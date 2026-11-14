*> Edge-case test (spec edge case "the jar changes between runs"; 22 §7.5): the check never reads a leftover
*> <generated>.partial. Scratch: build/content-test/partial. A .partial beside no <generated> gives
*> absent; a valid tree with a stale .partial (a manifest of another jar, no sentinels) beside it gives ok.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PACKS-PARTIAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-REASON              PIC X(128).
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "rm -rf build/content-test/partial && mkdir -p build/content-test/partial"
     CALL "SYSTEM" USING "cp -R contract/fixtures/content/stale build/content-test/partial/gen.partial"
     MOVE SPACES TO WS-DIR
     MOVE "build/content-test/partial/gen" TO WS-DIR
     CALL "CONTENT-PACKS-CHECK" USING WS-DIR WS-STATUS WS-REASON
     MOVE "N" TO TL-MODE
     MOVE "partial: a .partial alone gives absent" TO TL-CASE
     MOVE CT-PACKS-ABSENT TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "SYSTEM" USING "cp -R contract/fixtures/content/valid build/content-test/partial/gen"
     MOVE SPACES TO WS-REASON
     CALL "CONTENT-PACKS-CHECK" USING WS-DIR WS-STATUS WS-REASON
     MOVE "partial: a valid tree beside a stale .partial gives ok" TO TL-CASE
     MOVE CT-PACKS-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "SYSTEM" USING "rm -rf build/content-test/partial/gen"
     CALL "CONTENT-PACKS-CHECK" USING WS-DIR WS-STATUS WS-REASON
     MOVE "partial: once the tree is gone the .partial still gives absent" TO TL-CASE
     MOVE CT-PACKS-ABSENT TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
