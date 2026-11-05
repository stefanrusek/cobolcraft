*> Acceptance test, US7-4 core half (spec US7 scenario 4; tasks T495; standin-content §10.6, §10.7;
*> data-model §6; 09 §3.3 rows 0x45, 0x54, 0x0C, §3.2 row 0x7C): when a survival player's health
*> reaches 0 the player is sent Player Combat Kill carrying the cause, every player receives the death
*> message as System Chat, every non-empty inventory slot becomes a ground item at the feet + 0.5
*> with the §10.6 motion and pickup delay 30 and the inventory is empty; after Client Command
*> PERFORM_RESPAWN the player is sent Respawn to cobolcraft:main (data to keep 0x00) and the join
*> stream, and is at the world spawn with full health and food. A player who disconnects while dead
*> is dead again on the next join, where they left (the stored state "as they left it", data-model
*> §6; US12-3), and is shown the death screen. Alice (entity 1) and Bobby (entity
*> 2) are survival with the starting items (slots 0 to 9); Alice's health is set to 2 and she falls
*> 10 blocks onto greystone at (20, 100, 20).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US7-DEATH-RESPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-CAROL               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 20.
 01 WS-Y                   BINARY-LONG VALUE 100.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-STATE               BINARY-LONG VALUE 2.
 01 WS-MOVE                BINARY-LONG VALUE 30.
 01 WS-FX                  FLOAT-LONG VALUE 20.5.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG VALUE 20.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-ACTION              BINARY-LONG VALUE 0.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-R1                  PIC -(4)9.9(3).
 01 WS-R2                  PIC -(4)9.9(3).
 01 WS-R3                  PIC -(4)9.9(3).
 01 WS-TEXT                PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 2 TO PL-HEALTH(WS-ROW)
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 111 TO WS-FY
     MOVE 0 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-HEALTH" USING WS-BOB WS-TEXT
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS

     MOVE "acceptance US7-4 given a survival player's health reaches zero when they die then "
         & "they are sent Player Combat Kill carrying the cause, the death message" TO TL-CASE
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "damage 1 type 1 source 0 | hurt 1 | health 0 food 24 | kill 1 cobolcraft.death.fall("
         & "Alice) | chat cobolcraft.death.fall(Alice)" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-4 given a survival player dies when the death message is sent then "
         & "every other player receives it as System Chat" TO TL-CASE
     CALL "TEST-DRAIN-HEALTH" USING WS-BOB WS-TEXT
     MOVE "damage 1 type 1 source 0 | hurt 1 | chat cobolcraft.death.fall(Alice)"
         TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-4 given a survival player dies then the player is dead" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE PS-DEAD TO TL-EXPECTED-N
     MOVE PL-STATE(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US7-4 given a survival player dies then the inventory is empty (§10.6: "
         & "nothing is kept)" TO TL-CASE
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         ADD PL-SLOT-COUNT(WS-ROW, WS-I) TO WS-SUM
     END-PERFORM
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SUM TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

     MOVE "acceptance US7-4 given a survival player dies then slot 0 (64 greystone) lies on the "
         & "ground as one item at the feet + 0.5 with motion (-0.1, 0.2, -0.1) and pickup delay 30"
         TO TL-CASE
     MOVE 3 TO WS-ENTITY
     PERFORM DESCRIBE-ITEM
     MOVE "item 2 x 64 at 20.500 101.500 20.500 motion -0.100 0.200 -0.100 delay 30"
         TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-4 given a survival player dies then slot 9 (the trowel) lies on the "
         & "ground with motion (0.02, 0.2, -0.06) and pickup delay 30, the tenth and last item"
         TO TL-CASE
     MOVE 12 TO WS-ENTITY
     PERFORM DESCRIBE-ITEM
     MOVE "item 11 x 1 at 20.500 101.500 20.500 motion 0.020 0.200 -0.060 delay 30"
         TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-4 given a dead player when they choose to respawn then they are sent "
         & "Respawn to cobolcraft:main with data to keep 0x00, full health and food and the "
         & "world spawn position" TO TL-CASE
     CALL "TEST-CLIENT-COMMAND" USING WS-ALICE WS-ACTION
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "respawn cobolcraft:main mode 0 keep 0 | health 30 food 24 | position 4.5 54.0 8.5"
         TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-4 given a dead player when they respawn then they are alive in "
         & "cobolcraft:main at the world spawn with health 30, food 24, survival, the inventory "
         & "empty and the starting items not given again" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     MOVE PL-STATE(WS-ROW) TO WS-E1
     MOVE PL-DIM(WS-ROW) TO WS-E2
     COMPUTE WS-R1 ROUNDED = PL-X(WS-ROW)
     COMPUTE WS-R2 ROUNDED = PL-Y(WS-ROW)
     COMPUTE WS-R3 ROUNDED = PL-Z(WS-ROW)
     STRING "state " FUNCTION TRIM(WS-E1) " dim " FUNCTION TRIM(WS-E2) " at "
         FUNCTION TRIM(WS-R1) " " FUNCTION TRIM(WS-R2) " " FUNCTION TRIM(WS-R3)
         DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     MOVE PL-HEALTH(WS-ROW) TO WS-E1
     MOVE PL-FOOD(WS-ROW) TO WS-E2
     MOVE PL-MODE(WS-ROW) TO WS-E3
     STRING " health " FUNCTION TRIM(WS-E1) " food " FUNCTION TRIM(WS-E2) " mode "
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         ADD PL-SLOT-COUNT(WS-ROW, WS-I) TO WS-SUM
     END-PERFORM
     MOVE WS-SUM TO WS-E1
     STRING " items " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED POINTER WS-PTR
     MOVE "state 1 dim 1 at 4.500 54.000 8.500 health 30 food 24 mode 0 items 0"
         TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US7-4 given a player who disconnects while dead when they join again then "
         & "they are dead with health 0 where they left and are shown the death screen (Player "
         & "Combat Kill)"
         TO TL-CASE
     MOVE "Carol" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CAROL
     MOVE CN-PLAYER(WS-CAROL) TO WS-ROW
     MOVE 1 TO PL-HEALTH(WS-ROW)
     MOVE 111 TO WS-FY
     MOVE 0 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-CAROL WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-CAROL WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "CORE-CONN-CLOSED" USING WS-CAROL
     CALL "TEST-JOIN-UNDRAINED" USING WS-NAME WS-NAME-LENGTH WS-CAROL
     MOVE CN-PLAYER(WS-CAROL) TO WS-ROW
     CALL "TEST-DRAIN-HEALTH" USING WS-CAROL WS-TEXT
     MOVE PL-ENTITY-ID(WS-ROW) TO WS-E1
     MOVE SPACES TO TL-EXPECTED
     STRING "health 0 food 24 | position 20.5 101.0 20.5 | kill " FUNCTION TRIM(WS-E1)
         " cobolcraft.death.fall(Carol)" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US7-4 given a player who rejoined dead when they have loaded then they "
         & "are dead and can respawn with full health" TO TL-CASE
     MOVE PL-STATE(WS-ROW) TO WS-E1
     CALL "TEST-CLIENT-COMMAND" USING WS-CAROL WS-ACTION
     MOVE PL-HEALTH(WS-ROW) TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "state " FUNCTION TRIM(WS-E1) " then health " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "state 2 then health 30" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Describes the ground item with network entity id WS-ENTITY into WS-TEXT.
 DESCRIBE-ITEM.
     CALL "TEST-FIND-ENTITY" USING WS-ENTITY WS-I
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE EN-ITEM(WS-I) TO WS-E1
     MOVE EN-ITEM-COUNT(WS-I) TO WS-E2
     COMPUTE WS-R1 ROUNDED = EN-X(WS-I)
     COMPUTE WS-R2 ROUNDED = EN-Y(WS-I)
     COMPUTE WS-R3 ROUNDED = EN-Z(WS-I)
     STRING "item " FUNCTION TRIM(WS-E1) " x " FUNCTION TRIM(WS-E2) " at " FUNCTION TRIM(WS-R1)
         " " FUNCTION TRIM(WS-R2) " " FUNCTION TRIM(WS-R3) DELIMITED BY SIZE INTO WS-TEXT
         POINTER WS-PTR
     COMPUTE WS-R1 ROUNDED = EN-VX(WS-I)
     COMPUTE WS-R2 ROUNDED = EN-VY(WS-I)
     COMPUTE WS-R3 ROUNDED = EN-VZ(WS-I)
     MOVE EN-DELAY(WS-I) TO WS-E3
     STRING " motion " FUNCTION TRIM(WS-R1) " " FUNCTION TRIM(WS-R2) " " FUNCTION TRIM(WS-R3)
         " delay " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US7-DEATH-RESPAWN.

 COPY CORETEST.
