*> Implementation test of the huge mushrooms (docs/protocol/35-worldgen-features-4-decorators-and-vegetation.md sections 11.1 to 11.4 and the checks of section 12 item 7; core/src/feat-mush.cob):
*> the data features huge_brown_mushroom and huge_red_mushroom compile (types 21 and 23; a missing cap or stem provider, a missing can_place_on, a foliage_radius below 1, a missing tag or a full
*> feature table make them unsupported); placement is checked cell by cell against an independent model with its own random source: the height H = 4 + nextInt(3) (doubled on nextInt(12) = 0),
*> the position rules (origin.y >= minY + 1, origin.y + H + 1 <= maxY, can_place_on below, every layer 0..H of radius 0 (red, brown up to layer 3) or the foliage radius holds air or leaves), the brown cap
*> (one layer at H, corners left out, four side properties by the xMin/xMax/zMin/zMax rule) and the red cap (four layers, the ring and the full top square, up and the four sides by inner = R - 2), and the
*> stem of H cells; a mushroom block is set only over air or replaceable_by_mushrooms; a cap state without the side properties is placed as given; a provider without a state places nothing.
*> The worked examples of 11.4 (the flags of the named cells, 45 cap blocks for H = 6 R = 3 and H = 5 R = 2) are checked on the model and on the level.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-4-11.
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
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/mush".
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
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
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
 01 WS-B3                  BINARY-LONG VALUE 3.
 01 WS-B12                 BINARY-LONG VALUE 12.
 01 WS-SEEDNO              BINARY-LONG.
 01 WS-SEEDTXT             PIC 999.
 01 WS-TAG-REG             PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112).
 01 WS-TAG-N               BINARY-LONG.
 01 WS-TAG-IDS.
    05 WS-TAG-ID           BINARY-LONG OCCURS 4 TIMES.
 01 WS-TAG-STATUS          BINARY-LONG.
*> the blocks the model knows
 01 WS-B-AIR               BINARY-LONG.
 01 WS-B-DIRT              BINARY-LONG.
 01 WS-B-LEAVES            BINARY-LONG.
 01 WS-B-GRASS             BINARY-LONG.
 01 WS-B-STONE             BINARY-LONG.
 01 WS-B-BROWN             BINARY-LONG.
 01 WS-B-RED               BINARY-LONG.
 01 WS-S-STONE             BINARY-LONG.
 01 WS-S-DIRT              BINARY-LONG.
 01 WS-S-LOG               BINARY-LONG.
 01 WS-S-STEM              BINARY-LONG.
 01 WS-CAPB-TABLE.
    05 WS-CAPB             BINARY-LONG OCCURS 16 TIMES.
 01 WS-CAPR-TABLE.
    05 WS-CAPR             BINARY-LONG OCCURS 32 TIMES.
*> the case under test
 01 WS-KIND                BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-OX                  BINARY-LONG VALUE 24.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG VALUE 40.
 01 WS-WY0                 BINARY-LONG.
 01 WS-COLTOP              BINARY-LONG.
 01 WS-ACTUAL-CAPS         BINARY-LONG.
 01 WS-FOUND45             BINARY-LONG.
 01 WS-LABEL               PIC X(20).
 01 WS-OYTXT               PIC -999.
 01 WS-MODETXT             PIC 9.
*> the snapshot before and the model's expectation after: x 16..31, z 32..47, y WS-WY0 .. WS-WY0 + 39 (index (y - WY0) * 256 + (z - 32) * 16 + (x - 16) + 1)
 01 WS-S0-TABLE.
    05 WS-S0               BINARY-LONG OCCURS 10240 TIMES.
 01 WS-EXPS-TABLE.
    05 WS-EXPS             BINARY-LONG OCCURS 10240 TIMES.
 01 WS-M-RES               BINARY-LONG.
 01 WS-M-H                 BINARY-LONG.
 01 WS-M-CAPN              BINARY-LONG.
 01 WS-M-IDX               BINARY-LONG.
 01 WS-M-X                 BINARY-LONG.
 01 WS-M-Y                 BINARY-LONG.
 01 WS-M-Z                 BINARY-LONG.
 01 WS-M-ST                BINARY-LONG.
 01 WS-M-BLK               BINARY-LONG.
 01 WS-M-LAYER             BINARY-LONG.
 01 WS-M-RAD               BINARY-LONG.
 01 WS-M-NRAD              BINARY-LONG.
 01 WS-M-DX                BINARY-LONG.
 01 WS-M-DZ                BINARY-LONG.
 01 WS-M-VALID             BINARY-LONG.
 01 WS-M-NEWST             BINARY-LONG.
 01 WS-M-INNER             BINARY-LONG.
 01 WS-M-XMIN              BINARY-LONG.
 01 WS-M-XMAX              BINARY-LONG.
 01 WS-M-ZMIN              BINARY-LONG.
 01 WS-M-ZMAX              BINARY-LONG.
 01 WS-M-ONX               BINARY-LONG.
 01 WS-M-ONZ               BINARY-LONG.
 01 WS-M-W                 BINARY-LONG.
 01 WS-M-E                 BINARY-LONG.
 01 WS-M-N                 BINARY-LONG.
 01 WS-M-S                 BINARY-LONG.
 01 WS-M-U                 BINARY-LONG.
 01 WS-M-SKIP              BINARY-LONG.
 01 WS-M-F                 BINARY-LONG.
 01 WS-M-AX                BINARY-LONG.
 01 WS-M-AZ                BINARY-LONG.
 01 WS-M-I                 BINARY-LONG.
 01 WS-TW                  PIC X(5).
 01 WS-TE                  PIC X(5).
 01 WS-TN                  PIC X(5).
 01 WS-TS                  PIC X(5).
 01 WS-TU                  PIC X(5).
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

