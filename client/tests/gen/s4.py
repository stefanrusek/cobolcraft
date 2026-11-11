from mesh4 import *
IDS=['PIG','PIG_SADDLE','COLD_PIG','PIG_BABY']
hdr='''*> Entity models part 4 section 4 (Pig): the meshes of pig, pig_saddle, cold_pig and pig_baby (4.2), the saddle rule and setupAnim (4.1).
*> Entry points for the integrator (inputs): EF4-PIG-SADDLE IN(saddle item with an equippable asset, baby) OUT(drawn: a baby never shows the pig_saddle layer);
*>   EF4-PIG-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 walk position, 4 walk speed): QuadrupedModel.setupAnim (also the saddle model). Model choice: EF4-VARIANT-MODEL, texture: EF4-VARIANT-TEXTURE.
'''
extra=''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-PIG-SADDLE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) NOT = 0 AND L-I(2) = 0
         MOVE 1 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EF4-PIG-SADDLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-PIG-ANIM.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EF4-QUAD-POSE" USING EMM-MODEL L-IN
     GOBACK.
 END PROGRAM EF4-PIG-ANIM.
'''
write_section_src(4,hdr,IDS,extra); write_layers(IDS)
