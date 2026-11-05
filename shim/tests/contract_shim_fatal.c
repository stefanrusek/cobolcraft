/* Contract test, provider side of shim-abi.md §1 and §2: cc_fatal is the single fatal-exit path. It
 * writes "FATAL <what>: <detail>" to standard error and exits with status 1. Fatal-path test program:
 * the expected outcome is in contract_shim_fatal.expect (exit status 1, the stderr line), checked by
 * tools/runtests.py as one case named after this program. */

#include "ccshim.h"

int main(void) {
    cc_fatal("probe: detail");
}
