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

/* ---- compares, whole numbers, MOVE and the functions that go with them ---- */

static const cob_field_attr A_TEXT = {COB_TYPE_ALPHANUMERIC, 0, 0, 0, NULL};

static int sign_of(int x) { return x < 0 ? -1 : x > 0; }

/* the bytes and attribute of two results are the same (the attribute decides how a consumer reads the bytes) */
static int same_field(const cob_field *fast, const cob_field *stock) {
    return fast->size == stock->size && COB_FIELD_TYPE(fast) == COB_FIELD_TYPE(stock) &&
           COB_FIELD_DIGITS(fast) == COB_FIELD_DIGITS(stock) && COB_FIELD_SCALE(fast) == COB_FIELD_SCALE(stock) &&
           fast->attr->flags == stock->attr->flags && memcmp(fast->data, stock->data, fast->size) == 0;
}

static uint64_t rng_state = 0x9E3779B97F4A7C15ULL;
static uint64_t next_random(void) {
    rng_state ^= rng_state << 13;
    rng_state ^= rng_state >> 7;
    rng_state ^= rng_state << 17;
    return rng_state;
}

/* a random double of any magnitude: random sign, random exponent from 2^-80 to 2^80, random mantissa, and one in four is cut to an integer */
static double random_double(void) {
    uint64_t r = next_random();
    double v = ldexp((double)(r >> 11) / 9007199254740992.0 + 1.0, (int)(next_random() % 161) - 80);
    if ((r & 3) == 0) {
        v = trunc(v);
    }
    return (r & 4) ? -v : v;
}

static const double SPECIAL_DOUBLES[] = {0.0, -0.0, 0.5, -0.5, 1.0, -1.0, 1.9999999999999998, -1.9999999999999998, 2.9999999999999996, 3.0,
                                         3.0000000000000004, 99.99, -99.99, 127.5, 128.0, -128.0, 255.9, 256.0, 32767.5, 32768.0,
                                         999999999.5, 1e9, 2147483647.5, 2147483648.0, -2147483647.5, -2147483648.0, -2147483648.5,
                                         4294967295.5, 4294967296.0, 1e15, 4503599627370497.0, 9007199254740992.0, 9007199254740994.0,
                                         1e18, -1e18, 3.9e18, 4.1e18, 1e19, 1e300, -1e300, 1e-300, -1e-300, 1e-30, 1.5e-20,
                                         0.1, 0.2, 0.3, 123456.789, -98765.4321, 1.0 / 3.0, 5e-324, INFINITY, -INFINITY, NAN};
#define SPECIAL_COUNT ((int)(sizeof SPECIAL_DOUBLES / sizeof SPECIAL_DOUBLES[0]))

static const int64_t SPECIAL_INTEGERS[] = {0, 1, -1, 2, 3, -3, 16, 100, 2147483647LL, 2147483648LL, -2147483648LL, -2147483649LL, 4294967295LL,
                                           9007199254740991LL, 9007199254740992LL, 9007199254740993LL, -9007199254740993LL, 1000000000000000000LL,
                                           INT64_MAX, INT64_MIN};
#define INTEGER_COUNT ((int)(sizeof SPECIAL_INTEGERS / sizeof SPECIAL_INTEGERS[0]))

/* cob_cmp_llint: a float against an integer is the sign of the exact difference; a zero answers -n, clamped. */
static void compare_with_integer(void) {
    int wrong = 0, done = 0, zero_wrong = 0;
    for (int i = 0; i < SPECIAL_COUNT + 20000; i++) {
        double v = i < SPECIAL_COUNT ? SPECIAL_DOUBLES[i] : random_double();
        float s = (float)v;
        if ((v == 0.0 && signbit(v)) || (s == 0.0f && signbit(s))) {
            continue; /* libcob's decimal of a negative zero is not set: its own answers are not repeatable */
        }
        for (int j = 0; j < INTEGER_COUNT + 6; j++) {
            int64_t n = j < INTEGER_COUNT ? SPECIAL_INTEGERS[j] : (int64_t)(next_random() >> (next_random() % 64)) * (next_random() & 1 ? 1 : -1);
            cob_field fd = field_of(&v, sizeof v, &A_DOUBLE), fs = field_of(&s, sizeof s, &A_FLOAT);
            int want = cob_cmp_llint(&fd, n), got = ccfp_cmp_llint(&fd, n);
            wrong += sign_of(want) != sign_of(got);
            zero_wrong += v == 0.0 && want != got && !signbit(v);
            want = cob_cmp_llint(&fs, n);
            got = ccfp_cmp_llint(&fs, n);
            wrong += sign_of(want) != sign_of(got);
            zero_wrong += s == 0.0f && want != got && !signbit(s);
            done += 2;
            if (i >= SPECIAL_COUNT && j >= 4) {
                break;
            }
        }
    }
    tl_int("fpfast cob_cmp_llint of a float: comparisons made", 1, done > 100000);
    tl_int("fpfast cob_cmp_llint of a float: answers of another sign than libcob's (specials and 20000 random floats)", 0, wrong);
    tl_int("fpfast cob_cmp_llint of a positive zero: answers other than libcob's (-n, clamped to int)", 0, zero_wrong);
}

