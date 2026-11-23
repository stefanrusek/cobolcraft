*> T11106 (docs/protocol/57-client-closures-1-rendering-and-animation.md section 1): the first-person fire overlay. FIRE-OVERLAY-MESH puts two unit quads of the block atlas
*> sprite fire_1 into RL-HF-VERTEX (12 vertices: the corners 1 2 3 1 3 4 of each) in the camera space of the hand pass: z -0.5 before the transform, rotated about y by -10 degrees
*> (first quad) or +10 degrees (second) and then translated by (+0.24, -0.3, 0) or (-0.24, -0.3, 0); the texture coordinates are (u1, v1), (u0, v1), (u0, v0), (u1, v0) (mirrored
*> horizontally); the colour is white with alpha 229 / 255 and no light. The condition (1.2): the local player is on fire (PL-ON-FIRE, the flag of entry 0), first person, the world
*> screen, not a spectator. RENDER-LIST-BUILD draws the mesh after the depth clear and the arm, translucent, on the block atlas, with the hand's projection.
*> Expected corners from an independent script: x' = cos(a) x + sin(a) z, z' = -sin(a) x + cos(a) z with a = -10 degrees, then + the translation, for the corners (+-0.5, +-0.5, -0.5).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FIRE-OVERLAY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-NAME                PIC X(120).
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-EU                  FLOAT-LONG.
 01 WS-EV                  FLOAT-LONG.
 01 WS-CLEAR-AT            BINARY-LONG.
 01 WS-ARM-AT              BINARY-LONG.
 01 WS-FIRE-AT             BINARY-LONG.
 01 WS-UI-AT               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 32 TO AT-W
     MOVE 16 TO AT-H
     MOVE 3 TO AT-SPRITE-COUNT
     MOVE "minecraft:block/fire_0" TO AT-NAME(2)
     MOVE 22 TO AT-NAME-LENGTH(2)
     MOVE 0 TO AT-X(2) AT-Y(2)
     MOVE 16 TO AT-SW(2) AT-SH(2)
     MOVE "minecraft:block/fire_1" TO AT-NAME(3)
     MOVE 22 TO AT-NAME-LENGTH(3)
     MOVE 16 TO AT-X(3)
     MOVE 0 TO AT-Y(3)
     MOVE 16 TO AT-SW(3) AT-SH(3)
     MOVE SCR-WORLD TO SM-SCREEN
     MOVE 0 TO CL-CAMERA PL-MODE
     MOVE 1 TO PL-ON-FIRE
     MOVE "N" TO TL-MODE
*>   The condition.
     CALL "FIRE-OVERLAY-MESH" USING CLIENT-STATE
     MOVE "T11106 a burning player in first person survival draws two quads of six vertices" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE RL-HF-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-ON-FIRE
     CALL "FIRE-OVERLAY-MESH" USING CLIENT-STATE
     MOVE "T11106 a player not on fire draws none" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-HF-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PL-ON-FIRE
     MOVE 1 TO CL-CAMERA
     CALL "FIRE-OVERLAY-MESH" USING CLIENT-STATE
     MOVE "T11106 the third person view draws none (the figure's own flames, T11105)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-HF-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CL-CAMERA
     MOVE 3 TO PL-MODE
     CALL "FIRE-OVERLAY-MESH" USING CLIENT-STATE
     MOVE "T11106 a spectator draws none" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-HF-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO PL-MODE
     CALL "FIRE-OVERLAY-MESH" USING CLIENT-STATE
     MOVE "T11106 creative mode draws it (the server keeps the flag for one tick)" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     MOVE RL-HF-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-MODE
     MOVE SCR-PAUSE TO SM-SCREEN
     CALL "FIRE-OVERLAY-MESH" USING CLIENT-STATE
     MOVE "T11106 a screen other than the world draws none" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-HF-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SCR-WORLD TO SM-SCREEN
     MOVE 2 TO AT-SPRITE-COUNT
     CALL "FIRE-OVERLAY-MESH" USING CLIENT-STATE
     MOVE "T11106 a pack without fire_1 draws none" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-HF-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO AT-SPRITE-COUNT
