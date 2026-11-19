*> Acceptance test, the activities of the villager brain (docs/protocol/44 part 3 sections 2.10, 2.11, 2.11a, 2.12, 2.14, 5; 19 section 22.3; lane 002-lane-p49p, T35004): a hostile near a villager
*> puts it into PANIC and it calms down when the hostile is gone; ringing a bell makes the villagers within 32 blocks hear it and hide at home (HIDE) until 300 ticks have passed; a raid
*> that has not spawned its first wave puts the villagers into PRE_RAID (they walk to the bell), a wave under way into RAID, and the end of the raid gives the schedule back.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-VILLAGER-ACTIVITY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VLMEM.
 COPY RAIDSTATE.
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
 01 WS-V                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-PRESENT             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-HEARD               BINARY-LONG.
 01 WS-QD                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-N1                  BINARY-LONG.
 01 WS-N2                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "VT-FLAT" USING WS-PLAYER WS-FY
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-Y = WS-FY + 1
*>   The village: a bell at x0 + 2, a bed 8 blocks west of the villager's spot.
     COMPUTE WS-X = WS-X0 + 2
     MOVE "minecraft:bell" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z0 WS-KEY WS-PAIRS
     COMPUTE WS-X = WS-X0 - 6
     MOVE "minecraft:red_bed" TO WS-KEY
     MOVE "facing=north,occupied=false,part=head" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z0 WS-KEY WS-PAIRS
     CALL "VT-SCAN" USING WS-DIM WS-X0 WS-Z0
     COMPUTE WS-X = WS-X0 + 4
     CALL "VT-SPAWN" USING WS-DIM WS-X WS-Y WS-Z0 WS-V WS-S
     MOVE 1000 TO CW-TICKS
     MOVE 3000 TO CW-TIME
     CALL "VL-BRAIN" USING WS-V
*>   Panic: a zombie 5 blocks away; the sensor finds it and the brain panics.
     MOVE "minecraft:zombie" TO WS-KEY
     COMPUTE WS-X = WS-X0 + 9
     CALL "VT-MOB" USING WS-KEY WS-DIM WS-X WS-Y WS-Z0 WS-M
     MOVE 1020 TO CW-TICKS
     CALL "VL-FEAR-STEP" USING WS-V
     CALL "VL-BRAIN" USING WS-V
     MOVE "acceptance US15 44-3§2.14 a hostile within its distance puts the villager into PANIC" TO WS-CASE
     MOVE VA-PANIC TO WS-E
     MOVE VM-ACT(WS-S) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VM-HAS" USING WS-S MT-NEAREST-HOSTILE WS-PRESENT
     MOVE "acceptance US15 44-3§4.2 the sensor wrote nearest_hostile" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   The zombie goes far away: the next scan erases the memory and VillagerCalmDown gives the schedule back.
     COMPUTE EN-X(WS-M) = WS-X0 + 60
     MOVE 1040 TO CW-TICKS
     MOVE 0 TO EN-FLEE(WS-V)
     CALL "VL-FEAR-STEP" USING WS-V
     CALL "VL-BRAIN" USING WS-V
     MOVE "acceptance US15 44-3§2.14 with the hostile gone the villager calms down to the schedule (work)" TO WS-CASE
     MOVE VA-WORK TO WS-E
     MOVE VM-ACT(WS-S) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE 0 TO EN-HEALTH(WS-M)
