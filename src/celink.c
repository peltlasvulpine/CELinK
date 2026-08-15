#include "celink.h"

#include <usbdrvce.h>
#include <string.h>
#include <stdbool.h>

#define CELINK_REQUEST_SEND_MESSAGE 0x01
#define CELINK_REQUEST_TYPE         0x40
#define CELINK_MAX_MESSAGE          255

static char message_buffer[CELINK_MAX_MESSAGE + 1];

static volatile bool message_ready = false;
static volatile bool transfer_pending = false;
static bool usb_initialized = false;

volatile unsigned setup_seen = 0;
volatile unsigned transfer_scheduled = 0;
volatile unsigned transfer_completed = 0;
volatile unsigned last_status = 0;
volatile unsigned last_transferred = 0;

volatile unsigned last_bmRequestType = 0;
volatile unsigned last_bRequest = 0;
volatile unsigned last_wValue = 0;
volatile unsigned last_wIndex = 0;
volatile unsigned last_wLength = 0;

volatile unsigned schedule_error = 0;


static usb_error_t celink_transfer_callback(
    usb_endpoint_t endpoint,
    usb_transfer_status_t status,
    size_t transferred,
    usb_transfer_data_t *data)
{
    (void)endpoint;

    transfer_pending = false;

    last_status = status;
    last_transferred = transferred;
    transfer_completed++;

    if (status == USB_TRANSFER_COMPLETED)
    {
        if (transferred > CELINK_MAX_MESSAGE)
            transferred = CELINK_MAX_MESSAGE;

        if (data != NULL && transferred > 0)
            memcpy(message_buffer, data, transferred);

        message_buffer[transferred] = '\0';
        message_ready = true;
    }

    return USB_SUCCESS;
}


static usb_error_t celink_usb_event(
    usb_event_t event,
    void *event_data,
    usb_callback_data_t *callback_data)
{
    (void)callback_data;

    if (event != USB_DEFAULT_SETUP_EVENT)
        return USB_SUCCESS;

    setup_seen++;

    const usb_control_setup_t *setup =
        (const usb_control_setup_t *)event_data;

    if (setup == NULL)
        return USB_SUCCESS;

    last_bmRequestType = setup->bmRequestType;
    last_bRequest = setup->bRequest;
    last_wValue = setup->wValue;
    last_wIndex = setup->wIndex;
    last_wLength = setup->wLength;

    /*
     * Only accept our vendor OUT request:
     *
     * 40 01 ...
     *
     * 0x40 = HOST -> DEVICE | VENDOR | DEVICE
     * 0x01 = CELINK_REQUEST_SEND_MESSAGE
     */
    if (setup->bmRequestType != CELINK_REQUEST_TYPE)
        return USB_SUCCESS;

    if (setup->bRequest != CELINK_REQUEST_SEND_MESSAGE)
        return USB_SUCCESS;

    if (setup->wLength > CELINK_MAX_MESSAGE)
        return USB_IGNORE;

    if (transfer_pending)
        return USB_IGNORE;

    /*
     * The official usbdrvce test example obtains the default
     * control endpoint and schedules the transfer on that endpoint.
     */
    usb_device_t host =
        usb_FindDevice(NULL, NULL, USB_SKIP_HUBS);

    if (host == NULL)
    {
        last_status = USB_ERROR_NO_DEVICE;
        return USB_IGNORE;
    }

    usb_endpoint_t endpoint =
        usb_GetDeviceEndpoint(host, 0);

    if (endpoint == NULL)
    {
        last_status = USB_ERROR_SYSTEM;
        return USB_IGNORE;
    }

    transfer_pending = true;

    usb_error_t error = usb_ScheduleControlTransfer(
        endpoint,
        setup,
        message_buffer,
        celink_transfer_callback,
        NULL
    );

    if (error != USB_SUCCESS)
    {
        transfer_pending = false;

        schedule_error = error;
        last_status = error;

        return USB_IGNORE;
    }

    transfer_scheduled++;

    /*
     * Tell usbdrvce that we've handled this setup request.
     */
    return USB_IGNORE;
}


void celink_init(void)
{
    message_buffer[0] = '\0';

    message_ready = false;
    transfer_pending = false;
    usb_initialized = false;

    setup_seen = 0;
    transfer_scheduled = 0;
    transfer_completed = 0;

    last_status = 0;
    last_transferred = 0;

    last_bmRequestType = 0;
    last_bRequest = 0;
    last_wValue = 0;
    last_wIndex = 0;
    last_wLength = 0;

    schedule_error = 0;

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
        last_status = error;
    }
}


void celink_process(void)
{
    if (!usb_initialized)
        return;

    usb_HandleEvents();
    usb_PollTransfers();
}


bool celink_message_available(void)
{
    return message_ready;
}


const char *celink_get_message(void)
{
    message_ready = false;
    return message_buffer;
}


void celink_disconnect(void)
{
    if (!usb_initialized)
        return;

    usb_Cleanup();

    usb_initialized = false;
    transfer_pending = false;
    message_ready = false;

    message_buffer[0] = '\0';
}