*> Implementation test (lane p49r; 20 section 10.1, 21 section 5.3): the cube-mob move control against the document.
*> 1. The interval between two jumps: a drawn jumpDelay d gives the next jump d on-ground ticks after the jump tick (the decrement happens on the jump tick of the
*>    next jump too: the on-ground ticks counted from the one after the takeoff up to and including the next takeoff are d). The drawn d is read from EN-HOP right
*>    after the takeoff tick (10 to 29 for a calm slime, x 4 for a magma cube, divided by 3 for an aggressive one).
*> 2. With a target the attack goal turns the cube by lookAt(target, 10, 10): at most 10 degrees a tick (yaw 0 faces +Z, -90 faces +X), not the 90 of the move
*>    control; and the move control's own turn without a target stays at 90 a tick.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STDMOB-CUBE-10-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY BRWORLD.
 COPY CTBSHAPE.
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
 01 WS-TYPE                BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SCENARIO-KEY        PIC X(24).
 01 WS-SIZE                BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-CHASED              BINARY-LONG.
 01 WS-PREV-GROUND         BINARY-LONG.
 01 WS-GROUND-TICKS        BINARY-LONG.
 01 WS-DRAWN               BINARY-LONG.
 01 WS-TAKEOFFS            BINARY-LONG.
 01 WS-INTERVALS           BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-FIRST-BAD           BINARY-LONG.
 01 WS-FIRST-DRAWN         BINARY-LONG.
 01 WS-FIRST-GOT           BINARY-LONG.
 01 WS-CASE-NAME           PIC X(60).
 01 WS-YAW-1               FLOAT-LONG.
 01 WS-YAW-2               FLOAT-LONG.
 01 WS-YAW-3               FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "BR-WORLD-READY"
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STONE = FUNCTION NUMVAL(WS-STATE-TEXT)
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 40
     PERFORM VARYING WS-X FROM -28 BY 1 UNTIL WS-X > 28
         PERFORM VARYING WS-Z FROM -28 BY 1 UNTIL WS-Z > 28
             COMPUTE WS-K = WS-CX + WS-X
             COMPUTE WS-I = WS-CZ + WS-Z
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-K WS-FLOOR WS-I WS-STONE
         END-PERFORM
     END-PERFORM
     MOVE "slime" TO WS-SCENARIO-KEY
     MOVE 1 TO WS-SIZE
     MOVE 0 TO WS-CHASED
     MOVE 500 TO WS-TICKS
     PERFORM RUN-INTERVALS
     MOVE "calm slime" TO WS-CASE-NAME
     PERFORM ASSERT-INTERVALS
     MOVE "slime" TO WS-SCENARIO-KEY
     MOVE 2 TO WS-SIZE
     MOVE 1 TO WS-CHASED
     MOVE 200 TO WS-TICKS
     PERFORM RUN-INTERVALS
     MOVE "hunting slime" TO WS-CASE-NAME
     PERFORM ASSERT-INTERVALS
     MOVE "magma_cube" TO WS-SCENARIO-KEY
     MOVE 1 TO WS-SIZE
     MOVE 0 TO WS-CHASED
     MOVE 900 TO WS-TICKS
     PERFORM RUN-INTERVALS
     MOVE "calm magma cube" TO WS-CASE-NAME
     PERFORM ASSERT-INTERVALS
