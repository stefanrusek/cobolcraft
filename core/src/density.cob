*> The density function evaluator of world generation (docs/protocol/10 sections 4 and 6; T0417): evaluates a
*> function loaded into the content library's node store (CTWORLDGEN.cpy: DENSITY-FUNCTIONS-LOAD, NOISES-LOAD)
*> at a block position. Every value is a float32 held in a FLOAT-LONG: each step is one cc_f64 operation followed by
*> cc_f64_f32_round (10 section 16; see noise.cob). The node type is the row of the type table of the loader
*> (content/src/worldgen-types.cob, domain 1): 1 constant, 2 add, 3 sub, 4 mul, 5 div, 6 min, 7 max, 8 abs,
*> 9 square, 10 cube, 11 negate, 12 sqrt, 13 reciprocal, 14 log, 15 sign, 16 half_negative, 17 quarter_negative,
*> 18 squeeze, 19 cache, 20 blend_density, 21 clamp, 22 lerp, 23 range_choice, 24 gradient, 25 noise, 26 shift_a,
*> 27 shift_b, 28 shift, 29 spline, 30 old_blended_noise, 31 find_top_surface, 32 interpolated, 33 blend_alpha,
*> 34 blend_offset, 35 beardifier; a node of type 0 is a reference to the function of the id in WGN-TEXT-1. A fresh world
*> has no blending data (10 section 4.1): blend_alpha 1, blend_offset 0, blend_density the identity, beardifier 0.
*> The types after 35 (the overworld terrain data do not use them) evaluate to 0 here.
*>
*> Entry points:
*>   DENSITY-SETUP USING seed (BINARY-DOUBLE UNSIGNED): the world seed; empties the noise store and the names
*>     of the normal noises (a noise is built from the content's definition when first used).
*>   DENSITY-EVAL USING function key (PIC X(112), "minecraft:..."), x, y, z (BINARY-LONG), result out (FLOAT-LONG)
*>   DENSITY-NODE USING node (BINARY-LONG), x, y, z, result out: the same for a node of the store.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DENSITY-SETUP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DENSITY.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-STATE== LEADING ==XR-== BY ==WS-S-==.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION USING L-SEED.
     CALL "NOISE-RESET"
     CALL "CLIMATE-MEMO-RESET"
     MOVE 0 TO DN-NOISE-COUNT DN-BLEND-COUNT
     CALL "XORO-SEED" USING L-SEED WS-STATE
     CALL "XORO-FORK-POSITIONAL" USING WS-STATE DN-FACTORY
     GOBACK.
 END PROGRAM DENSITY-SETUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DENSITY-NOISE-HANDLE.
*> USING noise id (PIC X(112), "minecraft:continentalness"), handle out (BINARY-LONG; 0 when the content has no
*> such noise definition): the normal noise of the world's seed, built on first use from the definition of the
*> store (function kind 8; WGN-INT 1 base octave, 2 octave count, 3 modifier count, 4 normalize; WGN-NUM 1 the base
*> amplitude; WGN-CHILD 1 the chain of modifier constants).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DENSITY.
 COPY CTWORLDGEN.
 01 WS-KIND                BINARY-LONG VALUE 8.
 01 WS-ROOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-LEN                 BINARY-LONG.
 01 WS-MODS.
    05 WS-MOD              FLOAT-LONG OCCURS 32 TIMES.
 01 WS-MOD-COUNT           BINARY-LONG.
 01 WS-NORMALIZE           BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-OCTAVES             BINARY-LONG.
 01 WS-AMP                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(112).
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-HANDLE.
     MOVE 0 TO L-HANDLE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > DN-NOISE-COUNT
         IF DN-NOISE-NAME(WS-I) = L-NAME
             MOVE DN-NOISE-HANDLE(WS-I) TO L-HANDLE
         END-IF
     END-PERFORM
     IF L-HANDLE > 0
         GOBACK
     END-IF
     CALL "WG-FIND" USING WS-KIND L-NAME WS-ROOT
     IF WS-ROOT = 0
         GOBACK
     END-IF
     MOVE WGN-INT(WS-ROOT, 3) TO WS-MOD-COUNT
     MOVE WGN-CHILD(WS-ROOT, 1) TO WS-NODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-MOD-COUNT
         MOVE WGN-NUM(WS-NODE, 1) TO WS-MOD(WS-I)
         MOVE WGN-NEXT(WS-NODE) TO WS-NODE
     END-PERFORM
     MOVE 0 TO WS-NORMALIZE
     IF WGN-INT(WS-ROOT, 4) NOT = 0
         MOVE 1 TO WS-NORMALIZE
     END-IF
     MOVE L-NAME(1:64) TO WS-NAME
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NAME TRAILING)) TO WS-LEN
     MOVE WGN-INT(WS-ROOT, 1) TO WS-BASE
     MOVE WGN-INT(WS-ROOT, 2) TO WS-OCTAVES
     MOVE WGN-NUM(WS-ROOT, 1) TO WS-AMP
     CALL "NOISE-CREATE" USING DN-FACTORY WS-NAME WS-LEN WS-BASE WS-OCTAVES WS-AMP WS-MODS
         WS-MOD-COUNT WS-NORMALIZE L-HANDLE
     ADD 1 TO DN-NOISE-COUNT
     MOVE L-NAME TO DN-NOISE-NAME(DN-NOISE-COUNT)
     MOVE L-HANDLE TO DN-NOISE-HANDLE(DN-NOISE-COUNT)
     GOBACK.
 END PROGRAM DENSITY-NOISE-HANDLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DENSITY-F32.
