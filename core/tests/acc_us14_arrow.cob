*> Acceptance test (US14; docs/protocol/17 section 3.9 arrow entity, damage on hit, Punch, piercing, pickup): what an arrow does after the shot. An arrow of speed 3.0 and base
*> damage 2.0 does ceil(3.0 x 2.0) = 6 to a cow; a critical arrow adds nextInt(damage / 2 + 2) (6 to 10, more than 6 at least once in twelve shots); Punch II pushes the cow along the
*> flight by 2 x 0.6; a piercing arrow flies on through the first cow and hurts the second, a plain one stops at the first; a stuck arrow is picked up by a player (mode 1, Take Item
*> Entity to the viewers) but by a creative player only when the mode is 2 (a shot that cost nothing).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-ARROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-ARROW-TYPE          BINARY-LONG.
 01 WS-ARROW-ITEM          BINARY-LONG.
 01 WS-COW                 BINARY-LONG.
 01 WS-COW2                BINARY-LONG.
 01 WS-ARROW               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TICKS               BINARY-LONG VALUE 1.
 01 WS-DX                  FLOAT-LONG VALUE 0.
 01 WS-DZ                  FLOAT-LONG VALUE 3.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG VALUE 0.
 01 WS-VY                  FLOAT-LONG VALUE 0.
 01 WS-VZ                  FLOAT-LONG VALUE 3.
 01 WS-BASE                BINARY-LONG VALUE 2000.
 01 WS-OWNER               BINARY-LONG.
 01 WS-LOSS                BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-HAYSTACK            PIC X(1026).
 01 WS-HITS                BINARY-LONG.
 01 WS-CRIT                 BINARY-LONG VALUE 0.
 01 WS-PIERCE-LEVEL         BINARY-LONG VALUE 0.
 01 WS-ITEM-OK              BINARY-LONG.
 01 WS-BOB                  BINARY-LONG.
 01 WS-BOB-CONN             BINARY-LONG.
 01 WS-FOUND                BINARY-LONG.
 01 WS-MX                   FLOAT-LONG.
 01 WS-MY                   FLOAT-LONG.
 01 WS-MZ                   FLOAT-LONG.
 01 WS-HEALTH0              FLOAT-LONG.
 01 WS-LOSS-PLAYER          BINARY-LONG.
 01 WS-V0                   FLOAT-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "RT-OPEN" USING WS-PLAYER WS-CONN WS-FLOOR WS-CX WS-CZ
     MOVE "arrow" TO WS-KEY
     CALL "RT-ENTITY-ID" USING WS-KEY WS-ARROW-TYPE
     CALL "RT-ITEM-ID" USING WS-KEY WS-ARROW-ITEM
     MOVE PL-ENTITY-ID(WS-PLAYER) TO WS-OWNER
     MOVE "cow" TO WS-KEY
     CALL "RT-SPAWN-MOB" USING WS-PLAYER WS-KEY WS-DX WS-DZ WS-COW
     MOVE 100 TO EN-HEALTH(WS-COW)
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS

*>   A plain arrow: exactly 6.
     MOVE 0 TO WS-CRIT
     PERFORM FIRE
     MOVE EN-VZ(WS-COW) TO WS-V0
     MOVE "acceptance US14 17 3.9 an arrow of speed 3.0 and base damage 2.0 hurts a cow by ceil(6.0) = 6" TO WS-CASE
     MOVE 6 TO WS-EXPECT
     COMPUTE WS-OBSERVE = 100 - EN-HEALTH(WS-COW)
     PERFORM CHECK-N

*>   Critical arrows: never less than 6, more than 6 now and then, at most 10.
     MOVE 1 TO WS-CRIT
     MOVE 99 TO WS-MIN
     MOVE 0 TO WS-MAX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         PERFORM PLACE-COW
         PERFORM FIRE
         COMPUTE WS-LOSS = 100 - EN-HEALTH(WS-COW)
         MOVE FUNCTION MIN(WS-MIN, WS-LOSS) TO WS-MIN
         MOVE FUNCTION MAX(WS-MAX, WS-LOSS) TO WS-MAX
     END-PERFORM
     MOVE "acceptance US14 17 3.9 twelve critical arrows hurt by 6 to 10 and by more than 6 at least once" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-MIN >= 6 AND WS-MAX <= 10 AND WS-MAX > 6
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N

