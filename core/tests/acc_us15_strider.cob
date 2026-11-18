 *> Acceptance test, the strider (docs/protocol/21 section 5.7, 44-6 section 8; lane 002-lane-mobsb7, T9502 to T9504): the row, the cold state (speed x 0.66 squared, metadata 19), lava (stands on
*> the surface at y + 0.5, rises below it, goes to the nearest lava), the saddle, steering only with the warped fungus on a stick, the boost (140 + nextInt(841) ticks, the stick wears and breaks into a
*> fishing rod) and the jockeys (a zombified piglin with the stick on a saddled strider, 1/30; a baby strider, 1/10).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-STRIDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY XORO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STYPE               BINARY-LONG.
 01 WS-ZTYPE               BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-S2                  BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-PREV                FLOAT-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-WALK                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-LAVA-STATE          BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 14.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-WANTED              BINARY-LONG VALUE 101.
 01 WS-EXPECTED            PIC X(1024).
 01 WS-HEX                 PIC X(8).
 01 WS-BYTE                BINARY-LONG.
 01 WS-CH                  PIC X.
 01 WS-DONE                BINARY-LONG.
 01 WS-BOOSTED             BINARY-LONG.
 01 WS-STICK               BINARY-LONG.
 01 WS-ROD                 BINARY-LONG.
 01 WS-SADDLE              BINARY-LONG.
 01 WS-HANDLED             BINARY-LONG.
 01 WS-HELD                PIC X(24).
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-RIDER               BINARY-LONG.
 01 WS-DRIVEN              BINARY-LONG.
 01 WS-STARTED             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     MOVE "minecraft:strider" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-STYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombified_piglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZTYPE WS-ENTITY-ROW WS-STATUS
     MOVE 2 TO BW-DIFFICULTY
     CALL "STDMOB-INDEX" USING WS-STYPE WS-M
     MOVE "acceptance US15 21§5.7 the strider is the last row of the table" TO TL-CASE
     MOVE SM-COUNT TO TL-EXPECTED-N
     MOVE WS-M TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§5.7 the strider has 20 health" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE SM-HEALTH(WS-M) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A stone floor 14 x 14 (top block FY) around the player, with a lava pool of 3 x 3 cells 4 to 6 blocks east of the strider.
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 7
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 7
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FY WS-KIND
     MOVE "minecraft:lava" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-LAVA-STATE
     PERFORM VARYING WS-FX FROM 4 BY 1 UNTIL WS-FX > 6
         PERFORM VARYING WS-FZ FROM 3 BY 1 UNTIL WS-FZ > 5
             COMPUTE WS-LX = WS-X0 + WS-FX
             COMPUTE WS-LZ = WS-Z0 + WS-FZ
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-LX WS-FY WS-LZ WS-LAVA-STATE
         END-PERFORM
     END-PERFORM
     COMPUTE WS-X = WS-X0 + 1.5
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-Z = WS-Z0 + 4.5
     CALL "MOB-SPAWN" USING WS-DIM WS-STYPE WS-X WS-Y WS-Z WS-YAW WS-S
