/* Implementation test of shim/src/cc_zlib.c: the CC_SMALL retry protocol of contracts/shim-abi.md §5
 * (the caller enlarges the output buffer and retries) for deflate and inflate in every mode, an empty
 * input, and an inflate input that ends before the compressed stream does (CC_BADDATA). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ccshim.h"
#include "testlib.h"

#define SIZE 100000

typedef int32_t (*codec)(int32_t, const uint8_t *, int32_t, uint8_t *, int32_t, int32_t *);

/* Calls `f`, doubling the output buffer from 16 bytes while it returns CC_SMALL. Returns the final
 * code; *out and *length hold the result and *retries counts the CC_SMALL answers. */
static int32_t with_retries(codec f, int32_t mode, const uint8_t *in, int32_t inlen, uint8_t **out, int32_t *length, int *retries) {
    int32_t cap = 16;
    int32_t rc;
    *retries = 0;
    *out = malloc((size_t)cap);
    while ((rc = f(mode, in, inlen, *out, cap, length)) == CC_SMALL) {
        cap *= 2;
        *out = realloc(*out, (size_t)cap);
        ++*retries;
    }
    return rc;
}

int main(void) {
    static const char *names[] = {"CC_ZLIB", "CC_GZIP", "CC_RAW"};
    uint8_t *input = malloc(SIZE);
    for (int i = 0; i < SIZE; i++) input[i] = (uint8_t)((i * 31) ^ (i >> 7));
    char name[128];
    for (int32_t mode = CC_ZLIB; mode <= CC_RAW; mode++) {
        uint8_t *packed, *plain;
        int32_t packed_length, plain_length;
        int retries;
        int32_t rc = with_retries(cc_deflate, mode, input, SIZE, &packed, &packed_length, &retries);
        snprintf(name, sizeof name, "test cc_deflate %s retried after CC_SMALL succeeds", names[mode]);
        tl_int(name, 1, rc == 0 && retries > 0);
        rc = with_retries(cc_inflate, mode, packed, packed_length, &plain, &plain_length, &retries);
        snprintf(name, sizeof name, "test cc_inflate %s retried after CC_SMALL succeeds", names[mode]);
        tl_int(name, 1, rc == 0 && retries > 0);
        snprintf(name, sizeof name, "test cc_inflate %s retried output equals the input", names[mode]);
        tl_int(name, 1, plain_length == SIZE && memcmp(plain, input, SIZE) == 0);
        rc = cc_inflate(mode, packed, packed_length / 2, plain, SIZE, &plain_length);
        snprintf(name, sizeof name, "test cc_inflate %s input ending before the stream end returns CC_BADDATA", names[mode]);
        tl_int(name, CC_BADDATA, rc);
        free(packed);
        free(plain);
    }
    uint8_t packed[64], plain[8];
    int32_t packed_length, plain_length;
    tl_int("test cc_deflate of empty input returns 0", 0, cc_deflate(CC_ZLIB, input, 0, packed, sizeof packed, &packed_length));
    tl_int("test cc_inflate of a compressed empty input returns 0", 0, cc_inflate(CC_ZLIB, packed, packed_length, plain, sizeof plain, &plain_length));
    tl_int("test cc_inflate of a compressed empty input yields 0 bytes", 0, plain_length);
    free(input);
    return 0;
}
