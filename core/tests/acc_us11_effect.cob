*> Acceptance test, US11-3 core half (spec US11 scenario 3; tasks T563; standin-content §14.6,
*> §10.2, §10.3, §9.5). The hailstorm is the kind with a gameplay effect: on every tick with Time
*> mod 80 = 0 while cobolcraft:main is thundering (the hailstorm skin: rain and thunder levels at full strength), every alive survival player (§9.5 step 4)
*> and every mob (step 6) that is exposed takes 1 damage of cause cobolcraft:hail (damage type 31,
*> no source). Exposed: the biome cell of its position has has_precipitation 1 (lowland and upland,
*> all of cobolcraft:main) and every cell of its column from floor(y + height) up to the top y (255)
*> is void. Alice (survival, entity 1, height 1.75) stands at the spawn point (4.5, 54, 8.5), column
*> (4, 8) open to the sky (§5.2: the marker pillar is at (8, 8)). The sodgrazer (entity 2, height
*> 0.9, health 8) stands on column (10, 13) (top 54). Drizzle and clear have no gameplay effect.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US11-EFFECT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY WEATHER.
 COPY ETIDS.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-KIND                BINARY-LONG.
 01 WS-TIME                BINARY-LONG VALUE 1000000.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STONE               BINARY-LONG VALUE 2.
 01 WS-TEXT                PIC X(4096).
 01 WS-E1                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS CS-DEFAULT-MODE

     MOVE "acceptance US11-3 given a hailstorm and survival Alice under the open sky when Time "
         & "reaches 80 then she takes 1 hail damage (type 31, no source)" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     PERFORM SET-HAIL
     MOVE 79 TO CW-TIME
     CALL "TEST-TICKS" USING WS-ONE
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE "damage 1 type 31 source 0 | hurt 1 | health 19 food 20" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US11-3 given a hailstorm when Time reaches 81 (not a multiple of 80) then "
         & "nothing happens" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     PERFORM SET-HAIL
     MOVE 80 TO CW-TIME
     CALL "TEST-TICKS" USING WS-ONE
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US11-3 given drizzle when Time reaches 80 then nothing happens (drizzle has "
         & "no gameplay effect)" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     PERFORM SET-DRIZZLE
     MOVE 79 TO CW-TIME
     CALL "TEST-TICKS" USING WS-ONE
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US11-3 given a hailstorm and a block high above Alice's column when Time "
         & "reaches 80 then she is not exposed and takes no damage" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     PERFORM SET-HAIL
     MOVE 4 TO WS-BX
     MOVE 200 TO WS-BY
     MOVE 8 TO WS-BZ
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE 79 TO CW-TIME
     CALL "TEST-TICKS" USING WS-ONE
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US11-3 given a hailstorm and creative Alice when Time reaches 80 then she "
         & "takes no damage" TO TL-CASE
     MOVE 1 TO CS-DEFAULT-MODE
     PERFORM OPEN-AND-JOIN
     MOVE 0 TO CS-DEFAULT-MODE
     PERFORM SET-HAIL
     MOVE 79 TO CW-TIME
     CALL "TEST-TICKS" USING WS-ONE
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US11-3 given a hailstorm and a sodgrazer under the open sky when Time "
         & "reaches 80 then it takes 1 hail damage (health 7) and Alice sees it hurt" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     PERFORM SPAWN-MOB
     PERFORM SET-HAIL
     MOVE 1 TO PL-MODE(1)
     MOVE 79 TO CW-TIME
     CALL "TEST-TICKS" USING WS-ONE
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE EN-HEALTH(WS-MOB) TO WS-E1
     STRING " | mob health " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE
         INTO WS-TEXT(FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) + 1:)
     MOVE "damage 2 type 31 source 0 | hurt 2 | mob health 7" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US11-3 given a hailstorm and a sodgrazer under a roof when Time reaches 80 "
         & "then it takes no damage (health 8)" TO TL-CASE
     PERFORM OPEN-AND-JOIN
     MOVE 100 TO WS-BY
     PERFORM VARYING WS-BX FROM 7 BY 1 UNTIL WS-BX > 13
         PERFORM VARYING WS-BZ FROM 10 BY 1 UNTIL WS-BZ > 16
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
         END-PERFORM
     END-PERFORM
     PERFORM SPAWN-MOB
     PERFORM SET-HAIL
     MOVE 1 TO PL-MODE(1)
     MOVE 79 TO CW-TIME
     CALL "TEST-TICKS" USING WS-ONE
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE EN-HEALTH(WS-MOB) TO WS-E1
     MOVE SPACES TO WS-TEXT
     STRING "mob health " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "mob health 8" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> The hailstorm is thunder at full strength (the skin of 33 section 4: both flags set, both levels 1); drizzle is rain only.
 SET-HAIL.
     MOVE WK-HAILSTORM TO WS-KIND
     CALL "WEATHER-SET-KIND" USING WS-KIND WS-TIME
     MOVE 1 TO CW-RAIN-LEVEL(1) CW-RAIN-LEVEL-OLD(1) CW-THUNDER-LEVEL(1) CW-THUNDER-LEVEL-OLD(1).

 SET-DRIZZLE.
     MOVE WK-DRIZZLE TO WS-KIND
     CALL "WEATHER-SET-KIND" USING WS-KIND WS-TIME
     MOVE 1 TO CW-RAIN-LEVEL(1) CW-RAIN-LEVEL-OLD(1)
     MOVE 0 TO CW-THUNDER-LEVEL(1) CW-THUNDER-LEVEL-OLD(1).

*> Opens the world; Alice joins at the spawn point and is drained.
 OPEN-AND-JOIN.
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE.

*> A sodgrazer on column (10, 13); everything sent so far is drained.
 SPAWN-MOB.
     MOVE ET-SODGRAZER TO WS-TYPE
     MOVE 10.5 TO WS-X
     MOVE 55 TO WS-Y
     MOVE 13.5 TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-MOB
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US11-EFFECT.

 COPY CORETEST.
