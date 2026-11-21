*> Acceptance test of docs/protocol/34-entity-models-6-overworld-hostiles-arthropods-slimes.md section 10 (Phantom): 10.1 the mesh (the mirrored right wing), 10.2 setupAnim (wing flap and tail from the flap time; example 15.5), 10.3 the flap time,
*> the size scale and translate, the pitch rotation and the eyes layer texture.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-6-10.
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
     MOVE "PHANTOM" TO WS-LAYER
     CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer PHANTOM is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-6§10 Phantom 10.1 PHANTOM" TO CK-PREFIX
     MOVE "P body root 0 0 0 -0.1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 8 -3 -2 -8 5 3 9 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P tail_base body 0 -2 1 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C tail_base 3 20 -2 0 0 3 2 6 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P tail_tip tail_base 0 0.5 6 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C tail_tip 4 29 -1 0 0 1 1 6 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_wing_base body 2 -2 -8 0 0 0.1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_wing_base 23 12 0 0 0 6 2 9 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_wing_tip left_wing_base 6 0 0 0 0 0.1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_wing_tip 16 24 0 0 0 13 1 9 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_wing_base body -3 -2 -8 0 0 -0.1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_wing_base 23 12 -6 0 0 6 2 9 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_wing_tip right_wing_base -6 0 0 0 0 -0.1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_wing_tip 16 24 -13 0 0 13 1 9 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head body 0 1 -7 0.2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -4 -2 -5 7 3 5 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "10.1 PHANTOM: parts below the root" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.1 PHANTOM: cuboids" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.1 PHANTOM: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.1 PHANTOM: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "PHANTOM" TO WS-LAYER
     CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     CALL "EF6-PHANTOM-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 0.0 TO WS-E
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
     MOVE -0.1 TO WS-E
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
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -7.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 0.2 TO WS-E
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
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.x" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.zrot" TO WS-NAME
     MOVE 0.279252672 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.x" TO WS-NAME
     MOVE 6.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.y" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.zrot" TO WS-NAME
     MOVE 0.279252672 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.zrot" TO WS-NAME
     MOVE -0.279252672 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.x" TO WS-NAME
     MOVE -6.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.y" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.zrot" TO WS-NAME
     MOVE -0.279252672 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.z" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.xrot" TO WS-NAME
     MOVE -0.17453292 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.y" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.z" TO WS-NAME
     MOVE 6.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.xrot" TO WS-NAME
     MOVE -0.17453292 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PHANTOM" TO WS-LAYER
     CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 3 TO WS-IV(1)
     CALL "EF6-PHANTOM-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 0.0 TO WS-E
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
     MOVE -0.1 TO WS-E
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
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -7.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 0.2 TO WS-E
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
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.x" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.zrot" TO WS-NAME
     MOVE 0.258283329 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.x" TO WS-NAME
     MOVE 6.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.y" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.zrot" TO WS-NAME
     MOVE 0.258283329 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.zrot" TO WS-NAME
     MOVE -0.258283329 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.x" TO WS-NAME
     MOVE -6.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.y" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.zrot" TO WS-NAME
     MOVE -0.258283329 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.z" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.xrot" TO WS-NAME
     MOVE -0.149305371 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.y" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.z" TO WS-NAME
     MOVE 6.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.xrot" TO WS-NAME
     MOVE -0.149305371 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PHANTOM" TO WS-LAYER
     CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 10.5 TO WS-IV(1)
     CALL "EF6-PHANTOM-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 0.0 TO WS-E
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
     MOVE -0.1 TO WS-E
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
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -7.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 0.2 TO WS-E
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
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.x" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.zrot" TO WS-NAME
     MOVE 0.057064403 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.x" TO WS-NAME
     MOVE 6.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.y" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.zrot" TO WS-NAME
     MOVE 0.057064403 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.zrot" TO WS-NAME
     MOVE -0.057064403 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.x" TO WS-NAME
     MOVE -6.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.y" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.zrot" TO WS-NAME
     MOVE -0.057064403 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.z" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.xrot" TO WS-NAME
     MOVE -0.007288082 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.y" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.z" TO WS-NAME
     MOVE 6.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.xrot" TO WS-NAME
     MOVE -0.007288082 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PHANTOM" TO WS-LAYER
     CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 47.25 TO WS-IV(1)
     CALL "EF6-PHANTOM-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 0.0 TO WS-E
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
     MOVE -0.1 TO WS-E
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
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -7.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 0.2 TO WS-E
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
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.x" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.zrot" TO WS-NAME
     MOVE 0.276493675 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.x" TO WS-NAME
     MOVE 6.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.y" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.zrot" TO WS-NAME
     MOVE 0.276493675 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.zrot" TO WS-NAME
     MOVE -0.276493675 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.x" TO WS-NAME
     MOVE -6.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.y" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.zrot" TO WS-NAME
     MOVE -0.276493675 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.z" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.xrot" TO WS-NAME
     MOVE -0.17110121 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.y" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.z" TO WS-NAME
     MOVE 6.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.xrot" TO WS-NAME
     MOVE -0.17110121 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PHANTOM" TO WS-LAYER
     CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 120 TO WS-IV(1)
     CALL "EF6-PHANTOM-ANIM" USING EMM-MODEL WS-IN
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "body.y" TO WS-NAME
     MOVE 0.0 TO WS-E
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
     MOVE -0.1 TO WS-E
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
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.y" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.z" TO WS-NAME
     MOVE -7.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 0.2 TO WS-E
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
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.x" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.zrot" TO WS-NAME
     MOVE -0.277626723 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.x" TO WS-NAME
     MOVE 6.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.y" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.zrot" TO WS-NAME
     MOVE -0.277626723 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_tip.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.x" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.z" TO WS-NAME
     MOVE -8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.zrot" TO WS-NAME
     MOVE 0.277626723 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_base.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.x" TO WS-NAME
     MOVE -6.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.y" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.z" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.zrot" TO WS-NAME
     MOVE 0.277626723 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_wing_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_wing_tip.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.z" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.xrot" TO WS-NAME
     MOVE -0.172506401 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.x" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.y" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.z" TO WS-NAME
     MOVE 6.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.xrot" TO WS-NAME
     MOVE -0.172506401 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.ys" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CYSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_tip" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_tip.zs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CZSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PHANTOM" TO WS-LAYER
     CALL "EF6-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO WS-IV(1)
     CALL "EF6-PHANTOM-ANIM" USING EMM-MODEL WS-IN
     MOVE "left_wing_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_wing_base.zrot" TO WS-NAME
     MOVE 0.25828 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail_base" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "tail_base.xrot" TO WS-NAME
     MOVE -0.14931 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF6-PHANTOM-FLAP" USING WS-IN WS-OUT
     MOVE "10.3 flap time network id 0 age 0" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     MOVE 12.5 TO WS-IV(2)
     CALL "EF6-PHANTOM-FLAP" USING WS-IN WS-OUT
     MOVE "10.3 flap time network id 7 age 12.5" TO WS-NAME
     MOVE 33.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 100 TO WS-IV(1)
     MOVE 3.25 TO WS-IV(2)
     CALL "EF6-PHANTOM-FLAP" USING WS-IN WS-OUT
     MOVE "10.3 flap time network id 100 age 3.25" TO WS-NAME
     MOVE 303.25 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF6-PHANTOM-SCALE-OPS" USING WS-IN WS-OUT
     MOVE "10.3 scale and translate for size 0 (count; code 2 scale, 1 translate; values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 0 (count; code 2 scale, 1 translate; values) [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 0 (count; code 2 scale, 1 translate; values) [3]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 0 (count; code 2 scale, 1 translate; values) [4]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 0 (count; code 2 scale, 1 translate; values) [5]" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 0 (count; code 2 scale, 1 translate; values) [6]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 0 (count; code 2 scale, 1 translate; values) [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 0 (count; code 2 scale, 1 translate; values) [8]" TO WS-NAME
     MOVE 1.3125 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 0 (count; code 2 scale, 1 translate; values) [9]" TO WS-NAME
     MOVE 0.1875 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF6-PHANTOM-SCALE-OPS" USING WS-IN WS-OUT
     MOVE "10.3 scale and translate for size 1 (count; code 2 scale, 1 translate; values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 1 (count; code 2 scale, 1 translate; values) [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 1 (count; code 2 scale, 1 translate; values) [3]" TO WS-NAME
     MOVE 1.15 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 1 (count; code 2 scale, 1 translate; values) [4]" TO WS-NAME
     MOVE 1.15 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 1 (count; code 2 scale, 1 translate; values) [5]" TO WS-NAME
     MOVE 1.15 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 1 (count; code 2 scale, 1 translate; values) [6]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 1 (count; code 2 scale, 1 translate; values) [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 1 (count; code 2 scale, 1 translate; values) [8]" TO WS-NAME
     MOVE 1.3125 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 1 (count; code 2 scale, 1 translate; values) [9]" TO WS-NAME
     MOVE 0.1875 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     CALL "EF6-PHANTOM-SCALE-OPS" USING WS-IN WS-OUT
     MOVE "10.3 scale and translate for size 3 (count; code 2 scale, 1 translate; values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 3 (count; code 2 scale, 1 translate; values) [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 3 (count; code 2 scale, 1 translate; values) [3]" TO WS-NAME
     MOVE 1.45 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 3 (count; code 2 scale, 1 translate; values) [4]" TO WS-NAME
     MOVE 1.45 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 3 (count; code 2 scale, 1 translate; values) [5]" TO WS-NAME
     MOVE 1.45 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 3 (count; code 2 scale, 1 translate; values) [6]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 3 (count; code 2 scale, 1 translate; values) [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 3 (count; code 2 scale, 1 translate; values) [8]" TO WS-NAME
     MOVE 1.3125 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 3 (count; code 2 scale, 1 translate; values) [9]" TO WS-NAME
     MOVE 0.1875 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10 TO WS-IV(1)
     CALL "EF6-PHANTOM-SCALE-OPS" USING WS-IN WS-OUT
     MOVE "10.3 scale and translate for size 10 (count; code 2 scale, 1 translate; values) [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 10 (count; code 2 scale, 1 translate; values) [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 10 (count; code 2 scale, 1 translate; values) [3]" TO WS-NAME
     MOVE 2.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 10 (count; code 2 scale, 1 translate; values) [4]" TO WS-NAME
     MOVE 2.5 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 10 (count; code 2 scale, 1 translate; values) [5]" TO WS-NAME
     MOVE 2.5 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 10 (count; code 2 scale, 1 translate; values) [6]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 10 (count; code 2 scale, 1 translate; values) [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 10 (count; code 2 scale, 1 translate; values) [8]" TO WS-NAME
     MOVE 1.3125 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 scale and translate for size 10 (count; code 2 scale, 1 translate; values) [9]" TO WS-NAME
     MOVE 0.1875 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF6-PHANTOM-ROT-OPS" USING WS-IN WS-OUT
     MOVE "10.3 pitch rotation x rot 0 (count; code 6 rotate X degrees) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 pitch rotation x rot 0 (count; code 6 rotate X degrees) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 pitch rotation x rot 0 (count; code 6 rotate X degrees) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 pitch rotation x rot 0 (count; code 6 rotate X degrees) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 pitch rotation x rot 0 (count; code 6 rotate X degrees) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE 30 TO WS-IV(1)
     CALL "EF6-PHANTOM-ROT-OPS" USING WS-IN WS-OUT
     MOVE "10.3 pitch rotation x rot 30 (count; code 6 rotate X degrees) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 pitch rotation x rot 30 (count; code 6 rotate X degrees) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 pitch rotation x rot 30 (count; code 6 rotate X degrees) [3]" TO WS-NAME
     MOVE 30 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 pitch rotation x rot 30 (count; code 6 rotate X degrees) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 pitch rotation x rot 30 (count; code 6 rotate X degrees) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE -45.5 TO WS-IV(1)
     CALL "EF6-PHANTOM-ROT-OPS" USING WS-IN WS-OUT
     MOVE "10.3 pitch rotation x rot -45.5 (count; code 6 rotate X degrees) [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 pitch rotation x rot -45.5 (count; code 6 rotate X degrees) [2]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 pitch rotation x rot -45.5 (count; code 6 rotate X degrees) [3]" TO WS-NAME
     MOVE -45.5 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 pitch rotation x rot -45.5 (count; code 6 rotate X degrees) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "10.3 pitch rotation x rot -45.5 (count; code 6 rotate X degrees) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE SPACES TO WS-X120
     MOVE 0 TO WS-IV(1)
     CALL "EF6-PHANTOM-TEXTURE" USING WS-IN WS-X120
     MOVE "10.3 texture" TO WS-NAME
     MOVE "textures/entity/phantom/phantom.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE SPACES TO WS-X120
     MOVE 1 TO WS-IV(1)
     CALL "EF6-PHANTOM-TEXTURE" USING WS-IN WS-X120
     MOVE "10.3 eyes texture" TO WS-NAME
     MOVE "textures/entity/phantom/phantom_eyes.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-6§10 Phantom: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-6§10 Phantom: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-6-10.
