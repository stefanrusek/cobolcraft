*> Implementation test (lane p49y; a standard world of the generated vanilla data pack (CC_GENERATED_DIR), skipped as a pass without it; docs/protocol/30-redstone-8 section 14.1): the movement game events posted by
*> ENTITY-MOVE through GAME-EVENT-MOVED: step, swim, flap, hit_ground, splash and bounce, with the moveDist and nextStep counters of 14.1.3, the supporting block of the step, the emission classes and the
*> exceptions (a teleport, a rider, a spectator, a sneaking or flying player, an entity of emission NONE).
*> The expected values are the worked examples of 14.1.12 (1 to 10) and rules of 14.1.2 to 14.1.10. Every case runs a mob (or a player row) of the standard world over a stone floor at y = 200 with ENTITY-MOVE,
*> and reads what the game event log (GAMEEVENT.cpy GE-LOG) holds after each call as "<call>:<event>" pairs.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GAME-EVENT-MOVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY CITEMS.
 COPY GAMEEVENT.
 COPY GEMOVE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-PROW                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ZTYPE               BINARY-LONG.
 01 WS-ROWT                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 40.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STONE               BINARY-LONG.
 01 WS-LADDER              BINARY-LONG.
 01 WS-CARPET              BINARY-LONG.
 01 WS-FENCE               BINARY-LONG.
 01 WS-SLIME               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-SKIP                BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-CALLS               BINARY-LONG.
 01 WS-GROUND              BINARY-LONG.
 01 WS-LIST                PIC X(400).
 01 WS-PTR                 BINARY-LONG.
 01 WS-BEFORE              BINARY-DOUBLE.
 01 WS-LOG                 BINARY-LONG.
 01 WS-NUM                 PIC Z9.
 01 WS-EXPECT              PIC X(400).
 01 WS-WHY                 PIC X(150).
 01 WS-BAT                 BINARY-LONG.
 01 WS-TURTLE              BINARY-LONG.
 01 WS-STRIDER             BINARY-LONG.
 01 WS-MINECART            BINARY-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-OK                  BINARY-LONG.
 01 WS-POWDER              BINARY-LONG.
 01 WS-ALLAY               BINARY-LONG.
 01 WS-BEE                 BINARY-LONG.
 01 WS-PHANTOM             BINARY-LONG.
 01 WS-VEX                 BINARY-LONG.
 01 WS-FLAPS               BINARY-LONG.
 01 WS-I0                  BINARY-LONG.
 01 WS-RAW                 BINARY-LONG VALUE 0.
 01 WS-PX0                 BINARY-LONG.
 01 WS-PX1                 BINARY-LONG.
 01 WS-PZ0                 BINARY-LONG.
 01 WS-PZ1                 BINARY-LONG.
 01 WS-STATE-OUT           BINARY-LONG.
 01 WS-DIST-OUT            PIC -9.9999.
 PROCEDURE DIVISION.
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "implementation 30-8 movement events: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 201 TO PL-Y(WS-PLAYER)
     MOVE PL-ENTITY-ROW(WS-PLAYER) TO WS-PROW
     MOVE "N" TO TL-MODE
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BY = 201
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-BX - 20
     COMPUTE WS-FZ = WS-BZ - 20
     MOVE 200 TO WS-FY
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:ladder" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-LADDER
     MOVE "minecraft:white_carpet" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-CARPET
     MOVE "minecraft:oak_fence" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-FENCE
     MOVE "minecraft:slime_block" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-SLIME
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:bat" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-BAT WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:turtle" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TURTLE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:strider" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-STRIDER WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:minecart" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-MINECART WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:powder_snow" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-POWDER
     MOVE "minecraft:allay" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ALLAY WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:bee" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-BEE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:phantom" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PHANTOM WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:vex" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-VEX WS-ENTITY-ROW WS-STATUS
     MOVE 12001 TO CW-TIME
     MOVE 1000 TO CW-TICKS
     COMPUTE WS-PX0 = WS-BX - 13
     COMPUTE WS-PX1 = WS-BX - 8
     COMPUTE WS-PZ0 = WS-BZ - 1
     COMPUTE WS-PZ1 = WS-BZ + 1
*>   Mob rows stay out of the way of the player and of one another: x = bx - 15 + row spacing.
     MOVE 0 TO WS-DY

*>   1. Example 1: a mob walks 0.18 blocks per call on a full block: moveDist 0.108 a call, > 1.0 at call 10 (1.08), nextStep 2.0, call 19 (2.052), nextStep 3.0, call 28 (3.024).
     MOVE WS-ZTYPE TO WS-TYPE
     PERFORM NEW-MOB
     MOVE 0.18 TO WS-LEN
     MOVE 30 TO WS-CALLS
     MOVE 1 TO WS-GROUND
     PERFORM WALK
     MOVE " 10:step 19:step 28:step" TO WS-EXPECT
     MOVE "example 1: 0.18 blocks per call on the ground: steps at calls 10, 19 and 28" TO WS-WHY
     PERFORM CHECK-LIST
     MOVE "nextStep is 4.0 after the third step" TO WS-WHY
     MOVE 4000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-NEXT-STEP(WS-ROWT) * 1000
     PERFORM CASE-LINE
     PERFORM FREE-MOB

