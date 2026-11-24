/* Implementation test of cc_open_path (contracts/shim-delta.md): an opener that exists is started and the
 * call returns 0 at once, a missing opener returns CC_NOTFOUND, and the call does not wait for the child
 * (the opener /bin/sleep given "3" runs for 3 s; the call must return in well under one). */
#include <errno.h>
#include <stdio.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#include "ccshim.h"
#include "testlib.h"

static double now(void) {
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return (double)t.tv_sec + (double)t.tv_nsec / 1e9;
}

int main(void) {
    char dir[] = "/tmp";
    tl_int("test cc_open_path of an existing opener returns 0", 0, cc_open_path("/usr/bin/true", dir));
    tl_int("test cc_open_path of a missing opener returns CC_NOTFOUND", CC_NOTFOUND,
           cc_open_path("/nonexistent/opener", dir));
    usleep(300000);
    errno = 0;
    pid_t left = waitpid(-1, NULL, WNOHANG);
    tl_int("test cc_open_path leaves no zombie child (waitpid fails)", -1, (int)left);
    tl_int("test cc_open_path leaves no zombie child (ECHILD)", ECHILD, errno);
    double start = now();
    int32_t rc = cc_open_path("/bin/sleep", "3");
    double took = now() - start;
    tl_int("test cc_open_path of a slow opener returns 0", 0, rc);
    tl_int("test cc_open_path does not wait for the child", 1, took < 1.0);
    return 0;
}
