*> Acceptance test of docs/protocol/36-structures-2 sections 7 to 9 (the structure processors) over the standard content set of the generated packs (skipped as a pass
*> without them): the compiled lists (the 40 shipped ones, the fixtures of core/tests/fixtures/gen_proc.py, the lists that do not compile), the rule processor and its tests
*> (worked examples 11.4 and 11.6), block_rot, protected_blocks, capped (example 11.9), gravity, block_ignore, blackstone_replace (11.7), block_age (11.8), nop, the pipeline of 7.4
*> inside STRUCT-PLACE (state transform timing, originals, the box and `capped`), the int providers, and the capacity limits of the tables.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-2-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY CELLS.
 COPY STRUCTTPL.
 COPY STRUCTSET.
 COPY STRUCTPLACE.
 COPY STRUCTPROC.
 COPY STRUCTPPOS.
 COPY STRUCTCUR.
 COPY FEATLEVEL.
 01 WS-TPL-DIR             PIC X(1100) VALUE "core/tests/fixtures/tpl".
 01 WS-PROC-DIR            PIC X(1100) VALUE "core/tests/fixtures/proc".
 01 WS-GEN-DIR             PIC X(1100).
 01 WS-PACK-DIR            PIC X(1100).
 01 WS-ENV                 PIC X(1100).
 01 WS-FILE                PIC X(1200).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
 01 WS-ID                  PIC X(96).
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-STATE               BINARY-LONG.
 01 WS-PROPS               PIC X(160).
 01 WS-LNAME               PIC X(40).
 01 WS-LKEY                PIC X(80).
 01 WS-LIDX                BINARY-LONG.
 01 WS-PROC                BINARY-LONG.
 01 WS-OFF                 BINARY-LONG VALUE 0.
 01 WS-KEEP                BINARY-LONG.
 01 WS-LABEL               PIC X(150).
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-NBT-IN              BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-OK                  BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-ED                  PIC -(8)9.
 01 WS-ED2                 PIC -(8)9.
 01 WS-ED3                 PIC -(8)9.
 01 WS-ED4                 PIC -(8)9.
 01 WS-ED5                 PIC -(8)9.
 01 WS-ED6                 PIC -(8)9.
 01 WS-RNG                 BINARY-DOUBLE UNSIGNED.
 01 WS-RNG2                BINARY-DOUBLE UNSIGNED.
 01 WS-U                   FLOAT-LONG.
 01 WS-U2                  FLOAT-LONG.
 01 WS-LIMIT-F             FLOAT-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-DRAW2               BINARY-LONG.
 01 WS-DRAW3               BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-CX                  BINARY-LONG VALUE 0.
 01 WS-CZ                  BINARY-LONG VALUE 0.
 01 WS-SAVE-P              BINARY-LONG.
 01 WS-SAVE-R              BINARY-LONG.
 01 WS-SAVE-T              BINARY-LONG.
 01 WS-SAVE-O              BINARY-LONG.
 01 WS-NONZERO             BINARY-LONG.
 01 WS-AT-TEXT             PIC X(300).
 01 WS-POS2                BINARY-LONG.
 01 WS-BAD-NAMES           PIC X(900) VALUE "bad_jigsaw bad_lava bad_type bad_notype bad_nolocation bad_testtype bad_posrule bad_posrange bad_block bad_output bad_state "
     & "bad_noprob bad_rules bad_nolimit bad_limit bad_nodelegate bad_heightmap bad_integrity bad_rottable bad_protected bad_ignore bad_ignore2 "
     & "bad_ignore3 bad_height2 bad_norules bad_protected2 bad_age bad_alloftests bad_height bad_blockstatematch bad_probability bad_tag bad_list bad_json bad_rootnum "
     & "missing".
 01 WS-NAME-ONE            PIC X(40).
 01 WS-SHIPPED             PIC X(1000) VALUE "ancient_city_generic_degradation ancient_city_start_degradation ancient_city_walls_degradation bastion_generic_degradation "
     & "bottom_rampart bridge empty entrance_replacement farm_desert farm_plains farm_savanna farm_snowy farm_taiga fossil_coal fossil_diamonds "
     & "fossil_rot high_rampart high_wall housing mossify_10_percent mossify_20_percent mossify_70_percent outpost_rot rampart_degradation roof "
     & "side_wall_degradation stable_degradation street_plains street_savanna street_snowy_or_taiga trail_ruins_houses_archaeology "
     & "trail_ruins_roads_archaeology trail_ruins_tower_top_archaeology treasure_rooms trial_chambers_copper_bulb_degradation zombie_desert "
     & "zombie_plains zombie_savanna zombie_snowy zombie_taiga".
 01 WS-COUNT-RULE          BINARY-LONG.
 01 WS-COUNT-PROT          BINARY-LONG.
 01 WS-COUNT-ROT           BINARY-LONG.
 01 WS-COUNT-CAPPED        BINARY-LONG.
 01 WS-LOADED              BINARY-LONG.
 01 WS-OBS-SAVE            PIC X(300).
 01 WS-FLAG-OUT            BINARY-LONG.
 01 WS-STATE-TEXT          PIC X(300).
 01 WS-WANT                PIC X(300).
 01 WS-BAD-COUNT           BINARY-LONG.
 01 WS-BAD-TEXT            PIC X(300).
 01 WS-FROM                PIC X(48).
 01 WS-TO                  PIC X(48).
 01 WS-CHANGED             BINARY-LONG.
 01 WS-KEPT                BINARY-LONG.
 01 WS-C1                  BINARY-LONG.
 01 WS-C2                  BINARY-LONG.
 01 WS-C3                  BINARY-LONG.
 01 WS-C4                  BINARY-LONG.
 01 WS-C5                  BINARY-LONG.
 01 WS-F1                  BINARY-LONG.
 01 WS-F2                  BINARY-LONG.
 01 WS-H1                  BINARY-LONG.
 01 WS-H2                  BINARY-LONG.
 01 WS-GATE                FLOAT-LONG.
 01 WS-AGE-KEY             PIC X(48).
 01 WS-AGE-TARGET          PIC X(48).
 01 WS-AGE-PAIRS           PIC X(160).
 01 WS-AGE-LIMIT           FLOAT-LONG.
 01 WS-AGE-LIMIT-S         FLOAT-SHORT.
 01 WS-IP-TYPE             BINARY-LONG.
 01 WS-IA                  BINARY-LONG.
 01 WS-IB                  BINARY-LONG.
 01 WS-IC                  BINARY-LONG.
 01 WS-SPAN                BINARY-LONG.
 01 WS-RANGE               BINARY-LONG.
 01 WS-SLOPE               BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-FACING-NAMES.
    05 FILLER              PIC X(8) VALUE "north".
    05 FILLER              PIC X(8) VALUE "east".
    05 FILLER              PIC X(8) VALUE "south".
    05 FILLER              PIC X(8) VALUE "west".
 01 WS-FACING-TABLE REDEFINES WS-FACING-NAMES.
    05 WS-FACING-NAME      PIC X(8) OCCURS 4 TIMES.
 01 WS-HALF-NAMES.
    05 FILLER              PIC X(8) VALUE "top".
    05 FILLER              PIC X(8) VALUE "bottom".
 01 WS-HALF-TABLE REDEFINES WS-HALF-NAMES.
    05 WS-HALF-NAME        PIC X(8) OCCURS 2 TIMES.
 01 WS-BS-MAP              PIC X(1100) VALUE "cobblestone blackstone mossy_cobblestone blackstone stone polished_blackstone stone_bricks polished_blackstone_bricks "
     & "mossy_stone_bricks polished_blackstone_bricks cobblestone_stairs blackstone_stairs mossy_cobblestone_stairs blackstone_stairs "
     & "stone_stairs polished_blackstone_stairs stone_brick_stairs polished_blackstone_brick_stairs "
     & "mossy_stone_brick_stairs polished_blackstone_brick_stairs cobblestone_slab blackstone_slab mossy_cobblestone_slab blackstone_slab "
     & "smooth_stone_slab polished_blackstone_slab stone_slab polished_blackstone_slab stone_brick_slab polished_blackstone_brick_slab "
     & "mossy_stone_brick_slab polished_blackstone_brick_slab stone_brick_wall polished_blackstone_brick_wall "
     & "mossy_stone_brick_wall polished_blackstone_brick_wall cobblestone_wall blackstone_wall mossy_cobblestone_wall blackstone_wall "
     & "chiseled_stone_bricks chiseled_polished_blackstone cracked_stone_bricks cracked_polished_blackstone_bricks iron_bars iron_chain".
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN-DIR
     ELSE
         MOVE WS-ENV TO WS-GEN-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-GEN-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "acceptance US12 36-2§7 Structure processors: no generated packs here, skipped" TO TL-CASE
         MOVE "ok" TO TL-EXPECTED
         MOVE "ok" TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE SPACES TO WS-PACK-DIR
     STRING FUNCTION TRIM(WS-GEN-DIR TRAILING) "/vanilla-data" DELIMITED BY SIZE INTO WS-PACK-DIR
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-GEN-DIR WS-STATUS
     CALL "BLOCKS-OPEN"
     CALL "STRUCT-TPL-RESET"
     CALL "STRUCT-PROC-RESET"
     CALL "FD-SET-DIR" USING WS-PROC-DIR
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN-Y WS-HEIGHT WS-SEA
     SET ADDRESS OF CE-CHUNK TO WS-PTR

