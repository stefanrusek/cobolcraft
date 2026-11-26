/* cc_wk (contracts/shim-abi.md section 15): worker processes for work that must not stall the caller's loop. cc_wk_spawn forks
 * the calling process; the child is a copy of the caller's state that shares no memory with it and talks to it over two pipes
 * (requests down, responses up). The parent reads without blocking and writes requests; the child reads and writes blocking and
 * ends with cc_wk_child_exit. No game logic here: the bytes are the caller's. A child closes every pipe end it inherited from
 * other slots, so a worker sees end of input when the parent ends, and ends with `_exit` (the parent's exit handlers, window and
 * GPU state are not the child's to run). A write to a closed pipe returns an error instead of raising SIGPIPE. */
#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <mach-o/dyld.h>
#include <limits.h>
#include <signal.h>
#include <spawn.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#include "ccshim.h"

#define WK_SLOTS 8
#define WK_MAX_DUMPS 32

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
    /* Present when the program is built with --coverage: _exit skips the dump of the child's counters. Every loaded image
     * built that way (the program, and each shared library of a test build) has a dump of its own, and a lookup in an image
     * also finds the dumps of the images it links, so each distinct one is called once. The dump of the image this function
     * is in comes last: nothing it counts after its own dump is kept. */
    void (*seen[WK_MAX_DUMPS])(void);
    Dl_info self;
    void *home = dladdr((void *)cc_wk_child_exit, &self) != 0 ? dlopen(self.dli_fname, RTLD_NOLOAD | RTLD_LAZY) : NULL;
    void (*own)(void) = home == NULL ? NULL : (void (*)(void))dlsym(home, "__gcov_dump");
    int count = 1;
    seen[0] = own;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        void *image = dlopen(_dyld_get_image_name(i), RTLD_NOLOAD | RTLD_LAZY);
        void (*dump)(void) = image == NULL ? NULL : (void (*)(void))dlsym(image, "__gcov_dump");
        int fresh = dump != NULL && count < WK_MAX_DUMPS;
        for (int k = 0; k < count; k++) {
            fresh = fresh && seen[k] != dump;
        }
        if (fresh) {
            seen[count++] = dump;
            dump();
        }
    }
    if (own != NULL) {
        own();
    }
    _exit(0);
}

int32_t cc_wk_cpus(void) {
    long n = sysconf(_SC_NPROCESSORS_ONLN);
    return n < 1 ? 1 : (int32_t)n;
}

/* Child programs (shim-abi section 15, cc_wk_proc_*): the single-player host starts the server program as a child with a pipe on its
 * standard input (the parent's control lines; end of input is the parent's death) and one on its standard output (the child's
 * lines). Glue only: posix_spawn and an argument vector cannot be written in COBOL. The descriptors of the parent (window, GPU,
 * sockets, the worker pipes) are not inherited (POSIX_SPAWN_CLOEXEC_DEFAULT); standard error is. */
#define PROC_SLOTS 4
#define PROC_ARGS 16

typedef struct {
    pid_t pid; /* 0 = free */
    int to_child;
    int from_child;
    int ended;
    int status;
} proc_slot;

static proc_slot procs[PROC_SLOTS];
extern char **environ;

static proc_slot *proc_of(int32_t slot) {
    if (slot < 1 || slot > PROC_SLOTS || procs[slot - 1].pid == 0) {
        return NULL;
    }
    return &procs[slot - 1];
}

