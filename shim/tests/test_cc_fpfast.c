/* Implementation test of shim/src/cc_fpfast.c: the ccfp_decimal_* functions against libcob's own cob_decimal_* functions
 * (the stock path, called here by their own names) and against C double arithmetic.
 *   - float operands and a float target: the stored bytes are those of the C expression, a zero result being positive
 *     zero (libcob never gives a negative zero);
 *   - a decimal operand that converts exactly (an integer below 2^53, a literal of up to 22 decimals): the same;
 *   - every case that is passed on (a target that is not a float, an operand that does not convert exactly, a division
 *     by zero, a result that is not finite, an operand that is not finite, a power, an alignment, a comparison with a
 *     decimal): the stored bytes, the return value and the comparison result are those of the stock functions, given
 *     the same double where a double was computed;
 *   - the ccfp_intr_* functions (SIN, COS, MOD, the arithmetic inside a function argument) against libcob's cob_intr_*
 *     functions: MOD and integer arithmetic give the same number, float arithmetic the C double, SIN and COS libm's
 *     double (within 1e-15 of libcob's), and every argument this file does not read itself gives libcob's result. */
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "cc_fpfast.h"
#include "testlib.h"

typedef struct {
    void (*set)(cob_decimal *, cob_field *);
    int (*get)(cob_decimal *, cob_field *, const int);
    void (*op[5])(cob_decimal *, cob_decimal *); /* + - * / ** */
    int (*cmp)(cob_decimal *, cob_decimal *);
    void (*align)(cob_decimal *, const int);
} api;

static const api STOCK = {cob_decimal_set_field, cob_decimal_get_field,
                          {cob_decimal_add, cob_decimal_sub, cob_decimal_mul, cob_decimal_div, cob_decimal_pow},
                          cob_decimal_cmp, cob_decimal_align};
static const api FAST = {ccfp_decimal_set_field, ccfp_decimal_get_field,
                         {ccfp_decimal_add, ccfp_decimal_sub, ccfp_decimal_mul, ccfp_decimal_div, ccfp_decimal_pow},
                         ccfp_decimal_cmp, ccfp_decimal_align};
static const char OPS[] = "+-*/^";

/* the attributes cobc generates: FLOAT-LONG, FLOAT-SHORT, BINARY-LONG, BINARY-DOUBLE, PIC 9(5)V9(4), PIC 9(3)P(2),
 * PIC V9(25). The display fields are unsigned: libcob reads the sign convention of a signed one from the running
 * COBOL module, and this test has none. */
static const cob_field_attr A_DOUBLE = {COB_TYPE_NUMERIC_DOUBLE, 34, 17, COB_FLAG_HAVE_SIGN | COB_FLAG_IS_FP, NULL};
static const cob_field_attr A_FLOAT = {COB_TYPE_NUMERIC_FLOAT, 15, 8, COB_FLAG_HAVE_SIGN | COB_FLAG_IS_FP, NULL};
static const cob_field_attr A_LONG = {COB_TYPE_NUMERIC_BINARY, 9, 0, COB_FLAG_HAVE_SIGN | COB_FLAG_REAL_BINARY, NULL};
static const cob_field_attr A_QUAD = {COB_TYPE_NUMERIC_BINARY, 18, 0, COB_FLAG_HAVE_SIGN | COB_FLAG_REAL_BINARY, NULL};
static const cob_field_attr A_DEC = {COB_TYPE_NUMERIC_DISPLAY, 9, 4, 0, NULL};
static const cob_field_attr A_SCALED = {COB_TYPE_NUMERIC_DISPLAY, 3, -2, 0, NULL};
static const cob_field_attr A_FINE = {COB_TYPE_NUMERIC_DISPLAY, 25, 25, 0, NULL};

static cob_decimal d1, d2;

static cob_field field_of(void *data, size_t size, const cob_field_attr *attr) {
    cob_field f = {size, data, attr};
    return f;
}

/* target = a <op> b through one of the two sets of functions; the return value of the store. */
static int compute(const api *x, cob_field *target, cob_field *a, char op, cob_field *b, int opt) {
    x->set(&d1, a);
    x->set(&d2, b);
    x->op[strchr(OPS, op) - OPS](&d1, &d2);
    return x->get(&d1, target, opt);
}

/* The same statement through both sets of functions: equal stored bytes and return values. */
static void same_as_stock(const char *name, cob_field *target, cob_field *a, char op, cob_field *b, int opt) {
    unsigned char stock[32], fast[32];
    char label[200];
    memset(target->data, 0, target->size);
    int stock_status = compute(&STOCK, target, a, op, b, opt);
    memcpy(stock, target->data, target->size);
    memset(target->data, 0, target->size);
    int fast_status = compute(&FAST, target, a, op, b, opt);
    memcpy(fast, target->data, target->size);
    snprintf(label, sizeof label, "%s: stored bytes", name);
    tl_bytes(label, stock, target->size, fast, target->size);
    snprintf(label, sizeof label, "%s: return value", name);
    tl_int(label, stock_status, fast_status);
}

