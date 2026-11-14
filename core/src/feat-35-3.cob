*> Worldgen features, part 3 (docs/protocol/35-worldgen-features-3-tree-placers.md): the shared tree helpers (section 1), the rules of TreeFeature that
*> need no level (section 2: the height and room checks, the free height scan, the result rule, the leaf distance relaxation, the position hash, the passes of the
*> shape update) and the feature sizes (section 3), as pure programs over explicit inputs. Directions are the ordinals DOWN 0, UP 1, NORTH 2, SOUTH 3, WEST 4,
*> EAST 5; the draws are those of the wrapped WorldgenRandom (WGR-*, core/src/ores.cob).
*>
*> Entry points: F353-TREE-HEIGHT, F353-RANDOM-DIRECTION, F353-STEP, F353-VALID-TREE-POS, F353-ATTACHMENT-SIZE, F353-WATERLOGGED (section 1);
*>   F353-ROOM-OK, F353-CLIP-OK, F353-MAX-FREE, F353-TREE-RESULT, F353-POS-HASH, F353-LEAF-RELAX, F353-PASS-DIRECTIONS (section 2); F353-SIZE-AT (section 3).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F353-TREE-HEIGHT.
*> Section 1 getTreeHeight: USING state, base height, random a, random b (BINARY-LONG), height out: base + nextInt(a + 1) + nextInt(b + 1), both draws always made.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BOUND               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-BASE                 BINARY-LONG.
 01 L-RAND-A               BINARY-LONG.
 01 L-RAND-B               BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-BASE L-RAND-A L-RAND-B L-HEIGHT.
     COMPUTE WS-BOUND = L-RAND-A + 1
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-A
     COMPUTE WS-BOUND = L-RAND-B + 1
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-B
     COMPUTE L-HEIGHT = L-BASE + WS-A + WS-B
     GOBACK.
 END PROGRAM F353-TREE-HEIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F353-RANDOM-DIRECTION.
*> Section 1 getRandomDirection: USING state, direction out (the ordinal): [NORTH, EAST, SOUTH, WEST][nextInt(4)].
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-I                   BINARY-LONG.
 01 WS-PLANE.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 4.
 01 WS-PLANE-TABLE REDEFINES WS-PLANE.
    05 WS-ORD BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-DIRECTION            BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-DIRECTION.
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-FOUR WS-I
     MOVE WS-ORD(WS-I + 1) TO L-DIRECTION
     GOBACK.
 END PROGRAM F353-RANDOM-DIRECTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F353-STEP.
*> Section 1: USING direction (ordinal), dx, dy, dz out: NORTH z-1, SOUTH z+1, WEST x-1, EAST x+1, DOWN y-1, UP y+1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIRECTION            BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIRECTION L-DX L-DY L-DZ.
     MOVE 0 TO L-DX L-DY L-DZ
     EVALUATE L-DIRECTION
         WHEN 0
             MOVE -1 TO L-DY
         WHEN 1
             MOVE 1 TO L-DY
         WHEN 2
             MOVE -1 TO L-DZ
         WHEN 3
             MOVE 1 TO L-DZ
         WHEN 4
             MOVE -1 TO L-DX
         WHEN OTHER
             MOVE 1 TO L-DX
     END-EVALUATE
     GOBACK.
 END PROGRAM F353-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F353-VALID-TREE-POS.
*> Section 1: USING air (0 or 1), in tag replaceable_by_trees (0 or 1), is a log (0 or 1), mode (1 validTreePos, 2 TrunkPlacer.isFree), flag out.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AIR                  BINARY-LONG.
 01 L-REPLACEABLE          BINARY-LONG.
 01 L-LOG                  BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-AIR L-REPLACEABLE L-LOG L-MODE L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-AIR = 1 OR L-REPLACEABLE = 1
         MOVE 1 TO L-FLAG
     END-IF
     IF L-MODE = 2 AND L-LOG = 1
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM F353-VALID-TREE-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F353-ATTACHMENT-SIZE.
*> Section 1.1: USING double trunk (0 or 1), size x out, size z out, double trunk out: the constructor sizes 2 when double, else 1; doubleTrunk() is both 2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DOUBLE               BINARY-LONG.
 01 L-SIZE-X               BINARY-LONG.
 01 L-SIZE-Z               BINARY-LONG.
 01 L-IS-DOUBLE            BINARY-LONG.
 PROCEDURE DIVISION USING L-DOUBLE L-SIZE-X L-SIZE-Z L-IS-DOUBLE.
     MOVE 1 TO L-SIZE-X L-SIZE-Z
     IF L-DOUBLE = 1
         MOVE 2 TO L-SIZE-X L-SIZE-Z
     END-IF
     MOVE 0 TO L-IS-DOUBLE
     IF L-SIZE-X = 2 AND L-SIZE-Z = 2
         MOVE 1 TO L-IS-DOUBLE
     END-IF
     GOBACK.
 END PROGRAM F353-ATTACHMENT-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F353-WATERLOGGED.
