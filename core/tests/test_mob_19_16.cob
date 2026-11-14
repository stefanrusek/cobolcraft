*> Implementation test (002-lane-mobsfull-h20; docs/protocol/19-mobs-land-friendly-and-neutral.md section 16): the bee without a hive. It is neutral (SM-NEUTRAL 5, follow range 16, it does not
*> flee when hit); a hit by a player angers it and every bee within 16 blocks, it flies at the player and stings once (2 damage, Poison 10 s on Normal, 18 s on Hard, none on Easy;
*> nothing on Peaceful); after the sting it is stung (metadata 18 bit 4), calm, and dies by the sting countdown (every 5 ticks with chance 1 / clamp(1200 - ticks, 1, 1200)); an angry
*> bee within 2 blocks rolls (bit 2); in water for more than 20 ticks it takes drowning damage; flowers are its breeding food (M188-FOOD, M188-BREEDS).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-16.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY EFFECTS.
 COPY STDMOBS.
 COPY RULES.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-BEE                 BINARY-LONG.
 01 WS-BEE2                BINARY-LONG.
 01 WS-BEE3                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-DAMAGE              BINARY-LONG VALUE 1.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-WOOL                BINARY-LONG.
 01 WS-NEEDED              BINARY-LONG.
 01 WS-SPECIES             PIC X(24).
 01 WS-ITEM                PIC X(24).
 01 WS-FOUND               BINARY-LONG.
 01 WS-SECONDS             BINARY-LONG.
 01 WS-LOVE                BINARY-LONG.
 01 WS-TAME                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-HEALTH0             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 24.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 24.5
     MOVE PL-X(WS-PLAYER) TO WS-PX
     MOVE PL-Z(WS-PLAYER) TO WS-PZ
     COMPUTE WS-Y = WS-FLOOR + 1
     MOVE 6000 TO CW-TIME
     MOVE 2 TO BW-DIFFICULTY
     MOVE "minecraft:bee" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-TYPE WS-M
     MOVE "N" TO TL-MODE

     MOVE "acceptance US15 19§16 Bee: neutral 5, follow range 16, no panic when hit" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 5 * 10000 + 16 * 10
     COMPUTE TL-OBSERVED-N = SM-NEUTRAL(WS-M) * 10000 + SM-FOLLOW(WS-M) * 10 + SM-PANIC-MILLI(WS-M)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A hit by a player: anger, target, no flight, the other bee in range alerted, the far one not.
     COMPUTE WS-X = WS-PX + 3
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-BEE
     COMPUTE WS-X = WS-PX + 6
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-BEE2
     COMPUTE WS-X = WS-PX + 20
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-BEE3
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     MOVE CAUSE-PLAYER TO WS-CAUSE
     CALL "HEALTH-MOB-DAMAGE" USING WS-BEE WS-DAMAGE WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 19§16 Bee: a hit by a player angers it at that player" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-ANGER(WS-BEE) > 0
         MOVE EN-TARGET(WS-BEE) TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§16 Bee: a hit bee does not flee" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FLEE(WS-BEE) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§16 Bee: a bee within 16 blocks is angered too" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-BEE2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§16 Bee: a bee 20 blocks away is not" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-BEE3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-BEE2
     CALL "ENTITY-REMOVE" USING WS-BEE3

