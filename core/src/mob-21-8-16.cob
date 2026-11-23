*> The cushion's placement, survival and breaking (docs/protocol/21 section 8.16.1, 44-9 section 8.1; task T39200, T2648/T2649).
*> Every box here is 6 BINARY-DOUBLE (x1 y1 z1 x2 y2 z2) in U = 1/16,000,000 block, so a comparison is an exact integer one (a FLOAT-LONG compare is fuzzy). The shape tables (BSH-*) are in
*> 1/16,000 block, so 1000 U per table unit. The document's one-ulp deflation ("nextUp / nextDown") is one U here: the shapes are multiples of 1000 U, so no result differs.
*>   CUSHION-U USING coordinate (FLOAT-LONG), u out (BINARY-DOUBLE)                  the coordinate rounded to U
*>   CUSHION-CELL USING u, cell out                                                   the block cell that holds the coordinate (floor)
*>   CUSHION-SUFFOCATING USING dim, cell x, y, z, result out                          isSuffocating: the state is in the tag causes_suffocation and its collision shape is the full cube
*>   CUSHION-ANCHOR USING dim, box, result out                                        hasAnchorBelow (outline bounding box of a block under the base)
*>   CUSHION-COVERED USING dim, box, result out                                       isCoveredBySuffocatingBlocks (every block of the deflated box suffocates)
*>   CUSHION-BURIED USING dim, box, result out                                        isAnchorBuried (the bottom 1/64 is entirely inside collision shapes)
*>   CUSHION-FIRE USING dim, box, result out                                          some block of the deflated box is in the tag fire
*>   CUSHION-SURVIVES USING dim, box, ok out                                          wouldSurviveAt = anchor and not covered
*>   CUSHION-CAN-PLACE USING dim, box, ok out                                         canBePlacedAt = survives and not buried
*>   CUSHION-BOX-OF USING row, box out                                                the entity's box (1.0 x 0.25 on its position)
*>   CUSHION-KIND USING item, colour out                                              the dye of a cushion item (white_cushion + dye), -1 for any other item
*>   CUSHION-BREAK USING row, killer player row (0 none)                              the item of its colour drops (not with the entity_drops rule off or a creative breaker), the entity goes
*>   CUSHION-SEAT USING row                                                           its rider put at the passenger point: the cushion's x and z, y + 0.25 less the player's vehicle attachment 0.6
*>   CUSHION-THUNDER USING bolt row                                                   thunderHit: every cushion whose box meets the bolt's box (+-3 around it, -3 to +9) is killed and drops its item
*>   CUSHION-STEP USING row                                                           every 100th call: destroyIfInFire, then the survival check
*>   CUSHION-HURT USING row, player row, done out                                     a hit by a player (DECOR-ATTACK's hook)
*>   CUSHION-ITEM-USE USING player row, PLAY-SERVERBOUND (Use Item On), item, placed out   CushionItem.useOn
*> Not modelled: the fluid entityInside of the check, the place, sit and get-up sounds (FR-043), mayInteract of the spawn protection, the 20 ticks of invulnerability of a lightning drop (a bolt hits no item entity here).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CUSHION-U.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-U                    BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-X L-U.
     COMPUTE L-U ROUNDED = L-X * 16000000
     GOBACK.
 END PROGRAM CUSHION-U.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CUSHION-CELL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-U                    BINARY-DOUBLE.
 01 L-CELL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-U L-CELL.
     COMPUTE L-CELL = FUNCTION INTEGER(L-U / 16000000)
     GOBACK.
 END PROGRAM CUSHION-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CUSHION-SUFFOCATING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:causes_suffocation".
 01 WS-TAGGED              BINARY-LONG.
 01 WS-SHAPE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-RESULT.
     MOVE 0 TO L-RESULT
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     IF WS-STATE = 0
         GOBACK
     END-IF
     CALL "CONTENT-BLOCK-OF-STATE" USING WS-STATE WS-BLOCK WS-INDEX WS-ROW WS-STATUS
     CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-BLOCK WS-TAGGED
     CALL "BSH-COLL-ID" USING WS-STATE WS-SHAPE
     IF WS-TAGGED = 1 AND WS-SHAPE = 1
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM CUSHION-SUFFOCATING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CUSHION-ANCHOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 01 WS-A.
    05 WS-AV               BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-LOW                 BINARY-DOUBLE OCCURS 3 TIMES.
 01 WS-HIGH                BINARY-DOUBLE OCCURS 3 TIMES.
 01 WS-SCAN                BINARY-DOUBLE.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CK                  BINARY-LONG OCCURS 3 TIMES.
 01 WS-C1                  BINARY-LONG OCCURS 3 TIMES.
 01 WS-C2                  BINARY-LONG OCCURS 3 TIMES.
 01 WS-STATE               BINARY-LONG.
 01 WS-SHAPE               BINARY-LONG.
 01 WS-BI                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-V1                  BINARY-DOUBLE.
 01 WS-V2                  BINARY-DOUBLE.
 01 WS-CU                  BINARY-DOUBLE.
 01 WS-OVER                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-BOX.
    05 L-B                 BINARY-DOUBLE OCCURS 6 TIMES.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-BOX L-RESULT.
     MOVE 0 TO L-RESULT
*>   The probe slab A: 1/64 under the base, the footprint less one U on the high sides; the scan runs 0.125 further down.
     MOVE L-B(1) TO WS-AV(1)
     COMPUTE WS-AV(2) = L-B(2) - 250000
     MOVE L-B(3) TO WS-AV(3)
     COMPUTE WS-AV(4) = L-B(4) - 1
     MOVE L-B(2) TO WS-AV(5)
     COMPUTE WS-AV(6) = L-B(6) - 1
     CALL "CUSHION-CELL" USING WS-AV(1) WS-C1(1)
     COMPUTE WS-SCAN = WS-AV(2) - 2000000
     CALL "CUSHION-CELL" USING WS-SCAN WS-C1(2)
     CALL "CUSHION-CELL" USING WS-AV(3) WS-C1(3)
     CALL "CUSHION-CELL" USING WS-AV(4) WS-C2(1)
     CALL "CUSHION-CELL" USING WS-AV(5) WS-C2(2)
     CALL "CUSHION-CELL" USING WS-AV(6) WS-C2(3)
     PERFORM VARYING WS-CX FROM WS-C1(1) BY 1 UNTIL WS-CX > WS-C2(1)
         PERFORM VARYING WS-CY FROM WS-C1(2) BY 1 UNTIL WS-CY > WS-C2(2)
             PERFORM VARYING WS-CZ FROM WS-C1(3) BY 1 UNTIL WS-CZ > WS-C2(3)
                 CALL "WORLD-GET-BLOCK" USING L-DIM WS-CX WS-CY WS-CZ WS-STATE
                 MOVE WS-CX TO WS-CK(1)
                 MOVE WS-CY TO WS-CK(2)
                 MOVE WS-CZ TO WS-CK(3)
                 CALL "BSH-OUT-ID" USING WS-STATE WS-SHAPE
*>               The bounding box of the outline shape in the cell.
                 IF BSH-N(WS-SHAPE + 1) > 0
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
                         MOVE 9000000000000000 TO WS-LOW(WS-K)
                         MOVE -9000000000000000 TO WS-HIGH(WS-K)
                         COMPUTE WS-CU = WS-CK(WS-K) * 16000000
                         PERFORM VARYING WS-BI FROM 1 BY 1 UNTIL WS-BI > BSH-N(WS-SHAPE + 1)
                             COMPUTE WS-V1 = WS-CU + BSH-V(WS-SHAPE + 1, WS-BI, WS-K) * 1000
                             COMPUTE WS-V2 = WS-CU + BSH-V(WS-SHAPE + 1, WS-BI, WS-K + 3) * 1000
                             COMPUTE WS-LOW(WS-K) = FUNCTION MIN(WS-LOW(WS-K), WS-V1)
                             COMPUTE WS-HIGH(WS-K) = FUNCTION MAX(WS-HIGH(WS-K), WS-V2)
                         END-PERFORM
                     END-PERFORM
                     MOVE 1 TO WS-OVER
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
                         IF WS-HIGH(WS-K) <= WS-AV(WS-K) OR WS-LOW(WS-K) >= WS-AV(WS-K + 3)
                             MOVE 0 TO WS-OVER
                         END-IF
                     END-PERFORM
                     IF WS-OVER = 1
                         MOVE 1 TO L-RESULT
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM CUSHION-ANCHOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CUSHION-COVERED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LOWER               BINARY-DOUBLE.
 01 WS-UPPER               BINARY-DOUBLE.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-C1                  BINARY-LONG OCCURS 3 TIMES.
 01 WS-C2                  BINARY-LONG OCCURS 3 TIMES.
 01 WS-SUFF                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-BOX.
    05 L-B                 BINARY-DOUBLE OCCURS 6 TIMES.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-BOX L-RESULT.
     MOVE 1 TO L-RESULT
*>   The box less one U on every side; the result is 1 only when every block it touches suffocates.
     COMPUTE WS-LOWER = L-B(1) + 1
     CALL "CUSHION-CELL" USING WS-LOWER WS-C1(1)
     COMPUTE WS-LOWER = L-B(2) + 1
     CALL "CUSHION-CELL" USING WS-LOWER WS-C1(2)
     COMPUTE WS-LOWER = L-B(3) + 1
     CALL "CUSHION-CELL" USING WS-LOWER WS-C1(3)
     COMPUTE WS-UPPER = L-B(4) - 1
     CALL "CUSHION-CELL" USING WS-UPPER WS-C2(1)
     COMPUTE WS-UPPER = L-B(5) - 1
     CALL "CUSHION-CELL" USING WS-UPPER WS-C2(2)
     COMPUTE WS-UPPER = L-B(6) - 1
     CALL "CUSHION-CELL" USING WS-UPPER WS-C2(3)
     PERFORM VARYING WS-CX FROM WS-C1(1) BY 1 UNTIL WS-CX > WS-C2(1)
         PERFORM VARYING WS-CY FROM WS-C1(2) BY 1 UNTIL WS-CY > WS-C2(2)
             PERFORM VARYING WS-CZ FROM WS-C1(3) BY 1 UNTIL WS-CZ > WS-C2(3)
                 CALL "CUSHION-SUFFOCATING" USING L-DIM WS-CX WS-CY WS-CZ WS-SUFF
                 IF WS-SUFF = 0
                     MOVE 0 TO L-RESULT
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM CUSHION-COVERED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CUSHION-FIRE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LOWER               BINARY-DOUBLE.
 01 WS-UPPER               BINARY-DOUBLE.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-C1                  BINARY-LONG OCCURS 3 TIMES.
 01 WS-C2                  BINARY-LONG OCCURS 3 TIMES.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:fire".
 01 WS-TAGGED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-BOX.
    05 L-B                 BINARY-DOUBLE OCCURS 6 TIMES.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-BOX L-RESULT.
     MOVE 0 TO L-RESULT
     COMPUTE WS-LOWER = L-B(1) + 1
     CALL "CUSHION-CELL" USING WS-LOWER WS-C1(1)
     COMPUTE WS-LOWER = L-B(2) + 1
     CALL "CUSHION-CELL" USING WS-LOWER WS-C1(2)
     COMPUTE WS-LOWER = L-B(3) + 1
     CALL "CUSHION-CELL" USING WS-LOWER WS-C1(3)
     COMPUTE WS-UPPER = L-B(4) - 1
     CALL "CUSHION-CELL" USING WS-UPPER WS-C2(1)
     COMPUTE WS-UPPER = L-B(5) - 1
     CALL "CUSHION-CELL" USING WS-UPPER WS-C2(2)
     COMPUTE WS-UPPER = L-B(6) - 1
     CALL "CUSHION-CELL" USING WS-UPPER WS-C2(3)
     PERFORM VARYING WS-CX FROM WS-C1(1) BY 1 UNTIL WS-CX > WS-C2(1)
         PERFORM VARYING WS-CY FROM WS-C1(2) BY 1 UNTIL WS-CY > WS-C2(2)
             PERFORM VARYING WS-CZ FROM WS-C1(3) BY 1 UNTIL WS-CZ > WS-C2(3)
                 CALL "WORLD-GET-BLOCK" USING L-DIM WS-CX WS-CY WS-CZ WS-STATE
                 CALL "CONTENT-BLOCK-OF-STATE" USING WS-STATE WS-BLOCK WS-INDEX WS-ROW WS-STATUS
                 CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-BLOCK WS-TAGGED
                 IF WS-TAGGED = 1
                     MOVE 1 TO L-RESULT
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM CUSHION-FIRE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CUSHION-BURIED.
*> The slab C (the bottom 1/64 of the box, one U less on every side) is buried when the collision boxes that overlap it cover all of it. The boxes are clipped to C; each axis is cut at every box
*> bound, and every piece of the cut must lie inside some box (a piece is inside a box or outside it, since every cut is a box bound).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTBSHAPE.
 01 WS-CV                  BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CK                  BINARY-LONG OCCURS 3 TIMES.
 01 WS-C1                  BINARY-LONG OCCURS 3 TIMES.
 01 WS-C2                  BINARY-LONG OCCURS 3 TIMES.
 01 WS-STATE               BINARY-LONG.
 01 WS-SHAPE               BINARY-LONG.
 01 WS-BI                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CU                  BINARY-DOUBLE.
 01 WS-LO                  BINARY-DOUBLE OCCURS 3 TIMES.
 01 WS-HI                  BINARY-DOUBLE OCCURS 3 TIMES.
 01 WS-POSITIVE            BINARY-LONG.
 01 WS-NB                  BINARY-LONG.
 01 WS-BOXES.
    05 WS-BOX              OCCURS 48 TIMES.
       10 WS-BV            BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-CUTS.
    05 WS-AXIS             OCCURS 3 TIMES.
       10 WS-CUT           BINARY-DOUBLE OCCURS 100 TIMES.
 01 WS-NC                  BINARY-LONG OCCURS 3 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-J1                  BINARY-LONG.
 01 WS-TEMP                BINARY-DOUBLE.
 01 WS-P                   BINARY-LONG OCCURS 3 TIMES.
 01 WS-PK                  BINARY-LONG.
 01 WS-PK1                 BINARY-LONG.
 01 WS-PL                  BINARY-DOUBLE OCCURS 3 TIMES.
 01 WS-PH                  BINARY-DOUBLE OCCURS 3 TIMES.
 01 WS-INSIDE              BINARY-LONG.
 01 WS-HOLE                BINARY-LONG.
 01 WS-LOWER               BINARY-DOUBLE.
 01 WS-UPPER               BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-BOX.
    05 L-B                 BINARY-DOUBLE OCCURS 6 TIMES.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-BOX L-RESULT.
     MOVE 0 TO L-RESULT WS-NB
     COMPUTE WS-CV(1) = L-B(1) + 1
     COMPUTE WS-CV(2) = L-B(2) + 1
     COMPUTE WS-CV(3) = L-B(3) + 1
     COMPUTE WS-CV(4) = L-B(4) - 1
     COMPUTE WS-CV(5) = L-B(2) + 250000 - 1
     COMPUTE WS-CV(6) = L-B(6) - 1
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
         CALL "CUSHION-CELL" USING WS-CV(WS-K) WS-C1(WS-K)
         COMPUTE WS-UPPER = WS-CV(WS-K + 3)
         CALL "CUSHION-CELL" USING WS-UPPER WS-C2(WS-K)
     END-PERFORM
*>   The collision boxes of every cell that C touches, clipped to C, when they overlap it with positive volume.
     PERFORM VARYING WS-CX FROM WS-C1(1) BY 1 UNTIL WS-CX > WS-C2(1)
         PERFORM VARYING WS-CY FROM WS-C1(2) BY 1 UNTIL WS-CY > WS-C2(2)
             PERFORM VARYING WS-CZ FROM WS-C1(3) BY 1 UNTIL WS-CZ > WS-C2(3)
                 CALL "WORLD-GET-BLOCK" USING L-DIM WS-CX WS-CY WS-CZ WS-STATE
                 MOVE WS-CX TO WS-CK(1)
                 MOVE WS-CY TO WS-CK(2)
                 MOVE WS-CZ TO WS-CK(3)
                 CALL "BSH-COLL-ID" USING WS-STATE WS-SHAPE
                 PERFORM VARYING WS-BI FROM 1 BY 1 UNTIL WS-BI > BSH-N(WS-SHAPE + 1)
                     MOVE 1 TO WS-POSITIVE
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
                         COMPUTE WS-CU = WS-CK(WS-K) * 16000000
                         COMPUTE WS-LOWER = WS-CU + BSH-V(WS-SHAPE + 1, WS-BI, WS-K) * 1000
                         COMPUTE WS-UPPER = WS-CU + BSH-V(WS-SHAPE + 1, WS-BI, WS-K + 3) * 1000
                         COMPUTE WS-LO(WS-K) = FUNCTION MAX(WS-LOWER, WS-CV(WS-K))
                         COMPUTE WS-HI(WS-K) = FUNCTION MIN(WS-UPPER, WS-CV(WS-K + 3))
                         IF WS-HI(WS-K) <= WS-LO(WS-K)
                             MOVE 0 TO WS-POSITIVE
                         END-IF
                     END-PERFORM
                     IF WS-POSITIVE = 1 AND WS-NB < 48
                         ADD 1 TO WS-NB
                         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
                             MOVE WS-LO(WS-K) TO WS-BV(WS-NB, WS-K)
                             MOVE WS-HI(WS-K) TO WS-BV(WS-NB, WS-K + 3)
                         END-PERFORM
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF WS-NB = 0
         GOBACK
     END-IF
*>   The cuts of each axis: the bounds of C and of every box, in ascending order.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
         MOVE WS-CV(WS-K) TO WS-CUT(WS-K, 1)
         MOVE WS-CV(WS-K + 3) TO WS-CUT(WS-K, 2)
         MOVE 2 TO WS-NC(WS-K)
         PERFORM VARYING WS-BI FROM 1 BY 1 UNTIL WS-BI > WS-NB
             ADD 1 TO WS-NC(WS-K)
             MOVE WS-BV(WS-BI, WS-K) TO WS-CUT(WS-K, WS-NC(WS-K))
             ADD 1 TO WS-NC(WS-K)
             MOVE WS-BV(WS-BI, WS-K + 3) TO WS-CUT(WS-K, WS-NC(WS-K))
         END-PERFORM
         PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > WS-NC(WS-K)
             MOVE WS-CUT(WS-K, WS-I) TO WS-TEMP
             MOVE WS-I TO WS-J
             PERFORM UNTIL WS-J = 1
                 COMPUTE WS-J1 = WS-J - 1
                 IF WS-CUT(WS-K, WS-J1) <= WS-TEMP
                     EXIT PERFORM
                 END-IF
                 MOVE WS-CUT(WS-K, WS-J1) TO WS-CUT(WS-K, WS-J)
                 MOVE WS-J1 TO WS-J
             END-PERFORM
             MOVE WS-TEMP TO WS-CUT(WS-K, WS-J)
         END-PERFORM
     END-PERFORM
*>   Every piece of positive size must be inside a box; one that is not is a hole, and the slab is not buried.
     MOVE 0 TO WS-HOLE
     PERFORM VARYING WS-P(1) FROM 1 BY 1 UNTIL WS-P(1) >= WS-NC(1) OR WS-HOLE = 1
         PERFORM VARYING WS-P(2) FROM 1 BY 1 UNTIL WS-P(2) >= WS-NC(2) OR WS-HOLE = 1
             PERFORM VARYING WS-P(3) FROM 1 BY 1 UNTIL WS-P(3) >= WS-NC(3) OR WS-HOLE = 1
                 MOVE 1 TO WS-POSITIVE
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
                     MOVE WS-P(WS-K) TO WS-PK
                     COMPUTE WS-PK1 = WS-PK + 1
                     MOVE WS-CUT(WS-K, WS-PK) TO WS-PL(WS-K)
                     MOVE WS-CUT(WS-K, WS-PK1) TO WS-PH(WS-K)
                     IF WS-PH(WS-K) <= WS-PL(WS-K)
                         MOVE 0 TO WS-POSITIVE
                     END-IF
                 END-PERFORM
                 IF WS-POSITIVE = 1
                     MOVE 0 TO WS-INSIDE
                     PERFORM VARYING WS-BI FROM 1 BY 1 UNTIL WS-BI > WS-NB
                         IF WS-BV(WS-BI, 1) <= WS-PL(1) AND WS-PH(1) <= WS-BV(WS-BI, 4)
                            AND WS-BV(WS-BI, 2) <= WS-PL(2) AND WS-PH(2) <= WS-BV(WS-BI, 5)
                            AND WS-BV(WS-BI, 3) <= WS-PL(3) AND WS-PH(3) <= WS-BV(WS-BI, 6)
                             MOVE 1 TO WS-INSIDE
                         END-IF
                     END-PERFORM
                     IF WS-INSIDE = 0
                         MOVE 1 TO WS-HOLE
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF WS-HOLE = 0
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM CUSHION-BURIED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CUSHION-SURVIVES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ANCHOR              BINARY-LONG.
 01 WS-COVERED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-BOX.
    05 L-B                 BINARY-DOUBLE OCCURS 6 TIMES.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-BOX L-OK.
     MOVE 0 TO L-OK
     CALL "CUSHION-ANCHOR" USING L-DIM L-BOX WS-ANCHOR
     CALL "CUSHION-COVERED" USING L-DIM L-BOX WS-COVERED
     IF WS-ANCHOR = 1 AND WS-COVERED = 0
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM CUSHION-SURVIVES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CUSHION-CAN-PLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SURVIVES            BINARY-LONG.
 01 WS-BURIED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-BOX.
    05 L-B                 BINARY-DOUBLE OCCURS 6 TIMES.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-BOX L-OK.
     MOVE 0 TO L-OK
     CALL "CUSHION-SURVIVES" USING L-DIM L-BOX WS-SURVIVES
     IF WS-SURVIVES = 1
         CALL "CUSHION-BURIED" USING L-DIM L-BOX WS-BURIED
         IF WS-BURIED = 0
             MOVE 1 TO L-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CUSHION-CAN-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CUSHION-BOX-OF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-BOX.
    05 L-B                 BINARY-DOUBLE OCCURS 6 TIMES.
 PROCEDURE DIVISION USING L-ROW L-BOX.
     COMPUTE WS-F = EN-X(L-ROW) - 0.5
     CALL "CUSHION-U" USING WS-F L-B(1)
     MOVE EN-Y(L-ROW) TO WS-F
     CALL "CUSHION-U" USING WS-F L-B(2)
     COMPUTE WS-F = EN-Z(L-ROW) - 0.5
     CALL "CUSHION-U" USING WS-F L-B(3)
     COMPUTE WS-F = EN-X(L-ROW) + 0.5
     CALL "CUSHION-U" USING WS-F L-B(4)
     COMPUTE WS-F = EN-Y(L-ROW) + 0.25
     CALL "CUSHION-U" USING WS-F L-B(5)
     COMPUTE WS-F = EN-Z(L-ROW) + 0.5
     CALL "CUSHION-U" USING WS-F L-B(6)
     GOBACK.
 END PROGRAM CUSHION-BOX-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CUSHION-KIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-WHITE-KEY           PIC X(112) VALUE "minecraft:white_cushion".
 01 WS-WHITE               BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-COLOUR               BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-COLOUR.
     MOVE -1 TO L-COLOUR
     CALL "TOOLUSE-KEY" USING L-ITEM WS-KEY
     COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-KEY))
     IF WS-LENGTH > 8
         COMPUTE WS-FROM = WS-LENGTH - 7
         IF WS-KEY(WS-FROM:8) = "_cushion"
             CALL "CONTENT-ITEM-BY-KEY" USING WS-WHITE-KEY WS-WHITE WS-ITEM-ROW WS-STATUS
             COMPUTE L-COLOUR = L-ITEM - WS-WHITE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM CUSHION-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CUSHION-BREAK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-WHITE-KEY           PIC X(112) VALUE "minecraft:white_cushion".
 01 WS-WHITE               BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-CREATIVE            BINARY-LONG.
 01 WS-RULE-NAME           PIC X(40) VALUE "entity_drops".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-DIM                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KILLER               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-KILLER.
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
*>   dropItem: nothing when the entity_drops rule is off or the breaker has infinite materials (a creative player).
     IF WS-RULE NOT = 0 AND WS-SLOT > 0
         MOVE 0 TO WS-CREATIVE
         IF L-KILLER > 0
             IF PL-MODE(L-KILLER) = 1
                 MOVE 1 TO WS-CREATIVE
             END-IF
         END-IF
         IF WS-CREATIVE = 0
             CALL "CONTENT-ITEM-BY-KEY" USING WS-WHITE-KEY WS-WHITE WS-ITEM-ROW WS-STATUS
             COMPUTE WS-ITEM = WS-WHITE + PJ-I1(WS-SLOT)
             CALL "DECOR-DROP" USING WS-DIM WS-X WS-Y WS-Z WS-ITEM
         END-IF
     END-IF
