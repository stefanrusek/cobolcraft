*> Entity models part 4 section 7 (Goat): the meshes of goat and goat_baby (7.3), the texture paths (7.1) and setupAnim (7.2).
*> Entry points for the integrator (inputs): EF4-GOAT-TEXTURE IN(baby) path(out X(120)); EF4-GOAT-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 walk position, 4 walk speed,
*>   5 has left horn, 6 has right horn, 7 rammingXHeadRot, 8 baby model): QuadrupedModel.setupAnim, horn visibility, ramming pitch, the baby's 0.3926991 tilt when not ramming.


 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-M-GOAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P head root 1 14 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C head 2 61 -6 -11 -10 3 2 1 0 0".
    05 FILLER PIC X(100) VALUE "C head 2 61 2 -11 -10 3 2 1 0 1".
    05 FILLER PIC X(100) VALUE "C head 23 52 -0.5 -3 -14 0 7 5 0 1".
    05 FILLER PIC X(100) VALUE "P left_horn head 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_horn 12 55 -0.01 -16 -10 2 7 2 0 0".
    05 FILLER PIC X(100) VALUE "P right_horn head 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_horn 12 55 -2.99 -16 -10 2 7 2 0 0".
    05 FILLER PIC X(100) VALUE "P nose head 0 -8 -8 0.9599 0 0".
    05 FILLER PIC X(100) VALUE "C nose 34 46 -3 -4 -8 5 7 10 0 0".
    05 FILLER PIC X(100) VALUE "P body root 0 24 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C body 1 1 -4 -17 -7 9 11 16 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 28 -5 -18 -8 11 14 11 0 0".
    05 FILLER PIC X(100) VALUE "P left_hind_leg root 1 14 4 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_hind_leg 36 29 0 4 0 3 6 3 0 0".
    05 FILLER PIC X(100) VALUE "P right_hind_leg root -3 14 4 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_hind_leg 49 29 0 4 0 3 6 3 0 0".
    05 FILLER PIC X(100) VALUE "P left_front_leg root 1 14 -6 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_front_leg 49 2 0 0 0 3 10 3 0 0".
    05 FILLER PIC X(100) VALUE "P right_front_leg root -3 14 -6 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_front_leg 35 2 0 0 0 3 10 3 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 59 TIMES.
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.
 01 WS-N                   BINARY-LONG VALUE 21.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO
     MOVE 64 TO MM-TEXW
     MOVE 64 TO MM-TEXH
     GOBACK.
 END PROGRAM EF4-M-GOAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-M-GOAT-BABY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P left_hind_leg root 1.5 19.5 3 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_hind_leg 29 12 -1 -0.5 -1 2 5 2 0 0".
    05 FILLER PIC X(100) VALUE "P right_hind_leg root -1.5 19.5 3 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_hind_leg 21 12 -1 -0.5 -1 2 5 2 0 0".
    05 FILLER PIC X(100) VALUE "P right_front_leg root -1.5 19.5 -2 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_front_leg 21 5 -1 -0.5 -1 2 5 2 0 0".
    05 FILLER PIC X(100) VALUE "P left_front_leg root 1.5 19.5 -2 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_front_leg 29 5 -1 -0.5 -1 2 5 2 0 0".
    05 FILLER PIC X(100) VALUE "P body root 0 17.8 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 10 -3 -2.3 -4.5 6 5 9 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 24 -2.5 -2.2 -4 5 4 8 0 0".
    05 FILLER PIC X(100) VALUE "P head root 0 15.5 -3 0.4363 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 0 -2 -3.8126 -5.1548 4 4 6 0 0".
    05 FILLER PIC X(100) VALUE "P right_horn head -1.5 -1.5 -1 -0.3926991 0 0".
    05 FILLER PIC X(100) VALUE "C right_horn 24 0 0 -4.5 0 1 2 1 0 1".
    05 FILLER PIC X(100) VALUE "P left_horn head -1.5 -1.5 -1 -0.3926991 0 0".
    05 FILLER PIC X(100) VALUE "C left_horn 24 0 2 -4.5 0 1 2 1 0 1".
    05 FILLER PIC X(100) VALUE "P right_ear head -1.7 -2.3126 0.1452 0 -0.5236 0".
    05 FILLER PIC X(100) VALUE "C right_ear 0 12 -2 -0.5 -0.5 2 1 1 0 1".
    05 FILLER PIC X(100) VALUE "P left_ear head 1.7 -2.3126 0.1452 0 0.5236 0".
    05 FILLER PIC X(100) VALUE "C left_ear 0 12 0 -0.5 -0.5 2 1 1 0 0".
    05 FILLER PIC X(100) VALUE "P HeadMain head 0 -1.3126 -1.1548 0 0 0".
    05 FILLER PIC X(100) VALUE "C HeadMain 0 0 -2 -2.5 -4 4 4 6 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 57 TIMES.
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.
 01 WS-N                   BINARY-LONG VALUE 23.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO
     MOVE 64 TO MM-TEXW
     MOVE 64 TO MM-TEXH
     GOBACK.
 END PROGRAM EF4-M-GOAT-BABY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-GOAT-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     MOVE "textures/entity/goat/goat.png" TO L-PATH
     IF L-I(1) NOT = 0
         MOVE "textures/entity/goat/goat_baby.png" TO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EF4-GOAT-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-GOAT-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-P                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EF4-QUAD-POSE" USING EMM-MODEL L-IN
     MOVE "head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-H
     MOVE "left_horn" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
     MOVE 0 TO MM-VISIBLE(WS-P)
     IF L-I(5) NOT = 0
         MOVE 1 TO MM-VISIBLE(WS-P)
     END-IF
     MOVE "right_horn" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
     MOVE 0 TO MM-VISIBLE(WS-P)
     IF L-I(6) NOT = 0
         MOVE 1 TO MM-VISIBLE(WS-P)
     END-IF
     IF L-I(7) NOT = 0
         MOVE L-I(7) TO MM-CXROT(WS-H)
     END-IF
     IF L-I(8) NOT = 0 AND L-I(7) = 0
         MOVE 0.3926991 TO MM-CXROT(WS-H)
     END-IF
     GOBACK.
 END PROGRAM EF4-GOAT-ANIM.
