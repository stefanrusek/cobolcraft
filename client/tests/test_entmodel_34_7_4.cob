*> Acceptance test of docs/protocol/34-entity-models-7-nether-end-bosses.md section 4 (Strider): 4.1 the renderer facts (texture by suffocating and baby, shadow with the baby half, cold shaking, the saddle layer decision), 4.2 the shared animation, 4.3 the adult mesh
*> with its bristles and the adult custom animation, 4.4 the baby mesh and its custom animation (worked value 16.75). Mesh rows are the tables of the document.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-7-4.
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
     MOVE "STRIDER" TO WS-LAYER
     CALL "EF7-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer STRIDER is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-7§4 Strider 4 STRIDER" TO CK-PREFIX
     MOVE "P right_leg root -4 8 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_leg 0 32 -2 0 -2 4 16 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_leg root 4 8 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_leg 0 55 -2 0 -2 4 16 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 1 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 0 -8 -6 -8 16 14 16 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_bottom_bristle body -8 4 -8 0 0 -1.2217305" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_bottom_bristle 16 65 -12 0 0 12 0 16 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_middle_bristle body -8 -1 -8 0 0 -1.134464" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_middle_bristle 16 49 -12 0 0 12 0 16 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_top_bristle body -8 -5 -8 0 0 -0.87266463" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_top_bristle 16 33 -12 0 0 12 0 16 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_top_bristle body 8 -6 -8 0 0 0.87266463" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_top_bristle 16 33 0 0 0 12 0 16 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_middle_bristle body 8 -2 -8 0 0 1.134464" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_middle_bristle 16 49 0 0 0 12 0 16 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_bottom_bristle body 8 3 -8 0 0 1.2217305" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_bottom_bristle 16 65 0 0 0 12 0 16 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "4 STRIDER: parts below the root" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "4 STRIDER: cuboids" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "4 STRIDER: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "4 STRIDER: texture height" TO WS-NAME
     MOVE 128.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "STRIDER_BABY" TO WS-LAYER
     CALL "EF7-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer STRIDER_BABY is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-7§4 Strider 4 STRIDER_BABY" TO CK-PREFIX
     MOVE "P body root 0 16.75 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 0 -3.5 -3.75 -4 7 7 8 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_leg root -1.5 20 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_leg 0 24 -1 0 -1 2 4 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_leg root 1.5 20 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_leg 8 24 -1 0 -1 2 4 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P bristle0 body 0 -4.25 2 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C bristle0 0 21 -3.5 -2.5 0 7 3 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P bristle1 body 0 -4.25 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C bristle1 0 18 -3.5 -2.5 0 7 3 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P bristle2 body 0 -4.25 -2 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C bristle2 0 15 -3.5 -2.5 0 7 3 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "4 STRIDER_BABY: parts below the root" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "4 STRIDER_BABY: cuboids" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "4 STRIDER_BABY: texture width" TO WS-NAME
     MOVE 32.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "4 STRIDER_BABY: texture height" TO WS-NAME
     MOVE 32.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "STRIDER_SADDLE" TO WS-LAYER
     CALL "EF7-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer STRIDER_SADDLE is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-7§4 Strider 4 STRIDER_SADDLE" TO CK-PREFIX
     MOVE "P right_leg root -4 8 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_leg 0 32 -2 0 -2 4 16 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_leg root 4 8 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_leg 0 55 -2 0 -2 4 16 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 1 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 0 -8 -6 -8 16 14 16 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_bottom_bristle body -8 4 -8 0 0 -1.2217305" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_bottom_bristle 16 65 -12 0 0 12 0 16 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_middle_bristle body -8 -1 -8 0 0 -1.134464" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_middle_bristle 16 49 -12 0 0 12 0 16 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_top_bristle body -8 -5 -8 0 0 -0.87266463" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_top_bristle 16 33 -12 0 0 12 0 16 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_top_bristle body 8 -6 -8 0 0 0.87266463" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_top_bristle 16 33 0 0 0 12 0 16 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_middle_bristle body 8 -2 -8 0 0 1.134464" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_middle_bristle 16 49 0 0 0 12 0 16 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_bottom_bristle body 8 3 -8 0 0 1.2217305" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_bottom_bristle 16 65 0 0 0 12 0 16 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "4 STRIDER_SADDLE: parts below the root" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "4 STRIDER_SADDLE: cuboids" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "4 STRIDER_SADDLE: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "4 STRIDER_SADDLE: texture height" TO WS-NAME
     MOVE 128.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "STRIDER" TO WS-LAYER
     CALL "EF7-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 10 TO WS-IV(1)
     MOVE -20 TO WS-IV(2)
     MOVE 1.0 TO WS-IV(3)
     MOVE 0.25 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF7-STRIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 1.929262798 TO WS-E
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
     MOVE 0.17453292 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE -0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.099749499 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.y" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.zrot" TO WS-NAME
     MOVE 1.198740909 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.y" TO WS-NAME
     MOVE 7.31836124 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xrot" TO WS-NAME
     MOVE 0.34081938 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zrot" TO WS-NAME
     MOVE 0.031925949 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.zrot" TO WS-NAME
     MOVE 1.113242839 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.y" TO WS-NAME
     MOVE -6.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.zrot" TO WS-NAME
     MOVE 0.86205405 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.y" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.zrot" TO WS-NAME
     MOVE -1.244720091 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.y" TO WS-NAME
     MOVE 8.68163876 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xrot" TO WS-NAME
     MOVE -0.34081938 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zrot" TO WS-NAME
     MOVE -0.031925949 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.y" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.zrot" TO WS-NAME
     MOVE -1.155685161 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.y" TO WS-NAME
     MOVE -5.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.zrot" TO WS-NAME
     MOVE -0.88327521 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "STRIDER" TO WS-LAYER
     CALL "EF7-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 5 TO WS-IV(1)
     MOVE 5 TO WS-IV(2)
     MOVE 2.5 TO WS-IV(3)
     MOVE 0.1 TO WS-IV(4)
     MOVE 12.5 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF7-STRIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 2.328223743 TO WS-E
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
     MOVE -0.022862453 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.y" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.zrot" TO WS-NAME
     MOVE 1.37634943 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.y" TO WS-NAME
     MOVE 7.618365687 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xrot" TO WS-NAME
     MOVE 0.190817156 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zrot" TO WS-NAME
     MOVE -0.005227846 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.zrot" TO WS-NAME
     MOVE 1.292778337 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.y" TO WS-NAME
     MOVE -6.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.zrot" TO WS-NAME
     MOVE 0.826005764 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.y" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.zrot" TO WS-NAME
     MOVE -1.06711157 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.y" TO WS-NAME
     MOVE 8.381634313 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xrot" TO WS-NAME
     MOVE -0.190817156 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zrot" TO WS-NAME
     MOVE 0.005227846 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.y" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.zrot" TO WS-NAME
     MOVE -0.976149663 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.y" TO WS-NAME
     MOVE -5.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.zrot" TO WS-NAME
     MOVE -0.919323496 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "STRIDER" TO WS-LAYER
     CALL "EF7-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF7-STRIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 2.0 TO WS-E
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
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.y" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.zrot" TO WS-NAME
     MOVE 1.2217305 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.y" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.zrot" TO WS-NAME
     MOVE 1.134464 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.y" TO WS-NAME
     MOVE -6.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.zrot" TO WS-NAME
     MOVE 0.87266463 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.y" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.zrot" TO WS-NAME
     MOVE -1.2217305 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.y" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.y" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.zrot" TO WS-NAME
     MOVE -1.134464 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.y" TO WS-NAME
     MOVE -5.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.zrot" TO WS-NAME
     MOVE -0.87266463 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "STRIDER" TO WS-LAYER
     CALL "EF7-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE -15 TO WS-IV(1)
     MOVE 30 TO WS-IV(2)
     MOVE 3.3 TO WS-IV(3)
     MOVE 0.9 TO WS-IV(4)
     MOVE 40.25 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF7-STRIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 1.764618557 TO WS-E
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
     MOVE -0.26179938 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.52359876 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE -0.097190307 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.y" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.zrot" TO WS-NAME
     MOVE 1.164335102 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.y" TO WS-NAME
     MOVE 7.381688365 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xrot" TO WS-NAME
     MOVE 0.309155818 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zrot" TO WS-NAME
     MOVE -0.034292796 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.zrot" TO WS-NAME
     MOVE 1.161934551 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.y" TO WS-NAME
     MOVE -6.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.zrot" TO WS-NAME
     MOVE 0.799150272 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.y" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.zrot" TO WS-NAME
     MOVE -1.279125898 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.y" TO WS-NAME
     MOVE 8.618311635 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xrot" TO WS-NAME
     MOVE -0.309155818 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zrot" TO WS-NAME
     MOVE 0.034292796 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.y" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.zrot" TO WS-NAME
     MOVE -1.106993449 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.y" TO WS-NAME
     MOVE -5.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.zrot" TO WS-NAME
     MOVE -0.946178988 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "STRIDER" TO WS-LAYER
     CALL "EF7-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 20 TO WS-IV(1)
     MOVE -40 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     MOVE 0.2 TO WS-IV(4)
     MOVE 6 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF7-STRIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 2.380429542 TO WS-E
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
     MOVE -0.070375661 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.y" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.zrot" TO WS-NAME
     MOVE 1.311596942 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.y" TO WS-NAME
     MOVE 8.687147595 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xrot" TO WS-NAME
     MOVE -0.343573797 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zrot" TO WS-NAME
     MOVE 0.017875155 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.zrot" TO WS-NAME
     MOVE 1.341796771 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.y" TO WS-NAME
     MOVE -6.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.zrot" TO WS-NAME
     MOVE 0.997275379 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.y" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.zrot" TO WS-NAME
     MOVE -1.131864058 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.y" TO WS-NAME
     MOVE 7.312852405 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xrot" TO WS-NAME
     MOVE 0.343573797 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zrot" TO WS-NAME
     MOVE -0.017875155 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.y" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.zrot" TO WS-NAME
     MOVE -0.927131229 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.y" TO WS-NAME
     MOVE -5.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.zrot" TO WS-NAME
     MOVE -0.748053881 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "STRIDER_BABY" TO WS-LAYER
     CALL "EF7-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 10 TO WS-IV(1)
     MOVE -20 TO WS-IV(2)
     MOVE 1.0 TO WS-IV(3)
     MOVE 0.25 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     CALL "EF7-STRIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 17.214631399 TO WS-E
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
     MOVE 0.17453292 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE -0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.099749499 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.y" TO WS-NAME
     MOVE -4.25 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.z" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.xrot" TO WS-NAME
     MOVE -0.022989591 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.y" TO WS-NAME
     MOVE -4.25 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.xrot" TO WS-NAME
     MOVE -0.021221161 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.y" TO WS-NAME
     MOVE -4.25 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.z" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.xrot" TO WS-NAME
     MOVE -0.01061058 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.x" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.y" TO WS-NAME
     MOVE 19.31836124 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xrot" TO WS-NAME
     MOVE 0.34081938 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zrot" TO WS-NAME
     MOVE 0.031925949 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.x" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.y" TO WS-NAME
     MOVE 20.68163876 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xrot" TO WS-NAME
     MOVE -0.34081938 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zrot" TO WS-NAME
     MOVE -0.031925949 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "STRIDER_BABY" TO WS-LAYER
     CALL "EF7-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 5 TO WS-IV(1)
     MOVE 5 TO WS-IV(2)
     MOVE 2.5 TO WS-IV(3)
     MOVE 0.1 TO WS-IV(4)
     MOVE 12.5 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     CALL "EF7-STRIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 17.414111871 TO WS-E
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
     MOVE -0.022862453 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.y" TO WS-NAME
     MOVE -4.25 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.z" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.xrot" TO WS-NAME
     MOVE 0.15461893 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.y" TO WS-NAME
     MOVE -4.25 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.xrot" TO WS-NAME
     MOVE 0.158314337 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.y" TO WS-NAME
     MOVE -4.25 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.z" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.xrot" TO WS-NAME
     MOVE -0.046658866 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.x" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.y" TO WS-NAME
     MOVE 19.618365687 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xrot" TO WS-NAME
     MOVE 0.190817156 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zrot" TO WS-NAME
     MOVE -0.005227846 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.x" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.y" TO WS-NAME
     MOVE 20.381634313 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xrot" TO WS-NAME
     MOVE -0.190817156 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zrot" TO WS-NAME
     MOVE 0.005227846 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "STRIDER_BABY" TO WS-LAYER
     CALL "EF7-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     CALL "EF7-STRIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 17.25 TO WS-E
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
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.y" TO WS-NAME
     MOVE -4.25 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.z" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.y" TO WS-NAME
     MOVE -4.25 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.y" TO WS-NAME
     MOVE -4.25 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.z" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.x" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.y" TO WS-NAME
     MOVE 20.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.x" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.y" TO WS-NAME
     MOVE 20.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "STRIDER_BABY" TO WS-LAYER
     CALL "EF7-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE -15 TO WS-IV(1)
     MOVE 30 TO WS-IV(2)
     MOVE 3.3 TO WS-IV(3)
     MOVE 0.9 TO WS-IV(4)
     MOVE 40.25 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     CALL "EF7-STRIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 17.132309279 TO WS-E
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
     MOVE -0.26179938 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.52359876 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE -0.097190307 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.y" TO WS-NAME
     MOVE -4.25 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.z" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.xrot" TO WS-NAME
     MOVE -0.057395398 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.y" TO WS-NAME
     MOVE -4.25 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.xrot" TO WS-NAME
     MOVE 0.027470551 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.y" TO WS-NAME
     MOVE -4.25 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.z" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.xrot" TO WS-NAME
     MOVE -0.073514358 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.x" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.y" TO WS-NAME
     MOVE 19.381688365 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xrot" TO WS-NAME
     MOVE 0.309155818 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zrot" TO WS-NAME
     MOVE -0.034292796 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.x" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.y" TO WS-NAME
     MOVE 20.618311635 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xrot" TO WS-NAME
     MOVE -0.309155818 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zrot" TO WS-NAME
     MOVE 0.034292796 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "STRIDER_BABY" TO WS-LAYER
     CALL "EF7-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 20 TO WS-IV(1)
     MOVE -40 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     MOVE 0.2 TO WS-IV(4)
     MOVE 6 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     CALL "EF7-STRIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 17.440214771 TO WS-E
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
     MOVE -0.070375661 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.y" TO WS-NAME
     MOVE -4.25 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.z" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.xrot" TO WS-NAME
     MOVE 0.089866442 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle0.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.y" TO WS-NAME
     MOVE -4.25 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.xrot" TO WS-NAME
     MOVE 0.207332771 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle1.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.y" TO WS-NAME
     MOVE -4.25 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.z" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.xrot" TO WS-NAME
     MOVE 0.124610749 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "bristle2" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "bristle2.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.x" TO WS-NAME
     MOVE 1.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.y" TO WS-NAME
     MOVE 20.687147595 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xrot" TO WS-NAME
     MOVE -0.343573797 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zrot" TO WS-NAME
     MOVE 0.017875155 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.x" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.y" TO WS-NAME
     MOVE 19.312852405 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xrot" TO WS-NAME
     MOVE 0.343573797 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zrot" TO WS-NAME
     MOVE -0.017875155 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "STRIDER_SADDLE" TO WS-LAYER
     CALL "EF7-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 10 TO WS-IV(1)
     MOVE -20 TO WS-IV(2)
     MOVE 1.0 TO WS-IV(3)
     MOVE 0.25 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF7-STRIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 1.929262798 TO WS-E
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
     MOVE 0.17453292 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE -0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE 0.099749499 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.y" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.zrot" TO WS-NAME
     MOVE 1.198740909 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.y" TO WS-NAME
     MOVE 7.31836124 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xrot" TO WS-NAME
     MOVE 0.34081938 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zrot" TO WS-NAME
     MOVE 0.031925949 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.zrot" TO WS-NAME
     MOVE 1.113242839 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.y" TO WS-NAME
     MOVE -6.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.zrot" TO WS-NAME
     MOVE 0.86205405 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.y" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.zrot" TO WS-NAME
     MOVE -1.244720091 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.y" TO WS-NAME
     MOVE 8.68163876 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xrot" TO WS-NAME
     MOVE -0.34081938 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zrot" TO WS-NAME
     MOVE -0.031925949 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.y" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.zrot" TO WS-NAME
     MOVE -1.155685161 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.y" TO WS-NAME
     MOVE -5.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.zrot" TO WS-NAME
     MOVE -0.88327521 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "STRIDER_SADDLE" TO WS-LAYER
     CALL "EF7-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 5 TO WS-IV(1)
     MOVE 5 TO WS-IV(2)
     MOVE 2.5 TO WS-IV(3)
     MOVE 0.1 TO WS-IV(4)
     MOVE 12.5 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF7-STRIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 2.328223743 TO WS-E
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
     MOVE -0.022862453 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.y" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.zrot" TO WS-NAME
     MOVE 1.37634943 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.y" TO WS-NAME
     MOVE 7.618365687 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xrot" TO WS-NAME
     MOVE 0.190817156 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zrot" TO WS-NAME
     MOVE -0.005227846 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.zrot" TO WS-NAME
     MOVE 1.292778337 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.y" TO WS-NAME
     MOVE -6.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.zrot" TO WS-NAME
     MOVE 0.826005764 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.y" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.zrot" TO WS-NAME
     MOVE -1.06711157 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.y" TO WS-NAME
     MOVE 8.381634313 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xrot" TO WS-NAME
     MOVE -0.190817156 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zrot" TO WS-NAME
     MOVE 0.005227846 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.y" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.zrot" TO WS-NAME
     MOVE -0.976149663 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.y" TO WS-NAME
     MOVE -5.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.zrot" TO WS-NAME
     MOVE -0.919323496 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "STRIDER_SADDLE" TO WS-LAYER
     CALL "EF7-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF7-STRIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 2.0 TO WS-E
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
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.y" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.zrot" TO WS-NAME
     MOVE 1.2217305 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.y" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.zrot" TO WS-NAME
     MOVE 1.134464 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.y" TO WS-NAME
     MOVE -6.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.zrot" TO WS-NAME
     MOVE 0.87266463 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.y" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.zrot" TO WS-NAME
     MOVE -1.2217305 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.y" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.y" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.zrot" TO WS-NAME
     MOVE -1.134464 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.y" TO WS-NAME
     MOVE -5.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.zrot" TO WS-NAME
     MOVE -0.87266463 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "STRIDER_SADDLE" TO WS-LAYER
     CALL "EF7-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE -15 TO WS-IV(1)
     MOVE 30 TO WS-IV(2)
     MOVE 3.3 TO WS-IV(3)
     MOVE 0.9 TO WS-IV(4)
     MOVE 40.25 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF7-STRIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 1.764618557 TO WS-E
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
     MOVE -0.26179938 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.yrot" TO WS-NAME
     MOVE 0.52359876 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zrot" TO WS-NAME
     MOVE -0.097190307 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.y" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.zrot" TO WS-NAME
     MOVE 1.164335102 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.y" TO WS-NAME
     MOVE 7.381688365 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xrot" TO WS-NAME
     MOVE 0.309155818 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zrot" TO WS-NAME
     MOVE -0.034292796 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.zrot" TO WS-NAME
     MOVE 1.161934551 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.y" TO WS-NAME
     MOVE -6.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.zrot" TO WS-NAME
     MOVE 0.799150272 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.y" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.zrot" TO WS-NAME
     MOVE -1.279125898 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.y" TO WS-NAME
     MOVE 8.618311635 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xrot" TO WS-NAME
     MOVE -0.309155818 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zrot" TO WS-NAME
     MOVE 0.034292796 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.y" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.zrot" TO WS-NAME
     MOVE -1.106993449 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.y" TO WS-NAME
     MOVE -5.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.zrot" TO WS-NAME
     MOVE -0.946178988 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "STRIDER_SADDLE" TO WS-LAYER
     CALL "EF7-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 20 TO WS-IV(1)
     MOVE -40 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     MOVE 0.2 TO WS-IV(4)
     MOVE 6 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EF7-STRIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 2.380429542 TO WS-E
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
     MOVE -0.070375661 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.y" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.zrot" TO WS-NAME
     MOVE 1.311596942 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_bottom_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.y" TO WS-NAME
     MOVE 8.687147595 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xrot" TO WS-NAME
     MOVE -0.343573797 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zrot" TO WS-NAME
     MOVE 0.017875155 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.zrot" TO WS-NAME
     MOVE 1.341796771 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.x" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.y" TO WS-NAME
     MOVE -6.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.zrot" TO WS-NAME
     MOVE 0.997275379 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_top_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.y" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.zrot" TO WS-NAME
     MOVE -1.131864058 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_bottom_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_bottom_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.y" TO WS-NAME
     MOVE 7.312852405 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xrot" TO WS-NAME
     MOVE 0.343573797 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zrot" TO WS-NAME
     MOVE -0.017875155 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.y" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.zrot" TO WS-NAME
     MOVE -0.927131229 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.x" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.y" TO WS-NAME
     MOVE -5.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.zrot" TO WS-NAME
     MOVE -0.748053881 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_top_bristle" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_top_bristle.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "STRIDER_BABY" TO WS-LAYER
     CALL "EF7-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer STRIDER_BABY is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0.25 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     CALL "EF7-STRIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 16.75 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE SPACES TO WS-X120
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF7-STRIDER-TEXTURE" USING WS-IN WS-X120
     MOVE "4.1 texture suffocating 0 baby 0" TO WS-NAME
     MOVE "textures/entity/strider/strider.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE SPACES TO WS-X120
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF7-STRIDER-TEXTURE" USING WS-IN WS-X120
     MOVE "4.1 texture suffocating 0 baby 1" TO WS-NAME
     MOVE "textures/entity/strider/strider_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE SPACES TO WS-X120
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF7-STRIDER-TEXTURE" USING WS-IN WS-X120
     MOVE "4.1 texture suffocating 1 baby 0" TO WS-NAME
     MOVE "textures/entity/strider/strider_cold.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE SPACES TO WS-X120
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF7-STRIDER-TEXTURE" USING WS-IN WS-X120
     MOVE "4.1 texture suffocating 1 baby 1" TO WS-NAME
     MOVE "textures/entity/strider/strider_cold_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF7-STRIDER-SHADOW" USING WS-IN WS-OUT
     MOVE "4.1 shadow baby 0 scale 1" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF7-STRIDER-SHADOW" USING WS-IN WS-OUT
     MOVE "4.1 shadow baby 1 scale 1" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     CALL "EF7-STRIDER-SHADOW" USING WS-IN WS-OUT
     MOVE "4.1 shadow baby 0 scale 2" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 3 TO WS-IV(2)
     CALL "EF7-STRIDER-SHADOW" USING WS-IN WS-OUT
     MOVE "4.1 shadow baby 1 scale 3" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF7-STRIDER-SHAKING" USING WS-IN WS-OUT
     MOVE "4.1 shaking fully frozen 0 suffocating 0" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF7-STRIDER-SHAKING" USING WS-IN WS-OUT
     MOVE "4.1 shaking fully frozen 1 suffocating 0" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF7-STRIDER-SHAKING" USING WS-IN WS-OUT
     MOVE "4.1 shaking fully frozen 0 suffocating 1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF7-STRIDER-SHAKING" USING WS-IN WS-OUT
     MOVE "4.1 shaking fully frozen 1 suffocating 1" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF7-STRIDER-SADDLE" USING WS-IN WS-OUT
     MOVE "4.1 saddle layer equippable 1 asset id 1 baby 0" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF7-STRIDER-SADDLE" USING WS-IN WS-OUT
     MOVE "4.1 saddle layer equippable 0 asset id 1 baby 0" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF7-STRIDER-SADDLE" USING WS-IN WS-OUT
     MOVE "4.1 saddle layer equippable 1 asset id 0 baby 0" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF7-STRIDER-SADDLE" USING WS-IN WS-OUT
     MOVE "4.1 saddle layer equippable 1 asset id 1 baby 1" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE SPACES TO WS-X120
     MOVE 0 TO WS-IV(1)
     CALL "EF7-STRIDER-SADDLE-TEXTURE" USING WS-IN WS-X120
     MOVE "4.1 saddle texture" TO WS-NAME
     MOVE "textures/entity/equipment/strider_saddle/saddle.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-7§4 Strider: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-7§4 Strider: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-7-4.