*>   2. Example 2: 0.2158 a call: steps at 8 (1.0358), 16 (2.0717), 24 (3.1075), 31 (4.0139), 39 (5.0497).
     PERFORM NEW-MOB
     MOVE 0.2158 TO WS-LEN
     MOVE 40 TO WS-CALLS
     PERFORM WALK
     MOVE " 8:step 16:step 24:step 31:step 39:step" TO WS-EXPECT
     MOVE "example 2: 0.2158 per call: steps at calls 8, 16, 24, 31 and 39" TO WS-WHY
     PERFORM CHECK-LIST
     PERFORM FREE-MOB

*>   3. Example 3: 0.2806 a call: steps at 6, 12, 18, 24, 30, 36.
     PERFORM NEW-MOB
     MOVE 0.2806 TO WS-LEN
     MOVE 37 TO WS-CALLS
     PERFORM WALK
     MOVE " 6:step 12:step 18:step 24:step 30:step 36:step" TO WS-EXPECT
     MOVE "example 3: 0.2806 per call: steps at calls 6, 12, 18, 24, 30 and 36" TO WS-WHY
     PERFORM CHECK-LIST
     PERFORM FREE-MOB

*>   4. Example 4: climbing a ladder straight up 0.12 per call (horizontal 0): v3 = 0.072 counts: steps at call 14 (1.008) and 28 (2.016); the affected state is the ladder.
     PERFORM VARYING WS-CY FROM 201 BY 1 UNTIL WS-CY > 215
         COMPUTE WS-CX = WS-BX - 15
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-BZ WS-LADDER
     END-PERFORM
     PERFORM NEW-MOB
     MOVE 0 TO WS-LEN
     MOVE 0.12 TO WS-DY
     MOVE 29 TO WS-CALLS
     MOVE 0 TO WS-GROUND
     PERFORM WALK
     MOVE " 14:step 28:step" TO WS-EXPECT
     MOVE "example 4: climbing a ladder 0.12 per call: steps at calls 14 and 28" TO WS-WHY
     PERFORM CHECK-LIST
     MOVE "and the step's affected state is the ladder" TO WS-WHY
     MOVE WS-LADDER TO TL-EXPECTED-N
     MOVE GE-L-STATE(FUNCTION MOD(GE-COUNT - 1, 128) + 1) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM FREE-MOB
     PERFORM VARYING WS-CY FROM 201 BY 1 UNTIL WS-CY > 215
         COMPUTE WS-CX = WS-BX - 15
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-BZ WS-AIR
     END-PERFORM
     MOVE 0 TO WS-DY
     MOVE 1 TO WS-GROUND

*>   5. A step after the third gets nothing without ground: the same walk in the air (no support): moveDist grows, no step (not on the ground), and flyDist grows with it.
     PERFORM NEW-MOB
     MOVE 205 TO EN-Y(WS-ROWT)
     MOVE 0.3 TO WS-LEN
     MOVE 10 TO WS-CALLS
     MOVE 0 TO WS-GROUND
     PERFORM WALK
     MOVE SPACES TO WS-EXPECT
     MOVE "walking through the air: no step, no event" TO WS-WHY
     PERFORM CHECK-LIST
     MOVE "flyDist is 0.6 x the length of the movement summed (10 x 0.18 = 1.8)" TO WS-WHY
     MOVE 1800 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-FLY-DIST(WS-ROWT) * 1000 + 0.5
     PERFORM CASE-LINE
     PERFORM FREE-MOB

*>   6. Example 6: an entity on a carpet: P0 is the block under the carpet, P1 the carpet; r1 posts nothing, r2 posts step with the carpet as the affected state.
     COMPUTE WS-CX = WS-BX - 15
     MOVE 201 TO WS-CY
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 8
         COMPUTE WS-CZ = WS-BZ + WS-I - 4
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-CARPET
     END-PERFORM
     PERFORM NEW-MOB
     MOVE 201.0625 TO EN-Y(WS-ROWT)
     MOVE 0.18 TO WS-LEN
     MOVE 11 TO WS-CALLS
     MOVE 1 TO WS-GROUND
     PERFORM WALK-Z
     MOVE " 10:step" TO WS-EXPECT
     MOVE "example 6: on a carpet one step is posted at call 10" TO WS-WHY
     PERFORM CHECK-LIST
     MOVE "its affected state is the carpet, not the stone under it" TO WS-WHY
     MOVE WS-CARPET TO TL-EXPECTED-N
     MOVE GE-L-STATE(FUNCTION MOD(GE-COUNT - 1, 128) + 1) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM FREE-MOB
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 8
         COMPUTE WS-CZ = WS-BZ + WS-I - 4
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-AIR
     END-PERFORM

