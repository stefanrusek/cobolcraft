*> Shared vocabulary for the AI system (docs/protocol/44-residual-mob-questions-1-shared-model-framework.md section 3, check of the worked example 3.5; lane 002-lane-p49i, T22610; phase task T2690):
*> the terms of 3.1, the Brain tick order of 3.3, the gate semantics of 3.4 and the weighted shuffle of 3.5, as the programs of core/src/q44-44-1.cob. The Brain of a mob here is a state machine per
*> species, so these are the framework's rules over arguments.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-1-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-L1                  BINARY-LONG VALUE 1.
 01 WS-L0                  BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-FA                  FLOAT-LONG.
 01 WS-FB                  FLOAT-LONG.
 01 WS-KEY                 FLOAT-LONG.
 01 WS-WEIGHTS.
    05 WS-W                BINARY-LONG OCCURS 32 TIMES.
 01 WS-DRAWS.
    05 WS-D                FLOAT-LONG OCCURS 32 TIMES.
 01 WS-ORDER.
    05 WS-OR               BINARY-LONG OCCURS 32 TIMES.
 01 WS-RUNNING             PIC X(32) VALUE ALL "0".
 01 WS-CAN                 PIC X(32) VALUE ALL "0".
 01 WS-STARTED             PIC X(32) VALUE ALL "0".
 01 WS-TRIGGERS            PIC X(32) VALUE ALL "0".
 01 WS-NAME40              PIC X(40).
 01 WS-NAME16              PIC X(16).
 01 WS-COUNT-TEXT          PIC 99.
 PROCEDURE DIVISION.
*>   3.5 the worked example: A weight 2 draw 0.25, B weight 1 draw 0.60.
     MOVE 0.25 TO WS-FA
     CALL "Q1-SHUFFLE-KEY" USING WS-FA WS-L1 WS-KEY
     MOVE 2 TO WS-A
     CALL "Q1-SHUFFLE-KEY" USING WS-FA WS-A WS-FB
     MOVE "key of A (weight 2, r 0.25) is -(0.25 ^ 0.5) = -0.5" TO WS-CASE
     MOVE -500000 TO WS-E
     COMPUTE WS-O ROUNDED = WS-FB * 1000000
     PERFORM CHECK-N
     MOVE 0.60 TO WS-FA
     CALL "Q1-SHUFFLE-KEY" USING WS-FA WS-L1 WS-KEY
     MOVE "key of B (weight 1, r 0.60) is -0.6" TO WS-CASE
     MOVE -600000 TO WS-E
     COMPUTE WS-O ROUNDED = WS-KEY * 1000000
     PERFORM CHECK-N
     MOVE 2 TO WS-N
     MOVE 2 TO WS-W(1)
     MOVE 1 TO WS-W(2)
     MOVE 0.25 TO WS-D(1)
     MOVE 0.60 TO WS-D(2)
     CALL "Q1-SHUFFLE-ORDER" USING WS-N WS-WEIGHTS WS-DRAWS WS-ORDER
     MOVE "the shuffle puts B (-0.6) first, then A (-0.5)" TO WS-CASE
     MOVE 21 TO WS-E
     COMPUTE WS-O = WS-OR(1) * 10 + WS-OR(2)
     PERFORM CHECK-N
     MOVE 0.90 TO WS-D(1)
     CALL "Q1-SHUFFLE-ORDER" USING WS-N WS-WEIGHTS WS-DRAWS WS-ORDER
     MOVE "a larger r for the heavier entry (0.90, key -0.9487) puts A first" TO WS-CASE
     MOVE 12 TO WS-E
     COMPUTE WS-O = WS-OR(1) * 10 + WS-OR(2)
     PERFORM CHECK-N
     MOVE 3 TO WS-N
     MOVE 1 TO WS-W(3)
     MOVE 0.30 TO WS-D(1)
     MOVE 0.50 TO WS-D(2)
     MOVE 0.80 TO WS-D(3)
     MOVE 1 TO WS-W(1)
     CALL "Q1-SHUFFLE-ORDER" USING WS-N WS-WEIGHTS WS-DRAWS WS-ORDER
     MOVE "three entries of weight 1 sort ascending by -r: draws .3 .5 .8 give 3 2 1" TO WS-CASE
     MOVE 321 TO WS-E
     COMPUTE WS-O = WS-OR(1) * 100 + WS-OR(2) * 10 + WS-OR(3)
     PERFORM CHECK-N
