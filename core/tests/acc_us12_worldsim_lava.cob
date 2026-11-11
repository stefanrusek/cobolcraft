*> Acceptance test of the liquid rules in a world that has them (specs 002 phase 41; docs/protocol/29a sections 2 and 3, 29 section 5, 33 section 2.4): two
*> water sources one cell apart turn the cell between them into a source (source conversion), a flowing cell next to a higher one grows, lava next to
*> water becomes obsidian (a source), cobblestone (flowing) or basalt (soul soil below, blue ice beside), lava falling onto water makes stone, water
*> falls over an edge, and random ticks reach the positions of a section with randomly ticking blocks (the trace of the machinery of 29 section 3
*> records them). The cobolcraft world has none of these blocks, so the test adds them to the block table.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US12-WORLDSIM-LAVA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY BUSTATE.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-PTR                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-OBSIDIAN            BINARY-LONG.
 01 WS-COBBLE              BINARY-LONG.
 01 WS-BASALT              BINARY-LONG.
 01 WS-SOIL                BINARY-LONG.
 01 WS-ICE                 BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-COUNT               BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-FLUID               BINARY-LONG VALUE 1.
 01 WS-KIND                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-RULE-KIND           BINARY-LONG VALUE 11.
 01 WS-RULE-EFFECT         BINARY-LONG VALUE 0.
 01 WS-RULE-ARG            BINARY-LONG VALUE 0.
 01 WS-RULE-FLAGS          BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE "T" TO TL-MODE
     MOVE "minecraft:water" TO WS-KEY
     MOVE 0 TO WS-SOLID
     MOVE 16 TO WS-COUNT
     PERFORM INSTALL
     MOVE WS-BASE TO WS-WATER
     MOVE "minecraft:lava" TO WS-KEY
     PERFORM INSTALL
     MOVE WS-BASE TO WS-LAVA
     MOVE 1 TO WS-SOLID
     MOVE 1 TO WS-COUNT
     MOVE "minecraft:stone" TO WS-KEY
     PERFORM INSTALL
     MOVE WS-BASE TO WS-STONE
     MOVE "minecraft:obsidian" TO WS-KEY
     PERFORM INSTALL
     MOVE WS-BASE TO WS-OBSIDIAN
     MOVE "minecraft:cobblestone" TO WS-KEY
     PERFORM INSTALL
     MOVE WS-BASE TO WS-COBBLE
     MOVE "minecraft:basalt" TO WS-KEY
     PERFORM INSTALL
     MOVE WS-BASE TO WS-BASALT
     MOVE "minecraft:soul_soil" TO WS-KEY
     PERFORM INSTALL
     MOVE WS-BASE TO WS-SOIL
     MOVE "minecraft:blue_ice" TO WS-KEY
     PERFORM INSTALL
     MOVE WS-BASE TO WS-ICE
     PERFORM PLATFORM

