*> Test of the azalea tree (data/minecraft/worldgen/feature/azalea_tree.json: bending_trunk_placer, random_spread_foliage_placer, a weighted foliage provider and the simple
*> below_trunk_provider rooted_dirt; docs/protocol/35-worldgen-features-3-tree-placers.md sections 2.2, 4.7, 5.1 and 5.2, 35-2 section 4 for the weighted provider): the data feature
*> compiles as a tree (type 51); over 80 seeds on flat ground an independent shadow model written from those sections (height, the direction, the lean draws, the bend length, then for
*> each attachment the 50 leaf attempts, each valid attempt drawing the weighted provider again, so that a cell hit twice takes the last draw) predicts every cell of the window (log,
*> azalea leaves, flowering azalea leaves, rooted dirt under the trunk, nothing) and the random state after the tree.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-AZALEA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY XORO.
 COPY XORO REPLACING ==XR-STATE== BY ==XR2-STATE== LEADING ==XR-== BY ==X2-==.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/azalea".
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
 01 WS-RESULT              BINARY-LONG.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE 0.
 01 WS-HEIGHT              BINARY-LONG VALUE 256.
 01 WS-SEA                 BINARY-LONG VALUE 0.
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
 01 WS-RUN                 BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-ROUT                BINARY-LONG.
 01 WS-BAD-TOTAL           BINARY-LONG.
 01 WS-FLOWER-TOTAL        BINARY-LONG.
 01 WS-REDRAW-TOTAL        BINARY-LONG.
 01 WS-LEAF-TOTAL          BINARY-LONG.
 01 WS-S-STONE             BINARY-LONG.
 01 WS-B-AIR               BINARY-LONG.
 01 WS-B-LOG               BINARY-LONG.
 01 WS-B-AZ                BINARY-LONG.
 01 WS-B-FL                BINARY-LONG.
 01 WS-B-ROOTED            BINARY-LONG.
 01 WS-TAG-REG             PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112).
 01 WS-TAG-N               BINARY-LONG.
 01 WS-TAG-IDS.
    05 WS-TAG-ID           BINARY-LONG OCCURS 4 TIMES.
 01 WS-TAG-STATUS          BINARY-LONG.
*> the model: one class per cell of x 0..15, y 56..95 (index y - 55), z 0..15 : 0 untouched, 1 log, 2 azalea leaves, 3 flowering leaves, 4 rooted dirt
 01 WS-MODEL.
    05 WS-M                PIC 9 OCCURS 15360 TIMES.
 01 WS-H                   BINARY-LONG.
 01 WS-DIRN                BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-CCX                 BINARY-LONG.
 01 WS-CCY                 BINARY-LONG.
 01 WS-CCZ                 BINARY-LONG.
 01 WS-NATT                BINARY-LONG.
 01 WS-ATT.
    05 WS-A OCCURS 32 TIMES.
       10 WS-AX            BINARY-LONG.
       10 WS-AY            BINARY-LONG.
       10 WS-AZ            BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-MI                  BINARY-LONG.
 01 WS-CLS                 BINARY-LONG.
 01 WS-AFTER               BINARY-LONG.
 01 WS-AFTER2              BINARY-LONG.
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
     MOVE "stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-STONE
     MOVE "air" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-AIR
     MOVE "oak_log" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-LOG
     MOVE "azalea_leaves" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-AZ
     MOVE "flowering_azalea_leaves" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-FL
     MOVE "rooted_dirt" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-ROOTED
