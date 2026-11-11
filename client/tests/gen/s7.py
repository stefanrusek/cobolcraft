from mesh4 import *
IDS=['GOAT','GOAT_BABY']
hdr='''*> Entity models part 4 section 7 (Goat): the meshes of goat and goat_baby (7.3), the texture paths (7.1) and setupAnim (7.2).
*> Entry points for the integrator (inputs): EF4-GOAT-TEXTURE IN(baby) path(out X(120)); EF4-GOAT-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 walk position, 4 walk speed,
*>   5 has left horn, 6 has right horn, 7 rammingXHeadRot, 8 baby model): QuadrupedModel.setupAnim, horn visibility, ramming pitch, the baby's 0.3926991 tilt when not ramming.
'''
extra=''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-GOAT-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     MOVE "textures/entity/goat/goat.png" TO L-PATH
     IF L-I(1) NOT = 0
         MOVE "textures/entity/goat/goat_baby.png" TO L-PATH
     END-IF
     GOBACK.
 END PROGRAM EF4-GOAT-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-GOAT-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-P                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EF4-QUAD-POSE" USING EMM-MODEL L-IN
     MOVE "head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-H
     MOVE "left_horn" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
     MOVE 0 TO MM-VISIBLE(WS-P)
     IF L-I(5) NOT = 0
         MOVE 1 TO MM-VISIBLE(WS-P)
     END-IF
     MOVE "right_horn" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
     MOVE 0 TO MM-VISIBLE(WS-P)
     IF L-I(6) NOT = 0
         MOVE 1 TO MM-VISIBLE(WS-P)
     END-IF
     IF L-I(7) NOT = 0
         MOVE L-I(7) TO MM-CXROT(WS-H)
     END-IF
     IF L-I(8) NOT = 0 AND L-I(7) = 0
         MOVE 0.3926991 TO MM-CXROT(WS-H)
     END-IF
     GOBACK.
 END PROGRAM EF4-GOAT-ANIM.
'''
write_section_src(7,hdr,IDS,extra); write_layers(IDS)