*>   The angry bee flies at the player and stings once.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200 OR EN-BEE-STUNG(WS-BEE) = 1
         MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
         CALL "MOB-STEP" USING WS-BEE
     END-PERFORM
     MOVE "acceptance US15 19§16 Bee: it stings the player" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-BEE-STUNG(WS-BEE) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§16 Bee: the sting does 2 damage" TO TL-CASE
     MOVE 18 TO TL-EXPECTED-N
     MOVE PL-HEALTH(WS-PLAYER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§16 Bee: Poison for 10 s on Normal" TO TL-CASE
     MOVE 200 TO TL-EXPECTED-N
     MOVE EF-DURATION(WS-PLAYER, 19) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§16 Bee: a stung bee is calm" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-ANGER(WS-BEE) TO TL-OBSERVED-N
     ADD EN-TARGET(WS-BEE) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-DATA-VALUES" USING WS-BEE WS-BABY WS-WOOL WS-NEEDED
     MOVE "acceptance US15 19§16 Bee: the flags byte of a stung bee is 4 (metadata 18)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 4 * 10 + 1
     COMPUTE TL-OBSERVED-N = WS-WOOL * 10 + WS-NEEDED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A stung bee stays stung and does not sting again; it dies when the countdown ends.
     MOVE 10 TO EN-HEALTH(WS-BEE)
     MOVE 0 TO EN-BEE-T(WS-BEE)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         CALL "MOB-STEP" USING WS-BEE
     END-PERFORM
     MOVE "acceptance US15 19§16 Bee: 5 ticks after the sting the countdown is 5 and the bee lives" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 5 * 100 + 10
     COMPUTE TL-OBSERVED-N = EN-BEE-T(WS-BEE) * 100 + EN-HEALTH(WS-BEE)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1195 TO EN-BEE-T(WS-BEE)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         CALL "MOB-STEP" USING WS-BEE
     END-PERFORM
     MOVE "acceptance US15 19§16 Bee: at 1199 ticks it still lives" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-BEE) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-STEP" USING WS-BEE
     MOVE "acceptance US15 19§16 Bee: at 1200 ticks the chance is 1 and it dies" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-BEE) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Easy: the sting has no poison; Hard: 18 s; Peaceful: no sting.
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 3
         IF WS-I NOT = 2
             MOVE WS-I TO BW-DIFFICULTY
             COMPUTE WS-X = WS-PX + 1
             CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-BEE2
             MOVE 20 TO PL-HEALTH(WS-PLAYER)
             MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER) EF-ON(WS-PLAYER, 19) EF-DURATION(WS-PLAYER, 19)
             MOVE 200 TO EN-ANGER(WS-BEE2)
             MOVE WS-PLAYER TO EN-TARGET(WS-BEE2)
             MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-BEE2)
             CALL "MOB-STEP" USING WS-BEE2
             EVALUATE WS-I
                 WHEN 0
                     MOVE "acceptance US15 19§16 Bee: no sting on Peaceful, but it rolls within 2 blocks" TO TL-CASE
                     COMPUTE TL-EXPECTED-N = 20 * 10 + 1
                     COMPUTE TL-OBSERVED-N = PL-HEALTH(WS-PLAYER) * 10 + EN-BEE-ROLL(WS-BEE2)
                 WHEN 1
                     MOVE "acceptance US15 19§16 Bee: Easy sting 2 damage and no poison" TO TL-CASE
                     COMPUTE TL-EXPECTED-N = 18 * 1000 + 0
                     COMPUTE TL-OBSERVED-N = PL-HEALTH(WS-PLAYER) * 1000 + EF-DURATION(WS-PLAYER, 19)
                 WHEN OTHER
                     MOVE "acceptance US15 19§16 Bee: Hard sting 2 damage and Poison 18 s" TO TL-CASE
                     COMPUTE TL-EXPECTED-N = 18 * 1000 + 360
                     COMPUTE TL-OBSERVED-N = PL-HEALTH(WS-PLAYER) * 1000 + EF-DURATION(WS-PLAYER, 19)
             END-EVALUATE
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
             IF WS-I = 0
                 CALL "MOB-DATA-VALUES" USING WS-BEE2 WS-BABY WS-WOOL WS-NEEDED
                 MOVE "acceptance US15 19§16 Bee: the rolling flag is bit 2" TO TL-CASE
                 MOVE 2 TO TL-EXPECTED-N
                 MOVE WS-WOOL TO TL-OBSERVED-N
                 CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>               Beyond 2 blocks it stops rolling; a bee without anger stops too.
                 COMPUTE EN-X(WS-BEE2) = WS-PX + 9
                 CALL "MOB-STEP" USING WS-BEE2
                 MOVE "acceptance US15 19§16 Bee: farther than 2 blocks it does not roll" TO TL-CASE
                 MOVE 0 TO TL-EXPECTED-N
                 MOVE EN-BEE-ROLL(WS-BEE2) TO TL-OBSERVED-N
                 CALL "TEST-ASSERT" USING TESTLIB-ASSERT
             END-IF
             CALL "ENTITY-REMOVE" USING WS-BEE2
         END-IF
     END-PERFORM
     MOVE 2 TO BW-DIFFICULTY

*>   Water: more than 20 ticks in water, then drowning damage.
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     PERFORM VARYING WS-WX FROM 0 BY 1 UNTIL WS-WX > 40
         PERFORM VARYING WS-WZ FROM 0 BY 1 UNTIL WS-WZ > 40
             COMPUTE WS-WY = WS-X0 + 4 + WS-WX
             COMPUTE WS-I = WS-Z0 + 4 + WS-WZ
             COMPUTE WS-DAMAGE = WS-FLOOR + 1
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WY WS-DAMAGE WS-I WS-STATE
             COMPUTE WS-DAMAGE = WS-FLOOR + 2
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WY WS-DAMAGE WS-I WS-STATE
         END-PERFORM
     END-PERFORM
     COMPUTE WS-X = WS-X0 + 24.5
     COMPUTE WS-Z = WS-Z0 + 24.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-BEE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         COMPUTE EN-Y(WS-BEE) = WS-FLOOR + 1.5
         CALL "MOB-STEP" USING WS-BEE
     END-PERFORM
     MOVE "acceptance US15 19§16 Bee: 20 ticks in water do not hurt it" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 20 * 100 + 10
     COMPUTE TL-OBSERVED-N = EN-BEE-WET(WS-BEE) * 100 + EN-HEALTH(WS-BEE)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         COMPUTE EN-Y(WS-BEE) = WS-FLOOR + 1.5
         CALL "MOB-STEP" USING WS-BEE
     END-PERFORM
     MOVE "acceptance US15 19§16 Bee: beyond 20 ticks in water it drowns by 1" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-BEE) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-X(WS-BEE) = WS-PX + 2
     COMPUTE EN-Z(WS-BEE) = WS-PZ + 2
     COMPUTE EN-Y(WS-BEE) = WS-FLOOR + 1
     CALL "ENTITY-REMOVE" USING WS-BEE

*>   Flowers are the breeding food, nothing else.
     MOVE "bee" TO WS-SPECIES
     MOVE "poppy" TO WS-ITEM
     CALL "M188-FOOD" USING WS-SPECIES WS-ITEM WS-FOUND WS-SECONDS WS-LOVE WS-TAME
     MOVE "acceptance US15 19§16 Bee: a poppy is its food" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "cactus_flower" TO WS-ITEM
     CALL "M188-FOOD" USING WS-SPECIES WS-ITEM WS-FOUND WS-SECONDS WS-LOVE WS-TAME
     MOVE "acceptance US15 19§16 Bee: so is a cactus flower, and it brings love" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-FOUND * 10 + WS-LOVE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "stone" TO WS-ITEM
     CALL "M188-FOOD" USING WS-SPECIES WS-ITEM WS-FOUND WS-SECONDS WS-LOVE WS-TAME
     MOVE "acceptance US15 19§16 Bee: stone is not" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "M188-BREEDS" USING WS-SPECIES WS-OK
     MOVE "acceptance US15 19§16 Bee: a bee can mate" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-19-16.
 COPY CORETEST.
 COPY MOBSPTEST.
