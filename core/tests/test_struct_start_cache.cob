*> The start list cache of STRUCT-CHUNK-STARTS (docs/design/world-types.md structures part 8, performance): over 48 x 48 chunks of the structure fixtures (the data of
*> test_struct_36_1_5) a second pass is answered from the cache entirely and equals the engine (STRUCT-CHUNK-STARTS-RAW) start for start; another seed, a changed gate, a changed
*> set of possible sets and a reloaded data set are each a miss (a cached answer is never served for a changed epoch), and a chunk that has no start is cached too.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-START-CACHE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTDATA.
 COPY CARVER.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/struct".
 01 WS-CLIMATE-DIR         PIC X(1100) VALUE "core/tests/fixtures/density".
 01 WS-STATUS              BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-RAW                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SUM                 BINARY-DOUBLE.
 01 WS-SUM-RAW             BINARY-DOUBLE.
 01 WS-SUM-FIRST           BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-H0                  BINARY-LONG.
 01 WS-M0                  BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-NAME                PIC X(40).
 01 WS-MINS.
    05 WS-MIN              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MAXS.
    05 WS-MAX              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-OFFSET              BINARY-DOUBLE.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "STRUCT-LOAD" USING WS-DIR WS-STATUS
     CALL "WORLDGEN-FREE"
     CALL "NOISES-LOAD" USING WS-CLIMATE-DIR WS-STATUS
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-CLIMATE-DIR WS-STATUS
     MOVE 0 TO WS-USEED
     CALL "DENSITY-SETUP" USING WS-USEED
     CALL "CLIMATE-POINTS-RESET"
     MOVE "minecraft:plains" TO WS-NAME
     PERFORM ADD-POINT
     CALL "STRUCT-POSSIBLE-BUILD"
     MOVE "minecraft:s_one" TO WS-KEY
     CALL "STRUCT-GATE-ON" USING WS-KEY
     MOVE "minecraft:s_two" TO WS-KEY
     CALL "STRUCT-GATE-ON" USING WS-KEY
     MOVE "minecraft:s_three" TO WS-KEY
     CALL "STRUCT-GATE-ON" USING WS-KEY
     MOVE 0 TO WS-SEED
