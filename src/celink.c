#include "celink.h"

#include <usbdrvce.h>
#include <srldrvce.h>
#include <string.h>
#include <stdbool.h>

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