*>   Cold: on stone it is suffocating, the viewers get metadata 19 true after the baby flag.
     CALL "STRIDER-COLD" USING WS-S
     MOVE "acceptance US15 21§5.7 a strider on stone is cold" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-COLD(WS-S) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE EN-ID(WS-S) TO WS-BYTE
     MOVE FUNCTION CHAR(WS-BYTE + 1) TO WS-CH
     MOVE FUNCTION LOWER-CASE(FUNCTION HEX-OF(WS-CH)) TO WS-HEX(1:2)
     MOVE SPACES TO WS-EXPECTED
     STRING WS-HEX(1:2) "100800" "130801" "ff" DELIMITED BY SIZE INTO WS-EXPECTED
     MOVE "acceptance US15 21§5.7 metadata 19 suffocating is sent" TO TL-CASE
     CALL "RC-CHECK-HEX" USING WS-CONN TL-CASE WS-WANTED WS-EXPECTED
     CALL "STDMOB-SPEED" USING WS-S WS-M WS-SPEED
     MOVE "acceptance US15 21§5.7 a cold strider walks at 0.66 squared of 0.067 (millionths)" TO TL-CASE
     MOVE 29185 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-SPEED * 1000000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The nearest lava within 8 x 2 blocks: the pool's west column, 3 cells east of the strider.
     CALL "STRIDER-FIND-LAVA" USING WS-S WS-FOUND WS-LX WS-LY WS-LZ
     MOVE "acceptance US15 21§5.7 StriderGoToLavaGoal finds the pool" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE TL-EXPECTED-N = WS-X0 + 4
     MOVE WS-LX TO TL-OBSERVED-N
     MOVE "acceptance US15 21§5.7 and its nearest column" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Walking: with a destination it walks toward it (x grows), and arriving ends the stroll.
     COMPUTE EN-DEST-X(WS-S) = WS-X0 + 5
     COMPUTE EN-DEST-Z(WS-S) = WS-Z0 + 4
     MOVE 50 TO EN-PATH-TICKS(WS-S)
     CALL "STRIDER-TICK" USING WS-S WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 21§5.7 a strider with a destination walks east" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-WALK = 1 AND WS-HX > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-X(WS-S) = EN-DEST-X(WS-S) + 0.5
     COMPUTE EN-Z(WS-S) = EN-DEST-Z(WS-S) + 0.5
     CALL "STRIDER-TICK" USING WS-S WS-HX WS-HZ WS-WALK
     MOVE "acceptance US15 21§5.7 arriving ends the stroll" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-PATH-TICKS(WS-S) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Over lava (cell FY of the pool): standing at the surface, FY + 0.5, from above it; below the surface it rises.
     COMPUTE EN-Y(WS-S) = WS-FY + 0.9
     COMPUTE WS-PREV = WS-FY + 1.2
     MOVE 0 TO EN-PATH-TICKS(WS-S)
     CALL "STRIDER-LAVA" USING WS-S WS-PREV
     MOVE "acceptance US15 21§5.7 a strider in lava with open air above stands on the surface (cell y + 0.5, thousandths)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-FY * 1000 + 500
     COMPUTE TL-OBSERVED-N ROUNDED = EN-Y(WS-S) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§5.7 on the ground" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-ON-GROUND(WS-S) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STRIDER-COLD" USING WS-S
     MOVE "acceptance US15 21§5.7 in lava it is warm" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-COLD(WS-S) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-Y(WS-S) = WS-FY + 0.3
     MOVE EN-Y(WS-S) TO WS-PREV
     MOVE 0 TO EN-VY(WS-S)
     CALL "STRIDER-LAVA" USING WS-S WS-PREV
     MOVE "acceptance US15 21§5.7 below the surface it rises (v = 0.05, thousandths)" TO TL-CASE
     MOVE 50 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VY(WS-S) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Lava above: not on the surface either.
     COMPUTE WS-LY = WS-FY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-LX WS-LY WS-LZ WS-LAVA-STATE
     COMPUTE EN-X(WS-S) = WS-LX + 0.5
     COMPUTE EN-Z(WS-S) = WS-LZ + 0.5
     COMPUTE EN-Y(WS-S) = WS-FY + 0.9
     COMPUTE WS-PREV = WS-FY + 1.2
     MOVE 0 TO EN-VY(WS-S)
     CALL "STRIDER-LAVA" USING WS-S WS-PREV
     MOVE "acceptance US15 21§5.7 with lava above it rises too" TO TL-CASE
     MOVE 50 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = EN-VY(WS-S) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Out of lava and out of reach of lava: nothing to find.
     COMPUTE EN-X(WS-S) = WS-X0 + 40
     COMPUTE EN-Y(WS-S) = WS-FY + 1
     COMPUTE EN-Z(WS-S) = WS-Z0 + 40
     CALL "STRIDER-FIND-LAVA" USING WS-S WS-FOUND WS-LX WS-LY WS-LZ
     MOVE "acceptance US15 21§5.7 no lava within 8 blocks: none found" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The goal and the stroll start by the draw: within 400 ticks a strider on stone near lava sets out.
     COMPUTE EN-X(WS-S) = WS-X0 + 1.5
     COMPUTE EN-Z(WS-S) = WS-Z0 + 4.5
     MOVE 0 TO EN-PATH-TICKS(WS-S) WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400 OR WS-FOUND = 1
         ADD 1 TO CW-TIME
         CALL "STRIDER-TICK" USING WS-S WS-HX WS-HZ WS-WALK
         IF EN-PATH-TICKS(WS-S) > 0
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§5.7 a strider sets out on its own" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The saddle (a strider is saddled by anyone, 5.7), then the empty hand mounts.
     COMPUTE EN-X(WS-S) = WS-X0 + 1.5
     COMPUTE EN-Y(WS-S) = WS-FY + 1
     COMPUTE EN-Z(WS-S) = WS-Z0 + 4.5
     MOVE "minecraft:saddle" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-SADDLE WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:warped_fungus_on_a_stick" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STICK WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:fishing_rod" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ROD WS-ITEM-ROW WS-STATUS
     MOVE 0 TO PL-HELD(WS-PLAYER)
     MOVE WS-SADDLE TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE "saddle" TO WS-HELD
     CALL "MOB-RIDE-USE" USING WS-PLAYER WS-S WS-HELD WS-HANDLED
     MOVE "acceptance US15 21§5.7 a saddle goes on a strider" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-SADDLE(WS-S) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-HELD
     CALL "MOB-RIDE-USE" USING WS-PLAYER WS-S WS-HELD WS-HANDLED
     MOVE "acceptance US15 21§5.7 the empty hand mounts it" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-RIDER(WS-S) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-RIDE-TICK" USING WS-S WS-DONE
     MOVE "acceptance US15 21§5.7 without the stick the rider does not steer (the strider walks on its own)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DONE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-STICK TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1)
     CALL "MOB-RIDE-TICK" USING WS-S WS-DONE
     MOVE "acceptance US15 21§5.7 with the stick the rider's client steers" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-DONE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The stick boosts: 140 + nextInt(841) ticks, once at a time; it wears out after 100 uses and becomes a fishing rod.
     CALL "STRIDER-STICK-USE" USING WS-CONN WS-DONE
     MOVE "acceptance US15 21§5.7 the stick boosts the strider" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-DONE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§5.7 the boost lasts 140 to 980 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-BOOST(WS-S) >= 140 AND EN-BOOST(WS-S) <= 980 AND EN-BOOSTING(WS-S) = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STRIDER-STICK-USE" USING WS-CONN WS-DONE
     MOVE "acceptance US15 21§5.7 no second boost while boosting" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DONE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO EN-BOOST(WS-S)
     MOVE 0 TO EN-BOOST-T(WS-S)
     MOVE 0 TO EN-PATH-TICKS(WS-S)
     PERFORM 4 TIMES
         CALL "STRIDER-TICK" USING WS-S WS-HX WS-HZ WS-WALK
     END-PERFORM
     MOVE "acceptance US15 21§5.7 the boost ends after its total" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-BOOSTING(WS-S) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-I
     PERFORM UNTIL PL-SLOT-ITEM(WS-PLAYER, 1) = WS-ROD OR WS-I > 200
         ADD 1 TO WS-I
         MOVE 0 TO EN-BOOSTING(WS-S)
         CALL "STRIDER-STICK-USE" USING WS-CONN WS-DONE
     END-PERFORM
     MOVE "acceptance US15 21§5.7 the worn stick breaks into a fishing rod on the 100th boost" TO TL-CASE
     MOVE 99 TO TL-EXPECTED-N
     MOVE WS-I TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Another item in the hand (the rod now) and no stick use; and without a mount nothing happens.
     CALL "STRIDER-STICK-USE" USING WS-CONN WS-DONE
     MOVE "acceptance US15 21§5.7 a fishing rod is no stick" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DONE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-RIDE-TICK" USING WS-S WS-DONE
     MOVE "acceptance US15 21§5.7 and a rod does not steer" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "MOB-RIDE-STOP" USING WS-S
     CALL "STRIDER-STICK-USE" USING WS-CONN WS-DONE
     MOVE "acceptance US15 21§5.7 on foot the stick does nothing" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-S
