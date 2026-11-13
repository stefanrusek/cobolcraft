*> The noise primitives of world generation (docs/protocol/10 section 3; NOISE.cpy): improved (gradient)
*> noise, its smeared variant, octave stacks and normal noise. Every float32 value of the reference is
*> held as a FLOAT-LONG that is exactly a float32 and every step that the reference does in float32 is
*> one cc_f64 operation followed by cc_f64_f32_round (10 section 16): COMPUTE on floats is not IEEE
*> exact (decimal intermediates), so no float arithmetic is written in COBOL. Doubles that the reference
*> keeps in double (frequencies, offsets, coordinates) are cc_f64 operations without the rounding.
*>
*> Entry points:
*>   NOISE-RESET                                      empties the store
*>   PERLIN-CREATE USING state (XR-STATE), fudge (FLOAT-LONG, 0 for a plain octave), index out
*>   PERLIN-GET USING index, x, y, z (FLOAT-LONG), result out (FLOAT-LONG, a float32 value)
*>   NOISE-CREATE USING factory (XR pair), name (PIC X(64)), name length, base octave, octave count
*>     (BINARY-LONG), base amplitude (FLOAT-LONG), modifiers (32 FLOAT-LONG), modifier count (0 = all 1.0),
*>     normalize (0 enabled, 1 disabled), handle out (BINARY-LONG)
*>   NOISE-GET USING handle, x, y, z (FLOAT-LONG), result out (FLOAT-LONG, a float32 value)
*>   NOISE-SMEARED-STACK USING state (XR-STATE), first octave (BINARY-LONG), y scale, amplitude base (FLOAT-LONG),
*>     handle out: the octave stack of old_blended_noise (10 section 3.4, fbm)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NOISE-RESET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NOISE.
 PROCEDURE DIVISION.
     MOVE 0 TO NZ-PERLIN-COUNT NZ-LAYER-COUNT NZ-NOISE-COUNT
     ADD 1 TO NZ-GEN
     GOBACK.
 END PROGRAM NOISE-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERLIN-CREATE.
*> 10 section 3.1 construction: three offset draws (nextDouble * 256), then the shuffle of 0..255.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NOISE.
 01 WS-D                   FLOAT-LONG.
 01 WS-256                 FLOAT-LONG VALUE 256.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-T                   BINARY-SHORT UNSIGNED.
 01 WS-TARGET              BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FUDGE                FLOAT-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FUDGE L-INDEX.
     ADD 1 TO NZ-PERLIN-COUNT
     MOVE NZ-PERLIN-COUNT TO L-INDEX
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-D WS-256 NZ-OX(L-INDEX)
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-D WS-256 NZ-OY(L-INDEX)
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-D WS-256 NZ-OZ(L-INDEX)
     MOVE L-FUDGE TO NZ-FUDGE(L-INDEX)
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 255
         COMPUTE NZ-PERM(L-INDEX, WS-I + 1) = WS-I
     END-PERFORM
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 255
         COMPUTE WS-BOUND = 256 - WS-I
         CALL "XORO-NEXT-INT" USING L-STATE WS-BOUND WS-J
         COMPUTE WS-TARGET = WS-I + WS-J + 1
         MOVE NZ-PERM(L-INDEX, WS-I + 1) TO WS-T
         MOVE NZ-PERM(L-INDEX, WS-TARGET) TO NZ-PERM(L-INDEX, WS-I + 1)
         MOVE WS-T TO NZ-PERM(L-INDEX, WS-TARGET)
     END-PERFORM
     GOBACK.
 END PROGRAM PERLIN-CREATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NOISE-WRAP.
