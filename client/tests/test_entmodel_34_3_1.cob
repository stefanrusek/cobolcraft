*> Acceptance test of docs/protocol/34-entity-models-3-villagers-illagers-golems-misc.md section 1 (Villager, baby villager and wandering trader): 1.1 the adult mesh
*> and its no-hat variant, 1.2 the baby mesh, 1.3 setupAnim, 1.4 renderer constants, shadow and textures, the crossed-arms item transform, 1.5 the profession layer's texture names, hat
*> metadata and overlay choice, 1.6 the wandering trader, and the worked examples 1 and 2 of section 13. Mesh rows are the tables of the document; expected values of the formulas
*> were worked by an independent script.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-3-1.
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
 01 WS-PN                 PIC X(24).
 COPY EMCHKW.
 01 WS-TEXT               PIC X(100).
 01 WS-KEY                PIC X(40).
 01 WS-POINT.
    05 WS-PV                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-CHAIN.
    05 WS-CV                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-ARG                PIC X(24).
 01 WS-FLAG               BINARY-LONG.
 01 WS-LEVEL              BINARY-LONG.
 01 WS-BABY               BINARY-LONG.
 01 WS-FOLDER             PIC X(24).
 PROCEDURE DIVISION.
     MOVE "VILLAGER" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer VILLAGER is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-3§1 Villager, baby villager and wandering trader 1.1 adult" TO CK-PREFIX
     MOVE "P head root 0.0 1.501 0.0 0 0 0 0.9375 0.9375 0.9375" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -4 -10 -4 8 10 8 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C hat 32 0 -4 -10 -4 8 10 8 0.51 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat_rim hat 0 0 0 -1.5707964 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C hat_rim 30 47 -8 -8 -6 16 16 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P nose head 0 -2 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C nose 24 0 -1 -1 -6 2 4 2 0 0" TO CK-ROW
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
     MOVE "1.1 adult villager: parts below the root" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 adult villager: cuboids" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 adult villager: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 adult villager: texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "VILLAGER_NO_HAT" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer VILLAGER_NO_HAT is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-3§1 Villager, baby villager and wandering trader 1.1 no hat" TO CK-PREFIX
     MOVE "P head root 0.0 1.501 0.0 0 0 0 0.9375 0.9375 0.9375" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat_rim hat 0 0 0 -1.5707964 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P nose head 0 -2 0 0 0 0" TO CK-ROW
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
     MOVE "1.1 no-hat villager has no head cuboid: parts below the root" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 no-hat villager has no head cuboid: cuboids" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 no-hat villager has no head cuboid: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.1 no-hat villager has no head cuboid: texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "WANDERING_TRADER" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer WANDERING_TRADER is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "1.6 wandering trader shares the adult villager mesh: parts below the root" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 wandering trader shares the adult villager mesh: cuboids" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 wandering trader shares the adult villager mesh: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.6 wandering trader shares the adult villager mesh: texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "VILLAGER_BABY" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer VILLAGER_BABY is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-3§1 Villager, baby villager and wandering trader 1.2 baby" TO CK-PREFIX
     MOVE "P arms root 0 17.5 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hand arms -3 1.4025 -0.9599 -1.0472 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hand 36 15 -1 -2.4925 -1.8401 2 4 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hand 16 15 5 -2.4925 -1.8401 2 4 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P middlearm_r1 right_hand 0 0.9024 -1.8175 -1.0472 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C middlearm_r1 24 17 -2 -0.9924 -0.9825 4 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_leg root -1 21.5 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_leg 8 23 -1 -0.5 -1 2 3 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_leg root 1 21.5 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_leg 0 23 -1 -0.5 -1 2 3 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head root 0 16 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -4 -8 -3.5 8 8 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat head 0 -4 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C hat 0 30 -4 -4 -3.5 8 8 7 0.3 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat_rim head 0 -4.5 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C hat_rim 0 45 -7 -0.5 -6 14 1 12 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P nose head 0 -2 -4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C nose 23 0 -1 0 -0.5 2 2 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 18.75 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 15 -2 -2.75 -1.5 4 5 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P bb_main root 0.5 24 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C bb_main 16 21 -2.5 -8 -1.5 4 6 3 0.2 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "1.2 baby villager: parts below the root" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 baby villager: cuboids" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 baby villager: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 baby villager: texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "VILLAGER_BABY_NO_HAT" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer VILLAGER_BABY_NO_HAT is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-3§1 Villager, baby villager and wandering trader 1.2 baby no hat" TO CK-PREFIX
     MOVE "P arms root 0 17.5 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hand arms -3 1.4025 -0.9599 -1.0472 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hand 36 15 -1 -2.4925 -1.8401 2 4 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hand 16 15 5 -2.4925 -1.8401 2 4 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P middlearm_r1 right_hand 0 0.9024 -1.8175 -1.0472 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C middlearm_r1 24 17 -2 -0.9924 -0.9825 4 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_leg root -1 21.5 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_leg 8 23 -1 -0.5 -1 2 3 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_leg root 1 21.5 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_leg 0 23 -1 -0.5 -1 2 3 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head root 0 16 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat head 0 -4 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat_rim head 0 -4.5 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P nose head 0 -2 -4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 18.75 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 15 -2 -2.75 -1.5 4 5 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P bb_main root 0.5 24 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C bb_main 16 21 -2.5 -8 -1.5 4 6 3 0.2 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "1.2 baby no-hat villager: parts below the root" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 baby no-hat villager: cuboids" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 baby no-hat villager: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.2 baby no-hat villager: texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "VILLAGER" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 20 TO WS-IV(1)
     MOVE -30 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 10 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     CALL "EM3-VILLAGER-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 0.34906584 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE -0.52359876 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
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
     MOVE "arms" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "arms.xrot" TO WS-NAME
     MOVE -0.75 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "arms" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "arms.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "VILLAGER" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 15 TO WS-IV(1)
     MOVE 40 TO WS-IV(2)
     MOVE 7.5 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 10 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     CALL "EM3-VILLAGER-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 0.4 TO WS-E
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
     MOVE -0.293259035 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xrot" TO WS-NAME
     MOVE 0.196212954 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xrot" TO WS-NAME
     MOVE -0.196212954 TO WS-E
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
     MOVE "arms" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "arms.xrot" TO WS-NAME
     MOVE -0.75 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "arms" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "arms.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "VILLAGER_BABY" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE -10 TO WS-IV(1)
     MOVE 25 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 0.3 TO WS-IV(4)
     MOVE 3.3 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     CALL "EM3-VILLAGER-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 0.4 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE 0.4363323 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.zrot" TO WS-NAME
     MOVE 0.298896526 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_leg.xrot" TO WS-NAME
     MOVE 0.049590369 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_leg.xrot" TO WS-NAME
     MOVE -0.049590369 TO WS-E
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
     MOVE "arms" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "arms.xrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "arms" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "arms.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "VILLAGER_BABY" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     CALL "EM3-VILLAGER-ANIM" USING EMM-MODEL WS-IN
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
     MOVE "arms" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "arms.xrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "arms" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "arms.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "VILLAGER" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE "arms" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE 0 TO WS-PV(1) WS-PV(2) WS-PV(3)
     CALL "EMM-CHAIN-POINT" USING EMM-MODEL WS-P WS-POINT WS-CHAIN
     MOVE "1.3 translateToArms: the arms pivot x" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-CV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 translateToArms: the arms pivot y (root offset 1.501 and scale 0.9375)" TO WS-NAME
     MOVE 0.26959375 TO WS-E
     MOVE WS-CV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 translateToArms: the arms pivot z" TO WS-NAME
     MOVE -0.05859375 TO WS-E
     MOVE WS-CV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EM3-VILLAGER-SHADOW" USING WS-IN WS-OUT
     MOVE "1.4 shadow radius baby 0 scale 1" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EM3-VILLAGER-SHADOW" USING WS-IN WS-OUT
     MOVE "1.4 shadow radius baby 1 scale 1" TO WS-NAME
     MOVE 0.125 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     CALL "EM3-VILLAGER-SHADOW" USING WS-IN WS-OUT
     MOVE "1.4 shadow radius baby 0 scale 2" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1.5 TO WS-IV(2)
     CALL "EM3-VILLAGER-SHADOW" USING WS-IN WS-OUT
     MOVE "1.4 shadow radius baby 1 scale 1.5" TO WS-NAME
     MOVE 0.1875 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-BABY
     CALL "EM3-VILLAGER-TEXTURE" USING WS-BABY WS-TEXT
     MOVE "1.4 texture baby 0" TO WS-NAME
     MOVE "textures/entity/villager/villager.png" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 1 TO WS-BABY
     CALL "EM3-VILLAGER-TEXTURE" USING WS-BABY WS-TEXT
     MOVE "1.4 texture baby 1" TO WS-NAME
     MOVE "textures/entity/villager/villager_baby.png" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-TEXT
     CALL "EM3-TRADER-TEXTURE" USING WS-TEXT
     MOVE "1.6 wandering trader texture" TO WS-NAME
     MOVE "textures/entity/wandering_trader/wandering_trader.png" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "villager" TO WS-ARG
     CALL "EM3-HEAD-TRANSFORM" USING WS-ARG WS-OUT
     MOVE "1.4 custom head transform villager [1]" TO WS-NAME
     MOVE -0.1171875 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.4 custom head transform villager [2]" TO WS-NAME
     MOVE -0.07421875 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.4 custom head transform villager [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.4 custom head transform villager [4]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "default" TO WS-ARG
     CALL "EM3-HEAD-TRANSFORM" USING WS-ARG WS-OUT
     MOVE "1.4 custom head transform default [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.4 custom head transform default [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.4 custom head transform default [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.4 custom head transform default [4]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     CALL "EM3-CROSSED-ARMS-OPS" USING WS-OUT
     MOVE "1.4 crossed arms item: operation count" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.4 crossed arms item: operation 1 value 0" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.4 crossed arms item: operation 1 value 1" TO WS-NAME
     MOVE 42.971834635 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.4 crossed arms item: operation 1 value 2" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.4 crossed arms item: operation 1 value 3" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.4 crossed arms item: operation 2 value 0" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.4 crossed arms item: operation 2 value 1" TO WS-NAME
     MOVE 1.07 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.4 crossed arms item: operation 2 value 2" TO WS-NAME
     MOVE 1.07 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.4 crossed arms item: operation 2 value 3" TO WS-NAME
     MOVE 1.07 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.4 crossed arms item: operation 3 value 0" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.4 crossed arms item: operation 3 value 1" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.4 crossed arms item: operation 3 value 2" TO WS-NAME
     MOVE 0.13 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.4 crossed arms item: operation 3 value 3" TO WS-NAME
     MOVE -0.34 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.4 crossed arms item: operation 4 value 0" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.4 crossed arms item: operation 4 value 1" TO WS-NAME
     MOVE 180 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.4 crossed arms item: operation 4 value 2" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.4 crossed arms item: operation 4 value 3" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "villager" TO WS-ARG
     MOVE "type" TO WS-FOLDER
     MOVE "minecraft:plains" TO WS-KEY
     MOVE 0 TO WS-LEVEL
     MOVE 0 TO WS-BABY
     CALL "EM3-PROF-TEXTURE" USING WS-ARG WS-FOLDER WS-KEY WS-LEVEL WS-BABY WS-TEXT
     MOVE "1.5 texture of villager type minecraft:plains level 0 baby 0" TO WS-NAME
     MOVE "minecraft:textures/entity/villager/type/plains.png" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "villager" TO WS-ARG
     MOVE "type" TO WS-FOLDER
     MOVE "minecraft:desert" TO WS-KEY
     MOVE 0 TO WS-LEVEL
     MOVE 1 TO WS-BABY
     CALL "EM3-PROF-TEXTURE" USING WS-ARG WS-FOLDER WS-KEY WS-LEVEL WS-BABY WS-TEXT
     MOVE "1.5 texture of villager type minecraft:desert level 0 baby 1" TO WS-NAME
     MOVE "minecraft:textures/entity/villager/baby/desert.png" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "villager" TO WS-ARG
     MOVE "profession" TO WS-FOLDER
     MOVE "minecraft:smith" TO WS-KEY
     MOVE 0 TO WS-LEVEL
     MOVE 0 TO WS-BABY
     CALL "EM3-PROF-TEXTURE" USING WS-ARG WS-FOLDER WS-KEY WS-LEVEL WS-BABY WS-TEXT
     MOVE "1.5 texture of villager profession minecraft:smith level 0 baby 0" TO WS-NAME
     MOVE "minecraft:textures/entity/villager/profession/smith.png" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "zombie_villager" TO WS-ARG
     MOVE "profession" TO WS-FOLDER
     MOVE "minecraft:farmer" TO WS-KEY
     MOVE 0 TO WS-LEVEL
     MOVE 0 TO WS-BABY
     CALL "EM3-PROF-TEXTURE" USING WS-ARG WS-FOLDER WS-KEY WS-LEVEL WS-BABY WS-TEXT
     MOVE "1.5 texture of zombie_villager profession minecraft:farmer level 0 baby 0" TO WS-NAME
     MOVE "minecraft:textures/entity/zombie_villager/profession/farmer.png" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "villager" TO WS-ARG
     MOVE "profession_level" TO WS-FOLDER
     MOVE "minecraft:smith" TO WS-KEY
     MOVE 1 TO WS-LEVEL
     MOVE 0 TO WS-BABY
     CALL "EM3-PROF-TEXTURE" USING WS-ARG WS-FOLDER WS-KEY WS-LEVEL WS-BABY WS-TEXT
     MOVE "1.5 texture of villager profession_level minecraft:smith level 1 baby 0" TO WS-NAME
     MOVE "minecraft:textures/entity/villager/profession_level/stone.png" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "villager" TO WS-ARG
     MOVE "profession_level" TO WS-FOLDER
     MOVE "minecraft:smith" TO WS-KEY
     MOVE 3 TO WS-LEVEL
     MOVE 0 TO WS-BABY
     CALL "EM3-PROF-TEXTURE" USING WS-ARG WS-FOLDER WS-KEY WS-LEVEL WS-BABY WS-TEXT
     MOVE "1.5 texture of villager profession_level minecraft:smith level 3 baby 0" TO WS-NAME
     MOVE "minecraft:textures/entity/villager/profession_level/gold.png" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "villager" TO WS-ARG
     MOVE "profession_level" TO WS-FOLDER
     MOVE "minecraft:smith" TO WS-KEY
     MOVE 5 TO WS-LEVEL
     MOVE 0 TO WS-BABY
     CALL "EM3-PROF-TEXTURE" USING WS-ARG WS-FOLDER WS-KEY WS-LEVEL WS-BABY WS-TEXT
     MOVE "1.5 texture of villager profession_level minecraft:smith level 5 baby 0" TO WS-NAME
     MOVE "minecraft:textures/entity/villager/profession_level/diamond.png" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "villager" TO WS-ARG
     MOVE "profession_level" TO WS-FOLDER
     MOVE "minecraft:smith" TO WS-KEY
     MOVE 9 TO WS-LEVEL
     MOVE 0 TO WS-BABY
     CALL "EM3-PROF-TEXTURE" USING WS-ARG WS-FOLDER WS-KEY WS-LEVEL WS-BABY WS-TEXT
     MOVE "1.5 texture of villager profession_level minecraft:smith level 9 baby 0" TO WS-NAME
     MOVE "minecraft:textures/entity/villager/profession_level/diamond.png" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "villager" TO WS-ARG
     MOVE "profession_level" TO WS-FOLDER
     MOVE "minecraft:smith" TO WS-KEY
     MOVE -2 TO WS-LEVEL
     MOVE 0 TO WS-BABY
     CALL "EM3-PROF-TEXTURE" USING WS-ARG WS-FOLDER WS-KEY WS-LEVEL WS-BABY WS-TEXT
     MOVE "1.5 texture of villager profession_level minecraft:smith level -2 baby 0" TO WS-NAME
     MOVE "minecraft:textures/entity/villager/profession_level/stone.png" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "villager" TO WS-ARG
     MOVE "profession_level" TO WS-FOLDER
     MOVE "mod:cleric" TO WS-KEY
     MOVE 2 TO WS-LEVEL
     MOVE 0 TO WS-BABY
     CALL "EM3-PROF-TEXTURE" USING WS-ARG WS-FOLDER WS-KEY WS-LEVEL WS-BABY WS-TEXT
     MOVE "1.5 texture of villager profession_level mod:cleric level 2 baby 0" TO WS-NAME
     MOVE "mod:textures/entity/villager/profession_level/iron.png" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "villager" TO WS-ARG
     MOVE "profession_level" TO WS-FOLDER
     MOVE "minecraft:cleric" TO WS-KEY
     MOVE 4 TO WS-LEVEL
     MOVE 0 TO WS-BABY
     CALL "EM3-PROF-TEXTURE" USING WS-ARG WS-FOLDER WS-KEY WS-LEVEL WS-BABY WS-TEXT
     MOVE "1.5 texture of villager profession_level minecraft:cleric level 4 baby 0" TO WS-NAME
     MOVE "minecraft:textures/entity/villager/profession_level/emerald.png" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "zombie_villager" TO WS-ARG
     MOVE "type" TO WS-FOLDER
     MOVE "minecraft:snow" TO WS-KEY
     MOVE 0 TO WS-LEVEL
     MOVE 1 TO WS-BABY
     CALL "EM3-PROF-TEXTURE" USING WS-ARG WS-FOLDER WS-KEY WS-LEVEL WS-BABY WS-TEXT
     MOVE "1.5 texture of zombie_villager type minecraft:snow level 0 baby 1" TO WS-NAME
     MOVE "minecraft:textures/entity/zombie_villager/baby/snow.png" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "villager" TO WS-ARG
     MOVE "profession" TO WS-FOLDER
     MOVE SPACES TO WS-KEY
     CALL "EM3-PROF-TEXTURE" USING WS-ARG WS-FOLDER WS-KEY WS-LEVEL WS-BABY WS-TEXT
     MOVE "1.5 a key that cannot be resolved falls back to the missing-texture image" TO WS-NAME
     MOVE "minecraft:missingno" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "none" TO WS-ARG
     CALL "EM3-HAT-VALUE" USING WS-ARG WS-FLAG
     MOVE "1.5 hat metadata value 'none'" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-FLAG TO WS-O
     PERFORM CHECK-NUM
     MOVE "partial" TO WS-ARG
     CALL "EM3-HAT-VALUE" USING WS-ARG WS-FLAG
     MOVE "1.5 hat metadata value 'partial'" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-FLAG TO WS-O
     PERFORM CHECK-NUM
     MOVE "full" TO WS-ARG
     CALL "EM3-HAT-VALUE" USING WS-ARG WS-FLAG
     MOVE "1.5 hat metadata value 'full'" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-FLAG TO WS-O
     PERFORM CHECK-NUM
     MOVE SPACES TO WS-ARG
     CALL "EM3-HAT-VALUE" USING WS-ARG WS-FLAG
     MOVE "1.5 hat metadata value ''" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-FLAG TO WS-O
     PERFORM CHECK-NUM
     MOVE "bogus" TO WS-ARG
     CALL "EM3-HAT-VALUE" USING WS-ARG WS-FLAG
     MOVE "1.5 hat metadata value 'bogus'" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-FLAG TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EM3-PROF-MODEL" USING WS-IN WS-OUT
     MOVE "1.5 type overlay model typeHat 0 profHat 0 (1 = full model)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EM3-PROF-MODEL" USING WS-IN WS-OUT
     MOVE "1.5 type overlay model typeHat 0 profHat 1 (1 = full model)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     CALL "EM3-PROF-MODEL" USING WS-IN WS-OUT
     MOVE "1.5 type overlay model typeHat 0 profHat 2 (1 = full model)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EM3-PROF-MODEL" USING WS-IN WS-OUT
     MOVE "1.5 type overlay model typeHat 1 profHat 0 (1 = full model)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EM3-PROF-MODEL" USING WS-IN WS-OUT
     MOVE "1.5 type overlay model typeHat 1 profHat 1 (1 = full model)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     CALL "EM3-PROF-MODEL" USING WS-IN WS-OUT
     MOVE "1.5 type overlay model typeHat 1 profHat 2 (1 = full model)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EM3-PROF-MODEL" USING WS-IN WS-OUT
     MOVE "1.5 type overlay model typeHat 2 profHat 0 (1 = full model)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EM3-PROF-MODEL" USING WS-IN WS-OUT
     MOVE "1.5 type overlay model typeHat 2 profHat 1 (1 = full model)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 2 TO WS-IV(2)
     CALL "EM3-PROF-MODEL" USING WS-IN WS-OUT
     MOVE "1.5 type overlay model typeHat 2 profHat 2 (1 = full model)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EM3-PROF-OVERLAYS" USING WS-IN WS-OUT
     MOVE "1.5 overlays invisible 0 data 1 baby 0 none 0 nitwit 0 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 overlays invisible 0 data 1 baby 0 none 0 nitwit 0 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 overlays invisible 0 data 1 baby 0 none 0 nitwit 0 [3]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EM3-PROF-OVERLAYS" USING WS-IN WS-OUT
     MOVE "1.5 overlays invisible 1 data 1 baby 0 none 0 nitwit 0 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 overlays invisible 1 data 1 baby 0 none 0 nitwit 0 [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 overlays invisible 1 data 1 baby 0 none 0 nitwit 0 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EM3-PROF-OVERLAYS" USING WS-IN WS-OUT
     MOVE "1.5 overlays invisible 0 data 0 baby 0 none 0 nitwit 0 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 overlays invisible 0 data 0 baby 0 none 0 nitwit 0 [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 overlays invisible 0 data 0 baby 0 none 0 nitwit 0 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EM3-PROF-OVERLAYS" USING WS-IN WS-OUT
     MOVE "1.5 overlays invisible 0 data 1 baby 1 none 0 nitwit 0 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 overlays invisible 0 data 1 baby 1 none 0 nitwit 0 [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 overlays invisible 0 data 1 baby 1 none 0 nitwit 0 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EM3-PROF-OVERLAYS" USING WS-IN WS-OUT
     MOVE "1.5 overlays invisible 0 data 1 baby 0 none 1 nitwit 0 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 overlays invisible 0 data 1 baby 0 none 1 nitwit 0 [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 overlays invisible 0 data 1 baby 0 none 1 nitwit 0 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EM3-PROF-OVERLAYS" USING WS-IN WS-OUT
     MOVE "1.5 overlays invisible 0 data 1 baby 0 none 0 nitwit 1 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 overlays invisible 0 data 1 baby 0 none 0 nitwit 1 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 overlays invisible 0 data 1 baby 0 none 0 nitwit 1 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EM3-PROF-OVERLAYS" USING WS-IN WS-OUT
     MOVE "1.5 overlays invisible 0 data 1 baby 1 none 1 nitwit 0 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 overlays invisible 0 data 1 baby 1 none 1 nitwit 0 [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 overlays invisible 0 data 1 baby 1 none 1 nitwit 0 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EM3-PROF-OVERLAYS" USING WS-IN WS-OUT
     MOVE "1.5 overlays invisible 0 data 1 baby 0 none 1 nitwit 1 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 overlays invisible 0 data 1 baby 0 none 1 nitwit 1 [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.5 overlays invisible 0 data 1 baby 0 none 1 nitwit 1 [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "NOSUCH" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE "an unknown layer is not built" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-3§1 Villager, baby villager and wandering trader: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-3§1 Villager, baby villager and wandering trader: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-3-1.
