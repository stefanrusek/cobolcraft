*> Implementation test of formats/src/files.cob (FILE-READ-ALL): a whole file into an area (status 0
*> and its length), a missing file (status 1), a file larger than the capacity (status 5 with the
*> size set, nothing read) and a file that exists but cannot be opened (status 1, length 0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FILES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-AREA                PIC X(64).
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-SHOWN               PIC -(9)9.
 01 WS-STATUS-D            PIC 9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-PATH
     MOVE "contract/fixtures/formats/hello.txt" TO WS-PATH
     MOVE 35 TO WS-PATH-LENGTH
     MOVE SPACES TO WS-AREA
     MOVE 64 TO WS-CAPACITY
     CALL "FILE-READ-ALL" USING WS-PATH WS-PATH-LENGTH WS-AREA WS-CAPACITY WS-LENGTH WS-STATUS
     MOVE "files a readable file is read whole (status 0, 14 bytes)" TO TL-CASE
     MOVE "0 14 hello fixture" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-LENGTH TO WS-SHOWN
     MOVE WS-STATUS TO WS-STATUS-D
     STRING WS-STATUS-D " " FUNCTION TRIM(WS-SHOWN) " " WS-AREA(1:13) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 14 TO WS-CAPACITY
     CALL "FILE-READ-ALL" USING WS-PATH WS-PATH-LENGTH WS-AREA WS-CAPACITY WS-LENGTH WS-STATUS
     MOVE "files a capacity equal to the size reads the file" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 13 TO WS-CAPACITY
     MOVE SPACES TO WS-AREA
     CALL "FILE-READ-ALL" USING WS-PATH WS-PATH-LENGTH WS-AREA WS-CAPACITY WS-LENGTH WS-STATUS
     MOVE "files a file larger than the capacity is status 5 with its size set, nothing read"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "5 14 blank" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-LENGTH TO WS-SHOWN
     MOVE WS-STATUS TO WS-STATUS-D
     IF WS-AREA = SPACES
         STRING WS-STATUS-D " " FUNCTION TRIM(WS-SHOWN) " blank" DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         STRING WS-STATUS-D " " FUNCTION TRIM(WS-SHOWN) " written" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-PATH
     MOVE "contract/fixtures/formats/absent.txt" TO WS-PATH
     MOVE 36 TO WS-PATH-LENGTH
     MOVE 64 TO WS-CAPACITY
     MOVE 9 TO WS-LENGTH
     CALL "FILE-READ-ALL" USING WS-PATH WS-PATH-LENGTH WS-AREA WS-CAPACITY WS-LENGTH WS-STATUS
     MOVE "files a missing file is status 1 with length 0" TO TL-CASE
     MOVE "1 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-LENGTH TO WS-SHOWN
     MOVE WS-STATUS TO WS-STATUS-D
     STRING WS-STATUS-D " " FUNCTION TRIM(WS-SHOWN) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A file that exists but cannot be opened (mode 000).
     CALL "SYSTEM" USING "mkdir -p build/formats-test && echo x > build/formats-test/locked.txt"
     CALL "SYSTEM" USING "chmod 000 build/formats-test/locked.txt"
     MOVE SPACES TO WS-PATH
     MOVE "build/formats-test/locked.txt" TO WS-PATH
     MOVE 29 TO WS-PATH-LENGTH
     MOVE 9 TO WS-LENGTH
     CALL "FILE-READ-ALL" USING WS-PATH WS-PATH-LENGTH WS-AREA WS-CAPACITY WS-LENGTH WS-STATUS
     MOVE "files a file that cannot be opened is status 1 with length 0" TO TL-CASE
     MOVE "1 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-LENGTH TO WS-SHOWN
     MOVE WS-STATUS TO WS-STATUS-D
     STRING WS-STATUS-D " " FUNCTION TRIM(WS-SHOWN) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SYSTEM" USING "chmod 600 build/formats-test/locked.txt"
     STOP RUN.
 END PROGRAM TEST-FILES.
