*> Goal selector state of one mob (docs/protocol/18-mob-framework.md section 4.1), table driven: the caller registers goals
*> (GOAL-ADD), sets GS-CAN-USE / GS-CAN-CONTINUE of every goal from its own conditions before each evaluation, and applies the
*> actions that GOAL-SELECTOR-TICK appends to the log (start, stop, tick of goal GS-LOG-GOAL).
*> Flags: 1 MOVE, 2 LOOK, 3 JUMP, 4 TARGET. A lower priority number is a higher priority.
 01 GS-STATE.
    05 GS-COUNT             BINARY-LONG.
    05 GS-DISABLED          PIC 9 OCCURS 4 TIMES.
    05 GS-LOCK              BINARY-LONG OCCURS 4 TIMES.
    05 GS-LOG-COUNT         BINARY-LONG.
    05 GS-LOG OCCURS 64 TIMES.
       10 GS-LOG-ACTION     PIC 9.
          88 GS-LOG-START   VALUE 1.
          88 GS-LOG-STOP    VALUE 2.
          88 GS-LOG-TICK    VALUE 3.
       10 GS-LOG-GOAL       BINARY-LONG.
    05 GS-GOAL OCCURS 24 TIMES.
       10 GS-PRIORITY       BINARY-LONG.
       10 GS-FLAG           PIC 9 OCCURS 4 TIMES.
       10 GS-INTERRUPTABLE  PIC 9.
       10 GS-EVERY-TICK     PIC 9.
       10 GS-RUNNING        PIC 9.
       10 GS-CAN-USE        PIC 9.
       10 GS-CAN-CONTINUE   PIC 9.
