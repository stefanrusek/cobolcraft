*> Acceptance test of docs/protocol/34-entity-models-6-overworld-hostiles-arthropods-slimes.md section 6 (Spider and cave spider): 6.1 the one mesh and the cave spider layer through scaling 0.7, 6.2 setupAnim (head look and the four leg pairs with
*> their phases; worked example 15.8), 6.3 textures (one eyes texture for both), shadow radii and the eyes layer. Mesh rows are the table of the document.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-6-6.
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
     MOVE "SPIDER" TO WS-LAYER
     CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer SPIDER is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-6§6 Spider and cave spider 6.1 SPIDER" TO CK-PREFIX
     MOVE "P head root 0 15 -3 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 32 4 -4 -4 -8 8 8 8 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body0 root 0 15 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body0 0 0 -3 -3 -3 6 6 6 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body1 root 0 15 9 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body1 0 12 -5 -4 -6 10 8 12 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -4 15 2 0 0.7853982 -0.7853982" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 18 0 -15 -1 -1 16 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 4 15 2 0 -0.7853982 0.7853982" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 18 0 -1 -1 -1 16 2 2 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_middle_hind_leg root -4 15 1 0 0.3926991 -0.58119464" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_middle_hind_leg 18 0 -15 -1 -1 16 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_middle_hind_leg root 4 15 1 0 -0.3926991 0.58119464" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_middle_hind_leg 18 0 -1 -1 -1 16 2 2 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_middle_front_leg root -4 15 0 0 -0.3926991 -0.58119464" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_middle_front_leg 18 0 -15 -1 -1 16 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_middle_front_leg root 4 15 0 0 0.3926991 0.58119464" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_middle_front_leg 18 0 -1 -1 -1 16 2 2 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -4 15 -1 0 -0.7853982 -0.7853982" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 18 0 -15 -1 -1 16 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 4 15 -1 0 0.7853982 0.7853982" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 18 0 -1 -1 -1 16 2 2 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "6.1 SPIDER: parts below the root" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "6.1 SPIDER: cuboids" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "6.1 SPIDER: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "6.1 SPIDER: texture height" TO WS-NAME
     MOVE 32.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "CAVE_SPIDER" TO WS-LAYER
     CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer CAVE_SPIDER is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-6§6 Spider and cave spider 6.1 CAVE_SPIDER" TO CK-PREFIX
     MOVE "P head root 0.0 17.7048 -2.1 0 0 0 0.7 0.7 0.7" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 32 4 -4 -4 -8 8 8 8 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body0 root 0.0 17.7048 0.0 0 0 0 0.7 0.7 0.7" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body0 0 0 -3 -3 -3 6 6 6 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body1 root 0.0 17.7048 6.3 0 0 0 0.7 0.7 0.7" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body1 0 12 -5 -4 -6 10 8 12 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -2.8 17.7048 1.4 0 0.7853982 -0.7853982 0.7 0.7 0.7" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 18 0 -15 -1 -1 16 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 2.8 17.7048 1.4 0 -0.7853982 0.7853982 0.7 0.7 0.7" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 18 0 -1 -1 -1 16 2 2 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_middle_hind_leg root -2.8 17.7048 0.7 0 0.3926991 -0.58119464 0.7 0.7 0.7" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_middle_hind_leg 18 0 -15 -1 -1 16 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_middle_hind_leg root 2.8 17.7048 0.7 0 -0.3926991 0.58119464 0.7 0.7 0.7" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_middle_hind_leg 18 0 -1 -1 -1 16 2 2 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_middle_front_leg root -2.8 17.7048 0.0 0 -0.3926991 -0.58119464 0.7 0.7 0.7" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_middle_front_leg 18 0 -15 -1 -1 16 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_middle_front_leg root 2.8 17.7048 0.0 0 0.3926991 0.58119464 0.7 0.7 0.7" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_middle_front_leg 18 0 -1 -1 -1 16 2 2 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -2.8 17.7048 -0.7 0 -0.7853982 -0.7853982 0.7 0.7 0.7" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 18 0 -15 -1 -1 16 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 2.8 17.7048 -0.7 0 0.7853982 0.7853982 0.7 0.7 0.7" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 18 0 -1 -1 -1 16 2 2 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "6.1 CAVE_SPIDER: parts below the root" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "6.1 CAVE_SPIDER: cuboids" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "6.1 CAVE_SPIDER: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "6.1 CAVE_SPIDER: texture height" TO WS-NAME
     MOVE 32.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "SPIDER" TO WS-LAYER
     CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 10 TO WS-IV(1)
     MOVE -20 TO WS-IV(2)
     MOVE 1.0 TO WS-IV(3)
     MOVE 1.0 TO WS-IV(4)
     CALL "EF6-SPIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
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
     MOVE 15.0 TO WS-E
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
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
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
     MOVE -1.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 1.174085371 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0.470927906 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
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
     MOVE 2.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE -0.690940355 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE 0.538197005 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.yrot" TO WS-NAME
     MOVE 0.004011924 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.zrot" TO WS-NAME
     MOVE 0.266724359 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.z" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.yrot" TO WS-NAME
     MOVE -0.487156927 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.zrot" TO WS-NAME
     MOVE 0.33399343 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
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
     MOVE -1.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE -1.174085371 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE -0.470927906 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
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
     MOVE 2.0 TO WS-E
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
     MOVE 0.690940355 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE -0.538197005 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.yrot" TO WS-NAME
     MOVE -0.004011924 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.zrot" TO WS-NAME
     MOVE -0.266724359 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.z" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.yrot" TO WS-NAME
     MOVE 0.487156927 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.zrot" TO WS-NAME
     MOVE -0.33399343 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SPIDER" TO WS-LAYER
     CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF6-SPIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
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
     MOVE 15.0 TO WS-E
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
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
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
     MOVE -1.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.7853982 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0.7853982 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
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
     MOVE 2.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE -0.7853982 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE 0.7853982 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.yrot" TO WS-NAME
     MOVE 0.3926991 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.zrot" TO WS-NAME
     MOVE 0.58119464 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.z" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.yrot" TO WS-NAME
     MOVE -0.3926991 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.zrot" TO WS-NAME
     MOVE 0.58119464 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
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
     MOVE -1.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE -0.7853982 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE -0.7853982 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
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
     MOVE 2.0 TO WS-E
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
     MOVE 0.7853982 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE -0.7853982 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.yrot" TO WS-NAME
     MOVE -0.3926991 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.zrot" TO WS-NAME
     MOVE -0.58119464 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.z" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.yrot" TO WS-NAME
     MOVE 0.3926991 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.zrot" TO WS-NAME
     MOVE -0.58119464 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SPIDER" TO WS-LAYER
     CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE -15 TO WS-IV(1)
     MOVE 40 TO WS-IV(2)
     MOVE 3.5 TO WS-IV(3)
     MOVE 0.4 TO WS-IV(4)
     CALL "EF6-SPIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
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
     MOVE 15.0 TO WS-E
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
     MOVE -0.26179938 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.69813168 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
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
     MOVE -1.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.625590155 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0.675066009 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
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
     MOVE 2.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE -0.793233302 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE 0.669524095 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.yrot" TO WS-NAME
     MOVE 0.552507145 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.zrot" TO WS-NAME
     MOVE 0.470862443 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.z" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.yrot" TO WS-NAME
     MOVE -0.384864005 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.zrot" TO WS-NAME
     MOVE 0.46532054 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
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
     MOVE -1.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE -0.625590155 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE -0.675066009 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
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
     MOVE 2.0 TO WS-E
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
     MOVE 0.793233302 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE -0.669524095 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.yrot" TO WS-NAME
     MOVE -0.552507145 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.zrot" TO WS-NAME
     MOVE -0.470862443 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.z" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.yrot" TO WS-NAME
     MOVE 0.384864005 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.zrot" TO WS-NAME
     MOVE -0.46532054 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SPIDER" TO WS-LAYER
     CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 25 TO WS-IV(1)
     MOVE -90 TO WS-IV(2)
     MOVE 7.25 TO WS-IV(3)
     MOVE 0.9 TO WS-IV(4)
     CALL "EF6-SPIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.z" TO WS-NAME
     MOVE 9.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
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
     MOVE 15.0 TO WS-E
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
     MOVE 0.4363323 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE -1.57079628 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
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
     MOVE -1.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.701531992 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0.743173644 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
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
     MOVE 2.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE -1.135493131 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE 0.427883043 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.yrot" TO WS-NAME
     MOVE 0.476565326 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.zrot" TO WS-NAME
     MOVE 0.538970065 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.x" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.z" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.yrot" TO WS-NAME
     MOVE -0.042604173 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.zrot" TO WS-NAME
     MOVE 0.223679485 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
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
     MOVE -1.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE -0.701531992 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE -0.743173644 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
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
     MOVE 2.0 TO WS-E
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
     MOVE 1.135493131 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE -0.427883043 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.yrot" TO WS-NAME
     MOVE -0.476565326 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.zrot" TO WS-NAME
     MOVE -0.538970065 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.x" TO WS-NAME
     MOVE -4.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.y" TO WS-NAME
     MOVE 15.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.z" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.yrot" TO WS-NAME
     MOVE 0.042604173 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.zrot" TO WS-NAME
     MOVE -0.223679485 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "CAVE_SPIDER" TO WS-LAYER
     CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 10 TO WS-IV(1)
     MOVE -20 TO WS-IV(2)
     MOVE 1.0 TO WS-IV(3)
     MOVE 1.0 TO WS-IV(4)
     CALL "EF6-SPIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.z" TO WS-NAME
     MOVE 6.3 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
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
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -2.1 TO WS-E
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
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -0.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 1.174085371 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0.470927906 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 1.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE -0.690940355 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE 0.538197005 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.x" TO WS-NAME
     MOVE 2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.yrot" TO WS-NAME
     MOVE 0.004011924 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.zrot" TO WS-NAME
     MOVE 0.266724359 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.x" TO WS-NAME
     MOVE 2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.z" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.yrot" TO WS-NAME
     MOVE -0.487156927 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.zrot" TO WS-NAME
     MOVE 0.33399343 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -0.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE -1.174085371 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE -0.470927906 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 1.4 TO WS-E
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
     MOVE 0.690940355 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE -0.538197005 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.x" TO WS-NAME
     MOVE -2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.yrot" TO WS-NAME
     MOVE -0.004011924 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.zrot" TO WS-NAME
     MOVE -0.266724359 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.x" TO WS-NAME
     MOVE -2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.z" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.yrot" TO WS-NAME
     MOVE 0.487156927 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.zrot" TO WS-NAME
     MOVE -0.33399343 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "CAVE_SPIDER" TO WS-LAYER
     CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF6-SPIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.z" TO WS-NAME
     MOVE 6.3 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
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
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -2.1 TO WS-E
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
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -0.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.7853982 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0.7853982 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 1.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE -0.7853982 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE 0.7853982 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.x" TO WS-NAME
     MOVE 2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.yrot" TO WS-NAME
     MOVE 0.3926991 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.zrot" TO WS-NAME
     MOVE 0.58119464 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.x" TO WS-NAME
     MOVE 2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.z" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.yrot" TO WS-NAME
     MOVE -0.3926991 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.zrot" TO WS-NAME
     MOVE 0.58119464 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -0.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE -0.7853982 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE -0.7853982 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 1.4 TO WS-E
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
     MOVE 0.7853982 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE -0.7853982 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.x" TO WS-NAME
     MOVE -2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.yrot" TO WS-NAME
     MOVE -0.3926991 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.zrot" TO WS-NAME
     MOVE -0.58119464 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.x" TO WS-NAME
     MOVE -2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.z" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.yrot" TO WS-NAME
     MOVE 0.3926991 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.zrot" TO WS-NAME
     MOVE -0.58119464 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "CAVE_SPIDER" TO WS-LAYER
     CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE -15 TO WS-IV(1)
     MOVE 40 TO WS-IV(2)
     MOVE 3.5 TO WS-IV(3)
     MOVE 0.4 TO WS-IV(4)
     CALL "EF6-SPIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.z" TO WS-NAME
     MOVE 6.3 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
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
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -2.1 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE -0.26179938 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.69813168 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -0.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.625590155 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0.675066009 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 1.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE -0.793233302 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE 0.669524095 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.x" TO WS-NAME
     MOVE 2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.yrot" TO WS-NAME
     MOVE 0.552507145 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.zrot" TO WS-NAME
     MOVE 0.470862443 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.x" TO WS-NAME
     MOVE 2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.z" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.yrot" TO WS-NAME
     MOVE -0.384864005 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.zrot" TO WS-NAME
     MOVE 0.46532054 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -0.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE -0.625590155 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE -0.675066009 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 1.4 TO WS-E
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
     MOVE 0.793233302 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE -0.669524095 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.x" TO WS-NAME
     MOVE -2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.yrot" TO WS-NAME
     MOVE -0.552507145 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.zrot" TO WS-NAME
     MOVE -0.470862443 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.x" TO WS-NAME
     MOVE -2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.z" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.yrot" TO WS-NAME
     MOVE 0.384864005 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.zrot" TO WS-NAME
     MOVE -0.46532054 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "CAVE_SPIDER" TO WS-LAYER
     CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 25 TO WS-IV(1)
     MOVE -90 TO WS-IV(2)
     MOVE 7.25 TO WS-IV(3)
     MOVE 0.9 TO WS-IV(4)
     CALL "EF6-SPIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body0" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body0.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.z" TO WS-NAME
     MOVE 6.3 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body1" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body1.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
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
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -2.1 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 0.4363323 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE -1.57079628 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.x" TO WS-NAME
     MOVE 2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.z" TO WS-NAME
     MOVE -0.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.yrot" TO WS-NAME
     MOVE 0.701531992 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zrot" TO WS-NAME
     MOVE 0.743173644 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.x" TO WS-NAME
     MOVE 2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.z" TO WS-NAME
     MOVE 1.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE -1.135493131 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zrot" TO WS-NAME
     MOVE 0.427883043 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.x" TO WS-NAME
     MOVE 2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.yrot" TO WS-NAME
     MOVE 0.476565326 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.zrot" TO WS-NAME
     MOVE 0.538970065 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_front_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.x" TO WS-NAME
     MOVE 2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.z" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.yrot" TO WS-NAME
     MOVE -0.042604173 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.zrot" TO WS-NAME
     MOVE 0.223679485 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_middle_hind_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.x" TO WS-NAME
     MOVE -2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.z" TO WS-NAME
     MOVE -0.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE -0.701531992 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE -0.743173644 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.x" TO WS-NAME
     MOVE -2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.z" TO WS-NAME
     MOVE 1.4 TO WS-E
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
     MOVE 1.135493131 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zrot" TO WS-NAME
     MOVE -0.427883043 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.x" TO WS-NAME
     MOVE -2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.yrot" TO WS-NAME
     MOVE -0.476565326 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.zrot" TO WS-NAME
     MOVE -0.538970065 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_front_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.x" TO WS-NAME
     MOVE -2.8 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.y" TO WS-NAME
     MOVE 17.7048 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.z" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.yrot" TO WS-NAME
     MOVE 0.042604173 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.zrot" TO WS-NAME
     MOVE -0.223679485 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.xs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.ys" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_middle_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_middle_hind_leg.zs" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SPIDER" TO WS-LAYER
     CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer SPIDER is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF6-SPIDER-ANIM" USING EMM-MODEL WS-IN
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.yrot" TO WS-NAME
     MOVE 0.6909382 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.yrot" TO WS-NAME
     MOVE -0.6909382 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.yrot" TO WS-NAME
     MOVE -1.1740882 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.zrot" TO WS-NAME
     MOVE -0.4709282 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE SPACES TO WS-X120
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF6-SPIDER-TEXTURE" USING WS-IN WS-X120
     MOVE "6.3 texture cave 0" TO WS-NAME
     MOVE "textures/entity/spider/spider.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE SPACES TO WS-X120
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF6-SPIDER-TEXTURE" USING WS-IN WS-X120
     MOVE "6.3 texture cave 1" TO WS-NAME
     MOVE "textures/entity/spider/cave_spider.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE SPACES TO WS-X120
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF6-SPIDER-TEXTURE" USING WS-IN WS-X120
     MOVE "6.3 eyes texture of the spider" TO WS-NAME
     MOVE "textures/entity/spider/spider_eyes.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE SPACES TO WS-X120
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF6-SPIDER-TEXTURE" USING WS-IN WS-X120
     MOVE "6.3 eyes texture of the cave spider (the same file)" TO WS-NAME
     MOVE "textures/entity/spider/spider_eyes.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-6§6 Spider and cave spider: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-6§6 Spider and cave spider: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-6-6.
