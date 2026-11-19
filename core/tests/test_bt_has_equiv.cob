*> Equivalence test of BT-HAS, BT-ADD and BT-POLL on the bucket chains of BLOCK-TICKS (core/src/blockupd-29.cob; lane perfsteady). BT-ADD asked BT-HAS whether the tick was
*> pending by a pass over the whole table, on every schedule: with an ocean's worth of fluid ticks (tens of thousands, a few hundred scheduled in each tick) that was a pass of
*> 32768 rows several hundred times a tick. BT-HAS now walks the chain of the position's bucket, which BT-ADD and BT-POLL keep. This test applies 6000 random operations
*> (a schedule, with a small set of positions and ids so that duplicates and bucket neighbours are common, on both sides of zero; a poll of a random index; a reset of the
*> table by BT-COUNT 0 as the older tests do) and, after each one, compares BT-HAS with the pass over the table for a random identity (present or not), and at the end for
*> every entry of the table; it checks that a full table ignores a schedule, and bounds the cost of 30000 schedules into an empty table.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BT-HAS-EQUIV.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY BLOCKTICK.
 01 WS-SEED                BINARY-DOUBLE VALUE 777.
 01 WS-Q                   BINARY-DOUBLE.
 01 WS-OP                  BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-TRIG                BINARY-DOUBLE VALUE 100.
 01 WS-PRIO                BINARY-LONG VALUE 0.
 01 WS-SUB                 BINARY-LONG VALUE 0.
 01 WS-RESULT              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG VALUE 0.
 01 WS-CHECKS              BINARY-LONG VALUE 0.
 01 WS-ADDED               BINARY-LONG VALUE 0.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-US                  BINARY-DOUBLE.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE 0 TO BT-COUNT
     PERFORM VARYING WS-STEP FROM 1 BY 1 UNTIL WS-STEP > 6000
         PERFORM NEXT-RANDOM
         COMPUTE WS-OP = FUNCTION MOD(WS-Q, 100)
         EVALUATE TRUE
             WHEN WS-OP < 55
                 PERFORM RANDOM-IDENTITY
                 ADD 1 TO WS-SUB
                 CALL "BT-ADD" USING WS-DIM WS-TYPE WS-ID WS-X WS-Y WS-Z WS-TRIG WS-PRIO WS-SUB WS-RESULT
                 ADD WS-RESULT TO WS-ADDED
             WHEN WS-OP < 85
                 IF BT-COUNT > 0
                     PERFORM NEXT-RANDOM
                     COMPUTE WS-I = 1 + FUNCTION MOD(WS-Q, BT-COUNT)
                     CALL "BT-POLL" USING WS-I
                 END-IF
             WHEN WS-OP < 87
                 MOVE 0 TO BT-COUNT
             WHEN OTHER
                 CONTINUE
         END-EVALUATE
         PERFORM RANDOM-IDENTITY
         PERFORM SCAN-TABLE
         CALL "BT-HAS" USING WS-DIM WS-TYPE WS-ID WS-X WS-Y WS-Z WS-FOUND
         ADD 1 TO WS-CHECKS
         IF WS-FOUND NOT = WS-WANT
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "perfsteady: given 6000 random schedules, polls and resets when BT-HAS answers for a random identity then it answers as the pass over the table" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BT-COUNT
         CALL "BT-HAS" USING BT-T-DIM(WS-I) BT-T-TYPE(WS-I) BT-T-ID(WS-I) BT-T-X(WS-I) BT-T-Y(WS-I) BT-T-Z(WS-I) WS-FOUND
         IF WS-FOUND NOT = 1
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "perfsteady: given the table after the operations when BT-HAS asks for each of its entries then every one is found" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "perfsteady: the random operations scheduled a good number of ticks and left some pending" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ADDED > 1000 AND BT-COUNT > 20
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The table full: 32768 distinct ticks, then one more is ignored.
     MOVE 0 TO BT-COUNT
     CALL STATIC "clock" RETURNING WS-T0
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= 32768
         MOVE 1 TO WS-DIM
         MOVE 2 TO WS-TYPE
         MOVE 3 TO WS-ID
         COMPUTE WS-X = FUNCTION MOD(WS-I, 512) - 256
         COMPUTE WS-Z = FUNCTION MOD(WS-I / 512, 64) - 32
         MOVE 60 TO WS-Y
         ADD 1 TO WS-SUB
         CALL "BT-ADD" USING WS-DIM WS-TYPE WS-ID WS-X WS-Y WS-Z WS-TRIG WS-PRIO WS-SUB WS-RESULT
     END-PERFORM
     CALL STATIC "clock" RETURNING WS-T1
     COMPUTE WS-US = WS-T1 - WS-T0
     DISPLAY "PERF 32768 BT-ADD us " WS-US
     MOVE 5 TO WS-ID
     MOVE 1000 TO WS-X
     CALL "BT-ADD" USING WS-DIM WS-TYPE WS-ID WS-X WS-Y WS-Z WS-TRIG WS-PRIO WS-SUB WS-RESULT
     MOVE "perfsteady: given a full table of 32768 ticks when one more is scheduled then it is ignored and the table has 32768" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-RESULT * 100000 + BT-COUNT
     MOVE 32768 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "perfsteady: given 32768 schedules into an empty table when they are done then they took under 5 s of CPU (the pass over the table took minutes)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-US < 5000000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 NEXT-RANDOM.
     COMPUTE WS-SEED = FUNCTION MOD(WS-SEED * 1103515245 + 12345, 2147483648)
     DIVIDE WS-SEED BY 65536 GIVING WS-Q
     .
 RANDOM-IDENTITY.
     PERFORM NEXT-RANDOM
     COMPUTE WS-DIM = 1 + FUNCTION MOD(WS-Q, 2)
     PERFORM NEXT-RANDOM
     COMPUTE WS-TYPE = 1 + FUNCTION MOD(WS-Q, 2)
     PERFORM NEXT-RANDOM
     COMPUTE WS-ID = FUNCTION MOD(WS-Q, 3)
     PERFORM NEXT-RANDOM
     COMPUTE WS-X = FUNCTION MOD(WS-Q, 24) * 37 - 400
     PERFORM NEXT-RANDOM
     COMPUTE WS-Y = FUNCTION MOD(WS-Q, 5) * 3 - 60
     PERFORM NEXT-RANDOM
     COMPUTE WS-Z = FUNCTION MOD(WS-Q, 24) * 29 - 300
     .
 SCAN-TABLE.
     MOVE 0 TO WS-WANT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BT-COUNT
         IF BT-T-DIM(WS-I) = WS-DIM AND BT-T-TYPE(WS-I) = WS-TYPE AND BT-T-ID(WS-I) = WS-ID
                 AND BT-T-X(WS-I) = WS-X AND BT-T-Y(WS-I) = WS-Y AND BT-T-Z(WS-I) = WS-Z
             MOVE 1 TO WS-WANT
         END-IF
     END-PERFORM
     .
 END PROGRAM TEST-BT-HAS-EQUIV.
