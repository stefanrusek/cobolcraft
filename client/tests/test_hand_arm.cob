*> T28300 (lane 002-lane-p70d): the arm of an empty main hand in first person (12 section 6.5; model 12 section 7.4). ENTITY-MODEL-SLOTS gives the model row "player" a slot of the entity atlas
*> in a first-person view of a standard world; HAND-MESH then builds the main arm and its sleeve (2 cuboids, 72 vertices) into RL-HA-VERTEX, RENDER-LIST-BUILD draws it after the depth
*> clear. Expected vertices from an independent script written from the formulas of 12 section 6.5 (the pose chain, the arm's pivot (-5, 2, 0) and cuboid (-3, -2, -2, 4 x 12 x 4) of the wide arm
*> at texture (40, 16), the sleeve at grow 0.25, the left arm's pivot (5, 2, 0) and cuboid (-1, -2, -2) at (32, 48)): the first three vertices and the sixth of the top face (the corners 6, 5, 1, 2 of
*> EF7-FACE-VERTS) at rest, 150 ms into a swing (p 0.5), with the equip offset 0.5, the sleeve's first vertex and the left arm's. The arm wears the skin of the player's own UUID (Alice: default skin index 5,
*> slim: the model row player_slim, 3 pixel arms, cuboid origin x -2 right and -1 left, texture code 6; Carol: index 9, wide, row player): the same chain with the slim cuboids (arm_expect.py of T51007).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-HAND-ARM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CONTENT.
 COPY CLMODELS.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-SLOT                BINARY-LONG.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-NAME                PIC X(100).
 01 WS-INDEX               BINARY-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-OPT-NAME            PIC X(40).
 01 WS-OPT-VALUE           PIC X(4096).
 01 WS-OPT-LENGTH          BINARY-LONG.
 01 WS-OPT-OK              BINARY-LONG.
 01 WS-UO                  FLOAT-LONG.
 01 WS-VO                  FLOAT-LONG.
 01 WS-CLEAR-AT            BINARY-LONG.
 01 WS-ARM-AT              BINARY-LONG.
 01 WS-TEX                 BINARY-LONG.
 01 WS-UB                  BINARY-LONG.
 01 WS-UBL                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
     MOVE 10 TO WS-EYE(1) WS-EYE(3)
     MOVE 64 TO WS-EYE(2)
     MOVE 0 TO PL-SLOT-COUNT(PL-HELD + 1) PL-OFFHAND-COUNT
     MOVE 0 TO CL-HAND-ITEM CL-OHAND-ITEM CL-SWING-AT CL-BOB-INIT EF-COUNT
     MOVE 3000000 TO CL-NOW-MS
     MOVE CL-NOW-MS TO CL-HAND-TICK-MS
     MOVE 1 TO CL-HAND-H CL-HAND-OH
     MOVE 100 TO CL-ATK-TICKER
*>   A stand-in world has no slot for the model and draws no arm.
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T28300 a stand-in world draws no arm of an empty hand" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-HA-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A standard world in first person: the model row "player" has a slot.
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE 0 TO EA-MT-COUNT
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     CALL "LOCAL-FIGURE-KEY" USING CLIENT-STATE WS-ROW WS-TEX
     MOVE 0 TO WS-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EA-MT-COUNT
         IF EA-MT-MODEL(WS-I) = WS-ROW AND EA-MT-TEX(WS-I) = WS-TEX
             MOVE WS-I TO WS-SLOT
         END-IF
     END-PERFORM
     MOVE "T28300 a first-person standard world gives the local figure a slot of the entity atlas: the slim model with the skin code of Alice (index 5 plus 1)" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SLOT > 0 AND CL-MD-KEY(WS-ROW) = "player_slim"
         MOVE EA-MT-TEX(WS-SLOT) TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO CL-CAMERA
     MOVE 0 TO EA-MT-COUNT
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "T28300 in third person the slot is the one of the figure (the model's own row, one slot)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EA-MT-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CL-CAMERA
     MOVE 0 TO EA-MT-COUNT
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE 1 TO WS-SLOT
*>   The top faces of the slim arm's boxes end at texel 47 (3 wide), the left one's at 39.
     MOVE 47 TO WS-UB
     MOVE 39 TO WS-UBL
