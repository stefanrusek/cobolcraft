*> Acceptance test (vanfmt lane; docs/protocol/07 section 10): a world folder in the 26.3 layout (core/tests/fixtures/
*> gen_vanfmt.py) is read and saved back without losing data. Given the folder, when the level is read, then the time of
*> day comes from the overworld clock of world_clocks.dat, the weather from weather.dat, the rules from game_rules.dat
*> (keys with minecraft:) and the layout stays vanilla. When the world is saved after 100 ticks, then level.dat keeps its
*> compound Data with the keys the core does not model (ServerBrands, UnknownBlock, version 19133, difficulty_settings,
*> singleplayer_uuid), Time moved by the 100 ticks, level.dat_old holds the file before, the clock file keeps the other
*> clock and counts the 100 ticks, the rules file keeps the unknown rule, and a second read gives the same state.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-VANFMT-SAVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY BRRULES.
 COPY PROTO.
 01 WS-COMMAND             PIC X(200).
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-REQUEST             PIC X(10) VALUE SPACES.
 01 WS-NAME                PIC X(40).
 01 WS-INDEX               BINARY-LONG.
 01 WS-ROOT                BINARY-LONG.
 01 WS-FILE                PIC X(256).
 01 WS-PATH                PIC X(128).
 01 WS-OBSERVED            PIC X(8192).
 01 WS-OBSERVED-ONE        PIC X(8192).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-E6                  PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "rm -rf build/vanfmt-folder && mkdir -p build/vanfmt-folder/dimensions/minecraft/overworld/region" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "cp -R core/tests/fixtures/vanfmt/. build/vanfmt-folder/" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "build/vanfmt-folder" TO CW-FOLDER
     MOVE 19 TO CW-FOLDER-LENGTH
     CALL "LEVEL-DAT-READ"
     PERFORM SHOW-STATE
     MOVE "acceptance vanfmt given a 26.3 folder when read then clock, weather and rules come from the saved-data files" TO TL-CASE
     MOVE "Vanfmt Fixture|2000|11 22 33 1 0|0 7" TO TL-EXPECTED
     PERFORM CHECK

*>   100 ticks pass, then the world is saved.
     ADD 100 TO CW-TICKS
     ADD 100 TO CW-TIME
     CALL "LEVEL-DAT-WRITE"
     MOVE "build/vanfmt-folder/level.dat" TO WS-FILE
     CALL "TEST-NBT-FILE" USING WS-FILE PB-BUFFER WS-ROOT
     MOVE SPACES TO WS-OBSERVED
     MOVE "Data.Time" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.version" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.ServerBrands" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.UnknownBlock" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.singleplayer_uuid" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.difficulty_settings.difficulty" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.GameType" TO WS-PATH PERFORM ADD-GET
     MOVE "WorldType" TO WS-PATH PERFORM ADD-GET
     MOVE "acceptance vanfmt when saved then level.dat keeps Data with its unmodelled keys, Time + 100, and no flat keys" TO TL-CASE
     MOVE "76620 19133 [vanilla] {keep:77} I[1,2,3,4] hard 1 absent" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "build/vanfmt-folder/level.dat_old" TO WS-FILE
     CALL "TEST-NBT-FILE" USING WS-FILE PB-BUFFER WS-ROOT
     MOVE SPACES TO WS-OBSERVED
     MOVE "Data.Time" TO WS-PATH PERFORM ADD-GET
     MOVE "acceptance vanfmt when saved then level.dat_old is the file before the save" TO TL-CASE
     MOVE "76520" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "build/vanfmt-folder/data/minecraft/world_clocks.dat" TO WS-FILE
     CALL "TEST-NBT-FILE" USING WS-FILE PB-BUFFER WS-ROOT
     MOVE SPACES TO WS-OBSERVED
     MOVE "data.minecraft:overworld.total_ticks" TO WS-PATH PERFORM ADD-GET
     MOVE "data.minecraft:the_end.total_ticks" TO WS-PATH PERFORM ADD-GET
     MOVE "DataVersion" TO WS-PATH PERFORM ADD-GET
     MOVE "acceptance vanfmt when saved then the overworld clock counts 100 ticks and the end clock is kept" TO TL-CASE
     MOVE "50100 999 5023" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "build/vanfmt-folder/data/minecraft/game_rules.dat" TO WS-FILE
     CALL "TEST-NBT-FILE" USING WS-FILE PB-BUFFER WS-ROOT
     MOVE SPACES TO WS-OBSERVED
     MOVE "data.minecraft:advance_time" TO WS-PATH PERFORM ADD-GET
     MOVE "data.minecraft:random_tick_speed" TO WS-PATH PERFORM ADD-GET
     MOVE "data.minecraft:future_rule" TO WS-PATH PERFORM ADD-GET
     MOVE "acceptance vanfmt when saved then the rules file holds the changed rules with minecraft: keys and the unknown rule" TO TL-CASE
     MOVE "0 7 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "build/vanfmt-folder/data/minecraft/weather.dat" TO WS-FILE
     CALL "TEST-NBT-FILE" USING WS-FILE PB-BUFFER WS-ROOT
     MOVE SPACES TO WS-OBSERVED
     MOVE "data" TO WS-PATH PERFORM ADD-GET
     MOVE "acceptance vanfmt when saved then weather.dat holds the five fields" TO TL-CASE
     MOVE "{clear_weather_time:11,rain_time:22,thunder_time:33,raining:1,thundering:0}" TO TL-EXPECTED
     PERFORM CHECK

