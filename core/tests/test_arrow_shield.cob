*> Implementation test (wrap C round 6, T56409; docs/protocol/17 section 3.6, 44-residual-mob-questions-8 sections 7.3 step 9 and 6.3): a raised shield blocks the hit of an arrow that comes from in front
*> of the player (the angle to the arrow's position at most 90 degrees, not a piercing arrow): no damage, the shield wears, and the arrow is deflected with REVERSE and s = 0.2 (the velocity times -0.1,
*> the arrow keeps flying and is not removed). An arrow from behind, a piercing arrow and a player without a raised shield are hurt as before.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ARROW-SHIELD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CTOOLS.
 COPY CITEMS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 20.
 01 WS-FKIND               BINARY-LONG VALUE 2.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG VALUE 0.
 01 WS-VY                  FLOAT-LONG VALUE 0.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-BASE                BINARY-LONG VALUE 2000.
 01 WS-OWNER               BINARY-LONG VALUE 0.
 01 WS-ARROW               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-HEALTH0             FLOAT-LONG.
 01 WS-LOSS                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TICKS               BINARY-LONG VALUE 1.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-ARROW-TYPE          BINARY-LONG.
 01 WS-PICKUP              BINARY-LONG VALUE 0.
 01 WS-ITEMS               BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 COPY CONTENT.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO PL-YAW(WS-PLAYER) PL-PITCH(WS-PLAYER)
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 10
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 10
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     MOVE "minecraft:arrow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ARROW-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:shield" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER)

*>   A raised shield (used for 10 ticks) and an arrow of speed 3 from 3 blocks in front (damage ceil(3 x 2) = 6): blocked, the player keeps his health, the arrow flies back at 0.3 and lives.
     CALL "COMBAT-TS-CHECK" USING WS-PLAYER
     COMPUTE TS-BLOCK-START(WS-PLAYER) = CW-TICKS + 1 - 10
     MOVE 0 TO TS-BLOCK-HAND(WS-PLAYER)
     MOVE -3 TO WS-VZ
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 3
     PERFORM FIRE
     COMPUTE WS-LOSS = FUNCTION INTEGER(WS-HEALTH0 - PL-HEALTH(WS-PLAYER) + 0.5)
     MOVE "implementation 17 3.6 a raised shield blocks the arrow from in front: no damage" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LOSS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 44-8 7.3 step 9 the blocked arrow is not removed" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ARROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 6.3 REVERSE with s 0.2: the velocity is -3 x -0.1 = +0.3 along z" TO TL-CASE
     MOVE 300 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VZ(WS-ARROW) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-TICKS" USING WS-THREE
     COMPUTE WS-LOSS = FUNCTION INTEGER(WS-HEALTH0 - PL-HEALTH(WS-PLAYER) + 0.5)
     MOVE "implementation 44-8 7.3 the deflected arrow does not hit the player again" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LOSS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A piercing arrow is not blocked (17 section 3.6 rule 1): the player takes the 6.
     MOVE -3 TO WS-VZ
     PERFORM FIRE-PIERCING
     COMPUTE WS-LOSS = FUNCTION INTEGER(WS-HEALTH0 - PL-HEALTH(WS-PLAYER) + 0.5)
     MOVE "implementation 17 3.6 a piercing arrow goes through the shield: 6 damage" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE WS-LOSS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   An arrow from behind (the angle is more than 90 degrees) hurts.
     MOVE 3 TO WS-VZ
     COMPUTE WS-Z = PL-Z(WS-PLAYER) - 3
     PERFORM FIRE
     COMPUTE WS-LOSS = FUNCTION INTEGER(WS-HEALTH0 - PL-HEALTH(WS-PLAYER) + 0.5)
     MOVE "implementation 17 3.6 an arrow from behind is not blocked: 6 damage" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE WS-LOSS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A shield that is not raised blocks nothing.
     MOVE 0 TO TS-BLOCK-START(WS-PLAYER)
     MOVE -3 TO WS-VZ
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 3
     PERFORM FIRE
     COMPUTE WS-LOSS = FUNCTION INTEGER(WS-HEALTH0 - PL-HEALTH(WS-PLAYER) + 0.5)
     MOVE "implementation 17 3.6 without a raised shield the arrow from in front hurts: 6 damage" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE WS-LOSS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   An arrow that has nearly stopped (squared speed below 1e-7 after the reverse) is discarded: with pickup mode 1 it first drops its arrow item, with mode 0 nothing.
     COMPUTE TS-BLOCK-START(WS-PLAYER) = CW-TICKS + 1 - 10
     MOVE -0.003 TO WS-VZ
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 0.25
     MOVE 1 TO WS-PICKUP
     PERFORM FIRE
     PERFORM COUNT-ITEMS
     MOVE "implementation 44-8 7.3 step 9 a nearly stopped blocked arrow with pickup 1 is removed and drops its item" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-ITEMS * 10 + EN-USED(WS-ARROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM CLEAR-ITEMS
     COMPUTE TS-BLOCK-START(WS-PLAYER) = CW-TICKS + 1 - 10
     MOVE 0 TO WS-PICKUP
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 0.25
     PERFORM FIRE
     PERFORM COUNT-ITEMS
     MOVE "implementation 44-8 7.3 step 9 a nearly stopped blocked arrow with pickup 0 is removed and drops nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-ITEMS * 10 + EN-USED(WS-ARROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 COUNT-ITEMS.
     MOVE 0 TO WS-ITEMS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM
             ADD EN-ITEM-COUNT(WS-I) TO WS-ITEMS
         END-IF
     END-PERFORM.

 CLEAR-ITEMS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM.

*> An arrow at WS-Z (player's x, 1.0 above his feet) with the velocity WS-VZ, one tick; WS-HEALTH0 is the health before.
 FIRE.
     PERFORM CLEAR-ARROWS
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER) TS-LAST-HURT(WS-PLAYER)
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HEALTH0
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = PL-Y(WS-PLAYER) + 1.0
     CALL "ARROW-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-BASE WS-OWNER WS-ARROW
     MOVE WS-PICKUP TO EN-ARR-PICKUP(WS-ARROW)
     CALL "TEST-TICKS" USING WS-TICKS.

 FIRE-PIERCING.
     PERFORM CLEAR-ARROWS
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER) TS-LAST-HURT(WS-PLAYER)
     MOVE PL-HEALTH(WS-PLAYER) TO WS-HEALTH0
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = PL-Y(WS-PLAYER) + 1.0
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 3
     CALL "ARROW-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-BASE WS-OWNER WS-ARROW
     MOVE 1 TO EN-ARR-PIERCE(WS-ARROW)
     CALL "TEST-TICKS" USING WS-TICKS.

 CLEAR-ARROWS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-ARROW-TYPE
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM.
 END PROGRAM TEST-ARROW-SHIELD.
 COPY CORETEST.
 COPY MOBSPTEST.
