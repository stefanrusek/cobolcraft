*> Implementation test of the large dripstone (docs/protocol/35-worldgen-features-6-underground.md section 7; core/src/feat-drip.cob): the data feature compiles (type 26; a missing column_radius or
*> wind_speed, a clamped_normal provider, a search range outside 1 to 512, a radius range with min above max and a full feature table make it unsupported), the height function matches the
*> worked values of 11.3, and over 64 caves (a low cave, tall caves, flooded, a lava floor, a porous ceiling that makes the circle test shrink the radius, caves with no ceiling, too low or an origin in
*> stone) every cell equals an independent model on a second random source: the scan (7.4 steps 1 to 3), the radius draw, the two objects' draws, the wind, moveBack with the radius halving, and
*> placeBlocks with its one or two draws per column. The model takes every Java float operation as an IEEE operation rounded to binary32 and the table cos and sin from the shim.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-6-7.
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
 COPY XORO.
 COPY XORO REPLACING ==XR-STATE== BY ==XR2-STATE== LEADING ==XR-== BY ==X2-==.
 COPY SPELWS.
 01 WS-SEEDNO              BINARY-LONG.
 01 WS-SEEDTXT             PIC 99.
 01 WS-VARIANT             BINARY-LONG.
 01 WS-CUR-FT              BINARY-LONG.
 01 WS-FT-REAL             BINARY-LONG.
 01 WS-FT-CONST            BINARY-LONG.
 01 WS-LCG                 BINARY-DOUBLE.
 01 WS-MODEL-RESULT        BINARY-LONG.
 01 WS-N-PLACED            BINARY-LONG VALUE 0.
 01 WS-N-WIND              BINARY-LONG VALUE 0.
 01 WS-N-SHRUNK            BINARY-LONG VALUE 0.
 01 WS-N-NOROOT            BINARY-LONG VALUE 0.
 01 WS-N-DRIP              BINARY-LONG VALUE 0.
 01 WS-DRIP-STATE          BINARY-LONG.
 01 WS-S-LAVA              BINARY-LONG.
 01 WS-S-GRAN              BINARY-LONG.
*> model
 01 M-CEIL                 BINARY-LONG.
 01 M-FLOOR                BINARY-LONG.
 01 M-HEIGHT               BINARY-LONG.
 01 M-RAD                  BINARY-LONG.
 01 M-MAXR                 BINARY-LONG.
 01 M-I                    BINARY-LONG.
 01 M-J                    BINARY-LONG.
 01 M-K                    BINARY-LONG.
 01 M-T                    BINARY-LONG.
 01 M-OBJ.
    05 MO OCCURS 2 TIMES.
       10 MO-X             BINARY-LONG.
       10 MO-Y             BINARY-LONG.
       10 MO-Z             BINARY-LONG.
       10 MO-R             BINARY-LONG.
       10 MO-BL            FLOAT-LONG.
       10 MO-SC            FLOAT-LONG.
       10 MO-OK            BINARY-LONG.
 01 M-S                    BINARY-LONG.
 01 M-WIND                 BINARY-LONG.
 01 M-WX                   FLOAT-LONG.
 01 M-WZ                   FLOAT-LONG.
 01 M-FA                   FLOAT-LONG.
 01 M-FB                   FLOAT-LONG.
 01 M-FR                   FLOAT-LONG.
 01 M-FR2                  FLOAT-LONG.
 01 M-X1                   FLOAT-LONG.
 01 M-X2                   FLOAT-LONG.
 01 M-X3                   FLOAT-LONG.
 01 M-X4                   FLOAT-LONG.
 01 M-SG                   BINARY-LONG.
 01 M-S1                   FLOAT-LONG.
 01 M-S2                   FLOAT-LONG.
 01 M-NF                   FLOAT-LONG.
 01 M-NF2                  FLOAT-LONG.
 01 M-HI                   BINARY-DOUBLE.
 01 M-B24                  BINARY-LONG VALUE 24.
 01 M-TWO24                FLOAT-LONG VALUE 16777216.
 01 M-LIT                  FLOAT-LONG.
 01 M-C0384                FLOAT-LONG.
 01 M-C075                 FLOAT-LONG.
 01 M-C43                  FLOAT-LONG.
 01 M-C23                  FLOAT-LONG.
 01 M-C13                  FLOAT-LONG.
 01 M-CTWOPI               FLOAT-LONG.
 01 M-CPI                  FLOAT-LONG.
 01 M-C02                  FLOAT-LONG.
 01 M-C08                  FLOAT-LONG.
 01 M-C10                  FLOAT-LONG VALUE 1.0.
 01 M-C6                   FLOAT-LONG VALUE 6.0.
 01 M-C0                   FLOAT-LONG VALUE 0.
 01 M-C033                 FLOAT-LONG.
 01 M-CMINB                FLOAT-LONG.
 01 M-CMINW                FLOAT-LONG.
 01 M-HD                   FLOAT-LONG.
 01 M-HOUT                 BINARY-LONG.
 01 M-RD                   FLOAT-LONG.
 01 M-DY                   FLOAT-LONG.
 01 M-ORIGIN-Y             BINARY-LONG.
 01 M-MAXOFF               BINARY-LONG.
 01 M-OFX                  BINARY-LONG.
 01 M-OFZ                  BINARY-LONG.
 01 M-PY                   BINARY-LONG.
 01 M-AX                   BINARY-LONG.
 01 M-AZ                   BINARY-LONG.
 01 M-EMB                  BINARY-LONG.
 01 M-ANG                  FLOAT-LONG.
 01 M-STEP                 FLOAT-LONG.
 01 M-STOP                 BINARY-LONG.
 01 M-CX                   BINARY-LONG.
 01 M-CY                   BINARY-LONG.
 01 M-CZ                   BINARY-LONG.
 01 M-DONE                 BINARY-LONG.
 01 M-DX                   BINARY-LONG.
 01 M-DZ                   BINARY-LONG.
 01 M-H                    BINARY-LONG.
 01 M-LIM                  BINARY-LONG.
 01 M-PLACED               BINARY-LONG.
 01 M-CLS                  BINARY-LONG.
 01 M-SQ                   BINARY-LONG.
 01 M-STR                  PIC X(112).
 01 M-ORD0                 BINARY-LONG VALUE 0.
 01 M-BOUND                BINARY-LONG.
 01 M-SCOLS                BINARY-LONG.
 01 M-GS                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
