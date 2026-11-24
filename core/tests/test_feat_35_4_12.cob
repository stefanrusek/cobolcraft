*> Implementation test of the huge fungus (docs/protocol/35-worldgen-features-4-decorators-and-vegetation.md section 11.5 and the check 8 of section 12; core/src/feat-fungus.cob): the data features
*> (crimson_fungus-like, warped, a non-wart hat, planted true and false) compile as type 22; a missing member, an unknown block or a full table make them unsupported. Placement is checked cell by cell
*> against an independent model with its own random source: the base block rule, H = 4 + nextInt(10) doubled on nextInt(12) = 0, the generation depth rule (not planted; the level height is the depth),
*> thick = nextFloat < 0.06, the stem (r = 1 when thick, corner cells draw nextFloat < 0.1), the hat layers (hatHeight, r per layer, r = 3 and thick increments), the low ring drop block, inner, corner and
*> edge hat blocks with the decor, hat and vine draws, the weeping vines column, planted destroying, and canBeReplaced / replaceable_blocks. The model also records that thick stems, vines, decor blocks
*> and depth failures were all exercised.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-4-12.
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
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/fungus".
 01 WS-PTR                 USAGE POINTER.
 01 WS-A                   PIC X(304640) BASED.
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
 01 WS-RESULT              BINARY-LONG.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-LMIN                BINARY-LONG.
 01 WS-LHT                 BINARY-LONG.
 01 WS-LTOP                BINARY-LONG.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
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
 01 WS-SEEDTXT             PIC 999.
 01 WS-OYTXT               PIC -999.
 01 WS-MODETXT             PIC 9.
 01 WS-LABEL               PIC X(20).
 01 WS-B-AIR               BINARY-LONG.
 01 WS-B-GRASS             BINARY-LONG.
 01 WS-B-SAPLING           BINARY-LONG.
 01 WS-B-BASE              BINARY-LONG.
 01 WS-S-STEM              BINARY-LONG.
 01 WS-S-HAT               BINARY-LONG.
 01 WS-S-DECOR             BINARY-LONG.
 01 WS-S-HEAD1             BINARY-LONG.
 01 WS-S-HEAD2             BINARY-LONG.
 01 WS-S-HEAD3             BINARY-LONG.
 01 WS-S-PLANT             BINARY-LONG.
 01 WS-B-HAT               BINARY-LONG.
 01 WS-WART                BINARY-LONG.
 01 WS-PLANTED             BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-OX                  BINARY-LONG VALUE 24.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG VALUE 40.
 01 WS-WY0                 BINARY-LONG.
 01 WS-COLTOP              BINARY-LONG.
 01 WS-BASEKEY             PIC X(40).
 01 WS-STEMKEY             PIC X(112).
 01 WS-ANY-THICK           BINARY-LONG VALUE 0.
 01 WS-ANY-VINE            BINARY-LONG VALUE 0.
 01 WS-ANY-DECOR           BINARY-LONG VALUE 0.
 01 WS-ANY-DEPTH           BINARY-LONG VALUE 0.
 01 WS-ANY-DESTROY         BINARY-LONG VALUE 0.
 01 WS-S0-TABLE.
    05 WS-S0               BINARY-LONG OCCURS 10240 TIMES.
 01 WS-EXPS-TABLE.
    05 WS-EXPS             BINARY-LONG OCCURS 10240 TIMES.
 01 WS-M-RES               BINARY-LONG.
 01 WS-M-H                 BINARY-LONG.
 01 WS-M-IDX               BINARY-LONG.
 01 WS-M-X                 BINARY-LONG.
 01 WS-M-Y                 BINARY-LONG.
 01 WS-M-Z                 BINARY-LONG.
 01 WS-M-ST                BINARY-LONG.
 01 WS-M-NEW               BINARY-LONG.
 01 WS-M-BLK               BINARY-LONG.
 01 WS-M-I                 BINARY-LONG.
 01 WS-M-THICK             BINARY-LONG.
 01 WS-M-R                 BINARY-LONG.
 01 WS-M-DX                BINARY-LONG.
 01 WS-M-DZ                BINARY-LONG.
 01 WS-M-DY                BINARY-LONG.
 01 WS-M-REPL              BINARY-LONG.
 01 WS-M-PRED              BINARY-LONG.
 01 WS-M-AIR               BINARY-LONG.
 01 WS-M-CORNER            BINARY-LONG.
 01 WS-M-HH                BINARY-LONG.
 01 WS-M-BOTTOM            BINARY-LONG.
 01 WS-M-Y2                BINARY-LONG.
 01 WS-M-BOUND             BINARY-LONG.
 01 WS-M-EX                BINARY-LONG.
 01 WS-M-EZ                BINARY-LONG.
 01 WS-M-INNER             BINARY-LONG.
 01 WS-M-LOW               BINARY-LONG.
 01 WS-M-B3                BINARY-LONG VALUE 3.
 01 WS-M-B10               BINARY-LONG VALUE 10.
 01 WS-M-B12               BINARY-LONG VALUE 12.
 01 WS-M-B5                BINARY-LONG VALUE 5.
 01 WS-M-B7                BINARY-LONG VALUE 7.
 01 WS-M-B11               BINARY-LONG VALUE 11.
 01 WS-M-F                 FLOAT-LONG.
 01 WS-M-LIT               FLOAT-LONG.
 01 WS-M-CD                FLOAT-LONG.
 01 WS-M-CH                FLOAT-LONG.
 01 WS-M-CV                FLOAT-LONG.
 01 WS-K-006               FLOAT-LONG.
 01 WS-K-01                FLOAT-LONG.
 01 WS-K-02                FLOAT-LONG.
 01 WS-K-001               FLOAT-LONG.
 01 WS-K-07                FLOAT-LONG.
 01 WS-K-0083              FLOAT-LONG.
 01 WS-K-00005             FLOAT-LONG.
 01 WS-K-098               FLOAT-LONG.
 01 WS-K-007               FLOAT-LONG.
 01 WS-K-015               FLOAT-LONG.
 01 WS-M-VX                BINARY-LONG.
 01 WS-M-VY                BINARY-LONG.
 01 WS-M-VL                BINARY-LONG.
 01 WS-M-STOP              BINARY-LONG.
 01 WS-M-CUR               BINARY-LONG.
 01 WS-M-LAYER             BINARY-LONG.
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
     MOVE "air" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-AIR
     MOVE "short_grass" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-GRASS
     MOVE 1 TO CB-REPLACEABLE(WS-WANT)
     MOVE "oak_sapling" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-SAPLING
     MOVE 0 TO CB-REPLACEABLE(WS-WANT)
     MOVE "shroomlight" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-DECOR
     MOVE SPACES TO WS-PAIRS
     MOVE "weeping_vines" TO WS-KEY
     MOVE "age=23" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-S-HEAD1
     MOVE "age=24" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-S-HEAD2
     MOVE "age=25" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-S-HEAD3
     MOVE "weeping_vines_plant" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-S-PLANT
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"0.06" WS-M-LIT
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-M-LIT WS-K-006
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"0.1" WS-M-LIT
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-M-LIT WS-K-01
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"0.2" WS-M-LIT
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-M-LIT WS-K-02
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"0.01" WS-M-LIT
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-M-LIT WS-K-001
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"0.7" WS-M-LIT
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-M-LIT WS-K-07
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"0.083" WS-M-LIT
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-M-LIT WS-K-0083
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"0.0005" WS-M-LIT
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-M-LIT WS-K-00005
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"0.98" WS-M-LIT
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-M-LIT WS-K-098
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"0.07" WS-M-LIT
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-M-LIT WS-K-007
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE Z"0.15" WS-K-015

