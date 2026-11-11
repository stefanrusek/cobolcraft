*> Worldgen features, part 2 (docs/protocol/35-worldgen-features-2-predicates-and-providers.md): the rules of block predicates (section 3), block state
*> providers (section 4), the noise-based providers (section 5), the corrections of section 7 and the RuleTest names (section 8), as pure programs over
*> explicit inputs (block states are integer codes, 0 meaning none where a result is optional). The draws are those of the Xoroshiro wrapped WorldgenRandom
*> (WGR-*, core/src/ores.cob); the legacy source is JRAND-* (core/src/rng-java.cob).
*>
*> Entry points (every one USING its arguments as the header of its program says):
*>   F352-ANCHOR, F352-GEN-CONTEXT, F352-READS-VOID          section 2 and 3.3 (vertical anchors, the generation context, reads outside the build height)
*>   F352-OFFSET-OK, F352-TAG-KEY-OK, F352-VOLUME-VALID, F352-VOLUME-CELL, F352-ANY-OF, F352-ALL-OF   section 3
*>   F352-ROTATED-DIRECTION, F352-AXIS-OF, F352-RANDOM-BLOCK, F352-RULE-BASED, F352-RANDOMIZED-INT, F352-COPY-COUNT   section 4
*>   F352-NOISE-INDEX, F352-DUAL-N, F352-THRESHOLD, F352-NORMAL-FACTOR, F352-LEGACY-KEYS, F352-JAVA-HASH, F352-OCTAVE-SEED   section 5
*>   F352-VARIETY, F352-NORMALIZE-FORM, F352-NOISE-PARAMS-OK    section 4.5 and 7
*>   F352-RULETEST-NAME    section 8

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-ANCHOR.
*> USING kind (1 absolute, 2 above_bottom, 3 below_top, 4 relative_to_sea_level), n, min y, height, sea level (BINARY-LONG), y out.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-MIN-Y                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-SEA                  BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-N L-MIN-Y L-HEIGHT L-SEA L-Y.
     EVALUATE L-KIND
         WHEN 1
             MOVE L-N TO L-Y
         WHEN 2
             COMPUTE L-Y = L-MIN-Y + L-N
         WHEN 3
             COMPUTE L-Y = L-MIN-Y + L-HEIGHT - 1 - L-N
         WHEN OTHER
             COMPUTE L-Y = L-SEA + L-N
     END-EVALUATE
     GOBACK.
 END PROGRAM F352-ANCHOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-GEN-CONTEXT.
*> Section 2 WorldGenerationContext of a world generation level: USING level min y, level height, generator min y, generator gen depth, min y out,
*> height out: max of the min ys, min of the heights.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEVEL-MIN            BINARY-LONG.
 01 L-LEVEL-HEIGHT         BINARY-LONG.
 01 L-GEN-MIN              BINARY-LONG.
 01 L-GEN-DEPTH            BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL-MIN L-LEVEL-HEIGHT L-GEN-MIN L-GEN-DEPTH L-MIN L-HEIGHT.
     MOVE L-LEVEL-MIN TO L-MIN
     IF L-GEN-MIN > L-LEVEL-MIN
         MOVE L-GEN-MIN TO L-MIN
     END-IF
     MOVE L-LEVEL-HEIGHT TO L-HEIGHT
     IF L-GEN-DEPTH < L-LEVEL-HEIGHT
         MOVE L-GEN-DEPTH TO L-HEIGHT
     END-IF
     GOBACK.
 END PROGRAM F352-GEN-CONTEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-READS-VOID.
