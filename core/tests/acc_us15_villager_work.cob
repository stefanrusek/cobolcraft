*> Acceptance test, a villager claims a job site, walks to it along a path, takes the profession and works at it (docs/protocol/44 part 3 sections 2.1, 2.5, 2.6, 2.7 and 19 section 22.4; lane
*> 002-lane-p49p, T35005): in the work activity a villager within 1.73 blocks of its job site starts working (last_worked_at_poi) and a work start restocks its trades; outside the work
*> activity it does not work.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-VILLAGER-WORK.
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
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-PRESENT             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-QD                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-N1                  BINARY-LONG.
 01 WS-N2                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "VT-FLAT" USING WS-PLAYER WS-FY
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-X = WS-X0 + 6
     MOVE "minecraft:lectern" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z0 WS-KEY WS-PAIRS
     CALL "VT-SCAN" USING WS-DIM WS-X0 WS-Z0
     CALL "VT-SPAWN" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-V WS-S
     MOVE 3000 TO CW-TIME
     MOVE 1000 TO CW-TICKS
*>   The villager claims the lectern, walks to it and becomes a librarian.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 800 OR VL-PROF(WS-S) = "librarian"
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-V
     END-PERFORM
     MOVE "acceptance US15 44-3§2.6 the villager walked to the lectern and became a librarian" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF VL-PROF(WS-S) = "librarian"
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VM-GET" USING WS-S MT-JOB-SITE WS-PRESENT WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
     MOVE "acceptance US15 44-3§2.6 and the lectern is its job_site" TO WS-CASE
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   Idle time (day tick 11500): no work.
     CALL "VL-ENSURE" USING WS-S
     MOVE 2 TO VL-O-USES(WS-S, 1)
     MOVE 0 TO VL-RESTOCKS(WS-S) VL-LAST-RESTOCK(WS-S)
     MOVE 11500 TO CW-TIME
     PERFORM 400 TIMES
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-V
     END-PERFORM
     CALL "VM-HAS" USING WS-S MT-LAST-WORKED WS-PRESENT
     MOVE "acceptance US15 44-3§2.7 outside the work activity the villager does not work" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   Work time: it works within 1.73 blocks of the lectern (one in two a 300 tick check) and the work start restocks.
     MOVE 3000 TO CW-TIME
     COMPUTE EN-X(WS-V) = WS-X0 + 5.5
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1500 OR WS-PRESENT = 1
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-V
         CALL "VM-HAS" USING WS-S MT-LAST-WORKED WS-PRESENT
     END-PERFORM
     MOVE "acceptance US15 44-3§2.7 in the work activity next to the lectern the villager works" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "VM-GET" USING WS-S MT-LAST-WORKED WS-PRESENT WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
     MOVE "acceptance US15 44-3§2.7 last_worked_at_poi is a tick of this run" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-N1 > 1000 AND WS-N1 <= CW-TICKS
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 19§22.4 the work start restocked the trades (uses 0)" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE VL-O-USES(WS-S, 1) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 19§22.4 and counted a restock today" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE VL-RESTOCKS(WS-S) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM ACC-US15-VILLAGER-WORK.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
 COPY VILLTEST.
