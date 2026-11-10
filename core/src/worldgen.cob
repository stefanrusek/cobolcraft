*> The world generators (standin-content §5.2 for cobolcraft:main, §15.2 for cobolcraft:subroutine),
*> selected by dimension (WORLDGEN-DIM-CHUNK, WORLDGEN-DIM-BIOMES): deterministic and stateless,
*> every column is generated from its world (x, z) alone. Trigonometry uses FUNCTION SIN / COS (research R2).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDGEN-HEIGHT.
*> USING x, z, h-out (BINARY-LONG): the surface height of world column (x, z),
*> 52 + 6 * sin(x / 23) * cos(z / 31) rounded to the nearest integer, halves away from zero.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SIN                 FLOAT-LONG.
 01 WS-COS                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-H.
     CALL "WORLDGEN-SINCOS" USING L-X L-Z WS-SIN WS-COS
     COMPUTE L-H ROUNDED MODE NEAREST-AWAY-FROM-ZERO = 52 + 6 * WS-SIN * WS-COS
     GOBACK.
 END PROGRAM WORLDGEN-HEIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDGEN-SINCOS.
*> USING x, z (BINARY-LONG), sin(x / 23) out, cos(z / 31) out (FLOAT-LONG). FUNCTION SIN and COS
*> are slow, so each result is remembered in a direct-mapped table of 4096 entries per function,
*> indexed by the coordinate mod 4096 and tagged with the coordinate.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SINS.
    05 WS-SIN-ENTRY OCCURS 4096 TIMES.
       10 WS-SIN-SET       PIC 9 VALUE 0.
       10 WS-SIN-KEY       BINARY-LONG.
       10 WS-SIN-VALUE     FLOAT-LONG.
 01 WS-COSS.
    05 WS-COS-ENTRY OCCURS 4096 TIMES.
       10 WS-COS-SET       PIC 9 VALUE 0.
       10 WS-COS-KEY       BINARY-LONG.
       10 WS-COS-VALUE     FLOAT-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SIN                  FLOAT-LONG.
 01 L-COS                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-SIN L-COS.
     COMPUTE WS-I = FUNCTION MOD(L-X, 4096) + 1
     IF WS-SIN-SET(WS-I) = 0 OR WS-SIN-KEY(WS-I) NOT = L-X
         COMPUTE WS-ANGLE = L-X / 23
         COMPUTE WS-SIN-VALUE(WS-I) = FUNCTION SIN(WS-ANGLE)
         MOVE L-X TO WS-SIN-KEY(WS-I)
         MOVE 1 TO WS-SIN-SET(WS-I)
     END-IF
     MOVE WS-SIN-VALUE(WS-I) TO L-SIN
     COMPUTE WS-I = FUNCTION MOD(L-Z, 4096) + 1
     IF WS-COS-SET(WS-I) = 0 OR WS-COS-KEY(WS-I) NOT = L-Z
         COMPUTE WS-ANGLE = L-Z / 31
         COMPUTE WS-COS-VALUE(WS-I) = FUNCTION COS(WS-ANGLE)
         MOVE L-Z TO WS-COS-KEY(WS-I)
         MOVE 1 TO WS-COS-SET(WS-I)
     END-IF
     MOVE WS-COS-VALUE(WS-I) TO L-COS
     GOBACK.
 END PROGRAM WORLDGEN-SINCOS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDGEN-CHUNK.