*> Section 2 getBlockState: USING y, min y, height, flag out: 1 when the position is outside the build height (the read gives void_air).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-Y                    BINARY-LONG.
 01 L-MIN-Y                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-Y L-MIN-Y L-HEIGHT L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-Y < L-MIN-Y OR L-Y > L-MIN-Y + L-HEIGHT - 1
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM F352-READS-VOID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-OFFSET-OK.
*> Section 3.1 Vec3i.offsetCodec(16): USING x, y, z (BINARY-LONG), ok out: every absolute component at most 16.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-OK.
     MOVE 0 TO L-OK
     IF FUNCTION ABS(L-X) <= 16 AND FUNCTION ABS(L-Y) <= 16 AND FUNCTION ABS(L-Z) <= 16
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM F352-OFFSET-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-TAG-KEY-OK.
*> Section 3.1: USING text (PIC X(64)), ok out: a bare TagKey identifier has no leading "#".
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(64).
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-OK.
     MOVE 1 TO L-OK
     IF L-TEXT(1:1) = "#" OR L-TEXT = SPACES
         MOVE 0 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM F352-TAG-KEY-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-VOLUME-VALID.
*> Section 3.3 volume_match: USING min x, y, z, max x, y, z (BINARY-LONG), status out: 0 valid, 1 a component of min is above max, 2 a bound is out of
*> the offset range (16).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MIN-X                BINARY-LONG.
 01 L-MIN-Y                BINARY-LONG.
 01 L-MIN-Z                BINARY-LONG.
 01 L-MAX-X                BINARY-LONG.
 01 L-MAX-Y                BINARY-LONG.
 01 L-MAX-Z                BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-MIN-X L-MIN-Y L-MIN-Z L-MAX-X L-MAX-Y L-MAX-Z L-STATUS.
     MOVE 0 TO L-STATUS
     IF FUNCTION ABS(L-MIN-X) > 16 OR FUNCTION ABS(L-MIN-Y) > 16 OR FUNCTION ABS(L-MIN-Z) > 16
         OR FUNCTION ABS(L-MAX-X) > 16 OR FUNCTION ABS(L-MAX-Y) > 16 OR FUNCTION ABS(L-MAX-Z) > 16
         MOVE 2 TO L-STATUS
     ELSE
         IF L-MIN-X > L-MAX-X OR L-MIN-Y > L-MAX-Y OR L-MIN-Z > L-MAX-Z
             MOVE 1 TO L-STATUS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM F352-VOLUME-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-VOLUME-CELL.
*> Section 3.3 volume_match visiting order: USING min x, y, z, max x, y, z, k (0-based), dx, dy, dz out, count out (BINARY-LONG): the k-th offset of the
*> box with x outermost, then z, then y innermost, and the number of cells.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-MIN-X                BINARY-LONG.
 01 L-MIN-Y                BINARY-LONG.
 01 L-MIN-Z                BINARY-LONG.
 01 L-MAX-X                BINARY-LONG.
 01 L-MAX-Y                BINARY-LONG.
 01 L-MAX-Z                BINARY-LONG.
 01 L-K                    BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-MIN-X L-MIN-Y L-MIN-Z L-MAX-X L-MAX-Y L-MAX-Z L-K L-DX L-DY L-DZ L-COUNT.
     COMPUTE WS-SX = L-MAX-X - L-MIN-X + 1
     COMPUTE WS-SY = L-MAX-Y - L-MIN-Y + 1
     COMPUTE WS-SZ = L-MAX-Z - L-MIN-Z + 1
     COMPUTE L-COUNT = WS-SX * WS-SY * WS-SZ
     COMPUTE L-DY = L-MIN-Y + FUNCTION MOD(L-K, WS-SY)
     COMPUTE WS-Q = FUNCTION INTEGER(L-K / WS-SY)
     COMPUTE L-DZ = L-MIN-Z + FUNCTION MOD(WS-Q, WS-SZ)
     COMPUTE L-DX = L-MIN-X + FUNCTION INTEGER(WS-Q / WS-SZ)
     GOBACK.
 END PROGRAM F352-VOLUME-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-ANY-OF.
*> Section 3.4: USING count, child results (BINARY-LONG x 64, 1 or 0), evaluated out (the children evaluated), result out: true at the first true child
*> (later children are not evaluated); the empty list is false.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-R.
    05 L-CHILD             BINARY-LONG OCCURS 64 TIMES.
 01 L-EVALUATED            BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-R L-EVALUATED L-RESULT.
     MOVE 0 TO L-EVALUATED L-RESULT
     PERFORM UNTIL L-EVALUATED >= L-N OR L-RESULT = 1
         ADD 1 TO L-EVALUATED
         MOVE L-CHILD(L-EVALUATED) TO L-RESULT
     END-PERFORM
     GOBACK.
 END PROGRAM F352-ANY-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-ALL-OF.
