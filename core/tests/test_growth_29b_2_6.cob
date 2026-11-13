*> Test of 29b part 2 section 6, Nether wart (core/src/growth-29b-2b.cob; T0545): nether wart of 6.
*> A case loads its inputs from a text of numbers (LOAD-IN fills WS-ISG), calls the program with the input group (and the key) and shows the first outputs of WS-RSG joined by "/", one group per
*> call; expected values come from the rules, tables and worked cases of the section.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GROWTH-29B-2-6.
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
     MOVE "acceptance US12 29b-2§6 Nether wart: properties and shape (6): age 0 to 3, column(16, 0, 5 + 3a) = 5, 8, 11, 14; survives on soul sand, no light test" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0 0 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-WART" USING WS-ISG WS-RSG
     MOVE 7 TO WS-N
     PERFORM ADD-N
     MOVE "1 5 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-WART" USING WS-ISG WS-RSG
     MOVE 7 TO WS-N
     PERFORM ADD-N
     MOVE "2 5 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-WART" USING WS-ISG WS-RSG
     MOVE 7 TO WS-N
     PERFORM ADD-N
     MOVE "3 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-WART" USING WS-ISG WS-RSG
     MOVE 7 TO WS-N
     PERFORM ADD-N
     MOVE "5/1/1/1/1/1/0 8/1/1/1/0/1/0 11/1/1/1/0/2/0 14/0/0/0/0/3/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§6 Nether wart: random tick (6): age below 3 and nextInt(10) = 0 write age + 1 with one draw; at age 3 it neither ticks nor draws; no bone meal" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0 0 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-WART" USING WS-ISG WS-RSG
     MOVE 7 TO WS-N
     PERFORM ADD-N
     MOVE "2 9 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-WART" USING WS-ISG WS-RSG
     MOVE 7 TO WS-N
     PERFORM ADD-N
     MOVE "2 0 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-WART" USING WS-ISG WS-RSG
     MOVE 7 TO WS-N
     PERFORM ADD-N
     MOVE "3 0 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-WART" USING WS-ISG WS-RSG
     MOVE 7 TO WS-N
     PERFORM ADD-N
     MOVE "5/1/1/1/1/1/0 11/1/1/1/0/2/0 11/1/1/1/1/3/0 14/1/0/0/0/3/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 29b-2§6 Nether wart: drops (6): age 3 sets the count to U(2, 4) then Fortune uniform_bonus_count adds nextInt(L + 1); other ages keep 1" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "3 1 0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-WART-DROP" USING WS-ISG WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE "3 2 1 3 2" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-WART-DROP" USING WS-ISG WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE "2 2 1 3 2" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-WART-DROP" USING WS-ISG WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE "3 0 1 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "GB2-WART-DROP" USING WS-ISG WS-RSG
     MOVE 3 TO WS-N
     PERFORM ADD-N
     MOVE "3/1/0 6/2/4 1/0/0 2/2/1" TO TL-EXPECTED
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
 END PROGRAM TEST-GROWTH-29B-2-6.
