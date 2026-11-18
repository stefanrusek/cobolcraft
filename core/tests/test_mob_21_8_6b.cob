*> The fires a lightning bolt starts (docs/protocol/21 section 8.6 spawnFire; 29b-8 sections 2.2, 2.3, 2.8; 33 section 8; lane p49t, T39000): the strike (life 2) of a bolt that is not visual-only
*> tries the bolt's own cell and then four cells of the 3 x 3 x 3 block around it on Normal and Hard; each later flash tries the own cell at every difficulty. A cell takes fire when it is air and the
*> fire can survive there (a solid block below, or a neighbour that can burn); soul fire above soul sand or soul soil; a fire with no floor has the flag of every flammable side. The rule
*> fire_spread_radius_around_player (-1 everywhere, else a player strictly closer than the radius) gates all of it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-8-6B.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY PROJSTATE.
 COPY BRWORLD.
 01 WS-CASE                PIC X(160).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-TEXT            PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 40.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VISUAL              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-MODE-SET            BINARY-LONG VALUE 2.
 01 WS-NAME                PIC X(24).
 01 WS-VALUE               PIC X(32).
 01 WS-RESULT              BINARY-LONG.
 01 WS-BARE                PIC X(48).
 01 WS-LONG                PIC X(48).
 01 WS-N                   BINARY-LONG.
 01 WS-INSIDE              BINARY-LONG.
 01 WS-OUTSIDE             BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-RULE-NAME           PIC X(40) VALUE "fire_spread_radius_around_player".
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-CAN                 BINARY-LONG.
 01 WS-BAR                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 10
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 20
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     COMPUTE WS-BX = WS-FX + 10
     COMPUTE WS-BY = WS-FY + 1
     COMPUTE WS-BZ = WS-FZ + 10
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
*>   Normal difficulty, a stone floor: the own cell takes fire.
     MOVE 2 TO BW-DIFFICULTY
     MOVE 0 TO WS-VISUAL
     PERFORM STRIKE
     MOVE WS-BX TO WS-CX
     MOVE WS-BY TO WS-CY
     MOVE WS-BZ TO WS-CZ
     PERFORM READ-KEY
     MOVE "acceptance US15 minecraft:lightning_bolt 21§8.6 a strike on Normal sets the bolt's own cell on fire" TO WS-CASE
     MOVE "fire" TO WS-VALUE
     PERFORM CHECK-TEXT
*>   Thirty strikes: every one places 1 to 9 fires (own cell and cells of the cube that can hold one), none outside the cube, and some place more than one.
     MOVE 99 TO WS-MIN
     MOVE 0 TO WS-MAX WS-OUTSIDE
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 30
         PERFORM CLEAR-AIR
         PERFORM STRIKE
         PERFORM COUNT-FIRES
         IF WS-INSIDE < WS-MIN
             MOVE WS-INSIDE TO WS-MIN
         END-IF
         IF WS-INSIDE > WS-MAX
             MOVE WS-INSIDE TO WS-MAX
         END-IF
     END-PERFORM
     MOVE "acceptance US15 minecraft:lightning_bolt 21§8.6 every strike places at least the fire of the own cell" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-MIN TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:lightning_bolt 21§8.6 some strikes place fires on the random cells too (more than 1)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-MAX > 1
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:lightning_bolt 21§8.6 no strike places more than the 9 cells of the layer (the cell above has no support)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-MAX <= 9
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 minecraft:lightning_bolt 21§8.6 no fire lands outside the 3 x 3 x 3 block" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-OUTSIDE TO WS-O
     PERFORM CHECK-N
