*> Acceptance test of docs/protocol/34-entity-models-6-overworld-hostiles-arthropods-slimes.md section 13 (Shulker bullet): the mesh (one part, three boxes), setupAnim (yaw and pitch), the renderer submit stack (translate, three spins, scale -0.5/-0.5/0.5), the second
*> translucent pass scaled 1.5 with tint 654311423, the spark texture and the full block light.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-6-13.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLEMM.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-E                   FLOAT-LONG.
 01 WS-O                   FLOAT-LONG.
 01 WS-IN.
    05 WS-IV                FLOAT-LONG OCCURS 32 TIMES.
 01 WS-OUT.
    05 WS-OV                FLOAT-LONG OCCURS 64 TIMES.
 01 WS-LAYER              PIC X(32).
 01 WS-OK                 BINARY-LONG.
 01 WS-PARTS              BINARY-LONG.
 01 WS-CUBES              BINARY-LONG.
 01 WS-P                  BINARY-LONG.
 01 WS-PN                 PIC X(24).
 COPY EMCHKW.

 01 WS-X32               PIC X(32).
 01 WS-X32B              PIC X(32).
 01 WS-X120              PIC X(120).
 01 WS-X24               PIC X(24).
 01 WS-X40               PIC X(40).
 01 WS-FL                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "SHULKER_BULLET" TO WS-LAYER
     CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer SHULKER_BULLET is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-6§13 Shulker bullet 13 SHULKER_BULLET" TO CK-PREFIX
     MOVE "P main root 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C main 0 0 -4 -4 -1 8 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C main 0 10 -1 -4 -4 2 8 8 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C main 20 0 -4 -1 -4 8 2 8 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "13 SHULKER_BULLET: parts below the root" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 SHULKER_BULLET: cuboids" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 SHULKER_BULLET: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 SHULKER_BULLET: texture height" TO WS-NAME
     MOVE 32.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "SHULKER_BULLET" TO WS-LAYER
     CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF6-BULLET-ANIM" USING EMM-MODEL WS-IN
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.y" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SHULKER_BULLET" TO WS-LAYER
     CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 30 TO WS-IV(1)
     MOVE -15 TO WS-IV(2)
     CALL "EF6-BULLET-ANIM" USING EMM-MODEL WS-IN
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.y" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.xrot" TO WS-NAME
     MOVE -0.26179938 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.yrot" TO WS-NAME
     MOVE 0.52359876 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SHULKER_BULLET" TO WS-LAYER
     CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE -90 TO WS-IV(1)
     MOVE 45.5 TO WS-IV(2)
     CALL "EF6-BULLET-ANIM" USING EMM-MODEL WS-IN
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.y" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.xrot" TO WS-NAME
     MOVE 0.794124786 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.yrot" TO WS-NAME
     MOVE -1.57079628 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SHULKER_BULLET" TO WS-LAYER
     CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 180 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     CALL "EF6-BULLET-ANIM" USING EMM-MODEL WS-IN
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.y" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.xrot" TO WS-NAME
     MOVE 0.17453292 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.yrot" TO WS-NAME
     MOVE 3.14159256 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "main" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "main.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF6-BULLET-OPS" USING WS-IN WS-OUT
     MOVE "13 submit stack at age 0 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 0 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 0 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 0 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [4]" TO WS-NAME
     MOVE 0.15 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 0 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 0 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [6]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 0 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [7]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 0 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 0 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 0 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [10]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 0 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [11]" TO WS-NAME
     MOVE 180.0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 0 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 0 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 0 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [14]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 0 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [15]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 0 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 0 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 0 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [18]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 0 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [19]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 0 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [20]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 0 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [21]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10.5 TO WS-IV(1)
     CALL "EF6-BULLET-OPS" USING WS-IN WS-OUT
     MOVE "13 submit stack at age 10.5 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 10.5 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 10.5 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 10.5 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [4]" TO WS-NAME
     MOVE 0.15 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 10.5 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 10.5 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [6]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 10.5 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [7]" TO WS-NAME
     MOVE 156.136180607 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 10.5 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 10.5 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 10.5 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [10]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 10.5 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [11]" TO WS-NAME
     MOVE 89.562788621 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 10.5 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 10.5 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 10.5 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [14]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 10.5 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [15]" TO WS-NAME
     MOVE 359.996819248 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 10.5 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 10.5 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 10.5 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [18]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 10.5 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [19]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 10.5 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [20]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 10.5 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [21]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 33.25 TO WS-IV(1)
     CALL "EF6-BULLET-OPS" USING WS-IN WS-OUT
     MOVE "13 submit stack at age 33.25 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 33.25 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 33.25 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 33.25 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [4]" TO WS-NAME
     MOVE 0.15 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 33.25 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 33.25 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [6]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 33.25 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [7]" TO WS-NAME
     MOVE -32.828548311 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 33.25 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 33.25 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 33.25 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [10]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 33.25 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [11]" TO WS-NAME
     MOVE -176.981034057 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 33.25 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 33.25 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 33.25 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [14]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 33.25 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [15]" TO WS-NAME
     MOVE -346.462216078 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 33.25 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 33.25 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 33.25 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [18]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 33.25 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [19]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 33.25 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [20]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 33.25 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [21]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 100 TO WS-IV(1)
     CALL "EF6-BULLET-OPS" USING WS-IN WS-OUT
     MOVE "13 submit stack at age 100 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 100 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 100 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 100 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [4]" TO WS-NAME
     MOVE 0.15 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 100 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 100 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [6]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 100 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [7]" TO WS-NAME
     MOVE -97.92379996 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 100 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 100 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 100 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [10]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 100 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [11]" TO WS-NAME
     MOVE -151.032875234 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 100 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 100 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 100 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [14]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 100 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [15]" TO WS-NAME
     MOVE 234.103622457 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 100 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 100 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 100 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [18]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 100 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [19]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 100 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [20]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 submit stack at age 100 (count; code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg 6 rotate X deg; values) [21]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF6-BULLET-PASS" USING WS-IN WS-OUT
     MOVE "13 pass 1 (scale factor, translucent, tint -1 none, order) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 pass 1 (scale factor, translucent, tint -1 none, order) [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 pass 1 (scale factor, translucent, tint -1 none, order) [3]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 pass 1 (scale factor, translucent, tint -1 none, order) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     CALL "EF6-BULLET-PASS" USING WS-IN WS-OUT
     MOVE "13 pass 2 halo (scale factor, translucent, tint, order) [1]" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 pass 2 halo (scale factor, translucent, tint, order) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 pass 2 halo (scale factor, translucent, tint, order) [3]" TO WS-NAME
     MOVE 654311423 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "13 pass 2 halo (scale factor, translucent, tint, order) [4]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE SPACES TO WS-X120
     MOVE 0 TO WS-IV(1)
     CALL "EF6-BULLET-TEXTURE" USING WS-IN WS-X120
     MOVE "13 texture" TO WS-NAME
     MOVE "textures/entity/shulker/spark.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EF6-BULLET-BLOCKLIGHT" USING WS-IN WS-OUT
     MOVE "13 block light level" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-6§13 Shulker bullet: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-6§13 Shulker bullet: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-6-13.