*>   A player hits the villager: hurt_by for 40 ticks, PANIC, and the schedule again after them.
     MOVE 1050 TO CW-TICKS
     CALL "VL-HURT-BY" USING WS-V WS-PLAYER
     CALL "VM-HAS" USING WS-S MT-HURT-BY WS-PRESENT
     MOVE "acceptance US15 44-3§4.6 a villager hurt by a player has hurt_by" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VL-BRAIN" USING WS-V
     MOVE "acceptance US15 44-3§2.14 hurt_by puts the villager into PANIC" TO WS-CASE
     MOVE VA-PANIC TO WS-E
     MOVE VM-ACT(WS-S) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE 1091 TO CW-TICKS
     CALL "VL-BRAIN" USING WS-V
     MOVE "acceptance US15 44-3§2.14 40 ticks later hurt_by has expired and the villager calms down (work)" TO WS-CASE
     MOVE VA-WORK TO WS-E
     MOVE VM-ACT(WS-S) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   The bell is rung: the villager hears it (48 box, 32 blocks) and hides.
     COMPUTE WS-X = WS-X0 + 2
     MOVE 1100 TO CW-TICKS
     CALL "VL-BELL-RING" USING WS-DIM WS-X WS-Y WS-Z0
     CALL "VM-GET" USING WS-S MT-HEARD-BELL-TIME WS-PRESENT WS-QD WS-QX WS-QY WS-QZ WS-HEARD WS-N2
     MOVE "acceptance US15 44-3§2.11a the villager within 32 blocks hears the bell: heard_bell_time is the game tick" TO WS-CASE
     MOVE 1100 TO WS-E
     MOVE WS-HEARD TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VL-BRAIN" USING WS-V
     MOVE "acceptance US15 44-3§2.11 with no raid the villager that heard the bell hides" TO WS-CASE
     MOVE VA-HIDE TO WS-E
     MOVE VM-ACT(WS-S) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 250
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-V
     END-PERFORM
     CALL "VM-GET" USING WS-S MT-HIDING-PLACE WS-PRESENT WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
     MOVE "acceptance US15 44-3§2.10 the hiding place is the home bed" TO WS-CASE
     COMPUTE WS-E = WS-X0 - 6
     MOVE WS-QX TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     COMPUTE WS-DX = FUNCTION INTEGER(EN-X(WS-V)) - (WS-X0 - 6)
     MOVE "acceptance US15 44-3§2.10 the villager walked to its home along a path (within 3 blocks)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-DX >= -3 AND WS-DX <= 3
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE 1500 TO CW-TICKS
     CALL "VL-BRAIN" USING WS-V
     MOVE "acceptance US15 44-3§2.17 300 ticks after the bell was heard the hiding ends: the schedule's activity (work)" TO WS-CASE
     MOVE VA-WORK TO WS-E
     MOVE VM-ACT(WS-S) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VM-HAS" USING WS-S MT-HEARD-BELL-TIME WS-PRESENT
     MOVE "acceptance US15 44-3§2.17 and heard_bell_time is erased" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A raid that has not spawned its first wave: PRE_RAID (the gate is 1 in 20 per tick: it comes within 400 ticks).
     MOVE 1 TO RD-USED(1)
     MOVE 1 TO RD-STATUS(1)
     MOVE 0 TO RD-STARTED(1) RD-GROUPS(1)
     MOVE 300 TO RD-COOLDOWN(1)
     MOVE WS-DIM TO RD-DIM(1)
     MOVE WS-X0 TO RD-CX(1)
     MOVE WS-FY TO RD-CY(1)
     MOVE WS-Z0 TO RD-CZ(1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400 OR VM-ACT(WS-S) = VA-PRE-RAID
         ADD 1 TO CW-TICKS
         CALL "VL-BRAIN" USING WS-V
     END-PERFORM
     MOVE "acceptance US15 44-3§2.12 a raid that has not spawned its first wave puts the villager into PRE_RAID" TO WS-CASE
     MOVE VA-PRE-RAID TO WS-E
     MOVE VM-ACT(WS-S) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   In PRE_RAID it walks to the bell (meeting point, closeEnough 2).
     MOVE 8000 TO CW-TIME
     COMPUTE WS-X = WS-X0 - 6
     COMPUTE EN-X(WS-V) = WS-X + 0.5
     MOVE 0 TO EN-COOLDOWN(WS-V)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 500
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-V
     END-PERFORM
     COMPUTE WS-DX = FUNCTION INTEGER(EN-X(WS-V)) - (WS-X0 + 2)
     MOVE "acceptance US15 44-3§2.17 in PRE_RAID the villager walks to the bell (within 3 blocks)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-DX >= -3 AND WS-DX <= 3
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A wave under way: RAID.
     MOVE 1 TO RD-STARTED(1)
     MOVE 1 TO RD-GROUPS(1)
     MOVE "minecraft:pillager" TO WS-KEY
     COMPUTE WS-X = WS-X0 + 20
     CALL "VT-MOB" USING WS-KEY WS-DIM WS-X WS-Y WS-Z0 WS-M
     MOVE 1 TO RR-ID(1)
     MOVE EN-ID(WS-M) TO RR-ID(1)
     MOVE 1 TO RR-RAID(1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400 OR VM-ACT(WS-S) = VA-RAID
         ADD 1 TO CW-TICKS
         CALL "VL-BRAIN" USING WS-V
     END-PERFORM
     MOVE "acceptance US15 44-3§2.12 a wave under way puts the villager into RAID" TO WS-CASE
     MOVE VA-RAID TO WS-E
     MOVE VM-ACT(WS-S) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   The raid ends: ResetRaidStatus gives the schedule back.
     MOVE 3 TO RD-STATUS(1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 700 OR (VM-ACT(WS-S) NOT = VA-RAID AND VM-ACT(WS-S) NOT = VA-HIDE)
         ADD 1 TO CW-TICKS
         CALL "VL-BRAIN" USING WS-V
     END-PERFORM
     MOVE "acceptance US15 44-3§2.12 when the raid is over (and the bell's 300 ticks are over) the villager returns to the schedule (work at day tick 8000)" TO WS-CASE
     MOVE VA-WORK TO WS-E
     MOVE VM-ACT(WS-S) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE 0 TO RD-USED(1)
     MOVE 0 TO RR-ID(1)
     STOP RUN.
 END PROGRAM ACC-US15-VILLAGER-ACTIVITY.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
 COPY VILLTEST.