*> USING operation (BINARY-LONG: 1 add, 2 subtract, 3 multiply, 4 divide), a, b, result out: the float32 result
*> of one operation on float32 values: the double operation, then the rounding to float32.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-OP                   BINARY-LONG.
 01 L-A                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-OP L-A L-B L-R.
     EVALUATE L-OP
         WHEN 1
             CALL STATIC "cc_f64_add" USING BY REFERENCE L-A L-B WS-T
         WHEN 2
             CALL STATIC "cc_f64_sub" USING BY REFERENCE L-A L-B WS-T
         WHEN 3
             CALL STATIC "cc_f64_mul" USING BY REFERENCE L-A L-B WS-T
         WHEN OTHER
             CALL STATIC "cc_f64_div" USING BY REFERENCE L-A L-B WS-T
     END-EVALUATE
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T L-R
     GOBACK.
 END PROGRAM DENSITY-F32.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DENSITY-SPLINE RECURSIVE.
*> USING spline row (BINARY-LONG, WSP-ROW), x, y, z, result out: 10 section 4.3. A constant spline is its value;
*> otherwise the coordinate function is evaluated, the interval found (the first point with c < location, minus 1;
*> none: the last), the ends extended linearly by the derivative and the inside the cubic Hermite form,
*> every step in float32; a point's value is a spline evaluated at the same position.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 LOCAL-STORAGE SECTION.
 01 LS-C                   FLOAT-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-K                   BINARY-LONG.
 01 LS-LAST                BINARY-LONG.
 01 LS-P0                  BINARY-LONG.
 01 LS-P1                  BINARY-LONG.
 01 LS-L0                  FLOAT-LONG.
 01 LS-L1                  FLOAT-LONG.
 01 LS-D0                  FLOAT-LONG.
 01 LS-D1                  FLOAT-LONG.
 01 LS-V0                  FLOAT-LONG.
 01 LS-V1                  FLOAT-LONG.
 01 LS-T                   FLOAT-LONG.
 01 LS-U                   FLOAT-LONG.
 01 LS-DX                  FLOAT-LONG.
 01 LS-DY                  FLOAT-LONG.
 01 LS-A                   FLOAT-LONG.
 01 LS-B                   FLOAT-LONG.
 01 LS-NEG                 FLOAT-LONG.
 01 LS-LOCATION            FLOAT-LONG.
 01 LS-ONE                 FLOAT-LONG VALUE 1.
 01 LS-ZERO                FLOAT-LONG VALUE 0.
 01 LS-MINUS-ONE           FLOAT-LONG VALUE -1.
 01 LS-OP-ADD              BINARY-LONG VALUE 1.
 01 LS-OP-SUB              BINARY-LONG VALUE 2.
 01 LS-OP-MUL              BINARY-LONG VALUE 3.
 01 LS-OP-DIV              BINARY-LONG VALUE 4.
 01 LS-FOUND              BINARY-LONG.
 01 LS-PT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-RESULT.
     IF WSP-N(L-ROW) = 0
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WSP-CONST(L-ROW) L-RESULT
         GOBACK
     END-IF
     CALL "DENSITY-NODE" USING WSP-COORD(L-ROW) L-X L-Y L-Z LS-C
     COMPUTE LS-LAST = WSP-N(L-ROW) - 1
     MOVE LS-LAST TO LS-I
     MOVE 0 TO LS-FOUND
     PERFORM VARYING LS-K FROM 0 BY 1 UNTIL LS-K > LS-LAST OR LS-FOUND = 1
         COMPUTE LS-PT = WSP-FIRST(L-ROW) + LS-K
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WPT-LOCATION(LS-PT) LS-LOCATION
         IF LS-C < LS-LOCATION
             COMPUTE LS-I = LS-K - 1
             MOVE 1 TO LS-FOUND
         END-IF
     END-PERFORM
*>   Beyond an end: the end point's value, extended by its derivative.
     IF LS-I < 0 OR LS-I = LS-LAST
         IF LS-I < 0
             MOVE WSP-FIRST(L-ROW) TO LS-PT
         ELSE
             COMPUTE LS-PT = WSP-FIRST(L-ROW) + LS-LAST
         END-IF
         CALL "DENSITY-SPLINE" USING WPT-VALUE(LS-PT) L-X L-Y L-Z LS-V0
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WPT-DERIVATIVE(LS-PT) LS-D0
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WPT-LOCATION(LS-PT) LS-L0
         IF LS-D0 = 0
             MOVE LS-V0 TO L-RESULT
             GOBACK
         END-IF
         CALL "DENSITY-F32" USING LS-OP-SUB LS-C LS-L0 LS-T
         CALL "DENSITY-F32" USING LS-OP-MUL LS-D0 LS-T LS-U
         CALL "DENSITY-F32" USING LS-OP-ADD LS-V0 LS-U L-RESULT
         GOBACK
     END-IF
     COMPUTE LS-P0 = WSP-FIRST(L-ROW) + LS-I
     COMPUTE LS-P1 = LS-P0 + 1
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WPT-LOCATION(LS-P0) LS-L0
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WPT-LOCATION(LS-P1) LS-L1
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WPT-DERIVATIVE(LS-P0) LS-D0
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WPT-DERIVATIVE(LS-P1) LS-D1
     CALL "DENSITY-F32" USING LS-OP-SUB LS-L1 LS-L0 LS-DX
     CALL "DENSITY-F32" USING LS-OP-SUB LS-C LS-L0 LS-T
     CALL "DENSITY-F32" USING LS-OP-DIV LS-T LS-DX LS-U
     MOVE LS-U TO LS-T
     CALL "DENSITY-SPLINE" USING WPT-VALUE(LS-P0) L-X L-Y L-Z LS-V0
     CALL "DENSITY-SPLINE" USING WPT-VALUE(LS-P1) L-X L-Y L-Z LS-V1
*>   a = d0 * dx - (y1 - y0); b = -d1 * dx + (y1 - y0)
     CALL "DENSITY-F32" USING LS-OP-SUB LS-V1 LS-V0 LS-DY
     CALL "DENSITY-F32" USING LS-OP-MUL LS-D0 LS-DX LS-U
     CALL "DENSITY-F32" USING LS-OP-SUB LS-U LS-DY LS-A
     CALL "DENSITY-F32" USING LS-OP-MUL LS-D1 LS-MINUS-ONE LS-NEG
     CALL "DENSITY-F32" USING LS-OP-MUL LS-NEG LS-DX LS-U
     CALL "DENSITY-F32" USING LS-OP-ADD LS-U LS-DY LS-B
