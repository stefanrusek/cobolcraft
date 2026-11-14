*> Acceptance test of the world simulation wired into the play path (specs 002 phase 41, T0500 and T0502; docs/protocol/29 sections 4, 7 and 29a section 2,
*> 33 section 2.1): a block placed or broken through the real packets is applied at once but reaches the viewers (Block Update) and its acknowledger
*> (Block Changed Ack) only when the tick runs (the queues of 29 section 7: BC-MARK, BC-BROADCAST, BC-ACK-SET, BC-ACK-TICK in CORE-TICK), and a water source
*> placed the same way schedules fluid ticks (29a section 2) that flow it over a platform, one level less per step of 5 ticks, and that recede when the
*> source is broken. The cobolcraft world has no water, so the test adds the liquid block to the block table and lets an item place it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US12-WORLDSIM-PLAY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CITEMS.
 01 TEST-FEED-OPTIONS EXTERNAL.
    05 TFO-NO-FLUSH           BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-EDIT                PIC -(9)9.
 01 WS-PTR                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG VALUE 0.
 01 WS-K                   BINARY-LONG.
 01 WS-LABEL               PIC X(24).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE 2 TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 64 TO PL-SLOT-COUNT(WS-ROW, 1)
     CALL "TEST-HELD" USING WS-CONN WS-SLOT
     MOVE 1 TO TFO-NO-FLUSH
     MOVE "T" TO TL-MODE

