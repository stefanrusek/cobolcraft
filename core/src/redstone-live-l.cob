*> Live redstone, the sculk sensors and the vibration dispatch (docs/protocol/30-redstone-8 sections 2 to 5): VIB-POST posts a game event at a position (2.1: every listener within its own radius, 8 for a sensor
*> and 16 for a calibrated one, hears it at once; the section scan and the delivery queue do not apply to these listeners), the listener keeps one candidate per tick (3.4 step 1), the ticker of the owner
*> turns a candidate of an earlier tick into the vibration in flight with the travel time floor(distance) and receives it when that is over (3.4), the sensor activates (4.2): phase active, the power
*> of the strength (3.2), a tick after 30 (calibrated 10), the neighbours of the block and of the block below told, `sculk_clicking`; its tick (4.3) goes to cooldown for 10 and then back to inactive
*> (`sculk_clicking_stop`). A calibrated sensor takes only the frequency its back input shows (5). The comparator reads the last frequency while active (4.7).
*> The block entity cells (BESTATE.cpy): XI 1 last_vibration_frequency, XI 2 a vibration is in flight, XI 6 its travel time, XI 7 a candidate is held, XI 12 its frequency, XI 13 the frequency in flight, XF 1
*> the distance of the vibration in flight, XF 2 the candidate's distance, BE-SEED the candidate's game tick.
*> Not done: the tags (`vibrations` as the listenable events, `dampens_vibrations`, `occludes_vibration_signals`: occlusion of 3.6), sneaking and spectators (3.5 step 2), the resonance of 4.2 step 4,
*> the step-on activation, the vibration particle, the waterlogged and removal rules, the shrieker; only the events this core posts exist: the note block play (10), a block placed or destroyed by a player
*> (13, 12) and the tripwire hook (10, 9, 10, 9).
*> Entry points:
*>   VIB-FREQUENCY USING event name (PIC X(24), as the registry names it), frequency out (3.1)
*>   VIB-POST USING dim, x, y, z (the block the event comes from), event name         the game event with no source entity
*>   SCULK-TICK-ALL                                                                    the owners' tickers, called by CORE-TICK
*>   SCULK-HOOK USING kind, dim, x, y, z, state, a, b                                  kind 7 the block tick of a sculk sensor or a calibrated sculk sensor (4.3)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIB-FREQUENCY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TABLE.
    05 FILLER PIC X(26) VALUE "step                    01".
    05 FILLER PIC X(26) VALUE "swim                    01".
    05 FILLER PIC X(26) VALUE "flap                    01".
    05 FILLER PIC X(26) VALUE "projectile_land         02".
    05 FILLER PIC X(26) VALUE "hit_ground              02".
    05 FILLER PIC X(26) VALUE "splash                  02".
    05 FILLER PIC X(26) VALUE "bounce                  02".
    05 FILLER PIC X(26) VALUE "item_interact_finish    03".
    05 FILLER PIC X(26) VALUE "projectile_shoot        03".
    05 FILLER PIC X(26) VALUE "instrument_play         03".
    05 FILLER PIC X(26) VALUE "entity_action           04".
    05 FILLER PIC X(26) VALUE "elytra_glide            04".
    05 FILLER PIC X(26) VALUE "unequip                 04".
    05 FILLER PIC X(26) VALUE "entity_dismount         05".
    05 FILLER PIC X(26) VALUE "equip                   05".
    05 FILLER PIC X(26) VALUE "entity_interact         06".
    05 FILLER PIC X(26) VALUE "shear                   06".
    05 FILLER PIC X(26) VALUE "entity_mount            06".
    05 FILLER PIC X(26) VALUE "entity_damage           07".
    05 FILLER PIC X(26) VALUE "drink                   08".
    05 FILLER PIC X(26) VALUE "eat                     08".
    05 FILLER PIC X(26) VALUE "container_close         09".
    05 FILLER PIC X(26) VALUE "block_close             09".
    05 FILLER PIC X(26) VALUE "block_deactivate        09".
    05 FILLER PIC X(26) VALUE "block_detach            09".
    05 FILLER PIC X(26) VALUE "container_open          10".
    05 FILLER PIC X(26) VALUE "block_open              10".
    05 FILLER PIC X(26) VALUE "block_activate          10".
    05 FILLER PIC X(26) VALUE "block_attach            10".
    05 FILLER PIC X(26) VALUE "prime_fuse              10".
    05 FILLER PIC X(26) VALUE "note_block_play         10".
    05 FILLER PIC X(26) VALUE "block_change            11".
    05 FILLER PIC X(26) VALUE "block_destroy           12".
    05 FILLER PIC X(26) VALUE "fluid_pickup            12".
    05 FILLER PIC X(26) VALUE "block_place             13".
    05 FILLER PIC X(26) VALUE "fluid_place             13".
    05 FILLER PIC X(26) VALUE "entity_place            14".
    05 FILLER PIC X(26) VALUE "lightning_strike        14".
    05 FILLER PIC X(26) VALUE "teleport                14".
    05 FILLER PIC X(26) VALUE "entity_die              15".
    05 FILLER PIC X(26) VALUE "explode                 15".
 01 WS-ROWS REDEFINES WS-TABLE.
    05 WS-ROW OCCURS 41 TIMES.
       10 WS-NAME          PIC X(24).
       10 WS-FREQ          PIC 99.
 01 WS-I                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-EVENT                PIC X(24).
 01 L-FREQUENCY            BINARY-LONG.
 PROCEDURE DIVISION USING L-EVENT L-FREQUENCY.
     MOVE 0 TO L-FREQUENCY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 41
         IF WS-NAME(WS-I) = L-EVENT
             MOVE WS-FREQ(WS-I) TO L-FREQUENCY
         END-IF
     END-PERFORM
