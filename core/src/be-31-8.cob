*> Block entities, part 8: sculk sensor, calibrated sculk sensor, sculk shrieker, sculk catalyst, copper golem statue, potent sulfur, the game event delivery rules they depend on and the
*> registry sweep (docs/protocol/31-block-entities-8-sculk-and-remaining-types.md; US12 phase 44). The data of the types lives in the BE-XI, BE-XT, BE-XF, BE-XD, BE-SEED, BE-TIME2 and BE-UUID cells of
*> the entity (roles in BESTATE.cpy). The programs are the rules of the sections; what needs the world (chunks, rays, players, the block state, the particles and sounds) is done by the caller from
*> the results. The test block and test instance block of section 10 are the BE6- programs of be-31-6.cob. Not here: the spreader's cursor update (35-6 section 8.4), the warden and shrieker
*> behaviour (44-x2), the golem entity, the geyser plume and the client particles (42), the position random of the sulfur countdown (10, the caller passes the draw).
*> Game event keys are the registry names, with or without the minecraft: prefix. Directions: 0 down, 1 up, 2 north, 3 south, 4 west, 5 east; a facings set is a bit mask of them.
*>
*>   BE8-EVENT-RADIUS, BE8-SECTION-RANGE, BE8-LISTENER-IN, BE8-ORDER, BE8-REGISTER                                                                      2
*>   BE8-FREQUENCY, BE8-RESONANCE, BE8-STRENGTH, BE8-TRAVEL, BE8-VALID, BE8-HANDLE, BE8-OCCLUDED, BE8-SNAP, BE8-ADD-CANDIDATE, BE8-CHOSEN, BE8-TICK, BE8-RELOAD, BE8-LISTENER-SAVE,
*>        BE8-LISTENER-LOAD and the helpers BE8-VINFO-WRITE, BE8-VINFO-READ                                                                                3
*>   BE8-SENSOR-CAN, BE8-SENSOR-RECEIVE, BE8-PHASE-TICK, BE8-PITCH, BE8-SENSOR-OUTPUT, BE8-STEP-ON, BE8-KEYS-SAVE, BE8-KEYS-LOAD                          4
*>   BE8-RADIUS, BE8-ACTIVE-TICKS, BE8-CAL-SIGNAL                                                                                                         5
*>   BE8-SHRIEKER-CAN, BE8-SHRIEKER-PLAYER, BE8-SHRIEKER-REMOVE                                                                                           6
*>   BE8-CAT-HANDLE, BE8-ADD-CURSORS, BE8-CAT-SAVE, BE8-CAT-LOAD, BE8-MERGE, BE8-BLOOM                                                                    7
*>   BE8-STATUE-NEXT, BE8-STATUE-SIGNAL, BE8-STATUE-USE, BE8-STATUE-FACING                                                                                8
*>   BE8-SULFUR-SOURCE, BE8-SULFUR-UNOBSTRUCTED, BE8-SULFUR-COUNTDOWN, BE8-SULFUR-NAUSEA, BE8-SULFUR-REACH, BE8-SULFUR-LAUNCH, BE8-GEYSER-SEED, BE8-SULFUR-TICKER, BE8-SULFUR-PLACE   9
*>   BE8-SWEEP                                                                                                                                            11
*>   BE8-DEFAULTS, BE8-SAVE, BE8-LOAD-KEY (BEX-DEFAULTS, BEX-SAVE and BEX-LOAD-KEY of be-31-3.cob)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-EVENT-NAME.
*> USING name (X(48)), length, bare name out (X(48), the minecraft: prefix removed), bare length out.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(48).
 01 L-LENGTH               BINARY-LONG.
 01 L-BARE                 PIC X(48).
 01 L-BARE-LENGTH          BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-LENGTH L-BARE L-BARE-LENGTH.
     MOVE SPACES TO L-BARE
     MOVE L-LENGTH TO L-BARE-LENGTH
     IF L-LENGTH > 10 AND L-NAME(1:10) = "minecraft:"
         COMPUTE L-BARE-LENGTH = L-LENGTH - 10
         MOVE L-NAME(11:L-BARE-LENGTH) TO L-BARE
     ELSE
         MOVE L-NAME(1:L-LENGTH) TO L-BARE
     END-IF
     GOBACK.
 END PROGRAM BE8-EVENT-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-EVENT-RADIUS.
*> USING event name, length, notification radius out: 2.1 (16, jukebox_play and jukebox_stop_play 10, shriek 32).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BARE                PIC X(48).
 01 WS-BARE-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(48).
 01 L-LENGTH               BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-LENGTH L-RADIUS.
     CALL "BE8-EVENT-NAME" USING L-NAME L-LENGTH WS-BARE WS-BARE-LENGTH
     MOVE 16 TO L-RADIUS
     IF WS-BARE = "jukebox_play" OR WS-BARE = "jukebox_stop_play"
         MOVE 10 TO L-RADIUS
     END-IF
     IF WS-BARE = "shriek"
         MOVE 32 TO L-RADIUS
     END-IF
     GOBACK.
 END PROGRAM BE8-EVENT-RADIUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-SECTION-RANGE.
*> USING coordinate, radius, first section out, last section out: the section box of one axis (2.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COORDINATE           BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 01 L-LOW                  BINARY-LONG.
 01 L-HIGH                 BINARY-LONG.
 PROCEDURE DIVISION USING L-COORDINATE L-RADIUS L-LOW L-HIGH.
     COMPUTE L-LOW = FUNCTION INTEGER((L-COORDINATE - L-RADIUS) / 16)
     COMPUTE L-HIGH = FUNCTION INTEGER((L-COORDINATE + L-RADIUS) / 16)
     GOBACK.
 END PROGRAM BE8-SECTION-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-LISTENER-IN.
*> USING listener x, y, z, event x, y, z (block positions), the listener radius, ok out: 2.3, the squared block distance must be at most radius * radius.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LX                   BINARY-LONG.
 01 L-LY                   BINARY-LONG.
 01 L-LZ                   BINARY-LONG.
 01 L-EX                   BINARY-LONG.
 01 L-EY                   BINARY-LONG.
 01 L-EZ                   BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-LX L-LY L-LZ L-EX L-EY L-EZ L-RADIUS L-OK.
     MOVE 0 TO L-OK
     IF (L-LX - L-EX) * (L-LX - L-EX) + (L-LY - L-EY) * (L-LY - L-EY) + (L-LZ - L-EZ) * (L-LZ - L-EZ) <= L-RADIUS * L-RADIUS
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM BE8-LISTENER-IN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-ORDER.
*> USING listeners (BINARY-LONG pairs of delivery mode, 0 immediate and 1 by distance, and squared distance), count, order out (the listener numbers, 1 based): 2.2 steps 4 and 5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-LISTENERS.
    05 L-L                 BINARY-LONG OCCURS 64 TIMES.
 01 L-COUNT                BINARY-LONG.
 01 L-ORDER.
    05 L-O                 BINARY-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-LISTENERS L-COUNT L-ORDER.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         IF L-L(WS-I * 2 - 1) = 0
             ADD 1 TO WS-N
             MOVE WS-I TO L-O(WS-N)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         IF L-L(WS-I * 2 - 1) = 1
             ADD 1 TO WS-N
             MOVE WS-I TO L-O(WS-N)
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > WS-N
         PERFORM VARYING WS-J FROM WS-I BY -1 UNTIL WS-J < 2
             IF L-L(L-O(WS-J - 1) * 2 - 1) = 1 AND L-L(L-O(WS-J) * 2 - 1) = 1 AND L-L(L-O(WS-J - 1) * 2) > L-L(L-O(WS-J) * 2)
                 MOVE L-O(WS-J) TO WS-T
                 MOVE L-O(WS-J - 1) TO L-O(WS-J)
                 MOVE WS-T TO L-O(WS-J - 1)
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM BE8-ORDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-REGISTER.
*> USING in a level, server level, block is an EntityBlock, the entity provides a listener, register out: 2.4.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-PROVIDER             BINARY-LONG.
 01 L-REGISTER             BINARY-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-SERVER L-BLOCK L-PROVIDER L-REGISTER.
     MOVE 0 TO L-REGISTER
     IF L-LEVEL = 1 AND L-SERVER = 1 AND L-BLOCK = 1 AND L-PROVIDER = 1
         MOVE 1 TO L-REGISTER
     END-IF
     GOBACK.
 END PROGRAM BE8-REGISTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-FREQUENCY.
*> USING game event name (X(48)), length, frequency out (0 to 15): getGameEventFrequency of 3.1, 0 for an event that is not listed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "step                  01".
    05 FILLER PIC X(24) VALUE "swim                  01".
    05 FILLER PIC X(24) VALUE "flap                  01".
    05 FILLER PIC X(24) VALUE "projectile_land       02".
    05 FILLER PIC X(24) VALUE "hit_ground            02".
    05 FILLER PIC X(24) VALUE "splash                02".
    05 FILLER PIC X(24) VALUE "bounce                02".
    05 FILLER PIC X(24) VALUE "item_interact_finish  03".
    05 FILLER PIC X(24) VALUE "projectile_shoot      03".
    05 FILLER PIC X(24) VALUE "instrument_play       03".
    05 FILLER PIC X(24) VALUE "entity_action         04".
    05 FILLER PIC X(24) VALUE "elytra_glide          04".
    05 FILLER PIC X(24) VALUE "unequip               04".
    05 FILLER PIC X(24) VALUE "entity_dismount       05".
    05 FILLER PIC X(24) VALUE "equip                 05".
    05 FILLER PIC X(24) VALUE "entity_interact       06".
    05 FILLER PIC X(24) VALUE "shear                 06".
    05 FILLER PIC X(24) VALUE "entity_mount          06".
    05 FILLER PIC X(24) VALUE "entity_damage         07".
    05 FILLER PIC X(24) VALUE "drink                 08".
    05 FILLER PIC X(24) VALUE "eat                   08".
    05 FILLER PIC X(24) VALUE "container_close       09".
    05 FILLER PIC X(24) VALUE "block_close           09".
    05 FILLER PIC X(24) VALUE "block_deactivate      09".
    05 FILLER PIC X(24) VALUE "block_detach          09".
    05 FILLER PIC X(24) VALUE "container_open        10".
    05 FILLER PIC X(24) VALUE "block_open            10".
    05 FILLER PIC X(24) VALUE "block_activate        10".
    05 FILLER PIC X(24) VALUE "block_attach          10".
    05 FILLER PIC X(24) VALUE "prime_fuse            10".
    05 FILLER PIC X(24) VALUE "note_block_play       10".
    05 FILLER PIC X(24) VALUE "block_change          11".
    05 FILLER PIC X(24) VALUE "block_destroy         12".
    05 FILLER PIC X(24) VALUE "fluid_pickup          12".
    05 FILLER PIC X(24) VALUE "block_place           13".
    05 FILLER PIC X(24) VALUE "fluid_place           13".
    05 FILLER PIC X(24) VALUE "entity_place          14".
    05 FILLER PIC X(24) VALUE "lightning_strike      14".
    05 FILLER PIC X(24) VALUE "teleport              14".
    05 FILLER PIC X(24) VALUE "entity_die            15".
    05 FILLER PIC X(24) VALUE "explode               15".
 01 FILLER REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 41 TIMES.
       10 WS-NAME            PIC X(22).
       10 WS-FREQ            PIC 99.
 01 WS-BARE                PIC X(48).
 01 WS-BARE-LENGTH         BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DIGITS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(48).
 01 L-LENGTH               BINARY-LONG.
 01 L-FREQUENCY            BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-LENGTH L-FREQUENCY.
     MOVE 0 TO L-FREQUENCY
     CALL "BE8-EVENT-NAME" USING L-NAME L-LENGTH WS-BARE WS-BARE-LENGTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 41
         IF WS-BARE = WS-NAME(WS-I)
             MOVE WS-FREQ(WS-I) TO L-FREQUENCY
         END-IF
     END-PERFORM
     IF WS-BARE-LENGTH > 9 AND WS-BARE(1:9) = "resonate_"
         COMPUTE WS-DIGITS = WS-BARE-LENGTH - 9
         IF WS-DIGITS <= 2 AND WS-BARE(10:WS-DIGITS) IS NUMERIC
             MOVE WS-BARE(10:WS-DIGITS) TO L-FREQUENCY
             IF L-FREQUENCY < 1 OR L-FREQUENCY > 15
                 MOVE 0 TO L-FREQUENCY
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE8-FREQUENCY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-RESONANCE.
*> USING frequency (1 to 15), event name out (X(48)), length out: getResonanceEventByFrequency of 3.1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EDIT                PIC Z9.
 LINKAGE SECTION.
 01 L-FREQUENCY            BINARY-LONG.
 01 L-NAME                 PIC X(48).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-FREQUENCY L-NAME L-LENGTH.
     MOVE L-FREQUENCY TO WS-EDIT
     MOVE SPACES TO L-NAME
     STRING "resonate_" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-NAME
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-NAME)) TO L-LENGTH
     GOBACK.
 END PROGRAM BE8-RESONANCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-STRENGTH.
