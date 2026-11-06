*> Fatal-path test of client/src/args.cob (research R14; client-surface.md §1): a command line
*> without --name ends the client with "FATAL arguments: ..." and exit status 1 (.expect).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ARGS-MISSING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLARGS.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     INITIALIZE CL-ARGS
     MOVE 2 TO AR-COUNT
     MOVE "--gamedir" TO AR-TEXT(1)
     MOVE 9 TO AR-LENGTH(1)
     MOVE "build/client-test-dir" TO AR-TEXT(2)
     MOVE 21 TO AR-LENGTH(2)
     CALL "ARGS-PARSE" USING CLIENT-STATE CL-ARGS
     DISPLAY "not reached"
     STOP RUN.
 END PROGRAM TEST-ARGS-MISSING.
