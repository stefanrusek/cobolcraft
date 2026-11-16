*> Implementation test of the tree decorators beehive, alter_ground, place_on_ground, shelf_mushroom, attached_to_leaves, pale_moss and creaking_heart (docs/protocol/35-worldgen-features-4-decorators-and-vegetation.md
*> sections 3.2 and 3.3; core/src/feat-tree-deco2.cob, FD-DECO-NODE and FR-DECORATE of feat-tree-deco.cob). The data features compile (type 51, the decorator kinds and fields; a decorator with an empty direction list or
*> tries 0 is unsupported). Behaviour is checked on a synthetic work area (the logs and leaves of TREEWORK.cpy written to the level and to the work lists): a decorator runs on the work area from a seed and an independent
*> model of the document's text, with its own random stream, applies the same rules to a copy of the window; every cell of the window must agree and the two random streams must be at the same position afterwards
*> (the number of draws is the point of 3.2). The block states placed are checked against the property text of the real block table (the layout of bee_nest, shelf_mushroom, pale_hanging_moss, creaking_heart, podzol).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-4-DECO2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY TREEWORK.
 COPY XORO.
 COPY XORO REPLACING ==XR-STATE== BY ==XR2-STATE== LEADING ==XR-== BY ==X2-==.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/deco2".
 01 WS-PTR                 USAGE POINTER.
 01 WS-A                   PIC X(304640) BASED.
 01 WS-KEY                 PIC X(112).
 01 WS-NAME                PIC X(48).
 01 WS-PAIRS               PIC X(160).
 01 WS-PROPS               PIC X(160).
 01 WS-FTKEY               PIC X(80).
 01 WS-FT                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
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
 01 WS-BLOCK               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-CASE                PIC X(200).
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ONE2                BINARY-LONG VALUE 1.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-LAYOUT              BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-ACTIVE              BINARY-LONG.
 01 WS-DIFF                BINARY-LONG.
 01 WS-TAG-REG             PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112).
 01 WS-TAG-N               BINARY-LONG.
 01 WS-TAG-IDS.
    05 WS-TAG-ID           BINARY-LONG OCCURS 4 TIMES.
 01 WS-TAG-STATUS          BINARY-LONG.
*> block indices (1-based) and states
 01 WS-B-AIR               BINARY-LONG.
 01 WS-B-LOG               BINARY-LONG.
 01 WS-B-LEAF              BINARY-LONG.
 01 WS-B-GRASS             BINARY-LONG.
 01 WS-B-DIRT              BINARY-LONG.
 01 WS-B-STONE             BINARY-LONG.
 01 WS-B-WATER             BINARY-LONG.
 01 WS-B-SHELF             BINARY-LONG.
 01 WS-B-VINE              BINARY-LONG.
 01 WS-S-AIR               BINARY-LONG.
 01 WS-S-LOG               BINARY-LONG.
 01 WS-S-LEAF              BINARY-LONG.
 01 WS-S-GRASS             BINARY-LONG.
 01 WS-S-DIRT              BINARY-LONG.
 01 WS-S-STONE             BINARY-LONG.
 01 WS-S-WATER             BINARY-LONG.
 01 WS-S-PODZOL            BINARY-LONG.
 01 WS-S-SHORT             BINARY-LONG.
 01 WS-S-FERN              BINARY-LONG.
 01 WS-S-NEST              BINARY-LONG.
 01 WS-S-HEART             BINARY-LONG.
 01 WS-S-MOSS              BINARY-LONG.
 01 WS-S-TIP               BINARY-LONG.
*> the window of the model: x 16..31, z 32..47, y 58..80
 01 WS-SNAP.
    05 WS-SN               BINARY-LONG OCCURS 5888 TIMES.
 01 WS-MOD.
    05 WS-MD               BINARY-LONG OCCURS 5888 TIMES.
 01 WS-MX                  BINARY-LONG.
 01 WS-MY                  BINARY-LONG.
 01 WS-MZ                  BINARY-LONG.
 01 WS-MS                  BINARY-LONG.
 01 WS-MB                  BINARY-LONG.
 01 WS-MI                  BINARY-LONG.
 01 WS-MAIR                BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-F1                  FLOAT-LONG VALUE 1.0.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-SIXTH               FLOAT-LONG VALUE 0.6.
 01 WS-QUARTER             FLOAT-LONG VALUE 0.25.
 01 WS-D                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-LIST.
    05 WS-LI               BINARY-LONG OCCURS 3000 TIMES.
 01 WS-NC                  BINARY-LONG.
 01 WS-CAND.
    05 WS-CD OCCURS 64 TIMES.
       10 WS-CD-X          BINARY-LONG.
       10 WS-CD-Y          BINARY-LONG.
       10 WS-CD-Z          BINARY-LONG.
 01 WS-XC.
    05 WS-XCE OCCURS 200 TIMES.
       10 WS-XC-X          BINARY-LONG.
       10 WS-XC-Y          BINARY-LONG.
       10 WS-XC-Z          BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-LOWLOG              BINARY-LONG.
 01 WS-HIGHLOG             BINARY-LONG.
 01 WS-LOWLEAF             BINARY-LONG.
 01 WS-MY2                 BINARY-LONG.
 01 WS-GO                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-FACE-NAMES.
    05 FILLER              PIC X(5) VALUE "north".
    05 FILLER              PIC X(5) VALUE "east".
    05 FILLER              PIC X(5) VALUE "south".
    05 FILLER              PIC X(5) VALUE "west".
 01 WS-FACE-T REDEFINES WS-FACE-NAMES.
    05 WS-FACE-N           PIC X(5) OCCURS 4 TIMES.
 01 WS-FN                  PIC X(5).
 01 WS-PAIR-D.
    05 WS-PD               BINARY-LONG OCCURS 2 TIMES.
 01 WS-FALLEN              BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-AGE-T               PIC 9.
 01 WS-BASE                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-AA                  BINARY-LONG.
 01 WS-BB                  BINARY-LONG.
 01 WS-CCX                 BINARY-LONG.
 01 WS-CCZ                 BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-NLL                 BINARY-LONG.
 01 WS-LAY-Y               BINARY-LONG.
 01 WS-MINX                BINARY-LONG.
 01 WS-MAXX                BINARY-LONG.
 01 WS-MINZ                BINARY-LONG.
 01 WS-MAXZ                BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-SPAN                BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-P1                  BINARY-LONG.
 01 WS-P2                  BINARY-LONG.
 01 WS-EXPECT-TEXT         PIC X(160).
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
     PERFORM LOOK-UP-BLOCKS
     PERFORM PUT-TAGS

*>   the data features compile
     PERFORM COMPILE-CASES

