*> Acceptance test of docs/protocol/44-residual-mob-questions-x2-continuation.md section 2 as rule functions (lane 002-lane-p49j-b, T24400 range): the warden spawn tracker (tick, decay in 12001 ticks, increase with cooldown, clamp), tryWarn candidate selection (worked example 3), the shrieker rules (canRespond, tryShriek, tryRespond reply sounds, tryGetPlayer order) and the SpawnUtil strategy and floor search.

*> The functions of core/src/q44-44-x2.cob are not called by a tick (no engine for them yet, see the lane task list).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-X2-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASE                PIC X(160).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                  FLOAT-LONG.
 01 WS-B                  FLOAT-LONG.
 01 WS-C                  FLOAT-LONG.
 01 WS-D                  FLOAT-LONG.
 01 WS-E                  FLOAT-LONG.
 01 WS-F                  FLOAT-LONG.
 01 WS-G                  FLOAT-LONG.
 01 WS-H                  FLOAT-LONG.
 01 WS-J                  FLOAT-LONG.
 01 WS-K                  FLOAT-LONG.
 01 WS-N1                 BINARY-LONG.
 01 WS-N2                 BINARY-LONG.
 01 WS-N3                 BINARY-LONG.
 01 WS-N4                 BINARY-LONG.
 01 WS-N5                 BINARY-LONG.
 01 WS-N6                 BINARY-LONG.
 01 WS-N7                 BINARY-LONG.
 01 WS-N8                 BINARY-LONG.
 01 WS-N9                 BINARY-LONG.
 01 WS-N10                 BINARY-LONG.
 01 WS-N11                 BINARY-LONG.
 01 WS-N12                 BINARY-LONG.
 01 WS-CHAIN.
    05 WS-LEVEL OCCURS 5 TIMES.
       10 WS-AMP            BINARY-LONG.
       10 WS-DUR            BINARY-LONG.
       10 WS-ACTIVE         BINARY-LONG.
 01 WS-TAB.
    05 WS-TN                BINARY-LONG.
    05 WS-TC OCCURS 6 TIMES.
       10 WS-TA             BINARY-LONG.
       10 WS-TB             BINARY-LONG.
       10 WS-TD             BINARY-LONG.
 01 WS-COL.
    05 WS-CELL OCCURS 14 TIMES.
       10 WS-CE             BINARY-LONG.
       10 WS-CF             BINARY-LONG.
 01 WS-S1                  PIC X(32).
 01 WS-S2                  PIC X(32).
 01 WS-S3                  PIC X(32).
 01 WS-S4                  PIC X(32).
 01 WS-S5                  PIC X(32).
 01 WS-S6                  PIC X(32).
 PROCEDURE DIVISION.
     MOVE 5 TO WS-N1
     MOVE 2 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-WT-TICK" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§2 2.1 a tick counts up: 5 becomes 6" TO WS-CASE
     MOVE 6 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 11999 TO WS-N1
     MOVE 2 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-WT-TICK" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§2 2.1 a tick at 11999 reaches 12000 without decay" TO WS-CASE
     MOVE 2 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 12000 TO WS-N1
     MOVE 2 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-WT-TICK" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§2 2.1 the tick at 12000 decays the level 2 to 1" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§2 2.1 and restarts the counter at 0 (that tick does not increment)" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 12000 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-WT-TICK" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§2 2.1 decay stops at level 0" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 5 TO WS-N3
     CALL "X2-WT-TICK" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§2 2.1 a positive cooldown counts down: 5 to 4" TO WS-CASE
     MOVE 4 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-WT-TICK" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§2 2.1 a cooldown of 0 stays 0" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1 WS-N4
     MOVE 3 TO WS-N2
     MOVE 0 TO WS-N3
     PERFORM UNTIL WS-N2 < 3
         CALL "X2-WT-TICK" USING WS-N1 WS-N2 WS-N3
         ADD 1 TO WS-N4
     END-PERFORM
     MOVE "acceptance US15 44-x2§2 2.5 example 2: a decay step takes 12001 ticks (the level drops on tick 12001)" TO WS-CASE
     MOVE 12001 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1 WS-N4
     MOVE 4 TO WS-N2
     MOVE 0 TO WS-N3
     PERFORM UNTIL WS-N2 < 1
         CALL "X2-WT-TICK" USING WS-N1 WS-N2 WS-N3
         ADD 1 TO WS-N4
     END-PERFORM
     MOVE "acceptance US15 44-x2§2 2.5 example 2: a full decay from 4 to 0 takes 48004 ticks" TO WS-CASE
     MOVE 48004 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 500 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-WT-INCREASE" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§2 2.1 increase: level 0 becomes 1" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§2 2.1 increase: cooldown 200" TO WS-CASE
     MOVE 200 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§2 2.1 increase: the counter restarts at 0" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 500 TO WS-N1
     MOVE 2 TO WS-N2
     MOVE 5 TO WS-N3
     CALL "X2-WT-INCREASE" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§2 2.1 increase on cooldown does nothing (level stays)" TO WS-CASE
     MOVE 2 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§2 2.1 increase on cooldown keeps the counter" TO WS-CASE
     MOVE 500 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 4 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-WT-INCREASE" USING WS-N1 WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§2 2.1 increase clamps at 4" TO WS-CASE
     MOVE 4 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE -3 TO WS-N1
     CALL "X2-WT-CLAMP" USING WS-N1
     MOVE "acceptance US15 44-x2§2 2.1 setWarningLevel(-3) clamps to 0" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 2 TO WS-N1
     CALL "X2-WT-CLAMP" USING WS-N1
     MOVE "acceptance US15 44-x2§2 2.1 setWarningLevel(2) clamps to 2" TO WS-CASE
     MOVE 2 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 9 TO WS-N1
     CALL "X2-WT-CLAMP" USING WS-N1
     MOVE "acceptance US15 44-x2§2 2.1 setWarningLevel(9) clamps to 4" TO WS-CASE
     MOVE 4 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     INITIALIZE WS-TAB
     MOVE 2 TO WS-TN
     MOVE 2 TO WS-TA(1)
     MOVE 0 TO WS-TB(1)
     MOVE 50 TO WS-TD(1)
     MOVE 0 TO WS-TA(2)
     MOVE 0 TO WS-TB(2)
     MOVE 10 TO WS-TD(2)
     MOVE 0 TO WS-N1
     CALL "X2-WARN" USING WS-N1 WS-TAB WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§2 2.5 example 3: A (level 2) and B (0): tryWarn returns 3" TO WS-CASE
     MOVE 3 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§2 2.5 example 3: a level was produced" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§2 2.5 example 3: A's tracker is (3, 200, 0)" TO WS-CASE
     MOVE 30200 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-TA(1) * 10000 + WS-TB(1)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§2 2.5 example 3: A's counter is 0" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-TD(1)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§2 2.5 example 3: B shares the winner's level" TO WS-CASE
     MOVE 3 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-TA(2)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§2 2.5 example 3: B shares the cooldown" TO WS-CASE
     MOVE 200 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-TB(2)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§2 2.5 example 3: B shares the counter" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-TD(2)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     INITIALIZE WS-TAB
     MOVE 2 TO WS-TN
     MOVE 1 TO WS-TA(1)
     MOVE 0 TO WS-TB(1)
     MOVE 7 TO WS-TD(1)
     MOVE 1 TO WS-TA(2)
     MOVE 0 TO WS-TB(2)
     MOVE 9 TO WS-TD(2)
     MOVE 0 TO WS-N1
     CALL "X2-WARN" USING WS-N1 WS-TAB WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§2 2.2 a tie goes to the first candidate (levels 1 and 1, list order)" TO WS-CASE
     MOVE 2 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     INITIALIZE WS-TAB
     MOVE 2 TO WS-TN
     MOVE 1 TO WS-TA(1)
     MOVE 0 TO WS-TB(1)
     MOVE 0 TO WS-TD(1)
     MOVE 3 TO WS-TA(2)
     MOVE 0 TO WS-TB(2)
     MOVE 0 TO WS-TD(2)
     MOVE 0 TO WS-N1
     CALL "X2-WARN" USING WS-N1 WS-TAB WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§2 2.2 the highest level wins even later in the list (1 and 3 give 4)" TO WS-CASE
     MOVE 4 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§2 2.2 and the first candidate shares it" TO WS-CASE
     MOVE 4 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-TA(1)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     INITIALIZE WS-TAB
     MOVE 1 TO WS-TN
     MOVE 1 TO WS-TA(1)
     MOVE 0 TO WS-TB(1)
     MOVE 0 TO WS-TD(1)
     MOVE 1 TO WS-N1
     CALL "X2-WARN" USING WS-N1 WS-TAB WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§2 2.2 a warden in the 48 box gives no result" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§2 2.2 and leaves the trackers alone" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-TA(1)
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     INITIALIZE WS-TAB
     MOVE 2 TO WS-TN
     MOVE 2 TO WS-TA(1)
     MOVE 0 TO WS-TB(1)
     MOVE 0 TO WS-TD(1)
     MOVE 0 TO WS-TA(2)
     MOVE 3 TO WS-TB(2)
     MOVE 0 TO WS-TD(2)
     MOVE 0 TO WS-N1
     CALL "X2-WARN" USING WS-N1 WS-TAB WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§2 2.2 a candidate on cooldown gives no result" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     INITIALIZE WS-TAB
     MOVE 0 TO WS-TN
     MOVE 0 TO WS-N1
     CALL "X2-WARN" USING WS-N1 WS-TAB WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§2 2.2 no candidate gives no result" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     INITIALIZE WS-TAB
     MOVE 1 TO WS-TN
     MOVE 4 TO WS-TA(1)
     MOVE 0 TO WS-TB(1)
     MOVE 0 TO WS-TD(1)
     MOVE 0 TO WS-N1
     CALL "X2-WARN" USING WS-N1 WS-TAB WS-N2 WS-N3
     MOVE "acceptance US15 44-x2§2 2.2 a candidate at level 4 stays 4" TO WS-CASE
     MOVE 4 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N3
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 2 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "X2-SHRIEK-CAN-RESPOND" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§2 2.3 canRespond: can_summon, Normal difficulty, spawn_wardens" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 2 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "X2-SHRIEK-CAN-RESPOND" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§2 2.3 canRespond is false without can_summon" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "X2-SHRIEK-CAN-RESPOND" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§2 2.3 canRespond is false on Peaceful" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 2 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-SHRIEK-CAN-RESPOND" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-x2§2 2.3 canRespond is false with spawn_wardens off" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     CALL "X2-SHRIEK-TRY" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§2 2.3 tryShriek: a player, not shrieking, can respond and the warning produced: shriek" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     CALL "X2-SHRIEK-TRY" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§2 2.3 tryShriek: no player: nothing" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     CALL "X2-SHRIEK-TRY" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§2 2.3 tryShriek: already shrieking: nothing" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "X2-SHRIEK-TRY" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§2 2.3 tryShriek: a failed warning returns without shrieking" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "X2-SHRIEK-TRY" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§2 2.3 tryShriek: without canRespond the warning is skipped and the shriek goes ahead" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-SHRIEK-RESPOND" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§2 2.3 tryRespond level 1 plays reply sound 1" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 2 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-SHRIEK-RESPOND" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§2 2.3 tryRespond level 2 plays reply sound 2" TO WS-CASE
     MOVE 2 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 3 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-SHRIEK-RESPOND" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§2 2.3 tryRespond level 3 plays reply sound 3" TO WS-CASE
     MOVE 3 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 4 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-SHRIEK-RESPOND" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§2 2.3 level 4 with a failed warden spawn plays listening_angry (4)" TO WS-CASE
     MOVE 4 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 4 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "X2-SHRIEK-RESPOND" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§2 2.3 level 4 with a warden spawned plays no reply sound" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§2 2.3 Darkness applies even when the warden spawned" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-SHRIEK-RESPOND" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§2 2.3 level 0 does nothing (no sound)" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§2 2.3 level 0 applies no Darkness" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 3 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-SHRIEK-RESPOND" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§2 2.3 without canRespond nothing happens" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 5 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "X2-SHRIEK-RESPOND" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§2 2.3 a level above 4 plays nothing but still darkens" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 * 10 + WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     CALL "X2-TRY-PLAYER" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§2 2.3 tryGetPlayer: the player himself" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     CALL "X2-TRY-PLAYER" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§2 2.3 tryGetPlayer: a controlling passenger" TO WS-CASE
     MOVE 2 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     CALL "X2-TRY-PLAYER" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§2 2.3 tryGetPlayer: a projectile's owner" TO WS-CASE
     MOVE 3 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-N4
     CALL "X2-TRY-PLAYER" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§2 2.3 tryGetPlayer: an item entity's owner" TO WS-CASE
     MOVE 4 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "X2-TRY-PLAYER" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§2 2.3 tryGetPlayer: none" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "X2-SPAWN-STRATEGY" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§2 2.4 ON_TOP_OF_COLLIDER accepts an empty above and a full floor" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "X2-SPAWN-STRATEGY" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§2 2.4 refuses a non-empty above" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "X2-SPAWN-STRATEGY" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§2 2.4 refuses a floor without a full top face" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "X2-SPAWN-STRATEGY" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§2 2.4 the plain strategy accepts a leaves floor" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     CALL "X2-SPAWN-STRATEGY" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-x2§2 2.4 NO_LEAVES refuses a leaves floor" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     INITIALIZE WS-COL
     MOVE 1 TO WS-CE(1)
     MOVE 0 TO WS-CF(1)
     MOVE 1 TO WS-CE(2)
     MOVE 0 TO WS-CF(2)
     MOVE 1 TO WS-CE(3)
     MOVE 0 TO WS-CF(3)
     MOVE 0 TO WS-CE(4)
     MOVE 1 TO WS-CF(4)
     MOVE 0 TO WS-CE(5)
     MOVE 1 TO WS-CF(5)
     MOVE 0 TO WS-CE(6)
     MOVE 1 TO WS-CF(6)
     MOVE 0 TO WS-CE(7)
     MOVE 1 TO WS-CF(7)
     MOVE 0 TO WS-CE(8)
     MOVE 1 TO WS-CF(8)
     MOVE 0 TO WS-CE(9)
     MOVE 1 TO WS-CF(9)
     MOVE 0 TO WS-CE(10)
     MOVE 1 TO WS-CF(10)
     MOVE 0 TO WS-CE(11)
     MOVE 1 TO WS-CF(11)
     MOVE 0 TO WS-CE(12)
     MOVE 1 TO WS-CF(12)
     MOVE 0 TO WS-CE(13)
     MOVE 1 TO WS-CF(13)
     MOVE 0 TO WS-CE(14)
     MOVE 1 TO WS-CF(14)
     MOVE 6 TO WS-N1
     CALL "X2-SPAWN-FIND" USING WS-N1 WS-COL WS-N2
     MOVE "acceptance US15 44-x2§2 2.4 floor search: air down to a solid block 3 below the start: offset 2 (the candidate is the air above the floor)" TO WS-CASE
     MOVE 2 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     INITIALIZE WS-COL
     MOVE 1 TO WS-CE(1)
     MOVE 0 TO WS-CF(1)
     MOVE 0 TO WS-CE(2)
     MOVE 1 TO WS-CF(2)
     MOVE 0 TO WS-CE(3)
     MOVE 1 TO WS-CF(3)
     MOVE 0 TO WS-CE(4)
     MOVE 1 TO WS-CF(4)
     MOVE 0 TO WS-CE(5)
     MOVE 1 TO WS-CF(5)
     MOVE 0 TO WS-CE(6)
     MOVE 1 TO WS-CF(6)
     MOVE 0 TO WS-CE(7)
     MOVE 1 TO WS-CF(7)
     MOVE 0 TO WS-CE(8)
     MOVE 1 TO WS-CF(8)
     MOVE 0 TO WS-CE(9)
     MOVE 1 TO WS-CF(9)
     MOVE 0 TO WS-CE(10)
     MOVE 1 TO WS-CF(10)
     MOVE 0 TO WS-CE(11)
     MOVE 1 TO WS-CF(11)
     MOVE 0 TO WS-CE(12)
     MOVE 1 TO WS-CF(12)
     MOVE 0 TO WS-CE(13)
     MOVE 1 TO WS-CF(13)
     MOVE 0 TO WS-CE(14)
     MOVE 1 TO WS-CF(14)
     MOVE 6 TO WS-N1
     CALL "X2-SPAWN-FIND" USING WS-N1 WS-COL WS-N2
     MOVE "acceptance US15 44-x2§2 2.4 floor search: a solid floor right below the start: offset 0" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     INITIALIZE WS-COL
     MOVE 1 TO WS-CE(1)
     MOVE 0 TO WS-CF(1)
     MOVE 1 TO WS-CE(2)
     MOVE 0 TO WS-CF(2)
     MOVE 1 TO WS-CE(3)
     MOVE 0 TO WS-CF(3)
     MOVE 1 TO WS-CE(4)
     MOVE 0 TO WS-CF(4)
     MOVE 1 TO WS-CE(5)
     MOVE 0 TO WS-CF(5)
     MOVE 1 TO WS-CE(6)
     MOVE 0 TO WS-CF(6)
     MOVE 1 TO WS-CE(7)
     MOVE 0 TO WS-CF(7)
     MOVE 1 TO WS-CE(8)
     MOVE 0 TO WS-CF(8)
     MOVE 1 TO WS-CE(9)
     MOVE 0 TO WS-CF(9)
     MOVE 1 TO WS-CE(10)
     MOVE 0 TO WS-CF(10)
     MOVE 1 TO WS-CE(11)
     MOVE 0 TO WS-CF(11)
     MOVE 1 TO WS-CE(12)
     MOVE 0 TO WS-CF(12)
     MOVE 1 TO WS-CE(13)
     MOVE 0 TO WS-CF(13)
     MOVE 1 TO WS-CE(14)
     MOVE 0 TO WS-CF(14)
     MOVE 6 TO WS-N1
     CALL "X2-SPAWN-FIND" USING WS-N1 WS-COL WS-N2
     MOVE "acceptance US15 44-x2§2 2.4 floor search: nothing solid in 13 steps: none" TO WS-CASE
     MOVE -1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     INITIALIZE WS-COL
     MOVE 1 TO WS-CE(1)
     MOVE 0 TO WS-CF(1)
     MOVE 1 TO WS-CE(2)
     MOVE 0 TO WS-CF(2)
     MOVE 1 TO WS-CE(3)
     MOVE 0 TO WS-CF(3)
     MOVE 1 TO WS-CE(4)
     MOVE 0 TO WS-CF(4)
     MOVE 1 TO WS-CE(5)
     MOVE 0 TO WS-CF(5)
     MOVE 1 TO WS-CE(6)
     MOVE 0 TO WS-CF(6)
     MOVE 1 TO WS-CE(7)
     MOVE 0 TO WS-CF(7)
     MOVE 1 TO WS-CE(8)
     MOVE 0 TO WS-CF(8)
     MOVE 1 TO WS-CE(9)
     MOVE 0 TO WS-CF(9)
     MOVE 1 TO WS-CE(10)
     MOVE 0 TO WS-CF(10)
     MOVE 1 TO WS-CE(11)
     MOVE 0 TO WS-CF(11)
     MOVE 1 TO WS-CE(12)
     MOVE 0 TO WS-CF(12)
     MOVE 1 TO WS-CE(13)
     MOVE 0 TO WS-CF(13)
     MOVE 0 TO WS-CE(14)
     MOVE 1 TO WS-CF(14)
     MOVE 6 TO WS-N1
     CALL "X2-SPAWN-FIND" USING WS-N1 WS-COL WS-N2
     MOVE "acceptance US15 44-x2§2 2.4 floor search: a floor at the 13th step (cell 14) is still found" TO WS-CASE
     MOVE 12 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 END PROGRAM TEST-Q44-44-X2-2.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(160).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.
