*> The activity of a villager brain (docs/protocol/19 section 22.3 and 44 part 3 sections 2.12, 2.14, 3.1; lane 002-lane-p49p). The schedule (VIL-DAY-ACT) gives idle, work, meet, rest or play; the
*> special activities panic, pre_raid, raid and hide (VA- constants of VLMEM.cpy) are entered by the core behaviours (VillagerPanicTrigger, ReactToBell, SetRaidStatus) and left by the behaviours that
*> call updateActivityFromSchedule (VillagerCalmDown, SetHiddenState, ResetRaidStatus), so the active activity stays one of them until then.
*>   VM-ACT-TICK USING slot, baby, schedule out, active out     the schedule's activity now; the active one (VM-ACT) follows it unless it is a special one
*>   VM-ACT-SET USING slot, activity                           enter an activity
*>   VM-ACT-RESET USING slot, baby                             updateActivityFromSchedule: the active activity becomes the schedule's

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VM-ACT-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VLMEM.
 COPY CORESTATE.
 01 WS-DAY                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-BABY                  BINARY-LONG.
 01 L-SCHEDULE              BINARY-LONG.
 01 L-ACTIVE                BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-BABY L-SCHEDULE L-ACTIVE.
     COMPUTE WS-DAY = FUNCTION MOD(CW-TIME, 24000)
     CALL "VIL-DAY-ACT" USING WS-DAY L-BABY L-SCHEDULE
     IF VM-ACT(L-SLOT) < VA-PANIC
         MOVE L-SCHEDULE TO VM-ACT(L-SLOT)
     END-IF
     MOVE VM-ACT(L-SLOT) TO L-ACTIVE
     GOBACK.
 END PROGRAM VM-ACT-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VM-ACT-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VLMEM.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-ACT                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-ACT.
     MOVE L-ACT TO VM-ACT(L-SLOT)
     GOBACK.
 END PROGRAM VM-ACT-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VM-ACT-RESET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VLMEM.
 01 WS-SCHEDULE             BINARY-LONG.
 01 WS-ACTIVE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 01 L-BABY                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT L-BABY.
     MOVE VA-IDLE TO VM-ACT(L-SLOT)
     CALL "VM-ACT-TICK" USING L-SLOT L-BABY WS-SCHEDULE WS-ACTIVE
     GOBACK.
 END PROGRAM VM-ACT-RESET.
