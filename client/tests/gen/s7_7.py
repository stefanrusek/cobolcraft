from crystal7 import *
from prog6 import *
define()
hdr='''*> Entity models part 7 section 7 (End crystal): the mesh with nested scales (7.1), the bob height and setupAnim with the two rotations (7.2), the renderer pose, beam vector and shouldRender (7.3).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF7-CRYSTAL-GETY IN(a) OUT(getY); EF7-ATAN2 IN(y, x) OUT(angle radians, Math.atan2); EF7-CRYSTAL-ANIM EMM-MODEL state(1 ageInTicks, 2 showsBottom): reset first, base visible, outer glass y, outer glass rotateBy Q1, inner glass and cube rotateBy Q2 (zero base rotation, so the angles of the quaternions);
*>   EF7-CRYSTAL-BEAM IN(beam offset x y z, ageInTicks) OUT(translate x y z, the beam vector x y z); EF7-CRYSTAL-RENDER IN() OUT(shadow radius, scale x y z, translate x y z); EF7-CRYSTAL-SHOULD IN(base test, has beam target) OUT(shouldRender);
*>   EF7-CRYSTAL-TEXTURE IN(beam) path(out X(120)). Layer END_CRYSTAL through EF7-LAYER.
'''
extra=''
extra+=prog('EF7-CRYSTAL-GETY','''     COMPUTE WS-F = FUNCTION SIN(0.2 * L-I(1)) / 2 + 0.5
     COMPUTE WS-F = (WS-F * WS-F + WS-F) * 0.4
     COMPUTE L-O(1) = WS-F - 1.4
''',' 01 WS-F                   FLOAT-LONG.\n')
extra+=prog('EF7-ATAN2','''     EVALUATE TRUE
         WHEN L-I(2) > 0
             COMPUTE L-O(1) = FUNCTION ATAN(L-I(1) / L-I(2))
         WHEN L-I(2) < 0
             COMPUTE L-O(1) = FUNCTION ATAN(L-I(1) / L-I(2))
             IF L-I(1) >= 0
                 COMPUTE L-O(1) = L-O(1) + 3.141592653589793
             ELSE
                 COMPUTE L-O(1) = L-O(1) - 3.141592653589793
             END-IF
         WHEN L-I(1) > 0
             MOVE 1.5707963267948966 TO L-O(1)
         WHEN L-I(1) < 0
             MOVE -1.5707963267948966 TO L-O(1)
         WHEN OTHER
             MOVE 0 TO L-O(1)
     END-EVALUATE
''')
extra+=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF7-CRYSTAL-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-OG                  BINARY-LONG.
 01 WS-IG                  BINARY-LONG.
 01 WS-CUBE                BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-K                   FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG VALUE 0.70710677.
 01 WS-Y                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-A.
    05 WS-AV               FLOAT-LONG OCCURS 9 TIMES.
 01 WS-Y9.
    05 WS-YV               FLOAT-LONG OCCURS 9 TIMES.
 01 WS-Q1.
    05 WS-Q1V              FLOAT-LONG OCCURS 9 TIMES.
 01 WS-Q2.
    05 WS-Q2V              FLOAT-LONG OCCURS 9 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-EIN.
    05 WS-EI               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-EOUT.
    05 WS-EO               FLOAT-LONG OCCURS 64 TIMES.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "outer_glass" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-OG
     MOVE "inner_glass" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-IG
     MOVE "cube" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-CUBE
     MOVE "base" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-BASE
     MOVE 0 TO MM-VISIBLE(WS-BASE)
     IF L-I(2) NOT = 0
         MOVE 1 TO MM-VISIBLE(WS-BASE)
     END-IF
     COMPUTE WS-F = FUNCTION SIN(0.2 * L-I(1)) / 2 + 0.5
     COMPUTE WS-F = (WS-F * WS-F + WS-F) * 0.4
     COMPUTE MM-CY(WS-OG) = MM-CY(WS-OG) + (WS-F - 1.4) * 16 / 2
     COMPUTE WS-R = L-I(1) * 3 * 0.017453292
     COMPUTE WS-C = FUNCTION COS(1.0471976)
     COMPUTE WS-S = FUNCTION SIN(1.0471976)
     COMPUTE WS-K = 1 - WS-C
     COMPUTE WS-AV(1) = WS-C + WS-AX * WS-AX * WS-K
     COMPUTE WS-AV(2) = 0 - WS-AX * WS-S
     COMPUTE WS-AV(3) = WS-AX * WS-AX * WS-K
     COMPUTE WS-AV(4) = WS-AX * WS-S
     MOVE WS-C TO WS-AV(5)
     COMPUTE WS-AV(6) = 0 - WS-AX * WS-S
     COMPUTE WS-AV(7) = WS-AX * WS-AX * WS-K
     COMPUTE WS-AV(8) = WS-AX * WS-S
     COMPUTE WS-AV(9) = WS-C + WS-AX * WS-AX * WS-K
     COMPUTE WS-YV(1) = FUNCTION COS(WS-R)
     MOVE 0 TO WS-YV(2)
     COMPUTE WS-YV(3) = FUNCTION SIN(WS-R)
     MOVE 0 TO WS-YV(4)
     MOVE 1 TO WS-YV(5)
     MOVE 0 TO WS-YV(6)
     COMPUTE WS-YV(7) = 0 - FUNCTION SIN(WS-R)
     MOVE 0 TO WS-YV(8)
     COMPUTE WS-YV(9) = FUNCTION COS(WS-R)
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
         PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 2
             COMPUTE WS-N = WS-I * 3 + WS-J + 1
             COMPUTE WS-Q1V(WS-N) = WS-YV(WS-I * 3 + 1) * WS-AV(WS-J + 1) + WS-YV(WS-I * 3 + 2) * WS-AV(WS-J + 4) + WS-YV(WS-I * 3 + 3) * WS-AV(WS-J + 7)
             COMPUTE WS-Q2V(WS-N) = WS-AV(WS-I * 3 + 1) * WS-YV(WS-J + 1) + WS-AV(WS-I * 3 + 2) * WS-YV(WS-J + 4) + WS-AV(WS-I * 3 + 3) * WS-YV(WS-J + 7)
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE WS-Q1V(WS-I) TO WS-EI(WS-I)
     END-PERFORM
     CALL "EF7-MAT-EULER" USING WS-EIN WS-EOUT
     MOVE WS-EO(1) TO MM-CXROT(WS-OG)
     MOVE WS-EO(2) TO MM-CYROT(WS-OG)
     MOVE WS-EO(3) TO MM-CZROT(WS-OG)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE WS-Q2V(WS-I) TO WS-EI(WS-I)
     END-PERFORM
     CALL "EF7-MAT-EULER" USING WS-EIN WS-EOUT
     MOVE WS-EO(1) TO MM-CXROT(WS-IG) MM-CXROT(WS-CUBE)
     MOVE WS-EO(2) TO MM-CYROT(WS-IG) MM-CYROT(WS-CUBE)
     MOVE WS-EO(3) TO MM-CZROT(WS-IG) MM-CZROT(WS-CUBE)
     GOBACK.
 END PROGRAM EF7-CRYSTAL-ANIM.

