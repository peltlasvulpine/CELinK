#ifndef CELINK_H
#define CELINK_H

#include <stdbool.h>
#include <stddef.h>

void celink_init(void);
void celink_disconnect(void);
void celink_process(void);

bool celink_message_available(void);
const char *celink_get_message(void);

bool celink_response_pending(void);
bool celink_send(const char *message);

#endif