*>   ---- the compiled lists
     MOVE "simple" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE "list simple: one rule processor with one rule" TO WS-LABEL
     MOVE SPL-FIRST(WS-LIDX) TO WS-PROC
     MOVE WS-LIDX TO WS-ED
     MOVE SPL-N(WS-LIDX) TO WS-ED2
     MOVE SPP-TYPE(WS-PROC) TO WS-ED3
     MOVE SPP-N(WS-PROC) TO WS-ED4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED2) " " FUNCTION TRIM(WS-ED3) " " FUNCTION TRIM(WS-ED4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 1 1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE SP-LIST-COUNT TO WS-A
     MOVE WS-LIDX TO WS-B
     PERFORM LOAD-LIST
     MOVE "a list is compiled once: the same number, no new row" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     IF WS-LIDX = WS-B AND SP-LIST-COUNT = WS-A
         MOVE "same" TO TL-OBSERVED
     END-IF
     MOVE "same" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "bare" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE "the bare array form of a list" TO WS-LABEL
     MOVE SPL-N(WS-LIDX) TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "2" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "empty" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE "the empty list has no processors (7.3)" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     MOVE SPL-N(WS-LIDX) TO WS-ED
     MOVE WS-LIDX TO WS-ED2
     IF WS-LIDX > 0
         STRING "loaded " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE "loaded 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE SP-PROC-COUNT TO WS-SAVE-P
     MOVE SP-RULE-COUNT TO WS-SAVE-R
     MOVE SP-TEST-COUNT TO WS-SAVE-T
     MOVE SP-POOL-COUNT TO WS-SAVE-O
     MOVE 0 TO WS-NONZERO
     MOVE 1 TO WS-POS2
     PERFORM UNTIL WS-POS2 > 900
         MOVE SPACES TO WS-NAME-ONE
         UNSTRING WS-BAD-NAMES DELIMITED BY ALL SPACE INTO WS-NAME-ONE WITH POINTER WS-POS2
         IF WS-NAME-ONE NOT = SPACES
             MOVE WS-NAME-ONE TO WS-LNAME
             PERFORM LOAD-LIST
             IF WS-LIDX NOT = 0
                 ADD 1 TO WS-NONZERO
                 DISPLAY "compiled although bad: " FUNCTION TRIM(WS-NAME-ONE)
             END-IF
         END-IF
     END-PERFORM
     MOVE "lists that do not compile (unknown or unsupported types, missing fields, bad ranges and blocks, not JSON, absent) give 0" TO WS-LABEL
     MOVE WS-NONZERO TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "a list that does not compile gives its rows back (processors, rules, tests and pool)" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     IF WS-SAVE-P = SP-PROC-COUNT AND WS-SAVE-R = SP-RULE-COUNT AND WS-SAVE-T = SP-TEST-COUNT AND WS-SAVE-O = SP-POOL-COUNT
         MOVE "same" TO TL-OBSERVED
     END-IF
     MOVE "same" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "protected_notag" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE SPL-FIRST(WS-LIDX) TO WS-PROC
     MOVE "a tag the content set does not have is the empty set" TO WS-LABEL
     MOVE SPP-N(WS-PROC) TO WS-ED
     MOVE SPACES TO TL-OBSERVED
     IF WS-LIDX > 0
         STRING "compiled " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE "compiled 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "gravity heightmaps and offset (9.5): default, WORLD_SURFACE offset 1, OCEAN_FLOOR_WG, OCEAN_FLOOR, MOTION_BLOCKING, MOTION_BLOCKING_NO_LEAVES" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-POS2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         EVALUATE WS-I
             WHEN 1
                 MOVE "gravity_default" TO WS-LNAME
             WHEN 2
                 MOVE "gravity" TO WS-LNAME
             WHEN 3
                 MOVE "gravity_ocean" TO WS-LNAME
             WHEN 4
                 MOVE "gravity_oceanfloor" TO WS-LNAME
             WHEN 5
                 MOVE "gravity_motion" TO WS-LNAME
             WHEN OTHER
                 MOVE "gravity_noleaves" TO WS-LNAME
         END-EVALUATE
         PERFORM LOAD-LIST
         MOVE SPL-FIRST(WS-LIDX) TO WS-PROC
         MOVE SPP-A(WS-PROC) TO WS-ED
         MOVE SPP-B(WS-PROC) TO WS-ED2
         STRING FUNCTION TRIM(WS-ED) "/" FUNCTION TRIM(WS-ED2) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-POS2
     END-PERFORM
     MOVE "0/0 1/1 2/0 3/0 4/0 5/0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "capped limits compile as the five int providers (constant, uniform, biased, very biased, trapezoid) with a delegate row" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-POS2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         EVALUATE WS-I
             WHEN 1
                 MOVE "capped2" TO WS-LNAME
             WHEN 2
                 MOVE "capped_uniform" TO WS-LNAME
             WHEN 3
                 MOVE "capped_biased" TO WS-LNAME
             WHEN 4
                 MOVE "capped_verybiased" TO WS-LNAME
             WHEN OTHER
                 MOVE "capped_trap" TO WS-LNAME
         END-EVALUATE
         PERFORM LOAD-LIST
         MOVE SPL-FIRST(WS-LIDX) TO WS-PROC
         MOVE SPP-B(WS-PROC) TO WS-ED
         MOVE SPP-TYPE(SPP-A(WS-PROC)) TO WS-ED2
         STRING FUNCTION TRIM(WS-ED) "/" FUNCTION TRIM(WS-ED2) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-POS2
     END-PERFORM
     MOVE "1/1 2/1 3/1 4/1 5/1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "combo" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE SPL-FIRST(WS-LIDX) TO WS-PROC
     MOVE "rule modifiers compile: append_loot 3 (rule 3), clear 1 (rule 7), append_static 2 (rule 8), the rest passthrough or unknown 0" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-POS2
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 11
         COMPUTE WS-K = SPP-A(WS-PROC) + WS-I
         MOVE SPR-MOD(WS-K) TO WS-ED
         STRING FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-POS2
     END-PERFORM
     MOVE "000300012000" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "unknownpos" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE SPL-FIRST(WS-LIDX) TO WS-PROC
     MOVE SPP-A(WS-PROC) TO WS-K
     MOVE "an unknown position test falls back to always_true (lenient field)" TO WS-LABEL
     MOVE SPR-POS(WS-K) TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   ---- all 40 shipped lists compile (12.12), with the counts of 10.2
     CALL "STRUCT-PROC-RESET"
     CALL "FD-SET-DIR" USING WS-PACK-DIR
     MOVE 0 TO WS-LOADED
     MOVE 1 TO WS-POS2
     PERFORM UNTIL WS-POS2 > 1000
         MOVE SPACES TO WS-NAME-ONE
         UNSTRING WS-SHIPPED DELIMITED BY ALL SPACE INTO WS-NAME-ONE WITH POINTER WS-POS2
         IF WS-NAME-ONE NOT = SPACES
             MOVE SPACES TO WS-LKEY
             STRING "minecraft:" FUNCTION TRIM(WS-NAME-ONE) DELIMITED BY SIZE INTO WS-LKEY
             CALL "STRUCT-PROC-LOAD" USING WS-LKEY WS-LIDX
             IF WS-LIDX > 0
                 ADD 1 TO WS-LOADED
             END-IF
         END-IF
     END-PERFORM
     MOVE "all 40 shipped processor lists compile" TO WS-LABEL
     MOVE WS-LOADED TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "40" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 0 TO WS-COUNT-RULE WS-COUNT-PROT WS-COUNT-ROT WS-COUNT-CAPPED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-PROC-COUNT
         EVALUATE SPP-TYPE(WS-I)
             WHEN 1
                 ADD 1 TO WS-COUNT-RULE
             WHEN 2
                 ADD 1 TO WS-COUNT-PROT
             WHEN 3
                 ADD 1 TO WS-COUNT-ROT
             WHEN 4
                 ADD 1 TO WS-COUNT-CAPPED
         END-EVALUATE
     END-PERFORM
     MOVE "shipped lists: 39 rule, 7 protected_blocks, 6 block_rot, 4 capped processors (10.2), 164 rules and 329 tests" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-COUNT-RULE TO WS-ED
     MOVE WS-COUNT-PROT TO WS-ED2
     MOVE WS-COUNT-ROT TO WS-ED3
     MOVE WS-COUNT-CAPPED TO WS-ED4
     MOVE SP-RULE-COUNT TO WS-ED5
     MOVE SP-TEST-COUNT TO WS-ED6
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) " " FUNCTION TRIM(WS-ED3) " " FUNCTION TRIM(WS-ED4) " "
         FUNCTION TRIM(WS-ED5) " " FUNCTION TRIM(WS-ED6) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "39 7 6 4 164 329" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     CALL "STRUCT-PROC-RESET"
     CALL "FD-SET-DIR" USING WS-PROC-DIR

