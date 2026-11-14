*> Implementation test for EX-ENTRY-READ and EX-WALK (22 §7.3 step 7; T0301): one entry is read through its local
*> header, inflated and CRC-checked (CCX-040, 041, 042, 021), and the planned entries of a small archive
*> (tests/fixtures/mini.zip) are read and written under a partial directory, with their index lines; --dry-run
*> reads and writes nothing; a bad entry or a path that cannot be written stops the walk with its code.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-EX-WALK.
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
 01 WS-EXPECT              BINARY-LONG.
 01 WS-EXPECT-TEXT         PIC 999.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-ENTRY-TEXT          PIC 999.
 01 WS-BUFFER              PIC X(1048576).
 01 WS-CAPACITY            BINARY-LONG VALUE 1048576.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-CRC                 BINARY-LONG UNSIGNED.
 01 WS-NAME                PIC X(64).
 01 WS-ROOT                PIC X(1100).
 01 WS-COMMAND             PIC X(1100).
 01 WS-SHELL               BINARY-LONG.
 01 WS-PARTIAL             PIC X(1100).
 01 WS-PATH                PIC X(1100).
 01 WS-OFFSET              BINARY-DOUBLE VALUE 0.
 01 WS-READ-STATUS         BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-POINTER             BINARY-LONG.
 01 WS-LF                  PIC X VALUE X"0A".
 PROCEDURE DIVISION.
     MOVE "walk" TO WS-NAME
     CALL "EXT-SCRATCH" USING WS-NAME WS-ROOT
     MOVE SPACES TO WS-COMMAND
     STRING "rm -rf " FUNCTION TRIM(WS-ROOT) " && mkdir -p " FUNCTION TRIM(WS-ROOT) " && touch " FUNCTION TRIM(WS-ROOT)
         "/blocker" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "EXT-SHELL" USING WS-COMMAND WS-SHELL
     MOVE 1 TO EXO-QUIET
     MOVE 0 TO EXO-DRY

*>   EX-ENTRY-READ: the good entries of ok-small.zip.
     MOVE "contract/fixtures/extract/ok-small.zip" TO WS-FILE
     MOVE 1 TO WS-ENTRY
     MOVE 0 TO WS-EXPECT
     PERFORM READ-ONE
     MOVE "entry: a deflated entry reads its 11 bytes" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE WS-LENGTH TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "entry: its text" TO TL-CASE
     MOVE "hello world" TO TL-EXPECTED
     MOVE WS-BUFFER(1:11) TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "entry: its CRC-32 0d4a1185" TO TL-CASE
     MOVE 222957957 TO TL-EXPECTED-N
     MOVE WS-CRC TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE 2 TO WS-ENTRY
     PERFORM READ-ONE
     MOVE "entry: a stored entry reads its 6 bytes" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE WS-LENGTH TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     CALL "ZIP-CLOSE" USING WS-ZIP
*>   An empty file inflates to nothing.
     MOVE "extract/tests/fixtures/mini.zip" TO WS-FILE
     MOVE 4 TO WS-ENTRY
     PERFORM READ-ONE
     MOVE "entry: an empty file reads 0 bytes" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LENGTH TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "entry: its CRC-32 is 0" TO TL-CASE
     MOVE WS-CRC TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     CALL "ZIP-CLOSE" USING WS-ZIP

