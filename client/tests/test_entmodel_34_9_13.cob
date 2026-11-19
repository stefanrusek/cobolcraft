*> Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 13 (falling blocks and primed TNT): the TNT submit (translate, swell scale below f = 10, Y rotations, worked values of 13.2), the white flash overlay,
*> the falling block's translation, shouldRender (the landed state hides the entity) and the block position of the lookup.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-9-13.
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
     MOVE -1 TO WS-IV(1)
     CALL "EF9-TNT-OPS" USING WS-IN WS-OUT
     MOVE "13.2 TNT pose for f = -1 [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -1 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -1 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -1 [4]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -1 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -1 [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -1 [7]" TO WS-NAME
     MOVE 1.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -1 [8]" TO WS-NAME
     MOVE 1.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -1 [9]" TO WS-NAME
     MOVE 1.3 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -1 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -1 [11]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -1 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -1 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -1 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -1 [15]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -1 [16]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -1 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -1 [18]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -1 [19]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -1 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -1 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE -0.5 TO WS-IV(1)
     CALL "EF9-TNT-OPS" USING WS-IN WS-OUT
     MOVE "13.2 TNT pose for f = -0.5 [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -0.5 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -0.5 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -0.5 [4]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -0.5 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -0.5 [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -0.5 [7]" TO WS-NAME
     MOVE 1.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -0.5 [8]" TO WS-NAME
     MOVE 1.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -0.5 [9]" TO WS-NAME
     MOVE 1.3 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -0.5 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -0.5 [11]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -0.5 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -0.5 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -0.5 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -0.5 [15]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -0.5 [16]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -0.5 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -0.5 [18]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -0.5 [19]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -0.5 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = -0.5 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF9-TNT-OPS" USING WS-IN WS-OUT
     MOVE "13.2 TNT pose for f = 0 [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0 [4]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0 [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0 [7]" TO WS-NAME
     MOVE 1.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0 [8]" TO WS-NAME
     MOVE 1.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0 [9]" TO WS-NAME
     MOVE 1.3 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0 [11]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0 [15]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0 [16]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0 [18]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0 [19]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     CALL "EF9-TNT-OPS" USING WS-IN WS-OUT
     MOVE "13.2 TNT pose for f = 0.5 [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0.5 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0.5 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0.5 [4]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0.5 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0.5 [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0.5 [7]" TO WS-NAME
     MOVE 1.244351875 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0.5 [8]" TO WS-NAME
     MOVE 1.244351875 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0.5 [9]" TO WS-NAME
     MOVE 1.244351875 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0.5 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0.5 [11]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0.5 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0.5 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0.5 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0.5 [15]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0.5 [16]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0.5 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0.5 [18]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0.5 [19]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0.5 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 0.5 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4.9 TO WS-IV(1)
     CALL "EF9-TNT-OPS" USING WS-IN WS-OUT
     MOVE "13.2 TNT pose for f = 4.9 [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 4.9 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 4.9 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 4.9 [4]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 4.9 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 4.9 [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 4.9 [7]" TO WS-NAME
     MOVE 1.020295603 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 4.9 [8]" TO WS-NAME
     MOVE 1.020295603 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 4.9 [9]" TO WS-NAME
     MOVE 1.020295603 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 4.9 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 4.9 [11]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 4.9 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 4.9 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 4.9 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 4.9 [15]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 4.9 [16]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 4.9 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 4.9 [18]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 4.9 [19]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 4.9 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 4.9 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     CALL "EF9-TNT-OPS" USING WS-IN WS-OUT
     MOVE "13.2 TNT pose for f = 5 [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 5 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 5 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 5 [4]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 5 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 5 [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 5 [7]" TO WS-NAME
     MOVE 1.01875 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 5 [8]" TO WS-NAME
     MOVE 1.01875 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 5 [9]" TO WS-NAME
     MOVE 1.01875 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 5 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 5 [11]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 5 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 5 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 5 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 5 [15]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 5 [16]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 5 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 5 [18]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 5 [19]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 5 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 5 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 9 TO WS-IV(1)
     CALL "EF9-TNT-OPS" USING WS-IN WS-OUT
     MOVE "13.2 TNT pose for f = 9 [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9 [4]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9 [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9 [7]" TO WS-NAME
     MOVE 1.00003 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9 [8]" TO WS-NAME
     MOVE 1.00003 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9 [9]" TO WS-NAME
     MOVE 1.00003 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9 [11]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9 [15]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9 [16]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9 [18]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9 [19]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 9.99 TO WS-IV(1)
     CALL "EF9-TNT-OPS" USING WS-IN WS-OUT
     MOVE "13.2 TNT pose for f = 9.99 [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9.99 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9.99 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9.99 [4]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9.99 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9.99 [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9.99 [7]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9.99 [8]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9.99 [9]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9.99 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9.99 [11]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9.99 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9.99 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9.99 [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9.99 [15]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9.99 [16]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9.99 [17]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9.99 [18]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9.99 [19]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9.99 [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 9.99 [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10 TO WS-IV(1)
     CALL "EF9-TNT-OPS" USING WS-IN WS-OUT
     MOVE "13.2 TNT pose for f = 10 [1]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 10 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 10 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 10 [4]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 10 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 10 [6]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 10 [7]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 10 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 10 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 10 [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 10 [11]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 10 [12]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 10 [13]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 10 [14]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 10 [15]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 10 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 10 [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE 12 TO WS-IV(1)
     CALL "EF9-TNT-OPS" USING WS-IN WS-OUT
     MOVE "13.2 TNT pose for f = 12 [1]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 12 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 12 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 12 [4]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 12 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 12 [6]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 12 [7]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 12 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 12 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 12 [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 12 [11]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 12 [12]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 12 [13]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 12 [14]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 12 [15]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 12 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 12 [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE 80 TO WS-IV(1)
     CALL "EF9-TNT-OPS" USING WS-IN WS-OUT
     MOVE "13.2 TNT pose for f = 80 [1]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 80 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 80 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 80 [4]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 80 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 80 [6]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 80 [7]" TO WS-NAME
     MOVE -90 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 80 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 80 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 80 [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 80 [11]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 80 [12]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 80 [13]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 80 [14]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 80 [15]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 80 [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 TNT pose for f = 80 [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     CALL "EF9-TNT-FLASH" USING WS-IN WS-OUT
     MOVE "13.2 overlay for f = 5 (u, alpha) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 overlay for f = 5 (u, alpha) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4.9 TO WS-IV(1)
     CALL "EF9-TNT-FLASH" USING WS-IN WS-OUT
     MOVE "13.2 overlay for f = 4.9 (u, alpha) [1]" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 overlay for f = 4.9 (u, alpha) [2]" TO WS-NAME
     MOVE 63 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF9-TNT-FLASH" USING WS-IN WS-OUT
     MOVE "13.2 overlay for f = 0 (u, alpha) [1]" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 overlay for f = 0 (u, alpha) [2]" TO WS-NAME
     MOVE 63 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE -1 TO WS-IV(1)
     CALL "EF9-TNT-FLASH" USING WS-IN WS-OUT
     MOVE "13.2 overlay for f = -1 (u, alpha) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 overlay for f = -1 (u, alpha) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10 TO WS-IV(1)
     CALL "EF9-TNT-FLASH" USING WS-IN WS-OUT
     MOVE "13.2 overlay for f = 10 (u, alpha) [1]" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 overlay for f = 10 (u, alpha) [2]" TO WS-NAME
     MOVE 63 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 14.99 TO WS-IV(1)
     CALL "EF9-TNT-FLASH" USING WS-IN WS-OUT
     MOVE "13.2 overlay for f = 14.99 (u, alpha) [1]" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 overlay for f = 14.99 (u, alpha) [2]" TO WS-NAME
     MOVE 63 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 15 TO WS-IV(1)
     CALL "EF9-TNT-FLASH" USING WS-IN WS-OUT
     MOVE "13.2 overlay for f = 15 (u, alpha) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.2 overlay for f = 15 (u, alpha) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-FALLING-OPS" USING WS-IN WS-OUT
     MOVE "13.1 submit translate (-0.5, 0, -0.5) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.1 submit translate (-0.5, 0, -0.5) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.1 submit translate (-0.5, 0, -0.5) [3]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.1 submit translate (-0.5, 0, -0.5) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.1 submit translate (-0.5, 0, -0.5) [5]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 5 TO WS-IV(2)
     CALL "EF9-FALLING-SHOWN" USING WS-IN WS-OUT
     MOVE "13.1 shouldRender: entity state 5, level state 5" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF9-FALLING-SHOWN" USING WS-IN WS-OUT
     MOVE "13.1 shouldRender: entity state 5, level state 0" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 5 TO WS-IV(2)
     CALL "EF9-FALLING-SHOWN" USING WS-IN WS-OUT
     MOVE "13.1 shouldRender: entity state 0, level state 5" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 123 TO WS-IV(1)
     MOVE 124 TO WS-IV(2)
     CALL "EF9-FALLING-SHOWN" USING WS-IN WS-OUT
     MOVE "13.1 shouldRender: entity state 123, level state 124" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10.5 TO WS-IV(1)
     MOVE 64 TO WS-IV(2)
     MOVE 10.5 TO WS-IV(3)
     MOVE 0.98 TO WS-IV(4)
     CALL "EF9-FALLING-POS" USING WS-IN WS-OUT
     MOVE "13.1 block position at (10.5, 64, 10.5) [1]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.1 block position at (10.5, 64, 10.5) [2]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.1 block position at (10.5, 64, 10.5) [3]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE -0.3 TO WS-IV(1)
     MOVE 63.2 TO WS-IV(2)
     MOVE 5.99 TO WS-IV(3)
     MOVE 0.98 TO WS-IV(4)
     CALL "EF9-FALLING-POS" USING WS-IN WS-OUT
     MOVE "13.1 block position at (-0.3, 63.2, 5.99) [1]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.1 block position at (-0.3, 63.2, 5.99) [2]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.1 block position at (-0.3, 63.2, 5.99) [3]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1.5 TO WS-IV(1)
     MOVE 70.02 TO WS-IV(2)
     MOVE -7.2 TO WS-IV(3)
     MOVE 0.98 TO WS-IV(4)
     CALL "EF9-FALLING-POS" USING WS-IN WS-OUT
     MOVE "13.1 block position at (1.5, 70.02, -7.2) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.1 block position at (1.5, 70.02, -7.2) [2]" TO WS-NAME
     MOVE 71 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.1 block position at (1.5, 70.02, -7.2) [3]" TO WS-NAME
     MOVE -8 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE -10.5 TO WS-IV(1)
     MOVE -64 TO WS-IV(2)
     MOVE 0.5 TO WS-IV(3)
     MOVE 0.98 TO WS-IV(4)
     CALL "EF9-FALLING-POS" USING WS-IN WS-OUT
     MOVE "13.1 block position at (-10.5, -64, 0.5) [1]" TO WS-NAME
     MOVE -11 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.1 block position at (-10.5, -64, 0.5) [2]" TO WS-NAME
     MOVE -64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13.1 block position at (-10.5, -64, 0.5) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-9§13: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-9§13: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-9-13.