*>   Turning: the hunting slime at yaw 0, the player 8 blocks east (wanted yaw -90).
     MOVE "slime" TO WS-SCENARIO-KEY
     MOVE 2 TO WS-SIZE
     PERFORM RUN-TURN
     MOVE "N" TO TL-MODE
     MOVE "test stdmob cube 10.1: a hunting cube turns 10 degrees on the first tick (thousandths)" TO TL-CASE
     MOVE -10000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-YAW-1 * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test stdmob cube 10.1: a hunting cube has turned 20 degrees after the second tick (thousandths)" TO TL-CASE
     MOVE -20000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-YAW-2 * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test stdmob cube 10.1: a hunting cube has turned 30 degrees after the third tick (thousandths)" TO TL-CASE
     MOVE -30000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-YAW-3 * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Spawns the cube on the floor, runs WS-TICKS ticks and checks the on-ground ticks between takeoffs against the drawn delay.
 RUN-INTERVALS.
     PERFORM SPAWN-CUBE
     MOVE EN-ON-GROUND(WS-MOB) TO WS-PREV-GROUND
     MOVE 0 TO WS-TAKEOFFS WS-INTERVALS WS-BAD WS-GROUND-TICKS WS-DRAWN WS-FIRST-BAD WS-FIRST-DRAWN WS-FIRST-GOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-TICKS
         ADD 1 TO CW-TIME
         PERFORM KEEP-PLAYER
         CALL "MOBS-TICK"
         IF WS-PREV-GROUND = 1
             ADD 1 TO WS-GROUND-TICKS
         END-IF
         IF WS-PREV-GROUND = 1 AND EN-ON-GROUND(WS-MOB) = 0
             IF WS-TAKEOFFS > 0
                 ADD 1 TO WS-INTERVALS
                 IF WS-GROUND-TICKS NOT = WS-DRAWN
                     ADD 1 TO WS-BAD
                     IF WS-FIRST-BAD = 0
                         MOVE 1 TO WS-FIRST-BAD
                         MOVE WS-DRAWN TO WS-FIRST-DRAWN
                         MOVE WS-GROUND-TICKS TO WS-FIRST-GOT
                     END-IF
                 END-IF
             END-IF
             ADD 1 TO WS-TAKEOFFS
             MOVE EN-HOP(WS-MOB) TO WS-DRAWN
             MOVE 0 TO WS-GROUND-TICKS
         END-IF
         MOVE EN-ON-GROUND(WS-MOB) TO WS-PREV-GROUND
     END-PERFORM
     CALL "ENTITY-REMOVE" USING WS-MOB
     .

 SPAWN-CUBE.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE WS-SCENARIO-KEY DELIMITED BY SPACE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-FX = WS-CX + 0.5
     COMPUTE WS-FY = WS-FLOOR + 1
     COMPUTE WS-FZ = WS-CZ + 0.5
     MOVE 1 TO PL-MODE(WS-PLAYER)
     COMPUTE PL-X(WS-PLAYER) = WS-CX + 0.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-CZ + 28.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-MOB
     MOVE WS-SIZE TO EN-VARIANT(WS-MOB)
     MOVE 16001 TO CW-TIME
     CALL "MOBS-TICK"
     CALL "MOBS-TICK"
     MOVE WS-FX TO EN-X(WS-MOB)
     MOVE WS-FZ TO EN-Z(WS-MOB)
     MOVE 0 TO EN-VX(WS-MOB) EN-VZ(WS-MOB) EN-DEST-X(WS-MOB) EN-TARGET(WS-MOB) EN-YAW(WS-MOB)
     MOVE 0 TO EN-HOP(WS-MOB)
     MOVE 45 TO EN-DEST-Z(WS-MOB)
     IF WS-CHASED = 1
         PERFORM KEEP-PLAYER
     END-IF
     .

*> A survival player 8 blocks east of the cube, healed every tick, when the scenario hunts.
 KEEP-PLAYER.
     IF WS-CHASED = 1
         MOVE 0 TO PL-MODE(WS-PLAYER)
         MOVE 20 TO PL-HEALTH(WS-PLAYER)
         MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
         COMPUTE PL-X(WS-PLAYER) = WS-CX + 8.5
         MOVE WS-FZ TO PL-Z(WS-PLAYER)
     END-IF
     .

 RUN-TURN.
     MOVE 1 TO WS-CHASED
     PERFORM SPAWN-CUBE
     MOVE 0 TO EN-YAW(WS-MOB)
     MOVE WS-PLAYER TO EN-TARGET(WS-MOB)
     ADD 1 TO CW-TIME
     CALL "MOBS-TICK"
     MOVE EN-YAW(WS-MOB) TO WS-YAW-1
     ADD 1 TO CW-TIME
     CALL "MOBS-TICK"
     MOVE EN-YAW(WS-MOB) TO WS-YAW-2
     ADD 1 TO CW-TIME
     CALL "MOBS-TICK"
     MOVE EN-YAW(WS-MOB) TO WS-YAW-3
     CALL "ENTITY-REMOVE" USING WS-MOB
     .

 ASSERT-INTERVALS.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO TL-CASE
     STRING "test stdmob cube 10.1: " DELIMITED BY SIZE FUNCTION TRIM(WS-CASE-NAME) DELIMITED BY SIZE
         " measured several jump intervals" DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-INTERVALS >= 3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "test stdmob cube 10.1: " DELIMITED BY SIZE FUNCTION TRIM(WS-CASE-NAME) DELIMITED BY SIZE
         " jumps d on-ground ticks after the previous jump (intervals off by one)" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-STDMOB-CUBE-10-1.
 COPY CORETEST.