*>   Files that are missing are created by the save (a 26.3 level.dat with no saved-data files yet).
     MOVE "rm -rf build/vanfmt-folder/data" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "LEVEL-DAT-WRITE"
     MOVE "build/vanfmt-folder/data/minecraft/world_clocks.dat" TO WS-FILE
     CALL "TEST-NBT-FILE" USING WS-FILE PB-BUFFER WS-ROOT
     MOVE SPACES TO WS-OBSERVED
     MOVE "data.minecraft:overworld.total_ticks" TO WS-PATH PERFORM ADD-GET
     MOVE "data.minecraft:the_end" TO WS-PATH PERFORM ADD-GET
     MOVE "acceptance vanfmt given no saved-data files when saved then they are created (clock kept, no other clock)" TO TL-CASE
     MOVE "50100 absent" TO TL-EXPECTED
     PERFORM CHECK

*>   A second read gives the same state.
     MOVE 0 TO CW-TIME
     CALL "LEVEL-DAT-READ"
     PERFORM SHOW-STATE
     MOVE "acceptance vanfmt given the saved folder when read again then the clock has moved 100 ticks and the rest is the same" TO TL-CASE
     MOVE "Vanfmt Fixture|2100|11 22 33 1 0|0 7" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 SHOW-STATE.
     MOVE SPACES TO WS-OBSERVED
     MOVE CW-TIME TO WS-E1
     MOVE CW-CLEAR-TIME TO WS-E2
     MOVE CW-RAIN-TIME TO WS-E3
     MOVE CW-THUNDER-TIME TO WS-E4
     MOVE CW-RAINING TO WS-E5
     MOVE CW-THUNDERING TO WS-E6
     STRING FUNCTION TRIM(CW-NAME) "|" FUNCTION TRIM(WS-E1) "|" FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3)
         " " FUNCTION TRIM(WS-E4) " " FUNCTION TRIM(WS-E5) " " FUNCTION TRIM(WS-E6) "|"
         DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "advance_time" TO WS-NAME
     CALL "BR-RULE-FIND" USING WS-NAME WS-INDEX
     MOVE GR-VALUE(WS-INDEX) TO WS-E1
     MOVE "random_tick_speed" TO WS-NAME
     CALL "BR-RULE-FIND" USING WS-NAME WS-INDEX
     MOVE GR-VALUE(WS-INDEX) TO WS-E2
     STRING FUNCTION TRIM(WS-OBSERVED) FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO WS-OBSERVED.

 ADD-GET.
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-OBSERVED-ONE
     STRING FUNCTION TRIM(WS-OBSERVED) " " FUNCTION TRIM(WS-OBSERVED-ONE) DELIMITED BY SIZE
         INTO WS-OBSERVED.

 CHECK.
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-VANFMT-SAVE.

 COPY CORETEST.
