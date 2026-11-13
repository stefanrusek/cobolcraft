*> Redstone part 8 (docs/protocol/30-redstone-8-tripwire-sculk-bells-vibration.md) as programs of plain numbers (RS3- prefix), like parts 6 and 7 and the RS1- helpers: the caller reads
*> the level and passes the facts; the program returns the decision. Nothing here is wired into the block-update hooks.
*> Directions are the data values 0 down, 1 up, 2 north, 3 south, 4 west, 5 east. Booleans are 0 and 1. Sculk sensor phases: 0 inactive, 1 active, 2 cooldown.
*> Event codes of the hook: 1 block_activate, 2 block_deactivate, 3 block_attach, 4 block_detach. Distances inside a cell are thousandths of a block.

*> ===== Section 1: per-block rows

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BLOCK8-ROW.
*> USING block name, block id, first state id, state count out (section 1); zeros for another name.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-ID                   BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 01 L-STATES               BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-ID L-FIRST L-STATES.
     MOVE 0 TO L-ID L-FIRST L-STATES
     EVALUATE FUNCTION TRIM(L-NAME)
         WHEN "tripwire_hook"
             MOVE 452 TO L-ID
             MOVE 11325 TO L-FIRST
             MOVE 16 TO L-STATES
         WHEN "tripwire"
             MOVE 453 TO L-ID
             MOVE 11341 TO L-FIRST
             MOVE 128 TO L-STATES
         WHEN "sculk_sensor"
             MOVE 1118 TO L-ID
             MOVE 30520 TO L-FIRST
             MOVE 96 TO L-STATES
         WHEN "calibrated_sculk_sensor"
             MOVE 1119 TO L-ID
             MOVE 30616 TO L-FIRST
             MOVE 384 TO L-STATES
         WHEN "sculk_shrieker"
             MOVE 1123 TO L-ID
             MOVE 31131 TO L-FIRST
             MOVE 8 TO L-STATES
         WHEN "bell"
             MOVE 938 TO L-ID
             MOVE 24162 TO L-FIRST
             MOVE 32 TO L-STATES
         WHEN "tnt"
             MOVE 220 TO L-ID
             MOVE 3833 TO L-FIRST
             MOVE 2 TO L-STATES
         WHEN "big_dripleaf"
             MOVE 1235 TO L-ID
             MOVE 33713 TO L-FIRST
             MOVE 32 TO L-STATES
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-BLOCK8-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BLOCK8-DELAYS.
*> USING block name, first, second, third scheduled delay out (-1 none; -2 for another name) (section 1): hook tick 10; tripwire recheck 10 and release 1;
*> sensor active 30 and cooldown 10; calibrated 10 and 10; shrieker 90; dripleaf 10, 10, 100.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-D1                   BINARY-LONG.
 01 L-D2                   BINARY-LONG.
 01 L-D3                   BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-D1 L-D2 L-D3.
     MOVE -1 TO L-D1 L-D2 L-D3
     EVALUATE FUNCTION TRIM(L-NAME)
         WHEN "tripwire_hook"
             MOVE 10 TO L-D1
         WHEN "tripwire"
             MOVE 10 TO L-D1
             MOVE 1 TO L-D2
         WHEN "sculk_sensor"
             MOVE 30 TO L-D1
             MOVE 10 TO L-D2
         WHEN "calibrated_sculk_sensor"
             MOVE 10 TO L-D1 L-D2
         WHEN "sculk_shrieker"
             MOVE 90 TO L-D1
         WHEN "big_dripleaf"
             MOVE 10 TO L-D1 L-D2
             MOVE 100 TO L-D3
         WHEN "bell"
             MOVE -1 TO L-D1
         WHEN "tnt"
             MOVE -1 TO L-D1
         WHEN OTHER
             MOVE -2 TO L-D1 L-D2 L-D3
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-BLOCK8-DELAYS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BLOCK8-REGISTRY.
*> USING block name, no collision out, strength in tenths out, light level out (section 1 registry facts); -1 for the dripleaf (not stated), -2 for another name.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-COLLISION            BINARY-LONG.
 01 L-STRENGTH             BINARY-LONG.
 01 L-LIGHT                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-COLLISION L-STRENGTH L-LIGHT.
     MOVE 0 TO L-COLLISION L-STRENGTH L-LIGHT
     EVALUATE FUNCTION TRIM(L-NAME)
         WHEN "tripwire_hook"
             MOVE 1 TO L-COLLISION
         WHEN "tripwire"
             MOVE 1 TO L-COLLISION
         WHEN "sculk_sensor"
             MOVE 15 TO L-STRENGTH
             MOVE 1 TO L-LIGHT
         WHEN "calibrated_sculk_sensor"
             MOVE 15 TO L-STRENGTH
             MOVE 1 TO L-LIGHT
         WHEN "sculk_shrieker"
             MOVE 30 TO L-STRENGTH
         WHEN "bell"
             MOVE 50 TO L-STRENGTH
         WHEN "tnt"
             MOVE 0 TO L-STRENGTH
         WHEN "big_dripleaf"
             MOVE -1 TO L-COLLISION L-STRENGTH L-LIGHT
         WHEN OTHER
             MOVE -2 TO L-COLLISION L-STRENGTH L-LIGHT
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-BLOCK8-REGISTRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BLOCK8-SOURCE.
*> USING block name, isSignalSource out (section 1): the hook and both sensors, in every state.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-RESULT.
     MOVE 0 TO L-RESULT
     EVALUATE FUNCTION TRIM(L-NAME)
         WHEN "tripwire_hook"
             MOVE 1 TO L-RESULT
         WHEN "sculk_sensor"
             MOVE 1 TO L-RESULT
         WHEN "calibrated_sculk_sensor"
             MOVE 1 TO L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-BLOCK8-SOURCE.

*> ===== Section 2: the game-event dispatch

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SECTION-RANGE.
*> USING block coordinate, radius, low section, high section out (section 2.1 item 3): blockToSectionCoord, an arithmetic shift right by 4 (floor / 16).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COORD                BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 01 L-LO                   BINARY-LONG.
 01 L-HI                   BINARY-LONG.
 PROCEDURE DIVISION USING L-COORD L-RADIUS L-LO L-HI.
     COMPUTE L-LO = FUNCTION INTEGER((L-COORD - L-RADIUS) / 16)
     COMPUTE L-HI = FUNCTION INTEGER((L-COORD + L-RADIUS) / 16)
     GOBACK.
 END PROGRAM RS3-SECTION-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-EVENT-RADIUS.
*> USING event name, notification radius out (section 2.1): 16 except jukebox_play and jukebox_stop_play (10) and shriek (32).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-RADIUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-RADIUS.
     MOVE 16 TO L-RADIUS
     EVALUATE FUNCTION TRIM(L-NAME)
         WHEN "jukebox_play"
             MOVE 10 TO L-RADIUS
         WHEN "jukebox_stop_play"
             MOVE 10 TO L-RADIUS
         WHEN "shriek"
             MOVE 32 TO L-RADIUS
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-EVENT-RADIUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-LISTENER-IN-RANGE.
*> USING block distance dx, dy, dz, the listener radius, in range out (section 2.1 item 4): distance squared at most radius squared.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-DX L-DY L-DZ L-RADIUS L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-DX * L-DX + L-DY * L-DY + L-DZ * L-DZ <= L-RADIUS * L-RADIUS
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-LISTENER-IN-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DELIVERY.
*> USING the delivery mode is BY_DISTANCE, queued out (section 2.1 item 5): the vibration listener overrides nothing, so it is called at once.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BY-DISTANCE          BINARY-LONG.
 01 L-QUEUED               BINARY-LONG.
 PROCEDURE DIVISION USING L-BY-DISTANCE L-QUEUED.
     MOVE L-BY-DISTANCE TO L-QUEUED
     GOBACK.
 END PROGRAM RS3-DELIVERY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-LISTENER-SECTION.
*> USING block coordinate, chunk section out (section 2.2): floor(coordinate / 16).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COORD                BINARY-LONG.
 01 L-SECTION              BINARY-LONG.
 PROCEDURE DIVISION USING L-COORD L-SECTION.
     COMPUTE L-SECTION = FUNCTION INTEGER(L-COORD / 16)
     GOBACK.
 END PROGRAM RS3-LISTENER-SECTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-LISTENER-CENTER.
*> USING block coordinate, the block centre out in thousandths (section 2.2): the position of a BlockPositionSource.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COORD                BINARY-LONG.
 01 L-CENTER               BINARY-LONG.
 PROCEDURE DIVISION USING L-COORD L-CENTER.
     COMPUTE L-CENTER = L-COORD * 1000 + 500
     GOBACK.
 END PROGRAM RS3-LISTENER-CENTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-EMIT-ROW.
*> USING row (1 to 10 of section 2.3), event frequency out, source out (0 none, 1 given, 2 the igniter or none); -1 and -1 outside.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FREQ                 BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FREQ L-SOURCE.
     MOVE 0 TO L-SOURCE
     EVALUATE L-ROW
         WHEN 1
             MOVE 10 TO L-FREQ
         WHEN 2
             MOVE 9 TO L-FREQ
         WHEN 3
             MOVE 10 TO L-FREQ
         WHEN 4
             MOVE 9 TO L-FREQ
         WHEN 5
             MOVE 6 TO L-FREQ
             MOVE 1 TO L-SOURCE
         WHEN 6
             MOVE 0 TO L-FREQ
             MOVE 1 TO L-SOURCE
         WHEN 7
             MOVE 0 TO L-FREQ
             MOVE 1 TO L-SOURCE
         WHEN 8
             MOVE 11 TO L-FREQ
             MOVE 1 TO L-SOURCE
         WHEN 9
             MOVE 11 TO L-FREQ
         WHEN 10
             MOVE 10 TO L-FREQ
             MOVE 2 TO L-SOURCE
         WHEN OTHER
             MOVE -1 TO L-FREQ L-SOURCE
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-EMIT-ROW.

*> ===== Section 3: the vibration system

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-ISQRT.
*> USING x, floor of the square root out: shared integer root (exact for every perfect square).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-X                    BINARY-DOUBLE.
 01 L-R                    BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-R.
     MOVE 0 TO L-R
     PERFORM UNTIL (L-R + 1) * (L-R + 1) > L-X
         ADD 1 TO L-R
     END-PERFORM
     GOBACK.
 END PROGRAM RS3-ISQRT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-EVENT-FREQ.
