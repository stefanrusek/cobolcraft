*> Acceptance test, AcquirePoi checks that a path reaches the point of interest (docs/protocol/44 part 3 section 2.1 steps 5 to 7; lane 002-lane-p49p, T35008): a villager shut in by walls cannot
*> reach the bed that is 10 blocks away, so it does not claim it and its home acquisition waits 40 to 79 ticks (JitteredLinearRetry); once the walls are gone it claims the bed only after that
*> wait; a second failure waits longer (the delay grows by 40 to 79 up to 400).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-VILLAGER-ACQUIRE.
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
 01 WS-Z                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-QD                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-HOME                BINARY-LONG VALUE 2.
 01 WS-FIRST               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "VT-FLAT" USING WS-PLAYER WS-FY
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-X = WS-X0 + 10
     MOVE "minecraft:red_bed" TO WS-KEY
     MOVE "facing=north,occupied=false,part=head" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z0 WS-KEY WS-PAIRS
     MOVE "minecraft:stone" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     PERFORM VARYING WS-DX FROM -2 BY 1 UNTIL WS-DX > 2
         PERFORM VARYING WS-DZ FROM -2 BY 1 UNTIL WS-DZ > 2
             IF WS-DX = -2 OR WS-DX = 2 OR WS-DZ = -2 OR WS-DZ = 2
                 PERFORM VARYING WS-H FROM 0 BY 1 UNTIL WS-H > 2
                     COMPUTE WS-X = WS-X0 + WS-DX
                     COMPUTE WS-Z = WS-Z0 + WS-DZ
                     COMPUTE WS-QY = WS-Y + WS-H
                     CALL "VT-PLACE" USING WS-DIM WS-X WS-QY WS-Z WS-KEY WS-PAIRS
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     CALL "VT-SCAN" USING WS-DIM WS-X0 WS-Z0
     CALL "VT-SPAWN" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-V WS-S
     MOVE 3000 TO CW-TIME
     MOVE 1000 TO CW-TICKS
     CALL "VL-BRAIN" USING WS-V
     CALL "VPX-OF" USING EN-ID(WS-V) WS-HOME WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     MOVE "acceptance US15 44-3§2.1 a villager shut in by walls does not claim the bed it cannot reach" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FOUND TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE VM-T(WS-S, TM-ACQ-HOME) TO WS-FIRST
     MOVE "acceptance US15 44-3§2.1 the failure delays the acquisition by 40 to 79 ticks" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-FIRST >= 1040 AND WS-FIRST <= 1079
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   The walls go: within the delay the bed is still not claimed, after it the villager claims it.
     PERFORM VARYING WS-DX FROM -2 BY 1 UNTIL WS-DX > 2
         PERFORM VARYING WS-DZ FROM -2 BY 1 UNTIL WS-DZ > 2
             IF WS-DX = -2 OR WS-DX = 2 OR WS-DZ = -2 OR WS-DZ = 2
                 PERFORM VARYING WS-H FROM 0 BY 1 UNTIL WS-H > 2
                     COMPUTE WS-X = WS-X0 + WS-DX
                     COMPUTE WS-Z = WS-Z0 + WS-DZ
                     COMPUTE WS-QY = WS-Y + WS-H
                     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-QY WS-Z WS-AIR
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 1030 TO CW-TICKS
     MOVE 0 TO VL-NEXT-BRAIN(WS-S)
     CALL "VL-BRAIN" USING WS-V
     CALL "VPX-OF" USING EN-ID(WS-V) WS-HOME WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     MOVE "acceptance US15 44-3§2.1 while the delay runs the villager does not try again" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FOUND TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE 1080 TO CW-TICKS
     MOVE 0 TO VL-NEXT-BRAIN(WS-S)
     CALL "VL-BRAIN" USING WS-V
     CALL "VPX-OF" USING EN-ID(WS-V) WS-HOME WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     MOVE "acceptance US15 44-3§2.1 after the delay, with a way to the bed, the villager claims it" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§2.1 and the retry delay is cleared" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE VM-T(WS-S, TM-ACQ-DELAY-HOME) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM ACC-US15-VILLAGER-ACQUIRE.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
 COPY VILLTEST.
