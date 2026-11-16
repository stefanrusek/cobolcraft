*> The runtime of the feature stage (docs/protocol/35-worldgen-features-1 sections 7 to 9, 35-2, 35-4 section 4): places a compiled placed feature (FEATDATA.cpy) through
*> the world-generation level (FEATLEVEL.cpy). Deviations, all listed in docs/design notes of the lane: block states carry no properties (a state is the default state of a
*> block), canSurvive is approximated by "a block that is not air lies below", and a fluid state is the one of a water or lava block.
*>
*> Entry points:
*>   FR-INT-SAMPLE USING state, provider (4 integers: type, a, b, c), value out
*>   FR-HP-SAMPLE USING state, provider (6 integers), min y, height, sea level, y out
*>   FR-PRED-TEST USING predicate, x, y, z, result out
*>   FR-PROV-STATE USING state, provider, x, y, z, block state out, ok out (0: nothing chosen)
*>   FR-PLACE-PF USING state, placed feature, top placed feature (0 for none), x, y, z, result out
*>   FR-PLACE-FT USING state, feature, x, y, z, result out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-NEXT-INT.
*> USING state, bound (BINARY-LONG, may be below 1: gives 0 without a draw), result out: nextInt(bound).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-BOUND                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-BOUND L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-BOUND > 0
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE L-BOUND L-RESULT
     END-IF
     GOBACK.
 END PROGRAM FR-NEXT-INT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-INT-SAMPLE IS RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-BOUND               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-RANGE               BINARY-LONG.
 01 WS-SLOPE               BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-G                   FLOAT-LONG.
 01 WS-FA                  FLOAT-LONG.
 01 WS-FB                  FLOAT-LONG.
 01 WS-FC                  FLOAT-LONG.
 01 WS-MILLION             FLOAT-LONG VALUE 1000000.
 LOCAL-STORAGE SECTION.
 01 LS-SOURCE.
    05 LS-Q                BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-P.
    05 L-V                 BINARY-LONG OCCURS 4 TIMES.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-P L-VALUE.
     EVALUATE L-V(1)
         WHEN 1
             MOVE L-V(2) TO L-VALUE
         WHEN 6
*>           weighted_list of constants: one draw below the total weight, the first entry whose running weight exceeds it
             MOVE 0 TO L-VALUE
             IF L-V(4) > 0
                 CALL "FR-NEXT-INT" USING L-STATE L-V(4) WS-A
                 MOVE 0 TO WS-B WS-SIDE
                 PERFORM VARYING WS-RANGE FROM 0 BY 1 UNTIL WS-RANGE >= L-V(3) OR WS-SIDE = 1
                     COMPUTE WS-BOUND = L-V(2) + WS-RANGE * 2
                     COMPUTE WS-SLOPE = WS-BOUND + 1
                     ADD FD-POOL(WS-SLOPE) TO WS-B
                     IF WS-A < WS-B
                         MOVE FD-POOL(WS-BOUND) TO L-VALUE
                         MOVE 1 TO WS-SIDE
*>                       a uniform entry (see FD-J-IP): the entry is sampled after the pick, one nextInt(range)
                         IF L-VALUE >= 1000000000
                             COMPUTE WS-RANGE = L-VALUE - 1000000000
                             DIVIDE WS-RANGE BY 20000 GIVING WS-SLOPE REMAINDER WS-B
                             COMPUTE WS-SLOPE = WS-SLOPE - 10000
                             COMPUTE WS-B = WS-B - 10000
                             COMPUTE WS-BOUND = WS-B - WS-SLOPE + 1
                             CALL "FR-NEXT-INT" USING L-STATE WS-BOUND WS-A
                             COMPUTE L-VALUE = WS-SLOPE + WS-A
                         END-IF
                     END-IF
                 END-PERFORM
             END-IF
         WHEN 2
             COMPUTE WS-BOUND = L-V(3) - L-V(2) + 1
             CALL "FR-NEXT-INT" USING L-STATE WS-BOUND WS-A
             COMPUTE L-VALUE = L-V(2) + WS-A
*>       trapezoid (35-4 2.2): symmetric with no plateau: nextInt(max + 1) - nextInt(max + 1); a plateau over the whole span: one draw; else min + nextInt(hi + 1) + nextInt(lo + 1)
         WHEN 5
             COMPUTE WS-RANGE = L-V(3) - L-V(2)
             EVALUATE TRUE
                 WHEN L-V(4) = 0 AND L-V(3) = 0 - L-V(2)
                     COMPUTE WS-BOUND = L-V(3) + 1
                     CALL "FR-NEXT-INT" USING L-STATE WS-BOUND WS-A
                     CALL "FR-NEXT-INT" USING L-STATE WS-BOUND WS-B
                     COMPUTE L-VALUE = WS-A - WS-B
                 WHEN L-V(4) = WS-RANGE
                     COMPUTE WS-BOUND = WS-RANGE + 1
                     CALL "FR-NEXT-INT" USING L-STATE WS-BOUND WS-A
                     COMPUTE L-VALUE = L-V(2) + WS-A
                 WHEN OTHER
                     COMPUTE WS-SLOPE = WS-RANGE - L-V(4)
                     DIVIDE WS-SLOPE BY 2 GIVING WS-SIDE
                     COMPUTE WS-BOUND = WS-RANGE - WS-SIDE + 1
                     CALL "FR-NEXT-INT" USING L-STATE WS-BOUND WS-A
                     COMPUTE WS-BOUND = WS-SIDE + 1
                     CALL "FR-NEXT-INT" USING L-STATE WS-BOUND WS-B
                     COMPUTE L-VALUE = L-V(2) + WS-A + WS-B
             END-EVALUATE
         WHEN 3
             COMPUTE WS-BOUND = L-V(3) - L-V(2) + 1
             CALL "FR-NEXT-INT" USING L-STATE WS-BOUND WS-A
             COMPUTE WS-BOUND = WS-A + 1
             CALL "FR-NEXT-INT" USING L-STATE WS-BOUND WS-B
             COMPUTE L-VALUE = L-V(2) + WS-B
         WHEN 4
             COMPUTE WS-BOUND = L-V(3) - L-V(2) + 1
             CALL "FR-NEXT-INT" USING L-STATE WS-BOUND WS-A
             COMPUTE WS-BOUND = WS-A + 1
             CALL "FR-NEXT-INT" USING L-STATE WS-BOUND WS-B
             COMPUTE WS-BOUND = WS-B + 1
             CALL "FR-NEXT-INT" USING L-STATE WS-BOUND WS-A
             COMPUTE L-VALUE = L-V(2) + WS-A
*>       clamped: the source (four integers in the pool from L-V(4)) is sampled with its own draws, then clamped to L-V(2) .. L-V(3)
         WHEN 7
             PERFORM VARYING WS-RANGE FROM 1 BY 1 UNTIL WS-RANGE > 4
                 COMPUTE WS-BOUND = L-V(4) + WS-RANGE - 1
                 MOVE FD-POOL(WS-BOUND) TO LS-Q(WS-RANGE)
             END-PERFORM
             CALL "FR-INT-SAMPLE" USING L-STATE LS-SOURCE L-VALUE
             IF L-VALUE < L-V(2)
                 MOVE L-V(2) TO L-VALUE
             END-IF
             IF L-VALUE > L-V(3)
                 MOVE L-V(3) TO L-VALUE
             END-IF
