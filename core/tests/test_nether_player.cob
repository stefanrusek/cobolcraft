*> Implementation test (lane nether, work plan A; docs/protocol/37-nether-1 section 5.5 and 6.8, 38 section 2, 39 section 8): in a standard
*> world with the extra dimensions on, a player switched into minecraft:the_nether (DIM-SWITCH, the travel the portals use) gets
*> Respawn first and then the join sequence of the nether; weather does not exist there (no rain level, no weather events, the overworld's
*> rain stays in the overworld); the player's position and dimension are kept when she disconnects and rejoins, and the saved player file's
*> Dimension string round trips for the_nether and the_end after the world is opened again. Needs the generated packs
*> (CC_GENERATED_DIR, default /tmp/cc-test/generated): a pass without them.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-PLAYER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DEST                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-TICKS               BINARY-LONG VALUE 5.
 01 WS-DRIZZLE             BINARY-LONG VALUE 2.
 01 WS-TIME                BINARY-LONG VALUE 100000.
 01 WS-CREATED             BINARY-LONG.
 01 WS-WORLD               PIC X(64) VALUE Z"build/core-test-world".
 01 WS-TEXT                PIC X(4096).
 01 WS-TEXT2               PIC X(4096).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-F1                  PIC -(5)9.9.
 01 WS-F2                  PIC -(5)9.9.
 01 WS-F3                  PIC -(5)9.9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
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
         MOVE "test nether player no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-DEFAULT-MODE CS-HOSTILE-MOBS
     MOVE 1 TO CS-EXTRA-DIMENSIONS CS-WEATHER-CHANGES
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW

     MOVE "test nether player switched into the nether Alice is sent Respawn, abilities, held slot, inventory, "
         & "Set Health, spawn, Set Time, game event 13, the chunk batch and Player Position (no weather pair)" TO TL-CASE
     MOVE DIM-STANDARD-NETHER TO WS-DEST
     MOVE 10.5 TO WS-X
     MOVE 41 TO WS-Y
     MOVE 10.5 TO WS-Z
     CALL "DIM-SWITCH" USING WS-ROW WS-DEST WS-X WS-Y WS-Z
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "84 65 107 18 106 99 115 39 96 12 46x25 11 73" TO TL-EXPECTED
     PERFORM CHECK
     CALL "TEST-ACCEPT-TELEPORT" USING WS-ALICE

     MOVE "test nether player she is in dimension row 4 at (10.5, 41, 10.5)" TO TL-CASE
     MOVE PL-DIM(WS-ROW) TO WS-E1
     COMPUTE WS-F1 = PL-X(WS-ROW)
     COMPUTE WS-F2 = PL-Y(WS-ROW)
     COMPUTE WS-F3 = PL-Z(WS-ROW)
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-F1) " " FUNCTION TRIM(WS-F2) " " FUNCTION TRIM(WS-F3)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "4 10.5 41.0 10.5" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK

     MOVE "test nether player rain in the overworld does not reach the nether: no level and no weather events for Alice" TO TL-CASE
     CALL "WEATHER-SET-KIND" USING WS-DRIZZLE WS-TIME
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     MOVE CW-RAIN-LEVEL(DIM-STANDARD-NETHER) TO WS-F1
     MOVE SPACES TO TL-OBSERVED
     STRING "[" FUNCTION TRIM(WS-TEXT) "] level " FUNCTION TRIM(WS-F1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "[] level 0.0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test nether player she disconnects and rejoins: dimension row 4 and her place are kept" TO TL-CASE
     CALL "CORE-CONN-CLOSED" USING WS-ALICE
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-E1
     COMPUTE WS-F1 = PL-X(WS-ROW)
     COMPUTE WS-F2 = PL-Y(WS-ROW)
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-F1) " " FUNCTION TRIM(WS-F2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "4 10.5 41.0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test nether player the saved player file survives the world being opened again: still in the nether" TO TL-CASE
     CALL "CORE-SAVE"
     CALL "CORE-CONN-CLOSED" USING WS-ALICE
     CALL "CORE-WORLD-OPEN" USING WS-WORLD CORE-SETTINGS WS-CREATED
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-E1
     MOVE WS-CREATED TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " created " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "4 created 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test nether player the same for the end: switched, saved, reopened and rejoined she is in row 5" TO TL-CASE
     MOVE DIM-STANDARD-END TO WS-DEST
     MOVE 0.5 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 0.5 TO WS-Z
     CALL "DIM-SWITCH" USING WS-ROW WS-DEST WS-X WS-Y WS-Z
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     CALL "CORE-SAVE"
     CALL "CORE-CONN-CLOSED" USING WS-ALICE
     CALL "CORE-WORLD-OPEN" USING WS-WORLD CORE-SETTINGS WS-CREATED
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE PL-DIM(CN-PLAYER(WS-ALICE)) TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE "5" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-NETHER-PLAYER.

 COPY CORETEST.