*>   a missing tag: the block tags are not registered yet
     MOVE "minecraft:hbrown_early" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-4§11.1: a missing block tag (leaves) makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N

*>   the blocks and the tags
     MOVE "air" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-AIR
     MOVE "dirt" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-DIRT
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-DIRT
     COMPUTE WS-TAG-ID(1) = WS-WANT - 1
     MOVE 1 TO WS-TAG-N
     MOVE "minecraft:mush_ground_t" TO WS-TAG
     CALL "TAG-PUT" USING WS-TAG-REG WS-TAG WS-TAG-N WS-TAG-IDS WS-TAG-STATUS
     MOVE "oak_leaves" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-LEAVES
     COMPUTE WS-TAG-ID(1) = WS-WANT - 1
     MOVE "minecraft:leaves" TO WS-TAG
     CALL "TAG-PUT" USING WS-TAG-REG WS-TAG WS-TAG-N WS-TAG-IDS WS-TAG-STATUS
     MOVE "short_grass" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-GRASS
     COMPUTE WS-TAG-ID(1) = WS-WANT - 1
     MOVE "minecraft:replaceable_by_mushrooms" TO WS-TAG
     CALL "TAG-PUT" USING WS-TAG-REG WS-TAG WS-TAG-N WS-TAG-IDS WS-TAG-STATUS
     MOVE "stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-STONE
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-STONE
     MOVE "brown_mushroom_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-BROWN
     MOVE "red_mushroom_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-RED
     MOVE "oak_log" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-LOG
     MOVE "mushroom_stem" TO WS-KEY
     MOVE "down=false,east=true,north=true,south=true,up=false,west=true" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-S-STEM
     PERFORM BUILD-CAP-TABLES

*>   the data features compile
     MOVE "minecraft:hbrown" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-4§11: the data feature huge_brown_mushroom compiles as type 21" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 21 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§11.1: foliage_radius 3 is read" TO WS-CASE
     MOVE WA-I(FT-A(WS-FT), 1) TO WS-OBS
     MOVE 3 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:hred" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-4§11: the data feature huge_red_mushroom compiles as type 23" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 23 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§11.1: foliage_radius defaults to 2" TO WS-CASE
     MOVE WA-I(FT-A(WS-FT), 1) TO WS-OBS
     MOVE 2 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:hred_tag" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-4§11.1: can_place_on given as a block tag compiles" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 23 TO WS-EXP
     PERFORM ASSERT-N

*>   unsupported forms
     MOVE "minecraft:hbrown_nocap" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-4§11.1: a missing cap_provider makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:hbrown_nostem" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-4§11.1: a missing stem_provider makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:hbrown_nopred" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-4§11.1: a missing can_place_on makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:hbrown_badradius" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-4§11.1: a foliage_radius below 1 makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE FD-WA-COUNT TO WS-COUNT
     MOVE FD-MAX-WA TO FD-WA-COUNT
     MOVE "minecraft:hbrown_full" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE WS-COUNT TO FD-WA-COUNT
     MOVE "35-4§11: a full feature table makes the feature unsupported" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE -1 TO WS-EXP
     PERFORM ASSERT-N

