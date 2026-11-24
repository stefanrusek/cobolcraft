*> Entity models part 6 section 6 (Spider and cave spider): the one mesh (6.1; the CAVE_SPIDER layer is the same mesh through EMD-SCALE-ROOT 0.7), setupAnim (6.2), textures (6.3).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF6-SPIDER-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 walk position, 4 walk speed): reset first, head look, then the four leg pairs (phases 0, pi, pi/2, 3 pi/2); EF6-SPIDER-TEXTURE IN(cave spider, eyes layer) path(out X(120)).


 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-M-SPIDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P head root 0 15 -3 0 0 0".
    05 FILLER PIC X(100) VALUE "C head 32 4 -4 -4 -8 8 8 8 0 0".
    05 FILLER PIC X(100) VALUE "P body0 root 0 15 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C body0 0 0 -3 -3 -3 6 6 6 0 0".
    05 FILLER PIC X(100) VALUE "P body1 root 0 15 9 0 0 0".
    05 FILLER PIC X(100) VALUE "C body1 0 12 -5 -4 -6 10 8 12 0 0".
    05 FILLER PIC X(100) VALUE "P right_hind_leg root -4 15 2 0 0.7853982 -0.7853982".
    05 FILLER PIC X(100) VALUE "C right_hind_leg 18 0 -15 -1 -1 16 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P left_hind_leg root 4 15 2 0 -0.7853982 0.7853982".
    05 FILLER PIC X(100) VALUE "C left_hind_leg 18 0 -1 -1 -1 16 2 2 0 1".
    05 FILLER PIC X(100) VALUE "P right_middle_hind_leg root -4 15 1 0 0.3926991 -0.58119464".
    05 FILLER PIC X(100) VALUE "C right_middle_hind_leg 18 0 -15 -1 -1 16 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P left_middle_hind_leg root 4 15 1 0 -0.3926991 0.58119464".
    05 FILLER PIC X(100) VALUE "C left_middle_hind_leg 18 0 -1 -1 -1 16 2 2 0 1".
    05 FILLER PIC X(100) VALUE "P right_middle_front_leg root -4 15 0 0 -0.3926991 -0.58119464".
    05 FILLER PIC X(100) VALUE "C right_middle_front_leg 18 0 -15 -1 -1 16 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P left_middle_front_leg root 4 15 0 0 0.3926991 0.58119464".
    05 FILLER PIC X(100) VALUE "C left_middle_front_leg 18 0 -1 -1 -1 16 2 2 0 1".
    05 FILLER PIC X(100) VALUE "P right_front_leg root -4 15 -1 0 -0.7853982 -0.7853982".
    05 FILLER PIC X(100) VALUE "C right_front_leg 18 0 -15 -1 -1 16 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P left_front_leg root 4 15 -1 0 0.7853982 0.7853982".
    05 FILLER PIC X(100) VALUE "C left_front_leg 18 0 -1 -1 -1 16 2 2 0 1".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 58 TIMES.
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.
 01 WS-N                   BINARY-LONG VALUE 22.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO
     MOVE 64 TO MM-TEXW
     MOVE 32 TO MM-TEXH
     GOBACK.
 END PROGRAM EF6-M-SPIDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-SPIDER-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-H                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-TH                  FLOAT-LONG.
 01 WS-PHI                 FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-H
     COMPUTE MM-CYROT(WS-H) = L-I(2) * 0.017453292
     COMPUTE MM-CXROT(WS-H) = L-I(1) * 0.017453292
     COMPUTE WS-TH = L-I(3) * 0.6662
     MOVE "right_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-R
     MOVE "left_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-L
     MOVE 0 TO WS-PHI
     COMPUTE WS-A = 0 - (FUNCTION COS(2 * WS-TH + WS-PHI) * 0.4) * L-I(4)
     COMPUTE WS-B = FUNCTION ABS(FUNCTION SIN(WS-TH + WS-PHI) * 0.4) * L-I(4)
     COMPUTE MM-CYROT(WS-R) = MM-CYROT(WS-R) + WS-A
     COMPUTE MM-CZROT(WS-R) = MM-CZROT(WS-R) + WS-B
     COMPUTE MM-CYROT(WS-L) = MM-CYROT(WS-L) - WS-A
     COMPUTE MM-CZROT(WS-L) = MM-CZROT(WS-L) - WS-B
     MOVE "right_middle_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-R
     MOVE "left_middle_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-L
     MOVE 3.1415927 TO WS-PHI
     COMPUTE WS-A = 0 - (FUNCTION COS(2 * WS-TH + WS-PHI) * 0.4) * L-I(4)
     COMPUTE WS-B = FUNCTION ABS(FUNCTION SIN(WS-TH + WS-PHI) * 0.4) * L-I(4)
     COMPUTE MM-CYROT(WS-R) = MM-CYROT(WS-R) + WS-A
     COMPUTE MM-CZROT(WS-R) = MM-CZROT(WS-R) + WS-B
     COMPUTE MM-CYROT(WS-L) = MM-CYROT(WS-L) - WS-A
     COMPUTE MM-CZROT(WS-L) = MM-CZROT(WS-L) - WS-B
     MOVE "right_middle_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-R
     MOVE "left_middle_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-L
     MOVE 1.5707964 TO WS-PHI
     COMPUTE WS-A = 0 - (FUNCTION COS(2 * WS-TH + WS-PHI) * 0.4) * L-I(4)
     COMPUTE WS-B = FUNCTION ABS(FUNCTION SIN(WS-TH + WS-PHI) * 0.4) * L-I(4)
     COMPUTE MM-CYROT(WS-R) = MM-CYROT(WS-R) + WS-A
     COMPUTE MM-CZROT(WS-R) = MM-CZROT(WS-R) + WS-B
     COMPUTE MM-CYROT(WS-L) = MM-CYROT(WS-L) - WS-A
     COMPUTE MM-CZROT(WS-L) = MM-CZROT(WS-L) - WS-B
     MOVE "right_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-R
     MOVE "left_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-L
     MOVE 4.712389 TO WS-PHI
     COMPUTE WS-A = 0 - (FUNCTION COS(2 * WS-TH + WS-PHI) * 0.4) * L-I(4)
     COMPUTE WS-B = FUNCTION ABS(FUNCTION SIN(WS-TH + WS-PHI) * 0.4) * L-I(4)
     COMPUTE MM-CYROT(WS-R) = MM-CYROT(WS-R) + WS-A
     COMPUTE MM-CZROT(WS-R) = MM-CZROT(WS-R) + WS-B
     COMPUTE MM-CYROT(WS-L) = MM-CYROT(WS-L) - WS-A
     COMPUTE MM-CZROT(WS-L) = MM-CZROT(WS-L) - WS-B
     GOBACK.
 END PROGRAM EF6-SPIDER-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-SPIDER-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     EVALUATE TRUE
         WHEN L-I(2) NOT = 0
             MOVE "textures/entity/spider/spider_eyes.png" TO L-PATH
         WHEN L-I(1) NOT = 0
             MOVE "textures/entity/spider/cave_spider.png" TO L-PATH
         WHEN OTHER
             MOVE "textures/entity/spider/spider.png" TO L-PATH
     END-EVALUATE
     GOBACK.
 END PROGRAM EF6-SPIDER-TEXTURE.
