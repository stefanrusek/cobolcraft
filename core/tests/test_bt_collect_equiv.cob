*> Equivalence test of BT-COLLECT (core/src/blockupd-29.cob; lane perfsteady). A world loading schedules thousands of fluid ticks, and the drain of the queue (BT-DRAIN,
*> every game tick) looked each chunk's head up with a pass over the whole table (a decimal division a row), once per chunk and per tick polled: seconds a tick, the
*> frame rate 0 of a loading world. BT-COLLECT does steps 1 and 2 of LevelTicks.tick (29 section 4.3) on the due ticks only, with the chunk of a tick kept in the table
*> (BT-ADD) and the heads kept per chunk. This test drives it and the old programs (REF-BT-HEAD, REF-BT-BEST-CHUNK, REF-BT-COLLECT: the code of the old BT-DRAIN steps 1
*> and 2, verbatim, but for the names) over the same random queues (two dimensions and both types, positions on both sides of zero in and out of the ticking range,
*> trigger times round the game time, all seven priorities, unique sub-tick orders, limits from 1 to the whole queue) and compares the run lists and what is left of the
*> table, row by row; then the cost of a collect of 30000 due ticks of 600 chunks, which the old code took minutes for.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BT-COLLECT-EQUIV.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY BLOCKTICK.
 COPY BTRUN.
 01 WS-PREV.
    05 WS-P-DIM            BINARY-LONG VALUE 1.
    05 WS-P-TYPE           BINARY-LONG VALUE 1.
    05 WS-P-X              BINARY-LONG VALUE 0.
    05 WS-P-Y              BINARY-LONG VALUE 0.
    05 WS-P-Z              BINARY-LONG VALUE 0.
    05 WS-P-TRIG           BINARY-DOUBLE VALUE 1000.
    05 WS-P-PRIO           BINARY-LONG VALUE 0.
    05 WS-P-SUB            BINARY-LONG VALUE 0.
 01 WS-NEW-RUN.
    05 WS-NEW-COUNT        BINARY-LONG.
    05 WS-NEW-ROW OCCURS 32768 TIMES.
       10 WS-NEW-ID        BINARY-LONG.
       10 WS-NEW-X         BINARY-LONG.
       10 WS-NEW-Y         BINARY-LONG.
       10 WS-NEW-Z         BINARY-LONG.
 01 WS-SNAP                PIC X(1867800).
 01 WS-AFTER-NEW           PIC X(1867800).
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE VALUE 12345.
 01 WS-Q                   BINARY-DOUBLE.
 01 WS-N                   BINARY-LONG.
 01 WS-ROUND               BINARY-LONG.
 01 WS-ROUNDS              BINARY-LONG VALUE 60.
 01 WS-I                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-TRIG                BINARY-DOUBLE.
 01 WS-PRIO                BINARY-LONG.
 01 WS-SUB                 BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-SAME-RUN            BINARY-LONG.
 01 WS-SAME-TABLE          BINARY-LONG.
 01 WS-BAD-ROUNDS          BINARY-LONG.
 01 WS-TOTAL-RUN           BINARY-LONG.
 01 WS-COLLECTS            BINARY-LONG.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-US                  BINARY-DOUBLE.
 01 WS-CHUNK-SPAN          BINARY-LONG.
 01 WS-ENV                 PIC X(8).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BT_ROUNDS"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-ROUNDS = FUNCTION NUMVAL(WS-ENV)
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 13 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "T" TO TL-MODE
     MOVE 0 TO WS-BAD-ROUNDS WS-TOTAL-RUN WS-COLLECTS
     PERFORM VARYING WS-ROUND FROM 1 BY 1 UNTIL WS-ROUND > WS-ROUNDS
         MOVE 0 TO BT-COUNT
         MOVE 0 TO BT-SUB-COUNT(1) BT-SUB-COUNT(2)
         MOVE 1000 TO CW-TICKS
