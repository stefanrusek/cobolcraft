from mesh5 import *
IDS=['PANDA','PANDA_BABY']
hdr='''*> Entity models part 5 section 5 (Panda): the meshes of panda and panda_baby (5.1), setupAnim (5.2), body transform (5.3), textures, held item and counters (5.4).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF5-PANDA-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 walk position, 4 walk speed, 5 ageInTicks, 6 unhappy, 7 sneezing, 8 sneezeTime, 9 sitAmount, 10 eating, 11 scared, 12 lieOnBackAmount, 13 rollAmount, 14 baby model): the
*>   quadruped base then the steps of 5.2; EF5-PANDA-BODY IN(baby, rollTime, sitAmount, scared, ageInTicks, xRot, lieOnBackAmount) OUT(count, then code 1 translate 3 rotate Y deg 6 rotate X deg and three values each);
*>   EF5-PANDA-TEXTURE IN(gene 0 normal 1 lazy 2 worried 3 playful 4 brown 5 weak 6 aggressive, an unknown gene is normal; baby) path(out X(120)); EF5-PANDA-ITEM IN(item not empty, sitting, scared, eating, ageInTicks)
*>   OUT(drawn, translate x y z); EF5-PANDA-COUNTER IN(amount, flag) OUT(amount after one tick: +0.15 max 1 or -0.19 min 0).
'''
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-PANDA-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-B                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-RH                  BINARY-LONG.
 01 WS-LH                  BINARY-LONG.
 01 WS-RF                  BINARY-LONG.
 01 WS-LF                  BINARY-LONG.
 01 WS-Q                   FLOAT-LONG.
 01 WS-RI.
    05 WS-RV               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-RO.
    05 WS-ROV              FLOAT-LONG OCCURS 64 TIMES.
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
     MOVE "right_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RH
     MOVE "left_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LH
     MOVE "right_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RF
     MOVE "left_front_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LF
     IF L-I(6) NOT = 0
         COMPUTE MM-CYROT(WS-H) = 0.35 * FUNCTION SIN(0.6 * L-I(5))
         COMPUTE MM-CZROT(WS-H) = 0.35 * FUNCTION SIN(0.6 * L-I(5))
         COMPUTE MM-CXROT(WS-RF) = -0.75 * FUNCTION SIN(0.3 * L-I(5))
         COMPUTE MM-CXROT(WS-LF) = 0.75 * FUNCTION SIN(0.3 * L-I(5))
     ELSE
         MOVE 0 TO MM-CZROT(WS-H)
     END-IF
     IF L-I(7) NOT = 0
         IF L-I(8) < 15
             COMPUTE MM-CXROT(WS-H) = (-0.7853982 * L-I(8)) / 14
         ELSE
             IF L-I(8) < 20
                 COMPUTE WS-Q = FUNCTION INTEGER-PART((L-I(8) - 15) / 5)
                 COMPUTE MM-CXROT(WS-H) = -0.7853982 + 0.7853982 * WS-Q
             END-IF
         END-IF
     END-IF
     IF L-I(9) > 0
         IF L-I(14) = 0
             MOVE L-I(9) TO WS-RV(1)
             MOVE MM-CXROT(WS-B) TO WS-RV(2)
             MOVE 1.7407963 TO WS-RV(3)
             CALL "EF5-ROT-LERP-RAD" USING WS-RI WS-RO
             MOVE WS-ROV(1) TO MM-CXROT(WS-B)
             MOVE MM-CXROT(WS-H) TO WS-RV(2)
             MOVE 1.5707964 TO WS-RV(3)
             CALL "EF5-ROT-LERP-RAD" USING WS-RI WS-RO
             MOVE WS-ROV(1) TO MM-CXROT(WS-H)
         ELSE
             MOVE L-I(9) TO WS-RV(1)
             MOVE MM-CXROT(WS-B) TO WS-RV(2)
             MOVE 0.17453292 TO WS-RV(3)
             CALL "EF5-ROT-LERP-RAD" USING WS-RI WS-RO
             MOVE WS-ROV(1) TO MM-CXROT(WS-B)
             COMPUTE MM-CZ(WS-B) = MM-CZ(WS-B) + L-I(9) * (-1.5 - MM-CZ(WS-B))
             COMPUTE MM-CZ(WS-H) = MM-CZ(WS-H) + L-I(9) * (-11.5 - MM-CZ(WS-H))
             COMPUTE MM-CY(WS-H) = MM-CY(WS-H) + L-I(9) * (17.5 - MM-CY(WS-H))
             COMPUTE MM-CZ(WS-RF) = MM-CZ(WS-RF) + L-I(9) * (-5 - MM-CZ(WS-RF))
             COMPUTE MM-CZ(WS-LF) = MM-CZ(WS-LF) + L-I(9) * (-5 - MM-CZ(WS-LF))
             COMPUTE MM-CZ(WS-RH) = MM-CZ(WS-RH) + L-I(9) * (3 - MM-CZ(WS-RH))
             COMPUTE MM-CZ(WS-LH) = MM-CZ(WS-LH) + L-I(9) * (3 - MM-CZ(WS-LH))
         END-IF
         MOVE -0.27079642 TO MM-CZROT(WS-RF)
         MOVE 0.27079642 TO MM-CZROT(WS-LF)
         MOVE 0.5707964 TO MM-CZROT(WS-RH)
         MOVE -0.5707964 TO MM-CZROT(WS-LH)
         IF L-I(10) NOT = 0
             COMPUTE MM-CXROT(WS-H) = 1.5707964 + 0.2 * FUNCTION SIN(0.6 * L-I(5))
             COMPUTE MM-CXROT(WS-RF) = -0.4 - 0.2 * FUNCTION SIN(0.6 * L-I(5))
             MOVE MM-CXROT(WS-RF) TO MM-CXROT(WS-LF)
         END-IF
         IF L-I(11) NOT = 0
             MOVE 2.1707964 TO MM-CXROT(WS-H)
             MOVE -0.9 TO MM-CXROT(WS-RF) MM-CXROT(WS-LF)
         END-IF
     ELSE
         MOVE 0 TO MM-CZROT(WS-RH) MM-CZROT(WS-LH) MM-CZROT(WS-RF) MM-CZROT(WS-LF)
     END-IF
     IF L-I(12) > 0
         COMPUTE MM-CXROT(WS-RH) = -0.6 * FUNCTION SIN(0.15 * L-I(5))
         COMPUTE MM-CXROT(WS-LH) = 0.6 * FUNCTION SIN(0.15 * L-I(5))
         COMPUTE MM-CXROT(WS-RF) = 0.3 * FUNCTION SIN(0.25 * L-I(5))
         COMPUTE MM-CXROT(WS-LF) = -0.3 * FUNCTION SIN(0.25 * L-I(5))
         MOVE L-I(12) TO WS-RV(1)
         MOVE MM-CXROT(WS-H) TO WS-RV(2)
         MOVE 1.5707964 TO WS-RV(3)
         CALL "EF5-ROT-LERP-RAD" USING WS-RI WS-RO
         MOVE WS-ROV(1) TO MM-CXROT(WS-H)
     END-IF
     IF L-I(13) > 0
         MOVE L-I(13) TO WS-RV(1)
         MOVE MM-CXROT(WS-H) TO WS-RV(2)
         MOVE 2.0561945 TO WS-RV(3)
         CALL "EF5-ROT-LERP-RAD" USING WS-RI WS-RO
         MOVE WS-ROV(1) TO MM-CXROT(WS-H)
         COMPUTE MM-CXROT(WS-RH) = -0.5 * FUNCTION SIN(0.5 * L-I(5))
         COMPUTE MM-CXROT(WS-LH) = 0.5 * FUNCTION SIN(0.5 * L-I(5))
         COMPUTE MM-CXROT(WS-RF) = 0.5 * FUNCTION SIN(0.5 * L-I(5))
         COMPUTE MM-CXROT(WS-LF) = -0.5 * FUNCTION SIN(0.5 * L-I(5))
     END-IF
     GOBACK.
 END PROGRAM EF5-PANDA-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-PANDA-BODY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-A0                  FLOAT-LONG.
 01 WS-A1                  FLOAT-LONG.
 01 WS-LIM                 BINARY-LONG.
 01 WS-G                   FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-OP                  BINARY-LONG.
 01 WS-V1                  FLOAT-LONG.
 01 WS-V2                  FLOAT-LONG.
 01 WS-V3                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO WS-N
     MOVE 0.8 TO WS-H
     IF L-I(1) NOT = 0
         MOVE 0.3 TO WS-H
     END-IF
     IF L-I(2) > 0
         COMPUTE WS-K = FUNCTION INTEGER(L-I(2))
         COMPUTE WS-F = L-I(2) - WS-K
         EVALUATE TRUE
             WHEN WS-K <= 7
                 COMPUTE WS-A0 = 90 * WS-K / 7
                 COMPUTE WS-A1 = 90 * (WS-K + 1) / 7
                 MOVE 8 TO WS-LIM
             WHEN WS-K <= 15
                 COMPUTE WS-A0 = 90 + 90 * (WS-K - 8) / 7
                 COMPUTE WS-A1 = 90 + 90 * (WS-K + 1 - 8) / 7
                 MOVE 16 TO WS-LIM
             WHEN WS-K <= 23
                 COMPUTE WS-A0 = 180 + 90 * (WS-K - 16) / 7
                 COMPUTE WS-A1 = 180 + 90 * (WS-K + 1 - 16) / 7
                 MOVE 24 TO WS-LIM
             WHEN WS-K <= 31
                 COMPUTE WS-A0 = 270 + 90 * (WS-K - 24) / 7
                 COMPUTE WS-A1 = 270 + 90 * (WS-K + 1 - 24) / 7
                 MOVE 32 TO WS-LIM
             WHEN OTHER
                 MOVE 0 TO WS-LIM
         END-EVALUATE
         IF WS-LIM > 0
             IF WS-K + 1 < WS-LIM
                 COMPUTE WS-G = WS-A0 + WS-F * (WS-A1 - WS-A0)
             ELSE
                 MOVE WS-A0 TO WS-G
             END-IF
             EVALUATE TRUE
                 WHEN WS-K <= 7 COMPUTE WS-TY = (WS-H + 0.2) * (WS-G / 90)
                 WHEN WS-K <= 15 COMPUTE WS-TY = (WS-H + 0.2) + (WS-H - 0.2) * (WS-G - 90) / 90
                 WHEN WS-K <= 23 COMPUTE WS-TY = WS-H + WS-H * (270 - WS-G) / 90
                 WHEN OTHER COMPUTE WS-TY = WS-H * (360 - WS-G) / 90
             END-EVALUATE
             MOVE 1 TO WS-OP
             MOVE 0 TO WS-V1
             MOVE WS-TY TO WS-V2
             MOVE 0 TO WS-V3
             PERFORM ADD-OP
             MOVE 6 TO WS-OP
             COMPUTE WS-V1 = 0 - WS-G
             MOVE 0 TO WS-V2 WS-V3
             PERFORM ADD-OP
         END-IF
     END-IF
     IF L-I(3) > 0
         MOVE 1 TO WS-OP
         MOVE 0 TO WS-V1 WS-V3
         COMPUTE WS-V2 = 0.8 * L-I(3)
         PERFORM ADD-OP
         MOVE 6 TO WS-OP
         COMPUTE WS-V1 = L-I(6) + L-I(3) * 90
         MOVE 0 TO WS-V2 WS-V3
         PERFORM ADD-OP
         MOVE 1 TO WS-OP
         MOVE 0 TO WS-V1 WS-V3
         COMPUTE WS-V2 = -1.0 * L-I(3)
         PERFORM ADD-OP
         IF L-I(4) NOT = 0
             MOVE 3 TO WS-OP
             COMPUTE WS-V1 = FUNCTION COS(1.25 * L-I(5)) * 3.141592653589793 * 0.05
             MOVE 0 TO WS-V2 WS-V3
             PERFORM ADD-OP
             IF L-I(1) NOT = 0
                 MOVE 1 TO WS-OP
                 MOVE 0 TO WS-V1
                 MOVE 0.8 TO WS-V2
                 MOVE 0.55 TO WS-V3
                 PERFORM ADD-OP
             END-IF
         END-IF
     END-IF
     IF L-I(7) > 0
         MOVE 0.5 TO WS-C
         IF L-I(1) = 0
             MOVE 1.3 TO WS-C
         END-IF
         MOVE 1 TO WS-OP
         MOVE 0 TO WS-V1 WS-V3
         COMPUTE WS-V2 = WS-C * L-I(7)
         PERFORM ADD-OP
         MOVE 6 TO WS-OP
         COMPUTE WS-V1 = L-I(6) + L-I(7) * 180
         MOVE 0 TO WS-V2 WS-V3
         PERFORM ADD-OP
     END-IF
     MOVE WS-N TO L-O(1)
     GO TO PROGRAM-DONE.

 ADD-OP.
     ADD 1 TO WS-N
     MOVE WS-OP TO L-O(WS-N * 4 - 2)
     MOVE WS-V1 TO L-O(WS-N * 4 - 1)
     MOVE WS-V2 TO L-O(WS-N * 4)
     MOVE WS-V3 TO L-O(WS-N * 4 + 1).

 PROGRAM-DONE.
     GOBACK.
 END PROGRAM EF5-PANDA-BODY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-PANDA-TEXTURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ADULT.
    05 FILLER PIC X(20) VALUE "panda".
    05 FILLER PIC X(20) VALUE "panda_lazy".
    05 FILLER PIC X(20) VALUE "panda_worried".
    05 FILLER PIC X(20) VALUE "panda_playful".
    05 FILLER PIC X(20) VALUE "panda_brown".
    05 FILLER PIC X(20) VALUE "panda_weak".
    05 FILLER PIC X(20) VALUE "panda_aggressive".
 01 WS-ADULT-R REDEFINES WS-ADULT.
    05 WS-A                PIC X(20) OCCURS 7 TIMES.
 01 WS-BABY.
    05 FILLER PIC X(24) VALUE "panda_baby".
    05 FILLER PIC X(24) VALUE "lazy_panda_baby".
    05 FILLER PIC X(24) VALUE "worried_panda_baby".
    05 FILLER PIC X(24) VALUE "playful_panda_baby".
    05 FILLER PIC X(24) VALUE "brown_panda_baby".
    05 FILLER PIC X(24) VALUE "weak_panda_baby".
    05 FILLER PIC X(24) VALUE "aggressive_panda_baby".
 01 WS-BABY-R REDEFINES WS-BABY.
    05 WS-B                PIC X(24) OCCURS 7 TIMES.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     MOVE 1 TO WS-K
     IF L-I(1) >= 0 AND L-I(1) <= 6
         COMPUTE WS-K = L-I(1) + 1
     END-IF
     MOVE SPACES TO L-PATH
     IF L-I(2) NOT = 0
         STRING "textures/entity/panda/" FUNCTION TRIM(WS-B(WS-K)) ".png" DELIMITED BY SIZE INTO L-PATH
     ELSE
         STRING "textures/entity/panda/" FUNCTION TRIM(WS-A(WS-K)) ".png" DELIMITED BY SIZE INTO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EF5-PANDA-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-PANDA-ITEM.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1) L-O(2) L-O(3) L-O(4)
     IF L-I(1) NOT = 0 AND L-I(2) NOT = 0 AND L-I(3) = 0
         MOVE 1 TO L-O(1)
         MOVE 0.1 TO L-O(2)
         MOVE 1.4 TO L-O(3)
         MOVE -0.6 TO L-O(4)
         IF L-I(4) NOT = 0
             COMPUTE L-O(4) = -0.6 - (0.2 * FUNCTION SIN(0.6 * L-I(5)) + 0.2)
             COMPUTE L-O(3) = 1.4 - 0.09 * FUNCTION SIN(0.6 * L-I(5))
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EF5-PANDA-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-PANDA-COUNTER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     IF L-I(2) NOT = 0
         COMPUTE L-O(1) = FUNCTION MIN(1, L-I(1) + 0.15)
     ELSE
         COMPUTE L-O(1) = FUNCTION MAX(0, L-I(1) - 0.19)
     END-IF
     GOBACK.
 END PROGRAM EF5-PANDA-COUNTER.
'''
write_section_src(5,hdr,IDS,extra); write_layers(IDS)
