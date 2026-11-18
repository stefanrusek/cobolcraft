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
 PROGRAM-ID. VL-BRAIN-VALIDATE.
*> USING entity row, claim kind (0 job site, 2 home, 3 meeting), block kind the claim needs (PXI-KIND-OF), released out: ValidateNearbyPoi (44 section 2.2) for one claim of the villager: it
*> only looks while the villager is in the claim's dimension and within 16 blocks of it; a claim whose block is gone is released (the claim table holds the ticket).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-QD                   BINARY-LONG.
 01 WS-QX                   BINARY-LONG.
 01 WS-QY                   BINARY-LONG.
 01 WS-QZ                   BINARY-LONG.
 01 WS-FOUND                BINARY-LONG.
 01 WS-KIND                 BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-LIMIT                FLOAT-LONG VALUE 256.0.
 01 WS-SAME                 BINARY-LONG.
 01 WS-NEAR                 BINARY-LONG.
 01 WS-RECORD               BINARY-LONG.
 01 WS-HOME                 BINARY-LONG.
 01 WS-NOT                  BINARY-LONG VALUE 0.
 01 WS-NOT-2                BINARY-LONG VALUE 0.
 01 WS-NOT-3                BINARY-LONG VALUE 0.
 01 WS-ACTION               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-KIND                  BINARY-LONG.
 01 L-EXPECTED              BINARY-LONG.
 01 L-RELEASED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-KIND L-EXPECTED L-RELEASED.
     MOVE 0 TO L-RELEASED
     CALL "VPX-OF" USING EN-ID(L-ROW) L-KIND WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     IF WS-FOUND = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-SAME WS-NEAR
     MOVE 1 TO WS-RECORD
     IF WS-QD = EN-DIM(L-ROW)
         MOVE 1 TO WS-SAME
         CALL "VL-BRAIN-DIST" USING L-ROW WS-QX WS-QY WS-QZ WS-D2
         IF WS-D2 < WS-LIMIT
             MOVE 1 TO WS-NEAR
             CALL "PXI-KIND-OF" USING WS-QD WS-QX WS-QY WS-QZ WS-KIND
             IF WS-KIND NOT = L-EXPECTED
                 MOVE 0 TO WS-RECORD
             END-IF
         END-IF
     END-IF
     MOVE 0 TO WS-HOME
     IF L-KIND = 2
         MOVE 1 TO WS-HOME
     END-IF
     CALL "Q3-VALIDATE-POI" USING WS-SAME WS-NEAR WS-RECORD WS-HOME WS-NOT WS-NOT-2 WS-NOT-3 WS-ACTION
     IF WS-ACTION NOT = 0
         CALL "VPX-RELEASE-KIND" USING EN-ID(L-ROW) L-KIND
         MOVE 1 TO L-RELEASED
     END-IF
     GOBACK.
 END PROGRAM VL-BRAIN-VALIDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-BRAIN.
*> USING entity row: one tick of the brain of a villager. Every tick: the activity (VM-ACT-TICK), WakeUp, the index fill, the walk target (VL-WALK-TICK). Every 20 to 39 ticks (the brain beat,
*> VL-NEXT-BRAIN) the decisions of VL-BRAIN-BEAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VILPOIX.
 COPY VLMEM.
 01 WS-SCHED                BINARY-LONG.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-BABY                 BINARY-LONG.
 01 WS-ACT                  BINARY-LONG.
 01 WS-CX                   BINARY-LONG.
 01 WS-CZ                   BINARY-LONG.
 01 WS-IDX                  BINARY-LONG.
 01 WS-R                    BINARY-LONG.
 01 WS-TWENTY               BINARY-LONG VALUE 20.
 01 WS-SALT                 BINARY-LONG VALUE 161.
 01 WS-STOP                 BINARY-LONG.
 01 WS-REST                 BINARY-LONG.
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
     CALL "VM-ACT-TICK" USING WS-SLOT WS-BABY WS-SCHED WS-ACT
