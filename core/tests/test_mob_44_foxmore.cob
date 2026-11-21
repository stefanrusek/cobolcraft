*> Implementation test (002-lane-mobsa5; 44 part 4 section 4, 44-x1 section 8.7, 19 section 7): fox melee bite (2 points, cooldown 20, reach 1.44 + the prey's width squared), the sleep goal (countdown,
*> night or shelter, alertable entities, wake in thunder or with prey), the faceplant countdown (40), the sweet berry bush (age 3 to 1, berries into the hand and as items, 40 ticks at the bush) and the
*> item search (one item into the hand, the rest of the stack dropped again).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-44-FOXMORE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-FOX                 BINARY-LONG.
 01 WS-CHICKEN             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-HEALTH0             BINARY-LONG.
 01 WS-ASLEEP              BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-BIT32               BINARY-LONG VALUE 32.
 01 WS-BIT64               BINARY-LONG VALUE 64.
 01 WS-BIT4                BINARY-LONG VALUE 4.
 01 WS-MODE-SET            BINARY-LONG VALUE 2.
 01 WS-MODE-READ           BINARY-LONG VALUE 1.
 01 WS-PROP                PIC X(24) VALUE "age".
 01 WS-TEXT                PIC X(32).
 01 WS-RESULT              BINARY-LONG.
 01 WS-OFFSET              FLOAT-LONG VALUE 0.
 01 WS-PATCH               BINARY-LONG VALUE 0.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-ROWI                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 2.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 2.5
     MOVE "N" TO TL-MODE
     MOVE 2 TO BW-DIFFICULTY
     MOVE 18000 TO CW-TIME
     MOVE "minecraft:fox" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-X0 + 24.5
     COMPUTE WS-Y = WS-FLOOR + 1
     COMPUTE WS-Z = WS-Z0 + 24.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-FOX
     MOVE 1 TO EN-ON-GROUND(WS-FOX)
     MOVE "minecraft:chicken" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-X0 + 25.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-CHICKEN
     MOVE WS-CHICKEN TO EN-FOE(WS-FOX)
     MOVE EN-ID(WS-CHICKEN) TO EN-FOE-ID(WS-FOX)

*>   Melee: the chicken one block away is bitten for 2; the cooldown is 20 ticks.
     MOVE EN-HEALTH(WS-CHICKEN) TO WS-HEALTH0
     CALL "M44-FOX-MELEE" USING WS-FOX WS-HIT
     MOVE "acceptance US15 44§4 Fox melee: prey within reach is bitten for 2" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 100 + WS-HEALTH0 - 2
     COMPUTE TL-OBSERVED-N = WS-HIT * 100 + EN-HEALTH(WS-CHICKEN)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44§4 Fox melee: the cooldown is 20 ticks" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE EN-FOX-ATK(WS-FOX) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 19
         CALL "M44-FOX-MELEE" USING WS-FOX WS-HIT
         ADD WS-HIT TO WS-N
     END-PERFORM
     MOVE "acceptance US15 44§4 Fox melee: no bite during the 19 ticks after a bite" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "M44-FOX-MELEE" USING WS-FOX WS-HIT
     MOVE "acceptance US15 44§4 Fox melee: the second bite on the 20th tick" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Out of reach: no bite.
     MOVE 0 TO EN-FOX-ATK(WS-FOX)
     COMPUTE EN-X(WS-CHICKEN) = EN-X(WS-FOX) + 4
     MOVE 20 TO EN-HEALTH(WS-CHICKEN)
     CALL "M44-FOX-MELEE" USING WS-FOX WS-HIT
     MOVE "acceptance US15 44§4 Fox melee: prey 4 blocks away is not bitten" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A prey that died in the bite is let go.
     MOVE 0 TO EN-FOX-ATK(WS-FOX)
     COMPUTE EN-X(WS-CHICKEN) = EN-X(WS-FOX) + 0.5
     MOVE 1 TO EN-HEALTH(WS-CHICKEN)
     MOVE 0 TO EN-HURT(WS-CHICKEN)
     CALL "M44-FOX-HUNT" USING WS-FOX WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§4 Fox melee: a prey that died in the bite is let go" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FOE(WS-FOX) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-FOX-FLAGS(WS-FOX)

