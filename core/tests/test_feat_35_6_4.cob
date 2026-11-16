*> Implementation test of the geode (docs/protocol/35-worldgen-features-6-underground.md section 4; core/src/feat-geode.cob): the data features compile (type 20; a missing invalid_blocks_threshold,
*> blocks or inner_placements make a feature unsupported; defaults of 4.1), and in a block of stone every cell equals an independent model on a second random source: the point draws, the
*> thresholds of 4.3 step 3 (11.1: P 3 gives fill 0.766965, inner 0.608581, middle 0.519875, outer 0.461266), the crack, the scan of the box with the shape noise of the world seed (the noise object
*> NormalNoise.createParity(-4, [1.0]) is the legacy noise of octave -4 with both layer amplitudes 5/6), the layers, the alternate and bud draws and the buds. Cases: the data's amethyst geode,
*> a variant with four points, no crack, buds on any inner block, other layers and a smaller box, and a flooded real geode (too many invalid points: false after the point draws) and a flooded variant (threshold 100, still placed).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-6-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY FEATINDEX.
 COPY CARVER.
 COPY NOISE.
 COPY XORO.
 COPY XORO REPLACING ==XR-STATE== BY ==XR2-STATE== LEADING ==XR-== BY ==X2-==.
 COPY SPELWS.
 01 WS-CASENO              BINARY-LONG.
 01 WS-CASETXT             PIC 99.
 01 WS-FT-REAL             BINARY-LONG.
 01 WS-FT-B                BINARY-LONG.
 01 WS-CUR-FT              BINARY-LONG.
 01 WS-MODEL-RESULT        BINARY-LONG.
 01 WS-N-BUDS              BINARY-LONG VALUE 0.
 01 WS-N-CRACK             BINARY-LONG VALUE 0.
 01 WS-N-TRUE              BINARY-LONG VALUE 0.
 01 WS-N-FALSE             BINARY-LONG VALUE 0.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-INV.
    05 WS-INVB             BINARY-LONG OCCURS 6 TIMES.
 01 WS-B-BEDROCK           BINARY-LONG.
 01 WS-S-AMETHYST          BINARY-LONG.
 01 WS-S-BUDDING           BINARY-LONG.
 01 WS-S-CALCITE           BINARY-LONG.
 01 WS-S-BASALT            BINARY-LONG.
 01 WS-BUD.
    05 WS-BUDD OCCURS 4 TIMES.
       10 WS-BUDW OCCURS 2 TIMES.
          15 WS-BUDS       BINARY-LONG OCCURS 6 TIMES.
 01 WS-B-BUD               BINARY-LONG OCCURS 4 TIMES.
 01 WS-DIRNAME             PIC X(8) OCCURS 6 TIMES.
*> model parameters of the variant
 01 M-VAR                  BINARY-LONG.
 01 M-PMIN                 BINARY-LONG.
 01 M-PMAX                 BINARY-LONG.
 01 M-WMIN                 BINARY-LONG.
 01 M-WMAX                 BINARY-LONG.
 01 M-CHANCE               FLOAT-LONG.
 01 M-ALT                  FLOAT-LONG.
 01 M-POT                  FLOAT-LONG.
 01 M-REQ                  BINARY-LONG.
 01 M-LAYERS.
    05 M-LAYER             FLOAT-LONG OCCURS 4 TIMES.
 01 M-NMULT                FLOAT-LONG.
 01 M-LO                   BINARY-LONG.
 01 M-HI                   BINARY-LONG.
 01 M-THR                  BINARY-LONG.
 01 M-BASE                 FLOAT-LONG.
 01 M-MINUS4               BINARY-LONG VALUE -4.
