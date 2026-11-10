*> Implementation test of the hidden debug world selection (plan "Operator addition: debug world";
*> docs/design/world-types.md §2.1): holding Ctrl while clicking the world-type button on the create-world
*> screen selects the debug type; without Ctrl the button cycles only standard and cobolcraft. The word
*> "debug" appears nowhere in the screen's widgets or the built-in language. Create with debug selected is
*> refused with the packs explanation when the packs are not ok, and uses the standard content (the
*> settings carry CS-WORLD-TYPE debug) when they are.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DEBUG-SELECT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CLLANG.
 COPY CONTENT.
 COPY COREAPI.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-debug-select".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 30.
 01 WS-SCREEN              BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-HITS                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E1                  PIC 9.
 01 WS-E2                  PIC 9.
 01 WS-E3                  PIC 9.
 PROCEDURE DIVISION.
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     MOVE CT-PACKS-OK TO CL-PACKS-STATUS
     MOVE SCR-CREATE-WORLD TO WS-SCREEN
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE ACT-WORLD-TYPE TO WS-ACTION
*>   Without Ctrl: standard, cobolcraft, standard.
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE SP-CREATE-TYPE TO WS-E1
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE SP-CREATE-TYPE TO WS-E2
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "debug select without Ctrl the button cycles standard (0), cobolcraft (1), standard (0) and "
         & "never debug" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "1 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING WS-E1 " " WS-E2 DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   With Ctrl held a click selects debug; the button then reads like the standard type.
     MOVE 1 TO IN-KEY-DOWN(CC-KEY-LEFT-CONTROL + 1)
     MOVE CC-MOD-CONTROL TO IN-MODS
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE SP-CREATE-TYPE TO WS-E1
     MOVE 0 TO IN-KEY-DOWN(CC-KEY-LEFT-CONTROL + 1)
     MOVE 0 TO IN-MODS
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "World type: Standard"
     MOVE WS-HITS TO WS-E2
     MOVE ZERO TO WS-HITS
     INSPECT FUNCTION LOWER-CASE(WS-TEXT) TALLYING WS-HITS FOR ALL "debug"
     MOVE WS-HITS TO WS-E3
     MOVE "debug select a Ctrl-click selects debug (2), the button still reads Standard, and the word "
         & "debug is nowhere on the screen" TO TL-CASE
     MOVE "2 1 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING WS-E1 " " WS-E2 " " WS-E3 DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The built-in language has no key or text with the word.
     MOVE ZERO TO WS-HITS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BI-LANG-COUNT
         INSPECT FUNCTION LOWER-CASE(BI-LANG-KEY(WS-I)) TALLYING WS-HITS FOR ALL "debug"
         INSPECT FUNCTION LOWER-CASE(BI-LANG-TEXT(WS-I)) TALLYING WS-HITS FOR ALL "debug"
     END-PERFORM
     MOVE "debug select the built-in language holds the word debug in no key and no text" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HITS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Create with debug and the packs not ok is refused with the packs explanation, nothing opens.
     MOVE CT-PACKS-STALE TO CL-PACKS-STATUS
     MOVE ACT-CREATE-WORLD TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "Standard worlds need the Minecraft content"
     MOVE WS-HITS TO WS-E1
     MOVE SP-ACTIVE TO WS-E2
     MOVE "debug select Create with debug selected and the packs not ok is refused with the packs "
         & "explanation; no world opens" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "1 0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING WS-E1 " " WS-E2 DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   With the packs ok the settings carry the debug type.
     MOVE CT-PACKS-OK TO CL-PACKS-STATUS
     MOVE ACT-CREATE-WORLD TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE SP-SETTINGS TO CORE-SETTINGS
     MOVE "debug select Create with debug selected and the packs ok opens the world with the settings "
         & "type debug" TO TL-CASE
     MOVE "debug" TO TL-EXPECTED
     MOVE FUNCTION TRIM(CS-WORLD-TYPE) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-DEBUG-SELECT.
 COPY CLTEST.
