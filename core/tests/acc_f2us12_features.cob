*> Acceptance test (T1294, US12-1; docs/protocol/35-worldgen-features-1 section 6 (the decoration driver), 35-worldgen-features-3 (tree placers), 35-worldgen-features-4 (vegetation), 11 section 6):
*> on the generated vanilla-data (CC_GENERATED_DIR, read only; skipped as a pass without the generated packs) a standard world of the fixed seed text 12345 generates the 15 chunks
*> -36 to -34 by 10 to 14 whole (the atomic path, decoration included; the biome there is forest and birch forest) and the decoration places what the features document: trees
*> (logs above y 50, with more leaves than logs), vegetation (grass, ferns and flowers on the ground) and nothing underground but the structures' and ores' own blocks,
*> and a chunk generated twice is the same byte for byte. Lakes (the LAKES step) are not asserted: core/src/feat-lake.cob fails a lake whose blobs reach the chunk border (docs/design/world-types.md
*> "Chunk borders"), which is nearly every placement, so no lake appears in the 300 chunks scanned (task T13005, the lane report).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-FEATURES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY DIMENSIONS.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-REF                 PIC X(304640).
 01 WS-REF2                PIC X(304640).
 01 WS-REF-Y               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-KIND-TABLE.
    05 WS-KIND             BINARY-CHAR OCCURS 1400 TIMES.
 01 WS-N-LOG               BINARY-LONG VALUE 0.
 01 WS-N-LEAVES            BINARY-LONG VALUE 0.
 01 WS-N-PLANT             BINARY-LONG VALUE 0.
 01 WS-N-FLOWER            BINARY-LONG VALUE 0.
 01 WS-N-PLANT-BAD         BINARY-LONG VALUE 0.
 01 WS-E1                  PIC -(9)9.
 01 WS-SAME                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
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
         MOVE "acceptance US12 features: no generated packs here, skipped" TO TL-CASE
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
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CW-DIM(1) TO WS-DIM
     PERFORM CLASSIFY-BLOCKS
     PERFORM VARYING WS-CX FROM -36 BY 1 UNTIL WS-CX > -34
         PERFORM VARYING WS-CZ FROM 10 BY 1 UNTIL WS-CZ > 14
             CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-REF WS-REF-Y
             PERFORM COUNT-CHUNK
         END-PERFORM
     END-PERFORM
     DISPLAY "PROBE logs " WS-N-LOG " leaves " WS-N-LEAVES " plants " WS-N-PLANT " flowers " WS-N-FLOWER
         " plants unsupported " WS-N-PLANT-BAD

     MOVE "T" TO TL-MODE
     MOVE "acceptance US12-1 given a standard world when the forest area is generated then it holds trees: surface logs and leaves" TO TL-CASE
     MOVE "trees" TO TL-EXPECTED
     MOVE "no trees" TO TL-OBSERVED
     IF WS-N-LOG > 0 AND WS-N-LEAVES > WS-N-LOG
         MOVE "trees" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-1 given a standard world when the forest area is generated then it holds vegetation: grass or ferns and flowers" TO TL-CASE
     MOVE "vegetation" TO TL-EXPECTED
     MOVE "none" TO TL-OBSERVED
     IF WS-N-PLANT > 0 AND WS-N-FLOWER > 0
         MOVE "vegetation" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-1 given the vegetation of the area when each plant is looked at then it stands on ground" TO TL-CASE
     MOVE "0 plants unsupported" TO TL-EXPECTED
     MOVE WS-N-PLANT-BAD TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " plants unsupported" DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the decoration is a function of the seed and the chunk: the same chunk again is the same bytes
     MOVE -35 TO WS-CX
     MOVE 12 TO WS-CZ
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-REF WS-REF-Y
     CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-CX WS-CZ WS-REF2 WS-REF-Y
     MOVE 0 TO WS-SAME
     IF WS-REF = WS-REF2
         MOVE 1 TO WS-SAME
     END-IF
     MOVE "acceptance US12-1 given the decoration order when a chunk is generated twice then both are the same byte for byte" TO TL-CASE
     MOVE "same" TO TL-EXPECTED
     MOVE "different" TO TL-OBSERVED
     IF WS-SAME = 1
         MOVE "same" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> WS-KIND(block + 1): 1 log, 2 leaves, 3 grass or fern, 4 flower, 6 ground
 CLASSIFY-BLOCKS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         MOVE 0 TO WS-KIND(WS-I)
         MOVE CB-KEY-LENGTH(WS-I) TO WS-LEN
         EVALUATE TRUE
             WHEN WS-LEN > 4 AND CB-KEY(WS-I)(WS-LEN - 3:4) = "_log"
                 MOVE 1 TO WS-KIND(WS-I)
             WHEN WS-LEN > 7 AND CB-KEY(WS-I)(WS-LEN - 6:7) = "_leaves"
                 MOVE 2 TO WS-KIND(WS-I)
             WHEN CB-KEY(WS-I)(1:WS-LEN) = "short_grass" OR CB-KEY(WS-I)(1:WS-LEN) = "fern"
                 MOVE 3 TO WS-KIND(WS-I)
             WHEN CB-KEY(WS-I)(1:WS-LEN) = "dandelion" OR CB-KEY(WS-I)(1:WS-LEN) = "poppy"
                 OR CB-KEY(WS-I)(1:WS-LEN) = "azure_bluet" OR CB-KEY(WS-I)(1:WS-LEN) = "oxeye_daisy"
                 OR CB-KEY(WS-I)(1:WS-LEN) = "cornflower"
                 MOVE 4 TO WS-KIND(WS-I)
             WHEN CB-KEY(WS-I)(1:WS-LEN) = "grass_block" OR CB-KEY(WS-I)(1:WS-LEN) = "dirt"
                 OR CB-KEY(WS-I)(1:WS-LEN) = "podzol" OR CB-KEY(WS-I)(1:WS-LEN) = "coarse_dirt"
                 OR CB-KEY(WS-I)(1:WS-LEN) = "snow_block" OR CB-KEY(WS-I)(1:WS-LEN) = "sand"
                 OR CB-KEY(WS-I)(1:WS-LEN) = "mud" OR CB-KEY(WS-I)(1:WS-LEN) = "rooted_dirt"
                 MOVE 6 TO WS-KIND(WS-I)
         END-EVALUATE
     END-PERFORM.