*> Section 3.4: as F352-ANY-OF: false at the first false child; the empty list is true.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-R.
    05 L-CHILD             BINARY-LONG OCCURS 64 TIMES.
 01 L-EVALUATED            BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-R L-EVALUATED L-RESULT.
     MOVE 0 TO L-EVALUATED
     MOVE 1 TO L-RESULT
     PERFORM UNTIL L-EVALUATED >= L-N OR L-RESULT = 0
         ADD 1 TO L-EVALUATED
         MOVE L-CHILD(L-EVALUATED) TO L-RESULT
     END-PERFORM
     GOBACK.
 END PROGRAM F352-ALL-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-ROTATED-DIRECTION.
*> Section 4.3 rotated: USING state, direction (BINARY-LONG: -1 absent, else 0 down, 1 up, 2 north, 3 south, 4 west, 5 east), direction out: when
*> absent one nextInt(6) is drawn (before the inner provider is asked).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SIX                 BINARY-LONG VALUE 6.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-DIRECTION            BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-DIRECTION L-OUT.
     MOVE L-DIRECTION TO L-OUT
     IF L-DIRECTION < 0
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-SIX L-OUT
     END-IF
     GOBACK.
 END PROGRAM F352-ROTATED-DIRECTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-AXIS-OF.
*> Section 4.3: USING direction (0 to 5 as above), axis out (0 x, 1 y, 2 z).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIRECTION            BINARY-LONG.
 01 L-AXIS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIRECTION L-AXIS.
     EVALUATE L-DIRECTION
         WHEN 0
         WHEN 1
             MOVE 1 TO L-AXIS
         WHEN 2
         WHEN 3
             MOVE 2 TO L-AXIS
         WHEN OTHER
             MOVE 0 TO L-AXIS
     END-EVALUATE
     GOBACK.
 END PROGRAM F352-AXIS-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-RANDOM-BLOCK.
*> Section 4.3 random_block: USING state, set size (BINARY-LONG), chosen out (1-based; 0 for an empty set, with no draw).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-SIZE                 BINARY-LONG.
 01 L-CHOSEN               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-SIZE L-CHOSEN.
     MOVE 0 TO L-CHOSEN
     IF L-SIZE > 0
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE L-SIZE L-CHOSEN
         ADD 1 TO L-CHOSEN
     END-IF
     GOBACK.
 END PROGRAM F352-RANDOM-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-RULE-BASED.
*> Section 4.3 rule_based: USING count of rules, if_true (BINARY-LONG x 64, 1 or 0), then results (BINARY-LONG x 64: the state code the rule's provider
*> gives, 0 for nothing), fallback (state code, 0 for nothing or no fallback), level state (the state at pos), optional out, state out.
*> Every rule whose predicate holds asks its provider; the first non-null answer is the result, a null answer continues the scan; then the fallback.
*> getState: the optional result, else the level state.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-IF.
    05 L-IF-TRUE           BINARY-LONG OCCURS 64 TIMES.
 01 L-THEN.
    05 L-THEN-STATE        BINARY-LONG OCCURS 64 TIMES.
 01 L-FALLBACK             BINARY-LONG.
 01 L-LEVEL-STATE          BINARY-LONG.
 01 L-OPTIONAL             BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-IF L-THEN L-FALLBACK L-LEVEL-STATE L-OPTIONAL L-STATE.
     MOVE 0 TO L-OPTIONAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-N OR L-OPTIONAL > 0
         IF L-IF-TRUE(WS-I) = 1
             MOVE L-THEN-STATE(WS-I) TO L-OPTIONAL
         END-IF
     END-PERFORM
     IF L-OPTIONAL = 0
         MOVE L-FALLBACK TO L-OPTIONAL
     END-IF
     MOVE L-OPTIONAL TO L-STATE
     IF L-OPTIONAL = 0
         MOVE L-LEVEL-STATE TO L-STATE
     END-IF
     GOBACK.
 END PROGRAM F352-RULE-BASED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-RANDOMIZED-INT.
