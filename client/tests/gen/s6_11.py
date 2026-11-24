from guard6 import *
from prog6 import *
define()
hdr='''*> Entity models part 6 section 11 (Guardian and elder guardian): the mesh and the elder layer (11.1), the twelve spikes (11.2), setupAnim (11.3), the client animation values and attack timing (11.4), textures and cull box (11.5), the beam (11.6) and the apparition particle (11.7).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF6-GUARDIAN-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 spikesAnimation, 4 ageInTicks, 5 tailAnimation, 6 look target present (lookAtPosition and lookDirection both set), 7 lookAtPosition y, 8 eyePosition y, 9 lookDirection x, 10 lookDirection z,
*>   11 eyePosition x, 12 eyePosition z, 13 lookAtPosition x, 14 lookAtPosition z): reset first, head look, spikes, eye, tail; EF6-GUARDIAN-TICK IN(in water, moving, tail speed, tail, spikes, random float) OUT(old tail, tail, tail speed, old spikes, spikes);
*>   EF6-GUARDIAN-LERP IN(partial, old, current) OUT(value); EF6-GUARDIAN-DURATION IN(elder) OUT(attack duration ticks); EF6-GUARDIAN-ATTACK IN(partial, clientSideAttackTime, duration) OUT(attackScale, attackTime); EF6-GUARDIAN-ATTACK-TICK IN(attack time, has target, duration) OUT(attack time);
*>   EF6-GUARDIAN-TEXTURE IN(0 guardian 1 elder 2 beam) path(out X(120)); EF6-GUARDIAN-CULLBOX IN(eye x y z, target x y z, target bounding height) OUT(min xyz, max xyz); EF6-GUARDIAN-BEAM-COLOR IN(attackScale) OUT(red, green, blue);
*>   EF6-GUARDIAN-BEAM IN(delta x y z, attackTime) OUT(L, rotate Y degrees, rotate X degrees, th, ph); EF6-GUARDIAN-BEAM-QUADS IN(th, L, attackTime) OUT(12 vertices x y z u v); EF6-ELDER-PARTICLE IN(age, partial) OUT(alpha, op count, then ops: code 6 rotate X degrees, 2 scale, 1 translate; the camera rotation is applied first by the caller).
*>   The rotation of the look vector about Y by pi/2 is the standard right-handed one (x cos + z sin, z cos - x sin); a zero-length horizontal offset gives d = 0 (the documents do not state this guard).
'''
sp=''
for i,(xr,yr,zr,sx,sy,sz) in enumerate(SP): sp+='         WHEN %d\n             MOVE %s TO WS-SX\n             MOVE %s TO WS-SY\n             MOVE %s TO WS-SZ\n'%(i,sx,sy,sz)
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-GUARDIAN-ANIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-DIG                 PIC 99.
 01 WS-H                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-EYE                 BINARY-LONG.
 01 WS-T0                  BINARY-LONG.
 01 WS-T1                  BINARY-LONG.
 01 WS-T2                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   FLOAT-LONG.
 01 WS-O                   FLOAT-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-LN                  FLOAT-LONG.
 01 WS-RX                  FLOAT-LONG.
 01 WS-RZ                  FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
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
     COMPUTE WS-E = (1 - L-I(3)) * 0.55
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 11
         MOVE WS-I TO WS-DIG
         MOVE SPACES TO WS-NAME
         IF WS-I < 10
             STRING "spike" WS-DIG(2:1) DELIMITED BY SIZE INTO WS-NAME
         ELSE
             STRING "spike" WS-DIG DELIMITED BY SIZE INTO WS-NAME
         END-IF
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
         EVALUATE WS-I
