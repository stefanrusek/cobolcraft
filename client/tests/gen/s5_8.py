from mesh5 import *
import kfgen,app5
IDS=['BAT']
AN=app5.parse('15.2')
hdr='''*> Entity models part 5 section 8 (Bat): the mesh (8), setupAnim with the BAT_RESTING and BAT_FLYING keyframes (15.2, as rows), texture, shadow and the entity-side counters.
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF5-BAT-ANIM EMM-MODEL state(1 yRot degrees, 2 resting, 3 ageInTicks, 4 fly animation start tick, 5 rest animation start tick; -2147483648 is a stopped state): reset, resting head yaw, then flying and resting keyframes;
*>   EF5-BAT-TEXTURE path(out X(120)); EF5-BAT-SHADOW IN() OUT(radius); EF5-BAT-TICK IN(resting, fly start, rest start, tickCount) OUT(fly start, rest start): setupAnimationStates;
*>   EF5-BAT-MOVE IN(resting, y, bbHeight, delta y) OUT(y, delta y): the per-tick resting snap and the flying 0.6 damping.
*>   Keyframes: EF5B-ANIM-DEF ordinal(1 BAT_RESTING 2 BAT_FLYING) EM5-DEF ok(out), EF5B-ANIM-NAME, EF5B-ANIM-INFO IN(ordinal) OUT(length, looping, channels), EF5B-ANIM-BONE, EF5B-ANIM-EVAL IN(ordinal, channel, t, scale) OUT(x y z), EF5B-ANIM-APPLY EMM-MODEL ordinal ms scale ok(out).
'''
kf=kfgen.gen('EF5B',['BAT_RESTING','BAT_FLYING'],AN,[''])
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-BAT-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-H                   BINARY-LONG.
 01 WS-OP                  BINARY-LONG VALUE 6.
 01 WS-START               BINARY-LONG.
 01 WS-A.
    05 WS-AV               FLOAT-LONG OCCURS 4 TIMES.
 01 WS-R                   FLOAT-LONG.
 01 WS-MS                  BINARY-LONG.
 01 WS-SCALE               FLOAT-LONG VALUE 1.
 01 WS-ORD                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     IF L-I(2) NOT = 0
         MOVE "head" TO WS-NAME
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-H
         COMPUTE MM-CYROT(WS-H) = L-I(1) * 0.017453292
     END-IF
     IF L-I(4) NOT = -2147483648
         MOVE L-I(4) TO WS-START
         MOVE L-I(3) TO WS-AV(1)
         CALL "EM5-STATE" USING WS-OP WS-START WS-A WS-R
         MOVE WS-R TO WS-MS
         MOVE 2 TO WS-ORD
         CALL "EF5B-ANIM-APPLY" USING EMM-MODEL WS-ORD WS-MS WS-SCALE WS-OK
     END-IF
     IF L-I(5) NOT = -2147483648
         MOVE L-I(5) TO WS-START
         MOVE L-I(3) TO WS-AV(1)
         CALL "EM5-STATE" USING WS-OP WS-START WS-A WS-R
         MOVE WS-R TO WS-MS
         MOVE 1 TO WS-ORD
         CALL "EF5B-ANIM-APPLY" USING EMM-MODEL WS-ORD WS-MS WS-SCALE WS-OK
     END-IF
     GOBACK.
 END PROGRAM EF5-BAT-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-BAT-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-PATH.
     MOVE "textures/entity/bat/bat.png" TO L-PATH
     GOBACK.
 END PROGRAM EF5-BAT-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-BAT-SHADOW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0.25 TO L-O(1)
     GOBACK.
 END PROGRAM EF5-BAT-SHADOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-BAT-TICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     IF L-I(1) NOT = 0
         MOVE -2147483648 TO L-O(1)
         MOVE L-I(3) TO L-O(2)
         IF L-I(3) = -2147483648
             MOVE L-I(4) TO L-O(2)
         END-IF
     ELSE
         MOVE -2147483648 TO L-O(2)
         MOVE L-I(2) TO L-O(1)
         IF L-I(2) = -2147483648
             MOVE L-I(4) TO L-O(1)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EF5-BAT-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-BAT-MOVE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     IF L-I(1) NOT = 0
         COMPUTE L-O(1) = FUNCTION INTEGER(L-I(2)) + 1 - L-I(3)
         MOVE 0 TO L-O(2)
     ELSE
         MOVE L-I(2) TO L-O(1)
         COMPUTE L-O(2) = L-I(4) * 0.6
     END-IF
     GOBACK.
 END PROGRAM EF5-BAT-MOVE.
'''
write_section_src(8,hdr,IDS,extra+'\n'+kf); write_layers(IDS)
