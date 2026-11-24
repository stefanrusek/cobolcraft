*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-9-end-bosses-decorations.md section 3, lane 002-lane-p49j-a): the instant effect arithmetic of a cloud (scale 0.5): harm 3 and 6, heal 2 and 4, inverted for undead; the loop itself (waiting, radius, victims, application tick) is proven by acc_us16_cloud (44-9 3 cases).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-9-3.
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
     MOVE 1 TO WB
     MOVE 0 TO WC
     MOVE 0.5 TO WF1
     CALL "Q9-INSTANT" USING WA WB WC WF1 WD WE
     MOVE "acceptance US15 44-9§3 3 amplifier 0 harm on a living mob: int(0.5 x 6 + 0.5) = 3" TO WS-NAME
     MOVE 3 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE "acceptance US15 44-9§3 3 the kind is damage (2)" TO WS-NAME
     MOVE 2 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WE
     PERFORM EXPECT
     MOVE 1 TO WA
     CALL "Q9-INSTANT" USING WA WB WC WF1 WD WE
     MOVE "acceptance US15 44-9§3 3 amplifier 1 harm: int(6.5) = 6" TO WS-NAME
     MOVE 6 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 0 TO WA
     MOVE 0 TO WB
     MOVE 0 TO WC
     CALL "Q9-INSTANT" USING WA WB WC WF1 WD WE
     MOVE "acceptance US15 44-9§3 3 amplifier 0 heal on a living mob: int(0.5 x 4 + 0.5) = 2" TO WS-NAME
     MOVE 2 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE "acceptance US15 44-9§3 3 the kind is heal (1)" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WE
     PERFORM EXPECT
     MOVE 1 TO WA
     CALL "Q9-INSTANT" USING WA WB WC WF1 WD WE
     MOVE "acceptance US15 44-9§3 3 amplifier 1 heal: int(4.5) = 4" TO WS-NAME
     MOVE 4 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 0 TO WA
     MOVE 1 TO WB
     MOVE 1 TO WC
     CALL "Q9-INSTANT" USING WA WB WC WF1 WD WE
     MOVE "acceptance US15 44-9§3 3 harm on an undead mob (inverted) heals instead: 3 becomes a heal of int(0.5 x 4 + 0.5) = 2" TO WS-NAME
     MOVE 2 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 0 TO WB
     MOVE 1 TO WC
     CALL "Q9-INSTANT" USING WA WB WC WF1 WD WE
     MOVE "acceptance US15 44-9§3 3 heal on an undead mob damages: 3 at amplifier 0" TO WS-NAME
     MOVE 3 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 1 TO WA
     MOVE 1 TO WB
     MOVE 0 TO WC
     MOVE 1.0 TO WF1
     CALL "Q9-INSTANT" USING WA WB WC WF1 WD WE
     MOVE "acceptance US15 44-9§3 3 the dragon fireball cloud effect amplifier 1 at scale 0.25 (the cloud scales the duration only): scale 1 would be int(1 x 12 + 0.5) = 12" TO WS-NAME
     MOVE 12 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     STOP RUN.
 EXPECT.
     MOVE WS-NAME TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-9-3.