*> Section 1 waterlogged(p, s): USING has the waterlogged property (0 or 1), the fluid matches (0 or 1: in tag water for roots, a water source for leaves),
*> value out (-1 no property, else 0 or 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAS                  BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS L-FLUID L-VALUE.
     MOVE -1 TO L-VALUE
     IF L-HAS = 1
         MOVE L-FLUID TO L-VALUE
     END-IF
     GOBACK.
 END PROGRAM F353-WATERLOGGED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F353-ROOM-OK.
*> Section 2.2 step 5: USING pos y, root origin y, height H, level min y, level max y (the top block index) (BINARY-LONG), ok out: false when
*> min(pos.y, rootOrigin.y) < level min y + 1 or max(pos.y, rootOrigin.y) + H + 1 > level max y + 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LOW                 BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 LINKAGE SECTION.
 01 L-POS-Y                BINARY-LONG.
 01 L-ROOT-Y               BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-MIN-Y                BINARY-LONG.
 01 L-MAX-Y                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-POS-Y L-ROOT-Y L-H L-MIN-Y L-MAX-Y L-OK.
     MOVE L-POS-Y TO WS-LOW WS-HIGH
     IF L-ROOT-Y < WS-LOW
         MOVE L-ROOT-Y TO WS-LOW
     END-IF
     IF L-ROOT-Y > WS-HIGH
         MOVE L-ROOT-Y TO WS-HIGH
     END-IF
     COMPUTE WS-HIGH = WS-HIGH + L-H + 1
     MOVE 1 TO L-OK
     IF WS-LOW < L-MIN-Y + 1 OR WS-HIGH > L-MAX-Y + 1
         MOVE 0 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM F353-ROOM-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F353-CLIP-OK.
*> Section 2.2 step 6: USING free (the free height), H, min_clipped_height (-1 when absent), ok out: false when free < H and (absent or free < min_clipped).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FREE                 BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-MIN-CLIPPED          BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-FREE L-H L-MIN-CLIPPED L-OK.
     MOVE 1 TO L-OK
     IF L-FREE < L-H AND (L-MIN-CLIPPED < 0 OR L-FREE < L-MIN-CLIPPED)
         MOVE 0 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM F353-CLIP-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F353-MAX-FREE.
*> Section 2.3 getMaxFreeTreeHeight over a world whose only blocked cell is one position relative to the root origin: USING H, size kind (1 two layers, 2 three
*> layers), limit, upper limit, lower size, middle size, upper size (BINARY-LONG; middle and upper limit are unused for kind 1), blocked dx, dy, dz, the blocked cell
*> is a vine (0 or 1), ignore vines (0 or 1), free out. For y from 0 to H + 1 and every (dx, dz) within the size s of the layer (x outer): a blocked cell
*> that is not free (or a vine unless ignored) returns y - 2; otherwise H.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Y                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-H                    BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-LIMIT                BINARY-LONG.
 01 L-UPPER-LIMIT          BINARY-LONG.
 01 L-LOWER                BINARY-LONG.
 01 L-MIDDLE               BINARY-LONG.
 01 L-UPPER                BINARY-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 01 L-VINE                 BINARY-LONG.
 01 L-IGNORE               BINARY-LONG.
 01 L-FREE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-H L-KIND L-LIMIT L-UPPER-LIMIT L-LOWER L-MIDDLE L-UPPER L-BX L-BY L-BZ L-VINE L-IGNORE L-FREE.
     MOVE L-H TO L-FREE
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > L-H + 1 OR WS-DONE = 1
         CALL "F353-SIZE-AT" USING L-KIND L-LIMIT L-UPPER-LIMIT L-LOWER L-MIDDLE L-UPPER L-H WS-Y WS-S
         MOVE 0 TO WS-HIT
         IF L-BY = WS-Y AND FUNCTION ABS(L-BX) <= WS-S AND FUNCTION ABS(L-BZ) <= WS-S
             IF L-VINE = 0 OR L-IGNORE = 0
                 MOVE 1 TO WS-HIT
             END-IF
         END-IF
         IF WS-HIT = 1
             COMPUTE L-FREE = WS-Y - 2
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM F353-MAX-FREE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F353-TREE-RESULT.
*> Section 2.1 step 2: USING number of logs, number of foliage positions, result out (1 unless both are empty: roots alone do not count).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LOGS                 BINARY-LONG.
 01 L-FOLIAGE              BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-LOGS L-FOLIAGE L-RESULT.
     MOVE 1 TO L-RESULT
     IF L-LOGS = 0 AND L-FOLIAGE = 0
         MOVE 0 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM F353-TREE-RESULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F353-POS-HASH.
*> Section 2.4 Vec3i.hashCode: USING x, y, z (BINARY-LONG), hash out (BINARY-LONG): ((y + z * 31) * 31 + x) in 32-bit signed arithmetic.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-H                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-HASH                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-HASH.
     COMPUTE WS-H = FUNCTION MOD((L-Y + L-Z * 31) * 31 + L-X + 2147483648, 4294967296) - 2147483648
     MOVE WS-H TO L-HASH
     GOBACK.
 END PROGRAM F353-POS-HASH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F353-LEAF-RELAX.
*> Section 2.4 step 3: USING the neighbour's distance (BINARY-LONG; -1 for none), the popped layer i, new layer out, enqueue out (0 or 1): nd = min(dist, i + 1),
*> enqueued when nd < 7; a neighbour with no distance is skipped.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIST                 BINARY-LONG.
 01 L-I                    BINARY-LONG.
 01 L-ND                   BINARY-LONG.
 01 L-ENQUEUE              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIST L-I L-ND L-ENQUEUE.
     MOVE 0 TO L-ENQUEUE L-ND
     IF L-DIST >= 0
         MOVE L-DIST TO L-ND
         IF L-I + 1 < L-ND
             COMPUTE L-ND = L-I + 1
         END-IF
         IF L-ND < 7
             MOVE 1 TO L-ENQUEUE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM F353-LEAF-RELAX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F353-PASS-DIRECTIONS.
*> Section 2.5: USING pass (1 NONE, 2 FORWARD, 3 BACKWARD), negative direction out, positive direction out (ordinals): NORTH and SOUTH along z, DOWN and UP
*> along y, WEST and EAST along x.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PASS                 BINARY-LONG.
 01 L-NEG                  BINARY-LONG.
 01 L-POS                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PASS L-NEG L-POS.
     EVALUATE L-PASS
         WHEN 1
             MOVE 2 TO L-NEG
             MOVE 3 TO L-POS
         WHEN 2
             MOVE 0 TO L-NEG
             MOVE 1 TO L-POS
         WHEN OTHER
             MOVE 4 TO L-NEG
             MOVE 5 TO L-POS
     END-EVALUATE
     GOBACK.
 END PROGRAM F353-PASS-DIRECTIONS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F353-SIZE-AT.
*> Section 3: USING kind (1 two_layers_feature_size, 2 three_layers_feature_size), limit, upper limit, lower size, middle size, upper size, H, y (BINARY-LONG),
*> size out. Two layers: lower below the limit, else upper. Three layers: lower below the limit; upper from H - upper limit; else middle.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-LIMIT                BINARY-LONG.
 01 L-UPPER-LIMIT          BINARY-LONG.
 01 L-LOWER                BINARY-LONG.
 01 L-MIDDLE               BINARY-LONG.
 01 L-UPPER                BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-LIMIT L-UPPER-LIMIT L-LOWER L-MIDDLE L-UPPER L-H L-Y L-SIZE.
     EVALUATE TRUE
         WHEN L-Y < L-LIMIT
             MOVE L-LOWER TO L-SIZE
         WHEN L-KIND = 1
             MOVE L-UPPER TO L-SIZE
         WHEN L-Y >= L-H - L-UPPER-LIMIT
             MOVE L-UPPER TO L-SIZE
         WHEN OTHER
             MOVE L-MIDDLE TO L-SIZE
     END-EVALUATE
     GOBACK.
 END PROGRAM F353-SIZE-AT.
