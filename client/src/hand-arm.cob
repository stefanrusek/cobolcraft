*> The arm of an empty main hand in first person (12 section 6.5; 12 section 7.4 for the model; 47 section 6 for the skin). HAND-EMPTY-ARM appends the player model's arm of
*> the main arm and its sleeve to RL-HA-VERTEX (36 vertices a cuboid, the entity atlas slot of the model row "player", the default skin the third-person figure of the local player
*> wears too), under the pose of the arm: M = the view pose, then translate (s (-0.3 sin(q pi) + 0.64), 0.4 sin(2 q pi) - 0.6 - 0.6 E, -0.4 sin(p pi) - 0.72), rotate Y s 45, rotate Y
*> s sin(q pi) 70, rotate Z s sin(p^2 pi) (-20), translate (-s, 3.6, 3.5), rotate Z 120 s, rotate X 200, rotate Y -135 s, translate (5.6 s, 0, 0), with p the swing progress, q its
*> root, s the side (+1 right arm) and E the equip offset; the model's cuboids (pixels, the arm's pivot added, divided by 16) go through M. The sleeve (grow 0.25) is drawn unless the
*> option modelPart_<side>_sleeve is false. Nothing without a slot for the model in the entity atlas (ENTITY-MODEL-SLOTS makes one in a first-person view of a standard world).
*> HAND-CUBOID is the drawing of one model cuboid (the unwrap of 12 section 7.4 on an atlas slot) that the arm and the banner models share.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-EMPTY-ARM.
*> USING CLIENT-STATE, prefix (12 FLOAT-LONG, the view pose of HAND-PREFIX), side (+1 right, -1 left), equip offset E (FLOAT-LONG), light 0 to 1 (FLOAT-LONG).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
*> The cuboids, right arm and sleeve then left arm and sleeve: pivot x y z, origin x y z, size w h d (pixels), texture u v, grow (the wide arm of 12 section 7.4).
 01 WS-CUBE-DATA.
    05 FILLER PIC X(66) VALUE "-00500+00200+00000-00300-00200-00200+00400+01200+00400+040+016+000".
    05 FILLER PIC X(66) VALUE "-00500+00200+00000-00300-00200-00200+00400+01200+00400+040+032+025".
    05 FILLER PIC X(66) VALUE "+00500+00200+00000-00100-00200-00200+00400+01200+00400+032+048+000".
    05 FILLER PIC X(66) VALUE "+00500+00200+00000-00100-00200-00200+00400+01200+00400+048+048+025".
 01 WS-CUBES REDEFINES WS-CUBE-DATA.
    05 WS-CUBE OCCURS 4 TIMES.
       10 WS-CPX              PIC S999V99 SIGN LEADING SEPARATE.
       10 WS-CPY              PIC S999V99 SIGN LEADING SEPARATE.
       10 WS-CPZ              PIC S999V99 SIGN LEADING SEPARATE.
       10 WS-COX              PIC S999V99 SIGN LEADING SEPARATE.
       10 WS-COY              PIC S999V99 SIGN LEADING SEPARATE.
       10 WS-COZ              PIC S999V99 SIGN LEADING SEPARATE.
       10 WS-CW               PIC S999V99 SIGN LEADING SEPARATE.
       10 WS-CH               PIC S999V99 SIGN LEADING SEPARATE.
       10 WS-CD               PIC S999V99 SIGN LEADING SEPARATE.
       10 WS-CU               PIC S999 SIGN LEADING SEPARATE.
       10 WS-CV               PIC S999 SIGN LEADING SEPARATE.
       10 WS-CG               PIC S9V99 SIGN LEADING SEPARATE.
 01 WS-NAME                PIC X(40).
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(24) VALUE "player".
 01 WS-S                   BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-CUBE-NO             BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-Q                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-SIDE-F              FLOAT-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-DEG                 FLOAT-LONG.
 01 WS-M.
    05 WS-MV               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-GEOM.
    05 WS-GV               FLOAT-LONG OCCURS 15 TIMES.
 01 WS-TINT.
    05 WS-TV               FLOAT-LONG OCCURS 3 TIMES VALUE 1.
 COPY CLCONST.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PREFIX.
    05 L-PV                FLOAT-LONG OCCURS 12 TIMES.
 01 L-SIDE                 BINARY-LONG.
 01 L-E                    FLOAT-LONG.
 01 L-LIGHT                FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PREFIX L-SIDE L-E L-LIGHT.
     MOVE 0 TO RL-HA-COUNT
     CALL "ENTITY-MODEL-FIND" USING WS-KEY WS-ROW
     MOVE 0 TO WS-S
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > EA-MT-COUNT
         IF EA-MT-MODEL(WS-K) = WS-ROW AND EA-MT-TEX(WS-K) = 0
             MOVE WS-K TO WS-S
         END-IF
     END-PERFORM
     IF WS-S = 0 OR EA-W = 0 OR EA-H = 0
         GOBACK
     END-IF
