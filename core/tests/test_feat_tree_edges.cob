*> Implementation test of the edges of the tree feature (core/src/feat-tree.cob, feat-data.cob, feat-run.cob): every thing the tree compiler refuses, the int provider and predicate
*> shapes the compiler refuses, trees refused by the build height, the room or the work grid, a log in the way, no soil under bedrock, leaves of a block without the distance layout,
*> and a random_selector without a usable default tree.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-TREE-EDGES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY CELLS.
 COPY CONTENT.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY XORO.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/trees".
 01 WS-REG-DIR             PIC X(1100) VALUE "core/tests/fixtures/feat-registry".
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-FT                  BINARY-LONG.
 01 WS-PF                  BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-TOP                 BINARY-LONG VALUE 0.
 01 WS-LOGS                BINARY-LONG.
 01 WS-LEAVES              BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-STATE-NO            BINARY-LONG.
 01 WS-NONAIR              BINARY-LONG.
 01 WS-SUM-A               BINARY-LONG.
 01 WS-SUM-B               BINARY-LONG.
 01 WS-TREES               BINARY-LONG.
 01 WS-REG                 PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112).
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 8 TIMES.
 01 WS-LAST                BINARY-LONG.
 01 WS-SAVED               BINARY-LONG.
 01 WS-A                   PIC X(196608) BASED.
 01 WS-SNAP                PIC X(196608).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM BUILD-TABLE
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "REGISTRY-LOAD-ALL" USING WS-REG-DIR WS-STATUS
     MOVE 1 TO CT-OPEN
     MOVE "minecraft:logs" TO WS-TAG
     MOVE 4 TO WS-ID(1)
     MOVE 6 TO WS-ID(2)
     MOVE 8 TO WS-ID(3)
     MOVE 3 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "minecraft:replaceable_by_trees" TO WS-TAG
     MOVE 0 TO WS-ID(1)
     MOVE 12 TO WS-ID(2)
     MOVE 13 TO WS-ID(3)
     MOVE 5 TO WS-ID(4)
     MOVE 7 TO WS-ID(5)
     MOVE 9 TO WS-ID(6)
     MOVE 6 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "minecraft:cannot_replace_below_tree_trunk" TO WS-TAG
     MOVE 14 TO WS-ID(1)
     MOVE 1 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "minecraft:supports_vegetation" TO WS-TAG
     MOVE 3 TO WS-ID(1)
     MOVE 2 TO WS-ID(2)
     MOVE 2 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"

*>   features the tree compiler refuses
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE SPACES TO WS-KEY
         EVALUATE WS-I
             WHEN 1 MOVE "minecraft:bad_root" TO WS-KEY
             WHEN 2 MOVE "minecraft:bad_deco" TO WS-KEY
             WHEN 3 MOVE "minecraft:bad_below" TO WS-KEY
             WHEN 4 MOVE "minecraft:bad_trunk" TO WS-KEY
             WHEN 5 MOVE "minecraft:bad_state" TO WS-KEY
             WHEN 6 MOVE "minecraft:bad_leaf" TO WS-KEY
             WHEN 7 MOVE "minecraft:bad_size" TO WS-KEY
             WHEN 8 MOVE "minecraft:bad_clipped" TO WS-KEY
             WHEN 9 MOVE "minecraft:bad_foliage" TO WS-KEY
             WHEN 10 MOVE "minecraft:bad_ip" TO WS-KEY
         END-EVALUATE
         CALL "FD-GET-FT" USING WS-KEY WS-FT
         CALL "FD-ENSURE-FT" USING WS-FT
         MOVE SPACES TO TL-CASE
         STRING "test feat tree edges " FUNCTION TRIM(WS-KEY) " is flagged unsupported and has type -1" DELIMITED BY SIZE INTO TL-CASE
         COMPUTE TL-OBSERVED-N = FD-BAD * 10 - FT-TYPE(WS-FT)
         MOVE 11 TO TL-EXPECTED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE "minecraft:unsupported_ft" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "test feat tree edges a feature type the compiler does not know is flagged unsupported (type -1)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FT-TYPE(WS-FT) - FD-BAD
     MOVE -2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE FD-TR-COUNT TO WS-SAVED
     MOVE 256 TO FD-TR-COUNT
     MOVE "minecraft:oak_bees_005" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "test feat tree edges a full tree table flags the next tree unsupported" TO TL-CASE
     MOVE FD-BAD TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-SAVED TO FD-TR-COUNT

