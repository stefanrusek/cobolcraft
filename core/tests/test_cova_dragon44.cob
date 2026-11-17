*> Implementation test (coverage lane A; docs/protocol/21 section 6.4, 44 part 9 section 1; core/src/dragon-44.cob): the degree wrap and the arctangent in every quadrant and on both axes, the
*> path to a goal outside the allowed nodes (it ends at the explored node nearest to it), the speeds of the landing, charging and hovering phases, and the wall check that leaves a block of
*> a namespaced "light" key in place.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-DRAGON44.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY DRAGSTATE.
 COPY FIGHTRT.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STONE               BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-KEY-SAVED           PIC X(48).
 01 WS-A                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-DEG                 FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-DIGIT               PIC 9.
 01 WS-FROM                BINARY-LONG VALUE 12.
 01 WS-TO                  BINARY-LONG VALUE 3.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-NO2                 BINARY-LONG VALUE 0.
 01 WS-NO3                 BINARY-LONG VALUE 0.
 01 WS-NO4                 BINARY-LONG VALUE 0.
 01 WS-PHASE               BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-WALL                BINARY-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-MOVED               FLOAT-LONG.
 01 WS-YS                  FLOAT-LONG.
 01 WS-ZS                  FLOAT-LONG.
 01 WS-TABLE.
    05 FILLER              PIC X(48) VALUE "010100010000000100".
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
*>   Mth.wrapDegrees: 200 wraps to -160, 180 to -180, -190 to 170.
     MOVE 200 TO WS-A
     CALL "DRAGON-WRAP" USING WS-A
     MOVE "test cova dragon44 200 degrees wrap to -160" TO WS-CASE
     MOVE -160 TO WS-E
     COMPUTE WS-O ROUNDED = WS-A
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE 180 TO WS-A
     CALL "DRAGON-WRAP" USING WS-A
     MOVE "test cova dragon44 180 degrees wrap to -180" TO WS-CASE
     MOVE -180 TO WS-E
     COMPUTE WS-O ROUNDED = WS-A
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE -190 TO WS-A
     CALL "DRAGON-WRAP" USING WS-A
     MOVE "test cova dragon44 -190 degrees wrap to 170" TO WS-CASE
     MOVE 170 TO WS-E
     COMPUTE WS-O ROUNDED = WS-A
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   atan2(y, x) in degrees for the four quadrants and the axes.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         EVALUATE WS-I
             WHEN 1
                 MOVE 1 TO WS-Y
                 MOVE 1 TO WS-X
                 MOVE 45 TO WS-E
             WHEN 2
                 MOVE 1 TO WS-Y
                 MOVE -1 TO WS-X
                 MOVE 135 TO WS-E
             WHEN 3
                 MOVE -1 TO WS-Y
                 MOVE -1 TO WS-X
                 MOVE -135 TO WS-E
             WHEN 4
                 MOVE 1 TO WS-Y
                 MOVE 0 TO WS-X
                 MOVE 90 TO WS-E
             WHEN 5
                 MOVE -1 TO WS-Y
                 MOVE 0 TO WS-X
                 MOVE -90 TO WS-E
             WHEN OTHER
                 MOVE 0 TO WS-Y
                 MOVE 0 TO WS-X
                 MOVE 0 TO WS-E
         END-EVALUATE
         CALL "DRAGON-ATAN2" USING WS-Y WS-X WS-DEG
         MOVE SPACES TO WS-CASE
         MOVE WS-I TO WS-DIGIT
         STRING "test cova dragon44 the arctangent case " WS-DIGIT " is the expected angle" DELIMITED BY SIZE INTO WS-CASE
         COMPUTE WS-O ROUNDED = WS-DEG
         CALL "CA-N" USING WS-CASE WS-E WS-O
     END-PERFORM
