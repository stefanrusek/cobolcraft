*> Fatal-path contract test, the core's consumer side of shim-abi.md §1 and §2: cc_fatal called from
*> COBOL (CALL STATIC with a z-string, research R2) writes "FATAL <what>: <detail>" to standard error
*> and exits with status 1. Expected outcome: contract_shim_consumer_fatal.expect (tools/runtests.py).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-CONTRACT-SHIM-FATAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-WHAT                PIC X(32) VALUE Z"core probe: fatal detail".
 PROCEDURE DIVISION.
     CALL STATIC "cc_fatal" USING BY REFERENCE WS-WHAT
     DISPLAY "cc_fatal returned"
     STOP RUN.
 END PROGRAM CORE-CONTRACT-SHIM-FATAL.