*>   The arm: an empty main hand and off hand build 72 vertices of the arm and sleeve and none of an item.
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T28300 an empty hand builds the arm and the sleeve: 72 vertices" TO TL-CASE
     MOVE 72 TO TL-EXPECTED-N
     MOVE RL-HA-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T28300 an empty hand builds no item mesh" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-HAND-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The top face's corners 6, 5, 1 and 2 at rest.
     MOVE 1 TO WS-INDEX
     MOVE 0.54775 TO WS-EX
     MOVE -0.98456 TO WS-EY
     MOVE -0.58790 TO WS-EZ
     MOVE "T28300 rest: the first vertex of the right arm" TO WS-NAME
     PERFORM CHECK-VERTEX
     MOVE 2 TO WS-INDEX
     MOVE 0.61674 TO WS-EX
     MOVE -0.84707 TO WS-EY
     MOVE -0.48070 TO WS-EZ
     MOVE "T28300 rest: the second vertex of the right arm (the slim arm's outer edge 1 pixel in)" TO WS-NAME
     PERFORM CHECK-VERTEX
     MOVE 3 TO WS-INDEX
     MOVE 0.39976 TO WS-EX
     MOVE -0.72420 TO WS-EY
     MOVE -0.49863 TO WS-EZ
     MOVE "T28300 rest: the third vertex of the right arm" TO WS-NAME
     PERFORM CHECK-VERTEX
     MOVE 6 TO WS-INDEX
     MOVE 0.33077 TO WS-EX
     MOVE -0.86170 TO WS-EY
     MOVE -0.60584 TO WS-EZ
     MOVE "T28300 rest: the sixth vertex of the right arm" TO WS-NAME
     PERFORM CHECK-VERTEX
     MOVE 37 TO WS-INDEX
     MOVE 0.55035 TO WS-EX
     MOVE -1.01104 TO WS-EY
     MOVE -0.58294 TO WS-EZ
     MOVE "T28300 rest: the first vertex of the sleeve (grow 0.25)" TO WS-NAME
     PERFORM CHECK-VERTEX
*>   The texture coordinates of the top face (texels (44, 16) to (48, 20) of the 64 x 64 skin) and of the sleeve's (44, 32) to (48, 36).
     MOVE 1 TO WS-INDEX
     MOVE 16 TO WS-VO
     MOVE "T28300 the right arm's first vertex samples the top face of the skin region (40, 16)" TO WS-NAME
     PERFORM CHECK-UV
     MOVE 37 TO WS-INDEX
     MOVE 32 TO WS-VO
     MOVE "T28300 the sleeve's first vertex samples the top face of the skin region (40, 32)" TO WS-NAME
     PERFORM CHECK-UV
     MOVE "T28300 the arm's light is at least 0.1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-HA-B(1) >= 0.0999 AND RL-HA-A(1) = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   150 ms into a swing (p = 0.5) the arm is moved and turned by the swing; with the equip offset 0.5 it is 0.3 lower.
     COMPUTE CL-SWING-AT = CL-NOW-MS - 150
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE 1 TO WS-INDEX
     MOVE 0.47498 TO WS-EX
     MOVE -1.31970 TO WS-EY
     MOVE -0.88175 TO WS-EZ
     MOVE "T28300 150 ms into a swing the first vertex follows the swing pose" TO WS-NAME
     PERFORM CHECK-VERTEX
     MOVE 0 TO CL-SWING-AT
     MOVE 0.5 TO CL-HAND-H CL-HAND-OH
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE 1 TO WS-INDEX
     MOVE 0.54775 TO WS-EX
     MOVE -1.28456 TO WS-EY
     MOVE -0.58790 TO WS-EZ
     MOVE "T28300 the equip offset 0.5 lowers the arm by 0.3" TO WS-NAME
     PERFORM CHECK-VERTEX
     MOVE 1 TO CL-HAND-H CL-HAND-OH
