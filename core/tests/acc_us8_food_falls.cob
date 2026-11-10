*> Acceptance test, US8-2 core half (spec US8 scenario 2; tasks T508; 17 section 4.9; 09 §3.3 row
*> 0x6A): a survival player's exhaustion grows with running (sprinting flag set, 0.1 a block), jumping
*> (0.05), attacking (0.1 a hit) and breaking blocks (0.005 a survival break), not with time or
*> walking; a tick with 4.0 exhaustion spends it on saturation, then food, with Set Health sent when
*> something changed. The observed text is the drained Set Health packets followed by the
*> exhaustion left, in thousandths. Alice (entity 1) and
*> Bobby are survival; Alice moves in the air at y 120 (no ground, no fall), later stands on
*> greystone at (20, 100, 20).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US8-FOOD-FALLS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 2.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-ACTION              BINARY-LONG.
 01 WS-MOVE                BINARY-LONG VALUE 30.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG VALUE 20.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-TEXT                PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 20.5 TO WS-FX
     MOVE 120 TO WS-FY
     MOVE 0 TO WS-FLAGS
     PERFORM ALICE-MOVE
     CALL "TEST-DRAIN-HUNGER" USING WS-ALICE WS-TEXT

     MOVE "acceptance US8-2 given a survival player when 990 ticks pass then no exhaustion has "
         & "come from time (17 section 4.9)" TO TL-CASE
     MOVE 0 TO PL-EXHAUSTION(WS-ROW)
     MOVE 990 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     MOVE "exhaustion 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-2 given a survival player with exhaustion 4.0 and saturation when a "
         & "tick passes then 4.0 is spent on saturation and Set Health is sent" TO TL-CASE
     MOVE 4 TO PL-EXHAUSTION(WS-ROW)
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     MOVE "health 20 food 20 exhaustion 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-2 given a survival player when they walk 10 blocks then exhaustion "
         & "does not change" TO TL-CASE
     MOVE 1 TO PL-EXHAUSTION(WS-ROW)
     MOVE 30.5 TO WS-FX
     PERFORM ALICE-MOVE
     MOVE "exhaustion 1000" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-2 given a survival player when they run 10 blocks (sprinting flag set, "
         & "0.1 a block) then exhaustion grows by 1.0" TO TL-CASE
     MOVE 1 TO WS-ACTION
     CALL "TEST-PLAYER-COMMAND" USING WS-ALICE WS-ACTION
     MOVE 0 TO PL-EXHAUSTION(WS-ROW)
     MOVE 20.5 TO WS-FX
     PERFORM ALICE-MOVE
     MOVE "exhaustion 1000" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-2 given a survival player with food 0 and no saturation when "
         & "exhaustion reaches 4.0 and a tick passes then 4.0 is taken off and the food level "
         & "stays 0 (no Set Health)" TO TL-CASE
     MOVE 2 TO WS-ACTION
     CALL "TEST-PLAYER-COMMAND" USING WS-ALICE WS-ACTION
     MOVE 0 TO PL-FOOD(WS-ROW)
     MOVE 0 TO PL-SATURATION(WS-ROW)
     MOVE 4 TO PL-EXHAUSTION(WS-ROW)
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     MOVE "exhaustion 0" TO TL-EXPECTED
     PERFORM CHECK

*>   Down onto greystone at (20, 100, 20), the fall start lowered so the landing does no damage.
     MOVE 20 TO PL-FOOD(WS-ROW)
     MOVE 5 TO PL-SATURATION(WS-ROW)
     MOVE 20 TO WS-X
     MOVE 100 TO WS-Y
     MOVE 20 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 101 TO PL-FALL-START(WS-ROW)
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     PERFORM ALICE-MOVE
     CALL "TEST-DRAIN-HUNGER" USING WS-ALICE WS-TEXT

     MOVE "acceptance US8-2 given a survival player on the ground when they jump then "
         & "exhaustion grows by 0.05" TO TL-CASE
     MOVE 0 TO PL-EXHAUSTION(WS-ROW)
     MOVE 101.42 TO WS-FY
     MOVE 0 TO WS-FLAGS
     PERFORM ALICE-MOVE
     MOVE "exhaustion 50" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-2 given a survival player in the air when they move down then that is "
         & "not a jump" TO TL-CASE
     MOVE 1 TO PL-EXHAUSTION(WS-ROW)
     MOVE 101.2 TO WS-FY
     PERFORM ALICE-MOVE
     MOVE "exhaustion 1000" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     PERFORM ALICE-MOVE

     MOVE "acceptance US8-2 given a survival player when they hit another "
         & "player then exhaustion grows by 0.1" TO TL-CASE
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE 22.5 TO WS-FX
     MOVE 0 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-BOB WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-HUNGER" USING WS-ALICE WS-TEXT
     MOVE 0 TO PL-EXHAUSTION(WS-ROW)
     CALL "TEST-ATTACK" USING WS-ALICE PL-ENTITY-ID(CN-PLAYER(WS-BOB))
     MOVE "exhaustion 100" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-2 given a survival player when they finish "
         & "breaking a block then exhaustion grows by 0.005" TO TL-CASE
     MOVE 25 TO WS-X
     MOVE 25 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-ACTION
     PERFORM ACT
*>   31 ticks: by hand greystone is 0.0222 per tick and the server takes the stop at progress >= 0.7.
     MOVE 31 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HUNGER" USING WS-ALICE WS-TEXT
     MOVE 0 TO PL-EXHAUSTION(WS-ROW)
     MOVE 3 TO WS-ACTION
     PERFORM ACT
     MOVE "exhaustion 5" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 ALICE-MOVE.
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS.

 ACT.
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-ALICE WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ.

*> Drains Alice's hunger packets and appends the exhaustion left in thousandths.
 CHECK.
     CALL "TEST-DRAIN-HUNGER" USING WS-ALICE WS-TEXT
     COMPUTE WS-MILLI ROUNDED = PL-EXHAUSTION(WS-ROW) * 1000
     MOVE WS-MILLI TO WS-EDIT
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " exhaustion " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE FUNCTION TRIM(TL-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US8-FOOD-FALLS.

 COPY CORETEST.