*>   the tags: dripstone_replaceable_blocks and base_stone_overworld are stone, granite, diorite and andesite here
     MOVE "stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-STONE
     MOVE WS-WANT TO WS-SETB(1)
     COMPUTE WS-ID(1) = WS-WANT - 1
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-STONE
     MOVE "granite" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-SETB(2)
     COMPUTE WS-ID(2) = WS-WANT - 1
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-GRAN
     MOVE "diorite" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-SETB(3)
     COMPUTE WS-ID(3) = WS-WANT - 1
     MOVE "andesite" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-SETB(4)
     COMPUTE WS-ID(4) = WS-WANT - 1
     MOVE 4 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "minecraft:base_stone_overworld" TO WS-TAG
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "dripstone_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-BASE
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-BASE
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-DRIP-STATE
     MOVE "water" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-WATER
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-WATER
     MOVE "lava" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-LAVA
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-LAVA
     MOVE "air" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-AIR
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"0.384" M-C0384
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"0.75" M-C075
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"1.3333333333333333" M-C43
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"0.6666666666666666" M-C23
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"0.3333333333333333" M-C13
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"6.2831855" M-LIT
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE M-LIT M-CTWOPI
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"3.1415927" M-LIT
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE M-LIT M-CPI
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"0.2" M-LIT
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE M-LIT M-C02
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"0.8" M-LIT
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE M-LIT M-C08
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"0.33" M-LIT
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE M-LIT M-C033

