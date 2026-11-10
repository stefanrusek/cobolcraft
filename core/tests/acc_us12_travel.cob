*> Acceptance test, US12-1 core half (spec US12 scenario 1; tasks T580; standin-content §15.5, §15.2,
*> §14.4; 09 §3.3 Dimensions rows; wire-profile §3.3): Use Item On aimed at a goto_pad starts travel
*> between cobolcraft:main and cobolcraft:subroutine. The arrival point is in the column (X, Z) of the
*> pad used: on the highest block when it is a goto_pad, otherwise on a goto_pad placed above the
*> highest block; travel that would put t + 2 above the dimension's top does not happen. The
*> traveller keeps inventory, health, food and game mode, stops eating, has the fall start reset, and
*> is sent Respawn (data to keep 0x03) then the join sequence of the new dimension: abilities, held
*> slot, inventory, Set Health, spawn position, Set Time, the weather pair, Game Event 13, the chunk
*> batch and Player Position. A player who travelled in the last 20 ticks, or who is dead, does not.
*> Heights from the §5.2 and §15.2 formulas: main column (6, 12) has turf at 53, the Subroutine
*> column (6, 12) slag at 34; main column (20, -20) turf at 56.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US12-TRAVEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY WEATHER.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQUENCE            BINARY-LONG VALUE 0.
 01 WS-TWENTY              BINARY-LONG VALUE 20.
 01 WS-DRIZZLE             BINARY-LONG VALUE 2.
 01 WS-TIME                BINARY-LONG VALUE 100000.
 01 WS-INVENTORY           PIC X(288).
 01 WS-SAME                PIC X(4).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-E6                  PIC -(9)9.
 01 WS-F1                  PIC -(5)9.9.
 01 WS-F2                  PIC -(5)9.9.
 01 WS-F3                  PIC -(5)9.9.
 01 WS-F4                  PIC -(5)9.9.
 01 WS-TEXT                PIC X(4096).
 01 WS-TEXT2               PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-DEFAULT-MODE CS-HOSTILE-MOBS CS-WEATHER-CHANGES
     MOVE 1 TO CS-EXTRA-DIMENSIONS

     MOVE "acceptance US12-1 given survival Alice in cobolcraft:main using the goto_pad at (6, 54, "
         & "12) then she is sent Respawn and the join sequence of cobolcraft:subroutine, in order"
         TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE 20 TO PL-HEALTH(WS-ROW)
     MOVE 15 TO PL-FOOD(WS-ROW)
     MOVE 5 TO PL-EATING-ITEM(WS-ROW)
     MOVE PL-INVENTORY(WS-ROW) TO WS-INVENTORY
     MOVE DIM-MAIN TO WS-DIM
     MOVE 6 TO WS-X MOVE 54 TO WS-Y MOVE 12 TO WS-Z
     PERFORM PLACE-PAD
     PERFORM USE-PAD
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE "4 84 65 107 18 106 99 115 39 96 12 46x25 11 73" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12-1 then she is in cobolcraft:subroutine at (6.5, 36, 12.5) on a new "
         & "goto_pad above the slag at 34, facing as before, with the same inventory, health, food "
         & "and game mode, not eating, fall start reset" TO TL-CASE
     PERFORM DESCRIBE-ALICE
     MOVE "dim 2 at 6.5 36.0 12.5 yaw -90 pitch 0 health 20 food 15 mode 0 eating 0 fall 36.0 "
         & "inventory same pad 16 solid 1" TO TL-EXPECTED
     MOVE DIM-SUBROUTINE TO WS-DIM
     MOVE 35 TO WS-Y
     PERFORM APPEND-BLOCK
     PERFORM CHECK

     MOVE "acceptance US12-1 given Alice used a goto_pad in the last 20 ticks when she uses the "
         & "arrival goto_pad then she stays (only the Block Changed Ack)" TO TL-CASE
     PERFORM USE-PAD
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE "4" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12-1 given 20 ticks have passed when Alice uses the arrival goto_pad in the "
         & "Subroutine then she returns to cobolcraft:main standing on the goto_pad of the column "
         & "(top 54), with health and food unchanged" TO TL-CASE
     CALL "TEST-TICKS" USING WS-TWENTY
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     PERFORM USE-PAD
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "respawn cobolcraft:main mode 0 keep 3 | health 20 food 15 | position 6.5 55.0 12.5"
         TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12-1 no block was placed on arrival in cobolcraft:main: (6, 54, 12) is "
         & "still the only goto_pad and (6, 55, 12) is void" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE DIM-MAIN TO WS-DIM
     MOVE 54 TO WS-Y
     PERFORM APPEND-BLOCK
     MOVE 55 TO WS-Y
     PERFORM APPEND-BLOCK
     MOVE PL-DIM(WS-ROW) TO WS-E1
     PERFORM APPEND-DIM
     MOVE "pad 16 solid 1 pad 0 solid 0 dim 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12-1 given rain in cobolcraft:main when Alice travels to the Subroutine and back "
         & "then she is sent nothing in the Subroutine (no weather there) and the rain pair (1, 7, 8) back "
         & "in cobolcraft:main" TO TL-CASE
     CALL "WEATHER-SET-KIND" USING WS-DRIZZLE WS-TIME
     MOVE 1 TO CW-RAIN-LEVEL(DIM-MAIN)
     CALL "TEST-TICKS" USING WS-TWENTY
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE 54 TO WS-Y
     PERFORM USE-PAD
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-TICKS" USING WS-TWENTY
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE 35 TO WS-Y
     PERFORM USE-PAD
     CALL "TEST-DRAIN-WEATHER" USING WS-ALICE WS-TEXT
     MOVE WS-TEXT TO WS-TEXT2
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(TL-OBSERVED) " / " FUNCTION TRIM(WS-TEXT2) DELIMITED BY SIZE
         INTO WS-TEXT
     MOVE " / 1 0.0 | 7 1.0 | 8 0.0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12-1 given creative Alice when she uses a goto_pad then she travels too (either "
         & "game mode), and is sent no Set Health" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE 1 TO PL-MODE(WS-ROW)
     MOVE DIM-MAIN TO WS-DIM
     MOVE 6 TO WS-X MOVE 54 TO WS-Y MOVE 12 TO WS-Z
     PERFORM PLACE-PAD
     PERFORM USE-PAD
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "respawn cobolcraft:subroutine mode 1 keep 3 | position 6.5 36.0 12.5" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12-1 given a block at y 126 of the Subroutine column (20, -20) when Alice "
         & "uses the goto_pad at (20, 57, -20) then the arrival (t 127, t + 2 above 127) is refused: "
         & "she stays and nothing is placed" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE DIM-SUBROUTINE TO WS-DIM
     MOVE 20 TO WS-X MOVE 126 TO WS-Y MOVE -20 TO WS-Z
     MOVE 2 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE DIM-MAIN TO WS-DIM
     MOVE 57 TO WS-Y
     PERFORM PLACE-PAD
     PERFORM USE-PAD
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE DIM-SUBROUTINE TO WS-DIM
     MOVE 127 TO WS-Y
     PERFORM APPEND-BLOCK
     MOVE PL-DIM(WS-ROW) TO WS-E1
     PERFORM APPEND-DIM
     MOVE "4 pad 0 solid 0 dim 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12-1 given dead Alice when a Use Item On a goto_pad arrives then she stays"
         TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE DIM-MAIN TO WS-DIM
     MOVE 6 TO WS-X MOVE 54 TO WS-Y MOVE 12 TO WS-Z
     PERFORM PLACE-PAD
     MOVE PS-DEAD TO PL-STATE(WS-ROW)
     PERFORM USE-PAD
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE PL-DIM(WS-ROW) TO WS-E1
     PERFORM APPEND-DIM
     MOVE "4 dim 1" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Opens the world; Alice joins at the spawn point (night, so no sodgrazer spawns) and is drained.
 OPEN-AND-JOIN.
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW.