*>   BlockAttachedEntity.kill: entity_die at the cushion, the killer (else the cushion itself) as the source.
     CALL "GAME-EVENT-KILLED" USING L-ROW L-KILLER
     CALL "PJ-DROP" USING L-ROW
     GOBACK.
 END PROGRAM CUSHION-BREAK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CUSHION-SEAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-RIDER               BINARY-LONG.
 01 WS-GROUND              BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE EN-RIDER(L-ROW) TO WS-RIDER
     IF WS-RIDER > 0
*>       getPassengerRidingPosition = position + (0, 0.25, 0); the player's feet are 0.6 below that (Avatar.DEFAULT_VEHICLE_ATTACHMENT): y - 0.35.
         MOVE EN-X(L-ROW) TO PL-X(WS-RIDER)
         COMPUTE PL-Y(WS-RIDER) = EN-Y(L-ROW) + 0.25 - 0.6
         MOVE EN-Z(L-ROW) TO PL-Z(WS-RIDER)
         CALL "ENTITY-MOVE" USING PL-ENTITY-ROW(WS-RIDER) PL-X(WS-RIDER) PL-Y(WS-RIDER) PL-Z(WS-RIDER)
             PL-YAW(WS-RIDER) PL-PITCH(WS-RIDER) WS-GROUND
     END-IF
     GOBACK.
 END PROGRAM CUSHION-SEAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CUSHION-THUNDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LIST.
    05 WS-LIST-ROW         BINARY-LONG OCCURS 64 TIMES.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-BOLT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BOLT.
