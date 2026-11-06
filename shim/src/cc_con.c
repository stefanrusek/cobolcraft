/* cc_con: non-blocking console lines from standard input (contracts/shim-abi.md §4). Glue only:
 * COBOL's ACCEPT blocks, and a non-blocking read needs struct pollfd and errno (shim-abi §1 table).
 *
 * Standard input is never switched to O_NONBLOCK (that flag would be shared with the terminal and
 * the parent shell); a read happens only after poll reports input, so it does not block. Bytes are
 * kept in a growing buffer until a newline completes a line, so a line may arrive in any number of
 * reads. A line longer than the caller's buffer is cut to `cap` bytes and the rest of it dropped.
 * At end of input an unterminated last line is still returned, then every later call is CC_CLOSED. */
#include <errno.h>
#include <poll.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "ccshim.h"

#define READ_CHUNK 4096

static uint8_t *pending;
static size_t used, size;
static int at_end;

/* Hands the first `length` pending bytes to the caller (cut to cap) and drops them plus `skip`. */
static int32_t take(size_t length, size_t skip, uint8_t *buf, int32_t cap, int32_t *len_out) {
    size_t copied = length < (size_t)cap ? length : (size_t)cap;
    memcpy(buf, pending, copied);
    *len_out = (int32_t)copied;
    used -= length + skip;
    memmove(pending, pending + length + skip, used);
    return 0;
}

int32_t cc_con_readline(uint8_t *buf, int32_t cap, int32_t *len_out) {
    *len_out = 0;
    for (;;) {
        uint8_t *newline = used > 0 ? memchr(pending, '\n', used) : NULL;
        if (newline != NULL) return take((size_t)(newline - pending), 1, buf, cap, len_out);
        if (at_end) return used > 0 ? take(used, 0, buf, cap, len_out) : CC_CLOSED;
        struct pollfd p = {.fd = STDIN_FILENO, .events = POLLIN, .revents = 0};
        if (poll(&p, 1, 0) < 0 && errno != EINTR) cc_fatal("cc_con_readline: poll failed");
        if (p.revents == 0) return CC_AGAIN;
        if (size - used < READ_CHUNK) {
            size = used + READ_CHUNK * 2;
            pending = realloc(pending, size);
            if (pending == NULL) cc_fatal("cc_con_readline: out of memory");
        }
        ssize_t n = read(STDIN_FILENO, pending + used, READ_CHUNK);
        if (n < 0 && errno != EINTR && errno != EAGAIN) cc_fatal("cc_con_readline: read failed");
        if (n > 0) used += (size_t)n;
        if (n == 0) at_end = 1;
    }
}
