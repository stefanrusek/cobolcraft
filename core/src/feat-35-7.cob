*> The helpers of the nether, end and miscellaneous features (docs/protocol/35-worldgen-features-7-nether-end-misc.md section 2). betweenClosed (2.1) is F355-BETWEEN (feat-35-5.cob).
*> Entry points:
*>   F357-RANDOM-POS USING state (java.util.Random), minX, minY, minZ, maxX, maxY, maxZ, x, y, z out: one position of randomBetweenClosed (2.2): nextInt(maxX - minX + 1) for x, then y, then z, each
*>     added to its minimum (three draws, taken when the consumer asks, so its own draws sit between two positions)
*>   F357-MANHATTAN-AT USING rx, ry, rz, index (0-based), dx, dy, dz out, found out: the index-th offset of withinBoxByManhattanDistance (2.3): by depth d = |x| + |y| + |z| from 0 up to rx + ry + rz;
*>     inside a depth x ascending over -min(rx, d) to min(rx, d), y ascending over -min(ry, d - |x|) to min(ry, d - |x|), then (x, y, +dz) with dz = d - |x| - |y| when dz <= rz and (x, y, -dz) after
*>     it when dz is not 0; found 0 for an index past the last offset

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F357-RANDOM-POS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-DOUBLE UNSIGNED.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1 L-X L-Y L-Z.
     COMPUTE WS-N = L-X1 - L-X0 + 1
     CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-N WS-D
     COMPUTE L-X = L-X0 + WS-D
     COMPUTE WS-N = L-Y1 - L-Y0 + 1
     CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-N WS-D
     COMPUTE L-Y = L-Y0 + WS-D
     COMPUTE WS-N = L-Z1 - L-Z0 + 1
     CALL "JRAND-NEXT-INT-BOUND" USING L-STATE WS-N WS-D
     COMPUTE L-Z = L-Z0 + WS-D
     GOBACK.
 END PROGRAM F357-RANDOM-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F357-MANHATTAN-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-MAX-DEPTH           BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-LIM-X               BINARY-LONG.
 01 WS-LIM-Y               BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-RX                   BINARY-LONG.
 01 L-RY                   BINARY-LONG.
 01 L-RZ                   BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-RX L-RY L-RZ L-INDEX L-DX L-DY L-DZ L-FOUND.
     MOVE 0 TO L-FOUND L-DX L-DY L-DZ WS-COUNT
     COMPUTE WS-MAX-DEPTH = L-RX + L-RY + L-RZ
     PERFORM VARYING WS-DEPTH FROM 0 BY 1 UNTIL WS-DEPTH > WS-MAX-DEPTH OR L-FOUND = 1
         MOVE FUNCTION MIN(L-RX, WS-DEPTH) TO WS-LIM-X
         COMPUTE WS-X = 0 - WS-LIM-X
         PERFORM UNTIL WS-X > WS-LIM-X OR L-FOUND = 1
             COMPUTE WS-DZ = WS-DEPTH - FUNCTION ABS(WS-X)
             MOVE FUNCTION MIN(L-RY, WS-DZ) TO WS-LIM-Y
             COMPUTE WS-Y = 0 - WS-LIM-Y
             PERFORM UNTIL WS-Y > WS-LIM-Y OR L-FOUND = 1
                 COMPUTE WS-DZ = WS-DEPTH - FUNCTION ABS(WS-X) - FUNCTION ABS(WS-Y)
                 IF WS-DZ <= L-RZ
                     IF WS-COUNT = L-INDEX
                         MOVE 1 TO L-FOUND
                         MOVE WS-X TO L-DX
                         MOVE WS-Y TO L-DY
                         MOVE WS-DZ TO L-DZ
                     END-IF
                     ADD 1 TO WS-COUNT
                     IF WS-DZ NOT = 0 AND L-FOUND = 0
                         IF WS-COUNT = L-INDEX
                             MOVE 1 TO L-FOUND
                             MOVE WS-X TO L-DX
                             MOVE WS-Y TO L-DY
                             COMPUTE L-DZ = 0 - WS-DZ
                         END-IF
                         ADD 1 TO WS-COUNT
                     END-IF
                 END-IF
                 ADD 1 TO WS-Y
             END-PERFORM
             ADD 1 TO WS-X
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM F357-MANHATTAN-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F357-TEMPLATE-ANCHOR.
*> USING rotation (0 NONE, 1 CLOCKWISE_90, 2 CLOCKWISE_180, 3 COUNTERCLOCKWISE_90), size x, size z (the template's unrotated size), dx, dz out: section 11.3 step 3, the offset of the anchor from the origin:
*> unit(rotation.rotate(WEST)) * (size x div 2) + unit(rotation.rotate(NORTH)) * (size z div 2); the y offset is 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-WEST                BINARY-LONG VALUE 4.
 01 WS-NORTH               BINARY-LONG VALUE 2.
 01 WS-DIR                 BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-HALF-X              BINARY-LONG.
 01 WS-HALF-Z              BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROT                  BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROT L-SX L-SZ L-DX L-DZ.
     DIVIDE L-SX BY 2 GIVING WS-HALF-X
     DIVIDE L-SZ BY 2 GIVING WS-HALF-Z
     CALL "F356-ROTATE" USING L-ROT WS-WEST WS-DIR
     CALL "F356-DIR-STEP" USING WS-DIR WS-AX WS-AY WS-AZ
     CALL "F356-ROTATE" USING L-ROT WS-NORTH WS-DIR
     CALL "F356-DIR-STEP" USING WS-DIR WS-BX WS-BY WS-BZ
     COMPUTE L-DX = WS-AX * WS-HALF-X + WS-BX * WS-HALF-Z
     COMPUTE L-DZ = WS-AZ * WS-HALF-X + WS-BZ * WS-HALF-Z
     GOBACK.
 END PROGRAM F357-TEMPLATE-ANCHOR.
