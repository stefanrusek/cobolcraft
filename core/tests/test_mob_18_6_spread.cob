*> Implementation test (002-lane-bugvillage; docs/protocol/32-light-engine.md section 5.2, 18 section 6.8): the sky light a monster's spawn rule reads spreads sideways
*> from open sky (each step through a cell that is not opaque takes one level), so by day no hostile mob spawns under the eaves of a house, a porch or the edge of a
*> canopy, where the stored light (0 at and below the column's topmost block, no sideways spreading) reads dark. Deep under a wide roof, or in a closed room, the cell is
*> still dark enough by day.
*>   - a 5 x 5 roof 3 above the floor: its centre cell is 3 steps from the open sky (sky light 12): the zombie rule never passes by day;
*>   - a 25 x 25 roof (13 steps from the open sky: sky light 2): the rule passes by day;
*>   - a closed room (stone walls round the cell under a 7 x 7 roof): the rule passes by day;
*>   - the same closed room with a pane of glass in one wall 3 steps from the cell (sky light 11 through the glass, 4 steps): the rule never passes by day;
*>   - LIGHT-SKY-SPREAD itself: 12 under the 5 x 5 roof, 15 in the open, the stored value (0) beyond the depth asked, and no change when the depth is 0.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-6-SPREAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY XORO.
 COPY STDMOBS.
 COPY BRWORLD.
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
 01 WS-K                  BINARY-LONG.
 01 WS-PASS               BINARY-LONG.
 01 WS-OK                 BINARY-LONG.
 01 WS-REASON             BINARY-LONG VALUE 0.
 01 WS-FLOOR-SIZE         BINARY-LONG.
 01 WS-KIND               BINARY-LONG.
 01 WS-STATE              BINARY-LONG.
 01 WS-KEY                PIC X(112).
 01 WS-NAME               PIC X(24).
 01 WS-TYPE               BINARY-LONG.
 01 WS-BX                 BINARY-LONG.
 01 WS-BZ                 BINARY-LONG.
 01 WS-BY                 BINARY-LONG.
 01 WS-ZROW               BINARY-LONG.
 01 WS-A                  BINARY-LONG.
 01 WS-B                  BINARY-LONG.
 01 WS-HALF               BINARY-LONG.
 01 WS-X0                 BINARY-LONG.
 01 WS-X1                 BINARY-LONG.
 01 WS-Z0                 BINARY-LONG.
 01 WS-Z1                 BINARY-LONG.
 01 WS-SKY                BINARY-LONG.
 01 WS-BLOCK              BINARY-LONG.
 01 WS-RAW                BINARY-LONG.
 01 WS-DEPTH              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-PY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FY = WS-PY + 40
     MOVE "zombie" TO WS-NAME
     CALL "TEST-TYPE" USING WS-NAME WS-TYPE WS-ZROW
*>   A stone floor 20 x 20 east of the player and 40 above it, the spot over its middle.
     COMPUTE WS-QX = WS-PX + 20
     COMPUTE WS-QZ = WS-PZ - 10
     MOVE 20 TO WS-FLOOR-SIZE
     MOVE 1 TO WS-KIND
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-QX WS-QZ WS-FLOOR-SIZE WS-FY WS-KIND
     COMPUTE WS-QX = WS-PX + 30
     COMPUTE WS-QZ = WS-PZ
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-CX = FUNCTION INTEGER(WS-QX / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-QZ / 16)
     MOVE 6000 TO CW-TIME
*>   Open sky: the spread changes nothing, the cell is lit by the sky at once.
     MOVE 7 TO WS-DEPTH
     PERFORM SPREAD-AT
     MOVE "bugvillage spread: the open cell reads sky light 15" TO WS-CASE
     MOVE 15 TO WS-E
     MOVE WS-SKY TO WS-O
     PERFORM CHECK-N
*>   A 5 x 5 roof of planks 3 above the floor.
     MOVE "minecraft:oak_planks" TO WS-KEY
     MOVE 2 TO WS-HALF
     PERFORM SET-ROOF
     PERFORM SPREAD-AT
     MOVE "bugvillage spread: under a 5 x 5 roof the centre cell is 3 steps from the open sky, light 12" TO WS-CASE
     MOVE 12 TO WS-E
     MOVE WS-SKY TO WS-O
     PERFORM CHECK-N
     MOVE 2 TO WS-DEPTH
     PERFORM SPREAD-AT
     MOVE "bugvillage spread: a depth of 2 does not reach it, the stored light 0 is kept" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-SKY TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-DEPTH
     PERFORM SPREAD-AT
     MOVE "bugvillage spread: a depth of 0 reads the stored light" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-SKY TO WS-O
     PERFORM CHECK-N
     MOVE 99 TO WS-DEPTH
     PERFORM SPREAD-AT
     MOVE "bugvillage spread: a depth above 7 is cut at 7 (the search grid is 15 cells wide)" TO WS-CASE
     MOVE 12 TO WS-E
     MOVE WS-SKY TO WS-O
     PERFORM CHECK-N
     MOVE 7 TO WS-DEPTH
     PERFORM COUNT-PASSES
     MOVE "bugvillage 18§6.8 by day no zombie spawns under the eaves (3 steps from the open sky)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PASS TO WS-O
     PERFORM CHECK-N
*>   A roof 25 x 25: 13 steps from the open sky, as dark as a cave by day.
     MOVE 12 TO WS-HALF
     PERFORM SET-ROOF
     PERFORM COUNT-PASSES
     MOVE "bugvillage 18§6.8 by day a zombie rule passes deep under a 25 x 25 roof (sky light 2)" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = FUNCTION MIN(WS-PASS, 1)
     PERFORM CHECK-N
     MOVE "minecraft:air" TO WS-KEY
     MOVE 12 TO WS-HALF
     PERFORM SET-ROOF
*>   A closed room: a 7 x 7 roof and stone walls under its edge, the cell in the middle.
     MOVE "minecraft:oak_planks" TO WS-KEY
     MOVE 3 TO WS-HALF
     PERFORM SET-ROOF
     MOVE "minecraft:stone" TO WS-KEY
     PERFORM SET-WALLS
     PERFORM COUNT-PASSES
     MOVE "bugvillage 18§6.8 by day a zombie rule passes in a closed room (the walls stop the spread)" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = FUNCTION MIN(WS-PASS, 1)
     PERFORM CHECK-N
*>   A pane of glass in the middle of the west wall (3 steps from the cell): the light comes in.
     MOVE "minecraft:glass" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     COMPUTE WS-BY = WS-FY + 1
     COMPUTE WS-BX = WS-QX - 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-QZ WS-STATE
     PERFORM COUNT-PASSES
     MOVE "bugvillage 18§6.8 by day no zombie spawns in a room that has a window (light through the glass)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PASS TO WS-O
     PERFORM CHECK-N
     STOP RUN.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
*> The block WS-KEY over the square of side 2 x WS-HALF + 1 round the spot, 3 above the floor, then the light again.
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
*> The block WS-KEY in the ring of cells at distance 3 from the spot, the two layers between the floor and the roof.
 SET-WALLS.
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 2
         COMPUTE WS-BY = WS-FY + WS-K
         PERFORM VARYING WS-I FROM -3 BY 1 UNTIL WS-I > 3
             COMPUTE WS-BX = WS-QX + WS-I
             COMPUTE WS-BZ = WS-QZ - 3
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
             COMPUTE WS-BZ = WS-QZ + 3
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
             COMPUTE WS-BX = WS-QX - 3
             COMPUTE WS-BZ = WS-QZ + WS-I
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
             COMPUTE WS-BX = WS-QX + 3
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
         END-PERFORM
     END-PERFORM
     PERFORM RELIGHT.
 RELIGHT.
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
 SPREAD-AT.
     CALL "LIGHT-SKY-SPREAD" USING WS-DIM WS-QX WS-Y WS-QZ WS-DEPTH WS-SKY.
 COUNT-PASSES.
     MOVE 0 TO WS-PASS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-RULE-AT" USING XR-STATE WS-DIM WS-ZROW WS-QX WS-Y WS-QZ WS-REASON WS-OK
         ADD WS-OK TO WS-PASS
     END-PERFORM.
 END PROGRAM TEST-MOB-18-6-SPREAD.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY MOBNETHERTEST.
