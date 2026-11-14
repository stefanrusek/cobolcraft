from mesh5 import *
import kfgen,app5
IDS=['SNIFFER','SNIFFER_BABY']
AN=app5.parse('15.6'); NM=[a['name'] for a in AN]
hdr='''*> Entity models part 5 section 14 (Sniffer and snifflet): the adult and baby meshes (14.1), setupAnim (14.2) with the nine definitions of 15.6 (as rows), textures, shadow and the culling box (14.3).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF5-SNIFFER-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 walk position, 4 walk speed, 5 ageInTicks, 6 searching, 7 dig start tick, 8 long sniff start, 9 stand up start, 10 happy start, 11 sniff sniff start; -2147483648 is stopped):
*>   reset first, head look, search or walk (factors 9 and 100), then dig, long sniff, stand up, happy, sniff sniff. The baby uses the same program (SniffletModel is not run by the client, so no baby transform).
*>   EF5-SNIFFER-TEXTURE IN(baby) path(out X(120)); EF5-SNIFFER-SHADOW IN() OUT(radius); EF5-SNIFFER-CULL IN(min x y z, max x y z) OUT(the box inflated by 0.6 on every axis).
*>   Keyframes EF5S-ANIM-*: ordinals 1 BABY_TRANSFORM 2 SNIFFER_SNIFFSNIFF 3 SNIFFER_LONGSNIFF 4 SNIFFER_WALK 5 SNIFFER_SNIFF_SEARCH 6 SNIFFER_DIG 7 SNIFFER_STAND_UP 8 SNIFFER_BABY_FALL 9 SNIFFER_HAPPY; -DEF ordinal EM5-DEF ok(out),
*>   -NAME, -INFO IN(ordinal) OUT(length, looping, channels), -BONE, -EVAL IN(ordinal, channel, t, scale) OUT(x y z), -APPLY EMM-MODEL ordinal ms scale ok(out).
'''
kf=kfgen.gen('EF5S',NM,AN,[''])
def blk(nm,start):
    return '''     IF L-I(%d) NOT = -2147483648
         MOVE L-I(%d) TO WS-START
         MOVE L-I(5) TO WS-AV(1)
         CALL "EM5-STATE" USING WS-OP WS-START WS-A WS-R
         MOVE WS-R TO WS-MS
         MOVE %d TO WS-ORD
         CALL "EF5S-ANIM-APPLY" USING EMM-MODEL WS-ORD WS-MS WS-ONE WS-OK
     END-IF
'''%(start,start,NM.index(nm)+1)
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-SNIFFER-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-HEAD                BINARY-LONG.
 01 WS-OP                  BINARY-LONG VALUE 6.
 01 WS-START               BINARY-LONG.
 01 WS-A.
    05 WS-AV               FLOAT-LONG OCCURS 4 TIMES.
 01 WS-R                   FLOAT-LONG.
 01 WS-MS                  BINARY-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-TF                  FLOAT-LONG VALUE 9.
 01 WS-SF                  FLOAT-LONG VALUE 100.
 01 WS-WP                  FLOAT-LONG.
 01 WS-WS                  FLOAT-LONG.
 01 WS-SCALE               FLOAT-LONG.
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
     COMPUTE MM-CXROT(WS-HEAD) = L-I(1) * 0.017453292
     COMPUTE MM-CYROT(WS-HEAD) = L-I(2) * 0.017453292
     MOVE L-I(3) TO WS-WP
     MOVE L-I(4) TO WS-WS
     CALL "EM5-WALK-TIME" USING WS-WP WS-WS WS-TF WS-SF WS-MS WS-SCALE
     MOVE %d TO WS-ORD
     IF L-I(6) NOT = 0
         MOVE %d TO WS-ORD
     END-IF
     CALL "EF5S-ANIM-APPLY" USING EMM-MODEL WS-ORD WS-MS WS-SCALE WS-OK
'''%(NM.index('SNIFFER_WALK')+1,NM.index('SNIFFER_SNIFF_SEARCH')+1)+blk('SNIFFER_DIG',7)+blk('SNIFFER_LONGSNIFF',8)+blk('SNIFFER_STAND_UP',9)+blk('SNIFFER_HAPPY',10)+blk('SNIFFER_SNIFFSNIFF',11)+r'''     GOBACK.
 END PROGRAM EF5-SNIFFER-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-SNIFFER-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     IF L-I(1) NOT = 0
         MOVE "textures/entity/sniffer/snifflet.png" TO L-PATH
     ELSE
         MOVE "textures/entity/sniffer/sniffer.png" TO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EF5-SNIFFER-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-SNIFFER-SHADOW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 1.1 TO L-O(1)
     GOBACK.
 END PROGRAM EF5-SNIFFER-SHADOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-SNIFFER-CULL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
         COMPUTE L-O(WS-K) = L-I(WS-K) - 0.6
         COMPUTE L-O(WS-K + 3) = L-I(WS-K + 3) + 0.6
     END-PERFORM
     GOBACK.
 END PROGRAM EF5-SNIFFER-CULL.
'''
write_section_src(14,hdr,IDS,extra+'\n'+kf); write_layers(IDS)
