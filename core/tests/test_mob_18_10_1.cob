*> Acceptance test (lane p49a, T14500; docs/protocol/18-mob-framework.md section 10.1 Goal arbitration): the worked example of the
*> goal selector, tick by tick, with the goal flags taken from the catalogue (GOAL-CATALOGUE) and the priorities of the example.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-10-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY MOBGOALS.
 01 WS-IDX                 BINARY-LONG.
 01 WS-G1                  BINARY-LONG.
 01 WS-G2                  BINARY-LONG.
 01 WS-G3                  BINARY-LONG.
 01 WS-G4                  BINARY-LONG.
 01 WS-G5                  BINARY-LONG.
 01 WS-PRIORITY            BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-SPEC                PIC X(6).
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(200).
 01 WS-POS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DIGITS              PIC 99.
 PROCEDURE DIVISION.
     CALL "GOAL-SELECTOR-RESET" USING GS-STATE
     MOVE "FloatGoal" TO WS-NAME
     CALL "GOAL-CATALOGUE" USING WS-NAME WS-SPEC WS-FOUND
     MOVE 0 TO WS-PRIORITY
     CALL "GOAL-ADD" USING GS-STATE WS-PRIORITY WS-SPEC WS-G1
     MOVE "MeleeAttackGoal" TO WS-NAME
     CALL "GOAL-CATALOGUE" USING WS-NAME WS-SPEC WS-FOUND
     MOVE 2 TO WS-PRIORITY
     CALL "GOAL-ADD" USING GS-STATE WS-PRIORITY WS-SPEC WS-G2
     MOVE "WaterAvoidingRandomStrollGoal" TO WS-NAME
     CALL "GOAL-CATALOGUE" USING WS-NAME WS-SPEC WS-FOUND
     MOVE 7 TO WS-PRIORITY
     CALL "GOAL-ADD" USING GS-STATE WS-PRIORITY WS-SPEC WS-G3
     MOVE "LookAtPlayerGoal" TO WS-NAME
     CALL "GOAL-CATALOGUE" USING WS-NAME WS-SPEC WS-FOUND
     MOVE 8 TO WS-PRIORITY
     CALL "GOAL-ADD" USING GS-STATE WS-PRIORITY WS-SPEC WS-G4
     MOVE "RandomLookAroundGoal" TO WS-NAME
     CALL "GOAL-CATALOGUE" USING WS-NAME WS-SPEC WS-FOUND
     MOVE 9 TO WS-PRIORITY
     CALL "GOAL-ADD" USING GS-STATE WS-PRIORITY WS-SPEC WS-G5

*>   Tick t: only the stroll (roll 0, a position exists) and the look-at-player goal can be used. G5 could be used too but its MOVE
*>   holder G3 (priority 7) is not replaceable by priority 9, which is checked before canUse.
     MOVE 1 TO GS-CAN-USE(WS-G3) GS-CAN-CONTINUE(WS-G3)
     MOVE 1 TO GS-CAN-USE(WS-G4) GS-CAN-CONTINUE(WS-G4)
     MOVE 1 TO GS-CAN-USE(WS-G5) GS-CAN-CONTINUE(WS-G5)
     MOVE 1 TO GS-CAN-CONTINUE(WS-G2)
     MOVE 1 TO WS-MODE
     CALL "GOAL-SELECTOR-TICK" USING GS-STATE WS-MODE
     PERFORM BUILD-LOG
     MOVE "T" TO TL-MODE
     MOVE "acceptance US15 18§10.1 Goal arbitration: tick t starts G3 and G4, G5 cannot replace G3" TO TL-CASE
     MOVE "S3 S4 T3 T4" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 18§10.1 Goal arbitration: G5 is not running" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE GS-RUNNING(WS-G5) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 18§10.1 Goal arbitration: G3 holds MOVE and G4 holds LOOK" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-G3 * 10 + WS-G4
     COMPUTE TL-OBSERVED-N = GS-LOCK(1) * 10 + GS-LOCK(2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Tick t+2: the mob has a target; G2 needs MOVE and LOOK and replaces both holders (2 < 7, 2 < 8): G3 and G4 stop, G2 starts.
     MOVE 1 TO GS-CAN-USE(WS-G2)
     CALL "GOAL-SELECTOR-TICK" USING GS-STATE WS-MODE
     PERFORM BUILD-LOG
     MOVE "T" TO TL-MODE
     MOVE "acceptance US15 18§10.1 Goal arbitration: tick t+2 G2 stops G3 and G4 and starts" TO TL-CASE
     MOVE "X3 X4 S2 T2" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 18§10.1 Goal arbitration: G2 locks MOVE and LOOK" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-G2 * 10 + WS-G2
     COMPUTE TL-OBSERVED-N = GS-LOCK(1) * 10 + GS-LOCK(2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   An odd tick: G2 requires an update every tick, so it is ticked alone.
     MOVE 0 TO WS-MODE
     CALL "GOAL-SELECTOR-TICK" USING GS-STATE WS-MODE
     PERFORM BUILD-LOG
     MOVE "T" TO TL-MODE
     MOVE "acceptance US15 18§10.1 Goal arbitration: an odd tick ticks G2 only" TO TL-CASE
     MOVE "T2" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The player is in water at the next evaluation: G1 owns JUMP, which nobody holds, so it starts alongside G2.
     MOVE 1 TO WS-MODE
     MOVE 0 TO GS-CAN-USE(WS-G3) GS-CAN-USE(WS-G4) GS-CAN-USE(WS-G5)
     MOVE 1 TO GS-CAN-USE(WS-G1)
     CALL "GOAL-SELECTOR-TICK" USING GS-STATE WS-MODE
     PERFORM BUILD-LOG
     MOVE "T" TO TL-MODE
     MOVE "acceptance US15 18§10.1 Goal arbitration: in water G1 starts alongside G2" TO TL-CASE
     MOVE "S1 T1 T2" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 BUILD-LOG.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-POS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GS-LOG-COUNT
         IF WS-POS > 1
             ADD 1 TO WS-POS
         END-IF
         EVALUATE GS-LOG-ACTION(WS-I)
             WHEN 1 MOVE "S" TO WS-TEXT(WS-POS:1)
             WHEN 2 MOVE "X" TO WS-TEXT(WS-POS:1)
             WHEN OTHER MOVE "T" TO WS-TEXT(WS-POS:1)
         END-EVALUATE
         ADD 1 TO WS-POS
         MOVE GS-LOG-GOAL(WS-I) TO WS-DIGITS
         MOVE WS-DIGITS(2:1) TO WS-TEXT(WS-POS:1)
         ADD 1 TO WS-POS
     END-PERFORM.
 END PROGRAM TEST-MOB-18-10-1.
