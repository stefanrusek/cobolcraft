/* Implementation test of the worker-process glue of shim/src/cc_wk.c (shim-abi section 15): a forked worker answers requests
 * over pipes, the parent reads without blocking, several workers are independent, a worker that ended is reported as end of
 * file, a stop reaps the process (graceful after end of input, forced when it is busy), a response larger than a pipe goes through
 * in pieces, and a worker started later does not hold the pipes of earlier ones. */
#include <errno.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/resource.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#include "ccshim.h"
#include "testlib.h"

#define BIG 304640

/* The worker: reads a 4-byte request n; n > 0 answers n * 2 as 4 bytes; n = -1 answers BIG bytes of (i % 251); n = -2 sleeps
 * forever (busy); n = -3 ends without answering. End of input ends the worker. */
static void serve(void) {
    for (;;) {
        int32_t n;
        if (cc_wk_child_read((uint8_t *)&n, 4) != 4) {
            break;
        }
        if (n > 0) {
            int32_t r = n * 2;
            cc_wk_child_write((const uint8_t *)&r, 4);
        } else if (n == -1) {
            static uint8_t big[BIG];
            for (int i = 0; i < BIG; i++) {
                big[i] = (uint8_t)(i % 251);
            }
            cc_wk_child_write(big, BIG);
        } else if (n == -2) {
            for (;;) {
                sleep(1);
            }
        } else {
            break;
        }
    }
    cc_wk_child_exit();
}

static int32_t spawn_server(void) {
    int32_t id = cc_wk_spawn();
    if (id == 0) {
        serve();
    }
    return id;
}

static int32_t recv_all(int32_t id, uint8_t *buf, int32_t n) {
    int32_t got = 0;
    time_t t0 = time(NULL);
    while (got < n && time(NULL) - t0 < 20) {
        int32_t r = cc_wk_recv(id, buf + got, n - got);
        if (r < 0) {
            return -1;
        }
        if (r == 0) {
            usleep(1000);
        }
        got += r;
    }
    return got;
}