*>   3.3 the Brain tick order.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         CALL "Q1-BRAIN-STEP" USING WS-I WS-NAME40
         EVALUATE WS-I
             WHEN 1
                 MOVE "forgetOutdatedMemories" TO WS-CASE
             WHEN 2
                 MOVE "tickSensors" TO WS-CASE
             WHEN 3
                 MOVE "startEachNonRunningBehavior" TO WS-CASE
             WHEN 4
                 MOVE "tickEachRunningBehavior" TO WS-CASE
             WHEN OTHER
                 MOVE SPACES TO WS-CASE
         END-EVALUATE
         MOVE 1 TO WS-E
         MOVE 0 TO WS-O
         IF WS-NAME40 = WS-CASE(1:40)
             MOVE 1 TO WS-O
         END-IF
         MOVE WS-I TO WS-COUNT-TEXT
         MOVE SPACES TO WS-CASE
         STRING "Brain.tick step " DELIMITED BY SIZE WS-COUNT-TEXT DELIMITED BY SIZE " (1 forget outdated memories, 2 sensors, 3 start, 4 tick; there is no schedule step)" DELIMITED BY SIZE
             INTO WS-CASE
         PERFORM CHECK-N
     END-PERFORM
     MOVE 1 TO WS-I
     MOVE 5 TO WS-A
     CALL "Q1-MEMORY-TICK" USING WS-A WS-B WS-N
     MOVE "memory expiry: a memory with ttl 5 becomes 4 and is kept" TO WS-CASE
     MOVE 40 TO WS-E
     COMPUTE WS-O = WS-B * 10 + WS-N
     PERFORM CHECK-N
     MOVE 1 TO WS-A
     CALL "Q1-MEMORY-TICK" USING WS-A WS-B WS-N
     MOVE "memory expiry: a memory with ttl 1 reaches 0 and is erased" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-N TO WS-O
     PERFORM CHECK-N
*>   3.1 memory entry conditions.
     CALL "Q1-MEMORY-OK" USING WS-L1 WS-L1 WS-L1 WS-A
     MOVE "VALUE_PRESENT holds when the slot holds a value" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q1-MEMORY-OK" USING WS-L1 WS-L1 WS-L0 WS-A
     MOVE "VALUE_PRESENT fails on an empty slot" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 2 TO WS-N
     CALL "Q1-MEMORY-OK" USING WS-N WS-L1 WS-L0 WS-A
     MOVE "VALUE_ABSENT holds on an empty slot" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q1-MEMORY-OK" USING WS-N WS-L1 WS-L1 WS-A
     MOVE "VALUE_ABSENT fails when the slot holds a value" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 3 TO WS-N
     CALL "Q1-MEMORY-OK" USING WS-N WS-L1 WS-L0 WS-A
     MOVE "REGISTERED holds for a registered key whatever the slot" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     CALL "Q1-MEMORY-OK" USING WS-N WS-L0 WS-L1 WS-A
     MOVE "REGISTERED fails for a key the Brain does not register" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE 9 TO WS-N
     CALL "Q1-MEMORY-OK" USING WS-N WS-L1 WS-L1 WS-A
     MOVE "an unknown status holds nowhere" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
*>   3.1 constants, the activity list, the trackers.
     CALL "Q1-TERM-CONST" USING WS-L1 WS-A
     MOVE 2 TO WS-N
     CALL "Q1-TERM-CONST" USING WS-N WS-B
     MOVE "constants: the sensor scan rate is 20 ticks and a behaviour's default duration range is 60 to 60" TO WS-CASE
     MOVE 2060 TO WS-E
     COMPUTE WS-O = WS-A * 100 + WS-B
     PERFORM CHECK-N
     MOVE 1 TO WS-I
     CALL "Q1-ACTIVITY" USING WS-I WS-NAME16
     MOVE "the first activity is core" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-NAME16 = "core"
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 26 TO WS-I
     CALL "Q1-ACTIVITY" USING WS-I WS-NAME16
     MOVE "the 26th (last) activity is dig" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-NAME16 = "dig"
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 27 TO WS-I
     CALL "Q1-ACTIVITY" USING WS-I WS-NAME16
     MOVE "there is no 27th activity" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-NAME16 = SPACES
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 64.0 TO WS-FA
     MOVE 1.62 TO WS-FB
     MOVE 2 TO WS-N
     CALL "Q1-TRACKER-Y" USING WS-N WS-L1 WS-FA WS-FB WS-KEY
     MOVE "EntityTracker with trackEyes aims at the eye position (64 + 1.62)" TO WS-CASE
     MOVE 65620 TO WS-E
     COMPUTE WS-O ROUNDED = WS-KEY * 1000
     PERFORM CHECK-N
     CALL "Q1-TRACKER-Y" USING WS-N WS-L0 WS-FA WS-FB WS-KEY
     MOVE "EntityTracker without trackEyes aims at the feet (64)" TO WS-CASE
     MOVE 64000 TO WS-E
     COMPUTE WS-O ROUNDED = WS-KEY * 1000
     PERFORM CHECK-N
     CALL "Q1-TRACKER-Y" USING WS-L1 WS-L1 WS-FA WS-FB WS-KEY
     MOVE "a BlockPosTracker is a fixed block: the y is the block's" TO WS-CASE
     MOVE 64000 TO WS-E
     COMPUTE WS-O ROUNDED = WS-KEY * 1000
     PERFORM CHECK-N
