*> Acceptance test of the common helpers of OceanMonumentPiece (docs/protocol/36-structures-6-ocean.md section 5.6; core/src/struct-mon-geo.cob): generateBox (every cell of the box, both ends inclusive, nothing outside the
*> chunk write box), generateWaterBox (ice, packed ice, blue ice and water stay; any other block becomes air at or above the sea level and water below it), generateBoxOnFillOnly (only over a water source block),
*> generateDefaultFloor (with the opening: the eight boxes and the 2 x 2 hole edged with bricks; without: one prismarine box), chunkIntersects (the corners converted to the world, touching counts) and spawnElder (a
*> request only when the world position lies inside the write box, no persistence). The cases are written from the table of 5.6 over an empty window of the feature level.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-6-5-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTMON.
 COPY STRUCTPIECE.
 COPY MTDATA.
 COPY GENENT.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-N2                  BINARY-LONG.
 01 WS-N3                  BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-OPEN                BINARY-LONG.
 01 WS-LINE                PIC X(12).
 01 WS-WANT-LINE           PIC X(12).
 01 WS-ORIENT              BINARY-LONG.
 01 WS-BW                  BINARY-LONG VALUE 8.
 01 WS-BH                  BINARY-LONG VALUE 4.
 01 WS-BD                  BINARY-LONG VALUE 8.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG VALUE 40.
 01 WS-BZ                  BINARY-LONG.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-DIGITS              PIC X(12) VALUE "0123456789AB".
 01 WS-TALLY               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FL2                 BINARY-LONG VALUE 2.
 01 WS-OKF                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "MT-SETUP"
*>   ---- generateBox: both ends inclusive; the local box (1, 1, 1) to (3, 2, 2) of the south frame (origin (2, 40, 2)) is the world box x 3 to 5, y 41 to 42, z 3 to 4
     MOVE 0 TO WS-CX WS-CZ
     MOVE 2 TO WS-BX WS-BZ
     MOVE 40 TO WS-BY
     MOVE 0 TO WS-ORIENT
     PERFORM FRAME-OPEN
     MOVE 1 TO WS-X WS-Y WS-Z
     MOVE 3 TO WS-X1
     MOVE 2 TO WS-Y1 WS-Z1
     MOVE 2 TO WS-B
     CALL "MONP-OP" USING "B" WS-X WS-Y WS-Z WS-X1 WS-Y1 WS-Z1 WS-B
     MOVE 0 TO WS-N WS-BAD
     PERFORM VARYING WS-Y FROM 40 BY 1 UNTIL WS-Y > 44
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 11
             PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 11
                 PERFORM CELL-CODE
                 IF WS-CODE = 2
                     ADD 1 TO WS-N
                 END-IF
                 MOVE 0 TO WS-FLAG
                 IF WS-X >= 3 AND WS-X <= 5 AND WS-Y >= 41 AND WS-Y <= 42 AND WS-Z >= 3 AND WS-Z <= 4
                     MOVE 1 TO WS-FLAG
                 END-IF
                 IF (WS-CODE = 2 AND WS-FLAG = 0) OR (WS-CODE NOT = 2 AND WS-FLAG = 1)
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-6§5.6 Common helpers of `OceanMonumentPiece`: generateBox writes the 3 x 2 x 2 cells of its box, both ends inclusive" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§5.6 Common helpers of `OceanMonumentPiece`: generateBox writes no other cell and leaves none of its own" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   ---- a box that reaches outside the chunk write box: a south frame with x0 = -3: the local line (0, 0, 0) to (5, 0, 0) is the world x -3 to 2 at z 2, only x 0 to 2 lie in chunk (0, 0)
     MOVE -3 TO WS-BX
     MOVE 2 TO WS-BZ
     PERFORM FRAME-OPEN
     MOVE 0 TO WS-X WS-Y WS-Z
     MOVE 5 TO WS-X1
     MOVE 0 TO WS-Y1 WS-Z1
     MOVE 1 TO WS-B
     CALL "MONP-OP" USING "B" WS-X WS-Y WS-Z WS-X1 WS-Y1 WS-Z1 WS-B
     MOVE 0 TO WS-N
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
         MOVE 40 TO WS-Y
         MOVE 2 TO WS-Z
         PERFORM CELL-CODE
         IF WS-CODE = 1
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-6§5.6 Common helpers of `OceanMonumentPiece`: a cell outside the chunk write box is skipped (3 of 6 cells written)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   ---- generateWaterBox below and at the sea level 63: a row of stone, air, ice, packed ice, blue ice and water at y 62 and y 63; the frame origin y 60 makes the local layers 2 and 3
     MOVE 0 TO WS-BX
     MOVE 60 TO WS-BY
     PERFORM FRAME-OPEN
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 5
         PERFORM VARYING WS-Y FROM 62 BY 1 UNTIL WS-Y > 63
             MOVE WS-K TO WS-X
             MOVE 2 TO WS-Z
             EVALUATE WS-K
                 WHEN 0
                     MOVE 8 TO WS-CODE
                 WHEN 1
                     MOVE 0 TO WS-CODE
                 WHEN 2
                     MOVE 9 TO WS-CODE
                 WHEN 3
                     MOVE 10 TO WS-CODE
                 WHEN 4
                     MOVE 11 TO WS-CODE
                 WHEN OTHER
                     MOVE 7 TO WS-CODE
             END-EVALUATE
             PERFORM CELL-SET
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-X WS-Z
     MOVE 2 TO WS-Y
     MOVE 5 TO WS-X1
     MOVE 3 TO WS-Y1
     MOVE 0 TO WS-Z1 WS-B
     CALL "MONP-OP" USING "W" WS-X WS-Y WS-Z WS-X1 WS-Y1 WS-Z1 WS-B
     MOVE SPACES TO WS-LINE
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 5
         MOVE WS-K TO WS-X
         MOVE 2 TO WS-Z
         MOVE 62 TO WS-Y
         PERFORM CELL-CODE
         COMPUTE WS-N = WS-CODE + 1
         MOVE WS-DIGITS(WS-N:1) TO WS-LINE(WS-K + 1:1)
         MOVE 63 TO WS-Y
         PERFORM CELL-CODE
         COMPUTE WS-N = WS-CODE + 1
         MOVE WS-DIGITS(WS-N:1) TO WS-LINE(WS-K + 7:1)
     END-PERFORM
     MOVE "779AB7009AB7" TO WS-WANT-LINE
     MOVE "acceptance US12 36-6§5.6 Common helpers of `OceanMonumentPiece`: generateWaterBox keeps ice, packed ice, blue ice and water; the rest is water below the sea level and air at or above it" TO TL-CASE
     PERFORM CHECK-LINE
