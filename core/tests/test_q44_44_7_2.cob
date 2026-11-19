*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-7-aquatic.md section 2, lane 002-lane-p49j-a, T24000 to T24099): the shared building blocks:
*> 2.1 the spawn group baby rule, 2.2 the golden dandelion age lock, 2.6 air supply defaults (the fish and squid cases of test_mob_21_4_1 and _5 prove the world side),
*> 2.7 the generic TargetingConditions order and 2.7's worked example. Sections 2.3 to 2.5 and 2.8 (nearest-visible sensors, tempting sensor, list order) need mob brains
*> that the core does not have for the aquatic mobs of part 7: gap.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-7-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(240).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-DRAW                FLOAT-LONG.
 01 WS-CHANCE              FLOAT-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-LOCKED              BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-TIMER               BINARY-LONG.
 01 WS-RANGE               FLOAT-LONG.
 01 WS-VIS                 FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-TT.
    05 WS-NULL             BINARY-LONG.
    05 WS-COMBAT           BINARY-LONG.
    05 WS-SAME             BINARY-LONG.
    05 WS-UNSEEN           BINARY-LONG.
    05 WS-SELFAIL          BINARY-LONG.
    05 WS-NOATTACK         BINARY-LONG.
    05 WS-ALLIED           BINARY-LONG.
    05 WS-LOS              BINARY-LONG.
    05 WS-MOB              BINARY-LONG.
    05 WS-HASLOS           BINARY-LONG.
    05 WS-ENEMY            BINARY-LONG.
    05 WS-PEACE            BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   2.1: the first member of a group is never a baby, later members with draw <= chance.
     MOVE 0.05 TO WS-CHANCE
     MOVE 0 TO WS-SIZE
     MOVE 0.0 TO WS-DRAW
     CALL "Q7-GROUP-BABY" USING WS-SIZE WS-DRAW WS-CHANCE WS-OBS
     MOVE "acceptance US15 44-7§2.1 the first mob of a group (size 0) is never a baby" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 1 TO WS-SIZE
     CALL "Q7-GROUP-BABY" USING WS-SIZE WS-DRAW WS-CHANCE WS-OBS
     MOVE "acceptance US15 44-7§2.1 the second member with draw 0 is a baby" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 0.05 TO WS-DRAW
     CALL "Q7-GROUP-BABY" USING WS-SIZE WS-DRAW WS-CHANCE WS-OBS
     MOVE "acceptance US15 44-7§2.1 a draw equal to the chance counts (nextFloat <= chance)" TO WS-NAME
     PERFORM EXPECT
     MOVE 0.06 TO WS-DRAW
     CALL "Q7-GROUP-BABY" USING WS-SIZE WS-DRAW WS-CHANCE WS-OBS
     MOVE "acceptance US15 44-7§2.1 a draw above the chance is an adult" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
*>   2.1 and 6.3: the default group chance by species (squid 0.05, glow squid 0.05, dolphin 0.1; axolotl groups never use it).
     MOVE "dolphin" TO WS-KEY
     CALL "Q7-GROUP-CHANCE" USING WS-KEY WS-CHANCE
     MOVE "acceptance US15 44-7§6.3 dolphin group chance 0.1 (x1000)" TO WS-NAME
     MOVE 100 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-CHANCE * 1000
     PERFORM EXPECT
     MOVE "glow_squid" TO WS-KEY
     CALL "Q7-GROUP-CHANCE" USING WS-KEY WS-CHANCE
     MOVE "acceptance US15 44-7§6.3 glow squid group chance 0.05 (x1000)" TO WS-NAME
     MOVE 50 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-CHANCE * 1000
     PERFORM EXPECT
     MOVE "squid" TO WS-KEY
     CALL "Q7-GROUP-CHANCE" USING WS-KEY WS-CHANCE
     MOVE "acceptance US15 44-7§6.3 squid group chance 0.05 (x1000)" TO WS-NAME
     PERFORM EXPECT
     MOVE "axolotl" TO WS-KEY
     CALL "Q7-GROUP-CHANCE" USING WS-KEY WS-CHANCE
     MOVE "acceptance US15 44-7§8.1 an axolotl group never uses the generic baby chance (AgeableMobGroupData(false)): 0" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-CHANCE * 1000
     PERFORM EXPECT
