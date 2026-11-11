*> Acceptance test of docs/protocol/34-entity-models-6-overworld-hostiles-arthropods-slimes.md section 1 (shared facts): 1.1 the table conventions (box unwrap rectangles, MeshTransformer.scaling on the cave spider root, retainExactParts and
*> retainPartsAndChildren), 1.2 the degrees to radians constant, 1.3 the summary table of the sixteen renderers (texture size, shadow radius, flip degrees, layers in order).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-6-1.
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
 01 WS-LAYER              PIC X(32).
 01 WS-OK                 BINARY-LONG.
 01 WS-PARTS              BINARY-LONG.
 01 WS-CUBES              BINARY-LONG.
 01 WS-P                  BINARY-LONG.
 01 WS-PN                 PIC X(24).
 COPY EMCHKW.

 01 WS-X32               PIC X(32).
 01 WS-X32B              PIC X(32).
 01 WS-X120              PIC X(120).
 01 WS-X24               PIC X(24).
 01 WS-X40               PIC X(40).
 01 WS-FL                BINARY-LONG.
 01 WS-RR.
    05 WS-RRV             PIC X(100) OCCURS 80 TIMES.
 01 WS-ZERO               FLOAT-LONG VALUE 0.
 01 WS-SC                 FLOAT-LONG.
 01 WS-LN                PIC X(32).
 01 WS-NAMES.
    05 WS-NM              PIC X(24) OCCURS 8 TIMES.
 01 WS-CNT                BINARY-LONG.
 01 WS-FOUND              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 8 TO WS-IV(3)
     MOVE 8 TO WS-IV(4)
     MOVE 8 TO WS-IV(5)
     CALL "EF6-BOX-UNWRAP" USING WS-IN WS-OUT
     MOVE "1.1 box unwrap u 0 v 0 size 8x8x8 (u0..u4, v0..v2) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 0 v 0 size 8x8x8 (u0..u4, v0..v2) [2]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 0 v 0 size 8x8x8 (u0..u4, v0..v2) [3]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 0 v 0 size 8x8x8 (u0..u4, v0..v2) [4]" TO WS-NAME
     MOVE 24 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 0 v 0 size 8x8x8 (u0..u4, v0..v2) [5]" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 0 v 0 size 8x8x8 (u0..u4, v0..v2) [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 0 v 0 size 8x8x8 (u0..u4, v0..v2) [7]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 0 v 0 size 8x8x8 (u0..u4, v0..v2) [8]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 16 TO WS-IV(1)
     MOVE 16 TO WS-IV(2)
     MOVE 8 TO WS-IV(3)
     MOVE 12 TO WS-IV(4)
     MOVE 4 TO WS-IV(5)
     CALL "EF6-BOX-UNWRAP" USING WS-IN WS-OUT
     MOVE "1.1 box unwrap u 16 v 16 size 8x12x4 (u0..u4, v0..v2) [1]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 16 v 16 size 8x12x4 (u0..u4, v0..v2) [2]" TO WS-NAME
     MOVE 20 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 16 v 16 size 8x12x4 (u0..u4, v0..v2) [3]" TO WS-NAME
     MOVE 28 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 16 v 16 size 8x12x4 (u0..u4, v0..v2) [4]" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 16 v 16 size 8x12x4 (u0..u4, v0..v2) [5]" TO WS-NAME
     MOVE 40 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 16 v 16 size 8x12x4 (u0..u4, v0..v2) [6]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 16 v 16 size 8x12x4 (u0..u4, v0..v2) [7]" TO WS-NAME
     MOVE 20 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 16 v 16 size 8x12x4 (u0..u4, v0..v2) [8]" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 56 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 30 TO WS-IV(4)
     MOVE 2 TO WS-IV(5)
     CALL "EF6-BOX-UNWRAP" USING WS-IN WS-OUT
     MOVE "1.1 box unwrap u 56 v 0 size 2x30x2 (u0..u4, v0..v2) [1]" TO WS-NAME
     MOVE 56 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 56 v 0 size 2x30x2 (u0..u4, v0..v2) [2]" TO WS-NAME
     MOVE 58 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 56 v 0 size 2x30x2 (u0..u4, v0..v2) [3]" TO WS-NAME
     MOVE 60 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 56 v 0 size 2x30x2 (u0..u4, v0..v2) [4]" TO WS-NAME
     MOVE 62 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 56 v 0 size 2x30x2 (u0..u4, v0..v2) [5]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 56 v 0 size 2x30x2 (u0..u4, v0..v2) [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 56 v 0 size 2x30x2 (u0..u4, v0..v2) [7]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 56 v 0 size 2x30x2 (u0..u4, v0..v2) [8]" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 9 TO WS-IV(2)
     MOVE 8 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 8 TO WS-IV(5)
     CALL "EF6-BOX-UNWRAP" USING WS-IN WS-OUT
     MOVE "1.1 box unwrap u 0 v 9 size 8x1x8 (u0..u4, v0..v2) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 0 v 9 size 8x1x8 (u0..u4, v0..v2) [2]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 0 v 9 size 8x1x8 (u0..u4, v0..v2) [3]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 0 v 9 size 8x1x8 (u0..u4, v0..v2) [4]" TO WS-NAME
     MOVE 24 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 0 v 9 size 8x1x8 (u0..u4, v0..v2) [5]" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 0 v 9 size 8x1x8 (u0..u4, v0..v2) [6]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 0 v 9 size 8x1x8 (u0..u4, v0..v2) [7]" TO WS-NAME
     MOVE 17 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 box unwrap u 0 v 9 size 8x1x8 (u0..u4, v0..v2) [8]" TO WS-NAME
     MOVE 18 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "P head root 0 15 -3 0 0 0" TO WS-RRV(1)
     MOVE "C head 32 4 -4 -4 -8 8 8 8 0 0" TO WS-RRV(2)
     MOVE 2 TO WS-CNT
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-RR WS-CNT WS-ZERO
     MOVE 0.7 TO WS-SC
     CALL "EMD-SCALE-ROOT" USING EMM-MODEL WS-SC
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -2.1 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.7 TO WS-IV(1)
     MOVE 15 TO WS-IV(2)
     CALL "EF6-SCALED-Y" USING WS-IN WS-OUT
     MOVE "1.1 vertex y 15 after scaling 0.7 about the ground point 24.016" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.7 TO WS-IV(1)
     MOVE 24 TO WS-IV(2)
     CALL "EF6-SCALED-Y" USING WS-IN WS-OUT
     MOVE "1.1 vertex y 24 after scaling 0.7 about the ground point 24.016" TO WS-NAME
     MOVE 24.0048 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2.35 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF6-SCALED-Y" USING WS-IN WS-OUT
     MOVE "1.1 vertex y 0 after scaling 2.35 about the ground point 24.016" TO WS-NAME
     MOVE -32.4216 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 24 TO WS-IV(2)
     CALL "EF6-SCALED-Y" USING WS-IN WS-OUT
     MOVE "1.1 vertex y 24 after scaling 1 about the ground point 24.016" TO WS-NAME
     MOVE 24.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     CALL "EF6-SCALED-Y" USING WS-IN WS-OUT
     MOVE "1.1 vertex y 10 after scaling 0.5 about the ground point 24.016" TO WS-NAME
     MOVE 17.008 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "P head root 0 -13 0 0 0 0" TO WS-RRV(1)
     MOVE "C head 0 0 -4 -8 -4 8 8 8 0 0" TO WS-RRV(2)
     MOVE "P hat head 0 0 0 0 0 0" TO WS-RRV(3)
     MOVE "C hat 0 16 -4 -8 -4 8 8 8 -0.5 0" TO WS-RRV(4)
     MOVE "P body root 0 -14 0 0 0 0" TO WS-RRV(5)
     MOVE "C body 32 16 -4 0 -2 8 12 4 0 0" TO WS-RRV(6)
     MOVE "P right_arm root -5 -12 0 0 0 0" TO WS-RRV(7)
     MOVE "C right_arm 56 0 -1 -2 -1 2 30 2 0 0" TO WS-RRV(8)
     MOVE "P left_arm root 5 -12 0 0 0 0" TO WS-RRV(9)
     MOVE "C left_arm 56 0 -1 -2 -1 2 30 2 0 1" TO WS-RRV(10)
     MOVE "P right_leg root -2 -5 0 0 0 0" TO WS-RRV(11)
     MOVE "C right_leg 56 0 -1 0 -1 2 30 2 0 0" TO WS-RRV(12)
     MOVE "P left_leg root 2 -5 0 0 0 0" TO WS-RRV(13)
     MOVE "C left_leg 56 0 -1 0 -1 2 30 2 0 1" TO WS-RRV(14)
     MOVE 14 TO WS-CNT
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-RR WS-CNT WS-ZERO
     MOVE "head" TO WS-NM(1)
     MOVE 1 TO WS-CNT
     CALL "EF6-RETAIN" USING EMM-MODEL 1 WS-NAMES WS-CNT
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts head : cuboids kept on head" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "hat" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts head : cuboids kept on hat" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts head : cuboids kept on body" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts head : cuboids kept on right_arm" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts head : cuboids kept on left_arm" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts head : cuboids kept on right_leg" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts head : cuboids kept on left_leg" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "P head root 0 -13 0 0 0 0" TO WS-RRV(1)
     MOVE "C head 0 0 -4 -8 -4 8 8 8 0 0" TO WS-RRV(2)
     MOVE "P hat head 0 0 0 0 0 0" TO WS-RRV(3)
     MOVE "C hat 0 16 -4 -8 -4 8 8 8 -0.5 0" TO WS-RRV(4)
     MOVE "P body root 0 -14 0 0 0 0" TO WS-RRV(5)
     MOVE "C body 32 16 -4 0 -2 8 12 4 0 0" TO WS-RRV(6)
     MOVE "P right_arm root -5 -12 0 0 0 0" TO WS-RRV(7)
     MOVE "C right_arm 56 0 -1 -2 -1 2 30 2 0 0" TO WS-RRV(8)
     MOVE "P left_arm root 5 -12 0 0 0 0" TO WS-RRV(9)
     MOVE "C left_arm 56 0 -1 -2 -1 2 30 2 0 1" TO WS-RRV(10)
     MOVE "P right_leg root -2 -5 0 0 0 0" TO WS-RRV(11)
     MOVE "C right_leg 56 0 -1 0 -1 2 30 2 0 0" TO WS-RRV(12)
     MOVE "P left_leg root 2 -5 0 0 0 0" TO WS-RRV(13)
     MOVE "C left_leg 56 0 -1 0 -1 2 30 2 0 1" TO WS-RRV(14)
     MOVE 14 TO WS-CNT
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-RR WS-CNT WS-ZERO
     MOVE "head" TO WS-NM(1)
     MOVE "hat" TO WS-NM(2)
     MOVE 2 TO WS-CNT
     CALL "EF6-RETAIN" USING EMM-MODEL 1 WS-NAMES WS-CNT
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts head/hat : cuboids kept on head" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "hat" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts head/hat : cuboids kept on hat" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts head/hat : cuboids kept on body" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts head/hat : cuboids kept on right_arm" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts head/hat : cuboids kept on left_arm" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts head/hat : cuboids kept on right_leg" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts head/hat : cuboids kept on left_leg" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "P head root 0 -13 0 0 0 0" TO WS-RRV(1)
     MOVE "C head 0 0 -4 -8 -4 8 8 8 0 0" TO WS-RRV(2)
     MOVE "P hat head 0 0 0 0 0 0" TO WS-RRV(3)
     MOVE "C hat 0 16 -4 -8 -4 8 8 8 -0.5 0" TO WS-RRV(4)
     MOVE "P body root 0 -14 0 0 0 0" TO WS-RRV(5)
     MOVE "C body 32 16 -4 0 -2 8 12 4 0 0" TO WS-RRV(6)
     MOVE "P right_arm root -5 -12 0 0 0 0" TO WS-RRV(7)
     MOVE "C right_arm 56 0 -1 -2 -1 2 30 2 0 0" TO WS-RRV(8)
     MOVE "P left_arm root 5 -12 0 0 0 0" TO WS-RRV(9)
     MOVE "C left_arm 56 0 -1 -2 -1 2 30 2 0 1" TO WS-RRV(10)
     MOVE "P right_leg root -2 -5 0 0 0 0" TO WS-RRV(11)
     MOVE "C right_leg 56 0 -1 0 -1 2 30 2 0 0" TO WS-RRV(12)
     MOVE "P left_leg root 2 -5 0 0 0 0" TO WS-RRV(13)
     MOVE "C left_leg 56 0 -1 0 -1 2 30 2 0 1" TO WS-RRV(14)
     MOVE 14 TO WS-CNT
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-RR WS-CNT WS-ZERO
     MOVE "hat" TO WS-NM(1)
     MOVE 1 TO WS-CNT
     CALL "EF6-RETAIN" USING EMM-MODEL 1 WS-NAMES WS-CNT
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts hat : cuboids kept on head" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "hat" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts hat : cuboids kept on hat" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts hat : cuboids kept on body" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts hat : cuboids kept on right_arm" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts hat : cuboids kept on left_arm" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts hat : cuboids kept on right_leg" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts hat : cuboids kept on left_leg" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "P head root 0 -13 0 0 0 0" TO WS-RRV(1)
     MOVE "C head 0 0 -4 -8 -4 8 8 8 0 0" TO WS-RRV(2)
     MOVE "P hat head 0 0 0 0 0 0" TO WS-RRV(3)
     MOVE "C hat 0 16 -4 -8 -4 8 8 8 -0.5 0" TO WS-RRV(4)
     MOVE "P body root 0 -14 0 0 0 0" TO WS-RRV(5)
     MOVE "C body 32 16 -4 0 -2 8 12 4 0 0" TO WS-RRV(6)
     MOVE "P right_arm root -5 -12 0 0 0 0" TO WS-RRV(7)
     MOVE "C right_arm 56 0 -1 -2 -1 2 30 2 0 0" TO WS-RRV(8)
     MOVE "P left_arm root 5 -12 0 0 0 0" TO WS-RRV(9)
     MOVE "C left_arm 56 0 -1 -2 -1 2 30 2 0 1" TO WS-RRV(10)
     MOVE "P right_leg root -2 -5 0 0 0 0" TO WS-RRV(11)
     MOVE "C right_leg 56 0 -1 0 -1 2 30 2 0 0" TO WS-RRV(12)
     MOVE "P left_leg root 2 -5 0 0 0 0" TO WS-RRV(13)
     MOVE "C left_leg 56 0 -1 0 -1 2 30 2 0 1" TO WS-RRV(14)
     MOVE 14 TO WS-CNT
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-RR WS-CNT WS-ZERO
     MOVE "body" TO WS-NM(1)
     MOVE "left_leg" TO WS-NM(2)
     MOVE 2 TO WS-CNT
     CALL "EF6-RETAIN" USING EMM-MODEL 1 WS-NAMES WS-CNT
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts body/left_leg : cuboids kept on head" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "hat" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts body/left_leg : cuboids kept on hat" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts body/left_leg : cuboids kept on body" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts body/left_leg : cuboids kept on right_arm" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts body/left_leg : cuboids kept on left_arm" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts body/left_leg : cuboids kept on right_leg" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainExactParts body/left_leg : cuboids kept on left_leg" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "P head root 0 -13 0 0 0 0" TO WS-RRV(1)
     MOVE "C head 0 0 -4 -8 -4 8 8 8 0 0" TO WS-RRV(2)
     MOVE "P hat head 0 0 0 0 0 0" TO WS-RRV(3)
     MOVE "C hat 0 16 -4 -8 -4 8 8 8 -0.5 0" TO WS-RRV(4)
     MOVE "P body root 0 -14 0 0 0 0" TO WS-RRV(5)
     MOVE "C body 32 16 -4 0 -2 8 12 4 0 0" TO WS-RRV(6)
     MOVE "P right_arm root -5 -12 0 0 0 0" TO WS-RRV(7)
     MOVE "C right_arm 56 0 -1 -2 -1 2 30 2 0 0" TO WS-RRV(8)
     MOVE "P left_arm root 5 -12 0 0 0 0" TO WS-RRV(9)
     MOVE "C left_arm 56 0 -1 -2 -1 2 30 2 0 1" TO WS-RRV(10)
     MOVE "P right_leg root -2 -5 0 0 0 0" TO WS-RRV(11)
     MOVE "C right_leg 56 0 -1 0 -1 2 30 2 0 0" TO WS-RRV(12)
     MOVE "P left_leg root 2 -5 0 0 0 0" TO WS-RRV(13)
     MOVE "C left_leg 56 0 -1 0 -1 2 30 2 0 1" TO WS-RRV(14)
     MOVE 14 TO WS-CNT
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-RR WS-CNT WS-ZERO
     MOVE "head" TO WS-NM(1)
     MOVE 1 TO WS-CNT
     CALL "EF6-RETAIN" USING EMM-MODEL 2 WS-NAMES WS-CNT
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren head : cuboids kept on head" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "hat" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren head : cuboids kept on hat" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren head : cuboids kept on body" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren head : cuboids kept on right_arm" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren head : cuboids kept on left_arm" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren head : cuboids kept on right_leg" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren head : cuboids kept on left_leg" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "P head root 0 -13 0 0 0 0" TO WS-RRV(1)
     MOVE "C head 0 0 -4 -8 -4 8 8 8 0 0" TO WS-RRV(2)
     MOVE "P hat head 0 0 0 0 0 0" TO WS-RRV(3)
     MOVE "C hat 0 16 -4 -8 -4 8 8 8 -0.5 0" TO WS-RRV(4)
     MOVE "P body root 0 -14 0 0 0 0" TO WS-RRV(5)
     MOVE "C body 32 16 -4 0 -2 8 12 4 0 0" TO WS-RRV(6)
     MOVE "P right_arm root -5 -12 0 0 0 0" TO WS-RRV(7)
     MOVE "C right_arm 56 0 -1 -2 -1 2 30 2 0 0" TO WS-RRV(8)
     MOVE "P left_arm root 5 -12 0 0 0 0" TO WS-RRV(9)
     MOVE "C left_arm 56 0 -1 -2 -1 2 30 2 0 1" TO WS-RRV(10)
     MOVE "P right_leg root -2 -5 0 0 0 0" TO WS-RRV(11)
     MOVE "C right_leg 56 0 -1 0 -1 2 30 2 0 0" TO WS-RRV(12)
     MOVE "P left_leg root 2 -5 0 0 0 0" TO WS-RRV(13)
     MOVE "C left_leg 56 0 -1 0 -1 2 30 2 0 1" TO WS-RRV(14)
     MOVE 14 TO WS-CNT
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-RR WS-CNT WS-ZERO
     MOVE "hat" TO WS-NM(1)
     MOVE 1 TO WS-CNT
     CALL "EF6-RETAIN" USING EMM-MODEL 2 WS-NAMES WS-CNT
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren hat : cuboids kept on head" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "hat" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren hat : cuboids kept on hat" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren hat : cuboids kept on body" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren hat : cuboids kept on right_arm" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren hat : cuboids kept on left_arm" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren hat : cuboids kept on right_leg" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren hat : cuboids kept on left_leg" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "P head root 0 -13 0 0 0 0" TO WS-RRV(1)
     MOVE "C head 0 0 -4 -8 -4 8 8 8 0 0" TO WS-RRV(2)
     MOVE "P hat head 0 0 0 0 0 0" TO WS-RRV(3)
     MOVE "C hat 0 16 -4 -8 -4 8 8 8 -0.5 0" TO WS-RRV(4)
     MOVE "P body root 0 -14 0 0 0 0" TO WS-RRV(5)
     MOVE "C body 32 16 -4 0 -2 8 12 4 0 0" TO WS-RRV(6)
     MOVE "P right_arm root -5 -12 0 0 0 0" TO WS-RRV(7)
     MOVE "C right_arm 56 0 -1 -2 -1 2 30 2 0 0" TO WS-RRV(8)
     MOVE "P left_arm root 5 -12 0 0 0 0" TO WS-RRV(9)
     MOVE "C left_arm 56 0 -1 -2 -1 2 30 2 0 1" TO WS-RRV(10)
     MOVE "P right_leg root -2 -5 0 0 0 0" TO WS-RRV(11)
     MOVE "C right_leg 56 0 -1 0 -1 2 30 2 0 0" TO WS-RRV(12)
     MOVE "P left_leg root 2 -5 0 0 0 0" TO WS-RRV(13)
     MOVE "C left_leg 56 0 -1 0 -1 2 30 2 0 1" TO WS-RRV(14)
     MOVE 14 TO WS-CNT
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-RR WS-CNT WS-ZERO
     MOVE "head" TO WS-NM(1)
     MOVE "arms" TO WS-NM(2)
     MOVE 2 TO WS-CNT
     CALL "EF6-RETAIN" USING EMM-MODEL 2 WS-NAMES WS-CNT
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren head/arms : cuboids kept on head" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "hat" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren head/arms : cuboids kept on hat" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren head/arms : cuboids kept on body" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren head/arms : cuboids kept on right_arm" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren head/arms : cuboids kept on left_arm" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren head/arms : cuboids kept on right_leg" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren head/arms : cuboids kept on left_leg" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "P head root 0 -13 0 0 0 0" TO WS-RRV(1)
     MOVE "C head 0 0 -4 -8 -4 8 8 8 0 0" TO WS-RRV(2)
     MOVE "P hat head 0 0 0 0 0 0" TO WS-RRV(3)
     MOVE "C hat 0 16 -4 -8 -4 8 8 8 -0.5 0" TO WS-RRV(4)
     MOVE "P body root 0 -14 0 0 0 0" TO WS-RRV(5)
     MOVE "C body 32 16 -4 0 -2 8 12 4 0 0" TO WS-RRV(6)
     MOVE "P right_arm root -5 -12 0 0 0 0" TO WS-RRV(7)
     MOVE "C right_arm 56 0 -1 -2 -1 2 30 2 0 0" TO WS-RRV(8)
     MOVE "P left_arm root 5 -12 0 0 0 0" TO WS-RRV(9)
     MOVE "C left_arm 56 0 -1 -2 -1 2 30 2 0 1" TO WS-RRV(10)
     MOVE "P right_leg root -2 -5 0 0 0 0" TO WS-RRV(11)
     MOVE "C right_leg 56 0 -1 0 -1 2 30 2 0 0" TO WS-RRV(12)
     MOVE "P left_leg root 2 -5 0 0 0 0" TO WS-RRV(13)
     MOVE "C left_leg 56 0 -1 0 -1 2 30 2 0 1" TO WS-RRV(14)
     MOVE 14 TO WS-CNT
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-RR WS-CNT WS-ZERO
     MOVE "right_arm" TO WS-NM(1)
     MOVE "left_arm" TO WS-NM(2)
     MOVE "body" TO WS-NM(3)
     MOVE 3 TO WS-CNT
     CALL "EF6-RETAIN" USING EMM-MODEL 2 WS-NAMES WS-CNT
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren right_arm/left_arm/body : cuboids kept on head" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "hat" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren right_arm/left_arm/body : cuboids kept on hat" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren right_arm/left_arm/body : cuboids kept on body" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren right_arm/left_arm/body : cuboids kept on right_arm" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren right_arm/left_arm/body : cuboids kept on left_arm" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren right_arm/left_arm/body : cuboids kept on right_leg" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "1.1 retainPartsAndChildren right_arm/left_arm/body : cuboids kept on left_leg" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-NCUBES(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE 90 TO WS-IV(1)
     CALL "EF6-DEG-TO-RAD" USING WS-IN WS-OUT
     MOVE "1.2 90 degrees in radians (float constant 0.017453292)" TO WS-NAME
     MOVE 1.57079628 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "creeper" TO WS-X24
     CALL "EF6-INFO" USING WS-X24 WS-OUT WS-X32
     MOVE "1.3 creeper found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 creeper main model layer" TO WS-NAME
     MOVE "CREEPER" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.3 creeper texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 creeper texture height" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 creeper shadow radius" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 creeper flip degrees (0 when the entity has no model flip)" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 creeper layers added" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "creeper" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF6-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.3 creeper layer 1" TO WS-NAME
     MOVE "CreeperPowerLayer" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "enderman" TO WS-X24
     CALL "EF6-INFO" USING WS-X24 WS-OUT WS-X32
     MOVE "1.3 enderman found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 enderman main model layer" TO WS-NAME
     MOVE "ENDERMAN" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.3 enderman texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 enderman texture height" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 enderman shadow radius" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 enderman flip degrees (0 when the entity has no model flip)" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 enderman layers added" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "enderman" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF6-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.3 enderman layer 1" TO WS-NAME
     MOVE "EnderEyesLayer" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "enderman" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF6-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.3 enderman layer 2" TO WS-NAME
     MOVE "CarriedBlockLayer" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "endermite" TO WS-X24
     CALL "EF6-INFO" USING WS-X24 WS-OUT WS-X32
     MOVE "1.3 endermite found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 endermite main model layer" TO WS-NAME
     MOVE "ENDERMITE" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.3 endermite texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 endermite texture height" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 endermite shadow radius" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 endermite flip degrees (0 when the entity has no model flip)" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 endermite layers added" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "silverfish" TO WS-X24
     CALL "EF6-INFO" USING WS-X24 WS-OUT WS-X32
     MOVE "1.3 silverfish found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 silverfish main model layer" TO WS-NAME
     MOVE "SILVERFISH" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.3 silverfish texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 silverfish texture height" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 silverfish shadow radius" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 silverfish flip degrees (0 when the entity has no model flip)" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 silverfish layers added" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "spider" TO WS-X24
     CALL "EF6-INFO" USING WS-X24 WS-OUT WS-X32
     MOVE "1.3 spider found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 spider main model layer" TO WS-NAME
     MOVE "SPIDER" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.3 spider texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 spider texture height" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 spider shadow radius" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 spider flip degrees (0 when the entity has no model flip)" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 spider layers added" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "spider" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF6-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.3 spider layer 1" TO WS-NAME
     MOVE "SpiderEyesLayer" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "cave_spider" TO WS-X24
     CALL "EF6-INFO" USING WS-X24 WS-OUT WS-X32
     MOVE "1.3 cave_spider found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 cave_spider main model layer" TO WS-NAME
     MOVE "CAVE_SPIDER" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.3 cave_spider texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 cave_spider texture height" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 cave_spider shadow radius" TO WS-NAME
     MOVE 0.56 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 cave_spider flip degrees (0 when the entity has no model flip)" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 cave_spider layers added" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "cave_spider" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF6-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.3 cave_spider layer 1" TO WS-NAME
     MOVE "SpiderEyesLayer" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "slime" TO WS-X24
     CALL "EF6-INFO" USING WS-X24 WS-OUT WS-X32
     MOVE "1.3 slime found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 slime main model layer" TO WS-NAME
     MOVE "SLIME" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.3 slime texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 slime texture height" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 slime shadow radius" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 slime flip degrees (0 when the entity has no model flip)" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 slime layers added" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "slime" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF6-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.3 slime layer 1" TO WS-NAME
     MOVE "SlimeOuterLayer" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "magma_cube" TO WS-X24
     CALL "EF6-INFO" USING WS-X24 WS-OUT WS-X32
     MOVE "1.3 magma_cube found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 magma_cube main model layer" TO WS-NAME
     MOVE "MAGMA_CUBE" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.3 magma_cube texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 magma_cube texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 magma_cube shadow radius" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 magma_cube flip degrees (0 when the entity has no model flip)" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 magma_cube layers added" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "sulfur_cube" TO WS-X24
     CALL "EF6-INFO" USING WS-X24 WS-OUT WS-X32
     MOVE "1.3 sulfur_cube found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 sulfur_cube main model layer" TO WS-NAME
     MOVE "SULFUR_CUBE" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.3 sulfur_cube texture width" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 sulfur_cube texture height" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 sulfur_cube shadow radius" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 sulfur_cube flip degrees (0 when the entity has no model flip)" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 sulfur_cube layers added" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "sulfur_cube" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF6-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.3 sulfur_cube layer 1" TO WS-NAME
     MOVE "SulfurCubeInnerLayer" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "sulfur_cube" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF6-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.3 sulfur_cube layer 2" TO WS-NAME
     MOVE "CustomHeadLayer" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "warden" TO WS-X24
     CALL "EF6-INFO" USING WS-X24 WS-OUT WS-X32
     MOVE "1.3 warden found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 warden main model layer" TO WS-NAME
     MOVE "WARDEN" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.3 warden texture width" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 warden texture height" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 warden shadow radius" TO WS-NAME
     MOVE 0.9 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 warden flip degrees (0 when the entity has no model flip)" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 warden layers added" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "warden" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF6-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.3 warden layer 1" TO WS-NAME
     MOVE "LivingEntityEmissiveLayer" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "warden" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF6-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.3 warden layer 2" TO WS-NAME
     MOVE "LivingEntityEmissiveLayer" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "warden" TO WS-X24
     MOVE 3 TO WS-FL
     CALL "EF6-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.3 warden layer 3" TO WS-NAME
     MOVE "LivingEntityEmissiveLayer" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "warden" TO WS-X24
     MOVE 4 TO WS-FL
     CALL "EF6-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.3 warden layer 4" TO WS-NAME
     MOVE "LivingEntityEmissiveLayer" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "warden" TO WS-X24
     MOVE 5 TO WS-FL
     CALL "EF6-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.3 warden layer 5" TO WS-NAME
     MOVE "LivingEntityEmissiveLayer" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "breeze" TO WS-X24
     CALL "EF6-INFO" USING WS-X24 WS-OUT WS-X32
     MOVE "1.3 breeze found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 breeze main model layer" TO WS-NAME
     MOVE "BREEZE" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.3 breeze texture width" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 breeze texture height" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 breeze shadow radius" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 breeze flip degrees (0 when the entity has no model flip)" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 breeze layers added" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "breeze" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF6-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.3 breeze layer 1" TO WS-NAME
     MOVE "BreezeWindLayer" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "breeze" TO WS-X24
     MOVE 2 TO WS-FL
     CALL "EF6-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.3 breeze layer 2" TO WS-NAME
     MOVE "BreezeEyesLayer" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "phantom" TO WS-X24
     CALL "EF6-INFO" USING WS-X24 WS-OUT WS-X32
     MOVE "1.3 phantom found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 phantom main model layer" TO WS-NAME
     MOVE "PHANTOM" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.3 phantom texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 phantom texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 phantom shadow radius" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 phantom flip degrees (0 when the entity has no model flip)" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 phantom layers added" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "phantom" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF6-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.3 phantom layer 1" TO WS-NAME
     MOVE "PhantomEyesLayer" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "guardian" TO WS-X24
     CALL "EF6-INFO" USING WS-X24 WS-OUT WS-X32
     MOVE "1.3 guardian found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 guardian main model layer" TO WS-NAME
     MOVE "GUARDIAN" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.3 guardian texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 guardian texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 guardian shadow radius" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 guardian flip degrees (0 when the entity has no model flip)" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 guardian layers added" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "elder_guardian" TO WS-X24
     CALL "EF6-INFO" USING WS-X24 WS-OUT WS-X32
     MOVE "1.3 elder_guardian found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 elder_guardian main model layer" TO WS-NAME
     MOVE "ELDER_GUARDIAN" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.3 elder_guardian texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 elder_guardian texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 elder_guardian shadow radius" TO WS-NAME
     MOVE 1.2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 elder_guardian flip degrees (0 when the entity has no model flip)" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 elder_guardian layers added" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "shulker" TO WS-X24
     CALL "EF6-INFO" USING WS-X24 WS-OUT WS-X32
     MOVE "1.3 shulker found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 shulker main model layer" TO WS-NAME
     MOVE "SHULKER" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.3 shulker texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 shulker texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 shulker shadow radius" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 shulker flip degrees (0 when the entity has no model flip)" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 shulker layers added" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "shulker_bullet" TO WS-X24
     CALL "EF6-INFO" USING WS-X24 WS-OUT WS-X32
     MOVE "1.3 shulker_bullet found" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 shulker_bullet main model layer" TO WS-NAME
     MOVE "SHULKER_BULLET" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "1.3 shulker_bullet texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 shulker_bullet texture height" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 shulker_bullet shadow radius" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 shulker_bullet flip degrees (0 when the entity has no model flip)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 shulker_bullet layers added" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "zombie" TO WS-X24
     CALL "EF6-INFO" USING WS-X24 WS-OUT WS-X32
     MOVE "1.3 an entity of another part is not found" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "creeper" TO WS-X24
     MOVE 2 TO WS-FL
     MOVE "x" TO WS-X32
     CALL "EF6-INFO-LAYER" USING WS-X24 WS-FL WS-X32
     MOVE "1.3 a layer past the end is blank" TO WS-NAME
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "sulfur_cube" TO WS-X24
     CALL "EF6-INFO" USING WS-X24 WS-OUT WS-X32
     MOVE "1.3 the baby sulfur cube layer width (SULFUR_CUBE_SMALL)" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 the baby sulfur cube layer height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "creeper" TO WS-X24
     CALL "EF6-INFO" USING WS-X24 WS-OUT WS-X32
     MOVE "1.3 other entities have the same baby size" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-6§1 Shared facts used by this part: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-6§1 Shared facts used by this part: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-6-1.