*> Section 4.3 randomized_int: USING state, has the integer property (0 or 1), uniform minimum, uniform maximum, value out: with the property one sample of the
*> uniform provider (min + nextInt(max - min + 1)); without it no draw and the value 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-HAS                  BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-HAS L-MIN L-MAX L-VALUE.
     MOVE 0 TO L-VALUE
     IF L-HAS = 1
         COMPUTE WS-BOUND = L-MAX - L-MIN + 1
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DRAW
         COMPUTE L-VALUE = L-MIN + WS-DRAW
     END-IF
     GOBACK.
 END PROGRAM F352-RANDOMIZED-INT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-COPY-COUNT.
*> Section 4.3 and 4.4 copy_properties: USING count of properties of the level block, has (BINARY-LONG x 64: 1 when the source state has that very property
*> instance), copied out: the number of properties copied; a property the source lacks is skipped.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-HAS.
    05 L-H                 BINARY-LONG OCCURS 64 TIMES.
 01 L-COPIED               BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-HAS L-COPIED.
     MOVE 0 TO L-COPIED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-N
         ADD L-H(WS-I) TO L-COPIED
     END-PERFORM
     GOBACK.
 END PROGRAM F352-COPY-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-NOISE-INDEX.
*> Section 5.4: USING v (FLOAT-LONG holding the float noise value), size (BINARY-LONG), index out: t = clamp((1.0f + v) / 2.0f, 0, 0.9999f), index =
*> (int)(t * (float) size), every operation rounded to float.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-TWO                 FLOAT-LONG VALUE 2.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-CAP                 FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-N                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-Q                   FLOAT-LONG.
 01 WS-CAP-RAW             FLOAT-LONG VALUE 0.9999.
 LINKAGE SECTION.
 01 L-V                    FLOAT-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-V L-SIZE L-INDEX.
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-CAP-RAW WS-CAP
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-ONE L-V WS-A
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-A WS-B
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-B WS-TWO WS-T
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-A
     MOVE WS-A TO WS-T
     IF WS-T < WS-ZERO
         MOVE WS-ZERO TO WS-T
     END-IF
     IF WS-T > WS-CAP
         MOVE WS-CAP TO WS-T
     END-IF
     MOVE L-SIZE TO WS-N
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-T WS-N WS-P
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-P WS-Q
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-Q L-INDEX
     GOBACK.
 END PROGRAM F352-NOISE-INDEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-DUAL-N.
*> Section 5.5: USING s (FLOAT-LONG, the slow noise), variety minimum, maximum (BINARY-LONG), n out: (int) clampedMap(s, -1, 1, min, max + 1) in double.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-TWO                 FLOAT-LONG VALUE 2.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-A                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-SPAN                FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-S                    FLOAT-LONG.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING L-S L-MIN L-MAX L-N.
     CALL STATIC "cc_f64_add" USING BY REFERENCE L-S WS-ONE WS-A
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-A WS-TWO WS-T
     IF WS-T < WS-ZERO
         MOVE WS-ZERO TO WS-T
     END-IF
     IF WS-T > WS-ONE
         MOVE WS-ONE TO WS-T
     END-IF
     MOVE L-MIN TO WS-C
     COMPUTE WS-D = L-MAX + 1
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-D WS-C WS-SPAN
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-T WS-SPAN WS-P
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-C WS-P WS-R
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-R L-N
     GOBACK.
 END PROGRAM F352-DUAL-N.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-THRESHOLD.
