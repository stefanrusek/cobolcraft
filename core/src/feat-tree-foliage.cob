*> The foliage placers of the tree feature (docs/protocol/35-worldgen-features-3-tree-placers.md section 5): FR-FOLIAGE places the leaves of one attachment of the trunk placer into the work
*> area of TREEWORK.cpy (the row routine FR-TREE-ROW is placeLeavesRow with the skip test of the placer, 5.1 and 5.2). Supported: blob, spruce, pine, acacia, fancy, jungle, mega pine, dark oak.
*> The attachment's radius offset and double trunk flag come from the trunk placer; the foliage height offset is always 0 (1.1). The offset draw is made once per attachment before any row.
*>
*> Entry points: FR-TREE-ROW USING state, x, y, z (centre), radius, dy, kind (the foliage placer 1 to 8), double; FR-FOLIAGE USING state, feature row, attachment index, foliage height, leaf radius.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TREE-ROW.
*> USING state, centre x, y, z, radius, dy, kind (TR-FKIND), double (0 or 1): placeLeavesRow (section 5.1) at layer y + dy for dx and dz from -radius to radius (+ 1 with a double trunk, whose
*> absolute offsets fold to the nearer of the two trunk columns), with the skip test of the placer (5.2). Blob skips a corner (ax and az equal the radius) when nextInt(2) is 0 (drawn at every
*> such position, before the dy = 0 test) or dy is 0; spruce and pine skip a corner of a radius above 0; acacia at dy = 0 keeps the cross and the inner 3 x 3 square, else skips the corners; fancy
*> skips a cell outside the ellipse (ax + 1/2)^2 + (az + 1/2)^2 > radius^2; jungle and mega pine skip ax + az >= 7 and ax^2 + az^2 > radius^2; dark oak skips the corners at dy = -1 (single trunk),
*> the signed corners at dy = 0 (double trunk) and ax + az > 2 radius - 2 at dy = 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-SKIP                BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-S1                  BINARY-LONG.
 01 WS-S2                  BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-DBL                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-X L-Y L-Z L-RADIUS L-DY L-KIND L-DBL.
     COMPUTE WS-LO = 0 - L-RADIUS
     COMPUTE WS-HI = L-RADIUS + L-DBL
     COMPUTE WS-PY = L-Y + L-DY
     PERFORM VARYING WS-DX FROM WS-LO BY 1 UNTIL WS-DX > WS-HI
         PERFORM VARYING WS-DZ FROM WS-LO BY 1 UNTIL WS-DZ > WS-HI
             COMPUTE WS-AX = FUNCTION ABS(WS-DX)
             COMPUTE WS-AZ = FUNCTION ABS(WS-DZ)
             IF L-DBL = 1
                 COMPUTE WS-AX = FUNCTION MIN(FUNCTION ABS(WS-DX), FUNCTION ABS(WS-DX - 1))
                 COMPUTE WS-AZ = FUNCTION MIN(FUNCTION ABS(WS-DZ), FUNCTION ABS(WS-DZ - 1))
             END-IF
             MOVE 0 TO WS-SKIP
             EVALUATE L-KIND
                 WHEN 1
                     IF WS-AX = L-RADIUS AND WS-AZ = L-RADIUS
                         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-TWO WS-DRAW
                         IF WS-DRAW = 0 OR L-DY = 0
                             MOVE 1 TO WS-SKIP
                         END-IF
                     END-IF
                 WHEN 2
                 WHEN 3
                     IF WS-AX = L-RADIUS AND WS-AZ = L-RADIUS AND L-RADIUS > 0
                         MOVE 1 TO WS-SKIP
                     END-IF
                 WHEN 9
                     IF WS-AX = L-RADIUS AND WS-AZ = L-RADIUS
                         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-TWO WS-DRAW
                         IF WS-DRAW = 0
                             MOVE 1 TO WS-SKIP
                         END-IF
                     END-IF
                 WHEN 4
                     IF L-DY = 0
                         IF (WS-AX > 1 OR WS-AZ > 1) AND WS-AX NOT = 0 AND WS-AZ NOT = 0
                             MOVE 1 TO WS-SKIP
                         END-IF
                     ELSE
                         IF WS-AX = L-RADIUS AND WS-AZ = L-RADIUS AND L-RADIUS > 0
                             MOVE 1 TO WS-SKIP
                         END-IF
                     END-IF
                 WHEN 5
                     COMPUTE WS-S1 = (2 * WS-AX + 1) * (2 * WS-AX + 1) + (2 * WS-AZ + 1) * (2 * WS-AZ + 1)
                     COMPUTE WS-S2 = 4 * L-RADIUS * L-RADIUS
                     IF WS-S1 > WS-S2
                         MOVE 1 TO WS-SKIP
                     END-IF
                 WHEN 6
                 WHEN 7
                     COMPUTE WS-S1 = WS-AX * WS-AX + WS-AZ * WS-AZ
                     COMPUTE WS-S2 = L-RADIUS * L-RADIUS
                     IF WS-AX + WS-AZ >= 7 OR WS-S1 > WS-S2
                         MOVE 1 TO WS-SKIP
                     END-IF
                 WHEN 8
                     EVALUATE L-DY
                         WHEN -1
                             IF L-DBL = 0 AND WS-AX = L-RADIUS AND WS-AZ = L-RADIUS
                                 MOVE 1 TO WS-SKIP
                             END-IF
                         WHEN 0
                             IF L-DBL = 1 AND (WS-DX = WS-LO OR WS-DX >= L-RADIUS) AND (WS-DZ = WS-LO OR WS-DZ >= L-RADIUS)
                                 MOVE 1 TO WS-SKIP
                             END-IF
                         WHEN 1
                             COMPUTE WS-S2 = L-RADIUS * 2 - 2
                             IF WS-AX + WS-AZ > WS-S2
                                 MOVE 1 TO WS-SKIP
                             END-IF
                     END-EVALUATE
             END-EVALUATE
             IF WS-SKIP = 0
                 COMPUTE WS-PX = L-X + WS-DX
                 COMPUTE WS-PZ = L-Z + WS-DZ
                 CALL "FR-TREE-LEAF" USING WS-PX WS-PY WS-PZ
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FR-TREE-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-FOLIAGE.
*> USING state, feature row, attachment index, foliage height FH, leaf radius: createFoliage (section 5.2) of the foliage placer of the row around the attachment.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY TREEWORK.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-AR                  BINARY-LONG.
 01 WS-AD                  BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-OFF                 BINARY-LONG.
 01 WS-YY                  BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-RAD                 BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-HH                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-PREV                BINARY-LONG.
 01 WS-USE                 BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-FL                  BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-ATT                  BINARY-LONG.
 01 L-FH                   BINARY-LONG.
 01 L-LR                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-ATT L-FH L-LR.
     MOVE TW-ATT-X(L-ATT) TO WS-AX
     MOVE TW-ATT-Y(L-ATT) TO WS-AY
     MOVE TW-ATT-Z(L-ATT) TO WS-AZ
     MOVE TW-ATT-R(L-ATT) TO WS-AR
     MOVE TW-ATT-D(L-ATT) TO WS-AD
     MOVE TR-FKIND(L-ROW) TO WS-KIND
     CALL "FR-INT-SAMPLE" USING L-STATE TR-OFF(L-ROW) WS-OFF
     EVALUATE WS-KIND
         WHEN 1
