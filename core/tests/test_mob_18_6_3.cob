*> Acceptance test (US15, FR-036, SC-008; docs/protocol/18-mob-framework.md section 6.3, with doc 44 part 2 section 9): mob caps.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-6-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY XORO.
 COPY MOBSPAWN.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-SEED               BINARY-DOUBLE UNSIGNED.
 01 WS-MIRROR.
    05 WS-M-LO            BINARY-DOUBLE UNSIGNED.
    05 WS-M-HI            BINARY-DOUBLE UNSIGNED.
 01 WS-CAT               BINARY-LONG.
 01 WS-N                 BINARY-LONG.
 01 WS-CHUNKS            BINARY-LONG.
 01 WS-OK                BINARY-LONG.
 01 WS-CLOSE             BINARY-LONG.
 01 WS-PLAYERS.
    05 WS-P              OCCURS 64 TIMES.
       10 WS-HAS         BINARY-LONG.
       10 WS-PC          BINARY-LONG OCCURS 8 TIMES.
 PROCEDURE DIVISION.
     MOVE 1 TO WS-CAT
     MOVE 69 TO WS-N
     MOVE 289 TO WS-CHUNKS
     CALL "MS6-GLOBAL-CAP" USING WS-CAT WS-N WS-CHUNKS WS-OK
     MOVE "acceptance US15 18§6.3 Mob caps: 69 monsters under the cap of 70 with 289 chunks" TO WS-CASE
     COMPUTE WS-E = 1
     COMPUTE WS-O = WS-OK
     PERFORM CHECK-N
     MOVE 70 TO WS-N
     CALL "MS6-GLOBAL-CAP" USING WS-CAT WS-N WS-CHUNKS WS-OK
     MOVE "acceptance US15 18§6.3 Mob caps: 70 monsters reach the cap" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-OK
     PERFORM CHECK-N
     MOVE 144 TO WS-CHUNKS
     MOVE 34 TO WS-N
     CALL "MS6-GLOBAL-CAP" USING WS-CAT WS-N WS-CHUNKS WS-OK
     MOVE "acceptance US15 18§6.3 Mob caps: 144 chunks scale the cap to 70 x 144 div 289 = 34" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-OK
     PERFORM CHECK-N
     MOVE 33 TO WS-N
     CALL "MS6-GLOBAL-CAP" USING WS-CAT WS-N WS-CHUNKS WS-OK
     MOVE "acceptance US15 18§6.3 Mob caps: 33 monsters are under the scaled cap" TO WS-CASE
     COMPUTE WS-E = 1
     COMPUTE WS-O = WS-OK
     PERFORM CHECK-N
     MOVE 7 TO WS-CAT
     MOVE 289 TO WS-CHUNKS
     MOVE 19 TO WS-N
     CALL "MS6-GLOBAL-CAP" USING WS-CAT WS-N WS-CHUNKS WS-OK
     MOVE "acceptance US15 18§6.3 Mob caps: water ambient has a cap of 20" TO WS-CASE
     COMPUTE WS-E = 1
     COMPUTE WS-O = WS-OK
     PERFORM CHECK-N
     MOVE 20 TO WS-N
     CALL "MS6-GLOBAL-CAP" USING WS-CAT WS-N WS-CHUNKS WS-OK
     MOVE "acceptance US15 18§6.3 Mob caps: 20 water ambient mobs reach it" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-OK
     PERFORM CHECK-N
     MOVE 2 TO WS-CAT
     CALL "MS6-CAP-MAX" USING WS-CAT WS-N
     MOVE "acceptance US15 18§6.3 Mob caps: the creature cap is 10" TO WS-CASE
     COMPUTE WS-E = 10
     COMPUTE WS-O = WS-N
     PERFORM CHECK-N
     MOVE 0 TO WS-CLOSE
     INITIALIZE WS-PLAYERS
     CALL "MS6-LOCAL-CAP" USING WS-CAT WS-CLOSE WS-PLAYERS WS-OK
     MOVE "acceptance US15 18§6.3 Mob caps: no player close to the chunk means no spawn" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-OK
     PERFORM CHECK-N
     MOVE 1 TO WS-CLOSE
     CALL "MS6-LOCAL-CAP" USING WS-CAT WS-CLOSE WS-PLAYERS WS-OK
     MOVE "acceptance US15 18§6.3 Mob caps: a close player with no counters yet allows the spawn" TO WS-CASE
     COMPUTE WS-E = 1
     COMPUTE WS-O = WS-OK
     PERFORM CHECK-N
     MOVE 1 TO WS-HAS(1)
     MOVE 9 TO WS-PC(1 2)
     CALL "MS6-LOCAL-CAP" USING WS-CAT WS-CLOSE WS-PLAYERS WS-OK
     MOVE "acceptance US15 18§6.3 Mob caps: 9 creatures near the player are below the local cap of 10" TO WS-CASE
     COMPUTE WS-E = 1
     COMPUTE WS-O = WS-OK
     PERFORM CHECK-N
     MOVE 10 TO WS-PC(1 2)
     CALL "MS6-LOCAL-CAP" USING WS-CAT WS-CLOSE WS-PLAYERS WS-OK
     MOVE "acceptance US15 18§6.3 Mob caps: 10 creatures near the only close player stop the spawn" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-OK
     PERFORM CHECK-N
     MOVE 2 TO WS-CLOSE
     CALL "MS6-LOCAL-CAP" USING WS-CAT WS-CLOSE WS-PLAYERS WS-OK
     MOVE "acceptance US15 18§6.3 Mob caps: a second close player without counters allows it" TO WS-CASE
     COMPUTE WS-E = 1
     COMPUTE WS-O = WS-OK
     PERFORM CHECK-N
     MOVE 1 TO WS-HAS(2)
     MOVE 12 TO WS-PC(2 2)
     CALL "MS6-LOCAL-CAP" USING WS-CAT WS-CLOSE WS-PLAYERS WS-OK
     MOVE "acceptance US15 44-2§9 local cap: every close player at or above the cap stops the spawn" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-OK
     PERFORM CHECK-N

     STOP RUN.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-6-3.
