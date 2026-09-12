#include "celink.h"

#include <usbdrvce.h>
#include <srldrvce.h>
#include <string.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

/*
 * CELinK — calculator side (USB HOST)
 *
 * The calculator supplies power and initiates the USB connection. Once a
 * CDC-ACM serial device is found (the Pico 2 W, running CircuitPython with
 * usb_cdc.data enabled), we open it with srldrvce and exchange plain text
 * commands/replies over it.
 */

#define CELINK_SRL_BUFFER_SIZE 512
#define CELINK_BAUD_RATE       115200

static srl_device_t srl_dev;
static uint8_t srl_buffer[CELINK_SRL_BUFFER_SIZE];

static usb_device_t connected_device = NULL;
static bool usb_initialized = false;
static bool serial_open = false;

static int last_error = 0;


/*
 * USB event handler.
 *
 * We are the HOST here, so we watch for a device to connect, reset it,
 * then once it's enabled (and not itself trying to be a device — i.e. we
 * really are the host), hand it to srldrvce to open as a serial device.
 */
static usb_error_t celink_usb_event(
    usb_event_t event,
    void *event_data,
    usb_callback_data_t *callback_data)
{
    (void)callback_data;

    switch (event)
    {
        case USB_DEVICE_CONNECTED_EVENT:
        {
            usb_device_t device = (usb_device_t)event_data;

            if (!(usb_GetRole() & USB_ROLE_DEVICE))
            {
                usb_RefDevice(device);
                connected_device = device;
                usb_ResetDevice(device);
            }

            break;
        }

        case USB_DEVICE_ENABLED_EVENT:
        {
            usb_device_t device = (usb_device_t)event_data;

            if (!(usb_GetRole() & USB_ROLE_DEVICE))
            {
                srl_error_t error = srl_Open(
                    &srl_dev,
                    device,
                    srl_buffer,
                    sizeof(srl_buffer),
                    SRL_INTERFACE_ANY,
                    CELINK_BAUD_RATE
                );

                if (error == SRL_SUCCESS)
                {
                    serial_open = true;
                }
                else
                {
                    last_error = (int)error;
                }
            }

            break;
        }

        case USB_DEVICE_DISCONNECTED_EVENT:
        {
            usb_device_t device = (usb_device_t)event_data;

            if (serial_open && device == connected_device)
            {
                srl_Close(&srl_dev);
                serial_open = false;
            }

            if (device == connected_device)
            {
                usb_UnrefDevice(device);
                connected_device = NULL;
            }

            break;
        }

        default:
            return srl_UsbEventCallback(event, event_data, callback_data);
    }

    return USB_SUCCESS;
}


void celink_init(void)
{
    connected_device = NULL;
    usb_initialized = false;
    serial_open = false;
    last_error = 0;

    srl_buffer[0] = 0;

    usb_error_t error = usb_Init(
        celink_usb_event,
        NULL,
        NULL,
        USB_DEFAULT_INIT_FLAGS
    );

    if (error == USB_SUCCESS)
    {
        usb_initialized = true;
    }
    else
    {
        last_error = (int)error;
    }
}


void celink_process(void)
{
    if (!usb_initialized)
        return;

    usb_HandleEvents();
}


bool celink_connected(void)
{
    return serial_open;
}


bool celink_send(const char *command)
{
    size_t length;
    int written;

    if (!serial_open || command == NULL)
        return false;

    length = strlen(command);

    if (length == 0)
        return false;

    written = srl_Write(&srl_dev, command, length);

    if (written < 0)
    {
        last_error = written;
        return false;
    }

    return (size_t)written == length;
}


int celink_read(char *buf, size_t len)
{
    int read_count;

    if (buf == NULL || len == 0)
        return 0;

    if (!serial_open)
    {
        buf[0] = '\0';
        return 0;
    }

    read_count = srl_Read(&srl_dev, buf, len - 1);

    if (read_count < 0)
    {
        last_error = read_count;
        read_count = 0;
    }

    buf[read_count] = '\0';

    return read_count;
}


bool celink_request(const char *command, char *buf, size_t len,
                     unsigned timeout_iters)
{
    unsigned i;

    if (buf == NULL || len == 0)
        return false;

    buf[0] = '\0';

    if (!celink_send(command))
        return false;

    for (i = 0; i < timeout_iters; i++)
    {
        celink_process();

        if (celink_read(buf, len) > 0)
            return true;
    }

    return false;
}