*>   Sleep: not before the countdown; at night it sleeps at once at 0 (even with the player near); the crouch bits go.
     MOVE 5 TO EN-FOX-SLP(WS-FOX)
     MOVE 4 TO EN-FOX-FLAGS(WS-FOX)
     CALL "M44-FOX-SLEEP" USING WS-FOX WS-ASLEEP
     MOVE "acceptance US15 44§4 Fox sleep: the countdown is still running" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 0 * 100 + 4
     COMPUTE TL-OBSERVED-N = WS-ASLEEP * 100 + EN-FOX-SLP(WS-FOX)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO EN-FOX-SLP(WS-FOX)
     CALL "M44-FOX-SLEEP" USING WS-FOX WS-ASLEEP
     MOVE "acceptance US15 44§4 Fox sleep: at night with the countdown at 0 the fox sleeps (flag 32), crouching is cleared" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ASLEEP = 1 AND EN-FOX-FLAGS(WS-FOX) = 32
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "M44-FOX-SLEEP" USING WS-FOX WS-ASLEEP
     MOVE "acceptance US15 44§4 Fox sleep: it keeps sleeping" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ASLEEP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO CW-THUNDERING
     CALL "M44-FOX-SLEEP" USING WS-FOX WS-ASLEEP
     MOVE 0 TO CW-THUNDERING
     MOVE "acceptance US15 44§4 Fox sleep: thunder wakes it, the countdown is rolled again (1 to 140)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ASLEEP = 0 AND EN-FOX-FLAGS(WS-FOX) = 0 AND EN-FOX-SLP(WS-FOX) >= 1 AND EN-FOX-SLP(WS-FOX) <= 140
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO EN-FOX-SLP(WS-FOX)
     CALL "M44-FOX-SLEEP" USING WS-FOX WS-ASLEEP
     MOVE WS-CHICKEN TO EN-FOE(WS-FOX)
     CALL "M44-FOX-SLEEP" USING WS-FOX WS-ASLEEP
     MOVE "acceptance US15 44§4 Fox sleep: a target wakes it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ASLEEP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-FOE(WS-FOX)
*>   The first call rolls the countdown (1 to 140) and keeps counting.
     MOVE 0 TO EN-FOX-SLP(WS-FOX)
     MOVE 6000 TO CW-TIME
     CALL "M44-FOX-SLEEP" USING WS-FOX WS-ASLEEP
     MOVE "acceptance US15 44§4 Fox sleep: the first call rolls the countdown" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-FOX-SLP(WS-FOX) >= 1 AND EN-FOX-SLP(WS-FOX) <= 140
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   By day a player within (12, 6, 12) who is not sneaking keeps it awake.
     MOVE 6000 TO CW-TIME
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-FOX) + 3
     COMPUTE PL-Y(WS-PLAYER) = EN-Y(WS-FOX)
     COMPUTE PL-Z(WS-PLAYER) = EN-Z(WS-FOX)
     MOVE 0 TO PL-SNEAKING(WS-PLAYER)
     MOVE 1 TO EN-FOX-SLP(WS-FOX)
     CALL "M44-FOX-SLEEP" USING WS-FOX WS-ASLEEP
     MOVE "acceptance US15 44§4 Fox sleep: by day a player in range keeps the fox awake" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ASLEEP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PL-SNEAKING(WS-PLAYER)
     MOVE 1 TO EN-FOX-SLP(WS-FOX)
     MOVE 0 TO EN-HEALTH(WS-CHICKEN)
     CALL "M44-FOX-ALERT" USING WS-FOX WS-A
     MOVE "acceptance US15 44§4 Fox sleep: a sneaking player and a dead chicken do not alert" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-A TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO EN-HEALTH(WS-CHICKEN)
     CALL "M44-FOX-ALERT" USING WS-FOX WS-A
     MOVE "acceptance US15 44§4 Fox sleep: a living chicken in range alerts" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-A TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-FOX) + 40
     MOVE 0 TO PL-SNEAKING(WS-PLAYER)

