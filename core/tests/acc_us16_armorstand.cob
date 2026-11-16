*> Acceptance test, the armor stand (docs/protocol/44 part 9 section 4; lane 002-lane-mobsb6, T9009): default poses, the placement yaw (multiples of 45 degrees), the clicked slot by height, swapping
*> equipment (put, take, creative copy, disabled slots, arms hidden hand slots, split), and the hit rules (the second hit within 5 ticks breaks it and pops the stand and its equipment, a first hit
*> only wobbles it, creative breaks without drops, a marker or an invisible stand ignores hits).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US16-ARMORSTAND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-HELMET              BINARY-LONG.
 01 WS-STAND-ITEM          BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-OUT                 FLOAT-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-HITY                FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:diamond_helmet" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-HELMET WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:armor_stand" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STAND-ITEM WS-ITEM-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = PL-Y(WS-PLAYER) + 20
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE 0 TO WS-YAW
     CALL "ARMOR-STAND-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE "acceptance US16 44-9 4.1 the left arm pose is (-10, 0, -10) and the right leg (1, 0, 1)" TO TL-CASE
     MOVE -9999 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PJ-POSE(WS-SLOT, 7) * 1000 + PJ-POSE(WS-SLOT, 16)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-YAW
     CALL "ARMOR-STAND-YAW" USING WS-YAW WS-OUT
     MOVE "acceptance US16 44-9 4.2 a player facing yaw 0 places the stand at yaw -180" TO TL-CASE
     MOVE -180 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-OUT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 100 TO WS-YAW
     CALL "ARMOR-STAND-YAW" USING WS-YAW WS-OUT
     MOVE "acceptance US16 44-9 4.2 yaw 100 snaps to -90 (floor((wrap(-80) + 22.5) / 45) x 45)" TO TL-CASE
     MOVE -90 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-OUT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Clicked slots: nothing worn gives the main hand; a worn head gives HEAD above 1.6.
     MOVE 1.7 TO WS-HITY
     CALL "ARMOR-STAND-SLOT" USING WS-ROW WS-HITY WS-S
     MOVE "acceptance US16 44-9 4.3 with nothing worn a click at 1.7 is the main hand (0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-S TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-HELMET TO PJ-EQ(WS-SLOT, 5)
     CALL "ARMOR-STAND-SLOT" USING WS-ROW WS-HITY WS-S
     MOVE "acceptance US16 44-9 4.3 with a helmet a click at 1.7 is the head (4)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-S TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-HELMET TO PJ-EQ(WS-SLOT, 2)
     MOVE 0.2 TO WS-HITY
     CALL "ARMOR-STAND-SLOT" USING WS-ROW WS-HITY WS-S
     MOVE "acceptance US16 44-9 4.3 with boots a click at 0.2 is the feet (1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-S TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-HELMET TO PJ-EQ(WS-SLOT, 4)
     MOVE 1.0 TO WS-HITY
     CALL "ARMOR-STAND-SLOT" USING WS-ROW WS-HITY WS-S
     MOVE "acceptance US16 44-9 4.3 with a chestplate a click at 1.0 is the chest (3)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-S TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-HELMET TO PJ-EQ(WS-SLOT, 3)
     MOVE 0.7 TO WS-HITY
     CALL "ARMOR-STAND-SLOT" USING WS-ROW WS-HITY WS-S
     MOVE "acceptance US16 44-9 4.3 with legs worn a click at 0.7 is the legs (2) (feet end at 0.55)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-S TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PJ-EQ(WS-SLOT, 2) PJ-EQ(WS-SLOT, 3) PJ-EQ(WS-SLOT, 4) PJ-EQ(WS-SLOT, 5)
*>   Put a helmet on with a full hand: the stand wears it, the survival stack loses it.
     COMPUTE WS-HELD = PL-HELD(WS-PLAYER) + 1
     MOVE WS-HELMET TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
     MOVE 1.7 TO WS-HITY
     CALL "ARMOR-STAND-INTERACT" USING WS-ROW WS-PLAYER WS-HITY WS-DONE
     MOVE "acceptance US16 44-9 4.3 a helmet in hand goes to the head slot and the hand is empty" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PJ-EQ(WS-SLOT, 5) = WS-HELMET AND PL-SLOT-COUNT(WS-PLAYER, WS-HELD) = 0 AND WS-DONE = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   An empty hand takes it back.
     CALL "ARMOR-STAND-INTERACT" USING WS-ROW WS-PLAYER WS-HITY WS-DONE
     MOVE "acceptance US16 44-9 4.3 an empty hand clicking the head takes the helmet" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PJ-EQ(WS-SLOT, 5) = 0 AND PL-SLOT-ITEM(WS-PLAYER, WS-HELD) = WS-HELMET AND PL-SLOT-COUNT(WS-PLAYER, WS-HELD) = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A disabled slot refuses (disabled bit 4 = the head slot id 4: bit 16 of 2**4).
     MOVE 16 TO PJ-I2(WS-SLOT)
     CALL "ARMOR-STAND-INTERACT" USING WS-ROW WS-PLAYER WS-HITY WS-DONE
     MOVE "acceptance US16 44-9 4.3 a disabled head slot refuses the helmet (still in hand)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PJ-EQ(WS-SLOT, 5) = 0 AND PL-SLOT-COUNT(WS-PLAYER, WS-HELD) = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PJ-I2(WS-SLOT)
