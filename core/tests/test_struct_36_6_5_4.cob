*> Acceptance test of the ocean monument layout (docs/protocol/36-structures-6-ocean.md sections 5.1 to 5.5 and the vectors of 6.1, 6.2, 7 facts 8 to 11; core/src/struct-monument.cob; T13501):
*> the complete start of world seed 0, chunk (0, 0) (direction, core, the 28 rooms in order, the wing seed and designs, the penthouse), the boxes of 6.1 for each direction, the 46 cell grid, its 95 + 3
*> links and the rules that hold for every start (the cells of the rooms partition the grid, every room reaches the source through open doors, the draws of the constructor).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-6-5-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTMON.
*> the doc's child list for seed 0 chunk (0, 0): kind (2), definition index (2), main design (1)
 01 WS-LIST.
    05 FILLER PIC X(5) VALUE "01020".
    05 FILLER PIC X(5) VALUE "02130".
    05 FILLER PIC X(5) VALUE "05100".
    05 FILLER PIC X(5) VALUE "05320".
    05 FILLER PIC X(5) VALUE "07000".
    05 FILLER PIC X(5) VALUE "03170".
    05 FILLER PIC X(5) VALUE "05070".
    05 FILLER PIC X(5) VALUE "04410".
    05 FILLER PIC X(5) VALUE "07290".
    05 FILLER PIC X(5) VALUE "03091".
    05 FILLER PIC X(5) VALUE "05510".
    05 FILLER PIC X(5) VALUE "03532".
    05 FILLER PIC X(5) VALUE "04260".
    05 FILLER PIC X(5) VALUE "03372".
    05 FILLER PIC X(5) VALUE "03402".
    05 FILLER PIC X(5) VALUE "03061".
    05 FILLER PIC X(5) VALUE "03120".
    05 FILLER PIC X(5) VALUE "03012".
    05 FILLER PIC X(5) VALUE "03032".
    05 FILLER PIC X(5) VALUE "07250".
    05 FILLER PIC X(5) VALUE "03352".
    05 FILLER PIC X(5) VALUE "05150".
    05 FILLER PIC X(5) VALUE "07310".
    05 FILLER PIC X(5) VALUE "05270".
    05 FILLER PIC X(5) VALUE "05570".
    05 FILLER PIC X(5) VALUE "03422".
    05 FILLER PIC X(5) VALUE "03561".
    05 FILLER PIC X(5) VALUE "03041".
 01 WS-L REDEFINES WS-LIST.
    05 WS-ROW OCCURS 28 TIMES.
       10 WS-R-KIND        PIC 99.
       10 WS-R-INDEX       PIC 99.
       10 WS-R-DESIGN      PIC 9.
 01 WS-RNG                 BINARY-DOUBLE UNSIGNED.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-LINKS               BINARY-LONG.
 01 WS-SCAN                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-Q1                  BINARY-LONG.
 01 WS-Q2                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-CELLS.
    05 WS-MARK             BINARY-LONG OCCURS 75 TIMES.
 01 WS-SEEN.
    05 WS-KIND-SEEN        BINARY-LONG OCCURS 11 TIMES.
 01 WS-BAD-PART            BINARY-LONG VALUE 0.
 01 WS-BAD-REACH           BINARY-LONG VALUE 0.
 01 WS-BAD-ORDER           BINARY-LONG VALUE 0.
 01 WS-BAD-DESIGN          BINARY-LONG VALUE 0.
 01 WS-NINE                BINARY-LONG VALUE 0.
 01 WS-ED                  PIC -(9)9.
 01 WS-EXP-TEXT            PIC X(60).
 01 WS-EXPECT.
    05 WS-EX OCCURS 24 TIMES.
       10 WS-EX-N          BINARY-LONG.
