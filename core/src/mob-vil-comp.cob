*> Two villagers and one job site (docs/protocol/44 part 3 sections 2.3 and 2.4; lane 002-lane-p49q, T37005). The claim table (VILPOI.cpy) holds the tickets of the job sites: the entries of two owners
*> at one position are what these behaviours settle.
*>   VL-COMPETE USING row, slot      PoiCompetitorScan (2.3): the villagers of nearest_living_entities (within 16 blocks, no visibility test: the gap of mob-vil-sense.cob) that hold the same job_site and
*>     whose profession takes that workstation (VIL-PROFESSION of the block) are folded together with this villager in list order (the entity table's): the accumulated villager stays only when its xp
*>     is strictly greater than the next one's, else the next wins; every loser's job_site is released. Run on the 20 to 39 tick brain beat (the document runs it every tick: the rule needs no
*>     timer, so it settles at the next beat).
*>   VL-YIELD USING row, slot        YieldJobSite (2.4): a villager that is not a baby, has no profession and holds a potential_job_site hands it to the first villager of nearest_living_entities
*>     that holds no potential_job_site, whose profession takes the workstation and that holds no job_site and can reach the site (VL-CAN-REACH, reach 1: the document's canReachPos) or holds
*>     this very site: this villager's claim and walk target are erased, the other gets the potential_job_site (the claim, VL-POT 1) and a walk target to it (speed s, closeness 1).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-COMPETE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VILPOI.
 01 WS-JOB                  BINARY-LONG VALUE 0.
 01 WS-QD                   BINARY-LONG.
 01 WS-QX                   BINARY-LONG.
 01 WS-QY                   BINARY-LONG.
 01 WS-QZ                   BINARY-LONG.
 01 WS-FOUND                BINARY-LONG.
 01 WS-KEY                  PIC X(32).
 01 WS-SITE-PROF            PIC X(16).
 01 WS-N                    BINARY-LONG.
 01 WS-I                    BINARY-LONG.
 01 WS-OSLOT                BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-ACC-ID               BINARY-LONG.
 01 WS-ACC-SLOT             BINARY-LONG.
 01 WS-HOLDS                BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     CALL "VPX-OF" USING EN-ID(L-ROW) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     IF WS-FOUND = 0
         GOBACK
     END-IF
     CALL "PXI-KEY-AT" USING WS-QD WS-QX WS-QY WS-QZ WS-KEY
     MOVE SPACES TO WS-SITE-PROF
     CALL "VIL-PROFESSION" USING WS-KEY WS-SITE-PROF
     IF WS-SITE-PROF = SPACES
         GOBACK
     END-IF
     MOVE EN-ID(L-ROW) TO WS-ACC-ID
     MOVE L-SLOT TO WS-ACC-SLOT
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
         IF WS-N NOT = L-ROW AND EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-HEALTH(WS-N) > 0 AND EN-DIM(WS-N) = EN-DIM(L-ROW)
             COMPUTE WS-D2 = (EN-X(WS-N) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-N) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-N) - EN-Z(L-ROW)) ** 2
             CALL "VL-FIND" USING EN-ID(WS-N) WS-NO WS-OSLOT
             IF WS-D2 <= 256 AND WS-OSLOT > 0
                 IF VL-KIND(WS-OSLOT) = 1 AND VL-PROF(WS-OSLOT) = WS-SITE-PROF
                     MOVE 0 TO WS-HOLDS
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PO-MAX
                         IF PO-OWNER(WS-I) = EN-ID(WS-N) AND PO-KIND(WS-I) = 0 AND PO-DIM(WS-I) = WS-QD
                                 AND PO-X(WS-I) = WS-QX AND PO-Y(WS-I) = WS-QY AND PO-Z(WS-I) = WS-QZ
                             MOVE 1 TO WS-HOLDS
                         END-IF
                     END-PERFORM
                     IF WS-HOLDS = 1
