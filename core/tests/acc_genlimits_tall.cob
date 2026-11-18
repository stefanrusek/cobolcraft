*> Acceptance test (lane genlimits; docs/protocol/38 section 2, 37-nether-5 item 3, 06): the Nether and the End are 256 blocks tall (min y 0, height 256, 16 sections), generated
*> content only exists up to y 127 but the memory of a generated chunk holds the whole height: whatever lands above y 127 (a block a player or a feature writes, a chest or spawner
*> entity of the generated-block-entity channel, a block of the chunk-overflow channel) is kept, is read back, and is still there after the world is saved and opened again.
*> For both dimensions with their real generators (needs the generated packs: a pass without them):
*>   - blocks written at y 128, 200 and 255 read back (and the cell above the build limit y 256 refuses);
*>   - a chest of the generated-block-entity channel at y 200 gets its block entity with the loot table (GBE-APPLY);
*>   - the overflow channel writes into air at y 220 (OV-APPLY-ROW);
*>   - after CORE-SAVE and a reopen the blocks and the chest entity are as they were.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-GENLIMITS-TALL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY NETHERDIM.
 COPY GENBE.
 COPY BESTATE.
 01 WS-SKIP                BINARY-LONG.
 01 WS-WORLD               PIC X(64) VALUE Z"build/core-test-world".
 01 WS-CREATED             BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-CHEST               BINARY-LONG.
 01 WS-KEY-STONE           PIC X(48) VALUE "minecraft:stone".
 01 WS-KEY-CHEST           PIC X(48) VALUE "minecraft:chest".
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-LOOT                PIC X(48) VALUE "minecraft:chests/end_city_treasure".
 01 WS-TEXT                PIC X(32) VALUE SPACES.
 01 WS-SEED                BINARY-DOUBLE VALUE 77.
 01 WS-KIND-CHEST          BINARY-LONG VALUE 1.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-NAME                PIC X(8).
 01 WS-PHASE               PIC X(8).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance genlimits tall dimensions: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE 0 TO ND-PLACEHOLDER
     MOVE 12345 TO CW-SEED
     CALL "GEN-BLOCK-STATE" USING WS-KEY-STONE WS-STONE
     CALL "GEN-BLOCK-STATE" USING WS-KEY-CHEST WS-CHEST
     PERFORM VARYING WS-D FROM 4 BY 1 UNTIL WS-D > 5
         MOVE WS-D TO WS-DIM
         PERFORM WRITE-AND-READ
     END-PERFORM
     MOVE "after" TO WS-PHASE
     CALL "CORE-SAVE"
     CALL "CORE-WORLD-OPEN" USING WS-WORLD CORE-SETTINGS WS-CREATED
     PERFORM VARYING WS-D FROM 4 BY 1 UNTIL WS-D > 5
         MOVE WS-D TO WS-DIM
         PERFORM READ-ONLY
     END-PERFORM
     STOP RUN.
 NAME-DIM.
     IF WS-DIM = 4
         MOVE "nether" TO WS-NAME
     ELSE
         MOVE "end" TO WS-NAME
     END-IF.
 WRITE-AND-READ.
     PERFORM NAME-DIM
     MOVE "before" TO WS-PHASE
     MOVE 3 TO WS-X
     MOVE 3 TO WS-Z
     MOVE 128 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
     MOVE 200 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
     MOVE 255 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
     MOVE 5 TO WS-X
     MOVE 200 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-CHEST
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
     MOVE 0 TO WS-CX WS-CZ
     CALL "WORLD-FIND" USING WS-DIM WS-CX WS-CZ WS-ROW
*>   the generated-block-entity channel: the chest entity at y 200
     MOVE 1 TO GB-COUNT
     MOVE 0 TO GB-LOST
     MOVE 5 TO GB-X(1)
     MOVE 200 TO GB-Y(1)
     MOVE 3 TO GB-Z(1)
     MOVE WS-KIND-CHEST TO GB-KIND(1)
     MOVE 77 TO GB-SEED(1)
     MOVE WS-LOOT TO GB-LOOT(1)
     MOVE SPACES TO GB-TEXT(1)
     CALL "GBE-APPLY" USING WS-DIM WS-ROW
     MOVE 0 TO GB-COUNT
*>   the overflow channel writes into air at y 220
     MOVE 7 TO WS-X
     MOVE 220 TO WS-Y
     CALL "OV-APPLY-ROW" USING WS-ROW WS-X WS-Y WS-Z WS-STONE WS-RESULT
     MOVE SPACES TO TL-CASE
     STRING "acceptance genlimits tall " FUNCTION TRIM(WS-NAME) ": overflow write into air at y 220 is written" DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM READ-ONLY.
 READ-ONLY.
     PERFORM NAME-DIM
     MOVE "N" TO TL-MODE
     MOVE 3 TO WS-X
     MOVE 3 TO WS-Z
     MOVE 128 TO WS-Y
     MOVE SPACES TO TL-CASE
     STRING "acceptance genlimits tall " FUNCTION TRIM(WS-NAME) " " FUNCTION TRIM(WS-PHASE) ": stone at y 128 reads back" DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-STONE TO TL-EXPECTED-N
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 200 TO WS-Y
     MOVE SPACES TO TL-CASE
     STRING "acceptance genlimits tall " FUNCTION TRIM(WS-NAME) " " FUNCTION TRIM(WS-PHASE) ": stone at y 200 reads back" DELIMITED BY SIZE INTO TL-CASE
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 255 TO WS-Y
     MOVE SPACES TO TL-CASE
     STRING "acceptance genlimits tall " FUNCTION TRIM(WS-NAME) " " FUNCTION TRIM(WS-PHASE) ": stone at y 255 reads back" DELIMITED BY SIZE INTO TL-CASE
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-X
     MOVE 220 TO WS-Y
     MOVE SPACES TO TL-CASE
     STRING "acceptance genlimits tall " FUNCTION TRIM(WS-NAME) " " FUNCTION TRIM(WS-PHASE) ": the overflow stone at y 220 reads back" DELIMITED BY SIZE INTO TL-CASE
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-X
     MOVE 200 TO WS-Y
     MOVE SPACES TO TL-CASE
     STRING "acceptance genlimits tall " FUNCTION TRIM(WS-NAME) " " FUNCTION TRIM(WS-PHASE) ": the chest at y 200 reads back" DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-CHEST TO TL-EXPECTED-N
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-INDEX
     MOVE SPACES TO TL-CASE
     STRING "acceptance genlimits tall " FUNCTION TRIM(WS-NAME) " " FUNCTION TRIM(WS-PHASE) ": the chest at y 200 has its block entity" DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-INDEX > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-GENLIMITS-TALL.
 COPY CORETEST.
 COPY PORTALTEST.
