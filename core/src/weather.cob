*> Weather (docs/protocol/33-world-simulation.md section 4; 16 §4.10; data-model §9). One WeatherData shared by every
*> dimension (CORESTATE.cpy CW-CLEAR-TIME, CW-RAIN-TIME, CW-THUNDER-TIME, CW-RAINING, CW-THUNDERING) and four levels per
*> dimension row that can have weather (DM-WEATHER 1: sky light, no ceiling, not the end): CW-RAIN-LEVEL, CW-THUNDER-LEVEL and
*> the values of the tick before (CW-RAIN-LEVEL-OLD, CW-THUNDER-LEVEL-OLD), 0 to 1, in single precision as the standard
*> game has them. The same mechanism serves both world types; in the cobolcraft type drizzle is rain and hailstorm is
*> thunder, a drawing skin (09 §3.3, standin §14.1), so no kind is stored.
*>
*> WEATHER-TICK (step 3 of standin §9.5, once per tick, for each enabled dimension with weather; the shared state is
*> advanced once per such dimension, as 33 §4.1 says, so with one weather dimension once per tick):
*>   A. when the setting weather-changes is on (the rule advance_weather; CS-WEATHER-CHANGES): the cycle of 33 §4.2 on the
*>      clear time, thunder time and rain time and the two flags, drawing new times uniformly from RAIN_DELAY 12000 to
*>      180000, RAIN_DURATION 12000 to 24000, THUNDER_DELAY 12000 to 180000 and THUNDER_DURATION 3600 to 15600 (inclusive),
*>      the thunder draw before the rain draw; the draws come from RNG-HASH (core/src/rng.cob) of the dimension row, CW-TIME
*>      and the draw's number, the core's deterministic source instead of the level random.
*>   B. always: the old levels take the levels; each level moves 0.01 (single precision) toward 1 when its flag is set, else
*>      toward 0, clamped to 0 and 1, thunder first, then rain.
*>   C. packets: Game Event 7 with the rain level and 8 with the thunder level to the players of the dimension when the
*>      level changed; when isRaining changed (rain level above 0.2) Game Event 2 (was raining) or 1 to every player in play,
*>      then 7 and 8 with the current levels to every player.
*> isRaining is the rain level above 0.2 (a single precision comparison against the double 0.2); isThundering is the
*> thunder level times the rain level above 0.9. A dimension without weather has all levels 0 and is sent nothing by C.
*>
*> A player who joins, respawns or arrives in a dimension is sent (WEATHER-SEND) Game Event 1, 7 and 8 when the dimension
*> isRaining (the rain level, and the thunder level times the rain level); nothing otherwise.
*>
*> Hail (§14.6, cobolcraft only): every tick with Time mod 80 = 0 while the dimension isThundering, every alive survival
*> player (WEATHER-HAIL-PLAYER) and every mob (WEATHER-HAIL-MOB) that is exposed takes 1 damage of cause cobolcraft:hail
*> (§10.3) through the damage path (HEALTH-DAMAGE, HEALTH-MOB-DAMAGE). Exposed (WEATHER-EXPOSED): the biome cell holding its
*> position has has_precipitation 1, and every cell of its column (floor(x), j, floor(z)) with floor(y + height) <= j <= the
*> dimension's top y is void. Biomes come from the cobolcraft:main generator (WORLDGEN-BIOMES).
*>
*> Entry points:
*>   WEATHER-INIT                                   a new world: all times 0, no rain, no thunder, levels 0
*>   WEATHER-LEVELS-LOAD                            after the state was read: levels 1 where the flags are set (33 §4.1)
*>   WEATHER-TICK                                   step 3 of §9.5
*>   WEATHER-SEND USING player row                  the join pair of the player's dimension (above)
*>   WEATHER-RAINING USING dimension row, raining out    isRaining (1 or 0)
*>   WEATHER-THUNDERING USING dimension row, thundering out    isThundering (1 or 0)
*>   WEATHER-SET-KIND USING kind, time              the same for a skin of the cobolcraft type (clear, drizzle, hailstorm)
*>   WEATHER-SET USING clear time, rain time, raining, thundering   MinecraftServer.setWeatherParameters (33 §4.3: the thunder
*>     time becomes the rain time; the levels follow by B)
*>   WEATHER-HAIL-PLAYER USING player row          hail on an alive player (step 4)
*>   WEATHER-HAIL-MOB USING mob tracker row        hail on a mob (step 6)
*> Internal: WEATHER-HAIL-DUE, WEATHER-EXPOSED, WEATHER-SAMPLE, WEATHER-CYCLE, WEATHER-SMOOTH, WEATHER-ANNOUNCE.
*> Builder (appends id + body to the caller's PB-BUFFER):
*>   WEATHER-EVENT-BUILD USING kind, step (1 to 3), PB-BUFFER    the step-th Game Event of the pair of a kind of the skin

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEATHER-EVENT-BUILD.
*> USING kind (WEATHER.cpy WK-*, the skin of the levels), step (1 START/STOP_RAINING, 2 rain level, 3 thunder level)
*> (BINARY-LONG each), PB-BUFFER: Game Event 0x27 of that step of the full-strength pair of the kind.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY WEATHER.
 01 WS-KIND                BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-VALUE               FLOAT-SHORT.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-KIND                 BINARY-LONG.
 01 L-STEP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-STEP PB-BUFFER.
     MOVE L-KIND TO WS-KIND
     EVALUATE L-STEP
         WHEN 1
             MOVE WEATHER-EVENT-STOP TO WS-EVENT
             IF WK-RAIN-MILLI(WS-KIND) > 0
                 MOVE WEATHER-EVENT-START TO WS-EVENT
             END-IF
             MOVE 0 TO WS-VALUE
         WHEN 2
             MOVE WEATHER-EVENT-RAIN TO WS-EVENT
             COMPUTE WS-VALUE = WK-RAIN-MILLI(WS-KIND) / 1000
         WHEN OTHER
             MOVE WEATHER-EVENT-THUNDER TO WS-EVENT
             COMPUTE WS-VALUE = WK-THUNDER-MILLI(WS-KIND) / 1000
     END-EVALUATE
     CALL "PLAY-GAME-EVENT-BUILD" USING WS-EVENT WS-VALUE PB-BUFFER
     GOBACK.
 END PROGRAM WEATHER-EVENT-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEATHER-INIT.
*> No parameters; called by CORE-WORLD-OPEN for a new world: every time 0, no rain, no thunder, every level 0 (33 4.1: the first
*> cycle draws fresh delays).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-D                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 0 TO CW-CLEAR-TIME CW-RAIN-TIME CW-THUNDER-TIME CW-RAINING CW-THUNDERING
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 3
         MOVE 0 TO CW-RAIN-LEVEL(WS-D) CW-RAIN-LEVEL-OLD(WS-D) CW-THUNDER-LEVEL(WS-D) CW-THUNDER-LEVEL-OLD(WS-D)
     END-PERFORM
     GOBACK.
 END PROGRAM WEATHER-INIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEATHER-LEVELS-LOAD.
*> No parameters: a level that can have weather starts at 1 when the stored state is raining, and its thunder level at 1 when it
*> is thundering too, so a saved storm resumes at full strength without a fade (33 4.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 01 WS-D                   BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > DIM-TABLE-ROWS
         MOVE 0 TO CW-RAIN-LEVEL(WS-D) CW-THUNDER-LEVEL(WS-D)
         IF DM-WEATHER(WS-D) = 1 AND CW-RAINING = 1
             MOVE 1 TO CW-RAIN-LEVEL(WS-D)
             IF CW-THUNDERING = 1
                 MOVE 1 TO CW-THUNDER-LEVEL(WS-D)
             END-IF
         END-IF
         MOVE CW-RAIN-LEVEL(WS-D) TO CW-RAIN-LEVEL-OLD(WS-D)
         MOVE CW-THUNDER-LEVEL(WS-D) TO CW-THUNDER-LEVEL-OLD(WS-D)
     END-PERFORM
     GOBACK.
 END PROGRAM WEATHER-LEVELS-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEATHER-RAINING.
*> USING dimension row, raining out (1 or 0): isRaining, the rain level above 0.2 in a dimension that can have weather. The
*> comparison is made on the level scaled by 10^9: it keeps the 0.20000002 of twenty additions of 0.01 (single precision) above 0.2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 01 WS-SCALED              BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-RAINING              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-RAINING.
     MOVE 0 TO L-RAINING
     COMPUTE WS-SCALED = CW-RAIN-LEVEL(L-DIM) * 1000000000
     IF DM-WEATHER(L-DIM) = 1 AND WS-SCALED > 200000000
         MOVE 1 TO L-RAINING
     END-IF
     GOBACK.
 END PROGRAM WEATHER-RAINING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEATHER-THUNDERING.
*> USING dimension row, thundering out (1 or 0): isThundering, the thunder level times the rain level above 0.9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 01 WS-SCALED              BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-THUNDERING           BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-THUNDERING.
     MOVE 0 TO L-THUNDERING
     COMPUTE WS-SCALED = CW-THUNDER-LEVEL(L-DIM) * CW-RAIN-LEVEL(L-DIM) * 1000000000
     IF DM-WEATHER(L-DIM) = 1 AND WS-SCALED > 900000000
         MOVE 1 TO L-THUNDERING
     END-IF
     GOBACK.
 END PROGRAM WEATHER-THUNDERING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEATHER-SET.
*> USING clear time, rain time (BINARY-LONG), raining, thundering (BINARY-LONG 1 or 0): setWeatherParameters (33 4.3): the
*> clear, rain and thunder times (the thunder time is the rain time) and the flags; the levels follow by the smoothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-CLEAR                BINARY-LONG.
 01 L-RAIN                 BINARY-LONG.
 01 L-RAINING              BINARY-LONG.
 01 L-THUNDERING           BINARY-LONG.
 PROCEDURE DIVISION USING L-CLEAR L-RAIN L-RAINING L-THUNDERING.
     MOVE L-CLEAR TO CW-CLEAR-TIME
     MOVE L-RAIN TO CW-RAIN-TIME CW-THUNDER-TIME
     MOVE L-RAINING TO CW-RAINING
     MOVE L-THUNDERING TO CW-THUNDERING
     GOBACK.
 END PROGRAM WEATHER-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEATHER-SET-KIND.
*> USING kind (WEATHER.cpy WK-*, the skin), time (BINARY-LONG ticks): the shared state of that skin for that long, through
*> WEATHER-SET: clear is clear time, drizzle is rain, hailstorm is rain and thunder.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY WEATHER.
 01 WS-CLEAR               BINARY-LONG.
 01 WS-RAIN                BINARY-LONG.
 01 WS-RAINING             BINARY-LONG.
 01 WS-THUNDERING          BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-TIME                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-TIME.
     MOVE 0 TO WS-CLEAR WS-RAIN WS-RAINING WS-THUNDERING
     EVALUATE L-KIND
         WHEN WK-CLEAR
             MOVE L-TIME TO WS-CLEAR
         WHEN WK-DRIZZLE
             MOVE L-TIME TO WS-RAIN
             MOVE 1 TO WS-RAINING
         WHEN OTHER
             MOVE L-TIME TO WS-RAIN
             MOVE 1 TO WS-RAINING WS-THUNDERING
     END-EVALUATE
     CALL "WEATHER-SET" USING WS-CLEAR WS-RAIN WS-RAINING WS-THUNDERING
     GOBACK.
 END PROGRAM WEATHER-SET-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEATHER-SAMPLE.
*> USING dimension row, draw number, low, high (BINARY-LONG), value out: a uniform integer from low to high inclusive, from the
*> deterministic source RNG-HASH of the dimension row, the time of day and the draw number.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-SPAN                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-LOW                  BINARY-LONG.
 01 L-HIGH                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-DRAW L-LOW L-HIGH L-VALUE.
     COMPUTE WS-ARG(1) = L-DIM - 1
     MOVE CW-TIME TO WS-ARG(2)
     MOVE L-DRAW TO WS-ARG(3)
     CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
     COMPUTE WS-SPAN = L-HIGH - L-LOW + 1
     COMPUTE L-VALUE = L-LOW + FUNCTION MOD(WS-R, WS-SPAN)
     GOBACK.
 END PROGRAM WEATHER-SAMPLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEATHER-CYCLE.
*> USING dimension row: part A of 33 4.2 on the shared state.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WEATHER.
 01 WS-CLEAR               BINARY-LONG.
 01 WS-THUNDER-T           BINARY-LONG.
 01 WS-RAIN-T              BINARY-LONG.
 01 WS-THUNDER             BINARY-LONG.
 01 WS-RAIN                BINARY-LONG.
 01 WS-DRAW-THUNDER        BINARY-LONG VALUE 1.
 01 WS-DRAW-RAIN           BINARY-LONG VALUE 2.
 01 WS-LOW                 BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     MOVE CW-CLEAR-TIME TO WS-CLEAR
     MOVE CW-THUNDER-TIME TO WS-THUNDER-T
     MOVE CW-RAIN-TIME TO WS-RAIN-T
     MOVE CW-THUNDERING TO WS-THUNDER
     MOVE CW-RAINING TO WS-RAIN
     IF WS-CLEAR > 0
         SUBTRACT 1 FROM WS-CLEAR
         MOVE 1 TO WS-THUNDER-T WS-RAIN-T
         IF WS-THUNDER = 1
             MOVE 0 TO WS-THUNDER-T
         END-IF
         IF WS-RAIN = 1
             MOVE 0 TO WS-RAIN-T
         END-IF
         MOVE 0 TO WS-THUNDER WS-RAIN
     ELSE
         IF WS-THUNDER-T > 0
             SUBTRACT 1 FROM WS-THUNDER-T
             IF WS-THUNDER-T = 0
                 COMPUTE WS-THUNDER = 1 - WS-THUNDER
             END-IF
         ELSE
             MOVE WEATHER-THUNDER-DELAY-MIN TO WS-LOW
             MOVE WEATHER-THUNDER-DELAY-MAX TO WS-HIGH
             IF WS-THUNDER = 1
                 MOVE WEATHER-THUNDER-LENGTH-MIN TO WS-LOW
                 MOVE WEATHER-THUNDER-LENGTH-MAX TO WS-HIGH
             END-IF
             CALL "WEATHER-SAMPLE" USING L-DIM WS-DRAW-THUNDER WS-LOW WS-HIGH WS-THUNDER-T
         END-IF
         IF WS-RAIN-T > 0
             SUBTRACT 1 FROM WS-RAIN-T
             IF WS-RAIN-T = 0
                 COMPUTE WS-RAIN = 1 - WS-RAIN
             END-IF
         ELSE
             MOVE WEATHER-RAIN-DELAY-MIN TO WS-LOW
             MOVE WEATHER-RAIN-DELAY-MAX TO WS-HIGH
             IF WS-RAIN = 1
                 MOVE WEATHER-RAIN-LENGTH-MIN TO WS-LOW
                 MOVE WEATHER-RAIN-LENGTH-MAX TO WS-HIGH
             END-IF
             CALL "WEATHER-SAMPLE" USING L-DIM WS-DRAW-RAIN WS-LOW WS-HIGH WS-RAIN-T
         END-IF
     END-IF
     MOVE WS-CLEAR TO CW-CLEAR-TIME
     MOVE WS-THUNDER-T TO CW-THUNDER-TIME
     MOVE WS-RAIN-T TO CW-RAIN-TIME
     MOVE WS-THUNDER TO CW-THUNDERING
     MOVE WS-RAIN TO CW-RAINING
     GOBACK.
 END PROGRAM WEATHER-CYCLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEATHER-SMOOTH.
*> USING dimension row: part B of 33 4.2 on the levels of the row (thunder first, then rain).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-STEP                FLOAT-SHORT VALUE 0.01.
 01 WS-ONE                 FLOAT-SHORT VALUE 1.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     MOVE CW-THUNDER-LEVEL(L-DIM) TO CW-THUNDER-LEVEL-OLD(L-DIM)
     IF CW-THUNDERING = 1
         COMPUTE CW-THUNDER-LEVEL(L-DIM) = CW-THUNDER-LEVEL(L-DIM) + WS-STEP
     ELSE
         COMPUTE CW-THUNDER-LEVEL(L-DIM) = CW-THUNDER-LEVEL(L-DIM) - WS-STEP
     END-IF
     IF CW-THUNDER-LEVEL(L-DIM) < 0
         MOVE 0 TO CW-THUNDER-LEVEL(L-DIM)
     END-IF
     IF CW-THUNDER-LEVEL(L-DIM) > WS-ONE
         MOVE WS-ONE TO CW-THUNDER-LEVEL(L-DIM)
     END-IF
     MOVE CW-RAIN-LEVEL(L-DIM) TO CW-RAIN-LEVEL-OLD(L-DIM)
     IF CW-RAINING = 1
         COMPUTE CW-RAIN-LEVEL(L-DIM) = CW-RAIN-LEVEL(L-DIM) + WS-STEP
     ELSE
         COMPUTE CW-RAIN-LEVEL(L-DIM) = CW-RAIN-LEVEL(L-DIM) - WS-STEP
     END-IF
     IF CW-RAIN-LEVEL(L-DIM) < 0
         MOVE 0 TO CW-RAIN-LEVEL(L-DIM)
     END-IF
     IF CW-RAIN-LEVEL(L-DIM) > WS-ONE
         MOVE WS-ONE TO CW-RAIN-LEVEL(L-DIM)
     END-IF
     GOBACK.
 END PROGRAM WEATHER-SMOOTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEATHER-SEND-EVENT.
*> USING dimension row (0 = every player), event, value (FLOAT-SHORT): a Game Event to the players of the dimension in play
*> whose join has been sent.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-VALUE                FLOAT-SHORT.
 PROCEDURE DIVISION USING L-DIM L-EVENT L-VALUE.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PLAY-GAME-EVENT-BUILD" USING L-EVENT L-VALUE PB-BUFFER
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1 AND PL-ENTITY-ROW(WS-ROW) > 0 AND (L-DIM = 0 OR PL-DIM(WS-ROW) = L-DIM)
             CALL "CORE-SEND" USING PL-CONN(WS-ROW) PB-BUFFER
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM WEATHER-SEND-EVENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEATHER-SEND.
*> USING player row (BINARY-LONG): the join pair (Game Event 1, 7 with the rain level, 8 with the thunder level times the rain
*> level) when the player's dimension isRaining; nothing otherwise (33 4.2 C).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WEATHER.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-RAINING             BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-VALUE               FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "WEATHER-RAINING" USING PL-DIM(L-ROW) WS-RAINING
     IF WS-RAINING = 1
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE WEATHER-EVENT-START TO WS-EVENT
         MOVE 0 TO WS-VALUE
         CALL "PLAY-GAME-EVENT-BUILD" USING WS-EVENT WS-VALUE PB-BUFFER
         CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
         CALL "PB-RESET" USING PB-BUFFER
         MOVE WEATHER-EVENT-RAIN TO WS-EVENT
         MOVE CW-RAIN-LEVEL(PL-DIM(L-ROW)) TO WS-VALUE
         CALL "PLAY-GAME-EVENT-BUILD" USING WS-EVENT WS-VALUE PB-BUFFER
         CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
         CALL "PB-RESET" USING PB-BUFFER
         MOVE WEATHER-EVENT-THUNDER TO WS-EVENT
         COMPUTE WS-VALUE = CW-THUNDER-LEVEL(PL-DIM(L-ROW)) * CW-RAIN-LEVEL(PL-DIM(L-ROW))
         CALL "PLAY-GAME-EVENT-BUILD" USING WS-EVENT WS-VALUE PB-BUFFER
         CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
         CALL "PB-FREE" USING PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM WEATHER-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEATHER-ANNOUNCE.
*> USING dimension row, was raining (BINARY-LONG): part C of 33 4.2 after the levels moved.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WEATHER.
 01 WS-RAINING             BINARY-LONG.
 01 WS-ALL                 BINARY-LONG VALUE 0.
 01 WS-EVENT               BINARY-LONG.
 01 WS-VALUE               FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-WAS                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-WAS.
     IF CW-RAIN-LEVEL-OLD(L-DIM) NOT = CW-RAIN-LEVEL(L-DIM)
         MOVE WEATHER-EVENT-RAIN TO WS-EVENT
         MOVE CW-RAIN-LEVEL(L-DIM) TO WS-VALUE
         CALL "WEATHER-SEND-EVENT" USING L-DIM WS-EVENT WS-VALUE
     END-IF
     IF CW-THUNDER-LEVEL-OLD(L-DIM) NOT = CW-THUNDER-LEVEL(L-DIM)
         MOVE WEATHER-EVENT-THUNDER TO WS-EVENT
         MOVE CW-THUNDER-LEVEL(L-DIM) TO WS-VALUE
         CALL "WEATHER-SEND-EVENT" USING L-DIM WS-EVENT WS-VALUE
     END-IF
     CALL "WEATHER-RAINING" USING L-DIM WS-RAINING
     IF WS-RAINING NOT = L-WAS
         MOVE WEATHER-EVENT-START TO WS-EVENT
         IF L-WAS = 1
             MOVE WEATHER-EVENT-STOP TO WS-EVENT
         END-IF
         MOVE 0 TO WS-VALUE
         CALL "WEATHER-SEND-EVENT" USING WS-ALL WS-EVENT WS-VALUE
         MOVE WEATHER-EVENT-RAIN TO WS-EVENT
         MOVE CW-RAIN-LEVEL(L-DIM) TO WS-VALUE
         CALL "WEATHER-SEND-EVENT" USING WS-ALL WS-EVENT WS-VALUE
         MOVE WEATHER-EVENT-THUNDER TO WS-EVENT
         MOVE CW-THUNDER-LEVEL(L-DIM) TO WS-VALUE
         CALL "WEATHER-SEND-EVENT" USING WS-ALL WS-EVENT WS-VALUE
     END-IF
     GOBACK.
 END PROGRAM WEATHER-ANNOUNCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEATHER-TICK.
*> No parameters; step 3 of standin §9.5: A, B and C of 33 4.2 for every enabled dimension that can have weather.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-WAS                 BINARY-LONG.
 LINKAGE SECTION.
 COPY COREAPI.
 PROCEDURE DIVISION.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CW-DIM-COUNT
         MOVE CW-DIM(WS-I) TO WS-D
         IF DM-WEATHER(WS-D) = 1
             CALL "WEATHER-RAINING" USING WS-D WS-WAS
             IF CS-WEATHER-CHANGES = 1
                 CALL "WEATHER-CYCLE" USING WS-D
             END-IF
             CALL "WEATHER-SMOOTH" USING WS-D
             CALL "WEATHER-ANNOUNCE" USING WS-D WS-WAS
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WEATHER-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEATHER-HAIL-DUE.
*> USING dimension row, due out (BINARY-LONG): 1 when hail strikes the dimension this tick (it isThundering and Time mod 80 = 0),
*> otherwise 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WEATHER.
 01 WS-THUNDERING          BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-DUE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-DUE.
     MOVE 0 TO L-DUE
     CALL "WEATHER-THUNDERING" USING L-DIM WS-THUNDERING
     IF WS-THUNDERING = 1 AND FUNCTION MOD(CW-TIME, WEATHER-HAIL-INTERVAL) = 0
         MOVE 1 TO L-DUE
     END-IF
     GOBACK.
 END PROGRAM WEATHER-HAIL-DUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEATHER-EXPOSED.
*> USING dimension row (BINARY-LONG), x, y, z (FLOAT-LONG), height in thousandths (BINARY-LONG),
*> exposed out (BINARY-LONG): 1 when an entity of that height at that position is exposed (above).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-CELL-Z              BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BIOMES.
    05 WS-BIOME            BINARY-LONG OCCURS 16 TIMES.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-HEIGHT-MILLI         BINARY-LONG.
 01 L-EXPOSED              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-HEIGHT-MILLI L-EXPOSED.
     COMPUTE WS-BX = FUNCTION INTEGER(L-X)
     COMPUTE WS-BZ = FUNCTION INTEGER(L-Z)
     COMPUTE WS-CX = (WS-BX - FUNCTION MOD(WS-BX, 16)) / 16
     COMPUTE WS-CZ = (WS-BZ - FUNCTION MOD(WS-BZ, 16)) / 16
     CALL "WORLDGEN-BIOMES" USING WS-CX WS-CZ WS-BIOMES
     COMPUTE WS-CELL-Z = (WS-BZ - WS-CZ * 16) / 4
     COMPUTE WS-CELL = (WS-BX - WS-CX * 16) / 4
     COMPUTE WS-CELL = WS-CELL-Z * 4 + WS-CELL + 1
     MOVE CBI-PRECIPITATION(WS-BIOME(WS-CELL) + 1) TO L-EXPOSED
     COMPUTE WS-J = FUNCTION INTEGER(L-Y + L-HEIGHT-MILLI / 1000)
     COMPUTE WS-TOP = DM-MIN-Y(L-DIM) + DM-HEIGHT(L-DIM) - 1
     PERFORM UNTIL WS-J > WS-TOP OR L-EXPOSED = 0
         CALL "WORLD-GET-BLOCK" USING L-DIM WS-BX WS-J WS-BZ WS-STATE
         IF WS-STATE NOT = 0
             MOVE 0 TO L-EXPOSED
         END-IF
         ADD 1 TO WS-J
     END-PERFORM
     GOBACK.
 END PROGRAM WEATHER-EXPOSED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEATHER-HAIL-PLAYER.
*> USING player row (BINARY-LONG) of an alive player: hail damage when it is due and the player is
*> exposed (HEALTH-DAMAGE ignores creative players and the hurt cooldown).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY CITEMS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DUE                 BINARY-LONG.
 01 WS-EXPOSED             BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-HAIL.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE L-ROW TO WS-ROW
     CALL "WEATHER-HAIL-DUE" USING PL-DIM(WS-ROW) WS-DUE
     IF WS-DUE = 0 OR PL-MODE(WS-ROW) NOT = 0
         GOBACK
     END-IF
     CALL "WEATHER-EXPOSED" USING PL-DIM(WS-ROW) PL-X(WS-ROW) PL-Y(WS-ROW) PL-Z(WS-ROW)
         ET-HEIGHT-MILLI(CR-OPERATOR + 1) WS-EXPOSED
     IF WS-EXPOSED = 1
         CALL "HEALTH-DAMAGE" USING WS-ROW RULE-CAUSE-AMOUNT(CAUSE-HAIL) WS-CAUSE WS-NONE WS-NONE2
     END-IF
     GOBACK.
 END PROGRAM WEATHER-HAIL-PLAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEATHER-HAIL-MOB.
*> USING mob tracker row (BINARY-LONG): hail damage when it is due and the mob is exposed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY CITEMS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DUE                 BINARY-LONG.
 01 WS-EXPOSED             BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-HAIL.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE L-ROW TO WS-ROW
     CALL "WEATHER-HAIL-DUE" USING EN-DIM(WS-ROW) WS-DUE
     IF WS-DUE = 0
         GOBACK
     END-IF
     CALL "WEATHER-EXPOSED" USING EN-DIM(WS-ROW) EN-X(WS-ROW) EN-Y(WS-ROW) EN-Z(WS-ROW)
         ET-HEIGHT-MILLI(EN-TYPE(WS-ROW) + 1) WS-EXPOSED
     IF WS-EXPOSED = 1
         CALL "HEALTH-MOB-DAMAGE" USING WS-ROW RULE-CAUSE-AMOUNT(CAUSE-HAIL) WS-CAUSE WS-NONE
     END-IF
     GOBACK.
 END PROGRAM WEATHER-HAIL-MOB.
