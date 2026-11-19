/* Implementation test of the child-program glue of shim/src/cc_wk.c (shim-abi section 15, cc_wk_proc_*): a started program gets
 * a pipe on its standard input and one on its standard output (cat echoes), end of input ends it, its exit status is reported,
 * a running one is waited for with a timeout and stopped by force, nothing of the caller's other descriptors is inherited, the
 * refusals (no slot, no descriptor, no such program, unknown slot) are answered, and the executable's directory is found. The
 * loopback listener of cc_net is checked here too. */
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/resource.h>
#include <unistd.h>

#include "ccshim.h"
#include "testlib.h"

/* Reads from the slot until `want` bytes arrived or the output ended (at most about 5 s). */
static int32_t read_all(int32_t slot, uint8_t *buf, int32_t want) {
    int32_t got = 0;
    for (int i = 0; i < 5000 && got < want; i++) {
        int32_t n = 0;
        int32_t rc = cc_wk_proc_read(slot, buf + got, want - got, &n);
        if (rc == 0) {
            got += n;
        } else if (rc == CC_CLOSED) {
            return got;
        } else {
            usleep(1000);
        }
    }
    return got;
}

int main(void) {
    int32_t slot = 0;
    tl_int("test cc_wk_proc spawn cat", 0, cc_wk_proc_spawn("/bin/cat", "", &slot));
    tl_int("test cc_wk_proc slot is a number from 1", 1, slot >= 1 && slot <= 4);
    uint8_t buf[64];
    int32_t got = 0;
    tl_int("test cc_wk_proc nothing yet is again", CC_AGAIN, cc_wk_proc_read(slot, buf, 8, &got));
    tl_int("test cc_wk_proc write", 5, cc_wk_proc_write(slot, (const uint8_t *)"hello", 5));
    tl_int("test cc_wk_proc echo arrives", 5, read_all(slot, buf, 5));
    tl_int("test cc_wk_proc echo is intact", 1, memcmp(buf, "hello", 5) == 0);
    int32_t status = -1;
    tl_int("test cc_wk_proc a running program is again after the timeout", CC_AGAIN, cc_wk_proc_wait(slot, 10, &status));
    cc_wk_proc_close_input(slot);
    tl_int("test cc_wk_proc end of input ends cat", 0, cc_wk_proc_wait(slot, 5000, &status));
    tl_int("test cc_wk_proc cat exit status", 0, status);
    status = -1;
    tl_int("test cc_wk_proc wait again reports the same status", 0, cc_wk_proc_wait(slot, 0, &status));
    tl_int("test cc_wk_proc status again", 0, status);
    tl_int("test cc_wk_proc output ends", CC_CLOSED, cc_wk_proc_read(slot, buf, 8, &got));
    tl_int("test cc_wk_proc write after close_input is refused", -1, cc_wk_proc_write(slot, (const uint8_t *)"x", 1));
    tl_int("test cc_wk_proc stop of an ended program", 0, cc_wk_proc_stop(slot));
    tl_int("test cc_wk_proc stop twice is refused", -1, cc_wk_proc_stop(slot));
    tl_int("test cc_wk_proc wait for an unknown slot", -1, cc_wk_proc_wait(slot, 0, &status));
    tl_int("test cc_wk_proc write to an unknown slot", -1, cc_wk_proc_write(slot, (const uint8_t *)"x", 1));
    tl_int("test cc_wk_proc read from an unknown slot", CC_CLOSED, cc_wk_proc_read(slot, buf, 8, &got));
    cc_wk_proc_close_input(slot);

    /* an exit status other than 0, and a write to a program that ended */
    tl_int("test cc_wk_proc spawn false", 0, cc_wk_proc_spawn("/usr/bin/false", "", &slot));
    tl_int("test cc_wk_proc false ends", 0, cc_wk_proc_wait(slot, 5000, &status));
    tl_int("test cc_wk_proc false exit status", 1, status);
    tl_int("test cc_wk_proc write to a program that ended is refused", -1, cc_wk_proc_write(slot, (const uint8_t *)"x", 1));
    cc_wk_proc_stop(slot);

    /* arguments: the words reach the program, the 16 word limit holds */
    tl_int("test cc_wk_proc spawn echo", 0, cc_wk_proc_spawn("/bin/echo", "a bb  c", &slot));
    tl_int("test cc_wk_proc echo arguments", 5, read_all(slot, buf, 7) == 7 && memcmp(buf, "a bb c\n", 7) == 0 ? 5 : 0);
    cc_wk_proc_stop(slot);
    tl_int("test cc_wk_proc spawn with too many words", 0,
        cc_wk_proc_spawn("/bin/echo", "1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20", &slot));
    tl_int("test cc_wk_proc words past the 16th are dropped", 1,
        read_all(slot, buf, 40) == 39 && memcmp(buf + 33, "15 16\n", 6) == 0);
    cc_wk_proc_stop(slot);

    /* a running program is stopped by force and reaped */
    tl_int("test cc_wk_proc spawn sleep", 0, cc_wk_proc_spawn("/bin/sleep", "30", &slot));
    tl_int("test cc_wk_proc stop of a running program", 0, cc_wk_proc_stop(slot));

    /* descriptors of the caller are not inherited: ls /dev/fd sees the standard three and its own directory, not descriptor 20 */
    int leak = open("/dev/null", O_RDONLY);
    dup2(leak, 20);
    tl_int("test cc_wk_proc spawn ls", 0, cc_wk_proc_spawn("/bin/ls", "/dev/fd", &slot));
    uint8_t listing[256];
    memset(listing, 0, sizeof listing);
    int32_t listed = read_all(slot, listing, 255);
    tl_int("test cc_wk_proc the child lists its descriptors", 1, listed >= 6 && memcmp(listing, "0\n1\n2\n", 6) == 0);
    tl_int("test cc_wk_proc the callers descriptor is not inherited", 1, strstr((const char *)listing, "20") == NULL);
    cc_wk_proc_stop(slot);
    close(leak);
    close(20);

    /* refusals: a program that does not exist, no slot, no descriptor for the first pipe, none for the second */
    tl_int("test cc_wk_proc no such program", CC_NOTFOUND, cc_wk_proc_spawn("/nonexistent/program", "", &slot));
    int32_t slots[5];
    int32_t last = 0;
    for (int i = 0; i < 4; i++) {
        cc_wk_proc_spawn("/bin/cat", "", &slots[i]);
    }
    tl_int("test cc_wk_proc no free slot", CC_NOTFOUND, cc_wk_proc_spawn("/bin/cat", "", &last));
    for (int i = 0; i < 4; i++) {
        cc_wk_proc_stop(slots[i]);
    }
    struct rlimit nofile;
    getrlimit(RLIMIT_NOFILE, &nofile);
    int spare = dup(0);
    close(spare);
    struct rlimit lim = nofile;
    lim.rlim_cur = (rlim_t)spare + 1;
    setrlimit(RLIMIT_NOFILE, &lim);
    int32_t f1 = cc_wk_proc_spawn("/bin/cat", "", &last);
    lim.rlim_cur = (rlim_t)spare + 2;
    setrlimit(RLIMIT_NOFILE, &lim);
    int32_t f2 = cc_wk_proc_spawn("/bin/cat", "", &last);
    setrlimit(RLIMIT_NOFILE, &nofile);
    tl_int("test cc_wk_proc no descriptor for the first pipe", CC_NOTFOUND, f1);
    tl_int("test cc_wk_proc no descriptor for the second pipe", CC_NOTFOUND, f2);
    tl_int("test cc_wk_proc spawn works again", 0, cc_wk_proc_spawn("/bin/cat", "", &slot));
    cc_wk_proc_stop(slot);

    /* the executable's directory */
    uint8_t dir[1024];
    int32_t n = cc_wk_self_dir(dir, 1024);
    tl_int("test cc_wk_self_dir finds a directory", 1, n > 1 && dir[0] == '/');
    char self[1100];
    snprintf(self, sizeof self, "%.*s/test_cc_wk_proc", (int)n, (const char *)dir);
    tl_int("test cc_wk_self_dir holds this program", 0, access(self, X_OK));
    tl_int("test cc_wk_self_dir with a buffer too small", -1, cc_wk_self_dir(dir, 1));

    /* the loopback listener accepts on 127.0.0.1 only */
    int32_t listener = 0;
    int32_t port = 0;
    tl_int("test cc_net_listen_loopback", 0, cc_net_listen_loopback(0, &listener, &port));
    tl_int("test cc_net_listen_loopback port", 1, port > 0);
    int32_t again_listener = 0;
    int32_t again_port = 0;
    tl_int("test cc_net_listen_loopback port in use", CC_ADDR_IN_USE, cc_net_listen_loopback(port, &again_listener, &again_port));
    int32_t client = 0;
    cc_net_connect("127.0.0.1", port, &client);
    int32_t accepted = 0;
    int32_t rc = CC_AGAIN;
    for (int i = 0; i < 2000 && rc != 0; i++) {
        rc = cc_net_accept(listener, &accepted);
        usleep(1000);
    }
    tl_int("test cc_net_listen_loopback accepts a loopback client", 0, rc);
    cc_net_close(accepted);
    cc_net_close(client);
    cc_net_close(listener);
    return 0;
}