*> Section 5.6 noise_threshold: USING state, v (FLOAT-LONG), threshold (FLOAT-LONG), high chance (FLOAT-LONG), low count, high count (BINARY-LONG), kind out
*> (1 low state, 2 high state, 3 the default state), index out (1-based, 0 for the default). Below the threshold: one nextInt(low count); else one
*> nextFloat, and below the chance one nextInt(high count).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-V                    FLOAT-LONG.
 01 L-THRESHOLD            FLOAT-LONG.
 01 L-CHANCE               FLOAT-LONG.
 01 L-LOW                  BINARY-LONG.
 01 L-HIGH                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-V L-THRESHOLD L-CHANCE L-LOW L-HIGH L-KIND L-INDEX.
     MOVE 3 TO L-KIND
     MOVE 0 TO L-INDEX
     IF L-V < L-THRESHOLD
         MOVE 1 TO L-KIND
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE L-LOW L-INDEX
         ADD 1 TO L-INDEX
     ELSE
         CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
         IF WS-F < L-CHANCE
             MOVE 2 TO L-KIND
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE L-HIGH L-INDEX
             ADD 1 TO L-INDEX
         END-IF
     END-IF
     GOBACK.
 END PROGRAM F352-THRESHOLD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-NORMAL-FACTOR.
