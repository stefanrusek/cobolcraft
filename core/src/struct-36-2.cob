*> Structure templates, part 1 (docs/protocol/36-structures-2 sections 3 and 4): the coordinate transform of a template-local block position
*> (mirror about the origin, then rotation about the pivot), the size and bounding box of a placed template, the zero position and the choice of
*> the palette. Mirror codes: 0 NONE, 1 LEFT_RIGHT (z -> -z), 2 FRONT_BACK (x -> -x). Rotation codes in the doc's declaration order: 0 NONE,
*> 1 CLOCKWISE_90, 2 CLOCKWISE_180, 3 COUNTERCLOCKWISE_90.
*>
*> Entry points:
*>   STRUCT-TX-POS USING x, y, z, mirror, rotation, pivot x, pivot z, x out, y out, z out (all BINARY-LONG): section 3.1
*>   STRUCT-TX-SIZE USING size x, y, z, rotation, x out, y out, z out: getSize(rotation), x and z swapped for a quarter turn (3.3)
*>   STRUCT-TX-BOX USING size x, y, z, mirror, rotation, pivot x, pivot z, origin x, y, z, box (6 BINARY-LONG: min x y z, max x y z): getBoundingBox (3.3)
*>   STRUCT-ZERO-POS USING pos x, y, z, mirror, rotation, size x, size z, x out, y out, z out: getZeroPositionWithTransform (3.3)
*>   STRUCT-PALETTE-PICK USING palette count, origin x, y, z, index out: getRandomPalette without a shared random (4.2, 4.3); -1 for no palettes

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-TX-POS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-MIRROR               BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-PX                   BINARY-LONG.
 01 L-PZ                   BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-MIRROR L-ROT L-PX L-PZ L-OX L-OY L-OZ.
     MOVE L-X TO WS-X
     MOVE L-Z TO WS-Z
     EVALUATE L-MIRROR
         WHEN 1
             COMPUTE WS-Z = 0 - WS-Z
         WHEN 2
             COMPUTE WS-X = 0 - WS-X
     END-EVALUATE
     MOVE L-Y TO L-OY
     EVALUATE L-ROT
         WHEN 1
             COMPUTE L-OX = L-PX + L-PZ - WS-Z
             COMPUTE L-OZ = L-PZ - L-PX + WS-X
         WHEN 2
             COMPUTE L-OX = 2 * L-PX - WS-X
             COMPUTE L-OZ = 2 * L-PZ - WS-Z
         WHEN 3
             COMPUTE L-OX = L-PX - L-PZ + WS-Z
             COMPUTE L-OZ = L-PX + L-PZ - WS-X
         WHEN OTHER
             MOVE WS-X TO L-OX
             MOVE WS-Z TO L-OZ
     END-EVALUATE
     GOBACK.
 END PROGRAM STRUCT-TX-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-TX-SIZE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SX L-SY L-SZ L-ROT L-OX L-OY L-OZ.
     MOVE L-SY TO L-OY
     IF L-ROT = 1 OR L-ROT = 3
         MOVE L-SZ TO L-OX
         MOVE L-SX TO L-OZ
     ELSE
         MOVE L-SX TO L-OX
         MOVE L-SZ TO L-OZ
     END-IF
     GOBACK.
 END PROGRAM STRUCT-TX-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-TX-BOX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ZERO-X              BINARY-LONG VALUE 0.
 01 WS-ZERO-Y              BINARY-LONG VALUE 0.
 01 WS-ZERO-Z              BINARY-LONG VALUE 0.
 01 WS-LAST-X              BINARY-LONG.
 01 WS-LAST-Y              BINARY-LONG.
 01 WS-LAST-Z              BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-MIRROR               BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-PX                   BINARY-LONG.
 01 L-PZ                   BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-BOX.
    05 L-BOX-V             BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING L-SX L-SY L-SZ L-MIRROR L-ROT L-PX L-PZ L-OX L-OY L-OZ L-BOX.
     COMPUTE WS-LAST-X = L-SX - 1
     COMPUTE WS-LAST-Y = L-SY - 1
     COMPUTE WS-LAST-Z = L-SZ - 1
     CALL "STRUCT-TX-POS" USING WS-ZERO-X WS-ZERO-Y WS-ZERO-Z L-MIRROR L-ROT L-PX L-PZ WS-AX WS-AY WS-AZ
     CALL "STRUCT-TX-POS" USING WS-LAST-X WS-LAST-Y WS-LAST-Z L-MIRROR L-ROT L-PX L-PZ WS-BX WS-BY WS-BZ
     COMPUTE L-BOX-V(1) = FUNCTION MIN(WS-AX, WS-BX) + L-OX
     COMPUTE L-BOX-V(2) = FUNCTION MIN(WS-AY, WS-BY) + L-OY
     COMPUTE L-BOX-V(3) = FUNCTION MIN(WS-AZ, WS-BZ) + L-OZ
     COMPUTE L-BOX-V(4) = FUNCTION MAX(WS-AX, WS-BX) + L-OX
     COMPUTE L-BOX-V(5) = FUNCTION MAX(WS-AY, WS-BY) + L-OY
     COMPUTE L-BOX-V(6) = FUNCTION MAX(WS-AZ, WS-BZ) + L-OZ
     GOBACK.
 END PROGRAM STRUCT-TX-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-ZERO-POS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-MIRROR               BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-SIZE-X               BINARY-LONG.
 01 L-SIZE-Z               BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-MIRROR L-ROT L-SIZE-X L-SIZE-Z L-OX L-OY L-OZ.
     COMPUTE WS-SX = L-SIZE-X - 1
     COMPUTE WS-SZ = L-SIZE-Z - 1
     MOVE 0 TO WS-DX
     MOVE 0 TO WS-DZ
     IF L-MIRROR = 2
         MOVE WS-SX TO WS-DX
     END-IF
     IF L-MIRROR = 1
         MOVE WS-SZ TO WS-DZ
     END-IF
     MOVE L-Y TO L-OY
     EVALUATE L-ROT
         WHEN 1
             COMPUTE L-OX = L-X + WS-SZ - WS-DZ
             COMPUTE L-OZ = L-Z + WS-DX
         WHEN 2
             COMPUTE L-OX = L-X + WS-SX - WS-DX
             COMPUTE L-OZ = L-Z + WS-SZ - WS-DZ
         WHEN 3
             COMPUTE L-OX = L-X + WS-DZ
             COMPUTE L-OZ = L-Z + WS-SX - WS-DX
         WHEN OTHER
             COMPUTE L-OX = L-X + WS-DX
             COMPUTE L-OZ = L-Z + WS-DZ
     END-EVALUATE
     GOBACK.
 END PROGRAM STRUCT-ZERO-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-PALETTE-PICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-X L-Y L-Z L-INDEX.
     IF L-COUNT < 1
         MOVE -1 TO L-INDEX
         GOBACK
     END-IF
     CALL "XORO-GET-SEED" USING L-X L-Y L-Z WS-SEED
     COMPUTE WS-USEED = FUNCTION MOD(WS-SEED + WS-M64, WS-M64)
     CALL "JRAND-SET-SEED" USING WS-STATE WS-USEED
     CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE L-COUNT L-INDEX
     GOBACK.
 END PROGRAM STRUCT-PALETTE-PICK.
