*> Acceptance test (lane bugwater; docs/protocol/18 section 4.2 WaterAvoidingRandomStrollGoal, LandRandomPos in section 4.3, the path types of section 5.1:
*> water has a negative malus for a land mob): land mobs stay out of water. On a grass arena with a one-deep pond next to a three-deep end, cows,
*> sheep, pigs and chickens strolling on the bank, panicking toward the pond, and zombies chasing a player across it, spend no tick with their box in
*> water; and a mob that is in the water gets out of it. The wet ticks are counted with FLUID-TOUCHES-WATER, the test the mob physics itself uses.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STDMOB-WATER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-PLAYER             BINARY-LONG.
 01 WS-DIM                BINARY-LONG.
 01 WS-KEY                PIC X(112).
 01 WS-TYPE               BINARY-LONG.
 01 WS-ENTITY-ROW         PIC X(66).
 01 WS-STATUS             BINARY-LONG.
 01 WS-BX                 BINARY-LONG.
 01 WS-BY                 BINARY-LONG.
 01 WS-BZ                 BINARY-LONG.
 01 WS-FX                 BINARY-LONG.
 01 WS-FZ                 BINARY-LONG.
 01 WS-FY                 BINARY-LONG.
 01 WS-SIZE               BINARY-LONG VALUE 41.
 01 WS-KIND               BINARY-LONG VALUE 2.
 01 WS-X                  FLOAT-LONG.
 01 WS-Y                  FLOAT-LONG.
 01 WS-Z                  FLOAT-LONG.
 01 WS-YAW                FLOAT-SHORT VALUE 0.
 01 WS-T                  BINARY-LONG.
 01 WS-I                  BINARY-LONG.
 01 WS-S                  BINARY-LONG.
 01 WS-CELL-X             BINARY-LONG.
 01 WS-CELL-Z             BINARY-LONG.
 01 WS-CELL-Y             BINARY-LONG.
 01 WS-ZLO                BINARY-LONG.
 01 WS-R                  BINARY-LONG.
 01 WS-M                  BINARY-LONG.
 01 WS-OK                 BINARY-LONG.
 01 WS-HX                 FLOAT-LONG.
 01 WS-HZ                 FLOAT-LONG.
 01 WS-WATER              BINARY-LONG.
 01 WS-STONE              BINARY-LONG.
 01 WS-WET                BINARY-LONG.
 01 WS-WET-TICKS          BINARY-LONG.
 01 WS-LEFT               BINARY-LONG.
 01 WS-ROWS.
    05 WS-ROW             BINARY-LONG OCCURS 16 TIMES.
 01 WS-SPECIES.
    05 FILLER             PIC X(112) VALUE "minecraft:cow".
    05 FILLER             PIC X(112) VALUE "minecraft:sheep".
    05 FILLER             PIC X(112) VALUE "minecraft:pig".
    05 FILLER             PIC X(112) VALUE "minecraft:chicken".
 01 WS-SPECIES-TABLE REDEFINES WS-SPECIES.
    05 WS-SPECIES-KEY     PIC X(112) OCCURS 4 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-BX - 20
     COMPUTE WS-FZ = WS-BZ - 20
     COMPUTE WS-FY = WS-BY - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
