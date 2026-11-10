*> Acceptance test of docs/protocol/34-entity-models-4-farm-animals-equines.md section 3 (Mooshroom): 3.1 the layers (geometry of cow and cow_baby), variant enum with the clamping id map, the texture table, setupAnim as the cow,
*> 3.2 the mushroom layer (when it is drawn, the outline-only case, the pose operations of the three block copies). Mesh rows are the tables of 2.3 reached through the layer ids of 3.1.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-4-3.
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
     MOVE "MOOSHROOM" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer MOOSHROOM is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§3 Mooshroom 3.1 MOOSHROOM" TO CK-PREFIX
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
     MOVE "3.1 MOOSHROOM: parts below the root" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 MOOSHROOM: cuboids" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 MOOSHROOM: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 MOOSHROOM: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "MOOSHROOM_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer MOOSHROOM_BABY is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§3 Mooshroom 3.1 MOOSHROOM_BABY" TO CK-PREFIX
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
     MOVE "3.1 MOOSHROOM_BABY: parts below the root" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 MOOSHROOM_BABY: cuboids" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 MOOSHROOM_BABY: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 MOOSHROOM_BABY: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "WARM_COW_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer WARM_COW_BABY is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§3 Mooshroom 3.1 WARM_COW_BABY" TO CK-PREFIX
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
     MOVE "3.1 WARM_COW_BABY: parts below the root" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 WARM_COW_BABY: cuboids" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 WARM_COW_BABY: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 WARM_COW_BABY: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "COLD_COW_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer COLD_COW_BABY is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§3 Mooshroom 3.1 COLD_COW_BABY" TO CK-PREFIX
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
     MOVE "3.1 COLD_COW_BABY: parts below the root" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 COLD_COW_BABY: cuboids" TO WS-NAME
     MOVE 9 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 COLD_COW_BABY: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 COLD_COW_BABY: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF4-MOOSHROOM-VARIANT" USING WS-IN WS-OUT
     MOVE "3.1 variant id 0 clamps to ordinal" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF4-MOOSHROOM-VARIANT" USING WS-IN WS-OUT
     MOVE "3.1 variant id 1 clamps to ordinal" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     CALL "EF4-MOOSHROOM-VARIANT" USING WS-IN WS-OUT
     MOVE "3.1 variant id 2 clamps to ordinal" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     CALL "EF4-MOOSHROOM-VARIANT" USING WS-IN WS-OUT
     MOVE "3.1 variant id 5 clamps to ordinal" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE -1 TO WS-IV(1)
     CALL "EF4-MOOSHROOM-VARIANT" USING WS-IN WS-OUT
     MOVE "3.1 variant id -1 clamps to ordinal" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-MOOSHROOM-TEXTURE" USING WS-IN WS-X120
     MOVE "3.1 texture variant 0 baby 0" TO WS-NAME
     MOVE "textures/entity/cow/mooshroom_red.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-MOOSHROOM-TEXTURE" USING WS-IN WS-X120
     MOVE "3.1 texture variant 0 baby 1" TO WS-NAME
     MOVE "textures/entity/cow/mooshroom_red_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-MOOSHROOM-TEXTURE" USING WS-IN WS-X120
     MOVE "3.1 texture variant 1 baby 0" TO WS-NAME
     MOVE "textures/entity/cow/mooshroom_brown.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-MOOSHROOM-TEXTURE" USING WS-IN WS-X120
     MOVE "3.1 texture variant 1 baby 1" TO WS-NAME
     MOVE "textures/entity/cow/mooshroom_brown_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 0 TO WS-IV(1)
     CALL "EF4-MOOSHROOM-BLOCK" USING WS-IN WS-X120
     MOVE "3.1 variant 0 block state" TO WS-NAME
     MOVE "red_mushroom_block" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 1 TO WS-IV(1)
     CALL "EF4-MOOSHROOM-BLOCK" USING WS-IN WS-X120
     MOVE "3.1 variant 1 block state" TO WS-NAME
     MOVE "brown_mushroom_block" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-MUSHROOM-DRAW" USING WS-IN WS-OUT
     MOVE "3.2 baby 0 model 0 invisible 0 glowing 0 draw and outline-only [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 baby 0 model 0 invisible 0 glowing 0 draw and outline-only [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-MUSHROOM-DRAW" USING WS-IN WS-OUT
     MOVE "3.2 baby 0 model 0 invisible 0 glowing 1 draw and outline-only [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 baby 0 model 0 invisible 0 glowing 1 draw and outline-only [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-MUSHROOM-DRAW" USING WS-IN WS-OUT
     MOVE "3.2 baby 0 model 0 invisible 1 glowing 0 draw and outline-only [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 baby 0 model 0 invisible 1 glowing 0 draw and outline-only [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-MUSHROOM-DRAW" USING WS-IN WS-OUT
     MOVE "3.2 baby 0 model 0 invisible 1 glowing 1 draw and outline-only [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 baby 0 model 0 invisible 1 glowing 1 draw and outline-only [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-MUSHROOM-DRAW" USING WS-IN WS-OUT
     MOVE "3.2 baby 0 model 1 invisible 0 glowing 0 draw and outline-only [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 baby 0 model 1 invisible 0 glowing 0 draw and outline-only [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-MUSHROOM-DRAW" USING WS-IN WS-OUT
     MOVE "3.2 baby 0 model 1 invisible 0 glowing 1 draw and outline-only [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 baby 0 model 1 invisible 0 glowing 1 draw and outline-only [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-MUSHROOM-DRAW" USING WS-IN WS-OUT
     MOVE "3.2 baby 0 model 1 invisible 1 glowing 0 draw and outline-only [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 baby 0 model 1 invisible 1 glowing 0 draw and outline-only [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-MUSHROOM-DRAW" USING WS-IN WS-OUT
     MOVE "3.2 baby 0 model 1 invisible 1 glowing 1 draw and outline-only [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 baby 0 model 1 invisible 1 glowing 1 draw and outline-only [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-MUSHROOM-DRAW" USING WS-IN WS-OUT
     MOVE "3.2 baby 1 model 0 invisible 0 glowing 0 draw and outline-only [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 baby 1 model 0 invisible 0 glowing 0 draw and outline-only [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-MUSHROOM-DRAW" USING WS-IN WS-OUT
     MOVE "3.2 baby 1 model 0 invisible 0 glowing 1 draw and outline-only [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 baby 1 model 0 invisible 0 glowing 1 draw and outline-only [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-MUSHROOM-DRAW" USING WS-IN WS-OUT
     MOVE "3.2 baby 1 model 0 invisible 1 glowing 0 draw and outline-only [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 baby 1 model 0 invisible 1 glowing 0 draw and outline-only [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-MUSHROOM-DRAW" USING WS-IN WS-OUT
     MOVE "3.2 baby 1 model 0 invisible 1 glowing 1 draw and outline-only [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 baby 1 model 0 invisible 1 glowing 1 draw and outline-only [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-MUSHROOM-DRAW" USING WS-IN WS-OUT
     MOVE "3.2 baby 1 model 1 invisible 0 glowing 0 draw and outline-only [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 baby 1 model 1 invisible 0 glowing 0 draw and outline-only [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-MUSHROOM-DRAW" USING WS-IN WS-OUT
     MOVE "3.2 baby 1 model 1 invisible 0 glowing 1 draw and outline-only [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 baby 1 model 1 invisible 0 glowing 1 draw and outline-only [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     CALL "EF4-MUSHROOM-DRAW" USING WS-IN WS-OUT
     MOVE "3.2 baby 1 model 1 invisible 1 glowing 0 draw and outline-only [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 baby 1 model 1 invisible 1 glowing 0 draw and outline-only [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     CALL "EF4-MUSHROOM-DRAW" USING WS-IN WS-OUT
     MOVE "3.2 baby 1 model 1 invisible 1 glowing 1 draw and outline-only [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 baby 1 model 1 invisible 1 glowing 1 draw and outline-only [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF4-MUSHROOM-OPS" USING WS-IN WS-OUT
     MOVE "3.2 copy 1 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [1]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 1 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 1 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [3]" TO WS-NAME
     MOVE 0.2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 1 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [4]" TO WS-NAME
     MOVE -0.35 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 1 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [5]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 1 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 1 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [7]" TO WS-NAME
     MOVE -48 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 1 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 1 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 1 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 1 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [11]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 1 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [12]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 1 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [13]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 1 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 1 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [15]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 1 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [16]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 1 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [17]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     CALL "EF4-MUSHROOM-OPS" USING WS-IN WS-OUT
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [1]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [3]" TO WS-NAME
     MOVE 0.2 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [4]" TO WS-NAME
     MOVE -0.35 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [5]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [7]" TO WS-NAME
     MOVE 42 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [10]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [11]" TO WS-NAME
     MOVE 0.1 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [13]" TO WS-NAME
     MOVE -0.6 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [14]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [15]" TO WS-NAME
     MOVE -48 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [16]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [18]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [19]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [20]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [21]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [22]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [23]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [24]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 2 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [25]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     CALL "EF4-MUSHROOM-OPS" USING WS-IN WS-OUT
     MOVE "3.2 copy 3 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 3 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [2]" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 3 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 3 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 3 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 3 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [6]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 3 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 3 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [8]" TO WS-NAME
     MOVE -0.7 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 3 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [9]" TO WS-NAME
     MOVE -0.2 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 3 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [10]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 3 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [11]" TO WS-NAME
     MOVE -78 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 3 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 3 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 3 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [14]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 3 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [15]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 3 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [16]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 3 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [17]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 3 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [18]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 3 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [19]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 3 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [20]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 copy 3 pose operations (count, then code 1 translate 2 rotate Y deg 3 scale 4 head transform and 3 values each) [21]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 9 TO WS-IV(1)
     CALL "EF4-MUSHROOM-OPS" USING WS-IN WS-OUT
     MOVE "3.2 a copy number outside 1..3 has no operations (coverage-only addition)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "MOOSHROOM" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 8 TO WS-IV(1)
     MOVE -14 TO WS-IV(2)
     MOVE 3.1 TO WS-IV(3)
     MOVE 0.4 TO WS-IV(4)
     CALL "EF4-COW-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 0.139626336 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE -0.244346088 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE -0.265733677 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE -0.265733677 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE 0.265733677 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE 0.265733677 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "MOOSHROOM_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 8 TO WS-IV(1)
     MOVE -14 TO WS-IV(2)
     MOVE 3.1 TO WS-IV(3)
     MOVE 0.4 TO WS-IV(4)
     CALL "EF4-COW-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.xrot" TO WS-NAME
     MOVE 0.139626336 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "head.yrot" TO WS-NAME
     MOVE -0.244346088 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_hind_leg.xrot" TO WS-NAME
     MOVE -0.265733677 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_front_leg.xrot" TO WS-NAME
     MOVE -0.265733677 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_hind_leg.xrot" TO WS-NAME
     MOVE 0.265733677 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_front_leg.xrot" TO WS-NAME
     MOVE 0.265733677 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-4§3 Mooshroom: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-4§3 Mooshroom: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-4-3.