*>   ---- generateBoxOnFillOnly: only the water source of a row of water, stone, air and ice takes the block
     PERFORM FRAME-OPEN
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 3
         MOVE WS-K TO WS-X
         MOVE 62 TO WS-Y
         MOVE 2 TO WS-Z
         EVALUATE WS-K
             WHEN 0
                 MOVE 7 TO WS-CODE
             WHEN 1
                 MOVE 8 TO WS-CODE
             WHEN 2
                 MOVE 0 TO WS-CODE
             WHEN OTHER
                 MOVE 9 TO WS-CODE
         END-EVALUATE
         PERFORM CELL-SET
     END-PERFORM
     MOVE 0 TO WS-X WS-Z
     MOVE 2 TO WS-Y
     MOVE 3 TO WS-X1
     MOVE 2 TO WS-Y1
     MOVE 0 TO WS-Z1
     MOVE 1 TO WS-B
     CALL "MONP-OP" USING "F" WS-X WS-Y WS-Z WS-X1 WS-Y1 WS-Z1 WS-B
     MOVE SPACES TO WS-LINE
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 3
         MOVE WS-K TO WS-X
         MOVE 2 TO WS-Z
         MOVE 62 TO WS-Y
         PERFORM CELL-CODE
         COMPUTE WS-N = WS-CODE + 1
         MOVE WS-DIGITS(WS-N:1) TO WS-LINE(WS-K + 1:1)
     END-PERFORM
     MOVE "1809        " TO WS-WANT-LINE
     MOVE "acceptance US12 36-6§5.6 Common helpers of `OceanMonumentPiece`: generateBoxOnFillOnly writes only over a water source block" TO TL-CASE
     PERFORM CHECK-LINE