*>   The pond: x from BX to BX + 14, z from BZ - 8 to BZ + 8, one deep (water at the floor's top layer, stone under it); from BX + 8 on it is three deep.
     COMPUTE WS-ZLO = WS-BZ - 8
     PERFORM VARYING WS-CELL-X FROM WS-BX BY 1 UNTIL WS-CELL-X > WS-BX + 14
         PERFORM VARYING WS-CELL-Z FROM WS-ZLO BY 1 UNTIL WS-CELL-Z > WS-BZ + 8
             COMPUTE WS-CELL-Y = WS-FY - 3
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CELL-X WS-CELL-Y WS-CELL-Z WS-STONE
             COMPUTE WS-CELL-Y = WS-FY - 2
             IF WS-CELL-X >= WS-BX + 8
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CELL-X WS-CELL-Y WS-CELL-Z WS-WATER
             ELSE
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CELL-X WS-CELL-Y WS-CELL-Z WS-STONE
             END-IF
             COMPUTE WS-CELL-Y = WS-FY - 1
             IF WS-CELL-X >= WS-BX + 8
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CELL-X WS-CELL-Y WS-CELL-Z WS-WATER
             ELSE
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CELL-X WS-CELL-Y WS-CELL-Z WS-STONE
             END-IF
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CELL-X WS-FY WS-CELL-Z WS-WATER
         END-PERFORM
     END-PERFORM
     MOVE "N" TO TL-MODE

*>   1. Strolling on the west bank: three of each of four species, 1200 ticks.
     MOVE 6000 TO CW-TIME
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         COMPUTE WS-S = FUNCTION MOD(WS-I - 1, 4) + 1
         MOVE WS-SPECIES-KEY(WS-S) TO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         COMPUTE WS-X = WS-BX - 0.5 - FUNCTION MOD(WS-I, 3)
         COMPUTE WS-Z = WS-BZ - 5 + WS-I
         COMPUTE WS-Y = WS-BY
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW(WS-I)
     END-PERFORM
     MOVE 0 TO WS-WET-TICKS
     PERFORM VARYING WS-T FROM 10 BY 1 UNTIL WS-T > 1209
         COMPUTE CW-TICKS = WS-T
         COMPUTE CW-TIME = 6000 + WS-T
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
             MOVE 0 TO EN-LOVE(WS-ROW(WS-I)) EN-HURT(WS-ROW(WS-I))
             CALL "STDMOB-STEP" USING WS-ROW(WS-I)
             PERFORM COUNT-WET
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US15 18§4.2 land animals strolling beside a pond spend no tick in the water" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-WET-TICKS TO WS-O
     PERFORM CHECK-N

*>   2. Panic: the attacker (the player) stands behind each animal so that it flees toward the pond.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         CALL "ENTITY-REMOVE" USING WS-ROW(WS-I)
     END-PERFORM
     MOVE 0 TO WS-WET-TICKS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         COMPUTE WS-S = FUNCTION MOD(WS-I - 1, 4) + 1
         MOVE WS-SPECIES-KEY(WS-S) TO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         COMPUTE WS-X = WS-BX - 1.5
         COMPUTE WS-Z = WS-BZ - 6 + WS-I * 1.5
         COMPUTE WS-Y = WS-BY
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW(WS-I)
     END-PERFORM
     COMPUTE PL-X(WS-PLAYER) = WS-BX - 12.5
     COMPUTE PL-Y(WS-PLAYER) = WS-BY
     PERFORM VARYING WS-T FROM 1300 BY 1 UNTIL WS-T > 1459
         COMPUTE CW-TICKS = WS-T
         COMPUTE CW-TIME = 6000 + WS-T
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
             MOVE 20 TO EN-FLEE(WS-ROW(WS-I))
             MOVE WS-PLAYER TO EN-FLEE-PLAYER(WS-ROW(WS-I))
             MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-FLEE-ID(WS-ROW(WS-I))
             MOVE 0 TO EN-LOVE(WS-ROW(WS-I)) EN-HURT(WS-ROW(WS-I))
             CALL "STDMOB-STEP" USING WS-ROW(WS-I)
             PERFORM COUNT-WET
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US15 18§4.2 land animals panicking toward a pond stop at its bank" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-WET-TICKS TO WS-O
     PERFORM CHECK-N

*>   3. Chasing zombies: the player stands on the far side of the pond at night, so the straight line crosses it.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         CALL "ENTITY-REMOVE" USING WS-ROW(WS-I)
     END-PERFORM
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         COMPUTE WS-X = WS-BX - 2.5
         COMPUTE WS-Z = WS-BZ - 2 + WS-I * 2
         COMPUTE WS-Y = WS-BY
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW(WS-I)
     END-PERFORM
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 19.5
     COMPUTE PL-Y(WS-PLAYER) = WS-BY
     COMPUTE PL-Z(WS-PLAYER) = WS-BZ + 0.5
     MOVE 0 TO WS-WET-TICKS
     PERFORM VARYING WS-T FROM 1500 BY 1 UNTIL WS-T > 1799
         COMPUTE CW-TICKS = WS-T
         MOVE 18000 TO CW-TIME
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
             CALL "STDMOB-STEP" USING WS-ROW(WS-I)
             PERFORM COUNT-WET
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US15 18§5.1 zombies chasing a player across a pond never walk into the water" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-WET-TICKS TO WS-O
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         CALL "ENTITY-REMOVE" USING WS-ROW(WS-I)
     END-PERFORM

*>   4. A cow in the shallow water and one in the deep end both get out within 600 ticks (the float goal and the stroll's land position).
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-BX + 3.5
     COMPUTE WS-Z = WS-BZ + 0.5
     COMPUTE WS-Y = WS-FY
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW(1)
     COMPUTE WS-X = WS-BX + 11.5
     COMPUTE WS-Y = WS-FY - 2
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW(2)
     PERFORM VARYING WS-T FROM 1900 BY 1 UNTIL WS-T > 2499
         COMPUTE CW-TICKS = WS-T
         COMPUTE CW-TIME = 6000 + WS-T
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
             MOVE 0 TO EN-LOVE(WS-ROW(WS-I)) EN-HURT(WS-ROW(WS-I))
             CALL "STDMOB-STEP" USING WS-ROW(WS-I)
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-LEFT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         MOVE WS-ROW(WS-I) TO WS-R
         MOVE EN-X(WS-R) TO WS-X
         MOVE EN-Y(WS-R) TO WS-Y
         MOVE EN-Z(WS-R) TO WS-Z
         CALL "FLUID-TOUCHES-WATER" USING WS-DIM WS-X WS-Y WS-Z WS-WET
         IF WS-WET = 0
             ADD 1 TO WS-LEFT
         END-IF
     END-PERFORM
     MOVE "acceptance US15 18§3.2 a cow put into a shallow pond and one in the deep end are both out of the water after 600 ticks" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-LEFT TO WS-O
     PERFORM CHECK-N

*>   5. STDMOB-LAND-DEST (LandRandomPos): a position in water or over water is refused, a position in a wall moves up out of it, one over a deep drop is kept.
     COMPUTE WS-CELL-X = WS-BX + 3
     COMPUTE WS-CELL-Z = WS-BZ
     COMPUTE WS-CELL-Y = WS-BY
     CALL "STDMOB-LAND-DEST" USING WS-DIM WS-CELL-X WS-CELL-Y WS-CELL-Z WS-OK
     MOVE "acceptance US15 18§4.3 LandRandomPos refuses a position above the water of a pond (feet over a water cell)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-N
     COMPUTE WS-CELL-Y = WS-FY
     CALL "STDMOB-LAND-DEST" USING WS-DIM WS-CELL-X WS-CELL-Y WS-CELL-Z WS-OK
     MOVE "acceptance US15 18§4.3 LandRandomPos refuses a position in a water cell" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-N
     COMPUTE WS-CELL-X = WS-BX - 6
     COMPUTE WS-CELL-Y = WS-BY
     CALL "STDMOB-LAND-DEST" USING WS-DIM WS-CELL-X WS-CELL-Y WS-CELL-Z WS-OK
     MOVE "acceptance US15 18§4.3 LandRandomPos accepts a position on the grass of the bank" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-N
     COMPUTE WS-CELL-Y = WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CELL-X WS-CELL-Y WS-CELL-Z WS-STONE
     COMPUTE WS-CELL-Y = WS-BY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CELL-X WS-CELL-Y WS-CELL-Z WS-STONE
     COMPUTE WS-CELL-Y = WS-BY
     CALL "STDMOB-LAND-DEST" USING WS-DIM WS-CELL-X WS-CELL-Y WS-CELL-Z WS-OK
     MOVE "acceptance US15 18§4.3 LandRandomPos moves a position inside a two-high wall up out of the solid" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-N
     COMPUTE WS-CELL-Y = WS-BY + 20
     CALL "STDMOB-LAND-DEST" USING WS-DIM WS-CELL-X WS-CELL-Y WS-CELL-Z WS-OK
     MOVE "acceptance US15 18§4.3 LandRandomPos keeps a position over a drop deeper than 4 cells" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-N

*>   6. STDMOB-WATER-GUARD: the step of a cow on the bank toward the pond is cancelled on that axis, along the shore it is kept, and the swimmers and tame mobs keep theirs.
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-BX - 0.6
     COMPUTE WS-Y = WS-BY
     COMPUTE WS-Z = WS-BZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW(1)
     MOVE WS-ROW(1) TO WS-R
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-R) WS-M
     MOVE 1 TO EN-ON-GROUND(WS-R)
     MOVE 0.2 TO WS-HX
     MOVE 0 TO WS-HZ
     CALL "STDMOB-WATER-GUARD" USING WS-R WS-M WS-HX WS-HZ
     MOVE "acceptance US15 18§5.1 a cow at the west bank cannot step east into the pond (the step is cancelled)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-HX TO WS-O
     PERFORM CHECK-N
     MOVE 0.05 TO WS-HX
     CALL "STDMOB-WATER-GUARD" USING WS-R WS-M WS-HX WS-HZ
     MOVE "acceptance US15 18§5.1 a step that stays in the cell of the cow is kept" TO WS-CASE
     MOVE 5 TO WS-E
     COMPUTE WS-O ROUNDED = WS-HX * 100
     PERFORM CHECK-N
     MOVE -0.2 TO WS-HX
     MOVE 0.2 TO WS-HZ
     CALL "STDMOB-WATER-GUARD" USING WS-R WS-M WS-HX WS-HZ
     MOVE "acceptance US15 18§5.1 a cow walking west and south along the shore keeps both steps" TO WS-CASE
     MOVE 4 TO WS-E
     COMPUTE WS-O ROUNDED = (WS-HX * -10) + (WS-HZ * 10)
     PERFORM CHECK-N
     MOVE 1 TO EN-TAMED(WS-R)
     MOVE 0.2 TO WS-HX
     MOVE 0 TO WS-HZ
     CALL "STDMOB-WATER-GUARD" USING WS-R WS-M WS-HX WS-HZ
     MOVE "acceptance US15 18§5.1 a tame mob walks into the water (follow owner makes water free)" TO WS-CASE
     MOVE 2 TO WS-E
     COMPUTE WS-O ROUNDED = WS-HX * 10
     PERFORM CHECK-N
     MOVE 0 TO EN-TAMED(WS-R)
     MOVE 0 TO EN-ON-GROUND(WS-R)
     CALL "STDMOB-WATER-GUARD" USING WS-R WS-M WS-HX WS-HZ
     MOVE "acceptance US15 18§5.1 a mob in the air (falling) is not guarded" TO WS-CASE
     MOVE 2 TO WS-E
     COMPUTE WS-O ROUNDED = WS-HX * 10
     PERFORM CHECK-N
     MOVE 1 TO EN-ON-GROUND(WS-R)
     MOVE 0 TO WS-HX
     MOVE -0.3 TO WS-HZ
     COMPUTE EN-X(WS-R) = WS-BX + 3.5
     COMPUTE EN-Z(WS-R) = WS-BZ + 9.4
     CALL "STDMOB-WATER-GUARD" USING WS-R WS-M WS-HX WS-HZ
     MOVE "acceptance US15 18§5.1 a cow on the north bank cannot step into the pond (negative z step cancelled)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-HZ TO WS-O
     PERFORM CHECK-N
     MOVE 0.3 TO WS-HZ
     COMPUTE EN-Z(WS-R) = WS-BZ - 8.7
     CALL "STDMOB-WATER-GUARD" USING WS-R WS-M WS-HX WS-HZ
     MOVE "acceptance US15 18§5.1 a cow on the south bank cannot step into the pond (positive z step cancelled)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-HZ TO WS-O
     PERFORM CHECK-N
     MOVE -0.3 TO WS-HX
     MOVE 0 TO WS-HZ
     COMPUTE EN-X(WS-R) = WS-BX + 15.6
     COMPUTE EN-Z(WS-R) = WS-BZ + 0.5
     CALL "STDMOB-WATER-GUARD" USING WS-R WS-M WS-HX WS-HZ
     MOVE "acceptance US15 18§5.1 a cow on the east bank cannot step west into the pond (negative x step cancelled)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-HX TO WS-O
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-R
     MOVE "minecraft:slime" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-BX - 0.6
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW(1)
     MOVE WS-ROW(1) TO WS-R
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-R) WS-M
     MOVE 1 TO EN-ON-GROUND(WS-R)
     MOVE 0.2 TO WS-HX
     MOVE 0 TO WS-HZ
     CALL "STDMOB-WATER-GUARD" USING WS-R WS-M WS-HX WS-HZ
     MOVE "acceptance US15 18§5.1 a slime (a swimmer) is not guarded" TO WS-CASE
     MOVE 2 TO WS-E
     COMPUTE WS-O ROUNDED = WS-HX * 10
     PERFORM CHECK-N
     STOP RUN.

 COUNT-WET.
     MOVE WS-ROW(WS-I) TO WS-R
     MOVE EN-X(WS-R) TO WS-X
     MOVE EN-Y(WS-R) TO WS-Y
     MOVE EN-Z(WS-R) TO WS-Z
     CALL "FLUID-TOUCHES-WATER" USING WS-DIM WS-X WS-Y WS-Z WS-WET
     IF WS-WET = 1
         ADD 1 TO WS-WET-TICKS
     END-IF.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-STDMOB-WATER.
 COPY CORETEST.
 COPY MOBSPTEST.
