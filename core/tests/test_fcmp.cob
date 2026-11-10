*> Implementation test of the float compare without decimals (core/src/fcmp.cob): a > b for finite numbers of both signs, equal
*> numbers, a difference far below the unit of the sum (a denormal against zero), the infinities and a NaN on either side.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FCMP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-TA                  PIC X(32).
 01 WS-TB                  PIC X(32).
 01 WS-R                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE "test fcmp 1 > 0" TO TL-CASE
     MOVE Z"1" TO WS-TA
     MOVE Z"0" TO WS-TB
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CHECK
     MOVE "test fcmp 0 > 1 is false" TO TL-CASE
     MOVE Z"0" TO WS-TA
     MOVE Z"1" TO WS-TB
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK
     MOVE "test fcmp equal numbers are not greater" TO TL-CASE
     MOVE Z"2.5" TO WS-TA
     MOVE Z"2.5" TO WS-TB
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK
     MOVE "test fcmp -1 > -2" TO TL-CASE
     MOVE Z"-1" TO WS-TA
     MOVE Z"-2" TO WS-TB
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CHECK
     MOVE "test fcmp -2 > -1 is false" TO TL-CASE
     MOVE Z"-2" TO WS-TA
     MOVE Z"-1" TO WS-TB
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK
     MOVE "test fcmp a denormal is greater than zero" TO TL-CASE
     MOVE Z"4.9e-324" TO WS-TA
     MOVE Z"0" TO WS-TB
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CHECK
     MOVE "test fcmp minus zero is not greater than zero" TO TL-CASE
     MOVE Z"-0" TO WS-TA
     MOVE Z"0" TO WS-TB
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK
     MOVE "test fcmp infinity is greater than a finite number" TO TL-CASE
     MOVE Z"inf" TO WS-TA
     MOVE Z"1e308" TO WS-TB
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CHECK
     MOVE "test fcmp infinity is not greater than itself" TO TL-CASE
     MOVE Z"inf" TO WS-TA
     MOVE Z"inf" TO WS-TB
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK
     MOVE "test fcmp a NaN is not greater than a number" TO TL-CASE
     MOVE Z"nan" TO WS-TA
     MOVE Z"1" TO WS-TB
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK
     MOVE "test fcmp a number is not greater than a NaN" TO TL-CASE
     MOVE Z"1" TO WS-TA
     MOVE Z"nan" TO WS-TB
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK
     STOP RUN.

 CHECK.
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TA WS-A
     CALL STATIC "cc_f64_from_text" USING BY REFERENCE WS-TB WS-B
     CALL "FCMP-GT" USING WS-A WS-B WS-R
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-FCMP.
