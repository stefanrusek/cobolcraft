*> Implementation test (002-lane-mobs, T4003; 18 sections 4.2 and 5.5): a chasing zombie follows a path (STDMOB-HEAD) instead of walking straight at its
*> target. On a stone platform with a wall across the middle and a gap at one end, a zombie on one side and the player on the other goes round the wall
*> through the gap and reaches the player (the platform is built in the test world with standard states).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STDMOB-FOLLOW.
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
 01 WS-ZOMBIE-TYPE         BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-XLO                 BINARY-LONG.
 01 WS-XHI                 BINARY-LONG.
 01 WS-ZLO                 BINARY-LONG.
 01 WS-ZHI                 BINARY-LONG.
 01 WS-ZHI3                BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Y3                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-HEALTH-TENTHS       BINARY-LONG.
 01 WS-ZOMBIE-ROW                 BINARY-LONG VALUE 6.
 01 WS-TX                  BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-ARRIVED             BINARY-LONG.
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
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZOMBIE-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STONE = FUNCTION NUMVAL(WS-STATE-TEXT)
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 40
     COMPUTE WS-XLO = WS-CX - 4
     COMPUTE WS-XHI = WS-CX + 4
     COMPUTE WS-ZLO = WS-CZ - 4
     COMPUTE WS-ZHI = WS-CZ + 4
     COMPUTE WS-ZHI3 = WS-CZ + 3
     COMPUTE WS-Y1 = WS-FLOOR + 1
     COMPUTE WS-Y3 = WS-FLOOR + 3
     PERFORM VARYING WS-X FROM WS-XLO BY 1 UNTIL WS-X > WS-XHI
         PERFORM VARYING WS-Z FROM WS-ZLO BY 1 UNTIL WS-Z > WS-ZHI
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FLOOR WS-Z WS-STONE
         END-PERFORM
     END-PERFORM
*>   The wall across the middle (x = centre), z from centre - 4 to centre + 3, 3 high: the gap is the column z = centre + 4.
     PERFORM VARYING WS-Z FROM WS-ZLO BY 1 UNTIL WS-Z > WS-ZHI3
         PERFORM VARYING WS-Y FROM WS-Y1 BY 1 UNTIL WS-Y > WS-Y3
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y WS-Z WS-STONE
         END-PERFORM
     END-PERFORM
*>   The player stands east of the wall, the zombie west of it at the same z.
     COMPUTE PL-X(WS-PLAYER) = WS-CX + 3.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-CZ + 0.5
     COMPUTE WS-FX = WS-CX - 3 + 0.5
     COMPUTE WS-FY = WS-FLOOR + 1
     COMPUTE WS-FZ = WS-CZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-ZOMBIE-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ZOMBIE
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400
         ADD 1 TO CW-TIME
         MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
         CALL "MOB-STEP" USING WS-ZOMBIE
     END-PERFORM
     COMPUTE WS-HEALTH-TENTHS = PL-HEALTH(WS-PLAYER) * 10
     MOVE "N" TO TL-MODE
     MOVE "test stdmob follow: the zombie went round the wall and is east of it" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-X(WS-ZOMBIE) > WS-CX + 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test stdmob follow: and it hit the player" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HEALTH-TENTHS < 200
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The recalculation delay grows with the distance: 4 to 10 ticks, plus 5 beyond 16 blocks and plus 10 beyond 32.
     COMPUTE WS-TX = WS-CX + 20
     MOVE 0 TO EN-PATH-TICKS(WS-ZOMBIE)
     CALL "STDMOB-HEAD" USING WS-ZOMBIE WS-ZOMBIE-ROW WS-TX WS-Y1 WS-CZ WS-HX WS-HZ WS-ARRIVED
     MOVE "test stdmob follow: a destination 20 blocks away: a delay of 9 to 15 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-PATH-TICKS(WS-ZOMBIE) >= 9 AND EN-PATH-TICKS(WS-ZOMBIE) <= 15
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-TX = WS-CX + 40
     MOVE 0 TO EN-PATH-TICKS(WS-ZOMBIE)
     CALL "STDMOB-HEAD" USING WS-ZOMBIE WS-ZOMBIE-ROW WS-TX WS-Y1 WS-CZ WS-HX WS-HZ WS-ARRIVED
     MOVE "test stdmob follow: a destination 40 blocks away: a delay of 14 to 20 ticks" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF EN-PATH-TICKS(WS-ZOMBIE) >= 14 AND EN-PATH-TICKS(WS-ZOMBIE) <= 20
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STDMOB-FOLLOW.
 COPY CORETEST.
