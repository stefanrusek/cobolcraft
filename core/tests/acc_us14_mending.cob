*> Acceptance test (US14; docs/protocol/17 section 5.3 Mending, 21 section 8.2 orb pickup, 28 section 9.4 repair_with_xp): an experience orb through the real tick. An orb touching the player
*> repairs one damaged item that has Mending (the main hand, the off hand or the worn armor) before it gives experience: xp x 2 durability, repaired = min(durability, damage), the remainder
*> xp - repaired x xp / durability goes to the player's experience. A pickaxe with 4 damage and an orb of 5: repaired 4, the player gets 3 (the worked example of 28 section 11 item 5); an undamaged
*> item with Mending is not repaired and the player gets the whole orb; an item without Mending is left alone.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-MENDING.
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
 01 WS-ENCH-KEY            PIC X(112).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TICKS               BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-ORB                 BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-XP0                 BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "RT-OPEN" USING WS-PLAYER WS-CONN WS-FLOOR WS-CX WS-CZ
     CALL "RT-CLEAR-SLOTS" USING WS-PLAYER

*>   A pickaxe with 4 damage and Mending in the main hand.
     MOVE "diamond_pickaxe" TO WS-KEY
     CALL "RT-GIVE" USING WS-PLAYER WS-ONE WS-KEY WS-ONE
     MOVE "minecraft:mending" TO WS-ENCH-KEY
     CALL "RT-ENCHANT" USING WS-PLAYER WS-ONE WS-ENCH-KEY WS-ONE
     MOVE 4 TO WS-DAMAGE
     MOVE PL-SLOT-VAR(WS-PLAYER, 1) TO WS-HANDLE
     CALL "SP-SET-DAMAGE" USING WS-HANDLE WS-DAMAGE
     MOVE WS-HANDLE TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE PL-XP-TOTAL(WS-PLAYER) TO WS-XP0
     PERFORM DROP-ORB
     CALL "RT-DAMAGE" USING WS-PLAYER WS-ONE WS-DAMAGE
     MOVE "acceptance US14 17 5.3 an orb of 5 mends the 4 damage of a Mending pickaxe in the main hand" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-DAMAGE TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE "acceptance US14 17 5.3 the remainder 5 - 4 x 5 / 10 = 3 goes to the player's experience" TO WS-CASE
     MOVE 3 TO WS-EXPECT
     COMPUTE WS-OBSERVE = PL-XP-TOTAL(WS-PLAYER) - WS-XP0
     PERFORM CHECK-N

*>   Undamaged, nothing to mend: the whole orb is experience.
     MOVE PL-XP-TOTAL(WS-PLAYER) TO WS-XP0
     PERFORM DROP-ORB
     MOVE "acceptance US14 17 5.3 an undamaged Mending pickaxe is not repaired: the orb gives all 5 points" TO WS-CASE
     MOVE 5 TO WS-EXPECT
     COMPUTE WS-OBSERVE = PL-XP-TOTAL(WS-PLAYER) - WS-XP0
     PERFORM CHECK-N

*>   Without Mending the damage stays.
     CALL "RT-CLEAR-SLOTS" USING WS-PLAYER
     CALL "RT-GIVE" USING WS-PLAYER WS-ONE WS-KEY WS-ONE
     MOVE 4 TO WS-DAMAGE
     MOVE PL-SLOT-VAR(WS-PLAYER, 1) TO WS-HANDLE
     CALL "SP-SET-DAMAGE" USING WS-HANDLE WS-DAMAGE
     MOVE WS-HANDLE TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE PL-XP-TOTAL(WS-PLAYER) TO WS-XP0
     PERFORM DROP-ORB
     CALL "RT-DAMAGE" USING WS-PLAYER WS-ONE WS-DAMAGE
     MOVE "acceptance US14 17 5.3 a damaged pickaxe without Mending keeps its 4 damage and the orb gives 5 points" TO WS-CASE
     MOVE 405 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-DAMAGE * 100 + PL-XP-TOTAL(WS-PLAYER) - WS-XP0
     PERFORM CHECK-N

*>   An orb of 5 repairs at most 10 durability (xp x 2): 30 damage becomes 20 and nothing is left over.
     CALL "RT-CLEAR-SLOTS" USING WS-PLAYER
     CALL "RT-GIVE" USING WS-PLAYER WS-ONE WS-KEY WS-ONE
     CALL "RT-ENCHANT" USING WS-PLAYER WS-ONE WS-ENCH-KEY WS-ONE
     MOVE 30 TO WS-DAMAGE
     MOVE PL-SLOT-VAR(WS-PLAYER, 1) TO WS-HANDLE
     CALL "SP-SET-DAMAGE" USING WS-HANDLE WS-DAMAGE
     MOVE WS-HANDLE TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE PL-XP-TOTAL(WS-PLAYER) TO WS-XP0
     MOVE 5 TO WS-VALUE
     PERFORM DROP-ORB
     CALL "RT-DAMAGE" USING WS-PLAYER WS-ONE WS-DAMAGE
     MOVE "acceptance US14 17 5.3 an orb of 5 repairs at most 10 of 30 damage and leaves the player nothing: damage 20, experience +0" TO WS-CASE
     MOVE 2000 TO WS-EXPECT
     COMPUTE WS-OBSERVE = WS-DAMAGE * 100 + PL-XP-TOTAL(WS-PLAYER) - WS-XP0
     PERFORM CHECK-N
     STOP RUN.

*> An orb of WS-VALUE (5 unless set) at the player's feet, then ticks until it is taken.
 DROP-ORB.
     IF WS-VALUE = 0
         MOVE 5 TO WS-VALUE
     END-IF
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "XP-ORB-SPAWN" USING PL-DIM(WS-PLAYER) WS-X WS-Y WS-Z WS-VALUE WS-ORB
     MOVE 5 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US14-MENDING.
 COPY CORETEST.
 COPY RANGEDTEST.
