*> Contract consumer test (US1-core; contracts/content-api.md section 4): the core side opens a set through the
*> fixture generated directories of contract/fixtures/content/ and asserts the status words and one block lookup.
*> Given the valid tree, When CORE-PACKS-STATUS runs, Then ok; the standard set then reaches the data (the tree
*> holds no variant registries: CT-BAD-DATA). Given the stale tree, Then the standard open is refused with
*> CT-PACKS-NOT-OK. Given the cobolcraft type (reads nothing from the directory), Then CT-OK and greystone is id 2.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTRACT-CONTENT-CONSUMER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-REASON              PIC X(128).
 01 WS-TYPE                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 PROCEDURE DIVISION.
     MOVE "contract/fixtures/content/valid" TO WS-DIR
     CALL "CORE-PACKS-STATUS" USING WS-DIR WS-STATUS WS-REASON
     MOVE "contract US1-core: valid tree packs status ok" TO TL-CASE
     MOVE CT-PACKS-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "contract US1-core: standard open reaches the data (no variants in the tree)" TO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

     MOVE "contract/fixtures/content/stale" TO WS-DIR
     CALL "CORE-PACKS-STATUS" USING WS-DIR WS-STATUS WS-REASON
     MOVE "contract US1-core: stale tree packs status stale" TO TL-CASE
     MOVE CT-PACKS-STALE TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "contract US1-core: standard open over a stale tree is refused" TO TL-CASE
     MOVE CT-PACKS-NOT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

     MOVE CT-TYPE-COBOLCRAFT TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "contract US1-core: cobolcraft open needs no packs" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "cobolcraft:greystone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-BLOCK-ROW WS-STATUS
     MOVE "contract US1-core: block lookup status" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "contract US1-core: greystone is block 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-ID TO WS-STATUS
     PERFORM ASSERT-STATUS
     CALL "CONTENT-CLOSE"
     STOP RUN.

 ASSERT-STATUS.
     MOVE "N" TO TL-MODE
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
