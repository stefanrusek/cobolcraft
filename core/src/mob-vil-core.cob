*> The core behaviours of the villager brain that change its activity (docs/protocol/44 part 3 sections 2.10 to 2.12, 2.14, 2.17; 19 section 22.3; lane 002-lane-p49p), run every tick by VL-BRAIN.
*> VillagerPanicTrigger and VillagerCalmDown (panic on hurt_by or nearest_hostile, calm when neither holds within 6 blocks), ReactToBell (heard_bell_time with no raid at the position: HIDE),
*> SetRaidStatus and ResetRaidStatus (one in 20 per tick: PRE_RAID before the first wave and between waves, RAID with a wave under way, the schedule when the raid is gone), in the HIDE activity
*> SetHiddenState (15 s) and LocateHidingPlace(32, 1.25, 2), in the RAID activity LocateHidingPlace(24, 1.4, 1), in PRE_RAID RingBell. Gaps: LocateHidingPlace's home is the villager's own claimed
*> home (the document's PoiManager.find and getRandom over every bed are not modelled), the RAID activity runs LocateHidingPlace always (its condition is not given), MoveToSkySeeingSpot, the
*> celebration is not run; the walk speeds 1.5 (pre-raid), 1.4 and 1.25 are applied by VL-WALK-SCALE.
*>   VL-CORE-TICK USING row, slot, baby

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-CORE-HIDING.
*> USING row, slot, radius, close enough, speed: LocateHidingPlace (44 section 2.10): needs walk_target absent; the home within radius, else the stored hiding_place; sets hiding_place and walks to it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VLMEM.
 01 WS-PRESENT              BINARY-LONG.
 01 WS-FOUND                BINARY-LONG.
 01 WS-WITHIN               BINARY-LONG.
 01 WS-RANDOM               BINARY-LONG VALUE 0.
 01 WS-STORED               BINARY-LONG.
 01 WS-SOURCE               BINARY-LONG.
 01 WS-QD                   BINARY-LONG.
 01 WS-QX                   BINARY-LONG.
 01 WS-QY                   BINARY-LONG.
 01 WS-QZ                   BINARY-LONG.
 01 WS-N1                   BINARY-LONG.
 01 WS-N2                   BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-LIMIT                FLOAT-LONG.
 01 WS-NEAR                 BINARY-LONG.
 01 WS-WALK                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 01 L-RADIUS                BINARY-LONG.
 01 L-CLOSE                 BINARY-LONG.
 01 L-SPEED                 FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-RADIUS L-CLOSE L-SPEED.
     CALL "VM-HAS" USING L-SLOT MT-WALK-TARGET WS-PRESENT
     IF WS-PRESENT = 1
         GOBACK
     END-IF
     MOVE 0 TO WS-FOUND WS-WITHIN
     CALL "VM-GET" USING L-SLOT MT-HOME WS-FOUND WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
     IF WS-FOUND = 1
         CALL "VL-BRAIN-DIST" USING L-ROW WS-QX WS-QY WS-QZ WS-D2
         COMPUTE WS-LIMIT = L-RADIUS * L-RADIUS
         IF WS-QD = EN-DIM(L-ROW) AND WS-D2 < WS-LIMIT
             MOVE 1 TO WS-WITHIN
         END-IF
     END-IF
     CALL "VM-HAS" USING L-SLOT MT-HIDING-PLACE WS-STORED
     CALL "Q3-HIDE-PICK" USING WS-FOUND WS-WITHIN WS-RANDOM WS-STORED WS-SOURCE
     IF WS-SOURCE = 0
         GOBACK
     END-IF
     IF WS-SOURCE = 3
         CALL "VM-GET" USING L-SLOT MT-HIDING-PLACE WS-PRESENT WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
     END-IF
     CALL "VM-ERASE" USING L-SLOT MT-INTERACTION-TARGET
     CALL "VM-AT" USING L-SLOT MT-HIDING-PLACE EN-DIM(L-ROW) WS-QX WS-QY WS-QZ
     CALL "VL-BRAIN-DIST" USING L-ROW WS-QX WS-QY WS-QZ WS-D2
     COMPUTE WS-LIMIT = L-CLOSE * L-CLOSE
     MOVE 0 TO WS-NEAR
     IF WS-D2 < WS-LIMIT
         MOVE 1 TO WS-NEAR
     END-IF
     CALL "Q3-HIDE-WALK" USING WS-NEAR WS-WALK
     IF WS-WALK = 1
         CALL "VL-WALK-SET" USING L-ROW L-SLOT EN-DIM(L-ROW) WS-QX WS-QY WS-QZ L-SPEED L-CLOSE
     END-IF
     GOBACK.
 END PROGRAM VL-CORE-HIDING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-CORE-HIDDEN.
*> USING row, slot, baby: SetHiddenState (44 section 2.17): while hiding_place and heard_bell_time are there, count the ticks near the place; after 300 ticks near, or 300 ticks after the bell, the
*> memories go and the activity is the schedule's again.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VLMEM.
 01 WS-HIDING               BINARY-LONG.
 01 WS-HEARD-OK             BINARY-LONG.
 01 WS-QD                   BINARY-LONG.
 01 WS-QX                   BINARY-LONG.
 01 WS-QY                   BINARY-LONG.
 01 WS-QZ                   BINARY-LONG.
 01 WS-HEARD                BINARY-LONG.
 01 WS-N2                   BINARY-LONG.
 01 WS-N1                   BINARY-LONG.
 01 WS-HX                   BINARY-LONG.
 01 WS-HY                   BINARY-LONG.
 01 WS-HZ                   BINARY-LONG.
 01 WS-NOW                  BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-NEAR                 BINARY-LONG.
 01 WS-DONE                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 01 L-BABY                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-BABY.
     MOVE CW-TICKS TO WS-NOW
     CALL "VM-GET" USING L-SLOT MT-HIDING-PLACE WS-HIDING WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
     CALL "VM-GET" USING L-SLOT MT-HEARD-BELL-TIME WS-HEARD-OK WS-QD WS-HX WS-HY WS-HZ WS-HEARD WS-N2
     IF WS-HIDING = 0 OR WS-HEARD-OK = 0
         GOBACK
     END-IF
     CALL "VL-BRAIN-DIST" USING L-ROW WS-QX WS-QY WS-QZ WS-D2
     MOVE 0 TO WS-NEAR
     IF WS-D2 < 9
         MOVE 1 TO WS-NEAR
     END-IF
     CALL "Q3-HIDDEN" USING WS-NOW WS-HEARD VM-T(L-SLOT, TM-HIDE-COUNT) WS-NEAR WS-DONE
     IF WS-DONE = 1
         CALL "VM-ERASE" USING L-SLOT MT-HEARD-BELL-TIME
         CALL "VM-ERASE" USING L-SLOT MT-HIDING-PLACE
         CALL "VM-ACT-RESET" USING L-SLOT L-BABY
     END-IF
     GOBACK.
 END PROGRAM VL-CORE-HIDDEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-CORE-RAID.
*> USING row, slot, baby: SetRaidStatus and ResetRaidStatus (44 section 2.12), one in 20 per tick, only while some raid exists.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VLMEM.
 COPY RAIDSTATE.
 01 WS-ANY                  BINARY-LONG.
 01 WS-I                    BINARY-LONG.
 01 WS-PX                   BINARY-LONG.
 01 WS-PY                   BINARY-LONG.
 01 WS-PZ                   BINARY-LONG.
 01 WS-RAID                 BINARY-LONG.
 01 WS-AT                   BINARY-LONG.
 01 WS-DRAW                 BINARY-LONG.
 01 WS-TWENTY               BINARY-LONG VALUE 20.
 01 WS-SALT                 BINARY-LONG VALUE 163.
 01 WS-STARTED              BINARY-LONG.
 01 WS-ALIVE                BINARY-LONG.
 01 WS-GROUPS               BINARY-LONG.
 01 WS-COOLDOWN             BINARY-LONG.
 01 WS-BETWEEN              BINARY-LONG.
 01 WS-ACTIVITY             BINARY-LONG.
 01 WS-RESET                BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-NO-2                 BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 01 L-BABY                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-BABY.
     MOVE 0 TO WS-ANY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RD-MAX OR WS-ANY = 1
         IF RD-USED(WS-I) = 1
             MOVE 1 TO WS-ANY
         END-IF
     END-PERFORM
     IF WS-ANY = 0 AND VM-ACT(L-SLOT) NOT = VA-PRE-RAID AND VM-ACT(L-SLOT) NOT = VA-RAID
         GOBACK
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-TWENTY WS-DRAW
     COMPUTE WS-PX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-PY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-PZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "RAID-AT" USING EN-DIM(L-ROW) WS-PX WS-PY WS-PZ WS-RAID
     MOVE 0 TO WS-AT
     IF WS-RAID > 0
         MOVE 1 TO WS-AT
     END-IF
*>   SetRaidStatus.
     IF WS-RAID > 0
         MOVE RD-STARTED(WS-RAID) TO WS-STARTED
         MOVE RD-GROUPS(WS-RAID) TO WS-GROUPS
         MOVE RD-COOLDOWN(WS-RAID) TO WS-COOLDOWN
         CALL "RAID-ALIVE" USING WS-RAID WS-ALIVE
         CALL "Q3-BETWEEN-WAVES" USING WS-GROUPS WS-ALIVE WS-COOLDOWN WS-BETWEEN
     ELSE
         MOVE 0 TO WS-STARTED WS-BETWEEN
     END-IF
     CALL "Q3-RAID-STATUS" USING WS-DRAW WS-AT WS-STARTED WS-BETWEEN WS-ACTIVITY
     EVALUATE WS-ACTIVITY
         WHEN 1
             CALL "VM-ACT-SET" USING L-SLOT VA-PRE-RAID
         WHEN 2
             CALL "VM-ACT-SET" USING L-SLOT VA-RAID
     END-EVALUATE
*>   ResetRaidStatus (PRE_RAID and RAID).
     IF (VM-ACT(L-SLOT) = VA-PRE-RAID OR VM-ACT(L-SLOT) = VA-RAID) AND WS-ACTIVITY = 0
         CALL "Q3-RAID-RESET" USING WS-DRAW WS-AT WS-NO WS-NO-2 WS-RESET
         IF WS-RESET = 1
             CALL "VM-ACT-RESET" USING L-SLOT L-BABY
         END-IF
     END-IF
     GOBACK.
 END PROGRAM VL-CORE-RAID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-CORE-PANIC.
*> USING row, slot, baby: VillagerPanicTrigger and VillagerCalmDown (44 section 2.14). The hostile of nearest_hostile is looked up by its row and entity id; it scares within 6 blocks.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VLMEM.
 01 WS-HURT                 BINARY-LONG.
 01 WS-HURT-ENTITY          BINARY-LONG.
 01 WS-HOSTILE              BINARY-LONG.
 01 WS-QD                   BINARY-LONG.
 01 WS-QX                   BINARY-LONG.
 01 WS-QY                   BINARY-LONG.
 01 WS-QZ                   BINARY-LONG.
 01 WS-HROW                 BINARY-LONG.
 01 WS-HID                  BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-RUN                  BINARY-LONG.
 01 WS-ERASE                BINARY-LONG.
 01 WS-ACTIVE               BINARY-LONG.
 01 WS-SCARED               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 01 L-BABY                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-BABY.
     MOVE 0 TO WS-HURT WS-HURT-ENTITY WS-HOSTILE
     IF VM-SET(L-SLOT, MT-HURT-BY) = 1
         CALL "VM-HAS" USING L-SLOT MT-HURT-BY WS-HURT
     END-IF
     IF VM-SET(L-SLOT, MT-HURT-BY-ENTITY) = 1
         CALL "VM-HAS" USING L-SLOT MT-HURT-BY-ENTITY WS-HURT-ENTITY
     END-IF
     MOVE 1000000 TO WS-D2
     IF VM-SET(L-SLOT, MT-NEAREST-HOSTILE) = 1
         CALL "VM-GET" USING L-SLOT MT-NEAREST-HOSTILE WS-HOSTILE WS-QD WS-QX WS-QY WS-QZ WS-HROW WS-HID
         IF WS-HOSTILE = 1
             IF EN-ID(WS-HROW) = WS-HID AND EN-USED(WS-HROW) = 1 AND EN-HEALTH(WS-HROW) > 0
                 COMPUTE WS-D2 = (EN-X(WS-HROW) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-HROW) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-HROW) - EN-Z(L-ROW)) ** 2
             ELSE
                 CALL "VM-ERASE" USING L-SLOT MT-NEAREST-HOSTILE
                 MOVE 0 TO WS-HOSTILE
             END-IF
         END-IF
     END-IF
     IF VM-ACT(L-SLOT) = VA-PANIC
