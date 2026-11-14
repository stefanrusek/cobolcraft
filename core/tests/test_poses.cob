 *> Implementation test of the player poses on the server (T6201; docs/protocol/53 sections 1 to 3 and 10; core/src/poses.cob, movement.cob):
*> Player Input with the shift flag gives the pose crouching (5) and the shared flags byte bit 0x02, sent to the player who sees it in Set Entity
*> Data (0x65) and to one who comes into view later; a player whose standing box does not fit under a ceiling is crouching (1.5 gap) or
*> crawling (pose 3, 1.0 gap) with the shift key up; a crouching player's move under a 1.5 ceiling is accepted (the standing box would be refused).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-POSES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CONTENT.
 01 WS-ALICE-NAME          PIC X(16) VALUE "Alice".
 01 WS-BOB-NAME            PIC X(16) VALUE "Bob".
 01 WS-CHARLIE-NAME        PIC X(16) VALUE "Charlie".
 01 WS-5                   BINARY-LONG VALUE 5.
 01 WS-3                   BINARY-LONG VALUE 3.
 01 WS-7                   BINARY-LONG VALUE 7.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-CHARLIE             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-TALLY               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 5.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG VALUE 8.
 01 WS-STONE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-PACKET              BINARY-LONG VALUE 30.
 01 WS-MX                  FLOAT-LONG.
 01 WS-MY                  FLOAT-LONG.
 01 WS-MZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-ALICE-NAME WS-5 WS-ALICE
     CALL "TEST-JOIN" USING WS-BOB-NAME WS-3 WS-BOB
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE CN-PLAYER(WS-BOB) TO WS-ROW
     MOVE CB-DEFAULT-STATE(CR-GREYSTONE + 1) TO WS-STONE
     MOVE "T" TO TL-MODE

     MOVE "test poses Player Input shift: Alice, who sees Bob, gets Set Entity Data (101) once" TO TL-CASE
     MOVE 32 TO WS-FLAGS
     CALL "TEST-INPUT" USING WS-BOB WS-FLAGS
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE "101" TO TL-EXPECTED
     MOVE WS-TEXT(1:30) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "test poses Player Input shift: Bob is crouching, pose 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE PL-POSE(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test poses Player Input shift: the flags byte has bit 0x02" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE PL-POSE-FLAGS(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The same Input again changes nothing, so nothing is sent.
     CALL "TEST-INPUT" USING WS-BOB WS-FLAGS
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE "test poses an unchanged state sends nothing" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-TEXT(1:30) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Charlie comes into view later: his join carries Bob's Add Entity and Bob's pose in Set Entity Data.
     CALL "TEST-JOIN-UNDRAINED" USING WS-CHARLIE-NAME WS-7 WS-CHARLIE
     CALL "TEST-DRAIN-IDS" USING WS-CHARLIE WS-TEXT
     MOVE 0 TO WS-TALLY
     INSPECT WS-TEXT TALLYING WS-TALLY FOR ALL " 101 "
     MOVE "N" TO TL-MODE
     MOVE "test poses a player who comes into view later gets Bob's pose (Set Entity Data after Add Entity)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TALLY > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO WS-FLAGS
     CALL "TEST-INPUT" USING WS-BOB WS-FLAGS
     MOVE "test poses releasing shift: Bob stands again" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-POSE(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Sprinting is bit 0x08 of the flags.
     MOVE 1 TO WS-FLAGS
     CALL "TEST-PLAYER-COMMAND" USING WS-BOB WS-FLAGS
     MOVE "test poses sprinting sets bit 0x08 of the flags" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE PL-POSE-FLAGS(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-FLAGS
     CALL "TEST-PLAYER-COMMAND" USING WS-BOB WS-FLAGS

*>   A ceiling 1.5 above Bob's feet (feet 70.5, stone with its underside at 72): standing does not fit, crouching does.
     MOVE 72 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
     MOVE 5.5 TO PL-X(WS-ROW)
     MOVE 70.5 TO PL-Y(WS-ROW)
     MOVE 8.5 TO PL-Z(WS-ROW)
     MOVE 0 TO WS-FLAGS
     CALL "TEST-INPUT" USING WS-BOB WS-FLAGS
     MOVE "test poses a 1.5 gap above the feet with the shift key up: crouching (forced), flags 0" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE PL-POSE(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test poses the forced crouch does not set the shift flag bit" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-POSE-FLAGS(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-ACCEPT-TELEPORT" USING WS-BOB
     MOVE 5.6 TO WS-MX
     MOVE 70.5 TO WS-MY
     MOVE 8.5 TO WS-MZ
     MOVE 0 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-BOB WS-PACKET WS-MX WS-MY WS-MZ WS-YAW WS-PITCH WS-FLAGS
     MOVE "test poses a crouching player moves under the 1.5 ceiling (position accepted)" TO TL-CASE
     COMPUTE TL-OBSERVED-N ROUNDED = PL-X(WS-ROW) * 10
     MOVE 56 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A 1.0 gap: only the swimming box (0.6) fits, the crawl pose 3.
     MOVE 71.0 TO PL-Y(WS-ROW)
     MOVE 5.5 TO PL-X(WS-ROW)
     CALL "TEST-INPUT" USING WS-BOB WS-FLAGS
     MOVE "test poses a 1.0 gap: crawling, pose 3" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE PL-POSE(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Free again: standing.
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
     CALL "TEST-INPUT" USING WS-BOB WS-FLAGS
     MOVE "test poses with the ceiling gone the player stands again" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-POSE(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-POSES.

 COPY CORETEST.
 COPY BETEST.
