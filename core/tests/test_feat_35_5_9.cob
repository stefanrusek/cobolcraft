*> Implementation test of the iceberg (docs/protocol/35-worldgen-features-5-water-and-surface.md section 9; core/src/feat-iceberg.cob): the data feature compiles (type 24; an unknown state makes it
*> unsupported), the gate admits iceberg_*, and over 40 seeds every cell of the chunk column equals an independent model on a shadow array with a second random source. The model takes the
*> binary32 steps with the IEEE helpers of the shim (cc_f64_*: each operation then rounded to binary32), the distances with the IEEE sign of a difference (zero axes divide to infinity or NaN),
*> the nextDouble tests as exact integers of the 53 bit draw (thresholds are the exact products of the double constants with 2^53) and the snow-cap test with doubles; it never caches a cosine.
*> The cases hold at least one elliptical berg, one round, one with snow on top, one with a cut-out and one tall round berg.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-5-9.
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
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/water".
 01 WS-PTR                 USAGE POINTER.
 01 WS-AREA                PIC X(304640) BASED.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-FT                  BINARY-LONG.
 01 WS-FT-PACKED           BINARY-LONG.
 01 WS-FT-BLUE             BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 5.
 01 WS-KEY                 PIC X(112).
 01 WS-NAME                PIC X(48).
 01 WS-FTKEY               PIC X(80).
 01 WS-PAIRS               PIC X(160).
 01 WS-CASE                PIC X(200).
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-SEEDNO              BINARY-LONG.
 01 WS-SEEDTXT             PIC 99.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-MIDX                BINARY-LONG.
 01 WS-SH.
    05 WS-OS               BINARY-LONG OCCURS 28416 TIMES.
 01 WS-S-PACK              BINARY-LONG.
 01 WS-S-BLUE              BINARY-LONG.
 01 WS-S-ICEB              BINARY-LONG.
 01 WS-S-SNOWB             BINARY-LONG.
 01 WS-S-WATER             BINARY-LONG.
 01 WS-B-SNOWB             BINARY-LONG.
 01 WS-B-ICE               BINARY-LONG.
 01 WS-B-PACK              BINARY-LONG.
 01 WS-B-BLUE              BINARY-LONG.
 01 WS-B-SNOW              BINARY-LONG.
 01 WS-B-WATER             BINARY-LONG.
 01 WS-N-ELL               BINARY-LONG VALUE 0.
 01 WS-N-ROUND             BINARY-LONG VALUE 0.
 01 WS-N-SNOW              BINARY-LONG VALUE 0.
 01 WS-N-CUT               BINARY-LONG VALUE 0.
 01 WS-N-TALL              BINARY-LONG VALUE 0.
 01 WS-N-CELLS             BINARY-LONG VALUE 0.
 01 WS-CUR-FT              BINARY-LONG.
