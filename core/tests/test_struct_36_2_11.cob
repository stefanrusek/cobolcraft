*> Acceptance test of the block entity data of a structure template (docs/protocol/36-structures-2 sections 1.5, 5.3 step 7 and 6.2 step 5): the loader keeps the
*> kind and the keys of each record's nbt (a container with its loot table, a spawner with its entity, a data marker with its metadata, a jigsaw record with its
*> keys), placement hands the containers and spawners to the worldgen block-entity channel (GENBE.cpy) drawing one loot seed per container from the piece random (SP-XR),
*> and the block state text parser reads "id[name=value,...]{nbt}" (15 section 9.1). Runs over the standard content set of the generated packs (skipped as a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-2-11.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY CELLS.
 COPY STRUCTTPL.
 COPY STRUCTSET.
 COPY STRUCTPLACE.
 COPY STRUCTPIECE.
 COPY FEATLEVEL.
 COPY GENBE.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-XR== LEADING ==XR-== BY ==WX-==.
 01 WS-TPL-DIR             PIC X(1100) VALUE "core/tests/fixtures/tpl".
 01 WS-GEN-DIR             PIC X(1100).
 01 WS-ENV                 PIC X(1100).
 01 WS-FILE                PIC X(1200).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
 01 WS-ID                  PIC X(96).
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-TEXT                PIC X(160).
 01 WS-STATE               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-LABEL               PIC X(150).
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-OX                  BINARY-LONG VALUE 4.
 01 WS-OY                  BINARY-LONG VALUE 70.
 01 WS-OZ                  BINARY-LONG VALUE 4.
 01 WS-AX                  BINARY-LONG VALUE 4.
 01 WS-AY                  BINARY-LONG VALUE 70.
 01 WS-AZ                  BINARY-LONG VALUE 4.
 01 WS-ED                  PIC -(8)9.
 01 WS-ED2                 PIC -(18)9.
 01 WS-ED3                 PIC -(8)9.
 01 WS-ED4                 PIC -(8)9.
 01 WS-S1                  BINARY-DOUBLE.
 01 WS-S2                  BINARY-DOUBLE.
 01 WS-S3                  BINARY-DOUBLE.
 01 WS-ED2-DRAW            BINARY-DOUBLE.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 424242.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN-DIR
     ELSE
         MOVE WS-ENV TO WS-GEN-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-GEN-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "acceptance US12 36-2§1 Template block entity data: no generated packs here, skipped" TO TL-CASE
         MOVE "ok" TO TL-EXPECTED
         MOVE "ok" TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-GEN-DIR WS-STATUS
     CALL "BLOCKS-OPEN"
     CALL "STRUCT-TPL-RESET"
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN-Y WS-HEIGHT WS-SEA
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE "T" TO TL-MODE

*>   The loader keeps the kind and the keys of each nbt (1.4, 1.5).
     MOVE "test:bes" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-TPL-DIR WS-ID WS-ROW
     MOVE "bes: loaded, 6 blocks, every one with a tag" TO WS-LABEL
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         IF TB-NBT(TP-BASE(WS-ROW, 1) + WS-I) > 0
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE TP-STATUS(WS-ROW) TO WS-ED
     MOVE WS-N TO WS-ED3
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 6" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "bes: kinds are container, container without a table, spawner, data marker, other structure block mode, a sign (dropped)" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-P
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE TB-NBT(TP-BASE(WS-ROW, 1) + WS-I) TO WS-N
         MOVE TN-KIND(WS-N) TO WS-ED
         IF WS-I > 1
             STRING " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-P
         END-IF
         STRING FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-P
     END-PERFORM
     MOVE "1 1 2 3 5 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE TB-NBT(TP-BASE(WS-ROW, 1) + 1) TO WS-N
     MOVE "bes: the container's loot table" TO WS-LABEL
     MOVE TN-LOOT(WS-N) TO TL-OBSERVED
     MOVE "minecraft:chests/simple_dungeon" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE TB-NBT(TP-BASE(WS-ROW, 1) + 2) TO WS-N
     MOVE "bes: a container without a table has none" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     STRING "[" TN-LOOT(WS-N) "]" DELIMITED BY SPACES INTO TL-OBSERVED
     MOVE "[]" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE TB-NBT(TP-BASE(WS-ROW, 1) + 3) TO WS-N
     MOVE "bes: the spawner's entity id (SpawnData.entity.id)" TO WS-LABEL
     MOVE TN-TEXT(WS-N) TO TL-OBSERVED
     MOVE "minecraft:cave_spider" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE TB-NBT(TP-BASE(WS-ROW, 1) + 4) TO WS-N
     MOVE "bes: the data marker's metadata" TO WS-LABEL
     MOVE TN-TEXT(WS-N) TO TL-OBSERVED
     MOVE "ChestEast" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

     MOVE "test:jig" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-TPL-DIR WS-ID WS-ROW
     MOVE TB-NBT(TP-BASE(WS-ROW, 1) + 1) TO WS-N
     MOVE "jig: a jigsaw record's name, pool, target, joint and priorities (1.5)" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     MOVE TN-KIND(WS-N) TO WS-ED
     MOVE TN-JOINT(WS-N) TO WS-ED2
     MOVE TN-PRIO-PLACE(WS-N) TO WS-ED3
     MOVE TN-PRIO-SELECT(WS-N) TO WS-ED4
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(TN-NAME(WS-N)) " " FUNCTION TRIM(TN-POOL(WS-N)) " "
         FUNCTION TRIM(TN-TARGET(WS-N)) " " FUNCTION TRIM(WS-ED2) " " FUNCTION TRIM(WS-ED3) " " FUNCTION TRIM(WS-ED4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "4 minecraft:bottom minecraft:foo/bar minecraft:top 2 3 4" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "jig: the final_state text" TO WS-LABEL
     MOVE TN-TEXT(WS-N) TO TL-OBSERVED
     MOVE "minecraft:stone" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE TB-NBT(TP-BASE(WS-ROW, 1) + 2) TO WS-N
     MOVE "jig: a bare jigsaw tag has the empty defaults and the default joint" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     MOVE TN-JOINT(WS-N) TO WS-ED
     MOVE TN-PRIO-PLACE(WS-N) TO WS-ED2
     STRING FUNCTION TRIM(TN-NAME(WS-N)) " " FUNCTION TRIM(TN-POOL(WS-N)) " " FUNCTION TRIM(TN-TARGET(WS-N)) " "
         FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) " " FUNCTION TRIM(TN-TEXT(WS-N)) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "minecraft:empty minecraft:empty minecraft:empty 0 0 minecraft:air" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

     MOVE TB-NBT(TP-BASE(WS-ROW, 1) + 3) TO WS-N
     MOVE "jig: the aligned joint" TO WS-LABEL
     MOVE TN-JOINT(WS-N) TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   The tag table: a first use without a reset starts at row 1, a full table makes the template unsupported.
     MOVE 0 TO TN-USED
     CALL "STRUCT-TPL-RESET"
     MOVE 0 TO TN-USED
     MOVE "test:bes" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-TPL-DIR WS-ID WS-ROW
     MOVE "the first tag of a table nobody reset is row 2" TO WS-LABEL
     MOVE TB-NBT(TP-BASE(WS-ROW, 1) + 1) TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "2" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     CALL "STRUCT-TPL-RESET"
     MOVE TN-MAX TO TN-USED
     MOVE "test:bes" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-TPL-DIR WS-ID WS-ROW
     MOVE "a full tag table makes the template unsupported (3)" TO WS-LABEL
     MOVE TP-STATUS(WS-ROW) TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "3" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     CALL "STRUCT-TPL-RESET"

*>   Placement: requests to the channel, one seed per container (5.3 step 7).
     MOVE "test:bes" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING WS-TPL-DIR WS-ID WS-ROW
     INITIALIZE STRUCT-SETTINGS
     MOVE 0 TO GBL-COUNT GBL-LOST
     CALL "WGR-SET-SEED" USING WS-XR WS-SEED
     MOVE WX-LO TO SP-XR-LO
     MOVE WX-HI TO SP-XR-HI
     CALL "MSP-RNG-LONG" USING WS-S1
     CALL "MSP-RNG-LONG" USING WS-S2
     CALL "MSP-RNG-LONG" USING WS-S3
     CALL "WGR-SET-SEED" USING WS-XR WS-SEED
     MOVE WX-LO TO SP-XR-LO
     MOVE WX-HI TO SP-XR-HI
     PERFORM PLACE
     MOVE "placement: a chest with a table and a spawner are requested, in placement order" TO WS-LABEL
     MOVE GBL-COUNT TO WS-ED
     MOVE GBL-KIND(1) TO WS-ED2
     MOVE GBL-X(1) TO WS-ED3
     MOVE GBL-KIND(2) TO WS-ED4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) " " FUNCTION TRIM(WS-ED3) " " FUNCTION TRIM(WS-ED4) " "
         FUNCTION TRIM(GBL-TEXT(2)) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "2 1 4 2 minecraft:cave_spider" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "placement: the chest's loot table key and the seed of the first draw" TO WS-LABEL
     MOVE GBL-SEED(1) TO WS-ED2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(GBL-LOOT(1)) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-S1 TO WS-ED2
     MOVE SPACES TO TL-EXPECTED
     STRING "minecraft:chests/simple_dungeon " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "placement: the second container (no table) drew a seed too, so the random is two draws further" TO WS-LABEL
     CALL "MSP-RNG-LONG" USING WS-ED2-DRAW
     MOVE WS-ED2-DRAW TO WS-ED2
     MOVE FUNCTION TRIM(WS-ED2) TO TL-OBSERVED
     MOVE WS-S3 TO WS-ED2
     MOVE FUNCTION TRIM(WS-ED2) TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   A record outside the settings' box is not written and draws nothing.
     MOVE 0 TO GBL-COUNT
     CALL "WGR-SET-SEED" USING WS-XR WS-SEED
     MOVE WX-LO TO SP-XR-LO
     MOVE WX-HI TO SP-XR-HI
     MOVE 1 TO PS-BOX-SET
     MOVE 4 TO PS-BOX(1)
     MOVE 60 TO PS-BOX(2)
     MOVE 4 TO PS-BOX(3)
     MOVE 4 TO PS-BOX(4)
     MOVE 80 TO PS-BOX(5)
     MOVE 8 TO PS-BOX(6)
     PERFORM PLACE
     MOVE "box: only the first column is written, one request" TO WS-LABEL
     MOVE GBL-COUNT TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "box: and one draw (the next is the second)" TO WS-LABEL
     CALL "MSP-RNG-LONG" USING WS-ED2-DRAW
     MOVE WS-ED2-DRAW TO WS-ED2
     MOVE FUNCTION TRIM(WS-ED2) TO TL-OBSERVED
     MOVE WS-S2 TO WS-ED2
     MOVE FUNCTION TRIM(WS-ED2) TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   The block state text parser (15 section 9.1).
     MOVE "minecraft:stone" TO WS-TEXT
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WANT
     PERFORM DO-PARSE
     MOVE "text: a plain id" TO WS-LABEL
     PERFORM ASSERT-PARSE-WANT
     MOVE "stone" TO WS-TEXT
     PERFORM DO-PARSE
     MOVE "text: a plain id without the namespace" TO WS-LABEL
     PERFORM ASSERT-PARSE-WANT
     MOVE "minecraft:stone{a:1}" TO WS-TEXT
     PERFORM DO-PARSE
     MOVE "text: the trailing nbt is accepted" TO WS-LABEL
     PERFORM ASSERT-PARSE-WANT
     MOVE "minecraft:stone{a:{b:1},c:[1]}" TO WS-TEXT
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WANT
     PERFORM DO-PARSE
     MOVE "text: nested nbt" TO WS-LABEL
     PERFORM ASSERT-PARSE-WANT
     MOVE "oak_stairs" TO WS-KEY
     MOVE "facing=south,half=top,shape=straight,waterlogged=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WANT
     MOVE "minecraft:oak_stairs[facing=south,half=top]" TO WS-TEXT
     PERFORM DO-PARSE
     MOVE "text: some properties, the rest default" TO WS-LABEL
     PERFORM ASSERT-PARSE-WANT
     MOVE "oak_stairs[ half = top , facing = south ]" TO WS-TEXT
     PERFORM DO-PARSE
     MOVE "text: whitespace around names, = and commas, any order" TO WS-LABEL
     PERFORM ASSERT-PARSE-WANT
     MOVE "oak_stairs[]" TO WS-TEXT
     PERFORM DO-PARSE
     MOVE "text: an empty property list" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-OK TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         EVALUATE WS-I
             WHEN 1
                 MOVE "minecraft:no_such_block" TO WS-TEXT
                 MOVE "an unknown block" TO WS-LABEL
             WHEN 2
                 MOVE "oak_stairs[nothing=x]" TO WS-TEXT
                 MOVE "an unknown property" TO WS-LABEL
             WHEN 3
                 MOVE "oak_stairs[facing=up]" TO WS-TEXT
                 MOVE "an invalid value" TO WS-LABEL
             WHEN 4
                 MOVE "oak_stairs[facing=south,facing=north]" TO WS-TEXT
                 MOVE "a duplicate property" TO WS-LABEL
             WHEN 5
                 MOVE "oak_stairs[facing]" TO WS-TEXT
                 MOVE "a property with no value" TO WS-LABEL
             WHEN 6
                 MOVE "oak_stairs[facing=south" TO WS-TEXT
                 MOVE "an unclosed list" TO WS-LABEL
             WHEN 7
                 MOVE SPACES TO WS-TEXT
                 MOVE "an empty text" TO WS-LABEL
             WHEN 8
                 MOVE "oak_stairs[facing=south]x" TO WS-TEXT
                 MOVE "text after the properties" TO WS-LABEL
             WHEN 9
                 MOVE "stone{a:1" TO WS-TEXT
                 MOVE "an unbalanced nbt" TO WS-LABEL
             WHEN 10
                 MOVE "stone{a:1}{b:2}" TO WS-TEXT
                 MOVE "nbt followed by more text" TO WS-LABEL
             WHEN OTHER
                 MOVE "[facing=south]" TO WS-TEXT
                 MOVE "properties with no id" TO WS-LABEL
         END-EVALUATE
         PERFORM DO-PARSE
         MOVE SPACES TO TL-OBSERVED
         MOVE WS-OK TO WS-ED
         MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
         MOVE "0" TO TL-EXPECTED
         STRING "text: " FUNCTION TRIM(WS-LABEL) " is a syntax error" DELIMITED BY SIZE INTO WS-LABEL
         PERFORM ASSERT-TEXT
     END-PERFORM
     GOBACK.

 DO-PARSE.
     CALL "STRUCT-BLOCK-TEXT" USING WS-TEXT WS-STATE WS-OK.

 ASSERT-PARSE-WANT.
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-OK TO WS-ED
     MOVE WS-STATE TO WS-ED2
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-WANT TO WS-ED2
     MOVE SPACES TO TL-EXPECTED
     STRING "1 " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM ASSERT-TEXT.

 ASSERT-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 36-2§5 Template block entity data: " FUNCTION TRIM(WS-LABEL) DELIMITED BY SIZE INTO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 PLACE.
     MOVE LOW-VALUES TO CE-STATES
     MOVE 0 TO FL-DISCARDED
     CALL "STRUCT-PLACE" USING WS-ROW WS-OX WS-OY WS-OZ WS-AX WS-AY WS-AZ STRUCT-SETTINGS WS-FLAGS WS-RESULT.
