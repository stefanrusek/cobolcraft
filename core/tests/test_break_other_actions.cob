*> Edge-case test (docs/protocol/13 section 2.4 Player Action, status values the block rules do not use): BLOCK-ACTION ignores every status other than start (0), finish (2) and
*> the one the old dig sequence ends with (3): the Player Action values 1 (cancel digging) and 9 and above change nothing, whatever block is at the position. Status 8 (the spear
*> jab) is routed to RANGED-STAB by PLAY-HANDLE and never reaches it. Alice starts no break; she sends the other statuses at loam and the block and the viewer's packets stay as they were.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BREAK-OTHER-ACTIONS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 20.
 01 WS-Y                   BINARY-LONG VALUE 100.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-ACTION              BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 3.
 01 WS-NOW                 BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT

     MOVE "test break other actions given the cancel status 1 when it is sent at a block then "
         & "the block is untouched and the viewer is told nothing" TO TL-CASE
     MOVE 1 TO WS-ACTION
     PERFORM ACT
     PERFORM CHECK-BLOCK
     PERFORM CHECK-QUIET

     MOVE "test break other actions given the status 9 when it is sent at a block then "
         & "the block is untouched and the viewer is told nothing" TO TL-CASE
     MOVE 9 TO WS-ACTION
     PERFORM ACT
     PERFORM CHECK-BLOCK
     PERFORM CHECK-QUIET
     STOP RUN.

 ACT.
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-ALICE WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ.

 CHECK-BLOCK.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-NOW
     MOVE "N" TO TL-MODE
     MOVE WS-STATE TO TL-EXPECTED-N
     MOVE WS-NOW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-QUIET.
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BREAK-OTHER-ACTIONS.

 COPY CORETEST.
