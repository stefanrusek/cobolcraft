*> Implementation test (lane nether, work plan A; docs/protocol/37-nether-1 section 6.9, 38 section 2, 39 section 4): the standard world
*> type has three dimensions, and the placeholder generators of minecraft:the_nether (DIM-GEN-NETHER: bedrock floor y 0, netherrack to
*> GEN-NETHER-HIGH on chunks of even cx + cz and to GEN-NETHER-LOW on odd ones, lava above the floor up to GEN-NETHER-LAVA-TOP, air,
*> a netherrack ceiling from GEN-NETHER-CEILING and bedrock at GEN-NETHER-ROOF) and minecraft:the_end (DIM-GEN-END: an end_stone island
*> of radius GEN-END-RADIUS between GEN-END-BOTTOM and GEN-END-TOP, void elsewhere) fill chunks through the one dispatch point
*> WORLDGEN-DIM-CHUNK; their biomes are nether_wastes and the_end; a standard world saves each dimension in its own folder. Needs the
*> generated packs (CC_GENERATED_DIR, default /tmp/cc-test/generated): a pass without them.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-GEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CELLS.
 COPY NETHERDIM.
 COPY CBLOCKS.
 01 WS-DIR                 PIC X(1024).
 01 WS-SAVE-CBI            BINARY-LONG.
 01 WS-LAVA-LOW            BINARY-LONG.
 01 WS-LAVA-HIGH           BINARY-LONG.
 01 WS-RACK                BINARY-LONG.
 01 WS-BED0                BINARY-LONG.
 01 WS-BED127              BINARY-LONG.
 01 WS-AIR-TOP             BINARY-LONG.
 01 WS-DIFF                BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-KEY-BEDROCK         PIC X(48) VALUE "minecraft:bedrock".
 01 WS-KEY-NETHERRACK      PIC X(48) VALUE "minecraft:netherrack".
 01 WS-KEY-LAVA            PIC X(48) VALUE "minecraft:lava".
 01 WS-KEY-END-STONE       PIC X(48) VALUE "minecraft:end_stone".
 01 WS-BEDROCK             BINARY-LONG.
 01 WS-NETHERRACK          BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-END-STONE           BINARY-LONG.
 01 WS-NAME-WASTES         PIC X(40) VALUE "minecraft:nether_wastes".
 01 WS-NAME-END            PIC X(40) VALUE "minecraft:the_end".
 01 WS-WASTES              BINARY-LONG.
 01 WS-THE-END             BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-MARKER              BINARY-LONG.
 01 WS-BIOMES.
    05 WS-BIOME            BINARY-LONG OCCURS 16 TIMES.
 01 WS-CHUNK               PIC X(304640).
 01 WS-STATE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-DIR-NAME            PIC X(1100).
 01 WS-SAVE-STATE          BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-KEEP                BINARY-LONG VALUE 3.
 01 WS-P1                  BINARY-LONG.
 01 WS-P2                  BINARY-LONG.
 01 WS-P3                  BINARY-LONG.
 01 WS-MODE                PIC 9 VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-BYTES               PIC X(1024) BASED.
 COPY PROTO.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-E6                  PIC -(9)9.
 01 WS-E7                  PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
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
         MOVE "test nether gen no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-EXTRA-DIMENSIONS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "GEN-BLOCK-STATE" USING WS-KEY-BEDROCK WS-BEDROCK
     CALL "GEN-BLOCK-STATE" USING WS-KEY-NETHERRACK WS-NETHERRACK
     CALL "GEN-BLOCK-STATE" USING WS-KEY-LAVA WS-LAVA
     CALL "GEN-BLOCK-STATE" USING WS-KEY-END-STONE WS-END-STONE
     CALL "SURFACE-BIOME-ID" USING WS-NAME-WASTES WS-WASTES
     CALL "SURFACE-BIOME-ID" USING WS-NAME-END WS-THE-END

     MOVE "test nether gen the table has the generator constants of the nether and the end rows" TO TL-CASE
     MOVE DM-GENERATOR(DIM-STANDARD-NETHER) TO WS-E1
     MOVE DM-GENERATOR(DIM-STANDARD-END) TO WS-E2
     MOVE DIM-GEN-NETHER TO WS-E3
     MOVE DIM-GEN-END TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "4 5 4 5" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test nether gen an open standard world with extra-dimensions on has the overworld, the nether and the end" TO TL-CASE
     MOVE CW-DIM-COUNT TO WS-E1
     MOVE CW-DIM(1) TO WS-E2
     MOVE CW-DIM(2) TO WS-E3
     MOVE CW-DIM(3) TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "3 3 4 5" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A world whose biome table lacks the Nether's keeps the placeholder terrain (NETHER-DIM-READY 0).
     MOVE CBI-COUNT TO WS-SAVE-CBI
     MOVE 0 TO CBI-COUNT
