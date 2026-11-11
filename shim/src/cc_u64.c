/* cc_u64: unsigned 64-bit wrap-around arithmetic by reference (contract/include/ccshim.h section 13).
 * GnuCOBOL has no unsigned 64-bit wrap arithmetic (an ABI-level gap, constitution Principle I): COMPUTE would run
 * through decimals. Arithmetic only, no game logic. A shift or rotate count is 1 to 63 (a count outside gives the
 * value unchanged for rotl and 0 for shl and shr when 64 or more). The result may alias an operand. */
#include <stdint.h>

#include "ccshim.h"

void cc_u64_add(const uint64_t *a, const uint64_t *b, uint64_t *r) { *r = *a + *b; }
void cc_u64_mul(const uint64_t *a, const uint64_t *b, uint64_t *r) { *r = *a * *b; }
void cc_u64_shl(const uint64_t *a, const int32_t *n, uint64_t *r) { *r = (uint32_t)*n >= 64 ? 0 : *a << *n; }
void cc_u64_shr(const uint64_t *a, const int32_t *n, uint64_t *r) { *r = (uint32_t)*n >= 64 ? 0 : *a >> *n; }
void cc_u64_rotl(const uint64_t *a, const int32_t *n, uint64_t *r) {
    uint32_t k = (uint32_t)*n & 63;
    *r = k == 0 ? *a : (*a << k) | (*a >> (64 - k));
}
