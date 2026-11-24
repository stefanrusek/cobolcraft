*> Contract test (US4, Q-2; contracts/shim-delta.md cc_open_path): a fresh client state names exactly
*> /usr/bin/open as its opener; an opener that cannot start gives CC-NOTFOUND, which the pack screen shows as
*> a line (cobolcraft.screen.packs.open_failed) without a crash.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTRACT-OPENER-PRODUCTION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-SCREEN              BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-HITS                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "rm -rf build/client-test-opener"
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "contract opener a fresh client state names /usr/bin/open" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(CL-OPENER) TO TL-OBSERVED
     MOVE "/usr/bin/open" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "Alice" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH
     MOVE "build/client-test-opener" TO CL-GAME-DIR
     MOVE 24 TO CL-GAME-DIR-LENGTH
     CALL "CL-START" USING CLIENT-STATE
     MOVE SPACES TO CL-OPENER
     MOVE "/nonexistent/opener" TO CL-OPENER
     MOVE 19 TO CL-OPENER-LENGTH
     MOVE SCR-PACKS TO WS-SCREEN
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE ACT-OPEN-PACK-FOLDER TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "Cannot start /nonexistent/opener"
     MOVE "contract opener an opener that cannot start (CC-NOTFOUND) shows its name on the pack screen "
         & "and nothing crashes" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE FUNCTION MIN(WS-HITS, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM CONTRACT-OPENER-PRODUCTION.
 COPY CLTEST.
