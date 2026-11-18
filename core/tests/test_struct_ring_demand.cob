*> Implementation test of the ring list snapped on demand (core/src/struct-36-1.cob: STRUCT-RINGS-PREP, STRUCT-RING-READY, STRUCT-RING-HAS, STRUCT-RINGS-ALL): the
*> answers equal those of the whole list built at once (STRUCT-RINGS-BUILD, every position snapped in order). On the fixtures of test_struct_36_1_4 (the set of
*> three ring positions, preferred biome plains) and three biome sources (no plains, plains everywhere, plains and forest by temperature), for four seeds:
*> the whole list is built and kept as the reference; the row is made stale; STRUCT-RING-HAS is asked for every chunk of the 19 x 19 square around each
*> position before its snap (so the chunks at 7, 8 and 9 from it too) and must say 1 exactly for the chunks of the reference; a chunk at 8 from a position
*> snaps nothing and one at 7 snaps that position only; STRUCT-RINGS-ALL after some positions were snapped gives the reference list; STRUCT-NEAREST-RING on a
*> stale row gives the nearest chunk of the reference.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-RING-DEMAND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTDATA.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/struct".
 01 WS-CLIMATE-DIR         PIC X(1100) VALUE "core/tests/fixtures/density".
 01 WS-STATUS              BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-SEEDS.
    05 WS-SEED-OF          BINARY-DOUBLE OCCURS 4 TIMES.
 01 WS-SET                 BINARY-LONG VALUE 6.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-WRONG               BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-REF.
    05 WS-REF-ROW OCCURS 256 TIMES.
       10 WS-REF-X         BINARY-LONG.
       10 WS-REF-Z         BINARY-LONG.
       10 WS-REF-RAW-X     BINARY-LONG.
       10 WS-REF-RAW-Z     BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG VALUE 32.
 01 WS-OZ                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BEST                BINARY-DOUBLE.
 01 WS-D                   BINARY-DOUBLE.
 01 WS-DDX                 BINARY-DOUBLE.
 01 WS-DDZ                 BINARY-DOUBLE.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-MINS.
    05 WS-MIN              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MAXS.
    05 WS-MAX              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-OFFSET              BINARY-DOUBLE.
 01 WS-NAME                PIC X(40).
 01 WS-EDIT-A              PIC -(9)9.
 01 WS-EDIT-B              PIC -(19)9.
 01 WS-LABEL               PIC X(60).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-SEED-OF(1)
     MOVE 12345 TO WS-SEED-OF(2)
     MOVE -7 TO WS-SEED-OF(3)
     MOVE 987654321012 TO WS-SEED-OF(4)
     CALL "STRUCT-LOAD" USING WS-DIR WS-STATUS
     CALL "WORLDGEN-FREE"
     CALL "NOISES-LOAD" USING WS-CLIMATE-DIR WS-STATUS
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-CLIMATE-DIR WS-STATUS
     CALL "DENSITY-SETUP" USING WS-USEED
     PERFORM VARYING WS-SOURCE FROM 1 BY 1 UNTIL WS-SOURCE > 3
         PERFORM SET-SOURCE
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 4
             MOVE WS-SEED-OF(WS-S) TO WS-SEED
             PERFORM CHECK-SEED
         END-PERFORM
     END-PERFORM
     CALL "WORLDGEN-FREE"
     GOBACK.

