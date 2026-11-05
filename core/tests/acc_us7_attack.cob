*> Acceptance test, US7-5 and US7-2 core half for attacks (spec US7 scenarios 2 and 5, US7 edge case
*> "player combat is disabled"; tasks T491; standin-content §10.2 to §10.4; 09 §3.3 rows 0x01, 0x19,
*> 0x2B, 0x6A): an Attack on a player whose collision box is within 4.0 blocks of the attacker's eye
*> point does the attack damage of the attacker's held item (pry_bar 4, any other item 1, the bare
*> hand 1); the target is sent Damage Event (damage type 29 cobolcraft:player_attack, source ids =
*> attacker entity id + 1), Hurt Animation and Set Health, and the attacker, who sees it, Damage
*> Event and Hurt Animation. A target out of reach is not hit; with player combat off nothing is
*> damaged. Alice (entity 1) stands at (20.5, 101, 20.5), Bobby (entity 2) 2 blocks east of her, both
*> survival with the starting items (slot 0 greystone, slot 8 pry_bar).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US7-ATTACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-BOB-ID              BINARY-LONG VALUE 2.
 01 WS-SLOT                BINARY-LONG.
 01 WS-MOVE                BINARY-LONG VALUE 31.
 01 WS-FX                  FLOAT-LONG VALUE 20.5.
 01 WS-FY                  FLOAT-LONG VALUE 101.
 01 WS-FZ                  FLOAT-LONG VALUE 20.5.
 01 WS-BX                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE -90.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 1.
 01 WS-TICKS               BINARY-LONG VALUE 12.
 01 WS-TEXT                PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     PERFORM OPEN-AND-JOIN

     MOVE "acceptance US7-5 given Alice holds a pry_bar and aims at Bobby 2 blocks away when she "
         & "attacks then Bobby takes the §10.4 damage of the pry_bar, 4" TO TL-CASE
     MOVE 8 TO WS-SLOT
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     CALL "TEST-ATTACK" USING WS-ALICE WS-BOB-ID
     CALL "TEST-DRAIN-HEALTH" USING WS-BOB WS-TEXT
     MOVE "damage 2 type 29 source 2 | hurt 2 | health 26 food 24" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-2 given another player hits survival Bobby when player combat is "
         & "enabled then Alice, who sees him, sees that he was hurt" TO TL-CASE
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "damage 2 type 29 source 2 | hurt 2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-5 given Alice holds greystone (any other item) when she attacks Bobby "
         & "then he takes 1" TO TL-CASE
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 0 TO WS-SLOT
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     CALL "TEST-DRAIN-HEALTH" USING WS-BOB WS-TEXT
     CALL "TEST-ATTACK" USING WS-ALICE WS-BOB-ID
     CALL "TEST-DRAIN-HEALTH" USING WS-BOB WS-TEXT
     MOVE "damage 2 type 29 source 2 | hurt 2 | health 25 food 24" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-5 given Alice holds nothing (bare hand) when she attacks Bobby then he "
         & "takes 1" TO TL-CASE
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 0 TO PL-SLOT-COUNT(CN-PLAYER(WS-ALICE), 1) PL-SLOT-ITEM(CN-PLAYER(WS-ALICE), 1)
     CALL "TEST-DRAIN-HEALTH" USING WS-BOB WS-TEXT
     CALL "TEST-ATTACK" USING WS-ALICE WS-BOB-ID
     CALL "TEST-DRAIN-HEALTH" USING WS-BOB WS-TEXT
     MOVE "damage 2 type 29 source 2 | hurt 2 | health 24 food 24" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-5 given Bobby's box is 3.9 blocks from Alice's eye point when she "
         & "attacks then he is within reach and takes 1" TO TL-CASE
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 24.75 TO WS-BX
     CALL "TEST-MOVE" USING WS-BOB WS-MOVE WS-BX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-HEALTH" USING WS-BOB WS-TEXT
     CALL "TEST-ATTACK" USING WS-ALICE WS-BOB-ID
     CALL "TEST-DRAIN-HEALTH" USING WS-BOB WS-TEXT
     MOVE "damage 2 type 29 source 2 | hurt 2 | health 23 food 24" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-5 given Bobby's box is 4.1 blocks from Alice's eye point when she "
         & "attacks then he is out of reach and takes nothing" TO TL-CASE
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 24.95 TO WS-BX
     CALL "TEST-MOVE" USING WS-BOB WS-MOVE WS-BX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-HEALTH" USING WS-BOB WS-TEXT
     CALL "TEST-ATTACK" USING WS-ALICE WS-BOB-ID
     CALL "TEST-DRAIN-HEALTH" USING WS-BOB WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "US7 edge given player combat is disabled when Alice attacks Bobby with a pry_bar then "
         & "no damage is done" TO TL-CASE
     MOVE 0 TO CS-PLAYER-COMBAT
     PERFORM OPEN-AND-JOIN
     MOVE 8 TO WS-SLOT
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     CALL "TEST-ATTACK" USING WS-ALICE WS-BOB-ID
     CALL "TEST-DRAIN-HEALTH" USING WS-BOB WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Opens the world with CORE-SETTINGS; Alice joins and stands at (20.5, 101, 20.5) facing east,
*> Bobby joins and stands 2 blocks east of her; both are drained.
 OPEN-AND-JOIN.
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 22.5 TO WS-BX
     CALL "TEST-MOVE" USING WS-BOB WS-MOVE WS-BX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-HEALTH" USING WS-BOB WS-TEXT.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US7-ATTACK.

 COPY CORETEST.