*>   Collect first: a break removes the entity's state while the table is walked.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 45 AND WS-COUNT < 64
             PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
                 IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = PJ-ENT(WS-I) AND EN-DIM(WS-E) = EN-DIM(L-BOLT)
                     IF FUNCTION ABS(EN-X(WS-E) - EN-X(L-BOLT)) < 3.5 AND FUNCTION ABS(EN-Z(WS-E) - EN-Z(L-BOLT)) < 3.5
                             AND EN-Y(WS-E) < EN-Y(L-BOLT) + 9 AND EN-Y(WS-E) + 0.25 > EN-Y(L-BOLT) - 3
                         ADD 1 TO WS-COUNT
                         MOVE WS-E TO WS-LIST-ROW(WS-COUNT)
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         CALL "CUSHION-BREAK" USING WS-LIST-ROW(WS-I) WS-NONE
     END-PERFORM
     GOBACK.
 END PROGRAM CUSHION-THUNDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CUSHION-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-BOX.
    05 WS-B                BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-FIRE                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     CALL "CUSHION-SEAT" USING L-ROW
*>   BlockAttachedEntity.tick: a counter to 100, then tickAtCheckInterval (destroyIfInFire) and the survival check.
     ADD 1 TO PJ-TICK(WS-SLOT)
     IF PJ-TICK(WS-SLOT) < 100
         GOBACK
     END-IF
     MOVE 0 TO PJ-TICK(WS-SLOT)
     CALL "CUSHION-BOX-OF" USING L-ROW WS-BOX
     CALL "CUSHION-FIRE" USING EN-DIM(L-ROW) WS-BOX WS-FIRE
     IF WS-FIRE = 1
         CALL "CUSHION-BREAK" USING L-ROW WS-NONE
         GOBACK
     END-IF
     CALL "CUSHION-SURVIVES" USING EN-DIM(L-ROW) WS-BOX WS-OK
     IF WS-OK = 0
         CALL "CUSHION-BREAK" USING L-ROW WS-NONE
     END-IF
     GOBACK.
 END PROGRAM CUSHION-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CUSHION-HURT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PLAYER L-DONE.
     MOVE 0 TO L-DONE
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     IF PJ-KIND(WS-SLOT) NOT = 45
         GOBACK
     END-IF
     MOVE 1 TO L-DONE
