*> The hand in first person (US20; 12 section 6, 8.2; FR-021). HAND-INPUT: breaking (the left button pressed or held once the last swing is over), placing (the right
*> button pressed on a target) or attacking starts the swing (CL-SWING-AT). HAND-EQUIP runs the equip animation (12 section 6.2) on the 50 ms client tick. HAND-MESH builds
*> the shown item in view space as vanilla poses it (12 section 6.3): the arm transform, the swing (6.4, 300 ms = 6 ticks), then the model's display transform for
*> firstperson_righthand (8.2; the nearest model of the item's chain that names one, else the defaults of block/block and item/generated). A flat item is extruded
*> (08 section 5.7): front and back quads 1/16 block apart and an edge quad, showing one texel, wherever an opaque pixel borders a transparent one; a block item is the unit
*> cube. HAND-QUAD drops the quads that face away from the eye (the hand pass culls back faces: 12 section 6.9; the shim's solid pipeline has no culling, so it is done
*> here) and shades the rest by the LEVEL lights of 12 section 6.10 (normals in world orientation, HAND-VIEW-ROT) and the light at the eye. HAND-PROJECT is the hand's own
*> projection (fixed 70 degrees, 6.9). RENDER-LIST-BUILD draws the mesh with that projection alone, after a depth clear (a draw record with slot -1; SUBMIT-FRAME calls
*> cc_vk_clear_depth), so it is never inside a block; the shim's solid pipeline tests less-or-equal with writes, the conventional form of the document's
*> greater-or-equal on a depth cleared to 0. Done in the files of this family: the arm of an empty hand (6.5; hand-arm.cob, T28300), the left hand and off hand (mainHand),
*> the use poses (6.6; use-item.cob and hand-pose.cob, T28200, T23000), view bobbing, sway, the cooldown dip (6.2) and the hurt tilt (6.1; hand-pose.cob, T23000, T23002), the
*> death tilt (T28000) and the glint (T23002). Not done: the level light map (the light at the eye is a brightness factor), the death fov (6.9) and the world shake of the bob (53 15.2).

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
*>       An attack on an entity restarts the attack strength ticker (17 section 4.1).
         IF IN-BUTTON-PRESSED(CC-BUTTON-LEFT + 1) = 1 AND TG-ENTITY-HIT = 1
             MOVE 0 TO CL-ATK-TICKER
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
*> USING CLIENT-STATE, equip offset E of the main hand out, equip offset of the off hand out, partial tick out (12 section 6.2): the shown stacks CL-HAND-ITEM and
*> CL-OHAND-ITEM (item + 1, 0 none) follow the selected and the off-hand stack through the heights CL-HAND-H and CL-OHAND-H: every 50 ms tick (HAND-TICK first) oh = h
*> and h moves toward the wanted height by at most 0.4 (1 when the shown stack is the current one, 0 otherwise; the main hand's 1 is multiplied by the cube of the
*> attack strength scale (ticker + 1) / D, so the held item drops while the attack cooldown recharges); below 0.1 the shown stack becomes the current one.
*> E = 1 - lerp(partial tick, oh, h). A clock that was never started, or a frame gap over 400 ms, restarts the tick clock without ticks.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-WANT                FLOAT-LONG.
 01 WS-STEP                FLOAT-LONG.
 01 WS-CURRENT             BINARY-LONG.
 01 WS-OCURRENT            BINARY-LONG.
 01 WS-DELAY               FLOAT-LONG.
 01 WS-SCALE               FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-E                    FLOAT-LONG.
 01 L-EO                   FLOAT-LONG.
 01 L-PART                 FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-E L-EO L-PART.
     MOVE 0 TO WS-CURRENT WS-OCURRENT
     IF PL-SLOT-COUNT(PL-HELD + 1) > 0
         COMPUTE WS-CURRENT = PL-SLOT-ITEM(PL-HELD + 1) + 1
     END-IF
     IF PL-OFFHAND-COUNT > 0
         COMPUTE WS-OCURRENT = PL-OFFHAND-ITEM + 1
     END-IF
     CALL "HAND-ATTACK-DELAY" USING CLIENT-STATE WS-CURRENT WS-DELAY
     IF CL-HAND-TICK-MS = 0 OR CL-NOW-MS < CL-HAND-TICK-MS OR CL-NOW-MS - CL-HAND-TICK-MS > 400
         MOVE CL-NOW-MS TO CL-HAND-TICK-MS
     END-IF
     PERFORM UNTIL CL-NOW-MS - CL-HAND-TICK-MS < 50
         CALL "HAND-TICK" USING CLIENT-STATE WS-CURRENT
         MOVE CL-HAND-H TO CL-HAND-OH
         MOVE CL-OHAND-H TO CL-OHAND-OH
         COMPUTE WS-SCALE = FUNCTION MIN(1, (CL-ATK-TICKER + 1) / WS-DELAY)
         MOVE 0 TO WS-WANT
         IF CL-HAND-ITEM = WS-CURRENT
             COMPUTE WS-WANT = WS-SCALE ** 3
         END-IF
         COMPUTE WS-STEP = FUNCTION MAX(-0.4, FUNCTION MIN(0.4, WS-WANT - CL-HAND-H))
         ADD WS-STEP TO CL-HAND-H
         IF CL-HAND-H < 0.1
             MOVE WS-CURRENT TO CL-HAND-ITEM
         END-IF
         MOVE 0 TO WS-WANT
         IF CL-OHAND-ITEM = WS-OCURRENT
             MOVE 1 TO WS-WANT
         END-IF
         COMPUTE WS-STEP = FUNCTION MAX(-0.4, FUNCTION MIN(0.4, WS-WANT - CL-OHAND-H))
         ADD WS-STEP TO CL-OHAND-H
         IF CL-OHAND-H < 0.1
             MOVE WS-OCURRENT TO CL-OHAND-ITEM
         END-IF
         ADD 50 TO CL-HAND-TICK-MS
     END-PERFORM
     COMPUTE L-PART = (CL-NOW-MS - CL-HAND-TICK-MS) / 50
     COMPUTE L-E = 1 - (CL-HAND-OH + L-PART * (CL-HAND-H - CL-HAND-OH))
     COMPUTE L-EO = 1 - (CL-OHAND-OH + L-PART * (CL-OHAND-H - CL-OHAND-OH))
     GOBACK.
 END PROGRAM HAND-EQUIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-VIEW-ROT.
*> USING yaw, pitch (view angles in degrees, FLOAT-LONG), Q (9 FLOAT-LONG by rows): the camera rotation Q = Ry(180 - yaw) x Rx(-pitch) of 12 section 6.7.2, which takes
*> a view-space direction to the world's (the normals of a held item are in world orientation, 6.10).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-C                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-CB                  FLOAT-LONG.
 01 WS-SB                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-YAW                  FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 01 L-Q.
    05 L-QV                FLOAT-LONG OCCURS 9 TIMES.
 PROCEDURE DIVISION USING L-YAW L-PITCH L-Q.
     COMPUTE WS-C = FUNCTION COS((180 - L-YAW) * FUNCTION PI / 180)
     COMPUTE WS-S = FUNCTION SIN((180 - L-YAW) * FUNCTION PI / 180)
     COMPUTE WS-CB = FUNCTION COS(L-PITCH * FUNCTION PI / 180)
     COMPUTE WS-SB = 0 - FUNCTION SIN(L-PITCH * FUNCTION PI / 180)
     MOVE WS-C TO L-QV(1)
     COMPUTE L-QV(2) = WS-S * WS-SB
     COMPUTE L-QV(3) = WS-S * WS-CB
     MOVE 0 TO L-QV(4)
     MOVE WS-CB TO L-QV(5)
     COMPUTE L-QV(6) = 0 - WS-SB
     COMPUTE L-QV(7) = 0 - WS-S
     COMPUTE L-QV(8) = WS-C * WS-SB
     COMPUTE L-QV(9) = WS-C * WS-CB
     GOBACK.
 END PROGRAM HAND-VIEW-ROT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-PROJECT.
*> USING CLIENT-STATE, projection (16 FLOAT-LONG, column-major, y down like the world's RL-PROJ): the hand pass's own perspective (12 section 6.9): vertical field of
*> view 70 degrees whatever the fov option and the sprint modifier are, scaled by 1 + fovEffectScale x (0.85714287 - 1) with the eye in water or lava; aspect = window
*> width / height; near 0.05, far 2048 (the far plane only moves the depth values).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FOV                 FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-ASPECT              FLOAT-LONG.
 01 WS-NEAR                FLOAT-LONG VALUE 0.05.
 01 WS-FAR                 FLOAT-LONG VALUE 2048.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PROJ.
    05 L-P                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-PROJ.
     MOVE 70 TO WS-FOV
     IF PL-EYE-WATER = 1 OR PL-EYE-LAVA = 1
         COMPUTE WS-FOV = 70 * (1 + CL-FOV-EFFECT * (0.85714287 - 1))
     END-IF
     COMPUTE WS-F = 1 / FUNCTION TAN(WS-FOV / 2 * FUNCTION PI / 180)
     COMPUTE WS-ASPECT = FUNCTION MAX(IN-WIN-W, 1) / FUNCTION MAX(IN-WIN-H, 1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE 0 TO L-P(WS-I)
     END-PERFORM
     COMPUTE L-P(1) = WS-F / WS-ASPECT
     COMPUTE L-P(6) = 0 - WS-F
     COMPUTE L-P(11) = WS-FAR / (WS-NEAR - WS-FAR)
     MOVE -1 TO L-P(12)
     COMPUTE L-P(15) = WS-NEAR * WS-FAR / (WS-NEAR - WS-FAR)
     GOBACK.
 END PROGRAM HAND-PROJECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-QUAD.
*> USING CLIENT-STATE, M (the model to view transform), corners (4 x, y, z, in model space, in the order of a texture seen from outside: top-left, top-right, bottom-right, bottom-left:
*> clockwise, the terrain's winding), texture coordinates (4 u then 4 v, atlas), normal (model space), light 0 to 1, glint (0 the item of the hand, 1 it with the glint, 2 only the glint
*> layer, 3 the empty hand's arm, 4 an item a mob holds, 5 a banner a mob holds), Q (HAND-VIEW-ROT): adds the six vertices of the quad (corners 1 2 3 1 3 4) to the mesh the mode names.
*> The item of the hand (0 to 2) is drawn as the hand pass of 12 section 6.9 and 6.10 says: a quad that faces away from the eye at the origin (cross(c2 - c1, c3 - c2) . c1 not above 0) is
*> dropped (CL-HAND-NOCULL 1 keeps them), and the shade is the LEVEL lights' min(1, (max(0, n.L0) + max(0, n.L1)) x 0.6 + 0.4) with n = Q x the quad's normal in view space, times the
*> light, at least 0.1. The arm (3) keeps the two-light formula in view space and no culling; in the world (4 and 5) the faces are shaded by their world direction as the entity models
*> are (up 1, down 0.5, east and west 0.6, north and south 0.8). A full mesh (2048 hand vertices) takes no more. With glint 5 the six vertices go to RL-EN-VERTEX (a banner held by a mob:
*> the entity atlas and mesh). With glint 3 they go to RL-HA-VERTEX and nowhere else; with glint 4 to RL-GI-VERTEX (the pose chain in entity-relative world coordinates; the caller sees to
*> the room). With glint 1 or 2 the same six vertices go to RL-HG-VERTEX as well (2: only there) with the glint coordinates of the atlas coordinates through the item scale 8 (GLINT-UV)
*> and the glint strength as brightness.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-ORDER-DATA          PIC X(6) VALUE "123134".
 01 WS-ORDER REDEFINES WS-ORDER-DATA.
    05 WS-ORD              PIC 9 OCCURS 6 TIMES.
 01 WS-N                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-W                   FLOAT-LONG OCCURS 3 TIMES.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-D0                  FLOAT-LONG.
 01 WS-D1                  FLOAT-LONG.
 01 WS-L1Y                 FLOAT-LONG.
 01 WS-SHADE               FLOAT-LONG.
 01 WS-P                   FLOAT-LONG OCCURS 12 TIMES.
 01 WS-E1                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-E2                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-FACING              FLOAT-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-GU                  FLOAT-LONG.
 01 WS-GV                  FLOAT-LONG.
 01 WS-GSCALE              FLOAT-LONG VALUE 8.
 01 WS-GSTRENGTH           FLOAT-LONG.
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
 01 L-GLINT                BINARY-LONG.
 01 L-Q.
    05 L-QV                FLOAT-LONG OCCURS 9 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-M L-CORNERS L-UV L-NORMAL L-LIGHT L-GLINT L-Q.
     IF L-GLINT NOT = 2 AND L-GLINT NOT = 3 AND L-GLINT NOT = 4 AND L-GLINT NOT = 5 AND RL-HAND-COUNT + 6 > 2048
         GOBACK
     END-IF
     IF L-GLINT = 5 AND RL-EN-COUNT + 6 > CL-MAX-ENTITY-VERTICES
         GOBACK
     END-IF
     IF (L-GLINT = 1 OR L-GLINT = 2) AND RL-HG-COUNT + 6 > 4096
         GOBACK
     END-IF
     IF L-GLINT = 3 AND RL-HA-COUNT + 6 > 1024
         GOBACK
     END-IF
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 3
             COMPUTE WS-P((WS-K - 1) * 3 + WS-R) = L-MV((WS-R - 1) * 3 + 1) * L-CP((WS-K - 1) * 3 + 1)
                 + L-MV((WS-R - 1) * 3 + 2) * L-CP((WS-K - 1) * 3 + 2) + L-MV((WS-R - 1) * 3 + 3) * L-CP((WS-K - 1) * 3 + 3)
                 + L-MV(9 + WS-R)
         END-PERFORM
     END-PERFORM
*>   Back faces of the item of the hand are not drawn: the quad is seen clockwise from the eye (the origin of view space) exactly when cross(c2 - c1, c3 - c2) . c1 is above 0.
     IF L-GLINT <= 2
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 3
             COMPUTE WS-E1(WS-R) = WS-P(3 + WS-R) - WS-P(WS-R)
             COMPUTE WS-E2(WS-R) = WS-P(6 + WS-R) - WS-P(3 + WS-R)
         END-PERFORM
         COMPUTE WS-FACING = (WS-E1(2) * WS-E2(3) - WS-E1(3) * WS-E2(2)) * WS-P(1)
             + (WS-E1(3) * WS-E2(1) - WS-E1(1) * WS-E2(3)) * WS-P(2)
             + (WS-E1(1) * WS-E2(2) - WS-E1(2) * WS-E2(1)) * WS-P(3)
         IF CL-HAND-NOCULL NOT = 1 AND WS-FACING <= 0
             GOBACK
         END-IF
     END-IF
*>   The normal in view space.
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
     IF L-GLINT <= 2
*>       The item of the hand: the normal in world orientation (the camera rotation Q put back, 6.7.2) and the second light of the Nether pointing down (normalize(-0.2, -1, 0.7)).
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 3
             COMPUTE WS-W(WS-R) = L-QV((WS-R - 1) * 3 + 1) * WS-N(1) + L-QV((WS-R - 1) * 3 + 2) * WS-N(2) + L-QV((WS-R - 1) * 3 + 3) * WS-N(3)
         END-PERFORM
         MOVE 0.808452 TO WS-L1Y
         IF PL-DIM-NAME = "minecraft:the_nether"
             MOVE -0.808452 TO WS-L1Y
         END-IF
         COMPUTE WS-D0 = FUNCTION MAX(0, 0.16169 * WS-W(1) + 0.808452 * WS-W(2) - 0.565916 * WS-W(3))
         COMPUTE WS-D1 = FUNCTION MAX(0, -0.16169 * WS-W(1) + WS-L1Y * WS-W(2) + 0.565916 * WS-W(3))
     ELSE
         COMPUTE WS-D0 = FUNCTION MAX(0, 0.16169 * WS-N(1) + 0.808452 * WS-N(2) - 0.565916 * WS-N(3))
         COMPUTE WS-D1 = FUNCTION MAX(0, -0.16169 * WS-N(1) + 0.808452 * WS-N(2) + 0.565916 * WS-N(3))
     END-IF
     COMPUTE WS-SHADE = FUNCTION MIN(1, (WS-D0 + WS-D1) * 0.6 + 0.4)
*>   In the world (mode 4, the item a mob holds) the faces are shaded by their world direction as the entity models are: up 1, down 0.5, east and west 0.6, north and south 0.8.
     IF L-GLINT = 4 OR L-GLINT = 5
         COMPUTE WS-SHADE = WS-N(1) * WS-N(1) * 0.6 + WS-N(3) * WS-N(3) * 0.8
         IF WS-N(2) >= 0
             COMPUTE WS-SHADE = WS-SHADE + WS-N(2) * WS-N(2)
         ELSE
             COMPUTE WS-SHADE = WS-SHADE + WS-N(2) * WS-N(2) * 0.5
         END-IF
     END-IF
     PERFORM VARYING WS-V FROM 1 BY 1 UNTIL WS-V > 6
         MOVE WS-ORD(WS-V) TO WS-K
         COMPUTE WS-C = (WS-K - 1) * 3
         IF L-GLINT = 3
             ADD 1 TO RL-HA-COUNT
             MOVE WS-P(WS-C + 1) TO RL-HA-X(RL-HA-COUNT)
             MOVE WS-P(WS-C + 2) TO RL-HA-Y(RL-HA-COUNT)
             MOVE WS-P(WS-C + 3) TO RL-HA-Z(RL-HA-COUNT)
             MOVE L-U(WS-K) TO RL-HA-U(RL-HA-COUNT)
             MOVE L-V(WS-K) TO RL-HA-V(RL-HA-COUNT)
             COMPUTE RL-HA-B(RL-HA-COUNT) = FUNCTION MAX(WS-SHADE * L-LIGHT, 0.1)
             MOVE 1 TO RL-HA-A(RL-HA-COUNT)
             MOVE 0 TO RL-HA-SKY(RL-HA-COUNT)
             MOVE 1 TO RL-HA-R(RL-HA-COUNT) RL-HA-G(RL-HA-COUNT) RL-HA-BLUE(RL-HA-COUNT)
         END-IF
         IF L-GLINT = 4
             ADD 1 TO RL-GI-COUNT
             MOVE WS-P(WS-C + 1) TO RL-GI-X(RL-GI-COUNT)
             MOVE WS-P(WS-C + 2) TO RL-GI-Y(RL-GI-COUNT)
             MOVE WS-P(WS-C + 3) TO RL-GI-Z(RL-GI-COUNT)
             MOVE L-U(WS-K) TO RL-GI-U(RL-GI-COUNT)
             MOVE L-V(WS-K) TO RL-GI-V(RL-GI-COUNT)
             COMPUTE RL-GI-B(RL-GI-COUNT) = FUNCTION MAX(WS-SHADE * L-LIGHT, 0.1)
             MOVE 1 TO RL-GI-A(RL-GI-COUNT)
             MOVE 0 TO RL-GI-SKY(RL-GI-COUNT)
             MOVE 1 TO RL-GI-R(RL-GI-COUNT) RL-GI-G(RL-GI-COUNT) RL-GI-BLUE(RL-GI-COUNT)
         END-IF
         IF L-GLINT = 5
             ADD 1 TO RL-EN-COUNT
             MOVE WS-P(WS-C + 1) TO RL-EN-X(RL-EN-COUNT)
             MOVE WS-P(WS-C + 2) TO RL-EN-Y(RL-EN-COUNT)
             MOVE WS-P(WS-C + 3) TO RL-EN-Z(RL-EN-COUNT)
             MOVE L-U(WS-K) TO RL-EN-U(RL-EN-COUNT)
             MOVE L-V(WS-K) TO RL-EN-V(RL-EN-COUNT)
             COMPUTE RL-EN-B(RL-EN-COUNT) = FUNCTION MAX(WS-SHADE * L-LIGHT, 0.1)
             MOVE 1 TO RL-EN-A(RL-EN-COUNT)
             MOVE 0 TO RL-EN-SKY(RL-EN-COUNT)
             MOVE 1 TO RL-EN-R(RL-EN-COUNT) RL-EN-G(RL-EN-COUNT) RL-EN-BLUE(RL-EN-COUNT)
         END-IF
         IF L-GLINT NOT = 2 AND L-GLINT NOT = 3 AND L-GLINT NOT = 4 AND L-GLINT NOT = 5
             ADD 1 TO RL-HAND-COUNT
             MOVE WS-P(WS-C + 1) TO RL-HAND-X(RL-HAND-COUNT)
             MOVE WS-P(WS-C + 2) TO RL-HAND-Y(RL-HAND-COUNT)
             MOVE WS-P(WS-C + 3) TO RL-HAND-Z(RL-HAND-COUNT)
             MOVE L-U(WS-K) TO RL-HAND-U(RL-HAND-COUNT)
             MOVE L-V(WS-K) TO RL-HAND-V(RL-HAND-COUNT)
             COMPUTE RL-HAND-B(RL-HAND-COUNT) = FUNCTION MAX(WS-SHADE * L-LIGHT, 0.1)
             MOVE 1 TO RL-HAND-A(RL-HAND-COUNT)
             MOVE 0 TO RL-HAND-SKY(RL-HAND-COUNT)
             MOVE 1 TO RL-HAND-R(RL-HAND-COUNT) RL-HAND-G(RL-HAND-COUNT) RL-HAND-BLUE(RL-HAND-COUNT)
         END-IF
         IF L-GLINT = 1 OR L-GLINT = 2
             ADD 1 TO RL-HG-COUNT
             MOVE WS-P(WS-C + 1) TO RL-HG-X(RL-HG-COUNT)
             MOVE WS-P(WS-C + 2) TO RL-HG-Y(RL-HG-COUNT)
             MOVE WS-P(WS-C + 3) TO RL-HG-Z(RL-HG-COUNT)
             MOVE L-U(WS-K) TO WS-GU
             MOVE L-V(WS-K) TO WS-GV
             CALL "GLINT-UV" USING WS-GU WS-GV WS-GSCALE
             MOVE WS-GU TO RL-HG-U(RL-HG-COUNT)
             MOVE WS-GV TO RL-HG-V(RL-HG-COUNT)
             CALL "GLINT-STRENGTH" USING CLIENT-STATE WS-GSTRENGTH
             MOVE WS-GSTRENGTH TO RL-HG-B(RL-HG-COUNT)
             MOVE 1 TO RL-HG-A(RL-HG-COUNT)
             MOVE 0 TO RL-HG-SKY(RL-HG-COUNT)
             MOVE 1 TO RL-HG-R(RL-HG-COUNT) RL-HG-G(RL-HG-COUNT) RL-HG-BLUE(RL-HG-COUNT)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM HAND-QUAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-BUILD.
*> USING CLIENT-STATE, prefix (the view pose, 12 FLOAT-LONG), side (+1 right arm, -1 left), item (id + 1, 0 none), equip offset, pose kind (HAND-ARM), elapsed use
*> ticks, use duration, swing (1 = this hand swings), light 0 to 1: appends one hand's item to RL-HAND-VERTEX (nothing, a cube of 36 vertices or an extruded icon).
*> With foil 1 the glint mesh RL-HG-VERTEX gets the quads too (HAND-QUAD glint 1; a flat item: one quad per opaque texel on each face, glint 2, instead of the whole icon).
*> A left hand uses the right-hand display entry mirrored (12 section 8.2: tx, ry and rz negated); the block default of the left hand is block/block's own entry.
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
 01 WS-BDYE                BINARY-LONG.
 01 WS-SHIELD              BINARY-LONG.
 01 WS-HAND-NO             BINARY-LONG.
 01 WS-SKIND               BINARY-LONG.
 01 WS-SID1                PIC X(80).
 01 WS-SL1                 BINARY-LONG.
 01 WS-SID2                PIC X(80).
 01 WS-SL2                 BINARY-LONG.
 01 WS-SDYE                BINARY-LONG.
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
 01 WS-VYAW                FLOAT-LONG.
 01 WS-VPITCH              FLOAT-LONG.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-VQ.
    05 WS-VQV              FLOAT-LONG OCCURS 9 TIMES.
*> The four walls of an exposed pixel edge (12 section 6.8): for each side up, down, west, east its four corners in the client's clockwise order (the document's v0 v3 v2 v1) as
*> five digits: x (0 the pixel's left, 1 its right), y (0 its bottom, 1 its top), z (0 the back plane 7.5 / 16, 1 the front 8.5 / 16), u and v (0 = 0.1 into the pixel, 1 = 0.9).
 01 WS-WALL-DATA.
    05 FILLER PIC X(20) VALUE "01000110101111101101".
    05 FILLER PIC X(20) VALUE "00100101101001100001".
    05 FILLER PIC X(20) VALUE "01010011000010100011".
    05 FILLER PIC X(20) VALUE "11110110001000110111".
 01 WS-WALL-TABLE REDEFINES WS-WALL-DATA.
    05 WS-WALL-SIDE        OCCURS 4 TIMES.
       10 WS-WALL-CORNER   OCCURS 4 TIMES.
          15 WS-WD         PIC 9 OCCURS 5 TIMES.
 01 B-ATLAS                PIC X(1073741824) BASED.
 01 WS-SIDE-F              FLOAT-LONG.
 01 WS-GL                  BINARY-LONG.
 01 WS-NOGL                BINARY-LONG VALUE 0.
 01 WS-GL2                 BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PREFIX.
    05 L-PV                FLOAT-LONG OCCURS 12 TIMES.
 01 L-SIDE                 BINARY-LONG.
 01 L-ITEM1                BINARY-LONG.
 01 L-E                    FLOAT-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-ELAPSED              FLOAT-LONG.
 01 L-DURATION             FLOAT-LONG.
 01 L-SWING                BINARY-LONG.
 01 L-LIGHT                FLOAT-LONG.
 01 L-FOIL                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PREFIX L-SIDE L-ITEM1 L-E L-KIND L-ELAPSED L-DURATION L-SWING L-LIGHT L-FOIL.
     IF L-ITEM1 = 0
         GOBACK
     END-IF
     COMPUTE WS-ITEM = L-ITEM1 - 1
     CALL "ITEM-SPRITE-OF" USING CLIENT-STATE WS-ITEM WS-SPRITE
     IF WS-SPRITE = 0
         GOBACK
     END-IF
     MOVE L-LIGHT TO WS-LIGHT
     CALL "CL-ITEM-FLAGS" USING CLIENT-STATE WS-ITEM WS-HBLOCK WS-HTOOL WS-HFOOD
*>   The view angles: held items are lit in world orientation (12 section 6.10), so the shade follows the camera.
     CALL "CAMERA-PLACE" USING CLIENT-STATE WS-VYAW WS-VPITCH WS-EYE-TABLE
     CALL "HAND-VIEW-ROT" USING WS-VYAW WS-VPITCH WS-VQ
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
*>   A banner is a code-drawn model with the display entry of its base model template_banner (52 section 6.7: rotation (0, 90, 0), scale 0.375) and a shield one of its own; a chest,
*>   a shulker box or a bed (item-special.cob) has its own display transform and quads below; any other code-drawn model is not drawn.
     MOVE -1 TO WS-BDYE
     MOVE 0 TO WS-SHIELD
     CALL "SPECIAL-ITEM-KIND" USING CLIENT-STATE WS-ITEM WS-SKIND WS-SID1 WS-SL1 WS-SID2 WS-SL2 WS-SDYE
     IF WS-HAVE = 2
         CALL "HAND-BANNER-COLOUR" USING CLIENT-STATE WS-ITEM WS-BDYE
         IF WS-BDYE < 0
             CALL "SHIELD-ITEM" USING CLIENT-STATE WS-ITEM WS-SHIELD
             IF WS-SHIELD = 0 AND WS-SKIND = 0
                 GOBACK
             END-IF
         END-IF
         MOVE 1 TO WS-HAVE
         MOVE 0 TO WS-DV(1) WS-DV(3) WS-DV(4) WS-DV(5) WS-DV(6)
         MOVE 90 TO WS-DV(2)
         MOVE 0.375 TO WS-DV(7) WS-DV(8) WS-DV(9)
*>       A shield (12 section 6.12): the display entries of item/shield (not blocking) and item/shield_blocking (the hand uses it, kind 8) of the hand's own context; the left entry is mirrored
*>       once more below like any other.
         IF WS-SHIELD = 1
             MOVE 0 TO WS-DV(1)
             MOVE 180 TO WS-DV(2)
             MOVE 1.25 TO WS-DV(7) WS-DV(8) WS-DV(9)
             IF L-KIND = 8
                 MOVE -5 TO WS-DV(3)
             ELSE
                 MOVE 5 TO WS-DV(3)
             END-IF
             EVALUATE TRUE
                 WHEN L-SIDE > 0 AND L-KIND NOT = 8
                     MOVE -10 TO WS-DV(4)
                     MOVE 1.75 TO WS-DV(5)
                     MOVE -10 TO WS-DV(6)
                 WHEN L-SIDE > 0
                     MOVE -15 TO WS-DV(4)
                     MOVE 3.25 TO WS-DV(5)
                     MOVE -11 TO WS-DV(6)
                 WHEN L-KIND NOT = 8
                     MOVE 10 TO WS-DV(4)
                     MOVE 0 TO WS-DV(5)
                     MOVE -10 TO WS-DV(6)
                 WHEN OTHER
                     MOVE 5 TO WS-DV(4)
                     MOVE 5 TO WS-DV(5)
                     MOVE -11 TO WS-DV(6)
             END-EVALUATE
         END-IF
     END-IF
     IF WS-HAVE = 0
         IF WS-CUBE = 1
             MOVE 0 TO WS-DV(1) WS-DV(3) WS-DV(4) WS-DV(5) WS-DV(6)
             MOVE 45 TO WS-DV(2)
             IF L-SIDE < 0
                 MOVE 225 TO WS-DV(2)
             END-IF
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
*>   The left hand's display entry is the right one mirrored (a block's own default excepted).
     IF L-SIDE < 0 AND NOT (WS-HAVE = 0 AND WS-CUBE = 1)
         COMPUTE WS-DV(4) = 0 - WS-DV(4)
         COMPUTE WS-DV(2) = 0 - WS-DV(2)
         COMPUTE WS-DV(3) = 0 - WS-DV(3)
     END-IF
*>   The prefix (view bobbing and sway), the arm transform or the use pose, then the swing of progress p = (now - start) / 300 ms (whack).
     MOVE L-PREFIX TO WS-M
     CALL "HAND-ARM" USING WS-M L-SIDE L-E L-KIND L-ELAPSED L-DURATION
     MOVE L-SIDE TO WS-SIDE-F
     MOVE 0 TO WS-GL
     IF L-FOIL = 1
         MOVE 1 TO WS-GL
     END-IF
     IF L-SWING = 1
         COMPUTE WS-P = (CL-NOW-MS - CL-SWING-AT) / CL-SWING-MS
         COMPUTE WS-Q = FUNCTION SQRT(WS-P)
         COMPUTE WS-AX = WS-SIDE-F * -0.4 * FUNCTION SIN(WS-Q * FUNCTION PI)
         COMPUTE WS-AY = 0.2 * FUNCTION SIN(WS-Q * 2 * FUNCTION PI)
         COMPUTE WS-AZ = -0.2 * FUNCTION SIN(WS-P * FUNCTION PI)
         CALL "HAND-M-TRANSLATE" USING WS-M WS-AX WS-AY WS-AZ
         MOVE 2 TO WS-AXIS
         COMPUTE WS-DEG = WS-SIDE-F * (45 + FUNCTION SIN(WS-P * WS-P * FUNCTION PI) * -20)
         CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
         MOVE 3 TO WS-AXIS
         COMPUTE WS-DEG = WS-SIDE-F * FUNCTION SIN(WS-Q * FUNCTION PI) * -20
         CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
         MOVE 1 TO WS-AXIS
         COMPUTE WS-DEG = FUNCTION SIN(WS-Q * FUNCTION PI) * -80
         CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
         MOVE 2 TO WS-AXIS
         COMPUTE WS-DEG = WS-SIDE-F * -45
         CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
     END-IF
*>   A chest, a shulker box or a bed is a code-drawn model of its own quads (a banner and a shield are drawn below with their display entries).
     IF WS-SKIND > 0 AND WS-BDYE < 0 AND WS-SHIELD = 0
         CALL "HAND-SPECIAL-MESH" USING CLIENT-STATE WS-SKIND WS-ITEM WS-M WS-LIGHT WS-VQ
         GOBACK
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
     IF WS-BDYE >= 0 OR WS-SHIELD = 1
         MOVE 2 TO WS-HAND-NO
         IF L-ITEM1 = CL-HAND-ITEM
             MOVE 1 TO WS-HAND-NO
         END-IF
         IF WS-SHIELD = 1
             CALL "HAND-SHIELD" USING CLIENT-STATE WS-M WS-HAND-NO WS-LIGHT
         ELSE
             CALL "HAND-BANNER" USING CLIENT-STATE WS-M WS-HAND-NO WS-BDYE WS-LIGHT
         END-IF
         GOBACK
     END-IF
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
             CALL "HAND-QUAD" USING CLIENT-STATE WS-M WS-CORNERS WS-TEXEL WS-N3 WS-LIGHT WS-GL WS-VQ
         END-PERFORM
         GOBACK
     END-IF
*>   An extruded icon (12 section 6.8): the whole icon on the front (z 8.5 / 16, u from the left) and on the back (z 7.5 / 16, seen from behind: its corners are the front's
*>   at the same x and y, so u still grows with +x) ...
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 2
         IF WS-F = 1
             MOVE 0 TO WS-U16(1) WS-U16(4) WS-V16(1) WS-V16(2)
             MOVE 16 TO WS-U16(2) WS-U16(3) WS-V16(3) WS-V16(4)
         ELSE
             MOVE 16 TO WS-U16(1) WS-U16(4)
             MOVE 0 TO WS-U16(2) WS-U16(3) WS-V16(1) WS-V16(2)
             MOVE 16 TO WS-V16(3) WS-V16(4)
         END-IF
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
             CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-U16(WS-K) WS-V16(WS-K) WS-TU(WS-K) WS-TV(WS-K)
         END-PERFORM
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
         CALL "HAND-QUAD" USING CLIENT-STATE WS-M WS-CORNERS WS-TEXEL WS-N3 WS-LIGHT WS-NOGL WS-VQ
     END-PERFORM
*>   ... and a wall where an opaque pixel (alpha above 0) borders a transparent one or the icon's rim, its texture coordinates inside the pixel (0.1 to 0.9 of it).
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
*>   The glint of a foil item covers the opaque texels only: one quad of each on the front and the back, its glint coordinates those of its texel corners.
     IF L-FOIL = 1
         PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 2
             MOVE WS-NRM-V(WS-F, 1) TO WS-NV(1)
             MOVE WS-NRM-V(WS-F, 2) TO WS-NV(2)
             MOVE WS-NRM-V(WS-F, 3) TO WS-NV(3)
             PERFORM VARYING WS-PY FROM 0 BY 1 UNTIL WS-PY >= WS-N
                 PERFORM VARYING WS-PX FROM 0 BY 1 UNTIL WS-PX >= WS-N
                     IF WS-OPAQUE(WS-PY * WS-N + WS-PX + 1) = 1
                         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
*>                           Corner k of the face's pick table: x and y low or high within the texel; z of the face.
                             COMPUTE WS-CP((WS-K - 1) * 3 + 1) = (WS-PX + WS-PICK(WS-F, (WS-K - 1) * 3 + 1)) * WS-CELL
                             COMPUTE WS-CP((WS-K - 1) * 3 + 2) = 1 - (WS-PY + 1 - WS-PICK(WS-F, (WS-K - 1) * 3 + 2)) * WS-CELL
                             COMPUTE WS-CP((WS-K - 1) * 3 + 3) = (19 - 2 * WS-F) / 32
*>                           The texel's corner of the icon: top-left, top-right, bottom-right, bottom-left.
                             COMPUTE WS-U16(WS-K) = (WS-PX + FUNCTION MOD(FUNCTION INTEGER((WS-K) / 2), 2)) * 16 / WS-N
                             COMPUTE WS-V16(WS-K) = (WS-PY + FUNCTION INTEGER(WS-K / 3)) * 16 / WS-N
                             CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-U16(WS-K) WS-V16(WS-K) WS-TU(WS-K) WS-TV(WS-K)
                         END-PERFORM
                         CALL "HAND-QUAD" USING CLIENT-STATE WS-M WS-CORNERS WS-TEXEL WS-N3 WS-LIGHT WS-GL2 WS-VQ
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-IF
     PERFORM VARYING WS-PY FROM 0 BY 1 UNTIL WS-PY >= WS-N
         PERFORM VARYING WS-PX FROM 0 BY 1 UNTIL WS-PX >= WS-N
             IF WS-OPAQUE(WS-PY * WS-N + WS-PX + 1) = 1
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
                         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                             IF WS-WD(WS-SIDE, WS-K, 1) = 0
                                 MOVE WS-X0 TO WS-CP((WS-K - 1) * 3 + 1)
                             ELSE
                                 MOVE WS-X1 TO WS-CP((WS-K - 1) * 3 + 1)
                             END-IF
                             IF WS-WD(WS-SIDE, WS-K, 2) = 0
                                 MOVE WS-Y0 TO WS-CP((WS-K - 1) * 3 + 2)
                             ELSE
                                 MOVE WS-Y1 TO WS-CP((WS-K - 1) * 3 + 2)
                             END-IF
                             IF WS-WD(WS-SIDE, WS-K, 3) = 0
                                 MOVE 0.46875 TO WS-CP((WS-K - 1) * 3 + 3)
                             ELSE
                                 MOVE 0.53125 TO WS-CP((WS-K - 1) * 3 + 3)
                             END-IF
                             COMPUTE WS-U16(WS-K) = (WS-PX + 0.1 + 0.8 * WS-WD(WS-SIDE, WS-K, 4)) * 16 / WS-N
                             COMPUTE WS-V16(WS-K) = (WS-PY + 0.1 + 0.8 * WS-WD(WS-SIDE, WS-K, 5)) * 16 / WS-N
                             CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE WS-U16(WS-K) WS-V16(WS-K) WS-TU(WS-K) WS-TV(WS-K)
                         END-PERFORM
                         EVALUATE WS-SIDE
                             WHEN 1
                                 MOVE 0 TO WS-NV(1) WS-NV(3)
                                 MOVE 1 TO WS-NV(2)
                             WHEN 2
                                 MOVE 0 TO WS-NV(1) WS-NV(3)
                                 MOVE -1 TO WS-NV(2)
                             WHEN 3
                                 MOVE 0 TO WS-NV(2) WS-NV(3)
                                 MOVE -1 TO WS-NV(1)
                             WHEN OTHER
                                 MOVE 0 TO WS-NV(2) WS-NV(3)
                                 MOVE 1 TO WS-NV(1)
                         END-EVALUATE
                         CALL "HAND-QUAD" USING CLIENT-STATE WS-M WS-CORNERS WS-TEXEL WS-N3 WS-LIGHT WS-GL WS-VQ
                     END-IF
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM HAND-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-MESH.
*> USING CLIENT-STATE: RL-HAND-VERTEX and RL-HAND-COUNT for this frame: the main hand's item, then the off hand's (HAND-BUILD each), under the view pose of HAND-PREFIX. The
*> main arm is the right one unless the mainHand option is "left", the off hand's the other. While the player eats the main hand takes the eating pose (12 section 6.6;
*> CL-EAT-MS is the use duration); a bow, crossbow, trident or shield in use, an auto spin attack and a loaded crossbow take theirs; an empty main hand shows its arm (HAND-EMPTY-ARM, RL-HA-VERTEX). Nothing swings and nothing changed since the last frame (the items, their sprites, the equip heights, the light, the view pose): the
*> mesh built then is still in RL-HAND-VERTEX and in the GPU slot, so it is neither built nor uploaded again.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-NAME                PIC X(40) VALUE "mainHand".
 01 WS-VALUE               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-M.
    05 WS-MV               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-E                   FLOAT-LONG.
 01 WS-EO                  FLOAT-LONG.
 01 WS-PART                FLOAT-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-OITEM               BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-OSPRITE             BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-OSIDE               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ELAPSED             FLOAT-LONG.
 01 WS-DURATION            FLOAT-LONG.
 01 WS-SWING               BINARY-LONG.
 01 WS-OKIND               BINARY-LONG.
 01 WS-NOSWING             BINARY-LONG VALUE 0.
 01 WS-OELAPSED            FLOAT-LONG.
 01 WS-ODURATION           FLOAT-LONG.
 01 WS-UKIND               BINARY-LONG.
 01 WS-UELAPSED            FLOAT-LONG.
 01 WS-UDURATION           FLOAT-LONG.
 01 WS-HAND-NO             BINARY-LONG.
 01 WS-LOADED              BINARY-LONG.
 01 WS-ARM                 BINARY-LONG.
 01 WS-BANNER              BINARY-LONG.
 01 WS-SHIELD-FLAG         BINARY-LONG.
 01 WS-ITEM-CLASS          BINARY-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-EX                  BINARY-LONG.
 01 WS-EY                  BINARY-LONG.
 01 WS-EZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-STILL               BINARY-LONG.
 01 WS-PREV-COUNT          BINARY-LONG.
 01 WS-HYAW                FLOAT-LONG.
 01 WS-HPITCH              FLOAT-LONG.
 01 WS-HEYE-TABLE.
    05 WS-HEYE             FLOAT-LONG OCCURS 3 TIMES.
 01 WS-PREV-GCOUNT         BINARY-LONG.
 01 WS-FOIL                BINARY-LONG.
 01 WS-OFOIL               BINARY-LONG.
 01 WS-DIGEST              FLOAT-LONG.
 01 WS-HAVE                BINARY-LONG.
 01 WS-OHAVE               BINARY-LONG.
 01 WS-VAL.
    05 WS-DV               FLOAT-LONG OCCURS 9 TIMES.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO RL-HAND-COUNT RL-HAND-SAME RL-HG-COUNT RL-HA-COUNT
     MOVE CL-HAND-KEY-COUNT TO WS-PREV-COUNT
     MOVE CL-HAND-KEY-GCOUNT TO WS-PREV-GCOUNT
     MOVE 0 TO CL-HAND-KEY-COUNT CL-HAND-KEY-GCOUNT
*>   The hands are drawn in first person only, and not to a spectator (53 section 15.1).
     IF SM-SCREEN = SCR-WORLD AND CL-CAMERA = 0 AND PL-MODE NOT = 3
         CALL "HAND-EQUIP" USING CLIENT-STATE WS-E WS-EO WS-PART
     ELSE
         GOBACK
     END-IF
*>   An empty main hand shows the arm (12 section 6.5) unless the player is invisible (the mob effect invisibility, id 13).
     MOVE 0 TO WS-ARM
     IF CL-HAND-ITEM = 0
         MOVE 1 TO WS-ARM
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EF-COUNT
             IF EF-ID(WS-I) = 13
                 MOVE 0 TO WS-ARM
             END-IF
         END-PERFORM
     END-IF
     IF CL-HAND-ITEM = 0 AND CL-OHAND-ITEM = 0 AND WS-ARM = 0
         GOBACK
     END-IF
     MOVE 1 TO WS-SIDE
     MOVE -1 TO WS-OSIDE
     MOVE "mainHand" TO WS-NAME
     CALL "OPTIONS-GET" USING CLIENT-STATE WS-NAME WS-VALUE WS-LENGTH WS-FOUND
     IF WS-FOUND = 1 AND WS-VALUE(1:6) = '"left"'
         MOVE -1 TO WS-SIDE
         MOVE 1 TO WS-OSIDE
     END-IF
     MOVE 0 TO WS-SPRITE WS-OSPRITE
     IF CL-HAND-ITEM > 0
         COMPUTE WS-ITEM = CL-HAND-ITEM - 1
         CALL "ITEM-SPRITE-OF" USING CLIENT-STATE WS-ITEM WS-SPRITE
     END-IF
     IF CL-OHAND-ITEM > 0
         COMPUTE WS-OITEM = CL-OHAND-ITEM - 1
         CALL "ITEM-SPRITE-OF" USING CLIENT-STATE WS-OITEM WS-OSPRITE
     END-IF
*>   The light at the eye (like an entity: the larger of the sky light by the daylight and the block light, of 15).
     COMPUTE WS-EX = FUNCTION INTEGER(PL-X)
     COMPUTE WS-EY = FUNCTION INTEGER(PL-Y + 1.62)
     COMPUTE WS-EZ = FUNCTION INTEGER(PL-Z)
     CALL "WORLD-CELL" USING CLIENT-STATE WS-EX WS-EY WS-EZ WS-STATE WS-SKY WS-BLK
     COMPUTE WS-LIGHT = FUNCTION MAX(WS-SKY * SK-U / 1000, WS-BLK) / 15
*>   The view pose is the world view's: the same partial tick (CL-PARTIAL) for both.
     CALL "HAND-PREFIX" USING CLIENT-STATE CL-PARTIAL WS-M
     IF WS-ARM = 1
         CALL "HAND-EMPTY-ARM" USING CLIENT-STATE WS-M WS-SIDE WS-E WS-LIGHT
     END-IF
*>   The poses: eating (the right button held on a food item) takes the main hand's eating pose; a bow, crossbow, trident or shield in use (USE-ITEM-INPUT) poses the hand that uses it
*>   (PL-USE-HAND); an auto spin attack (pose 4) poses the hand that holds a trident; else the main hand swings within its 300 ms, or holds a loaded crossbow at rest (kind 7).
     MOVE 0 TO WS-KIND WS-SWING WS-ELAPSED WS-DURATION WS-OKIND WS-OELAPSED WS-ODURATION
     IF PL-EATING = 1 AND CL-NOW-MS >= PL-EAT-START
         MOVE 1 TO WS-KIND
         COMPUTE WS-ELAPSED = (CL-NOW-MS - PL-EAT-START) / 50
         COMPUTE WS-DURATION = CL-EAT-MS / 50
     END-IF
     IF PL-USE-KIND > 0 AND CL-NOW-MS >= PL-USE-START
         MOVE PL-USE-KIND TO WS-UKIND
         MOVE 0 TO WS-HAND-NO
         IF PL-USE-HAND = 1
             MOVE 1 TO WS-HAND-NO
         END-IF
         CALL "USE-ITEM-LOADED" USING CLIENT-STATE WS-HAND-NO WS-LOADED
*>       A loaded crossbow is not charging: it keeps the pose of a crossbow at rest.
         IF WS-LOADED = 1
             MOVE 0 TO WS-UKIND
         END-IF
         COMPUTE WS-UELAPSED = (CL-NOW-MS - PL-USE-START) / 50
         COMPUTE WS-UDURATION = PL-USE-DURATION / 50
         IF PL-USE-HAND = 0 AND WS-KIND = 0
             MOVE WS-UKIND TO WS-KIND
             MOVE WS-UELAPSED TO WS-ELAPSED
             MOVE WS-UDURATION TO WS-DURATION
         END-IF
         IF PL-USE-HAND = 1
             MOVE WS-UKIND TO WS-OKIND
             MOVE WS-UELAPSED TO WS-OELAPSED
             MOVE WS-UDURATION TO WS-ODURATION
         END-IF
     END-IF
     IF PL-POSE = 4 AND WS-KIND = 0 AND WS-OKIND = 0
         MOVE 0 TO WS-ITEM-CLASS
         IF CL-HAND-ITEM > 0
             COMPUTE WS-ITEM = CL-HAND-ITEM - 1
             CALL "USE-ITEM-CLASS" USING CLIENT-STATE WS-ITEM WS-ITEM-CLASS
         END-IF
         IF WS-ITEM-CLASS = 4
             MOVE 6 TO WS-KIND
         ELSE
             MOVE 0 TO WS-ITEM-CLASS
             IF CL-OHAND-ITEM > 0
                 COMPUTE WS-OITEM = CL-OHAND-ITEM - 1
                 CALL "USE-ITEM-CLASS" USING CLIENT-STATE WS-OITEM WS-ITEM-CLASS
             END-IF
             IF WS-ITEM-CLASS = 4
                 MOVE 6 TO WS-OKIND
             END-IF
         END-IF
     END-IF
*>   A loaded crossbow in the main hand that is not being swung (swing progress under 0.001, 12 section 6.6) is held at rest (kind 7).
     IF WS-KIND = 0
         MOVE 1 TO WS-P
         IF CL-SWING-AT > 0 AND CL-NOW-MS >= CL-SWING-AT AND CL-NOW-MS - CL-SWING-AT < CL-SWING-MS
             MOVE 1 TO WS-SWING
             COMPUTE WS-P = (CL-NOW-MS - CL-SWING-AT) / CL-SWING-MS
         END-IF
         IF WS-SWING = 0 OR WS-P < 0.001
             MOVE 0 TO WS-HAND-NO
             CALL "USE-ITEM-LOADED" USING CLIENT-STATE WS-HAND-NO WS-LOADED
             IF WS-LOADED = 1
                 MOVE 7 TO WS-KIND
             END-IF
         END-IF
     END-IF
     MOVE 1 TO WS-STILL
*>   A banner in a hand is built each frame (its mesh is not the one of the cache).
     IF CL-HAND-ITEM > 0
         COMPUTE WS-ITEM = CL-HAND-ITEM - 1
         CALL "HAND-BANNER-COLOUR" USING CLIENT-STATE WS-ITEM WS-BANNER
         IF WS-BANNER >= 0
             MOVE 0 TO WS-STILL
         END-IF
     END-IF
     IF CL-OHAND-ITEM > 0
         COMPUTE WS-OITEM = CL-OHAND-ITEM - 1
         CALL "HAND-BANNER-COLOUR" USING CLIENT-STATE WS-OITEM WS-BANNER
         IF WS-BANNER >= 0
             MOVE 0 TO WS-STILL
         END-IF
     END-IF
*>   A shield in a hand is built each frame too (its mesh is the hand's, not the item mesh of the cache).
     IF CL-HAND-ITEM > 0
         COMPUTE WS-ITEM = CL-HAND-ITEM - 1
         CALL "SHIELD-ITEM" USING CLIENT-STATE WS-ITEM WS-SHIELD-FLAG
         IF WS-SHIELD-FLAG = 1
             MOVE 0 TO WS-STILL
         END-IF
     END-IF
     IF CL-OHAND-ITEM > 0
         COMPUTE WS-OITEM = CL-OHAND-ITEM - 1
         CALL "SHIELD-ITEM" USING CLIENT-STATE WS-OITEM WS-SHIELD-FLAG
         IF WS-SHIELD-FLAG = 1
             MOVE 0 TO WS-STILL
         END-IF
     END-IF
     IF WS-SWING = 1 OR (WS-KIND > 0 AND WS-KIND NOT = 7 AND WS-KIND NOT = 8) OR (WS-OKIND > 0 AND WS-OKIND NOT = 7 AND WS-OKIND NOT = 8)
         MOVE 0 TO WS-STILL
     END-IF
*>   A code-drawn model (present 2) draws nothing: the digest tells that change of the shown model apart from a still hand.
     MOVE 0 TO WS-HAVE WS-OHAVE
     IF WS-SPRITE > 0
         CALL "ITEM-HAND-DISPLAY" USING CLIENT-STATE WS-ITEM WS-HAVE WS-VAL
     END-IF
     IF WS-OSPRITE > 0
         CALL "ITEM-HAND-DISPLAY" USING CLIENT-STATE WS-OITEM WS-OHAVE WS-VAL
     END-IF
*>   The foil of the stacks the player holds (54 section 19.2; the shown stack follows the held one within a few ticks).
     MOVE 0 TO WS-FOIL WS-OFOIL
     IF PL-SLOT-COUNT(PL-HELD + 1) > 0 AND PL-SLOT-FOIL(PL-HELD + 1) = 1
         MOVE 1 TO WS-FOIL
     END-IF
     IF PL-OFFHAND-COUNT > 0 AND PL-OFFHAND-FOIL = 1
         MOVE 1 TO WS-OFOIL
     END-IF
     COMPUTE WS-DIGEST = WS-EO * 7.31 + CL-OHAND-ITEM * 131.7 + WS-OSPRITE * 0.37 + WS-HAVE * 1000.3 + WS-OHAVE * 3000.7
         + WS-FOIL * 17.3 + WS-OFOIL * 29.9 + WS-KIND * 53.1 + WS-OKIND * 61.7
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         COMPUTE WS-DIGEST = WS-DIGEST + WS-MV(WS-I) * (WS-I + 1)
     END-PERFORM
*>   The item is lit in world orientation (12 section 6.10): the view angles are part of what the mesh was built for.
     CALL "CAMERA-PLACE" USING CLIENT-STATE WS-HYAW WS-HPITCH WS-HEYE-TABLE
     IF WS-STILL = 1 AND WS-PREV-COUNT > 0 AND CL-HAND-KEY-ITEM = WS-ITEM AND CL-HAND-KEY-SPRITE = WS-SPRITE
             AND CL-HAND-KEY-E = WS-E AND CL-HAND-KEY-LIGHT = WS-LIGHT AND CL-HAND-KEY-P = WS-DIGEST
             AND CL-HAND-KEY-YAW = WS-HYAW AND CL-HAND-KEY-PITCH = WS-HPITCH
         MOVE WS-PREV-COUNT TO RL-HAND-COUNT CL-HAND-KEY-COUNT
         MOVE WS-PREV-GCOUNT TO RL-HG-COUNT CL-HAND-KEY-GCOUNT
         MOVE 1 TO RL-HAND-SAME
         GOBACK
     END-IF
     IF WS-STILL = 1
         MOVE WS-ITEM TO CL-HAND-KEY-ITEM
         MOVE WS-SPRITE TO CL-HAND-KEY-SPRITE
         MOVE WS-E TO CL-HAND-KEY-E
         MOVE WS-LIGHT TO CL-HAND-KEY-LIGHT
         MOVE WS-DIGEST TO CL-HAND-KEY-P
         MOVE WS-HYAW TO CL-HAND-KEY-YAW
         MOVE WS-HPITCH TO CL-HAND-KEY-PITCH
     END-IF
     CALL "HAND-BUILD" USING CLIENT-STATE WS-M WS-SIDE CL-HAND-ITEM WS-E WS-KIND WS-ELAPSED WS-DURATION WS-SWING WS-LIGHT WS-FOIL
     CALL "HAND-BUILD" USING CLIENT-STATE WS-M WS-OSIDE CL-OHAND-ITEM WS-EO WS-OKIND WS-OELAPSED WS-ODURATION WS-NOSWING WS-LIGHT WS-OFOIL
     IF WS-STILL = 1
         MOVE RL-HAND-COUNT TO CL-HAND-KEY-COUNT
         MOVE RL-HG-COUNT TO CL-HAND-KEY-GCOUNT
     END-IF
     GOBACK.
 END PROGRAM HAND-MESH.