*> The biome source: 1 forest everywhere (no cell is plains), 2 plains everywhere, 3 plains where the temperature is below 0 and forest elsewhere.
 SET-SOURCE.
     CALL "CLIMATE-POINTS-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE -10000 TO WS-MIN(WS-I)
         MOVE 10000 TO WS-MAX(WS-I)
     END-PERFORM
     MOVE 0 TO WS-OFFSET
     EVALUATE WS-SOURCE
         WHEN 1
             MOVE "minecraft:forest" TO WS-NAME
             CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET
         WHEN 2
             MOVE "minecraft:plains" TO WS-NAME
             CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET
         WHEN OTHER
             MOVE 0 TO WS-MAX(1)
             MOVE "minecraft:plains" TO WS-NAME
             CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET
             MOVE 0 TO WS-MIN(1)
             MOVE 10000 TO WS-MAX(1)
             MOVE "minecraft:forest" TO WS-NAME
             CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET
     END-EVALUATE
     CALL "STRUCT-POSSIBLE-BUILD".

 MAKE-LABEL.
     MOVE WS-SOURCE TO WS-EDIT-A
     MOVE WS-SEED TO WS-EDIT-B
     MOVE SPACES TO WS-LABEL
     STRING "source " FUNCTION TRIM(WS-EDIT-A) " seed " FUNCTION TRIM(WS-EDIT-B) DELIMITED BY SIZE INTO WS-LABEL.

 MAKE-STALE.
     MOVE 0 TO SR-SET(WS-ROW).

 COUNT-DONE.
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-N
         ADD SR-DONE(WS-ROW, WS-J) TO WS-DONE
     END-PERFORM.

 CHECK-SEED.
     PERFORM MAKE-LABEL
*>   the reference: the whole list at once
     CALL "STRUCT-RINGS-BUILD" USING WS-SET WS-SEED
     MOVE SS-RING-ROW(WS-SET) TO WS-ROW
     MOVE SR-N(WS-ROW) TO WS-N
     MOVE 0 TO WS-MOVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         MOVE SR-X(WS-ROW, WS-I) TO WS-REF-X(WS-I)
         MOVE SR-Z(WS-ROW, WS-I) TO WS-REF-Z(WS-I)
         MOVE SR-RAW-X(WS-ROW, WS-I) TO WS-REF-RAW-X(WS-I)
         MOVE SR-RAW-Z(WS-ROW, WS-I) TO WS-REF-RAW-Z(WS-I)
         IF WS-REF-X(WS-I) NOT = WS-REF-RAW-X(WS-I) OR WS-REF-Z(WS-I) NOT = WS-REF-RAW-Z(WS-I)
             ADD 1 TO WS-MOVED
         END-IF
     END-PERFORM
     MOVE SPACES TO TL-CASE
     STRING "ring demand " FUNCTION TRIM(WS-LABEL) ": the set has three ring positions" DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-N TO TL-OBSERVED-N
     MOVE 3 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-SOURCE = 1
         MOVE SPACES TO TL-CASE
     STRING "ring demand " FUNCTION TRIM(WS-LABEL) ": without plains no position moves" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-MOVED TO TL-OBSERVED-N
         MOVE 0 TO TL-EXPECTED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-IF

