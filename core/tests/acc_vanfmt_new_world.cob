*> Acceptance test (vanfmt lane; operator rule: the standard world type uses the vanilla layout; docs/protocol/07 section 10): a new
*> standard world is created and saved in the 26.3 layout: level.dat holds the compound Data (name, game type, spawn, Time,
*> version 19133, the default sets) and no WorldType, the seed is in data/minecraft/world_gen_settings.dat, the clock, weather
*> and rules files exist, the player file is players/data/<uuid>.dat; when the folder is opened again the world is standard
*> with the same name and seed. A cobolcraft-type world keeps the flat layout (WorldType key, no Data). Skipped as a pass
*> without the generated packs for the standard part (CC_GENERATED_DIR, default /tmp/cc-test/generated).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-VANFMT-NEW-WORLD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-WORLD               PIC X(64) VALUE Z"build/core-test-world".
 01 WS-CREATED             BINARY-LONG.
 01 WS-ROOT                BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-NAME-FILE           PIC X(256).
 01 WS-OBSERVED            PIC X(8192).
 01 WS-ONE                 PIC X(8192).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(19)9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
*>   The cobolcraft type: the flat layout.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "CORE-SAVE"
     MOVE "build/core-test-world/level.dat" TO WS-NAME-FILE
     CALL "TEST-NBT-FILE" USING WS-NAME-FILE PB-BUFFER WS-ROOT
     MOVE SPACES TO WS-OBSERVED
     MOVE "WorldType" TO WS-PATH PERFORM ADD-GET
     MOVE "Data" TO WS-PATH PERFORM ADD-GET
     MOVE "acceptance vanfmt new world: a cobolcraft world keeps the flat layout (WorldType, no Data)" TO TL-CASE
     MOVE "cobolcraft absent" TO TL-EXPECTED
     PERFORM CHECK

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
         MOVE "acceptance vanfmt new world no generated packs here, standard part skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "Vanilla New" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "CORE-SAVE"
     MOVE "build/core-test-world/level.dat" TO WS-NAME-FILE
     CALL "TEST-NBT-FILE" USING WS-NAME-FILE PB-BUFFER WS-ROOT
     MOVE SPACES TO WS-OBSERVED
     MOVE "Data.LevelName" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.version" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.DataVersion" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.GameType" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.spawn.dimension" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.initialized" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.DataPacks" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.difficulty_settings.difficulty" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.Version.Series" TO WS-PATH PERFORM ADD-GET
     MOVE "WorldType" TO WS-PATH PERFORM ADD-GET
     MOVE "acceptance vanfmt new world: a standard world's level.dat is Data with the default keys and no WorldType" TO TL-CASE
     MOVE "Vanilla New 19133 5023 1 minecraft:overworld 1 {Enabled:[vanilla],Disabled:[]} normal main absent"
         TO TL-EXPECTED
     PERFORM CHECK

     MOVE "build/core-test-world/data/minecraft/world_gen_settings.dat" TO WS-NAME-FILE
     CALL "TEST-NBT-FILE" USING WS-NAME-FILE PB-BUFFER WS-ROOT
     MOVE SPACES TO WS-OBSERVED
     MOVE "data.seed" TO WS-PATH PERFORM ADD-GET
     MOVE "data.generate_structures" TO WS-PATH PERFORM ADD-GET
     MOVE "data.bonus_chest" TO WS-PATH PERFORM ADD-GET
     MOVE "acceptance vanfmt new world: world_gen_settings.dat holds the seed" TO TL-CASE
     MOVE "12345 1 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "build/core-test-world/data/minecraft/world_clocks.dat" TO WS-NAME-FILE
     CALL "TEST-NBT-FILE" USING WS-NAME-FILE PB-BUFFER WS-ROOT
     MOVE SPACES TO WS-OBSERVED
     MOVE "data.minecraft:overworld.rate" TO WS-PATH PERFORM ADD-GET
     MOVE "acceptance vanfmt new world: world_clocks.dat holds the overworld clock" TO TL-CASE
     MOVE "1.000" TO TL-EXPECTED
     PERFORM CHECK

*>   Opened again: the same world.
     MOVE 0 TO CW-SEED
     CALL "CORE-WORLD-OPEN" USING WS-WORLD CORE-SETTINGS WS-CREATED
     MOVE WS-CREATED TO WS-E1
     MOVE CW-SEED TO WS-E2
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-E1) "|" FUNCTION TRIM(CW-NAME) "|" FUNCTION TRIM(CW-WORLD-TYPE) "|"
         FUNCTION TRIM(WS-E2) "|" CW-LAYOUT DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "acceptance vanfmt new world: opened again it is the same standard world in the vanilla layout" TO TL-CASE
     MOVE "0|Vanilla New|standard|12345|1" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 ADD-GET.
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-ONE
     STRING FUNCTION TRIM(WS-OBSERVED) " " FUNCTION TRIM(WS-ONE) DELIMITED BY SIZE INTO WS-OBSERVED.

 CHECK.
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-VANFMT-NEW-WORLD.

 COPY CORETEST.