*>   Nether, chunk (0, 0): even, the high floor.
     MOVE DIM-STANDARD-NETHER TO WS-DIM
     MOVE 0 TO WS-CX WS-CZ
     MOVE LOW-VALUES TO WS-CHUNK
     CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-CHUNK WS-MARKER
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF WS-CHUNK
     MOVE "test nether gen chunk (0, 0) column (5, 5): bedrock 0, netherrack 1 and 40, air 41 to 99, "
         & "netherrack 100 and 126, bedrock 127, air 128 and 255, no marker" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 255
         EVALUATE WS-Y
             WHEN 0 WHEN 1 WHEN 40 WHEN 41 WHEN 99 WHEN 100 WHEN 126 WHEN 127 WHEN 128 WHEN 255
                 COMPUTE WS-CELL = WS-Y * 256 + 5 * 16 + 5 + 1
                 EVALUATE CE-STATE(WS-CELL)
                     WHEN WS-BEDROCK STRING FUNCTION TRIM(TL-OBSERVED) " B" DELIMITED BY SIZE INTO TL-OBSERVED
                     WHEN WS-NETHERRACK STRING FUNCTION TRIM(TL-OBSERVED) " N" DELIMITED BY SIZE INTO TL-OBSERVED
                     WHEN WS-LAVA STRING FUNCTION TRIM(TL-OBSERVED) " L" DELIMITED BY SIZE INTO TL-OBSERVED
                     WHEN 0 STRING FUNCTION TRIM(TL-OBSERVED) " A" DELIMITED BY SIZE INTO TL-OBSERVED
                     WHEN OTHER STRING FUNCTION TRIM(TL-OBSERVED) " ?" DELIMITED BY SIZE INTO TL-OBSERVED
                 END-EVALUATE
         END-EVALUATE
     END-PERFORM
     MOVE WS-MARKER TO WS-E1
     STRING FUNCTION TRIM(TL-OBSERVED) " m" FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "B N N A A N N B A A m-1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Nether, chunk (1, 0): odd, the low floor under the lava ocean.
     MOVE 1 TO WS-CX
     MOVE LOW-VALUES TO WS-CHUNK
     CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-CHUNK WS-MARKER
     MOVE "test nether gen chunk (1, 0) column (0, 15): netherrack 20, lava 21 and 31, air 32" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-Y FROM 20 BY 1 UNTIL WS-Y > 32
         EVALUATE WS-Y
             WHEN 20 WHEN 21 WHEN 31 WHEN 32
                 COMPUTE WS-CELL = WS-Y * 256 + 15 * 16 + 0 + 1
                 EVALUATE CE-STATE(WS-CELL)
                     WHEN WS-NETHERRACK STRING FUNCTION TRIM(TL-OBSERVED) " N" DELIMITED BY SIZE INTO TL-OBSERVED
                     WHEN WS-LAVA STRING FUNCTION TRIM(TL-OBSERVED) " L" DELIMITED BY SIZE INTO TL-OBSERVED
                     WHEN 0 STRING FUNCTION TRIM(TL-OBSERVED) " A" DELIMITED BY SIZE INTO TL-OBSERVED
                     WHEN OTHER STRING FUNCTION TRIM(TL-OBSERVED) " ?" DELIMITED BY SIZE INTO TL-OBSERVED
                 END-EVALUATE
         END-EVALUATE
     END-PERFORM
     MOVE "N L L A" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Negative chunk coordinates keep the parity: (-1, 0) is odd like (1, 0).
     MOVE -1 TO WS-CX
     MOVE LOW-VALUES TO WS-CHUNK
     CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-CHUNK WS-MARKER
     MOVE "test nether gen chunk (-1, 0) is an odd chunk: lava at 31 in every column of the chunk" TO TL-CASE
     COMPUTE WS-CELL = 31 * 256 + 1
     MOVE SPACES TO TL-OBSERVED
     IF CE-STATE(WS-CELL) = WS-LAVA
         MOVE "lava" TO TL-OBSERVED
     ELSE
         MOVE "other" TO TL-OBSERVED
     END-IF
     MOVE "lava" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE WS-SAVE-CBI TO CBI-COUNT

