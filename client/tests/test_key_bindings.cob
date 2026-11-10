*> Implementation test of the key table (13 §7.3; OPTIONS-APPLY, controls and screens): the defaults of the 22 bindings the client reads
*> are the GLFW codes of the table; a rebinding read from options.txt takes the place of the default (inventory on I opens the
*> inventory, E no longer does; chat on B) and is persisted in options.txt (key_key.inventory:key.keyboard.i); a mouse button
*> binding is no keyboard key (code 0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-KEY-BINDINGS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-EXPECTED-CODES.
    05 FILLER PIC 9(3) VALUE 87.
    05 FILLER PIC 9(3) VALUE 65.
    05 FILLER PIC 9(3) VALUE 83.
    05 FILLER PIC 9(3) VALUE 68.
    05 FILLER PIC 9(3) VALUE 32.
    05 FILLER PIC 9(3) VALUE 340.
    05 FILLER PIC 9(3) VALUE 341.
    05 FILLER PIC 9(3) VALUE 69.
    05 FILLER PIC 9(3) VALUE 70.
    05 FILLER PIC 9(3) VALUE 81.
    05 FILLER PIC 9(3) VALUE 49.
    05 FILLER PIC 9(3) VALUE 50.
    05 FILLER PIC 9(3) VALUE 51.
    05 FILLER PIC 9(3) VALUE 52.
    05 FILLER PIC 9(3) VALUE 53.
    05 FILLER PIC 9(3) VALUE 54.
    05 FILLER PIC 9(3) VALUE 55.
    05 FILLER PIC 9(3) VALUE 56.
    05 FILLER PIC 9(3) VALUE 57.
    05 FILLER PIC 9(3) VALUE 84.
    05 FILLER PIC 9(3) VALUE 47.
    05 FILLER PIC 9(3) VALUE 294.
 01 WS-TABLE REDEFINES WS-EXPECTED-CODES.
    05 WS-CODE             PIC 9(3) OCCURS 22 TIMES.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-key-bindings".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 30.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-BIG                 PIC X(4096).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-SCREEN              BINARY-LONG.
 01 WS-PATH                PIC X(256) VALUE "build/client-test-key-bindings/options.txt".
 01 WS-TEXT                PIC X(16384).
 01 WS-CAPACITY            BINARY-LONG VALUE 16384.
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(64).
 01 WS-FOUND               BINARY-LONG.
 01 WS-D2                  PIC 99.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "rm -rf build/client-test-key-bindings && mkdir -p build/client-test-key-bindings"
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > KB-COUNT
         MOVE SPACES TO TL-CASE
         MOVE WS-I TO WS-D2
         STRING "key bindings default binding " WS-D2 " is the GLFW code of 13 7.3" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-CODE(WS-I) TO TL-EXPECTED-N
         MOVE KB-CODE(WS-I) TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   Rebinding: inventory to I, chat to B, the attack-like mouse button to nothing on the keyboard.
     MOVE "key_key.inventory" TO WS-NAME
     MOVE "key.keyboard.i" TO WS-BIG
     MOVE 14 TO WS-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-NAME WS-BIG WS-LENGTH WS-OK
     MOVE "key_key.chat" TO WS-NAME
     MOVE "key.mouse.4" TO WS-BIG
     MOVE 11 TO WS-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-NAME WS-BIG WS-LENGTH WS-OK
     CALL "OPTIONS-APPLY" USING CLIENT-STATE
     MOVE "key bindings a mouse button binding is no keyboard key (code 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE KB-CODE(KB-CHAT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "key bindings the inventory key is I (73)" TO TL-CASE
     MOVE 73 TO TL-EXPECTED-N
     MOVE KB-CODE(KB-INVENTORY) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SCR-WORLD TO SM-SCREEN
     MOVE 1 TO IN-KEY-PRESSED(CC-KEY-E + 1)
     CALL "SCREEN-INPUT" USING CLIENT-STATE
     MOVE 0 TO IN-KEY-PRESSED(CC-KEY-E + 1)
     MOVE "key bindings with inventory on I, E does not open the inventory" TO TL-CASE
     MOVE SCR-WORLD TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO IN-KEY-PRESSED(CC-KEY-I + 1)
     CALL "SCREEN-INPUT" USING CLIENT-STATE
     MOVE 0 TO IN-KEY-PRESSED(CC-KEY-I + 1)
     MOVE "key bindings with inventory on I, I opens the inventory" TO TL-CASE
     MOVE SCR-INVENTORY TO TL-EXPECTED-N
     MOVE SM-SCREEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Persisted: options.txt holds the key name; a restart gives the binding back.
     MOVE "key_key.inventory" TO WS-NAME
     MOVE "Alice" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH
     MOVE WS-DIR TO CL-GAME-DIR
     MOVE WS-DIR-LENGTH TO CL-GAME-DIR-LENGTH
     CALL "OPTIONS-SAVE" USING CLIENT-STATE
     CALL "TEST-READ-FILE" USING WS-PATH WS-TEXT WS-CAPACITY WS-TEXT-LENGTH
     CALL "TEST-OPT-LINE" USING WS-TEXT WS-TEXT-LENGTH WS-NAME WS-LINE WS-FOUND
     MOVE "key bindings options.txt holds key_key.inventory:key.keyboard.i" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "key.keyboard.i" TO TL-EXPECTED
     MOVE WS-LINE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE WS-DIR TO CL-GAME-DIR
     MOVE WS-DIR-LENGTH TO CL-GAME-DIR-LENGTH
     CALL "OPTIONS-LOAD" USING CLIENT-STATE
     CALL "OPTIONS-APPLY" USING CLIENT-STATE
     MOVE "key bindings after a restart the inventory key is still I (73)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 73 TO TL-EXPECTED-N
     MOVE KB-CODE(KB-INVENTORY) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-KEY-BINDINGS.

 COPY OPTTEST.
 COPY CLTEST.
