 *> Acceptance test, the ravager stun trigger (docs/protocol/20 section 13.6, 17 section 3.6; lane 002-lane-mobsb7, T9510): a mob's melee hit is blocked by a raised shield held towards it
*> (no damage), and a ravager whose hit is blocked with RoarTick 0 is stunned for 40 ticks with probability 0.5, else it throws the blocker back; during its roar nothing happens.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-RAVAGER-SHIELD.
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
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-RTYPE               BINARY-LONG.
 01 WS-ZTYPE               BINARY-LONG.
 01 WS-SHIELD              BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-ZZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-DAMAGE              BINARY-LONG VALUE 12.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-STUNNED             BINARY-LONG.
 01 WS-HAND                BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 2 TO BW-DIFFICULTY
     MOVE "minecraft:ravager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-RTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:shield" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-SHIELD WS-ITEM-ROW WS-STATUS
     MOVE 0 TO PL-HELD(WS-PLAYER)
     MOVE WS-SHIELD TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 0 TO PL-YAW(WS-PLAYER)
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     COMPUTE WS-ZZ = PL-Z(WS-PLAYER) + 2
     CALL "MOB-SPAWN" USING WS-DIM WS-RTYPE WS-X WS-Y WS-ZZ WS-YAW WS-R
     CALL "MOB-SPAWN" USING WS-DIM WS-ZTYPE WS-X WS-Y WS-ZZ WS-YAW WS-Z
*>   Shield down: the hit lands.
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     CALL "HEALTH-MOB-HIT" USING WS-PLAYER WS-DAMAGE WS-Z
     MOVE "acceptance US15 17§3.6 without a raised shield a zombie's hit does damage" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-HEALTH(WS-PLAYER) < 20
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Shield up for 10 ticks: blocked.
     CALL "COMBAT-BLOCK-RAISE" USING WS-PLAYER WS-HAND
     ADD 10 TO CW-TICKS
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     CALL "HEALTH-MOB-HIT" USING WS-PLAYER WS-DAMAGE WS-Z
     MOVE "acceptance US15 17§3.6 a raised shield towards the zombie blocks its hit" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE PL-HEALTH(WS-PLAYER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "EVK-RV-FIND" USING EN-ID(WS-Z) WS-ZERO WS-SLOT
     MOVE "acceptance US15 20§13.6 a zombie has no ravager state" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SLOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A ravager's blocked hits stun it in about half of the cases (RoarTick 0).
     MOVE 0 TO WS-STUNNED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60 OR WS-STUNNED = 1
         MOVE 20 TO PL-HEALTH(WS-PLAYER)
         MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
         CALL "HEALTH-MOB-HIT" USING WS-PLAYER WS-DAMAGE WS-R
         CALL "EVK-RV-FIND" USING EN-ID(WS-R) WS-ONE WS-SLOT
         IF RV-STUN(WS-SLOT) = 40
             MOVE 1 TO WS-STUNNED
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§13.6 a ravager whose hit is blocked is stunned for 40 ticks (within 60 hits)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-STUNNED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 17§3.6 and the hit did no damage" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE PL-HEALTH(WS-PLAYER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   During the roar nothing happens.
     MOVE 0 TO RV-STUN(WS-SLOT)
     MOVE 5 TO RV-ROAR(WS-SLOT)
     MOVE 0 TO WS-STUNNED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
         CALL "HEALTH-MOB-HIT" USING WS-PLAYER WS-DAMAGE WS-R
         IF RV-STUN(WS-SLOT) > 0
             MOVE 1 TO WS-STUNNED
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§13.6 with RoarTick above 0 a blocked hit does not stun" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STUNNED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US15-RAVAGER-SHIELD.

 COPY CORETEST.
 COPY MOBSPTEST.