*>   hurtServer: refused when the player may not build (adventure and spectator).
     IF PL-MODE(L-PLAYER) < 2
         CALL "CUSHION-BREAK" USING L-ROW L-PLAYER
     END-IF
     GOBACK.
 END PROGRAM CUSHION-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CUSHION-ITEM-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-DIM                 BINARY-LONG.
 01 WS-COLOUR              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:cushion_uses_collision_shape".
 01 WS-IN-TAG              BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-CLICK.
    05 WS-CK               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-ORG.
    05 WS-O                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-DIR.
    05 WS-D                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-SHAPE               BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-REPLACEABLE         BINARY-LONG.
 01 WS-TAG-REPLACEABLE     PIC X(112) VALUE "minecraft:replaceable".
 01 WS-SX                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-BOX.
    05 WS-B                BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-OTHER.
    05 WS-OB               BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-OK                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-OVER                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-FIRE                BINARY-LONG.
 01 WS-EV-PLACE            PIC X(32) VALUE "entity_place".
 01 WS-NO-STATE            BINARY-LONG VALUE -1.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 COPY PLAYPKT.
 01 L-ITEM                 BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER PLAY-SERVERBOUND L-ITEM L-PLACED.
     MOVE 0 TO L-PLACED
     CALL "CUSHION-KIND" USING L-ITEM WS-COLOUR
     IF WS-COLOUR < 0
         GOBACK
     END-IF
     MOVE PL-DIM(L-PLAYER) TO WS-DIM
     MOVE PSB-FACE TO WS-FACE
     COMPUTE WS-CK(1) = PSB-BX + PSB-CURSOR-X
     COMPUTE WS-CK(2) = PSB-BY + PSB-CURSOR-Y
     COMPUTE WS-CK(3) = PSB-BZ + PSB-CURSOR-Z
     CALL "WORLD-GET-BLOCK" USING WS-DIM PSB-BX PSB-BY PSB-BZ WS-STATE
