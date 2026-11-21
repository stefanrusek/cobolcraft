*> Acceptance test of docs/protocol/36-structures-5-mineshaft-stronghold.md section 3.8 (child coordinates of the five-way crossing, T1522) and the FiveCrossing child rule of 3.7: with all four
*> flags set the children are requested in the order Forward(5,1), Left(a,1), Left(b,7), Right(a,1), Right(b,7) with a = 3, b = 5 (a = 5, b = 3 for WEST and NORTH pieces), at the helper positions of
*> 3.5 (Left and Right: a is the height offset, b the offset along the depth axis from the box's minimum corner in world terms). The note's consequence is reproduced: for a NORTH piece the child
*> for leftLow is requested at (minX - 1, minY + 5, minZ + 1) (the high opening's place), while the opening carved for leftLow is at world z minZ + 7 .. minZ + 9.
*> Each requested anchor is checked on the entry face of the child that was made (the anchor of an orientBox lies on the face the piece is entered from) and the child's direction is the one requested.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-5-3-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTPIECE.
 COPY STRUCTSH.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-TYPE                BINARY-LONG VALUE 21.
 01 WS-DIR                 BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG VALUE 1.
 01 WS-MST                 BINARY-LONG VALUE 1.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-K1                  BINARY-LONG VALUE 1.
 01 WS-CHILD               BINARY-LONG.
 01 WS-GOOD                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-CASE                BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-EXP.
    05 WS-E OCCURS 5 TIMES.
       10 WS-EX            BINARY-LONG.
       10 WS-EY            BINARY-LONG.
       10 WS-EZ            BINARY-LONG.
       10 WS-ED            BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 100 TO WS-X0
     MOVE 62 TO WS-Y0
     MOVE 200 TO WS-Z0
     MOVE 109 TO WS-X1
     MOVE 210 TO WS-Z1
     PERFORM VARYING WS-CASE FROM 1 BY 1 UNTIL WS-CASE > 4
         EVALUATE WS-CASE
             WHEN 1
                 MOVE 2 TO WS-DIR
             WHEN 2
                 MOVE 0 TO WS-DIR
             WHEN 3
                 MOVE 1 TO WS-DIR
             WHEN OTHER
                 MOVE 3 TO WS-DIR
         END-EVALUATE
*>       the box of the crossing: 10 x 9 x 11 for north and south, 11 x 9 x 10 for east and west
         IF WS-DIR = 0 OR WS-DIR = 2
             MOVE 109 TO WS-X1
             MOVE 210 TO WS-Z1
         ELSE
             MOVE 110 TO WS-X1
             MOVE 209 TO WS-Z1
         END-IF
         PERFORM CALC-EXPECTED
         MOVE 0 TO WS-GOOD
         PERFORM VARYING WS-SEED FROM 1 BY 1 UNTIL WS-SEED > 60 OR WS-GOOD = 1
             CALL "SH-RESET"
             CALL "SPB-RESET"
             MOVE WS-X0 TO B-X0
             MOVE WS-Y0 TO B-Y0
             MOVE WS-Z0 TO B-Z0
             MOVE WS-X1 TO B-X1
             COMPUTE B-Y1 = WS-Y0 + 8
             MOVE WS-Z1 TO B-Z1
             CALL "SPB-ADD" USING WS-TYPE WS-DIR WS-DEPTH WS-MST WS-BOX WS-ROW
             MOVE 1 TO SP-F2(WS-ROW) SP-F3(WS-ROW) SP-F4(WS-ROW) SP-MST(WS-ROW)
             MOVE WS-ROW TO SH-START
             MOVE WS-SEED TO WS-STATE
             CALL "JRAND-SET-SEED" USING SP-RNG WS-STATE
             CALL "SH-CHILDREN" USING WS-ROW
             IF SH-PEND-N = 5
                 MOVE 1 TO WS-GOOD
                 PERFORM CHECK-CHILDREN
             END-IF
         END-PERFORM
         MOVE "N" TO TL-MODE
         EVALUATE WS-CASE
             WHEN 1
                 MOVE "acceptance US12 36-5§3.8 Child coordinates: NORTH five crossing: five children at Forward(5,1), Left(5,1), Left(3,7), Right(5,1), Right(3,7) of 3.5 (a seed with all five made)" TO TL-CASE
             WHEN 2
                 MOVE "acceptance US12 36-5§3.8 Child coordinates: SOUTH five crossing (a = 3, b = 5): the same five children" TO TL-CASE
             WHEN 3
                 MOVE "acceptance US12 36-5§3.8 Child coordinates: WEST five crossing (a = 5, b = 3): the same five children" TO TL-CASE
             WHEN OTHER
                 MOVE "acceptance US12 36-5§3.8 Child coordinates: EAST five crossing (a = 3, b = 5): the same five children" TO TL-CASE
         END-EVALUATE
         IF WS-GOOD = 0
             MOVE 99 TO TL-OBSERVED-N
         ELSE
             MOVE WS-BAD TO TL-OBSERVED-N
         END-IF
         MOVE 0 TO TL-EXPECTED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   the note: NORTH, leftLow's child is at (minX - 1, minY + 5, minZ + 1) WEST; the opening carved for leftLow (0,3,1 .. 0,5,3) of local z is world z maxZ - 3 .. maxZ - 1 of a NORTH piece
     MOVE 2 TO WS-DIR
     CALL "SPB-RESET"
     MOVE 100 TO B-X0
     MOVE 62 TO B-Y0
     MOVE 200 TO B-Z0
     MOVE 109 TO B-X1
     MOVE 70 TO B-Y1
     MOVE 210 TO B-Z1
     CALL "SPB-ADD" USING WS-TYPE WS-DIR WS-DEPTH WS-MST WS-BOX WS-ROW
     MOVE 1 TO WS-A
     MOVE 1 TO WS-K
     CALL "SPB-WORLD" USING WS-ROW WS-K WS-A WS-K1 WS-X0 WS-Y0 WS-Z0
     MOVE "acceptance US12 36-5§3.8 Child coordinates: the carved leftLow opening of a NORTH piece starts at local (0,3,1): world z maxZ - 1 = 209, y minY + 3; the child for leftLow asks for z minZ + 1 = 201 and y minY + 5 (the high opening)" TO TL-CASE
     MOVE 0 TO WS-A
     MOVE 3 TO WS-B
     CALL "SPB-WORLD" USING WS-ROW WS-A WS-B WS-K WS-X0 WS-Y0 WS-Z0
     COMPUTE TL-OBSERVED-N = WS-Z0 * 1000 + WS-Y0
     MOVE 209065 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CALC-EXPECTED.
*>   a and b: 3 and 5, swapped for WEST and NORTH
     MOVE 3 TO WS-A
     MOVE 5 TO WS-B
     IF WS-DIR = 1 OR WS-DIR = 2
         MOVE 5 TO WS-A
         MOVE 3 TO WS-B
     END-IF
*>   Forward(5, 1)
     MOVE WS-DIR TO WS-ED(1)
     EVALUATE WS-DIR
         WHEN 2
             COMPUTE WS-EX(1) = WS-X0 + 5
             COMPUTE WS-EZ(1) = WS-Z0 - 1
         WHEN 0
             COMPUTE WS-EX(1) = WS-X0 + 5
             COMPUTE WS-EZ(1) = WS-Z1 + 1
         WHEN 1
             COMPUTE WS-EX(1) = WS-X0 - 1
             COMPUTE WS-EZ(1) = WS-Z0 + 5
         WHEN OTHER
             COMPUTE WS-EX(1) = WS-X1 + 1
             COMPUTE WS-EZ(1) = WS-Z0 + 5
     END-EVALUATE
     COMPUTE WS-EY(1) = WS-Y0 + 1
*>   the four lateral children: Left(a,1), Left(b,7), Right(a,1), Right(b,7)
     PERFORM VARYING WS-K FROM 2 BY 1 UNTIL WS-K > 5
         EVALUATE WS-K
             WHEN 2
                 MOVE WS-A TO WS-I
                 MOVE 1 TO WS-CHILD
             WHEN 3
                 MOVE WS-B TO WS-I
                 MOVE 7 TO WS-CHILD
             WHEN 4
                 MOVE WS-A TO WS-I
                 MOVE 1 TO WS-CHILD
             WHEN OTHER
                 MOVE WS-B TO WS-I
                 MOVE 7 TO WS-CHILD
         END-EVALUATE
         COMPUTE WS-EY(WS-K) = WS-Y0 + WS-I
         IF WS-K < 4
*>           Left
             IF WS-DIR = 2 OR WS-DIR = 0
                 MOVE 1 TO WS-ED(WS-K)
                 COMPUTE WS-EX(WS-K) = WS-X0 - 1
                 COMPUTE WS-EZ(WS-K) = WS-Z0 + WS-CHILD
             ELSE
                 MOVE 2 TO WS-ED(WS-K)
                 COMPUTE WS-EX(WS-K) = WS-X0 + WS-CHILD
                 COMPUTE WS-EZ(WS-K) = WS-Z0 - 1
             END-IF
         ELSE
*>           Right
             IF WS-DIR = 2 OR WS-DIR = 0
                 MOVE 3 TO WS-ED(WS-K)
                 COMPUTE WS-EX(WS-K) = WS-X1 + 1
                 COMPUTE WS-EZ(WS-K) = WS-Z0 + WS-CHILD
             ELSE
                 MOVE 0 TO WS-ED(WS-K)
                 COMPUTE WS-EX(WS-K) = WS-X0 + WS-CHILD
                 COMPUTE WS-EZ(WS-K) = WS-Z1 + 1
             END-IF
         END-IF
     END-PERFORM.

 CHECK-CHILDREN.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 5
         MOVE SH-PEND(WS-K) TO WS-CHILD
         IF SP-ORIENT(WS-CHILD) NOT = WS-ED(WS-K)
             ADD 1 TO WS-BAD
         END-IF
*>       the anchor is inside the child's box and on the face the child is entered from
         IF WS-EX(WS-K) < SP-X0(WS-CHILD) OR WS-EX(WS-K) > SP-X1(WS-CHILD)
             ADD 1 TO WS-BAD
         END-IF
         IF WS-EY(WS-K) < SP-Y0(WS-CHILD) OR WS-EY(WS-K) > SP-Y1(WS-CHILD)
             ADD 1 TO WS-BAD
         END-IF
         IF WS-EZ(WS-K) < SP-Z0(WS-CHILD) OR WS-EZ(WS-K) > SP-Z1(WS-CHILD)
             ADD 1 TO WS-BAD
         END-IF
         EVALUATE SP-ORIENT(WS-CHILD)
             WHEN 2
                 IF WS-EZ(WS-K) NOT = SP-Z1(WS-CHILD)
                     ADD 1 TO WS-BAD
                 END-IF
             WHEN 0
                 IF WS-EZ(WS-K) NOT = SP-Z0(WS-CHILD)
                     ADD 1 TO WS-BAD
                 END-IF
             WHEN 1
                 IF WS-EX(WS-K) NOT = SP-X1(WS-CHILD)
                     ADD 1 TO WS-BAD
                 END-IF
             WHEN OTHER
                 IF WS-EX(WS-K) NOT = SP-X0(WS-CHILD)
                     ADD 1 TO WS-BAD
                 END-IF
         END-EVALUATE
     END-PERFORM.
 END PROGRAM TEST-STRUCT-36-5-3-8.
