/* cc_open_path (contracts/shim-delta.md): starts an opener with a path as its only argument. Glue only:
 * posix_spawn and an argument vector cannot be expressed from COBOL. The caller does not wait: a
 * detached thread reaps that one child, so no zombie remains and no process-wide SIGCHLD disposition
 * (which would break CALL "SYSTEM" status) is changed. */
#include <pthread.h>
#include <spawn.h>
#include <stdint.h>
#include <sys/wait.h>

#include "ccshim.h"

extern char **environ;

static void *reap(void *arg) {
    int status;
    waitpid((pid_t)(intptr_t)arg, &status, 0);
    return NULL;
}

int32_t cc_open_path(const char *opener, const char *path) {
    char *argv[3] = {(char *)opener, (char *)path, NULL};
    pid_t pid;
    if (posix_spawn(&pid, opener, NULL, NULL, argv, environ) != 0) return CC_NOTFOUND;
    pthread_t thread;
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    int created = pthread_create(&thread, &attr, reap, (void *)(intptr_t)pid);
    pthread_attr_destroy(&attr);
    if (created != 0) waitpid(pid, NULL, 0); /* cannot start a reaper: reap here, never leave a zombie */
    return 0;
}
