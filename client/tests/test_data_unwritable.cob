*> Fatal-path test of client/src/game-dir.cob (research R14: a file write that fails during save is
*> fatal): saving the server list into a game directory that cannot be written ends the client with
*> "FATAL client data: ..." and exit status 1 (.expect). The fatal path runs in a forked child (its
*> standard error is this program's); the parent then makes the directory writable again and
*> removes it, so a plain `rm -rf build` works afterwards, and ends with the child's exit status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DATA-UNWRITABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY TESTLIB.
 01 WS-NULL                USAGE POINTER VALUE NULL.
 01 WS-PID                 BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG.
 01 WS-EXIT                BINARY-LONG.
 01 WS-PATH                PIC X(64) VALUE "build/client-test-unwritable".
 01 WS-INFO                PIC X(16).
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "chmod -R u+w build/client-test-unwritable 2>/dev/null; rm -rf build/client-test-unwritable"
     CALL STATIC "fflush" USING BY VALUE WS-NULL RETURNING WS-RC
     CALL STATIC "fork" RETURNING WS-PID
     IF WS-PID = 0
         CALL "CL-INIT" USING CLIENT-STATE
         MOVE "build/client-test-unwritable" TO CL-GAME-DIR
         MOVE 28 TO CL-GAME-DIR-LENGTH
         CALL "GAME-DIR-SETUP" USING CLIENT-STATE
         CALL "SYSTEM" USING "chmod a-w build/client-test-unwritable"
         CALL "SERVERS-SAVE" USING CLIENT-STATE
         DISPLAY "not reached"
         STOP RUN
     END-IF
     CALL STATIC "waitpid" USING BY VALUE WS-PID BY REFERENCE WS-STATUS BY VALUE WS-ZERO
         RETURNING WS-RC
     DIVIDE WS-STATUS BY 256 GIVING WS-EXIT
     COMPUTE WS-EXIT = FUNCTION MOD(WS-EXIT, 256)
     CALL "SYSTEM" USING "chmod -R u+w build/client-test-unwritable 2>/dev/null; rm -rf build/client-test-unwritable"
     MOVE "test data unwritable afterwards the unwritable game directory is removed" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "removed" TO TL-EXPECTED
     MOVE "removed" TO TL-OBSERVED
     CALL "CBL_CHECK_FILE_EXIST" USING WS-PATH WS-INFO
     IF RETURN-CODE = 0
         MOVE "still there" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-EXIT TO RETURN-CODE
     STOP RUN.
 END PROGRAM TEST-DATA-UNWRITABLE.
