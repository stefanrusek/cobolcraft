*> Implementation test of the helpers of docs/protocol/35-worldgen-features-7-nether-end-misc.md section 2 (T1272; core/src/feat-35-7.cob): betweenClosed (2.1: the n-th position by the document's formula, the two-
*> corner overload accepts the corners in any order), randomBetweenClosed (2.2: three draws, nextInt(maxX - minX + 1) then y then z, each added to its minimum, taken lazily, so a draw of the consumer in between is
*> interleaved; positions may repeat; a one-cell range still draws) and withinBoxByManhattanDistance (2.3: ordered by Manhattan distance, the within-depth order of its three rules, the +dz offset followed at once by
*> -dz, the total (2 rx + 1)(2 ry + 1)(2 rz + 1), and an index past the end yields nothing). The Manhattan model builds the whole box and orders it by a different method (the sort key depth, x, y, then +dz before -dz).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-7-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-S1                  BINARY-DOUBLE UNSIGNED.
 01 WS-S2                  BINARY-DOUBLE UNSIGNED.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 777.
 01 WS-N                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RY                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-CASE                PIC X(120).
 01 WS-SIG                 BINARY-LONG.
 01 WS-PX                  PIC 9.
 01 WS-PY                  PIC 9.
 01 WS-PZ                  PIC 9.
