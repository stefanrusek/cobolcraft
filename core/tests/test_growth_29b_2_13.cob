*> Test of 29b part 2 section 13, Bone meal in one table (core/src/growth-29b-2c.cob; T0559): the bone meal table of 13.
*> A case loads its inputs from a text of numbers (LOAD-IN fills WS-ISG), calls the program with the input group (and the key) and shows the first outputs of WS-RSG joined by "/", one group per
*> call; expected values come from the rules, tables and worked cases of the section.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GROWTH-29B-2-13.
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
     MOVE "acceptance US12 29b-2§13 Bone meal in one table: wheat, carrots, potatoes (13): valid below age 7, always succeeds, age + U(2, 5) capped at 7, level random; beetroots add U(2, 5) / 3 up to 3" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "1 2 3 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-BONEMEAL" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "1 7 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-BONEMEAL" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "2 1 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-BONEMEAL" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "2 1 3 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-BONEMEAL" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "1/1/1/7/1/0 0/1/0/7/1/0 1/1/1/1/1/0 1/1/1/2/1/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§13 Bone meal in one table: torchflower crop (always valid, +1, no random) and pitcher crop (canGrow for age + 1 on the lower half, +1)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "3 1 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-BONEMEAL" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "4 2 0 1 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-BONEMEAL" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "4 2 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-BONEMEAL" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "1/1/1/2/0/0 1/1/1/3/0/0 0/1/0/2/0/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§13 Bone meal in one table: stems (13): valid unless age 7, age + U(2, 5) from the passed random, result 7 ticks at once; attached stems, wart, farmland, path, mud, fruit: no target" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "5 5 1 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-BONEMEAL" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "5 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-BONEMEAL" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "5 7 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-BONEMEAL" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "6 3 0 1 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-BONEMEAL" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "1/1/1/7/2/1 1/1/1/2/2/0 0/1/0/7/2/0 0/0/0/3/0/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§13 Bone meal in one table: cocoa (valid below age 2, +1), sweet berry bush (valid below 3, +1), rooted dirt (air below and in build height, hanging_roots)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "7 1 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-BONEMEAL" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "7 2 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-BONEMEAL" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "8 2 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-BONEMEAL" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "8 3 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-BONEMEAL" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "9 0 0 1 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-BONEMEAL" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "9 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-BONEMEAL" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "1/1/1/2/0/0 0/1/0/2/0/0 1/1/1/3/0/0 0/1/0/3/0/0 1/1/1/0/0/0 0/1/0/0/0/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§13 Bone meal in one table: sapling and azalea: valid by part 1 7.1 or 11.2, success P(0.45) on the level random; mangrove propagule as in 11.1" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "10 0 0 1 449999 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-BONEMEAL" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "10 0 0 1 450000 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-BONEMEAL" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "12 0 0 1 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-BONEMEAL" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "12 0 0 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-BONEMEAL" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "11 4 0 1 0 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-BONEMEAL" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "11 4 0 0 0 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-BONEMEAL" USING WS-ISG WS-RSG
     MOVE 6 TO WS-N
     PERFORM ADD-N
     MOVE "1/2/1/0/1/0 1/2/0/0/1/0 1/2/1/0/1/0 0/2/0/0/1/0 1/3/1/4/1/0 0/3/0/4/1/0" TO TL-EXPECTED
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
 END PROGRAM TEST-GROWTH-29B-2-13.