*>   ---- the rule processor (8.1, example 11.4)
     MOVE "rules" TO WS-LNAME
     PERFORM LOAD-LIST
     PERFORM FRESH-SETTINGS
     MOVE "example 11.4: stone at (1,2,3): both draws fail, the block stays" TO WS-LABEL
     MOVE 1 TO WS-PX
     MOVE 2 TO WS-PY
     MOVE 3 TO WS-PZ
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM RUN-AT
     MOVE "1 stone| 1,2,3 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "example 11.4: stone at (-5,64,17): the first rule draws 0.069996 and wins (cobblestone)" TO WS-LABEL
     MOVE -5 TO WS-PX
     MOVE 64 TO WS-PY
     MOVE 17 TO WS-PZ
     PERFORM RUN-AT
     MOVE "1 cobblestone| -5,64,17 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "example 11.4: a block that is not stone draws nothing and stays" TO WS-LABEL
     MOVE "gravel" TO WS-KEY
     PERFORM RUN-AT
     MOVE "1 gravel| -5,64,17 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   ---- rule tests and modifiers
     MOVE "combo" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE 0 TO WS-NBT-IN
     MOVE 10 TO WS-PX
     MOVE 64 TO WS-PY
     MOVE 10 TO WS-PZ
     MOVE "oak_planks" TO WS-KEY
     MOVE "all_of with block_match and height_match: oak planks at y 64 become birch" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 birch_planks| 10,64,10 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 80 TO WS-PY
     MOVE "all_of fails at the first false child (y 80 is outside 60 to 70), the block falls through to the last rule (not gravel in the air: glass)" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 glass| 10,80,10 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 64 TO WS-PY
     MOVE "dirt" TO WS-KEY
     MOVE "any_of: the first child matches" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 coarse_dirt| 10,64,10 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "stone_bricks" TO WS-KEY
     MOVE "any_of: the second child matches" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 coarse_dirt| 10,64,10 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "white_wool" TO WS-KEY
     MOVE "tag_match with a # tag" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 white_concrete| 10,64,10 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "oak_log" TO WS-KEY
     MOVE "axis=x" TO WS-PAIRS
     MOVE "random_blockstate_match with probability 1: the exact state matches and draws below 1" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 birch_log|axis=y 10,64,10 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "axis=y" TO WS-PAIRS
     MOVE "another state of the block does not match the state test (no draw), the log tag does" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 stripped_oak_log|axis=y 10,64,10 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "oak_stairs" TO WS-KEY
     MOVE "facing=east,half=bottom,shape=straight,waterlogged=false" TO WS-PAIRS
     MOVE "blockstate_match with an output state object and the append_loot modifier (a tag appears)" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 spruce_stairs|facing=north,half=bottom,shape=straight,waterlogged=false 10,64,10 1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "facing=east,half=top,shape=straight,waterlogged=false" TO WS-PAIRS
     MOVE "blockstate_match is exact: stairs with another half fall through to the last rule (glass)" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 glass| 10,64,10 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "sand" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     MOVE "random_block_match with probability 0 never passes (the sand falls through to the last rule: glass)" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 glass| 10,64,10 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "gold_block" TO WS-KEY
     MOVE "the clear modifier gives the block an (empty) tag" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 iron_block| 10,64,10 1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "iron_block" TO WS-KEY
     MOVE "the append_static modifier gives the block a tag" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 gold_block| 10,64,10 1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "copper_block" TO WS-KEY
     MOVE 1 TO WS-NBT-IN
     MOVE "the passthrough modifier keeps the tag the block had" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 gold_block| 10,64,10 1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "emerald_block" TO WS-KEY
     MOVE 0 TO WS-NBT-IN
     MOVE "an unknown modifier type is passthrough: no tag appears" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 gold_block| 10,64,10 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "granite" TO WS-KEY
     MOVE "not with a location test: granite in the air becomes glass (the world is read at the position)" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 glass| 10,64,10 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM STATE-OF
     MOVE 10 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 10 TO WS-Z
     MOVE 0 TO WS-FLAGS
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     MOVE "granite" TO WS-KEY
     MOVE "the location test fails when the world holds stone: granite stays" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 granite| 10,64,10 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "gravel" TO WS-KEY
     MOVE "the not test fails for gravel: it stays" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 gravel| 10,64,10 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE LOW-VALUES TO CE-STATES

