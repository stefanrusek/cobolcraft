/* cc_fpfast: arithmetic on FLOAT-LONG and FLOAT-SHORT fields in IEEE double, for programs compiled with FPFAST=1
 * (tools/package.mk; FPFAST=0 leaves the programs on libcob alone, with the same COBOL source).
 *
 * cobc 3.2 compiles every arithmetic expression to calls by name: cob_decimal_set_field for each operand (or
 * cob_decimal_set_llint, cob_decimal_set_ullint for a binary integer; those two are not taken over: libcob sets the
 * scale of the decimal, which removes a tag), cob_decimal_add / sub / mul / div / pow, cob_decimal_cmp for a
 * condition, cob_decimal_align, and cob_decimal_get_field for the target. libcob loads a float operand into its decimal through a string of digits and
 * computes in decimal; that conversion is most of the cost of a float expression. With FPFAST=1 the generated C is
 * compiled with -Dcob_decimal_<name>=ccfp_decimal_<name> for these nine names, so a program's own calls come here
 * and libcob's own calls stay in libcob. This file adapts those calls only; it holds no game or protocol logic
 * (constitution Principle I).
 *
 * A decimal loaded from a finite float field is tagged (a tagged decimal is always finite, and its zero is positive): its scale is FP_TAG, a value libcob never gives a scale, and
 * the double sits in the decimal's first limb. An operation with a tagged operand is done in double when the other
 * operand is tagged too or is a decimal whose double is its correctly rounded value (magnitude below 2^53, scale 0
 * to 22: the value and the power of ten are exact doubles, so the one division rounds once). A tagged result stored
 * into a float field is stored as it is. Every other case gives the decimal back to libcob first (untag: libcob's own
 * conversion of the double) and calls libcob: a store into a field that is not a float, a division by zero (libcob
 * raises the size error), a result that is not finite, a power, an alignment, a comparison with a decimal, an operand
 * that is not finite or does not convert exactly, a FLOAT-SHORT target the result does not fit.
 *
 * A decimal that is not tagged and is stored into a float field (COMPUTE X = 0.2, FUNCTION NUMVAL of "5.2") stays
 * libcob's: libcob truncates a decimal to a double where C rounds it, so its 0.2 is one unit in the last place below
 * C's, and MOVE 0.2 and VALUE 0.2, which never come here, give that same double.
 *
 * Five intrinsic functions are taken over the same way (-Dcob_intr_<name>=ccfp_intr_<name>): FUNCTION SIN, COS and
 * SQRT of a float or an integer below 2^53 (libm's; libcob computes them in multi-precision; SQRT only of a number
 * that is not negative), FUNCTION MOD of two
 * integers, and cob_intr_binop, the call cobc emits for + - * / inside a function's arguments: two integers while the
 * result is an integer of 64 bits, or a float with a float or an integer below 2^53. An integer here is a binary field
 * of 1, 2, 4 or 8 bytes or an unsigned display field of up to 18 digits, without decimals. Every other argument goes to
 * libcob's own function. */
#include <limits.h>
#include <math.h>
#include <stdint.h>
#include <string.h>

#include "cc_fpfast.h"

#pragma STDC FP_CONTRACT OFF

#define FP_TAG (-32766) /* libcob uses -32768 (not a number) and -32767 (infinity) */

_Static_assert(sizeof(mp_limb_t) == sizeof(double), "a limb holds a double");

/* the attribute cobc gives a FLOAT-LONG field */
static const cob_field_attr DOUBLE_ATTR = {COB_TYPE_NUMERIC_DOUBLE, 34, 17, COB_FLAG_HAVE_SIGN | COB_FLAG_IS_FP, NULL};
static const double POWER_OF_TEN[23] = {1e0,  1e1,  1e2,  1e3,  1e4,  1e5,  1e6,  1e7,  1e8,  1e9,  1e10, 1e11,
                                        1e12, 1e13, 1e14, 1e15, 1e16, 1e17, 1e18, 1e19, 1e20, 1e21, 1e22};

/* The shim's C is compiled without optimisation (tools/package.mk gives clang no -O), so the helpers every operation
 * runs are always_inline, and the limb of a tagged decimal is read and written through the mpz structure: a call into
 * GMP for it (mpz_limbs_read, mpz_limbs_write, mpz_limbs_finish) cost more than the arithmetic. */
#define HOT static inline __attribute__((always_inline))

HOT int tagged(const cob_decimal *d) { return d->scale == FP_TAG; }

HOT double tag_value(const cob_decimal *d) {
    double v;
    memcpy(&v, d->value->_mp_d, sizeof v);
    return v;
}

/* A zero is kept as positive zero: libcob's decimal has no negative zero, so no arithmetic of libcob gives one. The
 * value is one limb that holds the double's bits; the size is the one mpz_limbs_finish gives (0 for the bits of +0.0). */
HOT void tag(cob_decimal *d, double v) {
    uint64_t bits;
    v += 0.0;
    memcpy(&bits, &v, sizeof bits);
    if (d->value->_mp_alloc < 1) {
        mpz_limbs_write(d->value, 1);
    }
    d->value->_mp_d[0] = (mp_limb_t)bits;
    d->value->_mp_size = bits != 0;
    d->scale = FP_TAG;
}

/* A tagged decimal becomes libcob's decimal of its double. */
static void untag(cob_decimal *d) {
    if (tagged(d)) {
        double v = tag_value(d);
        cob_field f = {sizeof v, (unsigned char *)&v, &DOUBLE_ATTR};
        d->scale = 0;
        cob_decimal_set_field(d, &f);
    }
}

