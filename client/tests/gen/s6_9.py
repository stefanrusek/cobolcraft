from breeze6 import *
import kfgen
define()
hdr='''*> Entity models part 6 section 9 (Breeze): the base mesh and the BREEZE, BREEZE_WIND and BREEZE_EYES layer models (9.1), setupAnim with the six BreezeAnimation definitions as rows (9.2, 9.5), the entity-side state changes (9.3), textures and the wind scroll (9.4).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF6-BREEZE-ANIM EMM-MODEL state(1 ageInTicks, 2 idle start tick, 3 shoot start, 4 slide start, 5 slide back start, 6 inhale start, 7 long jump start; -2147483648 is stopped): reset first, then idle, shoot, slide, slide back, inhale, jump when started;
*>   EF6-BREEZE-POSE-CHANGE IN(pose 0 other 1 SHOOTING 2 INHALING 3 SLIDING, tickCount, idle, shoot, slide, slide back, inhale, long jump starts) OUT(the six starts); EF6-BREEZE-TICK IN(sliding, long jumping, tickCount, the six starts) OUT(the six starts);
*>   EF6-BREEZE-TEXTURE IN(0 main 1 wind 2 eyes) path(out X(120)); EF6-BREEZE-WIND-U IN(ageInTicks) OUT(u, v) with u = (age x 0.02) mod 1. Layers: BREEZE, BREEZE_WIND, BREEZE_EYES through EF6-LAYER (EF6-RETAIN mode 2).
*>   Keyframes EF6B-ANIM-*: ordinals 1 IDLE 2 SHOOT 3 JUMP 4 INHALE 5 SLIDE 6 SLIDE_BACK; -DEF ordinal EM5-DEF ok(out), -NAME, -INFO IN(ordinal) OUT(length, looping, channels), -BONE, -EVAL IN(ordinal, channel, t, scale) OUT(x y z), -APPLY EMM-MODEL ordinal ms scale ok(out).
'''
kf=kfgen.gen('EF6B',NM,AN,[''])
def blk(nm,start):
    return '''     IF L-I(%d) NOT = -2147483648
         MOVE L-I(%d) TO WS-START
         MOVE L-I(1) TO WS-AV(1)
         CALL "EM5-STATE" USING WS-OP WS-START WS-A WS-R
         MOVE WS-R TO WS-MS
         MOVE %d TO WS-ORD
         CALL "EF6B-ANIM-APPLY" USING EMM-MODEL WS-ORD WS-MS WS-ONE WS-OK
     END-IF
'''%(start,start,NM.index(nm)+1)
def prog(name,body,ws=''):
    s=' IDENTIFICATION DIVISION.\n PROGRAM-ID. %s.\n DATA DIVISION.\n'%name
    if ws: s+=' WORKING-STORAGE SECTION.\n'+ws
    s+=' LINKAGE SECTION.\n 01 L-IN.\n    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.\n 01 L-OUT.\n    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.\n PROCEDURE DIVISION USING L-IN L-OUT.\n'+body+'     GOBACK.\n END PROGRAM %s.\n\n'%name
    return s
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-BREEZE-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OP                  BINARY-LONG VALUE 6.
 01 WS-START               BINARY-LONG.
 01 WS-A.
    05 WS-AV               FLOAT-LONG OCCURS 4 TIMES.
 01 WS-R                   FLOAT-LONG.
 01 WS-MS                  BINARY-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-ORD                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
'''
for nm,st in (('IDLE',2),('SHOOT',3),('SLIDE',5),('SLIDE_BACK',6),('INHALE',4),('JUMP',7)):
    pass
# application order idle, shoot, slide, slide back, inhale, jump; state slots 2..7 in that order
for nm,slot in (('IDLE',2),('SHOOT',3),('SLIDE',4),('SLIDE_BACK',5),('INHALE',6),('JUMP',7)): extra+=blk(nm,slot)
extra+=r'''     GOBACK.
 END PROGRAM EF6-BREEZE-ANIM.

'''
extra+=prog('EF6-BREEZE-POSE-CHANGE','''     MOVE -2147483648 TO L-O(1) L-O(2) L-O(5) L-O(6)
     MOVE L-I(5) TO L-O(3)
     MOVE L-I(6) TO L-O(4)
     EVALUATE L-I(1)
         WHEN 1
             MOVE L-I(2) TO L-O(2)
         WHEN 2
             MOVE L-I(2) TO L-O(5)
         WHEN 3
             IF L-O(3) = -2147483648
                 MOVE L-I(2) TO L-O(3)
             END-IF
     END-EVALUATE
''')
extra+=prog('EF6-BREEZE-TICK','''     MOVE L-I(4) TO L-O(1)
     MOVE L-I(5) TO L-O(2)
     MOVE L-I(6) TO L-O(3)
     MOVE L-I(7) TO L-O(4)
     MOVE L-I(8) TO L-O(5)
     MOVE L-I(9) TO L-O(6)
     IF L-I(2) NOT = 0 AND L-O(6) = -2147483648
         MOVE L-I(3) TO L-O(6)
     END-IF
     IF L-O(1) = -2147483648
         MOVE L-I(3) TO L-O(1)
     END-IF
     IF L-I(1) = 0 AND L-O(3) NOT = -2147483648
         MOVE L-I(3) TO L-O(4)
         MOVE -2147483648 TO L-O(3)
     END-IF
''')
extra+=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-BREEZE-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     EVALUATE L-I(1)
         WHEN 1
             MOVE "textures/entity/breeze/breeze_wind.png" TO L-PATH
         WHEN 2
             MOVE "textures/entity/breeze/breeze_eyes.png" TO L-PATH
         WHEN OTHER
             MOVE "textures/entity/breeze/breeze.png" TO L-PATH
     END-EVALUATE
     GOBACK.
 END PROGRAM EF6-BREEZE-TEXTURE.

'''
extra+=prog('EF6-BREEZE-WIND-U','''     COMPUTE L-O(1) = FUNCTION MOD(L-I(1) * 0.02, 1)
     MOVE 0 TO L-O(2)
''')
write_section_src(9,hdr,IDS,extra+'\n'+kf); write_layers(LAYERS)