*>   the states the decorators place have the property text of the table
     MOVE "facing=south,honey_level=0" TO WS-EXPECT-TEXT
     MOVE WS-S-NEST TO WS-STATE
     MOVE "35-4§3.3 beehive: the nest state is bee_nest facing south" TO WS-CASE
     PERFORM ASSERT-PROPS
     MOVE "axis=y,creaking_heart_state=dormant,natural=true" TO WS-EXPECT-TEXT
     MOVE WS-S-HEART TO WS-STATE
     MOVE "35-4§3.3 creaking_heart: dormant and natural, the axis is the default y" TO WS-CASE
     PERFORM ASSERT-PROPS
     MOVE "tip=true" TO WS-EXPECT-TEXT
     MOVE WS-S-TIP TO WS-STATE
     MOVE "35-4§3.3 pale_moss: the tip state" TO WS-CASE
     PERFORM ASSERT-PROPS

*>   beehive: with leaves (layout 1), without (layout 2); probability 0 draws once and does nothing
     MOVE "minecraft:d2_beehive" TO WS-FTKEY
     MOVE 1 TO WS-LAYOUT
     PERFORM RUN-SEEDS
     MOVE "35-4§3.3 beehive with leaves: every window cell and the random stream agree with the model" TO WS-CASE
     PERFORM ASSERT-RESULT
     MOVE 2 TO WS-LAYOUT
     PERFORM RUN-SEEDS
     MOVE "35-4§3.3 beehive without leaves: every window cell and the random stream agree with the model" TO WS-CASE
     PERFORM ASSERT-RESULT
     MOVE "minecraft:d2_beehive0" TO WS-FTKEY
     MOVE 1 TO WS-LAYOUT
     PERFORM RUN-SEEDS
     MOVE "35-4§3.2 beehive probability 0: one draw, nothing placed" TO WS-CASE
     PERFORM ASSERT-QUIET

*>   attached_to_leaves
     MOVE "minecraft:d2_leaves" TO WS-FTKEY
     MOVE 1 TO WS-LAYOUT
     PERFORM RUN-SEEDS
     MOVE "35-4§3.3 attached_to_leaves: every window cell and the random stream agree with the model" TO WS-CASE
     PERFORM ASSERT-RESULT

*>   pale_moss with hangers under floating logs
     MOVE "minecraft:d2_pale" TO WS-FTKEY
     MOVE 6 TO WS-LAYOUT
     PERFORM RUN-SEEDS
     MOVE "35-4§3.3 pale_moss: every window cell and the random stream agree with the model" TO WS-CASE
     PERFORM ASSERT-RESULT
     MOVE 1 TO WS-LAYOUT
     PERFORM RUN-SEEDS
     MOVE "35-4§3.3 pale_moss on a trunk standing on the ground: the same" TO WS-CASE
     PERFORM ASSERT-RESULT

*>   creaking_heart in a thick trunk
     MOVE "minecraft:d2_heart" TO WS-FTKEY
     MOVE 3 TO WS-LAYOUT
     PERFORM RUN-SEEDS
     MOVE "35-4§3.3 creaking_heart: every window cell and the random stream agree with the model" TO WS-CASE
     PERFORM ASSERT-RESULT
     MOVE 1 TO WS-LAYOUT
     PERFORM RUN-SEEDS
     MOVE "35-4§3.3 creaking_heart in a thin trunk: no log is surrounded, one draw, nothing placed" TO WS-CASE
     PERFORM ASSERT-RESULT

*>   shelf_mushroom: standing, standing beside water, fallen
     MOVE "minecraft:d2_shelf" TO WS-FTKEY
     MOVE 1 TO WS-LAYOUT
     MOVE 0 TO WS-WATER
     PERFORM RUN-SEEDS
     MOVE "35-4§3.3 shelf_mushroom on a standing tree: every window cell and the random stream agree with the model" TO WS-CASE
     PERFORM ASSERT-RESULT
     MOVE 1 TO WS-WATER
     PERFORM RUN-SEEDS
     MOVE "35-4§3.3 shelf_mushroom beside water: the same" TO WS-CASE
     PERFORM ASSERT-RESULT
     MOVE 0 TO WS-WATER
     MOVE 4 TO WS-LAYOUT
     PERFORM RUN-SEEDS
     MOVE "35-4§3.3 shelf_mushroom on a fallen log: every window cell and the random stream agree with the model" TO WS-CASE
     PERFORM ASSERT-RESULT

*>   alter_ground under a 2 x 2 trunk
     MOVE "minecraft:d2_alter" TO WS-FTKEY
     MOVE 5 TO WS-LAYOUT
     PERFORM RUN-SEEDS
     MOVE "35-4§3.3 alter_ground: every window cell and the random stream agree with the model" TO WS-CASE
     PERFORM ASSERT-RESULT

*>   place_on_ground
     MOVE "minecraft:d2_place" TO WS-FTKEY
     MOVE 5 TO WS-LAYOUT
     PERFORM RUN-SEEDS
     MOVE "35-4§3.3 place_on_ground: every window cell and the random stream agree with the model" TO WS-CASE
     PERFORM ASSERT-RESULT

