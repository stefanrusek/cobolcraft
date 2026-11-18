*> Test of 44 part 3 sections 2.2 and 2.9 as wired into the villager brain (VL-BRAIN, lane 002-lane-p49h, T22008): ValidateNearbyPoi leaves the memory alone while the villager is farther
*> than 16 blocks from the point of interest (a claim whose block is gone is released only once the villager is within 16), and WakeUp stops sleeping when REST is not the activity.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-3-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-JOB                 BINARY-LONG VALUE 0.
 01 WS-HOME                BINARY-LONG.
 01 WS-QD                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "minecraft:villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 0.5
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 0.5
     CALL "MOB-SPAWN" USING PL-DIM(WS-PLAYER) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "VL-FIND" USING EN-ID(WS-ROW) WS-NO WS-SLOT
     MOVE 16001 TO CW-TIME
     MOVE 1000 TO CW-TICKS
*>   A job site claim on a block that is no job site, 30 blocks away: the villager is beyond 16 blocks, the memory is kept.
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X) + 30
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     CALL "VPX-CLAIM" USING EN-ID(WS-ROW) WS-JOB PL-DIM(WS-PLAYER) WS-BX WS-BY WS-BZ
     MOVE 0 TO VL-NEXT-BRAIN(WS-SLOT)
     CALL "VL-BRAIN" USING WS-ROW
     CALL "VPX-OF" USING EN-ID(WS-ROW) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     MOVE "acceptance US15 44-3§2.2 a claim whose block is gone is kept while the villager is 30 blocks away" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FOUND TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   The same claim 5 blocks away is released.
     MOVE WS-QX TO WS-BX
     COMPUTE WS-X = WS-BX - 5 + 0.5
     MOVE WS-X TO EN-X(WS-ROW)
     MOVE 0 TO VL-NEXT-BRAIN(WS-SLOT)
     CALL "VL-BRAIN" USING WS-ROW
     CALL "VPX-OF" USING EN-ID(WS-ROW) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     MOVE "acceptance US15 44-3§2.2 within 16 blocks of the vanished block the claim is released" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FOUND TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A home claim on a block that is no bed head is released too (the home rule only differs for an occupied bed).
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(WS-ROW)) + 3
     MOVE 2 TO WS-HOME
     CALL "VPX-CLAIM" USING EN-ID(WS-ROW) WS-HOME PL-DIM(WS-PLAYER) WS-BX WS-BY WS-BZ
     MOVE 0 TO VL-NEXT-BRAIN(WS-SLOT)
     CALL "VL-BRAIN" USING WS-ROW
     CALL "VPX-OF" USING EN-ID(WS-ROW) WS-HOME WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     MOVE "acceptance US15 44-3§2.2 a home claim on a block that is no bed is released" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FOUND TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   WakeUp: sleeping at midday (not REST) stops.
     MOVE 1 TO VL-SLEEP(WS-SLOT)
     MOVE 6000 TO CW-TIME
     MOVE 0 TO VL-NEXT-BRAIN(WS-SLOT)
     CALL "VL-BRAIN" USING WS-ROW
     MOVE "acceptance US15 44-3§2.9 a sleeping villager wakes when the activity is not REST" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE VL-SLEEP(WS-SLOT) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-Q44-44-3-8.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