*>   Punch II: 2 x 0.6 along +z.
     MOVE 0 TO WS-CRIT
     PERFORM PLACE-COW
     MOVE 2 TO WS-PIERCE-LEVEL
     PERFORM FIRE-PUNCH
     MOVE "acceptance US14 17 3.9 Punch II pushes the cow along the flight by 1.2 more than a plain arrow does (millis 1190 to 1210)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF EN-VZ(WS-COW) - WS-V0 > 1.19 AND EN-VZ(WS-COW) - WS-V0 < 1.21
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE 0 TO EN-VZ(WS-COW)

*>   A plain arrow stops at the first cow; a piercing one hurts the second as well.
     CALL "ENTITY-REMOVE" USING WS-COW
     MOVE 1 TO WS-DZ
     CALL "RT-SPAWN-MOB" USING WS-PLAYER WS-KEY WS-DX WS-DZ WS-COW
     MOVE 3 TO WS-DZ
     CALL "RT-SPAWN-MOB" USING WS-PLAYER WS-KEY WS-DX WS-DZ WS-COW2
     PERFORM PLACE-PAIR
     MOVE 0 TO WS-PIERCE-LEVEL
     PERFORM FIRE-PIERCE
     MOVE "acceptance US14 17 3.9 an arrow without piercing hurts the first cow only" TO WS-CASE
     MOVE 600 TO WS-EXPECT
     COMPUTE WS-OBSERVE = (100 - EN-HEALTH(WS-COW)) * 100 + (100 - EN-HEALTH(WS-COW2))
     PERFORM CHECK-N
     PERFORM PLACE-PAIR
     MOVE 1 TO WS-PIERCE-LEVEL
     PERFORM FIRE-PIERCE
     MOVE "acceptance US14 17 3.9 piercing I: the arrow hurts both cows (6 and 6) and is then gone" TO WS-CASE
     MOVE 606 TO WS-EXPECT
     CALL "RT-COUNT" USING WS-ARROW-TYPE WS-COUNT WS-ROW
     COMPUTE WS-OBSERVE = (100 - EN-HEALTH(WS-COW)) * 100 + (100 - EN-HEALTH(WS-COW2)) + WS-COUNT * 1000
     PERFORM CHECK-N

*>   Pickup of a stuck arrow.
     CALL "RT-CLEAR-SLOTS" USING WS-PLAYER
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     PERFORM STICK
     MOVE 1 TO EN-ARR-PICKUP(WS-ARROW)
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE SPACES TO WS-HAYSTACK
     STRING " " WS-IDS " " DELIMITED BY SIZE INTO WS-HAYSTACK
     MOVE 0 TO WS-HITS
     INSPECT WS-HAYSTACK TALLYING WS-HITS FOR ALL " 127 "
     MOVE "acceptance US14 17 3.9 a player touching a stuck arrow (mode 1) takes it: one arrow in the inventory, the entity gone, Take Item Entity sent" TO WS-CASE
     CALL "RT-COUNT" USING WS-ARROW-TYPE WS-COUNT WS-ROW
     MOVE 0 TO WS-ITEM-OK
     IF PL-SLOT-ITEM(WS-PLAYER, 1) = WS-ARROW-ITEM
         MOVE 1 TO WS-ITEM-OK
     END-IF
     COMPUTE WS-OBSERVE = WS-COUNT * 1000 + WS-HITS * 100 + PL-SLOT-COUNT(WS-PLAYER, 1) * 10 + WS-ITEM-OK
     MOVE 111 TO WS-EXPECT
     PERFORM CHECK-N
     CALL "RT-CLEAR-SLOTS" USING WS-PLAYER
     PERFORM STICK
     MOVE 2 TO EN-ARR-PICKUP(WS-ARROW)
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "acceptance US14 17 3.9 mode 2 (a shot that cost nothing) is not picked up by a survival player: the arrow stays, nothing in the inventory" TO WS-CASE
     MOVE 1000 TO WS-EXPECT
     CALL "RT-COUNT" USING WS-ARROW-TYPE WS-COUNT WS-ROW
     COMPUTE WS-OBSERVE = WS-COUNT * 1000 + PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM CHECK-N
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "acceptance US14 17 3.9 a creative player picks the mode 2 arrow up" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     CALL "RT-COUNT" USING WS-ARROW-TYPE WS-COUNT WS-ROW
     COMPUTE WS-OBSERVE = (1 - WS-COUNT) * PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM CHECK-N