*>   worked examples of 11.4 on the flag rules
     MOVE 1 TO WS-KIND
     MOVE 3 TO WS-R
     MOVE -3 TO WS-M-DX
     MOVE 0 TO WS-M-DZ
     PERFORM BROWN-FLAGS
     MOVE "35-4§11.4: brown cell (-3, 0) has west only" TO WS-CASE
     COMPUTE WS-OBS = WS-M-W + 2 * WS-M-E + 4 * WS-M-N + 8 * WS-M-S
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE -2 TO WS-M-DX
     MOVE -3 TO WS-M-DZ
     PERFORM BROWN-FLAGS
     MOVE "35-4§11.4: brown cell (-2, -3) has west and north" TO WS-CASE
     COMPUTE WS-OBS = WS-M-W + 2 * WS-M-E + 4 * WS-M-N + 8 * WS-M-S
     MOVE 5 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 0 TO WS-M-DX WS-M-DZ
     PERFORM BROWN-FLAGS
     MOVE "35-4§11.4: brown cell (0, 0) has no side" TO WS-CASE
     COMPUTE WS-OBS = WS-M-W + 2 * WS-M-E + 4 * WS-M-N + 8 * WS-M-S + 100 * WS-M-SKIP
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE -3 TO WS-M-DX
     MOVE -2 TO WS-M-DZ
     PERFORM BROWN-FLAGS
     MOVE "35-4§11.4: brown cell (-3, -2) has west and north" TO WS-CASE
     COMPUTE WS-OBS = WS-M-W + 2 * WS-M-E + 4 * WS-M-N + 8 * WS-M-S
     MOVE 5 TO WS-EXP
     PERFORM ASSERT-N
     MOVE -3 TO WS-M-DX WS-M-DZ
     PERFORM BROWN-FLAGS
     MOVE "35-4§11.4: a brown corner is left out" TO WS-CASE
     MOVE WS-M-SKIP TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 0 TO WS-M-CAPN
     PERFORM VARYING WS-M-DX FROM -3 BY 1 UNTIL WS-M-DX > 3
         PERFORM VARYING WS-M-DZ FROM -3 BY 1 UNTIL WS-M-DZ > 3
             PERFORM BROWN-FLAGS
             IF WS-M-SKIP = 0
                 ADD 1 TO WS-M-CAPN
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "35-4§11.4: the brown cap of R = 3 has 45 cells" TO WS-CASE
     MOVE WS-M-CAPN TO WS-OBS
     MOVE 45 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 2 TO WS-KIND
     MOVE 2 TO WS-R
     MOVE 5 TO WS-M-H
     MOVE 2 TO WS-M-LAYER
     MOVE -2 TO WS-M-DX
     MOVE 0 TO WS-M-DZ
     PERFORM RED-FLAGS
     MOVE "35-4§11.4: red cell (-2, 0) at layer 2 has west only" TO WS-CASE
     COMPUTE WS-OBS = WS-M-W + 2 * WS-M-E + 4 * WS-M-N + 8 * WS-M-S + 16 * WS-M-U
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE -1 TO WS-M-DZ
     PERFORM RED-FLAGS
     MOVE "35-4§11.4: red cell (-2, -1) at layer 2 has west and north" TO WS-CASE
     COMPUTE WS-OBS = WS-M-W + 2 * WS-M-E + 4 * WS-M-N + 8 * WS-M-S + 16 * WS-M-U
     MOVE 5 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 4 TO WS-M-LAYER
     PERFORM RED-FLAGS
     MOVE "35-4§11.4: red cell (-2, -1) at layer 4 (H - 1) has up, west and north" TO WS-CASE
     COMPUTE WS-OBS = WS-M-W + 2 * WS-M-E + 4 * WS-M-N + 8 * WS-M-S + 16 * WS-M-U
     MOVE 21 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 5 TO WS-M-LAYER
     MOVE 0 TO WS-M-DX WS-M-DZ
     PERFORM RED-FLAGS
     MOVE "35-4§11.4: red top cell (0, 0) has up and no side" TO WS-CASE
     COMPUTE WS-OBS = WS-M-W + 2 * WS-M-E + 4 * WS-M-N + 8 * WS-M-S + 16 * WS-M-U + 100 * WS-M-SKIP
     MOVE 16 TO WS-EXP
     PERFORM ASSERT-N
     MOVE -1 TO WS-M-DX WS-M-DZ
     PERFORM RED-FLAGS
     MOVE "35-4§11.4: red top cell (-1, -1) has up, west and north" TO WS-CASE
     COMPUTE WS-OBS = WS-M-W + 2 * WS-M-E + 4 * WS-M-N + 8 * WS-M-S + 16 * WS-M-U
     MOVE 21 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 0 TO WS-M-CAPN
     PERFORM VARYING WS-M-LAYER FROM 2 BY 1 UNTIL WS-M-LAYER > 5
         COMPUTE WS-M-RAD = WS-R
         IF WS-M-LAYER = 5
             COMPUTE WS-M-RAD = WS-R - 1
         END-IF
         COMPUTE WS-M-NRAD = 0 - WS-M-RAD
         PERFORM VARYING WS-M-DX FROM WS-M-NRAD BY 1 UNTIL WS-M-DX > WS-M-RAD
             PERFORM VARYING WS-M-DZ FROM WS-M-NRAD BY 1 UNTIL WS-M-DZ > WS-M-RAD
                 PERFORM RED-FLAGS
                 IF WS-M-SKIP = 0
                     ADD 1 TO WS-M-CAPN
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "35-4§11.4: the red cap of R = 2, H = 5 has 3 * 12 + 9 = 45 cells" TO WS-CASE
     MOVE WS-M-CAPN TO WS-OBS
     MOVE 45 TO WS-EXP
     PERFORM ASSERT-N

