*> Implementation test of the mangrove tree (docs/protocol/35-worldgen-features-3-tree-placers.md section 4.8 upwards branching trunk, section 6 root placers and 6.1 the mangrove root placer,
*> section 2.2 min_clipped_height; core/src/feat-tree.cob, feat-tree-trunk.cob, feat-tree-root.cob): the data feature compiles as a tree, a tree on a mud floor has its trunk column of H logs from the
*> trunk origin (3 above the ground), the root under the trunk and the four roots beside its foot, muddy roots where the roots enter mud, branches off the trunk column, moss above some roots,
*> leaves; a root path that never ends (mud all the way down) refuses the tree; a clipped tree is built when the free height reaches min_clipped_height and refused below it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-3-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY CELLS.
 COPY CONTENT.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY XORO.
 COPY XORO REPLACING ==XR-STATE== BY ==XR2-STATE== LEADING ==XR-== BY ==X2-==.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/tree-types".
 01 WS-REG-DIR             PIC X(1100) VALUE "core/tests/fixtures/feat-registry".
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-FT                  BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LOGB                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-RA                  BINARY-LONG.
 01 WS-RB                  BINARY-LONG.
 01 WS-SEEDS-OK            BINARY-LONG.
 01 WS-OFFCOL              BINARY-LONG.
 01 WS-MUDDY               BINARY-LONG.
 01 WS-MOSS                BINARY-LONG.
 01 WS-ROOTS               BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-TX                  BINARY-LONG VALUE 24.
 01 WS-CASE                PIC X(200).
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-STATE-NO            BINARY-LONG.
 01 WS-REG                 PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112).
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 8 TIMES.
 01 WS-A                   PIC X(196608) BASED.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM BUILD-TABLE
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "REGISTRY-LOAD-ALL" USING WS-REG-DIR WS-STATUS
     MOVE 1 TO CT-OPEN
     MOVE "minecraft:logs" TO WS-TAG
     MOVE 4 TO WS-ID(1)
     MOVE 1 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "minecraft:replaceable_by_trees" TO WS-TAG
     MOVE 0 TO WS-ID(1)
     MOVE 5 TO WS-ID(2)
     MOVE 10 TO WS-ID(3)
     MOVE 3 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "minecraft:cannot_replace_below_tree_trunk" TO WS-TAG
     MOVE 1 TO WS-ID(1)
     MOVE 1 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "minecraft:leaves" TO WS-TAG
     MOVE 5 TO WS-ID(1)
     MOVE 1 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "minecraft:mangrove_logs_can_grow_through" TO WS-TAG
     MOVE 6 TO WS-ID(1)
     MOVE 7 TO WS-ID(2)
     MOVE 5 TO WS-ID(3)
     MOVE 9 TO WS-ID(4)
     MOVE 4 TO WS-ID(5)
     MOVE 5 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"

*>   the data feature compiles as a tree (type 51)
     MOVE "minecraft:t_mangrove" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-3§4.8 and 6.1: the mangrove feature with the upwards branching trunk and the root placer compiles as a tree" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 51 TO WS-EXP
     PERFORM ASSERT-N

*>   thirty trees on a mud floor over stone
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-SEEDS-OK
     MOVE 0 TO WS-OFFCOL
     MOVE 0 TO WS-MUDDY
     MOVE 0 TO WS-MOSS
     MOVE 5 TO WS-BASE
     MOVE 2 TO WS-RA
     MOVE 1 TO WS-RB
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         MOVE WS-I TO WS-SEED
         MOVE 0 TO WS-FLOOR
         PERFORM NEW-WORLD
         PERFORM PLACE-TREE
         MOVE 8 TO WS-LOGB
         PERFORM COUNT-LOGS
         IF WS-RESULT = 1
             ADD 1 TO WS-SEEDS-OK
             PERFORM REDRAW-HEIGHT
*>           the trunk column: H logs from y = 66 (the ground is 62, the origin 63, the trunk origin 3 above it)
             MOVE 24 TO WS-LX
             MOVE 40 TO WS-LZ
             PERFORM VARYING WS-LY FROM 66 BY 1 UNTIL WS-LY >= 66 + WS-H
                 PERFORM READ-BLOCK
                 IF WS-BLOCK NOT = 5
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
             MOVE 5 TO WS-LOGB
             PERFORM COUNT-LOGS
             IF WS-COUNT > WS-H
                 ADD 1 TO WS-OFFCOL
             END-IF