*>   7. On a fence (collision 1.5 high): the entity stands at y = 202.5 on the fence block (201); the cell under its feet is air, the supporting block is the fence: the step's state is the fence.
     COMPUTE WS-CX = WS-BX - 15
     MOVE 201 TO WS-CY
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 8
         COMPUTE WS-CZ = WS-BZ + WS-I - 4
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-FENCE
     END-PERFORM
     PERFORM NEW-MOB
     MOVE 202.5 TO EN-Y(WS-ROWT)
     MOVE 0.18 TO WS-LEN
     MOVE 11 TO WS-CALLS
     MOVE 1 TO WS-GROUND
     PERFORM WALK-Z
     MOVE " 10:step" TO WS-EXPECT
     MOVE "standing on a fence: a step is posted" TO WS-WHY
     PERFORM CHECK-LIST
     MOVE "its affected state is the fence (the legacy cell is the same cell)" TO WS-WHY
     MOVE WS-FENCE TO TL-EXPECTED-N
     MOVE GE-L-STATE(FUNCTION MOD(GE-COUNT - 1, 128) + 1) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM FREE-MOB
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 8
         COMPUTE WS-CZ = WS-BZ + WS-I - 4
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-AIR
     END-PERFORM

*>   8. Example 7 and 8: a fall of 1.25 blocks posts hit_ground when the entity is on the ground again, with the stone as the state; a drop of 0.5 onto the ground posts it too; flat walking none.
     PERFORM NEW-MOB
     MOVE 202.25 TO EN-Y(WS-ROWT)
     MOVE 0 TO WS-LEN
     MOVE -0.25 TO WS-DY
     MOVE 4 TO WS-CALLS
     MOVE 0 TO WS-GROUND
     PERFORM WALK
     MOVE SPACES TO WS-EXPECT
     MOVE "falling in the air posts nothing yet" TO WS-WHY
     PERFORM CHECK-LIST
     MOVE 1250 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-FALL-DIST(WS-ROWT) * 1000 + 0.5
     MOVE "fallDistance is 1.0 after four 0.25 drops" TO TL-CASE
     MOVE 1000 TO TL-EXPECTED-N
     PERFORM CASE-LINE
     MOVE 0.25 TO WS-DY
     COMPUTE WS-DY = 0 - WS-DY
     MOVE 1 TO WS-CALLS
     MOVE 1 TO WS-GROUND
     MOVE 0 TO WS-I
     PERFORM WALK
     MOVE " 1:hit_ground" TO WS-EXPECT
     MOVE "example 7: landing posts hit_ground once" TO WS-WHY
     PERFORM CHECK-LIST
     MOVE "its affected state is the stone supporting block" TO WS-WHY
     MOVE WS-STONE TO TL-EXPECTED-N
     MOVE GE-L-STATE(FUNCTION MOD(GE-COUNT - 1, 128) + 1) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE "and fallDistance is 0 again" TO WS-WHY
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FALL-DIST(WS-ROWT) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 201.5 TO EN-Y(WS-ROWT)
     MOVE -0.5 TO WS-DY
     MOVE 1 TO WS-CALLS
     PERFORM WALK
     MOVE " 1:hit_ground" TO WS-EXPECT
     MOVE "example 8: a slab-high drop (dy -0.5) onto the ground posts hit_ground" TO WS-WHY
     PERFORM CHECK-LIST
     MOVE 0 TO WS-DY
     MOVE 0.1 TO WS-LEN
     MOVE 5 TO WS-CALLS
     PERFORM WALK
     MOVE SPACES TO WS-EXPECT
     MOVE "example 8: walking on flat ground posts none" TO WS-WHY
     PERFORM CHECK-LIST
     PERFORM FREE-MOB

*>   9. A bat never posts hit_ground (its checkFallDamage is empty), an item entity does (emission NONE, fall handling not).
     MOVE WS-BAT TO WS-TYPE
     PERFORM NEW-MOB
     MOVE 202.25 TO EN-Y(WS-ROWT)
     MOVE 0 TO WS-LEN
     MOVE -1.25 TO WS-DY
     MOVE 1 TO WS-CALLS
     MOVE 1 TO WS-GROUND
     PERFORM WALK
     MOVE SPACES TO WS-EXPECT
     MOVE "a bat landing after a fall posts no hit_ground" TO WS-WHY
     PERFORM CHECK-LIST
     PERFORM FREE-MOB
     CALL "ENTITY-ALLOC" USING WS-ROWT
     CALL "ENTITY-NEW-ID" USING EN-ID(WS-ROWT)
     MOVE CR-LOOSE-ITEM TO EN-TYPE(WS-ROWT)
     MOVE WS-DIM TO EN-DIM(WS-ROWT)
     COMPUTE EN-X(WS-ROWT) = WS-BX - 15 + 0.5
     MOVE 202.25 TO EN-Y(WS-ROWT)
     COMPUTE EN-Z(WS-ROWT) = WS-BZ + 0.5
     MOVE 1 TO WS-GROUND
     MOVE 1 TO WS-CALLS
     MOVE -1.25 TO WS-DY
     PERFORM WALK
     MOVE " 1:hit_ground" TO WS-EXPECT
     MOVE "an item entity (emission NONE) landing after a fall posts hit_ground" TO WS-WHY
     PERFORM CHECK-LIST
     MOVE 0.18 TO WS-LEN
     MOVE 0 TO WS-DY
     MOVE 12 TO WS-CALLS
     PERFORM WALK
     MOVE SPACES TO WS-EXPECT
     MOVE "and walking posts no step: no emission pass for emission NONE, moveDist stands still" TO WS-WHY
     PERFORM CHECK-LIST
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-MOVE-DIST(WS-ROWT) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     PERFORM FREE-MOB