*>   Ready tables: the real generator. Chunk (1, 0) in every column: bedrock at 0 and 127, a lava sea at y 1 to 31 only, netherrack, air above the roof.
     MOVE DIM-STANDARD-NETHER TO WS-DIM
     MOVE 1 TO WS-CX
     MOVE 0 TO WS-CZ
     MOVE LOW-VALUES TO WS-CHUNK
     CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-CHUNK WS-MARKER
     MOVE 0 TO WS-BED0 WS-BED127 WS-LAVA-LOW WS-LAVA-HIGH WS-RACK WS-AIR-TOP
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 256
         COMPUTE WS-CELL = WS-C
         IF CE-STATE(WS-CELL) = WS-BEDROCK
             ADD 1 TO WS-BED0
         END-IF
         COMPUTE WS-CELL = 127 * 256 + WS-C
         IF CE-STATE(WS-CELL) = WS-BEDROCK
             ADD 1 TO WS-BED127
         END-IF
         PERFORM VARYING WS-Y FROM 1 BY 1 UNTIL WS-Y > 126
             COMPUTE WS-CELL = WS-Y * 256 + WS-C
             EVALUATE TRUE
                 WHEN CE-STATE(WS-CELL) = WS-LAVA AND WS-Y <= 31
                     ADD 1 TO WS-LAVA-LOW
                 WHEN CE-STATE(WS-CELL) = WS-LAVA
                     ADD 1 TO WS-LAVA-HIGH
                 WHEN CE-STATE(WS-CELL) = WS-NETHERRACK AND WS-Y > 32 AND WS-Y < 100
                     ADD 1 TO WS-RACK
             END-EVALUATE
         END-PERFORM
         PERFORM VARYING WS-Y FROM 128 BY 1 UNTIL WS-Y > 255
             COMPUTE WS-CELL = WS-Y * 256 + WS-C
             IF CE-STATE(WS-CELL) NOT = 0
                 ADD 1 TO WS-AIR-TOP
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "test nether gen the real terrain of chunk (1, 0): bedrock floor and roof in all 256 columns, lava only at y <= 31, "
         & "netherrack in the open middle (an odd chunk's placeholder has none), nothing above the roof, no marker" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     IF WS-LAVA-LOW > 0
         MOVE 1 TO WS-LAVA-LOW
     END-IF
     IF WS-RACK > 1000
         MOVE 1 TO WS-RACK
     END-IF
     MOVE WS-BED0 TO WS-E1
     MOVE WS-BED127 TO WS-E2
     MOVE WS-LAVA-LOW TO WS-E3
     MOVE WS-LAVA-HIGH TO WS-E4
     MOVE WS-RACK TO WS-E5
     MOVE WS-AIR-TOP TO WS-E6
     MOVE WS-MARKER TO WS-E7
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) " "
         FUNCTION TRIM(WS-E5) " " FUNCTION TRIM(WS-E6) " " FUNCTION TRIM(WS-E7) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "256 256 1 0 1 0 -1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The placeholder End (the real End is tested in test_end_dim): chunk (0, 0) holds the island, a far chunk is void.
     MOVE 1 TO ND-PLACEHOLDER
     MOVE DIM-STANDARD-END TO WS-DIM
     MOVE 0 TO WS-CX
     MOVE LOW-VALUES TO WS-CHUNK
     CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-CHUNK WS-MARKER
     MOVE "test nether gen the end chunk (0, 0) column (3, 4): air 39, end_stone 40 and 63, air 64, no marker" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-Y FROM 39 BY 1 UNTIL WS-Y > 64
         EVALUATE WS-Y
             WHEN 39 WHEN 40 WHEN 63 WHEN 64
                 COMPUTE WS-CELL = WS-Y * 256 + 4 * 16 + 3 + 1
                 EVALUATE CE-STATE(WS-CELL)
                     WHEN WS-END-STONE STRING FUNCTION TRIM(TL-OBSERVED) " E" DELIMITED BY SIZE INTO TL-OBSERVED
                     WHEN 0 STRING FUNCTION TRIM(TL-OBSERVED) " A" DELIMITED BY SIZE INTO TL-OBSERVED
                     WHEN OTHER STRING FUNCTION TRIM(TL-OBSERVED) " ?" DELIMITED BY SIZE INTO TL-OBSERVED
                 END-EVALUATE
         END-EVALUATE
     END-PERFORM
     MOVE WS-MARKER TO WS-E1
     STRING FUNCTION TRIM(TL-OBSERVED) " m" FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "A E E A m-1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 10 TO WS-CX
     MOVE 10 TO WS-CZ
     MOVE LOW-VALUES TO WS-CHUNK
     CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-CHUNK WS-MARKER
     MOVE "test nether gen the end chunk (10, 10) is void" TO TL-CASE
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 65536
         IF CE-STATE(WS-CELL) NOT = 0
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE WS-COUNT TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The island edge: x 63, z 0 is inside (63 squared < 64 squared), x 64, z 1 is outside.
     MOVE 3 TO WS-CX
     MOVE 0 TO WS-CZ
     MOVE LOW-VALUES TO WS-CHUNK
     CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-CHUNK WS-MARKER
     MOVE "test nether gen the island edge: (63, 0) is end_stone at 50, (63, 63) is air (chunk (3, 0) holds x 48 to 63)" TO TL-CASE
     COMPUTE WS-CELL = 50 * 256 + 0 * 16 + 15 + 1
     MOVE SPACES TO TL-OBSERVED
     IF CE-STATE(WS-CELL) = WS-END-STONE
         MOVE "E" TO TL-OBSERVED
     ELSE
         MOVE "?" TO TL-OBSERVED
     END-IF
     MOVE 3 TO WS-CZ
     MOVE LOW-VALUES TO WS-CHUNK
     CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-CHUNK WS-MARKER
     COMPUTE WS-CELL = 50 * 256 + 15 * 16 + 15 + 1
     IF CE-STATE(WS-CELL) = 0
         STRING FUNCTION TRIM(TL-OBSERVED) " A" DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(TL-OBSERVED) " ?" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE "E A" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO ND-PLACEHOLDER
