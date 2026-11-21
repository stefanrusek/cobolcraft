*> Implementation test (002-lane-mobsfull-h2, T2214; docs/protocol/18 section 4.1 Goal selector): the goal selector of a mob,
*> table driven: cleanup, flag locks, replacement by strictly lower priority numbers, uninterruptable goals, disabled flags,
*> concurrent goals on disjoint flags, registration order tie-break, odd ticks, and the tick delay scaling.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-4-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY MOBGOALS.
 01 WS-IDX                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-PRIORITY            BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-EVERY               PIC 9.
 01 WS-RESULT              BINARY-LONG.
 01 WS-TEXT                PIC X(200).
 01 WS-POS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DIGITS              PIC 99.
 PROCEDURE DIVISION.

     *> Tick delay scaling: ceil(n / 2) unless the goal updates every tick.
     MOVE 5 TO WS-N
     MOVE 0 TO WS-EVERY
     CALL "ADJUSTED-TICK-DELAY" USING WS-N WS-EVERY WS-RESULT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 18§4.1 Goal selector adjustedTickDelay(5) = 3" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 40 TO WS-N
     CALL "ADJUSTED-TICK-DELAY" USING WS-N WS-EVERY WS-RESULT
     MOVE "acceptance US15 18§4.1 Goal selector adjustedTickDelay(40) = 20" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-EVERY
     CALL "ADJUSTED-TICK-DELAY" USING WS-N WS-EVERY WS-RESULT
     MOVE "acceptance US15 18§4.1 Goal selector adjustedTickDelay of an every-tick goal is n" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     MOVE WS-RESULT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> Goals A (prio 3, MOVE), B (prio 5, MOVE+LOOK), C (prio 8, LOOK), D (prio 2, JUMP, not interruptable).
     CALL "GOAL-SELECTOR-RESET" USING GS-STATE
     MOVE 3 TO WS-PRIORITY
     CALL "GOAL-ADD" USING GS-STATE WS-PRIORITY "100010" WS-A
     MOVE 5 TO WS-PRIORITY
     CALL "GOAL-ADD" USING GS-STATE WS-PRIORITY "110010" WS-B
     MOVE 8 TO WS-PRIORITY
     CALL "GOAL-ADD" USING GS-STATE WS-PRIORITY "010011" WS-C
     MOVE 2 TO WS-PRIORITY
     CALL "GOAL-ADD" USING GS-STATE WS-PRIORITY "001000" WS-D
     MOVE "acceptance US15 18§4.1 Goal selector registration returns indexes in order" TO TL-CASE
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N = 1234
     COMPUTE TL-OBSERVED-N = WS-A * 1000 + WS-B * 100 + WS-C * 10 + WS-D
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> B and C usable: B (MOVE, LOOK) starts first (registration order), C needs LOOK held by B at a lower priority number: no.
     MOVE 1 TO GS-CAN-USE(2)
     MOVE 1 TO GS-CAN-USE(3)
     MOVE 1 TO GS-CAN-CONTINUE(2)
     MOVE 1 TO GS-CAN-CONTINUE(3)
     MOVE 1 TO WS-MODE
     CALL "GOAL-SELECTOR-TICK" USING GS-STATE WS-MODE
     PERFORM BUILD-LOG
     MOVE "T" TO TL-MODE
     MOVE "acceptance US15 18§4.1 Goal selector the first goal in registration order wins the flags" TO TL-CASE
     MOVE "S2 T2" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> A (priority 3, MOVE) displaces B (priority 5, MOVE+LOOK): B stops, A starts; C (LOOK, prio 8) now can start.
     MOVE 1 TO GS-CAN-USE(1)
     MOVE 1 TO GS-CAN-CONTINUE(1)
     CALL "GOAL-SELECTOR-TICK" USING GS-STATE WS-MODE
     PERFORM BUILD-LOG
     MOVE "acceptance US15 18§4.1 Goal selector a strictly lower priority number interrupts a holder" TO TL-CASE
     MOVE "X2 S1 T1" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 18§4.1 Goal selector a stopped holder keeps its other lock until the next cleanup" TO TL-CASE
     MOVE 1200 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = GS-LOCK(1) * 1000 + GS-LOCK(2) * 100 + GS-LOCK(3) * 10 + GS-LOCK(4)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> Equal priority never interrupts: a second MOVE goal of priority 3 cannot displace A.
     MOVE 3 TO WS-PRIORITY
     CALL "GOAL-ADD" USING GS-STATE WS-PRIORITY "100010" WS-IDX
     MOVE 1 TO GS-CAN-USE(WS-IDX)
     MOVE 1 TO GS-CAN-CONTINUE(WS-IDX)
     CALL "GOAL-SELECTOR-TICK" USING GS-STATE WS-MODE
     PERFORM BUILD-LOG
     MOVE "T" TO TL-MODE
     MOVE "acceptance US15 18§4.1 Goal selector equal priority never interrupts (C starts instead)" TO TL-CASE
     MOVE "S3 T1 T3" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> Odd ticks tick only goals that update every tick (C does).
     MOVE 0 TO WS-MODE
     CALL "GOAL-SELECTOR-TICK" USING GS-STATE WS-MODE
     PERFORM BUILD-LOG
     MOVE "acceptance US15 18§4.1 Goal selector odd ticks run only every-tick goals" TO TL-CASE
     MOVE "T3" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> Goal D (prio 2, JUMP, not interruptable) starts; a JUMP goal of priority 1 cannot displace it.
     MOVE 1 TO WS-MODE
     MOVE 1 TO GS-CAN-USE(4)
     MOVE 1 TO GS-CAN-CONTINUE(4)
     MOVE 1 TO WS-PRIORITY
     CALL "GOAL-ADD" USING GS-STATE WS-PRIORITY "001010" WS-IDX
     MOVE 1 TO GS-CAN-USE(WS-IDX)
     MOVE 1 TO GS-CAN-CONTINUE(WS-IDX)
     CALL "GOAL-SELECTOR-TICK" USING GS-STATE WS-MODE
     PERFORM BUILD-LOG
     MOVE "acceptance US15 18§4.1 Goal selector a goal that is not interruptable is never displaced" TO TL-CASE
     MOVE "S4 T1 T3 T4" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     *> A disabled flag stops the goals holding it and keeps others from starting; the locks are released.
     MOVE 1 TO GS-DISABLED(1)
     CALL "GOAL-SELECTOR-TICK" USING GS-STATE WS-MODE
     PERFORM BUILD-LOG
     MOVE "acceptance US15 18§4.1 Goal selector a disabled flag stops its holder" TO TL-CASE
     MOVE "X1 T3 T4" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 18§4.1 Goal selector the lock of a stopped goal is removed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE GS-LOCK(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO GS-DISABLED(1)

     *> canContinueToUse false stops a goal.
     MOVE 0 TO GS-CAN-CONTINUE(4)
     MOVE 0 TO GS-CAN-USE(4)
     MOVE 0 TO GS-CAN-USE(1)
     MOVE 0 TO GS-CAN-USE(2)
     MOVE 0 TO GS-CAN-USE(5)
     MOVE 0 TO GS-CAN-USE(6)
     CALL "GOAL-SELECTOR-TICK" USING GS-STATE WS-MODE
     PERFORM BUILD-LOG
     MOVE "T" TO TL-MODE
     MOVE "acceptance US15 18§4.1 Goal selector canContinueToUse false stops the goal" TO TL-CASE
     MOVE "X4 T3" TO TL-EXPECTED
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
 END PROGRAM TEST-MOB-18-4-1.
