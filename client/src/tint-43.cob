*> Tint sources (docs/protocol/43-tint-sources.md): the block tint source table and the colour of a
*> face (sections 1 and 2), the colormaps and biome colours (3), the biome blend (4), the colour
*> fields (5), banner and map colours (6), item tints (7) and the dye, team and mob effect colour
*> tables (8 to 10). Colours are ARGB in a BINARY-DOUBLE (client/copy/CLTINT.cpy).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-BLOCK-SOURCE.
*> Section 2.1 (BlockColors.createDefault) and section 1 item 2: USING block name (PIC X(32), space
*> padded), tint index, source kind out (TS-*, TS-NONE when the block has no source at that index
*> or the index is at or beyond the list), constant 1 out, constant 2 out (ARGB).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLTINT.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(32).
 01 L-INDEX                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-C1                   BINARY-DOUBLE.
 01 L-C2                   BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-NAME L-INDEX L-KIND L-C1 L-C2.
     MOVE TS-NONE TO L-KIND
     MOVE 4294967295 TO L-C1 L-C2
     IF L-INDEX < 0
         GOBACK
     END-IF
     EVALUATE L-NAME
         WHEN "tall_grass"
         WHEN "large_fern"
             IF L-INDEX = 0
                 MOVE TS-DOUBLE-TALL-GRASS TO L-KIND
             END-IF
         WHEN "fern"
         WHEN "short_grass"
         WHEN "potted_fern"
         WHEN "bush"
             IF L-INDEX = 0
                 MOVE TS-GRASS TO L-KIND
             END-IF
         WHEN "grass_block"
             IF L-INDEX = 0
                 MOVE TS-GRASS-BLOCK TO L-KIND
             END-IF
         WHEN "pink_petals"
         WHEN "wildflowers"
             EVALUATE L-INDEX
                 WHEN 0
                     MOVE TS-CONSTANT TO L-KIND
                 WHEN 1
                     MOVE TS-GRASS TO L-KIND
             END-EVALUATE
         WHEN "spruce_leaves"
             IF L-INDEX = 0
                 MOVE TS-CONSTANT TO L-KIND
                 MOVE 4284586337 TO L-C1
             END-IF
         WHEN "birch_leaves"
             IF L-INDEX = 0
                 MOVE TS-CONSTANT TO L-KIND
                 MOVE 4286621525 TO L-C1
             END-IF
         WHEN "oak_leaves"
         WHEN "jungle_leaves"
         WHEN "acacia_leaves"
         WHEN "dark_oak_leaves"
         WHEN "vine"
         WHEN "mangrove_leaves"
             IF L-INDEX = 0
                 MOVE TS-FOLIAGE TO L-KIND
             END-IF
         WHEN "leaf_litter"
             IF L-INDEX = 0
                 MOVE TS-DRY-FOLIAGE TO L-KIND
             END-IF
         WHEN "water_cauldron"
             IF L-INDEX = 0
                 MOVE TS-WATER TO L-KIND
             END-IF
         WHEN "water"
         WHEN "bubble_column"
             IF L-INDEX = 0
                 MOVE TS-WATER-PARTICLES TO L-KIND
             END-IF
         WHEN "redstone_wire"
             IF L-INDEX = 0
                 MOVE TS-REDSTONE TO L-KIND
             END-IF
         WHEN "sugar_cane"
             IF L-INDEX = 0
                 MOVE TS-SUGAR-CANE TO L-KIND
             END-IF
         WHEN "attached_melon_stem"
         WHEN "attached_pumpkin_stem"
             IF L-INDEX = 0
                 MOVE TS-CONSTANT TO L-KIND
                 MOVE 4292921116 TO L-C1
             END-IF
         WHEN "melon_stem"
         WHEN "pumpkin_stem"
             IF L-INDEX = 0
                 MOVE TS-STEM TO L-KIND
             END-IF
         WHEN "lily_pad"
             IF L-INDEX = 0
                 MOVE TS-CONSTANT-2 TO L-KIND
                 MOVE 4285645660 TO L-C1
                 MOVE 4280320048 TO L-C2
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM TINT-BLOCK-SOURCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-MULTIPLY.
*> Section 1 item 4 (QuadInstance.multiplyColor): USING colour a, colour b, product out; each of
*> alpha, red, green and blue is a x b div 255.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   BINARY-DOUBLE.
 01 WS-B                   BINARY-DOUBLE.
 01 WS-SHIFT               BINARY-DOUBLE.
 01 WS-CA                  BINARY-DOUBLE.
 01 WS-CB                  BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-A                    BINARY-DOUBLE.
 01 L-B                    BINARY-DOUBLE.
 01 L-OUT                  BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-A L-B L-OUT.
     MOVE L-A TO WS-A
     MOVE L-B TO WS-B
     MOVE 0 TO L-OUT
     MOVE 1 TO WS-SHIFT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         COMPUTE WS-CA = FUNCTION MOD(WS-A, 256)
         COMPUTE WS-CB = FUNCTION MOD(WS-B, 256)
         COMPUTE WS-A = (WS-A - WS-CA) / 256
         COMPUTE WS-B = (WS-B - WS-CB) / 256
         COMPUTE WS-CA = WS-CA * WS-CB
         DIVIDE WS-CA BY 255 GIVING WS-CA
         COMPUTE L-OUT = L-OUT + WS-CA * WS-SHIFT
         COMPUTE WS-SHIFT = WS-SHIFT * 256
     END-PERFORM
     GOBACK.
 END PROGRAM TINT-MULTIPLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-SOURCE-COLOR.
*> Sections 1 and 2: USING CLIENT-STATE, source kind, constant 1, constant 2, TINT-QUERY (mode,
*> properties and position); sets TQ-COLOUR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLTINT.
 01 WS-RES                 BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-MAP                 BINARY-LONG VALUE 1.
 01 WS-DEF-T               COMP-2 VALUE 0.5.
 01 WS-DEF-D               COMP-2 VALUE 1.0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-KIND                 BINARY-LONG.
 01 L-C1                   BINARY-DOUBLE.
 01 L-C2                   BINARY-DOUBLE.
 COPY CLTINTQ REPLACING ==TINT-QUERY== BY ==L-QUERY== LEADING ==TQ-== BY ==QY-==.
 PROCEDURE DIVISION USING CLIENT-STATE L-KIND L-C1 L-C2 L-QUERY.
     MOVE 4294967295 TO QY-COLOUR
     EVALUATE L-KIND
         WHEN TS-CONSTANT
             MOVE L-C1 TO QY-COLOUR
         WHEN TS-CONSTANT-2
             IF QY-MODE = 0
                 MOVE L-C1 TO QY-COLOUR
             ELSE
                 MOVE L-C2 TO QY-COLOUR
             END-IF
         WHEN TS-GRASS-BLOCK
             EVALUATE QY-MODE
                 WHEN 0
                     CALL "TINT-COLORMAP" USING WS-MAP WS-DEF-T WS-DEF-D QY-COLOUR
                 WHEN 1
                     MOVE 1 TO WS-RES
                     CALL "TINT-AVERAGE" USING CLIENT-STATE WS-RES QY-X QY-Y QY-Z QY-RADIUS
                         QY-COLOUR
                 WHEN OTHER
                     MOVE 4294967295 TO QY-COLOUR
             END-EVALUATE
         WHEN TS-GRASS
             IF QY-MODE = 0
                 CALL "TINT-COLORMAP" USING WS-MAP WS-DEF-T WS-DEF-D QY-COLOUR
             ELSE
                 MOVE 1 TO WS-RES
                 CALL "TINT-AVERAGE" USING CLIENT-STATE WS-RES QY-X QY-Y QY-Z QY-RADIUS
                     QY-COLOUR
             END-IF
         WHEN TS-DOUBLE-TALL-GRASS
             IF QY-MODE = 0
                 CALL "TINT-COLORMAP" USING WS-MAP WS-DEF-T WS-DEF-D QY-COLOUR
             ELSE
                 MOVE 1 TO WS-RES
                 MOVE QY-Y TO WS-Y
                 IF QY-HALF = 1
                     SUBTRACT 1 FROM WS-Y
                 END-IF
                 CALL "TINT-AVERAGE" USING CLIENT-STATE WS-RES QY-X WS-Y QY-Z QY-RADIUS
                     QY-COLOUR
             END-IF
         WHEN TS-SUGAR-CANE
             IF QY-MODE NOT = 0
                 MOVE 1 TO WS-RES
                 CALL "TINT-AVERAGE" USING CLIENT-STATE WS-RES QY-X QY-Y QY-Z QY-RADIUS
                     QY-COLOUR
             END-IF
         WHEN TS-FOLIAGE
             IF QY-MODE = 0
                 MOVE 4282955032 TO QY-COLOUR
             ELSE
                 MOVE 2 TO WS-RES
                 CALL "TINT-AVERAGE" USING CLIENT-STATE WS-RES QY-X QY-Y QY-Z QY-RADIUS
                     QY-COLOUR
             END-IF
         WHEN TS-DRY-FOLIAGE
             IF QY-MODE = 0
                 MOVE 4284234802 TO QY-COLOUR
             ELSE
                 MOVE 3 TO WS-RES
                 CALL "TINT-AVERAGE" USING CLIENT-STATE WS-RES QY-X QY-Y QY-Z QY-RADIUS
                     QY-COLOUR
             END-IF
         WHEN TS-WATER
             IF QY-MODE NOT = 0
                 MOVE 4 TO WS-RES
                 CALL "TINT-AVERAGE" USING CLIENT-STATE WS-RES QY-X QY-Y QY-Z QY-RADIUS
                     QY-COLOUR
             END-IF
         WHEN TS-WATER-PARTICLES
             IF QY-MODE = 2
                 MOVE 4 TO WS-RES
                 CALL "TINT-AVERAGE" USING CLIENT-STATE WS-RES QY-X QY-Y QY-Z QY-RADIUS
                     QY-COLOUR
             END-IF
         WHEN TS-REDSTONE
             CALL "TINT-REDSTONE" USING QY-POWER QY-COLOUR
         WHEN TS-STEM
             CALL "TINT-STEM" USING QY-AGE QY-COLOUR
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM TINT-SOURCE-COLOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-BLOCK-COLOR.
*> Section 1 items 1 and 2: USING CLIENT-STATE, TINT-QUERY; TQ-COLOUR is the colour of source
*> TQ-INDEX of block TQ-NAME, opaque white when the block has no such source.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                BINARY-LONG.
 01 WS-C1                  BINARY-DOUBLE.
 01 WS-C2                  BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY CLTINTQ REPLACING ==TINT-QUERY== BY ==L-QUERY== LEADING ==TQ-== BY ==QY-==.
 PROCEDURE DIVISION USING CLIENT-STATE L-QUERY.
     CALL "TINT-BLOCK-SOURCE" USING QY-NAME QY-INDEX WS-KIND WS-C1 WS-C2
     CALL "TINT-SOURCE-COLOR" USING CLIENT-STATE WS-KIND WS-C1 WS-C2 L-QUERY
     GOBACK.
 END PROGRAM TINT-BLOCK-COLOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-REDSTONE.
