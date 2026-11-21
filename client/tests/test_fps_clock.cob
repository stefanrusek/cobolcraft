*> Implementation test of lane bugfps (T62300-T62399; operator report of try19: "the debug info shows 0 for the fps but the game is SO SMOOTH"). The frame clock
*> is the Unix epoch in milliseconds since lane bugsmooth (CL-CLOCK, gettimeofday: about 1.7e12, which does not fit 32 bits), and the frame rate of the F3 overlay
*> (DEBUG-OVERLAY-INPUT) measured the second against a narrow field. Frames at 60 fps (17, 17, 16 ms) on an epoch clock: after two seconds CL-FPS reads about 60,
*> the measurement window is about one second, and the client ticks still run at 20 Hz (the tick scheduler compares the same clock).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FPS-CLOCK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-EVENTS              PIC X(24).
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-NOW                 BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-TICKS0              BINARY-DOUBLE.
 01 WS-GAP                 BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "N" TO TL-MODE
     MOVE 1 TO CL-DEBUG
     MOVE 1700000000000 TO WS-NOW
     MOVE 0 TO WS-TICKS0
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 130
         EVALUATE FUNCTION MOD(WS-I, 3)
             WHEN 0 MOVE 16 TO WS-STEP
             WHEN OTHER MOVE 17 TO WS-STEP
         END-EVALUATE
         ADD WS-STEP TO WS-NOW
         CALL "CL-STEP" USING CLIENT-STATE WS-EVENTS WS-ZERO WS-NOW
     END-PERFORM
     MOVE "fps: 130 frames of 16.67 ms on a Unix epoch millisecond clock read about 60 fps (58 .. 61)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF CL-FPS >= 58 AND CL-FPS <= 61
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-GAP = CL-NOW-MS - CL-FPS-AT
     MOVE "fps: the last measurement is less than a second old (the window was measured, not skipped)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-GAP >= 0 AND WS-GAP < 1000 AND CL-FPS-AT > 1000000000000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "fps: the tick clock keeps its 50 ms schedule on the epoch clock (next tick within one tick of now)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF CL-NEXT-TICK > CL-NOW-MS AND CL-NEXT-TICK - CL-NOW-MS <= 50
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-FPS-CLOCK.
 COPY CLTEST.
