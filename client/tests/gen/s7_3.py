from blaze7 import *
from prog6 import *
setlayer('GHAST',ghast_rows(LENS),64,32,[4.5])
hdr='''*> Entity models part 7 section 3 (Ghast): the mesh through the 4.5 scaling transformer (3.1), setupAnim (3.2), texture, shadow radius and the tentacle lengths from the generator seeded 1660.
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF7-GHAST-ANIM EMM-MODEL state(1 ageInTicks): reset first, tentacle i xRot = 0.2 sin(age x 0.3 + i) + 0.4; EF7-GHAST-LENGTHS IN() OUT(nine lengths nextInt(7) + 8 from setSeed(1660), via EF7-RANDOM-SEQ);
*>   EF7-GHAST-TEXTURE IN(charging) path(out X(120)); EF7-GHAST-SHADOW IN() OUT(radius).
'''
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-GHAST-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-DIG                 PIC 9.
 01 WS-P                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 8
         MOVE WS-I TO WS-DIG
         MOVE SPACES TO WS-NAME
         STRING "tentacle" WS-DIG DELIMITED BY SIZE INTO WS-NAME
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
         COMPUTE MM-CXROT(WS-P) = 0.2 * FUNCTION SIN(L-I(1) * 0.3 + WS-I) + 0.4
     END-PERFORM
     GOBACK.
 END PROGRAM EF7-GHAST-ANIM.

'''
extra+=prog('EF7-GHAST-LENGTHS','''     MOVE 3 TO WS-IN(1)
     MOVE 1660 TO WS-IN(2)
     MOVE 7 TO WS-IN(3)
     MOVE 0 TO WS-IN(4)
     MOVE 9 TO WS-IN(5)
     CALL "EF7-RANDOM-SEQ" USING WS-IN-G L-OUT
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 9
         COMPUTE L-O(WS-K) = L-O(WS-K) + 8
     END-PERFORM
''',' 01 WS-IN-G.\n    05 WS-IN              FLOAT-LONG OCCURS 16 TIMES.\n 01 WS-K                   BINARY-LONG.\n')
extra+=prog('EF7-GHAST-SHADOW','     MOVE 1.5 TO L-O(1)\n')
extra+=' IDENTIFICATION DIVISION.\n PROGRAM-ID. EF7-GHAST-TEXTURE.\n DATA DIVISION.\n LINKAGE SECTION.\n 01 L-IN.\n    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.\n 01 L-PATH                 PIC X(120).\n PROCEDURE DIVISION USING L-IN L-PATH.\n     IF L-I(1) NOT = 0\n         MOVE "textures/entity/ghast/ghast_shooting.png" TO L-PATH\n     ELSE\n         MOVE "textures/entity/ghast/ghast.png" TO L-PATH\n     END-IF\n     GOBACK.\n END PROGRAM EF7-GHAST-TEXTURE.\n\n'
write_section_src(3,hdr,['GHAST'],extra); write_layers(['GHAST'])