static const double VALUES[] = {0.0,  -0.0,   1.0,   -1.0,        0.1,         0.2,          0.3,   1.5,
                                -2.75, 1e-300, 1e300, 123456.789, -98765.4321, 3.0e-9,       7.0,   1.0 / 3.0};
#define VALUE_COUNT ((int)(sizeof VALUES / sizeof VALUES[0]))

static double apply(double a, char op, double b) { return op == '+' ? a + b : op == '-' ? a - b : op == '*' ? a * b : a / b; }

static void float_to_float(void) {
    int wrong = 0, done = 0;
    for (int i = 0; i < VALUE_COUNT; i++) {
        for (int j = 0; j < VALUE_COUNT; j++) {
            for (int k = 0; k < 4; k++) {
                double a = VALUES[i], b = VALUES[j], want = apply(a, OPS[k], b) + 0.0, got = 99.0;
                if (!isfinite(want) || (OPS[k] == '/' && b == 0.0)) {
                    continue;
                }
                cob_field fa = field_of(&a, sizeof a, &A_DOUBLE), fb = field_of(&b, sizeof b, &A_DOUBLE);
                cob_field ft = field_of(&got, sizeof got, &A_DOUBLE);
                int status = compute(&FAST, &ft, &fa, OPS[k], &fb, 0);
                done++;
                wrong += status != 0 || memcmp(&want, &got, sizeof want) != 0;
            }
        }
    }
    tl_int("fpfast FLOAT-LONG op FLOAT-LONG into FLOAT-LONG: statements checked", 989, done);
    tl_int("fpfast FLOAT-LONG op FLOAT-LONG into FLOAT-LONG: results that are not the bytes of the C double expression", 0, wrong);

    wrong = 0;
    for (int i = 0; i < VALUE_COUNT; i++) {
        for (int k = 0; k < 4; k++) {
            float a = (float)VALUES[i], b = 1.25f, got = 99.0f;
            float want = (float)(apply((double)a, OPS[k], (double)b) + 0.0);
            if (!isfinite(a)) {
                continue; /* 1e300 is no FLOAT-SHORT value */
            }
            cob_field fa = field_of(&a, sizeof a, &A_FLOAT), fb = field_of(&b, sizeof b, &A_FLOAT);
            cob_field ft = field_of(&got, sizeof got, &A_FLOAT);
            int status = compute(&FAST, &ft, &fa, OPS[k], &fb, 0);
            wrong += status != 0 || memcmp(&want, &got, sizeof want) != 0;
        }
    }
    tl_int("fpfast FLOAT-SHORT op FLOAT-SHORT into FLOAT-SHORT: results that are not the bytes of the C expression in double", 0, wrong);

    double zero = 0.0, minus = -1.0, got = 99.0, positive_zero = 0.0;
    cob_field fzero = field_of(&zero, sizeof zero, &A_DOUBLE), fminus = field_of(&minus, sizeof minus, &A_DOUBLE);
    cob_field ft = field_of(&got, sizeof got, &A_DOUBLE);
    compute(&FAST, &ft, &fzero, '*', &fminus, 0);
    tl_bytes("fpfast 0.0 * -1.0 is stored as positive zero", &positive_zero, sizeof positive_zero, &got, sizeof got);
    same_as_stock("fpfast 0.0 * -1.0", &ft, &fzero, '*', &fminus, 0);
}

static void exact_decimal_operands(void) {
    double a = 0.1, got = 0.0, want;
    int32_t seven = 7;
    int64_t below = 9007199254740991LL; /* 2^53 - 1 */
    unsigned char literal[] = "125"; /* 12.5 as the literal cobc makes: digits, scale 1 */
    const cob_field_attr a_literal = {COB_TYPE_NUMERIC_DISPLAY, 3, 1, COB_FLAG_CONSTANT, NULL};
    cob_field fa = field_of(&a, sizeof a, &A_DOUBLE), ft = field_of(&got, sizeof got, &A_DOUBLE);
    cob_field f7 = field_of(&seven, sizeof seven, &A_LONG), fbelow = field_of(&below, sizeof below, &A_QUAD);
    cob_field fl = field_of(literal, 3, &a_literal);

    compute(&FAST, &ft, &fa, '/', &f7, 0);
    want = 0.1 / 7.0;
    tl_bytes("fpfast FLOAT-LONG / BINARY-LONG 7 is the C double 0.1 / 7.0", &want, sizeof want, &got, sizeof got);
    compute(&FAST, &ft, &f7, '-', &fa, 0);
    want = 7.0 - 0.1;
    tl_bytes("fpfast BINARY-LONG 7 - FLOAT-LONG is the C double 7.0 - 0.1", &want, sizeof want, &got, sizeof got);
    compute(&FAST, &ft, &fa, '*', &fl, 0);
    want = 0.1 * 12.5;
    tl_bytes("fpfast FLOAT-LONG * literal 12.5 is the C double 0.1 * 12.5", &want, sizeof want, &got, sizeof got);
    compute(&FAST, &ft, &fa, '+', &fbelow, 0);
    want = 0.1 + 9007199254740991.0;
    tl_bytes("fpfast FLOAT-LONG + BINARY-DOUBLE 2^53 - 1 is the C double sum", &want, sizeof want, &got, sizeof got);
}