'''+sp+r'''         END-EVALUATE
         COMPUTE WS-O = 1 + FUNCTION COS(L-I(4) * 1.5 + WS-I) * 0.01 - WS-E
         COMPUTE MM-CX(WS-P) = WS-SX * WS-O
         COMPUTE MM-CY(WS-P) = 16 + WS-SY * WS-O
         COMPUTE MM-CZ(WS-P) = WS-SZ * WS-O
     END-PERFORM
     IF L-I(6) NOT = 0
         MOVE "eye" TO WS-NAME
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-EYE
         IF L-I(7) - L-I(8) > 0
             MOVE 0 TO MM-CY(WS-EYE)
         ELSE
             MOVE 1 TO MM-CY(WS-EYE)
         END-IF
         COMPUTE WS-VX = L-I(11) - L-I(13)
         COMPUTE WS-VZ = L-I(12) - L-I(14)
         COMPUTE WS-LN = FUNCTION SQRT(WS-VX * WS-VX + WS-VZ * WS-VZ)
         MOVE 0 TO WS-D
         IF WS-LN >= 0.00001
             COMPUTE WS-VX = WS-VX / WS-LN
             COMPUTE WS-VZ = WS-VZ / WS-LN
             COMPUTE WS-RX = WS-VX * FUNCTION COS(1.5707964) + WS-VZ * FUNCTION SIN(1.5707964)
             COMPUTE WS-RZ = WS-VZ * FUNCTION COS(1.5707964) - WS-VX * FUNCTION SIN(1.5707964)
             COMPUTE WS-D = L-I(9) * WS-RX + L-I(10) * WS-RZ
         END-IF
         MOVE 0 TO MM-CX(WS-EYE)
         IF WS-D > 0
             COMPUTE MM-CX(WS-EYE) = FUNCTION SQRT(WS-D) * 2
         END-IF
         IF WS-D < 0
             COMPUTE MM-CX(WS-EYE) = 0 - FUNCTION SQRT(0 - WS-D) * 2
         END-IF
     END-IF
     MOVE "tail0" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-T0
     MOVE "tail1" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-T1
     MOVE "tail2" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-T2
     COMPUTE WS-S = FUNCTION SIN(L-I(5))
     COMPUTE MM-CYROT(WS-T0) = WS-S * 3.141592653589793 * 0.05
     COMPUTE MM-CYROT(WS-T1) = WS-S * 3.141592653589793 * 0.1
     COMPUTE MM-CYROT(WS-T2) = WS-S * 3.141592653589793 * 0.15
     GOBACK.
 END PROGRAM EF6-GUARDIAN-ANIM.

'''
extra+=prog('EF6-GUARDIAN-TICK','''     MOVE L-I(4) TO L-O(1)
     MOVE L-I(3) TO L-O(3)
     IF L-I(1) = 0
         MOVE 2 TO L-O(3)
     ELSE
         IF L-I(2) NOT = 0
             IF L-I(3) < 0.5
                 MOVE 4 TO L-O(3)
             ELSE
                 COMPUTE L-O(3) = L-I(3) + (0.5 - L-I(3)) * 0.1
             END-IF
         ELSE
             COMPUTE L-O(3) = L-I(3) + (0.125 - L-I(3)) * 0.2
         END-IF
     END-IF
     COMPUTE L-O(2) = L-I(4) + L-O(3)
     MOVE L-I(5) TO L-O(4)
     IF L-I(1) = 0
         MOVE L-I(6) TO L-O(5)
     ELSE
         IF L-I(2) NOT = 0
             COMPUTE L-O(5) = L-I(5) + (0 - L-I(5)) * 0.25
         ELSE
             COMPUTE L-O(5) = L-I(5) + (1 - L-I(5)) * 0.06
         END-IF
     END-IF
''')
extra+=prog('EF6-GUARDIAN-LERP','     COMPUTE L-O(1) = L-I(2) + L-I(1) * (L-I(3) - L-I(2))\n')
extra+=prog('EF6-GUARDIAN-DURATION','''     MOVE 80 TO L-O(1)
     IF L-I(1) NOT = 0
         MOVE 60 TO L-O(1)
     END-IF
''')
extra+=prog('EF6-GUARDIAN-ATTACK','''     COMPUTE L-O(1) = (L-I(2) + L-I(1)) / L-I(3)
     COMPUTE L-O(2) = L-I(2) + L-I(1)
''')
extra+=prog('EF6-GUARDIAN-ATTACK-TICK','''     MOVE L-I(1) TO L-O(1)
     IF L-I(2) NOT = 0 AND L-I(1) < L-I(3)
         COMPUTE L-O(1) = L-I(1) + 1
     END-IF
