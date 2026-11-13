*> World simulation of docs/protocol/33 as programs of plain numbers (sections 1 to 10) and the wiring of the block-update machinery of
*> 29 into the game tick (WORLDSIM-TICK, WORLDSIM-FLUSH, section 2.1). Prefixes: WT- server tick, WL- level tick, WC- clocks and time,
*> WW- weather, WS- sleeping, WP- spawn, WB- world border, GR- game rules, DF- difficulty, SV- saved layout. What lives in the world is
*> passed in as numbers by the caller; floats are FLOAT-LONG (the artifact's single-precision values are rounded with cc_f64_f32_round
*> where the section says float).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WT-PAUSE.
*> USING players connected, the tick-rate manager is sprinting, pause-when-empty seconds, empty ticks in and out (BINARY-LONG), paused out,
*> autosave once out: tickServer step 1 (1.1): P = seconds * 20; with P above 0 the counter counts ticks without players (reset otherwise or
*> while sprinting); at P or more the tick only runs the connections; the first such tick (counter = P) autosaves once.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYERS              BINARY-LONG.
 01 L-SPRINT               BINARY-LONG.
 01 L-SECONDS              BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-PAUSED               BINARY-LONG.
 01 L-SAVE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYERS L-SPRINT L-SECONDS L-EMPTY L-PAUSED L-SAVE.
     COMPUTE WS-P = L-SECONDS * 20
     MOVE 0 TO L-PAUSED L-SAVE
     IF WS-P > 0
         IF L-PLAYERS = 0 AND L-SPRINT = 0
             ADD 1 TO L-EMPTY
         ELSE
             MOVE 0 TO L-EMPTY
         END-IF
         IF L-EMPTY >= WS-P
             MOVE 1 TO L-PAUSED
         END-IF
         IF L-EMPTY = WS-P
             MOVE 1 TO L-SAVE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WT-PAUSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WT-HEARTBEAT.
*> USING the server's tick count after its increment (BINARY-LONG), send out: the empty-map Set Time of tickChildren step 4 every 20 ticks.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-SEND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-SEND.
     MOVE 0 TO L-SEND
     IF FUNCTION MOD(L-COUNT, 20) = 0
         MOVE 1 TO L-SEND
     END-IF
     GOBACK.
 END PROGRAM WT-HEARTBEAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WT-AUTOSAVE.
*> USING ticks until autosave in and out (BINARY-LONG), the tick rate (FLOAT-LONG), save out: 1.1 step 6: decremented every tick; at 0 or
*> below the world is saved and the countdown restarts at max(100, (int)(rate * 300)).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RESET               BINARY-LONG.
 LINKAGE SECTION.
 01 L-LEFT                 BINARY-LONG.
 01 L-RATE                 FLOAT-LONG.
 01 L-SAVE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-LEFT L-RATE L-SAVE.
     MOVE 0 TO L-SAVE
     SUBTRACT 1 FROM L-LEFT
     IF L-LEFT <= 0
         MOVE 1 TO L-SAVE
         COMPUTE WS-RESET = FUNCTION INTEGER(L-RATE * 300)
         IF WS-RESET < 100
             MOVE 100 TO WS-RESET
         END-IF
         MOVE WS-RESET TO L-LEFT
     END-IF
     GOBACK.
 END PROGRAM WT-AUTOSAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WT-LATENCY.
*> USING the PlayerList counter in and out (BINARY-LONG), send out: step 8 of tickChildren: incremented on each tick, the latency update is
*> broadcast when it is above 600 and the counter is reset.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNTER              BINARY-LONG.
 01 L-SEND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNTER L-SEND.
     MOVE 0 TO L-SEND
     ADD 1 TO L-COUNTER
     IF L-COUNTER > 600
         MOVE 1 TO L-SEND
         MOVE 0 TO L-COUNTER
     END-IF
     GOBACK.
 END PROGRAM WT-LATENCY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WT-STATUS.
*> USING nanoseconds since the last status rebuild (BINARY-DOUBLE), rebuild out: step 5 of tickServer: at least 5 seconds.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NANOS                BINARY-DOUBLE.
 01 L-REBUILD              BINARY-LONG.
 PROCEDURE DIVISION USING L-NANOS L-REBUILD.
     MOVE 0 TO L-REBUILD
     IF L-NANOS >= 5000000000
         MOVE 1 TO L-REBUILD
     END-IF
     GOBACK.
 END PROGRAM WT-STATUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WT-CHILD-RUNS.
*> USING step of tickChildren (1 to 12, the table of 1.2), the game runs normally (BINARY-LONG), runs out: the steps behind the tick manager are
*> the clock tick (3) and the game tests (9); everything else runs every tick.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STEP                 BINARY-LONG.
 01 L-NORMAL               BINARY-LONG.
 01 L-RUNS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STEP L-NORMAL L-RUNS.
     MOVE 1 TO L-RUNS
     IF (L-STEP = 3 OR L-STEP = 9) AND L-NORMAL = 0
         MOVE 0 TO L-RUNS
     END-IF
     GOBACK.
 END PROGRAM WT-CHILD-RUNS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WT-LEVEL-ORDER.
*> USING place (1 to 3), dimension row out: the CobolCraft rule of 1.2 step 6 and open question 2: overworld, Nether, End.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PLACE                BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PLACE L-DIM.
     MOVE L-PLACE TO L-DIM
     GOBACK.
 END PROGRAM WT-LEVEL-ORDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WL-STEP-RUNS.
*> USING step of the level tick (1 to 12, 2.1), the game runs normally (BINARY-LONG), runs out: steps 2 (border and weather), 5 (time tick), 6
*> (block and fluid ticks), 7 (raids) and 9 (block events) need `runs`; the sleep check (3), skyDarken (4), the chunk source (8, which
*> checks `runs` inside), the empty counter (10), the entity phase (11) and the entity manager (12) always run. Step 1 always runs.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STEP                 BINARY-LONG.
 01 L-NORMAL               BINARY-LONG.
 01 L-RUNS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STEP L-NORMAL L-RUNS.
     MOVE 1 TO L-RUNS
     IF (L-STEP = 2 OR L-STEP = 5 OR L-STEP = 6 OR L-STEP = 7 OR L-STEP = 9) AND L-NORMAL = 0
         MOVE 0 TO L-RUNS
     END-IF
     GOBACK.
 END PROGRAM WL-STEP-RUNS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WL-EMPTY.
*> USING the chunk source has active tickets, the game runs normally (BINARY-LONG), emptyTime in and out, entity phase out: step 10 and 11 of
*> 2.1: tickets reset the counter to 0, a normal tick adds 1; entities and block entities run while emptyTime < 300.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TICKETS              BINARY-LONG.
 01 L-NORMAL               BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-PHASE                BINARY-LONG.
 PROCEDURE DIVISION USING L-TICKETS L-NORMAL L-EMPTY L-PHASE.
     IF L-TICKETS = 1
         MOVE 0 TO L-EMPTY
     END-IF
     IF L-NORMAL = 1
         ADD 1 TO L-EMPTY
     END-IF
     MOVE 0 TO L-PHASE
     IF L-EMPTY < 300
         MOVE 1 TO L-PHASE
     END-IF
     GOBACK.
 END PROGRAM WL-EMPTY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WL-CHUNK-STEPS.
*> USING the chunk is in the entity-ticking range, the category list is empty, the chunk is inside the border and entities may tick there
*> (BINARY-LONG), thunder out, spawn out: tickSpawningChunk (2.2 step 4): the inhabited time grows always; thunder runs in the entity-ticking
*> range; an empty category list stops the chunk; spawning needs the border and entity-ticking permission.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RANGE                BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-BORDER               BINARY-LONG.
 01 L-THUNDER              BINARY-LONG.
 01 L-SPAWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-RANGE L-EMPTY L-BORDER L-THUNDER L-SPAWN.
     MOVE L-RANGE TO L-THUNDER
     MOVE 0 TO L-SPAWN
     IF L-EMPTY = 0 AND L-BORDER = 1
         MOVE 1 TO L-SPAWN
     END-IF
     GOBACK.
 END PROGRAM WL-CHUNK-STEPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WL-ICE-ATTEMPT.
*> USING nextInt(48) draw (BINARY-LONG), attempt out: tickChunk step 1 (2.4): one precipitation attempt when the draw is 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 BINARY-LONG.
 01 L-ATTEMPT              BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-ATTEMPT.
     MOVE 0 TO L-ATTEMPT
     IF L-DRAW = 0
         MOVE 1 TO L-ATTEMPT
     END-IF
     GOBACK.
 END PROGRAM WL-ICE-ATTEMPT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WL-RANDOM-POS.
*> USING randValue in and out (BINARY-LONG), x0, y0, z0, mask (BINARY-LONG), x, y, z out: randomBlockPos (2.4): randValue = randValue * 3 +
*> 1013904223 in 32-bit wrapping arithmetic, i = randValue >> 2 (arithmetic), the result (x0 + (i & 15), y0 + ((i >> 16) & mask), z0 +
*> ((i >> 8) & 15)).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-V                   BINARY-DOUBLE.
 01 WS-I                   BINARY-DOUBLE.
 01 WS-Q                   BINARY-DOUBLE.
 01 WS-P32                 BINARY-DOUBLE VALUE 4294967296.
 01 WS-P31                 BINARY-DOUBLE VALUE 2147483648.
 LINKAGE SECTION.
 01 L-RAND                 BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-MASK                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-RAND L-X0 L-Y0 L-Z0 L-MASK L-X L-Y L-Z.
     COMPUTE WS-V = L-RAND * 3 + 1013904223
     COMPUTE WS-V = FUNCTION MOD(WS-V + WS-P31, WS-P32) - WS-P31
     MOVE WS-V TO L-RAND
     COMPUTE WS-I = FUNCTION INTEGER(WS-V / 4)
     COMPUTE L-X = L-X0 + FUNCTION MOD(WS-I, 16)
     COMPUTE WS-Q = FUNCTION INTEGER(WS-I / 65536)
     COMPUTE L-Y = L-Y0 + FUNCTION MOD(FUNCTION MOD(WS-Q, 16), L-MASK + 1)
     COMPUTE WS-Q = FUNCTION INTEGER(WS-I / 256)
     COMPUTE L-Z = L-Z0 + FUNCTION MOD(WS-Q, 16)
     GOBACK.
 END PROGRAM WL-RANDOM-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WL-RANDOM-WORK.
*> USING random_tick_speed, the section holds random-ticking blocks or fluids (BINARY-LONG), precipitation attempts out, section positions out:
*> per chunk and tick `speed` attempts of the 1 in 48 draw, and per section with random-ticking content `speed` positions (2.4, worked example 9).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SPEED                BINARY-LONG.
 01 L-TICKING              BINARY-LONG.
 01 L-ATTEMPTS             BINARY-LONG.
 01 L-POSITIONS            BINARY-LONG.
 PROCEDURE DIVISION USING L-SPEED L-TICKING L-ATTEMPTS L-POSITIONS.
     MOVE L-SPEED TO L-ATTEMPTS
     MOVE 0 TO L-POSITIONS
     IF L-SPEED > 0 AND L-TICKING = 1
         MOVE L-SPEED TO L-POSITIONS
     END-IF
     GOBACK.
 END PROGRAM WL-RANDOM-WORK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WC-CLOCK.
*> USING the clock's partial tick, rate (FLOAT-LONG), total ticks in and out (BINARY-LONG), advance_time, paused (BINARY-LONG), partial tick out
*> (FLOAT-LONG): ServerClockManager.tick (3.2): with advance_time and the clock not paused, partial += rate, n = floor(partial), partial -= n,
*> total += n.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-RATE                 FLOAT-LONG.
 01 L-TOTAL                BINARY-LONG.
 01 L-ADVANCE              BINARY-LONG.
 01 L-PAUSED               BINARY-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-PARTIAL L-RATE L-TOTAL L-ADVANCE L-PAUSED L-OUT.
     MOVE L-PARTIAL TO L-OUT
     IF L-ADVANCE = 1 AND L-PAUSED = 0
         COMPUTE L-OUT = L-PARTIAL + L-RATE
         COMPUTE WS-N = FUNCTION INTEGER(L-OUT)
         COMPUTE L-OUT = L-OUT - WS-N
         ADD WS-N TO L-TOTAL
     END-IF
     GOBACK.
 END PROGRAM WC-CLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WC-ADD-TICKS.
