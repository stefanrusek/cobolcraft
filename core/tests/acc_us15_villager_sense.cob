*> Acceptance test, the golem_detected sensor of the villager brain (docs/protocol/44 part 3 sections 2.18 and 4.3; lane 002-lane-p49p, T35009): a sensor scans on its interval (a draw of
*> nextInt(200) ticks first, then every 200), an iron golem within 16 blocks sets golem_detected_recently for 599 ticks (and the golem-summoning rule's VL-GOLEM-UNTIL), no golem sets nothing, and
*> a golem that leaves lets the memory run out.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-VILLAGER-SENSE.
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
 01 WS-G                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-I                   BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "VT-FLAT" USING WS-PLAYER WS-FY
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-Y = WS-FY + 1
     CALL "VT-SPAWN" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-V WS-S
     MOVE "minecraft:iron_golem" TO WS-KEY
     COMPUTE WS-X = WS-X0 + 30
     CALL "VT-MOB" USING WS-KEY WS-DIM WS-X WS-Y WS-Z0 WS-G
     MOVE 3000 TO CW-TIME
     MOVE 1000 TO CW-TICKS
*>   The golem is 30 blocks away: nothing in 400 ticks.
     PERFORM 400 TIMES
         ADD 1 TO CW-TICKS
         CALL "VL-BRAIN" USING WS-V
     END-PERFORM
     CALL "VM-HAS" USING WS-S MT-GOLEM-DETECTED WS-PRESENT
     MOVE "acceptance US15 44-3§4.3 a golem 30 blocks away is not detected" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   It comes within 10 blocks: the next scan (at most 200 ticks) sets the memory.
     COMPUTE EN-X(WS-G) = WS-X0 + 10
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200 OR WS-PRESENT = 1
         ADD 1 TO CW-TICKS
         CALL "VL-BRAIN" USING WS-V
         CALL "VM-HAS" USING WS-S MT-GOLEM-DETECTED WS-PRESENT
     END-PERFORM
     MOVE "acceptance US15 44-3§4.3 a golem within 16 blocks is detected within one interval of 200 ticks" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 44-3§4.3 golem_detected_recently lasts 599 ticks (VL-GOLEM-UNTIL)" TO WS-CASE
     COMPUTE WS-E = CW-TICKS + 599
     MOVE VL-GOLEM-UNTIL(WS-S) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE CW-TICKS TO WS-FIRST
*>   The golem is gone: the memory is not renewed and runs out.
     MOVE 0 TO EN-HEALTH(WS-G)
     COMPUTE CW-TICKS = WS-FIRST + 600
     CALL "VL-BRAIN" USING WS-V
     CALL "VM-HAS" USING WS-S MT-GOLEM-DETECTED WS-PRESENT
     MOVE "acceptance US15 44-3§4.3 with the golem gone the memory runs out after 599 ticks" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-PRESENT TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM ACC-US15-VILLAGER-SENSE.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
 COPY VILLTEST.
