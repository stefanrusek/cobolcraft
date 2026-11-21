*> Test of 29b part 2 section 7, Cocoa (core/src/growth-29b-2b.cob; T0547): cocoa of 7.
*> A case loads its inputs from a text of numbers (LOAD-IN fills WS-ISG), calls the program with the input group (and the key) and shows the first outputs of WS-RSG joined by "/", one group per
*> call; expected values come from the rules, tables and worked cases of the section.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GROWTH-29B-2-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-ISG.
    05 WS-I BINARY-LONG OCCURS 16 TIMES.
 01 WS-RSG.
    05 WS-R BINARY-LONG OCCURS 16 TIMES.
 01 WS-KEY                 PIC X(48).
 01 WS-A                   PIC X(48).
 01 WS-B                   PIC X(48).
 01 WS-C                   PIC X(48).
 01 WS-STEM                BINARY-LONG.
 01 WS-T1                  BINARY-LONG.
 01 WS-T2                  BINARY-LONG.
 01 WS-IN                  PIC X(160).
 01 WS-TOK                 PIC X(24).
 01 WS-P                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-SHOW                PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 29b-2§7 Cocoa: survive, random tick and bone meal (7): support at the facing, nextInt(5) = 0 writes age + 1 below age 2, bone meal valid below age 2" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "2 0 1 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-COCOA" USING WS-ISG WS-RSG
     MOVE 7 TO WS-N
     PERFORM ADD-N
     MOVE "2 1 1 3" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-COCOA" USING WS-ISG WS-RSG
     MOVE 7 TO WS-N
     PERFORM ADD-N
     MOVE "3 2 1 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-COCOA" USING WS-ISG WS-RSG
     MOVE 7 TO WS-N
     PERFORM ADD-N
     MOVE "4 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-COCOA" USING WS-ISG WS-RSG
     MOVE 7 TO WS-N
     PERFORM ADD-N
     MOVE "1/1/1/1/1/1/1 1/1/1/0/1/1/2 1/0/0/0/2/0/2 0/1/1/1/1/1/1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§7 Cocoa: updateShape (7): air when the changed direction is the facing and the block cannot survive, else unchanged" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "2 2 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-COCOA-UPDATE" USING WS-ISG WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "2 2 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-COCOA-UPDATE" USING WS-ISG WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "3 2 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-COCOA-UPDATE" USING WS-ISG WS-RSG
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§7 Cocoa: placement (7): the first horizontal direction in looking order whose state can survive; none gives no placement" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "2 4 3 5 0 1 1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-COCOA-PLACE" USING WS-ISG WS-RSG
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "5 3 4 2 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-COCOA-PLACE" USING WS-ISG WS-RSG
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "3 2 5 4 1 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-COCOA-PLACE" USING WS-ISG WS-RSG
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "3 2 0 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-COCOA-PLACE" USING WS-ISG WS-RSG
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "4/2 -1/0 3/1 -1/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§7 Cocoa: shape (24 6.23): column(4 + 2a, 7 - 2a, 12) shifted by 5 - a pixels towards the facing: x1/x2/z1/z2/y1/y2 for north ages 0 to 2" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "2 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-COCOA-SHAPE" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "2 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-COCOA-SHAPE" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "2 2" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-COCOA-SHAPE" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "6/10/1/5/7/12 5/11/1/7/5/12 4/12/1/9/3/12" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§7 Cocoa: shape rotated to south, east and west at age 0" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "3 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-COCOA-SHAPE" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "5 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-COCOA-SHAPE" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "4 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-COCOA-SHAPE" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "6/10/11/15/7/12 11/15/6/10/7/12 1/5/6/10/7/12" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 BEGIN-CASE.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     .

 LOAD-IN.
     MOVE 1 TO WS-P
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 16
         MOVE SPACES TO WS-TOK
         IF WS-P <= 160
             UNSTRING WS-IN DELIMITED BY ALL SPACE INTO WS-TOK WITH POINTER WS-P
         END-IF
         COMPUTE WS-I(WS-K) = FUNCTION NUMVAL(WS-TOK)
     END-PERFORM
     .

 ADD-N.
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-N
         MOVE WS-R(WS-J) TO WS-SHOW
         IF WS-J > 1
             STRING "/" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
         STRING FUNCTION TRIM(WS-SHOW) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     STRING " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .

 ADD-TEXT.
     STRING FUNCTION TRIM(WS-A) "|" FUNCTION TRIM(WS-B) "|" FUNCTION TRIM(WS-C) "|" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-T1 TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) "/" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-T2 TO WS-SHOW
     STRING FUNCTION TRIM(WS-SHOW) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .
 END PROGRAM TEST-GROWTH-29B-2-7.
