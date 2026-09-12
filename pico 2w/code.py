import usb_cdc
import time
import wifihelprs

serial = usb_cdc.data
a = 0
print("initialized")
serial.write(b"initialized")
while True:
    if serial.in_waiting:
        oi = "" # revese of input, output lmao. haha get it?
        oi2 = b"" # second payload
        code = None
        io = serial.read(serial.in_waiting) # input
        data = io.decode().strip()
        if data == "wifiscan":
            temp = wifihelprs.scan()
            for ssid, strength in temp:
                oi += f"{ssid}:{strength}|"
            code = b"\x01"

        if data == "clear":
            for i in range(50):
                oi += " "
            oi += "|"

        if data == "wifiisconnected":
            oi = str(wifihelprs.wifi_is_connected())
            print("checked if wifi is connected")
            code = b"\x02"

        if data.startswith("connect"):
            temp = data.split("|")
            wifihelprs.connect(temp[1], temp[2])

        if data == "disconnect":
            wifihelprs.disconnect()

        if data.startswith("ping"):
            temp = data.split("|")
            oi = str(wifihelprs.ping(temp[1], int(temp[2])))
            print(f"pinged {temp[1]}")
            code = b"\x03"
        
        if data.startswith("get"):
            temp = data.split("|")
            oi, oi2 = wifihelprs.geturl(temp[1], int(temp[2]))
            code = b"\x04"

        if data == "help":
            oi = wifihelprs.help()
            code = b"\x05"
        if code is not None:
            serial.write(code)
            serial.write(oi.encode("utf-8"))
            serial.write(oi2)