*>                       The fold: the accumulated villager stays only with strictly more xp, else the next one wins.
                         IF VL-XP(WS-ACC-SLOT) > VL-XP(WS-OSLOT)
                             CALL "VPX-RELEASE-KIND" USING EN-ID(WS-N) WS-JOB
                             MOVE 0 TO VL-POT(WS-OSLOT)
                         ELSE
                             CALL "VPX-RELEASE-KIND" USING WS-ACC-ID WS-JOB
                             MOVE 0 TO VL-POT(WS-ACC-SLOT)
                             MOVE EN-ID(WS-N) TO WS-ACC-ID
                             MOVE WS-OSLOT TO WS-ACC-SLOT
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VL-COMPETE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-YIELD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VLMEM.
 01 WS-JOB                  BINARY-LONG VALUE 0.
 01 WS-QD                   BINARY-LONG.
 01 WS-QX                   BINARY-LONG.
 01 WS-QY                   BINARY-LONG.
 01 WS-QZ                   BINARY-LONG.
 01 WS-FOUND                BINARY-LONG.
 01 WS-KEY                  PIC X(32).
 01 WS-SITE-PROF            PIC X(16).
 01 WS-N                    BINARY-LONG.
 01 WS-OSLOT                BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-WIN                  BINARY-LONG.
 01 WS-WSLOT                BINARY-LONG.
 01 WS-OD                   BINARY-LONG.
 01 WS-OX                   BINARY-LONG.
 01 WS-OY                   BINARY-LONG.
 01 WS-OZ                   BINARY-LONG.
 01 WS-HAS-JOB              BINARY-LONG.
 01 WS-OK                   BINARY-LONG.
 01 WS-REACH                BINARY-LONG VALUE 1.
 01 WS-ONE                  BINARY-LONG VALUE 1.
 01 WS-SPEED                FLOAT-LONG VALUE 1.0.
 01 WS-D2                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     IF VL-POT(L-SLOT) NOT = 1 OR VL-PROF(L-SLOT) NOT = "none" OR EN-MOBAGE(L-ROW) < 0
         GOBACK
     END-IF
     CALL "VPX-OF" USING EN-ID(L-ROW) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     IF WS-FOUND = 0
         GOBACK
     END-IF
     CALL "PXI-KEY-AT" USING WS-QD WS-QX WS-QY WS-QZ WS-KEY
     MOVE SPACES TO WS-SITE-PROF
     CALL "VIL-PROFESSION" USING WS-KEY WS-SITE-PROF
     IF WS-SITE-PROF = SPACES
         GOBACK
     END-IF
     MOVE 0 TO WS-WIN
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT OR WS-WIN > 0
         IF WS-N NOT = L-ROW AND EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-HEALTH(WS-N) > 0 AND EN-DIM(WS-N) = EN-DIM(L-ROW)
             COMPUTE WS-D2 = (EN-X(WS-N) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-N) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-N) - EN-Z(L-ROW)) ** 2
             CALL "VL-FIND" USING EN-ID(WS-N) WS-NO WS-OSLOT
             IF WS-D2 <= 256 AND WS-OSLOT > 0
                 IF VL-KIND(WS-OSLOT) = 1 AND VL-POT(WS-OSLOT) = 0 AND VL-PROF(WS-OSLOT) = WS-SITE-PROF
                     CALL "VPX-OF" USING EN-ID(WS-N) WS-JOB WS-OD WS-OX WS-OY WS-OZ WS-HAS-JOB
                     MOVE 0 TO WS-OK
                     IF WS-HAS-JOB = 0
                         CALL "VL-CAN-REACH" USING WS-N WS-QX WS-QY WS-QZ WS-REACH WS-OK
                     ELSE
                         IF WS-OD = WS-QD AND WS-OX = WS-QX AND WS-OY = WS-QY AND WS-OZ = WS-QZ
                             MOVE 1 TO WS-OK
                         END-IF
                     END-IF
                     IF WS-OK = 1
                         MOVE WS-N TO WS-WIN
                         MOVE WS-OSLOT TO WS-WSLOT
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-WIN = 0
         GOBACK
     END-IF
     CALL "VPX-RELEASE-KIND" USING EN-ID(L-ROW) WS-JOB
     MOVE 0 TO VL-POT(L-SLOT)
     CALL "VL-WALK-STOP" USING L-ROW L-SLOT
     IF WS-HAS-JOB = 0
         CALL "VP-CLAIM" USING WS-QD WS-QX WS-QY WS-QZ EN-ID(WS-WIN)
         MOVE 1 TO VL-POT(WS-WSLOT)
         MOVE 0 TO VM-T(WS-WSLOT, TM-POT-START)
         CALL "VL-WALK-SET" USING WS-WIN WS-WSLOT WS-QD WS-QX WS-QY WS-QZ WS-SPEED WS-ONE
     END-IF
     GOBACK.
 END PROGRAM VL-YIELD.
