*> The render list (data-model §13; research R4; shim-abi.md §9): RENDER-LIST-BUILD writes the
*> frame's clear colour (the sky), projection and view matrices, the draws and the uploads. The
*> world is drawn on the world screen and behind the pause menu: the camera is the local player's
*> eye (1.6 above the feet, standin-content §3) turned by yaw (0 faces +Z, 90 faces -X) and pitch
*> (positive looks down); the projection is a 70 degree vertical perspective into Vulkan clip space
*> (y down, depth 0 to 1, near 0.05, far 512). Each section mesh is drawn with projection x view x
*> its offset from the eye (camera-relative, so float positions stay small): every opaque mesh,
*> then the translucent meshes back to front by section centre, then the UI mesh (texture 2) with
*> an orthographic window-pixel matrix. Meshes changed since the last frame, and the UI mesh, are
*> listed as uploads.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RENDER-LIST-BUILD.
*> USING CLIENT-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-R                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-WORLD               BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-ASPECT              FLOAT-LONG.
 01 WS-NEAR                FLOAT-LONG VALUE 0.05.
 01 WS-FAR                 FLOAT-LONG VALUE 512.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-FWD                 FLOAT-LONG OCCURS 3 TIMES.
 01 WS-RIGHT               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-UP                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-PV-TABLE.
    05 WS-PV               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-SUM                 FLOAT-LONG.
 01 WS-TCOUNT              BINARY-LONG.
 01 WS-TSLOT               BINARY-LONG OCCURS 4096 TIMES.
 01 WS-TROW                BINARY-LONG OCCURS 4096 TIMES.
 01 WS-TSEC                BINARY-LONG OCCURS 4096 TIMES.
 01 WS-TDIST               FLOAT-LONG OCCURS 4096 TIMES.
 01 WS-SWAP-SLOT           BINARY-LONG.
 01 WS-SWAP-ROW            BINARY-LONG.
 01 WS-SWAP-SEC            BINARY-LONG.
 01 WS-SWAP-DIST           FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE SK-R TO RL-CLEAR(1)
     MOVE SK-G TO RL-CLEAR(2)
     MOVE SK-B TO RL-CLEAR(3)
     MOVE 1 TO RL-CLEAR(4)
     MOVE 0 TO RL-DRAW-COUNT RL-UPLOAD-COUNT