*> Section 5.1.1 (no amplitude modifiers): USING octave count n, base amplitude A (FLOAT-LONG), mode (0 disabled, 1 enabled, 2 legacy), nf out (the normal
*> factor, FLOAT-LONG), sum out (the amplitude sum, FLOAT-LONG; after the legacy rescale for mode 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-THIRD               FLOAT-LONG VALUE 0.3333333333333333.
 01 WS-K                   FLOAT-LONG VALUE 0.2702247831245211.
 01 WS-ROOT2               FLOAT-LONG.
 01 WS-TWO                 FLOAT-LONG VALUE 2.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-START               FLOAT-LONG.
 01 WS-AMP                 FLOAT-LONG.
 01 WS-SUM                 FLOAT-LONG.
 01 WS-SQ                  FLOAT-LONG.
 01 WS-DEVSQ               FLOAT-LONG.
 01 WS-DEV                 FLOAT-LONG.
 01 WS-T1                  FLOAT-LONG.
 01 WS-T2                  FLOAT-LONG.
 01 WS-T3                  FLOAT-LONG.
 01 WS-NUM                 FLOAT-LONG.
 01 WS-DEN                 FLOAT-LONG.
 01 WS-POW                 FLOAT-LONG.
 01 WS-LEG                 FLOAT-LONG.
 01 WS-EK                  FLOAT-LONG.
 01 WS-KK                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-A                    FLOAT-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-NF                   FLOAT-LONG.
 01 L-SUM                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-N L-A L-MODE L-NF L-SUM.
     CALL STATIC "cc_f64_sqrt" USING BY REFERENCE WS-TWO WS-ROOT2
     MOVE L-A TO WS-START
     IF L-MODE > 0
*>       A * 2^(n-1) / (2^n - 1)
         MOVE 1 TO WS-POW
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I >= L-N
             CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-POW WS-TWO WS-T1
             MOVE WS-T1 TO WS-POW
         END-PERFORM
         CALL STATIC "cc_f64_mul" USING BY REFERENCE L-A WS-POW WS-NUM
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-POW WS-TWO WS-T1
         COMPUTE WS-DEN = WS-T1 - 1
         CALL STATIC "cc_f64_div" USING BY REFERENCE WS-NUM WS-DEN WS-START
     END-IF
     MOVE 0 TO WS-SUM WS-DEVSQ
     MOVE WS-START TO WS-AMP
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-N
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-SUM WS-AMP WS-T1
         MOVE WS-T1 TO WS-SUM
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-K WS-AMP WS-T1
         MOVE WS-T1 TO WS-T3
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-T1 WS-T3 WS-T2
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-DEVSQ WS-T2 WS-SQ
         MOVE WS-SQ TO WS-DEVSQ
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-AMP WS-HALF WS-T1
         MOVE WS-T1 TO WS-AMP
     END-PERFORM
     CALL STATIC "cc_f64_sqrt" USING BY REFERENCE WS-DEVSQ WS-DEV
     MOVE 0 TO L-NF
     IF WS-DEV NOT = WS-ZERO
         CALL STATIC "cc_f64_mul" USING BY REFERENCE L-A WS-THIRD WS-NUM
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-DEV WS-ROOT2 WS-DEN
         CALL STATIC "cc_f64_div" USING BY REFERENCE WS-NUM WS-DEN L-NF
     END-IF
     MOVE WS-SUM TO L-SUM
     IF L-MODE = 2 AND L-NF NOT = WS-ZERO
*>       p = (A * 0.5 * 1/3) / E(n - 1), E(k) = 0.1 * (1 + 1/(k + 1)); sum = sum * p / nf0, nf = p
         COMPUTE WS-KK = L-N
         COMPUTE WS-EK = 0.1 * (1 + 1 / WS-KK)
         CALL STATIC "cc_f64_mul" USING BY REFERENCE L-A WS-HALF WS-T1
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-T1 WS-THIRD WS-NUM
         CALL STATIC "cc_f64_div" USING BY REFERENCE WS-NUM WS-EK WS-LEG
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-SUM WS-LEG WS-T1
         CALL STATIC "cc_f64_div" USING BY REFERENCE WS-T1 L-NF L-SUM
         MOVE WS-LEG TO L-NF
     END-IF
     GOBACK.
 END PROGRAM F352-NORMAL-FACTOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-LEGACY-KEYS.
*> Section 5.2: USING seed (u64), key A out, key B out (BINARY-DOUBLE signed): the first two nextLong of LegacyRandomSource(seed).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-U                   BINARY-DOUBLE UNSIGNED.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE UNSIGNED.
 01 L-KA                   BINARY-DOUBLE.
 01 L-KB                   BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-SEED L-KA L-KB.
     CALL "JRAND-SET-SEED" USING WS-STATE L-SEED
     CALL "JRAND-NEXT-LONG" USING WS-STATE WS-U
     IF WS-U >= 9223372036854775808
         COMPUTE L-KA = WS-U - 18446744073709551616
     ELSE
         MOVE WS-U TO L-KA
     END-IF
     CALL "JRAND-NEXT-LONG" USING WS-STATE WS-U
     IF WS-U >= 9223372036854775808
         COMPUTE L-KB = WS-U - 18446744073709551616
     ELSE
         MOVE WS-U TO L-KB
     END-IF
     GOBACK.
 END PROGRAM F352-LEGACY-KEYS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-JAVA-HASH.
*> Section 5.2: USING text (PIC X(64)), length (BINARY-LONG), hash out (BINARY-LONG): String.hashCode, h = 31 * h + c wrapping 32 bit.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-H                   BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 01 L-HASH                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-HASH.
     MOVE 0 TO WS-H
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-LENGTH
         COMPUTE WS-H = FUNCTION MOD(31 * WS-H + FUNCTION ORD(L-TEXT(WS-I:1)) - 1 + 2147483648, 4294967296) - 2147483648
     END-PERFORM
     MOVE WS-H TO L-HASH
     GOBACK.
 END PROGRAM F352-JAVA-HASH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-OCTAVE-SEED.
*> Section 5.2 fromHashOf: USING hash (BINARY-LONG, signed 32), key (BINARY-DOUBLE signed, kA or kB), seed out (BINARY-DOUBLE signed): (long) hash xor key.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-H                   BINARY-DOUBLE UNSIGNED.
 01 WS-K                   BINARY-DOUBLE UNSIGNED.
 01 WS-S                   BINARY-DOUBLE SIGNED.
 LINKAGE SECTION.
 01 L-HASH                 BINARY-LONG.
 01 L-KEY                  BINARY-DOUBLE.
 01 L-SEED                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-HASH L-KEY L-SEED.
     IF L-HASH < 0
         COMPUTE WS-H = L-HASH + 18446744073709551616
     ELSE
         MOVE L-HASH TO WS-H
     END-IF
     IF L-KEY < 0
         COMPUTE WS-K = L-KEY + 18446744073709551616
     ELSE
         MOVE L-KEY TO WS-K
     END-IF
     CALL "CBL_XOR" USING WS-H WS-K BY VALUE 8
     IF WS-K >= 9223372036854775808
         COMPUTE L-SEED = WS-K - 18446744073709551616
     ELSE
         MOVE WS-K TO L-SEED
     END-IF
     GOBACK.
 END PROGRAM F352-OCTAVE-SEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-VARIETY.
*> Section 4.5: USING shape (1 an int, 2 a list of two, 3 the object), a, b (BINARY-LONG; b is ignored for an int), status out, min out, max out: 0 valid,
*> 1 min above max, 2 a bound outside [1, 64].
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SHAPE                BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SHAPE L-A L-B L-STATUS L-MIN L-MAX.
     MOVE L-A TO L-MIN
     MOVE L-B TO L-MAX
     IF L-SHAPE = 1
         MOVE L-A TO L-MAX
     END-IF
     MOVE 0 TO L-STATUS
     IF L-MIN > L-MAX
         MOVE 1 TO L-STATUS
     ELSE
         IF L-MIN < 1 OR L-MAX > 64
             MOVE 2 TO L-STATUS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM F352-VARIETY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-NORMALIZE-FORM.
*> Section 5.1: USING text (PIC X(16)), mode out (0 disabled for false, 1 enabled for true, 2 legacy; -1 any other).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(16).
 01 L-MODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-MODE.
     MOVE -1 TO L-MODE
     EVALUATE L-TEXT
         WHEN "false"
             MOVE 0 TO L-MODE
         WHEN "true"
             MOVE 1 TO L-MODE
         WHEN "legacy"
             MOVE 2 TO L-MODE
     END-EVALUATE
     GOBACK.
 END PROGRAM F352-NORMALIZE-FORM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-NOISE-PARAMS-OK.
*> Section 5.1: USING base octave, octave count, modifier count (BINARY-LONG), ok out: base_octave in [-32, 32], octave_count in [1, 32], 0 to 32
*> modifiers, and the modifier list empty or of exactly octave_count entries.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BASE                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-MODS                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-BASE L-COUNT L-MODS L-OK.
     MOVE 0 TO L-OK
     IF L-BASE >= -32 AND L-BASE <= 32 AND L-COUNT >= 1 AND L-COUNT <= 32 AND L-MODS <= 32 AND (L-MODS = 0 OR L-MODS = L-COUNT)
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM F352-NOISE-PARAMS-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F352-RULETEST-NAME.
*> Section 8: USING kind (1 RuleTestType, 2 PosRuleTestType), id (BINARY-LONG), name out (PIC X(32), spaces when there is no such id).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RULES.
    05 FILLER PIC X(32) VALUE "all_of".
    05 FILLER PIC X(32) VALUE "always_true".
    05 FILLER PIC X(32) VALUE "any_of".
    05 FILLER PIC X(32) VALUE "block_match".
    05 FILLER PIC X(32) VALUE "blockstate_match".
    05 FILLER PIC X(32) VALUE "not".
    05 FILLER PIC X(32) VALUE "tag_match".
    05 FILLER PIC X(32) VALUE "height_match".
    05 FILLER PIC X(32) VALUE "random_block_match".
    05 FILLER PIC X(32) VALUE "random_blockstate_match".
 01 WS-RULE-TABLE REDEFINES WS-RULES.
    05 WS-RULE PIC X(32) OCCURS 10 TIMES.
 01 WS-POSES.
    05 FILLER PIC X(32) VALUE "always_true".
    05 FILLER PIC X(32) VALUE "linear_pos".
    05 FILLER PIC X(32) VALUE "axis_aligned_linear_pos".
 01 WS-POS-TABLE REDEFINES WS-POSES.
    05 WS-POS PIC X(32) OCCURS 3 TIMES.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-NAME                 PIC X(32).
 PROCEDURE DIVISION USING L-KIND L-ID L-NAME.
     MOVE SPACES TO L-NAME
     IF L-KIND = 1 AND L-ID >= 0 AND L-ID < 10
         MOVE WS-RULE(L-ID + 1) TO L-NAME
     END-IF
     IF L-KIND = 2 AND L-ID >= 0 AND L-ID < 3
         MOVE WS-POS(L-ID + 1) TO L-NAME
     END-IF
     GOBACK.
 END PROGRAM F352-RULETEST-NAME.
