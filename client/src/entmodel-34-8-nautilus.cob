*> Entity models part 8, the nautilus layers and animation (docs/protocol/34-entity-models-8-aquatic-nautilus-boats.md 6.3, 6.4, Appendix A.2): EF8-M-NAUTILUS-SADDLE
*> (nautilus_saddle: the shell is one box grown 0.2, the body subtree is kept), EF8-M-NAUTILUS-ARMOR (nautilus_armor: the three shell boxes, the first two grown 0.01) and
*> EF8-M-NAUTILUS-CORAL (zombie_nautilus_coral: the adult mesh and the corals) USING model, and EF8-NAUTILUS-ANIM USING model, state (16 FLOAT-LONG: 1 xRot, 2 yRot
*> degrees, 3 walk position, 4 walk speed, 5 ageInTicks): NautilusModel.setupAnim, the body angles clamped to 10 degrees and the SWIMMING keyframes (linear, 1 s, looping).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-M-NAUTILUS-SADDLE.
*> USING model: the saddle layer (6.3, 128 x 128).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS1.
    05 FILLER PIC X(100) VALUE "P nroot root 0 29 -6 0 0 0".
    05 FILLER PIC X(100) VALUE "P shell nroot 0 -13 5 0 0 0".
    05 FILLER PIC X(100) VALUE "C shell 0 0 -7 -10 -7 14 10 16 0.2 0".
    05 FILLER PIC X(100) VALUE "P body nroot 0 -8.5 12.3 0 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 54 -5 -4.51 -3 10 8 14 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 76 -5 -4.51 7 10 8 0 0 0".
    05 FILLER PIC X(100) VALUE "P upper_mouth body 0 -2.51 7 0 0 0".
    05 FILLER PIC X(100) VALUE "C upper_mouth 54 54 -5 -2 0 10 4 4 -0.001 0".
    05 FILLER PIC X(100) VALUE "P inner_mouth body 0 -0.51 7.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C inner_mouth 54 70 -3 -2 -0.5 6 4 4 0 0".
    05 FILLER PIC X(100) VALUE "P lower_mouth body 0 1.49 7 0 0 0".
    05 FILLER PIC X(100) VALUE "C lower_mouth 54 62 -5 -1.98 0 10 4 4 -0.001 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 68 TIMES.
 01 WS-ROWS1-R REDEFINES WS-ROWS1.
    05 WS-ROW1             PIC X(100) OCCURS 80 TIMES.
 01 WS-N1                  BINARY-LONG VALUE 12.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS1-R WS-N1 WS-ZERO
     MOVE 128 TO MM-TEXW
     MOVE 128 TO MM-TEXH
     GOBACK.
 END PROGRAM EF8-M-NAUTILUS-SADDLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-M-NAUTILUS-ARMOR.
*> USING model: the body armor layer (6.3, 128 x 128).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS1.
    05 FILLER PIC X(100) VALUE "P nroot root 0 29 -6 0 0 0".
    05 FILLER PIC X(100) VALUE "P shell nroot 0 -13 5 0 0 0".
    05 FILLER PIC X(100) VALUE "C shell 0 0 -7 -10 -7 14 10 16 0.01 0".
    05 FILLER PIC X(100) VALUE "C shell 0 26 -7 0 -7 14 8 20 0.01 0".
    05 FILLER PIC X(100) VALUE "C shell 48 26 -7 0 6 14 8 0 0 0".
    05 FILLER PIC X(100) VALUE "P body nroot 0 -8.5 12.3 0 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 54 -5 -4.51 -3 10 8 14 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 76 -5 -4.51 7 10 8 0 0 0".
    05 FILLER PIC X(100) VALUE "P upper_mouth body 0 -2.51 7 0 0 0".
    05 FILLER PIC X(100) VALUE "C upper_mouth 54 54 -5 -2 0 10 4 4 -0.001 0".
    05 FILLER PIC X(100) VALUE "P inner_mouth body 0 -0.51 7.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C inner_mouth 54 70 -3 -2 -0.5 6 4 4 0 0".
    05 FILLER PIC X(100) VALUE "P lower_mouth body 0 1.49 7 0 0 0".
    05 FILLER PIC X(100) VALUE "C lower_mouth 54 62 -5 -1.98 0 10 4 4 -0.001 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 66 TIMES.
 01 WS-ROWS1-R REDEFINES WS-ROWS1.
    05 WS-ROW1             PIC X(100) OCCURS 80 TIMES.
 01 WS-N1                  BINARY-LONG VALUE 14.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS1-R WS-N1 WS-ZERO
     MOVE 128 TO MM-TEXW
     MOVE 128 TO MM-TEXH
     GOBACK.
 END PROGRAM EF8-M-NAUTILUS-ARMOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-M-NAUTILUS-CORAL.
