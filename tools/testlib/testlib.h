/* C test library (contracts/test-harness.md §3, research R9). Test infrastructure, excluded from
 * coverage. Every call prints exactly one line:
 *   TEST <case> PASS
 *   TEST <case> FAIL expected=<x> observed=<y>
 * Byte buffers are printed as lowercase hex without separators. */
#ifndef COBOLCRAFT_TESTLIB_H
#define COBOLCRAFT_TESTLIB_H

#include <stddef.h>
#include <stdio.h>
#include <string.h>

static inline void tl_int(const char *name, long long expected, long long observed) {
    if (expected == observed) {
        printf("TEST %s PASS\n", name);
    } else {
        printf("TEST %s FAIL expected=%lld observed=%lld\n", name, expected, observed);
    }
    fflush(stdout);
}

static inline void tl_str(const char *name, const char *expected, const char *observed) {
    if (strcmp(expected, observed) == 0) {
        printf("TEST %s PASS\n", name);
    } else {
        printf("TEST %s FAIL expected=%s observed=%s\n", name, expected, observed);
    }
    fflush(stdout);
}

static inline void tl_print_hex(const unsigned char *bytes, size_t length) {
    for (size_t i = 0; i < length; i++) {
        printf("%02x", bytes[i]);
    }
}

static inline void tl_bytes(const char *name, const void *expected, size_t expected_length,
                            const void *observed, size_t observed_length) {
    if (expected_length == observed_length &&
        memcmp(expected, observed, expected_length) == 0) {
        printf("TEST %s PASS\n", name);
    } else {
        printf("TEST %s FAIL expected=", name);
        tl_print_hex(expected, expected_length);
        printf(" observed=");
        tl_print_hex(observed, observed_length);
        printf("\n");
    }
    fflush(stdout);
}

#endif
