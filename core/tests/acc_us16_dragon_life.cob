*> Acceptance test, the ender dragon's damage rules, tick, death sequence and crystal hook (docs/protocol/21 section 6.4, 6.4.4, 44 part 9 section 1.1; lane 002-lane-mobsb8, T9703): part damage (body
*> divisor, head and neck full, only players and explosions), the sitting damage limit (50 -> takeoff), the killing blow (health 1 and DYING, or death when sitting), healing from a crystal, wing and head
*> contact damage, the death sequence (rise 0.1 per tick, XP orbs, removal at 200) and the crystal destroyed hook (10 head damage, strafe at the player).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US16-DRAGON-LIFE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY DRAGSTATE.
 COPY RULES.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CROW                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-PART                BINARY-LONG.
 01 WS-AMOUNT              FLOAT-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-ATT                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-HANDLED             BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-YES                 BINARY-LONG VALUE 1.
 01 WS-N2                  BINARY-LONG VALUE 0.
 01 WS-N3                  BINARY-LONG VALUE 0.
 01 WS-DONE                BINARY-LONG.
 01 WS-ORBS                BINARY-LONG.
 01 WS-PHASE               BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-ORB-KEY             PIC X(112) VALUE "minecraft:experience_orb".
 01 WS-ORB-TYPE            BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "THROWN-TYPE" USING WS-ORB-KEY WS-ORB-TYPE
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO WS-X
     MOVE 100 TO WS-Y
     MOVE 0 TO WS-Z
     CALL "DRAGON-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ROW
     MOVE 900 TO PL-X(WS-PLAYER)
     MOVE 900 TO PL-Z(WS-PLAYER)