*> USING total ticks in and out, ticks to add (BINARY-LONG, may be negative), partial tick in and out (FLOAT-LONG), set (BINARY-LONG, 1 setTotalTicks):
*> the manager writes of 3.2: setTotalTicks resets the partial tick; addTicks clamps the total at 0 from below.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TOTAL                BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-SET                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TOTAL L-TICKS L-PARTIAL L-SET.
     IF L-SET = 1
         MOVE L-TICKS TO L-TOTAL
         MOVE 0 TO L-PARTIAL
     ELSE
         ADD L-TICKS TO L-TOTAL
         IF L-TOTAL < 0
             MOVE 0 TO L-TOTAL
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WC-ADD-TICKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WC-MARKER.
*> USING the marker's ticks, period (0 none), the clock total (BINARY-LONG), occurs out, resolved total out: occursAt and
*> resolveTimeToMoveTo of 3.3; with a period the result is strictly in the future.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-C                   BINARY-DOUBLE.
 01 WS-D                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-TICKS                BINARY-LONG.
 01 L-PERIOD               BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 01 L-OCCURS               BINARY-LONG.
 01 L-RESOLVED             BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-TICKS L-PERIOD L-TOTAL L-OCCURS L-RESOLVED.
     MOVE 0 TO L-OCCURS
     IF L-PERIOD = 0
         MOVE L-TICKS TO L-RESOLVED
         IF L-TICKS = L-TOTAL
             MOVE 1 TO L-OCCURS
         END-IF
     ELSE
         COMPUTE WS-C = FUNCTION MOD(L-TOTAL, L-PERIOD)
         COMPUTE WS-D = L-TICKS - WS-C
         IF L-TICKS = WS-C
             MOVE 1 TO L-OCCURS
         END-IF
         IF WS-D > 0
             COMPUTE L-RESOLVED = L-TOTAL + WS-D
         ELSE
             COMPUTE L-RESOLVED = L-TOTAL + L-PERIOD + WS-D
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WC-MARKER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WC-MOVE-STATUS.
*> USING the clock has the marker, the marker occurs at the total already (BINARY-LONG), status out (1 NO_TIME_MARKER_FOUND, 2 NOT_MOVED, 0
*> moved): moveToTimeMarker (3.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAS                  BINARY-LONG.
 01 L-OCCURS               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS L-OCCURS L-STATUS.
     MOVE 0 TO L-STATUS
     IF L-HAS = 0
         MOVE 1 TO L-STATUS
     END-IF
     IF L-HAS = 1 AND L-OCCURS = 1
         MOVE 2 TO L-STATUS
     END-IF
     GOBACK.
 END PROGRAM WC-MOVE-STATUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WC-TIMELINE.
*> USING clock total, period (0 none) (BINARY-LONG), current ticks out, period count out: getCurrentTicks and getPeriodCount (3.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TOTAL                BINARY-LONG.
 01 L-PERIOD               BINARY-LONG.
 01 L-CURRENT              BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-TOTAL L-PERIOD L-CURRENT L-COUNT.
     MOVE L-TOTAL TO L-CURRENT
     MOVE 0 TO L-COUNT
     IF L-PERIOD > 0
         COMPUTE L-CURRENT = FUNCTION MOD(L-TOTAL, L-PERIOD)
         COMPUTE L-COUNT = FUNCTION INTEGER(L-TOTAL / L-PERIOD)
     END-IF
     GOBACK.
 END PROGRAM WC-TIMELINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WC-KEYFRAME.
*> USING the progress between two keyframes (0 to 1), the earlier and later value (FLOAT-LONG), interpolated (BINARY-LONG, 1 for floats, integers,
*> angles and colours, 0 for booleans, enums and the other types), value out (FLOAT-LONG): keyframeLerp (3.4): linear, or the earlier value held
*> until the progress reaches 1.0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PROGRESS             FLOAT-LONG.
 01 L-A                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-LINEAR               BINARY-LONG.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-PROGRESS L-A L-B L-LINEAR L-VALUE.
     IF L-LINEAR = 1
         COMPUTE L-VALUE = L-A + L-PROGRESS * (L-B - L-A)
     ELSE
         MOVE L-A TO L-VALUE
         IF L-PROGRESS >= 1.0
             MOVE L-B TO L-VALUE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WC-KEYFRAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WC-SKY-DARKEN.
*> USING the dimension-wide sky_light_level (FLOAT-LONG), skyDarken out: (int)(15.0f - L) truncated (3.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-F                   FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-LIGHT                FLOAT-LONG.
 01 L-DARKEN               BINARY-LONG.
 PROCEDURE DIVISION USING L-LIGHT L-DARKEN.
     COMPUTE WS-D = 15.0 - L-LIGHT
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-D WS-F
     COMPUTE L-DARKEN = FUNCTION INTEGER-PART(WS-F)
     GOBACK.
 END PROGRAM WC-SKY-DARKEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WC-OUTSIDE.
*> USING the dimension type has a fixed time, skyDarken (BINARY-LONG), bright out, dark out, and the sky light at a position, effective out: 3.5.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FIXED                BINARY-LONG.
 01 L-DARKEN               BINARY-LONG.
 01 L-SKY                  BINARY-LONG.
 01 L-BRIGHT               BINARY-LONG.
 01 L-DARK                 BINARY-LONG.
 01 L-EFFECTIVE            BINARY-LONG.
 PROCEDURE DIVISION USING L-FIXED L-DARKEN L-SKY L-BRIGHT L-DARK L-EFFECTIVE.
     MOVE 0 TO L-BRIGHT L-DARK
     IF L-FIXED = 0
         IF L-DARKEN < 4
             MOVE 1 TO L-BRIGHT
         ELSE
             MOVE 1 TO L-DARK
         END-IF
     END-IF
     COMPUTE L-EFFECTIVE = FUNCTION MAX(0, L-SKY - L-DARKEN)
     GOBACK.
 END PROGRAM WC-OUTSIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WC-WEATHER-SKY.
*> USING the running sky_light_level, rainLevel and thunderLevel (FLOAT-LONG), result out (FLOAT-LONG): the weather layers of 3.6: r' = rain -
*> thunder; with r' above 0 the value becomes a blend towards 4.0 with alpha 0.3125, then with the thunder level above 0 a blend with alpha
*> 0.52734375 (value + alpha * (4.0 - value), the level as the lerp factor).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   FLOAT-LONG.
 01 WS-M                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-VALUE                FLOAT-LONG.
 01 L-RAIN                 FLOAT-LONG.
 01 L-THUNDER              FLOAT-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-VALUE L-RAIN L-THUNDER L-RESULT.
     MOVE L-VALUE TO L-RESULT
     COMPUTE WS-R = L-RAIN - L-THUNDER
     IF WS-R > 0
         COMPUTE WS-M = L-RESULT + 0.3125 * (4.0 - L-RESULT)
         COMPUTE L-RESULT = L-RESULT + WS-R * (WS-M - L-RESULT)
     END-IF
     IF L-THUNDER > 0
         COMPUTE WS-M = L-RESULT + 0.52734375 * (4.0 - L-RESULT)
         COMPUTE L-RESULT = L-RESULT + L-THUNDER * (WS-M - L-RESULT)
     END-IF
     GOBACK.
 END PROGRAM WC-WEATHER-SKY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WC-STATE-LERP.
*> USING the weather level w, the running value, the layer's modified value (FLOAT-LONG), interpolated (BINARY-LONG), value out (FLOAT-LONG):
*> stateChangeLerp (3.4): interpolated types lerp by w; the others switch as soon as w is above 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEVEL                FLOAT-LONG.
 01 L-VALUE                FLOAT-LONG.
 01 L-MODIFIED             FLOAT-LONG.
 01 L-LINEAR               BINARY-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-VALUE L-MODIFIED L-LINEAR L-OUT.
     MOVE L-VALUE TO L-OUT
     IF L-LINEAR = 1
         COMPUTE L-OUT = L-VALUE + L-LEVEL * (L-MODIFIED - L-VALUE)
     END-IF
     IF L-LINEAR = 0 AND L-LEVEL > 0
         MOVE L-MODIFIED TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM WC-STATE-LERP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WC-MOON.
*> USING the overworld clock total (BINARY-LONG), phase out (0 full_moon to 7 waxing_gibbous), brightness out (FLOAT-LONG), slime chance out:
*> the moon of 3.7: a phase per 24000 ticks of the 192000 cycle, the brightness table 1, .75, .5, .25, 0, .25, .5, .75 and the slime track 0.5 at
*> full moon falling by 0.125 per phase (to 0.0 at new moon, then rising again).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BRIGHT              PIC X(8) VALUE "43210123".
 01 WS-DIGIT               PIC 9.
 LINKAGE SECTION.
 01 L-TOTAL                BINARY-LONG.
 01 L-PHASE                BINARY-LONG.
 01 L-BRIGHTNESS           FLOAT-LONG.
 01 L-SLIME                FLOAT-LONG.
 PROCEDURE DIVISION USING L-TOTAL L-PHASE L-BRIGHTNESS L-SLIME.
     COMPUTE L-PHASE = FUNCTION MOD(FUNCTION INTEGER(L-TOTAL / 24000), 8)
     MOVE WS-BRIGHT(L-PHASE + 1:1) TO WS-DIGIT
     COMPUTE L-BRIGHTNESS = WS-DIGIT / 4
     COMPUTE L-SLIME = WS-DIGIT * 0.125
     GOBACK.
 END PROGRAM WC-MOON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WC-SET-TIME-RATE.
*> USING the clock is paused, advance_time, the clock's rate (FLOAT-LONG), wire rate out (FLOAT-LONG): Set Time carries rate 0.0 when the clock is
*> paused or advance_time is false (3.8).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PAUSED               BINARY-LONG.
 01 L-ADVANCE              BINARY-LONG.
 01 L-RATE                 FLOAT-LONG.
 01 L-WIRE                 FLOAT-LONG.
 PROCEDURE DIVISION USING L-PAUSED L-ADVANCE L-RATE L-WIRE.
     MOVE L-RATE TO L-WIRE
     IF L-PAUSED = 1 OR L-ADVANCE = 0
         MOVE 0 TO L-WIRE
     END-IF
     GOBACK.
 END PROGRAM WC-SET-TIME-RATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WW-CAN-HAVE.
*> USING the dimension type has sky light, has a ceiling, the level is the End (BINARY-LONG), result out: Level.canHaveWeather (4.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SKY                  BINARY-LONG.
 01 L-CEILING              BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SKY L-CEILING L-END L-CAN.
     MOVE 0 TO L-CAN
     IF L-SKY = 1 AND L-CEILING = 0 AND L-END = 0
         MOVE 1 TO L-CAN
     END-IF
     GOBACK.
 END PROGRAM WW-CAN-HAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WW-IS.
*> USING can have weather, rainLevel, thunderLevel (FLOAT-LONG), raining out, thundering out: isRaining is rainLevel > 0.2 and isThundering is
*> thunderLevel * rainLevel > 0.9, both only where the level can have weather (4.1); the comparisons are exact (FP-CMP: a COBOL float comparison has a
*> tolerance that would merge 0.20000002 with 0.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-PRODUCT             FLOAT-LONG.
 01 WS-RAIN-LIMIT          FLOAT-LONG VALUE 0.2.
 01 WS-THUNDER-LIMIT       FLOAT-LONG VALUE 0.9.
 01 WS-SIGN                BINARY-LONG.
 LINKAGE SECTION.
 01 L-CAN                  BINARY-LONG.
 01 L-RAIN                 FLOAT-LONG.
 01 L-THUNDER              FLOAT-LONG.
 01 L-RAINING              BINARY-LONG.
 01 L-THUNDERING           BINARY-LONG.
 PROCEDURE DIVISION USING L-CAN L-RAIN L-THUNDER L-RAINING L-THUNDERING.
     MOVE 0 TO L-RAINING L-THUNDERING
     CALL STATIC "cc_f64_mul" USING BY REFERENCE L-THUNDER L-RAIN WS-PRODUCT
     CALL "FP-CMP" USING L-RAIN WS-RAIN-LIMIT WS-SIGN
     IF L-CAN = 1 AND WS-SIGN = 1
         MOVE 1 TO L-RAINING
     END-IF
     CALL "FP-CMP" USING WS-PRODUCT WS-THUNDER-LIMIT WS-SIGN
     IF L-CAN = 1 AND WS-SIGN = 1
         MOVE 1 TO L-THUNDERING
     END-IF
     GOBACK.
 END PROGRAM WW-IS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WW-RANGE.
*> USING which (1 RAIN_DELAY, 2 RAIN_DURATION, 3 THUNDER_DELAY, 4 THUNDER_DURATION), lowest out, highest out (BINARY-LONG): the four uniform
*> distributions of 4.2, both bounds inclusive.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WHICH                BINARY-LONG.
 01 L-LOW                  BINARY-LONG.
 01 L-HIGH                 BINARY-LONG.
 PROCEDURE DIVISION USING L-WHICH L-LOW L-HIGH.
     EVALUATE L-WHICH
         WHEN 2
             MOVE 12000 TO L-LOW
             MOVE 24000 TO L-HIGH
         WHEN 4
             MOVE 3600 TO L-LOW
             MOVE 15600 TO L-HIGH
         WHEN OTHER
             MOVE 12000 TO L-LOW
             MOVE 180000 TO L-HIGH
     END-EVALUATE
     GOBACK.
 END PROGRAM WW-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WW-CYCLE.
*> USING clearWeatherTime, thunderTime, rainTime, thundering, raining (BINARY-LONG, in and out), the thunder sample and the rain sample the
*> caller drew for the distribution the state calls for (BINARY-LONG; thunder before rain, 0 where none is needed), thunder drew out, rain
*> drew out: advanceWeatherCycle part A (4.2), the caller having checked advance_weather. With clear time above 0 it counts down and
*> sets both timers to 0 for flags that were on and 1 for flags that were off, both flags off. Otherwise a timer above 0 counts down and the
*> flag toggles at 0 (nothing drawn in that tick); a timer already 0 or below draws its sample (the duration when the flag is on, else the delay).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLEAR                BINARY-LONG.
 01 L-THUNDER-T            BINARY-LONG.
 01 L-RAIN-T               BINARY-LONG.
 01 L-THUNDER              BINARY-LONG.
 01 L-RAIN                 BINARY-LONG.
 01 L-THUNDER-SAMPLE       BINARY-LONG.
 01 L-RAIN-SAMPLE          BINARY-LONG.
 01 L-THUNDER-DREW         BINARY-LONG.
 01 L-RAIN-DREW            BINARY-LONG.
 PROCEDURE DIVISION USING L-CLEAR L-THUNDER-T L-RAIN-T L-THUNDER L-RAIN L-THUNDER-SAMPLE L-RAIN-SAMPLE L-THUNDER-DREW L-RAIN-DREW.
     MOVE 0 TO L-THUNDER-DREW L-RAIN-DREW
     IF L-CLEAR > 0
         SUBTRACT 1 FROM L-CLEAR
         MOVE 1 TO L-THUNDER-T L-RAIN-T
         IF L-THUNDER = 1
             MOVE 0 TO L-THUNDER-T
         END-IF
         IF L-RAIN = 1
             MOVE 0 TO L-RAIN-T
         END-IF
         MOVE 0 TO L-THUNDER L-RAIN
         GOBACK
     END-IF
     IF L-THUNDER-T > 0
         SUBTRACT 1 FROM L-THUNDER-T
         IF L-THUNDER-T = 0
             IF L-THUNDER = 1
                 MOVE 0 TO L-THUNDER
             ELSE
                 MOVE 1 TO L-THUNDER
             END-IF
         END-IF
     ELSE
         MOVE 1 TO L-THUNDER-DREW
         MOVE L-THUNDER-SAMPLE TO L-THUNDER-T
     END-IF
     IF L-RAIN-T > 0
         SUBTRACT 1 FROM L-RAIN-T
         IF L-RAIN-T = 0
             IF L-RAIN = 1
                 MOVE 0 TO L-RAIN
             ELSE
                 MOVE 1 TO L-RAIN
             END-IF
         END-IF
     ELSE
         MOVE 1 TO L-RAIN-DREW
         MOVE L-RAIN-SAMPLE TO L-RAIN-T
     END-IF
     GOBACK.
 END PROGRAM WW-CYCLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WW-SMOOTH.
*> USING a level (FLOAT-LONG, in and out), the target flag raining or thundering (BINARY-LONG): part B of 4.2: +0.01f or -0.01f in single
*> precision, clamped to 0 to 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-STEP                FLOAT-LONG VALUE 0.01.
 01 WS-STEP32              FLOAT-LONG.
 01 WS-SUM                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-LEVEL                FLOAT-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-FLAG.
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-STEP WS-STEP32
     IF L-FLAG = 1
         COMPUTE WS-SUM = L-LEVEL + WS-STEP32
     ELSE
         COMPUTE WS-SUM = L-LEVEL - WS-STEP32
     END-IF
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-SUM L-LEVEL
     IF L-LEVEL < 0
         MOVE 0 TO L-LEVEL
     END-IF
     IF L-LEVEL > 1
         MOVE 1 TO L-LEVEL
     END-IF
     GOBACK.
 END PROGRAM WW-SMOOTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WW-PACKETS.
*> USING the previous and current rain level, the previous and current thunder level (FLOAT-LONG), wasRaining, isRaining (BINARY-LONG), rain
*> level event out (1 sends Game Event 7 to this dimension), thunder level event out (1 sends Game Event 8), start or stop out (0 none, 1
*> Game Event 2 stop raining to all, 2 Game Event 1 start raining to all, each followed by Game Events 7 and 8 to all): part C of 4.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-O-RAIN               FLOAT-LONG.
 01 L-RAIN                 FLOAT-LONG.
 01 L-O-THUNDER            FLOAT-LONG.
 01 L-THUNDER              FLOAT-LONG.
 01 L-WAS                  BINARY-LONG.
 01 L-IS                   BINARY-LONG.
 01 L-RAIN-EVENT           BINARY-LONG.
 01 L-THUNDER-EVENT        BINARY-LONG.
 01 L-CHANGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-O-RAIN L-RAIN L-O-THUNDER L-THUNDER L-WAS L-IS L-RAIN-EVENT L-THUNDER-EVENT L-CHANGE.
     MOVE 0 TO L-RAIN-EVENT L-THUNDER-EVENT L-CHANGE
     IF L-O-RAIN NOT = L-RAIN
         MOVE 1 TO L-RAIN-EVENT
     END-IF
     IF L-O-THUNDER NOT = L-THUNDER
         MOVE 1 TO L-THUNDER-EVENT
     END-IF
     IF L-WAS = 1 AND L-IS = 0
         MOVE 1 TO L-CHANGE
     END-IF
     IF L-WAS = 0 AND L-IS = 1
         MOVE 2 TO L-CHANGE
     END-IF
     GOBACK.
 END PROGRAM WW-PACKETS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WW-SET.
*> USING clear time, rain time, raining, thundering (BINARY-LONG), clearWeatherTime out, rainTime out, thunderTime out, raining out, thundering
*> out: setWeatherParameters (4.3): thunderTime = rainTime. And the sleep reset (4.6): rain and thunder times 0, both flags off, the clear time
*> left alone, when `reset` is 1 (the clear time in is then kept in the out value).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CLEAR                BINARY-LONG.
 01 L-RAIN-T               BINARY-LONG.
 01 L-RAINING              BINARY-LONG.
 01 L-THUNDERING           BINARY-LONG.
 01 L-RESET                BINARY-LONG.
 01 L-O-CLEAR              BINARY-LONG.
 01 L-O-RAIN-T             BINARY-LONG.
 01 L-O-THUNDER-T          BINARY-LONG.
 01 L-O-RAINING            BINARY-LONG.
 01 L-O-THUNDERING         BINARY-LONG.
 PROCEDURE DIVISION USING L-CLEAR L-RAIN-T L-RAINING L-THUNDERING L-RESET L-O-CLEAR L-O-RAIN-T L-O-THUNDER-T L-O-RAINING
         L-O-THUNDERING.
     MOVE L-CLEAR TO L-O-CLEAR
     IF L-RESET = 1
         MOVE 0 TO L-O-RAIN-T L-O-THUNDER-T L-O-RAINING L-O-THUNDERING
     ELSE
         MOVE L-RAIN-T TO L-O-RAIN-T L-O-THUNDER-T
         MOVE L-RAINING TO L-O-RAINING
         MOVE L-THUNDERING TO L-O-THUNDERING
     END-IF
     GOBACK.
 END PROGRAM WW-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WW-TEMPERATURE.
*> USING the biome base temperature, block y, sea level, the temperature noise at (x / 8, z / 8) (FLOAT-LONG; y and sea BINARY-LONG), temperature
*> out (FLOAT-LONG): 4.5: up to sea + 17 the base temperature, above T0 - (N * 8 + y - (sea + 17)) * 0.05f / 40.0f.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIMIT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-BASE                 FLOAT-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-SEA                  BINARY-LONG.
 01 L-NOISE                FLOAT-LONG.
 01 L-TEMPERATURE          FLOAT-LONG.
 PROCEDURE DIVISION USING L-BASE L-Y L-SEA L-NOISE L-TEMPERATURE.
     COMPUTE WS-LIMIT = L-SEA + 17
     MOVE L-BASE TO L-TEMPERATURE
     IF L-Y > WS-LIMIT
         COMPUTE L-TEMPERATURE = L-BASE - (L-NOISE * 8 + L-Y - WS-LIMIT) * 0.05 / 40.0
     END-IF
     GOBACK.
 END PROGRAM WW-TEMPERATURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WW-PRECIPITATION.
*> USING the biome has precipitation (BINARY-LONG), the temperature (FLOAT-LONG), precipitation out (0 NONE, 1 RAIN, 2 SNOW), warm enough to rain
*> out: getPrecipitationAt and warmEnoughToRain (4.5; the threshold 0.15f, a float compare).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-LIMIT               FLOAT-LONG VALUE 0.15.
 01 WS-LIMIT32             FLOAT-LONG.
 01 WS-T32                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-HAS                  BINARY-LONG.
 01 L-TEMPERATURE          FLOAT-LONG.
 01 L-PRECIP               BINARY-LONG.
 01 L-WARM                 BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS L-TEMPERATURE L-PRECIP L-WARM.
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-LIMIT WS-LIMIT32
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE L-TEMPERATURE WS-T32
     MOVE 0 TO L-WARM
     IF WS-T32 >= WS-LIMIT32
         MOVE 1 TO L-WARM
     END-IF
     MOVE 0 TO L-PRECIP
     IF L-HAS = 1
         MOVE 2 TO L-PRECIP
         IF L-WARM = 1
             MOVE 1 TO L-PRECIP
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WW-PRECIPITATION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WW-FREEZE.
*> USING warm enough to rain at the position, the position is inside the build height, block light at it, source water in a liquid block there,
*> all four horizontal neighbours are water (BINARY-LONG), freeze out: Biome.shouldFreeze (4.4 step 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WARM                 BINARY-LONG.
 01 L-INSIDE               BINARY-LONG.
 01 L-LIGHT                BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-SURROUNDED           BINARY-LONG.
 01 L-FREEZE               BINARY-LONG.
 PROCEDURE DIVISION USING L-WARM L-INSIDE L-LIGHT L-SOURCE L-SURROUNDED L-FREEZE.
     MOVE 0 TO L-FREEZE
     IF L-WARM = 0 AND L-INSIDE = 1 AND L-LIGHT < 10 AND L-SOURCE = 1 AND L-SURROUNDED = 0
         MOVE 1 TO L-FREEZE
     END-IF
     GOBACK.
 END PROGRAM WW-FREEZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WW-SNOW.
*> USING max_snow_accumulation_height, is raining, precipitation at the top is SNOW, inside the build height, block light, the block at the top
*> is air, it is a snow layer, its layers, snow can survive there (BINARY-LONG), action out (0 nothing, 1 one new layer, 2 add a layer), new layers
*> out: 4.4 step 2.1: h above 0, raining and shouldSnow; a layer block below min(h, 8) grows by one, air becomes one layer.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIMIT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-HEIGHT               BINARY-LONG.
 01 L-RAINING              BINARY-LONG.
 01 L-SNOWY                BINARY-LONG.
 01 L-INSIDE               BINARY-LONG.
 01 L-LIGHT                BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-LAYER                BINARY-LONG.
 01 L-LAYERS               BINARY-LONG.
 01 L-SURVIVES             BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-HEIGHT L-RAINING L-SNOWY L-INSIDE L-LIGHT L-AIR L-LAYER L-LAYERS L-SURVIVES L-ACTION L-NEW.
     MOVE 0 TO L-ACTION
     MOVE L-LAYERS TO L-NEW
     MOVE L-HEIGHT TO WS-LIMIT
     IF WS-LIMIT > 8
         MOVE 8 TO WS-LIMIT
     END-IF
     IF L-RAINING = 1 AND L-HEIGHT > 0 AND L-SNOWY = 1 AND L-INSIDE = 1 AND L-LIGHT < 10 AND (L-AIR = 1 OR L-LAYER = 1)
             AND L-SURVIVES = 1
         IF L-LAYER = 1 AND L-LAYERS < WS-LIMIT
             MOVE 2 TO L-ACTION
             COMPUTE L-NEW = L-LAYERS + 1
         END-IF
         IF L-AIR = 1
             MOVE 1 TO L-ACTION
             MOVE 1 TO L-NEW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WW-SNOW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WW-CAULDRON.
*> USING precipitation (1 RAIN, 2 SNOW), the cauldron is empty, the level of a layered cauldron of the same kind (0 none), nextFloat draw
*> (FLOAT-LONG), new kind out (0 unchanged, 1 water, 2 powder snow), new level out: handlePrecipitation of the cauldrons (4.4): RAIN_FILL_CHANCE
*> 0.05 and POWDER_SNOW_FILL_CHANCE 0.1; an empty one becomes level 1, a layered one below level 3 gains one.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PRECIP               BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PRECIP L-EMPTY L-LEVEL L-DRAW L-KIND L-NEW.
     MOVE 0 TO L-KIND
     MOVE L-LEVEL TO L-NEW
     IF (L-PRECIP = 1 AND L-DRAW < 0.05) OR (L-PRECIP = 2 AND L-DRAW < 0.1)
         IF L-EMPTY = 1
             MOVE L-PRECIP TO L-KIND
             MOVE 1 TO L-NEW
         END-IF
         IF L-EMPTY = 0 AND L-LEVEL > 0 AND L-LEVEL < 3
             MOVE L-PRECIP TO L-KIND
             COMPUTE L-NEW = L-LEVEL + 1
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WW-CAULDRON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WW-THUNDER.
*> USING isRaining, isThundering, nextInt(100000) draw (BINARY-LONG), raining at the target, spawn_mobs, nextDouble draw, effective difficulty
*> (FLOAT-LONG), the block under the target is in the tag lightning_rods (BINARY-LONG), strike out, trap out, bolt visual only out: tickThunder (4.4):
*> the strike needs rain, thunder and a draw of 0, then rain at the target; the skeleton trap needs spawn_mobs, nextDouble < e * 0.01 and no
*> lightning rod under the target; the bolt is visual only when it is a trap. The nextDouble comparison is exact (FP-CMP).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-HUNDREDTH           FLOAT-LONG VALUE 0.01.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-SIGN                BINARY-LONG.
 LINKAGE SECTION.
 01 L-RAINING              BINARY-LONG.
 01 L-THUNDERING           BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-RAIN-AT              BINARY-LONG.
 01 L-SPAWN-MOBS           BINARY-LONG.
 01 L-DOUBLE               FLOAT-LONG.
 01 L-DIFFICULTY           FLOAT-LONG.
 01 L-ROD                  BINARY-LONG.
 01 L-STRIKE               BINARY-LONG.
 01 L-TRAP                 BINARY-LONG.
 01 L-VISUAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-RAINING L-THUNDERING L-DRAW L-RAIN-AT L-SPAWN-MOBS L-DOUBLE L-DIFFICULTY L-ROD L-STRIKE L-TRAP L-VISUAL.
     MOVE 0 TO L-STRIKE L-TRAP L-VISUAL
     CALL STATIC "cc_f64_mul" USING BY REFERENCE L-DIFFICULTY WS-HUNDREDTH WS-LIMIT
     CALL "FP-CMP" USING L-DOUBLE WS-LIMIT WS-SIGN
     IF L-RAINING = 1 AND L-THUNDERING = 1 AND L-DRAW = 0 AND L-RAIN-AT = 1
         MOVE 1 TO L-STRIKE
         IF L-SPAWN-MOBS = 1 AND L-ROD = 0 AND WS-SIGN = -1
             MOVE 1 TO L-TRAP
             MOVE 1 TO L-VISUAL
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WW-THUNDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WS-RULE-TEST.
*> USING the rule value (0 always, 1 when_dark, 2 never), the level is dark outside (BINARY-LONG), result out: a bed rule test (5.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RULE                 BINARY-LONG.
 01 L-DARK                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-RULE L-DARK L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-RULE = 0 OR (L-RULE = 1 AND L-DARK = 1)
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM WS-RULE-TEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WS-NEEDED.
*> USING active players, players_sleeping_percentage (BINARY-LONG), needed out: sleepersNeeded (5.4): max(1, ceil(active * pct / 100.0f)) with the
*> product in 32-bit int arithmetic (wrapping) and a float division.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-PRODUCT             BINARY-DOUBLE.
 01 WS-P32                 BINARY-DOUBLE VALUE 4294967296.
 01 WS-P31                 BINARY-DOUBLE VALUE 2147483648.
 01 WS-QUOTIENT            FLOAT-LONG.
 01 WS-Q32                 FLOAT-LONG.
 01 WS-CEIL                BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-ACTIVE               BINARY-LONG.
 01 L-PERCENT              BINARY-LONG.
 01 L-NEEDED               BINARY-LONG.
 PROCEDURE DIVISION USING L-ACTIVE L-PERCENT L-NEEDED.
     COMPUTE WS-PRODUCT = L-ACTIVE * L-PERCENT
     COMPUTE WS-PRODUCT = FUNCTION MOD(WS-PRODUCT + WS-P31, WS-P32) - WS-P31
     COMPUTE WS-QUOTIENT = WS-PRODUCT / 100.0
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-QUOTIENT WS-Q32
     COMPUTE WS-CEIL = FUNCTION INTEGER(WS-Q32)
     IF WS-CEIL < WS-Q32
         ADD 1 TO WS-CEIL
     END-IF
     IF WS-CEIL < 1
         MOVE 1 TO WS-CEIL
     END-IF
     MOVE WS-CEIL TO L-NEEDED
     GOBACK.
 END PROGRAM WS-NEEDED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WS-ENOUGH.
*> USING sleeping players, active players, players that slept long enough, percentage (BINARY-LONG), enough sleeping out, enough deeply out, skip
*> out, can sleep through nights out: areEnoughSleeping, areEnoughDeepSleeping and the tick check of 2.1 step 3 (both are needed) (5.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NEEDED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLEEPING             BINARY-LONG.
 01 L-ACTIVE               BINARY-LONG.
 01 L-DEEP                 BINARY-LONG.
 01 L-PERCENT              BINARY-LONG.
 01 L-ENOUGH               BINARY-LONG.
 01 L-ENOUGH-DEEP          BINARY-LONG.
 01 L-SKIP                 BINARY-LONG.
 01 L-THROUGH              BINARY-LONG.
 PROCEDURE DIVISION USING L-SLEEPING L-ACTIVE L-DEEP L-PERCENT L-ENOUGH L-ENOUGH-DEEP L-SKIP L-THROUGH.
     CALL "WS-NEEDED" USING L-ACTIVE L-PERCENT WS-NEEDED
     MOVE 0 TO L-ENOUGH L-ENOUGH-DEEP L-SKIP L-THROUGH
     IF L-SLEEPING >= WS-NEEDED
         MOVE 1 TO L-ENOUGH
     END-IF
     IF L-DEEP >= WS-NEEDED
         MOVE 1 TO L-ENOUGH-DEEP
     END-IF
     IF L-ENOUGH = 1 AND L-ENOUGH-DEEP = 1
         MOVE 1 TO L-SKIP
     END-IF
     IF L-PERCENT <= 100
         MOVE 1 TO L-THROUGH
     END-IF
     GOBACK.
 END PROGRAM WS-ENOUGH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WS-STATUS-UPDATE.
*> USING the new active and sleeping counts, the old ones (BINARY-LONG), changed out: SleepStatus.update (5.4): changed when either count differs
*> and the old or the new sleeping count is above 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ACTIVE               BINARY-LONG.
 01 L-SLEEPING             BINARY-LONG.
 01 L-OLD-ACTIVE           BINARY-LONG.
 01 L-OLD-SLEEPING         BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ACTIVE L-SLEEPING L-OLD-ACTIVE L-OLD-SLEEPING L-CHANGED.
     MOVE 0 TO L-CHANGED
     IF (L-ACTIVE NOT = L-OLD-ACTIVE OR L-SLEEPING NOT = L-OLD-SLEEPING) AND (L-OLD-SLEEPING > 0 OR L-SLEEPING > 0)
         MOVE 1 TO L-CHANGED
     END-IF
     GOBACK.
 END PROGRAM WS-STATUS-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WS-ANNOUNCE.
*> USING percentage, enough sleeping, sleeping players, sleepers needed (BINARY-LONG), message out (0 none, 1 sleep.skipping_night, 2
*> sleep.players_sleeping), shown sleeping out, shown needed out: announceSleepStatus (5.4); nothing above 100.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PERCENT              BINARY-LONG.
 01 L-ENOUGH               BINARY-LONG.
 01 L-SLEEPING             BINARY-LONG.
 01 L-NEEDED               BINARY-LONG.
 01 L-MESSAGE              BINARY-LONG.
 01 L-SHOWN-SLEEPING       BINARY-LONG.
 01 L-SHOWN-NEEDED         BINARY-LONG.
 PROCEDURE DIVISION USING L-PERCENT L-ENOUGH L-SLEEPING L-NEEDED L-MESSAGE L-SHOWN-SLEEPING L-SHOWN-NEEDED.
     MOVE 0 TO L-MESSAGE L-SHOWN-SLEEPING L-SHOWN-NEEDED
     IF L-PERCENT <= 100
         IF L-ENOUGH = 1
             MOVE 1 TO L-MESSAGE
         ELSE
             MOVE 2 TO L-MESSAGE
             MOVE L-SLEEPING TO L-SHOWN-SLEEPING
             MOVE L-NEEDED TO L-SHOWN-NEEDED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WS-ANNOUNCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WS-COUNTER.
*> USING sleeping, the block is a bed whose rule no longer allows sleeping (BINARY-LONG), sleepCounter in and out, wake out, long enough out: the
*> player tick of 5.3: a sleeper's counter grows and caps at 100 and the player wakes when the rule says no; a waker's counter keeps counting and
*> resets at 110; isSleepingLongEnough is sleeping with a counter of 100 or more.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SLEEPING             BINARY-LONG.
 01 L-REFUSED              BINARY-LONG.
 01 L-COUNTER              BINARY-LONG.
 01 L-WAKE                 BINARY-LONG.
 01 L-LONG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SLEEPING L-REFUSED L-COUNTER L-WAKE L-LONG.
     MOVE 0 TO L-WAKE L-LONG
     IF L-SLEEPING = 1
         ADD 1 TO L-COUNTER
         IF L-COUNTER > 100
             MOVE 100 TO L-COUNTER
         END-IF
         IF L-REFUSED = 1
             MOVE 1 TO L-WAKE
         END-IF
     ELSE
         IF L-COUNTER > 0
             ADD 1 TO L-COUNTER
             IF L-COUNTER >= 110
                 MOVE 0 TO L-COUNTER
             END-IF
         END-IF
     END-IF
     IF L-SLEEPING = 1 AND L-COUNTER >= 100
         MOVE 1 TO L-LONG
     END-IF
     GOBACK.
 END PROGRAM WS-COUNTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WS-START.
*> USING already sleeping or dead, can sleep, can set spawn, within range of either half, not obstructed, creative, a monster prevents rest,
*> Player.startSleepInBed failed, percentage (BINARY-LONG), result out (0 OK, 1 OTHER_PROBLEM, 2 TOO_FAR_AWAY, 3 OBSTRUCTED, 4 NOT_POSSIBLE,
*> 5 NOT_SAFE), set spawn out (1 the respawn point is set before the sleep test), not possible overlay out (1 sleep.not_possible), update list
*> out: ServerPlayer.startSleepInBed in order (5.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BUSY                 BINARY-LONG.
 01 L-CAN-SLEEP            BINARY-LONG.
 01 L-CAN-SPAWN            BINARY-LONG.
 01 L-RANGE                BINARY-LONG.
 01 L-FREE                 BINARY-LONG.
 01 L-CREATIVE             BINARY-LONG.
 01 L-MONSTER              BINARY-LONG.
 01 L-FAILED               BINARY-LONG.
 01 L-PERCENT              BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 01 L-SET-SPAWN            BINARY-LONG.
 01 L-OVERLAY              BINARY-LONG.
 01 L-UPDATE               BINARY-LONG.
 PROCEDURE DIVISION USING L-BUSY L-CAN-SLEEP L-CAN-SPAWN L-RANGE L-FREE L-CREATIVE L-MONSTER L-FAILED L-PERCENT L-RESULT
         L-SET-SPAWN L-OVERLAY L-UPDATE.
     MOVE 0 TO L-RESULT L-SET-SPAWN L-OVERLAY L-UPDATE
     EVALUATE TRUE
         WHEN L-BUSY = 1
             MOVE 1 TO L-RESULT
             GOBACK
         WHEN L-RANGE = 0
             MOVE 2 TO L-RESULT
             GOBACK
         WHEN L-FREE = 0
             MOVE 3 TO L-RESULT
             GOBACK
     END-EVALUATE
     IF L-CAN-SPAWN = 1
         MOVE 1 TO L-SET-SPAWN
     END-IF
     EVALUATE TRUE
         WHEN L-CAN-SLEEP = 0
             MOVE 4 TO L-RESULT
             GOBACK
         WHEN L-CREATIVE = 0 AND L-MONSTER = 1
             MOVE 5 TO L-RESULT
             GOBACK
     END-EVALUATE
     IF L-FAILED = 1
         MOVE 1 TO L-RESULT
     END-IF
     IF L-PERCENT > 100
         MOVE 1 TO L-OVERLAY
     END-IF
     MOVE 1 TO L-UPDATE
     GOBACK.
 END PROGRAM WS-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WS-RANGE.
*> USING the player's x, y, z, the bed's block x, y, z, the other half's block x, y, z (FLOAT-LONG for the player, BINARY-LONG for the blocks),
*> within out: the range test of startSleepInBed step 3 for the clicked bed position or for its other half: |x - (bx + 0.5)| <= 3.0, |y - by| <= 2.0,
*> |z - (bz + 0.5)| <= 3.0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-WITHIN               BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-BX L-BY L-BZ L-OX L-OY L-OZ L-WITHIN.
     MOVE 0 TO L-WITHIN
     COMPUTE WS-DX = FUNCTION ABS(L-X - (L-BX + 0.5))
     COMPUTE WS-DY = FUNCTION ABS(L-Y - L-BY)
     COMPUTE WS-DZ = FUNCTION ABS(L-Z - (L-BZ + 0.5))
     IF WS-DX <= 3.0 AND WS-DY <= 2.0 AND WS-DZ <= 3.0
         MOVE 1 TO L-WITHIN
     END-IF
     COMPUTE WS-DX = FUNCTION ABS(L-X - (L-OX + 0.5))
     COMPUTE WS-DY = FUNCTION ABS(L-Y - L-OY)
     COMPUTE WS-DZ = FUNCTION ABS(L-Z - (L-OZ + 0.5))
     IF WS-DX <= 3.0 AND WS-DY <= 2.0 AND WS-DZ <= 3.0
         MOVE 1 TO L-WITHIN
     END-IF
     GOBACK.
 END PROGRAM WS-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WS-USE-BED.
*> USING the clicked half is the head, the head position holds the same bed, destroy_on_use, occupied, a villager was kicked out, startSleep
*> result is OK (BINARY-LONG), action out (0 consumed with no effect, 1 error message and destroy, 2 villager kicked, 3 occupied text, 4 start
*> sleeping, 5 start result handled): AbstractBedBlock.useWithoutItem (5.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HEAD                 BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-DESTROY              BINARY-LONG.
 01 L-OCCUPIED             BINARY-LONG.
 01 L-KICKED               BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-HEAD L-SAME L-DESTROY L-OCCUPIED L-KICKED L-ACTION.
     MOVE 4 TO L-ACTION
     EVALUATE TRUE
         WHEN L-SAME = 0
             MOVE 0 TO L-ACTION
         WHEN L-DESTROY = 1
             MOVE 1 TO L-ACTION
         WHEN L-OCCUPIED = 1 AND L-KICKED = 1
             MOVE 2 TO L-ACTION
         WHEN L-OCCUPIED = 1
             MOVE 3 TO L-ACTION
     END-EVALUATE
     GOBACK.
 END PROGRAM WS-USE-BED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WS-NIGHT-SKIP.
*> USING advance_time, the dimension type has a default clock, advance_weather, isRaining (BINARY-LONG), move the clock out, wake all out, reset
*> the weather out: the night skip of 5.5 and 2.1 step 3: the clock moves only with advance_time, everyone wakes, the weather resets only with
*> advance_weather and rain.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ADVANCE-TIME         BINARY-LONG.
 01 L-CLOCK                BINARY-LONG.
 01 L-ADVANCE-WEATHER      BINARY-LONG.
 01 L-RAINING              BINARY-LONG.
 01 L-MOVE                 BINARY-LONG.
 01 L-WAKE                 BINARY-LONG.
 01 L-RESET                BINARY-LONG.
 PROCEDURE DIVISION USING L-ADVANCE-TIME L-CLOCK L-ADVANCE-WEATHER L-RAINING L-MOVE L-WAKE L-RESET.
     MOVE 0 TO L-MOVE L-RESET
     MOVE 1 TO L-WAKE
     IF L-ADVANCE-TIME = 1 AND L-CLOCK = 1
         MOVE 1 TO L-MOVE
     END-IF
     IF L-ADVANCE-WEATHER = 1 AND L-RAINING = 1
         MOVE 1 TO L-RESET
     END-IF
     GOBACK.
 END PROGRAM WS-NIGHT-SKIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WP-RESPAWN-DATA.
*> USING yaw, pitch (FLOAT-LONG), wrapped yaw out, clamped pitch out (FLOAT-LONG): RespawnData.of (6.1): yaw wrapped to the range of Mth.wrapDegrees (-180 inclusive to 180 exclusive), pitch clamped to
*> -90 to 90.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TURNS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-YAW                  FLOAT-LONG.
 01 L-PITCH                FLOAT-LONG.
 01 L-WRAPPED              FLOAT-LONG.
 01 L-CLAMPED              FLOAT-LONG.
 PROCEDURE DIVISION USING L-YAW L-PITCH L-WRAPPED L-CLAMPED.
     COMPUTE WS-TURNS = FUNCTION INTEGER((L-YAW + 180) / 360)
     COMPUTE L-WRAPPED = L-YAW - WS-TURNS * 360
     MOVE L-PITCH TO L-CLAMPED
     IF L-PITCH < -90
         MOVE -90 TO L-CLAMPED
     END-IF
     IF L-PITCH > 90
         MOVE 90 TO L-CLAMPED
     END-IF
     GOBACK.
 END PROGRAM WP-RESPAWN-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WP-SPIRAL.
*> USING index (1 to 121), x out, z out (BINARY-LONG): the cell of the square spiral of 6.2 step 4: start (0, 0) with the direction (0, -1); the
*> direction (dx, dz) becomes (-dz, dx) after the cell whose x = z, or x < 0 and x = -z, or x > 0 and x = 1 - z.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-X L-Z.
     MOVE 0 TO L-X L-Z
     MOVE 0 TO WS-DX
     MOVE -1 TO WS-DZ
     PERFORM VARYING WS-N FROM 2 BY 1 UNTIL WS-N > L-INDEX
         IF L-X = L-Z OR (L-X < 0 AND L-X = 0 - L-Z) OR (L-X > 0 AND L-X = 1 - L-Z)
             MOVE WS-DX TO WS-T
             COMPUTE WS-DX = 0 - WS-DZ
             MOVE WS-T TO WS-DZ
         END-IF
         ADD WS-DX TO L-X
         ADD WS-DZ TO L-Z
     END-PERFORM
     GOBACK.
 END PROGRAM WP-SPIRAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WP-COLUMN.
*> USING index (1 to 256), chunk minimum x, chunk minimum z (BINARY-LONG), x out, z out: getSpawnPosInChunk's column order (6.2): x outer and z
*> inner, both ascending from the chunk's minimum.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-MIN-X                BINARY-LONG.
 01 L-MIN-Z                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-MIN-X L-MIN-Z L-X L-Z.
     COMPUTE L-X = L-MIN-X + FUNCTION INTEGER((L-INDEX - 1) / 16)
     COMPUTE L-Z = L-MIN-Z + FUNCTION MOD(L-INDEX - 1, 16)
     GOBACK.
 END PROGRAM WP-COLUMN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WP-PROVISIONAL.
*> USING origin chunk x, origin chunk z, spawn height (BINARY-LONG), x out, y out, z out: the provisional spawn of 6.2 step 3: the origin chunk's
*> minimum corner plus (8, y, 8).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-HEIGHT L-X L-Y L-Z.
     COMPUTE L-X = L-CX * 16 + 8
     MOVE L-HEIGHT TO L-Y
     COMPUTE L-Z = L-CZ * 16 + 8
     GOBACK.
 END PROGRAM WP-PROVISIONAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WP-LEVEL-RESPAWN.
*> USING the dimension has a ceiling, generator spawn height, motion-blocking height, minimum y, world surface height, ocean floor height
*> (BINARY-LONG), topY out, rejected out: getLevelRespawnPos steps 1 and 2 (6.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CEILING              BINARY-LONG.
 01 L-SPAWN-HEIGHT         BINARY-LONG.
 01 L-MOTION               BINARY-LONG.
 01 L-MIN-Y                BINARY-LONG.
 01 L-SURFACE              BINARY-LONG.
 01 L-FLOOR                BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-REJECTED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CEILING L-SPAWN-HEIGHT L-MOTION L-MIN-Y L-SURFACE L-FLOOR L-TOP L-REJECTED.
     MOVE 0 TO L-REJECTED
     IF L-CEILING = 1
         MOVE L-SPAWN-HEIGHT TO L-TOP
     ELSE
         MOVE L-MOTION TO L-TOP
     END-IF
     IF L-TOP < L-MIN-Y
         MOVE 1 TO L-REJECTED
     END-IF
     IF L-SURFACE <= L-TOP AND L-SURFACE > L-FLOOR
         MOVE 1 TO L-REJECTED
     END-IF
     GOBACK.
 END PROGRAM WP-LEVEL-RESPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WP-LEVEL-COLUMN.
*> USING the fluid at the cell is not empty, the up face of its collision shape is a full face (BINARY-LONG), action out (0 go on down, 1 reject
*> the column, 2 return y + 1): one cell of the downward loop of getLevelRespawnPos step 3 (6.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLUID                BINARY-LONG.
 01 L-FULL                 BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-FLUID L-FULL L-ACTION.
     MOVE 0 TO L-ACTION
     IF L-FLUID = 1
         MOVE 1 TO L-ACTION
     END-IF
     IF L-FLUID = 0 AND L-FULL = 1
         MOVE 2 TO L-ACTION
     END-IF
     GOBACK.
 END PROGRAM WP-LEVEL-COLUMN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WP-QUANT.
*> USING a density value (FLOAT-LONG), quantised out (BINARY-DOUBLE), and a value and an interval (quantised minimum, maximum) (BINARY-DOUBLE),
*> distance out: q(v) = (long)(v * 10000.0f) truncated toward zero and distance(v) = v - max above 0, else max(min - v, 0) (6.3 step 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-SCALED              FLOAT-LONG.
 01 WS-F32                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-VALUE                FLOAT-LONG.
 01 L-Q                    BINARY-DOUBLE.
 01 L-MIN                  BINARY-DOUBLE.
 01 L-MAX                  BINARY-DOUBLE.
 01 L-DISTANCE             BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-VALUE L-Q L-MIN L-MAX L-DISTANCE.
     COMPUTE WS-SCALED = L-VALUE * 10000.0
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-SCALED WS-F32
     COMPUTE L-Q = FUNCTION INTEGER-PART(WS-F32)
     IF L-Q - L-MAX > 0
         COMPUTE L-DISTANCE = L-Q - L-MAX
     ELSE
         COMPUTE L-DISTANCE = L-MIN - L-Q
         IF L-DISTANCE < 0
             MOVE 0 TO L-DISTANCE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WP-QUANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WP-FITNESS.
*> USING the smallest sum of squared distances m (BINARY-DOUBLE), the unaligned x and z (BINARY-LONG), fitness out (BINARY-DOUBLE), aligned x and
*> z out (BINARY-LONG): fitness = m * 2048^2 + x^2 + z^2, and the biome-grid alignment (x >> 2) << 2 used for the density sampling only (6.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-M                    BINARY-DOUBLE.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FITNESS              BINARY-DOUBLE.
 01 L-QX                   BINARY-LONG.
 01 L-QZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-M L-X L-Z L-FITNESS L-QX L-QZ.
     COMPUTE L-FITNESS = L-M * 4194304 + L-X * L-X + L-Z * L-Z
     COMPUTE L-QX = FUNCTION INTEGER(L-X / 4) * 4
     COMPUTE L-QZ = FUNCTION INTEGER(L-Z / 4) * 4
     GOBACK.
 END PROGRAM WP-FITNESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WP-PROBE.
*> USING the pass centre x, z, the angle and the radius (FLOAT-LONG; centre BINARY-LONG), the step (BINARY-LONG), x out, z out (BINARY-LONG), the
*> next angle and radius out (FLOAT-LONG): one probe of the search pass of 6.3 step 3: (c.x + (int)(sin(angle) * radius), c.z + (int)(cos(angle) *
*> radius)); then angle += step / radius and, above 2 pi, angle = 0 and radius += step.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TWO-PI              FLOAT-LONG VALUE 6.283185307179586.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-ANGLE                FLOAT-LONG.
 01 L-RADIUS               FLOAT-LONG.
 01 L-STEP                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-NEXT-ANGLE           FLOAT-LONG.
 01 L-NEXT-RADIUS          FLOAT-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-ANGLE L-RADIUS L-STEP L-X L-Z L-NEXT-ANGLE L-NEXT-RADIUS.
     COMPUTE WS-DX = FUNCTION SIN(L-ANGLE) * L-RADIUS
     COMPUTE WS-DZ = FUNCTION COS(L-ANGLE) * L-RADIUS
     COMPUTE L-X = L-CX + FUNCTION INTEGER-PART(WS-DX)
     COMPUTE L-Z = L-CZ + FUNCTION INTEGER-PART(WS-DZ)
     COMPUTE L-NEXT-ANGLE = L-ANGLE + L-STEP / L-RADIUS
     MOVE L-RADIUS TO L-NEXT-RADIUS
     IF L-NEXT-ANGLE > WS-TWO-PI
         MOVE 0 TO L-NEXT-ANGLE
         COMPUTE L-NEXT-RADIUS = L-RADIUS + L-STEP
     END-IF
     GOBACK.
 END PROGRAM WP-PROBE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WP-CANDIDATE.
*> USING respawn_radius, border distance floor, the offset draw, candidate index i, the suggestion x, z (BINARY-LONG), x out, z out, candidate count
*> out, radius used out: PlayerSpawnFinder.findSpawn steps 2 to 4 (6.4): radius = max(0, rule), lowered to the border distance and to 1 when that
*>   is 1 or less; n = 2 radius + 1; count = min(1024, n^2); stride count - 1 up to
*> 16 candidates, else 17; k = (offset + stride * i) mod count; x = sx + k mod n - radius, z = sz + k div n - radius.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RADIUS              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-COPRIME             BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-RULE                 BINARY-LONG.
 01 L-BORDER               BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 01 L-I                    BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-RULE L-BORDER L-OFFSET L-I L-SX L-SZ L-X L-Z L-COUNT L-RADIUS.
     COMPUTE WS-RADIUS = FUNCTION MAX(0, L-RULE)
     IF L-BORDER < WS-RADIUS
         MOVE L-BORDER TO WS-RADIUS
     END-IF
     IF L-BORDER <= 1
         MOVE 1 TO WS-RADIUS
     END-IF
     MOVE WS-RADIUS TO L-RADIUS
     COMPUTE WS-N = 2 * WS-RADIUS + 1
     COMPUTE L-COUNT = WS-N * WS-N
     IF L-COUNT > 1024
         MOVE 1024 TO L-COUNT
     END-IF
     IF L-COUNT <= 16
         COMPUTE WS-COPRIME = L-COUNT - 1
     ELSE
         MOVE 17 TO WS-COPRIME
     END-IF
     COMPUTE WS-K = FUNCTION MOD(L-OFFSET + WS-COPRIME * L-I, L-COUNT)
     COMPUTE L-X = L-SX + FUNCTION MOD(WS-K, WS-N) - WS-RADIUS
     COMPUTE L-Z = L-SZ + FUNCTION INTEGER(WS-K / WS-N) - WS-RADIUS
     GOBACK.
 END PROGRAM WP-CANDIDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WP-FIXUP.
*> USING the start y, the minimum and maximum y, a blocked flag per y in a text of "0"/"1" one character per block from the minimum
*> (PIC X(64), 1 = the player box is blocked or in liquid there), result y out: fixupSpawnHeight (6.4): up one block at a time while blocked
*> and y < maxY; down one, then down while free and y > minY; up one.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Y                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-START                BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-BLOCKED              PIC X(64).
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-START L-MIN L-MAX L-BLOCKED L-RESULT.
     MOVE L-START TO WS-Y
     PERFORM UNTIL L-BLOCKED(WS-Y - L-MIN + 1:1) = "0" OR WS-Y >= L-MAX
         ADD 1 TO WS-Y
     END-PERFORM
     SUBTRACT 1 FROM WS-Y
     PERFORM UNTIL WS-Y <= L-MIN OR L-BLOCKED(WS-Y - L-MIN + 1:1) = "1"
         SUBTRACT 1 FROM WS-Y
     END-PERFORM
     ADD 1 TO WS-Y
     MOVE WS-Y TO L-RESULT
     GOBACK.
 END PROGRAM WP-FIXUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WP-EFFECTIVE.
*> USING the stored spawn x, z, the border minimum x, maximum x, minimum z, maximum z (FLOAT-LONG; the border as 7.4 defines it), inside out: the
*> stored position is inside the border when both coordinates are within bounds (minimum inclusive, maximum exclusive); otherwise the effective
*> data replaces it by the height-map position above the border centre (6.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-MIN-X                FLOAT-LONG.
 01 L-MAX-X                FLOAT-LONG.
 01 L-MIN-Z                FLOAT-LONG.
 01 L-MAX-Z                FLOAT-LONG.
 01 L-INSIDE               BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-MIN-X L-MAX-X L-MIN-Z L-MAX-Z L-INSIDE.
     MOVE 0 TO L-INSIDE
     IF L-X >= L-MIN-X AND L-X < L-MAX-X AND L-Z >= L-MIN-Z AND L-Z < L-MAX-Z
         MOVE 1 TO L-INSIDE
     END-IF
     GOBACK.
 END PROGRAM WP-EFFECTIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WP-PROTECTED.
*> USING the level is the world spawn's dimension, the operator list is not empty, the player is an operator, spawn-protection, x - spawn x, z -
*> spawn z (BINARY-LONG), protected out: DedicatedServer.isUnderSpawnProtection (6.5), a square of max(|dx|, |dz|) <= the property.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SAME                 BINARY-LONG.
 01 L-OPS                  BINARY-LONG.
 01 L-IS-OP                BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-PROTECTED            BINARY-LONG.
 PROCEDURE DIVISION USING L-SAME L-OPS L-IS-OP L-RADIUS L-DX L-DZ L-PROTECTED.
     MOVE 0 TO L-PROTECTED
     IF L-SAME = 1 AND L-OPS = 1 AND L-IS-OP = 0 AND L-RADIUS > 0
             AND FUNCTION MAX(FUNCTION ABS(L-DX), FUNCTION ABS(L-DZ)) <= L-RADIUS
         MOVE 1 TO L-PROTECTED
     END-IF
     GOBACK.
 END PROGRAM WP-PROTECTED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WB-EXTENT.
*> USING the centre x, the size, the absolute maximum size (FLOAT-LONG), minimum x out, maximum x out (FLOAT-LONG): a static extent (7.2):
*> clamp(c - S / 2, -A, A) and clamp(c + S / 2, -A, A).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CENTRE               FLOAT-LONG.
 01 L-SIZE                 FLOAT-LONG.
 01 L-ABSOLUTE             FLOAT-LONG.
 01 L-MIN                  FLOAT-LONG.
 01 L-MAX                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-CENTRE L-SIZE L-ABSOLUTE L-MIN L-MAX.
     COMPUTE L-MIN = L-CENTRE - L-SIZE / 2
     COMPUTE L-MAX = L-CENTRE + L-SIZE / 2
     IF L-MIN < 0 - L-ABSOLUTE
         COMPUTE L-MIN = 0 - L-ABSOLUTE
     END-IF
     IF L-MIN > L-ABSOLUTE
         MOVE L-ABSOLUTE TO L-MIN
     END-IF
     IF L-MAX < 0 - L-ABSOLUTE
         COMPUTE L-MAX = 0 - L-ABSOLUTE
     END-IF
     IF L-MAX > L-ABSOLUTE
         MOVE L-ABSOLUTE TO L-MAX
     END-IF
     GOBACK.
 END PROGRAM WB-EXTENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WB-MOVING.
*> USING from, to (FLOAT-LONG), the duration, the remaining progress in and out (BINARY-LONG), size out, status out (0 stationary, 1 shrinking, 2
*> growing), speed out (FLOAT-LONG), static out: one tick of a moving extent (7.2, 7.3): the progress decrements, the size is lerp((D - progress) /
*> D, from, to) and the extent turns static when the progress is 0 or below.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FRACTION            FLOAT-LONG.
 LINKAGE SECTION.
 01 L-FROM                 FLOAT-LONG.
 01 L-TO                   FLOAT-LONG.
 01 L-DURATION             BINARY-LONG.
 01 L-PROGRESS             BINARY-LONG.
 01 L-SIZE                 FLOAT-LONG.
 01 L-STATUS               BINARY-LONG.
 01 L-SPEED                FLOAT-LONG.
 01 L-STATIC               BINARY-LONG.
 PROCEDURE DIVISION USING L-FROM L-TO L-DURATION L-PROGRESS L-SIZE L-STATUS L-SPEED L-STATIC.
     SUBTRACT 1 FROM L-PROGRESS
     COMPUTE WS-FRACTION = (L-DURATION - L-PROGRESS) / L-DURATION
     COMPUTE L-SIZE = L-FROM + WS-FRACTION * (L-TO - L-FROM)
     MOVE 0 TO L-STATIC
     IF L-PROGRESS <= 0
         MOVE L-TO TO L-SIZE
         MOVE 1 TO L-STATIC
     END-IF
     IF L-TO < L-FROM
         MOVE 1 TO L-STATUS
     ELSE
         MOVE 2 TO L-STATUS
     END-IF
     COMPUTE L-SPEED = FUNCTION ABS(L-FROM - L-TO) / L-DURATION
     GOBACK.
 END PROGRAM WB-MOVING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WB-GEOMETRY.
*> USING x, z (FLOAT-LONG), the margin, the bounds minX, maxX, minZ, maxZ (FLOAT-LONG), within out, distance to the border out, the clamped x and z
*> out: isWithinBounds (the minimum edge inclusive, the maximum exclusive), getDistanceToBorder and clampVec3ToBound (7.4; the clamp keeps 1.0E-5f
*> of the float 9.999999747378752E-6 inside the maximum edge).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EPS                 FLOAT-LONG VALUE 0.000009999999747378752.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-MARGIN               FLOAT-LONG.
 01 L-MIN-X                FLOAT-LONG.
 01 L-MAX-X                FLOAT-LONG.
 01 L-MIN-Z                FLOAT-LONG.
 01 L-MAX-Z                FLOAT-LONG.
 01 L-WITHIN               BINARY-LONG.
 01 L-DISTANCE             FLOAT-LONG.
 01 L-CLAMP-X              FLOAT-LONG.
 01 L-CLAMP-Z              FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-MARGIN L-MIN-X L-MAX-X L-MIN-Z L-MAX-Z L-WITHIN L-DISTANCE L-CLAMP-X L-CLAMP-Z.
     MOVE 0 TO L-WITHIN
     IF L-X >= L-MIN-X - L-MARGIN AND L-X < L-MAX-X + L-MARGIN AND L-Z >= L-MIN-Z - L-MARGIN AND L-Z < L-MAX-Z + L-MARGIN
         MOVE 1 TO L-WITHIN
     END-IF
     COMPUTE L-DISTANCE = FUNCTION MIN(L-Z - L-MIN-Z, L-MAX-Z - L-Z, L-X - L-MIN-X, L-MAX-X - L-X)
     MOVE L-X TO L-CLAMP-X
     MOVE L-Z TO L-CLAMP-Z
     IF L-CLAMP-X < L-MIN-X
         MOVE L-MIN-X TO L-CLAMP-X
     END-IF
     IF L-CLAMP-X > L-MAX-X - WS-EPS
         COMPUTE L-CLAMP-X = L-MAX-X - WS-EPS
     END-IF
     IF L-CLAMP-Z < L-MIN-Z
         MOVE L-MIN-Z TO L-CLAMP-Z
     END-IF
     IF L-CLAMP-Z > L-MAX-Z - WS-EPS
         COMPUTE L-CLAMP-Z = L-MAX-Z - WS-EPS
     END-IF
     GOBACK.
 END PROGRAM WB-GEOMETRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WB-DAMAGE.
*> USING the entity is a player, is in a wall, its box is within bounds (BINARY-LONG), distance to the border, safe zone, damage per block
*> (FLOAT-LONG), in-wall damage out, border damage out (FLOAT-LONG): LivingEntity.baseTick (7.5): in a wall 1.0 and the border test is skipped;
*> otherwise a player outside takes max(1, floor(-d * damage)) when d = distance + safe zone is below 0 and damage per block is above 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-D                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-N                   FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-HURT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-WALL                 BINARY-LONG.
 01 L-WITHIN               BINARY-LONG.
 01 L-DISTANCE             FLOAT-LONG.
 01 L-SAFE                 FLOAT-LONG.
 01 L-PER-BLOCK            FLOAT-LONG.
 01 L-WALL-DAMAGE          FLOAT-LONG.
 01 L-BORDER-DAMAGE        FLOAT-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-WALL L-WITHIN L-DISTANCE L-SAFE L-PER-BLOCK L-WALL-DAMAGE L-BORDER-DAMAGE.
     MOVE 0 TO L-WALL-DAMAGE L-BORDER-DAMAGE
     IF L-WALL = 1
         MOVE 1.0 TO L-WALL-DAMAGE
         GOBACK
     END-IF
     IF L-PLAYER = 1 AND L-WITHIN = 0
         CALL STATIC "cc_f64_add" USING BY REFERENCE L-DISTANCE L-SAFE WS-D
         IF WS-D < 0 AND L-PER-BLOCK > 0
             CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-D L-PER-BLOCK WS-T
             CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-ZERO WS-T WS-N
             CALL STATIC "cc_f64_floor" USING BY REFERENCE WS-N WS-F
             CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-F WS-HURT
             IF WS-HURT < 1
                 MOVE 1 TO WS-HURT
             END-IF
             MOVE WS-HURT TO L-BORDER-DAMAGE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WB-DAMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WB-CLOSE.
*> USING the entity's distance to the border, x, z, the larger box side (FLOAT-LONG), the bounds (FLOAT-LONG x4), close out: isInsideCloseToBorder
*> (7.4): with m = max(1, side) the distance is below 2m and (x, z) is within the bounds with margin m.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DISTANCE             FLOAT-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-SIDE                 FLOAT-LONG.
 01 L-MIN-X                FLOAT-LONG.
 01 L-MAX-X                FLOAT-LONG.
 01 L-MIN-Z                FLOAT-LONG.
 01 L-MAX-Z                FLOAT-LONG.
 01 L-CLOSE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DISTANCE L-X L-Z L-SIDE L-MIN-X L-MAX-X L-MIN-Z L-MAX-Z L-CLOSE.
     COMPUTE WS-M = FUNCTION MAX(1, L-SIDE)
     MOVE 0 TO L-CLOSE
     IF L-DISTANCE < 2 * WS-M AND L-X >= L-MIN-X - WS-M AND L-X < L-MAX-X + WS-M AND L-Z >= L-MIN-Z - WS-M AND L-Z < L-MAX-Z + WS-M
         MOVE 1 TO L-CLOSE
     END-IF
     GOBACK.
 END PROGRAM WB-CLOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GR-CHANGE.
*> USING rule (1 reduced_debug_info, 2 limited_crafting, 3 immediate_respawn, 4 locator_bar, 5 spawn_monsters, 6 advance_time, 0 any other),
*> value (BINARY-LONG), action out, value sent out: MinecraftServer.onGameRuleChanged (8.1): 1 Entity Event 22 or 23 to every player about itself,
*> 2 Game Event 12 with 1.0 or 0.0, 3 Game Event 11 with 1.0 or 0.0, 4 re-evaluate waypoint connections, 5 updateMobSpawningFlags, 6 a full Set Time
*> to everybody; the notification manager is informed of every change (action 0 still reports).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RULE                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-SENT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-RULE L-VALUE L-ACTION L-SENT.
     MOVE L-RULE TO L-ACTION
     MOVE L-VALUE TO L-SENT
     IF L-RULE = 1
         COMPUTE L-SENT = 23 - L-VALUE
     END-IF
     GOBACK.
 END PROGRAM GR-CHANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GR-SPAWNING.
*> USING spawn_mobs, spawn_monsters (BINARY-LONG), live out, which rule or difficulty change just happened (0 none, 1 spawn_mobs, 2
*> spawn_monsters, 3 difficulty), the stored flag in and out: ServerLevel.isSpawningMonsters is spawn_mobs and spawn_monsters; the stored
*> chunk-source flag is refreshed only by a spawn_monsters or difficulty change, so a spawn_mobs change alone leaves it stale (8.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MOBS                 BINARY-LONG.
 01 L-MONSTERS             BINARY-LONG.
 01 L-LIVE                 BINARY-LONG.
 01 L-CHANGE               BINARY-LONG.
 01 L-STORED               BINARY-LONG.
 PROCEDURE DIVISION USING L-MOBS L-MONSTERS L-LIVE L-CHANGE L-STORED.
     MOVE 0 TO L-LIVE
     IF L-MOBS = 1 AND L-MONSTERS = 1
         MOVE 1 TO L-LIVE
     END-IF
     IF L-CHANGE = 2 OR L-CHANGE = 3
         MOVE L-LIVE TO L-STORED
     END-IF
     GOBACK.
 END PROGRAM GR-SPAWNING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GR-INVULNERABLE.
*> USING the player is damaged by drowning, fall, fire, freezing (four BINARY-LONG flags), drowning_damage, fall_damage, fire_damage,
*> freeze_damage (four rule values), is a player (BINARY-LONG), invulnerable out: Player.isInvulnerableTo (8.2): while the matching rule is false a
*> player is invulnerable to that damage tag (mobs are unaffected).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IS-DROWN             BINARY-LONG.
 01 L-IS-FALL              BINARY-LONG.
 01 L-IS-FIRE              BINARY-LONG.
 01 L-IS-FREEZE            BINARY-LONG.
 01 L-DROWN                BINARY-LONG.
 01 L-FALL                 BINARY-LONG.
 01 L-FIRE                 BINARY-LONG.
 01 L-FREEZE               BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-INVULNERABLE         BINARY-LONG.
 PROCEDURE DIVISION USING L-IS-DROWN L-IS-FALL L-IS-FIRE L-IS-FREEZE L-DROWN L-FALL L-FIRE L-FREEZE L-PLAYER L-INVULNERABLE.
     MOVE 0 TO L-INVULNERABLE
     IF L-PLAYER = 1
         IF (L-IS-DROWN = 1 AND L-DROWN = 0) OR (L-IS-FALL = 1 AND L-FALL = 0) OR (L-IS-FIRE = 1 AND L-FIRE = 0)
                 OR (L-IS-FREEZE = 1 AND L-FREEZE = 0)
             MOVE 1 TO L-INVULNERABLE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM GR-INVULNERABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GR-EXPLOSION.
*> USING interaction (0 NONE, 1 BLOCK, 2 MOB, 3 TNT, 4 TRIGGER), block_explosion_drop_decay, mob_griefing, mob_explosion_drop_decay,
*> tnt_explosion_drop_decay (BINARY-LONG), block interaction out (0 KEEP, 1 DESTROY, 2 DESTROY_WITH_DECAY, 3 TRIGGER_BLOCK): 8.3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INTERACTION          BINARY-LONG.
 01 L-BLOCK-DECAY          BINARY-LONG.
 01 L-GRIEF                BINARY-LONG.
 01 L-MOB-DECAY            BINARY-LONG.
 01 L-TNT-DECAY            BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-INTERACTION L-BLOCK-DECAY L-GRIEF L-MOB-DECAY L-TNT-DECAY L-RESULT.
     MOVE 0 TO L-RESULT
     EVALUATE L-INTERACTION
         WHEN 1
             COMPUTE L-RESULT = 1 + L-BLOCK-DECAY
         WHEN 2
             IF L-GRIEF = 1
                 COMPUTE L-RESULT = 1 + L-MOB-DECAY
             END-IF
         WHEN 3
             COMPUTE L-RESULT = 1 + L-TNT-DECAY
         WHEN 4
             MOVE 3 TO L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM GR-EXPLOSION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GR-CRAMMING.
*> USING max_entity_cramming L, pushable entities touching, those that are not passengers, nextInt(4) draw (BINARY-LONG), damage out (FLOAT-LONG):
*> LivingEntity.pushEntities (8.2): with L above 0 and more than L - 1 touching and a draw of 0, more than L - 1 non-passengers give 6.0 damage.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIMIT                BINARY-LONG.
 01 L-TOUCHING             BINARY-LONG.
 01 L-FREE                 BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-DAMAGE               FLOAT-LONG.
 PROCEDURE DIVISION USING L-LIMIT L-TOUCHING L-FREE L-DRAW L-DAMAGE.
     MOVE 0 TO L-DAMAGE
     IF L-LIMIT > 0 AND L-TOUCHING > L-LIMIT - 1 AND L-DRAW = 0 AND L-FREE > L-LIMIT - 1
         MOVE 6.0 TO L-DAMAGE
     END-IF
     GOBACK.
 END PROGRAM GR-CRAMMING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GR-MINECART.
*> USING max_minecart_speed, in water (BINARY-LONG), speed out (FLOAT-LONG): NewMinecartBehavior.getMaxSpeed (8.2): rule * (0.5 in water, else 1.0) / 20.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RULE                 BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-SPEED                FLOAT-LONG.
 PROCEDURE DIVISION USING L-RULE L-WATER L-SPEED.
     COMPUTE L-SPEED = L-RULE / 20.0
     IF L-WATER = 1
         COMPUTE L-SPEED = L-SPEED * 0.5
     END-IF
     GOBACK.
 END PROGRAM GR-MINECART.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GR-PORTAL.
*> USING the player has the invulnerable ability, players_nether_portal_creative_delay, players_nether_portal_default_delay, the destination is the
*> Nether, allow_entering_nether_using_portals, is a player (BINARY-LONG), delay out, allowed out: NetherPortalBlock.getPortalTransitionTime and
*> isAllowedToEnterPortal (8.2): other entities 0; a creative player the creative rule, other players the default rule (floor 0).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CREATIVE             BINARY-LONG.
 01 L-CREATIVE-RULE        BINARY-LONG.
 01 L-DEFAULT-RULE         BINARY-LONG.
 01 L-NETHER               BINARY-LONG.
 01 L-ALLOW                BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-ALLOWED              BINARY-LONG.
 PROCEDURE DIVISION USING L-CREATIVE L-CREATIVE-RULE L-DEFAULT-RULE L-NETHER L-ALLOW L-PLAYER L-DELAY L-ALLOWED.
     MOVE 0 TO L-DELAY
     IF L-PLAYER = 1
         IF L-CREATIVE = 1
             COMPUTE L-DELAY = FUNCTION MAX(0, L-CREATIVE-RULE)
         ELSE
             COMPUTE L-DELAY = FUNCTION MAX(0, L-DEFAULT-RULE)
         END-IF
     END-IF
     MOVE 1 TO L-ALLOWED
     IF L-NETHER = 1 AND L-ALLOW = 0
         MOVE 0 TO L-ALLOWED
     END-IF
     GOBACK.
 END PROGRAM GR-PORTAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GR-MOVEMENT-CHECK.
*> USING a single-player owner or a player changing dimension, player_movement_check, gliding, elytra_movement_check (BINARY-LONG), check out:
*> shouldCheckPlayerMovement (8.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EXEMPT               BINARY-LONG.
 01 L-PLAYER-RULE          BINARY-LONG.
 01 L-GLIDING              BINARY-LONG.
 01 L-ELYTRA-RULE          BINARY-LONG.
 01 L-CHECK                BINARY-LONG.
 PROCEDURE DIVISION USING L-EXEMPT L-PLAYER-RULE L-GLIDING L-ELYTRA-RULE L-CHECK.
     MOVE 1 TO L-CHECK
     IF L-EXEMPT = 1 OR L-PLAYER-RULE = 0 OR (L-GLIDING = 1 AND L-ELYTRA-RULE = 0)
         MOVE 0 TO L-CHECK
     END-IF
     GOBACK.
 END PROGRAM GR-MOVEMENT-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GR-FIRE-NEAR.
*> USING fire_spread_radius_around_player r, the distance from a non-spectator player of the level (FLOAT-LONG; r BINARY-LONG), near out:
*> canSpreadFireAround (8.2): true for -1, else a player strictly closer than r.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RADIUS               BINARY-LONG.
 01 L-DISTANCE             FLOAT-LONG.
 01 L-NEAR                 BINARY-LONG.
 PROCEDURE DIVISION USING L-RADIUS L-DISTANCE L-NEAR.
     MOVE 0 TO L-NEAR
     IF L-RADIUS = -1 OR L-DISTANCE < L-RADIUS
         MOVE 1 TO L-NEAR
     END-IF
     GOBACK.
 END PROGRAM GR-FIRE-NEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GR-LIMITED-CRAFTING.
*> USING limited_crafting, the recipe is special, the recipe is in the player's recipe book (BINARY-LONG), allowed out:
*> RecipeCraftingHolder.setRecipeUsed (8.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RULE                 BINARY-LONG.
 01 L-SPECIAL              BINARY-LONG.
 01 L-KNOWN                BINARY-LONG.
 01 L-ALLOWED              BINARY-LONG.
 PROCEDURE DIVISION USING L-RULE L-SPECIAL L-KNOWN L-ALLOWED.
     MOVE 1 TO L-ALLOWED
     IF L-RULE = 1 AND L-SPECIAL = 0 AND L-KNOWN = 0
         MOVE 0 TO L-ALLOWED
     END-IF
     GOBACK.
 END PROGRAM GR-LIMITED-CRAFTING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GR-GLOBAL-SOUND.
*> USING global_sound_events, same level, squared distance from the player to the event block centre (BINARY-LONG; the distance BINARY-DOUBLE),
*> mode out (0 an ordinary level event, 1 the event position, 2 a point 32 blocks from the player towards the event, 3 the player's own
*> position; modes 1 to 3 carry the global flag): ServerLevel.globalLevelEvent for one player (8.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RULE                 BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-DISTANCE-SQUARED     BINARY-DOUBLE.
 01 L-MODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-RULE L-SAME L-DISTANCE-SQUARED L-MODE.
     MOVE 0 TO L-MODE
     IF L-RULE = 1
         EVALUATE TRUE
             WHEN L-SAME = 0
                 MOVE 3 TO L-MODE
             WHEN L-DISTANCE-SQUARED < 1024
                 MOVE 1 TO L-MODE
             WHEN OTHER
                 MOVE 2 TO L-MODE
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM GR-GLOBAL-SOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GR-DROPS.
*> USING which (1 block_drops on popResource, 2 mob_drops on LivingEntity.shouldDropLoot, 3 entity_drops on a dropped item), the rule value, the stack
*> is empty, the entity is a baby (BINARY-LONG), drops out: the drop gates of 8.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WHICH                BINARY-LONG.
 01 L-RULE                 BINARY-LONG.
 01 L-EMPTY                BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-DROPS                BINARY-LONG.
 PROCEDURE DIVISION USING L-WHICH L-RULE L-EMPTY L-BABY L-DROPS.
     MOVE L-RULE TO L-DROPS
     IF L-WHICH = 1 AND L-EMPTY = 1
         MOVE 0 TO L-DROPS
     END-IF
     IF L-WHICH = 2 AND L-BABY = 1
         MOVE 0 TO L-DROPS
     END-IF
     GOBACK.
 END PROGRAM GR-DROPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DF-SET.
*> USING the new difficulty id, force, locked, hardcore (BINARY-LONG), difficulty stored out, applied out: MinecraftServer.setDifficulty (9.1):
*> ignored unless forced or not locked; a hardcore world always stores HARD (3); applying also refreshes the spawning flags and sends Change Difficulty.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIFFICULTY           BINARY-LONG.
 01 L-FORCE                BINARY-LONG.
 01 L-LOCKED               BINARY-LONG.
 01 L-HARDCORE             BINARY-LONG.
 01 L-STORED               BINARY-LONG.
 01 L-APPLIED              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIFFICULTY L-FORCE L-LOCKED L-HARDCORE L-STORED L-APPLIED.
     MOVE 0 TO L-APPLIED
     IF L-FORCE = 1 OR L-LOCKED = 0
         MOVE 1 TO L-APPLIED
         MOVE L-DIFFICULTY TO L-STORED
         IF L-HARDCORE = 1
             MOVE 3 TO L-STORED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM DF-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DF-SCALE.
*> USING difficulty id, damage (FLOAT-LONG), scaled damage out: damage scaling of Player.hurtServer (9.2): Peaceful 0, Easy min(d / 2 + 1, d), Normal
*> d, Hard d * 3 / 2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EASY                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIFFICULTY           BINARY-LONG.
 01 L-DAMAGE               FLOAT-LONG.
 01 L-SCALED               FLOAT-LONG.
 PROCEDURE DIVISION USING L-DIFFICULTY L-DAMAGE L-SCALED.
     EVALUATE L-DIFFICULTY
         WHEN 0
             MOVE 0 TO L-SCALED
         WHEN 1
             COMPUTE WS-EASY = L-DAMAGE / 2 + 1
             COMPUTE L-SCALED = FUNCTION MIN(WS-EASY, L-DAMAGE)
         WHEN 2
             MOVE L-DAMAGE TO L-SCALED
         WHEN OTHER
             COMPUTE L-SCALED = L-DAMAGE * 3 / 2
     END-EVALUATE
     GOBACK.
 END PROGRAM DF-SCALE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DF-SITES.
*> USING difficulty id, nextInt(2000) draw, the level spawns monsters, nether_portal_spawns_piglin, a player is close enough (BINARY-LONG), piglin
*> spawn out, lightning fires out, fire odds term out, peaceful gate out (1 the behaviour is enabled): the difficulty sites of 9.3: a portal piglin needs the
*> flag, a non-Peaceful difficulty, the attribute, draw < difficulty id and a close player; a main lightning strike starts 4 fires on Normal or Hard; the fire
*> ignition odds include difficulty id * 7.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIFFICULTY           BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-MONSTERS             BINARY-LONG.
 01 L-ATTRIBUTE            BINARY-LONG.
 01 L-CLOSE                BINARY-LONG.
 01 L-PIGLIN               BINARY-LONG.
 01 L-FIRES                BINARY-LONG.
 01 L-ODDS                 BINARY-LONG.
 01 L-ENABLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIFFICULTY L-DRAW L-MONSTERS L-ATTRIBUTE L-CLOSE L-PIGLIN L-FIRES L-ODDS L-ENABLED.
     MOVE 0 TO L-PIGLIN L-FIRES L-ENABLED
     IF L-MONSTERS = 1 AND L-DIFFICULTY NOT = 0 AND L-ATTRIBUTE = 1 AND L-DRAW < L-DIFFICULTY AND L-CLOSE = 1
         MOVE 1 TO L-PIGLIN
     END-IF
     IF L-DIFFICULTY >= 2
         MOVE 4 TO L-FIRES
     END-IF
     COMPUTE L-ODDS = L-DIFFICULTY * 7
     IF L-DIFFICULTY NOT = 0
         MOVE 1 TO L-ENABLED
     END-IF
     GOBACK.
 END PROGRAM DF-SITES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DF-INSTANCE.
*> USING the chunk is loaded to FULL status, its inhabited time, the moon brightness (BINARY-LONG; moon FLOAT-LONG), the game time and the overworld
*> clock total (BINARY-DOUBLE), inhabited out, moon out, time input out: getCurrentDifficultyAt (9.3): an unloaded chunk uses 0 and 0; the time
*> input T is the overworld clock's total ticks, not game time.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LOADED               BINARY-LONG.
 01 L-INHABITED            BINARY-LONG.
 01 L-MOON                 FLOAT-LONG.
 01 L-GAME-TIME            BINARY-DOUBLE.
 01 L-CLOCK                BINARY-DOUBLE.
 01 L-O-INHABITED          BINARY-LONG.
 01 L-O-MOON               FLOAT-LONG.
 01 L-TIME                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-LOADED L-INHABITED L-MOON L-GAME-TIME L-CLOCK L-O-INHABITED L-O-MOON L-TIME.
     MOVE 0 TO L-O-INHABITED L-O-MOON
     IF L-LOADED = 1
         MOVE L-INHABITED TO L-O-INHABITED
         MOVE L-MOON TO L-O-MOON
     END-IF
     MOVE L-CLOCK TO L-TIME
     GOBACK.
 END PROGRAM DF-INSTANCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SV-LAYOUT.
*> USING item (1 game time, spawn, difficulty, game type and name; 2 weather; 3 world clocks; 4 game rules; 5 world border), file out (PIC X(48)), fields
*> out (PIC X(160)): what is saved where in the 26.3 layout (10): the file and its fields.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-FILE                 PIC X(48).
 01 L-FIELDS               PIC X(160).
 PROCEDURE DIVISION USING L-ITEM L-FILE L-FIELDS.
     MOVE SPACES TO L-FILE L-FIELDS
     EVALUATE L-ITEM
         WHEN 1
             MOVE "level.dat" TO L-FILE
             MOVE "Time,spawn,difficulty_settings,GameType,LevelName,allowCommands,initialized,version" TO L-FIELDS
         WHEN 2
             MOVE "data/minecraft/weather.dat" TO L-FILE
             MOVE "clear_weather_time,rain_time,thunder_time,raining,thundering" TO L-FIELDS
         WHEN 3
             MOVE "data/minecraft/world_clocks.dat" TO L-FILE
             MOVE "total_ticks,partial_tick,rate,paused" TO L-FIELDS
         WHEN 4
             MOVE "data/minecraft/game_rules.dat" TO L-FILE
             MOVE "rule values keyed by rule id" TO L-FIELDS
         WHEN 5
             MOVE "minecraft/world_border.dat" TO L-FILE
             MOVE "center_x,center_z,damage_per_block,safe_zone,warning_blocks,warning_time,size,lerp_time,lerp_target" TO L-FIELDS
     END-EVALUATE
     GOBACK.
 END PROGRAM SV-LAYOUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-ENSURE.
*> No parameters: sets the defaults of WSIM.cpy once (random_tick_speed 3, each level's randValue a fixed constant) and the 29 machinery's (BU-ENSURE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY WSIM.
 PROCEDURE DIVISION.
     IF WSM-READY = 0
         MOVE 1 TO WSM-READY
         MOVE 3 TO WSM-SPEED
         MOVE 1013904223 TO WSM-RAND(1)
         MOVE 1664525 TO WSM-RAND(2)
         MOVE 22695477 TO WSM-RAND(3)
     END-IF
     CALL "BU-ENSURE"
     GOBACK.
 END PROGRAM WORLDSIM-ENSURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-RANDOM.
*> USING dimension row (BINARY-LONG): ServerLevel.tickChunk step 2 for every chunk that ticks (33 section 2.2 step 5 and 2.4): for each section, bottom to
*> top, whose counts say it holds randomly ticking blocks or fluids (BR-VISIT), random_tick_speed positions from randomBlockPos (WL-RANDOM-POS, the
*> level's own randValue) each get BR-RANDOM-TICK. The ice and snow attempts of step 1 are WORLDSIM-PRECIPITATION (worldsim-33d.cob).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY WSIM.
 COPY BRCOUNT.
 01 WS-NPLAYERS           BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-PX                  BINARY-LONG OCCURS 64 TIMES.
 01 WS-PZ                  BINARY-LONG OCCURS 64 TIMES.
 01 WS-CHUNK-X             BINARY-LONG.
 01 WS-CHUNK-Z             BINARY-LONG.
 01 WS-DISTANCE            BINARY-LONG.
 01 WS-ZERO-ROW            BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TICKING             BINARY-LONG.
 01 WS-SECTIONS            BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-VISIT               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-MASK                BINARY-LONG VALUE 15.
 01 WS-LAST                BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-ATTEMPT             BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-RAINING             BINARY-LONG.
 01 WS-THUNDERING          BINARY-LONG.
 01 WS-RAIN-LEVEL          FLOAT-LONG.
 01 WS-THUNDER-LEVEL       FLOAT-LONG.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     CALL "WORLDSIM-ENSURE"
     COMPUTE WS-SECTIONS = DM-HEIGHT(L-DIM) / 16
     MOVE CK-COUNT TO WS-LAST
     MOVE DM-WEATHER(L-DIM) TO WS-CAN
     MOVE CW-RAIN-LEVEL(L-DIM) TO WS-RAIN-LEVEL
     MOVE CW-THUNDER-LEVEL(L-DIM) TO WS-THUNDER-LEVEL
     CALL "WW-IS" USING WS-CAN WS-RAIN-LEVEL WS-THUNDER-LEVEL WS-RAINING WS-THUNDERING
     CALL "BR-RANDOM-TICK-ROW" USING L-DIM WS-ZERO-ROW WS-X WS-Y WS-Z
*>   The players that tick chunks of this dimension (BT-CHUNK-TICKS asked of each chunk: a player of the dimension with an entity whose
*>   centre chunk is within the view distance on both axes), listed once for the run.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     MOVE CS-VIEW-DISTANCE TO WS-DISTANCE
     MOVE 0 TO WS-NPLAYERS
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0 AND PL-DIM(WS-P) = L-DIM AND WS-NPLAYERS < 64
             ADD 1 TO WS-NPLAYERS
             MOVE PL-CENTER-X(WS-P) TO WS-PX(WS-NPLAYERS)
             MOVE PL-CENTER-Z(WS-P) TO WS-PZ(WS-NPLAYERS)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > WS-LAST
         IF CK-USED(WS-ROW) = 1 AND CK-DIM(WS-ROW) = L-DIM
             MOVE CK-X(WS-ROW) TO WS-CHUNK-X
             MOVE CK-Z(WS-ROW) TO WS-CHUNK-Z
             MOVE 0 TO WS-TICKING
             PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > WS-NPLAYERS OR WS-TICKING = 1
                 IF FUNCTION ABS(WS-CHUNK-X - WS-PX(WS-P)) <= WS-DISTANCE
                         AND FUNCTION ABS(WS-CHUNK-Z - WS-PZ(WS-P)) <= WS-DISTANCE
                     MOVE 1 TO WS-TICKING
                 END-IF
             END-PERFORM
             IF WS-TICKING = 1
                 COMPUTE WS-X0 = CK-X(WS-ROW) * 16
                 COMPUTE WS-Z0 = CK-Z(WS-ROW) * 16
                 PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > WSM-SPEED
                     CALL "WL-RANDOM-POS" USING WSM-RAND(L-DIM) WS-X0 WS-Y0 WS-Z0 WS-MASK WS-X WS-Y WS-Z
                     COMPUTE WS-DRAW = FUNCTION MOD(FUNCTION INTEGER(FUNCTION ABS(WSM-RAND(L-DIM)) / 65536), 48)
                     CALL "WL-ICE-ATTEMPT" USING WS-DRAW WS-ATTEMPT
                     IF WS-ATTEMPT = 1
                         CALL "WORLDSIM-PRECIPITATION" USING L-DIM WS-X WS-Z WS-RAINING
                     END-IF
                 END-PERFORM
                 PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S >= WS-SECTIONS
                     MOVE 0 TO WS-VISIT
                     COMPUTE WS-N = WS-S + 1
                     IF BR-TICKING-BLOCKS(WS-ROW, WS-N) > 0 OR BR-TICKING-FLUIDS(WS-ROW, WS-N) > 0
                         MOVE 1 TO WS-VISIT
                     END-IF
                     IF WS-VISIT = 1
                         COMPUTE WS-Y0 = DM-MIN-Y(L-DIM) + WS-S * 16
                         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > WSM-SPEED
                             CALL "WL-RANDOM-POS" USING WSM-RAND(L-DIM) WS-X0 WS-Y0 WS-Z0 WS-MASK WS-X WS-Y WS-Z
                             CALL "BR-RANDOM-TICK-ROW" USING L-DIM WS-ROW WS-X WS-Y WS-Z
                         END-PERFORM
                     END-IF
                 END-PERFORM
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WORLDSIM-RANDOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-TICK.
*> No parameters; called once per game tick by CORE-TICK after the clock and weather (33 section 2.1 steps 2 and 5), before the entities (step 11): for
*> each enabled level in order (overworld first): the scheduled block ticks and then the fluid ticks (BT-TICK-LEVEL, step 6), the chunk source tick
*> (WORLDSIM-RANDOM, then BC-BROADCAST: the changes made since the last tick reach the viewers, step 8) and the queued block events (BE-RUN, step 9).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "WORLDSIM-ENSURE"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CW-DIM-COUNT
         MOVE CW-DIM(WS-I) TO WS-DIM
         CALL "WORLDSIM-BORDER-TICK" USING WS-DIM
         CALL "BT-TICK-LEVEL" USING WS-DIM
         CALL "WORLDSIM-RANDOM" USING WS-DIM
         CALL "BC-BROADCAST"
         CALL "BE-RUN" USING WS-DIM
     END-PERFORM
     GOBACK.
 END PROGRAM WORLDSIM-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-ACKS.
*> No parameters: the start of each connection's tick (29 section 7.3, step 7 of 1.2): a stored block-change sequence is sent as Block Changed Ack.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ID                  BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > CORE-MAX-CONNS
         IF CN-USED(WS-ID) = 1 AND CN-CLOSE(WS-ID) = 0 AND CN-PLAYER(WS-ID) > 0
             CALL "BC-ACK-TICK" USING WS-ID
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WORLDSIM-ACKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-FLUSH.
*> No parameters: the part of a game tick that sends block changes and acknowledgements, without the rest of the tick (BC-BROADCAST, then WORLDSIM-ACKS).
*> Tests of the play path call it after feeding a packet instead of running a whole tick; CORE-TICK runs both in their places of the tick order.
 DATA DIVISION.
 PROCEDURE DIVISION.
     CALL "BC-BROADCAST"
     CALL "WORLDSIM-ACKS"
     GOBACK.
 END PROGRAM WORLDSIM-FLUSH.
