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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-SNOWY-SU.
*> USING direction of the shape update (1 down, 2 up, 3 north ...: the order of 2.3), the neighbour is in tag snow, the current snowy (BINARY-LONG), the new snowy out
*> (-1 for the state unchanged): SnowyBlock shape update (3.1): from UP the state takes snowy = the neighbour is in tag snow; every other direction leaves it.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIRECTION            BINARY-LONG.
 01 L-NEIGHBOUR-SNOW       BINARY-LONG.
 01 L-SNOWY                BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIRECTION L-NEIGHBOUR-SNOW L-SNOWY L-NEW.
     MOVE -1 TO L-NEW
     IF L-DIRECTION = 2
         MOVE L-NEIGHBOUR-SNOW TO L-NEW
     END-IF
     GOBACK.
 END PROGRAM GC3-SNOWY-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-SNOWY-PLACE.
*> USING the block above the clicked position is in tag snow (BINARY-LONG), snowy out: getStateForPlacement of 3.1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ABOVE-SNOW           BINARY-LONG.
 01 L-SNOWY                BINARY-LONG.
 PROCEDURE DIVISION USING L-ABOVE-SNOW L-SNOWY.
     MOVE L-ABOVE-SNOW TO L-SNOWY
     GOBACK.
 END PROGRAM GC3-SNOWY-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-STAY-ALIVE.
*> USING above is a snow layer, its layers, the fluid above is a full source, the light-into result of 2.1 (BINARY-LONG), alive out: canStayAlive of 3.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SNOW                 BINARY-LONG.
 01 L-LAYERS               BINARY-LONG.
 01 L-FULL                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-ALIVE                BINARY-LONG.
 PROCEDURE DIVISION USING L-SNOW L-LAYERS L-FULL L-RESULT L-ALIVE.
     MOVE 0 TO L-ALIVE
     IF L-SNOW = 1 AND L-LAYERS = 1
         MOVE 1 TO L-ALIVE
         GOBACK
     END-IF
     IF L-FULL = 1
         GOBACK
     END-IF
     IF L-RESULT < 15
         MOVE 1 TO L-ALIVE
     END-IF
     GOBACK.
 END PROGRAM GC3-STAY-ALIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-PROPAGATE.
