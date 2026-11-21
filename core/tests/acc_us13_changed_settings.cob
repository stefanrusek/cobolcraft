*> Acceptance test, US13 edge case "existing world folder and a changed configuration" core half
*> (spec US13 edge cases; operator decision A2; tasks T618): a saved world opened again with changed
*> settings keeps the world (a changed block, the time, a player record) and applies the new
*> settings (the description and the view distance new players get); the allow-list setting does
*> not override the enforcement flag stored in the world's access.dat.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US13-CHANGED-SETTINGS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
  01 WS-WORLD               PIC X(64) VALUE Z"build/core-test-world".
 01 WS-CREATED             BINARY-LONG.
 01 WS-ALICE-NAME          PIC X(16) VALUE "Alice".
 01 WS-LENGTH-5            BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 2.
 01 WS-Y                   BINARY-LONG VALUE 70.
 01 WS-Z                   BINARY-LONG VALUE 2.
 01 WS-STATE               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS CS-ALLOW-LIST-ENFORCED
     MOVE 1 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     MOVE 12 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-JOIN" USING WS-ALICE-NAME WS-LENGTH-5 WS-ALICE
     MOVE 77 TO PL-X(CN-PLAYER(WS-ALICE))
     CALL "CORE-CONN-CLOSED" USING WS-ALICE
     CALL "CORE-SAVE"

     MOVE "US13 edge given an existing world and changed settings when opened then the world is "
         & "kept (block, time, Alice's place) and the new settings apply (description, view "
         & "distance)" TO TL-CASE
     MOVE "Changed description" TO CS-DESCRIPTION
     MOVE 5 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE "Another name" TO CS-NEW-WORLD-NAME
     MOVE 1 TO CS-ALLOW-LIST-ENFORCED
     CALL "CORE-WORLD-OPEN" USING WS-WORLD CORE-SETTINGS WS-CREATED
     CALL "TEST-JOIN" USING WS-ALICE-NAME WS-LENGTH-5 WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE SPACES TO WS-TEXT
     MOVE WS-CREATED TO WS-EDIT
     STRING "created " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE WS-STATE TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " block " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO WS-TEXT
     MOVE CW-TIME TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " time " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO WS-TEXT
     COMPUTE WS-EDIT = PL-X(WS-ROW)
     STRING FUNCTION TRIM(WS-TEXT) " x " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE PL-MODE(WS-ROW) TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " mode " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO WS-TEXT
     MOVE "x" TO CS-DESCRIPTION
     MOVE 0 TO CS-VIEW-DISTANCE
     MOVE CW-SETTINGS TO CORE-SETTINGS
     MOVE CS-VIEW-DISTANCE TO WS-EDIT
     STRING FUNCTION TRIM(WS-TEXT) " view " FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(CW-NAME)
         " | " FUNCTION TRIM(CS-DESCRIPTION) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "created 0 block 12 time 16001 x 77 mode 1 view 5 New World | Changed description"
         TO TL-EXPECTED
     PERFORM CHECK

     MOVE "US13 edge the allow-list setting does not override the enforcement flag stored in the "
         & "world's access.dat (A2): saved off, reopened with the setting on, still off"
         TO TL-CASE
     MOVE AC-ENFORCED TO WS-EDIT
     MOVE SPACES TO WS-TEXT
     STRING "enforced " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "enforced 0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US13-CHANGED-SETTINGS.

 COPY CORETEST.