*>   The geometry of the first quad (vertices 1 to 6: corners 1 2 3 1 3 4), sprite fire_1 at u 0.5 to 1, v 0 to 1 of the 32 x 16 atlas.
     CALL "FIRE-OVERLAY-MESH" USING CLIENT-STATE
     MOVE "T11106 first quad corner 1 (bottom left)" TO WS-NAME
     MOVE 1 TO WS-INDEX
     MOVE -0.16558 TO WS-EX
     MOVE -0.8 TO WS-EY
     MOVE -0.57922 TO WS-EZ
     MOVE 1 TO WS-EU
     MOVE 1 TO WS-EV
     PERFORM CHECK-VERTEX
     MOVE "T11106 first quad corner 2 (bottom right, mirrored u)" TO WS-NAME
     MOVE 2 TO WS-INDEX
     MOVE 0.81922 TO WS-EX
     MOVE -0.8 TO WS-EY
     MOVE -0.40558 TO WS-EZ
     MOVE 0 TO WS-EU
     MOVE 1 TO WS-EV
     PERFORM CHECK-VERTEX
     MOVE "T11106 first quad corner 3 (top right)" TO WS-NAME
     MOVE 3 TO WS-INDEX
     MOVE 0.81922 TO WS-EX
     MOVE 0.2 TO WS-EY
     MOVE -0.40558 TO WS-EZ
     MOVE 0 TO WS-EU
     MOVE 0 TO WS-EV
     PERFORM CHECK-VERTEX
     MOVE "T11106 first quad second triangle starts at corner 1 again" TO WS-NAME
     MOVE 4 TO WS-INDEX
     MOVE -0.16558 TO WS-EX
     MOVE -0.8 TO WS-EY
     MOVE -0.57922 TO WS-EZ
     MOVE 1 TO WS-EU
     MOVE 1 TO WS-EV
     PERFORM CHECK-VERTEX
     MOVE "T11106 first quad corner 4 (top left, upright v)" TO WS-NAME
     MOVE 6 TO WS-INDEX
     MOVE -0.16558 TO WS-EX
     MOVE 0.2 TO WS-EY
     MOVE -0.57922 TO WS-EZ
     MOVE 1 TO WS-EU
     MOVE 0 TO WS-EV
     PERFORM CHECK-VERTEX
*>   The second quad: translation (-0.24, -0.3, 0), rotation +10 degrees.
     MOVE "T11106 second quad corner 1" TO WS-NAME
     MOVE 7 TO WS-INDEX
     MOVE -0.81922 TO WS-EX
     MOVE -0.8 TO WS-EY
     MOVE -0.40558 TO WS-EZ
     MOVE 1 TO WS-EU
     MOVE 1 TO WS-EV
     PERFORM CHECK-VERTEX
     MOVE "T11106 second quad corner 2" TO WS-NAME
     MOVE 8 TO WS-INDEX
     MOVE 0.16558 TO WS-EX
     MOVE -0.8 TO WS-EY
     MOVE -0.57922 TO WS-EZ
     MOVE 0 TO WS-EU
     MOVE 1 TO WS-EV
     PERFORM CHECK-VERTEX
     MOVE "T11106 second quad corner 3" TO WS-NAME
     MOVE 9 TO WS-INDEX
     MOVE 0.16558 TO WS-EX
     MOVE 0.2 TO WS-EY
     MOVE -0.57922 TO WS-EZ
     MOVE 0 TO WS-EU
     MOVE 0 TO WS-EV
     PERFORM CHECK-VERTEX
     MOVE "T11106 second quad corner 4" TO WS-NAME
     MOVE 12 TO WS-INDEX
     MOVE -0.81922 TO WS-EX
     MOVE 0.2 TO WS-EY
     MOVE -0.40558 TO WS-EZ
     MOVE 1 TO WS-EU
     MOVE 0 TO WS-EV
     PERFORM CHECK-VERTEX
