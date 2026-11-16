*> The forest rock feature (docs/protocol/35-worldgen-features-5-water-and-surface.md section 6; registry id 1, block_blob): FD-BLOB-NODE compiles the configuration into a row of FD-WA (WA-I(1) the
*> state to write, WA-PR(1) the can_place_on predicate), FR-BLOB places it: the origin walks down while its y is above minY + 3 until the block below satisfies the predicate (false at minY + 3 or
*> lower), then three blobs: rx, ry, rz = nextInt(2) each, every cell of the box of those radii whose squared distance to the origin is at most f * f, f = (rx + ry + rz) * 0.333f + 0.5f, takes the
*> state (flag 3), then the origin moves by (-1 + nextInt(2), -nextInt(2), -1 + nextInt(2)). The radii are 0 or 1, so the sum is 0 to 3 and f * f is 0.25, 0.69, 1.36 or 2.25: the integer
*> limit of the squared distance is 0, 0, 1 or 2 (the table below; no float rounding can matter, the values are far from integers).
*>
*> Entry points: FD-BLOB-NODE USING doc, node, row out (FD-BAD set when the state or the predicate cannot be compiled); FR-BLOB USING state, feature, x, y, z, result out.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-BLOB-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     MOVE 0 TO L-ROW
     IF FD-WA-COUNT >= FD-MAX-WA
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     ADD 1 TO FD-WA-COUNT
     MOVE FD-WA-COUNT TO WS-ROW
     INITIALIZE FD-WA(WS-ROW)
     MOVE WS-ROW TO L-ROW
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-STATE WS-E
     CALL "FD-J-STATE" USING JSON-DOC WS-E WA-I(WS-ROW, 1) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-CAN-PLACE-ON WS-E
     CALL "FD-PRED-NODE" USING JSON-DOC WS-E WA-PR(WS-ROW, 1)
     GOBACK.
 END PROGRAM FD-BLOB-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-BLOB.
*> USING state, feature, x, y, z, result out (1 when the blobs were placed).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PRED                BINARY-LONG.
 01 WS-POS-X               BINARY-LONG.
 01 WS-POS-Y               BINARY-LONG.
 01 WS-POS-Z               BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-TEST                BINARY-LONG.
 01 WS-LIMIT-Y             BINARY-LONG.
 01 WS-BOUND               BINARY-LONG VALUE 2.
 01 WS-RX                  BINARY-LONG.
 01 WS-RY                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-WRITTEN             BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-LIMITS-VALUES.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 2.
 01 WS-LIMITS REDEFINES WS-LIMITS-VALUES.
    05 WS-LIM              BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-RESULT.
     MOVE 0 TO L-RESULT
     MOVE FT-A(L-FT) TO WS-ROW
     MOVE WA-PR(WS-ROW, 1) TO WS-PRED
     MOVE L-X TO WS-POS-X
     MOVE L-Y TO WS-POS-Y
     MOVE L-Z TO WS-POS-Z
     COMPUTE WS-LIMIT-Y = FL-MIN-Y + 3
     MOVE 0 TO WS-TEST
     PERFORM UNTIL WS-POS-Y <= WS-LIMIT-Y OR WS-TEST = 1
         COMPUTE WS-BELOW = WS-POS-Y - 1
         CALL "FR-PRED-TEST" USING WS-PRED WS-POS-X WS-BELOW WS-POS-Z WS-TEST
         IF WS-TEST = 0
             MOVE WS-BELOW TO WS-POS-Y
         END-IF
     END-PERFORM
     IF WS-POS-Y <= WS-LIMIT-Y
         GOBACK
     END-IF
     PERFORM VARYING WS-PASS FROM 1 BY 1 UNTIL WS-PASS > 3
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-RX
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-RY
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-RZ
         COMPUTE WS-DRAW = WS-RX + WS-RY + WS-RZ + 1
         MOVE WS-LIM(WS-DRAW) TO WS-LIMIT
         COMPUTE WS-LX = WS-POS-X - WS-RX
         COMPUTE WS-LY = WS-POS-Y - WS-RY
         COMPUTE WS-LZ = WS-POS-Z - WS-RZ
         PERFORM VARYING WS-Z FROM WS-LZ BY 1 UNTIL WS-Z > WS-POS-Z + WS-RZ
             PERFORM VARYING WS-Y FROM WS-LY BY 1 UNTIL WS-Y > WS-POS-Y + WS-RY
                 PERFORM VARYING WS-X FROM WS-LX BY 1 UNTIL WS-X > WS-POS-X + WS-RX
                     COMPUTE WS-DX = WS-X - WS-POS-X
                     COMPUTE WS-DY = WS-Y - WS-POS-Y
                     COMPUTE WS-DZ = WS-Z - WS-POS-Z
                     IF WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ <= WS-LIMIT
                         CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WA-I(WS-ROW, 1) WS-FLAGS WS-WRITTEN
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DRAW
         COMPUTE WS-POS-X = WS-POS-X - 1 + WS-DRAW
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DRAW
         COMPUTE WS-POS-Y = WS-POS-Y - WS-DRAW
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DRAW
         COMPUTE WS-POS-Z = WS-POS-Z - 1 + WS-DRAW
     END-PERFORM
     MOVE 1 TO L-RESULT
     GOBACK.
 END PROGRAM FR-BLOB.