/* cob_cmp and cob_numeric_cmp of a float and a float, an integer or a DISPLAY number: libcob's answer itself. */
static void compare_fields(void) {
    static const struct { const char *digits; int scale; int sign; } LITERALS[] = {
        {"0", 0, 0},        {"5", 0, 0},          {"05", 1, 0},         {"5", 1, 0},           {"314159", 5, 0},     {"1", 22, 0},
        {"123456789012345", 0, 0}, {"123456789012345", 22, 0}, {"999999999999999", 15, 0}, {"1", 23, 0}, {"0000000000000001", 0, 0},
        {"05", 1, 1},       {"5", 1, 1},          {"314159", 5, 1},     {"0", 2, 1},          {"1", 3, 1}, {"1", 20, 1},
        {"1234567", 3, 0},  {"3", 1, 0},          {"1", 1, 0},          {"2", 1, 0},           {"7", 0, 1},
    };
    static const double BASES[] = {0.0, 0.5, -0.5, 0.1, 0.2, 0.3, 5.0, -5.0, 3.14159, 1e-22, 1234.567, 123456789012345.0, 7.0, -7.0, 1e-7, 1.0000001};
    int wrong = 0, done = 0, wrong_numeric = 0;
    for (size_t k = 0; k < sizeof LITERALS / sizeof LITERALS[0]; k++) {
        unsigned char text[24];
        size_t length = strlen(LITERALS[k].digits);
        cob_field_attr attr = {COB_TYPE_NUMERIC_DISPLAY, (unsigned short)length, (short)LITERALS[k].scale, COB_FLAG_CONSTANT, NULL};
        if (LITERALS[k].sign) {
            attr.flags |= COB_FLAG_HAVE_SIGN | COB_FLAG_SIGN_SEPARATE | COB_FLAG_SIGN_LEADING;
            text[0] = '-';
            memcpy(text + 1, LITERALS[k].digits, length);
            length++;
        } else {
            memcpy(text, LITERALS[k].digits, length);
        }
        cob_field fl = field_of(text, length, &attr);
        for (size_t b = 0; b < sizeof BASES / sizeof BASES[0]; b++) {
            for (int step = -2; step <= 2; step++) {
                double v = BASES[b];
                float s = (float)v;
                for (int i = 0; i < step; i++) {
                    v = nextafter(v, INFINITY);
                }
                for (int i = 0; i > step; i--) {
                    v = nextafter(v, -INFINITY);
                }
                cob_field fd = field_of(&v, sizeof v, &A_DOUBLE), fs = field_of(&s, sizeof s, &A_FLOAT);
                wrong += cob_cmp(&fd, &fl) != ccfp_cmp(&fd, &fl) || cob_cmp(&fl, &fd) != ccfp_cmp(&fl, &fd) ||
                         cob_cmp(&fs, &fl) != ccfp_cmp(&fs, &fl) || cob_cmp(&fl, &fs) != ccfp_cmp(&fl, &fs);
                wrong_numeric += cob_numeric_cmp(&fd, &fl) != ccfp_numeric_cmp(&fd, &fl) || cob_numeric_cmp(&fl, &fs) != ccfp_numeric_cmp(&fl, &fs);
                done += 8;
            }
        }
    }
    /* floats against floats and integers, including the values libcob reads as they are (NaN, infinity, -0.0) */
    for (int i = 0; i < SPECIAL_COUNT; i++) {
        for (int j = 0; j < SPECIAL_COUNT; j++) {
            double a = SPECIAL_DOUBLES[i], b = SPECIAL_DOUBLES[j];
            float c = (float)a;
            cob_field fa = field_of(&a, sizeof a, &A_DOUBLE), fb = field_of(&b, sizeof b, &A_DOUBLE), fc = field_of(&c, sizeof c, &A_FLOAT);
            wrong += cob_cmp(&fa, &fb) != ccfp_cmp(&fa, &fb) || cob_cmp(&fc, &fb) != ccfp_cmp(&fc, &fb) || cob_cmp(&fa, &fc) != ccfp_cmp(&fa, &fc);
            wrong_numeric += cob_numeric_cmp(&fa, &fb) != ccfp_numeric_cmp(&fa, &fb);
            done += 4;
        }
    }
    for (int i = 0; i < SPECIAL_COUNT; i++) {
        for (int j = 0; j < INTEGER_COUNT; j++) {
            double a = SPECIAL_DOUBLES[i];
            int64_t n = SPECIAL_INTEGERS[j];
            int32_t small = (int32_t)n;
            cob_field fa = field_of(&a, sizeof a, &A_DOUBLE), fn = field_of(&n, sizeof n, &A_QUAD), fsmall = field_of(&small, sizeof small, &A_LONG);
            wrong += cob_cmp(&fa, &fn) != ccfp_cmp(&fa, &fn) || cob_cmp(&fn, &fa) != ccfp_cmp(&fn, &fa) ||
                     cob_cmp(&fa, &fsmall) != ccfp_cmp(&fa, &fsmall) || cob_cmp(&fsmall, &fa) != ccfp_cmp(&fsmall, &fa);
            done += 4;
        }
    }
    /* what is not a float at all, and what is not a number */
    unsigned char t1[] = "abc", t2[] = "abd", d1x[] = "0123", d2x[] = "0124";
    cob_field fa1 = field_of(t1, 3, &A_TEXT), fa2 = field_of(t2, 3, &A_TEXT);
    cob_field_attr a4 = {COB_TYPE_NUMERIC_DISPLAY, 4, 0, 0, NULL};
    cob_field fd1 = field_of(d1x, 4, &a4), fd2 = field_of(d2x, 4, &a4);
    wrong += cob_cmp(&fa1, &fa2) != ccfp_cmp(&fa1, &fa2) || cob_cmp(&fd1, &fd2) != ccfp_cmp(&fd1, &fd2);
    wrong_numeric += cob_numeric_cmp(&fd2, &fd1) != ccfp_numeric_cmp(&fd2, &fd1);
    /* fields that are no float, integer or plain DISPLAY number: libcob's compare */
    {
        unsigned char packed[3] = {0x01, 0x23, 0x0C}, signed_trailing[] = "0123", spaced[] = "12 4", bad_sign[] = "x5", lone_sign[] = "-", scaled_down[] = "123";
        int32_t cents = 12345;
        const cob_field_attr a_packed = {COB_TYPE_NUMERIC_PACKED, 5, 0, COB_FLAG_HAVE_SIGN, NULL};
        const cob_field_attr a_cents = {COB_TYPE_NUMERIC_BINARY, 9, 2, COB_FLAG_HAVE_SIGN | COB_FLAG_REAL_BINARY, NULL};
        const cob_field_attr a_signed_trailing = {COB_TYPE_NUMERIC_DISPLAY, 4, 0, COB_FLAG_HAVE_SIGN, NULL};
        const cob_field_attr a_spaced = {COB_TYPE_NUMERIC_DISPLAY, 4, 0, 0, NULL};
        const cob_field_attr a_leading = {COB_TYPE_NUMERIC_DISPLAY, 1, 0, COB_FLAG_HAVE_SIGN | COB_FLAG_SIGN_SEPARATE | COB_FLAG_SIGN_LEADING, NULL};
        const cob_field_attr a_pad = {COB_TYPE_NUMERIC_DISPLAY, 3, -2, 0, NULL};
        cob_field odd[] = {field_of(packed, 3, &a_packed), field_of(&cents, 4, &a_cents), field_of(signed_trailing, 4, &a_signed_trailing),
                           field_of(spaced, 4, &a_spaced), field_of(bad_sign, 2, &a_leading), field_of(lone_sign, 1, &a_leading),
                           field_of(scaled_down, 3, &a_pad)};
        double v = 123.0;
        cob_field fv = field_of(&v, sizeof v, &A_DOUBLE);
        for (size_t i = 0; i < sizeof odd / sizeof odd[0]; i++) {
            wrong += cob_cmp(&fv, &odd[i]) != ccfp_cmp(&fv, &odd[i]) || cob_cmp(&odd[i], &fv) != ccfp_cmp(&odd[i], &fv);
            done += 2;
        }
    }
    tl_int("fpfast cob_cmp: comparisons made", 1, done > 2000);
    tl_int("fpfast cob_cmp of a float with a float, an integer or a DISPLAY number: answers other than libcob's", 0, wrong);
    tl_int("fpfast cob_numeric_cmp of a float with a float, an integer or a DISPLAY number: answers other than libcob's", 0, wrong_numeric);
}

