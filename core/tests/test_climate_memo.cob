*> Regression test of the memo of CLIMATE-BIOME-AT (core/src/climate.cob; the cost work of the world generation lane): the biome of a quart
*> cell read twice, and after a change of the seed or of the parameter points, equals the uncached sample and lookup
*> (CLIMATE-SAMPLE then CLIMATE-FIND) at every cell of a 8 x 5 x 4 block of cells. Fixture core/tests/fixtures/density (the router
*> functions of test_climate). Two points whose temperature intervals split at 0 give a lookup that depends on the noise of the seed;
*> swapping which of the two carries an offset gives a lookup that depends on the points.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CLIMATE-MEMO.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/density".
 01 WS-STATUS              BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-INDEX-2             BINARY-LONG.
 01 WS-BIOME               PIC X(40).
 01 WS-BIOME-2             PIC X(40).
 01 WS-FITNESS             BINARY-DOUBLE.
 01 WS-TARGET.
    05 WS-T                BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MINS.
    05 WS-MIN              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MAXS.
    05 WS-MAX              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-OFFSET              BINARY-DOUBLE.
 01 WS-NAME                PIC X(40).
 01 WS-I                   BINARY-LONG.
 01 WS-TMIN                BINARY-DOUBLE.
 01 WS-TMAX                BINARY-DOUBLE.
 01 WS-SPLIT               BINARY-DOUBLE.
 01 WS-SEEN-A              BINARY-LONG.
 01 WS-SEEN-B              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "WORLDGEN-FREE"
     CALL "NOISES-LOAD" USING WS-DIR WS-STATUS
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-DIR WS-STATUS
     PERFORM VARYING WS-SEED FROM 0 BY 7 UNTIL WS-SEED > 7
         CALL "DENSITY-SETUP" USING WS-SEED
         PERFORM FIND-SPLIT
         PERFORM SET-POINTS-1
         MOVE 0 TO WS-BAD WS-SEEN-A WS-SEEN-B
         PERFORM VARYING WS-PASS FROM 1 BY 1 UNTIL WS-PASS > 2
             PERFORM CHECK-CELLS
         END-PERFORM
         MOVE "test climate memo the lookup read twice equals the uncached lookup, a seed" TO TL-CASE
         MOVE WS-BAD TO TL-OBSERVED-N
         MOVE 0 TO TL-EXPECTED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE "test climate memo both points are found over the cells (the noise decides)" TO TL-CASE
         IF WS-SEEN-A > 0 AND WS-SEEN-B > 0
             MOVE 1 TO TL-OBSERVED-N
         ELSE
             MOVE 0 TO TL-OBSERVED-N
         END-IF
         MOVE 1 TO TL-EXPECTED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE 0 TO WS-SEED
     CALL "DENSITY-SETUP" USING WS-SEED
     MOVE 0 TO WS-BAD
     PERFORM FIND-SPLIT
     PERFORM SET-POINTS-1
     PERFORM CHECK-CELLS
     CALL "CLIMATE-POINTS-RESET"
     MOVE "minecraft:a" TO WS-NAME
     MOVE 0 TO WS-OFFSET
     PERFORM POINT-A
     MOVE "minecraft:b" TO WS-NAME
     MOVE 1000 TO WS-OFFSET
     PERFORM POINT-ALL
     MOVE 0 TO WS-BAD
     PERFORM CHECK-CELLS
     MOVE "test climate memo after the points change the lookup equals the uncached lookup" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> the cells x 0 to 7 step 3, y 14 to 18 step 1, z -4 to -1 against the uncached lookup
 CHECK-CELLS.
     PERFORM VARYING WS-QX FROM 0 BY 3 UNTIL WS-QX > 21
         PERFORM VARYING WS-QY FROM 14 BY 1 UNTIL WS-QY > 18
             PERFORM VARYING WS-QZ FROM -4 BY 1 UNTIL WS-QZ > -1
                 CALL "CLIMATE-BIOME-AT" USING WS-QX WS-QY WS-QZ WS-INDEX WS-BIOME
                 CALL "CLIMATE-SAMPLE" USING WS-QX WS-QY WS-QZ WS-TARGET
                 CALL "CLIMATE-FIND" USING WS-TARGET WS-INDEX-2 WS-BIOME-2 WS-FITNESS
                 IF WS-INDEX NOT = WS-INDEX-2 OR WS-BIOME NOT = WS-BIOME-2
                     ADD 1 TO WS-BAD
                 END-IF
                 IF WS-INDEX = 1
                     ADD 1 TO WS-SEEN-A
                 ELSE
                     ADD 1 TO WS-SEEN-B
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM.

*> the middle of the temperatures the cells have (the noise of the seed)
 FIND-SPLIT.
     MOVE 100000 TO WS-TMIN
     MOVE -100000 TO WS-TMAX
     PERFORM VARYING WS-QX FROM 0 BY 3 UNTIL WS-QX > 21
         PERFORM VARYING WS-QY FROM 14 BY 1 UNTIL WS-QY > 18
             PERFORM VARYING WS-QZ FROM -4 BY 1 UNTIL WS-QZ > -1
                 CALL "CLIMATE-SAMPLE" USING WS-QX WS-QY WS-QZ WS-TARGET
                 IF WS-T(1) < WS-TMIN
                     MOVE WS-T(1) TO WS-TMIN
                 END-IF
                 IF WS-T(1) > WS-TMAX
                     MOVE WS-T(1) TO WS-TMAX
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE WS-SPLIT = (WS-TMIN + WS-TMAX) / 2.

*> point a: temperature -10000 to the split, point b: above it, point b: temperature 0 to 10000 (the other axes the whole range)
 SET-POINTS-1.
     CALL "CLIMATE-POINTS-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE -10000 TO WS-MIN(WS-I)
         MOVE 10000 TO WS-MAX(WS-I)
     END-PERFORM
     MOVE WS-SPLIT TO WS-MAX(1)
     MOVE 0 TO WS-OFFSET
     MOVE "minecraft:a" TO WS-NAME
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET
     MOVE 10000 TO WS-MAX(1)
     COMPUTE WS-MIN(1) = WS-SPLIT + 1
     MOVE "minecraft:b" TO WS-NAME
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET.

*> point a over the whole range, then the point of WS-NAME over the whole range
 POINT-A.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE -10000 TO WS-MIN(WS-I)
         MOVE 10000 TO WS-MAX(WS-I)
     END-PERFORM
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET.

 POINT-ALL.
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET.
 END PROGRAM TEST-CLIMATE-MEMO.
 COPY CORETEST.
