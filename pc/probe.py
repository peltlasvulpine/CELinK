#!/usr/bin/env python3

import time
import usb.core
import usb.util


VID = 0x0451
PID = 0xE008

dev = usb.core.find(idVendor=VID, idProduct=PID)

if dev is None:
    print("calculator not found")
    raise SystemExit(1)

print("calculator found")
print("polling C0 02...")
print()

while True:
    try:
        data = dev.ctrl_transfer(
            0xC0,
            0x02,
            0,
            0,
            255,
            timeout=500,
        )

        print("RECEIVED:")
        print("bytes:", bytes(data))
        print("hex:  ", bytes(data).hex(" "))

        if data:
            break

    except usb.core.USBTimeoutError:
        print("timeout")

    except usb.core.USBError as e:
        print("USB ERROR:", e)
        break

    time.sleep(0.1)

usb.util.dispose_resources(dev)