*> Acceptance test of the current on a ground item (docs/protocol/41 section 3.2, 29a sections 1.4 and 8.3; the part T0347 left open because the flow
*> vector was not in the documents): an item in a flowing water cell is pushed along the flow of the cell with the strength 0.014 (the normalised
*> vector times it), E8 of 29a (a cell of amount 7 between a source and a cell of amount 6 flows east); in lava the push is 0.0023333 and, as the item
*> is at rest, lifted to 0.0045; a source over a drop flows toward the water below the empty cell beside it; a cell beside another fluid does not
*> count that fluid; a falling cell beside stone flows toward its lower neighbour. The cobolcraft world has no liquids, so the test adds the blocks to
*> the block table.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US12-ITEM-CURRENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CITEMPHYS.
 COPY CITEMS.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-COUNT               BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG VALUE 2.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 32767.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-A                   PIC X(16).
 01 WS-B                   PIC X(16).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
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
*>   A platform at y 99 (x 1 to 31, z 8 to 28).
     MOVE 99 TO WS-BY
     PERFORM VARYING WS-BX FROM 1 BY 1 UNTIL WS-BX > 31
         PERFORM VARYING WS-BZ FROM 8 BY 1 UNTIL WS-BZ > 28
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
         END-PERFORM
     END-PERFORM
     MOVE "T" TO TL-MODE

*>   E8: a source (x 5), a flowing cell of amount 7 (x 6, level 1) and one of amount 6 (x 7, level 2) in a row at z 10, y 100.
     MOVE 100 TO WS-BY
     MOVE 10 TO WS-BZ
     MOVE 5 TO WS-BX
     MOVE WS-WATER TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 6 TO WS-BX
     COMPUTE WS-STATE = WS-WATER + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 7 TO WS-BX
     COMPUTE WS-STATE = WS-WATER + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 6.5 TO WS-X
     MOVE 100 TO WS-Y
     MOVE 10.5 TO WS-Z
     PERFORM ITEM-TICK
     MOVE "acceptance US2 41§3.2 given an item at rest in water of amount 7 between a source and amount 6 when a tick runs then the current "
         & "(E8, flow east) gives it 0.014 of speed east" TO TL-CASE
     MOVE "0.01400 0.00000" TO TL-EXPECTED
     PERFORM OBSERVE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Lava: the same row at x 15 to 17 (z 10): 0.0023333 lifted to 0.0045 for an item at rest.
     MOVE 15 TO WS-BX
     MOVE WS-LAVA TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 16 TO WS-BX
     COMPUTE WS-STATE = WS-LAVA + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 17 TO WS-BX
     COMPUTE WS-STATE = WS-LAVA + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 16.5 TO WS-X
     PERFORM ITEM-TICK
     MOVE "acceptance US2 41§3.2 given an item at rest in flowing lava when a tick runs then its push 0.0023333 is lifted to 0.0045" TO TL-CASE
     MOVE "0.00450 0.00000" TO TL-EXPECTED
     PERFORM OBSERVE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A source over a drop: a pillar (10, 100, 14), a source (10, 101, 14), the empty cell (11, 101, 14) over water of amount 7 (11, 100, 14),