*>   The left arm (mainHand left): pivot (5, 2, 0), the cuboid at texture (32, 48).
     MOVE "mainHand" TO WS-OPT-NAME
     MOVE '"left"' TO WS-OPT-VALUE
     MOVE 6 TO WS-OPT-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-OPT-NAME WS-OPT-VALUE WS-OPT-LENGTH WS-OPT-OK
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE 1 TO WS-INDEX
     MOVE -0.61674 TO WS-EX
     MOVE -0.84707 TO WS-EY
     MOVE -0.48070 TO WS-EZ
     MOVE "T28300 mainHand left: the first vertex of the left arm" TO WS-NAME
     PERFORM CHECK-VERTEX
     MOVE 48 TO WS-VO
     MOVE "T28300 the left arm's first vertex samples the top face of the skin region (32, 48)" TO WS-NAME
     PERFORM CHECK-UV-LEFT
     MOVE '"right"' TO WS-OPT-VALUE
     MOVE 7 TO WS-OPT-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-OPT-NAME WS-OPT-VALUE WS-OPT-LENGTH WS-OPT-OK
*>   The skin part option: a sleeve that is off is not drawn.
     MOVE "modelPart_right_sleeve" TO WS-OPT-NAME
     MOVE "false" TO WS-OPT-VALUE
     MOVE 5 TO WS-OPT-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-OPT-NAME WS-OPT-VALUE WS-OPT-LENGTH WS-OPT-OK
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T28300 modelPart_right_sleeve false: the arm alone, 36 vertices" TO TL-CASE
     MOVE 36 TO TL-EXPECTED-N
     MOVE RL-HA-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "true" TO WS-OPT-VALUE
     MOVE 4 TO WS-OPT-LENGTH
     CALL "OPTIONS-SET" USING CLIENT-STATE WS-OPT-NAME WS-OPT-VALUE WS-OPT-LENGTH WS-OPT-OK
*>   An item in the main hand: no arm. An item in the off hand only: the arm and the item.
     MOVE 1 TO PL-SLOT-COUNT(PL-HELD + 1)
     MOVE 10 TO PL-SLOT-ITEM(PL-HELD + 1)
     MOVE 11 TO CL-HAND-ITEM CL-ATK-LAST
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T28300 an item in the main hand shows no arm" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-HA-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-SLOT-COUNT(PL-HELD + 1) CL-HAND-ITEM CL-ATK-LAST
     MOVE 1 TO PL-OFFHAND-COUNT
     MOVE 10 TO PL-OFFHAND-ITEM
     MOVE 11 TO CL-OHAND-ITEM
     MOVE 1 TO CL-OHAND-H CL-OHAND-OH
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T28300 an item in the off hand only: the arm and the item are both built" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-HA-COUNT = 72 AND RL-HAND-COUNT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-OFFHAND-COUNT CL-OHAND-ITEM
*>   An invisible player (the mob effect invisibility, id 13) shows no arm; another effect leaves it.
     MOVE 1 TO EF-COUNT
     MOVE 13 TO EF-ID(1)
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T28300 an invisible player shows no arm" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-HA-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 14 TO EF-ID(1)
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T28300 another effect (blindness) leaves the arm" TO TL-CASE
     MOVE 72 TO TL-EXPECTED-N
     MOVE RL-HA-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO EF-COUNT