*> model state
 01 M-SNOW                 BINARY-LONG.
 01 M-ELL                  BINARY-LONG.
 01 M-A                    BINARY-LONG.
 01 M-B                    BINARY-LONG.
 01 M-H                    BINARY-LONG.
 01 M-D                    BINARY-LONG.
 01 M-E                    BINARY-LONG.
 01 M-W                    BINARY-LONG.
 01 M-OX                   BINARY-LONG.
 01 M-OY                   BINARY-LONG.
 01 M-OZ                   BINARY-LONG.
 01 M-ANG                  FLOAT-LONG.
 01 M-ANG2                 FLOAT-LONG.
 01 M-HI                   BINARY-DOUBLE.
 01 M-LO                   BINARY-DOUBLE.
 01 M-K                    BINARY-DOUBLE.
 01 M-TH                   BINARY-DOUBLE.
 01 M-GT                   BINARY-LONG.
 01 M-BITS26               BINARY-LONG VALUE 26.
 01 M-BITS27               BINARY-LONG VALUE 27.
 01 M-BITS24               BINARY-LONG VALUE 24.
 01 M-B5                   BINARY-LONG VALUE 5.
 01 M-B3                   BINARY-LONG VALUE 3.
 01 M-B6                   BINARY-LONG VALUE 6.
 01 M-B7                   BINARY-LONG VALUE 7.
 01 M-B11                  BINARY-LONG VALUE 11.
 01 M-B15                  BINARY-LONG VALUE 15.
 01 M-B19                  BINARY-LONG VALUE 19.
 01 M-BOUND                BINARY-LONG.
 01 M-DR                   BINARY-LONG.
 01 M-FA                   FLOAT-LONG.
 01 M-FB                   FLOAT-LONG.
 01 M-FR                   FLOAT-LONG.
 01 M-FR2                  FLOAT-LONG.
 01 M-FT                   FLOAT-LONG.
 01 M-FU                   FLOAT-LONG.
 01 M-FHU                  FLOAT-LONG.
 01 M-FNF                  FLOAT-LONG.
 01 M-TWO24                FLOAT-LONG VALUE 16777216.
 01 M-TWO53                FLOAT-LONG VALUE 9007199254740992.
 01 M-TWO                  FLOAT-LONG VALUE 2.0.
 01 M-HALF                 FLOAT-LONG VALUE 0.5.
 01 M-ONE                  FLOAT-LONG VALUE 1.0.
 01 M-PI                   FLOAT-LONG VALUE 3.141592653589793.
 01 M-HALFPI               FLOAT-LONG VALUE 1.5707963267948966.
 01 M-F04                  FLOAT-LONG.
 01 M-F02                  FLOAT-LONG.
 01 M-F08                  FLOAT-LONG.
 01 M-F10                  FLOAT-LONG VALUE 10.0.
 01 M-F35                  FLOAT-LONG VALUE 3.5.
 01 M-F06                  FLOAT-LONG VALUE 0.6.
 01 M-LIT04                FLOAT-LONG VALUE 0.4.
 01 M-LIT02                FLOAT-LONG VALUE 0.2.
 01 M-LIT08                FLOAT-LONG VALUE 0.8.
 01 M-Y                    BINARY-LONG.
 01 M-YY                   BINARY-LONG.
 01 M-Y2                   BINARY-LONG.
 01 M-R                    BINARY-LONG.
 01 M-I32                  BINARY-LONG.
 01 M-SG                   BINARY-LONG.
 01 M-S1                   FLOAT-LONG.
 01 M-S2                   FLOAT-LONG.
 01 M-GX                   BINARY-LONG.
 01 M-GY                   BINARY-LONG.
 01 M-GZ                   BINARY-LONG.
 01 M-NW                   BINARY-LONG.
 01 M-SNW                  BINARY-LONG.
 01 M-CNW                  BINARY-LONG.
 01 M-PH                   BINARY-LONG.
 01 M-PX                   BINARY-LONG.
 01 M-PY                   BINARY-LONG.
 01 M-PZ                   BINARY-LONG.
 01 M-PR                   BINARY-LONG.
 01 M-PW                   BINARY-LONG.
 01 M-EC                   BINARY-LONG.
 01 M-EA                   BINARY-LONG.
 01 M-EB                   BINARY-LONG.
 01 M-EDX                  BINARY-LONG.
 01 M-EDZ                  BINARY-LONG.
 01 M-DIST                 FLOAT-LONG.
 01 M-LIMIT                FLOAT-LONG.
 01 M-DNEG                 BINARY-LONG.
 01 M-COS                  FLOAT-LONG.
 01 M-SIN                  FLOAT-LONG.
 01 M-ANGLE                FLOAT-LONG.
 01 M-STOP                 BINARY-LONG.
 01 M-REM                  BINARY-LONG.
 01 M-HGT                  BINARY-LONG.
 01 M-DIV                  BINARY-LONG.
 01 M-OKF                  BINARY-LONG.
 01 M-T                    BINARY-LONG.
 01 M-DBL                  FLOAT-LONG.
 01 M-ST                   BINARY-LONG.
 01 M-BL                   BINARY-LONG.
 01 M-PRESENT              BINARY-LONG.
 01 M-RAD                  BINARY-LONG.
 01 M-N                    BINARY-LONG.
 01 M-AIRB                 BINARY-LONG.
 01 M-NB                   BINARY-LONG.
 01 M-WY                   BINARY-LONG.
 01 M-SX                   BINARY-LONG.
 01 M-SZ                   BINARY-LONG.
 01 M-OFX                  BINARY-LONG.
 01 M-OFZ                  BINARY-LONG.
 01 M-CUTX                 BINARY-LONG.
 01 M-CUTZ                 BINARY-LONG.
 01 M-HE                   BINARY-LONG.
 01 M-WIDE                 BINARY-LONG.
 01 M-C                    BINARY-LONG.
 01 M-TOW                  BINARY-LONG.
 01 M-YOFF                 BINARY-LONG.
 01 M-QX                   BINARY-LONG.
 01 M-QY                   BINARY-LONG.
 01 M-QZ                   BINARY-LONG.
 01 M-MODEL-CUT            BINARY-LONG.
 01 M-DIRS.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
 01 M-DIR-TABLE REDEFINES M-DIRS.
    05 M-DIR4 OCCURS 4 TIMES.
       10 M-DDX            BINARY-LONG.
       10 M-DDZ            BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"
     MOVE "snow_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-SNOWB
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-SNOWB
     MOVE "ice" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-ICE
     MOVE "packed_ice" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-PACK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-PACK
     MOVE "blue_ice" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-BLUE
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-BLUE
     MOVE "snow" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-SNOW
     MOVE "water" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-WATER
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-WATER
     MOVE "minecraft:iceberg_packed" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT-PACKED
     CALL "FD-ENSURE-FT" USING WS-FT-PACKED
     MOVE "minecraft:iceberg_blue" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT-BLUE
     CALL "FD-ENSURE-FT" USING WS-FT-BLUE
     MOVE "35-5§9: the data feature compiles as an iceberg (24)" TO WS-CASE
     MOVE FT-TYPE(WS-FT-PACKED) TO WS-OBS
     MOVE 24 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 0.2 TO M-F02
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE M-LIT02 M-F02
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE M-LIT04 M-F04
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE M-LIT08 M-F08

     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 40
         COMPUTE WS-SEED = WS-SEEDNO * 7919
         MOVE WS-SEEDNO TO WS-SEEDTXT
         IF FUNCTION MOD(WS-SEEDNO, 2) = 0
             MOVE WS-FT-BLUE TO WS-CUR-FT
             MOVE WS-S-BLUE TO WS-S-ICEB
         ELSE
             MOVE WS-FT-PACKED TO WS-CUR-FT
             MOVE WS-S-PACK TO WS-S-ICEB
         END-IF
         PERFORM NEW-WORLD
         MOVE 24 TO WS-X
         MOVE 80 TO WS-Y
         MOVE 40 TO WS-Z
         PERFORM SAVE-WORLD
         PERFORM MODEL-RUN
         CALL "FR-PLACE-FT" USING XR-STATE WS-CUR-FT WS-X WS-Y WS-Z WS-RESULT
         PERFORM COMPARE-WORLD
         MOVE SPACES TO WS-CASE
         STRING "35-5§9: seed " WS-SEEDTXT " the cells equal the model" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-BAD TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
         MOVE SPACES TO WS-CASE
         STRING "35-5§9: seed " WS-SEEDTXT " the result and the random state equal the model's" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1000 TO WS-DRAW
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-OBS
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-DRAW WS-EXP
         COMPUTE WS-OBS = WS-RESULT * 1000 + WS-OBS
         COMPUTE WS-EXP = 1000 + WS-EXP
         PERFORM ASSERT-N
     END-PERFORM
     MOVE "35-5§9: an elliptical berg was placed" TO WS-CASE
     IF WS-N-ELL > 0
         MOVE 1 TO WS-OBS
     ELSE
         MOVE 0 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-5§9: a round berg was placed" TO WS-CASE
     IF WS-N-ROUND > 0
         MOVE 1 TO WS-OBS
     ELSE
         MOVE 0 TO WS-OBS
     END-IF
     PERFORM ASSERT-N
     MOVE "35-5§9: a berg with snow on top was placed" TO WS-CASE
     IF WS-N-SNOW > 0
         MOVE 1 TO WS-OBS
     ELSE
         MOVE 0 TO WS-OBS
     END-IF
     PERFORM ASSERT-N
     MOVE "35-5§9: a berg with a cut-out was placed" TO WS-CASE
     IF WS-N-CUT > 0
         MOVE 1 TO WS-OBS
     ELSE
         MOVE 0 TO WS-OBS
     END-IF
     PERFORM ASSERT-N
     MOVE "35-5§9: a tall round berg was placed" TO WS-CASE
     IF WS-N-TALL > 0
         MOVE 1 TO WS-OBS
     ELSE
         MOVE 0 TO WS-OBS
     END-IF
     PERFORM ASSERT-N
     MOVE "35-5§9: the bergs placed cells" TO WS-CASE
     IF WS-N-CELLS > 1000
         MOVE 1 TO WS-OBS
     ELSE
         MOVE 0 TO WS-OBS
     END-IF
     PERFORM ASSERT-N

     MOVE "minecraft:iceberg_bad" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-5§9: an unknown state makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE FD-WA-COUNT TO WS-COUNT
     MOVE FD-MAX-WA TO FD-WA-COUNT
     MOVE "minecraft:iceberg_full" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE WS-COUNT TO FD-WA-COUNT
     MOVE "35-5§9: a full feature table makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 1 TO FI-GATE
     MOVE "minecraft:iceberg_blue" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-5§9: the gate admits iceberg_blue" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN
     .
 SAVE-WORLD.
     PERFORM VARYING WS-QZ FROM 32 BY 1 UNTIL WS-QZ > 47
         PERFORM VARYING WS-QX FROM 16 BY 1 UNTIL WS-QX > 31
             PERFORM VARYING WS-QY FROM 10 BY 1 UNTIL WS-QY > 120
                 COMPUTE WS-MIDX = (WS-QY - 10) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
                 CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                 MOVE WS-STATE TO WS-OS(WS-MIDX)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 COMPARE-WORLD.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-QZ FROM 32 BY 1 UNTIL WS-QZ > 47
         PERFORM VARYING WS-QX FROM 16 BY 1 UNTIL WS-QX > 31
             PERFORM VARYING WS-QY FROM 10 BY 1 UNTIL WS-QY > 120
                 COMPUTE WS-MIDX = (WS-QY - 10) * 256 + (WS-QZ - 32) * 16 + (WS-QX - 16) + 1
                 CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                 IF WS-STATE NOT = WS-OS(WS-MIDX)
                     ADD 1 TO WS-BAD
                 END-IF
                 IF WS-STATE NOT = 0 AND WS-STATE NOT = WS-S-WATER
                     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                     IF WS-BLOCK NOT = 0 AND WS-QY > 62
                         ADD 1 TO WS-N-CELLS
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> NEW-WORLD: chunk (1, 2): stone to y 40, water 41 to 62, air above; both random sources seeded
 NEW-WORLD.
     SET ADDRESS OF WS-AREA TO WS-PTR
     MOVE LOW-VALUES TO WS-AREA
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE 10 TO WS-Y0
     MOVE 40 TO WS-Y1
     MOVE "stone" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 41 TO WS-Y0
     MOVE 62 TO WS-Y1
     MOVE "water" TO WS-KEY
     PERFORM FILL-BOX
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     .
*> ---- the model: shadow cell access (M-QX, M-QY, M-QZ; M-ST in / out; outside the chunk column or the box reads air and is not written)
 M-GET.
     MOVE 0 TO M-ST
     IF M-QX >= 16 AND M-QX <= 31 AND M-QZ >= 32 AND M-QZ <= 47 AND M-QY >= 10 AND M-QY <= 120
         COMPUTE WS-MIDX = (M-QY - 10) * 256 + (M-QZ - 32) * 16 + (M-QX - 16) + 1
         MOVE WS-OS(WS-MIDX) TO M-ST
     END-IF
     CALL "FL-BLOCK-OF" USING M-ST M-BL
     .
 M-PUT.
     IF M-QX >= 16 AND M-QX <= 31 AND M-QZ >= 32 AND M-QZ <= 47 AND M-QY >= 10 AND M-QY <= 120
         COMPUTE WS-MIDX = (M-QY - 10) * 256 + (M-QZ - 32) * 16 + (M-QX - 16) + 1
         MOVE M-ST TO WS-OS(WS-MIDX)
     END-IF
     .
