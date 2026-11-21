*> Acceptance test of docs/protocol/34-entity-models-7-nether-end-bosses.md section 1 (shared pieces): 1.1 part pose application ops and the PartPose helpers, 1.2 box corners, face rectangles, vertex slots, vertex uvs and normals, 1.3 the scaling transformer on a point,
*> 1.4 Mth sine and cosine tables, wrapDegrees, rotLerp and lerp, 1.5 the 48-bit random generator (the ghast tentacle lengths of section 3 are the check), 1.6 setupRotations ops, the body render choice, overlay texels and coordinates, light and shadow radius.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-7-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLEMM.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-E                   FLOAT-LONG.
 01 WS-O                   FLOAT-LONG.
 01 WS-IN.
    05 WS-IV                FLOAT-LONG OCCURS 32 TIMES.
 01 WS-OUT.
    05 WS-OV                FLOAT-LONG OCCURS 64 TIMES.

 01 WS-X32               PIC X(32).
 01 WS-X32B              PIC X(32).
 01 WS-X120              PIC X(120).
 01 WS-X24               PIC X(24).
 01 WS-X40               PIC X(40).
 01 WS-FL                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     MOVE 1 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     CALL "EF7-PART-OPS" USING WS-IN WS-OUT
     MOVE "1.1 part ops for pose (0, 0, 0, 0, 0, 0, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (0, 0, 0, 0, 0, 0, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (0, 0, 0, 0, 0, 0, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (0, 0, 0, 0, 0, 0, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (0, 0, 0, 0, 0, 0, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE 8 TO WS-IV(1)
     MOVE -16 TO WS-IV(2)
     MOVE 4 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     MOVE 1 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     CALL "EF7-PART-OPS" USING WS-IN WS-OUT
     MOVE "1.1 part ops for pose (8, -16, 4, 0.5, 0, 0, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (8, -16, 4, 0.5, 0, 0, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (8, -16, 4, 0.5, 0, 0, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [3]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (8, -16, 4, 0.5, 0, 0, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [4]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (8, -16, 4, 0.5, 0, 0, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [5]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (8, -16, 4, 0.5, 0, 0, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [6]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (8, -16, 4, 0.5, 0, 0, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (8, -16, 4, 0.5, 0, 0, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (8, -16, 4, 0.5, 0, 0, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [9]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0.25 TO WS-IV(5)
     MOVE -0.5 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     MOVE 1 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     CALL "EF7-PART-OPS" USING WS-IN WS-OUT
     MOVE "1.1 part ops for pose (1, 2, 3, 0, 0.25, -0.5, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (1, 2, 3, 0, 0.25, -0.5, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (1, 2, 3, 0, 0.25, -0.5, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [3]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (1, 2, 3, 0, 0.25, -0.5, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [4]" TO WS-NAME
     MOVE 0.125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (1, 2, 3, 0, 0.25, -0.5, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [5]" TO WS-NAME
     MOVE 0.1875 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (1, 2, 3, 0, 0.25, -0.5, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [6]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (1, 2, 3, 0, 0.25, -0.5, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [7]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (1, 2, 3, 0, 0.25, -0.5, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [8]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (1, 2, 3, 0, 0.25, -0.5, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 24 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0.875 TO WS-IV(7)
     MOVE 0.875 TO WS-IV(8)
     MOVE 0.875 TO WS-IV(9)
     CALL "EF7-PART-OPS" USING WS-IN WS-OUT
     MOVE "1.1 part ops for pose (0, 24, 0, 0, 0, 0, 0.875, 0.875, 0.875) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (0, 24, 0, 0, 0, 0, 0.875, 0.875, 0.875) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (0, 24, 0, 0, 0, 0, 0.875, 0.875, 0.875) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (0, 24, 0, 0, 0, 0, 0.875, 0.875, 0.875) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [4]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (0, 24, 0, 0, 0, 0, 0.875, 0.875, 0.875) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (0, 24, 0, 0, 0, 0, 0.875, 0.875, 0.875) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (0, 24, 0, 0, 0, 0, 0.875, 0.875, 0.875) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [7]" TO WS-NAME
     MOVE 0.875 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (0, 24, 0, 0, 0, 0, 0.875, 0.875, 0.875) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [8]" TO WS-NAME
     MOVE 0.875 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (0, 24, 0, 0, 0, 0, 0.875, 0.875, 0.875) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [9]" TO WS-NAME
     MOVE 0.875 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE -2 TO WS-IV(1)
     MOVE 6.9 TO WS-IV(2)
     MOVE -0.5 TO WS-IV(3)
     MOVE 0.2 TO WS-IV(4)
     MOVE 0.1 TO WS-IV(5)
     MOVE 0.3 TO WS-IV(6)
     MOVE 2 TO WS-IV(7)
     MOVE 1 TO WS-IV(8)
     MOVE 2 TO WS-IV(9)
     CALL "EF7-PART-OPS" USING WS-IN WS-OUT
     MOVE "1.1 part ops for pose (-2, 6.9, -0.5, 0.2, 0.1, 0.3, 2, 1, 2) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (-2, 6.9, -0.5, 0.2, 0.1, 0.3, 2, 1, 2) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (-2, 6.9, -0.5, 0.2, 0.1, 0.3, 2, 1, 2) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [3]" TO WS-NAME
     MOVE -0.125 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (-2, 6.9, -0.5, 0.2, 0.1, 0.3, 2, 1, 2) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [4]" TO WS-NAME
     MOVE 0.43125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (-2, 6.9, -0.5, 0.2, 0.1, 0.3, 2, 1, 2) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [5]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (-2, 6.9, -0.5, 0.2, 0.1, 0.3, 2, 1, 2) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [6]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (-2, 6.9, -0.5, 0.2, 0.1, 0.3, 2, 1, 2) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [7]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (-2, 6.9, -0.5, 0.2, 0.1, 0.3, 2, 1, 2) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [8]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (-2, 6.9, -0.5, 0.2, 0.1, 0.3, 2, 1, 2) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [9]" TO WS-NAME
     MOVE 0.2 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (-2, 6.9, -0.5, 0.2, 0.1, 0.3, 2, 1, 2) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [10]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (-2, 6.9, -0.5, 0.2, 0.1, 0.3, 2, 1, 2) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [11]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (-2, 6.9, -0.5, 0.2, 0.1, 0.3, 2, 1, 2) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [12]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 part ops for pose (-2, 6.9, -0.5, 0.2, 0.1, 0.3, 2, 1, 2) (count; code 1 translate, 7 rotationZYX z y x, 2 scale; values) [13]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 3 TO WS-IV(4)
     MOVE 0.1 TO WS-IV(5)
     MOVE 0.2 TO WS-IV(6)
     MOVE 0.3 TO WS-IV(7)
     MOVE 1 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 2 TO WS-IV(11)
     MOVE 2 TO WS-IV(12)
     MOVE 2 TO WS-IV(13)
     CALL "EF7-POSE-OP" USING WS-IN WS-OUT
     MOVE "1.1 PartPose op 1 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 1, 1, 1) with (2, 2, 2) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose op 1 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 1, 1, 1) with (2, 2, 2) [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose op 1 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 1, 1, 1) with (2, 2, 2) [3]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose op 1 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 1, 1, 1) with (2, 2, 2) [4]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose op 1 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 1, 1, 1) with (2, 2, 2) [5]" TO WS-NAME
     MOVE 0.2 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose op 1 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 1, 1, 1) with (2, 2, 2) [6]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose op 1 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 1, 1, 1) with (2, 2, 2) [7]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose op 1 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 1, 1, 1) with (2, 2, 2) [8]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose op 1 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 1, 1, 1) with (2, 2, 2) [9]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 3 TO WS-IV(4)
     MOVE 0.1 TO WS-IV(5)
     MOVE 0.2 TO WS-IV(6)
     MOVE 0.3 TO WS-IV(7)
     MOVE 2 TO WS-IV(8)
     MOVE 3 TO WS-IV(9)
     MOVE 4 TO WS-IV(10)
     MOVE 2 TO WS-IV(11)
     MOVE 2 TO WS-IV(12)
     MOVE 2 TO WS-IV(13)
     CALL "EF7-POSE-OP" USING WS-IN WS-OUT
     MOVE "1.1 PartPose op 2 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 2, 3, 4) with (2, 2, 2) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose op 2 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 2, 3, 4) with (2, 2, 2) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose op 2 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 2, 3, 4) with (2, 2, 2) [3]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose op 2 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 2, 3, 4) with (2, 2, 2) [4]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose op 2 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 2, 3, 4) with (2, 2, 2) [5]" TO WS-NAME
     MOVE 0.2 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose op 2 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 2, 3, 4) with (2, 2, 2) [6]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose op 2 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 2, 3, 4) with (2, 2, 2) [7]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose op 2 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 2, 3, 4) with (2, 2, 2) [8]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose op 2 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 2, 3, 4) with (2, 2, 2) [9]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 3 TO WS-IV(4)
     MOVE 0.1 TO WS-IV(5)
     MOVE 0.2 TO WS-IV(6)
     MOVE 0.3 TO WS-IV(7)
     MOVE 1 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     MOVE -2 TO WS-IV(12)
     MOVE 0.5 TO WS-IV(13)
     CALL "EF7-POSE-OP" USING WS-IN WS-OUT
     MOVE "1.1 PartPose op 3 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 1, 1, 1) with (1, -2, 0.5) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose op 3 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 1, 1, 1) with (1, -2, 0.5) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose op 3 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 1, 1, 1) with (1, -2, 0.5) [3]" TO WS-NAME
     MOVE 3.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose op 3 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 1, 1, 1) with (1, -2, 0.5) [4]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose op 3 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 1, 1, 1) with (1, -2, 0.5) [5]" TO WS-NAME
     MOVE 0.2 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose op 3 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 1, 1, 1) with (1, -2, 0.5) [6]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose op 3 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 1, 1, 1) with (1, -2, 0.5) [7]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose op 3 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 1, 1, 1) with (1, -2, 0.5) [8]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 PartPose op 3 (1 withScale, 2 scaled, 3 translated) on (1, 2, 3, 0.1, 0.2, 0.3, 1, 1, 1) with (1, -2, 0.5) [9]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE -4 TO WS-IV(1)
     MOVE -4 TO WS-IV(2)
     MOVE -4 TO WS-IV(3)
     MOVE 8 TO WS-IV(4)
     MOVE 8 TO WS-IV(5)
     MOVE 8 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     CALL "EF7-BOX-CORNERS" USING WS-IN WS-OUT
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0, 0, 0, 0) (A..H x y z) [1]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0, 0, 0, 0) (A..H x y z) [2]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0, 0, 0, 0) (A..H x y z) [3]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0, 0, 0, 0) (A..H x y z) [4]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0, 0, 0, 0) (A..H x y z) [5]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0, 0, 0, 0) (A..H x y z) [6]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0, 0, 0, 0) (A..H x y z) [7]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0, 0, 0, 0) (A..H x y z) [8]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0, 0, 0, 0) (A..H x y z) [9]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0, 0, 0, 0) (A..H x y z) [10]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0, 0, 0, 0) (A..H x y z) [11]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0, 0, 0, 0) (A..H x y z) [12]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0, 0, 0, 0) (A..H x y z) [13]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0, 0, 0, 0) (A..H x y z) [14]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0, 0, 0, 0) (A..H x y z) [15]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0, 0, 0, 0) (A..H x y z) [16]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0, 0, 0, 0) (A..H x y z) [17]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0, 0, 0, 0) (A..H x y z) [18]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0, 0, 0, 0) (A..H x y z) [19]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0, 0, 0, 0) (A..H x y z) [20]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0, 0, 0, 0) (A..H x y z) [21]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0, 0, 0, 0) (A..H x y z) [22]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0, 0, 0, 0) (A..H x y z) [23]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0, 0, 0, 0) (A..H x y z) [24]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE -4 TO WS-IV(1)
     MOVE -4 TO WS-IV(2)
     MOVE -4 TO WS-IV(3)
     MOVE 8 TO WS-IV(4)
     MOVE 8 TO WS-IV(5)
     MOVE 8 TO WS-IV(6)
     MOVE 0.5 TO WS-IV(7)
     MOVE 0.5 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     CALL "EF7-BOX-CORNERS" USING WS-IN WS-OUT
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0.5, 0.5, 0.5, 0) (A..H x y z) [1]" TO WS-NAME
     MOVE -4.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0.5, 0.5, 0.5, 0) (A..H x y z) [2]" TO WS-NAME
     MOVE -4.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0.5, 0.5, 0.5, 0) (A..H x y z) [3]" TO WS-NAME
     MOVE -4.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0.5, 0.5, 0.5, 0) (A..H x y z) [4]" TO WS-NAME
     MOVE 4.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0.5, 0.5, 0.5, 0) (A..H x y z) [5]" TO WS-NAME
     MOVE -4.5 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0.5, 0.5, 0.5, 0) (A..H x y z) [6]" TO WS-NAME
     MOVE -4.5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0.5, 0.5, 0.5, 0) (A..H x y z) [7]" TO WS-NAME
     MOVE 4.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0.5, 0.5, 0.5, 0) (A..H x y z) [8]" TO WS-NAME
     MOVE 4.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0.5, 0.5, 0.5, 0) (A..H x y z) [9]" TO WS-NAME
     MOVE -4.5 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0.5, 0.5, 0.5, 0) (A..H x y z) [10]" TO WS-NAME
     MOVE -4.5 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0.5, 0.5, 0.5, 0) (A..H x y z) [11]" TO WS-NAME
     MOVE 4.5 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0.5, 0.5, 0.5, 0) (A..H x y z) [12]" TO WS-NAME
     MOVE -4.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0.5, 0.5, 0.5, 0) (A..H x y z) [13]" TO WS-NAME
     MOVE -4.5 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0.5, 0.5, 0.5, 0) (A..H x y z) [14]" TO WS-NAME
     MOVE -4.5 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0.5, 0.5, 0.5, 0) (A..H x y z) [15]" TO WS-NAME
     MOVE 4.5 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0.5, 0.5, 0.5, 0) (A..H x y z) [16]" TO WS-NAME
     MOVE 4.5 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0.5, 0.5, 0.5, 0) (A..H x y z) [17]" TO WS-NAME
     MOVE -4.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0.5, 0.5, 0.5, 0) (A..H x y z) [18]" TO WS-NAME
     MOVE 4.5 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0.5, 0.5, 0.5, 0) (A..H x y z) [19]" TO WS-NAME
     MOVE 4.5 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0.5, 0.5, 0.5, 0) (A..H x y z) [20]" TO WS-NAME
     MOVE 4.5 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0.5, 0.5, 0.5, 0) (A..H x y z) [21]" TO WS-NAME
     MOVE 4.5 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0.5, 0.5, 0.5, 0) (A..H x y z) [22]" TO WS-NAME
     MOVE -4.5 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0.5, 0.5, 0.5, 0) (A..H x y z) [23]" TO WS-NAME
     MOVE 4.5 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-4, -4, -4, 8, 8, 8, 0.5, 0.5, 0.5, 0) (A..H x y z) [24]" TO WS-NAME
     MOVE 4.5 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE -10 TO WS-IV(1)
     MOVE 3.9 TO WS-IV(2)
     MOVE -0.5 TO WS-IV(3)
     MOVE 20 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     MOVE 3 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     CALL "EF7-BOX-CORNERS" USING WS-IN WS-OUT
     MOVE "1.2 corners of box (-10, 3.9, -0.5, 20, 3, 3, 0, 0, 0, 1) (A..H x y z) [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-10, 3.9, -0.5, 20, 3, 3, 0, 0, 0, 1) (A..H x y z) [2]" TO WS-NAME
     MOVE 3.9 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-10, 3.9, -0.5, 20, 3, 3, 0, 0, 0, 1) (A..H x y z) [3]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-10, 3.9, -0.5, 20, 3, 3, 0, 0, 0, 1) (A..H x y z) [4]" TO WS-NAME
     MOVE -10 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-10, 3.9, -0.5, 20, 3, 3, 0, 0, 0, 1) (A..H x y z) [5]" TO WS-NAME
     MOVE 3.9 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-10, 3.9, -0.5, 20, 3, 3, 0, 0, 0, 1) (A..H x y z) [6]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-10, 3.9, -0.5, 20, 3, 3, 0, 0, 0, 1) (A..H x y z) [7]" TO WS-NAME
     MOVE -10 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-10, 3.9, -0.5, 20, 3, 3, 0, 0, 0, 1) (A..H x y z) [8]" TO WS-NAME
     MOVE 6.9 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-10, 3.9, -0.5, 20, 3, 3, 0, 0, 0, 1) (A..H x y z) [9]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-10, 3.9, -0.5, 20, 3, 3, 0, 0, 0, 1) (A..H x y z) [10]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-10, 3.9, -0.5, 20, 3, 3, 0, 0, 0, 1) (A..H x y z) [11]" TO WS-NAME
     MOVE 6.9 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-10, 3.9, -0.5, 20, 3, 3, 0, 0, 0, 1) (A..H x y z) [12]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-10, 3.9, -0.5, 20, 3, 3, 0, 0, 0, 1) (A..H x y z) [13]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-10, 3.9, -0.5, 20, 3, 3, 0, 0, 0, 1) (A..H x y z) [14]" TO WS-NAME
     MOVE 3.9 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-10, 3.9, -0.5, 20, 3, 3, 0, 0, 0, 1) (A..H x y z) [15]" TO WS-NAME
     MOVE 2.5 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-10, 3.9, -0.5, 20, 3, 3, 0, 0, 0, 1) (A..H x y z) [16]" TO WS-NAME
     MOVE -10 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-10, 3.9, -0.5, 20, 3, 3, 0, 0, 0, 1) (A..H x y z) [17]" TO WS-NAME
     MOVE 3.9 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-10, 3.9, -0.5, 20, 3, 3, 0, 0, 0, 1) (A..H x y z) [18]" TO WS-NAME
     MOVE 2.5 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-10, 3.9, -0.5, 20, 3, 3, 0, 0, 0, 1) (A..H x y z) [19]" TO WS-NAME
     MOVE -10 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-10, 3.9, -0.5, 20, 3, 3, 0, 0, 0, 1) (A..H x y z) [20]" TO WS-NAME
     MOVE 6.9 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-10, 3.9, -0.5, 20, 3, 3, 0, 0, 0, 1) (A..H x y z) [21]" TO WS-NAME
     MOVE 2.5 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-10, 3.9, -0.5, 20, 3, 3, 0, 0, 0, 1) (A..H x y z) [22]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-10, 3.9, -0.5, 20, 3, 3, 0, 0, 0, 1) (A..H x y z) [23]" TO WS-NAME
     MOVE 6.9 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (-10, 3.9, -0.5, 20, 3, 3, 0, 0, 0, 1) (A..H x y z) [24]" TO WS-NAME
     MOVE 2.5 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 2 TO WS-IV(4)
     MOVE 8 TO WS-IV(5)
     MOVE 2 TO WS-IV(6)
     MOVE 0.25 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 0.1 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     CALL "EF7-BOX-CORNERS" USING WS-IN WS-OUT
     MOVE "1.2 corners of box (0, 0, 0, 2, 8, 2, 0.25, 0, 0.1, 1) (A..H x y z) [1]" TO WS-NAME
     MOVE 2.25 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (0, 0, 0, 2, 8, 2, 0.25, 0, 0.1, 1) (A..H x y z) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (0, 0, 0, 2, 8, 2, 0.25, 0, 0.1, 1) (A..H x y z) [3]" TO WS-NAME
     MOVE -0.1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (0, 0, 0, 2, 8, 2, 0.25, 0, 0.1, 1) (A..H x y z) [4]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (0, 0, 0, 2, 8, 2, 0.25, 0, 0.1, 1) (A..H x y z) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (0, 0, 0, 2, 8, 2, 0.25, 0, 0.1, 1) (A..H x y z) [6]" TO WS-NAME
     MOVE -0.1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (0, 0, 0, 2, 8, 2, 0.25, 0, 0.1, 1) (A..H x y z) [7]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (0, 0, 0, 2, 8, 2, 0.25, 0, 0.1, 1) (A..H x y z) [8]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (0, 0, 0, 2, 8, 2, 0.25, 0, 0.1, 1) (A..H x y z) [9]" TO WS-NAME
     MOVE -0.1 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (0, 0, 0, 2, 8, 2, 0.25, 0, 0.1, 1) (A..H x y z) [10]" TO WS-NAME
     MOVE 2.25 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (0, 0, 0, 2, 8, 2, 0.25, 0, 0.1, 1) (A..H x y z) [11]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (0, 0, 0, 2, 8, 2, 0.25, 0, 0.1, 1) (A..H x y z) [12]" TO WS-NAME
     MOVE -0.1 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (0, 0, 0, 2, 8, 2, 0.25, 0, 0.1, 1) (A..H x y z) [13]" TO WS-NAME
     MOVE 2.25 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (0, 0, 0, 2, 8, 2, 0.25, 0, 0.1, 1) (A..H x y z) [14]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (0, 0, 0, 2, 8, 2, 0.25, 0, 0.1, 1) (A..H x y z) [15]" TO WS-NAME
     MOVE 2.1 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (0, 0, 0, 2, 8, 2, 0.25, 0, 0.1, 1) (A..H x y z) [16]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (0, 0, 0, 2, 8, 2, 0.25, 0, 0.1, 1) (A..H x y z) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (0, 0, 0, 2, 8, 2, 0.25, 0, 0.1, 1) (A..H x y z) [18]" TO WS-NAME
     MOVE 2.1 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (0, 0, 0, 2, 8, 2, 0.25, 0, 0.1, 1) (A..H x y z) [19]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (0, 0, 0, 2, 8, 2, 0.25, 0, 0.1, 1) (A..H x y z) [20]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (0, 0, 0, 2, 8, 2, 0.25, 0, 0.1, 1) (A..H x y z) [21]" TO WS-NAME
     MOVE 2.1 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (0, 0, 0, 2, 8, 2, 0.25, 0, 0.1, 1) (A..H x y z) [22]" TO WS-NAME
     MOVE 2.25 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (0, 0, 0, 2, 8, 2, 0.25, 0, 0.1, 1) (A..H x y z) [23]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corners of box (0, 0, 0, 2, 8, 2, 0.25, 0, 0.1, 1) (A..H x y z) [24]" TO WS-NAME
     MOVE 2.1 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 8 TO WS-IV(3)
     MOVE 8 TO WS-IV(4)
     MOVE 8 TO WS-IV(5)
     MOVE 64 TO WS-IV(6)
     MOVE 32 TO WS-IV(7)
     CALL "EF7-BOX-RECTS" USING WS-IN WS-OUT
     MOVE "1.2 face rectangles of box tex (0,0) size 8x8x8 in 64x32 (down, up, west, north, east, south: u min, v min, u max, v max) [1]" TO WS-NAME
     MOVE 0.125 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,0) size 8x8x8 in 64x32 (down, up, west, north, east, south: u min, v min, u max, v max) [2]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,0) size 8x8x8 in 64x32 (down, up, west, north, east, south: u min, v min, u max, v max) [3]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,0) size 8x8x8 in 64x32 (down, up, west, north, east, south: u min, v min, u max, v max) [4]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,0) size 8x8x8 in 64x32 (down, up, west, north, east, south: u min, v min, u max, v max) [5]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,0) size 8x8x8 in 64x32 (down, up, west, north, east, south: u min, v min, u max, v max) [6]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,0) size 8x8x8 in 64x32 (down, up, west, north, east, south: u min, v min, u max, v max) [7]" TO WS-NAME
     MOVE 0.375 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,0) size 8x8x8 in 64x32 (down, up, west, north, east, south: u min, v min, u max, v max) [8]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,0) size 8x8x8 in 64x32 (down, up, west, north, east, south: u min, v min, u max, v max) [9]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,0) size 8x8x8 in 64x32 (down, up, west, north, east, south: u min, v min, u max, v max) [10]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,0) size 8x8x8 in 64x32 (down, up, west, north, east, south: u min, v min, u max, v max) [11]" TO WS-NAME
     MOVE 0.125 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,0) size 8x8x8 in 64x32 (down, up, west, north, east, south: u min, v min, u max, v max) [12]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,0) size 8x8x8 in 64x32 (down, up, west, north, east, south: u min, v min, u max, v max) [13]" TO WS-NAME
     MOVE 0.125 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,0) size 8x8x8 in 64x32 (down, up, west, north, east, south: u min, v min, u max, v max) [14]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,0) size 8x8x8 in 64x32 (down, up, west, north, east, south: u min, v min, u max, v max) [15]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,0) size 8x8x8 in 64x32 (down, up, west, north, east, south: u min, v min, u max, v max) [16]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,0) size 8x8x8 in 64x32 (down, up, west, north, east, south: u min, v min, u max, v max) [17]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,0) size 8x8x8 in 64x32 (down, up, west, north, east, south: u min, v min, u max, v max) [18]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,0) size 8x8x8 in 64x32 (down, up, west, north, east, south: u min, v min, u max, v max) [19]" TO WS-NAME
     MOVE 0.375 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,0) size 8x8x8 in 64x32 (down, up, west, north, east, south: u min, v min, u max, v max) [20]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,0) size 8x8x8 in 64x32 (down, up, west, north, east, south: u min, v min, u max, v max) [21]" TO WS-NAME
     MOVE 0.375 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,0) size 8x8x8 in 64x32 (down, up, west, north, east, south: u min, v min, u max, v max) [22]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,0) size 8x8x8 in 64x32 (down, up, west, north, east, south: u min, v min, u max, v max) [23]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,0) size 8x8x8 in 64x32 (down, up, west, north, east, south: u min, v min, u max, v max) [24]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE 32 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 6 TO WS-IV(3)
     MOVE 6 TO WS-IV(4)
     MOVE 6 TO WS-IV(5)
     MOVE 64 TO WS-IV(6)
     MOVE 64 TO WS-IV(7)
     CALL "EF7-BOX-RECTS" USING WS-IN WS-OUT
     MOVE "1.2 face rectangles of box tex (32,0) size 6x6x6 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [1]" TO WS-NAME
     MOVE 0.59375 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (32,0) size 6x6x6 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [2]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (32,0) size 6x6x6 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [3]" TO WS-NAME
     MOVE 0.6875 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (32,0) size 6x6x6 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [4]" TO WS-NAME
     MOVE 0.09375 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (32,0) size 6x6x6 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [5]" TO WS-NAME
     MOVE 0.6875 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (32,0) size 6x6x6 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [6]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (32,0) size 6x6x6 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [7]" TO WS-NAME
     MOVE 0.78125 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (32,0) size 6x6x6 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [8]" TO WS-NAME
     MOVE 0.09375 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (32,0) size 6x6x6 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [9]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (32,0) size 6x6x6 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [10]" TO WS-NAME
     MOVE 0.09375 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (32,0) size 6x6x6 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [11]" TO WS-NAME
     MOVE 0.59375 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (32,0) size 6x6x6 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [12]" TO WS-NAME
     MOVE 0.1875 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (32,0) size 6x6x6 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [13]" TO WS-NAME
     MOVE 0.59375 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (32,0) size 6x6x6 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [14]" TO WS-NAME
     MOVE 0.09375 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (32,0) size 6x6x6 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [15]" TO WS-NAME
     MOVE 0.6875 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (32,0) size 6x6x6 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [16]" TO WS-NAME
     MOVE 0.1875 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (32,0) size 6x6x6 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [17]" TO WS-NAME
     MOVE 0.6875 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (32,0) size 6x6x6 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [18]" TO WS-NAME
     MOVE 0.09375 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (32,0) size 6x6x6 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [19]" TO WS-NAME
     MOVE 0.78125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (32,0) size 6x6x6 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [20]" TO WS-NAME
     MOVE 0.1875 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (32,0) size 6x6x6 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [21]" TO WS-NAME
     MOVE 0.78125 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (32,0) size 6x6x6 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [22]" TO WS-NAME
     MOVE 0.09375 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (32,0) size 6x6x6 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [23]" TO WS-NAME
     MOVE 0.875 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (32,0) size 6x6x6 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [24]" TO WS-NAME
     MOVE 0.1875 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 16 TO WS-IV(2)
     MOVE 20 TO WS-IV(3)
     MOVE 3 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     MOVE 64 TO WS-IV(6)
     MOVE 64 TO WS-IV(7)
     CALL "EF7-BOX-RECTS" USING WS-IN WS-OUT
     MOVE "1.2 face rectangles of box tex (0,16) size 20x3x3 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [1]" TO WS-NAME
     MOVE 0.046875 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,16) size 20x3x3 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [2]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,16) size 20x3x3 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [3]" TO WS-NAME
     MOVE 0.359375 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,16) size 20x3x3 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [4]" TO WS-NAME
     MOVE 0.296875 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,16) size 20x3x3 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [5]" TO WS-NAME
     MOVE 0.359375 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,16) size 20x3x3 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [6]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,16) size 20x3x3 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [7]" TO WS-NAME
     MOVE 0.671875 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,16) size 20x3x3 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [8]" TO WS-NAME
     MOVE 0.296875 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,16) size 20x3x3 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [9]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,16) size 20x3x3 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [10]" TO WS-NAME
     MOVE 0.296875 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,16) size 20x3x3 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [11]" TO WS-NAME
     MOVE 0.046875 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,16) size 20x3x3 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [12]" TO WS-NAME
     MOVE 0.34375 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,16) size 20x3x3 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [13]" TO WS-NAME
     MOVE 0.046875 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,16) size 20x3x3 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [14]" TO WS-NAME
     MOVE 0.296875 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,16) size 20x3x3 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [15]" TO WS-NAME
     MOVE 0.359375 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,16) size 20x3x3 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [16]" TO WS-NAME
     MOVE 0.34375 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,16) size 20x3x3 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [17]" TO WS-NAME
     MOVE 0.359375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,16) size 20x3x3 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [18]" TO WS-NAME
     MOVE 0.296875 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,16) size 20x3x3 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [19]" TO WS-NAME
     MOVE 0.40625 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,16) size 20x3x3 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [20]" TO WS-NAME
     MOVE 0.34375 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,16) size 20x3x3 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [21]" TO WS-NAME
     MOVE 0.40625 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,16) size 20x3x3 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [22]" TO WS-NAME
     MOVE 0.296875 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,16) size 20x3x3 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [23]" TO WS-NAME
     MOVE 0.71875 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (0,16) size 20x3x3 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [24]" TO WS-NAME
     MOVE 0.34375 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE 24 TO WS-IV(1)
     MOVE 22 TO WS-IV(2)
     MOVE 11 TO WS-IV(3)
     MOVE 2 TO WS-IV(4)
     MOVE 2 TO WS-IV(5)
     MOVE 64 TO WS-IV(6)
     MOVE 64 TO WS-IV(7)
     CALL "EF7-BOX-RECTS" USING WS-IN WS-OUT
     MOVE "1.2 face rectangles of box tex (24,22) size 11x2x2 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [1]" TO WS-NAME
     MOVE 0.40625 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (24,22) size 11x2x2 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [2]" TO WS-NAME
     MOVE 0.34375 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (24,22) size 11x2x2 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [3]" TO WS-NAME
     MOVE 0.578125 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (24,22) size 11x2x2 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [4]" TO WS-NAME
     MOVE 0.375 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (24,22) size 11x2x2 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [5]" TO WS-NAME
     MOVE 0.578125 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (24,22) size 11x2x2 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [6]" TO WS-NAME
     MOVE 0.34375 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (24,22) size 11x2x2 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [7]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (24,22) size 11x2x2 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [8]" TO WS-NAME
     MOVE 0.375 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (24,22) size 11x2x2 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [9]" TO WS-NAME
     MOVE 0.375 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (24,22) size 11x2x2 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [10]" TO WS-NAME
     MOVE 0.375 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (24,22) size 11x2x2 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [11]" TO WS-NAME
     MOVE 0.40625 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (24,22) size 11x2x2 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [12]" TO WS-NAME
     MOVE 0.40625 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (24,22) size 11x2x2 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [13]" TO WS-NAME
     MOVE 0.40625 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (24,22) size 11x2x2 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [14]" TO WS-NAME
     MOVE 0.375 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (24,22) size 11x2x2 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [15]" TO WS-NAME
     MOVE 0.578125 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (24,22) size 11x2x2 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [16]" TO WS-NAME
     MOVE 0.40625 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (24,22) size 11x2x2 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [17]" TO WS-NAME
     MOVE 0.578125 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (24,22) size 11x2x2 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [18]" TO WS-NAME
     MOVE 0.375 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (24,22) size 11x2x2 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [19]" TO WS-NAME
     MOVE 0.609375 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (24,22) size 11x2x2 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [20]" TO WS-NAME
     MOVE 0.40625 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (24,22) size 11x2x2 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [21]" TO WS-NAME
     MOVE 0.609375 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (24,22) size 11x2x2 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [22]" TO WS-NAME
     MOVE 0.375 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (24,22) size 11x2x2 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [23]" TO WS-NAME
     MOVE 0.78125 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 face rectangles of box tex (24,22) size 11x2x2 in 64x64 (down, up, west, north, east, south: u min, v min, u max, v max) [24]" TO WS-NAME
     MOVE 0.40625 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF7-FACE-VERTS" USING WS-IN WS-OUT
     MOVE "1.2 corner indexes of face 0 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 0, in vertex slot order [1]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 0 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 0, in vertex slot order [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 0 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 0, in vertex slot order [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 0 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 0, in vertex slot order [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF7-FACE-VERTS" USING WS-IN WS-OUT
     MOVE "1.2 corner indexes of face 0 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 1, in vertex slot order [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 0 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 1, in vertex slot order [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 0 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 1, in vertex slot order [3]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 0 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 1, in vertex slot order [4]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF7-FACE-VERTS" USING WS-IN WS-OUT
     MOVE "1.2 corner indexes of face 1 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 0, in vertex slot order [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 1 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 0, in vertex slot order [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 1 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 0, in vertex slot order [3]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 1 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 0, in vertex slot order [4]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF7-FACE-VERTS" USING WS-IN WS-OUT
     MOVE "1.2 corner indexes of face 1 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 1, in vertex slot order [1]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 1 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 1, in vertex slot order [2]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 1 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 1, in vertex slot order [3]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 1 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 1, in vertex slot order [4]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF7-FACE-VERTS" USING WS-IN WS-OUT
     MOVE "1.2 corner indexes of face 2 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 0, in vertex slot order [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 2 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 0, in vertex slot order [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 2 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 0, in vertex slot order [3]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 2 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 0, in vertex slot order [4]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF7-FACE-VERTS" USING WS-IN WS-OUT
     MOVE "1.2 corner indexes of face 2 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 1, in vertex slot order [1]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 2 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 1, in vertex slot order [2]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 2 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 1, in vertex slot order [3]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 2 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 1, in vertex slot order [4]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF7-FACE-VERTS" USING WS-IN WS-OUT
     MOVE "1.2 corner indexes of face 3 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 0, in vertex slot order [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 3 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 0, in vertex slot order [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 3 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 0, in vertex slot order [3]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 3 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 0, in vertex slot order [4]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF7-FACE-VERTS" USING WS-IN WS-OUT
     MOVE "1.2 corner indexes of face 3 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 1, in vertex slot order [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 3 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 1, in vertex slot order [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 3 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 1, in vertex slot order [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 3 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 1, in vertex slot order [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF7-FACE-VERTS" USING WS-IN WS-OUT
     MOVE "1.2 corner indexes of face 4 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 0, in vertex slot order [1]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 4 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 0, in vertex slot order [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 4 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 0, in vertex slot order [3]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 4 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 0, in vertex slot order [4]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF7-FACE-VERTS" USING WS-IN WS-OUT
     MOVE "1.2 corner indexes of face 4 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 1, in vertex slot order [1]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 4 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 1, in vertex slot order [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 4 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 1, in vertex slot order [3]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 4 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 1, in vertex slot order [4]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF7-FACE-VERTS" USING WS-IN WS-OUT
     MOVE "1.2 corner indexes of face 5 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 0, in vertex slot order [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 5 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 0, in vertex slot order [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 5 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 0, in vertex slot order [3]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 5 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 0, in vertex slot order [4]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF7-FACE-VERTS" USING WS-IN WS-OUT
     MOVE "1.2 corner indexes of face 5 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 1, in vertex slot order [1]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 5 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 1, in vertex slot order [2]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 5 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 1, in vertex slot order [3]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 corner indexes of face 5 (0 down 1 up 2 west 3 north 4 east 5 south) mirror 1, in vertex slot order [4]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 20 TO WS-IV(3)
     MOVE 30 TO WS-IV(4)
     MOVE 40 TO WS-IV(5)
     CALL "EF7-VERTEX-UV" USING WS-IN WS-OUT
     MOVE "1.2 vertex slot 0 uv of rectangle u 10..30 v 20..40 (u, v) [1]" TO WS-NAME
     MOVE 30 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 vertex slot 0 uv of rectangle u 10..30 v 20..40 (u, v) [2]" TO WS-NAME
     MOVE 20 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 20 TO WS-IV(3)
     MOVE 30 TO WS-IV(4)
     MOVE 40 TO WS-IV(5)
     CALL "EF7-VERTEX-UV" USING WS-IN WS-OUT
     MOVE "1.2 vertex slot 1 uv of rectangle u 10..30 v 20..40 (u, v) [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 vertex slot 1 uv of rectangle u 10..30 v 20..40 (u, v) [2]" TO WS-NAME
     MOVE 20 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 20 TO WS-IV(3)
     MOVE 30 TO WS-IV(4)
     MOVE 40 TO WS-IV(5)
     CALL "EF7-VERTEX-UV" USING WS-IN WS-OUT
     MOVE "1.2 vertex slot 2 uv of rectangle u 10..30 v 20..40 (u, v) [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 vertex slot 2 uv of rectangle u 10..30 v 20..40 (u, v) [2]" TO WS-NAME
     MOVE 40 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 20 TO WS-IV(3)
     MOVE 30 TO WS-IV(4)
     MOVE 40 TO WS-IV(5)
     CALL "EF7-VERTEX-UV" USING WS-IN WS-OUT
     MOVE "1.2 vertex slot 3 uv of rectangle u 10..30 v 20..40 (u, v) [1]" TO WS-NAME
     MOVE 30 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 vertex slot 3 uv of rectangle u 10..30 v 20..40 (u, v) [2]" TO WS-NAME
     MOVE 40 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF7-FACE-NORMAL" USING WS-IN WS-OUT
     MOVE "1.2 normal of face 0 mirror 0 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 normal of face 0 mirror 0 [2]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 normal of face 0 mirror 0 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF7-FACE-NORMAL" USING WS-IN WS-OUT
     MOVE "1.2 normal of face 0 mirror 1 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 normal of face 0 mirror 1 [2]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 normal of face 0 mirror 1 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF7-FACE-NORMAL" USING WS-IN WS-OUT
     MOVE "1.2 normal of face 1 mirror 0 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 normal of face 1 mirror 0 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 normal of face 1 mirror 0 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF7-FACE-NORMAL" USING WS-IN WS-OUT
     MOVE "1.2 normal of face 1 mirror 1 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 normal of face 1 mirror 1 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 normal of face 1 mirror 1 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF7-FACE-NORMAL" USING WS-IN WS-OUT
     MOVE "1.2 normal of face 2 mirror 0 [1]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 normal of face 2 mirror 0 [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 normal of face 2 mirror 0 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF7-FACE-NORMAL" USING WS-IN WS-OUT
     MOVE "1.2 normal of face 2 mirror 1 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 normal of face 2 mirror 1 [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 normal of face 2 mirror 1 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF7-FACE-NORMAL" USING WS-IN WS-OUT
     MOVE "1.2 normal of face 3 mirror 0 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 normal of face 3 mirror 0 [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 normal of face 3 mirror 0 [3]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF7-FACE-NORMAL" USING WS-IN WS-OUT
     MOVE "1.2 normal of face 3 mirror 1 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 normal of face 3 mirror 1 [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 normal of face 3 mirror 1 [3]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF7-FACE-NORMAL" USING WS-IN WS-OUT
     MOVE "1.2 normal of face 4 mirror 0 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 normal of face 4 mirror 0 [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 normal of face 4 mirror 0 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF7-FACE-NORMAL" USING WS-IN WS-OUT
     MOVE "1.2 normal of face 4 mirror 1 [1]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 normal of face 4 mirror 1 [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 normal of face 4 mirror 1 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF7-FACE-NORMAL" USING WS-IN WS-OUT
     MOVE "1.2 normal of face 5 mirror 0 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 normal of face 5 mirror 0 [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 normal of face 5 mirror 0 [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF7-FACE-NORMAL" USING WS-IN WS-OUT
     MOVE "1.2 normal of face 5 mirror 1 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 normal of face 5 mirror 1 [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 normal of face 5 mirror 1 [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4.5 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 17.6 TO WS-IV(3)
     MOVE 2 TO WS-IV(4)
     CALL "EF7-SCALE-POINT" USING WS-IN WS-OUT
     MOVE "1.3 model point (1, 17.6, 2) after scaling 4.5 [1]" TO WS-NAME
     MOVE 4.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 model point (1, 17.6, 2) after scaling 4.5 [2]" TO WS-NAME
     MOVE -4.856 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 model point (1, 17.6, 2) after scaling 4.5 [3]" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1.2 TO WS-IV(1)
     MOVE -3 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 5 TO WS-IV(4)
     CALL "EF7-SCALE-POINT" USING WS-IN WS-OUT
     MOVE "1.3 model point (-3, 0, 5) after scaling 1.2 [1]" TO WS-NAME
     MOVE -3.6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 model point (-3, 0, 5) after scaling 1.2 [2]" TO WS-NAME
     MOVE -4.8032 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 model point (-3, 0, 5) after scaling 1.2 [3]" TO WS-NAME
     MOVE 6.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.7 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 24 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF7-SCALE-POINT" USING WS-IN WS-OUT
     MOVE "1.3 model point (2, 24, 1) after scaling 0.7 [1]" TO WS-NAME
     MOVE 1.4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 model point (2, 24, 1) after scaling 0.7 [2]" TO WS-NAME
     MOVE 24.0048 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 model point (2, 24, 1) after scaling 0.7 [3]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF7-INNER-ARMOR" USING WS-IN WS-OUT
     MOVE "1.3 INNER_ARMOR_DEFORMATION" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF7-MTH-SIN" USING WS-IN WS-OUT
     MOVE "1.4 Mth.sin(0) table entry" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF7-MTH-COS" USING WS-IN WS-OUT
     MOVE "1.4 Mth.cos(0) table entry" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     CALL "EF7-MTH-SIN" USING WS-IN WS-OUT
     MOVE "1.4 Mth.sin(0.5) table entry" TO WS-NAME
     MOVE 0.479409622 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     CALL "EF7-MTH-COS" USING WS-IN WS-OUT
     MOVE "1.4 Mth.cos(0.5) table entry" TO WS-NAME
     MOVE 0.877591257 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF7-MTH-SIN" USING WS-IN WS-OUT
     MOVE "1.4 Mth.sin(1) table entry" TO WS-NAME
     MOVE 0.841451385 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF7-MTH-COS" USING WS-IN WS-OUT
     MOVE "1.4 Mth.cos(1) table entry" TO WS-NAME
     MOVE 0.540332829 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2.5 TO WS-IV(1)
     CALL "EF7-MTH-SIN" USING WS-IN WS-OUT
     MOVE "1.4 Mth.sin(2.5) table entry" TO WS-NAME
     MOVE 0.598544793 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2.5 TO WS-IV(1)
     CALL "EF7-MTH-COS" USING WS-IN WS-OUT
     MOVE "1.4 Mth.cos(2.5) table entry" TO WS-NAME
     MOVE -0.80108934 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE -1.2 TO WS-IV(1)
     CALL "EF7-MTH-SIN" USING WS-IN WS-OUT
     MOVE "1.4 Mth.sin(-1.2) table entry" TO WS-NAME
     MOVE -0.932023312 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE -1.2 TO WS-IV(1)
     CALL "EF7-MTH-COS" USING WS-IN WS-OUT
     MOVE "1.4 Mth.cos(-1.2) table entry" TO WS-NAME
     MOVE 0.362308966 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10 TO WS-IV(1)
     CALL "EF7-MTH-SIN" USING WS-IN WS-OUT
     MOVE "1.4 Mth.sin(10) table entry" TO WS-NAME
     MOVE -0.54395808 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10 TO WS-IV(1)
     CALL "EF7-MTH-COS" USING WS-IN WS-OUT
     MOVE "1.4 Mth.cos(10) table entry" TO WS-NAME
     MOVE -0.839112392 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 100.3 TO WS-IV(1)
     CALL "EF7-MTH-SIN" USING WS-IN WS-OUT
     MOVE "1.4 Mth.sin(100.3) table entry" TO WS-NAME
     MOVE -0.229005448 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 100.3 TO WS-IV(1)
     CALL "EF7-MTH-COS" USING WS-IN WS-OUT
     MOVE "1.4 Mth.cos(100.3) table entry" TO WS-NAME
     MOVE 0.973425141 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF7-WRAP-DEGREES" USING WS-IN WS-OUT
     MOVE "1.4 wrapDegrees(0)" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 90 TO WS-IV(1)
     CALL "EF7-WRAP-DEGREES" USING WS-IN WS-OUT
     MOVE "1.4 wrapDegrees(90)" TO WS-NAME
     MOVE 90.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 180 TO WS-IV(1)
     CALL "EF7-WRAP-DEGREES" USING WS-IN WS-OUT
     MOVE "1.4 wrapDegrees(180)" TO WS-NAME
     MOVE -180.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE -180 TO WS-IV(1)
     CALL "EF7-WRAP-DEGREES" USING WS-IN WS-OUT
     MOVE "1.4 wrapDegrees(-180)" TO WS-NAME
     MOVE -180.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 190 TO WS-IV(1)
     CALL "EF7-WRAP-DEGREES" USING WS-IN WS-OUT
     MOVE "1.4 wrapDegrees(190)" TO WS-NAME
     MOVE -170.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE -190 TO WS-IV(1)
     CALL "EF7-WRAP-DEGREES" USING WS-IN WS-OUT
     MOVE "1.4 wrapDegrees(-190)" TO WS-NAME
     MOVE 170.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 350 TO WS-IV(1)
     CALL "EF7-WRAP-DEGREES" USING WS-IN WS-OUT
     MOVE "1.4 wrapDegrees(350)" TO WS-NAME
     MOVE -10.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 720.5 TO WS-IV(1)
     CALL "EF7-WRAP-DEGREES" USING WS-IN WS-OUT
     MOVE "1.4 wrapDegrees(720.5)" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE -400 TO WS-IV(1)
     CALL "EF7-WRAP-DEGREES" USING WS-IN WS-OUT
     MOVE "1.4 wrapDegrees(-400)" TO WS-NAME
     MOVE -40.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 100 TO WS-IV(3)
     CALL "EF7-ROT-LERP" USING WS-IN WS-OUT
     MOVE "1.4 rotLerp 0.5 10 to 100" TO WS-NAME
     MOVE 55.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 100 TO WS-IV(3)
     CALL "EF7-LERP" USING WS-IN WS-OUT
     MOVE "1.4 lerp 0.5 10 to 100" TO WS-NAME
     MOVE 55.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.25 TO WS-IV(1)
     MOVE 170 TO WS-IV(2)
     MOVE -170 TO WS-IV(3)
     CALL "EF7-ROT-LERP" USING WS-IN WS-OUT
     MOVE "1.4 rotLerp 0.25 170 to -170" TO WS-NAME
     MOVE 175.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.25 TO WS-IV(1)
     MOVE 170 TO WS-IV(2)
     MOVE -170 TO WS-IV(3)
     CALL "EF7-LERP" USING WS-IN WS-OUT
     MOVE "1.4 lerp 0.25 170 to -170" TO WS-NAME
     MOVE 85.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 359 TO WS-IV(3)
     CALL "EF7-ROT-LERP" USING WS-IN WS-OUT
     MOVE "1.4 rotLerp 1 0 to 359" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 359 TO WS-IV(3)
     CALL "EF7-LERP" USING WS-IN WS-OUT
     MOVE "1.4 lerp 1 0 to 359" TO WS-NAME
     MOVE 359 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     MOVE -0.5 TO WS-IV(2)
     MOVE 0.5 TO WS-IV(3)
     CALL "EF7-ROT-LERP" USING WS-IN WS-OUT
     MOVE "1.4 rotLerp 0.5 -0.5 to 0.5" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     MOVE -0.5 TO WS-IV(2)
     MOVE 0.5 TO WS-IV(3)
     CALL "EF7-LERP" USING WS-IN WS-OUT
     MOVE "1.4 lerp 0.5 -0.5 to 0.5" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1660 TO WS-IV(2)
     MOVE 31 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 5 TO WS-IV(5)
     CALL "EF7-RANDOM-SEQ" USING WS-IN WS-OUT
     MOVE "1.5 next(31) from seed 1660, 5 values [1]" TO WS-NAME
     MOVE 1256555755 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 next(31) from seed 1660, 5 values [2]" TO WS-NAME
     MOVE 1752112955 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 next(31) from seed 1660, 5 values [3]" TO WS-NAME
     MOVE 555797887 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 next(31) from seed 1660, 5 values [4]" TO WS-NAME
     MOVE 1692911944 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 next(31) from seed 1660, 5 values [5]" TO WS-NAME
     MOVE 175276762 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 24 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 4 TO WS-IV(5)
     CALL "EF7-RANDOM-SEQ" USING WS-IN WS-OUT
     MOVE "1.5 next(24) from seed 0, 4 values [1]" TO WS-NAME
     MOVE 12263604 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 next(24) from seed 0, 4 values [2]" TO WS-NAME
     MOVE 13949265 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 next(24) from seed 0, 4 values [3]" TO WS-NAME
     MOVE 4035531 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 next(24) from seed 0, 4 values [4]" TO WS-NAME
     MOVE 10172784 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 12345 TO WS-IV(2)
     MOVE 32 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     CALL "EF7-RANDOM-SEQ" USING WS-IN WS-OUT
     MOVE "1.5 next(32) from seed 12345, 3 values [1]" TO WS-NAME
     MOVE 1553932502 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 next(32) from seed 12345, 3 values [2]" TO WS-NAME
     MOVE -2090749135 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 next(32) from seed 12345, 3 values [3]" TO WS-NAME
     MOVE -287790814 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1660 TO WS-IV(2)
     MOVE 8 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 6 TO WS-IV(5)
     CALL "EF7-RANDOM-SEQ" USING WS-IN WS-OUT
     MOVE "1.5 next(8) from seed 1660, 6 values [1]" TO WS-NAME
     MOVE 149 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 next(8) from seed 1660, 6 values [2]" TO WS-NAME
     MOVE 208 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 next(8) from seed 1660, 6 values [3]" TO WS-NAME
     MOVE 66 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 next(8) from seed 1660, 6 values [4]" TO WS-NAME
     MOVE 201 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 next(8) from seed 1660, 6 values [5]" TO WS-NAME
     MOVE 20 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 next(8) from seed 1660, 6 values [6]" TO WS-NAME
     MOVE 42 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 1660 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 4 TO WS-IV(5)
     CALL "EF7-RANDOM-SEQ" USING WS-IN WS-OUT
     MOVE "1.5 nextFloat from seed 1660, 4 values [1]" TO WS-NAME
     MOVE 0.585129323 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextFloat from seed 1660, 4 values [2]" TO WS-NAME
     MOVE 0.81589115 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextFloat from seed 1660, 4 values [3]" TO WS-NAME
     MOVE 0.258813501 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextFloat from seed 1660, 4 values [4]" TO WS-NAME
     MOVE 0.788323525 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 7 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     CALL "EF7-RANDOM-SEQ" USING WS-IN WS-OUT
     MOVE "1.5 nextFloat from seed 7, 3 values [1]" TO WS-NAME
     MOVE 0.730699005 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextFloat from seed 7, 3 values [2]" TO WS-NAME
     MOVE 0.638537648 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextFloat from seed 7, 3 values [3]" TO WS-NAME
     MOVE 0.749169591 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 1660 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 9 TO WS-IV(5)
     CALL "EF7-RANDOM-SEQ" USING WS-IN WS-OUT
     MOVE "1.5 nextInt(7) from seed 1660, 9 values [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextInt(7) from seed 1660, 9 values [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextInt(7) from seed 1660, 9 values [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextInt(7) from seed 1660, 9 values [4]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextInt(7) from seed 1660, 9 values [5]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextInt(7) from seed 1660, 9 values [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextInt(7) from seed 1660, 9 values [7]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextInt(7) from seed 1660, 9 values [8]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextInt(7) from seed 1660, 9 values [9]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 5 TO WS-IV(2)
     MOVE 8 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 5 TO WS-IV(5)
     CALL "EF7-RANDOM-SEQ" USING WS-IN WS-OUT
     MOVE "1.5 nextInt(8) from seed 5, 5 values [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextInt(8) from seed 5, 5 values [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextInt(8) from seed 5, 5 values [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextInt(8) from seed 5, 5 values [4]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextInt(8) from seed 5, 5 values [5]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 99 TO WS-IV(2)
     MOVE 10 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 6 TO WS-IV(5)
     CALL "EF7-RANDOM-SEQ" USING WS-IN WS-OUT
     MOVE "1.5 nextInt(10) from seed 99, 6 values [1]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextInt(10) from seed 99, 6 values [2]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextInt(10) from seed 99, 6 values [3]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextInt(10) from seed 99, 6 values [4]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextInt(10) from seed 99, 6 values [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextInt(10) from seed 99, 6 values [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     CALL "EF7-RANDOM-SEQ" USING WS-IN WS-OUT
     MOVE "1.5 nextInt(1) from seed 3, 3 values [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextInt(1) from seed 3, 3 values [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextInt(1) from seed 3, 3 values [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 42 TO WS-IV(2)
     MOVE 1000 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 4 TO WS-IV(5)
     CALL "EF7-RANDOM-SEQ" USING WS-IN WS-OUT
     MOVE "1.5 nextInt(1000) from seed 42, 4 values [1]" TO WS-NAME
     MOVE 130 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextInt(1000) from seed 42, 4 values [2]" TO WS-NAME
     MOVE 763 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextInt(1000) from seed 42, 4 values [3]" TO WS-NAME
     MOVE 248 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextInt(1000) from seed 42, 4 values [4]" TO WS-NAME
     MOVE 884 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 432 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 16 TO WS-IV(4)
     MOVE 8 TO WS-IV(5)
     CALL "EF7-RANDOM-SEQ" USING WS-IN WS-OUT
     MOVE "1.5 nextFloat from seed 432 after skipping 16, 8 values [1]" TO WS-NAME
     MOVE 0.85062075 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextFloat from seed 432 after skipping 16, 8 values [2]" TO WS-NAME
     MOVE 0.287422241 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextFloat from seed 432 after skipping 16, 8 values [3]" TO WS-NAME
     MOVE 0.47471893 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextFloat from seed 432 after skipping 16, 8 values [4]" TO WS-NAME
     MOVE 0.687285783 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextFloat from seed 432 after skipping 16, 8 values [5]" TO WS-NAME
     MOVE 0.297860027 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextFloat from seed 432 after skipping 16, 8 values [6]" TO WS-NAME
     MOVE 0.135035992 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextFloat from seed 432 after skipping 16, 8 values [7]" TO WS-NAME
     MOVE 0.676409605 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextFloat from seed 432 after skipping 16, 8 values [8]" TO WS-NAME
     MOVE 0.14610076 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 432 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 8 TO WS-IV(5)
     CALL "EF7-RANDOM-SEQ" USING WS-IN WS-OUT
     MOVE "1.5 nextFloat from seed 432 after skipping 0, 8 values [1]" TO WS-NAME
     MOVE 0.763933661 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextFloat from seed 432 after skipping 0, 8 values [2]" TO WS-NAME
     MOVE 0.827584925 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextFloat from seed 432 after skipping 0, 8 values [3]" TO WS-NAME
     MOVE 0.848198536 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextFloat from seed 432 after skipping 0, 8 values [4]" TO WS-NAME
     MOVE 0.803539279 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextFloat from seed 432 after skipping 0, 8 values [5]" TO WS-NAME
     MOVE 0.767966273 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextFloat from seed 432 after skipping 0, 8 values [6]" TO WS-NAME
     MOVE 0.705038669 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextFloat from seed 432 after skipping 0, 8 values [7]" TO WS-NAME
     MOVE 0.671382787 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextFloat from seed 432 after skipping 0, 8 values [8]" TO WS-NAME
     MOVE 0.712294283 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 5 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 3 TO WS-IV(4)
     MOVE 4 TO WS-IV(5)
     CALL "EF7-RANDOM-SEQ" USING WS-IN WS-OUT
     MOVE "1.5 nextFloat from seed 5 after skipping 3, 4 values [1]" TO WS-NAME
     MOVE 0.611818077 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextFloat from seed 5 after skipping 3, 4 values [2]" TO WS-NAME
     MOVE 0.488904538 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextFloat from seed 5 after skipping 3, 4 values [3]" TO WS-NAME
     MOVE 0.944974605 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 nextFloat from seed 5 after skipping 3, 4 values [4]" TO WS-NAME
     MOVE 0.461837174 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 1660 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 9 TO WS-IV(5)
     CALL "EF7-RANDOM-SEQ" USING WS-IN WS-OUT
     MOVE "1.5 the nextInt(7) values of the ghast tentacle lengths minus 8 (0, 5, 1, 3, 3, 2, 4, 1, 4) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 the nextInt(7) values of the ghast tentacle lengths minus 8 (0, 5, 1, 3, 3, 2, 4, 1, 4) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 the nextInt(7) values of the ghast tentacle lengths minus 8 (0, 5, 1, 3, 3, 2, 4, 1, 4) [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 the nextInt(7) values of the ghast tentacle lengths minus 8 (0, 5, 1, 3, 3, 2, 4, 1, 4) [4]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 the nextInt(7) values of the ghast tentacle lengths minus 8 (0, 5, 1, 3, 3, 2, 4, 1, 4) [5]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 the nextInt(7) values of the ghast tentacle lengths minus 8 (0, 5, 1, 3, 3, 2, 4, 1, 4) [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 the nextInt(7) values of the ghast tentacle lengths minus 8 (0, 5, 1, 3, 3, 2, 4, 1, 4) [7]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 the nextInt(7) values of the ghast tentacle lengths minus 8 (0, 5, 1, 3, 3, 2, 4, 1, 4) [8]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 the nextInt(7) values of the ghast tentacle lengths minus 8 (0, 5, 1, 3, 3, 2, 4, 1, 4) [9]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 30 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF7-SETUP-ROTATIONS" USING WS-IN WS-OUT
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [3]" TO WS-NAME
     MOVE 150 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [7]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [8]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [9]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [12]" TO WS-NAME
     MOVE -1.501 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 12.7 TO WS-IV(2)
     MOVE 30 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF7-SETUP-ROTATIONS" USING WS-IN WS-OUT
     MOVE "1.6 setupRotations shaking 1 age 12.7 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 12.7 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 12.7 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [3]" TO WS-NAME
     MOVE 149.664926604 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 12.7 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 12.7 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 12.7 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 12.7 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [7]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 12.7 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [8]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 12.7 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [9]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 12.7 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 12.7 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 12.7 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [12]" TO WS-NAME
     MOVE -1.501 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 12.7 body yaw 30 death 0 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE -45 TO WS-IV(3)
     MOVE 6 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF7-SETUP-ROTATIONS" USING WS-IN WS-OUT
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw -45 death 6 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [1]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw -45 death 6 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw -45 death 6 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [3]" TO WS-NAME
     MOVE 225 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw -45 death 6 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw -45 death 6 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw -45 death 6 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [6]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw -45 death 6 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [7]" TO WS-NAME
     MOVE 56.920997883 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw -45 death 6 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw -45 death 6 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw -45 death 6 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [10]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw -45 death 6 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [11]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw -45 death 6 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [12]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw -45 death 6 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [13]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw -45 death 6 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw -45 death 6 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw -45 death 6 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [16]" TO WS-NAME
     MOVE -1.501 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw -45 death 6 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 21 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF7-SETUP-ROTATIONS" USING WS-IN WS-OUT
     MOVE "1.6 setupRotations shaking 1 age 3 body yaw 0 death 21 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [1]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 3 body yaw 0 death 21 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 3 body yaw 0 death 21 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [3]" TO WS-NAME
     MOVE 181.190763918 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 3 body yaw 0 death 21 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 3 body yaw 0 death 21 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 3 body yaw 0 death 21 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [6]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 3 body yaw 0 death 21 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [7]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 3 body yaw 0 death 21 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 3 body yaw 0 death 21 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 3 body yaw 0 death 21 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [10]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 3 body yaw 0 death 21 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [11]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 3 body yaw 0 death 21 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [12]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 3 body yaw 0 death 21 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [13]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 3 body yaw 0 death 21 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 3 body yaw 0 death 21 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 3 body yaw 0 death 21 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [16]" TO WS-NAME
     MOVE -1.501 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 1 age 3 body yaw 0 death 21 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 30 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF7-SETUP-ROTATIONS" USING WS-IN WS-OUT
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 1 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [1]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 1 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 1 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [3]" TO WS-NAME
     MOVE 150 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 1 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 1 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 1 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [6]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 1 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [7]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 1 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 1 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 1 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [10]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 1 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [11]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 1 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [12]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 1 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [13]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 1 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 1 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 1 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [16]" TO WS-NAME
     MOVE -1.501 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 10 body yaw 30 death 1 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 5 TO WS-IV(2)
     MOVE 90 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF7-SETUP-ROTATIONS" USING WS-IN WS-OUT
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 0 sleeping 1 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 0 sleeping 1 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 0 sleeping 1 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [3]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 0 sleeping 1 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [4]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 0 sleeping 1 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [5]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 0 sleeping 1 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [6]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 0 sleeping 1 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 0 sleeping 1 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [8]" TO WS-NAME
     MOVE -1.501 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 0 sleeping 1 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 5 TO WS-IV(2)
     MOVE 90 TO WS-IV(3)
     MOVE 2 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF7-SETUP-ROTATIONS" USING WS-IN WS-OUT
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 2 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [1]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 2 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 2 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [3]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 2 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 2 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 2 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [6]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 2 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [7]" TO WS-NAME
     MOVE 25.455844123 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 2 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 2 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 2 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [10]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 2 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [11]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 2 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [12]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 2 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [13]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 2 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 2 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 2 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [16]" TO WS-NAME
     MOVE -1.501 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 setupRotations shaking 0 age 5 body yaw 90 death 2 sleeping 0 (count; code 3 rotate Y deg, 4 rotate Z deg, 2 scale, 1 translate) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF7-BODY-RENDER" USING WS-IN WS-OUT
     MOVE "1.6 body render translucent 1 visible 0 glowing 0 (mode 0 none 1 model render type 2 translucent cull 3 outline; 1 when tinted 0x26FFFFFF) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 body render translucent 1 visible 0 glowing 0 (mode 0 none 1 model render type 2 translucent cull 3 outline; 1 when tinted 0x26FFFFFF) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF7-BODY-RENDER" USING WS-IN WS-OUT
     MOVE "1.6 body render translucent 0 visible 1 glowing 0 (mode 0 none 1 model render type 2 translucent cull 3 outline; 1 when tinted 0x26FFFFFF) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 body render translucent 0 visible 1 glowing 0 (mode 0 none 1 model render type 2 translucent cull 3 outline; 1 when tinted 0x26FFFFFF) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF7-BODY-RENDER" USING WS-IN WS-OUT
     MOVE "1.6 body render translucent 0 visible 0 glowing 1 (mode 0 none 1 model render type 2 translucent cull 3 outline; 1 when tinted 0x26FFFFFF) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 body render translucent 0 visible 0 glowing 1 (mode 0 none 1 model render type 2 translucent cull 3 outline; 1 when tinted 0x26FFFFFF) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF7-BODY-RENDER" USING WS-IN WS-OUT
     MOVE "1.6 body render translucent 0 visible 0 glowing 0 (mode 0 none 1 model render type 2 translucent cull 3 outline; 1 when tinted 0x26FFFFFF) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 body render translucent 0 visible 0 glowing 0 (mode 0 none 1 model render type 2 translucent cull 3 outline; 1 when tinted 0x26FFFFFF) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF7-BODY-RENDER" USING WS-IN WS-OUT
     MOVE "1.6 body render translucent 1 visible 1 glowing 1 (mode 0 none 1 model render type 2 translucent cull 3 outline; 1 when tinted 0x26FFFFFF) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 body render translucent 1 visible 1 glowing 1 (mode 0 none 1 model render type 2 translucent cull 3 outline; 1 when tinted 0x26FFFFFF) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF7-OVERLAY-PIXEL" USING WS-IN WS-OUT
     MOVE "1.6 overlay texel x 0 y 0 as signed ARGB" TO WS-NAME
     MOVE -1291911168 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 7 TO WS-IV(2)
     CALL "EF7-OVERLAY-PIXEL" USING WS-IN WS-OUT
     MOVE "1.6 overlay texel x 5 y 7 as signed ARGB" TO WS-NAME
     MOVE -1291911168 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 8 TO WS-IV(2)
     CALL "EF7-OVERLAY-PIXEL" USING WS-IN WS-OUT
     MOVE "1.6 overlay texel x 3 y 8 as signed ARGB" TO WS-NAME
     MOVE -654311425 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 8 TO WS-IV(2)
     CALL "EF7-OVERLAY-PIXEL" USING WS-IN WS-OUT
     MOVE "1.6 overlay texel x 0 y 8 as signed ARGB" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 15 TO WS-IV(1)
     MOVE 8 TO WS-IV(2)
     CALL "EF7-OVERLAY-PIXEL" USING WS-IN WS-OUT
     MOVE "1.6 overlay texel x 15 y 8 as signed ARGB" TO WS-NAME
     MOVE 1073741823 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 15 TO WS-IV(2)
     CALL "EF7-OVERLAY-PIXEL" USING WS-IN WS-OUT
     MOVE "1.6 overlay texel x 7 y 15 as signed ARGB" TO WS-NAME
     MOVE -1509949441 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 15 TO WS-IV(1)
     MOVE 15 TO WS-IV(2)
     CALL "EF7-OVERLAY-PIXEL" USING WS-IN WS-OUT
     MOVE "1.6 overlay texel x 15 y 15 as signed ARGB" TO WS-NAME
     MOVE 1073741823 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 8 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF7-OVERLAY-PIXEL" USING WS-IN WS-OUT
     MOVE "1.6 overlay texel x 8 y 0 as signed ARGB" TO WS-NAME
     MOVE -1291911168 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF7-OVERLAY-COORDS" USING WS-IN WS-OUT
     MOVE "1.6 overlay coordinates white progress 0 red 0 (u, v) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 overlay coordinates white progress 0 red 0 (u, v) [2]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF7-OVERLAY-COORDS" USING WS-IN WS-OUT
     MOVE "1.6 overlay coordinates white progress 0 red 1 (u, v) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 overlay coordinates white progress 0 red 1 (u, v) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF7-OVERLAY-COORDS" USING WS-IN WS-OUT
     MOVE "1.6 overlay coordinates white progress 1 red 0 (u, v) [1]" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 overlay coordinates white progress 1 red 0 (u, v) [2]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF7-OVERLAY-COORDS" USING WS-IN WS-OUT
     MOVE "1.6 overlay coordinates white progress 0.5 red 1 (u, v) [1]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 overlay coordinates white progress 0.5 red 1 (u, v) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.99 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF7-OVERLAY-COORDS" USING WS-IN WS-OUT
     MOVE "1.6 overlay coordinates white progress 0.99 red 0 (u, v) [1]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 overlay coordinates white progress 0.99 red 0 (u, v) [2]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 12 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF7-LIGHT" USING WS-IN WS-OUT
     MOVE "1.6 light coords block 5 sky 12 block light override 0" TO WS-NAME
     MOVE 12582992 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF7-LIGHT" USING WS-IN WS-OUT
     MOVE "1.6 light coords block 0 sky 0 block light override 0" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 15 TO WS-IV(1)
     MOVE 15 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF7-LIGHT" USING WS-IN WS-OUT
     MOVE "1.6 light coords block 15 sky 15 block light override 0" TO WS-NAME
     MOVE 15728880 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 9 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF7-LIGHT" USING WS-IN WS-OUT
     MOVE "1.6 light coords block 3 sky 9 block light override 1" TO WS-NAME
     MOVE 9437424 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF7-SHADOW" USING WS-IN WS-OUT
     MOVE "1.6 shadow radius 0.5 scale 1" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1.5 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     CALL "EF7-SHADOW" USING WS-IN WS-OUT
     MOVE "1.6 shadow radius 1.5 scale 2" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.25 TO WS-IV(1)
     MOVE 0.5 TO WS-IV(2)
     CALL "EF7-SHADOW" USING WS-IN WS-OUT
     MOVE "1.6 shadow radius 0.25 scale 0.5" TO WS-NAME
     MOVE 0.125 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-7§1 Shared pieces read in this round: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-7§1 Shared pieces read in this round: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-7-1.
