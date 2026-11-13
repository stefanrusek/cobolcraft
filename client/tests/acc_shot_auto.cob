*> Acceptance test (screenshot for automated runs): CL-SHOT-AT (--screenshot-after-frames N, CC_SCREENSHOT_AT_FRAME) takes one
*> screenshot by itself once frame N is reached, and only once; --screenshot-then-exit, CC_SCREENSHOT_THEN_EXIT and the options
*> are read by ARGS-PARSE.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-SHOT-AUTO.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CLARGS.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "N" TO TL-MODE
     COMPUTE CL-SHOT-AT = CL-FRAMES + 2
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "acceptance shot-auto before the frame no screenshot is requested" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CL-SHOT-PENDING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "acceptance shot-auto at the frame one screenshot is requested, marked automatic" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = CL-SHOT-PENDING * 10 + CL-SHOT-AUTO
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance shot-auto the setting is used up" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CL-SHOT-AT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CL-QUIT
     MOVE 0 TO WS-RC
     CALL "SHOT-POLL" USING CLIENT-STATE WS-RC
     MOVE "acceptance shot-auto without --screenshot-then-exit the run goes on" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CL-QUIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The command line.
     INITIALIZE CL-ARGS
     MOVE 5 TO AR-COUNT
     MOVE "--name" TO AR-TEXT(1)
     MOVE 6 TO AR-LENGTH(1)
     MOVE "Tester" TO AR-TEXT(2)
     MOVE 6 TO AR-LENGTH(2)
     MOVE "--screenshot-after-frames" TO AR-TEXT(3)
     MOVE 25 TO AR-LENGTH(3)
     MOVE "120" TO AR-TEXT(4)
     MOVE 3 TO AR-LENGTH(4)
     MOVE "--screenshot-then-exit" TO AR-TEXT(5)
     MOVE 22 TO AR-LENGTH(5)
     CALL "ARGS-PARSE" USING CLIENT-STATE CL-ARGS
     MOVE "acceptance shot-auto --screenshot-after-frames 120 and --screenshot-then-exit are read" TO TL-CASE
     MOVE 1120 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = CL-SHOT-EXIT * 1000 + CL-SHOT-AT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The environment: CC_SCREENSHOT_AT_FRAME and CC_SCREENSHOT_THEN_EXIT, no screenshot flag on the command line.
     DISPLAY "CC_SCREENSHOT_AT_FRAME" UPON ENVIRONMENT-NAME
     DISPLAY "77" UPON ENVIRONMENT-VALUE
     DISPLAY "CC_SCREENSHOT_THEN_EXIT" UPON ENVIRONMENT-NAME
     DISPLAY "1" UPON ENVIRONMENT-VALUE
     CALL "CL-INIT" USING CLIENT-STATE
     INITIALIZE CL-ARGS
     MOVE 2 TO AR-COUNT
     MOVE "--name" TO AR-TEXT(1)
     MOVE 6 TO AR-LENGTH(1)
     MOVE "Tester" TO AR-TEXT(2)
     MOVE 6 TO AR-LENGTH(2)
     CALL "ARGS-PARSE" USING CLIENT-STATE CL-ARGS
     MOVE "acceptance shot-auto the environment variables set frame 77 and exit" TO TL-CASE
     MOVE 1077 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = CL-SHOT-EXIT * 1000 + CL-SHOT-AT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-SHOT-AUTO.

 COPY CLTEST.