/* 1 when the decimal can be an operand of a double operation; then *v is its double. */
HOT int as_double(const cob_decimal *d, double *v) {
    if (tagged(d)) {
        *v = tag_value(d);
        return 1;
    }
    if (d->scale < 0 || d->scale > 22 || d->value->_mp_size > 1 || d->value->_mp_size < -1) {
        return 0;
    }
    mp_limb_t magnitude = d->value->_mp_size == 0 ? 0 : d->value->_mp_d[0];
    if (magnitude >= (1ULL << 53)) {
        return 0;
    }
    double m = (double)magnitude;
    *v = (d->value->_mp_size < 0 ? -m : m) / POWER_OF_TEN[d->scale];
    return 1;
}

/* 1 when the operation is one for doubles: at least one operand is tagged and both have a double. */
HOT int both_double(const cob_decimal *d1, const cob_decimal *d2, double *a, double *b) {
    return (tagged(d1) || tagged(d2)) && as_double(d1, a) && as_double(d2, b);
}

#if __BYTE_ORDER__ != __ORDER_LITTLE_ENDIAN__
#error "cc_fpfast.c reads and writes binary fields as little-endian hosts lay them out"
#endif

static const int64_t POWER_OF_TEN_INT[19] = {1LL,
                                             10LL,
                                             100LL,
                                             1000LL,
                                             10000LL,
                                             100000LL,
                                             1000000LL,
                                             10000000LL,
                                             100000000LL,
                                             1000000000LL,
                                             10000000000LL,
                                             100000000000LL,
                                             1000000000000LL,
                                             10000000000000LL,
                                             100000000000000LL,
                                             1000000000000000LL,
                                             10000000000000000LL,
                                             100000000000000000LL,
                                             1000000000000000000LL};

static int integer_of(const cob_field *f, int64_t *v);
static double cut_quotient(uint64_t v, int scale);

/* libcob's cob_binary_set_int64 for a field of 1, 2, 4 or 8 bytes. */
HOT void store_binary(cob_field *f, int64_t n) {
    unsigned char bytes[8];
    memcpy(bytes, &n, sizeof bytes);
    if (COB_FIELD_BINARY_SWAP(f)) {
        for (size_t i = 0; i < f->size; i++) {
            f->data[i] = bytes[f->size - 1 - i];
        }
    } else {
        memcpy(f->data, bytes, f->size);
    }
}

/* 1 when the integer (below 2^62 in magnitude) fits the bytes of a binary field as libcob checks it: a signed one holds
 * a magnitude of up to 8 * size - 1 bits, an unsigned one only what is not negative. */
HOT int fits_bytes(int64_t n, size_t size, int has_sign) {
    int64_t magnitude = n < 0 ? -n : n;
    if (size == 8) {
        return has_sign || n >= 0;
    }
    return has_sign ? magnitude < (int64_t)(1LL << (8 * size - 1)) : (n >= 0 && magnitude < (int64_t)(1LL << (8 * size)));
}

/* A finite double stored into a binary field the way libcob stores the decimal of it: the integer part (a decimal of
 * scale 0 is cut by shift_decimal, toward zero), when the field has no decimals, the statement has no ROUNDED and the
 * integer fits the field's digits and its bytes. 1 when stored; any other store is libcob's. */
HOT int store_integer(double v, cob_field *f, const int opt) {
    if ((opt & COB_STORE_ROUND) || COB_FIELD_SCALE(f) != 0 || !(v > -4.0e18 && v < 4.0e18)) {
        return 0;
    }
    size_t size = f->size;
    int digits = COB_FIELD_DIGITS(f);
    if ((size != 1 && size != 2 && size != 4 && size != 8) || digits > 18) {
        return 0;
    }
    int64_t n = (int64_t)v;
    int64_t magnitude = n < 0 ? -n : n;
    if (magnitude >= POWER_OF_TEN_INT[digits]) {
        return 0;
    }
    if (!fits_bytes(n, size, COB_FIELD_HAVE_SIGN(f))) {
        return 0;
    }
    store_binary(f, n);
    return 1;
}

void ccfp_decimal_set_field(cob_decimal *d, cob_field *f) {
    double v = NAN;
    if (COB_FIELD_TYPE(f) == COB_TYPE_NUMERIC_DOUBLE) {
        memcpy(&v, f->data, sizeof v);
    }
    if (COB_FIELD_TYPE(f) == COB_TYPE_NUMERIC_FLOAT) {
        float s;
        memcpy(&s, f->data, sizeof s);
        v = (double)s;
    }
    if (isfinite(v)) {
        tag(d, v);
        return;
    }
    cob_decimal_set_field(d, f);
}

int ccfp_decimal_get_field(cob_decimal *d, cob_field *f, const int opt) {
    if (tagged(d)) {
        double v = tag_value(d);
        if (COB_FIELD_TYPE(f) == COB_TYPE_NUMERIC_DOUBLE) {
            memcpy(f->data, &v, sizeof v);
            return 0;
        }
        float s = (float)v;
        if (COB_FIELD_TYPE(f) == COB_TYPE_NUMERIC_FLOAT && isfinite(s)) {
            memcpy(f->data, &s, sizeof s);
            return 0;
        }
        if ((COB_FIELD_TYPE(f) == COB_TYPE_NUMERIC_BINARY || COB_FIELD_TYPE(f) == COB_TYPE_NUMERIC_COMP5) && store_integer(v, f, opt)) {
            return 0;
        }
    }
    /* A decimal that was never a float (a literal, an integer, a product of those) into a float field: libcob's double of
     * it, which is cut toward zero, for a number of up to 53 bits with up to 22 decimals. */
    if (!tagged(d) && (COB_FIELD_TYPE(f) == COB_TYPE_NUMERIC_DOUBLE || COB_FIELD_TYPE(f) == COB_TYPE_NUMERIC_FLOAT) &&
        !(opt & COB_STORE_ROUND) && d->scale >= 0 && d->scale <= 22 && d->value->_mp_size >= -1 && d->value->_mp_size <= 1) {
        mp_limb_t magnitude = d->value->_mp_size == 0 ? 0 : d->value->_mp_d[0];
        if (magnitude < (1ULL << 53)) {
            double v = magnitude == 0 ? 0.0 : d->value->_mp_size < 0 ? -cut_quotient(magnitude, d->scale) : cut_quotient(magnitude, d->scale);
            float s = (float)v; /* below 2^53 and above -2^53: finite */
            if (COB_FIELD_TYPE(f) == COB_TYPE_NUMERIC_DOUBLE) {
                memcpy(f->data, &v, sizeof v);
            } else {
                memcpy(f->data, &s, sizeof s);
            }
            return 0;
        }
    }
    untag(d);
    return cob_decimal_get_field(d, f, opt);
}

