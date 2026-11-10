*> Acceptance test of docs/protocol/34-entity-models-5-wild-companion-animals-small-creatures.md section 5 (Panda): 5.1 the meshes of panda and panda_baby, 5.2 setupAnim after the quadruped base (unhappy, sneezing with the integer division, sitting for each age,
*> eating, scared, lying on the back, rolling), 5.3 the body transform (the four roll phases, sitting, lying), 5.4 the gene textures with the unknown-gene fallback, the held item layer and the counters. Mesh rows are the tables of the
*> document; formula values were worked by an independent script.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-5-5.
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
     MOVE "PANDA" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer PANDA is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-5§5 Panda 5.1 PANDA" TO CK-PREFIX
     MOVE "P head root 0 11.5 -17 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 6 -6.5 -5 -4 13 10 9 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 45 16 -3.5 0 -6 7 5 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 52 25 3.5 -8 -1 5 4 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 52 25 -8.5 -8 -1 5 4 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 10 0 1.5707964 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 25 -9.5 -13 -6.5 19 26 13 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -5.5 15 9 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 40 0 -3 0 -3 6 9 6 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 5.5 15 9 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 40 0 -3 0 -3 6 9 6 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -5.5 15 -9 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 40 0 -3 0 -3 6 9 6 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 5.5 15 -9 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 40 0 -3 0 -3 6 9 6 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "5.1 PANDA: parts below the root" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.1 PANDA: cuboids" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.1 PANDA: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.1 PANDA: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA_BABY" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer PANDA_BABY is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-5§5 Panda 5.1 PANDA_BABY" TO CK-PREFIX
     MOVE "P body root 0 18.5 2.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 11 -4.5 -3.5 -5.5 9 7 11 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head root 0 19 -3 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -3.5 -3 -5 7 6 5 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 24 6 -2 1 -6 4 2 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 24 0 -4.5 -4 -3.5 3 3 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 33 0 1.5 -4 -3.5 3 3 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -3 22 6.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 0 34 -1.5 0 -1.5 3 2 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 3 22 6.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 12 34 -1.5 0 -1.5 3 2 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -3 22 -1.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 0 29 -1.5 0 -1.5 3 2 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 3 22 -1.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 12 29 -1.5 0 -1.5 3 2 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "5.1 PANDA_BABY: parts below the root" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.1 PANDA_BABY: cuboids" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.1 PANDA_BABY: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.1 PANDA_BABY: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 10 TO WS-IV(1)
     MOVE -20 TO WS-IV(2)
     MOVE 1.2 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 12.5 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 10.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xrot" TO WS-NAME
     MOVE 1.5707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 11.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -17.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 0.17453292 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE -0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE 0.487975824 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE -0.487975824 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE -0.487975824 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE 0.487975824 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 10.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xrot" TO WS-NAME
     MOVE 1.5707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 11.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -17.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.340846671 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0.340846671 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE 0.587495182 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE -0.587495182 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE -15 TO WS-IV(1)
     MOVE 30 TO WS-IV(2)
     MOVE 3.5 TO WS-IV(3)
     MOVE 0.9 TO WS-IV(4)
     MOVE 40 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     MOVE 7 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 10.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xrot" TO WS-NAME
     MOVE 1.5707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 11.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -17.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE -0.3926991 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.52359876 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE -0.868865985 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE 0.868865985 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE 0.868865985 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE -0.868865985 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 5 TO WS-IV(1)
     MOVE 5 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 0.4 TO WS-IV(4)
     MOVE 5 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     MOVE 16 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 10.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xrot" TO WS-NAME
     MOVE 1.5707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 11.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -17.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE -0.7853982 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.08726646 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE 0.132240983 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE -0.132240983 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE -0.132240983 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE 0.132240983 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0.5 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     MOVE 19 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 10.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xrot" TO WS-NAME
     MOVE 1.5707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 11.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -17.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE -0.7853982 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE 1.323046572 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE -1.323046572 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE -1.323046572 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE 1.323046572 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 8 TO WS-IV(1)
     MOVE 8 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0.2 TO WS-IV(4)
     MOVE 6.5 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 0.6 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 10.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xrot" TO WS-NAME
     MOVE 1.67279634 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 11.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -17.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 0.998328374 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.139626336 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE 0.220129209 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0.27079642 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE -0.220129209 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE -0.5707964 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE -0.220129209 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE -0.27079642 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE 0.220129209 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE 0.5707964 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 8 TO WS-IV(1)
     MOVE 8 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0.2 TO WS-IV(4)
     MOVE 6.5 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 10.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xrot" TO WS-NAME
     MOVE 1.7407963 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 11.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -17.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 1.433243168 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.139626336 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE -0.262446768 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0.27079642 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE -0.220129209 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE -0.5707964 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE -0.262446768 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE -0.27079642 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE 0.220129209 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE 0.5707964 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 8 TO WS-IV(1)
     MOVE 8 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0.2 TO WS-IV(4)
     MOVE 6.5 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 10.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xrot" TO WS-NAME
     MOVE 1.65579635 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 11.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -17.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 2.1707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.139626336 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE -0.9 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0.27079642 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE -0.220129209 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE -0.5707964 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE -0.9 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE -0.27079642 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE 0.220129209 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE 0.5707964 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 8 TO WS-IV(1)
     MOVE 8 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0.2 TO WS-IV(4)
     MOVE 6.5 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 10.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xrot" TO WS-NAME
     MOVE 1.65579635 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 11.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -17.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 2.1707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.139626336 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE -0.9 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0.27079642 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE -0.220129209 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE -0.5707964 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE -0.9 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE -0.27079642 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE 0.220129209 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE 0.5707964 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 0.7 TO WS-IV(4)
     MOVE 9 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0.5 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 10.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xrot" TO WS-NAME
     MOVE 1.5707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 11.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -17.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 0.7853982 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE -0.233421959 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE 0.585434015 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE 0.233421959 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE -0.585434015 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 0.7 TO WS-IV(4)
     MOVE 9 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0.8 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 10.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xrot" TO WS-NAME
     MOVE 1.5707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 11.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -17.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 1.6449556 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE 0.488765059 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE -0.488765059 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE -0.488765059 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE 0.488765059 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 3 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 0.7 TO WS-IV(4)
     MOVE 9 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     MOVE 10 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0.4 TO WS-IV(12)
     MOVE 0.6 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 10.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xrot" TO WS-NAME
     MOVE 1.7407963 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 11.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -17.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 1.86203526 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE -0.270467571 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE -0.270467571 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE 0.488765059 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0.27079642 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE -0.488765059 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE -0.5707964 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE -0.488765059 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE -0.27079642 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -5.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE 0.488765059 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE 0.5707964 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA_BABY" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 10 TO WS-IV(1)
     MOVE -20 TO WS-IV(2)
     MOVE 1.2 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 12.5 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 18.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.z" TO WS-NAME
     MOVE 2.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 19.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 0.17453292 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE -0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE 0.487975824 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 6.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE -0.487975824 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE -0.487975824 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 6.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE 0.487975824 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA_BABY" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 18.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.z" TO WS-NAME
     MOVE 2.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 19.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.340846671 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0.340846671 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE 0.587495182 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 6.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE -0.587495182 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 6.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA_BABY" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE -15 TO WS-IV(1)
     MOVE 30 TO WS-IV(2)
     MOVE 3.5 TO WS-IV(3)
     MOVE 0.9 TO WS-IV(4)
     MOVE 40 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     MOVE 7 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 18.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.z" TO WS-NAME
     MOVE 2.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 19.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE -0.3926991 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.52359876 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE -0.868865985 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 6.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE 0.868865985 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE 0.868865985 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 6.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE -0.868865985 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA_BABY" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 5 TO WS-IV(1)
     MOVE 5 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 0.4 TO WS-IV(4)
     MOVE 5 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     MOVE 16 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 18.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.z" TO WS-NAME
     MOVE 2.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 19.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE -0.7853982 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.08726646 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE 0.132240983 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 6.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE -0.132240983 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE -0.132240983 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 6.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE 0.132240983 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA_BABY" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0.5 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     MOVE 19 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 18.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.z" TO WS-NAME
     MOVE 2.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 19.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE -0.7853982 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE 1.323046572 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 6.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE -1.323046572 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE -1.323046572 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 6.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE 1.323046572 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA_BABY" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 8 TO WS-IV(1)
     MOVE 8 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0.2 TO WS-IV(4)
     MOVE 6.5 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 0.6 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 18.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.z" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xrot" TO WS-NAME
     MOVE 0.104719752 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 18.1 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -8.1 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 0.139626336 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.139626336 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -3.6 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE 0.220129209 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0.27079642 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 4.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE -0.220129209 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE -0.5707964 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -3.6 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE -0.220129209 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE -0.27079642 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 4.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE 0.220129209 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE 0.5707964 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA_BABY" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 8 TO WS-IV(1)
     MOVE 8 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0.2 TO WS-IV(4)
     MOVE 6.5 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 18.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.z" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xrot" TO WS-NAME
     MOVE 0.17453292 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 17.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -11.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 1.433243168 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.139626336 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -5.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE -0.262446768 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0.27079642 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE -0.220129209 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE -0.5707964 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -5.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE -0.262446768 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE -0.27079642 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE 0.220129209 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE 0.5707964 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA_BABY" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 8 TO WS-IV(1)
     MOVE 8 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0.2 TO WS-IV(4)
     MOVE 6.5 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 18.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.z" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xrot" TO WS-NAME
     MOVE 0.08726646 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 18.25 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -7.25 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 2.1707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.139626336 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -3.25 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE -0.9 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0.27079642 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 4.75 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE -0.220129209 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE -0.5707964 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -3.25 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE -0.9 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE -0.27079642 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 4.75 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE 0.220129209 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE 0.5707964 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA_BABY" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 8 TO WS-IV(1)
     MOVE 8 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0.2 TO WS-IV(4)
     MOVE 6.5 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 18.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.z" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xrot" TO WS-NAME
     MOVE 0.08726646 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 18.25 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -7.25 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 2.1707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.139626336 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -3.25 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE -0.9 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0.27079642 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 4.75 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE -0.220129209 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE -0.5707964 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -3.25 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE -0.9 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE -0.27079642 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 4.75 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE 0.220129209 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE 0.5707964 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA_BABY" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 0.7 TO WS-IV(4)
     MOVE 9 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0.5 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 18.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.z" TO WS-NAME
     MOVE 2.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 19.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 0.7853982 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE -0.233421959 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 6.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE 0.585434015 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE 0.233421959 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 6.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE -0.585434015 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA_BABY" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 0.7 TO WS-IV(4)
     MOVE 9 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 0 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0.8 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 18.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.z" TO WS-NAME
     MOVE 2.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 19.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 1.6449556 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE 0.488765059 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 6.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE -0.488765059 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE -0.488765059 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 6.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE 0.488765059 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PANDA_BABY" TO WS-LAYER
     CALL "EF5-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 3 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 0.7 TO WS-IV(4)
     MOVE 9 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     MOVE 10 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0.4 TO WS-IV(12)
     MOVE 0.6 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     CALL "EF5-PANDA-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 18.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.z" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xrot" TO WS-NAME
     MOVE 0.17453292 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 17.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -11.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 1.350404433 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE -0.270467571 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE -0.270467571 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -5.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE 0.488765059 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0.27079642 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE -0.488765059 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE -0.5707964 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -5.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE -0.488765059 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE -0.27079642 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 22.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE 0.488765059 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE 0.5707964 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 0 roll 0 sit 0 scared 0 age 0 xRot 0 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 3.25 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 10 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 0 roll 3.25 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 3.25 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 3.25 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 3.25 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 0.464285714 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 3.25 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 3.25 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 3.25 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE -41.785714286 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 3.25 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 3.25 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 7.5 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 10 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 0 roll 7.5 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 7.5 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 7.5 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 7.5 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 7.5 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 7.5 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 7.5 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE -90.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 7.5 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 7.5 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 8 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 0 roll 8 sit 0 scared 0 age 0 xRot 0 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 8 sit 0 scared 0 age 0 xRot 0 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 8 sit 0 scared 0 age 0 xRot 0 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 8 sit 0 scared 0 age 0 xRot 0 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 8 sit 0 scared 0 age 0 xRot 0 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 8 sit 0 scared 0 age 0 xRot 0 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 8 sit 0 scared 0 age 0 xRot 0 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE -90.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 8 sit 0 scared 0 age 0 xRot 0 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 8 sit 0 scared 0 age 0 xRot 0 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 12.75 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 5 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 0 roll 12.75 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 12.75 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 12.75 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 12.75 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 1.407142857 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 12.75 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 12.75 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 12.75 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE -151.071428571 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 12.75 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 12.75 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 16.5 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 5 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 0 roll 16.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 16.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 16.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 16.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 1.542857143 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 16.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 16.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 16.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE -186.428571429 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 16.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 16.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 20 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 5 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 0 roll 20 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 20 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 20 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 20 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 1.142857143 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 20 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 20 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 20 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE -231.428571429 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 20 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 20 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 24.25 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 5 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 0 roll 24.25 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 24.25 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 24.25 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 24.25 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 0.771428571 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 24.25 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 24.25 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 24.25 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE -273.214285714 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 24.25 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 24.25 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 31.5 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 5 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 0 roll 31.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 31.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 31.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 31.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 31.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 31.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 31.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE -360.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 31.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 31.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 32 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 5 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 0 roll 32 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 40 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 5 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 0 roll 40 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0.5 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 5 TO WS-IV(5)
     MOVE 20 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 0 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 0.4 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE 65.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [12]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 7.5 TO WS-IV(5)
     MOVE 20 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 0 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE 110 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [12]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [14]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [15]" TO WS-NAME
     MOVE -0.156885063 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0.3 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 2 TO WS-IV(5)
     MOVE -10 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 0 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 0.24 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE 17.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [12]" TO WS-NAME
     MOVE -0.3 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [14]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [15]" TO WS-NAME
     MOVE -0.125843345 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 15 TO WS-IV(6)
     MOVE 0.6 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 0 roll 0 sit 0 scared 0 age 0 xRot 15 lie 0.6 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0 scared 0 age 0 xRot 15 lie 0.6 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0 scared 0 age 0 xRot 15 lie 0.6 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0 scared 0 age 0 xRot 15 lie 0.6 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 0.78 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0 scared 0 age 0 xRot 15 lie 0.6 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0 scared 0 age 0 xRot 15 lie 0.6 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0 scared 0 age 0 xRot 15 lie 0.6 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE 123.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0 scared 0 age 0 xRot 15 lie 0.6 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0 scared 0 age 0 xRot 15 lie 0.6 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0.4 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     MOVE 12 TO WS-IV(6)
     MOVE 0.7 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 0.32 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE 48.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [12]" TO WS-NAME
     MOVE -0.4 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [14]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [15]" TO WS-NAME
     MOVE -0.128893162 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [18]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [19]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [20]" TO WS-NAME
     MOVE 0.91 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [22]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [23]" TO WS-NAME
     MOVE 138.0 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [24]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [25]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 5.5 TO WS-IV(2)
     MOVE 0.2 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     MOVE 12 TO WS-IV(6)
     MOVE 0.9 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 0.785714286 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE -70.714285714 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [12]" TO WS-NAME
     MOVE 0.16 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [14]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [15]" TO WS-NAME
     MOVE 30.0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [18]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [19]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [20]" TO WS-NAME
     MOVE -0.2 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [22]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [23]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [24]" TO WS-NAME
     MOVE 1.17 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [25]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [26]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(26) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [27]" TO WS-NAME
     MOVE 174.0 TO WS-E
     MOVE WS-OV(27) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [28]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(28) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 0 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [29]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(29) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 1 roll 0 sit 0 scared 0 age 0 xRot 0 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 3.25 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 10 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 1 roll 3.25 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 3.25 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 3.25 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 3.25 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 0.232142857 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 3.25 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 3.25 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 3.25 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE -41.785714286 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 3.25 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 3.25 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 7.5 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 10 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 1 roll 7.5 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 7.5 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 7.5 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 7.5 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 7.5 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 7.5 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 7.5 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE -90.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 7.5 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 7.5 sit 0 scared 0 age 0 xRot 10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 8 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 1 roll 8 sit 0 scared 0 age 0 xRot 0 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 8 sit 0 scared 0 age 0 xRot 0 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 8 sit 0 scared 0 age 0 xRot 0 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 8 sit 0 scared 0 age 0 xRot 0 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 8 sit 0 scared 0 age 0 xRot 0 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 8 sit 0 scared 0 age 0 xRot 0 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 8 sit 0 scared 0 age 0 xRot 0 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE -90.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 8 sit 0 scared 0 age 0 xRot 0 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 8 sit 0 scared 0 age 0 xRot 0 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 12.75 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 5 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 1 roll 12.75 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 12.75 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 12.75 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 12.75 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 0.567857143 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 12.75 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 12.75 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 12.75 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE -151.071428571 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 12.75 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 12.75 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 16.5 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 5 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 1 roll 16.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 16.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 16.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 16.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 0.578571429 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 16.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 16.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 16.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE -186.428571429 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 16.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 16.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 20 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 5 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 1 roll 20 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 20 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 20 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 20 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 0.428571429 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 20 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 20 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 20 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE -231.428571429 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 20 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 20 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 24.25 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 5 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 1 roll 24.25 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 24.25 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 24.25 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 24.25 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 0.289285714 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 24.25 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 24.25 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 24.25 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE -273.214285714 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 24.25 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 24.25 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 31.5 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 5 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 1 roll 31.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 31.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 31.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 31.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 31.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 31.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 31.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE -360.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 31.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 31.5 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 32 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 5 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 1 roll 32 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 40 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 5 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 1 roll 40 sit 0 scared 0 age 0 xRot 5 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0.5 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 5 TO WS-IV(5)
     MOVE 20 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 1 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 0.4 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE 65.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [12]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.5 scared 0 age 5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 7.5 TO WS-IV(5)
     MOVE 20 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 1 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE 110 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [12]" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [14]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [15]" TO WS-NAME
     MOVE -0.156885063 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [18]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [19]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [20]" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 1 scared 1 age 7.5 xRot 20 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [21]" TO WS-NAME
     MOVE 0.55 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0.3 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 2 TO WS-IV(5)
     MOVE -10 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 1 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 0.24 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE 17.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [12]" TO WS-NAME
     MOVE -0.3 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [14]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [15]" TO WS-NAME
     MOVE -0.125843345 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [18]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [19]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [20]" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.3 scared 1 age 2 xRot -10 lie 0 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [21]" TO WS-NAME
     MOVE 0.55 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 15 TO WS-IV(6)
     MOVE 0.6 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 1 roll 0 sit 0 scared 0 age 0 xRot 15 lie 0.6 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0 scared 0 age 0 xRot 15 lie 0.6 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0 scared 0 age 0 xRot 15 lie 0.6 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0 scared 0 age 0 xRot 15 lie 0.6 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0 scared 0 age 0 xRot 15 lie 0.6 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0 scared 0 age 0 xRot 15 lie 0.6 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0 scared 0 age 0 xRot 15 lie 0.6 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE 123.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0 scared 0 age 0 xRot 15 lie 0.6 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0 scared 0 age 0 xRot 15 lie 0.6 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0.4 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     MOVE 12 TO WS-IV(6)
     MOVE 0.7 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 0.32 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE 48.0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [12]" TO WS-NAME
     MOVE -0.4 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [14]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [15]" TO WS-NAME
     MOVE -0.128893162 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [18]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [19]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [20]" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [21]" TO WS-NAME
     MOVE 0.55 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [22]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [23]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [24]" TO WS-NAME
     MOVE 0.35 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [25]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [26]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(26) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [27]" TO WS-NAME
     MOVE 138.0 TO WS-E
     MOVE WS-OV(27) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [28]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(28) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 0 sit 0.4 scared 1 age 3 xRot 12 lie 0.7 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [29]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(29) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 5.5 TO WS-IV(2)
     MOVE 0.2 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 3 TO WS-IV(5)
     MOVE 12 TO WS-IV(6)
     MOVE 0.9 TO WS-IV(7)
     CALL "EF5-PANDA-BODY" USING WS-IN WS-OUT
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [1]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [4]" TO WS-NAME
     MOVE 0.392857143 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [6]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [7]" TO WS-NAME
     MOVE -70.714285714 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [12]" TO WS-NAME
     MOVE 0.16 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [14]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [15]" TO WS-NAME
     MOVE 30.0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [18]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [19]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [20]" TO WS-NAME
     MOVE -0.2 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [22]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [23]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [24]" TO WS-NAME
     MOVE 0.45 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [25]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [26]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(26) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [27]" TO WS-NAME
     MOVE 174.0 TO WS-E
     MOVE WS-OV(27) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [28]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(28) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.3 body transform baby 1 roll 5.5 sit 0.2 scared 0 age 3 xRot 12 lie 0.9 (count, code 1 translate 3 rotate Y deg 6 rotate X deg, values) [29]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(29) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF5-PANDA-TEXTURE" USING WS-IN WS-X120
     MOVE "5.4 gene 0 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/panda/panda.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF5-PANDA-TEXTURE" USING WS-IN WS-X120
     MOVE "5.4 gene 0 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/panda/panda_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF5-PANDA-TEXTURE" USING WS-IN WS-X120
     MOVE "5.4 gene 1 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/panda/panda_lazy.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF5-PANDA-TEXTURE" USING WS-IN WS-X120
     MOVE "5.4 gene 1 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/panda/lazy_panda_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 2 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF5-PANDA-TEXTURE" USING WS-IN WS-X120
     MOVE "5.4 gene 2 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/panda/panda_worried.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF5-PANDA-TEXTURE" USING WS-IN WS-X120
     MOVE "5.4 gene 2 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/panda/worried_panda_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 3 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF5-PANDA-TEXTURE" USING WS-IN WS-X120
     MOVE "5.4 gene 3 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/panda/panda_playful.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 3 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF5-PANDA-TEXTURE" USING WS-IN WS-X120
     MOVE "5.4 gene 3 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/panda/playful_panda_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 4 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF5-PANDA-TEXTURE" USING WS-IN WS-X120
     MOVE "5.4 gene 4 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/panda/panda_brown.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 4 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF5-PANDA-TEXTURE" USING WS-IN WS-X120
     MOVE "5.4 gene 4 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/panda/brown_panda_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 5 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF5-PANDA-TEXTURE" USING WS-IN WS-X120
     MOVE "5.4 gene 5 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/panda/panda_weak.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 5 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF5-PANDA-TEXTURE" USING WS-IN WS-X120
     MOVE "5.4 gene 5 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/panda/weak_panda_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 6 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF5-PANDA-TEXTURE" USING WS-IN WS-X120
     MOVE "5.4 gene 6 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/panda/panda_aggressive.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 6 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF5-PANDA-TEXTURE" USING WS-IN WS-X120
     MOVE "5.4 gene 6 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/panda/aggressive_panda_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 7 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF5-PANDA-TEXTURE" USING WS-IN WS-X120
     MOVE "5.4 gene 7 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/panda/panda.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 7 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF5-PANDA-TEXTURE" USING WS-IN WS-X120
     MOVE "5.4 gene 7 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/panda/panda_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 9 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF5-PANDA-TEXTURE" USING WS-IN WS-X120
     MOVE "5.4 gene 9 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/panda/panda.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 9 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF5-PANDA-TEXTURE" USING WS-IN WS-X120
     MOVE "5.4 gene 9 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/panda/panda_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE -1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF5-PANDA-TEXTURE" USING WS-IN WS-X120
     MOVE "5.4 gene -1 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/panda/panda.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE -1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF5-PANDA-TEXTURE" USING WS-IN WS-X120
     MOVE "5.4 gene -1 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/panda/panda_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 7.5 TO WS-IV(5)
     CALL "EF5-PANDA-ITEM" USING WS-IN WS-OUT
     MOVE "5.4 item layer item 0 sitting 0 scared 0 eating 0: drawn, translate x y z [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 0 sitting 0 scared 0 eating 0: drawn, translate x y z [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 0 sitting 0 scared 0 eating 0: drawn, translate x y z [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 0 sitting 0 scared 0 eating 0: drawn, translate x y z [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 7.5 TO WS-IV(5)
     CALL "EF5-PANDA-ITEM" USING WS-IN WS-OUT
     MOVE "5.4 item layer item 0 sitting 0 scared 0 eating 1: drawn, translate x y z [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 0 sitting 0 scared 0 eating 1: drawn, translate x y z [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 0 sitting 0 scared 0 eating 1: drawn, translate x y z [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 0 sitting 0 scared 0 eating 1: drawn, translate x y z [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 7.5 TO WS-IV(5)
     CALL "EF5-PANDA-ITEM" USING WS-IN WS-OUT
     MOVE "5.4 item layer item 0 sitting 0 scared 1 eating 0: drawn, translate x y z [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 0 sitting 0 scared 1 eating 0: drawn, translate x y z [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 0 sitting 0 scared 1 eating 0: drawn, translate x y z [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 0 sitting 0 scared 1 eating 0: drawn, translate x y z [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 7.5 TO WS-IV(5)
     CALL "EF5-PANDA-ITEM" USING WS-IN WS-OUT
     MOVE "5.4 item layer item 0 sitting 0 scared 1 eating 1: drawn, translate x y z [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 0 sitting 0 scared 1 eating 1: drawn, translate x y z [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 0 sitting 0 scared 1 eating 1: drawn, translate x y z [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 0 sitting 0 scared 1 eating 1: drawn, translate x y z [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 7.5 TO WS-IV(5)
     CALL "EF5-PANDA-ITEM" USING WS-IN WS-OUT
     MOVE "5.4 item layer item 0 sitting 1 scared 0 eating 0: drawn, translate x y z [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 0 sitting 1 scared 0 eating 0: drawn, translate x y z [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 0 sitting 1 scared 0 eating 0: drawn, translate x y z [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 0 sitting 1 scared 0 eating 0: drawn, translate x y z [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 7.5 TO WS-IV(5)
     CALL "EF5-PANDA-ITEM" USING WS-IN WS-OUT
     MOVE "5.4 item layer item 0 sitting 1 scared 0 eating 1: drawn, translate x y z [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 0 sitting 1 scared 0 eating 1: drawn, translate x y z [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 0 sitting 1 scared 0 eating 1: drawn, translate x y z [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 0 sitting 1 scared 0 eating 1: drawn, translate x y z [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 7.5 TO WS-IV(5)
     CALL "EF5-PANDA-ITEM" USING WS-IN WS-OUT
     MOVE "5.4 item layer item 0 sitting 1 scared 1 eating 0: drawn, translate x y z [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 0 sitting 1 scared 1 eating 0: drawn, translate x y z [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 0 sitting 1 scared 1 eating 0: drawn, translate x y z [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 0 sitting 1 scared 1 eating 0: drawn, translate x y z [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 7.5 TO WS-IV(5)
     CALL "EF5-PANDA-ITEM" USING WS-IN WS-OUT
     MOVE "5.4 item layer item 0 sitting 1 scared 1 eating 1: drawn, translate x y z [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 0 sitting 1 scared 1 eating 1: drawn, translate x y z [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 0 sitting 1 scared 1 eating 1: drawn, translate x y z [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 0 sitting 1 scared 1 eating 1: drawn, translate x y z [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 7.5 TO WS-IV(5)
     CALL "EF5-PANDA-ITEM" USING WS-IN WS-OUT
     MOVE "5.4 item layer item 1 sitting 0 scared 0 eating 0: drawn, translate x y z [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 1 sitting 0 scared 0 eating 0: drawn, translate x y z [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 1 sitting 0 scared 0 eating 0: drawn, translate x y z [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 1 sitting 0 scared 0 eating 0: drawn, translate x y z [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 7.5 TO WS-IV(5)
     CALL "EF5-PANDA-ITEM" USING WS-IN WS-OUT
     MOVE "5.4 item layer item 1 sitting 0 scared 0 eating 1: drawn, translate x y z [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 1 sitting 0 scared 0 eating 1: drawn, translate x y z [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 1 sitting 0 scared 0 eating 1: drawn, translate x y z [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 1 sitting 0 scared 0 eating 1: drawn, translate x y z [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 7.5 TO WS-IV(5)
     CALL "EF5-PANDA-ITEM" USING WS-IN WS-OUT
     MOVE "5.4 item layer item 1 sitting 0 scared 1 eating 0: drawn, translate x y z [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 1 sitting 0 scared 1 eating 0: drawn, translate x y z [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 1 sitting 0 scared 1 eating 0: drawn, translate x y z [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 1 sitting 0 scared 1 eating 0: drawn, translate x y z [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 7.5 TO WS-IV(5)
     CALL "EF5-PANDA-ITEM" USING WS-IN WS-OUT
     MOVE "5.4 item layer item 1 sitting 0 scared 1 eating 1: drawn, translate x y z [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 1 sitting 0 scared 1 eating 1: drawn, translate x y z [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 1 sitting 0 scared 1 eating 1: drawn, translate x y z [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 1 sitting 0 scared 1 eating 1: drawn, translate x y z [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 7.5 TO WS-IV(5)
     CALL "EF5-PANDA-ITEM" USING WS-IN WS-OUT
     MOVE "5.4 item layer item 1 sitting 1 scared 0 eating 0: drawn, translate x y z [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 1 sitting 1 scared 0 eating 0: drawn, translate x y z [2]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 1 sitting 1 scared 0 eating 0: drawn, translate x y z [3]" TO WS-NAME
     MOVE 1.4 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 1 sitting 1 scared 0 eating 0: drawn, translate x y z [4]" TO WS-NAME
     MOVE -0.6 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 7.5 TO WS-IV(5)
     CALL "EF5-PANDA-ITEM" USING WS-IN WS-OUT
     MOVE "5.4 item layer item 1 sitting 1 scared 0 eating 1: drawn, translate x y z [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 1 sitting 1 scared 0 eating 1: drawn, translate x y z [2]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 1 sitting 1 scared 0 eating 1: drawn, translate x y z [3]" TO WS-NAME
     MOVE 1.487977711 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 1 sitting 1 scared 0 eating 1: drawn, translate x y z [4]" TO WS-NAME
     MOVE -0.604493976 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 7.5 TO WS-IV(5)
     CALL "EF5-PANDA-ITEM" USING WS-IN WS-OUT
     MOVE "5.4 item layer item 1 sitting 1 scared 1 eating 0: drawn, translate x y z [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 1 sitting 1 scared 1 eating 0: drawn, translate x y z [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 1 sitting 1 scared 1 eating 0: drawn, translate x y z [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 1 sitting 1 scared 1 eating 0: drawn, translate x y z [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 7.5 TO WS-IV(5)
     CALL "EF5-PANDA-ITEM" USING WS-IN WS-OUT
     MOVE "5.4 item layer item 1 sitting 1 scared 1 eating 1: drawn, translate x y z [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 1 sitting 1 scared 1 eating 1: drawn, translate x y z [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 1 sitting 1 scared 1 eating 1: drawn, translate x y z [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "5.4 item layer item 1 sitting 1 scared 1 eating 1: drawn, translate x y z [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF5-PANDA-COUNTER" USING WS-IN WS-OUT
     MOVE "5.4 sit/back/roll amount 0 flag 1 after one tick" TO WS-NAME
     MOVE 0.15 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.9 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF5-PANDA-COUNTER" USING WS-IN WS-OUT
     MOVE "5.4 sit/back/roll amount 0.9 flag 1 after one tick" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF5-PANDA-COUNTER" USING WS-IN WS-OUT
     MOVE "5.4 sit/back/roll amount 1 flag 1 after one tick" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF5-PANDA-COUNTER" USING WS-IN WS-OUT
     MOVE "5.4 sit/back/roll amount 0.5 flag 0 after one tick" TO WS-NAME
     MOVE 0.31 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF5-PANDA-COUNTER" USING WS-IN WS-OUT
     MOVE "5.4 sit/back/roll amount 0.1 flag 0 after one tick" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF5-PANDA-COUNTER" USING WS-IN WS-OUT
     MOVE "5.4 sit/back/roll amount 0 flag 0 after one tick" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-5§5 Panda: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-5§5 Panda: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-5-5.
