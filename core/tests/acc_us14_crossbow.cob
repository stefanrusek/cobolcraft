*> Acceptance test (US14; docs/protocol/17 section 3.9 crossbow, 25 part 7 section 9, 6.3 Quick Charge, Multishot, Piercing): the crossbow through the real play path. Use Item
*> starts the charge when a projectile exists; the tick completes it after 25 - 5 L ticks (Quick Charge L): the ammunition (the off hand's first) goes into the charged_projectiles
*> component and one item is used up (nothing for a creative player); releasing early only stops the charge; Use Item with a charged crossbow shoots (power 3.15, a critical arrow,
*> 1 durability), Multishot loads 3 (the extras free, mode 2) and shoots them at 0, -10 and +10 degrees for 3 durability, Piercing is carried to the arrow, and a firework rocket
*> flies at 1.6 and costs 3 durability.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-CROSSBOW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-ARROW-TYPE          BINARY-LONG.
 01 WS-ROCKET-TYPE         BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW1                BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-ROW3                BINARY-LONG.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-SIX                 BINARY-LONG VALUE 6.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-TICKS               BINARY-LONG.
 01 WS-CHARGED             BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-ENCH-KEY            PIC X(112).
 01 WS-SPEED               BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "RT-OPEN" USING WS-PLAYER WS-CONN WS-FLOOR WS-CX WS-CZ
     MOVE "arrow" TO WS-KEY
     CALL "RT-ENTITY-ID" USING WS-KEY WS-ARROW-TYPE
     MOVE "firework_rocket" TO WS-KEY
     CALL "RT-ENTITY-ID" USING WS-KEY WS-ROCKET-TYPE
     MOVE 0 TO PL-YAW(WS-PLAYER) PL-PITCH(WS-PLAYER)
     PERFORM FRESH-SLOTS
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS

*>   Charge: not loaded after 24 ticks, loaded after 25; one arrow used.
     CALL "TEST-USE-ITEM" USING WS-CONN
     MOVE 24 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "RT-CHARGED" USING WS-PLAYER WS-ONE WS-CHARGED
     MOVE "acceptance US14 17 3.9 a crossbow is not charged after 24 ticks of use (charge time 25) and no arrow is used" TO WS-CASE
     MOVE 10 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-CHARGED * 100 + PL-SLOT-COUNT(WS-PLAYER, 5)
     PERFORM CHECK-N
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "RT-CHARGED" USING WS-PLAYER WS-ONE WS-CHARGED
     MOVE "acceptance US14 17 3.9 after 25 ticks the crossbow holds one charged projectile and one of ten arrows is used up" TO WS-CASE
     MOVE 109 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-CHARGED * 100 + PL-SLOT-COUNT(WS-PLAYER, 5)
     PERFORM CHECK-N

*>   Use Item with the charged crossbow shoots.
     CALL "RT-CLEAR-TYPE" USING WS-ARROW-TYPE
     CALL "TEST-USE-ITEM" USING WS-CONN
     CALL "RT-COUNT" USING WS-ARROW-TYPE WS-COUNT WS-ROW
     COMPUTE WS-SPEED = FUNCTION INTEGER(FUNCTION SQRT(EN-VX(WS-ROW) * EN-VX(WS-ROW) + EN-VY(WS-ROW) * EN-VY(WS-ROW)
         + EN-VZ(WS-ROW) * EN-VZ(WS-ROW)) * 1000)
     MOVE "acceptance US14 17 3.9 Use Item with a charged crossbow shoots one critical arrow at 3.15 (millis 3050 to 3250), owned by the player, pickup mode 1" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-COUNT = 1 AND WS-SPEED >= 3050 AND WS-SPEED <= 3250 AND EN-ARR-CRIT(WS-ROW) = 1 AND EN-ARR-PICKUP(WS-ROW) = 1
             AND EN-TARGET-ID(WS-ROW) = PL-ENTITY-ID(WS-PLAYER)
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     CALL "RT-CHARGED" USING WS-PLAYER WS-ONE WS-CHARGED
     CALL "RT-DAMAGE" USING WS-PLAYER WS-ONE WS-DAMAGE
     MOVE "acceptance US14 17 3.9 the crossbow is empty again and took 1 durability" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-DAMAGE - WS-CHARGED * 10
     PERFORM CHECK-N

*>   Releasing early only stops the charge.
     CALL "TEST-USE-ITEM" USING WS-CONN
     MOVE 10 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "RT-RELEASE" USING WS-CONN
     MOVE 30 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "RT-CHARGED" USING WS-PLAYER WS-ONE WS-CHARGED
     MOVE "acceptance US14 17 3.9 releasing after 10 ticks loads nothing, even 30 ticks later; the arrows stay at 9" TO WS-CASE
     MOVE 9 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-CHARGED * 100 + PL-SLOT-COUNT(WS-PLAYER, 5)
     PERFORM CHECK-N

*>   Quick Charge III: 10 ticks.
     PERFORM FRESH-SLOTS
     MOVE "minecraft:quick_charge" TO WS-ENCH-KEY
     MOVE 3 TO WS-THREE
     CALL "RT-ENCHANT" USING WS-PLAYER WS-ONE WS-ENCH-KEY WS-THREE
     CALL "TEST-USE-ITEM" USING WS-CONN
     MOVE 9 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "RT-CHARGED" USING WS-PLAYER WS-ONE WS-CHARGED
     MOVE WS-CHARGED TO WS-COUNT
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "RT-CHARGED" USING WS-PLAYER WS-ONE WS-CHARGED
     MOVE "acceptance US14 17 3.9 Quick Charge III charges in 10 ticks: not after 9, loaded after 10" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-CHARGED - WS-COUNT
     PERFORM CHECK-N

*>   Multishot: three loaded for one arrow, shot at 0, -10 and +10 degrees, 3 durability.
     PERFORM FRESH-SLOTS
     MOVE 3 TO WS-THREE
     CALL "RT-ENCHANT" USING WS-PLAYER WS-ONE WS-ENCH-KEY WS-THREE
     MOVE "minecraft:multishot" TO WS-ENCH-KEY
     CALL "RT-ENCHANT1" USING WS-PLAYER WS-ENCH-KEY WS-ONE
     CALL "TEST-USE-ITEM" USING WS-CONN
     MOVE 10 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "RT-CHARGED" USING WS-PLAYER WS-ONE WS-CHARGED
     MOVE "acceptance US14 25 part 7 9.4 Multishot loads 3 projectiles and uses one arrow (the extras are free)" TO WS-CASE
     MOVE 309 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-CHARGED * 100 + PL-SLOT-COUNT(WS-PLAYER, 5)
     PERFORM CHECK-N
     CALL "RT-CLEAR-TYPE" USING WS-ARROW-TYPE
     CALL "TEST-USE-ITEM" USING WS-CONN
     PERFORM FIND-THREE
     MOVE "acceptance US14 25 part 7 9.5 the three arrows leave at 0, -10 and +10 degrees about the up vector (x velocity about 0, -0.55, +0.55)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-COUNT = 3 AND EN-VX(WS-ROW1) > -0.12 AND EN-VX(WS-ROW1) < 0.12
             AND EN-VX(WS-ROW2) > -0.67 AND EN-VX(WS-ROW2) < -0.43
             AND EN-VX(WS-ROW3) > 0.43 AND EN-VX(WS-ROW3) < 0.67
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US14 25 part 7 9.5 the first arrow can be picked up, the two free copies only by a creative player (modes 1, 2, 2)" TO WS-CASE
     MOVE 122 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-ARR-PICKUP(WS-ROW1) * 100 + EN-ARR-PICKUP(WS-ROW2) * 10 + EN-ARR-PICKUP(WS-ROW3)
     PERFORM CHECK-N
     CALL "RT-DAMAGE" USING WS-PLAYER WS-ONE WS-DAMAGE
     MOVE "acceptance US14 25 part 7 9.5 three arrows cost the crossbow 3 durability" TO WS-CASE
     MOVE 3 TO WS-EXPECT
     MOVE WS-DAMAGE TO WS-OBSERVE
     PERFORM CHECK-N

*>   Piercing II is carried to the arrow.
     PERFORM FRESH-SLOTS
     MOVE 3 TO WS-THREE
     MOVE "minecraft:quick_charge" TO WS-ENCH-KEY
     CALL "RT-ENCHANT" USING WS-PLAYER WS-ONE WS-ENCH-KEY WS-THREE
     MOVE "minecraft:piercing" TO WS-ENCH-KEY
     MOVE 2 TO WS-THREE
     CALL "RT-ENCHANT" USING WS-PLAYER WS-ONE WS-ENCH-KEY WS-THREE
     CALL "TEST-USE-ITEM" USING WS-CONN
     MOVE 10 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "RT-CLEAR-TYPE" USING WS-ARROW-TYPE
     CALL "TEST-USE-ITEM" USING WS-CONN
     CALL "RT-COUNT" USING WS-ARROW-TYPE WS-COUNT WS-ROW
     MOVE "acceptance US14 17 3.9 Piercing II: the arrow's pierce level is 2" TO WS-CASE
     MOVE 2 TO WS-EXPECT
     MOVE EN-ARR-PIERCE(WS-ROW) TO WS-OBSERVE
     PERFORM CHECK-N

*>   A firework rocket from the off hand: charged, used up, shot at 1.6, 3 durability.
     PERFORM FRESH-SLOTS
     MOVE "firework_rocket" TO WS-KEY
     CALL "RT-ITEM-ID" USING WS-KEY MN-EQUIP-ITEM(WS-PLAYER, 5)
     MOVE 2 TO MN-EQUIP-COUNT(WS-PLAYER, 5)
     MOVE 0 TO MN-EQUIP-VAR(WS-PLAYER, 5)
     CALL "TEST-USE-ITEM" USING WS-CONN
     MOVE 25 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "RT-CHARGED" USING WS-PLAYER WS-ONE WS-CHARGED
     MOVE "acceptance US14 17 3.9 a firework rocket in the off hand is loaded first: charged, 2 rockets become 1, the arrows stay 10" TO WS-CASE
     MOVE 1110 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-CHARGED * 1000 + MN-EQUIP-COUNT(WS-PLAYER, 5) * 100 + PL-SLOT-COUNT(WS-PLAYER, 5)
     PERFORM CHECK-N
     CALL "RT-CLEAR-TYPE" USING WS-ROCKET-TYPE
     CALL "TEST-USE-ITEM" USING WS-CONN
     CALL "RT-COUNT" USING WS-ROCKET-TYPE WS-COUNT WS-ROW
     MOVE "acceptance US14 17 3.9 the crossbow shoots a firework rocket entity at 1.6 (millis 1500 to 1700)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-COUNT = 1
         COMPUTE WS-SPEED = FUNCTION INTEGER(FUNCTION SQRT(EN-VX(WS-ROW) * EN-VX(WS-ROW) + EN-VY(WS-ROW) * EN-VY(WS-ROW)
             + EN-VZ(WS-ROW) * EN-VZ(WS-ROW)) * 1000)
         IF WS-SPEED >= 1500 AND WS-SPEED <= 1700
             MOVE 1 TO WS-OBSERVE
         END-IF
     END-IF
     PERFORM CHECK-N
     CALL "RT-DAMAGE" USING WS-PLAYER WS-ONE WS-DAMAGE
     MOVE "acceptance US14 17 3.9 a firework rocket costs the crossbow 3 durability" TO WS-CASE
     MOVE 3 TO WS-EXPECT
     MOVE WS-DAMAGE TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 0 TO MN-EQUIP-COUNT(WS-PLAYER, 5)

*>   The arrows are gone when the charge completes: nothing is loaded. The held slot changed: the use is over.
     PERFORM FRESH-SLOTS
     CALL "TEST-USE-ITEM" USING WS-CONN
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 5)
     MOVE 30 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "RT-CHARGED" USING WS-PLAYER WS-ONE WS-CHARGED
     MOVE "acceptance US14 25 part 7 9.3 the ammunition gone by the end of the charge: the crossbow stays empty" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-CHARGED TO WS-OBSERVE
     PERFORM CHECK-N
     PERFORM FRESH-SLOTS
     CALL "TEST-USE-ITEM" USING WS-CONN
     MOVE 1 TO PL-HELD(WS-PLAYER)
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 0 TO PL-HELD(WS-PLAYER)
     MOVE 30 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "RT-CHARGED" USING WS-PLAYER WS-ONE WS-CHARGED
     MOVE "acceptance US14 25 part 7 9.3 changing the held slot ends the charge: nothing is loaded when the slot is held again" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-CHARGED TO WS-OBSERVE
     PERFORM CHECK-N

