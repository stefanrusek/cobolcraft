*> Acceptance test of docs/protocol/36-structures-5-mineshaft-stronghold.md section 4.5 (local to world, T1536): a Straight piece (type shs, 30) with box (100,40,200)..(104,44,206) oriented
*> NORTH has the local position (1,2,1) at the world position (minX + 1, minY + 2, maxZ - 1) = (101,42,205); the same piece oriented EAST with box (100,40,200)..(106,44,204) has it at
*> (minX + z, minY + 2, minZ + x) = (101,42,201). The other two orientations of 36-1 section 6.4 (SOUTH: z + local z; WEST: maxX - z, minZ + x) are checked on the same boxes.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-5-4-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTPIECE.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-TYPE                BINARY-LONG VALUE 30.
 01 WS-DIR                 BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG VALUE 1.
 01 WS-MST                 BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LX                  BINARY-LONG VALUE 1.
 01 WS-LY                  BINARY-LONG VALUE 2.
 01 WS-LZ                  BINARY-LONG VALUE 1.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-TEXT                PIC X(30).
 01 WS-P                   BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "SPB-RESET"
     MOVE 100 TO B-X0
     MOVE 40 TO B-Y0
     MOVE 200 TO B-Z0
     MOVE 104 TO B-X1
     MOVE 44 TO B-Y1
     MOVE 206 TO B-Z1
     MOVE 2 TO WS-DIR
     CALL "SPB-ADD" USING WS-TYPE WS-DIR WS-DEPTH WS-MST WS-BOX WS-ROW
     PERFORM FORMAT-WORLD
     MOVE "acceptance US12 36-5§4.5 Local to world: a NORTH Straight piece with box (100,40,200)..(104,44,206): local (1,2,1) is (101,42,205)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "101 42 205" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SPB-RESET"
     MOVE 106 TO B-X1
     MOVE 204 TO B-Z1
     MOVE 3 TO WS-DIR
     CALL "SPB-ADD" USING WS-TYPE WS-DIR WS-DEPTH WS-MST WS-BOX WS-ROW
     PERFORM FORMAT-WORLD
     MOVE "acceptance US12 36-5§4.5 Local to world: the same piece oriented EAST with box (100,40,200)..(106,44,204): local (1,2,1) is (101,42,201)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "101 42 201" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   SOUTH: (minX + x, minY + y, minZ + z); WEST: (maxX - z, minY + y, minZ + x), on the box (100,40,200)..(106,44,204)
     CALL "SPB-RESET"
     MOVE 0 TO WS-DIR
     CALL "SPB-ADD" USING WS-TYPE WS-DIR WS-DEPTH WS-MST WS-BOX WS-ROW
     PERFORM FORMAT-WORLD
     MOVE "acceptance US12 36-5§4.5 Local to world: the same box oriented SOUTH: local (1,2,1) is (101,42,201)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "101 42 201" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SPB-RESET"
     MOVE 1 TO WS-DIR
     CALL "SPB-ADD" USING WS-TYPE WS-DIR WS-DEPTH WS-MST WS-BOX WS-ROW
     PERFORM FORMAT-WORLD
     MOVE "acceptance US12 36-5§4.5 Local to world: the same box oriented WEST: local (1,2,1) is (maxX - 1, minY + 2, minZ + 1) = (105,42,201)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "105 42 201" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 FORMAT-WORLD.
     CALL "SPB-WORLD" USING WS-ROW WS-LX WS-LY WS-LZ WS-WX WS-WY WS-WZ
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-P
     MOVE WS-WX TO WS-ED
     STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-P
     MOVE WS-WY TO WS-ED
     STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-P
     MOVE WS-WZ TO WS-ED
     STRING FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-P.
 END PROGRAM TEST-STRUCT-36-5-4-5.
