/* cc_fatal (contracts/shim-abi.md §1, §2; FR-012, research R14): the single fatal-exit path of every
 * program, called from the glue modules and from COBOL (CALL STATIC "cc_fatal" USING BY REFERENCE
 * <z-string>). The argument is the message "<what>: <detail>" composed by the caller (what failed,
 * then the detail, for example the file name or the failing library call); this module writes it as
 * the line "FATAL <what>: <detail>" to standard error and exits with status 1. */
#include <stdio.h>
#include <stdlib.h>

#include "ccshim.h"

_Noreturn void cc_fatal(const char *what) {
    fprintf(stderr, "FATAL %s\n", what);
    exit(1);
}