*> model work
 01 M-P                    BINARY-LONG.
 01 M-FA                   FLOAT-LONG.
 01 M-FB                   FLOAT-LONG.
 01 M-FR                   FLOAT-LONG.
 01 M-FR2                  FLOAT-LONG.
 01 M-S1                   FLOAT-LONG.
 01 M-S2                   FLOAT-LONG.
 01 M-SG                   BINARY-LONG.
 01 M-D                    FLOAT-LONG.
 01 M-R                    FLOAT-LONG.
 01 M-NF                   FLOAT-LONG.
 01 M-HIB                  BINARY-DOUBLE.
 01 M-B24                  BINARY-LONG VALUE 24.
 01 M-TWO24                FLOAT-LONG VALUE 16777216.
 01 M-TWO                  FLOAT-LONG VALUE 2.0.
 01 M-ONE                  FLOAT-LONG VALUE 1.0.
 01 M-ZERO                 FLOAT-LONG VALUE 0.
 01 M-FIVE                 FLOAT-LONG VALUE 5.0.
 01 M-SIX                  FLOAT-LONG VALUE 6.0.
 01 M-AMP                  FLOAT-LONG.
 01 M-FILL                 FLOAT-LONG.
 01 M-INNER                FLOAT-LONG.
 01 M-MIDDLE               FLOAT-LONG.
 01 M-OUTER                FLOAT-LONG.
 01 M-CRACKT               FLOAT-LONG.
 01 M-CRACK                BINARY-LONG.
 01 M-NPTS                 BINARY-LONG.
 01 M-PTS.
    05 M-PT OCCURS 8 TIMES.
       10 M-PX             BINARY-LONG.
       10 M-PY             BINARY-LONG.
       10 M-PZ             BINARY-LONG.
       10 M-PO             FLOAT-LONG.
 01 M-CPS.
    05 M-CP OCCURS 3 TIMES.
       10 M-CX             BINARY-LONG.
       10 M-CY             BINARY-LONG.
       10 M-CZ             BINARY-LONG.
 01 M-NCP                  BINARY-LONG.
 01 M-INVALID              BINARY-LONG.
 01 M-I                    BINARY-LONG.
 01 M-J                    BINARY-LONG.
 01 M-K                    BINARY-LONG.
 01 M-V                    BINARY-LONG.
 01 M-RR                   BINARY-LONG.
 01 M-S                    BINARY-LONG.
 01 M-DXX                  BINARY-LONG.
 01 M-DZZ                  BINARY-LONG.
 01 M-QX                   BINARY-LONG.
 01 M-QY                   BINARY-LONG.
 01 M-QZ                   BINARY-LONG.
 01 M-DSQ                  BINARY-LONG.
 01 M-FX                   FLOAT-LONG.
 01 M-FY                   FLOAT-LONG.
 01 M-FZ                   FLOAT-LONG.
 01 M-NV                   FLOAT-LONG.
 01 M-N                    FLOAT-LONG.
 01 M-SPAN                 BINARY-LONG.
 01 M-LX                   BINARY-LONG.
 01 M-LY                   BINARY-LONG.
 01 M-LZ                   BINARY-LONG.
 01 M-USEALT               BINARY-LONG.
 01 M-NPOT                 BINARY-LONG.
 01 M-POTS.
    05 M-PO3 OCCURS 4096 TIMES.
       10 M-OX             BINARY-LONG.
       10 M-OY             BINARY-LONG.
       10 M-OZ             BINARY-LONG.
 01 M-ST                   BINARY-LONG.
 01 M-WL                   BINARY-LONG.
 01 M-STOP                 BINARY-LONG.
 01 M-BS                   BINARY-LONG.
 01 M-DIRS.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
 01 M-DIR-T REDEFINES M-DIRS.
    05 M-DIR OCCURS 6 TIMES.
       10 M-DDX            BINARY-LONG.
       10 M-DDY            BINARY-LONG.
       10 M-DDZ            BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     MOVE 777 TO CV-SEED
     MOVE "stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-STONE
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-STONE
     MOVE "bedrock" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-BEDROCK
     COMPUTE WS-ID(1) = WS-WANT - 1
     MOVE 1 TO WS-COUNT
     MOVE "minecraft:features_cannot_replace" TO WS-TAG
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "water" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-WATER
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-WATER
     COMPUTE WS-ID(2) = WS-WANT - 1
     MOVE "lava" TO WS-KEY
     PERFORM WANT-BLOCK
     COMPUTE WS-ID(3) = WS-WANT - 1
     MOVE "ice" TO WS-KEY
     PERFORM WANT-BLOCK
     COMPUTE WS-ID(4) = WS-WANT - 1
     MOVE "packed_ice" TO WS-KEY
     PERFORM WANT-BLOCK
     COMPUTE WS-ID(5) = WS-WANT - 1
     MOVE "blue_ice" TO WS-KEY
     PERFORM WANT-BLOCK
     COMPUTE WS-ID(6) = WS-WANT - 1
     PERFORM VARYING M-I FROM 1 BY 1 UNTIL M-I > 6
         COMPUTE WS-INVB(M-I) = WS-ID(M-I) + 1
     END-PERFORM
     COMPUTE WS-ID(1) = WS-B-BEDROCK - 1
     MOVE 6 TO WS-COUNT
     MOVE "minecraft:geode_invalid_blocks" TO WS-TAG
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "air" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-AIR
     MOVE "amethyst_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-AMETHYST
     MOVE "budding_amethyst" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-BUDDING
     MOVE "calcite" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-CALCITE
     MOVE "smooth_basalt" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-BASALT
     MOVE "down" TO WS-DIRNAME(1)
     MOVE "up" TO WS-DIRNAME(2)
     MOVE "north" TO WS-DIRNAME(3)
     MOVE "south" TO WS-DIRNAME(4)
     MOVE "west" TO WS-DIRNAME(5)
     MOVE "east" TO WS-DIRNAME(6)
     PERFORM VARYING M-I FROM 1 BY 1 UNTIL M-I > 4
         EVALUATE M-I
             WHEN 1
                 MOVE "small_amethyst_bud" TO WS-KEY
             WHEN 2
                 MOVE "medium_amethyst_bud" TO WS-KEY
             WHEN 3
                 MOVE "large_amethyst_bud" TO WS-KEY
             WHEN OTHER
                 MOVE "amethyst_cluster" TO WS-KEY
         END-EVALUATE
         PERFORM VARYING M-J FROM 1 BY 1 UNTIL M-J > 6
             MOVE SPACES TO WS-PAIRS
             STRING "facing=" FUNCTION TRIM(WS-DIRNAME(M-J)) ",waterlogged=false" DELIMITED BY SIZE INTO WS-PAIRS
             CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-BUDS(M-I, 1, M-J)
             MOVE SPACES TO WS-PAIRS
             STRING "facing=" FUNCTION TRIM(WS-DIRNAME(M-J)) ",waterlogged=true" DELIMITED BY SIZE INTO WS-PAIRS
             CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-BUDS(M-I, 2, M-J)
         END-PERFORM
     END-PERFORM
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"

     MOVE "minecraft:geode" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE WS-FT TO WS-FT-REAL
     MOVE "35-6§4.1: the data feature geode compiles as type 20" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 20 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-6§4.1: the defaults are layers 1.7 2.2 3.2 4.2, offsets -16 and 16, threshold 1 and outer wall maximum 6" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WA-F(FT-A(WS-FT), 1) = 1.7 AND WA-F(FT-A(WS-FT), 2) = 2.2 AND WA-F(FT-A(WS-FT), 3) = 3.2 AND WA-F(FT-A(WS-FT), 4) = 4.2
         ADD 1 TO WS-OBS
     END-IF
     IF WA-I(FT-A(WS-FT), 8) = -16 AND WA-I(FT-A(WS-FT), 9) = 16 AND WA-I(FT-A(WS-FT), 10) = 1 AND WA-I(FT-A(WS-FT), 11) = 6
         ADD 10 TO WS-OBS
     END-IF
     MOVE 11 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-6§4.1: the four inner placements are read" TO WS-CASE
     MOVE WA-N(FT-A(WS-FT), 1) TO WS-OBS
     MOVE 4 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:geode_b" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE WS-FT TO WS-FT-B
     MOVE "35-6§4.1: the variant geode compiles too" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 20 TO WS-EXP
     PERFORM ASSERT-N
     PERFORM VARYING M-I FROM 1 BY 1 UNTIL M-I > 4
         EVALUATE M-I
             WHEN 1
                 MOVE "minecraft:geode_nothreshold" TO WS-FTKEY
                 MOVE "a missing invalid_blocks_threshold" TO WS-NAME
             WHEN 2
                 MOVE "minecraft:geode_noplacements" TO WS-FTKEY
                 MOVE "an empty inner_placements list" TO WS-NAME
             WHEN 3
                 MOVE "minecraft:geode_noblocks" TO WS-FTKEY
                 MOVE "a missing blocks record" TO WS-NAME
             WHEN OTHER
                 MOVE "minecraft:geode_full" TO WS-FTKEY
                 MOVE "a full feature table" TO WS-NAME
                 MOVE FD-MAX-WA TO FD-WA-COUNT
         END-EVALUATE
         PERFORM COMPILE-FT
         IF M-I = 4
             MOVE 5 TO FD-WA-COUNT
         END-IF
         MOVE SPACES TO WS-CASE
         STRING "35-6§4.1: " FUNCTION TRIM(WS-NAME) " makes the feature unsupported" DELIMITED BY SIZE INTO WS-CASE
         MOVE FT-TYPE(WS-FT) TO WS-OBS
         MOVE -1 TO WS-EXP
         PERFORM ASSERT-N
     END-PERFORM
     MOVE 1 TO FI-GATE
     MOVE "minecraft:amethyst_geode" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-6§4: the gate admits the placed feature amethyst_geode" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   the noise of the model: createParity(-4, [1.0]) of the world seed
     MOVE 1.0 TO M-BASE
     CALL "NOISE-CREATE-LEGACY" USING CV-SEED M-MINUS4 M-BASE WS-HANDLE
     CALL STATIC "cc_f64_div" USING BY REFERENCE M-FIVE M-SIX M-FR
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE M-FR M-AMP
     MOVE M-AMP TO NZ-L-AMP(NZ-FIRST(WS-HANDLE))
     COMPUTE M-K = NZ-FIRST(WS-HANDLE) + 1
     MOVE M-AMP TO NZ-L-AMP(M-K)

     PERFORM VARYING WS-CASENO FROM 1 BY 1 UNTIL WS-CASENO > 7
         COMPUTE WS-SEED = WS-CASENO * 7001
         MOVE WS-CASENO TO WS-CASETXT
         IF WS-CASENO <= 3
             MOVE 1 TO M-VAR
             MOVE WS-FT-REAL TO WS-CUR-FT
         ELSE
             MOVE 2 TO M-VAR
             MOVE WS-FT-B TO WS-CUR-FT
         END-IF
         PERFORM SET-PARAMS
         PERFORM NEW-WORLD
         MOVE 63 TO WS-Y0
         MOVE 69 TO WS-Y1
         MOVE 16 TO WS-X0
         MOVE 31 TO WS-X1
         MOVE 32 TO WS-Z0
         MOVE 47 TO WS-Z1
         MOVE "stone" TO WS-KEY
         PERFORM FILL-BOX
         IF WS-CASENO = 3 OR WS-CASENO = 7
