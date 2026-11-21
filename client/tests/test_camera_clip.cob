*> Test US18-2 (spec edge case; 12 §7.2): the third-person camera is 4 blocks away in open air; with a wall behind the player in a
*> one-block-high space it is pulled in so that it does not pass through the blocks, and never farther than 4.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CAMERA-CLIP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-FWD-TABLE.
    05 WS-FWD              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-DISTANCE            FLOAT-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 2.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "N" TO TL-MODE
     MOVE 0.5 TO WS-EYE(1) WS-EYE(3)
     MOVE 11.6 TO WS-EYE(2)
     MOVE 0 TO WS-FWD(1) WS-FWD(2)
     MOVE 1 TO WS-FWD(3)
     CALL "CAMERA-DISTANCE" USING CLIENT-STATE WS-EYE-TABLE WS-FWD-TABLE WS-DISTANCE
     MOVE "camera clip: open air behind the player, the camera is 4 blocks away" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-DISTANCE * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Looking straight up the camera goes down into the floor (top at y 10): pulled in to about 1.5.
     MOVE 0 TO WS-FWD(3)
     MOVE 1 TO WS-FWD(2)
     CALL "CAMERA-DISTANCE" USING CLIENT-STATE WS-EYE-TABLE WS-FWD-TABLE WS-DISTANCE
     MOVE "camera clip: looking up, the floor pulls the camera in to 1.5 blocks (the eye is 1.6 above it, 0.1 clearance)" TO TL-CASE
     MOVE 15 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-DISTANCE * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A wall of blocks across z -2, x -3 to 3, y 10 to 12 behind the player.
     PERFORM VARYING WS-X FROM -3 BY 1 UNTIL WS-X > 3
         PERFORM VARYING WS-Y FROM 10 BY 1 UNTIL WS-Y > 12
             MOVE -2 TO WS-Z
             CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-FWD(2)
     MOVE 1 TO WS-FWD(3)
     CALL "CAMERA-DISTANCE" USING CLIENT-STATE WS-EYE-TABLE WS-FWD-TABLE WS-DISTANCE
     MOVE "camera clip: a wall at z -2 behind the player shortens the distance to 1.4 blocks (z 0.5 - 0.1 to the wall's face at -1)" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-DISTANCE * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-CAMERA-CLIP.

 COPY CLTEST.