*>   Bad entries.
     MOVE "contract/fixtures/extract/t-bad-crc.zip" TO WS-FILE
     MOVE 1 TO WS-ENTRY
     MOVE 40 TO WS-EXPECT
     PERFORM READ-ONE
     MOVE "entry: CCX-040 text" TO TL-CASE
     MOVE "CCX-040 Entry a.txt is damaged: CRC-32 0d4a1185, expected deadbeef." TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     CALL "ZIP-CLOSE" USING WS-ZIP
     MOVE "contract/fixtures/extract/t-bad-deflate.zip" TO WS-FILE
     MOVE 41 TO WS-EXPECT
     PERFORM READ-ONE
     MOVE "entry: CCX-041 text for bad data" TO TL-CASE
     MOVE "CCX-041 Entry a.txt cannot be unpacked: bad deflate data or a size that differs from the central record."
         TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     CALL "ZIP-CLOSE" USING WS-ZIP
     MOVE "contract/fixtures/extract/t-size-mismatch.zip" TO WS-FILE
     PERFORM READ-ONE
     CALL "ZIP-CLOSE" USING WS-ZIP
     MOVE "extract/tests/fixtures/walk-big.zip" TO WS-FILE
     PERFORM READ-ONE
     MOVE "entry: CCX-041 text for an entry over the buffer" TO TL-CASE
     MOVE "CCX-041 Entry assets/minecraft/big.bin cannot be unpacked: larger than the 1048576-byte buffer."
         TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     CALL "ZIP-CLOSE" USING WS-ZIP
     MOVE "contract/fixtures/extract/t-local-mismatch.zip" TO WS-FILE
     MOVE 42 TO WS-EXPECT
     PERFORM READ-ONE
     MOVE "entry: CCX-042 text, exit 4" TO TL-CASE
     MOVE "CCX-042 Entry a.txt does not match its local header." TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     CALL "ZIP-CLOSE" USING WS-ZIP
     MOVE "contract/fixtures/extract/c-encrypted.zip" TO WS-FILE
     MOVE 21 TO WS-EXPECT
     PERFORM READ-ONE
     MOVE "entry: CCX-021 for an encrypted entry" TO TL-CASE
     MOVE "CCX-021 contract/fixtures/extract/c-encrypted.zip uses a zip feature this tool does not support: encrypted entry a.txt."
         TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     CALL "ZIP-CLOSE" USING WS-ZIP
     MOVE "contract/fixtures/extract/c-method-99.zip" TO WS-FILE
     PERFORM READ-ONE
     MOVE "entry: CCX-021 for a method" TO TL-CASE
     MOVE "CCX-021 contract/fixtures/extract/c-method-99.zip uses a zip feature this tool does not support: compression method 99 in entry a.txt."
         TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     CALL "ZIP-CLOSE" USING WS-ZIP
     MOVE "contract/fixtures/extract/c-zip64.zip" TO WS-FILE
     PERFORM READ-ONE
     CALL "ZIP-CLOSE" USING WS-ZIP
     MOVE "extract/tests/fixtures/bad-central-size.zip" TO WS-FILE
     MOVE 20 TO WS-EXPECT
     PERFORM READ-ONE
     MOVE "entry: CCX-020 for a central record whose size lies past the end" TO TL-CASE
     MOVE "CCX-020 extract/tests/fixtures/bad-central-size.zip is not a zip file this tool can read: bad central record at entry 0."
         TO TL-EXPECTED
     MOVE EXR-LINE TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     CALL "ZIP-CLOSE" USING WS-ZIP

*>   EX-WALK over the small archive.
     MOVE "extract/tests/fixtures/mini.zip" TO WS-FILE
     PERFORM OPEN-ZIP
     CALL "EX-PLAN" USING WS-ZIP WS-STATUS
     CALL "EX-INDEX-RESET"
     MOVE 0 TO EXR-WRITTEN EXR-BYTES
     MOVE SPACES TO WS-PARTIAL
     STRING FUNCTION TRIM(WS-ROOT) "/partial" DELIMITED BY SIZE INTO WS-PARTIAL
     MOVE -1 TO WS-STATUS
     CALL "EX-WALK" USING WS-ZIP WS-PARTIAL WS-STATUS
     MOVE "walk: the small archive walks with status 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "walk: 9 files written (pack.png twice)" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE EXR-WRITTEN TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "walk: 95 bytes written" TO TL-CASE
     MOVE 95 TO TL-EXPECTED-N
     MOVE EXR-BYTES TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "walk: 9 index lines" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE EXI-LINES TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE SPACES TO WS-PATH
     STRING FUNCTION TRIM(WS-PARTIAL) "/vanilla-resources/assets/minecraft/lang/en_us.json" DELIMITED BY SIZE INTO WS-PATH
     PERFORM READ-WHOLE
     MOVE "walk: en_us.json is the jar's bytes" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING '{"a": "b"}' WS-LF DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-TEXT(1:1024) TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "walk: en_us.json is 11 bytes" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE WS-LENGTH TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE SPACES TO WS-PATH
     STRING FUNCTION TRIM(WS-PARTIAL) "/featurepacks/trade_rebalance/data/minecraft/loot_table/a.json" DELIMITED BY SIZE
         INTO WS-PATH
     PERFORM READ-WHOLE
     MOVE "walk: a feature pack file is written" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-LENGTH TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE SPACES TO WS-PATH
     STRING FUNCTION TRIM(WS-PARTIAL) "/vanilla-data/pack.png" DELIMITED BY SIZE INTO WS-PATH
     PERFORM READ-WHOLE
     MOVE "walk: pack.png is written to the data pack too" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     MOVE WS-LENGTH TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     CALL "EX-WRITE-INDEX" USING WS-PARTIAL WS-STATUS
     MOVE SPACES TO WS-PATH
     STRING FUNCTION TRIM(WS-PARTIAL) "/index.txt" DELIMITED BY SIZE INTO WS-PATH
     PERFORM READ-WHOLE
     MOVE SPACES TO WS-EXPECTED
     MOVE 1 TO WS-POINTER
     STRING "8f8358cc 14 vanilla-resources/pack.png" WS-LF "8f8358cc 14 vanilla-data/pack.png" WS-LF
         "6d7b8797 11 vanilla-resources/assets/minecraft/lang/en_us.json" WS-LF
         "becbb469 15 vanilla-resources/assets/minecraft/textures/block/stone.png" WS-LF
         "6f91146d 13 vanilla-data/data/minecraft/recipe/stick.json" WS-LF
         "a3a6bf43 2 vanilla-data/data/minecraft/worldgen/biome/plains.json" WS-LF
         "773f5c14 12 featurepacks/trade_rebalance/pack.mcmeta" WS-LF
         "a3a6bf43 2 featurepacks/trade_rebalance/data/minecraft/loot_table/a.json" WS-LF
         "773f5c14 12 featurepacks/redstone_experiments/pack.mcmeta" WS-LF
         DELIMITED BY SIZE INTO WS-EXPECTED POINTER WS-POINTER
     MOVE "walk: index lines in central directory order" TO TL-CASE
     MOVE WS-EXPECTED TO TL-EXPECTED
     MOVE WS-TEXT(1:1024) TO TL-OBSERVED
     PERFORM ASSERT-TEXT