*>           water around the origin: the points are invalid
             MOVE 54 TO WS-Y0
             MOVE 66 TO WS-Y1
             MOVE 18 TO WS-X0
             MOVE 30 TO WS-X1
             MOVE 34 TO WS-Z0
             MOVE 46 TO WS-Z1
             MOVE "water" TO WS-KEY
             PERFORM FILL-BOX
         END-IF
         PERFORM SNAPSHOT
         CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
         CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
         MOVE 24 TO WS-OX
         MOVE 60 TO WS-OY
         MOVE 40 TO WS-OZ
         PERFORM MODEL-RUN
         CALL "FR-PLACE-FT" USING XR-STATE WS-CUR-FT WS-OX WS-OY WS-OZ WS-RESULT
         MOVE 0 TO WS-BAD
         PERFORM COMPARE
         MOVE SPACES TO WS-CASE
         STRING "35-6§4: case " WS-CASETXT " the cells equal the model" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-BAD TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
         MOVE SPACES TO WS-CASE
         STRING "35-6§4: case " WS-CASETXT " the result and the random state equal the model's" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1000 TO WS-DRAW
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-OBS
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-DRAW WS-EXP
         COMPUTE WS-OBS = WS-RESULT * 1000 + WS-OBS
         COMPUTE WS-EXP = WS-MODEL-RESULT * 1000 + WS-EXP
         PERFORM ASSERT-N
     END-PERFORM
     MOVE "35-6§4: geodes were placed" TO WS-CASE
     MOVE WS-N-TRUE TO WS-OBS
     MOVE 6 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-6§4: geodes with invalid points gave false" TO WS-CASE
     MOVE WS-N-FALSE TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-6§4: some geode had a crack" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-CRACK > 0
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-6§4: some geode had buds" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-BUDS > 0
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM ASSERT-N
     STOP RUN
     .