*>   Biomes through the dispatch point: the Nether biome source agrees with the biome cells the generator stored, and the end is the_end.
     MOVE DIM-STANDARD-NETHER TO WS-DIM
     MOVE 1 TO WS-CX
     MOVE 0 TO WS-CZ
     MOVE LOW-VALUES TO WS-CHUNK
     CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-CHUNK WS-MARKER
     CALL "WORLDGEN-DIM-BIOMES" USING WS-DIM WS-CX WS-CZ WS-BIOMES
     MOVE "test nether gen the biomes of the nether columns are the biomes the generator stored (all rows of a section equal)" TO TL-CASE
     MOVE 0 TO WS-DIFF
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 16
         IF CE-BIOME(WS-C) NOT = WS-BIOME(WS-C)
             ADD 1 TO WS-DIFF
         END-IF
     END-PERFORM
     MOVE WS-DIFF TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO CBI-COUNT
     CALL "WORLDGEN-DIM-BIOMES" USING WS-DIM WS-CX WS-CZ WS-BIOMES
     MOVE WS-SAVE-CBI TO CBI-COUNT
     MOVE "test nether gen without the Nether biomes in the table the placeholder biome is the first id 0 in every column" TO TL-CASE
     MOVE WS-BIOME(1) TO WS-E1
     MOVE WS-BIOME(16) TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE DIM-STANDARD-END TO WS-DIM
     CALL "WORLDGEN-DIM-BIOMES" USING WS-DIM WS-CX WS-CZ WS-BIOMES
     MOVE "test nether gen the biome of every end column is minecraft:the_end" TO TL-CASE
     MOVE WS-BIOME(7) TO WS-E4
     MOVE WS-THE-END TO WS-E5
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     MOVE FUNCTION TRIM(WS-E4) TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-E5) TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The cache and the world calls: a block read in the nether generates it; bedrock at the floor, y 255 is air.
     MOVE 5 TO WS-X
     MOVE 0 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-NETHER WS-X WS-Y WS-Z WS-STATE
     MOVE "test nether gen WORLD-GET-BLOCK in the nether reads the generated bedrock floor and 0 above 255" TO TL-CASE
     MOVE 0 TO WS-E1
     IF WS-STATE = WS-BEDROCK
         MOVE 1 TO WS-E1
     END-IF
     MOVE 300 TO WS-Y
     CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-NETHER WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Login lists the three dimension names, Respawn into the nether and the end carries the dimension type id, key, sea level, data to keep.
     INITIALIZE PL-ENTRY(1)
     MOVE 1 TO PL-ENTITY-ID(1)
     MOVE DIM-STANDARD-OVERWORLD TO PL-DIM(1)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PLAY-LOGIN-BUILD" USING WS-ONE PB-BUFFER
     SET ADDRESS OF WS-BYTES TO PB-ADDR
     MOVE "test nether gen Login of a standard world lists minecraft:overworld, minecraft:the_nether, minecraft:the_end in order" TO TL-CASE
     MOVE 0 TO WS-P1 WS-P2 WS-P3
     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-COUNT FROM 1 BY 1 UNTIL WS-COUNT > PB-LENGTH - 20
         IF WS-BYTES(WS-COUNT:19) = "minecraft:overworld" AND WS-P1 = 0
             MOVE WS-COUNT TO WS-P1
         END-IF
         IF WS-BYTES(WS-COUNT:20) = "minecraft:the_nether" AND WS-P2 = 0
             MOVE WS-COUNT TO WS-P2
         END-IF
         IF WS-BYTES(WS-COUNT:17) = "minecraft:the_end" AND WS-P3 = 0
             MOVE WS-COUNT TO WS-P3
         END-IF
     END-PERFORM
     IF WS-P1 > 0 AND WS-P2 > WS-P1 AND WS-P3 > WS-P2
         MOVE "ordered" TO TL-OBSERVED
     ELSE
         MOVE "missing or out of order" TO TL-OBSERVED
     END-IF
     MOVE "ordered" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-RESPAWN-BUILD" USING DIM-STANDARD-NETHER WS-MODE WS-KEEP PB-BUFFER
     MOVE "test nether gen Respawn into the nether: type id 1, key length 20, sea level 32, data to keep 3" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION HEX-OF(WS-BYTES(1:3)) TO TL-OBSERVED(1:6)
     MOVE FUNCTION HEX-OF(WS-BYTES(PB-LENGTH - 1:2)) TO TL-OBSERVED(8:4)
     MOVE "540114 2003" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-RESPAWN-BUILD" USING DIM-STANDARD-END WS-MODE WS-KEEP PB-BUFFER
     MOVE "test nether gen Respawn into the end: type id 2, key length 17, sea level 0, data to keep 3" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION HEX-OF(WS-BYTES(1:3)) TO TL-OBSERVED(1:6)
     MOVE FUNCTION HEX-OF(WS-BYTES(PB-LENGTH - 1:2)) TO TL-OBSERVED(8:4)
     MOVE "540211 0003" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-FREE" USING PB-BUFFER

