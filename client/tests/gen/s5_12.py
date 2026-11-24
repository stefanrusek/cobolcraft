from mesh5 import *
IDS=['TADPOLE']
hdr='''*> Entity models part 5 section 12 (Tadpole): the mesh (12), the tail swing, texture and shadow.
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF5-TADPOLE-ANIM EMM-MODEL state(1 in water, 2 ageInTicks): reset first, tail.yRot = -f x 0.25 x sin(0.3 A), f 1 in water else 1.5; EF5-TADPOLE-TEXTURE path(out X(120)); EF5-TADPOLE-SHADOW IN() OUT(radius).
'''
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-TADPOLE-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-T                   BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "tail" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-T
     MOVE 1.5 TO WS-F
     IF L-I(1) NOT = 0
         MOVE 1 TO WS-F
     END-IF
     COMPUTE MM-CYROT(WS-T) = 0 - WS-F * 0.25 * FUNCTION SIN(0.3 * L-I(2))
     GOBACK.
 END PROGRAM EF5-TADPOLE-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-TADPOLE-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-PATH.
     MOVE "textures/entity/tadpole/tadpole.png" TO L-PATH
     GOBACK.
 END PROGRAM EF5-TADPOLE-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF5-TADPOLE-SHADOW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0.14 TO L-O(1)
     GOBACK.
 END PROGRAM EF5-TADPOLE-SHADOW.
'''
write_section_src(12,hdr,IDS,extra); write_layers(IDS)
