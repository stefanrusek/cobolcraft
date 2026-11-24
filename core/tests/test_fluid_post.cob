*> Unit test, lane bugfountain: CHUNK-FLUID-POST (core/src/fluid-post.cob; docs/protocol/36-structures-1 section 6.5 placeBlock, 10 section 9, 29a section 2.1), the fluid ticks of a generated
*> chunk. A world of the cobolcraft set has no water or lava block, so nothing is scheduled. After the block tables are rebuilt from the standard set a chunk of air is written cell by cell
*> (as a generator writes it, no hook) and processed: a water or lava cell with air below or beside it, inside the chunk, gets a pending fluid tick (also at the chunk's edges and its
*> bottom layer); a cell shut in by solid blocks or by fluid gets none; a chunk with many such cells is capped.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FLUID-POST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY DIMENSIONS.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG VALUE 3.
 01 WS-CZ                  BINARY-LONG VALUE 5.
 01 WS-CZ2                 BINARY-LONG VALUE 6.
 01 WS-ROW                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-WATER-FIRST         BINARY-LONG.
 01 WS-LAVA-FIRST          BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-E                   BINARY-LONG.
 01 WS-FOUND-STATE         BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CELLS               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG VALUE 2.
 01 WS-KIND                BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-SET-STATE           BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CW-DIM(1) TO WS-DIM
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ WS-ROW
     CALL "CHUNK-FLUID-POST" USING WS-ROW WS-COUNT
     MOVE "test fluid post: a world of the cobolcraft set has no fluid block, so no tick is scheduled" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-STANDARD-TABLES"
     CALL "FLUID-ROLES" USING WS-WATER WS-LAVA WS-WATER-FIRST WS-LAVA-FIRST
     MOVE "stone" TO WS-KEY
     PERFORM FIND-STATE
     MOVE WS-FOUND-STATE TO WS-STONE
     COMPUTE WS-CELLS = DM-HEIGHT(WS-DIM) * 256
     MOVE DM-MIN-Y(WS-DIM) TO WS-MIN
*>   The chunk is all air.
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CELLS
         MOVE 0 TO CE-STATE(WS-I)
     END-PERFORM
*>   Water in the open air (60, 8, 8), lava at the corner (0, 70, 0) and the other corner (15, 71, 15), water on the bottom layer (5, min y, 5): four cells that spread.
     MOVE WS-WATER-FIRST TO WS-SET-STATE
     MOVE 8 TO WS-X
     COMPUTE WS-Y = WS-MIN + 10
     MOVE 8 TO WS-Z
     PERFORM PUT-CELL
     MOVE WS-LAVA-FIRST TO WS-SET-STATE
     MOVE 0 TO WS-X
     COMPUTE WS-Y = WS-MIN + 20
     MOVE 0 TO WS-Z
     PERFORM PUT-CELL
     MOVE 15 TO WS-X
     COMPUTE WS-Y = WS-MIN + 21
     MOVE 15 TO WS-Z
     PERFORM PUT-CELL
     MOVE WS-WATER-FIRST TO WS-SET-STATE
     MOVE 5 TO WS-X
     MOVE WS-MIN TO WS-Y
     MOVE 5 TO WS-Z
     PERFORM PUT-CELL
*>   Water shut in by stone on all six sides (8, 90, 8): no tick; two water cells one above the other in a stone shaft with a stone floor: none.
     COMPUTE WS-LO = WS-MIN + 30
     MOVE WS-STONE TO WS-SET-STATE
     PERFORM VARYING WS-X FROM 7 BY 1 UNTIL WS-X > 9
         PERFORM VARYING WS-Z FROM 7 BY 1 UNTIL WS-Z > 9
             PERFORM VARYING WS-Y FROM WS-LO BY 1 UNTIL WS-Y > WS-LO + 2
                 PERFORM PUT-CELL
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE WS-WATER-FIRST TO WS-SET-STATE
     MOVE 8 TO WS-X
     COMPUTE WS-Y = WS-MIN + 31
     MOVE 8 TO WS-Z
     PERFORM PUT-CELL
     CALL "CHUNK-FLUID-POST" USING WS-ROW WS-COUNT
     MOVE "test fluid post: a water or lava cell with air below or beside gets a tick (open air, chunk corners, bottom layer); one shut in by stone gets none" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-X = WS-CX * 16 + 8
     COMPUTE WS-Y = WS-MIN + 10
     COMPUTE WS-Z = WS-CZ * 16 + 8
     MOVE 1 TO WS-KIND
     CALL "BT-HAS" USING WS-DIM WS-TYPE WS-KIND WS-X WS-Y WS-Z WS-HAS
     MOVE "test fluid post: the open-air water source holds a pending fluid tick of fluid 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HAS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-X = WS-CX * 16
     COMPUTE WS-Y = WS-MIN + 20
     COMPUTE WS-Z = WS-CZ * 16
     MOVE 2 TO WS-KIND
     CALL "BT-HAS" USING WS-DIM WS-TYPE WS-KIND WS-X WS-Y WS-Z WS-HAS
     MOVE "test fluid post: the lava source at the chunk corner holds a pending fluid tick of fluid 2" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HAS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-X = WS-CX * 16 + 8
     COMPUTE WS-Y = WS-MIN + 31
     COMPUTE WS-Z = WS-CZ * 16 + 8
     MOVE 1 TO WS-KIND
     CALL "BT-HAS" USING WS-DIM WS-TYPE WS-KIND WS-X WS-Y WS-Z WS-HAS
     MOVE "test fluid post: the water shut in by stone holds no tick" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HAS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A sheet of water over air (256 cells with air below): the chunk's ticks stop at the cap of 128.
     CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-CX WS-CZ2 WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CELLS
         MOVE 0 TO CE-STATE(WS-I)
     END-PERFORM
     MOVE WS-WATER-FIRST TO WS-SET-STATE
     COMPUTE WS-Y = WS-MIN + 40
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             PERFORM PUT-CELL
         END-PERFORM
     END-PERFORM
     CALL "CHUNK-FLUID-POST" USING WS-ROW WS-COUNT
     MOVE "test fluid post: a sheet of 256 water cells over air is capped at 128 ticks" TO TL-CASE
     MOVE 128 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> The cell WS-X, WS-Y, WS-Z of the chunk WS-ROW (chunk-local x and z, world y) becomes the state WS-SET-STATE.
 PUT-CELL.
     COMPUTE WS-W = (WS-Y - DM-MIN-Y(WS-DIM)) * 256 + WS-Z * 16 + WS-X + 1
     MOVE WS-SET-STATE TO CE-STATE(WS-W).

 FIND-STATE.
     MOVE 0 TO WS-FOUND-STATE
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > CB-BLOCK-COUNT
         IF FUNCTION TRIM(CB-KEY(WS-E)) = FUNCTION TRIM(WS-KEY)
             MOVE CB-DEFAULT-STATE(WS-E) TO WS-FOUND-STATE
         END-IF
     END-PERFORM.
 END PROGRAM TEST-FLUID-POST.

 COPY NOSPAWN.
 COPY CORETEST.