*>   A goal outside the allowed nodes (3, with no crystals only 12 to 23 are allowed): the path ends at an explored node.
     MOVE 0 TO FR-CRYSTALS
     CALL "DRAGON-PATH" USING WS-FROM WS-TO WS-NO WS-NO2 WS-NO3 WS-NO4 FR-CRYSTALS
     MOVE "test cova dragon44 an unreachable goal still gives a path" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE DG-HAS-PATH TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE "test cova dragon44 the path ends at an allowed node (12 to 23)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF DG-PATH-NODE(DG-PATH-N) >= 12 AND DG-PATH-NODE(DG-PATH-N) <= 23
         MOVE 1 TO WS-O
     END-IF
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   The speed of each phase moves the dragon further the faster the phase (landing 1.5, hovering 1.0, charging 3.0 per step at rest).
     MOVE 0 TO WS-X
     MOVE 150 TO WS-Y
     MOVE 0 TO WS-A
     CALL "DRAGON-SPAWN" USING WS-DIM WS-X WS-Y WS-A WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         EVALUATE WS-I
             WHEN 1
                 MOVE 3 TO DG-PHASE
             WHEN 2
                 MOVE 8 TO DG-PHASE
             WHEN OTHER
                 MOVE 10 TO DG-PHASE
         END-EVALUATE
         MOVE 0 TO EN-X(WS-ROW)
         MOVE 150 TO EN-Y(WS-ROW)
         MOVE 0 TO EN-Z(WS-ROW)
         MOVE 0 TO EN-VX(WS-ROW)
         MOVE 0 TO EN-VY(WS-ROW)
         MOVE 0 TO EN-VZ(WS-ROW)
         MOVE 0 TO EN-YAW(WS-ROW)
         MOVE 1 TO DG-HAS-TARGET
         MOVE 0 TO DG-TX
         MOVE 150 TO DG-TY
         MOVE -50 TO DG-TZ
         MOVE 0 TO DG-YROT-A
         CALL "DRAGON-MOVE" USING WS-ROW
         MOVE SPACES TO WS-CASE
         MOVE WS-I TO WS-DIGIT
         STRING "test cova dragon44 a step toward a target in phase case " WS-DIGIT " heads for it (z velocity negative)" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1 TO WS-E
         MOVE 0 TO WS-O
         IF EN-VZ(WS-ROW) < 0 OR EN-Z(WS-ROW) < 0
             MOVE 1 TO WS-O
         END-IF
         CALL "CA-N" USING WS-CASE WS-E WS-O
     END-PERFORM
*>   The wall check: a block of key minecraft:light (transparent to the dragon) stays and is no wall.
     MOVE 0 TO DG-PHASE
     MOVE 0 TO EN-YAW(WS-ROW)
     MOVE 0 TO EN-X(WS-ROW)
     MOVE 150 TO EN-Y(WS-ROW)
     MOVE 0 TO EN-Z(WS-ROW)
     CALL "DRAGON-PARTS" USING WS-ROW
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     COMPUTE WS-IDX = CB-S-BLOCK(WS-STONE + 1) + 1
     MOVE CB-KEY(WS-IDX) TO WS-KEY-SAVED
     MOVE "minecraft:light" TO CB-KEY(WS-IDX)
     COMPUTE WS-SX = FUNCTION INTEGER(DG-PART-X(1))
     COMPUTE WS-SY = FUNCTION INTEGER(DG-PART-Y(1))
     COMPUTE WS-SZ = FUNCTION INTEGER(DG-PART-Z(1))
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-SX WS-SY WS-SZ WS-STONE
     CALL "DRAGON-WALLS" USING WS-ROW WS-WALL
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-SX WS-SY WS-SZ WS-STATE
     MOVE WS-KEY-SAVED TO CB-KEY(WS-IDX)
     MOVE "test cova dragon44 a light block in the head box is left in place" TO WS-CASE
     MOVE WS-STONE TO WS-E
     MOVE WS-STATE TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-DRAGON44.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY COVATEST.
