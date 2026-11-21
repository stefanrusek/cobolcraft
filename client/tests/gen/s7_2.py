from blaze7 import *
from prog6 import *
setlayer('BLAZE',blaze_rows(),64,32)
hdr='''*> Entity models part 7 section 2 (Blaze): the mesh (2.1), setupAnim (2.2), shadow, block light level and texture.
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF7-BLAZE-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 ageInTicks): reset first, head look, the twelve rods on three rings; EF7-BLAZE-RENDER IN() OUT(shadow radius, block light level); EF7-BLAZE-TEXTURE IN() path(out X(120)).
'''
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-BLAZE-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-DIG                 PIC 99.
 01 WS-H                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-BASE                FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-H
     COMPUTE MM-CXROT(WS-H) = L-I(1) * 0.017453292
     COMPUTE MM-CYROT(WS-H) = L-I(2) * 0.017453292
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 11
         MOVE WS-I TO WS-DIG
         MOVE SPACES TO WS-NAME
         IF WS-I < 10
             STRING "part" WS-DIG(2:1) DELIMITED BY SIZE INTO WS-NAME
         ELSE
             STRING "part" WS-DIG DELIMITED BY SIZE INTO WS-NAME
         END-IF
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
         EVALUATE TRUE
             WHEN WS-I < 4
                 MOVE WS-I TO WS-K
                 COMPUTE WS-BASE = L-I(3) * 3.141592653589793 * -0.1
                 MOVE 9 TO WS-R
                 COMPUTE WS-Y = -2 + FUNCTION COS((2 * WS-I + L-I(3)) * 0.25)
             WHEN WS-I < 8
                 COMPUTE WS-K = WS-I - 4
                 COMPUTE WS-BASE = 0.7853982 + L-I(3) * 3.141592653589793 * 0.03
                 MOVE 7 TO WS-R
                 COMPUTE WS-Y = 2 + FUNCTION COS((2 * WS-I + L-I(3)) * 0.25)
             WHEN OTHER
                 COMPUTE WS-K = WS-I - 8
                 COMPUTE WS-BASE = 0.47123894 + L-I(3) * 3.141592653589793 * -0.05
                 MOVE 5 TO WS-R
                 COMPUTE WS-Y = 11 + FUNCTION COS((1.5 * WS-I + L-I(3)) * 0.5)
         END-EVALUATE
         COMPUTE WS-A = WS-BASE + WS-K * 1.5707964
         COMPUTE MM-CX(WS-P) = FUNCTION COS(WS-A) * WS-R
         MOVE WS-Y TO MM-CY(WS-P)
         COMPUTE MM-CZ(WS-P) = FUNCTION SIN(WS-A) * WS-R
     END-PERFORM
     GOBACK.
 END PROGRAM EF7-BLAZE-ANIM.

'''
extra+=prog('EF7-BLAZE-RENDER','     MOVE 0.5 TO L-O(1)\n     MOVE 15 TO L-O(2)\n')
extra+=' IDENTIFICATION DIVISION.\n PROGRAM-ID. EF7-BLAZE-TEXTURE.\n DATA DIVISION.\n LINKAGE SECTION.\n 01 L-IN.\n    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.\n 01 L-PATH                 PIC X(120).\n PROCEDURE DIVISION USING L-IN L-PATH.\n     MOVE "textures/entity/blaze/blaze.png" TO L-PATH\n     GOBACK.\n END PROGRAM EF7-BLAZE-TEXTURE.\n\n'
write_section_src(2,hdr,['BLAZE'],extra); write_layers(['BLAZE'])
