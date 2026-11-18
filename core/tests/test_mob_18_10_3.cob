*> Acceptance test (lane p49a, T14504; docs/protocol/18-mob-framework.md section 10.3 A path on a grid): the worked example. Open flat
*> ground, a 0.6 wide mob, start block (0, 64, 0) and target block (3, 64, 0) (the snapshot cell (2, 1, 2) to (5, 1, 2)), follow_range 16.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-10-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY MOBPATH.
 01 WS-P                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-RANGE               FLOAT-LONG.
 01 WS-MULT                FLOAT-LONG VALUE 1.
 01 WS-BUDGET              BINARY-LONG.
 01 WS-WIDTH               FLOAT-LONG VALUE 0.6.
 01 WS-INDEX               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-MX                  FLOAT-LONG.
 01 WS-MY                  FLOAT-LONG.
 01 WS-MZ                  FLOAT-LONG.
 01 WS-REACHED             BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-NOW                 BINARY-LONG.
 01 WS-STUCK               BINARY-LONG.
 01 WS-WANT                FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE 16 TO WS-RANGE
     CALL "PATH-BUDGET" USING WS-RANGE WS-MULT WS-BUDGET
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 18§10.3 A path on a grid: follow_range 16 gives the node budget 256" TO TL-CASE
     MOVE 256 TO TL-EXPECTED-N
     MOVE WS-BUDGET TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

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
     END-PERFORM
     INITIALIZE PF-SEARCH
     INITIALIZE PF-MALUS-TABLE
     MOVE 1 TO PS-KIND
     MOVE 1 TO PS-TARGET-COUNT
     MOVE 1 TO PS-WIDTH
     MOVE 2 TO PS-HEIGHT
     MOVE 3 TO PS-MAX-FALL
     MOVE 1 TO PS-STEP
     MOVE 16 TO PS-MAX-DIST
     MOVE WS-BUDGET TO PS-BUDGET
     MOVE 2 TO PS-SX
     MOVE 1 TO PS-SY
     MOVE 2 TO PS-SZ
     MOVE 5 TO PS-TX(1)
     MOVE 1 TO PS-TY(1)
     MOVE 2 TO PS-TZ(1)
     MOVE 0 TO PS-REACH
     CALL "PATH-FIND" USING PF-WORLD PF-MALUS-TABLE PF-SEARCH PF-NODES

     MOVE "acceptance US15 18§10.3 A path on a grid: the target is reached" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PS-REACHED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§10.3 A path on a grid: the path is the four nodes (0,0) to (3,0)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE PS-PATH-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE "acceptance US15 18§10.3 A path on a grid: node x runs 2 3 4 5 along z 2" TO TL-CASE
         COMPUTE TL-EXPECTED-N = WS-I + 1
         COMPUTE TL-OBSERVED-N = PS-PX(WS-I) * (PS-PZ(WS-I) - 1)
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   The start has f = h = 3 (unweighted); its neighbours have h weighted 1.5.
     MOVE 2 TO WS-A
     MOVE 1 TO WS-B
     MOVE 2 TO WS-C
     PERFORM FIND-NODE
     MOVE "acceptance US15 18§10.3 A path on a grid: the start has h = 3.0 and g = 0" TO TL-CASE
     MOVE 3000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = PN-H(WS-NODE) * 1000 + PN-G(WS-NODE)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   East (1,0): g 1, h 3, f 4.0.
     MOVE 3 TO WS-A
     PERFORM FIND-NODE
     MOVE "acceptance US15 18§10.3 A path on a grid: east neighbour g 1, h 3, f 4.0" TO TL-CASE
     MOVE 4000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (PN-G(WS-NODE) + PN-H(WS-NODE)) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   North (0,1): g 1, h 4.743, f 5.743.
     MOVE 2 TO WS-A
     MOVE 3 TO WS-C
     PERFORM FIND-NODE
     MOVE "acceptance US15 18§10.3 A path on a grid: north neighbour f 5.743" TO TL-CASE
     MOVE 5743 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (PN-G(WS-NODE) + PN-H(WS-NODE)) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   South (0,-1) is the same distance as north.
     MOVE 1 TO WS-C
     PERFORM FIND-NODE
     MOVE "acceptance US15 18§10.3 A path on a grid: south neighbour f 5.743" TO TL-CASE
     COMPUTE TL-OBSERVED-N ROUNDED = (PN-G(WS-NODE) + PN-H(WS-NODE)) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   West (-1,0): h 6, f 7.
     MOVE 1 TO WS-A
     MOVE 2 TO WS-C
     PERFORM FIND-NODE
     MOVE "acceptance US15 18§10.3 A path on a grid: west neighbour f 7.0" TO TL-CASE
     MOVE 7000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (PN-G(WS-NODE) + PN-H(WS-NODE)) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   East-north diagonal (1,1): g 1.4142, h 3.354, f 4.768.
     MOVE 3 TO WS-A
     MOVE 3 TO WS-C
     PERFORM FIND-NODE
     MOVE "acceptance US15 18§10.3 A path on a grid: east-north diagonal f 4.768" TO TL-CASE
     MOVE 4768 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (PN-G(WS-NODE) + PN-H(WS-NODE)) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   (2,0): g 2, h 1.5, f 3.5. (2,1): g 2.4142, h 2.121, f 4.536. (3,0): g 3, h 0, f 3.0.
     MOVE 4 TO WS-A
     MOVE 2 TO WS-C
     PERFORM FIND-NODE
     MOVE "acceptance US15 18§10.3 A path on a grid: node (2,0) f 3.5" TO TL-CASE
     MOVE 3500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (PN-G(WS-NODE) + PN-H(WS-NODE)) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-C
     PERFORM FIND-NODE
     MOVE "acceptance US15 18§10.3 A path on a grid: node (2,1) f 4.536" TO TL-CASE
     MOVE 4536 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (PN-G(WS-NODE) + PN-H(WS-NODE)) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-A
     MOVE 2 TO WS-C
     PERFORM FIND-NODE
     MOVE "acceptance US15 18§10.3 A path on a grid: the target node g 3, h 0, f 3.0" TO TL-CASE
     MOVE 3000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = (PN-G(WS-NODE) + PN-H(WS-NODE)) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Following: a 0.6 wide mob aims at the node's centre, +0.5 in x and z; it has reached it within 0.45 in x and z and 1.0 in y.
     MOVE 1 TO WS-INDEX
     CALL "PATH-NEXT-ENTITY-POS" USING PF-SEARCH WS-INDEX WS-WIDTH WS-X WS-Y WS-Z
     MOVE "acceptance US15 18§10.3 A path on a grid: the first node aims at x + 0.5" TO TL-CASE
     MOVE 250 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-X * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§10.3 A path on a grid: and z + 0.5" TO TL-CASE
     COMPUTE TL-OBSERVED-N ROUNDED = WS-Z * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-X
     MOVE 1 TO WS-Y
     MOVE 2 TO WS-Z
     MOVE 3.0 TO WS-MX
     MOVE 1.0 TO WS-MY
     MOVE 3.0 TO WS-MZ
     CALL "FOLLOW-REACHED" USING WS-MX WS-MY WS-MZ WS-X WS-Y WS-Z WS-WIDTH WS-REACHED
     MOVE "acceptance US15 18§10.3 A path on a grid: 0.5 from the centre is not within 0.45" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-REACHED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2.9 TO WS-MX
     MOVE 2.9 TO WS-MZ
     CALL "FOLLOW-REACHED" USING WS-MX WS-MY WS-MZ WS-X WS-Y WS-Z WS-WIDTH WS-REACHED
     MOVE "acceptance US15 18§10.3 A path on a grid: 0.4 from the centre in x and z is reached" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-REACHED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Stuck: speed 0.25 cancels a path after 100 ticks when the squared displacement is below 2.44 (1.5625 squared).
     MOVE 0.25 TO WS-SPEED
     MOVE 101 TO WS-NOW
     MOVE 0 TO PV-LAST-CHECK PV-STUCK PV-LAST-X PV-LAST-Y PV-LAST-Z
     MOVE 5 TO PV-COUNT
     MOVE 1.5 TO WS-X
     MOVE 0 TO WS-Y WS-Z
     CALL "STUCK-CHECK" USING PF-NAV WS-SPEED WS-NOW WS-X WS-Y WS-Z WS-STUCK
     MOVE "acceptance US15 18§10.3 A path on a grid: 1.5 blocks in 100 ticks at speed 0.25 is stuck" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-STUCK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PV-LAST-CHECK PV-STUCK PV-LAST-X PV-LAST-Y PV-LAST-Z
     MOVE 5 TO PV-COUNT
     MOVE 1.6 TO WS-X
     CALL "STUCK-CHECK" USING PF-NAV WS-SPEED WS-NOW WS-X WS-Y WS-Z WS-STUCK
     MOVE "acceptance US15 18§10.3 A path on a grid: 1.6 blocks is not" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STUCK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 FIND-NODE.
     COMPUTE WS-P = (WS-B * PW-DZ + WS-C) * PW-DX + WS-A + 1
     MOVE PN-INDEX(WS-P) TO WS-NODE.
 END PROGRAM TEST-MOB-18-10-3.