void ccfp_decimal_add(cob_decimal *d1, cob_decimal *d2) {
    double a, b;
    if (both_double(d1, d2, &a, &b) && isfinite(a + b)) {
        tag(d1, a + b);
        return;
    }
    untag(d1);
    untag(d2);
    cob_decimal_add(d1, d2);
}

void ccfp_decimal_sub(cob_decimal *d1, cob_decimal *d2) {
    double a, b;
    if (both_double(d1, d2, &a, &b) && isfinite(a - b)) {
        tag(d1, a - b);
        return;
    }
    untag(d1);
    untag(d2);
    cob_decimal_sub(d1, d2);
}

void ccfp_decimal_mul(cob_decimal *d1, cob_decimal *d2) {
    double a, b;
    if (both_double(d1, d2, &a, &b) && isfinite(a * b)) {
        tag(d1, a * b);
        return;
    }
    untag(d1);
    untag(d2);
    cob_decimal_mul(d1, d2);
}

void ccfp_decimal_div(cob_decimal *d1, cob_decimal *d2) {
    double a, b;
    if (both_double(d1, d2, &a, &b) && b != 0.0 && isfinite(a / b)) {
        tag(d1, a / b);
        return;
    }
    untag(d1);
    untag(d2);
    cob_decimal_div(d1, d2);
}

void ccfp_decimal_pow(cob_decimal *d1, cob_decimal *d2) {
    untag(d1);
    untag(d2);
    cob_decimal_pow(d1, d2);
}

int ccfp_decimal_cmp(cob_decimal *d1, cob_decimal *d2) {
    if (tagged(d1) && tagged(d2)) {
        double a = tag_value(d1), b = tag_value(d2);
        return a < b ? -1 : a > b;
    }
    untag(d1);
    untag(d2);
    return cob_decimal_cmp(d1, d2);
}

void ccfp_decimal_align(cob_decimal *d, const int scale) {
    untag(d);
    cob_decimal_align(d, scale);
}

/* ---- intrinsic functions ---- */

#define PI_DOUBLE 3.141592653589793238462643383279502884
#define EXACT_LIMIT 9007199254740992LL /* 2^53: an integer below it is an exact double */
#define RESULTS 64 /* libcob keeps its last 32 intrinsic results; a result is read before 64 more calls */

/* the attribute libcob gives a 64-bit integer result */
static const cob_field_attr INTEGER_ATTR = {COB_TYPE_NUMERIC_BINARY, 18, 0, COB_FLAG_HAVE_SIGN | COB_FLAG_REAL_BINARY,
                                            NULL};
static struct {
    cob_field field;
    cob_field_attr attr; /* a copy of the attribute of the field a result is a copy of (see result_copy) */
    union {
        double d;
        int64_t i;
        unsigned char text[96]; /* the digits of a quotient (see quotient_field) */
    } value;
    int is_quotient; /* 1 when the result is the quotient dividend / divisor of integers: */
    int64_t dividend, divisor;
} results[RESULTS];
static unsigned next_result;

static cob_field *result_entry(size_t size, const cob_field_attr *attr, int copy_attr) {
    unsigned n = next_result++ % RESULTS;
    results[n].field.size = size;
    results[n].field.data = (unsigned char *)&results[n].value;
    results[n].is_quotient = 0;
    if (copy_attr) {
        results[n].attr = *attr;
        results[n].field.attr = &results[n].attr;
    } else {
        results[n].field.attr = attr;
    }
    return &results[n].field;
}

static cob_field *result_field(const cob_field_attr *attr) { return result_entry(sizeof results[0].value.d, attr, 0); }

/* A result that is a copy of a field of at most 8 bytes, its attribute too (libcob's make_field_entry). */
static cob_field *result_copy(const cob_field *src) {
    cob_field *f = result_entry(src->size, src->attr, 1);
    memcpy(f->data, src->data, src->size);
    return f;
}

static cob_field *double_result(double v) {
    cob_field *f = result_field(&DOUBLE_ATTR);
    v += 0.0;
    memcpy(f->data, &v, sizeof v);
    return f;
}

static cob_field *integer_result(int64_t v) {
    cob_field *f = result_field(&INTEGER_ATTR);
    memcpy(f->data, &v, sizeof v);
    return f;
}

