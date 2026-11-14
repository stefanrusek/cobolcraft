*> Implementation test of the Nether's feature order and layer scan (core/src/nether-37-5.cob NETHER-FEATURE-ROW, feat-35-1.cob F351-FLOOR-OF-LAYER; T1693 to T1694, T1697 to T1698;
*> docs/protocol/37-nether-5 sections 3, 5 and 8): rows per step 1, 3, 23, 10; the seed offsets index + 10000 * step; glowstone_extra index 6 and glowstone index 7; the features a
*> crimson-forest-only chunk runs, in order (the worked example of section 3); ore_magma at 70011 and delta at 40000 for basalt_deltas; and the worked column of section 5:
*> bedrock 127, air 100..126, netherrack 95..99, lava 33..94, netherrack 0..32: layer 0 emits y 100, layer 1 emits y 33, layer 2 none.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-5-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-OFFSET              BINARY-LONG.
 01 WS-KEY                 PIC X(26).
 01 WS-BIOMES              PIC X(5).
 01 WS-K                   BINARY-LONG.
 01 WS-C2                  BINARY-LONG.
 01 WS-C4                  BINARY-LONG.
 01 WS-C7                  BINARY-LONG.
 01 WS-C9                  BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-ED                  PIC Z9.
 01 WS-ED2                 PIC Z(8)9.
 01 WS-COLUMN.
    05 WS-CLASS            BINARY-LONG OCCURS 512 TIMES.
 01 WS-MIN                 BINARY-LONG VALUE 0.
 01 WS-START               BINARY-LONG VALUE 128.
 01 WS-TARGET              BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-RES                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-C2 WS-C4 WS-C7 WS-C9 WS-BAD
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > 37
         CALL "NETHER-FEATURE-ROW" USING WS-ROW WS-STEP WS-INDEX WS-OFFSET WS-KEY WS-BIOMES
         EVALUATE WS-STEP
             WHEN 2
                 ADD 1 TO WS-C2
             WHEN 4
                 ADD 1 TO WS-C4
             WHEN 7
                 ADD 1 TO WS-C7
             WHEN 9
                 ADD 1 TO WS-C9
         END-EVALUATE
         IF WS-OFFSET NOT = WS-INDEX + 10000 * WS-STEP
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12-core 37-5§8 rows per step 2, 4, 7, 9: 1, 3, 23, 10" TO TL-CASE
     MOVE 1302310 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-C2 * 1000000 + WS-C4 * 100000 + WS-C7 * 100 + WS-C9
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-core 37-5§3 every seed offset is index + 10000 * step" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the order table: row 3 is step 4 index 2; row 4 is step 7 index 0 ... : first row of each step and the last
     MOVE 1 TO WS-ROW
     PERFORM ROW-TEXT
     MOVE "acceptance US12-core 37-5§3 row 1: step 2 index 0 basalt_pillar, offset 20000, biome S" TO TL-CASE
     MOVE "2 0 20000 basalt_pillar .S..." TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-ROW
     PERFORM ROW-TEXT
     MOVE "acceptance US12-core 37-5§3 row 5: step 7 index 0 basalt_blobs, offset 70000, biome D" TO TL-CASE
     MOVE "7 0 70000 basalt_blobs ....D" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 11 TO WS-ROW
     PERFORM ROW-TEXT
     MOVE "acceptance US12-core 37-5§3 row 11: glowstone_extra index 6 offset 70006, all five biomes" TO TL-CASE
     MOVE "7 6 70006 glowstone_extra WSCPD" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12 TO WS-ROW
     PERFORM ROW-TEXT
     MOVE "acceptance US12-core 37-5§8 row 12: glowstone index 7 offset 70007" TO TL-CASE
     MOVE "7 7 70007 glowstone WSCPD" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 16 TO WS-ROW
     PERFORM ROW-TEXT
     MOVE "acceptance US12-core 37-5§3 ore_magma index 11 offset 70011 (row 16), all biomes" TO TL-CASE
     MOVE "7 11 70011 ore_magma WSCPD" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-ROW
     PERFORM ROW-TEXT
     MOVE "acceptance US12-core 37-5§3 delta index 0 offset 40000, basalt_deltas" TO TL-CASE
     MOVE "4 0 40000 delta ....D" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 37 TO WS-ROW
     PERFORM ROW-TEXT
     MOVE "acceptance US12-core 37-5§3 last row: crimson_forest_vegetation index 9 offset 90009, biome C" TO TL-CASE
     MOVE "9 9 90009 crimson_forest_vegetation ..C.." TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the worked example: a crimson-forest-only chunk runs step 7 indices 3, 4, 6, 7, 11, 15, 17 to 22 and step 9 indices 0, 1, 2, 7, 8, 9
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-K
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > 37
         CALL "NETHER-FEATURE-ROW" USING WS-ROW WS-STEP WS-INDEX WS-OFFSET WS-KEY WS-BIOMES
         IF WS-BIOMES(3:1) NOT = "."
             MOVE WS-STEP TO WS-ED
             STRING FUNCTION TRIM(WS-ED) "/" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-K
             MOVE WS-INDEX TO WS-ED
             STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-K
         END-IF
     END-PERFORM
     MOVE "acceptance US12-core 37-5§3 a crimson-forest-only chunk runs step/index: 7/3 .. 7/22, 9/0 .. 9/9 as in the worked example" TO TL-CASE
     MOVE "7/3 7/4 7/6 7/7 7/11 7/15 7/17 7/18 7/19 7/20 7/21 7/22 9/0 9/1 9/2 9/7 9/8 9/9" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     PERFORM LAYERS
     GOBACK.

 ROW-TEXT.
     CALL "NETHER-FEATURE-ROW" USING WS-ROW WS-STEP WS-INDEX WS-OFFSET WS-KEY WS-BIOMES
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-K
     MOVE WS-STEP TO WS-ED
     STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-K
     MOVE WS-INDEX TO WS-ED
     STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-K
     MOVE WS-OFFSET TO WS-ED2
     STRING FUNCTION TRIM(WS-ED2) " " FUNCTION TRIM(WS-KEY) " " WS-BIOMES DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-K.

 LAYERS.