*>       VillagerCalmDown: still scared while hurt_by, hurt_by_entity, or a hostile within 6 blocks.
         CALL "Q3-CALM" USING WS-HURT WS-HURT-ENTITY WS-HOSTILE WS-D2 WS-SCARED
         IF WS-SCARED = 0
             CALL "VM-ERASE" USING L-SLOT MT-HURT-BY
             CALL "VM-ERASE" USING L-SLOT MT-HURT-BY-ENTITY
             CALL "VM-ERASE" USING L-SLOT MT-NEAREST-HOSTILE
             CALL "VM-ACT-RESET" USING L-SLOT L-BABY
         END-IF
         GOBACK
     END-IF
     CALL "Q3-PANIC-RUN" USING WS-HURT WS-HOSTILE WS-RUN
     IF WS-RUN = 1
         MOVE 0 TO WS-ACTIVE
         CALL "Q3-PANIC-START" USING WS-ACTIVE WS-ERASE
         IF WS-ERASE = 1
             CALL "VL-WALK-STOP" USING L-ROW L-SLOT
             CALL "VM-ERASE" USING L-SLOT MT-INTERACTION-TARGET
         END-IF
         CALL "VM-ACT-SET" USING L-SLOT VA-PANIC
     END-IF
     GOBACK.
 END PROGRAM VL-CORE-PANIC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-CORE-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VLMEM.
 01 WS-RAID                 BINARY-LONG.
 01 WS-PX                   BINARY-LONG.
 01 WS-PY                   BINARY-LONG.
 01 WS-PZ                   BINARY-LONG.
 01 WS-HIDE                 BINARY-LONG.
 01 WS-RADIUS               BINARY-LONG.
 01 WS-CLOSE                BINARY-LONG.
 01 WS-SPEED                FLOAT-LONG.
 01 WS-QD                   BINARY-LONG.
 01 WS-QX                   BINARY-LONG.
 01 WS-QY                   BINARY-LONG.
 01 WS-QZ                   BINARY-LONG.
 01 WS-HEARD                BINARY-LONG.
 01 WS-N1                   BINARY-LONG.
 01 WS-N2                   BINARY-LONG.
 01 WS-RAID-AT              BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-MEET                 BINARY-LONG.
 01 WS-ROLL                 FLOAT-LONG.
 01 WS-RING                 BINARY-LONG.
 01 WS-BELL                 BINARY-LONG.
 01 WS-WITHIN               BINARY-LONG.
 01 WS-KEY                  PIC X(32).
 01 WS-DRAW                 BINARY-LONG.
 01 WS-THOUSAND             BINARY-LONG VALUE 1000.
 01 WS-SALT                 BINARY-LONG VALUE 165.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 01 L-BABY                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-BABY.
     CALL "VL-CORE-PANIC" USING L-ROW L-SLOT L-BABY