*>   placement against the model: the brown mushroom at y 64, seven ground and obstacle modes
     MOVE 0 TO WS-FOUND45
     MOVE 1 TO WS-KIND
     MOVE 0 TO WS-VAR
     MOVE "minecraft:hbrown" TO WS-FTKEY
     MOVE "brown" TO WS-LABEL
     MOVE 64 TO WS-OY
     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 84
         COMPUTE WS-MODE = FUNCTION MOD(WS-SEEDNO, 7)
         PERFORM RUN-CASE
     END-PERFORM
     MOVE "35-4§11 (12.7): a brown mushroom of H = 6, R = 3 with 45 cap blocks was placed" TO WS-CASE
     MOVE WS-FOUND45 TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
*>   red
     MOVE 0 TO WS-FOUND45
     MOVE 2 TO WS-KIND
     MOVE "minecraft:hred" TO WS-FTKEY
     MOVE "red" TO WS-LABEL
     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 84
         COMPUTE WS-MODE = FUNCTION MOD(WS-SEEDNO, 7)
         PERFORM RUN-CASE
     END-PERFORM
     MOVE "35-4§11 (12.7): a red mushroom of H = 5, R = 2 with 45 cap blocks was placed" TO WS-CASE
     MOVE WS-FOUND45 TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
*>   the tag predicate
     MOVE "minecraft:hred_tag" TO WS-FTKEY
     MOVE "redtag" TO WS-LABEL
     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 5
         MOVE 0 TO WS-MODE
         PERFORM RUN-CASE
     END-PERFORM
*>   states without the side properties, and providers without a state
     MOVE 0 TO WS-FOUND45
     MOVE 1 TO WS-VAR
     MOVE "minecraft:hred_plain" TO WS-FTKEY
     MOVE "redplain" TO WS-LABEL
     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 6
         MOVE 0 TO WS-MODE
         PERFORM RUN-CASE
     END-PERFORM
     MOVE 1 TO WS-KIND
     MOVE "minecraft:hbrown_plain" TO WS-FTKEY
     MOVE "brownplain" TO WS-LABEL
     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 6
         MOVE 0 TO WS-MODE
         PERFORM RUN-CASE
     END-PERFORM
     MOVE 2 TO WS-VAR
     MOVE "minecraft:hbrown_nocapstate" TO WS-FTKEY
     MOVE "nocapstate" TO WS-LABEL
     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 6
         MOVE 0 TO WS-MODE
         PERFORM RUN-CASE
     END-PERFORM
     MOVE 3 TO WS-VAR
     MOVE "minecraft:hbrown_nostemstate" TO WS-FTKEY
     MOVE "nostemstate" TO WS-LABEL
     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 6
         MOVE 0 TO WS-MODE
         PERFORM RUN-CASE
     END-PERFORM
*>   the height limits: near the top of the world and at the bottom
     MOVE 0 TO WS-VAR
     MOVE 313 TO WS-OY
     MOVE "minecraft:hbrown" TO WS-FTKEY
     MOVE "browntop" TO WS-LABEL
     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 24
         MOVE 0 TO WS-MODE
         PERFORM RUN-CASE
     END-PERFORM
     MOVE 2 TO WS-KIND
     MOVE "minecraft:hred" TO WS-FTKEY
     MOVE "redtop" TO WS-LABEL
     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 24
         MOVE 0 TO WS-MODE
         PERFORM RUN-CASE
     END-PERFORM
     MOVE -63 TO WS-OY
     MOVE "redlow" TO WS-LABEL
     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 6
         MOVE 0 TO WS-MODE
         PERFORM RUN-CASE
     END-PERFORM
     MOVE -64 TO WS-OY
     MOVE "redbottom" TO WS-LABEL
     PERFORM VARYING WS-SEEDNO FROM 1 BY 1 UNTIL WS-SEEDNO > 6
         MOVE 0 TO WS-MODE
         PERFORM RUN-CASE
     END-PERFORM

     MOVE 1 TO FI-GATE
     MOVE "minecraft:mushroom_island_vegetation" TO WS-FTKEY
     CALL "FR-GATE" USING WS-FTKEY WS-COUNT
     MOVE "35-4§11: the gate admits the mushroom_island_vegetation placed feature" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN
     .
