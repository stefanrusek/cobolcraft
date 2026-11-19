*> Entity models part 9, sections 10 and 11 item frames and paintings (docs/protocol/34-entity-models-9-non-living-entities.md): the facts of the renderers. The frame's item is placed by
*> item-held.cob ENTITY-FRAME-EMIT (test_entity_frame); these programs state the same rules from the document so that section 10 has its own test.
*>   EF9-FRAME-OFFSET IN(1 stepX, 2 stepZ of the direction) OUT(1 to 3 getRenderOffset: stepX x 0.3, -0.25, stepZ x 0.3);
*>   EF9-FRAME-OPS IN(1 direction: 0 DOWN, 1 UP, 2 NORTH, 3 SOUTH, 4 WEST, 5 EAST, 2 the frame is invisible, 3 rotation, 4 the frame holds a map) OUT(ops: count, then code and three values per op;
*>     1 translate, 2 scale, 3 rotate Y, 5 rotate X, 7 rotate Z degrees): the submit after the render offset is undone: translate by the step x 0.46875, rotate X by xRot, rotate Y by yRot, translate (0, 0, 0.5
*>     invisible or 0.4375), then for a map rotate Z by (rotation mod 4) x 90, rotate Z by 180, scale 1/128, translate (-64, -64, 0) and (0, 0, -1), else for an item rotate Z by rotation x 45 and scale 0.5;
*>   EF9-FRAME-LIGHT IN(1 glow frame, 2 block light) OUT(1 the block light: max(5, block) for a glow frame, 2 the item's light coordinates 15728880 or 0 for the normal light, 3 the map's light 15728850 or 0);
*>   EF9-PAINTING-ROT IN(1 direction as above) OUT(1 the Y rotation 180 - data2D x 90, SOUTH 0, WEST 1, NORTH 2, EAST 3);
*>   EF9-PAINTING-BLOCK IN(1 direction, 2 w, 3 h, 4 i, 5 j, 6 x, 7 y, 8 z of the entity, 9 and 10 the entity's block x and z) OUT(1 to 3 the block position whose light the cell takes): 11 extraction;
*>   EF9-PAINTING-FACE IN(1 w, 2 h, 3 i, 4 j, 5 face 0 front, 1 back, 2 top edge, 3 bottom edge, 4 the edge at x1, 5 the edge at x0) OUT(1 present, 2 to 21 the four vertices as x, y, z, u, v where u and v are
*>     fractions of the front sprite for the front face and of the back sprite for the others).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-FRAME-OFFSET.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(1) * 0.3
     MOVE -0.25 TO L-O(2)
     COMPUTE L-O(3) = L-I(2) * 0.3
     GOBACK.
 END PROGRAM EF9-FRAME-OFFSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-FRAME-OPS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIR                 BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-XROT                FLOAT-LONG.
 01 WS-YROT                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO WS-DIR
     MOVE L-I(3) TO WS-ROT
     MOVE 0 TO WS-SX WS-SY WS-SZ WS-XROT
     MOVE 180 TO WS-YROT
     EVALUATE WS-DIR
         WHEN 0
             MOVE -1 TO WS-SY
             MOVE 90 TO WS-XROT
         WHEN 1
             MOVE 1 TO WS-SY
             MOVE -90 TO WS-XROT
         WHEN 2
             MOVE -1 TO WS-SZ
             MOVE 0 TO WS-YROT
         WHEN 3
             MOVE 1 TO WS-SZ
             MOVE 180 TO WS-YROT
         WHEN 4
             MOVE -1 TO WS-SX
             COMPUTE WS-YROT = 180 - 90
         WHEN OTHER
             MOVE 1 TO WS-SX
             COMPUTE WS-YROT = 180 - 270
     END-EVALUATE
     MOVE 5 TO WS-N
     MOVE 1 TO L-O(2)
     COMPUTE L-O(3) = WS-SX * 0.46875
     COMPUTE L-O(4) = WS-SY * 0.46875
     COMPUTE L-O(5) = WS-SZ * 0.46875
     MOVE 5 TO L-O(6)
     MOVE WS-XROT TO L-O(7)
     MOVE 0 TO L-O(8) L-O(9)
     MOVE 3 TO L-O(10)
     MOVE WS-YROT TO L-O(11)
     MOVE 0 TO L-O(12) L-O(13)
     MOVE 1 TO L-O(14)
     MOVE 0 TO L-O(15) L-O(16)
     MOVE 0.4375 TO L-O(17)
     IF L-I(2) NOT = 0
         MOVE 0.5 TO L-O(17)
     END-IF
     MOVE 4 TO WS-N
     IF L-I(4) NOT = 0
         ADD 1 TO WS-N
         COMPUTE WS-K = WS-N * 4 - 2
         MOVE 7 TO L-O(WS-K)
         COMPUTE L-O(WS-K + 1) = FUNCTION MOD(WS-ROT, 4) * 2 * 360 / 8
         MOVE 0 TO L-O(WS-K + 2) L-O(WS-K + 3)
         ADD 1 TO WS-N
         COMPUTE WS-K = WS-N * 4 - 2
         MOVE 7 TO L-O(WS-K)
         MOVE 180 TO L-O(WS-K + 1)
         MOVE 0 TO L-O(WS-K + 2) L-O(WS-K + 3)
         ADD 1 TO WS-N
         COMPUTE WS-K = WS-N * 4 - 2
         MOVE 2 TO L-O(WS-K)
         COMPUTE L-O(WS-K + 1) = 1 / 128
         MOVE L-O(WS-K + 1) TO L-O(WS-K + 2) L-O(WS-K + 3)
         ADD 1 TO WS-N
         COMPUTE WS-K = WS-N * 4 - 2
         MOVE 1 TO L-O(WS-K)
         MOVE -64 TO L-O(WS-K + 1) L-O(WS-K + 2)
         MOVE 0 TO L-O(WS-K + 3)
         ADD 1 TO WS-N
         COMPUTE WS-K = WS-N * 4 - 2
         MOVE 1 TO L-O(WS-K)
         MOVE 0 TO L-O(WS-K + 1) L-O(WS-K + 2)
         MOVE -1 TO L-O(WS-K + 3)
     ELSE
         ADD 1 TO WS-N
         COMPUTE WS-K = WS-N * 4 - 2
         MOVE 7 TO L-O(WS-K)
         COMPUTE L-O(WS-K + 1) = WS-ROT * 360 / 8
         MOVE 0 TO L-O(WS-K + 2) L-O(WS-K + 3)
         ADD 1 TO WS-N
         COMPUTE WS-K = WS-N * 4 - 2
         MOVE 2 TO L-O(WS-K)
         MOVE 0.5 TO L-O(WS-K + 1) L-O(WS-K + 2) L-O(WS-K + 3)
     END-IF
     MOVE WS-N TO L-O(1)
     GOBACK.
 END PROGRAM EF9-FRAME-OPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-FRAME-LIGHT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(2) TO L-O(1)
     MOVE 0 TO L-O(2) L-O(3)
     IF L-I(1) NOT = 0
         COMPUTE L-O(1) = FUNCTION MAX(5, L-I(2))
         MOVE 15728880 TO L-O(2)
         MOVE 15728850 TO L-O(3)
     END-IF
     GOBACK.
 END PROGRAM EF9-FRAME-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-PAINTING-ROT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     EVALUATE L-I(1)
         WHEN 3
             MOVE 180 TO L-O(1)
         WHEN 4
             MOVE 90 TO L-O(1)
         WHEN 2
             MOVE 0 TO L-O(1)
         WHEN OTHER
             MOVE -90 TO L-O(1)
     END-EVALUATE
     GOBACK.
 END PROGRAM EF9-PAINTING-ROT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-PAINTING-BLOCK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OX                  FLOAT-LONG.
 01 WS-OY                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-OX = (L-I(4) + (0 - L-I(2) / 2)) + 0.5
     COMPUTE WS-OY = (L-I(5) + (0 - L-I(3) / 2)) + 0.5
     COMPUTE L-O(2) = FUNCTION INTEGER(L-I(7) + WS-OY)
     MOVE L-I(9) TO L-O(1)
     MOVE L-I(10) TO L-O(3)
     EVALUATE L-I(1)
         WHEN 2
             COMPUTE L-O(1) = FUNCTION INTEGER(L-I(6) + WS-OX)
         WHEN 4
             COMPUTE L-O(3) = FUNCTION INTEGER(L-I(8) - WS-OX)
         WHEN 3
             COMPUTE L-O(1) = FUNCTION INTEGER(L-I(6) - WS-OX)
         WHEN OTHER
             COMPUTE L-O(3) = FUNCTION INTEGER(L-I(8) + WS-OX)
     END-EVALUATE
     GOBACK.
 END PROGRAM EF9-PAINTING-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-PAINTING-FACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-W                   FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-I                   FLOAT-LONG.
 01 WS-J                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-X1                  FLOAT-LONG.
 01 WS-Y0                  FLOAT-LONG.
 01 WS-Y1                  FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG VALUE 0.03125.
 01 WS-UA                  FLOAT-LONG.
 01 WS-UB                  FLOAT-LONG.
 01 WS-VA                  FLOAT-LONG.
 01 WS-VB                  FLOAT-LONG.
 01 WS-US                  FLOAT-LONG VALUE 0.0625.
 01 WS-VS                  FLOAT-LONG VALUE 0.0625.
 01 WS-V.
    05 WS-VT OCCURS 4 TIMES.
       10 WS-VX            FLOAT-LONG.
       10 WS-VY            FLOAT-LONG.
       10 WS-VZ            FLOAT-LONG.
       10 WS-VU            FLOAT-LONG.
       10 WS-VW            FLOAT-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO WS-W
     MOVE L-I(2) TO WS-H
     MOVE L-I(3) TO WS-I
     MOVE L-I(4) TO WS-J
     COMPUTE WS-X1 = 0 - WS-W / 2 + WS-I + 1
     COMPUTE WS-X0 = 0 - WS-W / 2 + WS-I
     COMPUTE WS-Y1 = 0 - WS-H / 2 + WS-J + 1
     COMPUTE WS-Y0 = 0 - WS-H / 2 + WS-J
     COMPUTE WS-UA = (WS-W - WS-I) / WS-W
     COMPUTE WS-UB = (WS-W - WS-I - 1) / WS-W
     COMPUTE WS-VA = (WS-H - WS-J) / WS-H
     COMPUTE WS-VB = (WS-H - WS-J - 1) / WS-H
     MOVE 1 TO L-O(1)
     EVALUATE L-I(5)
         WHEN 0
             PERFORM SET-FRONT
         WHEN 1
             PERFORM SET-BACK
         WHEN 2
             IF WS-J = WS-H - 1
                 PERFORM SET-TOP
             ELSE
                 MOVE 0 TO L-O(1)
             END-IF
         WHEN 3
             IF WS-J = 0
                 PERFORM SET-BOTTOM
             ELSE
                 MOVE 0 TO L-O(1)
             END-IF
         WHEN 4
             IF WS-I = WS-W - 1
                 PERFORM SET-EDGE-X1
             ELSE
                 MOVE 0 TO L-O(1)
             END-IF
         WHEN OTHER
             IF WS-I = 0
                 PERFORM SET-EDGE-X0
             ELSE
                 MOVE 0 TO L-O(1)
             END-IF
     END-EVALUATE
     IF L-O(1) = 1
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
             COMPUTE WS-B = WS-K * 5 - 3
             MOVE WS-VX(WS-K) TO L-O(WS-B)
             MOVE WS-VY(WS-K) TO L-O(WS-B + 1)
             MOVE WS-VZ(WS-K) TO L-O(WS-B + 2)
             MOVE WS-VU(WS-K) TO L-O(WS-B + 3)
             MOVE WS-VW(WS-K) TO L-O(WS-B + 4)
         END-PERFORM
     END-IF
     GO TO FACE-EXIT.
 SET-FRONT.
     MOVE WS-X1 TO WS-VX(1)
     MOVE WS-Y0 TO WS-VY(1)
     COMPUTE WS-VZ(1) = 0 - WS-Z
     MOVE WS-UB TO WS-VU(1)
     MOVE WS-VA TO WS-VW(1)
     MOVE WS-X0 TO WS-VX(2)
     MOVE WS-Y0 TO WS-VY(2)
     COMPUTE WS-VZ(2) = 0 - WS-Z
     MOVE WS-UA TO WS-VU(2)
     MOVE WS-VA TO WS-VW(2)
     MOVE WS-X0 TO WS-VX(3)
     MOVE WS-Y1 TO WS-VY(3)
     COMPUTE WS-VZ(3) = 0 - WS-Z
     MOVE WS-UA TO WS-VU(3)
     MOVE WS-VB TO WS-VW(3)
     MOVE WS-X1 TO WS-VX(4)
     MOVE WS-Y1 TO WS-VY(4)
     COMPUTE WS-VZ(4) = 0 - WS-Z
     MOVE WS-UB TO WS-VU(4)
     MOVE WS-VB TO WS-VW(4).
 SET-BACK.
     MOVE WS-X1 TO WS-VX(1)
     MOVE WS-Y1 TO WS-VY(1)
     MOVE WS-Z TO WS-VZ(1)
     MOVE 1 TO WS-VU(1)
     MOVE 0 TO WS-VW(1)
     MOVE WS-X0 TO WS-VX(2)
     MOVE WS-Y1 TO WS-VY(2)
     MOVE WS-Z TO WS-VZ(2)
     MOVE 0 TO WS-VU(2) WS-VW(2)
     MOVE WS-X0 TO WS-VX(3)
     MOVE WS-Y0 TO WS-VY(3)
     MOVE WS-Z TO WS-VZ(3)
     MOVE 0 TO WS-VU(3)
     MOVE 1 TO WS-VW(3)
     MOVE WS-X1 TO WS-VX(4)
     MOVE WS-Y0 TO WS-VY(4)
     MOVE WS-Z TO WS-VZ(4)
     MOVE 1 TO WS-VU(4) WS-VW(4).
 SET-TOP.
     MOVE WS-X1 TO WS-VX(1)
     MOVE WS-Y1 TO WS-VY(1)
     COMPUTE WS-VZ(1) = 0 - WS-Z
     MOVE 0 TO WS-VU(1) WS-VW(1)
     MOVE WS-X0 TO WS-VX(2)
     MOVE WS-Y1 TO WS-VY(2)
     COMPUTE WS-VZ(2) = 0 - WS-Z
     MOVE 1 TO WS-VU(2)
     MOVE 0 TO WS-VW(2)
     MOVE WS-X0 TO WS-VX(3)
     MOVE WS-Y1 TO WS-VY(3)
     MOVE WS-Z TO WS-VZ(3)
     MOVE 1 TO WS-VU(3)
     MOVE WS-VS TO WS-VW(3)
     MOVE WS-X1 TO WS-VX(4)
     MOVE WS-Y1 TO WS-VY(4)
     MOVE WS-Z TO WS-VZ(4)
     MOVE 0 TO WS-VU(4)
     MOVE WS-VS TO WS-VW(4).
 SET-BOTTOM.
     MOVE WS-X1 TO WS-VX(1)
     MOVE WS-Y0 TO WS-VY(1)
     MOVE WS-Z TO WS-VZ(1)
     MOVE 0 TO WS-VU(1) WS-VW(1)
     MOVE WS-X0 TO WS-VX(2)
     MOVE WS-Y0 TO WS-VY(2)
     MOVE WS-Z TO WS-VZ(2)
     MOVE 1 TO WS-VU(2)
     MOVE 0 TO WS-VW(2)
     MOVE WS-X0 TO WS-VX(3)
     MOVE WS-Y0 TO WS-VY(3)
     COMPUTE WS-VZ(3) = 0 - WS-Z
     MOVE 1 TO WS-VU(3)
     MOVE WS-VS TO WS-VW(3)
     MOVE WS-X1 TO WS-VX(4)
     MOVE WS-Y0 TO WS-VY(4)
     COMPUTE WS-VZ(4) = 0 - WS-Z
     MOVE 0 TO WS-VU(4)
     MOVE WS-VS TO WS-VW(4).
 SET-EDGE-X1.
     MOVE WS-X1 TO WS-VX(1) WS-VX(2) WS-VX(3) WS-VX(4)
     MOVE WS-Y1 TO WS-VY(1)
     MOVE WS-Z TO WS-VZ(1)
     MOVE WS-US TO WS-VU(1)
     MOVE 0 TO WS-VW(1)
     MOVE WS-Y0 TO WS-VY(2)
     MOVE WS-Z TO WS-VZ(2)
     MOVE WS-US TO WS-VU(2)
     MOVE 1 TO WS-VW(2)
     MOVE WS-Y0 TO WS-VY(3)
     COMPUTE WS-VZ(3) = 0 - WS-Z
     MOVE 0 TO WS-VU(3)
     MOVE 1 TO WS-VW(3)
     MOVE WS-Y1 TO WS-VY(4)
     COMPUTE WS-VZ(4) = 0 - WS-Z
     MOVE 0 TO WS-VU(4) WS-VW(4).
 SET-EDGE-X0.
     MOVE WS-X0 TO WS-VX(1) WS-VX(2) WS-VX(3) WS-VX(4)
     MOVE WS-Y1 TO WS-VY(1)
     COMPUTE WS-VZ(1) = 0 - WS-Z
     MOVE WS-US TO WS-VU(1)
     MOVE 0 TO WS-VW(1)
     MOVE WS-Y0 TO WS-VY(2)
     COMPUTE WS-VZ(2) = 0 - WS-Z
     MOVE WS-US TO WS-VU(2)
     MOVE 1 TO WS-VW(2)
     MOVE WS-Y0 TO WS-VY(3)
     MOVE WS-Z TO WS-VZ(3)
     MOVE 0 TO WS-VU(3)
     MOVE 1 TO WS-VW(3)
     MOVE WS-Y1 TO WS-VY(4)
     MOVE WS-Z TO WS-VZ(4)
     MOVE 0 TO WS-VU(4) WS-VW(4).
 FACE-EXIT.
     CONTINUE.
 END PROGRAM EF9-PAINTING-FACE.