*> SET-PARAMS: the values of the data of the variant (1 the amethyst geode, 2 the variant)
 SET-PARAMS.
     IF M-VAR = 1
         MOVE 3 TO M-PMIN
         MOVE 4 TO M-PMAX
         MOVE 4 TO M-WMIN
         MOVE 6 TO M-WMAX
         MOVE 0.95 TO M-CHANCE
         MOVE 0.083 TO M-ALT
         MOVE 0.35 TO M-POT
         MOVE 1 TO M-REQ
         MOVE 1.7 TO M-LAYER(1)
         MOVE 2.2 TO M-LAYER(2)
         MOVE 3.2 TO M-LAYER(3)
         MOVE 4.2 TO M-LAYER(4)
         MOVE 0.05 TO M-NMULT
         MOVE -16 TO M-LO
         MOVE 16 TO M-HI
         MOVE 1 TO M-THR
     ELSE
         MOVE 4 TO M-PMIN
         MOVE 4 TO M-PMAX
         MOVE 3 TO M-WMIN
         MOVE 4 TO M-WMAX
         MOVE 0.0 TO M-CHANCE
         MOVE 0.5 TO M-ALT
         MOVE 0.5 TO M-POT
         MOVE 0 TO M-REQ
         MOVE 1.5 TO M-LAYER(1)
         MOVE 2.0 TO M-LAYER(2)
         MOVE 3.0 TO M-LAYER(3)
         MOVE 4.5 TO M-LAYER(4)
         MOVE 0.2 TO M-NMULT
         MOVE -10 TO M-LO
         MOVE 10 TO M-HI
         MOVE 100 TO M-THR
     END-IF
     .
