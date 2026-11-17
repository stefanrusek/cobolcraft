*> Test of the shared facts of the water and surface features (docs/protocol/35-worldgen-features-5-water-and-surface.md section 1; core/src/feat-35-5.cob; T1216): the block-write flags (1.1),
*> betweenClosed order, the Manhattan box, Util.shuffle, WeightedList.getRandom and the trapezoid int provider with their draws (1.2).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-5-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-X0                  BINARY-LONG VALUE 0.
 01 WS-Y0                  BINARY-LONG VALUE 0.
 01 WS-Z0                  BINARY-LONG VALUE 0.
 01 WS-X1                  BINARY-LONG VALUE 1.
 01 WS-Y1                  BINARY-LONG VALUE 2.
 01 WS-Z1                  BINARY-LONG VALUE 3.
 01 WS-KIND                BINARY-LONG.
 01 WS-VALUE               BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RY                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-S1                  BINARY-DOUBLE UNSIGNED.
 01 WS-S2                  BINARY-DOUBLE UNSIGNED.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 12345.
 01 WS-TABLE.
    05 WS-T                BINARY-LONG OCCURS 8 TIMES.
 01 WS-MODEL.
    05 WS-M                BINARY-LONG OCCURS 8 TIMES.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-HOLD                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-BIT                 BINARY-LONG VALUE 31.
 01 WS-R                   BINARY-DOUBLE.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 1 TO WS-KIND
     CALL "F355-FLAG" USING WS-KIND WS-VALUE
     MOVE "acceptance US12 35-5§1.1 setBlock(pos, state, 2) writes with flag 2 (UPDATE_CLIENTS)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-KIND
     CALL "F355-FLAG" USING WS-KIND WS-VALUE
     MOVE "acceptance US12 35-5§1.1 Feature.setBlock is setBlockAndUpdate: flag 3 (UPDATE_ALL)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-KIND
     CALL "F355-FLAG" USING WS-KIND WS-VALUE
     MOVE "acceptance US12 35-5§1.1 the block piles' flag 260 is UPDATE_INVISIBLE (4) plus SKIP_BLOCK_ENTITY_SIDEEFFECTS (256)" TO TL-CASE
     MOVE 260 TO TL-EXPECTED-N
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   betweenClosed: x fastest, then y, z slowest, both ends inclusive
     MOVE 0 TO WS-INDEX
     CALL "F355-BETWEEN" USING WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-INDEX WS-X WS-Y WS-Z
     MOVE "acceptance US12 35-5§1.2 betweenClosed starts at the minimum corner" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-X * 100 + WS-Y * 10 + WS-Z
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-INDEX
     CALL "F355-BETWEEN" USING WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-INDEX WS-X WS-Y WS-Z
     MOVE "acceptance US12 35-5§1.2 betweenClosed varies x fastest" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-X * 100 + WS-Y * 10 + WS-Z
     MOVE 100 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-INDEX
     CALL "F355-BETWEEN" USING WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-INDEX WS-X WS-Y WS-Z
     MOVE "acceptance US12 35-5§1.2 betweenClosed then y" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-X * 100 + WS-Y * 10 + WS-Z
     MOVE 10 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-INDEX
     CALL "F355-BETWEEN" USING WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-INDEX WS-X WS-Y WS-Z
     MOVE "acceptance US12 35-5§1.2 betweenClosed z slowest" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-X * 100 + WS-Y * 10 + WS-Z
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 23 TO WS-INDEX
     CALL "F355-BETWEEN" USING WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-INDEX WS-X WS-Y WS-Z
     MOVE "acceptance US12 35-5§1.2 betweenClosed ends at the maximum corner (both ends inclusive, 24 cells)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-X * 100 + WS-Y * 10 + WS-Z
     MOVE 123 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   corners given in any order: the minimum and maximum are taken per axis
     MOVE 23 TO WS-INDEX
     CALL "F355-BETWEEN" USING WS-X1 WS-Y1 WS-Z1 WS-X0 WS-Y0 WS-Z0 WS-INDEX WS-X WS-Y WS-Z
     MOVE "acceptance US12 35-5§1.2 betweenClosed takes the minimum and maximum per axis" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-X * 100 + WS-Y * 10 + WS-Z
     MOVE 123 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the Manhattan box
     MOVE 2 TO WS-RX
     MOVE 1 TO WS-RY
     MOVE 0 TO WS-RZ
     MOVE 2 TO WS-DX
     MOVE 1 TO WS-DY
     MOVE 0 TO WS-DZ
     CALL "F355-MANHATTAN-IN" USING WS-DX WS-DY WS-DZ WS-RX WS-RY WS-RZ WS-FLAG
     MOVE "acceptance US12 35-5§1.2 withinBoxByManhattanDistance holds the corner (2, 1, 0) of the box 2, 1, 0" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-DZ
     CALL "F355-MANHATTAN-IN" USING WS-DX WS-DY WS-DZ WS-RX WS-RY WS-RZ WS-FLAG
     MOVE "acceptance US12 35-5§1.2 withinBoxByManhattanDistance refuses an offset beyond one radius" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-DZ
     MOVE -2 TO WS-DX
     CALL "F355-MANHATTAN-IN" USING WS-DX WS-DY WS-DZ WS-RX WS-RY WS-RZ WS-FLAG
     MOVE "acceptance US12 35-5§1.2 withinBoxByManhattanDistance is symmetric in the sign of an offset" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Util.shuffle: size - 1 draws, from the end
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE WS-I TO WS-T(WS-I)
         MOVE WS-I TO WS-M(WS-I)
     END-PERFORM
     MOVE 5 TO WS-N
     CALL "JRAND-SET-SEED" USING WS-S1 WS-SEED
     CALL "JRAND-SET-SEED" USING WS-S2 WS-SEED
     CALL "F355-SHUFFLE" USING WS-TABLE WS-N WS-S1
     PERFORM VARYING WS-I FROM 5 BY -1 UNTIL WS-I < 2
         CALL "JRAND-NEXT-INT-BOUND" USING WS-S2 WS-I WS-DRAW
         COMPUTE WS-J = WS-DRAW + 1
         MOVE WS-M(WS-I) TO WS-HOLD
         MOVE WS-M(WS-J) TO WS-M(WS-I)
         MOVE WS-HOLD TO WS-M(WS-J)
     END-PERFORM
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         IF WS-T(WS-I) NOT = WS-M(WS-I)
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 35-5§1.2 Util.shuffle swaps element i - 1 with nextInt(i) for i = size down to 2" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 35-5§1.2 Util.shuffle makes exactly size - 1 draws" TO TL-CASE
     MOVE WS-S2 TO TL-EXPECTED-N
     MOVE WS-S1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-N
     CALL "JRAND-SET-SEED" USING WS-S1 WS-SEED
     CALL "JRAND-SET-SEED" USING WS-S2 WS-SEED
     CALL "F355-SHUFFLE" USING WS-TABLE WS-N WS-S1
     MOVE "acceptance US12 35-5§1.2 a list of one element is shuffled without a draw" TO TL-CASE
     MOVE WS-S2 TO TL-EXPECTED-N
     MOVE WS-S1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   WeightedList.getRandom: nextInt(total), the entry where the running value first becomes negative
     MOVE 3 TO WS-T(1)
     MOVE 1 TO WS-T(2)
     MOVE 2 TO WS-T(3)
     MOVE 3 TO WS-N
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         COMPUTE WS-SEED = 1000 + WS-I
         CALL "JRAND-SET-SEED" USING WS-S1 WS-SEED
         CALL "JRAND-SET-SEED" USING WS-S2 WS-SEED
         MOVE 6 TO WS-TOTAL
         CALL "JRAND-NEXT-INT-BOUND" USING WS-S2 WS-TOTAL WS-DRAW
         EVALUATE TRUE
             WHEN WS-DRAW < 3
                 MOVE 1 TO WS-J
             WHEN WS-DRAW < 4
                 MOVE 2 TO WS-J
             WHEN OTHER
                 MOVE 3 TO WS-J
         END-EVALUATE
         CALL "F355-WEIGHTED" USING WS-TABLE WS-N WS-S1 WS-INDEX
         IF WS-INDEX NOT = WS-J OR WS-S1 NOT = WS-S2
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 35-5§1.2 WeightedList.getRandom walks the weights 3, 1, 2 for 40 seeds" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-T(1) WS-T(2) WS-T(3)
     CALL "JRAND-SET-SEED" USING WS-S1 WS-SEED
     MOVE WS-S1 TO WS-S2
     CALL "F355-WEIGHTED" USING WS-TABLE WS-N WS-S1 WS-INDEX
     MOVE "acceptance US12 35-5§1.2 a weighted list of total weight 0 gives no choice and no draw" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     IF WS-INDEX = 0 AND WS-S1 = WS-S2
         MOVE 0 TO TL-OBSERVED-N
     ELSE
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   trapezoid(0, 0): two nextInt(1) draws, each one next(31) step, the value 0
     CALL "JRAND-SET-SEED" USING WS-S1 WS-SEED
     MOVE WS-S1 TO WS-S2
     MOVE 0 TO WS-MAX
     CALL "F355-TRAPEZOID" USING WS-MAX WS-S1 WS-VALUE
     CALL "JRAND-NEXT" USING WS-S2 WS-BIT WS-R
     CALL "JRAND-NEXT" USING WS-S2 WS-BIT WS-R
     MOVE "acceptance US12 35-5§1.2 trapezoid(0, 0, 0) is 0 and consumes two next(31) steps" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     IF WS-VALUE = 0 AND WS-S1 = WS-S2
         MOVE 0 TO TL-OBSERVED-N
     ELSE
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-MAX
     CALL "JRAND-SET-SEED" USING WS-S1 WS-SEED
     MOVE WS-S1 TO WS-S2
     CALL "F355-TRAPEZOID" USING WS-MAX WS-S1 WS-VALUE
     COMPUTE WS-N = WS-MAX + 1
     CALL "JRAND-NEXT-INT-BOUND" USING WS-S2 WS-N WS-DRAW
     CALL "JRAND-NEXT-INT-BOUND" USING WS-S2 WS-N WS-J
     MOVE "acceptance US12 35-5§1.2 trapezoid(-3, 3, 0) is nextInt(4) - nextInt(4), first draw first" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-DRAW - WS-J
     MOVE WS-VALUE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-FEAT-35-5-1.
