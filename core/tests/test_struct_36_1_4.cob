*> Acceptance test of docs/protocol/36-structures-1 section 4 (placement engines): the random_spread potential chunk (the table of 12.1, both spread
*> types, negative cells, other seeds), the four frequency reducers, the conjunction of isStructureChunk with the exclusion zone, the possible structure
*> sets of a biome source (4.1), concentric rings (the raw positions of 12.3, then the biome snap and the ring list), dimension_origin and the locate
*> position. The expected values come from tests/fixtures/struct and an independent script that follows the document (not from the COBOL).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-1-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTDATA.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/struct".
 01 WS-CLIMATE-DIR         PIC X(1100) VALUE "core/tests/fixtures/density".
 01 WS-STATUS              BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-SET                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SUM                 BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-TEXT                PIC X(240).
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT-A              PIC -(9)9.
 01 WS-EDIT-B              PIC -(9)9.
 01 WS-MINS.
    05 WS-MIN              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MAXS.
    05 WS-MAX              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-OFFSET              BINARY-DOUBLE.
 01 WS-NAME                PIC X(40).
 01 WS-DISTANCE            BINARY-LONG.
 01 WS-SPREAD              BINARY-LONG.
 01 WS-NUM                 BINARY-LONG.
 01 WS-RAW.
    05 WS-RAW-ROW OCCURS 256 TIMES.
       10 WS-RAW-X         BINARY-LONG.
       10 WS-RAW-Z         BINARY-LONG.
       10 WS-RAW-SEED      BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "STRUCT-LOAD" USING WS-DIR WS-STATUS
     MOVE 0 TO WS-SEED