/* A decimal that was never a float, stored into a float field: libcob's own store (it truncates where C rounds), the
 * double MOVE and VALUE give. */
static void decimal_into_float(void) {
    double got = 0.0, want = 0.0;
    unsigned char literal[] = "2"; /* 0.2 */
    const cob_field_attr a_literal = {COB_TYPE_NUMERIC_DISPLAY, 1, 1, COB_FLAG_CONSTANT, NULL};
    cob_field fl = field_of(literal, 1, &a_literal);
    cob_field ft = field_of(&got, sizeof got, &A_DOUBLE), fw = field_of(&want, sizeof want, &A_DOUBLE);

    FAST.set(&d1, &fl);
    FAST.get(&d1, &ft, 0);
    STOCK.set(&d1, &fl);
    STOCK.get(&d1, &fw, 0);
    tl_bytes("fpfast the decimal 0.2 into a FLOAT-LONG is libcob's double", &want, sizeof want, &got, sizeof got);
}

static void passed_on(void) {
    double a = 0.1, b = 0.2, zero = 0.0, big = 1e300, tiny = 1e-300, negbig = -1.7e308, huge = 1.7e308, got = 0.0;
    float small = 0.0f;
    int32_t three = 3, hundred = 100, n = 0;
    int64_t above = 9007199254740993LL, q = 0; /* 2^53 + 1 */
    unsigned char dec[] = "001234567", dec_out[9], scaled[] = "123", fine[] = "1234567890123456789012345";
    uint64_t inf_bits = 0x7FF0000000000000ULL, nan_bits = 0x7FF8000000000001ULL;
    cob_field fa = field_of(&a, sizeof a, &A_DOUBLE), fb = field_of(&b, sizeof b, &A_DOUBLE);
    cob_field fzero = field_of(&zero, sizeof zero, &A_DOUBLE), fbig = field_of(&big, sizeof big, &A_DOUBLE);
    cob_field ftiny = field_of(&tiny, sizeof tiny, &A_DOUBLE), fnegbig = field_of(&negbig, sizeof negbig, &A_DOUBLE);
    cob_field fhuge = field_of(&huge, sizeof huge, &A_DOUBLE);
    cob_field fgot = field_of(&got, sizeof got, &A_DOUBLE), fsmall = field_of(&small, sizeof small, &A_FLOAT);
    cob_field f3 = field_of(&three, sizeof three, &A_LONG), f100 = field_of(&hundred, sizeof hundred, &A_LONG);
    cob_field fn = field_of(&n, sizeof n, &A_LONG), fabove = field_of(&above, sizeof above, &A_QUAD);
    cob_field fq = field_of(&q, sizeof q, &A_QUAD), fdec = field_of(dec, 9, &A_DEC), fdec_out = field_of(dec_out, 9, &A_DEC);
    cob_field fscaled = field_of(scaled, 3, &A_SCALED), ffine = field_of(fine, 25, &A_FINE);
    cob_field finf = field_of(&inf_bits, sizeof inf_bits, &A_DOUBLE), fnan = field_of(&nan_bits, sizeof nan_bits, &A_DOUBLE);

    /* no float at all */
    same_as_stock("fpfast BINARY-LONG * BINARY-LONG into BINARY-LONG", &fn, &f3, '*', &f100, 0);
    same_as_stock("fpfast decimal / BINARY-LONG into decimal, rounded", &fdec_out, &fdec, '/', &f3, COB_STORE_ROUND);
    same_as_stock("fpfast BINARY-LONG / BINARY-LONG into FLOAT-LONG", &fgot, &f100, '/', &f3, 0);
    /* an operand that does not convert exactly */
    same_as_stock("fpfast BINARY-DOUBLE 2^53 + 1 + FLOAT-LONG into BINARY-DOUBLE", &fq, &fabove, '+', &fa, 0);
    same_as_stock("fpfast FLOAT-LONG - BINARY-DOUBLE 2^53 + 1 into FLOAT-LONG", &fgot, &fa, '-', &fabove, 0);
    same_as_stock("fpfast FLOAT-LONG * PIC 9(3)P(2) (a negative scale) into FLOAT-LONG", &fgot, &fa, '*', &fscaled, 0);
    same_as_stock("fpfast FLOAT-LONG + PIC V9(25) (25 decimals) into FLOAT-LONG", &fgot, &fa, '+', &ffine, 0);
    /* a division by zero, with and without the size error asked for */
    same_as_stock("fpfast FLOAT-LONG / FLOAT-LONG zero, ON SIZE ERROR", &fgot, &fa, '/', &fzero, COB_STORE_KEEP_ON_OVERFLOW);
    same_as_stock("fpfast FLOAT-LONG / FLOAT-LONG zero, no size error phrase", &fgot, &fa, '/', &fzero, 0);
    /* a result that is not finite */
    same_as_stock("fpfast 1e300 * 1e300, ON SIZE ERROR", &fgot, &fbig, '*', &fbig, COB_STORE_KEEP_ON_OVERFLOW);
    same_as_stock("fpfast 1e300 / 1e-300, no size error phrase", &fgot, &fbig, '/', &ftiny, 0);
    same_as_stock("fpfast 1e300 * 1e300 into FLOAT-SHORT", &fsmall, &fbig, '*', &fbig, 0);
    same_as_stock("fpfast 1e300 + 0.1 into FLOAT-SHORT (does not fit)", &fsmall, &fbig, '+', &fa, COB_STORE_KEEP_ON_OVERFLOW);
    same_as_stock("fpfast -1.7e308 - 1.7e308 (not finite), ON SIZE ERROR", &fgot, &fnegbig, '-', &fhuge, COB_STORE_KEEP_ON_OVERFLOW);
    same_as_stock("fpfast 1.7e308 + 1.7e308 (not finite), ON SIZE ERROR", &fgot, &fhuge, '+', &fhuge, COB_STORE_KEEP_ON_OVERFLOW);
    /* an operand that is not finite: libcob loads it as zero */
    same_as_stock("fpfast infinity + FLOAT-LONG", &fgot, &finf, '+', &fa, 0);
    same_as_stock("fpfast FLOAT-LONG * not-a-number", &fgot, &fa, '*', &fnan, 0);
    /* a power */
    same_as_stock("fpfast FLOAT-LONG ** BINARY-LONG 3", &fgot, &fa, '^', &f3, 0);
    same_as_stock("fpfast BINARY-LONG 3 ** FLOAT-LONG", &fgot, &f3, '^', &fb, 0);
}

