from mesh6 import *
from prog6 import *
SH=doc6.rows_from(6,'### 12.1')
setlayer('SHULKER',SH,64,64); setlayer('SHULKER_BOX',[r for r in SH if r.split()[1] in ('lid','base')],64,64)
hdr='''*> Entity models part 6 section 12 (Shulker): the SHULKER and SHULKER_BOX meshes (12.1), setupAnim (12.2), render offset, peek amount, attach face rotation, body rotation, dye textures and the cull box (12.3).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF6-SHULKER-ANIM EMM-MODEL state(1 xRot, 2 yHeadRot, 3 yBodyRot, 4 peekAmount, 5 ageInTicks): reset first, lid position and turn, head look; EF6-SHULKER-OFFSET IN(has old attach position, teleport interpolation, partial, scale, delta x y z (block - old block)) OUT(x y z);
*>   EF6-SHULKER-PEEK IN(current peek, raw data byte) OUT(new peek); EF6-SHULKER-ROT IN(attach face 0 DOWN 1 UP 2 NORTH 3 SOUTH 4 WEST 5 EAST) OUT(rotationXYZ x y z in radians, pivot x y z): the rotation of the opposite face about (0, 0.5, 0);
*>   EF6-SHULKER-BODYROT IN(bodyRot degrees) OUT(bodyRot + 180); EF6-SHULKER-TEXTURE IN(dye id 0 to 15, 16 none) path(out X(120)); EF6-SHULKER-CULLBOX IN(has render position, render x y z, block x y z, entity height, entity width) OUT(candidate, min xyz, max xyz).
'''
names=['white','orange','magenta','light_blue','yellow','lime','pink','gray','light_gray','cyan','purple','blue','brown','green','red','black']
rot=[(0,0,0),(3.1415927,0,0),(1.5707964,0,0),(1.5707964,0,3.1415927),(1.5707964,0,-1.5707964),(1.5707964,0,1.5707964)]
rb=''
for i,(x,y,z) in enumerate(rot): rb+='         WHEN %d\n             MOVE %s TO L-O(1)\n             MOVE %s TO L-O(2)\n             MOVE %s TO L-O(3)\n'%(i,x,y,z)
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-SHULKER-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-LID                 BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-F2                  FLOAT-LONG.
 01 WS-F3                  FLOAT-LONG.
 01 WS-F4                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "lid" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-LID
     MOVE "head" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-HEAD
     COMPUTE WS-F2 = (0.5 + L-I(4)) * 3.1415927
     COMPUTE WS-F3 = -1 + FUNCTION SIN(WS-F2)
     MOVE 0 TO WS-F4
     IF WS-F2 > 3.1415927
         COMPUTE WS-F4 = FUNCTION SIN(L-I(5) * 0.1) * 0.7
     END-IF
     MOVE 0 TO MM-CX(WS-LID) MM-CZ(WS-LID)
     COMPUTE MM-CY(WS-LID) = 16 + FUNCTION SIN(WS-F2) * 8 + WS-F4
     MOVE 0 TO MM-CYROT(WS-LID)
     IF L-I(4) > 0.3
         COMPUTE MM-CYROT(WS-LID) = (WS-F3 * WS-F3 * WS-F3 * WS-F3) * 3.1415927 * 0.125
     END-IF
     COMPUTE MM-CXROT(WS-HEAD) = L-I(1) * 0.017453292
     COMPUTE MM-CYROT(WS-HEAD) = ((L-I(2) - 180) - L-I(3)) * 0.017453292
     GOBACK.
 END PROGRAM EF6-SHULKER-ANIM.

'''
extra+=prog('EF6-SHULKER-OFFSET','''     MOVE 0 TO L-O(1) L-O(2) L-O(3)
     IF L-I(1) NOT = 0 AND L-I(2) > 0
         COMPUTE WS-E = ((L-I(2) - L-I(3)) / 6) * ((L-I(2) - L-I(3)) / 6) * L-I(4)
         COMPUTE L-O(1) = 0 - WS-E * L-I(5)
         COMPUTE L-O(2) = 0 - WS-E * L-I(6)
         COMPUTE L-O(3) = 0 - WS-E * L-I(7)
     END-IF
