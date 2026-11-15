*> The Nether's biome source (docs/protocol/37-nether-3; T1659 to T1672): the multi-noise preset minecraft:nether (section 2: five single-point
*> parameter rows), the climate sampled at the quart cell (section 3: the legacy temperature and vegetation noises at the quart coordinates,
*> y scale 0, the other four parameters 0, quantised (long)(v * 10000.0f)), the nearest-point search (section 4: the sum of squared distances
*> plus the offset squared, the first in the tree's sorted order wins a tie), the biome cells of a chunk (section 5.1: independent of y, so
*> one value per column replicated over the 64 cell rows) and the zoomed block lookup the surface pass uses (10 section 7.7).
*> A biome is its number 1 to 5 in the preset's list order: 1 nether_wastes, 2 soul_sand_valley, 3 crimson_forest, 4 warped_forest, 5 basalt_deltas
*> (NH-BIOME-ID(number) is its id in the biome table).
*>
*> Entry points (state in NETHER.cpy):
*>   NETHER-PRESET-ROW USING number (1 to 5), row out (7 BINARY-DOUBLE: T, H, C, E, D, W, offset, quantised)
*>   NETHER-BIOME-OF USING quantised T, quantised H (BINARY-DOUBLE), biome number out
*>   NETHER-CLIMATE-AT USING quart x, quart z (BINARY-LONG), quantised T out, quantised H out (BINARY-DOUBLE)
*>   NETHER-BIOME-GRID USING chunk x, chunk z: NH-RING, the biome numbers of the 6 x 6 quart cells from (4 cx - 1, 4 cz - 1)
*>   NETHER-BIOME-STORE USING chunk memory: the biome cells of the chunk (16 sections)
*>   NETHER-ZOOM USING x, y, z (block), biome number out: BiomeManager.getBiome over the ring of the chunk of that column

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-PRESET-ROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-NUMBER               BINARY-LONG.
 01 L-ROW.
    05 L-V                 BINARY-DOUBLE OCCURS 7 TIMES.
 PROCEDURE DIVISION USING L-NUMBER L-ROW.
     MOVE 0 TO L-V(1) L-V(2) L-V(3) L-V(4) L-V(5) L-V(6) L-V(7)
     EVALUATE L-NUMBER
         WHEN 2
             MOVE -5000 TO L-V(2)
         WHEN 3
             MOVE 4000 TO L-V(1)
         WHEN 4
             MOVE 5000 TO L-V(2)
             MOVE 3750 TO L-V(7)
         WHEN 5
             MOVE -5000 TO L-V(1)
             MOVE 1750 TO L-V(7)
     END-EVALUATE
     GOBACK.
 END PROGRAM NETHER-PRESET-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-BIOME-OF.
