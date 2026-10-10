# CELinK API reference

Calculator-side C library (`src/celink.h`, `src/celink.c`). The calculator is the USB host; a Raspberry Pi Pico 2 W running the CELinK CircuitPython code (`pico 2w/`) is the network device.

All functions are declared in `celink.h`.

## Quick start

```c
#include "celink.h"

celink_init();

while (1) {
    celink_process();               /* call every loop iteration */

    if (celink_connected()) {
        char page[2048];
        int status;

        if (celink_get("example.com", page, sizeof(page), &status, 15))
            /* status == 200, page holds the first 2047 bytes */;
        else
            /* page holds an error message, status == -1 */;
    }
}

celink_disconnect();
```

`celink_process()` must keep being called: USB events (plug, unplug, enumeration) are handled inside it. The blocking calls below call it for you while they wait.

---

## Setup and connection

### `void celink_init(void)`
Sets up the calculator as a USB host and starts watching for a serial device. Call once at startup, before anything else.

### `void celink_process(void)`
Services USB events. Call every loop iteration. Does nothing if `celink_init()` hasn't been called.

### `bool celink_connected(void)`
`true` once the Pico has been detected and its serial port opened. `false` before that, and again after it is unplugged.

### `void celink_disconnect(void)`
Shuts down USB and forgets the connection. Safe to call even if never connected.

### `int celink_last_error(void)`
The last low-level `usbdrvce`/`srldrvce` error code, for debugging. `0` means none recorded.

---

## Raw serial access

### `bool celink_send(const char *command)`
Sends a command string (no trailing newline needed). Returns `true` if connected and the whole command was accepted. Use this for fire-and-forget commands:

```c
celink_send("connect|MyWifi|MyPassword");   /* no reply is sent */
celink_send("disconnect");                  /* no reply is sent */
```

### `int celink_read(char *buf, size_t len)`
Non-blocking. Copies bytes received since the last call into `buf` (at most `len - 1`, null-terminated). Returns the number of bytes copied, or `0` if nothing new arrived or not connected.

### `bool celink_request(const char *command, int expected_code, char *buf, size_t len, unsigned timeout_iters)`
Sends `command`, waits for the reply, and copies it into `buf`.

| Parameter | Meaning |
|---|---|
| `command` | Command string, e.g. `"wifiscan"` |
| `expected_code` | The reply code this command should answer with (see below) |
| `buf`, `len` | Where the reply text goes |
| `timeout_iters` | Gives up after this many loop iterations with nothing received (not real time) |

Returns `true` on success. Returns `false` on timeout, send failure, protocol mismatch, or if not connected. On a protocol mismatch, `buf` holds a message such as `Protocol mismatch (got code 3, expected 2).`

Stale data left over from earlier commands is discarded before the command is sent, so a reply is never mistaken for the previous one.

### Reply codes

Every reply from the Pico starts with one raw code byte saying which command it answers. `celink_request()` checks it against `expected_code`.

| Constant | Value | Command |
|---|---|---|
| `CELINK_CODE_WIFISCAN` | 1 | `wifiscan` |
| `CELINK_CODE_STATUS` | 2 | `wifiisconnected` |
| `CELINK_CODE_PING` | 3 | `ping` |
| `CELINK_CODE_GET` | 4 | `get` |
| `CELINK_CODE_POST` | 4 | `post` (reuses the `get` code) |

`connect` and `disconnect` have no code because they send no reply.

### Commands

| Command | Reply code | Reply text |
|---|---|---|
| `wifiscan` | 1 | `SSID:strength\|SSID:strength\|...` |
| `connect\|ssid\|password` | none | none (fire-and-forget; check status afterward) |
| `disconnect` | none | none (fire-and-forget) |
| `wifiisconnected` | 2 | `True` or `False` |
| `ping\|host\|timeout_s` | 3 | round-trip time in seconds, or `None` |

`get` and `post` have their own functions (below) because their replies carry a body.

---

## HTTP

Both `celink_get()` and `celink_post()` talk to the Pico, which makes the real HTTP/HTTPS request. They share the same behavior:

