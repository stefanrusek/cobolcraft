*> Test of CL-MAIN of client/src/loop.cob (contracts/test-harness.md §2; research R14): CL-MAIN
*> started without --name (this program has no arguments) ends the run through the fatal
*> arguments path: "FATAL arguments: ...", exit status 1 (.expect).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CL-MAIN.
 PROCEDURE DIVISION.
     CALL "CL-MAIN"
     DISPLAY "not reached"
     STOP RUN.
 END PROGRAM TEST-CL-MAIN.