*>   White, alpha 229 / 255, no light term, no tint, on every vertex.
     MOVE 0 TO TL-OBSERVED-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         IF FUNCTION ABS(RL-HF-A(WS-I) - 0.898) < 0.001 AND RL-HF-B(WS-I) = 1 AND RL-HF-SKY(WS-I) = 0
                 AND RL-HF-R(WS-I) = 1 AND RL-HF-G(WS-I) = 1 AND RL-HF-BLUE(WS-I) = 1
             ADD 1 TO TL-OBSERVED-N
         END-IF
     END-PERFORM
     MOVE "T11106 every vertex is white with alpha 229/255, brightness 1 and no sky term" TO TL-CASE
     MOVE 12 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The render list: the depth clear (draw slot -1), the arm, then the fire (translucent, block atlas), then the UI.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "TEST-STEP" USING CLIENT-STATE
     ADD 1 TO AT-SPRITE-COUNT
     MOVE "minecraft:block/fire_1" TO AT-NAME(AT-SPRITE-COUNT)
     MOVE 22 TO AT-NAME-LENGTH(AT-SPRITE-COUNT)
     MOVE 0 TO AT-X(AT-SPRITE-COUNT) AT-Y(AT-SPRITE-COUNT)
     MOVE 16 TO AT-SW(AT-SPRITE-COUNT) AT-SH(AT-SPRITE-COUNT)
     MOVE 0 TO PL-MODE CL-CAMERA
     MOVE 1 TO PL-ON-FIRE
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE 0 TO WS-CLEAR-AT WS-ARM-AT WS-FIRE-AT WS-UI-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
         IF RL-D-SLOT(WS-I) = -1
             MOVE WS-I TO WS-CLEAR-AT
         END-IF
         IF RL-D-SLOT(WS-I) = MESH-SLOT-HAND-ARM
             MOVE WS-I TO WS-ARM-AT
         END-IF
         IF RL-D-SLOT(WS-I) = MESH-SLOT-HAND-FIRE
             MOVE WS-I TO WS-FIRE-AT
         END-IF
         IF RL-D-SLOT(WS-I) = MESH-SLOT-UI
             MOVE WS-I TO WS-UI-AT
         END-IF
     END-PERFORM
     MOVE "T11106 the render list draws the fire after the depth clear and the arm, before the UI" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-CLEAR-AT > 0 AND WS-FIRE-AT > WS-CLEAR-AT AND WS-FIRE-AT > WS-ARM-AT AND WS-UI-AT > WS-FIRE-AT
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T11106 the fire is drawn translucent on the block atlas (texture 0)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FIRE-AT > 0
         IF RL-D-TEX(WS-FIRE-AT) = CC-TEX-BLOCKS AND RL-D-PIPELINE(WS-FIRE-AT) = CC-PIPE-TRANSLUCENT
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T11106 the fire uses the hand's projection (focal length 1.428 in the first matrix cell times the aspect)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FIRE-AT > 0
         IF RL-D-MATRIX(WS-FIRE-AT, 12) = -1 AND FUNCTION ABS(RL-D-MATRIX(WS-FIRE-AT, 6) + 1.428148) < 0.001
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Not burning: no fire record.
     MOVE 0 TO PL-ON-FIRE
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE 0 TO WS-FIRE-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
         IF RL-D-SLOT(WS-I) = MESH-SLOT-HAND-FIRE
             MOVE WS-I TO WS-FIRE-AT
         END-IF
     END-PERFORM
     MOVE "T11106 a player not on fire has no fire draw record" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FIRE-AT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Vertex WS-INDEX of the fire mesh is at (WS-EX, WS-EY, WS-EZ) with the texture coordinates of an atlas of 32 x 16 whose fire_1 is the right half: u = 0.5 + WS-EU / 2, v = WS-EV.
 CHECK-VERTEX.
     COMPUTE WS-EU = 0.5 + WS-EU / 2
     MOVE WS-NAME TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(RL-HF-X(WS-INDEX) - WS-EX) < 0.0002 AND FUNCTION ABS(RL-HF-Y(WS-INDEX) - WS-EY) < 0.0002
             AND FUNCTION ABS(RL-HF-Z(WS-INDEX) - WS-EZ) < 0.0002
             AND FUNCTION ABS(RL-HF-U(WS-INDEX) - WS-EU) < 0.0002 AND FUNCTION ABS(RL-HF-V(WS-INDEX) - WS-EV) < 0.0002
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-FIRE-OVERLAY.
 COPY CLTEST.
