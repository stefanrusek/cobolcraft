*> The target block (US4-1; client-surface §3; standin-content §3 eye height 1.6, §11.4 block reach):
*> RAYCAST follows the look ray from the local player's eye (yaw 0 faces +Z, 90 faces -X; positive
*> pitch looks down, as render-list.cob) cell by cell through the replica (a voxel walk: the next
*> cell boundary crossed along any axis comes first) for at most CL-REACH blocks. The first cell
*> that is not void is the target; the face the ray enters it through is the clicked face (05c
*> Direction: crossing a boundary towards +x enters the west face 4, towards -x the east face 5,
*> towards +y the bottom 0, towards -y the top 1, towards +z the north face 2, towards -z the south
*> face 3), and the point where it enters, relative to the block's lowest corner, is the cursor of
*> Use Item On. The eye's own cell is never the target.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RAYCAST.
*> USING CLIENT-STATE: sets TG-HIT and, on a hit, TG-X, TG-Y, TG-Z, TG-FACE and TG-CX, TG-CY, TG-CZ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-EYE                 FLOAT-LONG OCCURS 3 TIMES.
 01 WS-DIR                 FLOAT-LONG OCCURS 3 TIMES.
 01 WS-CELL                BINARY-LONG OCCURS 3 TIMES.
 01 WS-STEP                BINARY-LONG OCCURS 3 TIMES.
 01 WS-TMAX                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-TDELTA              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-FACE-BASES          PIC X(3) VALUE "402".
 01 WS-A                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-HIT                 FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO TG-HIT
     COMPUTE WS-YAW = PL-YAW * FUNCTION PI / 180
     COMPUTE WS-PITCH = PL-PITCH * FUNCTION PI / 180
     COMPUTE WS-DIR(1) = 0 - FUNCTION SIN(WS-YAW) * FUNCTION COS(WS-PITCH)
     COMPUTE WS-DIR(2) = 0 - FUNCTION SIN(WS-PITCH)
     COMPUTE WS-DIR(3) = FUNCTION COS(WS-YAW) * FUNCTION COS(WS-PITCH)
     MOVE PL-X TO WS-EYE(1)
     COMPUTE WS-EYE(2) = PL-Y + 1.6
     MOVE PL-Z TO WS-EYE(3)
*>   Per axis: the step direction, the ray distance to the first boundary and between boundaries
*>   (an axis the ray does not move along is never crossed).
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         COMPUTE WS-CELL(WS-A) = FUNCTION INTEGER(WS-EYE(WS-A))
         EVALUATE TRUE
             WHEN WS-DIR(WS-A) > 0
                 MOVE 1 TO WS-STEP(WS-A)
                 COMPUTE WS-TMAX(WS-A) = (WS-CELL(WS-A) + 1 - WS-EYE(WS-A)) / WS-DIR(WS-A)
                 COMPUTE WS-TDELTA(WS-A) = 1 / WS-DIR(WS-A)
             WHEN WS-DIR(WS-A) < 0
                 MOVE -1 TO WS-STEP(WS-A)
                 COMPUTE WS-TMAX(WS-A) = (WS-CELL(WS-A) - WS-EYE(WS-A)) / WS-DIR(WS-A)
                 COMPUTE WS-TDELTA(WS-A) = -1 / WS-DIR(WS-A)
             WHEN OTHER
                 MOVE 0 TO WS-STEP(WS-A)
                 MOVE 1.0E30 TO WS-TMAX(WS-A) WS-TDELTA(WS-A)
         END-EVALUATE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64 OR TG-HIT = 1
         MOVE 1 TO WS-A
         PERFORM VARYING WS-K FROM 2 BY 1 UNTIL WS-K > 3
             IF WS-TMAX(WS-K) < WS-TMAX(WS-A)
                 MOVE WS-K TO WS-A
             END-IF
         END-PERFORM
         MOVE WS-TMAX(WS-A) TO WS-T
         IF WS-T > CL-REACH
             EXIT PERFORM
         END-IF
         ADD WS-STEP(WS-A) TO WS-CELL(WS-A)
         ADD WS-TDELTA(WS-A) TO WS-TMAX(WS-A)
         MOVE WS-CELL(1) TO WS-CX
         MOVE WS-CELL(2) TO WS-CY
         MOVE WS-CELL(3) TO WS-CZ
         CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-STATE WS-SKY WS-BLOCK
         IF WS-STATE NOT = 0
             MOVE 1 TO TG-HIT
             MOVE WS-CX TO TG-X
             MOVE WS-CY TO TG-Y
             MOVE WS-CZ TO TG-Z
             COMPUTE TG-FACE = FUNCTION NUMVAL(WS-FACE-BASES(WS-A:1))
                 + (1 - WS-STEP(WS-A)) / 2
             COMPUTE WS-HIT = WS-EYE(1) + WS-DIR(1) * WS-T - TG-X
             COMPUTE TG-CX = FUNCTION MIN(1, FUNCTION MAX(0, WS-HIT))
             COMPUTE WS-HIT = WS-EYE(2) + WS-DIR(2) * WS-T - TG-Y
             COMPUTE TG-CY = FUNCTION MIN(1, FUNCTION MAX(0, WS-HIT))
             COMPUTE WS-HIT = WS-EYE(3) + WS-DIR(3) * WS-T - TG-Z
             COMPUTE TG-CZ = FUNCTION MIN(1, FUNCTION MAX(0, WS-HIT))
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RAYCAST.
