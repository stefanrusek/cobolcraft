*> Structure pieces (docs/protocol/36-structures-1-model-placement-starts.md sections 5.6, 6.2 to 6.4 and 6.6; STRUCTPIECE.cpy, STRUCTBOX.cpy): the BoundingBox, the piece-local frame
*> and the pieces builder of the start being built. Directions are the 2D data values of 6.7 (0 south, 1 west, 2 north, 3 east, -1 none); any other direction takes the south row
*> of orientBox, as the document says of up and down. A box is six BINARY-LONG (STRUCTBOX.cpy).
*>
*> Entry points:
*>   SPB-BOX-NEW USING x0 y0 z0 x1 y1 z1, box out: the constructor (a malformed box takes the per-axis min and max)
*>   SPB-BOX-INTERSECTS USING box, box, flag out (3-D); SPB-BOX-INTERSECTS-XZ the same on x and z only; SPB-BOX-INSIDE USING box, x, y, z, flag out
*>   SPB-BOX-CENTER USING box, x out, y out, z out; SPB-BOX-INFLATE USING box, n (in place); SPB-BOX-MOVE USING box, dx, dy, dz (in place); SPB-BOX-UNION USING box, box, out (encapsulate)
*>   SPB-ORIENT-BOX USING x y z, offx offy offz, width height depth, direction, box out (orientBox); SPB-MAKE-BOX USING x y z, direction, width height depth, box out (makeBoundingBox)
*>   SPB-WORLD USING row, local x y z, world x y z out (getWorldX, getWorldY, getWorldZ of the piece row); SPB-DIR-XFORM USING row, direction, direction out (mirror then rotation of the piece)
*>   SPB-RESET (an empty builder); SPB-ADD USING type, orientation, depth, mineshaft type, box, row out (0 when the table is full: counted in SP-LOST)
*>   SPB-FIND-COLLISION USING box, row out (0 none, else the first piece in list order whose box intersects); SPB-OFFSET USING dy (offsetPiecesVertically)
*>   SPB-UNION-ALL USING box out (the union of the piece boxes); SPB-MOVE-BELOW-SEA USING sea level, min y, offset, dy out (moveBelowSeaLevel, one draw of SP-RNG when there is slack)
*>   SPB-IS-CLOSE USING row, chunk x, chunk z, margin, flag out (isCloseToChunk)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPB-BOX-NEW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 01 L-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 PROCEDURE DIVISION USING L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1 L-BOX.
     COMPUTE B-X0 = FUNCTION MIN(L-X0, L-X1)
     COMPUTE B-X1 = FUNCTION MAX(L-X0, L-X1)
     COMPUTE B-Y0 = FUNCTION MIN(L-Y0, L-Y1)
     COMPUTE B-Y1 = FUNCTION MAX(L-Y0, L-Y1)
     COMPUTE B-Z0 = FUNCTION MIN(L-Z0, L-Z1)
     COMPUTE B-Z1 = FUNCTION MAX(L-Z0, L-Z1)
     GOBACK.
 END PROGRAM SPB-BOX-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPB-BOX-INTERSECTS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==A-==.
 01 L-B.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-FLAG.
     MOVE 0 TO L-FLAG
     IF A-X1 >= B-X0 AND A-X0 <= B-X1 AND A-Y1 >= B-Y0 AND A-Y0 <= B-Y1 AND A-Z1 >= B-Z0 AND A-Z0 <= B-Z1
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM SPB-BOX-INTERSECTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPB-BOX-INTERSECTS-XZ.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==A-==.
 01 L-B.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-FLAG.
     MOVE 0 TO L-FLAG
     IF A-X1 >= B-X0 AND A-X0 <= B-X1 AND A-Z1 >= B-Z0 AND A-Z0 <= B-Z1
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM SPB-BOX-INTERSECTS-XZ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPB-BOX-INSIDE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-BOX L-X L-Y L-Z L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-X >= B-X0 AND L-X <= B-X1 AND L-Y >= B-Y0 AND L-Y <= B-Y1 AND L-Z >= B-Z0 AND L-Z <= B-Z1
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM SPB-BOX-INSIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPB-BOX-CENTER.
*> getCenter: per axis min + (max - min + 1) / 2, integer division (the span is positive).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SPAN                BINARY-LONG.
 LINKAGE SECTION.
 01 L-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-BOX L-X L-Y L-Z.
     COMPUTE WS-SPAN = B-X1 - B-X0 + 1
     COMPUTE L-X = B-X0 + FUNCTION INTEGER(WS-SPAN / 2)
     COMPUTE WS-SPAN = B-Y1 - B-Y0 + 1
     COMPUTE L-Y = B-Y0 + FUNCTION INTEGER(WS-SPAN / 2)
     COMPUTE WS-SPAN = B-Z1 - B-Z0 + 1
     COMPUTE L-Z = B-Z0 + FUNCTION INTEGER(WS-SPAN / 2)
     GOBACK.
 END PROGRAM SPB-BOX-CENTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPB-BOX-INFLATE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING L-BOX L-N.
     SUBTRACT L-N FROM B-X0 B-Y0 B-Z0
     ADD L-N TO B-X1 B-Y1 B-Z1
     GOBACK.
 END PROGRAM SPB-BOX-INFLATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPB-BOX-MOVE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-BOX L-DX L-DY L-DZ.
     ADD L-DX TO B-X0 B-X1
     ADD L-DY TO B-Y0 B-Y1
     ADD L-DZ TO B-Z0 B-Z1
     GOBACK.
 END PROGRAM SPB-BOX-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPB-BOX-UNION.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-A.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==A-==.
 01 L-B.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 L-OUT.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==O-==.
 PROCEDURE DIVISION USING L-A L-B L-OUT.
     COMPUTE O-X0 = FUNCTION MIN(A-X0, B-X0)
     COMPUTE O-Y0 = FUNCTION MIN(A-Y0, B-Y0)
     COMPUTE O-Z0 = FUNCTION MIN(A-Z0, B-Z0)
     COMPUTE O-X1 = FUNCTION MAX(A-X1, B-X1)
     COMPUTE O-Y1 = FUNCTION MAX(A-Y1, B-Y1)
     COMPUTE O-Z1 = FUNCTION MAX(A-Z1, B-Z1)
     GOBACK.
 END PROGRAM SPB-BOX-UNION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPB-ORIENT-BOX.
