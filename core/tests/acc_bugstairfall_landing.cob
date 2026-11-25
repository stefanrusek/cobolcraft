*> Acceptance test of CC-0011 core half (travelling down stairs or an incline fast deals fall damage on the ground; docs/protocol 18 section 3 "Entity.move moves
*> along y, then x and z ... onGround is set when the vertical movement was blocked while moving down"; 30-8 14.1: the server takes the packet's on-ground flag and
*> calls doCheckFallDamage with it). A client lands first and then walks on in the same tick, so on a step narrower than its stride the landing tick's final
*> position is already off the step: the claim is supported by the column the player left at the new height. The claim counts as ground there, the fall start
*> is the landing height and a descent of six one-block steps (landing claims whose final positions all stride off their step) deals no fall damage. A claim in
*> the air with no support at either position stays refused as ground (acc_f2us7_onground_claim). Alice is a survival player (stand-in set, box 0.7 wide).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGSTAIRFALL-LANDING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-STATE               BINARY-LONG VALUE 2.
 01 WS-MOVE                BINARY-LONG VALUE 30.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG VALUE 20.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-HP                  PIC 99.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
*>   Seven steps of full blocks, one lower each: step j is the cell (20 + j, 100 - j, 20), its top at 101 - j.
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 6
         COMPUTE WS-X = 20 + WS-J
         COMPUTE WS-Y = 100 - WS-J
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     END-PERFORM
     MOVE 20.9 TO WS-FX
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     PERFORM MOVE-ALICE
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS

*>   The first stride: the air packet over the column of step 1 (x 21.9, feet 100.55), then the landing on step 1 (top 100) with the final position 0.5 further, over
*>   the cell x 22 at feet 100, where there is only air under the feet.
     MOVE 21.9 TO WS-FX
     MOVE 100.55 TO WS-FY
     MOVE 0 TO WS-FLAGS
     PERFORM MOVE-ALICE
     MOVE 22.4 TO WS-FX
     MOVE 100 TO WS-FY
     MOVE 1 TO WS-FLAGS
     PERFORM MOVE-ALICE
     MOVE "acceptance bugstairfall given a landing claim whose final position strides off the step when the move is taken then it counts as ground and the fall start is the landing height" TO TL-CASE
     MOVE "ground 1 start 100000" TO TL-EXPECTED
     PERFORM CHECK

*>   Five more strides, each one step lower; the last claim lands on step 6 (top 95), 6 blocks under the first step; then Alice stands on it.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 5
         COMPUTE WS-FX = 21.9 + WS-K
         COMPUTE WS-FY = 100.55 - WS-K
         MOVE 0 TO WS-FLAGS
         PERFORM MOVE-ALICE
         COMPUTE WS-FX = 22.4 + WS-K
         COMPUTE WS-FY = 100 - WS-K
         MOVE 1 TO WS-FLAGS
         PERFORM MOVE-ALICE
     END-PERFORM
     MOVE 26.5 TO WS-FX
     MOVE 95 TO WS-FY
     MOVE 1 TO WS-FLAGS
     PERFORM MOVE-ALICE
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
     MOVE "acceptance bugstairfall given six landing claims down six one-block steps then the player stands on the last step with full health (no fall damage)" TO TL-CASE
     MOVE "ground 1 start 95000 health 20" TO TL-EXPECTED
     PERFORM CHECK-HEALTH
     STOP RUN.

 MOVE-ALICE.
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS.

 CHECK.
     COMPUTE WS-MILLI ROUNDED = PL-FALL-START(WS-ROW) * 1000
     MOVE WS-MILLI TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING "ground " PL-ON-GROUND(WS-ROW) " start " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-HEALTH.
     COMPUTE WS-MILLI ROUNDED = PL-FALL-START(WS-ROW) * 1000
     MOVE WS-MILLI TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     COMPUTE WS-HP = PL-HEALTH(WS-ROW)
     STRING "ground " PL-ON-GROUND(WS-ROW) " start " FUNCTION TRIM(WS-EDIT) " health " WS-HP DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-BUGSTAIRFALL-LANDING.

 COPY CORETEST.