*>   the data features compile
     MOVE "minecraft:fcrimson" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-4§11.5: the data feature huge_fungus compiles as type 22" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 22 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§11.5: planted defaults to false" TO WS-CASE
     MOVE WA-I(FT-A(WS-FT), 5) TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§11.5: a nether_wart_block hat is a wart hat" TO WS-CASE
     MOVE WA-I(FT-A(WS-FT), 6) TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:fnowart" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-4§11.5: another hat block is no wart hat" TO WS-CASE
     MOVE WA-I(FT-A(WS-FT), 6) TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:fplanted" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-4§11.5: planted true is read" TO WS-CASE
     MOVE WA-I(FT-A(WS-FT), 5) TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:fplanted_false" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-4§11.5: planted false is read" TO WS-CASE
     MOVE WA-I(FT-A(WS-FT), 5) TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     PERFORM UNSUPPORTED-CASES

*>   crimson: wart hat, over seven grounds
     MOVE 384 TO WS-LHT
     MOVE -64 TO WS-LMIN
     MOVE 64 TO WS-OY
     MOVE "minecraft:fcrimson" TO WS-FTKEY
     MOVE "crimson_nylium" TO WS-BASEKEY
     MOVE "crimson_stem" TO WS-NAME
     MOVE "nether_wart_block" TO WS-KEY
     MOVE "crimson" TO WS-LABEL
     PERFORM SET-STATES
     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 84
         COMPUTE WS-MODE = FUNCTION MOD(WS-SEEDNO, 7)
         PERFORM RUN-CASE
     END-PERFORM
     MOVE "minecraft:fwarped" TO WS-FTKEY
     MOVE "warped_nylium" TO WS-BASEKEY
     MOVE "warped_stem" TO WS-NAME
     MOVE "warped_wart_block" TO WS-KEY
     MOVE "warped" TO WS-LABEL
     PERFORM SET-STATES
     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 56
         COMPUTE WS-MODE = FUNCTION MOD(WS-SEEDNO, 7)
         PERFORM RUN-CASE
     END-PERFORM
     MOVE "minecraft:fnowart" TO WS-FTKEY
     MOVE "crimson_nylium" TO WS-BASEKEY
     MOVE "crimson_stem" TO WS-NAME
     MOVE "blackstone" TO WS-KEY
     MOVE "nowart" TO WS-LABEL
     PERFORM SET-STATES
     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 42
         COMPUTE WS-MODE = FUNCTION MOD(WS-SEEDNO, 7)
         PERFORM RUN-CASE
     END-PERFORM
     MOVE "minecraft:fplanted" TO WS-FTKEY
     MOVE "crimson_stem" TO WS-NAME
     MOVE "nether_wart_block" TO WS-KEY
     MOVE "planted" TO WS-LABEL
     PERFORM SET-STATES
     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 42
         COMPUTE WS-MODE = FUNCTION MOD(WS-SEEDNO, 7)
         PERFORM RUN-CASE
     END-PERFORM