*> RUN-CASE: one placement of the feature WS-FTKEY (kind WS-KIND, variant WS-VAR) at (24, WS-OY, 40) over the ground of WS-MODE with the random seed of WS-SEEDNO, against the model
 RUN-CASE.
     IF WS-KIND = 1
         MOVE 3 TO WS-R
     ELSE
         MOVE 2 TO WS-R
     END-IF
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     COMPUTE WS-SEED = WS-SEEDNO * 7919 + WS-OY + 100
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
     STRING "35-4§11: " FUNCTION TRIM(WS-LABEL) " y " WS-OYTXT " mode " WS-MODETXT " seed " WS-SEEDTXT " the level equals the model, cell by cell" DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE SPACES TO WS-CASE
     STRING "35-4§11: " FUNCTION TRIM(WS-LABEL) " y " WS-OYTXT " mode " WS-MODETXT " seed " WS-SEEDTXT " the result and the random state equal the model's" DELIMITED BY SIZE INTO WS-CASE
     MOVE 1000 TO WS-DRAW
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-DRAW WS-OBS
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-DRAW WS-EXP
     COMPUTE WS-OBS = WS-RESULT * 10000 + WS-OBS
     COMPUTE WS-EXP = WS-M-RES * 10000 + WS-EXP
     PERFORM ASSERT-N
     IF WS-M-RES = 1 AND WS-MODE = 0 AND WS-VAR = 0 AND WS-OY = 64
         IF (WS-KIND = 1 AND WS-M-H = 6) OR (WS-KIND = 2 AND WS-M-H = 5)
             MOVE 0 TO WS-ACTUAL-CAPS
             PERFORM COUNT-ACTUAL-CAPS
             IF WS-ACTUAL-CAPS = 45
                 MOVE 1 TO WS-FOUND45
             END-IF
         END-IF
     END-IF
     .
*> NEW-WORLD: chunk (1, 2); stone three layers and dirt below the origin; the obstacles of WS-MODE; the random sources seeded
 NEW-WORLD.
     SET ADDRESS OF WS-A TO WS-PTR
     MOVE LOW-VALUES TO WS-A
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     COMPUTE WS-Y0 = WS-OY - 4
     COMPUTE WS-Y1 = WS-OY - 2
     IF WS-Y0 < -64
         MOVE -64 TO WS-Y0
     END-IF
     MOVE "stone" TO WS-KEY
     IF WS-Y1 >= WS-Y0
         PERFORM FILL-BOX
     END-IF
     COMPUTE WS-Y0 = WS-OY - 1
     MOVE WS-Y0 TO WS-Y1
     IF WS-MODE = 5
         MOVE "stone" TO WS-KEY
     ELSE
         MOVE "dirt" TO WS-KEY
     END-IF
     IF WS-Y0 >= -64
         PERFORM FILL-BOX
     END-IF
     COMPUTE WS-COLTOP = WS-OY + 25
     IF WS-COLTOP > 319
         MOVE 319 TO WS-COLTOP
     END-IF
     EVALUATE WS-MODE
         WHEN 1
             COMPUTE WS-X = WS-OX + 2
             COMPUTE WS-Y = WS-OY + 4
             COMPUTE WS-Z = WS-OZ + 1
             MOVE "stone" TO WS-KEY
             PERFORM PUT-AT
         WHEN 2
             MOVE "oak_leaves" TO WS-KEY
             PERFORM PUT-COLUMN
         WHEN 3
             MOVE "short_grass" TO WS-KEY
             PERFORM PUT-COLUMN
         WHEN 4
             MOVE "stone" TO WS-KEY
             PERFORM PUT-COLUMN
         WHEN 6
             COMPUTE WS-X = WS-OX + 3
             COMPUTE WS-Y = WS-OY + 2
             COMPUTE WS-Z = WS-OZ + 3
             MOVE "stone" TO WS-KEY
             PERFORM PUT-AT
             COMPUTE WS-X = WS-OX - 3
             COMPUTE WS-Y = WS-OY + 1
             COMPUTE WS-Z = WS-OZ - 3
             PERFORM PUT-AT
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     .
*> PUT-COLUMN: the block WS-KEY at x = origin + R, z = origin, y from origin + 1 up to WS-COLTOP
 PUT-COLUMN.
     COMPUTE WS-X = WS-OX + WS-R
     MOVE WS-OZ TO WS-Z
     PERFORM VARYING WS-M-Y FROM WS-OY BY 1 UNTIL WS-M-Y >= WS-COLTOP
         COMPUTE WS-Y = WS-M-Y + 1
         PERFORM PUT-AT
     END-PERFORM
     .
*> SNAPSHOT: WS-S0 = the states of the window; the window starts at WS-WY0
 SNAPSHOT.
     IF WS-OY = 313
         MOVE 280 TO WS-WY0
     ELSE
         COMPUTE WS-WY0 = WS-OY - 4
         IF WS-WY0 < -64
             MOVE -64 TO WS-WY0
         END-IF
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
*> COUNT-ACTUAL-CAPS: WS-ACTUAL-CAPS = the cap blocks (brown or red mushroom block) of the window on the level
 COUNT-ACTUAL-CAPS.
     PERFORM VARYING WS-Y FROM WS-WY0 BY 1 UNTIL WS-Y > WS-WY0 + 39
         PERFORM VARYING WS-Z FROM 32 BY 1 UNTIL WS-Z > 47
             PERFORM VARYING WS-X FROM 16 BY 1 UNTIL WS-X > 31
                 PERFORM BLOCK-NOW
                 IF WS-BLOCK = WS-B-BROWN OR WS-BLOCK = WS-B-RED
                     ADD 1 TO WS-ACTUAL-CAPS
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> COMPARE-MODEL: WS-BAD = the cells of the window whose state differs from the model's
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
*> INDEX-OF: WS-M-IDX of the cell (WS-M-X, WS-M-Y, WS-M-Z)
 INDEX-OF.
     COMPUTE WS-M-IDX = (WS-M-Y - WS-WY0) * 256 + (WS-M-Z - 32) * 16 + (WS-M-X - 16) + 1
     .
