*> Implementation test of the large ore veins (core/src/ore-veins.cob; T0433; docs/protocol/11 section 3.2 and 10.3): the ore_vein rule of the
*> material rule. Hand-authored fixture core/tests/fixtures/veins; world seed 7; the expected states come from the independent Python
*> evaluation core/tests/fixtures/veins/expected.py (Xoroshiro128++ of docs/protocol/10 section 2, the positional factory of
*> minecraft:ore, the three float draws of the rule in order). The block table is the test's own (air 0, stone 1, water 86,
*> lava 102, copper_ore 50, raw_copper_block 51, granite 52).
*>   Rule level (SURFACE-RULE on the rule files vein_*): vein_a (density 0.7, richness 0.5, gap -1, raw chance 0.25), vein_raw (richness 1, chance 1:
*>   every drawn block is raw), vein_gap (gap +1: every drawn block is filler), vein_all (density 1, richness 0: filler or nothing), vein_none (density 0:
*>   never). Six positions, among them one whose first draw is above 0.7 (no block: the next rule runs).
*>   Chunk level: the generation job of the chunk (-1, 2) with the material rule minecraft:overworld whose vein density is a range_choice of an
*>   interpolated y gradient (0.7 at y -32 to -1): the vein density reaches the rule through the chunk's interpolation grid (the ore_vein node's
*>   density is registered with the grids); stone below y -32, the states of every cell equal the Python evaluation (counts and checksum).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ORE-VEINS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY GENSTAGE.
 COPY GENSTEPS.
 COPY CBLOCKS.
 COPY CELLS.
 COPY CTWORLDGEN.
 COPY SURFACE.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/veins".
 01 WS-STATUS              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 3.
 01 WS-CX                  BINARY-LONG VALUE -1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-KIND-RULE           BINARY-LONG VALUE 2.
 01 WS-KEY                 PIC X(112).
 01 WS-ROOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-TEXT                PIC X(80).
 01 WS-ONE                 PIC X(8).
 01 WS-EDIT                PIC Z(3)9.
 01 WS-POINTER             BINARY-LONG.
 01 WS-CHECK               BINARY-DOUBLE.
 01 WS-N-STONE             BINARY-LONG.
 01 WS-N-ORE               BINARY-LONG.
 01 WS-N-RAW               BINARY-LONG.
 01 WS-N-FILLER            BINARY-LONG.
 01 WS-POINTS.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE -20.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE -14.
    05 FILLER BINARY-LONG VALUE -5.
    05 FILLER BINARY-LONG VALUE 40.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE -1.
    05 FILLER BINARY-LONG VALUE 32.
    05 FILLER BINARY-LONG VALUE -16.
    05 FILLER BINARY-LONG VALUE -32.
    05 FILLER BINARY-LONG VALUE 47.
    05 FILLER BINARY-LONG VALUE -9.
    05 FILLER BINARY-LONG VALUE -17.
    05 FILLER BINARY-LONG VALUE 35.
    05 FILLER BINARY-LONG VALUE -5.
    05 FILLER BINARY-LONG VALUE -30.
    05 FILLER BINARY-LONG VALUE 33.
 01 WS-POINT REDEFINES WS-POINTS.
    05 WS-PT OCCURS 6 TIMES.
       10 WS-PT-X          BINARY-LONG.
       10 WS-PT-Y          BINARY-LONG.
       10 WS-PT-Z          BINARY-LONG.
 01 WS-MINS.
    05 WS-MIN              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MAXS.
    05 WS-MAX              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-OFFSET              BINARY-DOUBLE VALUE 0.
 01 WS-NAME                PIC X(40) VALUE "minecraft:plains".
 01 WS-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==T-==.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "7" TO CS-SEED-TEXT
     MOVE 7 TO CW-SEED
     MOVE CORE-SETTINGS TO CW-SETTINGS
     MOVE 7 TO CB-BLOCK-COUNT
     MOVE "minecraft:air" TO CB-KEY(1)
     MOVE 13 TO CB-KEY-LENGTH(1)
     MOVE 0 TO CB-DEFAULT-STATE(1)
     MOVE "minecraft:stone" TO CB-KEY(2)
     MOVE 15 TO CB-KEY-LENGTH(2)
     MOVE 1 TO CB-DEFAULT-STATE(2)
     MOVE "minecraft:water" TO CB-KEY(3)
     MOVE 15 TO CB-KEY-LENGTH(3)
     MOVE 86 TO CB-DEFAULT-STATE(3)
     MOVE "minecraft:lava" TO CB-KEY(4)
     MOVE 14 TO CB-KEY-LENGTH(4)
     MOVE 102 TO CB-DEFAULT-STATE(4)
     MOVE "minecraft:copper_ore" TO CB-KEY(5)
     MOVE 20 TO CB-KEY-LENGTH(5)
     MOVE 50 TO CB-DEFAULT-STATE(5)
     MOVE "minecraft:raw_copper_block" TO CB-KEY(6)
     MOVE 26 TO CB-KEY-LENGTH(6)
     MOVE 51 TO CB-DEFAULT-STATE(6)
     MOVE "minecraft:granite" TO CB-KEY(7)
     MOVE 17 TO CB-KEY-LENGTH(7)
     MOVE 52 TO CB-DEFAULT-STATE(7)
     MOVE 1 TO CBI-COUNT
     MOVE "minecraft:plains" TO CBI-KEY(1)
     MOVE 16 TO CBI-KEY-LENGTH(1)
     CALL "CLIMATE-POINTS-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE -10000 TO WS-MIN(WS-I)
         MOVE 10000 TO WS-MAX(WS-I)
     END-PERFORM
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET
     CALL "WORLDGEN-FREE"
     CALL "NOISES-LOAD" USING WS-DIR WS-STATUS
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-DIR WS-STATUS
     CALL "MATERIAL-RULES-LOAD" USING WS-DIR WS-STATUS
     MOVE "test ore veins the fixture material rules load" TO TL-CASE
     MOVE WS-STATUS TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-QUEUE-RESET"
     CALL "GEN-JOB-START" USING WS-JOB WS-DIM WS-CX WS-CZ

     MOVE "T" TO TL-MODE
     MOVE "minecraft:vein_a" TO WS-KEY
     MOVE "test ore veins vein_a: ore, ore, ore, filler, no block (first draw above 0.7), filler" TO TL-CASE
     MOVE "50,50,50,52,-1,52" TO TL-EXPECTED
     PERFORM RULE-LEVEL
     MOVE "minecraft:vein_raw" TO WS-KEY
     MOVE "test ore veins vein_raw: every drawn block is raw copper" TO TL-CASE
     MOVE "51,51,51,51,-1,51" TO TL-EXPECTED
     PERFORM RULE-LEVEL
     MOVE "minecraft:vein_gap" TO WS-KEY
     MOVE "test ore veins vein_gap: the gap above the limit keeps every drawn block filler" TO TL-CASE
     MOVE "52,52,52,52,-1,52" TO TL-EXPECTED
     PERFORM RULE-LEVEL
     MOVE "minecraft:vein_all" TO WS-KEY
     MOVE "test ore veins vein_all: density 1 and richness 0 give filler everywhere" TO TL-CASE
     MOVE "52,52,52,52,52,52" TO TL-EXPECTED
     PERFORM RULE-LEVEL
     MOVE "minecraft:vein_none" TO WS-KEY
     MOVE "test ore veins vein_none: density 0 gives nothing" TO TL-CASE
     MOVE "-1,-1,-1,-1,-1,-1" TO TL-EXPECTED
     PERFORM RULE-LEVEL
     MOVE "N" TO TL-MODE