*>  10. Example 9 and swim: a mob drops into a pool (6 x 3 x 4 water over the floor): the first pass above the water records the state, entering posts splash once (fallDistance reset), landing on the pool floor
*>      posts no hit_ground; above the floor, off the ground, moveDist > nextStep with water below posts swim.
     PERFORM VARYING WS-CY FROM 201 BY 1 UNTIL WS-CY > 204
         PERFORM VARYING WS-CX FROM WS-PX0 BY 1 UNTIL WS-CX > WS-PX1
             PERFORM VARYING WS-CZ FROM WS-PZ0 BY 1 UNTIL WS-CZ > WS-PZ1
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-WATER
             END-PERFORM
         END-PERFORM
     END-PERFORM
     PERFORM NEW-MOB
     COMPUTE EN-X(WS-ROWT) = WS-BX - 12 + 0.5
     MOVE 208.5 TO EN-Y(WS-ROWT)
     MOVE 0 TO WS-LEN
     MOVE -0.5 TO WS-DY
     MOVE 0 TO WS-GROUND
     MOVE 14 TO WS-CALLS
     PERFORM WALK-X
     MOVE " 8:splash" TO WS-EXPECT
     MOVE "example 9: dropping into water posts splash once (the box touches water at call 8, y = 204.5)" TO WS-WHY
     PERFORM CHECK-LIST
     MOVE "fallDistance is reset in water" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FALL-DIST(WS-ROWT) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 1 TO WS-GROUND
     MOVE 1 TO WS-CALLS
     PERFORM WALK-X
     MOVE SPACES TO WS-EXPECT
     MOVE "landing on the pool floor (still moving down, on the ground) posts no hit_ground" TO WS-WHY
     PERFORM CHECK-LIST
     PERFORM FREE-MOB
     PERFORM NEW-MOB
     COMPUTE EN-X(WS-ROWT) = WS-BX - 12 + 0.5
     MOVE 203.5 TO EN-Y(WS-ROWT)
     MOVE 0 TO WS-GROUND
     MOVE 0.18 TO WS-LEN
     MOVE 0 TO WS-DY
     MOVE 11 TO WS-CALLS
     PERFORM WALK-X
     MOVE " 10:swim" TO WS-EXPECT
     MOVE "above the floor in water, off the ground: moveDist > nextStep posts swim at call 10" TO WS-WHY
     PERFORM CHECK-LIST
     MOVE 0 TO WS-LEN
     MOVE 1 TO WS-CALLS
     PERFORM WALK-X
     MOVE SPACES TO WS-EXPECT
     MOVE "a pass with no movement in water keeps the water state and posts no splash" TO WS-WHY
     PERFORM CHECK-LIST
     PERFORM FREE-MOB
     PERFORM VARYING WS-CY FROM 201 BY 1 UNTIL WS-CY > 204
         PERFORM VARYING WS-CX FROM WS-PX0 BY 1 UNTIL WS-CX > WS-PX1
             PERFORM VARYING WS-CZ FROM WS-PZ0 BY 1 UNTIL WS-CZ > WS-PZ1
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM

*>  11. Example 10: a bat flies over open air: flap at tickCount 10 and 20 (multiples of 10): the cell below the feet is air; not at the other ticks.
     MOVE 1000 TO CW-TICKS
     MOVE WS-BAT TO WS-TYPE
     PERFORM NEW-MOB
     MOVE 210 TO EN-Y(WS-ROWT)
     MOVE 0.1 TO WS-LEN
     MOVE 0 TO WS-GROUND
     MOVE 0 TO WS-DY
     MOVE SPACES TO WS-LIST
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 22
         COMPUTE CW-TICKS = 1000 + WS-I
         PERFORM WALK-ONCE
     END-PERFORM
     MOVE " 10:flap 20:flap" TO WS-EXPECT
     MOVE "example 10: a bat flaps at tickCount 10 and 20 over air, at none of the other ticks of 1 to 22" TO WS-WHY
     PERFORM CHECK-LIST
     MOVE 1000 TO CW-TICKS
     PERFORM FREE-MOB