*> USING game event name, frequency out (section 3.1): 0 for the five events of frequency 0 and for a name that is not an event.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
 05 FILLER PIC X(32) VALUE "step".
 05 FILLER PIC 99 VALUE 1.
 05 FILLER PIC X(32) VALUE "swim".
 05 FILLER PIC 99 VALUE 1.
 05 FILLER PIC X(32) VALUE "flap".
 05 FILLER PIC 99 VALUE 1.
 05 FILLER PIC X(32) VALUE "projectile_land".
 05 FILLER PIC 99 VALUE 2.
 05 FILLER PIC X(32) VALUE "hit_ground".
 05 FILLER PIC 99 VALUE 2.
 05 FILLER PIC X(32) VALUE "splash".
 05 FILLER PIC 99 VALUE 2.
 05 FILLER PIC X(32) VALUE "bounce".
 05 FILLER PIC 99 VALUE 2.
 05 FILLER PIC X(32) VALUE "item_interact_finish".
 05 FILLER PIC 99 VALUE 3.
 05 FILLER PIC X(32) VALUE "projectile_shoot".
 05 FILLER PIC 99 VALUE 3.
 05 FILLER PIC X(32) VALUE "instrument_play".
 05 FILLER PIC 99 VALUE 3.
 05 FILLER PIC X(32) VALUE "entity_action".
 05 FILLER PIC 99 VALUE 4.
 05 FILLER PIC X(32) VALUE "elytra_glide".
 05 FILLER PIC 99 VALUE 4.
 05 FILLER PIC X(32) VALUE "unequip".
 05 FILLER PIC 99 VALUE 4.
 05 FILLER PIC X(32) VALUE "entity_dismount".
 05 FILLER PIC 99 VALUE 5.
 05 FILLER PIC X(32) VALUE "equip".
 05 FILLER PIC 99 VALUE 5.
 05 FILLER PIC X(32) VALUE "entity_interact".
 05 FILLER PIC 99 VALUE 6.
 05 FILLER PIC X(32) VALUE "shear".
 05 FILLER PIC 99 VALUE 6.
 05 FILLER PIC X(32) VALUE "entity_mount".
 05 FILLER PIC 99 VALUE 6.
 05 FILLER PIC X(32) VALUE "entity_damage".
 05 FILLER PIC 99 VALUE 7.
 05 FILLER PIC X(32) VALUE "drink".
 05 FILLER PIC 99 VALUE 8.
 05 FILLER PIC X(32) VALUE "eat".
 05 FILLER PIC 99 VALUE 8.
 05 FILLER PIC X(32) VALUE "container_close".
 05 FILLER PIC 99 VALUE 9.
 05 FILLER PIC X(32) VALUE "block_close".
 05 FILLER PIC 99 VALUE 9.
 05 FILLER PIC X(32) VALUE "block_deactivate".
 05 FILLER PIC 99 VALUE 9.
 05 FILLER PIC X(32) VALUE "block_detach".
 05 FILLER PIC 99 VALUE 9.
 05 FILLER PIC X(32) VALUE "container_open".
 05 FILLER PIC 99 VALUE 10.
 05 FILLER PIC X(32) VALUE "block_open".
 05 FILLER PIC 99 VALUE 10.
 05 FILLER PIC X(32) VALUE "block_activate".
 05 FILLER PIC 99 VALUE 10.
 05 FILLER PIC X(32) VALUE "block_attach".
 05 FILLER PIC 99 VALUE 10.
 05 FILLER PIC X(32) VALUE "prime_fuse".
 05 FILLER PIC 99 VALUE 10.
 05 FILLER PIC X(32) VALUE "note_block_play".
 05 FILLER PIC 99 VALUE 10.
 05 FILLER PIC X(32) VALUE "block_change".
 05 FILLER PIC 99 VALUE 11.
 05 FILLER PIC X(32) VALUE "block_destroy".
 05 FILLER PIC 99 VALUE 12.
 05 FILLER PIC X(32) VALUE "fluid_pickup".
 05 FILLER PIC 99 VALUE 12.
 05 FILLER PIC X(32) VALUE "block_place".
 05 FILLER PIC 99 VALUE 13.
 05 FILLER PIC X(32) VALUE "fluid_place".
 05 FILLER PIC 99 VALUE 13.
 05 FILLER PIC X(32) VALUE "entity_place".
 05 FILLER PIC 99 VALUE 14.
 05 FILLER PIC X(32) VALUE "lightning_strike".
 05 FILLER PIC 99 VALUE 14.
 05 FILLER PIC X(32) VALUE "teleport".
 05 FILLER PIC 99 VALUE 14.
 05 FILLER PIC X(32) VALUE "entity_die".
 05 FILLER PIC 99 VALUE 15.
 05 FILLER PIC X(32) VALUE "explode".
 05 FILLER PIC 99 VALUE 15.
 05 FILLER PIC X(32) VALUE "resonate_1".
 05 FILLER PIC 99 VALUE 1.
 05 FILLER PIC X(32) VALUE "resonate_2".
 05 FILLER PIC 99 VALUE 2.
 05 FILLER PIC X(32) VALUE "resonate_3".
 05 FILLER PIC 99 VALUE 3.
 05 FILLER PIC X(32) VALUE "resonate_4".
 05 FILLER PIC 99 VALUE 4.
 05 FILLER PIC X(32) VALUE "resonate_5".
 05 FILLER PIC 99 VALUE 5.
 05 FILLER PIC X(32) VALUE "resonate_6".
 05 FILLER PIC 99 VALUE 6.
 05 FILLER PIC X(32) VALUE "resonate_7".
 05 FILLER PIC 99 VALUE 7.
 05 FILLER PIC X(32) VALUE "resonate_8".
 05 FILLER PIC 99 VALUE 8.
 05 FILLER PIC X(32) VALUE "resonate_9".
 05 FILLER PIC 99 VALUE 9.
 05 FILLER PIC X(32) VALUE "resonate_10".
 05 FILLER PIC 99 VALUE 10.
 05 FILLER PIC X(32) VALUE "resonate_11".
 05 FILLER PIC 99 VALUE 11.
 05 FILLER PIC X(32) VALUE "resonate_12".
 05 FILLER PIC 99 VALUE 12.
 05 FILLER PIC X(32) VALUE "resonate_13".
 05 FILLER PIC 99 VALUE 13.
 05 FILLER PIC X(32) VALUE "resonate_14".
 05 FILLER PIC 99 VALUE 14.
 05 FILLER PIC X(32) VALUE "resonate_15".
 05 FILLER PIC 99 VALUE 15.
 05 FILLER PIC X(32) VALUE "item_interact_start".
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "jukebox_play".
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "jukebox_stop_play".
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "sculk_sensor_tendrils_clicking".
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "shriek".
 05 FILLER PIC 99 VALUE 0.
 01 WS-TABLE REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 61 TIMES.
       10 WS-RNAME         PIC X(32).
       10 WS-RFREQ         PIC 99.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-FREQ                 BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-FREQ.
     MOVE 0 TO L-FREQ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 61
         IF FUNCTION TRIM(L-NAME) = FUNCTION TRIM(WS-RNAME(WS-I))
             MOVE WS-RFREQ(WS-I) TO L-FREQ
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RS3-EVENT-FREQ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-EVENT-COUNTS.
*> USING events, events with a non-zero frequency, listed events, resonance events, events of frequency 0 out (section 3.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TOTAL                BINARY-LONG.
 01 L-NONZERO              BINARY-LONG.
 01 L-LISTED               BINARY-LONG.
 01 L-RESONANCE            BINARY-LONG.
 01 L-ZERO                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TOTAL L-NONZERO L-LISTED L-RESONANCE L-ZERO.
     MOVE 41 TO L-LISTED
     MOVE 15 TO L-RESONANCE
     MOVE 5 TO L-ZERO
     COMPUTE L-NONZERO = L-LISTED + L-RESONANCE
     COMPUTE L-TOTAL = L-NONZERO + L-ZERO
     GOBACK.
 END PROGRAM RS3-EVENT-COUNTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-RESONANCE-INDEX.
*> USING frequency, index in the list of 15 resonance events out (section 3.1): f - 1, or -1 outside 1 to 15.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FREQ                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-FREQ L-INDEX.
     MOVE -1 TO L-INDEX
     IF L-FREQ >= 1 AND L-FREQ <= 15
         COMPUTE L-INDEX = L-FREQ - 1
     END-IF
     GOBACK.
 END PROGRAM RS3-RESONANCE-INDEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-STRENGTH.
*> USING listener radius, block distance squared, strength out (section 3.2): max(1, 15 - floor((15 / radius) * distance)); the floor of the root of
*> 225 * d2 / radius2 is computed in integers, so the band edges are exact.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Q                   BINARY-DOUBLE.
 01 WS-F                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-RADIUS               BINARY-LONG.
 01 L-DSQ                  BINARY-LONG.
 01 L-STRENGTH             BINARY-LONG.
 PROCEDURE DIVISION USING L-RADIUS L-DSQ L-STRENGTH.
     COMPUTE WS-Q = 225 * L-DSQ / (L-RADIUS * L-RADIUS)
     CALL "RS3-ISQRT" USING WS-Q WS-F
     COMPUTE L-STRENGTH = 15 - WS-F
     IF L-STRENGTH < 1
         MOVE 1 TO L-STRENGTH
     END-IF
     GOBACK.
 END PROGRAM RS3-STRENGTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-STRENGTH-MILLI.
*> USING listener radius, distance in thousandths of a block, strength out (section 3.2 band boundaries).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-RADIUS               BINARY-LONG.
 01 L-DIST                 BINARY-LONG.
 01 L-STRENGTH             BINARY-LONG.
 PROCEDURE DIVISION USING L-RADIUS L-DIST L-STRENGTH.
     COMPUTE WS-F = 15 * L-DIST / (L-RADIUS * 1000)
     COMPUTE L-STRENGTH = 15 - WS-F
     IF L-STRENGTH < 1
         MOVE 1 TO L-STRENGTH
     END-IF
     GOBACK.
 END PROGRAM RS3-STRENGTH-MILLI.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TRAVEL-TIME.
*> USING the distance per axis in thousandths of a block, travel time out (section 3.2): floor of the distance in ticks.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   BINARY-DOUBLE.
 01 WS-Y                   BINARY-DOUBLE.
 01 WS-Z                   BINARY-DOUBLE.
 01 WS-S                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-DX L-DY L-DZ L-TICKS.
     MOVE L-DX TO WS-X
     MOVE L-DY TO WS-Y
     MOVE L-DZ TO WS-Z
     COMPUTE WS-S = (WS-X * WS-X + WS-Y * WS-Y + WS-Z * WS-Z) / 1000000
     CALL "RS3-ISQRT" USING WS-S L-TICKS
     GOBACK.
 END PROGRAM RS3-TRAVEL-TIME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-V-HANDLE.
*> USING a vibration in flight, valid vibration, listener position known, canReceiveVibration, occluded, accepted out, failing step out
*> (section 3.3): the first failing step returns; step 0 when a candidate is added.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLIGHT               BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-KNOWN                BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-OCCLUDED             BINARY-LONG.
 01 L-ACCEPTED             BINARY-LONG.
 01 L-STEP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FLIGHT L-VALID L-KNOWN L-CAN L-OCCLUDED L-ACCEPTED L-STEP.
     MOVE 0 TO L-ACCEPTED L-STEP
     EVALUATE TRUE
         WHEN L-FLIGHT = 1
             MOVE 1 TO L-STEP
         WHEN L-VALID = 0
             MOVE 2 TO L-STEP
         WHEN L-KNOWN = 0
             MOVE 3 TO L-STEP
         WHEN L-CAN = 0
             MOVE 4 TO L-STEP
         WHEN L-OCCLUDED = 1
             MOVE 5 TO L-STEP
         WHEN OTHER
             MOVE 1 TO L-ACCEPTED
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-V-HANDLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SELECT-REPLACE.
*> USING a candidate is kept, it is from the same tick, new distance, kept distance, new frequency, kept frequency, replace out (section 3.4 item 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEPT                 BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 01 L-NEW-D                BINARY-LONG.
 01 L-KEPT-D               BINARY-LONG.
 01 L-NEW-F                BINARY-LONG.
 01 L-KEPT-F               BINARY-LONG.
 01 L-REPLACE              BINARY-LONG.
 PROCEDURE DIVISION USING L-KEPT L-SAME L-NEW-D L-KEPT-D L-NEW-F L-KEPT-F L-REPLACE.
     MOVE 0 TO L-REPLACE
     EVALUATE TRUE
         WHEN L-KEPT = 0
             MOVE 1 TO L-REPLACE
         WHEN L-SAME = 1 AND L-NEW-D < L-KEPT-D
             MOVE 1 TO L-REPLACE
         WHEN L-SAME = 1 AND L-NEW-D = L-KEPT-D AND L-NEW-F > L-KEPT-F
             MOVE 1 TO L-REPLACE
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-SELECT-REPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TICK-CHOOSE.
*> USING a candidate exists, its tick, the current game time, a vibration in flight, choose out (section 3.4 item 2): strictly earlier.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAS                  BINARY-LONG.
 01 L-CAND                 BINARY-LONG.
 01 L-NOW                  BINARY-LONG.
 01 L-FLIGHT               BINARY-LONG.
 01 L-CHOOSE               BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS L-CAND L-NOW L-FLIGHT L-CHOOSE.
     MOVE 0 TO L-CHOOSE
     IF L-HAS = 1 AND L-CAND < L-NOW AND L-FLIGHT = 0
         MOVE 1 TO L-CHOOSE
     END-IF
     GOBACK.
 END PROGRAM RS3-TICK-CHOOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TRAVEL-DEC.
*> USING travel time, the travel time minus 1 out, not below 0 (section 3.4 item 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TRAVEL               BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TRAVEL L-NEW.
     COMPUTE L-NEW = L-TRAVEL - 1
     IF L-NEW < 0
         MOVE 0 TO L-NEW
     END-IF
     GOBACK.
 END PROGRAM RS3-TRAVEL-DEC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-RECEIVE.
*> USING the travel time after the decrement, the 3 by 3 chunks are loaded and ticking, received out, waits out (section 3.4 item 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TRAVEL               BINARY-LONG.
 01 L-LOADED               BINARY-LONG.
 01 L-RECEIVED             BINARY-LONG.
 01 L-WAITS                BINARY-LONG.
 PROCEDURE DIVISION USING L-TRAVEL L-LOADED L-RECEIVED L-WAITS.
     MOVE 0 TO L-RECEIVED L-WAITS
     IF L-TRAVEL <= 0
         IF L-LOADED = 1
             MOVE 1 TO L-RECEIVED
         ELSE
             MOVE 1 TO L-WAITS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS3-RECEIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-NOTIFY-TICK.
*> USING the tick T of the event, travel time n, the tick the owner is told out (section 3.4 timing): T + max(n, 1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TICK                 BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-TOLD                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TICK L-N L-TOLD.
     COMPUTE L-TOLD = L-TICK + 1
     IF L-N > 1
         COMPUTE L-TOLD = L-TICK + L-N
     END-IF
     GOBACK.
 END PROGRAM RS3-NOTIFY-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-VALID.
*> USING listenable, the context has a source entity, it is a spectator, it is stepping carefully, the event is in ignore_vibrations_sneaking, the user can
*> trigger avoid_vibration, it is a server player, it dampens vibrations, the context has a block state, that state dampens, then valid out, advancement out
*> (section 3.5, first match returns).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LISTENABLE           BINARY-LONG.
 01 L-HAS-SOURCE           BINARY-LONG.
 01 L-SPECTATOR            BINARY-LONG.
 01 L-CAREFUL              BINARY-LONG.
 01 L-IGNORED              BINARY-LONG.
 01 L-CAN-AVOID            BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-DAMPENS              BINARY-LONG.
 01 L-HAS-BLOCK            BINARY-LONG.
 01 L-BLOCK-DAMPENS        BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-ADVANCEMENT          BINARY-LONG.
 PROCEDURE DIVISION USING L-LISTENABLE L-HAS-SOURCE L-SPECTATOR L-CAREFUL L-IGNORED L-CAN-AVOID L-PLAYER L-DAMPENS L-HAS-BLOCK
         L-BLOCK-DAMPENS L-VALID L-ADVANCEMENT.
     MOVE 0 TO L-VALID L-ADVANCEMENT
     EVALUATE TRUE
         WHEN L-LISTENABLE = 0
             MOVE 0 TO L-VALID
         WHEN L-HAS-SOURCE = 1 AND L-SPECTATOR = 1
             MOVE 0 TO L-VALID
         WHEN L-HAS-SOURCE = 1 AND L-CAREFUL = 1 AND L-IGNORED = 1
             IF L-CAN-AVOID = 1 AND L-PLAYER = 1
                 MOVE 1 TO L-ADVANCEMENT
             END-IF
         WHEN L-HAS-SOURCE = 1 AND L-DAMPENS = 1
             MOVE 0 TO L-VALID
         WHEN L-HAS-BLOCK = 1 AND L-BLOCK-DAMPENS = 1
             MOVE 0 TO L-VALID
         WHEN OTHER
             MOVE 1 TO L-VALID
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-STEPPING-CAREFULLY.
*> USING the shift key is down, a cat or ocelot, isCrouching, result out (section 3.5): a cat or ocelot is also careful when crouching.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SHIFT                BINARY-LONG.
 01 L-FELINE               BINARY-LONG.
 01 L-CROUCHING            BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SHIFT L-FELINE L-CROUCHING L-RESULT.
     MOVE L-SHIFT TO L-RESULT
     IF L-FELINE = 1 AND L-CROUCHING = 1
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-STEPPING-CAREFULLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DAMPENS.
*> USING the warden, an item entity, its stack is in the item tag dampens_vibrations, dampensVibrations out (section 3.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WARDEN               BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-IN-TAG               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-WARDEN L-ITEM L-IN-TAG L-RESULT.
     MOVE L-WARDEN TO L-RESULT
     IF L-ITEM = 1 AND L-IN-TAG = 1
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-DAMPENS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-OCCLUDED.
*> USING the six ray results (1 meets an occluder), occluded out (section 3.6): only when all six rays are blocked.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-R1                   BINARY-LONG.
 01 L-R2                   BINARY-LONG.
 01 L-R3                   BINARY-LONG.
 01 L-R4                   BINARY-LONG.
 01 L-R5                   BINARY-LONG.
 01 L-R6                   BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-R1 L-R2 L-R3 L-R4 L-R5 L-R6 L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-R1 + L-R2 + L-R3 + L-R4 + L-R5 + L-R6 = 6
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-OCCLUDED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SNAP-CENTER.
*> USING a coordinate in thousandths, the block centre out (section 3.6): floor(coordinate) + 0.5.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COORD                BINARY-LONG.
 01 L-CENTER               BINARY-LONG.
 PROCEDURE DIVISION USING L-COORD L-CENTER.
     COMPUTE L-CENTER = FUNCTION INTEGER(L-COORD / 1000) * 1000 + 500
     GOBACK.
 END PROGRAM RS3-SNAP-CENTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-OCC-CONST.
*> USING the ray start offset out in nanoblocks (section 3.6): 0.00001.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OFFSET               BINARY-LONG.
 PROCEDURE DIVISION USING L-OFFSET.
     MOVE 10000 TO L-OFFSET
     GOBACK.
 END PROGRAM RS3-OCC-CONST.

*> ===== Section 4: sculk sensor block

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-PHASE-ORDINAL.
*> USING serialized phase name, ordinal out (section 4.1): -1 for another name.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-ORD                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-ORD.
     EVALUATE FUNCTION TRIM(L-NAME)
         WHEN "inactive"
             MOVE 0 TO L-ORD
         WHEN "active"
             MOVE 1 TO L-ORD
         WHEN "cooldown"
             MOVE 2 TO L-ORD
         WHEN OTHER
             MOVE -1 TO L-ORD
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-PHASE-ORDINAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-PHASE-CAN-ACTIVATE.
*> USING phase, canActivate out (section 4.1): true only in inactive.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PHASE                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-PHASE L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-PHASE = 0
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-PHASE-CAN-ACTIVATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SENSOR-ACTIVATE.
*> USING calibrated, waterlogged, new phase out (1 active), tick delay out, neighbours told out (the position and the one below), tendrils-clicking
*> event out, sculk_clicking sound out (section 4.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CALIBRATED           BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-PHASE                BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-NEIGHBOURS           BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-CALIBRATED L-WATERLOGGED L-PHASE L-DELAY L-NEIGHBOURS L-EVENT L-SOUND.
     MOVE 1 TO L-PHASE L-NEIGHBOURS L-EVENT
     MOVE 30 TO L-DELAY
     IF L-CALIBRATED = 1
         MOVE 10 TO L-DELAY
     END-IF
     COMPUTE L-SOUND = 1 - L-WATERLOGGED
     GOBACK.
 END PROGRAM RS3-SENSOR-ACTIVATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-RESONANCE-NOTE.
*> USING frequency 1 to 15, note out, pitch 2 ** ((note - 12) / 12) out in millionths (section 4.2 step 4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NOTES               PIC X(32) VALUE "00000204060709101214151819212224".
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-FREQ                 BINARY-LONG.
 01 L-NOTE                 BINARY-LONG.
 01 L-PITCH                BINARY-LONG.
 PROCEDURE DIVISION USING L-FREQ L-NOTE L-PITCH.
     COMPUTE WS-P = L-FREQ * 2 + 1
     MOVE WS-NOTES(WS-P:2) TO L-NOTE
     COMPUTE L-PITCH ROUNDED = (2 ** ((L-NOTE - 12) / 12)) * 1000000
     GOBACK.
 END PROGRAM RS3-RESONANCE-NOTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-CLICK-PITCH.
*> USING nextFloat draw (a double), pitch out in millionths (sections 4.2, 4.3): draw * 0.2 + 0.8.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-PITCH                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-PITCH.
     COMPUTE L-PITCH ROUNDED = (L-DRAW * 0.2 + 0.8) * 1000000
     GOBACK.
 END PROGRAM RS3-CLICK-PITCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SENSOR-TICK.
*> USING phase, waterlogged, new phase out, next tick delay out (-1 none), neighbours told out, sculk_clicking_stop out (section 4.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PHASE                BINARY-LONG.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-NEIGHBOURS           BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-PHASE L-WATERLOGGED L-NEW L-DELAY L-NEIGHBOURS L-SOUND.
     MOVE 0 TO L-NEW L-NEIGHBOURS L-SOUND
     MOVE -1 TO L-DELAY
     EVALUATE L-PHASE
         WHEN 1
             MOVE 2 TO L-NEW
             MOVE 10 TO L-DELAY
             MOVE 1 TO L-NEIGHBOURS
         WHEN 2
             COMPUTE L-SOUND = 1 - L-WATERLOGGED
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-SENSOR-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SENSOR-DEAF.
*> USING calibrated, deaf ticks out (section 4.3): the active ticks plus the cooldown of 10.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CALIBRATED           BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-CALIBRATED L-TICKS.
     MOVE 40 TO L-TICKS
     IF L-CALIBRATED = 1
         MOVE 20 TO L-TICKS
     END-IF
     GOBACK.
 END PROGRAM RS3-SENSOR-DEAF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SENSOR-WATER.
*> USING waterlogged, the fluid state is water out, a water tick is scheduled by updateShape out (section 4.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WATERLOGGED          BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-TICK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-WATERLOGGED L-FLUID L-TICK.
     MOVE L-WATERLOGGED TO L-FLUID L-TICK
     GOBACK.
 END PROGRAM RS3-SENSOR-WATER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SENSOR-ON-PLACE.
*> USING server level, the old block is this block, power, a tick is scheduled, clear power out, flags out (18) (section 4.4 onPlace).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-OLD                  BINARY-LONG.
 01 L-POWER                BINARY-LONG.
 01 L-SCHEDULED            BINARY-LONG.
 01 L-CLEAR                BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-OLD L-POWER L-SCHEDULED L-CLEAR L-FLAGS.
     MOVE 0 TO L-CLEAR L-FLAGS
     IF L-SERVER = 1 AND L-OLD = 0 AND L-POWER > 0 AND L-SCHEDULED = 0
         MOVE 1 TO L-CLEAR
         MOVE 18 TO L-FLAGS
     END-IF
     GOBACK.
 END PROGRAM RS3-SENSOR-ON-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SENSOR-REMOVED.
*> USING the removed phase, neighbours told out (section 4.4 affectNeighborsAfterRemoval): when it was active.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PHASE                BINARY-LONG.
 01 L-TOLD                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PHASE L-TOLD.
     MOVE 0 TO L-TOLD
     IF L-PHASE = 1
         MOVE 1 TO L-TOLD
     END-IF
     GOBACK.
 END PROGRAM RS3-SENSOR-REMOVED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SENSOR-STEP-ON.
*> USING server, canActivate, the entity is a warden, a block entity exists, canReceiveVibration holds, forceScheduleVibration out, step frequency out
*> (section 4.4 stepOn): it bypasses the tag, sneaking, occlusion and in-flight checks.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-WARDEN               BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-RECEIVE              BINARY-LONG.
 01 L-FORCES               BINARY-LONG.
 01 L-FREQ                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-CAN L-WARDEN L-ENTITY L-RECEIVE L-FORCES L-FREQ.
     MOVE 0 TO L-FORCES
     MOVE 1 TO L-FREQ
     IF L-SERVER = 1 AND L-CAN = 1 AND L-WARDEN = 0 AND L-ENTITY = 1 AND L-RECEIVE = 1
         MOVE 1 TO L-FORCES
     END-IF
     GOBACK.
 END PROGRAM RS3-SENSOR-STEP-ON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SENSOR-XP.
*> USING experience dropped out (section 4.4): a constant 5.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-XP                   BINARY-LONG.
 PROCEDURE DIVISION USING L-XP.
     MOVE 5 TO L-XP
     GOBACK.
 END PROGRAM RS3-SENSOR-XP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SENSOR-CAN-RECEIVE.
*> USING the position is the sensor's own block, the event is block_destroy or block_place, frequency, canActivate, result out (section 4.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SELF                 BINARY-LONG.
 01 L-DESTROY              BINARY-LONG.
 01 L-FREQ                 BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SELF L-DESTROY L-FREQ L-CAN L-RESULT.
     MOVE L-CAN TO L-RESULT
     IF L-SELF = 1 AND L-DESTROY = 1
         MOVE 0 TO L-RESULT
     END-IF
     IF L-FREQ = 0
         MOVE 0 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-SENSOR-CAN-RECEIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SENSOR-RECEIVE.
*> USING canActivate, the event frequency, block distance squared, listener radius, activates out, last_vibration_frequency stored out, strength out
*> (section 4.5 onReceiveVibration).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CAN                  BINARY-LONG.
 01 L-FREQ                 BINARY-LONG.
 01 L-DSQ                  BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 01 L-ACTIVATES            BINARY-LONG.
 01 L-STORED               BINARY-LONG.
 01 L-STRENGTH             BINARY-LONG.
 PROCEDURE DIVISION USING L-CAN L-FREQ L-DSQ L-RADIUS L-ACTIVATES L-STORED L-STRENGTH.
     MOVE 0 TO L-ACTIVATES L-STORED L-STRENGTH
     IF L-CAN = 1
         MOVE 1 TO L-ACTIVATES
         MOVE L-FREQ TO L-STORED
         CALL "RS3-STRENGTH" USING L-RADIUS L-DSQ L-STRENGTH
     END-IF
     GOBACK.
 END PROGRAM RS3-SENSOR-RECEIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SENSOR-SIGNAL.
*> USING power, direction, query (0 getSignal, 1 getDirectSignal), signal out (section 4.6): weak power every way, strong power only UP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWER                BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-QUERY                BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-POWER L-DIR L-QUERY L-SIGNAL.
     MOVE 0 TO L-SIGNAL
     IF L-QUERY = 0 OR L-DIR = 1
         MOVE L-POWER TO L-SIGNAL
     END-IF
     GOBACK.
 END PROGRAM RS3-SENSOR-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SENSOR-ANALOG.
*> USING phase, a block entity exists, last_vibration_frequency, comparator signal out (section 4.7): the frequency while active.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PHASE                BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-FREQ                 BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-PHASE L-ENTITY L-FREQ L-SIGNAL.
     MOVE 0 TO L-SIGNAL
     IF L-PHASE = 1 AND L-ENTITY = 1
         MOVE L-FREQ TO L-SIGNAL
     END-IF
     GOBACK.
 END PROGRAM RS3-SENSOR-ANALOG.

*> ===== Section 5: calibrated sculk sensor

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SENSOR-CONST.
*> USING calibrated, listener radius out, active ticks out, cooldown out (sections 4.5, 5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CALIBRATED           BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 01 L-ACTIVE               BINARY-LONG.
 01 L-COOLDOWN             BINARY-LONG.
 PROCEDURE DIVISION USING L-CALIBRATED L-RADIUS L-ACTIVE L-COOLDOWN.
     MOVE 8 TO L-RADIUS
     MOVE 30 TO L-ACTIVE
     MOVE 10 TO L-COOLDOWN
     IF L-CALIBRATED = 1
         MOVE 16 TO L-RADIUS
         MOVE 10 TO L-ACTIVE
     END-IF
     GOBACK.
 END PROGRAM RS3-SENSOR-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-CAL-BACK.
*> USING facing, the direction of the back input out (section 5): opp(facing).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-BACK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-BACK.
     COMPUTE L-BACK = L-FACING + 1 - 2 * FUNCTION MOD(L-FACING, 2)
     GOBACK.
 END PROGRAM RS3-CAL-BACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-CAL-CAN-RECEIVE.
*> USING the back signal, the event frequency, the plain sensor rule of 4.5, result out (section 5): back 0 accepts every frequency, back n only n.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BACK                 BINARY-LONG.
 01 L-FREQ                 BINARY-LONG.
 01 L-PLAIN                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-BACK L-FREQ L-PLAIN L-RESULT.
     MOVE L-PLAIN TO L-RESULT
     IF L-BACK NOT = 0 AND L-FREQ NOT = L-BACK
         MOVE 0 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-CAL-CAN-RECEIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-CAL-SIGNAL.
*> USING power, facing, direction, query (0 getSignal, 1 getDirectSignal), signal out (section 5): 0 toward facing, else as the plain sensor.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWER                BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-QUERY                BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-POWER L-FACING L-DIR L-QUERY L-SIGNAL.
     CALL "RS3-SENSOR-SIGNAL" USING L-POWER L-DIR L-QUERY L-SIGNAL
     IF L-QUERY = 0 AND L-DIR = L-FACING
         MOVE 0 TO L-SIGNAL
     END-IF
     GOBACK.
 END PROGRAM RS3-CAL-SIGNAL.

*> ===== Section 6: sculk shrieker

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SHRIEKER-CAN-RECEIVE.
*> USING shrieking, the plain rule, result out (section 6.2): not while shrieking.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SHRIEKING            BINARY-LONG.
 01 L-PLAIN                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SHRIEKING L-PLAIN L-RESULT.
     MOVE L-PLAIN TO L-RESULT
     IF L-SHRIEKING = 1
         MOVE 0 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-SHRIEKER-CAN-RECEIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TRY-PLAYER.
*> USING the entity is a server player, the controlling passenger of its vehicle is a player, the owner of a projectile is, the owner of an item entity is,
*> which out (0 none, 1 itself, 2 the passenger, 3 the projectile owner, 4 the item owner) (section 6.2 tryGetPlayer).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SELF                 BINARY-LONG.
 01 L-PASSENGER            BINARY-LONG.
 01 L-PROJECTILE           BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-WHICH                BINARY-LONG.
 PROCEDURE DIVISION USING L-SELF L-PASSENGER L-PROJECTILE L-ITEM L-WHICH.
     MOVE 0 TO L-WHICH
     EVALUATE TRUE
         WHEN L-SELF = 1
             MOVE 1 TO L-WHICH
         WHEN L-PASSENGER = 1
             MOVE 2 TO L-WHICH
         WHEN L-PROJECTILE = 1
             MOVE 3 TO L-WHICH
         WHEN L-ITEM = 1
             MOVE 4 TO L-WHICH
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-TRY-PLAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-REACTION-PLAYER.
*> USING a projectile owner is given, the player of the reaction out (1 the source entity, 2 the projectile owner) (section 6.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OWNER                BINARY-LONG.
 01 L-WHICH                BINARY-LONG.
 PROCEDURE DIVISION USING L-OWNER L-WHICH.
     COMPUTE L-WHICH = 1 + L-OWNER
     GOBACK.
 END PROGRAM RS3-REACTION-PLAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SHRIEKER-STEP-ON.
*> USING server, tryGetPlayer found a player, a block entity exists, shrieks now out (section 6.2 stepOn).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-SHRIEKS              BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-PLAYER L-ENTITY L-SHRIEKS.
     MOVE 0 TO L-SHRIEKS
     IF L-SERVER = 1 AND L-PLAYER = 1 AND L-ENTITY = 1
         MOVE 1 TO L-SHRIEKS
     END-IF
     GOBACK.
 END PROGRAM RS3-SHRIEKER-STEP-ON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-CAN-RESPOND.
*> USING can_summon, the difficulty is peaceful, the game rule spawn_wardens, canRespond out (section 6.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SUMMON               BINARY-LONG.
 01 L-PEACEFUL             BINARY-LONG.
 01 L-RULE                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-SUMMON L-PEACEFUL L-RULE L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-SUMMON = 1 AND L-PEACEFUL = 0 AND L-RULE = 1
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-CAN-RESPOND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TRY-SHRIEK.
*> USING a player, shrieking, can_summon, peaceful, the spawn_wardens rule, the warden-spawn tracker warns, shrieks out, warning_level reset out
*> (section 6.3): the tracker is asked only when canRespond; a refusal stops without shrieking.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CAN                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-SHRIEKING            BINARY-LONG.
 01 L-SUMMON               BINARY-LONG.
 01 L-PEACEFUL             BINARY-LONG.
 01 L-RULE                 BINARY-LONG.
 01 L-WARNS                BINARY-LONG.
 01 L-SHRIEKS              BINARY-LONG.
 01 L-RESET                BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-SHRIEKING L-SUMMON L-PEACEFUL L-RULE L-WARNS L-SHRIEKS L-RESET.
     MOVE 0 TO L-SHRIEKS L-RESET
     IF L-PLAYER = 1 AND L-SHRIEKING = 0
         MOVE 1 TO L-RESET
         MOVE 1 TO L-SHRIEKS
         CALL "RS3-CAN-RESPOND" USING L-SUMMON L-PEACEFUL L-RULE WS-CAN
         IF WS-CAN = 1 AND L-WARNS = 0
             MOVE 0 TO L-SHRIEKS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS3-TRY-SHRIEK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SHRIEK-EFFECT.
*> USING block tick delay out, level event out, event frequency out (shriek), flags out (section 6.3 step 4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DELAY                BINARY-LONG.
 01 L-LEVEL-EVENT          BINARY-LONG.
 01 L-FREQ                 BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-DELAY L-LEVEL-EVENT L-FREQ L-FLAGS.
     MOVE 90 TO L-DELAY
     MOVE 3007 TO L-LEVEL-EVENT
     MOVE 0 TO L-FREQ
     MOVE 2 TO L-FLAGS
     GOBACK.
 END PROGRAM RS3-SHRIEK-EFFECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SHRIEKER-TICK.
*> USING shrieking, new shrieking out (false), tryRespond runs out (section 6.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SHRIEKING            BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-RESPONDS             BINARY-LONG.
 PROCEDURE DIVISION USING L-SHRIEKING L-NEW L-RESPONDS.
     MOVE 0 TO L-NEW
     MOVE L-SHRIEKING TO L-RESPONDS
     GOBACK.
 END PROGRAM RS3-SHRIEKER-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-RESPOND.
*> USING canRespond, warning_level, the warning level for the sound, a warden spawned, summon attempted out (level at least 4), reply sound out (1 to 4),
*> darkness out (section 6.4 tryRespond).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CAN                  BINARY-LONG.
 01 L-WARNING              BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 01 L-SPAWNED              BINARY-LONG.
 01 L-TRIED                BINARY-LONG.
 01 L-REPLY                BINARY-LONG.
 01 L-DARKNESS             BINARY-LONG.
 PROCEDURE DIVISION USING L-CAN L-WARNING L-LEVEL L-SPAWNED L-TRIED L-REPLY L-DARKNESS.
     MOVE 0 TO L-TRIED L-REPLY L-DARKNESS
     IF L-CAN = 1 AND L-WARNING > 0
         MOVE 1 TO L-DARKNESS
         IF L-LEVEL >= 4
             MOVE 1 TO L-TRIED
         END-IF
         IF L-SPAWNED = 0 AND L-LEVEL >= 1 AND L-LEVEL <= 4
             MOVE L-LEVEL TO L-REPLY
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS3-RESPOND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SHRIEKER-BREAK.
*> USING shrieking, tryRespond runs once before removal out (section 6.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SHRIEKING            BINARY-LONG.
 01 L-RUNS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SHRIEKING L-RUNS.
     MOVE L-SHRIEKING TO L-RUNS
     GOBACK.
 END PROGRAM RS3-SHRIEKER-BREAK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SHRIEKER-CONST.
*> USING states, listener radius, experience, SpawnUtil arguments a b c, reply offset, reply volume, darkness radius out (sections 6.1, 6.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STATES               BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 01 L-XP                   BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-OFFSET               BINARY-LONG.
 01 L-VOLUME               BINARY-LONG.
 01 L-DARKNESS             BINARY-LONG.
 PROCEDURE DIVISION USING L-STATES L-RADIUS L-XP L-A L-B L-C L-OFFSET L-VOLUME L-DARKNESS.
     MOVE 8 TO L-STATES L-RADIUS
     MOVE 5 TO L-XP L-B L-VOLUME
     MOVE 20 TO L-A
     MOVE 6 TO L-C
     MOVE 10 TO L-OFFSET
     MOVE 40 TO L-DARKNESS
     GOBACK.
 END PROGRAM RS3-SHRIEKER-CONST.

*> ===== Section 7: tripwire and tripwire hook

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-HOOK-SHAPE.
*> USING facing, min x, max x, min y, max y, min z, max z out in pixels (section 7.1): boxZ(6, 0, 10, 10, 16) on the support side, the block at pos - facing.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-MINX                 BINARY-LONG.
 01 L-MAXX                 BINARY-LONG.
 01 L-MINY                 BINARY-LONG.
 01 L-MAXY                 BINARY-LONG.
 01 L-MINZ                 BINARY-LONG.
 01 L-MAXZ                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-MINX L-MAXX L-MINY L-MAXY L-MINZ L-MAXZ.
     MOVE 5 TO L-MINX L-MINZ
     MOVE 11 TO L-MAXX L-MAXZ
     MOVE 0 TO L-MINY
     MOVE 10 TO L-MAXY
     EVALUATE L-FACING
         WHEN 2
             MOVE 10 TO L-MINZ
             MOVE 16 TO L-MAXZ
         WHEN 3
             MOVE 0 TO L-MINZ
             MOVE 6 TO L-MAXZ
         WHEN 5
             MOVE 0 TO L-MINX
             MOVE 6 TO L-MAXX
         WHEN 4
             MOVE 10 TO L-MINX
             MOVE 16 TO L-MAXX
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-HOOK-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-HOOK-PLACE.
*> USING four horizontal directions in the placer's nearest-looking order, each with whether facing = opp(d) survives, facing out (-1 not placeable)
*> (section 7.1 placement).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D1                   BINARY-LONG.
 01 L-OK1                  BINARY-LONG.
 01 L-D2                   BINARY-LONG.
 01 L-OK2                  BINARY-LONG.
 01 L-D3                   BINARY-LONG.
 01 L-OK3                  BINARY-LONG.
 01 L-D4                   BINARY-LONG.
 01 L-OK4                  BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 PROCEDURE DIVISION USING L-D1 L-OK1 L-D2 L-OK2 L-D3 L-OK3 L-D4 L-OK4 L-FACING.
     MOVE -1 TO L-FACING
     EVALUATE TRUE
         WHEN L-OK1 = 1
             COMPUTE L-FACING = L-D1 + 1 - 2 * FUNCTION MOD(L-D1, 2)
         WHEN L-OK2 = 1
             COMPUTE L-FACING = L-D2 + 1 - 2 * FUNCTION MOD(L-D2, 2)
         WHEN L-OK3 = 1
             COMPUTE L-FACING = L-D3 + 1 - 2 * FUNCTION MOD(L-D3, 2)
         WHEN L-OK4 = 1
             COMPUTE L-FACING = L-D4 + 1 - 2 * FUNCTION MOD(L-D4, 2)
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-HOOK-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-HOOK-UPDATE-SHAPE.
*> USING facing, direction of the change, the hook can survive, becomes air out (section 7.1 updateShape).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-SURVIVES             BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-DIR L-SURVIVES L-AIR.
     MOVE 0 TO L-AIR
     IF L-DIR = L-FACING + 1 - 2 * FUNCTION MOD(L-FACING, 2) AND L-SURVIVES = 0
         MOVE 1 TO L-AIR
     END-IF
     GOBACK.
 END PROGRAM RS3-HOOK-UPDATE-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-WIRE-SHAPE.
*> USING attached, min y, max y out in tenths of a pixel (section 7.1): column(16, 1, 2.5) when attached, column(16, 0, 8) when not.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ATTACHED             BINARY-LONG.
 01 L-MINY                 BINARY-LONG.
 01 L-MAXY                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ATTACHED L-MINY L-MAXY.
     MOVE 0 TO L-MINY
     MOVE 80 TO L-MAXY
     IF L-ATTACHED = 1
         MOVE 10 TO L-MINY
         MOVE 25 TO L-MAXY
     END-IF
     GOBACK.
 END PROGRAM RS3-WIRE-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-WIRE-SIDE.
*> USING the neighbour (0 other, 1 hook, 2 wire), the hook's facing, the direction of the side, side out (section 7.1): a hook facing the wire or a wire.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-SIDE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-FACING L-DIR L-SIDE.
     MOVE 0 TO L-SIDE
     IF L-KIND = 2
         MOVE 1 TO L-SIDE
     END-IF
     IF L-KIND = 1 AND L-FACING = L-DIR + 1 - 2 * FUNCTION MOD(L-DIR, 2)
         MOVE 1 TO L-SIDE
     END-IF
     GOBACK.
 END PROGRAM RS3-WIRE-SIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-WIRE-ROTATE.
*> USING the north, east, south, west sides, rotation (0 none, 1 CW 90, 2 180, 3 CCW 90), the four sides out (section 7.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-ON                   BINARY-LONG.
 01 L-OE                   BINARY-LONG.
 01 L-OS                   BINARY-LONG.
 01 L-OW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-E L-S L-W L-ROT L-ON L-OE L-OS L-OW.
     MOVE L-N TO L-ON
     MOVE L-E TO L-OE
     MOVE L-S TO L-OS
     MOVE L-W TO L-OW
     EVALUATE L-ROT
         WHEN 1
             MOVE L-W TO L-ON
             MOVE L-N TO L-OE
             MOVE L-E TO L-OS
             MOVE L-S TO L-OW
         WHEN 2
             MOVE L-S TO L-ON
             MOVE L-W TO L-OE
             MOVE L-N TO L-OS
             MOVE L-E TO L-OW
         WHEN 3
             MOVE L-E TO L-ON
             MOVE L-S TO L-OE
             MOVE L-W TO L-OS
             MOVE L-N TO L-OW
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-WIRE-ROTATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-WIRE-MIRROR.
*> USING the north, east, south, west sides, mirror (0 none, 1 left-right swaps north and south, 2 front-back swaps east and west), the sides out.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-MIRROR               BINARY-LONG.
 01 L-ON                   BINARY-LONG.
 01 L-OE                   BINARY-LONG.
 01 L-OS                   BINARY-LONG.
 01 L-OW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-E L-S L-W L-MIRROR L-ON L-OE L-OS L-OW.
     MOVE L-N TO L-ON
     MOVE L-E TO L-OE
     MOVE L-S TO L-OS
     MOVE L-W TO L-OW
     IF L-MIRROR = 1
         MOVE L-S TO L-ON
         MOVE L-N TO L-OS
     END-IF
     IF L-MIRROR = 2
         MOVE L-W TO L-OE
         MOVE L-E TO L-OW
     END-IF
     GOBACK.
 END PROGRAM RS3-WIRE-MIRROR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-HOOK-SIGNAL.
*> USING powered, facing, direction, query (0 getSignal, 1 getDirectSignal), signal out (section 7.2): weak 15 every way while powered, strong 15 only toward facing.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWERED              BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-QUERY                BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-POWERED L-FACING L-DIR L-QUERY L-SIGNAL.
     MOVE 0 TO L-SIGNAL
     IF L-POWERED = 1 AND (L-QUERY = 0 OR L-DIR = L-FACING)
         MOVE 15 TO L-SIGNAL
     END-IF
     GOBACK.
 END PROGRAM RS3-HOOK-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-HOOK-CALC.
*> USING a readable facing, removing, the changed cell distance c (-1 none), the assumed wire disarmed, powered, the stored attached, powered, then three tables of
*> 64 for the cells k = 1 to 41 (kind 0 other, 1 wire, 2 hook facing back, 3 hook facing elsewhere; disarmed; powered), ran out, attached out, powered out,
*> D out, tick scheduled for the hook out (section 7.3 scan and result flags). A gap clears attached and the scan goes on.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-DIS                 BINARY-LONG.
 01 WS-PW                  BINARY-LONG.
 01 WS-ATT                 BINARY-LONG.
 01 WS-ANY                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-VALID                BINARY-LONG.
 01 L-REMOVING             BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-WDIS                 BINARY-LONG.
 01 L-WPOW                 BINARY-LONG.
 01 L-WAS-A                BINARY-LONG.
 01 L-WAS-P                BINARY-LONG.
 01 L-KDG.
    05 L-KD                BINARY-LONG OCCURS 64 TIMES.
 01 L-DSG.
    05 L-DS                BINARY-LONG OCCURS 64 TIMES.
 01 L-PWG.
    05 L-PW                BINARY-LONG OCCURS 64 TIMES.
 01 L-RAN                  BINARY-LONG.
 01 L-ATTACHED             BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-D                    BINARY-LONG.
 01 L-SCHEDULE             BINARY-LONG.
 PROCEDURE DIVISION USING L-VALID L-REMOVING L-C L-WDIS L-WPOW L-WAS-A L-WAS-P L-KDG L-DSG L-PWG L-RAN L-ATTACHED L-POWERED L-D
         L-SCHEDULE.
     MOVE 0 TO L-RAN L-D L-SCHEDULE WS-DONE WS-ANY
     MOVE L-WAS-A TO L-ATTACHED
     MOVE L-WAS-P TO L-POWERED
     IF L-VALID = 1
         MOVE 1 TO L-RAN
         COMPUTE WS-ATT = 1 - L-REMOVING
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 41 OR WS-DONE = 1
             MOVE L-KD(WS-K) TO WS-KIND
             MOVE L-DS(WS-K) TO WS-DIS
             MOVE L-PW(WS-K) TO WS-PW
             EVALUATE TRUE
                 WHEN WS-KIND = 2
                     MOVE WS-K TO L-D
                     MOVE 1 TO WS-DONE
                 WHEN WS-KIND = 3
                     MOVE 0 TO L-D
                     MOVE 1 TO WS-DONE
                 WHEN WS-KIND = 1 OR WS-K = L-C
                     IF WS-K = L-C
                         MOVE L-WDIS TO WS-DIS
                         MOVE L-WPOW TO WS-PW
                         MOVE 1 TO L-SCHEDULE
                         IF WS-DIS = 1
                             MOVE 0 TO WS-ATT
                         END-IF
                     END-IF
                     IF WS-DIS = 0 AND WS-PW = 1
                         MOVE 1 TO WS-ANY
                     END-IF
                 WHEN OTHER
                     MOVE 0 TO WS-ATT
             END-EVALUATE
         END-PERFORM
         MOVE 0 TO L-ATTACHED L-POWERED
         IF WS-ATT = 1 AND L-D > 1
             MOVE 1 TO L-ATTACHED
             MOVE WS-ANY TO L-POWERED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS3-HOOK-CALC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-HOOK-WRITES.
*> USING D, removing, notify, attached, was attached, write the far hook out, notify the far hook out, write the near hook out, notify the near hook out,
*> wires rewritten out (section 7.3 writes 1 to 4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D                    BINARY-LONG.
 01 L-REMOVING             BINARY-LONG.
 01 L-NOTIFY               BINARY-LONG.
 01 L-ATTACHED             BINARY-LONG.
 01 L-WAS-A                BINARY-LONG.
 01 L-WRITE-FAR            BINARY-LONG.
 01 L-NOTIFY-FAR           BINARY-LONG.
 01 L-WRITE-NEAR           BINARY-LONG.
 01 L-NOTIFY-NEAR          BINARY-LONG.
 01 L-CELLS                BINARY-LONG.
 PROCEDURE DIVISION USING L-D L-REMOVING L-NOTIFY L-ATTACHED L-WAS-A L-WRITE-FAR L-NOTIFY-FAR L-WRITE-NEAR L-NOTIFY-NEAR L-CELLS.
     MOVE 0 TO L-WRITE-FAR L-NOTIFY-FAR L-WRITE-NEAR L-NOTIFY-NEAR L-CELLS
     IF L-D > 0
         MOVE 1 TO L-WRITE-FAR L-NOTIFY-FAR
     END-IF
     IF L-REMOVING = 0
         MOVE 1 TO L-WRITE-NEAR
         MOVE L-NOTIFY TO L-NOTIFY-NEAR
     END-IF
     IF L-ATTACHED NOT = L-WAS-A AND L-D > 1
         COMPUTE L-CELLS = L-D - 1
     END-IF
     GOBACK.
 END PROGRAM RS3-HOOK-WRITES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-HOOK-EMIT.
*> USING attached, powered, was attached, was powered, kind out (0 none, 1 click on, 2 click off, 3 attach, 4 detach), pitch out in millionths (0 for the detach
*> pitch, RS3-DETACH-PITCH), event out (block_activate 1, block_deactivate 2, block_attach 3, block_detach 4), volume out (0.4) (section 7.4, first match).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ATTACHED             BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-WAS-A                BINARY-LONG.
 01 L-WAS-P                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-PITCH                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 01 L-VOLUME               BINARY-LONG.
 PROCEDURE DIVISION USING L-ATTACHED L-POWERED L-WAS-A L-WAS-P L-KIND L-PITCH L-EVENT L-VOLUME.
     MOVE 0 TO L-KIND L-PITCH L-EVENT L-VOLUME
     EVALUATE TRUE
         WHEN L-POWERED = 1 AND L-WAS-P = 0
             MOVE 1 TO L-KIND L-EVENT
             MOVE 600000 TO L-PITCH
         WHEN L-POWERED = 0 AND L-WAS-P = 1
             MOVE 2 TO L-KIND L-EVENT
             MOVE 500000 TO L-PITCH
         WHEN L-ATTACHED = 1 AND L-WAS-A = 0
             MOVE 3 TO L-KIND L-EVENT
             MOVE 700000 TO L-PITCH
         WHEN L-ATTACHED = 0 AND L-WAS-A = 1
             MOVE 4 TO L-KIND L-EVENT
     END-EVALUATE
     IF L-KIND > 0
         MOVE 400000 TO L-VOLUME
     END-IF
     GOBACK.
 END PROGRAM RS3-HOOK-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DETACH-PITCH.
*> USING nextFloat draw (a double), pitch out in millionths (section 7.4): 1.2 / (draw * 0.2 + 0.9).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-PITCH                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-PITCH.
     COMPUTE L-PITCH ROUNDED = 1.2 / (L-DRAW * 0.2 + 0.9) * 1000000
     GOBACK.
 END PROGRAM RS3-DETACH-PITCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-WIRE-INSIDE.
*> USING server, powered, a tick is scheduled at the position, checkPressed runs out (section 7.5 entityInside).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-SCHEDULED            BINARY-LONG.
 01 L-RUNS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-POWERED L-SCHEDULED L-RUNS.
     MOVE 0 TO L-RUNS
     IF L-SERVER = 1 AND L-POWERED = 0 AND L-SCHEDULED = 0
         MOVE 1 TO L-RUNS
     END-IF
     GOBACK.
 END PROGRAM RS3-WIRE-INSIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-WIRE-CHECK.
*> USING pressed, powered, write out, powered out, updateSource out, next tick delay out (section 7.5 checkPressed): 10 when pressed, 1 when it was powered.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PRESSED              BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-WRITE                BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-PRESSED L-POWERED L-WRITE L-NEW L-SOURCE L-DELAY.
     MOVE 0 TO L-WRITE L-SOURCE L-DELAY
     MOVE L-PRESSED TO L-NEW
     IF L-PRESSED NOT = L-POWERED
         MOVE 1 TO L-WRITE L-SOURCE
     END-IF
     IF L-PRESSED = 1
         MOVE 10 TO L-DELAY
     END-IF
     IF L-PRESSED = 0 AND L-POWERED = 1
         MOVE 1 TO L-DELAY
     END-IF
     GOBACK.
 END PROGRAM RS3-WIRE-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-WIRE-TICK.
*> USING powered, the entities are gathered and checkPressed runs out (section 7.5 scheduled tick).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POWERED              BINARY-LONG.
 01 L-GATHERS              BINARY-LONG.
 PROCEDURE DIVISION USING L-POWERED L-GATHERS.
     MOVE L-POWERED TO L-GATHERS
     GOBACK.
 END PROGRAM RS3-WIRE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-IGNORES-TRIGGERS.
*> USING entity type name, marker flag, isIgnoringBlockTriggers out (section 7.5): Display, Interaction, Marker, OminousItemSpawner, Bat and a marker ArmorStand.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-MARKER               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-MARKER L-RESULT.
     MOVE 0 TO L-RESULT
     EVALUATE FUNCTION TRIM(L-NAME)
         WHEN "display"
             MOVE 1 TO L-RESULT
         WHEN "interaction"
             MOVE 1 TO L-RESULT
         WHEN "marker"
             MOVE 1 TO L-RESULT
         WHEN "ominous_item_spawner"
             MOVE 1 TO L-RESULT
         WHEN "bat"
             MOVE 1 TO L-RESULT
         WHEN "armor_stand"
             MOVE L-MARKER TO L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-IGNORES-TRIGGERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-WIRE-PRESSED.
*> USING entities in the list that do not ignore block triggers, pressed out (section 7.5 checkPressed).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-PRESSED              BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT L-PRESSED.
     MOVE 0 TO L-PRESSED
     IF L-COUNT > 0
         MOVE 1 TO L-PRESSED
     END-IF
     GOBACK.
 END PROGRAM RS3-WIRE-PRESSED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-WIRE-REMOVAL-STATE.
*> USING disarmed, disarmed out, powered out (section 7.5): updateSource gets the removed state with powered forced true.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DISARMED             BINARY-LONG.
 01 L-OUT-DISARMED         BINARY-LONG.
 01 L-OUT-POWERED          BINARY-LONG.
 PROCEDURE DIVISION USING L-DISARMED L-OUT-DISARMED L-OUT-POWERED.
     MOVE L-DISARMED TO L-OUT-DISARMED
     MOVE 1 TO L-OUT-POWERED
     GOBACK.
 END PROGRAM RS3-WIRE-REMOVAL-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-SOURCE-SCAN.
*> USING a table of 64 cell kinds along one direction (0 other block, 1 wire, 2 hook facing the wire, 3 hook facing elsewhere), the index i of the hook found out
*> (0 none) (section 7.5 updateSource): i = 1 to 41, a wire continues, anything else ends the direction.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-KDG.
    05 L-KD                BINARY-LONG OCCURS 64 TIMES.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-KDG L-FOUND.
     MOVE 0 TO L-FOUND WS-DONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 41 OR WS-DONE = 1
         EVALUATE L-KD(WS-I)
             WHEN 2
                 MOVE WS-I TO L-FOUND
                 MOVE 1 TO WS-DONE
             WHEN 1
                 MOVE 0 TO WS-DONE
             WHEN OTHER
                 MOVE 1 TO WS-DONE
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM RS3-SOURCE-SCAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-WIRE-SHEARS.
*> USING server, shears in the main hand, disarms out, flags out (260), shear event frequency out (6) (section 7.5 shears).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-SHEARS               BINARY-LONG.
 01 L-DISARMS              BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-SHEARS L-DISARMS L-FLAGS L-EVENT.
     MOVE 0 TO L-DISARMS L-FLAGS L-EVENT
     IF L-SERVER = 1 AND L-SHEARS = 1
         MOVE 1 TO L-DISARMS
         MOVE 260 TO L-FLAGS
         MOVE 6 TO L-EVENT
     END-IF
     GOBACK.
 END PROGRAM RS3-WIRE-SHEARS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-NOTIFY-SECOND.
*> USING direction, the direction of the second block whose neighbours are updated out (section 7.6): opp(direction).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-SECOND               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-SECOND.
     COMPUTE L-SECOND = L-DIR + 1 - 2 * FUNCTION MOD(L-DIR, 2)
     GOBACK.
 END PROGRAM RS3-NOTIFY-SECOND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-HOOK-REMOVAL.
*> USING attached, powered, the calculation with removing true runs out, the old neighbours are notified out (section 7.7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ATTACHED             BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-CALC                 BINARY-LONG.
 01 L-NOTIFY               BINARY-LONG.
 PROCEDURE DIVISION USING L-ATTACHED L-POWERED L-CALC L-NOTIFY.
     MOVE 0 TO L-CALC
     MOVE L-POWERED TO L-NOTIFY
     IF L-ATTACHED = 1 OR L-POWERED = 1
         MOVE 1 TO L-CALC
     END-IF
     GOBACK.
 END PROGRAM RS3-HOOK-REMOVAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-HOOK-CALLER.
*> USING caller (1 placement, 2 the hook tick, 3 a wire updateSource, 4 the removal handler), removing out, notify out, a changed cell c out (section 7.3 callers).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CALLER               BINARY-LONG.
 01 L-REMOVING             BINARY-LONG.
 01 L-NOTIFY               BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-CALLER L-REMOVING L-NOTIFY L-CHANGED.
     MOVE 0 TO L-REMOVING L-NOTIFY L-CHANGED
     EVALUATE L-CALLER
         WHEN 2
             MOVE 1 TO L-NOTIFY
         WHEN 3
             MOVE 1 TO L-NOTIFY L-CHANGED
         WHEN 4
             MOVE 1 TO L-REMOVING
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-HOOK-CALLER.

*> ===== Section 8: bell

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BELL-ATTACHMENT.
*> USING serialized attachment name, ordinal out (section 8.1): floor 0, ceiling 1, single_wall 2, double_wall 3; -1 for another name.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-ORD                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-ORD.
     EVALUATE FUNCTION TRIM(L-NAME)
         WHEN "floor"
             MOVE 0 TO L-ORD
         WHEN "ceiling"
             MOVE 1 TO L-ORD
         WHEN "single_wall"
             MOVE 2 TO L-ORD
         WHEN "double_wall"
             MOVE 3 TO L-ORD
         WHEN OTHER
             MOVE -1 TO L-ORD
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-BELL-ATTACHMENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BELL-HIT.
*> USING attachment, facing, the hit face, the hit y relative to the block (a double), rings out (section 8.2 isProperHit): not on the Y axis, not above
*> 0.8123999834060669, then by attachment the axes of the face and of facing equal (floor), different (walls) or always (ceiling).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIMIT               FLOAT-LONG VALUE 0.8123999834060669.
 01 WS-GT                  BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ATTACHMENT           BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-FACE                 BINARY-LONG.
 01 L-REL                  FLOAT-LONG.
 01 L-RINGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ATTACHMENT L-FACING L-FACE L-REL L-RINGS.
     MOVE 0 TO L-RINGS WS-SAME
     CALL "FCMP-GT" USING L-REL WS-LIMIT WS-GT
     IF (L-FACE = 2 OR L-FACE = 3) AND (L-FACING = 2 OR L-FACING = 3)
         MOVE 1 TO WS-SAME
     END-IF
     IF (L-FACE = 4 OR L-FACE = 5) AND (L-FACING = 4 OR L-FACING = 5)
         MOVE 1 TO WS-SAME
     END-IF
     IF L-FACE >= 2 AND WS-GT = 0
         EVALUATE L-ATTACHMENT
             WHEN 0
                 MOVE WS-SAME TO L-RINGS
             WHEN 2 THRU 3
                 COMPUTE L-RINGS = 1 - WS-SAME
             WHEN 1
                 MOVE 1 TO L-RINGS
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM RS3-BELL-HIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BELL-ON-HIT.
*> USING check, isProperHit, attemptToRing rang, a player is known, hit counted out, bell_ring statistic out (section 8.3 onHit).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CHECK                BINARY-LONG.
 01 L-PROPER               BINARY-LONG.
 01 L-RANG                 BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-COUNTED              BINARY-LONG.
 01 L-STAT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CHECK L-PROPER L-RANG L-PLAYER L-COUNTED L-STAT.
     MOVE 0 TO L-COUNTED L-STAT
     IF L-PROPER = 1 OR L-CHECK = 0
         MOVE 1 TO L-COUNTED
         IF L-RANG = 1 AND L-PLAYER = 1
             MOVE 1 TO L-STAT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS3-BELL-ON-HIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BELL-USE-RESULT.
*> USING the hit counted, SUCCESS (1) or PASS (0) out (section 8.3 use without item).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNTED              BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNTED L-RESULT.
     MOVE L-COUNTED TO L-RESULT
     GOBACK.
 END PROGRAM RS3-BELL-USE-RESULT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BELL-SOURCE.
*> USING source (1 use without item, 2 projectile hit, 3 explosion, 4 redstone), onHit check out, rings with no direction out (section 8.3 table).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SOURCE               BINARY-LONG.
 01 L-CHECK                BINARY-LONG.
 01 L-NO-DIR               BINARY-LONG.
 PROCEDURE DIVISION USING L-SOURCE L-CHECK L-NO-DIR.
     MOVE 0 TO L-CHECK L-NO-DIR
     IF L-SOURCE = 1 OR L-SOURCE = 2
         MOVE 1 TO L-CHECK
     ELSE
         MOVE 1 TO L-NO-DIR
     END-IF
     GOBACK.
 END PROGRAM RS3-BELL-SOURCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BELL-RING.
*> USING server level, a bell block entity, a direction is given, facing, the direction, rang out, direction used out, sound volume out (2.0 in millionths),
*> block_change frequency out (11) (section 8.3 attemptToRing).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SERVER               BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-HAS-DIR              BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-RANG                 BINARY-LONG.
 01 L-USED                 BINARY-LONG.
 01 L-VOLUME               BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-SERVER L-ENTITY L-HAS-DIR L-FACING L-DIR L-RANG L-USED L-VOLUME L-EVENT.
     MOVE 0 TO L-RANG L-USED L-VOLUME L-EVENT
     IF L-SERVER = 1 AND L-ENTITY = 1
         MOVE 1 TO L-RANG
         MOVE L-FACING TO L-USED
         IF L-HAS-DIR = 1
             MOVE L-DIR TO L-USED
         END-IF
         MOVE 2000000 TO L-VOLUME
         MOVE 11 TO L-EVENT
     END-IF
     GOBACK.
 END PROGRAM RS3-BELL-RING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BELL-REDSTONE.
*> USING the neighbour signal, powered, rings out, powered out (section 8.3 redstone): rings on the rising edge only, powered follows the signal.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SIGNAL               BINARY-LONG.
 01 L-POWERED              BINARY-LONG.
 01 L-RINGS                BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SIGNAL L-POWERED L-RINGS L-NEW.
     MOVE 0 TO L-RINGS
     MOVE L-POWERED TO L-NEW
     IF L-SIGNAL NOT = L-POWERED
         MOVE L-SIGNAL TO L-RINGS L-NEW
     END-IF
     GOBACK.
 END PROGRAM RS3-BELL-REDSTONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BELL-CONST.
*> USING shake duration, resonance delay, resonance length, entity search radius, hear radius, glow duration, entity list refresh interval out (section 8.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SHAKE                BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 01 L-SEARCH               BINARY-LONG.
 01 L-HEAR                 BINARY-LONG.
 01 L-GLOW                 BINARY-LONG.
 01 L-REFRESH              BINARY-LONG.
 PROCEDURE DIVISION USING L-SHAKE L-DELAY L-LENGTH L-SEARCH L-HEAR L-GLOW L-REFRESH.
     MOVE 50 TO L-SHAKE
     MOVE 5 TO L-DELAY
     MOVE 40 TO L-LENGTH
     MOVE 48 TO L-SEARCH
     MOVE 32 TO L-HEAR
     MOVE 60 TO L-GLOW L-REFRESH
     GOBACK.
 END PROGRAM RS3-BELL-CONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BELL-HIT-ENTITY.
*> USING shaking, ticks, new ticks out, shaking out, block event type out (1) (section 8.4 onHit): shaking restarts ticks at 0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SHAKING              BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 01 L-NEW-TICKS            BINARY-LONG.
 01 L-NEW-SHAKING          BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SHAKING L-TICKS L-NEW-TICKS L-NEW-SHAKING L-TYPE.
     MOVE L-TICKS TO L-NEW-TICKS
     MOVE 1 TO L-NEW-SHAKING L-TYPE
     IF L-SHAKING = 1
         MOVE 0 TO L-NEW-TICKS
     END-IF
     GOBACK.
 END PROGRAM RS3-BELL-HIT-ENTITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BELL-TRIGGER.
*> USING the event value (a direction), ticks out, resonationTicks out, shaking out, direction out (section 8.4 triggerEvent).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VALUE                BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 01 L-RES                  BINARY-LONG.
 01 L-SHAKING              BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-VALUE L-TICKS L-RES L-SHAKING L-DIR.
     MOVE 0 TO L-TICKS L-RES
     MOVE 1 TO L-SHAKING
     MOVE L-VALUE TO L-DIR
     GOBACK.
 END PROGRAM RS3-BELL-TRIGGER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BELL-REFRESH.
*> USING the game time, lastRingTimestamp, a cached list exists, rebuild out (section 8.4 updateEntities): time above last + 60 or no list.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TIME                 BINARY-LONG.
 01 L-LAST                 BINARY-LONG.
 01 L-HAS-LIST             BINARY-LONG.
 01 L-REBUILD              BINARY-LONG.
 PROCEDURE DIVISION USING L-TIME L-LAST L-HAS-LIST L-REBUILD.
     MOVE 0 TO L-REBUILD
     IF L-TIME > L-LAST + 60 OR L-HAS-LIST = 0
         MOVE 1 TO L-REBUILD
     END-IF
     GOBACK.
 END PROGRAM RS3-BELL-REFRESH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BELL-HEARS.
*> USING alive, removed, the squared distance to the block centre in blocks, heard_bell_time set out (section 8.4): closer than 32.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ALIVE                BINARY-LONG.
 01 L-REMOVED              BINARY-LONG.
 01 L-DSQ                  BINARY-LONG.
 01 L-SETS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ALIVE L-REMOVED L-DSQ L-SETS.
     MOVE 0 TO L-SETS
     IF L-ALIVE = 1 AND L-REMOVED = 0 AND L-DSQ < 1024
         MOVE 1 TO L-SETS
     END-IF
     GOBACK.
 END PROGRAM RS3-BELL-HEARS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BELL-TICK.
*> USING shaking, ticks, resonating, resonationTicks, a raider is near, then shaking, ticks, resonating, resonationTicks out, bell_resonate sound out, end
*> action out (section 8.4 tick, in the order of the document).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SHAKING              BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 01 L-RESONATING           BINARY-LONG.
 01 L-RES-TICKS            BINARY-LONG.
 01 L-RAIDER               BINARY-LONG.
 01 L-O-SHAKING            BINARY-LONG.
 01 L-O-TICKS              BINARY-LONG.
 01 L-O-RESONATING         BINARY-LONG.
 01 L-O-RES-TICKS          BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SHAKING L-TICKS L-RESONATING L-RES-TICKS L-RAIDER L-O-SHAKING L-O-TICKS L-O-RESONATING L-O-RES-TICKS
         L-SOUND L-END.
     MOVE L-SHAKING TO L-O-SHAKING
     MOVE L-TICKS TO L-O-TICKS
     MOVE L-RESONATING TO L-O-RESONATING
     MOVE L-RES-TICKS TO L-O-RES-TICKS
     MOVE 0 TO L-SOUND L-END
     IF L-O-SHAKING = 1
         ADD 1 TO L-O-TICKS
     END-IF
     IF L-O-TICKS >= 50
         MOVE 0 TO L-O-SHAKING L-O-TICKS
     END-IF
     IF L-O-TICKS >= 5 AND L-O-RES-TICKS = 0 AND L-RAIDER = 1
         MOVE 1 TO L-O-RESONATING L-SOUND
     END-IF
     IF L-O-RESONATING = 1
         IF L-O-RES-TICKS < 40
             ADD 1 TO L-O-RES-TICKS
         ELSE
             MOVE 1 TO L-END
             MOVE 0 TO L-O-RESONATING
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RS3-BELL-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-BELL-GLOW.
*> USING alive, removed, tagged raiders, the squared distance in blocks, glowing for 60 ticks out (section 8.4 end action): closer than 48.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ALIVE                BINARY-LONG.
 01 L-REMOVED              BINARY-LONG.
 01 L-RAIDER               BINARY-LONG.
 01 L-DSQ                  BINARY-LONG.
 01 L-GLOWS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ALIVE L-REMOVED L-RAIDER L-DSQ L-GLOWS.
     MOVE 0 TO L-GLOWS
     IF L-ALIVE = 1 AND L-REMOVED = 0 AND L-RAIDER = 1 AND L-DSQ < 2304
         MOVE 1 TO L-GLOWS
     END-IF
     GOBACK.
 END PROGRAM RS3-BELL-GLOW.

*> ===== Section 9: catch-all

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TNT-FACTS.
*> USING unstable, state count, isSignalSource, conductor kind out (1 never) (section 9.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-UNSTABLE             BINARY-LONG.
 01 L-STATES               BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-CONDUCTOR            BINARY-LONG.
 PROCEDURE DIVISION USING L-UNSTABLE L-STATES L-SOURCE L-CONDUCTOR.
     MOVE 0 TO L-UNSTABLE L-SOURCE
     MOVE 2 TO L-STATES
     MOVE 1 TO L-CONDUCTOR
     GOBACK.
 END PROGRAM RS3-TNT-FACTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TNT-HOOK-ROW.
*> USING hook (1 onPlace, 2 neighborChanged, 3 playerWillDestroy, 4 wasExploded, 5 useItemOn, 6 onProjectileHit), needs a signal out, checks the previous block
*> out, server only out (section 9.1 table).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HOOK                 BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 01 L-PREVIOUS             BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 PROCEDURE DIVISION USING L-HOOK L-SIGNAL L-PREVIOUS L-SERVER.
     MOVE 0 TO L-SIGNAL L-PREVIOUS L-SERVER
     EVALUATE L-HOOK
         WHEN 1
             MOVE 1 TO L-SIGNAL L-PREVIOUS
         WHEN 2
             MOVE 1 TO L-SIGNAL
         WHEN 3
             MOVE 1 TO L-SERVER
         WHEN 6
             MOVE 1 TO L-SERVER
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-TNT-HOOK-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DRIP-TILT.
*> USING serialized tilt name, ordinal out (section 9.2): none 0, unstable 1, partial 2, full 3; -1 for another name.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-ORD                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-ORD.
     EVALUATE FUNCTION TRIM(L-NAME)
         WHEN "none"
             MOVE 0 TO L-ORD
         WHEN "unstable"
             MOVE 1 TO L-ORD
         WHEN "partial"
             MOVE 2 TO L-ORD
         WHEN "full"
             MOVE 3 TO L-ORD
         WHEN OTHER
             MOVE -1 TO L-ORD
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-DRIP-TILT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DRIP-DELAY.
*> USING tilt, ticks until the next state out (section 9.2): unstable 10, partial 10, full 100, none -1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TILT                 BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-TILT L-DELAY.
     MOVE -1 TO L-DELAY
     EVALUATE L-TILT
         WHEN 1 THRU 2
             MOVE 10 TO L-DELAY
         WHEN 3
             MOVE 100 TO L-DELAY
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-DRIP-DELAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DRIP-CAN-TILT.
*> USING the entity is on the ground, its y relative to the block in ten-thousandths, canEntityTilt out (section 9.2): above 0.6875.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-GROUND               BINARY-LONG.
 01 L-REL-Y                BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-GROUND L-REL-Y L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-GROUND = 1 AND L-REL-Y > 6875
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM RS3-DRIP-CAN-TILT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DRIP-ENTITY.
*> USING tilt, canEntityTilt, neighbour signal, sets unstable out, tick delay out (section 9.2 entity inside).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TILT                 BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 01 L-SETS                 BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 PROCEDURE DIVISION USING L-TILT L-CAN L-SIGNAL L-SETS L-DELAY.
     MOVE 0 TO L-SETS
     MOVE -1 TO L-DELAY
     IF L-TILT = 0 AND L-CAN = 1 AND L-SIGNAL = 0
         MOVE 1 TO L-SETS
         MOVE 10 TO L-DELAY
     END-IF
     GOBACK.
 END PROGRAM RS3-DRIP-ENTITY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DRIP-VIBRATES.
*> USING the new tilt, the old tilt, block_change posted out (section 9.2 setTilt): the new tilt differs and causes a vibration (none, partial, full).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NEW                  BINARY-LONG.
 01 L-OLD                  BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-NEW L-OLD L-EVENT.
     MOVE 0 TO L-EVENT
     IF L-NEW NOT = L-OLD AND L-NEW NOT = 1
         MOVE 1 TO L-EVENT
     END-IF
     GOBACK.
 END PROGRAM RS3-DRIP-VIBRATES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DRIP-NEIGHBOR.
*> USING the neighbour signal, tilt, new tilt out, sound out (1 tilt down, 2 tilt up), block_change out (section 9.2 neighborChanged): resetTilt.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SIGNAL               BINARY-LONG.
 01 L-TILT                 BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-SIGNAL L-TILT L-NEW L-SOUND L-EVENT.
     MOVE L-TILT TO L-NEW
     MOVE 0 TO L-SOUND L-EVENT
     IF L-SIGNAL = 1
         MOVE 0 TO L-NEW
         IF L-TILT NOT = 0
             MOVE 2 TO L-SOUND
         END-IF
         CALL "RS3-DRIP-VIBRATES" USING L-NEW L-TILT L-EVENT
     END-IF
     GOBACK.
 END PROGRAM RS3-DRIP-NEIGHBOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DRIP-TICK.
*> USING the neighbour signal, tilt, new tilt out, sound out, next tick delay out (-1 none), block_change out (section 9.2 scheduled tick).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SIGNAL               BINARY-LONG.
 01 L-TILT                 BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-SIGNAL L-TILT L-NEW L-SOUND L-DELAY L-EVENT.
     MOVE 0 TO L-NEW L-SOUND L-EVENT
     IF L-SIGNAL = 1
         IF L-TILT NOT = 0
             MOVE 2 TO L-SOUND
         END-IF
     ELSE
         EVALUATE L-TILT
             WHEN 1
                 MOVE 2 TO L-NEW
                 MOVE 1 TO L-SOUND
             WHEN 2
                 MOVE 3 TO L-NEW
                 MOVE 1 TO L-SOUND
             WHEN 3
                 MOVE 2 TO L-SOUND
         END-EVALUATE
     END-IF
     CALL "RS3-DRIP-DELAY" USING L-NEW L-DELAY
     CALL "RS3-DRIP-VIBRATES" USING L-NEW L-TILT L-EVENT
     GOBACK.
 END PROGRAM RS3-DRIP-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DRIP-PROJECTILE.
*> USING tilt, new tilt out (full), sound out (tilt down), block_change out (section 9.2 projectile hit): no power check.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TILT                 BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-TILT L-NEW L-SOUND L-EVENT.
     MOVE 3 TO L-NEW
     MOVE 1 TO L-SOUND
     CALL "RS3-DRIP-VIBRATES" USING L-NEW L-TILT L-EVENT
     GOBACK.
 END PROGRAM RS3-DRIP-PROJECTILE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-DRIP-PITCH.
*> USING nextFloat draw (a double), pitch out in millionths (section 9.2): Mth.randomBetween(random, 0.8, 1.2) = draw * 0.4 + 0.8.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DRAW                 FLOAT-LONG.
 01 L-PITCH                BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-PITCH.
     COMPUTE L-PITCH ROUNDED = (L-DRAW * 0.4 + 0.8) * 1000000
     GOBACK.
 END PROGRAM RS3-DRIP-PITCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-READER-OWNER.
*> USING the block class name, owner out (1 to 8 for 30-N, 311 for 31-1, 313 for 31-3, 314 for 31-4, 316 for 31-6, 0 not redstone, -1 unknown) (section 9.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-OWNER                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-OWNER.
     MOVE -1 TO L-OWNER
     EVALUATE FUNCTION TRIM(L-NAME)
         WHEN "DoorBlock"
             MOVE 7 TO L-OWNER
         WHEN "TrapDoorBlock"
             MOVE 7 TO L-OWNER
         WHEN "FenceGateBlock"
             MOVE 7 TO L-OWNER
         WHEN "RedstoneLampBlock"
             MOVE 7 TO L-OWNER
         WHEN "CopperBulbBlock"
             MOVE 7 TO L-OWNER
         WHEN "NoteBlock"
             MOVE 5 TO L-OWNER
         WHEN "DispenserBlock"
             MOVE 4 TO L-OWNER
         WHEN "HopperBlock"
             MOVE 4 TO L-OWNER
         WHEN "CrafterBlock"
             MOVE 4 TO L-OWNER
         WHEN "BaseRailBlock"
             MOVE 6 TO L-OWNER
         WHEN "PoweredRailBlock"
             MOVE 6 TO L-OWNER
         WHEN "DetectorRailBlock"
             MOVE 6 TO L-OWNER
         WHEN "PistonBaseBlock"
             MOVE 3 TO L-OWNER
         WHEN "DiodeBlock"
             MOVE 2 TO L-OWNER
         WHEN "ObserverBlock"
             MOVE 2 TO L-OWNER
         WHEN "CommandBlock"
             MOVE 316 TO L-OWNER
         WHEN "StructureBlock"
             MOVE 316 TO L-OWNER
         WHEN "TestBlock"
             MOVE 316 TO L-OWNER
         WHEN "ShelfBlock"
             MOVE 313 TO L-OWNER
         WHEN "AbstractSkullBlock"
             MOVE 313 TO L-OWNER
         WHEN "LecternBlock"
             MOVE 314 TO L-OWNER
         WHEN "JukeboxBlock"
             MOVE 314 TO L-OWNER
         WHEN "TrappedChestBlock"
             MOVE 311 TO L-OWNER
         WHEN "BellBlock"
             MOVE 8 TO L-OWNER
         WHEN "SculkSensorBlock"
             MOVE 8 TO L-OWNER
         WHEN "TripWireHookBlock"
             MOVE 8 TO L-OWNER
         WHEN "TntBlock"
             MOVE 8 TO L-OWNER
         WHEN "BigDripleafBlock"
             MOVE 8 TO L-OWNER
         WHEN "CarvedPumpkinBlock"
             MOVE 0 TO L-OWNER
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-READER-OWNER.

*> ===== Section 10: inventory of the redstone category

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TAB-COUNT.
*> USING entries, accept calls, forEach calls, tab row, tab column out (section 10): the creative tab itemGroup.redstone (key redstone_blocks).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTRIES              BINARY-LONG.
 01 L-ACCEPTS              BINARY-LONG.
 01 L-FOREACH              BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-COLUMN               BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTRIES L-ACCEPTS L-FOREACH L-ROW L-COLUMN.
     MOVE 66 TO L-ACCEPTS
     MOVE 1 TO L-FOREACH
     COMPUTE L-ENTRIES = L-ACCEPTS + L-FOREACH
     MOVE 0 TO L-ROW
     MOVE 4 TO L-COLUMN
     GOBACK.
 END PROGRAM RS3-TAB-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TAB-ITEM.
*> USING item name, tab number out, owning document out (30-N as 300 + N, 31-N as 310 + N, 459 for 45-9, 0 none), section out (0 none) (section 10 table);
*> zeros for an item not in the tab.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
 05 FILLER PIC X(32) VALUE "redstone".
 05 FILLER PIC 9(3) VALUE 301.
 05 FILLER PIC 99 VALUE 5.
 05 FILLER PIC X(32) VALUE "redstone_torch".
 05 FILLER PIC 9(3) VALUE 301.
 05 FILLER PIC 99 VALUE 8.
 05 FILLER PIC X(32) VALUE "redstone_block".
 05 FILLER PIC 9(3) VALUE 301.
 05 FILLER PIC 99 VALUE 6.
 05 FILLER PIC X(32) VALUE "repeater".
 05 FILLER PIC 9(3) VALUE 302.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "comparator".
 05 FILLER PIC 9(3) VALUE 302.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "target".
 05 FILLER PIC 9(3) VALUE 305.
 05 FILLER PIC 99 VALUE 6.
 05 FILLER PIC X(32) VALUE "copper_bulb".
 05 FILLER PIC 9(3) VALUE 307.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "lever".
 05 FILLER PIC 9(3) VALUE 305.
 05 FILLER PIC 99 VALUE 2.
 05 FILLER PIC X(32) VALUE "oak_button".
 05 FILLER PIC 9(3) VALUE 305.
 05 FILLER PIC 99 VALUE 3.
 05 FILLER PIC X(32) VALUE "stone_button".
 05 FILLER PIC 9(3) VALUE 305.
 05 FILLER PIC 99 VALUE 3.
 05 FILLER PIC X(32) VALUE "oak_pressure_plate".
 05 FILLER PIC 9(3) VALUE 305.
 05 FILLER PIC 99 VALUE 4.
 05 FILLER PIC X(32) VALUE "stone_pressure_plate".
 05 FILLER PIC 9(3) VALUE 305.
 05 FILLER PIC 99 VALUE 4.
 05 FILLER PIC X(32) VALUE "light_weighted_pressure_plate".
 05 FILLER PIC 9(3) VALUE 305.
 05 FILLER PIC 99 VALUE 4.
 05 FILLER PIC X(32) VALUE "heavy_weighted_pressure_plate".
 05 FILLER PIC 9(3) VALUE 305.
 05 FILLER PIC 99 VALUE 4.
 05 FILLER PIC X(32) VALUE "sculk_sensor".
 05 FILLER PIC 9(3) VALUE 308.
 05 FILLER PIC 99 VALUE 4.
 05 FILLER PIC X(32) VALUE "calibrated_sculk_sensor".
 05 FILLER PIC 9(3) VALUE 308.
 05 FILLER PIC 99 VALUE 5.
 05 FILLER PIC X(32) VALUE "sculk_shrieker".
 05 FILLER PIC 9(3) VALUE 308.
 05 FILLER PIC 99 VALUE 6.
 05 FILLER PIC X(32) VALUE "amethyst_block".
 05 FILLER PIC 9(3) VALUE 308.
 05 FILLER PIC 99 VALUE 4.
 05 FILLER PIC X(32) VALUE "white_wool".
 05 FILLER PIC 9(3) VALUE 308.
 05 FILLER PIC 99 VALUE 3.
 05 FILLER PIC X(32) VALUE "tripwire_hook".
 05 FILLER PIC 9(3) VALUE 308.
 05 FILLER PIC 99 VALUE 7.
 05 FILLER PIC X(32) VALUE "string".
 05 FILLER PIC 9(3) VALUE 308.
 05 FILLER PIC 99 VALUE 7.
 05 FILLER PIC X(32) VALUE "lectern".
 05 FILLER PIC 9(3) VALUE 314.
 05 FILLER PIC 99 VALUE 3.
 05 FILLER PIC X(32) VALUE "daylight_detector".
 05 FILLER PIC 9(3) VALUE 305.
 05 FILLER PIC 99 VALUE 5.
 05 FILLER PIC X(32) VALUE "lightning_rod".
 05 FILLER PIC 9(3) VALUE 305.
 05 FILLER PIC 99 VALUE 7.
 05 FILLER PIC X(32) VALUE "piston".
 05 FILLER PIC 9(3) VALUE 303.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "sticky_piston".
 05 FILLER PIC 9(3) VALUE 303.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "slime_block".
 05 FILLER PIC 9(3) VALUE 303.
 05 FILLER PIC 99 VALUE 4.
 05 FILLER PIC X(32) VALUE "honey_block".
 05 FILLER PIC 9(3) VALUE 303.
 05 FILLER PIC 99 VALUE 4.
 05 FILLER PIC X(32) VALUE "dispenser".
 05 FILLER PIC 9(3) VALUE 304.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "dropper".
 05 FILLER PIC 9(3) VALUE 304.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "crafter".
 05 FILLER PIC 9(3) VALUE 304.
 05 FILLER PIC 99 VALUE 6.
 05 FILLER PIC X(32) VALUE "hopper".
 05 FILLER PIC 9(3) VALUE 304.
 05 FILLER PIC 99 VALUE 5.
 05 FILLER PIC X(32) VALUE "chest".
 05 FILLER PIC 9(3) VALUE 311.
 05 FILLER PIC 99 VALUE 10.
 05 FILLER PIC X(32) VALUE "copper_chest".
 05 FILLER PIC 9(3) VALUE 311.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "barrel".
 05 FILLER PIC 9(3) VALUE 311.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "chiseled_bookshelf".
 05 FILLER PIC 9(3) VALUE 310.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "oak_shelf".
 05 FILLER PIC 9(3) VALUE 313.
 05 FILLER PIC 99 VALUE 6.
 05 FILLER PIC X(32) VALUE "furnace".
 05 FILLER PIC 9(3) VALUE 312.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "trapped_chest".
 05 FILLER PIC 9(3) VALUE 311.
 05 FILLER PIC 99 VALUE 10.
 05 FILLER PIC X(32) VALUE "jukebox".
 05 FILLER PIC 9(3) VALUE 314.
 05 FILLER PIC 99 VALUE 2.
 05 FILLER PIC X(32) VALUE "decorated_pot".
 05 FILLER PIC 9(3) VALUE 313.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "observer".
 05 FILLER PIC 9(3) VALUE 302.
 05 FILLER PIC 99 VALUE 6.
 05 FILLER PIC X(32) VALUE "note_block".
 05 FILLER PIC 9(3) VALUE 305.
 05 FILLER PIC 99 VALUE 8.
 05 FILLER PIC X(32) VALUE "composter".
 05 FILLER PIC 9(3) VALUE 302.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "cauldron".
 05 FILLER PIC 9(3) VALUE 302.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "rail".
 05 FILLER PIC 9(3) VALUE 306.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "powered_rail".
 05 FILLER PIC 9(3) VALUE 306.
 05 FILLER PIC 99 VALUE 5.
 05 FILLER PIC X(32) VALUE "detector_rail".
 05 FILLER PIC 9(3) VALUE 306.
 05 FILLER PIC 99 VALUE 6.
 05 FILLER PIC X(32) VALUE "activator_rail".
 05 FILLER PIC 9(3) VALUE 306.
 05 FILLER PIC 99 VALUE 5.
 05 FILLER PIC X(32) VALUE "minecart".
 05 FILLER PIC 9(3) VALUE 306.
 05 FILLER PIC 99 VALUE 8.
 05 FILLER PIC X(32) VALUE "hopper_minecart".
 05 FILLER PIC 9(3) VALUE 304.
 05 FILLER PIC 99 VALUE 5.
 05 FILLER PIC X(32) VALUE "chest_minecart".
 05 FILLER PIC 9(3) VALUE 306.
 05 FILLER PIC 99 VALUE 8.
 05 FILLER PIC X(32) VALUE "furnace_minecart".
 05 FILLER PIC 9(3) VALUE 306.
 05 FILLER PIC 99 VALUE 8.
 05 FILLER PIC X(32) VALUE "tnt_minecart".
 05 FILLER PIC 9(3) VALUE 306.
 05 FILLER PIC 99 VALUE 8.
 05 FILLER PIC X(32) VALUE "oak_chest_boat".
 05 FILLER PIC 9(3) VALUE 0.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "bamboo_chest_raft".
 05 FILLER PIC 9(3) VALUE 0.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "oak_door".
 05 FILLER PIC 9(3) VALUE 307.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "iron_door".
 05 FILLER PIC 9(3) VALUE 307.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "oak_fence_gate".
 05 FILLER PIC 9(3) VALUE 307.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "oak_trapdoor".
 05 FILLER PIC 9(3) VALUE 307.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "iron_trapdoor".
 05 FILLER PIC 9(3) VALUE 307.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "tnt".
 05 FILLER PIC 9(3) VALUE 308.
 05 FILLER PIC 99 VALUE 9.
 05 FILLER PIC X(32) VALUE "redstone_lamp".
 05 FILLER PIC 9(3) VALUE 307.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "bell".
 05 FILLER PIC 9(3) VALUE 308.
 05 FILLER PIC 99 VALUE 8.
 05 FILLER PIC X(32) VALUE "big_dripleaf".
 05 FILLER PIC 9(3) VALUE 308.
 05 FILLER PIC 99 VALUE 9.
 05 FILLER PIC X(32) VALUE "armor_stand".
 05 FILLER PIC 9(3) VALUE 459.
 05 FILLER PIC 99 VALUE 11.
 05 FILLER PIC X(32) VALUE "redstone_ore".
 05 FILLER PIC 9(3) VALUE 301.
 05 FILLER PIC 99 VALUE 7.
 01 WS-TABLE REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 67 TIMES.
       10 WS-RNAME         PIC X(32).
       10 WS-ROWNER        PIC 9(3).
       10 WS-RSECTION      PIC 99.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-NUMBER               BINARY-LONG.
 01 L-OWNER                BINARY-LONG.
 01 L-SECTION              BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-NUMBER L-OWNER L-SECTION.
     MOVE 0 TO L-NUMBER L-OWNER L-SECTION
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 67
         IF FUNCTION TRIM(L-NAME) = FUNCTION TRIM(WS-RNAME(WS-I))
             MOVE WS-I TO L-NUMBER
             MOVE WS-ROWNER(WS-I) TO L-OWNER
             MOVE WS-RSECTION(WS-I) TO L-SECTION
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RS3-TAB-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-TAB-ROW.
*> USING tab number 1 to 67, owning document out, section out (section 10); zeros outside 1 to 67.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
 05 FILLER PIC X(32) VALUE "redstone".
 05 FILLER PIC 9(3) VALUE 301.
 05 FILLER PIC 99 VALUE 5.
 05 FILLER PIC X(32) VALUE "redstone_torch".
 05 FILLER PIC 9(3) VALUE 301.
 05 FILLER PIC 99 VALUE 8.
 05 FILLER PIC X(32) VALUE "redstone_block".
 05 FILLER PIC 9(3) VALUE 301.
 05 FILLER PIC 99 VALUE 6.
 05 FILLER PIC X(32) VALUE "repeater".
 05 FILLER PIC 9(3) VALUE 302.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "comparator".
 05 FILLER PIC 9(3) VALUE 302.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "target".
 05 FILLER PIC 9(3) VALUE 305.
 05 FILLER PIC 99 VALUE 6.
 05 FILLER PIC X(32) VALUE "copper_bulb".
 05 FILLER PIC 9(3) VALUE 307.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "lever".
 05 FILLER PIC 9(3) VALUE 305.
 05 FILLER PIC 99 VALUE 2.
 05 FILLER PIC X(32) VALUE "oak_button".
 05 FILLER PIC 9(3) VALUE 305.
 05 FILLER PIC 99 VALUE 3.
 05 FILLER PIC X(32) VALUE "stone_button".
 05 FILLER PIC 9(3) VALUE 305.
 05 FILLER PIC 99 VALUE 3.
 05 FILLER PIC X(32) VALUE "oak_pressure_plate".
 05 FILLER PIC 9(3) VALUE 305.
 05 FILLER PIC 99 VALUE 4.
 05 FILLER PIC X(32) VALUE "stone_pressure_plate".
 05 FILLER PIC 9(3) VALUE 305.
 05 FILLER PIC 99 VALUE 4.
 05 FILLER PIC X(32) VALUE "light_weighted_pressure_plate".
 05 FILLER PIC 9(3) VALUE 305.
 05 FILLER PIC 99 VALUE 4.
 05 FILLER PIC X(32) VALUE "heavy_weighted_pressure_plate".
 05 FILLER PIC 9(3) VALUE 305.
 05 FILLER PIC 99 VALUE 4.
 05 FILLER PIC X(32) VALUE "sculk_sensor".
 05 FILLER PIC 9(3) VALUE 308.
 05 FILLER PIC 99 VALUE 4.
 05 FILLER PIC X(32) VALUE "calibrated_sculk_sensor".
 05 FILLER PIC 9(3) VALUE 308.
 05 FILLER PIC 99 VALUE 5.
 05 FILLER PIC X(32) VALUE "sculk_shrieker".
 05 FILLER PIC 9(3) VALUE 308.
 05 FILLER PIC 99 VALUE 6.
 05 FILLER PIC X(32) VALUE "amethyst_block".
 05 FILLER PIC 9(3) VALUE 308.
 05 FILLER PIC 99 VALUE 4.
 05 FILLER PIC X(32) VALUE "white_wool".
 05 FILLER PIC 9(3) VALUE 308.
 05 FILLER PIC 99 VALUE 3.
 05 FILLER PIC X(32) VALUE "tripwire_hook".
 05 FILLER PIC 9(3) VALUE 308.
 05 FILLER PIC 99 VALUE 7.
 05 FILLER PIC X(32) VALUE "string".
 05 FILLER PIC 9(3) VALUE 308.
 05 FILLER PIC 99 VALUE 7.
 05 FILLER PIC X(32) VALUE "lectern".
 05 FILLER PIC 9(3) VALUE 314.
 05 FILLER PIC 99 VALUE 3.
 05 FILLER PIC X(32) VALUE "daylight_detector".
 05 FILLER PIC 9(3) VALUE 305.
 05 FILLER PIC 99 VALUE 5.
 05 FILLER PIC X(32) VALUE "lightning_rod".
 05 FILLER PIC 9(3) VALUE 305.
 05 FILLER PIC 99 VALUE 7.
 05 FILLER PIC X(32) VALUE "piston".
 05 FILLER PIC 9(3) VALUE 303.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "sticky_piston".
 05 FILLER PIC 9(3) VALUE 303.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "slime_block".
 05 FILLER PIC 9(3) VALUE 303.
 05 FILLER PIC 99 VALUE 4.
 05 FILLER PIC X(32) VALUE "honey_block".
 05 FILLER PIC 9(3) VALUE 303.
 05 FILLER PIC 99 VALUE 4.
 05 FILLER PIC X(32) VALUE "dispenser".
 05 FILLER PIC 9(3) VALUE 304.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "dropper".
 05 FILLER PIC 9(3) VALUE 304.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "crafter".
 05 FILLER PIC 9(3) VALUE 304.
 05 FILLER PIC 99 VALUE 6.
 05 FILLER PIC X(32) VALUE "hopper".
 05 FILLER PIC 9(3) VALUE 304.
 05 FILLER PIC 99 VALUE 5.
 05 FILLER PIC X(32) VALUE "chest".
 05 FILLER PIC 9(3) VALUE 311.
 05 FILLER PIC 99 VALUE 10.
 05 FILLER PIC X(32) VALUE "copper_chest".
 05 FILLER PIC 9(3) VALUE 311.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "barrel".
 05 FILLER PIC 9(3) VALUE 311.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "chiseled_bookshelf".
 05 FILLER PIC 9(3) VALUE 310.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "oak_shelf".
 05 FILLER PIC 9(3) VALUE 313.
 05 FILLER PIC 99 VALUE 6.
 05 FILLER PIC X(32) VALUE "furnace".
 05 FILLER PIC 9(3) VALUE 312.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "trapped_chest".
 05 FILLER PIC 9(3) VALUE 311.
 05 FILLER PIC 99 VALUE 10.
 05 FILLER PIC X(32) VALUE "jukebox".
 05 FILLER PIC 9(3) VALUE 314.
 05 FILLER PIC 99 VALUE 2.
 05 FILLER PIC X(32) VALUE "decorated_pot".
 05 FILLER PIC 9(3) VALUE 313.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "observer".
 05 FILLER PIC 9(3) VALUE 302.
 05 FILLER PIC 99 VALUE 6.
 05 FILLER PIC X(32) VALUE "note_block".
 05 FILLER PIC 9(3) VALUE 305.
 05 FILLER PIC 99 VALUE 8.
 05 FILLER PIC X(32) VALUE "composter".
 05 FILLER PIC 9(3) VALUE 302.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "cauldron".
 05 FILLER PIC 9(3) VALUE 302.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "rail".
 05 FILLER PIC 9(3) VALUE 306.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "powered_rail".
 05 FILLER PIC 9(3) VALUE 306.
 05 FILLER PIC 99 VALUE 5.
 05 FILLER PIC X(32) VALUE "detector_rail".
 05 FILLER PIC 9(3) VALUE 306.
 05 FILLER PIC 99 VALUE 6.
 05 FILLER PIC X(32) VALUE "activator_rail".
 05 FILLER PIC 9(3) VALUE 306.
 05 FILLER PIC 99 VALUE 5.
 05 FILLER PIC X(32) VALUE "minecart".
 05 FILLER PIC 9(3) VALUE 306.
 05 FILLER PIC 99 VALUE 8.
 05 FILLER PIC X(32) VALUE "hopper_minecart".
 05 FILLER PIC 9(3) VALUE 304.
 05 FILLER PIC 99 VALUE 5.
 05 FILLER PIC X(32) VALUE "chest_minecart".
 05 FILLER PIC 9(3) VALUE 306.
 05 FILLER PIC 99 VALUE 8.
 05 FILLER PIC X(32) VALUE "furnace_minecart".
 05 FILLER PIC 9(3) VALUE 306.
 05 FILLER PIC 99 VALUE 8.
 05 FILLER PIC X(32) VALUE "tnt_minecart".
 05 FILLER PIC 9(3) VALUE 306.
 05 FILLER PIC 99 VALUE 8.
 05 FILLER PIC X(32) VALUE "oak_chest_boat".
 05 FILLER PIC 9(3) VALUE 0.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "bamboo_chest_raft".
 05 FILLER PIC 9(3) VALUE 0.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "oak_door".
 05 FILLER PIC 9(3) VALUE 307.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "iron_door".
 05 FILLER PIC 9(3) VALUE 307.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "oak_fence_gate".
 05 FILLER PIC 9(3) VALUE 307.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "oak_trapdoor".
 05 FILLER PIC 9(3) VALUE 307.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "iron_trapdoor".
 05 FILLER PIC 9(3) VALUE 307.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "tnt".
 05 FILLER PIC 9(3) VALUE 308.
 05 FILLER PIC 99 VALUE 9.
 05 FILLER PIC X(32) VALUE "redstone_lamp".
 05 FILLER PIC 9(3) VALUE 307.
 05 FILLER PIC 99 VALUE 0.
 05 FILLER PIC X(32) VALUE "bell".
 05 FILLER PIC 9(3) VALUE 308.
 05 FILLER PIC 99 VALUE 8.
 05 FILLER PIC X(32) VALUE "big_dripleaf".
 05 FILLER PIC 9(3) VALUE 308.
 05 FILLER PIC 99 VALUE 9.
 05 FILLER PIC X(32) VALUE "armor_stand".
 05 FILLER PIC 9(3) VALUE 459.
 05 FILLER PIC 99 VALUE 11.
 05 FILLER PIC X(32) VALUE "redstone_ore".
 05 FILLER PIC 9(3) VALUE 301.
 05 FILLER PIC 99 VALUE 7.
 01 WS-TABLE REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 67 TIMES.
       10 WS-RNAME         PIC X(32).
       10 WS-ROWNER        PIC 9(3).
       10 WS-RSECTION      PIC 99.
 LINKAGE SECTION.
 01 L-NUMBER               BINARY-LONG.
 01 L-OWNER                BINARY-LONG.
 01 L-SECTION              BINARY-LONG.
 PROCEDURE DIVISION USING L-NUMBER L-OWNER L-SECTION.
     MOVE 0 TO L-OWNER L-SECTION
     IF L-NUMBER >= 1 AND L-NUMBER <= 67
         MOVE WS-ROWNER(L-NUMBER) TO L-OWNER
         MOVE WS-RSECTION(L-NUMBER) TO L-SECTION
     END-IF
     GOBACK.
 END PROGRAM RS3-TAB-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS3-NO-TAB-ITEM.
*> USING block name, the block has no tab item of its own out (section 10): redstone_wire, redstone_wall_torch, tripwire, piston_head, moving_piston,
*> deepslate_redstone_ore.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-RESULT.
     MOVE 0 TO L-RESULT
     EVALUATE FUNCTION TRIM(L-NAME)
         WHEN "redstone_wire"
             MOVE 1 TO L-RESULT
         WHEN "redstone_wall_torch"
             MOVE 1 TO L-RESULT
         WHEN "tripwire"
             MOVE 1 TO L-RESULT
         WHEN "piston_head"
             MOVE 1 TO L-RESULT
         WHEN "moving_piston"
             MOVE 1 TO L-RESULT
         WHEN "deepslate_redstone_ore"
             MOVE 1 TO L-RESULT
     END-EVALUATE
     GOBACK.
 END PROGRAM RS3-NO-TAB-ITEM.