*>   A hand item with arms hidden is refused (main hand slot, arms flag 4 unset).
     MOVE WS-STAND-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD)
     CALL "ARMOR-STAND-INTERACT" USING WS-ROW WS-PLAYER WS-HITY WS-DONE
     MOVE "acceptance US16 44-9 4.3 a main hand item is refused while the arms are hidden" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PJ-EQ(WS-SLOT, 1) = 0 AND PL-SLOT-COUNT(WS-PLAYER, WS-HELD) = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO PJ-I1(WS-SLOT)
     CALL "ARMOR-STAND-INTERACT" USING WS-ROW WS-PLAYER WS-HITY WS-DONE
     MOVE "acceptance US16 44-9 4.3 with arms shown the main hand slot takes it" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PJ-EQ(WS-SLOT, 1) = WS-STAND-ITEM
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Splitting: a stack of 3 puts one into an empty slot (a worn slot refuses it).
     MOVE 0 TO PJ-EQ(WS-SLOT, 1)
     MOVE WS-STAND-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-HELD)
     MOVE 3 TO PL-SLOT-COUNT(WS-PLAYER, WS-HELD)
     CALL "ARMOR-STAND-INTERACT" USING WS-ROW WS-PLAYER WS-HITY WS-DONE
     MOVE "acceptance US16 44-9 4.3 a stack of 3 leaves 2 in the hand" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-PLAYER, WS-HELD) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 44-9 4.3 and the stand holds one" TO TL-CASE
     MOVE WS-STAND-ITEM TO TL-EXPECTED-N
     MOVE PJ-EQ(WS-SLOT, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Creative copy: an infinite materials player puts one copy and keeps the stack.
     MOVE 0 TO PJ-EQ(WS-SLOT, 1)
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "ARMOR-STAND-INTERACT" USING WS-ROW WS-PLAYER WS-HITY WS-DONE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE "acceptance US16 44-9 4.3 a creative player puts a copy and keeps the stack of 2" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PJ-EQ(WS-SLOT, 1) = WS-STAND-ITEM AND PL-SLOT-COUNT(WS-PLAYER, WS-HELD) = 2
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Hits: the first wobbles, the second within 5 ticks breaks and pops the stand and its equipment.
     MOVE WS-HELMET TO PJ-EQ(WS-SLOT, 5)
     MOVE 1000 TO CW-TICKS
     MOVE 0 TO WS-DONE
     CALL "ARMOR-STAND-HIT" USING WS-ROW WS-PLAYER WS-DONE
     MOVE "acceptance US16 44-9 4.4 the first hit only wobbles the stand (it stays)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM-COUNT(WS-I) > 0
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE WS-N TO WS-S
     MOVE 1004 TO CW-TICKS
     CALL "ARMOR-STAND-HIT" USING WS-ROW WS-PLAYER WS-DONE
     MOVE "acceptance US16 44-9 4.4 a second hit 4 ticks later breaks it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM-COUNT(WS-I) > 0
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US16 44-9 4.4 breaking pops three items (the stand, the helmet and the main hand copy)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-N - WS-S
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Slow second hit, marker, invisible and creative.
     CALL "ARMOR-STAND-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
     MOVE 2000 TO CW-TICKS
     CALL "ARMOR-STAND-HIT" USING WS-ROW WS-PLAYER WS-DONE
     MOVE 2010 TO CW-TICKS
     CALL "ARMOR-STAND-HIT" USING WS-ROW WS-PLAYER WS-DONE
     MOVE "acceptance US16 44-9 4.4 a second hit 10 ticks later only wobbles again" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 16 TO PJ-I1(WS-SLOT)
     MOVE 2011 TO CW-TICKS
     CALL "ARMOR-STAND-HIT" USING WS-ROW WS-PLAYER WS-DONE
     MOVE "acceptance US16 44-9 4.4 a marker stand ignores the hit" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DONE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PJ-I1(WS-SLOT)
     MOVE 1 TO PJ-I4(WS-SLOT)
     CALL "ARMOR-STAND-HIT" USING WS-ROW WS-PLAYER WS-DONE
     MOVE "acceptance US16 44-9 4.4 an invisible stand ignores the hit" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DONE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PJ-I4(WS-SLOT)
     MOVE 1 TO PL-MODE(WS-PLAYER)
     CALL "ARMOR-STAND-HIT" USING WS-ROW WS-PLAYER WS-DONE
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE "acceptance US16 44-9 4.4 a creative player breaks it at once" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US16-ARMORSTAND.
 COPY CORETEST.
 COPY MOBSPTEST.
