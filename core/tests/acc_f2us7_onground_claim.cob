*> Acceptance test, US7-2 core half (the endless survival climb; docs/protocol/13 §1.3 "The jump rule":
*> a CobolCraft server may validate that vertical movement is consistent with it): a client that
*> sends on-ground = 1 while its feet have no support must not gain height. The claim is not accepted:
*> a move that rises while claiming the ground in the air is refused (Player Position back to the last
*> valid position, a new teleport id), a claim in the air that does not rise is accepted as a position
*> but does not count as ground (the fall start is kept, so no fall is forgiven). Alice is a survival
*> player standing on greystone at (20, 100, 20), feet y 101.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US7-ONGROUND-CLAIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 20.
 01 WS-Y                   BINARY-LONG VALUE 100.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-STATE               BINARY-LONG VALUE 2.
 01 WS-MOVE                BINARY-LONG VALUE 30.
 01 WS-FX                  FLOAT-LONG VALUE 20.5.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG VALUE 20.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-MILLI               BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-TEXT                PIC X(256).
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     PERFORM MOVE-ALICE
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS

     MOVE "acceptance US7-2 given a survival player on the ground when they send on-ground 1 "
         & "while standing on a block then the move is accepted and counts as ground" TO TL-CASE
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     PERFORM MOVE-ALICE
     MOVE "y 101000 ground 1 ids ." TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-2 given a player in the air (a jump, on-ground 0) when it sends "
         & "on-ground 1 at a higher feet y then the move is refused and it is sent Player Position "
         & "at the last valid position" TO TL-CASE
     MOVE 102 TO WS-FY
     MOVE 0 TO WS-FLAGS
     PERFORM MOVE-ALICE
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
     MOVE 103 TO WS-FY
     MOVE 1 TO WS-FLAGS
     PERFORM MOVE-ALICE
     MOVE "y 102000 ground 0 ids 73" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-2 given the endless climb (on-ground 1 claimed in the air on every step "
         & "up, each step acknowledged) when twenty steps are sent then the player has not gained "
         & "height and is sent Player Position for each" TO TL-CASE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         CALL "TEST-ACCEPT-TELEPORT" USING WS-ALICE
         COMPUTE WS-FY = 102 + WS-I
         MOVE 1 TO WS-FLAGS
         PERFORM MOVE-ALICE
     END-PERFORM
     MOVE "y 102000 ground 0 ids 73x20" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-2 given a player in the air when it falls (lower feet y) with on-ground "
         & "1 claimed then the position is taken, the claim is not ground and the fall start "
         & "stays the highest y" TO TL-CASE
     CALL "TEST-ACCEPT-TELEPORT" USING WS-ALICE
     MOVE 102 TO WS-FY
     MOVE 0 TO WS-FLAGS
     PERFORM MOVE-ALICE
     MOVE 101.5 TO WS-FY
     MOVE 1 TO WS-FLAGS
     PERFORM MOVE-ALICE
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
     COMPUTE WS-MILLI = PL-FALL-START(WS-ROW) * 1000
     MOVE WS-MILLI TO WS-EDIT
     MOVE SPACES TO WS-TEXT
     STRING "start " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "start 102000" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US7-2 given the player lands on the block (feet y 101, on-ground 1) then "
         & "it counts as ground again and may jump again" TO TL-CASE
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     PERFORM MOVE-ALICE
     MOVE 102 TO WS-FY
     MOVE 0 TO WS-FLAGS
     PERFORM MOVE-ALICE
     MOVE "y 102000 ground 0 ids ." TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 MOVE-ALICE.
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS.

*> Observed "y <milli> ground <0|1> ids <packet ids of what was sent to Alice since the last drain,
*> or . for none>".
 CHECK.
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
     COMPUTE WS-MILLI ROUNDED = PL-Y(WS-ROW) * 1000
     MOVE WS-MILLI TO WS-EDIT
     MOVE SPACES TO WS-TEXT
     STRING "y " FUNCTION TRIM(WS-EDIT) " ground " PL-ON-GROUND(WS-ROW) " ids "
         DELIMITED BY SIZE INTO WS-TEXT
     IF WS-IDS = SPACES
         MOVE "." TO WS-IDS
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-IDS) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-F2US7-ONGROUND-CLAIM.

 COPY CORETEST.
