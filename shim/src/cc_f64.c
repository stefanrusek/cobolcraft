/* cc_f64: IEEE double arithmetic by reference (contract/include/ccshim.h section 10, specs/002-client-polish/
 * contracts/shim-delta.md, function set of docs/protocol/10-world-generation-terrain.md section 16).
 * COBOL cannot receive a C double return value, so operands and results travel by reference and every
 * function returns nothing. The rules (rounding, saturation, NaN handling) are those of section 16.2 and
 * 16.5; the file holds arithmetic only, no game logic (constitution Principle I). No contraction and no
 * fast-math: add and mul are fma(a, 1, b) and fma(a, b, -0), the rounded sum and product (the addend -0.0 keeps the sign of a zero product). */
#include <math.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "ccshim.h"

#pragma STDC FP_CONTRACT OFF

void cc_f64_add(const double *a, const double *b, double *r) { *r = fma(*a, 1.0, *b); }
void cc_f64_sub(const double *a, const double *b, double *r) { *r = fma(*b, -1.0, *a); }
void cc_f64_mul(const double *a, const double *b, double *r) { *r = fma(*a, *b, -0.0); }
void cc_f64_div(const double *a, const double *b, double *r) { *r = *a / *b; }
void cc_f64_floor(const double *a, double *r) { *r = floor(*a); }
void cc_f64_ceil(const double *a, double *r) { *r = ceil(*a); }
void cc_f64_sqrt(const double *a, double *r) { *r = sqrt(*a); }
void cc_f64_from_text(const char *text, double *r) { *r = strtod(text, NULL); }

void cc_f64_f32_round(const double *a, double *r) { *r = (double)(float)*a; }

/* d2i and d2l: truncate toward zero, saturate, NaN gives 0. The limits are exact powers of two. */
static int32_t to_i32(double x) {
    return x != x ? 0 : x >= 2147483648.0 ? INT32_MAX : x <= -2147483648.0 ? INT32_MIN : (int32_t)x;
}
static int64_t to_i64(double x) {
    return x != x ? 0 : x >= 9223372036854775808.0 ? INT64_MAX : x <= -9223372036854775808.0 ? INT64_MIN : (int64_t)x;
}
void cc_f64_to_i32(const double *a, int32_t *r) { *r = to_i32(*a); }
void cc_f64_to_i64(const double *a, int64_t *r) { *r = to_i64(*a); }
void cc_f64_i32_to_f32(const int32_t *a, double *r) { *r = (double)(float)*a; }

/* Math.round: exact floor(x + 1/2); x - floor(x) is exact, so the test is exact. */
static double round_half_up(double x) {
    double f = floor(x);
    return x - f >= 0.5 ? f + 1.0 : f;
}
void cc_f64_round_f32(const double *a, int32_t *r) { *r = to_i32(round_half_up(*a)); }
void cc_f64_round_f64(const double *a, int64_t *r) { *r = to_i64(round_half_up(*a)); }

void cc_f64_fmod(const double *a, const double *b, double *r) { *r = fmod(*a, *b); }

/* Math.min and Math.max: NaN propagates and -0.0 is smaller than 0.0. */
static double min_j(double a, double b) {
    return a != a || b != b ? NAN : a == b ? (signbit(a) ? a : b) : a < b ? a : b;
}
static double max_j(double a, double b) {
    return a != a || b != b ? NAN : a == b ? (signbit(a) ? b : a) : a > b ? a : b;
}
void cc_f64_min_j(const double *a, const double *b, double *r) { *r = min_j(*a, *b); }
void cc_f64_max_j(const double *a, const double *b, double *r) { *r = max_j(*a, *b); }

/* Mth.clamp: v < lo gives lo, otherwise min(v, hi); the float form is the same on exact floats. */
void cc_f64_clamp_f32(const double *v, const double *lo, const double *hi, double *r) { *r = *v < *lo ? *lo : min_j(*v, *hi); }
void cc_f64_clamp_f64(const double *v, const double *lo, const double *hi, double *r) { *r = *v < *lo ? *lo : min_j(*v, *hi); }

