*> Acceptance test, the fishing bobber (docs/protocol/17 section 3.11, 44 part 8 section 10.1; lane 002-lane-mobsb6, T9004): the cast (start 0.3 behind the eye line, launch 0.6 / len + 0.5 per component), the
*> owner check (a rod in the main hand within 32 blocks), the bite timer states (nibble count down, fish on its way, lured, waiting 100 to 600 minus the Lure term, nibble 20 to 40), the retrieve
*> costs (3.11) and the loot (items toward the player and 1 to 6 experience).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US16-FISHING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PLAYPKT.
 COPY PROJSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROD-ITEM            BINARY-LONG.
 01 WS-STICK-ITEM          BINARY-LONG.
 01 WS-BOBBER-TYPE         BINARY-LONG.
 01 WS-ORB-TYPE            BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PJ                  BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 96.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-COST                BINARY-LONG.
 01 WS-ITEMS               BINARY-LONG.
 01 WS-ORBS                BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG VALUE 1.
 01 WS-LURE                BINARY-LONG VALUE 0.
 01 WS-YAW                 FLOAT-LONG VALUE 0.
 01 WS-PITCH               FLOAT-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Y0 = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-X0 - 48
     COMPUTE WS-FZ = WS-Z0 - 48
     COMPUTE WS-GY = WS-Y0 - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-GY WS-KIND
     MOVE 0 TO WS-CONN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CORE-MAX-CONNS
         IF CN-PLAYER(WS-I) = WS-PLAYER
             MOVE WS-I TO WS-CONN
         END-IF
     END-PERFORM
     MOVE "minecraft:fishing_rod" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ROD-ITEM WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:stick" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STICK-ITEM WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:fishing_bobber" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-BOBBER-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:experience_orb" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ORB-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     COMPUTE WS-SLOT = PL-HELD(WS-PLAYER) + 1
     MOVE WS-ROD-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-SLOT)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, WS-SLOT)
     MOVE 0 TO PSB-HAND PSB-YAW PSB-PITCH
*>   The cast: yaw 0, pitch 0 gives v = (0, 0, 1) x (0.6 + 0.5) and starts 0.3 in front.
     CALL "THROWN-ITEM-USE" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-BOBBER-TYPE
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM
     MOVE "acceptance US16 17 3.11 a fishing rod cast makes a bobber (kind 7)" TO TL-CASE
     MOVE 107 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ROW > 0
         CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-PJ
         COMPUTE TL-OBSERVED-N = WS-DONE * 100 + PJ-KIND(WS-PJ)
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 17 3.11 it starts 0.3 in front at the eye height (z, millimetres)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = FUNCTION INTEGER(PL-Z(WS-PLAYER) * 1000 + 300.5)
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(EN-Z(WS-ROW) * 1000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 17 3.11 the launch is 1.1 along z (thousandths)" TO TL-CASE
     MOVE 1100 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VZ(WS-ROW) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "THROWN-ITEM-USE" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     MOVE "acceptance US16 17 3.11 using the rod again retrieves the hook (gone)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The flight ends on the floor: the hook stops at the block (velocity 0).
     MOVE 45 TO PSB-PITCH
     CALL "THROWN-ITEM-USE" USING WS-CONN PLAY-SERVERBOUND WS-DONE
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-BOBBER-TYPE
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         CALL "THROWN-TICK"
     END-PERFORM
     MOVE "acceptance US16 17 3.11 a hook cast at the floor rests on it with no velocity" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (EN-VX(WS-ROW) + EN-VY(WS-ROW) + EN-VZ(WS-ROW)) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-PJ
     MOVE "acceptance US16 17 3.11 the resting hook counts its life on the ground" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PJ-I6(WS-PJ) > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "BOBBER-RETRIEVE" USING WS-PLAYER WS-ROW WS-COST
     MOVE "acceptance US16 17 3.11 retrieving a hook on the ground costs 2 durability" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-COST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A hook not held (the stick in hand) is removed by its tick.
     CALL "BOBBER-CAST" USING WS-PLAYER WS-YAW WS-PITCH WS-ROW
     MOVE WS-STICK-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-SLOT)
     CALL "THROWN-TICK"
     MOVE "acceptance US16 44-8 10.1 a hook whose owner holds no rod is discarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-ROD-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-SLOT)
