*> Implementation test (002-lane-mobs; 20 section 7.1): the spider, row 7 of STDMOBS.cpy (health 16, movement speed 0.3, attack 2, follow range 16 from the
*> Mob base, no daylight burning). Its target goal starts only when the light at the spider is below 13 (brightness below 0.5): in daylight it is neutral
*> unless provoked, at night it takes a player in range as its target like a zombie does.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STDMOB-SPIDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY BRWORLD.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-LOOT-DIR            PIC X(1100) VALUE "core/tests/fixtures/stdmob-loot".
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-BLOCK               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-STONE               BINARY-LONG.
 01 WS-SPIDER-TYPE         BINARY-LONG.
 01 WS-SPIDER              BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "BR-WORLD-READY"
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:spider" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-SPIDER-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STONE = FUNCTION NUMVAL(WS-STATE-TEXT)
     MOVE "N" TO TL-MODE
     MOVE "test stdmob spider: the spider is row 7 with 16 health" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     CALL "STDMOB-INDEX" USING WS-SPIDER-TYPE WS-INDEX
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test stdmob spider: a spider has 16 health" TO TL-CASE
     MOVE 16 TO TL-EXPECTED-N
     CALL "STDMOB-HEALTH" USING WS-SPIDER-TYPE WS-INDEX
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A stone floor under the spider at the player's place (open sky above it).
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X) + 4
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y) - 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
     COMPUTE WS-X0 = WS-BX + 0.5
     COMPUTE WS-Y = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-Z = WS-BZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-SPIDER-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-SPIDER
*>   By day (sky light 15 at the spider) it takes no target, however near the player is.
     MOVE 6000 TO CW-TIME
     MOVE 0 TO EN-TARGET(WS-SPIDER)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE WS-X0 TO EN-X(WS-SPIDER)
         MOVE WS-Y TO EN-Y(WS-SPIDER)
         CALL "MOB-STEP" USING WS-SPIDER
     END-PERFORM
     MOVE "test stdmob spider: by day the spider takes no target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-SPIDER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   At night the sky light there is 4 (darkening 11): the spider takes the player as its target.
     MOVE 18000 TO CW-TIME
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE WS-X0 TO EN-X(WS-SPIDER)
         MOVE WS-Y TO EN-Y(WS-SPIDER)
         CALL "MOB-STEP" USING WS-SPIDER
     END-PERFORM
     MOVE "test stdmob spider: at night the spider targets the player" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-TARGET(WS-SPIDER) = WS-PLAYER
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Back in daylight a target is given up with probability 1 / 100 a tick: after 3000 ticks it is gone.
     MOVE 6000 TO CW-TIME
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3000 OR EN-TARGET(WS-SPIDER) = 0
         ADD 1 TO CW-TIME
         MOVE WS-X0 TO EN-X(WS-SPIDER)
         MOVE WS-Y TO EN-Y(WS-SPIDER)
         CALL "MOB-STEP" USING WS-SPIDER
     END-PERFORM
     MOVE "test stdmob spider: back in daylight it gives up the target" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-SPIDER) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STDMOB-SPIDER.
 COPY CORETEST.