*>   An arrow that has been stuck for 1200 ticks goes.
     CALL "RT-CLEAR-SLOTS" USING WS-PLAYER
     PERFORM STICK
     MOVE 0 TO EN-ARR-PICKUP(WS-ARROW)
     MOVE 1199 TO EN-AGE(WS-ARROW)
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "RT-COUNT" USING WS-ARROW-TYPE WS-COUNT WS-ROW
     MOVE "acceptance US14 44 7.5 an arrow stuck for 1200 ticks despawns" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-COUNT TO WS-OBSERVE
     PERFORM CHECK-N

*>   Another player in the line of flight: hurt, pushed by Punch, and passed through by a piercing arrow.
     CALL "RT-JOIN-BOB" USING WS-PLAYER WS-BOB WS-BOB-CONN
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "TEST-DRAIN-IDS" USING WS-BOB-CONN WS-IDS
     MOVE PL-HEALTH(WS-BOB) TO WS-HEALTH0
     MOVE 1 TO WS-PIERCE-LEVEL
     PERFORM FIRE-PUNCH
     COMPUTE WS-LOSS-PLAYER = FUNCTION INTEGER(WS-HEALTH0 - PL-HEALTH(WS-BOB) + 0.5)
     MOVE "acceptance US14 17 3.9 an arrow hurts another player in its way by 6 (speed 3.0 x base damage 2.0)" TO WS-CASE
     MOVE 6 TO WS-EXPECT
     MOVE WS-LOSS-PLAYER TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "RT-MOTION" USING WS-BOB-CONN WS-FOUND WS-MX WS-MY WS-MZ
     MOVE "acceptance US14 17 3.9 Punch I sends the hit player Set Entity Motion of 0.6 along the flight (millis 590 to 610)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-FOUND = 1 AND WS-MZ > 0.59 AND WS-MZ < 0.61 AND WS-MX > -0.01 AND WS-MX < 0.01
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE 0 TO PL-HURT-COOLDOWN(WS-BOB)
     MOVE PL-HEALTH(WS-BOB) TO WS-HEALTH0
     MOVE 0 TO WS-DX
     MOVE 5 TO WS-DZ
*>   The two cows of the earlier cases are taken away: a live one standing in the line (at the player's z + 3, the player's own cell) would be the entity the arrow meets after the
*>   player (hits are by order of the entity table), and the cow behind them would not be reached.
     IF EN-USED(WS-COW) = 1
         CALL "ENTITY-REMOVE" USING WS-COW
     END-IF
     IF EN-USED(WS-COW2) = 1
         CALL "ENTITY-REMOVE" USING WS-COW2
     END-IF
     CALL "RT-SPAWN-MOB" USING WS-PLAYER WS-KEY WS-DX WS-DZ WS-COW
     MOVE 100 TO EN-HEALTH(WS-COW)
     MOVE 1 TO WS-PIERCE-LEVEL
     PERFORM FIRE-PIERCE
     CALL "TEST-TICKS" USING WS-TICKS
     COMPUTE WS-LOSS-PLAYER = FUNCTION INTEGER(WS-HEALTH0 - PL-HEALTH(WS-BOB) + 0.5)
     MOVE "acceptance US14 17 3.9 a piercing arrow passes through the player (hurt once, 6) and hurts the cow behind (6)" TO WS-CASE
     MOVE 66 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-LOSS-PLAYER * 10 + (100 - EN-HEALTH(WS-COW))
     PERFORM CHECK-N
     STOP RUN.

