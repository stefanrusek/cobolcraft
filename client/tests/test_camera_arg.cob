*> Implementation test (002-lane-mobs): --camera x,y,z,yaw,pitch (or CC_CAMERA) fixes the view of every frame (CAMERA-PLACE) at that eye
*> position and look direction, so a screenshot run can aim at something (docs/protocol/13 section 7.3 is the screenshot; this is a run-time
*> option of the client, README). Fewer than five numbers or a non-numeric one is ignored.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CAMERA-ARG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLARGS.
 COPY TESTLIB.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     INITIALIZE CL-ARGS
     MOVE 3 TO AR-COUNT
     MOVE "--name" TO AR-TEXT(1)
     MOVE 6 TO AR-LENGTH(1)
     MOVE "Alice" TO AR-TEXT(2)
     MOVE 5 TO AR-LENGTH(2)
     MOVE "--camera" TO AR-TEXT(3)
     MOVE 8 TO AR-LENGTH(3)
     CALL "ARGS-PARSE" USING CLIENT-STATE CL-ARGS
     MOVE "N" TO TL-MODE
     MOVE "camera arg: --camera with no value sets nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CL-CAM-SET TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "CL-INIT" USING CLIENT-STATE
     INITIALIZE CL-ARGS
     MOVE 4 TO AR-COUNT
     MOVE "--name" TO AR-TEXT(1)
     MOVE 6 TO AR-LENGTH(1)
     MOVE "Alice" TO AR-TEXT(2)
     MOVE 5 TO AR-LENGTH(2)
     MOVE "--camera" TO AR-TEXT(3)
     MOVE 8 TO AR-LENGTH(3)
     MOVE "10.5,70,-3.25,90,45" TO AR-TEXT(4)
     MOVE 19 TO AR-LENGTH(4)
     CALL "ARGS-PARSE" USING CLIENT-STATE CL-ARGS
     MOVE "camera arg: five numbers are taken" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE CL-CAM-SET TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CAMERA-PLACE" USING CLIENT-STATE WS-YAW WS-PITCH WS-EYE-TABLE
     MOVE SPACES TO TL-OBSERVED
     MOVE "N" TO TL-MODE
     MOVE "camera place: the eye x is 10.5" TO TL-CASE
     MOVE 1050 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-EYE(1) * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "camera place: the eye y is 70 (the given point, not feet + 1.6)" TO TL-CASE
     MOVE 7000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-EYE(2) * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "camera place: the eye z is -3.25" TO TL-CASE
     MOVE -325 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-EYE(3) * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "camera place: yaw 90" TO TL-CASE
     MOVE 9000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-YAW * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "camera place: pitch 45" TO TL-CASE
     MOVE 4500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-PITCH * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Too few numbers, and a word that is no number: ignored.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "1,2,3,4" TO AR-TEXT(4)
     MOVE 7 TO AR-LENGTH(4)
     CALL "ARGS-PARSE" USING CLIENT-STATE CL-ARGS
     MOVE "camera arg: four numbers are ignored" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CL-CAM-SET TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "1,2,x,4,5" TO AR-TEXT(4)
     MOVE 9 TO AR-LENGTH(4)
     CALL "ARGS-PARSE" USING CLIENT-STATE CL-ARGS
     MOVE "camera arg: a non-numeric field is ignored" TO TL-CASE
     MOVE CL-CAM-SET TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Without the option the view is the player's: the eye is feet + 1.6.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 5 TO PL-X
     MOVE 20 TO PL-Y
     MOVE 6 TO PL-Z
     CALL "CAMERA-PLACE" USING CLIENT-STATE WS-YAW WS-PITCH WS-EYE-TABLE
     MOVE "camera place: without the option the eye is the player's, 1.6 above the feet" TO TL-CASE
     MOVE 2160 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-EYE(2) * 100
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-CAMERA-ARG.
