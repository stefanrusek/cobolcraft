*> The trial spawner in the live world (docs/protocol/44-residual-mob-questions-2-spawning-structures.md section 4; lane 002-lane-p49g). The data are those of the 31-7 trial spawner (BESTATE.cpy type 43):
*> BE-XI 1 the number of detected players (UUIDs at BE-UUID 1 to 64), 2 the number of current mobs (UUIDs at BE-UUID 65 to 320), 3 total_mobs_spawned, 4 the next spawn data is set, 5 the length of its id
*> (BE-XT 1), 6 the length of ejecting_loot_table (BE-XT 2), 9 target_cooldown_length, 10 required_player_range, 12 to 15 the block and sky light limits of the next spawn data, 16 its custom rules are set;
*> BE-SEED cooldown_ends_at, BE-TIME2 next_mob_spawns_at. Added here: BE-XI 17 the spawn_potentials of both configurations are the single entity of BE-XT 5 (length BE-XI 18), set when a spawn egg was used
*> on the block (5, overrideEntityToSpawn); without it the potentials list is empty. The block state holds trial_spawner_state and ominous. Both configurations are the default one of 4.2 (the 28 registry
*> configurations are not tabulated in the documents): total_mobs 6 (+2 a player), simultaneous_mobs 2 (+1), ticks_between_spawn 40, spawn_range 4, the default eject list.
*> Game time is CW-GAME-TIME + CW-TICKS.
*>
*> Entry points:
*>   TRIAL-SPAWNER-TICK USING index         TrialSpawner.tickServer (4.4; BE-TICK-ALL calls it for type 43): the untracking of lost mobs, then one tick of the state's row
*>   TS-OVERRIDE USING index, entity key (PIC X(64)), length    overrideEntityToSpawn (5): resets the saved state, the potentials become that entity, the block state inactive
*>   TS-UUID-INTS USING uuid bytes (X(16)), ints out (4 BINARY-LONG)    the four signed big-endian ints of a UUID (the form of BE-UUID)
*>   TS-LOS USING dim, eye x, y, z (FLOAT-LONG), block x, y, z, clear out    a visual ray from the point to the block centre (sampled every 0.125 block): clear when no solid cell lies
*>     between them (neither the cell the ray starts in, a spawner's own, nor the block it ends at is an obstacle)
*> Internal: TS-STATE-GET, TS-STATE-SET, TS-OMINOUS-SET, TS-UNTRACK, TS-NEXT-DATA, TS-DETECT-LIST, TS-DETECT, TS-SPAWN, TS-EJECT, TS-RESET-STATS, TS-OMINOUS-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TS-UUID-INTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-V                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-BYTES                PIC X(16).
 01 L-INTS.
    05 L-INT               BINARY-LONG OCCURS 4 TIMES.
 PROCEDURE DIVISION USING L-BYTES L-INTS.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         MOVE 0 TO WS-V
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
             COMPUTE WS-POS = (WS-K - 1) * 4 + WS-J
             COMPUTE WS-V = WS-V * 256 + FUNCTION ORD(L-BYTES(WS-POS:1)) - 1
         END-PERFORM
         IF WS-V >= 2147483648
             SUBTRACT 4294967296 FROM WS-V
         END-IF
         MOVE WS-V TO L-INT(WS-K)
     END-PERFORM
     GOBACK.
 END PROGRAM TS-UUID-INTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TS-LOS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SCX                 BINARY-LONG.
 01 WS-SCY                 BINARY-LONG.
 01 WS-SCZ                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-SX                   FLOAT-LONG.
 01 L-SY                   FLOAT-LONG.
 01 L-SZ                   FLOAT-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 01 L-CLEAR                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-SX L-SY L-SZ L-BX L-BY L-BZ L-CLEAR.
     MOVE 1 TO L-CLEAR
     COMPUTE WS-DX = L-BX + 0.5 - L-SX
     COMPUTE WS-DY = L-BY + 0.5 - L-SY
     COMPUTE WS-DZ = L-BZ + 0.5 - L-SZ
     COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
     COMPUTE WS-N = FUNCTION INTEGER(WS-LEN / 0.125) + 1
     COMPUTE WS-SCX = FUNCTION INTEGER(L-SX)
     COMPUTE WS-SCY = FUNCTION INTEGER(L-SY)
     COMPUTE WS-SCZ = FUNCTION INTEGER(L-SZ)
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-N OR L-CLEAR = 0
         COMPUTE WS-PX = L-SX + WS-DX * WS-I / WS-N
         COMPUTE WS-PY = L-SY + WS-DY * WS-I / WS-N
         COMPUTE WS-PZ = L-SZ + WS-DZ * WS-I / WS-N
         COMPUTE WS-CX = FUNCTION INTEGER(WS-PX)
         COMPUTE WS-CY = FUNCTION INTEGER(WS-PY)
         COMPUTE WS-CZ = FUNCTION INTEGER(WS-PZ)
         IF NOT (WS-CX = L-BX AND WS-CY = L-BY AND WS-CZ = L-BZ) AND NOT (WS-CX = WS-SCX AND WS-CY = WS-SCY AND WS-CZ = WS-SCZ)
             CALL "WORLD-GET-BLOCK" USING L-DIM WS-CX WS-CY WS-CZ WS-STATE
             IF WS-STATE > 0
                 IF CB-SOLID(CB-S-BLOCK(WS-STATE + 1) + 1) = 1
                     MOVE 0 TO L-CLEAR
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TS-LOS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TS-STATE-GET.
*> USING dim, x, y, z of the block, state out (0 to 5, the ordinal of trial_spawner_state), ominous out (1 when the property ominous is true).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-NAME1               PIC X(24) VALUE "trial_spawner_state".
 01 WS-NAME2               PIC X(24) VALUE "ominous".
 01 WS-TEXT                PIC X(32).
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-OMINOUS              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-OMINOUS.
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-BLOCK
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-BLOCK WS-NAME1 WS-TEXT WS-R
     EVALUATE WS-TEXT
         WHEN "waiting_for_players"
             MOVE 1 TO L-STATE
         WHEN "active"
             MOVE 2 TO L-STATE
         WHEN "waiting_for_reward_ejection"
             MOVE 3 TO L-STATE
         WHEN "ejecting_reward"
             MOVE 4 TO L-STATE
         WHEN "cooldown"
             MOVE 5 TO L-STATE
         WHEN OTHER
             MOVE 0 TO L-STATE
     END-EVALUATE
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-BLOCK WS-NAME2 WS-TEXT WS-R
     MOVE 0 TO L-OMINOUS
     IF WS-TEXT = "true"
         MOVE 1 TO L-OMINOUS
     END-IF
     GOBACK.
 END PROGRAM TS-STATE-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TS-STATE-SET.
*> USING dim, x, y, z of the block, kind (1 trial_spawner_state, 2 ominous), value (the ordinal of the state, or 1 / 0 for ominous): the block state with that property set (BLOCK-CHANGE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 2.
 01 WS-NAME                PIC X(24).
 01 WS-TEXT                PIC X(32).
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KIND L-VALUE.
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-BLOCK
     MOVE SPACES TO WS-TEXT
     IF L-KIND = 1
         MOVE "trial_spawner_state" TO WS-NAME
         EVALUATE L-VALUE
             WHEN 1
                 MOVE "waiting_for_players" TO WS-TEXT
             WHEN 2
                 MOVE "active" TO WS-TEXT
             WHEN 3
                 MOVE "waiting_for_reward_ejection" TO WS-TEXT
             WHEN 4
                 MOVE "ejecting_reward" TO WS-TEXT
             WHEN 5
                 MOVE "cooldown" TO WS-TEXT
             WHEN OTHER
                 MOVE "inactive" TO WS-TEXT
         END-EVALUATE
     ELSE
         MOVE "ominous" TO WS-NAME
         MOVE "false" TO WS-TEXT
         IF L-VALUE = 1
             MOVE "true" TO WS-TEXT
         END-IF
     END-IF
     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-BLOCK WS-NAME WS-TEXT WS-NEW
     IF WS-NEW NOT = WS-BLOCK
         CALL "BLOCK-CHANGE" USING L-DIM L-X L-Y L-Z WS-NEW
     END-IF
     GOBACK.
 END PROGRAM TS-STATE-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TS-RESET-STATS.
*> USING index: reset statistics (4.4): no detected player, total_mobs_spawned 0, next_mob_spawns_at 0 and cooldown_ends_at 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     MOVE 0 TO BE-XI(L-INDEX, 1) BE-XI(L-INDEX, 3) BE-TIME2(L-INDEX) BE-SEED(L-INDEX)
     GOBACK.
 END PROGRAM TS-RESET-STATS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TS-NEXT-DATA.
*> USING state (XORO), index, force (1: always pick): getOrCreateNextSpawnData: the next spawn data is kept when it has an id and force is 0; otherwise it is the pick of the potentials, one
*> nextInt(1) draw for the single entity (7.1) and its id, with no custom rules; an empty list leaves it as it is.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-DRAW                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-INDEX                BINARY-LONG.
 01 L-FORCE                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-INDEX L-FORCE.
     IF BE-XI(L-INDEX, 17) = 1 AND (L-FORCE = 1 OR BE-XI(L-INDEX, 5) = 0)
         CALL "XORO-NEXT-INT" USING L-STATE WS-ONE WS-DRAW
         MOVE BE-XT(L-INDEX, 5) TO BE-XT(L-INDEX, 1)
         MOVE BE-XI(L-INDEX, 18) TO BE-XI(L-INDEX, 5)
         MOVE 1 TO BE-XI(L-INDEX, 4)
         MOVE 0 TO BE-XI(L-INDEX, 16)
     END-IF
     GOBACK.
 END PROGRAM TS-NEXT-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TS-UNTRACK.
*> USING index, game time (BINARY-DOUBLE): step 2 of 4.4: a current mob that is gone, dead, in another dimension or more than 47 blocks (squared block distance above 2209) from the block is
*> forgotten; when at least one was, next_mob_spawns_at is the game time plus ticks_between_spawn (40).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BESTATE.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-REMOVED             BINARY-LONG.
 01 WS-INTS.
    05 WS-INT              BINARY-LONG OCCURS 4 TIMES.
 01 WS-MINE.
    05 WS-M                BINARY-LONG OCCURS 4 TIMES.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-LOST                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-TIME                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-INDEX L-TIME.
     MOVE 0 TO WS-REMOVED WS-N
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > BE-XI(L-INDEX, 2)
         COMPUTE WS-BASE = 64 + (WS-K - 1) * 4
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
             COMPUTE WS-A = WS-BASE + WS-J
             MOVE BE-UUID(L-INDEX, WS-A) TO WS-M(WS-J)
         END-PERFORM
         MOVE 1 TO WS-LOST
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF EN-USED(WS-E) = 1
                 CALL "TS-UUID-INTS" USING EN-UUID(WS-E) WS-INTS
                 IF WS-INT(1) = WS-M(1) AND WS-INT(2) = WS-M(2) AND WS-INT(3) = WS-M(3) AND WS-INT(4) = WS-M(4)
                     COMPUTE WS-DX = FUNCTION INTEGER(EN-X(WS-E)) - BE-X(L-INDEX)
                     COMPUTE WS-DY = FUNCTION INTEGER(EN-Y(WS-E)) - BE-Y(L-INDEX)
                     COMPUTE WS-DZ = FUNCTION INTEGER(EN-Z(WS-E)) - BE-Z(L-INDEX)
                     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
                     IF EN-HEALTH(WS-E) > 0 AND EN-DIM(WS-E) = BE-DIM(L-INDEX) AND WS-D2 <= 2209
                         MOVE 0 TO WS-LOST
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
         IF WS-LOST = 1
             MOVE 1 TO WS-REMOVED
         ELSE
             ADD 1 TO WS-N
             COMPUTE WS-ROW = 64 + (WS-N - 1) * 4
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
                 COMPUTE WS-A = WS-ROW + WS-J
                 MOVE WS-M(WS-J) TO BE-UUID(L-INDEX, WS-A)
             END-PERFORM
         END-IF
     END-PERFORM
     MOVE WS-N TO BE-XI(L-INDEX, 2)
     IF WS-REMOVED = 1
         COMPUTE BE-TIME2(L-INDEX) = L-TIME + 40
     END-IF
     GOBACK.
 END PROGRAM TS-UNTRACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TS-DETECT-LIST.
*> USING index, line of sight needed (1 or 0), player rows out (16 BINARY-LONG), count out: the players PlayerDetector.NO_CREATIVE_PLAYERS finds (4.5): alive, in the dimension, not creative and not
*> a spectator, whose block position is closer than required_player_range (integer squared distance below the range squared) to the spawner's, and with the sight flag a clear visual ray from the eye
*> to the block centre.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BESTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 01 WS-EYE                 FLOAT-LONG.
 01 WS-CLEAR               BINARY-LONG.
 01 WS-DET                 BINARY-LONG.
 01 WS-INCLUDING           BINARY-LONG VALUE 0.
 01 WS-CREATIVE            BINARY-LONG.
 01 WS-SPECTATOR           BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-SIGHT                BINARY-LONG.
 01 L-ROWS.
    05 L-ROW               BINARY-LONG OCCURS 16 TIMES.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-SIGHT L-ROWS L-COUNT.
     MOVE 0 TO L-COUNT
     COMPUTE WS-R2 = BE-XI(L-INDEX, 10) * BE-XI(L-INDEX, 10)
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS OR L-COUNT >= 16
         IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = BE-DIM(L-INDEX)
             COMPUTE WS-DX = FUNCTION INTEGER(PL-X(WS-P)) - BE-X(L-INDEX)
             COMPUTE WS-DY = FUNCTION INTEGER(PL-Y(WS-P)) - BE-Y(L-INDEX)
             COMPUTE WS-DZ = FUNCTION INTEGER(PL-Z(WS-P)) - BE-Z(L-INDEX)
             COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
             COMPUTE WS-EYE = PL-Y(WS-P) + 1.62
             MOVE 1 TO WS-CLEAR
             IF L-SIGHT = 1
                 CALL "TS-LOS" USING PL-DIM(WS-P) PL-X(WS-P) WS-EYE PL-Z(WS-P) BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-CLEAR
             END-IF
             MOVE 0 TO WS-CREATIVE WS-SPECTATOR
             IF PL-MODE(WS-P) = 1
                 MOVE 1 TO WS-CREATIVE
             END-IF
             IF PL-MODE(WS-P) = 3
                 MOVE 1 TO WS-SPECTATOR
             END-IF
             CALL "BE7-PLAYER-DETECT" USING WS-D2 BE-XI(L-INDEX, 10) WS-CREATIVE WS-SPECTATOR WS-INCLUDING L-SIGHT WS-CLEAR WS-DET
             IF WS-DET = 1
                 ADD 1 TO L-COUNT
                 MOVE WS-P TO L-ROW(L-COUNT)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TS-DETECT-LIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TS-OMINOUS-RESET.
*> USING index, game time (BINARY-DOUBLE): resetAfterBecomingOminous (4.6): every current mob is discarded (level event 3012 at its block), the next spawn data is cleared when the potentials are not
*> empty, total_mobs_spawned is 0, current_mobs is empty, next_mob_spawns_at is the game time plus ticks_between_spawn (40) and cooldown_ends_at the game time plus 160.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BESTATE.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-INTS.
    05 WS-INT              BINARY-LONG OCCURS 4 TIMES.
 01 WS-MINE.
    05 WS-M                BINARY-LONG OCCURS 4 TIMES.
 01 WS-EVENT               BINARY-LONG VALUE 3012.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-NOEXC               BINARY-LONG VALUE 0.
 01 WS-MX                  BINARY-LONG.
 01 WS-MY                  BINARY-LONG.
 01 WS-MZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-TIME                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-INDEX L-TIME.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > BE-XI(L-INDEX, 2)
         COMPUTE WS-BASE = 64 + (WS-K - 1) * 4
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
             COMPUTE WS-A = WS-BASE + WS-J
             MOVE BE-UUID(L-INDEX, WS-A) TO WS-M(WS-J)
         END-PERFORM
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF EN-USED(WS-E) = 1
                 CALL "TS-UUID-INTS" USING EN-UUID(WS-E) WS-INTS
                 IF WS-INT(1) = WS-M(1) AND WS-INT(2) = WS-M(2) AND WS-INT(3) = WS-M(3) AND WS-INT(4) = WS-M(4)
                     COMPUTE WS-MX = FUNCTION INTEGER(EN-X(WS-E))
                     COMPUTE WS-MY = FUNCTION INTEGER(EN-Y(WS-E))
                     COMPUTE WS-MZ = FUNCTION INTEGER(EN-Z(WS-E))
                     CALL "LEVEL-EVENT" USING EN-DIM(WS-E) WS-EVENT WS-MX WS-MY WS-MZ WS-ZERO WS-NOEXC
                     CALL "ENTITY-REMOVE" USING WS-E
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     IF BE-XI(L-INDEX, 17) = 1
         MOVE 0 TO BE-XI(L-INDEX, 4) BE-XI(L-INDEX, 5) BE-XI(L-INDEX, 16)
         MOVE SPACES TO BE-XT(L-INDEX, 1)
     END-IF
     MOVE 0 TO BE-XI(L-INDEX, 3) BE-XI(L-INDEX, 2)
     COMPUTE BE-TIME2(L-INDEX) = L-TIME + 40
     COMPUTE BE-SEED(L-INDEX) = L-TIME + 160
     GOBACK.
 END PROGRAM TS-OMINOUS-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TS-DETECT.
*> USING index, ominous (1 or 0), state (0 to 5), game time (BINARY-DOUBLE), applied out: tryDetectPlayers (4.5). It runs only on ticks where the packed block position plus the game time is a
*> multiple of 20; a cooldown of an ominous spawner stops it. The first detection needs a line of sight; unless the spawner is ominous a detected player holding Trial Omen (the first) or Bad Omen
*> (the last) makes it ominous: Bad Omen becomes Trial Omen of (amplifier + 1) x 18000 ticks (amplifier 0, flags 6), level event 3020 at the player's eye block (data 0), the block state ominous, level
*> event 3020 at the block (data 1) and the reset of 4.6. A cooldown that did not become ominous stops. The detected set takes the first list (or, when it was not empty, a second detection without the
*> line of sight); when it grew, next_mob_spawns_at is at least game time + 40 and, unless the spawner became ominous, level event 3019 (ominous) or 3013 with the set's size is sent.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BESTATE.
 01 WS-PACKED              BINARY-DOUBLE.
 01 WS-RUN                 BINARY-LONG.
 01 WS-ROWS1.
    05 WS-R1               BINARY-LONG OCCURS 16 TIMES.
 01 WS-ROWS2.
    05 WS-R2               BINARY-LONG OCCURS 16 TIMES.
 01 WS-N1                  BINARY-LONG.
 01 WS-N2                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-NOEXC               BINARY-LONG VALUE 0.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-TRIAL-OMEN          BINARY-LONG VALUE 33.
 01 WS-BAD-OMEN            BINARY-LONG VALUE 30.
 01 WS-CHOSEN              BINARY-LONG.
 01 WS-CHOSEN-BAD          BINARY-LONG.
 01 WS-OMEN                BINARY-LONG.
 01 WS-EARLY               BINARY-LONG.
 01 WS-APPLY               BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-STORED              BINARY-LONG.
 01 WS-ADDED               BINARY-LONG.
 01 WS-UUID.
    05 WS-U                BINARY-LONG OCCURS 4 TIMES.
 01 WS-FOUND               BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-AMP                 BINARY-LONG.
 01 WS-DURATION            BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 6.
 01 WS-EVENT               BINARY-LONG.
 01 WS-EV3020              BINARY-LONG VALUE 3020.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-KIND2               BINARY-LONG VALUE 2.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CELL            BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-OMINOUS              BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-TIME                 BINARY-DOUBLE.
 01 L-APPLIED              BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-OMINOUS L-STATE L-TIME L-APPLIED.
     MOVE 0 TO L-APPLIED
     CALL "BE7-PACK-POS" USING BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-PACKED
     CALL "BE7-DETECT-THROTTLE" USING WS-PACKED L-TIME WS-RUN
     IF WS-RUN = 0
         GOBACK
     END-IF
     CALL "TS-DETECT-LIST" USING L-INDEX WS-ONE WS-ROWS1 WS-N1
*>   the player that makes the spawner ominous: the first with Trial Omen, else the last with Bad Omen
     MOVE 0 TO WS-CHOSEN WS-CHOSEN-BAD WS-OMEN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N1
         CALL "EFFECT-LEVEL" USING WS-R1(WS-I) WS-BAD-OMEN WS-LEVEL WS-TICKS
         IF WS-LEVEL > 0
             MOVE WS-R1(WS-I) TO WS-CHOSEN-BAD
         END-IF
         CALL "EFFECT-LEVEL" USING WS-R1(WS-I) WS-TRIAL-OMEN WS-LEVEL WS-TICKS
         IF WS-LEVEL > 0 AND WS-CHOSEN = 0
             MOVE WS-R1(WS-I) TO WS-CHOSEN
         END-IF
     END-PERFORM
     IF WS-CHOSEN > 0
         MOVE 1 TO WS-OMEN
     END-IF
     IF WS-CHOSEN = 0 AND WS-CHOSEN-BAD > 0
         MOVE 1 TO WS-OMEN
         MOVE WS-CHOSEN-BAD TO WS-CHOSEN
     END-IF
     MOVE BE-XI(L-INDEX, 1) TO WS-STORED
     CALL "BE7-DETECT-PLAN" USING L-STATE L-OMINOUS WS-N1 WS-OMEN WS-STORED WS-EARLY WS-APPLY WS-STOP WS-SOURCE
     IF WS-EARLY = 1
         GOBACK
     END-IF
     IF WS-APPLY = 1
         MOVE 1 TO L-APPLIED
         CALL "EFFECT-LEVEL" USING WS-CHOSEN WS-TRIAL-OMEN WS-LEVEL WS-TICKS
         IF WS-LEVEL = 0
             CALL "EFFECT-LEVEL" USING WS-CHOSEN WS-BAD-OMEN WS-LEVEL WS-TICKS
             COMPUTE WS-DURATION = WS-LEVEL * 18000
             MOVE 0 TO WS-AMP
             CALL "EFFECT-REMOVE" USING WS-CHOSEN WS-BAD-OMEN
             CALL "EFFECT-ADD" USING WS-CHOSEN WS-TRIAL-OMEN WS-AMP WS-DURATION WS-FLAGS
         END-IF
         COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-CHOSEN))
         COMPUTE WS-PY = FUNCTION INTEGER(PL-Y(WS-CHOSEN) + 1.62)
         COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-CHOSEN))
         CALL "LEVEL-EVENT" USING BE-DIM(L-INDEX) WS-EV3020 WS-PX WS-PY WS-PZ WS-ZERO WS-NOEXC
         CALL "TS-STATE-SET" USING BE-DIM(L-INDEX) BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-KIND2 WS-ONE
         CALL "LEVEL-EVENT" USING BE-DIM(L-INDEX) WS-EV3020 BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-ONE WS-ZERO
         CALL "TS-OMINOUS-RESET" USING L-INDEX L-TIME
     END-IF
     IF WS-STOP = 1
         GOBACK
     END-IF
     IF WS-SOURCE = 1
         MOVE WS-ROWS1 TO WS-ROWS2
         MOVE WS-N1 TO WS-N2
     ELSE
         CALL "TS-DETECT-LIST" USING L-INDEX WS-ZERO WS-ROWS2 WS-N2
     END-IF
     MOVE 0 TO WS-ADDED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N2
         MOVE WS-R2(WS-I) TO WS-ROW
         CALL "TS-UUID-INTS" USING PL-UUID(WS-ROW) WS-UUID
         MOVE 1 TO WS-BASE
         CALL "BE7-UUID-IN" USING L-INDEX WS-BASE BE-XI(L-INDEX, 1) WS-UUID WS-FOUND
         IF WS-FOUND = 0 AND BE-XI(L-INDEX, 1) < 16
             COMPUTE WS-A = BE-XI(L-INDEX, 1) * 4
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
                 COMPUTE WS-CELL = WS-A + WS-J
                 MOVE WS-U(WS-J) TO BE-UUID(L-INDEX, WS-CELL)
             END-PERFORM
             ADD 1 TO BE-XI(L-INDEX, 1)
             ADD 1 TO WS-ADDED
         END-IF
     END-PERFORM
     CALL "BE7-DETECT-ADDED" USING L-INDEX L-TIME WS-ADDED L-APPLIED L-OMINOUS WS-EVENT
     IF WS-EVENT > 0
         CALL "LEVEL-EVENT" USING BE-DIM(L-INDEX) WS-EVENT BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) BE-XI(L-INDEX, 1) WS-ZERO
     END-IF
     GOBACK.
 END PROGRAM TS-DETECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TS-SPAWN.
