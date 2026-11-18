*> Implementation test (lane bugmobmove, T30701; 20 section 10, 21 section 5.3, 18 sections 3.2 and 3.2.1): slimes and magma cubes move only by hopping. On the
*> ground a cube stands still until its jump delay (10 + nextInt(20) ticks; a magma cube's x 4; an aggressive cube's / 3) has run out, then it jumps (vertical
*> speed 0.42, a magma cube's + 0.1 x size) and the same tick accelerates along its yaw by speed squared (speed 0.2 + 0.1 x size, zza = speed); in the air
*> it gains 0.02 x speed a tick; horizontal drag 0.546 on the ground, 0.91 in the air. The expected hop length and height are simulated here from those
*> rules (independent of the production code); the cube is measured over several hundred ticks of MOBS-TICK on flat stone.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STDMOB-CUBE-HOP.
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
*> the scenario
 01 WS-SCENARIO-KEY        PIC X(24).
 01 WS-SIZE                BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-CHASED              BINARY-LONG.
*> what one run measured
 01 WS-HOPS                BINARY-LONG.
 01 WS-STILL-BAD           BINARY-LONG.
 01 WS-GROUND-RUN          BINARY-LONG.
 01 WS-MAX-GROUND-RUN      BINARY-LONG.
 01 WS-PREV-GROUND         BINARY-LONG.
 01 WS-LAND-TICK           BINARY-LONG.
 01 WS-PREV-X              FLOAT-LONG.
 01 WS-PREV-Y              FLOAT-LONG.
 01 WS-PREV-Z              FLOAT-LONG.
 01 WS-STEP                FLOAT-LONG.
 01 WS-HOP-LENGTH          FLOAT-LONG.
 01 WS-TAKEOFF-STEP        FLOAT-LONG.
 01 WS-S1                  BINARY-LONG.
 01 WS-PEAK                FLOAT-LONG.
 01 WS-END-DISTANCE        FLOAT-LONG.
*> the simulation
 01 WS-SPEED               FLOAT-LONG.
 01 WS-JUMP                FLOAT-LONG.
 01 WS-SIM-H               FLOAT-LONG.
 01 WS-SIM-VY              FLOAT-LONG.
 01 WS-SIM-PEAK            FLOAT-LONG.
 01 WS-SIM-AIR             BINARY-LONG.
 01 WS-SIM-V               FLOAT-LONG.
 01 WS-SIM-DIST            FLOAT-LONG.
 01 WS-SIM-DONE            BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-CASE-NAME           PIC X(60).
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
*>   1. A size 1 slime, nobody to hunt (the player is in creative mode, far off).
     MOVE "slime" TO WS-SCENARIO-KEY
     MOVE 1 TO WS-SIZE
     MOVE 600 TO WS-TICKS
     MOVE 0 TO WS-CHASED
     PERFORM RUN-CUBE
     PERFORM SIMULATE-HOP
     MOVE "slime size 1" TO WS-CASE-NAME
     COMPUTE WS-LOW = 600 / (WS-SIM-AIR + 1 + 29) - 1
     COMPUTE WS-HIGH = 600 / (WS-SIM-AIR + 1 + 10) + 1
     PERFORM ASSERT-HOPS
     PERFORM ASSERT-STILL
     PERFORM ASSERT-LENGTH
     PERFORM ASSERT-PEAK
*>   1b. On ice (friction 0.98, BSH-SLIP of the floor) the takeoff tick accelerates by speed x 0.21600002 / F^3 x speed (18 section 3.2.1): 0.3 x 0.216 / 0.941 x 0.3.
     COMPUTE WS-S1 = WS-STONE + 1
     MOVE 980 TO BSH-SLIP(WS-S1)
     MOVE 300 TO WS-TICKS
     PERFORM RUN-CUBE
     MOVE 0 TO BSH-SLIP(WS-S1)
     MOVE "N" TO TL-MODE
     MOVE "test stdmob cube hop: a slime on ice takes off with the ice acceleration (micro blocks)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 0.3 * 0.3 * 0.21600002 / (0.98 ** 3) * 1000000
     COMPUTE TL-OBSERVED-N = WS-TAKEOFF-STEP * 1000000
     COMPUTE WS-DIFF = FUNCTION ABS(TL-OBSERVED-N - TL-EXPECTED-N)
     IF WS-DIFF * 100 <= TL-EXPECTED-N * 3
         MOVE TL-EXPECTED-N TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   2. A size 4 slime hops farther (speed 0.6).
     MOVE 4 TO WS-SIZE
     PERFORM RUN-CUBE
     PERFORM SIMULATE-HOP
     MOVE "slime size 4" TO WS-CASE-NAME
     PERFORM ASSERT-STILL
     PERFORM ASSERT-LENGTH
*>   3. A magma cube: jump 0.42 + 0.1 x size, delay x 4.
     MOVE "magma_cube" TO WS-SCENARIO-KEY
     MOVE 1 TO WS-SIZE
     MOVE 600 TO WS-TICKS
     PERFORM RUN-CUBE
     PERFORM SIMULATE-HOP
     MOVE "magma cube size 1" TO WS-CASE-NAME
     COMPUTE WS-LOW = 1
     COMPUTE WS-HIGH = 600 / (WS-SIM-AIR + 1 + 40) + 1
     PERFORM ASSERT-HOPS
     PERFORM ASSERT-STILL
     PERFORM ASSERT-LENGTH
     PERFORM ASSERT-PEAK
*>   4. A size 2 slime with a player 8 blocks east (survival): it jumps aggressively (delay / 3) towards the player and reaches it.
     MOVE "slime" TO WS-SCENARIO-KEY
     MOVE 2 TO WS-SIZE
     MOVE 300 TO WS-TICKS
     MOVE 1 TO WS-CHASED
     PERFORM RUN-CUBE
     PERFORM SIMULATE-HOP
     MOVE "slime size 2 hunting" TO WS-CASE-NAME
     COMPUTE WS-LOW = 300 / (WS-SIM-AIR + 1 + 9) - 1
     COMPUTE WS-HIGH = 300 / (WS-SIM-AIR + 1) + 1
     PERFORM ASSERT-HOPS
     PERFORM ASSERT-STILL
     MOVE "N" TO TL-MODE
     MOVE SPACES TO TL-CASE
     STRING "test stdmob cube hop: a hunting " DELIMITED BY SIZE "slime hopped to within 3 blocks of the player" DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-END-DISTANCE < 3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Spawns the cube of the scenario in the middle of the floor and runs WS-TICKS ticks, recording the takeoffs, the longest stand, the ticks it moved while
*> standing, the length and height of its first hop and (hunted) the distance to the player at the end.
 RUN-CUBE.
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
*>   Facing +Z, with the wanted yaw 0 for the next 45 ticks and 3 ticks of jump delay left: the first hop is straight.
     MOVE 0 TO EN-VX(WS-MOB) EN-VZ(WS-MOB) EN-DEST-X(WS-MOB) EN-TARGET(WS-MOB) EN-YAW(WS-MOB)
     MOVE 3 TO EN-HOP(WS-MOB)
     MOVE 45 TO EN-DEST-Z(WS-MOB)
     IF WS-CHASED = 1
         MOVE 0 TO PL-MODE(WS-PLAYER)
         COMPUTE PL-X(WS-PLAYER) = WS-CX + 8.5
         MOVE WS-FZ TO PL-Z(WS-PLAYER)
     END-IF
     MOVE EN-ON-GROUND(WS-MOB) TO WS-PREV-GROUND
     MOVE EN-X(WS-MOB) TO WS-PREV-X
     MOVE EN-Y(WS-MOB) TO WS-PREV-Y
     MOVE EN-Z(WS-MOB) TO WS-PREV-Z
     MOVE 0 TO WS-HOPS WS-STILL-BAD WS-GROUND-RUN WS-MAX-GROUND-RUN WS-HOP-LENGTH WS-PEAK
     MOVE -100 TO WS-LAND-TICK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-TICKS
         ADD 1 TO CW-TIME
         IF WS-CHASED = 1
             MOVE 20 TO PL-HEALTH(WS-PLAYER)
             MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
             COMPUTE PL-X(WS-PLAYER) = WS-CX + 8.5
             MOVE WS-FZ TO PL-Z(WS-PLAYER)
         END-IF
         CALL "MOBS-TICK"
         COMPUTE WS-STEP = FUNCTION SQRT((EN-X(WS-MOB) - WS-PREV-X) ** 2 + (EN-Z(WS-MOB) - WS-PREV-Z) ** 2)
         IF WS-PREV-GROUND = 1 AND EN-ON-GROUND(WS-MOB) = 0
             ADD 1 TO WS-HOPS
             IF WS-HOPS = 1
                 MOVE WS-STEP TO WS-TAKEOFF-STEP
             END-IF
         END-IF
         IF WS-PREV-GROUND = 0 AND EN-ON-GROUND(WS-MOB) = 1
             MOVE WS-I TO WS-LAND-TICK
         END-IF
         IF WS-PREV-GROUND = 1 AND EN-ON-GROUND(WS-MOB) = 1
             ADD 1 TO WS-GROUND-RUN
             IF WS-GROUND-RUN > WS-MAX-GROUND-RUN
                 MOVE WS-GROUND-RUN TO WS-MAX-GROUND-RUN
             END-IF
             IF WS-I - WS-LAND-TICK >= 12 AND WS-STEP > 0.002
                 ADD 1 TO WS-STILL-BAD
             END-IF
         ELSE
             MOVE 0 TO WS-GROUND-RUN
         END-IF
*>       The first hop: from its takeoff tick to the tick before the second one.
         IF WS-HOPS = 1
             ADD WS-STEP TO WS-HOP-LENGTH
             IF EN-Y(WS-MOB) - WS-FLOOR - 1 > WS-PEAK
                 COMPUTE WS-PEAK = EN-Y(WS-MOB) - WS-FLOOR - 1
             END-IF
         END-IF
         MOVE EN-ON-GROUND(WS-MOB) TO WS-PREV-GROUND
         MOVE EN-X(WS-MOB) TO WS-PREV-X
         MOVE EN-Y(WS-MOB) TO WS-PREV-Y
         MOVE EN-Z(WS-MOB) TO WS-PREV-Z
     END-PERFORM
     COMPUTE WS-END-DISTANCE = FUNCTION SQRT((EN-X(WS-MOB) - PL-X(WS-PLAYER)) ** 2 + (EN-Z(WS-MOB) - PL-Z(WS-PLAYER)) ** 2)
     CALL "ENTITY-REMOVE" USING WS-MOB
     .

*> The hop by the rules of the header: speed 0.2 + 0.1 x size; the takeoff tick adds speed squared along the yaw and drags by 0.546; each air tick adds 0.02 x
*> speed and drags by 0.91 (the landing tick included, which starts in the air); then 0.546 a tick on the ground. The vertical: the move by the speed
*> comes first, then (v - 0.08) x 0.98. WS-SIM-AIR is the landing tick (ticks after the takeoff tick), WS-SIM-DIST the length of the hop with its slide,
*> WS-SIM-PEAK the height reached.
 SIMULATE-HOP.
     COMPUTE WS-SPEED = 0.2 + 0.1 * WS-SIZE
     MOVE 0.42 TO WS-JUMP
     IF WS-SCENARIO-KEY = "magma_cube"
         COMPUTE WS-JUMP = 0.42 + 0.1 * WS-SIZE
     END-IF
     MOVE WS-JUMP TO WS-SIM-VY
     MOVE WS-JUMP TO WS-SIM-H WS-SIM-PEAK
     COMPUTE WS-SIM-VY = (WS-SIM-VY - 0.08) * 0.98
     MOVE 0 TO WS-SIM-AIR WS-SIM-DONE
     PERFORM UNTIL WS-SIM-DONE = 1
         ADD 1 TO WS-SIM-AIR
         IF WS-SIM-H + WS-SIM-VY <= 0
             MOVE 1 TO WS-SIM-DONE
         ELSE
             COMPUTE WS-SIM-H = WS-SIM-H + WS-SIM-VY
             IF WS-SIM-H > WS-SIM-PEAK
                 MOVE WS-SIM-H TO WS-SIM-PEAK
             END-IF
             COMPUTE WS-SIM-VY = (WS-SIM-VY - 0.08) * 0.98
         END-IF
     END-PERFORM
     COMPUTE WS-SIM-V = WS-SPEED * WS-SPEED
     MOVE WS-SIM-V TO WS-SIM-DIST
     COMPUTE WS-SIM-V = WS-SIM-V * 0.546
     PERFORM WS-SIM-AIR TIMES
         COMPUTE WS-SIM-V = WS-SIM-V + 0.02 * WS-SPEED
         COMPUTE WS-SIM-DIST = WS-SIM-DIST + WS-SIM-V
         COMPUTE WS-SIM-V = WS-SIM-V * 0.91
     END-PERFORM
     PERFORM 60 TIMES
         COMPUTE WS-SIM-DIST = WS-SIM-DIST + WS-SIM-V
         COMPUTE WS-SIM-V = WS-SIM-V * 0.546
     END-PERFORM
     .

 ASSERT-HOPS.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO TL-CASE
     STRING "test stdmob cube hop: " DELIMITED BY SIZE FUNCTION TRIM(WS-CASE-NAME) DELIMITED BY SIZE
         " takes off a plausible number of times (hops)" DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-HOPS TO TL-EXPECTED-N
     MOVE WS-HOPS TO TL-OBSERVED-N
     IF WS-HOPS < WS-LOW OR WS-HOPS > WS-HIGH
         COMPUTE TL-EXPECTED-N = WS-LOW
         MOVE WS-HOPS TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

 ASSERT-STILL.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO TL-CASE
     STRING "test stdmob cube hop: " DELIMITED BY SIZE FUNCTION TRIM(WS-CASE-NAME) DELIMITED BY SIZE
         " stands still between hops (ticks it slid)" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-STILL-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

*> The measured length of the first hop is within 4 percent of the simulated one (milli blocks).
 ASSERT-LENGTH.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO TL-CASE
     STRING "test stdmob cube hop: " DELIMITED BY SIZE FUNCTION TRIM(WS-CASE-NAME) DELIMITED BY SIZE
         " hops the documented length (milli blocks)" DELIMITED BY SIZE INTO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-SIM-DIST * 1000
     COMPUTE TL-OBSERVED-N = WS-HOP-LENGTH * 1000
     COMPUTE WS-DIFF = FUNCTION ABS(WS-HOP-LENGTH - WS-SIM-DIST)
     IF WS-DIFF * 100 <= WS-SIM-DIST * 4
         MOVE TL-EXPECTED-N TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .

 ASSERT-PEAK.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO TL-CASE
     STRING "test stdmob cube hop: " DELIMITED BY SIZE FUNCTION TRIM(WS-CASE-NAME) DELIMITED BY SIZE
         " jumps the documented height (milli blocks)" DELIMITED BY SIZE INTO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-SIM-PEAK * 1000
     COMPUTE TL-OBSERVED-N = WS-PEAK * 1000
     COMPUTE WS-DIFF = FUNCTION ABS(WS-PEAK - WS-SIM-PEAK)
     IF WS-DIFF <= 0.01
         MOVE TL-EXPECTED-N TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-STDMOB-CUBE-HOP.
 COPY CORETEST.
