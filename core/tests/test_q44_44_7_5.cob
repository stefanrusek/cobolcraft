*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-7-aquatic.md section 5 and its worked case 13.3, lane 002-lane-p49j-a): the elder guardian's
*> effect helper filter (survival or adventure, not allied, strictly closer than 50, no effect or lower amplifier or at most 1199 ticks left), the 1200-tick schedule
*> ((tickCount + id) mod 1200 = 0) and the Game Event value (0 silent, else 1). The core has no guardian mob yet: the rules are proven as functions.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-7-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(240).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-TICK                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-ALLIED              BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-CURAMP              BINARY-LONG.
 01 WS-CURDUR              BINARY-LONG.
 01 WS-NEWAMP              BINARY-LONG VALUE 2.
 01 WS-SILENT              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 1190 TO WS-TICK
     MOVE 10 TO WS-ID
     CALL "Q7-ELDER-DUE" USING WS-TICK WS-ID WS-OBS
     MOVE "acceptance US15 44-7§5 13.3 tick count 1190 with id 10 fires ((1190 + 10) mod 1200 = 0)" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 1191 TO WS-TICK
     CALL "Q7-ELDER-DUE" USING WS-TICK WS-ID WS-OBS
     MOVE "acceptance US15 44-7§5 the next tick does not fire" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 2390 TO WS-TICK
     CALL "Q7-ELDER-DUE" USING WS-TICK WS-ID WS-OBS
     MOVE "acceptance US15 44-7§5 and it fires again 1200 ticks later" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
*>   13.3: A survival 30 away without effect; B creative; C survival exactly 50; D MF III 5000 left; E MF III 800 left.
     MOVE 0 TO WS-MODE
     MOVE 0 TO WS-ALLIED
     MOVE 900 TO WS-D2
     MOVE 0 TO WS-HAS
     MOVE 0 TO WS-CURAMP
     MOVE 0 TO WS-CURDUR
     PERFORM FILTER
     MOVE "acceptance US15 44-7§5 13.3 player A (survival, 30 away, no effect) is affected" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 1 TO WS-MODE
     PERFORM FILTER
     MOVE "acceptance US15 44-7§5 13.3 player B (creative) is not" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 3 TO WS-MODE
     PERFORM FILTER
     MOVE "acceptance US15 44-7§5 a spectator is not" TO WS-NAME
     PERFORM EXPECT
     MOVE 2 TO WS-MODE
     PERFORM FILTER
     MOVE "acceptance US15 44-7§5 an adventure player is (GameType.isSurvival)" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 0 TO WS-MODE
     MOVE 2500 TO WS-D2
     PERFORM FILTER
     MOVE "acceptance US15 44-7§5 13.3 player C (exactly 50 away) is not (strict <)" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 2499 TO WS-D2
     PERFORM FILTER
     MOVE "acceptance US15 44-7§5 a player just inside 50 is" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 400 TO WS-D2
     MOVE 1 TO WS-ALLIED
     PERFORM FILTER
     MOVE "acceptance US15 44-7§5 a player allied to the elder (team) is not" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 0 TO WS-ALLIED
     MOVE 1 TO WS-HAS
     MOVE 2 TO WS-CURAMP
     MOVE 5000 TO WS-CURDUR
     PERFORM FILTER
     MOVE "acceptance US15 44-7§5 13.3 player D (Mining Fatigue III, 5000 left) is not" TO WS-NAME
     PERFORM EXPECT
     MOVE 800 TO WS-CURDUR
     PERFORM FILTER
     MOVE "acceptance US15 44-7§5 13.3 player E (Mining Fatigue III, 800 left) is refreshed" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 1199 TO WS-CURDUR
     PERFORM FILTER
     MOVE "acceptance US15 44-7§5 1199 ticks left qualifies" TO WS-NAME
     PERFORM EXPECT
     MOVE 1200 TO WS-CURDUR
     PERFORM FILTER
     MOVE "acceptance US15 44-7§5 1200 ticks left does not" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE -1 TO WS-CURDUR
     PERFORM FILTER
     MOVE "acceptance US15 44-7§5 an infinite duration never qualifies" TO WS-NAME
     PERFORM EXPECT
     MOVE 1 TO WS-CURAMP
     PERFORM FILTER
     MOVE "acceptance US15 44-7§5 a lower amplifier qualifies whatever the duration" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 3 TO WS-CURAMP
     MOVE 5000 TO WS-CURDUR
     PERFORM FILTER
     MOVE "acceptance US15 44-7§5 a higher amplifier with a long duration does not" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
*>   The Game Event value.
     MOVE 1 TO WS-SILENT
     CALL "Q7-ELDER-VALUE" USING WS-SILENT WS-OBS
     MOVE "acceptance US15 44-7§5 13.3 a silent elder sends value 0" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 0 TO WS-SILENT
     CALL "Q7-ELDER-VALUE" USING WS-SILENT WS-OBS
     MOVE "acceptance US15 44-7§5 13.3 an ordinary elder sends value 1" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     STOP RUN.
 FILTER.
     CALL "Q7-ELDER-FILTER" USING WS-MODE WS-ALLIED WS-D2 WS-HAS WS-CURAMP WS-CURDUR WS-NEWAMP WS-OBS.
 EXPECT.
     MOVE WS-NAME TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-7-5.
