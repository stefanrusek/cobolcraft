/* Test fixture of the shim's TLS tests (test infrastructure, excluded from coverage): runs
 * tools/testsrv/testsrv.py over HTTPS on a free loopback port and trusts its throwaway test CA through
 * the standard OpenSSL variable SSL_CERT_FILE (research R10), so no shipped code exists only for
 * tests. Test programs run from the repository root (tools/runtests.py), so the paths are relative to
 * it. The test CA is created with tools/testsrv/make-ca.sh when build/testsrv/ca.pem is absent. */
#ifndef COBOLCRAFT_TLS_TESTSRV_H
#define COBOLCRAFT_TLS_TESTSRV_H

#include <fcntl.h>
#include <signal.h>
#include <spawn.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>

extern char **environ;

#define TESTSRV_CA "build/testsrv/ca.pem"

/* Sets SSL_CERT_FILE to the test CA, creating the CA first when it is absent. */
static inline void testsrv_trust_ca(void) {
    struct stat info;
    if (stat(TESTSRV_CA, &info) != 0 && system("sh tools/testsrv/make-ca.sh >/dev/null") != 0) {
        fprintf(stderr, "tls_testsrv: make-ca.sh failed\n");
        exit(1);
    }
    char path[1024];
    if (realpath(TESTSRV_CA, path) == NULL) {
        fprintf(stderr, "tls_testsrv: %s missing\n", TESTSRV_CA);
        exit(1);
    }
    setenv("SSL_CERT_FILE", path, 1);
}

/* Starts testsrv.py serving `dir` over HTTPS, waits until it listens and returns its port; *pid_out
 * is the server process for testsrv_stop. Exits the test program when the server does not start. */
static inline int testsrv_start(const char *dir, pid_t *pid_out) {
    testsrv_trust_ca();
    char ready[64];
    snprintf(ready, sizeof ready, "build/testsrv/ready-%d", (int)getpid());
    remove(ready);
    char *argv[] = {"python3", "tools/testsrv/testsrv.py", "--dir", (char *)dir, "--https-port", "0",
                    "--ready-file", ready, NULL};
    /* Its "testsrv: ..." line would mix with the test program's TEST lines. */
    posix_spawn_file_actions_t actions;
    posix_spawn_file_actions_init(&actions);
    posix_spawn_file_actions_addopen(&actions, STDOUT_FILENO, "/dev/null", O_WRONLY, 0);
    int failed = posix_spawnp(pid_out, "python3", &actions, NULL, argv, environ);
    posix_spawn_file_actions_destroy(&actions);
    if (failed != 0) {
        fprintf(stderr, "tls_testsrv: cannot start testsrv.py\n");
        exit(1);
    }
    int http = 0, https = 0;
    for (int i = 0; i < 200 && https == 0; i++) {
        FILE *f = fopen(ready, "r");
        if (f != NULL) {
            if (fscanf(f, "http=%d https=%d", &http, &https) != 2) https = 0;
            fclose(f);
        }
        if (https == 0) usleep(50000);
    }
    remove(ready);
    if (https == 0) {
        fprintf(stderr, "tls_testsrv: testsrv.py did not start\n");
        kill(*pid_out, SIGTERM);
        exit(1);
    }
    return https;
}

static inline void testsrv_stop(pid_t pid) {
    kill(pid, SIGTERM);
    waitpid(pid, NULL, 0);
}

#endif
