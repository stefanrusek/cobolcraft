*> Acceptance test of docs/protocol/34-entity-models-4-farm-animals-equines.md section 2 (Cow): 2.1 the variant texture rule (null variant, baby texture, adult texture), 2.2 setupAnim (head angles and the four leg swings,
*> amplitude 1.4, phase 0.6662, the pose reset first), 2.3 the geometry of the layers cow, cold_cow, warm_cow and cow_baby (every part, cuboid, grow and mirror, texture size). Mesh rows are the tables of the document;
*> formula values were worked by an independent script.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-4-2.
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
     MOVE "COW" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer COW is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§2 Cow 2.3 COW" TO CK-PREFIX
     MOVE "P head root 0 4 -8 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -4 -4 -6 8 8 6 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 1 33 -3 1 -7 6 3 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 22 0 -5 -5 -5 1 3 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 22 0 4 -5 -5 1 3 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 5 2 1.5707964 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 18 4 -6 -10 -7 12 18 10 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 52 0 -2 2 -8 4 6 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -4 12 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 0 16 -2 0 -2 4 12 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 4 12 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 0 16 -2 0 -2 4 12 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -4 12 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 0 16 -2 0 -2 4 12 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 4 12 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 0 16 -2 0 -2 4 12 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "2.3 COW: parts below the root" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.3 COW: cuboids" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.3 COW: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.3 COW: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "COLD_COW" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer COLD_COW is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§2 Cow 2.3 COLD_COW" TO CK-PREFIX
     MOVE "P head root 0 4 -8 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -4 -4 -6 8 8 6 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 9 33 -3 1 -7 6 3 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 5 2 1.5707964 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 20 32 -6 -10 -7 12 18 10 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 18 4 -6 -10 -7 12 18 10 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 52 0 -2 2 -8 4 6 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -4 12 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 0 16 -2 0 -2 4 12 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 4 12 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 0 16 -2 0 -2 4 12 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -4 12 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 0 16 -2 0 -2 4 12 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 4 12 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 0 16 -2 0 -2 4 12 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_horn head -4.5 -2.5 -3.5 1.5708 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_horn 0 40 -1.5 -4.5 -0.5 2 6 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_horn head 5.5 -2.5 -5 1.5708 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_horn 0 32 -1.5 -3 -0.5 2 6 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "2.3 COLD_COW: parts below the root" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.3 COLD_COW: cuboids" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.3 COLD_COW: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.3 COLD_COW: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "WARM_COW" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer WARM_COW is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§2 Cow 2.3 WARM_COW" TO CK-PREFIX
     MOVE "P head root 0 4 -8 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -4 -4 -6 8 8 6 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 1 33 -3 1 -7 6 3 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 27 0 -8 -3 -5 4 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 39 0 -8 -5 -5 2 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 27 0 4 -3 -5 4 2 2 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 39 0 6 -5 -5 2 2 2 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 5 2 1.5707964 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 18 4 -6 -10 -7 12 18 10 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 52 0 -2 2 -8 4 6 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -4 12 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 0 16 -2 0 -2 4 12 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 4 12 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 0 16 -2 0 -2 4 12 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -4 12 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 0 16 -2 0 -2 4 12 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 4 12 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 0 16 -2 0 -2 4 12 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "2.3 WARM_COW: parts below the root" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.3 WARM_COW: cuboids" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.3 WARM_COW: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.3 WARM_COW: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "COW_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer COW_BABY is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§2 Cow 2.3 COW_BABY" TO CK-PREFIX
     MOVE "P head root 0 13.569 -5.1667 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 18 -3 -4.569 -4.8333 6 6 5 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 8 29 3 -5.569 -3.8333 1 2 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 4 29 -4 -5.569 -3.8333 1 2 1 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 12 29 -2 -1.569 -5.8333 4 3 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 3 19 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 0 -7 -7 -1 8 6 12 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -2.5 18 -3.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 22 18 -1.5 0 -1.5 3 6 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 2.5 18 -3.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 34 18 -1.5 0 -1.5 3 6 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -2.5 18 3.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 22 27 -1.5 0 -1.5 3 6 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 2.5 18 3.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 34 27 -1.5 0 -1.5 3 6 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "2.3 COW_BABY: parts below the root" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.3 COW_BABY: cuboids" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.3 COW_BABY: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "2.3 COW_BABY: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-VARIANT-TEXTURE" USING WS-IN WS-OUT
     MOVE "2.1 variant null 1 baby 0 texture (0 missing, 1 adult asset, 2 baby texture)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-VARIANT-TEXTURE" USING WS-IN WS-OUT
     MOVE "2.1 variant null 1 baby 1 texture (0 missing, 1 adult asset, 2 baby texture)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-VARIANT-TEXTURE" USING WS-IN WS-OUT
     MOVE "2.1 variant null 0 baby 0 texture (0 missing, 1 adult asset, 2 baby texture)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-VARIANT-TEXTURE" USING WS-IN WS-OUT
     MOVE "2.1 variant null 0 baby 1 texture (0 missing, 1 adult asset, 2 baby texture)" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "COW" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 12 TO WS-IV(1)
     MOVE -30 TO WS-IV(2)
     MOVE 2.5 TO WS-IV(3)
     MOVE 0.6 TO WS-IV(4)
     CALL "EF4-COW-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW pitch 12 yaw -30 pos 2.5 speed 0.6 head.xrot" TO WS-NAME
     MOVE 0.209439504 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW pitch 12 yaw -30 pos 2.5 speed 0.6 head.yrot" TO WS-NAME
     MOVE -0.52359876 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW pitch 12 yaw -30 pos 2.5 speed 0.6 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW pitch 12 yaw -30 pos 2.5 speed 0.6 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW pitch 12 yaw -30 pos 2.5 speed 0.6 right_front_leg.xrot" TO WS-NAME
     MOVE 0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW pitch 12 yaw -30 pos 2.5 speed 0.6 left_front_leg.xrot" TO WS-NAME
     MOVE -0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW pitch 12 yaw -30 pos 2.5 speed 0.6 body.xrot" TO WS-NAME
     MOVE 1.5707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "COW" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-COW-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW pitch 0 yaw 0 pos 0 speed 0 head.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW pitch 0 yaw 0 pos 0 speed 0 head.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW pitch 0 yaw 0 pos 0 speed 0 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW pitch 0 yaw 0 pos 0 speed 0 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW pitch 0 yaw 0 pos 0 speed 0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW pitch 0 yaw 0 pos 0 speed 0 left_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW pitch 0 yaw 0 pos 0 speed 0 body.xrot" TO WS-NAME
     MOVE 1.5707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "COW" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE -45 TO WS-IV(1)
     MOVE 80 TO WS-IV(2)
     MOVE 7.25 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-COW-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW pitch -45 yaw 80 pos 7.25 speed 1 head.xrot" TO WS-NAME
     MOVE -0.78539814 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW pitch -45 yaw 80 pos 7.25 speed 1 head.yrot" TO WS-NAME
     MOVE 1.39626336 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW pitch -45 yaw 80 pos 7.25 speed 1 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.164206578 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW pitch -45 yaw 80 pos 7.25 speed 1 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.164206578 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW pitch -45 yaw 80 pos 7.25 speed 1 right_front_leg.xrot" TO WS-NAME
     MOVE -0.164206578 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW pitch -45 yaw 80 pos 7.25 speed 1 left_front_leg.xrot" TO WS-NAME
     MOVE 0.164206578 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW pitch -45 yaw 80 pos 7.25 speed 1 body.xrot" TO WS-NAME
     MOVE 1.5707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "COLD_COW" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 12 TO WS-IV(1)
     MOVE -30 TO WS-IV(2)
     MOVE 2.5 TO WS-IV(3)
     MOVE 0.6 TO WS-IV(4)
     CALL "EF4-COW-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COLD_COW pitch 12 yaw -30 pos 2.5 speed 0.6 head.xrot" TO WS-NAME
     MOVE 0.209439504 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COLD_COW pitch 12 yaw -30 pos 2.5 speed 0.6 head.yrot" TO WS-NAME
     MOVE -0.52359876 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COLD_COW pitch 12 yaw -30 pos 2.5 speed 0.6 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COLD_COW pitch 12 yaw -30 pos 2.5 speed 0.6 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COLD_COW pitch 12 yaw -30 pos 2.5 speed 0.6 right_front_leg.xrot" TO WS-NAME
     MOVE 0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COLD_COW pitch 12 yaw -30 pos 2.5 speed 0.6 left_front_leg.xrot" TO WS-NAME
     MOVE -0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COLD_COW pitch 12 yaw -30 pos 2.5 speed 0.6 body.xrot" TO WS-NAME
     MOVE 1.5707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "COLD_COW" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-COW-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COLD_COW pitch 0 yaw 0 pos 0 speed 0 head.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COLD_COW pitch 0 yaw 0 pos 0 speed 0 head.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COLD_COW pitch 0 yaw 0 pos 0 speed 0 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COLD_COW pitch 0 yaw 0 pos 0 speed 0 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COLD_COW pitch 0 yaw 0 pos 0 speed 0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COLD_COW pitch 0 yaw 0 pos 0 speed 0 left_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COLD_COW pitch 0 yaw 0 pos 0 speed 0 body.xrot" TO WS-NAME
     MOVE 1.5707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "COLD_COW" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE -45 TO WS-IV(1)
     MOVE 80 TO WS-IV(2)
     MOVE 7.25 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-COW-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COLD_COW pitch -45 yaw 80 pos 7.25 speed 1 head.xrot" TO WS-NAME
     MOVE -0.78539814 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COLD_COW pitch -45 yaw 80 pos 7.25 speed 1 head.yrot" TO WS-NAME
     MOVE 1.39626336 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COLD_COW pitch -45 yaw 80 pos 7.25 speed 1 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.164206578 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COLD_COW pitch -45 yaw 80 pos 7.25 speed 1 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.164206578 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COLD_COW pitch -45 yaw 80 pos 7.25 speed 1 right_front_leg.xrot" TO WS-NAME
     MOVE -0.164206578 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COLD_COW pitch -45 yaw 80 pos 7.25 speed 1 left_front_leg.xrot" TO WS-NAME
     MOVE 0.164206578 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COLD_COW pitch -45 yaw 80 pos 7.25 speed 1 body.xrot" TO WS-NAME
     MOVE 1.5707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "WARM_COW" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 12 TO WS-IV(1)
     MOVE -30 TO WS-IV(2)
     MOVE 2.5 TO WS-IV(3)
     MOVE 0.6 TO WS-IV(4)
     CALL "EF4-COW-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 WARM_COW pitch 12 yaw -30 pos 2.5 speed 0.6 head.xrot" TO WS-NAME
     MOVE 0.209439504 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 WARM_COW pitch 12 yaw -30 pos 2.5 speed 0.6 head.yrot" TO WS-NAME
     MOVE -0.52359876 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 WARM_COW pitch 12 yaw -30 pos 2.5 speed 0.6 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 WARM_COW pitch 12 yaw -30 pos 2.5 speed 0.6 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 WARM_COW pitch 12 yaw -30 pos 2.5 speed 0.6 right_front_leg.xrot" TO WS-NAME
     MOVE 0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 WARM_COW pitch 12 yaw -30 pos 2.5 speed 0.6 left_front_leg.xrot" TO WS-NAME
     MOVE -0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 WARM_COW pitch 12 yaw -30 pos 2.5 speed 0.6 body.xrot" TO WS-NAME
     MOVE 1.5707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "WARM_COW" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-COW-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 WARM_COW pitch 0 yaw 0 pos 0 speed 0 head.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 WARM_COW pitch 0 yaw 0 pos 0 speed 0 head.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 WARM_COW pitch 0 yaw 0 pos 0 speed 0 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 WARM_COW pitch 0 yaw 0 pos 0 speed 0 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 WARM_COW pitch 0 yaw 0 pos 0 speed 0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 WARM_COW pitch 0 yaw 0 pos 0 speed 0 left_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 WARM_COW pitch 0 yaw 0 pos 0 speed 0 body.xrot" TO WS-NAME
     MOVE 1.5707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "WARM_COW" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE -45 TO WS-IV(1)
     MOVE 80 TO WS-IV(2)
     MOVE 7.25 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-COW-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 WARM_COW pitch -45 yaw 80 pos 7.25 speed 1 head.xrot" TO WS-NAME
     MOVE -0.78539814 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 WARM_COW pitch -45 yaw 80 pos 7.25 speed 1 head.yrot" TO WS-NAME
     MOVE 1.39626336 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 WARM_COW pitch -45 yaw 80 pos 7.25 speed 1 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.164206578 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 WARM_COW pitch -45 yaw 80 pos 7.25 speed 1 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.164206578 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 WARM_COW pitch -45 yaw 80 pos 7.25 speed 1 right_front_leg.xrot" TO WS-NAME
     MOVE -0.164206578 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 WARM_COW pitch -45 yaw 80 pos 7.25 speed 1 left_front_leg.xrot" TO WS-NAME
     MOVE 0.164206578 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 WARM_COW pitch -45 yaw 80 pos 7.25 speed 1 body.xrot" TO WS-NAME
     MOVE 1.5707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "COW_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 12 TO WS-IV(1)
     MOVE -30 TO WS-IV(2)
     MOVE 2.5 TO WS-IV(3)
     MOVE 0.6 TO WS-IV(4)
     CALL "EF4-COW-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW_BABY pitch 12 yaw -30 pos 2.5 speed 0.6 head.xrot" TO WS-NAME
     MOVE 0.209439504 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW_BABY pitch 12 yaw -30 pos 2.5 speed 0.6 head.yrot" TO WS-NAME
     MOVE -0.52359876 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW_BABY pitch 12 yaw -30 pos 2.5 speed 0.6 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW_BABY pitch 12 yaw -30 pos 2.5 speed 0.6 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW_BABY pitch 12 yaw -30 pos 2.5 speed 0.6 right_front_leg.xrot" TO WS-NAME
     MOVE 0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW_BABY pitch 12 yaw -30 pos 2.5 speed 0.6 left_front_leg.xrot" TO WS-NAME
     MOVE -0.079432226 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW_BABY pitch 12 yaw -30 pos 2.5 speed 0.6 body.xrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "COW_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-COW-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW_BABY pitch 0 yaw 0 pos 0 speed 0 head.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW_BABY pitch 0 yaw 0 pos 0 speed 0 head.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW_BABY pitch 0 yaw 0 pos 0 speed 0 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW_BABY pitch 0 yaw 0 pos 0 speed 0 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW_BABY pitch 0 yaw 0 pos 0 speed 0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW_BABY pitch 0 yaw 0 pos 0 speed 0 left_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW_BABY pitch 0 yaw 0 pos 0 speed 0 body.xrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "COW_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE -45 TO WS-IV(1)
     MOVE 80 TO WS-IV(2)
     MOVE 7.25 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-COW-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW_BABY pitch -45 yaw 80 pos 7.25 speed 1 head.xrot" TO WS-NAME
     MOVE -0.78539814 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW_BABY pitch -45 yaw 80 pos 7.25 speed 1 head.yrot" TO WS-NAME
     MOVE 1.39626336 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW_BABY pitch -45 yaw 80 pos 7.25 speed 1 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.164206578 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW_BABY pitch -45 yaw 80 pos 7.25 speed 1 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.164206578 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW_BABY pitch -45 yaw 80 pos 7.25 speed 1 right_front_leg.xrot" TO WS-NAME
     MOVE -0.164206578 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW_BABY pitch -45 yaw 80 pos 7.25 speed 1 left_front_leg.xrot" TO WS-NAME
     MOVE 0.164206578 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "2.2 COW_BABY pitch -45 yaw 80 pos 7.25 speed 1 body.xrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-4§2 Cow: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-4§2 Cow: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-4-2.
