*> Entity models part 7 (docs/protocol/34-entity-models-7-nether-end-bosses.md): Nether, End and bosses. Section 1 here (shared pieces, 1.1 to 1.6); the models in client/src/entmodel-34-7-<n>.cob.
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)): ops lists are count, then code (1 translate, 2 scale, 3 rotate Y degrees, 4 rotate Z degrees, 7 rotationZYX given as z y x radians) and three values per op in call order.
*>   EF7-PART-OPS IN(x y z texels, rotation x y z, scale x y z) OUT(ops): 1.1 part pose application; EF7-POSE-OP IN(op 1 withScale 2 scaled 3 translated, pose 9, three values) OUT(pose 9);
*>   EF7-BOX-CORNERS IN(x y z w h d grow x y z mirror) OUT(corners A..H x y z); EF7-BOX-RECTS IN(u v w h d texture W H) OUT(six face rectangles down up west north east south: u min v min u max v max as fractions);
*>   EF7-FACE-VERTS IN(face 0 down 1 up 2 west 3 north 4 east 5 south, mirror) OUT(four corner indexes 1 to 8 in vertex slot order); EF7-VERTEX-UV IN(slot, u min, v min, u max, v max) OUT(u, v); EF7-FACE-NORMAL IN(face, mirror) OUT(x y z);
*>   EF7-SCALE-POINT IN(s, x, y, z) OUT(the point after MeshTransformer.scaling); EF7-INNER-ARMOR IN() OUT(0.5); EF7-MTH-SIN, EF7-MTH-COS IN(x) OUT(table value, via EF5-MTH-SIN and EF5-MTH-COS); EF7-WRAP-DEGREES IN(x) OUT(r); EF7-ROT-LERP, EF7-LERP IN(t a b) OUT(value);
*>   EF7-RANDOM-SEQ IN(mode 1 next(bits) 2 nextFloat 3 nextInt(bound), seed, bits or bound, unused, count up to 60) OUT(the values): the 48-bit generator of 1.5 seeded with setSeed(seed);
*>   EF7-SETUP-ROTATIONS IN(shaking, ageInTicks, body yaw, death time, sleeping) OUT(ops: the rotations, the (-1, -1, 1) scale and the (0, -1.501, 0) translate); EF7-BODY-RENDER IN(translucent body, visible, glowing) OUT(mode 0 nothing 1 model render type 2 translucent cull 3 outline, tinted);
*>   EF7-OVERLAY-PIXEL IN(x y) OUT(signed ARGB); EF7-OVERLAY-COORDS IN(white progress, has red overlay) OUT(u, v); EF7-LIGHT IN(block, sky, block light 15 override) OUT(light coords); EF7-SHADOW IN(radius, scale) OUT(radius x scale).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-PART-OPS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 1 TO L-O(2)
     COMPUTE L-O(3) = L-I(1) / 16
     COMPUTE L-O(4) = L-I(2) / 16
     COMPUTE L-O(5) = L-I(3) / 16
     MOVE 1 TO WS-N
     IF L-I(4) NOT = 0 OR L-I(5) NOT = 0 OR L-I(6) NOT = 0
         ADD 1 TO WS-N
         COMPUTE WS-K = WS-N * 4 - 2
         MOVE 7 TO L-O(WS-K)
         MOVE L-I(6) TO L-O(WS-K + 1)
         MOVE L-I(5) TO L-O(WS-K + 2)
         MOVE L-I(4) TO L-O(WS-K + 3)
     END-IF
     IF L-I(7) NOT = 1 OR L-I(8) NOT = 1 OR L-I(9) NOT = 1
         ADD 1 TO WS-N
         COMPUTE WS-K = WS-N * 4 - 2
         MOVE 2 TO L-O(WS-K)
         MOVE L-I(7) TO L-O(WS-K + 1)
         MOVE L-I(8) TO L-O(WS-K + 2)
         MOVE L-I(9) TO L-O(WS-K + 3)
     END-IF
     MOVE WS-N TO L-O(1)
     GOBACK.
 END PROGRAM EF7-PART-OPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-POSE-OP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 9
         MOVE L-I(WS-K + 1) TO L-O(WS-K)
     END-PERFORM
     EVALUATE L-I(1)
         WHEN 1
             MOVE L-I(11) TO L-O(7)
             MOVE L-I(12) TO L-O(8)
             MOVE L-I(13) TO L-O(9)
         WHEN 2
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
                 COMPUTE L-O(WS-K) = L-I(WS-K + 1) * L-I(WS-K + 10)
                 COMPUTE L-O(WS-K + 6) = L-I(WS-K + 7) * L-I(WS-K + 10)
             END-PERFORM
         WHEN 3
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
                 COMPUTE L-O(WS-K) = L-I(WS-K + 1) + L-I(WS-K + 10)
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM EF7-POSE-OP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-BOX-CORNERS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X0                  FLOAT-LONG.
 01 WS-X1                  FLOAT-LONG.
 01 WS-Y0                  FLOAT-LONG.
 01 WS-Y1                  FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-Z1                  FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-X0 = L-I(1) - L-I(7)
     COMPUTE WS-X1 = L-I(1) + L-I(4) + L-I(7)
     COMPUTE WS-Y0 = L-I(2) - L-I(8)
     COMPUTE WS-Y1 = L-I(2) + L-I(5) + L-I(8)
     COMPUTE WS-Z0 = L-I(3) - L-I(9)
     COMPUTE WS-Z1 = L-I(3) + L-I(6) + L-I(9)
     IF L-I(10) NOT = 0
         MOVE WS-X0 TO WS-T
         MOVE WS-X1 TO WS-X0
         MOVE WS-T TO WS-X1
     END-IF
     MOVE WS-X0 TO L-O(1) L-O(10) L-O(13) L-O(22)
     MOVE WS-X1 TO L-O(4) L-O(7) L-O(16) L-O(19)
     MOVE WS-Y0 TO L-O(2) L-O(5) L-O(14) L-O(17)
     MOVE WS-Y1 TO L-O(8) L-O(11) L-O(20) L-O(23)
     MOVE WS-Z0 TO L-O(3) L-O(6) L-O(9) L-O(12)
     MOVE WS-Z1 TO L-O(15) L-O(18) L-O(21) L-O(24)
     GOBACK.
 END PROGRAM EF7-BOX-CORNERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-BOX-RECTS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = (L-I(1) + L-I(5)) / L-I(6)
     COMPUTE L-O(2) = L-I(2) / L-I(7)
     COMPUTE L-O(3) = (L-I(1) + L-I(5) + L-I(3)) / L-I(6)
     COMPUTE L-O(4) = (L-I(2) + L-I(5)) / L-I(7)
     COMPUTE L-O(5) = (L-I(1) + L-I(5) + L-I(3)) / L-I(6)
     COMPUTE L-O(6) = L-I(2) / L-I(7)
     COMPUTE L-O(7) = (L-I(1) + L-I(5) + 2 * L-I(3)) / L-I(6)
     COMPUTE L-O(8) = (L-I(2) + L-I(5)) / L-I(7)
     COMPUTE L-O(9) = L-I(1) / L-I(6)
     COMPUTE L-O(10) = (L-I(2) + L-I(5)) / L-I(7)
     COMPUTE L-O(11) = (L-I(1) + L-I(5)) / L-I(6)
     COMPUTE L-O(12) = (L-I(2) + L-I(5) + L-I(4)) / L-I(7)
     COMPUTE L-O(13) = (L-I(1) + L-I(5)) / L-I(6)
     COMPUTE L-O(14) = (L-I(2) + L-I(5)) / L-I(7)
     COMPUTE L-O(15) = (L-I(1) + L-I(5) + L-I(3)) / L-I(6)
     COMPUTE L-O(16) = (L-I(2) + L-I(5) + L-I(4)) / L-I(7)
     COMPUTE L-O(17) = (L-I(1) + L-I(5) + L-I(3)) / L-I(6)
     COMPUTE L-O(18) = (L-I(2) + L-I(5)) / L-I(7)
     COMPUTE L-O(19) = (L-I(1) + 2 * L-I(5) + L-I(3)) / L-I(6)
     COMPUTE L-O(20) = (L-I(2) + L-I(5) + L-I(4)) / L-I(7)
     COMPUTE L-O(21) = (L-I(1) + 2 * L-I(5) + L-I(3)) / L-I(6)
     COMPUTE L-O(22) = (L-I(2) + L-I(5)) / L-I(7)
     COMPUTE L-O(23) = (L-I(1) + 2 * L-I(5) + 2 * L-I(3)) / L-I(6)
     COMPUTE L-O(24) = (L-I(2) + L-I(5) + L-I(4)) / L-I(7)
     GOBACK.
 END PROGRAM EF7-BOX-RECTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-FACE-VERTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FACES.
    05 FILLER              PIC X(4) VALUE "6512".
    05 FILLER              PIC X(4) VALUE "3487".
    05 FILLER              PIC X(4) VALUE "1584".
    05 FILLER              PIC X(4) VALUE "2143".
    05 FILLER              PIC X(4) VALUE "6237".
    05 FILLER              PIC X(4) VALUE "5678".
 01 WS-FACES-R REDEFINES WS-FACES.
    05 WS-FACE-ROW         PIC X(4) OCCURS 6 TIMES.
 01 WS-ROW.
    05 WS-DIGIT            PIC 9 OCCURS 4 TIMES.
 01 WS-K                   BINARY-LONG.
 01 WS-FI                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-FI = L-I(1) + 1
     MOVE WS-FACE-ROW(WS-FI) TO WS-ROW
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         IF L-I(2) = 0
             MOVE WS-DIGIT(WS-K) TO L-O(WS-K)
         ELSE
             MOVE WS-DIGIT(5 - WS-K) TO L-O(WS-K)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EF7-FACE-VERTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-VERTEX-UV.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     EVALUATE L-I(1)
         WHEN 0
             MOVE L-I(4) TO L-O(1)
             MOVE L-I(3) TO L-O(2)
         WHEN 1
             MOVE L-I(2) TO L-O(1)
             MOVE L-I(3) TO L-O(2)
         WHEN 2
             MOVE L-I(2) TO L-O(1)
             MOVE L-I(5) TO L-O(2)
         WHEN OTHER
             MOVE L-I(4) TO L-O(1)
             MOVE L-I(5) TO L-O(2)
     END-EVALUATE
     GOBACK.
 END PROGRAM EF7-VERTEX-UV.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-FACE-NORMAL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1) L-O(2) L-O(3)
     EVALUATE L-I(1)
         WHEN 0
             MOVE -1 TO L-O(2)
         WHEN 1
             MOVE 1 TO L-O(2)
         WHEN 2
             MOVE -1 TO L-O(1)
             IF L-I(2) NOT = 0
                 MOVE 1 TO L-O(1)
             END-IF
         WHEN 3
             MOVE -1 TO L-O(3)
         WHEN 4
             MOVE 1 TO L-O(1)
             IF L-I(2) NOT = 0
                 MOVE -1 TO L-O(1)
             END-IF
         WHEN OTHER
             MOVE 1 TO L-O(3)
     END-EVALUATE
     GOBACK.
 END PROGRAM EF7-FACE-NORMAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-SCALE-POINT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(1) * L-I(2)
     COMPUTE L-O(2) = 24.016 * (1 - L-I(1)) + L-I(1) * L-I(3)
     COMPUTE L-O(3) = L-I(1) * L-I(4)
     GOBACK.
 END PROGRAM EF7-SCALE-POINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-INNER-ARMOR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0.5 TO L-O(1)
     GOBACK.
 END PROGRAM EF7-INNER-ARMOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-MTH-SIN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     CALL "EF5-MTH-SIN" USING L-IN L-OUT
     GOBACK.
 END PROGRAM EF7-MTH-SIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-MTH-COS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     CALL "EF5-MTH-COS" USING L-IN L-OUT
     GOBACK.
 END PROGRAM EF7-MTH-COS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-WRAP-DEGREES.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = FUNCTION REM(L-I(1), 360)
     IF L-O(1) >= 180
         COMPUTE L-O(1) = L-O(1) - 360
     END-IF
     IF L-O(1) < -180
         COMPUTE L-O(1) = L-O(1) + 360
     END-IF
     GOBACK.
 END PROGRAM EF7-WRAP-DEGREES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-ROT-LERP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-D = FUNCTION REM(L-I(3) - L-I(2), 360)
     IF WS-D >= 180
         COMPUTE WS-D = WS-D - 360
     END-IF
     IF WS-D < -180
         COMPUTE WS-D = WS-D + 360
     END-IF
     COMPUTE L-O(1) = L-I(2) + L-I(1) * WS-D
     GOBACK.
 END PROGRAM EF7-ROT-LERP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-LERP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(2) + L-I(1) * (L-I(3) - L-I(2))
     GOBACK.
 END PROGRAM EF7-LERP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-RANDOM-SEQ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-J                   BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-AGAIN               BINARY-LONG.
 01 WS-A                   BINARY-DOUBLE.
 01 WS-B                   BINARY-DOUBLE.
 01 WS-P                   BINARY-DOUBLE.
 01 WS-PW                  BINARY-DOUBLE.
 01 WS-BA                  BINARY-LONG.
 01 WS-BB                  BINARY-LONG.
 01 WS-ST                  BINARY-DOUBLE.
 01 WS-L                   BINARY-DOUBLE.
 01 WS-H                   BINARY-DOUBLE.
 01 WS-C                   BINARY-DOUBLE.
 01 WS-V                   BINARY-DOUBLE.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-M                   BINARY-DOUBLE.
 01 WS-BOUND               BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     PERFORM XOR-SEED
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > L-I(5)
         EVALUATE L-I(1)
             WHEN 1
                 MOVE L-I(3) TO WS-BITS
                 PERFORM NEXT-BITS
                 MOVE WS-V TO L-O(WS-J)
             WHEN 2
                 MOVE 24 TO WS-BITS
                 PERFORM NEXT-BITS
                 COMPUTE L-O(WS-J) = WS-V / 16777216
             WHEN OTHER
                 PERFORM NEXT-INT
                 MOVE WS-V TO L-O(WS-J)
         END-EVALUATE
     END-PERFORM
     GO TO PROGRAM-DONE.

 XOR-SEED.
     MOVE L-I(2) TO WS-A
     MOVE 25214903917 TO WS-B
     MOVE 0 TO WS-ST
     MOVE 1 TO WS-P
     PERFORM 48 TIMES
         COMPUTE WS-BA = FUNCTION MOD(FUNCTION INTEGER-PART(WS-A / WS-P), 2)
         COMPUTE WS-BB = FUNCTION MOD(FUNCTION INTEGER-PART(WS-B / WS-P), 2)
         IF WS-BA NOT = WS-BB
             ADD WS-P TO WS-ST
         END-IF
         COMPUTE WS-P = WS-P * 2
     END-PERFORM.

 NEXT-BITS.
     COMPUTE WS-L = FUNCTION MOD(WS-ST, 16777216)
     COMPUTE WS-H = FUNCTION INTEGER-PART(WS-ST / 16777216)
     COMPUTE WS-C = WS-L * 15525485 + FUNCTION MOD(WS-H * 15525485 + WS-L * 1502, 16777216) * 16777216 + 11
     COMPUTE WS-ST = FUNCTION MOD(WS-C, 281474976710656)
     COMPUTE WS-PW = 2 ** (48 - WS-BITS)
     COMPUTE WS-V = FUNCTION INTEGER-PART(WS-ST / WS-PW)
     IF WS-V >= 2147483648
         COMPUTE WS-V = WS-V - 4294967296
     END-IF.

 NEXT-INT.
     MOVE L-I(3) TO WS-BOUND
     MOVE 31 TO WS-BITS
     IF FUNCTION MOD(2147483648, WS-BOUND) = 0
         PERFORM NEXT-BITS
         COMPUTE WS-V = FUNCTION INTEGER-PART(WS-BOUND * WS-V / 2147483648)
     ELSE
         MOVE 1 TO WS-AGAIN
         PERFORM UNTIL WS-AGAIN = 0
             PERFORM NEXT-BITS
             MOVE WS-V TO WS-R
             COMPUTE WS-M = FUNCTION MOD(WS-R, WS-BOUND)
             IF WS-R - WS-M + (WS-BOUND - 1) < 2147483648
                 MOVE 0 TO WS-AGAIN
             END-IF
         END-PERFORM
         MOVE WS-M TO WS-V
     END-IF.

 PROGRAM-DONE.
     GOBACK.
 END PROGRAM EF7-RANDOM-SEQ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-SETUP-ROTATIONS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-Q                   FLOAT-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(3) TO WS-YAW
     IF L-I(1) NOT = 0
         COMPUTE WS-YAW = L-I(3) + FUNCTION COS(FUNCTION INTEGER(L-I(2)) * 3.25) * 3.141592653589793 * 0.4000000059604645
     END-IF
     MOVE 0 TO WS-N
     IF L-I(5) = 0
         ADD 1 TO WS-N
         MOVE 3 TO L-O(2)
         COMPUTE L-O(3) = 180 - WS-YAW
         MOVE 0 TO L-O(4) L-O(5)
     END-IF
     IF L-I(4) > 0
         ADD 1 TO WS-N
         COMPUTE WS-K = WS-N * 4 - 2
         MOVE 4 TO L-O(WS-K)
         COMPUTE WS-Q = FUNCTION SQRT((L-I(4) - 1) / 20 * 1.6)
         IF WS-Q > 1
             MOVE 1 TO WS-Q
         END-IF
         COMPUTE L-O(WS-K + 1) = WS-Q * 90
         MOVE 0 TO L-O(WS-K + 2) L-O(WS-K + 3)
     END-IF
     ADD 1 TO WS-N
     COMPUTE WS-K = WS-N * 4 - 2
     MOVE 2 TO L-O(WS-K)
     MOVE -1 TO L-O(WS-K + 1) L-O(WS-K + 2)
     MOVE 1 TO L-O(WS-K + 3)
     ADD 1 TO WS-N
     COMPUTE WS-K = WS-N * 4 - 2
     MOVE 1 TO L-O(WS-K)
     MOVE 0 TO L-O(WS-K + 1) L-O(WS-K + 3)
     MOVE -1.501 TO L-O(WS-K + 2)
     MOVE WS-N TO L-O(1)
     GOBACK.
 END PROGRAM EF7-SETUP-ROTATIONS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-BODY-RENDER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1) L-O(2)
     EVALUATE TRUE
         WHEN L-I(1) NOT = 0
             MOVE 2 TO L-O(1)
             MOVE 1 TO L-O(2)
         WHEN L-I(2) NOT = 0
             MOVE 1 TO L-O(1)
         WHEN L-I(3) NOT = 0
             MOVE 3 TO L-O(1)
     END-EVALUATE
     GOBACK.
 END PROGRAM EF7-BODY-RENDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-OVERLAY-PIXEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-AL                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     IF L-I(2) < 8
         MOVE -1291911168 TO L-O(1)
     ELSE
         COMPUTE WS-AL = FUNCTION INTEGER-PART((1 - L-I(1) / 15 * 0.75) * 255)
         COMPUTE L-O(1) = WS-AL * 16777216 + 16777215
         IF L-O(1) >= 2147483648
             COMPUTE L-O(1) = L-O(1) - 4294967296
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EF7-OVERLAY-PIXEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-OVERLAY-COORDS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = FUNCTION INTEGER-PART(L-I(1) * 15)
     MOVE 10 TO L-O(2)
     IF L-I(2) NOT = 0
         MOVE 3 TO L-O(2)
     END-IF
     GOBACK.
 END PROGRAM EF7-OVERLAY-COORDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-LIGHT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-B                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO WS-B
     IF L-I(3) NOT = 0
         MOVE 15 TO WS-B
     END-IF
     COMPUTE L-O(1) = WS-B * 16 + L-I(2) * 1048576
     GOBACK.
 END PROGRAM EF7-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-SHADOW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(1) * L-I(2)
     GOBACK.
 END PROGRAM EF7-SHADOW.

