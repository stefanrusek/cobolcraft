*> Acceptance test of docs/protocol/34-entity-models-4-farm-animals-equines.md section 9 (Llama and trader llama): 9.1 variants (clamping id map), textures, the chest rule, 9.2 setupAnim, 9.3 the decor layer algorithm
*> (player carpet, trader carpet, nothing; adult and baby decor models), 9.4 the geometry of llama, llama_baby, llama_decor (grow 0.5), llama_baby_decor (grow 0.2) and the trader aliases, 9.5 llama spit (pose operations, texture, mesh).
*> Mesh rows are the tables of the document; formula values were worked by an independent script.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-4-9.
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
     MOVE "LLAMA" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer LLAMA is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§9 Llama and trader llama 9.4 LLAMA" TO CK-PREFIX
     MOVE "P head root 0 7 -6 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -2 -14 -10 4 4 9 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 14 -4 -16 -6 8 18 6 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 17 0 -4 -19 -4 3 3 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 17 0 1 -19 -4 3 3 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 5 2 1.5707964 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 29 0 -6 -10 -7 12 18 10 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_chest root -8.5 3 3 0 1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_chest 45 28 -3 0 0 8 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_chest root 5.5 3 3 0 1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_chest 45 41 -3 0 0 8 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -3.5 10 6 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 29 29 -2 0 -2 4 14 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 3.5 10 6 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 29 29 -2 0 -2 4 14 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -3.5 10 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 29 29 -2 0 -2 4 14 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 3.5 10 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 29 29 -2 0 -2 4 14 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "9.4 LLAMA: parts below the root" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.4 LLAMA: cuboids" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.4 LLAMA: texture width" TO WS-NAME
     MOVE 128.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.4 LLAMA: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "TRADER_LLAMA" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer TRADER_LLAMA is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§9 Llama and trader llama 9.4 TRADER_LLAMA" TO CK-PREFIX
     MOVE "P head root 0 7 -6 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -2 -14 -10 4 4 9 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 14 -4 -16 -6 8 18 6 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 17 0 -4 -19 -4 3 3 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 17 0 1 -19 -4 3 3 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 5 2 1.5707964 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 29 0 -6 -10 -7 12 18 10 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_chest root -8.5 3 3 0 1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_chest 45 28 -3 0 0 8 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_chest root 5.5 3 3 0 1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_chest 45 41 -3 0 0 8 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -3.5 10 6 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 29 29 -2 0 -2 4 14 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 3.5 10 6 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 29 29 -2 0 -2 4 14 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -3.5 10 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 29 29 -2 0 -2 4 14 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 3.5 10 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 29 29 -2 0 -2 4 14 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "9.4 TRADER_LLAMA: parts below the root" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.4 TRADER_LLAMA: cuboids" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.4 TRADER_LLAMA: texture width" TO WS-NAME
     MOVE 128.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.4 TRADER_LLAMA: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "LLAMA_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer LLAMA_BABY is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§9 Llama and trader llama 9.4 LLAMA_BABY" TO CK-PREFIX
     MOVE "P head root 0 12 -4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -3 -9 -4 6 11 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 15 -1.5 -7 -7 3 3 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 20 4 0.5 -11 -3 2 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 20 0 -2.5 -11 -3 2 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -2.5 16.5 4.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 0 45 -1.4 -0.5 -1.5 3 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 2.5 16.5 4.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 12 45 -1.6 -0.5 -1.5 3 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -2.5 16.5 -3.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 0 34 -1.4 -0.5 -1.5 3 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 2.5 16.5 -3.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 12 34 -1.6 -0.5 -1.5 3 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 14 2.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 15 -4 -3 -8.5 8 6 13 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_chest root -8.5 4 3 0 1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_chest 45 28 -3 0 0 8 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_chest root 5.5 4 3 0 1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_chest 45 41 -3 0 0 8 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "9.4 LLAMA_BABY: parts below the root" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.4 LLAMA_BABY: cuboids" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.4 LLAMA_BABY: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.4 LLAMA_BABY: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "TRADER_LLAMA_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer TRADER_LLAMA_BABY is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§9 Llama and trader llama 9.4 TRADER_LLAMA_BABY" TO CK-PREFIX
     MOVE "P head root 0 12 -4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -3 -9 -4 6 11 4 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 15 -1.5 -7 -7 3 3 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 20 4 0.5 -11 -3 2 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 20 0 -2.5 -11 -3 2 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -2.5 16.5 4.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 0 45 -1.4 -0.5 -1.5 3 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 2.5 16.5 4.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 12 45 -1.6 -0.5 -1.5 3 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -2.5 16.5 -3.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 0 34 -1.4 -0.5 -1.5 3 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 2.5 16.5 -3.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 12 34 -1.6 -0.5 -1.5 3 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 14 2.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 15 -4 -3 -8.5 8 6 13 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_chest root -8.5 4 3 0 1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_chest 45 28 -3 0 0 8 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_chest root 5.5 4 3 0 1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_chest 45 41 -3 0 0 8 8 3 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "9.4 TRADER_LLAMA_BABY: parts below the root" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.4 TRADER_LLAMA_BABY: cuboids" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.4 TRADER_LLAMA_BABY: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.4 TRADER_LLAMA_BABY: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "LLAMA_DECOR" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer LLAMA_DECOR is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§9 Llama and trader llama 9.4 LLAMA_DECOR" TO CK-PREFIX
     MOVE "P head root 0 7 -6 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -2 -14 -10 4 4 9 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 14 -4 -16 -6 8 18 6 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 17 0 -4 -19 -4 3 3 2 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 17 0 1 -19 -4 3 3 2 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 5 2 1.5707964 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 29 0 -6 -10 -7 12 18 10 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_chest root -8.5 3 3 0 1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_chest 45 28 -3 0 0 8 8 3 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_chest root 5.5 3 3 0 1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_chest 45 41 -3 0 0 8 8 3 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -3.5 10 6 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 29 29 -2 0 -2 4 14 4 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 3.5 10 6 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 29 29 -2 0 -2 4 14 4 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -3.5 10 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 29 29 -2 0 -2 4 14 4 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 3.5 10 -5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 29 29 -2 0 -2 4 14 4 0.5 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "9.4 LLAMA_DECOR: parts below the root" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.4 LLAMA_DECOR: cuboids" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.4 LLAMA_DECOR: texture width" TO WS-NAME
     MOVE 128.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.4 LLAMA_DECOR: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "LLAMA_BABY_DECOR" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer LLAMA_BABY_DECOR is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§9 Llama and trader llama 9.4 LLAMA_BABY_DECOR" TO CK-PREFIX
     MOVE "P head root 0 12 -4 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 0 -3 -9 -4 6 11 4 0.2 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 0 15 -1.5 -7 -7 3 3 3 0.2 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 20 4 0.5 -11 -3 2 2 2 0.2 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C head 20 0 -2.5 -11 -3 2 2 2 0.2 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_hind_leg root -2.5 16.5 4.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_hind_leg 0 45 -1.4 -0.5 -1.5 3 8 3 0.2 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_hind_leg root 2.5 16.5 4.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_hind_leg 12 45 -1.6 -0.5 -1.5 3 8 3 0.2 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_front_leg root -2.5 16.5 -3.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_front_leg 0 34 -1.4 -0.5 -1.5 3 8 3 0.2 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_front_leg root 2.5 16.5 -3.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_front_leg 12 34 -1.6 -0.5 -1.5 3 8 3 0.2 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P body root 0 14 2.5 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C body 0 15 -4 -3 -8.5 8 6 13 0.2 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right_chest root -8.5 4 3 0 1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right_chest 45 28 -3 0 0 8 8 3 0.2 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left_chest root 5.5 4 3 0 1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left_chest 45 41 -3 0 0 8 8 3 0.2 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "9.4 LLAMA_BABY_DECOR: parts below the root" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.4 LLAMA_BABY_DECOR: cuboids" TO WS-NAME
     MOVE 11 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.4 LLAMA_BABY_DECOR: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.4 LLAMA_BABY_DECOR: texture height" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "LLAMA_SPIT" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer LLAMA_SPIT is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-4§9 Llama and trader llama 9.4 LLAMA_SPIT" TO CK-PREFIX
     MOVE "P main root 0 0 0 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C main 0 0 -4 0 0 2 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C main 0 0 0 -4 0 2 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C main 0 0 0 0 -4 2 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C main 0 0 0 0 0 2 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C main 0 0 2 0 0 2 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C main 0 0 0 2 0 2 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C main 0 0 0 0 2 2 2 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "9.4 LLAMA_SPIT: parts below the root" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.4 LLAMA_SPIT: cuboids" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.4 LLAMA_SPIT: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.4 LLAMA_SPIT: texture height" TO WS-NAME
     MOVE 32.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF4-LLAMA-VARIANT" USING WS-IN WS-OUT
     MOVE "9.1 variant id 0 clamps" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF4-LLAMA-VARIANT" USING WS-IN WS-OUT
     MOVE "9.1 variant id 1 clamps" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     CALL "EF4-LLAMA-VARIANT" USING WS-IN WS-OUT
     MOVE "9.1 variant id 2 clamps" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     CALL "EF4-LLAMA-VARIANT" USING WS-IN WS-OUT
     MOVE "9.1 variant id 3 clamps" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4 TO WS-IV(1)
     CALL "EF4-LLAMA-VARIANT" USING WS-IN WS-OUT
     MOVE "9.1 variant id 4 clamps" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 9 TO WS-IV(1)
     CALL "EF4-LLAMA-VARIANT" USING WS-IN WS-OUT
     MOVE "9.1 variant id 9 clamps" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE -1 TO WS-IV(1)
     CALL "EF4-LLAMA-VARIANT" USING WS-IN WS-OUT
     MOVE "9.1 variant id -1 clamps" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-LLAMA-TEXTURE" USING WS-IN WS-X120
     MOVE "9.1 variant 0 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/llama/llama_creamy.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-LLAMA-TEXTURE" USING WS-IN WS-X120
     MOVE "9.1 variant 0 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/llama/llama_creamy_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-LLAMA-TEXTURE" USING WS-IN WS-X120
     MOVE "9.1 variant 1 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/llama/llama_white.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-LLAMA-TEXTURE" USING WS-IN WS-X120
     MOVE "9.1 variant 1 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/llama/llama_white_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 2 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-LLAMA-TEXTURE" USING WS-IN WS-X120
     MOVE "9.1 variant 2 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/llama/llama_brown.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 2 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-LLAMA-TEXTURE" USING WS-IN WS-X120
     MOVE "9.1 variant 2 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/llama/llama_brown_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 3 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-LLAMA-TEXTURE" USING WS-IN WS-X120
     MOVE "9.1 variant 3 baby 0 texture" TO WS-NAME
     MOVE "textures/entity/llama/llama_gray.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 3 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-LLAMA-TEXTURE" USING WS-IN WS-X120
     MOVE "9.1 variant 3 baby 1 texture" TO WS-NAME
     MOVE "textures/entity/llama/llama_gray_baby.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-LLAMA-CHEST" USING WS-IN WS-OUT
     MOVE "9.1 hasChest 0 baby 0 state chest" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-LLAMA-CHEST" USING WS-IN WS-OUT
     MOVE "9.1 hasChest 0 baby 1 state chest" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF4-LLAMA-CHEST" USING WS-IN WS-OUT
     MOVE "9.1 hasChest 1 baby 0 state chest" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF4-LLAMA-CHEST" USING WS-IN WS-OUT
     MOVE "9.1 hasChest 1 baby 1 state chest" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF4-LLAMA-DECOR" USING WS-IN WS-OUT
     MOVE "9.3 carpet item 0 baby 0 trader 0: mode (0 none, 1 the item carpet, 2 trader carpet), baby decor model [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 carpet item 0 baby 0 trader 0: mode (0 none, 1 the item carpet, 2 trader carpet), baby decor model [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF4-LLAMA-DECOR" USING WS-IN WS-OUT
     MOVE "9.3 carpet item 0 baby 0 trader 1: mode (0 none, 1 the item carpet, 2 trader carpet), baby decor model [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 carpet item 0 baby 0 trader 1: mode (0 none, 1 the item carpet, 2 trader carpet), baby decor model [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF4-LLAMA-DECOR" USING WS-IN WS-OUT
     MOVE "9.3 carpet item 0 baby 1 trader 0: mode (0 none, 1 the item carpet, 2 trader carpet), baby decor model [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 carpet item 0 baby 1 trader 0: mode (0 none, 1 the item carpet, 2 trader carpet), baby decor model [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF4-LLAMA-DECOR" USING WS-IN WS-OUT
     MOVE "9.3 carpet item 0 baby 1 trader 1: mode (0 none, 1 the item carpet, 2 trader carpet), baby decor model [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 carpet item 0 baby 1 trader 1: mode (0 none, 1 the item carpet, 2 trader carpet), baby decor model [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF4-LLAMA-DECOR" USING WS-IN WS-OUT
     MOVE "9.3 carpet item 1 baby 0 trader 0: mode (0 none, 1 the item carpet, 2 trader carpet), baby decor model [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 carpet item 1 baby 0 trader 0: mode (0 none, 1 the item carpet, 2 trader carpet), baby decor model [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF4-LLAMA-DECOR" USING WS-IN WS-OUT
     MOVE "9.3 carpet item 1 baby 0 trader 1: mode (0 none, 1 the item carpet, 2 trader carpet), baby decor model [1]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 carpet item 1 baby 0 trader 1: mode (0 none, 1 the item carpet, 2 trader carpet), baby decor model [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     CALL "EF4-LLAMA-DECOR" USING WS-IN WS-OUT
     MOVE "9.3 carpet item 1 baby 1 trader 0: mode (0 none, 1 the item carpet, 2 trader carpet), baby decor model [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 carpet item 1 baby 1 trader 0: mode (0 none, 1 the item carpet, 2 trader carpet), baby decor model [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     MOVE 1 TO WS-IV(3)
     CALL "EF4-LLAMA-DECOR" USING WS-IN WS-OUT
     MOVE "9.3 carpet item 1 baby 1 trader 1: mode (0 none, 1 the item carpet, 2 trader carpet), baby decor model [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.3 carpet item 1 baby 1 trader 1: mode (0 none, 1 the item carpet, 2 trader carpet), baby decor model [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "LLAMA" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 14 TO WS-IV(1)
     MOVE -25 TO WS-IV(2)
     MOVE 2.1 TO WS-IV(3)
     MOVE 0.8 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF4-LLAMA-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA pos 2.1 chest 1 head.xrot" TO WS-NAME
     MOVE 0.244346088 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA pos 2.1 chest 1 head.yrot" TO WS-NAME
     MOVE -0.4363323 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA pos 2.1 chest 1 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.191444738 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA pos 2.1 chest 1 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.191444738 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA pos 2.1 chest 1 right_front_leg.xrot" TO WS-NAME
     MOVE -0.191444738 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA pos 2.1 chest 1 left_front_leg.xrot" TO WS-NAME
     MOVE 0.191444738 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "LLAMA" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF4-LLAMA-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA pos 0 chest 0 head.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA pos 0 chest 0 head.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA pos 0 chest 0 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA pos 0 chest 0 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA pos 0 chest 0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA pos 0 chest 0 left_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_chest visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_chest visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "LLAMA" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE -33 TO WS-IV(1)
     MOVE 60 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     MOVE 0.3 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF4-LLAMA-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA pos 5 chest 1 head.xrot" TO WS-NAME
     MOVE -0.575958636 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA pos 5 chest 1 head.yrot" TO WS-NAME
     MOVE 1.04719752 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA pos 5 chest 1 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.412488716 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA pos 5 chest 1 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.412488716 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA pos 5 chest 1 right_front_leg.xrot" TO WS-NAME
     MOVE 0.412488716 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA pos 5 chest 1 left_front_leg.xrot" TO WS-NAME
     MOVE -0.412488716 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "LLAMA_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 14 TO WS-IV(1)
     MOVE -25 TO WS-IV(2)
     MOVE 2.1 TO WS-IV(3)
     MOVE 0.8 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF4-LLAMA-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA_BABY pos 2.1 chest 1 head.xrot" TO WS-NAME
     MOVE 0.244346088 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA_BABY pos 2.1 chest 1 head.yrot" TO WS-NAME
     MOVE -0.4363323 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA_BABY pos 2.1 chest 1 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.191444738 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA_BABY pos 2.1 chest 1 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.191444738 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA_BABY pos 2.1 chest 1 right_front_leg.xrot" TO WS-NAME
     MOVE -0.191444738 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA_BABY pos 2.1 chest 1 left_front_leg.xrot" TO WS-NAME
     MOVE 0.191444738 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "LLAMA_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF4-LLAMA-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA_BABY pos 0 chest 0 head.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA_BABY pos 0 chest 0 head.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA_BABY pos 0 chest 0 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA_BABY pos 0 chest 0 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA_BABY pos 0 chest 0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA_BABY pos 0 chest 0 left_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_chest visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_chest visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "LLAMA_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE -33 TO WS-IV(1)
     MOVE 60 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     MOVE 0.3 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF4-LLAMA-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA_BABY pos 5 chest 1 head.xrot" TO WS-NAME
     MOVE -0.575958636 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA_BABY pos 5 chest 1 head.yrot" TO WS-NAME
     MOVE 1.04719752 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA_BABY pos 5 chest 1 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.412488716 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA_BABY pos 5 chest 1 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.412488716 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA_BABY pos 5 chest 1 right_front_leg.xrot" TO WS-NAME
     MOVE 0.412488716 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 LLAMA_BABY pos 5 chest 1 left_front_leg.xrot" TO WS-NAME
     MOVE -0.412488716 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "TRADER_LLAMA" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 14 TO WS-IV(1)
     MOVE -25 TO WS-IV(2)
     MOVE 2.1 TO WS-IV(3)
     MOVE 0.8 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF4-LLAMA-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA pos 2.1 chest 1 head.xrot" TO WS-NAME
     MOVE 0.244346088 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA pos 2.1 chest 1 head.yrot" TO WS-NAME
     MOVE -0.4363323 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA pos 2.1 chest 1 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.191444738 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA pos 2.1 chest 1 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.191444738 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA pos 2.1 chest 1 right_front_leg.xrot" TO WS-NAME
     MOVE -0.191444738 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA pos 2.1 chest 1 left_front_leg.xrot" TO WS-NAME
     MOVE 0.191444738 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "TRADER_LLAMA" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF4-LLAMA-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA pos 0 chest 0 head.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA pos 0 chest 0 head.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA pos 0 chest 0 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA pos 0 chest 0 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA pos 0 chest 0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA pos 0 chest 0 left_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_chest visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_chest visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "TRADER_LLAMA" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE -33 TO WS-IV(1)
     MOVE 60 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     MOVE 0.3 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF4-LLAMA-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA pos 5 chest 1 head.xrot" TO WS-NAME
     MOVE -0.575958636 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA pos 5 chest 1 head.yrot" TO WS-NAME
     MOVE 1.04719752 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA pos 5 chest 1 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.412488716 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA pos 5 chest 1 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.412488716 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA pos 5 chest 1 right_front_leg.xrot" TO WS-NAME
     MOVE 0.412488716 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA pos 5 chest 1 left_front_leg.xrot" TO WS-NAME
     MOVE -0.412488716 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "TRADER_LLAMA_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 14 TO WS-IV(1)
     MOVE -25 TO WS-IV(2)
     MOVE 2.1 TO WS-IV(3)
     MOVE 0.8 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF4-LLAMA-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA_BABY pos 2.1 chest 1 head.xrot" TO WS-NAME
     MOVE 0.244346088 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA_BABY pos 2.1 chest 1 head.yrot" TO WS-NAME
     MOVE -0.4363323 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA_BABY pos 2.1 chest 1 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.191444738 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA_BABY pos 2.1 chest 1 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.191444738 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA_BABY pos 2.1 chest 1 right_front_leg.xrot" TO WS-NAME
     MOVE -0.191444738 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA_BABY pos 2.1 chest 1 left_front_leg.xrot" TO WS-NAME
     MOVE 0.191444738 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "TRADER_LLAMA_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 0 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     CALL "EF4-LLAMA-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA_BABY pos 0 chest 0 head.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA_BABY pos 0 chest 0 head.yrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA_BABY pos 0 chest 0 right_hind_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA_BABY pos 0 chest 0 left_hind_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA_BABY pos 0 chest 0 right_front_leg.xrot" TO WS-NAME
     MOVE -0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA_BABY pos 0 chest 0 left_front_leg.xrot" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_chest visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_chest visible" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "TRADER_LLAMA_BABY" TO WS-LAYER
     CALL "EF4-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     MOVE -33 TO WS-IV(1)
     MOVE 60 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     MOVE 0.3 TO WS-IV(4)
     MOVE 1 TO WS-IV(5)
     CALL "EF4-LLAMA-ANIM" USING EMM-MODEL WS-IN
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA_BABY pos 5 chest 1 head.xrot" TO WS-NAME
     MOVE -0.575958636 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "head" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA_BABY pos 5 chest 1 head.yrot" TO WS-NAME
     MOVE 1.04719752 TO WS-E
     MOVE MM-CYROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA_BABY pos 5 chest 1 right_hind_leg.xrot" TO WS-NAME
     MOVE -0.412488716 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_hind_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA_BABY pos 5 chest 1 left_hind_leg.xrot" TO WS-NAME
     MOVE 0.412488716 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA_BABY pos 5 chest 1 right_front_leg.xrot" TO WS-NAME
     MOVE 0.412488716 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_front_leg" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "9.2 TRADER_LLAMA_BABY pos 5 chest 1 left_front_leg.xrot" TO WS-NAME
     MOVE -0.412488716 TO WS-E
     MOVE MM-CXROT(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "right_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "right_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE "left_chest" TO WS-PN
     CALL "EMM-FIND" USING EMM-MODEL WS-PN WS-P
     MOVE "left_chest visible" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE MM-VISIBLE(WS-P) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 90 TO WS-IV(2)
     CALL "EF4-SPIT-OPS" USING WS-IN WS-OUT
     MOVE "9.5 spit pose xRot 0 yRot 90 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot 0 yRot 90 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot 0 yRot 90 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot 0 yRot 90 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [4]" TO WS-NAME
     MOVE 0.15 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot 0 yRot 90 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot 0 yRot 90 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot 0 yRot 90 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot 0 yRot 90 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot 0 yRot 90 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot 0 yRot 90 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot 0 yRot 90 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot 0 yRot 90 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot 0 yRot 90 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE 25 TO WS-IV(1)
     MOVE -30 TO WS-IV(2)
     CALL "EF4-SPIT-OPS" USING WS-IN WS-OUT
     MOVE "9.5 spit pose xRot 25 yRot -30 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot 25 yRot -30 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot 25 yRot -30 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot 25 yRot -30 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [4]" TO WS-NAME
     MOVE 0.15 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot 25 yRot -30 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot 25 yRot -30 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot 25 yRot -30 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [7]" TO WS-NAME
     MOVE -120 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot 25 yRot -30 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot 25 yRot -30 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot 25 yRot -30 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot 25 yRot -30 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [11]" TO WS-NAME
     MOVE 25 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot 25 yRot -30 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot 25 yRot -30 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE -40 TO WS-IV(1)
     MOVE 10.5 TO WS-IV(2)
     CALL "EF4-SPIT-OPS" USING WS-IN WS-OUT
     MOVE "9.5 spit pose xRot -40 yRot 10.5 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot -40 yRot 10.5 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot -40 yRot 10.5 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot -40 yRot 10.5 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [4]" TO WS-NAME
     MOVE 0.15 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot -40 yRot 10.5 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot -40 yRot 10.5 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot -40 yRot 10.5 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [7]" TO WS-NAME
     MOVE -79.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot -40 yRot 10.5 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot -40 yRot 10.5 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot -40 yRot 10.5 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot -40 yRot 10.5 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [11]" TO WS-NAME
     MOVE -40 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot -40 yRot 10.5 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "9.5 spit pose xRot -40 yRot 10.5 (count, then code 1 translate 2 rotate Y deg 3 rotate Z deg, values) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     CALL "EF4-SPIT-TEXTURE" USING WS-X120
     MOVE "9.5 spit texture" TO WS-NAME
     MOVE "textures/entity/llama/llama_spit.png" TO TL-EXPECTED
     MOVE WS-X120 TO TL-OBSERVED
     PERFORM CHECK-TEXT
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-4§9 Llama and trader llama: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-4§9 Llama and trader llama: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-4-9.
