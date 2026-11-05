*> Acceptance test, US8-2 core half (spec US8 scenario 2; tasks T508; standin-content §11.2, §11.3;
*> 09 §3.3 row 0x6A): a survival player's exhaustion grows with time (0.005 a tick), walking (0.02 a
*> block), running with the sprinting flag set (0.12 a block), jumping (0.3), attacking (0.15 a hit)
*> and breaking blocks (0.025 a survival break); whenever it reaches 5.0, 5.0 is taken off and the
*> food level falls by 1 (not below 0) with Set Health sent. Each activity case starts from a set
*> exhaustion just below 5.0 so that the activity alone crosses it; the observed text is the
*> drained Set Health packets followed by the exhaustion left, in thousandths. Alice (entity 1) and
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

     MOVE "acceptance US8-2 given a survival player with food 24 when 990 ticks pass (4.95 "
         & "exhaustion) then the food level has not yet fallen" TO TL-CASE
     MOVE 0 TO PL-EXHAUSTION(WS-ROW)
     MOVE 990 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     MOVE "exhaustion 4950" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-2 given a survival player when time passes (0.005 a tick) then the "
         & "food level falls by 1 once exhaustion reaches 5.0 and Set Health is sent" TO TL-CASE
     MOVE 20 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     MOVE "health 30 food 23 exhaustion 50" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-2 given a survival player with exhaustion 4.9 when they walk 10 blocks "
         & "(0.02 a block) then the food level falls by 1" TO TL-CASE
     MOVE 24 TO PL-FOOD(WS-ROW)
     MOVE 4.9 TO PL-EXHAUSTION(WS-ROW)
     MOVE 30.5 TO WS-FX
     PERFORM ALICE-MOVE
     MOVE "health 30 food 23 exhaustion 100" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-2 given a survival player with exhaustion 4.0 when they walk 10 blocks "
         & "then exhaustion grows by 0.2 and the food level stays" TO TL-CASE
     MOVE 4 TO PL-EXHAUSTION(WS-ROW)
     MOVE 20.5 TO WS-FX
     PERFORM ALICE-MOVE
     MOVE "exhaustion 4200" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-2 given a survival player with exhaustion 4.0 when they run 10 blocks "
         & "(sprinting flag set, 0.12 a block) then the food level falls by 1: running makes it "
         & "fall faster than walking" TO TL-CASE
     MOVE 1 TO WS-ACTION
     CALL "TEST-PLAYER-COMMAND" USING WS-ALICE WS-ACTION
     MOVE 23 TO PL-FOOD(WS-ROW)
     MOVE 4 TO PL-EXHAUSTION(WS-ROW)
     MOVE 30.5 TO WS-FX
     PERFORM ALICE-MOVE
     MOVE "health 30 food 22 exhaustion 200" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-2 given a survival player with food 0 when exhaustion reaches 5.0 then "
         & "5.0 is taken off and the food level stays 0 (no Set Health)" TO TL-CASE
     MOVE 2 TO WS-ACTION
     CALL "TEST-PLAYER-COMMAND" USING WS-ALICE WS-ACTION
     MOVE 0 TO PL-FOOD(WS-ROW)
     MOVE 4.9 TO PL-EXHAUSTION(WS-ROW)
     MOVE 20.5 TO WS-FX
     PERFORM ALICE-MOVE
     MOVE "exhaustion 100" TO TL-EXPECTED
     PERFORM CHECK

*>   Down onto greystone at (20, 100, 20), the fall start lowered so the landing does no damage.
     MOVE 24 TO PL-FOOD(WS-ROW)
     MOVE 20 TO WS-X
     MOVE 100 TO WS-Y
     MOVE 20 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 101 TO PL-FALL-START(WS-ROW)
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     PERFORM ALICE-MOVE
     CALL "TEST-DRAIN-HUNGER" USING WS-ALICE WS-TEXT

     MOVE "acceptance US8-2 given a survival player on the ground with exhaustion 4.8 when they "
         & "jump (0.3) then the food level falls by 1" TO TL-CASE
     MOVE 4.8 TO PL-EXHAUSTION(WS-ROW)
     MOVE 101.42 TO WS-FY
     MOVE 0 TO WS-FLAGS
     PERFORM ALICE-MOVE
     MOVE "health 30 food 23 exhaustion 100" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-2 given a survival player in the air when they move down then that is "
         & "not a jump" TO TL-CASE
     MOVE 4.8 TO PL-EXHAUSTION(WS-ROW)
     MOVE 101.2 TO WS-FY
     PERFORM ALICE-MOVE
     MOVE "exhaustion 4800" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     PERFORM ALICE-MOVE

     MOVE "acceptance US8-2 given a survival player with exhaustion 4.9 when they hit another "
         & "player (0.15) then the food level falls by 1" TO TL-CASE
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE 22.5 TO WS-FX
     MOVE 0 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-BOB WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-HUNGER" USING WS-ALICE WS-TEXT
     MOVE 23 TO PL-FOOD(WS-ROW)
     MOVE 4.9 TO PL-EXHAUSTION(WS-ROW)
     CALL "TEST-ATTACK" USING WS-ALICE PL-ENTITY-ID(CN-PLAYER(WS-BOB))
     MOVE "health 30 food 22 exhaustion 50" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US8-2 given a survival player with exhaustion 4.98 when they finish "
         & "breaking a block (0.025) then the food level falls by 1" TO TL-CASE
     MOVE 25 TO WS-X
     MOVE 25 TO WS-Z
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-ACTION
     PERFORM ACT
     MOVE 30 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-HUNGER" USING WS-ALICE WS-TEXT
     MOVE 22 TO PL-FOOD(WS-ROW)
     MOVE 4.98 TO PL-EXHAUSTION(WS-ROW)
     MOVE 3 TO WS-ACTION
     PERFORM ACT
     MOVE "health 30 food 21 exhaustion 5" TO TL-EXPECTED
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
