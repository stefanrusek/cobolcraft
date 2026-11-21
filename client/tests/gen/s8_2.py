from aq8 import *
from prog6 import *
define()
hdr='''*> Entity models part 8 section 2 (squid and glow squid): the adult and baby meshes (2.1; the glow squid layers reuse them), setupAnim, render state lerps, the entity tentacle and body rotation updates, setupRotations, textures and the glow squid block light (2.2).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)): ops lists are count, then code (1 translate, 3 rotate Y degrees, 6 rotate X degrees) and three values per op.
*>   EF8-SQUID-ANIM EMM-MODEL state(1 tentacleAngle): reset first, every tentacle xRot set to the angle; EF8-SQUID-STATE IN(partial, old angle, angle, old xBodyRot, xBodyRot, old zBodyRot, zBodyRot) OUT(angle, xBodyRot, zBodyRot);
*>   EF8-SQUID-TENTACLE IN(tentacleMovement, tentacleSpeed, in water, rotateSpeed) OUT(movement, angle, rotateSpeed): the client side of Squid.aiStep steps 2 to 4; EF8-SQUID-BODY IN(in water, rotateSpeed, yBodyRot, zBodyRot, xBodyRot, vx, vy, vz) OUT(yBodyRot, zBodyRot, xBodyRot);
*>   EF8-SQUID-ROT-OPS IN(bodyRot, xBodyRot, zBodyRot, baby) OUT(ops); EF8-SQUID-TEXTURE IN(glow, baby) path(out X(60), relative to textures/entity/); EF8-GLOW-LIGHT IN(dark ticks remaining, normal block light) OUT(block light).
'''
extra=r''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-SQUID-ANIM.
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
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 7
         MOVE WS-I TO WS-DIG
         MOVE SPACES TO WS-NAME
         STRING "tentacle" WS-DIG DELIMITED BY SIZE INTO WS-NAME
         CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-P
         MOVE L-I(1) TO MM-CXROT(WS-P)
     END-PERFORM
     GOBACK.
 END PROGRAM EF8-SQUID-ANIM.

'''
extra+=prog('EF8-SQUID-STATE','''     COMPUTE L-O(1) = L-I(2) + L-I(1) * (L-I(3) - L-I(2))
     COMPUTE L-O(2) = L-I(4) + L-I(1) * (L-I(5) - L-I(4))
     COMPUTE L-O(3) = L-I(6) + L-I(1) * (L-I(7) - L-I(6))
''')
extra+=prog('EF8-SQUID-TENTACLE','''     COMPUTE L-O(1) = L-I(1) + L-I(2)
     IF L-O(1) > 6.2831855
         MOVE 6.283185307179586 TO L-O(1)
     END-IF
     MOVE L-I(4) TO L-O(3)
     IF L-I(3) NOT = 0
         IF L-O(1) < 3.1415927
             COMPUTE WS-P = L-O(1) / 3.1415927
             COMPUTE L-O(2) = FUNCTION SIN(WS-P * WS-P * 3.1415927) * 3.1415927 * 0.25
             IF WS-P > 0.75
                 MOVE 1 TO L-O(3)
             ELSE
                 COMPUTE L-O(3) = L-I(4) * 0.8
             END-IF
         ELSE
             MOVE 0 TO L-O(2)
             COMPUTE L-O(3) = L-I(4) * 0.99
         END-IF
     ELSE
         COMPUTE L-O(2) = FUNCTION ABS(FUNCTION SIN(L-O(1))) * 3.1415927 * 0.25
     END-IF
