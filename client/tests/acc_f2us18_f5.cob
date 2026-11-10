*> Acceptance test US18-1 (spec 002 FR-019; 13 §6, 12 §7.1): repeated F5 cycles first person, behind, in front, first person; the
*> crosshair is drawn in first person only; the view (the eye behind the player, mirrored in front) follows the mode.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US18-F5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-KEY                 BINARY-LONG VALUE 294.
 01 WS-I                   BINARY-LONG.
 01 WS-D1                  PIC 9.
 01 WS-CROSSHAIRS          BINARY-LONG.
 01 WS-VIEW-YAW            FLOAT-LONG.
 01 WS-VIEW-PITCH          FLOAT-LONG.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE "N" TO TL-MODE
     MOVE "acceptance US18-1 the camera starts in first person (0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE CL-CAMERA TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
         MOVE SPACES TO TL-CASE
         MOVE WS-I TO WS-D1
         STRING "acceptance US18-1 F5 press " WS-D1 " gives the next mode of first, behind, in front, first, behind"
             DELIMITED BY SIZE INTO TL-CASE
         COMPUTE TL-EXPECTED-N = FUNCTION MOD(WS-I, 3)
         MOVE CL-CAMERA TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE 0 TO CL-CAMERA
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE 0 TO WS-CROSSHAIRS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL AND SM-W-LENGTH(WS-I) = 1
             ADD 1 TO WS-CROSSHAIRS
         END-IF
     END-PERFORM
     MOVE "acceptance US18-1 the crosshair is drawn in first person" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-CROSSHAIRS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO CL-CAMERA
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     MOVE 0 TO WS-CROSSHAIRS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-LABEL AND SM-W-LENGTH(WS-I) = 1
             ADD 1 TO WS-CROSSHAIRS
         END-IF
     END-PERFORM
     MOVE "acceptance US18-1 the crosshair is not drawn in third person" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CROSSHAIRS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The view: facing +Z (yaw 0) from (0.5, 11.6, 0.5): behind puts the eye 4 blocks back (z -3.5), in front 4 blocks ahead (z 4.5) looking back (yaw 180).
     CALL "CAMERA-PLACE" USING CLIENT-STATE WS-VIEW-YAW WS-VIEW-PITCH WS-EYE-TABLE
     MOVE "acceptance US18-1 behind: the eye is 4 blocks behind the player (z -3.5) with the player's yaw 0" TO TL-CASE
     MOVE -35 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-EYE(3) * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO CL-CAMERA
     CALL "CAMERA-PLACE" USING CLIENT-STATE WS-VIEW-YAW WS-VIEW-PITCH WS-EYE-TABLE
     MOVE "acceptance US18-1 in front: the eye is 4 blocks ahead (z 4.5) looking back (yaw 180)" TO TL-CASE
     MOVE 45180 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-EYE(3) * 10 * 1000 + WS-VIEW-YAW
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CL-CAMERA
     CALL "CAMERA-PLACE" USING CLIENT-STATE WS-VIEW-YAW WS-VIEW-PITCH WS-EYE-TABLE
     MOVE "acceptance US18-1 first person: the eye is the player's (z 0.5)" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-EYE(3) * 10
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-F2US18-F5.

 COPY CLTEST.