void cc_f64_signum(const double *a, double *r) { *r = *a > 0 ? 1.0 : *a < 0 ? -1.0 : *a; }
void cc_f64_nextdown(const double *a, double *r) { *r = nextafter(*a, -INFINITY); }
void cc_f64_next_up(const double *a, double *r) { *r = nextafter(*a, INFINITY); }
void cc_f64_abs_f32(const double *a, double *r) { *r = fabs(*a); }
void cc_f64_abs_f64(const double *a, double *r) { *r = fabs(*a); }
void cc_f64_log1p(const double *a, double *r) { *r = log1p(*a); }
void cc_f64_to_radians(const double *a, double *r) { *r = *a * 0.017453292519943295; }
void cc_f64_copysign(const double *a, const double *b, double *r) { *r = copysign(*a, *b); }
void cc_f64_pow(const double *a, const double *b, double *r) { *r = pow(*a, *b); }
void cc_f64_log(const double *a, double *r) { *r = log(*a); }
void cc_f64_sin(const double *a, double *r) { *r = sin(*a); }
void cc_f64_cos(const double *a, double *r) { *r = cos(*a); }
void cc_f64_asin(const double *a, double *r) { *r = asin(*a); }
void cc_f64_acos(const double *a, double *r) { *r = acos(*a); }
void cc_f64_atan2_lib(const double *y, const double *x, double *r) { *r = atan2(*y, *x); }

void cc_f64_f64_bits(const double *a, int64_t *r) { memcpy(r, a, sizeof *r); }
void cc_f64_f64_from_bits(const int64_t *a, double *r) { memcpy(r, a, sizeof *r); }
void cc_f64_inv_sqrt(const double *a, double *r) { *r = 1.0 / sqrt(*a); }

/* 10 section 16.3 and 16.4: the tables, built on first use. */
static float sin_table[65536];
static double asin_table[257];
static double cos_table[257];
static int tables_ready;

static void tables_build(void) {
    if (tables_ready) return;
    for (int i = 0; i < 65536; i++) sin_table[i] = (float)sin((double)i / 10430.378350470453);
    for (int i = 0; i <= 256; i++) {
        asin_table[i] = asin((double)i / 256.0);
        cos_table[i] = cos(asin_table[i]);
    }
    tables_ready = 1;
}

/* Mth.sin(D) and Mth.cos(D): table lookups; the multiply and the add are separate double operations. */
void cc_f64_sin_tab(const double *a, double *r) {
    tables_build();
    double scaled = *a * 10430.378350470453;
    *r = (double)sin_table[(uint64_t)to_i64(scaled) & 65535];
}
void cc_f64_cos_tab(const double *a, double *r) {
    tables_build();
    double scaled = *a * 10430.378350470453;
    double shifted = scaled + 16384.0;
    *r = (double)sin_table[(uint64_t)to_i64(shifted) & 65535];
}

/* Mth.fastInvSqrt: one Newton step, evaluated as 1.5 - ((h * y) * y). */
static double fast_inv_sqrt(double x) {
    double h = 0.5 * x;
    int64_t bits;
    memcpy(&bits, &x, sizeof bits);
    bits = 6910469410427058090LL - (bits >> 1);
    double y;
    memcpy(&y, &bits, sizeof y);
    double hy = h * y;
    double hyy = hy * y;
    return y * (1.5 - hyy);
}
void cc_f64_fast_inv_sqrt(const double *a, double *r) { *r = fast_inv_sqrt(*a); }

/* Mth.atan2(y, x): the table routine of 10 section 16.4. */
void cc_f64_atan2_mth(const double *py, const double *px, double *r) {
    tables_build();
    double y = *py, x = *px;
    double d = x * x + y * y;
    if (d != d) {
        *r = NAN;
        return;
    }
    int ny = y < 0, nx = x < 0;
    if (ny) y = -y;
    if (nx) x = -x;
    int sw = y > x;
    if (sw) {
        double t = x;
        x = y;
        y = t;
    }
    double inv = fast_inv_sqrt(d);
    x = x * inv;
    y = y * inv;
    if (x != x || y != y) {
        *r = NAN;
        return;
    }
    double t = 17592186044416.0 + y; /* 2^44: the low bits of t hold y * 256 rounded */
    int64_t tb;
    memcpy(&tb, &t, sizeof tb);
    int32_t idx = (int32_t)(uint32_t)((uint64_t)tb & 0xFFFFFFFFu);
    idx = idx < 0 ? 0 : idx > 256 ? 256 : idx;
    double b = t - 17592186044416.0;
    double e = y * cos_table[idx] - x * b;
    double p = ((6.0 + e * e) * e) * 0.16666666666666666;
    double res = asin_table[idx] + p;
    if (sw) res = 1.5707963267948966 - res;
    if (nx) res = 3.141592653589793 - res;
    if (ny) res = -res;
    *r = res;
}

/* Mth.lerp: a + t * (b - a), each step rounded (to float for the float form), no fma. */
void cc_f64_lerp_f32(const double *t, const double *a, const double *b, double *r) {
    float diff = (float)(*b - *a);
    float scaled = (float)(*t * (double)diff);
    *r = (double)(float)(*a + (double)scaled);
}
void cc_f64_lerp_f64(const double *t, const double *a, const double *b, double *r) {
    double diff = *b - *a;
    double scaled = *t * diff;
    *r = *a + scaled;
}
