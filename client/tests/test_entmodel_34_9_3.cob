*> Acceptance test of docs/protocol/34-entity-models-9-non-living-entities.md section 3 (minecarts): 3.1 the shared MinecartModel part by part for the seven layers, 3.2 the offsetSeed shifts (Validation 3 and the formula with 64-bit wrapping),
*> the render pose of the new movement behaviour (offset, Y rotation, Z rotation, the hurt tilt, scale), the display block transform of step 5, the culling box growth, the default display block and offset per type, the passenger attachment, and 13.2's swell
*> and isLit as the TNT minecart contents use them (Validation 5).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTMODEL-34-9-3.
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
 01 WS-KEY               PIC X(24).
 01 WS-BLOCK-NAME         PIC X(24).
 01 WS-OFFSET             BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "MINECART" TO WS-LAYER
     CALL "EF9-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer MINECART is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-9§3 3.1 MINECART" TO CK-PREFIX
     MOVE "P bottom root 0 4 0 1.5707964 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C bottom 0 10 -10 -8 -1 20 16 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P front root -9 4 0 0 4.712389 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C front 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P back root 9 4 0 0 1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C back 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left root 0 4 -7 0 3.1415927 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right root 0 4 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "3.1 MINECART: parts below the root" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 MINECART: cuboids" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 MINECART: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 MINECART: texture height" TO WS-NAME
     MOVE 32.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "CHEST_MINECART" TO WS-LAYER
     CALL "EF9-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer CHEST_MINECART is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-9§3 3.1 CHEST_MINECART" TO CK-PREFIX
     MOVE "P bottom root 0 4 0 1.5707964 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C bottom 0 10 -10 -8 -1 20 16 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P front root -9 4 0 0 4.712389 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C front 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P back root 9 4 0 0 1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C back 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left root 0 4 -7 0 3.1415927 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right root 0 4 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "3.1 CHEST_MINECART: parts below the root" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 CHEST_MINECART: cuboids" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 CHEST_MINECART: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 CHEST_MINECART: texture height" TO WS-NAME
     MOVE 32.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "COMMAND_BLOCK_MINECART" TO WS-LAYER
     CALL "EF9-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer COMMAND_BLOCK_MINECART is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-9§3 3.1 COMMAND_BLOCK_MINECART" TO CK-PREFIX
     MOVE "P bottom root 0 4 0 1.5707964 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C bottom 0 10 -10 -8 -1 20 16 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P front root -9 4 0 0 4.712389 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C front 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P back root 9 4 0 0 1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C back 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left root 0 4 -7 0 3.1415927 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right root 0 4 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "3.1 COMMAND_BLOCK_MINECART: parts below the root" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 COMMAND_BLOCK_MINECART: cuboids" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 COMMAND_BLOCK_MINECART: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 COMMAND_BLOCK_MINECART: texture height" TO WS-NAME
     MOVE 32.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "FURNACE_MINECART" TO WS-LAYER
     CALL "EF9-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer FURNACE_MINECART is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-9§3 3.1 FURNACE_MINECART" TO CK-PREFIX
     MOVE "P bottom root 0 4 0 1.5707964 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C bottom 0 10 -10 -8 -1 20 16 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P front root -9 4 0 0 4.712389 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C front 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P back root 9 4 0 0 1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C back 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left root 0 4 -7 0 3.1415927 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right root 0 4 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "3.1 FURNACE_MINECART: parts below the root" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 FURNACE_MINECART: cuboids" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 FURNACE_MINECART: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 FURNACE_MINECART: texture height" TO WS-NAME
     MOVE 32.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "HOPPER_MINECART" TO WS-LAYER
     CALL "EF9-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer HOPPER_MINECART is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-9§3 3.1 HOPPER_MINECART" TO CK-PREFIX
     MOVE "P bottom root 0 4 0 1.5707964 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C bottom 0 10 -10 -8 -1 20 16 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P front root -9 4 0 0 4.712389 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C front 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P back root 9 4 0 0 1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C back 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left root 0 4 -7 0 3.1415927 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right root 0 4 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "3.1 HOPPER_MINECART: parts below the root" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 HOPPER_MINECART: cuboids" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 HOPPER_MINECART: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 HOPPER_MINECART: texture height" TO WS-NAME
     MOVE 32.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "SPAWNER_MINECART" TO WS-LAYER
     CALL "EF9-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer SPAWNER_MINECART is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-9§3 3.1 SPAWNER_MINECART" TO CK-PREFIX
     MOVE "P bottom root 0 4 0 1.5707964 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C bottom 0 10 -10 -8 -1 20 16 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P front root -9 4 0 0 4.712389 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C front 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P back root 9 4 0 0 1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C back 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left root 0 4 -7 0 3.1415927 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right root 0 4 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "3.1 SPAWNER_MINECART: parts below the root" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 SPAWNER_MINECART: cuboids" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 SPAWNER_MINECART: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 SPAWNER_MINECART: texture height" TO WS-NAME
     MOVE 32.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE "TNT_MINECART" TO WS-LAYER
     CALL "EF9-LAYER" USING EMM-MODEL WS-LAYER WS-OK
     PERFORM CK-RESET-COUNTS
     MOVE "layer TNT_MINECART is known" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OK TO WS-O
     PERFORM CHECK-NUM
     MOVE "acceptance US15 34-9§3 3.1 TNT_MINECART" TO CK-PREFIX
     MOVE "P bottom root 0 4 0 1.5707964 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C bottom 0 10 -10 -8 -1 20 16 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P front root -9 4 0 0 4.712389 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C front 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P back root 9 4 0 0 1.5707964 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C back 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P left root 0 4 -7 0 3.1415927 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C left 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "P right root 0 4 7 0 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     MOVE "C right 0 0 -8 -9 -1 16 8 2 0 0" TO CK-ROW
     PERFORM CK-ROW-CHECK
     CALL "EMM-STATS" USING EMM-MODEL WS-PARTS WS-CUBES
     MOVE "3.1 TNT_MINECART: parts below the root" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-PARTS TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 TNT_MINECART: cuboids" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-CUBES TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 TNT_MINECART: texture width" TO WS-NAME
     MOVE 64.0 TO WS-E
     MOVE MM-TEXW TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.1 TNT_MINECART: texture height" TO WS-NAME
     MOVE 32.0 TO WS-E
     MOVE MM-TEXH TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF9-MINECART-OFFSET" USING WS-IN WS-OUT
     MOVE "3.2 offsets of entity 1 (Validation 3: x, y, z, low 27 bits of the seed -4132653469018943280) [1]" TO WS-NAME
     MOVE 0.00175 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 1 (Validation 3: x, y, z, low 27 bits of the seed -4132653469018943280) [2]" TO WS-NAME
     MOVE 0.00075 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 1 (Validation 3: x, y, z, low 27 bits of the seed -4132653469018943280) [3]" TO WS-NAME
     MOVE 0.00175 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 1 (Validation 3: x, y, z, low 27 bits of the seed -4132653469018943280) [4]" TO WS-NAME
     MOVE 123146448 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 2 TO WS-IV(1)
     CALL "EF9-MINECART-OFFSET" USING WS-IN WS-OUT
     MOVE "3.2 offsets of entity 2 (Validation 3: x, y, z, low 27 bits of the seed 1916032762656048354) [1]" TO WS-NAME
     MOVE 0.00175 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 2 (Validation 3: x, y, z, low 27 bits of the seed 1916032762656048354) [2]" TO WS-NAME
     MOVE -0.00125 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 2 (Validation 3: x, y, z, low 27 bits of the seed 1916032762656048354) [3]" TO WS-NAME
     MOVE 0.00025 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 2 (Validation 3: x, y, z, low 27 bits of the seed 1916032762656048354) [4]" TO WS-NAME
     MOVE 69190882 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 100 TO WS-IV(1)
     CALL "EF9-MINECART-OFFSET" USING WS-IN WS-OUT
     MOVE "3.2 offsets of entity 100 (Validation 3: x, y, z, low 27 bits of the seed -6310268219801383060) [1]" TO WS-NAME
     MOVE 0.00075 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 100 (Validation 3: x, y, z, low 27 bits of the seed -6310268219801383060) [2]" TO WS-NAME
     MOVE 0.00025 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 100 (Validation 3: x, y, z, low 27 bits of the seed -6310268219801383060) [3]" TO WS-NAME
     MOVE -0.00125 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 100 (Validation 3: x, y, z, low 27 bits of the seed -6310268219801383060) [4]" TO WS-NAME
     MOVE 21843820 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF9-MINECART-OFFSET" USING WS-IN WS-OUT
     MOVE "3.2 offsets of entity 0 (the formula with 64-bit wrapping) [1]" TO WS-NAME
     MOVE -0.00175 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 0 (the formula with 64-bit wrapping) [2]" TO WS-NAME
     MOVE -0.00175 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 0 (the formula with 64-bit wrapping) [3]" TO WS-NAME
     MOVE -0.00175 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 0 (the formula with 64-bit wrapping) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 3 TO WS-IV(1)
     CALL "EF9-MINECART-OFFSET" USING WS-IN WS-OUT
     MOVE "3.2 offsets of entity 3 (the formula with 64-bit wrapping) [1]" TO WS-NAME
     MOVE -0.00075 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 3 (the formula with 64-bit wrapping) [2]" TO WS-NAME
     MOVE 0.00075 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 3 (the formula with 64-bit wrapping) [3]" TO WS-NAME
     MOVE 0.00125 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 3 (the formula with 64-bit wrapping) [4]" TO WS-NAME
     MOVE 106568758 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 7 TO WS-IV(1)
     CALL "EF9-MINECART-OFFSET" USING WS-IN WS-OUT
     MOVE "3.2 offsets of entity 7 (the formula with 64-bit wrapping) [1]" TO WS-NAME
     MOVE -0.00025 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 7 (the formula with 64-bit wrapping) [2]" TO WS-NAME
     MOVE -0.00025 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 7 (the formula with 64-bit wrapping) [3]" TO WS-NAME
     MOVE 0.00075 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 7 (the formula with 64-bit wrapping) [4]" TO WS-NAME
     MOVE 95672858 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1000 TO WS-IV(1)
     CALL "EF9-MINECART-OFFSET" USING WS-IN WS-OUT
     MOVE "3.2 offsets of entity 1000 (the formula with 64-bit wrapping) [1]" TO WS-NAME
     MOVE 0.00075 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 1000 (the formula with 64-bit wrapping) [2]" TO WS-NAME
     MOVE 0.00075 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 1000 (the formula with 64-bit wrapping) [3]" TO WS-NAME
     MOVE 0.00125 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 1000 (the formula with 64-bit wrapping) [4]" TO WS-NAME
     MOVE 114670040 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 123456 TO WS-IV(1)
     CALL "EF9-MINECART-OFFSET" USING WS-IN WS-OUT
     MOVE "3.2 offsets of entity 123456 (the formula with 64-bit wrapping) [1]" TO WS-NAME
     MOVE 0.00075 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 123456 (the formula with 64-bit wrapping) [2]" TO WS-NAME
     MOVE -0.00025 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 123456 (the formula with 64-bit wrapping) [3]" TO WS-NAME
     MOVE -0.00075 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 123456 (the formula with 64-bit wrapping) [4]" TO WS-NAME
     MOVE 37050816 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 999999 TO WS-IV(1)
     CALL "EF9-MINECART-OFFSET" USING WS-IN WS-OUT
     MOVE "3.2 offsets of entity 999999 (the formula with 64-bit wrapping) [1]" TO WS-NAME
     MOVE 0.00125 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 999999 (the formula with 64-bit wrapping) [2]" TO WS-NAME
     MOVE -0.00025 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 999999 (the formula with 64-bit wrapping) [3]" TO WS-NAME
     MOVE -0.00075 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 offsets of entity 999999 (the formula with 64-bit wrapping) [4]" TO WS-NAME
     MOVE 37140402 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     CALL "EF9-MINECART-OPS" USING WS-IN WS-OUT
     MOVE "3.2 pose for yaw 0 pitch 0 hurtTime 0 dir 1 damage 0 shift (0, 0, 0) [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 0 pitch 0 hurtTime 0 dir 1 damage 0 shift (0, 0, 0) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 0 pitch 0 hurtTime 0 dir 1 damage 0 shift (0, 0, 0) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 0 pitch 0 hurtTime 0 dir 1 damage 0 shift (0, 0, 0) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 0 pitch 0 hurtTime 0 dir 1 damage 0 shift (0, 0, 0) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 0 pitch 0 hurtTime 0 dir 1 damage 0 shift (0, 0, 0) [6]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 0 pitch 0 hurtTime 0 dir 1 damage 0 shift (0, 0, 0) [7]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 0 pitch 0 hurtTime 0 dir 1 damage 0 shift (0, 0, 0) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 0 pitch 0 hurtTime 0 dir 1 damage 0 shift (0, 0, 0) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 0 pitch 0 hurtTime 0 dir 1 damage 0 shift (0, 0, 0) [10]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 0 pitch 0 hurtTime 0 dir 1 damage 0 shift (0, 0, 0) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 0 pitch 0 hurtTime 0 dir 1 damage 0 shift (0, 0, 0) [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 0 pitch 0 hurtTime 0 dir 1 damage 0 shift (0, 0, 0) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 0 pitch 0 hurtTime 0 dir 1 damage 0 shift (0, 0, 0) [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 0 pitch 0 hurtTime 0 dir 1 damage 0 shift (0, 0, 0) [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 0 pitch 0 hurtTime 0 dir 1 damage 0 shift (0, 0, 0) [16]" TO WS-NAME
     MOVE 0.375 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 0 pitch 0 hurtTime 0 dir 1 damage 0 shift (0, 0, 0) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 0 pitch 0 hurtTime 0 dir 1 damage 0 shift (0, 0, 0) [18]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 0 pitch 0 hurtTime 0 dir 1 damage 0 shift (0, 0, 0) [19]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 0 pitch 0 hurtTime 0 dir 1 damage 0 shift (0, 0, 0) [20]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 0 pitch 0 hurtTime 0 dir 1 damage 0 shift (0, 0, 0) [21]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 90 TO WS-IV(1)
     MOVE 12 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 0 TO WS-IV(5)
     MOVE 0.00175 TO WS-IV(6)
     MOVE -0.00125 TO WS-IV(7)
     MOVE 0.00025 TO WS-IV(8)
     CALL "EF9-MINECART-OPS" USING WS-IN WS-OUT
     MOVE "3.2 pose for yaw 90 pitch 12 hurtTime 0 dir 1 damage 0 shift (0.00175, -0.00125, 0.00025) [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 90 pitch 12 hurtTime 0 dir 1 damage 0 shift (0.00175, -0.00125, 0.00025) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 90 pitch 12 hurtTime 0 dir 1 damage 0 shift (0.00175, -0.00125, 0.00025) [3]" TO WS-NAME
     MOVE 0.00175 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 90 pitch 12 hurtTime 0 dir 1 damage 0 shift (0.00175, -0.00125, 0.00025) [4]" TO WS-NAME
     MOVE -0.00125 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 90 pitch 12 hurtTime 0 dir 1 damage 0 shift (0.00175, -0.00125, 0.00025) [5]" TO WS-NAME
     MOVE 0.00025 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 90 pitch 12 hurtTime 0 dir 1 damage 0 shift (0.00175, -0.00125, 0.00025) [6]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 90 pitch 12 hurtTime 0 dir 1 damage 0 shift (0.00175, -0.00125, 0.00025) [7]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 90 pitch 12 hurtTime 0 dir 1 damage 0 shift (0.00175, -0.00125, 0.00025) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 90 pitch 12 hurtTime 0 dir 1 damage 0 shift (0.00175, -0.00125, 0.00025) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 90 pitch 12 hurtTime 0 dir 1 damage 0 shift (0.00175, -0.00125, 0.00025) [10]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 90 pitch 12 hurtTime 0 dir 1 damage 0 shift (0.00175, -0.00125, 0.00025) [11]" TO WS-NAME
     MOVE -12 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 90 pitch 12 hurtTime 0 dir 1 damage 0 shift (0.00175, -0.00125, 0.00025) [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 90 pitch 12 hurtTime 0 dir 1 damage 0 shift (0.00175, -0.00125, 0.00025) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 90 pitch 12 hurtTime 0 dir 1 damage 0 shift (0.00175, -0.00125, 0.00025) [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 90 pitch 12 hurtTime 0 dir 1 damage 0 shift (0.00175, -0.00125, 0.00025) [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 90 pitch 12 hurtTime 0 dir 1 damage 0 shift (0.00175, -0.00125, 0.00025) [16]" TO WS-NAME
     MOVE 0.375 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 90 pitch 12 hurtTime 0 dir 1 damage 0 shift (0.00175, -0.00125, 0.00025) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 90 pitch 12 hurtTime 0 dir 1 damage 0 shift (0.00175, -0.00125, 0.00025) [18]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 90 pitch 12 hurtTime 0 dir 1 damage 0 shift (0.00175, -0.00125, 0.00025) [19]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 90 pitch 12 hurtTime 0 dir 1 damage 0 shift (0.00175, -0.00125, 0.00025) [20]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 90 pitch 12 hurtTime 0 dir 1 damage 0 shift (0.00175, -0.00125, 0.00025) [21]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE -135 TO WS-IV(1)
     MOVE -30 TO WS-IV(2)
     MOVE 5 TO WS-IV(3)
     MOVE 1 TO WS-IV(4)
     MOVE 18 TO WS-IV(5)
     MOVE 0.001 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE -0.001 TO WS-IV(8)
     CALL "EF9-MINECART-OPS" USING WS-IN WS-OUT
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [1]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [3]" TO WS-NAME
     MOVE 0.001 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [5]" TO WS-NAME
     MOVE -0.001 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [6]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [7]" TO WS-NAME
     MOVE -135 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [10]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [11]" TO WS-NAME
     MOVE 30 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [16]" TO WS-NAME
     MOVE 0.375 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [18]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [19]" TO WS-NAME
     MOVE -8.630318472 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [22]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [23]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [24]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw -135 pitch -30 hurtTime 5 dir 1 damage 18 shift (0.001, 0, -0.001) [25]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE 45 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     MOVE 2.5 TO WS-IV(3)
     MOVE -1 TO WS-IV(4)
     MOVE 7 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0.0005 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     CALL "EF9-MINECART-OPS" USING WS-IN WS-OUT
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [1]" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [4]" TO WS-NAME
     MOVE 0.0005 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [6]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [7]" TO WS-NAME
     MOVE 45 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [10]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [11]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [16]" TO WS-NAME
     MOVE 0.375 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [18]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [19]" TO WS-NAME
     MOVE -1.047326252 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [20]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [21]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [22]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(22) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [23]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(23) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [24]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(24) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 45 pitch 0 hurtTime 2.5 dir -1 damage 7 shift (0, 0.0005, 0) [25]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(25) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10 TO WS-IV(1)
     MOVE 5 TO WS-IV(2)
     MOVE 0 TO WS-IV(3)
     MOVE -1 TO WS-IV(4)
     MOVE 4 TO WS-IV(5)
     MOVE 0 TO WS-IV(6)
     MOVE 0 TO WS-IV(7)
     MOVE 0 TO WS-IV(8)
     CALL "EF9-MINECART-OPS" USING WS-IN WS-OUT
     MOVE "3.2 pose for yaw 10 pitch 5 hurtTime 0 dir -1 damage 4 shift (0, 0, 0) [1]" TO WS-NAME
     MOVE 5 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 10 pitch 5 hurtTime 0 dir -1 damage 4 shift (0, 0, 0) [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 10 pitch 5 hurtTime 0 dir -1 damage 4 shift (0, 0, 0) [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 10 pitch 5 hurtTime 0 dir -1 damage 4 shift (0, 0, 0) [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 10 pitch 5 hurtTime 0 dir -1 damage 4 shift (0, 0, 0) [5]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 10 pitch 5 hurtTime 0 dir -1 damage 4 shift (0, 0, 0) [6]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 10 pitch 5 hurtTime 0 dir -1 damage 4 shift (0, 0, 0) [7]" TO WS-NAME
     MOVE 10 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 10 pitch 5 hurtTime 0 dir -1 damage 4 shift (0, 0, 0) [8]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 10 pitch 5 hurtTime 0 dir -1 damage 4 shift (0, 0, 0) [9]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 10 pitch 5 hurtTime 0 dir -1 damage 4 shift (0, 0, 0) [10]" TO WS-NAME
     MOVE 7 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 10 pitch 5 hurtTime 0 dir -1 damage 4 shift (0, 0, 0) [11]" TO WS-NAME
     MOVE -5 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 10 pitch 5 hurtTime 0 dir -1 damage 4 shift (0, 0, 0) [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 10 pitch 5 hurtTime 0 dir -1 damage 4 shift (0, 0, 0) [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 10 pitch 5 hurtTime 0 dir -1 damage 4 shift (0, 0, 0) [14]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(14) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 10 pitch 5 hurtTime 0 dir -1 damage 4 shift (0, 0, 0) [15]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(15) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 10 pitch 5 hurtTime 0 dir -1 damage 4 shift (0, 0, 0) [16]" TO WS-NAME
     MOVE 0.375 TO WS-E
     MOVE WS-OV(16) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 10 pitch 5 hurtTime 0 dir -1 damage 4 shift (0, 0, 0) [17]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(17) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 10 pitch 5 hurtTime 0 dir -1 damage 4 shift (0, 0, 0) [18]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(18) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 10 pitch 5 hurtTime 0 dir -1 damage 4 shift (0, 0, 0) [19]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(19) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 10 pitch 5 hurtTime 0 dir -1 damage 4 shift (0, 0, 0) [20]" TO WS-NAME
     MOVE -1 TO WS-E
     MOVE WS-OV(20) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 pose for yaw 10 pitch 5 hurtTime 0 dir -1 damage 4 shift (0, 0, 0) [21]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(21) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF9-MINECART-CONTENTS" USING WS-IN WS-OUT
     MOVE "3.2 step 5 transform for display offset 1 [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 1 [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 1 [3]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 1 [4]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 1 [5]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 1 [6]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 1 [7]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 1 [8]" TO WS-NAME
     MOVE -0.4375 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 1 [9]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 1 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 1 [11]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 1 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 1 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE 6 TO WS-IV(1)
     CALL "EF9-MINECART-CONTENTS" USING WS-IN WS-OUT
     MOVE "3.2 step 5 transform for display offset 6 [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 6 [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 6 [3]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 6 [4]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 6 [5]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 6 [6]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 6 [7]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 6 [8]" TO WS-NAME
     MOVE -0.125 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 6 [9]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 6 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 6 [11]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 6 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 6 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE 8 TO WS-IV(1)
     CALL "EF9-MINECART-CONTENTS" USING WS-IN WS-OUT
     MOVE "3.2 step 5 transform for display offset 8 [1]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 8 [2]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 8 [3]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 8 [4]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 8 [5]" TO WS-NAME
     MOVE 0.75 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 8 [6]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 8 [7]" TO WS-NAME
     MOVE -0.5 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 8 [8]" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 8 [9]" TO WS-NAME
     MOVE 0.5 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 8 [10]" TO WS-NAME
     MOVE 3 TO WS-E
     MOVE WS-OV(10) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 8 [11]" TO WS-NAME
     MOVE 90 TO WS-E
     MOVE WS-OV(11) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 8 [12]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(12) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 step 5 transform for display offset 8 [13]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(13) TO WS-O
     PERFORM CHECK-NUM
     MOVE 6 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF9-MINECART-CULL" USING WS-IN WS-OUT
     MOVE "3.2 culling box growth for display offset 6, not air 1" TO WS-NAME
     MOVE 0.28125 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 8 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF9-MINECART-CULL" USING WS-IN WS-OUT
     MOVE "3.2 culling box growth for display offset 8, not air 1" TO WS-NAME
     MOVE 0.375 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     MOVE 1 TO WS-IV(2)
     CALL "EF9-MINECART-CULL" USING WS-IN WS-OUT
     MOVE "3.2 culling box growth for display offset 1, not air 1" TO WS-NAME
     MOVE 0.046875 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 6 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF9-MINECART-CULL" USING WS-IN WS-OUT
     MOVE "3.2 culling box growth for display offset 6, not air 0" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 12 TO WS-IV(1)
     MOVE 0 TO WS-IV(2)
     CALL "EF9-MINECART-CULL" USING WS-IN WS-OUT
     MOVE "3.2 culling box growth for display offset 12, not air 0" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "minecart" TO WS-KEY
     MOVE "x" TO WS-BLOCK-NAME
     CALL "EF9-MINECART-DISPLAY" USING WS-KEY WS-BLOCK-NAME WS-OFFSET
     MOVE "3.2 default display block of minecart" TO WS-NAME
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-BLOCK-NAME TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "3.2 default display offset of minecart" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OFFSET TO WS-O
     PERFORM CHECK-NUM
     MOVE "chest_minecart" TO WS-KEY
     MOVE "x" TO WS-BLOCK-NAME
     CALL "EF9-MINECART-DISPLAY" USING WS-KEY WS-BLOCK-NAME WS-OFFSET
     MOVE "3.2 default display block of chest_minecart" TO WS-NAME
     MOVE "chest" TO TL-EXPECTED
     MOVE WS-BLOCK-NAME TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "3.2 default display offset of chest_minecart" TO WS-NAME
     MOVE 8 TO WS-E
     MOVE WS-OFFSET TO WS-O
     PERFORM CHECK-NUM
     MOVE "furnace_minecart" TO WS-KEY
     MOVE "x" TO WS-BLOCK-NAME
     CALL "EF9-MINECART-DISPLAY" USING WS-KEY WS-BLOCK-NAME WS-OFFSET
     MOVE "3.2 default display block of furnace_minecart" TO WS-NAME
     MOVE "furnace" TO TL-EXPECTED
     MOVE WS-BLOCK-NAME TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "3.2 default display offset of furnace_minecart" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OFFSET TO WS-O
     PERFORM CHECK-NUM
     MOVE "hopper_minecart" TO WS-KEY
     MOVE "x" TO WS-BLOCK-NAME
     CALL "EF9-MINECART-DISPLAY" USING WS-KEY WS-BLOCK-NAME WS-OFFSET
     MOVE "3.2 default display block of hopper_minecart" TO WS-NAME
     MOVE "hopper" TO TL-EXPECTED
     MOVE WS-BLOCK-NAME TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "3.2 default display offset of hopper_minecart" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OFFSET TO WS-O
     PERFORM CHECK-NUM
     MOVE "spawner_minecart" TO WS-KEY
     MOVE "x" TO WS-BLOCK-NAME
     CALL "EF9-MINECART-DISPLAY" USING WS-KEY WS-BLOCK-NAME WS-OFFSET
     MOVE "3.2 default display block of spawner_minecart" TO WS-NAME
     MOVE "spawner" TO TL-EXPECTED
     MOVE WS-BLOCK-NAME TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "3.2 default display offset of spawner_minecart" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OFFSET TO WS-O
     PERFORM CHECK-NUM
     MOVE "command_block_minecart" TO WS-KEY
     MOVE "x" TO WS-BLOCK-NAME
     CALL "EF9-MINECART-DISPLAY" USING WS-KEY WS-BLOCK-NAME WS-OFFSET
     MOVE "3.2 default display block of command_block_minecart" TO WS-NAME
     MOVE "command_block" TO TL-EXPECTED
     MOVE WS-BLOCK-NAME TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "3.2 default display offset of command_block_minecart" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OFFSET TO WS-O
     PERFORM CHECK-NUM
     MOVE "tnt_minecart" TO WS-KEY
     MOVE "x" TO WS-BLOCK-NAME
     CALL "EF9-MINECART-DISPLAY" USING WS-KEY WS-BLOCK-NAME WS-OFFSET
     MOVE "3.2 default display block of tnt_minecart" TO WS-NAME
     MOVE "tnt" TO TL-EXPECTED
     MOVE WS-BLOCK-NAME TO TL-OBSERVED
     PERFORM CHECK-TEXT
     MOVE "3.2 default display offset of tnt_minecart" TO WS-NAME
     MOVE 6 TO WS-E
     MOVE WS-OFFSET TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF9-MINECART-PASSENGER" USING WS-IN WS-OUT
     MOVE "1.3 passenger attachment of an ordinary rider [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 passenger attachment of an ordinary rider [2]" TO WS-NAME
     MOVE 0.1875 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 passenger attachment of an ordinary rider [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE 1 TO WS-IV(1)
     CALL "EF9-MINECART-PASSENGER" USING WS-IN WS-OUT
     MOVE "1.3 passenger attachment of a villager or a wandering trader [1]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 passenger attachment of a villager or a wandering trader [2]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "1.3 passenger attachment of a villager or a wandering trader [3]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE -5 TO WS-IV(1)
     CALL "EF9-TNT-SWELL" USING WS-IN WS-OUT
     MOVE "13.2 swell(-5)" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE -1 TO WS-IV(1)
     CALL "EF9-TNT-SWELL" USING WS-IN WS-OUT
     MOVE "13.2 swell(-1)" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF9-TNT-SWELL" USING WS-IN WS-OUT
     MOVE "13.2 swell(0)" TO WS-NAME
     MOVE 0.3 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0.5 TO WS-IV(1)
     CALL "EF9-TNT-SWELL" USING WS-IN WS-OUT
     MOVE "13.2 swell(0.5)" TO WS-NAME
     MOVE 0.244351875 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4.9 TO WS-IV(1)
     CALL "EF9-TNT-SWELL" USING WS-IN WS-OUT
     MOVE "13.2 swell(4.9)" TO WS-NAME
     MOVE 0.020295603 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     CALL "EF9-TNT-SWELL" USING WS-IN WS-OUT
     MOVE "13.2 swell(5)" TO WS-NAME
     MOVE 0.01875 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 9 TO WS-IV(1)
     CALL "EF9-TNT-SWELL" USING WS-IN WS-OUT
     MOVE "13.2 swell(9)" TO WS-NAME
     MOVE 0.00003 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 9.9 TO WS-IV(1)
     CALL "EF9-TNT-SWELL" USING WS-IN WS-OUT
     MOVE "13.2 swell(9.9)" TO WS-NAME
     MOVE 0.000000003 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10 TO WS-IV(1)
     CALL "EF9-TNT-SWELL" USING WS-IN WS-OUT
     MOVE "13.2 swell(10)" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 12 TO WS-IV(1)
     CALL "EF9-TNT-SWELL" USING WS-IN WS-OUT
     MOVE "13.2 swell(12)" TO WS-NAME
     MOVE 0.0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE -1 TO WS-IV(1)
     CALL "EF9-TNT-LIT" USING WS-IN WS-OUT
     MOVE "13.2 isLit(-1)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE -0.5 TO WS-IV(1)
     CALL "EF9-TNT-LIT" USING WS-IN WS-OUT
     MOVE "13.2 isLit(-0.5)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF9-TNT-LIT" USING WS-IN WS-OUT
     MOVE "13.2 isLit(0)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 4.9 TO WS-IV(1)
     CALL "EF9-TNT-LIT" USING WS-IN WS-OUT
     MOVE "13.2 isLit(4.9)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     CALL "EF9-TNT-LIT" USING WS-IN WS-OUT
     MOVE "13.2 isLit(5)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 9.99 TO WS-IV(1)
     CALL "EF9-TNT-LIT" USING WS-IN WS-OUT
     MOVE "13.2 isLit(9.99)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10 TO WS-IV(1)
     CALL "EF9-TNT-LIT" USING WS-IN WS-OUT
     MOVE "13.2 isLit(10)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10.5 TO WS-IV(1)
     CALL "EF9-TNT-LIT" USING WS-IN WS-OUT
     MOVE "13.2 isLit(10.5)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 14.9 TO WS-IV(1)
     CALL "EF9-TNT-LIT" USING WS-IN WS-OUT
     MOVE "13.2 isLit(14.9)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 15 TO WS-IV(1)
     CALL "EF9-TNT-LIT" USING WS-IN WS-OUT
     MOVE "13.2 isLit(15)" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 20 TO WS-IV(1)
     CALL "EF9-TNT-LIT" USING WS-IN WS-OUT
     MOVE "13.2 isLit(20)" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE -1 TO WS-IV(1)
     CALL "EF9-TNT-CART-OPS" USING WS-IN WS-OUT
     MOVE "3.2 TNT minecart contents for f = -1" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE -0.5 TO WS-IV(1)
     CALL "EF9-TNT-CART-OPS" USING WS-IN WS-OUT
     MOVE "3.2 TNT minecart contents for f = -0.5 [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = -0.5 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = -0.5 [3]" TO WS-NAME
     MOVE -0.15 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = -0.5 [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = -0.5 [5]" TO WS-NAME
     MOVE -0.15 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = -0.5 [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = -0.5 [7]" TO WS-NAME
     MOVE 1.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = -0.5 [8]" TO WS-NAME
     MOVE 1.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = -0.5 [9]" TO WS-NAME
     MOVE 1.3 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 0 TO WS-IV(1)
     CALL "EF9-TNT-CART-OPS" USING WS-IN WS-OUT
     MOVE "3.2 TNT minecart contents for f = 0 [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = 0 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = 0 [3]" TO WS-NAME
     MOVE -0.15 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = 0 [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = 0 [5]" TO WS-NAME
     MOVE -0.15 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = 0 [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = 0 [7]" TO WS-NAME
     MOVE 1.3 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = 0 [8]" TO WS-NAME
     MOVE 1.3 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = 0 [9]" TO WS-NAME
     MOVE 1.3 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 5 TO WS-IV(1)
     CALL "EF9-TNT-CART-OPS" USING WS-IN WS-OUT
     MOVE "3.2 TNT minecart contents for f = 5 [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = 5 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = 5 [3]" TO WS-NAME
     MOVE -0.009375 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = 5 [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = 5 [5]" TO WS-NAME
     MOVE -0.009375 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = 5 [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = 5 [7]" TO WS-NAME
     MOVE 1.01875 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = 5 [8]" TO WS-NAME
     MOVE 1.01875 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = 5 [9]" TO WS-NAME
     MOVE 1.01875 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 9 TO WS-IV(1)
     CALL "EF9-TNT-CART-OPS" USING WS-IN WS-OUT
     MOVE "3.2 TNT minecart contents for f = 9 [1]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = 9 [2]" TO WS-NAME
     MOVE 1 TO WS-E
     MOVE WS-OV(2) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = 9 [3]" TO WS-NAME
     MOVE -0.000015 TO WS-E
     MOVE WS-OV(3) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = 9 [4]" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(4) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = 9 [5]" TO WS-NAME
     MOVE -0.000015 TO WS-E
     MOVE WS-OV(5) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = 9 [6]" TO WS-NAME
     MOVE 2 TO WS-E
     MOVE WS-OV(6) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = 9 [7]" TO WS-NAME
     MOVE 1.00003 TO WS-E
     MOVE WS-OV(7) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = 9 [8]" TO WS-NAME
     MOVE 1.00003 TO WS-E
     MOVE WS-OV(8) TO WS-O
     PERFORM CHECK-NUM
     MOVE "3.2 TNT minecart contents for f = 9 [9]" TO WS-NAME
     MOVE 1.00003 TO WS-E
     MOVE WS-OV(9) TO WS-O
     PERFORM CHECK-NUM
     MOVE 10 TO WS-IV(1)
     CALL "EF9-TNT-CART-OPS" USING WS-IN WS-OUT
     MOVE "3.2 TNT minecart contents for f = 10" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     MOVE 11 TO WS-IV(1)
     CALL "EF9-TNT-CART-OPS" USING WS-IN WS-OUT
     MOVE "3.2 TNT minecart contents for f = 11" TO WS-NAME
     MOVE 0 TO WS-E
     MOVE WS-OV(1) TO WS-O
     PERFORM CHECK-NUM
     STOP RUN.

 COPY EMCHKP.

 CHECK-NUM.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-9§3: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     IF FUNCTION ABS(WS-O - WS-E) <= 0.00002
         MOVE WS-E TO WS-O
     END-IF
     COMPUTE TL-EXPECTED-N ROUNDED = WS-E * 100000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-O * 100000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 34-9§3: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTMODEL-34-9-3.