''',' 01 WS-P                   FLOAT-LONG.\n')
extra+=prog('EF8-SQUID-BODY','''     MOVE L-I(3) TO L-O(1)
     MOVE L-I(4) TO L-O(2)
     MOVE L-I(5) TO L-O(3)
     IF L-I(1) NOT = 0
         MOVE L-I(6) TO WS-AI(1)
         MOVE L-I(8) TO WS-AI(2)
         CALL "EF7-ATAN2" USING WS-IN2 WS-OUT2
         COMPUTE L-O(1) = L-I(3) + (0 - WS-OV(1) * 57.295776 - L-I(3)) * 0.1
         COMPUTE L-O(2) = L-I(4) + 3.1415927 * L-I(2) * 1.5
         COMPUTE WS-H = FUNCTION SQRT(L-I(6) * L-I(6) + L-I(8) * L-I(8))
         MOVE WS-H TO WS-AI(1)
         MOVE L-I(7) TO WS-AI(2)
         CALL "EF7-ATAN2" USING WS-IN2 WS-OUT2
         COMPUTE L-O(3) = L-I(5) + (0 - WS-OV(1) * 57.295776 - L-I(5)) * 0.1
     ELSE
         COMPUTE L-O(3) = L-I(5) + (-90 - L-I(5)) * 0.02
     END-IF
''',' 01 WS-H                   FLOAT-LONG.\n 01 WS-IN2.\n    05 WS-AI               FLOAT-LONG OCCURS 16 TIMES.\n 01 WS-OUT2.\n    05 WS-OV               FLOAT-LONG OCCURS 64 TIMES.\n')
extra+=prog('EF8-SQUID-ROT-OPS','''     MOVE 5 TO L-O(1)
     MOVE 1 TO L-O(2)
     MOVE 0 TO L-O(3) L-O(5)
     MOVE 0.5 TO L-O(4)
     MOVE -1.2 TO WS-DY
     IF L-I(4) NOT = 0
         MOVE 0.25 TO L-O(4)
         MOVE -0.6 TO WS-DY
     END-IF
     MOVE 3 TO L-O(6)
     COMPUTE L-O(7) = 180 - L-I(1)
     MOVE 0 TO L-O(8) L-O(9)
     MOVE 6 TO L-O(10)
     MOVE L-I(2) TO L-O(11)
     MOVE 0 TO L-O(12) L-O(13)
     MOVE 3 TO L-O(14)
     MOVE L-I(3) TO L-O(15)
     MOVE 0 TO L-O(16) L-O(17)
     MOVE 1 TO L-O(18)
     MOVE 0 TO L-O(19) L-O(21)
     MOVE WS-DY TO L-O(20)
''',' 01 WS-DY                  FLOAT-LONG.\n')
extra+=''' IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-SQUID-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(60).
 PROCEDURE DIVISION USING L-IN L-PATH.
     EVALUATE TRUE
         WHEN L-I(1) NOT = 0 AND L-I(2) NOT = 0
             MOVE "squid/glow_squid_baby.png" TO L-PATH
         WHEN L-I(1) NOT = 0
             MOVE "squid/glow_squid.png" TO L-PATH
         WHEN L-I(2) NOT = 0
             MOVE "squid/squid_baby.png" TO L-PATH
         WHEN OTHER
             MOVE "squid/squid.png" TO L-PATH
     END-EVALUATE
     GOBACK.
 END PROGRAM EF8-SQUID-TEXTURE.

'''
extra+=prog('EF8-GLOW-LIGHT','''     COMPUTE WS-T = 1 - L-I(1) / 10
     EVALUATE TRUE
         WHEN WS-T < 0
             MOVE 0 TO WS-I
         WHEN WS-T > 1
             MOVE 15 TO WS-I
         WHEN OTHER
             COMPUTE WS-I = FUNCTION INTEGER-PART(15 * WS-T)
     END-EVALUATE
     IF WS-I = 15
         MOVE 15 TO L-O(1)
     ELSE
         MOVE WS-I TO L-O(1)
         IF L-I(2) > L-O(1)
             MOVE L-I(2) TO L-O(1)
         END-IF
     END-IF
''',' 01 WS-T                   FLOAT-LONG.\n 01 WS-I                   BINARY-LONG.\n')
write_section_src(2,hdr,['SQUID','SQUID_BABY'],extra); write_layers(['SQUID','SQUID_BABY','GLOW_SQUID','GLOW_SQUID_BABY'])
