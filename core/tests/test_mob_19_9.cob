*> Implementation test (lane p49v; docs/protocol/19-mobs-land-friendly-and-neutral.md section 9 Polar bear, 44-residual-mob-questions-4-land-animals.md section 8): the polar bear is neutral
*> (SM-NEUTRAL 7, follow range 20, attack 6): a hit by a player angers an adult for 400 to 779 ticks and alerts the adult polar bears around it (a hurt baby alerts them and stays calm and flees; an
*> adult hit by a player does not panic); an adult with a baby polar bear within the box inflated by (8, 4, 8) takes a visible player within half its follow range as its target; the standing flag
*> (metadata 18) rises in the last 10 ticks of the attack cooldown while the target is in the warning band and falls when the bear bites or the target is far.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY RULES.
 COPY PROTO REPLACING LEADING ==PB-== BY ==TP-==.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
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
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-DAMAGE              BINARY-LONG VALUE 1.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-WOOL                BINARY-LONG.
 01 WS-NEEDED              BINARY-LONG.
 01 WS-NEAR                BINARY-LONG.
 01 WS-REACHED             BINARY-LONG.
 01 WS-COOLDOWN            BINARY-LONG.
 01 WS-STANDING            BINARY-LONG.
 01 WS-WARN                BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-GUARDS              BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-EXPECT-LEN          BINARY-LONG.
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
     MOVE "minecraft:polar_bear" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-TYPE WS-M
     MOVE "N" TO TL-MODE

     MOVE "acceptance US15 19§9 Polar bear: neutral 7, follow range 20, attack 6, health 30" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 7 * 1000000 + 20 * 10000 + 6 * 100 + 30
     COMPUTE TL-OBSERVED-N = SM-NEUTRAL(WS-M) * 1000000 + SM-FOLLOW(WS-M) * 10000 + SM-ATTACK(WS-M) * 100 + SM-HEALTH(WS-M)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The standing flag rule, by cases (near: inside the warning band and outside the reach).
     MOVE 0 TO WS-NEAR WS-REACHED
     MOVE 1 TO WS-REACHED
     MOVE 15 TO WS-COOLDOWN
     MOVE 1 TO WS-STANDING
     CALL "POLAR-BEAR-STAND" USING WS-NEAR WS-REACHED WS-COOLDOWN WS-STANDING WS-WARN
     MOVE "acceptance US15 19§9 Polar bear: within reach it is not standing and the cooldown is the attack's" TO TL-CASE
     MOVE 1500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-COOLDOWN * 100 + WS-STANDING * 10 + WS-WARN
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-REACHED
     MOVE 1 TO WS-NEAR
     MOVE 0 TO WS-COOLDOWN
     CALL "POLAR-BEAR-STAND" USING WS-NEAR WS-REACHED WS-COOLDOWN WS-STANDING WS-WARN
     MOVE "acceptance US15 19§9 Polar bear: in the band with the cooldown ready it resets the cooldown to 20 and lies down" TO TL-CASE
     MOVE 2000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-COOLDOWN * 100 + WS-STANDING * 10 + WS-WARN
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 11 TO WS-COOLDOWN
     CALL "POLAR-BEAR-STAND" USING WS-NEAR WS-REACHED WS-COOLDOWN WS-STANDING WS-WARN
     MOVE "acceptance US15 19§9 Polar bear: with 11 ticks left it still lies" TO TL-CASE
     MOVE 1100 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-COOLDOWN * 100 + WS-STANDING * 10 + WS-WARN
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 10 TO WS-COOLDOWN
     CALL "POLAR-BEAR-STAND" USING WS-NEAR WS-REACHED WS-COOLDOWN WS-STANDING WS-WARN
     MOVE "acceptance US15 19§9 Polar bear: with 10 ticks left it stands and the warning sound plays" TO TL-CASE
     MOVE 1011 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-COOLDOWN * 100 + WS-STANDING * 10 + WS-WARN
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-NEAR
     MOVE 7 TO WS-COOLDOWN
     CALL "POLAR-BEAR-STAND" USING WS-NEAR WS-REACHED WS-COOLDOWN WS-STANDING WS-WARN
     MOVE "acceptance US15 19§9 Polar bear: beyond the band it resets the cooldown and lies down" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-COOLDOWN * 100 + WS-STANDING * 10 + WS-WARN
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The box of the cub-defence rule: the adult's box inflated by (8, 4, 8) meets the baby's box.
     MOVE 9.0 TO WS-DX
     MOVE 0 TO WS-DY WS-DZ
     CALL "POLAR-BEAR-GUARDS" USING WS-DX WS-DY WS-DZ WS-GUARDS
     MOVE "acceptance US15 19§9 Polar bear: a baby 9 blocks away on the ground is inside the inflated box" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-GUARDS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9.2 TO WS-DX
     CALL "POLAR-BEAR-GUARDS" USING WS-DX WS-DY WS-DZ WS-GUARDS
     MOVE "acceptance US15 19§9 Polar bear: 9.2 blocks away is outside it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-GUARDS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-DX
     MOVE 5.3 TO WS-DY
     CALL "POLAR-BEAR-GUARDS" USING WS-DX WS-DY WS-DZ WS-GUARDS
     MOVE "acceptance US15 19§9 Polar bear: 5.3 blocks above (4 plus the bear's height 1.4 minus 0.1) is inside" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-GUARDS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5.5 TO WS-DY
     CALL "POLAR-BEAR-GUARDS" USING WS-DX WS-DY WS-DZ WS-GUARDS
     MOVE "acceptance US15 19§9 Polar bear: 5.5 blocks above is outside" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-GUARDS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -4.6 TO WS-DY
     CALL "POLAR-BEAR-GUARDS" USING WS-DX WS-DY WS-DZ WS-GUARDS
     MOVE "acceptance US15 19§9 Polar bear: 4.6 blocks below (4 plus the cub's height 0.7 minus 0.1) is inside" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-GUARDS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -4.8 TO WS-DY
     CALL "POLAR-BEAR-GUARDS" USING WS-DX WS-DY WS-DZ WS-GUARDS
     MOVE "acceptance US15 19§9 Polar bear: 4.8 blocks below is outside" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-GUARDS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   An adult hit by a player: angry for 400 to 779 ticks at that player, no panic; the adults around are alerted, a cub and a far bear are not.
     COMPUTE WS-X = WS-PX + 3
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-A
     COMPUTE WS-X = WS-PX + 6
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-B
     COMPUTE WS-X = WS-PX + 7
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-C
     MOVE -24000 TO EN-MOBAGE(WS-C)
     MOVE 1 TO EN-VARIANT(WS-C)
     COMPUTE WS-X = WS-PX - 22
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-D
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     MOVE CAUSE-PLAYER TO WS-CAUSE
     CALL "HEALTH-MOB-DAMAGE" USING WS-A WS-DAMAGE WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 19§9 Polar bear: a hit by a player angers an adult at that player" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-ANGER(WS-A) > 0
         MOVE EN-TARGET(WS-A) TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§9 Polar bear: the anger lasts 400 to 779 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-ANGER(WS-A) >= 400 AND EN-ANGER(WS-A) <= 779
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§9 Polar bear: an adult hit by a player does not panic (only environmental damage makes it flee)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-FLEE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§9 Polar bear: an adult 3 blocks from the hurt one is alerted" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§9 Polar bear: a cub is not alerted (alertOther alerts only non-baby bears)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-C) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§9 Polar bear: an adult 25 blocks away (beyond the follow range 20) is not alerted" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-D) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-A
     CALL "ENTITY-REMOVE" USING WS-B
     CALL "ENTITY-REMOVE" USING WS-D
     MOVE 0 TO EN-TARGET(WS-C) EN-ANGER(WS-C) EN-FLEE(WS-C)