*>   Easy: the strike places nothing; Hard does.
     PERFORM CLEAR-AIR
     MOVE 1 TO BW-DIFFICULTY
     PERFORM STRIKE
     PERFORM COUNT-FIRES
     MOVE "acceptance US15 minecraft:lightning_bolt 33§4.4 a strike on Easy places no fire" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-INSIDE TO WS-O
     PERFORM CHECK-N
     MOVE 3 TO BW-DIFFICULTY
     PERFORM STRIKE
     PERFORM COUNT-FIRES
     MOVE "acceptance US15 minecraft:lightning_bolt 33§4.4 a strike on Hard places fire" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-INSIDE >= 1
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   A visual-only bolt places none.
     PERFORM CLEAR-AIR
     MOVE 1 TO WS-VISUAL
     PERFORM STRIKE
     PERFORM COUNT-FIRES
     MOVE "acceptance US15 minecraft:lightning_bolt 21§8.6 a visual-only bolt starts no fire" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-INSIDE TO WS-O
     PERFORM CHECK-N
*>   The extra flashes try the own cell at every difficulty (Easy): the bolt runs to its end.
     MOVE 0 TO WS-VISUAL
     MOVE 1 TO BW-DIFFICULTY
     PERFORM CLEAR-AIR
     PERFORM FLY-WHOLE
     PERFORM COUNT-FIRES
     MOVE "acceptance US15 minecraft:lightning_bolt 21§8.6 on Easy a flash (spawnFire(0)) still sets the own cell on fire" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-INSIDE TO WS-O
     PERFORM CHECK-N
     MOVE 2 TO BW-DIFFICULTY
*>   The rule: -1 everywhere; a radius smaller than the distance of the only player: no fire (a flash too); the default 128: fire.
     PERFORM CLEAR-AIR
     MOVE 3 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     PERFORM STRIKE
     PERFORM COUNT-FIRES
     MOVE "acceptance US15 minecraft:lightning_bolt 33§8 a player farther than the rule radius: no fire" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-INSIDE TO WS-O
     PERFORM CHECK-N
     PERFORM FLY-WHOLE
     PERFORM COUNT-FIRES
     MOVE "acceptance US15 minecraft:lightning_bolt 33§8 the same for the flashes" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-INSIDE TO WS-O
     PERFORM CHECK-N
     MOVE 128 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     PERFORM STRIKE
     PERFORM COUNT-FIRES
     MOVE "acceptance US15 minecraft:lightning_bolt 33§8 a player closer than the rule radius 128: fire" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-INSIDE >= 1
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     PERFORM CLEAR-AIR
     MOVE -1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     MOVE 3 TO PL-MODE(WS-PLAYER)
     PERFORM STRIKE
     PERFORM COUNT-FIRES
     MOVE "acceptance US15 minecraft:lightning_bolt 33§8 the rule -1 lets it burn with no player near (a spectator at hand)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-INSIDE >= 1
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   A spectator never counts (rule 3000 and the only player a spectator).
     PERFORM CLEAR-AIR
     MOVE 3000 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     PERFORM STRIKE
     PERFORM COUNT-FIRES
     MOVE "acceptance US15 minecraft:lightning_bolt 33§8 a spectator does not count for the rule radius" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-INSIDE TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 128 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
*>   Soul sand below the own cell: soul fire.
     PERFORM CLEAR-AIR
     MOVE "soul_sand" TO WS-KEY
     COMPUTE WS-CY = WS-BY - 1
     MOVE WS-BX TO WS-CX
     MOVE WS-BZ TO WS-CZ
     PERFORM PLACE-AT
     PERFORM STRIKE
     COMPUTE WS-CY = WS-BY
     PERFORM READ-KEY
     MOVE "acceptance US15 minecraft:lightning_bolt 29b§2.2 the own cell above soul sand takes soul fire" TO WS-CASE
     MOVE "soul_fire" TO WS-VALUE
     PERFORM CHECK-TEXT
     MOVE "stone" TO WS-KEY
     COMPUTE WS-CY = WS-BY - 1
     PERFORM PLACE-AT