''')
extra+=pathprog('EF6-GUARDIAN-TEXTURE',[('1','textures/entity/guardian/guardian_elder.png'),('2','textures/entity/guardian/guardian_beam.png')],default='textures/entity/guardian/guardian.png')
extra+=prog('EF6-GUARDIAN-CULLBOX','''     COMPUTE WS-CY = L-I(5) + 0.5 * L-I(7)
     MOVE L-I(1) TO L-O(1)
     IF L-I(4) < L-O(1)
         MOVE L-I(4) TO L-O(1)
     END-IF
     MOVE L-I(2) TO L-O(2)
     IF WS-CY < L-O(2)
         MOVE WS-CY TO L-O(2)
     END-IF
     MOVE L-I(3) TO L-O(3)
     IF L-I(6) < L-O(3)
         MOVE L-I(6) TO L-O(3)
     END-IF
     MOVE L-I(1) TO L-O(4)
     IF L-I(4) > L-O(4)
         MOVE L-I(4) TO L-O(4)
     END-IF
     MOVE L-I(2) TO L-O(5)
     IF WS-CY > L-O(5)
         MOVE WS-CY TO L-O(5)
     END-IF
     MOVE L-I(3) TO L-O(6)
     IF L-I(6) > L-O(6)
         MOVE L-I(6) TO L-O(6)
     END-IF
''',' 01 WS-CY                  FLOAT-LONG.\n')
extra+=prog('EF6-GUARDIAN-BEAM-COLOR','''     COMPUTE WS-C = L-I(1) * L-I(1)
     COMPUTE L-O(1) = 64 + FUNCTION INTEGER-PART(WS-C * 191)
     COMPUTE L-O(2) = 32 + FUNCTION INTEGER-PART(WS-C * 191)
     COMPUTE L-O(3) = 128 - FUNCTION INTEGER-PART(WS-C * 64)
''',' 01 WS-C                   FLOAT-LONG.\n')
extra+=prog('EF6-GUARDIAN-BEAM','''     COMPUTE WS-LEN = FUNCTION SQRT(L-I(1) * L-I(1) + L-I(2) * L-I(2) + L-I(3) * L-I(3))
     COMPUTE L-O(1) = WS-LEN + 1
     COMPUTE WS-NY = L-I(2) / WS-LEN
     COMPUTE WS-A = FUNCTION ACOS(WS-NY)
     EVALUATE TRUE
         WHEN L-I(1) > 0
             COMPUTE WS-AT = FUNCTION ATAN(L-I(3) / L-I(1))
         WHEN L-I(1) < 0
             COMPUTE WS-AT = FUNCTION ATAN(L-I(3) / L-I(1))
             IF L-I(3) >= 0
                 COMPUTE WS-AT = WS-AT + 3.141592653589793
             ELSE
                 COMPUTE WS-AT = WS-AT - 3.141592653589793
             END-IF
         WHEN L-I(3) > 0
             MOVE 1.5707963267948966 TO WS-AT
         WHEN L-I(3) < 0
             MOVE -1.5707963267948966 TO WS-AT
         WHEN OTHER
             MOVE 0 TO WS-AT
     END-EVALUATE
     COMPUTE WS-B = 1.5707963267948966 - WS-AT
     COMPUTE L-O(2) = WS-B * 57.295776
     COMPUTE L-O(3) = WS-A * 57.295776
     COMPUTE L-O(4) = L-I(4) * 0.05 * -1.5
     COMPUTE L-O(5) = FUNCTION MOD(L-I(4) * 0.5, 1)
''',' 01 WS-LEN                 FLOAT-LONG.\n 01 WS-NY                  FLOAT-LONG.\n 01 WS-A                   FLOAT-LONG.\n 01 WS-B                   FLOAT-LONG.\n 01 WS-AT                  FLOAT-LONG.\n')
import guardquads6
write_section_src(11,hdr,['GUARDIAN'],extra+'\n'+guardquads6.build()); write_layers(['GUARDIAN','ELDER_GUARDIAN'])
