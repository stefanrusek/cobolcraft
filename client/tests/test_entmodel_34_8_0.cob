*> Acceptance test of docs/protocol/34-entity-models-8-aquatic-nautilus-boats.md section 0 (conventions and engine facts): 0.1 the part draw ops and the box extent with grow, 0.2 the root scaling pose (0.5 and 1.5), 0.3 the sine and cosine table values,
*> 0.4 the animation clock in milliseconds and applyWalk, 0.5 the baby model swap, the entity render type and the shadow radius.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-8-0.
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
     CALL "EF8-PART-OPS" USING WS-IN WS-OUT
     MOVE "0.1 part ops for pose (0, 0, 0, 0, 0, 0, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 part ops for pose (0, 0, 0, 0, 0, 0, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 part ops for pose (0, 0, 0, 0, 0, 0, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale) [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 part ops for pose (0, 0, 0, 0, 0, 0, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale) [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 part ops for pose (0, 0, 0, 0, 0, 0, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale) [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE 8 TO WS-IV(1)
     MOVE -16 TO WS-IV(2)
     MOVE 4 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 0.1 TO WS-IV(5)
     MOVE 0.2 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     MOVE 1 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     CALL "EF8-PART-OPS" USING WS-IN WS-OUT
     MOVE "0.1 part ops for pose (8, -16, 4, 0.5, 0.1, 0.2, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 part ops for pose (8, -16, 4, 0.5, 0.1, 0.2, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 part ops for pose (8, -16, 4, 0.5, 0.1, 0.2, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale) [3]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 part ops for pose (8, -16, 4, 0.5, 0.1, 0.2, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale) [4]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 part ops for pose (8, -16, 4, 0.5, 0.1, 0.2, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale) [5]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 part ops for pose (8, -16, 4, 0.5, 0.1, 0.2, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale) [6]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 part ops for pose (8, -16, 4, 0.5, 0.1, 0.2, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale) [7]" TO WS-NAME
     MOVE 0.2 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 part ops for pose (8, -16, 4, 0.5, 0.1, 0.2, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale) [8]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 part ops for pose (8, -16, 4, 0.5, 0.1, 0.2, 1, 1, 1) (count; code 1 translate, 7 rotationZYX z y x, 2 scale) [9]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0.5 TO WS-IV(7)
     MOVE 0.5 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     CALL "EF8-PART-OPS" USING WS-IN WS-OUT
     MOVE "0.1 part ops for pose (1, 2, 3, 0, 0, 0, 0.5, 0.5, 0.5) (count; code 1 translate, 7 rotationZYX z y x, 2 scale) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 part ops for pose (1, 2, 3, 0, 0, 0, 0.5, 0.5, 0.5) (count; code 1 translate, 7 rotationZYX z y x, 2 scale) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 part ops for pose (1, 2, 3, 0, 0, 0, 0.5, 0.5, 0.5) (count; code 1 translate, 7 rotationZYX z y x, 2 scale) [3]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 part ops for pose (1, 2, 3, 0, 0, 0, 0.5, 0.5, 0.5) (count; code 1 translate, 7 rotationZYX z y x, 2 scale) [4]" TO WS-NAME
     MOVE 0.125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 part ops for pose (1, 2, 3, 0, 0, 0, 0.5, 0.5, 0.5) (count; code 1 translate, 7 rotationZYX z y x, 2 scale) [5]" TO WS-NAME
     MOVE 0.1875 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 part ops for pose (1, 2, 3, 0, 0, 0, 0.5, 0.5, 0.5) (count; code 1 translate, 7 rotationZYX z y x, 2 scale) [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 part ops for pose (1, 2, 3, 0, 0, 0, 0.5, 0.5, 0.5) (count; code 1 translate, 7 rotationZYX z y x, 2 scale) [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 part ops for pose (1, 2, 3, 0, 0, 0, 0.5, 0.5, 0.5) (count; code 1 translate, 7 rotationZYX z y x, 2 scale) [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 part ops for pose (1, 2, 3, 0, 0, 0, 0.5, 0.5, 0.5) (count; code 1 translate, 7 rotationZYX z y x, 2 scale) [9]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE -6 TO WS-IV(1)
     MOVE 12 TO WS-IV(2)
     MOVE 0.02 TO WS-IV(3)
     CALL "EF8-BOX-EXTENT" USING WS-IN WS-OUT
     MOVE "0.1 box extent origin -6 size 12 grow 0.02 (from, to) [1]" TO WS-NAME
     MOVE -6.02 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 box extent origin -6 size 12 grow 0.02 (from, to) [2]" TO WS-NAME
     MOVE 6.02 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 8 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF8-BOX-EXTENT" USING WS-IN WS-OUT
     MOVE "0.1 box extent origin 0 size 8 grow 0 (from, to) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 box extent origin 0 size 8 grow 0 (from, to) [2]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE -1 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 0.5 TO WS-IV(3)
     CALL "EF8-BOX-EXTENT" USING WS-IN WS-OUT
     MOVE "0.1 box extent origin -1 size 2 grow 0.5 (from, to) [1]" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.1 box extent origin -1 size 2 grow 0.5 (from, to) [2]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     CALL "EF8-ROOT-POSE" USING WS-IN WS-OUT
     MOVE "0.2 root pose scale 0.5 (scale, y) [1]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.2 root pose scale 0.5 (scale, y) [2]" TO WS-NAME
     MOVE 12.008 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1.5 TO WS-IV(1)
     CALL "EF8-ROOT-POSE" USING WS-IN WS-OUT
     MOVE "0.2 root pose scale 1.5 (scale, y) [1]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.2 root pose scale 1.5 (scale, y) [2]" TO WS-NAME
     MOVE -12.008 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF8-ROOT-POSE" USING WS-IN WS-OUT
     MOVE "0.2 root pose scale 1 (scale, y) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.2 root pose scale 1 (scale, y) [2]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     CALL "EF8-ROOT-POSE" USING WS-IN WS-OUT
     MOVE "0.2 root pose scale 2 (scale, y) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.2 root pose scale 2 (scale, y) [2]" TO WS-NAME
     MOVE -24.016 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     CALL "EF8-ROOT-POSE" USING WS-IN WS-OUT
     MOVE "0.2 s 0.5 gives scale 0.5 and y +12.008 [1]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.2 s 0.5 gives scale 0.5 and y +12.008 [2]" TO WS-NAME
     MOVE 12.008 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1.5 TO WS-IV(1)
     CALL "EF8-ROOT-POSE" USING WS-IN WS-OUT
     MOVE "0.2 s 1.5 gives scale 1.5 and y -12.008 [1]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.2 s 1.5 gives scale 1.5 and y -12.008 [2]" TO WS-NAME
     MOVE -12.008 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF8-MTH-SIN" USING WS-IN WS-OUT
     MOVE "0.3 Mth.sin(0) table entry" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF8-MTH-COS" USING WS-IN WS-OUT
     MOVE "0.3 Mth.cos(0) table entry" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     CALL "EF8-MTH-SIN" USING WS-IN WS-OUT
     MOVE "0.3 Mth.sin(0.5) table entry" TO WS-NAME
     MOVE 0.479409622 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     CALL "EF8-MTH-COS" USING WS-IN WS-OUT
     MOVE "0.3 Mth.cos(0.5) table entry" TO WS-NAME
     MOVE 0.877591257 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF8-MTH-SIN" USING WS-IN WS-OUT
     MOVE "0.3 Mth.sin(1) table entry" TO WS-NAME
     MOVE 0.841451385 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF8-MTH-COS" USING WS-IN WS-OUT
     MOVE "0.3 Mth.cos(1) table entry" TO WS-NAME
     MOVE 0.540332829 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2.5 TO WS-IV(1)
     CALL "EF8-MTH-SIN" USING WS-IN WS-OUT
     MOVE "0.3 Mth.sin(2.5) table entry" TO WS-NAME
     MOVE 0.598544793 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2.5 TO WS-IV(1)
     CALL "EF8-MTH-COS" USING WS-IN WS-OUT
     MOVE "0.3 Mth.cos(2.5) table entry" TO WS-NAME
     MOVE -0.80108934 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE -1.2 TO WS-IV(1)
     CALL "EF8-MTH-SIN" USING WS-IN WS-OUT
     MOVE "0.3 Mth.sin(-1.2) table entry" TO WS-NAME
     MOVE -0.932023312 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE -1.2 TO WS-IV(1)
     CALL "EF8-MTH-COS" USING WS-IN WS-OUT
     MOVE "0.3 Mth.cos(-1.2) table entry" TO WS-NAME
     MOVE 0.362308966 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10 TO WS-IV(1)
     CALL "EF8-MTH-SIN" USING WS-IN WS-OUT
     MOVE "0.3 Mth.sin(10) table entry" TO WS-NAME
     MOVE -0.54395808 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10 TO WS-IV(1)
     CALL "EF8-MTH-COS" USING WS-IN WS-OUT
     MOVE "0.3 Mth.cos(10) table entry" TO WS-NAME
     MOVE -0.839112392 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 100.3 TO WS-IV(1)
     CALL "EF8-MTH-SIN" USING WS-IN WS-OUT
     MOVE "0.3 Mth.sin(100.3) table entry" TO WS-NAME
     MOVE -0.229005448 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 100.3 TO WS-IV(1)
     CALL "EF8-MTH-COS" USING WS-IN WS-OUT
     MOVE "0.3 Mth.cos(100.3) table entry" TO WS-NAME
     MOVE 0.973425141 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF8-ANIM-MS" USING WS-IN WS-OUT
     MOVE "0.4 animation time ms age 10 start 0" TO WS-NAME
     MOVE 500 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10.5 TO WS-IV(1)
     MOVE 4 TO WS-IV(2)
     CALL "EF8-ANIM-MS" USING WS-IN WS-OUT
     MOVE "0.4 animation time ms age 10.5 start 4" TO WS-NAME
     MOVE 325 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3.25 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     CALL "EF8-ANIM-MS" USING WS-IN WS-OUT
     MOVE "0.4 animation time ms age 3.25 start 3" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 100 TO WS-IV(1)
     MOVE -2 TO WS-IV(2)
     CALL "EF8-ANIM-MS" USING WS-IN WS-OUT
     MOVE "0.4 animation time ms age 100 start -2" TO WS-NAME
     MOVE 5100 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2.0 TO WS-IV(1)
     MOVE 0.4 TO WS-IV(2)
     MOVE 1.5 TO WS-IV(3)
     MOVE 2.5 TO WS-IV(4)
     CALL "EF8-WALK" USING WS-IN WS-OUT
     MOVE "0.4 applyWalk pos 2.0 speed 0.4 factors 1.5 2.5 (ms, strength) [1]" TO WS-NAME
     MOVE 150 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.4 applyWalk pos 2.0 speed 0.4 factors 1.5 2.5 (ms, strength) [2]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     MOVE 0.2 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 2.5 TO WS-IV(4)
     CALL "EF8-WALK" USING WS-IN WS-OUT
     MOVE "0.4 applyWalk pos 0.5 speed 0.2 factors 1 2.5 (ms, strength) [1]" TO WS-NAME
     MOVE 25 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.4 applyWalk pos 0.5 speed 0.2 factors 1 2.5 (ms, strength) [2]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3.5 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 9 TO WS-IV(3)
     MOVE 100 TO WS-IV(4)
     CALL "EF8-WALK" USING WS-IN WS-OUT
     MOVE "0.4 applyWalk pos 3.5 speed 1 factors 9 100 (ms, strength) [1]" TO WS-NAME
     MOVE 1575 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.4 applyWalk pos 3.5 speed 1 factors 9 100 (ms, strength) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF8-AGEABLE-MODEL" USING WS-IN WS-OUT
     MOVE "0.5 baby model swap baby 0" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF8-AGEABLE-MODEL" USING WS-IN WS-OUT
     MOVE "0.5 baby model swap baby 1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.7 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF8-SHADOW" USING WS-IN WS-OUT
     MOVE "0.5 shadow radius base 0.7 scale 1 ageScale 1 (base x scale, with ageScale) [1]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.5 shadow radius base 0.7 scale 1 ageScale 1 (base x scale, with ageScale) [2]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.7 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 0.5 TO WS-IV(3)
     CALL "EF8-SHADOW" USING WS-IN WS-OUT
     MOVE "0.5 shadow radius base 0.7 scale 2 ageScale 0.5 (base x scale, with ageScale) [1]" TO WS-NAME
     MOVE 1.4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.5 shadow radius base 0.7 scale 2 ageScale 0.5 (base x scale, with ageScale) [2]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0.5 TO WS-IV(3)
     CALL "EF8-SHADOW" USING WS-IN WS-OUT
     MOVE "0.5 shadow radius base 0.5 scale 1 ageScale 0.5 (base x scale, with ageScale) [1]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "0.5 shadow radius base 0.5 scale 1 ageScale 0.5 (base x scale, with ageScale) [2]" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE SPACES TO WS-X120
     MOVE 0 TO WS-IV(1)
     CALL "EF8-RENDER-TYPE" USING WS-IN WS-X120
     MOVE "0.5 default render type name" TO WS-NAME
     MOVE "entityCutout" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     STOP RUN.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-8§0 Conventions and engine facts used by every section: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-8§0 Conventions and engine facts used by every section: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-8-0.
