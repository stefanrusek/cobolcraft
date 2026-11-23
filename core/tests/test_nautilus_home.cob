*> Implementation test (wrap I2 round 5, T24090; docs/protocol/44-residual-mob-questions-7-aquatic.md section 10.4 "Restriction radius", 44-3 section B): a tame nautilus that is neither leashed nor
*> a vehicle keeps a home of radius 32 (an adult with an empty saddle slot) or 16: a home of that radius within radius + 8 blocks stays, otherwise the home is set to the nautilus's block. The
*> stroll candidate of RandomStroll.swim is rejected outside the home while the nautilus is restricted (the home closer than radius + 11), and not when it is far from its home or has none. A tame
*> nautilus that the interaction leaves without a passenger loses its home (doPlayerRide).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NAUTILUS-HOME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY ENKEEP.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-NAU                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DEST                BINARY-LONG.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-STONE               BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-CASE                PIC X(200).
 01 WS-EXPECT              BINARY-LONG.
 01 WS-OBSERVE             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     CALL "AQ-TEST-TANK" USING WS-PLAYER WS-DIM WS-X0 WS-Y0 WS-Z0
     COMPUTE WS-X = WS-X0 + 4.5
     COMPUTE WS-Y = WS-Y0 + 3
     COMPUTE WS-Z = WS-Z0 + 4.5
     MOVE "minecraft:nautilus" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-NAU
     MOVE EN-ID(WS-NAU) TO WS-ID