*> Section 2.2: USING power (0 to 15), colour out; the 16 rows of the table, alpha 255.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TABLE               PIC X(96) VALUE
     "4C0000700000" & "7A0000840000" & "8E0000990000" & "A30000AD0000"
     & "B70000C10000" & "CC0000D60000" & "E00000EA0600" & "F41B00FF3200".
 01 WS-ROWS REDEFINES WS-TABLE.
    05 WS-ROW              PIC X(6) OCCURS 16 TIMES.
 01 WS-HEX                 PIC X(16) VALUE "0123456789ABCDEF".
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-POWER                BINARY-LONG.
 01 L-COLOUR               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-POWER L-COLOUR.
     COMPUTE WS-P = FUNCTION MAX(0, FUNCTION MIN(15, L-POWER))
     MOVE 255 TO L-COLOUR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE 0 TO WS-D
         INSPECT WS-HEX TALLYING WS-D FOR CHARACTERS BEFORE INITIAL WS-ROW(WS-P + 1)(WS-I:1)
         COMPUTE L-COLOUR = L-COLOUR * 16 + WS-D
     END-PERFORM
     GOBACK.
 END PROGRAM TINT-REDSTONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-STEM.
*> Section 2.3: USING age (0 to 7), colour out: red age x 32, green 255 - age x 8, blue age x 4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-COLOUR               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-AGE L-COLOUR.
     COMPUTE WS-A = FUNCTION MAX(0, FUNCTION MIN(7, L-AGE))
     COMPUTE L-COLOUR = 4278190080 + WS-A * 32 * 65536 + (255 - WS-A * 8) * 256 + WS-A * 4
     GOBACK.
 END PROGRAM TINT-STEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-PARTICLE-RGB.
*> Section 2.4: USING CLIENT-STATE, TINT-QUERY, red, green, blue out (COMP-2, 0 to 1): a terrain
*> particle starts at 0.6 grey and, when index 0 of the block has a source, each channel is
*> multiplied by the byte of the terrain particle colour divided by 255.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLTINT.
 01 WS-COLOUR              BINARY-DOUBLE.
 01 WS-KIND                BINARY-LONG.
 01 WS-C1                  BINARY-DOUBLE.
 01 WS-C2                  BINARY-DOUBLE.
 01 WS-CH                  BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY CLTINTQ REPLACING ==TINT-QUERY== BY ==L-QUERY== LEADING ==TQ-== BY ==QY-==.
 01 L-R                    COMP-2.
 01 L-G                    COMP-2.
 01 L-B                    COMP-2.
 PROCEDURE DIVISION USING CLIENT-STATE L-QUERY L-R L-G L-B.
     MOVE 0 TO QY-INDEX
     MOVE 2 TO QY-MODE
     MOVE 0.6 TO L-R L-G L-B
     CALL "TINT-BLOCK-SOURCE" USING QY-NAME QY-INDEX WS-KIND WS-C1 WS-C2
     IF WS-KIND NOT = TS-NONE
         CALL "TINT-BLOCK-COLOR" USING CLIENT-STATE L-QUERY
         MOVE QY-COLOUR TO WS-COLOUR
         COMPUTE WS-CH = WS-COLOUR / 65536
         COMPUTE WS-CH = FUNCTION MOD(WS-CH, 256)
         COMPUTE L-R = 0.6 * WS-CH / 255
         COMPUTE WS-CH = WS-COLOUR / 256
         COMPUTE WS-CH = FUNCTION MOD(WS-CH, 256)
         COMPUTE L-G = 0.6 * WS-CH / 255
         COMPUTE WS-CH = FUNCTION MOD(WS-COLOUR, 256)
         COMPUTE L-B = 0.6 * WS-CH / 255
     END-IF
     GOBACK.
 END PROGRAM TINT-PARTICLE-RGB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-COLORMAP.
