*> The player-model preview of the inventory screens (docs/protocol/49 section 4; 40-menus-7 section 7.1 rule 8 for the creative screen's survival tab). A screen lays out a widget of kind WK-PREVIEW
*> (the box x, y, w and h in GUI pixels, the argument the model scale: 30 on the inventory screen, 20 on the creative one); PREVIEW-WIDGET finds it, PREVIEW-MESH makes its quads into RL-PV-VERTEX
*> (RENDER-LIST-BUILD draws that layer with the UI's matrix between the UI layer and the item icons: the model is drawn right after the container sheet).
*> The figure is the local player's (local-figure.cob), baked by ENTITY-MODEL-EMIT on a spare replica row at the origin, then carried to the screen as vanilla does: the pointer of the frame before
*> gives a = atan((centre x - pointer x) / 40) and b = atan((centre y - pointer y) / 40) (the numbers a x 20 and b x 20 are degrees), body yaw 180 + a x 20, head yaw a x 20 more, head pitch -b x 20 (0
*> while gliding); a point p of the baked figure (feet at the origin, y up) is turned about X by b x 20 degrees, then by half a turn about Z (x and y change sign), moved up by half the standing
*> height 1.8 plus the offset 0.0625, scaled by the model scale times the GUI scale and put at the box centre, the depth the negated z. The faces that look at the viewer are kept (a face looks
*> at the viewer when its outward normal, taken away from the centre of its cuboid, has a positive depth component), lit by the two ENTITY_IN_UI lights of 12 section 1.9 (normalize(0.2, -1, 1) and
*> normalize(-0.2, -1, 0) in the view space, y down) and drawn far to near by their mean depth. The armour, the held items and the cape are not drawn. (The baked figure is
*> at scale 1; the player's 0.9375 of 12 section 7.3 is applied here.)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PREVIEW-WIDGET.
*> USING CLIENT-STATE, widget out: the index of the first widget of kind WK-PREVIEW in the screen model, 0 when there is none or the world is not of the standard set (the stand-in set has no model of the player).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CONTENT.
 01 WS-W                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-WIDGET               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-WIDGET.
     MOVE 0 TO L-WIDGET
     IF CT-OPEN = 1 AND CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT
         PERFORM VARYING WS-W FROM 1 BY 1 UNTIL WS-W > SM-WIDGET-COUNT OR L-WIDGET > 0
             IF SM-W-KIND(WS-W) = WK-PREVIEW
                 MOVE WS-W TO L-WIDGET
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM PREVIEW-WIDGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PREVIEW-MESH.
*> USING CLIENT-STATE: RL-PV-COUNT and RL-PV-VERTEX for this frame (RL-PV-COUNT 0 and the remembered pointer cleared when the screen has no preview). Called after ENTITIES-MESH: the baked
*> vertices are appended to RL-EN-VERTEX and taken off again, and the spare replica row is given back as it was.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-W                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-SAVED               PIC X(1024).
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES VALUE 0.
 01 WS-START               BINARY-LONG.
 01 WS-NC                  BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SRC                 BINARY-LONG.
 01 WS-DST                 BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CY                  FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-SCALE               FLOAT-LONG.
 01 WS-SIN                 FLOAT-LONG.
 01 WS-COS                 FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
*> The four corners of each of the cuboid's six faces in the view space (x right, y down, z towards the viewer; blocks): the baked vertices 1, 2, 3 and 6 of the face's six.
 01 WS-VIEW.
    05 WS-VF OCCURS 6 TIMES.
       10 WS-VK OCCURS 4 TIMES.
          15 WS-VC         FLOAT-LONG OCCURS 3 TIMES.
 01 WS-CENTRE.
    05 WS-CE               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-FACE-CENTRE.
    05 WS-FACE-AT OCCURS 6 TIMES.
       10 WS-FC            FLOAT-LONG OCCURS 3 TIMES.
 01 WS-E1                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-E2                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-NORMAL.
    05 WS-NV               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-OUT                 FLOAT-LONG.
 01 WS-D0                  FLOAT-LONG.
 01 WS-D1                  FLOAT-LONG.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-ZSUM                FLOAT-LONG.
 01 WS-VERTEX-AT-DATA      PIC X(8) VALUE "01020306".
 01 WS-VERTEX-AT REDEFINES WS-VERTEX-AT-DATA.
    05 WS-VA               PIC 99 OCCURS 4 TIMES.
 01 WS-ORDER-DATA          PIC X(6) VALUE "123134".
 01 WS-ORDER-TABLE REDEFINES WS-ORDER-DATA.
    05 WS-ORD              PIC 9 OCCURS 6 TIMES.
 01 WS-VI                  BINARY-LONG.
 01 WS-CORNER-NO           BINARY-LONG.
*> The faces that show: the lighting, the tint, the four corners (window x y, texture u v of the baked quad), kept until they are sorted by their mean depth.
 01 WS-KEYS.
    05 WS-KEY              FLOAT-LONG OCCURS 48 TIMES.
 01 WS-ORDERS.
    05 WS-ORDER            BINARY-LONG OCCURS 48 TIMES.
 01 WS-QUADS.
    05 WS-Q OCCURS 48 TIMES.
       10 WS-Q-TINT-R      FLOAT-SHORT.
       10 WS-Q-TINT-G      FLOAT-SHORT.
       10 WS-Q-TINT-B      FLOAT-SHORT.
       10 WS-Q-CORNER OCCURS 4 TIMES.
          15 WS-Q-X        FLOAT-SHORT.
          15 WS-Q-Y        FLOAT-SHORT.
          15 WS-Q-U        FLOAT-SHORT.
          15 WS-Q-V        FLOAT-SHORT.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO RL-PV-COUNT
     CALL "PREVIEW-WIDGET" USING CLIENT-STATE WS-W
     IF WS-W = 0
         MOVE 0 TO RL-PV-MOUSE-X RL-PV-MOUSE-Y
         GOBACK
     END-IF
*>   The box centre and the angles from the pointer of the frame before (49 section 4.2).
     COMPUTE WS-CX = SM-W-X(WS-W) + SM-W-W(WS-W) / 2
     COMPUTE WS-CY = SM-W-Y(WS-W) + SM-W-H(WS-W) / 2
     MOVE SM-W-ARG(WS-W) TO WS-SCALE
     COMPUTE WS-A = FUNCTION ATAN((WS-CX - RL-PV-MOUSE-X) / 40)
     COMPUTE WS-B = FUNCTION ATAN((WS-CY - RL-PV-MOUSE-Y) / 40)
*>   This frame's pointer, for the next (GUI pixels).
     COMPUTE RL-PV-MOUSE-X = IN-CURSOR-X / CL-GUI-SCALE
     COMPUTE RL-PV-MOUSE-Y = IN-CURSOR-Y / CL-GUI-SCALE
     IF EN-COUNT >= CL-MAX-ENTITIES
         GOBACK
     END-IF
*>   The figure on the spare row, at the origin, in the angles of the preview (49 section 4.2).
     COMPUTE WS-R = EN-COUNT + 1
     MOVE EN-ENTITY(WS-R) TO WS-SAVED
     CALL "LOCAL-FIGURE-SET" USING CLIENT-STATE WS-R
     MOVE 0 TO EN-X(WS-R) EN-Y(WS-R) EN-Z(WS-R)
     COMPUTE EN-YAW(WS-R) = 180 + WS-A * 20
     COMPUTE EN-HEAD-YAW(WS-R) = EN-YAW(WS-R) + WS-A * 20
     COMPUTE EN-PITCH(WS-R) = 0 - WS-B * 20
     IF PL-POSE = 1
         MOVE 0 TO EN-PITCH(WS-R)
     END-IF
     MOVE RL-EN-COUNT TO WS-START
     IF EN-MODEL(WS-R) > 0
         ADD 1 TO EN-COUNT
         CALL "ENTITY-MODEL-EMIT" USING CLIENT-STATE WS-R WS-EYE-TABLE
         SUBTRACT 1 FROM EN-COUNT
     END-IF
     MOVE WS-SAVED TO EN-ENTITY(WS-R)
*>   The whole figure is turned about X by b x 20 degrees (the quaternion of 49 section 4.2).
     COMPUTE WS-SIN = FUNCTION SIN(WS-B * 20 * FUNCTION PI / 180)
     COMPUTE WS-COS = FUNCTION COS(WS-B * 20 * FUNCTION PI / 180)
     COMPUTE WS-NC = (RL-EN-COUNT - WS-START) / 36
     MOVE 0 TO WS-N
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > WS-NC
*>       The face corners in the view space (turn about X, half a turn about Z, the lift of half the height 1.8 and 0.0625, the depth negated: 49 section 4.3), and the centre of the box (the mean of the face centres).
         MOVE 0 TO WS-CE(1) WS-CE(2) WS-CE(3)
         PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 6
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                 COMPUTE WS-J = WS-START + (WS-C - 1) * 36 + (WS-F - 1) * 6 + WS-VA(WS-K)
*>               The player's own scale of 12 section 7.3 step 4 (AvatarRenderer, 0.9375 about the feet), which ENTITY-MODEL-EMIT does not apply to a "player" row.
                 COMPUTE WS-X = RL-EN-X(WS-J) * 0.9375
                 COMPUTE WS-Y = RL-EN-Y(WS-J) * 0.9375
                 COMPUTE WS-Z = RL-EN-Z(WS-J) * 0.9375
                 COMPUTE WS-T = WS-Y * WS-COS - WS-Z * WS-SIN
                 COMPUTE WS-Z = WS-Y * WS-SIN + WS-Z * WS-COS
                 COMPUTE WS-VC(WS-F, WS-K, 1) = 0 - WS-X
                 COMPUTE WS-VC(WS-F, WS-K, 2) = 0 - WS-T + 0.9625
                 COMPUTE WS-VC(WS-F, WS-K, 3) = 0 - WS-Z
             END-PERFORM
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 3
                 COMPUTE WS-FC(WS-F, WS-J) = (WS-VC(WS-F, 1, WS-J) + WS-VC(WS-F, 3, WS-J)) / 2
                 COMPUTE WS-CE(WS-J) = WS-CE(WS-J) + WS-FC(WS-F, WS-J) / 6
             END-PERFORM
         END-PERFORM
         PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 6
*>           The normal of the face from its first three corners, turned away from the box's centre.
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 3
                 COMPUTE WS-E1(WS-J) = WS-VC(WS-F, 2, WS-J) - WS-VC(WS-F, 1, WS-J)
                 COMPUTE WS-E2(WS-J) = WS-VC(WS-F, 3, WS-J) - WS-VC(WS-F, 2, WS-J)
             END-PERFORM
             COMPUTE WS-NV(1) = WS-E1(2) * WS-E2(3) - WS-E1(3) * WS-E2(2)
             COMPUTE WS-NV(2) = WS-E1(3) * WS-E2(1) - WS-E1(1) * WS-E2(3)
             COMPUTE WS-NV(3) = WS-E1(1) * WS-E2(2) - WS-E1(2) * WS-E2(1)
             COMPUTE WS-OUT = WS-NV(1) * (WS-FC(WS-F, 1) - WS-CE(1)) + WS-NV(2) * (WS-FC(WS-F, 2) - WS-CE(2))
                 + WS-NV(3) * (WS-FC(WS-F, 3) - WS-CE(3))
             COMPUTE WS-LEN = FUNCTION SQRT(WS-NV(1) * WS-NV(1) + WS-NV(2) * WS-NV(2) + WS-NV(3) * WS-NV(3))
             IF WS-LEN > 0.000000001
                 IF WS-OUT < 0
                     COMPUTE WS-LEN = 0 - WS-LEN
                 END-IF
                 COMPUTE WS-NV(1) = WS-NV(1) / WS-LEN
                 COMPUTE WS-NV(2) = WS-NV(2) / WS-LEN
                 COMPUTE WS-NV(3) = WS-NV(3) / WS-LEN
*>               The face shows when its outward normal looks at the viewer (a face seen edge-on adds nothing).
                 IF WS-NV(3) > 0.000001 AND WS-N < 48
                     ADD 1 TO WS-N
*>                   The ENTITY_IN_UI lights of 12 section 1.9: normalize(0.2, -1, 1) and normalize(-0.2, -1, 0), y down.
                     COMPUTE WS-D0 = FUNCTION MAX(0, 0.140028 * WS-NV(1) - 0.70014 * WS-NV(2) + 0.70014 * WS-NV(3))
                     COMPUTE WS-D1 = FUNCTION MAX(0, -0.196116 * WS-NV(1) - 0.980581 * WS-NV(2))
                     COMPUTE WS-LIGHT = FUNCTION MIN(1, (WS-D0 + WS-D1) * 0.6 + 0.4)
                     COMPUTE WS-J = WS-START + (WS-C - 1) * 36 + (WS-F - 1) * 6 + 1
                     COMPUTE WS-Q-TINT-R(WS-N) = RL-EN-R(WS-J) * WS-LIGHT
                     COMPUTE WS-Q-TINT-G(WS-N) = RL-EN-G(WS-J) * WS-LIGHT
                     COMPUTE WS-Q-TINT-B(WS-N) = RL-EN-BLUE(WS-J) * WS-LIGHT
                     MOVE 0 TO WS-ZSUM
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                         COMPUTE WS-J = WS-START + (WS-C - 1) * 36 + (WS-F - 1) * 6 + WS-VA(WS-K)
                         COMPUTE WS-Q-X(WS-N, WS-K) = (WS-CX + WS-SCALE * WS-VC(WS-F, WS-K, 1)) * CL-GUI-SCALE
                         COMPUTE WS-Q-Y(WS-N, WS-K) = (WS-CY + WS-SCALE * WS-VC(WS-F, WS-K, 2)) * CL-GUI-SCALE
                         MOVE RL-EN-U(WS-J) TO WS-Q-U(WS-N, WS-K)
                         MOVE RL-EN-V(WS-J) TO WS-Q-V(WS-N, WS-K)
                         COMPUTE WS-ZSUM = WS-ZSUM + WS-VC(WS-F, WS-K, 3)
                     END-PERFORM
                     MOVE WS-ZSUM TO WS-KEY(WS-N)
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE WS-START TO RL-EN-COUNT
*>   Far to near (the smaller mean depth first) into the layer, two triangles a face.
     CALL "SPECIAL-SORT" USING WS-N WS-KEYS WS-ORDERS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         MOVE WS-ORDER(WS-I) TO WS-SRC
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
             ADD 1 TO RL-PV-COUNT
             MOVE WS-ORD(WS-K) TO WS-CORNER-NO
             MOVE WS-Q-X(WS-SRC, WS-CORNER-NO) TO RL-PV-X(RL-PV-COUNT)
             MOVE WS-Q-Y(WS-SRC, WS-CORNER-NO) TO RL-PV-Y(RL-PV-COUNT)
             MOVE 0 TO RL-PV-Z(RL-PV-COUNT) RL-PV-SKY(RL-PV-COUNT)
             MOVE WS-Q-U(WS-SRC, WS-CORNER-NO) TO RL-PV-U(RL-PV-COUNT)
             MOVE WS-Q-V(WS-SRC, WS-CORNER-NO) TO RL-PV-V(RL-PV-COUNT)
             MOVE 1 TO RL-PV-B(RL-PV-COUNT) RL-PV-A(RL-PV-COUNT)
             MOVE WS-Q-TINT-R(WS-SRC) TO RL-PV-R(RL-PV-COUNT)
             MOVE WS-Q-TINT-G(WS-SRC) TO RL-PV-G(RL-PV-COUNT)
             MOVE WS-Q-TINT-B(WS-SRC) TO RL-PV-BLUE(RL-PV-COUNT)
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM PREVIEW-MESH.
