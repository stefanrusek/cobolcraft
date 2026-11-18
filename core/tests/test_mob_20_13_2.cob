*> Acceptance test (002-lane-p49b; docs/protocol/20 section 13.2): the pillager's crossbow goal. A pillager with a target stands to charge when it need not approach (squared
*> distance at most 64 and seeTime at least 5), charges for 25 ticks (CHARGING, state 1), is CHARGED (2) for attackDelay = 20 + nextInt(20) ticks, then READY_TO_ATTACK (3), and on
*> the next tick with a line of sight it shoots an arrow of speed 1.6 (inaccuracy 14 - 4 x difficulty) and is UNCHARGED (0) again. Farther than 8 blocks it approaches and does not charge.
*> This test counts a tick as the goal's tick: the state of EN-DRAW after MOB-STEP. Not here: metadata 17 (charging), the five-slot inventory and loot pickup, the captain's ominous
*> bottle, the patrol spawn rule and the cluster size 1.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-13-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY BRWORLD.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ARROW-TYPE          BINARY-LONG.
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
 01 WS-START               BINARY-LONG.
 01 WS-CHARGED             BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-SHOT                BINARY-LONG.
 01 WS-ARROWS              BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-STATE-AFTER         BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 3 TO BW-DIFFICULTY
     MOVE "N" TO TL-MODE
     MOVE "minecraft:pillager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:arrow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ARROW-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 12
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 12
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND

*>   Far away (20 blocks): it approaches and does not charge.
     COMPUTE WS-X0 = WS-X - 20
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         CALL "MOB-STEP" USING WS-MOB
     END-PERFORM
     MOVE "acceptance US15 20§13.2 Pillager 20 blocks away does not charge" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-DRAW(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§13.2 Pillager 20 blocks away walks toward its target" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "yes" TO TL-EXPECTED
     MOVE "no" TO TL-OBSERVED
     IF EN-X(WS-MOB) > WS-X0
         MOVE "yes" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     CALL "ENTITY-REMOVE" USING WS-MOB

*>   At 6 blocks with a line of sight: charge 25 ticks, delay, shot.
     COMPUTE WS-X0 = WS-X - 6
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     MOVE 0 TO WS-START WS-CHARGED WS-DELAY WS-SHOT WS-SEEN WS-MILLI WS-STATE-AFTER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 160 OR WS-SHOT > 0
         IF PL-HURT-COOLDOWN(WS-PLAYER) > 0
             SUBTRACT 1 FROM PL-HURT-COOLDOWN(WS-PLAYER)
         END-IF
         MOVE WS-X0 TO EN-X(WS-MOB)
         CALL "MOB-STEP" USING WS-MOB
         IF WS-START = 0 AND EN-DRAW(WS-MOB) = 1
             MOVE WS-I TO WS-START
         END-IF
         IF WS-CHARGED = 0 AND EN-DRAW(WS-MOB) = 2
             MOVE WS-I TO WS-CHARGED
             MOVE EN-SHOOT-TIME(WS-MOB) TO WS-DELAY
         END-IF
         MOVE 0 TO WS-ARROWS
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-ARROW-TYPE
                 ADD 1 TO WS-ARROWS
                 MOVE WS-E TO WS-ROW
             END-IF
         END-PERFORM
         IF WS-ARROWS > 0 AND WS-SHOT = 0
             MOVE WS-I TO WS-SHOT
             MOVE EN-DRAW(WS-MOB) TO WS-STATE-AFTER
             COMPUTE WS-SPEED = FUNCTION SQRT(EN-VX(WS-ROW) ** 2 + EN-VY(WS-ROW) ** 2 + EN-VZ(WS-ROW) ** 2)
             COMPUTE WS-MILLI ROUNDED = WS-SPEED * 1000
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§13.2 Pillager charges for 25 ticks" TO TL-CASE
     MOVE 25 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-CHARGED - WS-START
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§13.2 Pillager attackDelay is 20 + nextInt(20)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DELAY >= 20 AND WS-DELAY <= 39
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§13.2 Pillager shoots one tick after the delay ran out" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-DELAY + 1
     COMPUTE TL-OBSERVED-N = WS-SHOT - WS-CHARGED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§13.2 Pillager is UNCHARGED after the shot" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATE-AFTER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§13.2 Pillager arrow speed about 1.6" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MILLI >= 1450 AND WS-MILLI <= 1750
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-20-13-2.
 COPY CORETEST.
 COPY MOBSPTEST.