*>   ---- generateDefaultFloor with the opening at the cell offset (0, 0) and (8, 0): 52 prismarine, the 8 bricks of the edge and the 2 x 2 hole left empty
     MOVE 40 TO WS-BY
     PERFORM FRAME-OPEN
     MOVE 1 TO WS-OPEN
     MOVE 0 TO WS-X WS-Z
     CALL "MONP-FLOOR" USING WS-X WS-Z WS-OPEN
     MOVE 8 TO WS-X
     MOVE 0 TO WS-Z
     CALL "MONP-FLOOR" USING WS-X WS-Z WS-OPEN
     PERFORM FLOOR-COUNT
     MOVE "acceptance US12 36-6§5.6 Common helpers of `OceanMonumentPiece`: generateDefaultFloor with the opening makes 52 prismarine blocks in each cell" TO TL-CASE
     MOVE 104 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§5.6 Common helpers of `OceanMonumentPiece`: generateDefaultFloor with the opening edges the hole with 8 bricks in each cell" TO TL-CASE
     MOVE 16 TO TL-EXPECTED-N
     MOVE WS-N2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§5.6 Common helpers of `OceanMonumentPiece`: generateDefaultFloor with the opening leaves the 2 x 2 shaft empty (x 3 to 4, z 3 to 4 of the cell)" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE WS-N3 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§5.6 Common helpers of `OceanMonumentPiece`: generateDefaultFloor with the opening puts the bricks at (3..4, 2), (3..4, 5), (2, 3..4) and (5, 3..4)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   ---- without the opening: one prismarine box of 8 x 8
     PERFORM FRAME-OPEN
     MOVE 0 TO WS-OPEN
     MOVE 0 TO WS-X WS-Z
     CALL "MONP-FLOOR" USING WS-X WS-Z WS-OPEN
     PERFORM FLOOR-COUNT
     MOVE "acceptance US12 36-6§5.6 Common helpers of `OceanMonumentPiece`: generateDefaultFloor without the opening is one 8 x 8 prismarine box" TO TL-CASE
     MOVE 64 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   ---- chunkIntersects: a north frame with origin x 10: local x 0 to 7 is world x 10 to 17 (and local z 0 is the box's far side)
     MOVE 10 TO WS-BX
     MOVE 2 TO WS-BZ
     MOVE 2 TO WS-ORIENT
     MOVE 0 TO WS-CX
     PERFORM FRAME-OPEN
     MOVE 0 TO WS-X
     MOVE 0 TO WS-Z
     MOVE 5 TO WS-X1
     MOVE 7 TO WS-Z1
     CALL "MONP-CHUNK-INT" USING WS-X WS-Z WS-X1 WS-Z1 WS-FLAG
     MOVE "acceptance US12 36-6§5.6 Common helpers of `OceanMonumentPiece`: chunkIntersects is true for the corners over world x 10 to 15 in chunk 0" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-X
     CALL "MONP-CHUNK-INT" USING WS-X WS-Z WS-X1 WS-Z1 WS-FLAG
     MOVE 7 TO WS-X1
     CALL "MONP-CHUNK-INT" USING WS-X WS-Z WS-X1 WS-Z1 WS-FLAG
     MOVE "acceptance US12 36-6§5.6 Common helpers of `OceanMonumentPiece`: chunkIntersects is false for the corners over world x 16 to 17 in chunk 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-X
     MOVE 6 TO WS-X1
     CALL "MONP-CHUNK-INT" USING WS-X WS-Z WS-X1 WS-Z1 WS-FLAG
     MOVE "acceptance US12 36-6§5.6 Common helpers of `OceanMonumentPiece`: chunkIntersects counts a rectangle that touches the box on its edge (world x 15 to 16 in chunk 0)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-CX
     PERFORM FRAME-OPEN
     MOVE 0 TO WS-X
     MOVE 5 TO WS-X1
     CALL "MONP-CHUNK-INT" USING WS-X WS-Z WS-X1 WS-Z1 WS-FLAG
     MOVE "acceptance US12 36-6§5.6 Common helpers of `OceanMonumentPiece`: chunkIntersects is false for the corners over world x 10 to 15 in chunk 1" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-X
     MOVE 7 TO WS-X1
     MOVE 5 TO WS-Z
     MOVE 5 TO WS-Z1
     CALL "MONP-CHUNK-INT" USING WS-X WS-Z WS-X1 WS-Z1 WS-FLAG
     MOVE "acceptance US12 36-6§5.6 Common helpers of `OceanMonumentPiece`: chunkIntersects tests z too (the line of local z 5 is world z 4, inside chunk z 0)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   ---- spawnElder: local (1, 1, 1) of the north frame at origin (2, 40, 2) is the world cell (3, 41, 8): one request at its centre in chunk 0, none in chunk 1, no persistence
     MOVE 2 TO WS-BX
     MOVE 0 TO WS-CX
     PERFORM FRAME-OPEN
     MOVE 0 TO GEL-COUNT GEL-LOST
     MOVE 1 TO WS-X WS-Y WS-Z
     CALL "MONP-ELDER" USING WS-X WS-Y WS-Z
     MOVE "acceptance US12 36-6§5.6 Common helpers of `OceanMonumentPiece`: spawnElder asks the entity channel for one elder guardian when the position is inside the write box" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE GEL-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     IF GEL-X(1) = 3.5 AND GEL-Y(1) = 41 AND GEL-Z(1) = 8.5
         MOVE 1 TO WS-N
     END-IF
     MOVE "acceptance US12 36-6§5.6 Common helpers of `OceanMonumentPiece`: spawnElder places the elder guardian at (x + 0.5, y, z + 0.5) of the block" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-TALLY
     INSPECT GEL-NBT(1)(1:GEL-LEN(1)) TALLYING WS-TALLY FOR ALL "minecraft:elder_guardian"
     MOVE 0 TO WS-N
     IF WS-TALLY = 1
         MOVE 0 TO WS-TALLY
         INSPECT GEL-NBT(1)(1:GEL-LEN(1)) TALLYING WS-TALLY FOR ALL "PersistenceRequired" & X"0000"
         MOVE WS-TALLY TO WS-N
     END-IF
     MOVE "acceptance US12 36-6§5.6 Common helpers of `OceanMonumentPiece`: spawnElder makes an elder guardian with no persistence call (PersistenceRequired 0)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-CX
     PERFORM FRAME-OPEN
     MOVE 0 TO GEL-COUNT GEL-LOST
     CALL "MONP-ELDER" USING WS-X WS-Y WS-Z
     MOVE "acceptance US12 36-6§5.6 Common helpers of `OceanMonumentPiece`: spawnElder makes no request in a pass whose write box does not hold the position" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE GEL-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.

*> an empty window of chunk (WS-CX, 0) and the scratch piece row (WS-BX, WS-BY, WS-BZ, direction WS-ORIENT as a 2-D data value) with the box of an 8 x 4 x 8 piece
 FRAME-OPEN.
     MOVE 0 TO WS-CZ
     CALL "MT-WINDOW" USING WS-CX WS-CZ
     CALL "MT-CLEAR"
     CALL "MONP-BLOCKS"
     CALL "SPB-MAKE-BOX" USING WS-BX WS-BY WS-BZ WS-ORIENT WS-BW WS-BH WS-BD WS-BOX
     MOVE SP-MAX TO MP-ROW
     MOVE WS-ORIENT TO SP-ORIENT(SP-MAX)
     MOVE B-X0 TO SP-X0(SP-MAX)
     MOVE B-Y0 TO SP-Y0(SP-MAX)
     MOVE B-Z0 TO SP-Z0(SP-MAX)
     MOVE B-X1 TO SP-X1(SP-MAX)
     MOVE B-Y1 TO SP-Y1(SP-MAX)
     MOVE B-Z1 TO SP-Z1(SP-MAX)
     MOVE 0 TO MP-XOFF MP-DESIGN MP-PILLAR.
*> the block code (MT-ST order) of the world cell WS-X WS-Y WS-Z, 99 when it is none of them
 CELL-CODE.
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     MOVE 99 TO WS-CODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         IF WS-STATE = MT-ST(WS-I)
             COMPUTE WS-CODE = WS-I - 1
         END-IF
     END-PERFORM.
*> writes the block code WS-CODE at the world cell WS-X WS-Y WS-Z
 CELL-SET.
     MOVE MT-ST(WS-CODE + 1) TO WS-STATE
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FL2 WS-OKF.
*> compares WS-LINE with WS-WANT-LINE character by character: the number of differences against 0
 CHECK-LINE.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 12
         IF WS-LINE(WS-K:1) NOT = WS-WANT-LINE(WS-K:1)
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
*> floor counts in the window row z 2 to 9, y 40, x 0 to 15: WS-N prismarine, WS-N2 bricks, WS-N3 air in the two shaft squares; WS-BAD the cells of the shaft edge that are not bricks
 FLOOR-COUNT.
     MOVE 0 TO WS-N WS-N2 WS-N3 WS-BAD
     MOVE 40 TO WS-Y
     PERFORM VARYING WS-Z FROM 2 BY 1 UNTIL WS-Z > 9
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
             CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
             IF WS-STATE = MT-ST(3)
                 ADD 1 TO WS-N
             END-IF
             IF WS-STATE = MT-ST(2)
                 ADD 1 TO WS-N2
             END-IF
             IF WS-STATE = MT-ST(1) AND (FUNCTION MOD(WS-X, 8) = 3 OR FUNCTION MOD(WS-X, 8) = 4) AND (WS-Z = 5 OR WS-Z = 6)
                 ADD 1 TO WS-N3
             END-IF
         END-PERFORM
     END-PERFORM.

 END PROGRAM TEST-STRUCT-36-6-5-6.
 COPY MONTEST.
 COPY NOSPAWN.
 COPY CORETEST.
