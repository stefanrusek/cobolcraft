*> Test of CL-MAIN of client/src/loop.cob (contracts/test-harness.md §2; research R6): CL-MAIN with
*> --name and a scratch --gamedir opens the window, runs CL-RUN and, when the window's close is
*> requested, ends the program with exit status 0 (.expect). The runner starts test programs without
*> arguments, so this program runs itself again with them; that second run asks for the close two
*> seconds in (SIGALRM, TEST-CLOSE-REQUEST) and its exit status becomes this one's.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CL-MAIN-RUN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COUNT               BINARY-LONG.
 01 WS-COMMAND             PIC X(2048).
 01 WS-STATUS              BINARY-LONG.
 01 WS-HANDLER             USAGE PROGRAM-POINTER.
 01 WS-SIGALRM             BINARY-LONG VALUE 14.
 01 WS-SECONDS             BINARY-LONG VALUE 2.
 PROCEDURE DIVISION.
     ACCEPT WS-COUNT FROM ARGUMENT-NUMBER
     IF WS-COUNT = 0
         CALL "SYSTEM" USING "rm -rf build/client-test-cl-main"
         MOVE SPACES TO WS-COMMAND
         STRING FUNCTION TRIM(FUNCTION MODULE-PATH) " --name Tester --gamedir "
             "build/client-test-cl-main" DELIMITED BY SIZE INTO WS-COMMAND
         CALL "SYSTEM" USING WS-COMMAND
         COMPUTE WS-STATUS = RETURN-CODE / 256
         STOP RUN RETURNING WS-STATUS
     END-IF
     SET WS-HANDLER TO ENTRY "TEST-ALARM"
     CALL STATIC "signal" USING BY VALUE WS-SIGALRM BY VALUE WS-HANDLER
     CALL STATIC "alarm" USING BY VALUE WS-SECONDS
     CALL "CL-MAIN"
     STOP RUN RETURNING 9.
 END PROGRAM TEST-CL-MAIN-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ALARM.
 PROCEDURE DIVISION.
     CALL "TEST-CLOSE-REQUEST"
     GOBACK.
 END PROGRAM TEST-ALARM.
 COPY CLTEST.