*>   lerp(t, y0, y1) + t * (1 - t) * lerp(t, a, b)
     CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE LS-T LS-V0 LS-V1 LS-U
     CALL "DENSITY-F32" USING LS-OP-SUB LS-ONE LS-T LS-DX
     CALL "DENSITY-F32" USING LS-OP-MUL LS-T LS-DX LS-DY
     CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE LS-T LS-A LS-B LS-V0
     CALL "DENSITY-F32" USING LS-OP-MUL LS-DY LS-V0 LS-V1
     CALL "DENSITY-F32" USING LS-OP-ADD LS-U LS-V1 L-RESULT
     GOBACK.
 END PROGRAM DENSITY-SPLINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DENSITY-INTERPOLATED RECURSIVE.
*> USING node, x, y, z, result out: 10 section 4.1, the trilinear interpolation of the input evaluated at the eight
*> corners of the cell (cell sizes WGN-INT 1 horizontal and 2 vertical, anchored at multiples of them); evaluated
*> directly when the position is a corner.
*> Grid mode (the node has a slot in the chunk grids and the position is inside them): the corners are read from the grid
*> and the fractions from tables, with the integer divisions as DIVIDE (a COMPUTE with a division goes through decimals).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 COPY DENSITY.
 01 DG-GRID BASED.
 COPY GENGRID REPLACING LEADING ==GJ-== BY ==DG-==.
 01 WS-INIT                BINARY-LONG VALUE 0.
 01 WS-FRACTIONS.
    05 WS-FXT              FLOAT-LONG OCCURS 4 TIMES.
    05 WS-FYT              FLOAT-LONG OCCURS 8 TIMES.
    05 WS-FZT              FLOAT-LONG OCCURS 4 TIMES.
 01 WS-N4                  BINARY-LONG VALUE 4.
 01 WS-N8                  BINARY-LONG VALUE 8.
 LOCAL-STORAGE SECTION.
 01 LS-SLOT                BINARY-LONG.
 01 LS-GI                  BINARY-LONG.
 01 LS-RX                  BINARY-LONG.
 01 LS-RY                  BINARY-LONG.
 01 LS-RZ                  BINARY-LONG.
 01 LS-X0                  BINARY-LONG.
 01 LS-Y0                  BINARY-LONG.
 01 LS-Z0                  BINARY-LONG.
 01 LS-CX                  BINARY-LONG.
 01 LS-CY                  BINARY-LONG.
 01 LS-CZ                  BINARY-LONG.
 01 LS-LX                  BINARY-LONG.
 01 LS-LY                  BINARY-LONG.
 01 LS-LZ                  BINARY-LONG.
 01 LS-CI                  BINARY-LONG.
 01 LS-CJ                  BINARY-LONG.
 01 LS-CK                  BINARY-LONG.
 01 LS-A                   FLOAT-LONG.
 01 LS-B                   FLOAT-LONG.
 01 LS-FX                  FLOAT-LONG.
 01 LS-FY                  FLOAT-LONG.
 01 LS-FZ                  FLOAT-LONG.
 01 LS-OP-DIV              BINARY-LONG VALUE 4.
 01 LS-I                   BINARY-LONG.
 01 LS-Q                   BINARY-LONG.
 01 LS-G.
    05 LS-G-ITEM           FLOAT-LONG OCCURS 8 TIMES.
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-NODE L-X L-Y L-Z L-RESULT.
     MOVE WGN-INT(L-NODE, 1) TO LS-CX
     MOVE WGN-INT(L-NODE, 2) TO LS-CY
*>   grid mode: the slot of this node in the chunk grids, 0 when the node has none or the position is outside them
     MOVE 0 TO LS-SLOT
     IF DNG-ACTIVE = 1 AND LS-CX = 4 AND LS-CY = 8
         AND L-X >= DNG-X0 AND L-X < DNG-X0 + 16 AND L-Z >= DNG-Z0 AND L-Z < DNG-Z0 + 16
         AND L-Y >= -64 AND L-Y < 320
         SET ADDRESS OF DG-GRID TO DNG-PTR
         PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > DG-G-COUNT OR LS-SLOT > 0
             IF DG-G-NODE(LS-I) = L-NODE
                 MOVE LS-I TO LS-SLOT
             END-IF
         END-PERFORM
     END-IF
