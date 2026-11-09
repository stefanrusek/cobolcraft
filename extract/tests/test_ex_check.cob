*> Implementation test for EX-CHECK and EX-CROSS-CHECK (22 §4.2 C1 to C5; T0297): over the reject archives of
*> contract/fixtures/extract/ (each with its CCX code and, for a few, the message text of 22 §7.4) and over the
*> operator's real jar (tmp/minecraft-26.3-client.jar, git-ignored; the test fails when it is absent): the jar is
*> identified (size, SHA-256 against an independent `shasum`, version.json), and C5 compares what version.json says
*> with the accepted row.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-EX-CHECK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY EXSTATE.
 COPY FORMATS.
 01 WS-FILE                PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-EXPECT              BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-ROOT                PIC X(1100).
 01 WS-COMMAND             PIC X(1100).
 01 WS-SHELL               BINARY-LONG.
 01 WS-SHA-FILE            PIC X(1100).
 01 WS-SHA-TEXT            PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OFFSET              BINARY-DOUBLE VALUE 0.
 01 WS-READ-STATUS         BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ROW-NUMBER          BINARY-LONG VALUE 1.
 01 WS-ROW                 PIC X(92).
 01 WS-ROW-STATUS          BINARY-LONG.
 01 WS-NULL                USAGE POINTER VALUE NULL.
 01 WS-EXPECTED-LINE       PIC X(1024).
 01 WS-SIZE-TEXT           PIC X(20).
 01 WS-EXPECT-TEXT         PIC 999.
 01 WS-SIZE-NUMBER         BINARY-DOUBLE.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE "contract/fixtures/extract/c-too-short.bin" TO WS-FILE
     MOVE 20 TO WS-EXPECT
     PERFORM CHECK-ONE
     MOVE "check: CCX-020 text for a file under 22 bytes" TO TL-CASE
     MOVE "CCX-020 contract/fixtures/extract/c-too-short.bin is not a zip file this tool can read: too short."
         TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 4 TO TL-EXPECTED-N
     MOVE EXR-EXIT TO TL-OBSERVED-N
     MOVE "check: CCX-020 exit status 4" TO TL-CASE
     PERFORM ASSERT-NUMBER

     MOVE "contract/fixtures/extract/c-not-a-zip.bin" TO WS-FILE
     MOVE 20 TO WS-EXPECT
     PERFORM CHECK-ONE
     MOVE "check: CCX-020 text for text that is no zip" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "CCX-020 contract/fixtures/extract/c-not-a-zip.bin is not a zip file this tool can read: "
         "no end record or the central directory does not match the end record." DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT

     MOVE "contract/fixtures/extract/c-no-end-record.zip" TO WS-FILE
     MOVE 20 TO WS-EXPECT
     PERFORM CHECK-ONE
     MOVE "contract/fixtures/extract/c-central-mismatch.zip" TO WS-FILE
     PERFORM CHECK-ONE
     MOVE "contract/fixtures/extract/c-bad-central-record.zip" TO WS-FILE
     PERFORM CHECK-ONE

     MOVE "contract/fixtures/extract/c-zip64.zip" TO WS-FILE
     MOVE 21 TO WS-EXPECT
     PERFORM CHECK-ONE
     MOVE "check: CCX-021 zip64 text" TO TL-CASE
     MOVE "CCX-021 contract/fixtures/extract/c-zip64.zip uses a zip feature this tool does not support: zip64."
         TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "contract/fixtures/extract/c-several-disks.zip" TO WS-FILE
     PERFORM CHECK-ONE
     MOVE "check: CCX-021 several disks text" TO TL-CASE
     MOVE "CCX-021 contract/fixtures/extract/c-several-disks.zip uses a zip feature this tool does not support: several disks."
         TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "contract/fixtures/extract/c-encrypted.zip" TO WS-FILE
     PERFORM CHECK-ONE
     MOVE "check: CCX-021 encrypted entry text" TO TL-CASE
     MOVE "CCX-021 contract/fixtures/extract/c-encrypted.zip uses a zip feature this tool does not support: encrypted entry a.txt."
         TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "contract/fixtures/extract/c-method-99.zip" TO WS-FILE
     PERFORM CHECK-ONE
     MOVE "check: CCX-021 method text" TO TL-CASE
     MOVE "CCX-021 contract/fixtures/extract/c-method-99.zip uses a zip feature this tool does not support: compression method 99 in entry a.txt."
         TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT

     MOVE "contract/fixtures/extract/c-no-version-json.zip" TO WS-FILE
     MOVE 30 TO WS-EXPECT
     PERFORM CHECK-ONE
     MOVE "check: CCX-030 for a missing version.json names the id unknown" TO TL-CASE
     MOVE "CCX-030 This jar is not supported (Minecraft unknown, SHA-256 " TO TL-EXPECTED
     MOVE EXR-LINE(1:61) TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "contract/fixtures/extract/ok-small.zip" TO WS-FILE
     PERFORM CHECK-ONE
     MOVE "contract/fixtures/extract/c-wrong-id.zip" TO WS-FILE
     PERFORM CHECK-ONE
     MOVE "check: CCX-030 text of an unknown id" TO TL-CASE
     MOVE EXC-SIZE TO WS-SIZE-NUMBER
     CALL "EX-NUM" USING WS-SIZE-NUMBER WS-SIZE-TEXT
     MOVE SPACES TO TL-EXPECTED
     STRING "CCX-030 This jar is not supported (Minecraft 99.9, SHA-256 " EXC-SHA ", " FUNCTION TRIM(WS-SIZE-TEXT)
         " bytes). CobolCraft supports Minecraft 26.3. Nothing was written." DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 3 TO TL-EXPECTED-N
     MOVE EXR-EXIT TO TL-OBSERVED-N
     MOVE "check: CCX-030 exit status 3" TO TL-CASE
     PERFORM ASSERT-NUMBER

