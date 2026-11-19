*> The villager schedule and point of interest claims (docs/protocol/19 sections 22.3, 22.6 to 22.8; lane 002-lane-mobsb3, T8106). The state is VILSTATE.cpy (VL-NEXT-BRAIN, VL-SLEEP,
*> VL-LAST-SLEPT, VL-LAST-WOKEN, VL-POT), the claims VILPOI.cpy and the index VILPOIX.cpy. The brain is a simplified one: the activity of the day tick (VIL-DAY-ACT) and, every 20 to 39
*> ticks, AcquirePoi (home bed of any villager, meeting bell and job site of adults, nearest free point within 48 blocks of the index), ValidateNearbyPoi (a claim on a vanished block is
*> released), AssignProfessionFromJobSite (within 2 blocks of the claimed workstation), ResetProfession (no job site, no xp, level 1 or less) and the walk to the point of the activity by the
*> stroll fields (EN-DEST-X, EN-DEST-Z, EN-COOLDOWN; straight line, no path finding): work to the job site (beyond 3 blocks), meet to the bell (beyond 6), rest to the bed (beyond 2); within 2
*> blocks of its bed at rest time it sleeps (VL-SLEEP, VL-LAST-SLEPT) unless it woke within 100 ticks, and wakes when the activity is not rest (VL-LAST-WOKEN). Gaps: no sleeping pose or bed
*> position metadata, a sleeping villager still strolls, no door handling, no panic, no hiding, no YieldJobSite or PoiCompetitorScan (a claimed site is simply not offered again), the
*> workstation of a villager keeps its profession for a villager with xp, secondary job sites, bed occupancy by players.
*>
*>   VIL-DAY-ACT USING day tick, baby (0/1), activity out    0 idle, 1 work, 2 meet, 3 rest, 4 play
*>   PXI-KEY-AT USING dim, x, y, z, key out (X(32))           the block key without namespace at a position
*>   VL-BRAIN USING entity row                                one tick of the brain of a villager (VL-STEP)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIL-DAY-ACT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DAY                   BINARY-LONG.
 01 L-BABY                  BINARY-LONG.
 01 L-ACT                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DAY L-BABY L-ACT.
     EVALUATE TRUE
         WHEN L-DAY < 10 OR L-DAY >= 12000
             MOVE 3 TO L-ACT
         WHEN L-BABY = 1 AND ((L-DAY >= 3000 AND L-DAY < 6000) OR L-DAY >= 10000)
             MOVE 4 TO L-ACT
         WHEN L-BABY = 1
             MOVE 0 TO L-ACT
         WHEN L-DAY >= 2000 AND L-DAY < 9000
             MOVE 1 TO L-ACT
         WHEN L-DAY >= 9000 AND L-DAY < 11000
             MOVE 2 TO L-ACT
         WHEN OTHER
             MOVE 0 TO L-ACT
     END-EVALUATE
     GOBACK.
 END PROGRAM VIL-DAY-ACT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PXI-KEY-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE                BINARY-LONG.
 01 WS-KEY48                PIC X(48).
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-KEY                   PIC X(32).
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KEY.
     MOVE SPACES TO L-KEY
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     IF WS-STATE > 0 AND WS-STATE < CB-STATE-COUNT
         MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-KEY48
         IF WS-KEY48(1:10) = "minecraft:"
             MOVE WS-KEY48(11:32) TO L-KEY
         ELSE
             MOVE WS-KEY48(1:32) TO L-KEY
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PXI-KEY-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-BRAIN-DIST.
*> USING entity row, x, y, z (block), distance squared out: from the villager to the centre of the block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-DX                   FLOAT-LONG.
 01 WS-DY                   FLOAT-LONG.
 01 WS-DZ                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-D2                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-D2.
     COMPUTE WS-DX = L-X + 0.5 - EN-X(L-ROW)
     COMPUTE WS-DY = L-Y + 0.5 - EN-Y(L-ROW)
     COMPUTE WS-DZ = L-Z + 0.5 - EN-Z(L-ROW)
     COMPUTE L-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
     GOBACK.
 END PROGRAM VL-BRAIN-DIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-BRAIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VILPOIX.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-DAY                  BINARY-LONG.
 01 WS-BABY                 BINARY-LONG.
 01 WS-ACT                  BINARY-LONG.
 01 WS-CX                   BINARY-LONG.
 01 WS-CZ                   BINARY-LONG.
 01 WS-IDX                  BINARY-LONG.
 01 WS-R                    BINARY-LONG.
 01 WS-TWENTY               BINARY-LONG VALUE 20.
 01 WS-SALT                 BINARY-LONG VALUE 161.
 01 WS-RANGE                BINARY-LONG VALUE 48.
 01 WS-KIND-BED             BINARY-LONG VALUE 1.
 01 WS-KIND-BELL            BINARY-LONG VALUE 2.
 01 WS-KIND-JOB             BINARY-LONG VALUE 3.
 01 WS-HOME                 BINARY-LONG VALUE 2.
 01 WS-MEET                 BINARY-LONG VALUE 3.
 01 WS-JOB                  BINARY-LONG VALUE 0.
 01 WS-QD                   BINARY-LONG.
 01 WS-QX                   BINARY-LONG.
 01 WS-QY                   BINARY-LONG.
 01 WS-QZ                   BINARY-LONG.
 01 WS-FOUND                BINARY-LONG.
 01 WS-KIND                 BINARY-LONG.
 01 WS-KEY                  PIC X(32).
 01 WS-CHANGED              BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-HAS-JOB              BINARY-LONG.
 01 WS-PX                   BINARY-LONG.
 01 WS-PY                   BINARY-LONG.
 01 WS-PZ                   BINARY-LONG.
 01 WS-PD                   BINARY-LONG.
 01 WS-SX                   FLOAT-LONG.
 01 WS-SY                   FLOAT-LONG.
 01 WS-SZ                   FLOAT-LONG.
 01 WS-SYAW                 FLOAT-SHORT.
 01 WS-SPITCH               FLOAT-SHORT.
 01 WS-SGROUND              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "VL-FIND" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT = 0 OR VL-KIND(WS-SLOT) NOT = 1
         GOBACK
     END-IF
     MOVE 0 TO WS-BABY
     IF EN-MOBAGE(L-ROW) < 0
         MOVE 1 TO WS-BABY
     END-IF
     COMPUTE WS-DAY = FUNCTION MOD(CW-TIME, 24000)
     CALL "VIL-DAY-ACT" USING WS-DAY WS-BABY WS-ACT