*>   grid slot LS-SLOT, position inside the grids (cells of 4 by 8 by 4 anchored at the chunk's corner and y = -64; the grid of a
*>   node holds 5 x 5 x 49 values, x the slowest, then z, then y): the grid index of the cell, its eight corners at the offsets of
*>   one cell in x (245), z (49) and y (1).
     IF LS-SLOT > 0
         COMPUTE LS-LX = L-X - DNG-X0
         COMPUTE LS-LZ = L-Z - DNG-Z0
         COMPUTE LS-LY = L-Y + 64
         DIVIDE LS-LX BY 4 GIVING LS-CI REMAINDER LS-RX
         DIVIDE LS-LZ BY 4 GIVING LS-CK REMAINDER LS-RZ
         DIVIDE LS-LY BY 8 GIVING LS-CJ REMAINDER LS-RY
         COMPUTE LS-GI = (LS-SLOT - 1) * 1225 + (LS-CI * 5 + LS-CK) * 49 + LS-CJ + 1
         IF LS-RX = 0 AND LS-RY = 0 AND LS-RZ = 0
             MOVE DG-G-VAL(LS-GI) TO L-RESULT
         ELSE
             IF WS-INIT = 0
                 PERFORM VARYING LS-I FROM 0 BY 1 UNTIL LS-I > 3
                     CALL "DENSITY-FRACTION" USING LS-I WS-N4 WS-FXT(LS-I + 1)
                     MOVE WS-FXT(LS-I + 1) TO WS-FZT(LS-I + 1)
                 END-PERFORM
                 PERFORM VARYING LS-I FROM 0 BY 1 UNTIL LS-I > 7
                     CALL "DENSITY-FRACTION" USING LS-I WS-N8 WS-FYT(LS-I + 1)
                 END-PERFORM
                 MOVE 1 TO WS-INIT
             END-IF
             MOVE DG-G-VAL(LS-GI) TO LS-G-ITEM(1)
             MOVE DG-G-VAL(LS-GI + 245) TO LS-G-ITEM(2)
             MOVE DG-G-VAL(LS-GI + 1) TO LS-G-ITEM(3)
             MOVE DG-G-VAL(LS-GI + 246) TO LS-G-ITEM(4)
             MOVE DG-G-VAL(LS-GI + 49) TO LS-G-ITEM(5)
             MOVE DG-G-VAL(LS-GI + 294) TO LS-G-ITEM(6)
             MOVE DG-G-VAL(LS-GI + 50) TO LS-G-ITEM(7)
             MOVE DG-G-VAL(LS-GI + 295) TO LS-G-ITEM(8)
             CALL "NOISE-TRILERP" USING WS-FXT(LS-RX + 1) WS-FYT(LS-RY + 1) WS-FZT(LS-RZ + 1) LS-G L-RESULT
         END-IF
         GOBACK
     END-IF
     COMPUTE LS-RX = FUNCTION MOD(L-X, LS-CX)
     COMPUTE LS-RY = FUNCTION MOD(L-Y, LS-CY)
     COMPUTE LS-RZ = FUNCTION MOD(L-Z, LS-CX)
     IF LS-RX = 0 AND LS-RY = 0 AND LS-RZ = 0
         CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 1) L-X L-Y L-Z L-RESULT
         GOBACK
     END-IF
     COMPUTE LS-X0 = L-X - LS-RX
     COMPUTE LS-Y0 = L-Y - LS-RY
     COMPUTE LS-Z0 = L-Z - LS-RZ
*>   fractions: (float) remainder / (float) cell size, float32
     CALL "DENSITY-FRACTION" USING LS-RX LS-CX LS-FX
     CALL "DENSITY-FRACTION" USING LS-RY LS-CY LS-FY
     CALL "DENSITY-FRACTION" USING LS-RZ LS-CX LS-FZ
*>   corners 000 100 010 110 001 101 011 111
     PERFORM VARYING LS-I FROM 0 BY 1 UNTIL LS-I > 7
         COMPUTE LS-Q = LS-I / 2
         COMPUTE LS-RX = LS-X0 + FUNCTION MOD(LS-I, 2) * LS-CX
         COMPUTE LS-RY = LS-Y0 + FUNCTION MOD(LS-Q, 2) * LS-CY
         COMPUTE LS-Q = LS-I / 4
         COMPUTE LS-RZ = LS-Z0 + LS-Q * LS-CX
         CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 1) LS-RX LS-RY LS-RZ LS-G-ITEM(LS-I + 1)
     END-PERFORM
     CALL "NOISE-TRILERP" USING LS-FX LS-FY LS-FZ LS-G L-RESULT
     GOBACK.
 END PROGRAM DENSITY-INTERPOLATED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DENSITY-FRACTION.
*> USING remainder (BINARY-LONG, 0 to 63), cell size (BINARY-LONG, 1 to 64), result out (FLOAT-LONG): (float) remainder / (float) cell size
*> in float32 (two conversions and one division), kept in a table of the pairs (the cell sizes of the worlds are 1, 2, 4 and 8) and
*> computed once per pair.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OP-DIV              BINARY-LONG VALUE 4.
 01 WS-FRACS.
    05 WS-FRAC-ENTRY OCCURS 4096 TIMES.
       10 WS-FRAC-OK       PIC 9 VALUE 0.
       10 WS-FRAC          FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-R                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-R L-C L-RESULT.
     COMPUTE WS-I = (L-C - 1) * 64 + L-R + 1
     IF WS-FRAC-OK(WS-I) = 0
         CALL STATIC "cc_f64_i32_to_f32" USING BY REFERENCE L-R WS-A
         CALL STATIC "cc_f64_i32_to_f32" USING BY REFERENCE L-C WS-B
         CALL "DENSITY-F32" USING WS-OP-DIV WS-A WS-B WS-FRAC(WS-I)
         MOVE 1 TO WS-FRAC-OK(WS-I)
     END-IF
     MOVE WS-FRAC(WS-I) TO L-RESULT
     GOBACK.
 END PROGRAM DENSITY-FRACTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DENSITY-BLENDED.
