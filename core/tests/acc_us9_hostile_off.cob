*> Acceptance test, US9-6 core half (spec US9 scenario 6; FR-009; tasks T541; standin-content
*> §12.4): while the hostile-mobs setting is off, no abend spawns, and every abend there is is
*> removed at once and at every tick (Remove Entities to its viewers); sodgrazers stay. Alice
*> (entity 1, creative) stands at the spawn point (4.5, 54, 8.5): at Time 16100 her spawn column is
*> (-6, 8) in block light 0, where an abend spawns with the setting on (acc_us9_spawning). The
*> abend stands on column (10, 3) (top 55), the sodgrazer on column (10, 13) (top 54) (§5.2).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US9-HOSTILE-OFF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY ENTITYTYPES.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG VALUE 10.5.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-TEXT                PIC X(1024).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS

     MOVE "acceptance US9-6 given hostile mobs off when Time reaches 16100 at night, where an "
         & "abend would spawn for Alice, then nothing spawns" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE 16099 TO CW-TIME
     CALL "TEST-TICKS" USING WS-ONE
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     PERFORM CHECK

     MOVE "acceptance US9-6 given hostile mobs off and an abend and a sodgrazer in the world (as "
         & "a saved world would load them) when a tick passes then the abend is removed and "
         & "Alice is told so, and the sodgrazer stays" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE ET-ABEND TO WS-TYPE
     MOVE 56 TO WS-Y
     MOVE 3.5 TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE ET-SODGRAZER TO WS-TYPE
     MOVE 55 TO WS-Y
     MOVE 13.5 TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     CALL "TEST-TICKS" USING WS-ONE
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE "78(2)" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US9-6 the sodgrazer (entity 3) is still in the world" TO TL-CASE
     MOVE 3 TO WS-ID
     CALL "TEST-FIND-ENTITY" USING WS-ID WS-ROW
     MOVE SPACES TO WS-TEXT
     IF WS-ROW > 0
         MOVE "present" TO WS-TEXT
     END-IF
     MOVE "present" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Opens the world; creative Alice joins at the spawn point and is drained; TL-EXPECTED is cleared.
 OPEN-AND-JOIN.
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US9-HOSTILE-OFF.

 COPY CORETEST.