*>   2.2: the toggle flips the flag, sets age -24000 and the particle timer 40 (both ways).
     MOVE 0 TO WS-LOCKED
     MOVE 0 TO WS-AGE
     MOVE 0 TO WS-TIMER
     CALL "Q7-AGE-LOCK" USING WS-LOCKED WS-AGE WS-TIMER
     MOVE "acceptance US15 44-7§2.2 a golden dandelion locks the age" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE WS-LOCKED TO WS-OBS
     PERFORM EXPECT
     MOVE "acceptance US15 44-7§2.2 the age is set to -24000" TO WS-NAME
     MOVE -24000 TO WS-EXP
     MOVE WS-AGE TO WS-OBS
     PERFORM EXPECT
     MOVE "acceptance US15 44-7§2.2 the particle timer is 40" TO WS-NAME
     MOVE 40 TO WS-EXP
     MOVE WS-TIMER TO WS-OBS
     PERFORM EXPECT
     MOVE -100 TO WS-AGE
     CALL "Q7-AGE-LOCK" USING WS-LOCKED WS-AGE WS-TIMER
     MOVE "acceptance US15 44-7§2.2 a second use unlocks and still resets the age" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE WS-LOCKED TO WS-OBS
     PERFORM EXPECT
     MOVE -24000 TO WS-EXP
     MOVE WS-AGE TO WS-OBS
     PERFORM EXPECT
*>   2.7 worked example: combat range 16, visibility 0.5 gives 8: 9 blocks fails, 8 passes; visibility 0.05 gives the floor 2.
     MOVE 16 TO WS-RANGE
     MOVE 0.5 TO WS-VIS
     MOVE 81 TO WS-D2
     CALL "Q7-RANGE-PASS" USING WS-RANGE WS-VIS WS-D2 WS-OBS
     MOVE "acceptance US15 44-7§2.7 visibility 0.5: a target 9 away fails the range step" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 64 TO WS-D2
     CALL "Q7-RANGE-PASS" USING WS-RANGE WS-VIS WS-D2 WS-OBS
     MOVE "acceptance US15 44-7§2.7 a target exactly 8 away passes (equality passes)" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 0.05 TO WS-VIS
     MOVE 5 TO WS-D2
     CALL "Q7-RANGE-PASS" USING WS-RANGE WS-VIS WS-D2 WS-OBS
     MOVE "acceptance US15 44-7§2.7 visibility 0.05: the floor 2.0 makes r 2, so squared distance 5 fails" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 4 TO WS-D2
     CALL "Q7-RANGE-PASS" USING WS-RANGE WS-VIS WS-D2 WS-OBS
     MOVE "acceptance US15 44-7§2.7 and squared distance 4 (r = 2) passes" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 0 TO WS-RANGE
     MOVE 1000000 TO WS-D2
     CALL "Q7-RANGE-PASS" USING WS-RANGE WS-VIS WS-D2 WS-OBS
     MOVE "acceptance US15 44-7§2.7 a range of 0 means no limit" TO WS-NAME
     PERFORM EXPECT