/* One conversion of a float into a field through both sets of functions (a load and a store, no arithmetic: the store is
 * what is taken over): the same stored bytes and return value. */
static void same_store(const char *name, cob_field *target, cob_field *source, int opt) {
    unsigned char stock[32], fast[32];
    char label[200];
    memset(target->data, 0x5A, target->size);
    STOCK.set(&d1, source);
    int stock_status = STOCK.get(&d1, target, opt);
    memcpy(stock, target->data, target->size);
    memset(target->data, 0x5A, target->size);
    FAST.set(&d1, source);
    int fast_status = FAST.get(&d1, target, opt);
    memcpy(fast, target->data, target->size);
    snprintf(label, sizeof label, "%s: stored bytes", name);
    tl_bytes(label, stock, target->size, fast, target->size);
    snprintf(label, sizeof label, "%s: return value", name);
    tl_int(label, stock_status, fast_status);
}

/* A float stored into a binary integer field: libcob's own store (the integer part, the digits and bytes of the field,
 * ROUNDED, ON SIZE ERROR), whatever the value. */
static void float_into_integer(void) {
    static const int OPTS[] = {0, COB_STORE_KEEP_ON_OVERFLOW, COB_STORE_TRUNC_ON_OVERFLOW, COB_STORE_KEEP_ON_OVERFLOW | COB_STORE_TRUNC_ON_OVERFLOW,
                               COB_STORE_ROUND, COB_STORE_NO_SIZE_ERROR, COB_STORE_TRUNC_ON_OVERFLOW | COB_STORE_NO_SIZE_ERROR};
    static const cob_field_attr A_CHAR_TRUNC = {COB_TYPE_NUMERIC_BINARY, 3, 0, COB_FLAG_HAVE_SIGN | COB_FLAG_BINARY_TRUNC, NULL};
    static const cob_field_attr A_SCALED_BINARY = {COB_TYPE_NUMERIC_BINARY, 9, 2, COB_FLAG_HAVE_SIGN | COB_FLAG_REAL_BINARY, NULL};
    static const cob_field_attr A_COMP5 = {COB_TYPE_NUMERIC_COMP5, 9, 0, COB_FLAG_HAVE_SIGN | COB_FLAG_REAL_BINARY, NULL};
    unsigned char bytes[8];
    int wrong = 0, done = 0;
    const struct { const char *name; size_t size; const cob_field_attr *attr; } TARGETS[] = {
        {"BINARY-LONG", 4, &A_LONG},       {"BINARY-DOUBLE", 8, &A_QUAD},      {"a signed byte of 2 digits", 1, &A_BYTE},
        {"an unsigned byte", 1, &A_UBYTE}, {"a signed 2-byte of 4 digits", 2, &A_SHORT}, {"an unsigned 8-byte", 8, &A_UQUAD},
        {"a big-endian 4-byte", 4, &A_SWAPPED}, {"BINARY-CHAR with binary-truncate", 1, &A_CHAR_TRUNC},
        {"a binary with 2 decimals", 4, &A_SCALED_BINARY}, {"COMP-5", 4, &A_COMP5},
    };
    for (size_t t = 0; t < sizeof TARGETS / sizeof TARGETS[0]; t++) {
        cob_field target = field_of(bytes, TARGETS[t].size, TARGETS[t].attr);
        for (int i = 0; i < SPECIAL_COUNT + 3000; i++) {
            double v = i < SPECIAL_COUNT ? SPECIAL_DOUBLES[i] : random_double();
            float s = (float)v;
            cob_field fd = field_of(&v, sizeof v, &A_DOUBLE), fs = field_of(&s, sizeof s, &A_FLOAT);
            if ((v == 0.0 && signbit(v)) || (s == 0.0f && signbit(s))) {
                continue; /* libcob's decimal of a negative zero is not set (see float_into_integer's last cases) */
            }
            for (size_t o = 0; o < sizeof OPTS / sizeof OPTS[0]; o++) {
                unsigned char stock[8], fast[8];
                int stock_status, fast_status;
                for (int k = 0; k < 2; k++) {
                    cob_field *source = k ? &fs : &fd;
                    memset(bytes, 0x5A, sizeof bytes);
                    STOCK.set(&d1, source);
                    stock_status = STOCK.get(&d1, &target, OPTS[o]);
                    memcpy(stock, bytes, sizeof bytes);
                    memset(bytes, 0x5A, sizeof bytes);
                    FAST.set(&d1, source);
                    fast_status = FAST.get(&d1, &target, OPTS[o]);
                    memcpy(fast, bytes, sizeof bytes);
                    wrong += memcmp(stock, fast, sizeof stock) != 0 || stock_status != fast_status;
                    done++;
                    if (i >= SPECIAL_COUNT && o > 1) {
                        break;
                    }
                }
            }
        }
    }
    tl_int("fpfast a float into a binary integer: stores made", 1, done > 100000);
    tl_int("fpfast a float into a binary integer (10 field kinds, 7 option sets, specials and random): stores that are not libcob's, bytes or status", 0, wrong);
    {
        double v = 3.99;
        int32_t n = 0;
        cob_field fd = field_of(&v, sizeof v, &A_DOUBLE), fn = field_of(&n, sizeof n, &A_LONG);
        same_store("fpfast 3.99 into BINARY-LONG", &fn, &fd, 0);
        tl_int("fpfast 3.99 into BINARY-LONG is 3 (cut, not rounded)", 3, n);
        v = -3.99;
        same_store("fpfast -3.99 into BINARY-LONG", &fn, &fd, 0);
        tl_int("fpfast -3.99 into BINARY-LONG is -3", -3, n);
        v = 3.5;
        same_store("fpfast 3.5 into BINARY-LONG ROUNDED", &fn, &fd, COB_STORE_ROUND);
        tl_int("fpfast 3.5 into BINARY-LONG ROUNDED is libcob's 4", 4, n);
    }
}

