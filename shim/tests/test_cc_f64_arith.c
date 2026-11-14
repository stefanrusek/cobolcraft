/* Implementation test of shim/src/cc_f64.c: add, sub, mul, div, floor and sqrt over the IEEE vectors of
 * f64_vectors.txt (gen_f64_vectors.py, computed independently of the C code), plus 0.1 + 0.2, which
 * gives the bytes 343333333333D33F (specs/002-client-polish/research.md R5). */
#include <string.h>

#include "f64_vectors.h"

int main(void) {
    double a = 0.1, b = 0.2, r = 0;
    cc_f64_add(&a, &b, &r);
    uint8_t bytes[8];
    memcpy(bytes, &r, sizeof bytes);
    const uint8_t want[8] = {0x34, 0x33, 0x33, 0x33, 0x33, 0x33, 0xD3, 0x3F};
    tl_bytes("test cc_f64_add 0.1 + 0.2 bytes", want, sizeof want, bytes, sizeof bytes);
    f64_run_group(G_ARITH);
    return 0;
}
