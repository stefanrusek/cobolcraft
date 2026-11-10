*> The F5 camera (US18; 12 §7.1, §7.2; 13 §6; FR-019). CAMERA-INPUT: the key of the togglePerspective binding (F5) pressed on the world screen cycles
*> CL-CAMERA first person (0), behind (1), in front (2), first person. CAMERA-PLACE: the view of a frame: the eye (the player's feet + 1.6)
*> with the look yaw and pitch; in front (mirrored) yaw + 180 and pitch negated; in the two third-person modes the eye goes back along the
*> look direction by the distance of CAMERA-DISTANCE. CAMERA-DISTANCE: 4 blocks, shortened by blocks in the way: for each of the 8 corners
*> (+-0.1 on every axis) of the eye a ray against the replica along the camera's back direction for 4 blocks (sampled every 0.05); the
*> first cell with a block (a state other than 0) at distance t shortens the distance to t, never lengthens it. The target of RAYCAST stays
*> the player's own eye ray.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CAMERA-INPUT.
*> USING CLIENT-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-KEY                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE KB-CODE(KB-PERSPECTIVE) TO WS-KEY
     IF SM-SCREEN = SCR-WORLD AND IN-KEY-PRESSED(WS-KEY + 1) = 1
         COMPUTE CL-CAMERA = FUNCTION MOD(CL-CAMERA + 1, 3)
     END-IF
     GOBACK.
 END PROGRAM CAMERA-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CAMERA-DISTANCE.
*> USING CLIENT-STATE, eye (3 FLOAT-LONG), forward (3 FLOAT-LONG, the camera's look direction), distance out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CORNER              BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-START               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 01 L-FWD-TABLE.
    05 L-FWD               FLOAT-LONG OCCURS 3 TIMES.
 01 L-DISTANCE             FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-EYE-TABLE L-FWD-TABLE L-DISTANCE.
     MOVE 4.0 TO L-DISTANCE
     PERFORM VARYING WS-CORNER FROM 0 BY 1 UNTIL WS-CORNER > 7
         MOVE WS-CORNER TO WS-BITS
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             COMPUTE WS-START(WS-A) = L-EYE(WS-A) - 0.1
             IF FUNCTION MOD(WS-BITS, 2) = 1
                 COMPUTE WS-START(WS-A) = L-EYE(WS-A) + 0.1
             END-IF
             COMPUTE WS-BITS = WS-BITS / 2
         END-PERFORM
         MOVE 0 TO WS-DONE
         PERFORM VARYING WS-STEP FROM 1 BY 1 UNTIL WS-STEP > 80 OR WS-DONE = 1
             COMPUTE WS-T = WS-STEP * 0.05
             IF WS-T < L-DISTANCE
                 COMPUTE WS-CX = FUNCTION INTEGER(WS-START(1) - L-FWD(1) * WS-T)
                 COMPUTE WS-CY = FUNCTION INTEGER(WS-START(2) - L-FWD(2) * WS-T)
                 COMPUTE WS-CZ = FUNCTION INTEGER(WS-START(3) - L-FWD(3) * WS-T)
                 CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-STATE WS-SKY WS-BLOCK
                 IF WS-STATE > 0
                     MOVE WS-T TO L-DISTANCE
                     MOVE 1 TO WS-DONE
                 END-IF
             ELSE
                 MOVE 1 TO WS-DONE
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM CAMERA-DISTANCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CAMERA-PLACE.
*> USING CLIENT-STATE, view yaw out, view pitch out (degrees, FLOAT-LONG), eye (3 FLOAT-LONG) out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-FWD-TABLE.
    05 WS-FWD              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-DISTANCE            FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-YAW                  FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-YAW L-PITCH L-EYE-TABLE.
     MOVE PL-X TO L-EYE(1)
     COMPUTE L-EYE(2) = PL-Y + 1.6
     MOVE PL-Z TO L-EYE(3)
     MOVE PL-YAW TO L-YAW
     MOVE PL-PITCH TO L-PITCH
     IF CL-CAMERA = 2
         COMPUTE L-YAW = PL-YAW + 180
         COMPUTE L-PITCH = 0 - PL-PITCH
     END-IF
     IF CL-CAMERA > 0
         COMPUTE WS-YAW = L-YAW * FUNCTION PI / 180
         COMPUTE WS-PITCH = L-PITCH * FUNCTION PI / 180
         COMPUTE WS-FWD(1) = 0 - FUNCTION SIN(WS-YAW) * FUNCTION COS(WS-PITCH)
         COMPUTE WS-FWD(2) = 0 - FUNCTION SIN(WS-PITCH)
         COMPUTE WS-FWD(3) = FUNCTION COS(WS-YAW) * FUNCTION COS(WS-PITCH)
         CALL "CAMERA-DISTANCE" USING CLIENT-STATE L-EYE-TABLE WS-FWD-TABLE WS-DISTANCE
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             COMPUTE L-EYE(WS-A) = L-EYE(WS-A) - WS-FWD(WS-A) * WS-DISTANCE
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM CAMERA-PLACE.
