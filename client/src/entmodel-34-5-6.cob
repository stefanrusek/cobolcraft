*> Entity models part 5 section 6 (Polar bear): the meshes of the adult (scaled 1.2) and the baby, the pose after the quadruped base, textures, stand scale and counter.
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF5-BEAR-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 walk position, 4 walk speed, 5 standScale, 6 ageScale): the quadruped base then the standing pose (pixel offsets are multiplied by the scale of the body part,
*>   the layer scale carried by the root children); EF5-BEAR-STAND IN(partial, old counter, counter) OUT(standScale: the lerp divided by 6); EF5-BEAR-COUNTER IN(counter, standing) OUT(counter after a tick, 0 to 6);
*>   EF5-BEAR-TEXTURE IN(baby) path(out X(120)).


 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-M-POLAR-BEAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P head root 0 10 -16 0 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 0 -3.5 -3 -3 7 7 7 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 44 -2.5 1 -6 5 3 3 0 0".
    05 FILLER PIC X(100) VALUE "C head 26 0 -4.5 -4 -1 2 2 1 0 0".
    05 FILLER PIC X(100) VALUE "C head 26 0 2.5 -4 -1 2 2 1 0 1".
    05 FILLER PIC X(100) VALUE "P body root -2 9 12 1.5707964 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 19 -5 -13 -7 14 14 11 0 0".
    05 FILLER PIC X(100) VALUE "C body 39 0 -4 -25 -7 12 12 10 0 0".
    05 FILLER PIC X(100) VALUE "P right_hind_leg root -4.5 14 6 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_hind_leg 50 22 -2 0 -2 4 10 8 0 0".
    05 FILLER PIC X(100) VALUE "P left_hind_leg root 4.5 14 6 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_hind_leg 50 22 -2 0 -2 4 10 8 0 0".
    05 FILLER PIC X(100) VALUE "P right_front_leg root -3.5 14 -8 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_front_leg 50 40 -2 0 -2 4 10 6 0 0".
    05 FILLER PIC X(100) VALUE "P left_front_leg root 3.5 14 -8 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_front_leg 50 40 -2 0 -2 4 10 6 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 64 TIMES.
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.
 01 WS-N                   BINARY-LONG VALUE 16.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO
     MOVE 128 TO MM-TEXW
     MOVE 64 TO MM-TEXH
     GOBACK.
 END PROGRAM EF5-M-POLAR-BEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-M-POLAR-BEAR-BABY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P body root 0 17.5 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 9 -4 -3.5 -6 8 7 12 0 0".
    05 FILLER PIC X(100) VALUE "P head root 0 18.625 -5.75 0 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 0 -3 -2.625 -4.25 6 5 4 0 0".
    05 FILLER PIC X(100) VALUE "C head 20 3 -2 0.375 -6.25 4 2 2 0 0".
    05 FILLER PIC X(100) VALUE "C head 20 0 -4 -3.625 -2.75 2 2 1 0 0".
    05 FILLER PIC X(100) VALUE "C head 26 0 2 -3.625 -2.75 2 2 1 0 0".
    05 FILLER PIC X(100) VALUE "P right_hind_leg root -2.5 21.5 4.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_hind_leg 0 34 -1.5 -0.5 -1.5 3 3 3 0 0".
    05 FILLER PIC X(100) VALUE "P left_hind_leg root 2.5 21.5 4.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_hind_leg 12 34 -1.5 -0.5 -1.5 3 3 3 0 0".
    05 FILLER PIC X(100) VALUE "P right_front_leg root -2.5 21.5 -4.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_front_leg 0 28 -1.5 -0.5 -1.5 3 3 3 0 0".
    05 FILLER PIC X(100) VALUE "P left_front_leg root 2.5 21.5 -4.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_front_leg 12 28 -1.5 -0.5 -1.5 3 3 3 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 65 TIMES.
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.
 01 WS-N                   BINARY-LONG VALUE 15.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO
     MOVE 64 TO MM-TEXW
     MOVE 64 TO MM-TEXH
     GOBACK.
 END PROGRAM EF5-M-POLAR-BEAR-BABY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-BEAR-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-B                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-RF                  BINARY-LONG.
 01 WS-LF                  BINARY-LONG.
 01 WS-E                   FLOAT-LONG.
 01 WS-SC                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EF5-QUAD-POSE" USING EMM-MODEL L-IN
     MOVE "body" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-B
     MOVE "head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-H
     MOVE "right_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RF
     MOVE "left_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LF
     MOVE MM-YSCALE(WS-B) TO WS-SC
     COMPUTE WS-E = L-I(5) * L-I(5)
     COMPUTE MM-CXROT(WS-B) = MM-CXROT(WS-B) - WS-E * 3.141592653589793 * 0.35
     COMPUTE MM-CY(WS-B) = MM-CY(WS-B) + WS-E * L-I(6) * 2 * WS-SC
     COMPUTE MM-CY(WS-RF) = MM-CY(WS-RF) - WS-E * L-I(6) * 20 * WS-SC
     COMPUTE MM-CZ(WS-RF) = MM-CZ(WS-RF) + WS-E * L-I(6) * 4 * WS-SC
     COMPUTE MM-CXROT(WS-RF) = MM-CXROT(WS-RF) - WS-E * 3.141592653589793 * 0.45
     MOVE MM-CY(WS-RF) TO MM-CY(WS-LF)
     MOVE MM-CZ(WS-RF) TO MM-CZ(WS-LF)
     COMPUTE MM-CXROT(WS-LF) = MM-CXROT(WS-LF) - WS-E * 3.141592653589793 * 0.45
     COMPUTE MM-CY(WS-H) = MM-CY(WS-H) - WS-E * 24 * WS-SC
     COMPUTE MM-CZ(WS-H) = MM-CZ(WS-H) + WS-E * 13 * WS-SC
     COMPUTE MM-CXROT(WS-H) = MM-CXROT(WS-H) + WS-E * 3.141592653589793 * 0.15
     GOBACK.
 END PROGRAM EF5-BEAR-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-BEAR-STAND.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = (L-I(2) + L-I(1) * (L-I(3) - L-I(2))) / 6
     GOBACK.
 END PROGRAM EF5-BEAR-STAND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-BEAR-COUNTER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     IF L-I(2) NOT = 0
         COMPUTE L-O(1) = FUNCTION MIN(6, L-I(1) + 1)
     ELSE
         COMPUTE L-O(1) = FUNCTION MAX(0, L-I(1) - 1)
     END-IF
     GOBACK.
 END PROGRAM EF5-BEAR-COUNTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-BEAR-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     MOVE "textures/entity/bear/polarbear.png" TO L-PATH
     IF L-I(1) NOT = 0
         MOVE "textures/entity/bear/polarbear_baby.png" TO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EF5-BEAR-TEXTURE.
