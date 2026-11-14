*> Implementation test (002-lane-mobsfull-h11; docs/protocol/20 section 7.1 Spider, 18 section 5 LeapAtTargetGoal): the spider leaps at a target 2 to 4 blocks away
*> (squared distance above 4 and below 16) while on the ground, one evaluation in five: the horizontal direction to the target x 0.4 added to 0.2 x the current
*> velocity, the vertical speed 0.4. On Hard a new spider gets, with probability 0.1 x the special multiplier, one effect with no expiry: nextInt(5) 0 or 1 Speed,
*> 2 Strength, 3 Regeneration, 4 Invisibility. Speed makes the walk 1.2 times as fast, Strength adds 3 attack damage, Regeneration heals 1 every 50 ticks; an effect with
*> ticks left counts down (STDMOB-FX-TICK). The jockey skeleton needs a rider, which the core cannot seat (open).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-7-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY XORO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ROLL                BINARY-LONG.
 01 WS-LEAPT               BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-SPECIAL             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ANY                 BINARY-LONG.
 01 WS-SPEEDS              BINARY-LONG.
 01 WS-STRS                BINARY-LONG.
 01 WS-REGENS              BINARY-LONG.
 01 WS-INVIS               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-X0 = WS-X - 3
     MOVE "minecraft:spider" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-TYPE WS-M
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     MOVE WS-PLAYER TO EN-TARGET(WS-MOB)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-MOB)
     MOVE 1 TO EN-ON-GROUND(WS-MOB)
     MOVE 0 TO EN-VX(WS-MOB) EN-VZ(WS-MOB) EN-VY(WS-MOB) WS-ROLL

