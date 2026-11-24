*> Acceptance test of docs/protocol/34-entity-models-1-shared-model-and-framework.md section 1 (Model conventions): 1.1 units and the model height,
*> 1.3 the cuboid unwrap with the worked examples V1 to V3 (rectangles, vertex order, mirror, deformation, texture scale, face set), 1.4 the builder
*> state, 1.5 pose helpers, the transform order and the draw rule, 1.6 the part names. Expected values are the document's tables worked by hand.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-1-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLEM1.
 COPY TESTLIB.
 01 WS-NAME                PIC X(120).
 01 WS-E                   FLOAT-LONG.
 01 WS-O                   FLOAT-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-FORM                BINARY-LONG.
 01 WS-ARGS.
    05 WS-A                FLOAT-LONG OCCURS 14 TIMES.
 01 WS-PIN.
    05 WS-PI               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-POUT.
    05 WS-PO               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-HY                 FLOAT-LONG.
 01 WS-HS                 FLOAT-LONG.
 01 WS-OP                  BINARY-LONG.
 01 WS-POSE2.
    05 WS-P2               FLOAT-LONG OCCURS 9 TIMES.
 01 EM1-BUILDER.
    05 BU-U                FLOAT-LONG.
    05 BU-V                FLOAT-LONG.
    05 BU-MIRROR           BINARY-LONG.
 01 WS-NAMEIN              PIC X(24).
 01 WS-KNOWN               BINARY-LONG.
 01 WS-DRAWN               BINARY-LONG.
 01 WS-VIS                 BINARY-LONG.
 01 WS-CUB                 BINARY-LONG.
 01 WS-CHL                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 PROCEDURE DIVISION.
*> V1: humanoid head, 64 x 64.
     MOVE "V1 head" TO WS-NAME
     PERFORM HEAD-CUBE
     CALL "EM1-CUBE" USING EM1-CUBE-IN EM1-CUBE-OUT
     MOVE 6 TO WS-E
     MOVE EF-COUNT TO WS-O
     MOVE "faces drawn" TO WS-NAME
     PERFORM CHECK-NUM
     MOVE "creation order" TO WS-NAME
     COMPUTE WS-O = EF-DIR(1) * 100000 + EF-DIR(2) * 10000 + EF-DIR(3) * 1000 + EF-DIR(4) * 100 + EF-DIR(5) * 10 + EF-DIR(6)
     MOVE 123456 TO WS-E
     PERFORM CHECK-NUM
     MOVE 1 TO WS-F
     PERFORM CHECK-RECT-NUMS-V1
     MOVE "V1 NORTH vertex 0 B" TO WS-NAME
     PERFORM CHECK-V1-NORTH
     MOVE "V1 normals" TO WS-NAME
     COMPUTE WS-O = EF-NY(1) * 1000 + EF-NY(2) * 100 + EF-NX(3) * 10 + EF-NZ(4) * 1 + EF-NX(5) * 10000 + EF-NZ(6) * 100000
     MOVE -1 TO WS-E
     COMPUTE WS-E = -1 * 1000 + 100 - 10 - 1 + 10000 + 100000
     PERFORM CHECK-NUM
