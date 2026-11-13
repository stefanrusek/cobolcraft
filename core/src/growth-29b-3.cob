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