*>           blob: rows y = off down to off - FH, radius LR + rO - 1 - y / 2 (toward zero)
             COMPUTE WS-END = WS-OFF - L-FH
             PERFORM VARYING WS-YY FROM WS-OFF BY -1 UNTIL WS-YY < WS-END
                 COMPUTE WS-HALF = WS-YY / 2
                 COMPUTE WS-RAD = FUNCTION MAX(L-LR + WS-AR - 1 - WS-HALF, 0)
                 CALL "FR-TREE-ROW" USING L-STATE WS-AX WS-AY WS-AZ WS-RAD WS-YY WS-KIND WS-AD
             END-PERFORM
         WHEN 2
*>           spruce: a first radius of nextInt(2), then the radii 1 2 ... cycling as the placer's counters say
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-TWO WS-RAD
             MOVE 1 TO WS-HI
             MOVE 0 TO WS-LOW
             COMPUTE WS-END = 0 - L-FH
             PERFORM VARYING WS-YY FROM WS-OFF BY -1 UNTIL WS-YY < WS-END
                 CALL "FR-TREE-ROW" USING L-STATE WS-AX WS-AY WS-AZ WS-RAD WS-YY WS-KIND WS-AD
                 IF WS-RAD >= WS-HI
                     MOVE WS-LOW TO WS-RAD
                     MOVE 1 TO WS-LOW
                     COMPUTE WS-HI = FUNCTION MIN(WS-HI + 1, L-LR + WS-AR)
                 ELSE
                     ADD 1 TO WS-RAD
                 END-IF
             END-PERFORM
         WHEN 3