*>   the generation depth: a Nether-sized level, the origin near the top
     MOVE 128 TO WS-LHT
     MOVE 0 TO WS-LMIN
     MOVE 118 TO WS-OY
     MOVE "minecraft:fcrimson" TO WS-FTKEY
     MOVE "crimson_nylium" TO WS-BASEKEY
     MOVE "crimson_stem" TO WS-NAME
     MOVE "nether_wart_block" TO WS-KEY
     MOVE "crimson" TO WS-LABEL
     PERFORM SET-STATES
     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 40
         MOVE 0 TO WS-MODE
         PERFORM RUN-CASE
     END-PERFORM
     MOVE "minecraft:fplanted" TO WS-FTKEY
     MOVE "crimson_stem" TO WS-NAME
     MOVE "nether_wart_block" TO WS-KEY
     MOVE "planted" TO WS-LABEL
     PERFORM SET-STATES
     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 10
         MOVE 0 TO WS-MODE
         PERFORM RUN-CASE
     END-PERFORM
     MOVE "35-4§11.5: some stem was thick (the draw below 0.06)" TO WS-CASE
     MOVE WS-ANY-THICK TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§11.5: some weeping vine head was placed" TO WS-CASE
     MOVE WS-ANY-VINE TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§11.5: some decor block was placed" TO WS-CASE
     MOVE WS-ANY-DECOR TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§11.5: some placement failed the generation depth" TO WS-CASE
     MOVE WS-ANY-DEPTH TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§11.5: some planted hat cell destroyed a replaceable block" TO WS-CASE
     MOVE WS-ANY-DESTROY TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 1 TO FI-GATE
     MOVE "minecraft:crimson_fungi" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-4§11.5: the gate admits the crimson_fungi placed feature" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:warped_fungi" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-4§11.5: the gate admits the warped_fungi placed feature" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN
     .
 UNSUPPORTED-CASES.
     MOVE "minecraft:fbad_base" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-4§11.5: a missing valid_base_block makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:fbad_stem" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-4§11.5: a missing stem_state makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:fbad_hat" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-4§11.5: a missing hat_state makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:fbad_decor" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-4§11.5: a missing decor_state makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:fbad_repl" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-4§11.5: a missing replaceable_blocks makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:fbad_block" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-4§11.5: a state of an unknown block makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE FD-WA-COUNT TO WS-COUNT
     MOVE FD-MAX-WA TO FD-WA-COUNT
     MOVE "minecraft:ffull" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE WS-COUNT TO FD-WA-COUNT
     MOVE "35-4§11.5: a full feature table makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     .
