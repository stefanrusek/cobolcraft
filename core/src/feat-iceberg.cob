*> The iceberg feature (docs/protocol/35-worldgen-features-5-water-and-surface.md section 9; registry id 24, iceberg): FD-ICEBERG-NODE takes the row of FD-WA (WA-I(1) the iceberg state, WA-I(2) to
*> WA-I(6) the block indices of snow_block, ice, packed_ice, blue_ice and snow, WA-I(7) the default state of snow_block; FD-BAD when the state or a block is missing), FR-ICEBERG places it:
*> the nine parameter draws of 9.1 at the origin (x, sea level, z), the above-water body, the smoothing pass, the below-water taper and the cut-out channel, in the order of 9.2 (the radius helpers
*> of 9.3 draw random numbers on every call, so the loops keep the document's order). The float steps of the radius helpers are rounded to binary32 after every operation (MOVE through FLOAT-SHORT);
*> a distance is compared with another number through the sign of the IEEE difference (a FLOAT-LONG comparison is fuzzy); cos and sin of the two angles are taken once. Writes use flag 3.
*> Deviation: a cell outside the chunk column is refused by the level (feat-level.cob), as for every feature of this stage.
*>
*> Entry points: FD-ICEBERG-NODE USING doc, node, row out; FR-ICEBERG USING state, feature, x, y, z, result out (always 1).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-ICEBERG-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 COPY CBLOCKS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-NAME                PIC X(48).
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     MOVE 0 TO L-ROW
     IF FD-WA-COUNT >= FD-MAX-WA
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     ADD 1 TO FD-WA-COUNT
     MOVE FD-WA-COUNT TO WS-ROW
     INITIALIZE FD-WA(WS-ROW)
     MOVE WS-ROW TO L-ROW
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-STATE WS-E
     CALL "FD-J-STATE" USING JSON-DOC WS-E WA-I(WS-ROW, 1) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     MOVE "minecraft:snow_block" TO WS-NAME
     CALL "FD-BLOCK-INDEX" USING WS-NAME WA-I(WS-ROW, 2)
     MOVE "minecraft:ice" TO WS-NAME
     CALL "FD-BLOCK-INDEX" USING WS-NAME WA-I(WS-ROW, 3)
     MOVE "minecraft:packed_ice" TO WS-NAME
     CALL "FD-BLOCK-INDEX" USING WS-NAME WA-I(WS-ROW, 4)
     MOVE "minecraft:blue_ice" TO WS-NAME
     CALL "FD-BLOCK-INDEX" USING WS-NAME WA-I(WS-ROW, 5)
     MOVE "minecraft:snow" TO WS-NAME
     CALL "FD-BLOCK-INDEX" USING WS-NAME WA-I(WS-ROW, 6)
     IF WA-I(WS-ROW, 2) = 0 OR WA-I(WS-ROW, 3) = 0 OR WA-I(WS-ROW, 4) = 0 OR WA-I(WS-ROW, 5) = 0 OR WA-I(WS-ROW, 6) = 0
         MOVE 1 TO FD-BAD
     ELSE
         MOVE CB-DEFAULT-STATE(WA-I(WS-ROW, 2)) TO WA-I(WS-ROW, 7)
     END-IF
     GOBACK.
 END PROGRAM FD-ICEBERG-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-ICEBERG.
*> USING state, feature, x, y, z, result out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY CBLOCKS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-B3                  BINARY-LONG VALUE 3.
 01 WS-B5                  BINARY-LONG VALUE 5.
 01 WS-B6                  BINARY-LONG VALUE 6.
 01 WS-B7                  BINARY-LONG VALUE 7.
 01 WS-B11                 BINARY-LONG VALUE 11.
 01 WS-B15                 BINARY-LONG VALUE 15.
 01 WS-B19                 BINARY-LONG VALUE 19.
 01 WS-BOUND               BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-WRITTEN             BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-SNOW                BINARY-LONG.
 01 WS-ELL                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-NW                  BINARY-LONG.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-ANGLE2              FLOAT-LONG.
 01 WS-COS                 FLOAT-LONG.
 01 WS-SIN                 FLOAT-LONG.
 01 WS-COS2                FLOAT-LONG.
 01 WS-SIN2                FLOAT-LONG.
 01 WS-PI                  FLOAT-LONG VALUE 3.141592653589793.
 01 WS-HALF-PI             FLOAT-LONG VALUE 1.5707963267948966.
 01 WS-TWO                 FLOAT-LONG VALUE 2.0.
 01 WS-DBL                 FLOAT-LONG.
 01 WS-THRESH              FLOAT-LONG.
 01 WS-GT                  BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-RY                  BINARY-LONG.
 01 WS-Y2                  BINARY-LONG.
 01 WS-T1                  FLOAT-LONG.
 01 WS-T2                  FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-NF                  FLOAT-LONG.
 01 WS-F32                 FLOAT-SHORT.
 01 WS-NEG                 FLOAT-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-PH                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-PR                  BINARY-LONG.
 01 WS-PW                  BINARY-LONG.
 01 WS-EDX                 BINARY-LONG.
 01 WS-EDZ                 BINARY-LONG.
 01 WS-EA                  BINARY-LONG.
 01 WS-EB                  BINARY-LONG.
 01 WS-EC                  BINARY-LONG.
 01 WS-ECOS                FLOAT-LONG.
 01 WS-ESIN                FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-DIST-NEG            BINARY-LONG.
 01 WS-U1                  FLOAT-LONG.
 01 WS-U2                  FLOAT-LONG.
 01 WS-SG                  BINARY-LONG.
 01 WS-Q3                  BINARY-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-HALF                FLOAT-LONG VALUE -0.5.
 01 WS-ZERO-D              FLOAT-LONG VALUE 0.
 01 WS-REM                 BINARY-LONG.
 01 WS-HGT                 BINARY-LONG.
 01 WS-DIV                 BINARY-LONG.
 01 WS-OKF                 BINARY-LONG.
 01 WS-TT                  BINARY-LONG.
 01 WS-LHS                 BINARY-LONG.
 01 WS-RHS                 BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-RAD                 BINARY-LONG.
 01 WS-CNT                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ICEB                BINARY-LONG.
 01 WS-CUTX                BINARY-LONG.
 01 WS-CUTZ                BINARY-LONG.
 01 WS-OFX                 BINARY-LONG.
 01 WS-OFZ                 BINARY-LONG.
 01 WS-HALF-E              BINARY-LONG.
 01 WS-WIDE                BINARY-LONG.
 01 WS-NWIDE               BINARY-LONG.
 01 WS-CC                  BINARY-LONG.
 01 WS-TO-WATER            BINARY-LONG.
 01 WS-YOFF                BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WATER-STATE         BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-S1                  FLOAT-LONG.
 01 WS-M1                  FLOAT-LONG.
 01 WS-M2                  FLOAT-LONG.
 01 WS-P1                  FLOAT-LONG.
 01 WS-P2                  FLOAT-LONG.
 01 WS-P3                  FLOAT-LONG.
 01 WS-P2B                 FLOAT-LONG.
 01 WS-Q2B                 FLOAT-LONG.
 01 WS-Q1                  FLOAT-LONG.
 01 WS-Q2                  FLOAT-LONG.
 01 WS-Q3F                 FLOAT-LONG.
 01 WS-AXF                 FLOAT-LONG.
 01 WS-BXF                 FLOAT-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.0.
 01 WS-FA                  FLOAT-LONG.
 01 WS-FB                  FLOAT-LONG.
 01 WS-FRR                 FLOAT-LONG.
 01 WS-FR2                 FLOAT-LONG.
 01 WS-FKEEP               FLOAT-LONG.
 01 WS-HU                  FLOAT-LONG.
 01 WS-YY                  BINARY-LONG.
 01 WS-HALF-F              FLOAT-LONG VALUE 0.5.
 01 WS-F35                 FLOAT-LONG VALUE 3.5.
 01 WS-F10                 FLOAT-LONG VALUE 10.0.
 01 WS-F02                 FLOAT-LONG.
 01 WS-F08                 FLOAT-LONG.
 01 WS-F04                 FLOAT-LONG.
 01 WS-LIT02               FLOAT-LONG VALUE 0.2.
 01 WS-LIT08               FLOAT-LONG VALUE 0.8.
 01 WS-LIT04               FLOAT-LONG VALUE 0.4.
 01 WS-S2                  FLOAT-LONG.
 01 WS-DIRS.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
 01 WS-DIR-TABLE REDEFINES WS-DIRS.
    05 WS-DIR4 OCCURS 4 TIMES.
       10 WS-DDX           BINARY-LONG.
       10 WS-DDZ           BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-RESULT.
     MOVE 1 TO L-RESULT
     MOVE FT-A(L-FT) TO WS-ROW
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-LIT02 WS-F02
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-LIT08 WS-F08
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-LIT04 WS-F04
     MOVE L-X TO WS-OX
     MOVE FL-SEA TO WS-OY
     MOVE L-Z TO WS-OZ
*>   9.1: the parameter draws
     MOVE 0.7 TO WS-THRESH
     PERFORM NEXT-DOUBLE-GT
     MOVE WS-GT TO WS-SNOW
     CALL "WGR-NEXT-DOUBLE" USING L-STATE WS-DBL
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-DBL WS-TWO WS-M1
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-M1 WS-PI WS-ANGLE
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B5 WS-DRAW
     COMPUTE WS-A = 11 - WS-DRAW
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B3 WS-DRAW
     COMPUTE WS-B = 3 + WS-DRAW
     MOVE 0.7 TO WS-THRESH
     PERFORM NEXT-DOUBLE-GT
     MOVE WS-GT TO WS-ELL
     IF WS-ELL = 1
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B6 WS-DRAW
         COMPUTE WS-H = WS-DRAW + 6
     ELSE
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B15 WS-DRAW
         COMPUTE WS-H = WS-DRAW + 3
         MOVE 0.9 TO WS-THRESH
         PERFORM NEXT-DOUBLE-GT
         IF WS-GT = 1
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B19 WS-DRAW
             COMPUTE WS-H = WS-H + WS-DRAW + 7
         END-IF
     END-IF
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B11 WS-DRAW
     COMPUTE WS-D = WS-H + WS-DRAW
     IF WS-D > 18
         MOVE 18 TO WS-D
     END-IF
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B7 WS-DRAW
     COMPUTE WS-E = WS-H + WS-DRAW
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B5 WS-DRAW
     COMPUTE WS-E = WS-E - WS-DRAW
     IF WS-E > 11
         MOVE 11 TO WS-E
     END-IF
     IF WS-ELL = 1
         MOVE WS-A TO WS-W
     ELSE
         MOVE 11 TO WS-W
     END-IF
     COMPUTE WS-NW = 0 - WS-W
     CALL STATIC "cc_f64_cos" USING BY REFERENCE WS-ANGLE WS-COS
     CALL STATIC "cc_f64_sin" USING BY REFERENCE WS-ANGLE WS-SIN
*>   1. above water
     PERFORM VARYING WS-GX FROM WS-NW BY 1 UNTIL WS-GX >= WS-W
         PERFORM VARYING WS-GZ FROM WS-NW BY 1 UNTIL WS-GZ >= WS-W
             PERFORM VARYING WS-GY FROM 0 BY 1 UNTIL WS-GY >= WS-H
                 MOVE WS-GY TO WS-RY
                 IF WS-ELL = 1
                     PERFORM RADIUS-ELL
                 ELSE
                     PERFORM RADIUS-ROUND
                 END-IF
                 IF WS-ELL = 1 OR WS-GX < WS-R
                     MOVE WS-H TO WS-PH
                     MOVE WS-GX TO WS-PX
                     MOVE WS-GY TO WS-PY
                     MOVE WS-GZ TO WS-PZ
                     MOVE WS-R TO WS-PR
                     MOVE WS-W TO WS-PW
                     PERFORM PLACE-BLOCK
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
*>   2. smooth
     PERFORM SMOOTH
*>   3. below water
     PERFORM VARYING WS-GX FROM WS-NW BY 1 UNTIL WS-GX >= WS-W
         PERFORM VARYING WS-GZ FROM WS-NW BY 1 UNTIL WS-GZ >= WS-W
             COMPUTE WS-GY = -1
             PERFORM UNTIL WS-GY <= 0 - WS-D
                 MOVE WS-W TO WS-WY
                 IF WS-ELL = 1
*>                   Wy = ceil(W * (1.0f - (float)(y * y) / ((float) D * 8.0f)))
                     COMPUTE WS-YY = WS-GY * WS-GY
                     MOVE WS-YY TO WS-FA
                     COMPUTE WS-YY = WS-D * 8
                     MOVE WS-YY TO WS-FB
                     PERFORM F-DIV
                     PERFORM F-RND
                     PERFORM WY-FINISH
                 END-IF
                 COMPUTE WS-RY = 0 - WS-GY
                 MOVE WS-D TO WS-HGT
                 PERFORM RADIUS-STEEP
                 IF WS-GX < WS-R
                     MOVE WS-D TO WS-PH
                     MOVE WS-GX TO WS-PX
                     MOVE WS-GY TO WS-PY
                     MOVE WS-GZ TO WS-PZ
                     MOVE WS-R TO WS-PR
                     MOVE WS-WY TO WS-PW
                     PERFORM PLACE-BLOCK
                 END-IF
                 SUBTRACT 1 FROM WS-GY
             END-PERFORM
         END-PERFORM
     END-PERFORM
*>   4. cut-out
     IF WS-ELL = 1
         MOVE 0.1 TO WS-THRESH
     ELSE
         MOVE 0.7 TO WS-THRESH
     END-IF
     PERFORM NEXT-DOUBLE-GT
     IF WS-GT = 1
         PERFORM CUT-OUT
     END-IF
     GO TO MAIN-EXIT.
*> NEXT-DOUBLE-GT: WS-GT 1 when nextDouble() > WS-THRESH (the sign of the IEEE difference)
 NEXT-DOUBLE-GT.
     CALL "WGR-NEXT-DOUBLE" USING L-STATE WS-U1
     MOVE WS-THRESH TO WS-U2
     PERFORM SIGN-OF-DIFF
     MOVE 0 TO WS-GT
     IF WS-SG > 0
         MOVE 1 TO WS-GT
     END-IF
     .
*> SIGN-OF-DIFF: WS-SG = the sign (-1, 0, 1) of WS-U1 - WS-U2 in IEEE double arithmetic
 SIGN-OF-DIFF.
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-U1 WS-U2 WS-S1
     CALL STATIC "cc_f64_signum" USING BY REFERENCE WS-S1 WS-S2
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-S2 WS-SG
     .
*> The binary32 steps: WS-FA op WS-FB gives WS-FRR in one IEEE double operation, F-RND rounds WS-FRR to binary32 (cc_f64_f32_round), as Java does after each float operation.
 F-ADD.
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-FA WS-FB WS-FRR
     .
 F-SUB.
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-FA WS-FB WS-FRR
     .
 F-MUL.
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-FA WS-FB WS-FRR
     .
 F-DIV.
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-FA WS-FB WS-FRR
     .
 F-RND.
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-FRR WS-FR2
     MOVE WS-FR2 TO WS-FRR
     .
*> CEIL-HALF: WS-R = ceil(WS-FRR / 2)
 CEIL-HALF.
     MOVE WS-FRR TO WS-FA
     MOVE WS-HALF-F TO WS-FB
     PERFORM F-MUL
     CALL STATIC "cc_f64_ceil" USING BY REFERENCE WS-FRR WS-FR2
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-FR2 WS-R
     .
*> FINISH-RADIUS: f = (1.0f - q) * (float) E from WS-FRR = q, then CEIL-HALF
 FINISH-RADIUS.
     MOVE WS-ONE TO WS-FA
     MOVE WS-FRR TO WS-FB
     PERFORM F-SUB
     PERFORM F-RND
     MOVE WS-FRR TO WS-FA
     MOVE WS-E TO WS-FB
     PERFORM F-MUL
     PERFORM F-RND
     .
*> RADIUS-ELL (WS-RY = y, height WS-H, E): f = (1.0f - (float)(y*y) / ((float) H * 1.0f)) * (float) E; WS-R = ceil(f / 2)
 RADIUS-ELL.
     COMPUTE WS-YY = WS-RY * WS-RY
     MOVE WS-YY TO WS-FA
     MOVE WS-H TO WS-FB
     PERFORM F-DIV
     PERFORM F-RND
     PERFORM FINISH-RADIUS
     PERFORM CEIL-HALF
     .
*> RADIUS-ROUND (WS-RY = y, height WS-H, E): u = 3.5f - nextFloat(); then the two nextInt of the document
 RADIUS-ROUND.
     CALL "WGR-NEXT-FLOAT" USING L-STATE WS-NF
     MOVE WS-F35 TO WS-FA
     MOVE WS-NF TO WS-FB
     PERFORM F-SUB
     PERFORM F-RND
     MOVE WS-FRR TO WS-U
*>   (float) H * u
     MOVE WS-H TO WS-FA
     MOVE WS-U TO WS-FB
     PERFORM F-MUL
     PERFORM F-RND
     MOVE WS-FRR TO WS-HU
     COMPUTE WS-YY = WS-RY * WS-RY
     MOVE WS-YY TO WS-FA
     MOVE WS-HU TO WS-FB
     PERFORM F-DIV
     PERFORM F-RND
     PERFORM FINISH-RADIUS
     MOVE WS-FRR TO WS-FKEEP
     MOVE 5 TO WS-BOUND
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DRAW
     COMPUTE WS-TT = 15 + WS-DRAW
     IF WS-H > WS-TT
         MOVE 6 TO WS-BOUND
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DRAW
         COMPUTE WS-TT = 3 + WS-DRAW
         IF WS-RY < WS-TT
             COMPUTE WS-Y2 = WS-RY / 2
         ELSE
             MOVE WS-RY TO WS-Y2
         END-IF
*>       f = (1.0f - (float) y2 / ((float) H * u * 0.4f)) * (float) E
         MOVE WS-HU TO WS-FA
         MOVE WS-F04 TO WS-FB
         PERFORM F-MUL
         PERFORM F-RND
         MOVE WS-FRR TO WS-FB
         MOVE WS-Y2 TO WS-FA
         PERFORM F-DIV
         PERFORM F-RND
         PERFORM FINISH-RADIUS
         MOVE WS-FRR TO WS-FKEEP
     END-IF
     MOVE WS-FKEEP TO WS-FRR
     PERFORM CEIL-HALF
     .
*> RADIUS-STEEP (WS-RY = y, height WS-HGT, E): u = 1.0f + nextFloat() / 2.0f; f = (1.0f - (float) y / ((float) D * u)) * (float) E
 RADIUS-STEEP.
     CALL "WGR-NEXT-FLOAT" USING L-STATE WS-NF
     MOVE WS-NF TO WS-FA
     MOVE WS-TWO TO WS-FB
     PERFORM F-DIV
     MOVE WS-ONE TO WS-FA
     MOVE WS-FRR TO WS-FB
     PERFORM F-ADD
     PERFORM F-RND
     MOVE WS-FRR TO WS-U
     MOVE WS-HGT TO WS-FA
     MOVE WS-U TO WS-FB
     PERFORM F-MUL
     PERFORM F-RND
     MOVE WS-FRR TO WS-FB
     MOVE WS-RY TO WS-FA
     PERFORM F-DIV
     PERFORM F-RND
     PERFORM FINISH-RADIUS
     PERFORM CEIL-HALF
     .
*> WY-FINISH: WS-WY = ceil(W * (1.0f - q)) from WS-FRR = q
 WY-FINISH.
     MOVE WS-ONE TO WS-FA
     MOVE WS-FRR TO WS-FB
     PERFORM F-SUB
     PERFORM F-RND
     MOVE WS-W TO WS-FA
     MOVE WS-FRR TO WS-FB
     PERFORM F-MUL
     PERFORM F-RND
     CALL STATIC "cc_f64_ceil" USING BY REFERENCE WS-FRR WS-FR2
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-FR2 WS-WY
     .
*> ELLIPSE-DIST: WS-DIST-NEG 1 when the distance of (WS-EDX, WS-EDZ) to an ellipse of half axes WS-EA and WS-EB turned by the angle of WS-ECOS, WS-ESIN is negative
*> (((dx cos - dz sin) / a)^2 + ((dx sin + dz cos) / b)^2 - 1, each operation one IEEE double step; a zero axis divides to infinity or NaN, which is never negative); WS-DIST holds the value
 ELLIPSE-DIST.
     COMPUTE WS-DX = WS-EDX
     COMPUTE WS-DZ = WS-EDZ
     COMPUTE WS-AXF = WS-EA
     COMPUTE WS-BXF = WS-EB
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-DX WS-ECOS WS-M1
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-DZ WS-ESIN WS-M2
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-M1 WS-M2 WS-P1
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-P1 WS-AXF WS-P2
     MOVE WS-P2 TO WS-P2B
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-P2 WS-P2B WS-P3
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-DX WS-ESIN WS-M1
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-DZ WS-ECOS WS-M2
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-M1 WS-M2 WS-Q1
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-Q1 WS-BXF WS-Q2
     MOVE WS-Q2 TO WS-Q2B
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-Q2 WS-Q2B WS-Q3F
     CALL STATIC "cc_f64_add" USING BY REFERENCE WS-P3 WS-Q3F WS-S1
     CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-S1 WS-ONE WS-DIST
     MOVE WS-DIST TO WS-U1
     MOVE WS-ZERO-D TO WS-U2
     PERFORM SIGN-OF-DIFF
     MOVE 0 TO WS-DIST-NEG
     IF WS-SG < 0
         MOVE 1 TO WS-DIST-NEG
     END-IF
     .
*> PLACE-BLOCK (9.4): height WS-PH, offsets WS-PX WS-PY WS-PZ, radius WS-PR, width WS-PW
 PLACE-BLOCK.
     IF WS-ELL = 1
         MOVE WS-PX TO WS-EDX
         MOVE WS-PZ TO WS-EDZ
         MOVE WS-PW TO WS-EA
*>       ellipseC(y, height, B): B, less 4 - (H - y) when y > 0 and H - y <= 3
         MOVE WS-B TO WS-EC
         IF WS-PY > 0 AND WS-PH - WS-PY <= 3
             COMPUTE WS-EC = WS-B - (4 - (WS-PH - WS-PY))
         END-IF
         MOVE WS-EC TO WS-EB
         MOVE WS-COS TO WS-ECOS
         MOVE WS-SIN TO WS-ESIN
         PERFORM ELLIPSE-DIST
     ELSE
*>       circleDist: k = 10.0f * clamp(nextFloat(), 0.2f, 0.8f) / (float) radius; (double) k + x^2 + z^2 - radius^2
         CALL "WGR-NEXT-FLOAT" USING L-STATE WS-NF
         MOVE WS-NF TO WS-FA
         CALL STATIC "cc_f64_clamp_f32" USING BY REFERENCE WS-FA WS-F02 WS-F08 WS-FRR
         MOVE WS-F10 TO WS-FA
         MOVE WS-FRR TO WS-FB
         PERFORM F-MUL
         PERFORM F-RND
         MOVE WS-FRR TO WS-FA
         MOVE WS-PR TO WS-FB
         PERFORM F-DIV
         PERFORM F-RND
         COMPUTE WS-YY = WS-PX * WS-PX + WS-PZ * WS-PZ - WS-PR * WS-PR
         MOVE WS-YY TO WS-FB
         MOVE WS-FRR TO WS-FA
         PERFORM F-ADD
         MOVE WS-FRR TO WS-DIST
         MOVE WS-DIST TO WS-U1
         MOVE WS-ZERO-D TO WS-U2
         PERFORM SIGN-OF-DIFF
         MOVE 0 TO WS-DIST-NEG
         IF WS-SG < 0
             MOVE 1 TO WS-DIST-NEG
         END-IF
     END-IF
     IF WS-DIST-NEG = 1
         COMPUTE WS-QX = WS-OX + WS-PX
         COMPUTE WS-QY = WS-OY + WS-PY
         COMPUTE WS-QZ = WS-OZ + WS-PZ
         IF WS-ELL = 1
             MOVE WS-HALF TO WS-LIMIT
         ELSE
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B3 WS-DRAW
             COMPUTE WS-LIMIT = -6 - WS-DRAW
         END-IF
         MOVE WS-DIST TO WS-U1
         MOVE WS-LIMIT TO WS-U2
         PERFORM SIGN-OF-DIFF
         MOVE 0 TO WS-OKF
         IF WS-SG > 0
             MOVE 0.9 TO WS-THRESH
             PERFORM NEXT-DOUBLE-GT
             IF WS-GT = 1
                 MOVE 1 TO WS-OKF
             END-IF
         END-IF
         IF WS-OKF = 0
             COMPUTE WS-REM = WS-PH - WS-PY
             MOVE WS-PH TO WS-HGT
             PERFORM SET-ICEBERG-BLOCK
         END-IF
     END-IF
     .
*> SET-ICEBERG-BLOCK (9.4): position WS-QX WS-QY WS-QZ, remaining WS-REM, height WS-HGT
 SET-ICEBERG-BLOCK.
     CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     IF WS-CLASS = 1 OR WS-CLASS = 2 OR WS-BLOCK = WA-I(WS-ROW, 2) OR WS-BLOCK = WA-I(WS-ROW, 3)
         MOVE 1 TO WS-OKF
         MOVE 2 TO WS-DIV
         IF WS-ELL = 1
             MOVE 0.05 TO WS-THRESH
             PERFORM NEXT-DOUBLE-GT
             MOVE WS-GT TO WS-OKF
             MOVE 3 TO WS-DIV
         END-IF
         MOVE 0 TO WS-GT
         IF WS-SNOW = 1 AND WS-CLASS NOT = 2
             COMPUTE WS-BOUND = WS-HGT / WS-DIV
             IF WS-BOUND < 1
                 MOVE 1 TO WS-BOUND
             END-IF
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-TT
*>           (double) remaining <= t + height * 0.6, in tenths
             COMPUTE WS-LHS = 5 * WS-REM
             COMPUTE WS-RHS = 5 * WS-TT + 3 * WS-HGT
             IF WS-LHS <= WS-RHS AND WS-OKF = 1
                 MOVE 1 TO WS-GT
             END-IF
         END-IF
         IF WS-GT = 1
             CALL "FL-SET-STATE" USING WS-QX WS-QY WS-QZ WA-I(WS-ROW, 7) WS-FLAGS WS-WRITTEN
         ELSE
             CALL "FL-SET-STATE" USING WS-QX WS-QY WS-QZ WA-I(WS-ROW, 1) WS-FLAGS WS-WRITTEN
         END-IF
     END-IF
     .
*> ICEBERG-BLOCK-AT: WS-ICEB 1 when the block at WS-QX WS-QY WS-QZ is packed_ice, snow_block or blue_ice
 ICEBERG-BLOCK-AT.
     CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     MOVE 0 TO WS-ICEB
     IF WS-BLOCK = WA-I(WS-ROW, 2) OR WS-BLOCK = WA-I(WS-ROW, 4) OR WS-BLOCK = WA-I(WS-ROW, 5)
         MOVE 1 TO WS-ICEB
     END-IF
     .
*> SMOOTH (9.5)
 SMOOTH.
     IF WS-ELL = 1
         MOVE WS-A TO WS-RAD
     ELSE
         COMPUTE WS-RAD = WS-E / 2
     END-IF
     COMPUTE WS-SX = 0 - WS-RAD
     PERFORM VARYING WS-GX FROM WS-SX BY 1 UNTIL WS-GX > WS-RAD
         PERFORM VARYING WS-GZ FROM WS-SX BY 1 UNTIL WS-GZ > WS-RAD
             PERFORM VARYING WS-GY FROM 0 BY 1 UNTIL WS-GY > WS-H
                 COMPUTE WS-QX = WS-OX + WS-GX
                 COMPUTE WS-QY = WS-OY + WS-GY
                 COMPUTE WS-QZ = WS-OZ + WS-GZ
                 PERFORM ICEBERG-BLOCK-AT
                 IF WS-ICEB = 1 OR WS-BLOCK = WA-I(WS-ROW, 6)
                     MOVE WS-ICEB TO WS-K
                     COMPUTE WS-QY = WS-QY - 1
                     CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                     CALL "FL-CLASS" USING WS-STATE WS-CLASS
                     COMPUTE WS-QY = WS-QY + 1
                     IF WS-CLASS = 1
                         CALL "FL-SET-STATE" USING WS-QX WS-QY WS-QZ FL-S-AIR WS-FLAGS WS-WRITTEN
                         COMPUTE WS-QY = WS-QY + 1
                         CALL "FL-SET-STATE" USING WS-QX WS-QY WS-QZ FL-S-AIR WS-FLAGS WS-WRITTEN
                     ELSE
                         IF WS-K = 1
                             MOVE 0 TO WS-CNT
                             PERFORM VARYING WS-CC FROM 1 BY 1 UNTIL WS-CC > 4
                                 COMPUTE WS-QX = WS-OX + WS-GX + WS-DDX(WS-CC)
                                 COMPUTE WS-QZ = WS-OZ + WS-GZ + WS-DDZ(WS-CC)
                                 PERFORM ICEBERG-BLOCK-AT
                                 IF WS-ICEB = 0
                                     ADD 1 TO WS-CNT
                                 END-IF
                             END-PERFORM
                             IF WS-CNT >= 3
                                 COMPUTE WS-QX = WS-OX + WS-GX
                                 COMPUTE WS-QZ = WS-OZ + WS-GZ
                                 CALL "FL-SET-STATE" USING WS-QX WS-QY WS-QZ FL-S-AIR WS-FLAGS WS-WRITTEN
                             END-IF
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> CUT-OUT (9.6)
 CUT-OUT.
     CALL "F351-NEXT-BOOLEAN" USING L-STATE WS-DRAW
     IF WS-DRAW = 1
         MOVE -1 TO WS-SX
     ELSE
         MOVE 1 TO WS-SX
     END-IF
     CALL "F351-NEXT-BOOLEAN" USING L-STATE WS-DRAW
     IF WS-DRAW = 1
         MOVE -1 TO WS-SZ
     ELSE
         MOVE 1 TO WS-SZ
     END-IF
     COMPUTE WS-HALF-E = WS-E / 2
     COMPUTE WS-BOUND = WS-HALF-E - 2
     IF WS-BOUND < 1
         MOVE 1 TO WS-BOUND
     END-IF
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-OFX
     CALL "F351-NEXT-BOOLEAN" USING L-STATE WS-DRAW
     IF WS-DRAW = 1
         COMPUTE WS-BOUND = WS-E - WS-HALF-E - 1
         IF WS-BOUND < 1
             MOVE 1 TO WS-BOUND
         END-IF
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DRAW
         COMPUTE WS-OFX = WS-HALF-E + 1 - WS-DRAW
     END-IF
     COMPUTE WS-BOUND = WS-HALF-E - 2
     IF WS-BOUND < 1
         MOVE 1 TO WS-BOUND
     END-IF
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-OFZ
     CALL "F351-NEXT-BOOLEAN" USING L-STATE WS-DRAW
     IF WS-DRAW = 1
         COMPUTE WS-BOUND = WS-E - WS-HALF-E - 1
         IF WS-BOUND < 1
             MOVE 1 TO WS-BOUND
         END-IF
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DRAW
         COMPUTE WS-OFZ = WS-HALF-E + 1 - WS-DRAW
     END-IF
     IF WS-ELL = 1
         COMPUTE WS-BOUND = WS-A - 5
         IF WS-BOUND < 1
             MOVE 1 TO WS-BOUND
         END-IF
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-OFX
         MOVE WS-OFX TO WS-OFZ
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-ANGLE WS-HALF-PI WS-ANGLE2
     ELSE
         CALL "WGR-NEXT-DOUBLE" USING L-STATE WS-DBL
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-DBL WS-TWO WS-M1
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-M1 WS-PI WS-ANGLE2
     END-IF
     COMPUTE WS-CUTX = WS-SX * WS-OFX
     COMPUTE WS-CUTZ = WS-SZ * WS-OFZ
     CALL STATIC "cc_f64_cos" USING BY REFERENCE WS-ANGLE2 WS-COS2
     CALL STATIC "cc_f64_sin" USING BY REFERENCE WS-ANGLE2 WS-SIN2
     COMPUTE WS-GY = WS-H - 4
     MOVE 0 TO WS-TO-WATER
     PERFORM VARYING WS-YOFF FROM 0 BY 1 UNTIL WS-YOFF > WS-GY
         MOVE WS-YOFF TO WS-RY
         PERFORM RADIUS-ROUND
         PERFORM CARVE
     END-PERFORM
     MOVE 1 TO WS-TO-WATER
     MOVE -1 TO WS-YOFF
     MOVE 1 TO WS-GT
     PERFORM UNTIL WS-GT = 0
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B5 WS-DRAW
         COMPUTE WS-TT = 0 - WS-H + WS-DRAW
         IF WS-YOFF > WS-TT
             COMPUTE WS-RY = 0 - WS-YOFF
             MOVE WS-H TO WS-HGT
             PERFORM RADIUS-STEEP
             PERFORM CARVE
             SUBTRACT 1 FROM WS-YOFF
         ELSE
             MOVE 0 TO WS-GT
         END-IF
     END-PERFORM
     .
*> CARVE (9.6): radius WS-R, level WS-YOFF, WS-TO-WATER
 CARVE.
     DIVIDE WS-A BY 3 GIVING WS-Q3
     COMPUTE WS-WIDE = WS-R + 1 + WS-Q3
     COMPUTE WS-CC = WS-R - 3
     IF WS-CC > 3
         MOVE 3 TO WS-CC
     END-IF
     DIVIDE WS-B BY 2 GIVING WS-Q3
     COMPUTE WS-CC = WS-CC + WS-Q3 - 1
     COMPUTE WS-NWIDE = 0 - WS-WIDE
     MOVE WS-WIDE TO WS-EA
     MOVE WS-CC TO WS-EB
     MOVE WS-COS2 TO WS-ECOS
     MOVE WS-SIN2 TO WS-ESIN
     PERFORM VARYING WS-GX FROM WS-NWIDE BY 1 UNTIL WS-GX >= WS-WIDE
         PERFORM VARYING WS-GZ FROM WS-NWIDE BY 1 UNTIL WS-GZ >= WS-WIDE
             COMPUTE WS-EDX = WS-GX - WS-CUTX
             COMPUTE WS-EDZ = WS-GZ - WS-CUTZ
             PERFORM ELLIPSE-DIST
             IF WS-DIST-NEG = 1
                 COMPUTE WS-QX = WS-OX + WS-GX
                 COMPUTE WS-QY = WS-OY + WS-YOFF
                 COMPUTE WS-QZ = WS-OZ + WS-GZ
                 PERFORM ICEBERG-BLOCK-AT
                 IF WS-ICEB = 1
                     IF WS-TO-WATER = 1
                         MOVE CB-DEFAULT-STATE(FL-B-WATER) TO WS-WATER-STATE
                         CALL "FL-SET-STATE" USING WS-QX WS-QY WS-QZ WS-WATER-STATE WS-FLAGS WS-WRITTEN
                     ELSE
                         CALL "FL-SET-STATE" USING WS-QX WS-QY WS-QZ FL-S-AIR WS-FLAGS WS-WRITTEN
                         COMPUTE WS-QY = WS-QY + 1
                         CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                         CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                         IF WS-BLOCK = WA-I(WS-ROW, 6)
                             CALL "FL-SET-STATE" USING WS-QX WS-QY WS-QZ FL-S-AIR WS-FLAGS WS-WRITTEN
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     .
 MAIN-EXIT.
     CONTINUE.
 END PROGRAM FR-ICEBERG.