*> PLACE-IF-FREE: WS-M-NEWST at (WS-M-X, WS-M-Y, WS-M-Z) when the model's current block there is air or short grass (the replaceable_by_mushrooms of this test); counts caps when WS-M-F = 1
 PLACE-IF-FREE.
     PERFORM INDEX-OF
     MOVE WS-EXPS(WS-M-IDX) TO WS-M-ST
     CALL "FL-BLOCK-OF" USING WS-M-ST WS-M-BLK
     IF WS-M-BLK = WS-B-AIR OR WS-M-BLK = WS-B-GRASS
         MOVE WS-M-NEWST TO WS-EXPS(WS-M-IDX)
         IF WS-M-F = 1
             ADD 1 TO WS-M-CAPN
         END-IF
     END-IF
     .
*> BROWN-FLAGS: for WS-M-DX, WS-M-DZ and WS-R: WS-M-SKIP (corner) and the side flags WS-M-W, WS-M-E, WS-M-N, WS-M-S by 11.2
 BROWN-FLAGS.
     MOVE 0 TO WS-M-SKIP WS-M-W WS-M-E WS-M-N WS-M-S
     COMPUTE WS-M-XMIN = 0
     COMPUTE WS-M-XMAX = 0
     COMPUTE WS-M-ZMIN = 0
     COMPUTE WS-M-ZMAX = 0
     IF WS-M-DX = 0 - WS-R
         MOVE 1 TO WS-M-XMIN
     END-IF
     IF WS-M-DX = WS-R
         MOVE 1 TO WS-M-XMAX
     END-IF
     IF WS-M-DZ = 0 - WS-R
         MOVE 1 TO WS-M-ZMIN
     END-IF
     IF WS-M-DZ = WS-R
         MOVE 1 TO WS-M-ZMAX
     END-IF
     COMPUTE WS-M-ONX = WS-M-XMIN + WS-M-XMAX
     COMPUTE WS-M-ONZ = WS-M-ZMIN + WS-M-ZMAX
     IF WS-M-ONX > 0 AND WS-M-ONZ > 0
         MOVE 1 TO WS-M-SKIP
     ELSE
         IF WS-M-XMIN = 1 OR (WS-M-ONZ > 0 AND WS-M-DX = 1 - WS-R)
             MOVE 1 TO WS-M-W
         END-IF
         IF WS-M-XMAX = 1 OR (WS-M-ONZ > 0 AND WS-M-DX = WS-R - 1)
             MOVE 1 TO WS-M-E
         END-IF
         IF WS-M-ZMIN = 1 OR (WS-M-ONX > 0 AND WS-M-DZ = 1 - WS-R)
             MOVE 1 TO WS-M-N
         END-IF
         IF WS-M-ZMAX = 1 OR (WS-M-ONX > 0 AND WS-M-DZ = WS-R - 1)
             MOVE 1 TO WS-M-S
         END-IF
     END-IF
     .
*> RED-FLAGS: for WS-M-LAYER (height above the origin), WS-M-H, WS-M-DX, WS-M-DZ, WS-R: WS-M-SKIP and the flags WS-M-W, E, N, S, U by 11.3
 RED-FLAGS.
     MOVE 0 TO WS-M-SKIP WS-M-W WS-M-E WS-M-N WS-M-S WS-M-U
     COMPUTE WS-M-INNER = WS-R - 2
     IF WS-M-LAYER < WS-M-H
         COMPUTE WS-M-RAD = WS-R
     ELSE
         COMPUTE WS-M-RAD = WS-R - 1
     END-IF
     COMPUTE WS-M-AX = FUNCTION ABS(WS-M-DX)
     COMPUTE WS-M-AZ = FUNCTION ABS(WS-M-DZ)
     MOVE 0 TO WS-M-ONX WS-M-ONZ
     IF WS-M-AX = WS-M-RAD
         MOVE 1 TO WS-M-ONX
     END-IF
     IF WS-M-AZ = WS-M-RAD
         MOVE 1 TO WS-M-ONZ
     END-IF
     IF WS-M-LAYER < WS-M-H AND WS-M-ONX = WS-M-ONZ
         MOVE 1 TO WS-M-SKIP
     ELSE
         IF WS-M-LAYER >= WS-M-H - 1
             MOVE 1 TO WS-M-U
         END-IF
         IF WS-M-DX < 0 - WS-M-INNER
             MOVE 1 TO WS-M-W
         END-IF
         IF WS-M-DX > WS-M-INNER
             MOVE 1 TO WS-M-E
         END-IF
         IF WS-M-DZ < 0 - WS-M-INNER
             MOVE 1 TO WS-M-N
         END-IF
         IF WS-M-DZ > WS-M-INNER
             MOVE 1 TO WS-M-S
         END-IF
     END-IF
     .