*>   WakeUp (core): sleeping while REST is not the activity.
     MOVE 0 TO WS-REST
     IF WS-ACT = VA-REST
         MOVE 1 TO WS-REST
     END-IF
     CALL "Q3-WAKE" USING WS-REST VL-SLEEP(WS-SLOT) WS-STOP
     IF WS-STOP = 1
         MOVE 0 TO VL-SLEEP(WS-SLOT)
         MOVE CW-TICKS TO VL-LAST-WOKEN(WS-SLOT)
         COMPUTE VM-T(WS-SLOT, TM-SLEEP-OK) = CW-TICKS + 40
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
     CALL "VL-WALK-TICK" USING L-ROW WS-SLOT
     CALL "VL-SENSE" USING L-ROW WS-SLOT
     CALL "VL-CORE-TICK" USING L-ROW WS-SLOT WS-BABY
     IF VM-T(WS-SLOT, TM-CELL-ON) = 1
         CALL "VL-FARM-STEP" USING L-ROW WS-SLOT
     END-IF
     MOVE VM-ACT(WS-SLOT) TO WS-ACT
     IF CW-TICKS < VL-NEXT-BRAIN(WS-SLOT)
         GOBACK
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-TWENTY WS-R
     COMPUTE VL-NEXT-BRAIN(WS-SLOT) = CW-TICKS + 20 + WS-R
     CALL "VL-BRAIN-BEAT" USING L-ROW WS-SLOT WS-BABY WS-ACT
     GOBACK.
 END PROGRAM VL-BRAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-BRAIN-BEAT.
*> USING entity row, slot, baby, active activity: the decisions of the brain beat: ValidateNearbyPoi, AcquirePoi (home bed of any villager, meeting bell and job site of adults: the nearest free
*> point of the index within 48 blocks), AssignProfessionFromJobSite (within 2 blocks of the claimed workstation), ResetProfession, then the walk (VL-BRAIN-WALK) and the bed (VL-BRAIN-SLEEP).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VILPOIX.
 COPY VLMEM.
 01 WS-RANGE                BINARY-LONG VALUE 48.
 01 WS-KIND-BED             BINARY-LONG VALUE 1.
 01 WS-KIND-BELL            BINARY-LONG VALUE 2.
 01 WS-KIND-JOB             BINARY-LONG VALUE 3.
 01 WS-HOME                 BINARY-LONG VALUE 2.
 01 WS-MEET                 BINARY-LONG VALUE 3.
 01 WS-JOB                  BINARY-LONG VALUE 0.
 01 WS-INST-JOB             BINARY-LONG VALUE 1.
 01 WS-INST-HOME            BINARY-LONG VALUE 2.
 01 WS-INST-MEET            BINARY-LONG VALUE 3.
 01 WS-REACH-1              BINARY-LONG VALUE 1.
 01 WS-REACH-6              BINARY-LONG VALUE 6.
 01 WS-QD                   BINARY-LONG.
 01 WS-QX                   BINARY-LONG.
 01 WS-QY                   BINARY-LONG.
 01 WS-QZ                   BINARY-LONG.
 01 WS-FOUND                BINARY-LONG.
 01 WS-KEY                  PIC X(32).
 01 WS-CHANGED              BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-HAS-JOB              BINARY-LONG.
 01 WS-PX                   BINARY-LONG.
 01 WS-PY                   BINARY-LONG.
 01 WS-PZ                   BINARY-LONG.
 01 WS-REL                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 01 L-BABY                  BINARY-LONG.
 01 L-ACT                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-BABY L-ACT.
