*> Acceptance test of docs/protocol/44-residual-mob-questions-x2-continuation.md section 7 as rule functions (lane 002-lane-p49j-b, T24400 range): TryLaySpawnOnFluidNearLand, CopyMemoryWithExpiry and the tadpole growth with the feeding worked example.

*> The functions of core/src/q44-44-x2.cob are not called by a tick (no engine for them yet, see the lane task list).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-X2-7.
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
     INITIALIZE WS-TAB
     MOVE 4 TO WS-TN
     MOVE 1 TO WS-TA(1)
     MOVE 1 TO WS-TB(1)
     MOVE 1 TO WS-TD(1)
     MOVE 1 TO WS-TA(2)
     MOVE 1 TO WS-TB(2)
     MOVE 1 TO WS-TD(2)
     MOVE 1 TO WS-TA(3)
     MOVE 1 TO WS-TB(3)
     MOVE 1 TO WS-TD(3)
     MOVE 1 TO WS-TA(4)
     MOVE 1 TO WS-TB(4)
     MOVE 1 TO WS-TD(4)
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     CALL "X2-FROG-LAY" USING WS-N1 WS-N2 WS-TAB WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§7 7.1 a frog in water fails" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     INITIALIZE WS-TAB
     MOVE 4 TO WS-TN
     MOVE 1 TO WS-TA(1)
     MOVE 1 TO WS-TB(1)
     MOVE 1 TO WS-TD(1)
     MOVE 1 TO WS-TA(2)
     MOVE 1 TO WS-TB(2)
     MOVE 1 TO WS-TD(2)
     MOVE 1 TO WS-TA(3)
     MOVE 1 TO WS-TB(3)
     MOVE 1 TO WS-TD(3)
     MOVE 1 TO WS-TA(4)
     MOVE 1 TO WS-TB(4)
     MOVE 1 TO WS-TD(4)
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     CALL "X2-FROG-LAY" USING WS-N1 WS-N2 WS-TAB WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§7 7.1 a frog off the ground fails" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     INITIALIZE WS-TAB
     MOVE 4 TO WS-TN
     MOVE 1 TO WS-TA(1)
     MOVE 1 TO WS-TB(1)
     MOVE 1 TO WS-TD(1)
     MOVE 1 TO WS-TA(2)
     MOVE 1 TO WS-TB(2)
     MOVE 1 TO WS-TD(2)
     MOVE 1 TO WS-TA(3)
     MOVE 1 TO WS-TB(3)
     MOVE 1 TO WS-TD(3)
     MOVE 1 TO WS-TA(4)
     MOVE 1 TO WS-TB(4)
     MOVE 1 TO WS-TD(4)
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     CALL "X2-FROG-LAY" USING WS-N1 WS-N2 WS-TAB WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§7 7.1 the first passing direction (north) gets the spawn" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§7 7.1 and the pregnancy is erased" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     INITIALIZE WS-TAB
     MOVE 4 TO WS-TN
     MOVE 0 TO WS-TA(1)
     MOVE 1 TO WS-TB(1)
     MOVE 1 TO WS-TD(1)
     MOVE 1 TO WS-TA(2)
     MOVE 1 TO WS-TB(2)
     MOVE 1 TO WS-TD(2)
     MOVE 1 TO WS-TA(3)
     MOVE 1 TO WS-TB(3)
     MOVE 1 TO WS-TD(3)
     MOVE 1 TO WS-TA(4)
     MOVE 1 TO WS-TB(4)
     MOVE 1 TO WS-TD(4)
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     CALL "X2-FROG-LAY" USING WS-N1 WS-N2 WS-TAB WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§7 7.1 north closed on top: east is chosen" TO WS-CASE
     MOVE 2 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     INITIALIZE WS-TAB
     MOVE 4 TO WS-TN
     MOVE 0 TO WS-TA(1)
     MOVE 1 TO WS-TB(1)
     MOVE 1 TO WS-TD(1)
     MOVE 0 TO WS-TA(2)
     MOVE 1 TO WS-TB(2)
     MOVE 1 TO WS-TD(2)
     MOVE 0 TO WS-TA(3)
     MOVE 1 TO WS-TB(3)
     MOVE 1 TO WS-TD(3)
     MOVE 1 TO WS-TA(4)
     MOVE 1 TO WS-TB(4)
     MOVE 1 TO WS-TD(4)
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     CALL "X2-FROG-LAY" USING WS-N1 WS-N2 WS-TAB WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§7 7.1 only west passes: west (4)" TO WS-CASE
     MOVE 4 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     INITIALIZE WS-TAB
     MOVE 4 TO WS-TN
     MOVE 1 TO WS-TA(1)
     MOVE 0 TO WS-TB(1)
     MOVE 1 TO WS-TD(1)
     MOVE 1 TO WS-TA(2)
     MOVE 1 TO WS-TB(2)
     MOVE 0 TO WS-TD(2)
     MOVE 0 TO WS-TA(3)
     MOVE 1 TO WS-TB(3)
     MOVE 1 TO WS-TD(3)
     MOVE 0 TO WS-TA(4)
     MOVE 1 TO WS-TB(4)
     MOVE 1 TO WS-TD(4)
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     CALL "X2-FROG-LAY" USING WS-N1 WS-N2 WS-TAB WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§7 7.1 not supporting frogspawn: skipped" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§7 7.1 with no passing direction the trigger still returns true" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§7 7.1 and keeps the pregnancy" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "X2-COPY-MEMORY" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§7 7.2 copy memory: source present, target absent, predicate true" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-COPY-MEMORY" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§7 7.2 not when the predicate is false" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "X2-COPY-MEMORY" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§7 7.2 not when the target is already present" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "X2-COPY-MEMORY" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§7 7.2 not without the source" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     CALL "X2-TADPOLE-FEED" USING WS-N1 WS-N2
     MOVE "acceptance US15 44-x2§7 7.3 a fresh tadpole fed: +2400 ticks" TO WS-CASE
     MOVE 2400 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 23000 TO WS-N1
     CALL "X2-TADPOLE-FEED" USING WS-N1 WS-N2
     MOVE "acceptance US15 44-x2§7 7.3 worked example: age 23000 fed gives 23100" TO WS-CASE
     MOVE 23100 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 23100 TO WS-N1
     CALL "X2-TADPOLE-FEED" USING WS-N1 WS-N2
     MOVE "acceptance US15 44-x2§7 7.3 worked example: age 23100 fed gives 23180 (4.5 truncated to 4)" TO WS-CASE
     MOVE 23180 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 24500 TO WS-N1
     CALL "X2-TADPOLE-FEED" USING WS-N1 WS-N2
     MOVE "acceptance US15 44-x2§7 7.3 an age past 24000 adds nothing" TO WS-CASE
     MOVE 24500 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 100 TO WS-N1
     MOVE 0 TO WS-N2
     CALL "X2-TADPOLE-TICK" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§7 7.3 a tick ages the tadpole" TO WS-CASE
     MOVE 101 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 100 TO WS-N1
     MOVE 1 TO WS-N2
     CALL "X2-TADPOLE-TICK" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§7 7.3 an age-locked tadpole does not age" TO WS-CASE
     MOVE 100 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 23999 TO WS-N1
     MOVE 0 TO WS-N2
     CALL "X2-TADPOLE-TICK" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§7 7.3 at 23999 the next tick grows it up" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 100 TO WS-N1
     MOVE 0 TO WS-N2
     CALL "X2-TADPOLE-TICK" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§7 7.3 before that it does not" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 END PROGRAM TEST-Q44-44-X2-7.

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