*>   Step 1: a block of the tag cushion_uses_collision_shape: the click is clipped again against its collision shape, from the eye to 1 mm past the click.
     CALL "CONTENT-BLOCK-OF-STATE" USING WS-STATE WS-BLOCK WS-INDEX WS-ROW WS-STATUS
     CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-BLOCK WS-IN-TAG
     IF WS-IN-TAG = 1
         MOVE PL-X(L-PLAYER) TO WS-O(1)
         COMPUTE WS-O(2) = PL-Y(L-PLAYER) + 1.62
         MOVE PL-Z(L-PLAYER) TO WS-O(3)
         COMPUTE WS-D(1) = WS-CK(1) - WS-O(1)
         COMPUTE WS-D(2) = WS-CK(2) - WS-O(2)
         COMPUTE WS-D(3) = WS-CK(3) - WS-O(3)
         COMPUTE WS-LEN = FUNCTION SQRT(WS-D(1) * WS-D(1) + WS-D(2) * WS-D(2) + WS-D(3) * WS-D(3))
         IF WS-LEN > 0
*>           The segment runs from the eye to the click + normalised direction x 0.001; the direction is that segment, so t 1 is its end.
             COMPUTE WS-D(1) = WS-CK(1) + WS-D(1) / WS-LEN * 0.001 - WS-O(1)
             COMPUTE WS-D(2) = WS-CK(2) + WS-D(2) / WS-LEN * 0.001 - WS-O(2)
             COMPUTE WS-D(3) = WS-CK(3) + WS-D(3) / WS-LEN * 0.001 - WS-O(3)
             CALL "BSH-COLL-ID" USING WS-STATE WS-SHAPE
             CALL "BSH-RAY" USING WS-SHAPE PSB-BX PSB-BY PSB-BZ WS-ORG WS-DIR WS-T WS-AXIS
             IF WS-AXIS > 0 AND WS-T <= 1
                 COMPUTE WS-CK(1) = WS-O(1) + WS-T * WS-D(1)
                 COMPUTE WS-CK(2) = WS-O(2) + WS-T * WS-D(2)
                 COMPUTE WS-CK(3) = WS-O(3) + WS-T * WS-D(3)
