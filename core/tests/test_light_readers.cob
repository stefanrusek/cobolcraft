*> Implementation test (lane genlimits; docs/protocol/32-light-engine.md section 5.2, 29b-2 sections 6.2 and 7.1, 18 section 6.5, 20 sections 3.3, 4.1 and 10): the readers of the
*> stored sky light other than the monster spawn rule (lane bugvillage) see the sky light the sky engine has: the stored light (light.cob stand-in) is 15 above a column's topmost block and
*> 0 at and below it with no sideways spreading, so under the eaves of a house (a 5 x 5 roof 3 above the floor: the cell below its centre is 3 steps from open sky, light 12) it read 0.
*> LIGHT-SKY-SPREAD (core/src/light-spread.cob) gives the spread value. Per reader, under the 5 x 5 roof (light 12) and under a 25 x 25 roof (13 steps from open sky: dark, the stored 0):
*>   - GB-CROP-RT (crop growth needs raw brightness 9): wheat on farmland grows (500 ticks) under the small roof, never under the large one;
*>   - GB-SAPLING-RT (the cell above the sapling needs 9): the sapling advances to stage 1 (200 ticks) under the small roof, never under the large one;
*>   - STDMOB-SPOT-OK mode 1 (an animal needs brightness above 8 over grass): passes under the small roof, fails under the large one;
*>   - STDMOB-SPOT-OK mode 2 (a monster by day): never passes under the small roof, passes under the large one;
*>   - STDMOB-REINF-DARK (the zombie reinforcement dark check of 20 section 4.1, by day): never passes under the small roof, passes under the large one;
*>   - STDMOB-SLIME-RULE (the swamp slime's raw brightness at most nextInt(8)): by day at the full moon never spawns in the open or under the small roof, spawns under the large one.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LIGHT-READERS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY XORO.
 COPY STDMOBS.
 COPY BRWORLD.
 COPY CELLS.
 COPY CBLOCKS.
 01 WS-CASE               PIC X(120).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-SEED               BINARY-DOUBLE UNSIGNED.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-PX                 BINARY-LONG.
 01 WS-PY                 BINARY-LONG.
 01 WS-PZ                 BINARY-LONG.
 01 WS-FY                 BINARY-LONG.
 01 WS-QX                 BINARY-LONG.
 01 WS-QZ                 BINARY-LONG.
 01 WS-CX                 BINARY-LONG.
 01 WS-CZ                 BINARY-LONG.
 01 WS-CHUNK              BINARY-LONG.
 01 WS-Y                  BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-J                  BINARY-LONG.
 01 WS-PASS               BINARY-LONG.
 01 WS-OK                 BINARY-LONG.
 01 WS-FLOOR-SIZE         BINARY-LONG.
 01 WS-KIND               BINARY-LONG.
 01 WS-STATE              BINARY-LONG.
 01 WS-KEY                PIC X(112).
 01 WS-BX                 BINARY-LONG.
 01 WS-BZ                 BINARY-LONG.
 01 WS-BY                 BINARY-LONG.
 01 WS-A                  BINARY-LONG.
 01 WS-B                  BINARY-LONG.
 01 WS-HALF               BINARY-LONG.
 01 WS-X0                 BINARY-LONG.
 01 WS-X1                 BINARY-LONG.
 01 WS-Z0                 BINARY-LONG.
 01 WS-Z1                 BINARY-LONG.
 01 WS-MODE               BINARY-LONG.
 01 WS-R                  BINARY-DOUBLE.
 01 WS-REASON             BINARY-LONG VALUE 0.
 01 WS-WHEAT              BINARY-LONG.
 01 WS-SAPLING            BINARY-LONG.
 01 WS-FARMLAND           BINARY-LONG.
 01 WS-AIR                BINARY-LONG VALUE 0.
 01 WS-SWAMP              BINARY-LONG VALUE 0.
 01 WS-SLIME-HITS         BINARY-LONG.
 01 WS-CROP-X             BINARY-LONG.
 01 WS-SAP-X              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-PY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     MOVE 6000 TO CW-TIME
     MOVE "minecraft:farmland" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-FARMLAND
     MOVE "minecraft:wheat" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WHEAT
     MOVE "minecraft:oak_sapling" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-SAPLING
*>   Site A: a grass floor 20 x 20 east of the player and 40 above it; the spot over its middle (two air cells above the grass), the wheat one cell west of it on farmland and the sapling one cell east.
     COMPUTE WS-FY = WS-PY + 40
     COMPUTE WS-QX = WS-PX + 30
     COMPUTE WS-QZ = WS-PZ
     COMPUTE WS-BX = WS-PX + 20
     COMPUTE WS-BZ = WS-PZ - 10
     MOVE 20 TO WS-FLOOR-SIZE
     MOVE 2 TO WS-KIND
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-BX WS-BZ WS-FLOOR-SIZE WS-FY WS-KIND
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-CROP-X = WS-QX - 1
     COMPUTE WS-SAP-X = WS-QX + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CROP-X WS-FY WS-QZ WS-FARMLAND
*>   A 5 x 5 roof of planks 3 above the floor.
     MOVE "minecraft:oak_planks" TO WS-KEY
     MOVE 2 TO WS-HALF
     PERFORM SET-ROOF
     MOVE "small" TO WS-CASE
     PERFORM READERS-DARK-OR-LIT
*>   A roof 25 x 25: 13 steps from the open sky, dark by day.
     MOVE 12 TO WS-HALF
     PERFORM SET-ROOF
     PERFORM READERS-DARK-OR-LIT
*>   The slime: a swamp, a stone floor at y 66 above the terrain, feet at 67, the full moon by day (noon of day 0).
     PERFORM SLIME-SITE
     STOP RUN.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
*> Under the roof of half-width WS-HALF: WS-HALF 2 is lit (light 12), anything bigger is dark.
 READERS-DARK-OR-LIT.
     COMPUTE WS-Y = WS-FY + 1
     PERFORM RESET-PLANTS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 500
         CALL "GB-CROP-RT" USING WS-DIM WS-CROP-X WS-Y WS-QZ
     END-PERFORM
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CROP-X WS-Y WS-QZ WS-STATE
     COMPUTE WS-O = WS-STATE - WS-WHEAT
     IF WS-O > 0
         MOVE 1 TO WS-O
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         CALL "GB-SAPLING-RT" USING WS-DIM WS-SAP-X WS-Y WS-QZ
     END-PERFORM
     MOVE WS-O TO WS-J
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-SAP-X WS-Y WS-QZ WS-STATE
     COMPUTE WS-O = WS-STATE - WS-SAPLING
     IF WS-O > 0
         MOVE 1 TO WS-O
     END-IF
     IF WS-HALF = 2
         MOVE 1 TO WS-E
         MOVE "light readers: under the 5 x 5 roof (light 12) the sapling advances" TO WS-CASE
     ELSE
         MOVE 0 TO WS-E
         MOVE "light readers: under the 25 x 25 roof (dark) the sapling stays" TO WS-CASE
     END-IF
     PERFORM CHECK-N
     MOVE WS-J TO WS-O
     IF WS-HALF = 2
         MOVE "light readers: under the 5 x 5 roof (light 12) the wheat grows" TO WS-CASE
     ELSE
         MOVE "light readers: under the 25 x 25 roof (dark) the wheat does not grow" TO WS-CASE
     END-IF
     PERFORM CHECK-N
*>   an animal on the grass (mode 1) and a monster by day (mode 2): the draws are hashes of r
     MOVE 1 TO WS-MODE
     PERFORM COUNT-SPOT
     IF WS-HALF = 2
         MOVE 1 TO WS-E
         MOVE "light readers: under the 5 x 5 roof an animal's spot passes (brightness 12 above 8)" TO WS-CASE
     ELSE
         MOVE 0 TO WS-E
         MOVE "light readers: under the 25 x 25 roof an animal's spot fails (brightness 0)" TO WS-CASE
     END-IF
     MOVE WS-PASS TO WS-O
     IF WS-O > 1
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 2 TO WS-MODE
     PERFORM COUNT-SPOT
     IF WS-HALF = 2
         MOVE 0 TO WS-E
         MOVE "light readers: under the 5 x 5 roof no monster spot passes by day (sky 12)" TO WS-CASE
         MOVE WS-PASS TO WS-O
     ELSE
         MOVE 1 TO WS-E
         MOVE "light readers: under the 25 x 25 roof a monster spot passes by day (sky 0)" TO WS-CASE
         COMPUTE WS-O = FUNCTION MIN(WS-PASS, 1)
     END-IF
     PERFORM CHECK-N
*>   the zombie reinforcement dark check by day
     MOVE 0 TO WS-PASS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "STDMOB-REINF-DARK" USING XR-STATE WS-DIM WS-QX WS-Y WS-QZ WS-OK
         ADD WS-OK TO WS-PASS
     END-PERFORM
     IF WS-HALF = 2
         MOVE 0 TO WS-E
         MOVE "light readers: under the 5 x 5 roof no reinforcement spot passes by day (sky 12)" TO WS-CASE
         MOVE WS-PASS TO WS-O
     ELSE
         MOVE 1 TO WS-E
         MOVE "light readers: under the 25 x 25 roof a reinforcement spot passes by day (sky 0)" TO WS-CASE
         COMPUTE WS-O = FUNCTION MIN(WS-PASS, 1)
     END-IF
     PERFORM CHECK-N.
 RESET-PLANTS.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CROP-X WS-Y WS-QZ WS-WHEAT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-SAP-X WS-Y WS-QZ WS-SAPLING.
 COUNT-SPOT.
     MOVE 0 TO WS-PASS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         MOVE WS-I TO WS-R
         CALL "STDMOB-SPOT-OK" USING WS-DIM WS-QX WS-FY WS-QZ WS-MODE WS-R WS-OK
         ADD WS-OK TO WS-PASS
     END-PERFORM.
*> The block WS-KEY over the square of side 2 x WS-HALF + 1 round the spot (WS-QX, WS-QZ), 3 above the floor WS-FY, then the light again.
 SET-ROOF.
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     COMPUTE WS-BY = WS-FY + 3
     COMPUTE WS-X0 = WS-QX - WS-HALF
     COMPUTE WS-X1 = WS-QX + WS-HALF
     COMPUTE WS-Z0 = WS-QZ - WS-HALF
     COMPUTE WS-Z1 = WS-QZ + WS-HALF
     PERFORM VARYING WS-BX FROM WS-X0 BY 1 UNTIL WS-BX > WS-X1
         PERFORM VARYING WS-BZ FROM WS-Z0 BY 1 UNTIL WS-BZ > WS-Z1
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
         END-PERFORM
     END-PERFORM
     PERFORM RELIGHT.
 RELIGHT.
     COMPUTE WS-CX = FUNCTION INTEGER(WS-QX / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-QZ / 16)
     PERFORM VARYING WS-A FROM -2 BY 1 UNTIL WS-A > 2
         PERFORM VARYING WS-B FROM -2 BY 1 UNTIL WS-B > 2
             COMPUTE WS-BX = WS-CX + WS-A
             COMPUTE WS-BZ = WS-CZ + WS-B
             CALL "WORLD-FIND" USING WS-DIM WS-BX WS-BZ WS-CHUNK
             IF WS-CHUNK > 0
                 MOVE 0 TO CK-LIT(WS-CHUNK)
             END-IF
             CALL "STDMOB-READY" USING WS-DIM WS-BX WS-BZ WS-OK
         END-PERFORM
     END-PERFORM.
 SLIME-SITE.
     COMPUTE WS-QX = WS-PX + 60
     COMPUTE WS-QZ = WS-PZ + 20
     MOVE 66 TO WS-FY
     COMPUTE WS-BX = WS-QX - 10
     COMPUTE WS-BZ = WS-QZ - 10
     MOVE 1 TO WS-KIND
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-BX WS-BZ WS-FLOOR-SIZE WS-FY WS-KIND
     COMPUTE WS-CX = FUNCTION INTEGER(WS-QX / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-QZ / 16)
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-CHUNK
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-CHUNK)
     MOVE "minecraft:swamp" TO CBI-KEY(1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1024
         MOVE WS-SWAMP TO CE-BIOME(WS-I)
     END-PERFORM
     MOVE 6000 TO CW-TIME
     MOVE 2 TO BW-DIFFICULTY
     COMPUTE WS-Y = WS-FY + 1
     PERFORM RELIGHT
     PERFORM COUNT-SLIMES
     MOVE "light readers: in the open by day at the full moon the swamp slime never spawns (sky 15)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-SLIME-HITS TO WS-O
     PERFORM CHECK-N
     MOVE "minecraft:oak_planks" TO WS-KEY
     MOVE 2 TO WS-HALF
     PERFORM SET-ROOF
     PERFORM COUNT-SLIMES
     MOVE "light readers: under a 5 x 5 roof (light 12) by day the swamp slime never spawns" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-SLIME-HITS TO WS-O
     PERFORM CHECK-N
     MOVE 12 TO WS-HALF
     PERFORM SET-ROOF
     PERFORM COUNT-SLIMES
     MOVE "light readers: under a 25 x 25 roof (dark) by day the swamp slime spawns on some tries" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = FUNCTION MIN(WS-SLIME-HITS, 1)
     PERFORM CHECK-N.
 COUNT-SLIMES.
     MOVE 0 TO WS-SLIME-HITS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         MOVE 0 TO WS-REASON
         CALL "STDMOB-SLIME-RULE" USING XR-STATE WS-DIM WS-QX WS-Y WS-QZ WS-REASON WS-OK
         ADD WS-OK TO WS-SLIME-HITS
     END-PERFORM.
 END PROGRAM TEST-LIGHT-READERS.
 COPY CORETEST.
 COPY MOBSPTEST.
