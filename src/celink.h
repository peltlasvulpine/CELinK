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

/* Shuts down USB and forgets the connection. Safe to call even if never
 * connected. */
void celink_disconnect(void);

#endif
