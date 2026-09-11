# CELinK

A library to connect your TI-84 Plus CE / TI-83 Premium CE to the interwebs!
Still a work in progress.

Since the Raspberry Pi Pico 2W only has a 2.4GHz radio, it can only connect to 2.4GHz networks
This means no 5GHz or 6GHz networks.

## Checklist

### 🎯 Core goal

- [x] Give the TI-84 Plus CE internet/networking capability
- [x] Use an external device to provide networking
- [x] CE ↔ external device over USB
- [x] External device ↔ Wi-Fi/network
- [ ] Expose all of this through a clean C library
- [ ] Eventually make it practical for normal CE users

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
micro-USB ↔ mini-USB cable — no soldering, no extra hardware. The Pico 2 W
runs CircuitPython and exposes a small text command protocol over
`usb_cdc.data` (Wi-Fi scan, connect, disconnect, status, ping, help). The
calculator side talks to it in host mode via `srldrvce`.

## 📡 Status

- Pico-side Wi-Fi command layer: **working**, tested end-to-end from a
  laptop debugger
- Calculator-side host library + demo menu: **written**, not yet run on
  real hardware