'''
extra+=prog('EF7-MAT-EULER','''     MOVE L-I(8) TO WS-AI(1)
     MOVE L-I(9) TO WS-AI(2)
     CALL "EF7-ATAN2" USING WS-IN2 WS-OUT2
     MOVE WS-OV(1) TO L-O(1)
     COMPUTE WS-S = 0 - L-I(7)
     IF WS-S > 1
         MOVE 1 TO WS-S
     END-IF
     IF WS-S < -1
         MOVE -1 TO WS-S
     END-IF
     COMPUTE L-O(2) = FUNCTION ASIN(WS-S)
     MOVE L-I(4) TO WS-AI(1)
     MOVE L-I(1) TO WS-AI(2)
     CALL "EF7-ATAN2" USING WS-IN2 WS-OUT2
     MOVE WS-OV(1) TO L-O(3)
''',' 01 WS-S                   FLOAT-LONG.\n 01 WS-IN2.\n    05 WS-AI               FLOAT-LONG OCCURS 16 TIMES.\n 01 WS-OUT2.\n    05 WS-OV               FLOAT-LONG OCCURS 64 TIMES.\n')
extra+=prog('EF7-CRYSTAL-BEAM','''     COMPUTE WS-F = FUNCTION SIN(0.2 * L-I(4)) / 2 + 0.5
     COMPUTE WS-F = (WS-F * WS-F + WS-F) * 0.4
     MOVE L-I(1) TO L-O(1) 
     MOVE L-I(2) TO L-O(2)
     MOVE L-I(3) TO L-O(3)
     COMPUTE L-O(4) = 0 - L-I(1)
     COMPUTE L-O(5) = 0 - L-I(2) + WS-F - 1.4
     COMPUTE L-O(6) = 0 - L-I(3)
''',' 01 WS-F                   FLOAT-LONG.\n')
extra+=prog('EF7-CRYSTAL-RENDER','     MOVE 0.5 TO L-O(1)\n     MOVE 2 TO L-O(2) L-O(3) L-O(4)\n     MOVE 0 TO L-O(5) L-O(7)\n     MOVE -0.5 TO L-O(6)\n')
extra+=prog('EF7-CRYSTAL-SHOULD','     MOVE 0 TO L-O(1)\n     IF L-I(1) NOT = 0 OR L-I(2) NOT = 0\n         MOVE 1 TO L-O(1)\n     END-IF\n')
extra+=' IDENTIFICATION DIVISION.\n PROGRAM-ID. EF7-CRYSTAL-TEXTURE.\n DATA DIVISION.\n LINKAGE SECTION.\n 01 L-IN.\n    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.\n 01 L-PATH                 PIC X(120).\n PROCEDURE DIVISION USING L-IN L-PATH.\n     IF L-I(1) NOT = 0\n         MOVE "textures/entity/end_crystal/end_crystal_beam.png" TO L-PATH\n     ELSE\n         MOVE "textures/entity/end_crystal/end_crystal.png" TO L-PATH\n     END-IF\n     GOBACK.\n END PROGRAM EF7-CRYSTAL-TEXTURE.\n\n'
write_section_src(7,hdr,['END_CRYSTAL'],extra); write_layers(['END_CRYSTAL'])
