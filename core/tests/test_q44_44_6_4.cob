*> Piglin, piglin brute and hoglin sensors (docs/protocol/44-residual-mob-questions-6-nether.md section 4.1 step 1 and 4.3: NEAREST_REPELLENT; lane 002-lane-p49c, T15530):
*> the piglin_repellents block tag (soul fire, soul torch and wall torch, soul lantern, a lit soul campfire only), the hoglin_repellents tag (warped fungus, potted, nether
*> portal, respawn anchor, no lit test), the box of 8 blocks horizontally and 4 vertically, nearest first by Manhattan distance, and V10 (lit chosen over unlit at equal distance).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-6-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 40.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-PTYPE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-LIT                 BINARY-LONG.
 01 WS-UNLIT               BINARY-LONG.
 01 WS-PNAME               PIC X(24) VALUE "lit".
 01 WS-PFALSE              PIC X(32) VALUE "false".
 01 WS-MODE2               BINARY-LONG VALUE 2.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-RKIND               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RY                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-NAME                PIC X(112).
 01 WS-OFF-X               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-T                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 20
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 20
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FY WS-KIND
     MOVE "minecraft:piglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PTYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-CX = WS-X0 + 20
     COMPUTE WS-CY = WS-FY + 1
     COMPUTE WS-CZ = WS-Z0 + 20
     COMPUTE WS-X = WS-CX + 0.5
     MOVE WS-CY TO WS-Y
     COMPUTE WS-Z = WS-CZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-PTYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
*>   Piglin kind 1: one block of each repellent type, 2 east of the piglin, found; then removed.
     MOVE 1 TO WS-RKIND
     MOVE "soul_fire" TO WS-NAME
     PERFORM TRY-ONE
     MOVE "acceptance US15 44-6§4.1 soul_fire is a piglin repellent" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "soul_wall_torch" TO WS-NAME
     PERFORM TRY-ONE
     MOVE "acceptance US15 44-6§4.1 soul_wall_torch is a piglin repellent" TO TL-CASE
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "soul_lantern" TO WS-NAME
     PERFORM TRY-ONE
     MOVE "acceptance US15 44-6§4.1 soul_lantern is a piglin repellent" TO TL-CASE
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "soul_campfire" TO WS-NAME
     PERFORM TRY-ONE
     MOVE "acceptance US15 44-6§4.1 a lit soul_campfire is a piglin repellent" TO TL-CASE
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "soul_campfire" TO WS-NAME
     MOVE 1 TO WS-T
     PERFORM TRY-ONE
     MOVE "acceptance US15 44-6§4.1 an unlit soul_campfire is never returned" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-T
     MOVE "torch" TO WS-NAME
     PERFORM TRY-ONE
     MOVE "acceptance US15 44-6§4.1 a plain torch is not a repellent" TO TL-CASE
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "warped_fungus" TO WS-NAME
     PERFORM TRY-ONE
     MOVE "acceptance US15 44-6§4.1 warped fungus does not repel a piglin" TO TL-CASE
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The box: 8 horizontally, 4 vertically.
     MOVE "soul_torch" TO WS-NAME
     MOVE 8 TO WS-OFF-X
     MOVE 0 TO WS-OY
     PERFORM TRY-OFFSET
     MOVE "acceptance US15 44-6§4.1 a repellent 8 blocks away is inside the box" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 9 TO WS-OFF-X
     PERFORM TRY-OFFSET
     MOVE "acceptance US15 44-6§4.1 9 blocks away is outside" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-OFF-X
     MOVE 4 TO WS-OY
     PERFORM TRY-OFFSET
     MOVE "acceptance US15 44-6§4.1 4 blocks up is inside the box" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-OY
     PERFORM TRY-OFFSET
     MOVE "acceptance US15 44-6§4.1 5 blocks up is outside" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Nearest first by Manhattan distance: A at (3, 0, 3) is 6, B at (5, 0, 0) is 5: B wins.
     MOVE "minecraft:soul_torch" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     COMPUTE WS-BX = WS-CX + 3
     COMPUTE WS-BZ = WS-CZ + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-STATE
     COMPUTE WS-BX = WS-CX + 5
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-CZ WS-STATE
     MOVE 1 TO WS-RKIND
     CALL "PGB-REPEL" USING WS-ROW WS-RKIND WS-FOUND WS-RX WS-RY WS-RZ
     MOVE "acceptance US15 44-6§4.1 nearest first by Manhattan distance (5 beats 6, though 18 < 25 squared)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-CX + 5
     MOVE WS-RX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-BX = WS-CX + 5
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-CZ WS-AIR
     COMPUTE WS-BX = WS-CX + 3
     COMPUTE WS-BZ = WS-CZ + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-AIR
*>   V10: an unlit and a lit soul campfire at equal distance: the lit one.
     MOVE "minecraft:soul_campfire" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-LIT
     CALL "BLOCK-STATE-PROP" USING WS-MODE2 WS-LIT WS-PNAME WS-PFALSE WS-UNLIT
     COMPUTE WS-BX = WS-CX - 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-CZ WS-UNLIT
     COMPUTE WS-BX = WS-CX + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-CZ WS-LIT
     CALL "PGB-REPEL" USING WS-ROW WS-RKIND WS-FOUND WS-RX WS-RY WS-RZ
     MOVE "acceptance US15 44-6§11.2 V10 a lit and an unlit soul campfire at equal distance: the lit one" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-CX + 3
     MOVE WS-RX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-BX = WS-CX - 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-CZ WS-AIR
     COMPUTE WS-BX = WS-CX + 3
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-CZ WS-AIR
*>   Hoglin kind 2: warped fungus, potted, nether portal, respawn anchor repel; a soul torch does not; no lit test.
     MOVE 2 TO WS-RKIND
     MOVE "warped_fungus" TO WS-NAME
     PERFORM TRY-ONE
     MOVE "acceptance US15 44-6§4.3 warped_fungus repels a hoglin" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "potted_warped_fungus" TO WS-NAME
     PERFORM TRY-ONE
     MOVE "acceptance US15 44-6§4.3 potted_warped_fungus repels a hoglin" TO TL-CASE
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "nether_portal" TO WS-NAME
     PERFORM TRY-ONE
     MOVE "acceptance US15 44-6§4.3 nether_portal repels a hoglin" TO TL-CASE
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "respawn_anchor" TO WS-NAME
     PERFORM TRY-ONE
     MOVE "acceptance US15 44-6§4.3 respawn_anchor repels a hoglin (no lit test)" TO TL-CASE
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "soul_torch" TO WS-NAME
     PERFORM TRY-ONE
     MOVE "acceptance US15 44-6§4.3 a soul torch does not repel a hoglin" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 TRY-ONE.
     MOVE 2 TO WS-OFF-X
     MOVE 0 TO WS-OY
     PERFORM TRY-OFFSET.

 TRY-OFFSET.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     IF WS-T = 1
         CALL "BLOCK-STATE-PROP" USING WS-MODE2 WS-STATE WS-PNAME WS-PFALSE WS-UNLIT
         MOVE WS-UNLIT TO WS-STATE
     END-IF
     COMPUTE WS-BX = WS-CX + WS-OFF-X
     COMPUTE WS-BY = WS-CY + WS-OY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-CZ WS-STATE
     CALL "PGB-REPEL" USING WS-ROW WS-RKIND WS-FOUND WS-RX WS-RY WS-RZ
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-CZ WS-AIR.
 END PROGRAM TEST-Q44-44-6-4.
 COPY CORETEST.
 COPY MOBSPTEST.
