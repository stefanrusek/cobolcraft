*> Test of content/src/accepted-jar.cob (CONTENT-ACCEPTED-JAR; 22 §4.1, data-model §1): USING row number
*> (BINARY-LONG, 1-based), row out (PIC X(92), the width of content/copy/gen/acceptedjar.cpy), status out.
*> Row 1 is the one row of the generated table (version id, size, SHA-256, world and protocol version,
*> resource and data pack format); the expected values are the README row of 22 §4.1. Row 0, row 2 and a
*> negative row are CT-NOT-FOUND with the area left as it was.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ACCEPTED-JAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 01 WS-NUMBER              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROW                 PIC X(92).
 01 WS-VIEW REDEFINES WS-ROW.
    05 WS-VERSION          PIC X(4).
    05 WS-SIZE             PIC X(8).
    05 WS-SHA              PIC X(64).
    05 WS-WORLD            PIC X(4).
    05 WS-PROTOCOL         PIC X(3).
    05 WS-RESOURCE         PIC X(4).
    05 WS-DATA             PIC X(5).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE ALL "?" TO WS-ROW
     MOVE 1 TO WS-NUMBER
     CALL "CONTENT-ACCEPTED-JAR" USING WS-NUMBER WS-ROW WS-STATUS
     MOVE "N" TO TL-MODE
     MOVE "accepted jar: row 1 is found" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE "accepted jar: version id" TO TL-CASE
     MOVE "26.3" TO TL-EXPECTED
     MOVE WS-VERSION TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "accepted jar: size in bytes" TO TL-CASE
     MOVE "41483720" TO TL-EXPECTED
     MOVE WS-SIZE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "accepted jar: SHA-256" TO TL-CASE
     MOVE "4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d" TO TL-EXPECTED
     MOVE WS-SHA TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "accepted jar: world version" TO TL-CASE
     MOVE "5023" TO TL-EXPECTED
     MOVE WS-WORLD TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "accepted jar: protocol version" TO TL-CASE
     MOVE "777" TO TL-EXPECTED
     MOVE WS-PROTOCOL TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "accepted jar: resource pack format" TO TL-CASE
     MOVE "97.1" TO TL-EXPECTED
     MOVE WS-RESOURCE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "accepted jar: data pack format" TO TL-CASE
     MOVE "121.0" TO TL-EXPECTED
     MOVE WS-DATA TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     PERFORM VARYING WS-NUMBER FROM -1 BY 1 UNTIL WS-NUMBER > 2
         IF WS-NUMBER NOT = 1
             MOVE ALL "?" TO WS-ROW
             CALL "CONTENT-ACCEPTED-JAR" USING WS-NUMBER WS-ROW WS-STATUS
             MOVE "N" TO TL-MODE
             MOVE "accepted jar: a row other than 1 is not found" TO TL-CASE
             MOVE CT-NOT-FOUND TO TL-EXPECTED-N
             MOVE WS-STATUS TO TL-OBSERVED-N
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
             MOVE "T" TO TL-MODE
             MOVE "accepted jar: the area is left as it was" TO TL-CASE
             MOVE SPACES TO TL-EXPECTED
             MOVE ALL "?" TO TL-EXPECTED(1:92)
             MOVE WS-ROW TO TL-OBSERVED
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-IF
     END-PERFORM
     STOP RUN.