*>   A spectator is shown no hand at all, third person and the inventory screen none either.
     MOVE 3 TO PL-MODE
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T28300 a spectator has no arm and no hand" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = RL-HA-COUNT + RL-HAND-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-MODE
     MOVE 1 TO CL-CAMERA
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE "T28300 third person shows no arm" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-HA-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CL-CAMERA
*>   A player of a wide default skin (Carol, index 9: texture code 10): the model row player, the arm 4 wide (the first vertex of the wide arm).
     MOVE "Carol" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH
     MOVE 0 TO EA-MT-COUNT
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE 1 TO WS-SLOT
     MOVE 48 TO WS-UB
     CALL "HAND-MESH" USING CLIENT-STATE
     MOVE 2 TO WS-INDEX
     MOVE 0.63974 TO WS-EX
     MOVE -0.80123 TO WS-EY
     MOVE -0.44496 TO WS-EZ
     MOVE "T51007 a wide skin draws the wide arm: the second vertex is 4 pixels from the inner edge" TO WS-NAME
     PERFORM CHECK-VERTEX
     MOVE 1 TO WS-INDEX
     MOVE 16 TO WS-VO
     MOVE "T51007 the wide arm's top face is texels 44 to 48 of the skin region (40, 16)" TO WS-NAME
     PERFORM CHECK-UV
     MOVE "Alice" TO CL-NAME
*>   The render list: a depth clear (draw slot -1), then the arm mesh on the entity atlas.
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     MOVE 0 TO WS-CLEAR-AT WS-ARM-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
         IF RL-D-SLOT(WS-I) = -1
             MOVE WS-I TO WS-CLEAR-AT
         END-IF
         IF RL-D-SLOT(WS-I) = MESH-SLOT-HAND-ARM
             MOVE WS-I TO WS-ARM-AT
         END-IF
     END-PERFORM
     MOVE "T28300 the render list clears the depth and then draws the arm" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-CLEAR-AT > 0 AND WS-ARM-AT > WS-CLEAR-AT
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T28300 the arm is drawn with the entity atlas (texture 1) and the opaque pipeline" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ARM-AT > 0
         IF RL-D-TEX(WS-ARM-AT) = CC-TEX-ENTITIES AND RL-D-PIPELINE(WS-ARM-AT) = CC-PIPE-OPAQUE
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO CT-OPEN
     STOP RUN.

*> Vertex WS-INDEX of the arm mesh is at (WS-EX, WS-EY, WS-EZ) within 0.002.
 CHECK-VERTEX.
     MOVE WS-NAME TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(RL-HA-X(WS-INDEX) - WS-EX) < 0.002 AND FUNCTION ABS(RL-HA-Y(WS-INDEX) - WS-EY) < 0.002
             AND FUNCTION ABS(RL-HA-Z(WS-INDEX) - WS-EZ) < 0.002
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The texture coordinate of vertex WS-INDEX, taken back to texels of the 64 x 64 image in the player's slot, is on the top face rectangle (u 44 or 48, v WS-VO or WS-VO + 4).
 CHECK-UV.
     COMPUTE WS-UO = (RL-HA-U(WS-INDEX) * EA-W - EA-MT-X(WS-SLOT)) / EA-MT-W(WS-SLOT) * 64
     COMPUTE WS-EX = (RL-HA-V(WS-INDEX) * EA-H - EA-MT-Y(WS-SLOT)) / EA-MT-H(WS-SLOT) * 64
     MOVE WS-NAME TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF (FUNCTION ABS(WS-UO - 44) < 0.01 OR FUNCTION ABS(WS-UO - WS-UB) < 0.01)
             AND (FUNCTION ABS(WS-EX - WS-VO) < 0.01 OR FUNCTION ABS(WS-EX - WS-VO - 4) < 0.01)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The same for the left arm: the top face of its region (32, 48): u 36 or 40 for the arm (d 4).
 CHECK-UV-LEFT.
     COMPUTE WS-UO = (RL-HA-U(1) * EA-W - EA-MT-X(WS-SLOT)) / EA-MT-W(WS-SLOT) * 64
     COMPUTE WS-EX = (RL-HA-V(1) * EA-H - EA-MT-Y(WS-SLOT)) / EA-MT-H(WS-SLOT) * 64
     MOVE WS-NAME TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF (FUNCTION ABS(WS-UO - 36) < 0.01 OR FUNCTION ABS(WS-UO - WS-UBL) < 0.01)
             AND (FUNCTION ABS(WS-EX - WS-VO) < 0.01 OR FUNCTION ABS(WS-EX - WS-VO - 4) < 0.01)
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-HAND-ARM.
 COPY CLTEST.