*>   Saves: every dimension of the world has its folder, and a changed nether chunk is written into the nether's region folder.
     MOVE 41 TO WS-Y
     MOVE WS-BEDROCK TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING DIM-STANDARD-NETHER WS-X WS-Y WS-Z WS-STATE
     CALL "CORE-SAVE"
     MOVE "test nether gen after a save the three dimension folders exist with a region file in the nether's" TO TL-CASE
     MOVE 0 TO WS-E1 WS-E2 WS-E3 WS-E4
     MOVE SPACES TO WS-DIR-NAME
     STRING "build/core-test-world/dimensions/minecraft/overworld/region" X"00" DELIMITED BY SIZE INTO WS-DIR-NAME
     CALL "CBL_CHECK_FILE_EXIST" USING WS-DIR-NAME WS-FILE-INFO
     IF RETURN-CODE = 0 MOVE 1 TO WS-E1 END-IF
     MOVE SPACES TO WS-DIR-NAME
     STRING "build/core-test-world/dimensions/minecraft/the_nether/region" X"00" DELIMITED BY SIZE INTO WS-DIR-NAME
     CALL "CBL_CHECK_FILE_EXIST" USING WS-DIR-NAME WS-FILE-INFO
     IF RETURN-CODE = 0 MOVE 1 TO WS-E2 END-IF
     MOVE SPACES TO WS-DIR-NAME
     STRING "build/core-test-world/dimensions/minecraft/the_end/entities" X"00" DELIMITED BY SIZE INTO WS-DIR-NAME
     CALL "CBL_CHECK_FILE_EXIST" USING WS-DIR-NAME WS-FILE-INFO
     IF RETURN-CODE = 0 MOVE 1 TO WS-E3 END-IF
     MOVE SPACES TO WS-DIR-NAME
     STRING "build/core-test-world/dimensions/minecraft/the_nether/region/r.0.0.mca" X"00" DELIMITED BY SIZE INTO WS-DIR-NAME
     CALL "CBL_CHECK_FILE_EXIST" USING WS-DIR-NAME WS-FILE-INFO
     IF RETURN-CODE = 0 MOVE 1 TO WS-E4 END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) FUNCTION TRIM(WS-E2) FUNCTION TRIM(WS-E3) FUNCTION TRIM(WS-E4) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "1111" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The world opened again: the edit comes back from the nether's region file, in the nether only.
     MOVE Z"build/core-test-world" TO WS-DIR-NAME
     CALL "CORE-WORLD-OPEN" USING WS-DIR-NAME CORE-SETTINGS WS-SAVE-STATE
     MOVE 41 TO WS-Y
     CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-NETHER WS-X WS-Y WS-Z WS-STATE
     MOVE "test nether gen a reopened world holds the edit at (5, 41, 5) of the nether and three dimensions" TO TL-CASE
     MOVE 0 TO WS-E1
     IF WS-STATE = WS-BEDROCK
         MOVE 1 TO WS-E1
     END-IF
     MOVE CW-DIM-COUNT TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-NETHER-GEN.

 COPY CORETEST.
