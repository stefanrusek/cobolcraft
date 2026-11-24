*> The beardifier of the terrain adaptation (docs/protocol/36-structures-1-model-placement-starts.md section 9): the contribution of a rigid piece record and of a jigsaw junction at a block (9.3), and the
*> selection tests of 9.2. All arithmetic is Java float: each operation is done in double and rounded to single precision (FX-OP of feat-35-6.cob; the exact product of two floats fits a double).
*> Modes are the ids of terrain_adaptation: none 0, bury 1, beard_thin 2, beard_box 3, encapsulate 4. The kernel (24 x 24 x 24, built once in the artifact) is evaluated entry by entry here.
*> Entry points:
*>   STRUCT-BURY USING a, b, c (FLOAT-LONG), r out: 0 from the squared length 36, else 1 - sqrt(a*a + b*b + c*c) / 6
*>   STRUCT-BEARD-KERNEL USING i, j, k (0 to 23), r out: KERNEL[i * 576 + j * 24 + k] = (float) exp(-(a*a + (b + 0.5)^2 + c*c) / 16) with a = j - 12, b = k - 12, c = i - 12
*>   STRUCT-BEARD USING dx, dy, dz, yb (integers), r out: 0 outside 0 to 23 after adding 12; else (-yf * fastInvSqrt(L / 2) / 2) * kernel(z, x, y) with yf = yb + 0.5, L = dx*dx + yf*yf + dz*dz
*>   STRUCT-BEARD-RIGID USING mode, minX, minY, minZ, maxX, maxY, maxZ, ground level delta, x, y, z, r out: one rigid record's contribution
*>   STRUCT-BEARD-JUNCTION USING source x, source ground y, source z, x, y, z, r out: 0.4 * beard(jx, jy, jz, jy)
*>   STRUCT-BEARD-CLOSE USING minX, minZ, maxX, maxZ, chunk x, chunk z, margin, flag out: isCloseToChunk (the box meets the chunk square widened by the margin, inclusive, x and z only)
*>   STRUCT-BEARD-JUNCTION-IN USING source x, source z, chunk x, chunk z, flag out: bx - 12 < srcX < bx + 27 and bz - 12 < srcZ < bz + 27 (both strict)
*>   STRUCT-BEARD-AFFECTED USING minX, minY, minZ, maxX, maxY, maxZ, x, y, z, flag out: the point lies in the box inflated by 24 on every axis (else the sampled value is 0)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-BURY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OP-ADD              BINARY-LONG VALUE 1.
 01 WS-OP-SUB              BINARY-LONG VALUE 2.
 01 WS-OP-MUL              BINARY-LONG VALUE 3.
 01 WS-DUP                 FLOAT-LONG.
 01 WS-OP-DIV              BINARY-LONG VALUE 4.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-L                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-SIX                 FLOAT-LONG VALUE 6.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-A                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-C                    FLOAT-LONG.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-A L-B L-C L-R.
     MOVE L-A TO WS-DUP
     CALL "FX-OP" USING WS-OP-MUL L-A WS-DUP WS-A
     MOVE L-B TO WS-DUP
     CALL "FX-OP" USING WS-OP-MUL L-B WS-DUP WS-B
     MOVE L-C TO WS-DUP
     CALL "FX-OP" USING WS-OP-MUL L-C WS-DUP WS-C
     CALL "FX-OP" USING WS-OP-ADD WS-A WS-B WS-T
     CALL "FX-OP" USING WS-OP-ADD WS-T WS-C WS-L
     IF WS-L >= WS-SIX * WS-SIX
         MOVE 0 TO L-R
     ELSE
         CALL STATIC "cc_f64_sqrt" USING BY REFERENCE WS-L WS-T
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-S
         CALL "FX-OP" USING WS-OP-DIV WS-S WS-SIX WS-T
         CALL "FX-OP" USING WS-OP-SUB WS-ONE WS-T L-R
     END-IF
     GOBACK.
 END PROGRAM STRUCT-BURY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-BEARD-KERNEL.