*>       from a handful to a few thousand ticks, over 32 chunks a side, the view distance of 13 leaving the outer ones out of the ticking range
         PERFORM NEXT-RANDOM
         COMPUTE WS-N = 1 + FUNCTION MOD(WS-Q, 4) * FUNCTION MOD(WS-Q, 4) * 40 + FUNCTION MOD(WS-ROUND, 7) * 10
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
             PERFORM NEXT-RANDOM
             COMPUTE WS-DIM = 1 + FUNCTION MOD(WS-Q, 8) / 7
             PERFORM NEXT-RANDOM
             COMPUTE WS-TYPE = 1 + FUNCTION MOD(WS-Q, 2)
             PERFORM NEXT-RANDOM
             COMPUTE WS-X = FUNCTION MOD(WS-Q, 512) - 256
             PERFORM NEXT-RANDOM
             COMPUTE WS-Z = FUNCTION MOD(WS-Q, 512) - 256
             PERFORM NEXT-RANDOM
             COMPUTE WS-Y = FUNCTION MOD(WS-Q, 60)
             PERFORM NEXT-RANDOM
             COMPUTE WS-TRIG = 1000 + FUNCTION MOD(WS-Q, 6) - 3
             PERFORM NEXT-RANDOM
             COMPUTE WS-PRIO = FUNCTION MOD(WS-Q, 7) - 3
             PERFORM NEXT-RANDOM
             COMPUTE WS-ID = FUNCTION MOD(WS-Q, 50)
             MOVE BT-SUB-COUNT(WS-DIM) TO WS-SUB
             ADD 1 TO BT-SUB-COUNT(WS-DIM)
*>           one tick in eight is a twin of the one before: the same chunk, time, priority and sub-tick order at another height (the lower index of the two goes first)
             PERFORM NEXT-RANDOM
             IF FUNCTION MOD(WS-Q, 8) = 0 AND WS-I > 1
                 SUBTRACT 1 FROM BT-SUB-COUNT(WS-DIM)
                 MOVE WS-P-DIM TO WS-DIM
                 MOVE WS-P-TYPE TO WS-TYPE
                 MOVE WS-P-X TO WS-X
                 MOVE WS-P-Z TO WS-Z
                 COMPUTE WS-Y = WS-P-Y + 1
                 MOVE WS-P-TRIG TO WS-TRIG
                 MOVE WS-P-PRIO TO WS-PRIO
                 MOVE WS-P-SUB TO WS-SUB
             END-IF
             MOVE WS-DIM TO WS-P-DIM
             MOVE WS-TYPE TO WS-P-TYPE
             MOVE WS-X TO WS-P-X
             MOVE WS-Y TO WS-P-Y
             MOVE WS-Z TO WS-P-Z
             MOVE WS-TRIG TO WS-P-TRIG
             MOVE WS-PRIO TO WS-P-PRIO
             MOVE WS-SUB TO WS-P-SUB
             CALL "BT-ADD" USING WS-DIM WS-TYPE WS-ID WS-X WS-Y WS-Z WS-TRIG WS-PRIO WS-SUB WS-RESULT
         END-PERFORM
         PERFORM NEXT-RANDOM
         EVALUATE FUNCTION MOD(WS-Q, 5)
             WHEN 0 MOVE 65536 TO WS-MAX
             WHEN 1 MOVE 65536 TO WS-MAX
             WHEN 2 MOVE 1 TO WS-MAX
             WHEN OTHER COMPUTE WS-MAX = 1 + FUNCTION MOD(WS-Q, 1 + BT-COUNT)
         END-EVALUATE