*>   ValidateNearbyPoi (44 section 2.2): a claim whose block is gone or of another kind is released once the villager is within 16 blocks of it.
     CALL "VL-BRAIN-VALIDATE" USING L-ROW WS-HOME WS-KIND-BED WS-REL
     CALL "VL-BRAIN-VALIDATE" USING L-ROW WS-MEET WS-KIND-BELL WS-REL
     CALL "VL-BRAIN-VALIDATE" USING L-ROW WS-JOB WS-KIND-JOB WS-REL
     IF WS-REL = 1
         MOVE 0 TO VL-POT(L-SLOT)
     END-IF
     COMPUTE WS-PX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-PY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-PZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "VPX-OF" USING EN-ID(L-ROW) WS-HOME WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     IF WS-FOUND = 0
         CALL "PXI-NEAREST" USING EN-DIM(L-ROW) WS-PX WS-PY WS-PZ WS-KIND-BED WS-RANGE WS-QX WS-QY WS-QZ WS-FOUND
         IF WS-FOUND = 1
             CALL "VL-ACQ-OK" USING L-ROW L-SLOT WS-INST-HOME WS-QX WS-QY WS-QZ WS-REACH-1 WS-FOUND
         END-IF
         IF WS-FOUND = 1
             CALL "VPX-CLAIM" USING EN-ID(L-ROW) WS-HOME EN-DIM(L-ROW) WS-QX WS-QY WS-QZ
         END-IF
     END-IF
     IF L-BABY = 0
         CALL "VPX-OF" USING EN-ID(L-ROW) WS-MEET WS-QD WS-QX WS-QY WS-QZ WS-FOUND
         IF WS-FOUND = 0
             CALL "PXI-NEAREST" USING EN-DIM(L-ROW) WS-PX WS-PY WS-PZ WS-KIND-BELL WS-RANGE WS-QX WS-QY WS-QZ WS-FOUND
             IF WS-FOUND = 1
                 CALL "VL-ACQ-OK" USING L-ROW L-SLOT WS-INST-MEET WS-QX WS-QY WS-QZ WS-REACH-6 WS-FOUND
             END-IF
             IF WS-FOUND = 1
                 CALL "VPX-CLAIM" USING EN-ID(L-ROW) WS-MEET EN-DIM(L-ROW) WS-QX WS-QY WS-QZ
             END-IF
         END-IF
         CALL "VPX-OF" USING EN-ID(L-ROW) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND
         IF WS-FOUND = 0 AND VL-PROF(L-SLOT) = "none"
             CALL "PXI-NEAREST" USING EN-DIM(L-ROW) WS-PX WS-PY WS-PZ WS-KIND-JOB WS-RANGE WS-QX WS-QY WS-QZ WS-FOUND
             IF WS-FOUND = 1
                 CALL "VL-ACQ-OK" USING L-ROW L-SLOT WS-INST-JOB WS-QX WS-QY WS-QZ WS-REACH-1 WS-FOUND
             END-IF
             IF WS-FOUND = 1
                 CALL "VP-CLAIM" USING EN-DIM(L-ROW) WS-QX WS-QY WS-QZ EN-ID(L-ROW)
                 MOVE 1 TO VL-POT(L-SLOT)
                 MOVE 0 TO VM-T(L-SLOT, TM-POT-START)
             END-IF
         END-IF
     END-IF
     CALL "VPX-OF" USING EN-ID(L-ROW) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-FOUND
     MOVE WS-FOUND TO WS-HAS-JOB
     IF WS-FOUND = 1 AND VL-POT(L-SLOT) = 1
         CALL "VL-BRAIN-DIST" USING L-ROW WS-QX WS-QY WS-QZ WS-D2
         IF WS-D2 <= 4
             CALL "PXI-KEY-AT" USING WS-QD WS-QX WS-QY WS-QZ WS-KEY
             CALL "VL-CLAIM" USING L-SLOT WS-KEY WS-CHANGED
             MOVE 0 TO VL-POT(L-SLOT)
             IF WS-CHANGED = 1
                 CALL "MOB-DATA-SEND" USING L-ROW
             END-IF
         END-IF
     END-IF
     IF WS-HAS-JOB = 0 AND VL-PROF(L-SLOT) NOT = "none" AND VL-PROF(L-SLOT) NOT = "nitwit"
             AND VL-XP(L-SLOT) = 0 AND VL-LEVEL(L-SLOT) <= 1 AND VL-KIND(L-SLOT) = 1
         MOVE "none" TO VL-PROF(L-SLOT)
         MOVE 0 TO VL-O-N(L-SLOT) VL-BUILT(L-SLOT)
         CALL "MOB-DATA-SEND" USING L-ROW
     END-IF
     CALL "VL-BRAIN-WALK" USING L-ROW L-SLOT L-ACT
     CALL "VL-BRAIN-SLEEP" USING L-ROW L-SLOT L-ACT
     CALL "VL-WORK-TICK" USING L-ROW L-SLOT L-ACT
     CALL "VL-FARM-START" USING L-ROW L-SLOT L-ACT
     GOBACK.
 END PROGRAM VL-BRAIN-BEAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-BRAIN-WALK.