*>   would_survive of the mangrove propagule (the placed feature of the mangrove): the block below is in supports_mangrove_propagule
     MOVE "minecraft:d2_survive" TO WS-FTKEY
     CALL "FD-GET-PF" USING WS-FTKEY WS-I
     CALL "FD-ENSURE-PF" USING WS-I
     MOVE "35-4§3.3 would_survive of the propagule: the placed feature compiles" TO WS-CASE
     MOVE PF-STATUS(WS-I) TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 9 TO WS-LAYOUT
     MOVE 0 TO WS-WATER
     MOVE 7 TO WS-SEED
     PERFORM NEW-WORLD
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 24 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 40 TO WS-Z
     CALL "FR-PLACE-PF" USING XR-STATE WS-I WS-ZERO WS-X WS-Y WS-Z WS-OK
     MOVE "35-4§3.3 would_survive of the propagule: grass below lets the tree through" TO WS-CASE
     MOVE WS-OK TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 26 TO WS-X
     CALL "FR-PLACE-PF" USING XR-STATE WS-I WS-ZERO WS-X WS-Y WS-Z WS-OK
     MOVE "35-4§3.3 would_survive of the propagule: stone below stops it" TO WS-CASE
     MOVE WS-OK TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 20 TO WS-X
     MOVE 66 TO WS-Y
     CALL "FR-PLACE-PF" USING XR-STATE WS-I WS-ZERO WS-X WS-Y WS-Z WS-OK
     MOVE "35-4§3.3 would_survive of the propagule: air below stops it" TO WS-CASE
     MOVE WS-OK TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN.

 LOOK-UP-BLOCKS.
     MOVE "air" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-AIR
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-AIR
     MOVE "oak_log" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-LOG
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-LOG
     MOVE "oak_leaves" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-LEAF
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-LEAF
     MOVE "grass_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-GRASS
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-GRASS
     MOVE "dirt" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-DIRT
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-DIRT
     MOVE "stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-STONE
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-STONE
     MOVE "water" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-WATER
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-WATER
     MOVE "shelf_mushroom" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-SHELF
     MOVE "vine" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-VINE
     MOVE "podzol" TO WS-KEY
     MOVE "snowy=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-S-PODZOL
     MOVE "short_grass" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-S-SHORT
     MOVE "fern" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-S-FERN
     MOVE "bee_nest" TO WS-KEY
     MOVE "facing=south,honey_level=0" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-S-NEST
     MOVE "creaking_heart" TO WS-KEY
     MOVE "axis=y,creaking_heart_state=dormant,natural=true" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-S-HEART
     MOVE "pale_hanging_moss" TO WS-KEY
     MOVE "tip=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-S-MOSS
     MOVE "tip=true" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-S-TIP
     .
 PUT-TAGS.
     MOVE 1 TO WS-TAG-N
     COMPUTE WS-TAG-ID(1) = WS-B-LOG - 1
     MOVE "minecraft:logs" TO WS-TAG
     CALL "TAG-PUT" USING WS-TAG-REG WS-TAG WS-TAG-N WS-TAG-IDS WS-TAG-STATUS
     COMPUTE WS-TAG-ID(1) = WS-B-AIR - 1
     MOVE "minecraft:replaceable_by_trees" TO WS-TAG
     CALL "TAG-PUT" USING WS-TAG-REG WS-TAG WS-TAG-N WS-TAG-IDS WS-TAG-STATUS
     COMPUTE WS-TAG-ID(1) = WS-B-DIRT - 1
     MOVE "minecraft:cannot_replace_below_tree_trunk" TO WS-TAG
     CALL "TAG-PUT" USING WS-TAG-REG WS-TAG WS-TAG-N WS-TAG-IDS WS-TAG-STATUS
     MOVE 2 TO WS-TAG-N
     COMPUTE WS-TAG-ID(1) = WS-B-DIRT - 1
     COMPUTE WS-TAG-ID(2) = WS-B-GRASS - 1
     MOVE "minecraft:beneath_tree_podzol_replaceable" TO WS-TAG
     CALL "TAG-PUT" USING WS-TAG-REG WS-TAG WS-TAG-N WS-TAG-IDS WS-TAG-STATUS
     MOVE "minecraft:supports_mangrove_propagule" TO WS-TAG
     CALL "TAG-PUT" USING WS-TAG-REG WS-TAG WS-TAG-N WS-TAG-IDS WS-TAG-STATUS
     .
 COMPILE-CASES.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         EVALUATE WS-I
             WHEN 1 MOVE "minecraft:d2_beehive" TO WS-FTKEY
             WHEN 2 MOVE "minecraft:d2_leaves" TO WS-FTKEY
             WHEN 3 MOVE "minecraft:d2_pale" TO WS-FTKEY
             WHEN 4 MOVE "minecraft:d2_heart" TO WS-FTKEY
             WHEN 5 MOVE "minecraft:d2_shelf" TO WS-FTKEY
             WHEN 6 MOVE "minecraft:d2_alter" TO WS-FTKEY
             WHEN 7 MOVE "minecraft:d2_place" TO WS-FTKEY
             WHEN 8 MOVE "minecraft:d2_place_default" TO WS-FTKEY
             WHEN 9 MOVE "minecraft:d2_place_bad" TO WS-FTKEY
             WHEN 10 MOVE "minecraft:d2_leaves_bad" TO WS-FTKEY
             WHEN OTHER MOVE "minecraft:d2_beehive0" TO WS-FTKEY
         END-EVALUATE
         CALL "FD-GET-FT" USING WS-FTKEY WS-FT
         CALL "FD-ENSURE-FT" USING WS-FT
         MOVE FT-A(WS-FT) TO WS-ROW
         MOVE SPACES TO WS-CASE
         STRING "35-4§3: the data feature " FUNCTION TRIM(WS-FTKEY) " compiles as a tree (51) or is unsupported (-1)" DELIMITED BY SIZE INTO WS-CASE
         MOVE FT-TYPE(WS-FT) TO WS-OBS
         IF WS-I = 9 OR WS-I = 10
             MOVE -1 TO WS-EXP
         ELSE
             MOVE 51 TO WS-EXP
         END-IF
         PERFORM ASSERT-N
         IF WS-I < 9 OR WS-I = 11
             MOVE SPACES TO WS-CASE
             STRING "35-4§3: the decorator kind of " FUNCTION TRIM(WS-FTKEY) DELIMITED BY SIZE INTO WS-CASE
             MOVE TD-KIND(WS-ROW, 1) TO WS-OBS
             EVALUATE WS-I
                 WHEN 1 MOVE 5 TO WS-EXP
                 WHEN 2 MOVE 9 TO WS-EXP
                 WHEN 3 MOVE 10 TO WS-EXP
                 WHEN 4 MOVE 11 TO WS-EXP
                 WHEN 5 MOVE 8 TO WS-EXP
                 WHEN 6 MOVE 6 TO WS-EXP
                 WHEN OTHER MOVE 7 TO WS-EXP
             END-EVALUATE
             IF WS-I = 11
                 MOVE 5 TO WS-EXP
             END-IF
             PERFORM ASSERT-N
         END-IF
     END-PERFORM
     MOVE "minecraft:d2_place" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     MOVE FT-A(WS-FT) TO WS-ROW
     MOVE "35-4§3.3 place_on_ground: tries 40, radius 4 and height 2 are read" TO WS-CASE
     COMPUTE WS-OBS = TD-I(WS-ROW, 1, 1) * 10000 + TD-I(WS-ROW, 1, 2) * 100 + TD-I(WS-ROW, 1, 3)
     MOVE 400402 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:d2_place_default" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     MOVE FT-A(WS-FT) TO WS-ROW
     MOVE "35-4§3.3 place_on_ground: the defaults are tries 128, radius 2, height 1" TO WS-CASE
     COMPUTE WS-OBS = TD-I(WS-ROW, 1, 1) * 10000 + TD-I(WS-ROW, 1, 2) * 100 + TD-I(WS-ROW, 1, 3)
     MOVE 1280201 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:d2_leaves" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     MOVE FT-A(WS-FT) TO WS-ROW
     MOVE "35-4§3.3 attached_to_leaves: exclusion radii 1 and 0, 2 empty blocks and one direction (down) are read" TO WS-CASE
     COMPUTE WS-OBS = TD-I(WS-ROW, 1, 1) * 1000 + TD-I(WS-ROW, 1, 2) * 100 + TD-I(WS-ROW, 1, 3) * 10 + TD-ND(WS-ROW, 1)
     MOVE 1021 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:d2_pale" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     MOVE FT-A(WS-FT) TO WS-ROW
     MOVE "35-4§3.3 pale_moss: the three probabilities are read (leaves 0.5, trunk 0.6, ground 0)" TO WS-CASE
     COMPUTE WS-OBS ROUNDED = TD-PROB(WS-ROW, 1) * 100 + TD-F2(WS-ROW, 1) * 10 + TD-F3(WS-ROW, 1)
     MOVE 56 TO WS-EXP
     PERFORM ASSERT-N
     .
