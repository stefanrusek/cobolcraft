*> Acceptance test of docs/protocol/43-tint-sources.md section 3 (colormaps and the biome colour of one
*> position): the lookup 3.1 with the worked cases of section 11 (a marker pixel stands at each
*> (x, y) of the table), the defaults, the biome rules 3.2 with the clamping of climate values, and
*> the grass colour modifiers 3.3 (V1, V2 and the simplex noise values of an independent
*> reference).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TINT-43-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLTINT.
 COPY TESTLIB.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              PIC X(8).
 01 WS-COLOUR              BINARY-DOUBLE.
 01 WS-RESOLVER            BINARY-LONG.
 01 WS-BIOME               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-MAP                 BINARY-LONG.
 01 WS-T                   COMP-2.
 01 WS-D                   COMP-2.
 01 WS-U                   COMP-2.
 01 WS-V                   COMP-2.
 01 WS-N                   COMP-2.
 01 WS-DIFF                COMP-2.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-DB                  PIC 9.
 01 WS-ROWTAB              PIC X(64) VALUE "FFAD3200FF704C00FF473200FFCBBF00"
     & "FFFFFF00FF240C00FFFF0000FF7F7F00".
 01 WS-ROWS-R REDEFINES WS-ROWTAB.
    05 WS-ROWS             PIC X(8) OCCURS 8 TIMES.
 PROCEDURE DIVISION.
*>   3.1: before any pack is loaded the arrays are zero, so every lookup gives colour 0.
     MOVE 0.5 TO WS-T
     MOVE 0.5 TO WS-D
     MOVE 1 TO WS-MAP
     CALL "TINT-COLORMAP" USING WS-MAP WS-T WS-D WS-COLOUR
     MOVE "acceptance US11 43§3 Colormaps and the biome colour of one position: no pack is colour 0"
         TO WS-CASE
     MOVE "00000000" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
*>   Marker pixels: the colour of pixel (x, y) is FF, y, x, 00 in the three maps (alpha, r = y, g = x).
     PERFORM VARYING WS-ROW FROM 0 BY 1 UNTIL WS-ROW > 255
         PERFORM VARYING WS-COL FROM 0 BY 1 UNTIL WS-COL > 255
             COMPUTE WS-INDEX = WS-ROW * 256 + WS-COL + 1
             COMPUTE TT-MAP-GRASS(WS-INDEX) = 4278190080 + WS-ROW * 65536 + WS-COL * 256
             COMPUTE TT-MAP-FOLIAGE(WS-INDEX) = 4278190080 + WS-ROW * 65536 + WS-COL * 256 + 1
             COMPUTE TT-MAP-DRY(WS-INDEX) = 4278190080 + WS-ROW * 65536 + WS-COL * 256 + 2
         END-PERFORM
     END-PERFORM
*>   Section 11 table, one row per case, through the biome table (float climate values).
     MOVE 16 TO TT-BIOMES
     PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > 16
         MOVE 4282955032 TO TB-WATER(WS-INDEX)
         MOVE -1 TO TB-GRASS(WS-INDEX) TB-FOLIAGE(WS-INDEX) TB-DRY(WS-INDEX)
         MOVE 0 TO TB-MOD(WS-INDEX)
     END-PERFORM
     MOVE 0.8 TO TB-TEMP(1)
     MOVE 0.4 TO TB-DOWN(1)
     MOVE 0.7 TO TB-TEMP(2)
     MOVE 0.8 TO TB-DOWN(2)
     MOVE 0.8 TO TB-TEMP(3)
     MOVE 0.9 TO TB-DOWN(3)
     MOVE 0.25 TO TB-TEMP(4)
     MOVE 0.8 TO TB-DOWN(4)
     MOVE 0.0 TO TB-TEMP(5)
     MOVE 0.5 TO TB-DOWN(5)
     MOVE 0.95 TO TB-TEMP(6)
     MOVE 0.9 TO TB-DOWN(6)
     MOVE 2.0 TO TB-TEMP(7)
     MOVE 0.0 TO TB-DOWN(7)
     MOVE 0.5 TO TB-TEMP(8)
     MOVE 1.0 TO TB-DOWN(8)
     MOVE 1 TO WS-RESOLVER
     PERFORM VARYING WS-BIOME FROM 0 BY 1 UNTIL WS-BIOME > 7
         PERFORM CHECK-GRASS
     END-PERFORM
     MOVE 0 TO WS-BIOME