*> USING model: the warm zombie nautilus (6.4, 128 x 128).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS1.
    05 FILLER PIC X(100) VALUE "P nroot root 0 29 -6 0 0 0".
    05 FILLER PIC X(100) VALUE "P shell nroot 0 -13 5 0 0 0".
    05 FILLER PIC X(100) VALUE "C shell 0 0 -7 -10 -7 14 10 16 0 0".
    05 FILLER PIC X(100) VALUE "C shell 0 26 -7 0 -7 14 8 20 0 0".
    05 FILLER PIC X(100) VALUE "C shell 48 26 -7 0 6 14 8 0 0 0".
    05 FILLER PIC X(100) VALUE "P body nroot 0 -8.5 12.3 0 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 54 -5 -4.51 -3 10 8 14 0 0".
    05 FILLER PIC X(100) VALUE "C body 0 76 -5 -4.51 7 10 8 0 0 0".
    05 FILLER PIC X(100) VALUE "P upper_mouth body 0 -2.51 7 0 0 0".
    05 FILLER PIC X(100) VALUE "C upper_mouth 54 54 -5 -2 0 10 4 4 -0.001 0".
    05 FILLER PIC X(100) VALUE "P inner_mouth body 0 -0.51 7.5 0 0 0".
    05 FILLER PIC X(100) VALUE "C inner_mouth 54 70 -3 -2 -0.5 6 4 4 0 0".
    05 FILLER PIC X(100) VALUE "P lower_mouth body 0 1.49 7 0 0 0".
    05 FILLER PIC X(100) VALUE "C lower_mouth 54 62 -5 -1.98 0 10 4 4 -0.001 0".
    05 FILLER PIC X(100) VALUE "P corals shell 8 4.5 -8 0 0 0".
    05 FILLER PIC X(100) VALUE "P yellow_coral corals 0 -11 11 0 0 0".
    05 FILLER PIC X(100) VALUE "P yellow_coral_second yellow_coral 0 0 2 0 -0.7854 0".
    05 FILLER PIC X(100) VALUE "C yellow_coral_second 0 85 -4.5 -3.5 0 6 8 0 0 0".
    05 FILLER PIC X(100) VALUE "P yellow_coral_first yellow_coral 0 0 0 0 0.7854 0".
    05 FILLER PIC X(100) VALUE "C yellow_coral_first 0 85 -4.5 -3.5 0 6 8 0 0 0".
    05 FILLER PIC X(100) VALUE "P pink_coral corals -12.5 -18 11 0 0 0".
    05 FILLER PIC X(100) VALUE "C pink_coral -8 94 -4.5 4.5 0 6 0 8 0 0".
    05 FILLER PIC X(100) VALUE "P pink_coral_second pink_coral -1.5 4.5 4 0 0 1.5708".
    05 FILLER PIC X(100) VALUE "C pink_coral_second -8 94 -3 0 -4 6 0 8 0 0".
    05 FILLER PIC X(100) VALUE "P blue_coral corals -14 0 5.5 0 0 0".
    05 FILLER PIC X(100) VALUE "P blue_second blue_coral 0 0 -2 0 0.7854 0".
    05 FILLER PIC X(100) VALUE "C blue_second 0 102 -3.5 -5.5 0 5 10 0 0 0".
    05 FILLER PIC X(100) VALUE "P blue_first blue_coral 0 0 0 0 -0.7854 0".
    05 FILLER PIC X(100) VALUE "C blue_first 0 102 -3.5 -5.5 0 5 10 0 0 0".
    05 FILLER PIC X(100) VALUE "P red_coral corals 0 0 0 0 0 0".
    05 FILLER PIC X(100) VALUE "P red_coral_second red_coral -0.5 -1 1.5 0 -0.829 0".
    05 FILLER PIC X(100) VALUE "C red_coral_second 0 112 -2.5 -5.5 0 4 10 0 0 0".
    05 FILLER PIC X(100) VALUE "P red_coral_first red_coral 0 0 0 0 0.7854 0".
    05 FILLER PIC X(100) VALUE "C red_coral_first 0 112 -4.5 -5.5 0 6 10 0 0 0".
    05 FILLER PIC X(100) VALUE SPACES OCCURS 46 TIMES.
 01 WS-ROWS1-R REDEFINES WS-ROWS1.
    05 WS-ROW1             PIC X(100) OCCURS 80 TIMES.
 01 WS-N1                  BINARY-LONG VALUE 34.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLEMM.
 PROCEDURE DIVISION USING EMM-MODEL.
     CALL "EMM-INIT" USING EMM-MODEL
     CALL "EM3-ROWS" USING EMM-MODEL WS-ROWS1-R WS-N1 WS-ZERO
     MOVE 128 TO MM-TEXW
     MOVE 128 TO MM-TEXH
     GOBACK.
 END PROGRAM EF8-M-NAUTILUS-CORAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-NAUTILUS-ANIM.
