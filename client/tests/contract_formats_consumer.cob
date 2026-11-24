*> Contract test, consumer side (specs/002-client-polish/contracts/formats-api.md "Contract tests"): the client's
*> use of the formats library, as packs/source.cob, mcmeta.cob and stack.cob do it: open a zip pack, find
*> and read pack.mcmeta, parse it and take pack.pack_format, filter a file name with a regex, read a loose
*> file whole and decode a PNG. Linked from libformats, no client program involved.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTRACT-FORMATS-CONSUMER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY JSONDOC.
 COPY TESTLIB.
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-ZIP                 USAGE POINTER.
 01 WS-STATUS              BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-NAME                PIC X(256).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-AREA                PIC X(4000).
 01 WS-CAPACITY            BINARY-LONG VALUE 4000.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-OUT                 PIC X(512).
 01 WS-OUT-LENGTH          BINARY-LONG.
 01 WS-OUT-CAP             BINARY-LONG VALUE 512.
 01 WS-PNG                 PIC X(4096).
 01 WS-PNG-CAPACITY        BINARY-LONG VALUE 4096.
 01 WS-PNG-LENGTH          BINARY-LONG.
 01 WS-PIXELS              PIC X(1024).
 01 WS-PIXELS-CAPACITY     BINARY-LONG VALUE 1024.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-PAT                 PIC X(128).
 01 WS-SUBJ                PIC X(256).
 01 WS-PAT-LENGTH          BINARY-LONG.
 01 WS-SUBJ-LENGTH         BINARY-LONG.
 01 WS-MATCHED             BINARY-LONG.
 01 WS-ERROR               BINARY-LONG.
 01 WS-SHOWN               PIC -(9)9.
 01 WS-SHOWN2              PIC -(9)9.
 01 WS-STATUS-D            PIC 9.
 PROCEDURE DIVISION.
*>   A zip pack: ZIP-OPEN, ZIP-FIND, ZIP-READ, then JSON-PARSE and JSON-FIND on the bytes read.
     MOVE SPACES TO WS-PATH
     MOVE "contract/fixtures/formats/basic.zip" TO WS-PATH
     MOVE 35 TO WS-PATH-LENGTH
     CALL "ZIP-OPEN" USING WS-PATH WS-PATH-LENGTH WS-ZIP WS-STATUS
     MOVE "contract formats consumer: a zip pack opens (status 0)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "pack.mcmeta" TO WS-NAME
     MOVE 11 TO WS-NAME-LENGTH
     CALL "ZIP-FIND" USING WS-ZIP WS-NAME WS-NAME-LENGTH WS-INDEX
     CALL "ZIP-READ" USING WS-ZIP WS-INDEX WS-AREA WS-CAPACITY WS-LENGTH WS-STATUS
     CALL "ZIP-CLOSE" USING WS-ZIP
     CALL "JSON-PARSE" USING JSON-DOC WS-AREA WS-LENGTH
     MOVE "pack.pack_format" TO WS-NAME
     MOVE 16 TO WS-NAME-LENGTH
     CALL "JSON-FIND" USING JSON-DOC WS-NAME WS-NAME-LENGTH WS-NODE
     MOVE "contract formats consumer: pack.mcmeta of the zip has pack.pack_format 97" TO TL-CASE
     MOVE 97 TO TL-EXPECTED-N
     MOVE -1 TO TL-OBSERVED-N
     IF WS-NODE > 0 AND JN-TYPE(WS-NODE) = JT-NUMBER
         MOVE JN-NUM(WS-NODE) TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "pack.description" TO WS-NAME
     MOVE 16 TO WS-NAME-LENGTH
     CALL "JSON-FIND" USING JSON-DOC WS-NAME WS-NAME-LENGTH WS-NODE
     CALL "JSON-STRING" USING JSON-DOC WS-NODE WS-OUT WS-OUT-CAP WS-OUT-LENGTH
     MOVE "contract formats consumer: pack.description is zip test" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "zip test" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-OUT-LENGTH > 0
         MOVE WS-OUT(1:WS-OUT-LENGTH) TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A loose file of a folder pack: FILE-READ-ALL; a missing one is status 1.
     MOVE SPACES TO WS-PATH
     MOVE "contract/fixtures/formats/hello.txt" TO WS-PATH
     MOVE 35 TO WS-PATH-LENGTH
     CALL "FILE-READ-ALL" USING WS-PATH WS-PATH-LENGTH WS-AREA WS-CAPACITY WS-LENGTH WS-STATUS
     MOVE "contract formats consumer: a loose file is read whole (status 0, 14 bytes)" TO TL-CASE
     MOVE "0 14" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-LENGTH TO WS-SHOWN
     MOVE WS-STATUS TO WS-SHOWN2
     STRING FUNCTION TRIM(WS-SHOWN2) " " FUNCTION TRIM(WS-SHOWN) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-PATH
     MOVE "contract/fixtures/formats/absent.txt" TO WS-PATH
     MOVE 36 TO WS-PATH-LENGTH
     CALL "FILE-READ-ALL" USING WS-PATH WS-PATH-LENGTH WS-AREA WS-CAPACITY WS-LENGTH WS-STATUS
     MOVE "contract formats consumer: a missing loose file is status 1" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A texture: PNG-DECODE of the file read.
     MOVE SPACES TO WS-PATH
     MOVE "contract/fixtures/formats/g8.png" TO WS-PATH
     MOVE 32 TO WS-PATH-LENGTH
     CALL "FILE-READ-ALL" USING WS-PATH WS-PATH-LENGTH WS-PNG WS-PNG-CAPACITY WS-PNG-LENGTH WS-STATUS
     CALL "PNG-DECODE" USING WS-PNG WS-PNG-LENGTH WS-PIXELS WS-PIXELS-CAPACITY WS-WIDTH WS-HEIGHT
         WS-STATUS
     MOVE "contract formats consumer: g8.png decodes (status 0, 13x11)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0 13x11" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-WIDTH TO WS-SHOWN
     MOVE WS-HEIGHT TO WS-SHOWN2
     MOVE WS-STATUS TO WS-STATUS-D
     STRING WS-STATUS-D " " FUNCTION TRIM(WS-SHOWN) "x" FUNCTION TRIM(WS-SHOWN2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A pack.mcmeta filter: REGEX-FIND on a logical path.
     MOVE SPACES TO WS-PAT WS-SUBJ
     MOVE "^assets/.*\.png$" TO WS-PAT
     MOVE 16 TO WS-PAT-LENGTH
     MOVE "assets/cobolcraft/textures/block/x.png" TO WS-SUBJ
     MOVE 38 TO WS-SUBJ-LENGTH
     CALL "REGEX-FIND" USING WS-PAT WS-PAT-LENGTH WS-SUBJ WS-SUBJ-LENGTH WS-MATCHED WS-ERROR
     MOVE "contract formats consumer: the filter matches a png under assets, no error" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-MATCHED - WS-ERROR
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM CONTRACT-FORMATS-CONSUMER.
