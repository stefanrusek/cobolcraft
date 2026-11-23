*> Implementation test (wrap I2 round 5, T24090; docs/protocol/44-residual-mob-questions-7-aquatic.md section 8.4): a splash or lingering potion of water that bursts rehydrates every axolotl whose box
*> meets the potion's box inflated by 4.0 horizontally and 2.0 vertically (air + 1800, at most the maximum 6000: EN-DRY counts the ticks without air, so it falls by 1800 to at least 0). There is no
*> distance test; a potion of any other contents, and any other mob, does not rehydrate.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-AXOLOTL-REHYDRATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY PROJSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG VALUE 0.
 01 WS-VY                  FLOAT-LONG VALUE 0.
 01 WS-VZ                  FLOAT-LONG VALUE 0.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-OWNER               BINARY-LONG VALUE 0.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-POTION              BINARY-LONG.
 01 WS-WATER               PIC X(32) VALUE "water".
 01 WS-AWKWARD             PIC X(32) VALUE "awkward".
 01 WS-LINGERING           BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-POT                 BINARY-LONG.
 01 WS-AXO                 BINARY-LONG.
 01 WS-AXO2                BINARY-LONG.
 01 WS-AXO3                BINARY-LONG.
 01 WS-COD                 BINARY-LONG.
 01 WS-AXO-TYPE            BINARY-LONG.
 01 WS-COD-TYPE            BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:axolotl" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-AXO-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:cod" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COD-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE 80 TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "SC-POTION-ID" USING WS-WATER WS-POTION