*> BUILD-CAP-TABLES: WS-CAPB(1 + w + 2e + 4n + 8s) the brown cap state (up true, down false), WS-CAPR(1 + w + 2e + 4n + 8s + 16u) the red one
 BUILD-CAP-TABLES.
     PERFORM VARYING WS-M-U FROM 0 BY 1 UNTIL WS-M-U > 1
         PERFORM VARYING WS-M-W FROM 0 BY 1 UNTIL WS-M-W > 1
             PERFORM VARYING WS-M-E FROM 0 BY 1 UNTIL WS-M-E > 1
                 PERFORM VARYING WS-M-N FROM 0 BY 1 UNTIL WS-M-N > 1
                     PERFORM VARYING WS-M-S FROM 0 BY 1 UNTIL WS-M-S > 1
                         COMPUTE WS-M-F = 1 + WS-M-W + 2 * WS-M-E + 4 * WS-M-N + 8 * WS-M-S + 16 * WS-M-U
                         PERFORM TEXT-FLAGS
                         MOVE SPACES TO WS-PAIRS
                         IF WS-M-U = 0
*>                           the brown table: the provider's up is true
                             STRING "down=false,east=" FUNCTION TRIM(WS-TE) ",north=" FUNCTION TRIM(WS-TN) ",south=" FUNCTION TRIM(WS-TS)
                                 ",up=true,west=" FUNCTION TRIM(WS-TW) DELIMITED BY SIZE INTO WS-PAIRS
                             MOVE "brown_mushroom_block" TO WS-KEY
                             CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-CAPB(WS-M-F)
                         END-IF
                         MOVE SPACES TO WS-PAIRS
                         STRING "down=false,east=" FUNCTION TRIM(WS-TE) ",north=" FUNCTION TRIM(WS-TN) ",south=" FUNCTION TRIM(WS-TS)
                             ",up=" FUNCTION TRIM(WS-TU) ",west=" FUNCTION TRIM(WS-TW) DELIMITED BY SIZE INTO WS-PAIRS
                         MOVE "red_mushroom_block" TO WS-KEY
                         CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-CAPR(WS-M-F)
                     END-PERFORM
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 TEXT-FLAGS.
     MOVE "false" TO WS-TW WS-TE WS-TN WS-TS WS-TU
     IF WS-M-W = 1
         MOVE "true" TO WS-TW
     END-IF
     IF WS-M-E = 1
         MOVE "true" TO WS-TE
     END-IF
     IF WS-M-N = 1
         MOVE "true" TO WS-TN
     END-IF
     IF WS-M-S = 1
         MOVE "true" TO WS-TS
     END-IF
     IF WS-M-U = 1
         MOVE "true" TO WS-TU
     END-IF
     .
*> CAP-STATE: WS-M-NEWST = the model's cap state for the flags WS-M-W, E, N, S, U of the case's kind and variant
 CAP-STATE.
     COMPUTE WS-M-F = 1 + WS-M-W + 2 * WS-M-E + 4 * WS-M-N + 8 * WS-M-S
     IF WS-VAR = 1
         MOVE WS-S-STONE TO WS-M-NEWST
     ELSE
         IF WS-KIND = 1
             MOVE WS-CAPB(WS-M-F) TO WS-M-NEWST
         ELSE
             COMPUTE WS-M-F = WS-M-F + 16 * WS-M-U
             MOVE WS-CAPR(WS-M-F) TO WS-M-NEWST
         END-IF
     END-IF
     .
*> MODEL-RUN: replay the document's flow on the snapshot with the second random source: WS-EXPS, WS-M-RES, WS-M-H, WS-M-CAPN
 MODEL-RUN.
     PERFORM VARYING WS-M-I FROM 1 BY 1 UNTIL WS-M-I > 10240
         MOVE WS-S0(WS-M-I) TO WS-EXPS(WS-M-I)
     END-PERFORM
     MOVE 0 TO WS-M-RES WS-M-CAPN
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-B3 WS-DRAW
     COMPUTE WS-M-H = 4 + WS-DRAW
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-B12 WS-DRAW
     IF WS-DRAW = 0
         COMPUTE WS-M-H = WS-M-H * 2
     END-IF
     IF WS-OY < -63 OR WS-OY + WS-M-H + 1 > 319
         EXIT PARAGRAPH
     END-IF