/* A float result stored into a field that is not a float: libcob's store of the C double. */
static void float_into_other(void) {
    static const struct { double a; char op; double b; int opt; } CASES[] = {
        {0.1, '*', 100.0, 0}, {0.2, '*', 12.5, COB_STORE_ROUND}, {123.4567, '*', 0.2, 0}, {123.4567, '*', 0.2, COB_STORE_ROUND},
        {7.9, '+', 0.0, 0},   {1e12, '*', 1e3, COB_STORE_KEEP_ON_OVERFLOW}, {2.5, '-', 0.5, COB_STORE_ROUND}, {1.0, '/', 3.0, 0},
    };
    for (unsigned i = 0; i < sizeof CASES / sizeof CASES[0]; i++) {
        double a = CASES[i].a, b = CASES[i].b, r = apply(a, CASES[i].op, b);
        int32_t n_stock = 0, n_fast = 0;
        unsigned char dec_stock[9], dec_fast[9];
        char label[160];
        cob_field fa = field_of(&a, sizeof a, &A_DOUBLE), fb = field_of(&b, sizeof b, &A_DOUBLE), fr = field_of(&r, sizeof r, &A_DOUBLE);
        cob_field fn_stock = field_of(&n_stock, sizeof n_stock, &A_LONG), fn_fast = field_of(&n_fast, sizeof n_fast, &A_LONG);
        cob_field fd_stock = field_of(dec_stock, 9, &A_DEC), fd_fast = field_of(dec_fast, 9, &A_DEC);

        cob_decimal_set_field(&d1, &fr);
        int stock_status = cob_decimal_get_field(&d1, &fn_stock, CASES[i].opt);
        int fast_status = compute(&FAST, &fn_fast, &fa, CASES[i].op, &fb, CASES[i].opt);
        snprintf(label, sizeof label, "fpfast %g %c %g into BINARY-LONG is libcob's store of the C double", a, CASES[i].op, b);
        tl_int(label, n_stock + 1000003LL * stock_status, n_fast + 1000003LL * fast_status);

        memset(dec_stock, '0', 9);
        memset(dec_fast, '0', 9);
        cob_decimal_set_field(&d1, &fr);
        stock_status = cob_decimal_get_field(&d1, &fd_stock, CASES[i].opt);
        fast_status = compute(&FAST, &fd_fast, &fa, CASES[i].op, &fb, CASES[i].opt);
        snprintf(label, sizeof label, "fpfast %g %c %g into PIC 9(5)V9(4) is libcob's store of the C double", a, CASES[i].op, b);
        tl_bytes(label, dec_stock, 9, dec_fast, 9);
        snprintf(label, sizeof label, "fpfast %g %c %g into PIC 9(5)V9(4): return value", a, CASES[i].op, b);
        tl_int(label, stock_status, fast_status);
    }
}

