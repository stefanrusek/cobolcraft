*> Acceptance test, US4-4 core half (spec US4 scenario 4; tasks T440; FR-007; standin-content §1.1,
*> §1.3): in creative a block breaks at once on the start of the break and no item appears (no Add
*> Entity); the baseplate is never broken (US4 edge).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US4-BREAK-CREATIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 20.
 01 WS-Y                   BINARY-LONG VALUE 100.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-ACTION              BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG VALUE 15.
 01 WS-TEXT                PIC X(1024).
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE

     MOVE "acceptance US4-4 given creative when a block is broken then it breaks at once on "
         & "the start of the break (void) and no item appears (no Add Entity)" TO TL-CASE
     PERFORM START-AND-LIST
     MOVE "49(1,1) 8(20,100,20=0) 4(1) state 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US4 edge given creative when the baseplate is broken then nothing happens "
         & "and the player is sent its real state" TO TL-CASE
     MOVE 0 TO WS-Y
     PERFORM START-AND-LIST
     MOVE "8(20,0,20=1) 4(2) state 1" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 START-AND-LIST.
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-CONN WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " state " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO TL-OBSERVED.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US4-BREAK-CREATIVE.

 COPY CORETEST.