*>   3.4 the gates. Children 1 to 3 in order; all stopped; children 2 and 3 can start.
     MOVE 3 TO WS-N
     MOVE 1 TO WS-OR(1)
     MOVE 2 TO WS-OR(2)
     MOVE 3 TO WS-OR(3)
     MOVE "011" TO WS-CAN(1:3)
     MOVE "000" TO WS-RUNNING(1:3)
     CALL "Q1-GATE-START" USING WS-L1 WS-L0 WS-N WS-ORDER WS-RUNNING WS-CAN WS-STARTED WS-A
     MOVE "RUN_ONE: the first child that can start (2) starts and the visit stops" TO WS-CASE
     MOVE 1010 TO WS-E
     COMPUTE WS-O = WS-A * 1000 + FUNCTION NUMVAL(WS-STARTED(1:3))
     PERFORM CHECK-N
     CALL "Q1-GATE-START" USING WS-L1 WS-L1 WS-N WS-ORDER WS-RUNNING WS-CAN WS-STARTED WS-A
     MOVE "TRY_ALL: every child that can start does (2 and 3)" TO WS-CASE
     MOVE 1011 TO WS-E
     COMPUTE WS-O = WS-A * 1000 + FUNCTION NUMVAL(WS-STARTED(1:3))
     PERFORM CHECK-N
     MOVE "001" TO WS-CAN(1:3)
     MOVE 3 TO WS-OR(1)
     MOVE 2 TO WS-OR(2)
     MOVE 1 TO WS-OR(3)
     MOVE "010" TO WS-CAN(1:3)
     MOVE "010" TO WS-RUNNING(1:3)
     MOVE "011" TO WS-CAN(1:3)
     CALL "Q1-GATE-START" USING WS-L1 WS-L0 WS-N WS-ORDER WS-RUNNING WS-CAN WS-STARTED WS-A
     MOVE "only STOPPED children are considered: with child 2 running the visit order 3, 2, 1 starts child 3" TO WS-CASE
     MOVE 1001 TO WS-E
     COMPUTE WS-O = WS-A * 1000 + FUNCTION NUMVAL(WS-STARTED(1:3))
     PERFORM CHECK-N
     MOVE "000" TO WS-CAN(1:3)
     MOVE "000" TO WS-RUNNING(1:3)
     CALL "Q1-GATE-START" USING WS-L1 WS-L0 WS-N WS-ORDER WS-RUNNING WS-CAN WS-STARTED WS-A
     MOVE "tryStart returns true even when no child could start" TO WS-CASE
     MOVE 1000 TO WS-E
     COMPUTE WS-O = WS-A * 1000 + FUNCTION NUMVAL(WS-STARTED(1:3))
     PERFORM CHECK-N
     CALL "Q1-GATE-START" USING WS-L0 WS-L0 WS-N WS-ORDER WS-RUNNING WS-CAN WS-STARTED WS-A
     MOVE "tryStart returns false when an entry condition fails and nothing starts" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-A * 1000 + FUNCTION NUMVAL(WS-STARTED(1:3))
     PERFORM CHECK-N
     CALL "Q1-GATE-TICK" USING WS-N WS-RUNNING WS-A
     MOVE "a gate in which no child is running stops in the same Brain tick" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE "010" TO WS-RUNNING(1:3)
     CALL "Q1-GATE-TICK" USING WS-N WS-RUNNING WS-A
     MOVE "a gate with a running child goes on" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-A TO WS-O
     PERFORM CHECK-N
     MOVE "101" TO WS-RUNNING(1:3)
     CALL "Q1-GATE-STOP" USING WS-N WS-RUNNING WS-A
     MOVE "doStop stops every child still running (two of them)" TO WS-CASE
     MOVE 2000 TO WS-E
     COMPUTE WS-O = WS-A * 1000 + FUNCTION NUMVAL(WS-RUNNING(1:3))
     PERFORM CHECK-N
*>   TriggerGate: RUN_ONE stops after the first true, TRY_ALL calls all; the OneShot returns true.
     MOVE "010" TO WS-TRIGGERS(1:3)
     CALL "Q1-TRIGGER-GATE" USING WS-L0 WS-N WS-TRIGGERS WS-A WS-B
     MOVE "TriggerGate RUN_ONE: the visit stops after the second trigger (true), the OneShot returns true" TO WS-CASE
     MOVE 21 TO WS-E
     COMPUTE WS-O = WS-A * 10 + WS-B
     PERFORM CHECK-N
     CALL "Q1-TRIGGER-GATE" USING WS-L1 WS-N WS-TRIGGERS WS-A WS-B
     MOVE "TriggerGate TRY_ALL: all three triggers are called" TO WS-CASE
     MOVE 31 TO WS-E
     COMPUTE WS-O = WS-A * 10 + WS-B
     PERFORM CHECK-N
     MOVE "000" TO WS-TRIGGERS(1:3)
     CALL "Q1-TRIGGER-GATE" USING WS-L0 WS-N WS-TRIGGERS WS-A WS-B
     MOVE "TriggerGate RUN_ONE with no trigger true calls all and still returns true" TO WS-CASE
     MOVE 31 TO WS-E
     COMPUTE WS-O = WS-A * 10 + WS-B
     PERFORM CHECK-N
     STOP RUN.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 44-1§3 Shared vocabulary for the AI system: " DELIMITED BY SIZE FUNCTION TRIM(WS-CASE(1:195)) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-1-3.