*> ---- the model
 M-ADD.
     CALL STATIC "cc_f64_add" USING BY REFERENCE M-FA M-FB M-FR
     .
 M-SUB.
     CALL STATIC "cc_f64_sub" USING BY REFERENCE M-FA M-FB M-FR
     .
 M-MUL.
     CALL STATIC "cc_f64_mul" USING BY REFERENCE M-FA M-FB M-FR
     .
 M-DIVF.
     CALL STATIC "cc_f64_div" USING BY REFERENCE M-FA M-FB M-FR
     .
 M-SIGN.
     CALL STATIC "cc_f64_sub" USING BY REFERENCE M-FA M-FB M-FR
     CALL STATIC "cc_f64_signum" USING BY REFERENCE M-FR M-FR2
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE M-FR2 M-SG
     .
*> M-INVSQRT: M-FR = invSqrt(M-FA) = 1.0 / Math.sqrt(M-FA)
 M-INVSQRT.
     CALL STATIC "cc_f64_sqrt" USING BY REFERENCE M-FA M-FB
     MOVE M-ONE TO M-FA
     PERFORM M-DIVF
     .
*> M-FLOATDRAW: M-NF = nextFloat() of the model's source
 M-FLOATDRAW.
     CALL "WGR-NEXT" USING XR2-STATE M-B24 M-HIB
     MOVE M-HIB TO M-FA
     MOVE M-TWO24 TO M-FB
     PERFORM M-DIVF
     MOVE M-FR TO M-NF
     .
*> M-EMPTY-INVALID: M-V 1 when the model cell (WS-MX, WS-MY, WS-MZ) is air or an invalid block
 M-EMPTY-INVALID.
     PERFORM MGET
     PERFORM MBLOCK
     MOVE 0 TO M-V
     IF WS-MV = WS-S-AIR
         MOVE 1 TO M-V
     END-IF
     PERFORM VARYING M-I FROM 1 BY 1 UNTIL M-I > 6
         IF WS-MB = WS-INVB(M-I)
             MOVE 1 TO M-V
         END-IF
     END-PERFORM
     .
