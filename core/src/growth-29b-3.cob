*> Spreading, decay, leaves, snow, ice and sponges (docs/protocol/29b part 3) as programs of plain numbers (GC3- prefix): the decisions of each section take the
*> facts the caller read from the level (flags, light values, the random draws) and return the decision, as the part 1 helpers do (growth-29b-1.cob). Like part 1
*> sections 5 to 7 they are helpers: nothing here is wired into the block-update hooks. Section 1 (the block-to-section table and the tag members of 1.4) and
*> section 2 (the shared tests: light gets through, the draws, the direction orders, the breadth-first traversal) come first; the sections follow in order.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-PART.
*> USING block key (PIC X(48)), section x 10 (BINARY-LONG out): the block-to-section table of 1.3 (3.1 is 31, 4.3 is 43, 5.7 is 57, 10.1 is 101); 0 for other blocks.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-SECTION              BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-SECTION.
     MOVE 0 TO L-SECTION
     EVALUATE TRUE
         WHEN L-KEY = "minecraft:grass_block" OR L-KEY = "minecraft:mycelium"
             MOVE 30 TO L-SECTION
         WHEN L-KEY = "minecraft:podzol"
             MOVE 31 TO L-SECTION
         WHEN L-KEY = "minecraft:crimson_nylium" OR L-KEY = "minecraft:warped_nylium"
             MOVE 40 TO L-SECTION
         WHEN L-KEY = "minecraft:netherrack"
             MOVE 43 TO L-SECTION
         WHEN L-KEY = "minecraft:oak_leaves" OR L-KEY = "minecraft:birch_leaves" OR L-KEY = "minecraft:jungle_leaves" OR L-KEY = "minecraft:acacia_leaves"
              OR L-KEY = "minecraft:dark_oak_leaves" OR L-KEY = "minecraft:spruce_leaves" OR L-KEY = "minecraft:cherry_leaves" OR L-KEY = "minecraft:pale_oak_leaves"
              OR L-KEY = "minecraft:red_poplar_leaves" OR L-KEY = "minecraft:orange_poplar_leaves" OR L-KEY = "minecraft:yellow_poplar_leaves"
              OR L-KEY = "minecraft:azalea_leaves" OR L-KEY = "minecraft:flowering_azalea_leaves"
             MOVE 50 TO L-SECTION
         WHEN L-KEY = "minecraft:mangrove_leaves"
             MOVE 57 TO L-SECTION
         WHEN L-KEY = "minecraft:leaf_litter"
             MOVE 58 TO L-SECTION
         WHEN L-KEY = "minecraft:snow"
             MOVE 60 TO L-SECTION
         WHEN L-KEY = "minecraft:snow_block"
             MOVE 65 TO L-SECTION
         WHEN L-KEY = "minecraft:powder_snow"
             MOVE 80 TO L-SECTION
         WHEN L-KEY = "minecraft:ice"
             MOVE 71 TO L-SECTION
         WHEN L-KEY = "minecraft:packed_ice" OR L-KEY = "minecraft:blue_ice"
             MOVE 72 TO L-SECTION
         WHEN L-KEY = "minecraft:frosted_ice"
             MOVE 73 TO L-SECTION
         WHEN L-KEY = "minecraft:sponge"
             MOVE 101 TO L-SECTION
         WHEN L-KEY = "minecraft:wet_sponge"
             MOVE 102 TO L-SECTION
         WHEN L-KEY = "minecraft:magma_block"
             MOVE 103 TO L-SECTION
     END-EVALUATE
     GOBACK.
 END PROGRAM GC3-PART.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-IN-TAG.