*> USING entity row, slot, active activity: the walk behaviours of the activities that need walk_target absent. GoToPotentialJobSite (44 section 2.5; idle, work and play): walk to the claimed job
*> site, closeness 1; after 1200 ticks the claim is given up. SetWalkTargetFromBlockMemory (2.17): work walks to the job_site, meet to the meeting_point, rest to the home, with the
*> closeEnough, tooFar and giveUpAfter of the instance (Q3-BLOCKMEM-PARAMS). A point beyond tooFar is approached by a random position 15 blocks towards it (placeholder for
*> DefaultRandomPos.getPosTowards: the document does not give the sampling, so the position is the one 15 blocks along the direction to the point).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VLMEM.
 01 WS-PRESENT              BINARY-LONG.
 01 WS-TYPE                 BINARY-LONG.
 01 WS-INSTANCE             BINARY-LONG.
 01 WS-QD                   BINARY-LONG.
 01 WS-QX                   BINARY-LONG.
 01 WS-QY                   BINARY-LONG.
 01 WS-QZ                   BINARY-LONG.
 01 WS-SD                   BINARY-LONG.
 01 WS-N1                   BINARY-LONG.
 01 WS-N2                   BINARY-LONG.
 01 WS-CLOSE                BINARY-LONG.
 01 WS-TOO-FAR              BINARY-LONG.
 01 WS-GIVE-UP              BINARY-LONG.
 01 WS-SPEED                FLOAT-LONG.
 01 WS-SAME                 BINARY-LONG.
 01 WS-HAS-SINCE            BINARY-LONG.
 01 WS-SINCE                BINARY-LONG.
 01 WS-NOW                  BINARY-LONG.
 01 WS-DIST                 BINARY-LONG.
 01 WS-DX                   BINARY-LONG.
 01 WS-DY                   BINARY-LONG.
 01 WS-DZ                   BINARY-LONG.
 01 WS-FOUND                BINARY-LONG VALUE 1.
 01 WS-OUTCOME              BINARY-LONG.
 01 WS-YES                  BINARY-LONG.
 01 WS-ONE                  BINARY-LONG VALUE 1.
 01 WS-NONE                 BINARY-LONG VALUE 0.
 01 WS-H                    FLOAT-LONG.
 01 WS-TX                   BINARY-LONG.
 01 WS-TY                   BINARY-LONG.
 01 WS-TZ                   BINARY-LONG.
 01 WS-PX                   BINARY-LONG.
 01 WS-PY                   BINARY-LONG.
 01 WS-PZ                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 01 L-ACT                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ACT.
     MOVE CW-TICKS TO WS-NOW
     CALL "VM-HAS" USING L-SLOT MT-WALK-TARGET WS-PRESENT
     IF WS-PRESENT = 1
         GOBACK
     END-IF
*>   GoToPotentialJobSite.
     CALL "Q3-POT-START" USING L-ACT WS-YES
     CALL "VM-GET" USING L-SLOT MT-POTENTIAL-JOB-SITE WS-PRESENT WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
     IF WS-PRESENT = 1 AND WS-YES = 1
         IF VM-T(L-SLOT, TM-POT-START) = 0
             MOVE WS-NOW TO VM-T(L-SLOT, TM-POT-START)
         END-IF
         IF WS-NOW - VM-T(L-SLOT, TM-POT-START) > 1200
             CALL "VM-ERASE" USING L-SLOT MT-POTENTIAL-JOB-SITE
             MOVE 0 TO VM-T(L-SLOT, TM-POT-START)
         ELSE
             MOVE 1.0 TO WS-SPEED
             CALL "VL-WALK-SET" USING L-ROW L-SLOT WS-QD WS-QX WS-QY WS-QZ WS-SPEED WS-ONE
         END-IF
         GOBACK
     END-IF
*>   SetWalkTargetFromBlockMemory of the activity.
     MOVE 0 TO WS-INSTANCE
     EVALUATE L-ACT
         WHEN VA-WORK
             MOVE 1 TO WS-INSTANCE
             MOVE MT-JOB-SITE TO WS-TYPE
         WHEN VA-MEET
             MOVE 3 TO WS-INSTANCE
             MOVE MT-MEETING-POINT TO WS-TYPE
         WHEN VA-REST
             MOVE 2 TO WS-INSTANCE
             MOVE MT-HOME TO WS-TYPE
         WHEN VA-PRE-RAID
             MOVE 4 TO WS-INSTANCE
             MOVE MT-MEETING-POINT TO WS-TYPE
     END-EVALUATE
     IF WS-INSTANCE = 0
         GOBACK
     END-IF
     CALL "VM-GET" USING L-SLOT WS-TYPE WS-PRESENT WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
     IF WS-PRESENT = 0
         GOBACK
     END-IF
     CALL "Q3-BLOCKMEM-PARAMS" USING WS-INSTANCE WS-CLOSE WS-TOO-FAR WS-GIVE-UP WS-SPEED
     MOVE 0 TO WS-SAME
     IF WS-QD = EN-DIM(L-ROW)
         MOVE 1 TO WS-SAME
     END-IF
     COMPUTE WS-PX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-PY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-PZ = FUNCTION INTEGER(EN-Z(L-ROW))
     COMPUTE WS-DX = FUNCTION ABS(WS-QX - WS-PX)
     COMPUTE WS-DY = FUNCTION ABS(WS-QY - WS-PY)
     COMPUTE WS-DZ = FUNCTION ABS(WS-QZ - WS-PZ)
     COMPUTE WS-DIST = WS-DX + WS-DY + WS-DZ
     CALL "VM-GET" USING L-SLOT MT-CANT-REACH-SINCE WS-HAS-SINCE WS-SD WS-TX WS-TY WS-TZ WS-SINCE WS-N2
     CALL "Q3-BLOCKMEM" USING WS-SAME WS-HAS-SINCE WS-SINCE WS-NOW WS-GIVE-UP WS-DIST WS-TOO-FAR WS-CLOSE WS-FOUND WS-OUTCOME
     EVALUATE WS-OUTCOME
         WHEN 1