*>               The face the segment entered through.
                 EVALUATE TRUE
                     WHEN WS-AXIS = 1 AND WS-D(1) > 0
                         MOVE 4 TO WS-FACE
                     WHEN WS-AXIS = 1
                         MOVE 5 TO WS-FACE
                     WHEN WS-AXIS = 2 AND WS-D(2) < 0
                         MOVE 1 TO WS-FACE
                     WHEN WS-AXIS = 2
                         MOVE 0 TO WS-FACE
                     WHEN WS-AXIS = 3 AND WS-D(3) > 0
                         MOVE 2 TO WS-FACE
                     WHEN OTHER
                         MOVE 3 TO WS-FACE
                 END-EVALUATE
             END-IF
         END-IF
     END-IF
*>   Step 2: only the UP face.
     IF WS-FACE NOT = 1
         GOBACK
     END-IF
*>   Step 3: P is the clicked block when it is replaceable, else the block above; the seat origin is the centre of P with the exact click height.
     MOVE PSB-BX TO WS-PX
     MOVE PSB-BZ TO WS-PZ
     COMPUTE WS-PY = PSB-BY + 1
     MOVE 1 TO WS-REPLACEABLE
     IF WS-STATE > 0
         CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG-REPLACEABLE WS-BLOCK WS-REPLACEABLE
     END-IF
     IF WS-REPLACEABLE = 1
         MOVE PSB-BY TO WS-PY
     END-IF
     COMPUTE WS-SX = WS-PX + 0.5
     COMPUTE WS-SZ = WS-PZ + 0.5
     COMPUTE WS-YAW = WS-SX - 0.5
     CALL "CUSHION-U" USING WS-YAW WS-B(1)
     CALL "CUSHION-U" USING WS-CK(2) WS-B(2)
     COMPUTE WS-YAW = WS-SZ - 0.5
     CALL "CUSHION-U" USING WS-YAW WS-B(3)
     COMPUTE WS-YAW = WS-SX + 0.5
     CALL "CUSHION-U" USING WS-YAW WS-B(4)
     COMPUTE WS-YAW = WS-CK(2) + 0.25
     CALL "CUSHION-U" USING WS-YAW WS-B(5)
     COMPUTE WS-YAW = WS-SZ + 0.5
     CALL "CUSHION-U" USING WS-YAW WS-B(6)
