#!/usr/bin/env python3

import sys
import time

import usb.core
import usb.util


VID = 0x0451
PID = 0xE008

REQUEST_TYPE_OUT = 0x40
REQUEST_SEND_MESSAGE = 0x01

REQUEST_TYPE_IN = 0xC0
REQUEST_GET_RESPONSE = 0x02

MAX_MESSAGE = 255

RESPONSE_TIMEOUT = 30.0
POLL_TIMEOUT = 100
POLL_INTERVAL = 0.05


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

    if len(data) == 0:
        raise ValueError("Message cannot be empty")

    if len(data) > MAX_MESSAGE:
        raise ValueError(
            f"Message is too long ({len(data)} bytes, max {MAX_MESSAGE})"
        )

    data = bytearray(data)

    print()
    print("PC -> CALCULATOR")
    print(f"  bmRequestType = 0x{REQUEST_TYPE_OUT:02X}")
    print(f"  bRequest      = 0x{REQUEST_SEND_MESSAGE:02X}")
    print("  wValue        = 0")
    print("  wIndex        = 0")
    print(f"  wLength       = {len(data)}")
    print(f"  data          = {bytes(data)!r}")
    print(f"  hex           = {bytes(data).hex(' ')}")
    print()

    transferred = dev.ctrl_transfer(
        REQUEST_TYPE_OUT,
        REQUEST_SEND_MESSAGE,
        0,
        0,
        data,
        timeout=1000,
    )

    print(f"Sent {transferred} bytes.")


def wait_for_response(dev):
    print()
    print("CALCULATOR -> PC")
    print("Waiting for calculator response...")
    print("Press ENTER on the calculator.")
    print()

    deadline = time.monotonic() + RESPONSE_TIMEOUT
    polls = 0

    while time.monotonic() < deadline:
        polls += 1

        try:
            response = dev.ctrl_transfer(
                REQUEST_TYPE_IN,
                REQUEST_GET_RESPONSE,
                0,
                0,
                MAX_MESSAGE,
                timeout=POLL_TIMEOUT,
            )

            if response:
                data = bytes(response)

                print()
                print("CALCULATOR REPLIED!")
                print(f"  poll  = {polls}")
                print(f"  bytes = {len(data)}")
                print(f"  hex   = {data.hex(' ')}")

                try:
                    message = data.decode("utf-8")
                except UnicodeDecodeError:
                    message = data.decode(
                        "utf-8",
                        errors="replace"
                    )

                print(f"  text  = {message!r}")
                print()

                return message

            print(
                f"Poll {polls}: "
                "calculator has no response yet."
            )

        except usb.core.USBTimeoutError:
            # This is expected while the calculator has nothing queued.
            print(
                f"Poll {polls}: "
                "timeout, no response yet."
            )

        except usb.core.USBError as e:
            print()
            print("!!! USB ERROR WHILE POLLING !!!")
            print(f"  error = {e}")
            print(f"  errno = {getattr(e, 'errno', None)}")
            print(
                "  backend_error_code = "
                f"{getattr(e, 'backend_error_code', None)}"
            )
            print()
            return None

        time.sleep(POLL_INTERVAL)

    print()
    print("Timed out waiting for calculator response.")
    return None


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

        response = wait_for_response(dev)

        if response is None:
            return 1

    except usb.core.USBError as e:
        print()
        print("!!! USB ERROR !!!")
        print(f"error = {e}")
        print(f"errno = {getattr(e, 'errno', None)}")
        print(
            "backend_error_code = "
            f"{getattr(e, 'backend_error_code', None)}"
        )
        return 1

    except ValueError as e:
        print(f"Error: {e}")
        return 1

    except KeyboardInterrupt:
        print()
        print("Interrupted")
        return 130

    except Exception as e:
        print(f"Unexpected error: {e}")
        return 1

    finally:
        usb.util.dispose_resources(dev)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())