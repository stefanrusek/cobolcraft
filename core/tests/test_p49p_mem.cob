*> Test of the villager brain memory store and activities (core/src/mob-vil-mem.cob, mob-vil-act.cob, mob-vil-walk.cob; lane 002-lane-p49p; docs/protocol/18 section 4.5, 44 part 3 section 2): a memory is
*> set, read and erased by type; it expires; the claimed points of interest read through the claim table (potential job site versus job_site by VL-POT); a released slot is empty; the activity follows
*> the schedule until a special one is entered and goes back by updateActivityFromSchedule; a walk target starts the path walk of the standard mob step and ends on arrival or on running out of time.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-P49P-MEM.
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
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-QD                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-N1                  BINARY-LONG.
 01 WS-N2                  BINARY-LONG.
 01 WS-TTL                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-BABY                BINARY-LONG VALUE 0.
 01 WS-SCHEDULE            BINARY-LONG.
 01 WS-ACTIVE              BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG VALUE 1.0.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-GY                  BINARY-LONG.
 01 WS-HOME                BINARY-LONG VALUE 2.
 01 WS-JOB                 BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "VT-FLAT" USING WS-PLAYER WS-FY
     COMPUTE WS-X = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     CALL "VT-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     MOVE 1000 TO CW-TICKS
     MOVE 3000 TO CW-TIME
