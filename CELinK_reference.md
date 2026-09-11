# CELinK — Project Reference

*Give the TI-84 Plus CE internet access via an external device.*

---

## 🎯 Core Goal

- [x] Give the TI-84 Plus CE internet/networking capability
- [x] Use an external device to provide networking
- [x] CE ↔ external device over USB
- [x] External device ↔ Wi-Fi/network
- [ ] Expose all of this through a clean C library
- [ ] Eventually make it practical for normal CE users

---

## 🧱 Architecture

```
TI-84 Plus CE
      │
      │ USB  (calc = host, srldrvce, supplies power)
      ▼
  Pico 2 W
      │  (device, CircuitPython usb_cdc)
      │ Wi-Fi
      ▼
  Internet
```

CELinK is the **abstraction layer** — not just "some USB code."

The calculator is the USB host. It's what powers the link and initiates the
connection, using `srldrvce` in host mode. The Pico 2 W is the USB device,
running CircuitPython with `usb_cdc.data` enabled. They talk over a plain
pipe-delimited text protocol (see below) rather than raw custom control
transfers — simpler on both ends, and the calc's `srldrvce` and the Pico's
`usb_cdc` are both just doing standard serial.

An earlier prototype had the calculator acting as a USB *device* answering
raw control transfers from a PC (the original proof of concept). That path
is superseded now that the architecture is calc-as-host — it's no longer
what CELinK uses, just history.

---

## 🟢 Status

### Pico side — working, tested end-to-end

The full command set below has been tested from a laptop debug script
(`debugging/debugger.py`) talking to the Pico over `usb_cdc.data`:

| Command | Does | Status |
|---|---|---|
| `wifiscan` | Scan nearby networks, return `ssid:strength\|...` | ✅ |
| `connect\|ssid\|password` | Join a network | ✅ |
| `disconnect` | Leave the current network | ✅ |
| `wifiisconnected` | Returns `True`/`False` | ✅ |
| `ping\|host\|timeout` | Ping by IP or hostname (DNS-resolved) | ✅ |
| `help` | List available commands | ✅ |
| `clear` | Send a blank/padding response | ✅ |

### Calculator side — confirmed working on real hardware

`src/celink.c` / `src/celink.h` implement the calc as a USB host via
`srldrvce`. `src/main.c` is a demo/example program built on top of that
library — it exists to prove the library actually works, not as the
deliverable itself; it sends the exact command set above and displays the
replies. Tested end-to-end on real hardware: calculator ↔ Pico 2 W ↔
Wi-Fi, all commands confirmed working from the calc's own menu.

---

## 📦 Repo

- Repo: `peltlasvulpine/CELinK`, on `main`
- `pc/celink.py` — early PC-side dev/test client from the original
  device-mode prototype; not the current architecture's endpoint
- `debugging/debugger.py` — current laptop-side debug tool, used to test
  the Pico's `usb_cdc.data` protocol directly

---

## 📡 Current C API (`src/celink.h`)

```c
void celink_init(void);
void celink_process(void);
bool celink_connected(void);

bool celink_send(const char *command);
int  celink_read(char *buf, size_t len);
bool celink_request(const char *command, char *buf, size_t len,
                     unsigned timeout_iters);

int  celink_last_error(void);
void celink_disconnect(void);
```

This is the actual, implemented calculator-side API — a thin, working layer
over `srldrvce`, not yet the fully abstracted "hides the protocol
entirely" API Rule 1 describes below. Confirmed working on hardware via
`src/main.c`; the abstraction layer (Milestone 5) is the next thing to
build on top of it.

---

## 📜 Design Rules

### Rule 1 — Developer-friendly

> App developers shouldn't have to worry about the underlying protocol or maintaining compatibility.

- [x] A C API exists and works (`celink_send`/`celink_request`/etc.)
- [ ] Protocol details (the `wifiscan`/`connect|...` command strings) hidden
      behind proper function calls, e.g. `celink_wifi_scan()`
- [x] USB details hidden — callers never touch `srldrvce`/`usbdrvce` directly
- [ ] Networking details hidden
- [ ] Protocol versions handled by CELinK
- [ ] Backwards compatibility handled automatically
- [ ] Documentation good enough to make app development easy

```
"I want internet."
        ↓
     CELinK
        ↓
complicated shit handled here
```

### Rule 2 — User-friendly / accessible hardware

> Ordinary users should be able to build the hardware setup with cheap, readily available, preassembled parts.

- [x] No soldering for reference setup
- [x] No custom PCB required
- [x] Common cables/adapters — stock micro↔mini cable, no wiring needed
- [x] Prove stuff with PC/laptop before buying hardware
- [ ] Free/open-source software where possible
- [ ] Avoid specialized equipment (still just the Pico + cable — fine so far)

```
buy board → buy cable → flash CircuitPython → plug into CE → internet
```

> **Golden rule:** if you can't realistically build it with Amazon + free software, it's probably not a good reference design.

---

## 🚧 Protocol — Still Loose

The pipe-delimited text protocol (`wifiscan`, `connect|ssid|pass`, etc.)
works and is what's actually running, but it's informal:

- [ ] No protocol version field
- [ ] No structured error encoding (errors come back as plain text, if at
      all)
- [ ] No defined timeout/retry behavior beyond what each caller invents
- [ ] No max packet size enforcement
- [ ] No compatibility/version negotiation

Fine for a working prototype — worth formalizing before other people build
on top of it.

---

## 🌐 Networking — Pico Side Implemented, HTTP Still Missing

- [x] Wi-Fi scanning
- [x] Wi-Fi connect / disconnect / status
- [x] DNS (hostname → IP resolution for `ping`)
- [x] Ping
- [ ] HTTP requests
- [ ] Structured network error handling

---

## 🏁 Milestones

| # | Milestone | Status |
|---|---|---|
| 0 | USB communication proof of concept | 🟢 Complete (superseded design) |
| 1 | Pico ↔ laptop `usb_cdc.data` protocol | 🟢 Complete |
| 2 | Full Wi-Fi command set on the Pico | 🟢 Complete |
| 3 | Calc-side host library + demo | 🟢 Complete |
| 4 | Calc ↔ Pico working end-to-end | 🟢 Complete |
| 5 | Clean abstracted C API (hides protocol) | ⬜ Next |
| 6 | HTTP support | ⬜ |
| 7 | Actual internet applications | ⬜ |

That's when CELinK stops being "cool USB experiment" and becomes **the
calculator internet library**.

---

## 🧾 Canonical Checklist (condensed)

- USB first.
- Protocol before more networking features.
- API hides implementation details.
- Hardware should be accessible — no PCB, no soldering.
- Use cheap, commonly available hardware.
- Free/open-source tooling where possible.
- Community builds apps, CELinK provides the infrastructure.
- Don't make application developers understand USB/Wi-Fi internals.

> **CELinK isn't supposed to be a one-off program that happens to access Wi-Fi. It's supposed to become the reusable networking layer that CE applications can build on.**
