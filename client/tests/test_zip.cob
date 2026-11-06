*> Implementation test of client/src/zip.cob (ZIP-OPEN, ZIP-CLOSE, ZIP-COUNT, ZIP-NAME, ZIP-FIND,
*> ZIP-SIZE, ZIP-READ; docs/protocol/08-resource-packs.md §1.1, contracts/shim-abi.md §5 cc_inflate
*> mode CC_RAW): the central directory is read (found by searching backwards for the end of central
*> directory record, past an archive comment), stored and deflated entries are read, entries are
*> looked up by name, directory entries are listed as they are, names longer than 256 bytes are
*> skipped, a too-small capacity is reported (5), unsupported, encrypted, zip64 and damaged entries
*> are reported as corrupt (2), a missing or unreadable file is status 1 and a file that is not a
*> readable zip archive (08 §1.1) status 2. Fixtures: client/tests/fixtures/zips, written by
*> client/tests/fixtures/gen_zips.py.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ZIP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-FIXTURE             PIC X(64).
 01 WS-PATH                PIC X(1024).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-ZIP                 USAGE POINTER.
 01 WS-STATUS              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-NAME                PIC X(256).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-AREA                PIC X(4000).
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-READ-STATUS         BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-LINE                PIC X(10).
 01 WS-LINE-NUMBER         PIC 9(4).
 01 WS-LINE-POS            BINARY-LONG.
 01 WS-NUMS.
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC 9(4) VALUE 150.
    05 FILLER PIC 9(4) VALUE 300.
 01 WS-NUM-TABLE REDEFINES WS-NUMS.
    05 WS-NUM              PIC 9(4) OCCURS 3 TIMES.
 01 WS-BAD-NAMES.
    05 FILLER PIC X(16) VALUE "bzip.txt".
    05 FILLER PIC X(16) VALUE "crypt.txt".
    05 FILLER PIC X(16) VALUE "zip64.txt".
    05 FILLER PIC X(16) VALUE "farlocal.txt".
    05 FILLER PIC X(16) VALUE "badlocal.txt".
    05 FILLER PIC X(16) VALUE "overrun.txt".
    05 FILLER PIC X(16) VALUE "storedsize.txt".
    05 FILLER PIC X(16) VALUE "badinflate.txt".
    05 FILLER PIC X(16) VALUE "mismatch.txt".
 01 WS-BAD-TABLE REDEFINES WS-BAD-NAMES.
    05 WS-BAD-NAME         PIC X(16) OCCURS 9 TIMES.
 01 WS-UNREADABLE.
    05 FILLER PIC X(16) VALUE "notzip".
    05 FILLER PIC X(16) VALUE "tiny".
    05 FILLER PIC X(16) VALUE "truncated".
    05 FILLER PIC X(16) VALUE "badcd".
    05 FILLER PIC X(16) VALUE "badcount".
    05 FILLER PIC X(16) VALUE "zip64eocd".
 01 WS-UNREADABLE-TABLE REDEFINES WS-UNREADABLE.
    05 WS-UNREADABLE-NAME  PIC X(16) OCCURS 6 TIMES.
 PROCEDURE DIVISION.
*>   Files that cannot be opened or read: status 1, no archive.
     MOVE "client/tests/fixtures/zips/absent.zip" TO WS-PATH
     PERFORM OPEN-PATH
     MOVE "zip a missing file cannot be opened (status 1, handle NULL)" TO TL-CASE
     PERFORM ASSERT-OPEN-FAILED-1
     MOVE "client/tests/fixtures/zips" TO WS-PATH
     PERFORM OPEN-PATH
     MOVE "zip a directory cannot be read (status 1, handle NULL)" TO TL-CASE
     PERFORM ASSERT-OPEN-FAILED-1

