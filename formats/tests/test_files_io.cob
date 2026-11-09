*> Implementation test of formats/src/files.cob (FILE-READ-AT, FILE-WRITE, FILE-EXISTS; 22 §7.2): paths are
*> z-strings (a NUL ends one; a space-padded field works too; no end inside the 1100 bytes is
*> FM-PATH-LONG). FILE-EXISTS answers FM-OK for a file, FM-NOT-FOUND for nothing and FM-IS-DIR for a
*> directory. FILE-READ-AT reads up to the asked bytes at a byte offset (the length out is what was
*> read: fewer at the end of the file, 0 at or past it), a missing file is FM-NOT-FOUND, a directory or a
*> file that cannot be opened FM-UNREADABLE. FILE-WRITE creates or truncates a file and writes the bytes
*> (FM-UNREADABLE for a folder that is absent or not writable, FM-SHORT-WRITE when the disk takes fewer
*> bytes: made here by a file size limit of 512 bytes). Scratch files live under build/formats-test.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FILES-IO.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY FORMATS.
 01 WS-PATH                PIC X(1100).
 01 WS-AREA                PIC X(100).
 01 WS-BIG                 PIC X(8192).
 01 WS-OFFSET              BINARY-DOUBLE.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-SHOWN               PIC -(9)9.
 01 WS-SHOWN2              PIC -(9)9.
 01 WS-SHOWN3              PIC -(9)9.
*> struct rlimit: the soft and the hard limit.
 01 WS-LIMIT.
    05 WS-LIMIT-SOFT       BINARY-DOUBLE UNSIGNED.
    05 WS-LIMIT-HARD       BINARY-DOUBLE UNSIGNED.
 01 WS-SAVED.
    05 WS-SAVED-SOFT       BINARY-DOUBLE UNSIGNED.
    05 WS-SAVED-HARD       BINARY-DOUBLE UNSIGNED.
 01 WS-IGNORE              BINARY-DOUBLE VALUE 1.
 01 WS-RESOURCE            BINARY-LONG VALUE 1.
 01 WS-SIGNAL              BINARY-LONG VALUE 25.
 01 WS-RC                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "mkdir -p build/formats-test && rm -rf build/formats-test/io && mkdir build/formats-test/io"
     MOVE "N" TO TL-MODE

*>   FILE-EXISTS.
     MOVE LOW-VALUES TO WS-PATH
     MOVE "contract/fixtures/formats/hello.txt" TO WS-PATH
     CALL "FILE-EXISTS" USING WS-PATH WS-STATUS
     MOVE "files io FILE-EXISTS of a file is FM-OK" TO TL-CASE
     MOVE FM-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE SPACES TO WS-PATH
     MOVE "contract/fixtures/formats/hello.txt" TO WS-PATH
     CALL "FILE-EXISTS" USING WS-PATH WS-STATUS
     MOVE "files io FILE-EXISTS takes a space-padded path too" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE ALL "x" TO WS-PATH
     MOVE "contract/fixtures/formats/hello.txt" TO WS-PATH(1:35)
     MOVE X"00" TO WS-PATH(36:1)
     CALL "FILE-EXISTS" USING WS-PATH WS-STATUS
     MOVE "files io FILE-EXISTS stops at the NUL of a z-string (the bytes after it are not read)" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE LOW-VALUES TO WS-PATH
     MOVE "contract/fixtures/formats/absent.txt" TO WS-PATH
     CALL "FILE-EXISTS" USING WS-PATH WS-STATUS
     MOVE "files io FILE-EXISTS of nothing is FM-NOT-FOUND" TO TL-CASE
     MOVE FM-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE LOW-VALUES TO WS-PATH
     MOVE "contract/fixtures/formats" TO WS-PATH
     CALL "FILE-EXISTS" USING WS-PATH WS-STATUS
     MOVE "files io FILE-EXISTS of a directory is FM-IS-DIR" TO TL-CASE
     MOVE FM-IS-DIR TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE ALL "a" TO WS-PATH
     CALL "FILE-EXISTS" USING WS-PATH WS-STATUS
     MOVE "files io FILE-EXISTS of a path with no end in 1100 bytes is FM-PATH-LONG" TO TL-CASE
     MOVE FM-PATH-LONG TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE LOW-VALUES TO WS-PATH
     CALL "FILE-EXISTS" USING WS-PATH WS-STATUS
     MOVE "files io FILE-EXISTS of the empty path is FM-NOT-FOUND" TO TL-CASE
     MOVE FM-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