*>   Foliage and dry foliage read their own maps.
     MOVE 2 TO WS-RESOLVER
     MOVE 0 TO WS-BIOME
     CALL "TINT-BIOME-COLOR" USING WS-RESOLVER WS-BIOME WS-X WS-Z WS-COLOUR
     MOVE "acceptance US11 43§3 Colormaps and the biome colour of one position: plains foliage pixel"
         TO WS-CASE
     MOVE "FFAD3201" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE 3 TO WS-RESOLVER
     CALL "TINT-BIOME-COLOR" USING WS-RESOLVER WS-BIOME WS-X WS-Z WS-COLOUR
     MOVE "acceptance US11 43§3 Colormaps and the biome colour of one position: plains dry pixel"
         TO WS-CASE
     MOVE "FFAD3202" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
*>   The foliage and dry foliage overrides replace the lookup; the water colour is the biome field.
     MOVE 4282955032 TO TB-FOLIAGE(1)
     MOVE 4284234802 TO TB-DRY(1)
     MOVE 2 TO WS-RESOLVER
     CALL "TINT-BIOME-COLOR" USING WS-RESOLVER WS-BIOME WS-X WS-Z WS-COLOUR
     MOVE "acceptance US11 43§3 Colormaps and the biome colour of one position: foliage override"
         TO WS-CASE
     MOVE "FF48B518" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE 3 TO WS-RESOLVER
     CALL "TINT-BIOME-COLOR" USING WS-RESOLVER WS-BIOME WS-X WS-Z WS-COLOUR
     MOVE "acceptance US11 43§3 Colormaps and the biome colour of one position: dry override"
         TO WS-CASE
     MOVE "FF5C3C32" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE 4 TO WS-RESOLVER
     MOVE 4282955032 TO TB-WATER(1)
     CALL "TINT-BIOME-COLOR" USING WS-RESOLVER WS-BIOME WS-X WS-Z WS-COLOUR
     MOVE "acceptance US11 43§3 Colormaps and the biome colour of one position: water colour"
         TO WS-CASE
     MOVE "FF48B518" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
*>   Clamping: temperature -0.7 acts as 0.0 and 2.0 as 1.0.
     MOVE -0.7 TO TB-TEMP(9)
     MOVE 0.9 TO TB-DOWN(9)
     MOVE -1 TO TB-GRASS(9)
     MOVE 1 TO WS-RESOLVER
     MOVE 8 TO WS-BIOME
     MOVE 0 TO TB-MOD(9)
     CALL "TINT-BIOME-COLOR" USING WS-RESOLVER WS-BIOME WS-X WS-Z WS-COLOUR
     MOVE "acceptance US11 43§3 Colormaps and the biome colour of one position: -0.7 clamps to 0"
         TO WS-CASE
     MOVE "FFFFFF00" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE 0.5 TO TB-TEMP(9)
     MOVE 2.0 TO TB-DOWN(9)
     CALL "TINT-BIOME-COLOR" USING WS-RESOLVER WS-BIOME WS-X WS-Z WS-COLOUR
     MOVE "acceptance US11 43§3 Colormaps and the biome colour of one position: downfall 2 clamps to 1"
         TO WS-CASE
     MOVE "FF7F7F00" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
*>   The grass override is the base colour.
     MOVE 4287660365 TO TB-GRASS(9)
     CALL "TINT-BIOME-COLOR" USING WS-RESOLVER WS-BIOME WS-X WS-Z WS-COLOUR
     MOVE "acceptance US11 43§3 Colormaps and the biome colour of one position: grass override"
         TO WS-CASE
     MOVE "FF90814D" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
*>   A negative downfall clamps to 0.
     MOVE -0.5 TO TB-DOWN(9)
     MOVE -1 TO TB-GRASS(9)
     MOVE 0 TO TB-MOD(9)
     MOVE 0.5 TO TB-TEMP(9)
     MOVE 1 TO WS-RESOLVER
     MOVE 8 TO WS-BIOME
     CALL "TINT-BIOME-COLOR" USING WS-RESOLVER WS-BIOME WS-X WS-Z WS-COLOUR
     MOVE "acceptance US11 43§3 Colormaps and the biome colour of one position: negative downfall clamps to 0"
         TO WS-CASE
     MOVE "FFFF7F00" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
*>   Defaults when the index is out of range: temperature -1 gives x = 510 on the last row.
     MOVE -1.0 TO WS-T
     MOVE 0.0 TO WS-D
     MOVE 1 TO WS-MAP
     CALL "TINT-COLORMAP" USING WS-MAP WS-T WS-D WS-COLOUR
     MOVE "acceptance US11 43§3 Colormaps and the biome colour of one position: grass default"
         TO WS-CASE
     MOVE "FFFF00FF" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE 2 TO WS-MAP
     CALL "TINT-COLORMAP" USING WS-MAP WS-T WS-D WS-COLOUR
     MOVE "acceptance US11 43§3 Colormaps and the biome colour of one position: foliage default"
         TO WS-CASE
     MOVE "FF48B518" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE 3 TO WS-MAP
     CALL "TINT-COLORMAP" USING WS-MAP WS-T WS-D WS-COLOUR
     MOVE "acceptance US11 43§3 Colormaps and the biome colour of one position: dry default"
         TO WS-CASE
     MOVE "FF5C3C32" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
