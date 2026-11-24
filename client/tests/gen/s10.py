from mesh4 import *
import kfgen
from app4 import parse
IDS=['CAMEL','CAMEL_BABY','CAMEL_SADDLE','CAMEL_HUSK_SADDLE']
AD=parse('A.1'); BB=parse('A.2')
NAMES=[a['name'] for a in AD]+[a['name'] for a in BB]
hdr='''*> Entity models part 4 section 10 (Camel and camel husk): the meshes of camel, camel_baby and the saddle layers (10.3), textures and the model choice (10.1), setupAnim (10.2) and the keyframe data of Appendix A.1 and A.2 as rows.
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF4-CAMEL-TEXTURE IN(kind 0 camel 1 husk, baby) path(out X(120)); EF4-CAMEL-MODEL IN(kind, baby) layer(out X(32): the husk has only the adult model); EF4-CAMEL-JUMP IN(jumpCooldown, partial) OUT(max(cooldown - partial, 0));
*>   EF4-CAMEL-HEAD IN(yRot deg, xRot deg, jumpCooldown) OUT(head yRot rad, head xRot rad); EF4-CAMEL-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 walk position, 4 walk speed, 5 age in ticks, 6 jumpCooldown, 7 baby animations,
*>   8 is ridden, 9 saddle model, 10 to 14 the start ticks of the sit, sit pose, stand up, idle and dash states, -2147483648 when stopped): CamelModel.setupAnim.
*>   Animations (ordinals): 1 CAMEL_WALK, 2 SIT, 3 SIT_POSE, 4 STANDUP, 5 DASH, 6 IDLE, 7 CAMEL_BABY_WALK, 8 STANDUP, 9 DASH, 10 IDLE, 11 SIT, 12 SIT_POSE: EF4C-ANIM-DEF ordinal EM5-DEF ok(out), EF4C-ANIM-NAME ordinal name(X(48), out),
*>   EF4C-ANIM-INFO IN(ordinal) OUT(length, looping, channels), EF4C-ANIM-BONE ordinal channel bone target keys (out), EF4C-ANIM-EVAL IN(ordinal, channel, t seconds, scale) OUT(x y z), EF4C-ANIM-APPLY EMM-MODEL ordinal ms scale ok(out)
*>   (a looping animation of length 0 is not wrapped). Authoring conversions of 34-1 5.1: rotation degrees to radians, position y negated, scale factor minus 1.
'''
kf=kfgen.gen('EF4C',NAMES,AD+BB,[''])
kf=kf.replace('     CALL "EF4C-ANIM-DEF" USING L-ORD EM5-DEF WS-DOK\n','     CALL "EF4C-ANIM-DEF" USING L-ORD EM5-DEF WS-DOK\n     IF AD-LENGTH = 0\n         MOVE 0 TO AD-LOOP\n     END-IF\n')
assert 'MOVE 0 TO AD-LOOP' in kf
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-CAMEL-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     MOVE "textures/entity/camel/camel.png" TO L-PATH
     IF L-I(2) NOT = 0
         MOVE "textures/entity/camel/camel_baby.png" TO L-PATH
     END-IF
     IF L-I(1) NOT = 0
         MOVE "textures/entity/camel/camel_husk.png" TO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EF4-CAMEL-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-CAMEL-MODEL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-LAYER                PIC X(32).
 PROCEDURE DIVISION USING L-IN L-LAYER.
     MOVE "CAMEL" TO L-LAYER
     IF L-I(1) = 0 AND L-I(2) NOT = 0
         MOVE "CAMEL_BABY" TO L-LAYER
     END-IF
     GOBACK.
 END PROGRAM EF4-CAMEL-MODEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-CAMEL-JUMP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(1) - L-I(2)
     IF L-O(1) < 0
         MOVE 0 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EF4-CAMEL-JUMP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-CAMEL-HEAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO WS-YAW
     IF WS-YAW > 30
         MOVE 30 TO WS-YAW
     END-IF
     IF WS-YAW < -30
         MOVE -30 TO WS-YAW
     END-IF
     MOVE L-I(2) TO WS-PITCH
     IF WS-PITCH > 45
         MOVE 45 TO WS-PITCH
     END-IF
     IF WS-PITCH < -25
         MOVE -25 TO WS-PITCH
     END-IF
     IF L-I(3) > 0
         COMPUTE WS-PITCH = WS-PITCH + 45 * L-I(3) / 55
         IF WS-PITCH > 70
             MOVE 70 TO WS-PITCH
         END-IF
     END-IF
     COMPUTE L-O(1) = WS-YAW * 0.017453292
     COMPUTE L-O(2) = WS-PITCH * 0.017453292
     GOBACK.
 END PROGRAM EF4-CAMEL-HEAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-CAMEL-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HEAD                BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-P                   BINARY-LONG.
 01 WS-TF                  FLOAT-LONG VALUE 2.
 01 WS-SF                  FLOAT-LONG VALUE 2.5.
 01 WS-WALK-POS            FLOAT-LONG.
 01 WS-WALK-SPEED          FLOAT-LONG.
 01 WS-MS                  BINARY-LONG.
 01 WS-SCALE               FLOAT-LONG.
 01 WS-ORD                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ORDS.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              BINARY-LONG VALUE 6.
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE 11.
    05 FILLER              BINARY-LONG VALUE 12.
    05 FILLER              BINARY-LONG VALUE 8.
    05 FILLER              BINARY-LONG VALUE 10.
    05 FILLER              BINARY-LONG VALUE 9.
 01 WS-ORDS-R REDEFINES WS-ORDS.
    05 WS-O                BINARY-LONG OCCURS 10 TIMES.
 01 WS-H-IN.
    05 WS-HI               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-H-OUT.
    05 WS-HO               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-T-IN.
    05 WS-TI               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-T-OUT.
    05 WS-TO               FLOAT-LONG OCCURS 64 TIMES.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-HEAD
     MOVE L-I(2) TO WS-HI(1)
     MOVE L-I(1) TO WS-HI(2)
     MOVE L-I(6) TO WS-HI(3)
     CALL "EF4-CAMEL-HEAD" USING WS-H-IN WS-H-OUT
     MOVE WS-HO(1) TO MM-CYROT(WS-HEAD)
     MOVE WS-HO(2) TO MM-CXROT(WS-HEAD)
     MOVE L-I(3) TO WS-WALK-POS
     MOVE L-I(4) TO WS-WALK-SPEED
     CALL "EM5-WALK-TIME" USING WS-WALK-POS WS-WALK-SPEED WS-TF WS-SF WS-MS WS-SCALE
     MOVE 1 TO WS-ORD
     IF L-I(7) NOT = 0
         MOVE 7 TO WS-ORD
     END-IF
     CALL "EF4C-ANIM-APPLY" USING EMM-MODEL WS-ORD WS-MS WS-SCALE WS-OK
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 5
         MOVE L-I(5) TO WS-TI(1)
         MOVE L-I(9 + WS-K) TO WS-TI(2)
         MOVE 1 TO WS-TI(3)
         CALL "EM3-STATE-TIME" USING WS-T-IN WS-T-OUT
         IF WS-TO(2) NOT = 0
             IF L-I(7) NOT = 0
                 MOVE WS-O(5 + WS-K) TO WS-ORD
             ELSE
                 MOVE WS-O(WS-K) TO WS-ORD
             END-IF
             COMPUTE WS-MS = WS-TO(1)
             MOVE 1 TO WS-SCALE
             CALL "EF4C-ANIM-APPLY" USING EMM-MODEL WS-ORD WS-MS WS-SCALE WS-OK
         END-IF
     END-PERFORM
     IF L-I(9) NOT = 0
         MOVE "reins" TO WS-NAME
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
         MOVE 0 TO MM-VISIBLE(WS-P)
         IF L-I(8) NOT = 0
             MOVE 1 TO MM-VISIBLE(WS-P)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EF4-CAMEL-ANIM.
'''
write_section_src(10,hdr,IDS,extra+'\n'+kf); write_layers(IDS)