*>   the chunk (-1, 2) through the surface stage with the interpolated vein density
     PERFORM UNTIL T-ACTIVE NOT = 1 OR T-STAGE >= GJ-STAGE-CARVERS
         CALL "GEN-JOB-STEP" USING WS-JOB
     END-PERFORM
     SET ADDRESS OF CE-CHUNK TO T-ADDR
     MOVE 0 TO WS-CHECK WS-N-STONE WS-N-ORE WS-N-RAW WS-N-FILLER
     PERFORM VARYING WS-Y FROM -64 BY 1 UNTIL WS-Y > 319
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
             COMPUTE WS-CELL = (WS-Y + 64) * 256 + WS-I
             MOVE CE-STATE(WS-CELL) TO WS-STATE
             IF WS-Y < 0
                 COMPUTE WS-CHECK = FUNCTION MOD(WS-CHECK * 31 + WS-STATE, 1000003)
             END-IF
             EVALUATE WS-STATE
                 WHEN 1
                     ADD 1 TO WS-N-STONE
                 WHEN 50
                     ADD 1 TO WS-N-ORE
                 WHEN 51
                     ADD 1 TO WS-N-RAW
                 WHEN 52
                     ADD 1 TO WS-N-FILLER
             END-EVALUATE
         END-PERFORM
     END-PERFORM
     MOVE "test ore veins the chunk: stone cells (y -64 to -1, the others are veins)" TO TL-CASE
     MOVE WS-N-STONE TO TL-OBSERVED-N
     MOVE 10692 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test ore veins the chunk: copper ore cells" TO TL-CASE
     MOVE WS-N-ORE TO TL-OBSERVED-N
     MOVE 2150 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test ore veins the chunk: raw copper cells" TO TL-CASE
     MOVE WS-N-RAW TO TL-OBSERVED-N
     MOVE 728 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test ore veins the chunk: granite cells" TO TL-CASE
     MOVE WS-N-FILLER TO TL-OBSERVED-N
     MOVE 2814 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test ore veins the chunk: checksum of the states of y -64 to -1" TO TL-CASE
     MOVE WS-CHECK TO TL-OBSERVED-N
     MOVE 491417 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-JOB-FREE" USING WS-JOB
     STOP RUN.

*> the six positions through the rule of WS-KEY: the states as a comma separated text
 RULE-LEVEL.
     CALL "WG-FIND" USING WS-KIND-RULE WS-KEY WS-ROOT
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-POINTER
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > 6
         MOVE WS-PT-X(WS-P) TO SC-X
         MOVE WS-PT-Y(WS-P) TO SC-Y
         MOVE WS-PT-Z(WS-P) TO SC-Z
         CALL "SURFACE-RULE" USING WS-JOB WS-ROOT WS-RESULT
         IF WS-RESULT < 0
             MOVE "-1" TO WS-ONE
         ELSE
             MOVE WS-RESULT TO WS-EDIT
             MOVE FUNCTION TRIM(WS-EDIT) TO WS-ONE
         END-IF
         IF WS-P > 1
             STRING "," DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POINTER
         END-IF
         STRING FUNCTION TRIM(WS-ONE) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POINTER
     END-PERFORM
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ORE-VEINS.
 COPY CORETEST.