*>   ---- position tests (8.4, example 11.6)
     MOVE "linear" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     MOVE 0 TO PP-AX
     MOVE 64 TO PP-AY
     MOVE 0 TO PP-AZ
     MOVE "example 11.6: distance 12 clamps the chance to 1, the test always passes" TO WS-LABEL
     MOVE 6 TO WS-PX
     MOVE 64 TO WS-PY
     MOVE 6 TO WS-PZ
     PERFORM RUN-AT-ANCHOR
     MOVE "1 air| 6,64,6 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "example 11.6: distance 0 has chance 0, the test fails (u would have to be 0)" TO WS-LABEL
     MOVE 0 TO WS-PX
     MOVE 64 TO WS-PY
     MOVE 0 TO WS-PZ
     PERFORM RUN-AT-ANCHOR
     MOVE "1 stone| 0,64,0 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "example 11.6: block (3,64,-1): d = 4, chance 0.5, passes when the one draw u <= 0.5" TO WS-LABEL
     MOVE 3 TO WS-PX
     MOVE 64 TO WS-PY
     MOVE -1 TO WS-PZ
     PERFORM RUN-AT-ANCHOR
     CALL "STRUCT-POS-RANDOM" USING WS-PX WS-PY WS-PZ WS-RNG
     CALL "JRAND-NEXT-FLOAT" USING WS-RNG WS-U
     MOVE 0.5 TO WS-LIMIT-F
     IF WS-U <= WS-LIMIT-F
         MOVE "1 air| 3,64,-1 0" TO TL-EXPECTED
     ELSE
         MOVE "1 stone| 3,64,-1 0" TO TL-EXPECTED
     END-IF
     PERFORM ASSERT-TEXT
     MOVE "posalways" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE "a position test always_true passes without a draw" TO WS-LABEL
     MOVE 6 TO WS-PX
     MOVE 64 TO WS-PY
     MOVE 6 TO WS-PZ
     PERFORM RUN-AT-ANCHOR
     MOVE "1 air| 6,64,6 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "linear_min" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE "linear_pos below min_dist clamps t to 0: the chance is min_chance 1, the test passes" TO WS-LABEL
     MOVE 0 TO WS-PX
     MOVE 64 TO WS-PY
     MOVE 0 TO WS-PZ
     PERFORM RUN-AT-ANCHOR
     MOVE "1 air| 0,64,0 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "linear_pos beyond max_dist clamps t to 1: the chance is max_chance 0, the test fails" TO WS-LABEL
     MOVE 6 TO WS-PX
     MOVE 6 TO WS-PZ
     PERFORM RUN-AT-ANCHOR
     MOVE "1 stone| 6,64,6 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 999999 TO WS-A
     MOVE 1 TO WS-B
     MOVE 1 TO WS-K
     CALL "SP-IN-SET" USING WS-B WS-K WS-A WS-FLAG-OUT
     MOVE "a state outside the table is in no block set" TO WS-LABEL
     MOVE WS-FLAG-OUT TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "axis" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE "axis_aligned_linear_pos (the high_rampart form): only y counts, so a far x is distance 0 and fails" TO WS-LABEL
     MOVE 1000 TO WS-PX
     MOVE 64 TO WS-PY
     MOVE 0 TO WS-PZ
     PERFORM RUN-AT-ANCHOR
     MOVE "1 stone| 1000,64,0 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "axis_aligned_linear_pos: y distance 100 has chance 0.05 (the float32 of the data), one draw" TO WS-LABEL
     MOVE 0 TO WS-PX
     MOVE 164 TO WS-PY
     PERFORM RUN-AT-ANCHOR
     CALL "STRUCT-POS-RANDOM" USING WS-PX WS-PY WS-PZ WS-RNG
     CALL "JRAND-NEXT-FLOAT" USING WS-RNG WS-U
     MOVE 0.05 TO WS-LIMIT-F
     IF WS-U <= WS-LIMIT-F
         MOVE "1 air| 0,164,0 0" TO TL-EXPECTED
     ELSE
         MOVE "1 stone| 0,164,0 0" TO TL-EXPECTED
     END-IF
     PERFORM ASSERT-TEXT
     MOVE "axisz" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE "axis_aligned_linear_pos on z: distance 20 clamps to chance 1" TO WS-LABEL
     MOVE 5 TO WS-PX
     MOVE 70 TO WS-PY
     MOVE 20 TO WS-PZ
     PERFORM RUN-AT-ANCHOR
     MOVE "1 air| 5,70,20 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "axisx" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE "axis_aligned_linear_pos on x with chance 1 from distance 0" TO WS-LABEL
     MOVE 0 TO WS-PX
     MOVE 70 TO WS-PY
     MOVE 5 TO WS-PZ
     PERFORM RUN-AT-ANCHOR
     MOVE "1 air| 0,70,5 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   ---- block_rot (9.2)
     PERFORM FRESH-SETTINGS
     MOVE "rot_all" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE "block_rot with integrity 1 keeps every block (u <= 1)" TO WS-LABEL
     MOVE 1 TO WS-PX
     MOVE 2 TO WS-PY
     MOVE 3 TO WS-PZ
     PERFORM RUN-AT
     MOVE "1 stone| 1,2,3 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "rot_none" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE "block_rot with integrity 0 removes the block when u > 0 (0.795369 at (1,2,3))" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "0 stone| 1,2,3 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "rot_half" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE "block_rot 0.5 on stone at (1,2,3): u = 0.795369 > 0.5 removes it" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "0 stone| 1,2,3 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "block_rot 0.5 on stone at (-5,64,17): u = 0.069996 keeps it" TO WS-LABEL
     MOVE -5 TO WS-PX
     MOVE 64 TO WS-PY
     MOVE 17 TO WS-PZ
     PERFORM RUN-AT
     MOVE "1 stone| -5,64,17 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 1 TO WS-PX
     MOVE 2 TO WS-PY
     MOVE 3 TO WS-PZ
     MOVE "dirt" TO WS-KEY
     MOVE "block_rot: a block that is not rottable stays without a draw" TO WS-LABEL
     MOVE 1 TO PS-RANDOM-SET
     MOVE 777 TO WS-SEED
     CALL "JRAND-SET-SEED" USING PS-RANDOM WS-SEED
     MOVE PS-RANDOM TO WS-RNG2
     PERFORM RUN-AT
     MOVE "1 dirt| 1,2,3 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "block_rot: no draw was made from the shared random for it" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     IF PS-RANDOM = WS-RNG2
         MOVE "same" TO TL-OBSERVED
     END-IF
     MOVE "same" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "stone" TO WS-KEY
     PERFORM RUN-AT
     MOVE "block_rot: a rottable block draws from the shared random (getRandom(pos) is that stream)" TO WS-LABEL
     CALL "JRAND-NEXT-FLOAT" USING WS-RNG2 WS-U
     MOVE SPACES TO TL-OBSERVED
     IF PS-RANDOM = WS-RNG2
         MOVE "advanced by one draw" TO TL-OBSERVED
     END-IF
     MOVE "advanced by one draw" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "rot_tag" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE "white_wool" TO WS-KEY
     MOVE 0 TO PS-RANDOM-SET
     MOVE "block_rot with a rottable set of a tag and a block: wool rots at (1,2,3) (u > 0.5)" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "0 white_wool| 1,2,3 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   ---- protected_blocks (9.3) and block_ignore (9.1)
     MOVE "protected" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE "bedrock" TO WS-KEY
     PERFORM STATE-OF
     MOVE 3 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 3 TO WS-Z
     PERFORM SET-WORLD
     MOVE 3 TO WS-PX
     MOVE 70 TO WS-PY
     MOVE 3 TO WS-PZ
     MOVE "stone" TO WS-KEY
     MOVE "protected_blocks: the world's bedrock at the position protects it" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "0 stone| 3,70,3 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 4 TO WS-PX
     MOVE "protected_blocks: air at the position does not" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 stone| 4,70,3 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "protected_tag" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE 3 TO WS-PX
     MOVE "protected_blocks with the tag features_cannot_replace (bedrock is in it)" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "0 stone| 3,70,3 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE LOW-VALUES TO CE-STATES
     MOVE "ignore" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE "air" TO WS-KEY
     MOVE "block_ignore: air (a state object) is removed" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "0 air| 3,70,3 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "oak_log" TO WS-KEY
     MOVE "block_ignore: only the block counts, not the properties (oak_log with another axis is removed)" TO WS-LABEL
     MOVE "axis=z" TO WS-PAIRS
     PERFORM RUN-AT
     MOVE "0 oak_log|axis=z 3,70,3 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     MOVE "block_ignore: another block stays" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 stone| 3,70,3 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   ---- nop and gravity (9.5, 9.10)
     MOVE "nop" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE "nop returns the record as it is" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 stone| 3,70,3 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "stone" TO WS-KEY
     PERFORM STATE-OF
     PERFORM VARYING WS-Y FROM -64 BY 1 UNTIL WS-Y > 60
         MOVE 5 TO WS-X
         MOVE 5 TO WS-Z
         PERFORM SET-WORLD
     END-PERFORM
     MOVE "gravity" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE 5 TO WS-PX
     MOVE 90 TO WS-PY
     MOVE 5 TO WS-PZ
     MOVE 3 TO PP-LY
     MOVE "gravity: WORLD_SURFACE with offset 1 at a column whose top block is at y 60: height 61 + 1 + local y 3" TO WS-LABEL
     PERFORM RUN-AT-LOCAL
     MOVE "1 stone| 5,65,5 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "gravity_default" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE "gravity with the default heightmap and offset: 61 + 0 + local y 0" TO WS-LABEL
     MOVE 0 TO PP-LY
     PERFORM RUN-AT-LOCAL
     MOVE "1 stone| 5,61,5 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE LOW-VALUES TO CE-STATES

*>   ---- blackstone_replace (9.8, example 11.7)
     MOVE "blackstone" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE 3 TO WS-PX
     MOVE 70 TO WS-PY
     MOVE 3 TO WS-PZ
     MOVE "stone_brick_stairs" TO WS-KEY
     MOVE "facing=east,half=top,shape=outer_left,waterlogged=true" TO WS-PAIRS
     MOVE "example 11.7: stairs keep facing and half, shape and waterlogged take the defaults" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 polished_blackstone_brick_stairs|facing=east,half=top,shape=straight,waterlogged=false 3,70,3 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "stone_brick_wall" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     MOVE "up=true,north=low,east=none,south=none,west=none,waterlogged=false" TO WS-PAIRS
     MOVE "example 11.7: a wall becomes the default polished blackstone brick wall (no property copied)" TO WS-LABEL
     PERFORM RUN-AT
     MOVE TL-OBSERVED TO WS-OBS-SAVE
     PERFORM EXPECT-DEFAULT-WALL
     MOVE WS-OBS-SAVE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "smooth_stone_slab" TO WS-KEY
     MOVE "type=double,waterlogged=false" TO WS-PAIRS
     MOVE "example 11.7: a slab keeps its type" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 polished_blackstone_slab|type=double,waterlogged=false 3,70,3 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE SPACES TO WS-PAIRS
     MOVE "cobblestone" TO WS-KEY
     MOVE "a full block maps to its blackstone block" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 blackstone| 3,70,3 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "iron_bars" TO WS-KEY
     MOVE "north=true,east=false,south=false,west=true,waterlogged=false" TO WS-PAIRS
     MOVE "iron bars become a chain (axis y by default)" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 iron_chain|axis=y,waterlogged=false 3,70,3 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "dirt" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     MOVE "a block that is not in the map is unchanged" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 dirt| 3,70,3 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     PERFORM CHECK-BLACKSTONE-MAP

