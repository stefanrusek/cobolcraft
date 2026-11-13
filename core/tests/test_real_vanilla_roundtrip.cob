*> Real-data check (vanfmt lane; skipped as a pass unless the environment variable CC_REAL_SAVE names a world folder of the 26.3 layout and
*> the generated packs are present): the folder is copied (the original is never touched), opened, two of its chunks are loaded
*> and marked changed, the world is saved, and the saved copy is checked: the keys of level.dat that the core does not model
*> are still there, the saved-data files read the same, the chunks hold the same blocks when the folder is opened again, and
*> the open world reports the same name, seed, time, weather and layout.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-REAL-VANILLA-ROUNDTRIP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CELLS.
 COPY PROTO.
 01 WS-REAL                PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-WORLD               PIC X(64) VALUE Z"build/real-save".
 01 WS-COMMAND             PIC X(1300).
 01 WS-CREATED             BINARY-LONG.
 01 WS-ROOT                BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-NAME-FILE           PIC X(256).
 01 WS-OBSERVED            PIC X(8192).
 01 WS-BEFORE              PIC X(8192).
 01 WS-ONE                 PIC X(8192).
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SUM-A               BINARY-DOUBLE.
 01 WS-SUM-B               BINARY-DOUBLE.
 01 WS-SUM-A2              BINARY-DOUBLE.
 01 WS-SUM-B2              BINARY-DOUBLE.
 01 WS-E1                  PIC -(19)9.
 01 WS-E2                  PIC -(19)9.
 01 WS-E3                  PIC -(19)9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-REAL
     ACCEPT WS-REAL FROM ENVIRONMENT "CC_REAL_SAVE"
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
     IF WS-REAL = SPACES OR RETURN-CODE NOT = 0
         MOVE "test real vanilla roundtrip no CC_REAL_SAVE or no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE SPACES TO WS-COMMAND
     STRING "rm -rf build/real-save && mkdir -p build/real-save && cp -R '" FUNCTION TRIM(WS-REAL TRAILING)
         "/.' build/real-save/" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "build/real-save/level.dat" TO WS-NAME-FILE
     CALL "TEST-NBT-FILE" USING WS-NAME-FILE PB-BUFFER WS-ROOT
     MOVE SPACES TO WS-BEFORE
     PERFORM LEVEL-KEYS
     MOVE WS-OBSERVED TO WS-BEFORE
     MOVE "T" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "CORE-WORLD-OPEN" USING WS-WORLD CORE-SETTINGS WS-CREATED
     PERFORM SHOW-WORLD
     MOVE WS-OBSERVED TO WS-ONE
     DISPLAY "real world: " FUNCTION TRIM(WS-ONE)
     MOVE WS-ONE TO WS-BEFORE(4001:2000)
*>   Load two chunks (the island and a corner) and mark them changed.
     MOVE CW-DIM(1) TO WS-DIM
     MOVE 0 TO WS-CX WS-CZ
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW
     MOVE 1 TO CK-CHANGED(WS-ROW)
     PERFORM CHECKSUM
     MOVE WS-SUM-A TO WS-SUM-A2
     MOVE -32 TO WS-CX WS-CZ
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW
     MOVE 1 TO CK-CHANGED(WS-ROW)
     PERFORM CHECKSUM
     MOVE WS-SUM-A TO WS-SUM-B2
     CALL "CORE-SAVE"
*>   The saved level.dat keeps every key of the original (unmodelled ones included).
     CALL "TEST-NBT-FILE" USING WS-NAME-FILE PB-BUFFER WS-ROOT
     PERFORM LEVEL-KEYS
     MOVE "test real vanilla roundtrip level.dat keeps the keys the core does not model" TO TL-CASE
     MOVE WS-BEFORE(1:4000) TO TL-EXPECTED
     MOVE WS-OBSERVED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Open the saved folder again.
     CALL "CORE-WORLD-OPEN" USING WS-WORLD CORE-SETTINGS WS-CREATED
     PERFORM SHOW-WORLD
     MOVE "test real vanilla roundtrip the saved folder opens as the same world" TO TL-CASE
     MOVE WS-BEFORE(4001:2000) TO TL-EXPECTED
     MOVE WS-OBSERVED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CW-DIM(1) TO WS-DIM
     MOVE 0 TO WS-CX WS-CZ
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW
     PERFORM CHECKSUM
     MOVE WS-SUM-A TO WS-E1
     MOVE WS-SUM-A2 TO WS-E2
     MOVE "test real vanilla roundtrip chunk 0 0 holds the same blocks after the save" TO TL-CASE
     MOVE FUNCTION TRIM(WS-E2) TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -32 TO WS-CX WS-CZ
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW
     PERFORM CHECKSUM
     MOVE WS-SUM-A TO WS-E1
     MOVE WS-SUM-B2 TO WS-E2
     MOVE "test real vanilla roundtrip chunk -32 -32 holds the same blocks after the save" TO TL-CASE
     MOVE FUNCTION TRIM(WS-E2) TO TL-EXPECTED
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> WS-OBSERVED: the Data keys of the level.dat in PB-BUFFER that the core keeps: renders of the unmodelled ones.
 LEVEL-KEYS.
     MOVE SPACES TO WS-OBSERVED
     MOVE "Data.ServerBrands" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.WasModded" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.Version.Series" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.singleplayer_uuid" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.difficulty_settings" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.DataPacks" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.allowCommands" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.initialized" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.version" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.LevelName" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.spawn.pos" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.spawn.dimension" TO WS-PATH PERFORM ADD-GET.

 SHOW-WORLD.
     MOVE CW-SEED TO WS-E1
     MOVE CW-TIME TO WS-E2
     MOVE CW-RAIN-TIME TO WS-E3
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(CW-NAME) "|" FUNCTION TRIM(CW-WORLD-TYPE) "|" CW-LAYOUT "|" FUNCTION TRIM(WS-E1) "|"
         FUNCTION TRIM(WS-E2) "|" FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-OBSERVED.

*> WS-SUM-A: the sum of the block state ids of the chunk of WS-ROW over the dimension's cells.
 CHECKSUM.
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     MOVE 0 TO WS-SUM-A
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CE-STATE-CELLS
         ADD CE-STATE(WS-I) TO WS-SUM-A
     END-PERFORM.

 ADD-GET.
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-ONE
     STRING FUNCTION TRIM(WS-OBSERVED) " " FUNCTION TRIM(WS-ONE) DELIMITED BY SIZE INTO WS-OBSERVED.
 END PROGRAM TEST-REAL-VANILLA-ROUNDTRIP.

 COPY CORETEST.