*>   the data features compile
     MOVE "minecraft:large" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "35-6§7.1: the data feature large compiles as type 26" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 26 TO WS-EXP
     PERFORM ASSERT-N
     MOVE WS-FT TO WS-FT-REAL
     MOVE "35-6§7.1: the radius bounds are 3 and 16 and the search range defaults to 30" TO WS-CASE
     MOVE WA-I(FT-A(WS-FT), 3) TO WS-OBS
     COMPUTE WS-OBS = WS-OBS * 10000 + WA-I(FT-A(WS-FT), 4) * 100 + WA-I(FT-A(WS-FT), 2)
     MOVE 31630 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-6§7.1: the replaceable set is the four blocks of the tag" TO WS-CASE
     MOVE WA-N(FT-A(WS-FT), 1) TO WS-OBS
     MOVE 4 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:large_const" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE WS-FT TO WS-FT-CONST
     MOVE "35-6§7.1: constant providers and a constant radius compile (radius bounds 4 and 4, range 20)" TO WS-CASE
     MOVE WA-I(FT-A(WS-FT), 3) TO WS-OBS
     COMPUTE WS-OBS = WS-OBS * 10000 + WA-I(FT-A(WS-FT), 4) * 100 + WA-I(FT-A(WS-FT), 2)
     MOVE 40420 TO WS-EXP
     PERFORM ASSERT-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         EVALUATE WS-I
             WHEN 1
                 MOVE "minecraft:large_badscale" TO WS-FTKEY
                 MOVE "a clamped_normal height_scale" TO WS-NAME
             WHEN 2
                 MOVE "minecraft:large_nowind" TO WS-FTKEY
                 MOVE "a missing wind_speed" TO WS-NAME
             WHEN 3
                 MOVE "minecraft:large_noradius" TO WS-FTKEY
                 MOVE "a missing column_radius" TO WS-NAME
             WHEN 4
                 MOVE "minecraft:large_badrange" TO WS-FTKEY
                 MOVE "a search range of 600" TO WS-NAME
             WHEN 5
                 MOVE "minecraft:large_badradius" TO WS-FTKEY
                 MOVE "a radius range with min above max" TO WS-NAME
             WHEN OTHER
                 MOVE "minecraft:large_full" TO WS-FTKEY
                 MOVE "a full feature table" TO WS-NAME
                 MOVE FD-MAX-WA TO FD-WA-COUNT
         END-EVALUATE
         PERFORM COMPILE-FT
         IF WS-I = 6
             MOVE 5 TO FD-WA-COUNT
         END-IF
         MOVE SPACES TO WS-CASE
         STRING "35-6§7.1: " FUNCTION TRIM(WS-NAME) " makes the feature unsupported" DELIMITED BY SIZE INTO WS-CASE
         MOVE FT-TYPE(WS-FT) TO WS-OBS
         MOVE -1 TO WS-EXP
         PERFORM ASSERT-N
     END-PERFORM
     MOVE 1 TO FI-GATE
     MOVE "minecraft:large_dripstone" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-6§7: the gate admits the placed feature large_dripstone" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   the worked values of 11.3 (the model's height function, then the same function through a run is checked by the cave cases)
     PERFORM VARYING M-I FROM 1 BY 1 UNTIL M-I > 7
         EVALUATE M-I
             WHEN 1
                 MOVE 0 TO M-HD
                 MOVE 6 TO M-RAD
                 MOVE 1.0 TO MO-SC(1)
                 MOVE 0.5 TO MO-BL(1)
                 MOVE 16 TO WS-EXP
             WHEN 2
                 MOVE 3 TO M-HD
                 MOVE 6 TO M-RAD
                 MOVE 1.0 TO MO-SC(1)
                 MOVE 0.5 TO MO-BL(1)
                 MOVE 4 TO WS-EXP
             WHEN 3
                 MOVE 6 TO M-HD
                 MOVE 6 TO M-RAD
                 MOVE 1.0 TO MO-SC(1)
                 MOVE 0.5 TO MO-BL(1)
                 MOVE 0 TO WS-EXP
             WHEN 4
                 MOVE 0 TO M-HD
                 MOVE 10 TO M-RAD
                 MOVE 1.0 TO MO-SC(1)
                 MOVE 0.3 TO MO-BL(1)
                 MOVE 37 TO WS-EXP
             WHEN 5
                 MOVE 5 TO M-HD
                 MOVE 10 TO M-RAD
                 MOVE 1.0 TO MO-SC(1)
                 MOVE 0.3 TO MO-BL(1)
                 MOVE 7 TO WS-EXP
             WHEN 6
                 MOVE 0 TO M-HD
                 MOVE 6 TO M-RAD
                 MOVE 2.0 TO MO-SC(1)
                 MOVE 0.5 TO MO-BL(1)
                 MOVE 32 TO WS-EXP
             WHEN OTHER
                 MOVE 0 TO M-HD
                 MOVE 3 TO M-RAD
                 MOVE 0.4 TO MO-SC(1)
                 MOVE 0.4 TO MO-BL(1)
                 MOVE 2 TO WS-EXP
         END-EVALUATE
         MOVE 1 TO M-S
         MOVE M-RAD TO MO-R(1)
         PERFORM M-HEIGHT-AT
         MOVE SPACES TO WS-CASE
         MOVE M-I TO WS-SEEDTXT
         STRING "35-6§11.3: the height function row " WS-SEEDTXT " gives the document's value" DELIMITED BY SIZE INTO WS-CASE
         MOVE M-HOUT TO WS-OBS
         PERFORM ASSERT-N
     END-PERFORM

     MOVE 11 TO WS-LCG
     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 64
         COMPUTE WS-SEED = WS-SEEDNO * 6151
         MOVE WS-SEEDNO TO WS-SEEDTXT
         COMPUTE WS-VARIANT = FUNCTION MOD(WS-SEEDNO, 8)
         IF FUNCTION MOD(WS-SEEDNO, 16) < 8
             MOVE WS-FT-REAL TO WS-CUR-FT
         ELSE
             MOVE WS-FT-CONST TO WS-CUR-FT
         END-IF
         PERFORM NEW-WORLD
         PERFORM MAKE-CAVE
         PERFORM SNAPSHOT
         CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
         CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
         MOVE 24 TO WS-OX
         MOVE 60 TO WS-OY
         MOVE 40 TO WS-OZ
         IF WS-VARIANT = 7
             MOVE 40 TO WS-OY
         END-IF
         PERFORM MODEL-RUN
         CALL "FR-PLACE-FT" USING XR-STATE WS-CUR-FT WS-OX WS-OY WS-OZ WS-RESULT
         MOVE 0 TO WS-BAD
         PERFORM COMPARE
         MOVE SPACES TO WS-CASE
         STRING "35-6§7: cave " WS-SEEDTXT " the cells equal the model" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-BAD TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
         MOVE SPACES TO WS-CASE
         STRING "35-6§7: cave " WS-SEEDTXT " the result and the random state equal the model's" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1000 TO WS-DRAW
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-OBS
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-DRAW WS-EXP
         COMPUTE WS-OBS = WS-RESULT * 1000 + WS-OBS
         COMPUTE WS-EXP = WS-MODEL-RESULT * 1000 + WS-EXP
         PERFORM ASSERT-N
     END-PERFORM
     MOVE "35-6§7: dripstone was placed in many caves" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-PLACED > 20
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-6§7: some runs had wind" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-WIND > 0
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM ASSERT-N
     MOVE "35-6§7: some run shrank the radius to fit" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-SHRUNK > 0
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM ASSERT-N
     MOVE "35-6§7: some object found no root" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-N-NOROOT > 0
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM ASSERT-N
     STOP RUN
     .