*> M-SAFESET: the state M-ST at (WS-MX, WS-MY, WS-MZ) unless the block there is bedrock (cannot_replace)
 M-SAFESET.
     PERFORM MGET
     PERFORM MBLOCK
     IF WS-MB NOT = WS-B-BEDROCK
         MOVE M-ST TO WS-MV
         PERFORM MSET
     END-IF
     .
*> M-SUMS: M-S1 over the points (offset M-PO) and, when M-NCP > 0, M-S2 over the crack points (offset 2), for the position (M-QX, M-QY, M-QZ) with the noise term M-N
 M-SUM1.
     MOVE M-ZERO TO M-S1
     PERFORM VARYING M-K FROM 1 BY 1 UNTIL M-K > M-NPTS
         COMPUTE M-DSQ = (M-QX - M-PX(M-K)) * (M-QX - M-PX(M-K)) + (M-QY - M-PY(M-K)) * (M-QY - M-PY(M-K)) + (M-QZ - M-PZ(M-K)) * (M-QZ - M-PZ(M-K))
         MOVE M-DSQ TO M-FA
         MOVE M-PO(M-K) TO M-FB
         PERFORM M-ADD
         MOVE M-FR TO M-FA
         PERFORM M-INVSQRT
         MOVE M-FR TO M-FA
         MOVE M-N TO M-FB
         PERFORM M-ADD
         MOVE M-S1 TO M-FA
         MOVE M-FR TO M-FB
         PERFORM M-ADD
         MOVE M-FR TO M-S1
     END-PERFORM
     .
 M-SUM2.
     MOVE M-ZERO TO M-S2
     PERFORM VARYING M-K FROM 1 BY 1 UNTIL M-K > M-NCP
         COMPUTE M-DSQ = (M-QX - M-CX(M-K)) * (M-QX - M-CX(M-K)) + (M-QY - M-CY(M-K)) * (M-QY - M-CY(M-K)) + (M-QZ - M-CZ(M-K)) * (M-QZ - M-CZ(M-K))
         MOVE M-DSQ TO M-FA
         MOVE 2 TO M-FB
         PERFORM M-ADD
         MOVE M-FR TO M-FA
         PERFORM M-INVSQRT
         MOVE M-FR TO M-FA
         MOVE M-N TO M-FB
         PERFORM M-ADD
         MOVE M-S2 TO M-FA
         MOVE M-FR TO M-FB
         PERFORM M-ADD
         MOVE M-FR TO M-S2
     END-PERFORM
     .
*> M-THRESH: M-FR = 1 / sqrt(M-FA)
 M-THRESH.
     PERFORM M-INVSQRT
     .
 MODEL-RUN.
     MOVE 0 TO WS-MODEL-RESULT
*>   1. the number of points
     COMPUTE M-I = M-PMAX - M-PMIN + 1
     MOVE M-PMIN TO M-P
     IF M-VAR = 1
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-I M-V
         ADD M-V TO M-P
     END-IF
*>   3. the thresholds
     MOVE M-P TO M-FA
     MOVE M-WMAX TO M-FB
     PERFORM M-DIVF
     MOVE M-FR TO M-D
     MOVE M-LAYER(1) TO M-FA
     PERFORM M-THRESH
     MOVE M-FR TO M-FILL
     MOVE M-LAYER(2) TO M-FA
     MOVE M-D TO M-FB
     PERFORM M-ADD
     MOVE M-FR TO M-FA
     PERFORM M-THRESH
     MOVE M-FR TO M-INNER
     MOVE M-LAYER(3) TO M-FA
     MOVE M-D TO M-FB
     PERFORM M-ADD
     MOVE M-FR TO M-FA
     PERFORM M-THRESH
     MOVE M-FR TO M-MIDDLE
     MOVE M-LAYER(4) TO M-FA
     MOVE M-D TO M-FB
     PERFORM M-ADD
     MOVE M-FR TO M-FA
     PERFORM M-THRESH
     MOVE M-FR TO M-OUTER
     CALL "WGR-NEXT-DOUBLE" USING XR2-STATE M-R
     MOVE M-R TO M-FA
     MOVE M-TWO TO M-FB
     PERFORM M-DIVF
     MOVE M-FR TO M-FB
     IF M-VAR = 1
         MOVE 2.0 TO M-FA
     ELSE
         MOVE 2.0 TO M-FA
     END-IF
     PERFORM M-ADD
     MOVE M-FR TO M-FA
     IF M-P > 3
         MOVE M-D TO M-FB
     ELSE
         MOVE M-ZERO TO M-FB
     END-IF
     PERFORM M-ADD
     MOVE M-FR TO M-FA
     PERFORM M-THRESH
     MOVE M-FR TO M-CRACKT