*>   No floor: the cell hangs on a flammable block at its east side; its east flag is set and the others are not.
     PERFORM CLEAR-AIR
     MOVE "air" TO WS-KEY
     COMPUTE WS-CY = WS-BY - 1
     PERFORM PLACE-AT
     MOVE "oak_planks" TO WS-KEY
     COMPUTE WS-CX = WS-BX + 1
     COMPUTE WS-CY = WS-BY
     PERFORM PLACE-AT
     PERFORM STRIKE
     MOVE WS-BX TO WS-CX
     PERFORM READ-KEY
     MOVE "acceptance US15 minecraft:lightning_bolt 29b§2.2 with no floor the fire holds on a flammable neighbour" TO WS-CASE
     MOVE "fire" TO WS-VALUE
     PERFORM CHECK-TEXT
     MOVE "east" TO WS-NAME
     PERFORM READ-PROP
     MOVE "acceptance US15 minecraft:lightning_bolt 29b§2.2 the fire's east flag is set (flammable block there)" TO WS-CASE
     MOVE "true" TO WS-VALUE
     PERFORM CHECK-TEXT
     MOVE "north" TO WS-NAME
     PERFORM READ-PROP
     MOVE "acceptance US15 minecraft:lightning_bolt 29b§2.2 the fire's north flag is not set (air there)" TO WS-CASE
     MOVE "false" TO WS-VALUE
     PERFORM CHECK-TEXT
*>   No floor and nothing to burn: no fire survives (the cell stays air).
     MOVE "air" TO WS-KEY
     COMPUTE WS-CX = WS-BX + 1
     PERFORM PLACE-AT
     PERFORM CLEAR-AIR
     PERFORM STRIKE
     MOVE WS-BX TO WS-CX
     PERFORM READ-KEY
     MOVE "acceptance US15 minecraft:lightning_bolt 29b§2.3 a fire with no floor and no flammable neighbour cannot survive: no fire" TO WS-CASE
     MOVE "air" TO WS-VALUE
     PERFORM CHECK-TEXT
     MOVE "stone" TO WS-KEY
     COMPUTE WS-CY = WS-BY - 1
     PERFORM PLACE-AT
*>   A cell that is not air takes no fire.
     MOVE "stone" TO WS-KEY
     COMPUTE WS-CY = WS-BY
     PERFORM PLACE-AT
     PERFORM STRIKE
     PERFORM READ-KEY
     MOVE "acceptance US15 minecraft:lightning_bolt 21§8.6 the own cell is not air: it stays stone" TO WS-CASE
     MOVE "stone" TO WS-VALUE
     PERFORM CHECK-TEXT
     MOVE "air" TO WS-KEY
     PERFORM PLACE-AT
*>   canBurn of a cell: a waterlogged flammable block does not burn (29b§2.1), plain planks do, stone does not.
     MOVE "oak_planks" TO WS-KEY
     PERFORM PLACE-AT
     CALL "FIRE-CAN-BURN" USING WS-DIM WS-CX WS-CY WS-CZ WS-CAN
     MOVE "acceptance US15 minecraft:fire 29b§2.1 planks can burn" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-CAN TO WS-O
     PERFORM CHECK-N
     MOVE "oak_slab" TO WS-KEY
     PERFORM PLACE-AT
     MOVE "waterlogged" TO WS-NAME
     MOVE "true" TO WS-VALUE
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     CALL "BLOCK-STATE-PROP" USING WS-MODE-SET WS-STATE WS-NAME WS-VALUE WS-RESULT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-RESULT
     CALL "FIRE-CAN-BURN" USING WS-DIM WS-CX WS-CY WS-CZ WS-CAN
     MOVE "acceptance US15 minecraft:fire 29b§2.1 a waterlogged slab cannot burn" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-CAN TO WS-O
     PERFORM CHECK-N
     MOVE "stone" TO WS-KEY
     PERFORM PLACE-AT
     CALL "FIRE-CAN-BURN" USING WS-DIM WS-CX WS-CY WS-CZ WS-CAN
     MOVE "acceptance US15 minecraft:fire 29b§2.1 stone cannot burn" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-CAN TO WS-O
     PERFORM CHECK-N
     STOP RUN.