*> USING state (XORO), index, ominous (1 or 0), ok out: TrialSpawner.spawnMob (4.7). The next spawn data (taken, or picked) must have an id the core can make; the position is the spawner's random one
*> (spawn_range 4, as 2.2); the two cells must be free, the chunk made, a visual ray from the block centre must reach the spawn cell, the placement rule with the reason TRIAL_SPAWNER (light ignored)
*> must hold and, when the spawn data has custom rules, they too. The mob is persistent, finalized, its UUID is added to current_mobs and level events 3011 and 3012 are sent at the block with the flame
*> code (0 normal, 1 ominous).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BESTATE.
 COPY STDMOBS.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-NOEXC               BINARY-LONG VALUE 0.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-SPECIES             PIC X(24).
 01 WS-KEY48               PIC X(48).
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLEN                BINARY-LONG.
 01 WS-D1                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IY                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-READY               BINARY-LONG.
 01 WS-K1                  BINARY-LONG.
 01 WS-K2                  BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-CLEAR               BINARY-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-REASON              BINARY-LONG VALUE 3.
 01 WS-OK                  BINARY-LONG.
 01 WS-RULES.
    05 WS-RULE-SET         BINARY-LONG.
    05 WS-RULE-BMIN        BINARY-LONG.
    05 WS-RULE-BMAX        BINARY-LONG.
    05 WS-RULE-SMIN        BINARY-LONG.
    05 WS-RULE-SMAX        BINARY-LONG.
 01 WS-EKEY                PIC X(112).
 01 WS-TYPE                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-NEW                 BINARY-LONG.
 01 WS-INTS.
    05 WS-INT              BINARY-LONG OCCURS 4 TIMES.
 01 WS-BASE                BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-FLAME               BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-INDEX                BINARY-LONG.
 01 L-OMINOUS              BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-INDEX L-OMINOUS L-OK.
     MOVE 0 TO L-OK
     MOVE 0 TO WS-ZERO
     CALL "TS-NEXT-DATA" USING L-STATE L-INDEX WS-ZERO
     MOVE SPACES TO WS-SPECIES
     IF BE-XI(L-INDEX, 5) > 10 AND BE-XI(L-INDEX, 5) < 35 AND BE-XT(L-INDEX, 1)(1:10) = "minecraft:"
         COMPUTE WS-SLEN = BE-XI(L-INDEX, 5) - 10
         MOVE BE-XT(L-INDEX, 1)(11:WS-SLEN) TO WS-SPECIES
     END-IF
     MOVE WS-SPECIES TO WS-KEY48
     CALL "MS6-SPECIES" USING WS-KEY48 WS-ROW
     IF WS-SPECIES = SPACES OR WS-ROW = 0
         GOBACK
     END-IF
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D1
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D2
     COMPUTE WS-FX = BE-X(L-INDEX) + (WS-D1 - WS-D2) * 4 + 0.5
     CALL "XORO-NEXT-INT" USING L-STATE WS-THREE WS-A
     COMPUTE WS-IY = BE-Y(L-INDEX) + WS-A - 1
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D1
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D2
     COMPUTE WS-FZ = BE-Z(L-INDEX) + (WS-D1 - WS-D2) * 4 + 0.5
     COMPUTE WS-IX = FUNCTION INTEGER(WS-FX)
     COMPUTE WS-IZ = FUNCTION INTEGER(WS-FZ)
     COMPUTE WS-CX = FUNCTION INTEGER(WS-FX / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-FZ / 16)
     CALL "STDMOB-READY" USING BE-DIM(L-INDEX) WS-CX WS-CZ WS-READY
     CALL "MS6-BLOCK-KIND" USING BE-DIM(L-INDEX) WS-IX WS-IY WS-IZ WS-K1
     COMPUTE WS-ABOVE = WS-IY + 1
     CALL "MS6-BLOCK-KIND" USING BE-DIM(L-INDEX) WS-IX WS-ABOVE WS-IZ WS-K2
     IF WS-K1 NOT = 0 OR WS-K2 NOT = 0 OR WS-READY = 0
         GOBACK
     END-IF
     COMPUTE WS-SX = BE-X(L-INDEX) + 0.5
     COMPUTE WS-SY = BE-Y(L-INDEX) + 0.5
     COMPUTE WS-SZ = BE-Z(L-INDEX) + 0.5
     CALL "TS-LOS" USING BE-DIM(L-INDEX) WS-SX WS-SY WS-SZ WS-IX WS-IY WS-IZ WS-CLEAR
     IF WS-CLEAR = 0
         GOBACK
     END-IF
     CALL "MS6-RULE-AT" USING L-STATE BE-DIM(L-INDEX) WS-ROW WS-IX WS-IY WS-IZ WS-REASON WS-OK
     IF WS-OK = 1 AND BE-XI(L-INDEX, 16) = 1
         MOVE 1 TO WS-RULE-SET
         MOVE BE-XI(L-INDEX, 12) TO WS-RULE-BMIN
         MOVE BE-XI(L-INDEX, 13) TO WS-RULE-BMAX
         MOVE BE-XI(L-INDEX, 14) TO WS-RULE-SMIN
         MOVE BE-XI(L-INDEX, 15) TO WS-RULE-SMAX
         CALL "SPW-CUSTOM-OK" USING BE-DIM(L-INDEX) WS-IX WS-IY WS-IZ WS-ROW WS-RULES WS-OK
     END-IF
     IF WS-OK = 0
         GOBACK
     END-IF
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D1
     COMPUTE WS-YAW = WS-D1 * 360
     MOVE WS-IY TO WS-FY
     MOVE SPACES TO WS-EKEY
     STRING "minecraft:" DELIMITED BY SIZE WS-SPECIES DELIMITED BY SPACE INTO WS-EKEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING BE-DIM(L-INDEX) WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-NEW
     MOVE 1 TO EN-PERSISTENT(WS-NEW)
     CALL "STDMOB-FINALIZE" USING L-STATE WS-NEW
     CALL "TS-UUID-INTS" USING EN-UUID(WS-NEW) WS-INTS
     IF BE-XI(L-INDEX, 2) < 64
         COMPUTE WS-BASE = 64 + BE-XI(L-INDEX, 2) * 4
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
             COMPUTE WS-CELL = WS-BASE + WS-J
             MOVE WS-INT(WS-J) TO BE-UUID(L-INDEX, WS-CELL)
         END-PERFORM
         ADD 1 TO BE-XI(L-INDEX, 2)
     END-IF
     MOVE L-OMINOUS TO WS-FLAME
     MOVE 3011 TO WS-EVENT
     CALL "LEVEL-EVENT" USING BE-DIM(L-INDEX) WS-EVENT BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-FLAME WS-ZERO
     MOVE 3012 TO WS-EVENT
     CALL "LEVEL-EVENT" USING BE-DIM(L-INDEX) WS-EVENT BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-FLAME WS-ZERO
     MOVE 1 TO L-OK
     GOBACK.
 END PROGRAM TS-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TS-EJECT.
