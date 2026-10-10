# CELinK

A library to connect your TI-84 Plus CE / TI-83 Premium CE to the interwebs!
Still a work in progress (almost done).

Since the Raspberry Pi Pico 2W only has a 2.4GHz radio, it can only connect to 2.4GHz networks
This means no 5GHz+ networks.

## Checklist

### 🎯 Core goal

- [x] Give the TI-84 Plus CE internet/networking capability
- [x] Use an external device to provide networking
- [x] CE ↔ external device over USB
- [x] External device ↔ Wi-Fi/network
- [x] Fetch web pages over HTTP/HTTPS (the `get` command)
- [x] POST / form support (needed for search boxes)
- [~] Expose all of this through a clean C library

---

## 🧱 Current architecture

```text
TI-84 Plus CE
      │
      │ USB (calc = host, powers the link)
      ▼
Raspberry Pi Pico 2 W
      │ (device, CircuitPython)
      │ Wi-Fi
      ▼
  Internet
```

The calculator acts as the USB host and supplies power over a stock
micro-USB ↔ mini-USB cable, which means no soldering nor attaching extra parts. The Pico 2 W
runs CircuitPython and exposes a small text command protocol over
`usb_cdc.data` (WiFi scanning, connect, disconnect, status, ping, etc.). The
calculator side talks to it in host mode via `srldrvce`.

## 📡 Status

Confirmed working end-to-end on real hardware, calculator ↔ Pico 2 W ↔ Wi-Fi.

From the calculator's demo menu you can currently:

- scan for Wi-Fi networks, connect, disconnect, and check status
- ping a host or IP
- fetch a web page over HTTP or HTTPS (`get`), including servers on your
  local network
- submit forms online via `post`

Current limits:

- **HTTPS only works for sites whose root certificate is in `r1.pem`** on
  the Pico (Google and DuckDuckGo so far)
- The demo shows the first couple of KB of a page as raw HTML since
  there's no renderer yet
- **2.4GHz, WPA2-PSK networks only.** WPA2-Enterprise networks (many
  school and work networks) can't work with the Pico 2 W's wireless chip

## 🛠 Setup (rough)

- **Pico 2 W:** flash CircuitPython, install `adafruit_requests`,
  `adafruit_connection_manager` and `adafruit_ntp` (for example with
  `circup`), copy the files from `pico 2w/` onto the `CIRCUITPY` drive,
  and edit `r1.pem` file with the root CA certificates you want
  more trusted / available domains (one certificate block after another).
- **Calculator:** build with the CE C/C++ Toolchain (a `makefile` is
  included; it needs the toolchain's `usbdrvce` and `srldrvce` libraries)
  and send the resulting `.8xp` to your calculator.
