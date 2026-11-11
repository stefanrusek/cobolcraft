*> Entity models part 5 section 3 (Cat and ocelot): the meshes of the ocelot, cat, collar and baby layers (3.1), setupAnim of the adult and the baby (3.2, 3.3), textures, collar and body transform (3.4), counters (3.5).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF5-FELINE-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 walk position, 4 walk speed, 5 ageScale, 6 crouching, 7 sprinting, 8 sitting, 9 lieDownAmount, 10 lieDownAmountTail, 11 relaxStateOneAmount, 12 baby model): reset first;
*>   EF5-OCELOT-TEXTURE IN(baby) path(out X(120)); EF5-CAT-COLLAR-TEXTURE IN(baby) path; EF5-CAT-COLLAR IN(tamed) OUT(drawn); EF5-CAT-BODY-OPS IN(lieDownAmount, lying on a sleeping player) OUT(count, then code 1 translate
*>   4 rotate about Z in degrees, three values); EF5-LERP IN(t a b) OUT(a + t (b - a)) (the state lerps); EF5-CAT-COUNTERS IN(lie, lie tail, relax, lying, relax flag) OUT(lie, lie tail, relax) after one tick;
*>   EF5-CAT-ON-PLAYER IN(lying, a sleeping player within 2 blocks) OUT(on top); EF5-CAT-PURR IN(tickCount, lying, relaxed) OUT(purr this tick). The cat texture comes from the variant data.


 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-M-OCELOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P head root 0 15 -9 0 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 0 -2.5 -2 -3 5 4 5 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 24 -1.5 -0.001 -4 3 2 2 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 10 -2 -3 0 1 1 2 0 0".
    05 FILLER PIC X(100) VALUE "C head 6 10 1 -3 0 1 1 2 0 0".
    05 FILLER PIC X(100) VALUE "P body root 0 12 -10 1.5707964 0 0".
    05 FILLER PIC X(100) VALUE "C body 20 0 -2 3 -8 4 16 6 0 0".
    05 FILLER PIC X(100) VALUE "P tail1 root 0 15 8 0.9 0 0".
    05 FILLER PIC X(100) VALUE "C tail1 0 15 -0.5 0 0 1 8 1 0 0".
    05 FILLER PIC X(100) VALUE "P tail2 root 0 20 14 0 0 0".
    05 FILLER PIC X(100) VALUE "C tail2 4 15 -0.5 0 0 1 8 1 -0.02 0".
    05 FILLER PIC X(100) VALUE "P left_hind_leg root 1.1 18 5 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_hind_leg 8 13 -1 0 1 2 6 2 0 0".
    05 FILLER PIC X(100) VALUE "P right_hind_leg root -1.1 18 5 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_hind_leg 8 13 -1 0 1 2 6 2 0 0".
    05 FILLER PIC X(100) VALUE "P left_front_leg root 1.2 14.1 -5 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_front_leg 40 0 -1 0 0 2 10 2 0 0".
    05 FILLER PIC X(100) VALUE "P right_front_leg root -1.2 14.1 -5 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_front_leg 40 0 -1 0 0 2 10 2 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 61 TIMES.
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.
 01 WS-N                   BINARY-LONG VALUE 19.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO
     MOVE 64 TO MM-TEXW
     MOVE 32 TO MM-TEXH
     GOBACK.
 END PROGRAM EF5-M-OCELOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-M-CAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P head root 0 15 -9 0 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 0 -2.5 -2 -3 5 4 5 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 24 -1.5 -0.001 -4 3 2 2 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 10 -2 -3 0 1 1 2 0 0".
    05 FILLER PIC X(100) VALUE "C head 6 10 1 -3 0 1 1 2 0 0".
    05 FILLER PIC X(100) VALUE "P body root 0 12 -10 1.5707964 0 0".
    05 FILLER PIC X(100) VALUE "C body 20 0 -2 3 -8 4 16 6 0 0".
    05 FILLER PIC X(100) VALUE "P tail1 root 0 15 8 0.9 0 0".
    05 FILLER PIC X(100) VALUE "C tail1 0 15 -0.5 0 0 1 8 1 0 0".
    05 FILLER PIC X(100) VALUE "P tail2 root 0 20 14 0 0 0".
    05 FILLER PIC X(100) VALUE "C tail2 4 15 -0.5 0 0 1 8 1 -0.02 0".
    05 FILLER PIC X(100) VALUE "P left_hind_leg root 1.1 18 5 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_hind_leg 8 13 -1 0 1 2 6 2 0 0".
    05 FILLER PIC X(100) VALUE "P right_hind_leg root -1.1 18 5 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_hind_leg 8 13 -1 0 1 2 6 2 0 0".
    05 FILLER PIC X(100) VALUE "P left_front_leg root 1.2 14.1 -5 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_front_leg 40 0 -1 0 0 2 10 2 0 0".
    05 FILLER PIC X(100) VALUE "P right_front_leg root -1.2 14.1 -5 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_front_leg 40 0 -1 0 0 2 10 2 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 61 TIMES.
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.
 01 WS-N                   BINARY-LONG VALUE 19.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO
     MOVE 64 TO MM-TEXW
     MOVE 32 TO MM-TEXH
     GOBACK.
 END PROGRAM EF5-M-CAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-M-CAT-COLLAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P head root 0 15 -9 0 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 0 -2.5 -2 -3 5 4 5 0.01 0".
    05 FILLER PIC X(100) VALUE "C head 0 24 -1.5 -0.001 -4 3 2 2 0.01 0".
    05 FILLER PIC X(100) VALUE "C head 0 10 -2 -3 0 1 1 2 0.01 0".
    05 FILLER PIC X(100) VALUE "C head 6 10 1 -3 0 1 1 2 0.01 0".
    05 FILLER PIC X(100) VALUE "P body root 0 12 -10 1.5707964 0 0".
    05 FILLER PIC X(100) VALUE "C body 20 0 -2 3 -8 4 16 6 0.01 0".
    05 FILLER PIC X(100) VALUE "P tail1 root 0 15 8 0.9 0 0".
    05 FILLER PIC X(100) VALUE "C tail1 0 15 -0.5 0 0 1 8 1 0.01 0".
    05 FILLER PIC X(100) VALUE "P tail2 root 0 20 14 0 0 0".
    05 FILLER PIC X(100) VALUE "C tail2 4 15 -0.5 0 0 1 8 1 -0.02 0".
    05 FILLER PIC X(100) VALUE "P left_hind_leg root 1.1 18 5 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_hind_leg 8 13 -1 0 1 2 6 2 0.01 0".
    05 FILLER PIC X(100) VALUE "P right_hind_leg root -1.1 18 5 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_hind_leg 8 13 -1 0 1 2 6 2 0.01 0".
    05 FILLER PIC X(100) VALUE "P left_front_leg root 1.2 14.1 -5 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_front_leg 40 0 -1 0 0 2 10 2 0.01 0".
    05 FILLER PIC X(100) VALUE "P right_front_leg root -1.2 14.1 -5 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_front_leg 40 0 -1 0 0 2 10 2 0.01 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 61 TIMES.
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.
 01 WS-N                   BINARY-LONG VALUE 19.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO
     MOVE 64 TO MM-TEXW
     MOVE 32 TO MM-TEXH
     GOBACK.
 END PROGRAM EF5-M-CAT-COLLAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-M-OCELOT-BABY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P head root 0 20 -3.125 0 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 0 -2.5 -3 -2.875 5 4 4 0 0".
    05 FILLER PIC X(100) VALUE "C head 18 0 -2 -4 -0.875 1 1 2 0 0".
    05 FILLER PIC X(100) VALUE "C head 24 0 1 -4 -0.875 1 1 2 0 0".
    05 FILLER PIC X(100) VALUE "C head 18 3 -1.5 -1 -3.875 3 2 1 0 0".
    05 FILLER PIC X(100) VALUE "P left_front_leg root 1 22 -1.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_front_leg 18 18 -0.5 0 -1 1 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P right_front_leg root -1 22 -1.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_front_leg 12 18 -0.5 0 -1 1 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P left_hind_leg root 1 22 2.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_hind_leg 18 22 -0.5 0 -1 1 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P body root 0 20.5 0.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 8 -2 -1.5 -3.5 4 3 7 0 0".
    05 FILLER PIC X(100) VALUE "P right_hind_leg root -1 22 2.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_hind_leg 12 22 -0.5 0 -1 1 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P tail1 root 0 19.107 3.9151 -0.567232 0 0".
    05 FILLER PIC X(100) VALUE "C tail1 0 18 -0.5 -0.107 0.0849 1 1 5 0 0".
    05 FILLER PIC X(100) VALUE "P tail2 root 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 62 TIMES.
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.
 01 WS-N                   BINARY-LONG VALUE 18.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO
     MOVE 32 TO MM-TEXW
     MOVE 32 TO MM-TEXH
     GOBACK.
 END PROGRAM EF5-M-OCELOT-BABY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-M-CAT-BABY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P head root 0 20 -3.125 0 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 0 -2.5 -3 -2.875 5 4 4 0 0".
    05 FILLER PIC X(100) VALUE "C head 18 0 -2 -4 -0.875 1 1 2 0 0".
    05 FILLER PIC X(100) VALUE "C head 24 0 1 -4 -0.875 1 1 2 0 0".
    05 FILLER PIC X(100) VALUE "C head 18 3 -1.5 -1 -3.875 3 2 1 0 0".
    05 FILLER PIC X(100) VALUE "P left_front_leg root 1 22 -1.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_front_leg 18 18 -0.5 0 -1 1 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P right_front_leg root -1 22 -1.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_front_leg 12 18 -0.5 0 -1 1 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P left_hind_leg root 1 22 2.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_hind_leg 18 22 -0.5 0 -1 1 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P body root 0 20.5 0.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 8 -2 -1.5 -3.5 4 3 7 0 0".
    05 FILLER PIC X(100) VALUE "P right_hind_leg root -1 22 2.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_hind_leg 12 22 -0.5 0 -1 1 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P tail1 root 0 19.107 3.9151 -0.567232 0 0".
    05 FILLER PIC X(100) VALUE "C tail1 0 18 -0.5 -0.107 0.0849 1 1 5 0 0".
    05 FILLER PIC X(100) VALUE "P tail2 root 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 62 TIMES.
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.
 01 WS-N                   BINARY-LONG VALUE 18.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO
     MOVE 32 TO MM-TEXW
     MOVE 32 TO MM-TEXH
     GOBACK.
 END PROGRAM EF5-M-CAT-BABY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-M-CAT-BABY-COLLAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P head root 0 20 -3.125 0 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 0 -2.5 -3 -2.875 5 4 4 0 0".
    05 FILLER PIC X(100) VALUE "C head 18 0 -2 -4 -0.875 1 1 2 0 0".
    05 FILLER PIC X(100) VALUE "C head 24 0 1 -4 -0.875 1 1 2 0 0".
    05 FILLER PIC X(100) VALUE "C head 18 3 -1.5 -1 -3.875 3 2 1 0 0".
    05 FILLER PIC X(100) VALUE "P left_front_leg root 1 22 -1.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_front_leg 18 18 -0.5 0 -1 1 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P right_front_leg root -1 22 -1.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_front_leg 12 18 -0.5 0 -1 1 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P left_hind_leg root 1 22 2.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_hind_leg 18 22 -0.5 0 -1 1 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P body root 0 20.5 0.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 8 -2 -1.5 -3.5 4 3 7 0 0".
    05 FILLER PIC X(100) VALUE "P right_hind_leg root -1 22 2.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_hind_leg 12 22 -0.5 0 -1 1 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P tail1 root 0 19.107 3.9151 -0.567232 0 0".
    05 FILLER PIC X(100) VALUE "C tail1 0 18 -0.5 -0.107 0.0849 1 1 5 0 0".
    05 FILLER PIC X(100) VALUE "P tail2 root 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 62 TIMES.
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.
 01 WS-N                   BINARY-LONG VALUE 18.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO
     MOVE 32 TO MM-TEXW
     MOVE 32 TO MM-TEXH
     GOBACK.
 END PROGRAM EF5-M-CAT-BABY-COLLAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-FELINE-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-B                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-T1                  BINARY-LONG.
 01 WS-T2                  BINARY-LONG.
 01 WS-LH                  BINARY-LONG.
 01 WS-RH                  BINARY-LONG.
 01 WS-LF                  BINARY-LONG.
 01 WS-RF                  BINARY-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-LI.
    05 WS-LV               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-LO.
    05 WS-LOV              FLOAT-LONG OCCURS 64 TIMES.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "body" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-B
     MOVE "head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-H
     MOVE "tail1" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-T1
     MOVE "tail2" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-T2
     MOVE "left_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LH
     MOVE "right_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RH
     MOVE "left_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LF
     MOVE "right_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RF
     MOVE L-I(5) TO WS-A
     MOVE L-I(3) TO WS-P
     MOVE L-I(4) TO WS-S
     IF L-I(6) NOT = 0
         COMPUTE MM-CY(WS-B) = MM-CY(WS-B) + 1 * WS-A
         COMPUTE MM-CY(WS-H) = MM-CY(WS-H) + 2 * WS-A
         COMPUTE MM-CY(WS-T1) = MM-CY(WS-T1) + 1 * WS-A
         COMPUTE MM-CY(WS-T2) = MM-CY(WS-T2) - 4 * WS-A
         COMPUTE MM-CZ(WS-T2) = MM-CZ(WS-T2) + 2 * WS-A
         MOVE 1.5707964 TO MM-CXROT(WS-T1) MM-CXROT(WS-T2)
     ELSE
         IF L-I(7) NOT = 0
             MOVE MM-CY(WS-T1) TO MM-CY(WS-T2)
             COMPUTE MM-CZ(WS-T2) = MM-CZ(WS-T2) + 2 * WS-A
             MOVE 1.5707964 TO MM-CXROT(WS-T1) MM-CXROT(WS-T2)
         END-IF
     END-IF
     COMPUTE MM-CXROT(WS-H) = L-I(1) * 0.017453292
     COMPUTE MM-CYROT(WS-H) = L-I(2) * 0.017453292
     IF L-I(8) = 0
         IF L-I(12) = 0
             MOVE 1.5707964 TO MM-CXROT(WS-B)
         END-IF
         IF L-I(7) NOT = 0
             COMPUTE MM-CXROT(WS-LH) = FUNCTION COS(0.6662 * WS-P) * WS-S
             COMPUTE MM-CXROT(WS-RH) = FUNCTION COS(0.6662 * WS-P + 0.3) * WS-S
             COMPUTE MM-CXROT(WS-LF) = FUNCTION COS(0.6662 * WS-P + 3.141592653589793 + 0.3) * WS-S
             COMPUTE MM-CXROT(WS-RF) = FUNCTION COS(0.6662 * WS-P + 3.141592653589793) * WS-S
             COMPUTE MM-CXROT(WS-T2) = 1.7278761 + 0.31415927 * FUNCTION COS(WS-P) * WS-S
         ELSE
             COMPUTE MM-CXROT(WS-LH) = FUNCTION COS(0.6662 * WS-P) * WS-S
             COMPUTE MM-CXROT(WS-RH) = FUNCTION COS(0.6662 * WS-P + 3.141592653589793) * WS-S
             COMPUTE MM-CXROT(WS-LF) = FUNCTION COS(0.6662 * WS-P + 3.141592653589793) * WS-S
             COMPUTE MM-CXROT(WS-RF) = FUNCTION COS(0.6662 * WS-P) * WS-S
             IF L-I(6) NOT = 0
                 COMPUTE MM-CXROT(WS-T2) = 1.7278761 + 0.47123894 * FUNCTION COS(WS-P) * WS-S
             ELSE
                 COMPUTE MM-CXROT(WS-T2) = 1.7278761 + 0.7853982 * FUNCTION COS(WS-P) * WS-S
             END-IF
         END-IF
     ELSE
         IF L-I(12) = 0
             MOVE 0.7853982 TO MM-CXROT(WS-B)
             COMPUTE MM-CY(WS-B) = MM-CY(WS-B) - 4 * WS-A
             COMPUTE MM-CZ(WS-B) = MM-CZ(WS-B) + 5 * WS-A
             COMPUTE MM-CY(WS-H) = MM-CY(WS-H) - 3.3 * WS-A
             COMPUTE MM-CZ(WS-H) = MM-CZ(WS-H) + 1 * WS-A
             COMPUTE MM-CY(WS-T1) = MM-CY(WS-T1) + 8 * WS-A
             COMPUTE MM-CZ(WS-T1) = MM-CZ(WS-T1) - 2 * WS-A
             COMPUTE MM-CY(WS-T2) = MM-CY(WS-T2) + 2 * WS-A
             COMPUTE MM-CZ(WS-T2) = MM-CZ(WS-T2) - 0.8 * WS-A
             MOVE 1.7278761 TO MM-CXROT(WS-T1)
             MOVE 2.670354 TO MM-CXROT(WS-T2)
             MOVE -0.15707964 TO MM-CXROT(WS-LF) MM-CXROT(WS-RF)
             COMPUTE MM-CY(WS-LF) = MM-CY(WS-LF) + 2 * WS-A
             COMPUTE MM-CZ(WS-LF) = MM-CZ(WS-LF) - 2 * WS-A
             COMPUTE MM-CY(WS-RF) = MM-CY(WS-RF) + 2 * WS-A
             COMPUTE MM-CZ(WS-RF) = MM-CZ(WS-RF) - 2 * WS-A
             MOVE -1.5707964 TO MM-CXROT(WS-LH) MM-CXROT(WS-RH)
             COMPUTE MM-CY(WS-LH) = MM-CY(WS-LH) + 3 * WS-A
             COMPUTE MM-CZ(WS-LH) = MM-CZ(WS-LH) - 4 * WS-A
             COMPUTE MM-CY(WS-RH) = MM-CY(WS-RH) + 3 * WS-A
             COMPUTE MM-CZ(WS-RH) = MM-CZ(WS-RH) - 4 * WS-A
         ELSE
             COMPUTE MM-CXROT(WS-B) = MM-CXROT(WS-B) - 0.43633232
             COMPUTE MM-CY(WS-B) = MM-CY(WS-B) + 1.25
             COMPUTE MM-CZ(WS-H) = MM-CZ(WS-H) + 0.75
             COMPUTE MM-CXROT(WS-T1) = MM-CXROT(WS-T1) + 0.5454154
             COMPUTE MM-CY(WS-T1) = MM-CY(WS-T1) + 4.0
             COMPUTE MM-CZ(WS-T1) = MM-CZ(WS-T1) - 0.9
             COMPUTE MM-CZ(WS-LH) = MM-CZ(WS-LH) - 0.9
             COMPUTE MM-CZ(WS-RH) = MM-CZ(WS-RH) - 0.9
         END-IF
     END-IF
     IF L-I(9) > 0
         IF L-I(12) = 0
             COMPUTE MM-CZROT(WS-H) = MM-CZROT(WS-H) + L-I(9) * (-1.2707963 - MM-CZROT(WS-H))
             COMPUTE MM-CYROT(WS-H) = MM-CYROT(WS-H) + L-I(9) * (1.2707963 - MM-CYROT(WS-H))
             MOVE -1.2707963 TO MM-CXROT(WS-LF)
             MOVE -0.47079635 TO MM-CXROT(WS-RF)
             MOVE -0.2 TO MM-CZROT(WS-RF)
             COMPUTE MM-CX(WS-RF) = MM-CX(WS-RF) + WS-A
             MOVE -0.4 TO MM-CXROT(WS-LH)
             MOVE 0.5 TO MM-CXROT(WS-RH)
             MOVE -0.5 TO MM-CZROT(WS-RH)
             COMPUTE MM-CX(WS-RH) = MM-CX(WS-RH) + 0.8 * WS-A
             COMPUTE MM-CY(WS-RH) = MM-CY(WS-RH) + 2 * WS-A
             COMPUTE MM-CXROT(WS-T1) = MM-CXROT(WS-T1) + L-I(10) * (0.8 - MM-CXROT(WS-T1))
             COMPUTE MM-CXROT(WS-T2) = MM-CXROT(WS-T2) + L-I(10) * (-0.4 - MM-CXROT(WS-T2))
         ELSE
             COMPUTE MM-CX(WS-B) = MM-CX(WS-B) + 1
             COMPUTE MM-CXROT(WS-H) = MM-CXROT(WS-H) + L-I(9) * (0.17453292 - MM-CXROT(WS-H))
             COMPUTE MM-CZROT(WS-H) = MM-CZROT(WS-H) + L-I(9) * (-1.3089969 - MM-CZROT(WS-H))
             COMPUTE MM-CX(WS-H) = MM-CX(WS-H) + 1.5
             COMPUTE MM-CY(WS-H) = MM-CY(WS-H) + 0.75
             COMPUTE MM-CZ(WS-H) = MM-CZ(WS-H) - 0.5
             MOVE -0.7853982 TO MM-CXROT(WS-RF)
             COMPUTE MM-CX(WS-RF) = MM-CX(WS-RF) + 3.5
             COMPUTE MM-CY(WS-RF) = MM-CY(WS-RF) - 0.5
             MOVE -1.5707964 TO MM-CXROT(WS-LF)
             COMPUTE MM-CX(WS-LF) = MM-CX(WS-LF) + 1.5
             COMPUTE MM-CY(WS-LF) = MM-CY(WS-LF) - 1
             COMPUTE MM-CZ(WS-LF) = MM-CZ(WS-LF) - 2
             MOVE 0.6981317 TO MM-CXROT(WS-RH)
             MOVE 0.34906584 TO MM-CYROT(WS-RH)
             MOVE -0.34906584 TO MM-CZROT(WS-RH)
             COMPUTE MM-CX(WS-RH) = MM-CX(WS-RH) + 2.5
             COMPUTE MM-CY(WS-RH) = MM-CY(WS-RH) - 0.25
             COMPUTE MM-CZ(WS-RH) = MM-CZ(WS-RH) + 0.5
             COMPUTE MM-CX(WS-LH) = MM-CX(WS-LH) + 1.5
             COMPUTE MM-CZ(WS-LH) = MM-CZ(WS-LH) - 1
             COMPUTE MM-CXROT(WS-T1) = MM-CXROT(WS-T1) + (MM-CXROT(WS-T1) + L-I(10) * (-0.5235988 - MM-CXROT(WS-T1)))
             COMPUTE MM-CYROT(WS-T1) = MM-CYROT(WS-T1) + (MM-CYROT(WS-T1) + L-I(10) * (0 - MM-CYROT(WS-T1)))
             COMPUTE MM-CZROT(WS-T1) = MM-CZROT(WS-T1) + (MM-CZROT(WS-T1) + L-I(10) * (-0.17453292 - MM-CZROT(WS-T1)))
             COMPUTE MM-CX(WS-T1) = MM-CX(WS-T1) + 1
             COMPUTE MM-CY(WS-T1) = MM-CY(WS-T1) + 0.5
             COMPUTE MM-CZ(WS-T1) = MM-CZ(WS-T1) - 0.25
         END-IF
     END-IF
     IF L-I(11) > 0
         COMPUTE MM-CXROT(WS-H) = MM-CXROT(WS-H) + L-I(11) * (-0.58177644 - MM-CXROT(WS-H))
     END-IF
     GOBACK.
 END PROGRAM EF5-FELINE-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-OCELOT-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     MOVE "textures/entity/cat/ocelot.png" TO L-PATH
     IF L-I(1) NOT = 0
         MOVE "textures/entity/cat/ocelot_baby.png" TO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EF5-OCELOT-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-CAT-COLLAR-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     MOVE "textures/entity/cat/cat_collar.png" TO L-PATH
     IF L-I(1) NOT = 0
         MOVE "textures/entity/cat/cat_collar_baby.png" TO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EF5-CAT-COLLAR-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-CAT-COLLAR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) NOT = 0
         MOVE 1 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EF5-CAT-COLLAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-CAT-BODY-OPS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) > 0
         MOVE 2 TO L-O(1)
         MOVE 1 TO L-O(2)
         COMPUTE L-O(3) = 0.4 * L-I(1)
         COMPUTE L-O(4) = 0.15 * L-I(1)
         COMPUTE L-O(5) = 0.1 * L-I(1)
         MOVE 4 TO L-O(6)
         MOVE 0 TO L-O(7) L-O(8)
         COMPUTE L-O(9) = L-I(1) * 90
         IF L-I(2) NOT = 0
             MOVE 3 TO L-O(1)
             MOVE 1 TO L-O(10)
             COMPUTE L-O(11) = 0.15 * L-I(1)
             MOVE 0 TO L-O(12) L-O(13)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EF5-CAT-BODY-OPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-LERP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(2) + L-I(1) * (L-I(3) - L-I(2))
     GOBACK.
 END PROGRAM EF5-LERP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-CAT-COUNTERS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     IF L-I(4) NOT = 0
         COMPUTE L-O(1) = FUNCTION MIN(1, L-I(1) + 0.15)
         COMPUTE L-O(2) = FUNCTION MIN(1, L-I(2) + 0.08)
     ELSE
         COMPUTE L-O(1) = FUNCTION MAX(0, L-I(1) - 0.22)
         COMPUTE L-O(2) = FUNCTION MAX(0, L-I(2) - 0.13)
     END-IF
     IF L-I(5) NOT = 0
         COMPUTE L-O(3) = FUNCTION MIN(1, L-I(3) + 0.1)
     ELSE
         COMPUTE L-O(3) = FUNCTION MAX(0, L-I(3) - 0.13)
     END-IF
     GOBACK.
 END PROGRAM EF5-CAT-COUNTERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-CAT-ON-PLAYER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) NOT = 0 AND L-I(2) NOT = 0
         MOVE 1 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EF5-CAT-ON-PLAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-CAT-PURR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF (L-I(2) NOT = 0 OR L-I(3) NOT = 0) AND FUNCTION MOD(L-I(1), 5) = 0
         MOVE 1 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EF5-CAT-PURR.
