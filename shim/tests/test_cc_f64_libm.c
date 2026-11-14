/* Implementation test of the cc_f64_* functions beyond plain arithmetic (docs/protocol/10 section 16.2):
 * rounding, casts, libm wrappers, the sine table and the Mth.atan2 routine, over the vectors of
 * f64_vectors.txt. Every function must have vectors. */
#include "f64_vectors.h"

int main(void) {
    f64_run_group(G_LIBM);
    return 0;
}
