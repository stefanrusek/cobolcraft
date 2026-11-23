*> Implementation test (wrap I3, T2458/T2459; docs/protocol/20 section 6.2 "Seen fraction"): the ray from a sample point to the explosion centre is cast with the collider block context. EXPLODE-RAY-HIT walks the
*> voxels exactly (every cell the segment enters), so a segment that clips the corner of a solid cell over less than the old 0.1 block step hits it, a segment that stays out of it does not, in every
*> direction, from inside a solid cell and with start and end in one cell.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-EXPLODE-RAY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STONE               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-X1                  FLOAT-LONG.
 01 WS-Y1                  FLOAT-LONG.
 01 WS-Z1                  FLOAT-LONG.
 01 WS-X2                  FLOAT-LONG.
 01 WS-Y2                  FLOAT-LONG.
 01 WS-Z2                  FLOAT-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-A1                  FLOAT-LONG.
 01 WS-B1                  FLOAT-LONG.
 01 WS-C1                  FLOAT-LONG.
 01 WS-A2                  FLOAT-LONG.
 01 WS-B2                  FLOAT-LONG.
 01 WS-C2                  FLOAT-LONG.
 01 WS-EXPECT              BINARY-LONG.
 01 WS-NAME                PIC X(160).
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 20
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 40
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
*>   One stone cell at (1, 0, 1) relative to the base cell (the base is above the terrain: air all round).
     COMPUTE WS-SX = WS-BX + 1
     COMPUTE WS-SZ = WS-BZ + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-SX WS-BY WS-SZ WS-STONE
*>   A segment that clips the corner of the stone over 0.057 block (x + z = 2.04 enters x, z in [1, 1.04]): the 0.1 step missed it.
     MOVE "implementation 20 6.2 a segment clipping the corner of a solid cell over less than 0.1 block hits it" TO WS-NAME
     MOVE 0.0 TO WS-A1
     MOVE 0.5 TO WS-B1
     MOVE 2.04 TO WS-C1
     MOVE 2.04 TO WS-A2
     MOVE 0.5 TO WS-B2
     MOVE 0.0 TO WS-C2
     MOVE 1 TO WS-EXPECT
     PERFORM CHECK-RAY
     MOVE "implementation 20 6.2 a segment that passes the corner on the air side (x + z = 1.96) does not hit" TO WS-NAME
     MOVE 1.96 TO WS-C1
     MOVE 1.96 TO WS-A2
     MOVE 0 TO WS-EXPECT
     PERFORM CHECK-RAY
*>   Through the middle of the cell in both directions of x.
     MOVE "implementation 20 6.2 along +x through the cell hits" TO WS-NAME
     MOVE 0.5 TO WS-A1
     MOVE 1.5 TO WS-C1
     MOVE 3.5 TO WS-A2
     MOVE 1.5 TO WS-C2
     MOVE 1 TO WS-EXPECT
     PERFORM CHECK-RAY
     MOVE "implementation 20 6.2 along -x through the cell hits" TO WS-NAME
     MOVE 3.5 TO WS-A1
     MOVE 0.5 TO WS-A2
     PERFORM CHECK-RAY
*>   Along y, down and up, through the cell.
     MOVE "implementation 20 6.2 down along y through the cell hits" TO WS-NAME
     MOVE 1.5 TO WS-A1
     MOVE 3.5 TO WS-B1
     MOVE 1.5 TO WS-C1
     MOVE 1.5 TO WS-A2
     MOVE -1.5 TO WS-B2
     MOVE 1.5 TO WS-C2
     PERFORM CHECK-RAY
     MOVE "implementation 20 6.2 up along y through the cell hits" TO WS-NAME
     MOVE -1.5 TO WS-B1
     MOVE 3.5 TO WS-B2
     PERFORM CHECK-RAY
*>   Along z through air, both directions.
     MOVE "implementation 20 6.2 along +z through air does not hit" TO WS-NAME
     MOVE 5.5 TO WS-A1
     MOVE 0.5 TO WS-B1
     MOVE 0.5 TO WS-C1
     MOVE 5.5 TO WS-A2
     MOVE 0.5 TO WS-B2
     MOVE 4.5 TO WS-C2
     MOVE 0 TO WS-EXPECT
     PERFORM CHECK-RAY
     MOVE "implementation 20 6.2 along -z through air does not hit" TO WS-NAME
     MOVE 4.5 TO WS-C1
     MOVE 0.5 TO WS-C2
     PERFORM CHECK-RAY
*>   Start in the stone: a hit at once. Start and end in one air cell: none.
     MOVE "implementation 20 6.2 a segment that starts inside a solid cell hits" TO WS-NAME
     MOVE 1.5 TO WS-A1
     MOVE 0.5 TO WS-B1
     MOVE 1.5 TO WS-C1
     MOVE 4.5 TO WS-A2
     MOVE 0.5 TO WS-B2
     MOVE 1.5 TO WS-C2
     MOVE 1 TO WS-EXPECT
     PERFORM CHECK-RAY
     MOVE "implementation 20 6.2 a segment inside one air cell does not hit" TO WS-NAME
     MOVE 5.2 TO WS-A1
     MOVE 5.3 TO WS-A2
     MOVE 5.4 TO WS-B1
     MOVE 5.6 TO WS-B2
     MOVE 5.1 TO WS-C1
     MOVE 5.7 TO WS-C2
     MOVE 0 TO WS-EXPECT
     PERFORM CHECK-RAY
*>   A slanted segment through all three axes, forwards and backwards, through the cell, and a slanted one beside it.
     MOVE "implementation 20 6.2 a slanted segment (+x, +y, +z) through the cell hits" TO WS-NAME
     MOVE 0.2 TO WS-A1
     MOVE 0.2 TO WS-B1
     MOVE 0.2 TO WS-C1
     MOVE 2.8 TO WS-A2
     MOVE 0.8 TO WS-B2
     MOVE 2.8 TO WS-C2
     MOVE 1 TO WS-EXPECT
     PERFORM CHECK-RAY
     MOVE "implementation 20 6.2 the slanted segment from the other end (-x, -y, -z) hits" TO WS-NAME
     MOVE 2.8 TO WS-A1
     MOVE 0.8 TO WS-B1
     MOVE 2.8 TO WS-C1
     MOVE 0.2 TO WS-A2
     MOVE 0.2 TO WS-B2
     MOVE 0.2 TO WS-C2
     PERFORM CHECK-RAY
     MOVE "implementation 20 6.2 a slanted segment that stays in air above the cell does not hit" TO WS-NAME
     MOVE 0.2 TO WS-A1
     MOVE 3.2 TO WS-B1
     MOVE 0.2 TO WS-C1
     MOVE 2.8 TO WS-A2
     MOVE 3.8 TO WS-B2
     MOVE 2.8 TO WS-C2
     MOVE 0 TO WS-EXPECT
     PERFORM CHECK-RAY
     STOP RUN.
 CHECK-RAY.
     COMPUTE WS-X1 = WS-BX + WS-A1
     COMPUTE WS-Y1 = WS-BY + WS-B1
     COMPUTE WS-Z1 = WS-BZ + WS-C1
     COMPUTE WS-X2 = WS-BX + WS-A2
     COMPUTE WS-Y2 = WS-BY + WS-B2
     COMPUTE WS-Z2 = WS-BZ + WS-C2
     CALL "EXPLODE-RAY-HIT" USING WS-DIM WS-X1 WS-Y1 WS-Z1 WS-X2 WS-Y2 WS-Z2 WS-HIT
     MOVE WS-NAME TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-EXPLODE-RAY.
 COPY CORETEST.
 COPY MOBSPTEST.
