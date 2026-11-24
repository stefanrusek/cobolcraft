*> Entity models part 4 section 8 (Equines): the meshes of the horse, armor, saddle, baby, donkey and mule layers and their unscaled aliases (8.6), registrations and textures (8.2, 8.5), setupAnim (8.3, 8.4).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF4-EQUINE-REG entity(X(24)) saddle-layer-type(out X(40)) saddle-scale(out FLOAT-LONG) (8.2); EF4-EQUINE-TEXTURE entity baby path(out X(120)) for donkey, mule, skeleton_horse, zombie_horse (8.2);
*>   EF4-HORSE-VARIANT IN(id) OUT(ordinal, wraps modulo 7); EF4-HORSE-TEXTURE IN(ordinal, baby) path(out X(120)); EF4-HORSE-MARKING-ID IN(id) OUT(ordinal, wraps modulo 5);
*>   EF4-HORSE-MARKING IN(ordinal, baby) path(out X(120), spaces for none); EF4-MARKING-DRAW IN(texture present, invisible) OUT(drawn) (8.5).
*>   EF4-EQUINE-ANIM EMM-MODEL state(1 xRot deg, 2 yRot deg, 3 walk position, 4 walk speed, 5 eat, 6 stand, 7 feeding, 8 ageInTicks, 9 ageScale, 10 animate tail, 11 in water, 12 hook kind (0 adult horse, donkey and saddle models,
*>   1 baby horse, 2 baby donkey), 13 has chest, 14 is ridden, 15 donkey model (toggles the chests), 16 saddle model (toggles the reins)): the twelve steps of 8.3 and the overrides of 8.4, reset first.
*>   Pivot offsets of the scaled layers are carried in the root children (EMD-SCALE-ROOT), so every additive offset and constant of 8.3 is multiplied by the scale of the body part. IN(1) is overwritten by -30 for hook kind 2 (the shared state write).


 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-M-HORSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P body root 0 11 5 0 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 32 -5 -8 -17 10 10 22 0.05 0".
    05 FILLER PIC X(100) VALUE "P head_parts root 0 4 -12 0.5235988 0 0".
    05 FILLER PIC X(100) VALUE "C head_parts 0 35 -2.05 -6 -2 4 12 7 0 0".
    05 FILLER PIC X(100) VALUE "P head head_parts 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 13 -3 -11 -2 6 5 7 0 0".
    05 FILLER PIC X(100) VALUE "P mane head_parts 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C mane 56 36 -1 -11 5.01 2 16 2 0 0".
    05 FILLER PIC X(100) VALUE "P upper_mouth head_parts 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C upper_mouth 0 25 -2 -11 -7 4 5 5 0 0".
    05 FILLER PIC X(100) VALUE "P left_hind_leg root 4 14 7 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_hind_leg 48 21 -3 -1.01 -1 4 11 4 0 1".
    05 FILLER PIC X(100) VALUE "P right_hind_leg root -4 14 7 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_hind_leg 48 21 -1 -1.01 -1 4 11 4 0 0".
    05 FILLER PIC X(100) VALUE "P left_front_leg root 4 14 -10 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_front_leg 48 21 -3 -1.01 -1.9 4 11 4 0 1".
    05 FILLER PIC X(100) VALUE "P right_front_leg root -4 14 -10 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_front_leg 48 21 -1 -1.01 -1.9 4 11 4 0 0".
    05 FILLER PIC X(100) VALUE "P tail body 0 -5 2 0.5235988 0 0".
    05 FILLER PIC X(100) VALUE "C tail 42 36 -1.5 0 0 3 14 4 0 0".
    05 FILLER PIC X(100) VALUE "P left_ear head 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_ear 19 16 0.55 -13 4 2 3 1 -0.001 0".
    05 FILLER PIC X(100) VALUE "P right_ear head 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_ear 19 16 -2.55 -13 4 2 3 1 -0.001 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 56 TIMES.
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.
 01 WS-N                   BINARY-LONG VALUE 24.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO
     MOVE 64 TO MM-TEXW
     MOVE 64 TO MM-TEXH
     GOBACK.
 END PROGRAM EF4-M-HORSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-M-HORSE-ARMOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P body root 0 11 5 0 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 32 -5 -8 -17 10 10 22 0.05 0".
    05 FILLER PIC X(100) VALUE "P head_parts root 0 4 -12 0.5235988 0 0".
    05 FILLER PIC X(100) VALUE "C head_parts 0 35 -2.05 -6 -2 4 12 7 0 0".
    05 FILLER PIC X(100) VALUE "P head head_parts 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 13 -3 -11 -2 6 5 7 0.1 0".
    05 FILLER PIC X(100) VALUE "P mane head_parts 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C mane 56 36 -1 -11 5.01 2 16 2 0.1 0".
    05 FILLER PIC X(100) VALUE "P upper_mouth head_parts 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C upper_mouth 0 25 -2 -11 -7 4 5 5 0.1 0".
    05 FILLER PIC X(100) VALUE "P left_hind_leg root 4 14 7 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_hind_leg 48 21 -3 -1.01 -1 4 11 4 0.1 1".
    05 FILLER PIC X(100) VALUE "P right_hind_leg root -4 14 7 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_hind_leg 48 21 -1 -1.01 -1 4 11 4 0.1 0".
    05 FILLER PIC X(100) VALUE "P left_front_leg root 4 14 -10 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_front_leg 48 21 -3 -1.01 -1.9 4 11 4 0.1 1".
    05 FILLER PIC X(100) VALUE "P right_front_leg root -4 14 -10 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_front_leg 48 21 -1 -1.01 -1.9 4 11 4 0.1 0".
    05 FILLER PIC X(100) VALUE "P tail body 0 -5 2 0.5235988 0 0".
    05 FILLER PIC X(100) VALUE "C tail 42 36 -1.5 0 0 3 14 4 0.1 0".
    05 FILLER PIC X(100) VALUE "P left_ear head 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_ear 19 16 0.55 -13 4 2 3 1 -0.001 0".
    05 FILLER PIC X(100) VALUE "P right_ear head 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_ear 19 16 -2.55 -13 4 2 3 1 -0.001 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 56 TIMES.
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.
 01 WS-N                   BINARY-LONG VALUE 24.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO
     MOVE 64 TO MM-TEXW
     MOVE 64 TO MM-TEXH
     GOBACK.
 END PROGRAM EF4-M-HORSE-ARMOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-M-HORSE-SADDLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P body root 0 11 5 0 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 32 -5 -8 -17 10 10 22 0.05 0".
    05 FILLER PIC X(100) VALUE "P head_parts root 0 4 -12 0.5235988 0 0".
    05 FILLER PIC X(100) VALUE "C head_parts 0 35 -2.05 -6 -2 4 12 7 0 0".
    05 FILLER PIC X(100) VALUE "P head head_parts 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 13 -3 -11 -2 6 5 7 0 0".
    05 FILLER PIC X(100) VALUE "P mane head_parts 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C mane 56 36 -1 -11 5.01 2 16 2 0 0".
    05 FILLER PIC X(100) VALUE "P upper_mouth head_parts 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C upper_mouth 0 25 -2 -11 -7 4 5 5 0 0".
    05 FILLER PIC X(100) VALUE "P left_hind_leg root 4 14 7 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_hind_leg 48 21 -3 -1.01 -1 4 11 4 0 1".
    05 FILLER PIC X(100) VALUE "P right_hind_leg root -4 14 7 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_hind_leg 48 21 -1 -1.01 -1 4 11 4 0 0".
    05 FILLER PIC X(100) VALUE "P left_front_leg root 4 14 -10 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_front_leg 48 21 -3 -1.01 -1.9 4 11 4 0 1".
    05 FILLER PIC X(100) VALUE "P right_front_leg root -4 14 -10 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_front_leg 48 21 -1 -1.01 -1.9 4 11 4 0 0".
    05 FILLER PIC X(100) VALUE "P tail body 0 -5 2 0.5235988 0 0".
    05 FILLER PIC X(100) VALUE "C tail 42 36 -1.5 0 0 3 14 4 0 0".
    05 FILLER PIC X(100) VALUE "P left_ear head 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_ear 19 16 0.55 -13 4 2 3 1 -0.001 0".
    05 FILLER PIC X(100) VALUE "P right_ear head 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_ear 19 16 -2.55 -13 4 2 3 1 -0.001 0".
    05 FILLER PIC X(100) VALUE "P saddle body 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C saddle 26 0 -5 -8 -9 10 9 9 0.5 0".
    05 FILLER PIC X(100) VALUE "P left_saddle_mouth head_parts 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_saddle_mouth 29 5 2 -9 -6 1 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P right_saddle_mouth head_parts 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_saddle_mouth 29 5 -3 -9 -6 1 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P left_saddle_line head_parts 0 0 0 -0.5235988 0 0".
    05 FILLER PIC X(100) VALUE "C left_saddle_line 32 2 3.1 -6 -8 0 3 16 0 0".
    05 FILLER PIC X(100) VALUE "P right_saddle_line head_parts 0 0 0 -0.5235988 0 0".
    05 FILLER PIC X(100) VALUE "C right_saddle_line 32 2 -3.1 -6 -8 0 3 16 0 0".
    05 FILLER PIC X(100) VALUE "P head_saddle head_parts 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C head_saddle 1 1 -3 -11 -1.9 6 5 6 0.22 0".
    05 FILLER PIC X(100) VALUE "P mouth_saddle_wrap head_parts 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C mouth_saddle_wrap 19 0 -2 -11 -4 4 5 2 0.2 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 42 TIMES.
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.
 01 WS-N                   BINARY-LONG VALUE 38.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO
     MOVE 64 TO MM-TEXW
     MOVE 64 TO MM-TEXH
     GOBACK.
 END PROGRAM EF4-M-HORSE-SADDLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-M-HORSE-BABY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P body root 0 12.5 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 13 -4 -3.5 -7 8 7 14 0 0".
    05 FILLER PIC X(100) VALUE "P tail body 0 -1 7 -0.7418 0 0".
    05 FILLER PIC X(100) VALUE "C tail 24 34 -1.5 -1.5 -1 3 3 8 0 0".
    05 FILLER PIC X(100) VALUE "P left_hind_leg root 2.4 16 5.4 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_hind_leg 12 46 -1.5 -1 -1.5 3 9 3 0 0".
    05 FILLER PIC X(100) VALUE "P right_hind_leg root -2.4 16 5.4 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_hind_leg 0 46 -1.5 -1 -1.5 3 9 3 0 0".
    05 FILLER PIC X(100) VALUE "P left_front_leg root 2.4 16 -5.4 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_front_leg 12 34 -1.5 -1 -1.5 3 9 3 0 0".
    05 FILLER PIC X(100) VALUE "P right_front_leg root -2.4 16 -5.4 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_front_leg 0 34 -1.5 -1 -1.5 3 9 3 0 0".
    05 FILLER PIC X(100) VALUE "P head_parts root 0 10 -6 0.6109 0 0".
    05 FILLER PIC X(100) VALUE "C head_parts 30 0 -2 -6 -2 4 8 4 0 0".
    05 FILLER PIC X(100) VALUE "P head head_parts 0 -6.0516 -0.2951 0 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 0 -3 -3.9484 -6.705 6 4 9 0 0".
    05 FILLER PIC X(100) VALUE "P left_ear head 2 -4.2484 1.9451 0 0 0.2618".
    05 FILLER PIC X(100) VALUE "C left_ear 0 4 -1 -2.5 -0.8 2 3 1 0 0".
    05 FILLER PIC X(100) VALUE "P right_ear head -2 -4.2484 1.645 0 0 -0.2618".
    05 FILLER PIC X(100) VALUE "C right_ear 0 0 -1 -2.5 -0.5 2 3 1 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 60 TIMES.
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.
 01 WS-N                   BINARY-LONG VALUE 20.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO
     MOVE 64 TO MM-TEXW
     MOVE 64 TO MM-TEXH
     GOBACK.
 END PROGRAM EF4-M-HORSE-BABY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-M-DONKEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P body root 0 11 5 0 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 32 -5 -8 -17 10 10 22 0.05 0".
    05 FILLER PIC X(100) VALUE "P head_parts root 0 4 -12 0.5235988 0 0".
    05 FILLER PIC X(100) VALUE "C head_parts 0 35 -2.05 -6 -2 4 12 7 0 0".
    05 FILLER PIC X(100) VALUE "P head head_parts 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 13 -3 -11 -2 6 5 7 0 0".
    05 FILLER PIC X(100) VALUE "P mane head_parts 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C mane 56 36 -1 -11 5.01 2 16 2 0 0".
    05 FILLER PIC X(100) VALUE "P upper_mouth head_parts 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C upper_mouth 0 25 -2 -11 -7 4 5 5 0 0".
    05 FILLER PIC X(100) VALUE "P left_hind_leg root 4 14 7 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_hind_leg 48 21 -3 -1.01 -1 4 11 4 0 1".
    05 FILLER PIC X(100) VALUE "P right_hind_leg root -4 14 7 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_hind_leg 48 21 -1 -1.01 -1 4 11 4 0 0".
    05 FILLER PIC X(100) VALUE "P left_front_leg root 4 14 -10 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_front_leg 48 21 -3 -1.01 -1.9 4 11 4 0 1".
    05 FILLER PIC X(100) VALUE "P right_front_leg root -4 14 -10 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_front_leg 48 21 -1 -1.01 -1.9 4 11 4 0 0".
    05 FILLER PIC X(100) VALUE "P tail body 0 -5 2 0.5235988 0 0".
    05 FILLER PIC X(100) VALUE "C tail 42 36 -1.5 0 0 3 14 4 0 0".
    05 FILLER PIC X(100) VALUE "P left_ear head 1.25 -10 4 0.2617994 0 0.2617994".
    05 FILLER PIC X(100) VALUE "C left_ear 0 12 -1 -7 0 2 7 1 0 0".
    05 FILLER PIC X(100) VALUE "P right_ear head -1.25 -10 4 0.2617994 0 -0.2617994".
    05 FILLER PIC X(100) VALUE "C right_ear 0 12 -1 -7 0 2 7 1 0 0".
    05 FILLER PIC X(100) VALUE "P left_chest body 6 -8 0 0 -1.5707964 0".
    05 FILLER PIC X(100) VALUE "C left_chest 26 21 -4 0 -2 8 8 3 0 0".
    05 FILLER PIC X(100) VALUE "P right_chest body -6 -8 0 0 1.5707964 0".
    05 FILLER PIC X(100) VALUE "C right_chest 26 21 -4 0 -2 8 8 3 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 52 TIMES.
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.
 01 WS-N                   BINARY-LONG VALUE 28.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO
     MOVE 64 TO MM-TEXW
     MOVE 64 TO MM-TEXH
     GOBACK.
 END PROGRAM EF4-M-DONKEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-M-DONKEY-SADDLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P body root 0 11 5 0 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 32 -5 -8 -17 10 10 22 0.05 0".
    05 FILLER PIC X(100) VALUE "P head_parts root 0 4 -12 0.5235988 0 0".
    05 FILLER PIC X(100) VALUE "C head_parts 0 35 -2.05 -6 -2 4 12 7 0 0".
    05 FILLER PIC X(100) VALUE "P head head_parts 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 13 -3 -11 -2 6 5 7 0 0".
    05 FILLER PIC X(100) VALUE "P mane head_parts 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C mane 56 36 -1 -11 5.01 2 16 2 0 0".
    05 FILLER PIC X(100) VALUE "P upper_mouth head_parts 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C upper_mouth 0 25 -2 -11 -7 4 5 5 0 0".
    05 FILLER PIC X(100) VALUE "P left_hind_leg root 4 14 7 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_hind_leg 48 21 -3 -1.01 -1 4 11 4 0 1".
    05 FILLER PIC X(100) VALUE "P right_hind_leg root -4 14 7 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_hind_leg 48 21 -1 -1.01 -1 4 11 4 0 0".
    05 FILLER PIC X(100) VALUE "P left_front_leg root 4 14 -10 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_front_leg 48 21 -3 -1.01 -1.9 4 11 4 0 1".
    05 FILLER PIC X(100) VALUE "P right_front_leg root -4 14 -10 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_front_leg 48 21 -1 -1.01 -1.9 4 11 4 0 0".
    05 FILLER PIC X(100) VALUE "P tail body 0 -5 2 0.5235988 0 0".
    05 FILLER PIC X(100) VALUE "C tail 42 36 -1.5 0 0 3 14 4 0 0".
    05 FILLER PIC X(100) VALUE "P left_ear head 1.25 -10 4 0.2617994 0 0.2617994".
    05 FILLER PIC X(100) VALUE "C left_ear 0 12 -1 -7 0 2 7 1 0 0".
    05 FILLER PIC X(100) VALUE "P right_ear head -1.25 -10 4 0.2617994 0 -0.2617994".
    05 FILLER PIC X(100) VALUE "C right_ear 0 12 -1 -7 0 2 7 1 0 0".
    05 FILLER PIC X(100) VALUE "P saddle body 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C saddle 26 0 -5 -8 -9 10 9 9 0.5 0".
    05 FILLER PIC X(100) VALUE "P left_saddle_mouth head_parts 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_saddle_mouth 29 5 2 -9 -6 1 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P right_saddle_mouth head_parts 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_saddle_mouth 29 5 -3 -9 -6 1 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P left_saddle_line head_parts 0 0 0 -0.5235988 0 0".
    05 FILLER PIC X(100) VALUE "C left_saddle_line 32 2 3.1 -6 -8 0 3 16 0 0".
    05 FILLER PIC X(100) VALUE "P right_saddle_line head_parts 0 0 0 -0.5235988 0 0".
    05 FILLER PIC X(100) VALUE "C right_saddle_line 32 2 -3.1 -6 -8 0 3 16 0 0".
    05 FILLER PIC X(100) VALUE "P head_saddle head_parts 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C head_saddle 1 1 -3 -11 -1.9 6 5 6 0.22 0".
    05 FILLER PIC X(100) VALUE "P mouth_saddle_wrap head_parts 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C mouth_saddle_wrap 19 0 -2 -11 -4 4 5 2 0.2 0".
    05 FILLER PIC X(100) VALUE "P left_chest body 6 -8 0 0 -1.5707964 0".
    05 FILLER PIC X(100) VALUE "C left_chest 26 21 -4 0 -2 8 8 3 0 0".
    05 FILLER PIC X(100) VALUE "P right_chest body -6 -8 0 0 1.5707964 0".
    05 FILLER PIC X(100) VALUE "C right_chest 26 21 -4 0 -2 8 8 3 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 38 TIMES.
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.
 01 WS-N                   BINARY-LONG VALUE 42.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO
     MOVE 64 TO MM-TEXW
     MOVE 64 TO MM-TEXH
     GOBACK.
 END PROGRAM EF4-M-DONKEY-SADDLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-M-DONKEY-BABY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P body root 1 14 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 13 -5 -3 -7 8 6 14 0 0".
    05 FILLER PIC X(100) VALUE "P tail body 0 -1.5 6.5 0 0 0".
    05 FILLER PIC X(100) VALUE "P tail_r1 tail 0 0 0 -0.7418 0 0".
    05 FILLER PIC X(100) VALUE "C tail_r1 24 33 -2.5 -1 -0.5 3 3 8 0 0".
    05 FILLER PIC X(100) VALUE "P left_hind_leg body 2.25 3.5 5.25 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_hind_leg 12 44 -2.5 -1.5 -1.5 3 8 3 0 0".
    05 FILLER PIC X(100) VALUE "P right_hind_leg body -2.4 3.5 5.4 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_hind_leg 0 44 -2.5 -1.5 -1.5 3 8 3 0 0".
    05 FILLER PIC X(100) VALUE "P left_front_leg body 2.4 3.5 -5.3 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_front_leg 12 33 -2.5 -1.5 -1.5 3 8 3 0 0".
    05 FILLER PIC X(100) VALUE "P right_front_leg body -2.4 3.5 -5.4 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_front_leg 0 33 -2.5 -1.5 -1.5 3 8 3 0 0".
    05 FILLER PIC X(100) VALUE "P head_parts body 0 -3 -5 0 0 0".
    05 FILLER PIC X(100) VALUE "P neck_r1 head_parts 0 0 0 0.3927 0 0".
    05 FILLER PIC X(100) VALUE "C neck_r1 30 9 -3 -6 -3 4 8 4 0 0".
    05 FILLER PIC X(100) VALUE "P head head_parts 0 -5 -3 0 0 0".
    05 FILLER PIC X(100) VALUE "P head_r1 head 0 -1 1 0.3927 0 0".
    05 FILLER PIC X(100) VALUE "C head_r1 0 0 -4 -3.6 -8.4 6 4 9 0 0".
    05 FILLER PIC X(100) VALUE "P left_ear head 2 -3.5 -1 0.48 0 0.48".
    05 FILLER PIC X(100) VALUE "C left_ear 0 0 -2 -6.5 -0.3 2 7 1 0 0".
    05 FILLER PIC X(100) VALUE "P right_ear head -2 -3.5 -1 0.48 0 -0.48".
    05 FILLER PIC X(100) VALUE "C right_ear 22 0 -2 -6.5 -0.3 2 7 1 0 1".
    05 FILLER PIC X(100) VALUE "P right_chest body -1 10 0 0 0 0".
    05 FILLER PIC X(100) VALUE "P left_chest body -1 10 0 0 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 55 TIMES.
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.
 01 WS-N                   BINARY-LONG VALUE 25.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO
     MOVE 64 TO MM-TEXW
     MOVE 64 TO MM-TEXH
     GOBACK.
 END PROGRAM EF4-M-DONKEY-BABY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-EQUINE-REG.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENT                  PIC X(24).
 01 L-TYPE                 PIC X(40).
 01 L-SCALE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-ENT L-TYPE L-SCALE.
     MOVE SPACES TO L-TYPE
     MOVE 1 TO L-SCALE
     EVALUATE L-ENT
         WHEN "horse" MOVE "horse_saddle" TO L-TYPE MOVE 1.1 TO L-SCALE
         WHEN "donkey" MOVE "donkey_saddle" TO L-TYPE MOVE 0.87 TO L-SCALE
         WHEN "mule" MOVE "mule_saddle" TO L-TYPE MOVE 0.92 TO L-SCALE
         WHEN "skeleton_horse" MOVE "skeleton_horse_saddle" TO L-TYPE
         WHEN "zombie_horse" MOVE "zombie_horse_saddle" TO L-TYPE
     END-EVALUATE
     GOBACK.
 END PROGRAM EF4-EQUINE-REG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-EQUINE-TEXTURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BASE                PIC X(60).
 LINKAGE SECTION.
 01 L-ENT                  PIC X(24).
 01 L-BABY                 BINARY-LONG.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-ENT L-BABY L-PATH.
     MOVE SPACES TO L-PATH WS-BASE
     EVALUATE L-ENT
         WHEN "donkey" MOVE "textures/entity/horse/donkey" TO WS-BASE
         WHEN "mule" MOVE "textures/entity/horse/mule" TO WS-BASE
         WHEN "skeleton_horse" MOVE "textures/entity/horse/horse_skeleton" TO WS-BASE
         WHEN "zombie_horse" MOVE "textures/entity/horse/horse_zombie" TO WS-BASE
     END-EVALUATE
     IF L-BABY NOT = 0
         STRING FUNCTION TRIM(WS-BASE) "_baby.png" DELIMITED BY SIZE INTO L-PATH
     ELSE
         STRING FUNCTION TRIM(WS-BASE) ".png" DELIMITED BY SIZE INTO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EF4-EQUINE-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-HORSE-VARIANT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = FUNCTION MOD(L-I(1), 7)
     GOBACK.
 END PROGRAM EF4-HORSE-VARIANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-HORSE-TEXTURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES.
    05 FILLER PIC X(10) VALUE "white".
    05 FILLER PIC X(10) VALUE "creamy".
    05 FILLER PIC X(10) VALUE "chestnut".
    05 FILLER PIC X(10) VALUE "brown".
    05 FILLER PIC X(10) VALUE "black".
    05 FILLER PIC X(10) VALUE "gray".
    05 FILLER PIC X(10) VALUE "darkbrown".
 01 WS-NAMES-R REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(10) OCCURS 7 TIMES.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     COMPUTE WS-K = FUNCTION MOD(L-I(1), 7) + 1
     MOVE SPACES TO L-PATH
     IF L-I(2) NOT = 0
         STRING "textures/entity/horse/horse_" FUNCTION TRIM(WS-NAME(WS-K)) "_baby.png" DELIMITED BY SIZE INTO L-PATH
     ELSE
         STRING "textures/entity/horse/horse_" FUNCTION TRIM(WS-NAME(WS-K)) ".png" DELIMITED BY SIZE INTO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EF4-HORSE-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-HORSE-MARKING-ID.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = FUNCTION MOD(L-I(1), 5)
     GOBACK.
 END PROGRAM EF4-HORSE-MARKING-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-HORSE-MARKING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES.
    05 FILLER PIC X(12) VALUE SPACES.
    05 FILLER PIC X(12) VALUE "white".
    05 FILLER PIC X(12) VALUE "whitefield".
    05 FILLER PIC X(12) VALUE "whitedots".
    05 FILLER PIC X(12) VALUE "blackdots".
 01 WS-NAMES-R REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(12) OCCURS 5 TIMES.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     COMPUTE WS-K = FUNCTION MOD(L-I(1), 5) + 1
     MOVE SPACES TO L-PATH
     IF WS-K > 1
         IF L-I(2) NOT = 0
             STRING "textures/entity/horse/horse_markings_" FUNCTION TRIM(WS-NAME(WS-K)) "_baby.png" DELIMITED BY SIZE INTO L-PATH
         ELSE
             STRING "textures/entity/horse/horse_markings_" FUNCTION TRIM(WS-NAME(WS-K)) ".png" DELIMITED BY SIZE INTO L-PATH
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EF4-HORSE-MARKING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-MARKING-DRAW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) NOT = 0 AND L-I(2) = 0
         MOVE 1 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EF4-MARKING-DRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-EQUINE-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-BODY                BINARY-LONG.
 01 WS-HP                  BINARY-LONG.
 01 WS-LHL                 BINARY-LONG.
 01 WS-RHL                 BINARY-LONG.
 01 WS-LFL                 BINARY-LONG.
 01 WS-RFL                 BINARY-LONG.
 01 WS-TAIL                BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-SC                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-WATER               FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-LEG                 FLOAT-LONG.
 01 WS-MAX                 FLOAT-LONG.
 01 WS-GRAZ                FLOAT-LONG.
 01 WS-LSY                 FLOAT-LONG.
 01 WS-LSZ                 FLOAT-LONG.
 01 WS-ANG                 FLOAT-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-STAND               FLOAT-LONG.
 01 WS-EAT                 FLOAT-LONG.
 01 WS-P2                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "body" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-BODY
     MOVE "head_parts" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-HP
     MOVE "left_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LHL
     MOVE "right_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RHL
     MOVE "left_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LFL
     MOVE "right_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RFL
     MOVE "tail" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-TAIL
     MOVE MM-YSCALE(WS-BODY) TO WS-SC
     MOVE L-I(5) TO WS-EAT
     MOVE L-I(6) TO WS-STAND
     MOVE L-I(1) TO WS-P2
     COMPUTE WS-YAW = L-I(2)
     IF WS-YAW > 20
         MOVE 20 TO WS-YAW
     END-IF
     IF WS-YAW < -20
         MOVE -20 TO WS-YAW
     END-IF
     COMPUTE WS-PITCH = L-I(1) * 0.017453292
     IF L-I(4) > 0.2
         COMPUTE WS-PITCH = WS-PITCH + FUNCTION COS(0.8 * L-I(3)) * 0.15 * L-I(4)
     END-IF
     MOVE 1 TO WS-WATER
     IF L-I(11) NOT = 0
         MOVE 0.2 TO WS-WATER
     END-IF
     COMPUTE WS-C = FUNCTION COS(WS-WATER * L-I(3) * 0.6662 + 3.141592653589793)
     COMPUTE WS-LEG = WS-C * 0.8 * L-I(4)
     MOVE WS-STAND TO WS-MAX
     IF WS-EAT > WS-MAX
         MOVE WS-EAT TO WS-MAX
     END-IF
     COMPUTE WS-GRAZ = (1 - WS-MAX) * ((0.5235988 + WS-PITCH) + L-I(7) * FUNCTION SIN(L-I(8)) * 0.05)
     COMPUTE MM-CXROT(WS-HP) = WS-STAND * (0.2617994 + WS-PITCH) + WS-EAT * (2.1816616 + FUNCTION SIN(L-I(8)) * 0.05) + WS-GRAZ
     COMPUTE MM-CYROT(WS-HP) = WS-STAND * WS-YAW * 0.017453292 + (1 - WS-MAX) * (WS-YAW * 0.017453292)
     EVALUATE L-I(12)
         WHEN 0
             COMPUTE MM-CY(WS-HP) = MM-CY(WS-HP) + WS-SC * ((0 + WS-STAND * (-8 - 0)) + WS-EAT * (7 - (0 + WS-STAND * (-8 - 0))))
             COMPUTE MM-CZ(WS-HP) = MM-CZ(WS-HP) + WS-STAND * (-4 * WS-SC - MM-CZ(WS-HP))
         WHEN 1
             COMPUTE MM-CY(WS-HP) = MM-CY(WS-HP) + ((0 + WS-STAND * (-2 - 0)) + WS-EAT * (2 - (0 + WS-STAND * (-2 - 0))))
             COMPUTE MM-CZ(WS-HP) = MM-CZ(WS-HP) + WS-STAND * (-4 - MM-CZ(WS-HP))
         WHEN OTHER
             COMPUTE MM-CY(WS-HP) = MM-CY(WS-HP) + WS-EAT * (-1.2 - MM-CY(WS-HP))
             COMPUTE MM-CZ(WS-HP) = MM-CZ(WS-HP) + WS-STAND * (-3.6 - MM-CZ(WS-HP))
     END-EVALUATE
     COMPUTE MM-CXROT(WS-BODY) = WS-STAND * (-0.7853982) + (1 - WS-STAND) * MM-XROT(WS-BODY)
     EVALUATE L-I(12)
         WHEN 0 COMPUTE WS-LSY = 12 * WS-SC COMPUTE WS-LSZ = 4 * WS-SC MOVE 0.2617994 TO WS-ANG MOVE -1.0471976 TO WS-X0
         WHEN 1 MOVE 4 TO WS-LSY MOVE 0 TO WS-LSZ MOVE 0.2617994 TO WS-ANG MOVE -1.0471976 TO WS-X0
         WHEN OTHER MOVE 1 TO WS-LSY MOVE 0.5 TO WS-LSZ MOVE 1.0471976 TO WS-ANG MOVE 0 TO WS-X0
     END-EVALUATE
     COMPUTE MM-CY(WS-LFL) = MM-CY(WS-LFL) - WS-LSY * WS-STAND
     COMPUTE MM-CZ(WS-LFL) = MM-CZ(WS-LFL) + WS-LSZ * WS-STAND
     MOVE MM-CY(WS-LFL) TO MM-CY(WS-RFL)
     MOVE MM-CZ(WS-LFL) TO MM-CZ(WS-RFL)
     COMPUTE WS-ANG = WS-ANG * WS-STAND
     COMPUTE WS-W = FUNCTION COS(L-I(8) * 0.6 + 3.141592653589793)
     COMPUTE MM-CXROT(WS-LHL) = WS-ANG - (WS-C * 0.5 * L-I(4)) * (1 - WS-STAND)
     COMPUTE MM-CXROT(WS-RHL) = WS-ANG + (WS-C * 0.5 * L-I(4)) * (1 - WS-STAND)
     COMPUTE MM-CXROT(WS-LFL) = (WS-X0 + WS-W) * WS-STAND + WS-LEG * (1 - WS-STAND)
     COMPUTE MM-CXROT(WS-RFL) = (WS-X0 - WS-W) * WS-STAND - WS-LEG * (1 - WS-STAND)
     IF L-I(12) = 2
         COMPUTE MM-CY(WS-LHL) = MM-CY(WS-LHL) + WS-STAND * (-0.3 - MM-CY(WS-LHL))
         COMPUTE MM-CY(WS-RHL) = MM-CY(WS-LHL) + WS-STAND * (-0.3 - MM-CY(WS-LHL))
     END-IF
     EVALUATE L-I(12)
         WHEN 0 MOVE 0 TO WS-TX
         WHEN 1 MOVE -1.5707964 TO WS-TX
         WHEN OTHER MOVE -0.7853982 TO WS-TX
     END-EVALUATE
     COMPUTE MM-CXROT(WS-TAIL) = WS-TX + 0.5235988 + L-I(4) * 0.75
     COMPUTE MM-CY(WS-TAIL) = MM-CY(WS-TAIL) + L-I(4) * L-I(9)
     COMPUTE MM-CZ(WS-TAIL) = MM-CZ(WS-TAIL) + L-I(4) * 2 * L-I(9)
     MOVE 0 TO MM-CYROT(WS-TAIL)
     IF L-I(10) NOT = 0
         COMPUTE MM-CYROT(WS-TAIL) = FUNCTION COS(L-I(8) * 0.7)
     END-IF
     IF L-I(15) NOT = 0
         MOVE "left_chest" TO WS-NAME
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
         MOVE 0 TO MM-VISIBLE(WS-P)
         IF L-I(13) NOT = 0
             MOVE 1 TO MM-VISIBLE(WS-P)
         END-IF
         MOVE "right_chest" TO WS-NAME
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
         MOVE 0 TO MM-VISIBLE(WS-P)
         IF L-I(13) NOT = 0
             MOVE 1 TO MM-VISIBLE(WS-P)
         END-IF
     END-IF
     IF L-I(16) NOT = 0
         MOVE "left_saddle_line" TO WS-NAME
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
         MOVE 0 TO MM-VISIBLE(WS-P)
         IF L-I(14) NOT = 0
             MOVE 1 TO MM-VISIBLE(WS-P)
         END-IF
         MOVE "right_saddle_line" TO WS-NAME
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
         MOVE 0 TO MM-VISIBLE(WS-P)
         IF L-I(14) NOT = 0
             MOVE 1 TO MM-VISIBLE(WS-P)
         END-IF
     END-IF
     IF L-I(12) = 2
         MOVE -30 TO L-I(1)
         COMPUTE WS-P2 = -30 * 0.017453292
         COMPUTE MM-CXROT(WS-HP) = WS-STAND * (0.2617994 + WS-P2) + WS-EAT * (1.5707964 + FUNCTION SIN(L-I(8)) * 0.05) + (1 - WS-MAX) * ((0.5235988 + WS-P2) + L-I(7) * FUNCTION SIN(L-I(8)) * 0.05)
     END-IF
     GOBACK.
 END PROGRAM EF4-EQUINE-ANIM.