*>   ---- block_age (9.9, example 11.8)
     MOVE "age" TO WS-LNAME
     PERFORM LOAD-LIST
     PERFORM FRESH-SETTINGS
     MOVE "stone_bricks" TO WS-KEY
     MOVE -5 TO WS-PX
     MOVE 64 TO WS-PY
     MOVE 17 TO WS-PZ
     MOVE "example 11.8: stone bricks at (-5,64,17) with mossiness 0.3 become cracked stone bricks" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 cracked_stone_bricks| -5,64,17 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 1 TO WS-PX
     MOVE 2 TO WS-PY
     MOVE 3 TO WS-PZ
     MOVE "example 11.8: at (1,2,3) the first draw 0.795369 is not below 0.5, the block is unchanged" TO WS-LABEL
     PERFORM RUN-AT
     MOVE "1 stone_bricks| 1,2,3 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     PERFORM CHECK-AGE-CLASSES

*>   ---- int providers (23 section 7.1) against the same stream drawn by hand
     PERFORM CHECK-INT-PROVIDERS

*>   ---- the pipeline inside STRUCT-PLACE (7.4)
     MOVE 4 TO WS-OX
     MOVE 70 TO WS-OY
     MOVE 4 TO WS-OZ
     MOVE "test:stairs" TO WS-ID
     PERFORM LOAD-TEMPLATE
     MOVE LOW-VALUES TO CE-STATES
     PERFORM FRESH-SETTINGS
     MOVE "simple" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE WS-LIDX TO PS-PROCESSORS
     PERFORM PLACE
     MOVE 4 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 4 TO WS-Z
     PERFORM AT-TEXT
     MOVE "pipeline: a rule list turns the template's stone into cobblestone" TO WS-LABEL
     MOVE "cobblestone|" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE LOW-VALUES TO CE-STATES
     MOVE "stairsout" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE WS-LIDX TO PS-PROCESSORS
     MOVE 1 TO PS-ROTATION
     PERFORM PLACE
     MOVE 4 TO WS-X
     PERFORM AT-TEXT
     MOVE "state transform timing: a rule output oak_stairs[facing=north] under clockwise 90 is facing east in the world" TO WS-LABEL
     MOVE "oak_stairs|facing=east,half=bottom,shape=straight,waterlogged=false" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE LOW-VALUES TO CE-STATES
     MOVE "stairmatch" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE WS-LIDX TO PS-PROCESSORS
     PERFORM PLACE
     MOVE 4 TO WS-X
     MOVE 5 TO WS-Z
     PERFORM AT-TEXT
     MOVE "state transform timing: blockstate_match sees the unrotated file state (east), the output east is turned to south" TO WS-LABEL
     MOVE "spruce_stairs|facing=south,half=bottom,shape=straight,waterlogged=false" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE LOW-VALUES TO CE-STATES
     PERFORM FRESH-SETTINGS
     MOVE "twice" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE WS-LIDX TO PS-PROCESSORS
     PERFORM PLACE
     MOVE PW-COUNT TO WS-ED
     MOVE 5 TO WS-X
     MOVE 5 TO WS-Z
     PERFORM AT-TEXT
     MOVE SPACES TO WS-AT-TEXT
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(TL-OBSERVED) DELIMITED BY SIZE INTO WS-AT-TEXT
     MOVE WS-AT-TEXT TO TL-OBSERVED
     MOVE "a processor that removes a block drops it from the list: 4 of 5 records, the log's cell stays air" TO WS-LABEL
     MOVE "4 air|" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 4 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 4 TO WS-Z
     PERFORM AT-TEXT
     MOVE "processors run in list order on the same record: the second list element still sees the survivors" TO WS-LABEL
     MOVE "cobblestone|" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   ---- capped (9.4, example 11.9) and the box (7.4 step 1)
     MOVE "test:row5" TO WS-ID
     PERFORM LOAD-TEMPLATE
     MOVE LOW-VALUES TO CE-STATES
     PERFORM FRESH-SETTINGS
     MOVE 12345 TO PS-SEED
     MOVE "capped_uniform" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE WS-LIDX TO PS-PROCESSORS
     MOVE 10 TO WS-OX
     MOVE 64 TO WS-OY
     MOVE 10 TO WS-OZ
     PERFORM PLACE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-POS2
     PERFORM VARYING WS-X FROM 10 BY 1 UNTIL WS-X > 14
         MOVE 64 TO WS-Y
         MOVE 10 TO WS-Z
         CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
         MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
         IF FUNCTION TRIM(CB-KEY(WS-BLOCK + 1)) = "cobblestone"
             STRING "C" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-POS2
         ELSE
             STRING "s" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-POS2
         END-IF
     END-PERFORM
     MOVE "example 11.9: level seed 12345 at (10,64,10), limit uniform 1 to 3 draws 1, the shuffle tries block 2 first, and it changes: one block" TO WS-LABEL
     MOVE "ssCss" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "test:cube3" TO WS-ID
     PERFORM LOAD-TEMPLATE
     MOVE 4 TO WS-OX
     MOVE 70 TO WS-OY
     MOVE 4 TO WS-OZ
     MOVE "capped2" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE WS-LIDX TO PS-PROCESSORS
     PERFORM COUNT-COBBLE
     MOVE "capped with limit 2 changes exactly two of 27 stones" TO WS-LABEL
     MOVE "2" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     PERFORM COUNT-COBBLE
     MOVE "capped is deterministic: the same placement again changes the same two (count 2 again)" TO WS-LABEL
     MOVE "2" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "capped_none" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE WS-LIDX TO PS-PROCESSORS
     PERFORM COUNT-COBBLE
     MOVE "capped: a delegate that changes nothing changes nothing" TO WS-LABEL
     MOVE "0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "capped_zero" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE WS-LIDX TO PS-PROCESSORS
     PERFORM COUNT-COBBLE
     MOVE "capped: a limit whose maximum is 0 returns the list unchanged" TO WS-LABEL
     MOVE "0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "capped_ignore" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE WS-LIDX TO PS-PROCESSORS
     PERFORM COUNT-COBBLE
     MOVE "capped: a delegate that removes a block (null) is ignored, the block stays and does not count" TO WS-LABEL
     MOVE "0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "capped_trap" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE WS-LIDX TO PS-PROCESSORS
     PERFORM COUNT-COBBLE
     MOVE "capped_trap0" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE WS-LIDX TO PS-PROCESSORS
     PERFORM COUNT-COBBLE
     MOVE "capped_trapflat" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE WS-LIDX TO PS-PROCESSORS
     PERFORM COUNT-COBBLE
     MOVE "capped_biased" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE WS-LIDX TO PS-PROCESSORS
     PERFORM COUNT-COBBLE
     MOVE "capped_verybiased" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE WS-LIDX TO PS-PROCESSORS
     PERFORM COUNT-COBBLE
     MOVE "the box limits the pipeline (7.4 step 1): with a box and nop only the records inside it are processed" TO WS-LABEL
     MOVE "nop" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE WS-LIDX TO PS-PROCESSORS
     MOVE 1 TO PS-BOX-SET
     MOVE 4 TO PS-BOX(1)
     MOVE 70 TO PS-BOX(2)
     MOVE 4 TO PS-BOX(3)
     MOVE 4 TO PS-BOX(4)
     MOVE 70 TO PS-BOX(5)
     MOVE 4 TO PS-BOX(6)
     MOVE 4 TO WS-OX
     MOVE 70 TO WS-OY
     MOVE 4 TO WS-OZ
     PERFORM PLACE
     MOVE PW-COUNT TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "capped2" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE WS-LIDX TO PS-PROCESSORS
     PERFORM PLACE
     MOVE "capped evaluates the entire piece: with the same box all 27 records go through the pipeline" TO WS-LABEL
     MOVE PW-COUNT TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "27" TO TL-EXPECTED
     PERFORM ASSERT-TEXT

