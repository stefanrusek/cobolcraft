*> Fatal-path test of client/src/args.cob (research R14; client-surface.md §1, wire-profile.md §1):
*> a name with a character outside A-Z a-z 0-9 _ ends the client with "FATAL arguments: ..." and
*> exit status 1 (.expect).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ARGS-INVALID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLARGS.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     INITIALIZE CL-ARGS
     MOVE 2 TO AR-COUNT
     MOVE "--name" TO AR-TEXT(1)
     MOVE 6 TO AR-LENGTH(1)
     MOVE "bad-name" TO AR-TEXT(2)
     MOVE 8 TO AR-LENGTH(2)
     CALL "ARGS-PARSE" USING CLIENT-STATE CL-ARGS
     DISPLAY "not reached"
     STOP RUN.
 END PROGRAM TEST-ARGS-INVALID.
