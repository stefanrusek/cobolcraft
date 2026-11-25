*> Implementation test of CONTENT-TAG-AT (content/src/tags.cob): the bound tags of the set one by one.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-TAG-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 01 WS-INDEX               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-REGISTRY            PIC X(48).
 01 WS-KEY                 PIC X(112).
 01 WS-COUNT               BINARY-LONG VALUE 0.
 01 WS-ID                  BINARY-LONG VALUE 0.
 01 WS-OUT                 PIC X(200).
 01 WS-EDIT                PIC 9.
 PROCEDURE DIVISION.
     CALL "CONTENT-CLOSE"
     MOVE "tag-at given no open set when asked then not open" TO TL-CASE
     MOVE 1 TO WS-INDEX
     PERFORM ASK
     MOVE "4 [] []" TO TL-EXPECTED
     PERFORM ASSERT-OUT

     MOVE 1 TO CT-OPEN
     MOVE "tag-at given a set without tags when asked then not found" TO TL-CASE
     PERFORM ASK
     MOVE "1 [] []" TO TL-EXPECTED
     PERFORM ASSERT-OUT

     MOVE "minecraft:block" TO WS-REGISTRY
     MOVE "logs" TO WS-KEY
     CALL "TAG-PUT" USING WS-REGISTRY WS-KEY WS-COUNT WS-ID WS-STATUS
     MOVE "tag-at given one bound tag when index 1 then its registry and key" TO TL-CASE
     PERFORM ASK
     MOVE "0 [block] [minecraft:logs]" TO TL-EXPECTED
     PERFORM ASSERT-OUT

     MOVE "tag-at given one bound tag when index 2 then not found" TO TL-CASE
     MOVE 2 TO WS-INDEX
     PERFORM ASK
     MOVE "1 [] []" TO TL-EXPECTED
     PERFORM ASSERT-OUT

     MOVE "tag-at given one bound tag when index 0 then not found" TO TL-CASE
     MOVE 0 TO WS-INDEX
     PERFORM ASK
     MOVE "1 [] []" TO TL-EXPECTED
     PERFORM ASSERT-OUT

     CALL "CONTENT-CLOSE"
     STOP RUN.

 ASK.
     CALL "CONTENT-TAG-AT" USING WS-INDEX WS-REGISTRY WS-KEY WS-STATUS
     MOVE WS-STATUS TO WS-EDIT
     MOVE SPACES TO WS-OUT
     STRING WS-EDIT " [" FUNCTION TRIM(WS-REGISTRY) "] [" FUNCTION TRIM(WS-KEY) "]" DELIMITED BY SIZE INTO WS-OUT.

 ASSERT-OUT.
     MOVE "T" TO TL-MODE
     MOVE WS-OUT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-TAG-AT.