*>   The digest in the message is the file's own (independent shasum).
     MOVE "contract/fixtures/extract/c-wrong-id.zip" TO WS-FILE
     MOVE "check-sha.txt" TO WS-NAME
     CALL "EXT-SCRATCH" USING WS-NAME WS-SHA-FILE
     MOVE SPACES TO WS-NAME WS-ROOT
     MOVE "." TO WS-NAME
     CALL "EXT-SCRATCH" USING WS-NAME WS-ROOT
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p " FUNCTION TRIM(WS-ROOT) " && shasum -a 256 " FUNCTION TRIM(WS-FILE) " | cut -c1-64 > "
         FUNCTION TRIM(WS-SHA-FILE) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE 64 TO WS-LENGTH
     CALL "FILE-READ-AT" USING WS-SHA-FILE WS-OFFSET WS-SHA-TEXT WS-LENGTH WS-READ-STATUS
     PERFORM CHECK-ONE
     MOVE "check: the digest of the file is the shasum one" TO TL-CASE
     MOVE WS-SHA-TEXT TO TL-EXPECTED
     MOVE EXC-SHA TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "check: the id of version.json is kept" TO TL-CASE
     MOVE "99.9" TO TL-EXPECTED
     MOVE EXC-ID TO TL-OBSERVED
     PERFORM ASSERT-TEXT

     MOVE "contract/fixtures/extract/c-right-id-wrong-digest.zip" TO WS-FILE
     MOVE 31 TO WS-EXPECT
     PERFORM CHECK-ONE
     MOVE "check: CCX-031 text names the expected digest and size" TO TL-CASE
     MOVE EXC-SIZE TO WS-SIZE-NUMBER
     CALL "EX-NUM" USING WS-SIZE-NUMBER WS-SIZE-TEXT
     MOVE SPACES TO TL-EXPECTED
     STRING "CCX-031 This jar says it is Minecraft 26.3 but it is not the build CobolCraft was written for (SHA-256 "
         EXC-SHA ", expected 4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d; size "
         FUNCTION TRIM(WS-SIZE-TEXT) ", expected 41483720). The file may be damaged or from another build. "
         "Nothing was written." DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 3 TO TL-EXPECTED-N
     MOVE EXR-EXIT TO TL-OBSERVED-N
     MOVE "check: CCX-031 exit status 3" TO TL-CASE
     PERFORM ASSERT-NUMBER

     MOVE "contract/fixtures/extract/does-not-exist.zip" TO WS-FILE
     MOVE 11 TO WS-EXPECT
     PERFORM CHECK-ONE
     MOVE "check: CCX-011 text for a file that cannot be opened" TO TL-CASE
     MOVE "CCX-011 Cannot read contract/fixtures/extract/does-not-exist.zip: cannot be opened or read."
         TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT

     MOVE "extract/tests/fixtures/bad-central-size.zip" TO WS-FILE
     MOVE 20 TO WS-EXPECT
     PERFORM CHECK-ONE
     MOVE "check: CCX-020 for a central record whose size lies past the end" TO TL-CASE
     MOVE "CCX-020 extract/tests/fixtures/bad-central-size.zip is not a zip file this tool can read: bad central record at entry 0."
         TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "extract/tests/fixtures/zip64-end.zip" TO WS-FILE
     MOVE 21 TO WS-EXPECT
     PERFORM CHECK-ONE
     MOVE "check: CCX-021 zip64 text for a zip64 end record" TO TL-CASE
     MOVE "CCX-021 extract/tests/fixtures/zip64-end.zip uses a zip feature this tool does not support: zip64."
         TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "extract/tests/fixtures/bad-version-json.zip" TO WS-FILE
     MOVE 30 TO WS-EXPECT
     PERFORM CHECK-ONE
     MOVE "check: a version.json that is no JSON leaves the id unknown" TO TL-CASE
     MOVE "unknown" TO TL-EXPECTED
     MOVE EXC-ID TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE ALL "x" TO WS-FILE
     MOVE 11 TO WS-EXPECT
     PERFORM CHECK-ONE