*>   ---- the capacity limits
     CALL "STRUCT-PROC-RESET"
     MOVE 0 TO WS-LOADED
     MOVE 0 TO WS-I
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 69
         MOVE SPACES TO WS-LNAME
         MOVE WS-I TO WS-ED
         IF WS-I < 10
             STRING "big0" FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO WS-LNAME
         ELSE
             STRING "big" FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO WS-LNAME
         END-IF
         PERFORM LOAD-LIST
         IF WS-LIDX > 0
             ADD 1 TO WS-LOADED
         END-IF
     END-PERFORM
     MOVE "big00" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE SPL-FIRST(WS-LIDX) TO WS-PROC
     COMPUTE WS-A = 32768 / SPP-N(WS-PROC)
     MOVE "the pool holds 32768 block numbers: as many lists of the big tag compile as fit, then a list does not" TO WS-LABEL
     MOVE WS-LOADED TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE WS-A TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "the list table holds 64 lists: further lists are not even tried" TO WS-LABEL
     MOVE SP-LIST-COUNT TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE "64" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     CALL "STRUCT-PROC-RESET"
     MOVE "toomany" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE WS-LIDX TO WS-A
     MOVE "nops1023" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE WS-LIDX TO WS-B
     MOVE "capped_full" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE "the processor table holds 1024 rows: 1025 processors do not fit, 1023 do, and then a capped list has no row for its delegate" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-A TO WS-ED
     MOVE WS-LIDX TO WS-ED2
     IF WS-B > 0
         STRING FUNCTION TRIM(WS-ED) " fits " FUNCTION TRIM(WS-ED2) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     MOVE "0 fits 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     CALL "STRUCT-PROC-RESET"
     MOVE 0 TO WS-LOADED
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 4
         MOVE SPACES TO WS-LNAME
         MOVE WS-I TO WS-ED
         STRING "rules400_" FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO WS-LNAME
         PERFORM LOAD-LIST
         IF WS-LIDX > 0
             ADD 1 TO WS-LOADED
         END-IF
     END-PERFORM
     MOVE "tests_over" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE WS-LIDX TO WS-A
     MOVE "rules_over" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE "the test table holds 4096 rows and the rule table 2048: five lists of 400 rules fit, then a list of tests and a list of rules do not" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-LOADED TO WS-ED
     MOVE WS-A TO WS-ED2
     MOVE WS-LIDX TO WS-ED3
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-ED2) " " FUNCTION TRIM(WS-ED3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "5 0 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     GOBACK.

 ASSERT-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 36-2§7 Structure processors: " FUNCTION TRIM(WS-LABEL) DELIMITED BY SIZE INTO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 STATE-OF.
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE.

 STATE-TEXT.
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(CB-KEY(WS-BLOCK + 1)) "|" FUNCTION TRIM(WS-PROPS) DELIMITED BY SIZE INTO TL-OBSERVED.

 AT-TEXT.
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     PERFORM STATE-TEXT.

 SET-WORLD.
     MOVE 0 TO WS-FLAGS
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     MOVE 3 TO WS-FLAGS.

 FRESH-SETTINGS.
     INITIALIZE STRUCT-SETTINGS
     MOVE 3 TO WS-FLAGS.

 LOAD-LIST.
     MOVE SPACES TO WS-LKEY
     STRING "test:" FUNCTION TRIM(WS-LNAME) DELIMITED BY SIZE INTO WS-LKEY
     CALL "STRUCT-PROC-LOAD" USING WS-LKEY WS-LIDX.

 LOAD-TEMPLATE.
     CALL "STRUCT-TPL-LOAD" USING WS-TPL-DIR WS-ID WS-ROW.

 PLACE.
     MOVE WS-OX TO WS-AX
     MOVE WS-OY TO WS-AY
     MOVE WS-OZ TO WS-AZ
     CALL "STRUCT-PLACE" USING WS-ROW WS-OX WS-OY WS-OZ WS-AX WS-AY WS-AZ STRUCT-SETTINGS WS-FLAGS WS-RESULT.

*> RUN-AT: the processor WS-OFF of list WS-LIDX on the record (WS-PX, WS-PY, WS-PZ) of the state WS-KEY / WS-PAIRS; local position 0, anchor 0.
 RUN-AT.
     MOVE 0 TO PP-LX PP-LY PP-LZ PP-AX PP-AY PP-AZ
     PERFORM RUN-AT-LOCAL.

 RUN-AT-ANCHOR.
     MOVE 0 TO PP-LX PP-LY PP-LZ
     PERFORM RUN-AT-LOCAL.

 RUN-AT-LOCAL.
     PERFORM STATE-OF
     MOVE WS-PX TO CU-X
     MOVE WS-PY TO CU-Y
     MOVE WS-PZ TO CU-Z
     MOVE WS-STATE TO CU-STATE
     MOVE WS-NBT-IN TO CU-NBT
     COMPUTE WS-PROC = SPL-FIRST(WS-LIDX) + WS-OFF
     CALL "STRUCT-PROC-BLOCK" USING WS-PROC STRUCT-PPOS STRUCT-CUR WS-KEEP STRUCT-SETTINGS
     MOVE CU-STATE TO WS-STATE
     PERFORM STATE-TEXT
     MOVE TL-OBSERVED TO WS-STATE-TEXT
     MOVE SPACES TO WS-AT-TEXT
     MOVE WS-KEEP TO WS-ED
     MOVE CU-X TO WS-ED2
     MOVE CU-Y TO WS-ED3
     MOVE CU-Z TO WS-ED4
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-ED2) "," FUNCTION TRIM(WS-ED3) "," FUNCTION TRIM(WS-ED4)
         " " DELIMITED BY SIZE INTO WS-AT-TEXT
     MOVE CU-NBT TO WS-ED
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-AT-TEXT)) TO WS-A
     ADD 2 TO WS-A
     STRING FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO WS-AT-TEXT WITH POINTER WS-A
     MOVE WS-AT-TEXT TO TL-OBSERVED.

 EXPECT-DEFAULT-WALL.
     MOVE "polished_blackstone_brick_wall" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM STATE-OF
     PERFORM STATE-TEXT
     MOVE SPACES TO TL-EXPECTED
     STRING "1 " FUNCTION TRIM(TL-OBSERVED) " 3,70,3 0" DELIMITED BY SIZE INTO TL-EXPECTED.

*> CHECK-BLACKSTONE-MAP: every pair of the table of 9.8: the default state of the first block becomes the default state of the second.
 CHECK-BLACKSTONE-MAP.
     MOVE "blackstone" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE 0 TO WS-BAD-COUNT
     MOVE SPACES TO WS-BAD-TEXT
     MOVE 1 TO WS-POS2
     PERFORM UNTIL WS-POS2 > 1100
         MOVE SPACES TO WS-FROM WS-TO
         UNSTRING WS-BS-MAP DELIMITED BY ALL SPACE INTO WS-FROM WS-TO WITH POINTER WS-POS2
         IF WS-FROM NOT = SPACES
             MOVE WS-FROM TO WS-KEY
             MOVE SPACES TO WS-PAIRS
             PERFORM RUN-AT
             MOVE WS-TO TO WS-KEY
             MOVE SPACES TO WS-PAIRS
             PERFORM STATE-OF
             IF WS-STATE NOT = CU-STATE
                 ADD 1 TO WS-BAD-COUNT
                 MOVE WS-FROM TO WS-BAD-TEXT
             END-IF
         END-IF
     END-PERFORM
     MOVE "the 23 blackstone replacements of 9.8 (the default state of each target)" TO WS-LABEL
     MOVE WS-BAD-COUNT TO WS-ED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-BAD-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT.

