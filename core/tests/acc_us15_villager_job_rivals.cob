*> Acceptance test, two villagers and one job site (docs/protocol/44 part 3 sections 2.3 and 2.4; lane 002-lane-p49q, T37005): PoiCompetitorScan: of the villagers that hold the same job_site and whose
*> profession takes that workstation, the one with the most villager xp keeps it (the fold of 2.3: the accumulated villager stays only when its xp is strictly greater than the next one's, so on equal xp the
*> later one in the list wins) and every other has its job_site erased. YieldJobSite: a villager without a profession whose potential_job_site is a workstation yields it to another villager of the matching
*> profession that has no potential_job_site and no job_site and can reach it: it loses the claim and its walk target, the other gets the potential_job_site and a walk target to it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-VILLAGER-JOB-RIVALS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VILPOI.
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
 01 WS-LX                  BINARY-LONG.
 01 WS-XB                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-SA                  BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-SB                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-JOB                 BINARY-LONG VALUE 0.
 01 WS-QD                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-FOUND-A             BINARY-LONG.
 01 WS-FOUND-B             BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-N1                  BINARY-LONG.
 01 WS-N2                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "VT-FLAT" USING WS-PLAYER WS-FY
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-LX = WS-X0 + 8
     COMPUTE WS-XB = WS-X0 + 4
     MOVE "minecraft:lectern" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-LX WS-Y WS-Z0 WS-KEY WS-PAIRS
     CALL "VT-SCAN" USING WS-DIM WS-X0 WS-Z0
     CALL "VT-SPAWN" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-A WS-SA
     CALL "VT-SPAWN" USING WS-DIM WS-XB WS-Y WS-Z0 WS-B WS-SB
     MOVE 5000 TO CW-TIME
     MOVE 1000 TO CW-TICKS
*>   YieldJobSite: A (no profession) holds the lectern as its potential job site, B is a librarian with nothing.
     CALL "VP-CLAIM" USING WS-DIM WS-LX WS-Y WS-Z0 EN-ID(WS-A)
     MOVE 1 TO VL-POT(WS-SA)
     MOVE "librarian" TO VL-PROF(WS-SB)
     CALL "VL-YIELD" USING WS-A WS-SA
     CALL "VPX-OF" USING EN-ID(WS-A) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND-A
     CALL "VPX-OF" USING EN-ID(WS-B) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND-B
     MOVE "acceptance US15 44-3§2.4 the villager without a profession yields the site: it holds no claim" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FOUND-A TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§2.4 the librarian holds it (potential job site)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FOUND-B TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§2.4 and walks to it" TO WS-CASE
     MOVE 1 TO WS-E
     CALL "VM-HAS" USING WS-SB MT-WALK-TARGET WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A yields to nobody when the other has a potential job site of its own.
     CALL "VPX-RELEASE-KIND" USING EN-ID(WS-B) WS-JOB
     CALL "VP-CLAIM" USING WS-DIM WS-LX WS-Y WS-Z0 EN-ID(WS-A)
     MOVE 1 TO VL-POT(WS-SA)
     MOVE 1 TO VL-POT(WS-SB)
     CALL "VL-YIELD" USING WS-A WS-SA
     CALL "VPX-OF" USING EN-ID(WS-A) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND-A
     MOVE "acceptance US15 44-3§2.4 a villager that already has a potential job site is not given another" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FOUND-A TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   Nor when the other's profession does not take a lectern.
     MOVE 0 TO VL-POT(WS-SB)
     MOVE "farmer" TO VL-PROF(WS-SB)
     CALL "VL-YIELD" USING WS-A WS-SA
     CALL "VPX-OF" USING EN-ID(WS-A) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND-A
     MOVE "acceptance US15 44-3§2.4 a farmer does not want a lectern" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FOUND-A TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   PoiCompetitorScan: both librarians hold the lectern; A has 10 xp, B 50: B keeps it.
     CALL "VPX-RELEASE-KIND" USING EN-ID(WS-A) WS-JOB
     MOVE 0 TO VL-POT(WS-SA)
     MOVE "librarian" TO VL-PROF(WS-SA)
     MOVE "librarian" TO VL-PROF(WS-SB)
     MOVE 10 TO VL-XP(WS-SA)
     MOVE 50 TO VL-XP(WS-SB)
     CALL "VP-CLAIM" USING WS-DIM WS-LX WS-Y WS-Z0 EN-ID(WS-A)
     CALL "VP-CLAIM" USING WS-DIM WS-LX WS-Y WS-Z0 EN-ID(WS-B)
     CALL "VL-COMPETE" USING WS-A WS-SA
     CALL "VPX-OF" USING EN-ID(WS-A) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND-A
     CALL "VPX-OF" USING EN-ID(WS-B) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND-B
     MOVE "acceptance US15 44-3§2.3 the villager with less xp loses its job_site" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-FOUND-A TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§2.3 the one with more xp keeps it" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-FOUND-B TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   More xp for the scanning villager: the other one loses.
     CALL "VPX-RELEASE-KIND" USING EN-ID(WS-B) WS-JOB
     MOVE 90 TO VL-XP(WS-SA)
     CALL "VP-CLAIM" USING WS-DIM WS-LX WS-Y WS-Z0 EN-ID(WS-A)
     CALL "VP-CLAIM" USING WS-DIM WS-LX WS-Y WS-Z0 EN-ID(WS-B)
     CALL "VL-COMPETE" USING WS-A WS-SA
     CALL "VPX-OF" USING EN-ID(WS-A) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND-A
     CALL "VPX-OF" USING EN-ID(WS-B) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND-B
     MOVE "acceptance US15 44-3§2.3 the scanning villager with more xp keeps the site and the other loses it" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = WS-FOUND-A * (1 - WS-FOUND-B)
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   Equal xp: the later villager of the list wins (the fold keeps the accumulated one only when strictly greater).
     CALL "VPX-RELEASE-KIND" USING EN-ID(WS-A) WS-JOB
     CALL "VPX-RELEASE-KIND" USING EN-ID(WS-B) WS-JOB
     MOVE 50 TO VL-XP(WS-SA)
     CALL "VP-CLAIM" USING WS-DIM WS-LX WS-Y WS-Z0 EN-ID(WS-A)
     CALL "VP-CLAIM" USING WS-DIM WS-LX WS-Y WS-Z0 EN-ID(WS-B)
     CALL "VL-COMPETE" USING WS-A WS-SA
     CALL "VPX-OF" USING EN-ID(WS-A) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND-A
     CALL "VPX-OF" USING EN-ID(WS-B) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND-B
     MOVE "acceptance US15 44-3§2.3 on equal xp the later villager (B, after A) wins" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = WS-FOUND-B * (1 - WS-FOUND-A)
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM ACC-US15-VILLAGER-JOB-RIVALS.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
 COPY VILLTEST.