*>   the tags the engine reads: replaceable_by_trees (air and both leaves), logs, leaves
     MOVE 3 TO WS-TAG-N
     COMPUTE WS-TAG-ID(1) = WS-B-AIR - 1
     COMPUTE WS-TAG-ID(2) = WS-B-AZ - 1
     COMPUTE WS-TAG-ID(3) = WS-B-FL - 1
     MOVE "minecraft:replaceable_by_trees" TO WS-TAG
     CALL "TAG-PUT" USING WS-TAG-REG WS-TAG WS-TAG-N WS-TAG-IDS WS-TAG-STATUS
     MOVE 2 TO WS-TAG-N
     COMPUTE WS-TAG-ID(1) = WS-B-AZ - 1
     COMPUTE WS-TAG-ID(2) = WS-B-FL - 1
     MOVE "minecraft:leaves" TO WS-TAG
     CALL "TAG-PUT" USING WS-TAG-REG WS-TAG WS-TAG-N WS-TAG-IDS WS-TAG-STATUS
     MOVE 1 TO WS-TAG-N
     COMPUTE WS-TAG-ID(1) = WS-B-LOG - 1
     MOVE "minecraft:logs" TO WS-TAG
     CALL "TAG-PUT" USING WS-TAG-REG WS-TAG WS-TAG-N WS-TAG-IDS WS-TAG-STATUS
     MOVE 1 TO WS-TAG-N
     COMPUTE WS-TAG-ID(1) = WS-B-AIR - 1
     MOVE "minecraft:cannot_replace_below_tree_trunk" TO WS-TAG
     CALL "TAG-PUT" USING WS-TAG-REG WS-TAG WS-TAG-N WS-TAG-IDS WS-TAG-STATUS

     MOVE "minecraft:azalea_tree" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     MOVE "35-3§4.7, 5.2: the azalea_tree data feature compiles as a tree (51)" TO WS-CASE
     MOVE FT-TYPE(WS-FT) TO WS-OBS
     MOVE 51 TO WS-EXP
     PERFORM ASSERT-N

     MOVE 0 TO WS-BAD-TOTAL WS-FLOWER-TOTAL WS-REDRAW-TOTAL WS-LEAF-TOTAL
     PERFORM VARYING WS-RUN FROM 1 BY 1 UNTIL WS-RUN > 80
         COMPUTE WS-SEED = WS-RUN * 977 + 13
         PERFORM NEW-WORLD
         COMPUTE WS-X = WS-CX * 16 + 8
         MOVE 64 TO WS-Y
         COMPUTE WS-Z = WS-CZ * 16 + 8
         CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-X WS-Y WS-Z WS-RESULT
         PERFORM RUN-MODEL
         PERFORM COMPARE-WORLD
         ADD WS-BAD TO WS-BAD-TOTAL
         MOVE 1000 TO WS-BOUND
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-BOUND WS-AFTER
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-AFTER2
         IF WS-AFTER NOT = WS-AFTER2
             ADD 1 TO WS-BAD-TOTAL
         END-IF
         IF WS-RESULT NOT = 1
             ADD 1 TO WS-BAD-TOTAL
         END-IF
     END-PERFORM
     MOVE "35-3§5.2: 80 seeds, every cell of the window and the random state agree with the model" TO WS-CASE
     MOVE WS-BAD-TOTAL TO WS-OBS
     MOVE 0 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-2§4: flowering leaves occur (the weight 1 of 4 entries)" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-FLOWER-TOTAL > 20
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-3§5.1: cells hit by two leaf attempts (a second provider draw) occur" TO WS-CASE
     MOVE 0 TO WS-OBS
     IF WS-REDRAW-TOTAL > 20
         MOVE 1 TO WS-OBS
     END-IF
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN
     .
*> RUN-MODEL: the shadow of the whole tree on flat ground (origin (8, 64, 8) of the chunk), second random stream XR2 seeded alike
 RUN-MODEL.
     MOVE ALL "0" TO WS-MODEL
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
*>   getTreeHeight: base 4 + nextInt(2 + 1) + nextInt(0 + 1)
     MOVE 3 TO WS-BOUND
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-R
     MOVE 1 TO WS-BOUND
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-R2
     COMPUTE WS-H = 4 + WS-R + WS-R2
*>   the bending trunk: the direction (NORTH, EAST, SOUTH, WEST), the rooted dirt under the origin
     MOVE 4 TO WS-BOUND
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-DIRN
     MOVE 0 TO WS-DX WS-DZ
     EVALUATE WS-DIRN
         WHEN 0
             MOVE -1 TO WS-DZ
         WHEN 1
             MOVE 1 TO WS-DX
         WHEN 2
             MOVE 1 TO WS-DZ
         WHEN OTHER
             MOVE -1 TO WS-DX
     END-EVALUATE
     MOVE 8 TO WS-CCX
     MOVE 64 TO WS-CCY
     MOVE 8 TO WS-CCZ
     MOVE 8 TO WS-QX
     MOVE 63 TO WS-QY
     MOVE 8 TO WS-QZ
     MOVE 4 TO WS-CLS
     PERFORM MSET
     MOVE 0 TO WS-NATT
     COMPUTE WS-N = WS-H - 1
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > WS-N
         MOVE 2 TO WS-BOUND
         CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-D2
         IF WS-I + 1 >= WS-N + WS-D2
             ADD WS-DX TO WS-CCX
             ADD WS-DZ TO WS-CCZ
         END-IF
         MOVE WS-CCX TO WS-QX
         MOVE WS-CCY TO WS-QY
         MOVE WS-CCZ TO WS-QZ
         PERFORM MGET
         IF WS-CLS = 0
             MOVE 1 TO WS-CLS
             PERFORM MSET
         END-IF
         IF WS-I >= 3
             ADD 1 TO WS-NATT
             MOVE WS-CCX TO WS-AX(WS-NATT)
             MOVE WS-CCY TO WS-AY(WS-NATT)
             MOVE WS-CCZ TO WS-AZ(WS-NATT)
         END-IF
         ADD 1 TO WS-CCY
     END-PERFORM
*>   bend_length uniform 1..2, then len + 1 cells along the direction on the top layer
     MOVE 2 TO WS-BOUND
     CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-R
     COMPUTE WS-LEN = 1 + WS-R
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > WS-LEN
         MOVE WS-CCX TO WS-QX
         MOVE WS-CCY TO WS-QY
         MOVE WS-CCZ TO WS-QZ
         PERFORM MGET
         IF WS-CLS = 0
             MOVE 1 TO WS-CLS
             PERFORM MSET
         END-IF
         ADD 1 TO WS-NATT
         MOVE WS-CCX TO WS-AX(WS-NATT)
         MOVE WS-CCY TO WS-AY(WS-NATT)
         MOVE WS-CCZ TO WS-AZ(WS-NATT)
         ADD WS-DX TO WS-CCX
         ADD WS-DZ TO WS-CCZ
     END-PERFORM
