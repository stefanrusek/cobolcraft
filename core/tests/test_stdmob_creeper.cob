*> Implementation test (002-lane-mobs2, T4111; docs/protocol/20 section 6.1 Creeper): row 8 with 20 health; a creeper with a target within 3 blocks
*> swells by 1 each tick (stands still, no melee hit), the swell falls by 1 a tick when the target is gone or farther than 7 blocks, and at 30
*> it explodes with power 3 at its position (the creeper is removed without loot; the blast hurts the player and destroys the ground); the
*> viewers get Set Entity Data (entry 16, the swell direction) when the direction changes.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STDMOB-CREEPER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY PROTO.
 COPY BRWORLD.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-CREEPER-TYPE        BINARY-LONG.
 01 WS-CREEPER             BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BEFORE-STATE        BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-PADDED              PIC X(1030).
 01 WS-FOUND               BINARY-LONG.
 01 WS-HEALTH-TENTHS       BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-DIRT                BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-CY                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "BR-WORLD-READY"
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE "minecraft:creeper" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-CREEPER-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:dirt" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-DIRT = FUNCTION NUMVAL(WS-STATE-TEXT)
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE "N" TO TL-MODE

     CALL "STDMOB-INDEX" USING WS-CREEPER-TYPE WS-INDEX
     MOVE "test stdmob creeper: the creeper is row 8" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STDMOB-HEALTH" USING WS-CREEPER-TYPE WS-INDEX
     MOVE "test stdmob creeper: a creeper has 20 health" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A creeper 6 blocks away (beyond 3) walks up but does not swell.
     COMPUTE WS-X0 = WS-X + 6
     CALL "MOB-SPAWN" USING WS-DIM WS-CREEPER-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-CREEPER
     CALL "MOB-STEP" USING WS-CREEPER
     MOVE "test stdmob creeper: a creeper 6 blocks away does not swell" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-SWELL(WS-CREEPER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-CREEPER

*>   A creeper 2.5 blocks away swells 1 a tick, stands still and does not hit.
     COMPUTE WS-X0 = WS-X + 2.5
     PERFORM PLACE-GROUND
     CALL "MOB-SPAWN" USING WS-DIM WS-CREEPER-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-CREEPER
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         CALL "MOB-STEP" USING WS-CREEPER
     END-PERFORM
     MOVE "test stdmob creeper: after 10 ticks the swell is 10" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE EN-SWELL(WS-CREEPER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test stdmob creeper: a swelling creeper stands still" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(EN-X(WS-CREEPER) - WS-X0) < 0.001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test stdmob creeper: a creeper does not hit" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE PL-HEALTH(WS-PLAYER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-TEXT
     MOVE SPACES TO WS-PADDED
     STRING " " DELIMITED BY SIZE WS-TEXT DELIMITED BY SIZE INTO WS-PADDED
     MOVE 0 TO WS-FOUND
     INSPECT WS-PADDED TALLYING WS-FOUND FOR ALL " 101"
     MOVE "test stdmob creeper: the viewers got the swell direction (Set Entity Data)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FOUND > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The target leaves (farther than 7 blocks): the swell falls by 1 a tick.
     COMPUTE PL-X(WS-PLAYER) = WS-X0 - 12
     CALL "MOB-STEP" USING WS-CREEPER
     CALL "MOB-STEP" USING WS-CREEPER
     MOVE "test stdmob creeper: a target out of range lowers the swell by 1 a tick" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE EN-SWELL(WS-CREEPER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         CALL "MOB-STEP" USING WS-CREEPER
     END-PERFORM
     MOVE "test stdmob creeper: the swell does not go below 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-SWELL(WS-CREEPER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-CREEPER

*>   30 ticks of swelling: the explosion. The ground under the creeper goes, the player is hurt, the creeper is gone.
     MOVE WS-X TO PL-X(WS-PLAYER)
     COMPUTE WS-X0 = WS-X + 2.5
     PERFORM PLACE-GROUND
     CALL "MOB-SPAWN" USING WS-DIM WS-CREEPER-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-CREEPER
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X0)
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y) - 1
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-BEFORE-STATE
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 29
         CALL "MOB-STEP" USING WS-CREEPER
     END-PERFORM
     MOVE "test stdmob creeper: after 29 ticks it is still swelling" TO TL-CASE
     MOVE 29 TO TL-EXPECTED-N
     MOVE EN-SWELL(WS-CREEPER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MOB-STEP" USING WS-CREEPER
     MOVE "test stdmob creeper: the 30th tick removes the creeper" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-USED(WS-CREEPER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-HEALTH-TENTHS = PL-HEALTH(WS-PLAYER) * 10
     MOVE "test stdmob creeper: the blast hurt the player (some health is left or none)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HEALTH-TENTHS < 200
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE "test stdmob creeper: the block under the creeper is destroyed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-FREE" USING PB-BUFFER
     STOP RUN.
 PLACE-GROUND.
*>   A dirt block under the spot of the creeper and air in the two cells above it.
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X0)
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y) - 1
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-DIRT
     COMPUTE WS-CY = WS-BY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-AIR
     COMPUTE WS-CY = WS-BY + 2
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-CY WS-BZ WS-AIR.
 END PROGRAM TEST-STDMOB-CREEPER.
 COPY CORETEST.
