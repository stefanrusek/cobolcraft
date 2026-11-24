*> Implementation test of client/src/options.cob (OPTIONS-DEFAULTS, OPTIONS-READ, OPTIONS-WRITE, OPTIONS-GET; 13 §7.1, §7.2;
*> SC-009): the defaults are written as contract/fixtures/client/options-default.txt; the full fixture is read option by option (every
*> one of the 160 table options, in its stored form) and written back as the same bytes; the pack lists are read top first.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-OPTIONS-FILE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLOPTS.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-options".
 01 WS-FULL                PIC X(256) VALUE "contract/fixtures/client/options-full.txt".
 01 WS-DEFAULT             PIC X(256) VALUE "contract/fixtures/client/options-default.txt".
 01 WS-OUT                 PIC X(256) VALUE "build/client-test-options/out.txt".
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-TEXT                PIC X(16384).
 01 WS-CAPACITY            BINARY-LONG VALUE 16384.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-EXPECTED            PIC X(64).
 01 WS-VALUE               PIC X(64).
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 01 WS-D1                  PIC 9.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "rm -rf build/client-test-options && mkdir -p build/client-test-options"
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
     CALL "OPTIONS-DEFAULTS" USING CLIENT-STATE
     MOVE SPACES TO WS-PATH
     MOVE WS-OUT TO WS-PATH
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-OUT)) TO WS-PATH-LENGTH
     CALL "OPTIONS-WRITE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-OK
     CALL "TEST-OPT-SAME" USING WS-OUT WS-DEFAULT WS-SAME
     MOVE "options file the defaults are written as options-default.txt, byte for byte" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-SAME * WS-OK
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-PATH
     MOVE WS-FULL TO WS-PATH
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-FULL)) TO WS-PATH-LENGTH
     CALL "OPTIONS-READ" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-FOUND
     MOVE "options file the full fixture is read" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-READ-FILE" USING WS-FULL WS-TEXT WS-CAPACITY WS-LENGTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > OT-COUNT
         MOVE OT-NAME(WS-I) TO WS-NAME
         CALL "TEST-OPT-LINE" USING WS-TEXT WS-LENGTH WS-NAME WS-EXPECTED WS-FOUND
         CALL "OPTIONS-GET" USING CLIENT-STATE WS-NAME WS-VALUE WS-VALUE-LENGTH WS-FOUND
         MOVE "T" TO TL-MODE
         MOVE SPACES TO TL-CASE
         STRING "options file full fixture: " FUNCTION TRIM(WS-NAME) " has the stored value of the file"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-EXPECTED TO TL-EXPECTED
         MOVE WS-VALUE TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE "N" TO TL-MODE

     MOVE SPACES TO WS-PATH
     MOVE WS-OUT TO WS-PATH
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-OUT)) TO WS-PATH-LENGTH
     CALL "OPTIONS-WRITE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-OK
     CALL "TEST-OPT-SAME" USING WS-OUT WS-FULL WS-SAME
     MOVE "options file the full fixture is written back byte for byte" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-SAME * WS-OK
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "options file resourcePacks: two packs, top first (the file lists the lowest first)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "2 file/Faithful 32x - 26.3.zip vanilla" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE OP-COUNT TO WS-D1
     STRING WS-D1 " " OP-ID(1)(1:OP-ID-LENGTH(1)) " " OP-ID(2)(1:OP-ID-LENGTH(2)) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-OPTIONS-FILE.

 COPY OPTTEST.
 COPY CLTEST.