int32_t cc_wk_proc_spawn(const char *exe, const char *args, int32_t *slot_out) {
    int32_t id = 0;
    for (int i = 0; i < PROC_SLOTS && id == 0; i++) {
        if (procs[i].pid == 0) {
            id = i + 1;
        }
    }
    int down[2];
    int up[2];
    if (id == 0 || pipe(down) != 0) {
        return CC_NOTFOUND;
    }
    if (pipe(up) != 0) {
        close(down[0]);
        close(down[1]);
        return CC_NOTFOUND;
    }
    char text[1024];
    strncpy(text, args, sizeof text - 1);
    text[sizeof text - 1] = 0;
    char *argv[PROC_ARGS + 2];
    int argc = 0;
    argv[argc++] = (char *)exe;
    char *save = NULL;
    for (char *t = strtok_r(text, " ", &save); t != NULL && argc < PROC_ARGS + 1; t = strtok_r(NULL, " ", &save)) {
        argv[argc++] = t;
    }
    argv[argc] = NULL;
    posix_spawn_file_actions_t actions;
    posix_spawnattr_t attr;
    posix_spawn_file_actions_init(&actions);
    posix_spawnattr_init(&attr);
    posix_spawnattr_setflags(&attr, POSIX_SPAWN_CLOEXEC_DEFAULT);
    posix_spawn_file_actions_adddup2(&actions, down[0], 0);
    posix_spawn_file_actions_adddup2(&actions, up[1], 1);
    posix_spawn_file_actions_addinherit_np(&actions, 2);
    signal(SIGPIPE, SIG_IGN);
    pid_t pid;
    int rc = posix_spawn(&pid, exe, &actions, &attr, argv, environ);
    posix_spawn_file_actions_destroy(&actions);
    posix_spawnattr_destroy(&attr);
    close(down[0]);
    close(up[1]);
    if (rc != 0) {
        close(down[1]);
        close(up[0]);
        return CC_NOTFOUND;
    }
    fcntl(up[0], F_SETFL, fcntl(up[0], F_GETFL) | O_NONBLOCK);
    procs[id - 1] = (proc_slot){pid, down[1], up[0], 0, 0};
    *slot_out = id;
    return 0;
}

int32_t cc_wk_proc_write(int32_t slot, const uint8_t *buf, int32_t n) {
    proc_slot *p = proc_of(slot);
    if (p == NULL || p->to_child < 0) {
        return -1;
    }
    int32_t put = 0;
    while (put < n) {
        ssize_t w = write(p->to_child, buf + put, (size_t)(n - put));
        if (w > 0) {
            put += (int32_t)w;
        } else if (w < 0 && errno != EINTR) {
            return -1;
        }
    }
    return put;
}

int32_t cc_wk_proc_read(int32_t slot, uint8_t *buf, int32_t cap, int32_t *got_out) {
    proc_slot *p = proc_of(slot);
    if (p == NULL) {
        return CC_CLOSED;
    }
    ssize_t r = read(p->from_child, buf, (size_t)cap);
    if (r > 0) {
        *got_out = (int32_t)r;
        return 0;
    }
    if (r < 0 && (errno == EAGAIN || errno == EINTR)) {
        return CC_AGAIN;
    }
    return CC_CLOSED;
}

void cc_wk_proc_close_input(int32_t slot) {
    proc_slot *p = proc_of(slot);
    if (p != NULL && p->to_child >= 0) {
        close(p->to_child);
        p->to_child = -1;
    }
}

int32_t cc_wk_proc_wait(int32_t slot, int32_t timeout_ms, int32_t *status_out) {
    proc_slot *p = proc_of(slot);
    if (p == NULL) {
        return -1;
    }
    for (int32_t waited = 0; !p->ended; waited += 2) {
        int status;
        pid_t r = waitpid(p->pid, &status, WNOHANG);
        if (r == p->pid) {
            p->ended = 1;
            p->status = WIFEXITED(status) ? WEXITSTATUS(status) : 128 + WTERMSIG(status);
        } else if (waited >= timeout_ms) {
            return CC_AGAIN;
        } else {
            usleep(2000);
        }
    }
    *status_out = p->status;
    return 0;
}

int32_t cc_wk_proc_stop(int32_t slot) {
    proc_slot *p = proc_of(slot);
    if (p == NULL) {
        return -1;
    }
    if (!p->ended) {
        kill(p->pid, SIGKILL);
        int status;
        while (waitpid(p->pid, &status, 0) < 0 && errno == EINTR) {
        }
    }
    cc_wk_proc_close_input(slot);
    close(p->from_child);
    p->pid = 0;
    return 0;
}

int32_t cc_wk_self_dir(uint8_t *buf, int32_t cap) {
    char raw[PATH_MAX];
    char real[PATH_MAX];
    uint32_t size = sizeof raw;
    int32_t n = -1;
    if (_NSGetExecutablePath(raw, &size) == 0 && realpath(raw, real) != NULL) {
        char *slash = strrchr(real, '/');
        int32_t length = slash == NULL ? 0 : (int32_t)(slash - real);
        if (length <= cap) {
            memcpy(buf, real, (size_t)length);
            n = length;
        }
    }
    return n;
}
