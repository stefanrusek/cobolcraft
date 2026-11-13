/* cc_wk (contracts/shim-abi.md section 15): worker processes for work that must not stall the caller's loop. cc_wk_spawn forks
 * the calling process; the child is a copy of the caller's state that shares no memory with it and talks to it over two pipes
 * (requests down, responses up). The parent reads without blocking and writes requests; the child reads and writes blocking and
 * ends with cc_wk_child_exit. No game logic here: the bytes are the caller's. A child closes every pipe end it inherited from
 * other slots, so a worker sees end of input when the parent ends, and ends with `_exit` (the parent's exit handlers, window and
 * GPU state are not the child's to run). A write to a closed pipe returns an error instead of raising SIGPIPE. */
#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#include "ccshim.h"

#define WK_SLOTS 8

typedef struct {
    pid_t pid; /* 0 = free */
    int to_child;
    int from_child;
} wk_slot;

static wk_slot slots[WK_SLOTS];
static int child_in = -1;
static int child_out = -1;

static wk_slot *slot_of(int32_t id) {
    if (id < 1 || id > WK_SLOTS || slots[id - 1].pid == 0) {
        return NULL;
    }
    return &slots[id - 1];
}

int32_t cc_wk_spawn(void) {
    int32_t id = 0;
    for (int i = 0; i < WK_SLOTS && id == 0; i++) {
        if (slots[i].pid == 0) {
            id = i + 1;
        }
    }
    if (id == 0) {
        return -1;
    }
    int down[2];
    int up[2];
    if (pipe(down) != 0) {
        return -1;
    }
    if (pipe(up) != 0) {
        close(down[0]);
        close(down[1]);
        return -1;
    }
    signal(SIGPIPE, SIG_IGN);
    pid_t pid = fork();
    if (pid < 0) {
        close(down[0]);
        close(down[1]);
        close(up[0]);
        close(up[1]);
        return -1;
    }
    if (pid == 0) {
        for (int i = 0; i < WK_SLOTS; i++) {
            if (slots[i].pid != 0) {
                close(slots[i].to_child);
                close(slots[i].from_child);
                slots[i].pid = 0;
            }
        }
        close(down[1]);
        close(up[0]);
        child_in = down[0];
        child_out = up[1];
        return 0;
    }
    close(down[0]);
    close(up[1]);
    fcntl(up[0], F_SETFL, fcntl(up[0], F_GETFL) | O_NONBLOCK);
    slots[id - 1].pid = pid;
    slots[id - 1].to_child = down[1];
    slots[id - 1].from_child = up[0];
    return id;
}

int32_t cc_wk_send(int32_t id, const uint8_t *buf, int32_t n) {
    wk_slot *s = slot_of(id);
    if (s == NULL) {
        return -1;
    }
    ssize_t w = write(s->to_child, buf, (size_t)n);
    return w == n ? n : -1;
}

int32_t cc_wk_recv(int32_t id, uint8_t *buf, int32_t n) {
    wk_slot *s = slot_of(id);
    if (s == NULL) {
        return -1;
    }
    ssize_t r = read(s->from_child, buf, (size_t)n);
    if (r > 0) {
        return (int32_t)r;
    }
    if (r < 0 && (errno == EAGAIN || errno == EINTR)) {
        return 0;
    }
    return -1;
}

int32_t cc_wk_stop(int32_t id, int32_t force) {
    wk_slot *s = slot_of(id);
    if (s == NULL) {
        return -1;
    }
    if (force != 0) {
        kill(s->pid, SIGKILL);
    }
    close(s->to_child);
    close(s->from_child);
    int status;
    while (waitpid(s->pid, &status, 0) < 0 && errno == EINTR) {
    }
    s->pid = 0;
    return 0;
}

int32_t cc_wk_child_read(uint8_t *buf, int32_t n) {
    if (child_in < 0) {
        return -1;
    }
    int32_t got = 0;
    while (got < n) {
        ssize_t r = read(child_in, buf + got, (size_t)(n - got));
        if (r > 0) {
            got += (int32_t)r;
        } else if (r == 0) {
            return 0;
        } else if (errno != EINTR) {
            return -1;
        }
    }
    return got;
}

int32_t cc_wk_child_write(const uint8_t *buf, int32_t n) {
    if (child_out < 0) {
        return -1;
    }
    int32_t put = 0;
    while (put < n) {
        ssize_t w = write(child_out, buf + put, (size_t)(n - put));
        if (w > 0) {
            put += (int32_t)w;
        } else if (w < 0 && errno != EINTR) {
            return -1;
        }
    }
    return put;
}

void cc_wk_child_exit(void) {
    /* Present when the program is built with --coverage: _exit skips the dump of the child's counters. */
    void (*dump)(void) = (void (*)(void))dlsym(RTLD_DEFAULT, "__gcov_dump");
    if (dump != NULL) {
        dump();
    }
    _exit(0);
}
