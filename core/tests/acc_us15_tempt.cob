*> Acceptance test (US15; docs/protocol/18-mob-framework.md 4.7 TemptGoal, 19 sections 2 and 3.4): animals follow a player who holds their food (core/src/mob-18-tempt.cob, wired into
*> STDMOB-STEP). Range 10 (tempt_range), stop within 2.5 blocks, the goal cools down 100 ticks after it stops, a spectator or a dead player does not tempt, panic comes first.
*> Operator report: sheep did not follow a player holding wheat.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-TEMPT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY PROTO.
 COPY BRWORLD.
 COPY XORO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-XLO                BINARY-LONG.
 01 WS-XHI                BINARY-LONG.
 01 WS-ZLO                BINARY-LONG.
 01 WS-ZHI                BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-EDIT                PIC -(9)9.
 01 WS-NEEDLE              PIC X(40).
 01 WS-HITS                BINARY-LONG.
 01 WS-COW-TYPE            BINARY-LONG.
 01 WS-WANT-KEY            PIC X(112).
 01 WS-WANT-TYPE           BINARY-LONG.
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-ITEM-KEY            PIC X(112).
 01 WS-GIVE-COUNT          BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-ROW-A               BINARY-LONG.
 01 WS-ROW-B               BINARY-LONG.
 01 WS-ROW-C               BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-BABIES              BINARY-LONG.
 01 WS-ORBS                BINARY-LONG.
 01 WS-ORB-TYPE            BINARY-LONG.
 01 WS-COUNT-ITEM          BINARY-LONG.
 01 WS-COUNT-TOTAL         BINARY-LONG.
 01 WS-ID-A                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 01 WS-SLOT-ITEM           BINARY-LONG.
 01 WS-WHEAT               BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-COLOR               BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-S                   BINARY-LONG.
 01 WS-TRY                 BINARY-LONG.
 01 WS-KEY-IN              PIC X(24).
 01 WS-MILLI               BINARY-LONG.
 01 WS-START               FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-PX0                 FLOAT-LONG.
 01 WS-PZ0                 FLOAT-LONG.
 01 WS-PDIM                BINARY-LONG.
 01 WS-OK-IN               BINARY-LONG.
 01 WS-DIST-MILLI          BINARY-LONG.
 01 WS-CASES.
    05 FILLER PIC X(52) VALUE "sheep                   wheat                   0601".
    05 FILLER PIC X(52) VALUE "cow                     wheat                   0601".
    05 FILLER PIC X(52) VALUE "mooshroom               wheat                   0601".
    05 FILLER PIC X(52) VALUE "pig                     carrot                  0601".
    05 FILLER PIC X(52) VALUE "chicken                 wheat_seeds             0601".
    05 FILLER PIC X(52) VALUE "goat                    wheat                   0601".
    05 FILLER PIC X(52) VALUE "rabbit                  carrot                  0601".
    05 FILLER PIC X(52) VALUE "panda                   bamboo                  0601".
    05 FILLER PIC X(52) VALUE "horse                   golden_carrot           0601".
    05 FILLER PIC X(52) VALUE "horse                   enchanted_golden_apple  0601".
    05 FILLER PIC X(52) VALUE "llama                   hay_block               0601".
    05 FILLER PIC X(52) VALUE "camel                   cactus                  0601".
    05 FILLER PIC X(52) VALUE "sheep                   carrot                  0600".
    05 FILLER PIC X(52) VALUE "cow                     carrot                  0600".
    05 FILLER PIC X(52) VALUE "pig                     wheat                   0600".
    05 FILLER PIC X(52) VALUE "horse                   apple                   0600".
    05 FILLER PIC X(52) VALUE "llama                   wheat                   0600".
    05 FILLER PIC X(52) VALUE "wolf                    bone                    0600".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CS                OCCURS 18 TIMES.
       10 WS-CS-KEY         PIC X(24).
       10 WS-CS-FOOD        PIC X(24).
       10 WS-CS-DIST        PIC 99.
       10 WS-CS-WANT        PIC 99.

 01 WS-BABY-OK             BINARY-LONG.
 01 WS-LABEL               PIC X(24).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "BR-WORLD-READY"
     MOVE 2 TO BW-DIFFICULTY
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO PL-HELD(WS-PLAYER)
     MOVE 6000 TO CW-TIME
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STATE = FUNCTION NUMVAL(WS-STATE-TEXT)
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 40
     COMPUTE WS-XLO = WS-CX - 12
     COMPUTE WS-XHI = WS-CX + 12
     COMPUTE WS-ZLO = WS-CZ - 12
     COMPUTE WS-ZHI = WS-CZ + 12
     PERFORM VARYING WS-X FROM WS-XLO BY 1 UNTIL WS-X > WS-XHI
         PERFORM VARYING WS-Z FROM WS-ZLO BY 1 UNTIL WS-Z > WS-ZHI
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FLOOR WS-Z WS-STATE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
                 COMPUTE WS-E = WS-FLOOR + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE PL-X(WS-PLAYER) = WS-CX + 0.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-CZ + 0.5
     MOVE "minecraft:experience_orb" TO WS-WANT-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-WANT-KEY WS-ORB-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT

     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 18
         MOVE WS-CS-KEY(WS-S) TO WS-WANT-KEY
         MOVE WS-CS-FOOD(WS-S) TO WS-ITEM-KEY
         MOVE WS-CS-DIST(WS-S) TO WS-DX
         PERFORM SETUP-ONE
         PERFORM TICK-A 150 TIMES
         PERFORM MEASURE
         MOVE SPACES TO WS-CASE
         STRING "acceptance US15 18§4.7 Tempt: " FUNCTION TRIM(WS-WANT-KEY) " holding " FUNCTION TRIM(WS-ITEM-KEY) " the goal is "
             DELIMITED BY SIZE INTO WS-CASE
         IF WS-CS-WANT(WS-S) = 1
             STRING "running" DELIMITED BY SIZE INTO WS-CASE(FUNCTION LENGTH(FUNCTION TRIM(WS-CASE)) + 2:)
         ELSE
             STRING "idle" DELIMITED BY SIZE INTO WS-CASE(FUNCTION LENGTH(FUNCTION TRIM(WS-CASE)) + 2:)
         END-IF
         MOVE WS-CS-WANT(WS-S) TO WS-EXPECT
         MOVE 0 TO WS-OBSERVE
         IF EN-TEMPT(WS-ROW-A) = -1
             MOVE 1 TO WS-OBSERVE
         END-IF
         PERFORM CHECK-N
         IF WS-CS-WANT(WS-S) = 1
             MOVE SPACES TO WS-CASE
             STRING "acceptance US15 18§4.7 Tempt: " FUNCTION TRIM(WS-WANT-KEY) " holding " FUNCTION TRIM(WS-ITEM-KEY)
                 " the animal walked to the player and stopped within 3.5 blocks" DELIMITED BY SIZE INTO WS-CASE
             MOVE 1 TO WS-EXPECT
             MOVE 0 TO WS-OBSERVE
             IF WS-DIST < 3.5 AND WS-DIST > 1.0
                 MOVE 1 TO WS-OBSERVE
             END-IF
             PERFORM CHECK-N
         END-IF
     END-PERFORM