*>   WakeUp (core): sleeping while REST is not the activity.
     IF VL-SLEEP(WS-SLOT) = 1 AND WS-ACT NOT = 3
         MOVE 0 TO VL-SLEEP(WS-SLOT)
         MOVE CW-TICKS TO VL-LAST-WOKEN(WS-SLOT)
     END-IF
*>   A sleeping villager lies where it started sleeping, on its bed (19 section 22.8): the stroll of the mob step neither starts nor goes on (the cooldown is held at 1 and
*>   the destination is its own cell), so it does not wander off while it is flagged asleep and refuses a trade (22.4).
     IF VL-SLEEP(WS-SLOT) = 1
         COMPUTE EN-DEST-X(L-ROW) = FUNCTION INTEGER(EN-X(L-ROW))
         COMPUTE EN-DEST-Z(L-ROW) = FUNCTION INTEGER(EN-Z(L-ROW))
         MOVE 1 TO EN-COOLDOWN(L-ROW)
     END-IF
*>   The index fills while villagers live: one section of the chunk round the villager every 5 ticks (7 x 7 chunks, one after the other).
     IF FUNCTION MOD(CW-TICKS + EN-ID(L-ROW), 5) = 0
*>     The scan in progress goes on first (one chunk after the other: 24 calls finish it), then the chunk of the villager, then the round of the 7 x 7.
         IF PX-SC-ON = 1
             CALL "PXI-SCAN" USING PX-SC-DIM PX-SC-CX PX-SC-CZ
         ELSE
             COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW) / 16)
             COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW) / 16)
             CALL "PXI-SCAN" USING EN-DIM(L-ROW) WS-CX WS-CZ
             IF PX-SC-ON = 0
                 COMPUTE WS-IDX = FUNCTION MOD(CW-TICKS / 5, 49)
                 COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW) / 16) + FUNCTION INTEGER(WS-IDX / 7) - 3
                 COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW) / 16) + FUNCTION MOD(WS-IDX, 7) - 3
                 CALL "PXI-SCAN" USING EN-DIM(L-ROW) WS-CX WS-CZ
             END-IF
         END-IF
     END-IF
     IF CW-TICKS < VL-NEXT-BRAIN(WS-SLOT)
         GOBACK
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-TWENTY WS-R
     COMPUTE VL-NEXT-BRAIN(WS-SLOT) = CW-TICKS + 20 + WS-R
