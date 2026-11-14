*> Acceptance test (vanwrite lane; docs/protocol/07 section 10.8): a folder an old build left behind, a flat level.dat with
*> WorldType standard and the real file as level.dat_old (core/tests/fixtures/gen_vanwrite.py), is read as a standard world
*> that is saved in the 26.3 layout: level.dat becomes Data with the keys of the real file (unmodelled ones kept), no
*> WorldType key, level.dat_old stays the real file, and world_gen_settings.dat has the dimensions map.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-VANWRITE-MIGRATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-COMMAND             PIC X(200).
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-ROOT                BINARY-LONG.
 01 WS-FILE                PIC X(256).
 01 WS-PATH                PIC X(128).
 01 WS-OBSERVED            PIC X(8192).
 01 WS-ONE                 PIC X(8192).
 01 WS-E1                  PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "rm -rf build/vanwrite-folder && python3 -I core/tests/fixtures/gen_vanwrite.py build/vanwrite-folder" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "build/vanwrite-folder" TO CW-FOLDER
     MOVE 21 TO CW-FOLDER-LENGTH
     CALL "LEVEL-DAT-READ"
     MOVE CW-LAYOUT TO WS-E1
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-E1) "|" FUNCTION TRIM(CW-NAME) "|" FUNCTION TRIM(CW-WORLD-TYPE) DELIMITED BY SIZE
         INTO WS-OBSERVED
     MOVE "acceptance vanwrite given a flat standard level.dat when read then the world is standard and will be saved in the 26.3 layout"
         TO TL-CASE
     MOVE "1|Flat Standard|standard" TO TL-EXPECTED
     PERFORM CHECK

     CALL "LEVEL-DAT-WRITE"
     MOVE "build/vanwrite-folder/level.dat" TO WS-FILE
     CALL "TEST-NBT-FILE" USING WS-FILE PB-BUFFER WS-ROOT
     MOVE SPACES TO WS-OBSERVED
     MOVE "Data.LevelName" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.UnknownBlock" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.version" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.DataVersion" TO WS-PATH PERFORM ADD-GET
     MOVE "WorldType" TO WS-PATH PERFORM ADD-GET
     MOVE "Seed" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.Version.Id" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.Version.Name" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.Version.Snapshot" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.version_history" TO WS-PATH PERFORM ADD-GET
     MOVE "Data.DataPacks.Disabled" TO WS-PATH PERFORM ADD-GET
     MOVE "acceptance vanwrite when saved then level.dat is Data with the keys of the real file and no flat keys" TO TL-CASE
     MOVE "Flat Standard {keep:77} 19133 5023 absent absent 5023 26.3 0 [5015,5023] [trade_rebalance]" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "build/vanwrite-folder/level.dat_old" TO WS-FILE
     CALL "TEST-NBT-FILE" USING WS-FILE PB-BUFFER WS-ROOT
     MOVE SPACES TO WS-OBSERVED
     MOVE "Data.Time" TO WS-PATH PERFORM ADD-GET
     MOVE "acceptance vanwrite when saved then level.dat_old is still the real file" TO TL-CASE
     MOVE "10946" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "build/vanwrite-folder/data/minecraft/world_gen_settings.dat" TO WS-FILE
     CALL "TEST-NBT-FILE" USING WS-FILE PB-BUFFER WS-ROOT
     MOVE SPACES TO WS-OBSERVED
     MOVE "data.seed" TO WS-PATH PERFORM ADD-GET
     MOVE "data.dimensions.minecraft:overworld.type" TO WS-PATH PERFORM ADD-GET
     MOVE "acceptance vanwrite when saved then world_gen_settings.dat has the seed and the dimensions map" TO TL-CASE
     MOVE "424242 minecraft:overworld" TO TL-EXPECTED
     PERFORM CHECK

*>   The read-back checker (tools/validate_world.py) applies the loader's requirements to what was written.
     MOVE "python3 -I tools/validate_world.py build/vanwrite-folder > build/vanwrite.validate 2>&1" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE RETURN-CODE TO WS-E1
     MOVE SPACES TO WS-OBSERVED
     MOVE FUNCTION TRIM(WS-E1) TO WS-OBSERVED
     MOVE "acceptance vanwrite the saved folder passes the read-back checker (tools/validate_world.py: Data, dimensions, regions)" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 ADD-GET.
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-ONE
     STRING FUNCTION TRIM(WS-OBSERVED) " " FUNCTION TRIM(WS-ONE) DELIMITED BY SIZE INTO WS-OBSERVED.

 CHECK.
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-VANWRITE-MIGRATE.

 COPY CORETEST.
