from mesh5 import *
import kfgen,app5
IDS=['ARMADILLO','ARMADILLO_BABY']
A1=app5.parse('15.4'); A2=app5.parse('15.5')
N1=[a['name'] for a in A1]; N2=[a['name'] for a in A2]
hdr='''*> Entity models part 5 section 10 (Armadillo): the meshes of the adult and the baby (10.1), setupAnim (10.2), texture, shadow, the state enum and the animation state machine (10.3), the keyframe tables 15.4 and 15.5 (as rows).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF5-ARMADILLO-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 walk position, 4 walk speed, 5 ageInTicks, 6 hiding in shell, 7 roll out start tick, 8 roll up start tick, 9 peek start tick (-2147483648 is stopped), 10 baby model,
*>   11 OUT body skipDraw (the model has no skipDraw field; the body cuboids are not drawn when 1)): reset first, then the steps of 10.2;
*>   EF5-ARMADILLO-TEXTURE IN(baby) path(out X(120)); EF5-ARMADILLO-SHADOW IN() OUT(radius); EF5-ARMADILLO-INFO IN(state 0 IDLE 1 ROLLING 2 SCARED 3 UNROLLING) OUT(threatened, animation ticks);
*>   EF5-ARMADILLO-HIDE IN(state, inStateTicks) OUT(shouldHideInShell); EF5-ARMADILLO-STATES IN(state, inStateTicks, tickCount, roll out start, roll up start, peek start, peek received) OUT(roll out start, roll up start, peek start, peek received): setupAnimationStates.
*>   Keyframes: EF5A-ANIM-* for the adult (ordinals 1 ARMADILLO_ROLL_UP 2 ARMADILLO_WALK 3 ARMADILLO_PEEK 4 ARMADILLO_ROLL_OUT), EF5D-ANIM-* for the baby (1 BABY_ROLL_UP 2 BABY_WALK 3 BABY_ROLL_OUT 4 BABY_PEEK), each with
*>   -DEF ordinal EM5-DEF ok(out), -NAME, -INFO IN(ordinal) OUT(length, looping, channels), -BONE, -EVAL IN(ordinal, channel, t, scale) OUT(x y z), -APPLY EMM-MODEL ordinal ms scale ok(out).
'''
kf1=kfgen.gen('EF5A',N1,A1,[''])
kf2=kfgen.gen('EF5D',N2,A2,[''])
def blk(pfx,ords):
    ro,ru,pk,walk=ords
    s=''
    for nm,idx,start in (('ro',ro,7),('ru',ru,8),('pk',pk,9)):
        s+='''     IF L-I(%d) NOT = -2147483648
         MOVE L-I(%d) TO WS-START
         MOVE L-I(5) TO WS-AV(1)
         CALL "EM5-STATE" USING WS-OP WS-START WS-A WS-R
         MOVE WS-R TO WS-MS
         MOVE %d TO WS-ORD
         CALL "%s-ANIM-APPLY" USING EMM-MODEL WS-ORD WS-MS WS-ONE WS-OK
     END-IF
'''%(start,start,idx,pfx)
    return s
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-ARMADILLO-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-HEAD                BINARY-LONG.
 01 WS-BODY                BINARY-LONG.
 01 WS-RH                  BINARY-LONG.
 01 WS-LH                  BINARY-LONG.
 01 WS-TAIL                BINARY-LONG.
 01 WS-CUBE                BINARY-LONG.
 01 WS-OP                  BINARY-LONG VALUE 6.
 01 WS-START               BINARY-LONG.
 01 WS-A.
    05 WS-AV               FLOAT-LONG OCCURS 4 TIMES.
 01 WS-R                   FLOAT-LONG.
 01 WS-MS                  BINARY-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-TF                  FLOAT-LONG VALUE 16.5.
 01 WS-SF                  FLOAT-LONG VALUE 2.5.
 01 WS-WP                  FLOAT-LONG.
 01 WS-WS                  FLOAT-LONG.
 01 WS-SCALE               FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-ORD                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-HEAD
     MOVE "right_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RH
     MOVE "left_hind_leg" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LH
     MOVE "tail" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-TAIL
     MOVE "cube" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-CUBE
     IF L-I(6) NOT = 0
         MOVE 1 TO L-I(11)
         MOVE 0 TO MM-VISIBLE(WS-RH) MM-VISIBLE(WS-LH) MM-VISIBLE(WS-TAIL)
         MOVE 1 TO MM-VISIBLE(WS-CUBE)
     ELSE
         MOVE 0 TO L-I(11)
         MOVE 1 TO MM-VISIBLE(WS-RH) MM-VISIBLE(WS-LH) MM-VISIBLE(WS-TAIL)
         MOVE 0 TO MM-VISIBLE(WS-CUBE)
         MOVE L-I(1) TO WS-V
         IF WS-V < -22.5
             MOVE -22.5 TO WS-V
         END-IF
         IF WS-V > 25
             MOVE 25 TO WS-V
         END-IF
         COMPUTE MM-CXROT(WS-HEAD) = WS-V * 0.017453292
         MOVE L-I(2) TO WS-V
         IF WS-V < -32.5
             MOVE -32.5 TO WS-V
         END-IF
         IF WS-V > 32.5
             MOVE 32.5 TO WS-V
         END-IF
         COMPUTE MM-CYROT(WS-HEAD) = WS-V * 0.017453292
         MOVE L-I(3) TO WS-WP
         MOVE L-I(4) TO WS-WS
         CALL "EM5-WALK-TIME" USING WS-WP WS-WS WS-TF WS-SF WS-MS WS-SCALE
         MOVE 2 TO WS-ORD
         IF L-I(10) = 0
             CALL "EF5A-ANIM-APPLY" USING EMM-MODEL WS-ORD WS-MS WS-SCALE WS-OK
         ELSE
             CALL "EF5D-ANIM-APPLY" USING EMM-MODEL WS-ORD WS-MS WS-SCALE WS-OK
         END-IF
     END-IF
     IF L-I(10) = 0
