*> Weather per dimension (US11; standin-content §14; data-model §9; docs/protocol/09-cobolcraft-profile.md
*> §3.3 weather values). The kinds and rules are core/copy/WEATHER.cpy; the state is CW-WEATHER-KIND
*> and CW-WEATHER-LEFT of CORESTATE.cpy, indexed by the DIMENSIONS.cpy row.
*>
*> State (§14.3): a dimension with weather (DM-WEATHER 1) starts clear with 6000 remaining ticks; a
*> dimension without weather has kind 0, is never changed and has no hail; its players are always
*> sent the clear pair (§14.2, US11 edge case).
*>
*> Change (WEATHER-TICK, step 3 of standin §9.5, after Time advanced): while the weather-changes
*> setting is on (FR-009; off: nothing changes, US11-4), for each enabled dimension with weather
*> whose remaining time is not -1, the remaining time decreases by 1; at 0, with
*> r = H(d, Time) (d = dimension row - 1, core/src/rng.cob): after clear the next kind is drizzle
*> when r mod 100 < 70, otherwise hailstorm; after drizzle or hailstorm, clear; the remaining time
*> becomes the new kind's base + ((r div 100) mod span), and every player in the dimension is sent
*> the new kind's pair.
*>
*> The pair (§14.4): Game Event 1 START_RAINING (0.0) when the kind's rain level is above 0,
*> otherwise 2 STOP_RAINING (0.0); then 7 RAIN_LEVEL_CHANGE with the rain level; then 8
*> THUNDER_LEVEL_CHANGE with the thunder level. It is sent on every change of kind, and by
*> PLAY-ARRIVE (core/src/play.cob) on join, after a respawn and on arrival in another dimension.
*>
*> Hail (§14.6): on every tick with Time mod 80 = 0 while a dimension's kind has the hail effect
*> (the hailstorm), every alive survival player in it (WEATHER-HAIL-PLAYER, last of step 4 of §9.5)
*> and every mob in it (WEATHER-HAIL-MOB, last of a mob's step 6) that is exposed takes 1 damage of
*> cause cobolcraft:hail (§10.3) through the damage path (HEALTH-DAMAGE, HEALTH-MOB-DAMAGE: the
*> hurt cooldown, creative and dead players are respected there). Exposed (WEATHER-EXPOSED): the
*> biome cell holding its position has has_precipitation 1, and every cell of its column
*> (floor(x), j, floor(z)) with floor(y + height) <= j <= the dimension's top y is void. Biomes come
*> from the cobolcraft:main generator (WORLDGEN-BIOMES), the only dimension with weather.
*>
*> Entry points:
*>   WEATHER-INIT                                   the new-world state of every dimension
*>   WEATHER-TICK                                   step 3 of §9.5
*>   WEATHER-SEND USING player row                  the pair of the player's dimension
*>   WEATHER-BROADCAST USING dimension row          the pair to every player in the dimension
*>   WEATHER-HAIL-PLAYER USING player row           hail on an alive player (step 4)
*>   WEATHER-HAIL-MOB USING mob tracker row         hail on a mob (step 6)
*> Internal: WEATHER-HAIL-DUE, WEATHER-EXPOSED.
*> Builder (appends id + body to the caller's PB-BUFFER):
*>   WEATHER-EVENT-BUILD USING kind, step (1 to 3), PB-BUFFER    the step-th Game Event of the pair

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEATHER-EVENT-BUILD.
*> USING kind (WEATHER.cpy WK-*), step (1 START/STOP_RAINING, 2 rain level, 3 thunder level)
*> (BINARY-LONG each), PB-BUFFER: Game Event 0x27 of that step of the kind's pair.
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
*> No parameters; called by CORE-WORLD-OPEN for a new world: every dimension with weather is clear
*> with 6000 remaining ticks, every other dimension has kind 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY WEATHER.
 01 WS-D                   BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > DIM-TABLE-ROWS
         MOVE 0 TO CW-WEATHER-KIND(WS-D) CW-WEATHER-LEFT(WS-D)
         IF DM-WEATHER(WS-D) = 1
             MOVE WEATHER-START-KIND TO CW-WEATHER-KIND(WS-D)
             MOVE WEATHER-START-TICKS TO CW-WEATHER-LEFT(WS-D)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WEATHER-INIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEATHER-SEND.
*> USING player row (BINARY-LONG): the pair of the player's dimension, to the player; a dimension
*> without weather sends the clear pair, whatever the weather elsewhere (§14.2, §14.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY WEATHER.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-KIND                BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE CW-WEATHER-KIND(PL-DIM(L-ROW)) TO WS-KIND
     IF DM-WEATHER(PL-DIM(L-ROW)) = 0
         MOVE WK-CLEAR TO WS-KIND
     END-IF
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     PERFORM VARYING WS-STEP FROM 1 BY 1 UNTIL WS-STEP > 3
         CALL "PB-RESET" USING PB-BUFFER
         CALL "WEATHER-EVENT-BUILD" USING WS-KIND WS-STEP PB-BUFFER
         CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM WEATHER-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEATHER-BROADCAST.
*> USING dimension row (BINARY-LONG): WEATHER-SEND to every player of the dimension whose join has
*> been sent.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1 AND PL-ENTITY-ROW(WS-ROW) > 0 AND PL-DIM(WS-ROW) = L-DIM
             CALL "WEATHER-SEND" USING WS-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WEATHER-BROADCAST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEATHER-TICK.
*> No parameters; step 3 of standin §9.5: the countdown and change rules above, for every enabled
*> dimension with weather.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY WEATHER.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG VALUE 2.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-Q                   BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY COREAPI.
 PROCEDURE DIVISION.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CW-DIM-COUNT
         MOVE CW-DIM(WS-I) TO WS-D
         IF DM-WEATHER(WS-D) = 1 AND CS-WEATHER-CHANGES = 1
                 AND CW-WEATHER-LEFT(WS-D) NOT = WEATHER-UNTIL-CHANGED
             SUBTRACT 1 FROM CW-WEATHER-LEFT(WS-D)
         END-IF
         IF DM-WEATHER(WS-D) = 1 AND CS-WEATHER-CHANGES = 1 AND CW-WEATHER-LEFT(WS-D) = 0
             COMPUTE WS-ARG(1) = WS-D - 1
             MOVE CW-TIME TO WS-ARG(2)
             CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
             MOVE WK-CLEAR TO WS-KIND
             IF CW-WEATHER-KIND(WS-D) = WK-CLEAR
                 MOVE WK-HAILSTORM TO WS-KIND
                 IF FUNCTION MOD(WS-R, WEATHER-CHANCE-RANGE) < WEATHER-DRIZZLE-CHANCE
                     MOVE WK-DRIZZLE TO WS-KIND
                 END-IF
             END-IF
             COMPUTE WS-Q = WS-R / WEATHER-CHANCE-RANGE
             MOVE WS-KIND TO CW-WEATHER-KIND(WS-D)
             COMPUTE CW-WEATHER-LEFT(WS-D) = WK-DURATION-BASE(WS-KIND)
                 + FUNCTION MOD(WS-Q, WK-DURATION-SPAN(WS-KIND))
             CALL "WEATHER-BROADCAST" USING WS-D
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WEATHER-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WEATHER-HAIL-DUE.
*> USING dimension row, due out (BINARY-LONG): 1 when hail strikes the dimension this tick (it has
*> weather, its kind has the hail effect and Time mod 80 = 0), otherwise 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY WEATHER.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-DUE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-DUE.
     MOVE 0 TO L-DUE
     IF DM-WEATHER(L-DIM) = 0
         GOBACK
     END-IF
     IF WK-EFFECT(CW-WEATHER-KIND(L-DIM)) = WEATHER-EFFECT-HAIL
             AND FUNCTION MOD(CW-TIME, WEATHER-HAIL-INTERVAL) = 0
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
 COPY ENTITYTYPES.
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
         ET-HEIGHT-MILLI(ET-OPERATOR + 1) WS-EXPOSED
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
 COPY ENTITYTYPES.
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
