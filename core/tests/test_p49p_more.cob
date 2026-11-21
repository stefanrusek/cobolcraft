*> Test of the remaining branches of the villager brain programs of lane 002-lane-p49p (T35011): crops other than wheat (VL-CROP-AT, VL-FARM-PLACE), the farm items a villager picks up
*> (VL-FARM-PICKUP), a farmer's cell dropped outside the work activity, an empty farmland cell as a harvest cell, the hiding place kept in memory (LocateHidingPlace, source 3), a stale
*> nearest_hostile, ResetRaidStatus, the potential job site given up after 1200 ticks, SetWalkTargetFromBlockMemory (a point beyond tooFar, a point given up after giveUpAfter) and the walk target
*> of another dimension or with closeness 0.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-P49P-MORE.
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
 01 WS-KIND                BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-KEY32               PIC X(32).
 01 WS-PLANTED             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM-KEY            PIC X(112).
 01 WS-ROW                 BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY2                 FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-ZERO-F              FLOAT-LONG VALUE 0.
 01 WS-ZERO-G              FLOAT-LONG VALUE 0.
 01 WS-ZERO-H              FLOAT-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 0.
 01 WS-BABY                BINARY-LONG VALUE 0.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-QD                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-HOME                BINARY-LONG VALUE 2.
 01 WS-N1                  BINARY-LONG.
 01 WS-N2                  BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG VALUE 1.0.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-DIM2                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TABLE.
    05 WS-CELL             OCCURS 27 TIMES.
       10 WS-CX            BINARY-LONG.
       10 WS-CY            BINARY-LONG.
       10 WS-CZ            BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-KEYS-DATA.
    05 FILLER              PIC X(16) VALUE "carrot".
    05 FILLER              PIC X(16) VALUE "potato".
    05 FILLER              PIC X(16) VALUE "beetroot_seeds".
    05 FILLER              PIC X(16) VALUE "beetroot".
    05 FILLER              PIC X(16) VALUE "bread".
    05 FILLER              PIC X(16) VALUE "bone_meal".
    05 FILLER              PIC X(16) VALUE "stick".
 01 WS-KEYS REDEFINES WS-KEYS-DATA.
    05 WS-KEY-OF           PIC X(16) OCCURS 7 TIMES.
 01 WS-TIMER-DATA.
    05 FILLER              BINARY-LONG VALUE 45.
    05 FILLER              BINARY-LONG VALUE 46.
    05 FILLER              BINARY-LONG VALUE 47.
    05 FILLER              BINARY-LONG VALUE 48.
    05 FILLER              BINARY-LONG VALUE 24.
    05 FILLER              BINARY-LONG VALUE 25.
    05 FILLER              BINARY-LONG VALUE 0.
 01 WS-TIMERS REDEFINES WS-TIMER-DATA.
    05 WS-TIMER-OF         BINARY-LONG OCCURS 7 TIMES.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "VT-FLAT" USING WS-PLAYER WS-FY
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-Y = WS-FY + 1
     CALL "VT-SPAWN" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-V WS-S
     MOVE 3000 TO CW-TIME
     MOVE 1000 TO CW-TICKS