*>           the root under the trunk and the four beside its foot
             MOVE 24 TO WS-LX
             MOVE 40 TO WS-LZ
             MOVE 65 TO WS-LY
             PERFORM READ-BLOCK
             IF WS-BLOCK NOT = 8
                 ADD 1 TO WS-BAD
             END-IF
             MOVE 66 TO WS-LY
             MOVE 23 TO WS-LX
             MOVE 40 TO WS-LZ
             PERFORM READ-BLOCK
             IF WS-BLOCK NOT = 8 AND WS-BLOCK NOT = 10
                 ADD 1 TO WS-BAD
             END-IF
             MOVE 25 TO WS-LX
             PERFORM READ-BLOCK
             IF WS-BLOCK NOT = 8 AND WS-BLOCK NOT = 10
                 ADD 1 TO WS-BAD
             END-IF
             MOVE 24 TO WS-LX
             MOVE 39 TO WS-LZ
             PERFORM READ-BLOCK
             IF WS-BLOCK NOT = 8 AND WS-BLOCK NOT = 10
                 ADD 1 TO WS-BAD
             END-IF
             MOVE 41 TO WS-LZ
             PERFORM READ-BLOCK
             IF WS-BLOCK NOT = 8 AND WS-BLOCK NOT = 10
                 ADD 1 TO WS-BAD
             END-IF
             MOVE 9 TO WS-LOGB
             PERFORM COUNT-LOGS
             ADD WS-COUNT TO WS-MUDDY
             MOVE 10 TO WS-LOGB
             PERFORM COUNT-LOGS
             ADD WS-COUNT TO WS-MOSS
             MOVE 6 TO WS-LOGB
             PERFORM COUNT-LOGS
             IF WS-COUNT = 0
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM
     MOVE "35-3§6.1: at least twelve of thirty mangroves on a mud floor are placed (a root path longer than 15 refuses the tree)" TO WS-CASE
     MOVE WS-SEEDS-OK TO WS-OBS
     IF WS-SEEDS-OK >= 12
         MOVE 1 TO WS-OBS
     ELSE
         MOVE 0 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-3§4.8 and 6.1: every placed mangrove has its trunk column of H logs, the root under it, four roots (or the moss a root below put there first) beside its foot, and leaves" TO WS-CASE
     MOVE WS-BAD TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-3§4.8: some mangroves have branch logs off the trunk column" TO WS-CASE
     IF WS-OFFCOL > 3
         MOVE 1 TO WS-OBS
     ELSE
         MOVE 0 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-3§6.1: roots that enter the mud are muddy roots" TO WS-CASE
     IF WS-MUDDY > 10
         MOVE 1 TO WS-OBS
     ELSE
         MOVE 0 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-3§6: the above root placement puts moss on some roots" TO WS-CASE
     IF WS-MOSS > 3
         MOVE 1 TO WS-OBS
     ELSE
         MOVE 0 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   a tree one cell from the chunk border: the roots end at the border (cells outside the chunk are not placeable), so most trees are still placed
     MOVE 17 TO WS-TX
     MOVE 0 TO WS-SEEDS-OK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         MOVE WS-I TO WS-SEED
         MOVE 0 TO WS-FLOOR
         PERFORM NEW-WORLD
         PERFORM PLACE-TREE
         ADD WS-RESULT TO WS-SEEDS-OK
     END-PERFORM
     MOVE 24 TO WS-TX
     MOVE "35-3§6.1: at least twelve of thirty mangroves at the chunk border are placed (the roots end at the border)" TO WS-CASE
     IF WS-SEEDS-OK >= 12
         MOVE 1 TO WS-OBS
     ELSE
         MOVE 0 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N

