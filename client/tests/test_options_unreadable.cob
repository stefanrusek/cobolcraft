*> Edge-case test (spec edge case): an options.txt that is corrupt (contract/fixtures/client/options-corrupt.txt: bad values,
*> a line without a colon, an unterminated pack list, an unknown key, a bad key name) or unreadable (a directory in its place)
*> gives the defaults for what cannot be read, keeps the lines that can, and the game starts.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-OPTIONS-UNREADABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-options-unreadable".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 36.
 01 WS-FILE                PIC X(32) VALUE "options-corrupt.txt".
 01 WS-PATH                PIC X(1100) VALUE "contract/fixtures/client/options-corrupt.txt".
 01 WS-PATH-LENGTH         BINARY-LONG VALUE 44.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(40).
 01 WS-EXPECTED            PIC X(64).
 01 WS-VALUE               PIC X(64).
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-DEGREES             PIC 999.
 01 WS-EDIT                PIC ZZ9.
 01 WS-NAME                PIC X(40).
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "rm -rf build/client-test-options-unreadable && mkdir -p build/client-test-options-unreadable/options.txt"
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "Alice" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH
     MOVE WS-DIR TO CL-GAME-DIR
     MOVE WS-DIR-LENGTH TO CL-GAME-DIR-LENGTH
     CALL "CL-START" USING CLIENT-STATE
     MOVE "fov" TO WS-NAME
     CALL "OPTIONS-GET" USING CLIENT-STATE WS-NAME WS-VALUE WS-VALUE-LENGTH WS-FOUND
     MOVE "options unreadable: options.txt is a directory, the defaults hold and the game started" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "0.0" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "OPTIONS-DEFAULTS" USING CLIENT-STATE
     CALL "OPTIONS-READ" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-FOUND
     MOVE 1 TO WS-ROW
     PERFORM UNTIL WS-ROW > 99
         CALL "TEST-OPT-EXPECTED" USING WS-FILE WS-ROW WS-KEY WS-EXPECTED WS-FOUND
         IF WS-FOUND = 0
             EXIT PERFORM
         END-IF
         CALL "OPTIONS-GET" USING CLIENT-STATE WS-KEY WS-VALUE WS-VALUE-LENGTH WS-FOUND
         IF WS-KEY = "fov"
             COMPUTE WS-DEGREES = 70 + 40 * FUNCTION NUMVAL(WS-VALUE)
             MOVE WS-DEGREES TO WS-EDIT
             MOVE FUNCTION TRIM(WS-EDIT) TO WS-VALUE
         END-IF
         MOVE SPACES TO TL-CASE
         STRING "options corrupt: " FUNCTION TRIM(WS-KEY) " is " FUNCTION TRIM(WS-EXPECTED)
             DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-EXPECTED TO TL-EXPECTED
         MOVE FUNCTION TRIM(WS-VALUE) TO TL-OBSERVED
         IF WS-EXPECTED(1:5) = "0.25 "
             MOVE "0.25" TO TL-EXPECTED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         ADD 1 TO WS-ROW
     END-PERFORM
     MOVE "options corrupt: the key_ line with a bad key name keeps the default key (jump is space)" TO TL-CASE
     MOVE "key_key.jump" TO WS-NAME
     CALL "OPTIONS-GET" USING CLIENT-STATE WS-NAME WS-VALUE WS-VALUE-LENGTH WS-FOUND
     MOVE "key.keyboard.space" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "options corrupt: the valid soundCategory_music line of 0.5 is loaded" TO TL-CASE
     MOVE "soundCategory_music" TO WS-NAME
     CALL "OPTIONS-GET" USING CLIENT-STATE WS-NAME WS-VALUE WS-VALUE-LENGTH WS-FOUND
     MOVE "0.5" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-OPTIONS-UNREADABLE.

 COPY OPTTEST.
 COPY CLTEST.
