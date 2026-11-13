*> Implementation test (002-lane-mobs2, T4120; docs/protocol/20 section 5 bow goal and shot, 44 section 7 arrow tick, hit and ground, 18 section 7):
*> the skeleton (row 9, 20 health) draws its bow for 20 ticks and shoots an arrow at a target it has seen for 20 ticks within 15 blocks, standing still
*> while it does; an arrow flies (move, drag 0.99, gravity 0.05), sticks in a block (and is removed after 1200 ticks), or hits a player or a mob for
*> ceil(speed x base damage) and is removed; the owner is not hit; a player it kills gets death.attack.arrow with the shooter's name.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STDMOB-SKELETON.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY PROTO.
 COPY BRWORLD.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-SKELETON-TYPE       BINARY-LONG.
 01 WS-ARROW-TYPE          BINARY-LONG.
 01 WS-PIG-TYPE            BINARY-LONG.
 01 WS-SKELETON            BINARY-LONG.
 01 WS-PIG                 BINARY-LONG.
 01 WS-ARROW               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SPEED               FLOAT-LONG VALUE 1.6.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO2               FLOAT-LONG VALUE 0.
 01 WS-BASE                BINARY-LONG VALUE 2000.
 01 WS-OWNER               BINARY-LONG VALUE 0.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-STONE               BINARY-LONG.
 01 WS-DIRT                BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-ARROWS-BEFORE       BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.

 01 WS-CHAT                PIC X(4096).
 01 WS-NEG                 FLOAT-LONG VALUE -1.6.
 01 WS-DELTA               FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
*>   A world of the stand-in set has no arrow type and no arrow tick.
     CALL "ARROW-TYPE" USING WS-ARROW-TYPE
     CALL "ARROWS-TICK"
     MOVE "N" TO TL-MODE
     MOVE "test arrow: a world of the stand-in set has no arrow type" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ARROW-TYPE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-STANDARD-TABLES"
     CALL "BR-WORLD-READY"
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE "minecraft:skeleton" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-SKELETON-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:arrow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ARROW-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:pig" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PIG-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STONE = FUNCTION NUMVAL(WS-STATE-TEXT)
     MOVE "minecraft:dirt" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-DIRT = FUNCTION NUMVAL(WS-STATE-TEXT)
     MOVE "N" TO TL-MODE

     CALL "STDMOB-INDEX" USING WS-SKELETON-TYPE WS-INDEX
     MOVE "test stdmob skeleton: the skeleton is row 9" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The arena: high in the air above the player, 40 blocks of free sky east of x0.
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 4
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 40
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-X0 = WS-BX + 0.5
     MOVE WS-BY TO WS-Y
     COMPUTE WS-Z = WS-BZ + 0.5

*>   Flight: v = (1.6, 0, 0); after one tick the arrow is 1.6 on, its velocity (1.584, -0.05, 0).
     CALL "ARROW-SPAWN" USING WS-DIM WS-X0 WS-Y WS-Z WS-SPEED WS-ZERO WS-ZERO2 WS-BASE WS-OWNER WS-ARROW
     CALL "ARROWS-TICK"
     COMPUTE WS-DELTA = EN-X(WS-ARROW) - WS-X0
     MOVE "test arrow: after a tick the arrow has moved by its velocity 1.6" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(WS-DELTA - 1.6) < 0.0001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test arrow: drag 0.99 on x" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(EN-VX(WS-ARROW) - 1.584) < 0.0001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test arrow: gravity 0.05 on y" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(EN-VY(WS-ARROW) + 0.05) < 0.0001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ARROW