*>   Faceplant: the countdown of 40 ends the flag.
     MOVE 64 TO EN-FOX-FLAGS(WS-FOX)
     MOVE 0 TO EN-FOX-FP(WS-FOX)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 39
         CALL "M44-FOX-FACEPLANT" USING WS-FOX WS-A
     END-PERFORM
     MOVE "acceptance US15 44§x1 8.7 Fox faceplant: faceplanted for 39 ticks after the start" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 100 + 64
     COMPUTE TL-OBSERVED-N = WS-A * 100 + EN-FOX-FLAGS(WS-FOX)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "M44-FOX-FACEPLANT" USING WS-FOX WS-A
     MOVE "acceptance US15 44§x1 8.7 Fox faceplant: the 40th tick clears the flag" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-A * 100 + EN-FOX-FLAGS(WS-FOX)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 64 TO EN-FOX-FLAGS(WS-FOX)
     CALL "M44-FOX-IDLE" USING WS-FOX WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§x1 8.7 Fox faceplant: a faceplanted fox stands still in the idle step" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-FOX-FLAGS(WS-FOX) EN-FOX-FP(WS-FOX)
     MOVE 32 TO EN-FOX-FLAGS(WS-FOX)
     CALL "FOX-TICK" USING WS-FOX WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§4 Fox sleep: a sleeping fox stands still in its tick" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-FOX-FLAGS(WS-FOX)
     MOVE 0 TO EN-FOE(WS-FOX) EN-FOE-ID(WS-FOX)
     CALL "ENTITY-REMOVE" USING WS-CHICKEN
     MOVE 1000 TO EN-FOX-SLP(WS-FOX)

*>   Berries: a bush of age 3 three blocks away; the fox walks to it, waits 40 ticks, picks: age 1, berries in the hand and popped.
     MOVE "minecraft:sweet_berry_bush" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STATE = FUNCTION NUMVAL(WS-STATE-TEXT)
     MOVE "3" TO WS-TEXT
     CALL "BLOCK-STATE-PROP" USING WS-MODE-SET WS-STATE WS-PROP WS-TEXT WS-NEW
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(WS-FOX)) + 3
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(WS-FOX))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(WS-FOX))
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-NEW
     MOVE 0 TO EN-FOX-BCD(WS-FOX) EN-FOX-BON(WS-FOX) EN-FOX-HELD(WS-FOX)
     CALL "M44-FOX-BERRIES" USING WS-FOX WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§4 Fox berries: the fox finds the bush within 12 blocks and walks to it" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-FOX-BON(WS-FOX) = 1 AND EN-FOX-BX(WS-FOX) = WS-BX AND WS-WALK = 1 AND WS-HX > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-X(WS-FOX) = WS-BX + 0.5
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 39
         CALL "M44-FOX-BERRIES" USING WS-FOX WS-HX WS-HZ WS-WALK
     END-PERFORM
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "BLOCK-STATE-PROP" USING WS-MODE-READ WS-STATE WS-PROP WS-TEXT WS-RESULT
     MOVE "acceptance US15 44§4 Fox berries: after 39 ticks at the bush it is not picked yet (age 3)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION NUMVAL(WS-TEXT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "M44-FOX-BERRIES" USING WS-FOX WS-HX WS-HZ WS-WALK
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "BLOCK-STATE-PROP" USING WS-MODE-READ WS-STATE WS-PROP WS-TEXT WS-RESULT
     MOVE "acceptance US15 44§4 Fox berries: the 40th tick picks the bush back to age 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION NUMVAL(WS-TEXT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44§4 Fox berries: the empty hand holds a sweet berry" TO TL-CASE
     MOVE "minecraft:sweet_berries" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO TL-EXPECTED-N
     MOVE EN-FOX-HELD(WS-FOX) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM(WS-I) = WS-ITEM AND EN-ITEM-COUNT(WS-I) > 0
             ADD EN-ITEM-COUNT(WS-I) TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44§4 Fox berries: the remaining berries are popped (1 or 2 of the 2 or 3 with age 3)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-N >= 1 AND WS-N <= 2
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-FOX-BCD(WS-FOX)
     CALL "M44-FOX-BERRIES" USING WS-FOX WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§4 Fox berries: a bush of age 1 is no target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FOX-BON(WS-FOX) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A bush that is gone while the fox walks to it drops the target.
     MOVE 1 TO EN-FOX-BON(WS-FOX)
     MOVE WS-BX TO EN-FOX-BX(WS-FOX)
     CALL "M44-FOX-BERRIES" USING WS-FOX WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§4 Fox berries: a bush that is no longer ripe drops the target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FOX-BON(WS-FOX) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1000 TO EN-FOX-BCD(WS-FOX)

