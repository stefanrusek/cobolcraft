*> Acceptance test (002-lane-p49b fork u; docs/protocol/20 section 8.1): the enderman's reactions. A target that stares at it from within 4 blocks (squared distance below 16) makes it
*> teleport (random); a target farther than 16 blocks for 30 consecutive ticks makes it teleport towards the target; a projectile (arrow) hurts it not at all but makes it try to
*> teleport; any other damage with no living attacker teleports it with probability 1/10; in water, or in rain under open sky, it takes 1 point every tick; a teleport sends level
*> event 2018 to the viewers.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-8-1-MORE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY RULES.
 COPY DIMENSIONS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-BLOCK               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 24.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-MOVED               BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-IDS                 PIC X(1024).
 01 WS-PADDED              PIC X(1030).
 01 WS-HAS                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NIGHT               BINARY-DOUBLE VALUE 18000.
 01 WS-DAYTIME             BINARY-DOUBLE VALUE 6000.
 01 WS-GONE                BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "N" TO TL-MODE
     MOVE "minecraft:enderman" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     COMPUTE WS-FX = FUNCTION INTEGER(WS-X) - 12
     COMPUTE WS-FZ = FUNCTION INTEGER(WS-Z) - 12
     COMPUTE WS-FY = FUNCTION INTEGER(WS-Y) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     MOVE WS-NIGHT TO CW-TIME

*>   Staring within 4 blocks: the player looks straight at an enderman 3 blocks east (yaw -90, pitch up to its eye at +2.55).
     COMPUTE WS-X0 = WS-X + 3
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     MOVE -90 TO PL-YAW(WS-PLAYER)
     COMPUTE PL-PITCH(WS-PLAYER) = 0 - FUNCTION ATAN(0.93 / 3) * 180 / FUNCTION PI
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-IDS
     CALL "MOB-STEP" USING WS-MOB
     MOVE "acceptance US15 20§8.1 Enderman takes a staring player as its target" TO TL-CASE
     MOVE WS-PLAYER TO TL-EXPECTED-N
     MOVE EN-TARGET(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-X0 TO EN-X(WS-MOB)
     CALL "MOB-STEP" USING WS-MOB
     MOVE "acceptance US15 20§8.1 Enderman teleports from a target that stares within 4 blocks" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "moved" TO TL-EXPECTED
     MOVE "still" TO TL-OBSERVED
     IF FUNCTION ABS(EN-X(WS-MOB) - WS-X0) + FUNCTION ABS(EN-Z(WS-MOB) - WS-Z) > 3
         MOVE "moved" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     CALL "TEST-DRAIN-IDS" USING PL-CONN(WS-PLAYER) WS-IDS
     MOVE SPACES TO WS-PADDED
     STRING " " DELIMITED BY SIZE FUNCTION TRIM(WS-IDS) DELIMITED BY SIZE " " DELIMITED BY SIZE INTO WS-PADDED
     MOVE 0 TO WS-HAS
     INSPECT WS-PADDED TALLYING WS-HAS FOR ALL " 47 "
     MOVE "acceptance US15 20§8.1 Enderman teleport sends level event 2018 (packet 47)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HAS > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A target that does not stare does not make it teleport (the player looks away).
     CALL "ENTITY-REMOVE" USING WS-MOB
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-MOB)
     MOVE WS-PLAYER TO EN-TARGET(WS-MOB)
     MOVE 90 TO PL-YAW(WS-PLAYER)
     MOVE 0 TO PL-PITCH(WS-PLAYER)
     MOVE 0 TO WS-MOVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         MOVE WS-X0 TO EN-X(WS-MOB)
         CALL "MOB-STEP" USING WS-MOB
         IF FUNCTION ABS(EN-X(WS-MOB) - WS-X0) + FUNCTION ABS(EN-Z(WS-MOB) - WS-Z) > 3
             MOVE 1 TO WS-MOVED
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§8.1 Enderman does not teleport from a player who looks away" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MOVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A target farther than 16 blocks for 30 consecutive ticks: it teleports towards the target on the 30th tick.
     CALL "ENTITY-REMOVE" USING WS-MOB
     COMPUTE WS-X0 = WS-X + 20
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-MOB)
     MOVE WS-PLAYER TO EN-TARGET(WS-MOB)
     MOVE 0 TO WS-FIRST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40 OR WS-FIRST > 0
         MOVE WS-X0 TO EN-X(WS-MOB)
         MOVE WS-Z TO EN-Z(WS-MOB)
         MOVE WS-Y TO EN-Y(WS-MOB)
         CALL "MOB-STEP" USING WS-MOB
         IF EN-X(WS-MOB) - WS-X0 > 3 OR WS-X0 - EN-X(WS-MOB) > 3 OR EN-Z(WS-MOB) - WS-Z > 3 OR WS-Z - EN-Z(WS-MOB) > 3
             MOVE WS-I TO WS-FIRST
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§8.1 Enderman teleports towards a target 16+ blocks away on the 30th tick" TO TL-CASE
     MOVE 30 TO TL-EXPECTED-N
     MOVE WS-FIRST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB

*>   Damage reactions: an arrow is ignored and makes it teleport.
     COMPUTE WS-X0 = WS-X + 3
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
     MOVE 5 TO WS-AMOUNT
     MOVE CAUSE-ARROW TO WS-CAUSE
     MOVE 0 TO EN-HURT(WS-MOB)
     CALL "HEALTH-MOB-DAMAGE" USING WS-MOB WS-AMOUNT WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 20§8.1 Enderman takes no damage from an arrow" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 20§8.1 Enderman teleports away from an arrow" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "moved" TO TL-EXPECTED
     MOVE "still" TO TL-OBSERVED
     IF FUNCTION ABS(EN-X(WS-MOB) - WS-X0) + FUNCTION ABS(EN-Z(WS-MOB) - WS-Z) > 3
         MOVE "moved" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   Damage without a living attacker (a fall): hurts, and teleports in about one case in ten.
     MOVE CAUSE-FALL TO WS-CAUSE
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         MOVE WS-X0 TO EN-X(WS-MOB)
         MOVE WS-Z TO EN-Z(WS-MOB)
         MOVE 40 TO EN-HEALTH(WS-MOB)
         MOVE 0 TO EN-HURT(WS-MOB)
         ADD 1 TO CW-TICKS
         MOVE 1 TO WS-AMOUNT
         CALL "HEALTH-MOB-DAMAGE" USING WS-MOB WS-AMOUNT WS-CAUSE WS-NONE
         IF FUNCTION ABS(EN-X(WS-MOB) - WS-X0) + FUNCTION ABS(EN-Z(WS-MOB) - WS-Z) > 3
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§8.1 Enderman teleports after a fall about one time in ten" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COUNT >= 5 AND WS-COUNT <= 45
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A hit by a player is an ordinary hurt: no teleport.
     MOVE CAUSE-PLAYER TO WS-CAUSE
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 100
         MOVE WS-X0 TO EN-X(WS-MOB)
         MOVE WS-Z TO EN-Z(WS-MOB)
         MOVE 40 TO EN-HEALTH(WS-MOB)
         MOVE 0 TO EN-HURT(WS-MOB)
         ADD 1 TO CW-TICKS
         MOVE 1 TO WS-AMOUNT
         CALL "HEALTH-MOB-DAMAGE" USING WS-MOB WS-AMOUNT WS-CAUSE WS-PLAYER
         IF FUNCTION ABS(EN-X(WS-MOB) - WS-X0) + FUNCTION ABS(EN-Z(WS-MOB) - WS-Z) > 3
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE "acceptance US15 20§8.1 Enderman does not teleport when a player hits it" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB

*>   Water: standing in a water block it loses 1 health every tick.
     MOVE "minecraft:water" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STATE = FUNCTION NUMVAL(WS-STATE-TEXT)
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X) + 6
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE WS-X0 = WS-BX + 0.5
     COMPUTE WS-Z0 = WS-BZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z0 WS-YAW WS-MOB
     MOVE 0 TO EN-HURT(WS-MOB)
     CALL "MOB-STEP" USING WS-MOB
     MOVE "acceptance US15 20§8.1 Enderman in water loses 1 health a tick" TO TL-CASE
     MOVE 39 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-MOB) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITY-REMOVE" USING WS-MOB

*>   Daylight (8.1): by day, in the open, 600 ticks after its target changed, it loses the target and teleports (about 4 ticks in 100 at full brightness); not before 600 ticks, not at night.
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STATE = FUNCTION NUMVAL(WS-STATE-TEXT)
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X) + 10
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z)
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y) - 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE WS-X0 = WS-BX + 0.5
     MOVE 90 TO PL-YAW(WS-PLAYER)
     MOVE 0 TO PL-PITCH(WS-PLAYER)
     PERFORM VARYING WS-PASS FROM 1 BY 1 UNTIL WS-PASS > 3
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X0 WS-Y WS-Z WS-YAW WS-MOB
         MOVE PL-ENTITY-ID(WS-PLAYER) TO EN-TARGET-ID(WS-MOB)
         MOVE WS-PLAYER TO EN-TARGET(WS-MOB)
         MOVE WS-DAYTIME TO CW-TIME
         IF WS-PASS = 3
             MOVE WS-NIGHT TO CW-TIME
         END-IF
         MOVE 0 TO WS-GONE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 600 OR WS-GONE = 1
             MOVE WS-X0 TO EN-X(WS-MOB)
             MOVE WS-Z TO EN-Z(WS-MOB)
             MOVE WS-Y TO EN-Y(WS-MOB)
             MOVE 700 TO EN-ENDER-TICKS(WS-MOB)
             IF WS-PASS = 2
                 MOVE 590 TO EN-ENDER-TICKS(WS-MOB)
             END-IF
             ADD 1 TO CW-TICKS
             CALL "MOB-STEP" USING WS-MOB
             IF FUNCTION ABS(EN-X(WS-MOB) - WS-X0) + FUNCTION ABS(EN-Z(WS-MOB) - WS-Z) > 3
                 MOVE 1 TO WS-GONE
             END-IF
         END-PERFORM
         EVALUATE WS-PASS
             WHEN 1
                 MOVE "acceptance US15 20§8.1 Enderman teleports by day after 600 ticks" TO TL-CASE
                 MOVE 1 TO TL-EXPECTED-N
                 MOVE WS-GONE TO TL-OBSERVED-N
                 CALL "TEST-ASSERT" USING TESTLIB-ASSERT
                 MOVE "acceptance US15 20§8.1 Enderman loses its target to the daylight" TO TL-CASE
                 MOVE 0 TO TL-EXPECTED-N
                 MOVE EN-TARGET(WS-MOB) TO TL-OBSERVED-N
                 CALL "TEST-ASSERT" USING TESTLIB-ASSERT
             WHEN 2
                 MOVE "acceptance US15 20§8.1 Enderman does not teleport by day before 600 ticks" TO TL-CASE
                 MOVE 0 TO TL-EXPECTED-N
                 MOVE WS-GONE TO TL-OBSERVED-N
                 CALL "TEST-ASSERT" USING TESTLIB-ASSERT
             WHEN OTHER
                 MOVE "acceptance US15 20§8.1 Enderman does not teleport at night" TO TL-CASE
                 MOVE 0 TO TL-EXPECTED-N
                 MOVE WS-GONE TO TL-OBSERVED-N
                 CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-EVALUATE
         CALL "ENTITY-REMOVE" USING WS-MOB
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-MOB-20-8-1-MORE.
 COPY CORETEST.
 COPY MOBSPTEST.
