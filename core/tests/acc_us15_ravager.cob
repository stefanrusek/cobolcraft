*> Acceptance test, the ravager stun, roar and attack timers (docs/protocol/20 section 13.6; lane 002-lane-mobsb5, T8909): a stun lasts 40 ticks, then a 20 tick roar whose blast comes at
*> countdown 10: non-ravager living entities within 4 blocks, non-illagers take 6, non-players are thrown by 4 / distance squared, the ravager stands still while stunned, roaring
*> or within 10 ticks of a hit.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-RAVAGER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY EVKSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-RTYPE               BINARY-LONG.
 01 WS-ZTYPE               BINARY-LONG.
 01 WS-ITYPE               BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-FLAG                BINARY-LONG.
 01 WS-H0                  BINARY-LONG.
 01 WS-HP                  FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:ravager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-RTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:vindicator" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ITYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X0
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z0
     MOVE 2 TO BW-DIFFICULTY
     COMPUTE WS-X = WS-X0 + 30
     CALL "MOB-SPAWN" USING WS-DIM WS-RTYPE WS-X WS-Y WS-Z0 WS-YAW WS-R
     CALL "RAVAGER-STEP" USING WS-R WS-FLAG
     MOVE "acceptance US15 20§13.6 a calm ravager moves" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A hit starts the 10 tick attack timer, during which it stands still.
     CALL "RAVAGER-ATTACKED" USING WS-R
     CALL "RAVAGER-STEP" USING WS-R WS-FLAG
     MOVE "acceptance US15 20§13.6 10 ticks after a hit it is immobile" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 9 TIMES
         CALL "RAVAGER-STEP" USING WS-R WS-FLAG
     END-PERFORM
     MOVE "acceptance US15 20§13.6 then it moves again" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Victims around the ravager: a zombie 2 blocks east, a vindicator 3 blocks west, another ravager 1 block north, a zombie 6 blocks away, the player 2 blocks south.
     MOVE PL-X(WS-PLAYER) TO WS-X0
     MOVE PL-Z(WS-PLAYER) TO WS-Z0
     MOVE EN-X(WS-R) TO WS-X
     MOVE EN-Z(WS-R) TO WS-Z0
     COMPUTE WS-X0 = WS-X + 2
     CALL "MOB-SPAWN" USING WS-DIM WS-ZTYPE WS-X0 WS-Y WS-Z0 WS-YAW WS-Z
     COMPUTE WS-X0 = WS-X - 3
     CALL "MOB-SPAWN" USING WS-DIM WS-ITYPE WS-X0 WS-Y WS-Z0 WS-YAW WS-I
     MOVE WS-X TO WS-X0
     COMPUTE WS-Z0 = EN-Z(WS-R) - 1
     CALL "MOB-SPAWN" USING WS-DIM WS-RTYPE WS-X0 WS-Y WS-Z0 WS-YAW WS-R2
     MOVE EN-HEALTH(WS-Z) TO WS-H0
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-R)
     COMPUTE PL-Z(WS-PLAYER) = EN-Z(WS-R) + 2
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE EN-Y(WS-R) TO PL-Y(WS-PLAYER)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     MOVE 0 TO EN-VX(WS-Z) EN-VX(WS-I)
     CALL "RAVAGER-STUN" USING WS-R
     CALL "EVK-RV-FIND" USING EN-ID(WS-R) WS-NO WS-SLOT
     MOVE "acceptance US15 20§13.6 the stun lasts 40 ticks" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     MOVE RV-STUN(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 39 TIMES
         CALL "RAVAGER-STEP" USING WS-R WS-FLAG
     END-PERFORM
     MOVE "acceptance US15 20§13.6 stunned it stands still" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "RAVAGER-STEP" USING WS-R WS-FLAG
     MOVE "acceptance US15 20§13.6 when the stun ends the roar countdown is 20" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE RV-ROAR(WS-SLOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 9 TIMES
         CALL "RAVAGER-STEP" USING WS-R WS-FLAG
     END-PERFORM
     MOVE "acceptance US15 20§13.6 before countdown 10 nobody is hurt" TO TL-CASE
     MOVE WS-H0 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-Z) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "RAVAGER-STEP" USING WS-R WS-FLAG
     MOVE "acceptance US15 20§13.6 the roar hurts a zombie for 6" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-H0 - EN-HEALTH(WS-Z)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§13.6 and throws it east by 4 / 2 = 2 (thousandths)" TO TL-CASE
     MOVE 2000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VX(WS-Z) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§13.6 an illager is thrown (west, 4 / 3) but not hurt" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-VX(WS-I) < -1.3 AND EN-VX(WS-I) > -1.4 AND EN-HEALTH(WS-I) = 24
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§13.6 another ravager is untouched" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-R2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§13.6 the player takes 6 on Normal" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HP
     COMPUTE TL-OBSERVED-N ROUNDED = WS-HP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The remaining countdown keeps it still until 0.
     MOVE "acceptance US15 20§13.6 still roaring: immobile" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 10 TIMES
         CALL "RAVAGER-STEP" USING WS-R WS-FLAG
     END-PERFORM
     MOVE "acceptance US15 20§13.6 after the roar it moves again" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US15-RAVAGER.

 COPY CORETEST.
 COPY MOBSPTEST.