/* 1 when the field is an integer read here (see the head of this file); then *v is its value. */
static int integer_of(const cob_field *f, int64_t *v) {
    if (COB_FIELD_SCALE(f) != 0) {
        return 0;
    }
    if (COB_FIELD_TYPE(f) == COB_TYPE_NUMERIC_BINARY && (f->size == 1 || f->size == 2 || f->size == 4 || f->size == 8)) {
        uint64_t u = 0;
        memcpy(&u, f->data, f->size);
        if (COB_FIELD_BINARY_SWAP(f)) {
            u = __builtin_bswap64(u) >> (64 - 8 * (int)f->size);
        }
        if (COB_FIELD_HAVE_SIGN(f)) {
            int shift = 64 - 8 * (int)f->size;
            *v = (int64_t)(u << shift) >> shift;
            return 1;
        }
        *v = (int64_t)u;
        return u <= (uint64_t)INT64_MAX;
    }
    if (COB_FIELD_TYPE(f) == COB_TYPE_NUMERIC_DISPLAY && !COB_FIELD_HAVE_SIGN(f) && f->size >= 1 && f->size <= 18) {
        int64_t n = 0;
        for (size_t i = 0; i < f->size; i++) {
            if (f->data[i] < '0' || f->data[i] > '9') {
                return 0;
            }
            n = n * 10 + (f->data[i] - '0');
        }
        *v = n;
        return 1;
    }
    return 0;
}

/* FUNCTION PI is a decimal of 96 digits (libcob's own pi: cob_intr_pi, 500 ns a call: its GMP float is cut to 96 digits
 * and written as a field every time), which no operation here converts exactly. The first call is kept (field, attribute and
 * digits) and given again; the field is read as the double nearest to pi, so that FUNCTION SIN(DEGREES * FUNCTION PI / 180)
 * is a function of doubles like FUNCTION SIN(RADIANS). */
static cob_field pi_field;
static cob_field_attr pi_attr;
static unsigned char pi_digits[128];
static int pi_state; /* 0: not asked yet, 1: kept, -1: not a field of at most 128 digits (libcob's alone) */

static int pi_kept(void) {
    if (pi_state == 0) {
        const cob_field *pi = cob_intr_pi();
        int fits = pi->size <= sizeof pi_digits && COB_FIELD_TYPE(pi) == COB_TYPE_NUMERIC_DISPLAY;
        memcpy(pi_digits, pi->data, fits ? pi->size : 0);
        pi_attr = *pi->attr;
        pi_field = (cob_field){fits ? pi->size : 0, pi_digits, &pi_attr};
        pi_state = fits ? 1 : -1;
    }
    return pi_state > 0;
}

cob_field *ccfp_intr_pi(void) { return pi_kept() ? &pi_field : cob_intr_pi(); }

/* 1 when the field is the one FUNCTION PI gives (the kept field, or one with the same digits and attribute). */
static int is_pi(const cob_field *f) {
    if (f == &pi_field) {
        return 1;
    }
    if (COB_FIELD_TYPE(f) != COB_TYPE_NUMERIC_DISPLAY || !pi_kept()) {
        return 0;
    }
    return f->size == pi_field.size && f->attr->digits == pi_attr.digits && f->attr->scale == pi_attr.scale &&
           f->attr->flags == pi_attr.flags && memcmp(f->data, pi_digits, f->size) == 0;
}

/* 1 when the field is a finite float or an integer that is an exact double; then *v is its double. */
static int double_of(const cob_field *f, double *v) {
    int64_t n;
    if (COB_FIELD_TYPE(f) == COB_TYPE_NUMERIC_DOUBLE) {
        memcpy(v, f->data, sizeof *v);
        return isfinite(*v);
    }
    if (COB_FIELD_TYPE(f) == COB_TYPE_NUMERIC_FLOAT) {
        float s;
        memcpy(&s, f->data, sizeof s);
        *v = (double)s;
        return isfinite(s);
    }
    if (integer_of(f, &n) && n > -EXACT_LIMIT && n < EXACT_LIMIT) {
        *v = (double)n;
        return 1;
    }
    if (is_pi(f)) {
        *v = PI_DOUBLE;
        return 1;
    }
    return 0;
}

cob_field *ccfp_intr_sin(cob_field *f) {
    double x;
    if (double_of(f, &x)) {
        cob_set_exception(0);
        return double_result(sin(x));
    }
    return cob_intr_sin(f);
}

cob_field *ccfp_intr_cos(cob_field *f) {
    double x;
    if (double_of(f, &x)) {
        cob_set_exception(0);
        return double_result(cos(x));
    }
    return cob_intr_cos(f);
}

/* With IEEE's correctly rounded square root, FUNCTION SQRT(X * X) is the magnitude of X, as it is in libcob's decimals:
 * a program may rely on it (SQRT(DX * DX + DZ * DZ) + DZ is zero for a direction along -Z). */
cob_field *ccfp_intr_sqrt(cob_field *f) {
    double x;
    if (double_of(f, &x) && x >= 0.0) {
        cob_set_exception(0);
        return double_result(sqrt(x));
    }
    return cob_intr_sqrt(f);
}

/* FUNCTION MOD of two integers: a - b * floor(a / b), which has the sign of b. A zero divisor is libcob's (it raises
 * the argument exception). */
cob_field *ccfp_intr_mod(cob_field *f1, cob_field *f2) {
    int64_t a, b;
    if (integer_of(f1, &a) && integer_of(f2, &b) && b != 0) {
        int64_t r = b == -1 ? 0 : a % b;
        if (r != 0 && (r < 0) != (b < 0)) {
            r += b;
        }
        cob_set_exception(0);
        return integer_result(r);
    }
    return cob_intr_mod(f1, f2);
}

/* 1 when a <op> b of two integers is an integer of 64 bits; then *r is it. A division: only one without remainder. */
static int integer_binop(int64_t a, int op, int64_t b, int64_t *r) {
    if (op == '+') {
        return !__builtin_add_overflow(a, b, r);
    }
    if (op == '-') {
        return !__builtin_sub_overflow(a, b, r);
    }
    if (op == '*') {
        return !__builtin_mul_overflow(a, b, r);
    }
    if (op == '/' && b != 0 && b != -1 && a % b == 0) {
        *r = a / b;
        return 1;
    }
    return 0;
}

