*> Implementation test (T1747; docs/protocol/39-portals.md section 2): the entity-side portal state machine of a player. Standing in a lit
*> portal creates the process on the first tick (flag true, time 0); every later tick adds one to portalTime; a default-rule survival player
*> travels when the old portalTime reached 80 (the 82nd call here: the first creates the process, the 81st handlePortal moves her), a
*> creative player on the second call; leaving the portal decays portalTime by 4 per tick and the process ends at 0 (E7); after a transfer the
*> cooldown is 10, it is refilled while she touches a portal and counts down only after leaving and after Accept Teleportation. Needs
*> the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PORTAL-39-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY PORTAL.
 01 WS-SKIP                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-AXIS                BINARY-LONG VALUE 0.
 01 WS-W                   BINARY-LONG VALUE 2.
 01 WS-H                   BINARY-LONG VALUE 3.
 01 WS-FIRE                BINARY-LONG.
 01 WS-KEY-FIRE            PIC X(48) VALUE "fire".
 01 WS-PAIRS-NONE          PIC X(160) VALUE SPACES.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-CALLS               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   PIC -(9)9.
 01 WS-B                   PIC -(9)9.
 01 WS-C                   PIC -(9)9.
 01 WS-D                   PIC -(9)9.
 01 WS-E                   PIC -(9)9.
 01 WS-TEXT                PIC X(4096).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12 39§2 The entity-side portal state machine: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "PT-STATE" USING WS-KEY-FIRE WS-PAIRS-NONE WS-FIRE
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 0 TO PL-MODE(WS-ROW)
*>   A lit 2 x 3 portal in the nether, interior x 1..2, y 65..67 at z 0; Alice stands in the cell (1, 65, 0).
     MOVE DIM-STANDARD-NETHER TO WS-DIM
     MOVE 2 TO WS-X MOVE 65 TO WS-Y MOVE 0 TO WS-Z
     CALL "PT-FRAME" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H
     MOVE 1 TO WS-X
     CALL "BLOCK-CHANGE" USING WS-DIM WS-X WS-Y WS-Z WS-FIRE
     MOVE 1.5 TO WS-FX
     MOVE 65.0 TO WS-FY
     MOVE 0.5 TO WS-FZ
     CALL "DIM-SWITCH" USING WS-ROW WS-DIM WS-FX WS-FY WS-FZ
     CALL "TEST-ACCEPT-TELEPORT" USING WS-ALICE

*>   E7: 31 calls inside give portalTime 30; leaving, the next call still adds one (the flag set by the last sweep), then 4 are
*>   subtracted per tick: time 3 after the 39th call, the process is gone after the 40th.
     PERFORM 31 TIMES
         CALL "PORTAL-PLAYER-TICK" USING WS-ROW
     END-PERFORM
     MOVE PQ-PL-TIME(WS-ROW) TO WS-A
     MOVE 50.5 TO PL-X(WS-ROW)
     PERFORM 8 TIMES
         CALL "PORTAL-PLAYER-TICK" USING WS-ROW
     END-PERFORM
     MOVE PQ-PL-PROCESS(WS-ROW) TO WS-B
     MOVE PQ-PL-TIME(WS-ROW) TO WS-C
     CALL "PORTAL-PLAYER-TICK" USING WS-ROW
     MOVE PQ-PL-PROCESS(WS-ROW) TO WS-D
     MOVE PQ-PL-TIME(WS-ROW) TO WS-E
     MOVE SPACES TO TL-OBSERVED
     STRING "inside " FUNCTION TRIM(WS-A) ", after 8 calls out process " FUNCTION TRIM(WS-B) " time " FUNCTION TRIM(WS-C)
         ", after 9 process " FUNCTION TRIM(WS-D) " time " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 39§2 The entity-side portal state machine: E7 time 30 leaves a process that decays by 4 per tick "
         & "and is gone after 9 calls outside" TO TL-CASE
     MOVE "inside 30, after 8 calls out process 1 time 3, after 9 process 0 time 0" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 1.5 TO PL-X(WS-ROW)

     CALL "PORTAL-PLAYER-TICK" USING WS-ROW
     MOVE "acceptance US12 39§2 The entity-side portal state machine: 2.2 the first tick in a portal creates the process "
         & "(flag true, time 0) at the entry cell (1, 65, 0)" TO TL-CASE
     PERFORM DESCRIBE
     MOVE "dim 4 process 1 flag 1 time 0 cooldown 0 entry 1 65 0" TO TL-EXPECTED
     PERFORM CHECK

     CALL "PORTAL-PLAYER-TICK" USING WS-ROW
     MOVE "acceptance US12 39§2 The entity-side portal state machine: 2.3 the next tick adds one to portalTime and the sweep sets the flag again" TO TL-CASE
     PERFORM DESCRIBE
     MOVE "dim 4 process 1 flag 1 time 1 cooldown 0 entry 1 65 0" TO TL-EXPECTED
     PERFORM CHECK

     PERFORM 79 TIMES
         CALL "PORTAL-PLAYER-TICK" USING WS-ROW
     END-PERFORM
     MOVE "acceptance US12 39§2 The entity-side portal state machine: E7 after 81 calls (time 80) a default-rule survival "
         & "player has not travelled yet" TO TL-CASE
     PERFORM DESCRIBE
     MOVE "dim 4 process 1 flag 1 time 80 cooldown 0 entry 1 65 0" TO TL-EXPECTED
     PERFORM CHECK

     CALL "PORTAL-PLAYER-TICK" USING WS-ROW
     MOVE "acceptance US12 39§2 The entity-side portal state machine: E7 the 82nd call (old time 80 >= 80) starts the transfer: "
         & "she is in the overworld (dimension row 3) and the cooldown is 10" TO TL-CASE
     PERFORM DESCRIBE
     MOVE "dim 3 process 1 flag 0 time 81 cooldown 10 entry 1 65 0" TO TL-EXPECTED
     PERFORM CHECK

