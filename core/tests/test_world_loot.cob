*> Implementation test (T0436/T0437 hook; docs/protocol/26 section 1, docs/design/world-types.md): WORLD-LOOT-OPEN loads the loot data of a world's
*> content set. A standard or debug set reads <generated directory>/vanilla-data/data (the folder that holds the tables) so block drops use
*> the tables; a cobolcraft set has no loot tables in its built-in layer (every built-in block is noLootTable) and keeps none loaded, so
*> BLOCK-DROPS falls back to the stand-in yield. Opening again frees what an earlier open loaded (no duplicates, no tables left over from
*> a standard world in a cobolcraft one). A directory without data loads nothing and is not an error; a broken table fails the load, leaves
*> nothing loaded (the stand-in yield) and the status says CT-BAD-DATA.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WORLD-LOOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 01 WS-DIR                 PIC X(1024) VALUE "build/world-loot-gen".
 01 WS-TYPE                PIC X(10).
 01 WS-STATUS              BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-REGISTRY            PIC X(48) VALUE "loot_table".
 01 WS-KEY                 PIC X(112).
 01 WS-COMMAND             PIC X(300).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "rm -rf build/world-loot-gen && mkdir -p build/world-loot-gen && cp -R core/tests/fixtures/loot-blocks build/world-loot-gen/vanilla-data"
         TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "minecraft:blocks/pseudo_stone" TO WS-KEY

     MOVE "standard" TO WS-TYPE
     CALL "WORLD-LOOT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "test world loot a standard set loads the tables of vanilla-data" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "LOOT-DOC-GET" USING WS-REGISTRY WS-KEY WS-SLOT
     MOVE "test world loot a standard set has the table of a block" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SLOT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "WORLD-LOOT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "test world loot a second open of the same directory frees the first and loads again" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "debug" TO WS-TYPE
     CALL "WORLD-LOOT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     CALL "LOOT-DOC-GET" USING WS-REGISTRY WS-KEY WS-SLOT
     MOVE "test world loot a debug set loads the tables like the standard set" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-STATUS = CT-OK AND WS-SLOT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "cobolcraft" TO WS-TYPE
     CALL "WORLD-LOOT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     CALL "LOOT-DOC-GET" USING WS-REGISTRY WS-KEY WS-SLOT
     MOVE "test world loot a cobolcraft set keeps no table (stand-in yield) and the directory is ignored" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SLOT TO TL-OBSERVED-N
     IF WS-STATUS NOT = CT-OK
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "rm -rf build/world-loot-gen && mkdir -p build/world-loot-gen" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "standard" TO WS-TYPE
     CALL "WORLD-LOOT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     CALL "LOOT-DOC-GET" USING WS-REGISTRY WS-KEY WS-SLOT
     MOVE "test world loot a directory without vanilla-data loads nothing and is not an error" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SLOT TO TL-OBSERVED-N
     IF WS-STATUS NOT = CT-OK
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "mkdir -p build/world-loot-gen/vanilla-data/data/minecraft/loot_table/blocks && echo '{ not json' > build/world-loot-gen/vanilla-data/data/minecraft/loot_table/blocks/broken.json"
         TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "WORLD-LOOT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "test world loot a broken table fails the load with CT-BAD-DATA" TO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:blocks/broken" TO WS-KEY
     CALL "LOOT-DOC-GET" USING WS-REGISTRY WS-KEY WS-SLOT
     MOVE "test world loot a failed load leaves no table" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SLOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the open of a world's content set goes through it: a cobolcraft world opened after a loaded standard set has no table
     MOVE "rm -rf build/world-loot-gen && mkdir -p build/world-loot-gen && cp -R core/tests/fixtures/loot-blocks build/world-loot-gen/vanilla-data"
         TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "standard" TO WS-TYPE
     CALL "WORLD-LOOT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "cobolcraft" TO WS-TYPE
     CALL "WORLD-CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "minecraft:blocks/pseudo_stone" TO WS-KEY
     CALL "LOOT-DOC-GET" USING WS-REGISTRY WS-KEY WS-SLOT
     MOVE "test world loot opening the content set of a cobolcraft world drops the tables of the earlier set" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SLOT TO TL-OBSERVED-N
     IF WS-STATUS NOT = CORE-WO-OK
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-WORLD-LOOT.
 COPY CORETEST.
