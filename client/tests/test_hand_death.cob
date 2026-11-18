*> T28000 (lane 002-lane-p70d): the death time of the local player and the death tilt of the view pose (12 section 6.1 step 2: while dying rotate Z by
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
 01 WS-COUNT               BINARY-LONG VALUE 4.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
*>   The death time: counts client ticks while the health is 0, stops at 20, and is 0 again once alive.
     MOVE 30 TO PL-HEALTH
     MOVE 7 TO CL-DEATH-TIME
     CALL "HAND-DEATH-TICK" USING CLIENT-STATE
     MOVE "T28000 an alive player has deathTime 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CL-DEATH-TIME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-HEALTH
     CALL "HAND-DEATH-TICK" USING CLIENT-STATE
     CALL "HAND-DEATH-TICK" USING CLIENT-STATE
     CALL "HAND-DEATH-TICK" USING CLIENT-STATE
     MOVE "T28000 three ticks of a dying player make deathTime 3" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE CL-DEATH-TIME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 30 TIMES
         CALL "HAND-DEATH-TICK" USING CLIENT-STATE
     END-PERFORM
     MOVE "T28000 deathTime stops at 20" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE CL-DEATH-TIME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO PL-HEALTH
     CALL "HAND-DEATH-TICK" USING CLIENT-STATE
     MOVE "T28000 a respawned player has deathTime 0 again" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CL-DEATH-TIME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The client tick runs it: a player with no health has a deathTime of 1 or more after four steps (the loop ticks every 50 ms).
     MOVE 0 TO PL-HEALTH
     MOVE 0 TO CL-DEATH-TIME
     CALL "TEST-TICKS" USING CLIENT-STATE WS-COUNT
     MOVE "T28000 the client tick counts deathTime" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF CL-DEATH-TIME >= 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The tilt.
     MOVE 0 TO CL-BOB-INIT
     MOVE 0 TO WS-PART
     MOVE 0 TO PL-HEALTH
     MOVE 0 TO CL-DEATH-TIME
     CALL "HAND-PREFIX" USING CLIENT-STATE WS-PART WS-M
     MOVE "T28000 a dying player at deathTime 0 has no tilt" TO WS-NAME
     MOVE 1 TO WS-COS
     MOVE 0 TO WS-SIN
     PERFORM CHECK-TILT
     MOVE 10 TO CL-DEATH-TIME
     CALL "HAND-PREFIX" USING CLIENT-STATE WS-PART WS-M
     MOVE "T28000 at deathTime 10 the view is rolled 1.904762 degrees" TO WS-NAME
     MOVE 0.99945 TO WS-COS
     MOVE 0.03324 TO WS-SIN
     PERFORM CHECK-TILT
     MOVE 20 TO CL-DEATH-TIME
     CALL "HAND-PREFIX" USING CLIENT-STATE WS-PART WS-M
     MOVE "T28000 at deathTime 20 the view is rolled 3.636364 degrees" TO WS-NAME
     MOVE 0.99799 TO WS-COS
     MOVE 0.06342 TO WS-SIN
     PERFORM CHECK-TILT
*>   A dying player is not given the hurt tilt as well: the Hurt Animation time running changes nothing.
     MOVE 6000000 TO CL-NOW-MS
     COMPUTE PL-HURT-UNTIL = CL-NOW-MS + 250
     MOVE 90 TO PL-HURT-DIR
     CALL "HAND-PREFIX" USING CLIENT-STATE WS-PART WS-M
     MOVE "T28000 a dying player takes the death tilt alone, not the hurt tilt" TO WS-NAME
     PERFORM CHECK-TILT
     MOVE 0 TO PL-HURT-UNTIL PL-HURT-DIR
     MOVE 50 TO CL-DEATH-TIME
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
