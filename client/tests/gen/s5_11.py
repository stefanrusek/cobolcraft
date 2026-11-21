from mesh5 import *
import kfgen,app5
IDS=['FROG']
AN=app5.parse('15.3')
NM=[a['name'] for a in AN]
hdr='''*> Entity models part 5 section 11 (Frog): the mesh (11), setupAnim with the FROG keyframes (15.3, as rows), texture path and shadow.
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF5-FROG-ANIM EMM-MODEL state(1 walk position, 2 walk speed, 3 ageInTicks, 4 swimming, 5 jump start tick, 6 croak start tick, 7 tongue start tick, 8 swim idle start tick; -2147483648 is a stopped state): reset first, jump, croak, tongue,
*>   then swim (factors 1 and 2.5) or walk (1.5 and 2.5), then the swim idle, croaking_body visible while the croak state is started;
*>   EF5-FROG-TEXTURE asset-id(X(40), spaces for none) path(out X(120)): textures/<id>.png or the temperate default; EF5-FROG-SHADOW IN() OUT(radius).
*>   Keyframes EF5G-ANIM-*: ordinals 1 FROG_CROAK 2 FROG_WALK 3 FROG_JUMP 4 FROG_TONGUE 5 FROG_SWIM 6 FROG_IDLE_WATER; -DEF ordinal EM5-DEF ok(out), -NAME, -INFO IN(ordinal) OUT(length, looping, channels), -BONE,
*>   -EVAL IN(ordinal, channel, t, scale) OUT(x y z), -APPLY EMM-MODEL ordinal ms scale ok(out).
'''
kf=kfgen.gen('EF5G',NM,AN,[''])
def blk(nm,var,start):
    return '''     IF L-I(%d) NOT = -2147483648
         MOVE L-I(%d) TO WS-START
         MOVE L-I(3) TO WS-AV(1)
         CALL "EM5-STATE" USING WS-OP WS-START WS-A WS-R
         MOVE WS-R TO WS-MS
         MOVE %d TO WS-ORD
         CALL "EF5G-ANIM-APPLY" USING EMM-MODEL WS-ORD WS-MS WS-ONE WS-OK
     END-IF
'''%(start,start,NM.index(nm)+1)
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-FROG-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-CB                  BINARY-LONG.
 01 WS-OP                  BINARY-LONG VALUE 6.
 01 WS-START               BINARY-LONG.
 01 WS-A.
    05 WS-AV               FLOAT-LONG OCCURS 4 TIMES.
 01 WS-R                   FLOAT-LONG.
 01 WS-MS                  BINARY-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-TF                  FLOAT-LONG.
 01 WS-SF                  FLOAT-LONG VALUE 2.5.
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
'''+blk('FROG_JUMP','',5)+blk('FROG_CROAK','',6)+blk('FROG_TONGUE','',7)+r'''     MOVE L-I(1) TO WS-WP
     MOVE L-I(2) TO WS-WS
     IF L-I(4) NOT = 0
         MOVE 1 TO WS-TF
         MOVE %d TO WS-ORD
     ELSE
         MOVE 1.5 TO WS-TF
         MOVE %d TO WS-ORD
     END-IF
     CALL "EM5-WALK-TIME" USING WS-WP WS-WS WS-TF WS-SF WS-MS WS-SCALE
     CALL "EF5G-ANIM-APPLY" USING EMM-MODEL WS-ORD WS-MS WS-SCALE WS-OK
'''%(NM.index('FROG_SWIM')+1,NM.index('FROG_WALK')+1)+blk('FROG_IDLE_WATER','',8)+r'''     MOVE "croaking_body" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-CB
     MOVE 0 TO MM-VISIBLE(WS-CB)
     IF L-I(6) NOT = -2147483648
         MOVE 1 TO MM-VISIBLE(WS-CB)
     END-IF
     GOBACK.
 END PROGRAM EF5-FROG-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-FROG-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ID                   PIC X(40).
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-ID L-PATH.
     MOVE SPACES TO L-PATH
     IF L-ID = SPACES
         MOVE "textures/entity/frog/frog_temperate.png" TO L-PATH
     ELSE
         STRING "textures/" FUNCTION TRIM(L-ID) ".png" DELIMITED BY SIZE INTO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EF5-FROG-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-FROG-SHADOW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0.3 TO L-O(1)
     GOBACK.
 END PROGRAM EF5-FROG-SHADOW.
'''
write_section_src(11,hdr,IDS,extra+'\n'+kf); write_layers(IDS)
