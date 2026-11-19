*> Implementation test (lane bugbounce, T61200; docs/protocol/44-residual-mob-questions-5 section 4.3, 24-5 slime_block row): a standard mob that lands on a slime
*> block (bounceRestitution 1.0) leaves it upward (EN-VY above 0 after the landing step, the restitution step of Entity.restituteMovementAfterCollisions); on stone it
*> only rests (EN-VY never above 0); a slow landing (downward speed not above the gravity 0.08) does not bounce.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BOUNCE-MOB.
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
 01 WS-STATE               BINARY-LONG.
 01 WS-SPIDER-TYPE         BINARY-LONG.
 01 WS-SPIDER              BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-UPS                 BINARY-LONG.
 01 WS-RISE                BINARY-LONG.
 01 WS-RISE-SLIME          BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-LANDED              BINARY-LONG.
 01 WS-START               FLOAT-LONG.
 01 WS-MAXY                FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-FLOOR-Y             FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-KEYS.
    05 FILLER              PIC X(32) VALUE "minecraft:stone".
    05 FILLER              PIC X(32) VALUE "minecraft:slime_block".
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-FLOOR-KEY        PIC X(32) OCCURS 2 TIMES.
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
     MOVE "N" TO TL-MODE
     MOVE 6000 TO CW-TIME
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 2
         MOVE SPACES TO WS-KEY
         MOVE WS-FLOOR-KEY(WS-K) TO WS-KEY
         CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
         MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
         COMPUTE WS-STATE = FUNCTION NUMVAL(WS-STATE-TEXT)
*>       A floor cell of the key at the player's place, a spider 4 blocks above it falling (open sky above).
         COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 4 + WS-K * 2
         COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
         COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
         COMPUTE WS-X0 = WS-BX + 0.5
         COMPUTE WS-FLOOR-Y = WS-BY + 1
         COMPUTE WS-Y = WS-FLOOR-Y + 4
         COMPUTE WS-Z = WS-BZ + 0.5
         CALL "MOB-SPAWN" USING WS-DIM WS-SPIDER-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-SPIDER
         MOVE 0 TO EN-TARGET(WS-SPIDER)
         MOVE WS-X0 TO EN-X(WS-SPIDER)
         MOVE WS-Y TO EN-Y(WS-SPIDER)
         MOVE 0 TO EN-VY(WS-SPIDER)
         MOVE 0 TO WS-UPS WS-LANDED
         MOVE WS-FLOOR-Y TO WS-MAXY
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
             CALL "MOB-STEP" USING WS-SPIDER
*>           The measuring starts at the first landing: before it the mob is only falling.
             IF EN-ON-GROUND(WS-SPIDER) = 1
                 MOVE 1 TO WS-LANDED
             END-IF
             IF WS-LANDED = 1 AND EN-VY(WS-SPIDER) > 0.05
                 ADD 1 TO WS-UPS
             END-IF
             IF WS-LANDED = 1 AND EN-Y(WS-SPIDER) > WS-MAXY
                 MOVE EN-Y(WS-SPIDER) TO WS-MAXY
             END-IF
         END-PERFORM
         COMPUTE WS-RISE = (WS-MAXY - WS-FLOOR-Y) * 1000
         EVALUATE WS-K
             WHEN 1
                 MOVE "bounce mob: a mob landing on stone never rises (ticks with upward speed)" TO TL-CASE
                 MOVE 0 TO TL-EXPECTED-N
                 MOVE WS-UPS TO TL-OBSERVED-N
                 CALL "TEST-ASSERT" USING TESTLIB-ASSERT
             WHEN OTHER
                 MOVE WS-RISE TO WS-RISE-SLIME
                 MOVE "bounce mob: a mob landing on slime rises again (more than 2 blocks above the floor, thousandths)" TO TL-CASE
                 MOVE 1 TO TL-EXPECTED-N
                 MOVE 0 TO TL-OBSERVED-N
                 IF WS-RISE > 2000
                     MOVE 1 TO TL-OBSERVED-N
                 END-IF
                 CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-EVALUATE
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-BOUNCE-MOB.
 COPY CORETEST.