*> IEEE helpers: M-FR = M-FA op M-FB (then M-RND32 for a binary32 step)
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
*> M-SIGN: M-SG = the sign of M-FA - M-FB (0 for a NaN)
 M-SIGN.
     CALL STATIC "cc_f64_sub" USING BY REFERENCE M-FA M-FB M-S1
     CALL STATIC "cc_f64_signum" USING BY REFERENCE M-S1 M-S2
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE M-S2 M-SG
     .
*> M-CEILHALF: M-R = ceil(M-FR / 2)
 M-CEILHALF.
     MOVE M-FR TO M-FA
     MOVE M-HALF TO M-FB
     PERFORM M-MUL
     CALL STATIC "cc_f64_ceil" USING BY REFERENCE M-FR M-FR2
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE M-FR2 M-R
     .
*> M-DOUBLE-K: M-K = the 53 bit draw (nextDouble() * 2^53)
 M-DOUBLE-K.
     CALL "WGR-NEXT" USING XR2-STATE M-BITS26 M-HI
     CALL "WGR-NEXT" USING XR2-STATE M-BITS27 M-LO
     COMPUTE M-K = M-HI * 134217728 + M-LO
     .
*> M-DOUBLE-GT: M-GT 1 when the draw is above the threshold integer M-TH
 M-DOUBLE-GT.
     PERFORM M-DOUBLE-K
     MOVE 0 TO M-GT
     IF M-K > M-TH
         MOVE 1 TO M-GT
     END-IF
     .
