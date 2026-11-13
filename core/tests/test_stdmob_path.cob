*> Implementation test (002-lane-mobs, T4003; docs/protocol/18 section 5.2 and 5.3): STDMOB-PATH, the weighted A* of a walking mob over the cells of a
*> world: four neighbours, a step up of one block, a drop of up to 3 blocks, no walking through solid blocks or liquid, the heuristic weighted 1.5, a
*> budget of visited nodes, and when the target is not reached the path to the node that came closest. The world is a stone platform of 9 x 9
*> cells high above the terrain (standard block states set into the test world), with walls, a step and a water strip built on it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STDMOB-PATH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY DIMENSIONS.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-BLOCK               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-STONE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-XLO                 BINARY-LONG.
 01 WS-XHI                 BINARY-LONG.
 01 WS-ZLO                 BINARY-LONG.
 01 WS-ZHI                 BINARY-LONG.
 01 WS-ZHI3                BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Y3                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG VALUE 2.
 01 WS-BUDGET              BINARY-LONG VALUE 300.
 01 WS-COUNT               BINARY-LONG.
 01 WS-REACHED             BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-MAXY                BINARY-LONG.
 01 WS-PATH-TABLE.
    05 WS-PATH OCCURS 128 TIMES.
       10 WS-PX            BINARY-LONG.
       10 WS-PY            BINARY-LONG.
       10 WS-PZ            BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STONE = FUNCTION NUMVAL(WS-STATE-TEXT)
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:water" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-WATER = FUNCTION NUMVAL(WS-STATE-TEXT)
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 40
     COMPUTE WS-XLO = WS-CX - 4
     COMPUTE WS-XHI = WS-CX + 4
     COMPUTE WS-ZLO = WS-CZ - 4
     COMPUTE WS-ZHI = WS-CZ + 4
     COMPUTE WS-ZHI3 = WS-CZ + 3
     COMPUTE WS-Y1 = WS-FLOOR + 1
     COMPUTE WS-Y3 = WS-FLOOR + 3
*>   The platform: floor y = WS-FLOOR, x and z from centre - 4 to + 4; air above it (the cells to y + 4 are cleared).
     PERFORM VARYING WS-X FROM WS-XLO BY 1 UNTIL WS-X > WS-XHI
         PERFORM VARYING WS-Z FROM WS-ZLO BY 1 UNTIL WS-Z > WS-ZHI
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FLOOR WS-Z WS-STONE
         END-PERFORM
     END-PERFORM
     COMPUTE WS-SY = WS-FLOOR + 1
     COMPUTE WS-TY = WS-FLOOR + 1
     MOVE WS-CX TO WS-SX
     MOVE WS-CZ TO WS-SZ
     COMPUTE WS-SX = WS-CX - 4
     COMPUTE WS-TX = WS-CX + 4
     MOVE WS-CZ TO WS-TZ

