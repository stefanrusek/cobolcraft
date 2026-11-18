*> Acceptance test (US14; docs/protocol/17 section 3.9 bow, 6.3 Power, Flame, Infinity, 5.1 durability): the bow through the real play path. Use Item (0x43) with a
*> bow starts the draw when the player has ammunition (off hand first, then the inventory in slot order) or infinite materials; Player Action RELEASE_USE_ITEM
*> (6) after t ticks shoots an arrow of power p = min((f f + 2 f) / 3, 1), f = t / 20, at velocity 3.0 p along the look direction from the eye (1.62 - 0.1 above the
*> feet), a critical arrow at p = 1.0 only; below p 0.1 nothing is shot and nothing used; the arrow, the bow's one durability and the creative rules follow.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-BOW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CTOOLS.
 COPY CMENU.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-ARROW-TYPE          BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-SIX                 BINARY-LONG VALUE 6.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-TICKS               BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-ENCH-KEY            PIC X(112).
 01 WS-ENCH-ID             BINARY-LONG.
 01 WS-SPEED               BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-DX                  FLOAT-LONG VALUE 0.
 01 WS-DZ                  FLOAT-LONG VALUE 3.
 01 WS-COW                 BINARY-LONG.
 01 WS-HEALTH0             BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "RT-OPEN" USING WS-PLAYER WS-CONN WS-FLOOR WS-CX WS-CZ
     MOVE "arrow" TO WS-KEY
     CALL "RT-ENTITY-ID" USING WS-KEY WS-ARROW-TYPE
     MOVE 0 TO PL-YAW(WS-PLAYER) PL-PITCH(WS-PLAYER)
     MOVE "bow" TO WS-KEY
     CALL "RT-GIVE" USING WS-PLAYER WS-ONE WS-KEY WS-ONE
     MOVE "arrow" TO WS-KEY
     CALL "RT-GIVE" USING WS-PLAYER WS-FIVE WS-KEY WS-TEN
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS

*>   Full draw: 20 ticks.
     MOVE 20 TO WS-TICKS
     PERFORM DRAW-AND-RELEASE
     MOVE "acceptance US14 17 3.9 a bow drawn 20 ticks shoots exactly one arrow" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-COUNT TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US14 17 3.9 full power: velocity 3.0 within the 1.0 inaccuracy spread, aimed along +z (millis 2900 to 3100)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     COMPUTE WS-SPEED = FUNCTION INTEGER(FUNCTION SQRT(EN-VX(WS-ROW) * EN-VX(WS-ROW) + EN-VY(WS-ROW) * EN-VY(WS-ROW)
         + EN-VZ(WS-ROW) * EN-VZ(WS-ROW)) * 1000)
     IF WS-SPEED >= 2900 AND WS-SPEED <= 3100 AND EN-VZ(WS-ROW) > 2.8
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US14 17 3.9 the arrow starts at the eye less 0.1 (1.52 above the feet, millimetres) at the player's x and z" TO WS-CASE
     COMPUTE WS-EXPECT = FUNCTION INTEGER(PL-Y(WS-PLAYER) * 1000 + 1520.5)
     COMPUTE WS-OBSERVE = FUNCTION INTEGER(EN-Y(WS-ROW) * 1000 + 0.5)
     PERFORM CHECK-N
     MOVE "acceptance US14 17 3.9 the shooter owns the arrow and full power makes it critical" TO WS-CASE
     COMPUTE WS-EXPECT = PL-ENTITY-ID(WS-PLAYER) * 10 + 1
     COMPUTE WS-OBSERVE = EN-TARGET-ID(WS-ROW) * 10 + EN-ARR-CRIT(WS-ROW)
     PERFORM CHECK-N
     MOVE "acceptance US14 17 3.9 survival: one arrow of ten is used up" TO WS-CASE
     MOVE 9 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 5) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE PL-SLOT-VAR(WS-PLAYER, 1) TO WS-HANDLE
     CALL "SP-GET-DAMAGE" USING PL-SLOT-ITEM(WS-PLAYER, 1) WS-HANDLE WS-DAMAGE
     MOVE "acceptance US14 17 3.9 the bow takes one durability per shot" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-DAMAGE TO WS-OBSERVE
     PERFORM CHECK-N