*>   a mangrove in water: the root under the trunk is waterlogged (the first state of the two), a root in dry air is not
     MOVE 2 TO WS-FLOOR
     MOVE 3 TO WS-SEED
     PERFORM NEW-WORLD
     PERFORM PLACE-TREE
     MOVE "35-3§6.1: a mangrove placed in water is placed" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 24 TO WS-LX
     MOVE 40 TO WS-LZ
     MOVE 65 TO WS-LY
     CALL "FL-GET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE
     MOVE "35-3§6: the root under the trunk of a mangrove in water is waterlogged" TO WS-CASE
     MOVE WS-STATE TO WS-OBS
     MOVE CB-FIRST-STATE(8) TO WS-EXP
     PERFORM ASSERT-N
     MOVE 3 TO WS-SEED
     MOVE 0 TO WS-FLOOR
     PERFORM NEW-WORLD
     PERFORM PLACE-TREE
     MOVE 24 TO WS-LX
     MOVE 40 TO WS-LZ
     MOVE 65 TO WS-LY
     CALL "FL-GET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE
     MOVE "35-3§6: the root under the trunk of a mangrove in air is not waterlogged" TO WS-CASE
     MOVE WS-STATE TO WS-OBS
     MOVE CB-DEFAULT-STATE(8) TO WS-EXP
     PERFORM ASSERT-N

*>   a root path that never ends (mud down to the bottom of the world) fails the tree and no log is written
     MOVE 1 TO WS-FLOOR
     MOVE 7 TO WS-SEED
     PERFORM NEW-WORLD
     PERFORM PLACE-TREE
     MOVE "35-3§6.1: roots that reach the length limit refuse the tree" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 5 TO WS-LOGB
     PERFORM COUNT-LOGS
     MOVE "35-3§6.1: a refused mangrove has no log" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   a block of can_grow_through (moss) in the trunk column does not clip the free height and the trunk log replaces it
     MOVE 0 TO WS-FLOOR
     MOVE 3 TO WS-SEED
     PERFORM NEW-WORLD
     MOVE 24 TO WS-LX
     MOVE 68 TO WS-LY
     MOVE 40 TO WS-LZ
     MOVE CB-DEFAULT-STATE(10) TO WS-STATE
     CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
     PERFORM PLACE-TREE
     MOVE "35-4§4.8: a mangrove with a can_grow_through block in its trunk column is placed" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 24 TO WS-LX
     MOVE 68 TO WS-LY
     MOVE 40 TO WS-LZ
     PERFORM READ-BLOCK
     MOVE "35-3§4.8: the trunk log replaced the can_grow_through block" TO WS-CASE
     MOVE WS-BLOCK TO WS-OBS
     MOVE 5 TO WS-EXP
     PERFORM ASSERT-N

*>   a tall obstacle leaves the roots' step 1: a stone in the root column between the ground and the trunk origin refuses the tree
     MOVE 0 TO WS-FLOOR
     MOVE 7 TO WS-SEED
     PERFORM NEW-WORLD
     MOVE 24 TO WS-LX
     MOVE 64 TO WS-LY
     MOVE 40 TO WS-LZ
     MOVE 2 TO WS-STATE
     CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
     PERFORM PLACE-TREE
     MOVE "35-3§6.1: a solid block between the ground and the trunk origin refuses the tree" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N

*>   2.2 min_clipped_height: H = 6, a block beside the trunk at layer 5 gives a free height of 3
     MOVE "minecraft:t_clip2" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     MOVE 5 TO WS-SEED
     MOVE 0 TO WS-FLOOR
     PERFORM NEW-WORLD-GRASS
     MOVE 25 TO WS-LX
     MOVE 68 TO WS-LY
     MOVE 40 TO WS-LZ
     MOVE 2 TO WS-STATE
     CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
     PERFORM PLACE-TREE-GRASS
     MOVE "35-3§2.2: a tree clipped to 3 of 6 is built when min_clipped_height is 2" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 5 TO WS-LOGB
     PERFORM COUNT-LOGS
     MOVE "35-3§2.2: the clipped trunk has the free height (3) as its height" TO WS-CASE
     MOVE WS-COUNT TO WS-OBS
     MOVE 3 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "minecraft:t_clip4" TO WS-KEY
     CALL "FD-GET-FT" USING WS-KEY WS-FT
     PERFORM NEW-WORLD-GRASS
     MOVE 25 TO WS-LX
     MOVE 68 TO WS-LY
     MOVE 40 TO WS-LZ
     MOVE 2 TO WS-STATE
     CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
     PERFORM PLACE-TREE-GRASS
     MOVE "35-3§2.2: the same tree is refused when min_clipped_height is 4" TO WS-CASE
     MOVE WS-RESULT TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN.

 REDRAW-HEIGHT.
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     CALL "F353-TREE-HEIGHT" USING XR2-STATE WS-BASE WS-RA WS-RB WS-H
     .
 READ-BLOCK.
     CALL "FL-GET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     .
 COUNT-LOGS.