*>   ReactToBell.
     IF VM-SET(L-SLOT, MT-HEARD-BELL-TIME) = 1 AND VM-ACT(L-SLOT) NOT = VA-HIDE
         COMPUTE WS-PX = FUNCTION INTEGER(EN-X(L-ROW))
         COMPUTE WS-PY = FUNCTION INTEGER(EN-Y(L-ROW))
         COMPUTE WS-PZ = FUNCTION INTEGER(EN-Z(L-ROW))
         CALL "RAID-AT" USING EN-DIM(L-ROW) WS-PX WS-PY WS-PZ WS-RAID
         MOVE 0 TO WS-RAID-AT
         IF WS-RAID > 0
             MOVE 1 TO WS-RAID-AT
         END-IF
         MOVE 1 TO WS-HEARD
         CALL "Q3-REACT-BELL" USING WS-HEARD WS-RAID-AT WS-HIDE
         IF WS-HIDE = 1
             CALL "VM-ACT-SET" USING L-SLOT VA-HIDE
             MOVE 0 TO VM-T(L-SLOT, TM-HIDE-COUNT)
         END-IF
     END-IF
     CALL "VL-CORE-RAID" USING L-ROW L-SLOT L-BABY
     EVALUATE VM-ACT(L-SLOT)
         WHEN VA-HIDE
             CALL "VL-CORE-HIDDEN" USING L-ROW L-SLOT L-BABY
             IF VM-ACT(L-SLOT) = VA-HIDE
                 MOVE 32 TO WS-RADIUS
                 MOVE 2 TO WS-CLOSE
                 MOVE 1.25 TO WS-SPEED
                 CALL "VL-CORE-HIDING" USING L-ROW L-SLOT WS-RADIUS WS-CLOSE WS-SPEED
             END-IF
         WHEN VA-RAID
             MOVE 24 TO WS-RADIUS
             MOVE 1 TO WS-CLOSE
             MOVE 1.4 TO WS-SPEED
             CALL "VL-CORE-HIDING" USING L-ROW L-SLOT WS-RADIUS WS-CLOSE WS-SPEED
         WHEN VA-PRE-RAID