*>       the queue drained is the first dimension's (the player's: only its chunks tick), of the block or the fluid type by round; the second dimension's ticks are in the table as noise
         MOVE 1 TO WS-DIM
         COMPUTE WS-TYPE = 1 + FUNCTION MOD(WS-ROUND, 2)
         MOVE BLOCK-TICKS(1:1867800) TO WS-SNAP
         CALL "BT-COLLECT" USING WS-DIM WS-TYPE WS-MAX BT-RUN-LIST
         MOVE BT-RUN-LIST TO WS-NEW-RUN
         MOVE BLOCK-TICKS(1:1867800) TO WS-AFTER-NEW
         MOVE WS-SNAP TO BLOCK-TICKS(1:1867800)
         CALL "REF-BT-COLLECT" USING WS-DIM WS-TYPE WS-MAX BT-RUN-LIST
         MOVE 1 TO WS-SAME-RUN
         IF BT-R-COUNT NOT = WS-NEW-COUNT
             MOVE 0 TO WS-SAME-RUN
         ELSE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BT-R-COUNT
                 IF BT-R-ID(WS-I) NOT = WS-NEW-ID(WS-I) OR BT-R-X(WS-I) NOT = WS-NEW-X(WS-I)
                         OR BT-R-Y(WS-I) NOT = WS-NEW-Y(WS-I) OR BT-R-Z(WS-I) NOT = WS-NEW-Z(WS-I)
                     MOVE 0 TO WS-SAME-RUN
                 END-IF
             END-PERFORM
         END-IF
         ADD BT-R-COUNT TO WS-TOTAL-RUN
         MOVE 1 TO WS-SAME-TABLE
         IF BLOCK-TICKS(1:1867800) NOT = WS-AFTER-NEW
             MOVE 0 TO WS-SAME-TABLE
         END-IF
         IF WS-SAME-RUN = 0 OR WS-SAME-TABLE = 0
             ADD 1 TO WS-BAD-ROUNDS
             MOVE WS-ROUND TO WS-E1
             MOVE WS-N TO WS-E2
             MOVE BT-R-COUNT TO WS-E3
             DISPLAY "round " FUNCTION TRIM(WS-E1) " ticks " FUNCTION TRIM(WS-E2) " reference ran " FUNCTION TRIM(WS-E3)
                 " same run " WS-SAME-RUN " same table " WS-SAME-TABLE
         END-IF
         ADD 1 TO WS-COLLECTS
     END-PERFORM
     MOVE "perfsteady: given 60 random queues when BT-COLLECT and the old drain collect them then the run lists and the tables left are the same" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-ROUNDS TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     DISPLAY "ticks run by the random queues " WS-TOTAL-RUN
     MOVE "perfsteady: the random queues ran a good number of ticks (the comparison is not of empty lists)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TOTAL-RUN > 1000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   30000 due fluid ticks in 600 chunks of the first dimension that tick (a world loading): the cost of one collect
     MOVE 0 TO BT-COUNT
     MOVE 0 TO BT-SUB-COUNT(1)
     MOVE 1000 TO CW-TICKS
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= 30000
         COMPUTE WS-X = FUNCTION MOD(WS-I, 384) - 192
         COMPUTE WS-Z = FUNCTION MOD(WS-I * 13, 400) - 200
         DIVIDE WS-I BY 9600 GIVING WS-Y
         MOVE 1 TO WS-DIM
         MOVE 2 TO WS-TYPE
         MOVE 1 TO WS-ID
         COMPUTE WS-TRIG = 1000 - FUNCTION MOD(WS-I, 3)
         COMPUTE WS-PRIO = FUNCTION MOD(WS-I, 7) - 3
         MOVE BT-SUB-COUNT(1) TO WS-SUB
         ADD 1 TO BT-SUB-COUNT(1)
         CALL "BT-ADD" USING WS-DIM WS-TYPE WS-ID WS-X WS-Y WS-Z WS-TRIG WS-PRIO WS-SUB WS-RESULT
     END-PERFORM
     MOVE 65536 TO WS-MAX
     CALL STATIC "clock" RETURNING WS-T0
     CALL "BT-COLLECT" USING WS-DIM WS-TYPE WS-MAX BT-RUN-LIST
     CALL STATIC "clock" RETURNING WS-T1
     COMPUTE WS-US = WS-T1 - WS-T0
     DISPLAY "PERF BT-COLLECT of " BT-R-COUNT " due ticks us " WS-US
     MOVE "perfsteady: given 30000 due ticks in about 600 chunks when they are collected then it takes under 3 s of CPU" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-US < 3000000 AND BT-R-COUNT > 20000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 NEXT-RANDOM.
     COMPUTE WS-SEED = FUNCTION MOD(WS-SEED * 1103515245 + 12345, 2147483648)
     DIVIDE WS-SEED BY 65536 GIVING WS-Q
     .
 END PROGRAM TEST-BT-COLLECT-EQUIV.

