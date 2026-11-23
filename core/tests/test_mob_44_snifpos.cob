*> Implementation test (wrap C, T9215; 44 part 4 section 13, 44 part 3 section 2.19 B, 44 part 1 section 4.13): the sniffer's dig position: the light cost, the Animal walk
*> target value, LandRandomPos.getPos (ten attempts, the rejections and the scorer), canDig of a block (diggable, not explored, a path to it) and calculateDigPosition.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-44-SNIFPOS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY DIMENSIONS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-LOW                 BINARY-LONG VALUE 39.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-GRASS               BINARY-LONG VALUE 2.
 01 WS-STATE               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-WIDE                BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-COST                FLOAT-LONG.
 01 WS-SCORE               FLOAT-LONG.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 01 WS-SIZE-B              FLOAT-LONG.
 01 WS-DAMAGE              FLOAT-LONG VALUE 0.
 01 WS-SAFE                FLOAT-LONG VALUE 0.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-DARK                BINARY-LONG.
 01 WS-BRIGHT              BINARY-LONG.
 01 WS-BRIGHT-F            FLOAT-LONG.
 01 WS-MILLI               BINARY-DOUBLE.
 01 WS-KEY48               PIC X(48).
 01 WS-DISTINCT            BINARY-LONG.
 01 WS-SEEN                BINARY-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     MOVE 6000 TO CW-TIME
     MOVE 2 TO BW-DIFFICULTY
     MOVE "N" TO TL-MODE
     MOVE "minecraft:sniffer" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
*>   Two solid layers (stone at 39 under grass at 40), three layers of air above them.
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-LOW WS-STONE
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-GRASS
     COMPUTE WS-FX = WS-X0 + 24.5
     COMPUTE WS-FY = WS-FLOOR + 1
     COMPUTE WS-FZ = WS-Z0 + 24.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-A
     MOVE 1 TO EN-ON-GROUND(WS-A)
     COMPUTE WS-SX = WS-X0 + 24
     COMPUTE WS-SZ = WS-Z0 + 24
     COMPUTE WS-Y = WS-FLOOR + 1

*>   ---- the light cost (44-1 4.13): the cell above the grass in the day, and at night with the sky darkened.
     CALL "M44-LIGHT-COST" USING WS-DIM WS-SX WS-Y WS-SZ WS-COST
     COMPUTE WS-MILLI ROUNDED = WS-COST * 1000
     MOVE "wrapC 44-1 4.13 the light cost of full daylight is 0.5 (brightness 15: 1.0 - 0.5)" TO TL-CASE
     MOVE 500 TO TL-EXPECTED-N
     MOVE WS-MILLI TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 18000 TO CW-TIME
     CALL "STDMOB-LIGHTS" USING WS-DIM WS-SX WS-Y WS-SZ WS-SKY WS-BLOCK
     CALL "STDMOB-DARKEN" USING CW-TIME WS-DARK
     COMPUTE WS-BRIGHT = FUNCTION MAX(WS-BLOCK, WS-SKY - WS-DARK, 0)
     COMPUTE WS-BRIGHT-F = WS-BRIGHT / 15
     COMPUTE WS-MILLI ROUNDED = (WS-BRIGHT-F / (4 - 3 * WS-BRIGHT-F) - 0.5) * 1000
     MOVE WS-MILLI TO TL-EXPECTED-N
     CALL "M44-LIGHT-COST" USING WS-DIM WS-SX WS-Y WS-SZ WS-COST
     COMPUTE WS-MILLI ROUNDED = WS-COST * 1000
     MOVE "wrapC 44-1 4.13 the light cost at night follows the darkened brightness b / (4 - 3 b) - 0.5" TO TL-CASE
     MOVE WS-MILLI TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "wrapC 44-1 4.13 the light cost at night is below the daylight cost" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MILLI < 500
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6000 TO CW-TIME

