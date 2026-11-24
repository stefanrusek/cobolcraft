from mesh4 import *
import kfgen
from app4 import parse
IDS=['RABBIT','RABBIT_BABY']
AD=parse('A.3'); BB=parse('A.4')
NAMES=['RABBIT_HOP','RABBIT_IDLE_HEAD_TILT','RABBIT_BABY_HOP','RABBIT_BABY_IDLE_HEAD_TILT']
hdr='''*> Entity models part 4 section 12 (Rabbit): the meshes of rabbit and rabbit_baby (12.4), the variants and the texture rule (12.1, 12.3), setupAnim (12.2) and the keyframe data of Appendix A.3 and A.4 as rows.
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF4-RABBIT-VARIANT IN(id) OUT(ordinal 0 brown 1 white 2 black 3 white_splotched 4 gold 5 salt 6 caerbannog; the sparse id map has 99 for the last, unknown ids give brown);
*>   EF4-RABBIT-TEXTURE IN(is toast, baby, ordinal) path(out X(120)); EF4-RABBIT-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 age in ticks, 4 baby, 5 hop state start tick, 6 idle head tilt state start tick, -2147483648 when stopped).
*>   Animations (ordinals): 1 RABBIT_HOP, 2 RABBIT_IDLE_HEAD_TILT, 3 RABBIT_BABY_HOP, 4 RABBIT_BABY_IDLE_HEAD_TILT: EF4R-ANIM-DEF ordinal EM5-DEF ok(out), EF4R-ANIM-NAME ordinal name(X(48), out), EF4R-ANIM-INFO IN(ordinal) OUT(length, looping, channels),
*>   EF4R-ANIM-BONE ordinal channel bone target keys (out), EF4R-ANIM-EVAL IN(ordinal, channel, t seconds, scale) OUT(x y z), EF4R-ANIM-APPLY EMM-MODEL ordinal ms scale ok(out). Authoring conversions of 34-1 5.1.
'''
kf=kfgen.gen('EF4R',NAMES,AD+BB,[''])
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-RABBIT-VARIANT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) >= 1 AND L-I(1) <= 5
         MOVE L-I(1) TO L-O(1)
     END-IF
     IF L-I(1) = 99
         MOVE 6 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EF4-RABBIT-VARIANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-RABBIT-TEXTURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES.
    05 FILLER PIC X(16) VALUE "brown".
    05 FILLER PIC X(16) VALUE "white".
    05 FILLER PIC X(16) VALUE "black".
    05 FILLER PIC X(16) VALUE "white_splotched".
    05 FILLER PIC X(16) VALUE "gold".
    05 FILLER PIC X(16) VALUE "salt".
    05 FILLER PIC X(16) VALUE "caerbannog".
 01 WS-NAMES-R REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(16) OCCURS 7 TIMES.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     COMPUTE WS-K = L-I(3) + 1
     MOVE SPACES TO L-PATH
     IF L-I(1) NOT = 0
         IF L-I(2) NOT = 0
             MOVE "textures/entity/rabbit/rabbit_toast_baby.png" TO L-PATH
         ELSE
             MOVE "textures/entity/rabbit/rabbit_toast.png" TO L-PATH
         END-IF
     ELSE
         IF L-I(2) NOT = 0
             STRING "textures/entity/rabbit/rabbit_" FUNCTION TRIM(WS-NAME(WS-K)) "_baby.png" DELIMITED BY SIZE INTO L-PATH
         ELSE
             STRING "textures/entity/rabbit/rabbit_" FUNCTION TRIM(WS-NAME(WS-K)) ".png" DELIMITED BY SIZE INTO L-PATH
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EF4-RABBIT-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-RABBIT-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-HEAD                BINARY-LONG.
 01 WS-ORD                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-MS                  BINARY-LONG.
 01 WS-SCALE               FLOAT-LONG VALUE 1.
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
     IF L-I(6) = -2147483648
         MOVE "head" TO WS-NAME
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-HEAD
         COMPUTE MM-CYROT(WS-HEAD) = L-I(2) * 0.017453292
         COMPUTE MM-CXROT(WS-HEAD) = L-I(1) * 0.017453292
     END-IF
     MOVE L-I(3) TO WS-TI(1)
     MOVE L-I(5) TO WS-TI(2)
     MOVE 1 TO WS-TI(3)
     CALL "EM3-STATE-TIME" USING WS-T-IN WS-T-OUT
     IF WS-TO(2) NOT = 0
         MOVE 1 TO WS-ORD
         IF L-I(4) NOT = 0
             MOVE 3 TO WS-ORD
         END-IF
         COMPUTE WS-MS = WS-TO(1)
         CALL "EF4R-ANIM-APPLY" USING EMM-MODEL WS-ORD WS-MS WS-SCALE WS-OK
     END-IF
     MOVE L-I(3) TO WS-TI(1)
     MOVE L-I(6) TO WS-TI(2)
     CALL "EM3-STATE-TIME" USING WS-T-IN WS-T-OUT
     IF WS-TO(2) NOT = 0
         MOVE 2 TO WS-ORD
         IF L-I(4) NOT = 0
             MOVE 4 TO WS-ORD
         END-IF
         COMPUTE WS-MS = WS-TO(1)
         CALL "EF4R-ANIM-APPLY" USING EMM-MODEL WS-ORD WS-MS WS-SCALE WS-OK
     END-IF
     GOBACK.
 END PROGRAM EF4-RABBIT-ANIM.
'''
write_section_src(12,hdr,IDS,extra+'\n'+kf); write_layers(IDS)