*>   placed features: status 1 compiled, 2 unsupported
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE SPACES TO WS-KEY
         EVALUATE WS-I
             WHEN 1 MOVE "minecraft:wl_nodist" TO WS-KEY
             WHEN 2 MOVE "minecraft:wl_baddata" TO WS-KEY
             WHEN 3 MOVE "minecraft:wl_noweight" TO WS-KEY
             WHEN 4 MOVE "minecraft:wl_obj" TO WS-KEY
             WHEN 5 MOVE "minecraft:surv_nostate" TO WS-KEY
             WHEN 6 MOVE "minecraft:surv_stone" TO WS-KEY
             WHEN 7 MOVE "minecraft:surv_short" TO WS-KEY
             WHEN 8 MOVE "minecraft:wl_zero" TO WS-KEY
         END-EVALUATE
         CALL "FD-GET-PF" USING WS-KEY WS-PF
         CALL "FD-ENSURE-PF" USING WS-PF
         MOVE SPACES TO TL-CASE
         STRING "test feat tree edges " FUNCTION TRIM(WS-KEY) " compiles as expected" DELIMITED BY SIZE INTO TL-CASE
         MOVE PF-STATUS(WS-PF) TO TL-OBSERVED-N
         IF WS-I = 4 OR WS-I = 8
             MOVE 1 TO TL-EXPECTED-N
         ELSE
             MOVE 2 TO TL-EXPECTED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   a weighted_list whose weights are all 0 draws nothing and gives the count 0
     PERFORM NEW-WORLD
     MOVE 24 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 40 TO WS-Z
     MOVE WS-PF TO WS-TOP
     CALL "FR-PLACE-PF" USING XR-STATE WS-PF WS-TOP WS-X WS-Y WS-Z WS-RESULT
     MOVE "test feat tree edges a weighted_list of total weight 0 gives the count 0: nothing is placed" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:wl_obj" TO WS-KEY
     CALL "FD-GET-PF" USING WS-KEY WS-PF
     MOVE WS-PF TO WS-TOP
     PERFORM NEW-WORLD
     CALL "FR-PLACE-PF" USING XR-STATE WS-PF WS-TOP WS-X WS-Y WS-Z WS-RESULT
     MOVE "test feat tree edges a weighted_list with a constant provider as data gives its count (one tree)" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   refused trees: the work grid, the build height, the room
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE SPACES TO WS-KEY
         MOVE 63 TO WS-Y
         EVALUATE WS-I
             WHEN 1 MOVE "minecraft:wide_blob7" TO WS-KEY
             WHEN 2 MOVE "minecraft:wide_blob" TO WS-KEY
             WHEN 3 MOVE "minecraft:oak" TO WS-KEY
             WHEN 4 MOVE "minecraft:tall_oak" TO WS-KEY
         END-EVALUATE
         IF WS-I = 3
             MOVE -64 TO WS-Y
         END-IF
         IF WS-I = 4
             MOVE 300 TO WS-Y
         END-IF
         CALL "FD-GET-FT" USING WS-KEY WS-FT
         PERFORM NEW-WORLD
         MOVE 24 TO WS-X
         MOVE 40 TO WS-Z
         PERFORM PLACE-TREE
         MOVE SPACES TO TL-CASE
         STRING "test feat tree edges " FUNCTION TRIM(WS-KEY) " is refused here" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-RESULT TO TL-OBSERVED-N
         MOVE 0 TO TL-EXPECTED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE "test feat tree edges a refused wide tree writes nothing (the floor is untouched)" TO TL-CASE
     PERFORM NEW-WORLD
     MOVE "minecraft:wide_blob" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 24 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 40 TO WS-Z
     PERFORM PLACE-TREE
     PERFORM COUNT-NON-AIR
     MOVE WS-NONAIR TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a tree with its own lower_size reads it
     MOVE "minecraft:size_lower" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     PERFORM NEW-WORLD
     MOVE 24 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 40 TO WS-Z
     PERFORM PLACE-TREE
     MOVE "test feat tree edges a tree with lower_size 1 and limit 2 is placed on open ground" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a log of another tree in the way does not block the room (isFree accepts logs)
     MOVE "minecraft:oak" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     PERFORM NEW-WORLD
     MOVE 25 TO WS-LX
     MOVE 65 TO WS-LY
     MOVE 40 TO WS-LZ
     MOVE CB-DEFAULT-STATE(5) TO WS-STATE
     CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
     MOVE 24 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 40 TO WS-Z
     PERFORM PLACE-TREE
     MOVE "test feat tree edges a log beside the trunk does not block the tree" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   bedrock under the trunk is in cannot_replace_below_tree_trunk: no soil
     PERFORM NEW-WORLD
     MOVE 24 TO WS-LX
     MOVE 62 TO WS-LY
     MOVE 40 TO WS-LZ
     MOVE CB-DEFAULT-STATE(15) TO WS-STATE
     CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
     MOVE 24 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 40 TO WS-Z
     PERFORM PLACE-TREE
     CALL "FL-GET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     MOVE "test feat tree edges bedrock under the trunk stays bedrock (no soil)" TO TL-CASE
     MOVE WS-BLOCK TO TL-OBSERVED-N
     MOVE 15 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   leaves of a block without the 7 x 4 state layout keep their default state
     PERFORM NEW-WORLD
     MOVE 1 TO CB-STATES(6)
     MOVE 24 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 40 TO WS-Z
     PERFORM PLACE-TREE
     MOVE 28 TO CB-STATES(6)
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-LEAVES
     PERFORM VARYING WS-LY FROM 63 BY 1 UNTIL WS-LY > 80
         PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
             PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
                 CALL "FL-GET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE
                 CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                 IF WS-BLOCK = 6
                     ADD 1 TO WS-LEAVES
                     IF WS-STATE NOT = CB-DEFAULT-STATE(6)
                         ADD 1 TO WS-BAD
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "test feat tree edges leaves of a block with one state are all its default state" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-BAD = 0 AND WS-LEAVES > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a random_selector whose chosen child is unsupported places its default tree only when the default is a tree
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE SPACES TO WS-KEY
         EVALUATE WS-I
             WHEN 1 MOVE "minecraft:sel_nodefault" TO WS-KEY
             WHEN 2 MOVE "minecraft:sel_baddefault" TO WS-KEY
             WHEN 3 MOVE "minecraft:sel_noop" TO WS-KEY
         END-EVALUATE
         CALL "FD-GET-FT" USING WS-KEY WS-FT
         PERFORM NEW-WORLD
         MOVE 24 TO WS-X
         MOVE 63 TO WS-Y
         MOVE 40 TO WS-Z
         PERFORM PLACE-TREE
         PERFORM COUNT-NON-AIR
         MOVE SPACES TO TL-CASE
         STRING "test feat tree edges " FUNCTION TRIM(WS-KEY) " places nothing" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-NONAIR TO TL-OBSERVED-N
         MOVE 0 TO TL-EXPECTED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   a chosen child that is a placed feature the compiler refuses (a modifier it does not know) also falls back to the default tree
     MOVE "minecraft:sel_badpf" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     PERFORM NEW-WORLD
     MOVE 24 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 40 TO WS-Z
     PERFORM PLACE-TREE
     MOVE "test feat tree edges sel_badpf: the unsupported chosen placed feature gives way to the default tree" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 BUILD-TABLE.
