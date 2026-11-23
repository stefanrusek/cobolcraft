*> T59711 (docs/protocol/49 section 4): the player-model preview of the inventory screen. The screen lays out a WK-PREVIEW widget in the box (leftPos + 26, topPos + 8) of 49 x 70 GUI pixels with
*> the model scale 30; in a world of the standard set RENDER-LIST-BUILD makes the local figure's visible faces into the preview layer (RL-PV-VERTEX: window pixels, texture 1, UI pipeline) between the UI
*> layer and the icons, following the pointer of the frame before (a = atan((cx - x) / 40), b = atan((cy - y) / 40), body yaw 180 + a x 20, head yaw a x 20 more, head pitch -b x 20, the figure turned about
*> X by b x 20 degrees and half a turn about Z, lifted by 0.9625 blocks, scaled by 30 x the GUI scale), lit by the ENTITY_IN_UI lights. Expected numbers: tests/fixtures/gen_preview.py (independent of the
*> COBOL; window 854 x 480, GUI scale 2, leftPos 125, topPos 37, centre (175.5, 80)): the centre of the hat's front face (texels 40 to 48 x 8 to 16 of the skin) in the frames of the pointer.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-INVENTORY-PREVIEW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CONTENT.
 COPY CLMODELS.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-MODEL-KEY           PIC X(24).
 01 WS-UUID                PIC X(16).
 01 WS-SKIN-INDEX          BINARY-LONG.
 01 WS-SKIN-TEXTURE        PIC X(40).
 01 WS-SKIN-SLIM           BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HLIGHT              FLOAT-LONG.
 01 WS-HY                  FLOAT-LONG.
 01 WS-SU                  FLOAT-LONG.
 01 WS-SV                  FLOAT-LONG.
 01 WS-U-PX                FLOAT-LONG.
 01 WS-V-PX                FLOAT-LONG.
 01 WS-MAX-R               FLOAT-LONG.
 01 WS-MIN-R               FLOAT-LONG.
 01 WS-MIN-Y               FLOAT-LONG.
 01 WS-MAX-Y               FLOAT-LONG.
 01 WS-UI-AT               BINARY-LONG.
 01 WS-PV-AT               BINARY-LONG.
 01 WS-IC-AT               BINARY-LONG.
 01 WS-EN-COUNT-BEFORE     BINARY-LONG.
 01 WS-NAME                PIC X(120).
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "N" TO TL-MODE
     MOVE 854 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE 0 TO IN-CAPTURED