*> V2: mirror, offset (32, 48), origin (-1, -2, -2), size 4 x 12 x 4.
     MOVE 32 TO EC-U
     MOVE 48 TO EC-V
     MOVE -1 TO EC-OX
     MOVE -2 TO EC-OY
     MOVE -2 TO EC-OZ
     MOVE 4 TO EC-W
     MOVE 12 TO EC-H
     MOVE 4 TO EC-D
     MOVE 0 TO EC-GX EC-GY EC-GZ
     MOVE 1 TO EC-SU EC-SV
     MOVE 64 TO EC-TEXW EC-TEXH
     MOVE 1 TO EC-MIRROR
     MOVE 63 TO EC-FACES
     CALL "EM1-CUBE" USING EM1-CUBE-IN EM1-CUBE-OUT
     MOVE "V2 NORTH rect" TO WS-NAME
     COMPUTE WS-O = EF-MINU(4) * 1000000 + EF-MINV(4) * 10000 + EF-MAXU(4) * 100 + EF-MAXV(4)
     COMPUTE WS-E = 36 * 1000000 + 52 * 10000 + 40 * 100 + 64
     PERFORM CHECK-NUM
     MOVE "V2 EAST rect" TO WS-NAME
     COMPUTE WS-O = EF-MINU(5) * 1000000 + EF-MINV(5) * 10000 + EF-MAXU(5) * 100 + EF-MAXV(5)
     COMPUTE WS-E = 40 * 1000000 + 52 * 10000 + 44 * 100 + 64
     PERFORM CHECK-NUM
     MOVE "V2 SOUTH rect" TO WS-NAME
     COMPUTE WS-O = EF-MINU(6) * 1000000 + EF-MINV(6) * 10000 + EF-MAXU(6) * 100 + EF-MAXV(6)
     COMPUTE WS-E = 44 * 1000000 + 52 * 10000 + 48 * 100 + 64
     PERFORM CHECK-NUM
     MOVE "V2 WEST rect" TO WS-NAME
     COMPUTE WS-O = EF-MINU(3) * 1000000 + EF-MINV(3) * 10000 + EF-MAXU(3) * 100 + EF-MAXV(3)
     COMPUTE WS-E = 32 * 1000000 + 52 * 10000 + 36 * 100 + 64
     PERFORM CHECK-NUM
     MOVE "V2 DOWN rect" TO WS-NAME
     COMPUTE WS-O = EF-MINU(1) * 1000000 + EF-MINV(1) * 10000 + EF-MAXU(1) * 100 + EF-MAXV(1)
     COMPUTE WS-E = 36 * 1000000 + 48 * 10000 + 40 * 100 + 52
     PERFORM CHECK-NUM
     MOVE "V2 UP rect read upward" TO WS-NAME
     COMPUTE WS-O = EF-MINU(2) * 1000000 + EF-MINV(2) * 10000 + EF-MAXU(2) * 100 + EF-MAXV(2)
     COMPUTE WS-E = 40 * 1000000 + 52 * 10000 + 44 * 100 + 48
     PERFORM CHECK-NUM