*>   Open floor: 8 steps east, 9 nodes, all at the floor's standing height.
     PERFORM FIND-PATH
     MOVE "N" TO TL-MODE
     MOVE "test stdmob path: across an open floor the path has 9 nodes" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test stdmob path: it starts at the start and ends at the target" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-PX(1) = WS-SX AND WS-PZ(1) = WS-SZ AND WS-PX(WS-COUNT) = WS-TX AND WS-PZ(WS-COUNT) = WS-TZ
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test stdmob path: and the target was reached" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-REACHED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A wall of 3 blocks across the middle (x = centre) with a gap at z = centre + 4: the path goes round it, through the gap.
     PERFORM VARYING WS-Z FROM WS-ZLO BY 1 UNTIL WS-Z > WS-ZHI3
         PERFORM VARYING WS-Y FROM WS-Y1 BY 1 UNTIL WS-Y > WS-Y3
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y WS-Z WS-STONE
         END-PERFORM
     END-PERFORM
     PERFORM FIND-PATH
     MOVE "test stdmob path: a wall with a gap: the path is longer and reaches the target" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COUNT > 9 AND WS-REACHED = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test stdmob path: no node of it is inside the wall" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         IF WS-PX(WS-I) = WS-CX AND WS-PZ(WS-I) < WS-CZ + 4
             ADD 1 TO TL-OBSERVED-N
         END-IF
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Close the gap: the target cannot be reached; the path ends at the node nearest to it (the wall's west face).
     PERFORM VARYING WS-Y FROM WS-Y1 BY 1 UNTIL WS-Y > WS-Y3
         COMPUTE WS-Z = WS-CZ + 4
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y WS-Z WS-STONE
     END-PERFORM
     PERFORM FIND-PATH
     MOVE "test stdmob path: with the wall closed the target is not reached" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-REACHED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test stdmob path: but a partial path leads to the wall (a node next to it)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COUNT > 1 AND WS-PX(WS-COUNT) = WS-CX - 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Open the wall again; a single stone block in the way is stepped onto (a step up of one).
     PERFORM VARYING WS-Z FROM WS-ZLO BY 1 UNTIL WS-Z > WS-ZHI
         PERFORM VARYING WS-Y FROM WS-Y1 BY 1 UNTIL WS-Y > WS-Y3
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y WS-Z WS-AIR
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-Z FROM WS-ZLO BY 1 UNTIL WS-Z > WS-ZHI
         COMPUTE WS-Y = WS-FLOOR + 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y WS-Z WS-STONE
     END-PERFORM
     PERFORM FIND-PATH
     MOVE WS-FLOOR TO WS-MAXY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         IF WS-PY(WS-I) > WS-MAXY
             MOVE WS-PY(WS-I) TO WS-MAXY
         END-IF
     END-PERFORM
     MOVE "test stdmob path: a one-block step is climbed (a node one higher than the floor)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MAXY = WS-FLOOR + 2 AND WS-REACHED = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test stdmob path: and a node comes down again to the floor height" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-PY(WS-COUNT) = WS-FLOOR + 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A strip of water across the floor is not walked through: the path (budget permitting) avoids it or stops short.
     PERFORM VARYING WS-Z FROM WS-ZLO BY 1 UNTIL WS-Z > WS-ZHI
         COMPUTE WS-Y = WS-FLOOR + 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y WS-Z WS-AIR
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-FLOOR WS-Z WS-WATER
     END-PERFORM
     PERFORM FIND-PATH
     MOVE "test stdmob path: a strip of water is not crossed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         IF WS-PX(WS-I) = WS-CX
             ADD 1 TO TL-OBSERVED-N
         END-IF
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A zero budget visits nothing: a path of the start alone.
     MOVE 0 TO WS-BUDGET
     PERFORM FIND-PATH
     MOVE "test stdmob path: a budget of 0 nodes gives the start alone" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A start with no floor (a cell high in the air) has no path: count 0.
     MOVE 300 TO WS-BUDGET
     COMPUTE WS-SY = WS-FLOOR + 20
     PERFORM FIND-PATH
     MOVE "test stdmob path: a start in the air with no floor within reach gives no path" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Cells: below the world's lowest layer is solid; a cell with a block two above the floor has no head room for a mob of 2 cells.
     COMPUTE WS-Y = DM-MIN-Y(WS-DIM) - 1
     CALL "STDMOB-CELL" USING WS-DIM WS-CX WS-Y WS-CZ WS-COUNT
     MOVE "test stdmob path: a cell below the world is solid (type 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-Y = WS-FLOOR + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y WS-CZ WS-STONE
     COMPUTE WS-Y = WS-FLOOR + 1
     CALL "STDMOB-STANDABLE" USING WS-DIM WS-CX WS-Y WS-CZ WS-HEIGHT WS-COUNT
     MOVE "test stdmob path: a cell under a ceiling one above is no standing place for a mob of 2 cells" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 FIND-PATH.
     CALL "STDMOB-PATH" USING WS-DIM WS-SX WS-SY WS-SZ WS-TX WS-TY WS-TZ WS-HEIGHT WS-BUDGET WS-PATH-TABLE WS-COUNT WS-REACHED.
 END PROGRAM TEST-STDMOB-PATH.
 COPY CORETEST.