/* cob_get_int and cob_get_llint of binary fields and of whatever else: libcob's value. */
static void get_integers(void) {
    int wrong = 0;
    unsigned char display[] = "1234";
    cob_field_attr a4 = {COB_TYPE_NUMERIC_DISPLAY, 4, 0, 0, NULL};
    int8_t byte = -5;
    uint8_t ubyte = 250;
    int16_t word = -300;
    int32_t scaled = 12345;
    uint64_t huge = 18446744073709551615ULL;
    unsigned char swapped[4] = {0xFF, 0xFF, 0xFF, 0xF0};
    const cob_field_attr a_scaled = {COB_TYPE_NUMERIC_BINARY, 9, 2, COB_FLAG_HAVE_SIGN | COB_FLAG_REAL_BINARY, NULL};
    cob_field fixed[] = {field_of(&byte, 1, &A_BYTE), field_of(&ubyte, 1, &A_UBYTE), field_of(&word, 2, &A_SHORT), field_of(&scaled, 4, &a_scaled),
                         field_of(&huge, 8, &A_UQUAD), field_of(swapped, 4, &A_SWAPPED), field_of(display, 4, &a4)};
    for (size_t i = 0; i < sizeof fixed / sizeof fixed[0]; i++) {
        wrong += cob_get_int(&fixed[i]) != ccfp_get_int(&fixed[i]) || cob_get_llint(&fixed[i]) != ccfp_get_llint(&fixed[i]);
    }
    for (int i = 0; i < INTEGER_COUNT; i++) {
        int64_t n = SPECIAL_INTEGERS[i];
        int32_t k = (int32_t)n;
        cob_field fq = field_of(&n, sizeof n, &A_QUAD), fk = field_of(&k, sizeof k, &A_LONG);
        wrong += cob_get_int(&fq) != ccfp_get_int(&fq) || cob_get_llint(&fq) != ccfp_get_llint(&fq);
        wrong += cob_get_int(&fk) != ccfp_get_int(&fk) || cob_get_llint(&fk) != ccfp_get_llint(&fk);
    }
    for (int i = 0; i < SPECIAL_COUNT; i++) {
        double v = SPECIAL_DOUBLES[i];
        if (fabs(v) < 1e15 && !(v == 0.0 && signbit(v))) {
            cob_field fd = field_of(&v, sizeof v, &A_DOUBLE);
            wrong += cob_get_int(&fd) != ccfp_get_int(&fd) || cob_get_llint(&fd) != ccfp_get_llint(&fd);
        }
    }
    tl_int("fpfast cob_get_int and cob_get_llint: values other than libcob's", 0, wrong);
}

static const char *const PIC_SOURCES[] = {"0", "5", "05", "123456789012345", "0000000000000001", "314159", "999999999999999", "1", "7", "10", "250"};

/* MOVE of a number into a float field, and of a float into a binary integer field: cob_move's own result bytes. */
static void move_numbers(void) {
    int wrong = 0, done = 0;
    unsigned char out_stock[16], out_fast[16];
    static const cob_field_attr A_COMP5 = {COB_TYPE_NUMERIC_COMP5, 9, 0, COB_FLAG_HAVE_SIGN | COB_FLAG_REAL_BINARY, NULL};
    static const cob_field_attr A_CHAR_TRUNC = {COB_TYPE_NUMERIC_BINARY, 3, 0, COB_FLAG_HAVE_SIGN | COB_FLAG_BINARY_TRUNC, NULL};
    const struct { size_t size; const cob_field_attr *attr; } TARGETS[] = {
        {8, &A_DOUBLE}, {4, &A_FLOAT}, {4, &A_LONG}, {8, &A_QUAD}, {1, &A_BYTE}, {1, &A_UBYTE}, {2, &A_SHORT}, {8, &A_UQUAD},
        {4, &A_SWAPPED}, {4, &A_COMP5}, {1, &A_CHAR_TRUNC}, {9, &A_DEC}, {3, &A_SCALED},
    };
    /* DISPLAY literals (unsigned and signed, scale 0 to 22, up to 15 digits and over), exhaustively over a table and at random */
    for (int i = 0; i < 40 + 30000; i++) {
        unsigned char text[24];
        size_t length;
        int scale, sign;
        if (i < 40) {
            const char *digits = PIC_SOURCES[i % (sizeof PIC_SOURCES / sizeof PIC_SOURCES[0])];
            length = strlen(digits);
            memcpy(text, digits, length);
            scale = (i / 11) * 3 % 24;
            sign = (i / 4) & 1;
        } else {
            length = 1 + next_random() % 16;
            for (size_t k = 0; k < length; k++) {
                text[k] = (unsigned char)('0' + next_random() % 10);
            }
            scale = (int)(next_random() % 24);
            sign = (int)(next_random() & 1);
        }
        unsigned char signed_text[24];
        cob_field_attr attr = {COB_TYPE_NUMERIC_DISPLAY, (unsigned short)length, (short)scale, COB_FLAG_CONSTANT, NULL};
        cob_field fl = field_of(text, length, &attr);
        if (sign) {
            signed_text[0] = (unsigned char)(next_random() & 8 ? '-' : '+');
            memcpy(signed_text + 1, text, length);
            attr.flags |= COB_FLAG_HAVE_SIGN | COB_FLAG_SIGN_SEPARATE | COB_FLAG_SIGN_LEADING;
            fl = field_of(signed_text, length + 1, &attr);
        }
        for (size_t t = 0; t < 4; t++) {
            cob_field target = field_of(out_stock, TARGETS[t].size, TARGETS[t].attr);
            memset(out_stock, 0x5A, sizeof out_stock);
            cob_move(&fl, &target);
            memcpy(out_fast, out_stock, sizeof out_fast);
            memset(out_stock, 0x5A, sizeof out_stock);
            target.data = out_stock;
            ccfp_move(&fl, &target);
            wrong += memcmp(out_stock, out_fast, sizeof out_stock) != 0;
            done++;
        }
    }
    /* binary integers into a float; floats into every kind of target; a float into a float */
    for (int i = 0; i < INTEGER_COUNT + 5000; i++) {
        int64_t n = i < INTEGER_COUNT ? SPECIAL_INTEGERS[i] : (int64_t)(next_random() >> (next_random() % 64)) * (next_random() & 1 ? 1 : -1);
        int32_t k = (int32_t)n;
        cob_field fq = field_of(&n, sizeof n, &A_QUAD), fk = field_of(&k, sizeof k, &A_LONG);
        for (size_t t = 0; t < sizeof TARGETS / sizeof TARGETS[0]; t++) {
            cob_field target = field_of(out_stock, TARGETS[t].size, TARGETS[t].attr);
            cob_field *sources[2] = {&fq, &fk};
            for (int w = 0; w < 2; w++) {
                memset(out_stock, 0x5A, sizeof out_stock);
                cob_move(sources[w], &target);
                memcpy(out_fast, out_stock, sizeof out_fast);
                memset(out_stock, 0x5A, sizeof out_stock);
                ccfp_move(sources[w], &target);
                wrong += memcmp(out_stock, out_fast, sizeof out_stock) != 0;
                done++;
            }
        }
    }
    for (int i = 0; i < SPECIAL_COUNT + 3000; i++) {
        double v = i < SPECIAL_COUNT ? SPECIAL_DOUBLES[i] : random_double();
        float s = (float)v;
        cob_field fd = field_of(&v, sizeof v, &A_DOUBLE), fs = field_of(&s, sizeof s, &A_FLOAT);
        if ((v == 0.0 && signbit(v)) || (s == 0.0f && signbit(s))) {
            continue; /* libcob's decimal of a negative zero is not set */
        }
        for (size_t t = 0; t < sizeof TARGETS / sizeof TARGETS[0]; t++) {
            cob_field target = field_of(out_stock, TARGETS[t].size, TARGETS[t].attr);
            cob_field *sources[2] = {&fd, &fs};
            for (int w = 0; w < 2; w++) {
                memset(out_stock, 0x5A, sizeof out_stock);
                cob_move(sources[w], &target);
                memcpy(out_fast, out_stock, sizeof out_fast);
                memset(out_stock, 0x5A, sizeof out_stock);
                ccfp_move(sources[w], &target);
                wrong += memcmp(out_stock, out_fast, sizeof out_stock) != 0;
                done++;
            }
        }
    }
    /* an alphanumeric move is libcob's */
    unsigned char from[] = "hello", to_stock[8] = "xxxxxxx", to_fast[8] = "xxxxxxx";
    cob_field ffrom = field_of(from, 5, &A_TEXT), tstock = field_of(to_stock, 7, &A_TEXT), tfast = field_of(to_fast, 7, &A_TEXT);
    cob_move(&ffrom, &tstock);
    ccfp_move(&ffrom, &tfast);
    wrong += memcmp(to_stock, to_fast, 8) != 0;
    tl_int("fpfast MOVE: moves made", 1, done > 100000);
    tl_int("fpfast MOVE of a DISPLAY number or binary integer into a float, of a float into a binary integer, and the rest: results other than cob_move's", 0, wrong);
}