*>   WS-COUNT = the blocks WS-LOGB in the chunk window from y = 40
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-LY FROM 40 BY 1 UNTIL WS-LY > 110
         PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
             PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
                 PERFORM READ-BLOCK
                 IF WS-BLOCK = WS-LOGB
                     ADD 1 TO WS-COUNT
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 PLACE-TREE.
     MOVE WS-TX TO WS-X
     MOVE 63 TO WS-Y
     MOVE 40 TO WS-Z
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     .
 PLACE-TREE-GRASS.
     MOVE 24 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 40 TO WS-Z
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
     .
 NEW-WORLD.
*>   an empty chunk (1, 2): stone up to y = 60, mud y = 61 to 62 (WS-FLOOR 1: mud from y = 0 to 62); the tree goes at y = 63
     SET ADDRESS OF WS-A TO WS-PTR
     MOVE LOW-VALUES TO WS-A
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
         PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
             PERFORM VARYING WS-LY FROM 0 BY 1 UNTIL WS-LY > 62
                 MOVE CB-DEFAULT-STATE(2) TO WS-STATE
                 IF WS-LY >= 61 OR WS-FLOOR = 1
                     MOVE CB-DEFAULT-STATE(7) TO WS-STATE
                 END-IF
                 CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF WS-FLOOR = 2
         PERFORM VARYING WS-LX FROM 16 BY 1 UNTIL WS-LX > 31
             PERFORM VARYING WS-LZ FROM 32 BY 1 UNTIL WS-LZ > 47
                 PERFORM VARYING WS-LY FROM 63 BY 1 UNTIL WS-LY > 70
                     MOVE CB-DEFAULT-STATE(11) TO WS-STATE
                     CALL "FL-SET-STATE" USING WS-LX WS-LY WS-LZ WS-STATE WS-FLAGS WS-OK
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-IF
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     .
 NEW-WORLD-GRASS.
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
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     .
 BUILD-TABLE.
*>   1 air, 2 stone, 3 grass_block, 4 dirt, 5 mangrove_log (3 states, default the second), 6 mangrove_leaves (28, default the last), 7 mud, 8 mangrove_roots (2: waterlogged true, false),
*>   9 muddy_mangrove_roots (3), 10 moss_carpet, 11 water
     MOVE 11 TO CB-BLOCK-COUNT
     MOVE 11 TO CB-EPOCH
     MOVE 0 TO WS-STATE-NO
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         MOVE 1 TO WS-N
         MOVE 0 TO WS-D
         EVALUATE WS-I
             WHEN 5
                 MOVE 3 TO WS-N
                 MOVE 1 TO WS-D
             WHEN 6
                 MOVE 28 TO WS-N
                 MOVE 27 TO WS-D
             WHEN 8
                 MOVE 2 TO WS-N
                 MOVE 1 TO WS-D
             WHEN 9
                 MOVE 3 TO WS-N
                 MOVE 1 TO WS-D
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
     MOVE 1 TO CB-SOLID(7)
     MOVE "minecraft:air" TO CB-KEY(1)
     MOVE "minecraft:stone" TO CB-KEY(2)
     MOVE "minecraft:grass_block" TO CB-KEY(3)
     MOVE "minecraft:dirt" TO CB-KEY(4)
     MOVE "minecraft:mangrove_log" TO CB-KEY(5)
     MOVE "minecraft:mangrove_leaves" TO CB-KEY(6)
     MOVE "minecraft:mud" TO CB-KEY(7)
     MOVE "minecraft:mangrove_roots" TO CB-KEY(8)
     MOVE "minecraft:muddy_mangrove_roots" TO CB-KEY(9)
     MOVE "minecraft:moss_carpet" TO CB-KEY(10)
     MOVE "minecraft:water" TO CB-KEY(11)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CB-KEY(WS-I))) TO CB-KEY-LENGTH(WS-I)
     END-PERFORM
     .
 ASSERT-N.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-OBS TO TL-OBSERVED-N
     MOVE WS-EXP TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-FEAT-35-3-6.
