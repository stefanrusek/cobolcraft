*> Acceptance test, bug lane bugskyblock (operator report, try19: "my skyblock world bugged out and started generating chunks"). A skyblock world is
*> void everywhere except its island, and a world of a real 26.3 game declares its overworld generator in data/minecraft/world_gen_settings.dat
*> (07 section 10.4.5, 56 section 2.5). The type of such a folder was always "standard" (level.dat with the compound Data and no WorldType, WT-26), so
*> every chunk absent from the region files (all but the island's) got the standard noise terrain, whatever the file declared: a flat void world, a
*> generator a mod registered (skyblock:void_island) and a noise generator with another namespace's settings all grew mountains around the island.
*>   - WORLD-TYPE-DECIDE reads the overworld stem's generator: minecraft:flat is a superflat world (its own settings), minecraft:debug the debug world,
*>     minecraft:noise with a minecraft: settings id (or none) the standard world; any other generator type, or noise settings of another namespace,
*>     is one this core cannot generate: its chunks are void (the void preset of 56 section 3.2, FS-FALLBACK 1) and the file is kept as found.
*>   - With the generated packs: a joined world of each declared kind has void chunks around the saved island block, the island block survives a save
*>     and a reopen, and the saved world_gen_settings.dat still declares the generator it came with, with its nether and end stems.
*> Part 2 needs the generated packs (CC_GENERATED_DIR, default /tmp/cc-test/generated): without them it is skipped. Fixtures: gen_skyblock.py.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-SKYBLOCK-VOID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY FLATSET.
 COPY PROTO.
 01 WS-COMMAND             PIC X(200).
 01 WS-FOLDER              PIC X(64) VALUE Z"build/skyblock-folder".
 01 WS-VARIANT             PIC X(10).
 01 WS-REQUEST             PIC X(10) VALUE SPACES.
 01 WS-TYPE                PIC X(10).
 01 WS-STATUS              BINARY-LONG.
 01 WS-OBSERVED            PIC X(300).
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-CREATED             BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FALLBACK            PIC 9.
 01 WS-ISLAND              BINARY-LONG.
 01 WS-TICKS               BINARY-LONG VALUE 40.
 01 WS-SOLID               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-BID                 BINARY-LONG.
 01 WS-BROW                PIC X(819).
 01 WS-EDIT                PIC -(9)9.
 01 WS-PATH                PIC X(128).
 01 WS-ROOT                BINARY-LONG.
 01 WS-PATH-FILE           PIC X(256).
 01 WS-TEXT                PIC X(8192).
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS

*>   Part 1: the type the declared generator gives (no generated packs needed)
     MOVE "flat" TO WS-VARIANT
     PERFORM DECIDE
     MOVE "acceptance skyblock given minecraft:flat with no layers when the type is decided then it is superflat, no fallback" TO TL-CASE
     MOVE "0 superflat 0" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "modgen" TO WS-VARIANT
     PERFORM DECIDE
     MOVE "acceptance skyblock given a generator type of a mod when the type is decided then void chunks: superflat with the fallback" TO TL-CASE
     MOVE "0 superflat 1" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "modnoise" TO WS-VARIANT
     PERFORM DECIDE
     MOVE "acceptance skyblock given noise with settings of another namespace when decided then void chunks: superflat with the fallback"
         TO TL-CASE
     MOVE "0 superflat 1" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "noisecomp" TO WS-VARIANT
     PERFORM DECIDE
     MOVE "acceptance skyblock given noise with its settings written out as a compound when decided then void chunks: superflat with the fallback"
         TO TL-CASE
     MOVE "0 superflat 1" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "noise" TO WS-VARIANT
     PERFORM DECIDE
     MOVE "acceptance skyblock given the ordinary noise overworld when the type is decided then it is standard, no fallback" TO TL-CASE
     MOVE "0 standard 0" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "debug" TO WS-VARIANT
     PERFORM DECIDE
     MOVE "acceptance skyblock given minecraft:debug when the type is decided then it is the debug world, no fallback" TO TL-CASE
     MOVE "0 debug 0" TO TL-EXPECTED
     PERFORM CHECK
*>   a world_gen_settings.dat that cannot be read, one without the overworld generator type and one without dimensions: the standard world as before
     MOVE "flat" TO WS-VARIANT
     PERFORM DECIDE
     MOVE "echo 'not gzip' > build/skyblock-folder/data/minecraft/world_gen_settings.dat" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     PERFORM DECIDE-AGAIN
     MOVE "acceptance skyblock given an unreadable world_gen_settings.dat when the type is decided then it is standard" TO TL-CASE
     MOVE "0 standard 0" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "rm build/skyblock-folder/data/minecraft/world_gen_settings.dat" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     PERFORM DECIDE-AGAIN
     MOVE "acceptance skyblock given no world_gen_settings.dat when the type is decided then it is standard" TO TL-CASE
     MOVE "0 standard 0" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "bare" TO WS-VARIANT
     PERFORM DECIDE
     MOVE "acceptance skyblock given a file with no dimensions when the type is decided then it is standard" TO TL-CASE
     MOVE "0 standard 0" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "notype" TO WS-VARIANT
     PERFORM DECIDE
     MOVE "acceptance skyblock given an overworld generator with no type when decided then it is standard" TO TL-CASE
     MOVE "0 standard 0" TO TL-EXPECTED
     PERFORM CHECK

*>   Part 2: a joined world of each declared kind
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
         MOVE "acceptance skyblock no generated packs here, part 2 skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE "flat" TO WS-VARIANT
     PERFORM ISLAND-WORLD
     MOVE "modgen" TO WS-VARIANT
     PERFORM ISLAND-WORLD
     MOVE "modnoise" TO WS-VARIANT
     PERFORM ISLAND-WORLD
     STOP RUN.

*> The fixture folder of WS-VARIANT in build/skyblock-folder and its type decided as CORE-WORLD-OPEN does.
 DECIDE.
     MOVE SPACES TO WS-COMMAND
     STRING "rm -rf build/skyblock-folder && mkdir -p build/skyblock-folder/dimensions/minecraft/overworld/region"
         " && cp -R core/tests/fixtures/skyblock-" FUNCTION TRIM(WS-VARIANT) "/. build/skyblock-folder/" DELIMITED BY SIZE
         INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     PERFORM DECIDE-AGAIN.

 DECIDE-AGAIN.
     MOVE "build/skyblock-folder" TO CW-FOLDER
     MOVE 21 TO CW-FOLDER-LENGTH
     MOVE 9 TO FS-FALLBACK
     CALL "WORLD-TYPE-DECIDE" USING WS-REQUEST WS-TYPE WS-STATUS
     MOVE WS-STATUS TO WS-EDIT
     MOVE SPACES TO WS-OBSERVED
     MOVE FS-FALLBACK TO WS-FALLBACK
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-TYPE) " " WS-FALLBACK DELIMITED BY SIZE INTO WS-OBSERVED.