*>   A hurt cub alerts the adults around it, takes no anger itself and flees.
     COMPUTE WS-X = WS-PX + 9
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-B
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     CALL "HEALTH-MOB-DAMAGE" USING WS-C WS-DAMAGE WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 19§9 Polar bear: a hurt cub alerts the adult near it" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-B) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§9 Polar bear: a hurt cub itself is not angry and has no target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-ANGER(WS-C) + EN-TARGET(WS-C)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§9 Polar bear: a hurt cub panics (any damage makes a baby flee)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-FLEE(WS-C) > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-B

*>   The cub-defence target: an adult with a cub nearby takes a visible player within half its follow range (10 blocks); a cub never does.
     COMPUTE WS-X = WS-PX + 8
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-A
     MOVE 0 TO EN-TARGET(WS-A) EN-ANGER(WS-A)
     COMPUTE EN-X(WS-C) = WS-PX + 12
     MOVE WS-PZ TO EN-Z(WS-C)
     MOVE WS-Y TO EN-Y(WS-C)
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 19§9 Polar bear: an adult 8 blocks from a player with a cub 4 blocks away takes the player as target" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 19§9 Polar bear: that target is an anger of 400 to 779 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-ANGER(WS-A) >= 399 AND EN-ANGER(WS-A) <= 779
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-TARGET(WS-A) EN-ANGER(WS-A)
     COMPUTE EN-X(WS-C) = WS-PX + 40
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 19§9 Polar bear: with the cub 32 blocks away the adult takes no target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-X(WS-C) = WS-PX + 12
     COMPUTE EN-X(WS-A) = WS-PX + 11
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 19§9 Polar bear: a player 11 blocks away (beyond 10) is not taken" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-X(WS-C) = WS-PX + 5
     COMPUTE EN-X(WS-A) = WS-PX + 8
     MOVE 0 TO EN-TARGET(WS-A) EN-ANGER(WS-A)
     CALL "MOB-STEP" USING WS-C
     MOVE "acceptance US15 19§9 Polar bear: a cub never takes a target for its own defence" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-C) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-C

