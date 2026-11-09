*> Implementation test for lines of extract/src that the other tests leave unexecuted (T0315): EX-JOIN with an empty
*> base (every other line of the package is run by the tests of its own program).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-EXTRACT-COVER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY EXSTATE.
 01 WS-BASE                PIC X(1100).
 01 WS-REST                PIC X(1100).
 01 WS-OUT                 PIC X(1100).
 01 WS-CODE                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-BASE WS-REST WS-OUT
     MOVE "a/b.txt" TO WS-REST
     CALL "EX-JOIN" USING WS-BASE WS-REST WS-OUT
     MOVE "cover: EX-JOIN of an empty base is the rest alone" TO TL-CASE
     MOVE "a/b.txt" TO TL-EXPECTED
     MOVE WS-OUT TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "dir" TO WS-BASE
     CALL "EX-JOIN" USING WS-BASE WS-REST WS-OUT
     MOVE "cover: EX-JOIN joins with one slash" TO TL-CASE
     MOVE "dir/a/b.txt" TO TL-EXPECTED
     MOVE WS-OUT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-EXTRACT-COVER.

 COPY EXTEST.
