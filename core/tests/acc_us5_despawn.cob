*> Acceptance test, US5-4 core half and the US5 despawn edge case (spec US5 scenario 4; tasks T473;
*> docs/protocol/41 section 5.1, replacing standin-content §9.2 step 2): a ground item whose age reaches 6000 ticks disappears
*> for every viewer (Remove Entities); the age advances in every tick the item is processed, whoever is near, and an item whose
*> chunk is not loaded (no player within the view distance keeps it) is not processed at all. View distance 2, survival. Alice
*> (entity 1, pry_bar held) breaks greystone at
*> (22, 101, 20) on greystone at (22, 100, 20) while she stands at (22.5, 101, 26.5) and Bob
*> (entity 2) at (25.5, 101, 26.5): near the item but out of pickup range. Keep Alives are answered
*> during the long runs (TEST-TICKS-ANSWERED).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US5-DESPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 22.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-STATE               BINARY-LONG VALUE 2.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-ACTION              BINARY-LONG.
 01 WS-SLOT                BINARY-LONG VALUE 8.
 01 WS-TICKS               BINARY-LONG.
 01 WS-MOVE                BINARY-LONG VALUE 30.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG VALUE 101.0.
 01 WS-FZ                  FLOAT-LONG VALUE 26.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 1.
 01 WS-FLOOR-X             BINARY-LONG.
 01 WS-FLOOR-Z             BINARY-LONG VALUE 26.
 01 WS-FLOOR-Y             BINARY-LONG VALUE 100.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-ALICE-TEXT          PIC X(1024).
 01 WS-BOB-TEXT            PIC X(1024).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
*>   No mob spawns during the test: night (standin §4.8) with hostile mobs off, where §12.4
*>   names only the abend for cobolcraft:main.
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE 100 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
*>   Greystone under the players: a break by a player in the air is five times slower (13 section 2.1).
     PERFORM VARYING WS-FLOOR-X FROM 20 BY 1 UNTIL WS-FLOOR-X > 26
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FLOOR-X WS-FLOOR-Y WS-FLOOR-Z WS-STATE
     END-PERFORM
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     MOVE 22.5 TO WS-FX
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 25.5 TO WS-FX
     CALL "TEST-MOVE" USING WS-BOB WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS

     MOVE "acceptance US5-4 given a ground item with players near when 5999 ticks have passed "
         & "then it is still there with age 5999" TO TL-CASE
     PERFORM BREAK-BLOCK
     MOVE 3 TO WS-ENTITY
     MOVE 5999 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-ENTITIES" USING WS-BOB WS-TEXT
     PERFORM DESCRIBE-AGE
     MOVE "row in use age 5999" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US5-4 given a ground item when it has aged the lifetime (6000 ticks) "
         & "then it disappears for everyone (Remove Entities to each viewer)" TO TL-CASE
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE WS-TEXT TO WS-ALICE-TEXT
     CALL "TEST-DRAIN-ENTITIES" USING WS-BOB WS-TEXT
     MOVE WS-TEXT TO WS-BOB-TEXT
     CALL "TEST-FIND-ENTITY" USING WS-ENTITY WS-ROW
     MOVE WS-ROW TO WS-E2
     MOVE SPACES TO WS-TEXT
     STRING "Alice " FUNCTION TRIM(WS-ALICE-TEXT) " Bob " FUNCTION TRIM(WS-BOB-TEXT) " row "
         FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "Alice 78(3) Bob 78(3) row 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US5 edge given a ground item whose chunk no player keeps loaded "
         & "then it is not processed and its age does not advance" TO TL-CASE
     PERFORM BREAK-BLOCK
     MOVE 4 TO WS-ENTITY
     MOVE 80.5 TO WS-FX
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-MOVE" USING WS-BOB WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 200 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     PERFORM DESCRIBE-AGE
     MOVE "row in use age 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US5 edge given that ground item when a player comes near again then its "
         & "chunk is processed again and the age advances, one per tick" TO TL-CASE
     MOVE 22.5 TO WS-FX
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 10 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM DESCRIBE-AGE
     MOVE "row in use age 10" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Puts greystone at (22, 101, 20) and breaks it as Alice with the pry_bar (7 ticks).
 BREAK-BLOCK.
     MOVE 101 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-ACTION
     PERFORM ACT
     MOVE 7 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 3 TO WS-ACTION
     PERFORM ACT.

 ACT.
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-ALICE WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ.

*> WS-TEXT: "row in use age <age>" of ground item WS-ENTITY, or "no row".
 DESCRIBE-AGE.
     CALL "TEST-FIND-ENTITY" USING WS-ENTITY WS-ROW
     MOVE "no row" TO WS-TEXT
     IF WS-ROW > 0
         MOVE EN-AGE(WS-ROW) TO WS-E1
         MOVE SPACES TO WS-TEXT
         STRING "row in use age " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-TEXT
     END-IF.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US5-DESPAWN.

 COPY CORETEST.
