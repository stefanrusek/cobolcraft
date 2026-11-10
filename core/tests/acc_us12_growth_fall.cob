*> Acceptance test of the falling blocks of docs/protocol/29b part 1 section 3.1 wired into the block-update hooks (specs 002 phase 42): a falling block placed in the air schedules its
*> tick after its delay of 2 (onPlace row), the tick moves it to its landing cell above the first block with a solid face, and a falling block placed on a solid block stays. The
*> falling block entity's flight is not simulated (the block lands at once). The cobolcraft world has no sand, so the test adds it to the block table and registers the rows
*> through GB-RULES-OPEN, which CORE-WORLD-OPEN runs for the blocks of the open tables.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US12-GROWTH-FALL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 12.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG VALUE 12.
 01 WS-STATE               BINARY-LONG.
 01 WS-SAND                BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE "T" TO TL-MODE
     COMPUTE WS-N = CB-BLOCK-COUNT + 1
     MOVE "minecraft:sand" TO CB-KEY(WS-N)
     MOVE 14 TO CB-KEY-LENGTH(WS-N)
     MOVE 1 TO CB-SOLID(WS-N) CB-OPAQUE(WS-N)
     MOVE 0 TO CB-LIGHT(WS-N) CB-CLASS(WS-N) CB-TOOL-REQ(WS-N) CB-NEED-TIER(WS-N)
     MOVE -1 TO CB-BREAK-MS(WS-N)
     MOVE CB-STATE-COUNT TO WS-SAND
     MOVE WS-SAND TO CB-FIRST-STATE(WS-N) CB-DEFAULT-STATE(WS-N)
     MOVE 1 TO CB-STATES(WS-N)
     COMPUTE CB-S-BLOCK(WS-SAND + 1) = WS-N - 1
     MOVE 0 TO CB-S-LIGHT(WS-SAND + 1)
     ADD 1 TO CB-BLOCK-COUNT
     ADD 1 TO CB-STATE-COUNT
     ADD 1 TO CB-EPOCH
     CALL "GB-RULES-OPEN"
     CALL "GB-RULES-OPEN"
     MOVE 80 TO WS-Y
     MOVE 2 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE

     MOVE "acceptance US12 29b-1 3.1 given sand placed in the air above a block when 2 ticks pass then it has fallen to the cell above that block and the air is where it was"
         TO TL-CASE
     MOVE 90 TO WS-Y
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-SAND
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-EDIT
     MOVE 2 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-EDIT2
     MOVE 81 TO WS-Y
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-EDIT3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-SAND TO WS-EDIT
     MOVE SPACES TO TL-EXPECTED
     STRING FUNCTION TRIM(WS-EDIT) " 0 " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 29b-1 3.1 given sand placed on that sand when 3 ticks pass then it stays (the cell below is not free)" TO TL-CASE
     MOVE 82 TO WS-Y
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-SAND
     MOVE 3 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE WS-SAND TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 29b-1 3.1 given the block below the sand is removed when the neighbour update runs then the sand falls again (updateShape schedules the tick)"
         TO TL-CASE
     MOVE 80 TO WS-Y
     MOVE 0 TO WS-STATE
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 6 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     MOVE 82 TO WS-Y
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US12-GROWTH-FALL.

 COPY CORETEST.