static int compare(const api *x, cob_field *a, cob_field *b) {
    x->set(&d1, a);
    x->set(&d2, b);
    return x->cmp(&d1, &d2);
}

static void comparisons_and_alignment(void) {
    double a = 0.1, b = 0.2, sum = 0.1 + 0.2, got = 0.0;
    int32_t three = 3, n_stock = 0, n_fast = 0;
    unsigned char literal[] = "3"; /* 0.3 */
    const cob_field_attr a_literal = {COB_TYPE_NUMERIC_DISPLAY, 1, 1, COB_FLAG_CONSTANT, NULL};
    cob_field fa = field_of(&a, sizeof a, &A_DOUBLE), fb = field_of(&b, sizeof b, &A_DOUBLE), fsum = field_of(&sum, sizeof sum, &A_DOUBLE);
    cob_field f3 = field_of(&three, sizeof three, &A_LONG), fl = field_of(literal, 1, &a_literal), fgot = field_of(&got, sizeof got, &A_DOUBLE);
    cob_field fn_stock = field_of(&n_stock, sizeof n_stock, &A_LONG), fn_fast = field_of(&n_fast, sizeof n_fast, &A_LONG);

    tl_int("fpfast FLOAT-LONG 0.1 compared with FLOAT-LONG 0.2 is -1, as doubles", -1, compare(&FAST, &fa, &fb));
    tl_int("fpfast FLOAT-LONG 0.2 compared with FLOAT-LONG 0.1 is 1", 1, compare(&FAST, &fb, &fa));
    tl_int("fpfast a FLOAT-LONG compared with itself is 0", 0, compare(&FAST, &fsum, &fsum));
    tl_int("fpfast FLOAT-LONG 0.1 + 0.2 compared with the literal 0.3 is libcob's answer", compare(&STOCK, &fsum, &fl), compare(&FAST, &fsum, &fl));
    tl_int("fpfast the literal 0.3 compared with FLOAT-LONG 0.2 is libcob's answer", compare(&STOCK, &fl, &fb), compare(&FAST, &fl, &fb));
    tl_int("fpfast BINARY-LONG 3 compared with FLOAT-LONG 0.1 is libcob's answer", compare(&STOCK, &f3, &fa), compare(&FAST, &f3, &fa));

    /* cob_decimal_align: only emitted with -farithmetic-osvs, which the project does not use; passed on all the same */
    cob_decimal_set_field(&d1, &fb);
    cob_decimal_align(&d1, 4);
    cob_decimal_get_field(&d1, &fn_stock, 0);
    ccfp_decimal_set_field(&d1, &fb);
    ccfp_decimal_align(&d1, 4);
    ccfp_decimal_get_field(&d1, &fn_fast, 0);
    tl_int("fpfast an aligned FLOAT-LONG stored into BINARY-LONG is libcob's", n_stock, n_fast);

    /* a tag left in a decimal by an earlier statement does not survive libcob's own loads */
    ccfp_decimal_set_field(&d1, &fa);
    cob_decimal_set_llint(&d1, 42);
    ccfp_decimal_get_field(&d1, &fn_fast, 0);
    tl_int("fpfast a decimal loaded by cob_decimal_set_llint after a float load holds the integer", 42, n_fast);
    ccfp_decimal_set_field(&d1, &fa);
    ccfp_decimal_set_field(&d1, &f3);
    ccfp_decimal_get_field(&d1, &fgot, 0);
    tl_int("fpfast a decimal loaded from BINARY-LONG after a float load stores 3.0", 1, got == 3.0);
}

/* ---- intrinsic functions ---- */