*>   random_spread (4.3, 12.1)
     MOVE "acceptance US12 36-1§4 Placement engines: linear potential chunks of the cells of chunks (0,0) (5,7) (-1,-1) (40,-33), seed 0" TO TL-CASE
     MOVE 1 TO WS-SET
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM POTENTIAL-ROW
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "19,16 19,16 -18,-26 33,-44" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§4 Placement engines: triangular potential chunks (two draws, integer division), seed 0" TO TL-CASE
     MOVE 7 TO WS-SET
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM POTENTIAL-ROW
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "17,10 17,10 -22,-26 42,-53" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§4 Placement engines: the cell of a negative seed, chunks (0,0) (-1,-1) (40,-33) (100,100)" TO TL-CASE
     MOVE 1 TO WS-SET
     MOVE -5 TO WS-SEED
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE 0 TO WS-CX
     MOVE 0 TO WS-CZ
     PERFORM POTENTIAL-ONE
     MOVE -1 TO WS-CX
     MOVE -1 TO WS-CZ
     PERFORM POTENTIAL-ONE
     MOVE 40 TO WS-CX
     MOVE -33 TO WS-CZ
     PERFORM POTENTIAL-ONE
     MOVE 100 TO WS-CX
     MOVE 100 TO WS-CZ
     PERFORM POTENTIAL-ONE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "19,8 -32,-26 33,-52 96,105" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 77 TO WS-SEED
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE 0 TO WS-CX
     MOVE 0 TO WS-CZ
     PERFORM POTENTIAL-ONE
     MOVE "acceptance US12 36-1§4 Placement engines: seed 77 gives cell (0,0) the chunk (17,3)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "17,3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-SEED
     MOVE "N" TO TL-MODE
     MOVE 1 TO WS-SET
     MOVE 19 TO WS-CX
     MOVE 16 TO WS-CZ
     CALL "STRUCT-IS-CHUNK" USING WS-SET WS-SEED WS-CX WS-CZ WS-FLAG
     MOVE "acceptance US12 36-1§4 Placement engines: the potential chunk (19,16) is a structure chunk" TO TL-CASE
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-CX
     MOVE 0 TO WS-CZ
     CALL "STRUCT-IS-CHUNK" USING WS-SET WS-SEED WS-CX WS-CZ WS-FLAG
     MOVE "acceptance US12 36-1§4 Placement engines: chunk (0,0) is not (the potential chunk of its cell is (19,16))" TO TL-CASE
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-SET
     MOVE 0 TO WS-COUNT
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-CX FROM -96 BY 1 UNTIL WS-CX > 95
         PERFORM VARYING WS-CZ FROM -96 BY 1 UNTIL WS-CZ > 95
             CALL "STRUCT-IS-CHUNK" USING WS-SET WS-SEED WS-CX WS-CZ WS-FLAG
             IF WS-FLAG = 1
                 ADD 1 TO WS-COUNT
                 COMPUTE WS-SUM = WS-SUM + WS-CX * 1000 + WS-CZ
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-1§4 Placement engines: a 192 x 192 chunk area holds 36 structure chunks of alpha_set (count)" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 36 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§4 Placement engines: and their coordinates (checksum of x * 1000 + z)" TO TL-CASE
     MOVE WS-SUM TO TL-OBSERVED-N
     MOVE -198094 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   frequency reduction (4.4): chunks 0 to 15 square, seed 7
     MOVE 7 TO WS-SEED
     MOVE 8 TO WS-SET
     PERFORM FREQ-SQUARE
     MOVE "acceptance US12 36-1§4 Placement engines: default reducer (nextFloat < frequency, salt of the placement), count" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 121 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§4 Placement engines: default reducer checksum" TO TL-CASE
     MOVE WS-SUM TO TL-OBSERVED-N
     MOVE 876860 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-SET
     PERFORM FREQ-SQUARE
     MOVE "acceptance US12 36-1§4 Placement engines: legacy_type_2 (fixed salt 10387320), count" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 126 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§4 Placement engines: legacy_type_2 checksum" TO TL-CASE
     MOVE WS-SUM TO TL-OBSERVED-N
     MOVE 928918 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-SET
     PERFORM FREQ-SQUARE
     MOVE "acceptance US12 36-1§4 Placement engines: legacy_type_3 (setLargeFeatureSeed, nextDouble), count" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 128 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§4 Placement engines: legacy_type_3 checksum" TO TL-CASE
     MOVE WS-SUM TO TL-OBSERVED-N
     MOVE 931992 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-SET
     MOVE 0 TO WS-COUNT
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM -8 BY 1 UNTIL WS-I > 7
         PERFORM VARYING WS-J FROM -8 BY 1 UNTIL WS-J > 7
             COMPUTE WS-CX = WS-I * 16
             COMPUTE WS-CZ = WS-J * 16
             CALL "STRUCT-FREQ-OK" USING WS-SET WS-SEED WS-CX WS-CZ WS-FLAG
             IF WS-FLAG = 1
                 ADD 1 TO WS-COUNT
                 COMPUTE WS-SUM = WS-SUM + WS-CX * 1000 + WS-CZ
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-1§4 Placement engines: legacy_type_1 (cell of 16 chunks, one nextInt discarded, 1 / 0.25 = 4), count over 256 cells" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 64 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§4 Placement engines: legacy_type_1 checksum" TO TL-CASE
     MOVE WS-SUM TO TL-OBSERVED-N
     MOVE -592256 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -123456789 TO WS-SEED
     MOVE 0 TO WS-COUNT
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM -8 BY 1 UNTIL WS-I > 7
         PERFORM VARYING WS-J FROM -8 BY 1 UNTIL WS-J > 7
             COMPUTE WS-CX = WS-I * 16 + 3
             COMPUTE WS-CZ = WS-J * 16 - 5
             CALL "STRUCT-FREQ-OK" USING WS-SET WS-SEED WS-CX WS-CZ WS-FLAG
             IF WS-FLAG = 1
                 ADD 1 TO WS-COUNT
                 COMPUTE WS-SUM = WS-SUM + WS-CX * 1000 + WS-CZ
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-1§4 Placement engines: legacy_type_1 with a negative seed and negative chunks (arithmetic shift), count" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 66 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§4 Placement engines: and checksum" TO TL-CASE
     MOVE WS-SUM TO TL-OBSERVED-N
     MOVE -443162 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-SET
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-CX FROM 0 BY 1 UNTIL WS-CX > 9
         CALL "STRUCT-FREQ-OK" USING WS-SET WS-SEED WS-CX WS-CX WS-FLAG
         ADD WS-FLAG TO WS-COUNT
     END-PERFORM
     MOVE "acceptance US12 36-1§4 Placement engines: frequency 1.0 skips the reducer (all pass)" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 10 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   exclusion zone (4.5)
     MOVE 8 TO WS-SET
     MOVE 0 TO WS-SEED
     PERFORM TRI-AREA
     MOVE "acceptance US12 36-1§4 Placement engines: set with frequency 0.5 and an exclusion zone of 8 chunks round alpha_set, seed 0 (count)" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 7 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§4 Placement engines: and the chunks (checksum)" TO TL-CASE
     MOVE WS-SUM TO TL-OBSERVED-N
     MOVE 48985 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-SEED
     PERFORM TRI-AREA
     MOVE "acceptance US12 36-1§4 Placement engines: the same with seed 3 (count)" TO TL-CASE
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 7 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§4 Placement engines: seed 3 checksum" TO TL-CASE
     MOVE WS-SUM TO TL-OBSERVED-N
     MOVE -15035 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-SEED
     MOVE 1 TO WS-SET
     MOVE 19 TO WS-CX
     MOVE 16 TO WS-CZ
     MOVE 0 TO WS-R
     CALL "STRUCT-IN-RANGE" USING WS-SET WS-SEED WS-CX WS-CZ WS-R WS-FLAG
     MOVE "acceptance US12 36-1§4 Placement engines: hasStructureChunkInRange with radius 0 on the structure chunk itself" TO TL-CASE
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-CX
     MOVE 0 TO WS-CZ
     MOVE 18 TO WS-R
     CALL "STRUCT-IN-RANGE" USING WS-SET WS-SEED WS-CX WS-CZ WS-R WS-FLAG
     MOVE "acceptance US12 36-1§4 Placement engines: from (0,0) radius 18 reaches no alpha chunk (19 is one too far)" TO TL-CASE
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 19 TO WS-R
     CALL "STRUCT-IN-RANGE" USING WS-SET WS-SEED WS-CX WS-CZ WS-R WS-FLAG
     MOVE "acceptance US12 36-1§4 Placement engines: radius 19 does" TO TL-CASE
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   concentric rings (4.6): the raw positions of 12.3
     MOVE 32 TO WS-DISTANCE
     MOVE 3 TO WS-SPREAD
     MOVE 12 TO WS-NUM
     MOVE 0 TO WS-USEED
     CALL "STRUCT-RINGS-RAW" USING WS-DISTANCE WS-SPREAD WS-NUM WS-USEED WS-RAW
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE WS-RAW-X(WS-I) TO WS-EDIT-A
         MOVE WS-RAW-Z(WS-I) TO WS-EDIT-B
         STRING FUNCTION TRIM(WS-EDIT-A) "," FUNCTION TRIM(WS-EDIT-B) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-PERFORM
     MOVE "acceptance US12 36-1§4 Placement engines: the twelve raw ring positions of distance 32, spread 3, count 12, seed 0 (12.3)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "-13,-106 121,52 -92,69 -75,-342 223,-203 278,89 69,316 -213,194 -298,-95 -138,-492 511,-143 145,519" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12345 TO WS-USEED
     CALL "STRUCT-RINGS-RAW" USING WS-DISTANCE WS-SPREAD WS-NUM WS-USEED WS-RAW
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE WS-RAW-X(WS-I) TO WS-EDIT-A
         MOVE WS-RAW-Z(WS-I) TO WS-EDIT-B
         STRING FUNCTION TRIM(WS-EDIT-A) "," FUNCTION TRIM(WS-EDIT-B) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-PERFORM
     MOVE "acceptance US12 36-1§4 Placement engines: the first positions of seed 12345 (12.3)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "-105,124 -39,-107 114,21" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-NUM
     MOVE 99 TO WS-RAW-X(1)
     CALL "STRUCT-RINGS-RAW" USING WS-DISTANCE WS-SPREAD WS-NUM WS-USEED WS-RAW
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 36-1§4 Placement engines: count 0 gives an empty list" TO TL-CASE
     MOVE WS-RAW-X(1) TO TL-OBSERVED-N
     MOVE 99 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the biome source: possible sets (4.1) and the ring list with its biome snap (4.6.1)
     CALL "WORLDGEN-FREE"
     CALL "NOISES-LOAD" USING WS-CLIMATE-DIR WS-STATUS
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-CLIMATE-DIR WS-STATUS
     MOVE 0 TO WS-SEED
     MOVE 0 TO WS-USEED
     CALL "DENSITY-SETUP" USING WS-USEED
     CALL "CLIMATE-POINTS-RESET"
     CALL "STRUCT-POSSIBLE-BUILD"
     MOVE "acceptance US12 36-1§4 Placement engines: with no biome in the source no set is possible" TO TL-CASE
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-SET-COUNT
         ADD SS-POSSIBLE(WS-I) TO WS-COUNT
     END-PERFORM
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:forest" TO WS-NAME
     PERFORM ADD-POINT
     MOVE 6 TO WS-SET
     MOVE 0 TO WS-USEED
     CALL "STRUCT-RINGS-BUILD" USING WS-SET WS-SEED
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 36-1§4 Placement engines: no cell of the preferred biome plains: each ring chunk is its raw position" TO TL-CASE
     PERFORM RING-LIST
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "-13,-106 121,52 -92,69" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "CLIMATE-POINTS-RESET"
     MOVE "minecraft:plains" TO WS-NAME
     PERFORM ADD-POINT
     CALL "STRUCT-POSSIBLE-BUILD"
     MOVE "acceptance US12 36-1§4 Placement engines: with plains in the source the sets of plains structures are possible (1 1 1 1 0 0 1 1; the sets of the forest-only structure are not)" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE SS-POSSIBLE(WS-I) TO WS-EDIT-A
         STRING FUNCTION TRIM(WS-EDIT-A) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-PERFORM
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "1 1 1 1 0 0 1 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-SET
     CALL "STRUCT-RINGS-BUILD" USING WS-SET WS-SEED
     MOVE "acceptance US12 36-1§4 Placement engines: every cell is plains: the snap picks by reservoir sampling with the forked source, seed 0" TO TL-CASE
     PERFORM RING-LIST
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "-13,-101 126,58 -99,71" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE -13 TO WS-CX
     MOVE -101 TO WS-CZ
     CALL "STRUCT-IS-CHUNK" USING WS-SET WS-SEED WS-CX WS-CZ WS-FLAG
     MOVE "acceptance US12 36-1§4 Placement engines: a ring chunk is a structure chunk of the rings set" TO TL-CASE
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -13 TO WS-CX
     MOVE -100 TO WS-CZ
     CALL "STRUCT-IS-CHUNK" USING WS-SET WS-SEED WS-CX WS-CZ WS-FLAG
     MOVE "acceptance US12 36-1§4 Placement engines: its neighbour is not" TO TL-CASE
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12345 TO WS-SEED
     MOVE -106 TO WS-CX
     MOVE 123 TO WS-CZ
     CALL "STRUCT-IS-CHUNK" USING WS-SET WS-SEED WS-CX WS-CZ WS-FLAG
     MOVE "acceptance US12 36-1§4 Placement engines: a new seed builds the list again (seed 12345 first ring chunk (-106,123))" TO TL-CASE
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -99 TO WS-SEED
     MOVE 118 TO WS-CX
     MOVE -47 TO WS-CZ
     CALL "STRUCT-IS-CHUNK" USING WS-SET WS-SEED WS-CX WS-CZ WS-FLAG
     MOVE "acceptance US12 36-1§4 Placement engines: a negative seed (-99) gives (118,-47) among the rings" TO TL-CASE
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   dimension_origin (4.7) and the locate position (4.8)
     MOVE 5 TO WS-SET
     MOVE 0 TO WS-CX
     MOVE 0 TO WS-CZ
     CALL "STRUCT-IS-CHUNK" USING WS-SET WS-SEED WS-CX WS-CZ WS-FLAG
     MOVE "acceptance US12 36-1§4 Placement engines: dimension_origin: the origin chunk (0,0) is the one chunk" TO TL-CASE
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-CX
     CALL "STRUCT-IS-CHUNK" USING WS-SET WS-SEED WS-CX WS-CZ WS-FLAG
     MOVE "acceptance US12 36-1§4 Placement engines: no other chunk is" TO TL-CASE
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-SET
     MOVE 19 TO WS-CX
     MOVE 16 TO WS-CZ
     CALL "STRUCT-LOCATE-POS" USING WS-SET WS-CX WS-CZ WS-X WS-Y WS-Z
     MOVE "acceptance US12 36-1§4 Placement engines: locate position is the chunk's minimum corner at y 0 plus the offset (308, 0, 252)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-X * 1000000 + WS-Y * 1000 + WS-Z
     MOVE 308000252 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-SET
     MOVE -2 TO WS-CX
     MOVE 3 TO WS-CZ
     CALL "STRUCT-LOCATE-POS" USING WS-SET WS-CX WS-CZ WS-X WS-Y WS-Z
     MOVE "acceptance US12 36-1§4 Placement engines: dimension_origin has the zero offset (-32, 0, 48)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-X * 1000000 + WS-Y * 1000 + WS-Z
     MOVE -31999952 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 POTENTIAL-ROW.
     MOVE 0 TO WS-CX
     MOVE 0 TO WS-CZ
     PERFORM POTENTIAL-ONE
     MOVE 5 TO WS-CX
     MOVE 7 TO WS-CZ
     PERFORM POTENTIAL-ONE
     MOVE -1 TO WS-CX
     MOVE -1 TO WS-CZ
     PERFORM POTENTIAL-ONE
     MOVE 40 TO WS-CX
     MOVE -33 TO WS-CZ
     PERFORM POTENTIAL-ONE.
 POTENTIAL-ONE.
     CALL "STRUCT-POTENTIAL" USING WS-SET WS-SEED WS-CX WS-CZ WS-PX WS-PZ
     MOVE WS-PX TO WS-EDIT-A
     MOVE WS-PZ TO WS-EDIT-B
     STRING FUNCTION TRIM(WS-EDIT-A) "," FUNCTION TRIM(WS-EDIT-B) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR.
 FREQ-SQUARE.
     MOVE 0 TO WS-COUNT
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-CX FROM 0 BY 1 UNTIL WS-CX > 15
         PERFORM VARYING WS-CZ FROM 0 BY 1 UNTIL WS-CZ > 15
             CALL "STRUCT-FREQ-OK" USING WS-SET WS-SEED WS-CX WS-CZ WS-FLAG
             IF WS-FLAG = 1
                 ADD 1 TO WS-COUNT
                 COMPUTE WS-SUM = WS-SUM + WS-CX * 1000 + WS-CZ
             END-IF
         END-PERFORM
     END-PERFORM.
 TRI-AREA.
     MOVE 0 TO WS-COUNT
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-CX FROM -48 BY 1 UNTIL WS-CX > 47
         PERFORM VARYING WS-CZ FROM -48 BY 1 UNTIL WS-CZ > 47
             CALL "STRUCT-IS-CHUNK" USING WS-SET WS-SEED WS-CX WS-CZ WS-FLAG
             IF WS-FLAG = 1
                 ADD 1 TO WS-COUNT
                 COMPUTE WS-SUM = WS-SUM + WS-CX * 1000 + WS-CZ
             END-IF
         END-PERFORM
     END-PERFORM.
 ADD-POINT.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE -10000 TO WS-MIN(WS-I)
         MOVE 10000 TO WS-MAX(WS-I)
     END-PERFORM
     MOVE 0 TO WS-OFFSET
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET.
 RING-LIST.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SR-N(SS-RING-ROW(WS-SET))
         MOVE SR-X(SS-RING-ROW(WS-SET), WS-I) TO WS-EDIT-A
         MOVE SR-Z(SS-RING-ROW(WS-SET), WS-I) TO WS-EDIT-B
         STRING FUNCTION TRIM(WS-EDIT-A) "," FUNCTION TRIM(WS-EDIT-B) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-PERFORM.
