*> The poplar trunk and foliage placers of the tree feature (docs/protocol/35-worldgen-features-3-tree-placers.md 4.10, 5.4 and 5.5): FD-TREE-POPLAR-NODE and FD-TREE-POPLARF-NODE compile their
*> fields, FR-TRUNK-POPLAR places the trunk (a log per layer, every layer a shuffle of the six directions, and at the layer below the branch height trunk_height_above_branches 1 to 4 side logs),
*> FR-POPLAR-FOLIAGE the leaves of an attachment (the rows of 5.4 with the poplar row routine and hole draws of 5.5, then the leaves replaced by logs on the two axes of the crown).
*> A leaf replaced by a log is marked in the work grid as a log (TW-GRID 1); the commit writes only the leaves still marked (FR-TREE-COMMIT).
*> The shelf mushrooms the poplar trees carry (decorator shelf_mushroom) are not placed (feat-tree-deco.cob).
*>
*> Entry points: FD-TREE-POPLAR-NODE, FD-TREE-POPLARF-NODE USING doc, node, row; FR-TRUNK-POPLAR USING state, row, x, y, z, height;
*> FR-POPLAR-FOLIAGE USING state, row, attachment, foliage height, leaf radius, offset.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-TREE-POPLAR-NODE.
*> USING doc, trunk placer node, row: trunk_height_above_branches (TR-BHL) and branch_amount (TR-BC).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-K-ABOVE             PIC X(40) VALUE "trunk_height_above_branches".
 01 WS-K-AMOUNT            PIC X(40) VALUE "branch_amount".
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     CALL "FD-TREE-IP" USING JSON-DOC L-NODE WS-K-ABOVE TR-BHL(L-ROW)
     CALL "FD-TREE-IP" USING JSON-DOC L-NODE WS-K-AMOUNT TR-BC(L-ROW)
     GOBACK.
 END PROGRAM FD-TREE-POPLAR-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-TREE-POPLARF-NODE.