static const cob_field_attr A_BYTE = {COB_TYPE_NUMERIC_BINARY, 2, 0, COB_FLAG_HAVE_SIGN | COB_FLAG_REAL_BINARY, NULL};
static const cob_field_attr A_UBYTE = {COB_TYPE_NUMERIC_BINARY, 2, 0, COB_FLAG_REAL_BINARY, NULL};
static const cob_field_attr A_SHORT = {COB_TYPE_NUMERIC_BINARY, 4, 0, COB_FLAG_HAVE_SIGN | COB_FLAG_REAL_BINARY, NULL};
static const cob_field_attr A_UQUAD = {COB_TYPE_NUMERIC_BINARY, 18, 0, COB_FLAG_REAL_BINARY, NULL};
static const cob_field_attr A_SWAPPED = {COB_TYPE_NUMERIC_BINARY, 9, 0, COB_FLAG_HAVE_SIGN | COB_FLAG_BINARY_SWAP, NULL};
static const cob_field_attr A_ODD = {COB_TYPE_NUMERIC_BINARY, 7, 0, COB_FLAG_HAVE_SIGN | COB_FLAG_BINARY_SWAP, NULL};
static const cob_field_attr A_DIGITS = {COB_TYPE_NUMERIC_DISPLAY, 18, 0, 0, NULL};
static const cob_field_attr A_LONG_DIGITS = {COB_TYPE_NUMERIC_DISPLAY, 19, 0, 0, NULL};

/* the value of a result field as libcob reads it */
static double double_of_field(cob_field *f) {
    double v = 0.0;
    cob_field target = field_of(&v, sizeof v, &A_DOUBLE);
    cob_decimal_set_field(&d1, f);
    cob_decimal_get_field(&d1, &target, 0);
    return v;
}

/* 1 when both results read as the same number (and the same 64-bit integer) */
static int same_result(cob_field *fast, cob_field *stock) {
    double a = double_of_field(fast), b = double_of_field(stock);
    return a == b && cob_get_llint(fast) == cob_get_llint(stock);
}

static void sine_and_cosine(void) {
    static const double ANGLES[] = {0.0, 0.5, -0.5, 1.0, 3.141592653589793, -2.5, 100.25, 1e-9, 12345.678};
    char name[160];
    double x, inf = INFINITY;
    float xs = 0.75f;
    int32_t three = 3;
    unsigned char dec[] = "000015000"; /* 1.5 as PIC 9(5)V9(4) */
    cob_field fx = field_of(&x, sizeof x, &A_DOUBLE), fs = field_of(&xs, sizeof xs, &A_FLOAT);
    cob_field f3 = field_of(&three, sizeof three, &A_LONG), fd = field_of(dec, 9, &A_DEC);
    cob_field finf = field_of(&inf, sizeof inf, &A_DOUBLE), *r;

    for (size_t i = 0; i < sizeof ANGLES / sizeof ANGLES[0]; i++) {
        double want;
        x = ANGLES[i];
        r = ccfp_intr_sin(&fx);
        want = sin(x) + 0.0;
        snprintf(name, sizeof name, "fpfast FUNCTION SIN(%.17g) is the C double sin", x);
        tl_bytes(name, &want, sizeof want, r->data, r->size);
        snprintf(name, sizeof name, "fpfast FUNCTION SIN(%.17g) is libcob's within 1e-15", x);
        tl_int(name, 1, fabs(double_of_field(r) - double_of_field(cob_intr_sin(&fx))) <= 1e-15);
        r = ccfp_intr_cos(&fx);
        want = cos(x) + 0.0;
        snprintf(name, sizeof name, "fpfast FUNCTION COS(%.17g) is the C double cos", x);
        tl_bytes(name, &want, sizeof want, r->data, r->size);
        snprintf(name, sizeof name, "fpfast FUNCTION COS(%.17g) is libcob's within 1e-15", x);
        tl_int(name, 1, fabs(double_of_field(r) - double_of_field(cob_intr_cos(&fx))) <= 1e-15);
    }
    for (size_t i = 0; i < sizeof ANGLES / sizeof ANGLES[0]; i++) {
        double want;
        x = ANGLES[i] * ANGLES[i];
        r = ccfp_intr_sqrt(&fx);
        want = fabs(ANGLES[i]);
        snprintf(name, sizeof name, "fpfast FUNCTION SQRT of the C double square of %.17g is its magnitude", ANGLES[i]);
        tl_bytes(name, &want, sizeof want, r->data, r->size);
        snprintf(name, sizeof name, "fpfast FUNCTION SQRT(%.17g) is libcob's within 1e-12", x);
        tl_int(name, 1, fabs(double_of_field(r) - double_of_field(cob_intr_sqrt(&fx))) <= 1e-12);
    }
    x = -4.0;
    tl_int("fpfast FUNCTION SQRT of a negative float is libcob's", 1, same_result(ccfp_intr_sqrt(&fx), cob_intr_sqrt(&fx)));
    tl_int("fpfast FUNCTION SQRT of a decimal 1.5 is libcob's", 1, same_result(ccfp_intr_sqrt(&fd), cob_intr_sqrt(&fd)));
    tl_int("fpfast FUNCTION SIN of a FLOAT-SHORT is the C double sin of it", 1,
           double_of_field(ccfp_intr_sin(&fs)) == sin((double)xs));
    tl_int("fpfast FUNCTION COS of a BINARY-LONG 3 is the C double cos(3.0)", 1, double_of_field(ccfp_intr_cos(&f3)) == cos(3.0));
    tl_int("fpfast FUNCTION SIN of a decimal 1.5 is libcob's", 1, same_result(ccfp_intr_sin(&fd), cob_intr_sin(&fd)));
    tl_int("fpfast FUNCTION COS of a decimal 1.5 is libcob's", 1, same_result(ccfp_intr_cos(&fd), cob_intr_cos(&fd)));
    tl_int("fpfast FUNCTION SIN of an infinite float is libcob's", 1, same_result(ccfp_intr_sin(&finf), cob_intr_sin(&finf)));
    tl_int("fpfast FUNCTION COS of an infinite float is libcob's", 1, same_result(ccfp_intr_cos(&finf), cob_intr_cos(&finf)));
}

