*> Scheduled ticks (docs/protocol/29 section 4): the tick priorities (TickPriority values, ordinal = value + 3), the tick types
*> and the per-call limit of LevelTicks.tick (33 section 2.1 step 6).
 78 BT-P-EXTREMELY-HIGH           VALUE -3.
 78 BT-P-VERY-HIGH                VALUE -2.
 78 BT-P-HIGH                     VALUE -1.
 78 BT-P-NORMAL                   VALUE 0.
 78 BT-P-LOW                      VALUE 1.
 78 BT-P-VERY-LOW                 VALUE 2.
 78 BT-P-EXTREMELY-LOW            VALUE 3.
 78 BT-TYPE-BLOCK                 VALUE 1.
 78 BT-TYPE-FLUID                 VALUE 2.
 78 BT-MAX-TICKS                  VALUE 65536.
 78 BT-TABLE-SIZE                 VALUE 32768.
*> The pending ticks of every level, one table (dense: entry 1 to BT-COUNT); BT-SUB-COUNT is each dimension's subTickCount.
*> BT-TRIG is the absolute game time (CW-TICKS) the tick is due.
 01 BLOCK-TICKS EXTERNAL.
    05 BT-COUNT                  BINARY-LONG.
    05 BT-SUB-COUNT              BINARY-LONG OCCURS 3 TIMES.
    05 BT-TICK OCCURS 32768 TIMES.
       10 BT-T-DIM               BINARY-LONG.
       10 BT-T-TYPE              BINARY-LONG.
       10 BT-T-ID                BINARY-LONG.
       10 BT-T-X                 BINARY-LONG.
       10 BT-T-Y                 BINARY-LONG.
       10 BT-T-Z                 BINARY-LONG.
       10 BT-T-TRIG              BINARY-DOUBLE.
       10 BT-T-PRIO              BINARY-LONG.
       10 BT-T-SUB               BINARY-LONG.
