*> The hand in first person (US20; 12 section 6, 8.2; FR-021). HAND-INPUT: breaking (the left button pressed or held once the last swing is over), placing (the right
*> button pressed on a target) or attacking starts the swing (CL-SWING-AT). HAND-EQUIP runs the equip animation (12 section 6.2) on the 50 ms client tick. HAND-MESH builds
*> the shown item in view space as vanilla poses it (12 section 6.3): the arm transform, the swing (6.4, 300 ms = 6 ticks), then the model's display transform for
*> firstperson_righthand (8.2; the nearest model of the item's chain that names one, else the defaults of block/block and item/generated). A flat item is extruded
*> (08 section 5.7): front and back quads 1/16 block apart and an edge quad, showing one texel, wherever an opaque pixel borders a transparent one; a block item is the unit
*> cube. HAND-QUAD shades by the two-light formula of 12 section 1.9 and the light at the eye. RENDER-LIST-BUILD draws it with the projection alone, after a depth clear
*> (a draw record with slot -1; SUBMIT-FRAME calls cc_vk_clear_depth), so it is never inside a block. Not done: the arm of an empty hand (6.5), the left hand and
*> off hand, the use poses (6.6), view bobbing and sway (6.1), the cooldown dip (6.2) and the glint.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-INPUT.
*> USING CLIENT-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF SM-SCREEN = SCR-WORLD
         IF IN-BUTTON-PRESSED(CC-BUTTON-LEFT + 1) = 1
                 OR (IN-BUTTON-DOWN(CC-BUTTON-LEFT + 1) = 1 AND CL-NOW-MS - CL-SWING-AT >= CL-SWING-MS)
                 OR (IN-BUTTON-PRESSED(CC-BUTTON-RIGHT + 1) = 1 AND TG-HIT = 1)
             MOVE CL-NOW-MS TO CL-SWING-AT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM HAND-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-M-IDENT.
*> USING M (12 FLOAT-LONG: the 3 x 3 rotation by rows, then the translation): the identity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-M.
    05 L-MV                FLOAT-LONG OCCURS 12 TIMES.
 PROCEDURE DIVISION USING L-M.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE 0 TO L-MV(WS-I)
     END-PERFORM
     MOVE 1 TO L-MV(1) L-MV(5) L-MV(9)
     GOBACK.
 END PROGRAM HAND-M-IDENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-M-TRANSLATE.
*> USING M, x, y, z: M = M x translate(x, y, z) (a transform call multiplies on the right, 12 section 6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-M.
    05 L-MV                FLOAT-LONG OCCURS 12 TIMES.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-M L-X L-Y L-Z.
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 3
         COMPUTE L-MV(9 + WS-R) = L-MV(9 + WS-R) + L-MV((WS-R - 1) * 3 + 1) * L-X
             + L-MV((WS-R - 1) * 3 + 2) * L-Y + L-MV((WS-R - 1) * 3 + 3) * L-Z
     END-PERFORM
     GOBACK.
 END PROGRAM HAND-M-TRANSLATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-M-SCALE.
*> USING M, x, y, z: M = M x scale(x, y, z).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-M.
    05 L-MV                FLOAT-LONG OCCURS 12 TIMES.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-M L-X L-Y L-Z.
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 3
         COMPUTE L-MV((WS-R - 1) * 3 + 1) = L-MV((WS-R - 1) * 3 + 1) * L-X
         COMPUTE L-MV((WS-R - 1) * 3 + 2) = L-MV((WS-R - 1) * 3 + 2) * L-Y
         COMPUTE L-MV((WS-R - 1) * 3 + 3) = L-MV((WS-R - 1) * 3 + 3) * L-Z
     END-PERFORM
     GOBACK.
 END PROGRAM HAND-M-SCALE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-M-ROTATE.
*> USING M, axis (1 x, 2 y, 3 z), degrees: M = M x rotation about the axis (right-handed, as a quaternion axis rotation).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-C                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-Q                   FLOAT-LONG OCCURS 9 TIMES.
 01 WS-R                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-A                   FLOAT-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 01 L-M.
    05 L-MV                FLOAT-LONG OCCURS 12 TIMES.
 01 L-AXIS                 BINARY-LONG.
 01 L-DEG                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-M L-AXIS L-DEG.
     COMPUTE WS-C = FUNCTION COS(L-DEG * FUNCTION PI / 180)
     COMPUTE WS-S = FUNCTION SIN(L-DEG * FUNCTION PI / 180)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 9
         MOVE 0 TO WS-Q(WS-K)
     END-PERFORM
     EVALUATE L-AXIS
         WHEN 1
             MOVE 1 TO WS-Q(1)
             MOVE WS-C TO WS-Q(5) WS-Q(9)
             COMPUTE WS-Q(6) = 0 - WS-S
             MOVE WS-S TO WS-Q(8)
         WHEN 2
             MOVE 1 TO WS-Q(5)
             MOVE WS-C TO WS-Q(1) WS-Q(9)
             MOVE WS-S TO WS-Q(3)
             COMPUTE WS-Q(7) = 0 - WS-S
         WHEN OTHER
             MOVE 1 TO WS-Q(9)
             MOVE WS-C TO WS-Q(1) WS-Q(5)
             COMPUTE WS-Q(2) = 0 - WS-S
             MOVE WS-S TO WS-Q(4)
     END-EVALUATE
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 3
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
             COMPUTE WS-A(WS-K) = L-MV((WS-R - 1) * 3 + 1) * WS-Q(WS-K) + L-MV((WS-R - 1) * 3 + 2) * WS-Q(3 + WS-K)
                 + L-MV((WS-R - 1) * 3 + 3) * WS-Q(6 + WS-K)
         END-PERFORM
         MOVE WS-A(1) TO L-MV((WS-R - 1) * 3 + 1)
         MOVE WS-A(2) TO L-MV((WS-R - 1) * 3 + 2)
         MOVE WS-A(3) TO L-MV((WS-R - 1) * 3 + 3)
     END-PERFORM
     GOBACK.
 END PROGRAM HAND-M-ROTATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-EQUIP.
*> USING CLIENT-STATE, equip offset E out (12 section 6.2): the shown stack CL-HAND-ITEM (item + 1, 0 none) follows the selected one through the height
*> CL-HAND-H: every 50 ms tick oh = h and h moves toward 1 (the shown stack is the selected one) or 0 by at most 0.4; below 0.1 the shown stack becomes the
*> selected one. E = 1 - lerp(partial tick, oh, h). A clock that was never started, or a frame gap over 400 ms, restarts the tick clock without ticks.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-WANT                FLOAT-LONG.
 01 WS-STEP                FLOAT-LONG.
 01 WS-CURRENT             BINARY-LONG.
 01 WS-PARTIAL             FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-E                    FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-E.
     MOVE 0 TO WS-CURRENT
     IF PL-SLOT-COUNT(PL-HELD + 1) > 0
         COMPUTE WS-CURRENT = PL-SLOT-ITEM(PL-HELD + 1) + 1
     END-IF
     IF CL-HAND-TICK-MS = 0 OR CL-NOW-MS < CL-HAND-TICK-MS OR CL-NOW-MS - CL-HAND-TICK-MS > 400
         MOVE CL-NOW-MS TO CL-HAND-TICK-MS
     END-IF
     PERFORM UNTIL CL-NOW-MS - CL-HAND-TICK-MS < 50
         MOVE CL-HAND-H TO CL-HAND-OH
         MOVE 0 TO WS-WANT
         IF CL-HAND-ITEM = WS-CURRENT
             MOVE 1 TO WS-WANT
         END-IF
         COMPUTE WS-STEP = FUNCTION MAX(-0.4, FUNCTION MIN(0.4, WS-WANT - CL-HAND-H))
         ADD WS-STEP TO CL-HAND-H
         IF CL-HAND-H < 0.1
             MOVE WS-CURRENT TO CL-HAND-ITEM
         END-IF
         ADD 50 TO CL-HAND-TICK-MS
     END-PERFORM
     COMPUTE WS-PARTIAL = (CL-NOW-MS - CL-HAND-TICK-MS) / 50
     COMPUTE L-E = 1 - (CL-HAND-OH + WS-PARTIAL * (CL-HAND-H - CL-HAND-OH))
     GOBACK.
 END PROGRAM HAND-EQUIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-QUAD.
*> USING CLIENT-STATE, M (the model to view transform), corners (4 x, y, z, in model space, in the order of a texture: top-left, top-right, bottom-right,
*> bottom-left), texture coordinates (4 u then 4 v, atlas), normal (model space), light 0 to 1: adds the six vertices of the quad (corners 1 2 3 1 3 4) to the
*> hand, shaded by the two-light formula of 12 section 1.9 (min(1, (max(0, n.L0) + max(0, n.L1)) x 0.6 + 0.4), the lights of the level in view space)
*> times the light, at least 0.1. A full mesh (2048 vertices) takes no more.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ORDER-DATA          PIC X(6) VALUE "123134".
 01 WS-ORDER REDEFINES WS-ORDER-DATA.
    05 WS-ORD              PIC 9 OCCURS 6 TIMES.
 01 WS-N                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-D0                  FLOAT-LONG.
 01 WS-D1                  FLOAT-LONG.
 01 WS-SHADE               FLOAT-LONG.
 01 WS-P                   FLOAT-LONG OCCURS 12 TIMES.
 01 WS-R                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-M.
    05 L-MV                FLOAT-LONG OCCURS 12 TIMES.
 01 L-CORNERS.
    05 L-CP                FLOAT-LONG OCCURS 12 TIMES.
 01 L-UV.
    05 L-U                 FLOAT-SHORT OCCURS 4 TIMES.
    05 L-V                 FLOAT-SHORT OCCURS 4 TIMES.
 01 L-NORMAL.
    05 L-NV                FLOAT-LONG OCCURS 3 TIMES.
 01 L-LIGHT                FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-M L-CORNERS L-UV L-NORMAL L-LIGHT.
     IF RL-HAND-COUNT + 6 > 2048
         GOBACK
     END-IF
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 3
         COMPUTE WS-N(WS-R) = L-MV((WS-R - 1) * 3 + 1) * L-NV(1) + L-MV((WS-R - 1) * 3 + 2) * L-NV(2)
             + L-MV((WS-R - 1) * 3 + 3) * L-NV(3)
     END-PERFORM
     COMPUTE WS-LEN = FUNCTION SQRT(WS-N(1) * WS-N(1) + WS-N(2) * WS-N(2) + WS-N(3) * WS-N(3))
     IF WS-LEN > 0
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 3
             COMPUTE WS-N(WS-R) = WS-N(WS-R) / WS-LEN
         END-PERFORM
     END-IF
     COMPUTE WS-D0 = FUNCTION MAX(0, 0.16169 * WS-N(1) + 0.808452 * WS-N(2) - 0.565916 * WS-N(3))
     COMPUTE WS-D1 = FUNCTION MAX(0, -0.16169 * WS-N(1) + 0.808452 * WS-N(2) + 0.565916 * WS-N(3))
     COMPUTE WS-SHADE = FUNCTION MIN(1, (WS-D0 + WS-D1) * 0.6 + 0.4)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 3
             COMPUTE WS-P((WS-K - 1) * 3 + WS-R) = L-MV((WS-R - 1) * 3 + 1) * L-CP((WS-K - 1) * 3 + 1)
                 + L-MV((WS-R - 1) * 3 + 2) * L-CP((WS-K - 1) * 3 + 2) + L-MV((WS-R - 1) * 3 + 3) * L-CP((WS-K - 1) * 3 + 3)
                 + L-MV(9 + WS-R)
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-V FROM 1 BY 1 UNTIL WS-V > 6
         MOVE WS-ORD(WS-V) TO WS-K
         ADD 1 TO RL-HAND-COUNT
         COMPUTE WS-C = (WS-K - 1) * 3
         MOVE WS-P(WS-C + 1) TO RL-HAND-X(RL-HAND-COUNT)
         MOVE WS-P(WS-C + 2) TO RL-HAND-Y(RL-HAND-COUNT)
         MOVE WS-P(WS-C + 3) TO RL-HAND-Z(RL-HAND-COUNT)
         MOVE L-U(WS-K) TO RL-HAND-U(RL-HAND-COUNT)
         MOVE L-V(WS-K) TO RL-HAND-V(RL-HAND-COUNT)
         COMPUTE RL-HAND-B(RL-HAND-COUNT) = FUNCTION MAX(WS-SHADE * L-LIGHT, 0.1)
         MOVE 1 TO RL-HAND-A(RL-HAND-COUNT)
         MOVE 0 TO RL-HAND-SKY(RL-HAND-COUNT)
         MOVE 1 TO RL-HAND-R(RL-HAND-COUNT) RL-HAND-G(RL-HAND-COUNT) RL-HAND-BLUE(RL-HAND-COUNT)
     END-PERFORM
     GOBACK.
 END PROGRAM HAND-QUAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-MESH.
*> USING CLIENT-STATE: RL-HAND-VERTEX and RL-HAND-COUNT for this frame (none, a cube of 36 vertices or an extruded icon).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CONTENT.
 01 WS-CORNER-DATA.
    05 FILLER PIC X(12) VALUE "011111101001".
    05 FILLER PIC X(12) VALUE "110010000100".
    05 FILLER PIC X(12) VALUE "111110100101".
    05 FILLER PIC X(12) VALUE "010011001000".
    05 FILLER PIC X(12) VALUE "010110111011".
    05 FILLER PIC X(12) VALUE "100000001101".
 01 WS-CORNER-TABLE REDEFINES WS-CORNER-DATA.
    05 WS-FACE OCCURS 6 TIMES.
       10 WS-PICK            PIC 9 OCCURS 12 TIMES.
*> The outward normal of each face of the corner table: south, north, east, west, up, down.
 01 WS-NORMALS.
    05 WS-NRM OCCURS 6 TIMES.
       10 WS-NRM-V           FLOAT-LONG OCCURS 3 TIMES.
 01 WS-DIR-DATA            PIC X(6) VALUE "436521".
 01 WS-DIR-TABLE REDEFINES WS-DIR-DATA.
    05 WS-FACE-DIR         PIC 9 OCCURS 6 TIMES.
 01 WS-M.
    05 WS-MV               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-E                   FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-DEG                 FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-Q                   FLOAT-LONG.
 01 WS-HAVE                BINARY-LONG.
 01 WS-VAL.
    05 WS-DV               FLOAT-LONG OCCURS 9 TIMES.
 01 WS-HBLOCK              BINARY-LONG.
 01 WS-HTOOL               PIC X.
 01 WS-HFOOD               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-FACE-SPR            BINARY-LONG.
 01 WS-DIRECTION           BINARY-LONG.
 01 WS-CUBE                BINARY-LONG.
 01 WS-STD                 BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-OFF                 BINARY-LONG.
 01 WS-OPAQUE              PIC 9 OCCURS 1024 TIMES.
 01 WS-EDGE                PIC 9.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-EX                  BINARY-LONG.
 01 WS-EY                  BINARY-LONG.
 01 WS-EZ                  BINARY-LONG.
 01 WS-CORNERS.
    05 WS-CP               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-UV.
    05 WS-U16              FLOAT-SHORT OCCURS 4 TIMES.
    05 WS-V16              FLOAT-SHORT OCCURS 4 TIMES.
 01 WS-TEXEL.
    05 WS-TU               FLOAT-SHORT OCCURS 4 TIMES.
    05 WS-TV               FLOAT-SHORT OCCURS 4 TIMES.
 01 WS-N3.
    05 WS-NV               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-LO                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-HI                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-X0                  FLOAT-LONG.
 01 WS-X1                  FLOAT-LONG.
 01 WS-Y0                  FLOAT-LONG.
 01 WS-Y1                  FLOAT-LONG.
 01 WS-CELL                FLOAT-LONG.
 01 WS-PREV-COUNT          BINARY-LONG.
 01 WS-STILL               BINARY-LONG.
 01 B-ATLAS                PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO RL-HAND-COUNT RL-HAND-SAME
     MOVE CL-HAND-KEY-COUNT TO WS-PREV-COUNT
     MOVE 0 TO CL-HAND-KEY-COUNT
     IF SM-SCREEN = SCR-WORLD AND CL-CAMERA = 0
         CALL "HAND-EQUIP" USING CLIENT-STATE WS-E
     ELSE
         GOBACK
     END-IF
     IF CL-HAND-ITEM = 0
         GOBACK
     END-IF
     COMPUTE WS-ITEM = CL-HAND-ITEM - 1
     CALL "ITEM-SPRITE-OF" USING CLIENT-STATE WS-ITEM WS-SPRITE
     IF WS-SPRITE = 0
         GOBACK
     END-IF
*>   The light at the eye (like an entity: the larger of the sky light by the daylight and the block light, of 15).
     COMPUTE WS-EX = FUNCTION INTEGER(PL-X)
     COMPUTE WS-EY = FUNCTION INTEGER(PL-Y + 1.62)
     COMPUTE WS-EZ = FUNCTION INTEGER(PL-Z)
     CALL "WORLD-CELL" USING CLIENT-STATE WS-EX WS-EY WS-EZ WS-STATE WS-SKY WS-BLK
     COMPUTE WS-LIGHT = FUNCTION MAX(WS-SKY * SK-U / 1000, WS-BLK) / 15
     CALL "CL-ITEM-FLAGS" USING CLIENT-STATE WS-ITEM WS-HBLOCK WS-HTOOL WS-HFOOD
*>   A block item is the unit cube when its model has faces (a standard set) or it is a stand-in block; any other item is an extruded icon.
     MOVE 0 TO WS-STD
     IF CT-OPEN = 1 AND CT-STATE-COUNT > 0 AND CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT
         MOVE 1 TO WS-STD
     END-IF
     MOVE 0 TO WS-CUBE
     IF WS-HBLOCK = 1 AND (WS-STD = 0 OR IS-FACE-DONE(WS-ITEM + 1) = 1)
         MOVE 1 TO WS-CUBE
     END-IF
*>   The display transform of the model, else the default of block/block or item/generated (12 section 8.2).
     CALL "ITEM-HAND-DISPLAY" USING CLIENT-STATE WS-ITEM WS-HAVE WS-VAL
     IF WS-HAVE = 2
         GOBACK
     END-IF
*>   Nothing swings and nothing changed since the last frame (the item, its sprite, the equip height, the light): the mesh built then
*>   is still in RL-HAND-VERTEX and in the GPU slot, so it is neither built nor uploaded again.
     MOVE 1 TO WS-STILL
     IF CL-SWING-AT > 0 AND CL-NOW-MS >= CL-SWING-AT AND CL-NOW-MS - CL-SWING-AT < CL-SWING-MS
         MOVE 0 TO WS-STILL
     END-IF
     IF WS-STILL = 1 AND WS-PREV-COUNT > 0 AND CL-HAND-KEY-ITEM = WS-ITEM AND CL-HAND-KEY-SPRITE = WS-SPRITE
             AND CL-HAND-KEY-E = WS-E AND CL-HAND-KEY-LIGHT = WS-LIGHT
         MOVE WS-PREV-COUNT TO RL-HAND-COUNT CL-HAND-KEY-COUNT
         MOVE 1 TO RL-HAND-SAME
         GOBACK
     END-IF
     IF WS-STILL = 1
         MOVE WS-ITEM TO CL-HAND-KEY-ITEM
         MOVE WS-SPRITE TO CL-HAND-KEY-SPRITE
         MOVE WS-E TO CL-HAND-KEY-E
         MOVE WS-LIGHT TO CL-HAND-KEY-LIGHT
     END-IF
     IF WS-HAVE = 0
         IF WS-CUBE = 1
             MOVE 0 TO WS-DV(1) WS-DV(3) WS-DV(4) WS-DV(5) WS-DV(6)
             MOVE 45 TO WS-DV(2)
             MOVE 0.4 TO WS-DV(7) WS-DV(8) WS-DV(9)
         ELSE
             MOVE 0 TO WS-DV(1)
             MOVE -90 TO WS-DV(2)
             MOVE 25 TO WS-DV(3)
             MOVE 1.13 TO WS-DV(4) WS-DV(6)
             MOVE 3.2 TO WS-DV(5)
             MOVE 0.68 TO WS-DV(7) WS-DV(8) WS-DV(9)
         END-IF
     END-IF
*>   The arm transform, then the swing of progress p = (now - start) / 300 ms (whack).
     CALL "HAND-M-IDENT" USING WS-M
     MOVE 0.56 TO WS-AX
     COMPUTE WS-AY = -0.52 + WS-E * -0.6
     MOVE -0.72 TO WS-AZ
     CALL "HAND-M-TRANSLATE" USING WS-M WS-AX WS-AY WS-AZ
     IF CL-SWING-AT > 0 AND CL-NOW-MS >= CL-SWING-AT AND CL-NOW-MS - CL-SWING-AT < CL-SWING-MS
         COMPUTE WS-P = (CL-NOW-MS - CL-SWING-AT) / CL-SWING-MS
         COMPUTE WS-Q = FUNCTION SQRT(WS-P)
         COMPUTE WS-AX = -0.4 * FUNCTION SIN(WS-Q * FUNCTION PI)
         COMPUTE WS-AY = 0.2 * FUNCTION SIN(WS-Q * 2 * FUNCTION PI)
         COMPUTE WS-AZ = -0.2 * FUNCTION SIN(WS-P * FUNCTION PI)
         CALL "HAND-M-TRANSLATE" USING WS-M WS-AX WS-AY WS-AZ
         MOVE 2 TO WS-AXIS
         COMPUTE WS-DEG = 45 + FUNCTION SIN(WS-P * WS-P * FUNCTION PI) * -20
         CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
         MOVE 3 TO WS-AXIS
         COMPUTE WS-DEG = FUNCTION SIN(WS-Q * FUNCTION PI) * -20
         CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
         MOVE 1 TO WS-AXIS
         COMPUTE WS-DEG = FUNCTION SIN(WS-Q * FUNCTION PI) * -80
         CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
         MOVE 2 TO WS-AXIS
         MOVE -45 TO WS-DEG
         CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
     END-IF
*>   ItemTransform.apply: translate, rotationXYZ, scale, translate(-0.5).
     COMPUTE WS-AX = WS-DV(4) / 16
     COMPUTE WS-AY = WS-DV(5) / 16
     COMPUTE WS-AZ = WS-DV(6) / 16
     CALL "HAND-M-TRANSLATE" USING WS-M WS-AX WS-AY WS-AZ
     PERFORM VARYING WS-AXIS FROM 1 BY 1 UNTIL WS-AXIS > 3
         MOVE WS-DV(WS-AXIS) TO WS-DEG
         CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
     END-PERFORM
     MOVE WS-DV(7) TO WS-AX
     MOVE WS-DV(8) TO WS-AY
     MOVE WS-DV(9) TO WS-AZ
     CALL "HAND-M-SCALE" USING WS-M WS-AX WS-AY WS-AZ
     MOVE -0.5 TO WS-AX WS-AY WS-AZ
     CALL "HAND-M-TRANSLATE" USING WS-M WS-AX WS-AY WS-AZ
     MOVE 0 TO WS-LO(1) WS-LO(2) WS-LO(3)
     MOVE 1 TO WS-HI(1) WS-HI(2) WS-HI(3)
*>   Normals of the corner table's faces.
     MOVE 0 TO WS-NRM-V(1, 1) WS-NRM-V(1, 2) WS-NRM-V(2, 1) WS-NRM-V(2, 2) WS-NRM-V(3, 2) WS-NRM-V(3, 3)
         WS-NRM-V(4, 2) WS-NRM-V(4, 3) WS-NRM-V(5, 1) WS-NRM-V(5, 3) WS-NRM-V(6, 1) WS-NRM-V(6, 3)
     MOVE 1 TO WS-NRM-V(1, 3) WS-NRM-V(3, 1) WS-NRM-V(5, 2)
     MOVE -1 TO WS-NRM-V(2, 3) WS-NRM-V(4, 1) WS-NRM-V(6, 2)
*>   Corner texels of the icon: top-left, top-right, bottom-right, bottom-left.
     MOVE 0 TO WS-U16(1) WS-V16(1) WS-V16(2) WS-U16(4)
     MOVE 16 TO WS-U16(2) WS-U16(3) WS-V16(3) WS-V16(4)
     IF WS-CUBE = 1
         PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 6
             MOVE WS-SPRITE TO WS-FACE-SPR
             IF WS-STD = 1
                 MOVE WS-FACE-DIR(WS-F) TO WS-DIRECTION
                 CALL "ITEM-FACE-SPRITE" USING CLIENT-STATE WS-ITEM WS-DIRECTION WS-FACE-SPR
             END-IF
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                 CALL "ATLAS-UV" USING CLIENT-STATE WS-FACE-SPR WS-U16(WS-K) WS-V16(WS-K) WS-TU(WS-K) WS-TV(WS-K)
             END-PERFORM
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                 PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                     COMPUTE WS-C = (WS-K - 1) * 3 + WS-A
                     IF WS-PICK(WS-F, WS-C) = 0
                         MOVE WS-LO(WS-A) TO WS-CP(WS-C)
                     ELSE
                         MOVE WS-HI(WS-A) TO WS-CP(WS-C)
                     END-IF
                 END-PERFORM
             END-PERFORM
             MOVE WS-NRM-V(WS-F, 1) TO WS-NV(1)
             MOVE WS-NRM-V(WS-F, 2) TO WS-NV(2)
             MOVE WS-NRM-V(WS-F, 3) TO WS-NV(3)
             CALL "HAND-QUAD" USING CLIENT-STATE WS-M WS-CORNERS WS-TEXEL WS-N3 WS-LIGHT
         END-PERFORM
         IF WS-STILL = 1
             MOVE RL-HAND-COUNT TO CL-HAND-KEY-COUNT
         END-IF
         GOBACK
     END-IF
*>   An extruded icon: the whole icon on the front (z 8.5/16) and the back (z 7.5/16) ...
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-U16(WS-K) WS-V16(WS-K) WS-TU(WS-K) WS-TV(WS-K)
     END-PERFORM
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 2
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
             PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
                 COMPUTE WS-C = (WS-K - 1) * 3 + WS-A
                 IF WS-A = 3
                     COMPUTE WS-CP(WS-C) = (19 - 2 * WS-F) / 32
                 ELSE
                     IF WS-PICK(WS-F, WS-C) = 0
                         MOVE 0 TO WS-CP(WS-C)
                     ELSE
                         MOVE 1 TO WS-CP(WS-C)
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
         MOVE WS-NRM-V(WS-F, 1) TO WS-NV(1)
         MOVE WS-NRM-V(WS-F, 2) TO WS-NV(2)
         MOVE WS-NRM-V(WS-F, 3) TO WS-NV(3)
         CALL "HAND-QUAD" USING CLIENT-STATE WS-M WS-CORNERS WS-TEXEL WS-N3 WS-LIGHT
     END-PERFORM
*>   ... and an edge quad where an opaque pixel (alpha above 0) borders a transparent one or the icon's rim, showing that pixel's texel.
     MOVE AT-SW(WS-SPRITE) TO WS-N
     IF WS-N > 32
         MOVE 32 TO WS-N
     END-IF
     SET ADDRESS OF B-ATLAS TO AT-ADDR
     PERFORM VARYING WS-PY FROM 0 BY 1 UNTIL WS-PY >= WS-N
         PERFORM VARYING WS-PX FROM 0 BY 1 UNTIL WS-PX >= WS-N
             COMPUTE WS-OFF = ((AT-Y(WS-SPRITE) + WS-PY) * AT-W + AT-X(WS-SPRITE) + WS-PX) * 4 + 4
             MOVE 0 TO WS-OPAQUE(WS-PY * WS-N + WS-PX + 1)
             IF FUNCTION ORD(B-ATLAS(WS-OFF:1)) > 1
                 MOVE 1 TO WS-OPAQUE(WS-PY * WS-N + WS-PX + 1)
             END-IF
         END-PERFORM
     END-PERFORM
     COMPUTE WS-CELL = 1 / WS-N
     PERFORM VARYING WS-PY FROM 0 BY 1 UNTIL WS-PY >= WS-N
         PERFORM VARYING WS-PX FROM 0 BY 1 UNTIL WS-PX >= WS-N
             IF WS-OPAQUE(WS-PY * WS-N + WS-PX + 1) = 1
*>               The texel of the pixel: its centre in sprite units, on all four corners.
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                     COMPUTE WS-U16(WS-K) = (WS-PX + 0.5) * 16 / WS-N
                     COMPUTE WS-V16(WS-K) = (WS-PY + 0.5) * 16 / WS-N
                     CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-U16(WS-K) WS-V16(WS-K) WS-TU(WS-K) WS-TV(WS-K)
                 END-PERFORM
                 COMPUTE WS-X0 = WS-PX * WS-CELL
                 COMPUTE WS-X1 = (WS-PX + 1) * WS-CELL
                 COMPUTE WS-Y0 = 1 - (WS-PY + 1) * WS-CELL
                 COMPUTE WS-Y1 = 1 - WS-PY * WS-CELL
                 PERFORM VARYING WS-SIDE FROM 1 BY 1 UNTIL WS-SIDE > 4
                     MOVE 0 TO WS-NX WS-NY
                     EVALUATE WS-SIDE
                         WHEN 1
                             MOVE -1 TO WS-NY
                         WHEN 2
                             MOVE 1 TO WS-NY
                         WHEN 3
                             MOVE -1 TO WS-NX
                         WHEN OTHER
                             MOVE 1 TO WS-NX
                     END-EVALUATE
                     MOVE 1 TO WS-EDGE
                     COMPUTE WS-A = WS-PX + WS-NX
                     COMPUTE WS-C = WS-PY + WS-NY
                     IF WS-A >= 0 AND WS-A < WS-N AND WS-C >= 0 AND WS-C < WS-N
                         IF WS-OPAQUE(WS-C * WS-N + WS-A + 1) = 1
                             MOVE 0 TO WS-EDGE
                         END-IF
                     END-IF
                     IF WS-EDGE = 1
                         EVALUATE WS-SIDE
                             WHEN 1
*>                               Up (the pixel above is clear): the top edge, along x.
                                 MOVE 0 TO WS-NV(1) WS-NV(3)
                                 MOVE 1 TO WS-NV(2)
                                 MOVE WS-X0 TO WS-CP(1) WS-CP(10)
                                 MOVE WS-X1 TO WS-CP(4) WS-CP(7)
                                 MOVE WS-Y1 TO WS-CP(2) WS-CP(5) WS-CP(8) WS-CP(11)
                                 MOVE 0.53125 TO WS-CP(3) WS-CP(6)
                                 MOVE 0.46875 TO WS-CP(9) WS-CP(12)
                             WHEN 2
                                 MOVE 0 TO WS-NV(1) WS-NV(3)
                                 MOVE -1 TO WS-NV(2)
                                 MOVE WS-X0 TO WS-CP(1) WS-CP(10)
                                 MOVE WS-X1 TO WS-CP(4) WS-CP(7)
                                 MOVE WS-Y0 TO WS-CP(2) WS-CP(5) WS-CP(8) WS-CP(11)
                                 MOVE 0.53125 TO WS-CP(3) WS-CP(6)
                                 MOVE 0.46875 TO WS-CP(9) WS-CP(12)
                             WHEN 3
                                 MOVE 0 TO WS-NV(2) WS-NV(3)
                                 MOVE -1 TO WS-NV(1)
                                 MOVE WS-X0 TO WS-CP(1) WS-CP(4) WS-CP(7) WS-CP(10)
                                 MOVE WS-Y1 TO WS-CP(2) WS-CP(5)
                                 MOVE WS-Y0 TO WS-CP(8) WS-CP(11)
                                 MOVE 0.53125 TO WS-CP(3) WS-CP(12)
                                 MOVE 0.46875 TO WS-CP(6) WS-CP(9)
                             WHEN OTHER
                                 MOVE 0 TO WS-NV(2) WS-NV(3)
                                 MOVE 1 TO WS-NV(1)
                                 MOVE WS-X1 TO WS-CP(1) WS-CP(4) WS-CP(7) WS-CP(10)
                                 MOVE WS-Y1 TO WS-CP(2) WS-CP(5)
                                 MOVE WS-Y0 TO WS-CP(8) WS-CP(11)
                                 MOVE 0.53125 TO WS-CP(3) WS-CP(12)
                                 MOVE 0.46875 TO WS-CP(6) WS-CP(9)
                         END-EVALUATE
                         CALL "HAND-QUAD" USING CLIENT-STATE WS-M WS-CORNERS WS-TEXEL WS-N3 WS-LIGHT
                     END-IF
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     IF WS-STILL = 1
         MOVE RL-HAND-COUNT TO CL-HAND-KEY-COUNT
     END-IF
     GOBACK.
 END PROGRAM HAND-MESH.