*>           RingBell: one in 20 evaluations (a roll above 0.95), within 3 blocks of the meeting point that is a bell.
             CALL "VM-GET" USING L-SLOT MT-MEETING-POINT WS-MEET WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
             IF WS-MEET = 1
                 CALL "XP-RANDOM" USING WS-SALT WS-THOUSAND WS-DRAW
                 COMPUTE WS-ROLL = WS-DRAW / 1000
                 CALL "VL-BRAIN-DIST" USING L-ROW WS-QX WS-QY WS-QZ WS-D2
                 MOVE 0 TO WS-WITHIN
                 IF WS-D2 < 9 AND WS-QD = EN-DIM(L-ROW)
                     MOVE 1 TO WS-WITHIN
                 END-IF
                 CALL "PXI-KEY-AT" USING WS-QD WS-QX WS-QY WS-QZ WS-KEY
                 MOVE 0 TO WS-BELL
                 IF WS-KEY = "bell"
                     MOVE 1 TO WS-BELL
                 END-IF
                 CALL "Q3-RING-BELL" USING WS-MEET WS-ROLL WS-WITHIN WS-BELL WS-RING
                 IF WS-RING = 1
                     CALL "VL-BELL-RING" USING WS-QD WS-QX WS-QY WS-QZ
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM VL-CORE-TICK.
