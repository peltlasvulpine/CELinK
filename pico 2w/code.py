import usb_cdc
import time
import wifihelprs

serial = usb_cdc.data
a = 0
print("initialized")
serial.write(b"initialized")
while True:
    if serial.in_waiting:
        oi = ""
        io = serial.read(serial.in_waiting)
        data = io.decode().strip()
        if data == "wifiscan":
            temp = wifihelprs.scan()
            for ssid, strength in temp:
                oi += f"{ssid}:{strength}|"

        if data == "clear":
            for i in range(50):
                oi += " "
            oi += "|"

        if data == "wifiisconnected":
            oi = str(wifihelprs.wifi_is_connected())
            print("checked if wifi is connected")

        if data.startswith("connect"):
            temp = data.split("|")
            wifihelprs.connect(temp[1], temp[2])

        if data == "disconnect":
            wifihelprs.disconnect()

        if data.startswith("ping"):
            temp = data.split("|")
            oi = str(wifihelprs.ping(temp[1], int(temp[2])))
            print(f"pinged {temp[1]}")

        if data == "help":
            oi = wifihelprs.help()

        serial.write(oi.encode("utf-8"))