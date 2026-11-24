*> Implementation test (core/src/end-38d.cob; docs/protocol/38-end.md section 10, End city hooks): the structure set end_cities (spacing 20, separation 11, salt 10387313, triangular spread), the potential chunk of a cell by the random_spread rule of 36-1 section 4.3 (checked on its worked example with spacing 32, separation 8, salt 12345: linear (19, 16), triangular (17, 10), (-22, -26), (42, -53)), and the biomes that allow a city (end_highlands, end_midlands).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-END-38-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 01 WS-SKIP                BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-WANT                BINARY-DOUBLE.
 01 WS-GOT                 BINARY-DOUBLE.
 01 WS-DIFF                BINARY-DOUBLE.
 01 WS-TOL                 BINARY-LONG VALUE 20.
 01 WS-DIM                 BINARY-LONG.
 01 WS-DROPPED             BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-F1                  FLOAT-LONG.
 01 WS-F2                  FLOAT-LONG.
 01 WS-SEED                BINARY-DOUBLE SIGNED VALUE 0.
 01 WS-X1                 BINARY-LONG.
 01 WS-Z1                 BINARY-LONG.
 01 WS-WANT1              BINARY-LONG.
 01 WS-WANT2              BINARY-LONG.
 01 WS-R2                 BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-VAL                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 32 TO WS-A
     MOVE 8 TO WS-B
     MOVE 12345 TO WS-D
     MOVE 0 TO WS-E
     MOVE 0 TO WS-P
     MOVE 0 TO WS-C
     CALL "END-SPREAD-CANDIDATE" USING WS-SEED WS-A WS-B WS-D WS-E WS-P WS-C WS-X1 WS-Z1 WS-R
     MOVE "acceptance US12 38§10 End city hooks linear cell (0, 0) x" TO TL-CASE
     MOVE 19 TO TL-EXPECTED-N
     MOVE WS-X1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§10 End city hooks linear cell (0, 0) z" TO TL-CASE
     MOVE 16 TO TL-EXPECTED-N
     MOVE WS-Z1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§10 End city hooks linear cell (0, 0) flag" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 32 TO WS-A
     MOVE 8 TO WS-B
     MOVE 12345 TO WS-D
     MOVE 0 TO WS-E
     MOVE 19 TO WS-P
     MOVE 16 TO WS-C
     CALL "END-SPREAD-CANDIDATE" USING WS-SEED WS-A WS-B WS-D WS-E WS-P WS-C WS-X1 WS-Z1 WS-R
     MOVE "acceptance US12 38§10 End city hooks linear chunk (19, 16) x" TO TL-CASE
     MOVE 19 TO TL-EXPECTED-N
     MOVE WS-X1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§10 End city hooks linear chunk (19, 16) z" TO TL-CASE
     MOVE 16 TO TL-EXPECTED-N
     MOVE WS-Z1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§10 End city hooks linear chunk (19, 16) flag" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 32 TO WS-A
     MOVE 8 TO WS-B
     MOVE 12345 TO WS-D
     MOVE 1 TO WS-E
     MOVE 0 TO WS-P
     MOVE 0 TO WS-C
     CALL "END-SPREAD-CANDIDATE" USING WS-SEED WS-A WS-B WS-D WS-E WS-P WS-C WS-X1 WS-Z1 WS-R
     MOVE "acceptance US12 38§10 End city hooks triangular cell (0, 0) x" TO TL-CASE
     MOVE 17 TO TL-EXPECTED-N
     MOVE WS-X1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§10 End city hooks triangular cell (0, 0) z" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-Z1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§10 End city hooks triangular cell (0, 0) flag" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 32 TO WS-A
     MOVE 8 TO WS-B
     MOVE 12345 TO WS-D
     MOVE 1 TO WS-E
     MOVE -1 TO WS-P
     MOVE -1 TO WS-C
     CALL "END-SPREAD-CANDIDATE" USING WS-SEED WS-A WS-B WS-D WS-E WS-P WS-C WS-X1 WS-Z1 WS-R
     MOVE "acceptance US12 38§10 End city hooks triangular cell (-1, -1) x" TO TL-CASE
     MOVE -22 TO TL-EXPECTED-N
     MOVE WS-X1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§10 End city hooks triangular cell (-1, -1) z" TO TL-CASE
     MOVE -26 TO TL-EXPECTED-N
     MOVE WS-Z1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§10 End city hooks triangular cell (-1, -1) flag" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 32 TO WS-A
     MOVE 8 TO WS-B
     MOVE 12345 TO WS-D
     MOVE 1 TO WS-E
     MOVE 40 TO WS-P
     MOVE -33 TO WS-C
     CALL "END-SPREAD-CANDIDATE" USING WS-SEED WS-A WS-B WS-D WS-E WS-P WS-C WS-X1 WS-Z1 WS-R
     MOVE "acceptance US12 38§10 End city hooks triangular cell (1, -2) x" TO TL-CASE
     MOVE 42 TO TL-EXPECTED-N
     MOVE WS-X1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§10 End city hooks triangular cell (1, -2) z" TO TL-CASE
     MOVE -53 TO TL-EXPECTED-N
     MOVE WS-Z1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§10 End city hooks triangular cell (1, -2) flag" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "city-spacing" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VAL
     MOVE "acceptance US12 38§10 End city hooks city-spacing" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WS-VAL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "city-separation" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VAL
     MOVE "acceptance US12 38§10 End city hooks city-separation" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE WS-VAL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "city-salt" TO WS-NAME
     CALL "END-CONST" USING WS-NAME WS-VAL
     MOVE "acceptance US12 38§10 End city hooks city-salt" TO TL-CASE
     MOVE 10387313 TO TL-EXPECTED-N
     MOVE WS-VAL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1 TO WS-SEED
     MOVE 32 TO WS-A
     MOVE 8 TO WS-B
     MOVE 12345 TO WS-D
     MOVE 1 TO WS-E
     MOVE 0 TO WS-P
     MOVE 0 TO WS-C
     CALL "END-SPREAD-CANDIDATE" USING WS-SEED WS-A WS-B WS-D WS-E WS-P WS-C WS-X1 WS-Z1 WS-R
     MOVE "acceptance US12 38§10 End city hooks seed -1 gives a candidate inside the cell" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-X1 >= 0 AND WS-X1 < 24 AND WS-Z1 >= 0 AND WS-Z1 < 24
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-SEED
     MOVE 20 TO WS-A
     MOVE 11 TO WS-B
     MOVE 10387313 TO WS-D
     MOVE 1 TO WS-E
     MOVE 0 TO WS-P
     MOVE 0 TO WS-C
     CALL "END-CITY-CANDIDATE" USING WS-SEED WS-P WS-C WS-X1 WS-Z1 WS-R
     CALL "END-SPREAD-CANDIDATE" USING WS-SEED WS-A WS-B WS-D WS-E WS-P WS-C WS-WANT1 WS-WANT2 WS-R2
     MOVE "acceptance US12 38§10 End city hooks END-CITY-CANDIDATE is the set's own spread (x)" TO TL-CASE
     MOVE WS-WANT1 TO TL-EXPECTED-N
     MOVE WS-X1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§10 End city hooks END-CITY-CANDIDATE is the set's own spread (z)" TO TL-CASE
     MOVE WS-WANT2 TO TL-EXPECTED-N
     MOVE WS-Z1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     CALL "END-CITY-BIOME" USING WS-A WS-R
     MOVE "acceptance US12 38§10 End city hooks biome the_end allows a city: 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     CALL "END-CITY-BIOME" USING WS-A WS-R
     MOVE "acceptance US12 38§10 End city hooks biome end_highlands allows a city: 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     CALL "END-CITY-BIOME" USING WS-A WS-R
     MOVE "acceptance US12 38§10 End city hooks biome end_midlands allows a city: 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     CALL "END-CITY-BIOME" USING WS-A WS-R
     MOVE "acceptance US12 38§10 End city hooks biome small_end_islands allows a city: 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     CALL "END-CITY-BIOME" USING WS-A WS-R
     MOVE "acceptance US12 38§10 End city hooks biome end_barrens allows a city: 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 END PROGRAM TEST-END-38-10.
