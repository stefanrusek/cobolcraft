*> Test of the interval_select node of the density function loader (docs/protocol/11 section 2.3, 10 section 4.2): its fields are
*> the input (WGN-CHILD 1), the thresholds (a chain of constants from WGN-CHILD 2) and the functions (a chain from WGN-CHILD 3, one
*> more than there are thresholds; a function may be a number, an object or a reference). Before the type had fields the loader dropped
*> them and the node read 0. The fixture tree is content/tests/fixtures/interval-select (one function).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WORLDGEN-INTERVAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTWORLDGEN.
 01 WS-DIR                 PIC X(1100) VALUE "content/tests/fixtures/interval-select".
 01 WS-STATUS              BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:pick".
 01 WS-ROOT                BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-DOMAIN              BINARY-LONG.
 01 WS-TYPE-NAME           PIC X(32).
 01 WS-FIELDS              PIC X(640).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "WORLDGEN-FREE"
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-DIR WS-STATUS
     MOVE "interval select the fixture loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WG-FIND" USING WS-KIND WS-KEY WS-ROOT
     CALL "WG-TYPE-AT" USING WGN-TYPE(WS-ROOT) WS-DOMAIN WS-TYPE-NAME WS-FIELDS
     MOVE "T" TO TL-MODE
     MOVE "interval select the root is an interval_select" TO TL-CASE
     MOVE "interval_select" TO TL-EXPECTED
     MOVE WS-TYPE-NAME TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     CALL "WG-TYPE-AT" USING WGN-TYPE(WGN-CHILD(WS-ROOT, 1)) WS-DOMAIN WS-TYPE-NAME WS-FIELDS
     MOVE "T" TO TL-MODE
     MOVE "interval select the input is the gradient" TO TL-CASE
     MOVE "gradient" TO TL-EXPECTED
     MOVE WS-TYPE-NAME TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-COUNT
     MOVE WGN-CHILD(WS-ROOT, 2) TO WS-NODE
     PERFORM UNTIL WS-NODE = 0
         ADD 1 TO WS-COUNT
         MOVE WGN-NEXT(WS-NODE) TO WS-NODE
     END-PERFORM
     MOVE "interval select has three thresholds" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE TL-OBSERVED-N = WGN-NUM(WGN-NEXT(WGN-CHILD(WS-ROOT, 2)), 1) * 10
     MOVE "interval select the second threshold is 0.0 (a constant node)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-COUNT
     MOVE WGN-CHILD(WS-ROOT, 3) TO WS-NODE
     PERFORM UNTIL WS-NODE = 0
         ADD 1 TO WS-COUNT
         MOVE WGN-NEXT(WS-NODE) TO WS-NODE
     END-PERFORM
     MOVE "interval select has four functions" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WGN-NEXT(WGN-NEXT(WGN-CHILD(WS-ROOT, 3))) TO WS-NODE
     CALL "WG-TYPE-AT" USING WGN-TYPE(WS-NODE) WS-DOMAIN WS-TYPE-NAME WS-FIELDS
     MOVE "T" TO TL-MODE
     MOVE "interval select the third function is the abs object" TO TL-CASE
     MOVE "abs" TO TL-EXPECTED
     MOVE WS-TYPE-NAME TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-WORLDGEN-INTERVAL.
