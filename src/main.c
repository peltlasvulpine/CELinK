#include <ti/screen.h>
#include <keypadc.h>
#include "celink.h"

int main(void)
{
    os_ClrHome();

    celink_init();

    os_PutStrFull("CELinK says hi!");
    os_NewLine();
    os_PutStrFull("Press CLEAR to quit.");

    while (1)
    {
        kb_Scan();

        if (kb_IsDown(kb_KeyClear))
            break;
    }

    celink_disconnect();

    return 0;
}