*>   Files that are not readable zip archives: status 2 (08 §1.1).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE WS-UNREADABLE-NAME(WS-I) TO WS-FIXTURE
         PERFORM OPEN-FIXTURE
         MOVE SPACES TO TL-CASE
         STRING "zip " FUNCTION TRIM(WS-FIXTURE) ".zip is not a readable zip archive (status 2, handle NULL)"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE "2 null" TO TL-EXPECTED
         PERFORM SHOW-OPEN
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   An archive without entries.
     MOVE "empty" TO WS-FIXTURE
     PERFORM OPEN-FIXTURE
     MOVE "zip empty.zip opens with no entries" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0 set 0" TO TL-EXPECTED
     PERFORM SHOW-OPEN-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "pack.mcmeta" TO WS-NAME
     MOVE 11 TO WS-NAME-LENGTH
     CALL "ZIP-FIND" USING WS-ZIP WS-NAME WS-NAME-LENGTH WS-INDEX
     MOVE "zip empty.zip has no pack.mcmeta" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     PERFORM ASSERT-N
     CALL "ZIP-CLOSE" USING WS-ZIP
     MOVE "zip close sets the handle NULL; closing NULL does nothing" TO TL-CASE
     CALL "ZIP-CLOSE" USING WS-ZIP
     MOVE "T" TO TL-MODE
     MOVE "null" TO TL-EXPECTED
     MOVE "set" TO TL-OBSERVED
     IF WS-ZIP = NULL
         MOVE "null" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The central directory of basic.zip: names in order, directory entries included.
     MOVE "basic" TO WS-FIXTURE
     PERFORM OPEN-FIXTURE
     MOVE "zip basic.zip opens with 4 entries" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0 set 4" TO TL-EXPECTED
     PERFORM SHOW-OPEN-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "zip basic.zip names and lengths in central directory order" TO TL-CASE
     MOVE "pack.mcmeta 11|assets/ 7|assets/cobolcraft/lang/en_us.json 33|empty.txt 9|" TO TL-EXPECTED
     PERFORM SHOW-NAMES
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "zip names out of range are spaces with length 0" TO TL-CASE
     MOVE "|0||0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-INDEX
     CALL "ZIP-NAME" USING WS-ZIP WS-INDEX WS-NAME WS-NAME-LENGTH
     MOVE WS-NAME-LENGTH TO WS-E1
     STRING FUNCTION TRIM(WS-NAME) "|" FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "x" TO WS-NAME
     MOVE 5 TO WS-INDEX
     CALL "ZIP-NAME" USING WS-ZIP WS-INDEX WS-NAME WS-NAME-LENGTH
     MOVE WS-NAME-LENGTH TO WS-E1
     MOVE SPACES TO WS-PATH
     STRING TL-OBSERVED DELIMITED BY SPACE "|" FUNCTION TRIM(WS-NAME) "|" FUNCTION TRIM(WS-E1)
         DELIMITED BY SIZE INTO WS-PATH
     MOVE WS-PATH TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Lookup by name.
     MOVE "assets/cobolcraft/lang/en_us.json" TO WS-NAME
     MOVE 33 TO WS-NAME-LENGTH
     PERFORM FIND-NAME
     MOVE "zip find assets/cobolcraft/lang/en_us.json is entry 3" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     PERFORM ASSERT-N
     MOVE "assets/" TO WS-NAME
     MOVE 7 TO WS-NAME-LENGTH
     PERFORM FIND-NAME
     MOVE "zip find the directory entry assets/ is entry 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     PERFORM ASSERT-N
     MOVE "pack.mcmeta" TO WS-NAME
     MOVE 10 TO WS-NAME-LENGTH
     PERFORM FIND-NAME
     MOVE "zip find a prefix of a name (pack.mcmet) is absent" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM ASSERT-N
     MOVE "pack.mcmetaa" TO WS-NAME
     MOVE 12 TO WS-NAME-LENGTH
     PERFORM FIND-NAME
     MOVE "zip find a longer name (pack.mcmetaa) is absent" TO TL-CASE
     PERFORM ASSERT-N
     MOVE "missing.json" TO WS-NAME
     MOVE 12 TO WS-NAME-LENGTH
     PERFORM FIND-NAME
     MOVE "zip find missing.json is absent" TO TL-CASE
     PERFORM ASSERT-N
     MOVE 0 TO WS-NAME-LENGTH
     PERFORM FIND-NAME
     MOVE "zip find an empty name is absent" TO TL-CASE
     PERFORM ASSERT-N
     MOVE 257 TO WS-NAME-LENGTH
     PERFORM FIND-NAME
     MOVE "zip find a name longer than 256 is absent" TO TL-CASE
     PERFORM ASSERT-N