*>           pine: radius 0 growing to LR + rO, one smaller on the second to last row
             MOVE 0 TO WS-RAD
             COMPUTE WS-END = WS-OFF - L-FH
             PERFORM VARYING WS-YY FROM WS-OFF BY -1 UNTIL WS-YY < WS-END
                 CALL "FR-TREE-ROW" USING L-STATE WS-AX WS-AY WS-AZ WS-RAD WS-YY WS-KIND WS-AD
                 COMPUTE WS-HALF = WS-END + 1
                 IF WS-RAD >= 1 AND WS-YY = WS-HALF
                     SUBTRACT 1 FROM WS-RAD
                 ELSE
                     IF WS-RAD < L-LR + WS-AR
                         ADD 1 TO WS-RAD
                     END-IF
                 END-IF
             END-PERFORM
         WHEN 4
*>           acacia: the centre is the attachment raised by the offset; rows (LR + rO, -1 - FH), (LR - 1, -FH), (LR + rO - 1, 0)
             COMPUTE WS-CY = WS-AY + WS-OFF
             COMPUTE WS-RAD = L-LR + WS-AR
             COMPUTE WS-YY = -1 - L-FH
             CALL "FR-TREE-ROW" USING L-STATE WS-AX WS-CY WS-AZ WS-RAD WS-YY WS-KIND WS-AD
             COMPUTE WS-RAD = L-LR - 1
             COMPUTE WS-YY = 0 - L-FH
             CALL "FR-TREE-ROW" USING L-STATE WS-AX WS-CY WS-AZ WS-RAD WS-YY WS-KIND WS-AD
             COMPUTE WS-RAD = L-LR + WS-AR - 1
             MOVE 0 TO WS-YY
             CALL "FR-TREE-ROW" USING L-STATE WS-AX WS-CY WS-AZ WS-RAD WS-YY WS-KIND WS-AD
         WHEN 5
*>           fancy: rows y = off down to off - FH of radius LR, one wider between the first and the last
             COMPUTE WS-END = WS-OFF - L-FH
             PERFORM VARYING WS-YY FROM WS-OFF BY -1 UNTIL WS-YY < WS-END
                 MOVE L-LR TO WS-RAD
                 IF WS-YY NOT = WS-OFF AND WS-YY NOT = WS-END
                     ADD 1 TO WS-RAD
                 END-IF
                 CALL "FR-TREE-ROW" USING L-STATE WS-AX WS-AY WS-AZ WS-RAD WS-YY WS-KIND WS-AD
             END-PERFORM
         WHEN 6
*>           jungle: FH rows for a double trunk, else 1 + nextInt(2); the radius grows downwards: LR + rO + 1 - y
             MOVE L-FH TO WS-HH
             IF WS-AD = 0
                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-TWO WS-DRAW
                 COMPUTE WS-HH = 1 + WS-DRAW
             END-IF
             COMPUTE WS-END = WS-OFF - WS-HH
             PERFORM VARYING WS-YY FROM WS-OFF BY -1 UNTIL WS-YY < WS-END
                 COMPUTE WS-RAD = L-LR + WS-AR + 1 - WS-YY
                 CALL "FR-TREE-ROW" USING L-STATE WS-AX WS-AY WS-AZ WS-RAD WS-YY WS-KIND WS-AD
             END-PERFORM
         WHEN 7