*> RUN-SEEDS: for 24 seeds the decorator of the feature WS-FTKEY on the layout WS-LAYOUT, the model on a copy; WS-BAD the seeds where a cell or the stream differs, WS-ACTIVE the cells changed over all seeds
 RUN-SEEDS.
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE FT-A(WS-FT) TO WS-ROW
     MOVE 0 TO WS-BAD WS-ACTIVE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 24
         MOVE WS-I TO WS-SEED
         PERFORM NEW-WORLD
         PERFORM SNAPSHOT
         CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
         CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
         MOVE TR-LOGS-START(WS-ROW) TO TW-LOGS-START
         MOVE TR-LOGS-N(WS-ROW) TO TW-LOGS-N
         CALL "FR-DECORATE" USING XR-STATE WS-ROW WS-ONE WS-ONE2
         PERFORM MODEL-RUN
         MOVE 0 TO WS-DIFF
         PERFORM COMPARE-WINDOW
         MOVE 1000000 TO WS-N
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-P1
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-N WS-P2
         IF WS-DIFF > 0 OR WS-P1 NOT = WS-P2
             ADD 1 TO WS-BAD
         END-IF
         PERFORM COUNT-CHANGES
     END-PERFORM
     .
 ASSERT-RESULT.
     PERFORM ASSERT-RESULT-BAD
     .
 ASSERT-RESULT-BAD.
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§3 the run changed some cells over the seeds (the model is not trivially empty)" TO WS-CASE
     IF WS-ACTIVE > 0
         MOVE 1 TO WS-OBS
     ELSE
         MOVE 0 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     IF FUNCTION TRIM(WS-FTKEY) = "minecraft:d2_heart" AND WS-LAYOUT = 1
         MOVE 0 TO WS-EXP
     END-IF
     PERFORM ASSERT-N
     .
 ASSERT-QUIET.
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-4§3.2 probability 0: no cell changes over the seeds" TO WS-CASE
     MOVE WS-ACTIVE TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     .
 ASSERT-PROPS.
     MOVE SPACES TO WS-PROPS
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS
     MOVE 0 TO WS-OBS
     IF WS-PROPS = WS-EXPECT-TEXT
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     .
*> NEW-WORLD: floor of grass at y = 62 over stone, a stone patch at x 26..27 (y 62), and the tree of WS-LAYOUT (level and work lists)
 NEW-WORLD.
     SET ADDRESS OF WS-A TO WS-PTR
     MOVE LOW-VALUES TO WS-A
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE 58 TO WS-Y0
     MOVE 61 TO WS-Y1
     MOVE "stone" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 62 TO WS-Y0
     MOVE 62 TO WS-Y1
     MOVE "grass_block" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 26 TO WS-X0
     MOVE 27 TO WS-X1
     MOVE "stone" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 0 TO TW-NLOG TW-NLEAF TW-NRL
     EVALUATE WS-LAYOUT
         WHEN 1
             MOVE 63 TO WS-LAY-Y
             PERFORM THIN-TRUNK
             PERFORM LEAVES
         WHEN 2
             MOVE 63 TO WS-LAY-Y
             PERFORM THIN-TRUNK
         WHEN 3
             PERFORM THICK-TRUNK
         WHEN 4
             PERFORM FALLEN-LOG
         WHEN 5
             PERFORM SQUARE-TRUNK
         WHEN 9
             CONTINUE
         WHEN OTHER
             MOVE 66 TO WS-LAY-Y
             PERFORM THIN-TRUNK
             PERFORM LEAVES
     END-EVALUATE
     IF WS-WATER = 1
         MOVE "water" TO WS-KEY
         MOVE 25 TO WS-X
         MOVE 65 TO WS-Y
         MOVE 40 TO WS-Z
         PERFORM PUT-AT
         MOVE 26 TO WS-X
         MOVE 66 TO WS-Y
         PERFORM PUT-AT
     END-IF
     .
*> THIN-TRUNK: logs (24, y, 40) from WS-LAY-Y to 70
 THIN-TRUNK.
     PERFORM VARYING WS-Y FROM WS-LAY-Y BY 1 UNTIL WS-Y > 70
         MOVE 24 TO WS-X
         MOVE 40 TO WS-Z
         PERFORM ADD-LOG
     END-PERFORM
     .
 THICK-TRUNK.
     PERFORM VARYING WS-Y FROM 63 BY 1 UNTIL WS-Y > 67
         PERFORM VARYING WS-X FROM 23 BY 1 UNTIL WS-X > 25
             PERFORM VARYING WS-Z FROM 39 BY 1 UNTIL WS-Z > 41
                 PERFORM ADD-LOG
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 SQUARE-TRUNK.
     PERFORM VARYING WS-Y FROM 63 BY 1 UNTIL WS-Y > 66
         PERFORM VARYING WS-X FROM 24 BY 1 UNTIL WS-X > 25
             PERFORM VARYING WS-Z FROM 40 BY 1 UNTIL WS-Z > 41
                 PERFORM ADD-LOG
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 FALLEN-LOG.
     MOVE 63 TO WS-Y
     MOVE 40 TO WS-Z
     PERFORM VARYING WS-X FROM 21 BY 1 UNTIL WS-X > 27
         PERFORM ADD-LOG
     END-PERFORM
     .
 ADD-LOG.
     MOVE "oak_log" TO WS-KEY
     PERFORM PUT-AT
     ADD 1 TO TW-NLOG
     MOVE WS-X TO TW-LOG-X(TW-NLOG)
     MOVE WS-Y TO TW-LOG-Y(TW-NLOG)
     MOVE WS-Z TO TW-LOG-Z(TW-NLOG)
     MOVE 0 TO TW-LOG-A(TW-NLOG)
     .
