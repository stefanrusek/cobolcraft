*> Implementation test of on-ground and fall-start tracking (core/src/movement.cob MOVE-PLAYER; tasks
*> T414; data-model §6 "last fall start"; standin-content §10.3 "Fall distance": the fall start is
*> the highest feet y since the player was last on the ground, and follows the feet y while the
*> player is on the ground, flying or in creative mode). A survival player joins at the spawn.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ON-GROUND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PACKET              BINARY-LONG.
 01 WS-X                   FLOAT-LONG VALUE 4.5.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG VALUE 8.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-REAL                FLOAT-LONG.
 01 WS-TEXT                PIC X(256).
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT                PIC 9.
 01 WS-EDIT-REAL           PIC -(6)9.99.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW

     MOVE "test on ground: Move Player Status Only sets the on-ground flag from MoveFlags bit "
         & "0x01 (0x02 alone is off the ground, 0x03 on it)" TO TL-CASE
     PERFORM START-ROW
     MOVE 33 TO WS-PACKET
     MOVE 2 TO WS-FLAGS
     PERFORM DO-MOVE
     PERFORM ADD-STATE
     MOVE 3 TO WS-FLAGS
     PERFORM DO-MOVE
     PERFORM ADD-STATE
     MOVE "0 54.00 1 54.00 " TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test on ground: a survival player jumping keeps the highest feet y as fall start "
         & "while off the ground, and landing sets it to the feet y" TO TL-CASE
     PERFORM START-ROW
     MOVE 30 TO WS-PACKET
     MOVE 0 TO WS-FLAGS
     MOVE 55.25 TO WS-Y
     PERFORM DO-MOVE
     PERFORM ADD-STATE
     MOVE 54.5 TO WS-Y
     PERFORM DO-MOVE
     PERFORM ADD-STATE
     MOVE 1 TO WS-FLAGS
     MOVE 54.0 TO WS-Y
     PERFORM DO-MOVE
     PERFORM ADD-STATE
     MOVE "0 55.25 0 55.25 1 54.00 " TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test on ground: off the ground, a flying player's and a creative player's fall start "
         & "follows the feet y downward" TO TL-CASE
     PERFORM START-ROW
     MOVE 0 TO WS-FLAGS
     MOVE 60.0 TO WS-Y
     PERFORM DO-MOVE
     MOVE 1 TO PL-FLYING(WS-ROW)
     MOVE 58.0 TO WS-Y
     PERFORM DO-MOVE
     PERFORM ADD-STATE
     MOVE 0 TO PL-FLYING(WS-ROW)
     MOVE 1 TO PL-MODE(WS-ROW)
     MOVE 57.0 TO WS-Y
     PERFORM DO-MOVE
     PERFORM ADD-STATE
     MOVE "0 58.00 0 57.00 " TO TL-EXPECTED
     PERFORM ASSERT-ROW
     STOP RUN.

 DO-MOVE.
     CALL "TEST-MOVE" USING WS-CONN WS-PACKET WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-FLAGS.

 ADD-STATE.
     MOVE PL-ON-GROUND(WS-ROW) TO WS-EDIT
     STRING WS-EDIT " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     MOVE PL-FALL-START(WS-ROW) TO WS-EDIT-REAL
     STRING FUNCTION TRIM(WS-EDIT-REAL) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR.

 START-ROW.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR.

 ASSERT-ROW.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ON-GROUND.

 COPY CORETEST.