*>   resonate_n (1 to 15) is frequency n
     IF L-FREQUENCY = 0 AND L-EVENT(1:9) = "resonate_"
         COMPUTE L-FREQUENCY = FUNCTION NUMVAL(L-EVENT(10:2))
     END-IF
     GOBACK.
 END PROGRAM VIB-FREQUENCY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VIB-POST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BESTATE.
 COPY CBLOCKS.
 01 WS-PHASE-NAME          PIC X(32) VALUE "sculk_sensor_phase".
 01 WS-KEEP                PIC X(16) VALUE "keep".
 01 WS-FREQ                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-OLD                 PIC X(16).
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-RADIUS              BINARY-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-CALIBRATED          BINARY-LONG.
 01 WS-FACING              BINARY-LONG.
 01 WS-OPP                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STEPX               BINARY-LONG.
 01 WS-STEPY               BINARY-LONG.
 01 WS-STEPZ               BINARY-LONG.
 01 WS-BACK                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-REPLACE             BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-EVENT                PIC X(24).
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-EVENT.
     CALL "VIB-FREQUENCY" USING L-EVENT WS-FREQ
     IF WS-FREQ = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BE-MAX
         IF BE-USED(WS-I) = 1 AND BE-DIM(WS-I) = L-DIM AND (BE-TYPE(WS-I) = 34 OR BE-TYPE(WS-I) = 35)
             MOVE 0 TO WS-CALIBRATED
             MOVE 8 TO WS-RADIUS
             IF BE-TYPE(WS-I) = 35
                 MOVE 1 TO WS-CALIBRATED
                 MOVE 16 TO WS-RADIUS
             END-IF
             COMPUTE WS-DX = L-X - BE-X(WS-I)
             COMPUTE WS-DY = L-Y - BE-Y(WS-I)
             COMPUTE WS-DZ = L-Z - BE-Z(WS-I)
             COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
             IF WS-D2 <= WS-RADIUS * WS-RADIUS AND BE-XI(WS-I, 2) = 0
                 CALL "WORLD-GET-BLOCK" USING L-DIM BE-X(WS-I) BE-Y(WS-I) BE-Z(WS-I) WS-STATE
                 CALL "SW-SET-PROP-L" USING WS-STATE WS-PHASE-NAME WS-KEEP WS-NEW WS-OLD
                 MOVE 1 TO WS-OK
