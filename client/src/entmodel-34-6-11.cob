*> Entity models part 6 section 11 (Guardian and elder guardian): the mesh and the elder layer (11.1), the twelve spikes (11.2), setupAnim (11.3), the client animation values and attack timing (11.4), textures and cull box (11.5), the beam (11.6) and the apparition particle (11.7).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)):
*>   EF6-GUARDIAN-ANIM EMM-MODEL state(1 xRot, 2 yRot degrees, 3 spikesAnimation, 4 ageInTicks, 5 tailAnimation, 6 look target present (lookAtPosition and lookDirection both set), 7 lookAtPosition y, 8 eyePosition y, 9 lookDirection x, 10 lookDirection z,
*>   11 eyePosition x, 12 eyePosition z, 13 lookAtPosition x, 14 lookAtPosition z): reset first, head look, spikes, eye, tail; EF6-GUARDIAN-TICK IN(in water, moving, tail speed, tail, spikes, random float) OUT(old tail, tail, tail speed, old spikes, spikes);
*>   EF6-GUARDIAN-LERP IN(partial, old, current) OUT(value); EF6-GUARDIAN-DURATION IN(elder) OUT(attack duration ticks); EF6-GUARDIAN-ATTACK IN(partial, clientSideAttackTime, duration) OUT(attackScale, attackTime); EF6-GUARDIAN-ATTACK-TICK IN(attack time, has target, duration) OUT(attack time);
*>   EF6-GUARDIAN-TEXTURE IN(0 guardian 1 elder 2 beam) path(out X(120)); EF6-GUARDIAN-CULLBOX IN(eye x y z, target x y z, target bounding height) OUT(min xyz, max xyz); EF6-GUARDIAN-BEAM-COLOR IN(attackScale) OUT(red, green, blue);
*>   EF6-GUARDIAN-BEAM IN(delta x y z, attackTime) OUT(L, rotate Y degrees, rotate X degrees, th, ph); EF6-GUARDIAN-BEAM-QUADS IN(th, L, attackTime) OUT(12 vertices x y z u v); EF6-ELDER-PARTICLE IN(age, partial) OUT(alpha, op count, then ops: code 6 rotate X degrees, 2 scale, 1 translate; the camera rotation is applied first by the caller).
*>   The rotation of the look vector about Y by pi/2 is the standard right-handed one (x cos + z sin, z cos - x sin); a zero-length horizontal offset gives d = 0 (the documents do not state this guard).


 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-M-GUARDIAN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(100) VALUE "P head root 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 0 -6 10 -8 12 12 16 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 28 -8 10 -6 2 12 12 0 0".
    05 FILLER PIC X(100) VALUE "C head 0 28 6 10 -6 2 12 12 0 1".
    05 FILLER PIC X(100) VALUE "C head 16 40 -6 8 -6 12 2 12 0 0".
    05 FILLER PIC X(100) VALUE "C head 16 40 -6 22 -6 12 2 12 0 0".
    05 FILLER PIC X(100) VALUE "P spike0 head 0.0 7.92 8.08 5.497787144 0.0 0.0".
    05 FILLER PIC X(100) VALUE "C spike0 0 0 -1 -4.5 -1 2 9 2 0 0".
    05 FILLER PIC X(100) VALUE "P spike1 head 0.0 7.956775816 -8.043224184 0.785398163 0.0 0.0".
    05 FILLER PIC X(100) VALUE "C spike1 0 0 -1 -4.5 -1 2 9 2 0 0".
    05 FILLER PIC X(100) VALUE "P spike2 head 7.966708253 8.033291747 0.0 0.0 0.0 0.785398163".
    05 FILLER PIC X(100) VALUE "C spike2 0 0 -1 -4.5 -1 2 9 2 0 0".
    05 FILLER PIC X(100) VALUE "P spike3 head -7.9208006 8.0791994 0.0 0.0 0.0 5.497787144".
    05 FILLER PIC X(100) VALUE "C spike3 0 0 -1 -4.5 -1 2 9 2 0 0".
    05 FILLER PIC X(100) VALUE "P spike4 head -7.94770851 16.0 -7.94770851 1.570796327 0.785398163 0.0".
    05 FILLER PIC X(100) VALUE "C spike4 0 0 -1 -4.5 -1 2 9 2 0 0".
    05 FILLER PIC X(100) VALUE "P spike5 head 8.022692975 16.0 -8.022692975 1.570796327 5.497787144 0.0".
    05 FILLER PIC X(100) VALUE "C spike5 0 0 -1 -4.5 -1 2 9 2 0 0".
    05 FILLER PIC X(100) VALUE "P spike6 head 8.076813623 16.0 8.076813623 1.570796327 3.926990817 0.0".
    05 FILLER PIC X(100) VALUE "C spike6 0 0 -1 -4.5 -1 2 9 2 0 0".
    05 FILLER PIC X(100) VALUE "P spike7 head -8.06031218 16.0 8.06031218 1.570796327 2.35619449 0.0".
    05 FILLER PIC X(100) VALUE "C spike7 0 0 -1 -4.5 -1 2 9 2 0 0".
    05 FILLER PIC X(100) VALUE "P spike8 head 0.0 23.988359997 7.988359997 3.926990817 0.0 0.0".
    05 FILLER PIC X(100) VALUE "C spike8 0 0 -1 -4.5 -1 2 9 2 0 0".
    05 FILLER PIC X(100) VALUE "P spike9 head 0.0 23.927109579 -7.927109579 2.35619449 0.0 0.0".
    05 FILLER PIC X(100) VALUE "C spike9 0 0 -1 -4.5 -1 2 9 2 0 0".
    05 FILLER PIC X(100) VALUE "P spike10 head 7.932874278 23.932874278 0.0 0.0 0.0 2.35619449".
    05 FILLER PIC X(100) VALUE "C spike10 0 0 -1 -4.5 -1 2 9 2 0 0".
    05 FILLER PIC X(100) VALUE "P spike11 head -8.000354056 24.000354056 0.0 0.0 0.0 3.926990817".
    05 FILLER PIC X(100) VALUE "C spike11 0 0 -1 -4.5 -1 2 9 2 0 0".
    05 FILLER PIC X(100) VALUE "P eye head 0 0 -8.25 0 0 0".
    05 FILLER PIC X(100) VALUE "C eye 8 0 -1 15 0 2 2 1 0 0".
    05 FILLER PIC X(100) VALUE "P tail0 head 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C tail0 40 0 -2 14 7 4 4 8 0 0".
    05 FILLER PIC X(100) VALUE "P tail1 tail0 -1.5 0.5 14 0 0 0".
    05 FILLER PIC X(100) VALUE "C tail1 0 54 0 14 0 3 3 7 0 0".
    05 FILLER PIC X(100) VALUE "P tail2 tail1 0.5 0.5 6 0 0 0".
    05 FILLER PIC X(100) VALUE "C tail2 41 32 0 14 0 2 2 6 0 0".
    05 FILLER PIC X(100) VALUE "C tail2 25 19 1 10.5 3 1 9 9 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 41 TIMES.
 01 WS-ROWS-R REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(100) OCCURS 80 TIMES.
 01 WS-N                   BINARY-LONG VALUE 39.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS-R WS-N WS-ZERO
     MOVE 64 TO MM-TEXW
     MOVE 64 TO MM-TEXH
     GOBACK.
 END PROGRAM EF6-M-GUARDIAN.

 IDENTIFICATION DIVISION.
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
         WHEN 0
             MOVE 0 TO WS-SX
             MOVE -8 TO WS-SY
             MOVE 8 TO WS-SZ
         WHEN 1
             MOVE 0 TO WS-SX
             MOVE -8 TO WS-SY
             MOVE -8 TO WS-SZ
         WHEN 2
             MOVE 8 TO WS-SX
             MOVE -8 TO WS-SY
             MOVE 0 TO WS-SZ
         WHEN 3
             MOVE -8 TO WS-SX
             MOVE -8 TO WS-SY
             MOVE 0 TO WS-SZ
         WHEN 4
             MOVE -8 TO WS-SX
             MOVE 0 TO WS-SY
             MOVE -8 TO WS-SZ
         WHEN 5
             MOVE 8 TO WS-SX
             MOVE 0 TO WS-SY
             MOVE -8 TO WS-SZ
         WHEN 6
             MOVE 8 TO WS-SX
             MOVE 0 TO WS-SY
             MOVE 8 TO WS-SZ
         WHEN 7
             MOVE -8 TO WS-SX
             MOVE 0 TO WS-SY
             MOVE 8 TO WS-SZ
         WHEN 8
             MOVE 0 TO WS-SX
             MOVE 8 TO WS-SY
             MOVE 8 TO WS-SZ
         WHEN 9
             MOVE 0 TO WS-SX
             MOVE 8 TO WS-SY
             MOVE -8 TO WS-SZ
         WHEN 10
             MOVE 8 TO WS-SX
             MOVE 8 TO WS-SY
             MOVE 0 TO WS-SZ
         WHEN 11
             MOVE -8 TO WS-SX
             MOVE 8 TO WS-SY
             MOVE 0 TO WS-SZ
         END-EVALUATE
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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-GUARDIAN-TICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(4) TO L-O(1)
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
     GOBACK.
 END PROGRAM EF6-GUARDIAN-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-GUARDIAN-LERP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(2) + L-I(1) * (L-I(3) - L-I(2))
     GOBACK.
 END PROGRAM EF6-GUARDIAN-LERP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-GUARDIAN-DURATION.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 80 TO L-O(1)
     IF L-I(1) NOT = 0
         MOVE 60 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EF6-GUARDIAN-DURATION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-GUARDIAN-ATTACK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = (L-I(2) + L-I(1)) / L-I(3)
     COMPUTE L-O(2) = L-I(2) + L-I(1)
     GOBACK.
 END PROGRAM EF6-GUARDIAN-ATTACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-GUARDIAN-ATTACK-TICK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO L-O(1)
     IF L-I(2) NOT = 0 AND L-I(1) < L-I(3)
         COMPUTE L-O(1) = L-I(1) + 1
     END-IF
     GOBACK.
 END PROGRAM EF6-GUARDIAN-ATTACK-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-GUARDIAN-TEXTURE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-PATH                 PIC X(120).
 PROCEDURE DIVISION USING L-IN L-PATH.
     EVALUATE L-I(1)
         WHEN 1
             MOVE "textures/entity/guardian/guardian_elder.png" TO L-PATH
         WHEN 2
             MOVE "textures/entity/guardian/guardian_beam.png" TO L-PATH
         WHEN OTHER
             MOVE "textures/entity/guardian/guardian.png" TO L-PATH
     END-EVALUATE
     GOBACK.
 END PROGRAM EF6-GUARDIAN-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-GUARDIAN-CULLBOX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CY                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-CY = L-I(5) + 0.5 * L-I(7)
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
     GOBACK.
 END PROGRAM EF6-GUARDIAN-CULLBOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-GUARDIAN-BEAM-COLOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-C                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-C = L-I(1) * L-I(1)
     COMPUTE L-O(1) = 64 + FUNCTION INTEGER-PART(WS-C * 191)
     COMPUTE L-O(2) = 32 + FUNCTION INTEGER-PART(WS-C * 191)
     COMPUTE L-O(3) = 128 - FUNCTION INTEGER-PART(WS-C * 64)
     GOBACK.
 END PROGRAM EF6-GUARDIAN-BEAM-COLOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-GUARDIAN-BEAM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-NY                  FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-AT                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-LEN = FUNCTION SQRT(L-I(1) * L-I(1) + L-I(2) * L-I(2) + L-I(3) * L-I(3))
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
     GOBACK.
 END PROGRAM EF6-GUARDIAN-BEAM.


 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-GUARDIAN-BEAM-QUADS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LL                  FLOAT-LONG.
 01 WS-PH                  FLOAT-LONG.
 01 WS-V0                  FLOAT-LONG.
 01 WS-V1                  FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-P8.
    05 WS-PX               FLOAT-LONG OCCURS 8 TIMES.
    05 WS-PZ               FLOAT-LONG OCCURS 8 TIMES.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(2) TO WS-LL
     COMPUTE WS-PH = FUNCTION MOD(L-I(3) * 0.5, 1)
     COMPUTE WS-V0 = -1 + WS-PH
     COMPUTE WS-V1 = WS-V0 + WS-LL * 2.5
     COMPUTE WS-N = FUNCTION INTEGER(L-I(3))
     MOVE 0 TO WS-F
     IF FUNCTION MOD(WS-N, 2) = 0
         MOVE 0.5 TO WS-F
     END-IF
     COMPUTE WS-PX(1) = 0.2 * FUNCTION COS(L-I(1) + 3.141592653589793)
     COMPUTE WS-PZ(1) = 0.2 * FUNCTION SIN(L-I(1) + 3.141592653589793)
     COMPUTE WS-PX(2) = 0.2 * FUNCTION COS(L-I(1) + 0)
     COMPUTE WS-PZ(2) = 0.2 * FUNCTION SIN(L-I(1) + 0)
     COMPUTE WS-PX(3) = 0.2 * FUNCTION COS(L-I(1) + 1.5707963267948966)
     COMPUTE WS-PZ(3) = 0.2 * FUNCTION SIN(L-I(1) + 1.5707963267948966)
     COMPUTE WS-PX(4) = 0.2 * FUNCTION COS(L-I(1) + 4.71238898038469)
     COMPUTE WS-PZ(4) = 0.2 * FUNCTION SIN(L-I(1) + 4.71238898038469)
     COMPUTE WS-PX(5) = 0.282 * FUNCTION COS(L-I(1) + 2.356194490192345)
     COMPUTE WS-PZ(5) = 0.282 * FUNCTION SIN(L-I(1) + 2.356194490192345)
     COMPUTE WS-PX(6) = 0.282 * FUNCTION COS(L-I(1) + 0.7853981633974483)
     COMPUTE WS-PZ(6) = 0.282 * FUNCTION SIN(L-I(1) + 0.7853981633974483)
     COMPUTE WS-PX(7) = 0.282 * FUNCTION COS(L-I(1) + 5.497787143782138)
     COMPUTE WS-PZ(7) = 0.282 * FUNCTION SIN(L-I(1) + 5.497787143782138)
     COMPUTE WS-PX(8) = 0.282 * FUNCTION COS(L-I(1) + 3.9269908169872414)
     COMPUTE WS-PZ(8) = 0.282 * FUNCTION SIN(L-I(1) + 3.9269908169872414)
     MOVE WS-PX(1) TO L-O(1)
     MOVE WS-LL TO L-O(2)
     MOVE WS-PZ(1) TO L-O(3)
     MOVE 0.4999 TO L-O(4)
     COMPUTE L-O(5) = WS-V1
     MOVE WS-PX(1) TO L-O(6)
     MOVE 0 TO L-O(7)
     MOVE WS-PZ(1) TO L-O(8)
     MOVE 0.4999 TO L-O(9)
     COMPUTE L-O(10) = WS-V0
     MOVE WS-PX(2) TO L-O(11)
     MOVE 0 TO L-O(12)
     MOVE WS-PZ(2) TO L-O(13)
     MOVE 0 TO L-O(14)
     COMPUTE L-O(15) = WS-V0
     MOVE WS-PX(2) TO L-O(16)
     MOVE WS-LL TO L-O(17)
     MOVE WS-PZ(2) TO L-O(18)
     MOVE 0 TO L-O(19)
     COMPUTE L-O(20) = WS-V1
     MOVE WS-PX(3) TO L-O(21)
     MOVE WS-LL TO L-O(22)
     MOVE WS-PZ(3) TO L-O(23)
     MOVE 0.4999 TO L-O(24)
     COMPUTE L-O(25) = WS-V1
     MOVE WS-PX(3) TO L-O(26)
     MOVE 0 TO L-O(27)
     MOVE WS-PZ(3) TO L-O(28)
     MOVE 0.4999 TO L-O(29)
     COMPUTE L-O(30) = WS-V0
     MOVE WS-PX(4) TO L-O(31)
     MOVE 0 TO L-O(32)
     MOVE WS-PZ(4) TO L-O(33)
     MOVE 0 TO L-O(34)
     COMPUTE L-O(35) = WS-V0
     MOVE WS-PX(4) TO L-O(36)
     MOVE WS-LL TO L-O(37)
     MOVE WS-PZ(4) TO L-O(38)
     MOVE 0 TO L-O(39)
     COMPUTE L-O(40) = WS-V1
     MOVE WS-PX(5) TO L-O(41)
     MOVE WS-LL TO L-O(42)
     MOVE WS-PZ(5) TO L-O(43)
     MOVE 0.5 TO L-O(44)
     COMPUTE L-O(45) = WS-F + 0.5
     MOVE WS-PX(6) TO L-O(46)
     MOVE WS-LL TO L-O(47)
     MOVE WS-PZ(6) TO L-O(48)
     MOVE 1 TO L-O(49)
     COMPUTE L-O(50) = WS-F + 0.5
     MOVE WS-PX(7) TO L-O(51)
     MOVE WS-LL TO L-O(52)
     MOVE WS-PZ(7) TO L-O(53)
     MOVE 1 TO L-O(54)
     COMPUTE L-O(55) = WS-F
     MOVE WS-PX(8) TO L-O(56)
     MOVE WS-LL TO L-O(57)
     MOVE WS-PZ(8) TO L-O(58)
     MOVE 0.5 TO L-O(59)
     COMPUTE L-O(60) = WS-F
     GOBACK.
 END PROGRAM EF6-GUARDIAN-BEAM-QUADS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF6-ELDER-PARTICLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-F = (L-I(1) + L-I(2)) / 30
     COMPUTE L-O(1) = 0.05 + 0.5 * FUNCTION SIN(WS-F * 3.1415927)
     MOVE 3 TO L-O(2)
     MOVE 6 TO L-O(3)
     COMPUTE L-O(4) = 60 - 150 * WS-F
     MOVE 0 TO L-O(5) L-O(6)
     MOVE 2 TO L-O(7)
     MOVE 0.42553192 TO L-O(8)
     MOVE -0.42553192 TO L-O(9) L-O(10)
     MOVE 1 TO L-O(11)
     MOVE 0 TO L-O(12)
     MOVE -0.56 TO L-O(13)
     MOVE 3.5 TO L-O(14)
     GOBACK.
 END PROGRAM EF6-ELDER-PARTICLE.