*> the model: every offset of the box with its sort key, the offsets in sorted order
 01 WS-MODEL.
    05 WS-M OCCURS 400 TIMES.
       10 WS-MK            BINARY-LONG.
       10 WS-MX            BINARY-LONG.
       10 WS-MY            BINARY-LONG.
       10 WS-MZ            BINARY-LONG.
 01 WS-TMP.
    05 WS-TK               BINARY-LONG.
    05 WS-TX               BINARY-LONG.
    05 WS-TY               BINARY-LONG.
    05 WS-TZ               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-SHAPES.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 0.
 01 WS-SH REDEFINES WS-SHAPES.
    05 WS-SHAPE OCCURS 4 TIMES.
       10 WS-SRX           BINARY-LONG.
       10 WS-SRY           BINARY-LONG.
       10 WS-SRZ           BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   2.1 the formula (w = 3, h = 2): n = 7 is (minX + 7 mod 3, minY + (7 div 3) mod 2, minZ + (7 div 3) div 2) = (-1, 5, 3); the two-corner form takes the corners in any order
     MOVE -2 TO WS-X0
     MOVE 4 TO WS-Y0
     MOVE 3 TO WS-Z0
     MOVE 0 TO WS-X1
     MOVE 5 TO WS-Y1
     MOVE 5 TO WS-Z1
     MOVE 7 TO WS-INDEX
     CALL "F355-BETWEEN" USING WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-INDEX WS-X WS-Y WS-Z
     MOVE "acceptance US12 35-7§2.1 betweenClosed n = 7 of a 3 x 2 x 3 box is (-1, 4, 4) by the document's formula" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-X + 5) * 10000 + WS-Y * 100 + WS-Z
     MOVE 40404 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "F355-BETWEEN" USING WS-X1 WS-Y1 WS-Z1 WS-X0 WS-Y0 WS-Z0 WS-INDEX WS-X WS-Y WS-Z
     MOVE "acceptance US12 35-7§2.1 the two-position overload takes the corners in any order (swapped corners give the same n-th position)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-X + 5) * 10000 + WS-Y * 100 + WS-Z
     MOVE 40404 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 17 TO WS-INDEX
     CALL "F355-BETWEEN" USING WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-INDEX WS-X WS-Y WS-Z
     MOVE "acceptance US12 35-7§2.1 the last of the 18 positions is the maximum corner" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-X * 10000 + WS-Y * 100 + WS-Z
     MOVE 505 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   2.2 randomBetweenClosed: x, y, z draws in this order, each nextInt(range) + min
     CALL "JRAND-SET-SEED" USING WS-S1 WS-SEED
     MOVE WS-S1 TO WS-S2
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         CALL "F357-RANDOM-POS" USING WS-S1 WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-X WS-Y WS-Z
         COMPUTE WS-N = WS-X1 - WS-X0 + 1
         CALL "JRAND-NEXT-INT-BOUND" USING WS-S2 WS-N WS-A
         COMPUTE WS-N = WS-Y1 - WS-Y0 + 1
         CALL "JRAND-NEXT-INT-BOUND" USING WS-S2 WS-N WS-B
         COMPUTE WS-N = WS-Z1 - WS-Z0 + 1
         CALL "JRAND-NEXT-INT-BOUND" USING WS-S2 WS-N WS-C
         IF WS-X NOT = WS-X0 + WS-A OR WS-Y NOT = WS-Y0 + WS-B OR WS-Z NOT = WS-Z0 + WS-C
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 35-7§2.2 six positions are x = min + nextInt(w), y, z, three draws each in that order" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a draw of the consumer between two positions is interleaved: position, one nextInt(7), position
     CALL "JRAND-SET-SEED" USING WS-S1 WS-SEED
     MOVE WS-S1 TO WS-S2
     CALL "F357-RANDOM-POS" USING WS-S1 WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-X WS-Y WS-Z
     MOVE 7 TO WS-N
     CALL "JRAND-NEXT-INT-BOUND" USING WS-S1 WS-N WS-K
     CALL "F357-RANDOM-POS" USING WS-S1 WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-X WS-Y WS-Z
     MOVE 3 TO WS-N
     CALL "JRAND-NEXT-INT-BOUND" USING WS-S2 WS-N WS-A
     MOVE 2 TO WS-N
     CALL "JRAND-NEXT-INT-BOUND" USING WS-S2 WS-N WS-B
     MOVE 3 TO WS-N
     CALL "JRAND-NEXT-INT-BOUND" USING WS-S2 WS-N WS-C
     MOVE 7 TO WS-N
     CALL "JRAND-NEXT-INT-BOUND" USING WS-S2 WS-N WS-W
     MOVE "acceptance US12 35-7§2.2 a consumer's own draw between two positions stays between their draws (lazy production)" TO TL-CASE
     MOVE WS-W TO TL-EXPECTED-N
     MOVE WS-K TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-N
     CALL "JRAND-NEXT-INT-BOUND" USING WS-S2 WS-N WS-A
     MOVE 2 TO WS-N
     CALL "JRAND-NEXT-INT-BOUND" USING WS-S2 WS-N WS-B
     MOVE 3 TO WS-N
     CALL "JRAND-NEXT-INT-BOUND" USING WS-S2 WS-N WS-C
     MOVE "acceptance US12 35-7§2.2 the second position uses the draws after the consumer's" TO TL-CASE
     COMPUTE TL-EXPECTED-N = (WS-X0 + WS-A + 5) * 10000 + (WS-Y0 + WS-B) * 100 + WS-Z0 + WS-C
     COMPUTE TL-OBSERVED-N = (WS-X + 5) * 10000 + WS-Y * 100 + WS-Z
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a single cell: every position is that cell (the draws are nextInt(1) = 0)
     CALL "JRAND-SET-SEED" USING WS-S1 WS-SEED
     MOVE 3 TO WS-X0 WS-X1
     MOVE 4 TO WS-Y0 WS-Y1
     MOVE 5 TO WS-Z0 WS-Z1
     CALL "F357-RANDOM-POS" USING WS-S1 WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-X WS-Y WS-Z
     MOVE "acceptance US12 35-7§2.2 a one-cell range yields that cell" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-X * 10000 + WS-Y * 100 + WS-Z
     MOVE 30405 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   2.3 withinBoxByManhattanDistance against the model, four shapes
     PERFORM VARYING WS-SIG FROM 1 BY 1 UNTIL WS-SIG > 4
         MOVE WS-SRX(WS-SIG) TO WS-RX
         MOVE WS-SRY(WS-SIG) TO WS-RY
         MOVE WS-SRZ(WS-SIG) TO WS-RZ
         MOVE 0 TO WS-TOTAL
         PERFORM VARYING WS-DX FROM 0 BY 1 UNTIL WS-DX > 2 * WS-RX
             PERFORM VARYING WS-DY FROM 0 BY 1 UNTIL WS-DY > 2 * WS-RY
                 PERFORM VARYING WS-DZ FROM 0 BY 1 UNTIL WS-DZ > 2 * WS-RZ
                     ADD 1 TO WS-TOTAL
                     COMPUTE WS-MX(WS-TOTAL) = WS-DX - WS-RX
                     COMPUTE WS-MY(WS-TOTAL) = WS-DY - WS-RY
                     COMPUTE WS-MZ(WS-TOTAL) = WS-DZ - WS-RZ