int main(void) {
    int32_t a = spawn_server();
    int32_t b = spawn_server();
    tl_int("test cc_wk spawn gives slots", 1, a > 0 && b > 0 && a != b);

    uint8_t one[4];
    tl_int("test cc_wk nothing yet is zero", 0, cc_wk_recv(a, one, 4));
    int32_t n = 21;
    tl_int("test cc_wk send", 4, cc_wk_send(a, (const uint8_t *)&n, 4));
    tl_int("test cc_wk answer", 4, recv_all(a, one, 4));
    int32_t r;
    memcpy(&r, one, 4);
    tl_int("test cc_wk answer value", 42, r);
    n = 5;
    cc_wk_send(b, (const uint8_t *)&n, 4);
    recv_all(b, one, 4);
    memcpy(&r, one, 4);
    tl_int("test cc_wk second worker is independent", 10, r);

    n = -1;
    cc_wk_send(a, (const uint8_t *)&n, 4);
    static uint8_t big[BIG];
    tl_int("test cc_wk large response arrives in pieces", BIG, recv_all(a, big, BIG));
    int32_t ok = 1;
    for (int i = 0; i < BIG; i++) {
        if (big[i] != (uint8_t)(i % 251)) {
            ok = 0;
        }
    }
    tl_int("test cc_wk large response is intact", 1, ok);

    /* a worker that ends: end of file for the parent */
    n = -3;
    cc_wk_send(b, (const uint8_t *)&n, 4);
    int32_t eof = 0;
    for (int i = 0; i < 20000 && !eof; i++) {
        int32_t k = cc_wk_recv(b, one, 4);
        if (k < 0) {
            eof = 1;
        } else {
            usleep(1000);
        }
    }
    tl_int("test cc_wk ended worker reads as end of file", 1, eof);
    tl_int("test cc_wk stop of an ended worker", 0, cc_wk_stop(b, 0));
    tl_int("test cc_wk stop twice is refused", -1, cc_wk_stop(b, 0));
    tl_int("test cc_wk send to a stopped slot is refused", -1, cc_wk_send(b, (const uint8_t *)&n, 4));
    tl_int("test cc_wk recv from a stopped slot is refused", -1, cc_wk_recv(b, one, 4));

    /* graceful stop: end of input ends an idle worker */
    tl_int("test cc_wk graceful stop", 0, cc_wk_stop(a, 0));

    /* a busy worker is stopped by force, and a later worker does not hold earlier pipes */
    int32_t c = spawn_server();
    int32_t d = spawn_server();
    n = -2;
    cc_wk_send(c, (const uint8_t *)&n, 4);
    time_t t0 = time(NULL);
    tl_int("test cc_wk forced stop of a busy worker", 0, cc_wk_stop(c, 1));
    tl_int("test cc_wk forced stop is prompt", 1, time(NULL) - t0 < 5);
    n = 7;
    cc_wk_send(d, (const uint8_t *)&n, 4);
    recv_all(d, one, 4);
    memcpy(&r, one, 4);
    tl_int("test cc_wk worker after a stop still answers", 14, r);
    tl_int("test cc_wk stop d", 0, cc_wk_stop(d, 0));

    /* no stray children */
    int status;
    tl_int("test cc_wk no child is left", -1, waitpid(-1, &status, WNOHANG));

    /* the slot table is finite */
    int32_t ids[16];
    int32_t made = 0;
    int32_t refused = 0;
    for (int i = 0; i < 16; i++) {
        ids[i] = spawn_server();
        if (ids[i] > 0) {
            made++;
        } else {
            refused++;
        }
    }
    tl_int("test cc_wk table is finite", 1, made > 0 && refused > 0 && made + refused == 16);
    for (int i = 0; i < 16; i++) {
        if (ids[i] > 0) {
            cc_wk_stop(ids[i], 1);
        }
    }
    /* resource failures: no descriptor for the first pipe, none for the second, no process */
    struct rlimit nofile;
    struct rlimit nproc;
    getrlimit(RLIMIT_NOFILE, &nofile);
    getrlimit(RLIMIT_NPROC, &nproc);
    int spare = dup(0);
    close(spare);
    struct rlimit lim = nofile;
    lim.rlim_cur = (rlim_t)spare + 1;
    setrlimit(RLIMIT_NOFILE, &lim);
    int32_t f1 = cc_wk_spawn();
    lim.rlim_cur = (rlim_t)spare + 2;
    setrlimit(RLIMIT_NOFILE, &lim);
    int32_t f2 = cc_wk_spawn();
    setrlimit(RLIMIT_NOFILE, &nofile);
    /* no process: lowering the process limit cannot be undone by a user, so a helper process does it and reports by exit status */
    pid_t helper = fork();
    if (helper == 0) {
        struct rlimit one_proc = nproc;
        one_proc.rlim_cur = 1;
        setrlimit(RLIMIT_NPROC, &one_proc);
        exit(cc_wk_spawn() == -1 ? 0 : 1);
    }
    int helper_status = -1;
    waitpid(helper, &helper_status, 0);
    int32_t f3 = WIFEXITED(helper_status) && WEXITSTATUS(helper_status) == 0 ? -1 : 0;
    tl_int("test cc_wk no descriptor for the first pipe", -1, f1);
    tl_int("test cc_wk no descriptor for the second pipe", -1, f2);
    tl_int("test cc_wk no process", -1, f3);
    int32_t again = spawn_server();
    tl_int("test cc_wk spawn works again after the failures", 1, again > 0);
    cc_wk_stop(again, 0);

    /* a worker whose descriptors are gone fails its reads and writes */
    int32_t e = cc_wk_spawn();
    if (e == 0) {
        for (int fd = 3; fd < 64; fd++) {
            close(fd);
        }
        uint8_t x[4] = {0, 0, 0, 0};
        int32_t rr = cc_wk_child_read(x, 4);
        int32_t ww = cc_wk_child_write(x, 4);
        cc_wk_child_exit();
        (void)rr;
        (void)ww;
    }
    cc_wk_stop(e, 0);
    tl_int("test cc_wk child read without a worker fails", -1, cc_wk_child_read(one, 4));
    tl_int("test cc_wk child write without a worker fails", -1, cc_wk_child_write(one, 4));
    return 0;
}