*>   the foliage: 50 attempts per attachment at (nextInt(3) - nextInt(3), nextInt(2) - nextInt(2), nextInt(3) - nextInt(3)); a valid cell draws the provider nextInt(4): below 3 azalea
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-NATT
         PERFORM 50 TIMES
             MOVE 3 TO WS-BOUND
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-R
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-R2
             COMPUTE WS-PX = WS-AX(WS-K) + WS-R - WS-R2
             MOVE 2 TO WS-BOUND
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-R
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-R2
             COMPUTE WS-PY = WS-AY(WS-K) + WS-R - WS-R2
             MOVE 3 TO WS-BOUND
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-R
             CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-R2
             COMPUTE WS-PZ = WS-AZ(WS-K) + WS-R - WS-R2
             MOVE WS-PX TO WS-QX
             MOVE WS-PY TO WS-QY
             MOVE WS-PZ TO WS-QZ
             PERFORM MGET
             IF WS-CLS = 0 OR WS-CLS = 2 OR WS-CLS = 3
                 IF WS-CLS NOT = 0
                     ADD 1 TO WS-REDRAW-TOTAL
                 END-IF
                 MOVE 4 TO WS-BOUND
                 CALL "WGR-NEXT-INT-BOUND" USING XR2-STATE WS-BOUND WS-R
                 IF WS-R < 3
                     MOVE 2 TO WS-CLS
                 ELSE
                     MOVE 3 TO WS-CLS
                 END-IF
                 PERFORM MSET
             END-IF
         END-PERFORM
     END-PERFORM
     .
 MGET.
     COMPUTE WS-MI = (WS-QX * 40 + (WS-QY - 56)) * 16 + WS-QZ + 1
     MOVE WS-M(WS-MI) TO WS-CLS
     .
 MSET.
     COMPUTE WS-MI = (WS-QX * 40 + (WS-QY - 56)) * 16 + WS-QZ + 1
     MOVE WS-CLS TO WS-M(WS-MI)
     .
 COMPARE-WORLD.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-QX FROM 0 BY 1 UNTIL WS-QX > 15
         PERFORM VARYING WS-QY FROM 56 BY 1 UNTIL WS-QY > 95
             PERFORM VARYING WS-QZ FROM 0 BY 1 UNTIL WS-QZ > 15
                 COMPUTE WS-X = WS-CX * 16 + WS-QX
                 COMPUTE WS-Z = WS-CZ * 16 + WS-QZ
                 CALL "FL-GET-STATE" USING WS-X WS-QY WS-Z WS-STATE
                 CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                 EVALUATE TRUE
                     WHEN WS-BLOCK = WS-B-LOG
                         MOVE 1 TO WS-ROUT
                     WHEN WS-BLOCK = WS-B-AZ
                         MOVE 2 TO WS-ROUT
                         ADD 1 TO WS-LEAF-TOTAL
                     WHEN WS-BLOCK = WS-B-FL
                         MOVE 3 TO WS-ROUT
                         ADD 1 TO WS-LEAF-TOTAL
                         ADD 1 TO WS-FLOWER-TOTAL
                     WHEN WS-BLOCK = WS-B-ROOTED
                         MOVE 4 TO WS-ROUT
                     WHEN OTHER
                         MOVE 0 TO WS-ROUT
                 END-EVALUATE
                 PERFORM MGET
                 IF WS-ROUT NOT = WS-CLS
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> NEW-WORLD: chunk (WS-CX, WS-CZ) with stone up to y 63, air above; both random sources seeded
 NEW-WORLD.
     COMPUTE WS-X0 = WS-CX * 16
     COMPUTE WS-Z0 = WS-CZ * 16
     SET ADDRESS OF WS-AREA TO WS-PTR
     MOVE LOW-VALUES TO WS-AREA
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     PERFORM VARYING WS-QX FROM 0 BY 1 UNTIL WS-QX > 15
         PERFORM VARYING WS-QZ FROM 0 BY 1 UNTIL WS-QZ > 15
             PERFORM VARYING WS-QY FROM 0 BY 1 UNTIL WS-QY > 63
                 COMPUTE WS-X = WS-X0 + WS-QX
                 COMPUTE WS-Z = WS-Z0 + WS-QZ
                 CALL "FL-SET-STATE" USING WS-X WS-QY WS-Z WS-S-STONE WS-FLAGS WS-OK
             END-PERFORM
         END-PERFORM
     END-PERFORM
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-SET-SEED" USING XR2-STATE WS-SEED
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-AZALEA.
 COPY NOSPAWN.
 COPY CORETEST.
