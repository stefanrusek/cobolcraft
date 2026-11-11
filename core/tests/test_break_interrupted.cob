*> Edge-case test (spec edge case; docs/protocol/13 §2.4): a survival break resets and sends stage -1 (the byte 255)
*> when the held item changes, when the target block changes (a new Player Action start elsewhere), and when
*> another player breaks the block first. Alice breaks loam by hand (0.06667 per tick), Bobby is in view.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BREAK-INTERRUPTED.
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
 01 WS-X2                  BINARY-LONG VALUE 21.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-ACTION              BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 3.
 01 WS-VOID                BINARY-LONG VALUE 0.
 01 WS-TICKS               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
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
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X2 WS-Y WS-Z WS-STATE

     MOVE "test break interrupted given a break in progress when the held item changes then the "
         & "stage is cleared (255) for the viewers and no break is left" TO TL-CASE
     PERFORM START-BREAK
     MOVE 1 TO WS-SLOT
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     MOVE "5(1,20,100,20=255)" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test break interrupted given the break was reset when the player finishes it then the "
         & "block stays (the finish has no break to match)" TO TL-CASE
     MOVE 3 TO WS-ACTION
     PERFORM ACT
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test break interrupted given a break in progress when the player starts another block "
         & "then the old stage is cleared (255) before the new stage 0" TO TL-CASE
     PERFORM START-BREAK
     MOVE 21 TO WS-X
     MOVE 0 TO WS-ACTION
     PERFORM ACT
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     MOVE "5(1,20,100,20=255) 5(1,21,100,20=0)" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test break interrupted given Alice breaks (21,100,20) when Bobby breaks that block first "
         & "then Alice's stage is cleared at the next tick" TO TL-CASE
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-VOID
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     MOVE "8(21,100,20=0) 5(1,21,100,20=255)" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 START-BREAK.
     MOVE 20 TO WS-X
     MOVE 0 TO WS-SLOT
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-ACTION
     PERFORM ACT
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     CONTINUE.

 ACT.
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-ALICE WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BREAK-INTERRUPTED.

 COPY CORETEST.