*>   --dry-run: reads and checks, writes nothing.
     MOVE 1 TO EXO-DRY
     CALL "EX-INDEX-RESET"
     MOVE 0 TO EXR-WRITTEN EXR-BYTES
     MOVE SPACES TO WS-PARTIAL
     STRING FUNCTION TRIM(WS-ROOT) "/dry" DELIMITED BY SIZE INTO WS-PARTIAL
     CALL "EX-WALK" USING WS-ZIP WS-PARTIAL WS-STATUS
     MOVE "walk: --dry-run gives status 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     CALL "FILE-EXISTS" USING WS-PARTIAL WS-STATUS
     MOVE "walk: --dry-run creates no directory" TO TL-CASE
     MOVE FM-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "walk: --dry-run writes and indexes nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EXR-WRITTEN + EXI-LINES + EXR-BYTES
     PERFORM ASSERT-NUMBER
     MOVE 0 TO EXO-DRY

*>   A path that cannot be written: the partial directory is below a file.
     CALL "EX-INDEX-RESET"
     MOVE SPACES TO WS-PARTIAL
     STRING FUNCTION TRIM(WS-ROOT) "/blocker" DELIMITED BY SIZE INTO WS-PARTIAL
     CALL "EX-WALK" USING WS-ZIP WS-PARTIAL WS-STATUS
     MOVE "walk: a file where the partial directory belongs gives CCX-050" TO TL-CASE
     MOVE 50 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     CALL "ZIP-CLOSE" USING WS-ZIP

*>   Bad entries stop the walk with the entry's code.
     MOVE "extract/tests/fixtures/walk-bad-crc.zip" TO WS-FILE
     MOVE 40 TO WS-EXPECT
     PERFORM WALK-ONE
     MOVE "extract/tests/fixtures/walk-bad-deflate.zip" TO WS-FILE
     MOVE 41 TO WS-EXPECT
     PERFORM WALK-ONE
     MOVE "extract/tests/fixtures/walk-local-mismatch.zip" TO WS-FILE
     MOVE 42 TO WS-EXPECT
     PERFORM WALK-ONE
     CALL "EX-INDEX-RESET"
     STOP RUN.

 OPEN-ZIP.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-FILE)) TO WS-FILE-LENGTH
     MOVE WS-FILE TO EXC-PATH
     CALL "ZIP-OPEN" USING WS-FILE WS-FILE-LENGTH WS-ZIP WS-ZIP-STATUS
     MOVE SPACES TO TL-CASE
     STRING "walk: " FUNCTION TRIM(WS-FILE) " opens" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ZIP-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER.

 READ-ONE.
     PERFORM OPEN-ZIP
     MOVE -1 TO WS-STATUS
     MOVE 0 TO WS-LENGTH WS-CRC
     CALL "EX-ENTRY-READ" USING WS-ZIP WS-ENTRY WS-BUFFER WS-CAPACITY WS-LENGTH WS-CRC WS-STATUS
     MOVE WS-EXPECT TO WS-EXPECT-TEXT
     MOVE WS-ENTRY TO WS-ENTRY-TEXT
     MOVE SPACES TO TL-CASE
     STRING "entry: " FUNCTION TRIM(WS-FILE) " entry " WS-ENTRY-TEXT " gives CCX code " WS-EXPECT-TEXT
         DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER.

 WALK-ONE.
     PERFORM OPEN-ZIP
     CALL "EX-PLAN" USING WS-ZIP WS-STATUS
     CALL "EX-INDEX-RESET"
     MOVE SPACES TO WS-PARTIAL
     STRING FUNCTION TRIM(WS-ROOT) "/bad" DELIMITED BY SIZE INTO WS-PARTIAL
     MOVE -1 TO WS-STATUS
     CALL "EX-WALK" USING WS-ZIP WS-PARTIAL WS-STATUS
     CALL "ZIP-CLOSE" USING WS-ZIP
     MOVE WS-EXPECT TO WS-EXPECT-TEXT
     MOVE SPACES TO TL-CASE
     STRING "walk: " FUNCTION TRIM(WS-FILE) " gives CCX code " WS-EXPECT-TEXT DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER.

 READ-WHOLE.
     MOVE SPACES TO WS-TEXT
     MOVE 4096 TO WS-LENGTH
     CALL "FILE-READ-AT" USING WS-PATH WS-OFFSET WS-TEXT WS-LENGTH WS-READ-STATUS.

 ASSERT-NUMBER.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-EX-WALK.

 COPY EXTEST.