*> M-FLOAT: M-FNF = nextFloat()
 M-FLOAT.
     CALL "WGR-NEXT" USING XR2-STATE M-BITS24 M-HI
     MOVE M-HI TO M-FA
     MOVE M-TWO24 TO M-FB
     PERFORM M-DIVF
     MOVE M-FR TO M-FNF
     .
 M-ELLR.
     MOVE 0 TO M-YY
     COMPUTE M-YY = M-Y * M-Y
     MOVE M-YY TO M-FA
     MOVE M-H TO M-FB
     PERFORM M-DIVF
     PERFORM M-RND32
     MOVE M-ONE TO M-FA
     MOVE M-FR TO M-FB
     PERFORM M-SUB
     PERFORM M-RND32
     MOVE M-FR TO M-FA
     MOVE M-E TO M-FB
     PERFORM M-MUL
     PERFORM M-RND32
     PERFORM M-CEILHALF
     .
 M-ROUNDR.
     PERFORM M-FLOAT
     MOVE M-F35 TO M-FA
     MOVE M-FNF TO M-FB
     PERFORM M-SUB
     PERFORM M-RND32
     MOVE M-FR TO M-FU
     MOVE M-H TO M-FA
     MOVE M-FU TO M-FB
     PERFORM M-MUL
     PERFORM M-RND32
     MOVE M-FR TO M-FHU
     COMPUTE M-YY = M-Y * M-Y
     MOVE M-YY TO M-FA
     MOVE M-FHU TO M-FB
     PERFORM M-DIVF
     PERFORM M-RND32
     MOVE M-ONE TO M-FA
     MOVE M-FR TO M-FB
     PERFORM M-SUB
     PERFORM M-RND32
     MOVE M-FR TO M-FA
     MOVE M-E TO M-FB
     PERFORM M-MUL
     PERFORM M-RND32
     MOVE M-FR TO M-FT
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B5 M-DR
     COMPUTE M-T = 15 + M-DR
     IF M-H > M-T
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B6 M-DR
         COMPUTE M-T = 3 + M-DR
         MOVE M-Y TO M-Y2
         IF M-Y < M-T
             DIVIDE M-Y BY 2 GIVING M-Y2
         END-IF
         MOVE M-FHU TO M-FA
         MOVE M-F04 TO M-FB
         PERFORM M-MUL
         PERFORM M-RND32
         MOVE M-FR TO M-FB
         MOVE M-Y2 TO M-FA
         PERFORM M-DIVF
         PERFORM M-RND32
         MOVE M-ONE TO M-FA
         MOVE M-FR TO M-FB
         PERFORM M-SUB
         PERFORM M-RND32
         MOVE M-FR TO M-FA
         MOVE M-E TO M-FB
         PERFORM M-MUL
         PERFORM M-RND32
         MOVE M-FR TO M-FT
     END-IF
     MOVE M-FT TO M-FR
     PERFORM M-CEILHALF
     .
