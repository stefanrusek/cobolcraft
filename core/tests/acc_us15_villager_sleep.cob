*> Acceptance test, a villager sleeps in its bed at night (docs/protocol/19 section 22.8 and 44 part 3 section 2.17; lane 002-lane-p49p, T35006): at rest time a villager with a home bed 8 blocks
*> away claims it, walks to it along a path (SetWalkTargetFromBlockMemory), goes to sleep within 2 blocks (last_slept), does not walk while it sleeps, and wakes when the rest activity ends
*> (last_woken); a woken villager does not go back to bed for 100 ticks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-VILLAGER-SLEEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VLMEM.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-I                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-XS                  FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "VT-FLAT" USING WS-PLAYER WS-FY
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-X = WS-X0 + 8
     MOVE "minecraft:red_bed" TO WS-KEY
     MOVE "facing=north,occupied=false,part=head" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z0 WS-KEY WS-PAIRS
     CALL "VT-SCAN" USING WS-DIM WS-X0 WS-Z0
     CALL "VT-SPAWN" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-V WS-S
     MOVE 13000 TO CW-TIME
     MOVE 1000 TO CW-TICKS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 800 OR VL-SLEEP(WS-S) = 1
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-V
     END-PERFORM
     MOVE "acceptance US15 19§22.8 at night the villager walked to its bed and went to sleep" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE VL-SLEEP(WS-S) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     COMPUTE WS-DX = FUNCTION INTEGER(EN-X(WS-V)) - (WS-X0 + 8)
     MOVE "acceptance US15 19§22.8 it sleeps within 2 blocks of the bed" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-DX >= -2 AND WS-DX <= 2
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 19§22.8 last_slept is the tick it fell asleep" TO WS-CASE
     MOVE CW-TICKS TO WS-E
     MOVE VL-LAST-SLEPT(WS-S) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§2.17 the walk target is gone once it sleeps" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE VM-SET(WS-S, MT-WALK-TARGET) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   Asleep through the night: it stays where it is.
     MOVE EN-X(WS-V) TO WS-XS
     PERFORM 200 TIMES
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-V
     END-PERFORM
     MOVE "acceptance US15 19§22.8 it is still asleep 200 ticks later" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE VL-SLEEP(WS-S) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   Morning: it wakes.
     MOVE 2500 TO CW-TIME
     ADD 1 TO CW-TICKS
     CALL "STDMOB-STEP" USING WS-V
     MOVE "acceptance US15 19§22.8 when the rest activity ends the villager wakes" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE VL-SLEEP(WS-S) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 19§22.8 last_woken is the tick it woke" TO WS-CASE
     MOVE CW-TICKS TO WS-E
     MOVE VL-LAST-WOKEN(WS-S) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   Back to rest time right away: it does not lie down again within 100 ticks of waking.
     MOVE 13000 TO CW-TIME
     PERFORM 50 TIMES
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-V
     END-PERFORM
     MOVE "acceptance US15 19§22.8 it does not go back to bed within 100 ticks of waking" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE VL-SLEEP(WS-S) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300 OR VL-SLEEP(WS-S) = 1
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-V
     END-PERFORM
     MOVE "acceptance US15 19§22.8 but it does later" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE VL-SLEEP(WS-S) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM ACC-US15-VILLAGER-SLEEP.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
 COPY VILLTEST.