*>   FILE-READ-AT of hello.txt ("hello fixture", 14 bytes).
     MOVE LOW-VALUES TO WS-PATH
     MOVE "contract/fixtures/formats/hello.txt" TO WS-PATH
     MOVE 0 TO WS-OFFSET
     MOVE 5 TO WS-LENGTH
     MOVE SPACES TO WS-AREA
     CALL "FILE-READ-AT" USING WS-PATH WS-OFFSET WS-AREA WS-LENGTH WS-STATUS
     MOVE "files io read 5 bytes at offset 0: status 0, 5 bytes, hello" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0 5 hello|" TO TL-EXPECTED
     PERFORM SHOW-READ
     MOVE "N" TO TL-MODE
     MOVE 6 TO WS-OFFSET
     MOVE 7 TO WS-LENGTH
     MOVE SPACES TO WS-AREA
     CALL "FILE-READ-AT" USING WS-PATH WS-OFFSET WS-AREA WS-LENGTH WS-STATUS
     MOVE "files io read 7 bytes at offset 6: fixture" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0 7 fixture|" TO TL-EXPECTED
     PERFORM SHOW-READ
     MOVE 11 TO WS-OFFSET
     MOVE 100 TO WS-LENGTH
     MOVE SPACES TO WS-AREA
     CALL "FILE-READ-AT" USING WS-PATH WS-OFFSET WS-AREA WS-LENGTH WS-STATUS
     MOVE "files io read 100 bytes at offset 11 of 14: only 3 are there (status 0, length 3, bytes re)"
         TO TL-CASE
     MOVE "0 3 re" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-STATUS TO WS-SHOWN
     MOVE WS-LENGTH TO WS-SHOWN2
     STRING FUNCTION TRIM(WS-SHOWN) " " FUNCTION TRIM(WS-SHOWN2) " " WS-AREA(1:2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 14 TO WS-OFFSET
     MOVE 10 TO WS-LENGTH
     CALL "FILE-READ-AT" USING WS-PATH WS-OFFSET WS-AREA WS-LENGTH WS-STATUS
     MOVE "files io read at the end of the file: status 0, length 0" TO TL-CASE
     MOVE "0 0 |" TO TL-EXPECTED
     MOVE SPACES TO WS-AREA
     PERFORM SHOW-READ
     MOVE 5000000000 TO WS-OFFSET
     MOVE 10 TO WS-LENGTH
     CALL "FILE-READ-AT" USING WS-PATH WS-OFFSET WS-AREA WS-LENGTH WS-STATUS
     MOVE "files io read at offset 5000000000 past the end: status 0, length 0" TO TL-CASE
     PERFORM SHOW-READ
     MOVE 0 TO WS-OFFSET
     MOVE 0 TO WS-LENGTH
     CALL "FILE-READ-AT" USING WS-PATH WS-OFFSET WS-AREA WS-LENGTH WS-STATUS
     MOVE "files io read of 0 bytes: status 0, length 0" TO TL-CASE
     PERFORM SHOW-READ
     MOVE "contract/fixtures/formats/absent.txt" TO WS-PATH
     MOVE 0 TO WS-OFFSET
     MOVE 10 TO WS-LENGTH
     CALL "FILE-READ-AT" USING WS-PATH WS-OFFSET WS-AREA WS-LENGTH WS-STATUS
     MOVE "files io read of a missing file: FM-NOT-FOUND, length 0" TO TL-CASE
     MOVE "2 0 |" TO TL-EXPECTED
     PERFORM SHOW-READ
     MOVE LOW-VALUES TO WS-PATH
     MOVE "contract/fixtures/formats" TO WS-PATH
     MOVE 10 TO WS-LENGTH
     CALL "FILE-READ-AT" USING WS-PATH WS-OFFSET WS-AREA WS-LENGTH WS-STATUS
     MOVE "files io read of a directory: FM-UNREADABLE, length 0" TO TL-CASE
     MOVE "1 0 |" TO TL-EXPECTED
     PERFORM SHOW-READ
     MOVE ALL "a" TO WS-PATH
     MOVE 10 TO WS-LENGTH
     CALL "FILE-READ-AT" USING WS-PATH WS-OFFSET WS-AREA WS-LENGTH WS-STATUS
     MOVE "files io read of a path with no end: FM-PATH-LONG, length 0" TO TL-CASE
     MOVE "6 0 |" TO TL-EXPECTED
     PERFORM SHOW-READ
     CALL "SYSTEM" USING "echo x > build/formats-test/io/locked.txt && chmod 000 build/formats-test/io/locked.txt"
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/io/locked.txt" TO WS-PATH
     MOVE 1 TO WS-LENGTH
     CALL "FILE-READ-AT" USING WS-PATH WS-OFFSET WS-AREA WS-LENGTH WS-STATUS
     MOVE "files io read of a file that cannot be opened: FM-UNREADABLE, length 0" TO TL-CASE
     MOVE "1 0 |" TO TL-EXPECTED
     PERFORM SHOW-READ
     CALL "SYSTEM" USING "chmod 600 build/formats-test/io/locked.txt"

*>   FILE-WRITE, read back with FILE-READ-AT.
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/io/out.bin" TO WS-PATH
     MOVE "12345" TO WS-AREA
     MOVE 5 TO WS-LENGTH
     CALL "FILE-WRITE" USING WS-PATH WS-AREA WS-LENGTH WS-STATUS
     MOVE "files io write 5 bytes: FM-OK" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE FM-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE 0 TO WS-OFFSET
     MOVE 100 TO WS-LENGTH
     MOVE SPACES TO WS-AREA
     CALL "FILE-READ-AT" USING WS-PATH WS-OFFSET WS-AREA WS-LENGTH WS-STATUS
     MOVE "files io the file written has the 5 bytes" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0 5 12345|" TO TL-EXPECTED
     PERFORM SHOW-READ
     MOVE "abc" TO WS-AREA
     MOVE 3 TO WS-LENGTH
     CALL "FILE-WRITE" USING WS-PATH WS-AREA WS-LENGTH WS-STATUS
     MOVE 0 TO WS-OFFSET
     MOVE 100 TO WS-LENGTH
     MOVE SPACES TO WS-AREA
     CALL "FILE-READ-AT" USING WS-PATH WS-OFFSET WS-AREA WS-LENGTH WS-STATUS
     MOVE "files io a second write truncates: 3 bytes abc" TO TL-CASE
     MOVE "0 3 abc|" TO TL-EXPECTED
     PERFORM SHOW-READ
     MOVE 0 TO WS-LENGTH
     CALL "FILE-WRITE" USING WS-PATH WS-AREA WS-LENGTH WS-STATUS
     MOVE "files io write of 0 bytes: FM-OK" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE FM-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     CALL "FILE-EXISTS" USING WS-PATH WS-STATUS
     MOVE "files io the file of 0 bytes exists" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE 0 TO WS-OFFSET
     MOVE 100 TO WS-LENGTH
     CALL "FILE-READ-AT" USING WS-PATH WS-OFFSET WS-AREA WS-LENGTH WS-STATUS
     MOVE "files io the file of 0 bytes reads 0 bytes" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0 0 |" TO TL-EXPECTED
     MOVE SPACES TO WS-AREA
     PERFORM SHOW-READ
     MOVE "N" TO TL-MODE

*>   FILE-WRITE failures.
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/io/absent-folder/x.bin" TO WS-PATH
     MOVE 3 TO WS-LENGTH
     CALL "FILE-WRITE" USING WS-PATH WS-AREA WS-LENGTH WS-STATUS
     MOVE "files io write into a folder that is absent: FM-UNREADABLE" TO TL-CASE
     MOVE FM-UNREADABLE TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     CALL "SYSTEM" USING "mkdir -p build/formats-test/io/readonly && chmod 555 build/formats-test/io/readonly"
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/io/readonly/x.bin" TO WS-PATH
     CALL "FILE-WRITE" USING WS-PATH WS-AREA WS-LENGTH WS-STATUS
     MOVE "files io write into a folder that is not writable: FM-UNREADABLE" TO TL-CASE
     PERFORM ASSERT-STATUS
     CALL "SYSTEM" USING "chmod 755 build/formats-test/io/readonly"
     MOVE ALL "a" TO WS-PATH
     CALL "FILE-WRITE" USING WS-PATH WS-AREA WS-LENGTH WS-STATUS
     MOVE "files io write to a path with no end: FM-PATH-LONG" TO TL-CASE
     MOVE FM-PATH-LONG TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

*>   A disk that takes fewer bytes: the process may write 512 bytes of a file at most (SIGXFSZ ignored).
     MOVE ALL "z" TO WS-BIG
     MOVE LOW-VALUES TO WS-PATH
     MOVE "build/formats-test/io/short.bin" TO WS-PATH
     CALL STATIC "signal" USING BY VALUE WS-SIGNAL BY VALUE WS-IGNORE RETURNING WS-RC
     CALL STATIC "getrlimit" USING BY VALUE WS-RESOURCE BY REFERENCE WS-SAVED RETURNING WS-RC
     MOVE WS-SAVED TO WS-LIMIT
     MOVE 512 TO WS-LIMIT-SOFT
     CALL STATIC "setrlimit" USING BY VALUE WS-RESOURCE BY REFERENCE WS-LIMIT RETURNING WS-RC
     MOVE 8192 TO WS-LENGTH
     CALL "FILE-WRITE" USING WS-PATH WS-BIG WS-LENGTH WS-STATUS
     CALL STATIC "setrlimit" USING BY VALUE WS-RESOURCE BY REFERENCE WS-SAVED RETURNING WS-RC
     MOVE "files io write of 8192 bytes under a limit of 512: FM-SHORT-WRITE" TO TL-CASE
     MOVE FM-SHORT-WRITE TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     STOP RUN.

 ASSERT-STATUS.
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> "<status> <length> <bytes read>|" against TL-EXPECTED.
 SHOW-READ.
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-STATUS TO WS-SHOWN
     MOVE WS-LENGTH TO WS-SHOWN2
     IF WS-LENGTH > 0
         STRING FUNCTION TRIM(WS-SHOWN) " " FUNCTION TRIM(WS-SHOWN2) " " WS-AREA(1:WS-LENGTH) "|"
             DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         STRING FUNCTION TRIM(WS-SHOWN) " " FUNCTION TRIM(WS-SHOWN2) " |" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-FILES-IO.