*> Section 3.1 (ColorMapColorUtil.get): USING map (1 grass, 2 foliage, 3 dry foliage), temperature,
*> downfall (COMP-2, already clamped), colour out: d' = d x t; x = truncate((1 - t) x 255);
*> y = truncate((1 - d') x 255); the pixel y x 256 + x of the map, or the default colour (grass
*> FFFF00FF, foliage FF48B518, dry foliage FF5C3C32) when the index is outside the map.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLTINT.
 01 WS-DD                  COMP-2.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-MAP                  BINARY-LONG.
 01 L-T                    COMP-2.
 01 L-D                    COMP-2.
 01 L-COLOUR               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-MAP L-T L-D L-COLOUR.
     COMPUTE WS-DD = L-D * L-T
     COMPUTE WS-X = FUNCTION INTEGER-PART((1 - L-T) * 255)
     COMPUTE WS-Y = FUNCTION INTEGER-PART((1 - WS-DD) * 255)
     COMPUTE WS-INDEX = WS-Y * 256 + WS-X
     EVALUATE L-MAP
         WHEN 1
             MOVE 4294902015 TO L-COLOUR
             IF WS-INDEX >= 0 AND WS-INDEX < 65536
                 MOVE TT-MAP-GRASS(WS-INDEX + 1) TO L-COLOUR
             END-IF
         WHEN 2
             MOVE 4282955032 TO L-COLOUR
             IF WS-INDEX >= 0 AND WS-INDEX < 65536
                 MOVE TT-MAP-FOLIAGE(WS-INDEX + 1) TO L-COLOUR
             END-IF
         WHEN OTHER
             MOVE 4284234802 TO L-COLOUR
             IF WS-INDEX >= 0 AND WS-INDEX < 65536
                 MOVE TT-MAP-DRY(WS-INDEX + 1) TO L-COLOUR
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM TINT-COLORMAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-LEGACY-NEXT.
*> The java.util.Random step (10 §2: LegacyRandomSource): USING seed (48 bits, updated), bits (at
*> most 31), value out: seed = (seed x 0x5DEECE66D + 11) mod 2^48, value = seed >> (48 - bits).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MULT                BINARY-DOUBLE VALUE 25214903917.
 01 WS-LO                  BINARY-DOUBLE.
 01 WS-HI                  BINARY-DOUBLE.
 01 WS-HIPART              BINARY-DOUBLE.
 01 WS-TWO24               BINARY-DOUBLE VALUE 16777216.
 01 WS-TWO48               BINARY-DOUBLE VALUE 281474976710656.
 01 WS-DIV                 BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-BITS                 BINARY-LONG.
 01 L-VALUE                BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-SEED L-BITS L-VALUE.
     COMPUTE WS-LO = FUNCTION MOD(L-SEED, WS-TWO24)
     COMPUTE WS-HI = (L-SEED - WS-LO) / WS-TWO24
     COMPUTE WS-HIPART = FUNCTION MOD(WS-HI * WS-MULT, WS-TWO24)
     COMPUTE L-SEED = FUNCTION MOD(WS-LO * WS-MULT + WS-HIPART * WS-TWO24 + 11, WS-TWO48)
     COMPUTE WS-DIV = 2 ** (48 - L-BITS)
     COMPUTE L-VALUE = L-SEED / WS-DIV
     GOBACK.
 END PROGRAM TINT-LEGACY-NEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-SIMPLEX.
*> Section 3.3 and 10 §3.5: the 2D simplex noise BIOME_INFO_NOISE = SimplexNoise(Legacy(2345), true):
*> USING x, y (COMP-2), noise out (COMP-2). The permutation is built on the first call (three
*> offset draws that are multiplied by 0, then the shuffle of 256 entries).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-BITS                BINARY-LONG.
 01 WS-VALUE               BINARY-DOUBLE.
 01 WS-BOUND               BINARY-LONG.
 01 WS-VAL                 BINARY-LONG.
 01 WS-SWAP                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-PERM                BINARY-LONG OCCURS 256 TIMES.
 01 WS-F2                  COMP-2.
 01 WS-G2                  COMP-2.
 01 WS-S                   COMP-2.
 01 WS-T                   COMP-2.
 01 WS-X0                  COMP-2.
 01 WS-Y0                  COMP-2.
 01 WS-X1                  COMP-2.
 01 WS-Y1                  COMP-2.
 01 WS-X2                  COMP-2.
 01 WS-Y2                  COMP-2.
 01 WS-IF                  BINARY-LONG.
 01 WS-JF                  BINARY-LONG.
 01 WS-I1                  BINARY-LONG.
 01 WS-J1                  BINARY-LONG.
 01 WS-II                  BINARY-LONG.
 01 WS-JJ                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-G                   BINARY-LONG OCCURS 3 TIMES.
 01 WS-N                   COMP-2 OCCURS 3 TIMES.
 01 WS-C                   COMP-2.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-PX                  COMP-2.
 01 WS-PY                  COMP-2.
 01 WS-K                   BINARY-LONG.
 01 WS-GRADTAB.
    05 WS-GX-T             BINARY-LONG OCCURS 12 TIMES.
    05 WS-GY-T             BINARY-LONG OCCURS 12 TIMES.
 LINKAGE SECTION.
 01 L-X                    COMP-2.
 01 L-Y                    COMP-2.
 01 L-NOISE                COMP-2.
 PROCEDURE DIVISION USING L-X L-Y L-NOISE.
     IF WS-READY = 0
         MOVE 1 TO WS-READY
         MOVE 25214906180 TO WS-SEED
         MOVE 26 TO WS-BITS
         CALL "TINT-LEGACY-NEXT" USING WS-SEED WS-BITS WS-VALUE
         MOVE 27 TO WS-BITS
         CALL "TINT-LEGACY-NEXT" USING WS-SEED WS-BITS WS-VALUE
         MOVE 26 TO WS-BITS
         CALL "TINT-LEGACY-NEXT" USING WS-SEED WS-BITS WS-VALUE
         MOVE 27 TO WS-BITS
         CALL "TINT-LEGACY-NEXT" USING WS-SEED WS-BITS WS-VALUE
         MOVE 26 TO WS-BITS
         CALL "TINT-LEGACY-NEXT" USING WS-SEED WS-BITS WS-VALUE
         MOVE 27 TO WS-BITS
         CALL "TINT-LEGACY-NEXT" USING WS-SEED WS-BITS WS-VALUE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
             COMPUTE WS-PERM(WS-I) = WS-I - 1
         END-PERFORM
         MOVE 31 TO WS-BITS
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 255
             COMPUTE WS-BOUND = 256 - WS-I
             CALL "TINT-LEGACY-NEXT" USING WS-SEED WS-BITS WS-VALUE
             IF WS-BOUND = 256 OR 128 OR 64 OR 32 OR 16 OR 8 OR 4 OR 2 OR 1
                 COMPUTE WS-J = (WS-BOUND * WS-VALUE) / 2147483648
             ELSE
*>               nextInt's rejection loop never runs for this fixed seed (checked against the reference).
                 COMPUTE WS-VAL = FUNCTION MOD(WS-VALUE, WS-BOUND)
                 MOVE WS-VAL TO WS-J
             END-IF
             MOVE WS-PERM(WS-I + 1) TO WS-SWAP
             MOVE WS-PERM(WS-I + WS-J + 1) TO WS-PERM(WS-I + 1)
             MOVE WS-SWAP TO WS-PERM(WS-I + WS-J + 1)
         END-PERFORM
         MOVE 1 TO WS-GX-T(1)  MOVE 1 TO WS-GY-T(1)
         MOVE -1 TO WS-GX-T(2) MOVE 1 TO WS-GY-T(2)
         MOVE 1 TO WS-GX-T(3)  MOVE -1 TO WS-GY-T(3)
         MOVE -1 TO WS-GX-T(4) MOVE -1 TO WS-GY-T(4)
         MOVE 1 TO WS-GX-T(5)  MOVE 0 TO WS-GY-T(5)
         MOVE -1 TO WS-GX-T(6) MOVE 0 TO WS-GY-T(6)
         MOVE 1 TO WS-GX-T(7)  MOVE 0 TO WS-GY-T(7)
         MOVE -1 TO WS-GX-T(8) MOVE 0 TO WS-GY-T(8)
         MOVE 0 TO WS-GX-T(9)  MOVE 1 TO WS-GY-T(9)
         MOVE 0 TO WS-GX-T(10) MOVE -1 TO WS-GY-T(10)
         MOVE 0 TO WS-GX-T(11) MOVE 1 TO WS-GY-T(11)
         MOVE 0 TO WS-GX-T(12) MOVE -1 TO WS-GY-T(12)
         COMPUTE WS-F2 = 0.5 * (FUNCTION SQRT(3) - 1)
         COMPUTE WS-G2 = (3 - FUNCTION SQRT(3)) / 6
     END-IF
     COMPUTE WS-S = (L-X + L-Y) * WS-F2
     COMPUTE WS-IF = FUNCTION INTEGER(L-X + WS-S)
     COMPUTE WS-JF = FUNCTION INTEGER(L-Y + WS-S)
     COMPUTE WS-T = (WS-IF + WS-JF) * WS-G2
     COMPUTE WS-X0 = L-X - (WS-IF - WS-T)
     COMPUTE WS-Y0 = L-Y - (WS-JF - WS-T)
     IF WS-X0 > WS-Y0
         MOVE 1 TO WS-I1
         MOVE 0 TO WS-J1
     ELSE
         MOVE 0 TO WS-I1
         MOVE 1 TO WS-J1
     END-IF
     COMPUTE WS-X1 = WS-X0 - WS-I1 + WS-G2
     COMPUTE WS-Y1 = WS-Y0 - WS-J1 + WS-G2
     COMPUTE WS-X2 = WS-X0 - 1 + 2 * WS-G2
     COMPUTE WS-Y2 = WS-Y0 - 1 + 2 * WS-G2
     COMPUTE WS-II = FUNCTION MOD(WS-IF, 256)
     COMPUTE WS-JJ = FUNCTION MOD(WS-JF, 256)
*>   Corner 1: perm(ii + perm(jj)), corner 2: perm(ii + i1 + perm(jj + j1)), corner 3 at (1, 1).
     COMPUTE WS-A = FUNCTION MOD(WS-JJ, 256)
     COMPUTE WS-A = FUNCTION MOD(WS-II + WS-PERM(WS-A + 1), 256)
     COMPUTE WS-G(1) = FUNCTION MOD(WS-PERM(WS-A + 1), 12)
     COMPUTE WS-A = FUNCTION MOD(WS-JJ + WS-J1, 256)
     COMPUTE WS-A = FUNCTION MOD(WS-II + WS-I1 + WS-PERM(WS-A + 1), 256)
     COMPUTE WS-G(2) = FUNCTION MOD(WS-PERM(WS-A + 1), 12)
     COMPUTE WS-A = FUNCTION MOD(WS-JJ + 1, 256)
     COMPUTE WS-A = FUNCTION MOD(WS-II + 1 + WS-PERM(WS-A + 1), 256)
     COMPUTE WS-G(3) = FUNCTION MOD(WS-PERM(WS-A + 1), 12)
     MOVE WS-X0 TO WS-PX
     MOVE WS-Y0 TO WS-PY
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
         EVALUATE WS-K
             WHEN 2
                 MOVE WS-X1 TO WS-PX
                 MOVE WS-Y1 TO WS-PY
             WHEN 3
                 MOVE WS-X2 TO WS-PX
                 MOVE WS-Y2 TO WS-PY
         END-EVALUATE
         COMPUTE WS-C = 0.5 - WS-PX * WS-PX - WS-PY * WS-PY
         IF WS-C < 0
             MOVE 0 TO WS-N(WS-K)
         ELSE
             COMPUTE WS-A = WS-G(WS-K) + 1
             COMPUTE WS-N(WS-K) = WS-C * WS-C * WS-C * WS-C
                 * (WS-GX-T(WS-A) * WS-PX + WS-GY-T(WS-A) * WS-PY)
         END-IF
     END-PERFORM
     COMPUTE L-NOISE = 70.0 * (WS-N(1) + WS-N(2) + WS-N(3))
     GOBACK.
 END PROGRAM TINT-SIMPLEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-BIOME-COLOR.
*> Sections 3.2 and 3.3 (Biome): USING resolver (1 grass, 2 foliage, 3 dry foliage, 4 water), biome
*> id, block x, block z, colour out. Climate values are clamped to 0..1 as floats and widened.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLTINT.
 01 WS-I                   BINARY-LONG.
 01 WS-T                   COMP-2.
 01 WS-D                   COMP-2.
 01 WS-MAP                 BINARY-LONG.
 01 WS-BASE                BINARY-DOUBLE.
 01 WS-RGB                 BINARY-DOUBLE.
 01 WS-CR                  BINARY-LONG.
 01 WS-CG                  BINARY-LONG.
 01 WS-CB                  BINARY-LONG.
 01 WS-NX                  COMP-2.
 01 WS-NZ                  COMP-2.
 01 WS-NOISE               COMP-2.
 LINKAGE SECTION.
 01 L-RESOLVER             BINARY-LONG.
 01 L-BIOME                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-COLOUR               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-RESOLVER L-BIOME L-X L-Z L-COLOUR.
     COMPUTE WS-I = L-BIOME + 1
     MOVE TB-TEMP(WS-I) TO WS-T
     MOVE TB-DOWN(WS-I) TO WS-D
     IF WS-T < 0
         MOVE 0 TO WS-T
     END-IF
     IF WS-T > 1
         MOVE 1 TO WS-T
     END-IF
     IF WS-D < 0
         MOVE 0 TO WS-D
     END-IF
     IF WS-D > 1
         MOVE 1 TO WS-D
     END-IF
     EVALUATE L-RESOLVER
         WHEN 2
             IF TB-FOLIAGE(WS-I) >= 0
                 MOVE TB-FOLIAGE(WS-I) TO L-COLOUR
             ELSE
                 MOVE 2 TO WS-MAP
                 CALL "TINT-COLORMAP" USING WS-MAP WS-T WS-D L-COLOUR
             END-IF
         WHEN 3
             IF TB-DRY(WS-I) >= 0
                 MOVE TB-DRY(WS-I) TO L-COLOUR
             ELSE
                 MOVE 3 TO WS-MAP
                 CALL "TINT-COLORMAP" USING WS-MAP WS-T WS-D L-COLOUR
             END-IF
         WHEN 4
             MOVE TB-WATER(WS-I) TO L-COLOUR
         WHEN OTHER
             IF TB-GRASS(WS-I) >= 0
                 MOVE TB-GRASS(WS-I) TO WS-BASE
             ELSE
                 MOVE 1 TO WS-MAP
                 CALL "TINT-COLORMAP" USING WS-MAP WS-T WS-D WS-BASE
             END-IF
             MOVE WS-BASE TO L-COLOUR
             EVALUATE TB-MOD(WS-I)
                 WHEN 1
                     COMPUTE WS-RGB = FUNCTION MOD(WS-BASE, 16777216)
                     COMPUTE WS-CR = WS-RGB / 65536
                     COMPUTE WS-CG = FUNCTION MOD(WS-RGB, 65536)
                     COMPUTE WS-CG = WS-CG / 256
                     COMPUTE WS-CB = FUNCTION MOD(WS-RGB, 256)
                     COMPUTE WS-RGB = (WS-CR - FUNCTION MOD(WS-CR, 2)) * 65536
                         + (WS-CG - FUNCTION MOD(WS-CG, 2)) * 256
                         + WS-CB - FUNCTION MOD(WS-CB, 2) + 2634762
                     DIVIDE WS-RGB BY 2 GIVING WS-RGB
                     COMPUTE L-COLOUR = 4278190080 + WS-RGB
                 WHEN 2
                     COMPUTE WS-NX = L-X * 0.0225
                     COMPUTE WS-NZ = L-Z * 0.0225
                     CALL "TINT-SIMPLEX" USING WS-NX WS-NZ WS-NOISE
                     IF WS-NOISE < -0.1
                         MOVE 4283201084 TO L-COLOUR
                     ELSE
                         MOVE 4285165625 TO L-COLOUR
                     END-IF
             END-EVALUATE
     END-EVALUATE
     GOBACK.
 END PROGRAM TINT-BIOME-COLOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-BIOME-AT.
*> Section 4 (the level's getBiome, without the fuzzy zoom of 10 §7.7): USING CLIENT-STATE, block x,
*> y, z, biome id out: the replica's biome of the 4 x 4 x 4 cell holding the block; a position in a
*> chunk that is not loaded, or outside the world's height, is the plains biome.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CELLS.
 COPY CLTINT.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BIOME                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z L-BIOME.
     MOVE TT-PLAINS TO L-BIOME
     COMPUTE WS-CX = FUNCTION INTEGER(L-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-Z / 16)
     COMPUTE WS-LY = L-Y - PL-MIN-Y
     CALL "WORLD-ROW" USING CLIENT-STATE WS-CX WS-CZ WS-ROW
     IF WS-ROW > 0 AND WS-LY >= 0 AND WS-LY < PL-HEIGHT
         SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
         COMPUTE WS-LX = (L-X - WS-CX * 16) / 4
         COMPUTE WS-LZ = (L-Z - WS-CZ * 16) / 4
         COMPUTE WS-LY = WS-LY / 4
         COMPUTE WS-I = WS-LY * 16 + WS-LZ * 4 + WS-LX + 1
         MOVE CE-BIOME(WS-I) TO L-BIOME
     END-IF
     GOBACK.
 END PROGRAM TINT-BIOME-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-AVERAGE.
*> Section 4 (ClientLevel.calculateBlockTint): USING CLIENT-STATE, resolver (1 grass, 2 foliage,
*> 3 dry foliage, 4 water), block x, y, z, radius (0 to 7), colour out. Radius 0 is the resolver's
*> colour of the position's biome as it is; a larger radius averages the (2r + 1)^2 columns at the
*> same y, each channel summed and divided with integer division, alpha 255.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BIOME               BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-COLOUR              BINARY-DOUBLE.
 01 WS-CH                  BINARY-DOUBLE.
 01 WS-SUM                 BINARY-DOUBLE OCCURS 3 TIMES.
 01 WS-N                   BINARY-LONG.
 01 WS-RAD                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-RESOLVER             BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 01 L-COLOUR               BINARY-DOUBLE.
 PROCEDURE DIVISION USING CLIENT-STATE L-RESOLVER L-X L-Y L-Z L-RADIUS L-COLOUR.
     COMPUTE WS-RAD = FUNCTION MAX(0, FUNCTION MIN(7, L-RADIUS))
     IF WS-RAD = 0
         CALL "TINT-BIOME-AT" USING CLIENT-STATE L-X L-Y L-Z WS-BIOME
         CALL "TINT-BIOME-COLOR" USING L-RESOLVER WS-BIOME L-X L-Z L-COLOUR
         GOBACK
     END-IF
     MOVE 0 TO WS-SUM(1) WS-SUM(2) WS-SUM(3)
     PERFORM VARYING WS-DX FROM 0 BY 1 UNTIL WS-DX > 2 * WS-RAD
         PERFORM VARYING WS-DZ FROM 0 BY 1 UNTIL WS-DZ > 2 * WS-RAD
             COMPUTE WS-PX = L-X - WS-RAD + WS-DX
             COMPUTE WS-PZ = L-Z - WS-RAD + WS-DZ
             CALL "TINT-BIOME-AT" USING CLIENT-STATE WS-PX L-Y WS-PZ WS-BIOME
             CALL "TINT-BIOME-COLOR" USING L-RESOLVER WS-BIOME WS-PX WS-PZ WS-COLOUR
             COMPUTE WS-CH = WS-COLOUR / 65536
             COMPUTE WS-CH = FUNCTION MOD(WS-CH, 256)
             ADD WS-CH TO WS-SUM(1)
             COMPUTE WS-CH = WS-COLOUR / 256
             COMPUTE WS-CH = FUNCTION MOD(WS-CH, 256)
             ADD WS-CH TO WS-SUM(2)
             COMPUTE WS-CH = FUNCTION MOD(WS-COLOUR, 256)
             ADD WS-CH TO WS-SUM(3)
         END-PERFORM
     END-PERFORM
     COMPUTE WS-N = (2 * WS-RAD + 1) * (2 * WS-RAD + 1)
     DIVIDE WS-SUM(1) BY WS-N GIVING WS-SUM(1)
     DIVIDE WS-SUM(2) BY WS-N GIVING WS-SUM(2)
     DIVIDE WS-SUM(3) BY WS-N GIVING WS-SUM(3)
     COMPUTE L-COLOUR = 4278190080 + WS-SUM(1) * 65536 + WS-SUM(2) * 256 + WS-SUM(3)
     GOBACK.
 END PROGRAM TINT-AVERAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-COLOR-PARSE.
*> Section 5, colour field syntax: USING kind, text (the JSON value as text, PIC X(64)), its length,
*> colour out (ARGB), ok out (1 when the text is a colour of that kind).
*>   kind 1 STRING_RGB_COLOR: "#RRGGBB" made opaque, an integer as written, [r, g, b] floats;
*>   kind 2 RGB_COLOR_CODEC: an integer as written or [r, g, b] floats (alpha 255);
*>   kind 3 ARGB_COLOR_CODEC: an integer or [r, g, b, a] floats;
*>   kind 4 STRING_ARGB_COLOR: "#AARRGGBB" or an integer.
*> A float channel is floor(v x 255) kept within 0..255. An integer may be signed 32-bit or unsigned.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HEXDIGITS           PIC X(16) VALUE "0123456789ABCDEF".
 01 WS-UP                  PIC X(64).
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-V                   BINARY-DOUBLE.
 01 WS-DOTS                BINARY-LONG.
 01 WS-INNER               PIC X(64).
 01 WS-TOKENS.
    05 WS-TOKEN            PIC X(24) OCCURS 5 TIMES.
 01 WS-COUNT               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-CH                  BINARY-LONG OCCURS 4 TIMES.
 01 WS-F                   COMP-2.
 01 WS-BAD                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-COLOUR               BINARY-DOUBLE.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-TEXT L-LENGTH L-COLOUR L-OK.
     MOVE 0 TO L-OK L-COLOUR
     MOVE FUNCTION UPPER-CASE(L-TEXT) TO WS-UP
     EVALUATE TRUE
         WHEN L-TEXT(1:1) = "#"
             IF (L-KIND = 1 AND L-LENGTH = 7) OR (L-KIND = 4 AND L-LENGTH = 9)
                 MOVE 0 TO WS-V WS-BAD
                 PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > L-LENGTH
                     MOVE 0 TO WS-D
                     INSPECT WS-HEXDIGITS TALLYING WS-D FOR CHARACTERS
                         BEFORE INITIAL WS-UP(WS-I:1)
                     IF WS-D > 15
                         MOVE 1 TO WS-BAD
                     END-IF
                     COMPUTE WS-V = WS-V * 16 + WS-D
                 END-PERFORM
                 IF WS-BAD = 0
                     MOVE 1 TO L-OK
                     MOVE WS-V TO L-COLOUR
                     IF L-KIND = 1
                         ADD 4278190080 TO L-COLOUR
                     END-IF
                 END-IF
             END-IF
         WHEN L-TEXT(1:1) = "["
             COMPUTE WS-WANT = 3
             IF L-KIND = 3
                 MOVE 4 TO WS-WANT
             END-IF
             IF L-KIND NOT = 4 AND L-LENGTH > 2 AND L-TEXT(L-LENGTH:1) = "]"
                 MOVE SPACES TO WS-INNER WS-TOKENS
                 COMPUTE WS-D = L-LENGTH - 2
                 MOVE L-TEXT(2:WS-D) TO WS-INNER
                 MOVE 0 TO WS-COUNT
                 UNSTRING WS-INNER DELIMITED BY "," INTO WS-TOKEN(1) WS-TOKEN(2) WS-TOKEN(3)
                     WS-TOKEN(4) WS-TOKEN(5) TALLYING IN WS-COUNT
                 MOVE 0 TO WS-BAD
                 IF WS-COUNT = WS-WANT
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-WANT
                         IF FUNCTION TEST-NUMVAL(WS-TOKEN(WS-I)) NOT = 0
                             MOVE 1 TO WS-BAD
                         END-IF
                     END-PERFORM
                     IF WS-BAD = 0
                         MOVE 255 TO WS-CH(4)
                         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-WANT
                             COMPUTE WS-F = FUNCTION NUMVAL(WS-TOKEN(WS-I)) * 255
                             COMPUTE WS-CH(WS-I) = FUNCTION MAX(0,
                                 FUNCTION MIN(255, FUNCTION INTEGER(WS-F)))
                         END-PERFORM
                         MOVE 1 TO L-OK
                         COMPUTE L-COLOUR = WS-CH(4) * 16777216 + WS-CH(1) * 65536
                             + WS-CH(2) * 256 + WS-CH(3)
                     END-IF
                 END-IF
             END-IF
         WHEN OTHER
             MOVE 0 TO WS-DOTS
             INSPECT L-TEXT(1:L-LENGTH) TALLYING WS-DOTS FOR ALL "." ALL "E" ALL "e"
             IF WS-DOTS = 0 AND FUNCTION TEST-NUMVAL(L-TEXT(1:L-LENGTH)) = 0
                 COMPUTE WS-V = FUNCTION NUMVAL(L-TEXT(1:L-LENGTH))
                 IF WS-V >= -2147483648 AND WS-V <= 4294967295
                     IF WS-V < 0
                         ADD 4294967296 TO WS-V
                     END-IF
                     MOVE 1 TO L-OK
                     MOVE WS-V TO L-COLOUR
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM TINT-COLOR-PARSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-ATTRIBUTE-DEFAULT.
*> Section 5 and 12 §3.1: USING attribute name (PIC X(64)), colour out: the default of a colour
*> attribute (fog #000000, water fog #050533, sky #000000, all opaque); 0 for any other name.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(64).
 01 L-COLOUR               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-NAME L-COLOUR.
     EVALUATE L-NAME
         WHEN "minecraft:visual/fog_color"
         WHEN "minecraft:visual/sky_color"
             MOVE 4278190080 TO L-COLOUR
         WHEN "minecraft:visual/water_fog_color"
             MOVE 4278519091 TO L-COLOUR
         WHEN OTHER
             MOVE 0 TO L-COLOUR
     END-EVALUATE
     GOBACK.
 END PROGRAM TINT-ATTRIBUTE-DEFAULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-BIOME-SET.
*> Sections 3.2 and 5: USING biome id, temperature, downfall (COMP-2, stored as floats), water,
*> grass, foliage, dry foliage colours (ARGB, -1 for an absent override), grass colour modifier
*> name (PIC X(16): none, dark_forest, swamp). Fills the row of the biome table and counts it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLTINT.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-BIOME                BINARY-LONG.
 01 L-T                    COMP-2.
 01 L-D                    COMP-2.
 01 L-WATER                BINARY-DOUBLE.
 01 L-GRASS                BINARY-DOUBLE.
 01 L-FOLIAGE              BINARY-DOUBLE.
 01 L-DRY                  BINARY-DOUBLE.
 01 L-MOD                  PIC X(16).
 PROCEDURE DIVISION USING L-BIOME L-T L-D L-WATER L-GRASS L-FOLIAGE L-DRY L-MOD.
     COMPUTE WS-I = L-BIOME + 1
     MOVE L-T TO TB-TEMP(WS-I)
     MOVE L-D TO TB-DOWN(WS-I)
     MOVE L-WATER TO TB-WATER(WS-I)
     MOVE L-GRASS TO TB-GRASS(WS-I)
     MOVE L-FOLIAGE TO TB-FOLIAGE(WS-I)
     MOVE L-DRY TO TB-DRY(WS-I)
     EVALUATE L-MOD
         WHEN "dark_forest"
             MOVE 1 TO TB-MOD(WS-I)
         WHEN "swamp"
             MOVE 2 TO TB-MOD(WS-I)
         WHEN OTHER
             MOVE 0 TO TB-MOD(WS-I)
     END-EVALUATE
     IF WS-I > TT-BIOMES
         MOVE WS-I TO TT-BIOMES
     END-IF
     GOBACK.
 END PROGRAM TINT-BIOME-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-BIOME-FOG.
*> USING biome id, water fog colour (ARGB, 0 = none), water fog end distance multiplier (COMP-2, 0 = none): the attributes
*> visual/water_fog_color and the multiply argument of visual/water_fog_end_distance of the biome's row (43 section 5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLTINT.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-BIOME                BINARY-LONG.
 01 L-COLOUR               BINARY-DOUBLE.
 01 L-END                  COMP-2.
 PROCEDURE DIVISION USING L-BIOME L-COLOUR L-END.
     COMPUTE WS-I = L-BIOME + 1
     MOVE L-COLOUR TO TB-FOG(WS-I)
     MOVE L-END TO TB-FOG-END(WS-I)
     GOBACK.
 END PROGRAM TINT-BIOME-FOG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-HEX6.
*> USING six hex digits (PIC X(6)), value out (BINARY-DOUBLE): the number they spell.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIGITS              PIC X(16) VALUE "0123456789ABCDEF".
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(6).
 01 L-VALUE                BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-TEXT L-VALUE.
     MOVE 0 TO L-VALUE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE 0 TO WS-D
         INSPECT WS-DIGITS TALLYING WS-D FOR CHARACTERS BEFORE INITIAL L-TEXT(WS-I:1)
         COMPUTE L-VALUE = L-VALUE * 16 + WS-D
     END-PERFORM
     GOBACK.
 END PROGRAM TINT-HEX6.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-DYE.
*> Section 8 (DyeColor, 16 in declaration order): USING dye id (0 to 15), column (1 diffuse, 2
*> firework, 3 text), colour out: diffuse and text are opaque ARGB, the firework colour is the raw
*> RGB (alpha 0); an id outside 0 to 15 gives 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIFFUSE             PIC X(96) VALUE
     "F9FFFEF9801DC74EBD3AB3DAFED83D80C71FF38BAA474F529D9D97169C9C" &
     "8932B83C44AA8354325E7C16B02E261D1D21".
 01 WS-DIFFUSE-R REDEFINES WS-DIFFUSE.
    05 WS-DIF              PIC X(6) OCCURS 16 TIMES.
 01 WS-FIREWORK            PIC X(96) VALUE
     "F0F0F0EB8844C354CD6689D3DECF2A41CD34D88198434343ABABAB287697" &
     "7B2FBE25319251301A3B511AB3312C1E1B1B".
 01 WS-FIREWORK-R REDEFINES WS-FIREWORK.
    05 WS-FW               PIC X(6) OCCURS 16 TIMES.
 01 WS-TEXT                PIC X(96) VALUE
     "FFFFFFFF681FFF00FF9AC0CDFFFF00BFFF00FF69B4808080D3D3D300FFFF" &
     "A020F00000FF8B451300FF00FF0000000000".
 01 WS-TEXT-R REDEFINES WS-TEXT.
    05 WS-TX               PIC X(6) OCCURS 16 TIMES.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-COLUMN               BINARY-LONG.
 01 L-COLOUR               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-ID L-COLUMN L-COLOUR.
     MOVE 0 TO L-COLOUR
     IF L-ID >= 0 AND L-ID <= 15
         EVALUATE L-COLUMN
             WHEN 1
                 CALL "TINT-HEX6" USING WS-DIF(L-ID + 1) L-COLOUR
                 ADD 4278190080 TO L-COLOUR
             WHEN 2
                 CALL "TINT-HEX6" USING WS-FW(L-ID + 1) L-COLOUR
             WHEN OTHER
                 CALL "TINT-HEX6" USING WS-TX(L-ID + 1) L-COLOUR
                 ADD 4278190080 TO L-COLOUR
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM TINT-DYE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-DYE-MAP.
*> Section 8: USING dye id, variant (0 getMapColor, 1 getTerracottaColor), MapColor name out
*> (PIC X(24)); NONE for an id outside 0 to 15.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MAPNAMES            PIC X(384) VALUE
     "SNOW                    " &
     "COLOR_ORANGE            " &
     "COLOR_MAGENTA           " &
     "COLOR_LIGHT_BLUE        " &
     "COLOR_YELLOW            " &
     "COLOR_LIGHT_GREEN       " &
     "COLOR_PINK              " &
     "COLOR_GRAY              " &
     "COLOR_LIGHT_GRAY        " &
     "COLOR_CYAN              " &
     "COLOR_PURPLE            " &
     "COLOR_BLUE              " &
     "COLOR_BROWN             " &
     "COLOR_GREEN             " &
     "COLOR_RED               " &
     "COLOR_BLACK             ".
 01 WS-MAPNAMES-R REDEFINES WS-MAPNAMES.
    05 WS-MN               PIC X(24) OCCURS 16 TIMES.
 01 WS-TERRA               PIC X(384) VALUE
     "TERRACOTTA_WHITE        " &
     "TERRACOTTA_ORANGE       " &
     "TERRACOTTA_MAGENTA      " &
     "TERRACOTTA_LIGHT_BLUE   " &
     "TERRACOTTA_YELLOW       " &
     "TERRACOTTA_LIGHT_GREEN  " &
     "TERRACOTTA_PINK         " &
     "TERRACOTTA_GRAY         " &
     "TERRACOTTA_LIGHT_GRAY   " &
     "TERRACOTTA_CYAN         " &
     "TERRACOTTA_PURPLE       " &
     "TERRACOTTA_BLUE         " &
     "TERRACOTTA_BROWN        " &
     "TERRACOTTA_GREEN        " &
     "TERRACOTTA_RED          " &
     "TERRACOTTA_BLACK        ".
 01 WS-TERRA-R REDEFINES WS-TERRA.
    05 WS-TN               PIC X(24) OCCURS 16 TIMES.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-VARIANT              BINARY-LONG.
 01 L-NAME                 PIC X(24).
 PROCEDURE DIVISION USING L-ID L-VARIANT L-NAME.
     MOVE "NONE" TO L-NAME
     IF L-ID >= 0 AND L-ID <= 15
         IF L-VARIANT = 0
             MOVE WS-MN(L-ID + 1) TO L-NAME
         ELSE
             MOVE WS-TN(L-ID + 1) TO L-NAME
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TINT-DYE-MAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-TEAM.
*> Section 9 (TeamColor, 16 in enum order): USING team colour id (0 to 15), colour out: the raw RGB
*> (alpha 0) of the chat text colour; opaque white (-1) for an id outside 0 to 15 (no team colour).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TEAMS               PIC X(96) VALUE
     "0000000000AA00AA0000AAAAAA0000AA00AAFFAA00AAAAAA5555555555FF" &
     "55FF5555FFFFFF5555FF55FFFFFF55FFFFFF".
 01 WS-TEAMS-R REDEFINES WS-TEAMS.
    05 WS-TEAM             PIC X(6) OCCURS 16 TIMES.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-COLOUR               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-ID L-COLOUR.
     MOVE 4294967295 TO L-COLOUR
     IF L-ID >= 0 AND L-ID <= 15
         CALL "TINT-HEX6" USING WS-TEAM(L-ID + 1) L-COLOUR
     END-IF
     GOBACK.
 END PROGRAM TINT-TEAM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-TEAM-ID.
*> Section 9: USING colour name (PIC X(15): black, dark_blue, ... white), id out (-1 when unknown).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES               PIC X(240) VALUE
     "black          " &
     "dark_blue      " &
     "dark_green     " &
     "dark_aqua      " &
     "dark_red       " &
     "dark_purple    " &
     "gold           " &
     "gray           " &
     "dark_gray      " &
     "blue           " &
     "green          " &
     "aqua           " &
     "red            " &
     "light_purple   " &
     "yellow         " &
     "white          ".
 01 WS-NAMES-R REDEFINES WS-NAMES.
    05 WS-TNAME            PIC X(15) OCCURS 16 TIMES.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(15).
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-ID.
     MOVE -1 TO L-ID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         IF WS-TNAME(WS-I) = L-NAME
             COMPUTE L-ID = WS-I - 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TINT-TEAM-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-EFFECT.
*> Section 10 (MobEffects, 40 in registration order): USING effect id (0 to 39), colour out: the
*> raw RGB (alpha 0); 0 for an id outside 0 to 39.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EFFECTS             PIC X(240) VALUE
     "33EBFF8BAFE0D9C0434A4217FFC700F82423A9656AFDFF84551D4ACD5CAB" &
     "9146F0FF990098DAC0F6F6F61F1F23C2FF66587653484D4887A363736156" &
     "F87D232552A5F8242394A061CEFFFF59C106C0A44DF3CFB91DC2D188A3BE" &
     "0B613844FF4429272116A6A6DE4058BDC9FF78695A99FFA38C9B8C00FFEE".
 01 WS-EFFECTS-R REDEFINES WS-EFFECTS.
    05 WS-EFF              PIC X(6) OCCURS 40 TIMES.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-COLOUR               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-ID L-COLOUR.
     MOVE 0 TO L-COLOUR
     IF L-ID >= 0 AND L-ID <= 39
         CALL "TINT-HEX6" USING WS-EFF(L-ID + 1) L-COLOUR
     END-IF
     GOBACK.
 END PROGRAM TINT-EFFECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-EFFECT-ID.
*> Section 10: USING effect name without namespace (PIC X(24)), id out (-1 when unknown).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES               PIC X(960) VALUE
     "speed                   " &
     "slowness                " &
     "haste                   " &
     "mining_fatigue          " &
     "strength                " &
     "instant_health          " &
     "instant_damage          " &
     "jump_boost              " &
     "nausea                  " &
     "regeneration            " &
     "resistance              " &
     "fire_resistance         " &
     "water_breathing         " &
     "invisibility            " &
     "blindness               " &
     "night_vision            " &
     "hunger                  " &
     "weakness                " &
     "poison                  " &
     "wither                  " &
     "health_boost            " &
     "absorption              " &
     "saturation              " &
     "glowing                 " &
     "levitation              " &
     "luck                    " &
     "unluck                  " &
     "slow_falling            " &
     "conduit_power           " &
     "dolphins_grace          " &
     "bad_omen                " &
     "hero_of_the_village     " &
     "darkness                " &
     "trial_omen              " &
     "raid_omen               " &
     "wind_charged            " &
     "weaving                 " &
     "oozing                  " &
     "infested                " &
     "breath_of_the_nautilus  ".
 01 WS-NAMES-R REDEFINES WS-NAMES.
    05 WS-ENAME            PIC X(24) OCCURS 40 TIMES.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(24).
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-ID.
     MOVE -1 TO L-ID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         IF WS-ENAME(WS-I) = L-NAME
             COMPUTE L-ID = WS-I - 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TINT-EFFECT-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-BANNER-LAYER.
*> Section 6.1 (BannerRenderer): USING layer order (0 the pole and flag models, 1 the base colour
*> layer, 2 to 17 the up to 16 pattern layers), dye id, colour out: order 0 and any order past 17
*> are untinted (-1); the others are the dye's diffuse colour.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COLUMN              BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ORDER                BINARY-LONG.
 01 L-DYE                  BINARY-LONG.
 01 L-COLOUR               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-ORDER L-DYE L-COLOUR.
     MOVE 4294967295 TO L-COLOUR
     IF L-ORDER >= 1 AND L-ORDER <= 17
         CALL "TINT-DYE" USING L-DYE WS-COLUMN L-COLOUR
     END-IF
     GOBACK.
 END PROGRAM TINT-BANNER-LAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-MAP-PACK.
*> Section 6.2: USING base colour id, brightness id (0 LOW, 1 NORMAL, 2 HIGH, 3 LOWEST), packed id
*> out: base x 4 + brightness.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BASE                 BINARY-LONG.
 01 L-BRIGHT               BINARY-LONG.
 01 L-PACKED               BINARY-LONG.
 PROCEDURE DIVISION USING L-BASE L-BRIGHT L-PACKED.
     COMPUTE L-PACKED = L-BASE * 4 + L-BRIGHT
     GOBACK.
 END PROGRAM TINT-MAP-PACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-MAP-COLOR.
*> Section 6.2 (MapColor.getColorFromPackedId; the table of 24-1 §8.1): USING packed id (masked to
*> 0..255), colour out: 0 for NONE (base id 0) and for an undefined id (62 and above); else the
*> opaque base colour with each channel scaled by the modifier (180, 220, 255, 135) div 255.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COLOURS             PIC X(372) VALUE
     "0000007FB238F7E9A3C7C7C7FF0000A0A0FFA7A7A7007C00FFFFFFA4A8B8" &
     "976D4D7070704040FF8F7748FFFCF5D87F33B24CD86699D8E5E5337FCC19" &
     "F27FA54C4C4C9999994C7F997F3FB2334CB2664C33667F33993333191919" &
     "FAEE4D5CDBD54A80FF00D93A815631700200D1B1A19F522495576C706C8A" &
     "BA8524677535A04D4E392923876B62575C5C7A49584C3E5C4C32234C522A" &
     "8E3C2E251610BD3031943F615C191D167E863A8E8C562C3E14B485646464" &
     "D8AF937FA796".
 01 WS-COLOURS-R REDEFINES WS-COLOURS.
    05 WS-BASE             PIC X(6) OCCURS 62 TIMES.
 01 WS-MODS                PIC X(12) VALUE "180220255135".
 01 WS-MODS-R REDEFINES WS-MODS.
    05 WS-MOD              PIC 999 OCCURS 4 TIMES.
 01 WS-BYTE                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-RGB                 BINARY-DOUBLE.
 01 WS-CH                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-PACKED               BINARY-LONG.
 01 L-COLOUR               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-PACKED L-COLOUR.
     MOVE 0 TO L-COLOUR
     COMPUTE WS-BYTE = FUNCTION MOD(L-PACKED, 256)
     COMPUTE WS-ID = WS-BYTE / 4
     COMPUTE WS-B = FUNCTION MOD(WS-BYTE, 4) + 1
     IF WS-ID >= 1 AND WS-ID <= 61
         CALL "TINT-HEX6" USING WS-BASE(WS-ID + 1) WS-RGB
         MOVE 4278190080 TO L-COLOUR
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
             COMPUTE WS-CH = WS-RGB / (256 ** (2 - WS-I))
             COMPUTE WS-CH = FUNCTION MOD(WS-CH, 256)
             COMPUTE WS-CH = WS-CH * WS-MOD(WS-B)
             DIVIDE WS-CH BY 255 GIVING WS-CH
             COMPUTE L-COLOUR = L-COLOUR + WS-CH * (256 ** (2 - WS-I))
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM TINT-MAP-COLOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-MAP-BRIGHTNESS.
*> Section 6.2 (MapItem.update): USING water flag (1 when the winning colour is WATER), water depth,
*> average height, previous row's average height (COMP-2), scale S, par = (i + j) AND 1, brightness
*> id out. Water: v = depth x 0.1 + par x 0.2, HIGH below 0.5, LOW above 0.9, else NORMAL. Other:
*> v = ((avg - prev) x 4.0) / (S + 4) + (par - 0.5) x 0.4, HIGH above 0.6, LOW below -0.6, else
*> NORMAL; each operation is one IEEE double step in this order.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   COMP-2.
 01 WS-B                   COMP-2.
 01 WS-V                   COMP-2.
 01 WS-HIGH                COMP-2 VALUE 0.6.
 01 WS-LOW                 COMP-2 VALUE -0.6.
 01 WS-WH                  COMP-2 VALUE 0.5.
 01 WS-WL                  COMP-2 VALUE 0.9.
 01 WS-DEP                 COMP-2.
 01 WS-PAR                 COMP-2.
 01 WS-S                   COMP-2.
 01 WS-TENTH               COMP-2 VALUE 0.1.
 01 WS-FIFTH               COMP-2 VALUE 0.2.
 01 WS-DITHER              COMP-2 VALUE 0.4.
 01 WS-HALF                COMP-2 VALUE 0.5.
 01 WS-FOUR                COMP-2 VALUE 4.0.
 LINKAGE SECTION.
 01 L-WATER                BINARY-LONG.
 01 L-DEPTH                BINARY-LONG.
 01 L-AVG                  COMP-2.
 01 L-PREV                 COMP-2.
 01 L-SCALE                BINARY-LONG.
 01 L-PAR                  BINARY-LONG.
 01 L-BRIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING L-WATER L-DEPTH L-AVG L-PREV L-SCALE L-PAR L-BRIGHT.
     MOVE L-DEPTH TO WS-DEP
     MOVE L-PAR TO WS-PAR
     MOVE L-SCALE TO WS-S
     MOVE 1 TO L-BRIGHT
     IF L-WATER = 1
         COMPUTE WS-A = WS-DEP * WS-TENTH
         COMPUTE WS-B = WS-PAR * WS-FIFTH
         COMPUTE WS-V = WS-A + WS-B
         IF WS-V < WS-WH
             MOVE 2 TO L-BRIGHT
         END-IF
         IF WS-V > WS-WL
             MOVE 0 TO L-BRIGHT
         END-IF
     ELSE
         COMPUTE WS-A = L-AVG - L-PREV
         COMPUTE WS-A = WS-A * WS-FOUR
         COMPUTE WS-B = WS-S + 4
         COMPUTE WS-A = WS-A / WS-B
         COMPUTE WS-B = WS-PAR - WS-HALF
         COMPUTE WS-B = WS-B * WS-DITHER
         COMPUTE WS-V = WS-A + WS-B
         IF WS-V > WS-HIGH
             MOVE 2 TO L-BRIGHT
         END-IF
         IF WS-V < WS-LOW
             MOVE 0 TO L-BRIGHT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TINT-MAP-BRIGHTNESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-ITEM-SOURCE.
*> Section 7.1 (the shipped item definitions with tints): USING item name (PIC X(32)), whether the
*> stack has dyed_color (matters for wolf_armor only), layer index, TINT-ITEM: sets TI-TYPE (0 when
*> the layer is untinted: unlisted items and a layer past the list), TI-VALUE (constant), TI-DEFAULT
*> and the grass climate of that layer's source.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(32).
 01 L-DYED                 BINARY-LONG.
 01 L-LAYER                BINARY-LONG.
 COPY CLTINTI.
 PROCEDURE DIVISION USING L-NAME L-DYED L-LAYER TINT-ITEM.
     INITIALIZE TINT-ITEM
     MOVE -1 TO TI-CUSTOM TI-TEAM-ID
     IF L-LAYER < 0
         GOBACK
     END-IF
     EVALUATE L-NAME
         WHEN "oak_leaves"
         WHEN "acacia_leaves"
         WHEN "dark_oak_leaves"
         WHEN "jungle_leaves"
         WHEN "vine"
             IF L-LAYER = 0
                 MOVE 1 TO TI-TYPE
                 MOVE 4282955032 TO TI-VALUE
             END-IF
         WHEN "spruce_leaves"
             IF L-LAYER = 0
                 MOVE 1 TO TI-TYPE
                 MOVE 4284586337 TO TI-VALUE
             END-IF
         WHEN "birch_leaves"
             IF L-LAYER = 0
                 MOVE 1 TO TI-TYPE
                 MOVE 4286621525 TO TI-VALUE
             END-IF
         WHEN "mangrove_leaves"
             IF L-LAYER = 0
                 MOVE 1 TO TI-TYPE
                 MOVE 4287809096 TO TI-VALUE
             END-IF
         WHEN "lily_pad"
             IF L-LAYER = 0
                 MOVE 1 TO TI-TYPE
                 MOVE 4285645660 TO TI-VALUE
             END-IF
         WHEN "grass_block"
         WHEN "short_grass"
         WHEN "fern"
         WHEN "tall_grass"
         WHEN "large_fern"
         WHEN "bush"
             IF L-LAYER = 0
                 MOVE 3 TO TI-TYPE
                 MOVE 0.5 TO TI-TEMP
                 MOVE 1.0 TO TI-DOWN
             END-IF
         WHEN "leather_helmet"
         WHEN "leather_chestplate"
         WHEN "leather_leggings"
         WHEN "leather_boots"
         WHEN "leather_horse_armor"
             IF L-LAYER = 0
                 MOVE 2 TO TI-TYPE
                 MOVE 4288701760 TO TI-DEFAULT
             END-IF
         WHEN "wolf_armor"
             IF L-DYED = 1
                 EVALUATE L-LAYER
                     WHEN 0
                         MOVE 1 TO TI-TYPE
                         MOVE 4294967295 TO TI-VALUE
                     WHEN 1
                         MOVE 2 TO TI-TYPE
                         MOVE 0 TO TI-DEFAULT
                 END-EVALUATE
             END-IF
         WHEN "potion"
         WHEN "splash_potion"
         WHEN "lingering_potion"
         WHEN "tipped_arrow"
             IF L-LAYER = 0
                 MOVE 5 TO TI-TYPE
                 MOVE 4281884102 TO TI-DEFAULT
             END-IF
         WHEN "firework_star"
             EVALUATE L-LAYER
                 WHEN 0
                     MOVE 1 TO TI-TYPE
                     MOVE 4294967295 TO TI-VALUE
                 WHEN 1
                     MOVE 4 TO TI-TYPE
                     MOVE 4287269514 TO TI-DEFAULT
             END-EVALUATE
     END-EVALUATE
     GOBACK.
 END PROGRAM TINT-ITEM-SOURCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-POTION-COLOR.
*> Section 7.3 (PotionContents.getColor): USING TINT-ITEM, colour out (RGB), found out (0 when the
*> weighted effect total is 0, so the caller's default applies): the custom colour, else the
*> visible effects' colours weighted by amplifier + 1, each channel divided by the total weight.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-SUM                 BINARY-LONG OCCURS 3 TIMES.
 01 WS-RGB                 BINARY-DOUBLE.
 01 WS-CH                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLTINTI.
 01 L-COLOUR               BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING TINT-ITEM L-COLOUR L-FOUND.
     MOVE 0 TO L-COLOUR L-FOUND WS-TOTAL WS-SUM(1) WS-SUM(2) WS-SUM(3)
     IF TI-CUSTOM >= 0
         COMPUTE L-COLOUR = FUNCTION MOD(TI-CUSTOM, 16777216)
         MOVE 1 TO L-FOUND
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TI-EFF-COUNT
         IF TI-EFF-VISIBLE(WS-I) = 1
             CALL "TINT-EFFECT" USING TI-EFF-ID(WS-I) WS-RGB
             COMPUTE WS-W = TI-EFF-AMP(WS-I) + 1
             ADD WS-W TO WS-TOTAL
             COMPUTE WS-CH = WS-RGB / 65536
             COMPUTE WS-SUM(1) = WS-SUM(1) + WS-CH * WS-W
             COMPUTE WS-CH = FUNCTION MOD(WS-RGB, 65536)
             COMPUTE WS-CH = WS-CH / 256
             COMPUTE WS-SUM(2) = WS-SUM(2) + WS-CH * WS-W
             COMPUTE WS-CH = FUNCTION MOD(WS-RGB, 256)
             COMPUTE WS-SUM(3) = WS-SUM(3) + WS-CH * WS-W
         END-IF
     END-PERFORM
     IF WS-TOTAL > 0
         DIVIDE WS-SUM(1) BY WS-TOTAL GIVING WS-SUM(1)
         DIVIDE WS-SUM(2) BY WS-TOTAL GIVING WS-SUM(2)
         DIVIDE WS-SUM(3) BY WS-TOTAL GIVING WS-SUM(3)
         COMPUTE L-COLOUR = WS-SUM(1) * 65536 + WS-SUM(2) * 256 + WS-SUM(3)
         MOVE 1 TO L-FOUND
     END-IF
     GOBACK.
 END PROGRAM TINT-POTION-COLOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-ITEM-COLOR.
*> Section 7: USING TINT-ITEM; sets TI-COLOUR by the source type (constant, dye, grass, firework,
*> potion, team, custom_model_data); an unknown type is untinted (-1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MAP                 BINARY-LONG VALUE 1.
 01 WS-RGB                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SUM                 BINARY-LONG OCCURS 3 TIMES.
 01 WS-CH                  BINARY-LONG.
 01 WS-TEAM                BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY CLTINTI.
 PROCEDURE DIVISION USING TINT-ITEM.
     MOVE 4294967295 TO TI-COLOUR
     EVALUATE TI-TYPE
         WHEN 1
             COMPUTE TI-COLOUR = 4278190080 + FUNCTION MOD(TI-VALUE, 16777216)
         WHEN 2
             IF TI-HAS-DYE = 1
                 COMPUTE TI-COLOUR = 4278190080 + TI-DYE-RGB
             ELSE
                 MOVE TI-DEFAULT TO TI-COLOUR
             END-IF
         WHEN 3
             CALL "TINT-COLORMAP" USING WS-MAP TI-TEMP TI-DOWN TI-COLOUR
         WHEN 4
             IF TI-FW-COUNT = 0
                 MOVE TI-DEFAULT TO TI-COLOUR
             ELSE
                 MOVE 0 TO WS-SUM(1) WS-SUM(2) WS-SUM(3)
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TI-FW-COUNT
                     COMPUTE WS-CH = TI-FW-RGB(WS-I) / 65536
                     ADD WS-CH TO WS-SUM(1)
                     COMPUTE WS-CH = FUNCTION MOD(TI-FW-RGB(WS-I), 65536)
                     COMPUTE WS-CH = WS-CH / 256
                     ADD WS-CH TO WS-SUM(2)
                     COMPUTE WS-CH = FUNCTION MOD(TI-FW-RGB(WS-I), 256)
                     ADD WS-CH TO WS-SUM(3)
                 END-PERFORM
                 DIVIDE WS-SUM(1) BY TI-FW-COUNT GIVING WS-SUM(1)
                 DIVIDE WS-SUM(2) BY TI-FW-COUNT GIVING WS-SUM(2)
                 DIVIDE WS-SUM(3) BY TI-FW-COUNT GIVING WS-SUM(3)
                 COMPUTE TI-COLOUR = 4278190080 + WS-SUM(1) * 65536 + WS-SUM(2) * 256 + WS-SUM(3)
             END-IF
         WHEN 5
             MOVE 0 TO WS-FOUND
             IF TI-HAS-POTION = 1
                 CALL "TINT-POTION-COLOR" USING TINT-ITEM WS-RGB WS-FOUND
             END-IF
             IF WS-FOUND = 1
                 COMPUTE TI-COLOUR = 4278190080 + WS-RGB
             ELSE
                 COMPUTE TI-COLOUR = 4278190080 + FUNCTION MOD(TI-DEFAULT, 16777216)
             END-IF
         WHEN 6
             MOVE 0 TO WS-FOUND
             IF TI-TEAM-ID >= 0 AND TI-TEAM-ID <= 15
                 CALL "TINT-TEAM" USING TI-TEAM-ID WS-TEAM
                 COMPUTE TI-COLOUR = 4278190080 + WS-TEAM
             ELSE
                 COMPUTE TI-COLOUR = 4278190080 + FUNCTION MOD(TI-DEFAULT, 16777216)
             END-IF
         WHEN 7
             IF TI-INDEX >= 0 AND TI-INDEX < TI-CMD-COUNT
                 COMPUTE TI-COLOUR = 4278190080
                     + FUNCTION MOD(TI-CMD-COLOUR(TI-INDEX + 1), 16777216)
             ELSE
                 COMPUTE TI-COLOUR = 4278190080 + FUNCTION MOD(TI-DEFAULT, 16777216)
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM TINT-ITEM-COLOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-ARMOUR-LAYER.
*> Section 7.2 (EquipmentLayerRenderer.getColorForLayer): USING dyeable (1 when the layer has a
*> dyeable entry), has color_when_undyed, that colour (RGB), the stack's dye colour (opaque ARGB, 0
*> when undyed), colour out: -1 without dyeable; with it the dye if non-zero, else the undyed
*> colour made opaque, else 0; a result of 0 means the layer is not drawn.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DYEABLE              BINARY-LONG.
 01 L-HAS-UNDYED           BINARY-LONG.
 01 L-UNDYED               BINARY-DOUBLE.
 01 L-DYE                  BINARY-DOUBLE.
 01 L-COLOUR               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-DYEABLE L-HAS-UNDYED L-UNDYED L-DYE L-COLOUR.
     MOVE 4294967295 TO L-COLOUR
     IF L-DYEABLE = 1
         EVALUATE TRUE
             WHEN L-DYE NOT = 0
                 MOVE L-DYE TO L-COLOUR
             WHEN L-HAS-UNDYED = 1
                 COMPUTE L-COLOUR = 4278190080 + FUNCTION MOD(L-UNDYED, 16777216)
             WHEN OTHER
                 MOVE 0 TO L-COLOUR
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM TINT-ARMOUR-LAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-DYE-MIX.
*> Section 7.4 (DyedItemColor.applyDyes): USING TINT-MIX; sets TM-RESULT (RGB, alpha 0): the
*> stack's dyed colour and each dye's diffuse colour are averaged per channel (integer division by
*> n), then every channel becomes truncate(avg x avgMax / top) in single precision, avgMax being
*> the mean of the largest channels and top the largest averaged channel.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COLUMN              BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-SUM                 BINARY-LONG OCCURS 3 TIMES.
 01 WS-CH                  BINARY-LONG OCCURS 3 TIMES.
 01 WS-RGB                 BINARY-DOUBLE.
 01 WS-MAX                 BINARY-LONG.
 01 WS-MAXSUM              BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-AVG                 BINARY-LONG OCCURS 3 TIMES.
 01 WS-AVGMAX              COMP-1.
 01 WS-TOP                 COMP-1.
 01 WS-PROD                COMP-1.
 01 WS-QUOT                COMP-1.
 01 WS-A                   COMP-1.
 01 WS-OUT                 BINARY-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 COPY CLTINTI.
 PROCEDURE DIVISION USING TINT-MIX.
     MOVE 0 TO WS-N WS-MAXSUM WS-SUM(1) WS-SUM(2) WS-SUM(3)
     IF TM-HAS-DYED = 1
         COMPUTE WS-CH(1) = TM-DYED / 65536
         COMPUTE WS-CH(2) = FUNCTION MOD(TM-DYED, 65536)
         COMPUTE WS-CH(2) = WS-CH(2) / 256
         COMPUTE WS-CH(3) = FUNCTION MOD(TM-DYED, 256)
         COMPUTE WS-MAX = FUNCTION MAX(WS-CH(1), WS-CH(2), WS-CH(3))
         ADD WS-MAX TO WS-MAXSUM
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
             ADD WS-CH(WS-K) TO WS-SUM(WS-K)
         END-PERFORM
         ADD 1 TO WS-N
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TM-COUNT
         CALL "TINT-DYE" USING TM-DYE(WS-I) WS-COLUMN WS-RGB
         COMPUTE WS-RGB = FUNCTION MOD(WS-RGB, 16777216)
         COMPUTE WS-CH(1) = WS-RGB / 65536
         COMPUTE WS-CH(2) = FUNCTION MOD(WS-RGB, 65536)
         COMPUTE WS-CH(2) = WS-CH(2) / 256
         COMPUTE WS-CH(3) = FUNCTION MOD(WS-RGB, 256)
         COMPUTE WS-MAX = FUNCTION MAX(WS-CH(1), WS-CH(2), WS-CH(3))
         ADD WS-MAX TO WS-MAXSUM
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
             ADD WS-CH(WS-K) TO WS-SUM(WS-K)
         END-PERFORM
         ADD 1 TO WS-N
     END-PERFORM
     MOVE 0 TO TM-RESULT
     IF WS-N > 0
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
             DIVIDE WS-SUM(WS-K) BY WS-N GIVING WS-AVG(WS-K)
         END-PERFORM
         COMPUTE WS-AVGMAX = WS-MAXSUM / WS-N
         COMPUTE WS-MAX = FUNCTION MAX(WS-AVG(1), WS-AVG(2), WS-AVG(3))
         MOVE WS-MAX TO WS-TOP
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
             MOVE 0 TO WS-OUT(WS-K)
             IF WS-MAX > 0
                 MOVE WS-AVG(WS-K) TO WS-A
                 COMPUTE WS-PROD = WS-A * WS-AVGMAX
                 COMPUTE WS-QUOT = WS-PROD / WS-TOP
                 COMPUTE WS-OUT(WS-K) = FUNCTION INTEGER-PART(WS-QUOT)
             END-IF
         END-PERFORM
         COMPUTE TM-RESULT = WS-OUT(1) * 65536 + WS-OUT(2) * 256 + WS-OUT(3)
     END-IF
     GOBACK.
 END PROGRAM TINT-DYE-MIX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-RADIUS-PRESET.
*> Sections 4 and 12 (GraphicsPreset): USING preset (0 fast, 1 fancy, 2 fabulous), biome blend radius
*> out: 1, 2, 2; any other value gives the option's default 2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PRESET               BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-PRESET L-RADIUS.
     MOVE 2 TO L-RADIUS
     IF L-PRESET = 0
         MOVE 1 TO L-RADIUS
     END-IF
     GOBACK.
 END PROGRAM TINT-RADIUS-PRESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TINT-ITEM-TYPE.
*> Section 7 and 08 §6.4: USING tint source type name (PIC X(32), with or without the minecraft:
*> namespace), type out (TI-TYPE: 1 constant, 2 dye, 3 grass, 4 firework, 5 potion, 6 team, 7
*> custom_model_data; 0 for an unknown name).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(32).
 01 WS-REST                PIC X(22).
 LINKAGE SECTION.
 01 L-NAME                 PIC X(32).
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-TYPE.
     MOVE L-NAME TO WS-NAME
     IF WS-NAME(1:10) = "minecraft:"
         MOVE WS-NAME(11:22) TO WS-REST
         MOVE WS-REST TO WS-NAME
     END-IF
     EVALUATE WS-NAME
         WHEN "constant"
             MOVE 1 TO L-TYPE
         WHEN "dye"
             MOVE 2 TO L-TYPE
         WHEN "grass"
             MOVE 3 TO L-TYPE
         WHEN "firework"
             MOVE 4 TO L-TYPE
         WHEN "potion"
             MOVE 5 TO L-TYPE
         WHEN "team"
             MOVE 6 TO L-TYPE
         WHEN "custom_model_data"
             MOVE 7 TO L-TYPE
         WHEN OTHER
             MOVE 0 TO L-TYPE
     END-EVALUATE
     GOBACK.
 END PROGRAM TINT-ITEM-TYPE.
