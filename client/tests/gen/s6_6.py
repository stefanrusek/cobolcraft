from mesh6 import *
import s6_spider_data as SP
setlayer('SPIDER',SP.rows(),64,32); setlayer('CAVE_SPIDER',SP.rows(),64,32,[0.7],src='SPIDER')
IDS=['SPIDER']
hdr='''*> Entity models part 6 section 6 (Spider and cave spider): the one mesh (6.1; the CAVE_SPIDER layer is the same mesh through EMD-SCALE-ROOT 0.7), setupAnim (6.2), textures (6.3).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF6-SPIDER-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 walk position, 4 walk speed): reset first, head look, then the four leg pairs (phases 0, pi, pi/2, 3 pi/2); EF6-SPIDER-TEXTURE IN(cave spider, eyes layer) path(out X(120)).
'''
pairs=[('right_hind_leg','left_hind_leg','0'),('right_middle_hind_leg','left_middle_hind_leg','3.1415927'),('right_middle_front_leg','left_middle_front_leg','1.5707964'),('right_front_leg','left_front_leg','4.712389')]
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-SPIDER-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-H                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-TH                  FLOAT-LONG.
 01 WS-PHI                 FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-H
     COMPUTE MM-CYROT(WS-H) = L-I(2) * 0.017453292
     COMPUTE MM-CXROT(WS-H) = L-I(1) * 0.017453292
     COMPUTE WS-TH = L-I(3) * 0.6662
'''
for r,l,phi in pairs:
    extra+='''     MOVE "%s" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-R
     MOVE "%s" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-L
     MOVE %s TO WS-PHI
     COMPUTE WS-A = 0 - (FUNCTION COS(2 * WS-TH + WS-PHI) * 0.4) * L-I(4)
     COMPUTE WS-B = FUNCTION ABS(FUNCTION SIN(WS-TH + WS-PHI) * 0.4) * L-I(4)
     COMPUTE MM-CYROT(WS-R) = MM-CYROT(WS-R) + WS-A
     COMPUTE MM-CZROT(WS-R) = MM-CZROT(WS-R) + WS-B
     COMPUTE MM-CYROT(WS-L) = MM-CYROT(WS-L) - WS-A
     COMPUTE MM-CZROT(WS-L) = MM-CZROT(WS-L) - WS-B
'''%(r,l,phi)
extra+=r'''     GOBACK.
 END PROGRAM EF6-SPIDER-ANIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-SPIDER-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     EVALUATE TRUE
         WHEN L-I(2) NOT = 0
             MOVE "textures/entity/spider/spider_eyes.png" TO L-PATH
         WHEN L-I(1) NOT = 0
             MOVE "textures/entity/spider/cave_spider.png" TO L-PATH
         WHEN OTHER
             MOVE "textures/entity/spider/spider.png" TO L-PATH
     END-EVALUATE
     GOBACK.
 END PROGRAM EF6-SPIDER-TEXTURE.
'''
write_section_src(6,hdr,IDS,extra); write_layers(IDS)
setlayer('CAVE_SPIDER',SP.rows(),64,32,[0.7],src='SPIDER'); write_layers(['CAVE_SPIDER'])