*> M-STEEPR: y M-Y, height M-HGT
 M-STEEPR.
     PERFORM M-FLOAT
     MOVE M-FNF TO M-FA
     MOVE M-TWO TO M-FB
     PERFORM M-DIVF
     MOVE M-ONE TO M-FA
     MOVE M-FR TO M-FB
     PERFORM M-ADD
     PERFORM M-RND32
     MOVE M-FR TO M-FU
     MOVE M-HGT TO M-FA
     MOVE M-FU TO M-FB
     PERFORM M-MUL
     PERFORM M-RND32
     MOVE M-FR TO M-FHU
     MOVE M-Y TO M-FA
     MOVE M-FHU TO M-FB
     PERFORM M-DIVF
     PERFORM M-RND32
     MOVE M-ONE TO M-FA
     MOVE M-FR TO M-FB
     PERFORM M-SUB
     PERFORM M-RND32
     MOVE M-FR TO M-FA
     MOVE M-E TO M-FB
     PERFORM M-MUL
     PERFORM M-RND32
     PERFORM M-CEILHALF
     .
*> M-ELLIPSE: M-DNEG 1 when ellipseDist(M-EDX, M-EDZ, a = M-EA, b = M-EB, angle M-ANGLE) < 0 and M-DIST its value (IEEE: a zero axis divides to infinity or NaN)
 M-ELLIPSE.
     CALL STATIC "cc_f64_cos" USING BY REFERENCE M-ANGLE M-COS
     CALL STATIC "cc_f64_sin" USING BY REFERENCE M-ANGLE M-SIN
*>   p = (dx cos - dz sin) / a
     MOVE M-EDX TO M-FA
     MOVE M-COS TO M-FB
     PERFORM M-MUL
     MOVE M-FR TO M-FT
     MOVE M-EDZ TO M-FA
     MOVE M-SIN TO M-FB
     PERFORM M-MUL
     MOVE M-FR TO M-FB
     MOVE M-FT TO M-FA
     PERFORM M-SUB
     MOVE M-FR TO M-FA
     MOVE M-EA TO M-FB
     PERFORM M-DIVF
     MOVE M-FR TO M-FA
     MOVE M-FR TO M-FB
     PERFORM M-MUL
     MOVE M-FR TO M-FU
*>   q = (dx sin + dz cos) / b
     MOVE M-EDX TO M-FA
     MOVE M-SIN TO M-FB
     PERFORM M-MUL
     MOVE M-FR TO M-FT
     MOVE M-EDZ TO M-FA
     MOVE M-COS TO M-FB
     PERFORM M-MUL
     MOVE M-FR TO M-FB
     MOVE M-FT TO M-FA
     PERFORM M-ADD
     MOVE M-FR TO M-FA
     MOVE M-EB TO M-FB
     PERFORM M-DIVF
     MOVE M-FR TO M-FA
     MOVE M-FR TO M-FB
     PERFORM M-MUL
     MOVE M-FU TO M-FA
     MOVE M-FR TO M-FB
     PERFORM M-ADD
     MOVE M-FR TO M-FA
     MOVE M-ONE TO M-FB
     PERFORM M-SUB
     MOVE M-FR TO M-DIST
     MOVE M-DIST TO M-FA
     MOVE 0 TO M-FB
     PERFORM M-SIGN
     MOVE 0 TO M-DNEG
     IF M-SG < 0
         MOVE 1 TO M-DNEG
     END-IF
     .