*>   Far from the owner (over 32 blocks): discarded.
     CALL "BOBBER-CAST" USING WS-PLAYER WS-YAW WS-PITCH WS-ROW
     ADD 40 TO EN-X(WS-ROW)
     CALL "THROWN-TICK"
     MOVE "acceptance US16 44-8 10.1 a hook over 32 blocks away is discarded" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The bite timer, in a water cell.
     CALL "BOBBER-CAST" USING WS-PLAYER WS-YAW WS-PITCH WS-ROW
     CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-PJ
     COMPUTE WS-WX = WS-X0 + 4
     COMPUTE WS-WY = WS-Y0
     COMPUTE WS-WZ = WS-Z0
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-WX WS-WY WS-WZ WS-WATER
     COMPUTE EN-X(WS-ROW) = WS-WX + 0.5
     COMPUTE EN-Y(WS-ROW) = WS-WY + 0.4
     COMPUTE EN-Z(WS-ROW) = WS-WZ + 0.5
     MOVE 0 TO EN-VX(WS-ROW) EN-VY(WS-ROW) EN-VZ(WS-ROW)
     MOVE 2 TO PJ-I1(WS-PJ)
     MOVE 3 TO PJ-I5(WS-PJ)
     CALL "BOBBER-FISH" USING WS-ROW WS-PJ WS-AMOUNT
     CALL "BOBBER-FISH" USING WS-ROW WS-PJ WS-AMOUNT
     MOVE "acceptance US16 17 3.11 a nibble counts down by one per tick" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PJ-I5(WS-PJ) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "BOBBER-FISH" USING WS-ROW WS-PJ WS-AMOUNT
     MOVE "acceptance US16 17 3.11 at 0 the fish got away: lured, hooked and nibble are 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PJ-I5(WS-PJ) + PJ-I3(WS-PJ) + PJ-I4(WS-PJ)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "BOBBER-FISH" USING WS-ROW WS-PJ WS-AMOUNT
     MOVE "acceptance US16 17 3.11 waiting sets timeUntilLured to 100 to 600 (within the range, one tick later)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PJ-I3(WS-PJ) >= 100 AND PJ-I3(WS-PJ) <= 600
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PJ-I3(WS-PJ)
     CALL "BOBBER-FISH" USING WS-ROW WS-PJ WS-AMOUNT
     MOVE "acceptance US16 17 3.11 lured reaching 0 sets timeUntilHooked to 20 to 80" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PJ-I3(WS-PJ) = 0 AND PJ-I4(WS-PJ) >= 20 AND PJ-I4(WS-PJ) <= 80
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PJ-I4(WS-PJ)
     CALL "BOBBER-FISH" USING WS-ROW WS-PJ WS-AMOUNT
     MOVE "acceptance US16 17 3.11 the fish arriving sets nibble to 20 to 40" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PJ-I5(WS-PJ) >= 20 AND PJ-I5(WS-PJ) <= 40
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 40 TO PJ-I4(WS-PJ)
     MOVE 0 TO PJ-I5(WS-PJ)
     CALL "BOBBER-FISH" USING WS-ROW WS-PJ WS-AMOUNT
     MOVE "acceptance US16 17 3.11 a fish on its way counts timeUntilHooked down by the amount" TO TL-CASE
     MOVE 39 TO TL-EXPECTED-N
     MOVE PJ-I4(WS-PJ) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The Lure term shortens the wait.
     MOVE 0 TO PJ-I4(WS-PJ)
     MOVE 0 TO PJ-I3(WS-PJ)
     MOVE 3 TO PJ-I7(WS-PJ)
     CALL "BOBBER-FISH" USING WS-ROW WS-PJ WS-AMOUNT
     MOVE "acceptance US16 17 3.11 Lure III takes 300 off the wait (at most 300 after the tick)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PJ-I3(WS-PJ) <= 300
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Retrieving a biting fish pays 1 durability, gives loot and experience.
     MOVE 25 TO PJ-I5(WS-PJ)
     MOVE 0 TO WS-ITEMS WS-ORBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM-COUNT(WS-I) > 0
             ADD 1 TO WS-ITEMS
         END-IF
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-ORB-TYPE
             ADD 1 TO WS-ORBS
         END-IF
     END-PERFORM
     MOVE WS-ITEMS TO WS-I
     MOVE 0 TO WS-COST
     CALL "BOBBER-RETRIEVE" USING WS-PLAYER WS-ROW WS-COST
     MOVE "acceptance US16 17 3.11 a biting fish costs 1 durability" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-KIND
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > EN-COUNT
         IF EN-USED(WS-SLOT) = 1 AND EN-PLAYER(WS-SLOT) = 0 AND EN-ITEM-COUNT(WS-SLOT) > 0
             ADD 1 TO WS-KIND
         END-IF
         IF EN-USED(WS-SLOT) = 1 AND EN-TYPE(WS-SLOT) = WS-ORB-TYPE
             SUBTRACT 1 FROM WS-ORBS
         END-IF
     END-PERFORM
     MOVE "acceptance US16 17 3.11 the catch drops at least one item and an experience orb appears" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-KIND > WS-I AND WS-ORBS < 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 17 3.11 the retrieved hook is gone" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US16-FISHING.
 COPY CORETEST.
 COPY MOBSPTEST.
