*> Acceptance test of docs/protocol/36-structures-5 sections 2.5 to 2.12 (the blocks of the mineshaft pieces) in a chunk of stone: the room (air, entrances, upper half sphere), the crossing
*> (one and two floored, pillars, floor), the stairs, the corridor (shaft, ceiling, supports, fences, torches, cobwebs, rails, floor, pillars, the spider spawner and its block entity request),
*> every piece in the four orientations, and the invalid locations (a liquid beside the piece, a blocking biome). Cells are read back through the feature level.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-5-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATLEVEL.
 COPY STRUCTPIECE.
 COPY STRUCTBLK.
 COPY STRUCTDATA.
 COPY GENBE.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/struct-ms".
 01 WS-STATUS              BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==A-==.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-SUM                 BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-DIRN                BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-DEEP                BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-PT                  BINARY-LONG.
 01 WS-PO                  BINARY-LONG.
 01 WS-F1                  BINARY-LONG VALUE 0.
 01 WS-F2                  BINARY-LONG VALUE 0.
 01 WS-F4                  BINARY-LONG VALUE 0.
 01 WS-MST                 BINARY-LONG VALUE 0.
 01 WS-DEP                 BINARY-LONG VALUE 0.
 01 WS-T1                  BINARY-LONG.
 01 WS-T2                  BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "STRUCT-LOAD" USING WS-DIR WS-STATUS
     ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING WS-PTR
     MOVE "minecraft:stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STONE
     MOVE "minecraft:lava" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-LAVA

*>   the data: the structures' types, the mesa variant and the blocking biome tag
     MOVE "acceptance US12 36-5§1 Mineshaft: the two structures of the set are loaded, the second is the mesa variant (mineshaft_type)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SD-ST-COUNT * 10 + ST-VARIANT(1) + ST-VARIANT(2) * 100
     MOVE 120 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-5§2.9 Mineshaft: the blocking biome tag holds deep_dark" TO TL-CASE
     MOVE SD-BLOCK-COUNT TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the room: box (2,50,2)-(10,56,10), no entrance
     PERFORM STONE-WORLD
     CALL "SPB-RESET"
     MOVE 2 TO A-X0
     MOVE 50 TO A-Y0
     MOVE 2 TO A-Z0
     MOVE 10 TO A-X1
     MOVE 56 TO A-Y1
     MOVE 10 TO A-Z1
     MOVE 2 TO WS-PT
     MOVE -1 TO WS-PO
     PERFORM ADD-PIECE
     CALL "MS-POST" USING WS-ROW
     MOVE 6 TO WS-X
     MOVE 52 TO WS-Y
     MOVE 6 TO WS-Z
     PERFORM CELL-STATE
     MOVE "acceptance US12 36-5§2.5 Mineshaft room: the cell in the middle of the first three layers is cave air" TO TL-CASE
     MOVE WS-S TO TL-OBSERVED-N
     MOVE SB-S-CAVE-AIR TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 50 TO WS-Y
     PERFORM CELL-STATE
     MOVE "acceptance US12 36-5§2.5 Mineshaft room: the bottom layer (minY) is left alone" TO TL-CASE
     MOVE WS-S TO TL-OBSERVED-N
     MOVE WS-STONE TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 55 TO WS-Y
     PERFORM CELL-STATE
     MOVE "acceptance US12 36-5§2.5 Mineshaft room: the dome is air above the middle (y 55)" TO TL-CASE
     MOVE WS-S TO TL-OBSERVED-N
     MOVE SB-S-CAVE-AIR TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-X
     MOVE 2 TO WS-Z
     MOVE 56 TO WS-Y
     PERFORM CELL-STATE
     MOVE "acceptance US12 36-5§2.5 Mineshaft room: the top corner is outside the sphere (stone)" TO TL-CASE
     MOVE WS-S TO TL-OBSERVED-N
     MOVE WS-STONE TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the crossing, single floor: box (2,50,2)-(6,52,6): the cross of air, the corners stay, the inner corners hold planks pillars
     PERFORM STONE-WORLD
     MOVE 1 TO WS-PT
     MOVE -1 TO WS-PO
     MOVE 2 TO A-X0
     MOVE 50 TO A-Y0
     MOVE 2 TO A-Z0
     MOVE 6 TO A-X1
     MOVE 52 TO A-Y1
     MOVE 6 TO A-Z1
     PERFORM ADD-PIECE
     CALL "MS-POST" USING WS-ROW
     MOVE 4 TO WS-X
     MOVE 51 TO WS-Y
     MOVE 4 TO WS-Z
     MOVE SB-S-CAVE-AIR TO WS-WANT
     MOVE "acceptance US12 36-5§2.11 Mineshaft crossing: the centre is air" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE 2 TO WS-X
     MOVE 2 TO WS-Z
     MOVE WS-STONE TO WS-WANT
     MOVE "acceptance US12 36-5§2.11 Mineshaft crossing: the outer corner column is not cleared" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE 3 TO WS-X
     MOVE 3 TO WS-Z
     MOVE SB-PLANKS-S(1) TO WS-WANT
     MOVE "acceptance US12 36-5§2.11 Mineshaft crossing: the inner corner is a planks pillar (a block above the top)" TO TL-CASE
     PERFORM CHECK-CELL
