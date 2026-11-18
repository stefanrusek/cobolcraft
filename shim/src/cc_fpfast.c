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

static int tagged(const cob_decimal *d) { return d->scale == FP_TAG; }

static double tag_value(const cob_decimal *d) {
    double v;
    memcpy(&v, mpz_limbs_read(d->value), sizeof v);
    return v;
}

/* A zero is kept as positive zero: libcob's decimal has no negative zero, so no arithmetic of libcob gives one. */
static void tag(cob_decimal *d, double v) {
    v += 0.0;
    memcpy(mpz_limbs_write(d->value, 1), &v, sizeof v);
    mpz_limbs_finish(d->value, 1);
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
static int as_double(const cob_decimal *d, double *v) {
    if (tagged(d)) {
        *v = tag_value(d);
        return 1;
    }
    if (d->scale < 0 || d->scale > 22 || mpz_sizeinbase(d->value, 2) > 53) {
        return 0;
    }
    *v = mpz_get_d(d->value) / POWER_OF_TEN[d->scale];
    return 1;
}

/* 1 when the operation is one for doubles: at least one operand is tagged and both have a double. */
static int both_double(const cob_decimal *d1, const cob_decimal *d2, double *a, double *b) {
    return (tagged(d1) || tagged(d2)) && as_double(d1, a) && as_double(d2, b);
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

#define EXACT_LIMIT 9007199254740992LL /* 2^53: an integer below it is an exact double */
#define RESULTS 64 /* libcob keeps its last 32 intrinsic results; a result is read before 64 more calls */

/* the attribute libcob gives a 64-bit integer result */
static const cob_field_attr INTEGER_ATTR = {COB_TYPE_NUMERIC_BINARY, 18, 0, COB_FLAG_HAVE_SIGN | COB_FLAG_REAL_BINARY,
                                            NULL};
static struct {
    cob_field field;
    union {
        double d;
        int64_t i;
    } value;
} results[RESULTS];
static unsigned next_result;

static cob_field *result_field(const cob_field_attr *attr) {
    unsigned n = next_result++ % RESULTS;
    results[n].field.size = sizeof results[n].value;
    results[n].field.data = (unsigned char *)&results[n].value;
    results[n].field.attr = attr;
    return &results[n].field;
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
        unsigned char bytes[8] = {0};
        uint64_t u;
        for (size_t i = 0; i < f->size; i++) {
            bytes[i] = COB_FIELD_BINARY_SWAP(f) ? f->data[f->size - 1 - i] : f->data[i];
        }
        memcpy(&u, bytes, sizeof u);
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

cob_field *ccfp_intr_binop(cob_field *f1, const int op, cob_field *f2) {
    int64_t a, b, r;
    double x, y, z;
    if (integer_of(f1, &a) && integer_of(f2, &b)) {
        if (!integer_binop(a, op, b, &r)) {
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
