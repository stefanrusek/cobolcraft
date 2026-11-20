*> T28000 (lane 002-lane-p70d): the death tilt of the hand's view pose (the deathTime is PL-DEATH-TIME, the tilt is VIEW-POSE's since lane bugviewbob; a dying player keeps the hurt tilt: 57-1 section 5.2) (12 section 6.1 step 2: while dying rotate Z by
*> 40 - 8000 / (min(deathTime, 20) + 200) degrees and nothing else). Expected angles from an independent script: deathTime 10 gives 1.904762 degrees
*> (cos 0.999447, sin 0.033238), 20 and more 3.636364 degrees (cos 0.997987, sin 0.063424), 0 gives none. The image of the x axis of the pose is (cos, sin, 0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HAND-DEATH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-PART                FLOAT-LONG.
 01 WS-M.
    05 WS-MV               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-NAME                PIC X(200).
 01 WS-COS                 FLOAT-LONG.
 01 WS-SIN                 FLOAT-LONG.
 01 WS-BAD                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
*>   The tilt.
     MOVE 0 TO CL-BOB-INIT
     MOVE 0 TO WS-PART
     MOVE 0 TO PL-HEALTH
     MOVE 0 TO PL-DEATH-TIME
     CALL "HAND-PREFIX" USING CLIENT-STATE WS-PART WS-M
     MOVE "T28000 a dying player at deathTime 0 has no tilt" TO WS-NAME
     MOVE 1 TO WS-COS
     MOVE 0 TO WS-SIN
     PERFORM CHECK-TILT
     MOVE 10 TO PL-DEATH-TIME
     CALL "HAND-PREFIX" USING CLIENT-STATE WS-PART WS-M
     MOVE "T28000 at deathTime 10 the view is rolled 1.904762 degrees" TO WS-NAME
     MOVE 0.99945 TO WS-COS
     MOVE 0.03324 TO WS-SIN
     PERFORM CHECK-TILT
     MOVE 20 TO PL-DEATH-TIME
     CALL "HAND-PREFIX" USING CLIENT-STATE WS-PART WS-M
     MOVE "T28000 at deathTime 20 the view is rolled 3.636364 degrees" TO WS-NAME
     MOVE 0.99799 TO WS-COS
     MOVE 0.06342 TO WS-SIN
     PERFORM CHECK-TILT
     MOVE 0 TO PL-HURT-UNTIL PL-HURT-DIR
     MOVE 50 TO PL-DEATH-TIME
     CALL "HAND-PREFIX" USING CLIENT-STATE WS-PART WS-M
     MOVE "T28000 deathTime over 20 is read as 20" TO WS-NAME
     PERFORM CHECK-TILT
*>   Alive again: no tilt from the death time.
     MOVE 30 TO PL-HEALTH
     CALL "HAND-PREFIX" USING CLIENT-STATE WS-PART WS-M
     MOVE "T28000 a living player's view is not rolled by a stale deathTime" TO WS-NAME
     MOVE 1 TO WS-COS
     MOVE 0 TO WS-SIN
     PERFORM CHECK-TILT
     STOP RUN.

 CHECK-TILT.
     MOVE 0 TO WS-BAD
     IF FUNCTION ABS(WS-MV(1) - WS-COS) > 0.0006 OR FUNCTION ABS(WS-MV(4) - WS-SIN) > 0.0006 OR FUNCTION ABS(WS-MV(7)) > 0.0006
         ADD 1 TO WS-BAD
     END-IF
     IF FUNCTION ABS(WS-MV(3)) > 0.0006 OR FUNCTION ABS(WS-MV(6)) > 0.0006 OR FUNCTION ABS(WS-MV(9) - 1) > 0.0006
         ADD 1 TO WS-BAD
     END-IF
     MOVE WS-NAME TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-HAND-DEATH.

 COPY CLTEST.