*> USING node (old_blended_noise: WGN-NUM 1 xz_scale, 2 y_scale, 3 xz_factor, 4 y_factor, 5 smear_scale_multiplier),
*> x, y, z, result out: 10 section 3.4. The three stacks are built on the first use of the node, from
*> P.fromHashOf("minecraft:terrain"): minimum limit and maximum limit (first octave -15, ampBase 65535/65536) and
*> main (first octave -7, y scale smear / y_factor, ampBase 12.75). Value: lo and hi at the scaled position, the main
*> stack at the position divided by the factors, t = clamp(main + 0.5, 0, 1), lerp(t, lo, hi), lazily.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DENSITY.
 COPY CTWORLDGEN.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-R== LEADING ==XR-== BY ==WS-R-==.
 01 WS-BASE-TEXT           PIC X(32) VALUE Z"684.412".
 01 WS-LIMIT-TEXT          PIC X(32) VALUE Z"0.9999847412109375".
 01 WS-NAME                PIC X(64) VALUE "minecraft:terrain".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 17.
 01 WS-BASE                FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-MAIN-AMP            FLOAT-LONG VALUE 12.75.
 01 WS-MIN-FIRST           BINARY-LONG VALUE -15.
 01 WS-MAIN-FIRST          BINARY-LONG VALUE -7.
 01 WS-SMEAR               FLOAT-LONG.
 01 WS-MAIN-SCALE          FLOAT-LONG.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-OP-ADD              BINARY-LONG VALUE 1.
 01 WS-E                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-XD                  FLOAT-LONG.
 01 WS-YD                  FLOAT-LONG.
 01 WS-ZD                  FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-MX                  FLOAT-LONG.
 01 WS-MY                  FLOAT-LONG.
 01 WS-MZ                  FLOAT-LONG.
 01 WS-M                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-LO                  FLOAT-LONG.
 01 WS-HI                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-NODE L-X L-Y L-Z L-RESULT.
     MOVE 0 TO WS-E
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > DN-BLEND-COUNT
         IF DN-BLEND-NODE(WS-I) = L-NODE
             MOVE WS-I TO WS-E
         END-IF
     END-PERFORM
     IF WS-E = 0
         CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-BASE-TEXT WS-BASE
         CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-LIMIT-TEXT WS-LIMIT
         ADD 1 TO DN-BLEND-COUNT
         MOVE DN-BLEND-COUNT TO WS-E
         MOVE L-NODE TO DN-BLEND-NODE(WS-E)
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-BASE WGN-NUM(L-NODE, 1) DN-B-XZ-MUL(WS-E)
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-BASE WGN-NUM(L-NODE, 2) DN-B-Y-MUL(WS-E)
         CALL STATIC "cc_f64_mul" USING BY REFERENCE DN-B-Y-MUL(WS-E) WGN-NUM(L-NODE, 5) WS-SMEAR
         CALL STATIC "cc_f64_div" USING BY REFERENCE WS-SMEAR WGN-NUM(L-NODE, 4) WS-MAIN-SCALE
         CALL "XORO-FROM-HASH" USING DN-FACTORY WS-NAME WS-NAME-LENGTH WS-R
         CALL "NOISE-SMEARED-STACK" USING WS-R WS-MIN-FIRST WS-SMEAR WS-LIMIT DN-B-MIN(WS-E)
         CALL "NOISE-SMEARED-STACK" USING WS-R WS-MIN-FIRST WS-SMEAR WS-LIMIT DN-B-MAX(WS-E)
         CALL "NOISE-SMEARED-STACK" USING WS-R WS-MAIN-FIRST WS-MAIN-SCALE WS-MAIN-AMP DN-B-MAIN(WS-E)
     END-IF
     MOVE L-X TO WS-XD
     MOVE L-Y TO WS-YD
     MOVE L-Z TO WS-ZD
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-XD DN-B-XZ-MUL(WS-E) WS-X
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-YD DN-B-Y-MUL(WS-E) WS-Y
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-ZD DN-B-XZ-MUL(WS-E) WS-Z
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-X WGN-NUM(L-NODE, 3) WS-MX
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-Y WGN-NUM(L-NODE, 4) WS-MY
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-Z WGN-NUM(L-NODE, 3) WS-MZ
     CALL "NOISE-GET" USING DN-B-MAIN(WS-E) WS-MX WS-MY WS-MZ WS-M
     CALL "DENSITY-F32" USING WS-OP-ADD WS-M WS-HALF WS-T
     CALL STATIC "cc_f64_clamp_f32" USING BY REFERENCE WS-T WS-ZERO WS-ONE WS-M
     EVALUATE TRUE
         WHEN WS-M = 0
             CALL "NOISE-GET" USING DN-B-MIN(WS-E) WS-X WS-Y WS-Z L-RESULT
         WHEN WS-M = 1
             CALL "NOISE-GET" USING DN-B-MAX(WS-E) WS-X WS-Y WS-Z L-RESULT
         WHEN OTHER
             CALL "NOISE-GET" USING DN-B-MIN(WS-E) WS-X WS-Y WS-Z WS-LO
             CALL "NOISE-GET" USING DN-B-MAX(WS-E) WS-X WS-Y WS-Z WS-HI
             CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE WS-M WS-LO WS-HI L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM DENSITY-BLENDED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DENSITY-TOP-SURFACE RECURSIVE.
*> USING node (find_top_surface: WGN-CHILD 1 density, 2 upper_bound; WGN-INT 1 lower_bound, 2 cell_height), x, y, z
*> (y is ignored), result out: 10 section 4.4. y = floor(upper / cell_height) * cell_height (upper sampled at
*> (x, 0, z)); the lower bound when y <= it; else the first y going down by cell_height with density > 0, else the
*> lower bound; the result is the float of that integer.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 LOCAL-STORAGE SECTION.
 01 LS-ZERO                BINARY-LONG VALUE 0.
 01 LS-U                   FLOAT-LONG.
 01 LS-C                   FLOAT-LONG.
 01 LS-Q                   FLOAT-LONG.
 01 LS-D                   FLOAT-LONG.
 01 LS-FLOOR               FLOAT-LONG.
 01 LS-OP-DIV              BINARY-LONG VALUE 4.
 01 LS-LOWER               BINARY-LONG.
 01 LS-HEIGHT              BINARY-LONG.
 01 LS-CELL                BINARY-LONG.
 01 LS-SAMPLE              BINARY-LONG.
 01 LS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-NODE L-X L-Y L-Z L-RESULT.
     MOVE WGN-INT(L-NODE, 1) TO LS-LOWER
     MOVE WGN-INT(L-NODE, 2) TO LS-HEIGHT
     CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 2) L-X LS-ZERO L-Z LS-U
     CALL STATIC "cc_f64_i32_to_f32" USING BY REFERENCE LS-HEIGHT LS-C
     CALL "DENSITY-F32" USING LS-OP-DIV LS-U LS-C LS-Q
     CALL STATIC "cc_f64_floor" USING BY REFERENCE LS-Q LS-FLOOR
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE LS-FLOOR LS-CELL
     COMPUTE LS-SAMPLE = LS-CELL * LS-HEIGHT
     MOVE LS-LOWER TO LS-DONE
     IF LS-SAMPLE > LS-LOWER
         PERFORM UNTIL LS-SAMPLE < LS-LOWER
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 1) L-X LS-SAMPLE L-Z LS-D
             IF LS-D > 0
                 MOVE LS-SAMPLE TO LS-DONE
                 MOVE LS-LOWER TO LS-SAMPLE
                 SUBTRACT 1 FROM LS-SAMPLE
             ELSE
                 SUBTRACT LS-HEIGHT FROM LS-SAMPLE
             END-IF
         END-PERFORM
     END-IF
     CALL STATIC "cc_f64_i32_to_f32" USING BY REFERENCE LS-DONE L-RESULT
     GOBACK.
 END PROGRAM DENSITY-TOP-SURFACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DENSITY-NODE RECURSIVE.