*> USING model, state (16 FLOAT-LONG: 1 xRot, 2 yRot degrees, 3 walk position, 4 walk speed, 5 ageInTicks): reset first, then body.yRot and body.xRot set to the
*> state's angles clamped to -10 to 10 degrees (6.3 step 1) and SWIMMING.applyWalk(pos + age / 5, speed + 0.2, 2, 3) (step 2): time (long)((pos + age / 5) x 100) ms,
*> looped over 1 s, strength min((speed + 0.2) x 3, 1); each of the eight channels of A.2 (part 1 body, 2 upper mouth, 3 inner mouth, 4 lower mouth; target 1 x rotation in
*> degrees, 2 3 4 scale x y z, values at the times 0, 0.5, 0.75, 0.875, 1 in tenths) is interpolated linearly and added, times the strength (a scale as the factor minus 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CH-DATA.
    05 FILLER PIC X(22) VALUE "14+000+002-001+000+000".
    05 FILLER PIC X(22) VALUE "21+000+300+000+000+000".
    05 FILLER PIC X(22) VALUE "24+000+004-001+000+000".
    05 FILLER PIC X(22) VALUE "32+000-002+000+000+000".
    05 FILLER PIC X(22) VALUE "33+000-002+000+000+000".
    05 FILLER PIC X(22) VALUE "34+000+000-001+000+000".
    05 FILLER PIC X(22) VALUE "41+000-300+000+000+000".
    05 FILLER PIC X(22) VALUE "44+000+004-001+000+000".
 01 WS-CH-TABLE REDEFINES WS-CH-DATA.
    05 WS-CH OCCURS 8 TIMES.
       10 WS-CH-PART       PIC 9.
       10 WS-CH-TARGET     PIC 9.
       10 WS-CH-V          PIC S99V9 SIGN LEADING SEPARATE OCCURS 5 TIMES.
 01 WS-TIMES-DATA.
    05 FILLER PIC 9V999 VALUE 0.
    05 FILLER PIC 9V999 VALUE 0.5.
    05 FILLER PIC 9V999 VALUE 0.75.
    05 FILLER PIC 9V999 VALUE 0.875.
    05 FILLER PIC 9V999 VALUE 1.
 01 WS-TIMES REDEFINES WS-TIMES-DATA.
    05 WS-T                PIC 9V999 OCCURS 5 TIMES.
 01 WS-PARTS.
    05 WS-PI               BINARY-LONG OCCURS 4 TIMES.
 01 WS-NAME                PIC X(24).
 01 WS-MS                  BINARY-LONG.
 01 WS-TIME                FLOAT-LONG.
 01 WS-STRENGTH            FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLEMM.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING EMM-MODEL L-IN.
     CALL "EMM-RESET" USING EMM-MODEL
     MOVE "body" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-PI(1)
     MOVE "upper_mouth" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-PI(2)
     MOVE "inner_mouth" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-PI(3)
     MOVE "lower_mouth" TO WS-NAME
     CALL "EMM-FIND" USING EMM-MODEL WS-NAME WS-PI(4)
     COMPUTE MM-CYROT(WS-PI(1)) = FUNCTION MIN(FUNCTION MAX(L-I(2), -10), 10) * 0.017453292
     COMPUTE MM-CXROT(WS-PI(1)) = FUNCTION MIN(FUNCTION MAX(L-I(1), -10), 10) * 0.017453292
     COMPUTE WS-MS = FUNCTION INTEGER-PART((L-I(3) + L-I(5) / 5) * 100)
     COMPUTE WS-TIME = WS-MS / 1000
     COMPUTE WS-TIME = WS-TIME - FUNCTION INTEGER(WS-TIME)
     COMPUTE WS-STRENGTH = FUNCTION MIN((L-I(4) + 0.2) * 3, 1)
     MOVE 4 TO WS-K
     PERFORM VARYING WS-C FROM 4 BY -1 UNTIL WS-C < 1
         IF WS-T(WS-C) > WS-TIME
             COMPUTE WS-K = WS-C - 1
         END-IF
     END-PERFORM
     COMPUTE WS-F = (WS-TIME - WS-T(WS-K)) / (WS-T(WS-K + 1) - WS-T(WS-K))
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 8
         COMPUTE WS-V = (WS-CH-V(WS-C, WS-K) + (WS-CH-V(WS-C, WS-K + 1) - WS-CH-V(WS-C, WS-K)) * WS-F) * WS-STRENGTH
         MOVE WS-PI(WS-CH-PART(WS-C)) TO WS-P
         EVALUATE WS-CH-TARGET(WS-C)
             WHEN 1
                 COMPUTE MM-CXROT(WS-P) = MM-CXROT(WS-P) + WS-V * 0.017453292
             WHEN 2
                 COMPUTE MM-CXSCALE(WS-P) = MM-CXSCALE(WS-P) + WS-V
             WHEN 3
                 COMPUTE MM-CYSCALE(WS-P) = MM-CYSCALE(WS-P) + WS-V
             WHEN OTHER
                 COMPUTE MM-CZSCALE(WS-P) = MM-CZSCALE(WS-P) + WS-V
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM EF8-NAUTILUS-ANIM.