static void integer_mod(void) {
    static const int64_t VALUES[] = {0, 1, -1, 7, -7, 16, -16, 1681, 123456789, -123456789, INT64_MAX, INT64_MIN + 1};
    char name[160];
    int64_t a, b;
    int8_t byte = -5;
    uint8_t ubyte = 250;
    int16_t word = -300;
    uint64_t huge = 18446744073709551615ULL, small = 40;
    unsigned char swapped[4] = {0xFF, 0xFF, 0xFF, 0xF0}; /* -16, big-endian */
    unsigned char odd[3] = {0, 0, 9};
    unsigned char digits[] = "000000000000001234", spaced[] = "12 4", long_digits[] = "1000000000000000000";
    unsigned char dec[] = "000015000";
    int32_t sixteen = 16;
    cob_field fa = field_of(&a, sizeof a, &A_QUAD), fb = field_of(&b, sizeof b, &A_QUAD);
    cob_field f16 = field_of(&sixteen, sizeof sixteen, &A_LONG);
    cob_field others[] = {
        field_of(&byte, 1, &A_BYTE),       field_of(&ubyte, 1, &A_UBYTE),         field_of(&word, 2, &A_SHORT),
        field_of(&huge, 8, &A_UQUAD),      field_of(&small, 8, &A_UQUAD),         field_of(swapped, 4, &A_SWAPPED),
        field_of(odd, 3, &A_ODD),          field_of(digits, 18, &A_DIGITS),       field_of(spaced, 4, &A_DIGITS),
        field_of(long_digits, 19, &A_LONG_DIGITS), field_of(dec, 9, &A_DEC),
    };
    static const char *const OTHER_NAMES[] = {
        "a signed byte -5", "an unsigned byte 250", "a signed 2-byte -300", "an unsigned 8-byte 2^64 - 1", "an unsigned 8-byte 40",
        "a big-endian 4-byte -16", "a 3-byte binary 9", "18 display digits 1234", "display digits with a space", "19 display digits",
        "a decimal 1.5",
    };

    for (size_t i = 0; i < sizeof VALUES / sizeof VALUES[0]; i++) {
        for (size_t j = 0; j < sizeof VALUES / sizeof VALUES[0]; j++) {
            a = VALUES[i];
            b = VALUES[j];
            snprintf(name, sizeof name, "fpfast FUNCTION MOD(%lld, %lld) is libcob's", (long long)a, (long long)b);
            tl_int(name, 1, same_result(ccfp_intr_mod(&fa, &fb), cob_intr_mod(&fa, &fb)));
        }
    }
    for (size_t i = 0; i < sizeof others / sizeof others[0]; i++) {
        snprintf(name, sizeof name, "fpfast FUNCTION MOD(%s, 16) is libcob's", OTHER_NAMES[i]);
        tl_int(name, 1, same_result(ccfp_intr_mod(&others[i], &f16), cob_intr_mod(&others[i], &f16)));
        snprintf(name, sizeof name, "fpfast FUNCTION MOD(16, %s) is libcob's", OTHER_NAMES[i]);
        tl_int(name, 1, same_result(ccfp_intr_mod(&f16, &others[i]), cob_intr_mod(&f16, &others[i])));
    }
    a = -7;
    tl_int("fpfast FUNCTION MOD(-7, 16) is 9", 9, (int)cob_get_llint(ccfp_intr_mod(&fa, &f16)));
}