*> USING index: ejectReward (4.8): the table of ejecting_loot_table is rolled with an empty context (LOOT-ROLL, no seed), every stack becomes an item entity (spawnItem of 30-4 2 with accuracy 2,
*> direction UP: the bottom centre of the block 1.2 up, less 0.125, speed nextDouble x 0.1 + 0.2, motion triangle(0, 0.0344550), triangle(0.2, 0.0344550), triangle(0, 0.0344550)), and level event
*> 3014 (data 0) follows only when the roll was not empty. A table the content set does not hold rolls nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BESTATE.
 COPY LOOTCTX.
 01 WS-KEY                 PIC X(112).
 01 WS-I                   BINARY-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-X1                  FLOAT-LONG.
 01 WS-X2                  FLOAT-LONG.
 01 WS-Y1                  FLOAT-LONG.
 01 WS-Y2                  FLOAT-LONG.
 01 WS-Z1                  FLOAT-LONG.
 01 WS-Z2                  FLOAT-LONG.
 01 WS-SX                  BINARY-LONG VALUE 0.
 01 WS-SY                  BINARY-LONG VALUE 1.
 01 WS-SZ                  BINARY-LONG VALUE 0.
 01 WS-ACC                 BINARY-LONG VALUE 2.
 01 WS-VX                  BINARY-LONG.
 01 WS-VY                  BINARY-LONG.
 01 WS-VZ                  BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-FVX                 FLOAT-LONG.
 01 WS-FVY                 FLOAT-LONG.
 01 WS-FVZ                 FLOAT-LONG.
 01 WS-DELAY               BINARY-LONG VALUE 10.
 01 WS-ROW                 BINARY-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 3014.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-NOEXC               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     MOVE SPACES TO WS-KEY
     MOVE BE-XT(L-INDEX, 2)(1:BE-XI(L-INDEX, 6)) TO WS-KEY
     INITIALIZE LOOT-CONTEXT
     CALL "LOOT-ROLL" USING WS-KEY LOOT-CONTEXT LOOT-RESULT
     IF LR-STATUS NOT = 0 OR LR-COUNT = 0
         GOBACK
     END-IF
     COMPUTE WS-FX = BE-X(L-INDEX) + 0.5
     COMPUTE WS-FY = BE-Y(L-INDEX) + 1.2 - 0.125
     COMPUTE WS-FZ = BE-Z(L-INDEX) + 0.5
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > LR-COUNT
         CALL "IP-LEVEL-DOUBLE" USING WS-D
         CALL "IP-LEVEL-DOUBLE" USING WS-X1
         CALL "IP-LEVEL-DOUBLE" USING WS-X2
         CALL "IP-LEVEL-DOUBLE" USING WS-Y1
         CALL "IP-LEVEL-DOUBLE" USING WS-Y2
         CALL "IP-LEVEL-DOUBLE" USING WS-Z1
         CALL "IP-LEVEL-DOUBLE" USING WS-Z2
         CALL "RS2-SPAWN-MOTION" USING WS-SX WS-SY WS-SZ WS-ACC WS-D WS-X1 WS-X2 WS-Y1 WS-Y2 WS-Z1 WS-Z2 WS-VX WS-VY WS-VZ
         COMPUTE WS-FVX = WS-VX / 10000000
         COMPUTE WS-FVY = WS-VY / 10000000
         COMPUTE WS-FVZ = WS-VZ / 10000000
         CALL "GI-SPAWN-X" USING BE-DIM(L-INDEX) WS-FX WS-FY WS-FZ WS-FVX WS-FVY WS-FVZ LR-ITEM(WS-I) LR-AMOUNT(WS-I) WS-DELAY WS-ROW LR-HANDLE(WS-I)
     END-PERFORM
     CALL "LEVEL-EVENT" USING BE-DIM(L-INDEX) WS-EVENT BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-ZERO WS-NOEXC
     GOBACK.
 END PROGRAM TS-EJECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TS-OVERRIDE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-NOEXC               BINARY-LONG VALUE 0.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-INACTIVE            BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-ID                   PIC X(64).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-ID L-LENGTH.
     MOVE 0 TO BE-XI(L-INDEX, 2) BE-XI(L-INDEX, 4) BE-XI(L-INDEX, 5) BE-XI(L-INDEX, 16)
     MOVE SPACES TO BE-XT(L-INDEX, 1)
     CALL "TS-RESET-STATS" USING L-INDEX
     MOVE L-ID TO BE-XT(L-INDEX, 5)
     MOVE L-LENGTH TO BE-XI(L-INDEX, 18)
     MOVE 1 TO BE-XI(L-INDEX, 17)
     MOVE 0 TO BE-STATUS(L-INDEX)
     CALL "TS-STATE-SET" USING BE-DIM(L-INDEX) BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-KIND WS-INACTIVE
     CALL "BE-MARK-CHUNK" USING L-INDEX
     GOBACK.
 END PROGRAM TS-OVERRIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TRIAL-SPAWNER-TICK.
