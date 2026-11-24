*> Acceptance test, an occupied bed is not free (docs/protocol/19 section 22.8 "the bed is not occupied", 44 part 3 section 2.1 step 4; lane 002-lane-p49q, T37004): a villager at rest time does not claim a
*> bed whose occupied property is true (a player or another mob sleeps in it), and claims it once it is free.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-VILLAGER-BED-TAKEN.
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
 01 WS-HOME                BINARY-LONG VALUE 2.
 01 WS-QD                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "VT-FLAT" USING WS-PLAYER WS-FY
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-X = WS-X0 + 8
     MOVE "minecraft:red_bed" TO WS-KEY
     MOVE "facing=north,occupied=true,part=head" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z0 WS-KEY WS-PAIRS
     CALL "VT-SCAN" USING WS-DIM WS-X0 WS-Z0
     CALL "VT-SPAWN" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-V WS-S
     MOVE 13000 TO CW-TIME
     MOVE 1000 TO CW-TICKS
     PERFORM 150 TIMES
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-V
     END-PERFORM
     CALL "VPX-OF" USING EN-ID(WS-V) WS-HOME WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     MOVE "acceptance US15 19§22.8 a villager does not claim an occupied bed" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FOUND TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "facing=north,occupied=false,part=head" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z0 WS-KEY WS-PAIRS
     PERFORM 150 TIMES
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-V
     END-PERFORM
     CALL "VPX-OF" USING EN-ID(WS-V) WS-HOME WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     MOVE "acceptance US15 19§22.8 it claims the bed once it is free" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM ACC-US15-VILLAGER-BED-TAKEN.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
 COPY VILLTEST.