*>   and the empty cell to the west over lava, which does not count: the flow goes east.
     MOVE 10 TO WS-BX
     MOVE 100 TO WS-BY
     MOVE 14 TO WS-BZ
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     MOVE 101 TO WS-BY
     MOVE WS-WATER TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 100 TO WS-BY
     MOVE 11 TO WS-BX
     COMPUTE WS-STATE = WS-WATER + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 9 TO WS-BX
     MOVE WS-LAVA TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 10.5 TO WS-X
     MOVE 101 TO WS-Y
     MOVE 14.5 TO WS-Z
     PERFORM ITEM-TICK
     MOVE "acceptance US2 41§3.2 given a source over a drop when a tick runs then the item flows east, toward the water below the empty cell" TO TL-CASE
     MOVE "0.01400 0.00000" TO TL-EXPECTED
     PERFORM OBSERVE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A cell beside another fluid and nothing else: no current. Water (20, 100, 14) with lava (19, 100, 14) at its west.
     MOVE 20 TO WS-BX
     MOVE 100 TO WS-BY
     MOVE WS-WATER TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 19 TO WS-BX
     MOVE WS-LAVA TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 20.5 TO WS-X
     MOVE 100 TO WS-Y
     PERFORM ITEM-TICK
     MOVE "acceptance US2 41§3.2 given water beside lava when a tick runs then the item gets no current" TO TL-CASE
     MOVE "0.00000 0.00000" TO TL-EXPECTED
     PERFORM OBSERVE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A falling cell (level 8) at x 25 with stone to its east and a cell of amount 6 (level 2) to its west, z 10: the flow beside a solid face is
*>   (west 0.1644, down 0.9864) after the second normalising, and an item takes that normalised vector: 0.0023 west (0.014 / 6.083) and 0.0138 down.
     MOVE 25 TO WS-BX
     MOVE 10 TO WS-BZ
     COMPUTE WS-STATE = WS-WATER + 8
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 26 TO WS-BX
     MOVE WS-STONE TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 24 TO WS-BX
     COMPUTE WS-STATE = WS-WATER + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 25.5 TO WS-X
     MOVE 10.5 TO WS-Z
     PERFORM ITEM-TICK
     MOVE "acceptance US2 41§3.2 given a falling cell beside stone and a lower cell to the west when a tick runs then the item is pushed west by 0.014 / 6.083" TO TL-CASE
     MOVE "-0.00230 0.00000" TO TL-EXPECTED
     PERFORM OBSERVE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Stone above the open north side of a falling cell counts as a solid face as well (no change of the direction).
     MOVE 101 TO WS-BY
     MOVE 25 TO WS-BX
     MOVE 9 TO WS-BZ
     MOVE WS-STONE TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
*>   Water over the west side counts as the same fluid there (not a solid face).
     MOVE 24 TO WS-BX
     MOVE 10 TO WS-BZ
     MOVE WS-WATER TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 100 TO WS-BY
     MOVE 25.5 TO WS-X
     MOVE 10.5 TO WS-Z
     PERFORM ITEM-TICK
     MOVE "acceptance US2 41§3.2 given stone over the open side of a falling cell and water over its west side when a tick runs then the "
         & "push is the same" TO TL-CASE
     MOVE "-0.00230 0.00000" TO TL-EXPECTED
     PERFORM OBSERVE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A cell without a fluid has no flow.
     MOVE 26 TO WS-BX
     MOVE 100 TO WS-BY
     MOVE 10 TO WS-BZ
     CALL "FLUID-FLOW-AT" USING WS-DIM WS-BX WS-BY WS-BZ WS-X WS-Y WS-Z
     CALL "ITT-F" USING WS-X WS-A
     CALL "ITT-F" USING WS-Z WS-B
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US2 41§3.2 given a cell of stone when its flow is asked then it is the zero vector" TO TL-CASE
     MOVE "0.00000 0.00000" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Spawns an item at (WS-X, WS-Y, WS-Z) at rest and runs one tick; WS-ROW is its row.
 ITEM-TICK.
     MOVE 0 TO WS-VX WS-VY WS-VZ
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-ONE WS-DELAY WS-ROW
     CALL "TEST-TICKS" USING WS-ONE.

*> "vx vz" of WS-ROW; the item is removed.
 OBSERVE.
     CALL "ITT-F" USING EN-VX(WS-ROW) WS-A
     CALL "ITT-F" USING EN-VZ(WS-ROW) WS-B
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "ENTITY-REMOVE" USING WS-ROW.

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
 END PROGRAM ACC-US12-ITEM-CURRENT.

 COPY CORETEST.
 COPY ITEMTEST.