*>   A 5 tick draw: f = 0.25, p = (f f + 2 f) / 3 = 0.1875, velocity 0.5625, not critical (the draw table of 17 section 3.9 lists p 0.2917 and 0.6458 for
*>   t = 5 and t = 15, which its own formula does not give; the formula agrees with the t = 10 and t = 20 rows).
     MOVE 5 TO WS-TICKS
     PERFORM DRAW-AND-RELEASE
     COMPUTE WS-SPEED = FUNCTION INTEGER(FUNCTION SQRT(EN-VX(WS-ROW) * EN-VX(WS-ROW) + EN-VY(WS-ROW) * EN-VY(WS-ROW)
         + EN-VZ(WS-ROW) * EN-VZ(WS-ROW)) * 1000)
     MOVE "acceptance US14 17 3.9 a 5 tick draw: velocity 0.5625 within the spread (millis 540 to 590), not critical, second arrow used" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-SPEED >= 540 AND WS-SPEED <= 590 AND EN-ARR-CRIT(WS-ROW) = 0 AND PL-SLOT-COUNT(WS-PLAYER, 5) = 8
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N

*>   Below power 0.1: nothing.
     MOVE 2 TO WS-TICKS
     PERFORM DRAW-AND-RELEASE
     MOVE "acceptance US14 17 3.9 a 2 tick draw (power 0.07) shoots nothing and uses nothing: no new arrow, still 8 arrows" TO WS-CASE
     MOVE 8 TO WS-EXPECT
     COMPUTE WS-OBSERVE = PL-SLOT-COUNT(WS-PLAYER, 5) + WS-COUNT * 100
     PERFORM CHECK-N

*>   The off hand is searched first.
     MOVE "spectral_arrow" TO WS-KEY
     MOVE 2 TO MN-EQUIP-COUNT(WS-PLAYER, 5)
     CALL "RT-ITEM-ID" USING WS-KEY MN-EQUIP-ITEM(WS-PLAYER, 5)
     MOVE 0 TO MN-EQUIP-VAR(WS-PLAYER, 5)
     MOVE 20 TO WS-TICKS
     PERFORM DRAW-AND-RELEASE
     MOVE "acceptance US14 17 3.9 the off hand's spectral arrows go first: 2 become 1, the inventory arrows stay 8" TO WS-CASE
     MOVE 108 TO WS-EXPECT
     COMPUTE WS-OBSERVE = MN-EQUIP-COUNT(WS-PLAYER, 5) * 100 + PL-SLOT-COUNT(WS-PLAYER, 5)
     PERFORM CHECK-N
     MOVE 0 TO MN-EQUIP-COUNT(WS-PLAYER, 5)

*>   Infinity: arrows are not used (an arrow exactly).
     MOVE "minecraft:infinity" TO WS-ENCH-KEY
     CALL "TOOL-ENCHANT-ID" USING WS-ENCH-KEY WS-ENCH-ID
     MOVE PL-SLOT-VAR(WS-PLAYER, 1) TO WS-HANDLE
     CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-ENCH-ID WS-ONE
     MOVE WS-HANDLE TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 20 TO WS-TICKS
     PERFORM DRAW-AND-RELEASE
     MOVE "acceptance US14 17 3.9 a bow with Infinity shoots without using an arrow (8 stay)" TO WS-CASE
     MOVE 8 TO WS-EXPECT
     MOVE PL-SLOT-COUNT(WS-PLAYER, 5) TO WS-OBSERVE
     PERFORM CHECK-N

*>   Flame ignites the arrow for 100 ticks.
     MOVE "minecraft:flame" TO WS-ENCH-KEY
     CALL "TOOL-ENCHANT-ID" USING WS-ENCH-KEY WS-ENCH-ID
     MOVE PL-SLOT-VAR(WS-PLAYER, 1) TO WS-HANDLE
     CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-ENCH-ID WS-ONE
     MOVE WS-HANDLE TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 20 TO WS-TICKS
     PERFORM DRAW-AND-RELEASE
     MOVE "acceptance US14 17 3.9 Flame: the arrow burns for 100 ticks" TO WS-CASE
     MOVE 100 TO WS-EXPECT
     MOVE EN-BURN(WS-ROW) TO WS-OBSERVE
     PERFORM CHECK-N

