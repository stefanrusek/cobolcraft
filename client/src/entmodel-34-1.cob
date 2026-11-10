*> Entity models part 1 (docs/protocol/34-entity-models-1-shared-model-and-framework.md): the shared model library. Records are in client/copy/CLEM1.cpy.
*> Entry points for the integrator (inputs; floats are FLOAT-LONG):
*>   EM1-CUBE EM1-CUBE-IN EM1-CUBE-OUT: bakes a cuboid into its faces (1.3): EF-COUNT faces in creation order, corners in model pixels, texture
*>     coordinates already divided by the (scaled) texture size.
*>   EM1-ADDBOX builder form args(14 floats) EM1-CUBE-IN: the CubeListBuilder forms of 1.4 (form 1 plain, 2 deformation (args 7-9), 3 mirror override
*>     (arg 12), 4 deformation and texture scale (args 7-11), 5 face set (arg 12), 6 integer form with an explicit offset (args 13, 14: also sets the
*>     builder offset)); args 1-6 are x y z w h d. The builder is BU-U BU-V (floats) BU-MIRROR (binary-long).
*>   EM1-POSE-OP op EM1-POSE args(3 floats) out(9 floats): 1 translated(dx dy dz), 2 scaled(s), 3 scaled(sx sy sz), 4 withScale(s) (1.5).
*>   EM1-POINT EM1-POSE point(3 floats, pixels) out(3 floats, blocks): scale, rotate (Z-Y-X), translate, divided by 16 (1.5).
*>   EM1-HEIGHT y(pixels) scale out: height above the feet in blocks of a model point (1.1). EM1-RADIANS degrees out.
*>   EM1-DRAWS visible has-cuboids has-children out: whether a part is walked (1.5). EM1-PART-NAME name(X(24)) known, EM1-PART-NAME-COUNT n (1.6).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM1-CUBE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
*> Per direction: corner letters of the four vertices, then the indexes (U, V) of the min and max of the rectangle: minU minV maxU maxV.
 01 WS-DIRS.
    05 FILLER PIC X(8) VALUE "FEAB1021".
    05 FILLER PIC X(8) VALUE "CDHG2130".
    05 FILLER PIC X(8) VALUE "AEHD0112".
    05 FILLER PIC X(8) VALUE "BADC1122".
    05 FILLER PIC X(8) VALUE "FBCG2142".
    05 FILLER PIC X(8) VALUE "EFGH4152".
 01 WS-DIRS-R REDEFINES WS-DIRS.
    05 WS-DIR OCCURS 6 TIMES.
       10 WS-CORNERS       PIC X(4).
       10 WS-INDEX         PIC 9 OCCURS 4 TIMES.
 01 WS-NORMALS.
    05 FILLER PIC X(6) VALUE "0-1000".
    05 FILLER PIC X(6) VALUE "010000".
    05 FILLER PIC X(6) VALUE "-10000".
 01 WS-CX                  FLOAT-LONG OCCURS 8 TIMES.
 01 WS-CY                  FLOAT-LONG OCCURS 8 TIMES.
 01 WS-CZ                  FLOAT-LONG OCCURS 8 TIMES.
 01 WS-US                  FLOAT-LONG OCCURS 6 TIMES.
 01 WS-VS                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-X0                  FLOAT-LONG.
 01 WS-X1                  FLOAT-LONG.
 01 WS-Y0                  FLOAT-LONG.
 01 WS-Y1                  FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-Z1                  FLOAT-LONG.
 01 WS-TW                  FLOAT-LONG.
 01 WS-TH                  FLOAT-LONG.
 01 WS-BU                  FLOAT-LONG.
 01 WS-BV                  FLOAT-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-SRC                 BINARY-LONG.
 01 WS-MASK                BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 01 WS-RU0                 FLOAT-LONG.
 01 WS-RV0                 FLOAT-LONG.
 01 WS-RU1                 FLOAT-LONG.
 01 WS-RV1                 FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG OCCURS 4 TIMES.
 01 WS-TY                  FLOAT-LONG OCCURS 4 TIMES.
 01 WS-TZ                  FLOAT-LONG OCCURS 4 TIMES.
 01 WS-TTU                 FLOAT-LONG OCCURS 4 TIMES.
 01 WS-TTV                 FLOAT-LONG OCCURS 4 TIMES.
 01 WS-LETTER              PIC X.
 LINKAGE SECTION.
 COPY CLEM1.
 PROCEDURE DIVISION USING EM1-CUBE-IN EM1-CUBE-OUT.
     COMPUTE WS-BU = FUNCTION INTEGER-PART(EC-U)
     COMPUTE WS-BV = FUNCTION INTEGER-PART(EC-V)
     COMPUTE WS-TW = EC-TEXW * EC-SU
     COMPUTE WS-TH = EC-TEXH * EC-SV
     COMPUTE WS-X0 = EC-OX - EC-GX
     COMPUTE WS-Y0 = EC-OY - EC-GY
     COMPUTE WS-Z0 = EC-OZ - EC-GZ
     COMPUTE WS-X1 = EC-OX + EC-W + EC-GX
     COMPUTE WS-Y1 = EC-OY + EC-H + EC-GY
     COMPUTE WS-Z1 = EC-OZ + EC-D + EC-GZ
     IF EC-MIRROR NOT = 0
         MOVE WS-X0 TO WS-RU0
         MOVE WS-X1 TO WS-X0
         MOVE WS-RU0 TO WS-X1
     END-IF
