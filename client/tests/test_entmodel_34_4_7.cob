*> Acceptance test of docs/protocol/34-entity-models-4-farm-animals-equines.md section 7 (Goat): 7.1 the texture paths, 7.2 setupAnim (quadruped, horn visibility, ramming head pitch, the baby's fixed 22.5 degree tilt),
*> 7.3 the geometry of goat and goat_baby. Mesh rows are the tables of the document; formula values were worked by an independent script.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-4-7.
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
     MOVE "GOAT" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer GOAT is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§7 Goat 7.3 GOAT" TO CK-PREFIX
     MOVE "P head root 1 14 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 2 61 -6 -11 -10 3 2 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 2 61 2 -11 -10 3 2 1 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 23 52 -0.5 -3 -14 0 7 5 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_horn head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_horn 12 55 -0.01 -16 -10 2 7 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_horn head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_horn 12 55 -2.99 -16 -10 2 7 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P nose head 0 -8 -8 0.9599 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C nose 34 46 -3 -4 -8 5 7 10 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 24 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 1 1 -4 -17 -7 9 11 16 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 28 -5 -18 -8 11 14 11 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 1 14 4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 36 29 0 4 0 3 6 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -3 14 4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 49 29 0 4 0 3 6 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 1 14 -6 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 49 2 0 0 0 3 10 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -3 14 -6 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 35 2 0 0 0 3 10 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "7.3 GOAT: parts below the root" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.3 GOAT: cuboids" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.3 GOAT: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.3 GOAT: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "GOAT_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer GOAT_BABY is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§7 Goat 7.3 GOAT_BABY" TO CK-PREFIX
     MOVE "P left_hind_leg root 1.5 19.5 3 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 29 12 -1 -0.5 -1 2 5 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -1.5 19.5 3 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 21 12 -1 -0.5 -1 2 5 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -1.5 19.5 -2 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 21 5 -1 -0.5 -1 2 5 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 1.5 19.5 -2 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 29 5 -1 -0.5 -1 2 5 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 17.8 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 10 -3 -2.3 -4.5 6 5 9 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 24 -2.5 -2.2 -4 5 4 8 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head root 0 15.5 -3 0.4363 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -2 -3.8126 -5.1548 4 4 6 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_horn head -1.5 -1.5 -1 -0.3926991 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_horn 24 0 0 -4.5 0 1 2 1 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_horn head -1.5 -1.5 -1 -0.3926991 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_horn 24 0 2 -4.5 0 1 2 1 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_ear head -1.7 -2.3126 0.1452 0 -0.5236 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_ear 0 12 -2 -0.5 -0.5 2 1 1 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_ear head 1.7 -2.3126 0.1452 0 0.5236 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_ear 0 12 0 -0.5 -0.5 2 1 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P HeadMain head 0 -1.3126 -1.1548 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C HeadMain 0 0 -2 -2.5 -4 4 4 6 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "7.3 GOAT_BABY: parts below the root" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.3 GOAT_BABY: cuboids" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.3 GOAT_BABY: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "7.3 GOAT_BABY: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF4-GOAT-TEXTURE" USING WS-IN WS-X120
     MOVE "7.1 texture baby 0" TO WS-NAME
     MOVE "textures/entity/goat/goat.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 1 TO WS-IV(1)
     CALL "EF4-GOAT-TEXTURE" USING WS-IN WS-X120
     MOVE "7.1 texture baby 1" TO WS-NAME
     MOVE "textures/entity/goat/goat_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "GOAT" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 10 TO WS-IV(1)
     MOVE -20 TO WS-IV(2)
     MOVE 1.2 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     CALL "EF4-GOAT-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 11 ramming 0 pos 1.2 head.xrot" TO WS-NAME
     MOVE 0.17453292 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 11 ramming 0 pos 1.2 head.yrot" TO WS-NAME
     MOVE -0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 11 ramming 0 pos 1.2 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.487975824 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 11 ramming 0 pos 1.2 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.487975824 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 11 ramming 0 pos 1.2 right_front_leg.xrot" TO WS-NAME
     MOVE -0.487975824 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 11 ramming 0 pos 1.2 left_front_leg.xrot" TO WS-NAME
     MOVE 0.487975824 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_horn" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 11 ramming 0 pos 1.2 left_horn visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_horn" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 11 ramming 0 pos 1.2 right_horn visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "GOAT" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 15 TO WS-IV(1)
     MOVE 5 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     MOVE 0.7 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 0.8 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     CALL "EF4-GOAT-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 01 ramming 0.8 pos 3 head.xrot" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 01 ramming 0.8 pos 3 head.yrot" TO WS-NAME
     MOVE 0.08726646 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 01 ramming 0.8 pos 3 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.406575944 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 01 ramming 0.8 pos 3 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.406575944 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 01 ramming 0.8 pos 3 right_front_leg.xrot" TO WS-NAME
     MOVE 0.406575944 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 01 ramming 0.8 pos 3 left_front_leg.xrot" TO WS-NAME
     MOVE -0.406575944 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_horn" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 01 ramming 0.8 pos 3 left_horn visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_horn" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 01 ramming 0.8 pos 3 right_horn visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "GOAT" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE -8 TO WS-IV(1)
     MOVE 40 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 0.2 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE -0.4 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     CALL "EF4-GOAT-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 10 ramming -0.4 pos 2 head.xrot" TO WS-NAME
     MOVE -0.4 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 10 ramming -0.4 pos 2 head.yrot" TO WS-NAME
     MOVE 0.69813168 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 10 ramming -0.4 pos 2 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.066120492 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 10 ramming -0.4 pos 2 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.066120492 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 10 ramming -0.4 pos 2 right_front_leg.xrot" TO WS-NAME
     MOVE -0.066120492 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 10 ramming -0.4 pos 2 left_front_leg.xrot" TO WS-NAME
     MOVE 0.066120492 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_horn" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 10 ramming -0.4 pos 2 left_horn visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_horn" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 10 ramming -0.4 pos 2 right_horn visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "GOAT" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     CALL "EF4-GOAT-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 00 ramming 0 pos 0 head.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 00 ramming 0 pos 0 head.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 00 ramming 0 pos 0 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 00 ramming 0 pos 0 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 00 ramming 0 pos 0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 00 ramming 0 pos 0 left_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_horn" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 00 ramming 0 pos 0 left_horn visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_horn" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT horns 00 ramming 0 pos 0 right_horn visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "GOAT_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 10 TO WS-IV(1)
     MOVE -20 TO WS-IV(2)
     MOVE 1.2 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 1 TO WS-IV(8)
     CALL "EF4-GOAT-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 11 ramming 0 pos 1.2 head.xrot" TO WS-NAME
     MOVE 0.3926991 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 11 ramming 0 pos 1.2 head.yrot" TO WS-NAME
     MOVE -0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 11 ramming 0 pos 1.2 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.487975824 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 11 ramming 0 pos 1.2 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.487975824 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 11 ramming 0 pos 1.2 right_front_leg.xrot" TO WS-NAME
     MOVE -0.487975824 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 11 ramming 0 pos 1.2 left_front_leg.xrot" TO WS-NAME
     MOVE 0.487975824 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_horn" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 11 ramming 0 pos 1.2 left_horn visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_horn" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 11 ramming 0 pos 1.2 right_horn visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "GOAT_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 15 TO WS-IV(1)
     MOVE 5 TO WS-IV(2)
     MOVE 3 TO WS-IV(3)
     MOVE 0.7 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 0.8 TO WS-IV(7)
     MOVE 1 TO WS-IV(8)
     CALL "EF4-GOAT-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 01 ramming 0.8 pos 3 head.xrot" TO WS-NAME
     MOVE 0.8 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 01 ramming 0.8 pos 3 head.yrot" TO WS-NAME
     MOVE 0.08726646 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 01 ramming 0.8 pos 3 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.406575944 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 01 ramming 0.8 pos 3 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.406575944 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 01 ramming 0.8 pos 3 right_front_leg.xrot" TO WS-NAME
     MOVE 0.406575944 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 01 ramming 0.8 pos 3 left_front_leg.xrot" TO WS-NAME
     MOVE -0.406575944 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_horn" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 01 ramming 0.8 pos 3 left_horn visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_horn" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 01 ramming 0.8 pos 3 right_horn visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "GOAT_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE -8 TO WS-IV(1)
     MOVE 40 TO WS-IV(2)
     MOVE 2 TO WS-IV(3)
     MOVE 0.2 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE -0.4 TO WS-IV(7)
     MOVE 1 TO WS-IV(8)
     CALL "EF4-GOAT-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 10 ramming -0.4 pos 2 head.xrot" TO WS-NAME
     MOVE -0.4 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 10 ramming -0.4 pos 2 head.yrot" TO WS-NAME
     MOVE 0.69813168 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 10 ramming -0.4 pos 2 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.066120492 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 10 ramming -0.4 pos 2 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.066120492 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 10 ramming -0.4 pos 2 right_front_leg.xrot" TO WS-NAME
     MOVE -0.066120492 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 10 ramming -0.4 pos 2 left_front_leg.xrot" TO WS-NAME
     MOVE 0.066120492 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_horn" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 10 ramming -0.4 pos 2 left_horn visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_horn" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 10 ramming -0.4 pos 2 right_horn visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "GOAT_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 1 TO WS-IV(8)
     CALL "EF4-GOAT-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 00 ramming 0 pos 0 head.xrot" TO WS-NAME
     MOVE 0.3926991 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 00 ramming 0 pos 0 head.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 00 ramming 0 pos 0 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 00 ramming 0 pos 0 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 00 ramming 0 pos 0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 00 ramming 0 pos 0 left_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_horn" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 00 ramming 0 pos 0 left_horn visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_horn" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "7.2 GOAT_BABY horns 00 ramming 0 pos 0 right_horn visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-4§7 Goat: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-4§7 Goat: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-4-7.