*>   Source conversion: two sources with one cell between them.
     MOVE "acceptance US12 29a 2.3 given two water sources one cell apart on a platform when the first fluid tick runs then the cell between them is a "
         & "source" TO TL-CASE
     MOVE 100 TO WS-Y
     MOVE 5 TO WS-X
     MOVE 22 TO WS-Z
     MOVE WS-WATER TO WS-STATE
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 7 TO WS-X
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 6 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     MOVE 6 TO WS-X
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE WS-WATER TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A flowing cell next to a source grows to the level its neighbour gives.
     MOVE "acceptance US12 29a 2.2 given a weak flowing cell (level 7) next to a source when its tick runs then it takes level 1" TO TL-CASE
     MOVE 11 TO WS-X
     MOVE 25 TO WS-Z
     COMPUTE WS-STATE = WS-WATER + 7
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 12 TO WS-X
     MOVE WS-WATER TO WS-STATE
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 6 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     MOVE 11 TO WS-X
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     COMPUTE WS-STATE = WS-STATE - WS-WATER
     MOVE WS-STATE TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Lava next to water: obsidian for a source.
     MOVE "acceptance US12 29a 3.1 given a water source when a lava source is placed beside it then the lava becomes obsidian" TO TL-CASE
     MOVE 3 TO WS-X
     MOVE 25 TO WS-Z
     MOVE WS-WATER TO WS-STATE
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 4 TO WS-X
     MOVE WS-LAVA TO WS-STATE
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE WS-OBSIDIAN TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Flowing lava next to water: cobblestone.
     MOVE "acceptance US12 29a 3.1 given a water source when flowing lava is placed beside it then it becomes cobblestone" TO TL-CASE
     MOVE 3 TO WS-Z
     MOVE 24 TO WS-Z
     MOVE 3 TO WS-X
     MOVE WS-WATER TO WS-STATE
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 4 TO WS-X
     COMPUTE WS-STATE = WS-LAVA + 2
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE WS-COBBLE TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Soul soil below and blue ice beside: basalt.
     MOVE "acceptance US12 29a 3.2 given soul soil below and blue ice beside when flowing lava is placed then it becomes basalt" TO TL-CASE
     MOVE 14 TO WS-X
     MOVE 99 TO WS-Y
     MOVE 21 TO WS-Z
     MOVE WS-SOIL TO WS-STATE
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 100 TO WS-Y
     MOVE 15 TO WS-X
     MOVE WS-ICE TO WS-STATE
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 14 TO WS-X
     COMPUTE WS-STATE = WS-LAVA + 2
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE WS-BASALT TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Lava falling onto water makes stone.
     MOVE "acceptance US12 29a 2.8 given lava above a water source when the lava tick runs then the water cell is stone" TO TL-CASE
     MOVE 20 TO WS-X
     MOVE 10 TO WS-Z
     MOVE 100 TO WS-Y
     MOVE WS-WATER TO WS-STATE
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 101 TO WS-Y
     MOVE WS-LAVA TO WS-STATE
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 40 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     MOVE 100 TO WS-Y
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE WS-STONE TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Lava on a platform flows with the lava rules (drop-off 2, delay 30).
     MOVE "acceptance US12 29a 2.1 given a lava source on a platform when 31 ticks pass then the neighbours are flowing lava of level 2 (drop-off 2)"
         TO TL-CASE
     MOVE 28 TO WS-X
     MOVE 18 TO WS-Z
     MOVE 100 TO WS-Y
     MOVE WS-LAVA TO WS-STATE
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 31 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     MOVE 29 TO WS-X
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     COMPUTE WS-STATE = WS-STATE - WS-LAVA
     MOVE WS-STATE TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Water over an edge falls: the cell below the source is falling water (level 8).
     MOVE "acceptance US12 29a 2.3 given a water source in the air when its tick runs then the cell below is falling water (level 8)" TO TL-CASE
     MOVE 30 TO WS-X
     MOVE 28 TO WS-Z
     MOVE 120 TO WS-Y
     MOVE WS-WATER TO WS-STATE
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 11 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     MOVE 119 TO WS-Y
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     COMPUTE WS-STATE = WS-STATE - WS-WATER
     MOVE WS-STATE TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "8" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The cell above a source: getNewLiquid reads the source below (coverage of the read of the cell below; the answer is the empty fluid
*>   because nothing flows into the cell from the sides).
     MOVE "acceptance US12 29a 2.3 given a water source when the new state of the cell above it is asked then nothing flows there (empty)" TO TL-CASE
     MOVE 120 TO WS-Y
     MOVE 121 TO WS-Y
     MOVE 1 TO WS-FLUID
     CALL "FLUID-NEW" USING WS-DIM WS-X WS-Y WS-Z WS-FLUID WS-CODE WS-AMOUNT WS-FALLING
     MOVE WS-CODE TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Random ticks.
     MOVE "acceptance US12 33 2.4 given a randomly ticking block when 300 ticks run then the random tick reached a position of its section "
         & "(G in the trace of the machinery)" TO TL-CASE
     CALL "BU-ENSURE"
     MOVE 1 TO BU-TRACE-ON
     MOVE 0 TO BU-TRACE-LENGTH
     MOVE 2 TO WS-BLOCK
     MOVE 11 TO WS-RULE-KIND
     CALL "BU-RULE-ADD" USING WS-RULE-KIND WS-BLOCK WS-RULE-EFFECT WS-RULE-ARG WS-RULE-FLAGS
     PERFORM VARYING WS-DX FROM 0 BY 1 UNTIL WS-DX > 15
         PERFORM VARYING WS-DZ FROM 0 BY 1 UNTIL WS-DZ > 15
             MOVE WS-DX TO WS-X
             MOVE WS-DZ TO WS-Z
             MOVE 90 TO WS-Y
             MOVE 2 TO WS-STATE
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
         END-PERFORM
     END-PERFORM
     MOVE 300 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     MOVE 0 TO WS-N
     COMPUTE WS-COUNT = BU-TRACE-LENGTH - 1
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-COUNT
         IF BU-TRACE(WS-K:2) = "G "
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     IF WS-N > 0
         MOVE "random ticks seen" TO TL-OBSERVED
     ELSE
         MOVE "none" TO TL-OBSERVED
     END-IF
     MOVE "random ticks seen" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> A greystone platform of 7 x 7 cells under every scenario of the test (x 2 to 8 and 10 to 16, z 20 to 26 and 8 to 12, and so on): simply the cells
*> the scenarios stand on, y 99.
 PLATFORM.
     MOVE 99 TO WS-Y
     MOVE 2 TO WS-STATE
     PERFORM VARYING WS-X FROM 1 BY 1 UNTIL WS-X > 31
         PERFORM VARYING WS-Z FROM 8 BY 1 UNTIL WS-Z > 28
             IF WS-Y = 99 AND NOT (WS-X = 14 AND WS-Z = 21) AND NOT (WS-X = 30 AND WS-Z = 28)
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
             END-IF
         END-PERFORM
     END-PERFORM.

*> Adds a block with the key WS-KEY and WS-COUNT states (the index being the level for the liquids), solid or not (WS-SOLID), after the last block
*> and state of the tables; WS-BASE is its first state.
 INSTALL.
     COMPUTE WS-N = CB-BLOCK-COUNT + 1
     MOVE WS-KEY TO CB-KEY(WS-N)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO CB-KEY-LENGTH(WS-N)
     MOVE WS-SOLID TO CB-SOLID(WS-N) CB-OPAQUE(WS-N)
     MOVE 0 TO CB-LIGHT(WS-N) CB-CLASS(WS-N) CB-TOOL-REQ(WS-N) CB-NEED-TIER(WS-N)
     MOVE -1 TO CB-BREAK-MS(WS-N)
     MOVE CB-STATE-COUNT TO WS-BASE
     MOVE WS-BASE TO CB-FIRST-STATE(WS-N) CB-DEFAULT-STATE(WS-N)
     MOVE WS-COUNT TO CB-STATES(WS-N)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-COUNT
         COMPUTE CB-S-BLOCK(WS-BASE + WS-K) = WS-N - 1
         MOVE 0 TO CB-S-LIGHT(WS-BASE + WS-K)
     END-PERFORM
     ADD 1 TO CB-BLOCK-COUNT
     ADD WS-COUNT TO CB-STATE-COUNT
     ADD 1 TO CB-EPOCH.
 END PROGRAM ACC-US12-WORLDSIM-LAVA.

 COPY CORETEST.