*>   Creative without ammunition: loads a free arrow, nothing is used up, no durability.
     PERFORM FRESH-SLOTS
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 5)
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "TEST-USE-ITEM" USING WS-CONN
     MOVE 25 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "RT-CHARGED" USING WS-PLAYER WS-ONE WS-CHARGED
     CALL "RT-CLEAR-TYPE" USING WS-ARROW-TYPE
     CALL "TEST-USE-ITEM" USING WS-CONN
     CALL "RT-COUNT" USING WS-ARROW-TYPE WS-COUNT WS-ROW
     CALL "RT-DAMAGE" USING WS-PLAYER WS-ONE WS-DAMAGE
     MOVE "acceptance US14 25 part 7 9.1 a creative player without ammunition charges, shoots a free arrow (mode 2) and the crossbow takes no damage" TO WS-CASE
     MOVE 1120 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-CHARGED * 1000 + WS-COUNT * 100 + EN-ARR-PICKUP(WS-ROW) * 10 + WS-DAMAGE
     PERFORM CHECK-N
     MOVE 0 TO PL-MODE(WS-PLAYER)

*>   A survival player without ammunition cannot start charging.
     PERFORM FRESH-SLOTS
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 5)
     CALL "TEST-USE-ITEM" USING WS-CONN
     MOVE 40 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "RT-CHARGED" USING WS-PLAYER WS-ONE WS-CHARGED
     MOVE "acceptance US14 17 3.9 without a projectile a survival player cannot charge: nothing loaded" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-CHARGED TO WS-OBSERVE
     PERFORM CHECK-N
     STOP RUN.