*> SET-STATES: the model's states: stem block WS-NAME, hat block WS-KEY (default states), the base block WS-BASEKEY, WS-WART
 SET-STATES.
     MOVE SPACES TO WS-PAIRS
     MOVE WS-NAME TO WS-STEMKEY
     CALL "BLOCKS-STATE-OF" USING WS-STEMKEY WS-PAIRS WS-S-STEM
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-S-HAT
     CALL "FL-BLOCK-OF" USING WS-S-HAT WS-B-HAT
     MOVE WS-BASEKEY TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-BASE
     MOVE 0 TO WS-WART
     MOVE "nether_wart_block" TO WS-NAME
     CALL "FD-BLOCK-INDEX" USING WS-NAME WS-WANT
     IF WS-WANT = WS-B-HAT
         MOVE 1 TO WS-WART
     END-IF
     .
 RUN-CASE.
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE WA-I(FT-A(WS-FT), 5) TO WS-PLANTED
     COMPUTE WS-LTOP = WS-LMIN + WS-LHT - 1
     COMPUTE WS-SEED = WS-SEEDNO * 7919 + WS-OY + 31
     MOVE WS-SEEDNO TO WS-SEEDTXT
     MOVE WS-OY TO WS-OYTXT
     MOVE WS-MODE TO WS-MODETXT
     PERFORM NEW-WORLD
     PERFORM SNAPSHOT
     MOVE WS-OX TO WS-X
     MOVE WS-OY TO WS-Y
     MOVE WS-OZ TO WS-Z
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     PERFORM MODEL-RUN
     PERFORM COMPARE-MODEL
     MOVE SPACES TO WS-CASE
     STRING "35-4§11.5: " FUNCTION TRIM(WS-LABEL) " y " WS-OYTXT " mode " WS-MODETXT " seed " WS-SEEDTXT " the level equals the model, cell by cell" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE SPACES TO WS-CASE
     STRING "35-4§11.5: " FUNCTION TRIM(WS-LABEL) " y " WS-OYTXT " mode " WS-MODETXT " seed " WS-SEEDTXT " the result and the random state equal the model's" DELIMITED BY SIZE INTO WS-CASE
     MOVE 1000 TO WS-DRAW
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-OBS
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-DRAW WS-EXP
     COMPUTE WS-OBS = WS-RESULT * 10000 + WS-OBS
     COMPUTE WS-EXP = WS-M-RES * 10000 + WS-EXP
     PERFORM ASSERT-N
     .
 NEW-WORLD.
     SET ADDRESS OF WS-A TO WS-PTR
     MOVE LOW-VALUES TO WS-A
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-LMIN WS-LHT WS-SEA
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     COMPUTE WS-Y0 = WS-OY - 4
     COMPUTE WS-Y1 = WS-OY - 2
     MOVE "stone" TO WS-KEY
     PERFORM FILL-BOX
     COMPUTE WS-Y0 = WS-OY - 1
     MOVE WS-Y0 TO WS-Y1
     IF WS-MODE = 5
         MOVE "stone" TO WS-KEY
     ELSE
         MOVE WS-BASEKEY TO WS-KEY
     END-IF
     PERFORM FILL-BOX
     COMPUTE WS-COLTOP = WS-OY + 30
     IF WS-COLTOP > WS-LTOP
         MOVE WS-LTOP TO WS-COLTOP
     END-IF
     EVALUATE WS-MODE
         WHEN 1
             COMPUTE WS-X = WS-OX + 1
             COMPUTE WS-Y = WS-OY + 1
             MOVE WS-OZ TO WS-Z
             MOVE "oak_sapling" TO WS-KEY
             PERFORM PUT-AT
         WHEN 2
             MOVE "short_grass" TO WS-KEY
             PERFORM PUT-COLUMN-FROM-BASE
         WHEN 3
             MOVE "stone" TO WS-KEY
             PERFORM PUT-COLUMN
         WHEN 4
             COMPUTE WS-X = WS-OX + 1
             COMPUTE WS-Y = WS-OY + 2
             COMPUTE WS-Z = WS-OZ + 1
             MOVE "stone" TO WS-KEY
             PERFORM PUT-AT
         WHEN 6
             COMPUTE WS-X = WS-OX + 1
             COMPUTE WS-Z = WS-OZ + 1
             MOVE "oak_sapling" TO WS-KEY
             PERFORM VARYING WS-M-Y FROM 1 BY 1 UNTIL WS-M-Y > 8
                 COMPUTE WS-Y = WS-OY + WS-M-Y
                 PERFORM PUT-AT
             END-PERFORM
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     .
*> PUT-COLUMN: WS-KEY at x = origin + 2, z = origin, y from origin + 1 to WS-COLTOP; PUT-COLUMN-FROM-BASE from y = origin
 PUT-COLUMN.
     COMPUTE WS-X = WS-OX + 2
     MOVE WS-OZ TO WS-Z
     PERFORM VARYING WS-M-Y FROM WS-OY BY 1 UNTIL WS-M-Y >= WS-COLTOP
         COMPUTE WS-Y = WS-M-Y + 1
         PERFORM PUT-AT
     END-PERFORM
     .
 PUT-COLUMN-FROM-BASE.
     COMPUTE WS-X = WS-OX + 2
     MOVE WS-OZ TO WS-Z
     PERFORM VARYING WS-M-Y FROM WS-OY BY 1 UNTIL WS-M-Y > WS-COLTOP
         MOVE WS-M-Y TO WS-Y
         PERFORM PUT-AT
     END-PERFORM
     .
 SNAPSHOT.
     COMPUTE WS-WY0 = WS-OY - 4
     IF WS-WY0 + 39 > WS-LTOP
         COMPUTE WS-WY0 = WS-LTOP - 39
     END-IF
     MOVE 0 TO WS-M-I
     PERFORM VARYING WS-Y FROM WS-WY0 BY 1 UNTIL WS-Y > WS-WY0 + 39
         PERFORM VARYING WS-Z FROM 32 BY 1 UNTIL WS-Z > 47
             PERFORM VARYING WS-X FROM 16 BY 1 UNTIL WS-X > 31
                 ADD 1 TO WS-M-I
                 CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-S0(WS-M-I)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 COMPARE-MODEL.
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-M-I
     PERFORM VARYING WS-Y FROM WS-WY0 BY 1 UNTIL WS-Y > WS-WY0 + 39
         PERFORM VARYING WS-Z FROM 32 BY 1 UNTIL WS-Z > 47
             PERFORM VARYING WS-X FROM 16 BY 1 UNTIL WS-X > 31
                 ADD 1 TO WS-M-I
                 CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                 IF WS-STATE NOT = WS-EXPS(WS-M-I)
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> M-GET: WS-M-ST = the model's state at (WS-M-X, WS-M-Y, WS-M-Z), void air outside the level; WS-M-BLK its block; WS-M-AIR 1 when air
 M-GET.
     IF WS-M-Y < WS-LMIN OR WS-M-Y > WS-LTOP
         MOVE FL-S-VOID-AIR TO WS-M-ST
     ELSE
         COMPUTE WS-M-IDX = (WS-M-Y - WS-WY0) * 256 + (WS-M-Z - 32) * 16 + (WS-M-X - 16) + 1
         MOVE WS-EXPS(WS-M-IDX) TO WS-M-ST
     END-IF
     CALL "FL-BLOCK-OF" USING WS-M-ST WS-M-BLK
     MOVE 0 TO WS-M-AIR
     IF WS-M-ST = FL-S-VOID-AIR OR WS-M-BLK = WS-B-AIR
         MOVE 1 TO WS-M-AIR
     END-IF
     .