*>   A stone wall 5 blocks east: the arrow sticks in it and stays until 1200 ticks.
     COMPUTE WS-I = WS-BX + 5
     PERFORM VARYING WS-N FROM -3 BY 1 UNTIL WS-N > 3
         COMPUTE WS-VX = WS-BY + WS-N
         MOVE WS-VX TO WS-INDEX
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-I WS-INDEX WS-BZ WS-STONE
     END-PERFORM
     CALL "ARROW-SPAWN" USING WS-DIM WS-X0 WS-Y WS-Z WS-SPEED WS-ZERO WS-ZERO2 WS-BASE WS-OWNER WS-ARROW
     PERFORM 6 TIMES
         CALL "ARROWS-TICK"
     END-PERFORM
     MOVE "test arrow: an arrow that hits a block is in the ground" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-ON-GROUND(WS-ARROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test arrow: it stopped before the wall (x below 5 + the block x)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-X(WS-ARROW) < WS-BX + 5.0 AND EN-X(WS-ARROW) > WS-BX + 3.5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test arrow: an arrow in the ground does not move" TO TL-CASE
     MOVE EN-X(WS-ARROW) TO WS-VX
     CALL "ARROWS-TICK"
     MOVE 0 TO TL-OBSERVED-N
     IF EN-X(WS-ARROW) = WS-VX
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1198 TO EN-AGE(WS-ARROW)
     CALL "ARROWS-TICK"
     MOVE "test arrow: still there at age 1199" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ARROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ARROWS-TICK"
     MOVE "test arrow: removed at age 1200" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ARROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A hit on the player: ceil(1.6 x 2.0) = 4 points; the arrow is gone. An arrow of its owner passes through.
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 10.5
     MOVE WS-BY TO PL-Y(WS-PLAYER)
     MOVE WS-Z TO PL-Z(WS-PLAYER)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     COMPUTE WS-Y = WS-BY + 0.9
     COMPUTE WS-X = WS-BX + 8.5
     CALL "ARROW-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-SPEED WS-ZERO WS-ZERO2 WS-BASE WS-OWNER WS-ARROW
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-ARROW)
     PERFORM 3 TIMES
         CALL "ARROWS-TICK"
     END-PERFORM
     MOVE "test arrow: the owner is not hit by its own arrow" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE PL-HEALTH(WS-PLAYER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ARROW
     CALL "ARROW-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-SPEED WS-ZERO WS-ZERO2 WS-BASE WS-OWNER WS-ARROW
     PERFORM 3 TIMES
         CALL "ARROWS-TICK"
     END-PERFORM
     MOVE "test arrow: an arrow hits the player for ceil(1.6 x 2.0) = 4" TO TL-CASE
     MOVE 16 TO TL-EXPECTED-N
     MOVE PL-HEALTH(WS-PLAYER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test arrow: and is gone" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ARROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Arrows flying west and north (the yaw of each) and one in a chunk that is not loaded.
     CALL "ARROW-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-NEG WS-ZERO WS-ZERO2 WS-BASE WS-OWNER WS-ARROW
     CALL "ENTITY-REMOVE" USING WS-ARROW
     CALL "ARROW-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ZERO WS-ZERO2 WS-NEG WS-BASE WS-OWNER WS-ARROW
     CALL "ENTITY-REMOVE" USING WS-ARROW
     COMPUTE WS-VX = WS-X + 900
     CALL "ARROW-SPAWN" USING WS-DIM WS-VX WS-Y WS-Z WS-SPEED WS-ZERO WS-ZERO2 WS-BASE WS-OWNER WS-ARROW
     CALL "ARROWS-TICK"
     MOVE "test arrow: an arrow in an unloaded chunk waits" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ARROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-ARROW
*>   A hit on a pig: 4 of its 10.
     COMPUTE WS-X = WS-BX + 20.5
     CALL "MOB-SPAWN" USING WS-DIM WS-PIG-TYPE WS-X WS-Y WS-Z WS-YAW WS-PIG
     COMPUTE WS-X = WS-BX + 18.5
     CALL "ARROW-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-SPEED WS-ZERO WS-ZERO2 WS-BASE WS-OWNER WS-ARROW
     PERFORM 3 TIMES
         CALL "ARROWS-TICK"
     END-PERFORM
     MOVE "test arrow: an arrow hits a pig for 4" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-PIG) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-PIG

*>   A player shot dead by a skeleton's arrow: death.attack.arrow(victim, shooter).
     COMPUTE WS-X = WS-BX + 30.5
     MOVE WS-BY TO WS-Y
     CALL "MOB-SPAWN" USING WS-DIM WS-SKELETON-TYPE WS-X WS-Y WS-Z WS-YAW WS-SKELETON
     COMPUTE WS-X = WS-BX + 8.5
     COMPUTE WS-Y = WS-BY + 0.9
     MOVE 3 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     CALL "TEST-DRAIN-CHAT" USING WS-CONN WS-CHAT
     CALL "ARROW-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-SPEED WS-ZERO WS-ZERO2 WS-BASE EN-ID(WS-SKELETON) WS-ARROW
     PERFORM 3 TIMES
         CALL "ARROWS-TICK"
     END-PERFORM
     CALL "TEST-DRAIN-CHAT" USING WS-CONN WS-CHAT
     MOVE "T" TO TL-MODE
     MOVE "test arrow: a player killed by a skeleton's arrow gets death.attack.arrow" TO TL-CASE
     MOVE "death.attack.arrow(Stefan,Skeleton)" TO TL-EXPECTED
     MOVE WS-CHAT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE PS-ALIVE TO PL-STATE(WS-PLAYER)
*>   A player's own arrow that kills a pig credits the player (the experience orb appears).
     COMPUTE WS-X = WS-BX + 20.5
     MOVE 2 TO EN-HEALTH(WS-PIG)
     CALL "MOB-SPAWN" USING WS-DIM WS-PIG-TYPE WS-X WS-Y WS-Z WS-YAW WS-PIG
     MOVE 2 TO EN-HEALTH(WS-PIG)
     COMPUTE WS-X = WS-BX + 18.5
     CALL "ARROW-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-SPEED WS-ZERO WS-ZERO2 WS-BASE PL-ENTITY-ID(WS-PLAYER) WS-ARROW
     PERFORM 3 TIMES
         CALL "ARROWS-TICK"
     END-PERFORM
     MOVE "test arrow: an arrow of a player that kills a pig credits the player" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-KILLER(WS-PIG) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A skeleton 10 blocks from the player: it sees the target for 20 ticks, draws for 20, shoots; it stands still.
*>   The stone wall of the arrow test is taken away: it would block the line of sight.
     COMPUTE WS-I = WS-BX + 5
     PERFORM VARYING WS-N FROM -3 BY 1 UNTIL WS-N > 3
         COMPUTE WS-VX = WS-BY + WS-N
         MOVE WS-VX TO WS-INDEX
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-I WS-INDEX WS-BZ WS-AIR
     END-PERFORM
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 10.5
     MOVE WS-BY TO WS-Y
     COMPUTE WS-X0 = WS-X
     COMPUTE WS-I = FUNCTION INTEGER(WS-X0)
     COMPUTE WS-N = WS-BY - 1
     PERFORM VARYING WS-INDEX FROM -1 BY 1 UNTIL WS-INDEX > 12
         COMPUTE WS-VX = WS-BX + WS-INDEX
         MOVE WS-VX TO WS-I
         PERFORM VARYING WS-J FROM -10 BY 1 UNTIL WS-J > 10
             COMPUTE WS-K = WS-BZ + WS-J
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-I WS-N WS-K WS-DIRT
         END-PERFORM
     END-PERFORM
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     CALL "MOB-SPAWN" USING WS-DIM WS-SKELETON-TYPE WS-X WS-Y WS-Z WS-YAW WS-SKELETON
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 15
         CALL "MOB-STEP" USING WS-SKELETON
     END-PERFORM
     PERFORM COUNT-ARROWS
     MOVE "test stdmob skeleton: no arrow before the bow is drawn for 20 ticks" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         CALL "MOB-STEP" USING WS-SKELETON
     END-PERFORM
     PERFORM COUNT-ARROWS
     MOVE "test stdmob skeleton: one arrow after 35 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Strafing (20 section 5 bow goal, T4230): with the target seen for 20 ticks within 15 blocks the skeleton stands off its path and walks forward 0.5 and
*>   sideways (counter-clockwise: to the left of its facing) 0.5 of its walking speed; the target is at +x, so it moves toward +x and to -z. At 10
*>   blocks (d2 100: between a quarter and three quarters of the radius squared) it is neither backing off nor closing the gap on its own.
     COMPUTE EN-X(WS-SKELETON) = PL-X(WS-PLAYER) - 10
     MOVE PL-Z(WS-PLAYER) TO EN-Z(WS-SKELETON)
     MOVE 0 TO EN-STRAFE-BACK(WS-SKELETON) EN-STRAFE-CW(WS-SKELETON)
     MOVE 5 TO EN-STRAFE-TIME(WS-SKELETON)
     MOVE EN-X(WS-SKELETON) TO WS-VX
     MOVE EN-Z(WS-SKELETON) TO WS-VZ
     CALL "MOB-STEP" USING WS-SKELETON
     MOVE "test stdmob skeleton: it strafes: forward (+x) and to the left of its facing (-z) while it shoots" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-X(WS-SKELETON) > WS-VX + 0.001 AND EN-Z(WS-SKELETON) < WS-VZ - 0.001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   No second arrow before the 40-tick interval and the 20-tick draw (arrow 1 came at tick 22, arrow 2 at tick 83).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 29
         CALL "MOB-STEP" USING WS-SKELETON
     END-PERFORM
     PERFORM COUNT-ARROWS
     MOVE "test stdmob skeleton: no second arrow after 65 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 25
         CALL "MOB-STEP" USING WS-SKELETON
     END-PERFORM
     PERFORM COUNT-ARROWS
     MOVE "test stdmob skeleton: the second arrow after the interval and the draw" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Line of sight (20 section 5 step 1, 18 Sensing, T4230): a wall of stone between the skeleton and the player stops the shots: the seeTime
*>   falls below 0 (it counts down while the target is not seen) and no arrow is drawn; once the wall is gone the target is seen again.
     MOVE 1 TO WS-N
     PERFORM COUNT-ARROWS
     MOVE WS-N TO WS-ARROWS-BEFORE
     COMPUTE WS-I = WS-BX + 5
     PERFORM VARYING WS-INDEX FROM -8 BY 1 UNTIL WS-INDEX > 8
         COMPUTE WS-K = WS-BZ + WS-INDEX
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 2
             COMPUTE WS-L = WS-BY + WS-J
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-I WS-L WS-K WS-STONE
         END-PERFORM
     END-PERFORM
     MOVE 0 TO EN-DRAW(WS-SKELETON)
     MOVE 0 TO EN-SHOOT-TIME(WS-SKELETON)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 50
         CALL "MOB-STEP" USING WS-SKELETON
     END-PERFORM
     PERFORM COUNT-ARROWS
     MOVE "test stdmob skeleton: behind a wall it shoots no arrow in 50 ticks" TO TL-CASE
     MOVE WS-ARROWS-BEFORE TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test stdmob skeleton: and its seeTime counts down below 0" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-SWELL(WS-SKELETON) < 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-I = WS-BX + 5
     PERFORM VARYING WS-INDEX FROM -8 BY 1 UNTIL WS-INDEX > 8
         COMPUTE WS-K = WS-BZ + WS-INDEX
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 2
             COMPUTE WS-L = WS-BY + WS-J
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-I WS-L WS-K WS-AIR
         END-PERFORM
     END-PERFORM
     MOVE 0 TO EN-SWELL(WS-SKELETON)
*>   Alone (no player in reach) the goal resets; on Hard the interval is 20.
     MOVE 3 TO BW-DIFFICULTY
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 400.5
     MOVE 0 TO EN-TARGET(WS-SKELETON)
     CALL "MOB-STEP" USING WS-SKELETON
     MOVE "test stdmob skeleton: without a target the seeTime is 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-SWELL(WS-SKELETON) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE PL-X(WS-PLAYER) = WS-BX + 10.5
     MOVE 1 TO EN-DRAW(WS-SKELETON)
     MOVE 25 TO EN-SWELL(WS-SKELETON)
     MOVE 21 TO EN-DRAW(WS-SKELETON)
     CALL "MOB-STEP" USING WS-SKELETON
     MOVE "test stdmob skeleton: on Hard the next shot is 20 ticks away" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE EN-SHOOT-TIME(WS-SKELETON) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-FREE" USING PB-BUFFER
     STOP RUN.
 COUNT-ARROWS.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > EN-COUNT
         IF EN-USED(WS-INDEX) = 1 AND EN-TYPE(WS-INDEX) = WS-ARROW-TYPE
             ADD 1 TO WS-N
         END-IF
     END-PERFORM.
 END PROGRAM TEST-STDMOB-SKELETON.
 COPY CORETEST.