*> LEAVES: layers 68 and 69 radius 2, 70 and 71 radius 1 round (24, 40), where no log stands
 LEAVES.
     PERFORM VARYING WS-Y FROM 68 BY 1 UNTIL WS-Y > 71
         IF WS-Y <= 69
             MOVE 2 TO WS-R
         ELSE
             MOVE 1 TO WS-R
         END-IF
         COMPUTE WS-X0 = 24 - WS-R
         COMPUTE WS-X1 = 24 + WS-R
         PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1
             PERFORM VARYING WS-Z FROM 38 BY 1 UNTIL WS-Z > 42
                 IF WS-Z >= 40 - WS-R AND WS-Z <= 40 + WS-R
                     IF NOT (WS-X = 24 AND WS-Z = 40 AND WS-Y <= 70)
                         MOVE "oak_leaves" TO WS-KEY
                         PERFORM PUT-AT
                         ADD 1 TO TW-NLEAF
                         MOVE WS-X TO TW-LEAF-X(TW-NLEAF)
                         MOVE WS-Y TO TW-LEAF-Y(TW-NLEAF)
                         MOVE WS-Z TO TW-LEAF-Z(TW-NLEAF)
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> the window: index of (x, y, z)
 WINDOW-INDEX.
     COMPUTE WS-MI = ((WS-MX - 16) * 16 + (WS-MZ - 32)) * 23 + (WS-MY - 58) + 1
     .
 SNAPSHOT.
     PERFORM VARYING WS-MX FROM 16 BY 1 UNTIL WS-MX > 31
         PERFORM VARYING WS-MZ FROM 32 BY 1 UNTIL WS-MZ > 47
             PERFORM VARYING WS-MY FROM 58 BY 1 UNTIL WS-MY > 80
                 CALL "FL-GET-STATE" USING WS-MX WS-MY WS-MZ WS-STATE
                 PERFORM WINDOW-INDEX
                 MOVE WS-STATE TO WS-SN(WS-MI)
                 MOVE WS-STATE TO WS-MD(WS-MI)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 COMPARE-WINDOW.
     PERFORM VARYING WS-MX FROM 16 BY 1 UNTIL WS-MX > 31
         PERFORM VARYING WS-MZ FROM 32 BY 1 UNTIL WS-MZ > 47
             PERFORM VARYING WS-MY FROM 58 BY 1 UNTIL WS-MY > 80
                 CALL "FL-GET-STATE" USING WS-MX WS-MY WS-MZ WS-STATE
                 PERFORM WINDOW-INDEX
                 IF WS-MD(WS-MI) NOT = WS-STATE
                     ADD 1 TO WS-DIFF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 COUNT-CHANGES.
     PERFORM VARYING WS-MI FROM 1 BY 1 UNTIL WS-MI > 5888
         IF WS-MD(WS-MI) NOT = WS-SN(WS-MI)
             ADD 1 TO WS-ACTIVE
         END-IF
     END-PERFORM
     .
*> model cell access: WS-MX, WS-MY, WS-MZ; MGET gives WS-MS (the state, air outside the window) and WS-MB (its block), MAIR WS-MAIR 1 when it is air; MPUT sets WS-MS (ignored outside the window)
 MGET.
     MOVE WS-S-AIR TO WS-MS
     IF WS-MX >= 16 AND WS-MX <= 31 AND WS-MZ >= 32 AND WS-MZ <= 47 AND WS-MY >= 58 AND WS-MY <= 80
         PERFORM WINDOW-INDEX
         MOVE WS-MD(WS-MI) TO WS-MS
     END-IF
     COMPUTE WS-MB = CB-S-BLOCK(WS-MS + 1) + 1
     MOVE 0 TO WS-MAIR
     IF WS-MB = WS-B-AIR
         MOVE 1 TO WS-MAIR
     END-IF
     .
 MPUT.
     IF WS-MX >= 16 AND WS-MX <= 31 AND WS-MZ >= 32 AND WS-MZ <= 47 AND WS-MY >= 58 AND WS-MY <= 80
         PERFORM WINDOW-INDEX
         MOVE WS-MS TO WS-MD(WS-MI)
     END-IF
     .
*> MDRAW N: WS-D = nextInt(WS-N) of the model stream
 MDRAW.
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-N WS-D
     .
 MFLOAT.
     CALL "WGR-NEXT-FLOAT" USING XR2-STATE WS-F
     .
*> MSHUFFLE: Collections.shuffle of WS-LI(1 .. WS-NC): for i = size down to 2 swap(i - 1, nextInt(i))
 MSHUFFLE.
     PERFORM VARYING WS-Q FROM WS-NC BY -1 UNTIL WS-Q < 2
         MOVE WS-Q TO WS-N
         PERFORM MDRAW
         MOVE WS-LI(WS-D + 1) TO WS-T
         MOVE WS-LI(WS-Q) TO WS-LI(WS-D + 1)
         MOVE WS-T TO WS-LI(WS-Q)
     END-PERFORM
     .
 MODEL-RUN.
     EVALUATE FUNCTION TRIM(WS-FTKEY)
         WHEN "minecraft:d2_beehive"
             PERFORM M-BEEHIVE
         WHEN "minecraft:d2_beehive0"
             PERFORM MFLOAT
         WHEN "minecraft:d2_leaves"
             PERFORM M-LEAVES
         WHEN "minecraft:d2_pale"
             PERFORM M-PALE
         WHEN "minecraft:d2_heart"
             PERFORM M-HEART
         WHEN "minecraft:d2_shelf"
             PERFORM M-SHELF
         WHEN "minecraft:d2_alter"
             PERFORM M-ALTER
         WHEN "minecraft:d2_place"
             PERFORM M-PLACE
     END-EVALUATE
     .
 M-BEEHIVE.
     IF TW-NLOG > 0
         PERFORM MFLOAT
         IF WS-F < WS-F1
             MOVE 999 TO WS-LOWLOG
             MOVE -999 TO WS-HIGHLOG
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > TW-NLOG
                 IF TW-LOG-Y(WS-K) < WS-LOWLOG
                     MOVE TW-LOG-Y(WS-K) TO WS-LOWLOG
                 END-IF
                 IF TW-LOG-Y(WS-K) > WS-HIGHLOG
                     MOVE TW-LOG-Y(WS-K) TO WS-HIGHLOG
                 END-IF
             END-PERFORM
             IF TW-NLEAF > 0
                 MOVE 999 TO WS-LOWLEAF
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > TW-NLEAF
                     IF TW-LEAF-Y(WS-K) < WS-LOWLEAF
                         MOVE TW-LEAF-Y(WS-K) TO WS-LOWLEAF
                     END-IF
                 END-PERFORM
                 COMPUTE WS-MY2 = WS-LOWLEAF - 1
                 IF WS-LOWLOG + 1 > WS-MY2
                     COMPUTE WS-MY2 = WS-LOWLOG + 1
                 END-IF
             ELSE
                 MOVE 3 TO WS-N
                 PERFORM MDRAW
                 COMPUTE WS-MY2 = WS-LOWLOG + 1 + WS-D
                 IF WS-HIGHLOG < WS-MY2
                     MOVE WS-HIGHLOG TO WS-MY2
                 END-IF
             END-IF
             MOVE 0 TO WS-NC
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > TW-NLOG
                 IF TW-LOG-Y(WS-K) = WS-MY2
                     ADD 1 TO WS-NC
                     COMPUTE WS-CD-X(WS-NC) = TW-LOG-X(WS-K) + 1
                     MOVE TW-LOG-Z(WS-K) TO WS-CD-Z(WS-NC)
                     ADD 1 TO WS-NC
                     MOVE TW-LOG-X(WS-K) TO WS-CD-X(WS-NC)
                     COMPUTE WS-CD-Z(WS-NC) = TW-LOG-Z(WS-K) + 1
                     ADD 1 TO WS-NC
                     COMPUTE WS-CD-X(WS-NC) = TW-LOG-X(WS-K) - 1
                     MOVE TW-LOG-Z(WS-K) TO WS-CD-Z(WS-NC)
                 END-IF
             END-PERFORM
             IF WS-NC > 0
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-NC
                     MOVE WS-K TO WS-LI(WS-K)
                 END-PERFORM
                 PERFORM MSHUFFLE
                 MOVE 0 TO WS-DONE
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-NC OR WS-DONE = 1
                     MOVE WS-LI(WS-K) TO WS-J
                     MOVE WS-CD-X(WS-J) TO WS-MX
                     MOVE WS-MY2 TO WS-MY
                     MOVE WS-CD-Z(WS-J) TO WS-MZ
                     PERFORM MGET
                     MOVE WS-MAIR TO WS-GO
                     ADD 1 TO WS-MZ
                     PERFORM MGET
                     IF WS-GO = 1 AND WS-MAIR = 1
                         MOVE 1 TO WS-DONE
                         MOVE WS-CD-Z(WS-J) TO WS-MZ
                         MOVE WS-S-NEST TO WS-MS
                         PERFORM MPUT
                         MOVE 2 TO WS-N
                         PERFORM MDRAW
                         COMPUTE WS-T = 2 + WS-D
                         PERFORM WS-T TIMES
                             MOVE 599 TO WS-N
                             PERFORM MDRAW
                         END-PERFORM
                     END-IF
                 END-PERFORM
             END-IF
         END-IF
     END-IF
     .