*>   Crops: carrots, potatoes and beetroots are read with their maximum age; a farmer plants what it holds.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         COMPUTE WS-X = WS-X0 + WS-I
         MOVE SPACES TO WS-PAIRS
         MOVE "minecraft:farmland" TO WS-KEY
         CALL "VT-PLACE" USING WS-DIM WS-X WS-FY WS-Z0 WS-KEY WS-PAIRS
     END-PERFORM
     COMPUTE WS-X = WS-X0 + 1
     MOVE 2 TO VM-T(WS-S, TM-CARROT)
     CALL "VL-FARM-PLACE" USING WS-V WS-S WS-X WS-Y WS-Z0 WS-PLANTED
     CALL "VL-CROP-AT" USING WS-DIM WS-X WS-Y WS-Z0 WS-KIND WS-AGE WS-MAX WS-KEY32
     MOVE "test p49p more: a farmer holding carrots plants carrots (kind 2, max age 7)" TO WS-CASE
     COMPUTE WS-E = 2 * 100 + 7
     COMPUTE WS-O = WS-KIND * 100 + WS-MAX
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     COMPUTE WS-X = WS-X0 + 2
     MOVE 0 TO VM-T(WS-S, TM-CARROT)
     MOVE 2 TO VM-T(WS-S, TM-POTATO)
     CALL "VL-FARM-PLACE" USING WS-V WS-S WS-X WS-Y WS-Z0 WS-PLANTED
     CALL "VL-CROP-AT" USING WS-DIM WS-X WS-Y WS-Z0 WS-KIND WS-AGE WS-MAX WS-KEY32
     MOVE "test p49p more: potatoes (kind 3, max age 7)" TO WS-CASE
     COMPUTE WS-E = 3 * 100 + 7
     COMPUTE WS-O = WS-KIND * 100 + WS-MAX
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     COMPUTE WS-X = WS-X0 + 3
     MOVE 0 TO VM-T(WS-S, TM-POTATO)
     MOVE 2 TO VM-T(WS-S, TM-BEET-SEEDS)
     CALL "VL-FARM-PLACE" USING WS-V WS-S WS-X WS-Y WS-Z0 WS-PLANTED
     CALL "VL-CROP-AT" USING WS-DIM WS-X WS-Y WS-Z0 WS-KIND WS-AGE WS-MAX WS-KEY32
     MOVE "test p49p more: beetroots (kind 4, max age 3)" TO WS-CASE
     COMPUTE WS-E = 4 * 100 + 3
     COMPUTE WS-O = WS-KIND * 100 + WS-MAX
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A farmer with no seeds plants nothing; the empty farmland is a harvest cell (air over farmland).
     MOVE 0 TO VM-T(WS-S, TM-CARROT) VM-T(WS-S, TM-POTATO) VM-T(WS-S, TM-BEET-SEEDS) VM-T(WS-S, TM-SEEDS)
     MOVE WS-X0 TO WS-X
     MOVE "minecraft:farmland" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-FY WS-Z0 WS-KEY WS-PAIRS
     COMPUTE EN-X(WS-V) = WS-X0 + 0.5
     COMPUTE EN-Z(WS-V) = WS-Z0 + 0.5
     CALL "VL-FARM-PLACE" USING WS-V WS-S WS-X WS-Y WS-Z0 WS-PLANTED
     MOVE "test p49p more: with no seeds nothing is planted" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PLANTED TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VL-FARM-CELLS" USING WS-V WS-MODE WS-COUNT WS-TABLE
     MOVE "test p49p more: the villager stands over bare farmland at x0: an empty farmland cell is a harvest cell" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         IF WS-CY(WS-I) = WS-Y AND WS-CX(WS-I) = WS-X0
             MOVE 1 TO WS-O
         END-IF
     END-PERFORM
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   Farm items on the ground: each is picked up into its counter, the other is left.
     MOVE 1 TO WS-I
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         MOVE SPACES TO WS-ITEM-KEY
         MOVE WS-KEY-OF(WS-I) TO WS-ITEM-KEY
         CALL "CONTENT-ITEM-BY-KEY" USING WS-ITEM-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
         MOVE EN-X(WS-V) TO WS-FX
         MOVE EN-Y(WS-V) TO WS-FY2
         MOVE EN-Z(WS-V) TO WS-FZ
         CALL "GI-SPAWN" USING WS-DIM WS-FX WS-FY2 WS-FZ WS-ZERO-F WS-ZERO-G WS-ZERO-H WS-ITEM WS-ONE WS-DELAY WS-ROW
         MOVE 0 TO EN-DELAY(WS-ROW)
     END-PERFORM
     CALL "VL-FARM-PICKUP" USING WS-V WS-S
     MOVE "test p49p more: a carrot, a potato, beetroot seeds, a beetroot, bread and bone meal go into the counters" TO WS-CASE
     MOVE 6 TO WS-E
     MOVE 0 TO WS-O
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         IF VM-T(WS-S, WS-TIMER-OF(WS-I)) = 1
             ADD 1 TO WS-O
         END-IF
     END-PERFORM
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "test p49p more: a stick is not picked up (its ground item is still there)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-USED(WS-ROW) = 1 AND EN-ITEM-COUNT(WS-ROW) = 1
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A held cell outside the work activity is dropped.
     MOVE 1 TO VM-T(WS-S, TM-CELL-ON)
     CALL "VM-ACT-SET" USING WS-S VA-IDLE
     CALL "VL-FARM-STEP" USING WS-V WS-S
     MOVE "test p49p more: a farmer's cell is dropped when the activity is not work" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE VM-T(WS-S, TM-CELL-ON) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   LocateHidingPlace with no home: the stored hiding place is used (source 3) and walked to.
     CALL "VM-ERASE" USING WS-S MT-HOME
     COMPUTE WS-X = WS-X0 + 12
     CALL "VM-AT" USING WS-S MT-HIDING-PLACE WS-DIM WS-X WS-Y WS-Z0
     MOVE 1000 TO WS-N1
     CALL "VM-NOTE" USING WS-S MT-HEARD-BELL-TIME WS-N1
     CALL "VM-ACT-SET" USING WS-S VA-HIDE
     MOVE 1001 TO CW-TICKS
     CALL "VL-CORE-TICK" USING WS-V WS-S WS-BABY
     CALL "VM-GET" USING WS-S MT-WALK-TARGET WS-PRESENT WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
     MOVE "test p49p more: with no home the villager walks to the hiding place it remembers" TO WS-CASE
     MOVE WS-X TO WS-E
     MOVE WS-QX TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A nearest_hostile that is gone (row reused by another entity id) is forgotten.
     CALL "VM-ERASE" USING WS-S MT-HEARD-BELL-TIME
     CALL "VM-ERASE" USING WS-S MT-HIDING-PLACE
     CALL "VM-ACT-RESET" USING WS-S WS-BABY
     CALL "VL-WALK-STOP" USING WS-V WS-S
     MOVE "minecraft:zombie" TO WS-KEY
     COMPUTE WS-X = WS-X0 + 4
     CALL "VT-MOB" USING WS-KEY WS-DIM WS-X WS-Y WS-Z0 WS-M
     MOVE EN-ID(WS-M) TO WS-ID
     ADD 1000 TO WS-ID
     CALL "VM-NOTE-TTL" USING WS-S MT-NEAREST-HOSTILE WS-M WS-ID WS-NONE
     CALL "VL-CORE-TICK" USING WS-V WS-S WS-BABY
     CALL "VM-HAS" USING WS-S MT-NEAREST-HOSTILE WS-PRESENT
     MOVE "test p49p more: a nearest_hostile whose entity is gone is erased and does not panic" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-PRESENT + VM-ACT(WS-S) / 5
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE 0 TO EN-HEALTH(WS-M)
*>   ResetRaidStatus: a raid that is over (no bell heard) gives the schedule back to a villager in RAID.
     CALL "VM-ACT-SET" USING WS-S VA-RAID
     MOVE 1 TO RD-USED(1)
     MOVE 2 TO RD-STATUS(1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400 OR VM-ACT(WS-S) NOT = VA-RAID
         ADD 1 TO CW-TICKS
         CALL "VL-CORE-TICK" USING WS-V WS-S WS-BABY
     END-PERFORM
     MOVE "test p49p more: ResetRaidStatus gives the schedule back when the raid is over (work at 3000)" TO WS-CASE
     MOVE VA-WORK TO WS-E
     MOVE VM-ACT(WS-S) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE 0 TO RD-USED(1)
     CALL "VL-WALK-STOP" USING WS-V WS-S
*>   GoToPotentialJobSite gives up after 1200 ticks.
     COMPUTE WS-X = WS-X0 + 5
     CALL "VP-CLAIM" USING WS-DIM WS-X WS-Y WS-Z0 EN-ID(WS-V)
     MOVE 1 TO VL-POT(WS-S)
     MOVE 1 TO VM-T(WS-S, TM-POT-START)
     MOVE 5000 TO CW-TICKS
     CALL "VL-BRAIN-WALK" USING WS-V WS-S VA-WORK
     CALL "VM-HAS" USING WS-S MT-POTENTIAL-JOB-SITE WS-PRESENT
     MOVE "test p49p more: a potential job site walked to for 1200 ticks is given up" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A home beyond tooFar (150): the walk goes 15 blocks towards it.
     COMPUTE WS-X = WS-X0 + 200
     CALL "VM-AT" USING WS-S MT-HOME WS-DIM WS-X WS-Y WS-Z0
     COMPUTE EN-X(WS-V) = WS-X0 + 0.5
     COMPUTE EN-Z(WS-V) = WS-Z0 + 0.5
     CALL "VL-BRAIN-WALK" USING WS-V WS-S VA-REST
     CALL "VM-GET" USING WS-S MT-WALK-TARGET WS-PRESENT WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
     MOVE "test p49p more: a home 200 blocks away is approached by a walk target 15 blocks towards it" TO WS-CASE
     COMPUTE WS-E = WS-X0 + 15
     MOVE WS-QX TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A home that could not be reached for longer than giveUpAfter (1200) is released.
     CALL "VL-WALK-STOP" USING WS-V WS-S
     COMPUTE WS-X = WS-X0 + 20
     CALL "VM-AT" USING WS-S MT-HOME WS-DIM WS-X WS-Y WS-Z0
     MOVE 1 TO WS-N1
     CALL "VM-NOTE" USING WS-S MT-CANT-REACH-SINCE WS-N1
     MOVE 6000 TO CW-TICKS
     CALL "VL-BRAIN-WALK" USING WS-V WS-S VA-REST
     CALL "VM-HAS" USING WS-S MT-HOME WS-PRESENT
     MOVE "test p49p more: a home that could not be reached for 1200 ticks is released" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   Walk targets: closeness 0 counts as 1, another dimension ends the walk.
     MOVE 0 TO WS-CLOSE
     COMPUTE WS-X = WS-X0 + 1
     COMPUTE EN-X(WS-V) = WS-X0 + 1.5
     COMPUTE EN-Z(WS-V) = WS-Z0 + 0.5
     CALL "VL-WALK-SET" USING WS-V WS-S WS-DIM WS-X WS-Y WS-Z0 WS-SPEED WS-CLOSE
     CALL "VL-WALK-TICK" USING WS-V WS-S
     CALL "VM-HAS" USING WS-S MT-WALK-TARGET WS-PRESENT
     MOVE "test p49p more: with closeness 0 a villager at the block's centre has arrived" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     COMPUTE WS-DIM2 = WS-DIM + 1
     CALL "VL-WALK-SET" USING WS-V WS-S WS-DIM2 WS-X WS-Y WS-Z0 WS-SPEED WS-CLOSE
     CALL "VL-WALK-TICK" USING WS-V WS-S
     CALL "VM-HAS" USING WS-S MT-WALK-TARGET WS-PRESENT
     MOVE "test p49p more: a walk target in another dimension is dropped" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A farmer that is already walking somewhere does not pick a cell.
     MOVE "farmer" TO VL-PROF(WS-S)
     MOVE 0 TO VM-T(WS-S, TM-CELL-ON)
     MOVE 3 TO WS-CLOSE
     CALL "VL-WALK-SET" USING WS-V WS-S WS-DIM WS-X WS-Y WS-Z0 WS-SPEED WS-CLOSE
     CALL "VL-FARM-START" USING WS-V WS-S VA-WORK
     MOVE "test p49p more: a farmer with a walk target does not start on a cell" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE VM-T(WS-S, TM-CELL-ON) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-P49P-MORE.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
 COPY VILLTEST.
