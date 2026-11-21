*> Acceptance test (002-lane-p49b; docs/protocol/20 section 16): the breeze's table row and its shoot behaviour. Entity breeze: max health 30, movement speed 0.63, attack
*> damage 3 (not used: it has no melee goal), follow range 24, experience 10, a monster with no natural spawn rule here. Shoot: starts when it stands on the ground with
*> an attack target within 16 blocks (squared distance below 256) after a long jump armed it (p49u: test_mob_20_16_6); inhale 15 ticks, then it fires one breeze wind charge (speed 0.7 along the line from its firing point to the
*> target), recovery 4 ticks, cooldown 10 ticks. This test counts one tick as: the start tick, 15 ticks of inhale (the charge appears on the 15th tick after the start tick), 4 of recovery, 10 of
*> cooldown, so the second charge appears 30 ticks after the first. Not here: spread (the formula `Projectile.shoot` is not in the document), flight and explosion of the
*> charge (21 section 8.18 reads only the explosion), long jump, slide.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-16.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-CHARGE-TYPE         BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 6.
 01 WS-INDEX               BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 24.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-SHOTS               BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-SECOND              BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-CHARGE              BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-FIRST-ROW           BINARY-LONG VALUE 0.
 01 WS-HEALTH              FLOAT-SHORT.
 01 WS-MOB2                BINARY-LONG.
 01 WS-CHARGE2             BINARY-LONG.
 01 WS-POWER0              BINARY-LONG VALUE 0.
 01 WS-DIR1                FLOAT-LONG VALUE 1.
 01 WS-DIR2                FLOAT-LONG VALUE 0.5.
 01 WS-DIR3                FLOAT-LONG VALUE 0.25.
 01 WS-NOBODY              BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:breeze" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-TYPE WS-INDEX
     MOVE "acceptance US15 minecraft:breeze is a standard mob row" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-INDEX > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-INDEX = 0
         STOP RUN
     END-IF
     MOVE "acceptance US15 20§16 Breeze health, attack, follow, xp, kind, spawn" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 30 * 100000000 + 3 * 1000000 + 24 * 10000 + 10 * 100 + 10
     COMPUTE TL-OBSERVED-N = SM-HEALTH(WS-INDEX) * 100000000 + SM-ATTACK(WS-INDEX) * 1000000 + SM-FOLLOW(WS-INDEX) * 10000
         + SM-XP(WS-INDEX) * 100 + SM-KIND(WS-INDEX) * 10 + SM-SPAWN(WS-INDEX)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§16 Breeze speed 0.63 (squared / 0.454)" TO TL-CASE
     MOVE 874 TO TL-EXPECTED-N
     MOVE SM-WALK-MILLI(WS-INDEX) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "PROJ-TYPE" USING WS-KIND WS-CHARGE-TYPE
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 12
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 12
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     COMPUTE WS-X0 = WS-X - 8
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     MOVE 0 TO WS-SHOTS WS-FIRST WS-SECOND WS-SEEN WS-CHARGE WS-START
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 140
         IF PL-HURT-COOLDOWN(WS-PLAYER) > 0
             SUBTRACT 1 FROM PL-HURT-COOLDOWN(WS-PLAYER)
         END-IF
         CALL "MOB-STEP" USING WS-MOB
         IF WS-START = 0 AND EN-DRAW(WS-MOB) = 1
             MOVE WS-I TO WS-START
         END-IF
         MOVE 0 TO WS-COUNT
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-CHARGE-TYPE
                 ADD 1 TO WS-COUNT
                 MOVE WS-E TO WS-CHARGE
             END-IF
         END-PERFORM
         IF WS-COUNT > WS-SEEN
             MOVE WS-COUNT TO WS-SEEN
             ADD 1 TO WS-SHOTS
             IF WS-SHOTS = 1
                 MOVE WS-I TO WS-FIRST
                 MOVE WS-CHARGE TO WS-FIRST-ROW
                 COMPUTE WS-SPEED = FUNCTION SQRT(EN-VX(WS-CHARGE) ** 2 + EN-VY(WS-CHARGE) ** 2 + EN-VZ(WS-CHARGE) ** 2)
                 COMPUTE WS-MILLI ROUNDED = WS-SPEED * 1000
             ELSE
                 MOVE WS-I TO WS-SECOND
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§16 Breeze fires its first charge 15 ticks after the start tick" TO TL-CASE
     MOVE 15 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-FIRST - WS-START
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§16 Breeze charge speed about 0.7 (0.7 x |unit aim + spread|, within 0.64 to 0.77)" TO TL-CASE
     MOVE 700 TO TL-EXPECTED-N
     MOVE WS-MILLI TO TL-OBSERVED-N
     IF WS-MILLI >= 640 AND WS-MILLI <= 770
         MOVE 700 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§16.1 Breeze second charge needs another long jump: it comes later than the 30 ticks of recovery and cooldown" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SECOND > WS-FIRST + 30
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The charge flies straight at the player and hurts it for 1.0 (17 section 3.15); the charge is then removed.
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HEALTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40 OR EN-USED(WS-FIRST-ROW) = 0
         CALL "PROJ-STEP" USING WS-FIRST-ROW
     END-PERFORM
     MOVE "acceptance US15 20§16 Breeze charge hits the player and is removed" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-USED(WS-FIRST-ROW) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§16 Breeze charge damage is 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-HEALTH - PL-HEALTH(WS-PLAYER)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A charge in a chunk that is not loaded is removed by the projectile tick; the others are stepped.
     CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-DIR1 WS-DIR2 WS-DIR3 WS-POWER0 WS-NOBODY WS-CHARGE2
     COMPUTE EN-X(WS-CHARGE2) = 100000
     CALL "PROJECTILES-TICK"
     MOVE "acceptance US15 20§16 Breeze charge in an unloaded chunk is removed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-CHARGE2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   An inhale breaks off when the target leaves the 16-block range.
     COMPUTE WS-X0 = WS-X - 6
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5 OR EN-DRAW(WS-MOB2) = 1
         CALL "MOB-STEP" USING WS-MOB2
     END-PERFORM
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "MOB-STEP" USING WS-MOB2
     MOVE "acceptance US15 20§16 Breeze stops inhaling when it loses its target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-DRAW(WS-MOB2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-20-16.
 COPY CORETEST.
 COPY MOBSPTEST.
