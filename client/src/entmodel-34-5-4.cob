*> Entity models part 5 section 4 (Fox): the meshes of fox and fox_baby (4.1), setupAnim (4.2), the FOX_BABY_WALK keyframes (15.1, as rows), texture, body transform and counters (4.3), the held item layer (4.4).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF5-FOX-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 walk position, 4 walk speed, 5 ageScale, 6 ageInTicks, 7 crouchAmount, 8 head roll angle, 9 crouching, 10 sleeping, 11 sitting, 12 faceplanted, 13 pouncing, 14 baby model,
*>   15 legMotionPos (in and out: the model's persistent counter, +0.67 for every frame that runs the faceplanted step)): reset first; EF5-FOX-TEXTURE IN(variant 0 red 1 snow other, sleeping, baby) path(out X(120));
*>   EF5-FOX-BODY IN(pouncing, faceplanted, xRot) OUT(count 0 or 1, rotate about X in degrees); EF5-FOX-HEADROLL IN(partial, old, new) OUT(lerp x 0.11 pi); EF5-FOX-TICK IN(interested angle, interested flag, crouchAmount, crouching)
*>   OUT(old angle, angle, old crouch amount, crouch amount); EF5-FOX-ITEM-OPS IN(baby, sleeping, head x, y, z, head roll angle radians, yRot deg, xRot deg, item empty) OUT(count, then code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg
*>   5 rotate Z radians 6 rotate X deg and three values each). Keyframes: EF5F-ANIM-DEF ordinal(1 FOX_BABY_WALK) EM5-DEF ok(out), EF5F-ANIM-NAME, EF5F-ANIM-INFO IN(ordinal) OUT(length, looping, channels), EF5F-ANIM-BONE, EF5F-ANIM-EVAL IN(ordinal,
*>   channel, t seconds, scale) OUT(x y z), EF5F-ANIM-APPLY EMM-MODEL ordinal ms scale ok(out) (the authoring conversions of 34-1 5.1).


 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-M-FOX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P head root -1 16.5 -3 0 0 0".
    05 FILLER PIC X(100) VALUE "C head 1 5 -3 -2 -5 8 6 6 0 0".
    05 FILLER PIC X(100) VALUE "P right_ear head 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_ear 8 1 -3 -4 -4 2 2 1 0 0".
    05 FILLER PIC X(100) VALUE "P left_ear head 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_ear 15 1 3 -4 -4 2 2 1 0 0".
    05 FILLER PIC X(100) VALUE "P nose head 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C nose 6 18 -1 2.01 -8 4 2 3 0 0".
    05 FILLER PIC X(100) VALUE "P body root 0 16 -6 1.5707964 0 0".
    05 FILLER PIC X(100) VALUE "C body 24 15 -3 3.999 -3.5 6 11 6 0 0".
    05 FILLER PIC X(100) VALUE "P right_hind_leg root -5 17.5 7 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_hind_leg 13 24 2 0.5 -1 2 6 2 0.001 0".
    05 FILLER PIC X(100) VALUE "P left_hind_leg root -1 17.5 7 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_hind_leg 4 24 2 0.5 -1 2 6 2 0.001 0".
    05 FILLER PIC X(100) VALUE "P right_front_leg root -5 17.5 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_front_leg 13 24 2 0.5 -1 2 6 2 0.001 0".
    05 FILLER PIC X(100) VALUE "P left_front_leg root -1 17.5 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_front_leg 4 24 2 0.5 -1 2 6 2 0.001 0".
    05 FILLER PIC X(100) VALUE "P tail body -4 15 -1 -0.05235988 0 0".
    05 FILLER PIC X(100) VALUE "C tail 30 0 2 0 -1 4 9 5 0 0".
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
     MOVE 48 TO MM-TEXW
     MOVE 32 TO MM-TEXH
     GOBACK.
 END PROGRAM EF5-M-FOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-M-FOX-BABY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P head root 0 18.125 0.125 0 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 0 -3 -2.125 -5.125 6 5 5 0 0".
    05 FILLER PIC X(100) VALUE "C head 18 20 -1 0.875 -7.125 2 2 2 0 0".
    05 FILLER PIC X(100) VALUE "C head 22 8 -3 -4.125 -4.125 2 2 1 0 0".
    05 FILLER PIC X(100) VALUE "C head 22 11 1 -4.125 -4.125 2 2 1 0 0".
    05 FILLER PIC X(100) VALUE "P right_hind_leg root -1.5 22 4 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_hind_leg 22 4 -1 0 -1 2 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P left_hind_leg root 1.5 22 4 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_hind_leg 22 0 -1 0 -1 2 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P right_front_leg root -1.5 22 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C right_front_leg 22 4 -1 0 -1 2 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P left_front_leg root 1.5 22 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C left_front_leg 22 0 -1 0 -1 2 2 2 0 0".
    05 FILLER PIC X(100) VALUE "P body root 0 20 2 0 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 10 -2.5 -2 -3 5 4 6 0 0".
    05 FILLER PIC X(100) VALUE "P tail body 0 -0.5 3 0 0 0".
    05 FILLER PIC X(100) VALUE "C tail 0 20 -1.5 -1.48 -1 3 3 6 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 63 TIMES.
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.
 01 WS-N                   BINARY-LONG VALUE 17.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO
     MOVE 32 TO MM-TEXW
     MOVE 32 TO MM-TEXH
     GOBACK.
 END PROGRAM EF5-M-FOX-BABY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-FOX-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-B                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-RH                  BINARY-LONG.
 01 WS-LH                  BINARY-LONG.
 01 WS-RF                  BINARY-LONG.
 01 WS-LF                  BINARY-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-M                   FLOAT-LONG.
 01 WS-WP                  FLOAT-LONG.
 01 WS-WS                  FLOAT-LONG.
 01 WS-TF                  FLOAT-LONG VALUE 1.
 01 WS-SF                  FLOAT-LONG VALUE 2.5.
 01 WS-MS                  BINARY-LONG.
 01 WS-SCALE               FLOAT-LONG.
 01 WS-ORD                 BINARY-LONG VALUE 1.
 01 WS-OK                  BINARY-LONG.
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
     MOVE "tail" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-T
     MOVE "right_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RH
     MOVE "left_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LH
     MOVE "right_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RF
     MOVE "left_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LF
     MOVE L-I(5) TO WS-A
     MOVE L-I(7) TO WS-C
     MOVE L-I(8) TO MM-CZROT(WS-H)
     MOVE 1 TO MM-VISIBLE(WS-RH) MM-VISIBLE(WS-LH) MM-VISIBLE(WS-RF) MM-VISIBLE(WS-LF)
     IF L-I(14) = 0
         COMPUTE MM-CXROT(WS-RH) = FUNCTION COS(0.6662 * L-I(3)) * 1.4 * L-I(4)
         COMPUTE MM-CXROT(WS-LH) = FUNCTION COS(0.6662 * L-I(3) + 3.141592653589793) * 1.4 * L-I(4)
         COMPUTE MM-CXROT(WS-RF) = FUNCTION COS(0.6662 * L-I(3) + 3.141592653589793) * 1.4 * L-I(4)
         COMPUTE MM-CXROT(WS-LF) = FUNCTION COS(0.6662 * L-I(3)) * 1.4 * L-I(4)
     ELSE
         MOVE L-I(3) TO WS-WP
         MOVE L-I(4) TO WS-WS
         CALL "EM5-WALK-TIME" USING WS-WP WS-WS WS-TF WS-SF WS-MS WS-SCALE
         CALL "EF5F-ANIM-APPLY" USING EMM-MODEL WS-ORD WS-MS WS-SCALE WS-OK
     END-IF
     IF L-I(9) NOT = 0
         COMPUTE MM-CXROT(WS-B) = MM-CXROT(WS-B) + 0.10471976
         COMPUTE MM-CY(WS-H) = MM-CY(WS-H) + WS-C * WS-A
         COMPUTE WS-W = FUNCTION COS(L-I(6)) * 0.05
         MOVE WS-W TO MM-CYROT(WS-B) MM-CZROT(WS-RH) MM-CZROT(WS-LH)
         COMPUTE MM-CZROT(WS-RF) = WS-W / 2
         COMPUTE MM-CZROT(WS-LF) = WS-W / 2
         IF L-I(14) = 0
             COMPUTE MM-CY(WS-B) = MM-CY(WS-B) + WS-C
         ELSE
             COMPUTE MM-CY(WS-B) = MM-CY(WS-B) + WS-C / 6
         END-IF
     ELSE
         IF L-I(10) NOT = 0
             MOVE 0 TO MM-VISIBLE(WS-RH) MM-VISIBLE(WS-LH) MM-VISIBLE(WS-RF) MM-VISIBLE(WS-LF)
             IF L-I(14) = 0
                 MOVE -1.5707964 TO MM-CZROT(WS-B)
                 COMPUTE MM-CY(WS-B) = MM-CY(WS-B) + 5
                 MOVE -2.6179938 TO MM-CXROT(WS-T)
                 COMPUTE MM-CX(WS-H) = MM-CX(WS-H) + 2
                 COMPUTE MM-CY(WS-H) = MM-CY(WS-H) + 2.99
                 MOVE -2.0943952 TO MM-CYROT(WS-H)
                 MOVE 0 TO MM-CZROT(WS-H)
             ELSE
                 MOVE -1.5707964 TO MM-CZROT(WS-B)
                 MOVE -0.17453292 TO MM-CXROT(WS-B)
                 COMPUTE MM-CY(WS-B) = MM-CY(WS-B) + 1.5
                 COMPUTE MM-CZ(WS-B) = MM-CZ(WS-B) - 1.5
                 COMPUTE MM-CX(WS-B) = MM-CX(WS-B) - 1.5
                 MOVE -2.1816616 TO MM-CXROT(WS-T)
                 COMPUTE MM-CX(WS-T) = MM-CX(WS-T) - 0.7
                 COMPUTE MM-CZ(WS-T) = MM-CZ(WS-T) + 0.6
                 COMPUTE MM-CY(WS-T) = MM-CY(WS-T) + 0.9
                 COMPUTE MM-CX(WS-H) = MM-CX(WS-H) - 2
                 COMPUTE MM-CY(WS-H) = MM-CY(WS-H) + 2.8
                 COMPUTE MM-CZ(WS-H) = MM-CZ(WS-H) - 4
                 MOVE -2.0943952 TO MM-CYROT(WS-H)
                 MOVE 0 TO MM-CZROT(WS-H)
             END-IF
         ELSE
             IF L-I(11) NOT = 0
                 MOVE 0 TO MM-CXROT(WS-H) MM-CYROT(WS-H)
                 IF L-I(14) = 0
                     MOVE 0.5235988 TO MM-CXROT(WS-B)
                     COMPUTE MM-CY(WS-B) = MM-CY(WS-B) - 7
                     COMPUTE MM-CZ(WS-B) = MM-CZ(WS-B) + 3
                     MOVE 0.7853982 TO MM-CXROT(WS-T)
                     COMPUTE MM-CY(WS-H) = MM-CY(WS-H) - 6.5
                     COMPUTE MM-CZ(WS-H) = MM-CZ(WS-H) + 2.75
                     MOVE -0.2617994 TO MM-CXROT(WS-RF) MM-CXROT(WS-LF)
                     MOVE -1.3089969 TO MM-CXROT(WS-RH) MM-CXROT(WS-LH)
                     COMPUTE MM-CY(WS-RH) = MM-CY(WS-RH) + 4
                     COMPUTE MM-CZ(WS-RH) = MM-CZ(WS-RH) - 0.25
                     COMPUTE MM-CY(WS-LH) = MM-CY(WS-LH) + 4
                     COMPUTE MM-CZ(WS-LH) = MM-CZ(WS-LH) - 0.25
                     COMPUTE MM-CZ(WS-T) = MM-CZ(WS-T) - 1
                 ELSE
                     MOVE -0.959931 TO MM-CXROT(WS-B)
                     COMPUTE MM-CZ(WS-B) = MM-CZ(WS-B) - 4.5 * WS-A
                     COMPUTE MM-CY(WS-B) = MM-CY(WS-B) + 3 * WS-A
                     COMPUTE MM-CY(WS-T) = MM-CY(WS-T) - 0.6
                     COMPUTE MM-CZ(WS-T) = MM-CZ(WS-T) - 2 * WS-A
                     MOVE 0.95993114 TO MM-CXROT(WS-T)
                     COMPUTE MM-CY(WS-H) = MM-CY(WS-H) - 0.75
                     MOVE -0.2617994 TO MM-CXROT(WS-RF) MM-CXROT(WS-LF)
                     COMPUTE MM-CZ(WS-RF) = MM-CZ(WS-RF) - 1.5
                     COMPUTE MM-CZ(WS-LF) = MM-CZ(WS-LF) - 1.5
                     COMPUTE MM-CX(WS-RF) = MM-CX(WS-RF) + 0.01
                     COMPUTE MM-CX(WS-LF) = MM-CX(WS-LF) - 0.01
                     COMPUTE MM-CZ(WS-RH) = MM-CZ(WS-RH) - 3.75
                     COMPUTE MM-CZ(WS-LH) = MM-CZ(WS-LH) - 3.75
                     COMPUTE MM-CX(WS-RH) = MM-CX(WS-RH) + 0.01
                     COMPUTE MM-CX(WS-LH) = MM-CX(WS-LH) - 0.01
                 END-IF
             END-IF
         END-IF
     END-IF
     IF L-I(13) NOT = 0 AND L-I(14) = 0
         COMPUTE MM-CY(WS-B) = MM-CY(WS-B) - WS-C / 2
         COMPUTE MM-CY(WS-H) = MM-CY(WS-H) - WS-C / 2
     END-IF
     IF L-I(10) = 0 AND L-I(12) = 0 AND L-I(9) = 0
         COMPUTE MM-CXROT(WS-H) = L-I(1) * 0.017453292
         COMPUTE MM-CYROT(WS-H) = L-I(2) * 0.017453292
     END-IF
     IF L-I(10) NOT = 0
         MOVE 0 TO MM-CXROT(WS-H)
         MOVE -2.0943952 TO MM-CYROT(WS-H)
         COMPUTE MM-CZROT(WS-H) = FUNCTION COS(0.027 * L-I(6)) / 22
     END-IF
     IF L-I(12) NOT = 0
         COMPUTE L-I(15) = L-I(15) + 0.67
         MOVE L-I(15) TO WS-M
         COMPUTE MM-CXROT(WS-RH) = FUNCTION COS(0.4662 * WS-M) * 0.1
         COMPUTE MM-CXROT(WS-LH) = FUNCTION COS(0.4662 * WS-M + 3.141592653589793) * 0.1
         COMPUTE MM-CXROT(WS-RF) = FUNCTION COS(0.4662 * WS-M + 3.141592653589793) * 0.1
         COMPUTE MM-CXROT(WS-LF) = FUNCTION COS(0.4662 * WS-M) * 0.1
     END-IF
     GOBACK.
 END PROGRAM EF5-FOX-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-FOX-TEXTURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(40).
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     MOVE "fox" TO WS-NAME
     IF L-I(1) = 0 OR L-I(1) = 1
         IF L-I(1) = 1
             MOVE "fox_snow" TO WS-NAME
         END-IF
         IF L-I(2) NOT = 0
             IF L-I(1) = 1
                 STRING FUNCTION TRIM(WS-NAME) "_sleep" DELIMITED BY SIZE INTO WS-NAME
             ELSE
                 MOVE "fox_sleep" TO WS-NAME
             END-IF
         END-IF
         IF L-I(3) NOT = 0
             STRING FUNCTION TRIM(WS-NAME) "_baby" DELIMITED BY SIZE INTO WS-NAME
         END-IF
     END-IF
     MOVE SPACES TO L-PATH
     STRING "textures/entity/fox/" FUNCTION TRIM(WS-NAME) ".png" DELIMITED BY SIZE INTO L-PATH
     GOBACK.
 END PROGRAM EF5-FOX-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-FOX-BODY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1) L-O(2)
     IF L-I(1) NOT = 0 OR L-I(2) NOT = 0
         MOVE 1 TO L-O(1)
         COMPUTE L-O(2) = 0 - L-I(3)
     END-IF
     GOBACK.
 END PROGRAM EF5-FOX-BODY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-FOX-HEADROLL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = (L-I(2) + L-I(1) * (L-I(3) - L-I(2))) * 0.11 * 3.141592653589793
     GOBACK.
 END PROGRAM EF5-FOX-HEADROLL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-FOX-TICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO L-O(1)
     MOVE L-I(3) TO L-O(3)
     IF L-I(2) NOT = 0
         COMPUTE L-O(2) = L-I(1) + 0.4 * (1 - L-I(1))
     ELSE
         COMPUTE L-O(2) = L-I(1) + 0.4 * (0 - L-I(1))
     END-IF
     MOVE 0 TO L-O(4)
     IF L-I(4) NOT = 0
         COMPUTE L-O(4) = FUNCTION MIN(5, L-I(3) + 0.2)
     END-IF
     GOBACK.
 END PROGRAM EF5-FOX-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-FOX-ITEM-OPS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1) WS-N
     IF L-I(9) NOT = 0
         GOBACK
     END-IF
     ADD 1 TO WS-N
     MOVE 1 TO L-O(WS-N * 4 - 2)
     COMPUTE L-O(WS-N * 4 - 1) = L-I(3) / 16
     COMPUTE L-O(WS-N * 4) = L-I(4) / 16
     COMPUTE L-O(WS-N * 4 + 1) = L-I(5) / 16
     IF L-I(1) NOT = 0
         ADD 1 TO WS-N
         MOVE 2 TO L-O(WS-N * 4 - 2)
         MOVE 0.75 TO L-O(WS-N * 4 - 1) L-O(WS-N * 4) L-O(WS-N * 4 + 1)
     END-IF
     ADD 1 TO WS-N
     MOVE 5 TO L-O(WS-N * 4 - 2)
     MOVE L-I(6) TO L-O(WS-N * 4 - 1)
     MOVE 0 TO L-O(WS-N * 4) L-O(WS-N * 4 + 1)
     ADD 1 TO WS-N
     MOVE 3 TO L-O(WS-N * 4 - 2)
     MOVE L-I(7) TO L-O(WS-N * 4 - 1)
     MOVE 0 TO L-O(WS-N * 4) L-O(WS-N * 4 + 1)
     ADD 1 TO WS-N
     MOVE 6 TO L-O(WS-N * 4 - 2)
     MOVE L-I(8) TO L-O(WS-N * 4 - 1)
     MOVE 0 TO L-O(WS-N * 4) L-O(WS-N * 4 + 1)
     IF L-I(1) = 0
         IF L-I(2) = 0
             MOVE 0.06 TO WS-X
             MOVE 0.27 TO WS-Y
             MOVE -0.5 TO WS-Z
         ELSE
             MOVE 0.46 TO WS-X
             MOVE 0.26 TO WS-Y
             MOVE 0.22 TO WS-Z
         END-IF
     ELSE
         IF L-I(2) = 0
             MOVE 0.06 TO WS-X
             MOVE 0.26 TO WS-Y
             MOVE -0.5 TO WS-Z
         ELSE
             MOVE 0.4 TO WS-X
             MOVE 0.26 TO WS-Y
             MOVE 0.15 TO WS-Z
         END-IF
     END-IF
     ADD 1 TO WS-N
     MOVE 1 TO L-O(WS-N * 4 - 2)
     MOVE WS-X TO L-O(WS-N * 4 - 1)
     MOVE WS-Y TO L-O(WS-N * 4)
     MOVE WS-Z TO L-O(WS-N * 4 + 1)
     ADD 1 TO WS-N
     MOVE 6 TO L-O(WS-N * 4 - 2)
     MOVE 90 TO L-O(WS-N * 4 - 1)
     MOVE 0 TO L-O(WS-N * 4) L-O(WS-N * 4 + 1)
     IF L-I(2) NOT = 0
         ADD 1 TO WS-N
         MOVE 4 TO L-O(WS-N * 4 - 2)
         MOVE 90 TO L-O(WS-N * 4 - 1)
         MOVE 0 TO L-O(WS-N * 4) L-O(WS-N * 4 + 1)
     END-IF
     MOVE WS-N TO L-O(1)
     GOBACK.
 END PROGRAM EF5-FOX-ITEM-OPS.



 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5F-ANIM-BUILD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(60) VALUE "A 1 0.5 1 18".
    05 FILLER PIC X(60) VALUE "H body 2 1".
    05 FILLER PIC X(60) VALUE "K 0 0 0 0 1".
    05 FILLER PIC X(60) VALUE "H body 1 1".
    05 FILLER PIC X(60) VALUE "K 0 0 0 0 1".
    05 FILLER PIC X(60) VALUE "H head 2 1".
    05 FILLER PIC X(60) VALUE "K 0 0 0 0 1".
    05 FILLER PIC X(60) VALUE "H head 1 1".
    05 FILLER PIC X(60) VALUE "K 0 0 -1.025 0 1".
    05 FILLER PIC X(60) VALUE "H right_hind_leg 2 3".
    05 FILLER PIC X(60) VALUE "K 0 -35.0 0 0 2".
    05 FILLER PIC X(60) VALUE "K 0.25 35.0 0 0 1".
    05 FILLER PIC X(60) VALUE "K 0.5 -35.0 0 0 2".
    05 FILLER PIC X(60) VALUE "H right_hind_leg 1 3".
    05 FILLER PIC X(60) VALUE "K 0 0.05 0.6 -0.02 1".
    05 FILLER PIC X(60) VALUE "K 0.25 0.05 0.6 -0.02 1".
    05 FILLER PIC X(60) VALUE "K 0.5 0.05 0.6 -0.02 1".
    05 FILLER PIC X(60) VALUE "H right_hind_leg 3 1".
    05 FILLER PIC X(60) VALUE "K 0 1 1.15 1 1".
    05 FILLER PIC X(60) VALUE "H left_hind_leg 2 3".
    05 FILLER PIC X(60) VALUE "K 0 35.0 0 0 2".
    05 FILLER PIC X(60) VALUE "K 0.25 -35.0 0 0 1".
    05 FILLER PIC X(60) VALUE "K 0.5 35.0 0 0 2".
    05 FILLER PIC X(60) VALUE "H left_hind_leg 1 3".
    05 FILLER PIC X(60) VALUE "K 0 -0.05 0.6 -0.02 1".
    05 FILLER PIC X(60) VALUE "K 0.25 -0.05 0.6 -0.02 1".
    05 FILLER PIC X(60) VALUE "K 0.5 -0.05 0.6 -0.02 1".
    05 FILLER PIC X(60) VALUE "H left_hind_leg 3 1".
    05 FILLER PIC X(60) VALUE "K 0 1 1.15 1 1".
    05 FILLER PIC X(60) VALUE "H right_front_leg 2 3".
    05 FILLER PIC X(60) VALUE "K 0 35.0 0 0 2".
    05 FILLER PIC X(60) VALUE "K 0.25 -35.0 0 0 1".
    05 FILLER PIC X(60) VALUE "K 0.5 35.0 0 0 2".
    05 FILLER PIC X(60) VALUE "H right_front_leg 1 1".
    05 FILLER PIC X(60) VALUE "K 0 0.05 0.6 -0.4 1".
    05 FILLER PIC X(60) VALUE "H right_front_leg 3 1".
    05 FILLER PIC X(60) VALUE "K 0 1 1.15 1 1".
    05 FILLER PIC X(60) VALUE "H left_front_leg 2 3".
    05 FILLER PIC X(60) VALUE "K 0 -35.0 0 0 2".
    05 FILLER PIC X(60) VALUE "K 0.25 35.0 0 0 1".
    05 FILLER PIC X(60) VALUE "K 0.5 -35.0 0 0 2".
    05 FILLER PIC X(60) VALUE "H left_front_leg 1 1".
    05 FILLER PIC X(60) VALUE "K 0 -0.05 0.6 -0.4 1".
    05 FILLER PIC X(60) VALUE "H left_front_leg 3 1".
    05 FILLER PIC X(60) VALUE "K 0 1 1.15 1 1".
    05 FILLER PIC X(60) VALUE "H tail 2 1".
    05 FILLER PIC X(60) VALUE "K 0 -2.5 0 0 2".
    05 FILLER PIC X(60) VALUE "H tail 1 1".
    05 FILLER PIC X(60) VALUE "K 0 0 -0.05 0 2".
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(60) OCCURS 49 TIMES.
 01 WS-N                   BINARY-LONG VALUE 49.
 01 WS-I                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-GO                  BINARY-LONG.
 01 WS-TOK                 PIC X(24) OCCURS 7 TIMES.
 01 WS-NUM                 FLOAT-LONG OCCURS 7 TIMES.
 LINKAGE SECTION.
 01 L-ORD                  BINARY-LONG.
 COPY CLEM5.
 01 L-OK                   BINARY-LONG.
