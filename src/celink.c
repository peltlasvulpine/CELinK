#include "celink.h"

#include <usbdrvce.h>
#include <string.h>
#include <stdbool.h>

#define CELINK_REQUEST_SEND_MESSAGE 0x01
#define CELINK_REQUEST_GET_RESPONSE 0x02

#define CELINK_REQUEST_OUT 0x40
#define CELINK_REQUEST_IN  0xC0

#define CELINK_MAX_MESSAGE 255

static char message_buffer[CELINK_MAX_MESSAGE + 1];
static char response_buffer[CELINK_MAX_MESSAGE + 1];

static volatile bool message_ready = false;
static volatile bool response_pending = false;
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


/*
 * PC -> calculator transfer callback.
 *
 * DO NOT CHANGE THIS PATH.
 */
static usb_error_t celink_receive_callback(
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


/*
 * Calculator -> PC transfer callback.
 */
static usb_error_t celink_response_callback(
    usb_endpoint_t endpoint,
    usb_transfer_status_t status,
    size_t transferred,
    usb_transfer_data_t *data)
{
    (void)endpoint;
    (void)data;

    transfer_pending = false;

    last_status = status;
    last_transferred = transferred;
    transfer_completed++;

    if (status == USB_TRANSFER_COMPLETED)
    {
        response_pending = false;
        response_buffer[0] = '\0';
    }

    return USB_SUCCESS;
}


/*
 * USB setup-event handler.
 */
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
     * ============================================================
     * PC -> CALCULATOR
     *
     * 40 01
     *
     * ORIGINAL WORKING PATH.
     * ============================================================
     */
    if (setup->bmRequestType == CELINK_REQUEST_OUT &&
        setup->bRequest == CELINK_REQUEST_SEND_MESSAGE)
    {
        if (setup->wLength > CELINK_MAX_MESSAGE)
            return USB_IGNORE;

        if (transfer_pending)
            return USB_IGNORE;

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
            celink_receive_callback,
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

        return USB_IGNORE;
    }


    /*
     * ============================================================
     * CALCULATOR -> PC
     *
     * C0 02
     *
     * PC polls for a response.
     * ============================================================
     */
    if (setup->bmRequestType == CELINK_REQUEST_IN &&
        setup->bRequest == CELINK_REQUEST_GET_RESPONSE)
    {
        if (transfer_pending)
            return USB_IGNORE;

        if (setup->wLength == 0)
            return USB_IGNORE;

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


        /*
         * If a response is queued, send it.
         */
        if (response_pending)
        {
            size_t length = strlen(response_buffer);

            if (length > CELINK_MAX_MESSAGE)
                length = CELINK_MAX_MESSAGE;

            if (length > setup->wLength)
                length = setup->wLength;

            if (length == 0)
                return USB_IGNORE;

            transfer_pending = true;

            usb_error_t error = usb_ScheduleTransfer(
                endpoint,
                response_buffer,
                length,
                celink_response_callback,
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

            return USB_IGNORE;
        }


        /*
         * No response is queued.
         *
         * We still need to complete the poll rather than simply
         * ignoring the setup request.
         */
        transfer_pending = true;

        usb_error_t error = usb_ScheduleTransfer(
            endpoint,
            NULL,
            0,
            celink_response_callback,
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

        return USB_IGNORE;
    }

    return USB_SUCCESS;
}


void celink_init(void)
{
    message_buffer[0] = '\0';
    response_buffer[0] = '\0';

    message_ready = false;
    response_pending = false;
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


bool celink_response_pending(void)
{
    return response_pending;
}


bool celink_send(const char *message)
{
    size_t length;

    if (message == NULL)
        return false;

    length = strlen(message);

    if (length == 0 || length > CELINK_MAX_MESSAGE)
        return false;

    if (response_pending || transfer_pending)
        return false;

    memcpy(response_buffer, message, length);
    response_buffer[length] = '\0';

    response_pending = true;

    return true;
}


void celink_disconnect(void)
{
    if (!usb_initialized)
        return;

    usb_Cleanup();

    usb_initialized = false;
    transfer_pending = false;
    message_ready = false;
    response_pending = false;

    message_buffer[0] = '\0';
    response_buffer[0] = '\0';
}