*>   The swing progress of the arm (6.4: 300 ms, a swing begun at CL-SWING-AT) and the pose of 6.5.
     MOVE 0 TO WS-P
     IF CL-SWING-AT > 0 AND CL-NOW-MS >= CL-SWING-AT AND CL-NOW-MS - CL-SWING-AT < CL-SWING-MS
         COMPUTE WS-P = (CL-NOW-MS - CL-SWING-AT) / CL-SWING-MS
     END-IF
     COMPUTE WS-Q = FUNCTION SQRT(WS-P)
     MOVE L-SIDE TO WS-SIDE-F
     MOVE L-PREFIX TO WS-M
     COMPUTE WS-X = WS-SIDE-F * (-0.3 * FUNCTION SIN(WS-Q * FUNCTION PI) + 0.64)
     COMPUTE WS-Y = 0.4 * FUNCTION SIN(WS-Q * 2 * FUNCTION PI) - 0.6 + L-E * -0.6
     COMPUTE WS-Z = -0.4 * FUNCTION SIN(WS-P * FUNCTION PI) - 0.72
     CALL "HAND-M-TRANSLATE" USING WS-M WS-X WS-Y WS-Z
     MOVE 2 TO WS-AXIS
     COMPUTE WS-DEG = WS-SIDE-F * 45
     CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
     COMPUTE WS-DEG = WS-SIDE-F * FUNCTION SIN(WS-Q * FUNCTION PI) * 70
     CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
     MOVE 3 TO WS-AXIS
     COMPUTE WS-DEG = WS-SIDE-F * FUNCTION SIN(WS-P * WS-P * FUNCTION PI) * -20
     CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
     COMPUTE WS-X = WS-SIDE-F * -1
     MOVE 3.6 TO WS-Y
     MOVE 3.5 TO WS-Z
     CALL "HAND-M-TRANSLATE" USING WS-M WS-X WS-Y WS-Z
     COMPUTE WS-DEG = WS-SIDE-F * 120
     CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
     MOVE 1 TO WS-AXIS
     MOVE 200 TO WS-DEG
     CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
     MOVE 2 TO WS-AXIS
     COMPUTE WS-DEG = WS-SIDE-F * -135
     CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
     COMPUTE WS-X = WS-SIDE-F * 5.6
     MOVE 0 TO WS-Y WS-Z
     CALL "HAND-M-TRANSLATE" USING WS-M WS-X WS-Y WS-Z