*> USING ordinal EM5-DEF ok: builds the definition of the ordinal from the rows (ok 0 when the ordinal is not one of the animations).
 PROCEDURE DIVISION USING L-ORD EM5-DEF L-OK.
     MOVE 0 TO L-OK AD-CHANNELS AD-LOOP WS-GO WS-C
     MOVE 0 TO AD-LENGTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         PERFORM PARSE-ROW
         EVALUATE WS-TOK(1)(1:1)
             WHEN "A"
                 MOVE 0 TO WS-GO
                 IF WS-NUM(2) = L-ORD
                     MOVE 1 TO WS-GO
                     MOVE 1 TO L-OK
                     MOVE WS-NUM(3) TO AD-LENGTH
                     MOVE WS-NUM(4) TO AD-LOOP
                 END-IF
             WHEN "H"
                 IF WS-GO = 1
                     ADD 1 TO WS-C
                     MOVE WS-C TO AD-CHANNELS
                     MOVE WS-TOK(2) TO AC-BONE(WS-C)
                     MOVE WS-NUM(3) TO AC-TARGET(WS-C)
                     MOVE 0 TO AC-KEYS(WS-C)
                 END-IF
             WHEN OTHER
                 IF WS-GO = 1
                     PERFORM ADD-KEY
                 END-IF
         END-EVALUATE
     END-PERFORM
     GO TO PROGRAM-DONE.

 PARSE-ROW.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 7
         MOVE SPACES TO WS-TOK(WS-K)
         MOVE 0 TO WS-NUM(WS-K)
     END-PERFORM
     UNSTRING WS-ROW(WS-I) DELIMITED BY ALL SPACE INTO WS-TOK(1) WS-TOK(2) WS-TOK(3) WS-TOK(4) WS-TOK(5) WS-TOK(6) WS-TOK(7)
     PERFORM VARYING WS-K FROM 2 BY 1 UNTIL WS-K > 7
         IF WS-TOK(WS-K) NOT = SPACES AND WS-TOK(WS-K)(1:1) NOT ALPHABETIC
             COMPUTE WS-NUM(WS-K) = FUNCTION NUMVAL(WS-TOK(WS-K))
         END-IF
     END-PERFORM.

 ADD-KEY.
     ADD 1 TO AC-KEYS(WS-C)
     MOVE AC-KEYS(WS-C) TO WS-K
     MOVE WS-NUM(2) TO AK-TS(WS-C, WS-K)
     EVALUATE AC-TARGET(WS-C)
         WHEN 1
             MOVE WS-NUM(3) TO AK-POST(WS-C, WS-K, 1)
             COMPUTE AK-POST(WS-C, WS-K, 2) = -WS-NUM(4)
             MOVE WS-NUM(5) TO AK-POST(WS-C, WS-K, 3)
         WHEN 2
             COMPUTE AK-POST(WS-C, WS-K, 1) = WS-NUM(3) * 0.017453292
             COMPUTE AK-POST(WS-C, WS-K, 2) = WS-NUM(4) * 0.017453292
             COMPUTE AK-POST(WS-C, WS-K, 3) = WS-NUM(5) * 0.017453292
         WHEN OTHER
             COMPUTE AK-POST(WS-C, WS-K, 1) = WS-NUM(3) - 1
             COMPUTE AK-POST(WS-C, WS-K, 2) = WS-NUM(4) - 1
             COMPUTE AK-POST(WS-C, WS-K, 3) = WS-NUM(5) - 1
     END-EVALUATE
     MOVE AK-POST(WS-C, WS-K, 1) TO AK-PRE(WS-C, WS-K, 1)
     MOVE AK-POST(WS-C, WS-K, 2) TO AK-PRE(WS-C, WS-K, 2)
     MOVE AK-POST(WS-C, WS-K, 3) TO AK-PRE(WS-C, WS-K, 3)
     COMPUTE AK-INTERP(WS-C, WS-K) = WS-NUM(6).

 PROGRAM-DONE.
     GOBACK.
 END PROGRAM EF5F-ANIM-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5F-ANIM-DEF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LOADED               BINARY-LONG VALUE 0.
 01 WS-I                    BINARY-LONG.
 01 WS-OK                   BINARY-LONG.
 01 WS-CACHE.
    05 WS-CE                PIC X(60000) OCCURS 1 TIMES.
 LINKAGE SECTION.
 01 L-ORD                  BINARY-LONG.
 COPY CLEM5.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ORD EM5-DEF L-OK.
     IF WS-LOADED = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1
             CALL "EF5F-ANIM-BUILD" USING WS-I EM5-DEF WS-OK
             MOVE EM5-DEF TO WS-CE(WS-I)
         END-PERFORM
         MOVE 1 TO WS-LOADED
     END-IF
     MOVE 0 TO L-OK
     IF L-ORD >= 1 AND L-ORD <= 1
         MOVE WS-CE(L-ORD) TO EM5-DEF
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM EF5F-ANIM-DEF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5F-ANIM-NAME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES.
    05 FILLER PIC X(48) VALUE "FOX_BABY_WALK".
    05 FILLER PIC X(48) VALUE SPACES.
 01 WS-NAMES-R REDEFINES WS-NAMES.
    05 WS-NAME              PIC X(48) OCCURS 2 TIMES.
 LINKAGE SECTION.
 01 L-ORD                  BINARY-LONG.
 01 L-NAME                 PIC X(48).
 PROCEDURE DIVISION USING L-ORD L-NAME.
     MOVE WS-NAME(2) TO L-NAME
     IF L-ORD >= 1 AND L-ORD <= 1
         MOVE WS-NAME(L-ORD) TO L-NAME
     END-IF
     GOBACK.
 END PROGRAM EF5F-ANIM-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5F-ANIM-INFO.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OK                   BINARY-LONG.
 COPY CLEM5.
 01 WS-ORD                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-ORD = L-I(1)
     CALL "EF5F-ANIM-DEF" USING WS-ORD EM5-DEF WS-OK
     MOVE AD-LENGTH TO L-O(1)
     MOVE AD-LOOP TO L-O(2)
     MOVE AD-CHANNELS TO L-O(3)
     GOBACK.
 END PROGRAM EF5F-ANIM-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5F-ANIM-BONE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OK                   BINARY-LONG.
 COPY CLEM5.
 LINKAGE SECTION.
 01 L-ORD                  BINARY-LONG.
 01 L-CH                   BINARY-LONG.
 01 L-BONE                 PIC X(24).
 01 L-TARGET               BINARY-LONG.
 01 L-KEYS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ORD L-CH L-BONE L-TARGET L-KEYS.
     CALL "EF5F-ANIM-DEF" USING L-ORD EM5-DEF WS-OK
     MOVE AC-BONE(L-CH) TO L-BONE
     MOVE AC-TARGET(L-CH) TO L-TARGET
     MOVE AC-KEYS(L-CH) TO L-KEYS
     GOBACK.
 END PROGRAM EF5F-ANIM-BONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5F-ANIM-EVAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OK                   BINARY-LONG.
 COPY CLEM5.
 01 WS-ORD                  BINARY-LONG.
 01 WS-CH                   BINARY-LONG.
 01 WS-T                    FLOAT-LONG.
 01 WS-SC                   FLOAT-LONG.
 01 WS-V.
    05 WS-VV                FLOAT-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-ORD = L-I(1)
     COMPUTE WS-CH = L-I(2)
     CALL "EF5F-ANIM-DEF" USING WS-ORD EM5-DEF WS-OK
     MOVE L-I(3) TO WS-T
     MOVE L-I(4) TO WS-SC
     CALL "EM5-EVAL-CHANNEL" USING EM5-DEF WS-CH WS-T WS-SC WS-V
     MOVE WS-VV(1) TO L-O(1)
     MOVE WS-VV(2) TO L-O(2)
     MOVE WS-VV(3) TO L-O(3)
     GOBACK.
 END PROGRAM EF5F-ANIM-EVAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5F-ANIM-APPLY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DOK                  BINARY-LONG.
 COPY CLEM5.
 COPY CLEM2.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-ORD                  BINARY-LONG.
 01 L-MS                   BINARY-LONG.
 01 L-SCALE                FLOAT-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING EMM-MODEL L-ORD L-MS L-SCALE L-OK.
     CALL "EF5F-ANIM-DEF" USING L-ORD EM5-DEF WS-DOK
     MOVE MM-COUNT TO MH-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MM-COUNT
         MOVE MM-NAME(WS-I) TO MH-NAME(WS-I)
         MOVE MM-PARENT(WS-I) TO MH-PARENT(WS-I)
         MOVE MM-NCUBES(WS-I) TO MH-CUBES(WS-I)
         MOVE MM-CUR(WS-I) TO MH-POSE(WS-I)
     END-PERFORM
     CALL "EM5-APPLY" USING EM2-MESH EM5-DEF L-MS L-SCALE L-OK
     IF L-OK NOT = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MM-COUNT
             MOVE MH-POSE(WS-I) TO MM-CUR(WS-I)
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM EF5F-ANIM-APPLY.