*> USING d (FLOAT-LONG), result out: GradientNoise.wrap (10 section 3.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INIT                BINARY-LONG VALUE 0.
 01 WS-2P24                FLOAT-LONG VALUE 16777216.
 01 WS-HALF                FLOAT-LONG.
 01 WS-NEG-HALF            FLOAT-LONG.
 01 WS-2P25                FLOAT-LONG VALUE 33554432.
 01 WS-ONE-HALF            FLOAT-LONG VALUE 0.5.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-T                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-D                    FLOAT-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-D L-RESULT.
     IF WS-INIT = 0
         CALL STATIC "cc_f64_nextdown" USING BY REFERENCE WS-2P24 WS-HALF
         CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-ZERO WS-HALF WS-NEG-HALF
         MOVE 1 TO WS-INIT
     END-IF
     IF L-D >= WS-NEG-HALF AND L-D < WS-HALF
         MOVE L-D TO L-RESULT
         GOBACK
     END-IF
     CALL STATIC "cc_f64_div" USING BY REFERENCE L-D WS-2P25 WS-T
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-T WS-ONE-HALF WS-U
     CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-U WS-T
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-T WS-2P25 WS-U
     CALL STATIC "cc_f64_sub" USING BY REFERENCE L-D WS-U L-RESULT
     GOBACK.
 END PROGRAM NOISE-WRAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NOISE-SMOOTH.
*> USING t (a float32 value), result out: smooth(t) = t*t*t*(t*(t*6 - 15) + 10), every step float32.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-6                   FLOAT-LONG VALUE 6.
 01 WS-15                  FLOAT-LONG VALUE 15.
 01 WS-10                  FLOAT-LONG VALUE 10.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-COPY                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-T                    FLOAT-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-T L-RESULT.
     MOVE L-T TO WS-COPY
     CALL STATIC "cc_f64_mul" USING BY REFERENCE L-T WS-COPY WS-T
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-A
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-A L-T WS-T
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-B
     CALL STATIC "cc_f64_mul" USING BY REFERENCE L-T WS-6 WS-T
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-A
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-A WS-15 WS-T
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-A
     CALL STATIC "cc_f64_mul" USING BY REFERENCE L-T WS-A WS-T
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-A
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-A WS-10 WS-T
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-C
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-B WS-C WS-T
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T L-RESULT
     GOBACK.
 END PROGRAM NOISE-SMOOTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NOISE-GRAD-DOT.
*> USING hash (BINARY-LONG 0 to 15), the three float32 offsets (a table of three FLOAT-LONG), result out:
*> the dot product of gradient `hash` of 10 section 3.1 with them. Every gradient has exactly two non-zero
*> components of 1 or -1, so the left-to-right float32 sum is one float32 add or subtract of two of the
*> offsets (a product with 0 or +-1 is exact), negated for (-1, -1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC 9(3) VALUE 112.
    05 FILLER PIC 9(3) VALUE 221.
    05 FILLER PIC 9(3) VALUE 212.
    05 FILLER PIC 9(3) VALUE 312.
    05 FILLER PIC 9(3) VALUE 113.
    05 FILLER PIC 9(3) VALUE 231.
    05 FILLER PIC 9(3) VALUE 213.
    05 FILLER PIC 9(3) VALUE 313.
    05 FILLER PIC 9(3) VALUE 123.
    05 FILLER PIC 9(3) VALUE 232.
    05 FILLER PIC 9(3) VALUE 223.
    05 FILLER PIC 9(3) VALUE 323.
 01 WS-ROW-TABLE REDEFINES WS-ROWS.
    05 WS-ROW.
       10 WS-OP            PIC 9.
       10 WS-P1            PIC 9.
       10 WS-P2            PIC 9.
 01 WS-CODE REDEFINES WS-ROWS.
    05 WS-CODES            PIC 9(3) OCCURS 12 TIMES.
 01 WS-H                   BINARY-LONG.
 01 WS-ENTRY.
    05 WS-E-OP             PIC 9.
    05 WS-E-P1             PIC 9.
    05 WS-E-P2             PIC 9.
 01 WS-ENTRY-NUM REDEFINES WS-ENTRY PIC 9(3).
 01 WS-T                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-OPERAND-1           FLOAT-LONG.
 01 WS-OPERAND-2           FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-HASH                 BINARY-LONG.
 01 L-F.
    05 L-F-ITEM            FLOAT-LONG OCCURS 3 TIMES.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-HASH L-F L-RESULT.
*>   hashes 12 to 15 repeat the entries of 0, 9, 1 and 11
     MOVE L-HASH TO WS-H
     EVALUATE WS-H
         WHEN 12 MOVE 0 TO WS-H
         WHEN 13 MOVE 9 TO WS-H
         WHEN 14 MOVE 1 TO WS-H
         WHEN 15 MOVE 11 TO WS-H
     END-EVALUATE
     MOVE WS-CODES(WS-H + 1) TO WS-ENTRY-NUM
     MOVE L-F-ITEM(WS-E-P1) TO WS-OPERAND-1
     MOVE L-F-ITEM(WS-E-P2) TO WS-OPERAND-2
     EVALUATE WS-E-OP
         WHEN 1
             CALL STATIC "cc_f64_add" USING BY REFERENCE WS-OPERAND-1 WS-OPERAND-2 WS-T
         WHEN 2
             CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-OPERAND-1 WS-OPERAND-2 WS-T
         WHEN OTHER
             CALL STATIC "cc_f64_add" USING BY REFERENCE WS-OPERAND-1 WS-OPERAND-2 WS-U
             CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-ZERO WS-U WS-T
     END-EVALUATE
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T L-RESULT
     GOBACK.
 END PROGRAM NOISE-GRAD-DOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NOISE-FRACTION.
*> USING coordinate (double, already wrapped), offset (double), integer part out (BINARY-LONG), fraction
*> out (the double x' - floor(x'), exact), x' out: x' = coordinate + offset, floor, fraction.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FLOOR               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-C                    FLOAT-LONG.
 01 L-OFFSET               FLOAT-LONG.
 01 L-INT                  BINARY-LONG.
 01 L-FRACTION             FLOAT-LONG.
 01 L-SHIFTED              FLOAT-LONG.
 PROCEDURE DIVISION USING L-C L-OFFSET L-INT L-FRACTION L-SHIFTED.
     CALL STATIC "cc_f64_add" USING BY REFERENCE L-C L-OFFSET L-SHIFTED
     CALL STATIC "cc_f64_floor" USING BY REFERENCE L-SHIFTED WS-FLOOR
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-FLOOR L-INT
     CALL STATIC "cc_f64_sub" USING BY REFERENCE L-SHIFTED WS-FLOOR L-FRACTION
     GOBACK.
 END PROGRAM NOISE-FRACTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NOISE-TRILERP.
*> USING sx, sy, sz (smoothed fractions), the eight corner gradients (table of eight FLOAT-LONG, order 000
*> 100 010 110 001 101 011 111), result out: lerp(sz, lerp(sy, lerp(sx, g000, g100), lerp(sx, g010, g110)),
*> lerp(sy, lerp(sx, g001, g101), lerp(sx, g011, g111))), every lerp float32 (10 section 3.1 step 6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-G1                  FLOAT-LONG.
 01 WS-G2                  FLOAT-LONG.
 01 WS-G3                  FLOAT-LONG.
 01 WS-G4                  FLOAT-LONG.
 01 WS-G5                  FLOAT-LONG.
 01 WS-G6                  FLOAT-LONG.
 01 WS-G7                  FLOAT-LONG.
 01 WS-G8                  FLOAT-LONG.
 01 WS-M1                  FLOAT-LONG.
 01 WS-M2                  FLOAT-LONG.
 01 WS-M3                  FLOAT-LONG.
 01 WS-M4                  FLOAT-LONG.
 01 WS-N1                  FLOAT-LONG.
 01 WS-N2                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SX                   FLOAT-LONG.
 01 L-SY                   FLOAT-LONG.
 01 L-SZ                   FLOAT-LONG.
 01 L-G.
    05 L-G-ITEM            FLOAT-LONG OCCURS 8 TIMES.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-SX L-SY L-SZ L-G L-RESULT.
     MOVE L-G-ITEM(1) TO WS-G1
     MOVE L-G-ITEM(2) TO WS-G2
     MOVE L-G-ITEM(3) TO WS-G3
     MOVE L-G-ITEM(4) TO WS-G4
     MOVE L-G-ITEM(5) TO WS-G5
     MOVE L-G-ITEM(6) TO WS-G6
     MOVE L-G-ITEM(7) TO WS-G7
     MOVE L-G-ITEM(8) TO WS-G8
     CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE L-SX WS-G1 WS-G2 WS-M1
     CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE L-SX WS-G3 WS-G4 WS-M2
     CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE L-SX WS-G5 WS-G6 WS-M3
     CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE L-SX WS-G7 WS-G8 WS-M4
     CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE L-SY WS-M1 WS-M2 WS-N1
     CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE L-SY WS-M3 WS-M4 WS-N2
     CALL STATIC "cc_f64_lerp_f32" USING BY REFERENCE L-SZ WS-N1 WS-N2 L-RESULT
     GOBACK.
 END PROGRAM NOISE-TRILERP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERLIN-GET.
*> 10 sections 3.1 and 3.4 get(x, y, z). A smeared octave (NZ-FUDGE not 0) replaces fy in the gradients
*> by fyG = (float)(yFrac - fudge) with fudge = floor(base / scale + 1.0000000116860974E-7) * scale,
*> base = y when 0 <= y < yFrac else yFrac, and smooths with (float) yFrac.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NOISE.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-SMEAR-EPSILON       FLOAT-LONG.
 01 WS-EPSILON-TEXT        PIC X(32) VALUE Z"1.0000000116860974E-7".
 01 WS-INIT                BINARY-LONG VALUE 0.
*> index & 255 and perm & 15 without FUNCTION MOD (each call is a decimal conversion under libcob): the low byte of a BINARY-LONG
*> (little-endian, as every other REDEFINES of the project's targets) is the non-negative remainder for a negative sum too.
 01 WS-SUM                 BINARY-LONG.
 01 WS-SUM-BYTES REDEFINES WS-SUM.
    05 WS-SUM-LOW          BINARY-CHAR UNSIGNED.
    05 FILLER              PIC X(3).
 01 WS-M16-TABLE.
    05 WS-M16              BINARY-LONG OCCURS 256 TIMES.
 01 WS-M16-I               BINARY-LONG.
 01 WS-WX                  FLOAT-LONG.
 01 WS-WY                  FLOAT-LONG.
 01 WS-WZ                  FLOAT-LONG.
 01 WS-SHIFT-X             FLOAT-LONG.
 01 WS-SHIFT-Y             FLOAT-LONG.
 01 WS-SHIFT-Z             FLOAT-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IY                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-FRAC-X              FLOAT-LONG.
 01 WS-FRAC-Y              FLOAT-LONG.
 01 WS-FRAC-Z              FLOAT-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-FYS                 FLOAT-LONG.
 01 WS-FXM                 FLOAT-LONG.
 01 WS-FYM                 FLOAT-LONG.
 01 WS-FZM                 FLOAT-LONG.
 01 WS-BASE                FLOAT-LONG.
 01 WS-FUDGE               FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-AA                  BINARY-LONG.
 01 WS-AB                  BINARY-LONG.
 01 WS-BA                  BINARY-LONG.
 01 WS-BB                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-F.
    05 WS-F-ITEM           FLOAT-LONG OCCURS 3 TIMES.
 01 WS-G.
    05 WS-G-ITEM           FLOAT-LONG OCCURS 8 TIMES.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-L.
    05 WS-L-ITEM           FLOAT-LONG OCCURS 6 TIMES.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-INDEX L-X L-Y L-Z L-RESULT.
     IF WS-INIT = 0
         CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-EPSILON-TEXT WS-SMEAR-EPSILON
         PERFORM VARYING WS-M16-I FROM 0 BY 1 UNTIL WS-M16-I > 255
             COMPUTE WS-M16(WS-M16-I + 1) = FUNCTION MOD(WS-M16-I, 16)
         END-PERFORM
         MOVE 1 TO WS-INIT
     END-IF
     CALL "NOISE-WRAP" USING L-X WS-WX
     CALL "NOISE-WRAP" USING L-Y WS-WY
     CALL "NOISE-WRAP" USING L-Z WS-WZ
     CALL "NOISE-FRACTION" USING WS-WX NZ-OX(L-INDEX) WS-IX WS-FRAC-X WS-SHIFT-X
     CALL "NOISE-FRACTION" USING WS-WY NZ-OY(L-INDEX) WS-IY WS-FRAC-Y WS-SHIFT-Y
     CALL "NOISE-FRACTION" USING WS-WZ NZ-OZ(L-INDEX) WS-IZ WS-FRAC-Z WS-SHIFT-Z
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-FRAC-X WS-FX
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-FRAC-Y WS-FYS
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-FRAC-Z WS-FZ
     MOVE WS-FYS TO WS-FY
     IF NZ-FUDGE(L-INDEX) NOT = 0
         IF L-Y >= 0 AND L-Y < WS-FRAC-Y
             MOVE L-Y TO WS-BASE
         ELSE
             MOVE WS-FRAC-Y TO WS-BASE
         END-IF
         CALL STATIC "cc_f64_div" USING BY REFERENCE WS-BASE NZ-FUDGE(L-INDEX) WS-T
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-T WS-SMEAR-EPSILON WS-U
         CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-U WS-T
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-T NZ-FUDGE(L-INDEX) WS-FUDGE
         CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-FRAC-Y WS-FUDGE WS-T
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-FY
     END-IF
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-FX WS-ONE WS-T
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-FXM
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-FY WS-ONE WS-T
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-FYM
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-FZ WS-ONE WS-T
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-FZM
*>   permutation lookups (index & 255 is the non-negative remainder)
     COMPUTE WS-SUM = WS-IX
     COMPUTE WS-K = WS-SUM-LOW + 1
     MOVE NZ-PERM(L-INDEX, WS-K) TO WS-A
     COMPUTE WS-SUM = WS-IX + 1
     COMPUTE WS-K = WS-SUM-LOW + 1
     MOVE NZ-PERM(L-INDEX, WS-K) TO WS-B
     COMPUTE WS-SUM = WS-A + WS-IY
     COMPUTE WS-K = WS-SUM-LOW + 1
     MOVE NZ-PERM(L-INDEX, WS-K) TO WS-AA
     COMPUTE WS-SUM = WS-A + WS-IY + 1
     COMPUTE WS-K = WS-SUM-LOW + 1
     MOVE NZ-PERM(L-INDEX, WS-K) TO WS-AB
     COMPUTE WS-SUM = WS-B + WS-IY
     COMPUTE WS-K = WS-SUM-LOW + 1
     MOVE NZ-PERM(L-INDEX, WS-K) TO WS-BA
     COMPUTE WS-SUM = WS-B + WS-IY + 1
     COMPUTE WS-K = WS-SUM-LOW + 1
     MOVE NZ-PERM(L-INDEX, WS-K) TO WS-BB
*>   corners 1 to 8: 000 100 010 110 001 101 011 111
     MOVE WS-FX TO WS-F-ITEM(1) MOVE WS-FY TO WS-F-ITEM(2) MOVE WS-FZ TO WS-F-ITEM(3)
     COMPUTE WS-SUM = WS-AA + WS-IZ
     COMPUTE WS-K = WS-SUM-LOW + 1
     MOVE NZ-PERM(L-INDEX, WS-K) TO WS-H
     COMPUTE WS-H = WS-M16(WS-H + 1)
     CALL "NOISE-GRAD-DOT" USING WS-H WS-F WS-G-ITEM(1)
     MOVE WS-FXM TO WS-F-ITEM(1)
     COMPUTE WS-SUM = WS-BA + WS-IZ
     COMPUTE WS-K = WS-SUM-LOW + 1
     MOVE NZ-PERM(L-INDEX, WS-K) TO WS-H
     COMPUTE WS-H = WS-M16(WS-H + 1)
     CALL "NOISE-GRAD-DOT" USING WS-H WS-F WS-G-ITEM(2)
     MOVE WS-FX TO WS-F-ITEM(1) MOVE WS-FYM TO WS-F-ITEM(2)
     COMPUTE WS-SUM = WS-AB + WS-IZ
     COMPUTE WS-K = WS-SUM-LOW + 1
     MOVE NZ-PERM(L-INDEX, WS-K) TO WS-H
     COMPUTE WS-H = WS-M16(WS-H + 1)
     CALL "NOISE-GRAD-DOT" USING WS-H WS-F WS-G-ITEM(3)
     MOVE WS-FXM TO WS-F-ITEM(1)
     COMPUTE WS-SUM = WS-BB + WS-IZ
     COMPUTE WS-K = WS-SUM-LOW + 1
     MOVE NZ-PERM(L-INDEX, WS-K) TO WS-H
     COMPUTE WS-H = WS-M16(WS-H + 1)
     CALL "NOISE-GRAD-DOT" USING WS-H WS-F WS-G-ITEM(4)
     MOVE WS-FX TO WS-F-ITEM(1) MOVE WS-FY TO WS-F-ITEM(2) MOVE WS-FZM TO WS-F-ITEM(3)
     COMPUTE WS-SUM = WS-AA + WS-IZ + 1
     COMPUTE WS-K = WS-SUM-LOW + 1
     MOVE NZ-PERM(L-INDEX, WS-K) TO WS-H
     COMPUTE WS-H = WS-M16(WS-H + 1)
     CALL "NOISE-GRAD-DOT" USING WS-H WS-F WS-G-ITEM(5)
     MOVE WS-FXM TO WS-F-ITEM(1)
     COMPUTE WS-SUM = WS-BA + WS-IZ + 1
     COMPUTE WS-K = WS-SUM-LOW + 1
     MOVE NZ-PERM(L-INDEX, WS-K) TO WS-H
     COMPUTE WS-H = WS-M16(WS-H + 1)
     CALL "NOISE-GRAD-DOT" USING WS-H WS-F WS-G-ITEM(6)
     MOVE WS-FX TO WS-F-ITEM(1) MOVE WS-FYM TO WS-F-ITEM(2)
     COMPUTE WS-SUM = WS-AB + WS-IZ + 1
     COMPUTE WS-K = WS-SUM-LOW + 1
     MOVE NZ-PERM(L-INDEX, WS-K) TO WS-H
     COMPUTE WS-H = WS-M16(WS-H + 1)
     CALL "NOISE-GRAD-DOT" USING WS-H WS-F WS-G-ITEM(7)
     MOVE WS-FXM TO WS-F-ITEM(1)
     COMPUTE WS-SUM = WS-BB + WS-IZ + 1
     COMPUTE WS-K = WS-SUM-LOW + 1
     MOVE NZ-PERM(L-INDEX, WS-K) TO WS-H
     COMPUTE WS-H = WS-M16(WS-H + 1)
     CALL "NOISE-GRAD-DOT" USING WS-H WS-F WS-G-ITEM(8)
     CALL "NOISE-SMOOTH" USING WS-FX WS-SX
     CALL "NOISE-SMOOTH" USING WS-FYS WS-SY
     CALL "NOISE-SMOOTH" USING WS-FZ WS-SZ
     CALL "NOISE-TRILERP" USING WS-SX WS-SY WS-SZ WS-G L-RESULT
     GOBACK.
 END PROGRAM PERLIN-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NOISE-CREATE.
*> 10 section 3.3: the octave list (a zero modifier advances the frequency and draws nothing), the
*> normalisation factor, then two forks of the named generator and two perlin octaves per octave.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NOISE.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-R== LEADING ==XR-== BY ==WS-R-==.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-A== LEADING ==XR-== BY ==WS-A-==.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-B== LEADING ==XR-== BY ==WS-B-==.
 COPY XORO REPLACING ==XR-STATE== BY ==WS-G== LEADING ==XR-== BY ==WS-G-==.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-TWO                 FLOAT-LONG VALUE 2.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-DEV-UNIT            FLOAT-LONG.
 01 WS-DEV-TEXT            PIC X(32) VALUE Z"0.2702247831245211".
 01 WS-SECOND-TEXT         PIC X(32) VALUE Z"1.0181268882175227".
 01 WS-THIRD-TEXT          PIC X(32) VALUE Z"0.3333333333333333".
 01 WS-SECOND              FLOAT-LONG.
 01 WS-THIRD               FLOAT-LONG.
 01 WS-FUDGE               FLOAT-LONG VALUE 0.
 01 WS-FREQ                FLOAT-LONG.
 01 WS-AMP                 FLOAT-LONG.
 01 WS-POW                 FLOAT-LONG.
 01 WS-DEN                 FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-OCTAVES.
    05 WS-OCTAVE OCCURS 32 TIMES.
       10 WS-O-INDEX       BINARY-LONG.
       10 WS-O-FREQ        FLOAT-LONG.
       10 WS-O-AMP         FLOAT-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SUM                 FLOAT-LONG.
 01 WS-SQ                  FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-T2                  FLOAT-LONG.
 01 WS-DEV                 FLOAT-LONG.
 01 WS-NF                  FLOAT-LONG.
 01 WS-MOD                 FLOAT-LONG.
 01 WS-NEG                 FLOAT-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-INDEX-EDIT          PIC -(9)9.
 01 WS-PA                  BINARY-LONG.
 01 WS-PB                  BINARY-LONG.
 01 WS-LAYER-AMP           FLOAT-LONG.
 LINKAGE SECTION.
 01 L-FACTORY.
    05 L-FLO               BINARY-DOUBLE UNSIGNED.
    05 L-FHI               BINARY-DOUBLE UNSIGNED.
 01 L-NAME                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-BASE                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-AMP                  FLOAT-LONG.
 01 L-MODS.
    05 L-MOD               FLOAT-LONG OCCURS 32 TIMES.
 01 L-MOD-COUNT            BINARY-LONG.
 01 L-NORMALIZE            BINARY-LONG.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-FACTORY L-NAME L-LENGTH L-BASE L-COUNT L-AMP L-MODS L-MOD-COUNT
         L-NORMALIZE L-HANDLE.
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-DEV-TEXT WS-DEV-UNIT
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-SECOND-TEXT WS-SECOND
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-THIRD-TEXT WS-THIRD
*>   frequency 2^base octave and amplitude (normalised: amp * 2^(n-1) / (2^n - 1))
     MOVE WS-ONE TO WS-FREQ
     IF L-BASE < 0
         COMPUTE WS-N = 0 - L-BASE
         PERFORM WS-N TIMES
             CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-FREQ WS-HALF WS-T
             MOVE WS-T TO WS-FREQ
         END-PERFORM
     ELSE
         PERFORM L-BASE TIMES
             CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-FREQ WS-TWO WS-T
             MOVE WS-T TO WS-FREQ
         END-PERFORM
     END-IF
     MOVE L-AMP TO WS-AMP
     IF L-NORMALIZE = 0
         MOVE WS-ONE TO WS-POW
         COMPUTE WS-N = L-COUNT - 1
         PERFORM WS-N TIMES
             CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-POW WS-TWO WS-T
             MOVE WS-T TO WS-POW
         END-PERFORM
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-AMP WS-POW WS-T
         MOVE WS-T TO WS-AMP
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-POW WS-TWO WS-T
         CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-T WS-ONE WS-DEN
         CALL STATIC "cc_f64_div" USING BY REFERENCE WS-AMP WS-DEN WS-T
         MOVE WS-T TO WS-AMP
     END-IF
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         IF L-MOD-COUNT = 0
             MOVE WS-ONE TO WS-MOD
         ELSE
             MOVE L-MOD(WS-I) TO WS-MOD
         END-IF
         IF WS-MOD NOT = 0
             ADD 1 TO WS-COUNT
             COMPUTE WS-O-INDEX(WS-COUNT) = L-BASE + WS-I - 1
             MOVE WS-FREQ TO WS-O-FREQ(WS-COUNT)
             CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-AMP WS-MOD WS-O-AMP(WS-COUNT)
         END-IF
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-FREQ WS-TWO WS-T
         MOVE WS-T TO WS-FREQ
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-AMP WS-HALF WS-T
         MOVE WS-T TO WS-AMP
     END-PERFORM
*>   normalisation factor: (sum * 1/3) / (sqrt(sum of (0.27 * |amp|)^2) * sqrt 2); 0 when the deviation is 0
     MOVE WS-ZERO TO WS-SUM WS-SQ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-SUM WS-O-AMP(WS-I) WS-T
         MOVE WS-T TO WS-SUM
         CALL STATIC "cc_f64_abs_f64" USING BY REFERENCE WS-O-AMP(WS-I) WS-U
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-DEV-UNIT WS-U WS-T
         MOVE WS-T TO WS-T2
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-T WS-T2 WS-U
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-SQ WS-U WS-T
         MOVE WS-T TO WS-SQ
     END-PERFORM
     CALL STATIC "cc_f64_sqrt" USING BY REFERENCE WS-SQ WS-DEV
     MOVE WS-ZERO TO WS-NF
     IF WS-DEV NOT = 0
         CALL STATIC "cc_f64_sqrt" USING BY REFERENCE WS-TWO WS-T
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-DEV WS-T WS-U
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-SUM WS-THIRD WS-T
         CALL STATIC "cc_f64_div" USING BY REFERENCE WS-T WS-U WS-NF
     END-IF
*>   the two forks of the named generator, then two octaves per octave of the list
     CALL "XORO-FROM-HASH" USING L-FACTORY L-NAME L-LENGTH WS-R
     CALL "XORO-FORK-POSITIONAL" USING WS-R WS-A
     CALL "XORO-FORK-POSITIONAL" USING WS-R WS-B
     ADD 1 TO NZ-NOISE-COUNT
     MOVE NZ-NOISE-COUNT TO L-HANDLE
     COMPUTE NZ-FIRST(L-HANDLE) = NZ-LAYER-COUNT + 1
     COMPUTE NZ-LAYER-N(L-HANDLE) = WS-COUNT * 2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         MOVE WS-O-INDEX(WS-I) TO WS-INDEX-EDIT
         MOVE SPACES TO WS-NAME
         STRING "octave_" FUNCTION TRIM(WS-INDEX-EDIT) DELIMITED BY SIZE INTO WS-NAME
         COMPUTE WS-LEN = 7 + FUNCTION LENGTH(FUNCTION TRIM(WS-INDEX-EDIT))
         CALL "XORO-FROM-HASH" USING WS-A WS-NAME WS-LEN WS-G
         CALL "PERLIN-CREATE" USING WS-G WS-FUDGE WS-PA
         CALL "XORO-FROM-HASH" USING WS-B WS-NAME WS-LEN WS-G
         CALL "PERLIN-CREATE" USING WS-G WS-FUDGE WS-PB
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-NF WS-O-AMP(WS-I) WS-T
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-LAYER-AMP
         ADD 1 TO NZ-LAYER-COUNT
         MOVE WS-PA TO NZ-L-PERLIN(NZ-LAYER-COUNT)
         MOVE WS-O-FREQ(WS-I) TO NZ-L-FREQ(NZ-LAYER-COUNT)
         MOVE WS-LAYER-AMP TO NZ-L-AMP(NZ-LAYER-COUNT)
         ADD 1 TO NZ-LAYER-COUNT
         MOVE WS-PB TO NZ-L-PERLIN(NZ-LAYER-COUNT)
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-O-FREQ(WS-I) WS-SECOND
             NZ-L-FREQ(NZ-LAYER-COUNT)
         MOVE WS-LAYER-AMP TO NZ-L-AMP(NZ-LAYER-COUNT)
     END-PERFORM
     GOBACK.
 END PROGRAM NOISE-CREATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NOISE-GET.
*> 10 section 3.2: acc = acc + amplitude * perlin(x * f, y * f, z * f) over the layers in order, float32.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NOISE.
 COPY GENSTAGE.
 01 WS-ACC                 FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-HANDLE               BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-X L-Y L-Z L-RESULT.
     ADD 1 TO GS-NOISE
     MOVE 0 TO WS-ACC
     COMPUTE WS-LAST = NZ-FIRST(L-HANDLE) + NZ-LAYER-N(L-HANDLE) - 1
     PERFORM VARYING WS-I FROM NZ-FIRST(L-HANDLE) BY 1 UNTIL WS-I > WS-LAST
         CALL STATIC "cc_f64_mul" USING BY REFERENCE L-X NZ-L-FREQ(WS-I) WS-X
         CALL STATIC "cc_f64_mul" USING BY REFERENCE L-Y NZ-L-FREQ(WS-I) WS-Y
         CALL STATIC "cc_f64_mul" USING BY REFERENCE L-Z NZ-L-FREQ(WS-I) WS-Z
         CALL "PERLIN-GET" USING NZ-L-PERLIN(WS-I) WS-X WS-Y WS-Z WS-V
         CALL STATIC "cc_f64_mul" USING BY REFERENCE NZ-L-AMP(WS-I) WS-V WS-T
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-U
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-ACC WS-U WS-T
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-ACC
     END-PERFORM
     MOVE WS-ACC TO L-RESULT
     GOBACK.
 END PROGRAM NOISE-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NOISE-SMEARED-STACK.
*> 10 section 3.4 fbm(r, firstOctave, yScale, ampBase): n = -firstOctave + 1 layers, highest frequency first (the
*> first perlin made is the layer of frequency 1): a smeared perlin of scale yScale * freq, frequency freq, amplitude
*> (float) ampBase, then freq / 2 and ampBase * 2; ampBase starts at ampBase / (2^n - 1). The draws come from the
*> one generator passed in, in layer order.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NOISE.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-TWO                 FLOAT-LONG VALUE 2.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-FREQ                FLOAT-LONG.
 01 WS-AMP                 FLOAT-LONG.
 01 WS-POW                 FLOAT-LONG.
 01 WS-DEN                 FLOAT-LONG.
 01 WS-FUDGE               FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-LAYER-AMP           FLOAT-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PERLIN              BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FIRST                BINARY-LONG.
 01 L-Y-SCALE              FLOAT-LONG.
 01 L-AMP                  FLOAT-LONG.
 01 L-HANDLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FIRST L-Y-SCALE L-AMP L-HANDLE.
     COMPUTE WS-N = 1 - L-FIRST
     MOVE WS-ONE TO WS-POW
     PERFORM WS-N TIMES
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-POW WS-TWO WS-T
         MOVE WS-T TO WS-POW
     END-PERFORM
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-POW WS-ONE WS-DEN
     CALL STATIC "cc_f64_div" USING BY REFERENCE L-AMP WS-DEN WS-AMP
     MOVE WS-ONE TO WS-FREQ
     ADD 1 TO NZ-NOISE-COUNT
     MOVE NZ-NOISE-COUNT TO L-HANDLE
     COMPUTE NZ-FIRST(L-HANDLE) = NZ-LAYER-COUNT + 1
     MOVE WS-N TO NZ-LAYER-N(L-HANDLE)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         CALL STATIC "cc_f64_mul" USING BY REFERENCE L-Y-SCALE WS-FREQ WS-FUDGE
         CALL "PERLIN-CREATE" USING L-STATE WS-FUDGE WS-PERLIN
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-AMP WS-LAYER-AMP
         ADD 1 TO NZ-LAYER-COUNT
         MOVE WS-PERLIN TO NZ-L-PERLIN(NZ-LAYER-COUNT)
         MOVE WS-FREQ TO NZ-L-FREQ(NZ-LAYER-COUNT)
         MOVE WS-LAYER-AMP TO NZ-L-AMP(NZ-LAYER-COUNT)
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-FREQ WS-HALF WS-T
         MOVE WS-T TO WS-FREQ
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-AMP WS-TWO WS-T
         MOVE WS-T TO WS-AMP
     END-PERFORM
     GOBACK.
 END PROGRAM NOISE-SMEARED-STACK.