*>   Steps 4 and 5: canBePlacedAt.
     CALL "CUSHION-CAN-PLACE" USING WS-DIM WS-BOX WS-OK
     IF WS-OK = 0
         GOBACK
     END-IF
*>   Step 6 (server): another cushion that overlaps the box refuses the placement.
     MOVE 0 TO WS-OVER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 45
             PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
                 IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = PJ-ENT(WS-I) AND EN-DIM(WS-E) = WS-DIM
                     CALL "CUSHION-BOX-OF" USING WS-E WS-OTHER
                     IF WS-OB(4) > WS-B(1) AND WS-OB(1) < WS-B(4) AND WS-OB(5) > WS-B(2) AND WS-OB(2) < WS-B(5)
                        AND WS-OB(6) > WS-B(3) AND WS-OB(3) < WS-B(6)
                         MOVE 1 TO WS-OVER
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     IF WS-OVER = 1
         GOBACK
     END-IF
*>   The yaw is the player's, snapped to the nearest of the four horizontal directions (Direction.fromYRot, toYRot: south 0, west 90, north 180, east 270).
     COMPUTE WS-N = FUNCTION INTEGER(PL-YAW(L-PLAYER) / 90 + 0.5)
     COMPUTE WS-YAW = FUNCTION MOD(WS-N, 4) * 90
     CALL "CUSHION-SPAWN-YAW" USING WS-DIM WS-SX WS-CK(2) WS-SZ WS-COLOUR WS-YAW WS-NEW
     IF WS-NEW = 0
         GOBACK
     END-IF
     MOVE 1 TO L-PLACED
*>   destroyIfInFire at the placement.
     CALL "CUSHION-FIRE" USING WS-DIM WS-BOX WS-FIRE
     IF WS-FIRE = 1
         CALL "CUSHION-BREAK" USING WS-NEW WS-NONE
         CALL "GAME-EVENT-CELL" USING WS-DIM WS-PX WS-PY WS-PZ WS-EV-PLACE PL-ENTITY-ROW(L-PLAYER) WS-NO-STATE
     ELSE
         CALL "GAME-EVENT-BY" USING WS-EV-PLACE WS-NEW PL-ENTITY-ROW(L-PLAYER)
     END-IF
     CALL "MOB-TAKE" USING L-PLAYER
     GOBACK.
 END PROGRAM CUSHION-ITEM-USE.