*>               canReceiveVibration (4.5, 5): inactive only; a calibrated sensor takes only the frequency its back input shows
                 IF WS-OLD NOT = "inactive"
                     MOVE 0 TO WS-OK
                 END-IF
                 IF WS-CALIBRATED = 1 AND WS-OK = 1
                     CALL "PST-FACING-OF" USING WS-STATE WS-FACING
                     COMPUTE WS-OPP = WS-FACING + 1 - 2 * FUNCTION MOD(WS-FACING, 2)
                     CALL "BU-DIRECTION" USING WS-OPP WS-STEPX WS-STEPY WS-STEPZ
                     COMPUTE WS-BX = BE-X(WS-I) + WS-STEPX
                     COMPUTE WS-BY = BE-Y(WS-I) + WS-STEPY
                     COMPUTE WS-BZ = BE-Z(WS-I) + WS-STEPZ
                     CALL "RL-SIGNAL" USING L-DIM WS-BX WS-BY WS-BZ WS-OPP WS-BACK
                     IF WS-BACK NOT = 0 AND WS-BACK NOT = WS-FREQ
                         MOVE 0 TO WS-OK
                     END-IF
                 END-IF
                 IF WS-OK = 1
*>                   the selector (3.4 step 1): the first candidate of a tick stays unless a nearer one comes the same tick (or an equal one with a greater frequency)
                     COMPUTE WS-DIST = FUNCTION SQRT(WS-D2)
                     MOVE 0 TO WS-REPLACE
                     IF BE-XI(WS-I, 7) = 0
                         MOVE 1 TO WS-REPLACE
                     END-IF
                     IF BE-XI(WS-I, 7) = 1 AND BE-SEED(WS-I) = CW-TICKS
                         IF WS-DIST < BE-XF(WS-I, 2)
                             MOVE 1 TO WS-REPLACE
                         END-IF
                         IF WS-DIST = BE-XF(WS-I, 2) AND WS-FREQ > BE-XI(WS-I, 12)
                             MOVE 1 TO WS-REPLACE
                         END-IF
                     END-IF
                     IF WS-REPLACE = 1
                         MOVE 1 TO BE-XI(WS-I, 7)
                         MOVE WS-FREQ TO BE-XI(WS-I, 12)
                         MOVE WS-DIST TO BE-XF(WS-I, 2)
                         MOVE CW-TICKS TO BE-SEED(WS-I)
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VIB-POST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCULK-ACTIVATE.
*> USING block entity index, power (strength), frequency: activate (4.2 steps 1 to 3 and 6): the phase active with the power, a tick after the active ticks, the neighbours of the block and below told, the click.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 COPY CBLOCKS.
 01 WS-PHASE-NAME          PIC X(32) VALUE "sculk_sensor_phase".
 01 WS-POWER-NAME          PIC X(16) VALUE "power".
 01 WS-WL                  PIC X(16) VALUE "waterlogged".
 01 WS-ACTIVE              PIC X(16) VALUE "active".
 01 WS-KEEP                PIC X(16) VALUE "keep".
 01 WS-STATE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-NEW2                BINARY-LONG.
 01 WS-OLD                 PIC X(16).
 01 WS-TEXT                PIC X(16).
 01 WS-DIGITS              PIC Z9.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG.
 01 WS-PRIORITY            BINARY-LONG VALUE 0.
 01 WS-BELOW               BINARY-LONG.
 01 WS-SOUND               PIC X(48) VALUE "block.sculk_sensor.clicking".
 01 WS-SALT                BINARY-LONG VALUE 9303.
 01 WS-MILLION             BINARY-LONG VALUE 1000000.
 01 WS-DRAW                BINARY-LONG.
 01 WS-PITCH               BINARY-LONG.
 01 WS-VOLUME              BINARY-LONG VALUE 1000000.
 01 WS-SOURCE-BLOCKS       BINARY-LONG VALUE 4.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-POWER                BINARY-LONG.
 01 L-FREQ                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-POWER L-FREQ.
     CALL "WORLD-GET-BLOCK" USING BE-DIM(L-INDEX) BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-STATE
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     MOVE L-FREQ TO BE-XI(L-INDEX, 1)
     MOVE WS-ACTIVE TO WS-TEXT
     CALL "SW-SET-PROP-L" USING WS-STATE WS-PHASE-NAME WS-TEXT WS-NEW WS-OLD
     MOVE L-POWER TO WS-DIGITS
     MOVE FUNCTION TRIM(WS-DIGITS) TO WS-TEXT
     CALL "SW-SET-PROP" USING WS-NEW WS-POWER-NAME WS-TEXT WS-NEW2 WS-OLD
     CALL "LEVEL-SET-BLOCK" USING BE-DIM(L-INDEX) BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-NEW2 WS-FLAGS WS-BUDGET WS-RESULT
     MOVE 30 TO WS-DELAY
     IF BE-TYPE(L-INDEX) = 35
         MOVE 10 TO WS-DELAY
     END-IF
     CALL "BT-SCHEDULE" USING BE-DIM(L-INDEX) WS-TYPE WS-BLOCK BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-DELAY WS-PRIORITY WS-RESULT
     CALL "BU-NEIGHBORS-AT" USING BE-DIM(L-INDEX) BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-BLOCK
     COMPUTE WS-BELOW = BE-Y(L-INDEX) - 1
     CALL "BU-NEIGHBORS-AT" USING BE-DIM(L-INDEX) BE-X(L-INDEX) WS-BELOW BE-Z(L-INDEX) WS-BLOCK
     CALL "RL-GET-BOOL" USING WS-NEW2 WS-WL WS-RESULT
     IF WS-RESULT = 0
         CALL "XP-RANDOM" USING WS-SALT WS-MILLION WS-DRAW
         COMPUTE WS-PITCH = WS-DRAW / 5 + 800000
         CALL "RL-SOUND-AT" USING BE-DIM(L-INDEX) BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-SOUND WS-SOURCE-BLOCKS WS-VOLUME WS-PITCH
     END-IF
     CALL "BE-MARK-CHUNK" USING L-INDEX
     GOBACK.
 END PROGRAM SCULK-ACTIVATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCULK-TICK-ALL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BESTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-RADIUS              BINARY-LONG.
 01 WS-STRENGTH            BINARY-LONG.
 01 WS-STEP                FLOAT-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-PHASE-NAME          PIC X(32) VALUE "sculk_sensor_phase".
 01 WS-KEEP                PIC X(16) VALUE "keep".
 01 WS-NEW                 BINARY-LONG.
 01 WS-OLD                 PIC X(16).
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BE-MAX
         IF BE-USED(WS-I) = 1 AND BE-DIM(WS-I) > 0 AND (BE-TYPE(WS-I) = 34 OR BE-TYPE(WS-I) = 35)
             IF BE-XI(WS-I, 2) = 0
