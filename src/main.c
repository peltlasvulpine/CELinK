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
#define BODY_SIZE     2048

/* Search demo: POST a form to DuckDuckGo Lite, then pull the result titles
 * out of the HTML. The results sit well past the page's header, so this
 * buffer is bigger than BODY_SIZE. */
#define SEARCH_URL          "https://lite.duckduckgo.com/lite/"
#define SEARCH_BODY_SIZE    12288
#define SEARCH_MAX_RESULTS  5
#define RESULT_TITLE_SIZE   60

/* Rough iteration-based timeouts for celink_request(). These are loop
 * counts, not calibrated real time — a Wi-Fi scan takes longer than a
 * status check, so it gets a bigger budget. */
#define TIMEOUT_SHORT  4000
#define TIMEOUT_MEDIUM 8000
#define TIMEOUT_LONG   15000

/* Seconds the Pico may spend on a fetch (DNS + TLS handshake + download).
 * Sent to the Pico with the request; the calc waits a few seconds longer
 * than this before giving up locally. */
#define GET_TIMEOUT_S  15


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
    os_PutStrFull("5:Ping  6:Search");
    os_NewLine();
    os_PutStrFull("7:Get");
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
    char *wifi;
    char *colon;
    char line[27];
    int lines = 0;

    if (!celink_connected())
    {
        show_result("WIFI SCAN", "Not connected to Pico.");
        return;
    }

    if (!celink_request("wifiscan", CELINK_CODE_WIFISCAN, response,
                         sizeof(response), TIMEOUT_LONG))
    {
        show_result("WIFI SCAN",
                     response[0] != '\0' ? response : "Timed out.");
        return;
    }

    os_ClrHome();

    wifi = strtok(response, "|");

    while (wifi != NULL && lines < 10)
    {
        colon = strchr(wifi, ':');

        if (colon != NULL)
        {
            *colon = '\0';

            snprintf(
                line,
                sizeof(line),
                "%-16.16s %.9s",
                wifi,
                colon + 1
            );

            os_PutStrFull(line);
            os_NewLine();

            lines++;
        }

        wifi = strtok(NULL, "|");
    }

    os_NewLine();
    os_PutStrFull("Press any key...");

    wait_for_any_key();
}


static void run_connect(void)
{
    char ssid[FIELD_SIZE];
    char password[FIELD_SIZE];
    char command[COMMAND_SIZE];

    if (!celink_connected())
    {
        show_result("CONNECT", "Not connected to Pico.");
        return;
    }

    os_ClrHome();

    os_PutStrFull("SSID:");
    os_NewLine();
    os_GetStringInput("", ssid, sizeof(ssid));
    os_NewLine();
    os_PutStrFull("PASSWORD:");
    os_NewLine();
    os_GetStringInput("", password, sizeof(password));

    snprintf(command, sizeof(command), "connect|%s|%s", ssid, password);

    if (celink_send(command))
        show_result("CONNECT", "Sent. Check status to confirm.");
    else
        show_result("CONNECT", "Failed to send.");
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

    if (celink_request("wifiisconnected", CELINK_CODE_STATUS, response,
                        sizeof(response), TIMEOUT_SHORT))
        show_result("STATUS", response);
    else
        show_result("STATUS", response[0] != '\0' ? response : "Timed out.");
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

    if (celink_request(command, CELINK_CODE_PING, response, sizeof(response),
                        TIMEOUT_MEDIUM))
        show_result("PING", response);
    else
        show_result("PING", response[0] != '\0' ? response : "Timed out.");
}


/* Copies the next HTML entity's character and advances *pp past it. Only
 * the handful DuckDuckGo actually uses in titles. */
static char take_entity(const char **pp)
{
    const char *p = *pp;

    if (strncmp(p, "&amp;", 5) == 0)  { *pp = p + 5; return '&'; }
    if (strncmp(p, "&quot;", 6) == 0) { *pp = p + 6; return '"'; }
    if (strncmp(p, "&#x27;", 6) == 0) { *pp = p + 6; return '\''; }
    if (strncmp(p, "&nbsp;", 6) == 0) { *pp = p + 6; return ' '; }
    if (strncmp(p, "&lt;", 4) == 0)   { *pp = p + 4; return '<'; }
    if (strncmp(p, "&gt;", 4) == 0)   { *pp = p + 4; return '>'; }

    *pp = p + 1;
    return '&';
}


