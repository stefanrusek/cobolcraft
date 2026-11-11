*> Edge-case test (spec edge case): a game directory with no options.txt (and no options.dat) gives every default, no pack
*> enabled, and the game starts (CL-START builds the pack stack with the built-in pack only).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-OPTIONS-MISSING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-options-missing".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 33.
 01 WS-NAME                PIC X(40).
 01 WS-VALUE               PIC X(64).
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "rm -rf build/client-test-options-missing && mkdir -p build/client-test-options-missing"
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "Alice" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH
     MOVE WS-DIR TO CL-GAME-DIR
     MOVE WS-DIR-LENGTH TO CL-GAME-DIR-LENGTH
     CALL "CL-START" USING CLIENT-STATE
     MOVE "renderDistance" TO WS-NAME
     CALL "OPTIONS-GET" USING CLIENT-STATE WS-NAME WS-VALUE WS-VALUE-LENGTH WS-FOUND
     MOVE "options missing: no options.txt gives the default render distance 12" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "12" TO TL-EXPECTED
     MOVE WS-VALUE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "options missing: no pack is enabled and the stack is the built-in pack alone (the game started)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PK-COUNT + OP-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-OPTIONS-MISSING.

 COPY CLTEST.