*>           Release the point of interest and give the walk up for now.
             CALL "VM-ERASE" USING L-SLOT WS-TYPE
             CALL "VM-NOTE" USING L-SLOT MT-CANT-REACH-SINCE WS-NOW
         WHEN 2
*>           A position 15 blocks from the villager towards the point (placeholder for getPosTowards).
             COMPUTE WS-H = FUNCTION SQRT((WS-QX - EN-X(L-ROW)) ** 2 + (WS-QZ - EN-Z(L-ROW)) ** 2)
             COMPUTE WS-TX = FUNCTION INTEGER(EN-X(L-ROW) + (WS-QX - EN-X(L-ROW)) * 15 / WS-H)
             COMPUTE WS-TZ = FUNCTION INTEGER(EN-Z(L-ROW) + (WS-QZ - EN-Z(L-ROW)) * 15 / WS-H)
             CALL "VL-WALK-SET" USING L-ROW L-SLOT WS-QD WS-TX WS-PY WS-TZ WS-SPEED WS-CLOSE
         WHEN 3
             CALL "VL-WALK-SET" USING L-ROW L-SLOT WS-QD WS-QX WS-QY WS-QZ WS-SPEED WS-CLOSE
     END-EVALUATE
     GOBACK.
 END PROGRAM VL-BRAIN-WALK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-BRAIN-SLEEP.
*> USING entity row, slot, active activity: SleepInBed (19 section 22.8). In the rest activity a villager within 2 blocks of its home bed, not woken within 100 ticks and not within 40 ticks of the
*> last time it stopped, goes to sleep: VL-SLEEP, last_slept = now, and the walk target ends. Gap: no sleeping pose and no bed position in the metadata, beds are not marked occupied.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VLMEM.
 01 WS-PRESENT              BINARY-LONG.
 01 WS-QD                   BINARY-LONG.
 01 WS-QX                   BINARY-LONG.
 01 WS-QY                   BINARY-LONG.
 01 WS-QZ                   BINARY-LONG.
 01 WS-N1                   BINARY-LONG.
 01 WS-N2                   BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 01 L-ACT                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ACT.
     IF L-ACT NOT = VA-REST OR VL-SLEEP(L-SLOT) = 1
         GOBACK
     END-IF
     CALL "VM-GET" USING L-SLOT MT-HOME WS-PRESENT WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
     IF WS-PRESENT = 0 OR WS-QD NOT = EN-DIM(L-ROW)
         GOBACK
     END-IF
     CALL "VL-BRAIN-DIST" USING L-ROW WS-QX WS-QY WS-QZ WS-D2
     IF WS-D2 <= 4 AND CW-TICKS > VM-T(L-SLOT, TM-SLEEP-OK)
             AND (VL-LAST-WOKEN(L-SLOT) = 0 OR CW-TICKS - VL-LAST-WOKEN(L-SLOT) >= 100)
         MOVE 1 TO VL-SLEEP(L-SLOT)
         MOVE CW-TICKS TO VL-LAST-SLEPT(L-SLOT)
         CALL "VL-WALK-STOP" USING L-ROW L-SLOT
         CALL "VM-ERASE" USING L-SLOT MT-CANT-REACH-SINCE
     END-IF
     GOBACK.
 END PROGRAM VL-BRAIN-SLEEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-CAN-REACH.