*> USING chunk x, chunk z (BINARY-LONG), chunk memory (CELLS.cpy layout; only the block states
*> are written), marker-y out (BINARY-LONG: y of the marker glowtube, -1 when the chunk has none).
*> Layers per column (h = surface height): y 0 baseplate, 1 to h - 4 greystone, h - 3 to h - 1 loam,
*> h turf when h >= 50 else grit, above void. Marker chunks (chunk x and z multiples of 4) get the
*> pillar at local (8, 8): cardstack 9 at h + 1 and h + 2, cardstack 8 at h + 3, lucite at h + 4,
*> lit glowtube at h + 5. The sines and cosines are taken once per row and column of the chunk.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BLOCKS.
 COPY CELLS.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-SINS.
    05 WS-SIN              FLOAT-LONG OCCURS 16 TIMES.
 01 WS-COSS.
    05 WS-COS              FLOAT-LONG OCCURS 16 TIMES.
 01 WS-HEIGHTS.
    05 WS-H                BINARY-LONG OCCURS 256 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CHUNK                PIC X.
 01 L-MARKER-Y             BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-CHUNK L-MARKER-Y.
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF L-CHUNK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         COMPUTE WS-X = L-CX * 16 + WS-I - 1
         COMPUTE WS-Z = L-CZ * 16 + WS-I - 1
         CALL "WORLDGEN-SINCOS" USING WS-X WS-Z WS-SIN(WS-I) WS-COS(WS-I)
     END-PERFORM
     MOVE 999 TO WS-MIN
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 256
         COMPUTE WS-LZ = (WS-C - 1) / 16
         COMPUTE WS-LX = WS-C - 1 - WS-LZ * 16
         COMPUTE WS-H(WS-C) ROUNDED MODE NEAREST-AWAY-FROM-ZERO
             = 52 + 6 * WS-SIN(WS-LX + 1) * WS-COS(WS-LZ + 1)
         IF WS-H(WS-C) < WS-MIN
             MOVE WS-H(WS-C) TO WS-MIN
         END-IF
     END-PERFORM
*>   Whole layers first: void everywhere, baseplate at y 0, greystone from y 1 to the lowest h - 4.
     MOVE LOW-VALUES TO CE-STATES
     MOVE ALL X"0100" TO CE-STATES(1:512)
     COMPUTE WS-LENGTH = (WS-MIN - 4) * 512
     MOVE ALL X"0200" TO CE-STATES(513:WS-LENGTH)
*>   Then each column from the lowest h - 3 to its own h.
     COMPUTE WS-LOW = WS-MIN - 3
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 256
         MOVE WS-H(WS-C) TO WS-TOP
         PERFORM VARYING WS-Y FROM WS-LOW BY 1 UNTIL WS-Y > WS-TOP
             COMPUTE WS-CELL = WS-Y * 256 + WS-C
             EVALUATE TRUE
                 WHEN WS-Y <= WS-TOP - 4
                     MOVE ST-GREYSTONE TO CE-STATE(WS-CELL)
                 WHEN WS-Y < WS-TOP
                     MOVE ST-LOAM TO CE-STATE(WS-CELL)
                 WHEN WS-TOP >= 50
                     MOVE ST-TURF TO CE-STATE(WS-CELL)
                 WHEN OTHER
                     MOVE ST-GRIT TO CE-STATE(WS-CELL)
             END-EVALUATE
         END-PERFORM
     END-PERFORM
     MOVE -1 TO L-MARKER-Y
     IF FUNCTION MOD(L-CX, 4) = 0 AND FUNCTION MOD(L-CZ, 4) = 0
         MOVE 137 TO WS-C
         COMPUTE WS-CELL = WS-H(WS-C) * 256 + WS-C
         MOVE ST-CARDSTACK-Y TO CE-STATE(WS-CELL + 256)
         MOVE ST-CARDSTACK-Y TO CE-STATE(WS-CELL + 512)
         MOVE ST-CARDSTACK-Y-PUNCHED TO CE-STATE(WS-CELL + 768)
         MOVE ST-LUCITE TO CE-STATE(WS-CELL + 1024)
         MOVE ST-GLOWTUBE-LIT TO CE-STATE(WS-CELL + 1280)
         COMPUTE L-MARKER-Y = WS-H(WS-C) + 5
     END-IF
     GOBACK.
 END PROGRAM WORLDGEN-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDGEN-BIOMES.