*>   Projection (column-major).
     COMPUTE WS-F = 1 / FUNCTION TAN(35 * FUNCTION PI / 180)
     COMPUTE WS-ASPECT = FUNCTION MAX(IN-WIN-W, 1) / FUNCTION MAX(IN-WIN-H, 1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE 0 TO RL-PROJ(WS-I) RL-VIEW(WS-I)
     END-PERFORM
     COMPUTE RL-PROJ(1) = WS-F / WS-ASPECT
     COMPUTE RL-PROJ(6) = 0 - WS-F
     COMPUTE RL-PROJ(11) = WS-FAR / (WS-NEAR - WS-FAR)
     MOVE -1 TO RL-PROJ(12)
     COMPUTE RL-PROJ(15) = WS-NEAR * WS-FAR / (WS-NEAR - WS-FAR)
*>   View: rows right, up and -forward.
     COMPUTE WS-YAW = PL-YAW * FUNCTION PI / 180
     COMPUTE WS-PITCH = PL-PITCH * FUNCTION PI / 180
     COMPUTE WS-FWD(1) = 0 - FUNCTION SIN(WS-YAW) * FUNCTION COS(WS-PITCH)
     COMPUTE WS-FWD(2) = 0 - FUNCTION SIN(WS-PITCH)
     COMPUTE WS-FWD(3) = FUNCTION COS(WS-YAW) * FUNCTION COS(WS-PITCH)
     COMPUTE WS-RIGHT(1) = 0 - FUNCTION COS(WS-YAW)
     MOVE 0 TO WS-RIGHT(2)
     COMPUTE WS-RIGHT(3) = 0 - FUNCTION SIN(WS-YAW)
     COMPUTE WS-UP(1) = WS-RIGHT(2) * WS-FWD(3) - WS-RIGHT(3) * WS-FWD(2)
     COMPUTE WS-UP(2) = WS-RIGHT(3) * WS-FWD(1) - WS-RIGHT(1) * WS-FWD(3)
     COMPUTE WS-UP(3) = WS-RIGHT(1) * WS-FWD(2) - WS-RIGHT(2) * WS-FWD(1)
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 3
         COMPUTE WS-I = (WS-C - 1) * 4 + 1
         MOVE WS-RIGHT(WS-C) TO RL-VIEW(WS-I)
         MOVE WS-UP(WS-C) TO RL-VIEW(WS-I + 1)
         COMPUTE RL-VIEW(WS-I + 2) = 0 - WS-FWD(WS-C)
     END-PERFORM
     MOVE 1 TO RL-VIEW(16)
*>   Projection x view.
     PERFORM VARYING WS-C FROM 0 BY 1 UNTIL WS-C > 3
         PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R > 3
             MOVE 0 TO WS-SUM
             PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 3
                 COMPUTE WS-SUM = WS-SUM
                     + RL-PROJ(WS-K * 4 + WS-R + 1) * RL-VIEW(WS-C * 4 + WS-K + 1)
             END-PERFORM
             MOVE WS-SUM TO WS-PV(WS-C * 4 + WS-R + 1)
         END-PERFORM
     END-PERFORM
     MOVE PL-X TO WS-EYE(1)
     COMPUTE WS-EYE(2) = PL-Y + 1.6
     MOVE PL-Z TO WS-EYE(3)
     MOVE 0 TO WS-WORLD
     IF SM-SCREEN = SCR-WORLD OR SM-SCREEN = SCR-PAUSE
         MOVE 1 TO WS-WORLD
     END-IF
*>   Uploads of changed meshes; opaque draws; translucent candidates.
     MOVE 0 TO WS-TCOUNT
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 16
             COMPUTE WS-SLOT = MESH-SLOT-BASE + ((WS-R - 1) * 16 + WS-S - 1) * 2
             IF WR-UPLOAD(WS-R, WS-S) = 1 AND RL-UPLOAD-COUNT < CL-MAX-UPLOADS - 2
                 ADD 1 TO RL-UPLOAD-COUNT
                 MOVE WS-SLOT TO RL-U-SLOT(RL-UPLOAD-COUNT)
                 SET RL-U-ADDR(RL-UPLOAD-COUNT) TO WR-OP-ADDR(WS-R, WS-S)
                 MOVE WR-OP-COUNT(WS-R, WS-S) TO RL-U-COUNT(RL-UPLOAD-COUNT)
                 ADD 1 TO RL-UPLOAD-COUNT
                 COMPUTE RL-U-SLOT(RL-UPLOAD-COUNT) = WS-SLOT + 1
                 SET RL-U-ADDR(RL-UPLOAD-COUNT) TO WR-TR-ADDR(WS-R, WS-S)
                 MOVE WR-TR-COUNT(WS-R, WS-S) TO RL-U-COUNT(RL-UPLOAD-COUNT)
                 MOVE 0 TO WR-UPLOAD(WS-R, WS-S)
             END-IF
             IF WS-WORLD = 1 AND WR-USED(WS-R) = 1
                 IF WR-OP-COUNT(WS-R, WS-S) > 0 AND RL-DRAW-COUNT < CL-MAX-DRAWS - 1
                     ADD 1 TO RL-DRAW-COUNT
                     MOVE WS-SLOT TO RL-D-SLOT(RL-DRAW-COUNT)
                     MOVE CC-PIPE-OPAQUE TO RL-D-PIPELINE(RL-DRAW-COUNT)
                     MOVE CC-TEX-BLOCKS TO RL-D-TEX(RL-DRAW-COUNT)
                     CALL "SECTION-MATRIX" USING CLIENT-STATE WS-PV-TABLE WS-EYE-TABLE WS-R WS-S
                 END-IF
                 IF WR-TR-COUNT(WS-R, WS-S) > 0 AND WS-TCOUNT < 4096
                     ADD 1 TO WS-TCOUNT
                     COMPUTE WS-TSLOT(WS-TCOUNT) = WS-SLOT + 1
                     MOVE WS-R TO WS-TROW(WS-TCOUNT)
                     MOVE WS-S TO WS-TSEC(WS-TCOUNT)
                     COMPUTE WS-DX = WR-CX(WS-R) * 16 + 8 - WS-EYE(1)
                     COMPUTE WS-DY = (WS-S - 1) * 16 + 8 + PL-MIN-Y - WS-EYE(2)
                     COMPUTE WS-DZ = WR-CZ(WS-R) * 16 + 8 - WS-EYE(3)
                     COMPUTE WS-TDIST(WS-TCOUNT) = WS-DX ** 2 + WS-DY ** 2 + WS-DZ ** 2
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
*>   Translucent sections back to front (insertion sort, farthest first).
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > WS-TCOUNT
         MOVE WS-TSLOT(WS-I) TO WS-SWAP-SLOT
         MOVE WS-TROW(WS-I) TO WS-SWAP-ROW
         MOVE WS-TSEC(WS-I) TO WS-SWAP-SEC
         MOVE WS-TDIST(WS-I) TO WS-SWAP-DIST
         COMPUTE WS-J = WS-I - 1
         PERFORM UNTIL WS-J < 1
             IF WS-TDIST(WS-J) >= WS-SWAP-DIST
                 EXIT PERFORM
             END-IF
             MOVE WS-TSLOT(WS-J) TO WS-TSLOT(WS-J + 1)
             MOVE WS-TROW(WS-J) TO WS-TROW(WS-J + 1)
             MOVE WS-TSEC(WS-J) TO WS-TSEC(WS-J + 1)
             MOVE WS-TDIST(WS-J) TO WS-TDIST(WS-J + 1)
             SUBTRACT 1 FROM WS-J
         END-PERFORM
         MOVE WS-SWAP-SLOT TO WS-TSLOT(WS-J + 1)
         MOVE WS-SWAP-ROW TO WS-TROW(WS-J + 1)
         MOVE WS-SWAP-SEC TO WS-TSEC(WS-J + 1)
         MOVE WS-SWAP-DIST TO WS-TDIST(WS-J + 1)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-TCOUNT OR RL-DRAW-COUNT >= CL-MAX-DRAWS - 1
         ADD 1 TO RL-DRAW-COUNT
         MOVE WS-TSLOT(WS-I) TO RL-D-SLOT(RL-DRAW-COUNT)
         MOVE CC-PIPE-TRANSLUCENT TO RL-D-PIPELINE(RL-DRAW-COUNT)
         MOVE CC-TEX-BLOCKS TO RL-D-TEX(RL-DRAW-COUNT)
         MOVE WS-TROW(WS-I) TO WS-R
         MOVE WS-TSEC(WS-I) TO WS-S
         CALL "SECTION-MATRIX" USING CLIENT-STATE WS-PV-TABLE WS-EYE-TABLE WS-R WS-S
     END-PERFORM
*>   The UI: uploaded every frame, drawn last with x' = 2x / w - 1, y' = 2y / h - 1.
     ADD 1 TO RL-UPLOAD-COUNT
     MOVE MESH-SLOT-UI TO RL-U-SLOT(RL-UPLOAD-COUNT)
     SET RL-U-ADDR(RL-UPLOAD-COUNT) TO ADDRESS OF RL-UI-VERTEX(1)
     MOVE RL-UI-COUNT TO RL-U-COUNT(RL-UPLOAD-COUNT)
     ADD 1 TO RL-DRAW-COUNT
     MOVE MESH-SLOT-UI TO RL-D-SLOT(RL-DRAW-COUNT)
     MOVE CC-PIPE-UI TO RL-D-PIPELINE(RL-DRAW-COUNT)
     MOVE CC-TEX-UI TO RL-D-TEX(RL-DRAW-COUNT)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE 0 TO RL-D-MATRIX(RL-DRAW-COUNT, WS-I)
     END-PERFORM
     COMPUTE RL-D-MATRIX(RL-DRAW-COUNT, 1) = 2 / FUNCTION MAX(IN-WIN-W, 1)
     COMPUTE RL-D-MATRIX(RL-DRAW-COUNT, 6) = 2 / FUNCTION MAX(IN-WIN-H, 1)
     MOVE 1 TO RL-D-MATRIX(RL-DRAW-COUNT, 11) RL-D-MATRIX(RL-DRAW-COUNT, 16)
     MOVE -1 TO RL-D-MATRIX(RL-DRAW-COUNT, 13) RL-D-MATRIX(RL-DRAW-COUNT, 14)
     GOBACK.

 END PROGRAM RENDER-LIST-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SECTION-MATRIX.
*> USING CLIENT-STATE, projection x view (16 FLOAT-LONG), eye (3 FLOAT-LONG), row, section: the
*> last draw's matrix: projection x view x the translation by the section's lowest corner minus
*> the eye.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OFF                 FLOAT-LONG OCCURS 3 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PV-TABLE.
    05 L-PV                FLOAT-LONG OCCURS 16 TIMES.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 01 L-ROW                  BINARY-LONG.
 01 L-S                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PV-TABLE L-EYE-TABLE L-ROW L-S.
     COMPUTE WS-OFF(1) = WR-CX(L-ROW) * 16 - L-EYE(1)
     COMPUTE WS-OFF(2) = (L-S - 1) * 16 + PL-MIN-Y - L-EYE(2)
     COMPUTE WS-OFF(3) = WR-CZ(L-ROW) * 16 - L-EYE(3)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE L-PV(WS-I) TO RL-D-MATRIX(RL-DRAW-COUNT, WS-I)
     END-PERFORM
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 4
         COMPUTE RL-D-MATRIX(RL-DRAW-COUNT, 12 + WS-R) = L-PV(WS-R) * WS-OFF(1)
             + L-PV(4 + WS-R) * WS-OFF(2) + L-PV(8 + WS-R) * WS-OFF(3) + L-PV(12 + WS-R)
     END-PERFORM
     GOBACK.
 END PROGRAM SECTION-MATRIX.