''',' 01 WS-E                   FLOAT-LONG.\n')
extra+=prog('EF6-SHULKER-PEEK','''     COMPUTE WS-T = L-I(2) * 0.01
     MOVE L-I(1) TO L-O(1)
     IF L-I(1) > WS-T
         COMPUTE L-O(1) = L-I(1) - 0.05
         IF L-O(1) < WS-T
             MOVE WS-T TO L-O(1)
         END-IF
         IF L-O(1) > 1
             MOVE 1 TO L-O(1)
         END-IF
     END-IF
     IF L-I(1) < WS-T
         COMPUTE L-O(1) = L-I(1) + 0.05
         IF L-O(1) > WS-T
             MOVE WS-T TO L-O(1)
         END-IF
         IF L-O(1) < 0
             MOVE 0 TO L-O(1)
         END-IF
     END-IF
''',' 01 WS-T                   FLOAT-LONG.\n')
extra+=prog('EF6-SHULKER-ROT','''     MOVE 0 TO L-O(1) L-O(2) L-O(3) L-O(4) L-O(6)
     MOVE 0.5 TO L-O(5)
     EVALUATE L-I(1)
'''+rb+'''     END-EVALUATE
''')
extra+=prog('EF6-SHULKER-BODYROT','     COMPUTE L-O(1) = L-I(1) + 180\n')
names_tab=''
for i,n in enumerate(names): names_tab+='         WHEN %d\n             MOVE "textures/entity/shulker/shulker_%s.png" TO L-PATH\n'%(i,n)
extra+=' IDENTIFICATION DIVISION.\n PROGRAM-ID. EF6-SHULKER-TEXTURE.\n DATA DIVISION.\n LINKAGE SECTION.\n 01 L-IN.\n    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.\n 01 L-PATH                 PIC X(120).\n PROCEDURE DIVISION USING L-IN L-PATH.\n     EVALUATE L-I(1)\n'+names_tab+'         WHEN OTHER\n             MOVE "textures/entity/shulker/shulker.png" TO L-PATH\n     END-EVALUATE\n     GOBACK.\n END PROGRAM EF6-SHULKER-TEXTURE.\n\n'
extra+=prog('EF6-SHULKER-CULLBOX','''     MOVE 0 TO L-O(1) L-O(2) L-O(3) L-O(4) L-O(5) L-O(6) L-O(7)
     IF L-I(1) NOT = 0
         MOVE 1 TO L-O(1)
         COMPUTE WS-AY = L-I(3) + L-I(8) / 2
         COMPUTE WS-BX = L-I(5) + 0.5
         COMPUTE WS-BY = L-I(6) + L-I(8) / 2
         COMPUTE WS-BZ = L-I(7) + 0.5
         MOVE L-I(2) TO L-O(2)
         IF WS-BX < L-O(2)
             MOVE WS-BX TO L-O(2)
         END-IF
         MOVE WS-AY TO L-O(3)
         IF WS-BY < L-O(3)
             MOVE WS-BY TO L-O(3)
         END-IF
         MOVE L-I(4) TO L-O(4)
         IF WS-BZ < L-O(4)
             MOVE WS-BZ TO L-O(4)
         END-IF
         MOVE L-I(2) TO L-O(5)
         IF WS-BX > L-O(5)
             MOVE WS-BX TO L-O(5)
         END-IF
         MOVE WS-AY TO L-O(6)
         IF WS-BY > L-O(6)
             MOVE WS-BY TO L-O(6)
         END-IF
         MOVE L-I(4) TO L-O(7)
         IF WS-BZ > L-O(7)
             MOVE WS-BZ TO L-O(7)
         END-IF
         COMPUTE L-O(2) = L-O(2) - L-I(9) / 2
         COMPUTE L-O(3) = L-O(3) - L-I(8) / 2
         COMPUTE L-O(4) = L-O(4) - L-I(9) / 2
         COMPUTE L-O(5) = L-O(5) + L-I(9) / 2
         COMPUTE L-O(6) = L-O(6) + L-I(8) / 2
         COMPUTE L-O(7) = L-O(7) + L-I(9) / 2
     END-IF
''',' 01 WS-AY                  FLOAT-LONG.\n 01 WS-BX                  FLOAT-LONG.\n 01 WS-BY                  FLOAT-LONG.\n 01 WS-BZ                  FLOAT-LONG.\n')
write_section_src(12,hdr,['SHULKER','SHULKER_BOX'],extra); write_layers(['SHULKER','SHULKER_BOX'])