/* 1 when x <op> y of two doubles is a finite double; then *z is it. */
static int double_binop(double x, int op, double y, double *z) {
    if (op == '+') {
        *z = x + y;
    } else if (op == '-') {
        *z = x - y;
    } else if (op == '*') {
        *z = x * y;
    } else if (op == '/' && y != 0.0) {
        *z = x / y;
    } else {
        return 0;
    }
    return isfinite(*z);
}

/* ---- a quotient of integers with decimals ---- */

typedef unsigned __int128 u128;

static const uint64_t TEN_TO[20] = {1ULL,
                                    10ULL,
                                    100ULL,
                                    1000ULL,
                                    10000ULL,
                                    100000ULL,
                                    1000000ULL,
                                    10000000ULL,
                                    100000000ULL,
                                    1000000000ULL,
                                    10000000000ULL,
                                    100000000000ULL,
                                    1000000000000ULL,
                                    10000000000000ULL,
                                    100000000000000ULL,
                                    1000000000000000ULL,
                                    10000000000000000ULL,
                                    100000000000000000ULL,
                                    1000000000000000000ULL,
                                    10000000000000000000ULL};

/* 10^n for n up to 38 */
static u128 pow10_wide(int n) {
    return n <= 19 ? (u128)TEN_TO[n] : (u128)TEN_TO[19] * TEN_TO[n - 19];
}

static int digits_of(uint64_t v) {
    int n = 1;
    while (n < 20 && v >= TEN_TO[n]) {
        n++;
    }
    return n;
}

static int digits_of_wide(u128 v) {
    int n = 0;
    while (n < 39 && v >= pow10_wide(n)) {
        n++;
    }
    return n == 0 ? 1 : n;
}

/* Writes the digits of v (up to 19) into text[0..width) as zero padded decimal. */
static void put_digits(unsigned char *text, int width, uint64_t v) {
    for (int i = width - 1; i >= 0; i--) {
        text[i] = (unsigned char)('0' + v % 10);
        v /= 10;
    }
}

void cob_real_put_sign(cob_field *f, const int sign); /* libcob's, exported, not declared in libcob.h */

/* What libcob's FUNCTION expression a / b gives for two integers whose quotient has decimals (cob_intr_binop '/': the
 * decimal of a * 10^38 / b cut toward zero, its trailing zeros dropped, in a field cob_alloc_field makes of it: 4 or 8
 * bytes of binary when the number is small, DISPLAY otherwise). The digits come from two divisions of 19 digits each. Returns the
 * field, or null for what is left to libcob: a zero or exact quotient, a divisor of zero, a number of 62 bits or more. */
static cob_field *quotient_field(int64_t a, int64_t b) {
    if (b == 0 || a == 0 || a % b == 0 || a >= (1LL << 62) || a <= -(1LL << 62) || b >= (1LL << 62) || b <= -(1LL << 62)) {
        return NULL;
    }
    int negative = (a < 0) != (b < 0);
    uint64_t ma = a < 0 ? (uint64_t)-a : (uint64_t)a, mb = b < 0 ? (uint64_t)-b : (uint64_t)b;
    uint64_t whole = ma / mb, rest = ma % mb;
    u128 step = (u128)rest * TEN_TO[19];
    uint64_t first = (uint64_t)(step / mb); /* the first 19 decimals */
    step = (u128)(uint64_t)(step % mb) * TEN_TO[19];
    uint64_t second = (uint64_t)(step / mb); /* the next 19 */
    /* the trailing zeros of the 38 decimals are dropped (cob_trim_decimal), and the rest is the decimal digits */
    int zeros = 0;
    u128 fraction; /* the decimals as a number, trailing zeros dropped */
    if (second != 0) {
        uint64_t x = second;
        while (x % 10 == 0) {
            x /= 10;
            zeros++;
        }
        fraction = (u128)first * TEN_TO[19 - zeros] + x;
    } else {
        uint64_t x = first;
        zeros = 19;
        while (x % 10 == 0) {
            x /= 10;
            zeros++;
        }
        fraction = x;
    }
    int scale = 38 - zeros; /* at least 1: the quotient has decimals and 1 / b is above 10^-19 */
    int significant = whole > 0 ? digits_of(whole) + scale : digits_of_wide(fraction);
    cob_field *f;
    unsigned short sign_flag = negative ? COB_FLAG_HAVE_SIGN : 0;
    if (significant <= 38) {
        u128 value = (u128)whole * pow10_wide(scale) + fraction;
        int bits = value == 0 ? 1 : 128 - (int)(((uint64_t)(value >> 64) != 0) ? __builtin_clzll((uint64_t)(value >> 64)) : 64 + __builtin_clzll((uint64_t)value));
        if (bits < 33 - negative && scale < 10) {
            cob_field_attr attr = {COB_TYPE_NUMERIC_BINARY, 9, (short)scale, sign_flag, NULL};
            f = result_entry(4, &attr, 1);
            if (negative) {
                int32_t n = -(int32_t)(uint32_t)value;
                memcpy(f->data, &n, 4);
            } else {
                uint32_t n = (uint32_t)value;
                memcpy(f->data, &n, 4);
            }
            goto done;
        }
        if (bits < 65 - negative && scale < 19) {
            cob_field_attr attr = {COB_TYPE_NUMERIC_BINARY, 20, (short)scale, sign_flag, NULL};
            f = result_entry(8, &attr, 1);
            if (negative) {
                int64_t n = -(int64_t)(uint64_t)value;
                memcpy(f->data, &n, 8);
            } else {
                uint64_t n = (uint64_t)value;
                memcpy(f->data, &n, 8);
            }
            goto done;
        }
    }
    {
        /* DISPLAY: as many digits as GMP counts for the number (its count is the digits or one more), at least the decimals */
        mp_limb_t limbs[3];
        mpz_t whole_value;
        u128 low = (u128)(uint64_t)pow10_wide(scale) * whole; /* whole * 10^scale in three limbs */
        u128 high = (u128)(uint64_t)(pow10_wide(scale) >> 64) * whole + (low >> 64);
        u128 sum = (u128)(uint64_t)low + (uint64_t)fraction;
        limbs[0] = (mp_limb_t)sum;
        sum = (u128)(uint64_t)high + (uint64_t)(fraction >> 64) + (uint64_t)(sum >> 64);
        limbs[1] = (mp_limb_t)sum;
        limbs[2] = (mp_limb_t)((high >> 64) + (sum >> 64));
        mpz_roinit_n(whole_value, limbs, limbs[2] != 0 ? 3 : limbs[1] != 0 ? 2 : 1);
        int size = (int)mpz_sizeinbase(whole_value, 10);
        if (scale > size) {
            size = scale;
        }
        /* the number has at most 62 + 126 bits: 57 digits, 58 counted by GMP, which fit the 96 bytes of a result */
        cob_field_attr attr = {COB_TYPE_NUMERIC_DISPLAY, (unsigned short)size, (short)scale, sign_flag, NULL};
        f = result_entry((size_t)size, &attr, 1);
        memset(f->data, '0', (size_t)size);
        /* digits: the whole part (when there is one), then the decimals */
        int whole_digits = whole > 0 ? digits_of(whole) : 0;
        unsigned char *end = f->data + size;
        {
            /* the decimals cut at `scale` digits: the first `scale` of the 38 */
            unsigned char all[38];
            put_digits(all, 19, first);
            put_digits(all + 19, 19, second);
            memcpy(end - scale, all, (size_t)scale);
        }
        if (whole > 0) {
            put_digits(end - scale - whole_digits, whole_digits, whole);
        }
        if (negative) {
            cob_real_put_sign(f, -1);
        }
        goto done;
    }
done:
    results[(next_result - 1) % RESULTS].is_quotient = 1;
    results[(next_result - 1) % RESULTS].dividend = a;
    results[(next_result - 1) % RESULTS].divisor = b;
    return f;
}

