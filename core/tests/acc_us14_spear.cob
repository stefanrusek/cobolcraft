*> Acceptance test (US14; docs/protocol/17 section 3.12 spear jab, 2.4 spear table, 6.3 Lunge, 4.1 attack strength): the spear's jab through the real play path. The Attack packet
*> never runs the melee rules for a spear (handleAttack returns at once); Player Action STAB (8) is the jab: refused until the attack strength reaches the minimum attack charge 1.0,
*> then it hurts every entity along the look ray between the attack range's minimum and maximum reach (2.0 to 4.5, a creative player 2.0 to 6.5) by the spear's attack damage (iron 3),
*> costs 1 durability for each entity hit and 0.1 exhaustion for each stab, and resets the attack strength; Lunge I pushes the player along the look direction (Set Entity Motion), costs
*> 4.0 exhaustion and 1 more durability.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-SPEAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CTOOLS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-COW1                BINARY-LONG.
 01 WS-COW2                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-EIGHT               BINARY-LONG VALUE 8.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-TICKS               BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-EXH0                FLOAT-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-HAYSTACK            PIC X(1026).
 01 WS-HITS                BINARY-LONG.
 01 WS-ENCH-KEY            PIC X(112).
 01 WS-LOSS1               BINARY-LONG.
 01 WS-LOSS2               BINARY-LONG.
 01 WS-LAST0               BINARY-DOUBLE.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "RT-OPEN" USING WS-PLAYER WS-CONN WS-FLOOR WS-CX WS-CZ
*>   Looking a little down (a cow is 1.4 high, the eye 1.62 above the feet).
     MOVE 0 TO PL-YAW(WS-PLAYER)
     MOVE 5 TO PL-PITCH(WS-PLAYER)
     MOVE "cow" TO WS-KEY
     MOVE 0 TO WS-DX
     MOVE 3 TO WS-DZ
     CALL "RT-SPAWN-MOB" USING WS-PLAYER WS-KEY WS-DX WS-DZ WS-COW1
     CALL "RT-SPAWN-MOB" USING WS-PLAYER WS-KEY WS-DX WS-DZ WS-COW2
     PERFORM FRESH
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS

*>   The Attack packet does nothing with a spear in the hand.
     MOVE EN-ID(WS-COW1) TO WS-ID
     MOVE 2 TO WS-DZ
     PERFORM PLACE-COWS
     MOVE PL-X(WS-PLAYER) TO WS-EXH0
     CALL "TEST-ATTACK" USING WS-CONN WS-ID
     MOVE "acceptance US14 17 3.12 the Attack packet never runs the melee rules for a spear: the cow in reach is untouched and the attack strength not reset" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = 100 - EN-HEALTH(WS-COW1) + TS-LAST-ATTACK(WS-PLAYER)
     PERFORM CHECK-N

*>   The jab: a cow 3 blocks ahead loses 3 (iron spear), one durability, 0.1 exhaustion, the strength is reset.
     MOVE 3 TO WS-DZ
     PERFORM PLACE-COWS
     MOVE PL-EXHAUSTION(WS-PLAYER) TO WS-EXH0
     PERFORM STAB
     COMPUTE WS-LOSS1 = 100 - EN-HEALTH(WS-COW1)
     MOVE "acceptance US14 17 3.12 STAB with an iron spear hurts the cow 3 blocks ahead by its attack damage 3" TO WS-CASE
     MOVE 3 TO WS-EXPECT
     MOVE WS-LOSS1 TO WS-OBSERVE
     PERFORM CHECK-N
     CALL "RT-DAMAGE" USING WS-PLAYER WS-ONE WS-DAMAGE
     MOVE "acceptance US14 5.1 the spear takes 1 durability for the one entity it hit" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-DAMAGE TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US14 17 3.12 a stab costs 0.1 exhaustion (hundredths)" TO WS-CASE
     MOVE 10 TO WS-EXPECT
     COMPUTE WS-OBSERVE = FUNCTION INTEGER((PL-EXHAUSTION(WS-PLAYER) - WS-EXH0) * 100 + 0.5)
     PERFORM CHECK-N
     MOVE "acceptance US14 17 3.12 the stab resets the attack strength (TS-LAST-ATTACK is this tick + 1)" TO WS-CASE
     COMPUTE WS-EXPECT = CW-TICKS + 1
     MOVE TS-LAST-ATTACK(WS-PLAYER) TO WS-OBSERVE
     PERFORM CHECK-N