*>   ---- Animal.getWalkTargetValue: 10 over grass; over any other block the light cost.
     CALL "M44-ANIMAL-SCORE" USING WS-DIM WS-SX WS-Y WS-SZ WS-SCORE
     MOVE "wrapC 44-1 4.13 Animal.getWalkTargetValue is 10 over a grass block" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-SCORE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:dirt" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-SX WS-FLOOR WS-SZ WS-STATE
     CALL "M44-ANIMAL-SCORE" USING WS-DIM WS-SX WS-Y WS-SZ WS-SCORE
     CALL "M44-LIGHT-COST" USING WS-DIM WS-SX WS-Y WS-SZ WS-COST
     COMPUTE WS-MILLI ROUNDED = WS-COST * 1000
     MOVE WS-MILLI TO TL-EXPECTED-N
     COMPUTE WS-MILLI ROUNDED = WS-SCORE * 1000
     MOVE "wrapC 44-1 4.13 Animal.getWalkTargetValue over dirt is the light cost" TO TL-CASE
     MOVE WS-MILLI TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:grass_block" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-SX WS-FLOOR WS-SZ WS-STATE

*>   ---- LandRandomPos.getPos(mob, 10, 3) over a field with a pond (x 30 to 34), a cactus strip (x 14 to 17) and two solid layers (the cell at the floor is solid with a solid
*>   cell below: it moves up out of solid). Every result: inside the box, a solid block below, not water, not a cactus below.
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     PERFORM VARYING WS-X FROM 30 BY 1 UNTIL WS-X > 37
         PERFORM VARYING WS-Z FROM 14 BY 1 UNTIL WS-Z > 34
             COMPUTE WS-BX = WS-X0 + WS-X
             COMPUTE WS-BZ = WS-Z0 + WS-Z
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-Y WS-BZ WS-STATE
         END-PERFORM
     END-PERFORM
     MOVE "minecraft:cactus" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     PERFORM VARYING WS-X FROM 14 BY 1 UNTIL WS-X > 17
         PERFORM VARYING WS-Z FROM 14 BY 1 UNTIL WS-Z > 34
             COMPUTE WS-BX = WS-X0 + WS-X
             COMPUTE WS-BZ = WS-Z0 + WS-Z
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-Y WS-BZ WS-STATE
         END-PERFORM
     END-PERFORM
     MOVE 10 TO WS-H
     MOVE 3 TO WS-V
     MOVE 0 TO WS-BAD WS-TOTAL WS-DISTINCT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
         MOVE 0 TO WS-SEEN(WS-I)
     END-PERFORM
     PERFORM 60 TIMES
         ADD 1 TO CW-TICKS
         CALL "M44-LAND-POS" USING WS-A WS-H WS-V WS-FOUND WS-BX WS-BY WS-BZ
         ADD WS-FOUND TO WS-TOTAL
         IF WS-FOUND = 1
             COMPUTE WS-I = WS-BX - WS-SX
             IF WS-I < -10 OR WS-I > 10
                 ADD 1 TO WS-BAD
             END-IF
             COMPUTE WS-I = WS-BZ - WS-SZ
             IF WS-I < -10 OR WS-I > 10
                 ADD 1 TO WS-BAD
             END-IF
             COMPUTE WS-I = WS-BX - WS-SX + 11
             IF WS-SEEN(WS-I) = 0
                 MOVE 1 TO WS-SEEN(WS-I)
                 ADD 1 TO WS-DISTINCT
             END-IF
             COMPUTE WS-J = WS-BY - 1
             CALL "STDMOB-CELL" USING WS-DIM WS-BX WS-J WS-BZ WS-CELL
             IF WS-CELL NOT = 1
                 ADD 1 TO WS-BAD
             END-IF
             CALL "IP-BLOCK-KEY" USING WS-DIM WS-BX WS-BY WS-BZ WS-KEY48 WS-LENGTH
             IF WS-KEY48 = "minecraft:water" OR WS-KEY48 = "minecraft:cactus"
                 ADD 1 TO WS-BAD
             END-IF
             CALL "IP-BLOCK-KEY" USING WS-DIM WS-BX WS-J WS-BZ WS-KEY48 WS-LENGTH
             IF WS-KEY48 = "minecraft:cactus"
                 ADD 1 TO WS-BAD
             END-IF