/* 1 when the field is a quotient made by quotient_field and not yet overwritten; then *a and *b are its operands. */
static int is_quotient(const cob_field *f, int64_t *a, int64_t *b) {
    uintptr_t offset = (uintptr_t)f - (uintptr_t)&results[0].field;
    if ((uintptr_t)f < (uintptr_t)&results[0].field || offset % sizeof results[0] != 0 || offset / sizeof results[0] >= RESULTS) {
        return 0;
    }
    size_t n = offset / sizeof results[0];
    if (!results[n].is_quotient) {
        return 0;
    }
    *a = results[n].dividend;
    *b = results[n].divisor;
    return 1;
}

cob_field *ccfp_intr_binop(cob_field *f1, const int op, cob_field *f2) {
    int64_t a, b, r;
    double x, y, z;
    if (integer_of(f1, &a) && integer_of(f2, &b)) {
        if (!integer_binop(a, op, b, &r)) {
            cob_field *quotient = op == '/' ? quotient_field(a, b) : NULL;
            if (quotient != NULL) {
                cob_set_exception(0);
                return quotient;
            }
            return cob_intr_binop(f1, op, f2);
        }
        if (op == '/') {
            cob_set_exception(0);
        }
        return integer_result(r);
    }
    if (double_of(f1, &x) && double_of(f2, &y) && double_binop(x, op, y, &z)) {
        if (op == '/') {
            cob_set_exception(0);
        }
        return double_result(z);
    }
    return cob_intr_binop(f1, op, f2);
}

cob_field *ccfp_intr_tan(cob_field *f) {
    double x;
    if (double_of(f, &x)) {
        cob_set_exception(0);
        return double_result(tan(x)); /* the tangent of a finite double is finite */
    }
    return cob_intr_tan(f);
}

/* libcob's arc tangent of zero is the integer 0; of any other number a decimal, to which libm's double is the
 * (nearest) approximation, like sin and cos. */
cob_field *ccfp_intr_atan(cob_field *f) {
    double x;
    if (double_of(f, &x)) {
        cob_set_exception(0);
        return double_result(atan(x));
    }
    return cob_intr_atan(f);
}

/* ---- whole numbers and compares ---- */

#define MAGNITUDE_LIMIT 4000000000000000000.0 /* below 2^62: a double below it is cut to an int64 */

HOT int is_float_field(const cob_field *f) {
    return COB_FIELD_TYPE(f) == COB_TYPE_NUMERIC_DOUBLE || COB_FIELD_TYPE(f) == COB_TYPE_NUMERIC_FLOAT;
}

/* 1 when the field is a float of a value libcob's decimal keeps exactly (finite, not a negative zero); then *v is it. */
HOT int float_of(const cob_field *f, double *v) {
    if (COB_FIELD_TYPE(f) == COB_TYPE_NUMERIC_DOUBLE) {
        memcpy(v, f->data, sizeof *v);
    } else {
        float s;
        memcpy(&s, f->data, sizeof s);
        *v = (double)s;
    }
    return isfinite(*v) && !(*v == 0.0 && signbit(*v));
}

/* The number of the decimal V / 10^scale as libcob's cob_decimal_get_double makes a double of it: its GMP float
 * division is cut, so the double is cut toward zero (the C quotient is rounded to nearest: a quotient that lies above
 * the exact one, which the fused product with the divisor shows, is the double before it). V is below 2^53. */