*>   4. the crack flag
     PERFORM M-FLOATDRAW
     MOVE M-NF TO M-FA
     MOVE M-CHANCE TO M-FB
     PERFORM M-SIGN
     MOVE 0 TO M-CRACK
     IF M-SG < 0
         MOVE 1 TO M-CRACK
         ADD 1 TO WS-N-CRACK
     END-IF
*>   5. the points
     MOVE 0 TO M-INVALID M-NPTS
     COMPUTE M-J = M-WMAX - M-WMIN + 1
     PERFORM VARYING M-S FROM 1 BY 1 UNTIL M-S > M-P
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-J M-V
         COMPUTE M-PX(M-S) = WS-OX + M-V + M-WMIN
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-J M-V
         COMPUTE M-PY(M-S) = WS-OY + M-V + M-WMIN
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-J M-V
         COMPUTE M-PZ(M-S) = WS-OZ + M-V + M-WMIN
         MOVE M-PX(M-S) TO WS-MX
         MOVE M-PY(M-S) TO WS-MY
         MOVE M-PZ(M-S) TO WS-MZ
         PERFORM M-EMPTY-INVALID
         IF M-V = 1
             ADD 1 TO M-INVALID
             IF M-INVALID > M-THR
                 ADD 1 TO WS-N-FALSE
                 EXIT PARAGRAPH
             END-IF
         END-IF
         MOVE 2 TO M-K
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-K M-V
         COMPUTE M-PO(M-S) = M-V + 1
         ADD 1 TO M-NPTS
     END-PERFORM
     MOVE 0 TO M-NCP
     IF M-CRACK = 1
         MOVE 4 TO M-K
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-K M-RR
         COMPUTE M-S = 2 * M-P + 1
         MOVE 0 TO M-DXX M-DZZ
         IF M-RR = 0 OR M-RR = 2
             MOVE M-S TO M-DXX
         END-IF
         IF M-RR = 1 OR M-RR = 2
             MOVE M-S TO M-DZZ
         END-IF
         MOVE 3 TO M-NCP
         COMPUTE M-CX(1) = WS-OX + M-DXX
         COMPUTE M-CZ(1) = WS-OZ + M-DZZ
         COMPUTE M-CY(1) = WS-OY + 7
         COMPUTE M-CX(2) = WS-OX + M-DXX
         COMPUTE M-CZ(2) = WS-OZ + M-DZZ
         COMPUTE M-CY(2) = WS-OY + 5
         COMPUTE M-CX(3) = WS-OX + M-DXX
         COMPUTE M-CZ(3) = WS-OZ + M-DZZ
         COMPUTE M-CY(3) = WS-OY + 1
     END-IF
     MOVE 1 TO WS-MODEL-RESULT
     ADD 1 TO WS-N-TRUE
*>   7. the box
     MOVE 0 TO M-NPOT
     COMPUTE M-SPAN = M-HI - M-LO
     PERFORM VARYING M-LZ FROM 0 BY 1 UNTIL M-LZ > M-SPAN
         PERFORM VARYING M-LY FROM 0 BY 1 UNTIL M-LY > M-SPAN
             PERFORM VARYING M-LX FROM 0 BY 1 UNTIL M-LX > M-SPAN
                 COMPUTE M-QX = WS-OX + M-LO + M-LX
                 COMPUTE M-QY = WS-OY + M-LO + M-LY
                 COMPUTE M-QZ = WS-OZ + M-LO + M-LZ
                 PERFORM M-VISIT
             END-PERFORM
         END-PERFORM
     END-PERFORM
