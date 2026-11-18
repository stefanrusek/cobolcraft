/* cc_fpfast: the names the generated C of a COBOL program calls instead of libcob's cob_decimal_* and cob_intr_* functions when
 * the program is compiled with the defines of tools/package.mk (FPFAST=1, the default). Private to the shim and its
 * tests: no COBOL source calls these, and they are not part of contract/include/ccshim.h. See cc_fpfast.c. */
#ifndef COBOLCRAFT_CC_FPFAST_H
#define COBOLCRAFT_CC_FPFAST_H

#include <gmp.h>
#include <libcob.h>

void ccfp_decimal_set_field(cob_decimal *d, cob_field *f);
int ccfp_decimal_get_field(cob_decimal *d, cob_field *f, const int opt);
void ccfp_decimal_add(cob_decimal *d1, cob_decimal *d2);
void ccfp_decimal_sub(cob_decimal *d1, cob_decimal *d2);
void ccfp_decimal_mul(cob_decimal *d1, cob_decimal *d2);
void ccfp_decimal_div(cob_decimal *d1, cob_decimal *d2);
void ccfp_decimal_pow(cob_decimal *d1, cob_decimal *d2);
int ccfp_decimal_cmp(cob_decimal *d1, cob_decimal *d2);
void ccfp_decimal_align(cob_decimal *d, const int scale);

cob_field *ccfp_intr_sin(cob_field *f);
cob_field *ccfp_intr_cos(cob_field *f);
cob_field *ccfp_intr_sqrt(cob_field *f);
cob_field *ccfp_intr_mod(cob_field *f1, cob_field *f2);
cob_field *ccfp_intr_binop(cob_field *f1, const int op, cob_field *f2);

#endif