static double cut_quotient(uint64_t v, int scale) {
    double m = (double)v;
    if (scale == 0) {
        return m;
    }
    double q = m / POWER_OF_TEN[scale];
    return fma(q, POWER_OF_TEN[scale], -m) > 0.0 ? nextafter(q, 0.0) : q;
}

/* 1 when the field is a DISPLAY number of up to 15 digits with 0 to 22 decimals (a literal or a PIC 9 / PIC S9 SIGN
 * LEADING SEPARATE item); then *v is libcob's double of it. */
static int display_double(const cob_field *f, double *v) {
    const unsigned char *p = f->data;
    size_t n = f->size;
    int negative = 0, scale = COB_FIELD_SCALE(f);
    if (COB_FIELD_TYPE(f) != COB_TYPE_NUMERIC_DISPLAY || scale < 0 || scale > 22) {
        return 0;
    }
    if (COB_FIELD_HAVE_SIGN(f)) {
        if (!COB_FIELD_SIGN_SEPARATE(f) || !COB_FIELD_SIGN_LEADING(f) || n < 2 || (p[0] != '+' && p[0] != '-')) {
            return 0;
        }
        negative = p[0] == '-';
        p++;
        n--;
    }
    if (n < 1 || n > 15) {
        return 0;
    }
    uint64_t m = 0;
    for (size_t i = 0; i < n; i++) {
        if (p[i] < '0' || p[i] > '9') {
            return 0;
        }
        m = m * 10 + (p[i] - '0');
    }
    *v = m == 0 ? 0.0 : negative ? -cut_quotient(m, scale) : cut_quotient(m, scale);
    return 1;
}

/* 1 when the field is a number cob_cmp_float reads as libcob does: a float (its bytes as they are: libcob compares a
 * non-finite float too), an integer below 2^53, a DISPLAY number of display_double. */
HOT int compare_operand(const cob_field *f, double *v) {
    int64_t n;
    if (COB_FIELD_TYPE(f) == COB_TYPE_NUMERIC_DOUBLE) {
        memcpy(v, f->data, sizeof *v);
        return 1;
    }
    if (COB_FIELD_TYPE(f) == COB_TYPE_NUMERIC_FLOAT) {
        float s;
        memcpy(&s, f->data, sizeof s);
        *v = (double)s;
        return 1;
    }
    if (integer_of(f, &n) && n > -EXACT_LIMIT && n < EXACT_LIMIT) {
        *v = (double)n;
        return 1;
    }
    return display_double(f, v);
}

/* libcob's cob_cmp_float of two doubles: equal within a relative 1e-7. */
HOT int float_compare(double a, double b) {
    if (a == b) {
        return 0;
    }
    if (a != 0.0 && fabs((a - b) / a) < 0.0000001) {
        return 0;
    }
    return a < b ? -1 : 1;
}

int ccfp_cmp_llint(cob_field *f, const cob_s64_t n) {
    double v;
    if (is_float_field(f) && float_of(f, &v)) {
        if (v == 0.0) {
            return n > INT_MAX ? INT_MIN : n < INT_MIN ? INT_MAX : -(int)n; /* libcob's own answer for a zero */
        }
        if (v > 0.0 ? n <= 0 : n >= 0) {
            return v > 0.0 ? 1 : -1;
        }
        if (n > -EXACT_LIMIT && n < EXACT_LIMIT) {
            double w = (double)n;
            return v < w ? -1 : v > w;
        }
    }
    return cob_cmp_llint(f, n);
}

int ccfp_numeric_cmp(cob_field *f1, cob_field *f2) {
    double a, b;
    if ((is_float_field(f1) || is_float_field(f2)) && compare_operand(f1, &a) && compare_operand(f2, &b)) {
        return float_compare(a, b);
    }
    return cob_numeric_cmp(f1, f2);
}

int ccfp_cmp(cob_field *f1, cob_field *f2) {
    double a, b;
    if ((is_float_field(f1) || is_float_field(f2)) && compare_operand(f1, &a) && compare_operand(f2, &b)) {
        return float_compare(a, b);
    }
    return cob_cmp(f1, f2);
}

/* libcob's number of a binary field read as an int or a long long (scale 0): its value. */
int ccfp_get_int(cob_field *f) {
    int64_t n;
    if (COB_FIELD_TYPE(f) == COB_TYPE_NUMERIC_BINARY && integer_of(f, &n)) {
        return (int)n;
    }
    return cob_get_int(f);
}

cob_s64_t ccfp_get_llint(cob_field *f) {
    int64_t n;
    if (COB_FIELD_TYPE(f) == COB_TYPE_NUMERIC_BINARY && integer_of(f, &n)) {
        return n;
    }
    return cob_get_llint(f);
}

/* MOVE of a number into a float field, or of a float into a binary integer field: the conversions cob_move makes
 * through a decimal (cob_decimal_setget_fld), which are exact for the numbers read here; anything else is libcob's. */
