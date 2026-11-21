from mesh4 import *
IDS=['COW','COLD_COW','WARM_COW','COW_BABY']
hdr='''*> Entity models part 4 section 2 (Cow): the meshes of the layers cow, cold_cow, warm_cow and cow_baby (2.3), the variant texture rule (2.1) and setupAnim (2.2).
*> Entry points for the integrator (inputs): EF4-VARIANT-TEXTURE IN(variant null, baby) OUT(0 missing texture, 1 the variant's adult asset, 2 its baby texture) (2.1, also pig and chicken);
*>   EF4-COW-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 walk position, 4 walk speed): QuadrupedModel.setupAnim of 2.2 (EF4-QUAD-POSE). Layers: EF4-LAYER (COW, COLD_COW, WARM_COW, COW_BABY).
'''
extra=''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-VARIANT-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 0 TO L-O(1)
     IF L-I(1) = 0
         MOVE 1 TO L-O(1)
         IF L-I(2) NOT = 0
             MOVE 2 TO L-O(1)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM EF4-VARIANT-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF4-COW-ANIM.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EF4-QUAD-POSE" USING EMM-MODEL L-IN
     GOBACK.
 END PROGRAM EF4-COW-ANIM.
'''
write_section_src(2,hdr,IDS,extra); write_layers(IDS)
