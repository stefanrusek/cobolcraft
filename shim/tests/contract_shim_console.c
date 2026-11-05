/* Contract test, provider side of shim-abi.md §4: cc_con_readline returns each console line without
 * its newline, then CC_CLOSED at end of input. Standard input is contract_shim_console.stdin (two
 * lines, then end of input), fed by tools/runtests.py. */
#include "ccshim.h"
#include "testlib.h"

int main(void) {
    uint8_t line[256];
    int32_t length = -1;
    int32_t rc = cc_con_readline(line, sizeof line, &length);
    line[length] = 0;
    tl_int("contract shim cc_con_readline first line returns 0", 0, rc);
    tl_str("contract shim cc_con_readline first line without newline", "say hello world", (const char *)line);
    rc = cc_con_readline(line, sizeof line, &length);
    line[length] = 0;
    tl_int("contract shim cc_con_readline second line returns 0", 0, rc);
    tl_str("contract shim cc_con_readline second line without newline", "stop", (const char *)line);
    rc = cc_con_readline(line, sizeof line, &length);
    tl_int("contract shim cc_con_readline at end of input returns CC_CLOSED", CC_CLOSED, rc);
    rc = cc_con_readline(line, sizeof line, &length);
    tl_int("contract shim cc_con_readline after end of input stays CC_CLOSED", CC_CLOSED, rc);
    return 0;
}