*>       clamped_normal: one Gaussian draw, (int) clamp(mean + (float) g * deviation, min, max), every step in single precision (the mean and deviation are pool entries in millionths)
         WHEN 8
             CALL "F351-NEXT-GAUSSIAN" USING L-STATE WS-G
             CALL "FR-F32" USING WS-G
             MOVE FD-POOL(L-V(4)) TO WS-FA
             CALL STATIC "cc_f64_div" USING BY REFERENCE WS-FA WS-MILLION WS-FB
             CALL "FR-F32" USING WS-FB
             COMPUTE WS-BOUND = L-V(4) + 1
             MOVE FD-POOL(WS-BOUND) TO WS-FA
             CALL STATIC "cc_f64_div" USING BY REFERENCE WS-FA WS-MILLION WS-FC
             CALL "FR-F32" USING WS-FC
             CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-G WS-FC WS-FA
             CALL "FR-F32" USING WS-FA
             CALL STATIC "cc_f64_add" USING BY REFERENCE WS-FB WS-FA WS-G
             CALL "FR-F32" USING WS-G
             MOVE L-V(2) TO WS-FA
             MOVE L-V(3) TO WS-FB
             IF WS-G < WS-FA
                 MOVE WS-FA TO WS-G
             END-IF
             IF WS-G > WS-FB
                 MOVE WS-FB TO WS-G
             END-IF
             CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-G L-VALUE
         WHEN OTHER
             IF L-V(4) = 0 AND L-V(3) = 0 - L-V(2)
                 COMPUTE WS-BOUND = L-V(3) + 1
                 CALL "FR-NEXT-INT" USING L-STATE WS-BOUND WS-A
                 CALL "FR-NEXT-INT" USING L-STATE WS-BOUND WS-B
                 COMPUTE L-VALUE = WS-A - WS-B
             ELSE
                 COMPUTE WS-RANGE = L-V(3) - L-V(2)
                 IF L-V(4) = WS-RANGE
                     COMPUTE WS-BOUND = WS-RANGE + 1
                     CALL "FR-NEXT-INT" USING L-STATE WS-BOUND WS-A
                     COMPUTE L-VALUE = L-V(2) + WS-A
                 ELSE
                     COMPUTE WS-SLOPE = FUNCTION INTEGER((WS-RANGE - L-V(4)) / 2)
                     COMPUTE WS-SIDE = WS-RANGE - WS-SLOPE
                     COMPUTE WS-BOUND = WS-SIDE + 1
                     CALL "FR-NEXT-INT" USING L-STATE WS-BOUND WS-A
                     COMPUTE WS-BOUND = WS-SLOPE + 1
                     CALL "FR-NEXT-INT" USING L-STATE WS-BOUND WS-B
                     COMPUTE L-VALUE = L-V(2) + WS-A + WS-B
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM FR-INT-SAMPLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-NI.
*> USING state, low, high, result out: Mth.nextInt(r, lo, hi): lo when lo >= hi, else lo + nextInt(hi - lo + 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BOUND               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-LOW                  BINARY-LONG.
 01 L-HIGH                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-LOW L-HIGH L-RESULT.
     MOVE L-LOW TO L-RESULT
     IF L-LOW < L-HIGH
         COMPUTE WS-BOUND = L-HIGH - L-LOW + 1
         CALL "FR-NEXT-INT" USING L-STATE WS-BOUND WS-A
         COMPUTE L-RESULT = L-LOW + WS-A
     END-IF
     GOBACK.
 END PROGRAM FR-NI.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-HP-SAMPLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-INNER               BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-U                   BINARY-LONG.
 01 WS-RANGE               BINARY-LONG.
 01 WS-SLOPE               BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-P.
    05 L-V                 BINARY-LONG OCCURS 6 TIMES.
 01 L-MIN-Y                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-SEA                  BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-P L-MIN-Y L-HEIGHT L-SEA L-Y.
     MOVE L-V(3) TO WS-K
     MOVE L-V(4) TO WS-N
     CALL "F352-ANCHOR" USING WS-K WS-N L-MIN-Y L-HEIGHT L-SEA WS-LO
     MOVE L-V(5) TO WS-K
     MOVE L-V(6) TO WS-N
     CALL "F352-ANCHOR" USING WS-K WS-N L-MIN-Y L-HEIGHT L-SEA WS-HI
     MOVE WS-LO TO L-Y
     MOVE L-V(2) TO WS-INNER
     EVALUATE L-V(1)
         WHEN 2
             IF WS-LO <= WS-HI
                 COMPUTE WS-BOUND = WS-HI - WS-LO + 1
                 CALL "FR-NEXT-INT" USING L-STATE WS-BOUND WS-A
                 COMPUTE L-Y = WS-LO + WS-A
             END-IF
         WHEN 3
             IF WS-HI - WS-LO - WS-INNER + 1 > 0
                 COMPUTE WS-BOUND = WS-HI - WS-LO - WS-INNER + 1
                 CALL "FR-NEXT-INT" USING L-STATE WS-BOUND WS-A
                 COMPUTE WS-BOUND = WS-A + WS-INNER
                 CALL "FR-NEXT-INT" USING L-STATE WS-BOUND WS-B
                 COMPUTE L-Y = WS-LO + WS-B
             END-IF
         WHEN 4
             IF WS-HI - WS-LO - WS-INNER + 1 > 0
                 COMPUTE WS-T = WS-LO + WS-INNER
                 CALL "FR-NI" USING L-STATE WS-T WS-HI WS-A
                 COMPUTE WS-T = WS-A - 1
                 CALL "FR-NI" USING L-STATE WS-LO WS-T WS-B
                 COMPUTE WS-U = WS-B - 1 + WS-INNER
                 CALL "FR-NI" USING L-STATE WS-LO WS-U L-Y
             END-IF
         WHEN 5
             IF WS-LO <= WS-HI
                 COMPUTE WS-RANGE = WS-HI - WS-LO
                 IF WS-INNER >= WS-RANGE
                     COMPUTE WS-BOUND = WS-RANGE + 1
                     CALL "FR-NEXT-INT" USING L-STATE WS-BOUND WS-A
                     COMPUTE L-Y = WS-LO + WS-A
                 ELSE
                     COMPUTE WS-SLOPE = FUNCTION INTEGER((WS-RANGE - WS-INNER) / 2)
                     COMPUTE WS-SIDE = WS-RANGE - WS-SLOPE
                     COMPUTE WS-BOUND = WS-SIDE + 1
                     CALL "FR-NEXT-INT" USING L-STATE WS-BOUND WS-A
                     COMPUTE WS-BOUND = WS-SLOPE + 1
                     CALL "FR-NEXT-INT" USING L-STATE WS-BOUND WS-B
                     COMPUTE L-Y = WS-LO + WS-A + WS-B
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM FR-HP-SAMPLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-POOL-HAS.
*> USING pool start, count, value, flag out: the value is among the count entries of the pool.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-START                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-START L-COUNT L-VALUE L-FLAG.
     MOVE 0 TO L-FLAG
     PERFORM VARYING WS-I FROM L-START BY 1 UNTIL WS-I >= L-START + L-COUNT OR L-FLAG = 1
         IF FD-POOL(WS-I) = L-VALUE
             MOVE 1 TO L-FLAG
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FR-POOL-HAS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-PRED-TEST IS RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY CBLOCKS.
 LOCAL-STORAGE SECTION.
 01 LS-X                   BINARY-LONG.
 01 LS-Y                   BINARY-LONG.
 01 LS-Z                   BINARY-LONG.
 01 LS-STATE               BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-CLASS               BINARY-LONG.
 01 LS-CODE                BINARY-LONG.
 01 LS-CHILD               BINARY-LONG.
 01 LS-R                   BINARY-LONG.
 01 LS-LO                  BINARY-LONG.
 01 LS-HI                  BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-K                   BINARY-LONG.
 01 LS-V                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-PRED                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-PRED L-X L-Y L-Z L-RESULT.
     MOVE 0 TO L-RESULT
     COMPUTE LS-X = L-X + PR-OX(L-PRED)
     COMPUTE LS-Y = L-Y + PR-OY(L-PRED)
     COMPUTE LS-Z = L-Z + PR-OZ(L-PRED)
     EVALUATE PR-TYPE(L-PRED)
         WHEN 0
         WHEN 1
             CALL "FL-GET-STATE" USING LS-X LS-Y LS-Z LS-STATE
             CALL "FL-BLOCK-OF" USING LS-STATE LS-BLOCK
             CALL "FR-POOL-HAS" USING PR-POOL(L-PRED) PR-N(L-PRED) LS-BLOCK L-RESULT
         WHEN 2
             CALL "FL-GET-STATE" USING LS-X LS-Y LS-Z LS-STATE
             CALL "FL-CLASS" USING LS-STATE LS-CLASS
             MOVE 1 TO LS-CODE
             IF LS-CLASS = 2 OR LS-CLASS = 3
                 MOVE LS-CLASS TO LS-CODE
             END-IF
             CALL "FR-POOL-HAS" USING PR-POOL(L-PRED) PR-N(L-PRED) LS-CODE L-RESULT
         WHEN 5
             CALL "FL-GET-STATE" USING LS-X LS-Y LS-Z LS-STATE
             CALL "FL-BLOCK-OF" USING LS-STATE LS-BLOCK
             CALL "FL-CLASS" USING LS-STATE LS-CLASS
             IF LS-BLOCK > 0 AND LS-CLASS NOT = 1
                 IF CB-SOLID(LS-BLOCK) = 1
                     MOVE 1 TO L-RESULT
                 END-IF
             END-IF
*>       has_sturdy_face: the block at the offset is a full block (opaque; air, water and lava never are)
         WHEN 4
             CALL "FL-GET-STATE" USING LS-X LS-Y LS-Z LS-STATE
             CALL "FL-BLOCK-OF" USING LS-STATE LS-BLOCK
             IF LS-BLOCK > 0
                 IF CB-OPAQUE(LS-BLOCK) = 1
                     MOVE 1 TO L-RESULT
                 END-IF
             END-IF
*>       replaceable: the builder flag of the block at the offset (a cell outside the level reads as air, which is replaceable)
         WHEN 6
             CALL "FL-GET-STATE" USING LS-X LS-Y LS-Z LS-STATE
             CALL "FL-BLOCK-OF" USING LS-STATE LS-BLOCK
             IF LS-BLOCK > 0
                 MOVE CB-REPLACEABLE(LS-BLOCK) TO L-RESULT
             END-IF
         WHEN 8
             IF LS-Y >= FL-MIN-Y AND LS-Y <= FL-MIN-Y + FL-HEIGHT - 1
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN 9
             MOVE PR-CHILD(L-PRED) TO LS-CHILD
             PERFORM UNTIL LS-CHILD = 0 OR L-RESULT = 1
                 CALL "FR-PRED-TEST" USING LS-CHILD L-X L-Y L-Z L-RESULT
                 MOVE PR-NEXT(LS-CHILD) TO LS-CHILD
             END-PERFORM
         WHEN 10
             MOVE 1 TO L-RESULT
             MOVE PR-CHILD(L-PRED) TO LS-CHILD
             PERFORM UNTIL LS-CHILD = 0 OR L-RESULT = 0
                 CALL "FR-PRED-TEST" USING LS-CHILD L-X L-Y L-Z L-RESULT
                 MOVE PR-NEXT(LS-CHILD) TO LS-CHILD
             END-PERFORM
         WHEN 7
*>           would_survive of a sapling (BushBlock.canSurvive): the block below is in the tag supports_vegetation (the pool of the predicate)
             COMPUTE LS-Y = LS-Y - 1
             CALL "FL-GET-STATE" USING LS-X LS-Y LS-Z LS-STATE
             CALL "FL-BLOCK-OF" USING LS-STATE LS-BLOCK
             CALL "FR-POOL-HAS" USING PR-POOL(L-PRED) PR-N(L-PRED) LS-BLOCK L-RESULT
*>           sugar cane (24 part 3 7.10.2): sugar cane below, or a block of supports_sugar_cane with water or a block of supports_sugar_cane_adjacently beside it
             IF PR-A(L-PRED) = 2
                 MOVE 0 TO L-RESULT
                 IF LS-BLOCK = PR-E(L-PRED)
                     MOVE 1 TO L-RESULT
                 ELSE
                     CALL "FR-POOL-HAS" USING PR-POOL(L-PRED) PR-N(L-PRED) LS-BLOCK LS-K
                     PERFORM VARYING LS-DX FROM 0 BY 1 UNTIL LS-DX > 3 OR LS-K = 0 OR L-RESULT = 1
                         MOVE LS-X TO LS-V
                         MOVE LS-Z TO LS-R
                         EVALUATE LS-DX
                             WHEN 0
                                 ADD 1 TO LS-V
                             WHEN 1
                                 SUBTRACT 1 FROM LS-V
                             WHEN 2
                                 ADD 1 TO LS-R
                             WHEN OTHER
                                 SUBTRACT 1 FROM LS-R
                         END-EVALUATE
                         CALL "FL-GET-STATE" USING LS-V LS-Y LS-R LS-STATE
                         CALL "FL-CLASS" USING LS-STATE LS-CLASS
                         CALL "FL-BLOCK-OF" USING LS-STATE LS-BLOCK
                         CALL "FR-POOL-HAS" USING PR-C(L-PRED) PR-D(L-PRED) LS-BLOCK LS-DZ
                         IF LS-CLASS = 2 OR LS-DZ = 1
                             MOVE 1 TO L-RESULT
                         END-IF
                     END-PERFORM
                 END-IF
             END-IF
*>           cactus (29b part 4 section 4.1): the block below is a cactus or in supports_cactus, no horizontal neighbour is solid or lava, the cell above holds no liquid
             IF PR-A(L-PRED) = 3
                 IF PR-E(L-PRED) > 0 AND LS-BLOCK = PR-E(L-PRED)
                     MOVE 1 TO L-RESULT
                 END-IF
                 COMPUTE LS-Y = LS-Y + 1
                 PERFORM VARYING LS-DX FROM 0 BY 1 UNTIL LS-DX > 3 OR L-RESULT = 0
                     MOVE LS-X TO LS-V
                     MOVE LS-Z TO LS-R
                     EVALUATE LS-DX
                         WHEN 0
                             ADD 1 TO LS-V
                         WHEN 1
                             SUBTRACT 1 FROM LS-V
                         WHEN 2
                             ADD 1 TO LS-R
                         WHEN OTHER
                             SUBTRACT 1 FROM LS-R
                     END-EVALUATE
                     CALL "FL-GET-STATE" USING LS-V LS-Y LS-R LS-STATE
                     CALL "FL-CLASS" USING LS-STATE LS-CLASS
                     CALL "FL-BLOCK-OF" USING LS-STATE LS-BLOCK
                     IF LS-CLASS = 3
                         MOVE 0 TO L-RESULT
                     END-IF
                     IF LS-BLOCK > 0 AND (LS-CLASS = 0 OR LS-CLASS = 4)
                         IF CB-SOLID(LS-BLOCK) = 1
                             MOVE 0 TO L-RESULT
                         END-IF
                     END-IF
                 END-PERFORM
                 COMPUTE LS-Y = LS-Y + 1
                 CALL "FL-GET-STATE" USING LS-X LS-Y LS-Z LS-STATE
                 CALL "FL-CLASS" USING LS-STATE LS-CLASS
                 IF LS-CLASS = 2 OR LS-CLASS = 3
                     MOVE 0 TO L-RESULT
                 END-IF
             END-IF
         WHEN 11
             CALL "FR-PRED-TEST" USING PR-CHILD(L-PRED) L-X L-Y L-Z LS-R
             COMPUTE L-RESULT = 1 - LS-R
         WHEN 12
         WHEN 13
             MOVE 1 TO L-RESULT
         WHEN 14
             MOVE PR-A(L-PRED) TO LS-K
             MOVE PR-B(L-PRED) TO LS-V
             CALL "F352-ANCHOR" USING LS-K LS-V FL-MIN-Y FL-HEIGHT FL-SEA LS-LO
             MOVE PR-C(L-PRED) TO LS-K
             MOVE PR-D(L-PRED) TO LS-V
             CALL "F352-ANCHOR" USING LS-K LS-V FL-MIN-Y FL-HEIGHT FL-SEA LS-HI
             IF L-Y >= LS-LO AND L-Y <= LS-HI
                 MOVE 1 TO L-RESULT
             END-IF
         WHEN 15
             MOVE 1 TO L-RESULT
             PERFORM VARYING LS-DX FROM PR-A(L-PRED) BY 1 UNTIL LS-DX > PR-D(L-PRED) OR L-RESULT = 0
                 PERFORM VARYING LS-DZ FROM PR-C(L-PRED) BY 1 UNTIL LS-DZ > PR-F(L-PRED) OR L-RESULT = 0
                     PERFORM VARYING LS-DY FROM PR-B(L-PRED) BY 1 UNTIL LS-DY > PR-E(L-PRED) OR L-RESULT = 0
                         COMPUTE LS-X = L-X + LS-DX
                         COMPUTE LS-Y = L-Y + LS-DY
                         COMPUTE LS-Z = L-Z + LS-DZ
                         CALL "FR-PRED-TEST" USING PR-CHILD(L-PRED) LS-X LS-Y LS-Z L-RESULT
                     END-PERFORM
                 END-PERFORM
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM FR-PRED-TEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-PROV-STATE IS RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY CBLOCKS.
 LOCAL-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-RUN                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-PR                  BINARY-LONG.
 01 WS-PV                  BINARY-LONG.
 01 WS-TEST                BINARY-LONG.
 01 WS-P4.
    05 WS-Q                BINARY-LONG OCCURS 4 TIMES.
 01 WS-DIR                 BINARY-LONG.
 01 WS-BOUND6              BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-FACE-NAME           PIC X(40).
 01 WS-AXIS-NAME           PIC X(40).
 01 WS-AXIS-KEY            PIC X(40) VALUE "axis".
 01 WS-FACING-KEY          PIC X(40) VALUE "facing".
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-PV                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE-OUT            BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-PV L-X L-Y L-Z L-STATE-OUT L-OK.
     MOVE 0 TO L-OK L-STATE-OUT
     EVALUATE PV-TYPE(L-PV)
         WHEN 1
             MOVE PV-A(L-PV) TO L-STATE-OUT
             MOVE 1 TO L-OK
         WHEN 2
             MOVE 0 TO WS-TOTAL
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= PV-N(L-PV)
                 ADD FD-POOL(PV-POOL(L-PV) + WS-I * 2 + 1) TO WS-TOTAL
             END-PERFORM
             IF WS-TOTAL > 0
                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-TOTAL WS-DRAW
                 MOVE 0 TO WS-RUN
                 PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= PV-N(L-PV) OR L-OK = 1
                     ADD FD-POOL(PV-POOL(L-PV) + WS-I * 2 + 1) TO WS-RUN
                     IF WS-DRAW < WS-RUN
                         MOVE FD-POOL(PV-POOL(L-PV) + WS-I * 2) TO L-STATE-OUT
                         MOVE 1 TO L-OK
                     END-IF
                 END-PERFORM
             END-IF
         WHEN 3
             IF PV-N(L-PV) > 0
                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE PV-N(L-PV) WS-DRAW
                 MOVE FD-POOL(PV-POOL(L-PV) + WS-DRAW) TO WS-BLOCK
                 MOVE CB-DEFAULT-STATE(WS-BLOCK) TO L-STATE-OUT
                 MOVE 1 TO L-OK
             END-IF
*>       rule_based: the first rule whose predicate holds at the position and whose provider gives a state wins, else the fallback provider (a null state when there is none)
         WHEN 5
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= PV-N(L-PV) OR L-OK = 1
                 MOVE FD-POOL(PV-POOL(L-PV) + WS-I * 2) TO WS-PR
                 MOVE FD-POOL(PV-POOL(L-PV) + WS-I * 2 + 1) TO WS-PV
                 CALL "FR-PRED-TEST" USING WS-PR L-X L-Y L-Z WS-TEST
                 IF WS-TEST = 1
                     CALL "FR-PROV-STATE" USING L-STATE WS-PV L-X L-Y L-Z L-STATE-OUT L-OK
                 END-IF
             END-PERFORM
             IF L-OK = 0 AND PV-A(L-PV) > 0
                 MOVE PV-A(L-PV) TO WS-PV
                 CALL "FR-PROV-STATE" USING L-STATE WS-PV L-X L-Y L-Z L-STATE-OUT L-OK
             END-IF
*>       randomized_int: one sample of the values picks the state resolved when the data was compiled
         WHEN 4
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                 MOVE PV-IP-V(L-PV, WS-I) TO WS-Q(WS-I)
             END-PERFORM
             CALL "FR-INT-SAMPLE" USING L-STATE WS-P4 WS-DRAW
             COMPUTE WS-RUN = WS-DRAW - PV-LO(L-PV)
             IF WS-RUN >= 0 AND WS-RUN < PV-N(L-PV)
                 MOVE FD-POOL(PV-POOL(L-PV) + WS-RUN) TO L-STATE-OUT
                 MOVE 1 TO L-OK
             END-IF
*>       rotated (35-2 section 4.3): the direction (a draw when the data names none) comes first, then the inner provider's state; axis takes the axis of the direction and facing the direction
*>       (a block without the property, or without that value, keeps its state; the properties are found by name: the document's identity rule for the two axis and three facing
*>       properties is not modelled, the data uses rotated only on hay_block and the wall fans)
         WHEN 9
             MOVE PV-N(L-PV) TO WS-DIR
             IF WS-DIR < 0
                 MOVE 6 TO WS-BOUND6
                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND6 WS-DIR
             END-IF
             MOVE PV-A(L-PV) TO WS-PV
             CALL "FR-PROV-STATE" USING L-STATE WS-PV L-X L-Y L-Z L-STATE-OUT L-OK
             IF L-OK = 1
                 EVALUATE WS-DIR
                     WHEN 0
                         MOVE "down" TO WS-FACE-NAME
                         MOVE "y" TO WS-AXIS-NAME
                     WHEN 1
                         MOVE "up" TO WS-FACE-NAME
                         MOVE "y" TO WS-AXIS-NAME
                     WHEN 2
                         MOVE "north" TO WS-FACE-NAME
                         MOVE "z" TO WS-AXIS-NAME
                     WHEN 3
                         MOVE "south" TO WS-FACE-NAME
                         MOVE "z" TO WS-AXIS-NAME
                     WHEN 4
                         MOVE "west" TO WS-FACE-NAME
                         MOVE "x" TO WS-AXIS-NAME
                     WHEN OTHER
                         MOVE "east" TO WS-FACE-NAME
                         MOVE "x" TO WS-AXIS-NAME
                 END-EVALUATE
                 MOVE L-STATE-OUT TO WS-ROT
                 CALL "FD-STATE-SET" USING WS-ROT WS-AXIS-KEY WS-AXIS-NAME L-STATE-OUT WS-FOUND
                 MOVE L-STATE-OUT TO WS-ROT
                 CALL "FD-STATE-SET" USING WS-ROT WS-FACING-KEY WS-FACE-NAME L-STATE-OUT WS-FOUND
             END-IF
*>       the noise providers (feat-prov-noise.cob)
         WHEN 6
         WHEN 7
         WHEN 8
             CALL "FR-PROV-NOISE" USING L-STATE L-PV L-X L-Y L-Z L-STATE-OUT
             MOVE 1 TO L-OK
     END-EVALUATE
     GOBACK.
 END PROGRAM FR-PROV-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-BIOME-HAS.
*> USING biome key (PIC X(40)), placed feature key (PIC X(80)), flag out: 1 when the biome's generation settings list that placed feature (the `biome` modifier, 35-1 7.3).
*> The lists are those of the loaded biomes (WGN domain 14 chains); the answers are memoised until the worldgen store is loaded again.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTWORLDGEN.
 01 WS-MEMO-GEN            BINARY-LONG VALUE -1.
 01 WS-MEMO-COUNT          BINARY-LONG VALUE 0.
 01 WS-MEMO.
    05 WS-M OCCURS 1024 TIMES.
       10 WS-M-BIOME       PIC X(40).
       10 WS-M-KEY         PIC X(80).
       10 WS-M-FLAG        BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-BIOME112            PIC X(112).
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-BIOME                PIC X(40).
 01 L-KEY                  PIC X(80).
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BIOME L-KEY L-FLAG.
     IF WS-MEMO-GEN NOT = WG-LOAD-GEN
         MOVE WG-LOAD-GEN TO WS-MEMO-GEN
         MOVE 0 TO WS-MEMO-COUNT
     END-IF
     MOVE 0 TO L-FLAG WS-DONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-MEMO-COUNT OR WS-DONE = 1
         IF WS-M-BIOME(WS-I) = L-BIOME AND WS-M-KEY(WS-I) = L-KEY
             MOVE WS-M-FLAG(WS-I) TO L-FLAG
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     IF WS-DONE = 1
         GOBACK
     END-IF
     MOVE L-BIOME TO WS-BIOME112
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WG-COUNT(4) OR WS-ROW > 0
         IF WGF-KIND(WS-I) = 7 AND WGF-KEY(WS-I) = WS-BIOME112
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM
     IF WS-ROW > 0
         MOVE WGN-CHILD(WGF-ROOT(WS-ROW), 1) TO WS-NODE
         PERFORM UNTIL WS-NODE = 0 OR L-FLAG = 1
             IF WGN-TEXT-1(WS-NODE)(1:80) = L-KEY
                 MOVE 1 TO L-FLAG
             END-IF
             MOVE WGN-NEXT(WS-NODE) TO WS-NODE
         END-PERFORM
     END-IF
     IF WS-MEMO-COUNT < 1024
         ADD 1 TO WS-MEMO-COUNT
         MOVE L-BIOME TO WS-M-BIOME(WS-MEMO-COUNT)
         MOVE L-KEY TO WS-M-KEY(WS-MEMO-COUNT)
         MOVE L-FLAG TO WS-M-FLAG(WS-MEMO-COUNT)
     END-IF
     GOBACK.
 END PROGRAM FR-BIOME-HAS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-FLOOR-OF-LAYER.
*> USING x, start y, z, target layer, y out (min y - 1 for none): floorOfLayer of count_on_every_layer (35-1 7.11) over the level.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATLEVEL.
 01 WS-YY                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-C-ABOVE             BINARY-LONG.
 01 WS-C-BELOW             BINARY-LONG.
 01 WS-YB                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-START                BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-START L-Z L-TARGET L-Y.
     COMPUTE L-Y = FL-MIN-Y - 1
     MOVE 0 TO WS-N
     CALL "FL-GET-STATE" USING L-X L-START L-Z WS-ABOVE
     PERFORM VARYING WS-YY FROM L-START BY -1 UNTIL WS-YY <= FL-MIN-Y OR L-Y >= FL-MIN-Y
         COMPUTE WS-YB = WS-YY - 1
         CALL "FL-GET-STATE" USING L-X WS-YB L-Z WS-BELOW
         CALL "FL-CLASS" USING WS-ABOVE WS-C-ABOVE
         CALL "FL-CLASS" USING WS-BELOW WS-C-BELOW
         IF WS-C-BELOW = 0 AND WS-C-ABOVE >= 1 AND WS-C-ABOVE <= 3
             IF WS-N = L-TARGET
                 MOVE WS-YY TO L-Y
             ELSE
                 ADD 1 TO WS-N
             END-IF
         END-IF
         MOVE WS-BELOW TO WS-ABOVE
     END-PERFORM
     GOBACK.
 END PROGRAM FR-FLOOR-OF-LAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-MODIFY IS RECURSIVE.
*> USING state, modifier index, top placed feature (0 none), x, y, z, count out, positions out (4096 x 3 BINARY-LONG): one placement modifier of the compiled
*> data (35-1 section 7) over the level; the kinds are those of FEATDATA.cpy (0 block_predicate_filter ... 15 offset); the noise counts (7, 8) are the biome info noise of feat-noise.cob; randomly_selected
*> (16) and fixed_placement (17, up to four positions) are compiled.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 01 WS-ONCE                BINARY-LONG.
 01 WS-REPEAT              BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-NX                  FLOAT-LONG.
 01 WS-NZ                  FLOAT-LONG.
 01 WS-NOISE               FLOAT-LONG.
 01 WS-RATIO               FLOAT-LONG.
 01 WS-SCALE               FLOAT-LONG VALUE 200.
 01 WS-P4.
    05 WS-Q                BINARY-LONG OCCURS 4 TIMES.
 01 WS-P6.
    05 WS-R6               BINARY-LONG OCCURS 6 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-H2                  BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-BOUND               BINARY-LONG VALUE 16.
 01 WS-F                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-NF                  FLOAT-LONG.
 01 WS-BIOME               PIC X(40).
 01 WS-LAYER               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 4096.
 01 WS-STATE               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-EDGES               BINARY-LONG.
 01 WS-EXT                 BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-STEPS               BINARY-LONG.
 01 WS-STAGE               BINARY-LONG.
 LOCAL-STORAGE SECTION.
 01 LS-DRAW                BINARY-LONG.
 01 LS-CHILD               BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-MD                   BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-OUT.
    05 L-O OCCURS 4096 TIMES.
       10 L-OX             BINARY-LONG.
       10 L-OY             BINARY-LONG.
       10 L-OZ             BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-MD L-TOP L-X L-Y L-Z L-COUNT L-OUT.
     MOVE 0 TO L-COUNT WS-ONCE WS-REPEAT
     EVALUATE MD-KIND(L-MD)
         WHEN 0
             CALL "FR-PRED-TEST" USING MD-PR(L-MD) L-X L-Y L-Z WS-ONCE
         WHEN 1
             MOVE MD-A(L-MD) TO WS-NF
             CALL STATIC "cc_f64_div" USING BY REFERENCE WS-ONE WS-NF WS-T
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-U
             CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
             IF WS-F < WS-U
                 MOVE 1 TO WS-ONCE
             END-IF
         WHEN 2
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE MD-F(L-MD) WS-U
             CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
             IF WS-F < WS-U
                 MOVE 1 TO WS-ONCE
             END-IF
         WHEN 3
             CALL "FL-HEIGHT-OF" USING MD-A(L-MD) L-X L-Z WS-H
             CALL "F351-SURFACE-REL" USING WS-H MD-B(L-MD) MD-C(L-MD) L-Y WS-ONCE
         WHEN 4
             MOVE 3 TO WS-STAGE
             CALL "FL-HEIGHT-OF" USING WS-STAGE L-X L-Z WS-H
             MOVE 1 TO WS-STAGE
             CALL "FL-HEIGHT-OF" USING WS-STAGE L-X L-Z WS-H2
             CALL "F351-WATER-DEPTH" USING WS-H WS-H2 MD-A(L-MD) WS-ONCE
         WHEN 5
             IF L-TOP > 0
                 CALL "FL-BIOME-AT" USING L-X L-Y L-Z WS-BIOME
                 CALL "FR-BIOME-HAS" USING WS-BIOME PF-KEY(L-TOP) WS-ONCE
             END-IF
         WHEN 6
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                 MOVE MD-P(L-MD, WS-I) TO WS-Q(WS-I)
             END-PERFORM
             CALL "FR-INT-SAMPLE" USING L-STATE WS-P4 WS-N
             MOVE 1 TO WS-REPEAT
*>       noise_based_count (35-1 7.9): ceil((noise + offset) * ratio) repeats, the noise at (x / factor, z / factor); no draw
         WHEN 7
             MOVE L-X TO WS-FX
             MOVE L-Z TO WS-FZ
             CALL STATIC "cc_f64_div" USING BY REFERENCE WS-FX MD-F(L-MD) WS-NX
             CALL STATIC "cc_f64_div" USING BY REFERENCE WS-FZ MD-F(L-MD) WS-NZ
             CALL "F351-SIMPLEX" USING WS-NX WS-NZ WS-NOISE
             CALL STATIC "cc_f64_add" USING BY REFERENCE WS-NOISE MD-F2(L-MD) WS-T
             MOVE MD-A(L-MD) TO WS-RATIO
             CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-T WS-RATIO WS-U
             CALL STATIC "cc_f64_ceil" USING BY REFERENCE WS-U WS-T
             CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-T WS-N
             MOVE 1 TO WS-REPEAT
*>       noise_threshold_count (35-1 7.10): below_noise when the noise at (x / 200, z / 200) is below noise_level, else above_noise; no draw
         WHEN 8
             MOVE L-X TO WS-FX
             MOVE L-Z TO WS-FZ
             CALL STATIC "cc_f64_div" USING BY REFERENCE WS-FX WS-SCALE WS-NX
             CALL STATIC "cc_f64_div" USING BY REFERENCE WS-FZ WS-SCALE WS-NZ
             CALL "F351-SIMPLEX" USING WS-NX WS-NZ WS-NOISE
             MOVE MD-B(L-MD) TO WS-N
             IF WS-NOISE < MD-F(L-MD)
                 MOVE MD-A(L-MD) TO WS-N
             END-IF
             MOVE 1 TO WS-REPEAT
         WHEN 9
             MOVE 0 TO WS-LAYER WS-STOP
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                 MOVE MD-P(L-MD, WS-I) TO WS-Q(WS-I)
             END-PERFORM
             PERFORM UNTIL WS-STOP = 1
                 MOVE 0 TO WS-FOUND WS-I
                 CALL "FR-INT-SAMPLE" USING L-STATE WS-P4 WS-N
                 PERFORM UNTIL WS-I >= WS-N
                     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DX
                     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DZ
                     COMPUTE WS-X = L-X + WS-DX
                     COMPUTE WS-Z = L-Z + WS-DZ
                     MOVE 4 TO WS-STAGE
                     CALL "FL-HEIGHT-OF" USING WS-STAGE WS-X WS-Z WS-H
                     CALL "FR-FLOOR-OF-LAYER" USING WS-X WS-H WS-Z WS-LAYER WS-Y
                     IF WS-Y >= FL-MIN-Y AND L-COUNT < WS-CAP
                         ADD 1 TO L-COUNT
                         MOVE WS-X TO L-OX(L-COUNT)
                         MOVE WS-Y TO L-OY(L-COUNT)
                         MOVE WS-Z TO L-OZ(L-COUNT)
                         MOVE 1 TO WS-FOUND
                     END-IF
                     ADD 1 TO WS-I
                     CALL "FR-INT-SAMPLE" USING L-STATE WS-P4 WS-N
                 END-PERFORM
                 ADD 1 TO WS-LAYER
                 IF WS-FOUND = 0
                     MOVE 1 TO WS-STOP
                 END-IF
             END-PERFORM
         WHEN 10
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                 MOVE MD-P(L-MD, WS-I + 4) TO WS-Q(WS-I)
             END-PERFORM
             CALL "FR-INT-SAMPLE" USING L-STATE WS-P4 WS-DY
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                 MOVE MD-P(L-MD, WS-I) TO WS-Q(WS-I)
             END-PERFORM
             CALL "FR-INT-SAMPLE" USING L-STATE WS-P4 WS-DX
             CALL "FR-INT-SAMPLE" USING L-STATE WS-P4 WS-DZ
             PERFORM VARYING WS-SX FROM 0 BY 1 UNTIL WS-SX > WS-DX
                 PERFORM VARYING WS-SY FROM 0 BY 1 UNTIL WS-SY > WS-DY
                     PERFORM VARYING WS-SZ FROM 0 BY 1 UNTIL WS-SZ > WS-DZ
                         MOVE 0 TO WS-EXT
                         IF WS-SX = 0 OR WS-SX = WS-DX
                             ADD 1 TO WS-EXT
                         END-IF
                         IF WS-SY = 0 OR WS-SY = WS-DY
                             ADD 1 TO WS-EXT
                         END-IF
                         IF WS-SZ = 0 OR WS-SZ = WS-DZ
                             ADD 1 TO WS-EXT
                         END-IF
                         MOVE 1 TO WS-PASS
                         IF MD-C(L-MD) = 0 AND WS-EXT >= 2
                             MOVE 0 TO WS-PASS
                         END-IF
                         IF MD-D(L-MD) = 0 AND WS-EXT = 0
                             MOVE 0 TO WS-PASS
                         END-IF
                         IF WS-PASS = 1 AND L-COUNT < WS-CAP
                             ADD 1 TO L-COUNT
                             COMPUTE L-OX(L-COUNT) = L-X + WS-SX
                             COMPUTE L-OY(L-COUNT) = L-Y + WS-SY
                             COMPUTE L-OZ(L-COUNT) = L-Z + WS-SZ
                         END-IF
                     END-PERFORM
                 END-PERFORM
             END-PERFORM
         WHEN 11
             MOVE L-X TO WS-X
             MOVE L-Y TO WS-Y
             MOVE L-Z TO WS-Z
             MOVE 0 TO WS-STOP WS-I
             MOVE 1 TO WS-PASS
             IF MD-PR2(L-MD) > 0
                 CALL "FR-PRED-TEST" USING MD-PR2(L-MD) WS-X WS-Y WS-Z WS-PASS
             END-IF
             IF WS-PASS = 0
                 MOVE 1 TO WS-STOP
             END-IF
             PERFORM UNTIL WS-STOP > 0 OR WS-I >= MD-B(L-MD)
                 CALL "FR-PRED-TEST" USING MD-PR(L-MD) WS-X WS-Y WS-Z WS-R
                 IF WS-R = 1
                     MOVE 1 TO WS-ONCE
                     MOVE 1 TO WS-STOP
                 ELSE
                     ADD MD-A(L-MD) TO WS-Y
                     IF WS-Y < FL-MIN-Y OR WS-Y > FL-MIN-Y + FL-HEIGHT - 1
                         MOVE 1 TO WS-STOP
                     ELSE
                         MOVE 1 TO WS-PASS
                         IF MD-PR2(L-MD) > 0
                             CALL "FR-PRED-TEST" USING MD-PR2(L-MD) WS-X WS-Y WS-Z WS-PASS
                         END-IF
                         IF WS-PASS = 1
                             ADD 1 TO WS-I
                         ELSE
                             MOVE 2 TO WS-STOP
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
             IF WS-STOP NOT = 1
                 CALL "FR-PRED-TEST" USING MD-PR(L-MD) WS-X WS-Y WS-Z WS-R
                 IF WS-R = 1
                     MOVE 1 TO WS-ONCE
                 END-IF
             END-IF
             IF WS-ONCE = 1
                 ADD 1 TO L-COUNT
                 MOVE WS-X TO L-OX(1)
                 MOVE WS-Y TO L-OY(1)
                 MOVE WS-Z TO L-OZ(1)
                 MOVE 0 TO WS-ONCE
             END-IF
         WHEN 12
             CALL "FL-HEIGHT-OF" USING MD-A(L-MD) L-X L-Z WS-H
             IF WS-H > FL-MIN-Y
                 ADD 1 TO L-COUNT
                 MOVE L-X TO L-OX(1)
                 MOVE WS-H TO L-OY(1)
                 MOVE L-Z TO L-OZ(1)
             END-IF
         WHEN 13
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
                 MOVE MD-P(L-MD, WS-I) TO WS-R6(WS-I)
             END-PERFORM
             CALL "FR-HP-SAMPLE" USING L-STATE WS-P6 FL-MIN-Y FL-HEIGHT FL-SEA WS-Y
             ADD 1 TO L-COUNT
             MOVE L-X TO L-OX(1)
             MOVE WS-Y TO L-OY(1)
             MOVE L-Z TO L-OZ(1)
         WHEN 16
*>           randomly_selected (35-1 section 7.17): one nextInt(n) picks the alternative, which runs on the same input and emits into the same list
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE MD-B(L-MD) LS-DRAW
             MOVE MD-P(L-MD, LS-DRAW + 1) TO LS-CHILD
             CALL "FR-MODIFY" USING L-STATE LS-CHILD L-TOP L-X L-Y L-Z L-COUNT L-OUT
*>           the alternative has emitted its own positions: the flags it left in the shared storage must not emit them again
             MOVE 0 TO WS-ONCE WS-REPEAT
         WHEN 14
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DX
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DZ
             ADD 1 TO L-COUNT
             COMPUTE L-OX(1) = L-X + WS-DX
             MOVE L-Y TO L-OY(1)
             COMPUTE L-OZ(1) = L-Z + WS-DZ
         WHEN 17
*>           fixed_placement (35-1 7.18): the listed positions in the chunk of the input, in list order (no draw)
             COMPUTE WS-DX = FUNCTION INTEGER(L-X / 16)
             COMPUTE WS-DZ = FUNCTION INTEGER(L-Z / 16)
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MD-B(L-MD)
                 COMPUTE WS-A = FUNCTION INTEGER(MD-P(L-MD, WS-I * 3 - 2) / 16)
                 COMPUTE WS-EXT = FUNCTION INTEGER(MD-P(L-MD, WS-I * 3) / 16)
                 IF WS-A = WS-DX AND WS-EXT = WS-DZ
                     ADD 1 TO L-COUNT
                     MOVE MD-P(L-MD, WS-I * 3 - 2) TO L-OX(L-COUNT)
                     MOVE MD-P(L-MD, WS-I * 3 - 1) TO L-OY(L-COUNT)
                     MOVE MD-P(L-MD, WS-I * 3) TO L-OZ(L-COUNT)
                 END-IF
             END-PERFORM
         WHEN 15
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                 MOVE MD-P(L-MD, WS-I) TO WS-Q(WS-I)
             END-PERFORM
             CALL "FR-INT-SAMPLE" USING L-STATE WS-P4 WS-DX
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                 MOVE MD-P(L-MD, WS-I + 4) TO WS-Q(WS-I)
             END-PERFORM
             CALL "FR-INT-SAMPLE" USING L-STATE WS-P4 WS-DY
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
                 MOVE MD-P(L-MD, WS-I + 8) TO WS-Q(WS-I)
             END-PERFORM
             CALL "FR-INT-SAMPLE" USING L-STATE WS-P4 WS-DZ
             ADD 1 TO L-COUNT
             COMPUTE L-OX(1) = L-X + WS-DX
             COMPUTE L-OY(1) = L-Y + WS-DY
             COMPUTE L-OZ(1) = L-Z + WS-DZ
     END-EVALUATE
*>   the repeating counts: N positions, at most WS-CAP
     IF WS-REPEAT = 1
         IF WS-N > WS-CAP
             MOVE WS-CAP TO WS-N
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
             ADD 1 TO L-COUNT
             MOVE L-X TO L-OX(L-COUNT)
             MOVE L-Y TO L-OY(L-COUNT)
             MOVE L-Z TO L-OZ(L-COUNT)
         END-PERFORM
     END-IF
     IF WS-ONCE = 1
         ADD 1 TO L-COUNT
         MOVE L-X TO L-OX(L-COUNT)
         MOVE L-Y TO L-OY(L-COUNT)
         MOVE L-Z TO L-OZ(L-COUNT)
     END-IF
     GOBACK.
 END PROGRAM FR-MODIFY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-PLACE-PF IS RECURSIVE.
*> The evaluator of 35-1 section 8.2 over the compiled modifiers (see feat-35-1.cob F351-PLACE): a stack of (position, modifier) pairs, the pair last pushed first, the
*> positions of a modifier pushed last to first, the feature placed at every position the last modifier emits; the result is the OR. A placed feature that is not
*> supported (PF-STATUS 2) places nothing and draws nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 LOCAL-STORAGE SECTION.
 01 LS-STACK.
    05 LS-S OCCURS 4096 TIMES.
       10 LS-SX            BINARY-LONG.
       10 LS-SY            BINARY-LONG.
       10 LS-SZ            BINARY-LONG.
       10 LS-SM            BINARY-LONG.
 01 LS-OUT.
    05 LS-O OCCURS 4096 TIMES.
       10 LS-OX            BINARY-LONG.
       10 LS-OY            BINARY-LONG.
       10 LS-OZ            BINARY-LONG.
 01 LS-SP                  BINARY-LONG.
 01 LS-M                   BINARY-LONG.
 01 LS-X                   BINARY-LONG.
 01 LS-Y                   BINARY-LONG.
 01 LS-Z                   BINARY-LONG.
 01 LS-COUNT               BINARY-LONG.
 01 LS-I                   BINARY-LONG.
 01 LS-MD                  BINARY-LONG.
 01 LS-LAST                BINARY-LONG.
 01 LS-END                 BINARY-LONG.
 01 LS-R                   BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-PF                   BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-PF L-TOP L-X L-Y L-Z L-RESULT.
     MOVE 0 TO L-RESULT
     CALL "FD-ENSURE-PF" USING L-PF
     IF PF-STATUS(L-PF) NOT = 1
         GOBACK
     END-IF
     CALL "FD-ENSURE-FT" USING PF-FT(L-PF)
     IF PF-MD-COUNT(L-PF) = 0
         CALL "FR-PLACE-FT" USING L-STATE PF-FT(L-PF) L-X L-Y L-Z L-RESULT
         GOBACK
     END-IF
     COMPUTE LS-LAST = PF-MD-FIRST(L-PF) + PF-MD-COUNT(L-PF) - 1
     MOVE 1 TO LS-SP
     MOVE L-X TO LS-SX(1)
     MOVE L-Y TO LS-SY(1)
     MOVE L-Z TO LS-SZ(1)
     MOVE PF-MD-FIRST(L-PF) TO LS-SM(1)
     PERFORM UNTIL LS-SP = 0
         MOVE LS-SX(LS-SP) TO LS-X
         MOVE LS-SY(LS-SP) TO LS-Y
         MOVE LS-SZ(LS-SP) TO LS-Z
         MOVE LS-SM(LS-SP) TO LS-M
         SUBTRACT 1 FROM LS-SP
         CALL "FR-MODIFY" USING L-STATE LS-M L-TOP LS-X LS-Y LS-Z LS-COUNT LS-OUT
*>       the modifier's own row, or the last row of its alternatives (randomly_selected keeps them behind it)
         MOVE LS-M TO LS-END
         IF MD-KIND(LS-M) = 16
             MOVE MD-A(LS-M) TO LS-END
         END-IF
         IF LS-END < LS-LAST
             COMPUTE LS-MD = LS-END + 1
             PERFORM VARYING LS-I FROM LS-COUNT BY -1 UNTIL LS-I < 1
                 IF LS-SP < 4096
                     ADD 1 TO LS-SP
                     MOVE LS-OX(LS-I) TO LS-SX(LS-SP)
                     MOVE LS-OY(LS-I) TO LS-SY(LS-SP)
                     MOVE LS-OZ(LS-I) TO LS-SZ(LS-SP)
                     MOVE LS-MD TO LS-SM(LS-SP)
                 END-IF
             END-PERFORM
         ELSE
             PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > LS-COUNT
                 CALL "FR-PLACE-FT" USING L-STATE PF-FT(L-PF) LS-OX(LS-I) LS-OY(LS-I) LS-OZ(LS-I) LS-R
                 IF LS-R = 1
                     MOVE 1 TO L-RESULT
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FR-PLACE-PF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TREE-FALLBACK.
*> USING chosen placed feature (in and out), default placed feature of the selector: a random_selector whose default is a tree and whose chosen child cannot be placed (a
*> placed feature or a feature the compiler does not know: the fancy and the fallen trees) places its default tree instead; every other choice stays as it is.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-USABLE              BINARY-LONG.
 LINKAGE SECTION.
 01 L-CHOSEN               BINARY-LONG.
 01 L-DEFAULT              BINARY-LONG.
 PROCEDURE DIVISION USING L-CHOSEN L-DEFAULT.
     IF L-DEFAULT > 0
         CALL "FD-ENSURE-PF" USING L-CHOSEN
         MOVE 0 TO WS-USABLE
         IF PF-STATUS(L-CHOSEN) = 1
             CALL "FD-ENSURE-FT" USING PF-FT(L-CHOSEN)
             IF FT-TYPE(PF-FT(L-CHOSEN)) NOT = -1
                 MOVE 1 TO WS-USABLE
             END-IF
         END-IF
         IF WS-USABLE = 0
             CALL "FD-ENSURE-PF" USING L-DEFAULT
             IF PF-STATUS(L-DEFAULT) = 1
                 CALL "FD-ENSURE-FT" USING PF-FT(L-DEFAULT)
                 IF FT-TYPE(PF-FT(L-DEFAULT)) = 51
                     MOVE L-DEFAULT TO L-CHOSEN
                 END-IF
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FR-TREE-FALLBACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-PLACE-FT IS RECURSIVE.
*> USING state, feature index, x, y, z, result out (1 or 0): the leaf and combinator features of 35-1 section 9 and simple_block (35-4 section 4, FR-SIMPLE-BLOCK). A feature type that is not compiled places nothing and returns false.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 LOCAL-STORAGE SECTION.
 01 LS-I                   BINARY-LONG.
 01 LS-CHOSEN              BINARY-LONG.
 01 LS-R                   BINARY-LONG.
 01 LS-F                   FLOAT-LONG.
 01 LS-U                   FLOAT-LONG.
 01 LS-STATE               BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-TOTAL               BINARY-LONG.
 01 LS-DRAW                BINARY-LONG.
 01 LS-RUN                 BINARY-LONG.
 01 LS-ZERO                BINARY-LONG VALUE 0.
 01 LS-CH                  BINARY-LONG.
 01 LS-PFX                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-RESULT.
     MOVE 0 TO L-RESULT
     CALL "FD-ENSURE-FT" USING L-FT
     EVALUATE FT-TYPE(L-FT)
         WHEN 2
             CALL "FR-BLOCK-COLUMN" USING L-STATE FT-A(L-FT) L-X L-Y L-Z L-RESULT
         WHEN 54
             CALL "FR-VINES" USING L-X L-Y L-Z L-RESULT
         WHEN 30
             MOVE 1 TO L-RESULT
         WHEN 36
             MOVE 0 TO LS-CHOSEN
             PERFORM VARYING LS-I FROM 0 BY 1 UNTIL LS-I >= FT-B(L-FT) OR LS-CHOSEN > 0
                 COMPUTE LS-CH = FT-A(L-FT) + LS-I
                 CALL "WGR-NEXT-FLOAT" USING L-STATE LS-F
                 CALL STATIC "cc_f64_f32_round" USING BY REFERENCE CH-F(LS-CH) LS-U
                 IF LS-F < LS-U
                     MOVE LS-CH TO LS-CHOSEN
                 END-IF
             END-PERFORM
             IF LS-CHOSEN > 0
                 MOVE CH-PF(LS-CHOSEN) TO LS-PFX
                 CALL "FR-TREE-FALLBACK" USING LS-PFX FT-C(L-FT)
                 CALL "FR-PLACE-PF" USING L-STATE LS-PFX LS-ZERO L-X L-Y L-Z L-RESULT
             ELSE
                 CALL "FR-PLACE-PF" USING L-STATE FT-C(L-FT) LS-ZERO L-X L-Y L-Z L-RESULT
             END-IF
         WHEN 43
             IF FT-B(L-FT) > 0
                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE FT-B(L-FT) LS-DRAW
                 COMPUTE LS-CH = FT-A(L-FT) + LS-DRAW
                 CALL "FR-PLACE-PF" USING L-STATE CH-PF(LS-CH) LS-ZERO L-X L-Y L-Z L-RESULT
             END-IF
         WHEN 34
             CALL "F351-NEXT-BOOLEAN" USING L-STATE LS-DRAW
             IF LS-DRAW = 1
                 MOVE FT-A(L-FT) TO LS-CH
             ELSE
                 COMPUTE LS-CH = FT-A(L-FT) + 1
             END-IF
             CALL "FR-PLACE-PF" USING L-STATE CH-PF(LS-CH) LS-ZERO L-X L-Y L-Z L-RESULT
         WHEN 51
             CALL "FR-TREE" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 16
             CALL "FR-FALLEN" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 1
             CALL "FR-BLOB" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 22
             CALL "FR-FUNGUS" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 21
         WHEN 23
             CALL "FR-MUSH" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 20
             CALL "FR-GEODE" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 26
             CALL "FR-DRIP" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 5
             CALL "FR-BONUS" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 15
         WHEN 6
         WHEN 12
         WHEN 13
         WHEN 11
         WHEN 14
         WHEN 55
             CALL "FR-END" USING L-STATE FT-TYPE(L-FT) L-X L-Y L-Z L-RESULT L-FT
         WHEN 38
             CALL "FR-ROOTSYS" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 18
             CALL "FR-FOSSIL" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 50
             CALL "FR-TEMPLATE" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 8
             CALL "FR-CORAL-TREE" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 7
             CALL "FR-CORAL-CLAW" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 24
             CALL "FR-ICEBERG" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 47
             CALL "FR-SPIKE" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 17
             CALL "FR-FILL" USING L-FT L-X L-Y L-Z L-RESULT
         WHEN 3
             CALL "FR-PILE" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 52
             CALL "FR-MAGMA" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 9
             CALL "FR-DELTA" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 49
             CALL "FR-STEP" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 44
             CALL "FR-PILLAR" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 35
             CALL "FR-NSPREAD" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 33
             CALL "FR-PATCHY" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 29
             CALL "FR-RBLOB" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 4
             CALL "FR-ICE" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 10
             CALL "FR-DISK" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 19
             CALL "FR-FREEZE" USING L-FT L-X L-Z L-RESULT
         WHEN 25
             CALL "FR-LAKE" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 48
             CALL "FR-SPRING" USING L-FT L-X L-Y L-Z L-RESULT
         WHEN 27
             CALL "FR-ROOM" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 53
         WHEN 56
             CALL "FR-VPATCH" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 40
             CALL "FR-SCULK" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 28
             CALL "FR-MULTI" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 46
             CALL "FR-CLUSTER" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 45
             CALL "FR-SPEL" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 1000
             CALL "FR-BAMBOO" USING L-STATE L-FT L-X L-Y L-Z L-RESULT
         WHEN 57
             MOVE 0 TO LS-TOTAL
             PERFORM VARYING LS-I FROM 0 BY 1 UNTIL LS-I >= FT-B(L-FT)
                 COMPUTE LS-CH = FT-A(L-FT) + LS-I
                 ADD CH-W(LS-CH) TO LS-TOTAL
             END-PERFORM
             IF LS-TOTAL > 0
                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE LS-TOTAL LS-DRAW
                 MOVE 0 TO LS-RUN LS-CHOSEN
                 PERFORM VARYING LS-I FROM 0 BY 1 UNTIL LS-I >= FT-B(L-FT) OR LS-CHOSEN > 0
                     COMPUTE LS-CH = FT-A(L-FT) + LS-I
                     ADD CH-W(LS-CH) TO LS-RUN
                     IF LS-DRAW < LS-RUN
                         MOVE LS-CH TO LS-CHOSEN
                     END-IF
                 END-PERFORM
                 CALL "FR-PLACE-PF" USING L-STATE CH-PF(LS-CHOSEN) LS-ZERO L-X L-Y L-Z L-RESULT
             END-IF
         WHEN 41
             MOVE 1 TO L-RESULT
             PERFORM VARYING LS-I FROM 0 BY 1 UNTIL LS-I >= FT-B(L-FT) OR L-RESULT = 0
                 COMPUTE LS-CH = FT-A(L-FT) + LS-I
                 CALL "FR-PLACE-PF" USING L-STATE CH-PF(LS-CH) LS-ZERO L-X L-Y L-Z L-RESULT
             END-PERFORM
         WHEN 32
*>           overlay (35-5 section 1.3): every member from the same position, the result the OR of theirs (a failing member does not stop the others)
             PERFORM VARYING LS-I FROM 0 BY 1 UNTIL LS-I >= FT-B(L-FT)
                 COMPUTE LS-CH = FT-A(L-FT) + LS-I
                 CALL "FR-PLACE-PF" USING L-STATE CH-PF(LS-CH) LS-ZERO L-X L-Y L-Z LS-OK
                 IF LS-OK = 1
                     MOVE 1 TO L-RESULT
                 END-IF
             END-PERFORM
         WHEN 42
             CALL "FR-PROV-STATE" USING L-STATE FT-A(L-FT) L-X L-Y L-Z LS-STATE LS-OK
             IF LS-OK = 1
                 CALL "FR-SIMPLE-BLOCK" USING LS-STATE L-X L-Y L-Z L-RESULT
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM FR-PLACE-FT.