*>   corners A..H = 1..8
     MOVE WS-X0 TO WS-CX(1) WS-CX(4) WS-CX(5) WS-CX(8)
     MOVE WS-X1 TO WS-CX(2) WS-CX(3) WS-CX(6) WS-CX(7)
     MOVE WS-Y0 TO WS-CY(1) WS-CY(2) WS-CY(5) WS-CY(6)
     MOVE WS-Y1 TO WS-CY(3) WS-CY(4) WS-CY(7) WS-CY(8)
     MOVE WS-Z0 TO WS-CZ(1) WS-CZ(2) WS-CZ(3) WS-CZ(4)
     MOVE WS-Z1 TO WS-CZ(5) WS-CZ(6) WS-CZ(7) WS-CZ(8)
     MOVE WS-BU TO WS-US(1)
     COMPUTE WS-US(2) = WS-BU + EC-D
     COMPUTE WS-US(3) = WS-BU + EC-D + EC-W
     COMPUTE WS-US(4) = WS-BU + EC-D + 2 * EC-W
     COMPUTE WS-US(5) = WS-BU + 2 * EC-D + EC-W
     COMPUTE WS-US(6) = WS-BU + 2 * EC-D + 2 * EC-W
     MOVE WS-BV TO WS-VS(1)
     COMPUTE WS-VS(2) = WS-BV + EC-D
     COMPUTE WS-VS(3) = WS-BV + EC-D + EC-H
     MOVE 0 TO WS-N
     MOVE 1 TO WS-BIT
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 6
         COMPUTE WS-MASK = FUNCTION MOD(EC-FACES / WS-BIT, 2)
         IF WS-MASK = 1
             ADD 1 TO WS-N
             MOVE WS-D TO EF-DIR(WS-N)
             COMPUTE WS-K = WS-INDEX(WS-D, 1) + 1
             MOVE WS-US(WS-K) TO WS-RU0
             COMPUTE WS-K = WS-INDEX(WS-D, 2) + 1
             MOVE WS-VS(WS-K) TO WS-RV0
             COMPUTE WS-K = WS-INDEX(WS-D, 3) + 1
             MOVE WS-US(WS-K) TO WS-RU1
             COMPUTE WS-K = WS-INDEX(WS-D, 4) + 1
             MOVE WS-VS(WS-K) TO WS-RV1
             MOVE WS-RU0 TO EF-MINU(WS-N)
             MOVE WS-RV0 TO EF-MINV(WS-N)
             MOVE WS-RU1 TO EF-MAXU(WS-N)
             MOVE WS-RV1 TO EF-MAXV(WS-N)
             MOVE 0 TO EF-NX(WS-N) EF-NY(WS-N) EF-NZ(WS-N)
             EVALUATE WS-D
                 WHEN 1 MOVE -1 TO EF-NY(WS-N)
                 WHEN 2 MOVE 1 TO EF-NY(WS-N)
                 WHEN 3 MOVE -1 TO EF-NX(WS-N)
                 WHEN 4 MOVE -1 TO EF-NZ(WS-N)
                 WHEN 5 MOVE 1 TO EF-NX(WS-N)
                 WHEN OTHER MOVE 1 TO EF-NZ(WS-N)
             END-EVALUATE
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                 MOVE WS-CORNERS(WS-D)(WS-K:1) TO WS-LETTER
                 COMPUTE WS-C = FUNCTION ORD(WS-LETTER) - FUNCTION ORD("A") + 1
                 MOVE WS-CX(WS-C) TO WS-TX(WS-K)
                 MOVE WS-CY(WS-C) TO WS-TY(WS-K)
                 MOVE WS-CZ(WS-C) TO WS-TZ(WS-K)
             END-PERFORM
             COMPUTE WS-TTU(1) = WS-RU1 / WS-TW
             COMPUTE WS-TTV(1) = WS-RV0 / WS-TH
             COMPUTE WS-TTU(2) = WS-RU0 / WS-TW
             COMPUTE WS-TTV(2) = WS-RV0 / WS-TH
             COMPUTE WS-TTU(3) = WS-RU0 / WS-TW
             COMPUTE WS-TTV(3) = WS-RV1 / WS-TH
             COMPUTE WS-TTU(4) = WS-RU1 / WS-TW
             COMPUTE WS-TTV(4) = WS-RV1 / WS-TH
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                 MOVE WS-K TO WS-SRC
                 IF EC-MIRROR NOT = 0
                     COMPUTE WS-SRC = 5 - WS-K
                 END-IF
                 MOVE WS-TX(WS-K) TO EF-X(WS-N, WS-SRC)
                 MOVE WS-TY(WS-K) TO EF-Y(WS-N, WS-SRC)
                 MOVE WS-TZ(WS-K) TO EF-Z(WS-N, WS-SRC)
                 MOVE WS-TTU(WS-K) TO EF-TU(WS-N, WS-K)
                 MOVE WS-TTV(WS-K) TO EF-TV(WS-N, WS-K)
             END-PERFORM
             IF EC-MIRROR NOT = 0
                 IF WS-D = 3
                     MOVE 1 TO EF-NX(WS-N)
                 END-IF
                 IF WS-D = 5
                     MOVE -1 TO EF-NX(WS-N)
                 END-IF
             END-IF
         END-IF
         COMPUTE WS-BIT = WS-BIT * 2
     END-PERFORM
     MOVE WS-N TO EF-COUNT
     GOBACK.
 END PROGRAM EM1-CUBE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM1-ADDBOX.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BUILDER.
    05 L-BU                FLOAT-LONG.
    05 L-BV                FLOAT-LONG.
    05 L-BM                BINARY-LONG.
 01 L-FORM                 BINARY-LONG.
 01 L-ARGS.
    05 L-A                 FLOAT-LONG OCCURS 14 TIMES.
 COPY CLEM1.
 PROCEDURE DIVISION USING L-BUILDER L-FORM L-ARGS EM1-CUBE-IN.
     MOVE L-A(1) TO EC-OX
     MOVE L-A(2) TO EC-OY
     MOVE L-A(3) TO EC-OZ
     MOVE L-A(4) TO EC-W
     MOVE L-A(5) TO EC-H
     MOVE L-A(6) TO EC-D
     MOVE 0 TO EC-GX EC-GY EC-GZ
     MOVE 1 TO EC-SU EC-SV
     MOVE 63 TO EC-FACES
     MOVE L-BM TO EC-MIRROR
     EVALUATE L-FORM
         WHEN 2
             MOVE L-A(7) TO EC-GX
             MOVE L-A(8) TO EC-GY
             MOVE L-A(9) TO EC-GZ
         WHEN 3
             MOVE L-A(12) TO EC-MIRROR
         WHEN 4
             MOVE L-A(7) TO EC-GX
             MOVE L-A(8) TO EC-GY
             MOVE L-A(9) TO EC-GZ
             MOVE L-A(10) TO EC-SU
             MOVE L-A(11) TO EC-SV
         WHEN 5
             MOVE L-A(12) TO EC-FACES
         WHEN 6
             MOVE L-A(13) TO L-BU
             MOVE L-A(14) TO L-BV
     END-EVALUATE
     MOVE L-BU TO EC-U
     MOVE L-BV TO EC-V
     GOBACK.
 END PROGRAM EM1-ADDBOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM1-POSE-OP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-OP                   BINARY-LONG.
 01 L-POSE.
    05 L-P                 FLOAT-LONG OCCURS 9 TIMES.
 01 L-ARGS.
    05 L-A                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 9 TIMES.
 PROCEDURE DIVISION USING L-OP L-POSE L-ARGS L-OUT.
     MOVE L-POSE TO L-OUT
     EVALUATE L-OP
         WHEN 1
             COMPUTE L-O(1) = L-P(1) + L-A(1)
             COMPUTE L-O(2) = L-P(2) + L-A(2)
             COMPUTE L-O(3) = L-P(3) + L-A(3)
         WHEN 2
             IF L-A(1) NOT = 1
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
                     COMPUTE L-O(WS-I) = L-P(WS-I) * L-A(1)
                     COMPUTE L-O(WS-I + 6) = L-P(WS-I + 6) * L-A(1)
                 END-PERFORM
             END-IF
         WHEN 3
             COMPUTE L-O(1) = L-P(1) * L-A(1)
             COMPUTE L-O(2) = L-P(2) * L-A(2)
             COMPUTE L-O(3) = L-P(3) * L-A(3)
             COMPUTE L-O(7) = L-P(7) * L-A(1)
             COMPUTE L-O(8) = L-P(8) * L-A(2)
             COMPUTE L-O(9) = L-P(9) * L-A(3)
         WHEN OTHER
             MOVE L-A(1) TO L-O(7) L-O(8) L-O(9)
     END-EVALUATE
     GOBACK.
 END PROGRAM EM1-POSE-OP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM1-POINT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-CA                  FLOAT-LONG.
 01 WS-SA                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-POSE.
    05 L-P                 FLOAT-LONG OCCURS 9 TIMES.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-POSE L-IN L-OUT.
     COMPUTE WS-X = L-I(1) * L-P(7)
     COMPUTE WS-Y = L-I(2) * L-P(8)
     COMPUTE WS-Z = L-I(3) * L-P(9)