/* Finds each <a ... class='result-link'>TITLE</a> in a DuckDuckGo Lite
 * results page and copies the TITLE text (tags stripped, common entities
 * decoded) into titles[]. Returns how many were found. */
static int parse_results(const char *html,
                         char titles[][RESULT_TITLE_SIZE], int max)
{
    static const char marker[] = "class='result-link'>";
    const char *p = html;
    int n = 0;

    while (n < max && (p = strstr(p, marker)) != NULL)
    {
        size_t d = 0;

        p += sizeof(marker) - 1;

        while (*p != '\0' && d + 1 < RESULT_TITLE_SIZE)
        {
            if (*p == '<')
            {
                if (strncmp(p, "</a>", 4) == 0)
                    break;

                while (*p != '\0' && *p != '>')
                    p++;

                if (*p != '\0')
                    p++;

                continue;
            }

            if (*p == '&')
                titles[n][d++] = take_entity(&p);
            else
                titles[n][d++] = *p++;
        }

        titles[n][d] = '\0';
        n++;
    }

    return n;
}


static void run_search(void)
{
    char query[FIELD_SIZE];
    char form[2 + 3 * FIELD_SIZE + 1];
    static char page[SEARCH_BODY_SIZE];
    char titles[SEARCH_MAX_RESULTS][RESULT_TITLE_SIZE];
    char line[RESULT_TITLE_SIZE + 16];
    char label[32];
    int status = -1;
    int found, i;
    int rows = 0;

    if (!celink_connected())
    {
        show_result("SEARCH", "Not connected to Pico.");
        return;
    }

    os_ClrHome();
    os_GetStringInput("SEARCH:", query, sizeof(query));

    if (query[0] == '\0')
        return;

    /* Form body: q=<url-encoded query> */
    strcpy(form, "q=");

    if (celink_url_encode(query, form + 2, sizeof(form) - 2) < 0)
    {
        show_result("SEARCH", "Query too long.");
        return;
    }

    os_ClrHome();
    os_PutStrFull("Searching...");

    if (!celink_post(SEARCH_URL, "application/x-www-form-urlencoded",
                     form, strlen(form), page, sizeof(page), &status,
                     GET_TIMEOUT_S))
    {
        snprintf(label, sizeof(label), "SEARCH FAILED (%d)", status);
        show_result(label, page);
        return;
    }

    found = parse_results(page, titles, SEARCH_MAX_RESULTS);

    if (found == 0)
    {
        snprintf(label, sizeof(label), "SEARCH %d", status);
        show_result(label, "No results found.");
        return;
    }

    os_ClrHome();

    for (i = 0; i < found; i++)
    {
        int need;

        snprintf(line, sizeof(line), "%d.%s", i + 1, titles[i]);
        need = ((int)strlen(line) + 25) / 26;

        if (i > 0 && rows + need > 8)
            break;

        os_PutStrFull(line);
        os_NewLine();
        rows += need;
    }

    os_NewLine();
    os_PutStrFull("Press any key...");

    wait_for_any_key();
}


static void run_get(void)
{
    char url[FIELD_SIZE];
    static char body[BODY_SIZE];
    char label[FIELD_SIZE + 16];
    int status = -1;

    if (!celink_connected())
    {
        show_result("GET", "Not connected to Pico.");
        return;
    }

    os_ClrHome();
    os_GetStringInput("URL:", url, sizeof(url));

    if (celink_get(url, body, sizeof(body), &status, GET_TIMEOUT_S))
    {
        /* BODY_SIZE is a lot smaller than most real pages, so this is
         * just enough to prove the fetch actually worked — not a
         * browser. Scrolling/paging through the rest is future work. */
        snprintf(label, sizeof(label), "GET %d", status);
        show_result(label, body);
    }
    else
    {
        snprintf(label, sizeof(label), "GET FAILED (%d)", status);
        show_result(label, body);
    }
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
            run_search();
            draw_menu(celink_connected());
        }
        else if (kb_IsDown(kb_Key7))
        {
            run_get();
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