*>   An untamed nautilus has no home.
     CALL "NAUTILUS-RESTRICT" USING WS-NAU
     MOVE "implementation 44-7 10.4 an untamed nautilus is given no home" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EK-HOME-ON(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK

*>   A tame adult with an empty saddle slot: the radius 32 and the home at its own block.
     MOVE 1 TO EN-TAMED(WS-NAU)
     MOVE 0 TO EN-MOBAGE(WS-NAU) EN-SADDLE(WS-NAU)
     CALL "NAUTILUS-RESTRICT" USING WS-NAU
     MOVE "implementation 44-7 10.4 a tame adult nautilus with no saddle is homed with radius 32" TO WS-CASE
     MOVE 32 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EK-HOME-RADIUS(WS-NAU) * EK-HOME-ON(WS-NAU)
     PERFORM CHECK
     MOVE "implementation 44-7 10.4 the home is the block of the nautilus" TO WS-CASE
     COMPUTE WS-EXPECT = WS-X0 + 4
     MOVE EK-HOME-X(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK
     MOVE "implementation 44-7 10.4 the home block y and z" TO WS-CASE
     COMPUTE WS-EXPECT = (WS-Y0 + 3) * 1000 + WS-Z0 + 4
     COMPUTE WS-OBSERVE = EK-HOME-Y(WS-NAU) * 1000 + EK-HOME-Z(WS-NAU)
     PERFORM CHECK

*>   Within radius + 8 = 40 blocks the home stays; at 40 (the strict test) and farther it moves to the nautilus's block.
     MOVE EK-HOME-X(WS-NAU) TO WS-CX
     COMPUTE EN-X(WS-NAU) = WS-CX + 39.5
     CALL "NAUTILUS-RESTRICT" USING WS-NAU
     MOVE "implementation 44-7 10.4 39 blocks from the home the home stays" TO WS-CASE
     MOVE WS-CX TO WS-EXPECT
     MOVE EK-HOME-X(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK
     COMPUTE EN-X(WS-NAU) = WS-CX + 40.5
     CALL "NAUTILUS-RESTRICT" USING WS-NAU
     MOVE "implementation 44-7 10.4 40 blocks from the home (not closer than radius + 8) re-homes at the nautilus" TO WS-CASE
     COMPUTE WS-EXPECT = WS-CX + 40
     MOVE EK-HOME-X(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK

*>   A saddled one has the radius 16: the home of radius 32 does not equal it, so it is re-set at once; a baby has 16 too.
     MOVE 1 TO EN-SADDLE(WS-NAU)
     CALL "NAUTILUS-RESTRICT" USING WS-NAU
     MOVE "implementation 44-7 10.4 a saddled nautilus is re-homed with radius 16" TO WS-CASE
     MOVE 16 TO WS-EXPECT
     MOVE EK-HOME-RADIUS(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO EN-SADDLE(WS-NAU)
     MOVE -100 TO EN-MOBAGE(WS-NAU)
     MOVE 0 TO EK-HOME-ON(WS-NAU)
     CALL "NAUTILUS-RESTRICT" USING WS-NAU
     MOVE "implementation 44-7 10.4 a baby nautilus without a saddle has radius 16" TO WS-CASE
     MOVE 16 TO WS-EXPECT
     MOVE EK-HOME-RADIUS(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO EN-MOBAGE(WS-NAU)
     MOVE 1 TO EN-SADDLE(WS-NAU)

*>   The radius 16 keeps the home within 24 blocks: 23 stay, 24 move.
     MOVE EK-HOME-X(WS-NAU) TO WS-CX
     COMPUTE EN-X(WS-NAU) = WS-CX + 23.5
     CALL "NAUTILUS-RESTRICT" USING WS-NAU
     MOVE "implementation 44-7 10.4 radius 16: 23 blocks from the home it stays" TO WS-CASE
     MOVE WS-CX TO WS-EXPECT
     MOVE EK-HOME-X(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK
     COMPUTE EN-X(WS-NAU) = WS-CX + 24.5
     CALL "NAUTILUS-RESTRICT" USING WS-NAU
     MOVE "implementation 44-7 10.4 radius 16: 24 blocks from the home it moves" TO WS-CASE
     COMPUTE WS-EXPECT = WS-CX + 24
     MOVE EK-HOME-X(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK

*>   Leashed, ridden or carrying a mob: the home is left alone.
     MOVE EK-HOME-X(WS-NAU) TO WS-CX
     COMPUTE EN-X(WS-NAU) = WS-CX + 60.5
     MOVE WS-PLAYER TO EN-LEASH(WS-NAU)
     CALL "NAUTILUS-RESTRICT" USING WS-NAU
     MOVE "implementation 44-7 10.4 a leashed nautilus keeps its home" TO WS-CASE
     MOVE WS-CX TO WS-EXPECT
     MOVE EK-HOME-X(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO EN-LEASH(WS-NAU)
     MOVE WS-PLAYER TO EN-LEASH-KNOT(WS-NAU)
     CALL "NAUTILUS-RESTRICT" USING WS-NAU
     MOVE "implementation 44-7 10.4 a nautilus held by a fence knot keeps its home" TO WS-CASE
     MOVE WS-CX TO WS-EXPECT
     MOVE EK-HOME-X(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO EN-LEASH-KNOT(WS-NAU)
     MOVE WS-PLAYER TO EN-RIDER(WS-NAU)
     CALL "NAUTILUS-RESTRICT" USING WS-NAU
     MOVE "implementation 44-7 10.4 a ridden nautilus (a vehicle) keeps its home" TO WS-CASE
     MOVE WS-CX TO WS-EXPECT
     MOVE EK-HOME-X(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO EN-RIDER(WS-NAU)
     MOVE WS-NAU TO EN-PASS(WS-NAU)
     CALL "NAUTILUS-RESTRICT" USING WS-NAU
     MOVE "implementation 44-7 10.4 a nautilus with a mob passenger keeps its home" TO WS-CASE
     MOVE WS-CX TO WS-EXPECT
     MOVE EK-HOME-X(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO EN-PASS(WS-NAU)

*>   The stroll candidate: home block (10, 20, 30), radius 4; the mob stands within radius + 11 of it.
     COMPUTE EN-X(WS-NAU) = WS-X0 + 4.5
     MOVE 1 TO EK-HOME-ON(WS-NAU)
     MOVE 4 TO EK-HOME-RADIUS(WS-NAU)
     COMPUTE EK-HOME-X(WS-NAU) = WS-X0 + 4
     COMPUTE EK-HOME-Y(WS-NAU) = WS-Y0 + 3
     COMPUTE EK-HOME-Z(WS-NAU) = WS-Z0 + 4
     MOVE EK-HOME-X(WS-NAU) TO WS-CX
     MOVE EK-HOME-Y(WS-NAU) TO WS-CY
     MOVE EK-HOME-Z(WS-NAU) TO WS-CZ
     ADD 3 TO WS-CX
     CALL "NAUTILUS-HOME-CELL" USING WS-NAU WS-CX WS-CY WS-CZ WS-OK
     MOVE "implementation 44-7 10.4 a stroll cell 3 blocks from the home (radius 4) is accepted" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK
     ADD 1 TO WS-CX
     CALL "NAUTILUS-HOME-CELL" USING WS-NAU WS-CX WS-CY WS-CZ WS-OK
     MOVE "implementation 44-7 10.4 a stroll cell 4 blocks from the home (not below radius) is rejected" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK
     COMPUTE WS-CY = EK-HOME-Y(WS-NAU) + 4
     COMPUTE WS-CX = EK-HOME-X(WS-NAU) + 2
     CALL "NAUTILUS-HOME-CELL" USING WS-NAU WS-CX WS-CY WS-CZ WS-OK
     MOVE "implementation 44-7 10.4 the distance counts the height too (2, 4, 0 is 20: rejected)" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK
*>   Far from the home (radius + 11 = 15 blocks or more from its centre) the mob is not restricted: any cell goes.
     COMPUTE EN-X(WS-NAU) = EK-HOME-X(WS-NAU) + 15.5
     CALL "NAUTILUS-HOME-CELL" USING WS-NAU WS-CX WS-CY WS-CZ WS-OK
     MOVE "implementation 44-7 10.4 a mob 15 blocks from the home centre is not restricted" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK
     COMPUTE EN-X(WS-NAU) = EK-HOME-X(WS-NAU) + 14.5
     CALL "NAUTILUS-HOME-CELL" USING WS-NAU WS-CX WS-CY WS-CZ WS-OK
     MOVE "implementation 44-7 10.4 a mob 14 blocks from the home centre is restricted" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK
     COMPUTE EN-X(WS-NAU) = WS-X0 + 4.5
     MOVE 0 TO EK-HOME-ON(WS-NAU)
     CALL "NAUTILUS-HOME-CELL" USING WS-NAU WS-CX WS-CY WS-CZ WS-OK
     MOVE "implementation 44-7 10.4 without a home every cell is accepted" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE WS-OK TO WS-OBSERVE
     PERFORM CHECK

*>   The swim itself (AQUA-SWIM) in a tank: with a home of radius 1 (a restricted mob) it picks no destination in 8000 draws; without a home it picks some.
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-NAU) WS-M
     MOVE 1 TO EK-HOME-ON(WS-NAU)
     MOVE 1 TO EK-HOME-RADIUS(WS-NAU)
     COMPUTE EK-HOME-X(WS-NAU) = WS-X0 + 1
     COMPUTE EK-HOME-Y(WS-NAU) = WS-Y0 + 1
     COMPUTE EK-HOME-Z(WS-NAU) = WS-Z0 + 1
     MOVE 0 TO WS-DEST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8000
         ADD 1 TO CW-TIME
         MOVE 0 TO EN-COOLDOWN(WS-NAU)
         CALL "AQUA-SWIM" USING WS-NAU WS-M
         IF EN-COOLDOWN(WS-NAU) > 0
             ADD 1 TO WS-DEST
         END-IF
     END-PERFORM
     MOVE "implementation 44-7 10.4 a restricted nautilus swims to no cell outside its home (8000 draws)" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE WS-DEST TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO EK-HOME-ON(WS-NAU)
     MOVE 0 TO WS-DEST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8000
         ADD 1 TO CW-TIME
         MOVE 0 TO EN-COOLDOWN(WS-NAU)
         CALL "AQUA-SWIM" USING WS-NAU WS-M
         IF EN-COOLDOWN(WS-NAU) > 0
             ADD 1 TO WS-DEST
         END-IF
     END-PERFORM
     MOVE "implementation 44-7 10.4 the same nautilus without a home picks destinations in the tank" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-DEST > 0
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK

*>   clearHome (doPlayerRide, step 3 of 10.2): a ride that the interaction does not start (the player already rides something) leaves a tame nautilus without a passenger and without a home, with
*>   an empty hand and with an item that is no food; a sneaking player (secondary use) does not ride at all and the home stays; a ride that starts keeps the home.
     MOVE PL-X(WS-PLAYER) TO EN-X(WS-NAU)
     MOVE PL-Y(WS-PLAYER) TO EN-Y(WS-NAU)
     COMPUTE EN-Z(WS-NAU) = PL-Z(WS-PLAYER) + 2
     MOVE 1 TO EK-HOME-ON(WS-NAU)
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-HELD(WS-PLAYER)
     MOVE WS-NAU TO EN-VEHICLE(PL-ENTITY-ROW(WS-PLAYER))
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.2 an empty hand that does not start the ride clears the home of the nautilus" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EK-HOME-ON(WS-NAU) + EN-RIDER(WS-NAU)
     PERFORM CHECK
     MOVE 1 TO EK-HOME-ON(WS-NAU)
     MOVE "minecraft:cobblestone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-STONE WS-ITEM-ROW WS-STATUS
     MOVE WS-STONE TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.2 an item that is no food does the same" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     COMPUTE WS-OBSERVE = EK-HOME-ON(WS-NAU) + EN-RIDER(WS-NAU)
     PERFORM CHECK
     MOVE 1 TO EK-HOME-ON(WS-NAU)
     MOVE 1 TO PL-SNEAKING(WS-PLAYER)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.2 a sneaking player does not ride and the home stays" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE EK-HOME-ON(WS-NAU) TO WS-OBSERVE
     PERFORM CHECK
     MOVE 0 TO PL-SNEAKING(WS-PLAYER)
     MOVE 0 TO EN-VEHICLE(PL-ENTITY-ROW(WS-PLAYER))
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 1 TO EK-HOME-ON(WS-NAU)
     CALL "TEST-INTERACT" USING WS-CONN WS-ID WS-HAND0 WS-SNEAK0
     MOVE "implementation 44-7 10.2 a ride that starts keeps the home" TO WS-CASE
     MOVE WS-PLAYER TO WS-EXPECT
     COMPUTE WS-OBSERVE = EN-RIDER(WS-NAU) + EK-HOME-ON(WS-NAU) - 1
     PERFORM CHECK
     STOP RUN.
*> CHECK: one numeric assertion of WS-CASE
 CHECK.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-NAUTILUS-HOME.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY AQUATEST.