*> attached_to_leaves: probability 0.5, directions [down], exclusion radii 1 and 0, 2 empty blocks, the propagule provider (age = nextInt(5))
 M-LEAVES.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > TW-NLEAF
         MOVE WS-K TO WS-LI(WS-K)
     END-PERFORM
     MOVE TW-NLEAF TO WS-NC
     PERFORM MSHUFFLE
     MOVE 0 TO WS-NX
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > TW-NLEAF
         MOVE WS-LI(WS-K) TO WS-J
         MOVE 1 TO WS-N
         PERFORM MDRAW
         MOVE TW-LEAF-X(WS-J) TO WS-PX
         COMPUTE WS-PY = TW-LEAF-Y(WS-J) - 1
         MOVE TW-LEAF-Z(WS-J) TO WS-PZ
         MOVE 0 TO WS-HIT
         PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > WS-NX
             IF WS-PX >= WS-XC-X(WS-Q) - 1 AND WS-PX <= WS-XC-X(WS-Q) + 1
                 AND WS-PY = WS-XC-Y(WS-Q)
                 AND WS-PZ >= WS-XC-Z(WS-Q) - 1 AND WS-PZ <= WS-XC-Z(WS-Q) + 1
                 MOVE 1 TO WS-HIT
             END-IF
         END-PERFORM
         IF WS-HIT = 0
             PERFORM MFLOAT
             IF WS-F < WS-HALF
                 MOVE WS-PX TO WS-MX
                 MOVE WS-PY TO WS-MY
                 MOVE WS-PZ TO WS-MZ
                 PERFORM MGET
                 MOVE WS-MAIR TO WS-GO
                 COMPUTE WS-MY = WS-PY - 1
                 PERFORM MGET
                 IF WS-GO = 1 AND WS-MAIR = 1
                     ADD 1 TO WS-NX
                     MOVE WS-PX TO WS-XC-X(WS-NX)
                     MOVE WS-PY TO WS-XC-Y(WS-NX)
                     MOVE WS-PZ TO WS-XC-Z(WS-NX)
                     MOVE 5 TO WS-N
                     PERFORM MDRAW
                     MOVE WS-D TO WS-AGE-T
                     MOVE SPACES TO WS-PAIRS
                     STRING "age=" WS-AGE-T ",hanging=true,stage=0,waterlogged=false" DELIMITED BY SIZE INTO WS-PAIRS
                     MOVE "mangrove_propagule" TO WS-KEY
                     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-MS
                     MOVE WS-PX TO WS-MX
                     MOVE WS-PY TO WS-MY
                     MOVE WS-PZ TO WS-MZ
                     PERFORM MPUT
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     .
*> pale_moss (0.5, 0.6, ground 0): the logs shuffled, the ground draw, the trunk hangers, the leaf hangers
 M-PALE.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > TW-NLOG
         MOVE WS-K TO WS-LI(WS-K)
     END-PERFORM
     MOVE TW-NLOG TO WS-NC
     PERFORM MSHUFFLE
     PERFORM MFLOAT
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > TW-NLOG
         PERFORM MFLOAT
         MOVE TW-LOG-X(WS-K) TO WS-PX
         COMPUTE WS-PY = TW-LOG-Y(WS-K) - 1
         MOVE TW-LOG-Z(WS-K) TO WS-PZ
         MOVE WS-PX TO WS-MX
         MOVE WS-PY TO WS-MY
         MOVE WS-PZ TO WS-MZ
         PERFORM MGET
         IF WS-F < WS-SIXTH AND WS-MAIR = 1
             PERFORM M-HANGER
         END-IF
     END-PERFORM
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > TW-NLEAF
         PERFORM MFLOAT
         MOVE TW-LEAF-X(WS-K) TO WS-PX
         COMPUTE WS-PY = TW-LEAF-Y(WS-K) - 1
         MOVE TW-LEAF-Z(WS-K) TO WS-PZ
         MOVE WS-PX TO WS-MX
         MOVE WS-PY TO WS-MY
         MOVE WS-PZ TO WS-MZ
         PERFORM MGET
         IF WS-F < WS-HALF AND WS-MAIR = 1
             PERFORM M-HANGER
         END-IF
     END-PERFORM
     .
*> the moss hanger at (WS-PX, WS-PY, WS-PZ)
 M-HANGER.
     MOVE 0 TO WS-STOP
     PERFORM UNTIL WS-STOP = 1
         MOVE WS-PX TO WS-MX
         COMPUTE WS-MY = WS-PY - 1
         MOVE WS-PZ TO WS-MZ
         PERFORM MGET
         IF WS-MAIR = 0
             MOVE 1 TO WS-STOP
         ELSE
             PERFORM MFLOAT
             IF WS-F < WS-HALF
                 MOVE 1 TO WS-STOP
             ELSE
                 MOVE WS-PY TO WS-MY
                 MOVE WS-S-MOSS TO WS-MS
                 PERFORM MPUT
                 SUBTRACT 1 FROM WS-PY
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-PX TO WS-MX
     MOVE WS-PY TO WS-MY
     MOVE WS-PZ TO WS-MZ
     MOVE WS-S-TIP TO WS-MS
     PERFORM MPUT
     .
*> creaking_heart (probability 1): logs shuffled, the first with six log neighbours becomes the heart
 M-HEART.
     IF TW-NLOG > 0
         PERFORM MFLOAT
         IF WS-F < WS-F1
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > TW-NLOG
                 MOVE WS-K TO WS-LI(WS-K)
             END-PERFORM
             MOVE TW-NLOG TO WS-NC
             PERFORM MSHUFFLE
             MOVE 0 TO WS-DONE
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-NC OR WS-DONE = 1
                 MOVE WS-LI(WS-K) TO WS-J
                 MOVE 0 TO WS-N
                 MOVE TW-LOG-X(WS-J) TO WS-MX
                 MOVE TW-LOG-Y(WS-J) TO WS-MY
                 MOVE TW-LOG-Z(WS-J) TO WS-MZ
                 PERFORM M-LOG-NEIGHBOURS
                 IF WS-N = 6
                     MOVE 1 TO WS-DONE
                     MOVE WS-S-HEART TO WS-MS
                     MOVE TW-LOG-X(WS-J) TO WS-MX
                     MOVE TW-LOG-Y(WS-J) TO WS-MY
                     MOVE TW-LOG-Z(WS-J) TO WS-MZ
                     PERFORM MPUT
                 END-IF
             END-PERFORM
         END-IF
     END-IF
     .