*>               a candidate of an earlier tick becomes the vibration in flight (3.4 step 2)
                 IF BE-XI(WS-I, 7) = 1 AND BE-SEED(WS-I) < CW-TICKS
                     MOVE 1 TO BE-XI(WS-I, 2)
                     MOVE BE-XF(WS-I, 2) TO BE-XF(WS-I, 1)
                     MOVE BE-XI(WS-I, 12) TO BE-XI(WS-I, 13)
                     COMPUTE BE-XI(WS-I, 6) = FUNCTION INTEGER(BE-XF(WS-I, 2))
                     MOVE 0 TO BE-XI(WS-I, 7)
                 END-IF
             ELSE
*>               the travel time counts down; at 0 the owner receives it (3.4 step 3)
                 IF BE-XI(WS-I, 6) > 0
                     SUBTRACT 1 FROM BE-XI(WS-I, 6)
                 END-IF
                 IF BE-XI(WS-I, 6) <= 0
                     MOVE 8 TO WS-RADIUS
                     IF BE-TYPE(WS-I) = 35
                         MOVE 16 TO WS-RADIUS
                     END-IF
*>                   strength = max(1, 15 - floor(15 / radius x distance)) (3.2)
                     COMPUTE WS-STEP = 15 / WS-RADIUS * BE-XF(WS-I, 1)
                     COMPUTE WS-FLOOR = FUNCTION INTEGER(WS-STEP)
                     COMPUTE WS-STRENGTH = FUNCTION MAX(1, 15 - WS-FLOOR)
                     MOVE 0 TO BE-XI(WS-I, 2)
                     CALL "WORLD-GET-BLOCK" USING BE-DIM(WS-I) BE-X(WS-I) BE-Y(WS-I) BE-Z(WS-I) WS-STATE
                     CALL "SW-SET-PROP-L" USING WS-STATE WS-PHASE-NAME WS-KEEP WS-NEW WS-OLD
                     IF WS-OLD = "inactive"
                         CALL "SCULK-ACTIVATE" USING WS-I WS-STRENGTH BE-XI(WS-I, 13)
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SCULK-TICK-ALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCULK-HOOK RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-PHASE-NAME          PIC X(32) VALUE "sculk_sensor_phase".
 01 WS-POWER-NAME          PIC X(16) VALUE "power".
 01 WS-WL                  PIC X(16) VALUE "waterlogged".
 01 WS-KEEP                PIC X(16) VALUE "keep".
 01 WS-ZERO-TEXT           PIC X(16) VALUE "0".
 01 WS-COOLDOWN            PIC X(16) VALUE "cooldown".
 01 WS-INACTIVE            PIC X(16) VALUE "inactive".
 01 WS-SOUND               PIC X(48) VALUE "block.sculk_sensor.clicking_stop".
 01 WS-SALT                BINARY-LONG VALUE 9304.
 01 WS-MILLION             BINARY-LONG VALUE 1000000.
 01 WS-SOURCE-BLOCKS       BINARY-LONG VALUE 4.
 01 WS-VOLUME              BINARY-LONG VALUE 1000000.
 LOCAL-STORAGE SECTION.
 01 LS-NEW                 BINARY-LONG.
 01 LS-NEW2                BINARY-LONG.
 01 LS-OLD                 PIC X(16).
 01 LS-FLAGS               BINARY-LONG VALUE 3.
 01 LS-BUDGET              BINARY-LONG VALUE 512.
 01 LS-RESULT              BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-TYPE                BINARY-LONG VALUE 1.
 01 LS-DELAY               BINARY-LONG VALUE 10.
 01 LS-PRIORITY            BINARY-LONG VALUE 0.
 01 LS-BELOW               BINARY-LONG.
 01 LS-DRAW                BINARY-LONG.
 01 LS-PITCH               BINARY-LONG.
 01 LS-WL-ON               BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A L-B.
     MOVE CB-S-BLOCK(L-STATE + 1) TO LS-BLOCK
     IF L-KIND = 7
         CALL "SW-SET-PROP-L" USING L-STATE WS-PHASE-NAME WS-KEEP LS-NEW LS-OLD
         EVALUATE LS-OLD
             WHEN "active"
