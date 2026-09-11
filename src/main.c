#include <ti/screen.h>
#include <keypadc.h>
#include <stdio.h>
#include <string.h>
#include <ti/getcsc.h>

#include "celink.h"

/*
 * CELinK menu demo (calculator side).
 *
 * Plug a CELinK Pico 2 W into the calculator's USB port. The calculator is
 * the host and powers the link, so nothing extra needs to be done on the
 * calculator's end besides plugging in.
 */

#define RESPONSE_SIZE 256
#define COMMAND_SIZE  300
#define FIELD_SIZE    64

/* Rough iteration-based timeouts for celink_request(). These are loop
 * counts, not calibrated real time — a Wi-Fi scan takes longer than a
 * status check, so it gets a bigger budget. */
#define TIMEOUT_SHORT  4000
#define TIMEOUT_MEDIUM 8000
#define TIMEOUT_LONG   15000


static void draw_menu(bool connected)
{
    os_ClrHome();
    os_PutStrFull("=== CELinK DEMO ===");
    os_NewLine();
    os_NewLine();

    os_PutStrFull(connected ? "STATUS: CONNECTED" : "STATUS: WAITING...");
    os_NewLine();
    os_NewLine();

    os_PutStrFull("1:Scan  2:Connect");
    os_NewLine();
    os_PutStrFull("3:Discon 4:Status");
    os_NewLine();
    os_PutStrFull("5:Ping  6:Help");
    os_NewLine();
    os_NewLine();
    os_PutStrFull("0:Debug  CLEAR:Quit");
}


static void wait_for_any_key(void)
{
    while (os_GetCSC())
        ;

    while (!os_GetCSC())
        ;
}


static void show_result(const char *label, const char *result)
{
    os_ClrHome();
    os_PutStrFull(label);
    os_NewLine();
    os_NewLine();

    if (result == NULL || result[0] == '\0')
        os_PutStrFull("(no response)");
    else
        os_PutStrFull(result);

    os_NewLine();
    os_NewLine();
    os_PutStrFull("Press any key...");

    wait_for_any_key();
}


static void show_debug_screen(void)
{
    char buf[32];

    os_ClrHome();
    os_PutStrFull("=== CELinK DEBUG ===");
    os_NewLine();
    os_NewLine();

    os_PutStrFull(celink_connected() ? "SERIAL: OPEN" : "SERIAL: CLOSED");
    os_NewLine();

    sprintf(buf, "LAST ERROR: %d", celink_last_error());
    os_PutStrFull(buf);
    os_NewLine();
    os_NewLine();

    os_PutStrFull("Press any key...");

    wait_for_any_key();
}


static void run_wifiscan(void)
{
    char response[RESPONSE_SIZE];

    if (!celink_connected())
    {
        show_result("WIFI SCAN", "Not connected to Pico.");
        return;
    }

    if (celink_request("wifiscan", response, sizeof(response), TIMEOUT_LONG))
        show_result("WIFI SCAN", response);
    else
        show_result("WIFI SCAN", "Timed out.");
}


static void run_connect(void)
{
    char ssid[FIELD_SIZE];
    char password[FIELD_SIZE];
    char command[COMMAND_SIZE];
    char response[RESPONSE_SIZE];

    if (!celink_connected())
    {
        show_result("CONNECT", "Not connected to Pico.");
        return;
    }

    os_ClrHome();
    os_GetStringInput("SSID:", ssid, sizeof(ssid));
    os_GetStringInput("PASSWORD:", password, sizeof(password));

    snprintf(command, sizeof(command), "connect|%s|%s", ssid, password);

    if (celink_request(command, response, sizeof(response), TIMEOUT_LONG))
        show_result("CONNECT", "Sent. Check status to confirm.");
    else
        show_result("CONNECT", "Timed out sending command.");
}


static void run_disconnect(void)
{
    if (!celink_connected())
    {
        show_result("DISCONNECT", "Not connected to Pico.");
        return;
    }

    if (celink_send("disconnect"))
        show_result("DISCONNECT", "Sent.");
    else
        show_result("DISCONNECT", "Failed to send.");
}


static void run_status(void)
{
    char response[RESPONSE_SIZE];

    if (!celink_connected())
    {
        show_result("STATUS", "Not connected to Pico.");
        return;
    }

    if (celink_request("wifiisconnected", response, sizeof(response),
                        TIMEOUT_SHORT))
        show_result("STATUS", response);
    else
        show_result("STATUS", "Timed out.");
}


static void run_ping(void)
{
    char host[FIELD_SIZE];
    char timeout_str[8];
    char command[COMMAND_SIZE];
    char response[RESPONSE_SIZE];

    if (!celink_connected())
    {
        show_result("PING", "Not connected to Pico.");
        return;
    }

    os_ClrHome();
    os_GetStringInput("HOST/IP:", host, sizeof(host));
    os_GetStringInput("TIMEOUT(s):", timeout_str, sizeof(timeout_str));

    snprintf(command, sizeof(command), "ping|%s|%s", host, timeout_str);

    if (celink_request(command, response, sizeof(response), TIMEOUT_MEDIUM))
        show_result("PING", response);
    else
        show_result("PING", "Timed out.");
}


static void run_help(void)
{
    char response[RESPONSE_SIZE];

    if (!celink_connected())
    {
        show_result("HELP", "Not connected to Pico.");
        return;
    }

    if (celink_request("help", response, sizeof(response), TIMEOUT_SHORT))
        show_result("HELP", response);
    else
        show_result("HELP", "Timed out.");
}


int main(void)
{
    bool was_connected = false;

    os_ClrHome();

    celink_init();

    draw_menu(false);

    while (1)
    {
        kb_Scan();
        celink_process();

        if (celink_connected() != was_connected)
        {
            was_connected = celink_connected();
            draw_menu(was_connected);
        }

        if (kb_IsDown(kb_KeyClear))
            break;

        if (kb_IsDown(kb_Key1))
        {
            run_wifiscan();
            draw_menu(celink_connected());
        }
        else if (kb_IsDown(kb_Key2))
        {
            run_connect();
            draw_menu(celink_connected());
        }
        else if (kb_IsDown(kb_Key3))
        {
            run_disconnect();
            draw_menu(celink_connected());
        }
        else if (kb_IsDown(kb_Key4))
        {
            run_status();
            draw_menu(celink_connected());
        }
        else if (kb_IsDown(kb_Key5))
        {
            run_ping();
            draw_menu(celink_connected());
        }
        else if (kb_IsDown(kb_Key6))
        {
            run_help();
            draw_menu(celink_connected());
        }
        else if (kb_IsDown(kb_Key0))
        {
            show_debug_screen();
            draw_menu(celink_connected());
        }
    }

    celink_disconnect();

    return 0;
}