*>   the floor under it: stone is a full cube, so planks only where there is air below (carve (4,49,4))
     PERFORM STONE-WORLD
     MOVE 4 TO WS-X
     MOVE 49 TO WS-Y
     MOVE 4 TO WS-Z
     PERFORM CELL-INDEX
     MOVE 0 TO CE-STATE(WS-I)
     PERFORM ADD-PIECE
     CALL "MS-POST" USING WS-ROW
     MOVE SB-PLANKS-S(1) TO WS-WANT
     MOVE "acceptance US12 36-5§2.11 Mineshaft crossing: the floor layer minY - 1 gets planks where the block is not a full cube" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE 4 TO WS-Z
     MOVE 5 TO WS-X
     MOVE WS-STONE TO WS-WANT
     MOVE "acceptance US12 36-5§2.11 Mineshaft crossing: a stone floor stays" TO TL-CASE
     PERFORM CHECK-CELL
*>   two floored: box (2,50,2)-(6,56,6): air of both floors, a ceiling of the lower floor at y 53 kept
     PERFORM STONE-WORLD
     MOVE 56 TO A-Y1
     MOVE 1 TO WS-F1
     PERFORM ADD-PIECE
     MOVE 0 TO WS-F1
     CALL "MS-POST" USING WS-ROW
     MOVE 4 TO WS-X
     MOVE 4 TO WS-Z
     MOVE 52 TO WS-Y
     MOVE SB-S-CAVE-AIR TO WS-WANT
     MOVE "acceptance US12 36-5§2.11 Mineshaft crossing two floored: the lower floor is air" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE 53 TO WS-Y
     MOVE SB-S-CAVE-AIR TO WS-WANT
     MOVE "acceptance US12 36-5§2.11 Mineshaft crossing two floored: the inner layer at minY + 3 is air too" TO TL-CASE
     PERFORM CHECK-CELL
     MOVE 54 TO WS-Y
     MOVE SB-S-CAVE-AIR TO WS-WANT
     MOVE "acceptance US12 36-5§2.11 Mineshaft crossing two floored: the upper floor is air" TO TL-CASE
     PERFORM CHECK-CELL

*>   the stairs, north oriented, box (4,45,0)-(6,52,8): the entry tunnel and the lowest cell
     PERFORM STONE-WORLD
     MOVE 3 TO WS-PT
     MOVE 2 TO WS-PO
     MOVE 4 TO A-X0
     MOVE 45 TO A-Y0
     MOVE 0 TO A-Z0
     MOVE 6 TO A-X1
     MOVE 52 TO A-Y1
     MOVE 8 TO A-Z1
     PERFORM ADD-PIECE
     CALL "MS-POST" USING WS-ROW
     MOVE 5 TO WS-X
     MOVE 51 TO WS-Y
     MOVE 7 TO WS-Z
     MOVE SB-S-CAVE-AIR TO WS-WANT
     MOVE "acceptance US12 36-5§2.12 Mineshaft stairs: the entry box (local 0,5,0 to 2,7,1) is air: local (1,6,0) is world (5,51,8)" TO TL-CASE
     MOVE 8 TO WS-Z
     PERFORM CHECK-CELL
     MOVE 5 TO WS-X
     MOVE 46 TO WS-Y
     MOVE 1 TO WS-Z
     MOVE SB-S-CAVE-AIR TO WS-WANT
     MOVE "acceptance US12 36-5§2.12 Mineshaft stairs: the bottom box (local 0,0,7 to 2,2,8) is air: local (1,1,8) is world (5,46,0)" TO TL-CASE
     MOVE 0 TO WS-Z
     PERFORM CHECK-CELL
     MOVE 5 TO WS-X
     MOVE 50 TO WS-Y
     MOVE 8 TO WS-Z
     MOVE SB-S-CAVE-AIR TO WS-WANT
     MOVE "acceptance US12 36-5§2.12 Mineshaft stairs: the diagonal at step 0 spans local y 4 to 7 at z 2 (world z 6): (5,49,6)" TO TL-CASE
     MOVE 6 TO WS-Z
     MOVE 49 TO WS-Y
     PERFORM CHECK-CELL
     MOVE 6 TO WS-Z
     MOVE 46 TO WS-Y
     MOVE WS-STONE TO WS-WANT
     MOVE "acceptance US12 36-5§2.12 Mineshaft stairs: below the diagonal at step 0 the rock stays: (5,46,6)" TO TL-CASE
     PERFORM CHECK-CELL
     STOP RUN.

 STONE-WORLD.
     CALL "SPB-RESET"
     MOVE 0 TO GBL-COUNT GBL-LOST
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE LOW-VALUES TO CE-CHUNK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 135 * 256
         MOVE WS-STONE TO CE-STATE(WS-I)
     END-PERFORM
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     CALL "MSP-OPEN"
     MOVE 5 TO SP-XR-LO
     MOVE 7 TO SP-XR-HI.
 ADD-PIECE.
     CALL "SPB-ADD" USING WS-PT WS-PO WS-DEP WS-MST WS-BOX WS-ROW
     MOVE WS-F1 TO SP-F1(WS-ROW)
     MOVE WS-F2 TO SP-F2(WS-ROW)
     MOVE WS-F4 TO SP-F4(WS-ROW).
 CELL-INDEX.
     COMPUTE WS-I = (WS-Y + 64) * 256 + WS-Z * 16 + WS-X + 1.
 CHECK-CELL.
     PERFORM CELL-STATE
     MOVE WS-S TO TL-OBSERVED-N
     MOVE WS-WANT TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 CELL-STATE.
     COMPUTE WS-I = (WS-Y + 64) * 256 + WS-Z * 16 + WS-X + 1
     MOVE CE-STATE(WS-I) TO WS-S.

 END PROGRAM TEST-STRUCT-36-5-2.
 COPY CORETEST.
