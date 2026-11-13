*> Acceptance test (vanilla key.screenshot): F2 pressed on the world screen asks the shim for a screenshot named
*> YYYY-MM-DD_HH.MM.SS.png in <game directory>/screenshots (a key repeat does not), the served request adds the chat message
*> "Saved screenshot as <file name>" (a failed one screenshot.failure), SHOT-NAME adds _1, _2 after a name that exists, and the key is
*> the key.screenshot binding of the options. The shim's request is the real one; no frame is presented here, so the request is
*> served by calling SHOT-POLL with the result the shim would give.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-SHOT-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-F2                  BINARY-LONG VALUE 291.
 01 WS-EVENT.
    05 WS-KIND             BINARY-LONG.
    05 WS-A                BINARY-LONG.
    05 WS-B                BINARY-LONG.
    05 WS-C                BINARY-LONG.
    05 FILLER              PIC X(8).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-MS                  BINARY-LONG VALUE 50.
 01 WS-STAMP               PIC X(19) VALUE "2026-11-12_13.14.15".
 01 WS-PATH                PIC X(1200).
 01 WS-RC                  BINARY-LONG.
 01 WS-FILE                PIC X(1200).
 01 WS-HANDLE              PIC X(4).
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "N" TO TL-MODE
     MOVE "acceptance shot the screenshot binding is F2 (291)" TO TL-CASE
     MOVE 291 TO TL-EXPECTED-N
     MOVE KB-CODE(KB-SCREENSHOT) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     INITIALIZE WS-EVENT
     MOVE CC-EV-KEY-DOWN TO WS-KIND
     MOVE WS-F2 TO WS-A
     MOVE 1 TO WS-C
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENT WS-ONE WS-MS
     MOVE "acceptance shot a repeated F2 does not take a screenshot" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CL-SHOT-PENDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-KEY" USING CLIENT-STATE WS-F2
     MOVE "acceptance shot F2 on the world screen requests a screenshot" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE CL-SHOT-PENDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance shot the file name is YYYY-MM-DD_HH.MM.SS.png (23 bytes, .png, dashes and dots)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF CL-SHOT-NAME-LENGTH = 23 AND CL-SHOT-NAME(20:4) = ".png" AND CL-SHOT-NAME(5:1) = "-"
             AND CL-SHOT-NAME(8:1) = "-" AND CL-SHOT-NAME(11:1) = "_" AND CL-SHOT-NAME(14:1) = "."
             AND CL-SHOT-NAME(17:1) = "." AND CL-SHOT-NAME(1:4) IS NUMERIC
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance shot the shim holds the request (the result is CC-AGAIN until a frame is presented)" TO TL-CASE
     MOVE CC-AGAIN TO TL-EXPECTED-N
     CALL STATIC "cc_vk_screenshot_result" RETURNING TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO WS-RC
     CALL "SHOT-POLL" USING CLIENT-STATE WS-RC
     MOVE "acceptance shot a served request is no longer pending" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CL-SHOT-PENDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance shot the chat shows Saved screenshot as <file name>" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED
     STRING "Saved screenshot as " CL-SHOT-NAME(1:23) DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE CH-TEXT(CH-COUNT)(1:CH-LENGTH(CH-COUNT)) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A failed request, and the run ending after an automatic screenshot with --screenshot-then-exit.
     MOVE 1 TO CL-SHOT-PENDING CL-SHOT-AUTO CL-SHOT-EXIT
     MOVE CC-FAILED TO WS-RC
     CALL "SHOT-POLL" USING CLIENT-STATE WS-RC
     MOVE "acceptance shot a failed request says Couldn't save screenshot" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     STRING "Couldn't save screenshot: " CL-SHOT-NAME(1:23) DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE CH-TEXT(CH-COUNT)(1:CH-LENGTH(CH-COUNT)) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance shot an automatic screenshot with exit ends the run" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE CL-QUIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Names: the stamp alone, then _1 after the file exists, then _2.
     CALL "SHOT-NAME" USING CLIENT-STATE WS-STAMP WS-PATH
     MOVE "acceptance shot a free name is the stamp and .png" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "2026-11-12_13.14.15.png" TO TL-EXPECTED
     MOVE CL-SHOT-NAME TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CBL_CREATE_FILE" USING WS-PATH 2 0 0 WS-HANDLE
     CALL "CBL_CLOSE_FILE" USING WS-HANDLE
     CALL "SHOT-NAME" USING CLIENT-STATE WS-STAMP WS-PATH
     MOVE "acceptance shot a name that exists gets _1" TO TL-CASE
     MOVE "2026-11-12_13.14.15_1.png" TO TL-EXPECTED
     MOVE CL-SHOT-NAME TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CBL_CREATE_FILE" USING WS-PATH 2 0 0 WS-HANDLE
     CALL "CBL_CLOSE_FILE" USING WS-HANDLE
     CALL "SHOT-NAME" USING CLIENT-STATE WS-STAMP WS-PATH
     MOVE "acceptance shot then _2" TO TL-CASE
     MOVE "2026-11-12_13.14.15_2.png" TO TL-EXPECTED
     MOVE CL-SHOT-NAME TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CBL_DELETE_FILE" USING WS-PATH
     MOVE SPACES TO WS-FILE
     STRING "build/client-test-play/screenshots/2026-11-12_13.14.15.png" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_DELETE_FILE" USING WS-FILE
     MOVE SPACES TO WS-FILE
     STRING "build/client-test-play/screenshots/2026-11-12_13.14.15_1.png" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_DELETE_FILE" USING WS-FILE
     STOP RUN.
 END PROGRAM ACC-SHOT-KEY.

 COPY CLTEST.
