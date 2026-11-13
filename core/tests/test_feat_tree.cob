*> Implementation test of the tree feature (core/src/feat-tree.cob; docs/protocol/35-worldgen-features-3 sections 2, 3, 4.1 and 5.2): the data features oak, birch, spruce and pine
*> compile as type 51; an oak placed on grass has a straight trunk of 4 to 6 logs, soil under it, the blob leaves of the worked example (5 leaves in the top row), every leaf at its
*> distance from the nearest log (section 2.4), not persistent and not waterlogged; a tree whose leaves would cross the chunk border or that meets an obstruction places nothing and
*> writes nothing; the weighted_list count, the would_survive sapling predicate and the random_selector fallback to the default tree of a missing variant.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-TREE.
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

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         EVALUATE WS-I
             WHEN 1
                 MOVE "minecraft:oak" TO WS-KEY
             WHEN 2
                 MOVE "minecraft:birch" TO WS-KEY
             WHEN 3
                 MOVE "minecraft:spruce" TO WS-KEY
             WHEN 4
                 MOVE "minecraft:pine" TO WS-KEY
         END-EVALUATE
         CALL "FD-GET-FT" USING WS-KEY WS-FT
         CALL "FD-ENSURE-FT" USING WS-FT
         MOVE SPACES TO TL-CASE
         STRING "test feat tree the data feature " FUNCTION TRIM(WS-KEY) " compiles as a tree (type 51)" DELIMITED BY SIZE INTO TL-CASE
         MOVE FT-TYPE(WS-FT) TO TL-OBSERVED-N
         MOVE 51 TO TL-EXPECTED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   an oak on grass at (24, 63, 40)
     MOVE "minecraft:oak" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 11 TO WS-SEED
     PERFORM NEW-WORLD
     MOVE 24 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 40 TO WS-Z
     PERFORM PLACE-TREE
     MOVE "test feat tree an oak placed on open grass is placed" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the trunk column
     MOVE 0 TO WS-H
     PERFORM VARYING WS-LY FROM 63 BY 1 UNTIL WS-LY > 80
         MOVE 24 TO WS-LX
         MOVE 40 TO WS-LZ
         CALL "FL-GET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE
         CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
         IF WS-BLOCK = 5 AND WS-H = WS-LY - 63
             ADD 1 TO WS-H
         END-IF
     END-PERFORM
     MOVE "test feat tree the straight trunk of an oak has 4 to 6 logs (base 4, random 2)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-H >= 4 AND WS-H <= 6
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the top row at y = 63 + H: 5 leaves (blob radius 1, corners skipped)
     MOVE 0 TO WS-LEAVES
     COMPUTE WS-LY = 63 + WS-H
     PERFORM VARYING WS-DX FROM -3 BY 1 UNTIL WS-DX > 3
         PERFORM VARYING WS-DZ FROM -3 BY 1 UNTIL WS-DZ > 3
             COMPUTE WS-LX = 24 + WS-DX
             COMPUTE WS-LZ = 40 + WS-DZ
             CALL "FL-GET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE
             CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
             IF WS-BLOCK = 6
                 ADD 1 TO WS-LEAVES
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "test feat tree the top leaf row of an oak has 5 leaves (docs 35-3 section 8, example 1)" TO TL-CASE
     MOVE WS-LEAVES TO TL-OBSERVED-N
     MOVE 5 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   soil
     MOVE 62 TO WS-LY
     MOVE 24 TO WS-LX
     MOVE 40 TO WS-LZ
     CALL "FL-GET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     MOVE "test feat tree the grass under the trunk becomes dirt (soil_beneath_tree)" TO TL-CASE
     MOVE WS-BLOCK TO TL-OBSERVED-N
     MOVE 4 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   every leaf: distance = manhattan distance to the nearest log (capped at 7), persistent false, waterlogged false
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-LEAVES
     PERFORM VARYING WS-LY FROM 63 BY 1 UNTIL WS-LY > 80
         PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
             PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
                 CALL "FL-GET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE
                 CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                 IF WS-BLOCK = 6
                     ADD 1 TO WS-LEAVES
                     COMPUTE WS-STATE-NO = WS-STATE - CB-FIRST-STATE(6)
                     COMPUTE WS-D = WS-STATE-NO / 4 + 1
                     COMPUTE WS-N = FUNCTION MOD(WS-STATE-NO, 4)
                     MOVE 7 TO WS-BEST
                     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-H
                         COMPUTE WS-DX = FUNCTION ABS(WS-LX - 24) + FUNCTION ABS(WS-LZ - 40) + FUNCTION ABS(WS-LY - 63 - WS-I)
                         IF WS-DX < WS-BEST
                             MOVE WS-DX TO WS-BEST
                         END-IF
                     END-PERFORM
                     IF WS-D NOT = WS-BEST OR WS-N NOT = 3
                         ADD 1 TO WS-BAD
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "test feat tree every leaf has its distance to the nearest log, persistent false, waterlogged false" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test feat tree an oak has between 40 and 70 leaves" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-LEAVES >= 40 AND WS-LEAVES <= 70
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   determinism: the same seed gives the same chunk
     SET ADDRESS OF WS-A TO WS-PTR
     MOVE WS-A TO WS-SNAP
     PERFORM NEW-WORLD
     MOVE 24 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 40 TO WS-Z
     PERFORM PLACE-TREE
     MOVE "test feat tree the same seed gives the same tree, byte for byte" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-A = WS-SNAP
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the chunk border: the leaves of a tree at x = 17 would reach x = 15 (the chunk of x 16 to 31 starts at 16)
     PERFORM NEW-WORLD
     MOVE 17 TO WS-X
     PERFORM PLACE-TREE
     MOVE "test feat tree a tree whose leaves would cross the chunk border is not placed" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM COUNT-NON-AIR
     MOVE "test feat tree a refused tree writes nothing (no logs, leaves or soil)" TO TL-CASE
     MOVE WS-NONAIR TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   an obstruction at y = 3 above the origin gives a free height of 1: not placed
     PERFORM NEW-WORLD
     MOVE 24 TO WS-LX
     MOVE 66 TO WS-LY
     MOVE 40 TO WS-LZ
     MOVE 1 TO WS-STATE
     CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
     MOVE 24 TO WS-X
     PERFORM PLACE-TREE
     MOVE "test feat tree a tree with an obstruction 3 above the origin (free height 1) is not placed" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   birch, spruce and pine place their own logs and leaves
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 4
         EVALUATE WS-I
             WHEN 2
                 MOVE "minecraft:birch" TO WS-KEY
             WHEN 3
                 MOVE "minecraft:spruce" TO WS-KEY
             WHEN 4
                 MOVE "minecraft:pine" TO WS-KEY
         END-EVALUATE
         CALL "FD-GET-FT" USING WS-KEY WS-FT
         PERFORM NEW-WORLD
         MOVE 24 TO WS-X
         MOVE 63 TO WS-Y
         MOVE 40 TO WS-Z
         PERFORM PLACE-TREE
         MOVE SPACES TO TL-CASE
         STRING "test feat tree " FUNCTION TRIM(WS-KEY) " is placed" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-RESULT TO TL-OBSERVED-N
         MOVE 1 TO TL-EXPECTED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE 0 TO WS-LOGS
         MOVE 0 TO WS-LEAVES
         MOVE 0 TO WS-BAD
         PERFORM VARYING WS-LY FROM 63 BY 1 UNTIL WS-LY > 85
             PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
                 PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
                     CALL "FL-GET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE
                     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                     COMPUTE WS-N = 2 * FUNCTION MIN(WS-I, 3) + 3
                     COMPUTE WS-D = WS-N + 1
                     EVALUATE TRUE
                         WHEN WS-BLOCK = WS-N
                             ADD 1 TO WS-LOGS
                         WHEN WS-BLOCK = WS-D
                             ADD 1 TO WS-LEAVES
                         WHEN WS-BLOCK NOT = 1
                             ADD 1 TO WS-BAD
                     END-EVALUATE
                 END-PERFORM
             END-PERFORM
         END-PERFORM
         MOVE SPACES TO TL-CASE
         STRING "test feat tree " FUNCTION TRIM(WS-KEY) " has only its own logs and leaves, at least 5 logs and 15 leaves" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO TL-OBSERVED-N
         IF WS-BAD = 0 AND WS-LOGS >= 5 AND WS-LEAVES >= 15
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         MOVE 1 TO TL-EXPECTED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   the placed feature: weighted_list count, would_survive sapling, random_selector falling back to the default tree
     MOVE "minecraft:tree_here" TO WS-KEY
     CALL "FD-GET-PF" USING WS-KEY WS-PF
     CALL "FD-ENSURE-PF" USING WS-PF
     MOVE "test feat tree a placed feature with a weighted_list count and a would_survive sapling filter compiles" TO TL-CASE
     MOVE PF-STATUS(WS-PF) TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-TREES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         COMPUTE WS-SEED = 100 + WS-I
         PERFORM NEW-WORLD
         MOVE 24 TO WS-X
         MOVE 63 TO WS-Y
         MOVE 40 TO WS-Z
         CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
         CALL "FR-PLACE-PF" USING XR-STATE WS-PF WS-TOP WS-X WS-Y WS-Z WS-RESULT
         ADD WS-RESULT TO WS-TREES
     END-PERFORM
     MOVE "test feat tree the placed feature places a tree on grass for every seed (the missing variant falls back to the default tree)" TO TL-CASE
     MOVE WS-TREES TO TL-OBSERVED-N
     MOVE 6 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   on stone a sapling cannot survive
     PERFORM NEW-WORLD
     PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
         PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
             MOVE 62 TO WS-LY
             MOVE 1 TO WS-STATE
             CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
         END-PERFORM
     END-PERFORM
     MOVE 24 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 40 TO WS-Z
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "FR-PLACE-PF" USING XR-STATE WS-PF WS-TOP WS-X WS-Y WS-Z WS-RESULT
     MOVE "test feat tree the would_survive sapling filter refuses a tree on stone" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
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
 END PROGRAM TEST-FEAT-TREE.

 COPY CORETEST.