*>   The warning band, in the world: a target 3 blocks away that the bear cannot approach (it is put back each tick) makes it stand in the last 10 ticks of the cooldown.
     COMPUTE EN-X(WS-A) = WS-PX + 3
     MOVE WS-PZ TO EN-Z(WS-A)
     MOVE WS-Y TO EN-Y(WS-A)
     MOVE 600 TO EN-ANGER(WS-A)
     MOVE WS-PLAYER TO EN-TARGET(WS-A)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-A)
     MOVE 0 TO EN-COOLDOWN(WS-A) EN-POLAR-STAND(WS-A) WS-FIRST
     MOVE 0 TO WS-TICKS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         COMPUTE EN-X(WS-A) = WS-PX + 3
         MOVE WS-PZ TO EN-Z(WS-A)
         CALL "MOB-STEP" USING WS-A
         IF EN-POLAR-STAND(WS-A) = 1 AND WS-FIRST = 0
             MOVE WS-I TO WS-FIRST
             MOVE EN-COOLDOWN(WS-A) TO WS-TICKS
         END-IF
     END-PERFORM
     MOVE "acceptance US15 19§9 Polar bear: it stands with 10 ticks of the cooldown left, 11 ticks after the cooldown was set" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 10 * 100 + 11
     COMPUTE TL-OBSERVED-N = WS-TICKS * 100 + WS-FIRST
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Standing is entity data (metadata 18 BOOLEAN): sent only while it is true.
     MOVE 1 TO EN-POLAR-STAND(WS-A)
     CALL "MOB-DATA-VALUES" USING WS-A WS-BABY WS-WOOL WS-NEEDED
     MOVE "acceptance US15 19§9 Polar bear: a standing bear needs entity data" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-NEEDED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-INIT" USING TP-BUFFER WS-CAPACITY
     CALL "MOB-DATA-BUILD" USING WS-A TP-BUFFER
     MOVE 8 TO WS-EXPECT-LEN
     IF EN-ID(WS-A) < 128
         ADD 1 TO WS-EXPECT-LEN
     ELSE
         ADD 2 TO WS-EXPECT-LEN
     END-IF
     MOVE "acceptance US15 19§9 Polar bear: it sends baby, standing 18 (3 bytes) and the end marker" TO TL-CASE
     MOVE WS-EXPECT-LEN TO TL-EXPECTED-N
     MOVE TP-LENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-FREE" USING TP-BUFFER
     MOVE 0 TO EN-POLAR-STAND(WS-A)
     CALL "MOB-DATA-VALUES" USING WS-A WS-BABY WS-WOOL WS-NEEDED
     MOVE "acceptance US15 19§9 Polar bear: a bear on all fours needs none" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-NEEDED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Within reach it bites, and stands no more.
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO EN-COOLDOWN(WS-A)
     MOVE 1 TO EN-POLAR-STAND(WS-A)
     COMPUTE EN-X(WS-A) = WS-PX + 1
     MOVE WS-PZ TO EN-Z(WS-A)
     MOVE 600 TO EN-ANGER(WS-A)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
         COMPUTE EN-X(WS-A) = WS-PX + 1
         MOVE WS-PZ TO EN-Z(WS-A)
         CALL "MOB-STEP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 19§9 Polar bear: within reach it bites the player and lies down" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-HEALTH(WS-PLAYER) < 20 AND EN-POLAR-STAND(WS-A) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-19-9.
 COPY CORETEST.
 COPY MOBSPTEST.