*>   A world of the stand-in set has no model of the player: the widget is laid out and nothing is drawn.
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     MOVE 1 TO CT-OPEN
     MOVE 350 TO IN-CURSOR-X
     MOVE 160 TO IN-CURSOR-Y
     MOVE CC-KEY-E TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE "T59711 the inventory screen lays out the preview widget (49 4.1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM COUNT-WIDGETS
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T59711 a stand-in world draws no preview" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-PV-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
*>   The standard set: the inventory screen opens on the first frame (the pointer of the frame before is 0, 0).
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 0 TO EA-MT-COUNT
*>   A stack in the main inventory, so that the icon layer has quads.
     MOVE 8 TO PL-SLOT-COUNT(10)
     MOVE 1 TO PL-SLOT-ITEM(10)
     MOVE EN-COUNT TO WS-EN-COUNT-BEFORE
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE 0 TO WS-I
     PERFORM VARYING WS-W FROM 1 BY 1 UNTIL WS-W > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-W) = WK-PREVIEW
             MOVE WS-W TO WS-I
         END-IF
     END-PERFORM
     MOVE "T59711 the box is (leftPos + 26, topPos + 8), 49 x 70, scale 30: x 151, y 45" TO TL-CASE
     MOVE 151045049070030 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SM-W-X(WS-I) * 1000000000000 + SM-W-Y(WS-I) * 1000000000 + SM-W-W(WS-I) * 1000000
         + SM-W-H(WS-I) * 1000 + SM-W-ARG(WS-I)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM FIND-SLOT
     MOVE "T59711 the figure has a slot in the entity atlas (the model of its skin, the skin's code)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SLOT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T59711 the first frame draws a preview of whole faces (a multiple of 6 vertices)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-PV-COUNT > 0 AND FUNCTION MOD(RL-PV-COUNT, 6) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The first frame's pointer is the one of no frame: (0, 0), the figure turned a long way (gen_preview.py).
     MOVE 343.446 TO WS-EX
     MOVE 119.879 TO WS-EY
     MOVE "T59711 the first frame follows the pointer 0, 0: the hat's front face" TO WS-NAME
     PERFORM CHECK-HAT
     MOVE "T59711 the preview is drawn without touching the entity mesh or the replica rows" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-EN-COUNT = 0 AND EN-COUNT = WS-EN-COUNT-BEFORE AND EN-USED(EN-COUNT + 1) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The draw order: the UI layer, the preview (texture 1, the UI pipeline, the UI's matrix), the icons.
     MOVE 0 TO WS-UI-AT WS-PV-AT WS-IC-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-DRAW-COUNT
         IF RL-D-SLOT(WS-I) = MESH-SLOT-UI
             MOVE WS-I TO WS-UI-AT
         END-IF
         IF RL-D-SLOT(WS-I) = MESH-SLOT-PREVIEW
             MOVE WS-I TO WS-PV-AT
         END-IF
         IF RL-D-SLOT(WS-I) = MESH-SLOT-ICONS
             MOVE WS-I TO WS-IC-AT
         END-IF
     END-PERFORM
     MOVE "T59711 the preview is drawn after the UI layer and before the icons" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-UI-AT > 0 AND WS-PV-AT = WS-UI-AT + 1 AND WS-IC-AT = WS-PV-AT + 1 AND RL-IC-COUNT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T59711 the preview is drawn with the UI pipeline, the entity atlas and the UI's matrix" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-PV-AT = 0 OR WS-UI-AT = 0
         MOVE 1 TO WS-PV-AT WS-UI-AT
         MOVE 0 TO TL-OBSERVED-N
     ELSE
         IF RL-D-PIPELINE(WS-PV-AT) = CC-PIPE-UI AND RL-D-TEX(WS-PV-AT) = CC-TEX-ENTITIES
                 AND RL-D-MATRIX(WS-PV-AT, 1) = RL-D-MATRIX(WS-UI-AT, 1) AND RL-D-MATRIX(WS-PV-AT, 6) = RL-D-MATRIX(WS-UI-AT, 6)
                 AND RL-D-MATRIX(WS-PV-AT, 13) = -1 AND RL-D-MATRIX(WS-PV-AT, 14) = -1
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The second frame follows the pointer of the first (window 350, 160 = GUI 175, 80: the centre less half a pixel): nearly front on.
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE 350.862 TO WS-EX
     MOVE 119.256 TO WS-EY
     MOVE "T59711 the pointer at the centre: the figure faces the viewer (the hat's front face)" TO WS-NAME
     PERFORM CHECK-HAT
*>   Its extent: the pants' front faces end 24.25 pixels below the model's origin (0.011 pixels more at the corner the leg's idle turn of 0.005 radians lowers: HumanoidModel), the
*>   hat's top edge is 8.5 above it. The hat's front face is lit 0.4 + 0.6 x 0.70014 = 0.82008 (12 section 1.9, the normal (0, 0, 1) against normalize(0.2, -1, 1) in the view space); no
*>   face is lit less than 0.4 or more than 1.
     MOVE 9999 TO WS-MIN-Y
     MOVE -9999 TO WS-MAX-Y
     MOVE 9 TO WS-MIN-R
     MOVE 0 TO WS-MAX-R
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-PV-COUNT
         MOVE FUNCTION MIN(WS-MIN-Y, RL-PV-Y(WS-I)) TO WS-MIN-Y
         MOVE FUNCTION MAX(WS-MAX-Y, RL-PV-Y(WS-I)) TO WS-MAX-Y
         MOVE FUNCTION MIN(WS-MIN-R, RL-PV-R(WS-I)) TO WS-MIN-R
         MOVE FUNCTION MAX(WS-MAX-R, RL-PV-R(WS-I)) TO WS-MAX-R
     END-PERFORM
     MOVE "T59711 the figure ends at the feet 218.573 and the hat's top 103.436" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(WS-MAX-Y - 218.573) < 0.05 AND FUNCTION ABS(WS-MIN-Y - 103.436) < 0.02
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T59711 the hat's front face is lit 0.82008 (ENTITY_IN_UI), no face is lit below 0.4 or above 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(WS-HLIGHT - 0.82008) < 0.003 AND WS-MIN-R >= 0.399 AND WS-MAX-R <= 1.0001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T59711 the tint is grey (the light in all three channels), the alpha 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 1 TO TL-OBSERVED-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-PV-COUNT
         IF RL-PV-R(WS-I) NOT = RL-PV-G(WS-I) OR RL-PV-R(WS-I) NOT = RL-PV-BLUE(WS-I) OR RL-PV-A(WS-I) NOT = 1
             MOVE 0 TO TL-OBSERVED-N
         END-IF
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The pointer 40 pixels left of the box's centre: the figure turns to it (body yaw 180 + a x 20, the head as much again).
     MOVE 270 TO IN-CURSOR-X
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE 342.695 TO WS-EX
     MOVE 119.256 TO WS-EY
     MOVE "T59711 the pointer left of the box: the hat's front face turns to the left" TO WS-NAME
     PERFORM CHECK-HAT
*>   The pointer above (GUI 175, 40): the figure and the head tilt back.
     MOVE 350 TO IN-CURSOR-X
     MOVE 80 TO IN-CURSOR-Y
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE 350.900 TO WS-EX
     MOVE 116.225 TO WS-EY
     MOVE "T59711 the pointer above the box: the hat's front face tilts" TO WS-NAME
     PERFORM CHECK-HAT
*>   Gliding (the Fall Flying pose): the head pitch is 0 and the preview is still made.
     MOVE 1 TO PL-POSE
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "T59711 a gliding player still has a preview" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-PV-COUNT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO PL-POSE
*>   A wide skin (Carol: the default skin index 9, wide) draws from the model row "player"; Alice's (index 5) is slim.
     MOVE "Carol" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-STEP" USING CLIENT-STATE
     PERFORM FIND-SLOT
     MOVE "T59711 a wide skin has its own slot of the model row player" TO TL-CASE
     MOVE "player" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     IF WS-SLOT > 0
         MOVE CL-MD-KEY(EA-MT-MODEL(WS-SLOT)) TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "T59711 and a preview" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-PV-COUNT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   With every replica row counted in there is no spare row to make the figure on: no preview (and no slot made for it).
     MOVE EN-COUNT TO WS-EN-COUNT-BEFORE
     MOVE CL-MAX-ENTITIES TO EN-COUNT
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "T59711 without a free replica row there is no preview" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-PV-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-EN-COUNT-BEFORE TO EN-COUNT
*>   The creative screen's survival inventory tab has the preview too (40-7 7.1 rule 8): the box (leftPos + 73, topPos + 6), 32 x 43, scale 20. Which tab it is, is found by showing each.
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE 1 TO PL-MODE
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE 0 TO WS-I
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 20 OR WS-I > 0
         MOVE WS-J TO CR-TAB
         CALL "TEST-STEP" USING CLIENT-STATE
         PERFORM VARYING WS-W FROM 1 BY 1 UNTIL WS-W > SM-WIDGET-COUNT
             IF SM-W-KIND(WS-W) = WK-PREVIEW
                 MOVE WS-W TO WS-I
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "T59711 one tab of the creative screen lays out the preview box (leftPos 116 + 73, topPos 52 + 6), 32 x 43, scale 20" TO TL-CASE
     MOVE 189058032043020 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-I > 0
         COMPUTE TL-OBSERVED-N = SM-W-X(WS-I) * 1000000000000 + SM-W-Y(WS-I) * 1000000000 + SM-W-W(WS-I) * 1000000
             + SM-W-H(WS-I) * 1000 + SM-W-ARG(WS-I)
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "T59711 and it draws a preview of the figure" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-PV-COUNT > 0 AND SM-SCREEN = SCR-CREATIVE
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE 0 TO PL-MODE
*>   Closing the screen clears the pointer's memory and the layer.
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "T59711 with the screen closed there is no preview and no remembered pointer" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = RL-PV-COUNT + RL-PV-MOUSE-X + RL-PV-MOUSE-Y
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.

 COUNT-WIDGETS.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-W FROM 1 BY 1 UNTIL WS-W > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-W) = WK-PREVIEW
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM.

*> WS-SLOT: the slot of the local figure's model (slim or wide by the skin of its offline UUID) and skin code.
 FIND-SLOT.
     CALL "CLP-OFFLINE-UUID" USING CL-NAME CL-NAME-LENGTH WS-UUID
     CALL "PLAYER-SKIN-FOR-UUID" USING WS-UUID WS-SKIN-INDEX WS-SKIN-TEXTURE WS-SKIN-SLIM
     MOVE SPACES TO WS-MODEL-KEY
     MOVE "player" TO WS-MODEL-KEY
     IF WS-SKIN-SLIM = 1
         MOVE "player_slim" TO WS-MODEL-KEY
     END-IF
     CALL "ENTITY-MODEL-FIND" USING WS-MODEL-KEY WS-ROW
     COMPUTE WS-CODE = WS-SKIN-INDEX + 1
     MOVE 0 TO WS-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EA-MT-COUNT
         IF EA-MT-MODEL(WS-I) = WS-ROW AND EA-MT-TEX(WS-I) = WS-CODE
             MOVE WS-I TO WS-SLOT
         END-IF
     END-PERFORM.

*> The quad of the preview whose texels are the hat's front face (u 40 to 48, v 8 to 16 of the 64 x 64 skin): the mean of its six vertices' window position is WS-HX, WS-HY.
 CHECK-HAT.
     PERFORM FIND-SLOT
     MOVE 0 TO WS-FOUND
     MOVE 0 TO WS-HX WS-HY
     PERFORM VARYING WS-Q FROM 0 BY 1 UNTIL WS-Q >= RL-PV-COUNT / 6 OR WS-SLOT = 0
         MOVE 0 TO WS-SU WS-SV
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
             COMPUTE WS-I = WS-Q * 6 + WS-K
             COMPUTE WS-U-PX = (RL-PV-U(WS-I) * EA-W - EA-MT-X(WS-SLOT)) / EA-MT-W(WS-SLOT) * 64
             COMPUTE WS-V-PX = (RL-PV-V(WS-I) * EA-H - EA-MT-Y(WS-SLOT)) / EA-MT-H(WS-SLOT) * 64
             COMPUTE WS-SU = WS-SU + WS-U-PX / 6
             COMPUTE WS-SV = WS-SV + WS-V-PX / 6
         END-PERFORM
         IF FUNCTION ABS(WS-SU - 44) < 0.01 AND FUNCTION ABS(WS-SV - 12) < 0.01
             ADD 1 TO WS-FOUND
             MOVE 0 TO WS-HX WS-HY
             COMPUTE WS-I = WS-Q * 6 + 1
             MOVE RL-PV-R(WS-I) TO WS-HLIGHT
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
                 COMPUTE WS-I = WS-Q * 6 + WS-K
                 COMPUTE WS-HX = WS-HX + RL-PV-X(WS-I) / 6
                 COMPUTE WS-HY = WS-HY + RL-PV-Y(WS-I) / 6
             END-PERFORM
         END-IF
     END-PERFORM
     MOVE WS-NAME TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FOUND = 1 AND FUNCTION ABS(WS-HX - WS-EX) < 0.01 AND FUNCTION ABS(WS-HY - WS-EY) < 0.01
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-INVENTORY-PREVIEW.
 COPY CLTEST.
