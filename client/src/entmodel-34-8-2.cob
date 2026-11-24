*> Entity models part 8 section 2 (squid and glow squid): the adult and baby meshes (2.1; the glow squid layers reuse them), setupAnim, render state lerps, the entity tentacle and body rotation updates, setupRotations, textures and the glow squid block light (2.2).
*> Entry points for the integrator (inputs; the table programs take IN (16 FLOAT-LONG) and OUT (64 FLOAT-LONG)): ops lists are count, then code (1 translate, 3 rotate Y degrees, 6 rotate X degrees) and three values per op.
*>   EF8-SQUID-ANIM EMM-MODEL state(1 tentacleAngle): reset first, every tentacle xRot set to the angle; EF8-SQUID-STATE IN(partial, old angle, angle, old xBodyRot, xBodyRot, old zBodyRot, zBodyRot) OUT(angle, xBodyRot, zBodyRot);
*>   EF8-SQUID-TENTACLE IN(tentacleMovement, tentacleSpeed, in water, rotateSpeed) OUT(movement, angle, rotateSpeed): the client side of Squid.aiStep steps 2 to 4; EF8-SQUID-BODY IN(in water, rotateSpeed, yBodyRot, zBodyRot, xBodyRot, vx, vy, vz) OUT(yBodyRot, zBodyRot, xBodyRot);
*>   EF8-SQUID-ROT-OPS IN(bodyRot, xBodyRot, zBodyRot, baby) OUT(ops); EF8-SQUID-TEXTURE IN(glow, baby) path(out X(60), relative to textures/entity/); EF8-GLOW-LIGHT IN(dark ticks remaining, normal block light) OUT(block light).


 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-M-SQUID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS1.
    05 FILLER PIC X(100) VALUE "P body root 0 8 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 0 -6 -8 -6 12 16 12 0.02 0".
    05 FILLER PIC X(100) VALUE "P tentacle0 root 5.0 15 0.0 0 1.570796327 0".
    05 FILLER PIC X(100) VALUE "C tentacle0 48 0 -1 0 -1 2 18 2 0 0".
    05 FILLER PIC X(100) VALUE "P tentacle1 root 3.535533906 15 3.535533906 0 0.785398163 0".
    05 FILLER PIC X(100) VALUE "C tentacle1 48 0 -1 0 -1 2 18 2 0 0".
    05 FILLER PIC X(100) VALUE "P tentacle2 root 0.0 15 5.0 0 0.0 0".
    05 FILLER PIC X(100) VALUE "C tentacle2 48 0 -1 0 -1 2 18 2 0 0".
    05 FILLER PIC X(100) VALUE "P tentacle3 root -3.535533906 15 3.535533906 0 -0.785398163 0".
    05 FILLER PIC X(100) VALUE "C tentacle3 48 0 -1 0 -1 2 18 2 0 0".
    05 FILLER PIC X(100) VALUE "P tentacle4 root -5.0 15 0.0 0 -1.570796327 0".
    05 FILLER PIC X(100) VALUE "C tentacle4 48 0 -1 0 -1 2 18 2 0 0".
    05 FILLER PIC X(100) VALUE "P tentacle5 root -3.535533906 15 -3.535533906 0 -2.35619449 0".
    05 FILLER PIC X(100) VALUE "C tentacle5 48 0 -1 0 -1 2 18 2 0 0".
    05 FILLER PIC X(100) VALUE "P tentacle6 root -0.0 15 -5.0 0 -3.141592654 0".
    05 FILLER PIC X(100) VALUE "C tentacle6 48 0 -1 0 -1 2 18 2 0 0".
    05 FILLER PIC X(100) VALUE "P tentacle7 root 3.535533906 15 -3.535533906 0 -3.926990817 0".
    05 FILLER PIC X(100) VALUE "C tentacle7 48 0 -1 0 -1 2 18 2 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 62 TIMES.
 01 WS-ROWS1-R REDEFINES WS-ROWS1.
    05 WS-ROW1             PIC X(100) OCCURS 80 TIMES.
 01 WS-N1                  BINARY-LONG VALUE 18.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS1-R WS-N1 WS-ZERO
     MOVE 64 TO MM-TEXW
     MOVE 32 TO MM-TEXH
     GOBACK.
 END PROGRAM EF8-M-SQUID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-M-SQUID-BABY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS1.
    05 FILLER PIC X(100) VALUE "P body root 0 13 0 0 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 0 -4 -5 -4 8 10 8 0 0".
    05 FILLER PIC X(100) VALUE "P tentacle0 root 3.0 18.5 0.0 0 1.570796327 0".
    05 FILLER PIC X(100) VALUE "C tentacle0 0 18 -1 -0.5 -1 2 6 2 0 0".
    05 FILLER PIC X(100) VALUE "P tentacle1 root 2.121320344 18.5 2.121320344 0 0.785398163 0".
    05 FILLER PIC X(100) VALUE "C tentacle1 0 18 -1 -0.5 -1 2 6 2 0 0".
    05 FILLER PIC X(100) VALUE "P tentacle2 root 0.0 18.5 3.0 0 0.0 0".
    05 FILLER PIC X(100) VALUE "C tentacle2 0 18 -1 -0.5 -1 2 6 2 0 0".
    05 FILLER PIC X(100) VALUE "P tentacle3 root -2.121320344 18.5 2.121320344 0 -0.785398163 0".
    05 FILLER PIC X(100) VALUE "C tentacle3 0 18 -1 -0.5 -1 2 6 2 0 0".
    05 FILLER PIC X(100) VALUE "P tentacle4 root -3.0 18.5 0.0 0 -1.570796327 0".
    05 FILLER PIC X(100) VALUE "C tentacle4 0 18 -1 -0.5 -1 2 6 2 0 0".
    05 FILLER PIC X(100) VALUE "P tentacle5 root -2.121320344 18.5 -2.121320344 0 -2.35619449 0".
    05 FILLER PIC X(100) VALUE "C tentacle5 0 18 -1 -0.5 -1 2 6 2 0 0".
    05 FILLER PIC X(100) VALUE "P tentacle6 root -0.0 18.5 -3.0 0 -3.141592654 0".
    05 FILLER PIC X(100) VALUE "C tentacle6 0 18 -1 -0.5 -1 2 6 2 0 0".
    05 FILLER PIC X(100) VALUE "P tentacle7 root 2.121320344 18.5 -2.121320344 0 -3.926990817 0".
    05 FILLER PIC X(100) VALUE "C tentacle7 0 18 -1 -0.5 -1 2 6 2 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 62 TIMES.
 01 WS-ROWS1-R REDEFINES WS-ROWS1.
    05 WS-ROW1             PIC X(100) OCCURS 80 TIMES.
 01 WS-N1                  BINARY-LONG VALUE 18.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS1-R WS-N1 WS-ZERO
     MOVE 32 TO MM-TEXW
     MOVE 32 TO MM-TEXH
     GOBACK.
 END PROGRAM EF8-M-SQUID-BABY.

 IDENTIFICATION DIVISION.
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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-SQUID-STATE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(2) + L-I(1) * (L-I(3) - L-I(2))
     COMPUTE L-O(2) = L-I(4) + L-I(1) * (L-I(5) - L-I(4))
     COMPUTE L-O(3) = L-I(6) + L-I(1) * (L-I(7) - L-I(6))
     GOBACK.
 END PROGRAM EF8-SQUID-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-SQUID-TENTACLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-P                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = L-I(1) + L-I(2)
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
     GOBACK.
 END PROGRAM EF8-SQUID-TENTACLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-SQUID-BODY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-H                   FLOAT-LONG.
 01 WS-IN2.
    05 WS-AI               FLOAT-LONG OCCURS 16 TIMES.
 01 WS-OUT2.
    05 WS-OV               FLOAT-LONG OCCURS 64 TIMES.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(3) TO L-O(1)
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
     GOBACK.
 END PROGRAM EF8-SQUID-BODY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-SQUID-ROT-OPS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DY                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 5 TO L-O(1)
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
     GOBACK.
 END PROGRAM EF8-SQUID-ROT-OPS.

 IDENTIFICATION DIVISION.
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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-GLOW-LIGHT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-T = 1 - L-I(1) / 10
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
     GOBACK.
 END PROGRAM EF8-GLOW-LIGHT.