void ccfp_move(cob_field *src, cob_field *dst) {
    unsigned dst_type = COB_FIELD_TYPE(dst), src_type = COB_FIELD_TYPE(src);
    double v;
    if (dst_type == COB_TYPE_NUMERIC_DOUBLE || dst_type == COB_TYPE_NUMERIC_FLOAT) {
        int64_t n;
        int have = 0;
        if (src_type == COB_TYPE_NUMERIC_DISPLAY) {
            have = display_double(src, &v);
        } else if (src_type == COB_TYPE_NUMERIC_BINARY && integer_of(src, &n) && n > -EXACT_LIMIT && n < EXACT_LIMIT) {
            v = (double)n;
            have = 1;
        }
        if (have && dst_type == COB_TYPE_NUMERIC_DOUBLE) {
            memcpy(dst->data, &v, sizeof v);
            return;
        }
        if (have) {
            float s = (float)v; /* a number below 2^53 in magnitude: finite */
            memcpy(dst->data, &s, sizeof s);
            return;
        }
    } else if ((dst_type == COB_TYPE_NUMERIC_BINARY || dst_type == COB_TYPE_NUMERIC_COMP5) && is_float_field(src) &&
               float_of(src, &v)) {
        int opt = COB_FIELD_BINARY_TRUNC(dst) && !COB_FIELD_REAL_BINARY(dst) ? COB_STORE_TRUNC_ON_OVERFLOW : 0;
        if (store_integer(v, dst, opt | COB_STORE_NO_SIZE_ERROR)) {
            return;
        }
    }
    cob_move(src, dst);
}

/* FUNCTION INTEGER and INTEGER-PART give libcob's whole number: a binary field of 4 bytes when it has up to 32 bits
 * (31 and a sign when negative), of 8 bytes otherwise, signed when negative. */
static const cob_field_attr INT4_SIGNED = {COB_TYPE_NUMERIC_BINARY, 9, 0, COB_FLAG_HAVE_SIGN, NULL};
static const cob_field_attr INT4_UNSIGNED = {COB_TYPE_NUMERIC_BINARY, 9, 0, 0, NULL};
static const cob_field_attr INT8_SIGNED = {COB_TYPE_NUMERIC_BINARY, 20, 0, COB_FLAG_HAVE_SIGN, NULL};
static const cob_field_attr INT8_UNSIGNED = {COB_TYPE_NUMERIC_BINARY, 20, 0, 0, NULL};

static cob_field *whole_number(int64_t n) {
    uint64_t magnitude = n < 0 ? (uint64_t)0 - (uint64_t)n : (uint64_t)n;
    int bits = magnitude == 0 ? 1 : 64 - __builtin_clzll(magnitude);
    cob_field *f;
    if (n < 0 ? bits < 32 : bits < 33) {
        f = result_entry(4, n < 0 ? &INT4_SIGNED : &INT4_UNSIGNED, 0);
        int32_t i = (int32_t)n;
        uint32_t u = (uint32_t)n;
        memcpy(f->data, n < 0 ? (void *)&i : (void *)&u, 4);
    } else {
        f = result_entry(8, n < 0 ? &INT8_SIGNED : &INT8_UNSIGNED, 0);
        memcpy(f->data, &n, 8);
    }
    return f;
}

/* 1 when the field is a float or an integer; then *n is its whole number (floor when `down`, else cut toward zero). */
HOT int whole_of(const cob_field *f, int down, int64_t *n) {
    double v;
    if (is_float_field(f)) {
        if (!float_of(f, &v) || !(v > -MAGNITUDE_LIMIT && v < MAGNITUDE_LIMIT)) {
            return 0;
        }
        *n = (int64_t)(down ? floor(v) : v);
        return 1;
    }
    return COB_FIELD_TYPE(f) == COB_TYPE_NUMERIC_BINARY && integer_of(f, n) && *n != INT64_MIN; /* its magnitude has 64 bits: libcob writes DISPLAY digits */
}

/* The whole number of a quotient this file made: FUNCTION INTEGER(a / b), the idiom of a floor division, without reading
 * the decimal back. The quotient libcob keeps is cut toward zero at 38 decimals, which no whole number lies between it
 * and a / b. */
cob_field *ccfp_intr_integer(cob_field *f) {
    int64_t n, a, b;
    if (is_quotient(f, &a, &b)) {
        n = a / b;
        return whole_number((a % b != 0 && (a < 0) != (b < 0)) ? n - 1 : n);
    }
    if (whole_of(f, 1, &n)) {
        return whole_number(n);
    }
    return cob_intr_integer(f);
}

cob_field *ccfp_intr_integer_part(cob_field *f) {
    int64_t n, a, b;
    if (is_quotient(f, &a, &b)) {
        return whole_number(a / b);
    }
    if (whole_of(f, 0, &n)) {
        return whole_number(n);
    }
    return cob_intr_integer_part(f);
}

/* 1 when the decimal of the double has at most 96 digits, the most libcob's GMP float keeps: then libcob's double of
 * the decimal is the double itself (the decimal is exact), and a copy of the double needs no libcob. A double is
 * o * 2^k with o odd; o * 5^-k has up to 16 + 0.7 * -k digits. */
HOT int decimal_is_exact(double v) {
    uint64_t bits, mantissa;
    int exponent;
    memcpy(&bits, &v, sizeof bits);
    exponent = (int)((bits >> 52) & 0x7ff);
    mantissa = (bits & 0xfffffffffffffULL) | (1ULL << 52);
    if (exponent == 0 || exponent > 1023 + 260) {
        return 0; /* zero and the denormals, and above 1e78 */
    }
    return exponent - 1075 + __builtin_ctzll(mantissa) >= -110;
}

/* FUNCTION ABS of a float is libcob's float of the decimal of its magnitude: the same bits when the decimal is exact.
 * The result has the attribute of the argument. */
cob_field *ccfp_intr_abs(cob_field *f) {
    double v;
    if (is_float_field(f) && float_of(f, &v) && (v == 0.0 || decimal_is_exact(v))) {
        cob_field *r = result_copy(f);
        if (f->size == sizeof(double)) {
            double m = fabs(v);
            memcpy(r->data, &m, sizeof m);
        } else {
            float m = (float)fabs(v);
            memcpy(r->data, &m, sizeof m);
        }
        return r;
    }
    return cob_intr_abs(f);
}