*> orientBox (6.3): minY = y + offY and maxY = y + height - 1 + offY for every direction; the x and z extents by the table (south, and any direction not west, north or east, is the first row).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OFF-X                BINARY-LONG.
 01 L-OFF-Y                BINARY-LONG.
 01 L-OFF-Z                BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-DEPTH                BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-OFF-X L-OFF-Y L-OFF-Z L-WIDTH L-HEIGHT L-DEPTH L-DIR L-BOX.
     COMPUTE B-Y0 = L-Y + L-OFF-Y
     COMPUTE B-Y1 = L-Y + L-HEIGHT - 1 + L-OFF-Y
     EVALUATE L-DIR
         WHEN 2
             COMPUTE B-X0 = L-X + L-OFF-X
             COMPUTE B-X1 = L-X + L-WIDTH - 1 + L-OFF-X
             COMPUTE B-Z0 = L-Z - L-DEPTH + 1 + L-OFF-Z
             COMPUTE B-Z1 = L-Z + L-OFF-Z
         WHEN 1
             COMPUTE B-X0 = L-X - L-DEPTH + 1 + L-OFF-Z
             COMPUTE B-X1 = L-X + L-OFF-Z
             COMPUTE B-Z0 = L-Z + L-OFF-X
             COMPUTE B-Z1 = L-Z + L-WIDTH - 1 + L-OFF-X
         WHEN 3
             COMPUTE B-X0 = L-X + L-OFF-Z
             COMPUTE B-X1 = L-X + L-DEPTH - 1 + L-OFF-Z
             COMPUTE B-Z0 = L-Z + L-OFF-X
             COMPUTE B-Z1 = L-Z + L-WIDTH - 1 + L-OFF-X
         WHEN OTHER
             COMPUTE B-X0 = L-X + L-OFF-X
             COMPUTE B-X1 = L-X + L-WIDTH - 1 + L-OFF-X
             COMPUTE B-Z0 = L-Z + L-OFF-Z
             COMPUTE B-Z1 = L-Z + L-DEPTH - 1 + L-OFF-Z
     END-EVALUATE
     GOBACK.
 END PROGRAM SPB-ORIENT-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPB-MAKE-BOX.