/* FUNCTION INTEGER and INTEGER-PART: libcob's result, attribute and bytes. */
static void whole_numbers(void) {
    int wrong_integer = 0, wrong_part = 0, done = 0;
    for (int i = 0; i < SPECIAL_COUNT + 20000; i++) {
        double v = i < SPECIAL_COUNT ? SPECIAL_DOUBLES[i] : random_double();
        float s = (float)v;
        cob_field fd = field_of(&v, sizeof v, &A_DOUBLE), fs = field_of(&s, sizeof s, &A_FLOAT);
        cob_field *sources[2] = {&fd, &fs};
        if ((v == 0.0 && signbit(v)) || (s == 0.0f && signbit(s))) {
            continue; /* libcob's decimal of a negative zero is not set */
        }
        for (int w = 0; w < 2; w++) {
            {
                cob_field *fast = ccfp_intr_integer(sources[w]);
                unsigned char fast_bytes[512];
                cob_field fast_copy = *fast;
                memcpy(fast_bytes, fast->data, fast->size);
                fast_copy.data = fast_bytes;
                cob_field_attr attr = *fast->attr;
                fast_copy.attr = &attr;
                wrong_integer += !same_field(&fast_copy, cob_intr_integer(sources[w]));
                fast = ccfp_intr_integer_part(sources[w]);
                memcpy(fast_bytes, fast->data, fast->size);
                fast_copy = *fast;
                fast_copy.data = fast_bytes;
                attr = *fast->attr;
                fast_copy.attr = &attr;
                wrong_part += !same_field(&fast_copy, cob_intr_integer_part(sources[w]));
                done++;
            }
        }
    }
    for (int i = 0; i < INTEGER_COUNT; i++) {
        int64_t n = SPECIAL_INTEGERS[i];
        int32_t k = (int32_t)n;
        cob_field fq = field_of(&n, sizeof n, &A_QUAD), fk = field_of(&k, sizeof k, &A_LONG);
        cob_field *sources[2] = {&fq, &fk};
        for (int w = 0; w < 2; w++) {
            cob_field *fast = ccfp_intr_integer(sources[w]);
            unsigned char fast_bytes[512];
            cob_field fast_copy = *fast;
            cob_field_attr attr = *fast->attr;
            memcpy(fast_bytes, fast->data, fast->size);
            fast_copy.data = fast_bytes;
            fast_copy.attr = &attr;
            wrong_integer += !same_field(&fast_copy, cob_intr_integer(sources[w]));
            fast = ccfp_intr_integer_part(sources[w]);
            fast_copy = *fast;
            attr = *fast->attr;
            memcpy(fast_bytes, fast->data, fast->size);
            fast_copy.data = fast_bytes;
            fast_copy.attr = &attr;
            wrong_part += !same_field(&fast_copy, cob_intr_integer_part(sources[w]));
            done++;
        }
    }
    unsigned char display[] = "1234", scaled[] = "12345";
    cob_field_attr a4 = {COB_TYPE_NUMERIC_DISPLAY, 4, 0, 0, NULL}, a5 = {COB_TYPE_NUMERIC_DISPLAY, 5, 2, 0, NULL};
    cob_field fdisplay = field_of(display, 4, &a4), fscaled = field_of(scaled, 5, &a5);
    wrong_integer += !same_field(ccfp_intr_integer(&fdisplay), cob_intr_integer(&fdisplay)) || !same_field(ccfp_intr_integer(&fscaled), cob_intr_integer(&fscaled));
    wrong_part += !same_field(ccfp_intr_integer_part(&fscaled), cob_intr_integer_part(&fscaled));
    tl_int("fpfast FUNCTION INTEGER and INTEGER-PART: calls made", 1, done > 30000);
    tl_int("fpfast FUNCTION INTEGER (floor): results of another size, attribute or bytes than libcob's", 0, wrong_integer);
    tl_int("fpfast FUNCTION INTEGER-PART (toward zero): results of another size, attribute or bytes than libcob's", 0, wrong_part);
    {
        double v = -2.5;
        cob_field fd = field_of(&v, sizeof v, &A_DOUBLE);
        tl_int("fpfast FUNCTION INTEGER(-2.5) is -3", -3, (int)cob_get_llint(ccfp_intr_integer(&fd)));
        tl_int("fpfast FUNCTION INTEGER-PART(-2.5) is -2", -2, (int)cob_get_llint(ccfp_intr_integer_part(&fd)));
    }
}