*>           mega pine: one row per layer from the attachment - FH + off up to the attachment + off, radius LR + rO + floor(d / FH * 3.5) (float arithmetic), one wider on an even layer
*>           when the radius equals that of the row below
             MOVE FUNCTION MAX(L-FH, 1) TO WS-HH
             MOVE 0 TO WS-PREV
             COMPUTE WS-YY = WS-AY - WS-HH + WS-OFF
             COMPUTE WS-END = WS-AY + WS-OFF
             PERFORM UNTIL WS-YY > WS-END
                 COMPUTE WS-D = WS-AY - WS-YY
                 COMPUTE WS-F = WS-D / WS-HH
                 CALL "FR-F32" USING WS-F
                 COMPUTE WS-F = WS-F * 3.5
                 CALL "FR-F32" USING WS-F
                 COMPUTE WS-FL = FUNCTION INTEGER(WS-F)
                 COMPUTE WS-RAD = L-LR + WS-AR + WS-FL
                 MOVE WS-RAD TO WS-USE
                 IF WS-D > 0 AND WS-RAD = WS-PREV AND FUNCTION MOD(WS-YY, 2) = 0
                     COMPUTE WS-USE = WS-RAD + 1
                 END-IF
                 MOVE 0 TO WS-DRAW
                 CALL "FR-TREE-ROW" USING L-STATE WS-AX WS-YY WS-AZ WS-USE WS-DRAW WS-KIND WS-AD
                 MOVE WS-RAD TO WS-PREV
                 ADD 1 TO WS-YY
             END-PERFORM
         WHEN 9
*>           bush: the blob rows without the halving: radius LR + rO - 1 - y, a corner skipped on a coin toss
             COMPUTE WS-END = WS-OFF - L-FH
             PERFORM VARYING WS-YY FROM WS-OFF BY -1 UNTIL WS-YY < WS-END
                 COMPUTE WS-RAD = L-LR + WS-AR - 1 - WS-YY
                 CALL "FR-TREE-ROW" USING L-STATE WS-AX WS-AY WS-AZ WS-RAD WS-YY WS-KIND WS-AD
             END-PERFORM
         WHEN 10
             CALL "FR-SPREAD" USING L-STATE L-ROW L-ATT L-FH L-LR
         WHEN 11
             CALL "FR-CHERRY-FOLIAGE" USING L-STATE L-ROW L-ATT L-FH L-LR WS-OFF
         WHEN OTHER
*>           dark oak: rows (LR + 2, -1), (LR + 3, 0), (LR + 2, 1) and, on a coin toss, (LR, 2) for a double trunk; (LR + 2, -1) and (LR + 1, 0) for a single one
             COMPUTE WS-CY = WS-AY + WS-OFF
             COMPUTE WS-RAD = L-LR + 2
             MOVE -1 TO WS-YY
             CALL "FR-TREE-ROW" USING L-STATE WS-AX WS-CY WS-AZ WS-RAD WS-YY WS-KIND WS-AD
             IF WS-AD = 1
                 COMPUTE WS-RAD = L-LR + 3
                 MOVE 0 TO WS-YY
                 CALL "FR-TREE-ROW" USING L-STATE WS-AX WS-CY WS-AZ WS-RAD WS-YY WS-KIND WS-AD
                 COMPUTE WS-RAD = L-LR + 2
                 MOVE 1 TO WS-YY
                 CALL "FR-TREE-ROW" USING L-STATE WS-AX WS-CY WS-AZ WS-RAD WS-YY WS-KIND WS-AD
                 CALL "F351-NEXT-BOOLEAN" USING L-STATE WS-DRAW
                 IF WS-DRAW = 1
                     MOVE L-LR TO WS-RAD
                     MOVE 2 TO WS-YY
                     CALL "FR-TREE-ROW" USING L-STATE WS-AX WS-CY WS-AZ WS-RAD WS-YY WS-KIND WS-AD
                 END-IF
             ELSE
                 COMPUTE WS-RAD = L-LR + 1
                 MOVE 0 TO WS-YY
                 CALL "FR-TREE-ROW" USING L-STATE WS-AX WS-CY WS-AZ WS-RAD WS-YY WS-KIND WS-AD
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM FR-FOLIAGE.
