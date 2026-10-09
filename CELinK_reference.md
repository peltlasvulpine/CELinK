# CELinK — Project Reference

*Give the TI-84 Plus CE internet access via an external device.*

---

## 🎯 Core Goal

- [x] Give the TI-84 Plus CE internet/networking capability
- [x] Use an external device to provide networking
- [x] CE ↔ external device over USB
- [x] External device ↔ Wi-Fi/network
- [ ] Expose all of this through a clean C library

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

The calculator is the USB host. It's what powers the link and initiates the
connection, via `srldrvce` in host mode. The Pico 2 W is the USB device,
running CircuitPython with `usb_cdc.data` enabled. They talk over a plain
pipe-delimited text protocol (see below) rather than raw custom control
transfers — simpler on both ends, and the calc's `srldrvce` and the Pico's
`usb_cdc` are both just doing standard serial.

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
| `get\|url\|maxbytes\|timeout` | Fetch a URL (HTTP or HTTPS) via `adafruit_requests` with a `timeout` in seconds; reply as `status\|code\|len` + raw body, or `error\|message` | ✅ |

### Reply framing

Every command that sends a reply starts it with a single raw **code byte**
saying which command it answers. That lets the calc reject a stale reply
left over from an earlier command instead of showing it as the wrong answer
(the old "PING shows the previous result" bug).

| Code | Command |
|---|---|
| 1 | `wifiscan` |
| 2 | `wifiisconnected` |
| 3 | `ping` |
| 4 | `get` |
| 5 | `help` |

Reply layout is `<code byte><text>`. For `get`, the text is
`status|<http code>|<length>\n` followed by exactly `<length>` raw body
bytes (not escaped), or `error|<message>\n` with no body on failure.

`connect` and `disconnect` are fire-and-forget: no code, no reply — check
`wifiisconnected` afterwards. `clear` also sets no code, so as it stands
nothing is sent back for it.

### Calculator side — confirmed working on real hardware

`src/celink.c` / `src/celink.h` implement the calc as a USB host via
`srldrvce`. `src/main.c` is a demo/example program built on top of that
library. It exists to prove the library actually works, not as the
deliverable itself; it sends the exact command set above and displays the
replies. Tested end-to-end on real hardware: calculator ↔ Pico 2 W ↔
Wi-Fi, all commands confirmed working from the calc's own menu.

`celink_get()` sends its timeout to the Pico and waits in real seconds
(via `clock()`) for the reply, plus a few seconds of margin so the Pico's
own timeout error can arrive first. Other requests still use
loop-iteration timeouts. If a `get` reply's header can't be parsed, the
calc shows `Bad hdr len=<n>: <what it read>` so the bad line is visible.

---

## 📦 Repo

- Repo: `peltlasvulpine/CELinK`, on `main`
- `src/` — calculator side (`celink.c` / `celink.h` library, `main.c` demo)
- `pico 2w/` — Pico side (`code.py`, `wifihelprs.py`, `boot.py`); the Pico
  also needs an `r1.pem` CA bundle on `CIRCUITPY` (see Networking)
- `debugging/debugger.py` — laptop-side debug tool, used to test the
  Pico's `usb_cdc.data` protocol directly

---

## 📡 Current C API (`src/celink.h`)

```c
void celink_init(void);
void celink_process(void);
bool celink_connected(void);

bool celink_send(const char *command);
int  celink_read(char *buf, size_t len);
bool celink_request(const char *command, int expected_code, char *buf,
                     size_t len, unsigned timeout_iters);
bool celink_get(const char *url, char *body, size_t max_body,
                 int *out_status, unsigned timeout_s);

int  celink_last_error(void);
void celink_disconnect(void);
```

`expected_code` is one of the `CELINK_CODE_*` constants in `celink.h`
(`WIFISCAN`, `STATUS`, `PING`, `GET`, `HELP`); a reply carrying any other
code fails with a "Protocol mismatch" message instead of being displayed.

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
- [ ] Avoid specialized equipment (except for the Pico 2W)

```
buy board → buy cable → flash CircuitPython → plug into CE → internet
```

> **Golden rule:** if you can't realistically build it with Amazon + free software, it's probably not a good reference design.

---

## 🚧 Protocol

The pipe-delimited text protocol (`wifiscan`, `connect|ssid|pass`, etc.)
works and is what's actually running, but it's informal:

- [ ] No protocol version field
- [ ] No structured error encoding (`get` errors come back as
      `error|message`; other commands return plain text, if anything)
- [ ] Timeouts only partly defined: `get` carries an explicit timeout in
      seconds, everything else still uses per-caller loop-iteration counts
- [ ] No max packet size enforcement
- [ ] No compatibility/version negotiation

Fine for a working prototype — worth formalizing before other people build
on top of it.

---

## 🌐 Networking

- [x] Wi-Fi scanning
- [x] Wi-Fi connect / disconnect / status
- [x] DNS (hostname → IP resolution for `ping`)
- [x] Ping
- [x] HTTP requests (`get|url|maxbytes|timeout`) — works for public sites
      and for servers on the local network (tested against a LAN
      `IP:port` server). A URL with no scheme gets `https://` if it
      contains letters and `http://` if it's a bare IP.
- [x] HTTPS — via a manually-curated multi-root CA bundle in `r1.pem`
      (loaded once with `ssl_context.load_verify_locations(cadata=...)`;
      covers Google's and DuckDuckGo's chains so far). Confirmed working
      against `https://www.google.com` and `https://lite.duckduckgo.com/lite/`
      on real hardware. Only sites whose root CA is in the bundle verify.
- [ ] POST requests — needed for anything that submits a form (e.g. actual
      DDG Lite search, which posts `q` to `/lite/`)
- [ ] Not possible on this hardware: WPA2-Enterprise / 802.1X networks
      (the Pico 2 W's CYW43439 only does WPA2-PSK) and 5GHz
- [ ] Structured network error handling — errors currently surface as
      whatever CircuitPython's bare `OSError`/mbedtls message happens to be,
      not always human-readable

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
| 6 | HTTP support (incl. HTTPS via CA bundle) | 🟢 Complete |
| 7 | Actual internet applications | ⬜ In progress (search via DDG Lite) |

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