*> M-PLACE: placeBlock(M-PH, M-PX, M-PY, M-PZ, radius M-PR, width M-PW)
 M-PLACE.
     IF M-ELL = 1
         MOVE M-PX TO M-EDX
         MOVE M-PZ TO M-EDZ
         MOVE M-PW TO M-EA
         MOVE M-B TO M-EC
         IF M-PY > 0 AND M-PH - M-PY <= 3
             COMPUTE M-EC = M-B - (4 - (M-PH - M-PY))
         END-IF
         MOVE M-EC TO M-EB
         MOVE M-ANG TO M-ANGLE
         PERFORM M-ELLIPSE
     ELSE
         PERFORM M-FLOAT
         MOVE M-FNF TO M-FR
         MOVE M-FNF TO M-FA
         MOVE M-F02 TO M-FB
         CALL STATIC "cc_f64_clamp_f32" USING BY REFERENCE M-FA M-F02 M-F08 M-FR
         MOVE M-F10 TO M-FA
         MOVE M-FR TO M-FB
         PERFORM M-MUL
         PERFORM M-RND32
         MOVE M-FR TO M-FA
         MOVE M-PR TO M-FB
         PERFORM M-DIVF
         PERFORM M-RND32
         MOVE M-FR TO M-FT
         COMPUTE M-YY = M-PX * M-PX + M-PZ * M-PZ - M-PR * M-PR
         MOVE M-YY TO M-FB
         MOVE M-FT TO M-FA
         PERFORM M-ADD
         MOVE M-FR TO M-DIST
         MOVE M-DIST TO M-FA
         MOVE 0 TO M-FB
         PERFORM M-SIGN
         MOVE 0 TO M-DNEG
         IF M-SG < 0
             MOVE 1 TO M-DNEG
         END-IF
     END-IF
     IF M-DNEG = 1
         IF M-ELL = 1
             MOVE -0.5 TO M-LIMIT
         ELSE
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B3 M-DR
             COMPUTE M-YY = -6 - M-DR
             MOVE M-YY TO M-LIMIT
         END-IF
         MOVE M-DIST TO M-FA
         MOVE M-LIMIT TO M-FB
         PERFORM M-SIGN
         MOVE 0 TO M-STOP
         IF M-SG > 0
             MOVE 8106479329266893 TO M-TH
             PERFORM M-DOUBLE-GT
             MOVE M-GT TO M-STOP
         END-IF
         IF M-STOP = 0
             COMPUTE M-REM = M-PH - M-PY
             MOVE M-PH TO M-HGT
             COMPUTE M-QX = M-OX + M-PX
             COMPUTE M-QY = M-OY + M-PY
             COMPUTE M-QZ = M-OZ + M-PZ
             PERFORM M-SETICE
         END-IF
     END-IF
     .
 M-SETICE.
     PERFORM M-GET
     IF M-ST = 0 OR M-BL = WS-B-SNOWB OR M-BL = WS-B-ICE OR M-BL = WS-B-WATER
         MOVE M-ST TO M-PRESENT
         MOVE 1 TO M-OKF
         MOVE 2 TO M-DIV
         IF M-ELL = 1
             MOVE 450359962737049 TO M-TH
             PERFORM M-DOUBLE-GT
             MOVE M-GT TO M-OKF
             MOVE 3 TO M-DIV
         END-IF
         MOVE 0 TO M-STOP
         IF M-SNOW = 1 AND M-BL NOT = WS-B-WATER
             COMPUTE M-BOUND = M-HGT / M-DIV
             IF M-BOUND < 1
                 MOVE 1 TO M-BOUND
             END-IF
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-BOUND M-T
*>           (double) remaining <= t + height * 0.6
             MOVE M-HGT TO M-FA
             MOVE M-F06 TO M-FB
             PERFORM M-MUL
             MOVE M-T TO M-FA
             MOVE M-FR TO M-FB
             PERFORM M-ADD
             MOVE M-REM TO M-FA
             MOVE M-FR TO M-FB
             PERFORM M-SIGN
             IF M-SG <= 0 AND M-OKF = 1
                 MOVE 1 TO M-STOP
             END-IF
         END-IF
         COMPUTE M-QX = M-OX + M-PX
         COMPUTE M-QY = M-OY + M-PY
         COMPUTE M-QZ = M-OZ + M-PZ
         IF M-STOP = 1
             MOVE WS-S-SNOWB TO M-ST
         ELSE
             MOVE WS-S-ICEB TO M-ST
         END-IF
         PERFORM M-PUT
     END-IF
     .
