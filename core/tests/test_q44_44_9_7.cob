*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-9-end-bosses-decorations.md section 7, lane 002-lane-p49j-a): the interaction entity: the attack skip rule (a player attack is skipped only without a response; a non-player never) and the use result (client SUCCESS with a response else CONSUME; the server CONSUME). The core has no interaction or marker entity.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-9-7.
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
     MOVE 1 TO WA
     MOVE 0 TO WB
     CALL "Q9-INTERACT-ATTACK" USING WA WB WC
     MOVE "acceptance US15 44-9§7 7 a player attack on an unresponsive interaction is skipped" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WC
     PERFORM EXPECT
     MOVE 1 TO WA
     MOVE 1 TO WB
     CALL "Q9-INTERACT-ATTACK" USING WA WB WC
     MOVE "acceptance US15 44-9§7 7 with response true the attack proceeds (not skipped)" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WC
     PERFORM EXPECT
     MOVE 0 TO WA
     MOVE 0 TO WB
     CALL "Q9-INTERACT-ATTACK" USING WA WB WC
     MOVE "acceptance US15 44-9§7 7 a non-player attacker is never skipped" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WC
     PERFORM EXPECT
     MOVE 1 TO WA
     MOVE 1 TO WB
     CALL "Q9-INTERACT-USE" USING WA WB WC
     MOVE "acceptance US15 44-9§7 7 use on the client with response: SUCCESS (1)" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WC
     PERFORM EXPECT
     MOVE 1 TO WA
     MOVE 0 TO WB
     CALL "Q9-INTERACT-USE" USING WA WB WC
     MOVE "acceptance US15 44-9§7 7 use on the client without response: CONSUME (2)" TO WS-NAME
     MOVE 2 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WC
     PERFORM EXPECT
     MOVE 0 TO WA
     MOVE 1 TO WB
     CALL "Q9-INTERACT-USE" USING WA WB WC
     MOVE "acceptance US15 44-9§7 7 use on the server: CONSUME (2) whatever the response" TO WS-NAME
     MOVE 2 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WC
     PERFORM EXPECT
     STOP RUN.
 EXPECT.
     MOVE WS-NAME TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-9-7.