'''+blk('EF5A',(4,1,3,2))+r'''     ELSE
'''+blk('EF5D',(3,1,4,2))+r'''     END-IF
     GOBACK.
 END PROGRAM EF5-ARMADILLO-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-ARMADILLO-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     IF L-I(1) NOT = 0
         MOVE "textures/entity/armadillo/armadillo_baby.png" TO L-PATH
     ELSE
         MOVE "textures/entity/armadillo/armadillo.png" TO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EF5-ARMADILLO-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-ARMADILLO-SHADOW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0.4 TO L-O(1)
     GOBACK.
 END PROGRAM EF5-ARMADILLO-SHADOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-ARMADILLO-INFO.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1) L-O(2)
     EVALUATE L-I(1)
         WHEN 1
             MOVE 1 TO L-O(1)
             MOVE 10 TO L-O(2)
         WHEN 2
             MOVE 1 TO L-O(1)
             MOVE 50 TO L-O(2)
         WHEN 3
             MOVE 1 TO L-O(1)
             MOVE 30 TO L-O(2)
     END-EVALUATE
     GOBACK.
 END PROGRAM EF5-ARMADILLO-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-ARMADILLO-HIDE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     EVALUATE L-I(1)
         WHEN 1
             IF L-I(2) > 5
                 MOVE 1 TO L-O(1)
             END-IF
         WHEN 2
             MOVE 1 TO L-O(1)
         WHEN 3
             IF L-I(2) < 26
                 MOVE 1 TO L-O(1)
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM EF5-ARMADILLO-HIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-ARMADILLO-STATES.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(7) TO L-O(4)
     EVALUATE L-I(1)
         WHEN 0
             MOVE -2147483648 TO L-O(1) L-O(2) L-O(3)
         WHEN 1
             MOVE -2147483648 TO L-O(1) L-O(3)
             MOVE L-I(5) TO L-O(2)
             IF L-I(5) = -2147483648
                 MOVE L-I(3) TO L-O(2)
             END-IF
         WHEN 3
             MOVE -2147483648 TO L-O(2) L-O(3)
             MOVE L-I(4) TO L-O(1)
             IF L-I(4) = -2147483648
                 MOVE L-I(3) TO L-O(1)
             END-IF
         WHEN OTHER
             MOVE -2147483648 TO L-O(1) L-O(2)
             MOVE L-I(6) TO L-O(3)
             IF L-I(7) NOT = 0
                 MOVE -2147483648 TO L-O(3)
                 MOVE 0 TO L-O(4)
             END-IF
             IF L-I(2) = 0
                 COMPUTE L-O(3) = L-I(3) - 50
             ELSE
                 IF L-O(3) = -2147483648
                     MOVE L-I(3) TO L-O(3)
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM EF5-ARMADILLO-STATES.
'''
write_section_src(10,hdr,IDS,extra+'\n'+kf1+'\n'+kf2); write_layers(IDS)
