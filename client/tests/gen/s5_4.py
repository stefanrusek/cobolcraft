from mesh5 import *
import kfgen,app5
IDS=['FOX','FOX_BABY']
AN=app5.parse('15.1')
hdr='''*> Entity models part 5 section 4 (Fox): the meshes of fox and fox_baby (4.1), setupAnim (4.2), the FOX_BABY_WALK keyframes (15.1, as rows), texture, body transform and counters (4.3), the held item layer (4.4).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF5-FOX-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 walk position, 4 walk speed, 5 ageScale, 6 ageInTicks, 7 crouchAmount, 8 head roll angle, 9 crouching, 10 sleeping, 11 sitting, 12 faceplanted, 13 pouncing, 14 baby model,
*>   15 legMotionPos (in and out: the model's persistent counter, +0.67 for every frame that runs the faceplanted step)): reset first; EF5-FOX-TEXTURE IN(variant 0 red 1 snow other, sleeping, baby) path(out X(120));
*>   EF5-FOX-BODY IN(pouncing, faceplanted, xRot) OUT(count 0 or 1, rotate about X in degrees); EF5-FOX-HEADROLL IN(partial, old, new) OUT(lerp x 0.11 pi); EF5-FOX-TICK IN(interested angle, interested flag, crouchAmount, crouching)
*>   OUT(old angle, angle, old crouch amount, crouch amount); EF5-FOX-ITEM-OPS IN(baby, sleeping, head x, y, z, head roll angle radians, yRot deg, xRot deg, item empty) OUT(count, then code 1 translate 2 scale 3 rotate Y deg 4 rotate Z deg
*>   5 rotate Z radians 6 rotate X deg and three values each). Keyframes: EF5F-ANIM-DEF ordinal(1 FOX_BABY_WALK) EM5-DEF ok(out), EF5F-ANIM-NAME, EF5F-ANIM-INFO IN(ordinal) OUT(length, looping, channels), EF5F-ANIM-BONE, EF5F-ANIM-EVAL IN(ordinal,
*>   channel, t seconds, scale) OUT(x y z), EF5F-ANIM-APPLY EMM-MODEL ordinal ms scale ok(out) (the authoring conversions of 34-1 5.1).
'''
kf=kfgen.gen('EF5F',['FOX_BABY_WALK'],AN,[''])
def mv(n,var): return '     MOVE "%s" TO WS-NAME\n     CALL "EMM-FIND" USING EMM-MODEL WS-NAME %s\n'%(n,var)
extra=r''' IDENTIFICATION DIVISION.
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
'''
for n,v in (('body','WS-B'),('head','WS-H'),('tail','WS-T'),('right_hind_leg','WS-RH'),('left_hind_leg','WS-LH'),('right_front_leg','WS-RF'),('left_front_leg','WS-LF')): extra+=mv(n,v)
extra+=r'''     MOVE L-I(5) TO WS-A
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
'''
write_section_src(4,hdr,IDS,extra+'\n'+kf); write_layers(IDS)
