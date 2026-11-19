*> Acceptance test, a baby jumps on a bed (docs/protocol/44 part 3 section 2.9 JumpOnBed, 19 section 22.3; lane 002-lane-p49q, T37007): a baby villager in the play activity with a nearest_bed and no other
*> baby in sight walks to the bed (walk_target closeness 0) and, standing on it, jumps 3 to 6 times with 5 ticks between the jumps (the jump is a vertical speed of 0.42, 18 section 3.2), then stops. A
*> baby that is not on or over a bed counts its 100 tick walking budget down and gives up. An adult never jumps.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-VILLAGER-JUMP.
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
 01 WS-K                   BINARY-LONG.
 01 WS-SK                  BINARY-LONG.
 01 WS-AD                  BINARY-LONG.
 01 WS-SAD                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-MAX-K               FLOAT-LONG.
 01 WS-MAX-AD              FLOAT-LONG.
 01 WS-TOP                 FLOAT-LONG.
 01 WS-JUMPS               BINARY-LONG.
 01 WS-WAS-UP              BINARY-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "VT-FLAT" USING WS-PLAYER WS-FY
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 6
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-X = WS-X0 + 5
     MOVE "minecraft:red_bed" TO WS-KEY
     MOVE "facing=north,occupied=false,part=head" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z0 WS-KEY WS-PAIRS
     CALL "VT-SCAN" USING WS-DIM WS-X0 WS-Z0
     CALL "VT-SPAWN" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-K WS-SK
     COMPUTE WS-X = WS-X0 - 5
     CALL "VT-SPAWN" USING WS-DIM WS-X WS-Y WS-Z0 WS-AD WS-SAD
     MOVE -24000 TO EN-MOBAGE(WS-K)
     MOVE 5000 TO CW-TIME
     MOVE 1000 TO CW-TICKS
     MOVE 0 TO WS-MAX-K WS-MAX-AD WS-JUMPS WS-WAS-UP
     COMPUTE WS-TOP = WS-FY + 2
     COMPUTE WS-LIMIT = WS-FY + 3.0
     PERFORM 600 TIMES
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-K
         CALL "STDMOB-STEP" USING WS-AD
         IF EN-Y(WS-K) > WS-MAX-K
             MOVE EN-Y(WS-K) TO WS-MAX-K
         END-IF
         IF EN-Y(WS-AD) > WS-MAX-AD
             MOVE EN-Y(WS-AD) TO WS-MAX-AD
         END-IF
*>       Count the jumps: leaving the bed top upwards (feet more than 0.3 above the top while within 1.5 blocks of the bed).
         IF EN-Y(WS-K) > WS-TOP + 0.3 AND FUNCTION ABS(EN-X(WS-K) - (WS-X0 + 5.5)) < 1.5
             IF WS-WAS-UP = 0
                 ADD 1 TO WS-JUMPS
             END-IF
             MOVE 1 TO WS-WAS-UP
         ELSE
             MOVE 0 TO WS-WAS-UP
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-3§2.9 the baby jumped on the bed (its feet rose more than 1 above the bed top)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-MAX-K > WS-LIMIT
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§2.9 it jumped 3 to 6 times" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-JUMPS >= 3 AND WS-JUMPS <= 6
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§2.9 the adult never jumps" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-MAX-AD < WS-FY + 2.1
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM ACC-US15-VILLAGER-JUMP.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
 COPY VILLTEST.
