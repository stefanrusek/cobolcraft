*> Test of the stronghold assembly (docs/protocol/36-structures-5-mineshaft-stronghold.md sections 3.2 to 3.6, 4.3, 5 items 6 to 8; core/src/struct-stronghold.cob; T10001): the piece table (11 entries,
*> total 145, the quotas of the limited entries), the start piece (an EAST start of chunk (1, 0) at seed 0 is the box (18,64,2)..(22,74,6), 4.3), its imposed first child (the five crossing
*> (23,62,-1)..(33,70,8) with the four draws, 4.3), and whole strongholds over a grid of chunks: a portal room, the counts of the limited classes, every box above y 10 before the vertical
*> shift, no overlap between pieces other than the filler corridors, the depth bound, the reach of 112 blocks, and the same layout for the same seed.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-STRONGHOLD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTPIECE.
 COPY STRUCTSH.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-SEED                BINARY-DOUBLE VALUE 0.
 01 WS-ANY                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG VALUE 29.
 01 WS-DIR                 BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-FLAG                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-COUNTS.
    05 WS-N                BINARY-LONG OCCURS 40 TIMES.
 01 WS-TEXT                PIC X(60).
 01 WS-ED1                 PIC -(9)9.
 01 WS-ED2                 PIC -(9)9.
 01 WS-SUM1                BINARY-DOUBLE.
 01 WS-SUM2                BINARY-DOUBLE.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-FIVE-D              BINARY-LONG VALUE 5.
 01 WS-ELEVEN              BINARY-LONG VALUE 11.
 01 WS-CLASS               BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   the table (3.3)
     CALL "SH-RESET"
     CALL "SH-UPDATE-WEIGHT" USING WS-ANY
     MOVE "acceptance US12 36-5§3.3 the full table weighs 145 and has limited entries" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1450 + 1
     COMPUTE TL-OBSERVED-N = SH-TOTAL * 10 + WS-ANY
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-5§3.3 the weights in table order sum 40 5 20 20 10 5 5 5 5 10 20" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO WS-SUM1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         COMPUTE WS-SUM1 = WS-SUM1 * 3 + SH-W(WS-I) + SH-MAX(WS-I)
     END-PERFORM
     MOVE 0 TO WS-SUM2
     MOVE 0 TO WS-J
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         EVALUATE WS-I
             WHEN 1 MOVE 40 TO WS-DRAW MOVE 0 TO WS-BOUND
             WHEN 2 MOVE 5 TO WS-DRAW MOVE 5 TO WS-BOUND
             WHEN 3 MOVE 20 TO WS-DRAW MOVE 0 TO WS-BOUND
             WHEN 4 MOVE 20 TO WS-DRAW MOVE 0 TO WS-BOUND
             WHEN 5 MOVE 10 TO WS-DRAW MOVE 6 TO WS-BOUND
             WHEN 6 MOVE 5 TO WS-DRAW MOVE 5 TO WS-BOUND
             WHEN 7 MOVE 5 TO WS-DRAW MOVE 5 TO WS-BOUND
             WHEN 8 MOVE 5 TO WS-DRAW MOVE 4 TO WS-BOUND
             WHEN 9 MOVE 5 TO WS-DRAW MOVE 4 TO WS-BOUND
             WHEN 10 MOVE 10 TO WS-DRAW MOVE 2 TO WS-BOUND
             WHEN OTHER MOVE 20 TO WS-DRAW MOVE 1 TO WS-BOUND
         END-EVALUATE
         COMPUTE WS-SUM2 = WS-SUM2 * 3 + WS-DRAW + WS-BOUND
     END-PERFORM
     MOVE WS-SUM1 TO TL-OBSERVED-N
     MOVE WS-SUM2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a limited entry whose quota is used up leaves currentPieces; with every limited entry used up nothing is left to place
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         IF SH-MAX(WS-I) > 0
             MOVE SH-MAX(WS-I) TO SH-CNT(WS-I)
         END-IF
     END-PERFORM
     CALL "SH-UPDATE-WEIGHT" USING WS-ANY
     MOVE "acceptance US12 36-5§3.4 with every quota used up updatePieceWeight is false" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ANY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the start of chunk (1, 0) at seed 0 (4.2, 4.3): setLargeFeatureSeed, nextInt(4) = 1 is EAST
     CALL "SH-RESET"
     CALL "SPB-RESET"
     MOVE 1 TO WS-CX
     MOVE 0 TO WS-CZ
     CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED WS-CX WS-CZ
     MOVE 4 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
     MOVE "acceptance US12 36-5§4.3 the first nextInt(4) of chunk (1,0) at seed 0 is 1 (EAST)" TO TL-CASE
     MOVE WS-DRAW TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-DIR
     MOVE 18 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 2 TO WS-Z
     CALL "SPB-MAKE-BOX" USING WS-X WS-Y WS-Z WS-DIR WS-FIVE WS-ELEVEN WS-FIVE-D WS-BOX
     CALL "SPB-ADD" USING WS-TYPE WS-DIR WS-NONE BY CONTENT WS-NONE BY REFERENCE WS-BOX WS-ROW
     MOVE 1 TO SP-F2(WS-ROW)
     MOVE WS-ROW TO SH-START
     MOVE "acceptance US12 36-5§4.3 an EAST start is the box (18,64,2)..(22,74,6)" TO TL-CASE
     MOVE "18 64 2 22 74 6" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     PERFORM FORMAT-BOX
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     CALL "SH-CHILDREN" USING WS-ROW
     MOVE "acceptance US12 36-5§3.6 the start imposes the five crossing: two pieces in the list and one pending" TO TL-CASE
     MOVE 21 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SP-COUNT * 10 + SH-PEND-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "T" TO TL-MODE
     MOVE "the first child is a five crossing (sh5c, 21) in the box (23,62,-1)..(33,70,8)" TO TL-CASE
     MOVE "21 23 62 -1 33 70 8" TO TL-EXPECTED
     MOVE 2 TO WS-ROW
     PERFORM FORMAT-CHILD
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 36-5§3.6 the imposed class is cleared and the child has depth 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SP-DEPTH(2) + SH-IMPOSED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   whole strongholds over a grid of chunks
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 5
         COMPUTE WS-CX = WS-I * 37 - 90
         COMPUTE WS-CZ = 60 - WS-I * 29
         COMPUTE WS-SEED = WS-I * 7919 - 20000
         CALL "SH-FIND-POINT" USING WS-SEED WS-CX WS-CZ WS-SEA WS-MIN-Y WS-X WS-Y WS-Z WS-VALID
         IF WS-VALID NOT = 1
             ADD 1 TO WS-BAD
         END-IF
         PERFORM CHECK-STRONGHOLD
     END-PERFORM
     MOVE "acceptance US12 36-5§5.6-7 six strongholds: portal room, counts, boxes, overlaps, depth and reach hold" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the same seed and chunk give the same layout (the vertical shift included)
     COMPUTE WS-SEED = 1 * 7919 - 20000
     COMPUTE WS-CX = 1 * 37 - 90
     COMPUTE WS-CZ = 60 - 1 * 29
     CALL "SH-FIND-POINT" USING WS-SEED WS-CX WS-CZ WS-SEA WS-MIN-Y WS-X WS-Y WS-Z WS-VALID
     MOVE SP-COUNT TO WS-I
     MOVE 0 TO WS-SUM1
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > SP-COUNT
         COMPUTE WS-SUM1 = FUNCTION MOD(WS-SUM1 * 31 + SP-X0(WS-J) * 7 + SP-Y0(WS-J) * 3 + SP-Z0(WS-J) + SP-TYPE(WS-J), 1000000007)
     END-PERFORM
     CALL "SH-FIND-POINT" USING WS-SEED WS-CX WS-CZ WS-SEA WS-MIN-Y WS-X WS-Y WS-Z WS-VALID
     MOVE 0 TO WS-SUM2
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > SP-COUNT
         COMPUTE WS-SUM2 = FUNCTION MOD(WS-SUM2 * 31 + SP-X0(WS-J) * 7 + SP-Y0(WS-J) * 3 + SP-Z0(WS-J) + SP-TYPE(WS-J), 1000000007)
     END-PERFORM
     MOVE "acceptance US12 36-5§3.2 the layout is a function of the seed and the chunk" TO TL-CASE
     MOVE WS-SUM1 TO TL-EXPECTED-N
     MOVE WS-SUM2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-5§3.2 the stub of a stronghold is the chunk's min corner at y 0" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-CX * 16 * 1000 + WS-CZ * 16 + 0
     COMPUTE TL-OBSERVED-N = WS-X * 1000 + WS-Z + WS-Y
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 FORMAT-BOX.
     MOVE 1 TO WS-J
     MOVE SPACES TO WS-TEXT
     PERFORM FORMAT-COORDS
     MOVE WS-TEXT TO TL-OBSERVED.

 FORMAT-COORDS.
     MOVE SP-X0(WS-ROW) TO WS-ED1
     STRING FUNCTION TRIM(WS-ED1) " " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-J
     MOVE SP-Y0(WS-ROW) TO WS-ED1
     STRING FUNCTION TRIM(WS-ED1) " " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-J
     MOVE SP-Z0(WS-ROW) TO WS-ED1
     STRING FUNCTION TRIM(WS-ED1) " " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-J
     MOVE SP-X1(WS-ROW) TO WS-ED1
     STRING FUNCTION TRIM(WS-ED1) " " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-J
     MOVE SP-Y1(WS-ROW) TO WS-ED1
     STRING FUNCTION TRIM(WS-ED1) " " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-J
     MOVE SP-Z1(WS-ROW) TO WS-ED1
     STRING FUNCTION TRIM(WS-ED1) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-J.

 FORMAT-CHILD.
     MOVE 1 TO WS-J
     MOVE SPACES TO WS-TEXT
     MOVE SP-TYPE(WS-ROW) TO WS-ED1
     STRING FUNCTION TRIM(WS-ED1) " " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-J
     PERFORM FORMAT-COORDS
     MOVE WS-TEXT TO TL-OBSERVED.

 CHECK-STRONGHOLD.
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 40
         MOVE 0 TO WS-N(WS-J)
     END-PERFORM
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > SP-COUNT
         ADD 1 TO WS-N(SP-TYPE(WS-J))
         IF SP-DEPTH(WS-J) > 51
             ADD 1 TO WS-BAD
         END-IF
         IF SP-TYPE(WS-J) NOT = 20
             PERFORM VARYING WS-CLASS FROM 1 BY 1 UNTIL WS-CLASS >= WS-J
                 IF SP-TYPE(WS-CLASS) NOT = 20
                     CALL "SPB-BOX-INTERSECTS" USING SP-BOX(WS-J) BY CONTENT SP-BOX(WS-CLASS) BY REFERENCE WS-FLAG
                     IF WS-FLAG = 1
                         ADD 1 TO WS-BAD
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
         IF FUNCTION ABS(SP-X0(WS-J) - SP-X0(1)) > 112 + 12 OR FUNCTION ABS(SP-Z0(WS-J) - SP-Z0(1)) > 112 + 12
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
*>   25 prison hall, 31 straight stairs down, 28 stairs down (the start is 29), 27 room crossing, 21 and 19, 23, 24
     IF WS-N(25) > 5 OR WS-N(31) > 5 OR WS-N(28) > 5 OR WS-N(27) > 6 OR WS-N(21) > 5 OR WS-N(19) > 4 OR WS-N(23) > 2 OR WS-N(24) NOT = 1 OR WS-N(29) NOT = 1
         ADD 1 TO WS-BAD
     END-IF.
 END PROGRAM TEST-STRUCT-STRONGHOLD.