*>   Finalizing an adult strider: 1/30 a zombified piglin with the stick on a saddled strider.
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3000 OR WS-FOUND = 1
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MOB-SPAWN" USING WS-DIM WS-STYPE WS-X WS-Y WS-Z WS-YAW WS-S
         CALL "STDMOB-FINALIZE" USING XR-STATE WS-S
         IF EN-PASS(WS-S) > 0 AND EN-TYPE(EN-PASS(WS-S)) = WS-ZTYPE
             MOVE 1 TO WS-FOUND
         ELSE
             IF EN-PASS(WS-S) > 0
                 CALL "ENTITY-REMOVE" USING EN-PASS(WS-S)
             END-IF
             CALL "ENTITY-REMOVE" USING WS-S
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§5.7 an adult strider can carry a zombified piglin" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE EN-PASS(WS-S) TO WS-RIDER
     MOVE "acceptance US15 21§5.7 the rider holds the warped fungus on a stick (hand 9)" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE EN-HAND(WS-RIDER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§5.7 and the strider is saddled" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-SADDLE(WS-S) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-MOUNT-DRIVE" USING WS-S WS-DRIVEN
     MOVE "acceptance US15 21§5.7 a mob rider does not steer a strider" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DRIVEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-RIDER
     CALL "ENTITY-REMOVE" USING WS-S
*>   Otherwise 1/10 a baby strider.
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300 OR WS-FOUND = 1
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MOB-SPAWN" USING WS-DIM WS-STYPE WS-X WS-Y WS-Z WS-YAW WS-S
         CALL "STDMOB-FINALIZE" USING XR-STATE WS-S
         IF EN-PASS(WS-S) > 0 AND EN-TYPE(EN-PASS(WS-S)) = WS-STYPE
             MOVE 1 TO WS-FOUND
         ELSE
             IF EN-PASS(WS-S) > 0
                 CALL "ENTITY-REMOVE" USING EN-PASS(WS-S)
             END-IF
             CALL "ENTITY-REMOVE" USING WS-S
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§5.7 an adult strider can carry a baby strider" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 21§5.7 the rider is a baby" TO TL-CASE
     MOVE EN-VARIANT(EN-PASS(WS-S)) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING EN-PASS(WS-S)
*>   A baby strider carries no jockey.
     MOVE 1 TO EN-VARIANT(WS-S)
     MOVE 5 TO WS-SEED
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "STRIDER-JOCKEY" USING XR-STATE WS-S
     MOVE "acceptance US15 21§5.7 a baby strider has no rider" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-PASS(WS-S) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US15-STRIDER.

 COPY CORETEST.
 COPY MOBSPTEST.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. RC-CHECK-HEX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-INDEX-BYTE          BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-AREA                PIC X(65536) BASED.
 01 WS-COPY                PIC X(512).
 01 WS-HEX                 PIC X(1024).
 01 WS-TEXT                PIC X(4096).
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-CASE                 PIC X(240).
 01 L-WANTED               BINARY-LONG.
 01 L-EXPECTED             PIC X(1024).
 PROCEDURE DIVISION USING L-ID L-CASE L-WANTED L-EXPECTED.
     MOVE "none" TO WS-HEX
     MOVE 0 TO WS-FOUND WS-OUTCOME
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING L-ID PB-BUFFER WS-CLOSE
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         *>       The health slot (index 9) sent at the pairing (18 section 9.3) is not the packet looked for.
         IF WS-OUTCOME = 0 AND WS-PACKET-ID = L-WANTED AND WS-FOUND = 0
             MOVE 1 TO WS-FOUND
             SET ADDRESS OF WS-AREA TO PK-ADDR
             MOVE FUNCTION ORD(WS-AREA(PK-POS + 2:1)) TO WS-INDEX-BYTE
             IF WS-INDEX-BYTE = 10
                 MOVE 0 TO WS-FOUND
             ELSE
                 COMPUTE WS-COUNT = PK-LENGTH - PK-POS
                 MOVE SPACES TO WS-COPY
                 MOVE WS-AREA(PK-POS + 1:WS-COUNT) TO WS-COPY
                 CALL "TEST-HEX-OF" USING WS-COPY WS-COUNT WS-HEX
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     MOVE WS-HEX TO WS-TEXT
     MOVE L-CASE TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE L-EXPECTED TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     GOBACK.
 END PROGRAM RC-CHECK-HEX.