*>   The cuboids of the arm (1 right, 3 left) and its sleeve unless the skin part is off.
     MOVE 1 TO WS-FIRST
     MOVE "modelPart_right_sleeve" TO WS-NAME
     IF L-SIDE < 0
         MOVE 3 TO WS-FIRST
         MOVE "modelPart_left_sleeve" TO WS-NAME
     END-IF
     MOVE WS-FIRST TO WS-LAST
     CALL "OPTIONS-GET" USING CLIENT-STATE WS-NAME WS-VALUE WS-LENGTH WS-FOUND
     IF WS-FOUND = 0 OR WS-VALUE(1:5) NOT = "false"
         ADD 1 TO WS-LAST
     END-IF
     PERFORM VARYING WS-CUBE-NO FROM WS-FIRST BY 1 UNTIL WS-CUBE-NO > WS-LAST
         MOVE WS-CPX(WS-CUBE-NO) TO WS-GV(1)
         MOVE WS-CPY(WS-CUBE-NO) TO WS-GV(2)
         MOVE WS-CPZ(WS-CUBE-NO) TO WS-GV(3)
         MOVE 0 TO WS-GV(4)
         MOVE WS-COX(WS-CUBE-NO) TO WS-GV(5)
         MOVE WS-COY(WS-CUBE-NO) TO WS-GV(6)
         MOVE WS-COZ(WS-CUBE-NO) TO WS-GV(7)
         MOVE WS-CW(WS-CUBE-NO) TO WS-GV(8)
         MOVE WS-CH(WS-CUBE-NO) TO WS-GV(9)
         MOVE WS-CD(WS-CUBE-NO) TO WS-GV(10)
         MOVE WS-CU(WS-CUBE-NO) TO WS-GV(11)
         MOVE WS-CV(WS-CUBE-NO) TO WS-GV(12)
         MOVE WS-CG(WS-CUBE-NO) TO WS-GV(13)
         MOVE 64 TO WS-GV(14) WS-GV(15)
         CALL "HAND-CUBOID" USING CLIENT-STATE WS-M WS-S WS-GEOM WS-TINT L-LIGHT
     END-PERFORM
     GOBACK.
 END PROGRAM HAND-EMPTY-ARM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-CUBOID.
