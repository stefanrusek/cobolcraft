*> Implementation test (002-lane-mobsfull-h2, T2238; docs/protocol/18 section 5.2 Nodes, costs and A*): node distances, the node budget and the weighted A* of PATH-FIND over a world snapshot.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-5-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY MOBPATH.
 01 WS-A                 BINARY-LONG.
 01 WS-B                 BINARY-LONG.
 01 WS-C                 BINARY-LONG.
 01 WS-D                 BINARY-LONG.
 01 WS-E                 BINARY-LONG.
 01 WS-F                 BINARY-LONG.
 01 WS-G                 BINARY-LONG.
 01 WS-H                 BINARY-LONG.
 01 WS-I                 BINARY-LONG.
 01 WS-J                 BINARY-LONG.
 01 WS-K                 BINARY-LONG.
 01 WS-L                 BINARY-LONG.
 01 WS-M                 BINARY-LONG.
 01 WS-N                 BINARY-LONG.
 01 WS-O                 BINARY-LONG.
 01 WS-P                 BINARY-LONG.
 01 WS-O1                BINARY-LONG.
 01 WS-O2                BINARY-LONG.
 01 WS-O3                BINARY-LONG.
 01 WS-O4                BINARY-LONG.
 01 WS-O5                BINARY-LONG.
 01 WS-O6                BINARY-LONG.
 01 WS-O7                BINARY-LONG.
 01 WS-O8                BINARY-LONG.
 01 WS-F1                FLOAT-LONG.
 01 WS-F2                FLOAT-LONG.
 01 WS-F3                FLOAT-LONG.
 01 WS-F4                FLOAT-LONG.
 01 WS-F5                FLOAT-LONG.
 01 WS-F6                FLOAT-LONG.
 01 WS-F7                FLOAT-LONG.
 01 WS-F8                FLOAT-LONG.
 01 WS-G1                FLOAT-LONG.
 01 WS-G2                FLOAT-LONG.
 01 WS-G3                FLOAT-LONG.
 01 WS-G4                FLOAT-LONG.
 01 WS-T                 PIC X(80).
 01 WS-U                 PIC X(80).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0 TO WS-C
     MOVE 1 TO WS-D
     MOVE 2 TO WS-E
     MOVE 2 TO WS-H
     CALL "NODE-DISTANCE" USING WS-A WS-B WS-C WS-D WS-E WS-H WS-G1 WS-O1
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* Node.distanceTo is Euclidean in float" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 3 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-G1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* Node.distanceTo has a Manhattan form" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 5 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 16 TO WS-F1
     MOVE 1 TO WS-F2
     CALL "PATH-BUDGET" USING WS-F1 WS-F2 WS-O1
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* the node budget is floor(follow_range x 16) x multiplier (16 gives 256)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 256 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1.5 TO WS-F2
     CALL "PATH-BUDGET" USING WS-F1 WS-F2 WS-O1
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* the node budget multiplier 1.5 gives 384" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 384 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7.5 TO WS-F1
     MOVE 1 TO WS-F2
     CALL "PATH-BUDGET" USING WS-F1 WS-F2 WS-O1
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* the node budget truncates (7.5 gives 120)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 120 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM BUILD-FLAT
     PERFORM INIT-SEARCH
     CALL "PATH-FIND" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* a straight path on flat ground reaches the target" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-REACHED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* a straight path of 5 nodes" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 5 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-PATH-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* the path runs from the start node" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-PX(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* the path ends at the target" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 6 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-PX(5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     MOVE 2 TO WS-C
     PERFORM FIND-NODE
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* the start node heuristic is unweighted (distance 4)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 40 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PN-H(WS-O1) * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* the start node has g 0" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PN-G(WS-O1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-A
     PERFORM FIND-NODE
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* a neighbour has g = the step distance (1)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PN-G(WS-O1) * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* a neighbour heuristic is weighted 1.5 (3 x 1.5)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 45 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PN-H(WS-O1) * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM BUILD-FLAT
     PERFORM INIT-SEARCH
     MOVE 5 TO PS-TX(1)
     MOVE 5 TO PS-TZ(1)
     CALL "PATH-FIND" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* a diagonal path takes the diagonal (4 nodes)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 4 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-PATH-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* the diagonal path reaches the target" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-REACHED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM BUILD-FLAT
     PERFORM INIT-SEARCH
     PERFORM BUILD-WALL
     MOVE 9 TO WS-E
     CALL "PATH-FIND" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* a wall forces a detour that reaches the target" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-REACHED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM CHECK-COUNT
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* the detour is longer than the straight path" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O2
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM CHECK-WALL
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* the detour never crosses the wall" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O3
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM BUILD-FLAT
     PERFORM INIT-SEARCH
     MOVE 4 TO WS-A
     MOVE 0 TO WS-B
     MOVE 2 TO WS-C
     MOVE 9 TO WS-D
     PERFORM SET-CELL
     CALL "PATH-FIND" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* a cheap detour avoids a water square (malus 8)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-REACHED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-A
     MOVE 1 TO WS-B
     MOVE 2 TO WS-C
     PERFORM COUNT-NODE-AT
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* the path does not step on the water square" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O3
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM BUILD-FLAT
     PERFORM INIT-SEARCH
     MOVE 6 TO WS-A
     MOVE 1 TO WS-B
     MOVE 2 TO WS-C
     MOVE 0 TO WS-D
     PERFORM SET-CELL
     MOVE 2 TO WS-B
     PERFORM SET-CELL
     CALL "PATH-FIND" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* an unreachable target gives a path to the node that came closest" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-REACHED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* the closest node is the one next to the target on the start side" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 5 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-PX(PS-PATH-COUNT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* the closest node path has 4 nodes" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 4 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-PATH-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM BUILD-FLAT
     PERFORM INIT-SEARCH
     MOVE 1 TO PS-REACH
     CALL "PATH-FIND" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* reach 1 stops one block before the target" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 4 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-PATH-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* reach counts as reached" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-REACHED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM BUILD-FLAT
     PERFORM INIT-SEARCH
     MOVE 10 TO PS-TX(1)
     MOVE 3.5 TO PS-MAX-DIST
     CALL "PATH-FIND" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* a node at distance max from the start is not expanded" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-REACHED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* the search stopped at the distance limit" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 5 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-PX(PS-PATH-COUNT)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM BUILD-FLAT
     PERFORM INIT-SEARCH
     MOVE 2 TO PS-BUDGET
     MOVE 10 TO PS-TX(1)
     CALL "PATH-FIND" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* the node budget limits the nodes popped" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-VISITED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* a budget-limited search is not reached" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-REACHED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM BUILD-FLAT
     PERFORM INIT-SEARCH
     MOVE 2 TO PS-TARGET-COUNT
     MOVE 3 TO PS-TX(2)
     MOVE 1 TO PS-TY(2)
     MOVE 2 TO PS-TZ(2)
     CALL "PATH-FIND" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* with several targets the path with the fewest nodes wins" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-PATH-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* the nearer target was reached" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-REACHED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM BUILD-FLAT
     PERFORM INIT-SEARCH
     MOVE 0 TO PS-SY
     CALL "PATH-FIND" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* a start inside solid rock gives no path" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-PATH-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* and the target is not reached" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-REACHED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM BUILD-FLAT
     PERFORM INIT-SEARCH
     MOVE 2 TO PS-TARGET-COUNT
     MOVE 2 TO PS-TX(1)
     MOVE 1 TO PS-TY(1)
     MOVE 9 TO PS-TZ(1)
     MOVE 6 TO PS-TX(2)
     MOVE 1 TO PS-TY(2)
     MOVE 2 TO PS-TZ(2)
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     MOVE 9 TO WS-C
     MOVE 0 TO WS-D
     PERFORM SET-CELL
     MOVE 6 TO WS-A
     MOVE 2 TO WS-C
     PERFORM SET-CELL
     CALL "PATH-FIND" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES
     MOVE "acceptance US15 18§5.2 Nodes, costs and A* two unreachable targets with equal best distance: the one with fewer nodes wins" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 4 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PS-PATH-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 BUILD-FLAT.
     INITIALIZE PF-WORLD
     INITIALIZE PF-NODES
     MOVE 16 TO PW-DX
     MOVE 8 TO PW-DY
     MOVE 16 TO PW-DZ
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > 2048
         MOVE 1 TO PW-CELL(WS-P)
     END-PERFORM
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > 256
         MOVE 0 TO PW-CELL(WS-P)
     END-PERFORM.
 INIT-SEARCH.
     INITIALIZE PF-SEARCH
     INITIALIZE PF-MALUS-TABLE
     MOVE 1 TO PS-KIND
     MOVE 1 TO PS-TARGET-COUNT
     MOVE 1 TO PS-WIDTH
     MOVE 2 TO PS-HEIGHT
     MOVE 3 TO PS-MAX-FALL
     MOVE 1 TO PS-STEP
     MOVE 100 TO PS-MAX-DIST
     MOVE 1000 TO PS-BUDGET
     MOVE 2 TO PS-SX
     MOVE 1 TO PS-SY
     MOVE 2 TO PS-SZ
     MOVE 6 TO PS-TX(1)
     MOVE 1 TO PS-TY(1)
     MOVE 2 TO PS-TZ(1).
 SET-CELL.
     COMPUTE WS-P = (WS-B * PW-DZ + WS-C) * PW-DX + WS-A + 1
     MOVE WS-D TO PW-CELL(WS-P).
 FIND-NODE.
     COMPUTE WS-P = (WS-B * PW-DZ + WS-C) * PW-DX + WS-A + 1
     MOVE PN-INDEX(WS-P) TO WS-O1.
 BUILD-WALL.
     PERFORM VARYING WS-C FROM 0 BY 1 UNTIL WS-C > 6
         MOVE 4 TO WS-A
         MOVE 1 TO WS-B
         MOVE 0 TO WS-D
         PERFORM SET-CELL
         MOVE 2 TO WS-B
         PERFORM SET-CELL
     END-PERFORM.
 COUNT-NODE-AT.
     MOVE 0 TO WS-O3
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > PS-PATH-COUNT
         IF PS-PX(WS-P) = WS-A AND PS-PY(WS-P) = WS-B AND PS-PZ(WS-P) = WS-C
             ADD 1 TO WS-O3
         END-IF
     END-PERFORM.
 CHECK-WALL.
     MOVE 0 TO WS-O3
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > PS-PATH-COUNT
         IF PS-PX(WS-P) = 4 AND PS-PZ(WS-P) < 7
             ADD 1 TO WS-O3
         END-IF
     END-PERFORM.
 CHECK-COUNT.
     MOVE 0 TO WS-O2
     IF PS-PATH-COUNT NOT < WS-E
         MOVE 1 TO WS-O2
     END-IF.
 END PROGRAM TEST-MOB-18-5-2.