*>  12. Never posted: a teleport (over 8 blocks), a rider, a spectator, a sneaking player on the ground, a flying player; posted: a sneaking player in the air (moveDist grows, no step).
     PERFORM NEW-MOB
     MOVE 0 TO WS-LEN
     MOVE 1 TO WS-CALLS
     MOVE 1 TO WS-GROUND
     COMPUTE WS-X = EN-X(WS-ROWT) + 20
     MOVE EN-Y(WS-ROWT) TO WS-Y
     MOVE EN-Z(WS-ROWT) TO WS-Z
     MOVE GE-COUNT TO WS-BEFORE
     CALL "ENTITY-MOVE" USING WS-ROWT WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-GROUND
     MOVE "a displacement of 20 blocks is a teleport: no counter changes" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-MOVE-DIST(WS-ROWT) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 5 TO EN-VEHICLE(WS-ROWT)
     MOVE 0.18 TO WS-LEN
     MOVE 12 TO WS-CALLS
     PERFORM WALK
     MOVE SPACES TO WS-EXPECT
     MOVE "a rider posts nothing" TO WS-WHY
     PERFORM CHECK-LIST
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-MOVE-DIST(WS-ROWT) TO TL-OBSERVED-N
     MOVE "and its moveDist stands still" TO TL-CASE
     PERFORM CASE-LINE
     MOVE 0 TO EN-VEHICLE(WS-ROWT)
     MOVE 6 TO EN-MOUNT(WS-ROWT)
     PERFORM WALK
     MOVE "a mob riding a mob posts nothing" TO WS-WHY
     PERFORM CHECK-LIST
     MOVE 0 TO EN-MOUNT(WS-ROWT)
     PERFORM FREE-MOB
     MOVE WS-PROW TO WS-ROWT
     MOVE 0.18 TO WS-LEN
     COMPUTE EN-X(WS-ROWT) = WS-BX - 10 + 0.5
     COMPUTE EN-Z(WS-ROWT) = WS-BZ + 0.5
     MOVE 201 TO EN-Y(WS-ROWT)
     MOVE 3 TO PL-MODE(WS-PLAYER)
     MOVE 1 TO WS-GROUND
     MOVE 12 TO WS-CALLS
     PERFORM WALK
     MOVE "a spectator (noPhysics) posts nothing" TO WS-WHY
     MOVE SPACES TO WS-EXPECT
     PERFORM CHECK-LIST
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 2 TO PL-POSE-FLAGS(WS-PLAYER)
     PERFORM WALK
     MOVE "a player sneaking on the ground posts no step" TO WS-WHY
     PERFORM CHECK-LIST
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-MOVE-DIST(WS-ROWT) TO TL-OBSERVED-N
     MOVE "and accumulates no walked distance (emission NONE)" TO TL-CASE
     PERFORM CASE-LINE
     MOVE 1 TO PL-FLYING(WS-PLAYER)
     MOVE 0 TO PL-POSE-FLAGS(WS-PLAYER)
     PERFORM WALK
     MOVE "a flying player posts no step" TO WS-WHY
     PERFORM CHECK-LIST
     MOVE 0 TO PL-FLYING(WS-PLAYER)
     MOVE 0 TO WS-GROUND
     MOVE 2 TO PL-POSE-FLAGS(WS-PLAYER)
     PERFORM WALK
     MOVE "a sneaking player in the air runs the pass (emission ALL) but cannot step" TO WS-WHY
     PERFORM CHECK-LIST
     MOVE "its moveDist grows (12 x 0.108)" TO TL-CASE
     MOVE 1296 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-MOVE-DIST(WS-ROWT) * 1000 + 0.5
     PERFORM CASE-LINE
     MOVE 0 TO PL-POSE-FLAGS(WS-PLAYER)
     MOVE 0 TO EN-MOVE-DIST(WS-ROWT) EN-NEXT-STEP(WS-ROWT)
     MOVE 1 TO WS-GROUND
     MOVE 11 TO WS-CALLS
     PERFORM WALK
     MOVE " 10:step" TO WS-EXPECT
     MOVE "a walking player on the ground steps at call 10 like a mob" TO WS-WHY
     PERFORM CHECK-LIST

*>  13. A swimming player on the ground (the swimming flag) cannot step; in the water it posts swim.
     MOVE 0 TO EN-MOVE-DIST(WS-ROWT) EN-NEXT-STEP(WS-ROWT)
     MOVE 1 TO PL-SWIMMING(WS-PLAYER)
     MOVE 11 TO WS-CALLS
     PERFORM WALK
     MOVE "a swimming player (flag) on dry ground: the step fails, no swim without water" TO WS-WHY
     MOVE SPACES TO WS-EXPECT
     PERFORM CHECK-LIST
     MOVE 0 TO PL-SWIMMING(WS-PLAYER)
     MOVE 5 TO PL-POSE(WS-PLAYER)
     MOVE 0 TO EN-MOVE-DIST(WS-ROWT) EN-NEXT-STEP(WS-ROWT)
     MOVE 201 TO EN-Y(WS-ROWT)
     MOVE 0 TO WS-GROUND
     MOVE 11 TO WS-CALLS
     PERFORM WALK
     MOVE " 10:step" TO WS-EXPECT
     MOVE "a player in the crouching pose (not the shift key) steps off the ground with no vertical movement" TO WS-WHY
     PERFORM CHECK-LIST
     MOVE 0 TO PL-POSE(WS-PLAYER)
     MOVE 1 TO WS-GROUND