*>   Out of range: the player is 20 blocks farther away (tempt_range 10)
     MOVE "pig" TO WS-WANT-KEY
     MOVE "carrot" TO WS-ITEM-KEY
     MOVE 6 TO WS-DX
     PERFORM SETUP-ONE
     COMPUTE PL-X(WS-PLAYER) = PL-X(WS-PLAYER) - 20
     PERFORM TICK-A 5 TIMES
     MOVE "acceptance US15 18§4.7 Tempt: a player 26 blocks away does not tempt" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-TEMPT(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
     COMPUTE PL-X(WS-PLAYER) = PL-X(WS-PLAYER) + 20
*>   A player who is not alive, a spectator and another dimension do not tempt; a creative player does
     MOVE 0 TO EN-TEMPT(WS-ROW-A)
     MOVE 3 TO PL-MODE(WS-PLAYER)
     PERFORM TICK-A 5 TIMES
     MOVE "acceptance US15 18§4.7 Tempt: a spectator holding carrots does not tempt a pig" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-TEMPT(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 1 TO PL-MODE(WS-PLAYER)
     PERFORM TICK-A 5 TIMES
     MOVE "acceptance US15 18§4.7 Tempt: a creative player holding carrots tempts a pig" TO WS-CASE
     MOVE -1 TO WS-EXPECT
     MOVE EN-TEMPT(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO EN-TEMPT(WS-ROW-A)
     MOVE PS-DEAD TO PL-STATE(WS-PLAYER)
     PERFORM TICK-A 5 TIMES
     MOVE PS-ALIVE TO PL-STATE(WS-PLAYER)
     MOVE "acceptance US15 18§4.7 Tempt: a dead player does not tempt" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-TEMPT(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE PL-DIM(WS-PLAYER) TO WS-PDIM
     COMPUTE PL-DIM(WS-PLAYER) = WS-PDIM + 1
     PERFORM TICK-A 5 TIMES
     MOVE WS-PDIM TO PL-DIM(WS-PLAYER)
     MOVE "acceptance US15 18§4.7 Tempt: a player in another dimension does not tempt" TO WS-CASE
     MOVE 0 TO WS-EXPECT
     MOVE EN-TEMPT(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
*>   The goal stops when the player puts the food away: 100 ticks of cooldown, during which the food does not tempt
     PERFORM TICK-A 3 TIMES
     MOVE "acceptance US15 18§4.7 Tempt: the goal runs while the carrot is held" TO WS-CASE
     MOVE -1 TO WS-EXPECT
     MOVE EN-TEMPT(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM TICK-A 1 TIMES
     MOVE "acceptance US15 18§4.7 Tempt: when the carrot is put away the goal stops and cools down for 100 ticks" TO WS-CASE
     MOVE 100 TO WS-EXPECT
     MOVE EN-TEMPT(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     PERFORM TICK-A 50 TIMES
     MOVE "acceptance US15 18§4.7 Tempt: during the cooldown the carrot does not tempt (50 ticks left)" TO WS-CASE
     MOVE 50 TO WS-EXPECT
     MOVE EN-TEMPT(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
     PERFORM TICK-A 51 TIMES
     MOVE "acceptance US15 18§4.7 Tempt: after the cooldown the carrot tempts again" TO WS-CASE
     MOVE -1 TO WS-EXPECT
     MOVE EN-TEMPT(WS-ROW-A) TO WS-OBSERVE
     PERFORM CHECK-N
*>   Panic comes before the tempt goal: a pig that fled east keeps going away from the player
     COMPUTE EN-X(WS-ROW-A) = PL-X(WS-PLAYER) + 6
     MOVE WS-PLAYER TO EN-FLEE-PLAYER(WS-ROW-A)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-FLEE-ID(WS-ROW-A)
     MOVE 30 TO EN-FLEE(WS-ROW-A)
     PERFORM TICK-A 20 TIMES
     PERFORM MEASURE
     MOVE "acceptance US15 18§4.7 Tempt: a panicking pig runs away from the player holding a carrot" TO WS-CASE
     MOVE 1 TO WS-EXPECT
     MOVE 0 TO WS-OBSERVE
     IF WS-DIST > 6.5
         MOVE 1 TO WS-OBSERVE
     END-IF
     PERFORM CHECK-N
*>   The speeds of the goals and the foods
     MOVE "pig" TO WS-KEY-IN
     MOVE 1200 TO WS-EXPECT
     PERFORM CHECK-SPEED
     MOVE "cow" TO WS-KEY-IN
     MOVE 1250 TO WS-EXPECT
     PERFORM CHECK-SPEED
     MOVE "sheep" TO WS-KEY-IN
     MOVE 1100 TO WS-EXPECT
     PERFORM CHECK-SPEED
     MOVE "chicken" TO WS-KEY-IN
     MOVE 1000 TO WS-EXPECT
     PERFORM CHECK-SPEED
     MOVE "wolf" TO WS-KEY-IN
     MOVE 0 TO WS-EXPECT
     PERFORM CHECK-SPEED
     MOVE "trader_llama" TO WS-KEY-IN
     MOVE "hay_block" TO WS-ITEM-KEY
     MOVE 1 TO WS-EXPECT
     PERFORM CHECK-FOOD
     MOVE "donkey" TO WS-KEY-IN
     MOVE "golden_apple" TO WS-ITEM-KEY
     PERFORM CHECK-FOOD
     MOVE "donkey" TO WS-KEY-IN
     MOVE "carrot" TO WS-ITEM-KEY
     MOVE 0 TO WS-EXPECT
     PERFORM CHECK-FOOD
     STOP RUN.

 SETUP-ONE.
     PERFORM CLEAR-MOBS
     MOVE 0 TO WS-DZ
     PERFORM SPAWN-MOB
     MOVE WS-E TO WS-ROW-A
     MOVE 1 TO WS-GIVE-COUNT
     PERFORM GIVE-HELD
     MOVE 0 TO EN-TEMPT(WS-ROW-A).

 TICK-A.
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW-A.

 MEASURE.
     COMPUTE WS-PX0 = EN-X(WS-ROW-A) - PL-X(WS-PLAYER)
     COMPUTE WS-PZ0 = EN-Z(WS-ROW-A) - PL-Z(WS-PLAYER)
     COMPUTE WS-DIST = FUNCTION SQRT(WS-PX0 * WS-PX0 + WS-PZ0 * WS-PZ0).

 CHECK-SPEED.
     CALL "MOB-TEMPT-SPEED" USING WS-KEY-IN WS-MILLI
     MOVE SPACES TO WS-CASE
     STRING "acceptance US15 18§4.7 Tempt: the speed modifier of " FUNCTION TRIM(WS-KEY-IN) " in thousandths"
         DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-MILLI TO WS-OBSERVE
     PERFORM CHECK-N.

 CHECK-FOOD.
     CALL "MOB-TEMPT-FOOD" USING WS-KEY-IN WS-ITEM-KEY WS-OK-IN
     MOVE SPACES TO WS-CASE
     STRING "acceptance US15 18§4.7 Tempt: " FUNCTION TRIM(WS-ITEM-KEY) " tempts a " FUNCTION TRIM(WS-KEY-IN) " (1 yes)"
         DELIMITED BY SIZE INTO WS-CASE
     MOVE WS-OK-IN TO WS-OBSERVE
     PERFORM CHECK-N.

 CLEAR-MOBS.
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
         IF EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0
             CALL "ENTITY-REMOVE" USING WS-N
         END-IF
     END-PERFORM.

 SPAWN-MOB.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-WANT-KEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WANT-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-FX = WS-CX + 0.5 + WS-DX
     COMPUTE WS-FY = WS-FLOOR + 1
     COMPUTE WS-FZ = WS-CZ + 0.5 + WS-DZ
     CALL "MOB-SPAWN" USING WS-DIM WS-WANT-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-E.

 FIND-TYPE.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-WANT-KEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WANT-TYPE WS-ENTITY-ROW WS-STATUS.

 GIVE-HELD.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-ITEM-KEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM-ID WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM-ID TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE WS-GIVE-COUNT TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1).

 COUNT-BABIES.
     MOVE 0 TO WS-BABIES
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
         IF EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-MOBAGE(WS-N) < 0 AND EN-VARIANT(WS-N) = 1
             ADD 1 TO WS-BABIES
             MOVE WS-N TO WS-BABY
         END-IF
     END-PERFORM.

 COUNT-ORBS.
     MOVE 0 TO WS-ORBS
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
         IF EN-USED(WS-N) = 1 AND EN-TYPE(WS-N) = WS-ORB-TYPE
             ADD 1 TO WS-ORBS
         END-IF
     END-PERFORM.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US15-TEMPT.
 COPY CORETEST.