/* FUNCTION ABS of a float: libcob's result (copy of the argument's attribute); every other argument is libcob's. */
static void absolute_values(void) {
    int wrong = 0, done = 0;
    for (int i = 0; i < SPECIAL_COUNT + 40000; i++) {
        double v = i < SPECIAL_COUNT ? SPECIAL_DOUBLES[i] : random_double();
        if (i >= SPECIAL_COUNT && i % 4 == 0) {
            v = ldexp(v, -(int)(next_random() % 400)); /* small ones: the exact-decimal limit is crossed */
        }
        float s = (float)v;
        cob_field fd = field_of(&v, sizeof v, &A_DOUBLE), fs = field_of(&s, sizeof s, &A_FLOAT);
        cob_field *sources[2] = {&fd, &fs};
        if ((v == 0.0 && signbit(v)) || (s == 0.0f && signbit(s))) {
            continue; /* libcob's decimal of a negative zero is not set */
        }
        for (int w = 0; w < 2; w++) {
            cob_field *fast = ccfp_intr_abs(sources[w]);
            unsigned char fast_bytes[512];
            cob_field fast_copy = *fast;
            cob_field_attr attr = *fast->attr;
            memcpy(fast_bytes, fast->data, fast->size);
            fast_copy.data = fast_bytes;
            fast_copy.attr = &attr;
            cob_field *stock = cob_intr_abs(sources[w]);
            wrong += !same_field(&fast_copy, stock);
            done++;
        }
    }
    int32_t k = -7;
    cob_field fk = field_of(&k, sizeof k, &A_LONG);
    wrong += !same_field(ccfp_intr_abs(&fk), cob_intr_abs(&fk));
    tl_int("fpfast FUNCTION ABS: calls made", 1, done > 50000);
    tl_int("fpfast FUNCTION ABS of a float: results of another size, attribute or bytes than libcob's (specials, 40000 random, tiny)", 0, wrong);
}

/* FUNCTION TAN and ATAN: libm's double, within 1e-12 of libcob's; any argument this file does not read is libcob's. */
static void tangent_and_arc_tangent(void) {
    static const double POINTS[] = {0.0, 0.5, -0.5, 1.0, -1.0, 2.5, 0.7853981633974483, 100.25, -100.25, 1e-9, 12345.678, 1e10, -1e10};
    char name[160];
    int wrong_tan = 0, wrong_atan = 0;
    unsigned char dec[] = "000015000";
    float xs = 0.75f;
    double x;
    cob_field fx = field_of(&x, sizeof x, &A_DOUBLE), fd = field_of(dec, 9, &A_DEC), fs = field_of(&xs, sizeof xs, &A_FLOAT), *r;

    for (size_t i = 0; i < sizeof POINTS / sizeof POINTS[0]; i++) {
        double want;
        x = POINTS[i];
        r = ccfp_intr_tan(&fx);
        want = tan(x) + 0.0;
        snprintf(name, sizeof name, "fpfast FUNCTION TAN(%.17g) is the C double tan", x);
        tl_bytes(name, &want, sizeof want, r->data, r->size);
        r = ccfp_intr_atan(&fx);
        want = atan(x) + 0.0;
        snprintf(name, sizeof name, "fpfast FUNCTION ATAN(%.17g) is the C double atan", x);
        tl_bytes(name, &want, sizeof want, r->data, r->size);
    }
    for (int i = 0; i < 20000; i++) {
        x = i < 10000 ? ldexp((double)(next_random() >> 11) / 9007199254740992.0 - 0.5, (int)(next_random() % 12) - 6) * 10.0 : random_double();
        if (x == 0.0 && signbit(x)) {
            continue; /* libcob's decimal of a negative zero is not set */
        }
        double lib_tan = double_of_field(cob_intr_tan(&fx)), fast_tan = double_of_field(ccfp_intr_tan(&fx));
        double lib_atan = double_of_field(cob_intr_atan(&fx)), fast_atan = double_of_field(ccfp_intr_atan(&fx));
        wrong_tan += fabs(fast_tan - lib_tan) > 1e-12 * (1.0 + fabs(lib_tan));
        wrong_atan += fabs(fast_atan - lib_atan) > 1e-15;
    }
    tl_int("fpfast FUNCTION TAN: 20000 random numbers further than 1e-12 (relative) from libcob's", 0, wrong_tan);
    tl_int("fpfast FUNCTION ATAN: 20000 random numbers further than 1e-15 from libcob's", 0, wrong_atan);
    tl_int("fpfast FUNCTION TAN of a decimal 1.5 is libcob's", 1, same_result(ccfp_intr_tan(&fd), cob_intr_tan(&fd)));
    tl_int("fpfast FUNCTION ATAN of a decimal 1.5 is libcob's", 1, same_result(ccfp_intr_atan(&fd), cob_intr_atan(&fd)));
    tl_int("fpfast FUNCTION TAN of a FLOAT-SHORT is the C double tan of it", 1, double_of_field(ccfp_intr_tan(&fs)) == tan((double)xs));
    x = INFINITY;
    tl_int("fpfast FUNCTION ATAN of an infinite float is libcob's", 1, same_result(ccfp_intr_atan(&fx), cob_intr_atan(&fx)));
    tl_int("fpfast FUNCTION TAN of an infinite float is libcob's", 1, same_result(ccfp_intr_tan(&fx), cob_intr_tan(&fx)));
}