*>   8. the buds
     PERFORM VARYING M-I FROM 1 BY 1 UNTIL M-I > M-NPOT
         MOVE 4 TO M-K
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-K M-V
         ADD 1 TO M-V
         MOVE M-V TO M-BS
         MOVE 0 TO M-STOP
         PERFORM VARYING M-J FROM 1 BY 1 UNTIL M-J > 6 OR M-STOP = 1
             COMPUTE WS-MX = M-OX(M-I) + M-DDX(M-J)
             COMPUTE WS-MY = M-OY(M-I) + M-DDY(M-J)
             COMPUTE WS-MZ = M-OZ(M-I) + M-DDZ(M-J)
             PERFORM MGET
             MOVE 1 TO M-WL
             IF WS-MV = WS-S-WATER
                 MOVE 2 TO M-WL
             END-IF
             IF WS-MV = WS-S-AIR OR WS-MV = WS-S-WATER
                 MOVE WS-BUDS(M-BS, M-WL, M-J) TO M-ST
                 PERFORM M-SAFESET
                 ADD 1 TO WS-N-BUDS
                 MOVE 1 TO M-STOP
             END-IF
         END-PERFORM
     END-PERFORM
     .
*> M-VISIT (7.1 to 7.9) at (M-QX, M-QY, M-QZ)
 M-VISIT.
     MOVE M-QX TO M-FX
     MOVE M-QY TO M-FY
     MOVE M-QZ TO M-FZ
     CALL "NOISE-GET" USING WS-HANDLE M-FX M-FY M-FZ M-NV
     MOVE M-NV TO M-FA
     MOVE M-NMULT TO M-FB
     PERFORM M-MUL
     MOVE M-FR TO M-N
     PERFORM M-SUM1
     MOVE M-S1 TO M-FA
     MOVE M-OUTER TO M-FB
     PERFORM M-SIGN
     IF M-SG < 0
         EXIT PARAGRAPH
     END-IF
     MOVE M-QX TO WS-MX
     MOVE M-QY TO WS-MY
     MOVE M-QZ TO WS-MZ
     MOVE M-S1 TO M-FA
     MOVE M-FILL TO M-FB
     PERFORM M-SIGN
     IF M-SG >= 0
         MOVE WS-S-AIR TO M-ST
         PERFORM M-SAFESET
         EXIT PARAGRAPH
     END-IF
     IF M-NCP > 0
         PERFORM M-SUM2
         MOVE M-S2 TO M-FA
         MOVE M-CRACKT TO M-FB
         PERFORM M-SIGN
         IF M-SG >= 0
             MOVE WS-S-AIR TO M-ST
             PERFORM M-SAFESET
             EXIT PARAGRAPH
         END-IF
     END-IF
     MOVE M-S1 TO M-FA
     MOVE M-INNER TO M-FB
     PERFORM M-SIGN
     IF M-SG >= 0
         PERFORM M-FLOATDRAW
         MOVE M-NF TO M-FA
         MOVE M-ALT TO M-FB
         PERFORM M-SIGN
         MOVE 0 TO M-USEALT
         MOVE WS-S-AMETHYST TO M-ST
         IF M-SG < 0
             MOVE 1 TO M-USEALT
             MOVE WS-S-BUDDING TO M-ST
         END-IF
         PERFORM M-SAFESET
         IF M-REQ = 0 OR M-USEALT = 1
             PERFORM M-FLOATDRAW
             MOVE M-NF TO M-FA
             MOVE M-POT TO M-FB
             PERFORM M-SIGN
             IF M-SG < 0
                 ADD 1 TO M-NPOT
                 MOVE M-QX TO M-OX(M-NPOT)
                 MOVE M-QY TO M-OY(M-NPOT)
                 MOVE M-QZ TO M-OZ(M-NPOT)
             END-IF
         END-IF
         EXIT PARAGRAPH
     END-IF
     MOVE M-S1 TO M-FA
     MOVE M-MIDDLE TO M-FB
     PERFORM M-SIGN
     IF M-SG >= 0
         MOVE WS-S-CALCITE TO M-ST
     ELSE
         MOVE WS-S-BASALT TO M-ST
     END-IF
     PERFORM M-SAFESET
     .
 COPY SPELPROC.
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-6-4.
 COPY CORETEST.