*>   ValidateNearbyPoi: a claim whose block is gone or of another kind is released.
     CALL "VPX-OF" USING EN-ID(L-ROW) WS-HOME WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     IF WS-FOUND = 1
         CALL "PXI-KIND-OF" USING WS-QD WS-QX WS-QY WS-QZ WS-KIND
         IF WS-KIND NOT = WS-KIND-BED
             CALL "VPX-RELEASE-KIND" USING EN-ID(L-ROW) WS-HOME
         END-IF
     END-IF
     CALL "VPX-OF" USING EN-ID(L-ROW) WS-MEET WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     IF WS-FOUND = 1
         CALL "PXI-KIND-OF" USING WS-QD WS-QX WS-QY WS-QZ WS-KIND
         IF WS-KIND NOT = WS-KIND-BELL
             CALL "VPX-RELEASE-KIND" USING EN-ID(L-ROW) WS-MEET
         END-IF
     END-IF
     CALL "VPX-OF" USING EN-ID(L-ROW) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     IF WS-FOUND = 1
         CALL "PXI-KIND-OF" USING WS-QD WS-QX WS-QY WS-QZ WS-KIND
         IF WS-KIND NOT = WS-KIND-JOB
             CALL "VPX-RELEASE-KIND" USING EN-ID(L-ROW) WS-JOB
             MOVE 0 TO VL-POT(WS-SLOT)
         END-IF
     END-IF
     COMPUTE WS-PX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-PY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-PZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "VPX-OF" USING EN-ID(L-ROW) WS-HOME WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     IF WS-FOUND = 0
         CALL "PXI-NEAREST" USING EN-DIM(L-ROW) WS-PX WS-PY WS-PZ WS-KIND-BED WS-RANGE WS-QX WS-QY WS-QZ WS-FOUND
         IF WS-FOUND = 1
             CALL "VPX-CLAIM" USING EN-ID(L-ROW) WS-HOME EN-DIM(L-ROW) WS-QX WS-QY WS-QZ
         END-IF
     END-IF
     IF WS-BABY = 0
         CALL "VPX-OF" USING EN-ID(L-ROW) WS-MEET WS-QD WS-QX WS-QY WS-QZ WS-FOUND
         IF WS-FOUND = 0
             CALL "PXI-NEAREST" USING EN-DIM(L-ROW) WS-PX WS-PY WS-PZ WS-KIND-BELL WS-RANGE WS-QX WS-QY WS-QZ WS-FOUND
             IF WS-FOUND = 1
                 CALL "VPX-CLAIM" USING EN-ID(L-ROW) WS-MEET EN-DIM(L-ROW) WS-QX WS-QY WS-QZ
             END-IF
         END-IF
         CALL "VPX-OF" USING EN-ID(L-ROW) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND
         IF WS-FOUND = 0 AND VL-PROF(WS-SLOT) = "none"
             CALL "PXI-NEAREST" USING EN-DIM(L-ROW) WS-PX WS-PY WS-PZ WS-KIND-JOB WS-RANGE WS-QX WS-QY WS-QZ WS-FOUND
             IF WS-FOUND = 1
                 CALL "VP-CLAIM" USING EN-DIM(L-ROW) WS-QX WS-QY WS-QZ EN-ID(L-ROW)
                 MOVE 1 TO VL-POT(WS-SLOT)
             END-IF
         END-IF
     END-IF
     CALL "VPX-OF" USING EN-ID(L-ROW) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     MOVE WS-FOUND TO WS-HAS-JOB
     IF WS-FOUND = 1 AND VL-POT(WS-SLOT) = 1
         CALL "VL-BRAIN-DIST" USING L-ROW WS-QX WS-QY WS-QZ WS-D2
         IF WS-D2 <= 4
             CALL "PXI-KEY-AT" USING WS-QD WS-QX WS-QY WS-QZ WS-KEY
             CALL "VL-CLAIM" USING WS-SLOT WS-KEY WS-CHANGED
             MOVE 0 TO VL-POT(WS-SLOT)
             IF WS-CHANGED = 1
                 CALL "MOB-DATA-SEND" USING L-ROW
             END-IF
         END-IF
     END-IF
     IF WS-HAS-JOB = 0 AND VL-PROF(WS-SLOT) NOT = "none" AND VL-PROF(WS-SLOT) NOT = "nitwit"
             AND VL-XP(WS-SLOT) = 0 AND VL-LEVEL(WS-SLOT) <= 1 AND VL-KIND(WS-SLOT) = 1
         MOVE "none" TO VL-PROF(WS-SLOT)
         MOVE 0 TO VL-O-N(WS-SLOT) VL-BUILT(WS-SLOT)
         CALL "MOB-DATA-SEND" USING L-ROW
     END-IF
     MOVE 0 TO WS-FOUND
     EVALUATE WS-ACT
         WHEN 1
             CALL "VPX-OF" USING EN-ID(L-ROW) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND
             MOVE 9 TO WS-PD
         WHEN 2
             CALL "VPX-OF" USING EN-ID(L-ROW) WS-MEET WS-QD WS-QX WS-QY WS-QZ WS-FOUND
             MOVE 36 TO WS-PD
         WHEN 3
             CALL "VPX-OF" USING EN-ID(L-ROW) WS-HOME WS-QD WS-QX WS-QY WS-QZ WS-FOUND
             MOVE 4 TO WS-PD
     END-EVALUATE