*>   can_place_on: dirt below
     MOVE WS-OX TO WS-M-X
     COMPUTE WS-M-Y = WS-OY - 1
     MOVE WS-OZ TO WS-M-Z
     PERFORM INDEX-OF
     MOVE WS-S0(WS-M-IDX) TO WS-M-ST
     CALL "FL-BLOCK-OF" USING WS-M-ST WS-M-BLK
     IF WS-M-BLK NOT = WS-B-DIRT
         EXIT PARAGRAPH
     END-IF
*>   every layer is free of solid blocks inside its radius
     MOVE 1 TO WS-M-VALID
     PERFORM VARYING WS-M-LAYER FROM 0 BY 1 UNTIL WS-M-LAYER > WS-M-H
         MOVE 0 TO WS-M-RAD
         IF WS-KIND = 1 AND WS-M-LAYER > 3
             MOVE WS-R TO WS-M-RAD
         END-IF
         COMPUTE WS-M-NRAD = 0 - WS-M-RAD
         PERFORM VARYING WS-M-DX FROM WS-M-NRAD BY 1 UNTIL WS-M-DX > WS-M-RAD
             PERFORM VARYING WS-M-DZ FROM WS-M-NRAD BY 1 UNTIL WS-M-DZ > WS-M-RAD
                 COMPUTE WS-M-X = WS-OX + WS-M-DX
                 COMPUTE WS-M-Y = WS-OY + WS-M-LAYER
                 COMPUTE WS-M-Z = WS-OZ + WS-M-DZ
                 PERFORM INDEX-OF
                 MOVE WS-S0(WS-M-IDX) TO WS-M-ST
                 CALL "FL-BLOCK-OF" USING WS-M-ST WS-M-BLK
                 IF WS-M-BLK NOT = WS-B-AIR AND WS-M-BLK NOT = WS-B-LEAVES
                     MOVE 0 TO WS-M-VALID
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF WS-M-VALID = 0
         EXIT PARAGRAPH
     END-IF
     MOVE 1 TO WS-M-RES
*>   the cap
     IF WS-VAR NOT = 2
         IF WS-KIND = 1
             PERFORM MODEL-BROWN-CAP
         ELSE
             PERFORM MODEL-RED-CAP
         END-IF
     END-IF
*>   the stem: H cells, the plain variant uses a log
     IF WS-VAR NOT = 3
         PERFORM VARYING WS-M-I FROM 0 BY 1 UNTIL WS-M-I >= WS-M-H
             MOVE WS-OX TO WS-M-X
             COMPUTE WS-M-Y = WS-OY + WS-M-I
             MOVE WS-OZ TO WS-M-Z
             IF WS-VAR = 1
                 MOVE WS-S-LOG TO WS-M-NEWST
             ELSE
                 MOVE WS-S-STEM TO WS-M-NEWST
             END-IF
             MOVE 0 TO WS-M-F
             PERFORM PLACE-IF-FREE
         END-PERFORM
     END-IF
     .
 MODEL-BROWN-CAP.
     COMPUTE WS-M-NRAD = 0 - WS-R
     PERFORM VARYING WS-M-DX FROM WS-M-NRAD BY 1 UNTIL WS-M-DX > WS-R
         PERFORM VARYING WS-M-DZ FROM WS-M-NRAD BY 1 UNTIL WS-M-DZ > WS-R
             PERFORM BROWN-FLAGS
             IF WS-M-SKIP = 0
                 MOVE 0 TO WS-M-U
                 PERFORM CAP-STATE
                 COMPUTE WS-M-X = WS-OX + WS-M-DX
                 COMPUTE WS-M-Y = WS-OY + WS-M-H
                 COMPUTE WS-M-Z = WS-OZ + WS-M-DZ
                 MOVE 1 TO WS-M-F
                 PERFORM PLACE-IF-FREE
             END-IF
         END-PERFORM
     END-PERFORM
     .
 MODEL-RED-CAP.
     PERFORM VARYING WS-M-LAYER FROM WS-M-H BY -1 UNTIL WS-M-LAYER < WS-M-H - 3
         IF WS-M-LAYER < WS-M-H
             MOVE WS-R TO WS-M-RAD
         ELSE
             COMPUTE WS-M-RAD = WS-R - 1
         END-IF
         COMPUTE WS-M-NRAD = 0 - WS-M-RAD
         PERFORM VARYING WS-M-DX FROM WS-M-NRAD BY 1 UNTIL WS-M-DX > WS-M-RAD
             PERFORM VARYING WS-M-DZ FROM WS-M-NRAD BY 1 UNTIL WS-M-DZ > WS-M-RAD
                 PERFORM RED-FLAGS
                 IF WS-M-SKIP = 0
                     PERFORM CAP-STATE
                     COMPUTE WS-M-X = WS-OX + WS-M-DX
                     COMPUTE WS-M-Y = WS-OY + WS-M-LAYER
                     COMPUTE WS-M-Z = WS-OZ + WS-M-DZ
                     MOVE 1 TO WS-M-F
                     PERFORM PLACE-IF-FREE
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-4-11.
 COPY CORETEST.