*> AGE-SIMPLE: block_age of WS-AGE-KEY with WS-AGE-PAIRS at 60 positions: one draw u, the block becomes WS-AGE-TARGET with the same properties when u < WS-AGE-LIMIT.
 AGE-SIMPLE.
     MOVE 0 TO WS-BAD-COUNT WS-CHANGED WS-KEPT
     MOVE SPACES TO WS-BAD-TEXT
     PERFORM VARYING WS-PX FROM 0 BY 1 UNTIL WS-PX > 59
         MOVE 64 TO WS-PY
         MOVE 0 TO WS-PZ
         CALL "STRUCT-POS-RANDOM" USING WS-PX WS-PY WS-PZ WS-RNG
         CALL "JRAND-NEXT-FLOAT" USING WS-RNG WS-U
         MOVE SPACES TO TL-EXPECTED
         IF WS-U < WS-AGE-LIMIT
             ADD 1 TO WS-CHANGED
             STRING FUNCTION TRIM(WS-AGE-TARGET) "|" FUNCTION TRIM(WS-AGE-PAIRS) DELIMITED BY SIZE INTO TL-EXPECTED
         ELSE
             ADD 1 TO WS-KEPT
             STRING FUNCTION TRIM(WS-AGE-KEY) "|" FUNCTION TRIM(WS-AGE-PAIRS) DELIMITED BY SIZE INTO TL-EXPECTED
         END-IF
         MOVE WS-AGE-KEY TO WS-KEY
         MOVE WS-AGE-PAIRS TO WS-PAIRS
         PERFORM RUN-AT
         IF WS-STATE-TEXT NOT = TL-EXPECTED
             ADD 1 TO WS-BAD-COUNT
             MOVE WS-STATE-TEXT TO WS-BAD-TEXT
         END-IF
     END-PERFORM
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-BAD-COUNT TO WS-ED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-BAD-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "both outcomes occurred among the 60 positions" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     IF WS-CHANGED > 0 AND WS-KEPT > 0
         MOVE "both" TO TL-OBSERVED
     END-IF
     MOVE "both" TO TL-EXPECTED
     PERFORM ASSERT-TEXT.

 CHECK-AGE-CLASSES.
     MOVE "age" TO WS-LNAME
     PERFORM LOAD-LIST
     MOVE 0.3 TO WS-AGE-LIMIT-S
     MOVE WS-AGE-LIMIT-S TO WS-AGE-LIMIT
     MOVE "stone_brick_slab" TO WS-AGE-KEY
     MOVE "mossy_stone_brick_slab" TO WS-AGE-TARGET
     MOVE "type=double,waterlogged=true" TO WS-AGE-PAIRS
     MOVE "block_age on a slab: mossy_stone_brick_slab with its properties when u < mossiness" TO WS-LABEL
     PERFORM AGE-SIMPLE
     MOVE "stone_brick_wall" TO WS-AGE-KEY
     MOVE "mossy_stone_brick_wall" TO WS-AGE-TARGET
     MOVE "east=none,north=low,south=none,up=true,waterlogged=false,west=none" TO WS-AGE-PAIRS
     MOVE "block_age on a wall: mossy_stone_brick_wall with its properties when u < mossiness" TO WS-LABEL
     PERFORM AGE-SIMPLE
     MOVE 0.15 TO WS-AGE-LIMIT-S
     MOVE WS-AGE-LIMIT-S TO WS-AGE-LIMIT
     MOVE "obsidian" TO WS-AGE-KEY
     MOVE "crying_obsidian" TO WS-AGE-TARGET
     MOVE SPACES TO WS-AGE-PAIRS
     MOVE "block_age on obsidian: crying obsidian when u < 0.15" TO WS-LABEL
     PERFORM AGE-SIMPLE
*>   stone and chiseled stone bricks are full stone too (example 11.8 draws at (-5,64,17))
     MOVE -5 TO WS-PX
     MOVE 64 TO WS-PY
     MOVE 17 TO WS-PZ
     MOVE "stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM RUN-AT
     MOVE "stone: the same draws as the stone bricks of example 11.8" TO WS-LABEL
     MOVE "1 cracked_stone_bricks| -5,64,17 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "chiseled_stone_bricks" TO WS-KEY
     PERFORM RUN-AT
     MOVE "chiseled stone bricks: the same" TO WS-LABEL
     MOVE "1 cracked_stone_bricks| -5,64,17 0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE 0.3 TO WS-AGE-LIMIT-S
     MOVE WS-AGE-LIMIT-S TO WS-AGE-LIMIT
     PERFORM AGE-STAIRS-LOOP
     PERFORM AGE-FULL-LOOP.

*> The stairs of 9.9: gate 0.5, then pick(rng, [stone_slab, stone_brick_slab], [mossy stairs with the properties, mossy slab]).
 AGE-STAIRS-LOOP.
     MOVE 0 TO WS-BAD-COUNT WS-C1 WS-C2 WS-C3 WS-C4 WS-C5
     MOVE SPACES TO WS-BAD-TEXT
     PERFORM VARYING WS-PX FROM 0 BY 1 UNTIL WS-PX > 199
         MOVE 64 TO WS-PY
         MOVE 0 TO WS-PZ
         CALL "STRUCT-POS-RANDOM" USING WS-PX WS-PY WS-PZ WS-RNG
         CALL "JRAND-NEXT-FLOAT" USING WS-RNG WS-U
         MOVE SPACES TO TL-EXPECTED
         MOVE 0.5 TO WS-GATE
         MOVE "stone_stairs|facing=south,half=top,shape=straight,waterlogged=false" TO WS-WANT
         IF WS-U < WS-GATE
             CALL "JRAND-NEXT-FLOAT" USING WS-RNG WS-U2
             MOVE 2 TO WS-BOUND
             CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-BOUND WS-DRAW
             IF WS-U2 < WS-AGE-LIMIT
                 IF WS-DRAW = 0
                     ADD 1 TO WS-C2
                     MOVE "mossy_stone_brick_stairs|facing=south,half=top,shape=straight,waterlogged=false" TO WS-WANT
                 ELSE
                     ADD 1 TO WS-C3
                     MOVE "mossy_stone_brick_slab|type=bottom,waterlogged=false" TO WS-WANT
                 END-IF
             ELSE
                 IF WS-DRAW = 0
                     ADD 1 TO WS-C4
                     MOVE "stone_slab|type=bottom,waterlogged=false" TO WS-WANT
                 ELSE
                     ADD 1 TO WS-C5
                     MOVE "stone_brick_slab|type=bottom,waterlogged=false" TO WS-WANT
                 END-IF
             END-IF
         ELSE
             ADD 1 TO WS-C1
         END-IF
         MOVE "stone_stairs" TO WS-KEY
         MOVE "facing=south,half=top,shape=straight,waterlogged=false" TO WS-PAIRS
         PERFORM RUN-AT
         IF WS-STATE-TEXT NOT = WS-WANT
             ADD 1 TO WS-BAD-COUNT
             MOVE WS-STATE-TEXT TO WS-BAD-TEXT
         END-IF
     END-PERFORM
     MOVE "block_age on stairs over 200 positions: the gate, the two draws of the pick and each of the five results as the doc's lists" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-BAD-COUNT TO WS-ED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-BAD-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "block_age on stairs: all five results occurred" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     IF WS-C1 > 0 AND WS-C2 > 0 AND WS-C3 > 0 AND WS-C4 > 0 AND WS-C5 > 0
         MOVE "all" TO TL-OBSERVED
     END-IF
     MOVE "all" TO TL-EXPECTED
     PERFORM ASSERT-TEXT.