*> WS-N = how many of the six neighbours of (WS-MX, WS-MY, WS-MZ) are oak logs
 M-LOG-NEIGHBOURS.
     MOVE WS-MX TO WS-QX
     MOVE WS-MY TO WS-QY
     MOVE WS-MZ TO WS-QZ
     MOVE 0 TO WS-N
     PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > 6
         MOVE WS-QX TO WS-MX
         MOVE WS-QY TO WS-MY
         MOVE WS-QZ TO WS-MZ
         EVALUATE WS-Q
             WHEN 1 SUBTRACT 1 FROM WS-MY
             WHEN 2 ADD 1 TO WS-MY
             WHEN 3 SUBTRACT 1 FROM WS-MZ
             WHEN 4 ADD 1 TO WS-MZ
             WHEN 5 SUBTRACT 1 FROM WS-MX
             WHEN OTHER ADD 1 TO WS-MX
         END-EVALUATE
         PERFORM MGET
         IF WS-MB = WS-B-LOG
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE WS-QX TO WS-MX
     MOVE WS-QY TO WS-MY
     MOVE WS-QZ TO WS-MZ
     .
*> shelf_mushroom (probability 1)
 M-SHELF.
     IF TW-NLOG > 0
         PERFORM MFLOAT
         IF WS-F < WS-F1
             MOVE 0 TO WS-FALLEN
             IF TW-LOG-Y(1) = TW-LOG-Y(TW-NLOG)
                 MOVE 1 TO WS-FALLEN
             END-IF
             IF WS-FALLEN = 1
                 IF TW-LOG-X(1) NOT = TW-LOG-X(TW-NLOG)
                     MOVE 0 TO WS-PD(1)
                     MOVE 2 TO WS-PD(2)
                 ELSE
                     MOVE 1 TO WS-PD(1)
                     MOVE 3 TO WS-PD(2)
                 END-IF
             ELSE
                 MOVE 4 TO WS-N
                 PERFORM MDRAW
                 MOVE WS-D TO WS-PD(1)
                 COMPUTE WS-PD(2) = WS-D + 1
                 IF WS-PD(2) = 4
                     MOVE 0 TO WS-PD(2)
                 END-IF
             END-IF
             MOVE TW-LOG-Y(1) TO WS-BASE
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > TW-NLOG
                 IF WS-FALLEN = 1 OR (TW-LOG-Y(WS-K) - WS-BASE >= 1 AND TW-LOG-Y(WS-K) - WS-BASE <= 4)
                     MOVE 0 TO WS-DONE
                     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 2 OR WS-DONE = 1
                         PERFORM MFLOAT
                         IF WS-F <= WS-QUARTER
                             PERFORM M-SHELF-TRY
                             IF WS-FALLEN = 0 AND WS-HIT = 1
                                 MOVE 1 TO WS-DONE
                             END-IF
                         END-IF
                     END-PERFORM
                 END-IF
             END-PERFORM
         END-IF
     END-IF
     .
*> the attempt of log WS-K, direction WS-PD(WS-J); WS-HIT 1 when a shelf went in
 M-SHELF-TRY.
     MOVE 0 TO WS-HIT
     MOVE WS-PD(WS-J) TO WS-D
     EVALUATE WS-D
         WHEN 0
             MOVE 0 TO WS-DX
             MOVE -1 TO WS-DZ
         WHEN 1
             MOVE 1 TO WS-DX
             MOVE 0 TO WS-DZ
         WHEN 2
             MOVE 0 TO WS-DX
             MOVE 1 TO WS-DZ
         WHEN OTHER
             MOVE -1 TO WS-DX
             MOVE 0 TO WS-DZ
     END-EVALUATE
     COMPUTE WS-PX = TW-LOG-X(WS-K) + WS-DX
     MOVE TW-LOG-Y(WS-K) TO WS-PY
     COMPUTE WS-PZ = TW-LOG-Z(WS-K) + WS-DZ
*>   shelf-replaceable: air or replaceable, and no water at the cell or its four neighbours
     MOVE WS-PX TO WS-MX
     MOVE WS-PY TO WS-MY
     MOVE WS-PZ TO WS-MZ
     PERFORM MGET
     MOVE 0 TO WS-GO
     IF WS-MAIR = 1 OR CB-REPLACEABLE(WS-MB) = 1
         MOVE 1 TO WS-GO
     END-IF
     MOVE WS-PX TO WS-QX
     MOVE WS-PZ TO WS-QZ
     PERFORM M-WATER-NEAR
     IF WS-GO = 1 AND WS-N = 0
*>       the blocked rule: standing - a shelf below the cell; fallen - a shelf beside the cell or the log
         MOVE 0 TO WS-C
         IF WS-FALLEN = 0
             MOVE WS-PX TO WS-MX
             COMPUTE WS-MY = WS-PY - 1
             MOVE WS-PZ TO WS-MZ
             PERFORM MGET
             IF WS-MB = WS-B-SHELF
                 MOVE 1 TO WS-C
             END-IF
         ELSE
             MOVE WS-PX TO WS-QX
             MOVE WS-PZ TO WS-QZ
             PERFORM M-SHELF-NEAR
             IF WS-N > 0
                 MOVE 1 TO WS-C
             END-IF
             MOVE TW-LOG-X(WS-K) TO WS-QX
             MOVE TW-LOG-Z(WS-K) TO WS-QZ
             PERFORM M-SHELF-NEAR
             IF WS-N > 0
                 MOVE 1 TO WS-C
             END-IF
         END-IF
         IF WS-C = 0
             MOVE 2 TO WS-N
             PERFORM MDRAW
             MOVE WS-D TO WS-AGE
             MOVE WS-PD(WS-J) TO WS-D
             MOVE WS-FACE-N(WS-D + 1) TO WS-FN
             MOVE WS-AGE TO WS-AGE-T
             MOVE SPACES TO WS-PAIRS
             STRING "age=" WS-AGE-T ",facing=" FUNCTION TRIM(WS-FN) DELIMITED BY SIZE INTO WS-PAIRS
             MOVE "shelf_mushroom" TO WS-KEY
             CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-MS
             MOVE WS-PX TO WS-MX
             MOVE WS-PY TO WS-MY
             MOVE WS-PZ TO WS-MZ
             PERFORM MPUT
             MOVE 1 TO WS-HIT
         END-IF
     END-IF
     .
