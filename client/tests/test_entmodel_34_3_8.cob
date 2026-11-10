*> Acceptance test of docs/protocol/34-entity-models-3-villagers-illagers-golems-misc.md section 8 (Snow golem): the mesh (5 cuboids, every one with grow -0.5), setupAnim with the worked example, the head layer rules and transform, the renderer. Mesh rows are the table of the document;
*> formula values were worked by an independent script.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-3-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLEMM.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-E                   FLOAT-LONG.
 01 WS-O                   FLOAT-LONG.
 01 WS-IN.
    05 WS-IV                FLOAT-LONG OCCURS 16 TIMES.
 01 WS-OUT.
    05 WS-OV                FLOAT-LONG OCCURS 64 TIMES.
 01 WS-LAYER              PIC X(32).
 01 WS-OK                 BINARY-LONG.
 01 WS-PARTS              BINARY-LONG.
 01 WS-CUBES              BINARY-LONG.
 01 WS-P                  BINARY-LONG.
 01 WS-TEXT               PIC X(100).
 01 WS-PN                 PIC X(24).
 COPY EMCHKW.
 PROCEDURE DIVISION.
     MOVE "SNOW_GOLEM" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer SNOW_GOLEM is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-3§8 Snow golem mesh" TO CK-PREFIX
     MOVE "P head root 0 4 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -4 -8 -4 8 8 8 -0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_arm root 5 6 1 0 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_arm 32 0 -1 0 -1 12 2 2 -0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_arm root -5 6 -1 0 3.1415927 -1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_arm 32 0 -1 0 -1 12 2 2 -0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P upper_body root 0 13 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C upper_body 0 16 -5 -10 -5 10 10 10 -0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P lower_body root 0 24 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C lower_body 0 36 -6 -12 -6 12 12 12 -0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "8 snow golem: parts below the root" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 snow golem: cuboids" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 snow golem: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 snow golem: texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "SNOW_GOLEM" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 0 TO WS-IV(1)
     MOVE 40 TO WS-IV(2)
     CALL "EM3-SNOW-GOLEM-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.69813168 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "upper_body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "upper_body.yrot" TO WS-NAME
     MOVE 0.17453292 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.yrot" TO WS-NAME
     MOVE 0.17453292 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.yrot" TO WS-NAME
     MOVE 3.316125574 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.x" TO WS-NAME
     MOVE 4.92403877 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.z" TO WS-NAME
     MOVE -0.868240863 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.x" TO WS-NAME
     MOVE -4.92403877 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.z" TO WS-NAME
     MOVE 0.868240863 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SNOW_GOLEM" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 10 TO WS-IV(1)
     MOVE -60 TO WS-IV(2)
     CALL "EM3-SNOW-GOLEM-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 0.17453292 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE -1.04719752 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "upper_body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "upper_body.yrot" TO WS-NAME
     MOVE -0.26179938 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.yrot" TO WS-NAME
     MOVE -0.26179938 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.yrot" TO WS-NAME
     MOVE 2.879793274 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.x" TO WS-NAME
     MOVE 4.829629142 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.z" TO WS-NAME
     MOVE 1.294095188 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.x" TO WS-NAME
     MOVE -4.829629142 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.z" TO WS-NAME
     MOVE -1.294095188 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SNOW_GOLEM" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE -5 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EM3-SNOW-GOLEM-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE -0.08726646 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "upper_body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "upper_body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.yrot" TO WS-NAME
     MOVE 3.141592654 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.x" TO WS-NAME
     MOVE 5.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.z" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.x" TO WS-NAME
     MOVE -5.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SNOW_GOLEM" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 25 TO WS-IV(1)
     MOVE 175 TO WS-IV(2)
     CALL "EM3-SNOW-GOLEM-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 0.4363323 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 3.0543261 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "upper_body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "upper_body.yrot" TO WS-NAME
     MOVE 0.763581525 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.yrot" TO WS-NAME
     MOVE 0.763581525 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.yrot" TO WS-NAME
     MOVE 3.905174179 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.x" TO WS-NAME
     MOVE 3.611819889 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.z" TO WS-NAME
     MOVE -3.457565197 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.x" TO WS-NAME
     MOVE -3.611819889 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.z" TO WS-NAME
     MOVE 3.457565197 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SNOW_GOLEM" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 0 TO WS-IV(1)
     MOVE 40 TO WS-IV(2)
     CALL "EM3-SNOW-GOLEM-ANIM" USING EMM-MODEL WS-IN
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.x" TO WS-NAME
     MOVE 4.92404 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.z" TO WS-NAME
     MOVE -0.86824 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.yrot" TO WS-NAME
     MOVE 3.31613 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EM3-SNOW-HEAD-DRAW" USING WS-IN WS-OUT
     MOVE "8 head layer drawn pumpkin 1 invisible 0 glowing 0" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EM3-SNOW-HEAD-DRAW" USING WS-IN WS-OUT
     MOVE "8 head layer drawn pumpkin 0 invisible 0 glowing 0" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EM3-SNOW-HEAD-DRAW" USING WS-IN WS-OUT
     MOVE "8 head layer drawn pumpkin 1 invisible 1 glowing 0" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EM3-SNOW-HEAD-DRAW" USING WS-IN WS-OUT
     MOVE "8 head layer drawn pumpkin 1 invisible 1 glowing 1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EM3-SNOW-HEAD-DRAW" USING WS-IN WS-OUT
     MOVE "8 head layer drawn pumpkin 0 invisible 1 glowing 1" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     CALL "EM3-SNOW-HEAD-OPS" USING WS-OUT
     MOVE "8 head layer operation count" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 head layer operation 1 value 0" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 head layer operation 1 value 1" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 head layer operation 1 value 2" TO WS-NAME
     MOVE -0.34375 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 head layer operation 1 value 3" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 head layer operation 2 value 0" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 head layer operation 2 value 1" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 head layer operation 2 value 2" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 head layer operation 2 value 3" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 head layer operation 3 value 0" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 head layer operation 3 value 1" TO WS-NAME
     MOVE 0.625 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 head layer operation 3 value 2" TO WS-NAME
     MOVE -0.625 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 head layer operation 3 value 3" TO WS-NAME
     MOVE -0.625 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 head layer operation 4 value 0" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 head layer operation 4 value 1" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 head layer operation 4 value 2" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 head layer operation 4 value 3" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EM3-SNOW-RENDERER" USING WS-IN WS-OUT
     MOVE "8 shadow radius 0.5, outline only when glowing and invisible (visible, glowing) [1]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 shadow radius 0.5, outline only when glowing and invisible (visible, glowing) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 shadow radius 0.5, outline only when glowing and invisible (visible, glowing) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EM3-SNOW-RENDERER" USING WS-IN WS-OUT
     MOVE "8 outline when glowing and invisible [1]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 outline when glowing and invisible [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 outline when glowing and invisible [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EM3-SNOW-RENDERER" USING WS-IN WS-OUT
     MOVE "8 no outline when not glowing [1]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 no outline when not glowing [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8 no outline when not glowing [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     CALL "EM3-SNOW-TEXTURE" USING WS-TEXT
     MOVE "8 texture" TO WS-NAME
     MOVE "textures/entity/snow_golem/snow_golem.png" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-TEXT
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-3§8 Snow golem: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-3§8 Snow golem: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-3-8.