*> The full stone of 9.9: gate 0.5, then the four draws that build the lists, then pick (u, nextInt(2)).
 AGE-FULL-LOOP.
     MOVE 0 TO WS-BAD-COUNT WS-C1 WS-C2 WS-C3 WS-C4 WS-C5
     MOVE SPACES TO WS-BAD-TEXT
     PERFORM VARYING WS-PX FROM 0 BY 1 UNTIL WS-PX > 299
         MOVE 64 TO WS-PY
         MOVE 0 TO WS-PZ
         CALL "STRUCT-POS-RANDOM" USING WS-PX WS-PY WS-PZ WS-RNG
         CALL "JRAND-NEXT-FLOAT" USING WS-RNG WS-U
         MOVE 0.5 TO WS-GATE
         MOVE "stone_bricks|" TO WS-WANT
         IF WS-U < WS-GATE
             MOVE 4 TO WS-BOUND
             CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-BOUND WS-DRAW
             MOVE 2 TO WS-BOUND
             CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-BOUND WS-DRAW2
             MOVE WS-DRAW TO WS-F1
             MOVE WS-DRAW2 TO WS-H1
             MOVE 4 TO WS-BOUND
             CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-BOUND WS-DRAW
             MOVE 2 TO WS-BOUND
             CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-BOUND WS-DRAW2
             MOVE WS-DRAW TO WS-F2
             MOVE WS-DRAW2 TO WS-H2
             CALL "JRAND-NEXT-FLOAT" USING WS-RNG WS-U2
             MOVE 2 TO WS-BOUND
             CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-BOUND WS-DRAW3
             IF WS-U2 < WS-AGE-LIMIT
                 IF WS-DRAW3 = 0
                     ADD 1 TO WS-C2
                     MOVE "mossy_stone_bricks|" TO WS-WANT
                 ELSE
                     ADD 1 TO WS-C3
                     PERFORM WANT-STAIRS-2
                 END-IF
             ELSE
                 IF WS-DRAW3 = 0
                     ADD 1 TO WS-C4
                     MOVE "cracked_stone_bricks|" TO WS-WANT
                 ELSE
                     ADD 1 TO WS-C5
                     PERFORM WANT-STAIRS-1
                 END-IF
             END-IF
         ELSE
             ADD 1 TO WS-C1
         END-IF
         MOVE "stone_bricks" TO WS-KEY
         MOVE SPACES TO WS-PAIRS
         PERFORM RUN-AT
         IF WS-STATE-TEXT NOT = WS-WANT
             ADD 1 TO WS-BAD-COUNT
             MOVE WS-STATE-TEXT TO WS-BAD-TEXT
         END-IF
     END-PERFORM
     MOVE "block_age on full stone over 300 positions: the seven draws in the order of example 11.8 and each of the five results" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-BAD-COUNT TO WS-ED
     STRING FUNCTION TRIM(WS-ED) " " FUNCTION TRIM(WS-BAD-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "block_age on full stone: all five results occurred" TO WS-LABEL
     MOVE SPACES TO TL-OBSERVED
     IF WS-C1 > 0 AND WS-C2 > 0 AND WS-C3 > 0 AND WS-C4 > 0 AND WS-C5 > 0
         MOVE "all" TO TL-OBSERVED
     END-IF
     MOVE "all" TO TL-EXPECTED
     PERFORM ASSERT-TEXT.

 WANT-STAIRS-1.
     MOVE SPACES TO WS-WANT
     STRING "stone_brick_stairs|facing=" FUNCTION TRIM(WS-FACING-NAME(WS-F1 + 1)) ",half=" FUNCTION TRIM(WS-HALF-NAME(WS-H1 + 1))
         ",shape=straight,waterlogged=false" DELIMITED BY SIZE INTO WS-WANT.

 WANT-STAIRS-2.
     MOVE SPACES TO WS-WANT
     STRING "mossy_stone_brick_stairs|facing=" FUNCTION TRIM(WS-FACING-NAME(WS-F2 + 1)) ",half=" FUNCTION TRIM(WS-HALF-NAME(WS-H2 + 1))
         ",shape=straight,waterlogged=false" DELIMITED BY SIZE INTO WS-WANT.

*> IntProvider.sample against the same stream drawn by hand (23 section 7.1).
 CHECK-INT-PROVIDERS.
     MOVE "uniform 3 to 7: a + nextInt(5)" TO WS-LABEL
     MOVE 2 TO WS-IP-TYPE
     MOVE 3 TO WS-IA
     MOVE 7 TO WS-IB
     MOVE 0 TO WS-IC
     PERFORM IP-CASE
     MOVE "biased_to_bottom 2 to 12: min + nextInt(nextInt(11) + 1)" TO WS-LABEL
     MOVE 3 TO WS-IP-TYPE
     MOVE 2 TO WS-IA
     MOVE 12 TO WS-IB
     PERFORM IP-CASE
     MOVE "very_biased_to_bottom 0 to 10: three draws" TO WS-LABEL
     MOVE 4 TO WS-IP-TYPE
     MOVE 0 TO WS-IA
     MOVE 10 TO WS-IB
     PERFORM IP-CASE
     MOVE "trapezoid -4 to 4 plateau 2: min + nextInt(side + 1) + nextInt(slope + 1)" TO WS-LABEL
     MOVE 5 TO WS-IP-TYPE
     MOVE -4 TO WS-IA
     MOVE 4 TO WS-IB
     MOVE 2 TO WS-IC
     PERFORM IP-CASE
     MOVE "trapezoid -4 to 4 plateau 0: nextInt(5) - nextInt(5)" TO WS-LABEL
     MOVE 0 TO WS-IC
     PERFORM IP-CASE
     MOVE "trapezoid with the plateau as wide as the range: a uniform draw" TO WS-LABEL
     MOVE 1 TO WS-IA
     MOVE 5 TO WS-IB
     MOVE 4 TO WS-IC
     PERFORM IP-CASE
     MOVE "constant: the value, no draw" TO WS-LABEL
     MOVE 1 TO WS-IP-TYPE
     MOVE 9 TO WS-IA
     PERFORM IP-CASE.

 IP-CASE.
     MOVE 4242 TO WS-SEED
     CALL "JRAND-SET-SEED" USING WS-RNG WS-SEED
     MOVE WS-RNG TO WS-RNG2
     CALL "STRUCT-IP-SAMPLE" USING WS-IP-TYPE WS-IA WS-IB WS-IC WS-RNG WS-DRAW
     COMPUTE WS-SPAN = WS-IB - WS-IA + 1
     MOVE WS-IA TO WS-EXP
     EVALUATE WS-IP-TYPE
         WHEN 2
             CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG2 WS-SPAN WS-DRAW2
             COMPUTE WS-EXP = WS-IA + WS-DRAW2
         WHEN 3
             CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG2 WS-SPAN WS-DRAW2
             ADD 1 TO WS-DRAW2
             CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG2 WS-DRAW2 WS-DRAW3
             COMPUTE WS-EXP = WS-IA + WS-DRAW3
         WHEN 4
             CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG2 WS-SPAN WS-DRAW2
             ADD 1 TO WS-DRAW2
             CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG2 WS-DRAW2 WS-DRAW3
             ADD 1 TO WS-DRAW3
             CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG2 WS-DRAW3 WS-DRAW2
             COMPUTE WS-EXP = WS-IA + WS-DRAW2
         WHEN 5
             COMPUTE WS-RANGE = WS-IB - WS-IA
             IF WS-IC = 0 AND WS-IB = 0 - WS-IA
                 COMPUTE WS-BOUND = WS-IB + 1
                 CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG2 WS-BOUND WS-DRAW2
                 CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG2 WS-BOUND WS-DRAW3
                 COMPUTE WS-EXP = WS-DRAW2 - WS-DRAW3
             ELSE
                 IF WS-IC = WS-RANGE
                     CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG2 WS-SPAN WS-DRAW2
                     COMPUTE WS-EXP = WS-IA + WS-DRAW2
                 ELSE
                     COMPUTE WS-SLOPE = (WS-RANGE - WS-IC) / 2
                     COMPUTE WS-BOUND = WS-RANGE - WS-SLOPE + 1
                     CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG2 WS-BOUND WS-DRAW2
                     COMPUTE WS-BOUND = WS-SLOPE + 1
                     CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG2 WS-BOUND WS-DRAW3
                     COMPUTE WS-EXP = WS-IA + WS-DRAW2 + WS-DRAW3
                 END-IF
             END-IF
     END-EVALUATE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-DRAW TO WS-ED
     STRING FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED
     IF WS-RNG NOT = WS-RNG2
         MOVE "stream differs" TO TL-OBSERVED
     END-IF
     MOVE WS-EXP TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-EXPECTED
     PERFORM ASSERT-TEXT.

 COUNT-COBBLE.
     MOVE LOW-VALUES TO CE-STATES
     PERFORM PLACE
     MOVE 0 TO WS-A
     PERFORM VARYING WS-X FROM 4 BY 1 UNTIL WS-X > 6
         PERFORM VARYING WS-Y FROM 70 BY 1 UNTIL WS-Y > 72
             PERFORM VARYING WS-Z FROM 4 BY 1 UNTIL WS-Z > 6
                 CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                 MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
                 IF FUNCTION TRIM(CB-KEY(WS-BLOCK + 1)) = "cobblestone"
                     ADD 1 TO WS-A
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE WS-A TO WS-ED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED.
