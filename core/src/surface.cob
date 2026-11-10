*> The surface rules of the standard overworld (docs/protocol/10 sections 7.7 and 10; T0423; SURFACE.cpy): the zoomed biome lookup,
*> the terracotta bands, the interpreter of the data-driven material rule tree (domains 2 and 3 of the content's node store), the
*> column procedure and the step of the generation job that runs them (GEN-STAGE-SURFACE: steps 0 to 3 the preliminary surface level
*> at the four corners of the chunk, steps 4 to 99 the biome cells around the chunk, one quart layer each, steps 100 to 163 four
*> columns each, in the order of 10.1, x outer and z inner). A world whose content holds no material rule "minecraft:overworld"
*> keeps the fill as it is. The ore vein rule belongs to document 11 (ores.cob) and gives no block here.
*>
*> Entry points:
*>   SURFACE-SETUP USING seed (BINARY-DOUBLE UNSIGNED): the world seed; computes the zoom seed (7.7) and forgets what was
*>     remembered of the node store.
*>   SURFACE-BIOME-AT USING job, x, y, z, biome id out: BiomeManager.getBiome of 7.7 over the chunk's stored cells.
*>   SURFACE-BANDS-ENSURE: builds the terracotta bands of 10.6 for the world's positional factory.
*>   SURFACE-RULE USING job, rule node, state out (-1: the rule yields no block); SURFACE-COND USING job, node, result out.
*>   SURFACE-COLUMN USING job, local x, local z: the column procedure of 10.1 (and the pillars of 10.7).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SURFACE-SETUP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SURFACE.
 01 WS-DATA                PIC X(8).
 01 WS-DIGEST              PIC X(64).
 01 WS-DIGEST-LENGTH       BINARY-LONG UNSIGNED.
 01 WS-DATA-LENGTH         BINARY-DOUBLE UNSIGNED VALUE 8.
 01 WS-ALGORITHM           USAGE POINTER.
 01 WS-ENGINE              USAGE POINTER VALUE NULL.
 01 WS-RC                  BINARY-LONG.
 01 WS-V                   BINARY-DOUBLE UNSIGNED.
 01 WS-A                   BINARY-DOUBLE UNSIGNED.
 01 WS-I                   BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION USING L-SEED.
*>   obfuscateSeed: the first 8 bytes of SHA-256 of the 8 little-endian bytes of the seed, as a little-endian word
     MOVE L-SEED TO WS-V
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         COMPUTE WS-BYTE = FUNCTION MOD(WS-V, 256)
         MOVE FUNCTION CHAR(WS-BYTE + 1) TO WS-DATA(WS-I:1)
         DIVIDE WS-V BY 256 GIVING WS-V
     END-PERFORM
     CALL STATIC "EVP_sha256" RETURNING WS-ALGORITHM
     CALL STATIC "EVP_Digest" USING BY REFERENCE WS-DATA BY VALUE WS-DATA-LENGTH
         BY REFERENCE WS-DIGEST BY REFERENCE WS-DIGEST-LENGTH BY VALUE WS-ALGORITHM
         BY VALUE WS-ENGINE RETURNING WS-RC
     MOVE 0 TO WS-A
     PERFORM VARYING WS-I FROM 8 BY -1 UNTIL WS-I < 1
         COMPUTE WS-BYTE = FUNCTION ORD(WS-DIGEST(WS-I:1)) - 1
         COMPUTE WS-A = WS-A * 256 + WS-BYTE
     END-PERFORM
     MOVE WS-A TO SF-ZOOM-SEED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SF-NODES
         MOVE 0 TO SF-N-REF(WS-I) SF-N-ANSWER(WS-I) SF-N-VG-READY(WS-I)
         MOVE -2 TO SF-N-STATE(WS-I)
         MOVE -1 TO SF-N-HANDLE(WS-I) SF-N-BIOME(WS-I)
     END-PERFORM
     MOVE 0 TO SF-BANDS-READY
     MOVE 1 TO SF-SEED-READY
     GOBACK.
 END PROGRAM SURFACE-SETUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SURFACE-LCG.
*> USING s (BINARY-DOUBLE UNSIGNED, in and out), increment (BINARY-DOUBLE): s * (s * 6364136223846793005 + 1442695040888963407)
*> + increment, 64 bit wrapping (7.7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-MUL                 BINARY-DOUBLE UNSIGNED VALUE 6364136223846793005.
 01 WS-ADD                 BINARY-DOUBLE UNSIGNED VALUE 1442695040888963407.
 01 WS-T                   BINARY-DOUBLE UNSIGNED.
 LINKAGE SECTION.
 01 L-S                    BINARY-DOUBLE UNSIGNED.
 01 L-INC                  BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-S L-INC.
     COMPUTE WS-T = FUNCTION MOD(L-S * WS-MUL + WS-ADD, WS-M64)
     COMPUTE L-S = FUNCTION MOD(L-S * WS-T + L-INC, WS-M64)
     GOBACK.
 END PROGRAM SURFACE-LCG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SURFACE-FIDDLE.
*> USING s (BINARY-DOUBLE UNSIGNED), result out (FLOAT-LONG): ((floorMod(s >> 24, 1024)) / 1024.0 - 0.5) * 0.9 (7.7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-TEXT                PIC X(8) VALUE Z"0.9".
 01 WS-NINE-TENTHS         FLOAT-LONG.
 01 WS-THOUSAND            FLOAT-LONG VALUE 1024.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-Q                   BINARY-DOUBLE UNSIGNED.
 01 WS-M                   BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-G                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-S                    BINARY-DOUBLE UNSIGNED.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-S L-RESULT.
     IF WS-READY = 0
         CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TEXT WS-NINE-TENTHS
         MOVE 1 TO WS-READY
     END-IF
     DIVIDE L-S BY 16777216 GIVING WS-Q
     COMPUTE WS-M = FUNCTION MOD(WS-Q, 1024)
     MOVE WS-M TO WS-F
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-F WS-THOUSAND WS-G
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-G WS-HALF WS-F
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-F WS-NINE-TENTHS L-RESULT
     GOBACK.
 END PROGRAM SURFACE-FIDDLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SURFACE-BIOME-ID.
*> USING name (PIC X(40), "minecraft:plains"), id out (BINARY-LONG): the id of that biome in the open set (0 when absent).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-I                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-ID.
     MOVE 0 TO L-ID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CBI-COUNT
         MOVE CBI-KEY-LENGTH(WS-I) TO WS-LEN
         IF WS-LEN > 0 AND WS-LEN <= 40
             COMPUTE WS-NEXT = WS-LEN + 1
             IF CBI-KEY(WS-I)(1:WS-LEN) = L-NAME(1:WS-LEN) AND L-NAME(WS-NEXT:1) = SPACE
                 COMPUTE L-ID = WS-I - 1
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SURFACE-BIOME-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SURFACE-CELL-BIOME.
*> USING job, quart x, quart y, quart z, id out: the stored biome of a quart cell of the chunk or of the ring of cells around it
*> (the surface stage's neighbours, GJ-SF-RING); the quart y is clamped to the dimension.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-LAYER               BINARY-LONG.
 01 WS-SECTION             BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 01 L-QX                   BINARY-LONG.
 01 L-QY                   BINARY-LONG.
 01 L-QZ                   BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-JOB L-QX L-QY L-QZ L-ID.
     MOVE 0 TO L-ID
     COMPUTE WS-RX = L-QX - J-CX * 4
     COMPUTE WS-RZ = L-QZ - J-CZ * 4
     COMPUTE WS-LAYER = FUNCTION MAX(0, FUNCTION MIN(95, L-QY + 16))
     IF WS-RX >= 0 AND WS-RX <= 3 AND WS-RZ >= 0 AND WS-RZ <= 3
         SET ADDRESS OF CE-CHUNK TO J-ADDR
         DIVIDE WS-LAYER BY 4 GIVING WS-SECTION REMAINDER WS-LY
         COMPUTE WS-CELL = WS-SECTION * 64 + WS-LY * 16 + WS-RZ * 4 + WS-RX + 1
         MOVE CE-BIOME(WS-CELL) TO L-ID
     ELSE
         IF J-SF-RING(WS-LAYER * 36 + (WS-RZ + 1) * 6 + WS-RX + 2) > 0
             COMPUTE L-ID = J-SF-RING(WS-LAYER * 36 + (WS-RZ + 1) * 6 + WS-RX + 2) - 1
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SURFACE-CELL-BIOME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SURFACE-BIOME-AT.
*> USING job, x, y, z, id out: 7.7 BiomeManager.getBiome. The eight cells around (x - 2, y - 2, z - 2) are read; when they hold
*> one biome that is the answer (remembered for the four y of the cell layer in SC-BIO-Q / SC-BIO-ID, per column), else the cell of the
*> smallest fiddled distance (the first on a tie) wins.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SURFACE.
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
 01 WS-QUARTER             FLOAT-LONG VALUE 0.25.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-BEST                FLOAT-LONG.
 01 WS-E                   FLOAT-LONG.
 01 WS-REM                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-JOB L-X L-Y L-Z L-ID.
     COMPUTE WS-X1 = L-X - 2
     COMPUTE WS-Y1 = L-Y - 2
     COMPUTE WS-Z1 = L-Z - 2
     COMPUTE WS-QX = FUNCTION INTEGER(WS-X1 / 4)
     COMPUTE WS-QY = FUNCTION INTEGER(WS-Y1 / 4)
     COMPUTE WS-QZ = FUNCTION INTEGER(WS-Z1 / 4)
     IF WS-QY = SC-BIO-Q AND SC-BIO-ID >= 0
         MOVE SC-BIO-ID TO L-ID
         GOBACK
     END-IF
     MOVE 1 TO WS-SAME
     PERFORM VARYING WS-C FROM 0 BY 1 UNTIL WS-C > 7
         DIVIDE WS-C BY 4 GIVING WS-T
         COMPUTE WS-AX = WS-QX + WS-T
         DIVIDE WS-C BY 2 GIVING WS-T
         COMPUTE WS-AY = WS-QY + FUNCTION MOD(WS-T, 2)
         COMPUTE WS-AZ = WS-QZ + FUNCTION MOD(WS-C, 2)
         COMPUTE WS-T = WS-C + 1
         CALL "SURFACE-CELL-BIOME" USING L-JOB WS-AX WS-AY WS-AZ WS-CELL(WS-T)
         IF WS-CELL(WS-T) NOT = WS-CELL(1)
             MOVE 0 TO WS-SAME
         END-IF
     END-PERFORM
     MOVE WS-QY TO SC-BIO-Q
     IF WS-SAME = 1
         MOVE WS-CELL(1) TO L-ID SC-BIO-ID
         GOBACK
     END-IF
     MOVE -1 TO SC-BIO-ID
     MOVE SF-ZOOM-SEED TO WS-SEED
     COMPUTE WS-REM = FUNCTION MOD(WS-X1, 4)
     COMPUTE WS-FRX = WS-REM / 4
     COMPUTE WS-REM = FUNCTION MOD(WS-Y1, 4)
     COMPUTE WS-FRY = WS-REM / 4
     COMPUTE WS-REM = FUNCTION MOD(WS-Z1, 4)
     COMPUTE WS-FRZ = WS-REM / 4
     MOVE 0 TO WS-BEST L-ID
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
         MOVE SF-ZOOM-SEED TO WS-S
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
         COMPUTE WS-T = WS-C + 1
         IF WS-C = 0 OR WS-B < WS-BEST
             MOVE WS-B TO WS-BEST
             MOVE WS-CELL(WS-T) TO L-ID
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SURFACE-BIOME-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. XORO-NEXT-FLOAT.
*> USING generator state (XORO.cpy), result out (FLOAT-LONG): nextFloat of 10 section 2.3, (nextLong >>> 40) * 2^-24 (exact).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LONG                BINARY-DOUBLE UNSIGNED.
 01 WS-BITS                BINARY-DOUBLE UNSIGNED.
 01 WS-F                   FLOAT-LONG.
 01 WS-SCALE               FLOAT-LONG VALUE 16777216.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-STATE L-RESULT.
     CALL "XORO-NEXT-LONG" USING L-STATE WS-LONG
     DIVIDE WS-LONG BY 1099511627776 GIVING WS-BITS
     MOVE WS-BITS TO WS-F
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-F WS-SCALE L-RESULT
     GOBACK.
 END PROGRAM XORO-NEXT-FLOAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SURFACE-BANDS-ENSURE.
*> No parameters: 10.6, the 192 band states, from P.fromHashOf("minecraft:clay_bands") of the world's factory (DN-FACTORY); built
*> once for a factory.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY SURFACE.
 COPY DENSITY.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-R== LEADING ==XR-== BY ==WS-R-==.
 01 WS-NAME                PIC X(64) VALUE "minecraft:clay_bands".
 01 WS-LENGTH              BINARY-LONG VALUE 20.
 01 WS-KEYS.
    05 FILLER              PIC X(48) VALUE "minecraft:terracotta".
    05 FILLER              PIC X(48) VALUE "minecraft:orange_terracotta".
    05 FILLER              PIC X(48) VALUE "minecraft:yellow_terracotta".
    05 FILLER              PIC X(48) VALUE "minecraft:brown_terracotta".
    05 FILLER              PIC X(48) VALUE "minecraft:red_terracotta".
    05 FILLER              PIC X(48) VALUE "minecraft:white_terracotta".
    05 FILLER              PIC X(48) VALUE "minecraft:light_gray_terracotta".
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-KEY              PIC X(48) OCCURS 7 TIMES.
 01 WS-STATES.
    05 WS-STATE            BINARY-LONG OCCURS 7 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE UNSIGNED.
 01 WS-POS                 BINARY-LONG.
 PROCEDURE DIVISION.
     IF SF-BANDS-READY = 1 AND SF-BAND-LO = DN-FLO AND SF-BAND-HI = DN-FHI
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         CALL "GEN-BLOCK-STATE" USING WS-KEY(WS-I) WS-STATE(WS-I)
     END-PERFORM
     CALL "XORO-FROM-HASH" USING DN-FACTORY WS-NAME WS-LENGTH WS-R
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 192
         MOVE WS-STATE(1) TO SF-BAND(WS-I)
     END-PERFORM
*>   orange bands: i + 0 is the band index, SF-BAND is 1 based
     MOVE 0 TO WS-I
     PERFORM UNTIL WS-I >= 192
         MOVE 5 TO WS-BOUND
         CALL "XORO-NEXT-INT" USING WS-R WS-BOUND WS-DRAW
         COMPUTE WS-I = WS-I + WS-DRAW + 1
         IF WS-I < 192
             COMPUTE WS-J = WS-I + 1
             MOVE WS-STATE(2) TO SF-BAND(WS-J)
         END-IF
         ADD 1 TO WS-I
     END-PERFORM
*>   yellow (1), brown (2), red (1)
     PERFORM VARYING WS-KIND FROM 1 BY 1 UNTIL WS-KIND > 3
         EVALUATE WS-KIND
             WHEN 1
                 MOVE 1 TO WS-WIDTH
                 MOVE 3 TO WS-K
             WHEN 2
                 MOVE 2 TO WS-WIDTH
                 MOVE 4 TO WS-K
             WHEN OTHER
                 MOVE 1 TO WS-WIDTH
                 MOVE 5 TO WS-K
         END-EVALUATE
         MOVE 10 TO WS-BOUND
         CALL "XORO-NEXT-INT" USING WS-R WS-BOUND WS-DRAW
         COMPUTE WS-COUNT = WS-DRAW + 6
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
             MOVE 3 TO WS-BOUND
             CALL "XORO-NEXT-INT" USING WS-R WS-BOUND WS-DRAW
             COMPUTE WS-J = WS-WIDTH + WS-DRAW
             MOVE 192 TO WS-BOUND
             CALL "XORO-NEXT-INT" USING WS-R WS-BOUND WS-START
             PERFORM VARYING WS-POS FROM 0 BY 1 UNTIL WS-POS >= WS-J OR WS-START + WS-POS >= 192
                 COMPUTE WS-DRAW = WS-START + WS-POS + 1
                 MOVE WS-STATE(WS-K) TO SF-BAND(WS-DRAW)
             END-PERFORM
         END-PERFORM
     END-PERFORM
*>   white bands with light grey edges
     MOVE 7 TO WS-BOUND
     CALL "XORO-NEXT-INT" USING WS-R WS-BOUND WS-DRAW
     COMPUTE WS-COUNT = WS-DRAW + 9
     MOVE 0 TO WS-POS
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-COUNT OR WS-POS >= 192
         COMPUTE WS-I = WS-POS + 1
         MOVE WS-STATE(6) TO SF-BAND(WS-I)
         IF WS-POS - 1 > 0
             CALL "XORO-NEXT-LONG" USING WS-R WS-LONG
             IF FUNCTION MOD(WS-LONG, 2) = 1
                 MOVE WS-STATE(7) TO SF-BAND(WS-POS)
             END-IF
         END-IF
         IF WS-POS + 1 < 192
             CALL "XORO-NEXT-LONG" USING WS-R WS-LONG
             IF FUNCTION MOD(WS-LONG, 2) = 1
                 COMPUTE WS-I = WS-POS + 2
                 MOVE WS-STATE(7) TO SF-BAND(WS-I)
             END-IF
         END-IF
         MOVE 16 TO WS-BOUND
         CALL "XORO-NEXT-INT" USING WS-R WS-BOUND WS-DRAW
         COMPUTE WS-POS = WS-POS + WS-DRAW + 4
     END-PERFORM
     MOVE DN-FLO TO SF-BAND-LO
     MOVE DN-FHI TO SF-BAND-HI
     MOVE 1 TO SF-BANDS-READY
     GOBACK.
 END PROGRAM SURFACE-BANDS-ENSURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SURFACE-ANCHOR.
*> USING kind (1 absolute, 2 above_bottom, 3 below_top, 4 relative_to_sea_level), value, y out (10.4 anchors; min y -64, height 384,
*> sea level 63).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-VALUE L-Y.
     EVALUATE L-KIND
         WHEN 2
             COMPUTE L-Y = -64 + L-VALUE
         WHEN 3
             COMPUTE L-Y = 319 - L-VALUE
         WHEN 4
             COMPUTE L-Y = 63 + L-VALUE
         WHEN OTHER
             MOVE L-VALUE TO L-Y
     END-EVALUATE
     GOBACK.
 END PROGRAM SURFACE-ANCHOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SURFACE-NOISE-AT.
*> USING node (a node holding a noise id in WGN-TEXT-1), x, y, z, value out (FLOAT-LONG): the normal noise of that id at the
*> position (0 when the content defines no such noise); the handle is remembered in the node's row.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 COPY SURFACE.
 01 WS-KEY                 PIC X(112).
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-NODE L-X L-Y L-Z L-VALUE.
     IF SF-N-HANDLE(L-NODE) = -1
         MOVE WGN-TEXT-1(L-NODE)(1:112) TO WS-KEY
         CALL "DENSITY-NOISE-HANDLE" USING WS-KEY SF-N-HANDLE(L-NODE)
     END-IF
     MOVE 0 TO L-VALUE
     IF SF-N-HANDLE(L-NODE) > 0
         MOVE L-X TO WS-X
         MOVE L-Y TO WS-Y
         MOVE L-Z TO WS-Z
         CALL "NOISE-GET" USING SF-N-HANDLE(L-NODE) WS-X WS-Y WS-Z L-VALUE
     END-IF
     GOBACK.
 END PROGRAM SURFACE-NOISE-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SURFACE-NOISE-NAMED.
*> USING noise id (PIC X(112)), x, y, z, value out (FLOAT-LONG): the normal noise of that id at the position (0 when undefined).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HANDLE              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(112).
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-KEY L-X L-Y L-Z L-VALUE.
     CALL "DENSITY-NOISE-HANDLE" USING L-KEY WS-HANDLE
     MOVE 0 TO L-VALUE
     IF WS-HANDLE > 0
         CALL "NOISE-GET" USING WS-HANDLE L-X L-Y L-Z L-VALUE
     END-IF
     GOBACK.
 END PROGRAM SURFACE-NOISE-NAMED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SURFACE-BIOME-IN.
*> USING job, node (a biome condition: the ids in WGN-TEXT-1), answer out: 1 when the biome at the context position is one of
*> them (7.7, 10.1: the biome at the current y); the answer is remembered for the last biome tested.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 COPY SURFACE.
 COPY CBLOCKS.
 01 WS-ID                  BINARY-LONG.
 01 WS-LIST                PIC X(164).
 01 WS-PATTERN             PIC X(50).
 01 WS-LEN                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 01 L-NODE                 BINARY-LONG.
 01 L-ANSWER               BINARY-LONG.
 PROCEDURE DIVISION USING L-JOB L-NODE L-ANSWER.
     CALL "SURFACE-BIOME-AT" USING L-JOB SC-X SC-Y SC-Z WS-ID
     IF WS-ID = SF-N-BIOME(L-NODE)
         MOVE SF-N-ANSWER(L-NODE) TO L-ANSWER
         GOBACK
     END-IF
     MOVE SPACES TO WS-LIST WS-PATTERN
     STRING " " WGN-TEXT-1(L-NODE) " " DELIMITED BY SIZE INTO WS-LIST
     COMPUTE WS-LEN = CBI-KEY-LENGTH(WS-ID + 1) + 2
     STRING " " CBI-KEY(WS-ID + 1)(1:CBI-KEY-LENGTH(WS-ID + 1)) " " DELIMITED BY SIZE INTO WS-PATTERN
     MOVE 0 TO WS-COUNT
     INSPECT WS-LIST TALLYING WS-COUNT FOR ALL WS-PATTERN(1:WS-LEN)
     MOVE 0 TO L-ANSWER
     IF WS-COUNT > 0
         MOVE 1 TO L-ANSWER
     END-IF
     MOVE WS-ID TO SF-N-BIOME(L-NODE)
     MOVE L-ANSWER TO SF-N-ANSWER(L-NODE)
     GOBACK.
 END PROGRAM SURFACE-BIOME-IN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SURFACE-GRADIENT.
*> USING job, node (a vertical_gradient condition), answer out: 10.4: true at and below the first anchor, false at and above the
*> second, between them true when nextFloat of the position random of P.fromHashOf(random_name).forkPositional() is below
*> map(y, trueAt, falseAt, 1.0, 0.0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 COPY SURFACE.
 COPY DENSITY.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-H== LEADING ==XR-== BY ==WS-H-==.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-F== LEADING ==XR-== BY ==WS-F-==.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-R== LEADING ==XR-== BY ==WS-R-==.
 01 WS-NAME                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TRUE-AT             BINARY-LONG.
 01 WS-FALSE-AT            BINARY-LONG.
 01 WS-AK                  BINARY-LONG.
 01 WS-AV                  BINARY-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-FRACTION            FLOAT-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-DRAW                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 01 L-ANSWER               BINARY-LONG.
 PROCEDURE DIVISION USING L-NODE L-ANSWER.
     MOVE WGN-INT(L-NODE, 1) TO WS-AK
     MOVE WGN-INT(L-NODE, 2) TO WS-AV
     CALL "SURFACE-ANCHOR" USING WS-AK WS-AV WS-TRUE-AT
     MOVE WGN-INT(L-NODE, 3) TO WS-AK
     MOVE WGN-INT(L-NODE, 4) TO WS-AV
     CALL "SURFACE-ANCHOR" USING WS-AK WS-AV WS-FALSE-AT
     MOVE 0 TO L-ANSWER
     EVALUATE TRUE
         WHEN SC-Y <= WS-TRUE-AT
             MOVE 1 TO L-ANSWER
         WHEN SC-Y >= WS-FALSE-AT
             CONTINUE
         WHEN OTHER
             IF SF-N-VG-READY(L-NODE) = 0
                 MOVE WGN-TEXT-1(L-NODE)(1:64) TO WS-NAME
                 COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-NAME TRAILING))
                 CALL "XORO-FROM-HASH" USING DN-FACTORY WS-NAME WS-LENGTH WS-H
                 CALL "XORO-FORK-POSITIONAL" USING WS-H WS-F
                 MOVE WS-F-LO TO SF-N-VG-LO(L-NODE)
                 MOVE WS-F-HI TO SF-N-VG-HI(L-NODE)
                 MOVE 1 TO SF-N-VG-READY(L-NODE)
             END-IF
             MOVE SF-N-VG-LO(L-NODE) TO WS-F-LO
             MOVE SF-N-VG-HI(L-NODE) TO WS-F-HI
             CALL "XORO-AT" USING WS-F SC-X SC-Y SC-Z WS-R
             CALL "XORO-NEXT-FLOAT" USING WS-R WS-DRAW
             COMPUTE WS-A = SC-Y - WS-TRUE-AT
             COMPUTE WS-B = WS-FALSE-AT - WS-TRUE-AT
             CALL STATIC "cc_f64_div" USING BY REFERENCE WS-A WS-B WS-FRACTION
             CALL STATIC "cc_f64_lerp_f64" USING BY REFERENCE WS-FRACTION WS-ONE WS-ZERO WS-T
             IF WS-DRAW < WS-T
                 MOVE 1 TO L-ANSWER
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM SURFACE-GRADIENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SURFACE-COND.
*> USING job, node (a domain 3 node), result out (1 true): 10.4. References to named conditions are followed (kind 3 of the
*> store), a not flips the answer of its child.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 COPY SURFACE.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-ROWS.
    05 WS-R-NOT            BINARY-LONG.
    05 WS-R-BIOME          BINARY-LONG.
    05 WS-R-ABOVE          BINARY-LONG.
    05 WS-R-STEEP          BINARY-LONG.
    05 WS-R-HOLE           BINARY-LONG.
    05 WS-R-STONE          BINARY-LONG.
    05 WS-R-WATER          BINARY-LONG.
    05 WS-R-YABOVE         BINARY-LONG.
    05 WS-R-NOISE          BINARY-LONG.
    05 WS-R-GRADIENT       BINARY-LONG.
 01 WS-DOMAIN              BINARY-LONG VALUE 3.
 01 WS-KIND                BINARY-LONG VALUE 3.
 01 WS-NODE                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INVERT              BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-RES                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-NAME                PIC X(32).
 01 WS-D                   BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-ANCHOR              BINARY-LONG.
 01 WS-AK                  BINARY-LONG.
 01 WS-AV                  BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-RIGHT               BINARY-LONG.
 01 WS-SECOND              BINARY-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-TWO                 FLOAT-LONG VALUE 2.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-RANGE               FLOAT-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-FX                 FLOAT-LONG.
 01 WS-FZ                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 01 L-NODE                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-JOB L-NODE L-RESULT.
     IF WS-READY = 0
         MOVE "not" TO WS-NAME
         CALL "WG-TYPE-FIND" USING WS-DOMAIN WS-NAME WS-R-NOT
         MOVE "biome" TO WS-NAME
         CALL "WG-TYPE-FIND" USING WS-DOMAIN WS-NAME WS-R-BIOME
         MOVE "above_preliminary_surface" TO WS-NAME
         CALL "WG-TYPE-FIND" USING WS-DOMAIN WS-NAME WS-R-ABOVE
         MOVE "steep" TO WS-NAME
         CALL "WG-TYPE-FIND" USING WS-DOMAIN WS-NAME WS-R-STEEP
         MOVE "hole" TO WS-NAME
         CALL "WG-TYPE-FIND" USING WS-DOMAIN WS-NAME WS-R-HOLE
         MOVE "stone_depth" TO WS-NAME
         CALL "WG-TYPE-FIND" USING WS-DOMAIN WS-NAME WS-R-STONE
         MOVE "water" TO WS-NAME
         CALL "WG-TYPE-FIND" USING WS-DOMAIN WS-NAME WS-R-WATER
         MOVE "y_above" TO WS-NAME
         CALL "WG-TYPE-FIND" USING WS-DOMAIN WS-NAME WS-R-YABOVE
         MOVE "noise_threshold" TO WS-NAME
         CALL "WG-TYPE-FIND" USING WS-DOMAIN WS-NAME WS-R-NOISE
         MOVE "vertical_gradient" TO WS-NAME
         CALL "WG-TYPE-FIND" USING WS-DOMAIN WS-NAME WS-R-GRADIENT
         MOVE 1 TO WS-READY
     END-IF
     MOVE L-NODE TO WS-NODE
     MOVE 0 TO WS-INVERT WS-DONE WS-RES
     PERFORM UNTIL WS-DONE = 1
         MOVE WGN-TYPE(WS-NODE) TO WS-TYPE
         EVALUATE TRUE
             WHEN WS-TYPE = 0
                 IF SF-N-REF(WS-NODE) = 0
                     MOVE WGN-TEXT-1(WS-NODE)(1:112) TO WS-KEY
                     CALL "WG-FIND" USING WS-KIND WS-KEY SF-N-REF(WS-NODE)
                 END-IF
                 IF SF-N-REF(WS-NODE) = 0
                     MOVE 1 TO WS-DONE
                 ELSE
                     MOVE SF-N-REF(WS-NODE) TO WS-NODE
                 END-IF
             WHEN WS-TYPE = WS-R-NOT
                 COMPUTE WS-INVERT = 1 - WS-INVERT
                 MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE
             WHEN WS-TYPE = WS-R-BIOME
                 CALL "SURFACE-BIOME-IN" USING L-JOB WS-NODE WS-RES
                 MOVE 1 TO WS-DONE
             WHEN WS-TYPE = WS-R-ABOVE
                 IF SC-Y >= SC-MIN-LEVEL
                     MOVE 1 TO WS-RES
                 END-IF
                 MOVE 1 TO WS-DONE
             WHEN WS-TYPE = WS-R-STEEP
                 MOVE SC-STEEP TO WS-RES
                 MOVE 1 TO WS-DONE
             WHEN WS-TYPE = WS-R-HOLE
                 IF SC-DEPTH <= 0
                     MOVE 1 TO WS-RES
                 END-IF
                 MOVE 1 TO WS-DONE
             WHEN WS-TYPE = WS-R-STONE
*>               floor counts the solid blocks above, ceiling those below (10.4)
                 IF WGN-INT(WS-NODE, 1) = 0
                     MOVE SC-ABOVE TO WS-D
                 ELSE
                     MOVE SC-BELOW TO WS-D
                 END-IF
                 COMPUTE WS-LIMIT = 1 + WGN-INT(WS-NODE, 2)
                 IF WGN-INT(WS-NODE, 3) = 1
                     ADD SC-DEPTH TO WS-LIMIT
                 END-IF
                 IF WGN-INT(WS-NODE, 4) > 0
                     IF SC-SEC-READY = 0
                         MOVE "minecraft:surface_secondary" TO WS-KEY
                         MOVE SC-X TO WS-FX
                         MOVE SC-Z TO WS-FZ
                         CALL "SURFACE-NOISE-NAMED" USING WS-KEY WS-FX WS-ZERO WS-FZ SC-SEC
                         MOVE 1 TO SC-SEC-READY
                     END-IF
*>                   (int) map(secondary, -1.0, 1.0, 0.0, range)
                     COMPUTE WS-RANGE = WGN-INT(WS-NODE, 4)
                     CALL STATIC "cc_f64_add" USING BY REFERENCE SC-SEC WS-ONE WS-V
                     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-V WS-TWO WS-T
                     CALL STATIC "cc_f64_lerp_f64" USING BY REFERENCE WS-T WS-ZERO WS-RANGE WS-V
                     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-V WS-SECOND
                     ADD WS-SECOND TO WS-LIMIT
                 END-IF
                 IF WS-D <= WS-LIMIT
                     MOVE 1 TO WS-RES
                 END-IF
                 MOVE 1 TO WS-DONE
             WHEN WS-TYPE = WS-R-WATER
                 MOVE 1 TO WS-RES
                 IF SC-WATER-SET = 1
                     MOVE SC-Y TO WS-Y
                     IF WGN-INT(WS-NODE, 3) = 1
                         ADD SC-ABOVE TO WS-Y
                     END-IF
                     COMPUTE WS-LIMIT = SC-WATER + WGN-INT(WS-NODE, 1) + SC-DEPTH * WGN-INT(WS-NODE, 2)
                     IF WS-Y < WS-LIMIT
                         MOVE 0 TO WS-RES
                     END-IF
                 END-IF
                 MOVE 1 TO WS-DONE
             WHEN WS-TYPE = WS-R-YABOVE
                 MOVE WGN-INT(WS-NODE, 1) TO WS-AK
                 MOVE WGN-INT(WS-NODE, 2) TO WS-AV
                 CALL "SURFACE-ANCHOR" USING WS-AK WS-AV WS-ANCHOR
                 MOVE SC-Y TO WS-Y
                 IF WGN-INT(WS-NODE, 4) = 1
                     ADD SC-ABOVE TO WS-Y
                 END-IF
                 COMPUTE WS-LIMIT = WS-ANCHOR + SC-DEPTH * WGN-INT(WS-NODE, 3)
                 IF WS-Y >= WS-LIMIT
                     MOVE 1 TO WS-RES
                 END-IF
                 MOVE 1 TO WS-DONE
             WHEN WS-TYPE = WS-R-NOISE
                 IF WGN-INT(WS-NODE, 1) = 1
                     MOVE SC-Y TO WS-Y
                 ELSE
                     MOVE 0 TO WS-Y
                 END-IF
                 CALL "SURFACE-NOISE-AT" USING WS-NODE SC-X WS-Y SC-Z WS-V
                 IF WS-V >= WGN-NUM(WS-NODE, 1) AND WS-V <= WGN-NUM(WS-NODE, 2)
                     MOVE 1 TO WS-RES
                 END-IF
                 MOVE 1 TO WS-DONE
             WHEN WS-TYPE = WS-R-GRADIENT
                 CALL "SURFACE-GRADIENT" USING WS-NODE WS-RES
                 MOVE 1 TO WS-DONE
             WHEN OTHER
                 MOVE 1 TO WS-DONE
         END-EVALUATE
     END-PERFORM
     MOVE WS-RES TO L-RESULT
     IF WS-INVERT = 1
         COMPUTE L-RESULT = 1 - WS-RES
     END-IF
     GOBACK.
 END PROGRAM SURFACE-COND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SURFACE-RULE.
*> USING job, rule node (domain 2), state out (the block state the rule gives at the context position, -1 for none): 10.5. A
*> sequence tries its rules in order, a condition runs its rule when its test holds, a block is its state (the default state of the
*> named block: properties of a block rule are not applied), the band rules give the terracotta band of 10.6. The walk keeps its own
*> stack of sequences instead of recursing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 COPY SURFACE.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-ROWS.
    05 WS-R-SEQUENCE       BINARY-LONG.
    05 WS-R-CONDITION      BINARY-LONG.
    05 WS-R-BLOCK          BINARY-LONG.
    05 WS-R-BANDLANDS      BINARY-LONG.
    05 WS-R-BADLANDS       BINARY-LONG.
    05 WS-R-ORE-VEIN       BINARY-LONG.
 01 WS-DOMAIN              BINARY-LONG VALUE 2.
 01 WS-KIND                BINARY-LONG VALUE 2.
 01 WS-NAME                PIC X(32).
 01 WS-KEY                 PIC X(112).
 01 WS-KEY48               PIC X(48).
 01 WS-IGNORE              PIC X(160).
 01 WS-NODE                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-SP                  BINARY-LONG.
 01 WS-STACK.
    05 WS-NEXT             BINARY-LONG OCCURS 64 TIMES.
 01 WS-DONE                BINARY-LONG.
 01 WS-TRUE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-V                   FLOAT-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-FOUR                FLOAT-LONG VALUE 4.
 01 WS-ROUND               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 01 L-NODE                 BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-JOB L-NODE L-STATE.
     IF WS-READY = 0
         MOVE "sequence" TO WS-NAME
         CALL "WG-TYPE-FIND" USING WS-DOMAIN WS-NAME WS-R-SEQUENCE
         MOVE "condition" TO WS-NAME
         CALL "WG-TYPE-FIND" USING WS-DOMAIN WS-NAME WS-R-CONDITION
         MOVE "block" TO WS-NAME
         CALL "WG-TYPE-FIND" USING WS-DOMAIN WS-NAME WS-R-BLOCK
         MOVE "bandlands" TO WS-NAME
         CALL "WG-TYPE-FIND" USING WS-DOMAIN WS-NAME WS-R-BANDLANDS
         MOVE "badlands" TO WS-NAME
         CALL "WG-TYPE-FIND" USING WS-DOMAIN WS-NAME WS-R-BADLANDS
         MOVE "ore_vein" TO WS-NAME
         CALL "WG-TYPE-FIND" USING WS-DOMAIN WS-NAME WS-R-ORE-VEIN
         MOVE 1 TO WS-READY
     END-IF
     MOVE -1 TO L-STATE
     MOVE L-NODE TO WS-NODE
     MOVE 0 TO WS-SP WS-DONE
     PERFORM UNTIL WS-DONE = 1
         MOVE WGN-TYPE(WS-NODE) TO WS-TYPE
*>       WS-TRUE 1: the node gave no block, go on with the next rule of the enclosing sequence (the default: a type the rules
*>       below do not handle gives none); a reference that resolves and a sequence with rules go on with the node they name
         MOVE 1 TO WS-TRUE
         EVALUATE TRUE
             WHEN WS-TYPE = 0
                 IF SF-N-REF(WS-NODE) = 0
                     MOVE WGN-TEXT-1(WS-NODE)(1:112) TO WS-KEY
                     CALL "WG-FIND" USING WS-KIND WS-KEY SF-N-REF(WS-NODE)
                 END-IF
                 IF SF-N-REF(WS-NODE) NOT = 0
                     MOVE SF-N-REF(WS-NODE) TO WS-NODE
                     MOVE 0 TO WS-TRUE
                 END-IF
             WHEN WS-TYPE = WS-R-SEQUENCE
                 IF WGN-CHILD(WS-NODE, 1) NOT = 0
                     ADD 1 TO WS-SP
                     MOVE WGN-NEXT(WGN-CHILD(WS-NODE, 1)) TO WS-NEXT(WS-SP)
                     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE
                     MOVE 0 TO WS-TRUE
                 END-IF
             WHEN WS-TYPE = WS-R-CONDITION
                 CALL "SURFACE-COND" USING L-JOB WGN-CHILD(WS-NODE, 1) WS-TRUE
                 IF WS-TRUE = 1
                     MOVE WGN-CHILD(WS-NODE, 2) TO WS-NODE
                     MOVE 0 TO WS-TRUE
                 ELSE
                     MOVE 1 TO WS-TRUE
                 END-IF
             WHEN WS-TYPE = WS-R-BLOCK
                 IF SF-N-STATE(WS-NODE) = -2
                     UNSTRING WGN-TEXT-1(WS-NODE) DELIMITED BY SPACE INTO WS-KEY48 WS-IGNORE
                     CALL "GEN-BLOCK-STATE" USING WS-KEY48 SF-N-STATE(WS-NODE)
                 END-IF
                 MOVE SF-N-STATE(WS-NODE) TO L-STATE
                 MOVE 1 TO WS-DONE
             WHEN WS-TYPE = WS-R-ORE-VEIN
                 CALL "ORE-VEIN-RULE" USING L-JOB WS-NODE L-STATE
                 IF L-STATE >= 0
                     MOVE 1 TO WS-DONE
                 ELSE
                     MOVE 1 TO WS-TRUE
                 END-IF
             WHEN WS-TYPE = WS-R-BANDLANDS OR WS-TYPE = WS-R-BADLANDS
                 CALL "SURFACE-BANDS-ENSURE"
                 MOVE SC-X TO WS-X
                 MOVE SC-Z TO WS-Z
                 MOVE "minecraft:clay_bands_offset" TO WS-KEY
                 CALL "SURFACE-NOISE-NAMED" USING WS-KEY WS-X WS-ZERO WS-Z WS-V
                 CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-V WS-FOUR WS-W
                 CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-W WS-V
                 CALL STATIC "cc_f64_round_f32" USING BY REFERENCE WS-V WS-ROUND
                 COMPUTE WS-INDEX = FUNCTION MOD(SC-Y + WS-ROUND + 192, 192) + 1
                 MOVE SF-BAND(WS-INDEX) TO L-STATE
                 MOVE 1 TO WS-DONE
         END-EVALUATE
         PERFORM UNTIL WS-TRUE = 0 OR WS-DONE = 1
             IF WS-SP = 0
                 MOVE 1 TO WS-DONE
             ELSE
                 IF WS-NEXT(WS-SP) = 0
                     SUBTRACT 1 FROM WS-SP
                 ELSE
                     MOVE WS-NEXT(WS-SP) TO WS-NODE
                     MOVE WGN-NEXT(WS-NODE) TO WS-NEXT(WS-SP)
                     MOVE 0 TO WS-TRUE
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM SURFACE-RULE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SURFACE-PILLARS.
*> USING job, local x, local z: 10.7, the pillars of eroded badlands: air from the column's top up to a height the badlands
*> noises give becomes stone (nothing when water is met first).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 COPY SURFACE.
 01 WS-K1                  PIC X(112) VALUE "minecraft:badlands_surface".
 01 WS-K2                  PIC X(112) VALUE "minecraft:badlands_pillar".
 01 WS-K3                  PIC X(112) VALUE "minecraft:badlands_pillar_roof".
 01 WS-TEXTS.
    05 WS-T-1              PIC X(8) VALUE Z"8.25".
    05 WS-T-2              PIC X(8) VALUE Z"0.2".
    05 WS-T-3              PIC X(8) VALUE Z"0.75".
    05 WS-T-4              PIC X(8) VALUE Z"1.5".
 01 WS-C-825               FLOAT-LONG.
 01 WS-C-02                FLOAT-LONG.
 01 WS-C-075               FLOAT-LONG.
 01 WS-C-15                FLOAT-LONG.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-C-15F               FLOAT-LONG VALUE 15.
 01 WS-C-25                FLOAT-LONG VALUE 2.5.
 01 WS-C-50                FLOAT-LONG VALUE 50.
 01 WS-C-24                FLOAT-LONG VALUE 24.
 01 WS-C-64                FLOAT-LONG VALUE 64.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-M                   FLOAT-LONG.
 01 WS-ROOF                FLOAT-LONG.
 01 WS-E                   FLOAT-LONG.
 01 WS-TOP                 FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-TOP-Y               BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 01 L-LX                   BINARY-LONG.
 01 L-LZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-JOB L-LX L-LZ.
     IF WS-READY = 0
         CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-T-1 WS-C-825
         CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-T-2 WS-C-02
         CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-T-3 WS-C-075
         CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-T-4 WS-C-15
         MOVE 1 TO WS-READY
     END-IF
     SET ADDRESS OF CE-CHUNK TO J-ADDR
     COMPUTE WS-COL = L-LZ * 16 + L-LX + 1
     COMPUTE WS-START = J-HM-SURFACE(WS-COL) + 1
     MOVE SC-X TO WS-X
     MOVE SC-Z TO WS-Z
*>   s = |badlands_surface(x, 0, z) * 8.25|, p = (float) (badlands_pillar(x * 0.2, 0, z * 0.2) * 15.0f)
     CALL "SURFACE-NOISE-NAMED" USING WS-K1 WS-X WS-ZERO WS-Z WS-A
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-A WS-C-825 WS-B
     CALL STATIC "cc_f64_abs_f64" USING BY REFERENCE WS-B WS-S
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-X WS-C-02 WS-A
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-Z WS-C-02 WS-B
     CALL "SURFACE-NOISE-NAMED" USING WS-K2 WS-A WS-ZERO WS-B WS-P
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-P WS-C-15F WS-A
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-A WS-P
     CALL STATIC "cc_f64_min_j" USING BY REFERENCE WS-S WS-P WS-M
     IF WS-M <= 0
         GOBACK
     END-IF
*>   roof = |badlands_pillar_roof(x * 0.75, 0, z * 0.75) * 1.5|, top = 64 + min(m * m * 2.5, ceil(roof * 50) + 24)
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-X WS-C-075 WS-A
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-Z WS-C-075 WS-B
     CALL "SURFACE-NOISE-NAMED" USING WS-K3 WS-A WS-ZERO WS-B WS-ROOF
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-ROOF WS-C-15 WS-A
     CALL STATIC "cc_f64_abs_f64" USING BY REFERENCE WS-A WS-ROOF
     MOVE WS-M TO WS-E
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-M WS-E WS-A
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-A WS-C-25 WS-B
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-ROOF WS-C-50 WS-A
     CALL STATIC "cc_f64_ceil" USING BY REFERENCE WS-A WS-LIMIT
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-LIMIT WS-C-24 WS-A
     CALL STATIC "cc_f64_min_j" USING BY REFERENCE WS-B WS-A WS-LIMIT
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-C-64 WS-LIMIT WS-TOP
     CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-TOP WS-A
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-A WS-TOP-Y
     IF WS-START > WS-TOP-Y
         GOBACK
     END-IF
*>   scan down: the default block ends the scan, water ends the whole extension
     MOVE 0 TO WS-STOP WS-WATER
     PERFORM VARYING WS-Y FROM WS-TOP-Y BY -1 UNTIL WS-Y < -64 OR WS-STOP = 1
         COMPUTE WS-CELL = (WS-Y + 64) * 256 + WS-COL
         EVALUATE TRUE
             WHEN CE-STATE(WS-CELL) = SC-STONE-STATE
                 MOVE 1 TO WS-STOP
             WHEN CE-STATE(WS-CELL) = SC-WATER-STATE
                 MOVE 1 TO WS-STOP WS-WATER
         END-EVALUATE
     END-PERFORM
     IF WS-WATER = 1
         GOBACK
     END-IF
     MOVE WS-TOP-Y TO WS-Y
     COMPUTE WS-CELL = (WS-Y + 64) * 256 + WS-COL
     PERFORM UNTIL WS-Y < -64 OR CE-STATE(WS-CELL) NOT = 0
         MOVE SC-STONE-STATE TO CE-STATE(WS-CELL)
         IF WS-Y > J-HM-SURFACE(WS-COL)
             MOVE WS-Y TO J-HM-SURFACE(WS-COL)
         END-IF
         IF WS-Y > J-HM-OCEAN(WS-COL)
             MOVE WS-Y TO J-HM-OCEAN(WS-COL)
         END-IF
         SUBTRACT 1 FROM WS-Y
         COMPUTE WS-CELL = (WS-Y + 64) * 256 + WS-COL
     END-PERFORM
     GOBACK.
 END PROGRAM SURFACE-PILLARS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SURFACE-COLUMN.
*> USING job, local x, local z: the column procedure of 10.1 for one column of the chunk whose fill is done.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 COPY CBLOCKS.
 COPY DENSITY.
 COPY SURFACE.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-R== LEADING ==XR-== BY ==WS-R-==.
 01 WS-K-SURFACE           PIC X(112) VALUE "minecraft:surface".
 01 WS-ERODED              PIC X(48) VALUE "minecraft:eroded_badlands".
 01 WS-COL                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-NEIGHBOUR           BINARY-LONG.
 01 WS-GRAD-X              BINARY-LONG.
 01 WS-GRAD-Z              BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-LOWER               BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-G.
    05 WS-G-ITEM           FLOAT-LONG OCCURS 8 TIMES.
 01 WS-OP-DIV              BINARY-LONG VALUE 4.
 01 WS-SIXTEEN             FLOAT-LONG VALUE 16.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-DEPTH-SCALE         FLOAT-LONG VALUE 2.75.
 01 WS-THREE               FLOAT-LONG VALUE 3.
 01 WS-QUARTER             FLOAT-LONG VALUE 0.25.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-X-CELL              BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 01 L-LX                   BINARY-LONG.
 01 L-LZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-JOB L-LX L-LZ.
     SET ADDRESS OF CE-CHUNK TO J-ADDR
     COMPUTE WS-X = J-CX * 16 + L-LX
     COMPUTE WS-Z = J-CZ * 16 + L-LZ
     COMPUTE WS-COL = L-LZ * 16 + L-LX + 1
     MOVE WS-X TO SC-X
     MOVE WS-Z TO SC-Z
     MOVE 0 TO SC-SEC-READY
     MOVE -999 TO SC-BIO-Q
     MOVE -1 TO SC-BIO-ID
*>   the biome of the column's first free block: eroded badlands raise pillars first
     COMPUTE WS-START = J-HM-SURFACE(WS-COL) + 1
     CALL "SURFACE-BIOME-AT" USING L-JOB WS-X WS-START WS-Z WS-ID
     IF CBI-KEY(WS-ID + 1) = WS-ERODED
         CALL "SURFACE-PILLARS" USING L-JOB L-LX L-LZ
         COMPUTE WS-START = J-HM-SURFACE(WS-COL) + 1
     END-IF
*>   steep: the surface heights of the neighbours, clamped to the chunk
     COMPUTE WS-NEIGHBOUR = FUNCTION MIN(L-LX + 1, 15)
     COMPUTE WS-INDEX = L-LZ * 16 + WS-NEIGHBOUR + 1
     MOVE J-HM-SURFACE(WS-INDEX) TO WS-GRAD-X
     COMPUTE WS-NEIGHBOUR = FUNCTION MAX(L-LX - 1, 0)
     COMPUTE WS-INDEX = L-LZ * 16 + WS-NEIGHBOUR + 1
     SUBTRACT J-HM-SURFACE(WS-INDEX) FROM WS-GRAD-X
     COMPUTE WS-NEIGHBOUR = FUNCTION MIN(L-LZ + 1, 15)
     COMPUTE WS-INDEX = WS-NEIGHBOUR * 16 + L-LX + 1
     MOVE J-HM-SURFACE(WS-INDEX) TO WS-GRAD-Z
     COMPUTE WS-NEIGHBOUR = FUNCTION MAX(L-LZ - 1, 0)
     COMPUTE WS-INDEX = WS-NEIGHBOUR * 16 + L-LX + 1
     SUBTRACT J-HM-SURFACE(WS-INDEX) FROM WS-GRAD-Z
     MOVE 0 TO SC-STEEP
     IF WS-GRAD-X <= -4 OR WS-GRAD-Z >= 4
         MOVE 1 TO SC-STEEP
     END-IF
*>   surfaceDepth = (int) (surface(x, 0, z) * 2.75 + 3.0 + P.at(x, 0, z).nextDouble() * 0.25)
     MOVE WS-X TO WS-FX
     MOVE WS-Z TO WS-FZ
     CALL "SURFACE-NOISE-NAMED" USING WS-K-SURFACE WS-FX WS-ZERO WS-FZ WS-A
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-A WS-DEPTH-SCALE WS-B
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-B WS-THREE WS-C
     MOVE 0 TO WS-Y
     CALL "XORO-AT" USING DN-FACTORY WS-X WS-Y WS-Z WS-R
     CALL "XORO-NEXT-DOUBLE" USING WS-R WS-A
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-A WS-QUARTER WS-B
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-C WS-B WS-D
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-D SC-DEPTH
*>   minSurfaceLevel = floor(chunk_surface_level(x, 0, z)) + surfaceDepth - 8, the level interpolated between the corners
     CALL STATIC "cc_f64_i32_to_f32" USING BY REFERENCE L-LX WS-A
     CALL "DENSITY-F32" USING WS-OP-DIV WS-A WS-SIXTEEN WS-FX
     CALL STATIC "cc_f64_i32_to_f32" USING BY REFERENCE L-LZ WS-A
     CALL "DENSITY-F32" USING WS-OP-DIV WS-A WS-SIXTEEN WS-FZ
     MOVE J-SF-CSL(1) TO WS-G-ITEM(1) WS-G-ITEM(3)
     MOVE J-SF-CSL(2) TO WS-G-ITEM(2) WS-G-ITEM(4)
     MOVE J-SF-CSL(3) TO WS-G-ITEM(5) WS-G-ITEM(7)
     MOVE J-SF-CSL(4) TO WS-G-ITEM(6) WS-G-ITEM(8)
     CALL "NOISE-TRILERP" USING WS-FX WS-ZERO WS-FZ WS-G WS-A
     CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-A WS-B
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-B WS-LEVEL
     COMPUTE SC-MIN-LEVEL = WS-LEVEL + SC-DEPTH - 8
*>   down the column
     MOVE 0 TO SC-ABOVE SC-WATER-SET
     MOVE 999999 TO WS-LOWER
     PERFORM VARYING WS-Y FROM WS-START BY -1 UNTIL WS-Y < -64
         IF WS-Y > 319
             MOVE 0 TO WS-STATE
         ELSE
             COMPUTE WS-CELL = (WS-Y + 64) * 256 + WS-COL
             MOVE CE-STATE(WS-CELL) TO WS-STATE
         END-IF
         EVALUATE TRUE
             WHEN WS-STATE = 0
                 MOVE 0 TO SC-ABOVE SC-WATER-SET
             WHEN WS-STATE = SC-WATER-STATE OR WS-STATE = SC-LAVA-STATE
                 IF SC-WATER-SET = 0
                     COMPUTE SC-WATER = WS-Y + 1
                     MOVE 1 TO SC-WATER-SET
                 END-IF
             WHEN OTHER
                 ADD 1 TO SC-ABOVE
                 IF WS-LOWER >= WS-Y
                     COMPUTE WS-S = WS-Y - 1
                     MOVE 1 TO WS-SOLID
                     PERFORM UNTIL WS-S < -64 OR WS-SOLID = 0
                         COMPUTE WS-CELL = (WS-S + 64) * 256 + WS-COL
                         IF CE-STATE(WS-CELL) = 0 OR CE-STATE(WS-CELL) = SC-WATER-STATE
                             OR CE-STATE(WS-CELL) = SC-LAVA-STATE
                             MOVE 0 TO WS-SOLID
                         ELSE
                             SUBTRACT 1 FROM WS-S
                         END-IF
                     END-PERFORM
                     COMPUTE WS-LOWER = WS-S + 1
                 END-IF
                 COMPUTE SC-BELOW = WS-Y - WS-LOWER + 1
                 MOVE WS-Y TO SC-Y
                 CALL "SURFACE-RULE" USING L-JOB SC-ROOT WS-RESULT
                 IF WS-RESULT >= 0
                     COMPUTE WS-CELL = (WS-Y + 64) * 256 + WS-COL
                     MOVE WS-RESULT TO CE-STATE(WS-CELL)
                 END-IF
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM SURFACE-COLUMN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GEN-STAGE-SURFACE.
*> Step GJ-SUB (0 to 163) of the surface stage: the corner levels, the biome ring, then four columns per step (see the top of
*> this file). Nothing when the content holds no material rule minecraft:overworld.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENSTAGE.
 COPY SURFACE.
 COPY DENSITY.
 01 WS-KIND-RULE           BINARY-LONG VALUE 2.
 01 WS-KIND-FN             BINARY-LONG VALUE 1.
 01 WS-KEY-RULE            PIC X(112) VALUE "minecraft:overworld".
 01 WS-KEY-CSL             PIC X(112) VALUE "minecraft:overworld/chunk_surface_level".
 01 WS-KEY-STONE           PIC X(48) VALUE "minecraft:stone".
 01 WS-KEY-WATER           PIC X(48) VALUE "minecraft:water".
 01 WS-KEY-LAVA            PIC X(48) VALUE "minecraft:lava".
 01 WS-ROOT                BINARY-LONG.
 01 WS-CSL                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-LAYER               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-BIOME               PIC X(40).
 01 WS-ID                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 PROCEDURE DIVISION USING L-JOB.
     ADD 1 TO GS-SURFACE
     CALL "WG-FIND" USING WS-KIND-RULE WS-KEY-RULE WS-ROOT
     IF WS-ROOT = 0
         GOBACK
     END-IF
     EVALUATE TRUE
         WHEN J-SUB < 4
             IF J-SUB = 0
                 CALL "SURFACE-BANDS-ENSURE"
             END-IF
             CALL "WG-FIND" USING WS-KIND-FN WS-KEY-CSL WS-CSL
             MOVE 0 TO J-SF-CSL(J-SUB + 1)
             IF WS-CSL > 0
                 DIVIDE J-SUB BY 2 GIVING WS-HALF REMAINDER WS-I
                 COMPUTE WS-X = J-CX * 16 + WS-I * 16
                 COMPUTE WS-Z = J-CZ * 16 + WS-HALF * 16
                 MOVE 0 TO WS-Y
                 CALL "DENSITY-NODE" USING WS-CSL WS-X WS-Y WS-Z J-SF-CSL(J-SUB + 1)
             END-IF
         WHEN J-SUB < 100
             COMPUTE WS-LAYER = J-SUB - 4
             COMPUTE WS-QY = -16 + WS-LAYER
             PERFORM VARYING WS-RZ FROM -1 BY 1 UNTIL WS-RZ > 4
                 PERFORM VARYING WS-RX FROM -1 BY 1 UNTIL WS-RX > 4
                     IF WS-RX < 0 OR WS-RX > 3 OR WS-RZ < 0 OR WS-RZ > 3
                         COMPUTE WS-QX = J-CX * 4 + WS-RX
                         COMPUTE WS-QZ = J-CZ * 4 + WS-RZ
                         CALL "CLIMATE-BIOME-AT" USING WS-QX WS-QY WS-QZ WS-N WS-BIOME
                         CALL "SURFACE-BIOME-ID" USING WS-BIOME WS-ID
                         COMPUTE WS-INDEX = WS-LAYER * 36 + (WS-RZ + 1) * 6 + WS-RX + 2
                         COMPUTE J-SF-RING(WS-INDEX) = WS-ID + 1
                     END-IF
                 END-PERFORM
             END-PERFORM
         WHEN OTHER
             CALL "GEN-BLOCK-STATE" USING WS-KEY-STONE SC-STONE-STATE
             CALL "GEN-BLOCK-STATE" USING WS-KEY-WATER SC-WATER-STATE
             CALL "GEN-BLOCK-STATE" USING WS-KEY-LAVA SC-LAVA-STATE
             MOVE WS-ROOT TO SC-ROOT
             MOVE 1 TO DNG-ACTIVE
             COMPUTE DNG-X0 = J-CX * 16
             COMPUTE DNG-Z0 = J-CZ * 16
             SET DNG-PTR TO ADDRESS OF J-GRID
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 3
                 COMPUTE WS-N = (J-SUB - 100) * 4 + WS-I
                 DIVIDE WS-N BY 16 GIVING WS-LX REMAINDER WS-LZ
                 CALL "SURFACE-COLUMN" USING L-JOB WS-LX WS-LZ
             END-PERFORM
             MOVE 0 TO DNG-ACTIVE
     END-EVALUATE
     GOBACK.
 END PROGRAM GEN-STAGE-SURFACE.