*> USING chunk x, chunk z (BINARY-LONG), biomes out (table of 16 BINARY-LONG, entry cell z * 4 +
*> cell x + 1): the biome of each 4 x 4 cell column, the same for every cell Y. Upland (1) when the
*> surface height at the cell's lowest-x, lowest-z corner column is 55 or more, else plains (0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BLOCKS.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-BIOMES.
    05 L-BIOME             BINARY-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING L-CX L-CZ L-BIOMES.
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 15
         COMPUTE WS-Z = WS-I / 4
         COMPUTE WS-X = L-CX * 16 + (WS-I - WS-Z * 4) * 4
         COMPUTE WS-Z = L-CZ * 16 + WS-Z * 4
         CALL "WORLDGEN-HEIGHT" USING WS-X WS-Z WS-H
         MOVE BIOME-PLAINS TO L-BIOME(WS-I + 1)
         IF WS-H >= 55
             MOVE BIOME-UPLAND TO L-BIOME(WS-I + 1)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WORLDGEN-BIOMES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDGEN-SUB-HEIGHT.
*> USING x, z, h-out (BINARY-LONG): the floor height of cobolcraft:subroutine column (x, z) (standin
*> §15.2), GEN-SUB-BASE + GEN-SUB-AMPLITUDE x sin(x / GEN-SUB-X-DIVISOR) x cos(z /
*> GEN-SUB-Z-DIVISOR) rounded to the nearest integer, halves away from zero.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DIMENSIONS.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-SIN                 FLOAT-LONG.
 01 WS-COS                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-H.
     COMPUTE WS-ANGLE = L-X / GEN-SUB-X-DIVISOR
     COMPUTE WS-SIN = FUNCTION SIN(WS-ANGLE)
     COMPUTE WS-ANGLE = L-Z / GEN-SUB-Z-DIVISOR
     COMPUTE WS-COS = FUNCTION COS(WS-ANGLE)
     COMPUTE L-H ROUNDED MODE NEAREST-AWAY-FROM-ZERO
         = GEN-SUB-BASE + GEN-SUB-AMPLITUDE * WS-SIN * WS-COS
     GOBACK.
 END PROGRAM WORLDGEN-SUB-HEIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDGEN-SUB-CHUNK.
*> USING chunk x, chunk z (BINARY-LONG), chunk memory (CELLS.cpy layout; only the block states
*> are written), marker-y out (BINARY-LONG: y of the marker glowtube, -1 when the chunk has none).
*> The §15.2 generator: per column (h = floor height) y 0 baseplate, 1 to h - 3 greystone, h - 2 to
*> h slag, above void (up to the top of the chunk memory); in chunks whose chunk x and z are both
*> multiples of GEN-SUB-MARKER-MOD (mathematical modulo) a lit glowtube at local (8, h + 1, 8). The
*> sines and cosines are taken once per row and column of the chunk.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BLOCKS.
 COPY DIMENSIONS.
 COPY CELLS.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-SINS.
    05 WS-SIN              FLOAT-LONG OCCURS 16 TIMES.
 01 WS-COSS.
    05 WS-COS              FLOAT-LONG OCCURS 16 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CHUNK                PIC X.
 01 L-MARKER-Y             BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-CHUNK L-MARKER-Y.
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF L-CHUNK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         COMPUTE WS-ANGLE = (L-CX * 16 + WS-I - 1) / GEN-SUB-X-DIVISOR
         COMPUTE WS-SIN(WS-I) = FUNCTION SIN(WS-ANGLE)
         COMPUTE WS-ANGLE = (L-CZ * 16 + WS-I - 1) / GEN-SUB-Z-DIVISOR
         COMPUTE WS-COS(WS-I) = FUNCTION COS(WS-ANGLE)
     END-PERFORM
     MOVE LOW-VALUES TO CE-STATES
     MOVE ALL X"0100" TO CE-STATES(1:512)
     MOVE -1 TO L-MARKER-Y
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 256
         COMPUTE WS-LZ = (WS-C - 1) / 16
         COMPUTE WS-LX = WS-C - 1 - WS-LZ * 16
         COMPUTE WS-H ROUNDED MODE NEAREST-AWAY-FROM-ZERO
             = GEN-SUB-BASE + GEN-SUB-AMPLITUDE * WS-SIN(WS-LX + 1) * WS-COS(WS-LZ + 1)
         PERFORM VARYING WS-Y FROM 1 BY 1 UNTIL WS-Y > WS-H
             COMPUTE WS-CELL = WS-Y * 256 + WS-C
             IF WS-Y <= WS-H - 3
                 MOVE ST-GREYSTONE TO CE-STATE(WS-CELL)
             ELSE
                 MOVE ST-SLAG TO CE-STATE(WS-CELL)
             END-IF
         END-PERFORM
         IF WS-C = 137 AND FUNCTION MOD(L-CX, GEN-SUB-MARKER-MOD) = 0
                 AND FUNCTION MOD(L-CZ, GEN-SUB-MARKER-MOD) = 0
             COMPUTE L-MARKER-Y = WS-H + 1
             MOVE ST-GLOWTUBE-LIT TO CE-STATE(L-MARKER-Y * 256 + WS-C)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WORLDGEN-SUB-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDGEN-DIM-CHUNK.