*>   Item search: an empty hand takes a stack of 3 two blocks away (one in the hand, two dropped again).
     MOVE 0 TO EN-FOX-HELD(WS-FOX)
     MOVE "minecraft:wheat" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     COMPUTE WS-X = EN-X(WS-FOX) - 3
     COMPUTE WS-Y = EN-Y(WS-FOX)
     MOVE EN-Z(WS-FOX) TO WS-Z
     CALL "IP-AT-LOCATION" USING WS-DIM WS-X WS-Y WS-Z WS-OFFSET WS-ITEM WS-THREE WS-PATCH WS-ROWI
     MOVE 0 TO EN-DELAY(WS-ROWI)
     MOVE 0 TO WS-WALK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400 OR WS-WALK = 1
         ADD 1 TO CW-TIME
         CALL "M44-FOX-ITEMS" USING WS-FOX WS-HX WS-HZ WS-WALK
     END-PERFORM
     MOVE "acceptance US15 44§4 Fox items: within 400 ticks the 1 in 10 roll starts the walk toward the item (0.36)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-WALK = 1 AND WS-HX < -0.35 AND WS-HX > -0.37
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The item it walks to stays its target when it is out of the box (an item beyond 8 blocks is still walked to).
     MOVE EN-X(WS-ROWI) TO WS-X
     COMPUTE EN-X(WS-ROWI) = EN-X(WS-FOX) - 20
     CALL "M44-FOX-ITEMS" USING WS-FOX WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§4 Fox items: the item it walks to stays its target when it is out of the box" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-WALK = 1 AND EN-FOX-ITEM(WS-FOX) = EN-ID(WS-ROWI)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-X(WS-ROWI) = EN-X(WS-FOX) + 0.5
     MOVE EN-ID(WS-ROWI) TO WS-N
     CALL "M44-FOX-ITEMS" USING WS-FOX WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§4 Fox items: within 1 block the fox takes one item into its hand" TO TL-CASE
     MOVE WS-ITEM TO TL-EXPECTED-N
     MOVE EN-FOX-HELD(WS-FOX) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-A
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM(WS-I) = WS-ITEM AND EN-ITEM-COUNT(WS-I) > 0
             ADD EN-ITEM-COUNT(WS-I) TO WS-A
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44§4 Fox items: the other two of the stack are dropped again" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-A TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "M44-FOX-ITEMS" USING WS-FOX WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 44§4 Fox items: a full hand searches no more" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WALK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-44-FOXMORE.
 COPY CORETEST.
 COPY MOBSPTEST.