*>   Leap 3 blocks from the target, on the ground, roll 0.
     CALL "STDMOB-LEAP" USING WS-MOB WS-M WS-ROLL WS-LEAPT
     MOVE "acceptance US15 20§7.1 Spider: 3 blocks from its target on the ground it leaps (roll 0)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-LEAPT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§7.1 Spider: the leap is 0.4 toward the target and 0.4 up" TO TL-CASE
     COMPUTE WS-V ROUNDED = EN-VX(WS-MOB) * 1000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-V * 1000000 + EN-VY(WS-MOB) * 1000 + EN-VZ(WS-MOB) * 100
     COMPUTE TL-EXPECTED-N = 400 * 1000000 + 400
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The current velocity counts 0.2.
     MOVE 1 TO EN-VX(WS-MOB)
     CALL "STDMOB-LEAP" USING WS-MOB WS-M WS-ROLL WS-LEAPT
     MOVE "acceptance US15 20§7.1 Spider: the leap adds 0.2 x the old horizontal velocity (0.4 + 0.2)" TO TL-CASE
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-MOB) * 1000
     MOVE 600 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Not leaping.
     MOVE 1 TO WS-ROLL
     CALL "STDMOB-LEAP" USING WS-MOB WS-M WS-ROLL WS-LEAPT
     MOVE "acceptance US15 20§7.1 Spider: one evaluation in five: roll 1 does not leap" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LEAPT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-ROLL
     MOVE 0 TO EN-ON-GROUND(WS-MOB)
     CALL "STDMOB-LEAP" USING WS-MOB WS-M WS-ROLL WS-LEAPT
     MOVE "acceptance US15 20§7.1 Spider: in the air it does not leap" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LEAPT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO EN-ON-GROUND(WS-MOB)
     COMPUTE EN-X(WS-MOB) = WS-X - 4
     CALL "STDMOB-LEAP" USING WS-MOB WS-M WS-ROLL WS-LEAPT
     MOVE "acceptance US15 20§7.1 Spider: 4 blocks away (squared 16) it does not leap" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LEAPT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-X(WS-MOB) = WS-X - 2
     CALL "STDMOB-LEAP" USING WS-MOB WS-M WS-ROLL WS-LEAPT
     MOVE "acceptance US15 20§7.1 Spider: 2 blocks away (squared 4) it does not leap" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LEAPT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-X(WS-MOB) = WS-X - 2.1
     CALL "STDMOB-LEAP" USING WS-MOB WS-M WS-ROLL WS-LEAPT
     MOVE "acceptance US15 20§7.1 Spider: 2.1 blocks away it leaps" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-LEAPT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Straight below the target: no horizontal part, 0.2 x the old velocity only.
     MOVE WS-X TO EN-X(WS-MOB)
     MOVE WS-Z TO EN-Z(WS-MOB)
     COMPUTE EN-Y(WS-MOB) = WS-Y - 3
     MOVE 1 TO EN-VX(WS-MOB)
     CALL "STDMOB-LEAP" USING WS-MOB WS-M WS-ROLL WS-LEAPT
     MOVE "acceptance US15 20§7.1 Spider: with no horizontal offset the velocity is the raw offset (0)" TO TL-CASE
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-MOB) * 1000
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EN-TARGET(WS-MOB)
     CALL "STDMOB-LEAP" USING WS-MOB WS-M WS-ROLL WS-LEAPT
     MOVE "acceptance US15 20§7.1 Spider: without a target it does not leap" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LEAPT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Hard spawn effect.
     MOVE 1000 TO WS-SPECIAL
     MOVE 2 TO BW-DIFFICULTY
     MOVE 0 TO WS-ANY WS-SPEEDS WS-STRS WS-REGENS WS-INVIS WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         INITIALIZE EN-FX-SPEED(WS-MOB) EN-FX-STRENGTH(WS-MOB) EN-FX-REGEN(WS-MOB) EN-FX-INVIS(WS-MOB)
         CALL "STDMOB-SPIDER-FX" USING XR-STATE WS-MOB WS-SPECIAL
         IF EN-FX-SPEED(WS-MOB) NOT = 0 OR EN-FX-STRENGTH(WS-MOB) NOT = 0 OR EN-FX-REGEN(WS-MOB) NOT = 0
                 OR EN-FX-INVIS(WS-MOB) NOT = 0
             ADD 1 TO WS-ANY
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§7.1 Spider: on Normal no effect" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ANY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO BW-DIFFICULTY
     MOVE 0 TO WS-SPECIAL
     MOVE 0 TO WS-ANY
     MOVE 5 TO WS-SEED
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "STDMOB-SPIDER-FX" USING XR-STATE WS-MOB WS-SPECIAL
     MOVE "acceptance US15 20§7.1 Spider: special multiplier 0 gives no effect even on Hard" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION ABS(EN-FX-SPEED(WS-MOB)) + FUNCTION ABS(EN-FX-STRENGTH(WS-MOB))
         + FUNCTION ABS(EN-FX-REGEN(WS-MOB)) + FUNCTION ABS(EN-FX-INVIS(WS-MOB))
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1000 TO WS-SPECIAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         MOVE 0 TO EN-FX-SPEED(WS-MOB) EN-FX-STRENGTH(WS-MOB) EN-FX-REGEN(WS-MOB) EN-FX-INVIS(WS-MOB)
         CALL "STDMOB-SPIDER-FX" USING XR-STATE WS-MOB WS-SPECIAL
         IF EN-FX-SPEED(WS-MOB) = -1
             ADD 1 TO WS-SPEEDS
         END-IF
         IF EN-FX-STRENGTH(WS-MOB) = -1
             ADD 1 TO WS-STRS
         END-IF
         IF EN-FX-REGEN(WS-MOB) = -1
             ADD 1 TO WS-REGENS
         END-IF
         IF EN-FX-INVIS(WS-MOB) = -1
             ADD 1 TO WS-INVIS
         END-IF
     END-PERFORM
     COMPUTE WS-ANY = WS-SPEEDS + WS-STRS + WS-REGENS + WS-INVIS
     MOVE "acceptance US15 20§7.1 Spider: on Hard at special 1 about one spider in ten gets an effect" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ANY >= 20 AND WS-ANY <= 65
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§7.1 Spider: every kind of effect occurs (Speed twice as often)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SPEEDS > WS-STRS AND WS-STRS > 0 AND WS-REGENS > 0 AND WS-INVIS > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Finalize on Hard keeps the effect fields valid.
     MOVE 3 TO BW-DIFFICULTY
     MOVE 0 TO EN-FX-SPEED(WS-MOB) EN-FX-STRENGTH(WS-MOB) EN-FX-REGEN(WS-MOB) EN-FX-INVIS(WS-MOB)
     MOVE 9 TO WS-SEED
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "STDMOB-FINALIZE" USING XR-STATE WS-MOB
     MOVE "acceptance US15 20§7.1 Spider: finalizing a spider leaves valid effect fields" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF (EN-FX-SPEED(WS-MOB) NOT = 0 AND EN-FX-SPEED(WS-MOB) NOT = -1)
             OR (EN-FX-STRENGTH(WS-MOB) NOT = 0 AND EN-FX-STRENGTH(WS-MOB) NOT = -1)
             OR (EN-FX-REGEN(WS-MOB) NOT = 0 AND EN-FX-REGEN(WS-MOB) NOT = -1)
             OR (EN-FX-INVIS(WS-MOB) NOT = 0 AND EN-FX-INVIS(WS-MOB) NOT = -1)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Effects at work: Strength +3 damage, ticks counting down, Regeneration every 50 ticks.
     MOVE 0 TO EN-FX-SPEED(WS-MOB) EN-FX-STRENGTH(WS-MOB) EN-FX-REGEN(WS-MOB) EN-FX-INVIS(WS-MOB)
     CALL "STDMOB-ATTACK-DAMAGE" USING WS-MOB WS-M WS-DAMAGE
     MOVE "acceptance US15 20§7.1 Spider: attack damage 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-DAMAGE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1 TO EN-FX-STRENGTH(WS-MOB)
     CALL "STDMOB-ATTACK-DAMAGE" USING WS-MOB WS-M WS-DAMAGE
     MOVE "acceptance US15 20§7.1 Spider: with Strength the attack damage is 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-DAMAGE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO EN-FX-SPEED(WS-MOB)
     MOVE -1 TO EN-FX-INVIS(WS-MOB)
     MOVE -1 TO EN-FX-STRENGTH(WS-MOB)
     MOVE 5 TO EN-FX-WATER(WS-MOB)
     MOVE 3 TO EN-FX-FIRE(WS-MOB)
     MOVE 1 TO EN-FX-REGEN(WS-MOB)
     MOVE 10 TO EN-HEALTH(WS-MOB)
     MOVE 100 TO CW-TIME
     CALL "STDMOB-FX-TICK" USING WS-MOB WS-M
     MOVE "acceptance US15 20§7.1 Spider: effects with ticks left count down, -1 stays" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1 * 100000 + 4 * 1000 + 2 * 10 + 1
     COMPUTE TL-OBSERVED-N = EN-FX-SPEED(WS-MOB) * 100000 + EN-FX-WATER(WS-MOB) * 1000 + EN-FX-FIRE(WS-MOB) * 10
         - EN-FX-INVIS(WS-MOB)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§7.1 Spider: Regeneration heals 1 when the time is a multiple of 50" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 101 TO CW-TIME
     MOVE 1 TO EN-FX-REGEN(WS-MOB)
     MOVE 3 TO EN-FX-STRENGTH(WS-MOB) EN-FX-INVIS(WS-MOB)
     CALL "STDMOB-FX-TICK" USING WS-MOB WS-M
     MOVE "acceptance US15 20§7.1 Spider: Regeneration does not heal between" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 100 TO CW-TIME
     MOVE 16 TO EN-HEALTH(WS-MOB)
     MOVE -1 TO EN-FX-REGEN(WS-MOB)
     CALL "STDMOB-FX-TICK" USING WS-MOB WS-M
     MOVE "acceptance US15 20§7.1 Spider: Regeneration does not pass the maximum health 16" TO TL-CASE
     MOVE 16 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB
     STOP RUN.
 END PROGRAM TEST-MOB-20-7-1.
 COPY CORETEST.
 COPY MOBSPTEST.
