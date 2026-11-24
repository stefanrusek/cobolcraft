*> Acceptance test, a villager takes a bed farther than the 15 blocks its path search reaches (operator bug "villagers can't path find to their beds", try16; docs/protocol/44 part 3
*> sections 2.1 step 6 and 2.17: the home walk target has tooFar 150, the POI search radius is 48; lane 002-lane-bugvlbed, T58401): a bed 22 blocks from a villager on open ground. At night
*> the villager claims it, walks to it and sleeps within reach of it; the bed is occupied.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGVLBED-FAR.
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
 01 WS-I                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-OCC                 BINARY-LONG.
 01 WS-HX                  BINARY-LONG.
 01 WS-HY                  BINARY-LONG.
 01 WS-HZ                  BINARY-LONG.
 01 WS-HD                  BINARY-LONG.
 01 WS-HF                  BINARY-LONG.
 01 WS-HOME                BINARY-LONG VALUE 2.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "VT-FLAT" USING WS-PLAYER WS-FY
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-X = WS-X0 + 22
     MOVE "minecraft:red_bed" TO WS-KEY
     MOVE "facing=north,occupied=false,part=head" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z0 WS-KEY WS-PAIRS
     CALL "VT-SCAN" USING WS-DIM WS-X0 WS-Z0
     CALL "VT-SCAN-KEEP" USING WS-DIM WS-X WS-Z0
     CALL "VT-SPAWN" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-V WS-S
     MOVE 13000 TO CW-TIME
     MOVE 1000 TO CW-TICKS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2500 OR VL-SLEEP(WS-S) = 1
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-V
     END-PERFORM
     MOVE "acceptance US15 44-3§2.1 the villager claimed the bed 22 blocks away" TO WS-CASE
     MOVE 1 TO WS-E
     CALL "VPX-OF" USING EN-ID(WS-V) WS-HOME WS-HD WS-HX WS-HY WS-HZ WS-HF
     MOVE WS-HF TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 19§22.8 the villager went to sleep" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE VL-SLEEP(WS-S) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     COMPUTE WS-DX = FUNCTION INTEGER(EN-X(WS-V)) - WS-X
     MOVE "acceptance US15 19§22.8 it sleeps within 2 blocks of the bed" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-DX >= -2 AND WS-DX <= 2
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 19§22.8 the bed is occupied" TO WS-CASE
     MOVE 1 TO WS-E
     CALL "VL-BED-IS-OCCUPIED" USING WS-DIM WS-X WS-Y WS-Z0 WS-OCC
     MOVE WS-OCC TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM ACC-BUGVLBED-FAR.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
 COPY VILLTEST.