*> WS-N = the water cells among (WS-QX, WS-PY, WS-QZ) and its four horizontal neighbours
 M-WATER-NEAR.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-Q FROM 0 BY 1 UNTIL WS-Q > 4
         MOVE WS-QX TO WS-MX
         MOVE WS-PY TO WS-MY
         MOVE WS-QZ TO WS-MZ
         EVALUATE WS-Q
             WHEN 1 ADD 1 TO WS-MX
             WHEN 2 SUBTRACT 1 FROM WS-MX
             WHEN 3 ADD 1 TO WS-MZ
             WHEN 4 SUBTRACT 1 FROM WS-MZ
         END-EVALUATE
         PERFORM MGET
         IF WS-MB = WS-B-WATER
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     .
*> WS-N = the shelf_mushroom cells among the four horizontal neighbours of (WS-QX, WS-PY, WS-QZ)
 M-SHELF-NEAR.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > 4
         MOVE WS-QX TO WS-MX
         MOVE WS-PY TO WS-MY
         MOVE WS-QZ TO WS-MZ
         EVALUATE WS-Q
             WHEN 1 ADD 1 TO WS-MX
             WHEN 2 SUBTRACT 1 FROM WS-MX
             WHEN 3 ADD 1 TO WS-MZ
             WHEN OTHER SUBTRACT 1 FROM WS-MZ
         END-EVALUATE
         PERFORM MGET
         IF WS-MB = WS-B-SHELF
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     .
*> alter_ground with the podzol provider: the lowest layer of the logs (layout 5: y 63)
 M-ALTER.
     MOVE 0 TO WS-NLL
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > TW-NLOG
         IF TW-LOG-Y(WS-K) = 63
             ADD 1 TO WS-NLL
             MOVE WS-K TO WS-LI(WS-NLL)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-NLL
         MOVE WS-LI(WS-K) TO WS-J
         PERFORM VARYING WS-C FROM 0 BY 1 UNTIL WS-C > 3
             IF WS-C = 0 OR WS-C = 2
                 COMPUTE WS-CCX = TW-LOG-X(WS-J) - 1
             ELSE
                 COMPUTE WS-CCX = TW-LOG-X(WS-J) + 2
             END-IF
             IF WS-C < 2
                 COMPUTE WS-CCZ = TW-LOG-Z(WS-J) - 1
             ELSE
                 COMPUTE WS-CCZ = TW-LOG-Z(WS-J) + 2
             END-IF
             PERFORM M-CIRCLE
         END-PERFORM
         PERFORM 5 TIMES
             MOVE 64 TO WS-N
             PERFORM MDRAW
             COMPUTE WS-AA = FUNCTION MOD(WS-D, 8)
             COMPUTE WS-BB = (WS-D - WS-AA) / 8
             IF WS-AA = 0 OR WS-AA = 7 OR WS-BB = 0 OR WS-BB = 7
                 COMPUTE WS-CCX = TW-LOG-X(WS-J) + WS-AA - 3
                 COMPUTE WS-CCZ = TW-LOG-Z(WS-J) + WS-BB - 3
                 PERFORM M-CIRCLE
             END-IF
         END-PERFORM
     END-PERFORM
     .
 M-CIRCLE.
     PERFORM VARYING WS-DX FROM -2 BY 1 UNTIL WS-DX > 2
         PERFORM VARYING WS-DZ FROM -2 BY 1 UNTIL WS-DZ > 2
             IF FUNCTION ABS(WS-DX) + FUNCTION ABS(WS-DZ) < 4
                 COMPUTE WS-QX = WS-CCX + WS-DX
                 COMPUTE WS-QZ = WS-CCZ + WS-DZ
                 MOVE 0 TO WS-STOP
                 PERFORM VARYING WS-Q FROM 2 BY -1 UNTIL WS-Q < -3 OR WS-STOP = 1
                     MOVE WS-QX TO WS-MX
                     COMPUTE WS-MY = 63 + WS-Q
                     MOVE WS-QZ TO WS-MZ
                     PERFORM MGET
                     IF WS-MB = WS-B-DIRT OR WS-MB = WS-B-GRASS
                         MOVE WS-S-PODZOL TO WS-MS
                         PERFORM MPUT
                         MOVE 1 TO WS-STOP
                     ELSE
                         IF WS-MAIR = 0 AND WS-Q < 0
                             MOVE 1 TO WS-STOP
                         END-IF
                     END-IF
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     .
*> place_on_ground: tries 40, radius 4, height 2, weighted short_grass 3 / fern 1; layout 5 (the lowest layer x 24..25, z 40..41, y 63)
 M-PLACE.
     MOVE 20 TO WS-MINX
     MOVE 29 TO WS-MAXX
     MOVE 36 TO WS-MINZ
     MOVE 45 TO WS-MAXZ
     PERFORM 40 TIMES
         MOVE 10 TO WS-N
         PERFORM MDRAW
         COMPUTE WS-QX = WS-MINX + WS-D
         MOVE 5 TO WS-N
         PERFORM MDRAW
         COMPUTE WS-QY = 61 + WS-D
         MOVE 10 TO WS-N
         PERFORM MDRAW
         COMPUTE WS-QZ = WS-MINZ + WS-D
         MOVE WS-QX TO WS-MX
         COMPUTE WS-MY = WS-QY + 1
         MOVE WS-QZ TO WS-MZ
         PERFORM MGET
         MOVE 0 TO WS-GO
         IF WS-MAIR = 1 OR WS-MB = WS-B-VINE
             MOVE 1 TO WS-GO
         END-IF
         MOVE WS-QY TO WS-MY
         PERFORM MGET
         IF WS-GO = 1 AND CB-OPAQUE(WS-MB) = 1 AND WS-MAIR = 0
*>           the first free y of the column: from the top down the first fluid or motion-blocking non-leaf cell, plus one
             MOVE 58 TO WS-H
             MOVE 0 TO WS-STOP
             PERFORM VARYING WS-Q FROM 80 BY -1 UNTIL WS-Q < 58 OR WS-STOP = 1
                 MOVE WS-Q TO WS-MY
                 PERFORM MGET
                 IF WS-MAIR = 0
                     MOVE CB-KEY-LENGTH(WS-MB) TO WS-LEN
                     IF CB-SOLID(WS-MB) = 1 AND (WS-LEN < 7 OR CB-KEY(WS-MB)(WS-LEN - 6:7) NOT = "_leaves")
                         COMPUTE WS-H = WS-Q + 1
                         MOVE 1 TO WS-STOP
                     END-IF
                 END-IF
             END-PERFORM
             IF WS-H <= WS-QY + 1
                 MOVE 4 TO WS-N
                 PERFORM MDRAW
                 IF WS-D < 3
                     MOVE WS-S-SHORT TO WS-MS
                 ELSE
                     MOVE WS-S-FERN TO WS-MS
                 END-IF
                 MOVE WS-QX TO WS-MX
                 COMPUTE WS-MY = WS-QY + 1
                 MOVE WS-QZ TO WS-MZ
                 PERFORM MPUT
             END-IF
         END-IF
     END-PERFORM
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-35-4-DECO2.
 COPY CORETEST.
