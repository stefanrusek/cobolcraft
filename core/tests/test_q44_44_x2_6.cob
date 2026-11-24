*> Acceptance test of docs/protocol/44-residual-mob-questions-x2-continuation.md section 6 as rule functions (lane 002-lane-p49j-b, T24400 range): the projectile residuals: llama spit particle factors, snowball damage to a blaze, egg hatching counts and the deflection rule of 6.4 with the breeze override.

*> The functions of core/src/q44-44-x2.cob are not called by a tick (no engine for them yet, see the lane task list).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-X2-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASE                PIC X(160).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                  FLOAT-LONG.
 01 WS-B                  FLOAT-LONG.
 01 WS-C                  FLOAT-LONG.
 01 WS-D                  FLOAT-LONG.
 01 WS-E                  FLOAT-LONG.
 01 WS-F                  FLOAT-LONG.
 01 WS-G                  FLOAT-LONG.
 01 WS-H                  FLOAT-LONG.
 01 WS-J                  FLOAT-LONG.
 01 WS-K                  FLOAT-LONG.
 01 WS-N1                 BINARY-LONG.
 01 WS-N2                 BINARY-LONG.
 01 WS-N3                 BINARY-LONG.
 01 WS-N4                 BINARY-LONG.
 01 WS-N5                 BINARY-LONG.
 01 WS-N6                 BINARY-LONG.
 01 WS-N7                 BINARY-LONG.
 01 WS-N8                 BINARY-LONG.
 01 WS-N9                 BINARY-LONG.
 01 WS-N10                 BINARY-LONG.
 01 WS-N11                 BINARY-LONG.
 01 WS-N12                 BINARY-LONG.
 01 WS-CHAIN.
    05 WS-LEVEL OCCURS 5 TIMES.
       10 WS-AMP            BINARY-LONG.
       10 WS-DUR            BINARY-LONG.
       10 WS-ACTIVE         BINARY-LONG.
 01 WS-TAB.
    05 WS-TN                BINARY-LONG.
    05 WS-TC OCCURS 6 TIMES.
       10 WS-TA             BINARY-LONG.
       10 WS-TB             BINARY-LONG.
       10 WS-TD             BINARY-LONG.
 01 WS-COL.
    05 WS-CELL OCCURS 14 TIMES.
       10 WS-CE             BINARY-LONG.
       10 WS-CF             BINARY-LONG.
 01 WS-S1                  PIC X(32).
 01 WS-S2                  PIC X(32).
 01 WS-S3                  PIC X(32).
 01 WS-S4                  PIC X(32).
 01 WS-S5                  PIC X(32).
 01 WS-S6                  PIC X(32).
 PROCEDURE DIVISION.
     MOVE 0 TO WS-N1
     CALL "X2-SPIT-FACTOR" USING WS-N1 WS-A
     MOVE "acceptance US15 44-x2§6 6.2 llama spit particle 0 velocity factor 0.4 (thousandths)" TO WS-CASE
     MOVE 400 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 3 TO WS-N1
     CALL "X2-SPIT-FACTOR" USING WS-N1 WS-A
     MOVE "acceptance US15 44-x2§6 6.2 llama spit particle 3 velocity factor 0.7 (thousandths)" TO WS-CASE
     MOVE 700 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 6 TO WS-N1
     CALL "X2-SPIT-FACTOR" USING WS-N1 WS-A
     MOVE "acceptance US15 44-x2§6 6.2 llama spit particle 6 velocity factor 1.0 (thousandths)" TO WS-CASE
     MOVE 1000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     CALL "X2-SNOWBALL-DAMAGE" USING WS-N1 WS-N2
     MOVE "acceptance US15 44-x2§6 6.2 a snowball hit on a blaze does 3" TO WS-CASE
     MOVE 3 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     CALL "X2-SNOWBALL-DAMAGE" USING WS-N1 WS-N2
     MOVE "acceptance US15 44-x2§6 6.2 any other target takes 0" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 3 TO WS-N1
     MOVE 0 TO WS-N2
     CALL "X2-EGG-COUNT" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§6 6.2 an egg with nextInt(8) = 3 hatches nothing" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 5 TO WS-N2
     CALL "X2-EGG-COUNT" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§6 6.2 nextInt(8) = 0 and nextInt(32) = 5 hatches one chick" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     CALL "X2-EGG-COUNT" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§6 6.2 nextInt(8) = 0 and nextInt(32) = 0 hatches four" TO WS-CASE
     MOVE 4 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-DEFLECT-KIND" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§6 6.4 an entity of tag deflects_projectiles reverses a projectile" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-DEFLECT-KIND" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§6 6.4 an entity outside the tag does not" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-DEFLECT-KIND" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§6 6.4 a breeze in the tag deflects other projectiles with its own deflection (sound, then reverse)" TO WS-CASE
     MOVE 2 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "X2-DEFLECT-KIND" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§6 6.4 a breeze does not deflect a wind charge" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-DEFLECT-KIND" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§6 6.4 a breeze outside the tag does not deflect" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 END PROGRAM TEST-Q44-44-X2-6.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(160).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.