*> USING doc, foliage placer node, row: side_hole_chance (TR-CF1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-K-HOLE              PIC X(40) VALUE "side_hole_chance".
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     CALL "FD-TREE-FLOAT" USING JSON-DOC L-NODE WS-K-HOLE WS-ZERO TR-CF1(L-ROW)
     GOBACK.
 END PROGRAM FD-TREE-POPLARF-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TRUNK-POPLAR.
*> USING state, row, x, y, z, height: 4.10: the soil under the origin; by = H - trunk_height_above_branches; per layer a log, then a shuffle of the directions (for n = 6 down to 2 swap
*> element nextInt(n) with element n - 1; the vertical ones are dropped); at layer by - 1 branch_amount side logs (the first of the shuffled horizontals, with the axis of their direction)
*> beside the log of that layer; the attachment is the cell by above the origin.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-NH                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-LIST.
    05 WS-DIR              BINARY-LONG OCCURS 6 TIMES.
 01 WS-HOR.
    05 WS-H                BINARY-LONG OCCURS 6 TIMES.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-X L-Y L-Z L-H.
     COMPUTE WS-Y = L-Y - 1
     CALL "FR-TREE-SOIL" USING L-ROW L-X WS-Y L-Z
     CALL "FR-INT-SAMPLE" USING L-STATE TR-BHL(L-ROW) WS-ABOVE
     COMPUTE WS-BY = L-H - WS-ABOVE
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= L-H
         COMPUTE WS-Y = L-Y + WS-I
         CALL "FR-TREE-LOG" USING L-X WS-Y L-Z WS-ZERO WS-PLACED
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 6
             COMPUTE WS-DIR(WS-J) = WS-J - 1
         END-PERFORM
         PERFORM VARYING WS-N FROM 6 BY -1 UNTIL WS-N < 2
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-N WS-K
             MOVE WS-DIR(WS-K + 1) TO WS-T
             MOVE WS-DIR(WS-N) TO WS-DIR(WS-K + 1)
             MOVE WS-T TO WS-DIR(WS-N)
         END-PERFORM
         MOVE 0 TO WS-NH
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 6
             IF WS-DIR(WS-J) >= 2
                 ADD 1 TO WS-NH
                 MOVE WS-DIR(WS-J) TO WS-H(WS-NH)
             END-IF
         END-PERFORM
         IF WS-BY - 1 = WS-I
             CALL "FR-INT-SAMPLE" USING L-STATE TR-BC(L-ROW) WS-COUNT
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-COUNT OR WS-K > WS-NH
                 CALL "F353-STEP" USING WS-H(WS-K) WS-DX WS-DY WS-DZ
                 MOVE 1 TO WS-AXIS
                 IF WS-DX NOT = 0
                     MOVE -1 TO WS-AXIS
                 END-IF
                 COMPUTE WS-PX = L-X + WS-DX
                 COMPUTE WS-PZ = L-Z + WS-DZ
                 CALL "FR-TREE-LOG" USING WS-PX WS-Y WS-PZ WS-AXIS WS-PLACED
             END-PERFORM
         END-IF
     END-PERFORM
     COMPUTE WS-Y = L-Y + WS-BY
     CALL "FR-TREE-ATT" USING L-X WS-Y L-Z WS-ZERO WS-ZERO2
     GOBACK.
 END PROGRAM FR-TRUNK-POPLAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-POPLAR-INSIDE.
*> USING radius, ax, az, cut value, hole, flag out: inside (5.5): ax + az <= 2 radius - (cut + hole).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RAD                  BINARY-LONG.
 01 L-AX                   BINARY-LONG.
 01 L-AZ                   BINARY-LONG.
 01 L-CUT                  BINARY-LONG.
 01 L-HOLE                 BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-RAD L-AX L-AZ L-CUT L-HOLE L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-AX + L-AZ <= 2 * L-RAD - (L-CUT + L-HOLE)
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM FR-POPLAR-INSIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-POPLAR-CUT.
*> USING x, z, radius, partial, flip, cut out: cut (5.5): radius - 1 for a corner (x and z non-zero with opposite signs, or equal signs when flipped), else radius + 1 on a partial row, else radius.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RAD                  BINARY-LONG.
 01 L-PARTIAL              BINARY-LONG.
 01 L-FLIP                 BINARY-LONG.
 01 L-CUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-RAD L-PARTIAL L-FLIP L-CUT.
     MOVE L-RAD TO L-CUT
     IF L-PARTIAL = 1
         COMPUTE L-CUT = L-RAD + 1
     END-IF
     IF L-X NOT = 0 AND L-Z NOT = 0
         IF L-FLIP = 0 AND ((L-X < 0 AND L-Z > 0) OR (L-X > 0 AND L-Z < 0))
             COMPUTE L-CUT = L-RAD - 1
         END-IF
         IF L-FLIP = 1 AND ((L-X < 0 AND L-Z < 0) OR (L-X > 0 AND L-Z > 0))
             COMPUTE L-CUT = L-RAD - 1
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FR-POPLAR-CUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-POPLAR-ROW.
*> USING state, row, centre x, y, z, radius, dy, hh, flip: the poplar row routine (5.5): for x, z in -radius .. radius (signed): a partial row (dy = hh - 1 or hh - 2) skips the rim without a draw; otherwise
*> hole = 1 when nextFloat() is at most side_hole_chance, and the cell is skipped unless inside (radius, |x|, |z|, cut, hole); else tryPlaceLeaf.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-PARTIAL             BINARY-LONG.
 01 WS-EDGE                BINARY-LONG.
 01 WS-HOLE                BINARY-LONG.
 01 WS-CUT                 BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-INSIDE              BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CY                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-RAD                  BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-HH                   BINARY-LONG.
 01 L-FLIP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-CX L-CY L-CZ L-RAD L-DY L-HH L-FLIP.
     MOVE TR-CF1(L-ROW) TO WS-P
     CALL "FR-F32" USING WS-P
     COMPUTE WS-LO = 0 - L-RAD
     COMPUTE WS-PY = L-CY + L-DY
     MOVE 0 TO WS-PARTIAL
     IF L-HH - 1 = L-DY OR L-HH - 2 = L-DY
         MOVE 1 TO WS-PARTIAL
     END-IF
     PERFORM VARYING WS-X FROM WS-LO BY 1 UNTIL WS-X > L-RAD
         PERFORM VARYING WS-Z FROM WS-LO BY 1 UNTIL WS-Z > L-RAD
             COMPUTE WS-AX = FUNCTION ABS(WS-X)
             COMPUTE WS-AZ = FUNCTION ABS(WS-Z)
             MOVE 0 TO WS-EDGE
             IF WS-AX = L-RAD OR WS-AZ = L-RAD
                 MOVE 1 TO WS-EDGE
             END-IF
             IF NOT (WS-PARTIAL = 1 AND WS-EDGE = 1)
                 CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
                 MOVE 0 TO WS-HOLE
                 IF WS-F <= WS-P
                     MOVE 1 TO WS-HOLE
                 END-IF
                 CALL "FR-POPLAR-CUT" USING WS-X WS-Z L-RAD WS-PARTIAL L-FLIP WS-CUT
                 CALL "FR-POPLAR-INSIDE" USING L-RAD WS-AX WS-AZ WS-CUT WS-HOLE WS-INSIDE
                 IF WS-INSIDE = 1
                     COMPUTE WS-PX = L-CX + WS-X
                     COMPUTE WS-PZ = L-CZ + WS-Z
                     CALL "FR-TREE-LEAF" USING WS-PX WS-PY WS-PZ L-STATE
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FR-POPLAR-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-POPLAR-LOGS.
*> USING centre x, y, z, radius, dy, hh, flip (hh is unused: the only call is at dy = hh - 4, which is never a partial row, so partial is 0): replaceLeavesWithLog (5.5): a cell inside (radius, |x|, |z|, cut, 2) on the x axis or the z axis of the crown, at least 4 from its rim, whose
*> cell holds a leaf of this tree, becomes a log with the axis x when z is 0, else z.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TREEWORK.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-PARTIAL             BINARY-LONG.
 01 WS-CUT                 BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-INSIDE              BINARY-LONG.
 01 WS-HOLE                BINARY-LONG VALUE 2.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CY                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-RAD                  BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-HH                   BINARY-LONG.
 01 L-FLIP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CY L-CZ L-RAD L-DY L-HH L-FLIP.
     COMPUTE WS-LO = 0 - L-RAD
     COMPUTE WS-PY = L-CY + L-DY
     MOVE 0 TO WS-PARTIAL
     PERFORM VARYING WS-X FROM WS-LO BY 1 UNTIL WS-X > L-RAD
         PERFORM VARYING WS-Z FROM WS-LO BY 1 UNTIL WS-Z > L-RAD
             COMPUTE WS-AX = FUNCTION ABS(WS-X)
             COMPUTE WS-AZ = FUNCTION ABS(WS-Z)
             CALL "FR-POPLAR-CUT" USING WS-X WS-Z L-RAD WS-PARTIAL L-FLIP WS-CUT
             CALL "FR-POPLAR-INSIDE" USING L-RAD WS-AX WS-AZ WS-CUT WS-HOLE WS-INSIDE
             IF WS-INSIDE = 1 AND ((WS-AZ = 0 AND L-RAD - WS-AX >= 4) OR (WS-AX = 0 AND L-RAD - WS-AZ >= 4))
                 COMPUTE WS-PX = L-CX + WS-X
                 COMPUTE WS-PZ = L-CZ + WS-Z
                 CALL "FR-TREE-CELL" USING WS-PX WS-PY WS-PZ WS-CELL
                 IF WS-CELL > 0
                     IF TW-GRID(WS-CELL) = 2
                         MOVE 1 TO TW-GRID(WS-CELL)
                         ADD 1 TO TW-NLOG
                         MOVE WS-PX TO TW-LOG-X(TW-NLOG)
                         MOVE WS-PY TO TW-LOG-Y(TW-NLOG)
                         MOVE WS-PZ TO TW-LOG-Z(TW-NLOG)
                         MOVE 1 TO TW-LOG-A(TW-NLOG)
                         IF WS-AZ = 0
                             MOVE -1 TO TW-LOG-A(TW-NLOG)
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FR-POPLAR-LOGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-POPLAR-FOLIAGE.
*> USING state, row, attachment, foliage height, leaf radius, offset: createFoliage of the poplar placer (5.4): centre = the attachment raised by the offset, r0 = radius + radius offset - 1,
*> flip = nextBoolean() (the first draw), hh = foliage height; rows (r0 - 2, hh - 1), (r0 - 1, hh - 2), (r0 - 1, hh - 3), then (r0, y) for y = hh - 4 down to 1; the log replacement at hh - 4;
*> then (r0 - 1, 0) and (clamp(r0 - 2, 1, 2), -1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TREEWORK.
 01 WS-CY                  BINARY-LONG.
 01 WS-R0                  BINARY-LONG.
 01 WS-RAD                 BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-HH                  BINARY-LONG.
 01 WS-FLIP                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-ATT                  BINARY-LONG.
 01 L-FH                   BINARY-LONG.
 01 L-LR                   BINARY-LONG.
 01 L-OFF                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-ATT L-FH L-LR L-OFF.
     CALL "F351-NEXT-BOOLEAN" USING L-STATE WS-FLIP
     COMPUTE WS-CY = TW-ATT-Y(L-ATT) + L-OFF
     COMPUTE WS-R0 = L-LR + TW-ATT-R(L-ATT) - 1
     MOVE L-FH TO WS-HH
     COMPUTE WS-RAD = WS-R0 - 2
     COMPUTE WS-Y = WS-HH - 1
     CALL "FR-POPLAR-ROW" USING L-STATE L-ROW TW-ATT-X(L-ATT) WS-CY TW-ATT-Z(L-ATT) WS-RAD WS-Y WS-HH WS-FLIP
     COMPUTE WS-RAD = WS-R0 - 1
     COMPUTE WS-Y = WS-HH - 2
     CALL "FR-POPLAR-ROW" USING L-STATE L-ROW TW-ATT-X(L-ATT) WS-CY TW-ATT-Z(L-ATT) WS-RAD WS-Y WS-HH WS-FLIP
     COMPUTE WS-Y = WS-HH - 3
     CALL "FR-POPLAR-ROW" USING L-STATE L-ROW TW-ATT-X(L-ATT) WS-CY TW-ATT-Z(L-ATT) WS-RAD WS-Y WS-HH WS-FLIP
     COMPUTE WS-FROM = WS-HH - 4
     PERFORM VARYING WS-Y FROM WS-FROM BY -1 UNTIL WS-Y < 1
         CALL "FR-POPLAR-ROW" USING L-STATE L-ROW TW-ATT-X(L-ATT) WS-CY TW-ATT-Z(L-ATT) WS-R0 WS-Y WS-HH WS-FLIP
     END-PERFORM
     CALL "FR-POPLAR-LOGS" USING TW-ATT-X(L-ATT) WS-CY TW-ATT-Z(L-ATT) WS-R0 WS-FROM WS-HH WS-FLIP
     MOVE 0 TO WS-Y
     CALL "FR-POPLAR-ROW" USING L-STATE L-ROW TW-ATT-X(L-ATT) WS-CY TW-ATT-Z(L-ATT) WS-RAD WS-Y WS-HH WS-FLIP
     COMPUTE WS-RAD = FUNCTION MIN(FUNCTION MAX(WS-R0 - 2, 1), 2)
     MOVE -1 TO WS-Y
     CALL "FR-POPLAR-ROW" USING L-STATE L-ROW TW-ATT-X(L-ATT) WS-CY TW-ATT-Z(L-ATT) WS-RAD WS-Y WS-HH WS-FLIP
     GOBACK.
 END PROGRAM FR-POPLAR-FOLIAGE.
