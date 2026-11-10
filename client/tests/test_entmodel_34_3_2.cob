*> Acceptance test of docs/protocol/34-entity-models-3-villagers-illagers-golems-misc.md section 2 (Zombie villager): 2.1 and 2.2 the adult and baby meshes
*> and their no-hat variants (not scaled), 2.3 animateZombieArms with the worked example, the shaking rule, 2.4 the adult armor slots (grows head 1.0 and 1.5, body 1.1, legs
*> 0.6 and 1.1) and the baby armor set. Mesh rows are the tables of the document; formula values were worked by an independent script.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-3-2.
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
 01 WS-SLOT               BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "ZOMBIE_VILLAGER" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer ZOMBIE_VILLAGER is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-3§2 Zombie villager 2.1 adult" TO CK-PREFIX
     MOVE "P head root 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -4 -10 -4 8 10 8 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 24 0 -1 -3 -6 2 4 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C hat 32 0 -4 -10 -4 8 10 8 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat_rim hat 0 0 0 -1.5707964 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C hat_rim 30 47 -8 -8 -6 16 16 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 16 20 -4 0 -3 8 12 6 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 38 -4 0 -3 8 20 6 0.05 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_arm root -5 2 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_arm 44 22 -3 -2 -2 4 12 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_arm root 5 2 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_arm 44 22 -1 -2 -2 4 12 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_leg root -2 12 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_leg 0 22 -2 0 -2 4 12 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_leg root 2 12 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_leg 0 22 -2 0 -2 4 12 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "2.1 zombie villager: parts below the root" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.1 zombie villager: cuboids" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.1 zombie villager: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.1 zombie villager: texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_VILLAGER_NO_HAT" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer ZOMBIE_VILLAGER_NO_HAT is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "2.1 no-hat zombie villager: parts below the root" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.1 no-hat zombie villager: cuboids" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.1 no-hat zombie villager: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.1 no-hat zombie villager: texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_VILLAGER_BABY" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer ZOMBIE_VILLAGER_BABY is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-3§2 Zombie villager 2.2 baby" TO CK-PREFIX
     MOVE "P body root 0 18.75 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 15 -2 -2.75 -1.5 4 5 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 16 22 -2 -2.75 -1.5 4 6 3 0.1 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head root 0 16 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -4 -8 -3.5 8 8 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat head 0 -4 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C hat 0 31 -4 -4 -3.5 8 8 7 0.3 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat_rim head 0 -4.5 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C hat_rim 0 46 -7 -0.5 -6 14 1 12 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P nose head 0 -1 -4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C nose 23 0 -1 -1 -0.5 2 2 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_arm root -3 15.5 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_arm 24 15 -1 -0.5 -1 2 5 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_arm root 3 15.5 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_arm 16 15 -1 -0.5 -1 2 5 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_leg root -1 21.5 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_leg 8 23 -1 -0.5 -1 2 3 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_leg root 1 21.5 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_leg 0 23 -1 -0.5 -1 2 3 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "2.2 baby zombie villager: parts below the root" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.2 baby zombie villager: cuboids" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.2 baby zombie villager: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.2 baby zombie villager: texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_VILLAGER_BABY_NO_HAT" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer ZOMBIE_VILLAGER_BABY_NO_HAT is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "2.2 no-hat baby zombie villager: parts below the root" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.2 no-hat baby zombie villager: cuboids" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.2 no-hat baby zombie villager: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.2 no-hat baby zombie villager: texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_VILLAGER" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     CALL "EM3-ZV-ARMS" USING EMM-MODEL WS-IN
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.xrot" TO WS-NAME
     MOVE -2.094395102 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.yrot" TO WS-NAME
     MOVE -0.1 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.xrot" TO WS-NAME
     MOVE -2.094395102 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.yrot" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_VILLAGER" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     CALL "EM3-ZV-ARMS" USING EMM-MODEL WS-IN
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.xrot" TO WS-NAME
     MOVE -1.396263402 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.yrot" TO WS-NAME
     MOVE -0.1 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.xrot" TO WS-NAME
     MOVE -1.396263402 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.yrot" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_VILLAGER" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     CALL "EM3-ZV-ARMS" USING EMM-MODEL WS-IN
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.xrot" TO WS-NAME
     MOVE -1.177237815 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.yrot" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.xrot" TO WS-NAME
     MOVE -1.177237815 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.yrot" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_VILLAGER" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     CALL "EM3-ZV-ARMS" USING EMM-MODEL WS-IN
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.xrot" TO WS-NAME
     MOVE -1.482842712 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.yrot" TO WS-NAME
     MOVE 0.7 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.xrot" TO WS-NAME
     MOVE -1.482842712 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.yrot" TO WS-NAME
     MOVE -0.7 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_VILLAGER" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0.25 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     CALL "EM3-ZV-ARMS" USING EMM-MODEL WS-IN
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.xrot" TO WS-NAME
     MOVE -1.24084225 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.yrot" TO WS-NAME
     MOVE 0.524264069 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.xrot" TO WS-NAME
     MOVE -1.24084225 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.yrot" TO WS-NAME
     MOVE -0.524264069 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_VILLAGER_BABY" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0.3 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     CALL "EM3-ZV-ARMS" USING EMM-MODEL WS-IN
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.xrot" TO WS-NAME
     MOVE -1.523377333 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.yrot" TO WS-NAME
     MOVE 0.385410197 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.xrot" TO WS-NAME
     MOVE -1.523377333 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.yrot" TO WS-NAME
     MOVE -0.385410197 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_VILLAGER_BABY" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0.7 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     CALL "EM3-ZV-ARMS" USING EMM-MODEL WS-IN
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.xrot" TO WS-NAME
     MOVE -0.537039451 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.yrot" TO WS-NAME
     MOVE 0.385410197 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.xrot" TO WS-NAME
     MOVE -0.537039451 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.yrot" TO WS-NAME
     MOVE -0.385410197 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_VILLAGER" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0.4 TO WS-IV(4)
     MOVE 10 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     CALL "EM3-ZV-ARMS" USING EMM-MODEL WS-IN
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.xrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.xrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_VILLAGER" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0.4 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 10 TO WS-IV(6)
     CALL "EM3-ZV-ARMS" USING EMM-MODEL WS-IN
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.xrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.xrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_VILLAGER" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0.4 TO WS-IV(4)
     MOVE 4 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     CALL "EM3-ZV-ARMS" USING EMM-MODEL WS-IN
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.xrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.xrot" TO WS-NAME
     MOVE -1.315058104 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.yrot" TO WS-NAME
     MOVE -0.47063391 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_VILLAGER" TO WS-LAYER
     CALL "EM3-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0.4 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 4 TO WS-IV(6)
     CALL "EM3-ZV-ARMS" USING EMM-MODEL WS-IN
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.xrot" TO WS-NAME
     MOVE -1.503198641 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.yrot" TO WS-NAME
     MOVE 0.67063391 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_arm.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.xrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_arm" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_arm.zrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CZROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     MOVE 30 TO WS-IV(4)
     CALL "EM3-ZV-SHAKING" USING WS-IN WS-OUT
     MOVE "2 shaking frozen 0 converting 0 age 5 bodyRot 30 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2 shaking frozen 0 converting 0 age 5 bodyRot 30 [2]" TO WS-NAME
     MOVE 30 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 5.9 TO WS-IV(3)
     MOVE 30 TO WS-IV(4)
     CALL "EM3-ZV-SHAKING" USING WS-IN WS-OUT
     MOVE "2 shaking frozen 1 converting 0 age 5.9 bodyRot 30 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2 shaking frozen 1 converting 0 age 5.9 bodyRot 30 [2]" TO WS-NAME
     MOVE 28.923489614 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 5.9 TO WS-IV(3)
     MOVE 30 TO WS-IV(4)
     CALL "EM3-ZV-SHAKING" USING WS-IN WS-OUT
     MOVE "2 shaking frozen 0 converting 1 age 5.9 bodyRot 30 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2 shaking frozen 0 converting 1 age 5.9 bodyRot 30 [2]" TO WS-NAME
     MOVE 28.923489614 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     MOVE -20 TO WS-IV(4)
     CALL "EM3-ZV-SHAKING" USING WS-IN WS-OUT
     MOVE "2 shaking frozen 1 converting 1 age 7 bodyRot -20 [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2 shaking frozen 1 converting 1 age 7 bodyRot -20 [2]" TO WS-NAME
     MOVE -20.911849543 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 7 TO WS-IV(3)
     MOVE 5 TO WS-IV(4)
     CALL "EM3-ZV-SHAKING" USING WS-IN WS-OUT
     MOVE "2 shaking frozen 0 converting 0 age 7 bodyRot 5 [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2 shaking frozen 0 converting 0 age 7 bodyRot 5 [2]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-SLOT
     CALL "EM3-ZV-ARMOR" USING EMM-MODEL WS-SLOT
     PERFORM CK-RESET-COUNTS
     MOVE "acceptance US15 34-3§2 Zombie villager 2.4 armor helmet" TO CK-PREFIX
     MOVE "P head root 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat_rim hat 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_arm root -5 2 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_arm root 5 2 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_leg root -2 12 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_leg root 2 12 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -4 -10 -4 8 8 8 1.0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C hat 32 0 -4 -8 -4 8 8 8 1.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "2.4 zombie villager armor helmet: parts below the root" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.4 zombie villager armor helmet: cuboids" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.4 zombie villager armor helmet: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.4 zombie villager armor helmet: texture height" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-SLOT
     CALL "EM3-ZV-ARMOR" USING EMM-MODEL WS-SLOT
     PERFORM CK-RESET-COUNTS
     MOVE "acceptance US15 34-3§2 Zombie villager 2.4 armor chestplate" TO CK-PREFIX
     MOVE "P head root 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat_rim hat 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_arm root -5 2 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_arm root 5 2 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_leg root -2 12 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_leg root 2 12 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 16 16 -4 0 -2 8 12 4 1.1 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_arm 40 16 -3 -2 -2 4 12 4 1.0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_arm 40 16 -1 -2 -2 4 12 4 1.0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "2.4 zombie villager armor chestplate: parts below the root" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.4 zombie villager armor chestplate: cuboids" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.4 zombie villager armor chestplate: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.4 zombie villager armor chestplate: texture height" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-SLOT
     CALL "EM3-ZV-ARMOR" USING EMM-MODEL WS-SLOT
     PERFORM CK-RESET-COUNTS
     MOVE "acceptance US15 34-3§2 Zombie villager 2.4 armor leggings" TO CK-PREFIX
     MOVE "P head root 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat_rim hat 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_arm root -5 2 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_arm root 5 2 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_leg root -2 12 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_leg root 2 12 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 16 16 -4 0 -2 8 12 4 0.6 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_leg 0 16 -2 0 -2 4 12 4 0.6 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_leg 0 16 -2 0 -2 4 12 4 0.6 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "2.4 zombie villager armor leggings: parts below the root" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.4 zombie villager armor leggings: cuboids" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.4 zombie villager armor leggings: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.4 zombie villager armor leggings: texture height" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-SLOT
     CALL "EM3-ZV-ARMOR" USING EMM-MODEL WS-SLOT
     PERFORM CK-RESET-COUNTS
     MOVE "acceptance US15 34-3§2 Zombie villager 2.4 armor boots" TO CK-PREFIX
     MOVE "P head root 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P hat_rim hat 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_arm root -5 2 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_arm root 5 2 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_leg root -2 12 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_leg root 2 12 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_leg 0 16 -2 0 -2 4 12 4 1.1 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_leg 0 16 -2 0 -2 4 12 4 1.1 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "2.4 zombie villager armor boots: parts below the root" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.4 zombie villager armor boots: cuboids" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.4 zombie villager armor boots: texture width" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.4 zombie villager armor boots: texture height" TO WS-NAME
     MOVE 32 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-SLOT
     CALL "EM3-ZV-BABY-ARMOR" USING EMM-MODEL WS-SLOT
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "2.4 baby armor helmet cuboids" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.4 baby armor helmet texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-SLOT
     CALL "EM3-ZV-BABY-ARMOR" USING EMM-MODEL WS-SLOT
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "2.4 baby armor chestplate cuboids" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.4 baby armor chestplate texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-SLOT
     CALL "EM3-ZV-BABY-ARMOR" USING EMM-MODEL WS-SLOT
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "2.4 baby armor leggings cuboids" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.4 baby armor leggings texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-SLOT
     CALL "EM3-ZV-BABY-ARMOR" USING EMM-MODEL WS-SLOT
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "2.4 baby armor boots cuboids" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.4 baby armor boots texture height" TO WS-NAME
     MOVE 64 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-SLOT
     CALL "EM3-ZV-BABY-ARMOR" USING EMM-MODEL WS-SLOT
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.4 baby outer armor head grow x" TO WS-NAME
     MOVE -0.1 TO WS-E
     MOVE MC-GX(WS-P, 1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.4 baby outer armor head grow y" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE MC-GY(WS-P, 1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.4 baby outer armor head grow z" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE MC-GZ(WS-P, 1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-SLOT
     CALL "EM3-ZV-BABY-ARMOR" USING EMM-MODEL WS-SLOT
     MOVE "waist" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.4 baby inner armor waist grow x (-0.1 and -0.1)" TO WS-NAME
     MOVE -0.2 TO WS-E
     MOVE MC-GX(WS-P, 1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.4 baby inner armor waist grow y (0.3 and -0.1)" TO WS-NAME
     MOVE 0.2 TO WS-E
     MOVE MC-GY(WS-P, 1) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-3§2 Zombie villager: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-3§2 Zombie villager: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-3-2.