*> The old steps 1 and 2 of BT-DRAIN, as they were before BT-COLLECT.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. REF-BT-HEAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BLOCKTICK.
 01 WS-I                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-BETTER              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-TYPE L-CX L-CZ L-INDEX.
     MOVE 0 TO L-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BT-COUNT
         COMPUTE WS-CX = (BT-T-X(WS-I) - FUNCTION MOD(BT-T-X(WS-I), 16)) / 16
         COMPUTE WS-CZ = (BT-T-Z(WS-I) - FUNCTION MOD(BT-T-Z(WS-I), 16)) / 16
         IF BT-T-DIM(WS-I) = L-DIM AND BT-T-TYPE(WS-I) = L-TYPE AND WS-CX = L-CX AND WS-CZ = L-CZ
             MOVE 0 TO WS-BETTER
             IF L-INDEX = 0
                 MOVE 1 TO WS-BETTER
             ELSE
                 EVALUATE TRUE
                     WHEN BT-T-TRIG(WS-I) < BT-T-TRIG(L-INDEX)
                         MOVE 1 TO WS-BETTER
                     WHEN BT-T-TRIG(WS-I) > BT-T-TRIG(L-INDEX)
                         CONTINUE
                     WHEN BT-T-PRIO(WS-I) < BT-T-PRIO(L-INDEX)
                         MOVE 1 TO WS-BETTER
                     WHEN BT-T-PRIO(WS-I) > BT-T-PRIO(L-INDEX)
                         CONTINUE
                     WHEN BT-T-SUB(WS-I) < BT-T-SUB(L-INDEX)
                         MOVE 1 TO WS-BETTER
                 END-EVALUATE
             END-IF
             IF WS-BETTER = 1
                 MOVE WS-I TO L-INDEX
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM REF-BT-HEAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REF-BT-BEST-CHUNK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BLOCKTICK.
 01 WS-J                   BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-BETTER              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-CHUNKS.
    05 L-CHUNK OCCURS 4096 TIMES.
       10 L-C-CX           BINARY-LONG.
       10 L-C-CZ           BINARY-LONG.
       10 L-C-IN           BINARY-LONG.
 01 L-BEST                 BINARY-LONG.
 01 L-HEAD                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-TYPE L-COUNT L-CHUNKS L-BEST L-HEAD.
     MOVE 0 TO L-BEST L-HEAD
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > L-COUNT
         IF L-C-IN(WS-J) = 1
             CALL "REF-BT-HEAD" USING L-DIM L-TYPE L-C-CX(WS-J) L-C-CZ(WS-J) WS-HEAD
             MOVE 0 TO WS-BETTER
             IF L-BEST = 0
                 MOVE 1 TO WS-BETTER
             ELSE
                 IF BT-T-PRIO(WS-HEAD) < BT-T-PRIO(L-HEAD)
                         OR (BT-T-PRIO(WS-HEAD) = BT-T-PRIO(L-HEAD) AND BT-T-SUB(WS-HEAD) < BT-T-SUB(L-HEAD))
                     MOVE 1 TO WS-BETTER
                 END-IF
             END-IF
             IF WS-BETTER = 1
                 MOVE WS-J TO L-BEST
                 MOVE WS-HEAD TO L-HEAD
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM REF-BT-BEST-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REF-BT-COLLECT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BLOCKTICK.
 01 WS-CHUNKS.
    05 WS-CHUNK OCCURS 4096 TIMES.
       10 WS-C-CX          BINARY-LONG.
       10 WS-C-CZ          BINARY-LONG.
       10 WS-C-IN          BINARY-LONG.
 01 WS-CHUNK-COUNT         BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-BEST-HEAD           BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-NEXT-HEAD           BINARY-LONG.
 01 WS-TICKING             BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 COPY BTRUN.
 PROCEDURE DIVISION USING L-DIM L-TYPE L-MAX BT-RUN-LIST.
     MOVE 0 TO BT-R-COUNT WS-CHUNK-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BT-COUNT
         IF BT-T-DIM(WS-I) = L-DIM AND BT-T-TYPE(WS-I) = L-TYPE
             COMPUTE WS-CX = (BT-T-X(WS-I) - FUNCTION MOD(BT-T-X(WS-I), 16)) / 16
             COMPUTE WS-CZ = (BT-T-Z(WS-I) - FUNCTION MOD(BT-T-Z(WS-I), 16)) / 16
             MOVE 0 TO WS-SEEN
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-CHUNK-COUNT
                 IF WS-C-CX(WS-J) = WS-CX AND WS-C-CZ(WS-J) = WS-CZ
                     MOVE 1 TO WS-SEEN
                 END-IF
             END-PERFORM
             IF WS-SEEN = 0
                 ADD 1 TO WS-CHUNK-COUNT
                 MOVE WS-CX TO WS-C-CX(WS-CHUNK-COUNT)
                 MOVE WS-CZ TO WS-C-CZ(WS-CHUNK-COUNT)
                 MOVE 0 TO WS-C-IN(WS-CHUNK-COUNT)
                 CALL "REF-BT-HEAD" USING L-DIM L-TYPE WS-CX WS-CZ WS-HEAD
                 CALL "BT-CHUNK-TICKS" USING L-DIM WS-CX WS-CZ WS-TICKING
                 IF BT-T-TRIG(WS-HEAD) <= CW-TICKS AND WS-TICKING = 1
                     MOVE 1 TO WS-C-IN(WS-CHUNK-COUNT)
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     PERFORM UNTIL BT-R-COUNT >= L-MAX
         CALL "REF-BT-BEST-CHUNK" USING L-DIM L-TYPE WS-CHUNK-COUNT WS-CHUNKS WS-BEST WS-BEST-HEAD
         IF WS-BEST = 0
             EXIT PERFORM
         END-IF
         MOVE 0 TO WS-C-IN(WS-BEST)
         MOVE WS-C-CX(WS-BEST) TO WS-CX
         MOVE WS-C-CZ(WS-BEST) TO WS-CZ
         MOVE WS-BEST-HEAD TO WS-HEAD
         ADD 1 TO BT-R-COUNT
         MOVE BT-T-ID(WS-HEAD) TO BT-R-ID(BT-R-COUNT)
         MOVE BT-T-X(WS-HEAD) TO BT-R-X(BT-R-COUNT)
         MOVE BT-T-Y(WS-HEAD) TO BT-R-Y(BT-R-COUNT)
         MOVE BT-T-Z(WS-HEAD) TO BT-R-Z(BT-R-COUNT)
         CALL "BT-POLL" USING WS-HEAD
         PERFORM UNTIL BT-R-COUNT >= L-MAX
             CALL "REF-BT-HEAD" USING L-DIM L-TYPE WS-CX WS-CZ WS-HEAD
             IF WS-HEAD = 0
                 EXIT PERFORM
             END-IF
             IF BT-T-TRIG(WS-HEAD) > CW-TICKS
                 EXIT PERFORM
             END-IF
             CALL "REF-BT-BEST-CHUNK" USING L-DIM L-TYPE WS-CHUNK-COUNT WS-CHUNKS WS-NEXT WS-NEXT-HEAD
             IF WS-NEXT > 0
                 IF BT-T-PRIO(WS-HEAD) > BT-T-PRIO(WS-NEXT-HEAD)
                         OR (BT-T-PRIO(WS-HEAD) = BT-T-PRIO(WS-NEXT-HEAD)
                             AND BT-T-SUB(WS-HEAD) > BT-T-SUB(WS-NEXT-HEAD))
                     EXIT PERFORM
                 END-IF
             END-IF
             ADD 1 TO BT-R-COUNT
             MOVE BT-T-ID(WS-HEAD) TO BT-R-ID(BT-R-COUNT)
             MOVE BT-T-X(WS-HEAD) TO BT-R-X(BT-R-COUNT)
             MOVE BT-T-Y(WS-HEAD) TO BT-R-Y(BT-R-COUNT)
             MOVE BT-T-Z(WS-HEAD) TO BT-R-Z(BT-R-COUNT)
             CALL "BT-POLL" USING WS-HEAD
         END-PERFORM
         CALL "REF-BT-HEAD" USING L-DIM L-TYPE WS-CX WS-CZ WS-HEAD
         IF WS-HEAD > 0 AND BT-R-COUNT < L-MAX
             IF BT-T-TRIG(WS-HEAD) <= CW-TICKS
                 MOVE 1 TO WS-C-IN(WS-BEST)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM REF-BT-COLLECT.

 COPY CORETEST.
