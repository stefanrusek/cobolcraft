*> Acceptance test of docs/protocol/34-entity-models-3-villagers-illagers-golems-misc.md section 3 (Witch): 3.1 the mesh (64 x 128, the villager parts kept by the merge rule, scaled
*> 0.9375), the feet and head heights of section 13, 3.2 setupAnim with its worked example, 3.3 the renderer table and the item layer transform. Mesh rows are the table of the document;
*> formula values were worked by an independent script.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-3-3.
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
     MOVE "WITCH" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer WITCH is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-3§3 Witch 3.1" TO CK-PREFIX
     MOVE "P head root 0.0 1.501 0.0 0 0 0 0.9375 0.9375 0.9375" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -4 -10 -4 8 10 8 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat head -5 -10.03125 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C hat 0 64 0 0 0 10 2 10 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat_rim hat 0 0 0 -1.5707964 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C hat_rim 30 47 -8 -8 -6 16 16 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat2 hat 1.75 -4 2 -0.05235988 0 0.02617994" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C hat2 0 76 0 0 0 7 4 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat3 hat2 1.75 -4 2 -0.10471976 0 0.05235988" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C hat3 0 87 0 0 0 4 4 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat4 hat3 1.75 -2 2 -0.20943952 0 0.10471976" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C hat4 0 95 0 0 0 1 2 1 0.25 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P nose head 0 -2 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C nose 24 0 -1 -1 -6 2 4 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P mole nose 0 -2 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C mole 0 0 0 3 -6.75 1 1 1 -0.25 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0.0 1.501 0.0 0 0 0 0.9375 0.9375 0.9375" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 16 20 -4 0 -3 8 12 6 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P jacket body 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C jacket 0 38 -4 0 -3 8 20 6 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P arms root 0.0 4.3135 -0.9375 -0.75 0 0 0.9375 0.9375 0.9375" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C arms 44 22 -8 -2 -2 4 8 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C arms 44 22 4 -2 -2 4 8 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C arms 40 38 -4 2 -2 8 4 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_leg root -1.875 12.751 0.0 0 0 0 0.9375 0.9375 0.9375" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_leg 0 22 -2 0 -2 4 12 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_leg root 1.875 12.751 0.0 0 0 0 0.9375 0.9375 0.9375" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_leg 0 22 -2 0 -2 4 12 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "3.1 witch: parts below the root" TO WS-NAME
     MOVE 13 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 witch: cuboids" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 witch: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 witch: texture height" TO WS-NAME
     MOVE 128 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE 1 TO WS-IV(1)
     MOVE 24 TO WS-IV(2)
     CALL "EM3-ENTITY-Y" USING WS-IN WS-OUT
     MOVE "13.1 witch feet" TO WS-NAME
     MOVE 0.0009375 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE -10 TO WS-IV(2)
     CALL "EM3-ENTITY-Y" USING WS-IN WS-OUT
     MOVE "13.1 witch head top" TO WS-NAME
     MOVE 1.993125 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "WITCH" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 10 TO WS-IV(1)
     MOVE -20 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 10 TO WS-IV(5)
     MOVE 7 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EM3-WITCH-ANIM" USING EMM-MODEL WS-IN
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
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xrot" TO WS-NAME
     MOVE -0.145205694 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xrot" TO WS-NAME
     MOVE 0.145205694 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "nose" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "nose.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "nose" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "nose.xrot" TO WS-NAME
     MOVE 0.050596737 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "nose" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "nose.zrot" TO WS-NAME
     MOVE 0.033372535 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "WITCH" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EM3-WITCH-ANIM" USING EMM-MODEL WS-IN
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
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "nose" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "nose.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "nose" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "nose.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "nose" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "nose.zrot" TO WS-NAME
     MOVE 0.04363323 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "WITCH" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE -15 TO WS-IV(1)
     MOVE 30 TO WS-IV(2)
     MOVE 6.6 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 22.5 TO WS-IV(5)
     MOVE 13 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     CALL "EM3-WITCH-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE -0.26179938 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.52359876 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xrot" TO WS-NAME
     MOVE -0.217183639 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xrot" TO WS-NAME
     MOVE 0.217183639 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "nose" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "nose.x" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CX(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "nose" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "nose.y" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "nose" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "nose.z" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "nose" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "nose.xrot" TO WS-NAME
     MOVE -0.9 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "nose" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "nose.zrot" TO WS-NAME
     MOVE 0.034064766 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "WITCH" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 5 TO WS-IV(1)
     MOVE 5 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0.2 TO WS-IV(4)
     MOVE 40 TO WS-IV(5)
     MOVE 19 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     CALL "EM3-WITCH-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 0.08726646 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.08726646 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xrot" TO WS-NAME
     MOVE 0.110064605 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xrot" TO WS-NAME
     MOVE -0.110064605 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "nose" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "nose.y" TO WS-NAME
     MOVE -2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "nose" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "nose.xrot" TO WS-NAME
     MOVE -0.034755473 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "nose" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "nose.zrot" TO WS-NAME
     MOVE -0.039128466 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "nose" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "nose.xs" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-CXSCALE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     CALL "EM3-WITCH-RENDERER" USING WS-OUT
     MOVE "3.3 renderer [shadow, custom head layer] 0" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.3 renderer [shadow, custom head layer] 1" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     CALL "EM3-WITCH-TEXTURE" USING WS-TEXT
     MOVE "3.3 texture" TO WS-NAME
     MOVE "textures/entity/witch/witch.png" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 0 TO WS-IV(1)
     CALL "EM3-WITCH-ITEM-OPS" USING WS-IN WS-OUT
     MOVE "3.3 other item: the crossed-arms transform of 1.4 (operation count 4)" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.3 other item: the crossed-arms scale" TO WS-NAME
     MOVE 1.07 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EM3-WITCH-ITEM-OPS" USING WS-IN WS-OUT
     MOVE "3.3 potion transform: operation count" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.3 potion transform: operation 1 value 0" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.3 potion transform: operation 1 value 1" TO WS-NAME
     MOVE 0.0625 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.3 potion transform: operation 1 value 2" TO WS-NAME
     MOVE 0.25 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.3 potion transform: operation 1 value 3" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.3 potion transform: operation 2 value 0" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.3 potion transform: operation 2 value 1" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.3 potion transform: operation 2 value 2" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.3 potion transform: operation 2 value 3" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.3 potion transform: operation 3 value 0" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.3 potion transform: operation 3 value 1" TO WS-NAME
     MOVE 140 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.3 potion transform: operation 3 value 2" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.3 potion transform: operation 3 value 3" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.3 potion transform: operation 4 value 0" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.3 potion transform: operation 4 value 1" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.3 potion transform: operation 4 value 2" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.3 potion transform: operation 4 value 3" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.3 potion transform: operation 5 value 0" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.3 potion transform: operation 5 value 1" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.3 potion transform: operation 5 value 2" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.3 potion transform: operation 5 value 3" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-3§3 Witch: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-3§3 Witch: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-3-3.