*>   mirrored: x0 = 3, x1 = -1 (swapped); the vertex order is reversed; WEST and EAST normals exchange.
     MOVE "V2 NORTH vertex 1 is D mirrored" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE EF-X(4, 2) TO WS-O
     PERFORM CHECK-NUM
     MOVE -1 TO WS-E
     MOVE "V2 NORTH vertex 3 is B mirrored x" TO WS-NAME
     MOVE EF-X(4, 4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "V2 WEST normal exchanged" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE EF-NX(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "V2 EAST normal exchanged" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE EF-NX(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "V2 NORTH normal unchanged" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE EF-NZ(4) TO WS-O
     PERFORM CHECK-NUM
*>   the texture rectangles do not move: vertex 0 of NORTH after reversal carries (minU, maxV).
     MOVE "V2 NORTH reversed vertex u" TO WS-NAME
     COMPUTE WS-E = 40 / 64
     MOVE EF-TU(4, 1) TO WS-O
     PERFORM CHECK-NUM
*> V3: deformation 0.5.
     PERFORM HEAD-CUBE
     MOVE 0.5 TO EC-GX EC-GY EC-GZ
     CALL "EM1-CUBE" USING EM1-CUBE-IN EM1-CUBE-OUT
     MOVE "V3 corner A grown" TO WS-NAME
     COMPUTE WS-O = EF-X(4, 2) * 10000 + EF-Y(4, 2) * 100 + EF-Z(4, 2)
     COMPUTE WS-E = -4.5 * 10000 + -8.5 * 100 + -4.5
     PERFORM CHECK-NUM
     MOVE "V3 corner G grown" TO WS-NAME
     COMPUTE WS-O = EF-X(6, 3) * 10000 + EF-Y(6, 3) * 100 + EF-Z(6, 3)
     COMPUTE WS-E = 4.5 * 10000 + 0.5 * 100 + 4.5
     PERFORM CHECK-NUM
     MOVE "V3 rectangles unchanged" TO WS-NAME
     COMPUTE WS-O = EF-MINU(4) * 10000 + EF-MINV(4) * 100 + EF-MAXU(4) + EF-MAXV(4) * 0.001
     COMPUTE WS-E = 8 * 10000 + 8 * 100 + 16 + 16 * 0.001
     PERFORM CHECK-NUM
*> Face set: only NORTH and SOUTH; texture scale 2 divides by W x 2 and H x 2.
     PERFORM HEAD-CUBE
     MOVE 40 TO EC-FACES
     MOVE 2 TO EC-SU EC-SV
     CALL "EM1-CUBE" USING EM1-CUBE-IN EM1-CUBE-OUT
     MOVE "face set count" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE EF-COUNT TO WS-O
     PERFORM CHECK-NUM
     MOVE "face set directions" TO WS-NAME
     COMPUTE WS-O = EF-DIR(1) * 10 + EF-DIR(2)
     MOVE 46 TO WS-E
     PERFORM CHECK-NUM
     MOVE "texture scale divisor" TO WS-NAME
     COMPUTE WS-E = 16 / 128
     MOVE EF-TU(1, 1) TO WS-O
     PERFORM CHECK-NUM
*> The offset is truncated.
     PERFORM HEAD-CUBE
     MOVE 8.9 TO EC-U
     MOVE 8.9 TO EC-V
     CALL "EM1-CUBE" USING EM1-CUBE-IN EM1-CUBE-OUT
     MOVE "offset truncated" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE EF-MINU(1) TO WS-O
     COMPUTE WS-E = 16 + 8
     COMPUTE WS-O = EF-MINU(1) + EF-MINV(1)
     PERFORM CHECK-NUM
*> Strip rule for unequal sides (U3 differs from U4): w 2, h 3, d 5 at (0, 0).
     MOVE 0 TO EC-U EC-V
     MOVE 2 TO EC-W
     MOVE 3 TO EC-H
     MOVE 5 TO EC-D
     MOVE 0 TO EC-GX EC-GY EC-GZ
     MOVE 1 TO EC-SU EC-SV
     MOVE 63 TO EC-FACES
     CALL "EM1-CUBE" USING EM1-CUBE-IN EM1-CUBE-OUT
     MOVE "unequal UP maxU is U3 and SOUTH minU is U4" TO WS-NAME
     COMPUTE WS-O = EF-MAXU(2) * 100 + EF-MINU(6)
     COMPUTE WS-E = 9 * 100 + 12
     PERFORM CHECK-NUM
*> 1.1 height of a model point: 1.501 - y/16 blocks, times the entity scale.
     MOVE 24 TO WS-HY
     MOVE 1 TO WS-HS
     CALL "EM1-HEIGHT" USING WS-HY WS-HS WS-PO(1)
     MOVE "feet at 24 are 0.001 above" TO WS-NAME
     MOVE 0.001 TO WS-E
     MOVE WS-PO(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-HY
     MOVE 2 TO WS-HS
     CALL "EM1-HEIGHT" USING WS-HY WS-HS WS-PO(1)
     MOVE "top of the model scaled by two" TO WS-NAME
     MOVE 3.002 TO WS-E
     MOVE WS-PO(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 180 TO WS-PI(1)
     CALL "EM1-RADIANS" USING WS-PI(1) WS-PO(1)
     MOVE "degrees to radians constant" TO WS-NAME
     COMPUTE WS-E = 180 * 0.017453292
     MOVE WS-PO(1) TO WS-O
     PERFORM CHECK-NUM
*> 1.4 builder: offsets and mirror stay in force; a per-box mirror does not change the builder; the int form sets the offset.
     MOVE 0 TO BU-U BU-V BU-MIRROR
     MOVE 1 TO WS-FORM
     MOVE 0 TO WS-A(1) WS-A(2) WS-A(3)
     MOVE 4 TO WS-A(4) WS-A(5) WS-A(6)
     CALL "EM1-ADDBOX" USING EM1-BUILDER WS-FORM WS-ARGS EM1-CUBE-IN
     MOVE "default form: no deformation, scale 1, all faces" TO WS-NAME
     COMPUTE WS-O = EC-GX + EC-SU * 10 + EC-FACES * 100 + EC-MIRROR * 100000
     COMPUTE WS-E = 0 + 10 + 6300
     PERFORM CHECK-NUM
     MOVE 3 TO WS-FORM
     MOVE 1 TO WS-A(12)
     CALL "EM1-ADDBOX" USING EM1-BUILDER WS-FORM WS-ARGS EM1-CUBE-IN
     MOVE "mirror override applies to the box" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE EC-MIRROR TO WS-O
     PERFORM CHECK-NUM
     MOVE "mirror override leaves the builder" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE BU-MIRROR TO WS-O
     PERFORM CHECK-NUM
     MOVE 6 TO WS-FORM
     MOVE 16 TO WS-A(13)
     MOVE 32 TO WS-A(14)
     CALL "EM1-ADDBOX" USING EM1-BUILDER WS-FORM WS-ARGS EM1-CUBE-IN
     MOVE "integer form sets the builder offset" TO WS-NAME
     COMPUTE WS-E = 16 * 100 + 32
     COMPUTE WS-O = BU-U * 100 + BU-V
     PERFORM CHECK-NUM
     MOVE "integer form box uses the offset" TO WS-NAME
     COMPUTE WS-O = EC-U * 100 + EC-V
     PERFORM CHECK-NUM
     MOVE 2 TO WS-FORM
     MOVE 0.25 TO WS-A(7) WS-A(8) WS-A(9)
     CALL "EM1-ADDBOX" USING EM1-BUILDER WS-FORM WS-ARGS EM1-CUBE-IN
     MOVE "deformation form" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE EC-GY TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-FORM
     MOVE 2 TO WS-A(10) WS-A(11)
     CALL "EM1-ADDBOX" USING EM1-BUILDER WS-FORM WS-ARGS EM1-CUBE-IN
     MOVE "texture scale form" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE EC-SV TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-FORM
     MOVE 9 TO WS-A(12)
     CALL "EM1-ADDBOX" USING EM1-BUILDER WS-FORM WS-ARGS EM1-CUBE-IN
     MOVE "face set form" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE EC-FACES TO WS-O
     PERFORM CHECK-NUM
*> 1.5 pose helpers: translated adds to position; scaled multiplies position and scale; withScale replaces scale.
     MOVE 2 TO EP-X
     MOVE 4 TO EP-Y
     MOVE 6 TO EP-Z
     MOVE 0.5 TO EP-XROT
     MOVE 0.6 TO EP-YROT
     MOVE 0.7 TO EP-ZROT
     MOVE 1 TO EP-XSCALE EP-YSCALE EP-ZSCALE
     MOVE 1 TO WS-OP
     MOVE 1 TO WS-PI(1)
     MOVE 2 TO WS-PI(2)
     MOVE 3 TO WS-PI(3)
     CALL "EM1-POSE-OP" USING WS-OP EM1-POSE WS-PIN WS-POSE2
     MOVE "translated position" TO WS-NAME
     COMPUTE WS-O = WS-P2(1) * 10000 + WS-P2(2) * 100 + WS-P2(3)
     COMPUTE WS-E = 3 * 10000 + 6 * 100 + 9
     PERFORM CHECK-NUM
     MOVE "translated keeps rotation and scale" TO WS-NAME
     COMPUTE WS-O = WS-P2(5) * 10 + WS-P2(7)
     COMPUTE WS-E = 0.6 * 10 + 1
     PERFORM CHECK-NUM
     MOVE 3 TO WS-OP
     MOVE 2 TO WS-PI(1)
     MOVE 3 TO WS-PI(2)
     MOVE 4 TO WS-PI(3)
     CALL "EM1-POSE-OP" USING WS-OP EM1-POSE WS-PIN WS-POSE2
     MOVE "scaled three factors multiplies position and scale" TO WS-NAME
     COMPUTE WS-O = WS-P2(1) * 10000 + WS-P2(2) * 100 + WS-P2(3) + WS-P2(7) * 0.1 + WS-P2(8) * 0.01 + WS-P2(9) * 0.001
     COMPUTE WS-E = 4 * 10000 + 12 * 100 + 24 + 2 * 0.1 + 3 * 0.01 + 4 * 0.001
     PERFORM CHECK-NUM
     MOVE "scaled keeps rotation" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-P2(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-OP
     MOVE 1 TO WS-PI(1)
     CALL "EM1-POSE-OP" USING WS-OP EM1-POSE WS-PIN WS-POSE2
     MOVE "scaled(1) returns the same pose" TO WS-NAME
     COMPUTE WS-O = WS-P2(1) * 100 + WS-P2(8)
     COMPUTE WS-E = 2 * 100 + 1
     PERFORM CHECK-NUM
     MOVE 2 TO WS-OP
     MOVE 0.5 TO WS-PI(1)
     CALL "EM1-POSE-OP" USING WS-OP EM1-POSE WS-PIN WS-POSE2
     MOVE "scaled(0.5) multiplies position and scale, not rotation" TO WS-NAME
     COMPUTE WS-O = WS-P2(1) * 10000 + WS-P2(3) * 100 + WS-P2(7) * 10 + WS-P2(5)
     COMPUTE WS-E = 1 * 10000 + 3 * 100 + 5 + 0.6
     PERFORM CHECK-NUM
     MOVE 4 TO WS-OP
     MOVE 0.5 TO WS-PI(1)
     CALL "EM1-POSE-OP" USING WS-OP EM1-POSE WS-PIN WS-POSE2
     MOVE "withScale replaces scale only" TO WS-NAME
     COMPUTE WS-O = WS-P2(1) * 100 + WS-P2(7) * 10 + WS-P2(9)
     COMPUTE WS-E = 2 * 100 + 5 + 0.5
     PERFORM CHECK-NUM
*> Transform order: scale, rotate (Z-Y-X), translate, all divided by 16 (a point at pixels).
     MOVE 16 TO EP-X
     MOVE 0 TO EP-Y EP-Z EP-XROT EP-YROT
     COMPUTE EP-ZROT = 3.141592653589793 / 2
     MOVE 2 TO EP-XSCALE
     MOVE 1 TO EP-YSCALE EP-ZSCALE
     MOVE 16 TO WS-PI(1)
     MOVE 0 TO WS-PI(2) WS-PI(3)
     CALL "EM1-POINT" USING EM1-POSE WS-PIN WS-POUT
     MOVE "scale x2 then rotate z 90 then translate 16px" TO WS-NAME
     COMPUTE WS-O = WS-PO(1) * 10000 + WS-PO(2) * 100 + WS-PO(3)
     COMPUTE WS-E = 1.0 * 10000 + 2.0 * 100 + 0
     PERFORM CHECK-NUM
*>   rotation stacks z last on the vector: rotate (1, 0, 0) with x 90 and y 90: X first leaves it, Y then sends x to -z.
     MOVE 0 TO EP-X EP-Y EP-Z EP-ZROT
     COMPUTE EP-XROT = 3.141592653589793 / 2
     COMPUTE EP-YROT = 3.141592653589793 / 2
     MOVE 1 TO EP-XSCALE
     MOVE 16 TO WS-PI(1)
     CALL "EM1-POINT" USING EM1-POSE WS-PIN WS-POUT
     MOVE "rotationZYX acts X first" TO WS-NAME
     COMPUTE WS-O = WS-PO(1) * 10000 + WS-PO(2) * 100 + WS-PO(3)
     COMPUTE WS-E = 0 * 10000 + 0 * 100 + -1
     PERFORM CHECK-NUM
*> Draw rule: invisible parts draw nothing, empty parts without children draw nothing, skipDraw hides the cuboids only.
     MOVE 1 TO WS-VIS WS-CUB WS-CHL
     CALL "EM1-DRAWS" USING WS-VIS WS-CUB WS-CHL WS-DRAWN
     MOVE "visible part with cuboids draws" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-DRAWN TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-VIS
     CALL "EM1-DRAWS" USING WS-VIS WS-CUB WS-CHL WS-DRAWN
     MOVE "invisible part draws nothing with children" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-DRAWN TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-VIS
     MOVE 0 TO WS-CUB WS-CHL
     CALL "EM1-DRAWS" USING WS-VIS WS-CUB WS-CHL WS-DRAWN
     MOVE "empty part draws nothing" TO WS-NAME
     MOVE WS-DRAWN TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-CHL
     CALL "EM1-DRAWS" USING WS-VIS WS-CUB WS-CHL WS-DRAWN
     MOVE "part with children only is walked" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-DRAWN TO WS-O
     PERFORM CHECK-NUM
*> 1.6 part names.
     MOVE "left_front_leg_tip" TO WS-NAMEIN
     CALL "EM1-PART-NAME" USING WS-NAMEIN WS-KNOWN
     MOVE "known name" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-KNOWN TO WS-O
     PERFORM CHECK-NUM
     MOVE "blue_first" TO WS-NAMEIN
     CALL "EM1-PART-NAME" USING WS-NAMEIN WS-KNOWN
     MOVE "blue coral first has the short string" TO WS-NAME
     MOVE WS-KNOWN TO WS-O
     PERFORM CHECK-NUM
     MOVE "blue_coral_first" TO WS-NAMEIN
     CALL "EM1-PART-NAME" USING WS-NAMEIN WS-KNOWN
     MOVE "blue_coral_first is not a constant" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-KNOWN TO WS-O
     PERFORM CHECK-NUM
     MOVE "wing" TO WS-NAMEIN
     CALL "EM1-PART-NAME" USING WS-NAMEIN WS-KNOWN
     MOVE "unknown name" TO WS-NAME
     MOVE WS-KNOWN TO WS-O
     PERFORM CHECK-NUM
     CALL "EM1-PART-NAME-COUNT" USING WS-COUNT
     MOVE "name table size (106 names of 1.6)" TO WS-NAME
     MOVE 106 TO WS-E
     MOVE WS-COUNT TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 HEAD-CUBE.
     MOVE 0 TO EC-U EC-V
     MOVE -4 TO EC-OX EC-OY EC-OZ
     MOVE -8 TO EC-OY
     MOVE 8 TO EC-W EC-H EC-D
     MOVE 0 TO EC-GX EC-GY EC-GZ
     MOVE 1 TO EC-SU EC-SV
     MOVE 64 TO EC-TEXW EC-TEXH
     MOVE 0 TO EC-MIRROR
     MOVE 63 TO EC-FACES.

 CHECK-RECT-NUMS-V1.
     MOVE "V1 DOWN rect" TO WS-NAME
     COMPUTE WS-O = EF-MINU(1) * 1000000 + EF-MINV(1) * 10000 + EF-MAXU(1) * 100 + EF-MAXV(1)
     COMPUTE WS-E = 8 * 1000000 + 0 * 10000 + 16 * 100 + 8
     PERFORM CHECK-NUM
     MOVE "V1 UP rect read upward" TO WS-NAME
     COMPUTE WS-O = EF-MINU(2) * 1000000 + EF-MINV(2) * 10000 + EF-MAXU(2) * 100 + EF-MAXV(2)
     COMPUTE WS-E = 16 * 1000000 + 8 * 10000 + 24 * 100 + 0
     PERFORM CHECK-NUM
     MOVE "V1 WEST rect" TO WS-NAME
     COMPUTE WS-O = EF-MINU(3) * 1000000 + EF-MINV(3) * 10000 + EF-MAXU(3) * 100 + EF-MAXV(3)
     COMPUTE WS-E = 0 * 1000000 + 8 * 10000 + 8 * 100 + 16
     PERFORM CHECK-NUM
     MOVE "V1 NORTH rect" TO WS-NAME
     COMPUTE WS-O = EF-MINU(4) * 1000000 + EF-MINV(4) * 10000 + EF-MAXU(4) * 100 + EF-MAXV(4)
     COMPUTE WS-E = 8 * 1000000 + 8 * 10000 + 16 * 100 + 16
     PERFORM CHECK-NUM
     MOVE "V1 EAST rect" TO WS-NAME
     COMPUTE WS-O = EF-MINU(5) * 1000000 + EF-MINV(5) * 10000 + EF-MAXU(5) * 100 + EF-MAXV(5)
     COMPUTE WS-E = 16 * 1000000 + 8 * 10000 + 24 * 100 + 16
     PERFORM CHECK-NUM
     MOVE "V1 SOUTH rect" TO WS-NAME
     COMPUTE WS-O = EF-MINU(6) * 1000000 + EF-MINV(6) * 10000 + EF-MAXU(6) * 100 + EF-MAXV(6)
     COMPUTE WS-E = 24 * 1000000 + 8 * 10000 + 32 * 100 + 16
     PERFORM CHECK-NUM.

 CHECK-V1-NORTH.
*>   B, A, D, C with the texture values of the worked example.
     COMPUTE WS-O = EF-X(4, 1) * 10000 + EF-Y(4, 1) * 100 + EF-Z(4, 1) + EF-TU(4, 1) * 0.001 + EF-TV(4, 1) * 0.0001
     COMPUTE WS-E = 4 * 10000 + -8 * 100 + -4 + 0.25 * 0.001 + 0.125 * 0.0001
     PERFORM CHECK-NUM
     MOVE "V1 NORTH vertex 1 A" TO WS-NAME
     COMPUTE WS-O = EF-X(4, 2) * 10000 + EF-Y(4, 2) * 100 + EF-Z(4, 2) + EF-TU(4, 2) * 0.001 + EF-TV(4, 2) * 0.0001
     COMPUTE WS-E = -4 * 10000 + -8 * 100 + -4 + 0.125 * 0.001 + 0.125 * 0.0001
     PERFORM CHECK-NUM
     MOVE "V1 NORTH vertex 2 D" TO WS-NAME
     COMPUTE WS-O = EF-X(4, 3) * 10000 + EF-Y(4, 3) * 100 + EF-Z(4, 3) + EF-TU(4, 3) * 0.001 + EF-TV(4, 3) * 0.0001
     COMPUTE WS-E = -4 * 10000 + 0 * 100 + -4 + 0.125 * 0.001 + 0.25 * 0.0001
     PERFORM CHECK-NUM
     MOVE "V1 NORTH vertex 3 C" TO WS-NAME
     COMPUTE WS-O = EF-X(4, 4) * 10000 + EF-Y(4, 4) * 100 + EF-Z(4, 4) + EF-TU(4, 4) * 0.001 + EF-TV(4, 4) * 0.0001
     COMPUTE WS-E = 4 * 10000 + 0 * 100 + -4 + 0.25 * 0.001 + 0.25 * 0.0001
     PERFORM CHECK-NUM.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-1§1 Model conventions: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-1-1.