*> makeBoundingBox (6.3): the axis of north and south is z (width along x, depth along z), any other direction swaps them.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-DEPTH                BINARY-LONG.
 01 L-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-DIR L-WIDTH L-HEIGHT L-DEPTH L-BOX.
     MOVE L-X TO B-X0
     MOVE L-Y TO B-Y0
     MOVE L-Z TO B-Z0
     COMPUTE B-Y1 = L-Y + L-HEIGHT - 1
     IF L-DIR = 0 OR L-DIR = 2
         COMPUTE B-X1 = L-X + L-WIDTH - 1
         COMPUTE B-Z1 = L-Z + L-DEPTH - 1
     ELSE
         COMPUTE B-X1 = L-X + L-DEPTH - 1
         COMPUTE B-Z1 = L-Z + L-WIDTH - 1
     END-IF
     GOBACK.
 END PROGRAM SPB-MAKE-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPB-WORLD.
*> getWorldX, getWorldY, getWorldZ (6.4) of the piece in row L-ROW for a piece-local position; no orientation means the local position is already absolute.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-WX                   BINARY-LONG.
 01 L-WY                   BINARY-LONG.
 01 L-WZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-WX L-WY L-WZ.
     EVALUATE SP-ORIENT(L-ROW)
         WHEN 2
             COMPUTE L-WX = SP-X0(L-ROW) + L-X
             COMPUTE L-WZ = SP-Z1(L-ROW) - L-Z
         WHEN 0
             COMPUTE L-WX = SP-X0(L-ROW) + L-X
             COMPUTE L-WZ = SP-Z0(L-ROW) + L-Z
         WHEN 1
             COMPUTE L-WX = SP-X1(L-ROW) - L-Z
             COMPUTE L-WZ = SP-Z0(L-ROW) + L-X
         WHEN 3
             COMPUTE L-WX = SP-X0(L-ROW) + L-Z
             COMPUTE L-WZ = SP-Z0(L-ROW) + L-X
         WHEN OTHER
             MOVE L-X TO L-WX
             MOVE L-Z TO L-WZ
     END-EVALUATE
     IF SP-ORIENT(L-ROW) < 0
         MOVE L-Y TO L-WY
     ELSE
         COMPUTE L-WY = SP-Y0(L-ROW) + L-Y
     END-IF
     GOBACK.
 END PROGRAM SPB-WORLD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPB-DIR-XFORM.
