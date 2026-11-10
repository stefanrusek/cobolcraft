*> Entity models part 7 section 5 (Hoglin and zoglin): the adult and baby meshes (5.2, 5.3; the zoglin layers reuse them), setupAnim (5.4), textures, shadow and shaking (5.1).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF7-HOGLIN-ANIM EMM-MODEL state(1 yRot degrees, 2 walk position, 3 walk speed (not clamped), 4 attackAnimationRemainingTicks, 5 baby model): reset first, ears, head yaw, headbutt, legs;
*>   EF7-HOGLIN-TEXTURE IN(zoglin, baby) path(out X(120)); EF7-HOGLIN-SHADOW IN() OUT(0.7); EF7-HOGLIN-SHAKING IN(zoglin, base shaking rule, converting) OUT(1 shakes). Layers HOGLIN, HOGLIN_BABY, ZOGLIN, ZOGLIN_BABY through EF7-LAYER.


 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-M-HOGLIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS1.
    05 FILLER PIC X(100) VALUE "P body root 0 7 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C body 1 1 -8 -7 -13 16 14 26 0 0".
    05 FILLER PIC X(100) VALUE "P mane body 0 -14 -7 0 0 0".
    05 FILLER PIC X(100) VALUE "C mane 90 33 0 0 -9 0 10 19 0.001 0".
    05 FILLER PIC X(100) VALUE "P head root 0 2 -12 0.87266463 0 0".
    05 FILLER PIC X(100) VALUE "C head 61 1 -7 -3 -19 14 6 19 0 0".
    05 FILLER PIC X(100) VALUE "P right_ear head -6 -2 -3 0 0 -0.6981317".
    05 FILLER PIC X(100) VALUE "C right_ear 1 1 -6 -1 -2 6 1 4 0 0".
    05 FILLER PIC X(100) VALUE "P left_ear head 6 -2 -3 0 0 0.6981317".
    05 FILLER PIC X(100) VALUE "C left_ear 1 6 0 -1 -2 6 1 4 0 0".
    05 FILLER PIC X(100) VALUE "P right_horn head -7 2 -12 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_horn 10 13 -1 -11 -1 2 11 2 0 0".
    05 FILLER PIC X(100) VALUE "P left_horn head 7 2 -12 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_horn 1 13 -1 -11 -1 2 11 2 0 0".
    05 FILLER PIC X(100) VALUE "P right_front_leg root -4 10 -8.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_front_leg 66 42 -3 0 -3 6 14 6 0 0".
    05 FILLER PIC X(100) VALUE "P left_front_leg root 4 10 -8.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_front_leg 41 42 -3 0 -3 6 14 6 0 0".
    05 FILLER PIC X(100) VALUE "P right_hind_leg root -5 13 10 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_hind_leg 21 45 -2.5 0 -2.5 5 11 5 0 0".
    05 FILLER PIC X(100) VALUE "P left_hind_leg root 5 13 10 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_hind_leg 0 45 -2.5 0 -2.5 5 11 5 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 58 TIMES.
 01 WS-ROWS1-R REDEFINES WS-ROWS1.
    05 WS-ROW1             PIC X(100) OCCURS 80 TIMES.
 01 WS-N1                  BINARY-LONG VALUE 22.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS1-R WS-N1 WS-ZERO
     MOVE 128 TO MM-TEXW
     MOVE 64 TO MM-TEXH
     GOBACK.
 END PROGRAM EF7-M-HOGLIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-M-HOGLIN-BABY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS1.
    05 FILLER PIC X(100) VALUE "P head root 0 13 -7 0.8727 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 0 -5 -2.2605 -10.547 10 4 12 0 0".
    05 FILLER PIC X(100) VALUE "C head 44 29 -7 -4.0981 -8.4879 2 5 2 0 0".
    05 FILLER PIC X(100) VALUE "C head 52 29 5 -4.0981 -8.4879 2 5 2 0 0".
    05 FILLER PIC X(100) VALUE "P body root 0 24 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 16 -4 -14 -7 8 8 14 0.02 0".
    05 FILLER PIC X(100) VALUE "C body 24 39 0 -18 -8 0 6 11 0.02 0".
    05 FILLER PIC X(100) VALUE "P right_ear head -5 -1 -1.5 0 0 -0.8727".
    05 FILLER PIC X(100) VALUE "C right_ear 32 5 -5.1 -0.5 -2 6 1 4 0 0".
    05 FILLER PIC X(100) VALUE "P left_ear head 5 -1 -1.5 0 0 0.8727".
    05 FILLER PIC X(100) VALUE "C left_ear 32 0 -0.9 -0.5 -2 6 1 4 0 1".
    05 FILLER PIC X(100) VALUE "P right_hind_leg root -2.5 18 4.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_hind_leg 0 47 -1.5 0 -1.5 3 6 3 0 0".
    05 FILLER PIC X(100) VALUE "P left_hind_leg root 2.5 18 4.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_hind_leg 12 47 -1.5 0 -1.5 3 6 3 0 0".
    05 FILLER PIC X(100) VALUE "P right_front_leg root -2.5 18 -4.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_front_leg 0 38 -1.5 0 -1.5 3 6 3 0 0".
    05 FILLER PIC X(100) VALUE "P left_front_leg root 2.5 18 -4.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_front_leg 12 38 -1.5 0 -1.5 3 6 3 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 61 TIMES.
 01 WS-ROWS1-R REDEFINES WS-ROWS1.
    05 WS-ROW1             PIC X(100) OCCURS 80 TIMES.
 01 WS-N1                  BINARY-LONG VALUE 19.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS1-R WS-N1 WS-ZERO
     MOVE 64 TO MM-TEXW
     MOVE 64 TO MM-TEXH
     GOBACK.
 END PROGRAM EF7-M-HOGLIN-BABY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-HOGLIN-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-H                   BINARY-LONG.
 01 WS-RE                  BINARY-LONG.
 01 WS-LE                  BINARY-LONG.
 01 WS-RF                  BINARY-LONG.
 01 WS-LF                  BINARY-LONG.
 01 WS-RH                  BINARY-LONG.
 01 WS-LH                  BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-D                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-H
     MOVE "right_ear" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RE
     MOVE "left_ear" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LE
     MOVE "right_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RF
     MOVE "left_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LF
     MOVE "right_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RH
     MOVE "left_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LH
     COMPUTE MM-CZROT(WS-RE) = -0.6981317 - L-I(3) * FUNCTION SIN(L-I(2))
     COMPUTE MM-CZROT(WS-LE) = 0.6981317 + L-I(3) * FUNCTION SIN(L-I(2))
     COMPUTE MM-CYROT(WS-H) = L-I(1) * 0.017453292
     COMPUTE WS-D = FUNCTION ABS(10 - 2 * L-I(4))
     COMPUTE WS-F = 1 - WS-D / 10
     COMPUTE MM-CXROT(WS-H) = 0.87266463 + WS-F * (-0.34906584 - 0.87266463)
     IF L-I(5) NOT = 0
         COMPUTE MM-CY(WS-H) = MM-CY(WS-H) + WS-F * 2.5
     END-IF
     COMPUTE MM-CXROT(WS-RF) = FUNCTION COS(L-I(2)) * 1.2 * L-I(3)
     COMPUTE MM-CXROT(WS-LF) = FUNCTION COS(L-I(2) + 3.141592653589793) * 1.2 * L-I(3)
     MOVE MM-CXROT(WS-LF) TO MM-CXROT(WS-RH)
     MOVE MM-CXROT(WS-RF) TO MM-CXROT(WS-LH)
     GOBACK.
 END PROGRAM EF7-HOGLIN-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-HOGLIN-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     EVALUATE TRUE
         WHEN L-I(1) NOT = 0 AND L-I(2) NOT = 0
             MOVE "textures/entity/hoglin/zoglin_baby.png" TO L-PATH
         WHEN L-I(1) NOT = 0
             MOVE "textures/entity/hoglin/zoglin.png" TO L-PATH
         WHEN L-I(2) NOT = 0
             MOVE "textures/entity/hoglin/hoglin_baby.png" TO L-PATH
         WHEN OTHER
             MOVE "textures/entity/hoglin/hoglin.png" TO L-PATH
     END-EVALUATE
     GOBACK.
 END PROGRAM EF7-HOGLIN-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-HOGLIN-SHADOW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0.7 TO L-O(1)
     GOBACK.
 END PROGRAM EF7-HOGLIN-SHADOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-HOGLIN-SHAKING.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(2) NOT = 0 OR (L-I(3) NOT = 0 AND L-I(1) = 0)
         MOVE 1 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EF7-HOGLIN-SHAKING.