*>               deactivate (4.3): cooldown, power 0, a tick 10 ahead, the neighbours told
                 CALL "SW-SET-PROP-L" USING L-STATE WS-PHASE-NAME WS-COOLDOWN LS-NEW LS-OLD
                 CALL "SW-SET-PROP" USING LS-NEW WS-POWER-NAME WS-ZERO-TEXT LS-NEW2 LS-OLD
                 CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW2 LS-FLAGS LS-BUDGET LS-RESULT
                 CALL "BT-SCHEDULE" USING L-DIM LS-TYPE LS-BLOCK L-X L-Y L-Z LS-DELAY LS-PRIORITY LS-RESULT
                 CALL "BU-NEIGHBORS-AT" USING L-DIM L-X L-Y L-Z LS-BLOCK
                 COMPUTE LS-BELOW = L-Y - 1
                 CALL "BU-NEIGHBORS-AT" USING L-DIM L-X LS-BELOW L-Z LS-BLOCK
             WHEN "cooldown"
                 CALL "SW-SET-PROP-L" USING L-STATE WS-PHASE-NAME WS-INACTIVE LS-NEW LS-OLD
                 CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
                 CALL "RL-GET-BOOL" USING LS-NEW WS-WL LS-WL-ON
                 IF LS-WL-ON = 0
                     CALL "XP-RANDOM" USING WS-SALT WS-MILLION LS-DRAW
                     COMPUTE LS-PITCH = LS-DRAW / 5 + 800000
                     CALL "RL-SOUND-AT" USING L-DIM L-X L-Y L-Z WS-SOUND WS-SOURCE-BLOCKS WS-VOLUME LS-PITCH
                 END-IF
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM SCULK-HOOK.