*>   A splash potion of water: an axolotl 3 blocks to the side with 3000 dry ticks gets 1800 of them back; one 1000 dry ticks old is fully rehydrated (0, not below).
     PERFORM SPAWN-AXOLOTL
     MOVE 3000 TO EN-DRY(WS-AXO)
     COMPUTE WS-X = PL-X(WS-PLAYER) + 3
     MOVE WS-AXO-TYPE TO WS-TYPE
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-AXO2
     MOVE 1000 TO EN-DRY(WS-AXO2)
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE 0 TO WS-LINGERING
     PERFORM BURST-WATER
     MOVE "implementation 44-7 8.4 a splash water potion takes 1800 dry ticks off a near axolotl" TO TL-CASE
     MOVE 1200 TO TL-EXPECTED-N
     MOVE EN-DRY(WS-AXO) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 44-7 8.4 the air is at most the maximum (EN-DRY is not below 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-DRY(WS-AXO2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The horizontal reach: the potion's box (0.25 wide) inflated by 4.0 meets an axolotl (0.75 wide) whose centre is 4.4 away, not one 4.6 away. No distance test: a corner is as good as a side.
     PERFORM SPAWN-AXOLOTL
     MOVE 3000 TO EN-DRY(WS-AXO)
     COMPUTE WS-X = PL-X(WS-PLAYER) + 4.4
     COMPUTE WS-Z = PL-Z(WS-PLAYER) + 4.4
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-AXO2
     MOVE 3000 TO EN-DRY(WS-AXO2)
     COMPUTE WS-X = PL-X(WS-PLAYER) + 4.6
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-AXO3
     MOVE 3000 TO EN-DRY(WS-AXO3)
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE WS-COD-TYPE TO WS-TYPE
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-COD
     MOVE 3000 TO EN-DRY(WS-COD)
     MOVE WS-AXO-TYPE TO WS-TYPE
     MOVE 0 TO WS-LINGERING
     PERFORM BURST-WATER
     MOVE "implementation 44-7 8.4 an axolotl 4.4 away to the side and 4.4 behind is rehydrated" TO TL-CASE
     MOVE 1200 TO TL-EXPECTED-N
     MOVE EN-DRY(WS-AXO2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 44-7 8.4 an axolotl 4.6 away is out of the box" TO TL-CASE
     MOVE 3000 TO TL-EXPECTED-N
     MOVE EN-DRY(WS-AXO3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 44-7 8.4 the axolotl at the potion itself too" TO TL-CASE
     MOVE 1200 TO TL-EXPECTED-N
     MOVE EN-DRY(WS-AXO) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 44-7 8.4 a cod at the potion is no axolotl and is untouched" TO TL-CASE
     MOVE 3000 TO TL-EXPECTED-N
     MOVE EN-DRY(WS-COD) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Vertical reach: inflated by 2.0, the potion's box (0.25 tall, bottom at y) meets an axolotl (0.42 tall) whose feet are below 2.25 above and above 2.42 below the potion's feet.
     PERFORM SPAWN-AXOLOTL
     MOVE 3000 TO EN-DRY(WS-AXO)
     MOVE PL-X(WS-PLAYER) TO WS-X
     COMPUTE WS-Y = 80 + 2.2
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-AXO2
     MOVE 3000 TO EN-DRY(WS-AXO2)
     COMPUTE WS-Y = 80 - 2.3
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-AXO3
     MOVE 3000 TO EN-DRY(WS-AXO3)
     PERFORM BURST-WATER
     MOVE "implementation 44-7 8.4 an axolotl 2.2 above the potion is reached (the box inflated by 2.0 above the 0.25)" TO TL-CASE
     MOVE 1200 TO TL-EXPECTED-N
     MOVE EN-DRY(WS-AXO2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 44-7 8.4 an axolotl 2.3 below the potion is reached (its 0.42 body reaches up past -2.0)" TO TL-CASE
     MOVE 1200 TO TL-EXPECTED-N
     MOVE EN-DRY(WS-AXO3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM SPAWN-AXOLOTL
     MOVE 3000 TO EN-DRY(WS-AXO)
     COMPUTE WS-Y = 80 + 2.4
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-AXO2
     MOVE 3000 TO EN-DRY(WS-AXO2)
     COMPUTE WS-Y = 80 - 2.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-AXO3
     MOVE 3000 TO EN-DRY(WS-AXO3)
     PERFORM BURST-WATER
     MOVE "implementation 44-7 8.4 an axolotl 2.4 above the potion is out of reach" TO TL-CASE
     MOVE 3000 TO TL-EXPECTED-N
     MOVE EN-DRY(WS-AXO2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "implementation 44-7 8.4 an axolotl 2.5 below the potion is out of reach" TO TL-CASE
     MOVE 3000 TO TL-EXPECTED-N
     MOVE EN-DRY(WS-AXO3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A lingering potion of water rehydrates too (before and without any cloud); a splash potion of another potion (awkward: no effects) does not.
     PERFORM SPAWN-AXOLOTL
     MOVE 3000 TO EN-DRY(WS-AXO)
     MOVE 1 TO WS-LINGERING
     PERFORM BURST-WATER
     MOVE "implementation 44-7 8.4 a lingering water potion rehydrates as well" TO TL-CASE
     MOVE 1200 TO TL-EXPECTED-N
     MOVE EN-DRY(WS-AXO) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3000 TO EN-DRY(WS-AXO)
     CALL "SC-POTION-ID" USING WS-AWKWARD WS-POTION
     MOVE 0 TO WS-LINGERING
     PERFORM BURST-WATER
     MOVE "implementation 44-7 8.4 an awkward potion is not in the rehydrates_axolotls tag" TO TL-CASE
     MOVE 3000 TO TL-EXPECTED-N
     MOVE EN-DRY(WS-AXO) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
*> SPAWN-AXOLOTL: an axolotl at the player's x and z, y 80 (the potion's place): its row in WS-AXO
 SPAWN-AXOLOTL.
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE 80 TO WS-Y
     MOVE WS-AXO-TYPE TO WS-TYPE
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-AXO.
*> BURST-WATER: a thrown potion of the contents WS-POTION (splash, or lingering with WS-LINGERING 1) bursts at (player x, 80, player z)
 BURST-WATER.
     MOVE 0 TO WS-HANDLE
     CALL "SC-POTION-SET" USING WS-HANDLE WS-POTION
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE 80 TO WS-Y
     CALL "POTION-SPAWN" USING WS-LINGERING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-OWNER WS-POT
     CALL "POTION-LOAD" USING WS-POT WS-HANDLE WS-LINGERING
     CALL "POTION-BURST" USING WS-POT WS-NO.
 END PROGRAM TEST-AXOLOTL-REHYDRATE.
 COPY CORETEST.
 COPY MOBSPTEST.