*> The world of WS-VARIANT opened as the client opens a saved world (request cobolcraft), joined, an island block set, saved and opened again.
 ISLAND-WORLD.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-COMMAND
     STRING "rm -rf build/skyblock-folder && mkdir -p build/skyblock-folder/dimensions/minecraft/overworld/region"
         " && cp -R core/tests/fixtures/skyblock-" FUNCTION TRIM(WS-VARIANT) "/. build/skyblock-folder/" DELIMITED BY SIZE
         INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     PERFORM OPEN-FOLDER
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE SPACES TO WS-KEY
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BID WS-BROW WS-STATUS
     MOVE CB-DEFAULT-STATE(WS-BID + 1) TO WS-STATE
     MOVE CW-DIM(1) TO WS-DIM
     MOVE 8 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 8 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM SCAN-VOID
     MOVE SPACES TO WS-OBSERVED
     MOVE WS-SOLID TO WS-EDIT
     MOVE 0 TO WS-FALLBACK
     IF WS-ISLAND NOT = 0
         MOVE 1 TO WS-FALLBACK
     END-IF
     STRING FUNCTION TRIM(WS-VARIANT) " " FUNCTION TRIM(WS-EDIT) " " WS-FALLBACK DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE SPACES TO TL-CASE
     STRING "acceptance skyblock a joined " FUNCTION TRIM(WS-VARIANT) " world: no solid block in the nine chunks around the island but the island block"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING FUNCTION TRIM(WS-VARIANT) " 0 1" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK
     CALL "CORE-SAVE"