*> the value of an entry is computed once (FUNCTION EXP is a decimal evaluation, tens of microseconds) and kept: the table has 24 * 24 * 24 entries (the arguments are 0 to 23), the same values the formula gives
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-E                   FLOAT-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-KERNELS.
    05 WS-KERNEL           OCCURS 13824 TIMES.
       10 WS-KSET          BINARY-LONG VALUE 0.
       10 WS-KVAL          FLOAT-LONG.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-J                    BINARY-LONG.
 01 L-K                    BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-I L-J L-K L-R.
     COMPUTE WS-AT = (L-I * 24 + L-J) * 24 + L-K + 1
     IF WS-KSET(WS-AT) = 1
         MOVE WS-KVAL(WS-AT) TO L-R
         GOBACK
     END-IF
     COMPUTE WS-A = L-J - 12
     COMPUTE WS-B = L-K - 12 + 0.5
     COMPUTE WS-C = L-I - 12
     COMPUTE WS-D = WS-A * WS-A + WS-B * WS-B + WS-C * WS-C
     COMPUTE WS-E = FUNCTION EXP(0 - WS-D / 16)
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-E L-R
     MOVE 1 TO WS-KSET(WS-AT)
     MOVE L-R TO WS-KVAL(WS-AT)
     GOBACK.
 END PROGRAM STRUCT-BEARD-KERNEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-BEARD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OP-ADD              BINARY-LONG VALUE 1.
 01 WS-OP-MUL              BINARY-LONG VALUE 3.
 01 WS-DUP                 FLOAT-LONG.
 01 WS-OP-DIV              BINARY-LONG VALUE 4.
 01 WS-IX                  BINARY-LONG.
 01 WS-IY                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-YF                  FLOAT-LONG.
 01 WS-FDX                 FLOAT-LONG.
 01 WS-FDZ                 FLOAT-LONG.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-TWO                 FLOAT-LONG VALUE 2.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-L                   FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-INV                 FLOAT-LONG.
 01 WS-INVF                FLOAT-LONG.
 01 WS-NEG                 FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-KERN                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-YB                   BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-DX L-DY L-DZ L-YB L-R.
     MOVE 0 TO L-R
     COMPUTE WS-IX = L-DX + 12
     COMPUTE WS-IY = L-DY + 12
     COMPUTE WS-IZ = L-DZ + 12
     IF WS-IX >= 0 AND WS-IX <= 23 AND WS-IY >= 0 AND WS-IY <= 23 AND WS-IZ >= 0 AND WS-IZ <= 23
         COMPUTE WS-A = L-YB
         CALL "FX-OP" USING WS-OP-ADD WS-A WS-HALF WS-YF
         MOVE L-DX TO WS-FDX
         MOVE L-DZ TO WS-FDZ
         MOVE WS-FDX TO WS-DUP
         CALL "FX-OP" USING WS-OP-MUL WS-FDX WS-DUP WS-A
         MOVE WS-YF TO WS-DUP
         CALL "FX-OP" USING WS-OP-MUL WS-YF WS-DUP WS-B
         MOVE WS-FDZ TO WS-DUP
         CALL "FX-OP" USING WS-OP-MUL WS-FDZ WS-DUP WS-C
         CALL "FX-OP" USING WS-OP-ADD WS-A WS-B WS-H
         CALL "FX-OP" USING WS-OP-ADD WS-H WS-C WS-L
         CALL "FX-OP" USING WS-OP-DIV WS-L WS-TWO WS-H
         CALL STATIC "cc_f64_fast_inv_sqrt" USING BY REFERENCE WS-H WS-INV
         CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-INV WS-INVF
         COMPUTE WS-NEG = 0 - WS-YF
         CALL "FX-OP" USING WS-OP-MUL WS-NEG WS-INVF WS-A
         CALL "FX-OP" USING WS-OP-DIV WS-A WS-TWO WS-V
         CALL "STRUCT-BEARD-KERNEL" USING WS-IZ WS-IX WS-IY WS-KERN
         CALL "FX-OP" USING WS-OP-MUL WS-V WS-KERN L-R
     END-IF
     GOBACK.
 END PROGRAM STRUCT-BEARD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-BEARD-RIGID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OP-MUL              BINARY-LONG VALUE 3.
 01 WS-EIGHT               FLOAT-LONG VALUE 0.8.
 01 WS-W                   FLOAT-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-BOTTOM              BINARY-LONG.
 01 WS-YB                  BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-FA                  FLOAT-LONG.
 01 WS-FB                  FLOAT-LONG.
 01 WS-FC                  FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 01 L-G                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-MODE L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1 L-G L-X L-Y L-Z L-R.
     MOVE 0 TO L-R
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-EIGHT WS-W
     MOVE FUNCTION MAX(0, L-X0 - L-X, L-X - L-X1) TO WS-DX
     MOVE FUNCTION MAX(0, L-Z0 - L-Z, L-Z - L-Z1) TO WS-DZ
     COMPUTE WS-BOTTOM = L-Y0 + L-G
     COMPUTE WS-YB = L-Y - WS-BOTTOM
     EVALUATE L-MODE
         WHEN 1
             MOVE WS-DX TO WS-FA
             COMPUTE WS-FB = WS-YB / 2
             MOVE WS-DZ TO WS-FC
             CALL "STRUCT-BURY" USING WS-FA WS-FB WS-FC L-R
         WHEN 2
             MOVE WS-YB TO WS-DY
             CALL "STRUCT-BEARD" USING WS-DX WS-DY WS-DZ WS-YB WS-V
             CALL "FX-OP" USING WS-OP-MUL WS-W WS-V L-R
         WHEN 3
             COMPUTE WS-T = WS-BOTTOM - L-Y
             MOVE FUNCTION MAX(0, WS-T, L-Y - L-Y1) TO WS-DY
             CALL "STRUCT-BEARD" USING WS-DX WS-DY WS-DZ WS-YB WS-V
             CALL "FX-OP" USING WS-OP-MUL WS-W WS-V L-R
         WHEN 4
             COMPUTE WS-T = L-Y0 - L-Y
             MOVE FUNCTION MAX(0, WS-T, L-Y - L-Y1) TO WS-DY
             COMPUTE WS-FA = WS-DX / 2
             COMPUTE WS-FB = WS-DY / 2
             COMPUTE WS-FC = WS-DZ / 2
             CALL "STRUCT-BURY" USING WS-FA WS-FB WS-FC WS-V
             CALL "FX-OP" USING WS-OP-MUL WS-W WS-V L-R
         WHEN OTHER
             MOVE 0 TO L-R
     END-EVALUATE
     GOBACK.
 END PROGRAM STRUCT-BEARD-RIGID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-BEARD-JUNCTION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OP-MUL              BINARY-LONG VALUE 3.
 01 WS-FOUR                FLOAT-LONG VALUE 0.4.
 01 WS-W                   FLOAT-LONG.
 01 WS-JX                  BINARY-LONG.
 01 WS-JY                  BINARY-LONG.
 01 WS-JZ                  BINARY-LONG.
 01 WS-JB                  BINARY-LONG.
 01 WS-V                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-SX L-SY L-SZ L-X L-Y L-Z L-R.
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-FOUR WS-W
     COMPUTE WS-JX = L-X - L-SX
     COMPUTE WS-JY = L-Y - L-SY
     COMPUTE WS-JZ = L-Z - L-SZ
     MOVE WS-JY TO WS-JB
     CALL "STRUCT-BEARD" USING WS-JX WS-JY WS-JZ WS-JB WS-V
     CALL "FX-OP" USING WS-OP-MUL WS-W WS-V L-R
     GOBACK.
 END PROGRAM STRUCT-BEARD-JUNCTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-BEARD-CLOSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LO-X                BINARY-LONG.
 01 WS-HI-X                BINARY-LONG.
 01 WS-LO-Z                BINARY-LONG.
 01 WS-HI-Z                BINARY-LONG.
 LINKAGE SECTION.
 01 L-X0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-MARGIN               BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X0 L-Z0 L-X1 L-Z1 L-CX L-CZ L-MARGIN L-FLAG.
     COMPUTE WS-LO-X = L-CX * 16 - L-MARGIN
     COMPUTE WS-HI-X = L-CX * 16 + 15 + L-MARGIN
     COMPUTE WS-LO-Z = L-CZ * 16 - L-MARGIN
     COMPUTE WS-HI-Z = L-CZ * 16 + 15 + L-MARGIN
     MOVE 0 TO L-FLAG
     IF L-X1 >= WS-LO-X AND L-X0 <= WS-HI-X AND L-Z1 >= WS-LO-Z AND L-Z0 <= WS-HI-Z
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM STRUCT-BEARD-CLOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-BEARD-JUNCTION-IN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-SX                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SX L-SZ L-CX L-CZ L-FLAG.
     COMPUTE WS-BX = L-CX * 16
     COMPUTE WS-BZ = L-CZ * 16
     MOVE 0 TO L-FLAG
     IF L-SX > WS-BX - 12 AND L-SX < WS-BX + 27 AND L-SZ > WS-BZ - 12 AND L-SZ < WS-BZ + 27
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM STRUCT-BEARD-JUNCTION-IN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-BEARD-AFFECTED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1 L-X L-Y L-Z L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-X >= L-X0 - 24 AND L-X <= L-X1 + 24 AND L-Y >= L-Y0 - 24 AND L-Y <= L-Y1 + 24
         AND L-Z >= L-Z0 - 24 AND L-Z <= L-Z1 + 24
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM STRUCT-BEARD-AFFECTED.