*> USING index: tickServer (4.4) for a live trial spawner: the lost mobs are forgotten, then the row of the block state's trial_spawner_state runs (the table of 4.4 in order), and the block state
*> takes the next state when it differs. canSpawnInLevel is spawner_blocks_work and not Peaceful and spawn_mobs; hasMobToSpawn is a next spawn data with an id or a spawn egg's potentials. The
*> ominous item spawner (4.6), the display entity, the client particles and the sounds are not modelled.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BESTATE.
 COPY BRWORLD.
 COPY XORO REPLACING LEADING ==XR-== BY ==WS-==.
 01 WS-SEEDED              BINARY-LONG VALUE 0.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 20260613.
 01 WS-TS               BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-OMINOUS             BINARY-LONG.
 01 WS-APPLIED             BINARY-LONG.
 01 WS-TIME                BINARY-DOUBLE.
 01 WS-START               BINARY-DOUBLE.
 01 WS-F1                  FLOAT-SHORT.
 01 WS-F2                  FLOAT-SHORT.
 01 WS-RULE-WORK           PIC X(40) VALUE "spawner_blocks_work".
 01 WS-RULE-MOBS           PIC X(40) VALUE "spawn_mobs".
 01 WS-WORK                BINARY-DOUBLE.
 01 WS-MOBS                BINARY-DOUBLE.
 01 WS-WORK-L              BINARY-LONG.
 01 WS-MOBS-L              BINARY-LONG.
 01 WS-PEACEFUL            BINARY-LONG.
 01 WS-OVERRIDE            BINARY-LONG VALUE 0.
 01 WS-CAN                 BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-EXTRA               BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-SIMULTANEOUS        BINARY-LONG.
 01 WS-F-TOTAL             FLOAT-SHORT VALUE 6.0.
 01 WS-F-TOTAL-PER         FLOAT-SHORT VALUE 2.0.
 01 WS-F-SIMUL             FLOAT-SHORT VALUE 2.0.
 01 WS-F-SIMUL-PER         FLOAT-SHORT VALUE 1.0.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-NOEXC               BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-OK                  BINARY-LONG.
 01 WS-DUE                 BINARY-LONG.
 01 WS-EJECT               BINARY-LONG.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-PICK                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-KIND1               BINARY-LONG VALUE 1.
 01 WS-KIND2               BINARY-LONG VALUE 2.
 01 WS-LEN30               BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-DIFF                BINARY-DOUBLE.
 01 WS-BASE-UUID           BINARY-LONG.
 01 WS-INTS.
    05 WS-INT              BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX.
     IF WS-SEEDED = 0
         CALL "XORO-SEED" USING WS-SEED WS-STATE
         MOVE 1 TO WS-SEEDED
     END-IF
     CALL "TS-STATE-GET" USING BE-DIM(L-INDEX) BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-TS WS-OMINOUS
     COMPUTE WS-TIME = CW-GAME-TIME + CW-TICKS
     CALL "TS-UNTRACK" USING L-INDEX WS-TIME
     CALL "BR-RULE-GET" USING WS-RULE-WORK WS-WORK
     CALL "BR-RULE-GET" USING WS-RULE-MOBS WS-MOBS
     MOVE WS-WORK TO WS-WORK-L
     MOVE WS-MOBS TO WS-MOBS-L
     MOVE 0 TO WS-PEACEFUL
     IF BW-DIFFICULTY = 0
         MOVE 1 TO WS-PEACEFUL
     END-IF
     CALL "BE7-CAN-SPAWN" USING WS-WORK-L WS-OVERRIDE WS-PEACEFUL WS-MOBS-L WS-CAN
     CALL "BE7-HAS-MOB" USING L-INDEX BE-XI(L-INDEX, 17) WS-HAS
     MOVE WS-TS TO WS-NEXT
     EVALUATE WS-TS
         WHEN 0
             IF WS-HAS = 1
                 CALL "TS-NEXT-DATA" USING WS-STATE L-INDEX WS-ZERO
                 IF BE-XI(L-INDEX, 5) > 0
                     MOVE 1 TO WS-NEXT
                 END-IF
             END-IF
         WHEN 1
             IF WS-CAN = 0
                 CALL "TS-RESET-STATS" USING L-INDEX
             ELSE
                 IF WS-HAS = 0
                     MOVE 0 TO WS-NEXT
                 ELSE
                     CALL "TS-DETECT" USING L-INDEX WS-OMINOUS WS-TS WS-TIME WS-APPLIED
                     IF BE-XI(L-INDEX, 1) > 0
                         MOVE 2 TO WS-NEXT
                     END-IF
                 END-IF
             END-IF
         WHEN 2
             IF WS-CAN = 0
                 CALL "TS-RESET-STATS" USING L-INDEX
                 MOVE 1 TO WS-NEXT
             ELSE
                 IF WS-HAS = 0
                     MOVE 0 TO WS-NEXT
                 ELSE
                     COMPUTE WS-EXTRA = FUNCTION MAX(BE-XI(L-INDEX, 1) - 1, 0)
                     CALL "TS-DETECT" USING L-INDEX WS-OMINOUS WS-TS WS-TIME WS-APPLIED
                     IF WS-APPLIED = 1
                         MOVE 1 TO WS-OMINOUS
                     END-IF
                     CALL "BE7-TRIAL-TOTALS" USING WS-F-TOTAL WS-F-TOTAL-PER WS-F-SIMUL WS-F-SIMUL-PER WS-EXTRA WS-TOTAL WS-SIMULTANEOUS
                     IF BE-XI(L-INDEX, 3) >= WS-TOTAL
                         IF BE-XI(L-INDEX, 2) = 0
                             COMPUTE BE-SEED(L-INDEX) = WS-TIME + BE-XI(L-INDEX, 9)
                             MOVE 0 TO BE-XI(L-INDEX, 3) BE-TIME2(L-INDEX)
                             MOVE 3 TO WS-NEXT
                         END-IF
                     ELSE
                         IF WS-TIME >= BE-TIME2(L-INDEX) AND BE-XI(L-INDEX, 2) < WS-SIMULTANEOUS
                             CALL "TS-SPAWN" USING WS-STATE L-INDEX WS-OMINOUS WS-OK
                             IF WS-OK = 1
                                 ADD 1 TO BE-XI(L-INDEX, 3)
                                 COMPUTE BE-TIME2(L-INDEX) = WS-TIME + 40
                                 CALL "TS-NEXT-DATA" USING WS-STATE L-INDEX WS-ONE
                             END-IF
                         END-IF
                     END-IF
                 END-IF
             END-IF
         WHEN 3
             COMPUTE WS-START = BE-SEED(L-INDEX) - BE-XI(L-INDEX, 9)
             MOVE WS-TIME TO WS-F1
             COMPUTE WS-F2 = WS-START + 40.0
             IF WS-F1 >= WS-F2
                 MOVE 4 TO WS-NEXT
             END-IF
         WHEN 4
             COMPUTE WS-START = BE-SEED(L-INDEX) - BE-XI(L-INDEX, 9)
             COMPUTE WS-DIFF = WS-TIME - WS-START
             IF FUNCTION MOD(WS-DIFF, 30) = 0
                 IF BE-XI(L-INDEX, 1) = 0
                     MOVE 0 TO BE-XI(L-INDEX, 6)
                     MOVE 5 TO WS-NEXT
                 ELSE
                     IF BE-XI(L-INDEX, 6) = 0
                         CALL "XORO-NEXT-INT" USING WS-STATE WS-TWO WS-PICK
                         MOVE SPACES TO BE-XT(L-INDEX, 2)
                         IF WS-PICK = 0
                             MOVE "minecraft:spawners/trial_chamber/consumables" TO BE-XT(L-INDEX, 2)
                             MOVE 44 TO BE-XI(L-INDEX, 6)
                         ELSE
                             MOVE "minecraft:spawners/trial_chamber/key" TO BE-XT(L-INDEX, 2)
                             MOVE 37 TO BE-XI(L-INDEX, 6)
                         END-IF
                     END-IF
                     CALL "TS-EJECT" USING L-INDEX