*>   Uncompressed sizes.
     MOVE "zip sizes of entries 1 to 4 and of out-of-range entries 0 and 5" TO TL-CASE
     MOVE "53 0 3000 0 0 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-LINE-POS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE WS-I TO WS-INDEX
         IF WS-I = 5
             MOVE 0 TO WS-INDEX
         END-IF
         CALL "ZIP-SIZE" USING WS-ZIP WS-INDEX WS-SIZE
         MOVE WS-SIZE TO WS-E1
         STRING FUNCTION TRIM(WS-E1) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-LINE-POS
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Reading a stored entry.
     MOVE 1 TO WS-INDEX
     MOVE 4000 TO WS-CAPACITY
     PERFORM READ-ENTRY
     MOVE "zip read stored pack.mcmeta" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE '0 53 {"pack":{"pack_format":97,"description":"zip test"}}' TO TL-EXPECTED
     PERFORM SHOW-READ
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Reading a deflated entry (cc_inflate CC_RAW).
     MOVE 3 TO WS-INDEX
     PERFORM READ-ENTRY
     MOVE "zip read deflated en_us.json: status 0, length 3000" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0 3000" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-READ-STATUS TO WS-E1
     MOVE WS-LENGTH TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         MOVE WS-NUM(WS-I) TO WS-LINE-NUMBER
         COMPUTE WS-LINE-POS = (WS-LINE-NUMBER - 1) * 10 + 1
         MOVE SPACES TO TL-CASE TL-EXPECTED
         STRING "zip read deflated en_us.json line " WS-LINE-NUMBER DELIMITED BY SIZE INTO TL-CASE
         STRING "line " WS-LINE-NUMBER DELIMITED BY SIZE INTO TL-EXPECTED
         MOVE WS-AREA(WS-LINE-POS:10) TO WS-LINE
         MOVE WS-LINE(1:9) TO TL-OBSERVED
         IF WS-LINE(10:1) NOT = X"0A"
             MOVE "no newline" TO TL-OBSERVED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   Capacity too small, empty entries, out of range.
     MOVE 2999 TO WS-CAPACITY
     PERFORM READ-ENTRY
     MOVE "zip read deflated en_us.json with capacity 2999 is status 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-READ-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 52 TO WS-CAPACITY
     MOVE 1 TO WS-INDEX
     PERFORM READ-ENTRY
     MOVE "zip read stored pack.mcmeta with capacity 52 is status 5" TO TL-CASE
     MOVE WS-READ-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 0 TO WS-CAPACITY
     MOVE 4 TO WS-INDEX
     PERFORM READ-ENTRY
     MOVE "zip read the empty deflated empty.txt (capacity 0)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0 0" TO TL-EXPECTED
     PERFORM SHOW-READ
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-INDEX
     PERFORM READ-ENTRY
     MOVE "zip read the directory entry assets/" TO TL-CASE
     PERFORM SHOW-READ
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4000 TO WS-CAPACITY
     MOVE 0 TO WS-INDEX
     PERFORM READ-ENTRY
     MOVE "zip read entry 0 is status 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-READ-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-N
     MOVE 5 TO WS-INDEX
     PERFORM READ-ENTRY
     MOVE "zip read entry 5 of 4 is status 2" TO TL-CASE
     MOVE WS-READ-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-N
     CALL "ZIP-CLOSE" USING WS-ZIP

*>   An archive comment: the end of central directory record is found searching backwards.
     MOVE "comment" TO WS-FIXTURE
     PERFORM OPEN-FIXTURE
     MOVE "zip comment.zip (1000-byte archive comment) opens with 1 entry" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0 set 1" TO TL-EXPECTED
     PERFORM SHOW-OPEN-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-INDEX
     PERFORM READ-ENTRY
     MOVE "zip comment.zip read hello.txt" TO TL-CASE
     MOVE "0 15 hello, comment" TO TL-EXPECTED
     PERFORM SHOW-READ
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ZIP-CLOSE" USING WS-ZIP

*>   Names longer than 256 bytes are skipped; a 256-byte name is kept.
     MOVE "longname" TO WS-FIXTURE
     PERFORM OPEN-FIXTURE
     MOVE "zip longname.zip opens with 2 entries (the 300-byte name skipped)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0 set 2" TO TL-EXPECTED
     PERFORM SHOW-OPEN-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-INDEX
     CALL "ZIP-NAME" USING WS-ZIP WS-INDEX WS-NAME WS-NAME-LENGTH
     MOVE "zip longname.zip entry 1 is the 256-byte name" TO TL-CASE
     MOVE "256 nnnn .txt" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-NAME-LENGTH TO WS-E1
     STRING FUNCTION TRIM(WS-E1) " " WS-NAME(1:4) " " WS-NAME(253:4) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "short.txt" TO WS-NAME
     MOVE 9 TO WS-NAME-LENGTH
     PERFORM FIND-NAME
     MOVE "zip longname.zip find short.txt is entry 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     PERFORM ASSERT-N
     MOVE 2 TO WS-INDEX
     PERFORM READ-ENTRY
     MOVE "zip longname.zip read short.txt" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0 6 short" TO TL-EXPECTED
     PERFORM SHOW-READ
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ZIP-CLOSE" USING WS-ZIP