*> An arrow from the player's x and z at 0.5 above the floor along +z (the first WS-VZ blocks), crit WS-CRIT, then one tick.
 FIRE.
     PERFORM CLEAR-ARROWS
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = PL-Y(WS-PLAYER) + 0.5
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "ARROW-SPAWN" USING PL-DIM(WS-PLAYER) WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-BASE WS-OWNER WS-ARROW
     MOVE WS-CRIT TO EN-ARR-CRIT(WS-ARROW)
     CALL "TEST-TICKS" USING WS-TICKS.

 FIRE-PUNCH.
     PERFORM CLEAR-ARROWS
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = PL-Y(WS-PLAYER) + 0.5
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "ARROW-SPAWN" USING PL-DIM(WS-PLAYER) WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-BASE WS-OWNER WS-ARROW
     MOVE WS-PIERCE-LEVEL TO EN-ARR-PUNCH(WS-ARROW)
     CALL "TEST-TICKS" USING WS-TICKS.

 FIRE-PIERCE.
     PERFORM CLEAR-ARROWS
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = PL-Y(WS-PLAYER) + 0.5
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "ARROW-SPAWN" USING PL-DIM(WS-PLAYER) WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-BASE WS-OWNER WS-ARROW
     MOVE WS-PIERCE-LEVEL TO EN-ARR-PIERCE(WS-ARROW)
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS.

*> A stuck arrow at the player's feet, stuck for 10 ticks.
 STICK.
     PERFORM CLEAR-ARROWS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE 0 TO WS-VZ
     CALL "ARROW-SPAWN" USING PL-DIM(WS-PLAYER) WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-BASE WS-OWNER WS-ARROW
     MOVE 3 TO WS-VZ
     MOVE 1 TO EN-ON-GROUND(WS-ARROW)
     MOVE 10 TO EN-AGE(WS-ARROW).

 PLACE-PAIR.
     PERFORM PLACE-COW
     COMPUTE EN-Z(WS-COW) = PL-Z(WS-PLAYER) + 1
     MOVE PL-X(WS-PLAYER) TO EN-X(WS-COW2)
     MOVE PL-Y(WS-PLAYER) TO EN-Y(WS-COW2)
     COMPUTE EN-Z(WS-COW2) = PL-Z(WS-PLAYER) + 3
     MOVE 0 TO EN-VX(WS-COW2) EN-VY(WS-COW2) EN-VZ(WS-COW2) EN-FLEE(WS-COW2) EN-HURT(WS-COW2)
     MOVE 100 TO EN-HEALTH(WS-COW2).

 CLEAR-ARROWS.
     CALL "RT-COUNT" USING WS-ARROW-TYPE WS-COUNT WS-ROW
     PERFORM UNTIL WS-COUNT = 0
         CALL "ENTITY-REMOVE" USING WS-ROW
         CALL "RT-COUNT" USING WS-ARROW-TYPE WS-COUNT WS-ROW
     END-PERFORM.

*> The cow back at 3 blocks ahead on the floor, standing still.
 PLACE-COW.
     MOVE PL-X(WS-PLAYER) TO EN-X(WS-COW)
     MOVE PL-Y(WS-PLAYER) TO EN-Y(WS-COW)
     COMPUTE EN-Z(WS-COW) = PL-Z(WS-PLAYER) + 3
     MOVE 0 TO EN-VX(WS-COW) EN-VY(WS-COW) EN-VZ(WS-COW) EN-FLEE(WS-COW)
     MOVE 100 TO EN-HEALTH(WS-COW)
     MOVE 0 TO EN-HURT(WS-COW).

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US14-ARROW.
 COPY CORETEST.
 COPY RANGEDTEST.