*> MAKE-CAVE: the cave of the variant over the world of NEW-WORLD (stone y 40 to 62, air 63 to 69, stone 70 to 80): 0 as it is (height 7); 1 and 5 tall (air from y 50); 2 tall and flooded to y 55;
*> 3 tall over a lava floor at y 49; 4 and 6 tall with a porous ceiling (air holes in the stone y 70 to 76 from the test's own sequence, 6 with more); 7 the origin inside the stone (y 40);
*> the seeds above 56 also have no stone above (air y 70 to 80: no ceiling in range) in variant 1 and a low cave (stone y 63 to 67) in variant 5.
 MAKE-CAVE.
     IF WS-VARIANT >= 1
         MOVE 16 TO WS-X0
         MOVE 31 TO WS-X1
         MOVE 32 TO WS-Z0
         MOVE 47 TO WS-Z1
         MOVE 50 TO WS-Y0
         MOVE 62 TO WS-Y1
         MOVE "air" TO WS-KEY
         PERFORM FILL-BOX
     END-IF
     IF WS-VARIANT = 2
         MOVE 55 TO WS-Y1
         MOVE "water" TO WS-KEY
         PERFORM FILL-BOX
     END-IF
     IF WS-VARIANT = 3
         MOVE 49 TO WS-Y0
         MOVE 49 TO WS-Y1
         MOVE "lava" TO WS-KEY
         PERFORM FILL-BOX
     END-IF
     IF WS-VARIANT = 4 OR WS-VARIANT = 6
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 150 + WS-VARIANT * 20
             COMPUTE WS-LCG = FUNCTION MOD(WS-LCG * 1103515245 + 12345, 2147483648)
             COMPUTE WS-X = 18 + FUNCTION MOD(WS-LCG / 65536, 13)
             COMPUTE WS-LCG = FUNCTION MOD(WS-LCG * 1103515245 + 12345, 2147483648)
             COMPUTE WS-Z = 34 + FUNCTION MOD(WS-LCG / 65536, 13)
             COMPUTE WS-LCG = FUNCTION MOD(WS-LCG * 1103515245 + 12345, 2147483648)
             COMPUTE WS-Y = 70 + FUNCTION MOD(WS-LCG / 65536, 7)
             MOVE WS-S-AIR TO WS-STATE
             CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
         END-PERFORM
     END-IF
     IF WS-SEEDNO > 56 AND WS-VARIANT = 1
         MOVE 70 TO WS-Y0
         MOVE 80 TO WS-Y1
         MOVE "air" TO WS-KEY
         PERFORM FILL-BOX
     END-IF
     IF WS-SEEDNO > 56 AND WS-VARIANT = 5
         MOVE 63 TO WS-Y0
         MOVE 67 TO WS-Y1
         MOVE "stone" TO WS-KEY
         PERFORM FILL-BOX
     END-IF
     .
*> ---- the model: IEEE helpers (M-FA op M-FB gives M-FR; M-RND32 rounds M-FR to binary32)
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
 M-RND32.
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE M-FR M-FR2
     MOVE M-FR2 TO M-FR
     .
*> M-SIGN: M-SG = the sign of M-FA - M-FB
 M-SIGN.
     CALL STATIC "cc_f64_sub" USING BY REFERENCE M-FA M-FB M-S1
     CALL STATIC "cc_f64_signum" USING BY REFERENCE M-S1 M-S2
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE M-S2 M-SG
     .
*> M-FLOAT: M-NF = nextFloat() of the model's random source (24 bit draw over 2^24)
 M-FLOAT.
     CALL "WGR-NEXT" USING XR2-STATE M-B24 M-HI
     MOVE M-HI TO M-FA
     MOVE M-TWO24 TO M-FB
     PERFORM M-DIVF
     MOVE M-FR TO M-NF
     .
*> M-UNIFORM: M-FR = nextFloat() * (max - min) + min in binary32 for the float provider (kind M-K, min M-X1, max M-X2); a constant (kind 1) is its value and draws nothing
 M-UNIFORM.
     MOVE M-X1 TO M-FR
     PERFORM M-RND32
     MOVE M-FR TO M-X1
     IF M-K = 2
         PERFORM M-FLOAT
         MOVE M-X2 TO M-FR
         PERFORM M-RND32
         MOVE M-FR TO M-X2
         MOVE M-X2 TO M-FA
         MOVE M-X1 TO M-FB
         PERFORM M-SUB
         PERFORM M-RND32
         MOVE M-FR TO M-FB
         MOVE M-NF TO M-FA
         PERFORM M-MUL
         PERFORM M-RND32
         MOVE M-FR TO M-FA
         MOVE M-X1 TO M-FB
         PERFORM M-ADD
         PERFORM M-RND32
     ELSE
         MOVE M-X1 TO M-FR
     END-IF
     .
*> M-HEIGHT-AT: M-HOUT = (int) getSpeleothemHeight(M-HD, radius MO-R(M-S), scale MO-SC(M-S), bluntness MO-BL(M-S)) with doubles (7.2)
 M-HEIGHT-AT.
     MOVE M-HD TO M-FA
     MOVE MO-BL(M-S) TO M-FB
     PERFORM M-SIGN
     IF M-SG < 0
         MOVE MO-BL(M-S) TO M-HD
     END-IF
     MOVE MO-R(M-S) TO M-RD
     MOVE M-HD TO M-FA
     MOVE M-RD TO M-FB
     PERFORM M-DIVF
     MOVE M-FR TO M-FA
     MOVE M-C0384 TO M-FB
     PERFORM M-MUL
     MOVE M-FR TO M-X1
*>   a = 0.75 * t^(4/3), b = t^(2/3), c = (1/3) ln t
     CALL STATIC "cc_f64_pow" USING BY REFERENCE M-X1 M-C43 M-FR
     MOVE M-C075 TO M-FA
     MOVE M-FR TO M-FB
     PERFORM M-MUL
     MOVE M-FR TO M-X2
     CALL STATIC "cc_f64_pow" USING BY REFERENCE M-X1 M-C23 M-FR
     MOVE M-FR TO M-X3
     CALL STATIC "cc_f64_log" USING BY REFERENCE M-X1 M-FR
     MOVE M-C13 TO M-FA
     MOVE M-FR TO M-FB
     PERFORM M-MUL
     MOVE M-FR TO M-X4
     MOVE M-X2 TO M-FA
     MOVE M-X3 TO M-FB
     PERFORM M-SUB
     MOVE M-FR TO M-FA
     MOVE M-X4 TO M-FB
     PERFORM M-SUB
     MOVE MO-SC(M-S) TO M-FA
     MOVE M-FR TO M-FB
     PERFORM M-MUL
     MOVE M-FR TO M-FA
     MOVE M-C0 TO M-FB
     PERFORM M-SIGN
     IF M-SG < 0
         MOVE M-C0 TO M-FR
     END-IF
     MOVE M-FR TO M-FA
     MOVE M-C0384 TO M-FB
     PERFORM M-DIVF
     MOVE M-FR TO M-FA
     MOVE M-RD TO M-FB
     PERFORM M-MUL
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE M-FR M-HOUT
     .
*> M-OFFSET: the wind offset (M-OFX, M-OFZ) of a cell at height M-PY
 M-OFFSET.
     MOVE 0 TO M-OFX M-OFZ
     IF M-WIND = 1
         COMPUTE M-T = M-ORIGIN-Y - M-PY
         MOVE M-T TO M-DY
         MOVE M-WX TO M-FA
         MOVE M-DY TO M-FB
         PERFORM M-MUL
         CALL STATIC "cc_f64_floor" USING BY REFERENCE M-FR M-FR2
         CALL STATIC "cc_f64_to_i32" USING BY REFERENCE M-FR2 M-OFX
         MOVE M-WZ TO M-FA
         PERFORM M-MUL
         CALL STATIC "cc_f64_floor" USING BY REFERENCE M-FR M-FR2
         CALL STATIC "cc_f64_to_i32" USING BY REFERENCE M-FR2 M-OFZ
         COMPUTE M-T = 0 - M-MAXOFF
         COMPUTE M-OFX = FUNCTION MAX(M-T, FUNCTION MIN(M-OFX, M-MAXOFF))
         COMPUTE M-OFZ = FUNCTION MAX(M-T, FUNCTION MIN(M-OFZ, M-MAXOFF))
     END-IF
     .
*> M-EMPTY3: M-CLS = 1 when the model cell (WS-MX, WS-MY, WS-MZ) is air, water or lava
 M-EMPTY3.
     PERFORM MGET
     PERFORM MBLOCK
     MOVE 0 TO M-CLS
     IF WS-MV = WS-S-AIR OR WS-MB = WS-B-WATER OR WS-MB = WS-B-LAVA
         MOVE 1 TO M-CLS
     END-IF
     .
*> M-EMBED: M-EMB 1 when the circle of the radius M-RAD at (M-CX, M-CY, M-CZ) is mostly embedded in stone (7.3)
 M-EMBED.
     MOVE M-CX TO WS-MX
     MOVE M-CY TO WS-MY
     MOVE M-CZ TO WS-MZ
     PERFORM M-EMPTY3
     IF M-CLS = 1
         MOVE 0 TO M-EMB
         EXIT PARAGRAPH
     END-IF
     MOVE 1 TO M-EMB
     MOVE M-RAD TO M-RD
     MOVE M-C6 TO M-FA
     MOVE M-RD TO M-FB
     PERFORM M-DIVF
     PERFORM M-RND32
     MOVE M-FR TO M-STEP
     MOVE M-C0 TO M-ANG
     MOVE 0 TO M-STOP
     PERFORM UNTIL M-STOP = 1
         MOVE M-ANG TO M-FA
         MOVE M-CTWOPI TO M-FB
         PERFORM M-SIGN
         IF M-SG >= 0
             MOVE 1 TO M-STOP
         ELSE
             CALL STATIC "cc_f64_cos_tab" USING BY REFERENCE M-ANG M-FA
             MOVE M-RD TO M-FB
             PERFORM M-MUL
             PERFORM M-RND32
             CALL STATIC "cc_f64_to_i32" USING BY REFERENCE M-FR M-AX
             CALL STATIC "cc_f64_sin_tab" USING BY REFERENCE M-ANG M-FA
             PERFORM M-MUL
             PERFORM M-RND32
             CALL STATIC "cc_f64_to_i32" USING BY REFERENCE M-FR M-AZ
             COMPUTE WS-MX = M-CX + M-AX
             MOVE M-CY TO WS-MY
             COMPUTE WS-MZ = M-CZ + M-AZ
             PERFORM M-EMPTY3
             IF M-CLS = 1
                 MOVE 0 TO M-EMB
                 MOVE 1 TO M-STOP
             ELSE
                 MOVE M-ANG TO M-FA
                 MOVE M-STEP TO M-FB
                 PERFORM M-ADD
                 PERFORM M-RND32
                 MOVE M-FR TO M-ANG
             END-IF
         END-IF
     END-PERFORM
     .
*> M-MOVEBACK (7.5) of the object M-S: MO-OK 1 when it found a root
 M-MOVEBACK.
     MOVE 0 TO MO-OK(M-S)
     MOVE 0 TO M-DONE
     PERFORM UNTIL MO-R(M-S) <= 1 OR M-DONE = 1
         MOVE MO-X(M-S) TO M-AX
         MOVE MO-Y(M-S) TO M-PY
         MOVE MO-Z(M-S) TO M-AZ
         MOVE M-C0 TO M-HD
         PERFORM M-HEIGHT-AT
         COMPUTE M-J = FUNCTION MIN(10, M-HOUT)
         MOVE 0 TO M-I
         PERFORM UNTIL M-I >= M-J OR M-DONE = 1
             MOVE MO-X(M-S) TO WS-MX
             MOVE M-PY TO WS-MY
             MOVE MO-Z(M-S) TO WS-MZ
             PERFORM MGET
             PERFORM MBLOCK
             IF WS-MB = WS-B-LAVA
                 MOVE 1 TO M-DONE
             ELSE
                 PERFORM M-OFFSET
                 COMPUTE M-CX = MO-X(M-S) + M-OFX
                 MOVE M-PY TO M-CY
                 COMPUTE M-CZ = MO-Z(M-S) + M-OFZ
                 MOVE MO-R(M-S) TO M-RAD
                 PERFORM M-EMBED
                 IF M-EMB = 1
                     MOVE M-PY TO MO-Y(M-S)
                     MOVE 1 TO MO-OK(M-S)
                     MOVE 1 TO M-DONE
                 ELSE
                     IF M-S = 2
                         SUBTRACT 1 FROM M-PY
                     ELSE
                         ADD 1 TO M-PY
                     END-IF
                     ADD 1 TO M-I
                 END-IF
             END-IF
         END-PERFORM
         IF M-DONE = 0
             COMPUTE MO-R(M-S) = MO-R(M-S) / 2
             ADD 1 TO WS-N-SHRUNK
         END-IF
     END-PERFORM
     IF MO-OK(M-S) = 0
         ADD 1 TO WS-N-NOROOT
     END-IF
     .
*> M-PLACE-BLOCKS (7.6) of the object M-S
 M-PLACE-BLOCKS.
     COMPUTE M-GS = 0 - MO-R(M-S)
     PERFORM VARYING M-DX FROM M-GS BY 1 UNTIL M-DX > MO-R(M-S)
         PERFORM VARYING M-DZ FROM M-GS BY 1 UNTIL M-DZ > MO-R(M-S)
             COMPUTE M-SQ = M-DX * M-DX + M-DZ * M-DZ
             MOVE M-SQ TO M-FA
             CALL STATIC "cc_f64_sqrt" USING BY REFERENCE M-FA M-FR
             PERFORM M-RND32
             MOVE M-FR TO M-HD
             MOVE M-HD TO M-FA
             MOVE MO-R(M-S) TO M-FB
             PERFORM M-SIGN
             IF M-SG <= 0
                 PERFORM M-HEIGHT-AT
                 MOVE M-HOUT TO M-H
                 IF M-H > 0
                     PERFORM M-COLUMN
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     .
 M-COLUMN.
     PERFORM M-FLOAT
     MOVE M-NF TO M-FA
     MOVE M-C02 TO M-FB
     PERFORM M-SIGN
     IF M-SG < 0
         PERFORM M-FLOAT
         MOVE M-C10 TO M-FA
         MOVE M-C08 TO M-FB
         PERFORM M-SUB
         PERFORM M-RND32
         MOVE M-FR TO M-FB
         MOVE M-NF TO M-FA
         PERFORM M-MUL
         PERFORM M-RND32
         MOVE M-FR TO M-FA
         MOVE M-C08 TO M-FB
         PERFORM M-ADD
         PERFORM M-RND32
         MOVE M-FR TO M-FB
         MOVE M-H TO M-FA
         PERFORM M-MUL
         PERFORM M-RND32
         CALL STATIC "cc_f64_to_i32" USING BY REFERENCE M-FR M-H
     END-IF
     COMPUTE M-AX = MO-X(M-S) + M-DX
     MOVE MO-Y(M-S) TO M-PY
     COMPUTE M-AZ = MO-Z(M-S) + M-DZ
     MOVE 0 TO M-PLACED
     IF M-S = 2
*>       the WORLD_SURFACE_WG height of the model's world: the first y above the highest block that is not air
         MOVE 319 TO M-LIM
         MOVE 0 TO M-DONE
         PERFORM UNTIL M-LIM < -64 OR M-DONE = 1
             MOVE M-AX TO WS-MX
             MOVE M-LIM TO WS-MY
             MOVE M-AZ TO WS-MZ
             PERFORM MGET
             IF WS-MV NOT = WS-S-AIR
                 MOVE 1 TO M-DONE
             ELSE
                 SUBTRACT 1 FROM M-LIM
             END-IF
         END-PERFORM
         ADD 1 TO M-LIM
     ELSE
         MOVE 2147483647 TO M-LIM
     END-IF
     MOVE 0 TO M-I
     MOVE 0 TO M-DONE
     PERFORM UNTIL M-I >= M-H OR M-PY >= M-LIM OR M-DONE = 1
         PERFORM M-OFFSET
         COMPUTE WS-MX = M-AX + M-OFX
         MOVE M-PY TO WS-MY
         COMPUTE WS-MZ = M-AZ + M-OFZ
         PERFORM M-EMPTY3
         IF M-CLS = 1
             MOVE 1 TO M-PLACED
             MOVE WS-S-BASE TO WS-MV
             PERFORM MSET
             ADD 1 TO WS-N-DRIP
         ELSE
             IF M-PLACED = 1
                 PERFORM MBLOCK
                 IF WS-MB = WS-SETB(1) OR WS-MB = WS-SETB(2) OR WS-MB = WS-SETB(3) OR WS-MB = WS-SETB(4)
                     MOVE 1 TO M-DONE
                 END-IF
             END-IF
         END-IF
         IF M-DONE = 0
             IF M-S = 2
                 ADD 1 TO M-PY
             ELSE
                 SUBTRACT 1 FROM M-PY
             END-IF
             ADD 1 TO M-I
         END-IF
     END-PERFORM
     .
*> M-FPROV: the float provider n of the compiled row (1 height_scale, 2 stalactite_bluntness, 3 stalagmite_bluntness, 4 wind_speed): sampled into M-FR
 M-FPROV.
     MOVE WA-I(FT-A(WS-CUR-FT), 4 + M-GS) TO M-K
     COMPUTE M-T = (M-GS - 1) * 2 + 1
     MOVE WA-G(FT-A(WS-CUR-FT), M-T) TO M-X1
     MOVE WA-G(FT-A(WS-CUR-FT), M-T + 1) TO M-X2
     PERFORM M-UNIFORM
     .
*> MODEL-RUN (7.4)
 MODEL-RUN.
     MOVE 0 TO WS-MODEL-RESULT
     MOVE 0 TO M-WIND
     MOVE WS-OX TO WS-MX
     MOVE WS-OY TO WS-MY
     MOVE WS-OZ TO WS-MZ
     PERFORM M-EMPTY3
     IF M-CLS = 0 OR WS-MB = WS-B-LAVA
         EXIT PARAGRAPH
     END-IF
*>   the scan: up while the cell is air or water, at most range - 1 steps, ending on the first other block, which has to be a base cell or lava
     MOVE 0 TO M-CEIL
     MOVE WS-OY TO M-PY
     MOVE 1 TO M-I
     MOVE 0 TO M-DONE
     PERFORM UNTIL M-I >= WA-I(FT-A(WS-CUR-FT), 2) OR M-DONE = 1
         MOVE WS-OX TO WS-MX
         MOVE M-PY TO WS-MY
         MOVE WS-OZ TO WS-MZ
         PERFORM MGET
         PERFORM MBLOCK
         IF WS-MV = WS-S-AIR OR WS-MB = WS-B-WATER
             ADD 1 TO M-PY
             ADD 1 TO M-I
         ELSE
             MOVE 1 TO M-DONE
         END-IF
     END-PERFORM
     MOVE WS-OX TO WS-MX
     MOVE M-PY TO WS-MY
     MOVE WS-OZ TO WS-MZ
     PERFORM MGET
     PERFORM MBLOCK
     MOVE -1000 TO M-CEIL
     IF WS-MB = WS-B-BASE OR WS-MB = WS-B-LAVA OR WS-MB = WS-SETB(1) OR WS-MB = WS-SETB(2) OR WS-MB = WS-SETB(3) OR WS-MB = WS-SETB(4)
         MOVE M-PY TO M-CEIL
     END-IF
     MOVE WS-OY TO M-PY
     MOVE 1 TO M-I
     MOVE 0 TO M-DONE
     PERFORM UNTIL M-I >= WA-I(FT-A(WS-CUR-FT), 2) OR M-DONE = 1
         MOVE WS-OX TO WS-MX
         MOVE M-PY TO WS-MY
         MOVE WS-OZ TO WS-MZ
         PERFORM MGET
         PERFORM MBLOCK
         IF WS-MV = WS-S-AIR OR WS-MB = WS-B-WATER
             SUBTRACT 1 FROM M-PY
             ADD 1 TO M-I
         ELSE
             MOVE 1 TO M-DONE
         END-IF
     END-PERFORM
     MOVE WS-OX TO WS-MX
     MOVE M-PY TO WS-MY
     MOVE WS-OZ TO WS-MZ
     PERFORM MGET
     PERFORM MBLOCK
     MOVE -1000 TO M-FLOOR
     IF WS-MB = WS-B-BASE OR WS-MB = WS-B-LAVA OR WS-MB = WS-SETB(1) OR WS-MB = WS-SETB(2) OR WS-MB = WS-SETB(3) OR WS-MB = WS-SETB(4)
         MOVE M-PY TO M-FLOOR
     END-IF
     IF M-CEIL = -1000 OR M-FLOOR = -1000
         EXIT PARAGRAPH
     END-IF
     COMPUTE M-HEIGHT = M-CEIL - M-FLOOR - 1
     IF M-HEIGHT < 4
         EXIT PARAGRAPH
     END-IF
     MOVE 1 TO WS-MODEL-RESULT
*>   the radius: (int)((float) height * ratio), clamped to the bounds, then one draw
     MOVE WA-F(FT-A(WS-CUR-FT), 1) TO M-FR
     PERFORM M-RND32
     MOVE M-FR TO M-FB
     MOVE M-HEIGHT TO M-FA
     PERFORM M-MUL
     PERFORM M-RND32
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE M-FR M-MAXR
     COMPUTE M-MAXR = FUNCTION MAX(WA-I(FT-A(WS-CUR-FT), 3), FUNCTION MIN(M-MAXR, WA-I(FT-A(WS-CUR-FT), 4)))
     COMPUTE M-BOUND = M-MAXR - WA-I(FT-A(WS-CUR-FT), 3) + 1
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-BOUND M-I
     COMPUTE M-RAD = M-I + WA-I(FT-A(WS-CUR-FT), 3)
*>   the objects: the stalactite first (bluntness, scale), then the stalagmite
     MOVE WS-OX TO MO-X(1)
     COMPUTE MO-Y(1) = M-CEIL - 1
     MOVE WS-OZ TO MO-Z(1)
     MOVE M-RAD TO MO-R(1)
     MOVE 2 TO M-GS
     PERFORM M-FPROV
     MOVE M-FR TO MO-BL(1)
     MOVE 1 TO M-GS
     PERFORM M-FPROV
     MOVE M-FR TO MO-SC(1)
     MOVE WS-OX TO MO-X(2)
     COMPUTE MO-Y(2) = M-FLOOR + 1
     MOVE WS-OZ TO MO-Z(2)
     MOVE M-RAD TO MO-R(2)
     MOVE 3 TO M-GS
     PERFORM M-FPROV
     MOVE M-FR TO MO-BL(2)
     MOVE 1 TO M-GS
     PERFORM M-FPROV
     MOVE M-FR TO MO-SC(2)
*>   the wind: both objects need the radius and the bluntness
     MOVE 0 TO M-K
     IF M-RAD >= WA-I(FT-A(WS-CUR-FT), 9)
         MOVE WA-F(FT-A(WS-CUR-FT), 2) TO M-FR
         PERFORM M-RND32
         MOVE M-FR TO M-CMINB
         MOVE MO-BL(1) TO M-FA
         MOVE M-CMINB TO M-FB
         PERFORM M-SIGN
         IF M-SG >= 0
             MOVE MO-BL(2) TO M-FA
             PERFORM M-SIGN
             IF M-SG >= 0
                 MOVE 1 TO M-K
             END-IF
         END-IF
     END-IF
     IF M-K = 1
         MOVE 1 TO M-WIND
         ADD 1 TO WS-N-WIND
         MOVE 4 TO M-GS
         PERFORM M-FPROV
         MOVE M-FR TO M-CMINW
         PERFORM M-FLOAT
         MOVE M-NF TO M-FA
         MOVE M-CPI TO M-FB
         PERFORM M-MUL
         PERFORM M-RND32
         MOVE M-FR TO M-FA
         MOVE M-C0 TO M-FB
         PERFORM M-ADD
         PERFORM M-RND32
         MOVE M-FR TO M-X1
         CALL STATIC "cc_f64_cos_tab" USING BY REFERENCE M-X1 M-FA
         MOVE M-CMINW TO M-FB
         PERFORM M-MUL
         PERFORM M-RND32
         MOVE M-FR TO M-WX
         CALL STATIC "cc_f64_sin_tab" USING BY REFERENCE M-X1 M-FA
         PERFORM M-MUL
         PERFORM M-RND32
         MOVE M-FR TO M-WZ
         MOVE WS-OY TO M-ORIGIN-Y
         COMPUTE M-MAXOFF = 16 - M-RAD
     END-IF
     MOVE 1 TO M-S
     PERFORM M-MOVEBACK
     MOVE 2 TO M-S
     PERFORM M-MOVEBACK
     IF MO-OK(1) = 1
         MOVE 1 TO M-S
         PERFORM M-PLACE-BLOCKS
     END-IF
     IF MO-OK(2) = 1
         MOVE 2 TO M-S
         PERFORM M-PLACE-BLOCKS
     END-IF
     ADD 1 TO WS-N-PLACED
     .
 COPY SPELPROC.
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-6-7.
 COPY CORETEST.