*> USING dimension row, chunk x, chunk z (BINARY-LONG), chunk memory, marker-y out: the chunk from
*> the dimension's generator (DIMENSIONS.cpy DM-GENERATOR): WORLDGEN-CHUNK (§5.2) or
*> WORLDGEN-SUB-CHUNK (§15.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DIMENSIONS.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CHUNK                PIC X.
 01 L-MARKER-Y             BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-CHUNK L-MARKER-Y.
     EVALUATE DM-GENERATOR(L-DIM)
         WHEN DIM-GEN-SUBROUTINE
             CALL "WORLDGEN-SUB-CHUNK" USING L-CX L-CZ L-CHUNK L-MARKER-Y
         WHEN DIM-GEN-STANDARD
             CALL "WORLDGEN-VOID-CHUNK" USING L-CHUNK L-MARKER-Y
         WHEN OTHER
             CALL "WORLDGEN-CHUNK" USING L-CX L-CZ L-CHUNK L-MARKER-Y
     END-EVALUATE
     GOBACK.
 END PROGRAM WORLDGEN-DIM-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDGEN-VOID-CHUNK.
*> USING chunk memory, marker-y out: the placeholder generator of the standard world type (void in every
*> cell, no marker) until the standard worldgen of docs 10 and 11 is built.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 LINKAGE SECTION.
 01 L-CHUNK                PIC X.
 01 L-MARKER-Y             BINARY-LONG.
 PROCEDURE DIVISION USING L-CHUNK L-MARKER-Y.
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF L-CHUNK
     MOVE LOW-VALUES TO CE-STATES
     MOVE -1 TO L-MARKER-Y
     GOBACK.
 END PROGRAM WORLDGEN-VOID-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDGEN-DIM-BIOMES.
*> USING dimension row, chunk x, chunk z (BINARY-LONG), biomes out (table of 16 BINARY-LONG, as
*> WORLDGEN-BIOMES): the dimension's single biome (DM-BIOME, §15.1) in every cell, or, when it has
*> none (-1), the biomes of WORLDGEN-BIOMES (§5.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DIMENSIONS.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-BIOMES.
    05 L-BIOME             BINARY-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-BIOMES.
     IF DM-BIOME(L-DIM) < 0
         CALL "WORLDGEN-BIOMES" USING L-CX L-CZ L-BIOMES
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE DM-BIOME(L-DIM) TO L-BIOME(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM WORLDGEN-DIM-BIOMES.