*> A fresh crossbow in slot 1, ten arrows in slot 5, the player in survival.
 FRESH-SLOTS.
     CALL "RT-CLEAR-SLOTS" USING WS-PLAYER
     MOVE "crossbow" TO WS-KEY
     CALL "RT-GIVE1" USING WS-PLAYER WS-KEY WS-ONE
     MOVE "arrow" TO WS-KEY
     CALL "RT-GIVE" USING WS-PLAYER WS-FIVE WS-KEY WS-TEN
     MOVE 0 TO MN-EQUIP-COUNT(WS-PLAYER, 5)
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "RT-CLEAR-TYPE" USING WS-ARROW-TYPE
     CALL "RT-CLEAR-TYPE" USING WS-ROCKET-TYPE.

*> The three arrows in spawn order (rows ascending): WS-ROW1 to WS-ROW3 and WS-COUNT.
 FIND-THREE.
     MOVE 0 TO WS-COUNT WS-ROW1 WS-ROW2 WS-ROW3
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-TYPE(WS-ROW) = WS-ARROW-TYPE
             ADD 1 TO WS-COUNT
             EVALUATE WS-COUNT
                 WHEN 1
                     MOVE WS-ROW TO WS-ROW1
                 WHEN 2
                     MOVE WS-ROW TO WS-ROW2
                 WHEN 3
                     MOVE WS-ROW TO WS-ROW3
             END-EVALUATE
         END-IF
     END-PERFORM.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US14-CROSSBOW.
 COPY CORETEST.
 COPY RANGEDTEST.
