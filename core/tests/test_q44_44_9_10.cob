*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-9-end-bosses-decorations.md section 10, lane 002-lane-p49j-a): the Wither boss bar rules: a setter that changes a value broadcasts the matching operation (2 progress, 3 name, 4 colour and overlay, 5 the three flags) only while visible; equal values broadcast nothing; makeInvulnerable (220 ticks, a third of max health). The bar packets and the fight are proven by acc_us16 (44-9 10 case).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-9-10.
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
     MOVE 1 TO WC
     CALL "Q9-BOSS-OP" USING WA WB WC WD
     MOVE "acceptance US15 44-9§10 10 a progress change on a visible bar broadcasts UPDATE_PROGRESS (2)" TO WS-NAME
     MOVE 2 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 2 TO WA
     CALL "Q9-BOSS-OP" USING WA WB WC WD
     MOVE "acceptance US15 44-9§10 10 a name change: UPDATE_NAME (3)" TO WS-NAME
     MOVE 3 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 3 TO WA
     CALL "Q9-BOSS-OP" USING WA WB WC WD
     MOVE "acceptance US15 44-9§10 10 a colour change: UPDATE_STYLE (4)" TO WS-NAME
     MOVE 4 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 4 TO WA
     CALL "Q9-BOSS-OP" USING WA WB WC WD
     MOVE "acceptance US15 44-9§10 10 an overlay change shares UPDATE_STYLE (4)" TO WS-NAME
     MOVE 4 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 5 TO WA
     CALL "Q9-BOSS-OP" USING WA WB WC WD
     MOVE "acceptance US15 44-9§10 10 darken screen: UPDATE_PROPERTIES (5)" TO WS-NAME
     MOVE 5 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 6 TO WA
     CALL "Q9-BOSS-OP" USING WA WB WC WD
     MOVE "acceptance US15 44-9§10 10 play boss music shares UPDATE_PROPERTIES (5)" TO WS-NAME
     MOVE 5 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 7 TO WA
     CALL "Q9-BOSS-OP" USING WA WB WC WD
     MOVE "acceptance US15 44-9§10 10 create world fog shares it too (5)" TO WS-NAME
     MOVE 5 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 1 TO WA
     MOVE 0 TO WB
     CALL "Q9-BOSS-OP" USING WA WB WC WD
     MOVE "acceptance US15 44-9§10 10 an equal value broadcasts nothing" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 1 TO WB
     MOVE 0 TO WC
     CALL "Q9-BOSS-OP" USING WA WB WC WD
     MOVE "acceptance US15 44-9§10 10 a hidden bar broadcasts nothing" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 300 TO WF1
     CALL "Q9-WITHER-INVULN" USING WF1 WF2 WA
     MOVE "acceptance US15 44-9§10 10 makeInvulnerable: health 300 / 3 = 100" TO WS-NAME
     MOVE 100 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF2
     PERFORM EXPECT
     MOVE "acceptance US15 44-9§10 10 and 220 invulnerable ticks" TO WS-NAME
     MOVE 220 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WA
     PERFORM EXPECT
     STOP RUN.
 EXPECT.
     MOVE WS-NAME TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-9-10.
