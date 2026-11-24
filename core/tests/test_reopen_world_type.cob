*> Bug lane bughang (operator report: the game hung opening a saved world; sampled, the main thread was inside the standard terrain pipeline,
*> reached through PLAY-JOIN, CHUNKS-INITIAL-BATCH, WORLD-CHUNK, WORLDGEN-STANDARD-CHUNK, GEN-STANDARD-INSTALL). A world opened from the list takes its
*> type from its level.dat (WORLD-TYPE-DECIDE, CW-WORLD-TYPE) whatever the host asks for, and the client asks for cobolcraft there (SP-CREATE-TYPE
*> keeps its default when no create screen ran). The generators and the generation queue must follow the world's type, not the request: a superflat
*> world reopened with the request cobolcraft made the standard terrain for every chunk of the first batch inside the join (625 chunks at view
*> distance 12), and a debug world reopened that way lost its grid.
*>   - A superflat world saved and reopened with the request cobolcraft joins in seconds and its chunks are flat (air above the grass layer).
*>   - The chunks of a superflat overworld are fed over the ticks by the generation queue (CHUNK-FEED-ON), never made inside the join: a flat chunk with its
*>     light costs 40 to 180 ms, so the view of the client (289 chunks at 8, 625 at 12) froze the window for one to two minutes.
*>   - A debug world saved and reopened with the request cobolcraft is still the debug world (WORLD-IS-DEBUG, WORLD-GEN-OWN).
*> Needs the generated packs (CC_GENERATED_DIR, default /tmp/cc-test/generated): without them the test passes as skipped.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-REOPEN-WORLD-TYPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-FOLDER              PIC X(64) VALUE Z"build/reopen-world-folder".
 01 WS-COMMAND             PIC X(200).
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-CREATED             BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 3.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG VALUE 3.
 01 WS-GRASS               BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-T0                  PIC X(21).
 01 WS-T1                  PIC X(21).
 01 WS-SECONDS             BINARY-LONG.
 01 WS-TEXT                PIC X(80).
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "test reopen world type no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF

*>   a superflat world is made and saved
     MOVE "rm -rf build/reopen-world-folder && mkdir -p build/reopen-world-folder" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "superflat" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 1 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED
     CALL "CORE-SAVE"

*>   reopened as the client opens it from the list: the request is cobolcraft, the level.dat says superflat
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "cobolcraft" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 1 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED
     MOVE "test reopen world type a superflat world opened with the request cobolcraft is superflat" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE CW-WORLD-TYPE TO TL-OBSERVED
     MOVE "superflat" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE FUNCTION CURRENT-DATE TO WS-T0
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE FUNCTION CURRENT-DATE TO WS-T1
     PERFORM ELAPSED
     MOVE "test reopen world type the join of a reopened superflat world takes seconds, not the standard pipeline of every chunk"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SECONDS < 20
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     MOVE -61 TO WS-Y
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-GRASS
     MOVE -60 TO WS-Y
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-ABOVE
     MOVE "test reopen world type the chunk of a reopened superflat world is flat: grass at -61 and air at -60" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-GRASS > 0 AND WS-ABOVE = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CHUNK-FEED-ON" USING WS-DIM WS-FLAG
     MOVE "test reopen world type the chunks of a superflat overworld come through the chunk feed (a view of 625 chunks is not made inside the join)"
         TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-GEN-OWN" USING WS-FLAG
     MOVE "test reopen world type WORLD-GEN-OWN is 1 for the reopened superflat world (no queue, no workers)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a debug world is made, saved and reopened the same way
     MOVE "rm -rf build/reopen-world-folder && mkdir -p build/reopen-world-folder" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "debug" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 1 TO CS-VIEW-DISTANCE
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED
     CALL "CORE-SAVE"
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "cobolcraft" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 1 TO CS-VIEW-DISTANCE
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED
     CALL "WORLD-IS-DEBUG" USING WS-FLAG
     MOVE "test reopen world type a debug world opened with the request cobolcraft is still the debug world" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 ELAPSED.
     COMPUTE WS-SECONDS = (FUNCTION NUMVAL(WS-T1(9:2)) * 3600 + FUNCTION NUMVAL(WS-T1(11:2)) * 60 + FUNCTION NUMVAL(WS-T1(13:2)))
         - (FUNCTION NUMVAL(WS-T0(9:2)) * 3600 + FUNCTION NUMVAL(WS-T0(11:2)) * 60 + FUNCTION NUMVAL(WS-T0(13:2)))
     .
 END PROGRAM TEST-REOPEN-WORLD-TYPE.
 COPY CORETEST.
