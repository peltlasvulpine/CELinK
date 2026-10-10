import usb_cdc
import time
import wifihelprs as wifi

serial = usb_cdc.data
MAX_POST_BODY = 512
POST_TIMEOUT_S = 3
a = 0


def read_post(io):
    buf = io

    last_rx = time.monotonic()
    while b"\n" not in buf:
        if time.monotonic() - last_rx > POST_TIMEOUT_S:
            return "error|header timeout\n", b""
        if serial.in_waiting:
            buf += serial.read(serial.in_waiting)
            last_rx = time.monotonic()

    header, _, body = buf.partition(b"\n")

    try:
        f = header.decode().split("|")
        url = f[1]
        maxbytes = int(f[2])
        timeout = int(f[3])
        content_type = f[4]
        body_len = int(f[5])
        if body_len < 0:
            raise ValueError
    except Exception:
        
        time.sleep(0.3)
        serial.reset_input_buffer()
        return "error|bad post header\n", b""

    too_big = body_len > MAX_POST_BODY
    received = len(body)
    if too_big:
        body = b""
    last_rx = time.monotonic()
    while received < body_len:
        if time.monotonic() - last_rx > POST_TIMEOUT_S:
            return "error|body timeout\n", b""
        if serial.in_waiting:
            chunk = serial.read(serial.in_waiting)
            received += len(chunk)
            if not too_big:
                body += chunk
            last_rx = time.monotonic()

    if too_big:
        return "error|body too large\n", b""

    return wifi.posturl(url, maxbytes, timeout, content_type, body[:body_len])


print("initialized")
serial.write(b"initialized")
while True:
    if serial.in_waiting:
        oi = "" # revese of input, output lmao. haha get it?
        oi2 = b"" # second payload
        code = None
        io = serial.read(serial.in_waiting) # input
        is_post = io.startswith(b"post|")
        data = "" if is_post else io.decode().strip()
        if data == "wifiscan":
            temp = wifi.scan()
            for ssid, strength in temp:
                oi += f"{ssid}:{strength}|"
            code = b"\x01"

        if data == "clear":
            for i in range(50):
                oi += " "
                oi2 += b" "
            oi += "|"
            oi2 += b"|"

        if data == "wifiisconnected":
            oi = str(wifi.wifi_is_connected())
            print("checked if wifi is connected")
            code = b"\x02"

        if data.startswith("connect"):
            temp = data.split("|")
            wifi.connect(temp[1], temp[2])

        if data == "disconnect":
            wifi.disconnect()

        if data.startswith("ping"):
            temp = data.split("|")
            oi = str(wifi.ping(temp[1], int(temp[2])))
            print(f"pinged {temp[1]}")
            code = b"\x03"

        if data.startswith("get"):
            temp = data.split("|")
            oi, oi2 = wifi.geturl(temp[1], int(temp[2]), int(temp[3]))
            code = b"\x04"

        if is_post:
            oi, oi2 = read_post(io)
            print("posted")
            code = b"\x04"

        if code is not None:
            serial.write(code)
            serial.write(oi.encode("utf-8"))
            serial.write(oi2)
