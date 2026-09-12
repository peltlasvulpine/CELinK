#ifndef CELINK_H
#define CELINK_H

#include <stdbool.h>
#include <stddef.h>

/*
 * CELinK — calculator side
 *
 * The calculator acts as the USB HOST and supplies power. It looks for a
 * connected USB CDC serial device (the CELinK Pico 2 W running CircuitPython
 * with usb_cdc.data enabled) and talks to it using a simple pipe-delimited
 * text protocol, e.g. "wifiscan", "connect|SSID|PASSWORD", "ping|IP|3".
 *
 * See wifihelprs.py / code.py on the Pico side for the exact command set.
 */

/* Sets up the calculator as a USB host and starts watching for a serial
 * device to connect. Call once at startup, before anything else in this
 * file. */
void celink_init(void);

/* Call every loop iteration. Services USB events and keeps the connection
 * to the Pico alive. Does nothing if celink_init() hasn't been called. */
void celink_process(void);

/* True once a serial (CDC) device has connected and been opened. False
 * before it connects, and after it disconnects. */
bool celink_connected(void);

/* Sends a raw command string (no trailing newline needed) to the connected
 * device. Returns true if celink_connected() and the whole command was
 * accepted into the outgoing buffer, false otherwise. */
bool celink_send(const char *command);

/* Non-blocking. Copies any bytes received since the last call into buf (up
 * to len - 1 bytes), null-terminated. Returns the number of bytes copied,
 * or 0 if nothing new has arrived (or not connected). */
int celink_read(char *buf, size_t len);

/* Sends `command`, then repeatedly calls celink_process() and checks for a
 * reply until one arrives or `timeout_iters` iterations pass with nothing
 * received. Copies the reply into buf on success. Returns true on success,
 * false on timeout, send failure, or if not connected. */
bool celink_request(const char *command, char *buf, size_t len,
                     unsigned timeout_iters);

/* Last low-level usbdrvce/srldrvce error code, for debugging. 0 means no
 * error has been recorded. */
int celink_last_error(void);

/* Fetches a URL through the Pico. Sends "get|<url>|<max_body-1>" so the
 * Pico knows the most it should bother sending, then reads back a
 * "status|<code>|<length>" header line followed by exactly <length> raw
 * body bytes (the body is NOT pipe-escaped — it's read as a known-length
 * blob, so it can contain any bytes except that an embedded '\0' will
 * still look like end-of-string once copied into `body`).
 *
 * On success, copies up to max_body - 1 body bytes into `body`
 * (null-terminated) and sets *out_status to the HTTP status code, then
 * returns true. On failure (a "error|<message>" reply, a malformed
 * header, or a stall of more than timeout_iters idle iterations waiting
 * for the header or for body bytes), copies an error message into
 * `body` instead, sets *out_status to -1, and returns false.
 *
 * timeout_iters is an *idle* timeout — it resets every time new bytes
 * arrive, so a slow-but-steady page transfer won't time out partway
 * through the way a fixed overall timeout would. */
bool celink_get(const char *url, char *body, size_t max_body,
                 int *out_status, unsigned timeout_iters);

/* Shuts down USB and forgets the connection. Safe to call even if never
 * connected. */
void celink_disconnect(void);

#endif
