*> Implementation test for EX-VERIFY (22 §7.6; T0305): a tree made from the small archive (the walk, the generated
*> pack.mcmeta, index.txt, manifest.txt and the marker) verifies (CCX-102); each damage names itself in CCX-060: a
*> changed file (CRC-32), a file of another size, a missing file, a file the index does not list, a missing or
*> invalid manifest, a missing index, a file count that differs from the manifest and a pack.mcmeta that is not the
*> text of 22 §6.2 for the manifest's format.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-EX-VERIFY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY EXSTATE.
 COPY FORMATS.
 01 WS-FILE                PIC X(1024).
 01 WS-FILE-LENGTH         BINARY-LONG.
 01 WS-ZIP                 USAGE POINTER.
 01 WS-ZIP-STATUS          BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-ROOT                PIC X(1100).
 01 WS-COMMAND             PIC X(1100).
 01 WS-SHELL               BINARY-LONG.
 01 WS-GOOD                PIC X(1100).
 01 WS-CASE                PIC X(1100).
 01 WS-PATH                PIC X(1100).
 01 WS-ROW-NUMBER          BINARY-LONG VALUE 1.
 01 WS-ROW-STATUS          BINARY-LONG.
 01 WS-BYTES               PIC X(12) VALUE "changed text".
 01 WS-BYTES-LENGTH        BINARY-LONG VALUE 12.
 01 WS-SHORT               PIC X(3) VALUE "abc".
 01 WS-SHORT-LENGTH        BINARY-LONG VALUE 3.
 01 WS-FILE-STATUS         BINARY-LONG.
 01 WS-EXPECTED            PIC X(1024).
 01 WS-CASE-NAME           PIC X(60).
 PROCEDURE DIVISION.
     MOVE "verify" TO WS-NAME
     CALL "EXT-SCRATCH" USING WS-NAME WS-ROOT
     MOVE SPACES TO WS-COMMAND
     STRING "rm -rf " FUNCTION TRIM(WS-ROOT) " && mkdir -p " FUNCTION TRIM(WS-ROOT) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE 1 TO EXO-QUIET
     MOVE 0 TO EXO-DRY

*>   Make a good tree from the small archive.
     MOVE SPACES TO WS-GOOD
     STRING FUNCTION TRIM(WS-ROOT) "/good" DELIMITED BY SIZE INTO WS-GOOD
     MOVE "extract/tests/fixtures/mini.zip" TO WS-FILE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-FILE)) TO WS-FILE-LENGTH
     CALL "ZIP-OPEN" USING WS-FILE WS-FILE-LENGTH WS-ZIP WS-ZIP-STATUS
     CALL "EX-PLAN" USING WS-ZIP WS-STATUS
     CALL "EX-INDEX-RESET"
     CALL "CONTENT-ACCEPTED-JAR" USING WS-ROW-NUMBER EXC-ROW WS-ROW-STATUS
     CALL "EX-WRITE-MARKER" USING WS-GOOD WS-STATUS
     CALL "EX-WRITE-MCMETA" USING WS-GOOD WS-STATUS
     MOVE 0 TO EXR-WRITTEN EXR-BYTES
     CALL "EX-WALK" USING WS-ZIP WS-GOOD WS-STATUS
     CALL "ZIP-CLOSE" USING WS-ZIP
     CALL "EX-WRITE-INDEX" USING WS-GOOD WS-STATUS
     CALL "EX-WRITE-MANIFEST" USING WS-GOOD WS-STATUS
     MOVE "verify: the good tree was made" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER

     MOVE WS-GOOD TO WS-CASE
     PERFORM VERIFY-ONE
     MOVE "verify: a good tree gives status 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "verify: CCX-102 names the 11 files and the directory" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "CCX-102 Verified 11 files in " FUNCTION TRIM(WS-GOOD) "." DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   A file with other bytes of the same size: its CRC-32 differs.
     MOVE "crc" TO WS-CASE-NAME
     PERFORM COPY-GOOD
     MOVE SPACES TO WS-PATH
     STRING FUNCTION TRIM(WS-CASE) "/vanilla-resources/assets/minecraft/lang/en_us.json" DELIMITED BY SIZE INTO WS-PATH
     MOVE 11 TO WS-BYTES-LENGTH
     CALL "FILE-WRITE" USING WS-PATH WS-BYTES WS-BYTES-LENGTH WS-FILE-STATUS
     PERFORM VERIFY-ONE
     MOVE "verify: a changed file gives CCX-060, exit 6" TO TL-CASE
     MOVE 60 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 6 TO TL-EXPECTED-N
     MOVE EXR-EXIT TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "verify: the CRC-32 problem names the file, found and expected" TO TL-CASE
     MOVE "CCX-060 Verification failed: 1 problems. First: CRC-32 21fc166e instead of 6d7b8797 in vanilla-resources/assets/minecraft/lang/en_us.json."
         TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   A file of another size.
     MOVE "size" TO WS-CASE-NAME
     PERFORM COPY-GOOD
     MOVE SPACES TO WS-PATH
     STRING FUNCTION TRIM(WS-CASE) "/vanilla-data/data/minecraft/recipe/stick.json" DELIMITED BY SIZE INTO WS-PATH
     CALL "FILE-WRITE" USING WS-PATH WS-SHORT WS-SHORT-LENGTH WS-FILE-STATUS
     PERFORM VERIFY-ONE
     MOVE "verify: a file of another size" TO TL-CASE
     MOVE "CCX-060 Verification failed: 1 problems. First: size 3 instead of 13 in vanilla-data/data/minecraft/recipe/stick.json."
         TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   A missing file, two missing files (the problems are counted).
     MOVE "missing" TO WS-CASE-NAME
     PERFORM COPY-GOOD
     MOVE SPACES TO WS-COMMAND
     STRING "rm " FUNCTION TRIM(WS-CASE) "/vanilla-data/pack.png " FUNCTION TRIM(WS-CASE)
         "/featurepacks/trade_rebalance/pack.mcmeta" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     PERFORM VERIFY-ONE
     MOVE "verify: two missing files are two problems, the first named" TO TL-CASE
     MOVE "CCX-060 Verification failed: 2 problems. First: missing vanilla-data/pack.png." TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   A file the index does not list.
     MOVE "extra" TO WS-CASE-NAME
     PERFORM COPY-GOOD
     MOVE SPACES TO WS-COMMAND
     STRING "mkdir -p " FUNCTION TRIM(WS-CASE) "/vanilla-data/extra && touch " FUNCTION TRIM(WS-CASE)
         "/vanilla-data/extra/stray.txt" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     PERFORM VERIFY-ONE
     MOVE "verify: a file the index does not list" TO TL-CASE
     MOVE "CCX-060 Verification failed: 1 problems. First: extra file vanilla-data/extra/stray.txt." TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   The manifest.
     MOVE "no-manifest" TO WS-CASE-NAME
     PERFORM COPY-GOOD
     MOVE SPACES TO WS-COMMAND
     STRING "rm " FUNCTION TRIM(WS-CASE) "/manifest.txt" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     PERFORM VERIFY-ONE
     MOVE "verify: a missing manifest" TO TL-CASE
     MOVE "CCX-060 Verification failed: 1 problems. First: manifest invalid: manifest.txt is missing or not a manifest."
         TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "bad-manifest" TO WS-CASE-NAME
     PERFORM COPY-GOOD
     MOVE SPACES TO WS-PATH
     STRING FUNCTION TRIM(WS-CASE) "/manifest.txt" DELIMITED BY SIZE INTO WS-PATH
     CALL "FILE-WRITE" USING WS-PATH WS-SHORT WS-SHORT-LENGTH WS-FILE-STATUS
     PERFORM VERIFY-ONE
     MOVE "verify: an invalid manifest" TO TL-CASE
     MOVE 60 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER

*>   The index.
     MOVE "no-index" TO WS-CASE-NAME
     PERFORM COPY-GOOD
     MOVE SPACES TO WS-COMMAND
     STRING "rm " FUNCTION TRIM(WS-CASE) "/index.txt" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     PERFORM VERIFY-ONE
     MOVE "verify: a missing index" TO TL-CASE
     MOVE "CCX-060 Verification failed: 1 problems. First: manifest invalid: index.txt is missing or too large."
         TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   An index with a line that is not "crc size path".
     MOVE "bad-index" TO WS-CASE-NAME
     PERFORM COPY-GOOD
     MOVE SPACES TO WS-PATH
     STRING FUNCTION TRIM(WS-CASE) "/index.txt" DELIMITED BY SIZE INTO WS-PATH
     CALL "FILE-WRITE" USING WS-PATH WS-SHORT WS-SHORT-LENGTH WS-FILE-STATUS
     PERFORM VERIFY-ONE
     MOVE "verify: an index line that is no crc size path" TO TL-CASE
     MOVE 60 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER

*>   A manifest that counts another number of files.
     MOVE "count" TO WS-CASE-NAME
     PERFORM COPY-GOOD
     MOVE SPACES TO WS-COMMAND
     STRING "sed 's/^files-total=11$/files-total=12/' " FUNCTION TRIM(WS-GOOD) "/manifest.txt > " FUNCTION TRIM(WS-CASE)
         "/manifest.txt" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     PERFORM VERIFY-ONE
     MOVE "verify: files-total that differs from the index" TO TL-CASE
     MOVE "CCX-060 Verification failed: 1 problems. First: manifest invalid: files-total 12 but the index lists 11."
         TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   A manifest whose resource format says another pack.mcmeta text.
     MOVE "format" TO WS-CASE-NAME
     PERFORM COPY-GOOD
     MOVE SPACES TO WS-COMMAND
     STRING "sed 's/^resource-format=97.1$/resource-format=97.2/' " FUNCTION TRIM(WS-GOOD) "/manifest.txt > "
         FUNCTION TRIM(WS-CASE) "/manifest.txt" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     PERFORM VERIFY-ONE
     MOVE "verify: pack.mcmeta that is not the text of the manifest's format" TO TL-CASE
     MOVE "CCX-060 Verification failed: 1 problems. First: vanilla-resources/pack.mcmeta is not the text of 22 section 6.2 for 97.2."
         TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   A directory that is not there.
     MOVE SPACES TO WS-CASE
     STRING FUNCTION TRIM(WS-ROOT) "/nothing" DELIMITED BY SIZE INTO WS-CASE
     PERFORM VERIFY-ONE
     MOVE "verify: an absent directory" TO TL-CASE
     MOVE 60 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     STOP RUN.

 COPY-GOOD.
     MOVE SPACES TO WS-CASE
     STRING FUNCTION TRIM(WS-ROOT) "/" FUNCTION TRIM(WS-CASE-NAME) DELIMITED BY SIZE INTO WS-CASE
     MOVE SPACES TO WS-COMMAND
     STRING "cp -R " FUNCTION TRIM(WS-GOOD) " " FUNCTION TRIM(WS-CASE) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL.

 VERIFY-ONE.
     MOVE -1 TO WS-STATUS
     CALL "EX-VERIFY" USING WS-CASE WS-STATUS.

 ASSERT-NUMBER.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-EX-VERIFY.

 COPY EXTEST.