*> The node memo around DENSITY-NODE-RAW (DMEMO.cpy): a node evaluated at the position of its last evaluation (any y when that
*> evaluation did not read y) returns the stored value; otherwise it is evaluated and, when it reached no grid or blend node, stored.
*> The y and impure flags of the evaluation fold into the flags of the caller either way.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 COPY NOISE.
 COPY DMEMO.
 LOCAL-STORAGE SECTION.
 01 LS-STAMP               BINARY-LONG.
 01 LS-OUTER-Y             BINARY-LONG.
 01 LS-OUTER-IMPURE        BINARY-LONG.
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-NODE L-X L-Y L-Z L-RESULT.
     IF L-NODE = 0
         MOVE 0 TO L-RESULT
         GOBACK
     END-IF
     COMPUTE LS-STAMP = WG-LOAD-GEN + NZ-GEN + 1
     IF DM-STAMP(L-NODE) = LS-STAMP AND DM-X(L-NODE) = L-X AND DM-Z(L-NODE) = L-Z
             AND (DM-UY(L-NODE) = 0 OR DM-Y(L-NODE) = L-Y)
         MOVE DM-RES(L-NODE) TO L-RESULT
         IF DM-UY(L-NODE) = 1
             MOVE 1 TO DM-USES-Y
         END-IF
         GOBACK
     END-IF
     MOVE DM-USES-Y TO LS-OUTER-Y
     MOVE DM-IMPURE TO LS-OUTER-IMPURE
     MOVE 0 TO DM-USES-Y DM-IMPURE
     CALL "DENSITY-NODE-RAW" USING L-NODE L-X L-Y L-Z L-RESULT
     IF DM-IMPURE = 0
         MOVE LS-STAMP TO DM-STAMP(L-NODE)
         MOVE L-X TO DM-X(L-NODE)
         MOVE L-Y TO DM-Y(L-NODE)
         MOVE L-Z TO DM-Z(L-NODE)
         MOVE DM-USES-Y TO DM-UY(L-NODE)
         MOVE L-RESULT TO DM-RES(L-NODE)
     END-IF
     IF LS-OUTER-Y = 1
         MOVE 1 TO DM-USES-Y
     END-IF
     IF LS-OUTER-IMPURE = 1
         MOVE 1 TO DM-IMPURE
     END-IF
     GOBACK.
 END PROGRAM DENSITY-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DENSITY-NODE-RAW RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 COPY GENSTAGE.
 COPY DMEMO.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-QUARTER             FLOAT-LONG VALUE 0.25.
 01 WS-FOUR                FLOAT-LONG VALUE 4.
 01 WS-TWO                 FLOAT-LONG VALUE 2.
 01 WS-24                  FLOAT-LONG VALUE 24.
 01 WS-MINUS-ONE           FLOAT-LONG VALUE -1.
 01 WS-KIND                BINARY-LONG VALUE 1.
 LOCAL-STORAGE SECTION.
 01 LS-A                   FLOAT-LONG.
 01 LS-B                   FLOAT-LONG.
 01 LS-C                   FLOAT-LONG.
 01 LS-T                   FLOAT-LONG.
 01 LS-U                   FLOAT-LONG.
 01 LS-V                   FLOAT-LONG.
 01 LS-LO                  FLOAT-LONG.
 01 LS-HI                  FLOAT-LONG.
 01 LS-XD                  FLOAT-LONG.
 01 LS-YD                  FLOAT-LONG.
 01 LS-ZD                  FLOAT-LONG.
 01 LS-SX                  FLOAT-LONG.
 01 LS-SY                  FLOAT-LONG.
 01 LS-SZ                  FLOAT-LONG.
 01 LS-AX                  FLOAT-LONG.
 01 LS-AY                  FLOAT-LONG.
 01 LS-AZ                  FLOAT-LONG.
 01 LS-HANDLE              BINARY-LONG.
 01 LS-ROOT                BINARY-LONG.
 01 LS-COORD               BINARY-LONG.
 01 LS-FROM                BINARY-LONG.
 01 LS-TO                  BINARY-LONG.
 01 LS-OP                  BINARY-LONG.
 01 LS-OP-ADD              BINARY-LONG VALUE 1.
 01 LS-OP-SUB              BINARY-LONG VALUE 2.
 01 LS-OP-MUL              BINARY-LONG VALUE 3.
 01 LS-OP-DIV              BINARY-LONG VALUE 4.
 01 LS-KEY                 PIC X(112).
 LINKAGE SECTION.
 01 L-NODE                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-NODE L-X L-Y L-Z L-RESULT.
     MOVE 0 TO L-RESULT
     EVALUATE WGN-TYPE(L-NODE)
         WHEN 0
             MOVE WGN-TEXT-1(L-NODE)(1:112) TO LS-KEY
             CALL "WG-FIND" USING WS-KIND LS-KEY LS-ROOT
             CALL "DENSITY-NODE" USING LS-ROOT L-X L-Y L-Z L-RESULT
         WHEN 1
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WGN-NUM(L-NODE, 1) L-RESULT
         WHEN 2 THRU 5
             COMPUTE LS-OP = WGN-TYPE(L-NODE) - 1
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 1) L-X L-Y L-Z LS-A
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 2) L-X L-Y L-Z LS-B
             CALL "DENSITY-F32" USING LS-OP LS-A LS-B L-RESULT
         WHEN 6
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 1) L-X L-Y L-Z LS-A
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 2) L-X L-Y L-Z LS-B
             IF LS-B < LS-A
                 MOVE LS-B TO L-RESULT
             ELSE
                 MOVE LS-A TO L-RESULT
             END-IF
         WHEN 7
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 1) L-X L-Y L-Z LS-A
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 2) L-X L-Y L-Z LS-B
             IF LS-B > LS-A
                 MOVE LS-B TO L-RESULT
             ELSE
                 MOVE LS-A TO L-RESULT
             END-IF
         WHEN 8
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 1) L-X L-Y L-Z LS-A
             CALL STATIC "cc_f64_abs_f32" USING BY REFERENCE LS-A L-RESULT
         WHEN 9
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 1) L-X L-Y L-Z LS-A
             MOVE LS-A TO LS-B
             CALL "DENSITY-F32" USING LS-OP-MUL LS-A LS-B L-RESULT
         WHEN 10
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 1) L-X L-Y L-Z LS-A
             MOVE LS-A TO LS-C
             CALL "DENSITY-F32" USING LS-OP-MUL LS-A LS-C LS-B
             CALL "DENSITY-F32" USING LS-OP-MUL LS-B LS-A L-RESULT
         WHEN 11
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 1) L-X L-Y L-Z LS-A
             CALL STATIC "cc_f64_mul" USING BY REFERENCE LS-A WS-MINUS-ONE L-RESULT
         WHEN 12
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 1) L-X L-Y L-Z LS-A
             CALL STATIC "cc_f64_sqrt" USING BY REFERENCE LS-A LS-B
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE LS-B L-RESULT
         WHEN 13
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 1) L-X L-Y L-Z LS-A
             CALL "DENSITY-F32" USING LS-OP-DIV WS-ONE LS-A L-RESULT
         WHEN 14
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 1) L-X L-Y L-Z LS-A
             CALL STATIC "cc_f64_log" USING BY REFERENCE LS-A LS-B
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE LS-B L-RESULT
         WHEN 15
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 1) L-X L-Y L-Z LS-A
             CALL STATIC "cc_f64_signum" USING BY REFERENCE LS-A L-RESULT
         WHEN 16
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 1) L-X L-Y L-Z LS-A
             IF LS-A > 0
                 MOVE LS-A TO L-RESULT
             ELSE
                 CALL "DENSITY-F32" USING LS-OP-MUL LS-A WS-HALF L-RESULT
             END-IF
         WHEN 17
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 1) L-X L-Y L-Z LS-A
             IF LS-A > 0
                 MOVE LS-A TO L-RESULT
             ELSE
                 CALL "DENSITY-F32" USING LS-OP-MUL LS-A WS-QUARTER L-RESULT
             END-IF
         WHEN 18