*>                   key: depth, then x + 8, then y + 8, then z descending-sign order (+dz before -dz)
                     COMPUTE WS-MK(WS-TOTAL) = (FUNCTION ABS(WS-MX(WS-TOTAL)) + FUNCTION ABS(WS-MY(WS-TOTAL))
                         + FUNCTION ABS(WS-MZ(WS-TOTAL))) * 1000000 + (WS-MX(WS-TOTAL) + 8) * 10000
                         + (WS-MY(WS-TOTAL) + 8) * 100 + (8 - WS-MZ(WS-TOTAL))
                 END-PERFORM
             END-PERFORM
         END-PERFORM
         PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > WS-TOTAL
             MOVE WS-M(WS-I) TO WS-TMP
             COMPUTE WS-J = WS-I - 1
             PERFORM UNTIL WS-J < 1 OR WS-MK(WS-J) <= WS-TK
                 MOVE WS-M(WS-J) TO WS-M(WS-J + 1)
                 SUBTRACT 1 FROM WS-J
             END-PERFORM
             MOVE WS-TMP TO WS-M(WS-J + 1)
         END-PERFORM
         MOVE 0 TO WS-BAD
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-TOTAL
             COMPUTE WS-INDEX = WS-I - 1
             CALL "F357-MANHATTAN-AT" USING WS-RX WS-RY WS-RZ WS-INDEX WS-DX WS-DY WS-DZ WS-FOUND
             IF WS-FOUND NOT = 1 OR WS-DX NOT = WS-MX(WS-I) OR WS-DY NOT = WS-MY(WS-I) OR WS-DZ NOT = WS-MZ(WS-I)
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
         MOVE SPACES TO WS-CASE
         MOVE WS-RX TO WS-PX
         MOVE WS-RY TO WS-PY
         MOVE WS-RZ TO WS-PZ
         STRING "acceptance US12 35-7§2.3 the box " WS-PX " " WS-PY " " WS-PZ " has the order of the three rules at every index"
             DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-CASE TO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         MOVE WS-BAD TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         COMPUTE TL-EXPECTED-N = (2 * WS-RX + 1) * (2 * WS-RY + 1) * (2 * WS-RZ + 1)
         MOVE WS-TOTAL TO TL-OBSERVED-N
         MOVE "acceptance US12 35-7§2.3 the total is (2 rx + 1)(2 ry + 1)(2 rz + 1)" TO TL-CASE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE WS-TOTAL TO WS-INDEX
         CALL "F357-MANHATTAN-AT" USING WS-RX WS-RY WS-RZ WS-INDEX WS-DX WS-DY WS-DZ WS-FOUND
         MOVE "acceptance US12 35-7§2.3 an index past the last offset yields none" TO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         MOVE WS-FOUND TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   worked: radii (1, 1, 1): offset 0 is the origin; offsets 1 to 6 are the six neighbours, x first (-1,0,0), then (0,-1,0), (0,0,+1), (0,0,-1), (0,+1,0), (+1,0,0)
     MOVE 1 TO WS-RX WS-RY WS-RZ
     MOVE 3 TO WS-INDEX
     CALL "F357-MANHATTAN-AT" USING WS-RX WS-RY WS-RZ WS-INDEX WS-DX WS-DY WS-DZ WS-FOUND
     MOVE "acceptance US12 35-7§2.3 radii 1 1 1: the third offset is (0, 0, +1), the fourth (0, 0, -1)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-DX + 1) * 100 + (WS-DY + 1) * 10 + WS-DZ + 1
     MOVE 112 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-INDEX
     CALL "F357-MANHATTAN-AT" USING WS-RX WS-RY WS-RZ WS-INDEX WS-DX WS-DY WS-DZ WS-FOUND
     COMPUTE TL-OBSERVED-N = (WS-DX + 1) * 100 + (WS-DY + 1) * 10 + WS-DZ + 1
     MOVE 110 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-FEAT-35-7-2.
