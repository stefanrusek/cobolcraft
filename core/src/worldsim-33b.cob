*> World simulation wiring, second part (docs/protocol/33 sections 3, 5 and 7): the clock of the overworld (rate, pause, advance_time, partial tick; Set Time
*> carries rate 0.0 while it stands still), the sleeping flow (using a bed, the sleep counter, the night skip with its weather reset) and the world border
*> (a state per level, the lerp of a moving border and the damage to a player outside it). World borders are inert at their default size of 59999968.
*> Not wired and still decision helpers only (worldsim-33.cob): the border packets (Initialize Border, Set Border Size and the others), the player pose and
*> overlay texts of sleeping, the set-spawn side effect of a bed, the `time`, `gamerule` and `worldborder` commands (the commands lane calls
*> WORLDSIM-CLOCK-SET and WORLDSIM-BORDER-SET / WORLDSIM-BORDER-LERP), and the border death message (the damage uses CAUSE-COMMAND).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-ENSURE2.
*> No parameters: sets the defaults of WSIM2.cpy once: advance_time on, the clock running at rate 1.0, players_sleeping_percentage 100, every border at its
*> default (centre 0, size 59999968, absolute maximum 29999984, damage 0.2 per block, safe zone 5.0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY WSIM2.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     IF W2-READY = 0
         MOVE 1 TO W2-READY
         MOVE 1 TO W2-ADVANCE
         MOVE 0 TO W2-PAUSED
         MOVE 1.0 TO W2-RATE
         MOVE 0 TO W2-PARTIAL
         MOVE 100 TO W2-SLEEP-PCT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
             MOVE 0 TO W2-SLEEPING(WS-I) W2-SLEEP-COUNTER(WS-I)
         END-PERFORM
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
             MOVE 0 TO W2-B-CX(WS-I) W2-B-CZ(WS-I) W2-B-FROM(WS-I) W2-B-TO(WS-I)
             MOVE 59999968 TO W2-B-SIZE(WS-I)
             MOVE 29999984 TO W2-B-ABSOLUTE(WS-I)
             MOVE 0.2 TO W2-B-DAMAGE(WS-I)
             MOVE 5.0 TO W2-B-SAFE(WS-I)
             MOVE 0 TO W2-B-DURATION(WS-I) W2-B-PROGRESS(WS-I) W2-B-MOVING(WS-I)
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM WORLDSIM-ENSURE2.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-CLOCK-SET.
*> USING advance_time, paused (BINARY-LONG), rate (FLOAT-LONG): the writes of the clock manager (33 section 3.2) and the advance_time rule; every
*> player gets the Set Time that carries them (rate 0.0 while stopped, 3.8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WSIM2.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ADVANCE              BINARY-LONG.
 01 L-PAUSED               BINARY-LONG.
 01 L-RATE                 FLOAT-LONG.
 PROCEDURE DIVISION USING L-ADVANCE L-PAUSED L-RATE.
     CALL "WORLDSIM-ENSURE2"
     MOVE L-ADVANCE TO W2-ADVANCE
     MOVE L-PAUSED TO W2-PAUSED
     MOVE L-RATE TO W2-RATE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PLAY-TIME-RATE-BUILD" USING CW-TIME PB-BUFFER
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1 AND PL-ENTITY-ROW(WS-ROW) > 0
             CALL "CORE-SEND" USING PL-CONN(WS-ROW) PB-BUFFER
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM WORLDSIM-CLOCK-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-CLOCK-STEP.
*> No parameters: ServerClockManager.tick for the overworld clock (33 section 3.2): partial += rate, n = floor(partial), the time of day moves by n and wraps at
*> RULE-DAY-LENGTH; nothing moves with advance_time false or a paused clock. Called by WORLD-TIME-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY WSIM2.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-PART                FLOAT-LONG.
 LINKAGE SECTION.
 PROCEDURE DIVISION.
     CALL "WORLDSIM-ENSURE2"
     MOVE CW-TIME TO WS-TOTAL
     CALL "WC-CLOCK" USING W2-PARTIAL W2-RATE WS-TOTAL W2-ADVANCE W2-PAUSED WS-PART
     MOVE WS-PART TO W2-PARTIAL
     COMPUTE CW-TIME = FUNCTION MOD(WS-TOTAL, RULE-DAY-LENGTH)
     GOBACK.
 END PROGRAM WORLDSIM-CLOCK-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAY-TIME-RATE-BUILD.
*> USING time of day (BINARY-DOUBLE), PB-BUFFER: PLAY-TIME-BUILD with the clock's real rate and partial tick (Set Time 3.8): the rate on the wire is 0.0
*> when the clock is paused or advance_time is false.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY WSIM2.
 01 WS-PACKET-ID           BINARY-LONG VALUE 115.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-PARTIAL             FLOAT-SHORT.
 01 WS-RATE                FLOAT-SHORT.
 01 WS-WIRE                FLOAT-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TIME                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-TIME PB-BUFFER.
     CALL "WORLDSIM-ENSURE2"
     CALL "WC-SET-TIME-RATE" USING W2-PAUSED W2-ADVANCE W2-RATE WS-WIRE
     MOVE WS-WIRE TO WS-RATE
     MOVE W2-PARTIAL TO WS-PARTIAL
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-LONG" USING PB-BUFFER L-TIME
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ONE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-VARLONG" USING PB-BUFFER L-TIME
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-PARTIAL
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-RATE
     GOBACK.
 END PROGRAM PLAY-TIME-RATE-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-DARKEN.
*> USING dimension row, skyDarken out (BINARY-LONG): 33 section 3.5 for the overworld clock: the sky light level is 15 by day and 4 from clock tick 12523 to
*> 23477 (the plateau and the dusk and dawn ticks the section derives), then the weather layers of 3.6 (WC-WEATHER-SKY with the level's rain and thunder
*> levels) and (int)(15 - L) (WC-SKY-DARKEN).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-L                   FLOAT-LONG.
 01 WS-RAIN                FLOAT-LONG.
 01 WS-THUNDER             FLOAT-LONG.
 01 WS-OUT                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-DARKEN               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-DARKEN.
     MOVE 15.0 TO WS-L
     IF CW-TIME >= 12523 AND CW-TIME <= 23477
         MOVE 4.0 TO WS-L
     END-IF
     MOVE CW-RAIN-LEVEL(L-DIM) TO WS-RAIN
     MOVE CW-THUNDER-LEVEL(L-DIM) TO WS-THUNDER
     CALL "WC-WEATHER-SKY" USING WS-L WS-RAIN WS-THUNDER WS-OUT
     CALL "WC-SKY-DARKEN" USING WS-OUT L-DARKEN
     GOBACK.
 END PROGRAM WORLDSIM-DARKEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-BED-KEY.
*> USING block state, bed out (BINARY-LONG): 1 when the block's key ends in "_bed" (beds and the straw bed family of 33 section 5.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-BED                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-BED.
     MOVE 0 TO L-BED
     MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
     MOVE CB-KEY-LENGTH(WS-BLOCK + 1) TO WS-LENGTH
     IF WS-LENGTH > 4
         COMPUTE WS-LENGTH = WS-LENGTH - 3
         IF CB-KEY(WS-BLOCK + 1)(WS-LENGTH:4) = "_bed"
             MOVE 1 TO L-BED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WORLDSIM-BED-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-SLEEP-USE.
*> USING connection id, bed x, y, z (BINARY-LONG): AbstractBedBlock.useWithoutItem and ServerPlayer.startSleepInBed (33 sections 5.1, 5.2) for a bed of the
*> overworld rule `sleep when dark`: not already sleeping, the range test of WS-RANGE (the clicked position stands for both halves), the cell above free
*> (no collision), no monster check (this core has no monster-in-box rule), then WS-START decides; success sets the player sleeping with a counter of 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY WSIM2.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DARKEN              BINARY-LONG.
 01 WS-DARK                BINARY-LONG.
 01 WS-BRIGHT              BINARY-LONG.
 01 WS-EFFECTIVE           BINARY-LONG.
 01 WS-RULE                BINARY-LONG VALUE 1.
 01 WS-CAN-SLEEP           BINARY-LONG.
 01 WS-CAN-SPAWN           BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-WITHIN              BINARY-LONG.
 01 WS-ABOVE-Y             BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-BUSY                BINARY-LONG.
 01 WS-CREATIVE            BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-NO2                 BINARY-LONG VALUE 0.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-FIXED               BINARY-LONG VALUE 0.
 01 WS-SKY                 BINARY-LONG VALUE 15.
 01 WS-RESULT              BINARY-LONG.
 01 WS-SET-SPAWN           BINARY-LONG.
 01 WS-OVERLAY             BINARY-LONG.
 01 WS-UPDATE              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-X L-Y L-Z.
     CALL "WORLDSIM-ENSURE2"
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     CALL "WORLDSIM-DARKEN" USING PL-DIM(WS-ROW) WS-DARKEN
     CALL "WC-OUTSIDE" USING WS-FIXED WS-DARKEN WS-SKY WS-BRIGHT WS-DARK WS-EFFECTIVE
     CALL "WS-RULE-TEST" USING WS-RULE WS-DARK WS-CAN-SLEEP
     MOVE EN-X(PL-ENTITY-ROW(WS-ROW)) TO WS-X
     MOVE EN-Y(PL-ENTITY-ROW(WS-ROW)) TO WS-Y
     MOVE EN-Z(PL-ENTITY-ROW(WS-ROW)) TO WS-Z
     MOVE L-X TO WS-OX
     MOVE L-Y TO WS-OY
     MOVE L-Z TO WS-OZ
     CALL "WS-RANGE" USING WS-X WS-Y WS-Z L-X L-Y L-Z WS-OX WS-OY WS-OZ WS-WITHIN
     COMPUTE WS-ABOVE-Y = L-Y + 1
     CALL "WORLD-GET-BLOCK" USING PL-DIM(WS-ROW) L-X WS-ABOVE-Y L-Z WS-STATE
     MOVE 1 TO WS-FREE
     IF WS-STATE NOT = 0
         IF CB-SOLID(CB-S-BLOCK(WS-STATE + 1) + 1) = 1
             MOVE 0 TO WS-FREE
         END-IF
     END-IF
     MOVE W2-SLEEPING(WS-ROW) TO WS-BUSY
     MOVE 0 TO WS-CREATIVE
     IF PL-MODE(WS-ROW) = 1
         MOVE 1 TO WS-CREATIVE
     END-IF
     CALL "WS-START" USING WS-BUSY WS-CAN-SLEEP WS-CAN-SPAWN WS-WITHIN WS-FREE WS-CREATIVE WS-NO WS-NO2 W2-SLEEP-PCT
         WS-RESULT WS-SET-SPAWN WS-OVERLAY WS-UPDATE
     IF WS-RESULT = 0
         MOVE 1 TO W2-SLEEPING(WS-ROW)
         MOVE 0 TO W2-SLEEP-COUNTER(WS-ROW)
     END-IF
     GOBACK.
 END PROGRAM WORLDSIM-SLEEP-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-SLEEP-TICK.
*> No parameters: the sleep check of 33 section 2.1 step 3 for the overworld, every tick: each sleeping player's counter moves (WS-COUNTER; a player wakes when
*> the bed rule no longer allows sleeping, i.e. it is no longer dark); with enough sleeping and enough sleeping long enough (WS-ENOUGH) the clock moves to the
*> next tick 0 of the day (WC-MARKER, marker `wake_up_from_sleep` = tick 0, period 24000) when advance_time is on, every sleeper wakes and a rain or thunder
*> state resets (WW-SET, the clear time left alone); Set Time is sent to everybody. A player is active unless it is a spectator (mode 3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WSIM2.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DARKEN              BINARY-LONG.
 01 WS-DARK                BINARY-LONG.
 01 WS-BRIGHT              BINARY-LONG.
 01 WS-EFFECTIVE           BINARY-LONG.
 01 WS-FIXED               BINARY-LONG VALUE 0.
 01 WS-SKY                 BINARY-LONG VALUE 15.
 01 WS-REFUSED             BINARY-LONG.
 01 WS-WAKE                BINARY-LONG.
 01 WS-LONG                BINARY-LONG.
 01 WS-ACTIVE              BINARY-LONG.
 01 WS-SLEEPING            BINARY-LONG.
 01 WS-DEEP                BINARY-LONG.
 01 WS-ENOUGH              BINARY-LONG.
 01 WS-ENOUGH-DEEP         BINARY-LONG.
 01 WS-SKIP                BINARY-LONG.
 01 WS-THROUGH             BINARY-LONG.
 01 WS-CLOCK-MOVES         BINARY-LONG VALUE 1.
 01 WS-MOVE                BINARY-LONG.
 01 WS-WAKE-ALL            BINARY-LONG.
 01 WS-RESET               BINARY-LONG.
 01 WS-RAINING             BINARY-LONG.
 01 WS-MARKER-TICKS        BINARY-LONG VALUE 0.
 01 WS-PERIOD              BINARY-LONG VALUE 24000.
 01 WS-OCCURS              BINARY-LONG.
 01 WS-RESOLVED            BINARY-DOUBLE.
 01 WS-NEW-CLEAR           BINARY-LONG.
 01 WS-NEW-RAIN-T          BINARY-LONG.
 01 WS-NEW-THUNDER-T       BINARY-LONG.
 01 WS-NEW-RAINING         BINARY-LONG.
 01 WS-NEW-THUNDERING      BINARY-LONG.
 01 WS-RAIN-IN             BINARY-LONG.
 01 WS-THUNDER-IN          BINARY-LONG.
 01 WS-CLEAR-IN            BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 PROCEDURE DIVISION.
     CALL "WORLDSIM-ENSURE2"
     CALL "WORLDSIM-DARKEN" USING WS-ONE WS-DARKEN
     CALL "WC-OUTSIDE" USING WS-FIXED WS-DARKEN WS-SKY WS-BRIGHT WS-DARK WS-EFFECTIVE
     COMPUTE WS-REFUSED = 1 - WS-DARK
     MOVE 0 TO WS-ACTIVE WS-SLEEPING WS-DEEP
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1 AND PL-ENTITY-ROW(WS-ROW) > 0 AND PL-DIM(WS-ROW) = 1
             IF PL-MODE(WS-ROW) NOT = 3
                 ADD 1 TO WS-ACTIVE
             END-IF
             IF W2-SLEEPING(WS-ROW) = 1
                 CALL "WS-COUNTER" USING W2-SLEEPING(WS-ROW) WS-REFUSED W2-SLEEP-COUNTER(WS-ROW) WS-WAKE WS-LONG
                 IF WS-WAKE = 1
                     MOVE 0 TO W2-SLEEPING(WS-ROW) W2-SLEEP-COUNTER(WS-ROW)
                 ELSE
                     ADD 1 TO WS-SLEEPING
                     ADD WS-LONG TO WS-DEEP
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-SLEEPING = 0
         GOBACK
     END-IF
     CALL "WS-ENOUGH" USING WS-SLEEPING WS-ACTIVE WS-DEEP W2-SLEEP-PCT WS-ENOUGH WS-ENOUGH-DEEP WS-SKIP WS-THROUGH
     IF WS-SKIP = 0
         GOBACK
     END-IF
     MOVE CW-RAINING TO WS-RAINING
     CALL "WS-NIGHT-SKIP" USING W2-ADVANCE WS-CLOCK-MOVES WS-ONE WS-RAINING WS-MOVE WS-WAKE-ALL WS-RESET
     IF WS-MOVE = 1
         CALL "WC-MARKER" USING WS-MARKER-TICKS WS-PERIOD CW-TIME WS-OCCURS WS-RESOLVED
         COMPUTE CW-TIME = FUNCTION MOD(WS-RESOLVED, WS-PERIOD)
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "PLAY-TIME-RATE-BUILD" USING CW-TIME PB-BUFFER
         PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
             IF PL-USED(WS-ROW) = 1 AND PL-ENTITY-ROW(WS-ROW) > 0
                 CALL "CORE-SEND" USING PL-CONN(WS-ROW) PB-BUFFER
             END-IF
         END-PERFORM
         CALL "PB-FREE" USING PB-BUFFER
     END-IF
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         MOVE 0 TO W2-SLEEPING(WS-ROW) W2-SLEEP-COUNTER(WS-ROW)
     END-PERFORM
     IF WS-RESET = 1
         MOVE CW-RAIN-TIME TO WS-RAIN-IN
         MOVE CW-RAINING TO WS-RAINING
         MOVE CW-THUNDERING TO WS-THUNDER-IN
         MOVE CW-CLEAR-TIME TO WS-CLEAR-IN
         CALL "WW-SET" USING WS-CLEAR-IN WS-RAIN-IN WS-RAINING WS-THUNDER-IN WS-ONE WS-NEW-CLEAR WS-NEW-RAIN-T WS-NEW-THUNDER-T
             WS-NEW-RAINING WS-NEW-THUNDERING
         MOVE WS-NEW-RAIN-T TO CW-RAIN-TIME
         MOVE WS-NEW-THUNDER-T TO CW-THUNDER-TIME
         MOVE WS-NEW-RAINING TO CW-RAINING
         MOVE WS-NEW-THUNDERING TO CW-THUNDERING
     END-IF
     GOBACK.
 END PROGRAM WORLDSIM-SLEEP-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-BORDER-SET.
*> USING dimension row, centre x, centre z, size, damage per block, safe zone (FLOAT-LONG; the row BINARY-LONG): a static extent for that level's border
*> (33 section 7.2 setSize and setCenter); a moving extent in progress is dropped.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY WSIM2.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   FLOAT-LONG.
 01 L-CZ                   FLOAT-LONG.
 01 L-SIZE                 FLOAT-LONG.
 01 L-DAMAGE               FLOAT-LONG.
 01 L-SAFE                 FLOAT-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-SIZE L-DAMAGE L-SAFE.
     CALL "WORLDSIM-ENSURE2"
     MOVE L-CX TO W2-B-CX(L-DIM)
     MOVE L-CZ TO W2-B-CZ(L-DIM)
     MOVE L-SIZE TO W2-B-SIZE(L-DIM)
     MOVE L-DAMAGE TO W2-B-DAMAGE(L-DIM)
     MOVE L-SAFE TO W2-B-SAFE(L-DIM)
     MOVE 0 TO W2-B-MOVING(L-DIM)
     GOBACK.
 END PROGRAM WORLDSIM-BORDER-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-BORDER-LERP.
*> USING dimension row, from size, to size (FLOAT-LONG), duration in ticks (BINARY-LONG): lerpSizeBetween (33 section 7.2): a static extent when the sizes
*> are equal, else a moving one that WORLDSIM-BORDER-TICK advances.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY WSIM2.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-FROM                 FLOAT-LONG.
 01 L-TO                   FLOAT-LONG.
 01 L-DURATION             BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-FROM L-TO L-DURATION.
     CALL "WORLDSIM-ENSURE2"
     MOVE L-FROM TO W2-B-SIZE(L-DIM) W2-B-FROM(L-DIM)
     MOVE L-TO TO W2-B-TO(L-DIM)
     MOVE L-DURATION TO W2-B-DURATION(L-DIM) W2-B-PROGRESS(L-DIM)
     MOVE 1 TO W2-B-MOVING(L-DIM)
     IF L-FROM = L-TO
         MOVE 0 TO W2-B-MOVING(L-DIM)
     END-IF
     GOBACK.
 END PROGRAM WORLDSIM-BORDER-LERP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-BORDER-TICK.
*> USING dimension row (BINARY-LONG): the border of one level for one tick (33 sections 7.3, 7.5): a moving extent advances (WB-MOVING) and turns static at the
*> end; every player of the level whose box (0.6 wide) is not within the bounds takes max(1, floor(-d x damage)) points (WB-DAMAGE) as damage, d being the
*> distance to the border plus the safe zone, when d is below 0 and the damage per block is above 0. The hurt window of HEALTH-DAMAGE limits how often it lands.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY WSIM2.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SIZE                FLOAT-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-STATIC              BINARY-LONG.
 01 WS-MIN-X               FLOAT-LONG.
 01 WS-MAX-X               FLOAT-LONG.
 01 WS-MIN-Z               FLOAT-LONG.
 01 WS-MAX-Z               FLOAT-LONG.
 01 WS-D1                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-D3                  FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-X-LOW               FLOAT-LONG.
 01 WS-Z-LOW               FLOAT-LONG.
 01 WS-X-HIGH              FLOAT-LONG.
 01 WS-Z-HIGH              FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-WITHIN              BINARY-LONG.
 01 WS-WITHIN-HIGH         BINARY-LONG.
 01 WS-DISTANCE            FLOAT-LONG.
 01 WS-WALL                BINARY-LONG VALUE 0.
 01 WS-PLAYER              BINARY-LONG VALUE 1.
 01 WS-WALL-DAMAGE         FLOAT-LONG.
 01 WS-DAMAGE              FLOAT-LONG.
 01 WS-POINTS              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     CALL "WORLDSIM-ENSURE2"
     IF W2-B-MOVING(L-DIM) = 1
         CALL "WB-MOVING" USING W2-B-FROM(L-DIM) W2-B-TO(L-DIM) W2-B-DURATION(L-DIM) W2-B-PROGRESS(L-DIM) WS-SIZE WS-STATUS WS-SPEED
             WS-STATIC
         MOVE WS-SIZE TO W2-B-SIZE(L-DIM)
         IF WS-STATIC = 1
             MOVE 0 TO W2-B-MOVING(L-DIM)
         END-IF
     END-IF
     CALL "WB-EXTENT" USING W2-B-CX(L-DIM) W2-B-SIZE(L-DIM) W2-B-ABSOLUTE(L-DIM) WS-MIN-X WS-MAX-X
     CALL "WB-EXTENT" USING W2-B-CZ(L-DIM) W2-B-SIZE(L-DIM) W2-B-ABSOLUTE(L-DIM) WS-MIN-Z WS-MAX-Z
     MOVE CAUSE-COMMAND TO WS-CAUSE
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1 AND PL-ENTITY-ROW(WS-ROW) > 0 AND PL-DIM(WS-ROW) = L-DIM AND PL-MODE(WS-ROW) = 0
             MOVE EN-X(PL-ENTITY-ROW(WS-ROW)) TO WS-X
             MOVE EN-Z(PL-ENTITY-ROW(WS-ROW)) TO WS-Z
             COMPUTE WS-X-LOW = WS-X - 0.3
             COMPUTE WS-Z-LOW = WS-Z - 0.3
             COMPUTE WS-X-HIGH = WS-X + 0.3 - 0.000009999999747378752
             COMPUTE WS-Z-HIGH = WS-Z + 0.3 - 0.000009999999747378752
             CALL "WB-GEOMETRY" USING WS-X-LOW WS-Z-LOW WS-ZERO WS-MIN-X WS-MAX-X WS-MIN-Z WS-MAX-Z WS-WITHIN WS-D1 WS-D2 WS-D3
             CALL "WB-GEOMETRY" USING WS-X-HIGH WS-Z-HIGH WS-ZERO WS-MIN-X WS-MAX-X WS-MIN-Z WS-MAX-Z WS-WITHIN-HIGH WS-D1 WS-D2
                 WS-D3
             IF WS-WITHIN-HIGH = 0
                 MOVE 0 TO WS-WITHIN
             END-IF
             CALL "WB-GEOMETRY" USING WS-X WS-Z WS-ZERO WS-MIN-X WS-MAX-X WS-MIN-Z WS-MAX-Z WS-POINTS WS-DISTANCE WS-D2 WS-D3
             CALL "WB-DAMAGE" USING WS-PLAYER WS-WALL WS-WITHIN WS-DISTANCE W2-B-SAFE(L-DIM) W2-B-DAMAGE(L-DIM) WS-WALL-DAMAGE WS-DAMAGE
             IF WS-DAMAGE > 0
                 MOVE WS-DAMAGE TO WS-POINTS
                 CALL "HEALTH-DAMAGE" USING WS-ROW WS-POINTS WS-CAUSE WS-NONE WS-NONE2
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WORLDSIM-BORDER-TICK.