*> M-SET: WS-M-NEW at the cell; nothing above or below the level
 M-SET.
     IF WS-M-Y >= WS-LMIN AND WS-M-Y <= WS-LTOP
         COMPUTE WS-M-IDX = (WS-M-Y - WS-WY0) * 256 + (WS-M-Z - 32) * 16 + (WS-M-X - 16) + 1
         MOVE WS-M-NEW TO WS-EXPS(WS-M-IDX)
     END-IF
     .
*> M-REPLACEABLE: WS-M-REPL for the cell: air or short grass; with WS-M-PRED = 1 also an oak sapling
 M-REPLACEABLE.
     PERFORM M-GET
     MOVE 0 TO WS-M-REPL
     IF WS-M-AIR = 1 OR WS-M-BLK = WS-B-GRASS
         MOVE 1 TO WS-M-REPL
     END-IF
     IF WS-M-PRED = 1 AND WS-M-BLK = WS-B-SAPLING
         MOVE 1 TO WS-M-REPL
     END-IF
     .
*> M-BELOW-AIR: WS-M-AIR for the block below the cell (WS-M-X, WS-M-Y, WS-M-Z); the cell is restored
 M-BELOW-AIR.
     SUBTRACT 1 FROM WS-M-Y
     PERFORM M-GET
     ADD 1 TO WS-M-Y
     .
 MODEL-RUN.
     PERFORM VARYING WS-M-I FROM 1 BY 1 UNTIL WS-M-I > 10240
         MOVE WS-S0(WS-M-I) TO WS-EXPS(WS-M-I)
     END-PERFORM
     MOVE 0 TO WS-M-RES
     MOVE WS-OX TO WS-M-X
     COMPUTE WS-M-Y = WS-OY - 1
     MOVE WS-OZ TO WS-M-Z
     PERFORM M-GET
     IF WS-M-BLK NOT = WS-B-BASE
         EXIT PARAGRAPH
     END-IF
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-M-B10 WS-DRAW
     COMPUTE WS-M-H = 4 + WS-DRAW
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-M-B12 WS-DRAW
     IF WS-DRAW = 0
         COMPUTE WS-M-H = WS-M-H * 2
     END-IF
     IF WS-PLANTED = 0 AND WS-OY + WS-M-H + 1 >= WS-LHT
         MOVE 1 TO WS-ANY-DEPTH
         EXIT PARAGRAPH
     END-IF
     MOVE 0 TO WS-M-THICK
     IF WS-PLANTED = 0
         CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-M-F
         IF WS-M-F < WS-K-006
             MOVE 1 TO WS-M-THICK
             MOVE 1 TO WS-ANY-THICK
         END-IF
     END-IF
     MOVE 1 TO WS-M-RES
     MOVE WS-OX TO WS-M-X
     MOVE WS-OY TO WS-M-Y
     MOVE WS-OZ TO WS-M-Z
     MOVE FL-S-AIR TO WS-M-NEW
     PERFORM M-SET
     PERFORM MODEL-STEM
     PERFORM MODEL-HAT
     .
 MODEL-STEM.
     MOVE WS-M-THICK TO WS-M-R
     PERFORM VARYING WS-M-DX FROM 0 BY 1 UNTIL WS-M-DX > 2 * WS-M-R
         PERFORM VARYING WS-M-DZ FROM 0 BY 1 UNTIL WS-M-DZ > 2 * WS-M-R
             MOVE 0 TO WS-M-CORNER
             IF WS-M-THICK = 1 AND (WS-M-DX = 0 OR WS-M-DX = 2) AND (WS-M-DZ = 0 OR WS-M-DZ = 2)
                 MOVE 1 TO WS-M-CORNER
             END-IF
             PERFORM VARYING WS-M-DY FROM 0 BY 1 UNTIL WS-M-DY >= WS-M-H
                 COMPUTE WS-M-X = WS-OX + WS-M-DX - WS-M-R
                 COMPUTE WS-M-Y = WS-OY + WS-M-DY
                 COMPUTE WS-M-Z = WS-OZ + WS-M-DZ - WS-M-R
                 MOVE 1 TO WS-M-PRED
                 PERFORM M-REPLACEABLE
                 IF WS-M-REPL = 1
                     IF WS-PLANTED = 1
                         PERFORM M-BELOW-AIR
                         IF WS-M-AIR = 0
                             MOVE FL-S-AIR TO WS-M-NEW
                             PERFORM M-SET
                         END-IF
                         MOVE WS-S-STEM TO WS-M-NEW
                         PERFORM M-SET
                     ELSE
                         IF WS-M-CORNER = 1
                             CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-M-F
                             IF WS-M-F < WS-K-01
                                 MOVE WS-S-STEM TO WS-M-NEW
                                 PERFORM M-SET
                             END-IF
                         ELSE
                             MOVE WS-S-STEM TO WS-M-NEW
                             PERFORM M-SET
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 MODEL-HAT.
     COMPUTE WS-M-BOUND = 1 + WS-M-H / 3
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-M-BOUND WS-DRAW
     COMPUTE WS-M-HH = WS-DRAW + 5
     IF WS-M-HH > WS-M-H
         MOVE WS-M-H TO WS-M-HH
     END-IF
     COMPUTE WS-M-BOTTOM = WS-M-H - WS-M-HH
     PERFORM VARYING WS-M-LAYER FROM WS-M-BOTTOM BY 1 UNTIL WS-M-LAYER > WS-M-H
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-M-B3 WS-DRAW
         MOVE 1 TO WS-M-R
         IF WS-M-LAYER < WS-M-H - WS-DRAW
             MOVE 2 TO WS-M-R
         END-IF
         IF WS-M-HH > 8 AND WS-M-LAYER < WS-M-BOTTOM + 4
             MOVE 3 TO WS-M-R
         END-IF
         IF WS-M-THICK = 1
             ADD 1 TO WS-M-R
         END-IF
         PERFORM VARYING WS-M-DX FROM 0 BY 1 UNTIL WS-M-DX > 2 * WS-M-R
             PERFORM VARYING WS-M-DZ FROM 0 BY 1 UNTIL WS-M-DZ > 2 * WS-M-R
                 PERFORM MODEL-HAT-CELL
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> MODEL-HAT-CELL: the cell (WS-M-DX - R, WS-M-LAYER, WS-M-DZ - R) of the hat (WS-M-DX and WS-M-DZ run from 0 to 2R)
 MODEL-HAT-CELL.
     MOVE 0 TO WS-M-EX WS-M-EZ WS-M-INNER WS-M-CORNER WS-M-LOW
     IF WS-M-DX = 0 OR WS-M-DX = 2 * WS-M-R
         MOVE 1 TO WS-M-EX
     END-IF
     IF WS-M-DZ = 0 OR WS-M-DZ = 2 * WS-M-R
         MOVE 1 TO WS-M-EZ
     END-IF
     IF WS-M-EX = 0 AND WS-M-EZ = 0 AND WS-M-LAYER < WS-M-H
         MOVE 1 TO WS-M-INNER
     END-IF
     IF WS-M-EX = 1 AND WS-M-EZ = 1
         MOVE 1 TO WS-M-CORNER
     END-IF
     IF WS-M-LAYER < WS-M-BOTTOM + 3
         MOVE 1 TO WS-M-LOW
     END-IF
     COMPUTE WS-M-X = WS-OX + WS-M-DX - WS-M-R
     COMPUTE WS-M-Y = WS-OY + WS-M-LAYER
     COMPUTE WS-M-Z = WS-OZ + WS-M-DZ - WS-M-R
     MOVE 0 TO WS-M-PRED
     PERFORM M-REPLACEABLE
     IF WS-M-REPL = 0
         EXIT PARAGRAPH
     END-IF
     IF WS-PLANTED = 1
         PERFORM M-BELOW-AIR
         IF WS-M-AIR = 0
             MOVE FL-S-AIR TO WS-M-NEW
             PERFORM M-SET
             MOVE 1 TO WS-ANY-DESTROY
         END-IF
     END-IF
     IF WS-M-LOW = 1
         IF WS-M-INNER = 0
             PERFORM MODEL-DROP
         END-IF
     ELSE
         IF WS-M-INNER = 1
             MOVE WS-K-01 TO WS-M-CD
             MOVE WS-K-02 TO WS-M-CH
             MOVE WS-K-01 TO WS-M-CV
         ELSE
             IF WS-M-CORNER = 1
                 MOVE WS-K-001 TO WS-M-CD
                 MOVE WS-K-07 TO WS-M-CH
                 MOVE WS-K-0083 TO WS-M-CV
             ELSE
                 MOVE WS-K-00005 TO WS-M-CD
                 MOVE WS-K-098 TO WS-M-CH
                 MOVE WS-K-007 TO WS-M-CV
             END-IF
         END-IF
         IF WS-WART = 0
             MOVE 0 TO WS-M-CV
         END-IF
         PERFORM MODEL-HAT-BLOCK
     END-IF
     .
 MODEL-HAT-BLOCK.
     CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-M-F
     IF WS-M-F < WS-M-CD
         MOVE WS-S-DECOR TO WS-M-NEW
         PERFORM M-SET
         MOVE 1 TO WS-ANY-DECOR
     ELSE
         CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-M-F
         IF WS-M-F < WS-M-CH
             MOVE WS-S-HAT TO WS-M-NEW
             PERFORM M-SET
             CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-M-F
             IF WS-M-F < WS-M-CV
                 PERFORM MODEL-VINES
             END-IF
         END-IF
     END-IF
     .
 MODEL-DROP.
     SUBTRACT 1 FROM WS-M-Y
     PERFORM M-GET
     ADD 1 TO WS-M-Y
     IF WS-M-BLK = WS-B-HAT
         MOVE WS-S-HAT TO WS-M-NEW
         PERFORM M-SET
     ELSE
         CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-M-F
         IF WS-M-F < WS-K-015
             MOVE WS-S-HAT TO WS-M-NEW
             PERFORM M-SET
             IF WS-WART = 1
                 CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-M-B11 WS-DRAW
                 IF WS-DRAW = 0
                     PERFORM MODEL-VINES
                 END-IF
             END-IF
         END-IF
     END-IF
     .
