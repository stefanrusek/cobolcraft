*> Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md sections 10 and 11 (item frame and painting): the render offset, the frame's submit (step x 0.46875, X and Y rotations by direction, translate 0.5 or 0.4375,
*> the map branch and the item branch), the lights of a glow frame (max(5, block), 15728880, 15728850), the worked example and Validation 8; the painting's Y rotation, the block position of each cell's light and the vertices of the six faces of a cell
*> (the table of 11 evaluated symbolically, Validation 9).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-9-10.
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
 PROCEDURE DIVISION.
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF9-FRAME-OFFSET" USING WS-IN WS-OUT
     MOVE "10 render offset of direction 0 [1]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 render offset of direction 0 [2]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 render offset of direction 0 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF9-FRAME-OFFSET" USING WS-IN WS-OUT
     MOVE "10 render offset of direction 1 [1]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 render offset of direction 1 [2]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 render offset of direction 1 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE -1 TO WS-IV(2)
     CALL "EF9-FRAME-OFFSET" USING WS-IN WS-OUT
     MOVE "10 render offset of direction 2 [1]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 render offset of direction 2 [2]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 render offset of direction 2 [3]" TO WS-NAME
     MOVE -0.3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF9-FRAME-OFFSET" USING WS-IN WS-OUT
     MOVE "10 render offset of direction 3 [1]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 render offset of direction 3 [2]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 render offset of direction 3 [3]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE -1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF9-FRAME-OFFSET" USING WS-IN WS-OUT
     MOVE "10 render offset of direction 4 [1]" TO WS-NAME
     MOVE -0.3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 render offset of direction 4 [2]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 render offset of direction 4 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF9-FRAME-OFFSET" USING WS-IN WS-OUT
     MOVE "10 render offset of direction 5 [1]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 render offset of direction 5 [2]" TO WS-NAME
     MOVE -0.25 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 render offset of direction 5 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [1]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [4]" TO WS-NAME
     MOVE -0.46875 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [7]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [11]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [17]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [19]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [22]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [23]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [24]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 0 map 0 [25]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [1]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [4]" TO WS-NAME
     MOVE -0.46875 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [7]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [11]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [17]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [19]" TO WS-NAME
     MOVE 135.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [22]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [23]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [24]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 3 map 0 [25]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [1]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [4]" TO WS-NAME
     MOVE -0.46875 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [7]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [11]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [19]" TO WS-NAME
     MOVE 315.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [22]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [23]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [24]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 7 map 0 [25]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [1]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [4]" TO WS-NAME
     MOVE -0.46875 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [7]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [11]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [17]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [19]" TO WS-NAME
     MOVE 90.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [22]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [23]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [24]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [25]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [26]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(26) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [27]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(27) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [28]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(28) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [29]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(29) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [30]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(30) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [31]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(31) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [32]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(32) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [33]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(33) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [34]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(34) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [35]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(35) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [36]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(36) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 5 map 1 [37]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(37) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [1]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [4]" TO WS-NAME
     MOVE -0.46875 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [7]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [11]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [17]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [19]" TO WS-NAME
     MOVE 180.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [22]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [23]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [24]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [25]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [26]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(26) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [27]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(27) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [28]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(28) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [29]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(29) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [30]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(30) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [31]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(31) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [32]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(32) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [33]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(33) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [34]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(34) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [35]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(35) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [36]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(36) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 0 rotation 2 map 1 [37]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(37) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [1]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [4]" TO WS-NAME
     MOVE -0.46875 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [7]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [11]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [19]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [22]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [23]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [24]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [25]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [26]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(26) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [27]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(27) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [28]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(28) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [29]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(29) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [30]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(30) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [31]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(31) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [32]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(32) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [33]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(33) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [34]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(34) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [35]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(35) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [36]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(36) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 0 invisible 1 rotation 0 map 1 [37]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(37) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [1]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [4]" TO WS-NAME
     MOVE 0.46875 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [7]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [11]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [17]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [19]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [22]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [23]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [24]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 0 map 0 [25]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [1]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [4]" TO WS-NAME
     MOVE 0.46875 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [7]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [11]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [17]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [19]" TO WS-NAME
     MOVE 135.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [22]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [23]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [24]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 3 map 0 [25]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [1]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [4]" TO WS-NAME
     MOVE 0.46875 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [7]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [11]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [19]" TO WS-NAME
     MOVE 315.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [22]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [23]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [24]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 7 map 0 [25]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [1]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [4]" TO WS-NAME
     MOVE 0.46875 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [7]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [11]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [17]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [19]" TO WS-NAME
     MOVE 90.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [22]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [23]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [24]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [25]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [26]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(26) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [27]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(27) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [28]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(28) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [29]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(29) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [30]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(30) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [31]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(31) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [32]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(32) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [33]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(33) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [34]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(34) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [35]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(35) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [36]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(36) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 5 map 1 [37]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(37) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [1]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [4]" TO WS-NAME
     MOVE 0.46875 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [7]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [11]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [17]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [19]" TO WS-NAME
     MOVE 180.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [22]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [23]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [24]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [25]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [26]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(26) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [27]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(27) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [28]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(28) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [29]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(29) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [30]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(30) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [31]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(31) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [32]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(32) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [33]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(33) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [34]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(34) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [35]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(35) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [36]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(36) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 0 rotation 2 map 1 [37]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(37) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [1]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [4]" TO WS-NAME
     MOVE 0.46875 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [7]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [11]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [19]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [22]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [23]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [24]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [25]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [26]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(26) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [27]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(27) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [28]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(28) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [29]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(29) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [30]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(30) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [31]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(31) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [32]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(32) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [33]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(33) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [34]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(34) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [35]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(35) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [36]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(36) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 1 invisible 1 rotation 0 map 1 [37]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(37) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [1]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [5]" TO WS-NAME
     MOVE -0.46875 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [17]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [19]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [22]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [23]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [24]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 0 map 0 [25]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [1]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [5]" TO WS-NAME
     MOVE -0.46875 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [17]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [19]" TO WS-NAME
     MOVE 135.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [22]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [23]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [24]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 3 map 0 [25]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [1]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [5]" TO WS-NAME
     MOVE -0.46875 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [19]" TO WS-NAME
     MOVE 315.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [22]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [23]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [24]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 7 map 0 [25]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [1]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [5]" TO WS-NAME
     MOVE -0.46875 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [17]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [19]" TO WS-NAME
     MOVE 90.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [22]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [23]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [24]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [25]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [26]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(26) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [27]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(27) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [28]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(28) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [29]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(29) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [30]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(30) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [31]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(31) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [32]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(32) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [33]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(33) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [34]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(34) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [35]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(35) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [36]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(36) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 5 map 1 [37]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(37) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [1]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [5]" TO WS-NAME
     MOVE -0.46875 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [17]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [19]" TO WS-NAME
     MOVE 180.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [22]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [23]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [24]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [25]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [26]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(26) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [27]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(27) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [28]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(28) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [29]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(29) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [30]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(30) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [31]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(31) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [32]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(32) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [33]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(33) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [34]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(34) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [35]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(35) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [36]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(36) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 0 rotation 2 map 1 [37]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(37) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [1]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [5]" TO WS-NAME
     MOVE -0.46875 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [19]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [22]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [23]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [24]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [25]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [26]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(26) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [27]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(27) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [28]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(28) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [29]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(29) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [30]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(30) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [31]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(31) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [32]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(32) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [33]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(33) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [34]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(34) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [35]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(35) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [36]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(36) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 2 invisible 1 rotation 0 map 1 [37]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(37) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [1]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [5]" TO WS-NAME
     MOVE 0.46875 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [11]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [17]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [19]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [22]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [23]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [24]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 0 map 0 [25]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [1]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [5]" TO WS-NAME
     MOVE 0.46875 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [11]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [17]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [19]" TO WS-NAME
     MOVE 135.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [22]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [23]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [24]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 3 map 0 [25]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [1]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [5]" TO WS-NAME
     MOVE 0.46875 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [11]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [19]" TO WS-NAME
     MOVE 315.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [22]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [23]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [24]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 7 map 0 [25]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [1]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [5]" TO WS-NAME
     MOVE 0.46875 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [11]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [17]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [19]" TO WS-NAME
     MOVE 90.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [22]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [23]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [24]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [25]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [26]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(26) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [27]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(27) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [28]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(28) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [29]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(29) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [30]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(30) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [31]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(31) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [32]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(32) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [33]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(33) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [34]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(34) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [35]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(35) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [36]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(36) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 5 map 1 [37]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(37) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [1]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [5]" TO WS-NAME
     MOVE 0.46875 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [11]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [17]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [19]" TO WS-NAME
     MOVE 180.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [22]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [23]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [24]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [25]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [26]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(26) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [27]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(27) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [28]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(28) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [29]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(29) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [30]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(30) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [31]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(31) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [32]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(32) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [33]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(33) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [34]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(34) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [35]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(35) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [36]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(36) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 0 rotation 2 map 1 [37]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(37) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [1]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [5]" TO WS-NAME
     MOVE 0.46875 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [11]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [19]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [22]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [23]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [24]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [25]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [26]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(26) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [27]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(27) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [28]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(28) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [29]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(29) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [30]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(30) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [31]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(31) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [32]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(32) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [33]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(33) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [34]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(34) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [35]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(35) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [36]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(36) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 3 invisible 1 rotation 0 map 1 [37]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(37) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [1]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [3]" TO WS-NAME
     MOVE -0.46875 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [11]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [17]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [19]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [22]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [23]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [24]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 0 map 0 [25]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [1]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [3]" TO WS-NAME
     MOVE -0.46875 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [11]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [17]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [19]" TO WS-NAME
     MOVE 135.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [22]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [23]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [24]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 3 map 0 [25]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [1]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [3]" TO WS-NAME
     MOVE -0.46875 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [11]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [19]" TO WS-NAME
     MOVE 315.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [22]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [23]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [24]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 7 map 0 [25]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [1]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [3]" TO WS-NAME
     MOVE -0.46875 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [11]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [17]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [19]" TO WS-NAME
     MOVE 90.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [22]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [23]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [24]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [25]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [26]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(26) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [27]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(27) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [28]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(28) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [29]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(29) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [30]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(30) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [31]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(31) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [32]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(32) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [33]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(33) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [34]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(34) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [35]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(35) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [36]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(36) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 5 map 1 [37]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(37) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [1]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [3]" TO WS-NAME
     MOVE -0.46875 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [11]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [17]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [19]" TO WS-NAME
     MOVE 180.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [22]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [23]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [24]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [25]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [26]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(26) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [27]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(27) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [28]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(28) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [29]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(29) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [30]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(30) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [31]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(31) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [32]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(32) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [33]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(33) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [34]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(34) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [35]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(35) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [36]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(36) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 0 rotation 2 map 1 [37]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(37) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [1]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [3]" TO WS-NAME
     MOVE -0.46875 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [11]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [19]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [22]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [23]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [24]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [25]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [26]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(26) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [27]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(27) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [28]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(28) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [29]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(29) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [30]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(30) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [31]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(31) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [32]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(32) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [33]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(33) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [34]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(34) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [35]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(35) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [36]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(36) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 4 invisible 1 rotation 0 map 1 [37]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(37) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [1]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [3]" TO WS-NAME
     MOVE 0.46875 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [11]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [17]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [19]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [22]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [23]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [24]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 0 map 0 [25]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [1]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [3]" TO WS-NAME
     MOVE 0.46875 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [11]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [17]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [19]" TO WS-NAME
     MOVE 135.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [22]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [23]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [24]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 3 map 0 [25]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [1]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [3]" TO WS-NAME
     MOVE 0.46875 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [11]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [19]" TO WS-NAME
     MOVE 315.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [22]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [23]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [24]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 7 map 0 [25]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [1]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [3]" TO WS-NAME
     MOVE 0.46875 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [11]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [17]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [19]" TO WS-NAME
     MOVE 90.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [22]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [23]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [24]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [25]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [26]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(26) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [27]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(27) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [28]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(28) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [29]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(29) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [30]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(30) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [31]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(31) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [32]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(32) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [33]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(33) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [34]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(34) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [35]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(35) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [36]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(36) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 5 map 1 [37]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(37) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [1]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [3]" TO WS-NAME
     MOVE 0.46875 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [11]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [17]" TO WS-NAME
     MOVE 0.4375 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [19]" TO WS-NAME
     MOVE 180.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [22]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [23]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [24]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [25]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [26]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(26) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [27]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(27) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [28]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(28) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [29]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(29) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [30]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(30) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [31]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(31) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [32]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(32) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [33]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(33) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [34]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(34) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [35]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(35) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [36]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(36) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 0 rotation 2 map 1 [37]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(37) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF9-FRAME-OPS" USING WS-IN WS-OUT
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [1]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [3]" TO WS-NAME
     MOVE 0.46875 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [11]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [19]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [22]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [23]" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [24]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [25]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [26]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(26) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [27]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(27) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [28]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(28) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [29]" TO WS-NAME
     MOVE 0.0078125 TO WS-E
     MOVE WS-OV(29) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [30]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(30) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [31]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(31) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [32]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(32) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [33]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(33) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [34]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(34) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [35]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(35) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [36]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(36) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 submit for direction 5 invisible 1 rotation 0 map 1 [37]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(37) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     CALL "EF9-FRAME-LIGHT" USING WS-IN WS-OUT
     MOVE "10 lights of glow 0 block light 3 [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 lights of glow 0 block light 3 [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 lights of glow 0 block light 3 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 12 TO WS-IV(2)
     CALL "EF9-FRAME-LIGHT" USING WS-IN WS-OUT
     MOVE "10 lights of glow 0 block light 12 [1]" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 lights of glow 0 block light 12 [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 lights of glow 0 block light 12 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     CALL "EF9-FRAME-LIGHT" USING WS-IN WS-OUT
     MOVE "10 lights of glow 1 block light 3 [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 lights of glow 1 block light 3 [2]" TO WS-NAME
     MOVE 15728880 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 lights of glow 1 block light 3 [3]" TO WS-NAME
     MOVE 15728850 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 5 TO WS-IV(2)
     CALL "EF9-FRAME-LIGHT" USING WS-IN WS-OUT
     MOVE "10 lights of glow 1 block light 5 [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 lights of glow 1 block light 5 [2]" TO WS-NAME
     MOVE 15728880 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 lights of glow 1 block light 5 [3]" TO WS-NAME
     MOVE 15728850 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 14 TO WS-IV(2)
     CALL "EF9-FRAME-LIGHT" USING WS-IN WS-OUT
     MOVE "10 lights of glow 1 block light 14 [1]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 lights of glow 1 block light 14 [2]" TO WS-NAME
     MOVE 15728880 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10 lights of glow 1 block light 14 [3]" TO WS-NAME
     MOVE 15728850 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     CALL "EF9-PAINTING-ROT" USING WS-IN WS-OUT
     MOVE "11 Y rotation of direction 3" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     CALL "EF9-PAINTING-ROT" USING WS-IN WS-OUT
     MOVE "11 Y rotation of direction 4" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     CALL "EF9-PAINTING-ROT" USING WS-IN WS-OUT
     MOVE "11 Y rotation of direction 2" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     CALL "EF9-PAINTING-ROT" USING WS-IN WS-OUT
     MOVE "11 Y rotation of direction 5" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 10.5 TO WS-IV(6)
     MOVE 64.5 TO WS-IV(7)
     MOVE -3.5 TO WS-IV(8)
     MOVE 10 TO WS-IV(9)
     MOVE -4 TO WS-IV(10)
     CALL "EF9-PAINTING-BLOCK" USING WS-IN WS-OUT
     MOVE "11 light block of cell (0, 0) of a 1 x 1 painting facing 2 [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (0, 0) of a 1 x 1 painting facing 2 [2]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (0, 0) of a 1 x 1 painting facing 2 [3]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 10.5 TO WS-IV(6)
     MOVE 64.5 TO WS-IV(7)
     MOVE -3.5 TO WS-IV(8)
     MOVE 10 TO WS-IV(9)
     MOVE -4 TO WS-IV(10)
     CALL "EF9-PAINTING-BLOCK" USING WS-IN WS-OUT
     MOVE "11 light block of cell (1, 0) of a 2 x 1 painting facing 2 [1]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (1, 0) of a 2 x 1 painting facing 2 [2]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (1, 0) of a 2 x 1 painting facing 2 [3]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 4 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     MOVE 2 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     MOVE 10.5 TO WS-IV(6)
     MOVE 64.5 TO WS-IV(7)
     MOVE -3.5 TO WS-IV(8)
     MOVE 10 TO WS-IV(9)
     MOVE -4 TO WS-IV(10)
     CALL "EF9-PAINTING-BLOCK" USING WS-IN WS-OUT
     MOVE "11 light block of cell (2, 1) of a 4 x 3 painting facing 2 [1]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (2, 1) of a 4 x 3 painting facing 2 [2]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (2, 1) of a 4 x 3 painting facing 2 [3]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 2 TO WS-IV(5)
     MOVE 10.5 TO WS-IV(6)
     MOVE 64.5 TO WS-IV(7)
     MOVE -3.5 TO WS-IV(8)
     MOVE 10 TO WS-IV(9)
     MOVE -4 TO WS-IV(10)
     CALL "EF9-PAINTING-BLOCK" USING WS-IN WS-OUT
     MOVE "11 light block of cell (0, 2) of a 3 x 3 painting facing 2 [1]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (0, 2) of a 3 x 3 painting facing 2 [2]" TO WS-NAME
     MOVE 65 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (0, 2) of a 3 x 3 painting facing 2 [3]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 10.5 TO WS-IV(6)
     MOVE 64.5 TO WS-IV(7)
     MOVE -3.5 TO WS-IV(8)
     MOVE 10 TO WS-IV(9)
     MOVE -4 TO WS-IV(10)
     CALL "EF9-PAINTING-BLOCK" USING WS-IN WS-OUT
     MOVE "11 light block of cell (0, 0) of a 1 x 1 painting facing 3 [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (0, 0) of a 1 x 1 painting facing 3 [2]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (0, 0) of a 1 x 1 painting facing 3 [3]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 10.5 TO WS-IV(6)
     MOVE 64.5 TO WS-IV(7)
     MOVE -3.5 TO WS-IV(8)
     MOVE 10 TO WS-IV(9)
     MOVE -4 TO WS-IV(10)
     CALL "EF9-PAINTING-BLOCK" USING WS-IN WS-OUT
     MOVE "11 light block of cell (1, 0) of a 2 x 1 painting facing 3 [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (1, 0) of a 2 x 1 painting facing 3 [2]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (1, 0) of a 2 x 1 painting facing 3 [3]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 4 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     MOVE 2 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     MOVE 10.5 TO WS-IV(6)
     MOVE 64.5 TO WS-IV(7)
     MOVE -3.5 TO WS-IV(8)
     MOVE 10 TO WS-IV(9)
     MOVE -4 TO WS-IV(10)
     CALL "EF9-PAINTING-BLOCK" USING WS-IN WS-OUT
     MOVE "11 light block of cell (2, 1) of a 4 x 3 painting facing 3 [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (2, 1) of a 4 x 3 painting facing 3 [2]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (2, 1) of a 4 x 3 painting facing 3 [3]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 2 TO WS-IV(5)
     MOVE 10.5 TO WS-IV(6)
     MOVE 64.5 TO WS-IV(7)
     MOVE -3.5 TO WS-IV(8)
     MOVE 10 TO WS-IV(9)
     MOVE -4 TO WS-IV(10)
     CALL "EF9-PAINTING-BLOCK" USING WS-IN WS-OUT
     MOVE "11 light block of cell (0, 2) of a 3 x 3 painting facing 3 [1]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (0, 2) of a 3 x 3 painting facing 3 [2]" TO WS-NAME
     MOVE 65 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (0, 2) of a 3 x 3 painting facing 3 [3]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 10.5 TO WS-IV(6)
     MOVE 64.5 TO WS-IV(7)
     MOVE -3.5 TO WS-IV(8)
     MOVE 10 TO WS-IV(9)
     MOVE -4 TO WS-IV(10)
     CALL "EF9-PAINTING-BLOCK" USING WS-IN WS-OUT
     MOVE "11 light block of cell (0, 0) of a 1 x 1 painting facing 4 [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (0, 0) of a 1 x 1 painting facing 4 [2]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (0, 0) of a 1 x 1 painting facing 4 [3]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 10.5 TO WS-IV(6)
     MOVE 64.5 TO WS-IV(7)
     MOVE -3.5 TO WS-IV(8)
     MOVE 10 TO WS-IV(9)
     MOVE -4 TO WS-IV(10)
     CALL "EF9-PAINTING-BLOCK" USING WS-IN WS-OUT
     MOVE "11 light block of cell (1, 0) of a 2 x 1 painting facing 4 [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (1, 0) of a 2 x 1 painting facing 4 [2]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (1, 0) of a 2 x 1 painting facing 4 [3]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 4 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     MOVE 2 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     MOVE 10.5 TO WS-IV(6)
     MOVE 64.5 TO WS-IV(7)
     MOVE -3.5 TO WS-IV(8)
     MOVE 10 TO WS-IV(9)
     MOVE -4 TO WS-IV(10)
     CALL "EF9-PAINTING-BLOCK" USING WS-IN WS-OUT
     MOVE "11 light block of cell (2, 1) of a 4 x 3 painting facing 4 [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (2, 1) of a 4 x 3 painting facing 4 [2]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (2, 1) of a 4 x 3 painting facing 4 [3]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 2 TO WS-IV(5)
     MOVE 10.5 TO WS-IV(6)
     MOVE 64.5 TO WS-IV(7)
     MOVE -3.5 TO WS-IV(8)
     MOVE 10 TO WS-IV(9)
     MOVE -4 TO WS-IV(10)
     CALL "EF9-PAINTING-BLOCK" USING WS-IN WS-OUT
     MOVE "11 light block of cell (0, 2) of a 3 x 3 painting facing 4 [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (0, 2) of a 3 x 3 painting facing 4 [2]" TO WS-NAME
     MOVE 65 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (0, 2) of a 3 x 3 painting facing 4 [3]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 10.5 TO WS-IV(6)
     MOVE 64.5 TO WS-IV(7)
     MOVE -3.5 TO WS-IV(8)
     MOVE 10 TO WS-IV(9)
     MOVE -4 TO WS-IV(10)
     CALL "EF9-PAINTING-BLOCK" USING WS-IN WS-OUT
     MOVE "11 light block of cell (0, 0) of a 1 x 1 painting facing 5 [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (0, 0) of a 1 x 1 painting facing 5 [2]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (0, 0) of a 1 x 1 painting facing 5 [3]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 10.5 TO WS-IV(6)
     MOVE 64.5 TO WS-IV(7)
     MOVE -3.5 TO WS-IV(8)
     MOVE 10 TO WS-IV(9)
     MOVE -4 TO WS-IV(10)
     CALL "EF9-PAINTING-BLOCK" USING WS-IN WS-OUT
     MOVE "11 light block of cell (1, 0) of a 2 x 1 painting facing 5 [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (1, 0) of a 2 x 1 painting facing 5 [2]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (1, 0) of a 2 x 1 painting facing 5 [3]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 4 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     MOVE 2 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     MOVE 10.5 TO WS-IV(6)
     MOVE 64.5 TO WS-IV(7)
     MOVE -3.5 TO WS-IV(8)
     MOVE 10 TO WS-IV(9)
     MOVE -4 TO WS-IV(10)
     CALL "EF9-PAINTING-BLOCK" USING WS-IN WS-OUT
     MOVE "11 light block of cell (2, 1) of a 4 x 3 painting facing 5 [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (2, 1) of a 4 x 3 painting facing 5 [2]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (2, 1) of a 4 x 3 painting facing 5 [3]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 2 TO WS-IV(5)
     MOVE 10.5 TO WS-IV(6)
     MOVE 64.5 TO WS-IV(7)
     MOVE -3.5 TO WS-IV(8)
     MOVE 10 TO WS-IV(9)
     MOVE -4 TO WS-IV(10)
     CALL "EF9-PAINTING-BLOCK" USING WS-IN WS-OUT
     MOVE "11 light block of cell (0, 2) of a 3 x 3 painting facing 5 [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (0, 2) of a 3 x 3 painting facing 5 [2]" TO WS-NAME
     MOVE 65 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 light block of cell (0, 2) of a 3 x 3 painting facing 5 [3]" TO WS-NAME
     MOVE -5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 1 x 1 painting cell (0, 0) face 0 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 0 [2]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 0 [3]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 0 [4]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 0 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 0 [6]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 0 [7]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 0 [8]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 0 [9]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 0 [10]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 0 [11]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 0 [12]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 0 [13]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 0 [14]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 0 [15]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 0 [16]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 0 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 0 [18]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 0 [19]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 0 [20]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 0 [21]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 1 x 1 painting cell (0, 0) face 1 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 1 [2]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 1 [3]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 1 [4]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 1 [5]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 1 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 1 [7]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 1 [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 1 [9]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 1 [10]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 1 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 1 [12]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 1 [13]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 1 [14]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 1 [16]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 1 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 1 [18]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 1 [19]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 1 [20]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 1 [21]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 2 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 1 x 1 painting cell (0, 0) face 2 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 2 [2]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 2 [3]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 2 [4]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 2 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 2 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 2 [7]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 2 [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 2 [9]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 2 [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 2 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 2 [12]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 2 [13]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 2 [14]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 2 [15]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 2 [16]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 2 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 2 [18]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 2 [19]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 2 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 2 [21]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 1 x 1 painting cell (0, 0) face 3 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 3 [2]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 3 [3]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 3 [4]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 3 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 3 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 3 [7]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 3 [8]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 3 [9]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 3 [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 3 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 3 [12]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 3 [13]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 3 [14]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 3 [15]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 3 [16]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 3 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 3 [18]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 3 [19]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 3 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 3 [21]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 4 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 1 x 1 painting cell (0, 0) face 4 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 4 [2]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 4 [3]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 4 [4]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 4 [5]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 4 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 4 [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 4 [8]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 4 [9]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 4 [10]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 4 [11]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 4 [12]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 4 [13]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 4 [14]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 4 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 4 [16]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 4 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 4 [18]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 4 [19]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 4 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 4 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 5 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 1 x 1 painting cell (0, 0) face 5 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 5 [2]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 5 [3]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 5 [4]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 5 [5]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 5 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 5 [7]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 5 [8]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 5 [9]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 5 [10]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 5 [11]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 5 [12]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 5 [13]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 5 [14]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 5 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 5 [16]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 5 [17]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 5 [18]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 5 [19]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 5 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 1 x 1 painting cell (0, 0) face 5 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 2 x 1 painting cell (0, 0) face 0 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 0 [2]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 0 [3]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 0 [4]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 0 [5]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 0 [6]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 0 [7]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 0 [8]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 0 [9]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 0 [10]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 0 [11]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 0 [12]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 0 [13]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 0 [14]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 0 [15]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 0 [16]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 0 [17]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 0 [18]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 0 [19]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 0 [20]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 0 [21]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 2 x 1 painting cell (0, 0) face 1 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 1 [2]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 1 [3]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 1 [4]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 1 [5]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 1 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 1 [7]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 1 [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 1 [9]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 1 [10]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 1 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 1 [12]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 1 [13]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 1 [14]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 1 [16]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 1 [17]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 1 [18]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 1 [19]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 1 [20]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 1 [21]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 2 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 2 x 1 painting cell (0, 0) face 2 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 2 [2]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 2 [3]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 2 [4]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 2 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 2 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 2 [7]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 2 [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 2 [9]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 2 [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 2 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 2 [12]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 2 [13]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 2 [14]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 2 [15]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 2 [16]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 2 [17]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 2 [18]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 2 [19]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 2 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 2 [21]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 2 x 1 painting cell (0, 0) face 3 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 3 [2]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 3 [3]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 3 [4]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 3 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 3 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 3 [7]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 3 [8]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 3 [9]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 3 [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 3 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 3 [12]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 3 [13]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 3 [14]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 3 [15]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 3 [16]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 3 [17]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 3 [18]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 3 [19]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 3 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 3 [21]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 4 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 2 x 1 painting cell (0, 0) face 4 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 5 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 2 x 1 painting cell (0, 0) face 5 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 5 [2]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 5 [3]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 5 [4]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 5 [5]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 5 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 5 [7]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 5 [8]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 5 [9]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 5 [10]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 5 [11]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 5 [12]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 5 [13]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 5 [14]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 5 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 5 [16]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 5 [17]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 5 [18]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 5 [19]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 5 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (0, 0) face 5 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 2 x 1 painting cell (1, 0) face 0 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 0 [2]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 0 [3]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 0 [4]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 0 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 0 [6]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 0 [7]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 0 [8]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 0 [9]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 0 [10]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 0 [11]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 0 [12]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 0 [13]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 0 [14]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 0 [15]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 0 [16]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 0 [17]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 0 [18]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 0 [19]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 0 [20]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 0 [21]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 2 x 1 painting cell (1, 0) face 1 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 1 [2]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 1 [3]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 1 [4]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 1 [5]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 1 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 1 [7]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 1 [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 1 [9]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 1 [10]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 1 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 1 [12]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 1 [13]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 1 [14]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 1 [16]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 1 [17]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 1 [18]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 1 [19]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 1 [20]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 1 [21]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 2 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 2 x 1 painting cell (1, 0) face 2 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 2 [2]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 2 [3]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 2 [4]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 2 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 2 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 2 [7]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 2 [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 2 [9]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 2 [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 2 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 2 [12]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 2 [13]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 2 [14]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 2 [15]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 2 [16]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 2 [17]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 2 [18]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 2 [19]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 2 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 2 [21]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 2 x 1 painting cell (1, 0) face 3 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 3 [2]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 3 [3]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 3 [4]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 3 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 3 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 3 [7]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 3 [8]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 3 [9]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 3 [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 3 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 3 [12]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 3 [13]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 3 [14]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 3 [15]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 3 [16]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 3 [17]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 3 [18]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 3 [19]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 3 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 3 [21]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 4 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 2 x 1 painting cell (1, 0) face 4 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 4 [2]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 4 [3]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 4 [4]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 4 [5]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 4 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 4 [7]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 4 [8]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 4 [9]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 4 [10]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 4 [11]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 4 [12]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 4 [13]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 4 [14]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 4 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 4 [16]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 4 [17]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 4 [18]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 4 [19]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 4 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 2 x 1 painting cell (1, 0) face 4 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 5 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 2 x 1 painting cell (1, 0) face 5 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (0, 0) face 0 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 0 [2]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 0 [3]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 0 [4]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 0 [5]" TO WS-NAME
     MOVE 0.666666667 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 0 [6]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 0 [7]" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 0 [8]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 0 [9]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 0 [10]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 0 [11]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 0 [12]" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 0 [13]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 0 [14]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 0 [15]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 0 [16]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 0 [17]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 0 [18]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 0 [19]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 0 [20]" TO WS-NAME
     MOVE 0.666666667 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 0 [21]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (0, 0) face 1 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 1 [2]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 1 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 1 [4]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 1 [5]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 1 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 1 [7]" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 1 [8]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 1 [9]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 1 [10]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 1 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 1 [12]" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 1 [13]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 1 [14]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 1 [16]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 1 [17]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 1 [18]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 1 [19]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 1 [20]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 1 [21]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 2 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (0, 0) face 2 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (0, 0) face 3 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 3 [2]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 3 [3]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 3 [4]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 3 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 3 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 3 [7]" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 3 [8]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 3 [9]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 3 [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 3 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 3 [12]" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 3 [13]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 3 [14]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 3 [15]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 3 [16]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 3 [17]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 3 [18]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 3 [19]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 3 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 3 [21]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 4 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (0, 0) face 4 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 5 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (0, 0) face 5 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 5 [2]" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 5 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 5 [4]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 5 [5]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 5 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 5 [7]" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 5 [8]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 5 [9]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 5 [10]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 5 [11]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 5 [12]" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 5 [13]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 5 [14]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 5 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 5 [16]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 5 [17]" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 5 [18]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 5 [19]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 5 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 0) face 5 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (1, 0) face 0 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 0 [2]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 0 [3]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 0 [4]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 0 [5]" TO WS-NAME
     MOVE 0.333333333 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 0 [6]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 0 [7]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 0 [8]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 0 [9]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 0 [10]" TO WS-NAME
     MOVE 0.666666667 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 0 [11]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 0 [12]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 0 [13]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 0 [14]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 0 [15]" TO WS-NAME
     MOVE 0.666666667 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 0 [16]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 0 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 0 [18]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 0 [19]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 0 [20]" TO WS-NAME
     MOVE 0.333333333 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 0 [21]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (1, 0) face 1 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 1 [2]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 1 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 1 [4]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 1 [5]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 1 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 1 [7]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 1 [8]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 1 [9]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 1 [10]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 1 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 1 [12]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 1 [13]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 1 [14]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 1 [16]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 1 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 1 [18]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 1 [19]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 1 [20]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 1 [21]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 2 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (1, 0) face 2 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (1, 0) face 3 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 3 [2]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 3 [3]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 3 [4]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 3 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 3 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 3 [7]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 3 [8]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 3 [9]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 3 [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 3 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 3 [12]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 3 [13]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 3 [14]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 3 [15]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 3 [16]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 3 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 3 [18]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 3 [19]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 3 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 0) face 3 [21]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 4 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (1, 0) face 4 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 5 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (1, 0) face 5 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (2, 0) face 0 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 0 [2]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 0 [3]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 0 [4]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 0 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 0 [6]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 0 [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 0 [8]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 0 [9]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 0 [10]" TO WS-NAME
     MOVE 0.333333333 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 0 [11]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 0 [12]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 0 [13]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 0 [14]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 0 [15]" TO WS-NAME
     MOVE 0.333333333 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 0 [16]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 0 [17]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 0 [18]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 0 [19]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 0 [20]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 0 [21]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (2, 0) face 1 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 1 [2]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 1 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 1 [4]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 1 [5]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 1 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 1 [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 1 [8]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 1 [9]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 1 [10]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 1 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 1 [12]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 1 [13]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 1 [14]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 1 [16]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 1 [17]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 1 [18]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 1 [19]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 1 [20]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 1 [21]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 2 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (2, 0) face 2 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (2, 0) face 3 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 3 [2]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 3 [3]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 3 [4]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 3 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 3 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 3 [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 3 [8]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 3 [9]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 3 [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 3 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 3 [12]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 3 [13]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 3 [14]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 3 [15]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 3 [16]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 3 [17]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 3 [18]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 3 [19]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 3 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 3 [21]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 4 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (2, 0) face 4 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 4 [2]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 4 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 4 [4]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 4 [5]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 4 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 4 [7]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 4 [8]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 4 [9]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 4 [10]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 4 [11]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 4 [12]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 4 [13]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 4 [14]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 4 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 4 [16]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 4 [17]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 4 [18]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 4 [19]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 4 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 0) face 4 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 5 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (2, 0) face 5 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (0, 1) face 0 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 0 [2]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 0 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 0 [4]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 0 [5]" TO WS-NAME
     MOVE 0.666666667 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 0 [6]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 0 [7]" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 0 [8]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 0 [9]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 0 [10]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 0 [11]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 0 [12]" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 0 [13]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 0 [14]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 0 [15]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 0 [16]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 0 [17]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 0 [18]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 0 [19]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 0 [20]" TO WS-NAME
     MOVE 0.666666667 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 0 [21]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (0, 1) face 1 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 1 [2]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 1 [3]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 1 [4]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 1 [5]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 1 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 1 [7]" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 1 [8]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 1 [9]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 1 [10]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 1 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 1 [12]" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 1 [13]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 1 [14]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 1 [16]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 1 [17]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 1 [18]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 1 [19]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 1 [20]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 1 [21]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 2 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (0, 1) face 2 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 2 [2]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 2 [3]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 2 [4]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 2 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 2 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 2 [7]" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 2 [8]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 2 [9]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 2 [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 2 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 2 [12]" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 2 [13]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 2 [14]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 2 [15]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 2 [16]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 2 [17]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 2 [18]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 2 [19]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 2 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 2 [21]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (0, 1) face 3 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 4 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (0, 1) face 4 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 5 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (0, 1) face 5 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 5 [2]" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 5 [3]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 5 [4]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 5 [5]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 5 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 5 [7]" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 5 [8]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 5 [9]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 5 [10]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 5 [11]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 5 [12]" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 5 [13]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 5 [14]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 5 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 5 [16]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 5 [17]" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 5 [18]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 5 [19]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 5 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (0, 1) face 5 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (1, 1) face 0 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 0 [2]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 0 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 0 [4]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 0 [5]" TO WS-NAME
     MOVE 0.333333333 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 0 [6]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 0 [7]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 0 [8]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 0 [9]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 0 [10]" TO WS-NAME
     MOVE 0.666666667 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 0 [11]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 0 [12]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 0 [13]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 0 [14]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 0 [15]" TO WS-NAME
     MOVE 0.666666667 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 0 [16]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 0 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 0 [18]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 0 [19]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 0 [20]" TO WS-NAME
     MOVE 0.333333333 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 0 [21]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (1, 1) face 1 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 1 [2]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 1 [3]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 1 [4]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 1 [5]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 1 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 1 [7]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 1 [8]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 1 [9]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 1 [10]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 1 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 1 [12]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 1 [13]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 1 [14]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 1 [16]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 1 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 1 [18]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 1 [19]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 1 [20]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 1 [21]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 2 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (1, 1) face 2 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 2 [2]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 2 [3]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 2 [4]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 2 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 2 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 2 [7]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 2 [8]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 2 [9]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 2 [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 2 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 2 [12]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 2 [13]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 2 [14]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 2 [15]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 2 [16]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 2 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 2 [18]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 2 [19]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 2 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (1, 1) face 2 [21]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (1, 1) face 3 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 4 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (1, 1) face 4 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 5 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (1, 1) face 5 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (2, 1) face 0 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 0 [2]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 0 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 0 [4]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 0 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 0 [6]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 0 [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 0 [8]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 0 [9]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 0 [10]" TO WS-NAME
     MOVE 0.333333333 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 0 [11]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 0 [12]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 0 [13]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 0 [14]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 0 [15]" TO WS-NAME
     MOVE 0.333333333 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 0 [16]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 0 [17]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 0 [18]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 0 [19]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 0 [20]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 0 [21]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (2, 1) face 1 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 1 [2]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 1 [3]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 1 [4]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 1 [5]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 1 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 1 [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 1 [8]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 1 [9]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 1 [10]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 1 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 1 [12]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 1 [13]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 1 [14]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 1 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 1 [16]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 1 [17]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 1 [18]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 1 [19]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 1 [20]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 1 [21]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 2 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (2, 1) face 2 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 2 [2]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 2 [3]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 2 [4]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 2 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 2 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 2 [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 2 [8]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 2 [9]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 2 [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 2 [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 2 [12]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 2 [13]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 2 [14]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 2 [15]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 2 [16]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 2 [17]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 2 [18]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 2 [19]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 2 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 2 [21]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (2, 1) face 3 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 4 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (2, 1) face 4 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 4 [2]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 4 [3]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 4 [4]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 4 [5]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 4 [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 4 [7]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 4 [8]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 4 [9]" TO WS-NAME
     MOVE 0.03125 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 4 [10]" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 4 [11]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 4 [12]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 4 [13]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 4 [14]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 4 [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 4 [16]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 4 [17]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 4 [18]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 4 [19]" TO WS-NAME
     MOVE -0.03125 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 4 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "11 3 x 2 painting cell (2, 1) face 4 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 5 TO WS-IV(5)
     CALL "EF9-PAINTING-FACE" USING WS-IN WS-OUT
     MOVE "11 3 x 2 painting cell (2, 1) face 5 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-9§10: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-9§10: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-9-10.