*> USING tag (1 snow, 2 nylium, 3 cannot_support_snow_layer, 4 support_override_snow_layer, 5 leaves), block key (PIC X(48)), member (BINARY-LONG out, 1 or 0): the tag
*> members read from the jar (1.4), listed to make the examples concrete; a reimplementation takes the tags from the data pack (23).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SECTION             BINARY-LONG.
 LINKAGE SECTION.
 01 L-TAG                  BINARY-LONG.
 01 L-KEY                  PIC X(48).
 01 L-MEMBER               BINARY-LONG.
 PROCEDURE DIVISION USING L-TAG L-KEY L-MEMBER.
     MOVE 0 TO L-MEMBER
     CALL "GC3-PART" USING L-KEY WS-SECTION
     EVALUATE L-TAG
         WHEN 1
             IF L-KEY = "minecraft:snow" OR L-KEY = "minecraft:snow_block" OR L-KEY = "minecraft:powder_snow"
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 2
             IF WS-SECTION = 40
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 3
             IF L-KEY = "minecraft:ice" OR L-KEY = "minecraft:packed_ice" OR L-KEY = "minecraft:barrier"
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN 4
             IF L-KEY = "minecraft:honey_block" OR L-KEY = "minecraft:soul_sand" OR L-KEY = "minecraft:mud"
                 MOVE 1 TO L-MEMBER
             END-IF
         WHEN OTHER
             IF WS-SECTION = 50 OR WS-SECTION = 57
                 MOVE 1 TO L-MEMBER
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM GC3-IN-TAG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-LIGHT-INTO.
*> USING from shape is empty, to shape is empty, the two faces cover the unit square, default value (the above state's dampening) (BINARY-LONG), result out:
*> getLightDampeningInto (2.1): both empty give the default; else 16 when the faces cover the square, else the default.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FROM-EMPTY           BINARY-LONG.
 01 L-TO-EMPTY             BINARY-LONG.
 01 L-COVERS               BINARY-LONG.
 01 L-DEFAULT              BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-FROM-EMPTY L-TO-EMPTY L-COVERS L-DEFAULT L-RESULT.
     MOVE L-DEFAULT TO L-RESULT
     IF L-FROM-EMPTY = 1 AND L-TO-EMPTY = 1
         GOBACK
     END-IF
     IF L-COVERS = 1
         MOVE 16 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM GC3-LIGHT-INTO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-SURVIVES.
*> USING the result of getLightDampeningInto (BINARY-LONG), survives out (1 when the result is below 15) (2.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RESULT               BINARY-LONG.
 01 L-SURVIVES             BINARY-LONG.
 PROCEDURE DIVISION USING L-RESULT L-SURVIVES.
     MOVE 0 TO L-SURVIVES
     IF L-RESULT < 15
         MOVE 1 TO L-SURVIVES
     END-IF
     GOBACK.
 END PROGRAM GC3-SURVIVES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-FACES-COVER.
*> USING face A, face B (each a count 0 to 4 and four rectangles x1 y1 x2 y2 in pixels, BINARY-LONG x 17), covers out: mergedFaceOccludes of 2.1, true when the union
*> of the rectangles of both faces covers the 16 x 16 unit square (a full face does so alone).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CELLS               PIC X(256).
 01 WS-R                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-Y2                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 LINKAGE SECTION.
 01 L-FACE-A.
    05 L-A-N               BINARY-LONG.
    05 L-A-V               BINARY-LONG OCCURS 16 TIMES.
 01 L-FACE-B.
    05 L-B-N               BINARY-LONG.
    05 L-B-V               BINARY-LONG OCCURS 16 TIMES.
 01 L-COVERS               BINARY-LONG.
 PROCEDURE DIVISION USING L-FACE-A L-FACE-B L-COVERS.
     MOVE ALL "0" TO WS-CELLS
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > L-A-N
         COMPUTE WS-BASE = (WS-R - 1) * 4
         MOVE L-A-V(WS-BASE + 1) TO WS-X1
         MOVE L-A-V(WS-BASE + 2) TO WS-Y1
         MOVE L-A-V(WS-BASE + 3) TO WS-X2
         MOVE L-A-V(WS-BASE + 4) TO WS-Y2
         PERFORM VARYING WS-X FROM WS-X1 BY 1 UNTIL WS-X >= WS-X2
             PERFORM VARYING WS-Y FROM WS-Y1 BY 1 UNTIL WS-Y >= WS-Y2
                 COMPUTE WS-CELL = WS-X * 16 + WS-Y + 1
                 MOVE "1" TO WS-CELLS(WS-CELL:1)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > L-B-N
         COMPUTE WS-BASE = (WS-R - 1) * 4
         MOVE L-B-V(WS-BASE + 1) TO WS-X1
         MOVE L-B-V(WS-BASE + 2) TO WS-Y1
         MOVE L-B-V(WS-BASE + 3) TO WS-X2
         MOVE L-B-V(WS-BASE + 4) TO WS-Y2
         PERFORM VARYING WS-X FROM WS-X1 BY 1 UNTIL WS-X >= WS-X2
             PERFORM VARYING WS-Y FROM WS-Y1 BY 1 UNTIL WS-Y >= WS-Y2
                 COMPUTE WS-CELL = WS-X * 16 + WS-Y + 1
                 MOVE "1" TO WS-CELLS(WS-CELL:1)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0 TO L-COVERS
     IF WS-CELLS = ALL "1"
         MOVE 1 TO L-COVERS
     END-IF
     GOBACK.
 END PROGRAM GC3-FACES-COVER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-NEXT-INT.
*> USING mode (1 Mth.nextInt(a, b), 2 nextIntBetweenInclusive(a, b), 3 Util.getRandom(list of size a)), a, b, the draw (BINARY-LONG), result, draws made, the bound of
*> the nextInt call (BINARY-LONG out): 2.2. Mode 1 is a without a draw when a >= b, else a + nextInt(b - a + 1); mode 2 always draws; mode 3 returns the 1-based index.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 01 L-BOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-MODE L-A L-B L-DRAW L-RESULT L-DRAWS L-BOUND.
     MOVE 1 TO L-DRAWS
     COMPUTE L-BOUND = L-B - L-A + 1
     COMPUTE L-RESULT = L-A + L-DRAW
     IF L-MODE = 3
         MOVE L-A TO L-BOUND
         COMPUTE L-RESULT = L-DRAW + 1
     END-IF
     IF L-MODE = 1 AND L-A >= L-B
         MOVE L-A TO L-RESULT
         MOVE 0 TO L-DRAWS
         MOVE 0 TO L-BOUND
     END-IF
     GOBACK.
 END PROGRAM GC3-NEXT-INT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-DIRECTION.
*> USING list (1 Direction.values(), 2 the horizontal plane), index 1 to 6 (4 for the plane), dx, dy, dz (BINARY-LONG out): the orders of 2.3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIST                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-LIST L-INDEX L-DX L-DY L-DZ.
     MOVE 0 TO L-DX L-DY L-DZ
     IF L-LIST = 2
         EVALUATE L-INDEX
             WHEN 1
                 MOVE -1 TO L-DZ
             WHEN 2
                 MOVE 1 TO L-DX
             WHEN 3
                 MOVE 1 TO L-DZ
             WHEN OTHER
                 MOVE -1 TO L-DX
         END-EVALUATE
         GOBACK
     END-IF
     EVALUATE L-INDEX
         WHEN 1
             MOVE -1 TO L-DY
         WHEN 2
             MOVE 1 TO L-DY
         WHEN 3
             MOVE -1 TO L-DZ
         WHEN 4
             MOVE 1 TO L-DZ
         WHEN 5
             MOVE -1 TO L-DX
         WHEN OTHER
             MOVE 1 TO L-DX
     END-EVALUATE
     GOBACK.
 END PROGRAM GC3-DIRECTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-BFS.
*> USING maxDepth, maxCount, start node (BINARY-LONG), neighbours (64 nodes of 6 neighbour node numbers, 0 for none), verdict of each node (1 ACCEPT, 2 SKIP, 3 STOP),
*> accepted count out, number of nodes taken out, the nodes in the order the node function ran (64): BlockPos.breadthFirstTraversal of 2.4 on a graph of numbered
*> nodes, the queue holding a node and its depth, repeats dropped when taken.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-QUEUE.
    05 WS-Q-NODE           BINARY-LONG OCCURS 512 TIMES.
    05 WS-Q-DEPTH          BINARY-LONG OCCURS 512 TIMES.
 01 WS-VISITED.
    05 WS-SEEN             BINARY-LONG OCCURS 64 TIMES.
 01 WS-HEAD                BINARY-LONG.
 01 WS-TAIL                BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-MAX-DEPTH            BINARY-LONG.
 01 L-MAX-COUNT            BINARY-LONG.
 01 L-START                BINARY-LONG.
 01 L-NEIGHBOURS.
    05 L-NB                BINARY-LONG OCCURS 384 TIMES.
 01 L-VERDICTS.
    05 L-VERDICT           BINARY-LONG OCCURS 64 TIMES.
 01 L-COUNT                BINARY-LONG.
 01 L-TAKEN                BINARY-LONG.
 01 L-ORDER.
    05 L-ORD               BINARY-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-MAX-DEPTH L-MAX-COUNT L-START L-NEIGHBOURS L-VERDICTS L-COUNT L-TAKEN L-ORDER.
     INITIALIZE WS-VISITED
     MOVE 0 TO L-COUNT L-TAKEN
     MOVE 1 TO WS-HEAD WS-TAIL
     MOVE L-START TO WS-Q-NODE(1)
     MOVE 0 TO WS-Q-DEPTH(1)
     MOVE 2 TO WS-TAIL
     PERFORM UNTIL WS-HEAD >= WS-TAIL
         MOVE WS-Q-NODE(WS-HEAD) TO WS-NODE
         MOVE WS-Q-DEPTH(WS-HEAD) TO WS-DEPTH
         ADD 1 TO WS-HEAD
         IF WS-SEEN(WS-NODE) = 0
             MOVE 1 TO WS-SEEN(WS-NODE)
             ADD 1 TO L-TAKEN
             MOVE WS-NODE TO L-ORD(L-TAKEN)
             EVALUATE L-VERDICT(WS-NODE)
                 WHEN 3
                     GOBACK
                 WHEN 1
                     ADD 1 TO L-COUNT
                     IF L-COUNT >= L-MAX-COUNT
                         GOBACK
                     END-IF
                     IF WS-DEPTH < L-MAX-DEPTH
                         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 6
                             COMPUTE WS-SLOT = (WS-NODE - 1) * 6 + WS-J
                             MOVE L-NB(WS-SLOT) TO WS-NEXT
                             IF WS-NEXT > 0
                                 MOVE WS-NEXT TO WS-Q-NODE(WS-TAIL)
                                 COMPUTE WS-Q-DEPTH(WS-TAIL) = WS-DEPTH + 1
                                 ADD 1 TO WS-TAIL
                             END-IF
                         END-PERFORM
                     END-IF
             END-EVALUATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GC3-BFS.
