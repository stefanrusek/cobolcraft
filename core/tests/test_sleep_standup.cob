*> Implementation test, lane bugsleep: SLEEP-STAND-UP (core/src/sleep-vil.cob) picks where somebody stands when it leaves a bed (a villager that wakes, a player who leaves the bed):
*> the first free cell beside the head half (+x, -x, +z, then the head's other neighbours are the foot), then beside the foot half, a free cell having no solid block at the feet or over
*> the head and a solid floor; with none it is the middle of the cell above the head half. A bed facing south: foot at (x, y, z - 1), head at (x, y, z).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SLEEP-STANDUP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-STONE               BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-FOOT                BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-HX                  BINARY-LONG.
 01 WS-HY                  BINARY-LONG.
 01 WS-HZ                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-UP                  BINARY-LONG.
 01 WS-DOWN                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-OX                  FLOAT-LONG.
 01 WS-OY                  FLOAT-LONG.
 01 WS-OZ                  FLOAT-LONG.
 01 WS-GOT-X               BINARY-LONG.
 01 WS-GOT-Y               BINARY-LONG.
 01 WS-GOT-Z               BINARY-LONG.
 01 WS-WANT-X              BINARY-LONG.
 01 WS-WANT-Y              BINARY-LONG.
 01 WS-WANT-Z              BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "TEST-STANDARD-TABLES"
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     MOVE "minecraft:stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STONE
     MOVE "minecraft:red_bed" TO WS-KEY
     MOVE "facing=south,occupied=false,part=head" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-HEAD
     MOVE "facing=south,occupied=false,part=foot" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-FOOT
     COMPUTE WS-HX = FUNCTION INTEGER(PL-X(WS-ROW)) + 3
     COMPUTE WS-HY = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-HZ = FUNCTION INTEGER(PL-Z(WS-ROW)) + 4
     COMPUTE WS-FZ = WS-HZ - 1
     COMPUTE WS-UP = WS-HY + 1
     COMPUTE WS-DOWN = WS-HY - 1
     MOVE "N" TO TL-MODE

     PERFORM BUILD-AREA
     MOVE "stand up with the whole area free: the cell beside the head half in +x" TO TL-CASE
     COMPUTE WS-WANT-X = WS-HX + 1
     MOVE WS-HZ TO WS-WANT-Z
     MOVE WS-HY TO WS-WANT-Y
     PERFORM CHECK-STAND

     PERFORM BUILD-AREA
     COMPUTE WS-X = WS-HX + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-HY WS-HZ WS-STONE
     MOVE "stand up with a solid block at the feet in +x: the cell beside the head half in -x" TO TL-CASE
     COMPUTE WS-WANT-X = WS-HX - 1
     PERFORM CHECK-STAND

     COMPUTE WS-X = WS-HX - 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-HY WS-HZ WS-STONE
     MOVE "stand up with +x and -x blocked: the cell in front of the head half (z + 1)" TO TL-CASE
     MOVE WS-HX TO WS-WANT-X
     COMPUTE WS-WANT-Z = WS-HZ + 1
     PERFORM CHECK-STAND

     COMPUTE WS-Z = WS-HZ + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-HY WS-Z WS-STONE
     MOVE "stand up with the head's three neighbours blocked: the cell beside the foot half in +x" TO TL-CASE
     COMPUTE WS-WANT-X = WS-HX + 1
     MOVE WS-FZ TO WS-WANT-Z
     PERFORM CHECK-STAND

     PERFORM BUILD-AREA
     COMPUTE WS-X = WS-HX + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-UP WS-HZ WS-STONE
     MOVE "stand up with a solid block over the head room in +x: the cell in -x" TO TL-CASE
     COMPUTE WS-WANT-X = WS-HX - 1
     MOVE WS-HZ TO WS-WANT-Z
     PERFORM CHECK-STAND

     PERFORM BUILD-AREA
     COMPUTE WS-X = WS-HX + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-DOWN WS-HZ WS-AIR
     MOVE "stand up with no floor under +x: the cell in -x" TO TL-CASE
     COMPUTE WS-WANT-X = WS-HX - 1
     PERFORM CHECK-STAND

*>   No free cell at all (every neighbour of both halves is stone): the middle of the cell above the head half.
     PERFORM BUILD-AREA
     PERFORM VARYING WS-X FROM -1 BY 1 UNTIL WS-X > 1
         PERFORM VARYING WS-Z FROM -2 BY 1 UNTIL WS-Z > 1
             COMPUTE WS-GOT-X = WS-HX + WS-X
             COMPUTE WS-GOT-Z = WS-HZ + WS-Z
             IF WS-X NOT = 0 OR WS-Z < -1 OR WS-Z > 0
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-GOT-X WS-HY WS-GOT-Z WS-STONE
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "stand up with no free cell beside the bed: the middle of the cell above the head half" TO TL-CASE
     MOVE WS-HX TO WS-WANT-X
     MOVE WS-HZ TO WS-WANT-Z
     COMPUTE WS-WANT-Y = WS-HY + 1
     PERFORM CHECK-STAND
     STOP RUN.

*> The area x - 2 to x + 2, z - 3 to z + 2: stone floor, air at the feet and the head, the whole bed (foot at z - 1, head at z) in the middle.
 BUILD-AREA.
     PERFORM VARYING WS-X FROM -2 BY 1 UNTIL WS-X > 2
         PERFORM VARYING WS-Z FROM -3 BY 1 UNTIL WS-Z > 2
             COMPUTE WS-GOT-X = WS-HX + WS-X
             COMPUTE WS-GOT-Z = WS-HZ + WS-Z
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-GOT-X WS-DOWN WS-GOT-Z WS-STONE
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-GOT-X WS-HY WS-GOT-Z WS-AIR
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-GOT-X WS-UP WS-GOT-Z WS-AIR
         END-PERFORM
     END-PERFORM
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-HY WS-HZ WS-HEAD
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-HY WS-FZ WS-FOOT
     MOVE WS-HY TO WS-WANT-Y.

*> The cell the program names against WS-WANT-X, WS-WANT-Y, WS-WANT-Z (the cell, the middle is +0.5; the cell above the head half gives y + 1).
 CHECK-STAND.
     CALL "SLEEP-STAND-UP" USING WS-DIM WS-HX WS-HY WS-HZ WS-OX WS-OY WS-OZ
     COMPUTE WS-GOT-X = FUNCTION INTEGER(WS-OX * 1000 + 0.5)
     COMPUTE WS-GOT-Y = FUNCTION INTEGER(WS-OY * 1000 + 0.5)
     COMPUTE WS-GOT-Z = FUNCTION INTEGER(WS-OZ * 1000 + 0.5)
     COMPUTE WS-E1 = WS-WANT-X * 1000 + 500
     COMPUTE WS-E2 = WS-WANT-Y * 1000
     COMPUTE WS-E3 = WS-WANT-Z * 1000 + 500
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) "," FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-GOT-X TO WS-E1
     MOVE WS-GOT-Y TO WS-E2
     MOVE WS-GOT-Z TO WS-E3
     STRING FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) "," FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-HY TO WS-WANT-Y.
 END PROGRAM TEST-SLEEP-STANDUP.
 COPY CORETEST.
 COPY BETEST.