*>   The real jar (T1 to T4): identified, with an open archive.
     MOVE "minecraft-26.3-client.jar" TO WS-NAME
     CALL "EXT-INPUT-PATH" USING WS-NAME WS-FILE
     MOVE 0 TO WS-EXPECT
     PERFORM CHECK-ONE
     MOVE "check: the real jar is identified (input present)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     IF WS-STATUS NOT = 0
         DISPLAY "the real jar is absent or not accepted: " FUNCTION TRIM(WS-FILE)
         STOP RUN
     END-IF
     MOVE "check: jar size 41483720" TO TL-CASE
     MOVE 41483720 TO TL-EXPECTED-N
     MOVE EXC-SIZE TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "check: jar id 26.3" TO TL-CASE
     MOVE "26.3" TO TL-EXPECTED
     MOVE EXC-ID TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "check: jar digest as the table says" TO TL-CASE
     MOVE "4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d" TO TL-EXPECTED
     MOVE EXC-SHA TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "check: jar digest is the shasum one" TO TL-CASE
     MOVE "check-jar-sha.txt" TO WS-NAME
     CALL "EXT-SCRATCH" USING WS-NAME WS-SHA-FILE
     MOVE SPACES TO WS-COMMAND
     STRING "shasum -a 256 " FUNCTION TRIM(WS-FILE) " | cut -c1-64 > " FUNCTION TRIM(WS-SHA-FILE)
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE 64 TO WS-LENGTH
     CALL "FILE-READ-AT" USING WS-SHA-FILE WS-OFFSET WS-SHA-TEXT WS-LENGTH WS-READ-STATUS
     MOVE WS-SHA-TEXT TO TL-EXPECTED
     MOVE EXC-SHA TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "check: version.json world version 5023" TO TL-CASE
     MOVE 5023 TO TL-EXPECTED-N
     MOVE EXC-WORLD TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "check: version.json protocol 777" TO TL-CASE
     MOVE 777 TO TL-EXPECTED-N
     MOVE EXC-PROTOCOL TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "check: version.json resource format 97.1" TO TL-CASE
     COMPUTE TL-OBSERVED-N = EXC-RES-MAJOR * 100 + EXC-RES-MINOR
     MOVE 9701 TO TL-EXPECTED-N
     PERFORM ASSERT-NUMBER
     MOVE "check: version.json data format 121.0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = EXC-DATA-MAJOR * 100 + EXC-DATA-MINOR
     MOVE 12100 TO TL-EXPECTED-N
     PERFORM ASSERT-NUMBER
     MOVE "check: the open archive has 34227 central records (T1)" TO TL-CASE
     CALL "ZIP-COUNT" USING EXC-ZIP WS-COUNT
     MOVE 34227 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "check: the identifying row is row 1 of the accepted-jar table" TO TL-CASE
     CALL "CONTENT-ACCEPTED-JAR" USING WS-ROW-NUMBER WS-ROW WS-ROW-STATUS
     MOVE WS-ROW TO TL-EXPECTED
     MOVE EXC-ROW TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   C5: the facts against the row; each difference is CCX-045.
     CALL "EX-CROSS-CHECK" USING EXC-ROW WS-STATUS
     MOVE "check: C5 passes for the real jar" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 5024 TO EXC-WORLD
     PERFORM CROSS-45
     MOVE "check: C5 world version difference text" TO TL-CASE
     MOVE "CCX-045 version.json or the file counts do not match the table for this jar: world_version 5024, expected 5023."
         TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 5023 TO EXC-WORLD
     MOVE 778 TO EXC-PROTOCOL
     PERFORM CROSS-45
     MOVE 777 TO EXC-PROTOCOL
     MOVE 96 TO EXC-RES-MAJOR
     PERFORM CROSS-45
     MOVE 97 TO EXC-RES-MAJOR
     MOVE 2 TO EXC-RES-MINOR
     PERFORM CROSS-45
     MOVE 1 TO EXC-RES-MINOR
     MOVE 122 TO EXC-DATA-MAJOR
     PERFORM CROSS-45
     MOVE 121 TO EXC-DATA-MAJOR
     MOVE 1 TO EXC-DATA-MINOR
     PERFORM CROSS-45
     MOVE 0 TO EXC-DATA-MINOR
     MOVE "26.4" TO EXC-ID
     PERFORM CROSS-45
     MOVE "26.3" TO EXC-ID
     CALL "ZIP-CLOSE" USING EXC-ZIP
     STOP RUN.

 CHECK-ONE.
     MOVE -1 TO WS-STATUS
     CALL "EX-CHECK" USING WS-FILE WS-STATUS
     MOVE SPACES TO TL-CASE
     MOVE WS-EXPECT TO WS-EXPECT-TEXT
     STRING "check: " FUNCTION TRIM(WS-FILE) " gives CCX code " WS-EXPECT-TEXT DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER.

 CROSS-45.
     CALL "EX-CROSS-CHECK" USING EXC-ROW WS-STATUS
     MOVE "check: C5 difference gives CCX-045, exit 4" TO TL-CASE
     MOVE 45 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER.

 ASSERT-NUMBER.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-EX-CHECK.

 COPY EXTEST.