*>   Absent until set; set with its value; erased.
     CALL "VM-GET" USING WS-SLOT MT-HIDING-PLACE WS-PRESENT WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
     MOVE "acceptance US15 18§4.5 a memory that was never set is absent" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VM-AT" USING WS-SLOT MT-HIDING-PLACE WS-DIM WS-X WS-Y WS-Z
     CALL "VM-GET" USING WS-SLOT MT-HIDING-PLACE WS-PRESENT WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
     MOVE "acceptance US15 18§4.5 a memory that was set is present" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 18§4.5 the memory holds the position it was given" TO WS-CASE
     MOVE WS-X TO WS-E
     MOVE WS-QX TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VM-ERASE" USING WS-SLOT MT-HIDING-PLACE
     CALL "VM-HAS" USING WS-SLOT MT-HIDING-PLACE WS-PRESENT
     MOVE "acceptance US15 18§4.5 an erased memory is absent" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   The numbers and the expiry: the memory is there for 599 ticks and gone at the 600th.
     MOVE 599 TO WS-TTL
     MOVE 77 TO WS-N1
     MOVE 5 TO WS-ID
     CALL "VM-PUT" USING WS-SLOT MT-GOLEM-DETECTED WS-DIM WS-X WS-Y WS-Z WS-N1 WS-ID WS-TTL
     MOVE 1598 TO CW-TICKS
     CALL "VM-GET" USING WS-SLOT MT-GOLEM-DETECTED WS-PRESENT WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
     MOVE "acceptance US15 44-3§4.3 golem_detected_recently is still there 598 ticks later" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 18§4.5 the memory returns its two numbers" TO WS-CASE
     COMPUTE WS-E = 77 * 100 + 5
     COMPUTE WS-O = WS-N1 * 100 + WS-N2
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE 1599 TO CW-TICKS
     CALL "VM-HAS" USING WS-SLOT MT-GOLEM-DETECTED WS-PRESENT
     MOVE "acceptance US15 44-3§4.3 and is gone when 599 ticks have passed" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   The claimed points of interest read through the claim table: home, then the job claim as potential job site and, once taken, as job_site.
     CALL "VM-AT" USING WS-SLOT MT-HOME WS-DIM WS-X WS-Y WS-Z
     CALL "VPX-OF" USING EN-ID(WS-ROW) WS-HOME WS-QD WS-QX WS-QY WS-QZ WS-PRESENT
     MOVE "acceptance US15 44-3§2.1 putting the home memory claims the point in the claim table" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VM-GET" USING WS-SLOT MT-HOME WS-PRESENT WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
     MOVE "acceptance US15 44-3§2.1 the home memory reads back its position" TO WS-CASE
     MOVE WS-Z TO WS-E
     MOVE WS-QZ TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VM-AT" USING WS-SLOT MT-POTENTIAL-JOB-SITE WS-DIM WS-X WS-Y WS-Z
     CALL "VM-HAS" USING WS-SLOT MT-POTENTIAL-JOB-SITE WS-PRESENT
     MOVE "acceptance US15 44-3§2.1 a claimed job site is the potential job site" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VM-HAS" USING WS-SLOT MT-JOB-SITE WS-PRESENT
     MOVE "acceptance US15 44-3§2.1 and not yet the job_site" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VM-AT" USING WS-SLOT MT-JOB-SITE WS-DIM WS-X WS-Y WS-Z
     CALL "VM-HAS" USING WS-SLOT MT-POTENTIAL-JOB-SITE WS-PRESENT
     MOVE "acceptance US15 44-3§2.6 once it is the job_site it is no potential job site" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VM-HAS" USING WS-SLOT MT-JOB-SITE WS-PRESENT
     MOVE "acceptance US15 44-3§2.6 the job_site is present" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VM-ERASE" USING WS-SLOT MT-JOB-SITE
     CALL "VPX-OF" USING EN-ID(WS-ROW) WS-JOB WS-QD WS-QX WS-QY WS-QZ WS-PRESENT
     MOVE "acceptance US15 44-3§2.5 erasing a claimed memory releases the ticket" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A slot that is released is empty.
     MOVE 9 TO VM-T(WS-SLOT, TM-WORK-CHECK)
     MOVE EN-ID(WS-ROW) TO WS-ID
     CALL "VL-REMOVE" USING WS-ID
     MOVE "acceptance US15 18§4.5 a released slot has no memory" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE VM-SET(WS-SLOT, MT-HOME) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 18§4.5 and no timers" TO WS-CASE
     MOVE VM-T(WS-SLOT, TM-WORK-CHECK) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   The activity: the schedule by day tick, a special activity stays, the reset goes back to the schedule.
     CALL "VT-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ROW WS-SLOT
     CALL "VT-DAY" USING WS-ZERO
     MOVE 3000 TO CW-TIME
     CALL "VM-ACT-TICK" USING WS-SLOT WS-BABY WS-SCHEDULE WS-ACTIVE
     MOVE "acceptance US15 19§22.3 at day tick 3000 the adult works" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-ACTIVE TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE VA-HIDE TO WS-O
     CALL "VM-ACT-SET" USING WS-SLOT VA-HIDE
     MOVE 13000 TO CW-TIME
     CALL "VM-ACT-TICK" USING WS-SLOT WS-BABY WS-SCHEDULE WS-ACTIVE
     MOVE "acceptance US15 44-3§2.11 a special activity stays while the schedule moves on" TO WS-CASE
     MOVE VA-HIDE TO WS-E
     MOVE WS-ACTIVE TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 19§22.3 and the schedule says rest at 13000" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE WS-SCHEDULE TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VM-ACT-RESET" USING WS-SLOT WS-BABY
     MOVE "acceptance US15 44-3§3.1 updateActivityFromSchedule puts the schedule's activity back" TO WS-CASE
     MOVE 3 TO WS-E
     MOVE VM-ACT(WS-SLOT) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   The walk target: set, it starts the path walk; arriving ends it.
     MOVE 2000 TO CW-TICKS
     COMPUTE WS-QX = WS-X + 10
     COMPUTE WS-QZ = WS-Z + 0
     MOVE 3 TO WS-CLOSE
     CALL "VL-WALK-SET" USING WS-ROW WS-SLOT WS-DIM WS-QX WS-Y WS-QZ WS-SPEED WS-CLOSE
     MOVE "acceptance US15 18§5.5 a walk target starts the walk to its block (dest x)" TO WS-CASE
     MOVE WS-QX TO WS-E
     MOVE EN-DEST-X(WS-ROW) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 18§5.5 and the walk has ticks to run" TO WS-CASE
     MOVE 200 TO WS-E
     MOVE EN-COOLDOWN(WS-ROW) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE EN-Y(WS-ROW) TO WS-GY
     CALL "VL-WALK-GY" USING WS-ROW WS-GY
     MOVE "acceptance US15 18§5.5 on the same floor the path search aims at the standing cell of the column (the villager's y)" TO WS-CASE
     MOVE WS-Y TO WS-E
     MOVE WS-GY TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     COMPUTE WS-N1 = WS-Y + 3
     CALL "VL-WALK-SET" USING WS-ROW WS-SLOT WS-DIM WS-QX WS-N1 WS-QZ WS-SPEED WS-CLOSE
     MOVE WS-Y TO WS-GY
     CALL "VL-WALK-GY" USING WS-ROW WS-GY
     MOVE "acceptance US15 18§5.5 a target 3 floors up: the path search aims at its y" TO WS-CASE
     MOVE WS-N1 TO WS-E
     MOVE WS-GY TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VL-WALK-SET" USING WS-ROW WS-SLOT WS-DIM WS-QX WS-Y WS-QZ WS-SPEED WS-CLOSE
     CALL "VL-WALK-TICK" USING WS-ROW WS-SLOT
     CALL "VM-HAS" USING WS-SLOT MT-WALK-TARGET WS-PRESENT
     MOVE "acceptance US15 18§5.5 10 blocks from the target the walk goes on" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     PERFORM 400 TIMES
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-ROW
     END-PERFORM
     CALL "VM-HAS" USING WS-SLOT MT-WALK-TARGET WS-PRESENT
     MOVE "acceptance US15 18§5.5 the villager walked there along a path and the walk target is gone" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     COMPUTE WS-N1 = FUNCTION INTEGER(EN-X(WS-ROW))
     MOVE "acceptance US15 18§5.5 and it is within 3 blocks of the target block" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-QX - WS-N1 <= 3 AND WS-N1 - WS-QX <= 3
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   A target nobody can reach: the walk runs out, the target goes and the cant_reach marker stays.
     COMPUTE WS-QX = WS-X + 30
     MOVE 1 TO WS-CLOSE
     CALL "VL-WALK-SET" USING WS-ROW WS-SLOT WS-DIM WS-QX WS-Y WS-QZ WS-SPEED WS-CLOSE
     MOVE 0 TO EN-COOLDOWN(WS-ROW)
     CALL "VL-WALK-TICK" USING WS-ROW WS-SLOT
     CALL "VM-HAS" USING WS-SLOT MT-WALK-TARGET WS-PRESENT
     MOVE "acceptance US15 44-3§2.17 a walk that ran out of time ends the walk target" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VM-HAS" USING WS-SLOT MT-CANT-REACH-SINCE WS-PRESENT
     MOVE "acceptance US15 44-3§2.17 and leaves cant_reach_walk_target_since" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-P49P-MEM.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
 COPY VILLTEST.