*> M-ICEB: M-NB 1 when the shadow cell (M-QX, M-QY, M-QZ) is packed_ice, snow_block or blue_ice
 M-ICEB.
     PERFORM M-GET
     MOVE 0 TO M-NB
     IF M-BL = WS-B-PACK OR M-BL = WS-B-SNOWB OR M-BL = WS-B-BLUE
         MOVE 1 TO M-NB
     END-IF
     .
 M-PUTAIR.
     MOVE 0 TO M-ST
     PERFORM M-PUT
     .
 M-SMOOTH.
     IF M-ELL = 1
         MOVE M-A TO M-RAD
     ELSE
         DIVIDE M-E BY 2 GIVING M-RAD
     END-IF
     COMPUTE M-SNW = 0 - M-RAD
     PERFORM VARYING M-GX FROM M-SNW BY 1 UNTIL M-GX > M-RAD
         PERFORM VARYING M-GZ FROM M-SNW BY 1 UNTIL M-GZ > M-RAD
             PERFORM VARYING M-GY FROM 0 BY 1 UNTIL M-GY > M-H
                 COMPUTE M-QX = M-OX + M-GX
                 COMPUTE M-QY = M-OY + M-GY
                 COMPUTE M-QZ = M-OZ + M-GZ
                 PERFORM M-ICEB
                 IF M-NB = 1 OR M-BL = WS-B-SNOW
                     MOVE M-NB TO M-AIRB
                     COMPUTE M-QY = M-OY + M-GY - 1
                     PERFORM M-GET
                     IF M-ST = 0
                         COMPUTE M-QY = M-OY + M-GY
                         PERFORM M-PUTAIR
                         COMPUTE M-QY = M-OY + M-GY + 1
                         PERFORM M-PUTAIR
                     ELSE
                         IF M-AIRB = 1
                             MOVE 0 TO M-N
                             PERFORM VARYING M-C FROM 1 BY 1 UNTIL M-C > 4
                                 COMPUTE M-QX = M-OX + M-GX + M-DDX(M-C)
                                 COMPUTE M-QY = M-OY + M-GY
                                 COMPUTE M-QZ = M-OZ + M-GZ + M-DDZ(M-C)
                                 PERFORM M-ICEB
                                 IF M-NB = 0
                                     ADD 1 TO M-N
                                 END-IF
                             END-PERFORM
                             IF M-N >= 3
                                 COMPUTE M-QX = M-OX + M-GX
                                 COMPUTE M-QY = M-OY + M-GY
                                 COMPUTE M-QZ = M-OZ + M-GZ
                                 PERFORM M-PUTAIR
                             END-IF
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 M-CARVE.
     COMPUTE M-WIDE = M-R + 1
     DIVIDE M-A BY 3 GIVING M-T
     ADD M-T TO M-WIDE
     COMPUTE M-C = M-R - 3
     IF M-C > 3
         MOVE 3 TO M-C
     END-IF
     DIVIDE M-B BY 2 GIVING M-T
     COMPUTE M-C = M-C + M-T - 1
     COMPUTE M-CNW = 0 - M-WIDE
     PERFORM VARYING M-GX FROM M-CNW BY 1 UNTIL M-GX >= M-WIDE
         PERFORM VARYING M-GZ FROM M-CNW BY 1 UNTIL M-GZ >= M-WIDE
             COMPUTE M-EDX = M-GX - M-CUTX
             COMPUTE M-EDZ = M-GZ - M-CUTZ
             MOVE M-WIDE TO M-EA
             MOVE M-C TO M-EB
             MOVE M-ANG2 TO M-ANGLE
             PERFORM M-ELLIPSE
             IF M-DNEG = 1
                 COMPUTE M-QX = M-OX + M-GX
                 COMPUTE M-QY = M-OY + M-YOFF
                 COMPUTE M-QZ = M-OZ + M-GZ
                 PERFORM M-ICEB
                 IF M-NB = 1
                     IF M-TOW = 1
                         MOVE WS-S-WATER TO M-ST
                         PERFORM M-PUT
                     ELSE
                         PERFORM M-PUTAIR
                         ADD 1 TO M-QY
                         PERFORM M-GET
                         IF M-BL = WS-B-SNOW
                             PERFORM M-PUTAIR
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     .
 M-CUT.
     CALL "F351-NEXT-BOOLEAN" USING XR2-STATE M-DR
     MOVE 1 TO M-SX
     IF M-DR = 1
         MOVE -1 TO M-SX
     END-IF
     CALL "F351-NEXT-BOOLEAN" USING XR2-STATE M-DR
     MOVE 1 TO M-SZ
     IF M-DR = 1
         MOVE -1 TO M-SZ
     END-IF
     DIVIDE M-E BY 2 GIVING M-HE
     COMPUTE M-BOUND = FUNCTION MAX(M-HE - 2, 1)
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-BOUND M-OFX
     CALL "F351-NEXT-BOOLEAN" USING XR2-STATE M-DR
     IF M-DR = 1
         COMPUTE M-BOUND = FUNCTION MAX(M-E - M-HE - 1, 1)
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-BOUND M-DR
         COMPUTE M-OFX = M-HE + 1 - M-DR
     END-IF
     COMPUTE M-BOUND = FUNCTION MAX(M-HE - 2, 1)
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-BOUND M-OFZ
     CALL "F351-NEXT-BOOLEAN" USING XR2-STATE M-DR
     IF M-DR = 1
         COMPUTE M-BOUND = FUNCTION MAX(M-E - M-HE - 1, 1)
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-BOUND M-DR
         COMPUTE M-OFZ = M-HE + 1 - M-DR
     END-IF
     IF M-ELL = 1
         COMPUTE M-BOUND = FUNCTION MAX(M-A - 5, 1)
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-BOUND M-OFX
         MOVE M-OFX TO M-OFZ
         MOVE M-ANG TO M-FA
         MOVE M-HALFPI TO M-FB
         PERFORM M-ADD
         MOVE M-FR TO M-ANG2
     ELSE
         PERFORM M-DOUBLE-K
         MOVE M-K TO M-FA
         MOVE M-TWO53 TO M-FB
         PERFORM M-DIVF
         MOVE M-FR TO M-FA
         MOVE M-TWO TO M-FB
         PERFORM M-MUL
         MOVE M-FR TO M-FA
         MOVE M-PI TO M-FB
         PERFORM M-MUL
         MOVE M-FR TO M-ANG2
     END-IF
     COMPUTE M-CUTX = M-SX * M-OFX
     COMPUTE M-CUTZ = M-SZ * M-OFZ
     MOVE 0 TO M-TOW
     PERFORM VARYING M-YOFF FROM 0 BY 1 UNTIL M-YOFF > M-H - 4
         MOVE M-YOFF TO M-Y
         PERFORM M-ROUNDR
         PERFORM M-CARVE
     END-PERFORM
     MOVE 1 TO M-TOW
     MOVE -1 TO M-YOFF
     MOVE 0 TO M-STOP
     PERFORM UNTIL M-STOP = 1
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B5 M-DR
         COMPUTE M-T = 0 - M-H + M-DR
         IF M-YOFF > M-T
             COMPUTE M-Y = 0 - M-YOFF
             MOVE M-H TO M-HGT
             PERFORM M-STEEPR
             PERFORM M-CARVE
             SUBTRACT 1 FROM M-YOFF
         ELSE
             MOVE 1 TO M-STOP
         END-IF
     END-PERFORM
     .
 MODEL-RUN.
     MOVE WS-X TO M-OX
     MOVE 63 TO M-OY
     MOVE WS-Z TO M-OZ
     MOVE 6305039478318694 TO M-TH
     PERFORM M-DOUBLE-GT
     MOVE M-GT TO M-SNOW
     PERFORM M-DOUBLE-K
     MOVE M-K TO M-FA
     MOVE M-TWO53 TO M-FB
     PERFORM M-DIVF
     MOVE M-FR TO M-FA
     MOVE M-TWO TO M-FB
     PERFORM M-MUL
     MOVE M-FR TO M-FA
     MOVE M-PI TO M-FB
     PERFORM M-MUL
     MOVE M-FR TO M-ANG
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B5 M-DR
     COMPUTE M-A = 11 - M-DR
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B3 M-DR
     COMPUTE M-B = 3 + M-DR
     MOVE 6305039478318694 TO M-TH
     PERFORM M-DOUBLE-GT
     MOVE M-GT TO M-ELL
     IF M-ELL = 1
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B6 M-DR
         COMPUTE M-H = M-DR + 6
     ELSE
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B15 M-DR
         COMPUTE M-H = M-DR + 3
         MOVE 8106479329266893 TO M-TH
         PERFORM M-DOUBLE-GT
         IF M-GT = 1
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B19 M-DR
             COMPUTE M-H = M-H + M-DR + 7
             ADD 1 TO WS-N-TALL
         END-IF
     END-IF
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B11 M-DR
     COMPUTE M-D = FUNCTION MIN(M-H + M-DR, 18)
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B7 M-DR
     COMPUTE M-E = M-H + M-DR
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE M-B5 M-DR
     COMPUTE M-E = FUNCTION MIN(M-E - M-DR, 11)
     MOVE 11 TO M-W
     IF M-ELL = 1
         MOVE M-A TO M-W
         ADD 1 TO WS-N-ELL
     ELSE
         ADD 1 TO WS-N-ROUND
     END-IF
     IF M-SNOW = 1
         ADD 1 TO WS-N-SNOW
     END-IF
     COMPUTE M-NW = 0 - M-W
