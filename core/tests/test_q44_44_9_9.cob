*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-9-end-bosses-decorations.md section 9.1 and 9.2, lane 002-lane-p49j-a): the dried ghast hydration schedule (a random tick schedules 5000 ticks when waterlogged or hydrated; each block tick steps the hydration; hatching at 3, so at least 20000 ticks) and the baby feeding growth (seconds = int(float(a / 20) x 0.1), ageUp with forced ages). No dried ghast block or happy ghast exists in the core.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-9-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(240).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WA                      BINARY-LONG.
 01 WB                      BINARY-LONG.
 01 WC                      BINARY-LONG.
 01 WD                      BINARY-LONG.
 01 WE                      BINARY-LONG.
 01 WF1                     FLOAT-LONG.
 01 WF2                     FLOAT-LONG.
 01 WF3                     FLOAT-LONG.
 01 WF4                     FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 0 TO WA
     MOVE 0 TO WB
     MOVE 0 TO WC
     CALL "Q9-DRIED-RANDOM" USING WA WB WC WD
     MOVE "acceptance US15 44-9§9.1 and 9.2 9.1 a dry, unhydrated block never schedules" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 1 TO WA
     CALL "Q9-DRIED-RANDOM" USING WA WB WC WD
     MOVE "acceptance US15 44-9§9.1 and 9.2 9.1 a waterlogged block schedules a tick in 5000" TO WS-NAME
     MOVE 5000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 0 TO WA
     MOVE 2 TO WB
     CALL "Q9-DRIED-RANDOM" USING WA WB WC WD
     MOVE "acceptance US15 44-9§9.1 and 9.2 9.1 a hydrated dry block (level 2) schedules too" TO WS-NAME
     MOVE 5000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 1 TO WC
     CALL "Q9-DRIED-RANDOM" USING WA WB WC WD
     MOVE "acceptance US15 44-9§9.1 and 9.2 9.1 not when a tick is already scheduled" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 0 TO WA
     MOVE 2 TO WB
     CALL "Q9-DRIED-TICK" USING WA WB WC
     MOVE "acceptance US15 44-9§9.1 and 9.2 9.1 a dry block loses one hydration level per block tick (2 to 1)" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WB
     PERFORM EXPECT
     MOVE 0 TO WB
     CALL "Q9-DRIED-TICK" USING WA WB WC
     MOVE "acceptance US15 44-9§9.1 and 9.2 9.1 and stays at 0" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WB
     PERFORM EXPECT
     MOVE 1 TO WA
     MOVE 0 TO WB
     CALL "Q9-DRIED-TICK" USING WA WB WC
     MOVE "acceptance US15 44-9§9.1 and 9.2 9.1 a waterlogged block gains one level (0 to 1)" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WB
     PERFORM EXPECT
     MOVE 1 TO WA
     MOVE 3 TO WB
     CALL "Q9-DRIED-TICK" USING WA WB WC
     MOVE "acceptance US15 44-9§9.1 and 9.2 9.1 at level 3 and waterlogged the block hatches" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WC
     PERFORM EXPECT
     MOVE "acceptance US15 44-9§9.1 and 9.2 9.1 hatching leaves the level at 3 (the block is removed)" TO WS-NAME
     MOVE 3 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WB
     PERFORM EXPECT
     MOVE 1 TO WA
     MOVE 0 TO WB
     MOVE 0 TO WD
     MOVE 0 TO WC
     PERFORM UNTIL WC = 1
         CALL "Q9-DRIED-TICK" USING WA WB WC
         ADD 1 TO WD
     END-PERFORM
     MOVE "acceptance US15 44-9§9.1 and 9.2 9.1 three increases then the hatch: four block ticks in all (20000 ticks at 5000 each)" TO WS-NAME
     MOVE 4 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 24000 TO WA
     CALL "Q9-FEED-SECONDS" USING WA WB
     MOVE "acceptance US15 44-9§9.1 and 9.2 9.2 a baby with age -24000: seconds = int(float(-(-24000) / 20 = 1200) x 0.1) = 120" TO WS-NAME
     MOVE 120 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WB
     PERFORM EXPECT
     MOVE 100 TO WA
     CALL "Q9-FEED-SECONDS" USING WA WB
     MOVE "acceptance US15 44-9§9.1 and 9.2 9.2 age -100: 100 / 20 = 5, x 0.1 = 0.5, seconds 0" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WB
     PERFORM EXPECT
     MOVE 400 TO WA
     CALL "Q9-FEED-SECONDS" USING WA WB
     MOVE "acceptance US15 44-9§9.1 and 9.2 9.2 age -400: 20 x 0.1 = 2 seconds" TO WS-NAME
     MOVE 2 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WB
     PERFORM EXPECT
     MOVE -24000 TO WA
     MOVE 120 TO WB
     MOVE 1 TO WC
     MOVE 0 TO WD
     MOVE 0 TO WE
     CALL "Q9-AGE-UP" USING WA WB WC WD WE
     MOVE "acceptance US15 44-9§9.1 and 9.2 9.2 ageUp 120 seconds from -24000: the age rises by 2400 to -21600" TO WS-NAME
     MOVE -21600 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WA
     PERFORM EXPECT
     MOVE "acceptance US15 44-9§9.1 and 9.2 9.2 forced: forcedAge gains 2400" TO WS-NAME
     MOVE 2400 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE "acceptance US15 44-9§9.1 and 9.2 9.2 and forcedAgeTimer becomes 40" TO WS-NAME
     MOVE 40 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WE
     PERFORM EXPECT
     MOVE -100 TO WA
     MOVE 10 TO WB
     MOVE 1 TO WC
     MOVE 0 TO WD
     MOVE 0 TO WE
     CALL "Q9-AGE-UP" USING WA WB WC WD WE
     MOVE "acceptance US15 44-9§9.1 and 9.2 9.2 the age is capped at 0 and then becomes the forced age: from -100 with 10 seconds: min(100, 0) = 0, then setAge(forcedAge 100)" TO WS-NAME
     MOVE 100 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WA
     PERFORM EXPECT
     MOVE -24000 TO WA
     MOVE 0 TO WC
     MOVE 0 TO WD
     MOVE 0 TO WE
     CALL "Q9-AGE-UP" USING WA WB WC WD WE
     MOVE "acceptance US15 44-9§9.1 and 9.2 9.2 not forced: no forced age and no timer" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WE
     PERFORM EXPECT
     STOP RUN.
 EXPECT.
     MOVE WS-NAME TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-9-9.