*> 6.1: building-local (9, 0, 22) per direction north, east, south, west, then the boxes of the left wing, right wing and penthouse
 01 WS-V-TABLE.
    05 FILLER PIC X(12) VALUE "-020 039 006".
    05 FILLER PIC X(12) VALUE "-007 039 -20".
    05 FILLER PIC X(12) VALUE "-020 039 -07".
    05 FILLER PIC X(12) VALUE "006 039 -20".
 01 WS-VT REDEFINES WS-V-TABLE.
    05 WS-VROW OCCURS 4 TIMES.
       10 WS-VX            PIC S999 SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 WS-VY            PIC S999 SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   6.2: the start of world seed 0, chunk (0, 0)
     MOVE 0 TO WS-CX WS-CZ
     CALL "MON-START" USING WS-RNG WS-SEED WS-CX WS-CZ
     MOVE "acceptance US12 36-6§5.1 seed 0 chunk (0, 0) draws the direction south" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE MO-DIR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§5.1 the building box is (-29, 39, -29) to (28, 61, 28)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF MO-BX0 NOT = -29 OR MO-BY0 NOT = 39 OR MO-BZ0 NOT = -29 OR MO-BX1 NOT = 28 OR MO-BY1 NOT = 61 OR MO-BZ1 NOT = 28
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§5.3 the core room is at x 3, index 13" TO TL-CASE
     MOVE 13 TO TL-EXPECTED-N
     MOVE MD-INDEX(MO-CORE) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§6.2 the monument has 31 children" TO TL-CASE
     MOVE 31 TO TL-EXPECTED-N
     MOVE MO-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 28
         IF MC-KIND(WS-I) NOT = WS-R-KIND(WS-I) OR MC-INDEX(WS-I) NOT = WS-R-INDEX(WS-I) OR MC-DESIGN(WS-I) NOT = WS-R-DESIGN(WS-I)
             ADD 1 TO WS-BAD
             MOVE WS-I TO WS-ED
             DISPLAY "PROBE child " FUNCTION TRIM(WS-ED) " is " MC-KIND(WS-I) " " MC-INDEX(WS-I) " " MC-DESIGN(WS-I)
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-6§6.2 the 28 rooms come in the order of the doc with their designs" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§6.2 the wing seed is 116690193" TO TL-CASE
     MOVE 116690193 TO TL-EXPECTED-N
     MOVE MO-WING-SEED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§6.2 the left wing has design 1 and index 1001" TO TL-CASE
     MOVE 1001 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = MC-INDEX(29) + MC-DESIGN(29) - 1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§6.2 the right wing has design 0 and index 1002" TO TL-CASE
     MOVE 1002 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = MC-INDEX(30) + MC-DESIGN(30)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§6.2 the last child is the penthouse" TO TL-CASE
     MOVE 1003 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = MC-INDEX(31) + MC-KIND(31) - 11
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   6.1: the boxes for dir south at chunk (0, 0)
     MOVE "acceptance US12 36-6§6.1 south: the entry room box is (-4, 39, -7) to (3, 42, 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF MC-X0(1) NOT = -4 OR MC-Y0(1) NOT = 39 OR MC-Z0(1) NOT = -7 OR MC-X1(1) NOT = 3 OR MC-Y1(1) NOT = 42 OR MC-Z1(1) NOT = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§6.1 south: the core box is (4, 39, 9) to (19, 46, 24)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF MC-X0(2) NOT = 4 OR MC-Y0(2) NOT = 39 OR MC-Z0(2) NOT = 9 OR MC-X1(2) NOT = 19 OR MC-Y1(2) NOT = 46 OR MC-Z1(2) NOT = 24
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§6.1 south: the double X room 10 box is (-20, 39, 9) to (-5, 42, 16)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF MC-X0(3) NOT = -20 OR MC-Y0(3) NOT = 39 OR MC-Z0(3) NOT = 9 OR MC-X1(3) NOT = -5 OR MC-Y1(3) NOT = 42 OR MC-Z1(3) NOT = 16
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§6.1 south: the left wing is (-28, 40, -28) to (-6, 47, -8)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF MC-X0(29) NOT = -28 OR MC-Y0(29) NOT = 40 OR MC-Z0(29) NOT = -28 OR MC-X1(29) NOT = -6 OR MC-Y1(29) NOT = 47 OR MC-Z1(29) NOT = -8
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§6.1 south: the right wing is (5, 40, -28) to (27, 47, -8)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF MC-X0(30) NOT = 5 OR MC-Y0(30) NOT = 40 OR MC-Z0(30) NOT = -28 OR MC-X1(30) NOT = 27 OR MC-Y1(30) NOT = 47 OR MC-Z1(30) NOT = -8
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§6.1 the penthouse is (-7, 52, -7) to (6, 56, 6)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF MC-X0(31) NOT = -7 OR MC-Y0(31) NOT = 52 OR MC-Z0(31) NOT = -7 OR MC-X1(31) NOT = 6 OR MC-Y1(31) NOT = 56 OR MC-Z1(31) NOT = 6
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   6.1 for the other directions: the same start with the direction forced
     PERFORM VARYING WS-DIR FROM 0 BY 1 UNTIL WS-DIR > 3
         MOVE -29 TO WS-X0
         MOVE -29 TO WS-Z0
         MOVE 4 TO WS-NINE
         CALL "JRAND-LARGE-FEATURE-SEED" USING WS-RNG WS-SEED WS-CX WS-CZ
         CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-NINE WS-K
         CALL "MON-LAYOUT" USING WS-RNG WS-DIR WS-X0 WS-Z0
         MOVE MO-VX TO WS-EX-N(1)
         MOVE MO-VZ TO WS-EX-N(2)
         EVALUATE WS-DIR
             WHEN 0
                 MOVE -20 TO WS-EX-N(3)
                 MOVE 6 TO WS-EX-N(4)
                 MOVE -28 TO WS-EX-N(5)
                 MOVE 7 TO WS-EX-N(6)
                 MOVE -6 TO WS-EX-N(7)
                 MOVE 27 TO WS-EX-N(8)
                 MOVE 5 TO WS-EX-N(9)
                 MOVE 7 TO WS-EX-N(10)
                 MOVE 27 TO WS-EX-N(11)
                 MOVE 27 TO WS-EX-N(12)
             WHEN 1
                 MOVE -7 TO WS-EX-N(3)
                 MOVE -20 TO WS-EX-N(4)
                 MOVE -28 TO WS-EX-N(5)
                 MOVE -28 TO WS-EX-N(6)
                 MOVE -8 TO WS-EX-N(7)
                 MOVE -6 TO WS-EX-N(8)
                 MOVE -28 TO WS-EX-N(9)
                 MOVE 5 TO WS-EX-N(10)
                 MOVE -8 TO WS-EX-N(11)
                 MOVE 27 TO WS-EX-N(12)
             WHEN 2
                 MOVE -20 TO WS-EX-N(3)
                 MOVE -7 TO WS-EX-N(4)
                 MOVE -28 TO WS-EX-N(5)
                 MOVE -28 TO WS-EX-N(6)
                 MOVE -6 TO WS-EX-N(7)
                 MOVE -8 TO WS-EX-N(8)
                 MOVE 5 TO WS-EX-N(9)
                 MOVE -28 TO WS-EX-N(10)
                 MOVE 27 TO WS-EX-N(11)
                 MOVE -8 TO WS-EX-N(12)
             WHEN OTHER
                 MOVE 6 TO WS-EX-N(3)
                 MOVE -20 TO WS-EX-N(4)
                 MOVE 7 TO WS-EX-N(5)
                 MOVE -28 TO WS-EX-N(6)
                 MOVE 27 TO WS-EX-N(7)
                 MOVE -6 TO WS-EX-N(8)
                 MOVE 7 TO WS-EX-N(9)
                 MOVE 5 TO WS-EX-N(10)
                 MOVE 27 TO WS-EX-N(11)
                 MOVE 27 TO WS-EX-N(12)
         END-EVALUATE
         MOVE 0 TO WS-BAD
         IF MO-VX NOT = WS-EX-N(3) OR MO-VZ NOT = WS-EX-N(4)
             ADD 1 TO WS-BAD
         END-IF
         IF MC-X0(29) NOT = WS-EX-N(5) OR MC-Z0(29) NOT = WS-EX-N(6) OR MC-X1(29) NOT = WS-EX-N(7) OR MC-Z1(29) NOT = WS-EX-N(8)
             ADD 1 TO WS-BAD
         END-IF
         IF MC-X0(30) NOT = WS-EX-N(9) OR MC-Z0(30) NOT = WS-EX-N(10) OR MC-X1(30) NOT = WS-EX-N(11) OR MC-Z1(30) NOT = WS-EX-N(12)
             ADD 1 TO WS-BAD
         END-IF
         IF MC-X0(31) NOT = -7 OR MC-Z0(31) NOT = -7 OR MC-X1(31) NOT = 6 OR MC-Z1(31) NOT = 6 OR MC-Y0(29) NOT = 40 OR MC-Y1(31) NOT = 56
             ADD 1 TO WS-BAD
         END-IF
         MOVE WS-DIR TO WS-ED
         STRING "acceptance US12 36-6§6.1 direction " FUNCTION TRIM(WS-ED) " grid origin, wings and penthouse" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         MOVE WS-BAD TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   5.2 and 5.3: the grid has 46 rooms and 95 + 3 links
     MOVE 0 TO WS-N
     MOVE 0 TO WS-LINKS
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 78
         IF MD-INDEX(WS-SLOT) >= 0
             ADD 1 TO WS-N
         END-IF
         PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 6
             IF MD-CONN(WS-SLOT, WS-D) > 0
                 ADD 1 TO WS-LINKS
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-6§5.2 46 grid rooms and three special definitions" TO TL-CASE
     MOVE 49 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§5.3 98 links, counted from both ends" TO TL-CASE
     MOVE 196 TO TL-EXPECTED-N
     MOVE WS-LINKS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§5.3 the z slots are mirrored: the slot north of room 0 is room 5" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE MD-CONN(1, 3) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   every start: the rooms partition the grid, every room reaches the source, the kinds that occur, the order of the list
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 11
         MOVE 0 TO WS-KIND-SEEN(WS-K)
     END-PERFORM
     MOVE 1000 TO WS-SCAN
     PERFORM VARYING WS-CX FROM -10 BY 1 UNTIL WS-CX > 29
         PERFORM VARYING WS-CZ FROM 0 BY 1 UNTIL WS-CZ > 9
             CALL "MON-START" USING WS-RNG WS-SEED WS-CX WS-CZ
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 75
                 MOVE 0 TO WS-MARK(WS-K)
             END-PERFORM
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MO-COUNT
                 ADD 1 TO WS-KIND-SEEN(MC-KIND(WS-I))
                 MOVE 1 TO WS-W
                 MOVE 1 TO WS-H
                 MOVE 1 TO WS-D
                 EVALUATE MC-KIND(WS-I)
                     WHEN 2
                         MOVE 2 TO WS-W WS-H WS-D
                     WHEN 5
                         MOVE 2 TO WS-W
                     WHEN 6
                         MOVE 2 TO WS-H
                     WHEN 7
                         MOVE 2 TO WS-D
                     WHEN 8
                         MOVE 2 TO WS-W WS-H
                     WHEN 9
                         MOVE 2 TO WS-H WS-D
                 END-EVALUATE
                 IF MC-KIND(WS-I) <= 9
                     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= WS-W * WS-H * WS-D
                         COMPUTE WS-Q1 = WS-J / WS-W
                         COMPUTE WS-Q2 = WS-J / (WS-W * WS-D)
                         COMPUTE WS-CELL = MC-INDEX(WS-I) + FUNCTION MOD(WS-J, WS-W) + 5 * FUNCTION MOD(WS-Q1, WS-D) + 25 * WS-Q2
                         ADD 1 TO WS-MARK(WS-CELL + 1)
                     END-PERFORM
                 END-IF
                 IF MC-KIND(WS-I) = 3 AND MC-DESIGN(WS-I) > 2
                     ADD 1 TO WS-BAD-DESIGN
                 END-IF
             END-PERFORM
             MOVE 0 TO WS-N
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 75
                 IF MD-INDEX(WS-K) >= 0 AND WS-MARK(WS-K) NOT = 1
                     ADD 1 TO WS-BAD-PART
                 END-IF
                 IF MD-INDEX(WS-K) < 0 AND WS-MARK(WS-K) NOT = 0
                     ADD 1 TO WS-BAD-PART
                 END-IF
             END-PERFORM
             PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 75
                 IF MD-INDEX(WS-SLOT) >= 0
                     ADD 1 TO WS-SCAN
                     CALL "MON-FIND" USING WS-SLOT WS-SCAN WS-FOUND
                     IF WS-FOUND NOT = 1
                         ADD 1 TO WS-BAD-REACH
                     END-IF
                 END-IF
             END-PERFORM
             IF MC-KIND(1) NOT = 1 OR MC-KIND(2) NOT = 2 OR MC-KIND(MO-COUNT) NOT = 11 OR MC-KIND(MO-COUNT - 1) NOT = 10
                 ADD 1 TO WS-BAD-ORDER
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-6§5.4 the cells of the rooms partition the 46 grid cells in 400 starts" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-PART TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§5.3 every room reaches the source through open doors in 400 starts" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-REACH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§5.4 entry, core first and wings, penthouse last in 400 starts" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-ORDER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-6§5.4 a simple room's design is 0, 1 or 2" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-DESIGN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 11
         IF WS-KIND-SEEN(WS-K) = 0
             MOVE WS-K TO WS-ED
             DISPLAY "PROBE kind never seen: " FUNCTION TRIM(WS-ED)
         END-IF
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-6-5-4.