*>   above water
     PERFORM VARYING M-GX FROM M-NW BY 1 UNTIL M-GX >= M-W
         PERFORM VARYING M-GZ FROM M-NW BY 1 UNTIL M-GZ >= M-W
             PERFORM VARYING M-GY FROM 0 BY 1 UNTIL M-GY >= M-H
                 MOVE M-GY TO M-Y
                 IF M-ELL = 1
                     PERFORM M-ELLR
                 ELSE
                     PERFORM M-ROUNDR
                 END-IF
                 IF M-ELL = 1 OR M-GX < M-R
                     MOVE M-H TO M-PH
                     MOVE M-GX TO M-PX
                     MOVE M-GY TO M-PY
                     MOVE M-GZ TO M-PZ
                     MOVE M-R TO M-PR
                     MOVE M-W TO M-PW
                     PERFORM M-PLACE
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     PERFORM M-SMOOTH
*>   below water
     PERFORM VARYING M-GX FROM M-NW BY 1 UNTIL M-GX >= M-W
         PERFORM VARYING M-GZ FROM M-NW BY 1 UNTIL M-GZ >= M-W
             MOVE -1 TO M-GY
             PERFORM UNTIL M-GY <= 0 - M-D
                 MOVE M-W TO M-WY
                 IF M-ELL = 1
                     COMPUTE M-YY = M-GY * M-GY
                     MOVE M-YY TO M-FA
                     COMPUTE M-YY = M-D * 8
                     MOVE M-YY TO M-FB
                     PERFORM M-DIVF
                     PERFORM M-RND32
                     MOVE M-ONE TO M-FA
                     MOVE M-FR TO M-FB
                     PERFORM M-SUB
                     PERFORM M-RND32
                     MOVE M-W TO M-FA
                     MOVE M-FR TO M-FB
                     PERFORM M-MUL
                     PERFORM M-RND32
                     CALL STATIC "cc_f64_ceil" USING BY REFERENCE M-FR M-FR2
                     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE M-FR2 M-WY
                 END-IF
                 COMPUTE M-Y = 0 - M-GY
                 MOVE M-D TO M-HGT
                 PERFORM M-STEEPR
                 IF M-GX < M-R
                     MOVE M-D TO M-PH
                     MOVE M-GX TO M-PX
                     MOVE M-GY TO M-PY
                     MOVE M-GZ TO M-PZ
                     MOVE M-R TO M-PR
                     MOVE M-WY TO M-PW
                     PERFORM M-PLACE
                 END-IF
                 SUBTRACT 1 FROM M-GY
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF M-ELL = 1
         MOVE 900719925474099 TO M-TH
     ELSE
         MOVE 6305039478318694 TO M-TH
     END-IF
     PERFORM M-DOUBLE-GT
     IF M-GT = 1
         ADD 1 TO WS-N-CUT
         PERFORM M-CUT
     END-IF
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-5-9.
 COPY CORETEST.