/* FUNCTION PI inside a function argument: the double nearest to it. */
static void pi_in_arguments(void) {
    double x = 37.5, y = 90.0;
    int64_t whole = 180;
    cob_field fx = field_of(&x, sizeof x, &A_DOUBLE), fy = field_of(&y, sizeof y, &A_DOUBLE), fw = field_of(&whole, sizeof whole, &A_QUAD);
    cob_field *pi = cob_intr_pi(), pi_copy = *pi;
    unsigned char digits[128], other[128];
    cob_field_attr attr = *pi->attr;
    char name[160];

    memcpy(digits, pi->data, pi->size);
    pi_copy.data = digits;
    pi_copy.attr = &attr;
    double want = x * 3.141592653589793;
    cob_field *r = ccfp_intr_binop(&fx, '*', &pi_copy);
    tl_bytes("fpfast FLOAT-LONG * FUNCTION PI inside a function argument is the C double x * pi", &want, sizeof want, r->data, r->size);
    want = 3.141592653589793 * x;
    r = ccfp_intr_binop(&pi_copy, '*', &fx);
    tl_bytes("fpfast FUNCTION PI * FLOAT-LONG inside a function argument is the C double pi * x", &want, sizeof want, r->data, r->size);
    want = x * 3.141592653589793 / 180.0;
    r = ccfp_intr_binop(ccfp_intr_binop(&fx, '*', &pi_copy), '/', &fw);
    tl_bytes("fpfast FLOAT-LONG * FUNCTION PI / 180 inside a function argument is the C double expression", &want, sizeof want, r->data, r->size);
    snprintf(name, sizeof name, "fpfast FUNCTION COS(x * FUNCTION PI / 180) is the C double cos of it");
    tl_int(name, 1, double_of_field(ccfp_intr_cos(ccfp_intr_binop(ccfp_intr_binop(&fx, '*', &pi_copy), '/', &fw))) == cos(want));
    tl_int("fpfast FUNCTION SIN(FUNCTION PI) is the C double sin(pi)", 1, double_of_field(ccfp_intr_sin(&pi_copy)) == sin(3.141592653589793));
    tl_int("fpfast FUNCTION PI * 90 and libcob's: within 1e-14", 1,
           fabs(double_of_field(ccfp_intr_binop(&fy, '*', &pi_copy)) - double_of_field(cob_intr_binop(&fy, '*', &pi_copy))) < 1e-12);
    /* a decimal that is not pi (the last digit changed), of the same shape, goes to libcob */
    memcpy(other, digits, pi->size);
    other[pi->size - 1] = other[pi->size - 1] == '0' ? '1' : '0';
    cob_field not_pi = {pi->size, other, &attr};
    tl_int("fpfast a decimal of pi's shape but another number inside a function argument is libcob's", 1,
           same_result(ccfp_intr_binop(&fx, '*', &not_pi), cob_intr_binop(&fx, '*', &not_pi)));
    cob_field other_scale_attr_field = pi_copy;
    cob_field_attr other_attr = attr;
    other_attr.scale = (short)(attr.scale - 1);
    other_scale_attr_field.attr = &other_attr;
    tl_int("fpfast a decimal with pi's digits and another scale inside a function argument is libcob's", 1,
           same_result(ccfp_intr_binop(&fx, '*', &other_scale_attr_field), cob_intr_binop(&fx, '*', &other_scale_attr_field)));
}

/* a / b of two integers inside a function argument: libcob's own field (size, attribute, bytes), and FUNCTION INTEGER and
 * INTEGER-PART of it, whatever the operands; the made fields are recognised by the whole-number functions. */
static void integer_quotients(void) {
    static const int64_t EDGES[] = {1, -1, 2, 3, -3, 7, 10, 16, -16, 100, 1000000007LL, 4294967295LL, 4294967296LL, 4611686018427387903LL,
                                    -4611686018427387903LL, 4611686018427387904LL, 9007199254740993LL, 0};
    int wrong = 0, wrong_integer = 0, wrong_part = 0, done = 0;
    for (int i = 0; i < 18 * 18 + 40000; i++) {
        int64_t a, b;
        if (i < 18 * 18) {
            a = EDGES[i / 18];
            b = EDGES[i % 18];
        } else {
            int wa = 1 + (int)(next_random() % 62), wb = 1 + (int)(next_random() % 62);
            a = (int64_t)(next_random() >> (64 - wa));
            b = (int64_t)(next_random() >> (64 - wb));
            if (next_random() & 1) {
                a = -a;
            }
            if (next_random() & 1) {
                b = -b;
            }
            if (i % 5 == 0) {
                a = a / 7 * 7; /* some that divide in part: the decimals end early */
                b = (next_random() & 1) ? 7 : 16;
            }
            if (i % 11 == 0) {
                b = (int64_t)1 << (next_random() % 40); /* a power of two: a quotient of up to 40 decimals */
            }
        }
        cob_field fa = field_of(&a, sizeof a, &A_QUAD), fb = field_of(&b, sizeof b, &A_QUAD);
        cob_field *fast = ccfp_intr_binop(&fa, '/', &fb);
        unsigned char bytes[96];
        cob_field_attr attr = *fast->attr;
        cob_field copy = *fast;
        copy.attr = &attr;
        memcpy(bytes, fast->data, fast->size);
        copy.data = bytes;
        cob_field *stock = cob_intr_binop(&fa, '/', &fb);
        /* an exact quotient is the integer of integer_binop (its attribute is not libcob's: the number is) */
        wrong += b != 0 && a % b == 0 ? !same_result(&copy, stock) : !same_field(&copy, stock);
        done++;
        if (b != 0) {
            cob_field *whole_fast = ccfp_intr_integer(ccfp_intr_binop(&fa, '/', &fb));
            unsigned char whole_bytes[512];
            cob_field_attr whole_attr = *whole_fast->attr;
            cob_field whole_copy = *whole_fast;
            memcpy(whole_bytes, whole_fast->data, whole_fast->size);
            whole_copy.data = whole_bytes;
            whole_copy.attr = &whole_attr;
            wrong_integer += !same_field(&whole_copy, cob_intr_integer(cob_intr_binop(&fa, '/', &fb)));
            whole_fast = ccfp_intr_integer_part(ccfp_intr_binop(&fa, '/', &fb));
            whole_attr = *whole_fast->attr;
            whole_copy = *whole_fast;
            memcpy(whole_bytes, whole_fast->data, whole_fast->size);
            whole_copy.data = whole_bytes;
            whole_copy.attr = &whole_attr;
            wrong_part += !same_field(&whole_copy, cob_intr_integer_part(cob_intr_binop(&fa, '/', &fb)));
        }
    }
    tl_int("fpfast integer / integer inside a function argument: quotients made", 1, done > 40000);
    tl_int("fpfast integer / integer inside a function argument: fields of another size, attribute or bytes than libcob's (edges, 40000 random)", 0, wrong);
    tl_int("fpfast FUNCTION INTEGER(a / b): results of another size, attribute or bytes than libcob's", 0, wrong_integer);
    tl_int("fpfast FUNCTION INTEGER-PART(a / b): results of another size, attribute or bytes than libcob's", 0, wrong_part);
    {
        int64_t a = 7, b = 2;
        cob_field fa = field_of(&a, sizeof a, &A_QUAD), fb = field_of(&b, sizeof b, &A_QUAD);
        tl_int("fpfast FUNCTION INTEGER(7 / 2) is 3", 3, (int)cob_get_llint(ccfp_intr_integer(ccfp_intr_binop(&fa, '/', &fb))));
        a = -7;
        tl_int("fpfast FUNCTION INTEGER(-7 / 2) is -4", -4, (int)cob_get_llint(ccfp_intr_integer(ccfp_intr_binop(&fa, '/', &fb))));
        tl_int("fpfast FUNCTION INTEGER-PART(-7 / 2) is -3", -3, (int)cob_get_llint(ccfp_intr_integer_part(ccfp_intr_binop(&fa, '/', &fb))));
        a = 1;
        b = 3;
        cob_field *q = ccfp_intr_binop(&fa, '/', &fb);
        cob_field *r = ccfp_intr_binop(&fa, '+', &fa); /* later results do not disturb the quotient's recognition until 64 more */
        tl_int("fpfast the quotient 1 / 3 is 38 digits of 3", 38, (int)q->size);
        tl_int("fpfast an integer result after a quotient is a plain integer", 2, (int)cob_get_llint(r));
        b = 0;
        tl_int("fpfast a quotient by zero is libcob's", 1, same_field(ccfp_intr_binop(&fa, '/', &fb), cob_intr_binop(&fa, '/', &fb)));
    }
}

