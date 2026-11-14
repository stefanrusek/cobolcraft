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
 01 WS-SUFFIX              PIC X(128).
 01 WS-VCMD                PIC X(200).
 01 WS-KN                  PIC X(32).
 01 WS-KL                  BINARY-LONG.
 01 WS-KV                  BINARY-LONG.
 01 WS-KSEED               BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-STEM                PIC X(16).
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

*>   The loader needs the dimensions map with an overworld stem (07 section 10.4.5: "Overworld settings missing"); each stem has
*>   type and generator, a noise generator has settings and a biome_source with a type.
     MOVE SPACES TO WS-OBSERVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         EVALUATE WS-I
             WHEN 1 MOVE "overworld" TO WS-STEM
             WHEN 2 MOVE "the_nether" TO WS-STEM
             WHEN 3 MOVE "the_end" TO WS-STEM
         END-EVALUATE
         MOVE SPACES TO WS-PATH
         STRING "data.dimensions.minecraft:" FUNCTION TRIM(WS-STEM) ".type" DELIMITED BY SIZE INTO WS-PATH
         PERFORM ADD-GET
         MOVE SPACES TO WS-PATH
         STRING "data.dimensions.minecraft:" FUNCTION TRIM(WS-STEM) ".generator.type" DELIMITED BY SIZE INTO WS-PATH
         PERFORM ADD-GET
         MOVE SPACES TO WS-PATH
         STRING "data.dimensions.minecraft:" FUNCTION TRIM(WS-STEM) ".generator.settings" DELIMITED BY SIZE INTO WS-PATH
         PERFORM ADD-GET
         MOVE SPACES TO WS-PATH
         STRING "data.dimensions.minecraft:" FUNCTION TRIM(WS-STEM) ".generator.biome_source.type"
             DELIMITED BY SIZE INTO WS-PATH
         PERFORM ADD-GET
     END-PERFORM
     MOVE "data.dimensions.minecraft:overworld.generator.biome_source.preset" TO WS-PATH PERFORM ADD-GET
     MOVE "data.dimensions.minecraft:the_nether.generator.biome_source.preset" TO WS-PATH PERFORM ADD-GET
     MOVE "acceptance vanfmt new world: world_gen_settings.dat holds the dimensions map with the three standard stems" TO TL-CASE
     STRING "minecraft:overworld minecraft:noise minecraft:overworld minecraft:multi_noise "
         "minecraft:the_nether minecraft:noise minecraft:nether minecraft:multi_noise "
         "minecraft:the_end minecraft:noise minecraft:end minecraft:the_end "
         "minecraft:overworld minecraft:nether" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK


*>   The read-back checker (tools/validate_world.py) applies the loader's requirements to what was written.
     MOVE "python3 -I tools/validate_world.py build/core-test-world > build/core-test-world.validate 2>&1" TO WS-VCMD
     CALL "SYSTEM" USING WS-VCMD
     MOVE RETURN-CODE TO WS-E1
     MOVE SPACES TO WS-OBSERVED
     MOVE FUNCTION TRIM(WS-E1) TO WS-OBSERVED
     MOVE "acceptance vanwrite the saved folder passes the read-back checker (tools/validate_world.py: Data, dimensions, regions)" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
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

*>   A world_gen_settings.dat that an earlier build wrote without the dimensions map is repaired by the next save, and a member
*>   the core does not know stays; a file that has the map keeps it as it is (the Seed of such a file is the core's).
     MOVE "/data/minecraft/world_gen_settings.dat" TO WS-SUFFIX
     CALL "VFMT-SAVED-BEGIN" USING PB-BUFFER
     MOVE "seed" TO WS-KN MOVE 4 TO WS-KL
     MOVE 12345 TO WS-KSEED
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WS-KN WS-KL WS-KSEED
     MOVE "keep_me" TO WS-KN MOVE 7 TO WS-KL
     MOVE 77 TO WS-KV
     CALL "NBT-WRITE-INT" USING PB-BUFFER WS-KN WS-KL WS-KV
     CALL "VFMT-SAVED-END" USING PB-BUFFER WS-SUFFIX
     CALL "CORE-SAVE"
     MOVE "build/core-test-world/data/minecraft/world_gen_settings.dat" TO WS-NAME-FILE
     CALL "TEST-NBT-FILE" USING WS-NAME-FILE PB-BUFFER WS-ROOT
     MOVE SPACES TO WS-OBSERVED
     MOVE "data.keep_me" TO WS-PATH PERFORM ADD-GET
     MOVE "data.dimensions.minecraft:overworld.generator.type" TO WS-PATH PERFORM ADD-GET
     MOVE "data.dimensions.minecraft:the_end.type" TO WS-PATH PERFORM ADD-GET
     MOVE "acceptance vanfmt new world: a file without dimensions gets them at the next save and keeps unknown members" TO TL-CASE
     MOVE "77 minecraft:noise minecraft:the_end" TO TL-EXPECTED
     PERFORM CHECK
     CALL "CORE-SAVE"
     CALL "TEST-NBT-FILE" USING WS-NAME-FILE PB-BUFFER WS-ROOT
     MOVE SPACES TO WS-OBSERVED
     MOVE "data.keep_me" TO WS-PATH PERFORM ADD-GET
     MOVE "data.dimensions.minecraft:overworld.type" TO WS-PATH PERFORM ADD-GET
     MOVE "acceptance vanfmt new world: a file that has the map keeps it at the next save" TO TL-CASE
     MOVE "77 minecraft:overworld" TO TL-EXPECTED
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
