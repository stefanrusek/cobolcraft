from mesh6 import *
from prog6 import *
setlayer('PHANTOM',doc6.rows_from(6,'### 10.1'),64,64)
hdr='''*> Entity models part 6 section 10 (Phantom): the mesh (10.1), the wing flap and tail of setupAnim (10.2), flap time, size scale, pitch rotation and textures (10.3).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)): ops lists are count, then code (1 translate, 2 scale, 6 rotate X degrees) and three values per op in call order.
*>   EF6-PHANTOM-ANIM EMM-MODEL state(1 flapTime): reset first, wings and tail from t = flapTime x 7.448451 x 0.017453292; EF6-PHANTOM-FLAP IN(network id, ageInTicks) OUT(flapTime = id x 3 + age);
*>   EF6-PHANTOM-SCALE-OPS IN(size) OUT(ops: scale 1 + 0.15 size, translate (0, 1.3125, 0.1875)); EF6-PHANTOM-ROT-OPS IN(xRot degrees) OUT(ops); EF6-PHANTOM-TEXTURE IN(eyes) path(out X(120)).
'''
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-PHANTOM-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-LB                  BINARY-LONG.
 01 WS-LT                  BINARY-LONG.
 01 WS-RB                  BINARY-LONG.
 01 WS-RT                  BINARY-LONG.
 01 WS-TB                  BINARY-LONG.
 01 WS-TT                  BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "left_wing_base" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LB
     MOVE "left_wing_tip" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LT
     MOVE "right_wing_base" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RB
     MOVE "right_wing_tip" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-RT
     MOVE "tail_base" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-TB
     MOVE "tail_tip" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-TT
     COMPUTE WS-T = L-I(1) * 7.448451 * 0.017453292
     COMPUTE MM-CZROT(WS-LB) = FUNCTION COS(WS-T) * 16 * 0.017453292
     MOVE MM-CZROT(WS-LB) TO MM-CZROT(WS-LT)
     COMPUTE MM-CZROT(WS-RB) = 0 - MM-CZROT(WS-LB)
     COMPUTE MM-CZROT(WS-RT) = 0 - MM-CZROT(WS-LT)
     COMPUTE MM-CXROT(WS-TB) = 0 - (5 + FUNCTION COS(2 * WS-T) * 5) * 0.017453292
     MOVE MM-CXROT(WS-TB) TO MM-CXROT(WS-TT)
     GOBACK.
 END PROGRAM EF6-PHANTOM-ANIM.

'''
extra+=prog('EF6-PHANTOM-FLAP','     COMPUTE L-O(1) = L-I(1) * 3 + L-I(2)\n')
extra+=prog('EF6-PHANTOM-SCALE-OPS','''     COMPUTE WS-S = 1 + 0.15 * L-I(1)
     MOVE 2 TO L-O(1) L-O(2)
     MOVE WS-S TO L-O(3) L-O(4) L-O(5)
     MOVE 1 TO L-O(6)
     MOVE 0 TO L-O(7)
     MOVE 1.3125 TO L-O(8)
     MOVE 0.1875 TO L-O(9)
''',' 01 WS-S                   FLOAT-LONG.\n')
extra+=prog('EF6-PHANTOM-ROT-OPS','''     MOVE 1 TO L-O(1)
     MOVE 6 TO L-O(2)
     MOVE L-I(1) TO L-O(3)
     MOVE 0 TO L-O(4) L-O(5)
''')
extra+=pathprog('EF6-PHANTOM-TEXTURE',[('1','textures/entity/phantom/phantom_eyes.png')],default='textures/entity/phantom/phantom.png')
write_section_src(10,hdr,['PHANTOM'],extra); write_layers(['PHANTOM'])
