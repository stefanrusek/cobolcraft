*> Acceptance test of docs/protocol/34-entity-models-4-farm-animals-equines.md section 4 (Pig): 4.1 the model pair by model type, the saddle layer (no baby model: a baby pig never shows a saddle), the null variant rule,
*> setupAnim as the quadruped, 4.2 the geometry of pig, pig_saddle, cold_pig and pig_baby. Mesh rows are the tables of the document; formula values were worked by an independent script.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-4-4.
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
     MOVE "PIG" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer PIG is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§4 Pig 4.2 PIG" TO CK-PREFIX
     MOVE "P head root 0 12 -6 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -4 -4 -8 8 8 8 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 16 16 -2 0 -9 4 3 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 11 2 1.5707964 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 28 8 -5 -10 -7 10 16 8 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -3 18 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 0 16 -2 0 -2 4 6 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 3 18 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 0 16 -2 0 -2 4 6 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -3 18 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 0 16 -2 0 -2 4 6 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 3 18 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 0 16 -2 0 -2 4 6 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "4.2 PIG: parts below the root" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "4.2 PIG: cuboids" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "4.2 PIG: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "4.2 PIG: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "PIG_SADDLE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer PIG_SADDLE is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§4 Pig 4.2 PIG_SADDLE" TO CK-PREFIX
     MOVE "P head root 0 12 -6 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -4 -4 -8 8 8 8 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 16 16 -2 0 -9 4 3 1 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 11 2 1.5707964 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 28 8 -5 -10 -7 10 16 8 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -3 18 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 0 16 -2 0 -2 4 6 4 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 3 18 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 0 16 -2 0 -2 4 6 4 0.5 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -3 18 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 0 16 -2 0 -2 4 6 4 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 3 18 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 0 16 -2 0 -2 4 6 4 0.5 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "4.2 PIG_SADDLE: parts below the root" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "4.2 PIG_SADDLE: cuboids" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "4.2 PIG_SADDLE: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "4.2 PIG_SADDLE: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "COLD_PIG" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer COLD_PIG is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§4 Pig 4.2 COLD_PIG" TO CK-PREFIX
     MOVE "P head root 0 12 -6 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -4 -4 -8 8 8 8 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 16 16 -2 0 -9 4 3 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 11 2 1.5707964 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 28 8 -5 -10 -7 10 16 8 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 28 32 -5 -10 -7 10 16 8 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -3 18 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 0 16 -2 0 -2 4 6 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 3 18 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 0 16 -2 0 -2 4 6 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -3 18 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 0 16 -2 0 -2 4 6 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 3 18 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 0 16 -2 0 -2 4 6 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "4.2 COLD_PIG: parts below the root" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "4.2 COLD_PIG: cuboids" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "4.2 COLD_PIG: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "4.2 COLD_PIG: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "PIG_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer PIG_BABY is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§4 Pig 4.2 PIG_BABY" TO CK-PREFIX
     MOVE "P body root 0 19 0.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 0 -3.5 -3 -4.5 7 6 9 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head root 0 19 -2 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 15 -3.5 -5 -5 7 6 6 0.025 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 6 27 -1.5 -1.975 -6 3 2 1 0.015 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 2.5 22 -3 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 0 0 -1 0 -1 2 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -2.5 22 -3 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 23 0 -1 0 -1 2 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 2.5 22 4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 0 4 -1 0 -1 2 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -2.5 22 4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 23 4 -1 0 -1 2 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "4.2 PIG_BABY: parts below the root" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "4.2 PIG_BABY: cuboids" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "4.2 PIG_BABY: texture width" TO WS-NAME
     MOVE 32.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "4.2 PIG_BABY: texture height" TO WS-NAME
     MOVE 32.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "pig" TO WS-X24
     MOVE "normal" TO WS-X40
     MOVE 0 TO WS-FL
     CALL "EF4-VARIANT-MODEL" USING WS-X24 WS-X40 WS-FL WS-X32
     MOVE "4.1 pig model type normal baby 0" TO WS-NAME
     MOVE "PIG" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "pig" TO WS-X24
     MOVE "normal" TO WS-X40
     MOVE 1 TO WS-FL
     CALL "EF4-VARIANT-MODEL" USING WS-X24 WS-X40 WS-FL WS-X32
     MOVE "4.1 pig model type normal baby 1" TO WS-NAME
     MOVE "PIG_BABY" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "pig" TO WS-X24
     MOVE "cold" TO WS-X40
     MOVE 0 TO WS-FL
     CALL "EF4-VARIANT-MODEL" USING WS-X24 WS-X40 WS-FL WS-X32
     MOVE "4.1 pig model type cold baby 0" TO WS-NAME
     MOVE "COLD_PIG" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "pig" TO WS-X24
     MOVE "cold" TO WS-X40
     MOVE 1 TO WS-FL
     CALL "EF4-VARIANT-MODEL" USING WS-X24 WS-X40 WS-FL WS-X32
     MOVE "4.1 pig model type cold baby 1" TO WS-NAME
     MOVE "PIG_BABY" TO TL-EXPECTED
     MOVE WS-X32 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-PIG-SADDLE" USING WS-IN WS-OUT
     MOVE "4.1 saddle item 0 baby 0 drawn (pig_saddle layer type, no baby model)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-PIG-SADDLE" USING WS-IN WS-OUT
     MOVE "4.1 saddle item 1 baby 0 drawn (pig_saddle layer type, no baby model)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-PIG-SADDLE" USING WS-IN WS-OUT
     MOVE "4.1 saddle item 0 baby 1 drawn (pig_saddle layer type, no baby model)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-PIG-SADDLE" USING WS-IN WS-OUT
     MOVE "4.1 saddle item 1 baby 1 drawn (pig_saddle layer type, no baby model)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-VARIANT-TEXTURE" USING WS-IN WS-OUT
     MOVE "4.1 null variant: missing texture" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-VARIANT-TEXTURE" USING WS-IN WS-OUT
     MOVE "4.1 baby: the baby texture of the variant" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PIG" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 20 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 1.5 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     CALL "EF4-PIG-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG anim pos 1.5 head.xrot" TO WS-NAME
     MOVE 0.34906584 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG anim pos 1.5 head.yrot" TO WS-NAME
     MOVE 0.17453292 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG anim pos 1.5 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.378623842 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG anim pos 1.5 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.378623842 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG anim pos 1.5 right_front_leg.xrot" TO WS-NAME
     MOVE -0.378623842 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG anim pos 1.5 left_front_leg.xrot" TO WS-NAME
     MOVE 0.378623842 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PIG" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE -5 TO WS-IV(1)
     MOVE -60 TO WS-IV(2)
     MOVE 9 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-PIG-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG anim pos 9 head.xrot" TO WS-NAME
     MOVE -0.08726646 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG anim pos 9 head.yrot" TO WS-NAME
     MOVE -1.04719752 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG anim pos 9 right_hind_leg.xrot" TO WS-NAME
     MOVE 1.342583587 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG anim pos 9 left_hind_leg.xrot" TO WS-NAME
     MOVE -1.342583587 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG anim pos 9 right_front_leg.xrot" TO WS-NAME
     MOVE -1.342583587 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG anim pos 9 left_front_leg.xrot" TO WS-NAME
     MOVE 1.342583587 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PIG_SADDLE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 20 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 1.5 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     CALL "EF4-PIG-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG_SADDLE anim pos 1.5 head.xrot" TO WS-NAME
     MOVE 0.34906584 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG_SADDLE anim pos 1.5 head.yrot" TO WS-NAME
     MOVE 0.17453292 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG_SADDLE anim pos 1.5 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.378623842 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG_SADDLE anim pos 1.5 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.378623842 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG_SADDLE anim pos 1.5 right_front_leg.xrot" TO WS-NAME
     MOVE -0.378623842 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG_SADDLE anim pos 1.5 left_front_leg.xrot" TO WS-NAME
     MOVE 0.378623842 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PIG_SADDLE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE -5 TO WS-IV(1)
     MOVE -60 TO WS-IV(2)
     MOVE 9 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-PIG-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG_SADDLE anim pos 9 head.xrot" TO WS-NAME
     MOVE -0.08726646 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG_SADDLE anim pos 9 head.yrot" TO WS-NAME
     MOVE -1.04719752 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG_SADDLE anim pos 9 right_hind_leg.xrot" TO WS-NAME
     MOVE 1.342583587 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG_SADDLE anim pos 9 left_hind_leg.xrot" TO WS-NAME
     MOVE -1.342583587 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG_SADDLE anim pos 9 right_front_leg.xrot" TO WS-NAME
     MOVE -1.342583587 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG_SADDLE anim pos 9 left_front_leg.xrot" TO WS-NAME
     MOVE 1.342583587 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "COLD_PIG" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 20 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 1.5 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     CALL "EF4-PIG-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 COLD_PIG anim pos 1.5 head.xrot" TO WS-NAME
     MOVE 0.34906584 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 COLD_PIG anim pos 1.5 head.yrot" TO WS-NAME
     MOVE 0.17453292 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 COLD_PIG anim pos 1.5 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.378623842 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 COLD_PIG anim pos 1.5 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.378623842 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 COLD_PIG anim pos 1.5 right_front_leg.xrot" TO WS-NAME
     MOVE -0.378623842 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 COLD_PIG anim pos 1.5 left_front_leg.xrot" TO WS-NAME
     MOVE 0.378623842 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "COLD_PIG" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE -5 TO WS-IV(1)
     MOVE -60 TO WS-IV(2)
     MOVE 9 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-PIG-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 COLD_PIG anim pos 9 head.xrot" TO WS-NAME
     MOVE -0.08726646 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 COLD_PIG anim pos 9 head.yrot" TO WS-NAME
     MOVE -1.04719752 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 COLD_PIG anim pos 9 right_hind_leg.xrot" TO WS-NAME
     MOVE 1.342583587 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 COLD_PIG anim pos 9 left_hind_leg.xrot" TO WS-NAME
     MOVE -1.342583587 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 COLD_PIG anim pos 9 right_front_leg.xrot" TO WS-NAME
     MOVE -1.342583587 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 COLD_PIG anim pos 9 left_front_leg.xrot" TO WS-NAME
     MOVE 1.342583587 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PIG_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 20 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 1.5 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     CALL "EF4-PIG-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG_BABY anim pos 1.5 head.xrot" TO WS-NAME
     MOVE 0.34906584 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG_BABY anim pos 1.5 head.yrot" TO WS-NAME
     MOVE 0.17453292 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG_BABY anim pos 1.5 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.378623842 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG_BABY anim pos 1.5 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.378623842 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG_BABY anim pos 1.5 right_front_leg.xrot" TO WS-NAME
     MOVE -0.378623842 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG_BABY anim pos 1.5 left_front_leg.xrot" TO WS-NAME
     MOVE 0.378623842 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "PIG_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE -5 TO WS-IV(1)
     MOVE -60 TO WS-IV(2)
     MOVE 9 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-PIG-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG_BABY anim pos 9 head.xrot" TO WS-NAME
     MOVE -0.08726646 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG_BABY anim pos 9 head.yrot" TO WS-NAME
     MOVE -1.04719752 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG_BABY anim pos 9 right_hind_leg.xrot" TO WS-NAME
     MOVE 1.342583587 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG_BABY anim pos 9 left_hind_leg.xrot" TO WS-NAME
     MOVE -1.342583587 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG_BABY anim pos 9 right_front_leg.xrot" TO WS-NAME
     MOVE -1.342583587 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "4.1 PIG_BABY anim pos 9 left_front_leg.xrot" TO WS-NAME
     MOVE 1.342583587 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-4§4 Pig: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-4§4 Pig: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-4-4.
