*> Acceptance test of the nether fortress start and growth (docs/protocol/36-structures-8-nether-and-end.md section 2 and 7.4, 18.1 items 3 and 10; core/src/struct-fortress.cob; T13507): the start
*> piece at (minBlockX + 2, minBlockZ + 2) with the first draw of the generation as its orientation, its 19 by 10 by 19 box, every child coming from the pending list until it is empty, the
*> distance limit of 112 and the vertical placement between 48 and 70 (moveInsideHeights).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-8-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTPIECE.
 COPY STRUCTFORT.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-REF                 BINARY-DOUBLE UNSIGNED.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-DRAW                BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-BAD-START           BINARY-LONG VALUE 0.
 01 WS-BAD-ORIENT          BINARY-LONG VALUE 0.
 01 WS-BAD-Y               BINARY-LONG VALUE 0.
 01 WS-BAD-FAR             BINARY-LONG VALUE 0.
 01 WS-BAD-PEND            BINARY-LONG VALUE 0.
 01 WS-MINY                BINARY-LONG.
 01 WS-MAXY                BINARY-LONG.
 01 WS-SPAN                BINARY-LONG.
 01 WS-COUNT1              BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-SIZES.
    05 WS-SEEN-LOW         BINARY-LONG VALUE 0.
    05 WS-SEEN-HIGH        BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 50
         COMPUTE WS-CX = WS-K - 25
         COMPUTE WS-CZ = FUNCTION MOD(WS-K * 11, 17) - 8
         CALL "FORT-START" USING WS-SEED WS-CX WS-CZ
*>       the orientation is the first draw after the seeding
         CALL "JRAND-LARGE-FEATURE-SEED" USING WS-REF WS-SEED WS-CX WS-CZ
         CALL "JRAND-NEXT-INT-BOUND" USING WS-REF WS-FOUR WS-DRAW
         EVALUATE WS-DRAW
             WHEN 0
                 MOVE 2 TO WS-WANT
             WHEN 1
                 MOVE 3 TO WS-WANT
             WHEN 2
                 MOVE 0 TO WS-WANT
             WHEN OTHER
                 MOVE 1 TO WS-WANT
         END-EVALUATE
         IF SP-ORIENT(1) NOT = WS-WANT OR SP-TYPE(1) NOT = 18 OR SP-DEPTH(1) NOT = 0
             ADD 1 TO WS-BAD-ORIENT
         END-IF
*>       the start box: x and z from the chunk, ten high
         COMPUTE WS-SX = WS-CX * 16 + 2
         COMPUTE WS-SZ = WS-CZ * 16 + 2
         IF SP-X0(1) NOT = WS-SX OR SP-Z0(1) NOT = WS-SZ OR SP-X1(1) NOT = WS-SX + 18 OR SP-Z1(1) NOT = WS-SZ + 18
             OR SP-Y1(1) - SP-Y0(1) NOT = 9
             ADD 1 TO WS-BAD-START
         END-IF
         IF FO-PEND-N NOT = 0
             ADD 1 TO WS-BAD-PEND
         END-IF
         MOVE 1000 TO WS-MINY
         MOVE -1000 TO WS-MAXY
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-COUNT
             IF SP-Y0(WS-I) < WS-MINY
                 MOVE SP-Y0(WS-I) TO WS-MINY
             END-IF
             IF SP-Y1(WS-I) > WS-MAXY
                 MOVE SP-Y1(WS-I) TO WS-MAXY
             END-IF
             IF FUNCTION ABS(SP-X0(WS-I) - WS-SX) > 112 + 40 OR FUNCTION ABS(SP-Z0(WS-I) - WS-SZ) > 112 + 40
                 ADD 1 TO WS-BAD-FAR
             END-IF
         END-PERFORM
         COMPUTE WS-SPAN = WS-MAXY - WS-MINY + 1
         IF WS-MINY < 48
             ADD 1 TO WS-BAD-Y
         END-IF
         IF WS-SPAN <= 22 AND WS-MAXY > 70
             ADD 1 TO WS-BAD-Y
         END-IF
         IF WS-SPAN <= 22 AND WS-MINY > 48
             ADD 1 TO WS-SEEN-HIGH
         END-IF
         IF WS-MINY = 48
             ADD 1 TO WS-SEEN-LOW
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§2 A. Nether fortress: structure, start and growth: the start piece faces the first draw of the generation" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-ORIENT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§2 A. Nether fortress: structure, start and growth: the start box is (16 cx + 2, 16 cz + 2), 19 wide, 10 high" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-START TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§2 A. Nether fortress: structure, start and growth: growth ends with no pending piece" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-PEND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§2 A. Nether fortress: structure, start and growth: no piece lies far beyond the 112 limit from the start" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-FAR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§2 A. Nether fortress: structure, start and growth: the fortress starts at y 48 or above and ends by 70 when it fits" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-Y TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§2 A. Nether fortress: structure, start and growth: the minimum y is 48 for some and above 48 for others (a draw of 48 + nextInt)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SEEN-LOW > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the same start gives the same fortress
     MOVE SP-COUNT TO WS-COUNT1
     CALL "FORT-START" USING WS-SEED WS-CX WS-CZ
     MOVE "acceptance US12 36-8§2 A. Nether fortress: structure, start and growth: the same start gives the same piece count" TO TL-CASE
     MOVE WS-COUNT1 TO TL-EXPECTED-N
     MOVE SP-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     DISPLAY "PROBE seen high " WS-SEEN-HIGH " low " WS-SEEN-LOW
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-8-2.
