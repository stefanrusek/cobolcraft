*> Acceptance test of docs/protocol/34-entity-models-4-farm-animals-equines.md section 8 (Equines): 8.2 the renderer registrations (saddle layer type and scale, textures), 8.3 setupAnim of AbstractEquineModel with the hook constants of
*> the horse, baby horse and baby donkey (each of the twelve steps, the worked example 3 and 5 of the document), 8.4 chests, the baby donkey state write, the saddle reins, 8.5 variants, body textures and markings (with the wrapping id
*> maps), 8.6 the geometry of horse, horse_armor, horse_saddle, horse_baby, donkey, donkey_saddle, donkey_baby and the unscaled and mule aliases. Mesh rows are the tables of the document; formula values were worked by an
*> independent script. Pivot offsets of the scaled layers are carried in the pixels of the root's children (EMD-SCALE-ROOT), so an additive pivot offset is multiplied by the layer scale.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-4-8.
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
     MOVE "HORSE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer HORSE is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§8 Equines: horse, donkey, mule, skeleton horse, zombie horse 8.6 HORSE" TO CK-PREFIX
     MOVE "P body root 0.0 9.6984 5.5 0 0 0 1.1 1.1 1.1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 32 -5 -8 -17 10 10 22 0.05 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head_parts root 0.0 1.9984 -13.2 0.5235988 0 0 1.1 1.1 1.1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head_parts 0 35 -2.05 -6 -2 4 12 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 13 -3 -11 -2 6 5 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P mane head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C mane 56 36 -1 -11 5.01 2 16 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P upper_mouth head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C upper_mouth 0 25 -2 -11 -7 4 5 5 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 4.4 12.9984 7.7 0 0 0 1.1 1.1 1.1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 48 21 -3 -1.01 -1 4 11 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -4.4 12.9984 7.7 0 0 0 1.1 1.1 1.1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 48 21 -1 -1.01 -1 4 11 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 4.4 12.9984 -11.0 0 0 0 1.1 1.1 1.1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 48 21 -3 -1.01 -1.9 4 11 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -4.4 12.9984 -11.0 0 0 0 1.1 1.1 1.1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 48 21 -1 -1.01 -1.9 4 11 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P tail body 0 -5 2 0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C tail 42 36 -1.5 0 0 3 14 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_ear head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_ear 19 16 0.55 -13 4 2 3 1 -0.001 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_ear head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_ear 19 16 -2.55 -13 4 2 3 1 -0.001 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "8.6 HORSE: parts below the root" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 HORSE: cuboids" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 HORSE: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 HORSE: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "SKELETON_HORSE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer SKELETON_HORSE is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§8 Equines: horse, donkey, mule, skeleton horse, zombie horse 8.6 SKELETON_HORSE" TO CK-PREFIX
     MOVE "P body root 0 11 5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 32 -5 -8 -17 10 10 22 0.05 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head_parts root 0 4 -12 0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head_parts 0 35 -2.05 -6 -2 4 12 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 13 -3 -11 -2 6 5 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P mane head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C mane 56 36 -1 -11 5.01 2 16 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P upper_mouth head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C upper_mouth 0 25 -2 -11 -7 4 5 5 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 4 14 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 48 21 -3 -1.01 -1 4 11 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -4 14 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 48 21 -1 -1.01 -1 4 11 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 4 14 -10 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 48 21 -3 -1.01 -1.9 4 11 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -4 14 -10 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 48 21 -1 -1.01 -1.9 4 11 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P tail body 0 -5 2 0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C tail 42 36 -1.5 0 0 3 14 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_ear head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_ear 19 16 0.55 -13 4 2 3 1 -0.001 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_ear head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_ear 19 16 -2.55 -13 4 2 3 1 -0.001 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "8.6 SKELETON_HORSE: parts below the root" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 SKELETON_HORSE: cuboids" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 SKELETON_HORSE: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 SKELETON_HORSE: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_HORSE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer ZOMBIE_HORSE is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§8 Equines: horse, donkey, mule, skeleton horse, zombie horse 8.6 ZOMBIE_HORSE" TO CK-PREFIX
     MOVE "P body root 0 11 5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 32 -5 -8 -17 10 10 22 0.05 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head_parts root 0 4 -12 0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head_parts 0 35 -2.05 -6 -2 4 12 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 13 -3 -11 -2 6 5 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P mane head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C mane 56 36 -1 -11 5.01 2 16 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P upper_mouth head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C upper_mouth 0 25 -2 -11 -7 4 5 5 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 4 14 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 48 21 -3 -1.01 -1 4 11 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -4 14 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 48 21 -1 -1.01 -1 4 11 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 4 14 -10 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 48 21 -3 -1.01 -1.9 4 11 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -4 14 -10 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 48 21 -1 -1.01 -1.9 4 11 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P tail body 0 -5 2 0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C tail 42 36 -1.5 0 0 3 14 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_ear head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_ear 19 16 0.55 -13 4 2 3 1 -0.001 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_ear head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_ear 19 16 -2.55 -13 4 2 3 1 -0.001 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "8.6 ZOMBIE_HORSE: parts below the root" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 ZOMBIE_HORSE: cuboids" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 ZOMBIE_HORSE: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 ZOMBIE_HORSE: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "HORSE_ARMOR" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer HORSE_ARMOR is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§8 Equines: horse, donkey, mule, skeleton horse, zombie horse 8.6 HORSE_ARMOR" TO CK-PREFIX
     MOVE "P body root 0.0 9.6984 5.5 0 0 0 1.1 1.1 1.1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 32 -5 -8 -17 10 10 22 0.05 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head_parts root 0.0 1.9984 -13.2 0.5235988 0 0 1.1 1.1 1.1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head_parts 0 35 -2.05 -6 -2 4 12 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 13 -3 -11 -2 6 5 7 0.1 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P mane head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C mane 56 36 -1 -11 5.01 2 16 2 0.1 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P upper_mouth head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C upper_mouth 0 25 -2 -11 -7 4 5 5 0.1 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 4.4 12.9984 7.7 0 0 0 1.1 1.1 1.1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 48 21 -3 -1.01 -1 4 11 4 0.1 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -4.4 12.9984 7.7 0 0 0 1.1 1.1 1.1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 48 21 -1 -1.01 -1 4 11 4 0.1 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 4.4 12.9984 -11.0 0 0 0 1.1 1.1 1.1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 48 21 -3 -1.01 -1.9 4 11 4 0.1 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -4.4 12.9984 -11.0 0 0 0 1.1 1.1 1.1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 48 21 -1 -1.01 -1.9 4 11 4 0.1 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P tail body 0 -5 2 0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C tail 42 36 -1.5 0 0 3 14 4 0.1 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_ear head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_ear 19 16 0.55 -13 4 2 3 1 -0.001 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_ear head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_ear 19 16 -2.55 -13 4 2 3 1 -0.001 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "8.6 HORSE_ARMOR: parts below the root" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 HORSE_ARMOR: cuboids" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 HORSE_ARMOR: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 HORSE_ARMOR: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "UNDEAD_HORSE_ARMOR" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer UNDEAD_HORSE_ARMOR is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§8 Equines: horse, donkey, mule, skeleton horse, zombie horse 8.6 UNDEAD_HORSE_ARMOR" TO CK-PREFIX
     MOVE "P body root 0 11 5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 32 -5 -8 -17 10 10 22 0.05 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head_parts root 0 4 -12 0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head_parts 0 35 -2.05 -6 -2 4 12 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 13 -3 -11 -2 6 5 7 0.1 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P mane head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C mane 56 36 -1 -11 5.01 2 16 2 0.1 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P upper_mouth head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C upper_mouth 0 25 -2 -11 -7 4 5 5 0.1 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 4 14 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 48 21 -3 -1.01 -1 4 11 4 0.1 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -4 14 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 48 21 -1 -1.01 -1 4 11 4 0.1 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 4 14 -10 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 48 21 -3 -1.01 -1.9 4 11 4 0.1 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -4 14 -10 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 48 21 -1 -1.01 -1.9 4 11 4 0.1 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P tail body 0 -5 2 0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C tail 42 36 -1.5 0 0 3 14 4 0.1 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_ear head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_ear 19 16 0.55 -13 4 2 3 1 -0.001 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_ear head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_ear 19 16 -2.55 -13 4 2 3 1 -0.001 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "8.6 UNDEAD_HORSE_ARMOR: parts below the root" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 UNDEAD_HORSE_ARMOR: cuboids" TO WS-NAME
     MOVE 12 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 UNDEAD_HORSE_ARMOR: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 UNDEAD_HORSE_ARMOR: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "HORSE_SADDLE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer HORSE_SADDLE is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§8 Equines: horse, donkey, mule, skeleton horse, zombie horse 8.6 HORSE_SADDLE" TO CK-PREFIX
     MOVE "P body root 0.0 9.6984 5.5 0 0 0 1.1 1.1 1.1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 32 -5 -8 -17 10 10 22 0.05 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head_parts root 0.0 1.9984 -13.2 0.5235988 0 0 1.1 1.1 1.1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head_parts 0 35 -2.05 -6 -2 4 12 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 13 -3 -11 -2 6 5 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P mane head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C mane 56 36 -1 -11 5.01 2 16 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P upper_mouth head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C upper_mouth 0 25 -2 -11 -7 4 5 5 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 4.4 12.9984 7.7 0 0 0 1.1 1.1 1.1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 48 21 -3 -1.01 -1 4 11 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -4.4 12.9984 7.7 0 0 0 1.1 1.1 1.1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 48 21 -1 -1.01 -1 4 11 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 4.4 12.9984 -11.0 0 0 0 1.1 1.1 1.1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 48 21 -3 -1.01 -1.9 4 11 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -4.4 12.9984 -11.0 0 0 0 1.1 1.1 1.1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 48 21 -1 -1.01 -1.9 4 11 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P tail body 0 -5 2 0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C tail 42 36 -1.5 0 0 3 14 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_ear head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_ear 19 16 0.55 -13 4 2 3 1 -0.001 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_ear head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_ear 19 16 -2.55 -13 4 2 3 1 -0.001 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P saddle body 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C saddle 26 0 -5 -8 -9 10 9 9 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_saddle_mouth head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_saddle_mouth 29 5 2 -9 -6 1 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_saddle_mouth head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_saddle_mouth 29 5 -3 -9 -6 1 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_saddle_line head_parts 0 0 0 -0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_saddle_line 32 2 3.1 -6 -8 0 3 16 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_saddle_line head_parts 0 0 0 -0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_saddle_line 32 2 -3.1 -6 -8 0 3 16 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head_saddle head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head_saddle 1 1 -3 -11 -1.9 6 5 6 0.22 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P mouth_saddle_wrap head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C mouth_saddle_wrap 19 0 -2 -11 -4 4 5 2 0.2 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "8.6 HORSE_SADDLE: parts below the root" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 HORSE_SADDLE: cuboids" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 HORSE_SADDLE: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 HORSE_SADDLE: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "SKELETON_HORSE_SADDLE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer SKELETON_HORSE_SADDLE is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§8 Equines: horse, donkey, mule, skeleton horse, zombie horse 8.6 SKELETON_HORSE_SADDLE" TO CK-PREFIX
     MOVE "P body root 0 11 5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 32 -5 -8 -17 10 10 22 0.05 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head_parts root 0 4 -12 0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head_parts 0 35 -2.05 -6 -2 4 12 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 13 -3 -11 -2 6 5 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P mane head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C mane 56 36 -1 -11 5.01 2 16 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P upper_mouth head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C upper_mouth 0 25 -2 -11 -7 4 5 5 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 4 14 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 48 21 -3 -1.01 -1 4 11 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -4 14 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 48 21 -1 -1.01 -1 4 11 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 4 14 -10 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 48 21 -3 -1.01 -1.9 4 11 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -4 14 -10 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 48 21 -1 -1.01 -1.9 4 11 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P tail body 0 -5 2 0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C tail 42 36 -1.5 0 0 3 14 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_ear head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_ear 19 16 0.55 -13 4 2 3 1 -0.001 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_ear head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_ear 19 16 -2.55 -13 4 2 3 1 -0.001 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P saddle body 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C saddle 26 0 -5 -8 -9 10 9 9 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_saddle_mouth head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_saddle_mouth 29 5 2 -9 -6 1 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_saddle_mouth head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_saddle_mouth 29 5 -3 -9 -6 1 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_saddle_line head_parts 0 0 0 -0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_saddle_line 32 2 3.1 -6 -8 0 3 16 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_saddle_line head_parts 0 0 0 -0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_saddle_line 32 2 -3.1 -6 -8 0 3 16 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head_saddle head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head_saddle 1 1 -3 -11 -1.9 6 5 6 0.22 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P mouth_saddle_wrap head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C mouth_saddle_wrap 19 0 -2 -11 -4 4 5 2 0.2 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "8.6 SKELETON_HORSE_SADDLE: parts below the root" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 SKELETON_HORSE_SADDLE: cuboids" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 SKELETON_HORSE_SADDLE: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 SKELETON_HORSE_SADDLE: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_HORSE_SADDLE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer ZOMBIE_HORSE_SADDLE is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§8 Equines: horse, donkey, mule, skeleton horse, zombie horse 8.6 ZOMBIE_HORSE_SADDLE" TO CK-PREFIX
     MOVE "P body root 0 11 5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 32 -5 -8 -17 10 10 22 0.05 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head_parts root 0 4 -12 0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head_parts 0 35 -2.05 -6 -2 4 12 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 13 -3 -11 -2 6 5 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P mane head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C mane 56 36 -1 -11 5.01 2 16 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P upper_mouth head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C upper_mouth 0 25 -2 -11 -7 4 5 5 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 4 14 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 48 21 -3 -1.01 -1 4 11 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -4 14 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 48 21 -1 -1.01 -1 4 11 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 4 14 -10 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 48 21 -3 -1.01 -1.9 4 11 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -4 14 -10 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 48 21 -1 -1.01 -1.9 4 11 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P tail body 0 -5 2 0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C tail 42 36 -1.5 0 0 3 14 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_ear head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_ear 19 16 0.55 -13 4 2 3 1 -0.001 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_ear head 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_ear 19 16 -2.55 -13 4 2 3 1 -0.001 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P saddle body 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C saddle 26 0 -5 -8 -9 10 9 9 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_saddle_mouth head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_saddle_mouth 29 5 2 -9 -6 1 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_saddle_mouth head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_saddle_mouth 29 5 -3 -9 -6 1 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_saddle_line head_parts 0 0 0 -0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_saddle_line 32 2 3.1 -6 -8 0 3 16 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_saddle_line head_parts 0 0 0 -0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_saddle_line 32 2 -3.1 -6 -8 0 3 16 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head_saddle head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head_saddle 1 1 -3 -11 -1.9 6 5 6 0.22 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P mouth_saddle_wrap head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C mouth_saddle_wrap 19 0 -2 -11 -4 4 5 2 0.2 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "8.6 ZOMBIE_HORSE_SADDLE: parts below the root" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 ZOMBIE_HORSE_SADDLE: cuboids" TO WS-NAME
     MOVE 19 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 ZOMBIE_HORSE_SADDLE: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 ZOMBIE_HORSE_SADDLE: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "HORSE_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer HORSE_BABY is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§8 Equines: horse, donkey, mule, skeleton horse, zombie horse 8.6 HORSE_BABY" TO CK-PREFIX
     MOVE "P body root 0 12.5 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 13 -4 -3.5 -7 8 7 14 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P tail body 0 -1 7 -0.7418 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C tail 24 34 -1.5 -1.5 -1 3 3 8 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 2.4 16 5.4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 12 46 -1.5 -1 -1.5 3 9 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -2.4 16 5.4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 0 46 -1.5 -1 -1.5 3 9 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 2.4 16 -5.4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 12 34 -1.5 -1 -1.5 3 9 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -2.4 16 -5.4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 0 34 -1.5 -1 -1.5 3 9 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head_parts root 0 10 -6 0.6109 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head_parts 30 0 -2 -6 -2 4 8 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head head_parts 0 -6.0516 -0.2951 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -3 -3.9484 -6.705 6 4 9 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_ear head 2 -4.2484 1.9451 0 0 0.2618" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_ear 0 4 -1 -2.5 -0.8 2 3 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_ear head -2 -4.2484 1.645 0 0 -0.2618" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_ear 0 0 -1 -2.5 -0.5 2 3 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "8.6 HORSE_BABY: parts below the root" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 HORSE_BABY: cuboids" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 HORSE_BABY: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 HORSE_BABY: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "SKELETON_HORSE_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer SKELETON_HORSE_BABY is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§8 Equines: horse, donkey, mule, skeleton horse, zombie horse 8.6 SKELETON_HORSE_BABY" TO CK-PREFIX
     MOVE "P body root 0 12.5 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 13 -4 -3.5 -7 8 7 14 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P tail body 0 -1 7 -0.7418 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C tail 24 34 -1.5 -1.5 -1 3 3 8 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 2.4 16 5.4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 12 46 -1.5 -1 -1.5 3 9 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -2.4 16 5.4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 0 46 -1.5 -1 -1.5 3 9 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 2.4 16 -5.4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 12 34 -1.5 -1 -1.5 3 9 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -2.4 16 -5.4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 0 34 -1.5 -1 -1.5 3 9 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head_parts root 0 10 -6 0.6109 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head_parts 30 0 -2 -6 -2 4 8 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head head_parts 0 -6.0516 -0.2951 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -3 -3.9484 -6.705 6 4 9 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_ear head 2 -4.2484 1.9451 0 0 0.2618" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_ear 0 4 -1 -2.5 -0.8 2 3 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_ear head -2 -4.2484 1.645 0 0 -0.2618" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_ear 0 0 -1 -2.5 -0.5 2 3 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "8.6 SKELETON_HORSE_BABY: parts below the root" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 SKELETON_HORSE_BABY: cuboids" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 SKELETON_HORSE_BABY: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 SKELETON_HORSE_BABY: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_HORSE_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer ZOMBIE_HORSE_BABY is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§8 Equines: horse, donkey, mule, skeleton horse, zombie horse 8.6 ZOMBIE_HORSE_BABY" TO CK-PREFIX
     MOVE "P body root 0 12.5 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 13 -4 -3.5 -7 8 7 14 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P tail body 0 -1 7 -0.7418 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C tail 24 34 -1.5 -1.5 -1 3 3 8 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 2.4 16 5.4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 12 46 -1.5 -1 -1.5 3 9 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -2.4 16 5.4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 0 46 -1.5 -1 -1.5 3 9 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 2.4 16 -5.4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 12 34 -1.5 -1 -1.5 3 9 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -2.4 16 -5.4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 0 34 -1.5 -1 -1.5 3 9 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head_parts root 0 10 -6 0.6109 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head_parts 30 0 -2 -6 -2 4 8 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head head_parts 0 -6.0516 -0.2951 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -3 -3.9484 -6.705 6 4 9 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_ear head 2 -4.2484 1.9451 0 0 0.2618" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_ear 0 4 -1 -2.5 -0.8 2 3 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_ear head -2 -4.2484 1.645 0 0 -0.2618" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_ear 0 0 -1 -2.5 -0.5 2 3 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "8.6 ZOMBIE_HORSE_BABY: parts below the root" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 ZOMBIE_HORSE_BABY: cuboids" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 ZOMBIE_HORSE_BABY: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 ZOMBIE_HORSE_BABY: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "DONKEY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer DONKEY is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§8 Equines: horse, donkey, mule, skeleton horse, zombie horse 8.6 DONKEY" TO CK-PREFIX
     MOVE "P body root 0.0 12.69208 4.35 0 0 0 0.87 0.87 0.87" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 32 -5 -8 -17 10 10 22 0.05 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head_parts root 0.0 6.60208 -10.44 0.5235988 0 0 0.87 0.87 0.87" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head_parts 0 35 -2.05 -6 -2 4 12 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 13 -3 -11 -2 6 5 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P mane head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C mane 56 36 -1 -11 5.01 2 16 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P upper_mouth head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C upper_mouth 0 25 -2 -11 -7 4 5 5 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 3.48 15.30208 6.09 0 0 0 0.87 0.87 0.87" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 48 21 -3 -1.01 -1 4 11 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -3.48 15.30208 6.09 0 0 0 0.87 0.87 0.87" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 48 21 -1 -1.01 -1 4 11 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 3.48 15.30208 -8.7 0 0 0 0.87 0.87 0.87" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 48 21 -3 -1.01 -1.9 4 11 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -3.48 15.30208 -8.7 0 0 0 0.87 0.87 0.87" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 48 21 -1 -1.01 -1.9 4 11 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P tail body 0 -5 2 0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C tail 42 36 -1.5 0 0 3 14 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_ear head 1.25 -10 4 0.2617994 0 0.2617994" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_ear 0 12 -1 -7 0 2 7 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_ear head -1.25 -10 4 0.2617994 0 -0.2617994" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_ear 0 12 -1 -7 0 2 7 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_chest body 6 -8 0 0 -1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_chest 26 21 -4 0 -2 8 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_chest body -6 -8 0 0 1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_chest 26 21 -4 0 -2 8 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "8.6 DONKEY: parts below the root" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 DONKEY: cuboids" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 DONKEY: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 DONKEY: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "MULE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer MULE is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§8 Equines: horse, donkey, mule, skeleton horse, zombie horse 8.6 MULE" TO CK-PREFIX
     MOVE "P body root 0.0 12.04128 4.6 0 0 0 0.92 0.92 0.92" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 32 -5 -8 -17 10 10 22 0.05 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head_parts root 0.0 5.60128 -11.04 0.5235988 0 0 0.92 0.92 0.92" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head_parts 0 35 -2.05 -6 -2 4 12 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 13 -3 -11 -2 6 5 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P mane head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C mane 56 36 -1 -11 5.01 2 16 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P upper_mouth head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C upper_mouth 0 25 -2 -11 -7 4 5 5 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 3.68 14.80128 6.44 0 0 0 0.92 0.92 0.92" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 48 21 -3 -1.01 -1 4 11 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -3.68 14.80128 6.44 0 0 0 0.92 0.92 0.92" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 48 21 -1 -1.01 -1 4 11 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 3.68 14.80128 -9.2 0 0 0 0.92 0.92 0.92" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 48 21 -3 -1.01 -1.9 4 11 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -3.68 14.80128 -9.2 0 0 0 0.92 0.92 0.92" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 48 21 -1 -1.01 -1.9 4 11 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P tail body 0 -5 2 0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C tail 42 36 -1.5 0 0 3 14 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_ear head 1.25 -10 4 0.2617994 0 0.2617994" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_ear 0 12 -1 -7 0 2 7 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_ear head -1.25 -10 4 0.2617994 0 -0.2617994" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_ear 0 12 -1 -7 0 2 7 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_chest body 6 -8 0 0 -1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_chest 26 21 -4 0 -2 8 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_chest body -6 -8 0 0 1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_chest 26 21 -4 0 -2 8 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "8.6 MULE: parts below the root" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 MULE: cuboids" TO WS-NAME
     MOVE 14 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 MULE: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 MULE: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "DONKEY_SADDLE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer DONKEY_SADDLE is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§8 Equines: horse, donkey, mule, skeleton horse, zombie horse 8.6 DONKEY_SADDLE" TO CK-PREFIX
     MOVE "P body root 0.0 12.69208 4.35 0 0 0 0.87 0.87 0.87" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 32 -5 -8 -17 10 10 22 0.05 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head_parts root 0.0 6.60208 -10.44 0.5235988 0 0 0.87 0.87 0.87" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head_parts 0 35 -2.05 -6 -2 4 12 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 13 -3 -11 -2 6 5 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P mane head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C mane 56 36 -1 -11 5.01 2 16 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P upper_mouth head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C upper_mouth 0 25 -2 -11 -7 4 5 5 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 3.48 15.30208 6.09 0 0 0 0.87 0.87 0.87" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 48 21 -3 -1.01 -1 4 11 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -3.48 15.30208 6.09 0 0 0 0.87 0.87 0.87" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 48 21 -1 -1.01 -1 4 11 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 3.48 15.30208 -8.7 0 0 0 0.87 0.87 0.87" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 48 21 -3 -1.01 -1.9 4 11 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -3.48 15.30208 -8.7 0 0 0 0.87 0.87 0.87" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 48 21 -1 -1.01 -1.9 4 11 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P tail body 0 -5 2 0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C tail 42 36 -1.5 0 0 3 14 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_ear head 1.25 -10 4 0.2617994 0 0.2617994" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_ear 0 12 -1 -7 0 2 7 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_ear head -1.25 -10 4 0.2617994 0 -0.2617994" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_ear 0 12 -1 -7 0 2 7 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P saddle body 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C saddle 26 0 -5 -8 -9 10 9 9 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_saddle_mouth head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_saddle_mouth 29 5 2 -9 -6 1 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_saddle_mouth head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_saddle_mouth 29 5 -3 -9 -6 1 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_saddle_line head_parts 0 0 0 -0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_saddle_line 32 2 3.1 -6 -8 0 3 16 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_saddle_line head_parts 0 0 0 -0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_saddle_line 32 2 -3.1 -6 -8 0 3 16 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head_saddle head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head_saddle 1 1 -3 -11 -1.9 6 5 6 0.22 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P mouth_saddle_wrap head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C mouth_saddle_wrap 19 0 -2 -11 -4 4 5 2 0.2 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_chest body 6 -8 0 0 -1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_chest 26 21 -4 0 -2 8 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_chest body -6 -8 0 0 1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_chest 26 21 -4 0 -2 8 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "8.6 DONKEY_SADDLE: parts below the root" TO WS-NAME
     MOVE 21 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 DONKEY_SADDLE: cuboids" TO WS-NAME
     MOVE 21 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 DONKEY_SADDLE: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 DONKEY_SADDLE: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "MULE_SADDLE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer MULE_SADDLE is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§8 Equines: horse, donkey, mule, skeleton horse, zombie horse 8.6 MULE_SADDLE" TO CK-PREFIX
     MOVE "P body root 0.0 12.04128 4.6 0 0 0 0.92 0.92 0.92" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 32 -5 -8 -17 10 10 22 0.05 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head_parts root 0.0 5.60128 -11.04 0.5235988 0 0 0.92 0.92 0.92" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head_parts 0 35 -2.05 -6 -2 4 12 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 13 -3 -11 -2 6 5 7 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P mane head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C mane 56 36 -1 -11 5.01 2 16 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P upper_mouth head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C upper_mouth 0 25 -2 -11 -7 4 5 5 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 3.68 14.80128 6.44 0 0 0 0.92 0.92 0.92" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 48 21 -3 -1.01 -1 4 11 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -3.68 14.80128 6.44 0 0 0 0.92 0.92 0.92" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 48 21 -1 -1.01 -1 4 11 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 3.68 14.80128 -9.2 0 0 0 0.92 0.92 0.92" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 48 21 -3 -1.01 -1.9 4 11 4 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -3.68 14.80128 -9.2 0 0 0 0.92 0.92 0.92" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 48 21 -1 -1.01 -1.9 4 11 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P tail body 0 -5 2 0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C tail 42 36 -1.5 0 0 3 14 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_ear head 1.25 -10 4 0.2617994 0 0.2617994" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_ear 0 12 -1 -7 0 2 7 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_ear head -1.25 -10 4 0.2617994 0 -0.2617994" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_ear 0 12 -1 -7 0 2 7 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P saddle body 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C saddle 26 0 -5 -8 -9 10 9 9 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_saddle_mouth head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_saddle_mouth 29 5 2 -9 -6 1 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_saddle_mouth head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_saddle_mouth 29 5 -3 -9 -6 1 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_saddle_line head_parts 0 0 0 -0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_saddle_line 32 2 3.1 -6 -8 0 3 16 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_saddle_line head_parts 0 0 0 -0.5235988 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_saddle_line 32 2 -3.1 -6 -8 0 3 16 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head_saddle head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head_saddle 1 1 -3 -11 -1.9 6 5 6 0.22 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P mouth_saddle_wrap head_parts 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C mouth_saddle_wrap 19 0 -2 -11 -4 4 5 2 0.2 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_chest body 6 -8 0 0 -1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_chest 26 21 -4 0 -2 8 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_chest body -6 -8 0 0 1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_chest 26 21 -4 0 -2 8 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "8.6 MULE_SADDLE: parts below the root" TO WS-NAME
     MOVE 21 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 MULE_SADDLE: cuboids" TO WS-NAME
     MOVE 21 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 MULE_SADDLE: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 MULE_SADDLE: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "DONKEY_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer DONKEY_BABY is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§8 Equines: horse, donkey, mule, skeleton horse, zombie horse 8.6 DONKEY_BABY" TO CK-PREFIX
     MOVE "P body root 1 14 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 13 -5 -3 -7 8 6 14 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P tail body 0 -1.5 6.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P tail_r1 tail 0 0 0 -0.7418 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C tail_r1 24 33 -2.5 -1 -0.5 3 3 8 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg body 2.25 3.5 5.25 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 12 44 -2.5 -1.5 -1.5 3 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg body -2.4 3.5 5.4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 0 44 -2.5 -1.5 -1.5 3 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg body 2.4 3.5 -5.3 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 12 33 -2.5 -1.5 -1.5 3 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg body -2.4 3.5 -5.4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 0 33 -2.5 -1.5 -1.5 3 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head_parts body 0 -3 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P neck_r1 head_parts 0 0 0 0.3927 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C neck_r1 30 9 -3 -6 -3 4 8 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head head_parts 0 -5 -3 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head_r1 head 0 -1 1 0.3927 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head_r1 0 0 -4 -3.6 -8.4 6 4 9 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_ear head 2 -3.5 -1 0.48 0 0.48" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_ear 0 0 -2 -6.5 -0.3 2 7 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_ear head -2 -3.5 -1 0.48 0 -0.48" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_ear 22 0 -2 -6.5 -0.3 2 7 1 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_chest body -1 10 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_chest body -1 10 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "8.6 DONKEY_BABY: parts below the root" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 DONKEY_BABY: cuboids" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 DONKEY_BABY: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 DONKEY_BABY: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "MULE_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer MULE_BABY is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§8 Equines: horse, donkey, mule, skeleton horse, zombie horse 8.6 MULE_BABY" TO CK-PREFIX
     MOVE "P body root 1 14 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 13 -5 -3 -7 8 6 14 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P tail body 0 -1.5 6.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P tail_r1 tail 0 0 0 -0.7418 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C tail_r1 24 33 -2.5 -1 -0.5 3 3 8 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg body 2.25 3.5 5.25 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 12 44 -2.5 -1.5 -1.5 3 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg body -2.4 3.5 5.4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 0 44 -2.5 -1.5 -1.5 3 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg body 2.4 3.5 -5.3 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 12 33 -2.5 -1.5 -1.5 3 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg body -2.4 3.5 -5.4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 0 33 -2.5 -1.5 -1.5 3 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head_parts body 0 -3 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P neck_r1 head_parts 0 0 0 0.3927 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C neck_r1 30 9 -3 -6 -3 4 8 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head head_parts 0 -5 -3 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P head_r1 head 0 -1 1 0.3927 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head_r1 0 0 -4 -3.6 -8.4 6 4 9 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_ear head 2 -3.5 -1 0.48 0 0.48" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_ear 0 0 -2 -6.5 -0.3 2 7 1 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_ear head -2 -3.5 -1 0.48 0 -0.48" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_ear 22 0 -2 -6.5 -0.3 2 7 1 0 1" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_chest body -1 10 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_chest body -1 10 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "8.6 MULE_BABY: parts below the root" TO WS-NAME
     MOVE 15 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 MULE_BABY: cuboids" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 MULE_BABY: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.6 MULE_BABY: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "horse" TO WS-X24
     CALL "EF4-EQUINE-REG" USING WS-X24 WS-X40 WS-IV(1)
     MOVE "8.2 horse saddle layer type" TO WS-NAME
     MOVE "horse_saddle" TO TL-EXPECTED
     MOVE WS-X40 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "8.2 horse saddle model scale" TO WS-NAME
     MOVE 1.1 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "donkey" TO WS-X24
     CALL "EF4-EQUINE-REG" USING WS-X24 WS-X40 WS-IV(1)
     MOVE "8.2 donkey saddle layer type" TO WS-NAME
     MOVE "donkey_saddle" TO TL-EXPECTED
     MOVE WS-X40 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "8.2 donkey saddle model scale" TO WS-NAME
     MOVE 0.87 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "mule" TO WS-X24
     CALL "EF4-EQUINE-REG" USING WS-X24 WS-X40 WS-IV(1)
     MOVE "8.2 mule saddle layer type" TO WS-NAME
     MOVE "mule_saddle" TO TL-EXPECTED
     MOVE WS-X40 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "8.2 mule saddle model scale" TO WS-NAME
     MOVE 0.92 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "skeleton_horse" TO WS-X24
     CALL "EF4-EQUINE-REG" USING WS-X24 WS-X40 WS-IV(1)
     MOVE "8.2 skeleton_horse saddle layer type" TO WS-NAME
     MOVE "skeleton_horse_saddle" TO TL-EXPECTED
     MOVE WS-X40 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "8.2 skeleton_horse saddle model scale" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "zombie_horse" TO WS-X24
     CALL "EF4-EQUINE-REG" USING WS-X24 WS-X40 WS-IV(1)
     MOVE "8.2 zombie_horse saddle layer type" TO WS-NAME
     MOVE "zombie_horse_saddle" TO TL-EXPECTED
     MOVE WS-X40 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "8.2 zombie_horse saddle model scale" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "donkey" TO WS-X24
     MOVE 0 TO WS-FL
     CALL "EF4-EQUINE-TEXTURE" USING WS-X24 WS-FL WS-X120
     MOVE "8.2 donkey baby 0 texture" TO WS-NAME
     MOVE "textures/entity/horse/donkey.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "donkey" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF4-EQUINE-TEXTURE" USING WS-X24 WS-FL WS-X120
     MOVE "8.2 donkey baby 1 texture" TO WS-NAME
     MOVE "textures/entity/horse/donkey_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "mule" TO WS-X24
     MOVE 0 TO WS-FL
     CALL "EF4-EQUINE-TEXTURE" USING WS-X24 WS-FL WS-X120
     MOVE "8.2 mule baby 0 texture" TO WS-NAME
     MOVE "textures/entity/horse/mule.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "mule" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF4-EQUINE-TEXTURE" USING WS-X24 WS-FL WS-X120
     MOVE "8.2 mule baby 1 texture" TO WS-NAME
     MOVE "textures/entity/horse/mule_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "skeleton_horse" TO WS-X24
     MOVE 0 TO WS-FL
     CALL "EF4-EQUINE-TEXTURE" USING WS-X24 WS-FL WS-X120
     MOVE "8.2 skeleton_horse baby 0 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_skeleton.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "skeleton_horse" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF4-EQUINE-TEXTURE" USING WS-X24 WS-FL WS-X120
     MOVE "8.2 skeleton_horse baby 1 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_skeleton_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "zombie_horse" TO WS-X24
     MOVE 0 TO WS-FL
     CALL "EF4-EQUINE-TEXTURE" USING WS-X24 WS-FL WS-X120
     MOVE "8.2 zombie_horse baby 0 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_zombie.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "zombie_horse" TO WS-X24
     MOVE 1 TO WS-FL
     CALL "EF4-EQUINE-TEXTURE" USING WS-X24 WS-FL WS-X120
     MOVE "8.2 zombie_horse baby 1 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_zombie_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 0 TO WS-IV(1)
     CALL "EF4-HORSE-VARIANT" USING WS-IN WS-OUT
     MOVE "8.5 horse colour id 0 (the id map wraps)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-HORSE-TEXTURE" USING WS-IN WS-X120
     MOVE "8.5 horse colour 0 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_white.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-HORSE-TEXTURE" USING WS-IN WS-X120
     MOVE "8.5 horse colour 0 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_white_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 1 TO WS-IV(1)
     CALL "EF4-HORSE-VARIANT" USING WS-IN WS-OUT
     MOVE "8.5 horse colour id 1 (the id map wraps)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-HORSE-TEXTURE" USING WS-IN WS-X120
     MOVE "8.5 horse colour 1 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_creamy.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-HORSE-TEXTURE" USING WS-IN WS-X120
     MOVE "8.5 horse colour 1 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_creamy_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 2 TO WS-IV(1)
     CALL "EF4-HORSE-VARIANT" USING WS-IN WS-OUT
     MOVE "8.5 horse colour id 2 (the id map wraps)" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-HORSE-TEXTURE" USING WS-IN WS-X120
     MOVE "8.5 horse colour 2 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_chestnut.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-HORSE-TEXTURE" USING WS-IN WS-X120
     MOVE "8.5 horse colour 2 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_chestnut_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 3 TO WS-IV(1)
     CALL "EF4-HORSE-VARIANT" USING WS-IN WS-OUT
     MOVE "8.5 horse colour id 3 (the id map wraps)" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-HORSE-TEXTURE" USING WS-IN WS-X120
     MOVE "8.5 horse colour 3 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_brown.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 3 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-HORSE-TEXTURE" USING WS-IN WS-X120
     MOVE "8.5 horse colour 3 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_brown_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 4 TO WS-IV(1)
     CALL "EF4-HORSE-VARIANT" USING WS-IN WS-OUT
     MOVE "8.5 horse colour id 4 (the id map wraps)" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-HORSE-TEXTURE" USING WS-IN WS-X120
     MOVE "8.5 horse colour 4 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_black.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 4 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-HORSE-TEXTURE" USING WS-IN WS-X120
     MOVE "8.5 horse colour 4 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_black_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 5 TO WS-IV(1)
     CALL "EF4-HORSE-VARIANT" USING WS-IN WS-OUT
     MOVE "8.5 horse colour id 5 (the id map wraps)" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-HORSE-TEXTURE" USING WS-IN WS-X120
     MOVE "8.5 horse colour 5 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_gray.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 5 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-HORSE-TEXTURE" USING WS-IN WS-X120
     MOVE "8.5 horse colour 5 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_gray_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 6 TO WS-IV(1)
     CALL "EF4-HORSE-VARIANT" USING WS-IN WS-OUT
     MOVE "8.5 horse colour id 6 (the id map wraps)" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 6 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-HORSE-TEXTURE" USING WS-IN WS-X120
     MOVE "8.5 horse colour 6 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_darkbrown.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 6 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-HORSE-TEXTURE" USING WS-IN WS-X120
     MOVE "8.5 horse colour 6 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_darkbrown_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 7 TO WS-IV(1)
     CALL "EF4-HORSE-VARIANT" USING WS-IN WS-OUT
     MOVE "8.5 horse colour id 7 (the id map wraps)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-HORSE-TEXTURE" USING WS-IN WS-X120
     MOVE "8.5 horse colour 0 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_white.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-HORSE-TEXTURE" USING WS-IN WS-X120
     MOVE "8.5 horse colour 0 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_white_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 8 TO WS-IV(1)
     CALL "EF4-HORSE-VARIANT" USING WS-IN WS-OUT
     MOVE "8.5 horse colour id 8 (the id map wraps)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-HORSE-TEXTURE" USING WS-IN WS-X120
     MOVE "8.5 horse colour 1 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_creamy.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-HORSE-TEXTURE" USING WS-IN WS-X120
     MOVE "8.5 horse colour 1 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_creamy_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 13 TO WS-IV(1)
     CALL "EF4-HORSE-VARIANT" USING WS-IN WS-OUT
     MOVE "8.5 horse colour id 13 (the id map wraps)" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 6 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-HORSE-TEXTURE" USING WS-IN WS-X120
     MOVE "8.5 horse colour 6 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_darkbrown.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 6 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-HORSE-TEXTURE" USING WS-IN WS-X120
     MOVE "8.5 horse colour 6 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_darkbrown_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE -1 TO WS-IV(1)
     CALL "EF4-HORSE-VARIANT" USING WS-IN WS-OUT
     MOVE "8.5 horse colour id -1 (the id map wraps)" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 6 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-HORSE-TEXTURE" USING WS-IN WS-X120
     MOVE "8.5 horse colour 6 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_darkbrown.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 6 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-HORSE-TEXTURE" USING WS-IN WS-X120
     MOVE "8.5 horse colour 6 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/horse/horse_darkbrown_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 0 TO WS-IV(1)
     CALL "EF4-HORSE-MARKING-ID" USING WS-IN WS-OUT
     MOVE "8.5 marking id 0 (wraps)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-HORSE-MARKING" USING WS-IN WS-X120
     MOVE "8.5 marking 0 baby 0 texture (spaces: none)" TO WS-NAME
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-HORSE-MARKING" USING WS-IN WS-X120
     MOVE "8.5 marking 0 baby 1 texture (spaces: none)" TO WS-NAME
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 1 TO WS-IV(1)
     CALL "EF4-HORSE-MARKING-ID" USING WS-IN WS-OUT
     MOVE "8.5 marking id 1 (wraps)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-HORSE-MARKING" USING WS-IN WS-X120
     MOVE "8.5 marking 1 baby 0 texture (spaces: none)" TO WS-NAME
     MOVE "textures/entity/horse/horse_markings_white.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-HORSE-MARKING" USING WS-IN WS-X120
     MOVE "8.5 marking 1 baby 1 texture (spaces: none)" TO WS-NAME
     MOVE "textures/entity/horse/horse_markings_white_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 2 TO WS-IV(1)
     CALL "EF4-HORSE-MARKING-ID" USING WS-IN WS-OUT
     MOVE "8.5 marking id 2 (wraps)" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-HORSE-MARKING" USING WS-IN WS-X120
     MOVE "8.5 marking 2 baby 0 texture (spaces: none)" TO WS-NAME
     MOVE "textures/entity/horse/horse_markings_whitefield.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-HORSE-MARKING" USING WS-IN WS-X120
     MOVE "8.5 marking 2 baby 1 texture (spaces: none)" TO WS-NAME
     MOVE "textures/entity/horse/horse_markings_whitefield_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 3 TO WS-IV(1)
     CALL "EF4-HORSE-MARKING-ID" USING WS-IN WS-OUT
     MOVE "8.5 marking id 3 (wraps)" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-HORSE-MARKING" USING WS-IN WS-X120
     MOVE "8.5 marking 3 baby 0 texture (spaces: none)" TO WS-NAME
     MOVE "textures/entity/horse/horse_markings_whitedots.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 3 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-HORSE-MARKING" USING WS-IN WS-X120
     MOVE "8.5 marking 3 baby 1 texture (spaces: none)" TO WS-NAME
     MOVE "textures/entity/horse/horse_markings_whitedots_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 4 TO WS-IV(1)
     CALL "EF4-HORSE-MARKING-ID" USING WS-IN WS-OUT
     MOVE "8.5 marking id 4 (wraps)" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-HORSE-MARKING" USING WS-IN WS-X120
     MOVE "8.5 marking 4 baby 0 texture (spaces: none)" TO WS-NAME
     MOVE "textures/entity/horse/horse_markings_blackdots.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 4 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-HORSE-MARKING" USING WS-IN WS-X120
     MOVE "8.5 marking 4 baby 1 texture (spaces: none)" TO WS-NAME
     MOVE "textures/entity/horse/horse_markings_blackdots_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 5 TO WS-IV(1)
     CALL "EF4-HORSE-MARKING-ID" USING WS-IN WS-OUT
     MOVE "8.5 marking id 5 (wraps)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-HORSE-MARKING" USING WS-IN WS-X120
     MOVE "8.5 marking 0 baby 0 texture (spaces: none)" TO WS-NAME
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-HORSE-MARKING" USING WS-IN WS-X120
     MOVE "8.5 marking 0 baby 1 texture (spaces: none)" TO WS-NAME
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 9 TO WS-IV(1)
     CALL "EF4-HORSE-MARKING-ID" USING WS-IN WS-OUT
     MOVE "8.5 marking id 9 (wraps)" TO WS-NAME
     MOVE 4 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-HORSE-MARKING" USING WS-IN WS-X120
     MOVE "8.5 marking 4 baby 0 texture (spaces: none)" TO WS-NAME
     MOVE "textures/entity/horse/horse_markings_blackdots.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 4 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-HORSE-MARKING" USING WS-IN WS-X120
     MOVE "8.5 marking 4 baby 1 texture (spaces: none)" TO WS-NAME
     MOVE "textures/entity/horse/horse_markings_blackdots_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE -2 TO WS-IV(1)
     CALL "EF4-HORSE-MARKING-ID" USING WS-IN WS-OUT
     MOVE "8.5 marking id -2 (wraps)" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-HORSE-MARKING" USING WS-IN WS-X120
     MOVE "8.5 marking 3 baby 0 texture (spaces: none)" TO WS-NAME
     MOVE "textures/entity/horse/horse_markings_whitedots.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 3 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-HORSE-MARKING" USING WS-IN WS-X120
     MOVE "8.5 marking 3 baby 1 texture (spaces: none)" TO WS-NAME
     MOVE "textures/entity/horse/horse_markings_whitedots_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-MARKING-DRAW" USING WS-IN WS-OUT
     MOVE "8.5 marking texture 0 invisible 0: layer drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-MARKING-DRAW" USING WS-IN WS-OUT
     MOVE "8.5 marking texture 0 invisible 1: layer drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-MARKING-DRAW" USING WS-IN WS-OUT
     MOVE "8.5 marking texture 1 invisible 0: layer drawn" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-MARKING-DRAW" USING WS-IN WS-OUT
     MOVE "8.5 marking texture 1 invisible 1: layer drawn" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "HORSE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 12 TO WS-IV(1)
     MOVE -35 TO WS-IV(2)
     MOVE 1.7 TO WS-IV(3)
     MOVE 0.9 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 40 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.761285524 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.yrot" TO WS-NAME
     MOVE -0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.y" TO WS-NAME
     MOVE 1.9984 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.z" TO WS-NAME
     MOVE -13.2 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.y" TO WS-NAME
     MOVE 12.9984 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.z" TO WS-NAME
     MOVE -11.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.y" TO WS-NAME
     MOVE 12.9984 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.z" TO WS-NAME
     MOVE -11.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.190962552 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.190962552 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.305540084 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE 0.305540084 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.xrot" TO WS-NAME
     MOVE 1.1985988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.y" TO WS-NAME
     MOVE -4.1 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.z" TO WS-NAME
     MOVE 3.8 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.yrot" TO WS-NAME
     MOVE -0.962605866 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "HORSE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE -20 TO WS-IV(1)
     MOVE 8 TO WS-IV(2)
     MOVE 3.1 TO WS-IV(3)
     MOVE 0.1 TO WS-IV(4)
     MOVE 0.4 TO WS-IV(5)
     MOVE 0.3 TO WS-IV(6)
     MOVE 0.6 TO WS-IV(7)
     MOVE 17.5 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.xrot" TO WS-NAME
     MOVE 0.914130696 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.yrot" TO WS-NAME
     MOVE 0.125663702 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.y" TO WS-NAME
     MOVE 3.4944 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.z" TO WS-NAME
     MOVE -10.56 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 body.xrot" TO WS-NAME
     MOVE -0.23561946 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.y" TO WS-NAME
     MOVE 9.0384 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.z" TO WS-NAME
     MOVE -9.68 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.y" TO WS-NAME
     MOVE 9.0384 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.z" TO WS-NAME
     MOVE -9.68 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.110596432 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.046483208 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.xrot" TO WS-NAME
     MOVE -0.222788781 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.xrot" TO WS-NAME
     MOVE -0.405529779 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.xrot" TO WS-NAME
     MOVE 0.5985988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.y" TO WS-NAME
     MOVE -4.95 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.z" TO WS-NAME
     MOVE 2.1 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "HORSE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 5 TO WS-IV(1)
     MOVE -10 TO WS-IV(2)
     MOVE 0.5 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     MOVE 3.3 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.xrot" TO WS-NAME
     MOVE 2.173774315 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.y" TO WS-NAME
     MOVE 9.6984 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.z" TO WS-NAME
     MOVE -13.2 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.y" TO WS-NAME
     MOVE 12.9984 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.z" TO WS-NAME
     MOVE -11.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.y" TO WS-NAME
     MOVE 12.9984 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.z" TO WS-NAME
     MOVE -11.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.236258317 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.236258317 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.378013306 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.xrot" TO WS-NAME
     MOVE 0.378013306 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.xrot" TO WS-NAME
     MOVE 0.8985988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.y" TO WS-NAME
     MOVE -4.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.z" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.yrot" TO WS-NAME
     MOVE -0.673699636 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "HORSE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.yrot" TO WS-NAME
     MOVE 0.17453292 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.y" TO WS-NAME
     MOVE -6.8016 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.z" TO WS-NAME
     MOVE -4.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 body.xrot" TO WS-NAME
     MOVE -0.7853982 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.y" TO WS-NAME
     MOVE -0.2016 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.z" TO WS-NAME
     MOVE -6.6 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.y" TO WS-NAME
     MOVE -0.2016 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.z" TO WS-NAME
     MOVE -6.6 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -2.0471976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.0471976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.xrot" TO WS-NAME
     MOVE 0.5235988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.y" TO WS-NAME
     MOVE -5.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.z" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "HORSE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 25 TO WS-IV(1)
     MOVE 15 TO WS-IV(2)
     MOVE 2.2 TO WS-IV(3)
     MOVE 0.7 TO WS-IV(4)
     MOVE 0.2 TO WS-IV(5)
     MOVE 0.8 TO WS-IV(6)
     MOVE 0.3 TO WS-IV(7)
     MOVE 9 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.xrot" TO WS-NAME
     MOVE 1.172433372 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.yrot" TO WS-NAME
     MOVE 0.26179938 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.y" TO WS-NAME
     MOVE -2.0936 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.z" TO WS-NAME
     MOVE -6.16 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 body.xrot" TO WS-NAME
     MOVE -0.62831856 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.y" TO WS-NAME
     MOVE 2.4384 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.z" TO WS-NAME
     MOVE -7.48 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.y" TO WS-NAME
     MOVE 2.4384 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.z" TO WS-NAME
     MOVE -7.48 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.276453651 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.142425389 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.xrot" TO WS-NAME
     MOVE -1.452734991 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.xrot" TO WS-NAME
     MOVE -0.222781169 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.xrot" TO WS-NAME
     MOVE 1.0485988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.y" TO WS-NAME
     MOVE -4.65 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.z" TO WS-NAME
     MOVE 2.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.yrot" TO WS-NAME
     MOVE 0.999858636 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "HORSE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 3 TO WS-IV(1)
     MOVE 35 TO WS-IV(2)
     MOVE 0.9 TO WS-IV(3)
     MOVE 0.4 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0.2 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 5 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.56870714 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.yrot" TO WS-NAME
     MOVE 0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.y" TO WS-NAME
     MOVE 0.2384 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.z" TO WS-NAME
     MOVE -11.44 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 body.xrot" TO WS-NAME
     MOVE -0.15707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.y" TO WS-NAME
     MOVE 10.3584 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.z" TO WS-NAME
     MOVE -10.12 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.y" TO WS-NAME
     MOVE 10.3584 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.z" TO WS-NAME
     MOVE -10.12 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.184451511 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.079731751 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.22278763 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.19609141 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.xrot" TO WS-NAME
     MOVE 0.8235988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.y" TO WS-NAME
     MOVE -4.6 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.z" TO WS-NAME
     MOVE 2.8 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SKELETON_HORSE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 12 TO WS-IV(1)
     MOVE -35 TO WS-IV(2)
     MOVE 1.7 TO WS-IV(3)
     MOVE 0.9 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 40 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.761285524 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.yrot" TO WS-NAME
     MOVE -0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.y" TO WS-NAME
     MOVE 4.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.z" TO WS-NAME
     MOVE -12.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.y" TO WS-NAME
     MOVE 14.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.z" TO WS-NAME
     MOVE -10.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.y" TO WS-NAME
     MOVE 14.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.z" TO WS-NAME
     MOVE -10.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.190962552 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.190962552 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.305540084 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE 0.305540084 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.xrot" TO WS-NAME
     MOVE 1.1985988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.y" TO WS-NAME
     MOVE -4.1 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.z" TO WS-NAME
     MOVE 3.8 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.yrot" TO WS-NAME
     MOVE -0.962605866 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SKELETON_HORSE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE -20 TO WS-IV(1)
     MOVE 8 TO WS-IV(2)
     MOVE 3.1 TO WS-IV(3)
     MOVE 0.1 TO WS-IV(4)
     MOVE 0.4 TO WS-IV(5)
     MOVE 0.3 TO WS-IV(6)
     MOVE 0.6 TO WS-IV(7)
     MOVE 17.5 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.xrot" TO WS-NAME
     MOVE 0.914130696 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.yrot" TO WS-NAME
     MOVE 0.125663702 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.y" TO WS-NAME
     MOVE 5.36 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.z" TO WS-NAME
     MOVE -9.6 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 body.xrot" TO WS-NAME
     MOVE -0.23561946 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.y" TO WS-NAME
     MOVE 10.4 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.z" TO WS-NAME
     MOVE -8.8 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.y" TO WS-NAME
     MOVE 10.4 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.z" TO WS-NAME
     MOVE -8.8 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.110596432 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.046483208 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.xrot" TO WS-NAME
     MOVE -0.222788781 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.xrot" TO WS-NAME
     MOVE -0.405529779 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.xrot" TO WS-NAME
     MOVE 0.5985988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.y" TO WS-NAME
     MOVE -4.95 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.z" TO WS-NAME
     MOVE 2.1 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SKELETON_HORSE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 5 TO WS-IV(1)
     MOVE -10 TO WS-IV(2)
     MOVE 0.5 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     MOVE 3.3 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.xrot" TO WS-NAME
     MOVE 2.173774315 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.y" TO WS-NAME
     MOVE 11.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.z" TO WS-NAME
     MOVE -12.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.y" TO WS-NAME
     MOVE 14.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.z" TO WS-NAME
     MOVE -10.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.y" TO WS-NAME
     MOVE 14.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.z" TO WS-NAME
     MOVE -10.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.236258317 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.236258317 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.378013306 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.xrot" TO WS-NAME
     MOVE 0.378013306 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.xrot" TO WS-NAME
     MOVE 0.8985988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.y" TO WS-NAME
     MOVE -4.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.z" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.yrot" TO WS-NAME
     MOVE -0.673699636 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SKELETON_HORSE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.yrot" TO WS-NAME
     MOVE 0.17453292 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.y" TO WS-NAME
     MOVE -4.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.z" TO WS-NAME
     MOVE -4.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 body.xrot" TO WS-NAME
     MOVE -0.7853982 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.y" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.z" TO WS-NAME
     MOVE -6.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.y" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.z" TO WS-NAME
     MOVE -6.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -2.0471976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.0471976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.xrot" TO WS-NAME
     MOVE 0.5235988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.y" TO WS-NAME
     MOVE -5.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.z" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SKELETON_HORSE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 25 TO WS-IV(1)
     MOVE 15 TO WS-IV(2)
     MOVE 2.2 TO WS-IV(3)
     MOVE 0.7 TO WS-IV(4)
     MOVE 0.2 TO WS-IV(5)
     MOVE 0.8 TO WS-IV(6)
     MOVE 0.3 TO WS-IV(7)
     MOVE 9 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.xrot" TO WS-NAME
     MOVE 1.172433372 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.yrot" TO WS-NAME
     MOVE 0.26179938 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.y" TO WS-NAME
     MOVE 0.28 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.z" TO WS-NAME
     MOVE -5.6 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 body.xrot" TO WS-NAME
     MOVE -0.62831856 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.y" TO WS-NAME
     MOVE 4.4 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.z" TO WS-NAME
     MOVE -6.8 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.y" TO WS-NAME
     MOVE 4.4 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.z" TO WS-NAME
     MOVE -6.8 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.276453651 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.142425389 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.xrot" TO WS-NAME
     MOVE -1.452734991 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.xrot" TO WS-NAME
     MOVE -0.222781169 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.xrot" TO WS-NAME
     MOVE 1.0485988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.y" TO WS-NAME
     MOVE -4.65 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.z" TO WS-NAME
     MOVE 2.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.yrot" TO WS-NAME
     MOVE 0.999858636 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SKELETON_HORSE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 3 TO WS-IV(1)
     MOVE 35 TO WS-IV(2)
     MOVE 0.9 TO WS-IV(3)
     MOVE 0.4 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0.2 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 5 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.56870714 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.yrot" TO WS-NAME
     MOVE 0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.y" TO WS-NAME
     MOVE 2.4 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.z" TO WS-NAME
     MOVE -10.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 body.xrot" TO WS-NAME
     MOVE -0.15707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.y" TO WS-NAME
     MOVE 11.6 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.z" TO WS-NAME
     MOVE -9.2 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.y" TO WS-NAME
     MOVE 11.6 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.z" TO WS-NAME
     MOVE -9.2 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.184451511 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.079731751 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.22278763 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.19609141 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.xrot" TO WS-NAME
     MOVE 0.8235988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.y" TO WS-NAME
     MOVE -4.6 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.z" TO WS-NAME
     MOVE 2.8 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 SKELETON_HORSE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "HORSE_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 12 TO WS-IV(1)
     MOVE -35 TO WS-IV(2)
     MOVE 1.7 TO WS-IV(3)
     MOVE 0.9 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 40 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 1 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.761285524 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.yrot" TO WS-NAME
     MOVE -0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.y" TO WS-NAME
     MOVE 10.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.z" TO WS-NAME
     MOVE -6.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.y" TO WS-NAME
     MOVE 16.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.y" TO WS-NAME
     MOVE 16.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.190962552 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.190962552 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.305540084 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE 0.305540084 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.xrot" TO WS-NAME
     MOVE -0.3721976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.y" TO WS-NAME
     MOVE -0.1 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.z" TO WS-NAME
     MOVE 8.8 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.yrot" TO WS-NAME
     MOVE -0.962605866 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "HORSE_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE -20 TO WS-IV(1)
     MOVE 8 TO WS-IV(2)
     MOVE 3.1 TO WS-IV(3)
     MOVE 0.1 TO WS-IV(4)
     MOVE 0.4 TO WS-IV(5)
     MOVE 0.3 TO WS-IV(6)
     MOVE 0.6 TO WS-IV(7)
     MOVE 17.5 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     MOVE 1 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.xrot" TO WS-NAME
     MOVE 0.914130696 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.yrot" TO WS-NAME
     MOVE 0.125663702 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.y" TO WS-NAME
     MOVE 10.44 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 body.xrot" TO WS-NAME
     MOVE -0.23561946 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.y" TO WS-NAME
     MOVE 14.8 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.y" TO WS-NAME
     MOVE 14.8 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.110596432 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.046483208 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.xrot" TO WS-NAME
     MOVE -0.222788781 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.xrot" TO WS-NAME
     MOVE -0.405529779 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.xrot" TO WS-NAME
     MOVE -0.9721976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.y" TO WS-NAME
     MOVE -0.95 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.z" TO WS-NAME
     MOVE 7.1 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "HORSE_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 5 TO WS-IV(1)
     MOVE -10 TO WS-IV(2)
     MOVE 0.5 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     MOVE 3.3 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 1 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.xrot" TO WS-NAME
     MOVE 2.173774315 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.y" TO WS-NAME
     MOVE 12.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.z" TO WS-NAME
     MOVE -6.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.y" TO WS-NAME
     MOVE 16.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.y" TO WS-NAME
     MOVE 16.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.236258317 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.236258317 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.378013306 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.xrot" TO WS-NAME
     MOVE 0.378013306 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.xrot" TO WS-NAME
     MOVE -0.6721976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.y" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.z" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.yrot" TO WS-NAME
     MOVE -0.673699636 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "HORSE_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 1 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.yrot" TO WS-NAME
     MOVE 0.17453292 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.y" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.z" TO WS-NAME
     MOVE -4.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 body.xrot" TO WS-NAME
     MOVE -0.7853982 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.y" TO WS-NAME
     MOVE 12.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.y" TO WS-NAME
     MOVE 12.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -2.0471976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.0471976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.xrot" TO WS-NAME
     MOVE -1.0471976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.y" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.z" TO WS-NAME
     MOVE 7.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "HORSE_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 25 TO WS-IV(1)
     MOVE 15 TO WS-IV(2)
     MOVE 2.2 TO WS-IV(3)
     MOVE 0.7 TO WS-IV(4)
     MOVE 0.2 TO WS-IV(5)
     MOVE 0.8 TO WS-IV(6)
     MOVE 0.3 TO WS-IV(7)
     MOVE 9 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     MOVE 1 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.xrot" TO WS-NAME
     MOVE 1.172433372 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.yrot" TO WS-NAME
     MOVE 0.26179938 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.y" TO WS-NAME
     MOVE 9.12 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.z" TO WS-NAME
     MOVE -4.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 body.xrot" TO WS-NAME
     MOVE -0.62831856 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.y" TO WS-NAME
     MOVE 12.8 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.y" TO WS-NAME
     MOVE 12.8 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.276453651 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.142425389 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.xrot" TO WS-NAME
     MOVE -1.452734991 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.xrot" TO WS-NAME
     MOVE -0.222781169 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.xrot" TO WS-NAME
     MOVE -0.5221976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.y" TO WS-NAME
     MOVE -0.65 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.z" TO WS-NAME
     MOVE 7.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.yrot" TO WS-NAME
     MOVE 0.999858636 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "HORSE_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 3 TO WS-IV(1)
     MOVE 35 TO WS-IV(2)
     MOVE 0.9 TO WS-IV(3)
     MOVE 0.4 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0.2 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 5 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 1 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.56870714 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.yrot" TO WS-NAME
     MOVE 0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.y" TO WS-NAME
     MOVE 9.6 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.z" TO WS-NAME
     MOVE -5.6 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 body.xrot" TO WS-NAME
     MOVE -0.15707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.y" TO WS-NAME
     MOVE 15.2 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.y" TO WS-NAME
     MOVE 15.2 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.184451511 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.079731751 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.22278763 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.19609141 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.xrot" TO WS-NAME
     MOVE -0.7471976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.y" TO WS-NAME
     MOVE -0.6 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.z" TO WS-NAME
     MOVE 7.8 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "HORSE_SADDLE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 12 TO WS-IV(1)
     MOVE -35 TO WS-IV(2)
     MOVE 1.7 TO WS-IV(3)
     MOVE 0.9 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 40 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 1 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.761285524 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.yrot" TO WS-NAME
     MOVE -0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.y" TO WS-NAME
     MOVE 1.9984 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.z" TO WS-NAME
     MOVE -13.2 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.y" TO WS-NAME
     MOVE 12.9984 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.z" TO WS-NAME
     MOVE -11.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.y" TO WS-NAME
     MOVE 12.9984 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.z" TO WS-NAME
     MOVE -11.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.190962552 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.190962552 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.305540084 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE 0.305540084 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.xrot" TO WS-NAME
     MOVE 1.1985988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.y" TO WS-NAME
     MOVE -4.1 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.z" TO WS-NAME
     MOVE 3.8 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.yrot" TO WS-NAME
     MOVE -0.962605866 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_saddle_line" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_saddle_line visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_saddle_line" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_saddle_line visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "HORSE_SADDLE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE -20 TO WS-IV(1)
     MOVE 8 TO WS-IV(2)
     MOVE 3.1 TO WS-IV(3)
     MOVE 0.1 TO WS-IV(4)
     MOVE 0.4 TO WS-IV(5)
     MOVE 0.3 TO WS-IV(6)
     MOVE 0.6 TO WS-IV(7)
     MOVE 17.5 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 1 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.xrot" TO WS-NAME
     MOVE 0.914130696 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.yrot" TO WS-NAME
     MOVE 0.125663702 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.y" TO WS-NAME
     MOVE 3.4944 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.z" TO WS-NAME
     MOVE -10.56 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 body.xrot" TO WS-NAME
     MOVE -0.23561946 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.y" TO WS-NAME
     MOVE 9.0384 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.z" TO WS-NAME
     MOVE -9.68 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.y" TO WS-NAME
     MOVE 9.0384 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.z" TO WS-NAME
     MOVE -9.68 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.110596432 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.046483208 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.xrot" TO WS-NAME
     MOVE -0.222788781 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.xrot" TO WS-NAME
     MOVE -0.405529779 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.xrot" TO WS-NAME
     MOVE 0.5985988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.y" TO WS-NAME
     MOVE -4.95 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.z" TO WS-NAME
     MOVE 2.1 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_saddle_line" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_saddle_line visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_saddle_line" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_saddle_line visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "HORSE_SADDLE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 5 TO WS-IV(1)
     MOVE -10 TO WS-IV(2)
     MOVE 0.5 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     MOVE 3.3 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 1 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.xrot" TO WS-NAME
     MOVE 2.173774315 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.y" TO WS-NAME
     MOVE 9.6984 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.z" TO WS-NAME
     MOVE -13.2 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.y" TO WS-NAME
     MOVE 12.9984 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.z" TO WS-NAME
     MOVE -11.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.y" TO WS-NAME
     MOVE 12.9984 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.z" TO WS-NAME
     MOVE -11.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.236258317 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.236258317 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.378013306 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.xrot" TO WS-NAME
     MOVE 0.378013306 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.xrot" TO WS-NAME
     MOVE 0.8985988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.y" TO WS-NAME
     MOVE -4.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.z" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.yrot" TO WS-NAME
     MOVE -0.673699636 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_saddle_line" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_saddle_line visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_saddle_line" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_saddle_line visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "HORSE_SADDLE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 1 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.yrot" TO WS-NAME
     MOVE 0.17453292 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.y" TO WS-NAME
     MOVE -6.8016 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.z" TO WS-NAME
     MOVE -4.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 body.xrot" TO WS-NAME
     MOVE -0.7853982 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.y" TO WS-NAME
     MOVE -0.2016 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.z" TO WS-NAME
     MOVE -6.6 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.y" TO WS-NAME
     MOVE -0.2016 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.z" TO WS-NAME
     MOVE -6.6 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -2.0471976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.0471976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.xrot" TO WS-NAME
     MOVE 0.5235988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.y" TO WS-NAME
     MOVE -5.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.z" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_saddle_line" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_saddle_line visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_saddle_line" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_saddle_line visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "HORSE_SADDLE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 25 TO WS-IV(1)
     MOVE 15 TO WS-IV(2)
     MOVE 2.2 TO WS-IV(3)
     MOVE 0.7 TO WS-IV(4)
     MOVE 0.2 TO WS-IV(5)
     MOVE 0.8 TO WS-IV(6)
     MOVE 0.3 TO WS-IV(7)
     MOVE 9 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 1 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.xrot" TO WS-NAME
     MOVE 1.172433372 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.yrot" TO WS-NAME
     MOVE 0.26179938 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.y" TO WS-NAME
     MOVE -2.0936 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.z" TO WS-NAME
     MOVE -6.16 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 body.xrot" TO WS-NAME
     MOVE -0.62831856 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.y" TO WS-NAME
     MOVE 2.4384 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.z" TO WS-NAME
     MOVE -7.48 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.y" TO WS-NAME
     MOVE 2.4384 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.z" TO WS-NAME
     MOVE -7.48 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.276453651 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.142425389 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.xrot" TO WS-NAME
     MOVE -1.452734991 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.xrot" TO WS-NAME
     MOVE -0.222781169 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.xrot" TO WS-NAME
     MOVE 1.0485988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.y" TO WS-NAME
     MOVE -4.65 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.z" TO WS-NAME
     MOVE 2.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.yrot" TO WS-NAME
     MOVE 0.999858636 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_saddle_line" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_saddle_line visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_saddle_line" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_saddle_line visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "HORSE_SADDLE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 3 TO WS-IV(1)
     MOVE 35 TO WS-IV(2)
     MOVE 0.9 TO WS-IV(3)
     MOVE 0.4 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0.2 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 5 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 1 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.56870714 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.yrot" TO WS-NAME
     MOVE 0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.y" TO WS-NAME
     MOVE 0.2384 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.z" TO WS-NAME
     MOVE -11.44 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 body.xrot" TO WS-NAME
     MOVE -0.15707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.y" TO WS-NAME
     MOVE 10.3584 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.z" TO WS-NAME
     MOVE -10.12 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.y" TO WS-NAME
     MOVE 10.3584 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.z" TO WS-NAME
     MOVE -10.12 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.184451511 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.079731751 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.22278763 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.19609141 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.xrot" TO WS-NAME
     MOVE 0.8235988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.y" TO WS-NAME
     MOVE -4.6 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.z" TO WS-NAME
     MOVE 2.8 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_saddle_line" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_saddle_line visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_saddle_line" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 HORSE_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_saddle_line visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "DONKEY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 12 TO WS-IV(1)
     MOVE -35 TO WS-IV(2)
     MOVE 1.7 TO WS-IV(3)
     MOVE 0.9 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 40 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 1 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.761285524 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.yrot" TO WS-NAME
     MOVE -0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.y" TO WS-NAME
     MOVE 6.60208 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.z" TO WS-NAME
     MOVE -10.44 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.y" TO WS-NAME
     MOVE 15.30208 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.z" TO WS-NAME
     MOVE -8.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.y" TO WS-NAME
     MOVE 15.30208 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.z" TO WS-NAME
     MOVE -8.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.190962552 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.190962552 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.305540084 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE 0.305540084 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.xrot" TO WS-NAME
     MOVE 1.1985988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.y" TO WS-NAME
     MOVE -4.1 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.z" TO WS-NAME
     MOVE 3.8 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.yrot" TO WS-NAME
     MOVE -0.962605866 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "DONKEY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE -20 TO WS-IV(1)
     MOVE 8 TO WS-IV(2)
     MOVE 3.1 TO WS-IV(3)
     MOVE 0.1 TO WS-IV(4)
     MOVE 0.4 TO WS-IV(5)
     MOVE 0.3 TO WS-IV(6)
     MOVE 0.6 TO WS-IV(7)
     MOVE 17.5 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 1 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.xrot" TO WS-NAME
     MOVE 0.914130696 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.yrot" TO WS-NAME
     MOVE 0.125663702 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.y" TO WS-NAME
     MOVE 7.78528 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.z" TO WS-NAME
     MOVE -8.352 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 body.xrot" TO WS-NAME
     MOVE -0.23561946 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.y" TO WS-NAME
     MOVE 12.17008 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.z" TO WS-NAME
     MOVE -7.656 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.y" TO WS-NAME
     MOVE 12.17008 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.z" TO WS-NAME
     MOVE -7.656 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.110596432 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.046483208 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.xrot" TO WS-NAME
     MOVE -0.222788781 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.xrot" TO WS-NAME
     MOVE -0.405529779 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.xrot" TO WS-NAME
     MOVE 0.5985988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.y" TO WS-NAME
     MOVE -4.95 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.z" TO WS-NAME
     MOVE 2.1 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_chest visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_chest visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "DONKEY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 5 TO WS-IV(1)
     MOVE -10 TO WS-IV(2)
     MOVE 0.5 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     MOVE 3.3 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 1 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.xrot" TO WS-NAME
     MOVE 2.173774315 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.y" TO WS-NAME
     MOVE 12.69208 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.z" TO WS-NAME
     MOVE -10.44 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.y" TO WS-NAME
     MOVE 15.30208 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.z" TO WS-NAME
     MOVE -8.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.y" TO WS-NAME
     MOVE 15.30208 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.z" TO WS-NAME
     MOVE -8.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.236258317 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.236258317 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.378013306 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.xrot" TO WS-NAME
     MOVE 0.378013306 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.xrot" TO WS-NAME
     MOVE 0.8985988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.y" TO WS-NAME
     MOVE -4.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.z" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.yrot" TO WS-NAME
     MOVE -0.673699636 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "DONKEY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 1 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.yrot" TO WS-NAME
     MOVE 0.17453292 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.y" TO WS-NAME
     MOVE -0.35792 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.z" TO WS-NAME
     MOVE -3.48 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 body.xrot" TO WS-NAME
     MOVE -0.7853982 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.y" TO WS-NAME
     MOVE 4.86208 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.z" TO WS-NAME
     MOVE -5.22 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.y" TO WS-NAME
     MOVE 4.86208 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.z" TO WS-NAME
     MOVE -5.22 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -2.0471976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.0471976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.xrot" TO WS-NAME
     MOVE 0.5235988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.y" TO WS-NAME
     MOVE -5.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.z" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_chest visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_chest visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "DONKEY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 25 TO WS-IV(1)
     MOVE 15 TO WS-IV(2)
     MOVE 2.2 TO WS-IV(3)
     MOVE 0.7 TO WS-IV(4)
     MOVE 0.2 TO WS-IV(5)
     MOVE 0.8 TO WS-IV(6)
     MOVE 0.3 TO WS-IV(7)
     MOVE 9 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 1 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.xrot" TO WS-NAME
     MOVE 1.172433372 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.yrot" TO WS-NAME
     MOVE 0.26179938 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.y" TO WS-NAME
     MOVE 3.36568 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.z" TO WS-NAME
     MOVE -4.872 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 body.xrot" TO WS-NAME
     MOVE -0.62831856 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.y" TO WS-NAME
     MOVE 6.95008 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.z" TO WS-NAME
     MOVE -5.916 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.y" TO WS-NAME
     MOVE 6.95008 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.z" TO WS-NAME
     MOVE -5.916 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.276453651 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.142425389 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.xrot" TO WS-NAME
     MOVE -1.452734991 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.xrot" TO WS-NAME
     MOVE -0.222781169 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.xrot" TO WS-NAME
     MOVE 1.0485988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.y" TO WS-NAME
     MOVE -4.65 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.z" TO WS-NAME
     MOVE 2.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.yrot" TO WS-NAME
     MOVE 0.999858636 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "DONKEY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 3 TO WS-IV(1)
     MOVE 35 TO WS-IV(2)
     MOVE 0.9 TO WS-IV(3)
     MOVE 0.4 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0.2 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 5 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 1 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.56870714 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.yrot" TO WS-NAME
     MOVE 0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.y" TO WS-NAME
     MOVE 5.21008 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.z" TO WS-NAME
     MOVE -9.048 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 body.xrot" TO WS-NAME
     MOVE -0.15707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.y" TO WS-NAME
     MOVE 13.21408 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.z" TO WS-NAME
     MOVE -8.004 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.y" TO WS-NAME
     MOVE 13.21408 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.z" TO WS-NAME
     MOVE -8.004 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.184451511 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.079731751 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.22278763 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.19609141 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.xrot" TO WS-NAME
     MOVE 0.8235988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.y" TO WS-NAME
     MOVE -4.6 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.z" TO WS-NAME
     MOVE 2.8 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "MULE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 12 TO WS-IV(1)
     MOVE -35 TO WS-IV(2)
     MOVE 1.7 TO WS-IV(3)
     MOVE 0.9 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 40 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 1 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.761285524 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.yrot" TO WS-NAME
     MOVE -0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.y" TO WS-NAME
     MOVE 5.60128 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.z" TO WS-NAME
     MOVE -11.04 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.y" TO WS-NAME
     MOVE 14.80128 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.z" TO WS-NAME
     MOVE -9.2 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.y" TO WS-NAME
     MOVE 14.80128 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.z" TO WS-NAME
     MOVE -9.2 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.190962552 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.190962552 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.305540084 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE 0.305540084 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.xrot" TO WS-NAME
     MOVE 1.1985988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.y" TO WS-NAME
     MOVE -4.1 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.z" TO WS-NAME
     MOVE 3.8 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.yrot" TO WS-NAME
     MOVE -0.962605866 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "MULE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE -20 TO WS-IV(1)
     MOVE 8 TO WS-IV(2)
     MOVE 3.1 TO WS-IV(3)
     MOVE 0.1 TO WS-IV(4)
     MOVE 0.4 TO WS-IV(5)
     MOVE 0.3 TO WS-IV(6)
     MOVE 0.6 TO WS-IV(7)
     MOVE 17.5 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 1 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.xrot" TO WS-NAME
     MOVE 0.914130696 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.yrot" TO WS-NAME
     MOVE 0.125663702 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.y" TO WS-NAME
     MOVE 6.85248 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.z" TO WS-NAME
     MOVE -8.832 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 body.xrot" TO WS-NAME
     MOVE -0.23561946 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.y" TO WS-NAME
     MOVE 11.48928 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.z" TO WS-NAME
     MOVE -8.096 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.y" TO WS-NAME
     MOVE 11.48928 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.z" TO WS-NAME
     MOVE -8.096 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.110596432 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.046483208 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.xrot" TO WS-NAME
     MOVE -0.222788781 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.xrot" TO WS-NAME
     MOVE -0.405529779 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.xrot" TO WS-NAME
     MOVE 0.5985988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.y" TO WS-NAME
     MOVE -4.95 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.z" TO WS-NAME
     MOVE 2.1 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_chest visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_chest visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "MULE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 5 TO WS-IV(1)
     MOVE -10 TO WS-IV(2)
     MOVE 0.5 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     MOVE 3.3 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 1 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.xrot" TO WS-NAME
     MOVE 2.173774315 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.y" TO WS-NAME
     MOVE 12.04128 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.z" TO WS-NAME
     MOVE -11.04 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.y" TO WS-NAME
     MOVE 14.80128 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.z" TO WS-NAME
     MOVE -9.2 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.y" TO WS-NAME
     MOVE 14.80128 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.z" TO WS-NAME
     MOVE -9.2 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.236258317 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.236258317 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.378013306 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.xrot" TO WS-NAME
     MOVE 0.378013306 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.xrot" TO WS-NAME
     MOVE 0.8985988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.y" TO WS-NAME
     MOVE -4.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.z" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.yrot" TO WS-NAME
     MOVE -0.673699636 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "MULE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 1 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.yrot" TO WS-NAME
     MOVE 0.17453292 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.y" TO WS-NAME
     MOVE -1.75872 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.z" TO WS-NAME
     MOVE -3.68 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 body.xrot" TO WS-NAME
     MOVE -0.7853982 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.y" TO WS-NAME
     MOVE 3.76128 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.z" TO WS-NAME
     MOVE -5.52 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.y" TO WS-NAME
     MOVE 3.76128 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.z" TO WS-NAME
     MOVE -5.52 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -2.0471976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.0471976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.xrot" TO WS-NAME
     MOVE 0.5235988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.y" TO WS-NAME
     MOVE -5.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.z" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_chest visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_chest visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "MULE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 25 TO WS-IV(1)
     MOVE 15 TO WS-IV(2)
     MOVE 2.2 TO WS-IV(3)
     MOVE 0.7 TO WS-IV(4)
     MOVE 0.2 TO WS-IV(5)
     MOVE 0.8 TO WS-IV(6)
     MOVE 0.3 TO WS-IV(7)
     MOVE 9 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 1 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.xrot" TO WS-NAME
     MOVE 1.172433372 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.yrot" TO WS-NAME
     MOVE 0.26179938 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.y" TO WS-NAME
     MOVE 2.17888 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.z" TO WS-NAME
     MOVE -5.152 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 body.xrot" TO WS-NAME
     MOVE -0.62831856 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.y" TO WS-NAME
     MOVE 5.96928 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.z" TO WS-NAME
     MOVE -6.256 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.y" TO WS-NAME
     MOVE 5.96928 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.z" TO WS-NAME
     MOVE -6.256 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.276453651 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.142425389 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.xrot" TO WS-NAME
     MOVE -1.452734991 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.xrot" TO WS-NAME
     MOVE -0.222781169 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.xrot" TO WS-NAME
     MOVE 1.0485988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.y" TO WS-NAME
     MOVE -4.65 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.z" TO WS-NAME
     MOVE 2.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.yrot" TO WS-NAME
     MOVE 0.999858636 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "MULE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 3 TO WS-IV(1)
     MOVE 35 TO WS-IV(2)
     MOVE 0.9 TO WS-IV(3)
     MOVE 0.4 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0.2 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 5 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 1 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.56870714 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.yrot" TO WS-NAME
     MOVE 0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.y" TO WS-NAME
     MOVE 4.12928 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.z" TO WS-NAME
     MOVE -9.568 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 body.xrot" TO WS-NAME
     MOVE -0.15707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.y" TO WS-NAME
     MOVE 12.59328 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.z" TO WS-NAME
     MOVE -8.464 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.y" TO WS-NAME
     MOVE 12.59328 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.z" TO WS-NAME
     MOVE -8.464 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.184451511 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.079731751 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.22278763 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.19609141 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.xrot" TO WS-NAME
     MOVE 0.8235988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.y" TO WS-NAME
     MOVE -4.6 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.z" TO WS-NAME
     MOVE 2.8 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 MULE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "DONKEY_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 12 TO WS-IV(1)
     MOVE -35 TO WS-IV(2)
     MOVE 1.7 TO WS-IV(3)
     MOVE 0.9 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 40 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 2 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 1 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.00000004 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.yrot" TO WS-NAME
     MOVE -0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.y" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.z" TO WS-NAME
     MOVE -5.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.y" TO WS-NAME
     MOVE 3.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.z" TO WS-NAME
     MOVE -5.3 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.y" TO WS-NAME
     MOVE 3.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.z" TO WS-NAME
     MOVE -5.3 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.190962552 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.190962552 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.305540084 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE 0.305540084 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.xrot" TO WS-NAME
     MOVE 0.4132006 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.y" TO WS-NAME
     MOVE -0.6 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.z" TO WS-NAME
     MOVE 8.3 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.yrot" TO WS-NAME
     MOVE -0.962605866 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_hind_leg.y" TO WS-NAME
     MOVE 3.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_hind_leg.y" TO WS-NAME
     MOVE 3.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.3 DONKEY_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 state xRot written (-30)" TO WS-NAME
     MOVE -30 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "DONKEY_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE -20 TO WS-IV(1)
     MOVE 8 TO WS-IV(2)
     MOVE 3.1 TO WS-IV(3)
     MOVE 0.1 TO WS-IV(4)
     MOVE 0.4 TO WS-IV(5)
     MOVE 0.3 TO WS-IV(6)
     MOVE 0.6 TO WS-IV(7)
     MOVE 17.5 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     MOVE 2 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 1 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.xrot" TO WS-NAME
     MOVE 0.512704988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.yrot" TO WS-NAME
     MOVE 0.125663702 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.y" TO WS-NAME
     MOVE -2.28 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.z" TO WS-NAME
     MOVE -4.58 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 body.xrot" TO WS-NAME
     MOVE -0.23561946 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.y" TO WS-NAME
     MOVE 3.2 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.z" TO WS-NAME
     MOVE -5.15 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.y" TO WS-NAME
     MOVE 3.2 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.z" TO WS-NAME
     MOVE -5.15 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.346215892 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.282102668 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.xrot" TO WS-NAME
     MOVE 0.091370499 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.xrot" TO WS-NAME
     MOVE -0.091370499 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.xrot" TO WS-NAME
     MOVE -0.1867994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.y" TO WS-NAME
     MOVE -1.45 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.z" TO WS-NAME
     MOVE 6.6 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_hind_leg.y" TO WS-NAME
     MOVE 2.36 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_hind_leg.y" TO WS-NAME
     MOVE 1.562 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_chest visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_chest visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.3 DONKEY_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 state xRot written (-30)" TO WS-NAME
     MOVE -30 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "DONKEY_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 5 TO WS-IV(1)
     MOVE -10 TO WS-IV(2)
     MOVE 0.5 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     MOVE 3.3 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 2 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 1 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.xrot" TO WS-NAME
     MOVE 1.562909115 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.y" TO WS-NAME
     MOVE -1.2 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.z" TO WS-NAME
     MOVE -5.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.y" TO WS-NAME
     MOVE 3.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.z" TO WS-NAME
     MOVE -5.3 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.y" TO WS-NAME
     MOVE 3.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.z" TO WS-NAME
     MOVE -5.3 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.236258317 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.236258317 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.378013306 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.xrot" TO WS-NAME
     MOVE 0.378013306 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.xrot" TO WS-NAME
     MOVE 0.1132006 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.y" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.z" TO WS-NAME
     MOVE 7.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.yrot" TO WS-NAME
     MOVE -0.673699636 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_hind_leg.y" TO WS-NAME
     MOVE 3.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_hind_leg.y" TO WS-NAME
     MOVE 3.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.3 DONKEY_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 state xRot written (-30)" TO WS-NAME
     MOVE -30 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "DONKEY_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 2 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 1 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.xrot" TO WS-NAME
     MOVE -0.26179936 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.yrot" TO WS-NAME
     MOVE 0.17453292 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.y" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.z" TO WS-NAME
     MOVE -3.6 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 body.xrot" TO WS-NAME
     MOVE -0.7853982 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.y" TO WS-NAME
     MOVE 2.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.z" TO WS-NAME
     MOVE -4.8 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.y" TO WS-NAME
     MOVE 2.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.z" TO WS-NAME
     MOVE -4.8 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 1.0471976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE 1.0471976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE 1.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.xrot" TO WS-NAME
     MOVE -0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.y" TO WS-NAME
     MOVE -1.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.z" TO WS-NAME
     MOVE 6.5 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_hind_leg.y" TO WS-NAME
     MOVE -0.3 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_hind_leg.y" TO WS-NAME
     MOVE -0.3 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_chest visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_chest visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.3 DONKEY_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 state xRot written (-30)" TO WS-NAME
     MOVE -30 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "DONKEY_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 25 TO WS-IV(1)
     MOVE 15 TO WS-IV(2)
     MOVE 2.2 TO WS-IV(3)
     MOVE 0.7 TO WS-IV(4)
     MOVE 0.2 TO WS-IV(5)
     MOVE 0.8 TO WS-IV(6)
     MOVE 0.3 TO WS-IV(7)
     MOVE 9 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     MOVE 2 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 1 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.xrot" TO WS-NAME
     MOVE 0.11007734 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.yrot" TO WS-NAME
     MOVE 0.26179938 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.y" TO WS-NAME
     MOVE -2.64 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.z" TO WS-NAME
     MOVE -3.88 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 body.xrot" TO WS-NAME
     MOVE -0.62831856 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.y" TO WS-NAME
     MOVE 2.7 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.z" TO WS-NAME
     MOVE -4.9 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.y" TO WS-NAME
     MOVE 2.7 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.z" TO WS-NAME
     MOVE -4.9 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.904772211 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.770743949 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.xrot" TO WS-NAME
     MOVE -0.614976911 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.xrot" TO WS-NAME
     MOVE 0.614976911 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.xrot" TO WS-NAME
     MOVE 0.2632006 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.y" TO WS-NAME
     MOVE -1.15 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.z" TO WS-NAME
     MOVE 7.2 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.yrot" TO WS-NAME
     MOVE 0.999858636 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_hind_leg.y" TO WS-NAME
     MOVE 0.46 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_hind_leg.y" TO WS-NAME
     MOVE -0.148 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.3 DONKEY_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 state xRot written (-30)" TO WS-NAME
     MOVE -30 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "DONKEY_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 3 TO WS-IV(1)
     MOVE 35 TO WS-IV(2)
     MOVE 0.9 TO WS-IV(3)
     MOVE 0.4 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0.2 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 5 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 2 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 1 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.xrot" TO WS-NAME
     MOVE -0.05235984 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.yrot" TO WS-NAME
     MOVE 0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.y" TO WS-NAME
     MOVE -3.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.z" TO WS-NAME
     MOVE -4.72 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 body.xrot" TO WS-NAME
     MOVE -0.15707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.y" TO WS-NAME
     MOVE 3.3 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.z" TO WS-NAME
     MOVE -5.2 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.y" TO WS-NAME
     MOVE 3.3 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.z" TO WS-NAME
     MOVE -5.2 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.341531151 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.077347889 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.01334811 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE 0.01334811 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.xrot" TO WS-NAME
     MOVE 0.0382006 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.y" TO WS-NAME
     MOVE -1.1 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.z" TO WS-NAME
     MOVE 7.3 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_hind_leg.y" TO WS-NAME
     MOVE 2.74 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_hind_leg.y" TO WS-NAME
     MOVE 2.132 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "8.3 DONKEY_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 state xRot written (-30)" TO WS-NAME
     MOVE -30 TO WS-E
     MOVE WS-IV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "DONKEY_SADDLE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 12 TO WS-IV(1)
     MOVE -35 TO WS-IV(2)
     MOVE 1.7 TO WS-IV(3)
     MOVE 0.9 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 40 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 1 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.761285524 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.yrot" TO WS-NAME
     MOVE -0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.y" TO WS-NAME
     MOVE 6.60208 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.z" TO WS-NAME
     MOVE -10.44 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.y" TO WS-NAME
     MOVE 15.30208 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.z" TO WS-NAME
     MOVE -8.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.y" TO WS-NAME
     MOVE 15.30208 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.z" TO WS-NAME
     MOVE -8.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.190962552 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.190962552 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.305540084 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE 0.305540084 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.xrot" TO WS-NAME
     MOVE 1.1985988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.y" TO WS-NAME
     MOVE -4.1 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.z" TO WS-NAME
     MOVE 3.8 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.yrot" TO WS-NAME
     MOVE -0.962605866 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_saddle_line" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_saddle_line visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_saddle_line" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_saddle_line visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "DONKEY_SADDLE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE -20 TO WS-IV(1)
     MOVE 8 TO WS-IV(2)
     MOVE 3.1 TO WS-IV(3)
     MOVE 0.1 TO WS-IV(4)
     MOVE 0.4 TO WS-IV(5)
     MOVE 0.3 TO WS-IV(6)
     MOVE 0.6 TO WS-IV(7)
     MOVE 17.5 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 1 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.xrot" TO WS-NAME
     MOVE 0.914130696 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.yrot" TO WS-NAME
     MOVE 0.125663702 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.y" TO WS-NAME
     MOVE 7.78528 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.z" TO WS-NAME
     MOVE -8.352 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 body.xrot" TO WS-NAME
     MOVE -0.23561946 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.y" TO WS-NAME
     MOVE 12.17008 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.z" TO WS-NAME
     MOVE -7.656 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.y" TO WS-NAME
     MOVE 12.17008 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.z" TO WS-NAME
     MOVE -7.656 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.110596432 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.046483208 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.xrot" TO WS-NAME
     MOVE -0.222788781 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.xrot" TO WS-NAME
     MOVE -0.405529779 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.xrot" TO WS-NAME
     MOVE 0.5985988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.y" TO WS-NAME
     MOVE -4.95 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.z" TO WS-NAME
     MOVE 2.1 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_saddle_line" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_saddle_line visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_saddle_line" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_saddle_line visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "DONKEY_SADDLE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 5 TO WS-IV(1)
     MOVE -10 TO WS-IV(2)
     MOVE 0.5 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     MOVE 3.3 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 1 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.xrot" TO WS-NAME
     MOVE 2.173774315 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.y" TO WS-NAME
     MOVE 12.69208 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.z" TO WS-NAME
     MOVE -10.44 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.y" TO WS-NAME
     MOVE 15.30208 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.z" TO WS-NAME
     MOVE -8.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.y" TO WS-NAME
     MOVE 15.30208 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.z" TO WS-NAME
     MOVE -8.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.236258317 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.236258317 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.378013306 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.xrot" TO WS-NAME
     MOVE 0.378013306 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.xrot" TO WS-NAME
     MOVE 0.8985988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.y" TO WS-NAME
     MOVE -4.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.z" TO WS-NAME
     MOVE 3.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.yrot" TO WS-NAME
     MOVE -0.673699636 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_saddle_line" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_saddle_line visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_saddle_line" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_saddle_line visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "DONKEY_SADDLE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 1 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.yrot" TO WS-NAME
     MOVE 0.17453292 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.y" TO WS-NAME
     MOVE -0.35792 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.z" TO WS-NAME
     MOVE -3.48 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 body.xrot" TO WS-NAME
     MOVE -0.7853982 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.y" TO WS-NAME
     MOVE 4.86208 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.z" TO WS-NAME
     MOVE -5.22 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.y" TO WS-NAME
     MOVE 4.86208 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.z" TO WS-NAME
     MOVE -5.22 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -2.0471976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.0471976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.xrot" TO WS-NAME
     MOVE 0.5235988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.y" TO WS-NAME
     MOVE -5.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.z" TO WS-NAME
     MOVE 2.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_saddle_line" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_saddle_line visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_saddle_line" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_saddle_line visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "DONKEY_SADDLE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 25 TO WS-IV(1)
     MOVE 15 TO WS-IV(2)
     MOVE 2.2 TO WS-IV(3)
     MOVE 0.7 TO WS-IV(4)
     MOVE 0.2 TO WS-IV(5)
     MOVE 0.8 TO WS-IV(6)
     MOVE 0.3 TO WS-IV(7)
     MOVE 9 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 1 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.xrot" TO WS-NAME
     MOVE 1.172433372 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.yrot" TO WS-NAME
     MOVE 0.26179938 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.y" TO WS-NAME
     MOVE 3.36568 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.z" TO WS-NAME
     MOVE -4.872 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 body.xrot" TO WS-NAME
     MOVE -0.62831856 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.y" TO WS-NAME
     MOVE 6.95008 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.z" TO WS-NAME
     MOVE -5.916 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.y" TO WS-NAME
     MOVE 6.95008 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.z" TO WS-NAME
     MOVE -5.916 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.276453651 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.142425389 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.xrot" TO WS-NAME
     MOVE -1.452734991 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.xrot" TO WS-NAME
     MOVE -0.222781169 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.xrot" TO WS-NAME
     MOVE 1.0485988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.y" TO WS-NAME
     MOVE -4.65 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.z" TO WS-NAME
     MOVE 2.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.yrot" TO WS-NAME
     MOVE 0.999858636 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_saddle_line" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_saddle_line visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_saddle_line" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_saddle_line visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "DONKEY_SADDLE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 3 TO WS-IV(1)
     MOVE 35 TO WS-IV(2)
     MOVE 0.9 TO WS-IV(3)
     MOVE 0.4 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0.2 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 5 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 1 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.56870714 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.yrot" TO WS-NAME
     MOVE 0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.y" TO WS-NAME
     MOVE 5.21008 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.z" TO WS-NAME
     MOVE -9.048 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 body.xrot" TO WS-NAME
     MOVE -0.15707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.y" TO WS-NAME
     MOVE 13.21408 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.z" TO WS-NAME
     MOVE -8.004 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.y" TO WS-NAME
     MOVE 13.21408 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.z" TO WS-NAME
     MOVE -8.004 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.184451511 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.079731751 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.22278763 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.19609141 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.xrot" TO WS-NAME
     MOVE 0.8235988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.y" TO WS-NAME
     MOVE -4.6 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.z" TO WS-NAME
     MOVE 2.8 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_saddle_line" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_saddle_line visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_saddle_line" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 DONKEY_SADDLE state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_saddle_line visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_HORSE_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 12 TO WS-IV(1)
     MOVE -35 TO WS-IV(2)
     MOVE 1.7 TO WS-IV(3)
     MOVE 0.9 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 40 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 1 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.761285524 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.yrot" TO WS-NAME
     MOVE -0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.y" TO WS-NAME
     MOVE 10.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 head_parts.z" TO WS-NAME
     MOVE -6.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.y" TO WS-NAME
     MOVE 16.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.y" TO WS-NAME
     MOVE 16.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.190962552 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.190962552 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.305540084 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE 0.305540084 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.xrot" TO WS-NAME
     MOVE -0.3721976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.y" TO WS-NAME
     MOVE -0.1 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.z" TO WS-NAME
     MOVE 8.8 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 12.0/-35.0/1.7/0.9/0.0/0.0/0.0 tail.yrot" TO WS-NAME
     MOVE -0.962605866 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_HORSE_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE -20 TO WS-IV(1)
     MOVE 8 TO WS-IV(2)
     MOVE 3.1 TO WS-IV(3)
     MOVE 0.1 TO WS-IV(4)
     MOVE 0.4 TO WS-IV(5)
     MOVE 0.3 TO WS-IV(6)
     MOVE 0.6 TO WS-IV(7)
     MOVE 17.5 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     MOVE 1 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.xrot" TO WS-NAME
     MOVE 0.914130696 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.yrot" TO WS-NAME
     MOVE 0.125663702 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.y" TO WS-NAME
     MOVE 10.44 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 head_parts.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 body.xrot" TO WS-NAME
     MOVE -0.23561946 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.y" TO WS-NAME
     MOVE 14.8 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.y" TO WS-NAME
     MOVE 14.8 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.110596432 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.046483208 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 left_front_leg.xrot" TO WS-NAME
     MOVE -0.222788781 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 right_front_leg.xrot" TO WS-NAME
     MOVE -0.405529779 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.xrot" TO WS-NAME
     MOVE -0.9721976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.y" TO WS-NAME
     MOVE -0.95 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.z" TO WS-NAME
     MOVE 7.1 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state -20.0/8.0/3.1/0.1/0.4/0.3/0.6 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_HORSE_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 5 TO WS-IV(1)
     MOVE -10 TO WS-IV(2)
     MOVE 0.5 TO WS-IV(3)
     MOVE 0.5 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 1 TO WS-IV(7)
     MOVE 3.3 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 1 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.xrot" TO WS-NAME
     MOVE 2.173774315 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.y" TO WS-NAME
     MOVE 12.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 head_parts.z" TO WS-NAME
     MOVE -6.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 body.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.y" TO WS-NAME
     MOVE 16.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.y" TO WS-NAME
     MOVE 16.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.236258317 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.236258317 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.378013306 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 right_front_leg.xrot" TO WS-NAME
     MOVE 0.378013306 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.xrot" TO WS-NAME
     MOVE -0.6721976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.y" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.z" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 5.0/-10.0/0.5/0.5/1.0/0.0/1.0 tail.yrot" TO WS-NAME
     MOVE -0.673699636 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_HORSE_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 0 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 1 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.yrot" TO WS-NAME
     MOVE 0.17453292 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.y" TO WS-NAME
     MOVE 8.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 head_parts.z" TO WS-NAME
     MOVE -4.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 body.xrot" TO WS-NAME
     MOVE -0.7853982 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.y" TO WS-NAME
     MOVE 12.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.y" TO WS-NAME
     MOVE 12.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -2.0471976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.0471976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.xrot" TO WS-NAME
     MOVE -1.0471976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.y" TO WS-NAME
     MOVE -1.0 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.z" TO WS-NAME
     MOVE 7.0 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 0.0/10.0/0.0/0.0/0.0/1.0/0.0 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_HORSE_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 25 TO WS-IV(1)
     MOVE 15 TO WS-IV(2)
     MOVE 2.2 TO WS-IV(3)
     MOVE 0.7 TO WS-IV(4)
     MOVE 0.2 TO WS-IV(5)
     MOVE 0.8 TO WS-IV(6)
     MOVE 0.3 TO WS-IV(7)
     MOVE 9 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 1 TO WS-IV(10)
     MOVE 1 TO WS-IV(11)
     MOVE 1 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.xrot" TO WS-NAME
     MOVE 1.172433372 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.yrot" TO WS-NAME
     MOVE 0.26179938 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.y" TO WS-NAME
     MOVE 9.12 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 head_parts.z" TO WS-NAME
     MOVE -4.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 body.xrot" TO WS-NAME
     MOVE -0.62831856 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.y" TO WS-NAME
     MOVE 12.8 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.y" TO WS-NAME
     MOVE 12.8 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.276453651 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.142425389 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 left_front_leg.xrot" TO WS-NAME
     MOVE -1.452734991 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 right_front_leg.xrot" TO WS-NAME
     MOVE -0.222781169 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.xrot" TO WS-NAME
     MOVE -0.5221976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.y" TO WS-NAME
     MOVE -0.65 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.z" TO WS-NAME
     MOVE 7.7 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 25.0/15.0/2.2/0.7/0.2/0.8/0.3 tail.yrot" TO WS-NAME
     MOVE 0.999858636 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "ZOMBIE_HORSE_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 3 TO MM-CXROT(2)
     MOVE 3 TO WS-IV(1)
     MOVE 35 TO WS-IV(2)
     MOVE 0.9 TO WS-IV(3)
     MOVE 0.4 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0.2 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 5 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 1 TO WS-IV(12)
     MOVE 1 TO WS-IV(13)
     MOVE 1 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.xrot" TO WS-NAME
     MOVE 0.56870714 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.yrot" TO WS-NAME
     MOVE 0.34906584 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.y" TO WS-NAME
     MOVE 9.6 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 head_parts.z" TO WS-NAME
     MOVE -5.6 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 body.xrot" TO WS-NAME
     MOVE -0.15707964 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.y" TO WS-NAME
     MOVE 15.2 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.y" TO WS-NAME
     MOVE 15.2 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.z" TO WS-NAME
     MOVE -5.4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.184451511 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.079731751 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 left_front_leg.xrot" TO WS-NAME
     MOVE -0.22278763 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.19609141 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.xrot" TO WS-NAME
     MOVE -0.7471976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.y" TO WS-NAME
     MOVE -0.6 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.z" TO WS-NAME
     MOVE 7.8 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 ZOMBIE_HORSE_BABY state 3.0/35.0/0.9/0.4/0.0/0.2/0.0 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "SKELETON_HORSE" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 0 TO WS-IV(1)
     MOVE 10 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     MOVE 1 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 0 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 0 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     MOVE 0 TO WS-IV(17)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 worked example 3 head_parts.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 worked example 3 head_parts.yrot" TO WS-NAME
     MOVE 0.1745329 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 worked example 3 head_parts.y" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 worked example 3 head_parts.z" TO WS-NAME
     MOVE -4 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "body" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 worked example 3 body.xrot" TO WS-NAME
     MOVE -0.7853982 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 worked example 3 left_front_leg.y" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 worked example 3 left_front_leg.z" TO WS-NAME
     MOVE -6 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 worked example 3 right_front_leg.y" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE MM-CY(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 worked example 3 right_front_leg.z" TO WS-NAME
     MOVE -6 TO WS-E
     MOVE MM-CZ(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 worked example 3 left_front_leg.xrot" TO WS-NAME
     MOVE -2.0471976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 worked example 3 right_front_leg.xrot" TO WS-NAME
     MOVE -0.0471976 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 worked example 3 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 worked example 3 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 worked example 3 tail.xrot" TO WS-NAME
     MOVE 0.5235988 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "tail" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 worked example 3 tail.yrot" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "DONKEY_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 25 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 11 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 2 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 1 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 worked example 5 baby donkey head stand 0" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "DONKEY_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 25 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 1 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 11 TO WS-IV(8)
     MOVE 0.5 TO WS-IV(9)
     MOVE 0 TO WS-IV(10)
     MOVE 0 TO WS-IV(11)
     MOVE 2 TO WS-IV(12)
     MOVE 0 TO WS-IV(13)
     MOVE 0 TO WS-IV(14)
     MOVE 1 TO WS-IV(15)
     MOVE 0 TO WS-IV(16)
     CALL "EF4-EQUINE-ANIM" USING EMM-MODEL WS-IN
     MOVE "head_parts" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "8.3 worked example 5 baby donkey head stand 1" TO WS-NAME
     MOVE -0.2617994 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-4§8 Equines: horse, donkey, mule, skeleton horse, zombie horse: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-4§8 Equines: horse, donkey, mule, skeleton horse, zombie horse: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-4-8.