*> The mirror and the rotation setOrientation derives (6.4: north none; south left-right; west left-right and clockwise 90; east clockwise 90; none or other: none), applied to a horizontal
*> direction in the order of 6.5 (mirror first, then rotate). Left-right swaps north and south; clockwise 90 is south to west to north to east to south in data values (d + 1 mod 4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-D                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DIR L-OUT.
     MOVE L-DIR TO WS-D
     IF SP-ORIENT(L-ROW) = 0 OR SP-ORIENT(L-ROW) = 1
         EVALUATE WS-D
             WHEN 0
                 MOVE 2 TO WS-D
             WHEN 2
                 MOVE 0 TO WS-D
         END-EVALUATE
     END-IF
     IF SP-ORIENT(L-ROW) = 1 OR SP-ORIENT(L-ROW) = 3
         COMPUTE WS-D = FUNCTION MOD(WS-D + 1, 4)
     END-IF
     MOVE WS-D TO L-OUT
     GOBACK.
 END PROGRAM SPB-DIR-XFORM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPB-RESET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 PROCEDURE DIVISION.
     MOVE 0 TO SP-COUNT SP-LOST SP-ENT-COUNT
     GOBACK.
 END PROGRAM SPB-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPB-ADD.
*> addPiece: appends a piece (fields not given are 0); a full table drops the piece and counts it, the caller then treats the attempt as a failed one.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-ORIENT               BINARY-LONG.
 01 L-DEPTH                BINARY-LONG.
 01 L-MST                  BINARY-LONG.
 01 L-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-ORIENT L-DEPTH L-MST L-BOX L-ROW.
     MOVE 0 TO L-ROW
     IF SP-COUNT >= SP-MAX
         ADD 1 TO SP-LOST
         GOBACK
     END-IF
     ADD 1 TO SP-COUNT
     MOVE SP-COUNT TO L-ROW
     INITIALIZE SP-PIECE(L-ROW)
     MOVE L-TYPE TO SP-TYPE(L-ROW)
     MOVE L-ORIENT TO SP-ORIENT(L-ROW)
     MOVE L-DEPTH TO SP-DEPTH(L-ROW)
     MOVE L-MST TO SP-MST(L-ROW)
     MOVE B-X0 TO SP-X0(L-ROW)
     MOVE B-Y0 TO SP-Y0(L-ROW)
     MOVE B-Z0 TO SP-Z0(L-ROW)
     MOVE B-X1 TO SP-X1(L-ROW)
     MOVE B-Y1 TO SP-Y1(L-ROW)
     MOVE B-Z1 TO SP-Z1(L-ROW)
     GOBACK.
 END PROGRAM SPB-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPB-FIND-COLLISION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-I                   BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 LINKAGE SECTION.
 01 L-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-BOX L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-COUNT OR L-ROW > 0
         CALL "SPB-BOX-INTERSECTS" USING SP-BOX(WS-I) L-BOX WS-FLAG
         IF WS-FLAG = 1
             MOVE WS-I TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SPB-FIND-COLLISION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPB-OFFSET.
*> offsetPiecesVertically: every piece box (and the entrance boxes of a room, whose move moves them too, 36-5 2.5) by dy.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DY.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-COUNT
         ADD L-DY TO SP-Y0(WS-I) SP-Y1(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-ENT-COUNT
         ADD L-DY TO SE-Y0(WS-I) SE-Y1(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM SPB-OFFSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPB-UNION-ALL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-I                   BINARY-LONG.
 01 WS-TMP.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==T-==.
 LINKAGE SECTION.
 01 L-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 PROCEDURE DIVISION USING L-BOX.
     MOVE SP-BOX(1) TO L-BOX
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > SP-COUNT
         MOVE L-BOX TO WS-TMP
         CALL "SPB-BOX-UNION" USING WS-TMP SP-BOX(WS-I) L-BOX
     END-PERFORM
     GOBACK.
 END PROGRAM SPB-UNION-ALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPB-MOVE-BELOW-SEA.
*> moveBelowSeaLevel (6.6): cap = sea - offset; top = ySpan + minY + 1; if top < cap then top += nextInt(cap - top); dy = top - box.maxY; every piece by dy.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==W-==.
 01 WS-CAP                 BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-SLACK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SEA                  BINARY-LONG.
 01 L-MIN-Y                BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SEA L-MIN-Y L-OFFSET L-DY.
     CALL "SPB-UNION-ALL" USING WS-BOX
     COMPUTE WS-CAP = L-SEA - L-OFFSET
     COMPUTE WS-TOP = W-Y1 - W-Y0 + 1 + L-MIN-Y + 1
     IF WS-TOP < WS-CAP
         COMPUTE WS-SLACK = WS-CAP - WS-TOP
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-SLACK WS-DRAW
         ADD WS-DRAW TO WS-TOP
     END-IF
     COMPUTE L-DY = WS-TOP - W-Y1
     CALL "SPB-OFFSET" USING L-DY
     GOBACK.
 END PROGRAM SPB-MOVE-BELOW-SEA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPB-IS-CLOSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-AREA.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==W-==.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-MARGIN               BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-CX L-CZ L-MARGIN L-FLAG.
     COMPUTE W-X0 = L-CX * 16 - L-MARGIN
     COMPUTE W-Z0 = L-CZ * 16 - L-MARGIN
     COMPUTE W-X1 = L-CX * 16 + 15 + L-MARGIN
     COMPUTE W-Z1 = L-CZ * 16 + 15 + L-MARGIN
     MOVE 0 TO W-Y0
     MOVE 0 TO W-Y1
     CALL "SPB-BOX-INTERSECTS-XZ" USING SP-BOX(L-ROW) WS-AREA L-FLAG
     GOBACK.
 END PROGRAM SPB-IS-CLOSE.
