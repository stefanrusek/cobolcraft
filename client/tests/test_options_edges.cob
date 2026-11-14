*> Implementation test of the edges of client/src/options.cob (13 §7.1): a value with a letter or too long is refused; pack lists that are
*> not JSON string arrays (no quote, no closing quote, a stray character, an unterminated list) change nothing; an incompatible list
*> that is no list is refused; version, resourcePacks and incompatibleResourcePacks read back; a line ending in a carriage return is
*> read; a game directory that cannot be written to gives one ERROR line and the game goes on.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-OPTIONS-EDGES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY TESTLIB.
 01 WS-NAME                PIC X(40).
 01 WS-BIG                 PIC X(4096).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-VALUE               PIC X(64).
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FULL                PIC X(1100) VALUE "contract/fixtures/client/options-full.txt".
 01 WS-FULL-LENGTH         BINARY-LONG VALUE 42.
 01 WS-CAPTURE             PIC X(256) VALUE "build/client-test-options-edges.out".
 01 WS-CAPTURED            PIC X(4096).
 01 WS-D1                  PIC 9.
 01 WS-CASES.
    05 FILLER PIC X(40) VALUE "[abc]".
    05 FILLER PIC X(40) VALUE '["abc]'.
    05 FILLER PIC X(40) VALUE '["a"x]'.
    05 FILLER PIC X(40) VALUE '["a",]'.
    05 FILLER PIC X(40) VALUE '["a"'.
    05 FILLER PIC X(40) VALUE '"a"'.
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE             PIC X(40) OCCURS 6 TIMES.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "OPTIONS-DEFAULTS" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
     MOVE "renderDistance" TO WS-NAME
     MOVE "12a" TO WS-BIG
     MOVE 3 TO WS-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-NAME WS-BIG WS-LENGTH WS-OK
     MOVE "options edges: a number with a letter is refused" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "12345678901" TO WS-BIG
     MOVE 11 TO WS-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-NAME WS-BIG WS-LENGTH WS-OK
     MOVE "options edges: a number of 11 characters is refused" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE "resourcePacks" TO WS-NAME
         MOVE SPACES TO WS-BIG
         MOVE WS-CASE(WS-I) TO WS-BIG
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-CASE(WS-I))) TO WS-LENGTH
         MOVE 1 TO OP-COUNT
         MOVE "keep" TO OP-ID(1)
         MOVE 4 TO OP-ID-LENGTH(1)
         CALL "OPTIONS-SET" USING CLIENT-STATE WS-NAME WS-BIG WS-LENGTH WS-OK
         MOVE WS-I TO WS-D1
         MOVE SPACES TO TL-CASE
         STRING "options edges: the pack list " FUNCTION TRIM(WS-CASE(WS-I)) " (case " WS-D1 ") changes nothing"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         COMPUTE TL-OBSERVED-N = 1 - WS-OK + OP-COUNT - 1
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE "incompatibleResourcePacks" TO WS-NAME
     MOVE "[x]" TO WS-BIG
     MOVE 3 TO WS-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-NAME WS-BIG WS-LENGTH WS-OK
     MOVE "options edges: an incompatible list that is no list is refused" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "OPTIONS-DEFAULTS" USING CLIENT-STATE
     CALL "OPTIONS-READ" USING CLIENT-STATE WS-FULL WS-FULL-LENGTH WS-FOUND
     MOVE "T" TO TL-MODE
     MOVE "version" TO WS-NAME
     CALL "OPTIONS-GET" USING CLIENT-STATE WS-NAME WS-VALUE WS-VALUE-LENGTH WS-FOUND
     MOVE "options edges: version reads 5023" TO TL-CASE
     MOVE "5023" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "resourcePacks" TO WS-NAME
     CALL "OPTIONS-GET" USING CLIENT-STATE WS-NAME WS-VALUE WS-VALUE-LENGTH WS-FOUND
     MOVE "options edges: resourcePacks reads back lowest first" TO TL-CASE
     MOVE '["vanilla","file/Faithful 32x - 26.3.zip"]' TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "incompatibleResourcePacks" TO WS-NAME
     CALL "OPTIONS-GET" USING CLIENT-STATE WS-NAME WS-VALUE WS-VALUE-LENGTH WS-FOUND
     MOVE "options edges: incompatibleResourcePacks reads back" TO TL-CASE
     MOVE '["file/Old Pack.zip"]' TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "nosuchoption" TO WS-NAME
     CALL "OPTIONS-GET" USING CLIENT-STATE WS-NAME WS-VALUE WS-VALUE-LENGTH WS-FOUND
     MOVE "options edges: an unknown option is not found" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-BIG
     STRING "renderDistance:20" X"0D" DELIMITED BY SIZE INTO WS-BIG
     MOVE 18 TO WS-LENGTH
     CALL "OPTIONS-LINE" USING CLIENT-STATE WS-BIG WS-LENGTH
     MOVE "renderDistance" TO WS-NAME
     CALL "OPTIONS-GET" USING CLIENT-STATE WS-NAME WS-VALUE WS-VALUE-LENGTH WS-FOUND
     MOVE "options edges: a line ending in a carriage return is read" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "20" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "no/such/directory" TO CL-GAME-DIR
     MOVE 17 TO CL-GAME-DIR-LENGTH
     CALL "TEST-CAPTURE-START" USING WS-CAPTURE
     CALL "OPTIONS-SAVE" USING CLIENT-STATE
     CALL "TEST-CAPTURE-STOP" USING WS-CAPTURE WS-CAPTURED
     MOVE "options edges: a game directory that cannot be written gives one ERROR line" TO TL-CASE
     MOVE "ERROR options: cannot write options.txt" TO TL-EXPECTED
     MOVE WS-CAPTURED TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-OPTIONS-EDGES.

 COPY OPTTEST.
 COPY CLTEST.