*>           squeeze: c = clamp(v, -1, 1); c / 2 - c * c * c / 24
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 1) L-X L-Y L-Z LS-A
             CALL STATIC "cc_f64_clamp_f32" USING BY REFERENCE LS-A WS-MINUS-ONE WS-ONE LS-C
             CALL "DENSITY-F32" USING LS-OP-DIV LS-C WS-TWO LS-T
             MOVE LS-C TO LS-B
             CALL "DENSITY-F32" USING LS-OP-MUL LS-C LS-B LS-U
             CALL "DENSITY-F32" USING LS-OP-MUL LS-U LS-C LS-V
             CALL "DENSITY-F32" USING LS-OP-DIV LS-V WS-24 LS-U
             CALL "DENSITY-F32" USING LS-OP-SUB LS-T LS-U L-RESULT
         WHEN 19
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 1) L-X L-Y L-Z L-RESULT
         WHEN 20
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 1) L-X L-Y L-Z L-RESULT
         WHEN 21
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 1) L-X L-Y L-Z LS-A
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WGN-NUM(L-NODE, 1) LS-LO
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WGN-NUM(L-NODE, 2) LS-HI
             CALL STATIC "cc_f64_clamp_f32" USING BY REFERENCE LS-A LS-LO LS-HI L-RESULT
         WHEN 22
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 1) L-X L-Y L-Z LS-A
             EVALUATE TRUE
                 WHEN LS-A = 0
                     CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 2) L-X L-Y L-Z L-RESULT
                 WHEN LS-A = 1
                     CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 3) L-X L-Y L-Z L-RESULT
                 WHEN OTHER
                     CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 2) L-X L-Y L-Z LS-B
                     CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 3) L-X L-Y L-Z LS-C
                     CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE LS-A LS-B LS-C L-RESULT
             END-EVALUATE
         WHEN 23
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 1) L-X L-Y L-Z LS-A
             IF LS-A >= WGN-NUM(L-NODE, 1) AND LS-A < WGN-NUM(L-NODE, 2)
                 CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 2) L-X L-Y L-Z L-RESULT
             ELSE
                 CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 3) L-X L-Y L-Z L-RESULT
             END-IF
         WHEN 24