*>           Over this field a position above the grass block at the floor (y 41) is the best score (10 over grass): the solid cell at y 40 moved up to it.
             IF WS-BY NOT = WS-FLOOR + 1
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM
*>   Only the offsets that land on a cell with a solid block below survive (dy 0, and the solid layers moved up), so a call finds nothing when none of its ten attempts qualifies.
     MOVE "wrapC 44-3 2.19 LandRandomPos finds a position in most calls over an open field (at least 30 of 60)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TOTAL >= 30
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "wrapC 44-3 2.19 LandRandomPos results stay inside the box, stand on solid, avoid water and cactus and take the grass score (violations)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "wrapC 44-3 2.19 LandRandomPos draws a spread of x offsets (at least 8 distinct of 21)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DISTINCT >= 8
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   ---- the build height limits: a sniffer on the lowest layer never gets a position below the dimension.
     MOVE EN-Y(WS-A) TO WS-FY
     COMPUTE EN-Y(WS-A) = DM-MIN-Y(WS-DIM) + 1
     MOVE 0 TO WS-BAD
     PERFORM 40 TIMES
         ADD 1 TO CW-TICKS
         CALL "M44-LAND-POS" USING WS-A WS-H WS-V WS-FOUND WS-BX WS-BY WS-BZ
         IF WS-FOUND = 1 AND WS-BY < DM-MIN-Y(WS-DIM)
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "wrapC 44-3 2.19 LandRandomPos rejects a candidate below the build height (violations)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-FY TO EN-Y(WS-A)

*>   ---- canDig of a block: dirt with a path to it digs; stone does not; an explored block does not; a walled-in block has no path; one 21 blocks away has none (the search never leaves 15).
     MOVE "minecraft:dirt" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     COMPUTE WS-BX = WS-SX + 4
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-FLOOR WS-SZ WS-STATE
     CALL "M44-SNIF-CAN-DIG-AT" USING WS-A WS-BX WS-FLOOR WS-SZ WS-OK
     MOVE "wrapC 44-4 13 canDig: a dirt block with a path to it" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-BX = WS-SX - 4
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-FLOOR WS-SZ WS-STATE
     CALL "M44-SNIF-CAN-DIG-AT" USING WS-A WS-BX WS-FLOOR WS-SZ WS-OK
     MOVE "wrapC 44-4 13 canDig: a stone block is not in sniffer_diggable_block" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-BX = WS-SX + 4
     MOVE 1 TO EN-SNIF-EXP-N(WS-A)
     MOVE WS-BX TO EN-SNIF-EXP-X(WS-A, 1)
     MOVE WS-FLOOR TO EN-SNIF-EXP-Y(WS-A, 1)
     MOVE WS-SZ TO EN-SNIF-EXP-Z(WS-A, 1)
     CALL "M44-SNIF-CAN-DIG-AT" USING WS-A WS-BX WS-FLOOR WS-SZ WS-OK
     MOVE "wrapC 44-4 13 canDig: an explored position is not dug again" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-SNIF-EXP-N(WS-A)
