*> Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 9 (dropped items, clusters, the ominous item spawner): renderedAmount from the table of 9.1 and Validation 4, seedFor (187 for an empty stack),
*> the bob, base and spin of 9.2 (steps 1 and 2), submitMultipleFromCount for thick and flat models (the draws of the Java LCG, generator vectors of Validation 10 checked in gen/jr9.py), and 9.3 (grow over 50 ticks, spin in degrees, fixed full bright light).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-9-9.
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
     MOVE "acceptance US15 34-9§9 dropped items and clusters" TO WS-PFX
     MOVE -1 TO WS-IV(1)
     CALL "EF9-ITEM-COPIES" USING WS-IN WS-OUT
     MOVE "9.1 renderedAmount of a stack of -1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF9-ITEM-COPIES" USING WS-IN WS-OUT
     MOVE "9.1 renderedAmount of a stack of 0" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF9-ITEM-COPIES" USING WS-IN WS-OUT
     MOVE "9.1 renderedAmount of a stack of 1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     CALL "EF9-ITEM-COPIES" USING WS-IN WS-OUT
     MOVE "9.1 renderedAmount of a stack of 2" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 16 TO WS-IV(1)
     CALL "EF9-ITEM-COPIES" USING WS-IN WS-OUT
     MOVE "9.1 renderedAmount of a stack of 16" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 17 TO WS-IV(1)
     CALL "EF9-ITEM-COPIES" USING WS-IN WS-OUT
     MOVE "9.1 renderedAmount of a stack of 17" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 32 TO WS-IV(1)
     CALL "EF9-ITEM-COPIES" USING WS-IN WS-OUT
     MOVE "9.1 renderedAmount of a stack of 32" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 33 TO WS-IV(1)
     CALL "EF9-ITEM-COPIES" USING WS-IN WS-OUT
     MOVE "9.1 renderedAmount of a stack of 33" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 40 TO WS-IV(1)
     CALL "EF9-ITEM-COPIES" USING WS-IN WS-OUT
     MOVE "9.1 renderedAmount of a stack of 40" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 48 TO WS-IV(1)
     CALL "EF9-ITEM-COPIES" USING WS-IN WS-OUT
     MOVE "9.1 renderedAmount of a stack of 48" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 49 TO WS-IV(1)
     CALL "EF9-ITEM-COPIES" USING WS-IN WS-OUT
     MOVE "9.1 renderedAmount of a stack of 49" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 64 TO WS-IV(1)
     CALL "EF9-ITEM-COPIES" USING WS-IN WS-OUT
     MOVE "9.1 renderedAmount of a stack of 64" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 99 TO WS-IV(1)
     CALL "EF9-ITEM-COPIES" USING WS-IN WS-OUT
     MOVE "9.1 renderedAmount of a stack of 99" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF9-ITEM-SEED" USING WS-IN WS-OUT
     MOVE "9.1 seedFor id 0 damage 0 empty 1" TO WS-NAME
     MOVE 187 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF9-ITEM-SEED" USING WS-IN WS-OUT
     MOVE "9.1 seedFor id 5 damage 3 empty 1" TO WS-NAME
     MOVE 187 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF9-ITEM-SEED" USING WS-IN WS-OUT
     MOVE "9.1 seedFor id 0 damage 0 empty 0" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 42 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF9-ITEM-SEED" USING WS-IN WS-OUT
     MOVE "9.1 seedFor id 42 damage 0 empty 0" TO WS-NAME
     MOVE 42 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1000 TO WS-IV(1)
     MOVE 12 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF9-ITEM-SEED" USING WS-IN WS-OUT
     MOVE "9.1 seedFor id 1000 damage 12 empty 0" TO WS-NAME
     MOVE 1012 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF9-ITEM-SEED" USING WS-IN WS-OUT
     MOVE "9.1 seedFor id 7 damage 1 empty 0" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE -0.125 TO WS-IV(3)
     CALL "EF9-ITEM-POSE" USING WS-IN WS-OUT
     MOVE "9.2 pose age 0 bobOffs 0 minY -0.125 (translate y, spin radians) [1]" TO WS-NAME
     MOVE 0.2875 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 pose age 0 bobOffs 0 minY -0.125 (translate y, spin radians) [2]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 20 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE -0.125 TO WS-IV(3)
     CALL "EF9-ITEM-POSE" USING WS-IN WS-OUT
     MOVE "9.2 pose age 20 bobOffs 0 minY -0.125 (translate y, spin radians) [1]" TO WS-NAME
     MOVE 0.378429743 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 pose age 20 bobOffs 0 minY -0.125 (translate y, spin radians) [2]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 33.5 TO WS-IV(1)
     MOVE 2.5 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF9-ITEM-POSE" USING WS-IN WS-OUT
     MOVE "9.2 pose age 33.5 bobOffs 2.5 minY 0 (translate y, spin radians) [1]" TO WS-NAME
     MOVE 0.120523598 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 pose age 33.5 bobOffs 2.5 minY 0 (translate y, spin radians) [2]" TO WS-NAME
     MOVE 4.175 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 100 TO WS-IV(1)
     MOVE 5.9 TO WS-IV(2)
     MOVE 0.3 TO WS-IV(3)
     CALL "EF9-ITEM-POSE" USING WS-IN WS-OUT
     MOVE "9.2 pose age 100 bobOffs 5.9 minY 0.3 (translate y, spin radians) [1]" TO WS-NAME
     MOVE -0.156585858 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 pose age 100 bobOffs 5.9 minY 0.3 (translate y, spin radians) [2]" TO WS-NAME
     MOVE 10.9 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1234.5 TO WS-IV(1)
     MOVE 0.3 TO WS-IV(2)
     MOVE -0.5 TO WS-IV(3)
     CALL "EF9-ITEM-POSE" USING WS-IN WS-OUT
     MOVE "9.2 pose age 1234.5 bobOffs 0.3 minY -0.5 (translate y, spin radians) [1]" TO WS-NAME
     MOVE 0.568321971 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 pose age 1234.5 bobOffs 0.3 minY -0.5 (translate y, spin radians) [2]" TO WS-NAME
     MOVE 62.025 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 187 TO WS-IV(2)
     MOVE 0.03125 TO WS-IV(3)
     CALL "EF9-CLUSTER" USING WS-IN WS-OUT
     MOVE "9.2 cluster of 1 seed 187 zSize 0.03125 (copies, then x y z each) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 1 seed 187 zSize 0.03125 (copies, then x y z each) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 1 seed 187 zSize 0.03125 (copies, then x y z each) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 1 seed 187 zSize 0.03125 (copies, then x y z each) [4]" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 5 TO WS-IV(2)
     MOVE 0.03125 TO WS-IV(3)
     CALL "EF9-CLUSTER" USING WS-IN WS-OUT
     MOVE "9.2 cluster of 2 seed 5 zSize 0.03125 (copies, then x y z each) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 2 seed 5 zSize 0.03125 (copies, then x y z each) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 2 seed 5 zSize 0.03125 (copies, then x y z each) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 2 seed 5 zSize 0.03125 (copies, then x y z each) [4]" TO WS-NAME
     MOVE -0.0234375 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 2 seed 5 zSize 0.03125 (copies, then x y z each) [5]" TO WS-NAME
     MOVE 0.034577975 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 2 seed 5 zSize 0.03125 (copies, then x y z each) [6]" TO WS-NAME
     MOVE -0.04850969 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 2 seed 5 zSize 0.03125 (copies, then x y z each) [7]" TO WS-NAME
     MOVE 0.0234375 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 1234 TO WS-IV(2)
     MOVE 0.03125 TO WS-IV(3)
     CALL "EF9-CLUSTER" USING WS-IN WS-OUT
     MOVE "9.2 cluster of 3 seed 1234 zSize 0.03125 (copies, then x y z each) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 3 seed 1234 zSize 0.03125 (copies, then x y z each) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 3 seed 1234 zSize 0.03125 (copies, then x y z each) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 3 seed 1234 zSize 0.03125 (copies, then x y z each) [4]" TO WS-NAME
     MOVE -0.046875 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 3 seed 1234 zSize 0.03125 (copies, then x y z each) [5]" TO WS-NAME
     MOVE 0.021987319 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 3 seed 1234 zSize 0.03125 (copies, then x y z each) [6]" TO WS-NAME
     MOVE -0.036031517 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 3 seed 1234 zSize 0.03125 (copies, then x y z each) [7]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 3 seed 1234 zSize 0.03125 (copies, then x y z each) [8]" TO WS-NAME
     MOVE 0.067703649 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 3 seed 1234 zSize 0.03125 (copies, then x y z each) [9]" TO WS-NAME
     MOVE -0.039383885 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 3 seed 1234 zSize 0.03125 (copies, then x y z each) [10]" TO WS-NAME
     MOVE 0.046875 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 98765 TO WS-IV(2)
     MOVE 0.03125 TO WS-IV(3)
     CALL "EF9-CLUSTER" USING WS-IN WS-OUT
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.03125 (copies, then x y z each) [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.03125 (copies, then x y z each) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.03125 (copies, then x y z each) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.03125 (copies, then x y z each) [4]" TO WS-NAME
     MOVE -0.09375 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.03125 (copies, then x y z each) [5]" TO WS-NAME
     MOVE 0.029080555 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.03125 (copies, then x y z each) [6]" TO WS-NAME
     MOVE 0.013626811 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.03125 (copies, then x y z each) [7]" TO WS-NAME
     MOVE -0.046875 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.03125 (copies, then x y z each) [8]" TO WS-NAME
     MOVE 0.008944425 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.03125 (copies, then x y z each) [9]" TO WS-NAME
     MOVE -0.014539629 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.03125 (copies, then x y z each) [10]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.03125 (copies, then x y z each) [11]" TO WS-NAME
     MOVE -0.067469707 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.03125 (copies, then x y z each) [12]" TO WS-NAME
     MOVE 0.025694427 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.03125 (copies, then x y z each) [13]" TO WS-NAME
     MOVE 0.046875 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.03125 (copies, then x y z each) [14]" TO WS-NAME
     MOVE 0.020724428 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.03125 (copies, then x y z each) [15]" TO WS-NAME
     MOVE -0.063506001 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.03125 (copies, then x y z each) [16]" TO WS-NAME
     MOVE 0.09375 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 7 TO WS-IV(2)
     MOVE 0.0625 TO WS-IV(3)
     CALL "EF9-CLUSTER" USING WS-IN WS-OUT
     MOVE "9.2 cluster of 4 seed 7 zSize 0.0625 (copies, then x y z each) [1]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 4 seed 7 zSize 0.0625 (copies, then x y z each) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 4 seed 7 zSize 0.0625 (copies, then x y z each) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 4 seed 7 zSize 0.0625 (copies, then x y z each) [4]" TO WS-NAME
     MOVE -0.140625 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 4 seed 7 zSize 0.0625 (copies, then x y z each) [5]" TO WS-NAME
     MOVE 0.03460485 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 4 seed 7 zSize 0.0625 (copies, then x y z each) [6]" TO WS-NAME
     MOVE 0.020780647 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 4 seed 7 zSize 0.0625 (copies, then x y z each) [7]" TO WS-NAME
     MOVE -0.046875 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 4 seed 7 zSize 0.0625 (copies, then x y z each) [8]" TO WS-NAME
     MOVE 0.037375438 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 4 seed 7 zSize 0.0625 (copies, then x y z each) [9]" TO WS-NAME
     MOVE -0.073555657 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 4 seed 7 zSize 0.0625 (copies, then x y z each) [10]" TO WS-NAME
     MOVE 0.046875 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 4 seed 7 zSize 0.0625 (copies, then x y z each) [11]" TO WS-NAME
     MOVE -0.022753546 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 4 seed 7 zSize 0.0625 (copies, then x y z each) [12]" TO WS-NAME
     MOVE -0.00140925 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 4 seed 7 zSize 0.0625 (copies, then x y z each) [13]" TO WS-NAME
     MOVE 0.140625 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 42 TO WS-IV(2)
     MOVE 0.0625001 TO WS-IV(3)
     CALL "EF9-CLUSTER" USING WS-IN WS-OUT
     MOVE "9.2 cluster of 2 seed 42 zSize 0.0625001 (copies, then x y z each) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 2 seed 42 zSize 0.0625001 (copies, then x y z each) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 2 seed 42 zSize 0.0625001 (copies, then x y z each) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 2 seed 42 zSize 0.0625001 (copies, then x y z each) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 2 seed 42 zSize 0.0625001 (copies, then x y z each) [5]" TO WS-NAME
     MOVE 0.068269104 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 2 seed 42 zSize 0.0625001 (copies, then x y z each) [6]" TO WS-NAME
     MOVE -0.133600438 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 2 seed 42 zSize 0.0625001 (copies, then x y z each) [7]" TO WS-NAME
     MOVE 0.054967028 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 98765 TO WS-IV(2)
     MOVE 0.25 TO WS-IV(3)
     CALL "EF9-CLUSTER" USING WS-IN WS-OUT
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.25 (copies, then x y z each) [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.25 (copies, then x y z each) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.25 (copies, then x y z each) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.25 (copies, then x y z each) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.25 (copies, then x y z each) [5]" TO WS-NAME
     MOVE 0.05816111 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.25 (copies, then x y z each) [6]" TO WS-NAME
     MOVE 0.027253622 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.25 (copies, then x y z each) [7]" TO WS-NAME
     MOVE 0.01788885 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.25 (copies, then x y z each) [8]" TO WS-NAME
     MOVE -0.029079258 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.25 (copies, then x y z each) [9]" TO WS-NAME
     MOVE -0.134939414 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.25 (copies, then x y z each) [10]" TO WS-NAME
     MOVE 0.051388854 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.25 (copies, then x y z each) [11]" TO WS-NAME
     MOVE 0.041448855 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.25 (copies, then x y z each) [12]" TO WS-NAME
     MOVE -0.127012002 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.25 (copies, then x y z each) [13]" TO WS-NAME
     MOVE 0.114354122 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.25 (copies, then x y z each) [14]" TO WS-NAME
     MOVE -0.052143252 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.25 (copies, then x y z each) [15]" TO WS-NAME
     MOVE -0.088238204 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 5 seed 98765 zSize 0.25 (copies, then x y z each) [16]" TO WS-NAME
     MOVE -0.127543187 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 187 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF9-CLUSTER" USING WS-IN WS-OUT
     MOVE "9.2 cluster of 3 seed 187 zSize 1 (copies, then x y z each) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 3 seed 187 zSize 1 (copies, then x y z each) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 3 seed 187 zSize 1 (copies, then x y z each) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 3 seed 187 zSize 1 (copies, then x y z each) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 3 seed 187 zSize 1 (copies, then x y z each) [5]" TO WS-NAME
     MOVE 0.072112137 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 3 seed 187 zSize 1 (copies, then x y z each) [6]" TO WS-NAME
     MOVE 0.024917436 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 3 seed 187 zSize 1 (copies, then x y z each) [7]" TO WS-NAME
     MOVE -0.018487573 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 3 seed 187 zSize 1 (copies, then x y z each) [8]" TO WS-NAME
     MOVE -0.002575761 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 3 seed 187 zSize 1 (copies, then x y z each) [9]" TO WS-NAME
     MOVE 0.076856446 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.2 cluster of 3 seed 187 zSize 1 (copies, then x y z each) [10]" TO WS-NAME
     MOVE 0.136393493 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 5 TO WS-IV(2)
     MOVE 0.5 TO WS-IV(3)
     CALL "EF9-CLUSTER" USING WS-IN WS-OUT
     MOVE "9.2 cluster of 0 seed 5 zSize 0.5 (copies, then x y z each)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF9-SPAWNER-OPS" USING WS-IN WS-OUT
     MOVE "9.3 ominous item spawner pose at age 0 [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 0 [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 0 [3]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 0 [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 0 [5]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 0 [6]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 0 [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 0 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 0 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10 TO WS-IV(1)
     CALL "EF9-SPAWNER-OPS" USING WS-IN WS-OUT
     MOVE "9.3 ominous item spawner pose at age 10 [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 10 [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 10 [3]" TO WS-NAME
     MOVE 0.2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 10 [4]" TO WS-NAME
     MOVE 0.2 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 10 [5]" TO WS-NAME
     MOVE 0.2 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 10 [6]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 10 [7]" TO WS-NAME
     MOVE 40 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 10 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 10 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 25 TO WS-IV(1)
     CALL "EF9-SPAWNER-OPS" USING WS-IN WS-OUT
     MOVE "9.3 ominous item spawner pose at age 25 [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 25 [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 25 [3]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 25 [4]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 25 [5]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 25 [6]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 25 [7]" TO WS-NAME
     MOVE -80 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 25 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 25 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 50 TO WS-IV(1)
     CALL "EF9-SPAWNER-OPS" USING WS-IN WS-OUT
     MOVE "9.3 ominous item spawner pose at age 50 [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 50 [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 50 [3]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 50 [4]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 50 [5]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 50 [6]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 50 [7]" TO WS-NAME
     MOVE -160 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 50 [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 50 [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 50.5 TO WS-IV(1)
     CALL "EF9-SPAWNER-OPS" USING WS-IN WS-OUT
     MOVE "9.3 ominous item spawner pose at age 50.5 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 50.5 [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 50.5 [3]" TO WS-NAME
     MOVE -140.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 50.5 [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 50.5 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE 51 TO WS-IV(1)
     CALL "EF9-SPAWNER-OPS" USING WS-IN WS-OUT
     MOVE "9.3 ominous item spawner pose at age 51 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 51 [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 51 [3]" TO WS-NAME
     MOVE -120 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 51 [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 51 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE 80 TO WS-IV(1)
     CALL "EF9-SPAWNER-OPS" USING WS-IN WS-OUT
     MOVE "9.3 ominous item spawner pose at age 80 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 80 [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 80 [3]" TO WS-NAME
     MOVE -40 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 80 [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 80 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE 400.25 TO WS-IV(1)
     CALL "EF9-SPAWNER-OPS" USING WS-IN WS-OUT
     MOVE "9.3 ominous item spawner pose at age 400.25 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 400.25 [2]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 400.25 [3]" TO WS-NAME
     MOVE 170.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 400.25 [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 ominous item spawner pose at age 400.25 [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF9-SPAWNER-LIGHT" USING WS-IN WS-OUT
     MOVE "9.3 fixed light coordinates (block 15, sky 15)" TO WS-NAME
     MOVE 15728880 TO WS-E
     MOVE WS-OV(1) TO WS-O
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
 END PROGRAM TEST-ENTMODEL-34-9-9.