*>   GoToPotentialJobSite (44 section 2.5): a claimed site that is not taken yet is walked to in the idle, work and play activities, up to its own block.
     IF WS-FOUND = 0 AND VL-POT(WS-SLOT) = 1 AND WS-ACT NOT = 2 AND WS-ACT NOT = 3
         CALL "VPX-OF" USING EN-ID(L-ROW) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND
         MOVE 2 TO WS-PD
     END-IF
     IF WS-FOUND = 1
         CALL "VL-BRAIN-DIST" USING L-ROW WS-QX WS-QY WS-QZ WS-D2
         IF VL-POT(WS-SLOT) = 1 AND WS-ACT NOT = 2 AND WS-ACT NOT = 3
             MOVE 2 TO WS-PD
         END-IF
         IF WS-D2 > WS-PD AND EN-COOLDOWN(L-ROW) = 0 AND VL-SLEEP(WS-SLOT) = 0
             MOVE WS-QX TO EN-DEST-X(L-ROW)
             MOVE WS-QZ TO EN-DEST-Z(L-ROW)
             MOVE 200 TO EN-COOLDOWN(L-ROW)
         END-IF
         IF WS-ACT = 3 AND WS-D2 <= 4 AND VL-SLEEP(WS-SLOT) = 0
             IF VL-LAST-WOKEN(WS-SLOT) = 0 OR CW-TICKS - VL-LAST-WOKEN(WS-SLOT) >= 100
                 MOVE 1 TO VL-SLEEP(WS-SLOT)
                 MOVE CW-TICKS TO VL-LAST-SLEPT(WS-SLOT)
*>               startSleeping puts the villager at the bed position (22.8): the middle of the bed block, on the mattress (51 R-E3: 9 sixteenths).
                 COMPUTE WS-SX = WS-QX + 0.5
                 COMPUTE WS-SY = WS-QY + 0.5625
                 COMPUTE WS-SZ = WS-QZ + 0.5
                 MOVE EN-YAW(L-ROW) TO WS-SYAW
                 MOVE EN-PITCH(L-ROW) TO WS-SPITCH
                 MOVE EN-ON-GROUND(L-ROW) TO WS-SGROUND
                 CALL "ENTITY-MOVE" USING L-ROW WS-SX WS-SY WS-SZ WS-SYAW WS-SPITCH WS-SGROUND
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM VL-BRAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VPX-RELEASE-KIND.
*> USING owner id, kind: releases the claims of that kind of the villager.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILPOI.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-OWNER                 BINARY-LONG.
 01 L-KIND                  BINARY-LONG.
 PROCEDURE DIVISION USING L-OWNER L-KIND.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PO-MAX
         IF PO-OWNER(WS-I) = L-OWNER AND PO-KIND(WS-I) = L-KIND
             INITIALIZE PO-ENTRY(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VPX-RELEASE-KIND.
