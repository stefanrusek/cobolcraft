*> Acceptance test, US7-6 core half and the US7 edge case of switching modes (spec US7 scenario 6;
*> tasks T498; FR-007; standin-content §10 preamble, §10.2 to §10.5): a creative player takes no
*> damage from any cause (falls, player attacks, and every cause of §10.3 through HEALTH-DAMAGE) and
*> is sent no Set Health; a player who switches from survival to creative while hurt keeps the stored
*> health, which neither changes nor recovers in creative, and after switching back it is the same
*> and recovers again. Alice and Bobby (entity 2) join; the game mode is changed by setting PL-MODE
*> (the set-mode command is US14).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US7-CREATIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY RULES.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-ALICE-ID            BINARY-LONG VALUE 1.
 01 WS-ROW                 BINARY-LONG.
 01 WS-MOVE                BINARY-LONG VALUE 30.
 01 WS-FX                  FLOAT-LONG VALUE 20.5.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG VALUE 20.5.
 01 WS-BX                  FLOAT-LONG VALUE 22.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-FLOOR-DIM           BINARY-LONG VALUE 1.
 01 WS-FLOOR-X             BINARY-LONG VALUE 20.
 01 WS-FLOOR-Y             BINARY-LONG VALUE 100.
 01 WS-FLOOR-Z             BINARY-LONG VALUE 20.
 01 WS-FLOOR-STATE         BINARY-LONG VALUE 2.
 01 WS-SLOT                BINARY-LONG VALUE 8.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG VALUE 3.
 01 WS-NO-ENTITY           BINARY-LONG VALUE 0.
 01 WS-NO-ATTACKER         BINARY-LONG VALUE 0.
 01 WS-TICKS               BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-TEXT                PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
*>   Greystone under Alice: a claim of the ground counts only with support (core/src/move-check.cob).
     CALL "WORLD-SET-BLOCK" USING WS-FLOOR-DIM WS-FLOOR-X WS-FLOOR-Y WS-FLOOR-Z WS-FLOOR-STATE
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-MOVE" USING WS-BOB WS-MOVE WS-BX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-HEALTH" USING WS-BOB WS-TEXT

     MOVE "acceptance US7-6 given a creative player when they fall 10 blocks then they take no "
         & "damage and are sent no health" TO TL-CASE
     PERFORM FALL-10
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-6 given a creative player when another player attacks them with a "
         & "pry_bar while player combat is on then they take no damage" TO TL-CASE
     MOVE 0 TO PL-MODE(CN-PLAYER(WS-BOB))
     MOVE 10 TO PL-SLOT-ITEM(CN-PLAYER(WS-BOB), 9)
     MOVE 1 TO PL-SLOT-COUNT(CN-PLAYER(WS-BOB), 9)
     CALL "TEST-HELD" USING WS-BOB WS-SLOT
     CALL "TEST-ATTACK" USING WS-BOB WS-ALICE-ID
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     PERFORM CHECK

     MOVE "acceptance US7-6 given a creative player when every cause of §10.3 would damage them "
         & "then their health stays 30 and nothing is sent" TO TL-CASE
     PERFORM VARYING WS-CAUSE FROM 1 BY 1 UNTIL WS-CAUSE > CAUSE-COUNT
         CALL "HEALTH-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-NO-ENTITY WS-NO-ATTACKER
     END-PERFORM
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE 30 TO WS-E1
     PERFORM CHECK-QUIET

     MOVE "US7 edge given a survival player hurt to 18 when they switch to creative and 100 "
         & "ticks pass then the stored health stays 18 (no recovery, nothing sent)" TO TL-CASE
     MOVE 0 TO PL-MODE(WS-ROW)
     MOVE 12 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     PERFORM FALL-10
     MOVE 1 TO PL-MODE(WS-ROW)
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE 100 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE 18 TO WS-E1
     PERFORM CHECK-QUIET

     MOVE "US7 edge given a hurt player in creative when they switch back to survival then the "
         & "health is the one they had, 18, and recovers again after 50 ticks" TO TL-CASE
     MOVE 0 TO PL-MODE(WS-ROW)
     MOVE 50 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "health 19 food 24" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Alice rises 10 blocks (on-ground false) and lands back at feet y 101 (on-ground true).
 FALL-10.
     MOVE 111 TO WS-FY
     MOVE 0 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS.

 *> Nothing was sent (WS-TEXT empty) and the stored health is WS-E1.
 CHECK-QUIET.
     MOVE SPACES TO TL-OBSERVED TL-EXPECTED
     STRING "sent [] health " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE PL-HEALTH(WS-ROW) TO WS-E1
     IF WS-TEXT = SPACES
         STRING "sent [] health " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         STRING "sent [" FUNCTION TRIM(WS-TEXT) "] health " FUNCTION TRIM(WS-E1)
             DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US7-CREATIVE.

 COPY CORETEST.