*>   Refused straight away: the attack strength is below the minimum attack charge 1.0.
     MOVE 3 TO WS-DZ
     PERFORM PLACE-COWS
     PERFORM STAB
     COMPUTE WS-LOSS1 = 100 - EN-HEALTH(WS-COW1)
     MOVE "acceptance US14 17 3.12 a second stab in the same tick is refused (attack strength below 1.0): no damage" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-LOSS1 TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 30 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM PLACE-COWS
     PERFORM STAB
     COMPUTE WS-LOSS1 = 100 - EN-HEALTH(WS-COW1)
     MOVE "acceptance US14 17 3.12 after 30 ticks (the iron spear's cooldown is 19) the strength is full again: the stab hurts by 3" TO WS-CASE
     MOVE 3 TO WS-EXPECT
     MOVE WS-LOSS1 TO WS-OBSERVE
     PERFORM CHECK-N

*>   Too close, too far and off the line: not hit.
     MOVE 30 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 1 TO WS-DZ
     PERFORM PLACE-COWS
     PERFORM STAB
     COMPUTE WS-LOSS1 = 100 - EN-HEALTH(WS-COW1)
     MOVE "acceptance US14 17 2.4 a cow 1 block ahead is closer than the minimum reach 2.0: not hit" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-LOSS1 TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 30 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 5.5 TO WS-DZ
     PERFORM PLACE-COWS
     PERFORM STAB
     COMPUTE WS-LOSS1 = 100 - EN-HEALTH(WS-COW1)
     MOVE "acceptance US14 17 2.4 a cow 5.5 blocks ahead (its box enters at 4.9) is beyond the maximum reach 4.5: not hit" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-LOSS1 TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 30 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 3 TO WS-DZ
     PERFORM PLACE-COWS
     MOVE 1.5 TO EN-X(WS-COW1)
     ADD PL-X(WS-PLAYER) TO EN-X(WS-COW1)
     PERFORM STAB
     COMPUTE WS-LOSS1 = 100 - EN-HEALTH(WS-COW1)
     MOVE "acceptance US14 17 3.12 a cow 1.5 blocks beside the line is not hit" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-LOSS1 TO WS-OBSERVE
     PERFORM CHECK-N

*>   Every entity along the ray: two cows in line, both hit, 2 durability.
     MOVE 30 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM FRESH
     MOVE 2.5 TO WS-DZ
     PERFORM PLACE-COWS
     MOVE PL-X(WS-PLAYER) TO EN-X(WS-COW2)
     COMPUTE EN-Z(WS-COW2) = PL-Z(WS-PLAYER) + 3.8
     PERFORM STAB
     COMPUTE WS-LOSS1 = 100 - EN-HEALTH(WS-COW1)
     COMPUTE WS-LOSS2 = 100 - EN-HEALTH(WS-COW2)
     CALL "RT-DAMAGE" USING WS-PLAYER WS-ONE WS-DAMAGE
     MOVE "acceptance US14 17 3.12 the jab goes through: two cows in line both lose 3 and the spear takes 2 durability" TO WS-CASE
     MOVE 332 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-LOSS1 * 100 + WS-LOSS2 * 10 + WS-DAMAGE
     PERFORM CHECK-N