*>   a stale row asked for a chunk 8 from the first position on x: nothing is snapped; 7 from it: that position only
     PERFORM MAKE-STALE
     COMPUTE WS-CX = WS-REF-RAW-X(1) + 8
     MOVE WS-REF-RAW-Z(1) TO WS-CZ
     CALL "STRUCT-RING-HAS" USING WS-SET WS-SEED WS-CX WS-CZ WS-FLAG
     PERFORM COUNT-DONE
     MOVE SPACES TO TL-CASE
     STRING "ring demand " FUNCTION TRIM(WS-LABEL) ": a chunk 8 from a position snaps nothing" DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-DONE TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-CX = WS-REF-RAW-X(1) + 7
     CALL "STRUCT-RING-HAS" USING WS-SET WS-SEED WS-CX WS-CZ WS-FLAG
     PERFORM COUNT-DONE
     MOVE SPACES TO TL-CASE
     STRING "ring demand " FUNCTION TRIM(WS-LABEL) ": a chunk 7 from a position snaps that position only" DELIMITED BY SIZE INTO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-DONE * 10 + SR-DONE(WS-ROW, 1)
     MOVE 11 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the whole list after one position was snapped on demand
     CALL "STRUCT-RINGS-ALL" USING WS-SET WS-SEED
     PERFORM COMPARE-LIST
     MOVE SPACES TO TL-CASE
     STRING "ring demand " FUNCTION TRIM(WS-LABEL) ": the whole list after a snap on demand is the list built at once" DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-WRONG TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   every chunk of the 19 x 19 square around each position, on a stale row
     PERFORM MAKE-STALE
     MOVE 0 TO WS-WRONG WS-HITS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         PERFORM VARYING WS-DZ FROM -9 BY 1 UNTIL WS-DZ > 9
             PERFORM VARYING WS-DX FROM -9 BY 1 UNTIL WS-DX > 9
                 COMPUTE WS-CX = WS-REF-RAW-X(WS-I) + WS-DX
                 COMPUTE WS-CZ = WS-REF-RAW-Z(WS-I) + WS-DZ
                 MOVE 0 TO WS-WANT
                 PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-N
                     IF WS-REF-X(WS-J) = WS-CX AND WS-REF-Z(WS-J) = WS-CZ
                         MOVE 1 TO WS-WANT
                     END-IF
                 END-PERFORM
                 CALL "STRUCT-RING-HAS" USING WS-SET WS-SEED WS-CX WS-CZ WS-FLAG
                 IF WS-FLAG NOT = WS-WANT
                     ADD 1 TO WS-WRONG
                 END-IF
                 ADD WS-FLAG TO WS-HITS
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE SPACES TO TL-CASE
     STRING "ring demand " FUNCTION TRIM(WS-LABEL) ": every chunk within 9 of a position is answered as by the list built at once" DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-WRONG TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "ring demand " FUNCTION TRIM(WS-LABEL) ": each ring chunk is found once" DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-HITS TO TL-OBSERVED-N
     MOVE WS-N TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM COMPARE-LIST
     MOVE SPACES TO TL-CASE
     STRING "ring demand " FUNCTION TRIM(WS-LABEL) ": the positions snapped on demand are those of the list built at once" DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-WRONG TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the eye of ender on a stale row: the nearest chunk of the reference (the first of equal distances)
     PERFORM MAKE-STALE
     COMPUTE WS-OX = WS-REF-RAW-X(2) * 16 + 100
     COMPUTE WS-OZ = WS-REF-RAW-Z(2) * 16 - 40
     MOVE 0 TO WS-BX WS-BZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         COMPUTE WS-DDX = WS-REF-X(WS-I) * 16 + 8 - WS-OX
         COMPUTE WS-DDZ = WS-REF-Z(WS-I) * 16 + 8 - WS-OZ
         COMPUTE WS-D = WS-DDX * WS-DDX + WS-DDZ * WS-DDZ
         IF WS-I = 1 OR WS-D < WS-BEST
             MOVE WS-D TO WS-BEST
             MOVE WS-REF-X(WS-I) TO WS-BX
             MOVE WS-REF-Z(WS-I) TO WS-BZ
         END-IF
     END-PERFORM
     CALL "STRUCT-NEAREST-RING" USING WS-SET WS-SEED WS-OX WS-OY WS-OZ WS-FOUND WS-CX WS-CZ WS-X WS-Y WS-Z
     MOVE SPACES TO TL-CASE
     STRING "ring demand " FUNCTION TRIM(WS-LABEL) ": the nearest ring chunk on a stale row is the nearest of the list built at once" DELIMITED BY SIZE INTO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-FOUND * 100 + FUNCTION ABS(WS-CX - WS-BX) + FUNCTION ABS(WS-CZ - WS-BZ)
     MOVE 100 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM COUNT-DONE
     MOVE SPACES TO TL-CASE
     STRING "ring demand " FUNCTION TRIM(WS-LABEL) ": the nearest ring chunk had the whole list snapped" DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-DONE TO TL-OBSERVED-N
     MOVE WS-N TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 COMPARE-LIST.
     MOVE 0 TO WS-WRONG
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-N
         IF SR-DONE(WS-ROW, WS-J) = 1
             IF SR-X(WS-ROW, WS-J) NOT = WS-REF-X(WS-J) OR SR-Z(WS-ROW, WS-J) NOT = WS-REF-Z(WS-J)
                 ADD 1 TO WS-WRONG
             END-IF
         END-IF
     END-PERFORM.
 END PROGRAM TEST-STRUCT-RING-DEMAND.
