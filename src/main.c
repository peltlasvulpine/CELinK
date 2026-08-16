#include <ti/screen.h>
#include <keypadc.h>
#include <stdio.h>

#include "celink.h"

extern volatile unsigned setup_seen;
extern volatile unsigned transfer_scheduled;
extern volatile unsigned transfer_completed;
extern volatile unsigned last_status;
extern volatile unsigned last_transferred;

extern volatile unsigned last_bmRequestType;
extern volatile unsigned last_bRequest;
extern volatile unsigned last_wLength;

int main(void)
{
    char buf[24];
    unsigned old_setup = 0xFFFFFF;

    os_ClrHome();

    celink_init();

    while (1)
    {
        kb_Scan();
        celink_process();

        if (setup_seen != old_setup)
        {
            old_setup = setup_seen;

            os_ClrHome();

            os_PutStrFull("CELinK DEBUG");
            os_NewLine();

            sprintf(buf, "SETUP %u", setup_seen);
            os_PutStrFull(buf);
            os_NewLine();

            sprintf(
                buf,
                "TYPE %02X REQ %02X",
                last_bmRequestType,
                last_bRequest
            );
            os_PutStrFull(buf);
            os_NewLine();

            sprintf(buf, "LEN %u", last_wLength);
            os_PutStrFull(buf);
            os_NewLine();

            sprintf(
                buf,
                "SCHED %u DONE %u",
                transfer_scheduled,
                transfer_completed
            );
            os_PutStrFull(buf);
            os_NewLine();

            sprintf(buf, "STAT %u", last_status);
            os_PutStrFull(buf);
            os_NewLine();

            sprintf(buf, "BYTES %u", last_transferred);
            os_PutStrFull(buf);
        }

        if (celink_message_available())
        {
            const char *message = celink_get_message();

            os_ClrHome();

            os_PutStrFull("PC SAYS:");
            os_NewLine();
            os_NewLine();

            os_PutStrFull(message);

            os_NewLine();
            os_NewLine();
            os_PutStrFull("ENTER = REPLY");
        }

        if (kb_IsDown(kb_KeyEnter))
        {
            if (celink_send("hello from CELinK"))
            {
                os_ClrHome();

                os_PutStrFull("REPLY QUEUED");
                os_NewLine();
                os_NewLine();

                os_PutStrFull("Waiting for PC...");
            }
        }

        if (kb_IsDown(kb_KeyClear))
            break;
    }

    celink_disconnect();

    return 0;
}