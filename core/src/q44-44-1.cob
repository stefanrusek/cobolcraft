*> Residual mob questions, part 1 (docs/protocol/44-residual-mob-questions-1-shared-model-framework.md; lane 002-lane-p49i, T22610 and following): the shared vocabulary of the AI system
*> (section 3): the gate policies, the TriggerGate, the weighted shuffle, the Brain tick order, the memory entry conditions and the constants of the terms. The Brain of a mob in this core is a state
*> machine per species, not a generic framework, so these programs are the framework's rules over arguments (a child is a flag and an index, a draw is an argument) and each species' own code is
*> checked against them by the tests of its section.
*>   Q1-SHUFFLE-KEY USING r, weight, key out                 k = -(r ^ (1 / w))
*>   Q1-SHUFFLE-ORDER USING count, weights, draws, order out the indexes of the entries sorted ascending by key
*>   Q1-GATE-START USING entry ok, running policy, count, order, running flags, can start flags, started flags out, result out
*>   Q1-GATE-TICK USING count, running flags, stop out       the gate stops when no child is running after the tick
*>   Q1-GATE-STOP USING count, running flags, stopped out    doStop: every child still running is stopped
*>   Q1-TRIGGER-GATE USING running policy, count, trigger results, called out, result out
*>   Q1-BRAIN-STEP USING n, name out                         the four steps of Brain.tick in order (name spaces past the fourth)
*>   Q1-MEMORY-OK USING status, registered, has value, ok out   1 VALUE_PRESENT, 2 VALUE_ABSENT, 3 REGISTERED
*>   Q1-MEMORY-TICK USING ttl, new ttl out, erased out
*>   Q1-TERM-CONST USING code, out                           1 sensor scan rate 20, 2 behaviour minimum duration 60, 3 maximum 60
*>   Q1-ACTIVITY USING n, name out                           the 26 activities in the order of 3.1
*>   Q1-TRACKER-Y USING kind (1 block position, 2 entity), track eyes, y, eye height, aim y out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q1-SHUFFLE-KEY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-R                    FLOAT-LONG.
 01 L-WEIGHT               BINARY-LONG.
 01 L-KEY                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-R L-WEIGHT L-KEY.
     COMPUTE L-KEY = 0 - (L-R ** (1 / L-WEIGHT))
     GOBACK.
 END PROGRAM Q1-SHUFFLE-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q1-SHUFFLE-ORDER.
