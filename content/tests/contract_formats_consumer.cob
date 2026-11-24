*> Contract test, consumer side (specs/002-client-polish/contracts/formats-api.md "Contract tests"): content's
*> use of the formats library. The packs check reads a manifest and probes sentinels with FILE-EXISTS and
*> FILE-READ-AT; the registry loader reads a data pack file whole, parses it with JSON-STRICT (23 §3.2) and
*> reads a zip data pack (datapacks/*.zip) with ZIP-OPEN, ZIP-FIND and ZIP-READ. Linked from libformats
*> only; no content program is involved.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTRACT-FORMATS-CONSUMER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY FORMATS.
 COPY JSONDOC.
 01 WS-PATH                PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-OFFSET              BINARY-DOUBLE VALUE 0.
 01 WS-AREA                PIC X(4000).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ERROR-OFFSET        BINARY-LONG.
 01 WS-REASON              BINARY-LONG.
 01 WS-ZIP                 USAGE POINTER.
 01 WS-NAME                PIC X(256).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4000.
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-PATH
     MOVE "contract/fixtures/content/valid/vanilla-data/pack.mcmeta" TO WS-PATH
     CALL "FILE-EXISTS" USING WS-PATH WS-STATUS
     MOVE "consumer: FILE-EXISTS finds a sentinel file" TO TL-CASE
     MOVE FM-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-PATH
     MOVE "contract/fixtures/content/valid/vanilla-data" TO WS-PATH
     CALL "FILE-EXISTS" USING WS-PATH WS-STATUS
     MOVE "consumer: FILE-EXISTS tells a directory" TO TL-CASE
     MOVE FM-IS-DIR TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-PATH
     MOVE "contract/fixtures/content/valid/nothing.txt" TO WS-PATH
     CALL "FILE-EXISTS" USING WS-PATH WS-STATUS
     MOVE "consumer: FILE-EXISTS of nothing" TO TL-CASE
     MOVE FM-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-PATH
     MOVE "contract/fixtures/content/valid/manifest.txt" TO WS-PATH
     MOVE 4000 TO WS-LENGTH
     CALL "FILE-READ-AT" USING WS-PATH WS-OFFSET WS-AREA WS-LENGTH WS-STATUS
     MOVE "consumer: FILE-READ-AT reads the manifest, which starts with format=1" TO TL-CASE
     MOVE FM-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "consumer: manifest first line" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "format=1" TO TL-EXPECTED
     MOVE WS-AREA(1:8) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-PATH
     MOVE "contract/fixtures/content/valid/vanilla-data/pack.mcmeta" TO WS-PATH
     MOVE 4000 TO WS-LENGTH
     CALL "FILE-READ-AT" USING WS-PATH WS-OFFSET WS-AREA WS-LENGTH WS-STATUS
     CALL "JSON-STRICT" USING WS-AREA WS-LENGTH JSON-DOC WS-ERROR-OFFSET WS-REASON
     MOVE "N" TO TL-MODE
     MOVE "consumer: JSON-STRICT accepts a data pack.mcmeta" TO TL-CASE
     MOVE FM-JS-OK TO TL-EXPECTED-N
     MOVE WS-REASON TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "pack.max_format" TO WS-NAME
     MOVE 15 TO WS-PATH-LENGTH
     CALL "JSON-FIND" USING JSON-DOC WS-NAME WS-PATH-LENGTH WS-NODE
     MOVE "consumer: the parsed document is searchable" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-NODE > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "{""a"":1,}" TO WS-AREA
     MOVE 8 TO WS-LENGTH
     CALL "JSON-STRICT" USING WS-AREA WS-LENGTH JSON-DOC WS-ERROR-OFFSET WS-REASON
     MOVE "consumer: JSON-STRICT rejects a trailing comma" TO TL-CASE
     MOVE FM-JS-TRAILING-COMMA TO TL-EXPECTED-N
     MOVE WS-REASON TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-PATH
     MOVE "contract/fixtures/formats/basic.zip" TO WS-PATH
     MOVE 35 TO WS-PATH-LENGTH
     CALL "ZIP-OPEN" USING WS-PATH WS-PATH-LENGTH WS-ZIP WS-STATUS
     MOVE "consumer: ZIP-OPEN opens a zip data pack" TO TL-CASE
     MOVE FM-ZIP-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-NAME
     MOVE "pack.mcmeta" TO WS-NAME
     MOVE 11 TO WS-NAME-LENGTH
     CALL "ZIP-FIND" USING WS-ZIP WS-NAME WS-NAME-LENGTH WS-INDEX
     CALL "ZIP-READ" USING WS-ZIP WS-INDEX WS-AREA WS-CAPACITY WS-LENGTH WS-STATUS
     CALL "ZIP-CLOSE" USING WS-ZIP
     MOVE "consumer: ZIP-READ reads pack.mcmeta, 53 bytes" TO TL-CASE
     MOVE 53 TO TL-EXPECTED-N
     MOVE WS-LENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