*> A goto_pad at (x, y, z) of WS-DIM.
 PLACE-PAD.
     MOVE TRAVEL-PAD-STATE TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT.

*> Use Item On the top face of (x, y, z).
 USE-PAD.
     ADD 1 TO WS-SEQUENCE
     CALL "TEST-USE-ON" USING WS-ALICE WS-X WS-Y WS-Z WS-FACE WS-SEQUENCE.

*> " pad <state> solid <0|1>": the block state at (x, y, z) of WS-DIM, and whether it is not void.
 APPEND-BLOCK.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-E1
     MOVE 0 TO WS-E2
     IF WS-STATE NOT = 0
         MOVE 1 TO WS-E2
     END-IF
     MOVE WS-TEXT TO WS-TEXT2
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-TEXT2) " pad " FUNCTION TRIM(WS-E1) " solid " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE FUNCTION TRIM(WS-TEXT) TO WS-TEXT2
     MOVE WS-TEXT2 TO WS-TEXT.

 APPEND-DIM.
     MOVE WS-TEXT TO WS-TEXT2
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-TEXT2) " dim " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-TEXT.

 DESCRIBE-ALICE.
     MOVE "diff" TO WS-SAME
     IF PL-INVENTORY(WS-ROW) = WS-INVENTORY
         MOVE "same" TO WS-SAME
     END-IF
     MOVE PL-DIM(WS-ROW) TO WS-E1
     COMPUTE WS-F1 ROUNDED = PL-X(WS-ROW)
     COMPUTE WS-F2 ROUNDED = PL-Y(WS-ROW)
     COMPUTE WS-F3 ROUNDED = PL-Z(WS-ROW)
     MOVE PL-YAW(WS-ROW) TO WS-E2
     MOVE PL-PITCH(WS-ROW) TO WS-E3
     MOVE PL-HEALTH(WS-ROW) TO WS-E4
     MOVE PL-FOOD(WS-ROW) TO WS-E5
     MOVE PL-EATING-ITEM(WS-ROW) TO WS-E6
     COMPUTE WS-F4 ROUNDED = PL-FALL-START(WS-ROW)
     MOVE SPACES TO WS-TEXT
     STRING "dim " FUNCTION TRIM(WS-E1) " at " FUNCTION TRIM(WS-F1) " " FUNCTION TRIM(WS-F2) " "
         FUNCTION TRIM(WS-F3) " yaw " FUNCTION TRIM(WS-E2) " pitch " FUNCTION TRIM(WS-E3)
         " health " FUNCTION TRIM(WS-E4) " food " FUNCTION TRIM(WS-E5) " mode " PL-MODE(WS-ROW)
         " eating " FUNCTION TRIM(WS-E6) " fall " FUNCTION TRIM(WS-F4) " inventory " WS-SAME
         DELIMITED BY SIZE INTO WS-TEXT.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US12-TRAVEL.

 COPY CORETEST.