*>   1 air, 2 stone, 3 grass_block, 4 dirt, 5 oak_log, 6 oak_leaves, 7 birch_log, 8 birch_leaves, 9 spruce_log, 10 spruce_leaves, 11 oak_sapling, 12 water, 13 cave_air,
*>   14 void_air, 15 bedrock, 16 lava. Logs have 3 states (default axis y, the second), leaves 28 (distance 1 to 7, persistent, waterlogged; default the last).
     MOVE 16 TO CB-BLOCK-COUNT
     MOVE 9 TO CB-EPOCH
     MOVE 0 TO WS-STATE-NO
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         EVALUATE WS-I
             WHEN 5
             WHEN 7
             WHEN 9
                 MOVE 3 TO WS-N
                 MOVE 1 TO WS-D
             WHEN 6
             WHEN 8
             WHEN 10
                 MOVE 28 TO WS-N
                 MOVE 27 TO WS-D
             WHEN OTHER
                 MOVE 1 TO WS-N
                 MOVE 0 TO WS-D
         END-EVALUATE
         MOVE WS-STATE-NO TO CB-FIRST-STATE(WS-I)
         MOVE WS-N TO CB-STATES(WS-I)
         COMPUTE CB-DEFAULT-STATE(WS-I) = WS-STATE-NO + WS-D
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X >= WS-N
             COMPUTE WS-Y = WS-STATE-NO + WS-X + 1
             COMPUTE CB-S-BLOCK(WS-Y) = WS-I - 1
         END-PERFORM
         ADD WS-N TO WS-STATE-NO
         MOVE 0 TO CB-SOLID(WS-I)
     END-PERFORM
     MOVE WS-STATE-NO TO CB-STATE-COUNT
     MOVE 1 TO CB-SOLID(2)
     MOVE 1 TO CB-SOLID(3)
     MOVE 1 TO CB-SOLID(4)
     MOVE 1 TO CB-SOLID(15)
     MOVE "minecraft:air" TO CB-KEY(1)
     MOVE "minecraft:stone" TO CB-KEY(2)
     MOVE "minecraft:grass_block" TO CB-KEY(3)
     MOVE "minecraft:dirt" TO CB-KEY(4)
     MOVE "minecraft:oak_log" TO CB-KEY(5)
     MOVE "minecraft:oak_leaves" TO CB-KEY(6)
     MOVE "minecraft:birch_log" TO CB-KEY(7)
     MOVE "minecraft:birch_leaves" TO CB-KEY(8)
     MOVE "minecraft:spruce_log" TO CB-KEY(9)
     MOVE "minecraft:spruce_leaves" TO CB-KEY(10)
     MOVE "minecraft:oak_sapling" TO CB-KEY(11)
     MOVE "minecraft:water" TO CB-KEY(12)
     MOVE "minecraft:cave_air" TO CB-KEY(13)
     MOVE "minecraft:void_air" TO CB-KEY(14)
     MOVE "minecraft:bedrock" TO CB-KEY(15)
     MOVE "minecraft:lava" TO CB-KEY(16)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CB-KEY(WS-I))) TO CB-KEY-LENGTH(WS-I)
     END-PERFORM
     .
 NEW-WORLD.
*>   an empty chunk (1, 2) with a grass floor at y = 62; air is state 0
     SET ADDRESS OF WS-A TO WS-PTR
     MOVE LOW-VALUES TO WS-A
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
         PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
             MOVE 62 TO WS-LY
             MOVE CB-DEFAULT-STATE(3) TO WS-STATE
             CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
         END-PERFORM
     END-PERFORM
     MOVE 11 TO WS-SEED
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     .
 PLACE-TREE.
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     .
 COUNT-NON-AIR.
     MOVE 0 TO WS-NONAIR
     PERFORM VARYING WS-LY FROM 63 BY 1 UNTIL WS-LY > 90
         PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
             PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
                 CALL "FL-GET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE
                 IF WS-STATE NOT = 0
                     ADD 1 TO WS-NONAIR
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 62 TO WS-LY
     PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
         PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
             CALL "FL-GET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE
             IF WS-STATE NOT = CB-DEFAULT-STATE(3)
                 ADD 1 TO WS-NONAIR
             END-IF
         END-PERFORM
     END-PERFORM
     .
 END PROGRAM TEST-FEAT-TREE-EDGES.

 COPY CORETEST.