*> USING distance (FLOAT-SHORT), listener radius, strength out: getRedstoneStrengthForDistance of 3.2, max(1, 15 - floor(15.0 / radius * distance)).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FLOOR               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DISTANCE             FLOAT-SHORT.
 01 L-RADIUS               BINARY-LONG.
 01 L-STRENGTH             BINARY-LONG.
 PROCEDURE DIVISION USING L-DISTANCE L-RADIUS L-STRENGTH.
     COMPUTE WS-FLOOR = FUNCTION INTEGER(15.0 / L-RADIUS * L-DISTANCE)
     COMPUTE L-STRENGTH = 15 - WS-FLOOR
     IF L-STRENGTH < 1
         MOVE 1 TO L-STRENGTH
     END-IF
     GOBACK.
 END PROGRAM BE8-STRENGTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-TRAVEL.
*> USING distance (FLOAT-SHORT), ticks out: calculateTravelTimeInTicks, floor(distance) (3.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DISTANCE             FLOAT-SHORT.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-DISTANCE L-TICKS.
     COMPUTE L-TICKS = FUNCTION INTEGER(L-DISTANCE)
     GOBACK.
 END PROGRAM BE8-TRAVEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-VALID.
*> USING event is listenable, the context has a source entity, it is a spectator, it is stepping carefully, the event is in ignore_vibrations_sneaking, the user can trigger avoid_vibration,
*> the entity is a server player, it dampens vibrations, the context has a block state, the state is in dampens_vibrations, valid out, criterion fired out: isValidVibration of 3.3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LISTENABLE           BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-SPECTATOR            BINARY-LONG.
 01 L-CAREFUL              BINARY-LONG.
 01 L-IGNORED              BINARY-LONG.
 01 L-AVOID                BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-DAMPENS              BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-STATE-DAMPENS        BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-CRITERION            BINARY-LONG.
 PROCEDURE DIVISION USING L-LISTENABLE L-ENTITY L-SPECTATOR L-CAREFUL L-IGNORED L-AVOID L-PLAYER L-DAMPENS L-STATE L-STATE-DAMPENS L-VALID L-CRITERION.
     MOVE 0 TO L-VALID L-CRITERION
     IF L-LISTENABLE = 0
         GOBACK
     END-IF
     IF L-ENTITY = 1
         IF L-SPECTATOR = 1
             GOBACK
         END-IF
         IF L-CAREFUL = 1 AND L-IGNORED = 1
             IF L-AVOID = 1 AND L-PLAYER = 1
                 MOVE 1 TO L-CRITERION
             END-IF
             GOBACK
         END-IF
         IF L-DAMPENS = 1
             GOBACK
         END-IF
     END-IF
     IF L-STATE = 1 AND L-STATE-DAMPENS = 1
         GOBACK
     END-IF
     MOVE 1 TO L-VALID
     GOBACK.
 END PROGRAM BE8-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-HANDLE.
*> USING index, the event is valid, the user has a position, it can receive the event, the vibration is occluded, step out (0 accepted, 1 a vibration is in flight, 2 not valid,
*> 3 no position, 4 cannot receive, 5 occluded): the order of the checks of 3.5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 01 L-POSITION             BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-OCCLUDED             BINARY-LONG.
 01 L-STEP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-VALID L-POSITION L-CAN L-OCCLUDED L-STEP.
     MOVE 0 TO L-STEP
     EVALUATE TRUE
         WHEN BE-XI(L-INDEX, 2) = 1
             MOVE 1 TO L-STEP
         WHEN L-VALID = 0
             MOVE 2 TO L-STEP
         WHEN L-POSITION = 0
             MOVE 3 TO L-STEP
         WHEN L-CAN = 0
             MOVE 4 TO L-STEP
         WHEN L-OCCLUDED = 1
             MOVE 5 TO L-STEP
     END-EVALUATE
     GOBACK.
 END PROGRAM BE8-HANDLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-OCCLUDED.
*> USING the results of the six rays (1 a ray met an occluding block; BINARY-LONG table), occluded out: occluded only when all six met one (3.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-HITS.
    05 L-H                 BINARY-LONG OCCURS 6 TIMES.
 01 L-OCCLUDED             BINARY-LONG.
 PROCEDURE DIVISION USING L-HITS L-OCCLUDED.
     MOVE 1 TO L-OCCLUDED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         IF L-H(WS-I) = 0
             MOVE 0 TO L-OCCLUDED
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BE8-OCCLUDED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-SNAP.
*> USING coordinate (FLOAT-LONG), snapped out (FLOAT-LONG): the centre of the block, floor(coordinate) + 0.5 (3.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COORDINATE           FLOAT-LONG.
 01 L-SNAPPED              FLOAT-LONG.
 PROCEDURE DIVISION USING L-COORDINATE L-SNAPPED.
     COMPUTE L-SNAPPED = FUNCTION INTEGER(L-COORDINATE) + 0.5
     GOBACK.
 END PROGRAM BE8-SNAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-ADD-CANDIDATE.
*> USING index, game time (BINARY-DOUBLE), event key (X(48)), length, distance (FLOAT-SHORT), x, y, z (FLOAT-LONG), has source, source UUID (BINARY-LONG table of 4), replaced out:
*> VibrationSelector.addCandidate of 3.7, only in the same tick and when closer, or equally close with a strictly higher frequency.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-OLD                 PIC X(48).
 01 WS-OLD-LENGTH          BINARY-LONG.
 01 WS-OLD-FREQ            BINARY-LONG.
 01 WS-NEW-FREQ            BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-TIME                 BINARY-DOUBLE.
 01 L-KEY                  PIC X(48).
 01 L-LENGTH               BINARY-LONG.
 01 L-DISTANCE             FLOAT-SHORT.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-UUID.
    05 L-U                 BINARY-LONG OCCURS 4 TIMES.
 01 L-REPLACED             BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-TIME L-KEY L-LENGTH L-DISTANCE L-X L-Y L-Z L-SOURCE L-UUID L-REPLACED.
     MOVE 0 TO L-REPLACED
     IF BE-XI(L-INDEX, 7) = 0
         MOVE 1 TO L-REPLACED
     ELSE
         IF L-TIME = BE-SEED(L-INDEX)
             MOVE BE-XT(L-INDEX, 2) TO WS-OLD
             MOVE BE-XI(L-INDEX, 8) TO WS-OLD-LENGTH
             CALL "BE8-FREQUENCY" USING WS-OLD WS-OLD-LENGTH WS-OLD-FREQ
             CALL "BE8-FREQUENCY" USING L-KEY L-LENGTH WS-NEW-FREQ
             IF L-DISTANCE < BE-XF(L-INDEX, 2) OR (L-DISTANCE = BE-XF(L-INDEX, 2) AND WS-NEW-FREQ > WS-OLD-FREQ)
                 MOVE 1 TO L-REPLACED
             END-IF
         END-IF
     END-IF
     IF L-REPLACED = 1
         MOVE 1 TO BE-XI(L-INDEX, 7)
         MOVE L-KEY TO BE-XT(L-INDEX, 2)
         MOVE L-LENGTH TO BE-XI(L-INDEX, 8)
         MOVE L-DISTANCE TO BE-XF(L-INDEX, 2)
         MOVE L-X TO BE-XD(L-INDEX, 4)
         MOVE L-Y TO BE-XD(L-INDEX, 5)
         MOVE L-Z TO BE-XD(L-INDEX, 6)
         MOVE L-SOURCE TO BE-XI(L-INDEX, 9)
         MOVE 0 TO BE-XI(L-INDEX, 10)
         MOVE L-TIME TO BE-SEED(L-INDEX)
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
             MOVE L-U(WS-K) TO BE-UUID(L-INDEX, 8 + WS-K)
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM BE8-ADD-CANDIDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-CHOSEN.
*> USING index, game time (BINARY-DOUBLE), chosen out: chosenCandidate(now) of 3.7, a candidate is chosen when its tick is earlier than now.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-TIME                 BINARY-DOUBLE.
 01 L-CHOSEN               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-TIME L-CHOSEN.
     MOVE 0 TO L-CHOSEN
     IF BE-XI(L-INDEX, 7) = 1 AND BE-SEED(L-INDEX) < L-TIME
         MOVE 1 TO L-CHOSEN
     END-IF
     GOBACK.
 END PROGRAM BE8-CHOSEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-TICK.
*> USING index, game time (BINARY-DOUBLE), the 3 by 3 chunks are loaded and ticking, selected out, delivered out, data changed out: VibrationSystem.Ticker.tick of 3.8 and receiveVibration of 3.10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-CHOSEN              BINARY-LONG.
 01 WS-TICKING             BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-TIME                 BINARY-DOUBLE.
 01 L-CHUNKS               BINARY-LONG.
 01 L-SELECTED             BINARY-LONG.
 01 L-DELIVERED            BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-TIME L-CHUNKS L-SELECTED L-DELIVERED L-CHANGED.
     MOVE 0 TO L-SELECTED L-DELIVERED L-CHANGED
     IF BE-XI(L-INDEX, 2) = 0
         CALL "BE8-CHOSEN" USING L-INDEX L-TIME WS-CHOSEN
         IF WS-CHOSEN = 1
             MOVE 1 TO BE-XI(L-INDEX, 2) L-SELECTED L-CHANGED
             MOVE BE-XT(L-INDEX, 2) TO BE-XT(L-INDEX, 1)
             MOVE BE-XI(L-INDEX, 8) TO BE-XI(L-INDEX, 3)
             MOVE BE-XF(L-INDEX, 2) TO BE-XF(L-INDEX, 1)
             MOVE BE-XD(L-INDEX, 4) TO BE-XD(L-INDEX, 1)
             MOVE BE-XD(L-INDEX, 5) TO BE-XD(L-INDEX, 2)
             MOVE BE-XD(L-INDEX, 6) TO BE-XD(L-INDEX, 3)
             MOVE BE-XI(L-INDEX, 9) TO BE-XI(L-INDEX, 4)
             MOVE BE-XI(L-INDEX, 10) TO BE-XI(L-INDEX, 5)
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                 MOVE BE-UUID(L-INDEX, 8 + WS-K) TO BE-UUID(L-INDEX, WS-K)
                 MOVE BE-UUID(L-INDEX, 12 + WS-K) TO BE-UUID(L-INDEX, 4 + WS-K)
             END-PERFORM
             COMPUTE BE-XI(L-INDEX, 6) = FUNCTION INTEGER(BE-XF(L-INDEX, 1))
             MOVE 0 TO BE-XI(L-INDEX, 7)
             MOVE -1 TO BE-SEED(L-INDEX)
         END-IF
     END-IF
     IF BE-XI(L-INDEX, 2) = 1
         MOVE 0 TO WS-TICKING
         IF BE-XI(L-INDEX, 6) > 0
             MOVE 1 TO WS-TICKING
         END-IF
         IF BE-XI(L-INDEX, 6) > 0
             SUBTRACT 1 FROM BE-XI(L-INDEX, 6)
         END-IF
         IF BE-XI(L-INDEX, 6) <= 0
             MOVE 0 TO WS-TICKING
             IF L-CHUNKS = 1
                 MOVE 1 TO WS-TICKING L-DELIVERED
                 MOVE 0 TO BE-XI(L-INDEX, 2)
             END-IF
         END-IF
         IF WS-TICKING = 1
             MOVE 1 TO L-CHANGED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE8-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-RELOAD.
*> USING index, fraction out (FLOAT-LONG): the share of the way the reloaded particle is sent at, 1 - T / total with total floor(distance); a total of 0 counts as arrived (3.9).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-TOTAL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-FRACTION             FLOAT-LONG.
 PROCEDURE DIVISION USING L-INDEX L-FRACTION.
     COMPUTE WS-TOTAL = FUNCTION INTEGER(BE-XF(L-INDEX, 1))
     MOVE 1.0 TO L-FRACTION
     IF WS-TOTAL > 0
         COMPUTE L-FRACTION = 1.0 - BE-XI(L-INDEX, 6) / WS-TOTAL
     END-IF
     GOBACK.
 END PROGRAM BE8-RELOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-VINFO-WRITE.
*> USING index, which (1 the vibration in flight, 2 the selector candidate), PB-BUFFER: the compound payload of a VibrationInfo (3.4): game_event, distance, pos, source, projectile_owner.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-DISTANCE            FLOAT-SHORT.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-U-SOURCE            BINARY-LONG.
 01 WS-U-OWNER             BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-T-DOUBLE            BINARY-LONG VALUE 6.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-NONAME              BINARY-LONG VALUE -1.
 01 WS-DUMMY               PIC X.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-WHICH                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-WHICH PB-BUFFER.
     IF L-WHICH = 1
         MOVE BE-XT(L-INDEX, 1) TO WS-KEY
         MOVE BE-XI(L-INDEX, 3) TO WS-KEY-LENGTH
         MOVE BE-XF(L-INDEX, 1) TO WS-DISTANCE
         MOVE BE-XD(L-INDEX, 1) TO WS-X
         MOVE BE-XD(L-INDEX, 2) TO WS-Y
         MOVE BE-XD(L-INDEX, 3) TO WS-Z
         MOVE BE-XI(L-INDEX, 4) TO WS-SOURCE
         MOVE BE-XI(L-INDEX, 5) TO WS-OWNER
         MOVE 1 TO WS-U-SOURCE
         MOVE 5 TO WS-U-OWNER
     ELSE
         MOVE BE-XT(L-INDEX, 2) TO WS-KEY
         MOVE BE-XI(L-INDEX, 8) TO WS-KEY-LENGTH
         MOVE BE-XF(L-INDEX, 2) TO WS-DISTANCE
         MOVE BE-XD(L-INDEX, 4) TO WS-X
         MOVE BE-XD(L-INDEX, 5) TO WS-Y
         MOVE BE-XD(L-INDEX, 6) TO WS-Z
         MOVE BE-XI(L-INDEX, 9) TO WS-SOURCE
         MOVE BE-XI(L-INDEX, 10) TO WS-OWNER
         MOVE 9 TO WS-U-SOURCE
         MOVE 13 TO WS-U-OWNER
     END-IF
     MOVE "game_event" TO WN
     CALL "BE6-W-STR" USING PB-BUFFER WN WS-KEY WS-KEY-LENGTH
     MOVE "distance" TO WN
     MOVE 8 TO WL
     CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WL WS-DISTANCE
     MOVE "pos" TO WN
     MOVE 3 TO WL
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-DOUBLE WS-THREE
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WS-DUMMY WS-NONAME WS-X
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WS-DUMMY WS-NONAME WS-Y
     CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WS-DUMMY WS-NONAME WS-Z
     IF WS-SOURCE = 1
         MOVE "source" TO WN
         MOVE 6 TO WL
         CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-FOUR BE-UUID(L-INDEX, WS-U-SOURCE)
     END-IF
     IF WS-OWNER = 1
         MOVE "projectile_owner" TO WN
         MOVE 16 TO WL
         CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-FOUR BE-UUID(L-INDEX, WS-U-OWNER)
     END-IF
     GOBACK.
 END PROGRAM BE8-VINFO-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-LISTENER-SAVE.
*> USING index, PB-BUFFER: the listener compound of 3.4: event when a vibration is in flight, selector (event of the candidate, tick -1 without one), event_delay.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-LONG                BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX PB-BUFFER.
     MOVE "listener" TO WN
     MOVE 8 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     IF BE-XI(L-INDEX, 2) = 1
         MOVE "event" TO WN
         MOVE 5 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         CALL "BE8-VINFO-WRITE" USING L-INDEX WS-ONE PB-BUFFER
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-IF
     MOVE "selector" TO WN
     MOVE 8 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE -1 TO WS-LONG
     IF BE-XI(L-INDEX, 7) = 1
         MOVE "event" TO WN
         MOVE 5 TO WL
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
         CALL "BE8-VINFO-WRITE" USING L-INDEX WS-TWO PB-BUFFER
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         MOVE BE-SEED(L-INDEX) TO WS-LONG
     END-IF
     MOVE "tick" TO WN
     CALL "BE7-W-LONG" USING PB-BUFFER WN WS-LONG
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE "event_delay" TO WN
     CALL "BE6-W-INT" USING PB-BUFFER WN BE-XI(L-INDEX, 6)
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     GOBACK.
 END PROGRAM BE8-LISTENER-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-VINFO-READ.
*> USING index, which (1 or 2), PB-BUFFER, valid out: reads the compound payload of a VibrationInfo into the cells of the vibration or the candidate; valid is 1 when game_event and pos were read.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-C32                 BINARY-LONG VALUE 32.
 01 WS-C64                 BINARY-LONG VALUE 64.
 01 WS-C4                  BINARY-LONG VALUE 4.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ETYPE               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ICOUNT              BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-HAS-EVENT           BINARY-LONG.
 01 WS-HAS-POS             BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-DISTANCE            FLOAT-SHORT.
 01 WS-DS.
    05 WS-D                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-INTS.
    05 WS-INT              BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-WHICH                BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-WHICH PB-BUFFER L-VALID.
     MOVE 0 TO WS-HAS-EVENT WS-HAS-POS WS-SOURCE WS-OWNER L-VALID
     MOVE SPACES TO WS-KEY
     MOVE 0 TO WS-KEY-LENGTH WS-DISTANCE
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-C32 WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "game_event" AND WS-TYPE = 8
                 MOVE 1 TO WS-HAS-EVENT
                 CALL "BE6-READ-TEXT" USING PB-BUFFER WS-KEY WS-C64 WS-KEY-LENGTH
             WHEN WN = "distance" AND WS-TYPE = 5
                 CALL "PB-GET-FLOAT" USING PB-BUFFER WS-DISTANCE
             WHEN WN = "pos" AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ETYPE WS-COUNT
                 IF WS-ETYPE = 6 AND WS-COUNT = 3
                     MOVE 1 TO WS-HAS-POS
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
                         CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-D(WS-K)
                     END-PERFORM
                 ELSE
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-COUNT OR PB-ERROR = 1
                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-ETYPE
                     END-PERFORM
                 END-IF
             WHEN WN = "source" AND WS-TYPE = 11
                 CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-C4 WS-ICOUNT WS-INTS
                 IF WS-ICOUNT = 4
                     MOVE 1 TO WS-SOURCE
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                         MOVE WS-INT(WS-K) TO BE-UUID(L-INDEX, (L-WHICH - 1) * 8 + WS-K)
                     END-PERFORM
                 END-IF
             WHEN WN = "projectile_owner" AND WS-TYPE = 11
                 CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-C4 WS-ICOUNT WS-INTS
                 IF WS-ICOUNT = 4
                     MOVE 1 TO WS-OWNER
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                         MOVE WS-INT(WS-K) TO BE-UUID(L-INDEX, (L-WHICH - 1) * 8 + 4 + WS-K)
                     END-PERFORM
                 END-IF
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     IF WS-HAS-EVENT = 1 AND WS-HAS-POS = 1
         MOVE 1 TO L-VALID
         IF L-WHICH = 1
             MOVE WS-KEY TO BE-XT(L-INDEX, 1)
             MOVE WS-KEY-LENGTH TO BE-XI(L-INDEX, 3)
             MOVE WS-DISTANCE TO BE-XF(L-INDEX, 1)
             MOVE WS-D(1) TO BE-XD(L-INDEX, 1)
             MOVE WS-D(2) TO BE-XD(L-INDEX, 2)
             MOVE WS-D(3) TO BE-XD(L-INDEX, 3)
             MOVE WS-SOURCE TO BE-XI(L-INDEX, 4)
             MOVE WS-OWNER TO BE-XI(L-INDEX, 5)
         ELSE
             MOVE WS-KEY TO BE-XT(L-INDEX, 2)
             MOVE WS-KEY-LENGTH TO BE-XI(L-INDEX, 8)
             MOVE WS-DISTANCE TO BE-XF(L-INDEX, 2)
             MOVE WS-D(1) TO BE-XD(L-INDEX, 4)
             MOVE WS-D(2) TO BE-XD(L-INDEX, 5)
             MOVE WS-D(3) TO BE-XD(L-INDEX, 6)
             MOVE WS-SOURCE TO BE-XI(L-INDEX, 9)
             MOVE WS-OWNER TO BE-XI(L-INDEX, 10)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE8-VINFO-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-LISTENER-LOAD.
*> USING index, PB-BUFFER: reads the listener compound payload (3.4): a missing selector makes the whole value fresh data; an unreadable event counts as absent; reloadVibrationParticle is set.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WN1                    PIC X(32).
 01 WN2                    PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-C32                 BINARY-LONG VALUE 32.
 01 WS-T1                  BINARY-LONG.
 01 WS-T2                  BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-VALID               BINARY-LONG.
 01 WS-SELECTOR            BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX PB-BUFFER.
     MOVE 0 TO WS-SELECTOR WS-DELAY
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 11
         MOVE 0 TO BE-XI(L-INDEX, WS-I)
     END-PERFORM
     MOVE SPACES TO BE-XT(L-INDEX, 1) BE-XT(L-INDEX, 2)
     MOVE -1 TO BE-SEED(L-INDEX)
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN1
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-T1 WN1 WS-C32 WL
         IF WS-T1 = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN1 = "event" AND WS-T1 = 10
                 CALL "BE8-VINFO-READ" USING L-INDEX WS-ONE PB-BUFFER WS-VALID
                 MOVE WS-VALID TO BE-XI(L-INDEX, 2)
             WHEN WN1 = "selector" AND WS-T1 = 10
                 MOVE 1 TO WS-SELECTOR
                 PERFORM UNTIL PB-ERROR = 1
                     MOVE SPACES TO WN2
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-T2 WN2 WS-C32 WL
                     IF WS-T2 = 0
                         EXIT PERFORM
                     END-IF
                     EVALUATE TRUE
                         WHEN WN2 = "event" AND WS-T2 = 10
                             CALL "BE8-VINFO-READ" USING L-INDEX WS-TWO PB-BUFFER WS-VALID
                             MOVE WS-VALID TO BE-XI(L-INDEX, 7)
                         WHEN WN2 = "tick" AND WS-T2 = 4
                             CALL "PB-GET-LONG" USING PB-BUFFER BE-SEED(L-INDEX)
                         WHEN OTHER
                             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-T2
                     END-EVALUATE
                 END-PERFORM
             WHEN WN1 = "event_delay" AND WS-T1 = 3
                 CALL "PB-GET-INT" USING PB-BUFFER WS-DELAY
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-T1
         END-EVALUATE
     END-PERFORM
     IF WS-SELECTOR = 0
         PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 10
             MOVE 0 TO BE-XI(L-INDEX, WS-I)
         END-PERFORM
         MOVE -1 TO BE-SEED(L-INDEX)
     ELSE
         IF WS-DELAY > 0
             MOVE WS-DELAY TO BE-XI(L-INDEX, 6)
         END-IF
     END-IF
     MOVE 1 TO BE-XI(L-INDEX, 11)
     GOBACK.
 END PROGRAM BE8-LISTENER-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-SENSOR-CAN.
*> USING the event is at the sensor own position, it is a block destroy or place, the event frequency, the block phase (0 inactive, 1 active, 2 cooldown), calibrated, the signal behind the block,
*> ok out: canReceiveVibration of 4.2 and 5.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OWN                  BINARY-LONG.
 01 L-DESTROY-PLACE        BINARY-LONG.
 01 L-FREQUENCY            BINARY-LONG.
 01 L-PHASE                BINARY-LONG.
 01 L-CALIBRATED           BINARY-LONG.
 01 L-BACK                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-OWN L-DESTROY-PLACE L-FREQUENCY L-PHASE L-CALIBRATED L-BACK L-OK.
     MOVE 0 TO L-OK
     IF L-OWN = 1 AND L-DESTROY-PLACE = 1
         GOBACK
     END-IF
     IF L-FREQUENCY = 0
         GOBACK
     END-IF
     IF L-CALIBRATED = 1 AND L-BACK NOT = 0 AND L-FREQUENCY NOT = L-BACK
         GOBACK
     END-IF
     IF L-PHASE = 0
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM BE8-SENSOR-CAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-SENSOR-RECEIVE.
*> USING index, phase, event key (X(48)), length, distance (FLOAT-SHORT), listener radius, power out, activate out: onReceiveVibration of 4.2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-FREQUENCY           BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-PHASE                BINARY-LONG.
 01 L-KEY                  PIC X(48).
 01 L-LENGTH               BINARY-LONG.
 01 L-DISTANCE             FLOAT-SHORT.
 01 L-RADIUS               BINARY-LONG.
 01 L-POWER                BINARY-LONG.
 01 L-ACTIVATE             BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-PHASE L-KEY L-LENGTH L-DISTANCE L-RADIUS L-POWER L-ACTIVATE.
     MOVE 0 TO L-POWER L-ACTIVATE
     IF L-PHASE = 0
         CALL "BE8-FREQUENCY" USING L-KEY L-LENGTH WS-FREQUENCY
         MOVE WS-FREQUENCY TO BE-XI(L-INDEX, 1)
         CALL "BE8-STRENGTH" USING L-DISTANCE L-RADIUS L-POWER
         MOVE 1 TO L-ACTIVATE
     END-IF
     GOBACK.
 END PROGRAM BE8-SENSOR-RECEIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-PHASE-TICK.
*> USING phase, not waterlogged, next phase out, power out, scheduled delay out, stop sound out: SculkSensorBlock.tick of 4.3.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PHASE                BINARY-LONG.
 01 L-DRY                  BINARY-LONG.
 01 L-NEXT                 BINARY-LONG.
 01 L-POWER                BINARY-LONG.
 01 L-DELAY                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-PHASE L-DRY L-NEXT L-POWER L-DELAY L-SOUND.
     MOVE L-PHASE TO L-NEXT
     MOVE 0 TO L-POWER L-DELAY L-SOUND
     EVALUATE L-PHASE
         WHEN 1
             MOVE 2 TO L-NEXT
             MOVE 10 TO L-DELAY
         WHEN 2
             MOVE 0 TO L-NEXT
             MOVE L-DRY TO L-SOUND
     END-EVALUATE
     GOBACK.
 END PROGRAM BE8-PHASE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-PITCH.
*> USING frequency (0 to 15), pitch out (FLOAT-SHORT): RESONANCE_PITCH_BEND, 2 ^ ((note - 12) / 12) (4.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NOTES               PIC X(32) VALUE "00000204060709101214151819212224".
 01 FILLER REDEFINES WS-NOTES.
    05 WS-NOTE             PIC 99 OCCURS 16 TIMES.
 LINKAGE SECTION.
 01 L-FREQUENCY            BINARY-LONG.
 01 L-PITCH                FLOAT-SHORT.
 PROCEDURE DIVISION USING L-FREQUENCY L-PITCH.
     COMPUTE L-PITCH = 2 ** ((WS-NOTE(L-FREQUENCY + 1) - 12) / 12)
     GOBACK.
 END PROGRAM BE8-PITCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-SENSOR-OUTPUT.
*> USING index, phase, comparator signal out: last_vibration_frequency while the phase is active (4.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-PHASE                BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-PHASE L-SIGNAL.
     MOVE 0 TO L-SIGNAL
     IF L-PHASE = 1
         MOVE BE-XI(L-INDEX, 1) TO L-SIGNAL
     END-IF
     GOBACK.
 END PROGRAM BE8-SENSOR-OUTPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-STEP-ON.
*> USING phase, the entity is a warden, a sensor entity exists, canReceive holds for the step, force out: SculkSensorBlock.stepOn of 4.4.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PHASE                BINARY-LONG.
 01 L-WARDEN               BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 01 L-FORCE                BINARY-LONG.
 PROCEDURE DIVISION USING L-PHASE L-WARDEN L-FOUND L-CAN L-FORCE.
     MOVE 0 TO L-FORCE
     IF L-PHASE = 0 AND L-WARDEN = 0 AND L-FOUND = 1 AND L-CAN = 1
         MOVE 1 TO L-FORCE
     END-IF
     GOBACK.
 END PROGRAM BE8-STEP-ON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-RADIUS.
*> USING type, listener radius out: 8 for the sensor and the shrieker, 16 for the calibrated sensor (3.3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-RADIUS.
     MOVE 8 TO L-RADIUS
     IF L-TYPE = 35
         MOVE 16 TO L-RADIUS
     END-IF
     GOBACK.
 END PROGRAM BE8-RADIUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-ACTIVE-TICKS.
*> USING calibrated, active ticks out (30, 10 for the calibrated sensor): 4.3 and 5.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CALIBRATED           BINARY-LONG.
 01 L-TICKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-CALIBRATED L-TICKS.
     MOVE 30 TO L-TICKS
     IF L-CALIBRATED = 1
         MOVE 10 TO L-TICKS
     END-IF
     GOBACK.
 END PROGRAM BE8-ACTIVE-TICKS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-CAL-SIGNAL.
*> USING the direction is the facing, power, signal out: the calibrated sensor output of 5, 0 toward its facing.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACING               BINARY-LONG.
 01 L-POWER                BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-FACING L-POWER L-SIGNAL.
     MOVE L-POWER TO L-SIGNAL
     IF L-FACING = 1
         MOVE 0 TO L-SIGNAL
     END-IF
     GOBACK.
 END PROGRAM BE8-CAL-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-SHRIEKER-CAN.
*> USING the block is shrieking, the source resolves to a player, ok out: the shrieker canReceiveVibration of 6.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SHRIEKING            BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-SHRIEKING L-PLAYER L-OK.
     MOVE 0 TO L-OK
     IF L-SHRIEKING = 0 AND L-PLAYER = 1
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM BE8-SHRIEKER-CAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-SHRIEKER-PLAYER.
*> USING a projectile owner is given, the owner is a player, the source entity is a player, which out (1 the owner, 2 the source, 0 none): onReceiveVibration of 6.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-OWNER-GIVEN          BINARY-LONG.
 01 L-OWNER-PLAYER         BINARY-LONG.
 01 L-SOURCE-PLAYER        BINARY-LONG.
 01 L-WHICH                BINARY-LONG.
 PROCEDURE DIVISION USING L-OWNER-GIVEN L-OWNER-PLAYER L-SOURCE-PLAYER L-WHICH.
     MOVE 0 TO L-WHICH
     IF L-OWNER-GIVEN = 1 AND L-OWNER-PLAYER = 1
         MOVE 1 TO L-WHICH
     ELSE
         IF L-SOURCE-PLAYER = 1
             MOVE 2 TO L-WHICH
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE8-SHRIEKER-PLAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-SHRIEKER-REMOVE.
*> USING the removed state was shrieking, server level, respond out: preRemoveSideEffects of 6 runs tryRespond once.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SHRIEKING            BINARY-LONG.
 01 L-SERVER               BINARY-LONG.
 01 L-RESPOND              BINARY-LONG.
 PROCEDURE DIVISION USING L-SHRIEKING L-SERVER L-RESPOND.
     MOVE 0 TO L-RESPOND
     IF L-SHRIEKING = 1 AND L-SERVER = 1
         MOVE 1 TO L-RESPOND
     END-IF
     GOBACK.
 END PROGRAM BE8-SHRIEKER-REMOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-KEYS-SAVE.
*> USING index, type, PB-BUFFER: the keys of the sensors (last_vibration_frequency) and the shrieker (warning_level) then the listener (4.1, 6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WN                     PIC X(32).
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-TYPE PB-BUFFER.
     MOVE "last_vibration_frequency" TO WN
     IF L-TYPE = 37
         MOVE "warning_level" TO WN
     END-IF
     CALL "BE6-W-INT" USING PB-BUFFER WN BE-XI(L-INDEX, 1)
     CALL "BE8-LISTENER-SAVE" USING L-INDEX PB-BUFFER
     GOBACK.
 END PROGRAM BE8-KEYS-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-KEYS-LOAD.
*> USING index, key name (X(32)), tag, PB-BUFFER, handled out: the keys of the three vibration users.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-TAG                  BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-NAME L-TAG PB-BUFFER L-HANDLED.
     MOVE 0 TO L-HANDLED
     IF L-TAG = 3 AND ((L-NAME = "last_vibration_frequency" AND BE-TYPE(L-INDEX) NOT = 37) OR (L-NAME = "warning_level" AND BE-TYPE(L-INDEX) = 37))
         MOVE 1 TO L-HANDLED
         CALL "PB-GET-INT" USING PB-BUFFER BE-XI(L-INDEX, 1)
     END-IF
     IF L-NAME = "listener" AND L-TAG = 10
         MOVE 1 TO L-HANDLED
         CALL "BE8-LISTENER-LOAD" USING L-INDEX PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM BE8-KEYS-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-CAT-HANDLE.
*> USING the event is entity_die, the source is a LivingEntity, its experience was already consumed, it drops experience, its experience reward, cursor charge out, skip experience out,
*> bloom out, advancement out, accepted out: CatalystListener.handleGameEvent of 7.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIE                  BINARY-LONG.
 01 L-LIVING               BINARY-LONG.
 01 L-CONSUMED             BINARY-LONG.
 01 L-DROPS                BINARY-LONG.
 01 L-REWARD               BINARY-LONG.
 01 L-CHARGE               BINARY-LONG.
 01 L-SKIP                 BINARY-LONG.
 01 L-BLOOM                BINARY-LONG.
 01 L-ADVANCEMENT          BINARY-LONG.
 01 L-ACCEPTED             BINARY-LONG.
 PROCEDURE DIVISION USING L-DIE L-LIVING L-CONSUMED L-DROPS L-REWARD L-CHARGE L-SKIP L-BLOOM L-ADVANCEMENT L-ACCEPTED.
     MOVE 0 TO L-CHARGE L-SKIP L-BLOOM L-ADVANCEMENT L-ACCEPTED
     IF L-DIE = 1 AND L-LIVING = 1
         MOVE 1 TO L-ACCEPTED
         IF L-CONSUMED = 0
             IF L-DROPS = 1 AND L-REWARD > 0
                 MOVE L-REWARD TO L-CHARGE
                 MOVE 1 TO L-ADVANCEMENT
             END-IF
             MOVE 1 TO L-SKIP L-BLOOM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE8-CAT-HANDLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-ADD-CURSORS.
*> USING index, x, y, z, amount: SculkSpreader.addCursors of 7.3, cursors of at most 1000 charge with decay_delay 1, update_delay 0 and no facings; a 33rd cursor is dropped.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-REST                BINARY-LONG.
 01 WS-CHARGE              BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-X L-Y L-Z L-AMOUNT.
     MOVE L-AMOUNT TO WS-REST
     PERFORM UNTIL WS-REST <= 0
         MOVE WS-REST TO WS-CHARGE
         IF WS-CHARGE > 1000
             MOVE 1000 TO WS-CHARGE
         END-IF
         IF BE-XI(L-INDEX, 1) < 32
             COMPUTE WS-B = BE-XI(L-INDEX, 1) * 7
             MOVE L-X TO BE-UUID(L-INDEX, WS-B + 1)
             MOVE L-Y TO BE-UUID(L-INDEX, WS-B + 2)
             MOVE L-Z TO BE-UUID(L-INDEX, WS-B + 3)
             MOVE WS-CHARGE TO BE-UUID(L-INDEX, WS-B + 4)
             MOVE 1 TO BE-UUID(L-INDEX, WS-B + 5)
             MOVE 0 TO BE-UUID(L-INDEX, WS-B + 6)
             MOVE -1 TO BE-UUID(L-INDEX, WS-B + 7)
             ADD 1 TO BE-XI(L-INDEX, 1)
         END-IF
         SUBTRACT WS-CHARGE FROM WS-REST
     END-PERFORM
     GOBACK.
 END PROGRAM BE8-ADD-CURSORS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-CAT-SAVE.
*> USING index, PB-BUFFER: the cursors list of 7.1 (an empty list when there are none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-T-STRING            BINARY-LONG VALUE 8.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-I                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-MASK                BINARY-LONG.
 01 WS-NONAME              BINARY-LONG VALUE -1.
 01 WS-DUMMY               PIC X.
 01 WS-TEXT                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX PB-BUFFER.
     MOVE "cursors" TO WN
     MOVE 7 TO WL
     MOVE BE-XI(L-INDEX, 1) TO WS-COUNT
     IF WS-COUNT = 0
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-ZERO WS-COUNT
     ELSE
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-COUNT
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         COMPUTE WS-B = (WS-I - 1) * 7
         MOVE "pos" TO WN
         MOVE 3 TO WL
         CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-THREE BE-UUID(L-INDEX, WS-B + 1)
         MOVE "charge" TO WN
         CALL "BE6-W-INT" USING PB-BUFFER WN BE-UUID(L-INDEX, WS-B + 4)
         MOVE "decay_delay" TO WN
         CALL "BE6-W-INT" USING PB-BUFFER WN BE-UUID(L-INDEX, WS-B + 5)
         MOVE "update_delay" TO WN
         CALL "BE6-W-INT" USING PB-BUFFER WN BE-UUID(L-INDEX, WS-B + 6)
         MOVE BE-UUID(L-INDEX, WS-B + 7) TO WS-MASK
         IF WS-MASK >= 0
             MOVE "facings" TO WN
             MOVE 7 TO WL
             MOVE 0 TO WS-LENGTH
             PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 5
                 IF FUNCTION MOD(FUNCTION INTEGER(WS-MASK / (2 ** WS-D)), 2) = 1
                     ADD 1 TO WS-LENGTH
                 END-IF
             END-PERFORM
             CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-STRING WS-LENGTH
             PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 5
                 IF FUNCTION MOD(FUNCTION INTEGER(WS-MASK / (2 ** WS-D)), 2) = 1
                     MOVE SPACES TO WS-TEXT
                     EVALUATE WS-D
                         WHEN 0
                             MOVE "down" TO WS-TEXT
                         WHEN 1
                             MOVE "up" TO WS-TEXT
                         WHEN 2
                             MOVE "north" TO WS-TEXT
                         WHEN 3
                             MOVE "south" TO WS-TEXT
                         WHEN 4
                             MOVE "west" TO WS-TEXT
                         WHEN 5
                             MOVE "east" TO WS-TEXT
                     END-EVALUATE
                     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WL
                     CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-DUMMY WS-NONAME WS-TEXT WL
                 END-IF
             END-PERFORM
         END-IF
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-PERFORM
     GOBACK.
 END PROGRAM BE8-CAT-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-CAT-LOAD.
*> USING index, PB-BUFFER: reads the cursors list (7.1). An entry needs pos; charge 0 to 1000 (default 0), decay_delay 0 to 1 (default 1), update_delay 0 or more (default 0), facings a list
*> of direction names. A list with a bad entry, more than 32 entries or the wrong element type reads as empty.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-C32                 BINARY-LONG VALUE 32.
 01 WS-C64                 BINARY-LONG VALUE 64.
 01 WS-C3                  BINARY-LONG VALUE 3.
 01 WS-ETYPE               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ICOUNT              BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FAIL                BINARY-LONG.
 01 WS-HAS-POS             BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-FTYPE               BINARY-LONG.
 01 WS-FCOUNT              BINARY-LONG.
 01 WS-TEXT                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-MASK                BINARY-LONG.
 01 WS-INTS.
    05 WS-INT              BINARY-LONG OCCURS 3 TIMES.
 01 WS-CHARGE              BINARY-LONG.
 01 WS-DECAY               BINARY-LONG.
 01 WS-UPDATE              BINARY-LONG.
 01 WS-TABLE.
    05 WS-T-ENTRY OCCURS 32 TIMES.
       10 WS-T-V           BINARY-LONG OCCURS 7 TIMES.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX PB-BUFFER.
     MOVE 0 TO WS-FAIL WS-N
     CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ETYPE WS-COUNT
     IF WS-COUNT > 32 OR (WS-COUNT > 0 AND WS-ETYPE NOT = 10)
         MOVE 1 TO WS-FAIL
     END-IF
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > WS-COUNT OR PB-ERROR = 1
         IF WS-FAIL = 1
             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-ETYPE
         ELSE
             MOVE 0 TO WS-HAS-POS WS-CHARGE WS-UPDATE WS-MASK
             MOVE 1 TO WS-DECAY
             MOVE -1 TO WS-MASK
             PERFORM UNTIL PB-ERROR = 1
                 MOVE SPACES TO WN
                 CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-C32 WL
                 IF WS-TYPE = 0
                     EXIT PERFORM
                 END-IF
                 EVALUATE TRUE
                     WHEN WN = "pos" AND WS-TYPE = 11
                         CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-C3 WS-ICOUNT WS-INTS
                         IF WS-ICOUNT = 3
                             MOVE 1 TO WS-HAS-POS
                         END-IF
                     WHEN WN = "charge" AND WS-TYPE = 3
                         CALL "PB-GET-INT" USING PB-BUFFER WS-CHARGE
                     WHEN WN = "decay_delay" AND WS-TYPE = 3
                         CALL "PB-GET-INT" USING PB-BUFFER WS-DECAY
                     WHEN WN = "update_delay" AND WS-TYPE = 3
                         CALL "PB-GET-INT" USING PB-BUFFER WS-UPDATE
                     WHEN WN = "facings" AND WS-TYPE = 9
                         MOVE 0 TO WS-MASK
                         CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-FTYPE WS-FCOUNT
                         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-FCOUNT OR PB-ERROR = 1
                             IF WS-FTYPE = 8
                                 CALL "BE6-READ-TEXT" USING PB-BUFFER WS-TEXT WS-C64 WS-LENGTH
                                 IF WS-LENGTH = 0
                                     MOVE 1 TO WS-LENGTH
                                 END-IF
                                 EVALUATE WS-TEXT(1:WS-LENGTH)
                                     WHEN "down"
                                         IF FUNCTION MOD(WS-MASK, 2) = 0
                                             ADD 1 TO WS-MASK
                                         END-IF
                                     WHEN "up"
                                         IF FUNCTION MOD(FUNCTION INTEGER(WS-MASK / 2), 2) = 0
                                             ADD 2 TO WS-MASK
                                         END-IF
                                     WHEN "north"
                                         IF FUNCTION MOD(FUNCTION INTEGER(WS-MASK / 4), 2) = 0
                                             ADD 4 TO WS-MASK
                                         END-IF
                                     WHEN "south"
                                         IF FUNCTION MOD(FUNCTION INTEGER(WS-MASK / 8), 2) = 0
                                             ADD 8 TO WS-MASK
                                         END-IF
                                     WHEN "west"
                                         IF FUNCTION MOD(FUNCTION INTEGER(WS-MASK / 16), 2) = 0
                                             ADD 16 TO WS-MASK
                                         END-IF
                                     WHEN "east"
                                         IF FUNCTION MOD(FUNCTION INTEGER(WS-MASK / 32), 2) = 0
                                             ADD 32 TO WS-MASK
                                         END-IF
                                 END-EVALUATE
                             ELSE
                                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-FTYPE
                             END-IF
                         END-PERFORM
                     WHEN OTHER
                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
                 END-EVALUATE
             END-PERFORM
             IF WS-HAS-POS = 0 OR WS-CHARGE < 0 OR WS-CHARGE > 1000 OR WS-DECAY < 0 OR WS-DECAY > 1 OR WS-UPDATE < 0
                 MOVE 1 TO WS-FAIL
             ELSE
                 ADD 1 TO WS-N
                 MOVE WS-INT(1) TO WS-T-V(WS-N, 1)
                 MOVE WS-INT(2) TO WS-T-V(WS-N, 2)
                 MOVE WS-INT(3) TO WS-T-V(WS-N, 3)
                 MOVE WS-CHARGE TO WS-T-V(WS-N, 4)
                 MOVE WS-DECAY TO WS-T-V(WS-N, 5)
                 MOVE WS-UPDATE TO WS-T-V(WS-N, 6)
                 MOVE WS-MASK TO WS-T-V(WS-N, 7)
             END-IF
         END-IF
     END-PERFORM
     MOVE 0 TO BE-XI(L-INDEX, 1)
     IF WS-FAIL = 0
         MOVE WS-N TO BE-XI(L-INDEX, 1)
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > WS-N
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 7
                 COMPUTE WS-B = (WS-E - 1) * 7 + WS-K
                 MOVE WS-T-V(WS-E, WS-K) TO BE-UUID(L-INDEX, WS-B)
             END-PERFORM
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM BE8-CAT-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-MERGE.
*> USING index, origin x, y, z, events out (BINARY-LONG groups of x, y, z, data, at most 32), event count out: the position merge of SculkSpreader.updateCursors after the cursors have been updated (7.3):
*> far cursors (Chebyshev above 1024) and cursors without charge are dropped (the latter send level event 3006 with data 0); cursors on one position merge while their charges sum to at most 1000;
*> each position with a charge sum and facings sends level event 3006 with ((int)(ln(1 + sum) / 2.299999952316284) + 1) << 6 plus the facings mask.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-CUR.
    05 WS-C OCCURS 32 TIMES.
       10 WS-CV            BINARY-LONG OCCURS 7 TIMES.
 01 WS-KEPT.
    05 WS-K OCCURS 32 TIMES.
       10 WS-KV            BINARY-LONG OCCURS 7 TIMES.
 01 WS-KN                  BINARY-LONG.
 01 WS-SLOTS.
    05 WS-S OCCURS 32 TIMES.
       10 WS-SX            BINARY-LONG.
       10 WS-SY            BINARY-LONG.
       10 WS-SZ            BINARY-LONG.
       10 WS-SUM           BINARY-LONG.
       10 WS-REM           BINARY-LONG.
 01 WS-SN                  BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-EVENTS.
    05 L-E                 BINARY-LONG OCCURS 192 TIMES.
 01 L-EVENT-COUNT          BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-X L-Y L-Z L-EVENTS L-EVENT-COUNT.
     MOVE 0 TO L-EVENT-COUNT WS-KN WS-SN
     MOVE BE-XI(L-INDEX, 1) TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 7
             MOVE BE-UUID(L-INDEX, (WS-I - 1) * 7 + WS-J) TO WS-CV(WS-I, WS-J)
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         COMPUTE WS-DX = FUNCTION ABS(WS-CV(WS-I, 1) - L-X)
         COMPUTE WS-DY = FUNCTION ABS(WS-CV(WS-I, 2) - L-Y)
         COMPUTE WS-DZ = FUNCTION ABS(WS-CV(WS-I, 3) - L-Z)
         IF WS-DX <= 1024 AND WS-DY <= 1024 AND WS-DZ <= 1024
             IF WS-CV(WS-I, 4) <= 0
                 ADD 1 TO L-EVENT-COUNT
                 COMPUTE WS-B = (L-EVENT-COUNT - 1) * 4
                 MOVE WS-CV(WS-I, 1) TO L-E(WS-B + 1)
                 MOVE WS-CV(WS-I, 2) TO L-E(WS-B + 2)
                 MOVE WS-CV(WS-I, 3) TO L-E(WS-B + 3)
                 MOVE 0 TO L-E(WS-B + 4)
             ELSE
                 MOVE 0 TO WS-SLOT
                 PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-SN
                     IF WS-SX(WS-J) = WS-CV(WS-I, 1) AND WS-SY(WS-J) = WS-CV(WS-I, 2) AND WS-SZ(WS-J) = WS-CV(WS-I, 3)
                         MOVE WS-J TO WS-SLOT
                     END-IF
                 END-PERFORM
                 IF WS-SLOT = 0
                     ADD 1 TO WS-SN WS-KN
                     MOVE WS-SN TO WS-SLOT
                     MOVE WS-CV(WS-I, 1) TO WS-SX(WS-SN)
                     MOVE WS-CV(WS-I, 2) TO WS-SY(WS-SN)
                     MOVE WS-CV(WS-I, 3) TO WS-SZ(WS-SN)
                     MOVE WS-CV(WS-I, 4) TO WS-SUM(WS-SN)
                     MOVE WS-KN TO WS-REM(WS-SN)
                     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 7
                         MOVE WS-CV(WS-I, WS-J) TO WS-KV(WS-KN, WS-J)
                     END-PERFORM
                 ELSE
                     ADD WS-CV(WS-I, 4) TO WS-SUM(WS-SLOT)
                     MOVE WS-REM(WS-SLOT) TO WS-J
                     IF WS-KV(WS-J, 4) + WS-CV(WS-I, 4) <= 1000
                         ADD WS-CV(WS-I, 4) TO WS-KV(WS-J, 4)
                         IF WS-CV(WS-I, 6) < WS-KV(WS-J, 6)
                             MOVE WS-CV(WS-I, 6) TO WS-KV(WS-J, 6)
                         END-IF
                     ELSE
                         ADD 1 TO WS-KN
                         PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 7
                             MOVE WS-CV(WS-I, WS-D) TO WS-KV(WS-KN, WS-D)
                         END-PERFORM
                         IF WS-CV(WS-I, 4) < WS-KV(WS-J, 4)
                             MOVE WS-KN TO WS-REM(WS-SLOT)
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-SN
         IF WS-SUM(WS-J) > 0 AND WS-KV(WS-REM(WS-J), 7) >= 0
             ADD 1 TO L-EVENT-COUNT
             COMPUTE WS-B = (L-EVENT-COUNT - 1) * 4
             MOVE WS-SX(WS-J) TO L-E(WS-B + 1)
             MOVE WS-SY(WS-J) TO L-E(WS-B + 2)
             MOVE WS-SZ(WS-J) TO L-E(WS-B + 3)
             COMPUTE WS-EVENT = (FUNCTION INTEGER(FUNCTION LOG(1 + WS-SUM(WS-J)) / 2.299999952316284) + 1) * 64 + WS-KV(WS-REM(WS-J), 7)
             MOVE WS-EVENT TO L-E(WS-B + 4)
         END-IF
     END-PERFORM
     MOVE WS-KN TO BE-XI(L-INDEX, 1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-KN
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 7
             MOVE WS-KV(WS-I, WS-J) TO BE-UUID(L-INDEX, (WS-I - 1) * 7 + WS-J)
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM BE8-MERGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-BLOOM.
*> USING the random float, pitch out (FLOAT-SHORT), scheduled tick delay out, sculk_soul particle count out, sound volume out: SculkCatalyst bloom of 7.4.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RANDOM               FLOAT-SHORT.
 01 L-PITCH                FLOAT-SHORT.
 01 L-DELAY                BINARY-LONG.
 01 L-PARTICLES            BINARY-LONG.
 01 L-VOLUME               BINARY-LONG.
 PROCEDURE DIVISION USING L-RANDOM L-PITCH L-DELAY L-PARTICLES L-VOLUME.
     COMPUTE L-PITCH = 0.6 + L-RANDOM * 0.4
     MOVE 8 TO L-DELAY
     MOVE 2 TO L-PARTICLES L-VOLUME
     GOBACK.
 END PROGRAM BE8-BLOOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-STATUE-NEXT.
*> USING pose (0 standing, 1 sitting, 2 running, 3 star), next pose out: the pose cycle of 8.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POSE                 BINARY-LONG.
 01 L-NEXT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-POSE L-NEXT.
     COMPUTE L-NEXT = FUNCTION MOD(L-POSE + 1, 4)
     GOBACK.
 END PROGRAM BE8-STATUE-NEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-STATUE-SIGNAL.
*> USING pose, comparator signal out (pose.ordinal + 1): 8.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-POSE                 BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-POSE L-SIGNAL.
     COMPUTE L-SIGNAL = L-POSE + 1
     GOBACK.
 END PROGRAM BE8-STATUE-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-STATUE-USE.
*> USING the item is an axe, the statue is a weathering statue, its oxidation (0 unaffected), the item is honeycomb, a golem was created, result out (0 pass, 1 the pose advances, 2 the golem
*> appears and the block is removed): CopperGolemStatueBlock.useItemOn of 8.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AXE                  BINARY-LONG.
 01 L-WEATHERING           BINARY-LONG.
 01 L-OXIDATION            BINARY-LONG.
 01 L-HONEYCOMB            BINARY-LONG.
 01 L-CREATED              BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-AXE L-WEATHERING L-OXIDATION L-HONEYCOMB L-CREATED L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-AXE = 1
         IF L-WEATHERING = 1 AND L-OXIDATION = 0 AND L-CREATED = 1
             MOVE 2 TO L-RESULT
         END-IF
     ELSE
         IF L-HONEYCOMB = 0 OR L-WEATHERING = 0
             MOVE 1 TO L-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE8-STATUE-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-STATUE-FACING.
*> USING yaw (degrees), direction out (south 3, west 4, north 2, east 5): Direction.fromYRot, floor(yaw / 90 + 0.5) & 3 (8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-YAW                  BINARY-LONG.
 01 L-DIRECTION            BINARY-LONG.
 PROCEDURE DIVISION USING L-YAW L-DIRECTION.
     COMPUTE WS-INDEX = FUNCTION MOD(FUNCTION INTEGER(L-YAW / 90 + 0.5), 4)
     EVALUATE WS-INDEX
         WHEN 0
             MOVE 3 TO L-DIRECTION
         WHEN 1
             MOVE 4 TO L-DIRECTION
         WHEN 2
             MOVE 2 TO L-DIRECTION
         WHEN OTHER
             MOVE 5 TO L-DIRECTION
     END-EVALUATE
     GOBACK.
 END PROGRAM BE8-STATUE-FACING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-SULFUR-SOURCE.
*> USING the five cells above the sulfur block (BINARY-LONG table: 1 a water source with the water block or a passable block, 2 a water source with another blocking block, 3 air or a passable
*> block that is no water source, 0 solid), h out (the cells between, 0 to 4, -1 none): findNoxiousGasSourceBlock of 9.4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-CELLS.
    05 L-C                 BINARY-LONG OCCURS 5 TIMES.
 01 L-HEIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING L-CELLS L-HEIGHT.
     MOVE -1 TO L-HEIGHT
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5 OR WS-DONE = 1
         IF L-C(WS-I) NOT = 1
             MOVE 1 TO WS-DONE
             IF L-C(WS-I) = 3
                 COMPUTE L-HEIGHT = WS-I - 1
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BE8-SULFUR-SOURCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-SULFUR-UNOBSTRUCTED.
*> USING passable cells (BINARY-LONG table of up to 24 flags starting at the cell above the sulfur), h, count out: getUnobstructedBlockCount of 9.4, the limit is 6 * h.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-CELLS.
    05 L-C                 BINARY-LONG OCCURS 24 TIMES.
 01 L-HEIGHT               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-CELLS L-HEIGHT L-COUNT.
     COMPUTE WS-LIMIT = 6 * L-HEIGHT
     MOVE WS-LIMIT TO L-COUNT
     PERFORM VARYING WS-I FROM WS-LIMIT BY -1 UNTIL WS-I < 1
         IF L-C(WS-I) = 0
             COMPUTE L-COUNT = WS-I - 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BE8-SULFUR-UNOBSTRUCTED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-SULFUR-COUNTDOWN.
*> USING index, state (2 dormant, 3 erupting), game time, a source was found, h, the draw (nextIntBetweenInclusive 15 to 30 for dormant, 1 to 2 for erupting), new state out, deactivate event out:
*> the waiting countdown of 9.5 in units of 20 ticks.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-TIME                 BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-STATE L-TIME L-FOUND L-HEIGHT L-DRAW L-NEW L-EVENT.
     MOVE L-STATE TO L-NEW
     MOVE 0 TO L-EVENT
     IF FUNCTION MOD(L-TIME, 20) NOT = 0 OR L-FOUND = 0
         GOBACK
     END-IF
     IF BE-XI(L-INDEX, 1) <= 0
         IF L-STATE = 2
             COMPUTE BE-XI(L-INDEX, 1) = 10 * (L-HEIGHT - 1) + L-DRAW
         ELSE
             COMPUTE BE-XI(L-INDEX, 1) = L-HEIGHT - 1 + L-DRAW
         END-IF
     END-IF
     IF BE-XI(L-INDEX, 1) > 0
         SUBTRACT 1 FROM BE-XI(L-INDEX, 1)
     END-IF
     IF BE-XI(L-INDEX, 1) = 0
         MOVE 2 TO L-NEW
         IF L-STATE = 2
             MOVE 3 TO L-NEW
         ELSE
             MOVE 1 TO L-EVENT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE8-SULFUR-COUNTDOWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-SULFUR-NAUSEA.
*> USING game time, a source was found, run out: the nausea pass runs every 10 ticks when there is a source (9.5).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TIME                 BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-RUN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TIME L-FOUND L-RUN.
     MOVE 0 TO L-RUN
     IF FUNCTION MOD(L-TIME, 10) = 0 AND L-FOUND = 1
         MOVE 1 TO L-RUN
     END-IF
     GOBACK.
 END PROGRAM BE8-SULFUR-NAUSEA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-SULFUR-REACH.
*> USING the eye block is passable, squared distance of the eye to the source centre (tenths do not matter, whole squared distance of positions is given), the lowered eye is in a water source,
*> the collider ray is clear, ok out: canBeReachedByNoxiousGas of 9.5, within 3.0 blocks.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PASSABLE             BINARY-LONG.
 01 L-DISTANCE             BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-CLEAR                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-PASSABLE L-DISTANCE L-WATER L-CLEAR L-OK.
     MOVE 0 TO L-OK
     IF L-PASSABLE = 1 AND L-DISTANCE <= 9 AND L-WATER = 1 AND L-CLEAR = 1
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM BE8-SULFUR-REACH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-SULFUR-LAUNCH.
*> USING vertical velocity (FLOAT-LONG), h, the entity is a flying player, the entity is excluded (cannot simulate movement, a passenger or not affected by geysers), add out: 9.6, +0.2 in y
*> when the vertical velocity is below 0.3 + h * 0.1 (the float constant 0.3f is taken as 0.3: differences below 1e-8 are not resolved).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIMIT               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-VELOCITY             FLOAT-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-FLYING               BINARY-LONG.
 01 L-EXCLUDED             BINARY-LONG.
 01 L-ADD                  BINARY-LONG.
 PROCEDURE DIVISION USING L-VELOCITY L-HEIGHT L-FLYING L-EXCLUDED L-ADD.
     MOVE 0 TO L-ADD
     COMPUTE WS-LIMIT = 0.3 + L-HEIGHT * 0.1
     IF L-FLYING = 0 AND L-EXCLUDED = 0 AND L-VELOCITY < WS-LIMIT
         MOVE 1 TO L-ADD
     END-IF
     GOBACK.
 END PROGRAM BE8-SULFUR-LAUNCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-GEYSER-SEED.
*> USING level seed (BINARY-DOUBLE), seed out: levelSeed exclusive or GEYSER_SALT (-904011478) as 64 bit values (9.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-H63                 PIC 9(20) VALUE 9223372036854775808.
 01 WS-A                   BINARY-DOUBLE UNSIGNED.
 01 WS-B                   BINARY-DOUBLE UNSIGNED.
 01 WS-T                   PIC S9(20).
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-RESULT               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-SEED L-RESULT.
     COMPUTE WS-A = FUNCTION MOD(L-SEED, WS-M64)
     COMPUTE WS-B = WS-M64 - 904011478
     CALL "CBL_XOR" USING WS-B WS-A BY VALUE 8
     IF WS-A >= WS-H63
         COMPUTE WS-T = WS-A - WS-M64
         MOVE WS-T TO L-RESULT
     ELSE
         MOVE WS-A TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM BE8-GEYSER-SEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-SULFUR-TICKER.
*> USING state (0 dry, 1 wet, 2 dormant, 3 erupting, 4 continuous), side (0 server, 1 client), ticker out: 9.3. Server 1 nausea, 2 countdown then nausea, 3 launch then countdown, 4 launch;
*> client 1 gas particles, 2 eruption plume then launch, 3 continuous plume then launch; 0 none.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-SIDE                 BINARY-LONG.
 01 L-TICKER               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-SIDE L-TICKER.
     MOVE 0 TO L-TICKER
     IF L-STATE > 0
         IF L-SIDE = 0
             MOVE L-STATE TO L-TICKER
         ELSE
             MOVE 1 TO L-TICKER
             IF L-STATE > 2
                 COMPUTE L-TICKER = L-STATE - 1
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BE8-SULFUR-TICKER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-SULFUR-PLACE.
*> USING the new state, block event queued out, start sound out (1 geyser_eruption_start for erupting, 2 geyser_continuous_start for continuous), block_activate posted out: onPlace of 9.2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-QUEUE                BINARY-LONG.
 01 L-SOUND                BINARY-LONG.
 01 L-ACTIVATE             BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-QUEUE L-SOUND L-ACTIVATE.
     MOVE 0 TO L-QUEUE L-SOUND L-ACTIVATE
     IF L-STATE = 3 OR L-STATE = 4
         MOVE 1 TO L-QUEUE L-ACTIVATE
         COMPUTE L-SOUND = L-STATE - 2
     END-IF
     GOBACK.
 END PROGRAM BE8-SULFUR-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-SWEEP.
*> USING type, valid blocks out, getUpdateTag sent (with the inheritance of the hanging sign) out, getUpdatePacket sent out, listener provider out: the table of 11, in the order of the registry.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(5) VALUE "01000".
    05 FILLER PIC X(5) VALUE "09000".
    05 FILLER PIC X(5) VALUE "01000".
    05 FILLER PIC X(5) VALUE "01000".
    05 FILLER PIC X(5) VALUE "01000".
    05 FILLER PIC X(5) VALUE "01000".
    05 FILLER PIC X(5) VALUE "01000".
    05 FILLER PIC X(5) VALUE "26110".
    05 FILLER PIC X(5) VALUE "26110".
    05 FILLER PIC X(5) VALUE "01110".
    05 FILLER PIC X(5) VALUE "01110".
    05 FILLER PIC X(5) VALUE "01100".
    05 FILLER PIC X(5) VALUE "01000".
    05 FILLER PIC X(5) VALUE "01000".
    05 FILLER PIC X(5) VALUE "01000".
    05 FILLER PIC X(5) VALUE "01110".
    05 FILLER PIC X(5) VALUE "14110".
    05 FILLER PIC X(5) VALUE "01000".
    05 FILLER PIC X(5) VALUE "01000".
    05 FILLER PIC X(5) VALUE "01000".
    05 FILLER PIC X(5) VALUE "32110".
    05 FILLER PIC X(5) VALUE "01110".
    05 FILLER PIC X(5) VALUE "01110".
    05 FILLER PIC X(5) VALUE "03000".
    05 FILLER PIC X(5) VALUE "17000".
    05 FILLER PIC X(5) VALUE "01110".
    05 FILLER PIC X(5) VALUE "01000".
    05 FILLER PIC X(5) VALUE "01000".
    05 FILLER PIC X(5) VALUE "01000".
    05 FILLER PIC X(5) VALUE "01000".
    05 FILLER PIC X(5) VALUE "01000".
    05 FILLER PIC X(5) VALUE "01110".
    05 FILLER PIC X(5) VALUE "02110".
    05 FILLER PIC X(5) VALUE "02000".
    05 FILLER PIC X(5) VALUE "01001".
    05 FILLER PIC X(5) VALUE "01001".
    05 FILLER PIC X(5) VALUE "01001".
    05 FILLER PIC X(5) VALUE "01001".
    05 FILLER PIC X(5) VALUE "01000".
    05 FILLER PIC X(5) VALUE "13110".
    05 FILLER PIC X(5) VALUE "02110".
    05 FILLER PIC X(5) VALUE "01110".
    05 FILLER PIC X(5) VALUE "01000".
    05 FILLER PIC X(5) VALUE "01110".
    05 FILLER PIC X(5) VALUE "01110".
    05 FILLER PIC X(5) VALUE "01110".
    05 FILLER PIC X(5) VALUE "01110".
    05 FILLER PIC X(5) VALUE "08010".
    05 FILLER PIC X(5) VALUE "01000".
 01 FILLER REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 49 TIMES.
       10 WS-BLOCKS          PIC 99.
       10 WS-TAG             PIC 9.
       10 WS-PACKET          PIC 9.
       10 WS-LISTENER        PIC 9.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-BLOCKS               BINARY-LONG.
 01 L-TAG                  BINARY-LONG.
 01 L-PACKET               BINARY-LONG.
 01 L-LISTENER             BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-BLOCKS L-TAG L-PACKET L-LISTENER.
     MOVE WS-BLOCKS(L-TYPE + 1) TO L-BLOCKS
     MOVE WS-TAG(L-TYPE + 1) TO L-TAG
     MOVE WS-PACKET(L-TYPE + 1) TO L-PACKET
     MOVE WS-LISTENER(L-TYPE + 1) TO L-LISTENER
     GOBACK.
 END PROGRAM BE8-SWEEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-DEFAULTS.
*> USING index: the defaults of a new potent sulfur entity (countdown -1, eruptionTick -1); BEX-DEFAULTS has cleared the cells.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     MOVE -1 TO BE-XI(L-INDEX, 1) BE-TIME2(L-INDEX)
     GOBACK.
 END PROGRAM BE8-DEFAULTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-SAVE.
*> USING index, type, PB-BUFFER: the custom keys of the types 34, 35, 36, 37 and 48 (BEX-SAVE of be-31-3.cob).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN                     PIC X(32).
 COPY BESTATE.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-TYPE PB-BUFFER.
     EVALUATE L-TYPE
         WHEN 34 WHEN 35 WHEN 37
             CALL "BE8-KEYS-SAVE" USING L-INDEX L-TYPE PB-BUFFER
         WHEN 36
             CALL "BE8-CAT-SAVE" USING L-INDEX PB-BUFFER
         WHEN 48
             MOVE "countdown" TO WN
             CALL "BE6-W-INT" USING PB-BUFFER WN BE-XI(L-INDEX, 1)
     END-EVALUATE
     GOBACK.
 END PROGRAM BE8-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BE8-LOAD-KEY.
*> USING index, key name (X(32)), tag, PB-BUFFER, handled out (BEX-LOAD-KEY of be-31-3.cob).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-TAG                  BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-NAME L-TAG PB-BUFFER L-HANDLED.
     MOVE 0 TO L-HANDLED
     EVALUATE BE-TYPE(L-INDEX)
         WHEN 34 WHEN 35 WHEN 37
             CALL "BE8-KEYS-LOAD" USING L-INDEX L-NAME L-TAG PB-BUFFER L-HANDLED
         WHEN 36
             IF L-NAME = "cursors" AND L-TAG = 9
                 MOVE 1 TO L-HANDLED
                 CALL "BE8-CAT-LOAD" USING L-INDEX PB-BUFFER
             END-IF
         WHEN 48
             IF L-NAME = "countdown" AND L-TAG = 3
                 MOVE 1 TO L-HANDLED
                 CALL "PB-GET-INT" USING PB-BUFFER BE-XI(L-INDEX, 1)
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM BE8-LOAD-KEY.