*>   Unsupported, encrypted, zip64 and damaged entries are reported as corrupt.
     MOVE "weird" TO WS-FIXTURE
     PERFORM OPEN-FIXTURE
     MOVE "zip weird.zip opens with 10 entries" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0 set 10" TO TL-EXPECTED
     PERFORM SHOW-OPEN-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "good.txt" TO WS-NAME
     MOVE 8 TO WS-NAME-LENGTH
     PERFORM FIND-NAME
     PERFORM READ-ENTRY
     MOVE "zip weird.zip read good.txt" TO TL-CASE
     MOVE "0 5 good" TO TL-EXPECTED
     PERFORM SHOW-READ
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE WS-BAD-NAME(WS-I) TO WS-NAME
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-BAD-NAME(WS-I))) TO WS-NAME-LENGTH
         PERFORM FIND-NAME
         PERFORM READ-ENTRY
         MOVE SPACES TO TL-CASE TL-OBSERVED
         STRING "zip weird.zip " FUNCTION TRIM(WS-BAD-NAME(WS-I)) " is found and reads as corrupt (status 2)"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE "found 2" TO TL-EXPECTED
         MOVE WS-READ-STATUS TO WS-E1
         STRING "found " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
         IF WS-INDEX = 0
             MOVE "absent" TO TL-OBSERVED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE "zip64.txt" TO WS-NAME
     MOVE 9 TO WS-NAME-LENGTH
     PERFORM FIND-NAME
     CALL "ZIP-SIZE" USING WS-ZIP WS-INDEX WS-SIZE
     MOVE "zip weird.zip zip64.txt (size 0xFFFFFFFF) reports size 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SIZE TO TL-OBSERVED-N
     PERFORM ASSERT-N
     CALL "ZIP-CLOSE" USING WS-ZIP
     STOP RUN.

 OPEN-FIXTURE.
     MOVE SPACES TO WS-PATH
     STRING "client/tests/fixtures/zips/" FUNCTION TRIM(WS-FIXTURE) ".zip" DELIMITED BY SIZE INTO WS-PATH
     PERFORM OPEN-PATH.

 OPEN-PATH.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH TRAILING)) TO WS-PATH-LENGTH
     SET WS-ZIP TO NULL
     MOVE -1 TO WS-STATUS
     CALL "ZIP-OPEN" USING WS-PATH WS-PATH-LENGTH WS-ZIP WS-STATUS.

 SHOW-OPEN.
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-STATUS TO WS-E1
     IF WS-ZIP = NULL
         STRING FUNCTION TRIM(WS-E1) " null" DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(WS-E1) " set" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF.

 SHOW-OPEN-COUNT.
     PERFORM SHOW-OPEN
     MOVE -1 TO WS-COUNT
     IF WS-ZIP NOT = NULL
         CALL "ZIP-COUNT" USING WS-ZIP WS-COUNT
     END-IF
     MOVE WS-COUNT TO WS-E1
     MOVE TL-OBSERVED TO WS-PATH
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-PATH) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED.

 ASSERT-OPEN-FAILED-1.
     MOVE "T" TO TL-MODE
     MOVE "1 null" TO TL-EXPECTED
     PERFORM SHOW-OPEN
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 SHOW-NAMES.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-LINE-POS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         MOVE WS-I TO WS-INDEX
         CALL "ZIP-NAME" USING WS-ZIP WS-INDEX WS-NAME WS-NAME-LENGTH
         MOVE WS-NAME-LENGTH TO WS-E1
         STRING WS-NAME(1:WS-NAME-LENGTH) " " FUNCTION TRIM(WS-E1) "|" DELIMITED BY SIZE
             INTO TL-OBSERVED WITH POINTER WS-LINE-POS
     END-PERFORM.

 FIND-NAME.
     MOVE -1 TO WS-INDEX
     CALL "ZIP-FIND" USING WS-ZIP WS-NAME WS-NAME-LENGTH WS-INDEX
     MOVE WS-INDEX TO TL-OBSERVED-N.

 READ-ENTRY.
     MOVE SPACES TO WS-AREA
     MOVE -1 TO WS-LENGTH WS-READ-STATUS
     CALL "ZIP-READ" USING WS-ZIP WS-INDEX WS-AREA WS-CAPACITY WS-LENGTH WS-READ-STATUS.

 SHOW-READ.
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-READ-STATUS TO WS-E1
     MOVE WS-LENGTH TO WS-E2
     IF WS-LENGTH > 0
         STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " WS-AREA(1:WS-LENGTH)
             DELIMITED BY SIZE INTO TL-OBSERVED
         INSPECT TL-OBSERVED REPLACING ALL X"0A" BY SPACE
     ELSE
         STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF.

 ASSERT-N.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ZIP.
