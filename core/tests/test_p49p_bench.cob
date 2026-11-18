*> Benchmark of the villager brain (lane 002-lane-p49p; docs/protocol/44 part 3 and 19 section 22.3): 40 villagers in a village (40 beds, 40 lecterns, one bell) on a flat stone floor, the POI index of the chunks round it filled, take STDMOB-STEP
*> (the brain, the walk and the physics of a villager) for 150 ticks at the work, meet and rest times. The CPU time per villager tick is shown (DISPLAY "BENCH ...", microseconds, the C clock) and
*> must stay below a generous bound, so that a per villager cost that grows with the village is noticed.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-P49P-BENCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-N                   BINARY-LONG VALUE 40.
 01 WS-ROWS.
    05 WS-ROW              BINARY-LONG OCCURS 40 TIMES.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-CLOCK0              BINARY-DOUBLE.
 01 WS-CLOCK1              BINARY-DOUBLE.
 01 WS-US                  FLOAT-LONG.
 01 WS-US-TEXT             PIC -(7)9.99.
 01 WS-TOTAL               BINARY-DOUBLE.
 01 WS-PHASE               BINARY-LONG.
 01 WS-PHASE-TIME-DATA.
    05 FILLER              BINARY-LONG VALUE 3000.
    05 FILLER              BINARY-LONG VALUE 9500.
    05 FILLER              BINARY-LONG VALUE 13000.
 01 WS-PHASE-TIMES REDEFINES WS-PHASE-TIME-DATA.
    05 WS-PHASE-TIME       BINARY-LONG OCCURS 3 TIMES.
 01 WS-LABEL-DATA.
    05 FILLER              PIC X(5) VALUE "work".
    05 FILLER              PIC X(5) VALUE "meet".
    05 FILLER              PIC X(5) VALUE "rest".
 01 WS-LABELS REDEFINES WS-LABEL-DATA.
    05 WS-LABEL            PIC X(5) OCCURS 3 TIMES.
 01 WS-BOUND               BINARY-LONG VALUE 5000.
 01 WS-MEAN                BINARY-LONG.
 01 WS-REPEAT-TEXT         PIC X(8).
 01 WS-REPEAT              BINARY-LONG VALUE 1.
 01 WS-TICKS               BINARY-LONG.
 01 WS-ASLEEP              BINARY-LONG.
 01 WS-WALKING             BINARY-LONG.
 01 WS-SL                  BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-FIRST-TEXT          PIC X(8).
 01 WS-FIRST               BINARY-LONG VALUE 1.
 01 WS-LAST                BINARY-LONG VALUE 3.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   P49P_BENCH_REPEAT (default 1) lengthens the measured part, for a profiler.
     ACCEPT WS-REPEAT-TEXT FROM ENVIRONMENT "P49P_BENCH_REPEAT"
     IF WS-REPEAT-TEXT NOT = SPACES
         COMPUTE WS-REPEAT = FUNCTION NUMVAL(WS-REPEAT-TEXT)
     END-IF
     ACCEPT WS-FIRST-TEXT FROM ENVIRONMENT "P49P_BENCH_PHASE"
     IF WS-FIRST-TEXT NOT = SPACES
         COMPUTE WS-FIRST = FUNCTION NUMVAL(WS-FIRST-TEXT)
         MOVE WS-FIRST TO WS-LAST
     END-IF
     COMPUTE WS-TICKS = 150 * WS-REPEAT
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "VT-FLAT" USING WS-PLAYER WS-FY
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-Y = WS-FY + 1
     MOVE SPACES TO WS-PAIRS
     MOVE "minecraft:bell" TO WS-KEY
     CALL "VT-PLACE" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-KEY WS-PAIRS
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-N
         COMPUTE WS-X = WS-X0 - 20 + FUNCTION MOD(WS-I, 20) * 2
         COMPUTE WS-Z = WS-Z0 + 10 + FUNCTION INTEGER(WS-I / 20) * 3
         MOVE "minecraft:red_bed" TO WS-KEY
         MOVE "facing=north,occupied=false,part=head" TO WS-PAIRS
         CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z WS-KEY WS-PAIRS
         COMPUTE WS-Z = WS-Z0 - 10 - FUNCTION INTEGER(WS-I / 20) * 3
         MOVE "minecraft:lectern" TO WS-KEY
         MOVE SPACES TO WS-PAIRS
         CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z WS-KEY WS-PAIRS
     END-PERFORM
*>   The POI index of the chunks round the village is filled first, so that the one-off fill (one chunk section of 4096 blocks per call) is not counted in the cost of a villager tick.
     CALL "VT-SCAN" USING WS-DIM WS-X0 WS-Z0
     PERFORM VARYING WS-I FROM -3 BY 1 UNTIL WS-I > 3
         PERFORM VARYING WS-T FROM -3 BY 1 UNTIL WS-T > 3
             COMPUTE WS-X = WS-X0 + WS-I * 16
             COMPUTE WS-Z = WS-Z0 + WS-T * 16
             CALL "VT-SCAN-KEEP" USING WS-DIM WS-X WS-Z
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         COMPUTE WS-X = WS-X0 - 20 + FUNCTION MOD((WS-I - 1) * 7, 41)
         COMPUTE WS-Z = WS-Z0 - 10 + FUNCTION MOD((WS-I - 1) * 11, 21)
         CALL "VT-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ROW(WS-I) WS-SLOT
     END-PERFORM
     MOVE 0 TO WS-TOTAL
     PERFORM VARYING WS-PHASE FROM WS-FIRST BY 1 UNTIL WS-PHASE > WS-LAST
         CALL "VT-DAY" USING WS-PHASE-TIME(WS-PHASE)
         PERFORM 60 TIMES
             PERFORM TICK-ALL
         END-PERFORM
         CALL STATIC "clock" RETURNING WS-CLOCK0
         PERFORM WS-TICKS TIMES
             PERFORM TICK-ALL
         END-PERFORM
         CALL STATIC "clock" RETURNING WS-CLOCK1
         MOVE 0 TO WS-ASLEEP WS-WALKING
         PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > WS-N
             CALL "VL-FIND" USING EN-ID(WS-ROW(WS-T)) WS-NO WS-SL
             IF VL-SLEEP(WS-SL) = 1
                 ADD 1 TO WS-ASLEEP
             END-IF
             IF EN-COOLDOWN(WS-ROW(WS-T)) > 0
                 ADD 1 TO WS-WALKING
             END-IF
         END-PERFORM
         DISPLAY "BENCH state at the end of the phase: asleep " WS-ASLEEP " walking " WS-WALKING
         COMPUTE WS-US = (WS-CLOCK1 - WS-CLOCK0) / (WS-TICKS * WS-N)
         MOVE WS-US TO WS-US-TEXT
         DISPLAY "BENCH villager step us per villager tick (" WS-LABEL(WS-PHASE) ", 40 villagers): " WS-US-TEXT
         COMPUTE WS-TOTAL = WS-TOTAL + WS-US
     END-PERFORM
     COMPUTE WS-MEAN = WS-TOTAL / (WS-LAST - WS-FIRST + 1)
     MOVE "test p49p bench: a villager tick costs less than 5 ms of CPU in a village" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MEAN < WS-BOUND
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 TICK-ALL.
     ADD 1 TO CW-TICKS
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > WS-N
         CALL "STDMOB-STEP" USING WS-ROW(WS-T)
     END-PERFORM.
 END PROGRAM TEST-P49P-BENCH.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY VILLTEST.
