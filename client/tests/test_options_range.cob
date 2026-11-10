*> Edge-case test (spec edge case, 13 §7.2: out-of-range file values are rejected by the codec): contract/fixtures/client/
*> options-out-of-range.txt holds a bad value for 22 options; each of them keeps its default (the rows of expected.txt;
*> fov is compared in degrees: 70 + 40 x the stored value), and the version line does not disturb the others.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-OPTIONS-RANGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY TESTLIB.
 01 WS-FILE                PIC X(32) VALUE "options-out-of-range.txt".
 01 WS-PATH                PIC X(1100) VALUE "contract/fixtures/client/options-out-of-range.txt".
 01 WS-PATH-LENGTH         BINARY-LONG VALUE 50.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(40).
 01 WS-EXPECTED            PIC X(64).
 01 WS-VALUE               PIC X(64).
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-DEGREES             PIC 999.
 01 WS-EDIT                PIC ZZ9.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "OPTIONS-DEFAULTS" USING CLIENT-STATE
     CALL "OPTIONS-READ" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-FOUND
     MOVE "T" TO TL-MODE
     MOVE 1 TO WS-ROW
     PERFORM UNTIL WS-ROW > 99
         CALL "TEST-OPT-EXPECTED" USING WS-FILE WS-ROW WS-KEY WS-EXPECTED WS-FOUND
         IF WS-FOUND = 0
             EXIT PERFORM
         END-IF
         CALL "OPTIONS-GET" USING CLIENT-STATE WS-KEY WS-VALUE WS-VALUE-LENGTH WS-FOUND
         IF WS-KEY = "fov"
             COMPUTE WS-DEGREES = 70 + 40 * FUNCTION NUMVAL(WS-VALUE)
             MOVE WS-DEGREES TO WS-EDIT
             MOVE FUNCTION TRIM(WS-EDIT) TO WS-VALUE
         END-IF
         MOVE SPACES TO TL-CASE
         STRING "options range: " FUNCTION TRIM(WS-KEY) " out of range keeps the default " FUNCTION TRIM(WS-EXPECTED)
             DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-EXPECTED TO TL-EXPECTED
         MOVE WS-VALUE TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         ADD 1 TO WS-ROW
     END-PERFORM
     MOVE "options range: the 22 rows of expected.txt were all checked" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 23 TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-OPTIONS-RANGE.

 COPY OPTTEST.
 COPY CLTEST.