*> A bolt standing at the own cell of the strike (WS-BX, WS-BY, WS-BZ), the first tick run, the bolt removed.
 STRIKE.
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY
     COMPUTE WS-Z = WS-BZ + 0.5
     CALL "LIGHTNING-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-VISUAL WS-ROW
     CALL "THROWN-TICK"
     CALL "PJ-DROP" USING WS-ROW.

*> The same bolt left to run until it ends (at most 60 ticks).
 FLY-WHOLE.
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY
     COMPUTE WS-Z = WS-BZ + 0.5
     CALL "LIGHTNING-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-VISUAL WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         CALL "THROWN-TICK"
     END-PERFORM
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     IF WS-SLOT > 0
         CALL "PJ-DROP" USING WS-ROW
     END-IF.

*> Air in the 5 x 5 x 5 block around the own cell, except the floor layer.
 CLEAR-AIR.
     MOVE 0 TO WS-STATE
     PERFORM VARYING WS-I FROM -2 BY 1 UNTIL WS-I > 2
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 2
             PERFORM VARYING WS-K FROM -2 BY 1 UNTIL WS-K > 2
                 COMPUTE WS-CX = WS-BX + WS-I
                 COMPUTE WS-CY = WS-BY + WS-J
                 COMPUTE WS-CZ = WS-BZ + WS-K
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE WS-BX TO WS-CX
     MOVE WS-BY TO WS-CY
     MOVE WS-BZ TO WS-CZ.

*> Fires of the 3 x 3 x 3 block (WS-INSIDE) and of the rest of the 7 x 5 x 7 block above the floor (WS-OUTSIDE, added up).
 COUNT-FIRES.
     MOVE 0 TO WS-INSIDE
     PERFORM VARYING WS-I FROM -3 BY 1 UNTIL WS-I > 3
         PERFORM VARYING WS-J FROM -1 BY 1 UNTIL WS-J > 3
             PERFORM VARYING WS-BAR FROM -3 BY 1 UNTIL WS-BAR > 3
                 COMPUTE WS-CX = WS-BX + WS-I
                 COMPUTE WS-CY = WS-BY + WS-J
                 COMPUTE WS-CZ = WS-BZ + WS-BAR
                 CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
                 MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-LONG
                 CALL "KEY-BARE" USING WS-LONG WS-BARE
                 IF WS-BARE = "fire" OR "soul_fire"
                     IF WS-I >= -1 AND WS-I <= 1 AND WS-J >= -1 AND WS-J <= 1 AND WS-BAR >= -1 AND WS-BAR <= 1
                         ADD 1 TO WS-INSIDE
                     ELSE
                         ADD 1 TO WS-OUTSIDE
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE WS-BX TO WS-CX
     MOVE WS-BY TO WS-CY
     MOVE WS-BZ TO WS-CZ.

*> WS-KEY: the block of that key (its default state) at (WS-CX, WS-CY, WS-CZ).
 PLACE-AT.
     IF WS-KEY = "air"
         MOVE 0 TO WS-STATE
     ELSE
         CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW-TEXT WS-STATUS
         MOVE CB-DEFAULT-STATE(WS-ID + 1) TO WS-STATE
     END-IF
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE.

 READ-KEY.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-LONG
     CALL "KEY-BARE" USING WS-LONG WS-BARE.

 READ-PROP.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
     MOVE SPACES TO WS-LONG
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-LONG WS-RESULT
     MOVE WS-LONG TO WS-BARE.

 CHECK-TEXT.
     MOVE "A" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-VALUE TO TL-EXPECTED
     MOVE WS-BARE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-8-6B.
 COPY CORETEST.
 COPY MOBSPTEST.
