*> Acceptance test, US9-4 core half and the sodgrazer's flight (spec US9 scenario 4, US7 scenario 5;
*> tasks T538; standin-content §10.2, §10.4, §12.1, §12.3 Flee, §12.5, §9.1; 09 §3.3 Mobs and
*> Health rows): an Attack on a mob within reach does the held item's attack damage (pry_bar 4)
*> whatever the player-combat setting; the mob's viewers are sent Damage Event (player_attack 29,
*> source = the attacker's entity id + 1) and Hurt Animation on each hit; for 12 ticks after a hit
*> further damage is ignored. A damaged sodgrazer flees for 40 ticks at 0.1 blocks per tick
*> directly away from the attacker, facing that way. A mob whose health reaches 0 is removed
*> (Remove Entities) and its yield lies on the ground at its position as one ground item (sodgrazer:
*> 2 grazer_flank, item 12; abend: 1 dump_shard, item 15) with no motion.
*> Alice (entity 1, survival, holding the pry_bar of her starting items in slot 8) stands at (4.5,
*> 54, 8.5) on the flat ground of column x = 4 (§5.2: top 53); the mob (entity 2) stands 2 blocks
*> south of her at (4.5, 54, 10.5): the nearest point of its box is 1.7 blocks from her eye point.
*> The test runs at night, in windows without a spawn tick.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US9-DEFEAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY ETIDS.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-MOB-ID              BINARY-LONG VALUE 2.
 01 WS-SLOT                BINARY-LONG VALUE 8.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TICKS               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-MOVE                BINARY-LONG VALUE 31.
 01 WS-X                   FLOAT-LONG VALUE 4.5.
 01 WS-Y                   FLOAT-LONG VALUE 54.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 1.
 01 WS-R1                  PIC -(5)9.99.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-TEXT                PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE

     MOVE "acceptance US9-4 given Alice attacks a sodgrazer in reach with a pry_bar then it takes "
         & "4 of its 8 health and she sees Damage Event and Hurt Animation" TO TL-CASE
     MOVE ET-SODGRAZER TO WS-TYPE
     PERFORM OPEN-AND-JOIN
     CALL "TEST-ATTACK" USING WS-ALICE WS-MOB-ID
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     PERFORM DESCRIBE-MOB
     MOVE "health 4 | damage 2 type 29 source 2 | hurt 2" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-3 given the sodgrazer was hit when a tick passes then it flees directly "
         & "away from Alice at 0.1 per tick, facing away (yaw 0), for 40 ticks" TO TL-CASE
     CALL "TEST-TICKS" USING WS-ONE
     MOVE EN-FLEE(WS-ROW) TO WS-E1
     MOVE EN-YAW(WS-ROW) TO WS-E2
     COMPUTE WS-R1 ROUNDED = EN-Z(WS-ROW)
     MOVE SPACES TO WS-TEXT
     STRING "flee " FUNCTION TRIM(WS-E1) " yaw " FUNCTION TRIM(WS-E2) " z " FUNCTION TRIM(WS-R1)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE "flee 39 yaw 0 z 10.60" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-4 given the sodgrazer was hit 1 tick ago (hurt cooldown 12) when Alice "
         & "attacks again then the hit is ignored" TO TL-CASE
     CALL "TEST-ATTACK" USING WS-ALICE WS-MOB-ID
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     PERFORM DESCRIBE-MOB
     MOVE "health 4 |" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US9-4 given 12 ticks after the first hit when Alice hits the sodgrazer "
         & "again then its health reaches 0: she sees the hit, then its removal and its yield, 2 "
         & "grazer_flank, on the ground where it was (z 11.7 after fleeing 12 ticks)" TO TL-CASE
     MOVE 11 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     CALL "TEST-ATTACK" USING WS-ALICE WS-MOB-ID
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE "25 43 78(2) 1(3,1@4.50,54.00,11.70) 101(3=12x2)" TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US9-4 the defeated sodgrazer is gone from the world" TO TL-CASE
     CALL "TEST-FIND-ENTITY" USING WS-MOB-ID WS-ROW
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

     MOVE "acceptance US9-4 given an abend with 1 health left when Alice hits it then it is "
         & "removed and its yield, 1 dump_shard, lies where it was" TO TL-CASE
     MOVE ET-ABEND TO WS-TYPE
     PERFORM OPEN-AND-JOIN
     MOVE 1 TO EN-HEALTH(WS-ROW)
     CALL "TEST-ATTACK" USING WS-ALICE WS-MOB-ID
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE "25 43 78(2) 1(3,1@4.50,54.00,10.50) 101(3=15x1)" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US7-5 given player combat is disabled when Alice attacks a sodgrazer then "
         & "it is still hit (the setting is about players)" TO TL-CASE
     MOVE 0 TO CS-PLAYER-COMBAT
     MOVE ET-SODGRAZER TO WS-TYPE
     PERFORM OPEN-AND-JOIN
     CALL "TEST-ATTACK" USING WS-ALICE WS-MOB-ID
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     PERFORM DESCRIBE-MOB
     MOVE "health 4 | damage 2 type 29 source 2 | hurt 2" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Opens the world at night; survival Alice joins, stands at (4.5, 54, 8.5) and holds slot 8 (the
*> pry_bar); a mob of WS-TYPE (entity 2) appears at (4.5, 54, 10.5); Alice is drained.
 OPEN-AND-JOIN.
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE 8.5 TO WS-Z
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     MOVE 10.5 TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT.

*> WS-TEXT becomes "health <h> | " followed by its old content.
 DESCRIBE-MOB.
     MOVE EN-HEALTH(WS-ROW) TO WS-E3
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE SPACES TO WS-TEXT
     STRING "health " FUNCTION TRIM(WS-E3) " | " FUNCTION TRIM(TL-OBSERVED) DELIMITED BY SIZE
         INTO WS-TEXT.

 CHECK.
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US9-DEFEAT.

 COPY CORETEST.