- **Waiting is measured in real seconds.** The calc waits up to `timeout_s` plus 3 seconds of margin for the response header, then gives up on the body if it stalls for 3 seconds with no new bytes.
- **On success** they return `true`, set `*out_status` to the HTTP status code, and copy the response body (null-terminated, at most `max - 1` bytes) into your buffer.
- **On failure** they return `false`, set `*out_status` to `-1`, and put an error message in your buffer.
- If the body stalls partway, they return `false` but your buffer holds the partial body and `*out_status` is the real HTTP status.
- URLs may not contain `|` (it separates protocol fields).
- URLs without a scheme are accepted: the Pico adds `https://` if the host has letters, otherwise `http://` (so `192.168.2.203:8080` works).
- HTTPS only works for sites whose root certificate is in `r1.pem` on the Pico.

### `bool celink_get(const char *url, char *body, size_t max_body, int *out_status, unsigned timeout_s)`

Fetches a URL.

| Parameter | Meaning |
|---|---|
| `url` | Page to fetch |
| `body` | Buffer for the response body |
| `max_body` | Size of `body`. The Pico is told to send at most `max_body - 1` bytes |
| `out_status` | Receives the HTTP status code, or `-1` on failure. May be `NULL` |
| `timeout_s` | Seconds the Pico may spend on the request |

### `bool celink_post(const char *url, const char *content_type, const void *post_body, size_t post_len, char *response, size_t max_response, int *out_status, unsigned timeout_s)`

Sends data to a URL with a POST request.

| Parameter | Meaning |
|---|---|
| `url` | Where to POST |
| `content_type` | e.g. `"application/x-www-form-urlencoded"`. May not contain `\|` |
| `post_body`, `post_len` | The request body and its length in bytes |
| `response`, `max_response` | Buffer for the response body, and its size |
| `out_status` | Receives the HTTP status code, or `-1` on failure. May be `NULL` |
| `timeout_s` | Seconds the Pico may spend on the request |

The body is sent as raw bytes with its length, so it can contain `|`, newlines, or anything else. It is limited to `CELINK_POST_MAX_BODY` (512) bytes; a longer body fails with `Body too large (max 512).`

### `int celink_url_encode(const char *in, char *out, size_t out_len)`

Percent-encodes text for a form body or query string. Letters, digits and `- _ . ~` are kept, a space becomes `+`, everything else becomes `%XX`.

Returns the encoded length, or `-1` if `out` is too small (`out` is then left empty). Worst case the output is three times the input length plus one.

### Example: a search

```c
char form[2 + 3 * 64 + 1];
char page[12288];
int status;

strcpy(form, "q=");
celink_url_encode("cats & dogs", form + 2, sizeof(form) - 2);   /* q=cats+%26+dogs */

if (celink_post("https://lite.duckduckgo.com/lite/",
                "application/x-www-form-urlencoded",
                form, strlen(form),
                page, sizeof(page), &status, 15)) {
    /* page holds the results HTML */
}
```

### Error messages

When a call returns `false` the message is in the body/response buffer:

| Message | Meaning |
|---|---|
| *(empty)* | Not connected, or a `NULL` argument |
| `Timed out waiting for header.` | The Pico never answered in time |
| `Protocol mismatch (got code N, expected M).` | A reply for a different command arrived |
| `Bad hdr len=N: ...` | The response header was malformed |
| `Bad content length.` | The header's length field was negative |
| `Body too large (max 512).` | `post_len` is over `CELINK_POST_MAX_BODY` |
| `URL/type can't contain '\|'.` | `post` only |
| `URL too long.` | `post` only |
| `Send failed.` | `post` only: the serial write stalled |
| anything else | An `error\|...` message from the Pico, e.g. a TLS or DNS failure, or `body timeout` |

---

## Wire format

For anyone writing a different device or debugging with a serial terminal. Fields are separated by `|`.

**get**

```
get|<url>|<max_bytes>|<timeout_s>
```

**post** (the header ends with a newline, then exactly `<body_len>` raw bytes follow)

```
post|<url>|<max_response>|<timeout_s>|<content_type>|<body_len>\n<body bytes>
```

**get and post replies**

```
<code byte 0x04>status|<http code>|<length>\n<length raw body bytes>
<code byte 0x04>error|<message>\n
```