int celink_last_error(void)
{
    return last_error;
}


#define CELINK_GET_CMD_MAX  512
#define CELINK_HEADER_MAX   128
#define CELINK_CHUNK_SIZE   64

bool celink_get(const char *url, char *body, size_t max_body,
                 int *out_status, unsigned timeout_iters)
{
    char command[CELINK_GET_CMD_MAX];
    char header[CELINK_HEADER_MAX];
    char pending[CELINK_CHUNK_SIZE];
    size_t pending_len = 0;
    size_t header_len = 0;
    size_t have = 0;
    unsigned idle = 0;
    bool header_done = false;
    long content_length = -1;
    char *bar1, *bar2;

    if (out_status != NULL)
        *out_status = -1;

    if (body == NULL || max_body == 0)
        return false;

    body[0] = '\0';

    if (url == NULL || !celink_connected())
        return false;

    /* Cap the body at what we can actually hold so the Pico doesn't
     * bother sending more than we can keep. */
    snprintf(command, sizeof(command), "get|%s|%u",
             url, (unsigned)(max_body - 1));

    if (!celink_send(command))
        return false;

    /* Phase 1: accumulate the "status|<code>|<len>" or "error|<msg>"
     * header line. Anything read past the newline in the same chunk
     * belongs to the body, not the header — stash it in `pending` so
     * phase 2 doesn't lose it. */
    while (!header_done && idle < timeout_iters)
    {
        char chunk[CELINK_CHUNK_SIZE];
        int n, i;

        celink_process();
        n = celink_read(chunk, sizeof(chunk));

        if (n <= 0)
        {
            idle++;
            continue;
        }

        idle = 0;

        for (i = 0; i < n; i++)
        {
            if (chunk[i] == '\n')
            {
                header_done = true;
                i++;
                break;
            }

            if (header_len + 1 < sizeof(header))
                header[header_len++] = chunk[i];
        }

        header[header_len] = '\0';

        if (header_done)
        {
            for (; i < n && pending_len < sizeof(pending); i++)
                pending[pending_len++] = chunk[i];
        }
    }

    if (!header_done)
    {
        strncpy(body, "Timed out waiting for header.", max_body - 1);
        body[max_body - 1] = '\0';
        return false;
    }

    if (strncmp(header, "error|", 6) == 0)
    {
        strncpy(body, header + 6, max_body - 1);
        body[max_body - 1] = '\0';
        return false;
    }

    /* Expect "status|<code>|<len>". */
    bar1 = strchr(header, '|');
    bar2 = bar1 ? strchr(bar1 + 1, '|') : NULL;

    if (bar1 == NULL || bar2 == NULL)
    {
        strncpy(body, "Bad response header.", max_body - 1);
        body[max_body - 1] = '\0';
        return false;
    }

    if (out_status != NULL)
        *out_status = atoi(bar1 + 1);

    content_length = atol(bar2 + 1);

    if (content_length < 0)
    {
        strncpy(body, "Bad content length.", max_body - 1);
        body[max_body - 1] = '\0';
        return false;
    }

    /* Phase 2: fill body with exactly content_length raw bytes, starting
     * with whatever was already stashed in `pending`. */
    for (size_t i = 0; i < pending_len && have + 1 < max_body; i++)
        body[have++] = pending[i];

    idle = 0;

    while ((long)have < content_length && idle < timeout_iters)
    {
        char chunk[CELINK_CHUNK_SIZE];
        int n, i;

        celink_process();
        n = celink_read(chunk, sizeof(chunk));

        if (n <= 0)
        {
            idle++;
            continue;
        }

        idle = 0;

        for (i = 0; i < n && have + 1 < max_body; i++)
            body[have++] = chunk[i];
    }

    body[have] = '\0';

    return (long)have >= content_length || have + 1 >= max_body;
}


void celink_disconnect(void)
{
    if (serial_open)
    {
        srl_Close(&srl_dev);
        serial_open = false;
    }

    if (connected_device != NULL)
    {
        usb_UnrefDevice(connected_device);
        connected_device = NULL;
    }

    if (usb_initialized)
    {
        usb_Cleanup();
        usb_initialized = false;
    }
}