*>   Out of reach: dirt 21 blocks east (the path search never leaves 15 blocks of its start).
     MOVE "minecraft:dirt" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     COMPUTE WS-BX = WS-X0 + 45
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-FLOOR WS-SZ WS-STATE
     CALL "M44-SNIF-CAN-DIG-AT" USING WS-A WS-BX WS-FLOOR WS-SZ WS-OK
     MOVE "wrapC 44-4 13 canDig: dirt 21 blocks away has no path (the search stays within 15)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Walled in: a ring of stone three high around the dirt block at (x + 2, z - 8), grass elsewhere.
     COMPUTE WS-BX = WS-SX + 2
     COMPUTE WS-BZ = WS-SZ - 8
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-FLOOR WS-BZ WS-STATE
     CALL "M44-SNIF-CAN-DIG-AT" USING WS-A WS-BX WS-FLOOR WS-BZ WS-OK
     MOVE "wrapC 44-4 13 canDig: dirt in the open 8 blocks away has a path" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     PERFORM VARYING WS-X FROM -1 BY 1 UNTIL WS-X > 1
         PERFORM VARYING WS-Z FROM -1 BY 1 UNTIL WS-Z > 1
             IF WS-X NOT = 0 OR WS-Z NOT = 0
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
                     COMPUTE WS-J = WS-X + WS-BX
                     COMPUTE WS-CELL = WS-Z + WS-BZ
                     COMPUTE WS-Y = WS-FLOOR + WS-I
                     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-J WS-Y WS-CELL WS-STATE
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     CALL "M44-SNIF-CAN-DIG-AT" USING WS-A WS-BX WS-FLOOR WS-BZ WS-OK
     MOVE "wrapC 44-4 13 canDig: the same dirt walled in by stone has no path" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   ---- calculateDigPosition over a field of dirt: the first candidate (radius 10) wins and can be dug; over stone nothing is found; outside the world border nothing is found.
     MOVE "minecraft:dirt" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 47
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 47
             COMPUTE WS-BX = WS-X0 + WS-X
             COMPUTE WS-BZ = WS-Z0 + WS-Z
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-FLOOR WS-BZ WS-STATE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
                 COMPUTE WS-Y = WS-FLOOR + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-Y WS-BZ WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-BAD
     PERFORM 20 TIMES
         ADD 1 TO CW-TICKS
         CALL "M44-SNIF-DIG-POS" USING WS-A WS-FOUND WS-BX WS-BY WS-BZ
         IF WS-FOUND = 0
             ADD 1 TO WS-BAD
         ELSE
             COMPUTE WS-I = WS-BX - WS-SX
             IF WS-I < -10 OR WS-I > 10
                 ADD 1 TO WS-BAD
             END-IF
             COMPUTE WS-I = WS-BZ - WS-SZ
             IF WS-I < -10 OR WS-I > 10
                 ADD 1 TO WS-BAD
             END-IF
             COMPUTE WS-J = WS-BY - 1
             CALL "M44-SNIF-CAN-DIG-AT" USING WS-A WS-BX WS-J WS-BZ WS-OK
             IF WS-OK = 0
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM
     MOVE "wrapC 44-4 13 calculateDigPosition over dirt finds a diggable position within the first radius (violations)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A border of size 1 far away leaves no candidate inside it.
     COMPUTE WS-CX = WS-X0 + 5000
     MOVE WS-CX TO WS-CZ
     MOVE 1 TO WS-SIZE-B
     CALL "WORLDSIM-BORDER-SET" USING WS-DIM WS-CX WS-CZ WS-SIZE-B WS-DAMAGE WS-SAFE
     CALL "M44-SNIF-DIG-POS" USING WS-A WS-FOUND WS-BX WS-BY WS-BZ
     MOVE "wrapC 44-4 13 calculateDigPosition: a candidate outside the world border is not taken" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 59999968 TO WS-SIZE-B
     MOVE 0 TO WS-CX WS-CZ
     CALL "WORLDSIM-BORDER-SET" USING WS-DIM WS-CX WS-CZ WS-SIZE-B WS-DAMAGE WS-SAFE
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     CALL "M44-SNIF-DIG-POS" USING WS-A WS-FOUND WS-BX WS-BY WS-BZ
     MOVE "wrapC 44-4 13 calculateDigPosition over stone finds nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-44-SNIFPOS.
 COPY CORETEST.
 COPY MOBSPTEST.
