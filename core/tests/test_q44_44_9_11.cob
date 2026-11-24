*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-9-end-bosses-decorations.md section 11.2, lane 002-lane-p49j-a): the shulker rules: the split condition (open and teleported, p = (n - 1) / 5), the peek amount steps and physical peek, and the bullet constants (flight steps 10 to 50, target delta x 1.025 clamped, velocity a fifth of the way). End crystal item, End city and the rest of 11 are proven by acc_us16 (44-9 11.1 and 11.2 cases).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-9-11.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(240).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WA                     BINARY-LONG.
 01 WB                     BINARY-LONG.
 01 WC                     BINARY-LONG.
 01 WD                     BINARY-LONG.
 01 WE                     BINARY-LONG.
 01 WF1                    FLOAT-LONG.
 01 WF2                    FLOAT-LONG.
 01 WF3                    FLOAT-LONG.
 01 WF4                    FLOAT-LONG.
 01 WF5                    FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 1 TO WA
     MOVE 1 TO WB
     MOVE 6 TO WC
     MOVE 0 TO WF1
     CALL "Q9-SHULKER-SPLIT" USING WA WB WC WF1 WD
     MOVE "acceptance US15 44-9§11.2 11.2 a closed shulker never splits" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 0 TO WA
     MOVE 0 TO WB
     CALL "Q9-SHULKER-SPLIT" USING WA WB WC WF1 WD
     MOVE "acceptance US15 44-9§11.2 11.2 an open shulker that failed to teleport does not split" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 0 TO WA
     MOVE 1 TO WB
     MOVE 3 TO WC
     MOVE 0.39 TO WF1
     CALL "Q9-SHULKER-SPLIT" USING WA WB WC WF1 WD
     MOVE "acceptance US15 44-9§11.2 11.2 open, teleported, 3 shulkers near (p = 0.4), draw 0.39: split" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 0.41 TO WF1
     CALL "Q9-SHULKER-SPLIT" USING WA WB WC WF1 WD
     MOVE "acceptance US15 44-9§11.2 11.2 the same with draw 0.41: no split" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 1 TO WC
     MOVE 0 TO WF1
     CALL "Q9-SHULKER-SPLIT" USING WA WB WC WF1 WD
     MOVE "acceptance US15 44-9§11.2 11.2 alone (n = 1, p = 0) it never splits" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 0 TO WF1
     MOVE 100 TO WA
     CALL "Q9-SHULKER-PEEK" USING WF1 WA WB
     MOVE "acceptance US15 44-9§11.2 11.2 the peek rises 0.05 a tick toward raw 100 (target 1.0): 0 to 0.05 (x1000)" TO WS-NAME
     MOVE 50 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF1 * 1000
     PERFORM EXPECT
     MOVE "acceptance US15 44-9§11.2 11.2 and the change flag is set" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WB
     PERFORM EXPECT
     MOVE 0.02 TO WF1
     MOVE 3 TO WA
     CALL "Q9-SHULKER-PEEK" USING WF1 WA WB
     MOVE "acceptance US15 44-9§11.2 11.2 it stops at the target 0.03 (raw 3): from 0.02 to 0.03, not 0.07 (x1000)" TO WS-NAME
     MOVE 30 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF1 * 1000
     PERFORM EXPECT
     MOVE 0.5 TO WF1
     MOVE 0 TO WA
     CALL "Q9-SHULKER-PEEK" USING WF1 WA WB
     MOVE "acceptance US15 44-9§11.2 11.2 closing: from 0.5 toward 0 falls 0.05 to 0.45 (x1000)" TO WS-NAME
     MOVE 450 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF1 * 1000
     PERFORM EXPECT
     MOVE 0 TO WF1
     MOVE 0 TO WA
     CALL "Q9-SHULKER-PEEK" USING WF1 WA WB
     MOVE "acceptance US15 44-9§11.2 11.2 at the target nothing changes (flag 0)" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WB
     PERFORM EXPECT
     MOVE 0 TO WF1
     CALL "Q9-SHULKER-PHYS" USING WF1 WF2
     MOVE "acceptance US15 44-9§11.2 11.2 physicalPeek(0) = 0" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF2 * 1000
     PERFORM EXPECT
     MOVE 1 TO WF1
     CALL "Q9-SHULKER-PHYS" USING WF1 WF2
     MOVE "acceptance US15 44-9§11.2 11.2 physicalPeek(1) = 1 (x1000)" TO WS-NAME
     MOVE 1000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF2 * 1000
     PERFORM EXPECT
     MOVE 0.5 TO WF1
     CALL "Q9-SHULKER-PHYS" USING WF1 WF2
     MOVE "acceptance US15 44-9§11.2 11.2 physicalPeek(0.5) = 0.5 (x1000)" TO WS-NAME
     MOVE 500 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF2 * 1000
     PERFORM EXPECT
     MOVE 0 TO WA
     CALL "Q9-BULLET-STEPS" USING WA WB
     MOVE "acceptance US15 44-9§11.2 11.2 flight steps: draw 0 gives 10" TO WS-NAME
     MOVE 10 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WB
     PERFORM EXPECT
     MOVE 4 TO WA
     CALL "Q9-BULLET-STEPS" USING WA WB
     MOVE "acceptance US15 44-9§11.2 11.2 flight steps: draw 4 gives 50" TO WS-NAME
     MOVE 50 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WB
     PERFORM EXPECT
     MOVE 0.15 TO WF1
     MOVE 0 TO WF2
     CALL "Q9-BULLET-VEL" USING WF1 WF2
     MOVE "acceptance US15 44-9§11.2 11.2 bullet delta 0.15 grows to 0.15375 (x100000)" TO WS-NAME
     MOVE 15375 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF1 * 100000
     PERFORM EXPECT
     MOVE "acceptance US15 44-9§11.2 11.2 and the velocity moves a fifth of the way: 0.030750 (x100000 = 3075)" TO WS-NAME
     MOVE 3075 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF2 * 100000
     PERFORM EXPECT
     MOVE 0.99 TO WF1
     MOVE 0 TO WF2
     CALL "Q9-BULLET-VEL" USING WF1 WF2
     MOVE "acceptance US15 44-9§11.2 11.2 a delta of 0.99 is clamped to 1.0" TO WS-NAME
     MOVE 1000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF1 * 1000
     PERFORM EXPECT
     MOVE -0.99 TO WF1
     CALL "Q9-BULLET-VEL" USING WF1 WF2
     MOVE "acceptance US15 44-9§11.2 11.2 a delta of -0.99 is clamped to -1.0" TO WS-NAME
     MOVE -1000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF1 * 1000
     PERFORM EXPECT
     STOP RUN.
 EXPECT.
     MOVE WS-NAME TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-9-11.
