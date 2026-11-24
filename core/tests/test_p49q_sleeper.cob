*> A settled sleeping villager is cheap (lane 002-lane-p49q, T37000; docs/protocol/19 section 22.8, 18 sections 2.5 and 3.2): a villager asleep in the rest activity that stands on solid ground, is not burning
*> and is not being pushed skips MOB-PHYSICS' full step and the entity environment tick on 4 ticks of 5; what the documents require stays: gravity when the ground under it goes (the support is checked every
*> tick), the fire count of a burning sleeper (every tick), and the hazards of its cell (fire, within the 5 ticks of the environment cadence). An awake villager gets the full step every tick.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-P49Q-SLEEPER.
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
 01 WS-XA                  BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-I                   BINARY-LONG.
 01 WS-Y0                  FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "VT-FLAT" USING WS-PLAYER WS-FY
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-XA = WS-X0 + 6
     CALL "VT-SPAWN" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-V WS-S
     CALL "VT-SPAWN" USING WS-DIM WS-XA WS-Y WS-Z0 WS-W WS-T
     MOVE 13000 TO CW-TIME
     MOVE 1000 TO CW-TICKS
     PERFORM 6 TIMES
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-V
     END-PERFORM
     MOVE 1 TO VL-SLEEP(WS-S)
*>   A tick that is not on the environment cadence (the tick count plus the entity id is not a multiple of 5).
     PERFORM UNTIL FUNCTION MOD(CW-TICKS + 1 + EN-ID(WS-V), 5) NOT = 0
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-V
     END-PERFORM
     MOVE -0.05 TO EN-VY(WS-V)
     MOVE 0 TO EN-BURN(WS-V)
     ADD 1 TO CW-TICKS
     CALL "STDMOB-STEP" USING WS-V
     MOVE "test p49q a settled sleeper does not run the physics step (its vertical speed is left alone)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-VY(WS-V) = -0.05
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "test p49q the sleeper stays asleep, on the ground, where it was" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF VL-SLEEP(WS-S) = 1 AND EN-ON-GROUND(WS-V) = 1 AND EN-Y(WS-V) = WS-Y
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   An awake villager (the other one, in the same rest time but not asleep) gets the whole step: gravity sets the vertical speed.
     MOVE 0 TO VL-SLEEP(WS-T)
     MOVE 0 TO EN-VY(WS-W)
     MOVE 2500 TO CW-TIME
     ADD 1 TO CW-TICKS
     CALL "STDMOB-STEP" USING WS-W
     MOVE "test p49q an awake villager gets the physics step every tick" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-VY(WS-W) < 0
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE 13000 TO CW-TIME
*>   Gravity: the ground under the sleeper goes, it falls (the support check runs every tick).
     MOVE EN-Y(WS-V) TO WS-Y0
     MOVE "minecraft:air" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X0 WS-FY WS-Z0 WS-KEY WS-PAIRS
     PERFORM 3 TIMES
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-V
     END-PERFORM
     MOVE "test p49q when the ground under a sleeper goes it falls" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-Y(WS-V) < WS-Y0 AND EN-ON-GROUND(WS-V) = 0
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A burning sleeper's fire count goes down every tick.
     MOVE 100 TO EN-BURN(WS-W)
     MOVE 1 TO VL-SLEEP(WS-T)
     PERFORM 3 TIMES
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-W
     END-PERFORM
     MOVE "test p49q a burning sleeper's fire count falls by one a tick (the environment tick runs)" TO WS-CASE
     MOVE 97 TO WS-E
     MOVE EN-BURN(WS-W) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   Fire in the cell of a sleeper sets it alight within the 5 ticks of the cadence.
     MOVE 0 TO EN-BURN(WS-W)
     MOVE "minecraft:fire" TO WS-KEY
     CALL "VT-PLACE" USING WS-DIM WS-XA WS-Y WS-Z0 WS-KEY WS-PAIRS
     PERFORM 5 TIMES
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-W
     END-PERFORM
     MOVE "test p49q fire in the cell of a sleeper sets it alight within 5 ticks" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-BURN(WS-W) > 0
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-P49Q-SLEEPER.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
 COPY VILLTEST.
