*> The cobolcraft:main generator (standin-content §5.2): deterministic and stateless, every column is
*> generated from its world (x, z) alone. Trigonometry uses FUNCTION SIN / COS (research R2).

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
*> USING chunk x, chunk z (BINARY-LONG), chunk memory (CHUNKMEM.cpy layout; only the block states
*> are written), marker-y out (BINARY-LONG: y of the marker glowtube, -1 when the chunk has none).
*> Layers per column (h = surface height): y 0 baseplate, 1 to h - 4 greystone, h - 3 to h - 1 loam,
*> h turf when h >= 50 else grit, above void. Marker chunks (chunk x and z multiples of 4) get the
*> pillar at local (8, 8): cardstack 9 at h + 1 and h + 2, cardstack 8 at h + 3, lucite at h + 4,
*> lit glowtube at h + 5. The sines and cosines are taken once per row and column of the chunk.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BLOCKS.
 COPY CHUNKMEM.
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
     SET ADDRESS OF CM-CHUNK TO ADDRESS OF L-CHUNK
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
     MOVE LOW-VALUES TO CM-STATES
     MOVE ALL X"01" TO CM-STATES(1:256)
     COMPUTE WS-LENGTH = (WS-MIN - 4) * 256
     MOVE ALL X"02" TO CM-STATES(257:WS-LENGTH)
*>   Then each column from the lowest h - 3 to its own h.
     COMPUTE WS-LOW = WS-MIN - 3
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 256
         MOVE WS-H(WS-C) TO WS-TOP
         PERFORM VARYING WS-Y FROM WS-LOW BY 1 UNTIL WS-Y > WS-TOP
             COMPUTE WS-CELL = WS-Y * 256 + WS-C
             EVALUATE TRUE
                 WHEN WS-Y <= WS-TOP - 4
                     MOVE ST-GREYSTONE TO CM-STATE(WS-CELL)
                 WHEN WS-Y < WS-TOP
                     MOVE ST-LOAM TO CM-STATE(WS-CELL)
                 WHEN WS-TOP >= 50
                     MOVE ST-TURF TO CM-STATE(WS-CELL)
                 WHEN OTHER
                     MOVE ST-GRIT TO CM-STATE(WS-CELL)
             END-EVALUATE
         END-PERFORM
     END-PERFORM
     MOVE -1 TO L-MARKER-Y
     IF FUNCTION MOD(L-CX, 4) = 0 AND FUNCTION MOD(L-CZ, 4) = 0
         MOVE 137 TO WS-C
         COMPUTE WS-CELL = WS-H(WS-C) * 256 + WS-C
         MOVE ST-CARDSTACK-Y TO CM-STATE(WS-CELL + 256)
         MOVE ST-CARDSTACK-Y TO CM-STATE(WS-CELL + 512)
         MOVE ST-CARDSTACK-Y-PUNCHED TO CM-STATE(WS-CELL + 768)
         MOVE ST-LUCITE TO CM-STATE(WS-CELL + 1024)
         MOVE ST-GLOWTUBE-LIT TO CM-STATE(WS-CELL + 1280)
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