*>                   one detected player leaves the set, the first
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
                         COMPUTE WS-A = WS-I + 4
                         MOVE BE-UUID(L-INDEX, WS-A) TO BE-UUID(L-INDEX, WS-I)
                     END-PERFORM
                     SUBTRACT 1 FROM BE-XI(L-INDEX, 1)
                 END-IF
             END-IF
         WHEN OTHER
             CALL "TS-DETECT" USING L-INDEX WS-OMINOUS WS-TS WS-TIME WS-APPLIED
             IF BE-XI(L-INDEX, 1) > 0
                 MOVE 0 TO BE-XI(L-INDEX, 3) BE-TIME2(L-INDEX)
                 MOVE 2 TO WS-NEXT
             ELSE
                 IF WS-TIME >= BE-SEED(L-INDEX)
                     CALL "TS-STATE-SET" USING BE-DIM(L-INDEX) BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-KIND2 WS-ZERO
                     MOVE 0 TO BE-XI(L-INDEX, 2) BE-XI(L-INDEX, 4) BE-XI(L-INDEX, 5) BE-XI(L-INDEX, 16)
                     MOVE SPACES TO BE-XT(L-INDEX, 1)
                     CALL "TS-RESET-STATS" USING L-INDEX
                     MOVE 1 TO WS-NEXT
                 END-IF
             END-IF
     END-EVALUATE
     IF WS-NEXT NOT = WS-TS
         CALL "TS-STATE-SET" USING BE-DIM(L-INDEX) BE-X(L-INDEX) BE-Y(L-INDEX) BE-Z(L-INDEX) WS-KIND1 WS-NEXT
         MOVE WS-NEXT TO BE-STATUS(L-INDEX)
         CALL "BE-MARK-CHUNK" USING L-INDEX
     END-IF
     GOBACK.
 END PROGRAM TRIAL-SPAWNER-TICK.
