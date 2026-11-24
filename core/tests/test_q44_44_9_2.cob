*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-9-end-bosses-decorations.md section 2 and 2.1, lane 002-lane-p49j-a): the fire counter semantics of 2.1 for the thunderHit default (counter + 1, ignition only when it becomes 0 from -1, then 5.0 damage) and the baseTick burn rule; the per-class effects of the table (pig, villager, creeper, turtle, mushroom cow) are proven by acc_us16_lightning (44-9 2 cases).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-9-2.
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
     CALL "Q9-THUNDER-FIRE" USING WA WB
     MOVE "acceptance US15 44-9§2 and 2.1 2.1 a cow at counter 0 struck: counter 1, no ignition" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WA
     PERFORM EXPECT
     MOVE 0 TO WA
     CALL "Q9-THUNDER-FIRE" USING WA WB
     MOVE "acceptance US15 44-9§2 and 2.1 2.1 and no 8 second ignition" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WB
     PERFORM EXPECT
     MOVE -1 TO WA
     CALL "Q9-THUNDER-FIRE" USING WA WB
     MOVE "acceptance US15 44-9§2 and 2.1 2.1 an entity at counter -1 is ignited by the bolt (incremented value 0)" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WB
     PERFORM EXPECT
     MOVE -1 TO WA
     CALL "Q9-THUNDER-FIRE" USING WA WB
     MOVE "acceptance US15 44-9§2 and 2.1 2.1 and its counter becomes 160 ticks (igniteForSeconds(8.0))" TO WS-NAME
     MOVE 160 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WA
     PERFORM EXPECT
     MOVE -5 TO WA
     CALL "Q9-THUNDER-FIRE" USING WA WB
     MOVE "acceptance US15 44-9§2 and 2.1 2.1 an entity at counter -5 only rises to -4" TO WS-NAME
     MOVE -4 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WA
     PERFORM EXPECT
     MOVE 1 TO WA
     MOVE 0 TO WB
     CALL "Q9-FIRE-TICK" USING WA WB WC
     MOVE "acceptance US15 44-9§2 and 2.1 2.1 one burn tick later at counter 1: no fire damage (1 mod 20 not 0)" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WC
     PERFORM EXPECT
     MOVE 1 TO WA
     MOVE 0 TO WB
     CALL "Q9-FIRE-TICK" USING WA WB WC
     MOVE "acceptance US15 44-9§2 and 2.1 2.1 and the counter drops to 0" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WA
     PERFORM EXPECT
     MOVE 40 TO WA
     MOVE 0 TO WB
     CALL "Q9-FIRE-TICK" USING WA WB WC
     MOVE "acceptance US15 44-9§2 and 2.1 2.1 a burning entity at counter 40 takes fire damage (40 mod 20 = 0)" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WC
     PERFORM EXPECT
     MOVE 40 TO WA
     MOVE 1 TO WB
     CALL "Q9-FIRE-TICK" USING WA WB WC
     MOVE "acceptance US15 44-9§2 and 2.1 2.1 but not in lava (the lava damages it instead)" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WC
     PERFORM EXPECT
     MOVE -3 TO WA
     MOVE 0 TO WB
     CALL "Q9-FIRE-TICK" USING WA WB WC
     MOVE "acceptance US15 44-9§2 and 2.1 2.1 clearFire keeps a negative counter (-3 stays -3)" TO WS-NAME
     MOVE -3 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WA
     PERFORM EXPECT
     MOVE 0 TO WA
     MOVE 0 TO WB
     CALL "Q9-FIRE-TICK" USING WA WB WC
     MOVE "acceptance US15 44-9§2 and 2.1 2.1 a counter at 0 stays 0" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WA
     PERFORM EXPECT
     STOP RUN.
 EXPECT.
     MOVE WS-NAME TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-9-2.