*> USING canStayAlive, the fluid above is in tag water (BINARY-LONG), canPropagate out (3.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ALIVE                BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ALIVE L-WATER L-CAN.
     MOVE 0 TO L-CAN
     IF L-ALIVE = 1 AND L-WATER = 0
         MOVE 1 TO L-CAN
     END-IF
     GOBACK.
 END PROGRAM GC3-PROPAGATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-SPREAD-TICK.
*> USING dirt resolved from the registry, canStayAlive, max local raw brightness at the cell above (BINARY-LONG), action out: the random tick of 3.2: 0 nothing (no dirt),
*> 1 the block decays to dirt, 2 stops (brightness below 9), 3 runs the four spread attempts.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIRT                 BINARY-LONG.
 01 L-ALIVE                BINARY-LONG.
 01 L-BRIGHTNESS           BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIRT L-ALIVE L-BRIGHTNESS L-ACTION.
     MOVE 0 TO L-ACTION
     IF L-DIRT = 0
         GOBACK
     END-IF
     MOVE 1 TO L-ACTION
     IF L-ALIVE = 0
         GOBACK
     END-IF
     MOVE 2 TO L-ACTION
     IF L-BRIGHTNESS < 9
         GOBACK
     END-IF
     MOVE 3 TO L-ACTION
     GOBACK.
 END PROGRAM GC3-SPREAD-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-SPREAD-TARGET.
*> USING the draws nextInt(3), nextInt(5), nextInt(3) in that order, the target is plain dirt, canPropagate for the target, the block above the target is in tag snow
*> (BINARY-LONG), dx, dy, dz, place, snowy out: one of the four attempts of 3.2 (dx -1..1, dy -3..1, dz -1..1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW-X               BINARY-LONG.
 01 L-DRAW-Y               BINARY-LONG.
 01 L-DRAW-Z               BINARY-LONG.
 01 L-DIRT                 BINARY-LONG.
 01 L-PROPAGATE            BINARY-LONG.
 01 L-SNOW                 BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-PLACE                BINARY-LONG.
 01 L-SNOWY                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW-X L-DRAW-Y L-DRAW-Z L-DIRT L-PROPAGATE L-SNOW L-DX L-DY L-DZ L-PLACE L-SNOWY.
     COMPUTE L-DX = L-DRAW-X - 1
     COMPUTE L-DY = L-DRAW-Y - 3
     COMPUTE L-DZ = L-DRAW-Z - 1
     MOVE 0 TO L-PLACE L-SNOWY
     IF L-DIRT = 1 AND L-PROPAGATE = 1
         MOVE 1 TO L-PLACE
         MOVE L-SNOW TO L-SNOWY
     END-IF
     GOBACK.
 END PROGRAM GC3-SPREAD-TARGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-MYCELIUM-ANIM.
*> USING the draw nextInt(10) (BINARY-LONG), spawn, particle height above the block x 10 (BINARY-LONG out): MyceliumBlock.animateTick (3.2, client only).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-SPAWN                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-SPAWN L-HEIGHT.
     MOVE 0 TO L-SPAWN L-HEIGHT
     IF L-DRAW = 0
         MOVE 1 TO L-SPAWN
         MOVE 11 TO L-HEIGHT
     END-IF
     GOBACK.
 END PROGRAM GC3-MYCELIUM-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-GRASS-VALID.
*> USING the block above is air, the position above is inside the build height (BINARY-LONG), valid, success out: grass block bone meal target (3.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AIR                  BINARY-LONG.
 01 L-INSIDE               BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 PROCEDURE DIVISION USING L-AIR L-INSIDE L-VALID L-SUCCESS.
     MOVE 0 TO L-VALID
     MOVE 1 TO L-SUCCESS
     IF L-AIR = 1 AND L-INSIDE = 1
         MOVE 1 TO L-VALID
     END-IF
     GOBACK.
 END PROGRAM GC3-GRASS-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-GRASS-STEPS.
*> USING i (0 to 127), steps out (i / 16, integer division): the walk length of 3.3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-STEPS                BINARY-LONG.
 PROCEDURE DIVISION USING L-I L-STEPS.
     DIVIDE L-I BY 16 GIVING L-STEPS
     GOBACK.
 END PROGRAM GC3-GRASS-STEPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-GRASS-STEP.
*> USING the draws nextInt(3) of dx, of the between of dy, of the nextInt(3) of dy, of dz (BINARY-LONG), dx, dy, dz out: one step of the cumulative walk of 3.3:
*> between(-1, 1) is the draw minus 1; dy = (between x nextInt(3)) / 2 truncated toward zero.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PRODUCT             BINARY-LONG.
 LINKAGE SECTION.
 01 L-DRAW-X               BINARY-LONG.
 01 L-DRAW-BETWEEN         BINARY-LONG.
 01 L-DRAW-Y               BINARY-LONG.
 01 L-DRAW-Z               BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW-X L-DRAW-BETWEEN L-DRAW-Y L-DRAW-Z L-DX L-DY L-DZ.
     COMPUTE L-DX = L-DRAW-X - 1
     COMPUTE WS-PRODUCT = (L-DRAW-BETWEEN - 1) * L-DRAW-Y
     DIVIDE WS-PRODUCT BY 2 GIVING L-DY
     COMPUTE L-DZ = L-DRAW-Z - 1
     GOBACK.
 END PROGRAM GC3-GRASS-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-GRASS-STOP.
*> USING the state below p is this grass block, the collision shape at p is a full block (BINARY-LONG), stop out: stopBonemealSpread of 3.3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BELOW-GRASS          BINARY-LONG.
 01 L-FULL                 BINARY-LONG.
 01 L-STOP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BELOW-GRASS L-FULL L-STOP.
     MOVE 0 TO L-STOP
     IF L-BELOW-GRASS = 0 OR L-FULL = 1
         MOVE 1 TO L-STOP
     END-IF
     GOBACK.
 END PROGRAM GC3-GRASS-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-GRASS-EFFECT.
*> USING the state at p is air, it is short_grass, nextFloat for the short grass test (FLOAT-LONG), short grass isValidBonemealTarget, p is inside the build height, nextFloat
*> of step 3 (FLOAT-LONG), the biome flower list is empty, the placed feature grass_bonemeal exists, short grass grown, result (1 flower placed, 2 grass patch placed, 3
*> empty list, 0 nothing), floats drawn (BINARY-LONG out): placeBonemealEffect of 3.3 (the short grass draw is made only for short grass; step 3 only for air in range).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AIR                  BINARY-LONG.
 01 L-SHORT                BINARY-LONG.
 01 L-DRAW-SHORT           FLOAT-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-INSIDE               BINARY-LONG.
 01 L-DRAW-FLOWER          FLOAT-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-FEATURE              BINARY-LONG.
 01 L-GROWN                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-AIR L-SHORT L-DRAW-SHORT L-VALID L-INSIDE L-DRAW-FLOWER L-EMPTY L-FEATURE L-GROWN L-RESULT L-DRAWS.
     MOVE 0 TO L-GROWN L-RESULT L-DRAWS
     IF L-SHORT = 1
         MOVE 1 TO L-DRAWS
         IF L-DRAW-SHORT < 0.1 AND L-VALID = 1
             MOVE 1 TO L-GROWN
         END-IF
     END-IF
     IF L-AIR = 0 OR L-INSIDE = 0
         GOBACK
     END-IF
     ADD 1 TO L-DRAWS
     IF L-DRAW-FLOWER < 0.125
         MOVE 1 TO L-RESULT
         IF L-EMPTY = 1
             MOVE 3 TO L-RESULT
         END-IF
         GOBACK
     END-IF
     IF L-FEATURE = 1
         MOVE 2 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM GC3-GRASS-EFFECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-NYLIUM-TICK.
*> USING the light-into result of 2.1 (BINARY-LONG), reverts, survives out: NyliumBlock random tick (4.1): canBeNylium is a result below 15, with no snow exception and no fluid
*> test; when false the block becomes netherrack.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RESULT               BINARY-LONG.
 01 L-REVERTS              BINARY-LONG.
 01 L-SURVIVES             BINARY-LONG.
 PROCEDURE DIVISION USING L-RESULT L-REVERTS L-SURVIVES.
     MOVE 0 TO L-REVERTS
     MOVE 1 TO L-SURVIVES
     IF L-RESULT >= 15
         MOVE 1 TO L-REVERTS
         MOVE 0 TO L-SURVIVES
     END-IF
     GOBACK.
 END PROGRAM GC3-NYLIUM-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-NYLIUM-BONE.
*> USING the block above is air, the position above is inside the build height, the feature nylium_bonemeal exists (BINARY-LONG), valid, success, place out: nylium bone meal (4.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AIR                  BINARY-LONG.
 01 L-INSIDE               BINARY-LONG.
 01 L-FEATURE              BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 01 L-PLACE                BINARY-LONG.
 PROCEDURE DIVISION USING L-AIR L-INSIDE L-FEATURE L-VALID L-SUCCESS L-PLACE.
     MOVE 0 TO L-VALID L-PLACE
     MOVE 1 TO L-SUCCESS
     IF L-AIR = 1 AND L-INSIDE = 1
         MOVE 1 TO L-VALID
     END-IF
     IF L-INSIDE = 1 AND L-FEATURE = 1
         MOVE 1 TO L-PLACE
     END-IF
     GOBACK.
 END PROGRAM GC3-NYLIUM-BONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-CUBE-NYLIUM.
*> USING the 27 cells of pos +- 1 (BINARY-LONG: 1 warped_nylium, 2 crimson_nylium, else another block), nylium count, warped found, crimson found out: the cube scan of 4.3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CUBE.
    05 L-CELL              BINARY-LONG OCCURS 27 TIMES.
 01 L-COUNT                BINARY-LONG.
 01 L-WARPED               BINARY-LONG.
 01 L-CRIMSON              BINARY-LONG.
 PROCEDURE DIVISION USING L-CUBE L-COUNT L-WARPED L-CRIMSON.
     MOVE 0 TO L-COUNT L-WARPED L-CRIMSON
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 27
         EVALUATE L-CELL(WS-I)
             WHEN 1
                 ADD 1 TO L-COUNT
                 MOVE 1 TO L-WARPED
             WHEN 2
                 ADD 1 TO L-COUNT
                 MOVE 1 TO L-CRIMSON
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM GC3-CUBE-NYLIUM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-NETHERRACK-VALID.
*> USING the state above propagates skylight down, the number of nylium blocks in the cube (BINARY-LONG), valid, success out: netherrack bone meal target (4.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SKY                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 PROCEDURE DIVISION USING L-SKY L-COUNT L-VALID L-SUCCESS.
     MOVE 0 TO L-VALID
     MOVE 1 TO L-SUCCESS
     IF L-SKY = 1 AND L-COUNT > 0
         MOVE 1 TO L-VALID
     END-IF
     GOBACK.
 END PROGRAM GC3-NETHERRACK-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-NETHERRACK-PERFORM.
*> USING a warped_nylium was found, a crimson_nylium was found, nextBoolean (BINARY-LONG), the block placed (1 warped, 2 crimson, 0 nothing), draws out: 4.3 performBonemeal; both
*> kinds make one draw: true gives warped, false crimson.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WARPED               BINARY-LONG.
 01 L-CRIMSON              BINARY-LONG.
 01 L-BOOLEAN              BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-WARPED L-CRIMSON L-BOOLEAN L-BLOCK L-DRAWS.
     MOVE 0 TO L-BLOCK L-DRAWS
     EVALUATE TRUE
         WHEN L-WARPED = 1 AND L-CRIMSON = 1
             MOVE 1 TO L-DRAWS
             MOVE 2 TO L-BLOCK
             IF L-BOOLEAN = 1
                 MOVE 1 TO L-BLOCK
             END-IF
         WHEN L-WARPED = 1
             MOVE 1 TO L-BLOCK
         WHEN L-CRIMSON = 1
             MOVE 2 TO L-BLOCK
     END-EVALUATE
     GOBACK.
 END PROGRAM GC3-NETHERRACK-PERFORM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-LEAF-STATES.
*> USING states, light dampening (BINARY-LONG out): the state of a leaves block (5.1): distance 1 to 7, persistent, waterlogged (28 states); dampening 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DISTANCE            BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATES               BINARY-LONG.
 01 L-DAMPENING            BINARY-LONG.
 PROCEDURE DIVISION USING L-STATES L-DAMPENING.
     MOVE 0 TO L-STATES
     PERFORM VARYING WS-DISTANCE FROM 1 BY 1 UNTIL WS-DISTANCE > 7
         PERFORM VARYING WS-FLAGS FROM 0 BY 1 UNTIL WS-FLAGS > 3
             ADD 1 TO L-STATES
         END-PERFORM
     END-PERFORM
     MOVE 1 TO L-DAMPENING
     GOBACK.
 END PROGRAM GC3-LEAF-STATES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-LEAF-DIST-AT.
*> USING the state is in tag prevents_nearby_leaf_decay, it has the distance property, its distance (BINARY-LONG), optional distance (-1 for empty), getDistanceAt out: 5.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LOG                  BINARY-LONG.
 01 L-HAS                  BINARY-LONG.
 01 L-DISTANCE             BINARY-LONG.
 01 L-OPTIONAL             BINARY-LONG.
 01 L-AT                   BINARY-LONG.
 PROCEDURE DIVISION USING L-LOG L-HAS L-DISTANCE L-OPTIONAL L-AT.
     MOVE -1 TO L-OPTIONAL
     MOVE 7 TO L-AT
     IF L-LOG = 1
         MOVE 0 TO L-OPTIONAL L-AT
         GOBACK
     END-IF
     IF L-HAS = 1
         MOVE L-DISTANCE TO L-OPTIONAL L-AT
     END-IF
     GOBACK.
 END PROGRAM GC3-LEAF-DIST-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-LEAF-UPDATE.
*> USING getDistanceAt of the six neighbours in Direction.values() order (BINARY-LONG x 6), distance, neighbours examined out: updateDistance (5.2): m = 7, then
*> min(m, d + 1) for each neighbour, the loop ending when m is 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STEP                BINARY-LONG.
 LINKAGE SECTION.
 01 L-NEIGHBOURS.
    05 L-N                 BINARY-LONG OCCURS 6 TIMES.
 01 L-DISTANCE             BINARY-LONG.
 01 L-EXAMINED             BINARY-LONG.
 PROCEDURE DIVISION USING L-NEIGHBOURS L-DISTANCE L-EXAMINED.
     MOVE 7 TO L-DISTANCE
     MOVE 0 TO L-EXAMINED
     PERFORM VARYING WS-STEP FROM 1 BY 1 UNTIL WS-STEP > 6 OR L-DISTANCE = 1
         ADD 1 TO L-EXAMINED
         IF L-N(WS-STEP) + 1 < L-DISTANCE
             COMPUTE L-DISTANCE = L-N(WS-STEP) + 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GC3-LEAF-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-LEAF-PLACE.
*> USING the fluid at the clicked position is water, the updated distance (BINARY-LONG), persistent, waterlogged, distance out: getStateForPlacement (5.3 PL).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATER                BINARY-LONG.
 01 L-DISTANCE             BINARY-LONG.
 01 L-PERSISTENT           BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-OUT-DISTANCE         BINARY-LONG.
 PROCEDURE DIVISION USING L-WATER L-DISTANCE L-PERSISTENT L-WATERLOGGED L-OUT-DISTANCE.
     MOVE 1 TO L-PERSISTENT
     MOVE L-WATER TO L-WATERLOGGED
     MOVE L-DISTANCE TO L-OUT-DISTANCE
     GOBACK.
 END PROGRAM GC3-LEAF-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-LEAF-SU.
*> USING waterlogged, getDistanceAt of the neighbour that sent the update, the own distance (BINARY-LONG), a water tick is scheduled, a block tick is scheduled, its delay
*> out: the shape update of 5.3 (d = the neighbour's distance + 1; scheduled unless d is 1 and the own distance is d).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-NEIGHBOUR            BINARY-LONG.
 01 L-OWN                  BINARY-LONG.
 01 L-WATER-TICK           BINARY-LONG.
 01 L-BLOCK-TICK           BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-WATERLOGGED L-NEIGHBOUR L-OWN L-WATER-TICK L-BLOCK-TICK L-DELAY.
     MOVE L-WATERLOGGED TO L-WATER-TICK
     MOVE 0 TO L-BLOCK-TICK L-DELAY
     COMPUTE WS-D = L-NEIGHBOUR + 1
     IF WS-D NOT = 1 OR L-OWN NOT = WS-D
         MOVE 1 TO L-BLOCK-TICK L-DELAY
     END-IF
     GOBACK.
 END PROGRAM GC3-LEAF-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-LEAF-RANDOM.
*> USING distance, persistent (BINARY-LONG), randomly ticking, drops resources, removes the block, game event out: isRandomlyTicking and the decay of 5.3 and 5.4.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DISTANCE             BINARY-LONG.
 01 L-PERSISTENT           BINARY-LONG.
 01 L-TICKING              BINARY-LONG.
 01 L-DROPS                BINARY-LONG.
 01 L-REMOVES              BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-DISTANCE L-PERSISTENT L-TICKING L-DROPS L-REMOVES L-EVENT.
     MOVE 0 TO L-TICKING L-DROPS L-REMOVES L-EVENT
     IF L-DISTANCE = 7 AND L-PERSISTENT = 0
         MOVE 1 TO L-TICKING L-DROPS L-REMOVES
     END-IF
     GOBACK.
 END PROGRAM GC3-LEAF-RANDOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-LEAF-DROP.
*> USING kind (1 the leaves item, 2 sapling, 3 stick, 4 apple), chance per million, count minimum, count maximum (BINARY-LONG out): the drops of a decayed oak leaf block with
*> no tool and fortune 0 (5.4): the leaves item never; sapling 0.05, sticks 0.02 (1 to 2), apple 0.005.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-CHANCE               BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-CHANCE L-MIN L-MAX.
     MOVE 0 TO L-CHANCE L-MIN L-MAX
     EVALUATE L-KIND
         WHEN 2
             MOVE 50000 TO L-CHANCE
             MOVE 1 TO L-MIN L-MAX
         WHEN 3
             MOVE 20000 TO L-CHANCE
             MOVE 1 TO L-MIN
             MOVE 2 TO L-MAX
         WHEN 4
             MOVE 5000 TO L-CHANCE
             MOVE 1 TO L-MIN L-MAX
     END-EVALUATE
     GOBACK.
 END PROGRAM GC3-LEAF-DROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-LEAF-VARIANT.
*> USING block key (PIC X(48)), class (1 TintedParticleLeavesBlock, 2 LeavesBlock, 3 UntintedParticleLeavesBlock, 4 MangroveLeavesBlock), leafParticleChance x 10000, particle
*> (0 none, 1 tinted_leaves, 2 cherry_leaves, 3 pale_oak_leaves, 4 red_poplar_leaves, 5 orange_poplar_leaves, 6 yellow_poplar_leaves), fixed particle colour (0 when the
*> position's tint is used), ambient sound (BINARY-LONG out): the variant table of 5.5.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-CLASS                BINARY-LONG.
 01 L-CHANCE               BINARY-LONG.
 01 L-PARTICLE             BINARY-LONG.
 01 L-COLOUR               BINARY-LONG.
 01 L-AMBIENT              BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-CLASS L-CHANCE L-PARTICLE L-COLOUR L-AMBIENT.
     MOVE 0 TO L-CLASS L-CHANCE L-PARTICLE L-COLOUR L-AMBIENT
     EVALUATE TRUE
         WHEN L-KEY = "minecraft:oak_leaves" OR L-KEY = "minecraft:birch_leaves" OR L-KEY = "minecraft:jungle_leaves" OR L-KEY = "minecraft:acacia_leaves"
              OR L-KEY = "minecraft:dark_oak_leaves"
             MOVE 1 TO L-CLASS L-PARTICLE
             MOVE 100 TO L-CHANCE
         WHEN L-KEY = "minecraft:spruce_leaves"
             MOVE 2 TO L-CLASS
         WHEN L-KEY = "minecraft:mangrove_leaves"
             MOVE 4 TO L-CLASS
             MOVE 1 TO L-PARTICLE
             MOVE 100 TO L-CHANCE
         WHEN L-KEY = "minecraft:cherry_leaves"
             MOVE 3 TO L-CLASS
             MOVE 2 TO L-PARTICLE
             MOVE 1000 TO L-CHANCE
         WHEN L-KEY = "minecraft:pale_oak_leaves"
             MOVE 3 TO L-CLASS
             MOVE 3 TO L-PARTICLE
             MOVE 200 TO L-CHANCE
         WHEN L-KEY = "minecraft:red_poplar_leaves"
             MOVE 3 TO L-CLASS
             MOVE 4 TO L-PARTICLE
             MOVE 100 TO L-CHANCE
             MOVE 1 TO L-AMBIENT
         WHEN L-KEY = "minecraft:orange_poplar_leaves"
             MOVE 3 TO L-CLASS
             MOVE 5 TO L-PARTICLE
             MOVE 100 TO L-CHANCE
             MOVE 1 TO L-AMBIENT
         WHEN L-KEY = "minecraft:yellow_poplar_leaves"
             MOVE 3 TO L-CLASS
             MOVE 6 TO L-PARTICLE
             MOVE 100 TO L-CHANCE
             MOVE 1 TO L-AMBIENT
         WHEN L-KEY = "minecraft:azalea_leaves" OR L-KEY = "minecraft:flowering_azalea_leaves"
             MOVE 3 TO L-CLASS
             MOVE 1 TO L-PARTICLE
             MOVE 100 TO L-CHANCE
             MOVE -9399763 TO L-COLOUR
     END-EVALUATE
     GOBACK.
 END PROGRAM GC3-LEAF-VARIANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-LEAF-DRIP.
*> USING it is raining at the cell above, the draw nextInt(15), the block below occludes with a sturdy UP face (BINARY-LONG), spawn, draws out: the rain drip of 5.6 step 2
*> (the draw is made only when it is raining).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RAINING              BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-STURDY               BINARY-LONG.
 01 L-SPAWN                BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-RAINING L-DRAW L-STURDY L-SPAWN L-DRAWS.
     MOVE 0 TO L-SPAWN L-DRAWS
     IF L-RAINING = 0
         GOBACK
     END-IF
     MOVE 1 TO L-DRAWS
     IF L-DRAW = 1 AND L-STURDY = 0
         MOVE 1 TO L-SPAWN
     END-IF
     GOBACK.
 END PROGRAM GC3-LEAF-DRIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-LEAF-AMBIENT.
*> USING the variant has an ambient sound, the draw nextInt(300) (BINARY-LONG), the four horizontal neighbours in order (BINARY-LONG x 4: bit 1 in the satisfying tag, bit 2 the
*> same block), play, draws out: 5.6 step 3; after each neighbour the sound plays when a (satisfying) is exactly 1 and b (same block) exactly 3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 LINKAGE SECTION.
 01 L-HAS                  BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-NEIGHBOURS.
    05 L-N                 BINARY-LONG OCCURS 4 TIMES.
 01 L-PLAY                 BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS L-DRAW L-NEIGHBOURS L-PLAY L-DRAWS.
     MOVE 0 TO L-PLAY L-DRAWS WS-A WS-B
     IF L-HAS = 0
         GOBACK
     END-IF
     MOVE 1 TO L-DRAWS
     IF L-DRAW NOT = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-STEP FROM 1 BY 1 UNTIL WS-STEP > 4 OR L-PLAY = 1
         IF L-N(WS-STEP) = 1 OR L-N(WS-STEP) = 3
             ADD 1 TO WS-A
         END-IF
         IF L-N(WS-STEP) >= 2
             ADD 1 TO WS-B
         END-IF
         IF WS-A = 1 AND WS-B = 3
             MOVE 1 TO L-PLAY
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GC3-LEAF-AMBIENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-LEAF-FALL.
*> USING nextFloat, leafParticleChance (FLOAT-LONG), the block below has a full UP collision face (BINARY-LONG), spawn out: falling leaves of 5.6 step 4.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-CHANCE               FLOAT-LONG.
 01 L-FULL                 BINARY-LONG.
 01 L-SPAWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-CHANCE L-FULL L-SPAWN.
     MOVE 0 TO L-SPAWN
     IF L-DRAW < L-CHANCE AND L-FULL = 0
         MOVE 1 TO L-SPAWN
     END-IF
     GOBACK.
 END PROGRAM GC3-LEAF-FALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-LEAF-CULL.
*> USING cutoutLeaves (default 1), the neighbour is a LeavesBlock (BINARY-LONG), skip out (1 skips the face, 0 the generic rule applies): LeavesBlock.skipRendering (5.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CUTOUT               BINARY-LONG.
 01 L-LEAVES               BINARY-LONG.
 01 L-SKIP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CUTOUT L-LEAVES L-SKIP.
     MOVE 0 TO L-SKIP
     IF L-CUTOUT = 0 AND L-LEAVES = 1
         MOVE 1 TO L-SKIP
     END-IF
     GOBACK.
 END PROGRAM GC3-LEAF-CULL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-MANGROVE-BONE.
*> USING the block below is air (BINARY-LONG), valid, success, setBlock flags, propagule age out: mangrove leaves bone meal (5.7): a hanging propagule of age 0 below, flags 2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AIR                  BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-SUCCESS              BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-AIR L-VALID L-SUCCESS L-FLAGS L-AGE.
     MOVE L-AIR TO L-VALID
     MOVE 1 TO L-SUCCESS
     MOVE 2 TO L-FLAGS
     MOVE 0 TO L-AGE
     GOBACK.
 END PROGRAM GC3-MANGROVE-BONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-LITTER.
*> USING the block below has a sturdy UP face (BINARY-LONG), survives, random tick, scheduled tick out: leaf_litter (5.8) has no random tick, scheduled tick or decay.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STURDY               BINARY-LONG.
 01 L-SURVIVES             BINARY-LONG.
 01 L-RANDOM               BINARY-LONG.
 01 L-SCHEDULED            BINARY-LONG.
 PROCEDURE DIVISION USING L-STURDY L-SURVIVES L-RANDOM L-SCHEDULED.
     MOVE L-STURDY TO L-SURVIVES
     MOVE 0 TO L-RANDOM L-SCHEDULED
     GOBACK.
 END PROGRAM GC3-LITTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-SNOW-SHAPE.
*> USING layers 1 to 8 (BINARY-LONG), outline height (px), collision height (px), shade brightness x 10, land pathfinding, view blocking out: SnowLayerBlock (6.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LAYERS               BINARY-LONG.
 01 L-OUTLINE              BINARY-LONG.
 01 L-COLLISION            BINARY-LONG.
 01 L-SHADE                BINARY-LONG.
 01 L-PATH                 BINARY-LONG.
 01 L-VIEW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-LAYERS L-OUTLINE L-COLLISION L-SHADE L-PATH L-VIEW.
     COMPUTE L-OUTLINE = 2 * L-LAYERS
     COMPUTE L-COLLISION = 2 * (L-LAYERS - 1)
     MOVE 10 TO L-SHADE
     MOVE 0 TO L-PATH L-VIEW
     IF L-LAYERS = 8
         MOVE 2 TO L-SHADE
         MOVE 1 TO L-VIEW
     END-IF
     IF L-LAYERS < 5
         MOVE 1 TO L-PATH
     END-IF
     GOBACK.
 END PROGRAM GC3-SNOW-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-SNOW-SURVIVE.
*> USING the block below is in cannot_support_snow_layer, in support_override_snow_layer, its UP collision face is full, it is a snow layer of 8 layers (BINARY-LONG),
*> survives out: canSurvive of 6.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CANNOT               BINARY-LONG.
 01 L-OVERRIDE             BINARY-LONG.
 01 L-FULL                 BINARY-LONG.
 01 L-EIGHT                BINARY-LONG.
 01 L-SURVIVES             BINARY-LONG.
 PROCEDURE DIVISION USING L-CANNOT L-OVERRIDE L-FULL L-EIGHT L-SURVIVES.
     MOVE 0 TO L-SURVIVES
     IF L-CANNOT = 1
         GOBACK
     END-IF
     IF L-OVERRIDE = 1 OR L-FULL = 1 OR L-EIGHT = 1
         MOVE 1 TO L-SURVIVES
     END-IF
     GOBACK.
 END PROGRAM GC3-SNOW-SURVIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-SNOW-SU.
*> USING canSurvive (BINARY-LONG), air out (1 when the shape update returns air, 0 for the generic rule): 6.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SURVIVES             BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SURVIVES L-AIR.
     MOVE 0 TO L-AIR
     IF L-SURVIVES = 0
         MOVE 1 TO L-AIR
     END-IF
     GOBACK.
 END PROGRAM GC3-SNOW-SU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-SNOW-TICK.
*> USING the block light at the position (BINARY-LONG), melts, items yielded, game event block_destroy out: the random tick of 6.2 (block light above 11); the drop call has no
*> entity so its loot pool yields nothing (6.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIGHT                BINARY-LONG.
 01 L-MELTS                BINARY-LONG.
 01 L-YIELDED              BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-LIGHT L-MELTS L-YIELDED L-EVENT.
     MOVE 0 TO L-MELTS L-YIELDED L-EVENT
     IF L-LIGHT > 11
         MOVE 1 TO L-MELTS L-EVENT
     END-IF
     GOBACK.
 END PROGRAM GC3-SNOW-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-SNOW-REPLACE.
*> USING the held item is snow, layers, the placement replaces the clicked block, the clicked face is UP (BINARY-LONG), replaceable out: canBeReplaced of 6.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SNOW                 BINARY-LONG.
 01 L-LAYERS               BINARY-LONG.
 01 L-CLICKED              BINARY-LONG.
 01 L-UP                   BINARY-LONG.
 01 L-REPLACEABLE          BINARY-LONG.
 PROCEDURE DIVISION USING L-SNOW L-LAYERS L-CLICKED L-UP L-REPLACEABLE.
     MOVE 0 TO L-REPLACEABLE
     IF L-SNOW = 1 AND L-LAYERS < 8
         MOVE 1 TO L-REPLACEABLE
         IF L-CLICKED = 1
             MOVE L-UP TO L-REPLACEABLE
         END-IF
         GOBACK
     END-IF
     IF L-LAYERS = 1
         MOVE 1 TO L-REPLACEABLE
     END-IF
     GOBACK.
 END PROGRAM GC3-SNOW-REPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-SNOW-PLACE.
*> USING the state at the clicked position is snow, its layers (BINARY-LONG), layers out (min(8, layers + 1); 0 for the generic placement): getStateForPlacement of 6.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SNOW                 BINARY-LONG.
 01 L-LAYERS               BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SNOW L-LAYERS L-NEW.
     MOVE 0 TO L-NEW
     IF L-SNOW = 1
         COMPUTE L-NEW = FUNCTION MIN(8, L-LAYERS + 1)
     END-IF
     GOBACK.
 END PROGRAM GC3-SNOW-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-SNOW-DROPS.
*> USING the tool has silk touch, the loot parameters hold an entity (a player break), layers (BINARY-LONG), item (1 snowball, 2 snow, 3 snow_block, 0 none), count out: the loot
*> table of snow (6.4); the pool needs an entity, branch one (no silk touch) gives snowballs x layers, branch two the snow item x layers (1 to 7) or snow_block at 8 (count 1:
*> the table names no count function for it).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SILK                 BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-LAYERS               BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-SILK L-ENTITY L-LAYERS L-ITEM L-COUNT.
     MOVE 0 TO L-ITEM L-COUNT
     IF L-ENTITY = 0
         GOBACK
     END-IF
     MOVE L-LAYERS TO L-COUNT
     EVALUATE TRUE
         WHEN L-SILK = 0
             MOVE 1 TO L-ITEM
         WHEN L-LAYERS < 8
             MOVE 2 TO L-ITEM
         WHEN OTHER
             MOVE 3 TO L-ITEM
             MOVE 1 TO L-COUNT
     END-EVALUATE
     GOBACK.
 END PROGRAM GC3-SNOW-DROPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-SNOW-BLOCK.
*> USING random tick, requires the correct tool for drops (BINARY-LONG out): snow_block (6.5) is a plain block.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RANDOM               BINARY-LONG.
 01 L-TOOL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-RANDOM L-TOOL.
     MOVE 0 TO L-RANDOM
     MOVE 1 TO L-TOOL
     GOBACK.
 END PROGRAM GC3-SNOW-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-ICE-TICK.
*> USING the block light at the position, the light dampening of the state (BINARY-LONG), melts out: IceBlock random tick (7.1): block light above 11 - dampening.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIGHT                BINARY-LONG.
 01 L-DAMPENING            BINARY-LONG.
 01 L-MELTS                BINARY-LONG.
 PROCEDURE DIVISION USING L-LIGHT L-DAMPENING L-MELTS.
     MOVE 0 TO L-MELTS
     IF L-LIGHT > 11 - L-DAMPENING
         MOVE 1 TO L-MELTS
     END-IF
     GOBACK.
 END PROGRAM GC3-ICE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-ICE-MELT.
*> USING the attribute water_evaporates at the position (BINARY-LONG), action (1 removeBlock with no event, 2 water), neighbour update, game event block_destroy out: melt (7.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EVAPORATES           BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-NEIGHBOUR            BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-EVAPORATES L-ACTION L-NEIGHBOUR L-EVENT.
     MOVE 0 TO L-NEIGHBOUR L-EVENT
     IF L-EVAPORATES = 1
         MOVE 1 TO L-ACTION
         GOBACK
     END-IF
     MOVE 2 TO L-ACTION
     MOVE 1 TO L-NEIGHBOUR L-EVENT
     GOBACK.
 END PROGRAM GC3-ICE-MELT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-ICE-DESTROY.
*> USING the tool has an enchantment in tag prevents_ice_melting, water_evaporates, the block below is in ice_melts_when_destroyed_above, the block below is a liquid
*> (BINARY-LONG), action out (0 nothing, 1 removeBlock, 2 water): playerDestroy (7.1); the last test is an OR of the tag and the liquid.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PREVENTS             BINARY-LONG.
 01 L-EVAPORATES           BINARY-LONG.
 01 L-IN-TAG               BINARY-LONG.
 01 L-LIQUID               BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-PREVENTS L-EVAPORATES L-IN-TAG L-LIQUID L-ACTION.
     MOVE 0 TO L-ACTION
     IF L-PREVENTS = 1
         GOBACK
     END-IF
     IF L-EVAPORATES = 1
         MOVE 1 TO L-ACTION
         GOBACK
     END-IF
     IF L-IN-TAG = 1 OR L-LIQUID = 1
         MOVE 2 TO L-ACTION
     END-IF
     GOBACK.
 END PROGRAM GC3-ICE-DESTROY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-ICE-LOOT.
*> USING the tool has silk touch (BINARY-LONG), ice dropped out: the loot table of ice (7.1) is one pool conditioned on silk touch.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SILK                 BINARY-LONG.
 01 L-DROPS                BINARY-LONG.
 PROCEDURE DIVISION USING L-SILK L-DROPS.
     MOVE L-SILK TO L-DROPS
     GOBACK.
 END PROGRAM GC3-ICE-LOOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-ICE-PLAIN.
*> USING block (1 packed_ice, 2 blue_ice), friction x 1000, strength x 10, random tick, face culled against the same block (BINARY-LONG out): 7.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-FRICTION             BINARY-LONG.
 01 L-STRENGTH             BINARY-LONG.
 01 L-RANDOM               BINARY-LONG.
 01 L-CULL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-FRICTION L-STRENGTH L-RANDOM L-CULL.
     MOVE 0 TO L-RANDOM L-CULL
     MOVE 980 TO L-FRICTION
     MOVE 5 TO L-STRENGTH
     IF L-BLOCK = 2
         MOVE 989 TO L-FRICTION
         MOVE 28 TO L-STRENGTH
         MOVE 1 TO L-CULL
     END-IF
     GOBACK.
 END PROGRAM GC3-ICE-PLAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-FROSTED-CONST.
*> USING MAX_AGE, NEIGHBORS_TO_AGE, NEIGHBORS_TO_MELT, states, random-ticking (BINARY-LONG out): the constants of FrostedIceBlock (7.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MAX-AGE              BINARY-LONG.
 01 L-TO-AGE               BINARY-LONG.
 01 L-TO-MELT              BINARY-LONG.
 01 L-STATES               BINARY-LONG.
 01 L-RANDOM               BINARY-LONG.
 PROCEDURE DIVISION USING L-MAX-AGE L-TO-AGE L-TO-MELT L-STATES L-RANDOM.
     MOVE 3 TO L-MAX-AGE
     MOVE 4 TO L-TO-AGE
     MOVE 2 TO L-TO-MELT
     COMPUTE L-STATES = L-MAX-AGE + 1
     MOVE 0 TO L-RANDOM
     GOBACK.
 END PROGRAM GC3-FROSTED-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-FROSTED-FEWER.
*> USING which of the six neighbours in Direction.values() order are frosted_ice (BINARY-LONG x 6), limit, fewer out: fewerNeighboursThan (7.3): false as soon as the count
*> reaches the limit, true after the loop.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STEP                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-NEIGHBOURS.
    05 L-N                 BINARY-LONG OCCURS 6 TIMES.
 01 L-LIMIT                BINARY-LONG.
 01 L-FEWER                BINARY-LONG.
 PROCEDURE DIVISION USING L-NEIGHBOURS L-LIMIT L-FEWER.
     MOVE 0 TO WS-COUNT
     MOVE 1 TO L-FEWER
     PERFORM VARYING WS-STEP FROM 1 BY 1 UNTIL WS-STEP > 6 OR L-FEWER = 0
         IF L-N(WS-STEP) = 1
             ADD 1 TO WS-COUNT
             IF WS-COUNT >= L-LIMIT
                 MOVE 0 TO L-FEWER
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GC3-FROSTED-FEWER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-FROSTED-SLIGHT.
*> USING age (BINARY-LONG), new age, melted out: slightlyMelt (7.3): below 3 the age rises (flags 2) and false is returned; at 3 it melts and true is returned.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-NEW-AGE              BINARY-LONG.
 01 L-MELTED               BINARY-LONG.
 PROCEDURE DIVISION USING L-AGE L-NEW-AGE L-MELTED.
     MOVE L-AGE TO L-NEW-AGE
     MOVE 0 TO L-MELTED
     IF L-AGE < 3
         COMPUTE L-NEW-AGE = L-AGE + 1
         GOBACK
     END-IF
     MOVE 1 TO L-MELTED
     GOBACK.
 END PROGRAM GC3-FROSTED-SLIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-FROSTED-DELAY.
*> USING kind (1 placement U(60, 120), 2 reschedule U(20, 40)), the draw nextInt(range) (BINARY-LONG), delay out (7.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DRAW L-DELAY.
     COMPUTE L-DELAY = 20 + L-DRAW
     IF L-KIND = 1
         COMPUTE L-DELAY = 60 + L-DRAW
     END-IF
     GOBACK.
 END PROGRAM GC3-FROSTED-DELAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-FROSTED-LIGHT.
*> USING the dimension is the End, the block light, getMaxLocalRawBrightness (BINARY-LONG), light out: step 2 of the scheduled tick (7.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-END                  BINARY-LONG.
 01 L-BLOCK-LIGHT          BINARY-LONG.
 01 L-RAW                  BINARY-LONG.
 01 L-LIGHT                BINARY-LONG.
 PROCEDURE DIVISION USING L-END L-BLOCK-LIGHT L-RAW L-LIGHT.
     MOVE L-RAW TO L-LIGHT
     IF L-END = 1
         MOVE L-BLOCK-LIGHT TO L-LIGHT
     END-IF
     GOBACK.
 END PROGRAM GC3-FROSTED-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-FROSTED-TICK.
*> USING the draw nextInt(3), fewerNeighboursThan(4), the light of step 2, age, light dampening (BINARY-LONG), outcome (1 reschedule only, 2 aged then reschedule, 3 melted:
*> neighbours aged, no reschedule), age after, the neighbour test was evaluated out: the scheduled tick of 7.3 (the neighbour test is not evaluated when the draw is 0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-FEWER                BINARY-LONG.
 01 L-LIGHT                BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-DAMPENING            BINARY-LONG.
 01 L-OUTCOME              BINARY-LONG.
 01 L-NEW-AGE              BINARY-LONG.
 01 L-EVALUATED            BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-FEWER L-LIGHT L-AGE L-DAMPENING L-OUTCOME L-NEW-AGE L-EVALUATED.
     MOVE 1 TO L-OUTCOME
     MOVE L-AGE TO L-NEW-AGE
     MOVE 0 TO L-EVALUATED
     IF L-DRAW NOT = 0
         MOVE 1 TO L-EVALUATED
         IF L-FEWER = 0
             GOBACK
         END-IF
     END-IF
     IF L-LIGHT > 11 - L-AGE - L-DAMPENING
         IF L-AGE < 3
             MOVE 2 TO L-OUTCOME
             COMPUTE L-NEW-AGE = L-AGE + 1
         ELSE
             MOVE 3 TO L-OUTCOME
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GC3-FROSTED-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-FROSTED-NEIGHBOUR.
*> USING the neighbour is frosted_ice, its age (BINARY-LONG), action (0 nothing, 1 aged and its tick scheduled with U(20, 40), 2 melted), age after out: step 4 of 7.3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FROSTED              BINARY-LONG.
 01 L-AGE                  BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-NEW-AGE              BINARY-LONG.
 PROCEDURE DIVISION USING L-FROSTED L-AGE L-ACTION L-NEW-AGE.
     MOVE 0 TO L-ACTION
     MOVE L-AGE TO L-NEW-AGE
     IF L-FROSTED = 0
         GOBACK
     END-IF
     IF L-AGE < 3
         MOVE 1 TO L-ACTION
         COMPUTE L-NEW-AGE = L-AGE + 1
         GOBACK
     END-IF
     MOVE 2 TO L-ACTION
     GOBACK.
 END PROGRAM GC3-FROSTED-NEIGHBOUR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-FROSTED-NU.
*> USING the changed neighbour is frosted_ice, fewerNeighboursThan(2) (BINARY-LONG), melts out (1 melts at once, 0 the generic rule): neighbour update of 7.3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FROSTED              BINARY-LONG.
 01 L-FEWER                BINARY-LONG.
 01 L-MELTS                BINARY-LONG.
 PROCEDURE DIVISION USING L-FROSTED L-FEWER L-MELTS.
     MOVE 0 TO L-MELTS
     IF L-FROSTED = 1 AND L-FEWER = 1
         MOVE 1 TO L-MELTS
     END-IF
     GOBACK.
 END PROGRAM GC3-FROSTED-NU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-POWDER-REG.
*> USING random-ticking, strength x 100, dynamicShape, noOcclusion, redstone conductor, in tag snow (BINARY-LONG out): the registry facts of powder snow (8).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RANDOM               BINARY-LONG.
 01 L-STRENGTH             BINARY-LONG.
 01 L-DYNAMIC              BINARY-LONG.
 01 L-NO-OCCLUSION         BINARY-LONG.
 01 L-CONDUCTOR            BINARY-LONG.
 01 L-SNOW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-RANDOM L-STRENGTH L-DYNAMIC L-NO-OCCLUSION L-CONDUCTOR L-SNOW.
     MOVE 0 TO L-RANDOM L-CONDUCTOR
     MOVE 25 TO L-STRENGTH
     MOVE 1 TO L-DYNAMIC L-NO-OCCLUSION L-SNOW
     GOBACK.
 END PROGRAM GC3-POWDER-REG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-DAMPENING.
*> USING the state is solid-render, it propagates skylight down (BINARY-LONG), light dampening out: the default rule (8): 15 when solid-render, else 0 when it propagates
*> skylight down, else 1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SOLID                BINARY-LONG.
 01 L-SKY                  BINARY-LONG.
 01 L-DAMPENING            BINARY-LONG.
 PROCEDURE DIVISION USING L-SOLID L-SKY L-DAMPENING.
     MOVE 1 TO L-DAMPENING
     IF L-SOLID = 1
         MOVE 15 TO L-DAMPENING
         GOBACK
     END-IF
     IF L-SKY = 1
         MOVE 0 TO L-DAMPENING
     END-IF
     GOBACK.
 END PROGRAM GC3-DAMPENING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-ROD-CONST.
*> USING ACTIVATION_TICKS, RANGE, SPARK_CYCLE, default facing (2 up), default powered (BINARY-LONG out): the constants of LightningRodBlock (9.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ACTIVATION           BINARY-LONG.
 01 L-RANGE                BINARY-LONG.
 01 L-CYCLE                BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ACTIVATION L-RANGE L-CYCLE L-FACING L-POWERED.
     MOVE 8 TO L-ACTIVATION
     MOVE 128 TO L-RANGE
     MOVE 200 TO L-CYCLE
     MOVE 2 TO L-FACING
     MOVE 0 TO L-POWERED
     GOBACK.
 END PROGRAM GC3-ROD-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-ROD-STRIKE.
*> USING facing (1 down, 2 up, 3 north, 4 south, 5 west, 6 east: Direction.values()), powered, direction of the neighbour update (the opposite of facing), tick delay, level event,
*> its data (the axis ordinal of facing: X 0, Y 1, Z 2) (BINARY-LONG out): onLightningStrike (9.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-OPPOSITE             BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-DATA                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-POWERED L-OPPOSITE L-DELAY L-EVENT L-DATA.
     MOVE 1 TO L-POWERED
     MOVE 8 TO L-DELAY
     MOVE 3002 TO L-EVENT
     EVALUATE L-FACING
         WHEN 1
             MOVE 2 TO L-OPPOSITE
             MOVE 1 TO L-DATA
         WHEN 2
             MOVE 1 TO L-OPPOSITE
             MOVE 1 TO L-DATA
         WHEN 3
             MOVE 4 TO L-OPPOSITE
             MOVE 2 TO L-DATA
         WHEN 4
             MOVE 3 TO L-OPPOSITE
             MOVE 2 TO L-DATA
         WHEN 5
             MOVE 6 TO L-OPPOSITE
             MOVE 0 TO L-DATA
         WHEN OTHER
             MOVE 5 TO L-OPPOSITE
             MOVE 0 TO L-DATA
     END-EVALUATE
     GOBACK.
 END PROGRAM GC3-ROD-STRIKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-ROD-TICK.
*> USING powered, neighbours updated (BINARY-LONG out): the scheduled tick of the lightning rod (9.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWERED              BINARY-LONG.
 01 L-UPDATES              BINARY-LONG.
 PROCEDURE DIVISION USING L-POWERED L-UPDATES.
     MOVE 0 TO L-POWERED
     MOVE 1 TO L-UPDATES
     GOBACK.
 END PROGRAM GC3-ROD-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-ROD-PLACE.
*> USING the old block is this block, the state is powered, a tick is scheduled at the position (BINARY-LONG), schedules a tick, its delay out: placement (9.2 PL).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OLD-SAME             BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-SCHEDULED            BINARY-LONG.
 01 L-SCHEDULES            BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-OLD-SAME L-POWERED L-SCHEDULED L-SCHEDULES L-DELAY.
     MOVE 0 TO L-SCHEDULES L-DELAY
     IF L-OLD-SAME = 0 AND L-POWERED = 1 AND L-SCHEDULED = 0
         MOVE 1 TO L-SCHEDULES
         MOVE 8 TO L-DELAY
     END-IF
     GOBACK.
 END PROGRAM GC3-ROD-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-ROD-REMOVE.
*> USING the removed state was powered (BINARY-LONG), neighbours updated out (9.2 removal).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWERED              BINARY-LONG.
 01 L-UPDATES              BINARY-LONG.
 PROCEDURE DIVISION USING L-POWERED L-UPDATES.
     MOVE L-POWERED TO L-UPDATES
     GOBACK.
 END PROGRAM GC3-ROD-REMOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-ROD-SIGNAL.
*> USING powered, facing, the direction asked (BINARY-LONG), own signal, direct signal out: the signals of the lightning rod (9.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWERED              BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-DIRECTION            BINARY-LONG.
 01 L-OWN                  BINARY-LONG.
 01 L-DIRECT               BINARY-LONG.
 PROCEDURE DIVISION USING L-POWERED L-FACING L-DIRECTION L-OWN L-DIRECT.
     MOVE 0 TO L-OWN L-DIRECT
     IF L-POWERED = 1
         MOVE 15 TO L-OWN
     END-IF
     IF L-POWERED = 1 AND L-FACING = L-DIRECTION
         MOVE 15 TO L-DIRECT
     END-IF
     GOBACK.
 END PROGRAM GC3-ROD-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-ROD-ANIM.
*> USING thundering, the draw nextInt(200), gameTime mod 200, the block is the top of its column (Y = WORLD_SURFACE height - 1), the draw of UniformInt(1, 2) as nextInt(2)
*> (BINARY-LONG), particles, spacing x 1000, draws made out: animateTick (9.2, client only); the draw must be at most the remainder.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-THUNDER              BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-MOD                  BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-COUNT-DRAW           BINARY-LONG.
 01 L-PARTICLES            BINARY-LONG.
 01 L-SPACING              BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-THUNDER L-DRAW L-MOD L-TOP L-COUNT-DRAW L-PARTICLES L-SPACING L-DRAWS.
     MOVE 0 TO L-PARTICLES L-DRAWS
     MOVE 125 TO L-SPACING
     IF L-THUNDER = 0
         GOBACK
     END-IF
     MOVE 1 TO L-DRAWS
     IF L-DRAW > L-MOD OR L-TOP = 0
         GOBACK
     END-IF
     MOVE 2 TO L-DRAWS
     COMPUTE L-PARTICLES = 1 + L-COUNT-DRAW
     GOBACK.
 END PROGRAM GC3-ROD-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-STRIKE-BLOCK.
*> USING the bolt position x, y, z (FLOAT-LONG), the block x, y, z (BINARY-LONG out): the block containing (x, y - 1.0E-6, z) (9.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-BX L-BY L-BZ.
     COMPUTE L-BX = FUNCTION INTEGER(L-X)
     COMPUTE L-BY = FUNCTION INTEGER(L-Y - 0.000001)
     COMPUTE L-BZ = FUNCTION INTEGER(L-Z)
     GOBACK.
 END PROGRAM GC3-STRIKE-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-COPPER-START.
*> USING the block at the strike is a LightningRodBlock, it is waxed (a key of the wax-off map), it is a WeatheringCopper (BINARY-LONG), the rod is struck, a weathering block
*> is reset to the unaffected variant, the walks run out: powerLightningRod and the start of clearCopperOnLightningStrike (9.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROD                  BINARY-LONG.
 01 L-WAXED                BINARY-LONG.
 01 L-WEATHERING           BINARY-LONG.
 01 L-STRIKES              BINARY-LONG.
 01 L-RESET                BINARY-LONG.
 01 L-WALKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROD L-WAXED L-WEATHERING L-STRIKES L-RESET L-WALKS.
     MOVE L-ROD TO L-STRIKES
     MOVE L-WEATHERING TO L-RESET
     MOVE 0 TO L-WALKS
     IF L-WAXED = 1 OR L-WEATHERING = 1
         MOVE 1 TO L-WALKS
     END-IF
     GOBACK.
 END PROGRAM GC3-COPPER-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-COPPER-COUNT.
*> USING kind (1 the number of walks 3 + nextInt(3), 2 the steps of a walk 1 + nextInt(8)), the draw (BINARY-LONG), the count out (9.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DRAW L-COUNT.
     COMPUTE L-COUNT = 1 + L-DRAW
     IF L-KIND = 1
         COMPUTE L-COUNT = 3 + L-DRAW
     END-IF
     GOBACK.
 END PROGRAM GC3-COPPER-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-COPPER-STEP.
*> USING the 10 candidate positions of BlockPos.randomInCube in order (BINARY-LONG x 10: 0 not a WeatheringCopper, 1 one with a previous state, 2 one without), the index
*> returned (0 for nothing), the previous state is set, level event 3002 with data -1 sent, positions taken, nextInt(3) draws made out: randomStep (9.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STEP                BINARY-LONG.
 LINKAGE SECTION.
 01 L-CELLS.
    05 L-CELL              BINARY-LONG OCCURS 10 TIMES.
 01 L-INDEX                BINARY-LONG.
 01 L-SET                  BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-TAKEN                BINARY-LONG.
 01 L-DRAWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-CELLS L-INDEX L-SET L-EVENT L-TAKEN L-DRAWS.
     MOVE 0 TO L-INDEX L-SET L-EVENT L-TAKEN
     PERFORM VARYING WS-STEP FROM 1 BY 1 UNTIL WS-STEP > 10 OR L-INDEX > 0
         ADD 1 TO L-TAKEN
         IF L-CELL(WS-STEP) > 0
             MOVE WS-STEP TO L-INDEX
             MOVE 1 TO L-EVENT
         END-IF
         IF L-CELL(WS-STEP) = 1
             MOVE 1 TO L-SET
         END-IF
     END-PERFORM
     COMPUTE L-DRAWS = 3 * L-TAKEN
     GOBACK.
 END PROGRAM GC3-COPPER-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-COPPER-WALK.
*> USING the steps of the walk, how many consecutive randomStep calls from the strike return a position (BINARY-LONG), randomStep calls made, moves out: randomWalk (9.3):
*> the walk ends at the first call that returns nothing.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STEPS                BINARY-LONG.
 01 L-SUCCEED              BINARY-LONG.
 01 L-CALLS                BINARY-LONG.
 01 L-MOVES                BINARY-LONG.
 PROCEDURE DIVISION USING L-STEPS L-SUCCEED L-CALLS L-MOVES.
     MOVE L-STEPS TO L-CALLS
     MOVE L-SUCCEED TO L-MOVES
     IF L-SUCCEED < L-STEPS
         COMPUTE L-CALLS = L-SUCCEED + 1
     ELSE
         MOVE L-STEPS TO L-MOVES
     END-IF
     GOBACK.
 END PROGRAM GC3-COPPER-WALK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GC3-BOLT-ORDER.
*> USING difficulty (0 peaceful, 1 easy, 2 normal, 3 hard), the bolt is visual-only (BINARY-LONG), fire step, powerLightningRod, clearCopper, game event lightning_strike out
*> (1 when it runs): the order of 9.4 at life 2; spawnFire needs Normal or Hard and a bolt that is not visual-only, the other three always run.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIFFICULTY           BINARY-LONG.
 01 L-VISUAL               BINARY-LONG.
 01 L-FIRE                 BINARY-LONG.
 01 L-ROD                  BINARY-LONG.
 01 L-COPPER               BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIFFICULTY L-VISUAL L-FIRE L-ROD L-COPPER L-EVENT.
     MOVE 0 TO L-FIRE
     MOVE 1 TO L-ROD L-COPPER L-EVENT
     IF L-DIFFICULTY >= 2 AND L-VISUAL = 0
         MOVE 1 TO L-FIRE
     END-IF
     GOBACK.
 END PROGRAM GC3-BOLT-ORDER.