*>           gradient: from + (float)(c - from_coordinate) * ((to - from) / (float)(to_coordinate - from_coordinate))
             IF WGN-TEXT-1(L-NODE)(1:1) = "y"
                 MOVE 1 TO DM-USES-Y
             END-IF
             EVALUATE WGN-TEXT-1(L-NODE)(1:1)
                 WHEN "x"
                     MOVE L-X TO LS-COORD
                 WHEN "y"
                     MOVE L-Y TO LS-COORD
                 WHEN OTHER
                     MOVE L-Z TO LS-COORD
             END-EVALUATE
             MOVE WGN-INT(L-NODE, 1) TO LS-FROM
             MOVE WGN-INT(L-NODE, 2) TO LS-TO
             IF LS-FROM < LS-TO
                 COMPUTE LS-COORD = FUNCTION MAX(LS-FROM, FUNCTION MIN(LS-TO, LS-COORD))
             ELSE
                 COMPUTE LS-COORD = FUNCTION MAX(LS-TO, FUNCTION MIN(LS-FROM, LS-COORD))
             END-IF
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WGN-NUM(L-NODE, 1) LS-LO
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WGN-NUM(L-NODE, 2) LS-HI
             CALL "DENSITY-F32" USING LS-OP-SUB LS-HI LS-LO LS-T
             COMPUTE LS-OP = LS-TO - LS-FROM
             CALL STATIC "cc_f64_i32_to_f32" USING BY REFERENCE LS-OP LS-U
             CALL "DENSITY-F32" USING LS-OP-DIV LS-T LS-U LS-A
             COMPUTE LS-OP = LS-COORD - LS-FROM
             CALL STATIC "cc_f64_i32_to_f32" USING BY REFERENCE LS-OP LS-U
             CALL "DENSITY-F32" USING LS-OP-MUL LS-U LS-A LS-B
             CALL "DENSITY-F32" USING LS-OP-ADD LS-LO LS-B L-RESULT
         WHEN 25
*>           noise: N.get(x * xz_scale + shift_x, y * y_scale + shift_y, z * xz_scale + shift_z)
             MOVE WGN-TEXT-1(L-NODE)(1:112) TO LS-KEY
             CALL "DENSITY-NOISE-HANDLE" USING LS-KEY LS-HANDLE
             IF LS-HANDLE = 0
                 GOBACK
             END-IF
             IF WGN-NUM(L-NODE, 2) NOT = 0
                 MOVE 1 TO DM-USES-Y
             END-IF
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 1) L-X L-Y L-Z LS-SX
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 2) L-X L-Y L-Z LS-SY
             CALL "DENSITY-NODE" USING WGN-CHILD(L-NODE, 3) L-X L-Y L-Z LS-SZ
             MOVE L-X TO LS-XD
             MOVE L-Y TO LS-YD
             MOVE L-Z TO LS-ZD
             CALL STATIC "cc_f64_mul" USING BY REFERENCE LS-XD WGN-NUM(L-NODE, 1) LS-T
             CALL STATIC "cc_f64_add" USING BY REFERENCE LS-T LS-SX LS-AX
             CALL STATIC "cc_f64_mul" USING BY REFERENCE LS-YD WGN-NUM(L-NODE, 2) LS-T
             CALL STATIC "cc_f64_add" USING BY REFERENCE LS-T LS-SY LS-AY
             CALL STATIC "cc_f64_mul" USING BY REFERENCE LS-ZD WGN-NUM(L-NODE, 1) LS-T
             CALL STATIC "cc_f64_add" USING BY REFERENCE LS-T LS-SZ LS-AZ
             CALL "NOISE-GET" USING LS-HANDLE LS-AX LS-AY LS-AZ L-RESULT
         WHEN 26 THRU 28
*>           shift_a (x/4, 0, z/4), shift_b (z/4, x/4, 0), shift (x/4, y/4, z/4): 4 * noise, float32
             MOVE WGN-TEXT-1(L-NODE)(1:112) TO LS-KEY
             CALL "DENSITY-NOISE-HANDLE" USING LS-KEY LS-HANDLE
             IF LS-HANDLE = 0
                 GOBACK
             END-IF
             MOVE L-X TO LS-XD
             MOVE L-Y TO LS-YD
             MOVE L-Z TO LS-ZD
             CALL STATIC "cc_f64_mul" USING BY REFERENCE LS-XD WS-QUARTER LS-SX
             CALL STATIC "cc_f64_mul" USING BY REFERENCE LS-YD WS-QUARTER LS-SY
             CALL STATIC "cc_f64_mul" USING BY REFERENCE LS-ZD WS-QUARTER LS-SZ
             EVALUATE WGN-TYPE(L-NODE)
                 WHEN 26
                     CALL "NOISE-GET" USING LS-HANDLE LS-SX WS-ZERO LS-SZ LS-A
                 WHEN 27
                     CALL "NOISE-GET" USING LS-HANDLE LS-SZ LS-SX WS-ZERO LS-A
                 WHEN OTHER
                     MOVE 1 TO DM-USES-Y
                     CALL "NOISE-GET" USING LS-HANDLE LS-SX LS-SY LS-SZ LS-A
             END-EVALUATE
             CALL "DENSITY-F32" USING LS-OP-MUL WS-FOUR LS-A L-RESULT
         WHEN 29
             CALL "DENSITY-SPLINE" USING WGN-INT(L-NODE, 1) L-X L-Y L-Z L-RESULT
         WHEN 30
             MOVE 1 TO DM-IMPURE
             CALL "DENSITY-BLENDED" USING L-NODE L-X L-Y L-Z L-RESULT
         WHEN 31
             MOVE 1 TO DM-IMPURE
             CALL "DENSITY-TOP-SURFACE" USING L-NODE L-X L-Y L-Z L-RESULT
         WHEN 32
             MOVE 1 TO DM-IMPURE
             CALL "DENSITY-INTERPOLATED" USING L-NODE L-X L-Y L-Z L-RESULT
         WHEN 33
             MOVE WS-ONE TO L-RESULT
         WHEN OTHER
*>           blend_offset and beardifier are 0 without blending data and structures; the types the overworld
*>           terrain does not use (after 35) evaluate to 0 here.
             MOVE WS-ZERO TO L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM DENSITY-NODE-RAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DENSITY-EVAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-ROOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(112).
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-KEY L-X L-Y L-Z L-RESULT.
     CALL "WG-FIND" USING WS-KIND L-KEY WS-ROOT
     CALL "DENSITY-NODE" USING WS-ROOT L-X L-Y L-Z L-RESULT
     GOBACK.
 END PROGRAM DENSITY-EVAL.