/* FUNCTION PI is libcob's field, kept. */
static void pi_field(void) {
    cob_field *kept = ccfp_intr_pi(), *again = ccfp_intr_pi();
    tl_int("fpfast FUNCTION PI is libcob's field", 1, same_field(kept, cob_intr_pi()));
    tl_int("fpfast FUNCTION PI is the same field every time", 1, kept == again);
    tl_int("fpfast FUNCTION PI is read as the double nearest to pi inside a function argument", 1,
           double_of_field(ccfp_intr_sin(ccfp_intr_binop(kept, '/', kept))) == sin(1.0));
}

/* A decimal that was never a float (a literal, an integer, a product of those) stored into a float field. */
static void decimal_into_float_exact(void) {
    int wrong = 0, done = 0;
    for (int i = 0; i < 30000; i++) {
        int digits = 1 + (int)(next_random() % 16);
        unsigned char text[18];
        for (int k = 0; k < digits; k++) {
            text[k] = (unsigned char)('0' + next_random() % 10);
        }
        cob_field_attr attr = {COB_TYPE_NUMERIC_DISPLAY, (unsigned short)digits, (short)(next_random() % 24), COB_FLAG_CONSTANT, NULL};
        cob_field fl = field_of(text, (size_t)digits, &attr);
        int64_t n = (int64_t)(next_random() >> (next_random() % 64)) * (next_random() & 1 ? 1 : -1);
        cob_field fn = field_of(&n, sizeof n, &A_QUAD);
        double got_stock = 0, got_fast = 0;
        float short_stock = 0, short_fast = 0;
        cob_field fds = field_of(&got_stock, sizeof got_stock, &A_DOUBLE), fdf = field_of(&got_fast, sizeof got_fast, &A_DOUBLE);
        cob_field fss = field_of(&short_stock, sizeof short_stock, &A_FLOAT), fsf = field_of(&short_fast, sizeof short_fast, &A_FLOAT);
        int opts[2] = {0, COB_STORE_KEEP_ON_OVERFLOW};
        for (int o = 0; o < 2; o++) {
            for (int k = 0; k < 3; k++) {
                cob_field *source = k == 0 ? &fl : &fn;
                if (k == 2) {
                    /* the product of the two */
                    STOCK.set(&d1, &fn);
                    STOCK.set(&d2, &fl);
                    cob_decimal_mul(&d1, &d2);
                    wrong += STOCK.get(&d1, &fds, opts[o]) != 0;
                    wrong += STOCK.get(&d1, &fss, opts[o]) != 0;
                    FAST.set(&d1, &fn);
                    FAST.set(&d2, &fl);
                    FAST.op[2](&d1, &d2);
                    FAST.get(&d1, &fdf, opts[o]);
                    FAST.set(&d1, &fn);
                    FAST.set(&d2, &fl);
                    FAST.op[2](&d1, &d2);
                    FAST.get(&d1, &fsf, opts[o]);
                } else {
                    STOCK.set(&d1, source);
                    STOCK.get(&d1, &fds, opts[o]);
                    STOCK.set(&d1, source);
                    STOCK.get(&d1, &fss, opts[o]);
                    FAST.set(&d1, source);
                    FAST.get(&d1, &fdf, opts[o]);
                    FAST.set(&d1, source);
                    FAST.get(&d1, &fsf, opts[o]);
                }
                wrong += memcmp(&got_stock, &got_fast, sizeof got_stock) != 0 || memcmp(&short_stock, &short_fast, sizeof short_stock) != 0;
                done++;
            }
        }
    }
    tl_int("fpfast a literal, an integer or their product into a float: stores made", 1, done > 100000);
    tl_int("fpfast a literal, an integer or their product into FLOAT-LONG and FLOAT-SHORT: stores of other bytes than libcob's", 0, wrong);
    {
        unsigned char five[] = "5";
        cob_field_attr tenth = {COB_TYPE_NUMERIC_DISPLAY, 1, 1, COB_FLAG_CONSTANT, NULL};
        cob_field half = field_of(five, 1, &tenth);
        double stock = 0, fast = 0;
        cob_field fs = field_of(&stock, sizeof stock, &A_DOUBLE), ff = field_of(&fast, sizeof fast, &A_DOUBLE);
        STOCK.set(&d1, &half);
        STOCK.get(&d1, &fs, COB_STORE_ROUND);
        FAST.set(&d1, &half);
        FAST.get(&d1, &ff, COB_STORE_ROUND);
        tl_bytes("fpfast the literal 0.5 into FLOAT-LONG ROUNDED is libcob's", &stock, sizeof stock, &fast, sizeof fast);
        STOCK.set(&d1, &half);
        STOCK.get(&d1, &fs, 0);
        tl_int("fpfast the literal 0.5 into FLOAT-LONG is 0.5", 1, stock == 0.5);
    }
}

/* A decimal that holds no limb yet (mpz_init, no space: libcob's own decimals are made with space) is given one by a float load. */
static void decimal_without_space(void) {
    double v = 2.5, got = 0.0;
    cob_decimal raw;
    cob_field fv = field_of(&v, sizeof v, &A_DOUBLE), fg = field_of(&got, sizeof got, &A_DOUBLE);
    mpz_init(raw.value);
    raw.scale = 0;
    ccfp_decimal_set_field(&raw, &fv);
    ccfp_decimal_get_field(&raw, &fg, 0);
    tl_int("fpfast a float loaded into a decimal that holds no space round trips", 1, got == 2.5);
    mpz_clear(raw.value);
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
    compare_with_integer();
    compare_fields();
    float_into_integer();
    get_integers();
    move_numbers();
    whole_numbers();
    absolute_values();
    tangent_and_arc_tangent();
    pi_in_arguments();
    integer_quotients();
    pi_field();
    decimal_into_float_exact();
    decimal_without_space();
    return 0;
}