*>   2.7 order: every flag alone.
     MOVE 16 TO WS-RANGE
     MOVE 1 TO WS-VIS
     MOVE 1 TO WS-D2
     PERFORM TT-CLEAR
     MOVE 1 TO WS-COMBAT
     PERFORM TT-RUN
     MOVE "acceptance US15 44-7§2.7 a plain visible combat target passes" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     PERFORM TT-CLEAR
     MOVE 1 TO WS-SAME
     PERFORM TT-RUN
     MOVE "acceptance US15 44-7§2.7 step 1: the attacker itself fails" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     PERFORM TT-CLEAR
     MOVE 1 TO WS-UNSEEN
     PERFORM TT-RUN
     MOVE "acceptance US15 44-7§2.7 step 2: a target nobody can see fails" TO WS-NAME
     PERFORM EXPECT
     PERFORM TT-CLEAR
     MOVE 1 TO WS-SELFAIL
     PERFORM TT-RUN
     MOVE "acceptance US15 44-7§2.7 step 3: a failing selector fails" TO WS-NAME
     PERFORM EXPECT
     PERFORM TT-CLEAR
     MOVE 1 TO WS-NULL
     MOVE 1000000 TO WS-D2
     PERFORM TT-RUN
     MOVE "acceptance US15 44-7§2.7 step 4: no attacker, non-combat: true at once (range not tested)" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 1 TO WS-COMBAT
     PERFORM TT-RUN
     MOVE "acceptance US15 44-7§2.7 step 4: no attacker, combat, not seen as enemy: false" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 1 TO WS-ENEMY
     PERFORM TT-RUN
     MOVE "acceptance US15 44-7§2.7 step 4: no attacker, combat, seen as enemy, not peaceful: true" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 1 TO WS-PEACE
     PERFORM TT-RUN
     MOVE "acceptance US15 44-7§2.7 step 4: the same on Peaceful: false" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     PERFORM TT-CLEAR
     MOVE 1 TO WS-COMBAT
     MOVE 1 TO WS-NOATTACK
     PERFORM TT-RUN
     MOVE "acceptance US15 44-7§2.7 step 5: combat and the attacker cannot attack it: false" TO WS-NAME
     PERFORM EXPECT
     MOVE 0 TO WS-NOATTACK
     MOVE 1 TO WS-ALLIED
     PERFORM TT-RUN
     MOVE "acceptance US15 44-7§2.7 step 5: combat and allied: false" TO WS-NAME
     PERFORM EXPECT
     MOVE 0 TO WS-COMBAT
     PERFORM TT-RUN
     MOVE "acceptance US15 44-7§2.7 step 5 is combat only: non-combat allied passes" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     PERFORM TT-CLEAR
     MOVE 0.5 TO WS-VIS
     MOVE 81 TO WS-D2
     PERFORM TT-RUN
     MOVE "acceptance US15 44-7§2.7 step 6 inside the full test: range 16, visibility 0.5, a target 9 away fails" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 1 TO WS-VIS
     PERFORM TT-CLEAR
     MOVE 1 TO WS-LOS
     MOVE 1 TO WS-MOB
     MOVE 0 TO WS-HASLOS
     PERFORM TT-RUN
     MOVE "acceptance US15 44-7§2.7 step 7: a mob attacker without line of sight fails" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 0 TO WS-MOB
     PERFORM TT-RUN
     MOVE "acceptance US15 44-7§2.7 step 7: a non-mob attacker never fails the line of sight" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 1 TO WS-MOB
     MOVE 1 TO WS-HASLOS
     PERFORM TT-RUN
     MOVE "acceptance US15 44-7§2.7 step 7: with line of sight it passes" TO WS-NAME
     PERFORM EXPECT
     STOP RUN.
 EXPECT.
     MOVE WS-NAME TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 TT-CLEAR.
     INITIALIZE WS-TT
     MOVE 1 TO WS-D2.
 TT-RUN.
     CALL "Q7-TARGET-TEST" USING WS-NULL WS-COMBAT WS-SAME WS-UNSEEN WS-SELFAIL WS-NOATTACK WS-ALLIED WS-RANGE WS-VIS WS-D2 WS-LOS WS-MOB WS-HASLOS
         WS-ENEMY WS-PEACE WS-OBS.
 END PROGRAM TEST-Q44-44-7-2.