*>   3.3 dark_forest, V1: base 79C05A gives FF507A32 (alpha forced to 255).
     MOVE 4286169178 TO TB-GRASS(10)
     MOVE 0.7 TO TB-TEMP(10)
     MOVE 0.8 TO TB-DOWN(10)
     MOVE 1 TO TB-MOD(10)
     MOVE 1 TO WS-RESOLVER
     MOVE 9 TO WS-BIOME
     CALL "TINT-BIOME-COLOR" USING WS-RESOLVER WS-BIOME WS-X WS-Z WS-COLOUR
     MOVE "acceptance US11 43§3 Colormaps and the biome colour of one position: V1 dark forest"
         TO WS-CASE
     MOVE "FF507A32" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
*>   3.3 swamp: the noise value of the column picks the colour whatever the base is.
     MOVE 2 TO TB-MOD(10)
     MOVE 33 TO WS-X
     MOVE 17 TO WS-Z
     CALL "TINT-BIOME-COLOR" USING WS-RESOLVER WS-BIOME WS-X WS-Z WS-COLOUR
     MOVE "acceptance US11 43§3 Colormaps and the biome colour of one position: V2 swamp noise low"
         TO WS-CASE
     MOVE "FF4C763C" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE 10 TO WS-X
     MOVE 10 TO WS-Z
     CALL "TINT-BIOME-COLOR" USING WS-RESOLVER WS-BIOME WS-X WS-Z WS-COLOUR
     MOVE "acceptance US11 43§3 Colormaps and the biome colour of one position: V2 swamp noise high"
         TO WS-CASE
     MOVE "FF6A7039" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
     MOVE -1 TO WS-X
     MOVE -1 TO WS-Z
     CALL "TINT-BIOME-COLOR" USING WS-RESOLVER WS-BIOME WS-X WS-Z WS-COLOUR
     MOVE "acceptance US11 43§3 Colormaps and the biome colour of one position: noise -0.0976 is not below -0.1"
         TO WS-CASE
     MOVE "FF6A7039" TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR
*>   The noise itself against the independent reference (simplex_ref.py), 1e-5.
     MOVE 33 TO WS-X
     MOVE 17 TO WS-Z
     MOVE 0.7425 TO WS-U
     MOVE 0.3825 TO WS-V
     CALL "TINT-SIMPLEX" USING WS-U WS-V WS-N
     MOVE -0.4953472912311554 TO WS-V
     PERFORM CHECK-NOISE
     MOVE 1.44 TO WS-U
     MOVE 1.44 TO WS-V
     CALL "TINT-SIMPLEX" USING WS-U WS-V WS-N
     MOVE -0.4989446699619293 TO WS-V
     PERFORM CHECK-NOISE
     MOVE 0.225 TO WS-U
     MOVE 0.225 TO WS-V
     CALL "TINT-SIMPLEX" USING WS-U WS-V WS-N
     MOVE 0.2991925776004791 TO WS-V
     PERFORM CHECK-NOISE
     MOVE 1.125 TO WS-U
     MOVE 0.45 TO WS-V
     CALL "TINT-SIMPLEX" USING WS-U WS-V WS-N
     MOVE -0.6134949922561646 TO WS-V
     PERFORM CHECK-NOISE
     MOVE 0.27 TO WS-U
     MOVE 2.2275 TO WS-V
     CALL "TINT-SIMPLEX" USING WS-U WS-V WS-N
     MOVE 0.2737693786621094 TO WS-V
     PERFORM CHECK-NOISE
     MOVE 0 TO WS-U
     MOVE 0 TO WS-V
     CALL "TINT-SIMPLEX" USING WS-U WS-V WS-N
     MOVE 0 TO WS-V
     PERFORM CHECK-NOISE
     STOP RUN.

*> Grass of the biome WS-BIOME against the marker pixel named by the case table of section 11.
 CHECK-GRASS.
     CALL "TINT-BIOME-COLOR" USING WS-RESOLVER WS-BIOME WS-X WS-Z WS-COLOUR
     MOVE SPACES TO WS-CASE
     MOVE WS-BIOME TO WS-DB
     STRING "acceptance US11 43§3 Colormaps and the biome colour of one position: section 11 row "
         WS-DB DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-ROWS(WS-BIOME + 1) TO WS-EXPECT
     CALL "TINT-CHECK" USING WS-CASE WS-EXPECT WS-COLOUR.

 CHECK-NOISE.
     COMPUTE WS-DIFF = FUNCTION ABS(WS-N - WS-V)
     MOVE "acceptance US11 43§3 Colormaps and the biome colour of one position: simplex noise matches"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DIFF < 0.00001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-TINT-43-3.
 COPY TINTTEST.