*>   Placing: applied at once, announced by the tick.
     MOVE "acceptance US12 33 2.1 given a held block when place is used then the block is there at once and the Block Update and the Ack follow "
         & "with the tick" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE 10 TO WS-X WS-Z
     MOVE 99 TO WS-Y
     MOVE 1 TO WS-FACE
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     MOVE 100 TO WS-Y
     PERFORM ADD-STATE
     MOVE "now" TO WS-LABEL
     PERFORM SHOW
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "tick" TO WS-LABEL
     PERFORM SHOW
     MOVE "state 2 now[49(0,0)] tick[8(10,100,10=2) 4(1)]" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Breaking in creative mode: the same.
     MOVE "acceptance US12 33 2.1 given creative when the block is dug then it is void at once and the Block Update and the Ack follow with the "
         & "tick" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE 0 TO WS-ACTION
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-CONN WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ
     PERFORM ADD-STATE
     MOVE "now" TO WS-LABEL
     PERFORM SHOW
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "tick" TO WS-LABEL
     PERFORM SHOW
     MOVE "state 0 now[49(0,0)] tick[8(10,100,10=0) 4(2)]" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Water: a platform, the liquid block in the tables, an item that places a source.
     PERFORM VARYING WS-DX FROM -3 BY 1 UNTIL WS-DX > 3
         PERFORM VARYING WS-DZ FROM -3 BY 1 UNTIL WS-DZ > 3
             COMPUTE WS-X = 10 + WS-DX
             COMPUTE WS-Z = 10 + WS-DZ
             MOVE 99 TO WS-Y
             MOVE 2 TO WS-STATE
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
         END-PERFORM
     END-PERFORM
     PERFORM INSTALL-WATER
     MOVE WS-BASE TO IT-PLACES-STATE(3)
     MOVE 5 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT

     MOVE "acceptance US12 29a 2 given water is placed on a platform when 5 ticks pass then it has spread to the four neighbours as flowing water of "
         & "level 1, announced by one Section Blocks Update" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE 10 TO WS-X WS-Z
     MOVE 99 TO WS-Y
     MOVE 1 TO WS-FACE
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-CONN WS-X WS-Y WS-Z WS-FACE WS-SEQ
     MOVE 100 TO WS-Y
     PERFORM ADD-STATE
     MOVE 5 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "ticks" TO WS-LABEL
     PERFORM SHOW
     MOVE 11 TO WS-X
     PERFORM ADD-STATE
     MOVE 9 TO WS-X
     PERFORM ADD-STATE
     MOVE 10 TO WS-X
     MOVE 9 TO WS-Z
     PERFORM ADD-STATE
     MOVE 11 TO WS-Z
     PERFORM ADD-STATE
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     MOVE "state " TO TL-EXPECTED
     MOVE 7 TO WS-PTR
     MOVE WS-BASE TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) " ticks[49(0,0) 8(10,100,10=" FUNCTION TRIM(WS-EDIT) ") 4(3) 49(0,0) 49(0,0) 49(0,0) 49(0,0) 86]"
         DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-PTR
     COMPUTE WS-N = WS-BASE + 1
     MOVE WS-N TO WS-EDIT
     PERFORM 4 TIMES
         STRING " state " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-PTR
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 29a 2 given the water has spread one level when 10 more ticks pass then the levels fall by one per ring of 5 ticks: "
         & "level 2 at two cells and level 3 at three cells from the source" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE 10 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     MOVE 100 TO WS-Y
     MOVE 12 TO WS-X
     MOVE 10 TO WS-Z
     PERFORM ADD-STATE
     MOVE 13 TO WS-X
     PERFORM ADD-STATE
     MOVE 8 TO WS-X
     PERFORM ADD-STATE
     MOVE 7 TO WS-X
     PERFORM ADD-STATE
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-K FROM 2 BY 1 UNTIL WS-K > 5
         COMPUTE WS-N = WS-BASE + 2
         IF WS-K = 3 OR WS-K = 5
             COMPUTE WS-N = WS-BASE + 3
         END-IF
         MOVE WS-N TO WS-EDIT
         IF WS-PTR > 1
             STRING " " DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-PTR
         END-IF
         STRING "state " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-EXPECTED WITH POINTER WS-PTR
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 29a 2 given the source is removed (BLOCK-CHANGE, which every play path change uses) when the ticks pass then the Block Update "
         & "comes with the next tick and the flowing water next to it recedes to nothing" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE 10 TO WS-X WS-Z
     MOVE 100 TO WS-Y
     MOVE 0 TO WS-STATE
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "dug" TO WS-LABEL
     PERFORM SHOW
     MOVE 70 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     MOVE 11 TO WS-X
     PERFORM ADD-STATE
     MOVE 9 TO WS-X
     PERFORM ADD-STATE
     MOVE 10 TO WS-X
     MOVE 9 TO WS-Z
     PERFORM ADD-STATE
     MOVE 11 TO WS-Z
     PERFORM ADD-STATE
     MOVE " dug[49(0,0) 8(10,100,10=0)] state 0 state 0 state 0 state 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 ADD-STATE.
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-EDIT
     IF WS-PTR > 1
         STRING " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-IF
     STRING "state " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR.

 SHOW.
     CALL "TEST-DRAIN-BLOCKS" USING WS-CONN WS-TEXT
     STRING " " FUNCTION TRIM(WS-LABEL) "[" FUNCTION TRIM(WS-TEXT) "]" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR.

*> Adds "minecraft:water" (16 states, the index being the level; no collision, no light) to the block tables after the last block and state.
 INSTALL-WATER.
     COMPUTE WS-N = CB-BLOCK-COUNT + 1
     MOVE "minecraft:water" TO CB-KEY(WS-N)
     MOVE 15 TO CB-KEY-LENGTH(WS-N)
     MOVE 0 TO CB-SOLID(WS-N) CB-OPAQUE(WS-N) CB-LIGHT(WS-N) CB-CLASS(WS-N) CB-TOOL-REQ(WS-N) CB-NEED-TIER(WS-N)
     MOVE -1 TO CB-BREAK-MS(WS-N)
     MOVE CB-STATE-COUNT TO WS-BASE
     MOVE WS-BASE TO CB-FIRST-STATE(WS-N) CB-DEFAULT-STATE(WS-N)
     MOVE 16 TO CB-STATES(WS-N)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 16
         COMPUTE CB-S-BLOCK(WS-BASE + WS-K) = WS-N - 1
         MOVE 0 TO CB-S-LIGHT(WS-BASE + WS-K)
     END-PERFORM
     ADD 1 TO CB-BLOCK-COUNT
     ADD 16 TO CB-STATE-COUNT
     ADD 1 TO CB-EPOCH.
 END PROGRAM ACC-US12-WORLDSIM-PLAY.

 COPY CORETEST.