*>   the file still declares the generator it came with, and the nether and end stems
     MOVE "build/skyblock-folder/data/minecraft/world_gen_settings.dat" TO WS-PATH-FILE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-NBT-FILE" USING WS-PATH-FILE PB-BUFFER WS-ROOT
     MOVE "data.dimensions.minecraft:overworld.generator.type" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT
     MOVE SPACES TO WS-OBSERVED
     MOVE FUNCTION TRIM(WS-TEXT) TO WS-OBSERVED
     MOVE "data.dimensions.minecraft:the_nether.type" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT
     STRING FUNCTION TRIM(WS-OBSERVED) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "data.dimensions.minecraft:the_end.type" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT
     STRING FUNCTION TRIM(WS-OBSERVED) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO WS-OBSERVED
     CALL "PB-FREE" USING PB-BUFFER
     MOVE SPACES TO TL-CASE
     STRING "acceptance skyblock a saved " FUNCTION TRIM(WS-VARIANT) " world keeps its overworld generator, nether and end stems"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     EVALUATE WS-VARIANT
         WHEN "flat"
             MOVE "minecraft:flat minecraft:the_nether minecraft:the_end" TO TL-EXPECTED
         WHEN "modgen"
             MOVE "skyblock:void_island minecraft:the_nether minecraft:the_end" TO TL-EXPECTED
         WHEN OTHER
             MOVE "minecraft:noise minecraft:the_nether minecraft:the_end" TO TL-EXPECTED
     END-EVALUATE
     PERFORM CHECK

*>   opened again: the island block is there, the chunks around it are still void
     PERFORM OPEN-FOLDER
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM SCAN-VOID
     MOVE SPACES TO WS-OBSERVED
     MOVE WS-SOLID TO WS-EDIT
     MOVE 0 TO WS-FALLBACK
     IF WS-ISLAND NOT = 0
         MOVE 1 TO WS-FALLBACK
     END-IF
     STRING FUNCTION TRIM(WS-VARIANT) " " FUNCTION TRIM(WS-EDIT) " " WS-FALLBACK DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE SPACES TO TL-CASE
     STRING "acceptance skyblock a " FUNCTION TRIM(WS-VARIANT) " world opened again: the island block is saved and the rest is still void"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING FUNCTION TRIM(WS-VARIANT) " 0 1" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK
     CALL "CORE-SAVE".

 OPEN-FOLDER.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "cobolcraft" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 1 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-CREATED.

*> WS-SOLID: the blocks other than air in the columns x, z = 3 of the nine chunks around chunk (0, 0) (every fourth height of the overworld); WS-ISLAND the
*> block at the island position 8, 64, 8.
 SCAN-VOID.
     MOVE 0 TO WS-SOLID
     PERFORM VARYING WS-CX FROM -1 BY 1 UNTIL WS-CX > 1
         PERFORM VARYING WS-CZ FROM -1 BY 1 UNTIL WS-CZ > 1
             COMPUTE WS-X = WS-CX * 16 + 3
             COMPUTE WS-Z = WS-CZ * 16 + 3
             PERFORM VARYING WS-Y FROM -64 BY 4 UNTIL WS-Y > 316
                 CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
                 IF WS-STATE NOT = 0
                     ADD 1 TO WS-SOLID
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 8 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 8 TO WS-Z
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-ISLAND.

 CHECK.
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-SKYBLOCK-VOID.

 COPY CORETEST.