static void argument_arithmetic(void) {
    static const int64_t INTEGERS[] = {0, 1, -1, 6, -6, 3, 1000000007, INT64_MAX, INT64_MIN, 9007199254740992LL, 4611686018427387904LL};
    static const double DOUBLES[] = {0.0, 0.1, -0.1, 2.5, 1e308, -1e308, 3.0, 1e-300};
    static const char OPERATORS[] = "+-*/^a";
    char name[160];
    int64_t a, b;
    double x, y;
    float xs = 0.75f;
    cob_field fa = field_of(&a, sizeof a, &A_QUAD), fb = field_of(&b, sizeof b, &A_QUAD);
    cob_field fx = field_of(&x, sizeof x, &A_DOUBLE), fy = field_of(&y, sizeof y, &A_DOUBLE);
    cob_field fs = field_of(&xs, sizeof xs, &A_FLOAT), *r;

    for (size_t i = 0; i < sizeof INTEGERS / sizeof INTEGERS[0]; i++) {
        for (size_t j = 0; j < sizeof INTEGERS / sizeof INTEGERS[0]; j++) {
            for (const char *op = OPERATORS; *op; op++) {
                a = INTEGERS[i];
                b = INTEGERS[j];
                if ((*op == '^' && (b > 6 || b < -6 || a > 1000000007 || a < -6)) || (*op == 'a' && (a < 0 || b < 0 || a > 6 || b > 6))) {
                    continue; /* libcob's own power of huge numbers and bit operations of wide ones are not the subject */
                }
                snprintf(name, sizeof name, "fpfast %lld %c %lld inside a function argument is libcob's", (long long)a, *op, (long long)b);
                tl_int(name, 1, same_result(ccfp_intr_binop(&fa, *op, &fb), cob_intr_binop(&fa, *op, &fb)));
            }
        }
    }
    for (size_t i = 0; i < sizeof DOUBLES / sizeof DOUBLES[0]; i++) {
        for (size_t j = 0; j < sizeof DOUBLES / sizeof DOUBLES[0]; j++) {
            for (const char *op = "+-*/"; *op; op++) {
                double want, got;
                x = DOUBLES[i];
                y = DOUBLES[j];
                want = *op == '+' ? x + y : *op == '-' ? x - y : *op == '*' ? x * y : x / y;
                r = ccfp_intr_binop(&fx, *op, &fy);
                got = double_of_field(r);
                snprintf(name, sizeof name, "fpfast %.17g %c %.17g inside a function argument", x, *op, y);
                if (isfinite(want) && (*op != '/' || y != 0.0)) {
                    want += 0.0;
                    tl_bytes(name, &want, sizeof want, r->data, r->size);
                } else {
                    tl_int(name, 1, got == double_of_field(cob_intr_binop(&fx, *op, &fy)));
                }
            }
        }
    }
    x = 2.0;
    y = 10.0;
    tl_int("fpfast a power of floats inside a function argument is libcob's", 1,
           same_result(ccfp_intr_binop(&fx, '^', &fy), cob_intr_binop(&fx, '^', &fy)));
    a = 4;
    x = 0.1;
    tl_int("fpfast BINARY-DOUBLE 4 * FLOAT-LONG 0.1 inside a function argument is the C double 4.0 * 0.1", 1,
           double_of_field(ccfp_intr_binop(&fa, '*', &fx)) == 4.0 * 0.1);
    tl_int("fpfast FLOAT-SHORT 0.75 - BINARY-DOUBLE 4 inside a function argument is the C double", 1,
           double_of_field(ccfp_intr_binop(&fs, '-', &fa)) == (double)xs - 4.0);
    a = 9007199254740993LL;
    tl_int("fpfast FLOAT-LONG + an integer above 2^53 inside a function argument is libcob's", 1,
           double_of_field(ccfp_intr_binop(&fx, '+', &fa)) == double_of_field(cob_intr_binop(&fx, '+', &fa)));
    a = 1;
    for (int i = 0; i < 200; i++) {
        b = i;
        r = ccfp_intr_binop(&fa, '+', &fb);
    }
    tl_int("fpfast the 200th result in a row is its own value", 200, (int)cob_get_llint(r));
}

int main(void) {
    static cob_module *module;
    static cob_global *global;
    cob_init(0, NULL);
    /* libcob's own intrinsic functions store signed results by the conventions of the running COBOL module */
    cob_module_global_enter(&module, &global, 0, 0, NULL);
    module->decimal_point = '.';
    module->numeric_separator = ',';
    cob_decimal_init(&d1);
    cob_decimal_init(&d2);
    float_to_float();
    exact_decimal_operands();
    decimal_into_float();
    passed_on();
    float_into_other();
    comparisons_and_alignment();
    sine_and_cosine();
    integer_mod();
    argument_arithmetic();
    return 0;
}