*>  14. The crouching rule: a crouching mob with no vertical movement steps off the ground; a minecart (on rails) does too.
     PERFORM NEW-MOB
     MOVE 1 TO EN-CROUCHING(WS-ROWT)
     MOVE 0.18 TO WS-LEN
     MOVE 0 TO WS-GROUND
     MOVE 11 TO WS-CALLS
     PERFORM WALK
     MOVE " 10:step" TO WS-EXPECT
     MOVE "a crouching mob (dy 0) steps although its on-ground flag is off" TO WS-WHY
     PERFORM CHECK-LIST
     PERFORM FREE-MOB
     MOVE WS-MINECART TO WS-TYPE
     MOVE 1 TO WS-RAW
     PERFORM NEW-MOB
     MOVE 0.18 TO WS-LEN
     MOVE 11 TO WS-CALLS
     PERFORM WALK
     MOVE " 10:step" TO WS-EXPECT
     MOVE "a minecart steps off the ground (on rails)" TO WS-WHY
     PERFORM CHECK-LIST
     PERFORM FREE-MOB

*>  15. The nextStep overrides: turtle +0.15, warden +0.55 and strider +0.6 from moveDist.
     MOVE WS-TURTLE TO WS-TYPE
     PERFORM NEW-MOB
     MOVE 1 TO WS-GROUND
     MOVE 0.18 TO WS-LEN
     MOVE 11 TO WS-CALLS
     PERFORM WALK
     MOVE "a turtle: nextStep = moveDist + 0.15 after the first step (1.08 + 0.15)" TO WS-WHY
     MOVE 1230 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-NEXT-STEP(WS-ROWT) * 1000 + 0.5
     MOVE WS-WHY TO TL-CASE
     PERFORM CASE-LINE
     PERFORM FREE-MOB
     MOVE WS-STRIDER TO WS-TYPE
     PERFORM NEW-MOB
     MOVE 0.18 TO WS-LEN
     MOVE 11 TO WS-CALLS
     PERFORM WALK
     MOVE "a strider: nextStep = moveDist + 0.6 after the first step (1.08 + 0.6)" TO TL-CASE
     MOVE 1680 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-NEXT-STEP(WS-ROWT) * 1000 + 0.5
     PERFORM CASE-LINE
     PERFORM FREE-MOB
     MOVE "minecraft:warden" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     PERFORM NEW-MOB
     MOVE 0.18 TO WS-LEN
     MOVE 11 TO WS-CALLS
     PERFORM WALK
     MOVE "a warden: nextStep = moveDist + 0.55 after the first step (1.08 + 0.55)" TO TL-CASE
     MOVE 1630 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-NEXT-STEP(WS-ROWT) * 1000 + 0.5
     PERFORM CASE-LINE
     PERFORM FREE-MOB