*> USING CLIENT-STATE, M (12 FLOAT-LONG, HAND-M-IDENT layout: the model space in blocks to the view), entity atlas slot (EA-MT), geometry (15 FLOAT-LONG: the part's pivot x y z in
*> pixels, its rotation about X in radians, the cuboid's origin x y z, size w h d, texture offset u v, grow, the texture's width and height in pixels), tint (3 FLOAT-LONG), light 0 to 1:
*> appends the 36 vertices of the cuboid (the six faces down, up, west, north, east, south as ModelPart does, the texels of 12 section 7.4 on the slot's rectangle) to RL-HA-VERTEX
*> through HAND-QUAD mode 3, with the tint. A corner is the pivot plus the box corner turned about X, divided by 16.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-SIN                 FLOAT-LONG.
 01 WS-COS                 FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-MODE                BINARY-LONG VALUE 3.
 01 WS-BOX-IN.
    05 WS-BI               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-BOX-OUT.
    05 WS-BO               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-RC-IN.
    05 WS-RI               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-RC-OUT.
    05 WS-RO               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-FV-IN.
    05 WS-FI               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-FV-OUT.
    05 WS-FO               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-UV-IN.
    05 WS-UI               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-UV-OUT.
    05 WS-UO               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-FN-IN.
    05 WS-NI               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-FN-OUT.
    05 WS-NO               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-CORNERS.
    05 WS-CP               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-UV.
    05 WS-U4               FLOAT-SHORT OCCURS 4 TIMES.
    05 WS-V4               FLOAT-SHORT OCCURS 4 TIMES.
 01 WS-NORMAL.
    05 WS-NV               FLOAT-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-M.
    05 L-MV                FLOAT-LONG OCCURS 12 TIMES.
 01 L-SLOT                 BINARY-LONG.
 01 L-GEOM.
    05 L-G                 FLOAT-LONG OCCURS 15 TIMES.
 01 L-TINT.
    05 L-T                 FLOAT-LONG OCCURS 3 TIMES.
 01 L-LIGHT                FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-M L-SLOT L-GEOM L-TINT L-LIGHT.
     MOVE L-G(5) TO WS-BI(1)
     MOVE L-G(6) TO WS-BI(2)
     MOVE L-G(7) TO WS-BI(3)
     MOVE L-G(8) TO WS-BI(4)
     MOVE L-G(9) TO WS-BI(5)
     MOVE L-G(10) TO WS-BI(6)
     MOVE L-G(13) TO WS-BI(7) WS-BI(8) WS-BI(9)
     MOVE 0 TO WS-BI(10)
     CALL "EF7-BOX-CORNERS" USING WS-BOX-IN WS-BOX-OUT
     MOVE L-G(11) TO WS-RI(1)
     MOVE L-G(12) TO WS-RI(2)
     MOVE L-G(8) TO WS-RI(3)
     MOVE L-G(9) TO WS-RI(4)
     MOVE L-G(10) TO WS-RI(5)
     MOVE L-G(14) TO WS-RI(6)
     MOVE L-G(15) TO WS-RI(7)
     CALL "EF7-BOX-RECTS" USING WS-RC-IN WS-RC-OUT
     COMPUTE WS-SIN = FUNCTION SIN(L-G(4))
     COMPUTE WS-COS = FUNCTION COS(L-G(4))
     PERFORM VARYING WS-F FROM 0 BY 1 UNTIL WS-F > 5
         MOVE WS-F TO WS-FI(1)
         MOVE 0 TO WS-FI(2)
         CALL "EF7-FACE-VERTS" USING WS-FV-IN WS-FV-OUT
         COMPUTE WS-A = WS-F * 4
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
             COMPUTE WS-J = WS-FO(WS-K)
             COMPUTE WS-N = (WS-J - 1) * 3
             COMPUTE WS-BASE = (WS-K - 1) * 3
*>           The corner turned about the part's X axis, the pivot added, in blocks.
             COMPUTE WS-Y = WS-BO(WS-N + 2) * WS-COS - WS-BO(WS-N + 3) * WS-SIN
             COMPUTE WS-Z = WS-BO(WS-N + 2) * WS-SIN + WS-BO(WS-N + 3) * WS-COS
             COMPUTE WS-CP(WS-BASE + 1) = (WS-BO(WS-N + 1) + L-G(1)) / 16
             COMPUTE WS-CP(WS-BASE + 2) = (WS-Y + L-G(2)) / 16
             COMPUTE WS-CP(WS-BASE + 3) = (WS-Z + L-G(3)) / 16
             COMPUTE WS-UI(1) = WS-K - 1
             MOVE WS-RO(WS-A + 1) TO WS-UI(2)
             MOVE WS-RO(WS-A + 2) TO WS-UI(3)
             MOVE WS-RO(WS-A + 3) TO WS-UI(4)
             MOVE WS-RO(WS-A + 4) TO WS-UI(5)
             CALL "EF7-VERTEX-UV" USING WS-UV-IN WS-UV-OUT
             COMPUTE WS-U4(WS-K) = (EA-MT-X(L-SLOT) + WS-UO(1) * EA-MT-W(L-SLOT)) / EA-W
             COMPUTE WS-V4(WS-K) = (EA-MT-Y(L-SLOT) + WS-UO(2) * EA-MT-H(L-SLOT)) / EA-H
         END-PERFORM
         MOVE WS-F TO WS-NI(1)
         MOVE 0 TO WS-NI(2)
         CALL "EF7-FACE-NORMAL" USING WS-FN-IN WS-FN-OUT
         MOVE WS-NO(1) TO WS-NV(1)
         COMPUTE WS-NV(2) = WS-NO(2) * WS-COS - WS-NO(3) * WS-SIN
         COMPUTE WS-NV(3) = WS-NO(2) * WS-SIN + WS-NO(3) * WS-COS
         MOVE RL-HA-COUNT TO WS-BEFORE
         CALL "HAND-QUAD" USING CLIENT-STATE L-M WS-CORNERS WS-UV WS-NORMAL L-LIGHT WS-MODE
*>       The tint of the six vertices of the quad just added (none when the mesh was full).
         IF RL-HA-COUNT = WS-BEFORE + 6
             PERFORM VARYING WS-V FROM 0 BY 1 UNTIL WS-V > 5
                 COMPUTE WS-J = RL-HA-COUNT - WS-V
                 MOVE L-T(1) TO RL-HA-R(WS-J)
                 MOVE L-T(2) TO RL-HA-G(WS-J)
                 MOVE L-T(3) TO RL-HA-BLUE(WS-J)
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM HAND-CUBOID.