*> MODEL-VINES: tryPlaceWeepingVines below the cell (WS-M-X, WS-M-Y, WS-M-Z)
 MODEL-VINES.
     MOVE WS-M-X TO WS-M-VX
     COMPUTE WS-M-CUR = WS-M-Y - 1
     SUBTRACT 1 FROM WS-M-Y
     PERFORM M-GET
     ADD 1 TO WS-M-Y
     IF WS-M-AIR = 0
         EXIT PARAGRAPH
     END-IF
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-M-B5 WS-DRAW
     COMPUTE WS-M-VL = 1 + WS-DRAW
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-M-B7 WS-DRAW
     IF WS-DRAW = 0
         COMPUTE WS-M-VL = WS-M-VL * 2
     END-IF
     MOVE 0 TO WS-M-STOP
     MOVE WS-M-Y TO WS-M-VY
     MOVE WS-M-CUR TO WS-M-Y
     PERFORM VARYING WS-M-I FROM 0 BY 1 UNTIL WS-M-I > WS-M-VL OR WS-M-STOP = 1
         PERFORM M-GET
         IF WS-M-AIR = 1
             SUBTRACT 1 FROM WS-M-Y
             PERFORM M-GET
             ADD 1 TO WS-M-Y
             IF WS-M-I = WS-M-VL OR WS-M-AIR = 0
                 CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-M-B3 WS-DRAW
                 EVALUATE WS-DRAW
                     WHEN 0
                         MOVE WS-S-HEAD1 TO WS-M-NEW
                     WHEN 1
                         MOVE WS-S-HEAD2 TO WS-M-NEW
                     WHEN OTHER
                         MOVE WS-S-HEAD3 TO WS-M-NEW
                 END-EVALUATE
                 PERFORM M-SET
                 MOVE 1 TO WS-ANY-VINE
                 MOVE 1 TO WS-M-STOP
             ELSE
                 MOVE WS-S-PLANT TO WS-M-NEW
                 PERFORM M-SET
             END-IF
         END-IF
         SUBTRACT 1 FROM WS-M-Y
     END-PERFORM
     MOVE WS-M-VY TO WS-M-Y
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-4-12.
 COPY NOSPAWN.
 COPY CORETEST.