*>   Damage: the body takes amount / 4 + min(amount, 1), the head the full amount; only players and explosions hurt.
     MOVE 3 TO WS-PART
     MOVE 8 TO WS-AMOUNT
     MOVE CAUSE-PLAYER TO WS-CAUSE
     CALL "DRAGON-HURT-PART" USING WS-ROW WS-PART WS-AMOUNT WS-CAUSE WS-PLAYER WS-OK
     MOVE "acceptance US16 21 6.4 a body hit of 8 by a player does 8 / 4 + 1 = 3" TO TL-CASE
     MOVE 197 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-HP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-PART
     CALL "DRAGON-HURT-PART" USING WS-ROW WS-PART WS-AMOUNT WS-CAUSE WS-PLAYER WS-OK
     MOVE "acceptance US16 21 6.4 a head hit of 8 does the full 8" TO TL-CASE
     MOVE 189 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-HP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CAUSE-MOB TO WS-CAUSE
     CALL "DRAGON-HURT-PART" USING WS-ROW WS-PART WS-AMOUNT WS-CAUSE WS-NO WS-OK
     MOVE "acceptance US16 21 6.4 damage with no player attacker and not in always_hurts_ender_dragons is ignored" TO TL-CASE
     MOVE 189 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-HP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CAUSE-EXPLOSION TO WS-CAUSE
     CALL "DRAGON-HURT-PART" USING WS-ROW WS-PART WS-AMOUNT WS-CAUSE WS-NO WS-OK
     MOVE "acceptance US16 21 6.4 an explosion always hurts the dragon" TO TL-CASE
     MOVE 181 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-HP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.005 TO WS-AMOUNT
     CALL "DRAGON-HURT-PART" USING WS-ROW WS-PART WS-AMOUNT WS-CAUSE WS-NO WS-OK
     MOVE "acceptance US16 21 6.4 an amount below 0.01 does nothing" TO TL-CASE
     MOVE 181 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-HP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Hook: the dragon handles its own damage, other entities are not handled.
     MOVE 8 TO WS-INT
     MOVE CAUSE-PLAYER TO WS-CAUSE
     CALL "DRAGON-HURT" USING WS-ROW WS-INT WS-CAUSE WS-PLAYER WS-HANDLED
     MOVE "acceptance US16 21 6.4 DRAGON-HURT handles the dragon's damage" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HANDLED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4 the hook hit lowered the health" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF DG-HP < 181
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE EN-HEALTH(WS-ROW) TO WS-BEFORE
     MOVE 0 TO WS-HANDLED
     MOVE 1 TO WS-I
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT OR (EN-USED(WS-I) = 1 AND EN-ID(WS-I) NOT = DG-ENT)
         CONTINUE
     END-PERFORM
     IF WS-I <= EN-COUNT
         CALL "DRAGON-HURT" USING WS-I WS-INT WS-CAUSE WS-PLAYER WS-HANDLED
     END-IF
     MOVE "acceptance US16 21 6.4 another entity is not handled by the dragon hook" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HANDLED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Sitting: arrows are ignored; more than 50 damage in a sitting phase starts TAKEOFF.
     MOVE 200 TO DG-HP
     MOVE 6 TO DG-PHASE
     MOVE 0 TO DG-SIT-DMG
     MOVE CAUSE-ARROW TO WS-CAUSE
     MOVE 10 TO WS-AMOUNT
     CALL "DRAGON-HURT-PART" USING WS-ROW WS-PART WS-AMOUNT WS-CAUSE WS-PLAYER WS-OK
     MOVE "acceptance US16 21 6.4 a sitting dragon ignores arrows" TO TL-CASE
     MOVE 200 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-HP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CAUSE-PLAYER TO WS-CAUSE
     MOVE 40 TO WS-AMOUNT
     CALL "DRAGON-HURT-PART" USING WS-ROW WS-PART WS-AMOUNT WS-CAUSE WS-PLAYER WS-OK
     MOVE "acceptance US16 21 6.4 40 sitting damage is counted, no takeoff yet" TO TL-CASE
     MOVE 406 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-SIT-DMG * 10 + DG-PHASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO WS-AMOUNT
     CALL "DRAGON-HURT-PART" USING WS-ROW WS-PART WS-AMOUNT WS-CAUSE WS-PLAYER WS-OK
     MOVE "acceptance US16 21 6.4 above 50 sitting damage the counter resets and the phase is TAKEOFF (4)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-SIT-DMG + DG-PHASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Killing blow: flying, health 1 and DYING; sitting, health 0.
     MOVE 0 TO DG-PHASE
     MOVE 5 TO DG-HP
     MOVE 20 TO WS-AMOUNT
     CALL "DRAGON-HURT-PART" USING WS-ROW WS-PART WS-AMOUNT WS-CAUSE WS-PLAYER WS-OK
     MOVE "acceptance US16 21 6.4 a killing blow while flying leaves 1 health and starts DYING (9)" TO TL-CASE
     MOVE 91 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-PHASE * 10 + DG-HP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 21 6.4 a dying dragon takes no more damage" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     CALL "DRAGON-HURT-PART" USING WS-ROW WS-PART WS-AMOUNT WS-CAUSE WS-PLAYER WS-OK
     COMPUTE TL-OBSERVED-N ROUNDED = DG-HP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO DG-PHASE
     MOVE 5 TO DG-HP
     MOVE 0 TO DG-SIT-DMG
     CALL "DRAGON-HURT-PART" USING WS-ROW WS-PART WS-AMOUNT WS-CAUSE WS-PLAYER WS-OK
     MOVE "acceptance US16 21 6.4 a killing blow while sitting leaves 0 health (the death sequence)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-HP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Healing: with a crystal remembered the dragon heals 1 every 10 ticks.
     MOVE 6 TO WS-INT
     MOVE 0 TO WS-I
     MOVE 5 TO WS-Y
     CALL "CRYSTAL-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-YES WS-CROW
     MOVE 100 TO DG-HP
     MOVE 0 TO DG-PHASE
     MOVE EN-ID(WS-CROW) TO DG-CRYSTAL
     MOVE 10 TO DG-TICK
     CALL "DRAGON-HEAL" USING WS-ROW
     MOVE "acceptance US16 21 6.4 the dragon heals 1 on every tenth tick while a crystal is remembered" TO TL-CASE
     MOVE 101 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-HP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 11 TO DG-TICK
     CALL "DRAGON-HEAL" USING WS-ROW
     MOVE "acceptance US16 21 6.4 and not on the other ticks" TO TL-CASE
     MOVE 101 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-HP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-DROP" USING WS-CROW
     MOVE 19 TO DG-TICK
     CALL "DRAGON-HEAL" USING WS-ROW
     MOVE "acceptance US16 21 6.4 a removed crystal is forgotten and heals nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE DG-CRYSTAL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The crystal destroyed hook: the nearest crystal is destroyed by a player near: 10 damage to the head and the dragon strafes the player.
     MOVE 200 TO DG-HP
     MOVE 0 TO DG-PHASE
     MOVE 0 TO WS-X
     MOVE 40 TO WS-Y
     MOVE 40 TO WS-Z
     CALL "CRYSTAL-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-YES WS-CROW
     MOVE EN-ID(WS-CROW) TO DG-CRYSTAL
     MOVE 10 TO PL-X(WS-PLAYER)
     MOVE 100 TO PL-Y(WS-PLAYER)
     MOVE 10 TO PL-Z(WS-PLAYER)
     CALL "CRYSTAL-HURT" USING WS-CROW WS-NO WS-N2 WS-PLAYER WS-DONE
     MOVE "acceptance US16 21 6.4 destroying the dragon's nearest crystal hurts its head for 10" TO TL-CASE
     MOVE 190 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = DG-HP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 44-9 1.1 and a circling dragon strafes the player who did it (phase 1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE DG-PHASE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Contact: a player in the head box takes 10 (mob attack), a player at a wing takes 5 while flying.
     MOVE 0 TO DG-PHASE
     MOVE 0 TO EN-X(WS-ROW) EN-Z(WS-ROW) EN-YAW(WS-ROW)
     MOVE 100 TO EN-Y(WS-ROW)
     MOVE 0 TO DG-HURT-T
     MOVE 100 TO DG-TICK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         CALL "DRAGON-HIST-PUSH" USING WS-ROW
     END-PERFORM
     CALL "DRAGON-PARTS" USING WS-ROW
     MOVE DG-PART-X(1) TO PL-X(WS-PLAYER)
     MOVE DG-PART-Y(1) TO PL-Y(WS-PLAYER)
     MOVE DG-PART-Z(1) TO PL-Z(WS-PLAYER)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     CALL "DRAGON-CONTACT" USING WS-ROW
     MOVE "acceptance US16 21 6.4 a player in the head box takes damage" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-HEALTH(WS-PLAYER) < 20
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE DG-PART-X(7) TO PL-X(WS-PLAYER)
     MOVE DG-PART-Y(7) TO PL-Y(WS-PLAYER)
     MOVE DG-PART-Z(7) TO PL-Z(WS-PLAYER)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     MOVE 0 TO DG-HURT-T
     CALL "DRAGON-CONTACT" USING WS-ROW
     MOVE "acceptance US16 21 6.4 a player at a wing takes damage while the dragon flies" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-HEALTH(WS-PLAYER) < 20
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Death sequence: health 0; it rises 0.1 per tick, orbs from tick 155, removed at tick 200 (the fight is not involved: DG-FIGHT 0).
     MOVE 900 TO PL-X(WS-PLAYER)
     MOVE 900 TO PL-Z(WS-PLAYER)
     MOVE 0 TO DG-HP DG-DEATH-T DG-FIGHT
     MOVE 9 TO DG-PHASE
     MOVE 100 TO EN-Y(WS-ROW)
     MOVE 0 TO EN-X(WS-ROW) EN-Z(WS-ROW)
     MOVE EN-ID(WS-ROW) TO WS-BEFORE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         CALL "DRAGON-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US16 21 6.4.4 after 10 ticks of dying the dragon rose by 1.0" TO TL-CASE
     MOVE 1010 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-Y(WS-ROW) * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 11 BY 1 UNTIL WS-I > 160
         CALL "DRAGON-STEP" USING WS-ROW
     END-PERFORM
     MOVE 0 TO WS-ORBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-ORB-TYPE
             ADD 1 TO WS-ORBS
         END-IF
     END-PERFORM
     MOVE "acceptance US16 21 6.4.4 experience orbs appear from tick 155" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ORBS > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 161 BY 1 UNTIL WS-I > 200
         CALL "DRAGON-STEP" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US16 21 6.4.4 at tick 200 the dragon is removed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE DG-ENT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US16-DRAGON-LIFE.
 COPY CORETEST.
 COPY MOBSPTEST.