*>   Power I adds 1.0 to the base damage of 2.0 (17 section 6.3): 3000 thousandths.
     MOVE "minecraft:power" TO WS-ENCH-KEY
     CALL "TOOL-ENCHANT-ID" USING WS-ENCH-KEY WS-ENCH-ID
     MOVE PL-SLOT-VAR(WS-PLAYER, 1) TO WS-HANDLE
     CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-ENCH-ID WS-ONE
     MOVE WS-HANDLE TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 20 TO WS-TICKS
     PERFORM DRAW-AND-RELEASE
     MOVE "acceptance US14 17 3.9 Power I: base damage 2.0 + 1.0" TO WS-CASE
     MOVE 3000 TO WS-EXPECT
     MOVE EN-ITEM(WS-ROW) TO WS-OBSERVE
     PERFORM CHECK-N

*>   Creative: no ammunition needed, nothing used, no durability, pickup only creative.
     MOVE 1 TO PL-MODE(WS-PLAYER)
     PERFORM VARYING WS-COUNT FROM 2 BY 1 UNTIL WS-COUNT > 36
         MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, WS-COUNT)
     END-PERFORM
     MOVE PL-SLOT-VAR(WS-PLAYER, 1) TO WS-HANDLE
     CALL "SP-GET-DAMAGE" USING PL-SLOT-ITEM(WS-PLAYER, 1) WS-HANDLE WS-DAMAGE
     MOVE 20 TO WS-TICKS
     PERFORM DRAW-AND-RELEASE
     MOVE "acceptance US14 17 3.9 a creative player without arrows still shoots: an arrow only creative players can pick up (mode 2)" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-COUNT = 1 AND EN-ARR-PICKUP(WS-ROW) = 2
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     MOVE PL-SLOT-VAR(WS-PLAYER, 1) TO WS-HANDLE
     MOVE WS-DAMAGE TO WS-EXPECT
     CALL "SP-GET-DAMAGE" USING PL-SLOT-ITEM(WS-PLAYER, 1) WS-HANDLE WS-DAMAGE
     MOVE "acceptance US14 5.1 a creative player's bow takes no durability damage" TO WS-CASE
     MOVE WS-DAMAGE TO WS-OBSERVE
     PERFORM CHECK-N

*>   Survival without any arrow cannot start drawing.
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 20 TO WS-TICKS
     PERFORM DRAW-AND-RELEASE
     MOVE "acceptance US14 17 3.9 a survival player without ammunition cannot draw: no arrow" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-COUNT TO WS-OBSERVE
     PERFORM CHECK-N

*>   The arrow flies on and hurts a cow in its way (damage = ceil(speed x 2.0), at least 6 at full power).
     MOVE "arrow" TO WS-KEY
     CALL "RT-GIVE" USING WS-PLAYER WS-FIVE WS-KEY WS-TEN
     MOVE "cow" TO WS-KEY
     CALL "RT-SPAWN-MOB" USING WS-PLAYER WS-KEY WS-DX WS-DZ WS-COW
     MOVE EN-HEALTH(WS-COW) TO WS-HEALTH0
     MOVE 5 TO PL-PITCH(WS-PLAYER)
     MOVE 20 TO WS-TICKS
     PERFORM DRAW-AND-RELEASE
     MOVE 6 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "acceptance US14 17 3.9 the arrow reaches the cow three blocks ahead, hurts it by at least 6 and is gone" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     CALL "RT-COUNT" USING WS-ARROW-TYPE WS-COUNT WS-ROW
     IF WS-HEALTH0 - EN-HEALTH(WS-COW) >= 6 AND WS-COUNT = 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
     STOP RUN.

*> Remove the arrows, Use Item, WS-TICKS ticks of draw, release; WS-COUNT arrows now exist and WS-ROW is the last.
 DRAW-AND-RELEASE.
     CALL "RT-COUNT" USING WS-ARROW-TYPE WS-COUNT WS-ROW
     PERFORM UNTIL WS-COUNT = 0
         CALL "ENTITY-REMOVE" USING WS-ROW
         CALL "RT-COUNT" USING WS-ARROW-TYPE WS-COUNT WS-ROW
     END-PERFORM
     CALL "TEST-USE-ITEM" USING WS-CONN
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-ACTION" USING WS-CONN WS-SIX WS-ZERO WS-ZERO WS-ZERO WS-ZERO WS-ZERO
     CALL "RT-COUNT" USING WS-ARROW-TYPE WS-COUNT WS-ROW
*>   No arrow: row 1 stands in so that the cases below fail instead of reading outside the table.
     IF WS-COUNT = 0
         MOVE 1 TO WS-ROW
     END-IF.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US14-BOW.
 COPY CORETEST.
 COPY RANGEDTEST.