*>   rotate about X, then Y, then Z (rotationZYX acts X first on a vector)
     COMPUTE WS-CA = FUNCTION COS(L-P(4))
     COMPUTE WS-SA = FUNCTION SIN(L-P(4))
     COMPUTE WS-T = WS-Y * WS-CA - WS-Z * WS-SA
     COMPUTE WS-Z = WS-Y * WS-SA + WS-Z * WS-CA
     MOVE WS-T TO WS-Y
     COMPUTE WS-CA = FUNCTION COS(L-P(5))
     COMPUTE WS-SA = FUNCTION SIN(L-P(5))
     COMPUTE WS-T = WS-X * WS-CA + WS-Z * WS-SA
     COMPUTE WS-Z = WS-Z * WS-CA - WS-X * WS-SA
     MOVE WS-T TO WS-X
     COMPUTE WS-CA = FUNCTION COS(L-P(6))
     COMPUTE WS-SA = FUNCTION SIN(L-P(6))
     COMPUTE WS-T = WS-X * WS-CA - WS-Y * WS-SA
     COMPUTE WS-Y = WS-X * WS-SA + WS-Y * WS-CA
     MOVE WS-T TO WS-X
     COMPUTE L-O(1) = (WS-X + L-P(1)) / 16
     COMPUTE L-O(2) = (WS-Y + L-P(2)) / 16
     COMPUTE L-O(3) = (WS-Z + L-P(3)) / 16
     GOBACK.
 END PROGRAM EM1-POINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM1-HEIGHT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-Y                    FLOAT-LONG.
 01 L-SCALE                FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-Y L-SCALE L-OUT.
     COMPUTE L-OUT = (1.501 - L-Y / 16) * L-SCALE
     GOBACK.
 END PROGRAM EM1-HEIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM1-RADIANS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DEG                  FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-DEG L-OUT.
     COMPUTE L-OUT = L-DEG * 0.017453292
     GOBACK.
 END PROGRAM EM1-RADIANS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM1-DRAWS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VISIBLE              BINARY-LONG.
 01 L-CUBOIDS              BINARY-LONG.
 01 L-CHILDREN             BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-VISIBLE L-CUBOIDS L-CHILDREN L-OUT.
     MOVE 1 TO L-OUT
     IF L-VISIBLE = 0
         MOVE 0 TO L-OUT
     END-IF
     IF L-CUBOIDS = 0 AND L-CHILDREN = 0
         MOVE 0 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM EM1-DRAWS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM1-PART-NAME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES.
    05 FILLER PIC X(24) VALUE "head".
    05 FILLER PIC X(24) VALUE "hat".
    05 FILLER PIC X(24) VALUE "body".
    05 FILLER PIC X(24) VALUE "upper_body".
    05 FILLER PIC X(24) VALUE "inner_body".
    05 FILLER PIC X(24) VALUE "waist".
    05 FILLER PIC X(24) VALUE "jacket".
    05 FILLER PIC X(24) VALUE "neck".
    05 FILLER PIC X(24) VALUE "mane".
    05 FILLER PIC X(24) VALUE "jaw".
    05 FILLER PIC X(24) VALUE "nose".
    05 FILLER PIC X(24) VALUE "beak".
    05 FILLER PIC X(24) VALUE "mouth".
    05 FILLER PIC X(24) VALUE "upper_mouth".
    05 FILLER PIC X(24) VALUE "inner_mouth".
    05 FILLER PIC X(24) VALUE "lower_mouth".
    05 FILLER PIC X(24) VALUE "tail".
    05 FILLER PIC X(24) VALUE "tongue".
    05 FILLER PIC X(24) VALUE "tongue_r1".
    05 FILLER PIC X(24) VALUE "cube".
    05 FILLER PIC X(24) VALUE "shell".
    05 FILLER PIC X(24) VALUE "harness".
    05 FILLER PIC X(24) VALUE "goggles".
    05 FILLER PIC X(24) VALUE "hat_rim".
    05 FILLER PIC X(24) VALUE "root".
    05 FILLER PIC X(24) VALUE "bone".
    05 FILLER PIC X(24) VALUE "bottom".
    05 FILLER PIC X(24) VALUE "feet".
    05 FILLER PIC X(24) VALUE "eyes".
    05 FILLER PIC X(24) VALUE "rods".
    05 FILLER PIC X(24) VALUE "mushrooms".
    05 FILLER PIC X(24) VALUE "arms".
    05 FILLER PIC X(24) VALUE "croaking_body".
    05 FILLER PIC X(24) VALUE "left_arm".
    05 FILLER PIC X(24) VALUE "right_arm".
    05 FILLER PIC X(24) VALUE "left_leg".
    05 FILLER PIC X(24) VALUE "right_leg".
    05 FILLER PIC X(24) VALUE "left_hind_leg".
    05 FILLER PIC X(24) VALUE "right_hind_leg".
    05 FILLER PIC X(24) VALUE "left_mid_leg".
    05 FILLER PIC X(24) VALUE "right_mid_leg".
    05 FILLER PIC X(24) VALUE "left_front_leg".
    05 FILLER PIC X(24) VALUE "right_front_leg".
    05 FILLER PIC X(24) VALUE "left_hind_foot".
    05 FILLER PIC X(24) VALUE "right_hind_foot".
    05 FILLER PIC X(24) VALUE "left_front_foot".
    05 FILLER PIC X(24) VALUE "right_front_foot".
    05 FILLER PIC X(24) VALUE "left_hind_leg_tip".
    05 FILLER PIC X(24) VALUE "right_hind_leg_tip".
    05 FILLER PIC X(24) VALUE "left_front_leg_tip".
    05 FILLER PIC X(24) VALUE "right_front_leg_tip".
    05 FILLER PIC X(24) VALUE "left_hand".
    05 FILLER PIC X(24) VALUE "right_hand".
    05 FILLER PIC X(24) VALUE "left_foot".
    05 FILLER PIC X(24) VALUE "right_foot".
    05 FILLER PIC X(24) VALUE "left_ear".
    05 FILLER PIC X(24) VALUE "right_ear".
    05 FILLER PIC X(24) VALUE "left_horn".
    05 FILLER PIC X(24) VALUE "right_horn".
    05 FILLER PIC X(24) VALUE "left_eye".
    05 FILLER PIC X(24) VALUE "right_eye".
    05 FILLER PIC X(24) VALUE "left_lid".
    05 FILLER PIC X(24) VALUE "right_lid".
    05 FILLER PIC X(24) VALUE "left_tendril".
    05 FILLER PIC X(24) VALUE "right_tendril".
    05 FILLER PIC X(24) VALUE "left_wing".
    05 FILLER PIC X(24) VALUE "right_wing".
    05 FILLER PIC X(24) VALUE "left_wing_base".
    05 FILLER PIC X(24) VALUE "right_wing_base".
    05 FILLER PIC X(24) VALUE "left_wing_tip".
    05 FILLER PIC X(24) VALUE "right_wing_tip".
    05 FILLER PIC X(24) VALUE "left_fin".
    05 FILLER PIC X(24) VALUE "right_fin".
    05 FILLER PIC X(24) VALUE "top_fin".
    05 FILLER PIC X(24) VALUE "bottom_fin".
    05 FILLER PIC X(24) VALUE "tail_fin".
    05 FILLER PIC X(24) VALUE "back_fin".
    05 FILLER PIC X(24) VALUE "left_blue_fin".
    05 FILLER PIC X(24) VALUE "right_blue_fin".
    05 FILLER PIC X(24) VALUE "left_paddle".
    05 FILLER PIC X(24) VALUE "right_paddle".
    05 FILLER PIC X(24) VALUE "top_gills".
    05 FILLER PIC X(24) VALUE "left_gills".
    05 FILLER PIC X(24) VALUE "right_gills".
    05 FILLER PIC X(24) VALUE "left_chest".
    05 FILLER PIC X(24) VALUE "right_chest".
    05 FILLER PIC X(24) VALUE "left_ribcage".
    05 FILLER PIC X(24) VALUE "right_ribcage".
    05 FILLER PIC X(24) VALUE "wind_body".
    05 FILLER PIC X(24) VALUE "wind_top".
    05 FILLER PIC X(24) VALUE "wind_mid".
    05 FILLER PIC X(24) VALUE "wind_bottom".
    05 FILLER PIC X(24) VALUE "chest_bottom".
    05 FILLER PIC X(24) VALUE "chest_lid".
    05 FILLER PIC X(24) VALUE "chest_lock".
    05 FILLER PIC X(24) VALUE "yellow_coral".
    05 FILLER PIC X(24) VALUE "yellow_coral_first".
    05 FILLER PIC X(24) VALUE "yellow_coral_second".
    05 FILLER PIC X(24) VALUE "pink_coral".
    05 FILLER PIC X(24) VALUE "pink_coral_second".
    05 FILLER PIC X(24) VALUE "blue_coral".
    05 FILLER PIC X(24) VALUE "blue_first".
    05 FILLER PIC X(24) VALUE "blue_second".
    05 FILLER PIC X(24) VALUE "red_coral".
    05 FILLER PIC X(24) VALUE "red_coral_first".
    05 FILLER PIC X(24) VALUE "red_coral_second".
 01 WS-NAMES-R REDEFINES WS-NAMES.
    05 WS-NAME PIC X(24) OCCURS 106 TIMES.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(24).
 01 L-KNOWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-KNOWN.
     MOVE 0 TO L-KNOWN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 106
         IF WS-NAME(WS-I) = L-NAME
             MOVE 1 TO L-KNOWN
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EM1-PART-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM1-PART-NAME-COUNT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT.
     MOVE 106 TO L-COUNT
     GOBACK.
 END PROGRAM EM1-PART-NAME-COUNT.
