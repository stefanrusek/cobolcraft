/* Implementation test of shim/src/cc_con.c. Standard input is replaced by a pipe the test writes
 * into, so lines can arrive in pieces: a line split across reads, a line longer than one read
 * (READ_CHUNK, 4096 bytes), several lines in one read, a line longer than the caller's buffer (cut
 * to cap, rest dropped), and an unterminated last line at end of input. */
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "ccshim.h"
#include "testlib.h"

#define LONG_LINE 10000

static uint8_t line[LONG_LINE + 1];
static int32_t length;

static int32_t read_line(int32_t cap) {
    length = -1;
    int32_t rc = cc_con_readline(line, cap, &length);
    line[length < 0 ? 0 : length] = 0;
    return rc;
}

int main(void) {
    int pipe_fds[2];
    pipe(pipe_fds);
    dup2(pipe_fds[0], STDIN_FILENO);
    int out = pipe_fds[1];

    tl_int("test cc_con_readline with no input returns CC_AGAIN", CC_AGAIN, read_line(LONG_LINE));
    tl_int("test cc_con_readline with no input reports length 0", 0, length);

    write(out, "list", 4);
    tl_int("test cc_con_readline partial line returns CC_AGAIN", CC_AGAIN, read_line(LONG_LINE));
    write(out, " players\n", 9);
    tl_int("test cc_con_readline line completed by a later read returns 0", 0, read_line(LONG_LINE));
    tl_str("test cc_con_readline line completed by a later read is assembled", "list players", (const char *)line);

    write(out, "time\nweather\n", 13);
    read_line(LONG_LINE);
    tl_str("test cc_con_readline first of two lines in one read", "time", (const char *)line);
    read_line(LONG_LINE);
    tl_str("test cc_con_readline second of two lines in one read", "weather", (const char *)line);

    char *big = malloc(LONG_LINE + 1);
    for (int i = 0; i < LONG_LINE; i++) big[i] = (char)('a' + i % 26);
    big[LONG_LINE] = '\n';
    write(out, big, LONG_LINE + 1);
    tl_int("test cc_con_readline line longer than one read returns 0", 0, read_line(LONG_LINE));
    tl_int("test cc_con_readline line longer than one read has every byte", LONG_LINE, length);
    tl_int("test cc_con_readline line longer than one read keeps the bytes", 0, memcmp(big, line, LONG_LINE));

    write(out, "abcdefgh\nnext\n", 14);
    tl_int("test cc_con_readline line longer than cap returns 0", 0, read_line(3));
    tl_str("test cc_con_readline line longer than cap is cut to cap", "abc", (const char *)line);
    read_line(LONG_LINE);
    tl_str("test cc_con_readline after a cut line the next line follows", "next", (const char *)line);

    write(out, "save", 4);
    close(out);
    tl_int("test cc_con_readline unterminated last line at end of input returns 0", 0, read_line(LONG_LINE));
    tl_str("test cc_con_readline unterminated last line at end of input", "save", (const char *)line);
    tl_int("test cc_con_readline then returns CC_CLOSED", CC_CLOSED, read_line(LONG_LINE));
    free(big);
    return 0;
}