*> USING row, x, y, z of a block, reach, ok out: canReach of AcquirePoi's path (44 section 2.1 step 6): a path search (STDMOB-PATH, 100 nodes, a villager is 2 blocks high) from the
*> villager's feet cell ends within `reach` (Manhattan, the POI type's valid range: 1 for a bed or a workstation, 6 for a bell) of the block. The document's one search to the whole set of
*> candidates is one search to the nearest candidate here.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SX                   BINARY-LONG.
 01 WS-SY                   BINARY-LONG.
 01 WS-SZ                   BINARY-LONG.
 01 WS-HEIGHT               BINARY-LONG VALUE 2.
 01 WS-BUDGET               BINARY-LONG VALUE 100.
 01 WS-COUNT                BINARY-LONG.
 01 WS-REACHED              BINARY-LONG.
 01 WS-DIST                 BINARY-LONG.
 01 WS-PATH-TABLE.
    05 WS-PATH OCCURS 128 TIMES.
       10 WS-PX             BINARY-LONG.
       10 WS-PY             BINARY-LONG.
       10 WS-PZ             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-REACH                 BINARY-LONG.
 01 L-OK                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-REACH L-OK.
     MOVE 0 TO L-OK
     COMPUTE WS-SX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-SY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-SZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "STDMOB-PATH" USING EN-DIM(L-ROW) WS-SX WS-SY WS-SZ L-X L-Y L-Z WS-HEIGHT WS-BUDGET WS-PATH-TABLE WS-COUNT WS-REACHED
     IF WS-COUNT = 0
*>       No floor under the villager within 3 blocks: no search is possible, so the candidate is not turned away.
         MOVE 1 TO L-OK
     ELSE
         COMPUTE WS-DIST = FUNCTION ABS(WS-PX(WS-COUNT) - L-X) + FUNCTION ABS(WS-PY(WS-COUNT) - L-Y) + FUNCTION ABS(WS-PZ(WS-COUNT) - L-Z)
         IF WS-REACHED = 1 OR WS-DIST <= L-REACH
             MOVE 1 TO L-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM VL-CAN-REACH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-ACQ-OK.
*> USING row, slot, instance (1 job site, 2 home, 3 meeting point), x, y, z, reach, ok out: the retry and path check of AcquirePoi for the nearest candidate (44 section 2.1 steps 4, 5, 6, 7 and the
*> JitteredLinearRetry): while the retry delay of the instance runs nothing is tried; a candidate that cannot be reached (VL-CAN-REACH) delays the instance by 40 to 79 ticks more than the
*> last delay, up to 400 (Q3-ACQ-RETRY); a reached one clears the delay. The document keeps a retry object per candidate position; this keeps one per instance.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VLMEM.
 01 WS-NOW                  BINARY-LONG.
 01 WS-YES                  BINARY-LONG.
 01 WS-DRAW                 BINARY-LONG.
 01 WS-FORTY                BINARY-LONG VALUE 40.
 01 WS-SALT                 BINARY-LONG VALUE 179.
 01 WS-NEXT                 BINARY-LONG.
 01 WS-PREV                 BINARY-LONG.
 01 WS-DELAY                BINARY-LONG.
 01 WS-D                    BINARY-LONG.
 01 WS-P                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 01 L-INSTANCE              BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-REACH                 BINARY-LONG.
 01 L-OK                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-INSTANCE L-X L-Y L-Z L-REACH L-OK.
     MOVE 0 TO L-OK
     MOVE CW-TICKS TO WS-NOW
     COMPUTE WS-D = 33 + L-INSTANCE
     COMPUTE WS-P = 36 + L-INSTANCE
     CALL "Q3-ACQ-SHOULD-RETRY" USING WS-NOW VM-T(L-SLOT, L-INSTANCE) WS-YES
     IF WS-YES = 0
         GOBACK
     END-IF
     CALL "VL-CAN-REACH" USING L-ROW L-X L-Y L-Z L-REACH L-OK
     IF L-OK = 1
         MOVE 0 TO VM-T(L-SLOT, WS-D) VM-T(L-SLOT, L-INSTANCE)
     ELSE
         CALL "XP-RANDOM" USING WS-SALT WS-FORTY WS-DRAW
         MOVE VM-T(L-SLOT, WS-P) TO WS-PREV
         MOVE VM-T(L-SLOT, WS-D) TO WS-DELAY
         CALL "Q3-ACQ-RETRY" USING WS-NOW WS-PREV WS-DELAY WS-DRAW WS-NEXT
         MOVE WS-PREV TO VM-T(L-SLOT, WS-P)
         MOVE WS-DELAY TO VM-T(L-SLOT, WS-D)
         MOVE WS-NEXT TO VM-T(L-SLOT, L-INSTANCE)
     END-IF
     GOBACK.
 END PROGRAM VL-ACQ-OK.

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
