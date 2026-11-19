*> Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 15 (lightning bolt): the path table (seed 0 reproduces the worked example and Validation 10), every layer step of the four passes (the trunk and the two branches with their
*> draws and widths, 14 steps a pass) and the vertices of the four quads of a layer for the document's flag sets, for several seeds; the generator is the Java LCG of 10 section 2.6 written in gen/jr9.py (its first values are checked against Validation 10).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-9-15.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLEMM.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-PFX                 PIC X(100).
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
     MOVE "acceptance US15 34-9§15 lightning bolt" TO WS-PFX
     MOVE 0 TO WS-IV(1)
     CALL "EF9-LIGHTNING-PATH" USING WS-IN WS-OUT
     MOVE "15 path table of seed 0 (xs, zs, endX, endZ) [1]" TO WS-NAME
     MOVE -13 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 0 (xs, zs, endX, endZ) [2]" TO WS-NAME
     MOVE -10 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 0 (xs, zs, endX, endZ) [3]" TO WS-NAME
     MOVE -7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 0 (xs, zs, endX, endZ) [4]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 0 (xs, zs, endX, endZ) [5]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 0 (xs, zs, endX, endZ) [6]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 0 (xs, zs, endX, endZ) [7]" TO WS-NAME
     MOVE -5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 0 (xs, zs, endX, endZ) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 0 (xs, zs, endX, endZ) [9]" TO WS-NAME
     MOVE -9 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 0 (xs, zs, endX, endZ) [10]" TO WS-NAME
     MOVE -9 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 0 (xs, zs, endX, endZ) [11]" TO WS-NAME
     MOVE -6 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 0 (xs, zs, endX, endZ) [12]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 0 (xs, zs, endX, endZ) [13]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 0 (xs, zs, endX, endZ) [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 0 (xs, zs, endX, endZ) [15]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 0 (xs, zs, endX, endZ) [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 0 (xs, zs, endX, endZ) [17]" TO WS-NAME
     MOVE -16 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 0 (xs, zs, endX, endZ) [18]" TO WS-NAME
     MOVE -13 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF9-LIGHTNING-PATH" USING WS-IN WS-OUT
     MOVE "15 path table of seed 1 (xs, zs, endX, endZ) [1]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1 (xs, zs, endX, endZ) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1 (xs, zs, endX, endZ) [3]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1 (xs, zs, endX, endZ) [4]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1 (xs, zs, endX, endZ) [5]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1 (xs, zs, endX, endZ) [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1 (xs, zs, endX, endZ) [7]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1 (xs, zs, endX, endZ) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1 (xs, zs, endX, endZ) [9]" TO WS-NAME
     MOVE -10 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1 (xs, zs, endX, endZ) [10]" TO WS-NAME
     MOVE -7 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1 (xs, zs, endX, endZ) [11]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1 (xs, zs, endX, endZ) [12]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1 (xs, zs, endX, endZ) [13]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1 (xs, zs, endX, endZ) [14]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1 (xs, zs, endX, endZ) [15]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1 (xs, zs, endX, endZ) [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1 (xs, zs, endX, endZ) [17]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1 (xs, zs, endX, endZ) [18]" TO WS-NAME
     MOVE -14 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE 42 TO WS-IV(1)
     CALL "EF9-LIGHTNING-PATH" USING WS-IN WS-OUT
     MOVE "15 path table of seed 42 (xs, zs, endX, endZ) [1]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 42 (xs, zs, endX, endZ) [2]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 42 (xs, zs, endX, endZ) [3]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 42 (xs, zs, endX, endZ) [4]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 42 (xs, zs, endX, endZ) [5]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 42 (xs, zs, endX, endZ) [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 42 (xs, zs, endX, endZ) [7]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 42 (xs, zs, endX, endZ) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 42 (xs, zs, endX, endZ) [9]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 42 (xs, zs, endX, endZ) [10]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 42 (xs, zs, endX, endZ) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 42 (xs, zs, endX, endZ) [12]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 42 (xs, zs, endX, endZ) [13]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 42 (xs, zs, endX, endZ) [14]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 42 (xs, zs, endX, endZ) [15]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 42 (xs, zs, endX, endZ) [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 42 (xs, zs, endX, endZ) [17]" TO WS-NAME
     MOVE -7 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 42 (xs, zs, endX, endZ) [18]" TO WS-NAME
     MOVE -8 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE 123456789 TO WS-IV(1)
     CALL "EF9-LIGHTNING-PATH" USING WS-IN WS-OUT
     MOVE "15 path table of seed 123456789 (xs, zs, endX, endZ) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 123456789 (xs, zs, endX, endZ) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 123456789 (xs, zs, endX, endZ) [3]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 123456789 (xs, zs, endX, endZ) [4]" TO WS-NAME
     MOVE -5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 123456789 (xs, zs, endX, endZ) [5]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 123456789 (xs, zs, endX, endZ) [6]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 123456789 (xs, zs, endX, endZ) [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 123456789 (xs, zs, endX, endZ) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 123456789 (xs, zs, endX, endZ) [9]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 123456789 (xs, zs, endX, endZ) [10]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 123456789 (xs, zs, endX, endZ) [11]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 123456789 (xs, zs, endX, endZ) [12]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 123456789 (xs, zs, endX, endZ) [13]" TO WS-NAME
     MOVE -5 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 123456789 (xs, zs, endX, endZ) [14]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 123456789 (xs, zs, endX, endZ) [15]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 123456789 (xs, zs, endX, endZ) [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 123456789 (xs, zs, endX, endZ) [17]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 123456789 (xs, zs, endX, endZ) [18]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE 9876543210 TO WS-IV(1)
     CALL "EF9-LIGHTNING-PATH" USING WS-IN WS-OUT
     MOVE "15 path table of seed 9876543210 (xs, zs, endX, endZ) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 9876543210 (xs, zs, endX, endZ) [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 9876543210 (xs, zs, endX, endZ) [3]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 9876543210 (xs, zs, endX, endZ) [4]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 9876543210 (xs, zs, endX, endZ) [5]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 9876543210 (xs, zs, endX, endZ) [6]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 9876543210 (xs, zs, endX, endZ) [7]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 9876543210 (xs, zs, endX, endZ) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 9876543210 (xs, zs, endX, endZ) [9]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 9876543210 (xs, zs, endX, endZ) [10]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 9876543210 (xs, zs, endX, endZ) [11]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 9876543210 (xs, zs, endX, endZ) [12]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 9876543210 (xs, zs, endX, endZ) [13]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 9876543210 (xs, zs, endX, endZ) [14]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 9876543210 (xs, zs, endX, endZ) [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 9876543210 (xs, zs, endX, endZ) [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 9876543210 (xs, zs, endX, endZ) [17]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 9876543210 (xs, zs, endX, endZ) [18]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE -5 TO WS-IV(1)
     CALL "EF9-LIGHTNING-PATH" USING WS-IN WS-OUT
     MOVE "15 path table of seed -5 (xs, zs, endX, endZ) [1]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed -5 (xs, zs, endX, endZ) [2]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed -5 (xs, zs, endX, endZ) [3]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed -5 (xs, zs, endX, endZ) [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed -5 (xs, zs, endX, endZ) [5]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed -5 (xs, zs, endX, endZ) [6]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed -5 (xs, zs, endX, endZ) [7]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed -5 (xs, zs, endX, endZ) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed -5 (xs, zs, endX, endZ) [9]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed -5 (xs, zs, endX, endZ) [10]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed -5 (xs, zs, endX, endZ) [11]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed -5 (xs, zs, endX, endZ) [12]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed -5 (xs, zs, endX, endZ) [13]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed -5 (xs, zs, endX, endZ) [14]" TO WS-NAME
     MOVE -6 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed -5 (xs, zs, endX, endZ) [15]" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed -5 (xs, zs, endX, endZ) [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed -5 (xs, zs, endX, endZ) [17]" TO WS-NAME
     MOVE -6 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed -5 (xs, zs, endX, endZ) [18]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1099511627793 TO WS-IV(1)
     CALL "EF9-LIGHTNING-PATH" USING WS-IN WS-OUT
     MOVE "15 path table of seed 1099511627793 (xs, zs, endX, endZ) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1099511627793 (xs, zs, endX, endZ) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1099511627793 (xs, zs, endX, endZ) [3]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1099511627793 (xs, zs, endX, endZ) [4]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1099511627793 (xs, zs, endX, endZ) [5]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1099511627793 (xs, zs, endX, endZ) [6]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1099511627793 (xs, zs, endX, endZ) [7]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1099511627793 (xs, zs, endX, endZ) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1099511627793 (xs, zs, endX, endZ) [9]" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1099511627793 (xs, zs, endX, endZ) [10]" TO WS-NAME
     MOVE 13 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1099511627793 (xs, zs, endX, endZ) [11]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1099511627793 (xs, zs, endX, endZ) [12]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1099511627793 (xs, zs, endX, endZ) [13]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1099511627793 (xs, zs, endX, endZ) [14]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1099511627793 (xs, zs, endX, endZ) [15]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1099511627793 (xs, zs, endX, endZ) [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1099511627793 (xs, zs, endX, endZ) [17]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 path table of seed 1099511627793 (xs, zs, endX, endZ) [18]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 0 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 13 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.17 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.16 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 0 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.16 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.15 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 0 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.15 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.14 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 0 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.14 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.13 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 4 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 0 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.13 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.12 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 0 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.12 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.11 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 6 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 0 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.11 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 0 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.09 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 8 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 0 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 21 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 9 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 0 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 21 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 28 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 10 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 0 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 28 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 11 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 0 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 12 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 0 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 21 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 13 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 0 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 21 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 17 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 28 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 0 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 1 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 13 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.51 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.48 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 1 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.48 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.45 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 1 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.45 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.42 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 1 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.42 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.39 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 4 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 1 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.39 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.36 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 1 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.36 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.33 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 6 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 1 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.33 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 1 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.27 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 8 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 1 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 21 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 9 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 1 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 21 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 28 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 10 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 1 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 28 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 11 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 1 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 12 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 1 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 21 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 13 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 1 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 21 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 17 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 28 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 1 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 2 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 13 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.85 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 2 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 2 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 2 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.65 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 4 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 2 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.65 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 2 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.55 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 6 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 2 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.55 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 2 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.45 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 8 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 2 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 21 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 9 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 2 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 21 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 28 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 10 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 2 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 28 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 11 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 2 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 12 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 2 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 21 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 13 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 2 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 21 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 17 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 28 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 2 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 3 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 13 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 1.19 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 1.12 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 3 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 1.12 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 1.05 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 3 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 1.05 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.98 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 3 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.98 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.91 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 4 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 3 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.91 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.84 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 3 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.84 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.77 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 6 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 3 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.77 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 3 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.63 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 8 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 3 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 21 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 9 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 3 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 21 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 28 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 10 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 3 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 28 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 11 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 3 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 12 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 3 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 21 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 13 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 0 pass 3 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 21 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 17 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 28 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 0 pass 3 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 0 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -11 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -8 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.17 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.16 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 0 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -8 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -6 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -9 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.16 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.15 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 0 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -9 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -10 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.15 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.14 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 0 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -10 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -8 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.14 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.13 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 4 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 0 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -8 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.13 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.12 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 0 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.12 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.11 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 6 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 0 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.11 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 0 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.09 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 8 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 0 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -8 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -6 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -16 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 9 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 0 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -16 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -28 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 10 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 0 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -28 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -38 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 11 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 0 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -9 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -14 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 12 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 0 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -14 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -9 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 13 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 0 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -9 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 0 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 1 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -11 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -8 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.51 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.48 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 1 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -8 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -6 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -9 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.48 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.45 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 1 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -9 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -10 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.45 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.42 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 1 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -10 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -8 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.42 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.39 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 4 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 1 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -8 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.39 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.36 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 1 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.36 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.33 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 6 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 1 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.33 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 1 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.27 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 8 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 1 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -8 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -6 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -16 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 9 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 1 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -16 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -28 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 10 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 1 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -28 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -38 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 11 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 1 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -9 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -14 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 12 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 1 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -14 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -9 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 13 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 1 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -9 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 1 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 2 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -11 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -8 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.85 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 2 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -8 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -6 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -9 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 2 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -9 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -10 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 2 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -10 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -8 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.65 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 4 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 2 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -8 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.65 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 2 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.55 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 6 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 2 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.55 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 2 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.45 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 8 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 2 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -8 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -6 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -16 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 9 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 2 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -16 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -28 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 10 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 2 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -28 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -38 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 11 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 2 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -9 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -14 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 12 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 2 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -14 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -9 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 13 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 2 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -9 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 2 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 3 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -11 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -8 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 1.19 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 1.12 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 3 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -8 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -6 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -9 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 1.12 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 1.05 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 3 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -9 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -10 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 1.05 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.98 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 3 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -10 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -8 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.98 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.91 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 4 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 3 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -8 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.91 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.84 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 3 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.84 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.77 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 6 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 3 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.77 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 3 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.63 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 8 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 3 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -8 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -6 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -16 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 9 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 3 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -16 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -28 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 10 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 3 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -28 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -38 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 11 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 3 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -9 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -14 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 12 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 3 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -14 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -9 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 13 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 7 pass 3 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -9 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 7 pass 3 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 0 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 13 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.17 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.16 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 0 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.16 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.15 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 0 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.15 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.14 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 0 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.14 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.13 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 4 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 0 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.13 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.12 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 0 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.12 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.11 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 6 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 0 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.11 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 0 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.09 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 8 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 0 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 9 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 0 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 17 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 17 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 10 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 0 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 17 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 17 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 30 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 22 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 11 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 0 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -13 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 12 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 0 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -13 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -19 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 13 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 0 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -19 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -14 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 0 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 1 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 13 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.51 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.48 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 1 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.48 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.45 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 1 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.45 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.42 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 1 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.42 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.39 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 4 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 1 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.39 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.36 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 1 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.36 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.33 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 6 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 1 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.33 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 1 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.27 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 8 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 1 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 9 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 1 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 17 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 17 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 10 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 1 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 17 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 17 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 30 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 22 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 11 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 1 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -13 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 12 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 1 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -13 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -19 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 13 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 1 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -19 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -14 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 1 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 2 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 13 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.85 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 2 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 2 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 2 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.65 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 4 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 2 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.65 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 2 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.6 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.55 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 6 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 2 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.55 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 2 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.45 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 8 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 2 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 9 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 2 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 17 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 17 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 10 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 2 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 17 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 17 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 30 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 22 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 11 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 2 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -13 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 12 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 2 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -13 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -19 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     MOVE 13 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 2 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -19 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -14 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 2 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 3 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 13 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 1.19 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 0 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 1.12 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 3 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 1.12 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 1 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 1.05 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 3 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 1.05 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 2 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.98 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 3 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.98 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 3 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.91 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 4 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 3 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.91 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 4 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.84 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 3 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.84 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 5 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.77 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 6 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 3 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE -3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.77 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 6 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 3 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 7 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.63 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 8 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 3 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 8 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 9 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 3 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 17 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 17 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 9 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 10 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 3 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 17 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 17 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE 30 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 22 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 10 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 11 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 3 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -13 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 11 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 12 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 3 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -13 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -19 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 12 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 31337 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 13 TO WS-IV(3)
     CALL "EF9-LIGHTNING-STEP" USING WS-IN WS-OUT
     MOVE "15 seed 31337 pass 3 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [3]" TO WS-NAME
     MOVE -19 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [4]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [5]" TO WS-NAME
     MOVE -14 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [6]" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [7]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 seed 31337 pass 3 step 13 (k, layer, prevX, prevZ, px, pz, wTop, wBot) [8]" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE 16 TO WS-IV(1)
     MOVE 13 TO WS-IV(2)
     MOVE 16 TO WS-IV(3)
     MOVE 13 TO WS-IV(4)
     MOVE 7 TO WS-IV(5)
     MOVE 0.17 TO WS-IV(6)
     MOVE 0.1 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     CALL "EF9-LIGHTNING-QUAD" USING WS-IN WS-OUT
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (0, 0, 1, 0) [1]" TO WS-NAME
     MOVE 15.9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (0, 0, 1, 0) [2]" TO WS-NAME
     MOVE 112 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (0, 0, 1, 0) [3]" TO WS-NAME
     MOVE 12.9 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (0, 0, 1, 0) [4]" TO WS-NAME
     MOVE 15.83 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (0, 0, 1, 0) [5]" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (0, 0, 1, 0) [6]" TO WS-NAME
     MOVE 12.83 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (0, 0, 1, 0) [7]" TO WS-NAME
     MOVE 16.17 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (0, 0, 1, 0) [8]" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (0, 0, 1, 0) [9]" TO WS-NAME
     MOVE 12.83 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (0, 0, 1, 0) [10]" TO WS-NAME
     MOVE 16.1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (0, 0, 1, 0) [11]" TO WS-NAME
     MOVE 112 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (0, 0, 1, 0) [12]" TO WS-NAME
     MOVE 12.9 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 16 TO WS-IV(1)
     MOVE 13 TO WS-IV(2)
     MOVE 16 TO WS-IV(3)
     MOVE 13 TO WS-IV(4)
     MOVE 7 TO WS-IV(5)
     MOVE 0.17 TO WS-IV(6)
     MOVE 0.1 TO WS-IV(7)
     MOVE 1 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     CALL "EF9-LIGHTNING-QUAD" USING WS-IN WS-OUT
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (1, 0, 1, 1) [1]" TO WS-NAME
     MOVE 16.1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (1, 0, 1, 1) [2]" TO WS-NAME
     MOVE 112 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (1, 0, 1, 1) [3]" TO WS-NAME
     MOVE 12.9 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (1, 0, 1, 1) [4]" TO WS-NAME
     MOVE 16.17 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (1, 0, 1, 1) [5]" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (1, 0, 1, 1) [6]" TO WS-NAME
     MOVE 12.83 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (1, 0, 1, 1) [7]" TO WS-NAME
     MOVE 16.17 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (1, 0, 1, 1) [8]" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (1, 0, 1, 1) [9]" TO WS-NAME
     MOVE 13.17 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (1, 0, 1, 1) [10]" TO WS-NAME
     MOVE 16.1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (1, 0, 1, 1) [11]" TO WS-NAME
     MOVE 112 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (1, 0, 1, 1) [12]" TO WS-NAME
     MOVE 13.1 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 16 TO WS-IV(1)
     MOVE 13 TO WS-IV(2)
     MOVE 16 TO WS-IV(3)
     MOVE 13 TO WS-IV(4)
     MOVE 7 TO WS-IV(5)
     MOVE 0.17 TO WS-IV(6)
     MOVE 0.1 TO WS-IV(7)
     MOVE 1 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     CALL "EF9-LIGHTNING-QUAD" USING WS-IN WS-OUT
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (1, 1, 0, 1) [1]" TO WS-NAME
     MOVE 16.1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (1, 1, 0, 1) [2]" TO WS-NAME
     MOVE 112 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (1, 1, 0, 1) [3]" TO WS-NAME
     MOVE 13.1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (1, 1, 0, 1) [4]" TO WS-NAME
     MOVE 16.17 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (1, 1, 0, 1) [5]" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (1, 1, 0, 1) [6]" TO WS-NAME
     MOVE 13.17 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (1, 1, 0, 1) [7]" TO WS-NAME
     MOVE 15.83 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (1, 1, 0, 1) [8]" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (1, 1, 0, 1) [9]" TO WS-NAME
     MOVE 13.17 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (1, 1, 0, 1) [10]" TO WS-NAME
     MOVE 15.9 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (1, 1, 0, 1) [11]" TO WS-NAME
     MOVE 112 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (1, 1, 0, 1) [12]" TO WS-NAME
     MOVE 13.1 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 16 TO WS-IV(1)
     MOVE 13 TO WS-IV(2)
     MOVE 16 TO WS-IV(3)
     MOVE 13 TO WS-IV(4)
     MOVE 7 TO WS-IV(5)
     MOVE 0.17 TO WS-IV(6)
     MOVE 0.1 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     CALL "EF9-LIGHTNING-QUAD" USING WS-IN WS-OUT
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (0, 1, 0, 0) [1]" TO WS-NAME
     MOVE 15.9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (0, 1, 0, 0) [2]" TO WS-NAME
     MOVE 112 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (0, 1, 0, 0) [3]" TO WS-NAME
     MOVE 13.1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (0, 1, 0, 0) [4]" TO WS-NAME
     MOVE 15.83 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (0, 1, 0, 0) [5]" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (0, 1, 0, 0) [6]" TO WS-NAME
     MOVE 13.17 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (0, 1, 0, 0) [7]" TO WS-NAME
     MOVE 15.83 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (0, 1, 0, 0) [8]" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (0, 1, 0, 0) [9]" TO WS-NAME
     MOVE 12.83 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (0, 1, 0, 0) [10]" TO WS-NAME
     MOVE 15.9 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (0, 1, 0, 0) [11]" TO WS-NAME
     MOVE 112 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 7 new (16, 13) previous (16, 13) flags (0, 1, 0, 0) [12]" TO WS-NAME
     MOVE 12.9 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE -4 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     MOVE 2 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0.1 TO WS-IV(6)
     MOVE 0.1 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     CALL "EF9-LIGHTNING-QUAD" USING WS-IN WS-OUT
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (0, 0, 1, 0) [1]" TO WS-NAME
     MOVE 2.9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (0, 0, 1, 0) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (0, 0, 1, 0) [3]" TO WS-NAME
     MOVE -4.1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (0, 0, 1, 0) [4]" TO WS-NAME
     MOVE 4.9 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (0, 0, 1, 0) [5]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (0, 0, 1, 0) [6]" TO WS-NAME
     MOVE 1.9 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (0, 0, 1, 0) [7]" TO WS-NAME
     MOVE 5.1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (0, 0, 1, 0) [8]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (0, 0, 1, 0) [9]" TO WS-NAME
     MOVE 1.9 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (0, 0, 1, 0) [10]" TO WS-NAME
     MOVE 3.1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (0, 0, 1, 0) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (0, 0, 1, 0) [12]" TO WS-NAME
     MOVE -4.1 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE -4 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     MOVE 2 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0.1 TO WS-IV(6)
     MOVE 0.1 TO WS-IV(7)
     MOVE 1 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     CALL "EF9-LIGHTNING-QUAD" USING WS-IN WS-OUT
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (1, 0, 1, 1) [1]" TO WS-NAME
     MOVE 3.1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (1, 0, 1, 1) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (1, 0, 1, 1) [3]" TO WS-NAME
     MOVE -4.1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (1, 0, 1, 1) [4]" TO WS-NAME
     MOVE 5.1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (1, 0, 1, 1) [5]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (1, 0, 1, 1) [6]" TO WS-NAME
     MOVE 1.9 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (1, 0, 1, 1) [7]" TO WS-NAME
     MOVE 5.1 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (1, 0, 1, 1) [8]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (1, 0, 1, 1) [9]" TO WS-NAME
     MOVE 2.1 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (1, 0, 1, 1) [10]" TO WS-NAME
     MOVE 3.1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (1, 0, 1, 1) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (1, 0, 1, 1) [12]" TO WS-NAME
     MOVE -3.9 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE -4 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     MOVE 2 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0.1 TO WS-IV(6)
     MOVE 0.1 TO WS-IV(7)
     MOVE 1 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     CALL "EF9-LIGHTNING-QUAD" USING WS-IN WS-OUT
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (1, 1, 0, 1) [1]" TO WS-NAME
     MOVE 3.1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (1, 1, 0, 1) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (1, 1, 0, 1) [3]" TO WS-NAME
     MOVE -3.9 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (1, 1, 0, 1) [4]" TO WS-NAME
     MOVE 5.1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (1, 1, 0, 1) [5]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (1, 1, 0, 1) [6]" TO WS-NAME
     MOVE 2.1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (1, 1, 0, 1) [7]" TO WS-NAME
     MOVE 4.9 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (1, 1, 0, 1) [8]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (1, 1, 0, 1) [9]" TO WS-NAME
     MOVE 2.1 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (1, 1, 0, 1) [10]" TO WS-NAME
     MOVE 2.9 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (1, 1, 0, 1) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (1, 1, 0, 1) [12]" TO WS-NAME
     MOVE -3.9 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE -4 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     MOVE 2 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0.1 TO WS-IV(6)
     MOVE 0.1 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     CALL "EF9-LIGHTNING-QUAD" USING WS-IN WS-OUT
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (0, 1, 0, 0) [1]" TO WS-NAME
     MOVE 2.9 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (0, 1, 0, 0) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (0, 1, 0, 0) [3]" TO WS-NAME
     MOVE -3.9 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (0, 1, 0, 0) [4]" TO WS-NAME
     MOVE 4.9 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (0, 1, 0, 0) [5]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (0, 1, 0, 0) [6]" TO WS-NAME
     MOVE 2.1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (0, 1, 0, 0) [7]" TO WS-NAME
     MOVE 4.9 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (0, 1, 0, 0) [8]" TO WS-NAME
     MOVE 16 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (0, 1, 0, 0) [9]" TO WS-NAME
     MOVE 1.9 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (0, 1, 0, 0) [10]" TO WS-NAME
     MOVE 2.9 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (0, 1, 0, 0) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 0 new (3, -4) previous (5, 2) flags (0, 1, 0, 0) [12]" TO WS-NAME
     MOVE -4.1 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE -8 TO WS-IV(1)
     MOVE 9 TO WS-IV(2)
     MOVE -6 TO WS-IV(3)
     MOVE 11 TO WS-IV(4)
     MOVE 4 TO WS-IV(5)
     MOVE 0.7 TO WS-IV(6)
     MOVE 0.7 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     CALL "EF9-LIGHTNING-QUAD" USING WS-IN WS-OUT
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (0, 0, 1, 0) [1]" TO WS-NAME
     MOVE -8.7 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (0, 0, 1, 0) [2]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (0, 0, 1, 0) [3]" TO WS-NAME
     MOVE 8.3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (0, 0, 1, 0) [4]" TO WS-NAME
     MOVE -6.7 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (0, 0, 1, 0) [5]" TO WS-NAME
     MOVE 80 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (0, 0, 1, 0) [6]" TO WS-NAME
     MOVE 10.3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (0, 0, 1, 0) [7]" TO WS-NAME
     MOVE -5.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (0, 0, 1, 0) [8]" TO WS-NAME
     MOVE 80 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (0, 0, 1, 0) [9]" TO WS-NAME
     MOVE 10.3 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (0, 0, 1, 0) [10]" TO WS-NAME
     MOVE -7.3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (0, 0, 1, 0) [11]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (0, 0, 1, 0) [12]" TO WS-NAME
     MOVE 8.3 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE -8 TO WS-IV(1)
     MOVE 9 TO WS-IV(2)
     MOVE -6 TO WS-IV(3)
     MOVE 11 TO WS-IV(4)
     MOVE 4 TO WS-IV(5)
     MOVE 0.7 TO WS-IV(6)
     MOVE 0.7 TO WS-IV(7)
     MOVE 1 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     CALL "EF9-LIGHTNING-QUAD" USING WS-IN WS-OUT
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (1, 0, 1, 1) [1]" TO WS-NAME
     MOVE -7.3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (1, 0, 1, 1) [2]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (1, 0, 1, 1) [3]" TO WS-NAME
     MOVE 8.3 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (1, 0, 1, 1) [4]" TO WS-NAME
     MOVE -5.3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (1, 0, 1, 1) [5]" TO WS-NAME
     MOVE 80 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (1, 0, 1, 1) [6]" TO WS-NAME
     MOVE 10.3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (1, 0, 1, 1) [7]" TO WS-NAME
     MOVE -5.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (1, 0, 1, 1) [8]" TO WS-NAME
     MOVE 80 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (1, 0, 1, 1) [9]" TO WS-NAME
     MOVE 11.7 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (1, 0, 1, 1) [10]" TO WS-NAME
     MOVE -7.3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (1, 0, 1, 1) [11]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (1, 0, 1, 1) [12]" TO WS-NAME
     MOVE 9.7 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE -8 TO WS-IV(1)
     MOVE 9 TO WS-IV(2)
     MOVE -6 TO WS-IV(3)
     MOVE 11 TO WS-IV(4)
     MOVE 4 TO WS-IV(5)
     MOVE 0.7 TO WS-IV(6)
     MOVE 0.7 TO WS-IV(7)
     MOVE 1 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     CALL "EF9-LIGHTNING-QUAD" USING WS-IN WS-OUT
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (1, 1, 0, 1) [1]" TO WS-NAME
     MOVE -7.3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (1, 1, 0, 1) [2]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (1, 1, 0, 1) [3]" TO WS-NAME
     MOVE 9.7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (1, 1, 0, 1) [4]" TO WS-NAME
     MOVE -5.3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (1, 1, 0, 1) [5]" TO WS-NAME
     MOVE 80 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (1, 1, 0, 1) [6]" TO WS-NAME
     MOVE 11.7 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (1, 1, 0, 1) [7]" TO WS-NAME
     MOVE -6.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (1, 1, 0, 1) [8]" TO WS-NAME
     MOVE 80 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (1, 1, 0, 1) [9]" TO WS-NAME
     MOVE 11.7 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (1, 1, 0, 1) [10]" TO WS-NAME
     MOVE -8.7 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (1, 1, 0, 1) [11]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (1, 1, 0, 1) [12]" TO WS-NAME
     MOVE 9.7 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE -8 TO WS-IV(1)
     MOVE 9 TO WS-IV(2)
     MOVE -6 TO WS-IV(3)
     MOVE 11 TO WS-IV(4)
     MOVE 4 TO WS-IV(5)
     MOVE 0.7 TO WS-IV(6)
     MOVE 0.7 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     CALL "EF9-LIGHTNING-QUAD" USING WS-IN WS-OUT
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (0, 1, 0, 0) [1]" TO WS-NAME
     MOVE -8.7 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (0, 1, 0, 0) [2]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (0, 1, 0, 0) [3]" TO WS-NAME
     MOVE 9.7 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (0, 1, 0, 0) [4]" TO WS-NAME
     MOVE -6.7 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (0, 1, 0, 0) [5]" TO WS-NAME
     MOVE 80 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (0, 1, 0, 0) [6]" TO WS-NAME
     MOVE 11.7 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (0, 1, 0, 0) [7]" TO WS-NAME
     MOVE -6.7 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (0, 1, 0, 0) [8]" TO WS-NAME
     MOVE 80 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (0, 1, 0, 0) [9]" TO WS-NAME
     MOVE 10.3 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (0, 1, 0, 0) [10]" TO WS-NAME
     MOVE -8.7 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (0, 1, 0, 0) [11]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 4 new (-8, 9) previous (-6, 11) flags (0, 1, 0, 0) [12]" TO WS-NAME
     MOVE 8.3 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     MOVE 0.5 TO WS-IV(6)
     MOVE 0.45 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     CALL "EF9-LIGHTNING-QUAD" USING WS-IN WS-OUT
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (0, 0, 1, 0) [1]" TO WS-NAME
     MOVE -0.45 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (0, 0, 1, 0) [2]" TO WS-NAME
     MOVE 48 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (0, 0, 1, 0) [3]" TO WS-NAME
     MOVE -0.45 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (0, 0, 1, 0) [4]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (0, 0, 1, 0) [5]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (0, 0, 1, 0) [6]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (0, 0, 1, 0) [7]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (0, 0, 1, 0) [8]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (0, 0, 1, 0) [9]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (0, 0, 1, 0) [10]" TO WS-NAME
     MOVE 0.45 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (0, 0, 1, 0) [11]" TO WS-NAME
     MOVE 48 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (0, 0, 1, 0) [12]" TO WS-NAME
     MOVE -0.45 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     MOVE 0.5 TO WS-IV(6)
     MOVE 0.45 TO WS-IV(7)
     MOVE 1 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     CALL "EF9-LIGHTNING-QUAD" USING WS-IN WS-OUT
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (1, 0, 1, 1) [1]" TO WS-NAME
     MOVE 0.45 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (1, 0, 1, 1) [2]" TO WS-NAME
     MOVE 48 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (1, 0, 1, 1) [3]" TO WS-NAME
     MOVE -0.45 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (1, 0, 1, 1) [4]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (1, 0, 1, 1) [5]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (1, 0, 1, 1) [6]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (1, 0, 1, 1) [7]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (1, 0, 1, 1) [8]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (1, 0, 1, 1) [9]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (1, 0, 1, 1) [10]" TO WS-NAME
     MOVE 0.45 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (1, 0, 1, 1) [11]" TO WS-NAME
     MOVE 48 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (1, 0, 1, 1) [12]" TO WS-NAME
     MOVE 0.45 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     MOVE 0.5 TO WS-IV(6)
     MOVE 0.45 TO WS-IV(7)
     MOVE 1 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     CALL "EF9-LIGHTNING-QUAD" USING WS-IN WS-OUT
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (1, 1, 0, 1) [1]" TO WS-NAME
     MOVE 0.45 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (1, 1, 0, 1) [2]" TO WS-NAME
     MOVE 48 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (1, 1, 0, 1) [3]" TO WS-NAME
     MOVE 0.45 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (1, 1, 0, 1) [4]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (1, 1, 0, 1) [5]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (1, 1, 0, 1) [6]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (1, 1, 0, 1) [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (1, 1, 0, 1) [8]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (1, 1, 0, 1) [9]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (1, 1, 0, 1) [10]" TO WS-NAME
     MOVE -0.45 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (1, 1, 0, 1) [11]" TO WS-NAME
     MOVE 48 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (1, 1, 0, 1) [12]" TO WS-NAME
     MOVE 0.45 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     MOVE 0.5 TO WS-IV(6)
     MOVE 0.45 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     CALL "EF9-LIGHTNING-QUAD" USING WS-IN WS-OUT
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (0, 1, 0, 0) [1]" TO WS-NAME
     MOVE -0.45 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (0, 1, 0, 0) [2]" TO WS-NAME
     MOVE 48 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (0, 1, 0, 0) [3]" TO WS-NAME
     MOVE 0.45 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (0, 1, 0, 0) [4]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (0, 1, 0, 0) [5]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (0, 1, 0, 0) [6]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (0, 1, 0, 0) [7]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (0, 1, 0, 0) [8]" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (0, 1, 0, 0) [9]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (0, 1, 0, 0) [10]" TO WS-NAME
     MOVE -0.45 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (0, 1, 0, 0) [11]" TO WS-NAME
     MOVE 48 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 quad at layer 3 new (0, 0) previous (1, 1) flags (0, 1, 0, 0) [12]" TO WS-NAME
     MOVE -0.45 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-LIGHTNING-COLOR" USING WS-IN WS-OUT
     MOVE "15 vertex colour [1]" TO WS-NAME
     MOVE 0.45 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 vertex colour [2]" TO WS-NAME
     MOVE 0.45 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 vertex colour [3]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "15 vertex colour [4]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING FUNCTION TRIM(WS-PFX) ": " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING FUNCTION TRIM(WS-PFX) ": " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-9-15.
