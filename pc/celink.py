#!/usr/bin/env python3

import sys
import usb.core
import usb.util

VID = 0x0451
PID = 0xE008

REQUEST_TYPE = 0x40
REQUEST_SEND_MESSAGE = 0x01

MAX_MESSAGE = 255


def find_calculator():
    print("Searching for calculator...")

    dev = usb.core.find(
        idVendor=VID,
        idProduct=PID
    )

    if dev is None:
        print("Error: CELinK calculator not found")
        return None

    print("Calculator found!")
    print(f"VID:PID = {VID:04X}:{PID:04X}")

    return dev


def send_message(dev, message):
    data = message.encode("utf-8")

    if len(data) > MAX_MESSAGE:
        raise ValueError(
            f"Message is too long ({len(data)} bytes, max {MAX_MESSAGE})"
        )

    if len(data) == 0:
        raise ValueError("Message cannot be empty")

    # Force the data into a mutable byte buffer.
    data = bytearray(data)

    print()
    print("Sending CELinK request:")
    print(f"  bmRequestType = 0x{REQUEST_TYPE:02X}")
    print(f"  bRequest      = 0x{REQUEST_SEND_MESSAGE:02X}")
    print(f"  wValue        = 0")
    print(f"  wIndex        = 0")
    print(f"  wLength       = {len(data)}")
    print(f"  data          = {data!r}")
    print(f"  hex           = {bytes(data).hex(' ')}")
    print()

    # PyUSB uses the length of the supplied byte buffer as wLength.
    transferred = dev.ctrl_transfer(
        bmRequestType=REQUEST_TYPE,
        bRequest=REQUEST_SEND_MESSAGE,
        wValue=0,
        wIndex=0,
        data_or_wLength=data,
        timeout=1000,
    )

    print(f"Sent: {message!r}")
    print(f"USB reported {transferred} bytes transferred")


def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <message>")
        return 1

    message = " ".join(sys.argv[1:])

    dev = find_calculator()

    if dev is None:
        return 1

    try:
        send_message(dev, message)

    except usb.core.USBError as e:
        print(f"USB error: {e}")
        return 1

    except ValueError as e:
        print(f"Error: {e}")
        return 1

    except Exception as e:
        print(f"Unexpected error: {e}")
        return 1

    finally:
        usb.util.dispose_resources(dev)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())