*>   classes by y from 0: 0 solid, 1 air, 2 water or lava, 3 bedrock (a cell above y 127 is air)
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 255
         EVALUATE TRUE
             WHEN WS-Y = 127
                 MOVE 3 TO WS-CLASS(WS-Y + 1)
             WHEN WS-Y > 127
                 MOVE 1 TO WS-CLASS(WS-Y + 1)
             WHEN WS-Y >= 100
                 MOVE 1 TO WS-CLASS(WS-Y + 1)
             WHEN WS-Y >= 95
                 MOVE 0 TO WS-CLASS(WS-Y + 1)
             WHEN WS-Y >= 33
                 MOVE 2 TO WS-CLASS(WS-Y + 1)
             WHEN OTHER
                 MOVE 0 TO WS-CLASS(WS-Y + 1)
         END-EVALUATE
     END-PERFORM
     MOVE 0 TO WS-TARGET
     CALL "F351-FLOOR-OF-LAYER" USING WS-COLUMN WS-MIN WS-START WS-TARGET WS-RES
     MOVE WS-RES TO TL-OBSERVED-N
     MOVE "acceptance US12-core 37-5§5 layer 0 of the worked column: y 100 (the roof bedrock is never a floor)" TO TL-CASE
     MOVE 100 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-TARGET
     CALL "F351-FLOOR-OF-LAYER" USING WS-COLUMN WS-MIN WS-START WS-TARGET WS-RES
     MOVE WS-RES TO TL-OBSERVED-N
     MOVE "acceptance US12-core 37-5§5 layer 1 of the worked column: y 33 (lava counts as empty, the floor under the lava)" TO TL-CASE
     MOVE 33 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-TARGET
     CALL "F351-FLOOR-OF-LAYER" USING WS-COLUMN WS-MIN WS-START WS-TARGET WS-RES
     MOVE WS-RES TO TL-OBSERVED-N
     MOVE "acceptance US12-core 37-5§5 layer 2 of the worked column: none (min y - 1)" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-NETHER-37-5-3.
