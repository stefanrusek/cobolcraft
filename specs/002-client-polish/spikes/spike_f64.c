/* spike (throwaway): the ABI-mismatch glue for IEEE double arithmetic (COBOL cannot receive a C double
 * return value). Operands and result by reference; fma(a, b, 0.0) is the rounded product and
 * fma(a, 1.0, b) the rounded sum, bit-equal to Java's separate double operations. */
#include <math.h>
void cc_f64_mul(const double *a, const double *b, double *out) { *out = fma(*a, *b, 0.0); }
void cc_f64_add(const double *a, const double *b, double *out) { *out = fma(*a, 1.0, *b); }