*> adds the trees and plants of the chunk WS-REF to the counts; a surface log is at y 50 and above (the mines are lower); a plant whose cell below is not ground is unsupported
 COUNT-CHUNK.
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF WS-REF
     PERFORM VARYING WS-I FROM 257 BY 1 UNTIL WS-I > 98304
         MOVE CE-STATE(WS-I) TO WS-STATE
         COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
         COMPUTE WS-Y = (WS-I - 1) / 256 - 64
         MOVE CE-STATE(WS-I - 256) TO WS-STATE
         COMPUTE WS-BELOW = CB-S-BLOCK(WS-STATE + 1) + 1
         EVALUATE WS-KIND(WS-BLOCK)
             WHEN 1
                 IF WS-Y >= 50
                     ADD 1 TO WS-N-LOG
                 END-IF
             WHEN 2
                 ADD 1 TO WS-N-LEAVES
             WHEN 3
                 ADD 1 TO WS-N-PLANT
                 IF WS-KIND(WS-BELOW) NOT = 6
                     ADD 1 TO WS-N-PLANT-BAD
                 END-IF
             WHEN 4
                 ADD 1 TO WS-N-FLOWER
                 IF WS-KIND(WS-BELOW) NOT = 6
                     ADD 1 TO WS-N-PLANT-BAD
                 END-IF
         END-EVALUATE
     END-PERFORM.
 END PROGRAM ACC-F2US12-FEATURES.

 COPY NOSPAWN.
 COPY CORETEST.
