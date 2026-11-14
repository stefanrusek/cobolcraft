*> Implementation test of the preset minecraft:nether and the nearest-point search (core/src/nether-37-3.cob; T1661 to T1666; docs/protocol/37-nether-3
*> sections 2.2, 4.1 to 4.3 and the worked values 8.2 to 8.5): the five quantised parameter rows, the decision boundaries against nether_wastes,
*> the exact ties (the first point of the tree's sorted order wins), the tie example (3000, -3300) and the climate sampled at the quart cells
*> of the worked examples for seeds 0 and 12345.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-3-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY NETHER.
 01 WS-ROW.
    05 WS-V                BINARY-DOUBLE OCCURS 7 TIMES.
 01 WS-N                   BINARY-LONG.
 01 WS-T                   BINARY-DOUBLE.
 01 WS-H                   BINARY-DOUBLE.
 01 WS-B                   BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-LINE                PIC X(60).
 01 WS-ED                  PIC -(9)9.
 01 WS-ED2                 PIC -(9)9.
 01 WS-ROW-T               BINARY-DOUBLE.
 01 WS-ROW-H               BINARY-DOUBLE.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 5
         CALL "NETHER-PRESET-ROW" USING WS-N WS-ROW
         MOVE SPACES TO TL-CASE
         MOVE WS-N TO WS-ED
         STRING "acceptance US12-core 37-3§2.2 preset row " FUNCTION TRIM(WS-ED) " (T, H, C, E, D, W, offset) quantised"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE SPACES TO TL-EXPECTED TL-OBSERVED
         EVALUATE WS-N
             WHEN 1
                 MOVE "0 0 0 0 0 0 0" TO TL-EXPECTED
             WHEN 2
                 MOVE "0 -5000 0 0 0 0 0" TO TL-EXPECTED
             WHEN 3
                 MOVE "4000 0 0 0 0 0 0" TO TL-EXPECTED
             WHEN 4
                 MOVE "0 5000 0 0 0 0 3750" TO TL-EXPECTED
             WHEN 5
                 MOVE "-5000 0 0 0 0 0 1750" TO TL-EXPECTED
         END-EVALUATE
         MOVE 1 TO WS-B
         PERFORM 7 TIMES
             MOVE WS-V(WS-B) TO WS-ED2
             IF WS-B = 1
                 MOVE FUNCTION TRIM(WS-ED2) TO TL-OBSERVED
             ELSE
                 MOVE SPACES TO WS-LINE
                 STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO WS-LINE
                 MOVE WS-LINE TO TL-OBSERVED
             END-IF
             ADD 1 TO WS-B
         END-PERFORM
         MOVE "T" TO TL-MODE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE "N" TO TL-MODE
     END-PERFORM

*>   boundaries and ties of 4.2, 8.4 and 8.5 (biome numbers: 1 wastes, 2 soul, 3 crimson, 4 warped, 5 basalt)
     MOVE "(0, 0) is nether_wastes" TO WS-LINE
     MOVE 0 TO WS-T
     MOVE 0 TO WS-H
     MOVE 1 TO TL-EXPECTED-N
     PERFORM DO-SEARCH
     MOVE "(0, -2500) ties soul_sand_valley with wastes: wastes" TO WS-LINE
     MOVE 0 TO WS-T
     MOVE -2500 TO WS-H
     MOVE 1 TO TL-EXPECTED-N
     PERFORM DO-SEARCH
     MOVE "(0, -2501) is soul_sand_valley" TO WS-LINE
     MOVE -2501 TO WS-H
     MOVE 2 TO TL-EXPECTED-N
     PERFORM DO-SEARCH
     MOVE "(2000, 0) ties crimson_forest with wastes: wastes" TO WS-LINE
     MOVE 2000 TO WS-T
     MOVE 0 TO WS-H
     MOVE 1 TO TL-EXPECTED-N
     PERFORM DO-SEARCH
     MOVE "(2001, 0) is crimson_forest" TO WS-LINE
     MOVE 2001 TO WS-T
     MOVE 3 TO TL-EXPECTED-N
     PERFORM DO-SEARCH
     MOVE "(0, 3906) is nether_wastes" TO WS-LINE
     MOVE 0 TO WS-T
     MOVE 3906 TO WS-H
     MOVE 1 TO TL-EXPECTED-N
     PERFORM DO-SEARCH
     MOVE "(0, 3907) is warped_forest" TO WS-LINE
     MOVE 3907 TO WS-H
     MOVE 4 TO TL-EXPECTED-N
     PERFORM DO-SEARCH
     MOVE "(-2806, 0) is nether_wastes" TO WS-LINE
     MOVE -2806 TO WS-T
     MOVE 0 TO WS-H
     MOVE 1 TO TL-EXPECTED-N
     PERFORM DO-SEARCH
     MOVE "(-2807, 0) is basalt_deltas" TO WS-LINE
     MOVE -2807 TO WS-T
     MOVE 5 TO TL-EXPECTED-N
     PERFORM DO-SEARCH
     MOVE "(-3000, 0) is basalt_deltas (8.4)" TO WS-LINE
     MOVE -3000 TO WS-T
     MOVE 5 TO TL-EXPECTED-N
     PERFORM DO-SEARCH
     MOVE "(3000, -3300) ties soul and crimson: crimson_forest (V15)" TO WS-LINE
     MOVE 3000 TO WS-T
     MOVE -3300 TO WS-H
     MOVE 3 TO TL-EXPECTED-N
     PERFORM DO-SEARCH
     MOVE "(620, -936) is nether_wastes (8.3)" TO WS-LINE
     MOVE 620 TO WS-T
     MOVE -936 TO WS-H
     MOVE 1 TO TL-EXPECTED-N
     PERFORM DO-SEARCH
     MOVE "(241, 7195) is warped_forest (8.3)" TO WS-LINE
     MOVE 241 TO WS-T
     MOVE 7195 TO WS-H
     MOVE 4 TO TL-EXPECTED-N
     PERFORM DO-SEARCH
     MOVE "(2535, -4985) is soul_sand_valley (8.3)" TO WS-LINE
     MOVE 2535 TO WS-T
     MOVE -4985 TO WS-H
     MOVE 2 TO TL-EXPECTED-N
     PERFORM DO-SEARCH

*>   climate at the quart cells of 8.2 (seed 0) and 8.3 (seed 12345), the biome that wins there
     MOVE 0 TO WS-SEED
     CALL "NETHER-SETUP" USING WS-SEED
     MOVE 0 TO WS-QX WS-QZ
     MOVE "seed 0 quart (0, 0): (1173, -456) nether_wastes" TO WS-LINE
     MOVE 1173 TO WS-T
     MOVE -456 TO WS-H
     MOVE 1 TO TL-EXPECTED-N
     PERFORM DO-CLIMATE
     MOVE 25 TO WS-QX
     MOVE -50 TO WS-QZ
     MOVE "seed 0 quart (25, -50): (-1046, -220) nether_wastes" TO WS-LINE
     MOVE -1046 TO WS-T
     MOVE -220 TO WS-H
     MOVE 1 TO TL-EXPECTED-N
     PERFORM DO-CLIMATE
     MOVE 250 TO WS-QX
     MOVE 250 TO WS-QZ
     MOVE "seed 0 quart (250, 250): (-623, -2383) nether_wastes" TO WS-LINE
     MOVE -623 TO WS-T
     MOVE -2383 TO WS-H
     MOVE 1 TO TL-EXPECTED-N
     PERFORM DO-CLIMATE
     MOVE -84 TO WS-QX
     MOVE 128 TO WS-QZ
     MOVE "seed 0 quart (-84, 128): (-2108, 4453) warped_forest" TO WS-LINE
     MOVE -2108 TO WS-T
     MOVE 4453 TO WS-H
     MOVE 4 TO TL-EXPECTED-N
     PERFORM DO-CLIMATE
     MOVE 12345 TO WS-SEED
     CALL "NETHER-SETUP" USING WS-SEED
     MOVE 25 TO WS-QX
     MOVE -50 TO WS-QZ
     MOVE "seed 12345 quart (25, -50): (241, 7195) warped_forest" TO WS-LINE
     MOVE 241 TO WS-T
     MOVE 7195 TO WS-H
     MOVE 4 TO TL-EXPECTED-N
     PERFORM DO-CLIMATE
     MOVE 250 TO WS-QX
     MOVE 250 TO WS-QZ
     MOVE "seed 12345 quart (250, 250): (2535, -4985) soul_sand_valley" TO WS-LINE
     MOVE 2535 TO WS-T
     MOVE -4985 TO WS-H
     MOVE 2 TO TL-EXPECTED-N
     PERFORM DO-CLIMATE
     MOVE -84 TO WS-QX
     MOVE 128 TO WS-QZ
     MOVE "seed 12345 quart (-84, 128): (-1198, -729) nether_wastes" TO WS-LINE
     MOVE -1198 TO WS-T
     MOVE -729 TO WS-H
     MOVE 1 TO TL-EXPECTED-N
     PERFORM DO-CLIMATE
     GOBACK.

 DO-SEARCH.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12-core 37-3§4 search " FUNCTION TRIM(WS-LINE) DELIMITED BY SIZE INTO TL-CASE
     CALL "NETHER-BIOME-OF" USING WS-T WS-H WS-B
     MOVE WS-B TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 DO-CLIMATE.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12-core 37-3§3 climate " FUNCTION TRIM(WS-LINE) DELIMITED BY SIZE INTO TL-CASE
     CALL "NETHER-CLIMATE-AT" USING WS-QX WS-QZ WS-ROW-T WS-ROW-H
     MOVE "N" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     IF WS-ROW-T = WS-T AND WS-ROW-H = WS-H
         CALL "NETHER-BIOME-OF" USING WS-ROW-T WS-ROW-H WS-B
         MOVE WS-B TO TL-OBSERVED-N
     ELSE
         MOVE -1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-NETHER-37-3-2.