*> USING count, weights (a positive integer each), draws (one r in [0, 1) per entry), order out: ShufflingList.shuffle, an ascending sort by the key (a stable insertion sort).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-PREV                BINARY-LONG.
 01 WS-PID                 BINARY-LONG.
 01 WS-KEYS.
    05 WS-K                FLOAT-LONG OCCURS 32 TIMES.
 01 WS-ONE                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-WEIGHTS.
    05 L-W                 BINARY-LONG OCCURS 32 TIMES.
 01 L-DRAWS.
    05 L-D                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-ORDER.
    05 L-O                 BINARY-LONG OCCURS 32 TIMES.
 PROCEDURE DIVISION USING L-COUNT L-WEIGHTS L-DRAWS L-ORDER.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         CALL "Q1-SHUFFLE-KEY" USING L-D(WS-I) L-W(WS-I) WS-K(WS-I)
         MOVE WS-I TO L-O(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > L-COUNT
         MOVE L-O(WS-I) TO WS-ID
         MOVE WS-I TO WS-J
         PERFORM UNTIL WS-J < 2
             COMPUTE WS-PREV = WS-J - 1
             MOVE L-O(WS-PREV) TO WS-PID
             IF WS-K(WS-ID) < WS-K(WS-PID)
                 MOVE WS-PID TO L-O(WS-J)
                 SUBTRACT 1 FROM WS-J
             ELSE
                 EXIT PERFORM
             END-IF
         END-PERFORM
         MOVE WS-ID TO L-O(WS-J)
     END-PERFORM
     GOBACK.
 END PROGRAM Q1-SHUFFLE-ORDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q1-GATE-START.
*> tryStart (3.4 lifecycle step 1): when every entry condition holds the gate is RUNNING and the running policy is applied over the children in the given order, considering only STOPPED
*> children (running flag 0): RUN_ONE (policy 0) starts the first that can start and stops there, TRY_ALL (1) starts every one that can; the result is 1 even when no child started. When an entry
*> condition fails the result is 0 and nothing starts.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ENTRY                BINARY-LONG.
 01 L-POLICY               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-ORDER.
    05 L-O                 BINARY-LONG OCCURS 32 TIMES.
 01 L-RUNNING.
    05 L-R                 PIC 9 OCCURS 32 TIMES.
 01 L-CAN.
    05 L-CS                PIC 9 OCCURS 32 TIMES.
 01 L-STARTED.
    05 L-ST                PIC 9 OCCURS 32 TIMES.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTRY L-POLICY L-COUNT L-ORDER L-RUNNING L-CAN L-STARTED L-RESULT.
     MOVE ALL "0" TO L-STARTED
     MOVE 0 TO L-RESULT WS-DONE
     IF L-ENTRY = 1
         MOVE 1 TO L-RESULT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT OR WS-DONE = 1
             MOVE L-O(WS-I) TO WS-C
             IF L-R(WS-C) = 0 AND L-CS(WS-C) = 1
                 MOVE "1" TO L-ST(WS-C)
                 IF L-POLICY = 0
                     MOVE 1 TO WS-DONE
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM Q1-GATE-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q1-GATE-TICK.
*> tickOrStop (3.4 step 2): afterwards, if no child is RUNNING the gate calls its own doStop (stop 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-RUNNING.
    05 L-R                 PIC 9 OCCURS 32 TIMES.
 01 L-STOP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-RUNNING L-STOP.
     MOVE 1 TO L-STOP
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         IF L-R(WS-I) = 1
             MOVE 0 TO L-STOP
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM Q1-GATE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q1-GATE-STOP.
*> doStop (3.4 step 3): every child still RUNNING is stopped (stopped = how many); the erase-on-exit memories are the caller's.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-RUNNING.
    05 L-R                 PIC 9 OCCURS 32 TIMES.
 01 L-STOPPED              BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-RUNNING L-STOPPED.
     MOVE 0 TO L-STOPPED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         IF L-R(WS-I) = 1
             MOVE "0" TO L-R(WS-I)
             ADD 1 TO L-STOPPED
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM Q1-GATE-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q1-TRIGGER-GATE.
*> TriggerGate (3.4): the triggers are visited in list order; each is called; after one that returns true RUN_ONE (0) stops the visit and TRY_ALL (1) goes on. called = how many were
*> called. The OneShot itself always returns true (result 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-POLICY               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-TRIGGERS.
    05 L-T                 PIC 9 OCCURS 32 TIMES.
 01 L-CALLED               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-POLICY L-COUNT L-TRIGGERS L-CALLED L-RESULT.
     MOVE 0 TO L-CALLED WS-DONE
     MOVE 1 TO L-RESULT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT OR WS-DONE = 1
         ADD 1 TO L-CALLED
         IF L-T(WS-I) = 1 AND L-POLICY = 0
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM Q1-TRIGGER-GATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q1-BRAIN-STEP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-NAME                 PIC X(40).
 PROCEDURE DIVISION USING L-N L-NAME.
     MOVE SPACES TO L-NAME
     EVALUATE L-N
         WHEN 1
             MOVE "forgetOutdatedMemories" TO L-NAME
         WHEN 2
             MOVE "tickSensors" TO L-NAME
         WHEN 3
             MOVE "startEachNonRunningBehavior" TO L-NAME
         WHEN 4
             MOVE "tickEachRunningBehavior" TO L-NAME
     END-EVALUATE
     GOBACK.
 END PROGRAM Q1-BRAIN-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q1-MEMORY-OK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STATUS               BINARY-LONG.
 01 L-REGISTERED           BINARY-LONG.
 01 L-HAS-VALUE            BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATUS L-REGISTERED L-HAS-VALUE L-OK.
     MOVE 0 TO L-OK
     EVALUATE L-STATUS
         WHEN 1
             IF L-HAS-VALUE = 1
                 MOVE 1 TO L-OK
             END-IF
         WHEN 2
             IF L-HAS-VALUE = 0
                 MOVE 1 TO L-OK
             END-IF
         WHEN 3
             IF L-REGISTERED = 1
                 MOVE 1 TO L-OK
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM Q1-MEMORY-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q1-MEMORY-TICK.
*> forgetOutdatedMemories (3.3 step 1): every memory with a timer is decremented and erased at expiry.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TTL                  BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-ERASED               BINARY-LONG.
 PROCEDURE DIVISION USING L-TTL L-NEW L-ERASED.
     COMPUTE L-NEW = L-TTL - 1
     MOVE 0 TO L-ERASED
     IF L-NEW <= 0
         MOVE 1 TO L-ERASED
     END-IF
     GOBACK.
 END PROGRAM Q1-MEMORY-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q1-TERM-CONST.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CODE                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-CODE L-OUT.
     MOVE 60 TO L-OUT
     IF L-CODE = 1
         MOVE 20 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM Q1-TERM-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q1-ACTIVITY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DATA.
    05 FILLER              PIC X(16) VALUE "core".
    05 FILLER              PIC X(16) VALUE "idle".
    05 FILLER              PIC X(16) VALUE "work".
    05 FILLER              PIC X(16) VALUE "play".
    05 FILLER              PIC X(16) VALUE "rest".
    05 FILLER              PIC X(16) VALUE "meet".
    05 FILLER              PIC X(16) VALUE "panic".
    05 FILLER              PIC X(16) VALUE "raid".
    05 FILLER              PIC X(16) VALUE "pre_raid".
    05 FILLER              PIC X(16) VALUE "hide".
    05 FILLER              PIC X(16) VALUE "fight".
    05 FILLER              PIC X(16) VALUE "celebrate".
    05 FILLER              PIC X(16) VALUE "admire_item".
    05 FILLER              PIC X(16) VALUE "avoid".
    05 FILLER              PIC X(16) VALUE "ride".
    05 FILLER              PIC X(16) VALUE "play_dead".
    05 FILLER              PIC X(16) VALUE "long_jump".
    05 FILLER              PIC X(16) VALUE "ram".
    05 FILLER              PIC X(16) VALUE "tongue".
    05 FILLER              PIC X(16) VALUE "swim".
    05 FILLER              PIC X(16) VALUE "lay_spawn".
    05 FILLER              PIC X(16) VALUE "sniff".
    05 FILLER              PIC X(16) VALUE "investigate".
    05 FILLER              PIC X(16) VALUE "roar".
    05 FILLER              PIC X(16) VALUE "emerge".
    05 FILLER              PIC X(16) VALUE "dig".
 01 WS-TABLE REDEFINES WS-DATA.
    05 WS-NAME             PIC X(16) OCCURS 26 TIMES.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-NAME                 PIC X(16).
 PROCEDURE DIVISION USING L-N L-NAME.
     MOVE SPACES TO L-NAME
     IF L-N >= 1 AND L-N <= 26
         MOVE WS-NAME(L-N) TO L-NAME
     END-IF
     GOBACK.
 END PROGRAM Q1-ACTIVITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. Q1-TRACKER-Y.
*> PositionTracker (3.1): a BlockPosTracker is a fixed block (the y is the block's); an EntityTracker aims at the eye position when trackEyes is true, else at the feet.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-EYES                 BINARY-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-EYE-HEIGHT           FLOAT-LONG.
 01 L-AIM                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-KIND L-EYES L-Y L-EYE-HEIGHT L-AIM.
     MOVE L-Y TO L-AIM
     IF L-KIND = 2 AND L-EYES = 1
         COMPUTE L-AIM = L-Y + L-EYE-HEIGHT
     END-IF
     GOBACK.
 END PROGRAM Q1-TRACKER-Y.