*>   She stands in the arrival portal: the cooldown is refilled each tick and nothing else happens; unacknowledged it does not count down.
     MOVE PQ-PL-CHANGING(WS-ROW) TO WS-A
     PERFORM 20 TIMES
         CALL "PORTAL-PLAYER-TICK" USING WS-ROW
     END-PERFORM
     MOVE PQ-PL-COOLDOWN(WS-ROW) TO WS-B
     MOVE PL-DIM(WS-ROW) TO WS-C
     MOVE SPACES TO TL-OBSERVED
     STRING "changing " FUNCTION TRIM(WS-A) " cooldown " FUNCTION TRIM(WS-B) " dim " FUNCTION TRIM(WS-C)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 39§2 The entity-side portal state machine: V9 before Accept Teleportation the cooldown does not count "
         & "down (changing 1) and she does not travel again" TO TL-CASE
     MOVE "changing 1 cooldown 10 dim 3" TO TL-EXPECTED
     PERFORM CHECK

     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     CALL "TEST-ACCEPT-TELEPORT" USING WS-ALICE
     PERFORM 30 TIMES
         CALL "PORTAL-PLAYER-TICK" USING WS-ROW
     END-PERFORM
     MOVE PQ-PL-COOLDOWN(WS-ROW) TO WS-B
     MOVE PL-DIM(WS-ROW) TO WS-C
     MOVE PQ-PL-CHANGING(WS-ROW) TO WS-A
     MOVE SPACES TO TL-OBSERVED
     STRING "changing " FUNCTION TRIM(WS-A) " cooldown " FUNCTION TRIM(WS-B) " dim " FUNCTION TRIM(WS-C)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 39§2 The entity-side portal state machine: V9 acknowledged and still touching the portal the cooldown is "
         & "kept at 10 on every tick and she stays in the overworld" TO TL-CASE
     MOVE "changing 0 cooldown 10 dim 3" TO TL-EXPECTED
     PERFORM CHECK

*>   Leaving the portal: far away in the overworld; the cooldown counts down 10 ticks, the process ends when its time decays to 0.
     MOVE 1000.5 TO PL-X(WS-ROW)
     MOVE 200 TO PL-Y(WS-ROW)
     MOVE 1000.5 TO PL-Z(WS-ROW)
     PERFORM 10 TIMES
         CALL "PORTAL-PLAYER-TICK" USING WS-ROW
     END-PERFORM
     MOVE PQ-PL-COOLDOWN(WS-ROW) TO WS-B
     MOVE PQ-PL-PROCESS(WS-ROW) TO WS-A
     MOVE PQ-PL-TIME(WS-ROW) TO WS-C
     MOVE SPACES TO TL-OBSERVED
     STRING "cooldown " FUNCTION TRIM(WS-B) " process " FUNCTION TRIM(WS-A) " time " FUNCTION TRIM(WS-C)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 39§2 The entity-side portal state machine: 2.3 ten ticks after leaving the cooldown is 0; the process "
         & "decayed while the cooldown held her in the portal (4 per tick from 81) and is gone" TO TL-CASE
     MOVE "cooldown 0 process 0 time 0" TO TL-EXPECTED
     PERFORM CHECK

*>   A creative player (transit time 0) in the nether portal travels on the second call.
     CALL "CORE-CONN-CLOSED" USING WS-ALICE
     MOVE 1 TO CS-DEFAULT-MODE
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 1 TO PL-MODE(WS-ROW)
     MOVE DIM-STANDARD-NETHER TO WS-DIM
     MOVE 1.5 TO WS-FX
     MOVE 65.0 TO WS-FY
     MOVE 0.5 TO WS-FZ
     CALL "DIM-SWITCH" USING WS-ROW WS-DIM WS-FX WS-FY WS-FZ
     CALL "TEST-ACCEPT-TELEPORT" USING WS-ALICE
     CALL "PORTAL-PLAYER-TICK" USING WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-A
     CALL "PORTAL-PLAYER-TICK" USING WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-B
     MOVE SPACES TO TL-OBSERVED
     STRING "after call 1 dim " FUNCTION TRIM(WS-A) ", after call 2 dim " FUNCTION TRIM(WS-B)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12 39§2 The entity-side portal state machine: V8 a creative player transfers on the second call "
         & "(the first creates the process)" TO TL-CASE
     MOVE "after call 1 dim 4, after call 2 dim 3" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 DESCRIBE.
     MOVE PL-DIM(WS-ROW) TO WS-A
     MOVE PQ-PL-PROCESS(WS-ROW) TO WS-B
     MOVE PQ-PL-FLAG(WS-ROW) TO WS-C
     MOVE PQ-PL-TIME(WS-ROW) TO WS-D
     MOVE PQ-PL-COOLDOWN(WS-ROW) TO WS-E
     MOVE SPACES TO WS-TEXT
     STRING "dim " FUNCTION TRIM(WS-A) " process " FUNCTION TRIM(WS-B) " flag " FUNCTION TRIM(WS-C) " time "
         FUNCTION TRIM(WS-D) " cooldown " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO WS-TEXT
     MOVE PQ-PL-EX(WS-ROW) TO WS-A
     MOVE PQ-PL-EY(WS-ROW) TO WS-B
     MOVE PQ-PL-EZ(WS-ROW) TO WS-C
     STRING FUNCTION TRIM(WS-TEXT) " entry " FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PORTAL-39-2.

 COPY CORETEST.
 COPY PORTALTEST.