*>  16. Bounce: landing on a slime block faster than the gravity (0.08) posts hit_ground then bounce (position the entity's, no state); a slow landing and a landing with the shift key do not bounce.
     MOVE WS-ZTYPE TO WS-TYPE
     COMPUTE WS-CX = WS-BX - 15
     MOVE 201 TO WS-CY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-BZ WS-SLIME
     PERFORM NEW-MOB
     MOVE 203.0 TO EN-Y(WS-ROWT)
     MOVE 0.01 TO WS-LEN
     MOVE -1 TO WS-DY
     MOVE 1 TO WS-CALLS
     MOVE 1 TO WS-GROUND
     PERFORM WALK-Z
     MOVE " 1:hit_ground 1:bounce" TO WS-EXPECT
     MOVE "landing on slime at speed 1.0: hit_ground, then bounce" TO WS-WHY
     PERFORM CHECK-LIST
     MOVE 204.0 TO EN-Y(WS-ROWT)
     MOVE 0 TO EN-FALL-DIST(WS-ROWT)
     MOVE 1 TO EN-IN-WATER(WS-ROWT)
     MOVE -0.05 TO WS-DY
     MOVE 202.05 TO EN-Y(WS-ROWT)
     PERFORM WALK-Z
     MOVE " 1:hit_ground" TO WS-EXPECT
     MOVE "landing on slime slower than the gravity: no bounce" TO WS-WHY
     PERFORM CHECK-LIST
     PERFORM FREE-MOB
     MOVE WS-PROW TO WS-ROWT
     COMPUTE EN-X(WS-ROWT) = WS-BX - 15 + 0.5
     COMPUTE EN-Z(WS-ROWT) = WS-BZ + 0.5
     MOVE 203.0 TO EN-Y(WS-ROWT)
     MOVE 2 TO PL-POSE-FLAGS(WS-PLAYER)
     MOVE -1 TO WS-DY
     MOVE 0 TO EN-FALL-DIST(WS-ROWT)
     PERFORM WALK-Z
     MOVE " 1:hit_ground" TO WS-EXPECT
     MOVE "a sneaking player landing on slime does not bounce (isSuppressingBounce)" TO WS-WHY
     PERFORM CHECK-LIST
     MOVE 0 TO PL-POSE-FLAGS(WS-PLAYER)
*>   a player jumping up resets the fall distance (the handler's rule): a rise after a fall of 1.0
     MOVE 5 TO EN-FALL-DIST(WS-ROWT)
     MOVE 201.0 TO EN-Y(WS-ROWT)
     MOVE 0.4 TO WS-DY
     MOVE 0 TO WS-GROUND
     PERFORM WALK-Z
     MOVE "a player moving up resets fallDistance" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FALL-DIST(WS-ROWT) TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-CY WS-BZ WS-AIR

*>  17. Direct programs: powder snow and a ladder are climbable states, stone is not; a step attempt on air fails whatever else holds.
     MOVE 1 TO WS-I
     CALL "GAME-EVENT-CLIMBABLE" USING WS-POWDER WS-OK
     MOVE "powder snow is climbable (isStateClimbable)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CASE-LINE
     CALL "GAME-EVENT-CLIMBABLE" USING WS-STONE WS-OK
     MOVE "stone is not climbable" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CASE-LINE
     MOVE 1 TO MV-ON-GROUND
     MOVE 0 TO MV-SWIMMING MV-CROUCH MV-DY MV-ROW MV-DIM
     MOVE "zombie" TO MV-KEY
     CALL "GAME-EVENT-STEP-TRY" USING MV-CTX WS-AIR WS-ONE WS-OK
     MOVE "a step attempt on air fails even on the ground" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     PERFORM CASE-LINE

*>  18. The flapping mobs over open air: an allay off the ground every pass, a bee every second tickCount, a vex every fourth, a phantom when (id mod 25 + tickCount) mod 25 = 0.
     MOVE WS-ALLAY TO WS-TYPE
     PERFORM NEW-MOB
     MOVE 210 TO EN-Y(WS-ROWT)
     MOVE 0.1 TO WS-LEN
     MOVE 0 TO WS-GROUND
     MOVE 1000 TO CW-TICKS
     MOVE SPACES TO WS-LIST
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         COMPUTE CW-TICKS = 1000 + WS-I
         PERFORM WALK-ONCE
     END-PERFORM
     MOVE " 1:flap 2:flap 3:flap" TO WS-EXPECT
     MOVE "an allay off the ground flaps at every pass" TO WS-WHY
     PERFORM CHECK-LIST
     PERFORM FREE-MOB
     MOVE 1000 TO CW-TICKS
     MOVE WS-BEE TO WS-TYPE
     PERFORM NEW-MOB
     MOVE 210 TO EN-Y(WS-ROWT)
     MOVE 0.1 TO WS-LEN
     MOVE 0 TO WS-GROUND
     MOVE SPACES TO WS-LIST
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         COMPUTE CW-TICKS = 1000 + WS-I
         PERFORM WALK-ONCE
     END-PERFORM
     MOVE " 2:flap 4:flap" TO WS-EXPECT
     MOVE "a flying bee flaps on every second tickCount" TO WS-WHY
     PERFORM CHECK-LIST
     PERFORM FREE-MOB
     MOVE 1000 TO CW-TICKS
     MOVE WS-VEX TO WS-TYPE
     PERFORM NEW-MOB
     MOVE 210 TO EN-Y(WS-ROWT)
     MOVE 0.1 TO WS-LEN
     MOVE 0 TO WS-GROUND
     MOVE SPACES TO WS-LIST
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         COMPUTE CW-TICKS = 1000 + WS-I
         PERFORM WALK-ONCE
     END-PERFORM
     MOVE " 4:flap 8:flap" TO WS-EXPECT
     MOVE "a vex flaps on every fourth tickCount" TO WS-WHY
     PERFORM CHECK-LIST
     PERFORM FREE-MOB
     MOVE 1000 TO CW-TICKS
     MOVE WS-PHANTOM TO WS-TYPE
     PERFORM NEW-MOB
     MOVE 210 TO EN-Y(WS-ROWT)
     MOVE 0.05 TO WS-LEN
     MOVE 0 TO WS-GROUND
     COMPUTE WS-I0 = 25 - FUNCTION MOD(EN-ID(WS-ROWT), 25)
     MOVE SPACES TO WS-LIST
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 25
         COMPUTE CW-TICKS = 1000 + WS-I
         PERFORM WALK-ONCE
     END-PERFORM
     MOVE WS-I0 TO WS-NUM
     MOVE SPACES TO WS-EXPECT
     STRING " " DELIMITED BY SIZE FUNCTION TRIM(WS-NUM) DELIMITED BY SIZE ":flap" DELIMITED BY SIZE INTO WS-EXPECT
     MOVE "a phantom flaps once in 25 ticks, when (id mod 25 + tickCount) mod 25 = 0" TO WS-WHY
     PERFORM CHECK-LIST
     PERFORM FREE-MOB
     MOVE 1000 TO CW-TICKS
     STOP RUN.

*> A new mob of type WS-TYPE at the left end of the floor, on it (feet 201), standing on the ground; the log counter is read before every case.
 NEW-MOB.
     COMPUTE WS-X = WS-BX - 15 + 0.5
     MOVE 201 TO WS-Y
     COMPUTE WS-Z = WS-BZ + 0.5
     IF WS-TYPE = 0
         MOVE WS-ZTYPE TO WS-TYPE
     END-IF
     IF WS-RAW = 1
         CALL "ENTITY-ALLOC" USING WS-ROWT
         CALL "ENTITY-NEW-ID" USING EN-ID(WS-ROWT)
         MOVE WS-TYPE TO EN-TYPE(WS-ROWT)
         MOVE WS-DIM TO EN-DIM(WS-ROWT)
         MOVE WS-X TO EN-X(WS-ROWT)
         MOVE WS-Y TO EN-Y(WS-ROWT)
         MOVE WS-Z TO EN-Z(WS-ROWT)
         MOVE 0 TO WS-RAW
     ELSE
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROWT
     END-IF
     MOVE 1 TO WS-GROUND
     MOVE 0 TO WS-DY
     MOVE 0 TO WS-TYPE
     .

 FREE-MOB.
     IF WS-ROWT NOT = WS-PROW
         IF EN-USED(WS-ROWT) = 1
             CALL "ENTITY-REMOVE" USING WS-ROWT
         END-IF
     END-IF
     MOVE 0 TO WS-DY
     MOVE 0 TO WS-LEN
     .

*> WS-CALLS calls of ENTITY-MOVE moving WS-LEN on x and WS-DY on y each, WS-GROUND the flag; WS-LIST gets " <call>:<event>" for every event of the log.
 WALK.
     PERFORM WALK-X
     .

 WALK-X.
     MOVE SPACES TO WS-LIST
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CALLS
         COMPUTE WS-X = EN-X(WS-ROWT) + WS-LEN
         COMPUTE WS-Y = EN-Y(WS-ROWT) + WS-DY
         MOVE EN-Z(WS-ROWT) TO WS-Z
         PERFORM WALK-CALL
     END-PERFORM
     .

 WALK-Z.
     MOVE SPACES TO WS-LIST
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-CALLS
         MOVE EN-X(WS-ROWT) TO WS-X
         COMPUTE WS-Y = EN-Y(WS-ROWT) + WS-DY
         COMPUTE WS-Z = EN-Z(WS-ROWT) + WS-LEN
         PERFORM WALK-CALL
     END-PERFORM
     .

*> One call at WS-X, WS-Y, WS-Z for the whole table row; a player row moves its player too (PL-X).
 WALK-ONCE.
     COMPUTE WS-X = EN-X(WS-ROWT) + WS-LEN
     COMPUTE WS-Y = EN-Y(WS-ROWT) + WS-DY
     MOVE EN-Z(WS-ROWT) TO WS-Z
     PERFORM WALK-CALL
     .

 WALK-CALL.
     MOVE GE-COUNT TO WS-BEFORE
     IF EN-PLAYER(WS-ROWT) > 0
         MOVE WS-X TO PL-X(EN-PLAYER(WS-ROWT))
         MOVE WS-Y TO PL-Y(EN-PLAYER(WS-ROWT))
         MOVE WS-Z TO PL-Z(EN-PLAYER(WS-ROWT))
     END-IF
     CALL "ENTITY-MOVE" USING WS-ROWT WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-GROUND
     COMPUTE WS-K = WS-BEFORE
     PERFORM UNTIL WS-K >= GE-COUNT
         ADD 1 TO WS-K
         COMPUTE WS-LOG = FUNCTION MOD(WS-K - 1, 128) + 1
         MOVE WS-I TO WS-NUM
         STRING " " DELIMITED BY SIZE FUNCTION TRIM(WS-NUM) DELIMITED BY SIZE ":" DELIMITED BY SIZE
             FUNCTION TRIM(GE-L-NAME(WS-LOG)) DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-PTR
     END-PERFORM
     .

 CHECK-LIST.
     MOVE WS-WHY TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-EXPECT TO TL-EXPECTED
     MOVE WS-LIST TO TL-OBSERVED
     PERFORM CASE-LINE
     MOVE "N" TO TL-MODE
     .

 CASE-LINE.
     MOVE SPACES TO WS-ENTITY-ROW
     STRING "implementation 30-8 movement: " DELIMITED BY SIZE FUNCTION TRIM(TL-CASE) DELIMITED BY SIZE INTO WS-ENTITY-ROW
     MOVE WS-ENTITY-ROW TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-GAME-EVENT-MOVE.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY PORTALTEST.