*>   the first pass makes every answer by the engine
     MOVE SD-CACHE-HITS TO WS-H0
     MOVE SD-CACHE-MISSES TO WS-M0
     PERFORM START-AREA
     MOVE WS-SUM TO WS-SUM-FIRST
     MOVE "test struct start cache given an empty cache when 48 x 48 chunks are asked then every call is a miss" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (SD-CACHE-MISSES - WS-M0) * 1000 + SD-CACHE-HITS - WS-H0
     MOVE 2304000 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the second pass is all hits and the same answers, which are the engine's
     MOVE SD-CACHE-HITS TO WS-H0
     MOVE SD-CACHE-MISSES TO WS-M0
     PERFORM START-AREA
     MOVE "test struct start cache given the chunks asked before when they are asked again then every call is a hit" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (SD-CACHE-MISSES - WS-M0) * 1000 + SD-CACHE-HITS - WS-H0
     MOVE 2304 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct start cache when the starts come from the cache then they equal those of the first pass" TO TL-CASE
     MOVE WS-SUM TO TL-OBSERVED-N
     MOVE WS-SUM-FIRST TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM RAW-AREA
     MOVE "test struct start cache when the starts come from the cache then they equal those of the engine" TO TL-CASE
     MOVE WS-SUM TO TL-OBSERVED-N
     MOVE WS-SUM-RAW TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct start cache when the area has starts then the checksum is not empty" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SUM > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   another seed is another answer
     MOVE 5 TO WS-SEED
     MOVE SD-CACHE-HITS TO WS-H0
     MOVE SD-CACHE-MISSES TO WS-M0
     PERFORM START-AREA
     MOVE WS-SUM TO WS-SUM-FIRST
     PERFORM RAW-AREA
     MOVE "test struct start cache given seed 5 when the same chunks are asked then they are misses and equal the engine" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (SD-CACHE-MISSES - WS-M0) * 1000 + SD-CACHE-HITS - WS-H0
     MOVE 2304000 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct start cache given seed 5 when the starts are made then they equal the engine's" TO TL-CASE
     MOVE WS-SUM-FIRST TO TL-OBSERVED-N
     MOVE WS-SUM-RAW TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a changed gate is a changed epoch: the answers follow the gate
     CALL "STRUCT-GATE-RESET"
     MOVE "minecraft:s_three" TO WS-KEY
     CALL "STRUCT-GATE-ON" USING WS-KEY
     MOVE SD-CACHE-HITS TO WS-H0
     MOVE SD-CACHE-MISSES TO WS-M0
     PERFORM START-AREA
     MOVE WS-SUM TO WS-SUM-FIRST
     PERFORM RAW-AREA
     MOVE "test struct start cache given a changed gate when the chunks are asked again then they are misses" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (SD-CACHE-MISSES - WS-M0) * 1000 + SD-CACHE-HITS - WS-H0
     MOVE 2304000 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct start cache given a changed gate when the starts are made then they equal the engine's" TO TL-CASE
     MOVE WS-SUM-FIRST TO TL-OBSERVED-N
     MOVE WS-SUM-RAW TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a changed biome source and its possible sets are a changed epoch
     CALL "CLIMATE-POINTS-RESET"
     MOVE "minecraft:forest" TO WS-NAME
     PERFORM ADD-POINT
     CALL "STRUCT-POSSIBLE-BUILD"
     MOVE SD-CACHE-HITS TO WS-H0
     MOVE SD-CACHE-MISSES TO WS-M0
     PERFORM START-AREA
     MOVE WS-SUM TO WS-SUM-FIRST
     PERFORM RAW-AREA
     MOVE "test struct start cache given other possible sets when the chunks are asked again then they are misses" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (SD-CACHE-MISSES - WS-M0) * 1000 + SD-CACHE-HITS - WS-H0
     MOVE 2304000 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test struct start cache given other possible sets when the starts are made then they equal the engine's" TO TL-CASE
     MOVE WS-SUM-FIRST TO TL-OBSERVED-N
     MOVE WS-SUM-RAW TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a reloaded data set is a changed epoch
     CALL "STRUCT-LOAD" USING WS-DIR WS-STATUS
     MOVE "minecraft:s_one" TO WS-KEY
     CALL "STRUCT-GATE-ON" USING WS-KEY
     MOVE SD-CACHE-HITS TO WS-H0
     MOVE SD-CACHE-MISSES TO WS-M0
     PERFORM START-AREA
     MOVE "test struct start cache given a reloaded data set when the chunks are asked again then they are misses" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (SD-CACHE-MISSES - WS-M0) * 1000 + SD-CACHE-HITS - WS-H0
     MOVE 2304000 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 START-AREA.
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-CX FROM 0 BY 1 UNTIL WS-CX > 47
         PERFORM VARYING WS-CZ FROM 0 BY 1 UNTIL WS-CZ > 47
             CALL "STRUCT-CHUNK-STARTS" USING WS-SEED WS-CX WS-CZ WS-TOTAL
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-TOTAL
                 COMPUTE WS-SUM = WS-SUM + (WS-CX * 64 + WS-CZ) * 1000000 + SC-SET(WS-I) * 100000 + SC-STRUCT(WS-I) * 10000 + SC-X(WS-I) + SC-Z(WS-I)
             END-PERFORM
         END-PERFORM
     END-PERFORM.
 RAW-AREA.
     MOVE 0 TO WS-SUM-RAW
     PERFORM VARYING WS-CX FROM 0 BY 1 UNTIL WS-CX > 47
         PERFORM VARYING WS-CZ FROM 0 BY 1 UNTIL WS-CZ > 47
             CALL "STRUCT-CHUNK-STARTS-RAW" USING WS-SEED WS-CX WS-CZ WS-TOTAL
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-TOTAL
                 COMPUTE WS-SUM-RAW = WS-SUM-RAW + (WS-CX * 64 + WS-CZ) * 1000000 + SC-SET(WS-I) * 100000 + SC-STRUCT(WS-I) * 10000 + SC-X(WS-I) + SC-Z(WS-I)
             END-PERFORM
         END-PERFORM
     END-PERFORM.
 ADD-POINT.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE -10000 TO WS-MIN(WS-I)
         MOVE 10000 TO WS-MAX(WS-I)
     END-PERFORM
     MOVE 0 TO WS-OFFSET
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET.
 END PROGRAM TEST-STRUCT-START-CACHE.