*> The search of 4.1 and 4.3: F_i = (T - T_i)^2 + (H - H_i)^2 + offset_i^2 (the four other parameters are 0 in the target and in every point), the
*> points visited in the tree's sorted order (cost sum |midpoint|: wastes 0, crimson 4000, soul 5000, basalt 6750, warped 8750) and a point
*> replaces the best only when strictly smaller, so a tie goes to the earlier point of that order.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ORDER.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE 4.
 01 WS-ORDER-T REDEFINES WS-ORDER.
    05 WS-O                BINARY-LONG OCCURS 5 TIMES.
 01 WS-ROW.
    05 WS-V                BINARY-DOUBLE OCCURS 7 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-F                   BINARY-DOUBLE.
 01 WS-BEST                BINARY-DOUBLE.
 01 WS-DT                  BINARY-DOUBLE.
 01 WS-DH                  BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-T                    BINARY-DOUBLE.
 01 L-H                    BINARY-DOUBLE.
 01 L-BIOME                BINARY-LONG.
 PROCEDURE DIVISION USING L-T L-H L-BIOME.
     MOVE 0 TO L-BIOME
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE WS-O(WS-I) TO WS-N
         CALL "NETHER-PRESET-ROW" USING WS-N WS-ROW
         COMPUTE WS-DT = L-T - WS-V(1)
         COMPUTE WS-DH = L-H - WS-V(2)
         COMPUTE WS-F = WS-DT * WS-DT + WS-DH * WS-DH + WS-V(7) * WS-V(7)
         IF WS-I = 1 OR WS-F < WS-BEST
             MOVE WS-F TO WS-BEST
             MOVE WS-N TO L-BIOME
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM NETHER-BIOME-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-CLIMATE-AT.
*> The target of 3.5 at the quart cell (qx, qz): temperature and vegetation sampled at (4 qx, 0, 4 qz) with xz scale 0.25 and y scale 0, which is
*> the noise at (qx, 0, qz), quantised as (long)(v * 10000.0f).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NETHER.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG VALUE 0.
 01 WS-Z                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-QX                   BINARY-LONG.
 01 L-QZ                   BINARY-LONG.
 01 L-T                    BINARY-DOUBLE.
 01 L-H                    BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-QX L-QZ L-T L-H.
     MOVE L-QX TO WS-X
     MOVE L-QZ TO WS-Z
     CALL "NOISE-GET" USING NH-H-TEMP WS-X WS-Y WS-Z WS-V
     CALL "CLIMATE-F32-QUANTIZE" USING WS-V L-T
     CALL "NOISE-GET" USING NH-H-VEG WS-X WS-Y WS-Z WS-V
     CALL "CLIMATE-F32-QUANTIZE" USING WS-V L-H
     GOBACK.
 END PROGRAM NETHER-CLIMATE-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-BIOME-GRID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NETHER.
 01 WS-GX                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-T                   BINARY-DOUBLE.
 01 WS-H                   BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ.
     COMPUTE NH-RING-QX = L-CX * 4 - 1
     COMPUTE NH-RING-QZ = L-CZ * 4 - 1
     PERFORM VARYING WS-GZ FROM 0 BY 1 UNTIL WS-GZ > 5
         PERFORM VARYING WS-GX FROM 0 BY 1 UNTIL WS-GX > 5
             COMPUTE WS-QX = NH-RING-QX + WS-GX
             COMPUTE WS-QZ = NH-RING-QZ + WS-GZ
             CALL "NETHER-CLIMATE-AT" USING WS-QX WS-QZ WS-T WS-H
             COMPUTE WS-I = WS-GZ * 6 + WS-GX + 1
             CALL "NETHER-BIOME-OF" USING WS-T WS-H NH-RING(WS-I)
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM NETHER-BIOME-GRID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-BIOME-STORE.
*> Section 5.1: the 4 x 4 column values of the chunk (the inner cells of the ring) copied to the 64 cell rows of each of the 16 sections, in the
*> entry order of 06 section 5.4: index section * 64 + (cell y) * 16 + (cell z) * 4 + (cell x) + 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 COPY NETHER.
 01 WS-S                   BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 LINKAGE SECTION.
 01 L-CHUNK                PIC X.
 PROCEDURE DIVISION USING L-CHUNK.
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF L-CHUNK
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > 15
         PERFORM VARYING WS-LY FROM 0 BY 1 UNTIL WS-LY > 3
             PERFORM VARYING WS-LZ FROM 0 BY 1 UNTIL WS-LZ > 3
                 PERFORM VARYING WS-LX FROM 0 BY 1 UNTIL WS-LX > 3
                     COMPUTE WS-I = (WS-LZ + 1) * 6 + WS-LX + 2
                     COMPUTE WS-CELL = WS-S * 64 + WS-LY * 16 + WS-LZ * 4 + WS-LX + 1
                     MOVE NH-BIOME-ID(NH-RING(WS-I)) TO CE-BIOME(WS-CELL)
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM NETHER-BIOME-STORE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-ZOOM.
*> 10 section 7.7 over the ring: the eight cells around (x - 2, y - 2, z - 2); the stored biome of a cell does not depend on its y (37-3 section 5),
*> so when the four (x, z) cells hold one biome that is the answer, else the cell of the smallest fiddled distance (the first on a tie; the cell
*> y takes part in the hash) wins. The column must lie in the chunk whose ring NETHER-BIOME-GRID built.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NETHER.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-REM                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CELLS.
    05 WS-CELL             BINARY-LONG OCCURS 8 TIMES.
 01 WS-SAME                BINARY-LONG.
 01 WS-S                   BINARY-DOUBLE UNSIGNED.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-INC                 BINARY-DOUBLE.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-OX                  FLOAT-LONG.
 01 WS-OY                  FLOAT-LONG.
 01 WS-OZ                  FLOAT-LONG.
 01 WS-FRX                 FLOAT-LONG.
 01 WS-FRY                 FLOAT-LONG.
 01 WS-FRZ                 FLOAT-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-FOUR                FLOAT-LONG VALUE 4.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-E                   FLOAT-LONG.
 01 WS-BEST                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BIOME                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-BIOME.
     COMPUTE WS-X1 = L-X - 2
     COMPUTE WS-Y1 = L-Y - 2
     COMPUTE WS-Z1 = L-Z - 2
     COMPUTE WS-QX = FUNCTION INTEGER(WS-X1 / 4)
     COMPUTE WS-QY = FUNCTION INTEGER(WS-Y1 / 4)
     COMPUTE WS-QZ = FUNCTION INTEGER(WS-Z1 / 4)
     MOVE 1 TO WS-SAME
     PERFORM VARYING WS-C FROM 0 BY 1 UNTIL WS-C > 7
         DIVIDE WS-C BY 4 GIVING WS-T
         COMPUTE WS-AX = WS-QX + WS-T
         COMPUTE WS-AZ = WS-QZ + FUNCTION MOD(WS-C, 2)
         COMPUTE WS-I = (WS-AZ - NH-RING-QZ) * 6 + WS-AX - NH-RING-QX + 1
         COMPUTE WS-T = WS-C + 1
         MOVE NH-RING(WS-I) TO WS-CELL(WS-T)
         IF WS-CELL(WS-T) NOT = WS-CELL(1)
             MOVE 0 TO WS-SAME
         END-IF
     END-PERFORM
     IF WS-SAME = 1
         MOVE WS-CELL(1) TO L-BIOME
         GOBACK
     END-IF
     COMPUTE WS-REM = FUNCTION MOD(WS-X1, 4)
     COMPUTE WS-A = WS-REM
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-A WS-FOUR WS-FRX
     COMPUTE WS-REM = FUNCTION MOD(WS-Y1, 4)
     COMPUTE WS-A = WS-REM
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-A WS-FOUR WS-FRY
     COMPUTE WS-REM = FUNCTION MOD(WS-Z1, 4)
     COMPUTE WS-A = WS-REM
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-A WS-FOUR WS-FRZ
     MOVE 0 TO WS-BEST L-BIOME
     PERFORM VARYING WS-C FROM 0 BY 1 UNTIL WS-C > 7
         DIVIDE WS-C BY 4 GIVING WS-T
         COMPUTE WS-AX = WS-QX + WS-T
         MOVE WS-FRX TO WS-OX
         IF WS-T = 1
             CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-FRX WS-ONE WS-OX
         END-IF
         DIVIDE WS-C BY 2 GIVING WS-T
         COMPUTE WS-REM = FUNCTION MOD(WS-T, 2)
         COMPUTE WS-AY = WS-QY + WS-REM
         MOVE WS-FRY TO WS-OY
         IF WS-REM = 1
             CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-FRY WS-ONE WS-OY
         END-IF
         COMPUTE WS-REM = FUNCTION MOD(WS-C, 2)
         COMPUTE WS-AZ = WS-QZ + WS-REM
         MOVE WS-FRZ TO WS-OZ
         IF WS-REM = 1
             CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-FRZ WS-ONE WS-OZ
         END-IF
         MOVE NH-ZOOM-SEED TO WS-S
         MOVE WS-AX TO WS-INC
         CALL "SURFACE-LCG" USING WS-S WS-INC
         MOVE WS-AY TO WS-INC
         CALL "SURFACE-LCG" USING WS-S WS-INC
         MOVE WS-AZ TO WS-INC
         CALL "SURFACE-LCG" USING WS-S WS-INC
         MOVE WS-AX TO WS-INC
         CALL "SURFACE-LCG" USING WS-S WS-INC
         MOVE WS-AY TO WS-INC
         CALL "SURFACE-LCG" USING WS-S WS-INC
         MOVE WS-AZ TO WS-INC
         CALL "SURFACE-LCG" USING WS-S WS-INC
         MOVE NH-ZOOM-SEED TO WS-SEED
         CALL "SURFACE-FIDDLE" USING WS-S WS-FX
         CALL "SURFACE-LCG" USING WS-S WS-SEED
         CALL "SURFACE-FIDDLE" USING WS-S WS-FY
         CALL "SURFACE-LCG" USING WS-S WS-SEED
         CALL "SURFACE-FIDDLE" USING WS-S WS-FZ
*>       (oz + fz)^2 + (oy + fy)^2 + (ox + fx)^2
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-OZ WS-FZ WS-A
         MOVE WS-A TO WS-E
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-A WS-E WS-D
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-OY WS-FY WS-A
         MOVE WS-A TO WS-E
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-A WS-E WS-B
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-D WS-B WS-A
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-OX WS-FX WS-B
         MOVE WS-B TO WS-E
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-B WS-E WS-D
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-A WS-D WS-B
         COMPUTE WS-I = (WS-AZ - NH-RING-QZ) * 6 + WS-AX - NH-RING-QX + 1
         IF WS-C = 0 OR WS-B < WS-BEST
             MOVE WS-B TO WS-BEST
             MOVE NH-RING(WS-I) TO L-BIOME
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM NETHER-ZOOM.