*>   A creative player reaches to 6.5.
     MOVE 30 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE 6 TO WS-DZ
     PERFORM PLACE-COWS
     PERFORM STAB
     COMPUTE WS-LOSS1 = 100 - EN-HEALTH(WS-COW1)
     MOVE "acceptance US14 17 2.4 a creative player's attack range reaches 6.5: a cow 6 blocks ahead is hurt by 3" TO WS-CASE
     MOVE 3 TO WS-EXPECT
     MOVE WS-LOSS1 TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 0 TO PL-MODE(WS-PLAYER)

*>   Lunge I: Set Entity Motion to the player, 4.0 exhaustion, 1 extra durability.
     MOVE 30 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM FRESH
     MOVE "minecraft:lunge" TO WS-ENCH-KEY
     CALL "RT-ENCHANT" USING WS-PLAYER WS-ONE WS-ENCH-KEY WS-ONE
     MOVE 3 TO WS-DZ
     PERFORM PLACE-COWS
     MOVE PL-EXHAUSTION(WS-PLAYER) TO WS-EXH0
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     PERFORM STAB
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE SPACES TO WS-HAYSTACK
     STRING " " WS-IDS " " DELIMITED BY SIZE INTO WS-HAYSTACK
     MOVE 0 TO WS-HITS
     INSPECT WS-HAYSTACK TALLYING WS-HITS FOR ALL " 103 "
     CALL "RT-DAMAGE" USING WS-PLAYER WS-ONE WS-DAMAGE
     MOVE "acceptance US14 17 3.12 Lunge I after a stab: Set Entity Motion to the player, 2 durability (1 hit and 1 for the lunge)" TO WS-CASE
     MOVE 12 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-HITS * 10 + WS-DAMAGE
     PERFORM CHECK-N
     MOVE "acceptance US14 17 6.3 Lunge I costs 4.0 exhaustion on top of the stab's 0.1 (hundredths: 410)" TO WS-CASE
     MOVE 410 TO WS-EXPECT
     COMPUTE WS-OBSERVE = FUNCTION INTEGER((PL-EXHAUSTION(WS-PLAYER) - WS-EXH0) * 100 + 0.5)
     PERFORM CHECK-N
     STOP RUN.

*> A fresh iron spear in slot 1, survival, a full attack strength, food full.
 FRESH.
     CALL "RT-CLEAR-SLOTS" USING WS-PLAYER
     MOVE "iron_spear" TO WS-KEY
     CALL "RT-GIVE" USING WS-PLAYER WS-ONE WS-KEY WS-ONE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO TS-LAST-ATTACK(WS-PLAYER)
     MOVE 20 TO PL-FOOD(WS-PLAYER).

*> Cow 1 on the line of sight WS-DZ blocks ahead, cow 2 3 blocks to its side (out of the line), both healthy and still.
 PLACE-COWS.
     MOVE PL-X(WS-PLAYER) TO EN-X(WS-COW1)
     COMPUTE EN-X(WS-COW2) = PL-X(WS-PLAYER) + 3
     MOVE PL-Y(WS-PLAYER) TO EN-Y(WS-COW1) EN-Y(WS-COW2)
     COMPUTE EN-Z(WS-COW1) = PL-Z(WS-PLAYER) + WS-DZ
     COMPUTE EN-Z(WS-COW2) = PL-Z(WS-PLAYER) + WS-DZ
     MOVE 0 TO EN-VX(WS-COW1) EN-VY(WS-COW1) EN-VZ(WS-COW1) EN-HURT(WS-COW1) EN-FLEE(WS-COW1)
     MOVE 0 TO EN-VX(WS-COW2) EN-VY(WS-COW2) EN-VZ(WS-COW2) EN-HURT(WS-COW2) EN-FLEE(WS-COW2)
     MOVE 100 TO EN-HEALTH(WS-COW1) EN-HEALTH(WS-COW2).

 STAB.
     CALL "TEST-ACTION" USING WS-CONN WS-EIGHT WS-ZERO WS-ZERO WS-ZERO WS-ZERO WS-ZERO.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US14-SPEAR.
 COPY CORETEST.
 COPY RANGEDTEST.
