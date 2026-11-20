*> Live redstone, observers and pressure plates (docs/protocol/30-redstone-2 section 6, 30-redstone-5 section 4 over the signal model of redstone-live.cob): the observer's detection,
*> pulse and removal hooks, the pressure plates' counting of the entities in their touch box, the check that writes the new signal, the re-check tick and the per-tick entity scan that
*> stands for `entityInside` (every entity whose box overlaps the touch box of an unpressed plate runs the check).
*> Deviations: no click sound and no BLOCK_ACTIVATE or BLOCK_DEACTIVATE game event goes out (the table row decides them, nothing is sent); an entity counts as a LivingEntity unless its key
*> holds one of the non-living words of RL-ENTITY-LIVING (the entity tables of this core carry no class); an armor stand counts as no marker; a player's box is 0.6 by 1.8 of the entity type
*> row (a sneaking player is not shortened).
*> Entry points:
*>   RL-OBS-HOOK USING kind, dimension row, x, y, z, state, a, b    kinds 1 onPlace, 2 removal, 4 updateShape, 7 tick of an observer
*>   RL-PLATE-HOOK USING kind, dimension row, x, y, z, state, a, b    kinds 2 removal and 7 tick of a pressure plate (on-off and weighted)
*>   RL-PLATE-CHECK USING dimension row, x, y, z, state, entity triggered    checkPressed (30-5 4.1)
*>   REDSTONE-ENTITY-TICK    once per game tick (CORE-TICK): entityInside of the plates

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-SET-NUM.
*> USING state, property name (PIC X(16)), value 0 to 15, state out: the state with that numeric property set (the state itself when it has none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OLD                 PIC X(16).
 01 WS-TEXT                PIC X(16).
 01 WS-N                   PIC Z9.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-NAME                 PIC X(16).
 01 L-VALUE                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-NAME L-VALUE L-OUT.
     MOVE L-VALUE TO WS-N
     MOVE SPACES TO WS-TEXT
     MOVE FUNCTION TRIM(WS-N) TO WS-TEXT
     CALL "SW-SET-PROP" USING L-STATE L-NAME WS-TEXT L-OUT WS-OLD
     GOBACK.
 END PROGRAM RL-SET-NUM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-OBS-HOOK RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 01 WS-POWERED             PIC X(16) VALUE "powered".
 LOCAL-STORAGE SECTION.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-F                   BINARY-LONG.
 01 LS-ON                  BINARY-LONG.
 01 LS-PENDING             BINARY-LONG.
 01 LS-CLIENT              BINARY-LONG VALUE 0.
 01 LS-SCHEDULE            BINARY-LONG.
 01 LS-SERVER              BINARY-LONG VALUE 1.
 01 LS-SAME                BINARY-LONG.
 01 LS-RESET               BINARY-LONG.
 01 LS-NEW                 BINARY-LONG.
 01 LS-NEW-ON              BINARY-LONG.
 01 LS-DELAY               BINARY-LONG.
 01 LS-NOTIFY              BINARY-LONG.
 01 LS-TYPE                BINARY-LONG VALUE 1.
 01 LS-PRIO                BINARY-LONG VALUE 0.
 01 LS-RESULT              BINARY-LONG.
 01 LS-FLAGS               BINARY-LONG.
 01 LS-BUDGET              BINARY-LONG VALUE 512.
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
     MOVE RL-S-DIR(L-STATE + 1) TO LS-F
     MOVE RL-S-ON(L-STATE + 1) TO LS-ON
     CALL "BT-HAS" USING L-DIM LS-TYPE LS-BLOCK L-X L-Y L-Z LS-PENDING
     EVALUATE L-KIND
         WHEN 4
*>           updateShape (6.3): a change on the watched side starts the pulse
             CALL "RS1-OBS-SU" USING L-A LS-F LS-ON LS-CLIENT LS-PENDING LS-SCHEDULE
             IF LS-SCHEDULE = 1
                 MOVE 2 TO LS-DELAY
                 CALL "BT-SCHEDULE" USING L-DIM LS-TYPE LS-BLOCK L-X L-Y L-Z LS-DELAY LS-PRIO LS-RESULT
             END-IF
         WHEN 7
*>           the pulse (6.4): on for 2 ticks, the back is told each time
             CALL "RS1-OBS-TICK" USING LS-ON LS-NEW-ON LS-DELAY LS-NOTIFY
             CALL "RL-SET-BOOL" USING L-STATE WS-POWERED LS-NEW-ON LS-NEW
             MOVE 2 TO LS-FLAGS
             CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
             IF LS-DELAY > 0
                 CALL "BT-SCHEDULE" USING L-DIM LS-TYPE LS-BLOCK L-X L-Y L-Z LS-DELAY LS-PRIO LS-RESULT
             END-IF
             IF LS-NOTIFY = 1
                 CALL "RL-FRONT" USING L-DIM L-X L-Y L-Z LS-F LS-BLOCK
             END-IF
         WHEN 1
*>           onPlace (6.5): a freshly placed powered observer is reset
             CALL "RL-SAME-BLOCK" USING L-STATE L-A LS-SAME
             CALL "RS1-OBS-ONPLACE" USING LS-SAME LS-SERVER LS-ON LS-PENDING LS-RESET
             IF LS-RESET = 1
                 MOVE 0 TO LS-NEW-ON
                 CALL "RL-SET-BOOL" USING L-STATE WS-POWERED LS-NEW-ON LS-NEW
                 MOVE 18 TO LS-FLAGS
                 CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
                 CALL "RL-FRONT" USING L-DIM L-X L-Y L-Z LS-F LS-BLOCK
             END-IF
         WHEN 2
*>           affectNeighborsAfterRemoval (6.5): the back is told when a pulse was on the way
             CALL "RS1-OBS-REMOVAL" USING LS-ON LS-PENDING LS-NOTIFY
             IF LS-NOTIFY = 1
                 CALL "RL-FRONT" USING L-DIM L-X L-Y L-Z LS-F LS-BLOCK
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM RL-OBS-HOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-ENTITY-FACTS.
*> USING entity row, x, y, z (FLOAT-LONG, the position the box stands at), half width, height (FLOAT-LONG), counted out, living out : the facts of 30-5 4.1 about an entity row of the
*> tracker: the position (a player's own row), the box, whether a plate counts it and whether it is a LivingEntity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-KEY                 PIC X(48).
 01 WS-BARE                PIC X(48).
 01 WS-HITS                BINARY-LONG.
 01 WS-SPECTATOR           BINARY-LONG.
 01 WS-IGNORES             BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-MARKER              BINARY-LONG VALUE 0.
 01 WS-PLAYER              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-HALF                 FLOAT-LONG.
 01 L-HEIGHT               FLOAT-LONG.
 01 L-COUNTED              BINARY-LONG.
 01 L-LIVING               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-HALF L-HEIGHT L-COUNTED L-LIVING.
     MOVE EN-X(L-ROW) TO L-X
     MOVE EN-Y(L-ROW) TO L-Y
     MOVE EN-Z(L-ROW) TO L-Z
     MOVE EN-PLAYER(L-ROW) TO WS-PLAYER
     MOVE 0 TO WS-SPECTATOR
     IF WS-PLAYER > 0
         MOVE PL-X(WS-PLAYER) TO L-X
         MOVE PL-Y(WS-PLAYER) TO L-Y
         MOVE PL-Z(WS-PLAYER) TO L-Z
         IF PL-MODE(WS-PLAYER) = 3
             MOVE 1 TO WS-SPECTATOR
         END-IF
     END-IF
     COMPUTE L-HALF = ET-WIDTH-MILLI(EN-TYPE(L-ROW) + 1) / 2000
     COMPUTE L-HEIGHT = ET-HEIGHT-MILLI(EN-TYPE(L-ROW) + 1) / 1000
     MOVE ET-KEY(EN-TYPE(L-ROW) + 1) TO WS-KEY
     CALL "KEY-BARE" USING WS-KEY WS-BARE
*>   isIgnoringBlockTriggers (4.1): the six classes
     MOVE 0 TO WS-CLASS
     MOVE 0 TO WS-HITS
     INSPECT WS-BARE TALLYING WS-HITS FOR ALL "display"
     IF WS-HITS > 0
         MOVE 1 TO WS-CLASS
     END-IF
     IF WS-BARE = "interaction"
         MOVE 2 TO WS-CLASS
     END-IF
     IF WS-BARE = "marker"
         MOVE 3 TO WS-CLASS
     END-IF
     IF WS-BARE = "ominous_item_spawner"
         MOVE 4 TO WS-CLASS
     END-IF
     IF WS-BARE = "armor_stand"
         MOVE 5 TO WS-CLASS
     END-IF
     IF WS-BARE = "bat"
         MOVE 6 TO WS-CLASS
     END-IF
     CALL "RS2-IGNORES-TRIGGERS" USING WS-CLASS WS-MARKER WS-IGNORES
     CALL "RS2-PLATE-COUNTED" USING WS-SPECTATOR WS-IGNORES L-COUNTED
*>   LivingEntity: a player, or an entity of none of the non-living kinds
     MOVE 1 TO L-LIVING
     MOVE 0 TO WS-HITS
     INSPECT WS-BARE TALLYING WS-HITS FOR ALL "item" ALL "tnt" ALL "arrow" ALL "trident" ALL "experience" ALL "boat" ALL "minecart"
         ALL "painting" ALL "end_crystal" ALL "falling_block" ALL "snowball" ALL "egg" ALL "ender_pearl" ALL "eye_of_ender" ALL "potion"
         ALL "fireball" ALL "firework" ALL "bobber" ALL "spit" ALL "bullet" ALL "wind_charge" ALL "leash" ALL "cloud" ALL "lightning"
         ALL "fangs" ALL "display" ALL "marker" ALL "interaction"
     IF WS-HITS > 0 AND WS-PLAYER = 0
         MOVE 0 TO L-LIVING
     END-IF
     GOBACK.
 END PROGRAM RL-ENTITY-FACTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-BOX-COUNT.
*> USING dimension row, low x, high x, low y, high y, low z, high z (FLOAT-LONG), all out, living out: the entities counted (30-5 4.1) whose box, standing at the entity's position, overlaps the
*> given box strictly.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-COUNTED             BINARY-LONG.
 01 WS-LIVING              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-LOX                  FLOAT-LONG.
 01 L-HIX                  FLOAT-LONG.
 01 L-LOY                  FLOAT-LONG.
 01 L-HIY                  FLOAT-LONG.
 01 L-LOZ                  FLOAT-LONG.
 01 L-HIZ                  FLOAT-LONG.
 01 L-ALL                  BINARY-LONG.
 01 L-LIVE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-LOX L-HIX L-LOY L-HIY L-LOZ L-HIZ L-ALL L-LIVE.
     MOVE 0 TO L-ALL L-LIVE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-DIM(WS-I) = L-DIM
             CALL "RL-ENTITY-FACTS" USING WS-I WS-X WS-Y WS-Z WS-HALF WS-HEIGHT WS-COUNTED WS-LIVING
             IF WS-COUNTED = 1 AND WS-X + WS-HALF > L-LOX AND WS-X - WS-HALF < L-HIX AND WS-Z + WS-HALF > L-LOZ
                     AND WS-Z - WS-HALF < L-HIZ AND WS-Y + WS-HEIGHT > L-LOY AND WS-Y < L-HIY
                 ADD 1 TO L-ALL
                 IF WS-LIVING = 1
                     ADD 1 TO L-LIVE
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RL-BOX-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-PLATE-COUNT.
*> USING dimension row, x, y, z of a plate, all out, living out: the entities counted in the touch box (30-5 4.1): the box (x + 1/16, y, z + 1/16) to (x + 15/16, y + 1/4, z + 15/16).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LOX                 FLOAT-LONG.
 01 WS-HIX                 FLOAT-LONG.
 01 WS-LOZ                 FLOAT-LONG.
 01 WS-HIZ                 FLOAT-LONG.
 01 WS-LOY                 FLOAT-LONG.
 01 WS-HIY                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ALL                  BINARY-LONG.
 01 L-LIVE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ALL L-LIVE.
     COMPUTE WS-LOX = L-X + 0.0625
     COMPUTE WS-HIX = L-X + 0.9375
     COMPUTE WS-LOZ = L-Z + 0.0625
     COMPUTE WS-HIZ = L-Z + 0.9375
     MOVE L-Y TO WS-LOY
     COMPUTE WS-HIY = L-Y + 0.25
     CALL "RL-BOX-COUNT" USING L-DIM WS-LOX WS-HIX WS-LOY WS-HIY WS-LOZ WS-HIZ L-ALL L-LIVE
     GOBACK.
 END PROGRAM RL-PLATE-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-PLATE-CHECK RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 01 WS-POWERED             PIC X(16) VALUE "powered".
 01 WS-POWER               PIC X(16) VALUE "power".
 LOCAL-STORAGE SECTION.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-CLASS               BINARY-LONG.
 01 LS-KEY                 PIC X(48).
 01 LS-BARE                PIC X(48).
 01 LS-NAME40              PIC X(40).
 01 LS-NAME32              PIC X(32).
 01 LS-ALL                 BINARY-LONG.
 01 LS-LIVE                BINARY-LONG.
 01 LS-OLD                 BINARY-LONG.
 01 LS-NEW                 BINARY-LONG.
 01 LS-SET                 BINARY-LONG.
 01 LS-SENS                BINARY-LONG.
 01 LS-FAM                 BINARY-LONG.
 01 LS-TIME                BINARY-LONG.
 01 LS-MAX                 BINARY-LONG.
 01 LS-WRITE               BINARY-LONG.
 01 LS-FLAGS               BINARY-LONG.
 01 LS-UPDATED             BINARY-LONG.
 01 LS-DIRTY               BINARY-LONG.
 01 LS-SOUND               BINARY-LONG.
 01 LS-EVENT               BINARY-LONG.
 01 LS-REARM               BINARY-LONG.
 01 LS-STATE               BINARY-LONG.
 01 LS-BUDGET              BINARY-LONG VALUE 512.
 01 LS-RESULT              BINARY-LONG.
 01 LS-BELOW               BINARY-LONG.
 01 LS-TYPE                BINARY-LONG VALUE 1.
 01 LS-PRIO                BINARY-LONG VALUE 0.
 01 LS-ON                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-RUN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE L-RUN.
     MOVE CB-S-BLOCK(L-STATE + 1) TO LS-BLOCK
     MOVE RL-CLASS(LS-BLOCK + 1) TO LS-CLASS
     MOVE CB-KEY(LS-BLOCK + 1) TO LS-KEY
     CALL "KEY-BARE" USING LS-KEY LS-BARE
     CALL "RL-PLATE-COUNT" USING L-DIM L-X L-Y L-Z LS-ALL LS-LIVE
     IF LS-CLASS = 19
         MOVE LS-BARE TO LS-NAME32
         MOVE RL-S-POWER(L-STATE + 1) TO LS-OLD
         CALL "RS2-WEIGHTED-INFO" USING LS-NAME32 LS-MAX LS-SET LS-TIME LS-FAM
         CALL "RS2-WEIGHTED-STRENGTH" USING LS-ALL LS-MAX LS-NEW
     ELSE
         MOVE LS-BARE TO LS-NAME40
         MOVE 0 TO LS-OLD
         IF RL-S-ON(L-STATE + 1) = 1
             MOVE 15 TO LS-OLD
         END-IF
         CALL "RS2-PLATE-INFO" USING LS-NAME40 LS-SET LS-SENS LS-FAM LS-TIME
         CALL "RS2-PLATE-STRENGTH" USING LS-SENS LS-ALL LS-LIVE LS-NEW
     END-IF
     CALL "RS2-PLATE-CHECK" USING LS-OLD LS-NEW LS-TIME LS-WRITE LS-FLAGS LS-UPDATED LS-DIRTY LS-SOUND LS-EVENT LS-REARM
     IF LS-WRITE = 1
         IF LS-CLASS = 19
             CALL "RL-SET-NUM" USING L-STATE WS-POWER LS-NEW LS-STATE
         ELSE
             MOVE 0 TO LS-ON
             IF LS-NEW > 0
                 MOVE 1 TO LS-ON
             END-IF
             CALL "RL-SET-BOOL" USING L-STATE WS-POWERED LS-ON LS-STATE
         END-IF
         CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-STATE LS-FLAGS LS-BUDGET LS-RESULT
         IF LS-UPDATED = 1
             COMPUTE LS-BELOW = L-Y - 1
             CALL "BU-NEIGHBORS-AT" USING L-DIM L-X L-Y L-Z LS-BLOCK
             CALL "BU-NEIGHBORS-AT" USING L-DIM L-X LS-BELOW L-Z LS-BLOCK
         END-IF
     END-IF
     IF LS-REARM > 0
         CALL "BT-SCHEDULE" USING L-DIM LS-TYPE LS-BLOCK L-X L-Y L-Z LS-REARM LS-PRIO LS-RESULT
     END-IF
     GOBACK.
 END PROGRAM RL-PLATE-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-PLATE-HOOK RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 LOCAL-STORAGE SECTION.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-CLASS               BINARY-LONG.
 01 LS-OLD                 BINARY-LONG.
 01 LS-RUN                 BINARY-LONG.
 01 LS-BELOW               BINARY-LONG.
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
     MOVE RL-CLASS(LS-BLOCK + 1) TO LS-CLASS
     MOVE RL-S-POWER(L-STATE + 1) TO LS-OLD
     IF LS-CLASS = 18 AND RL-S-ON(L-STATE + 1) = 1
         MOVE 15 TO LS-OLD
     END-IF
     EVALUATE L-KIND
         WHEN 7
*>           the tick (4.1): a pressed plate checks again
             CALL "RS2-PLATE-TICK" USING LS-OLD LS-RUN
             IF LS-RUN = 1
                 CALL "RL-PLATE-CHECK" USING L-DIM L-X L-Y L-Z L-STATE LS-RUN
             END-IF
         WHEN 2
*>           after removal (4.1): a pressed plate that was not moved tells its neighbours
             IF L-B = 0 AND LS-OLD > 0
                 COMPUTE LS-BELOW = L-Y - 1
                 CALL "BU-NEIGHBORS-AT" USING L-DIM L-X L-Y L-Z LS-BLOCK
                 CALL "BU-NEIGHBORS-AT" USING L-DIM L-X LS-BELOW L-Z LS-BLOCK
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM RL-PLATE-HOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REDSTONE-ENTITY-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY RSLIVE.
 01 WS-SERVER              BINARY-LONG VALUE 1.
 LOCAL-STORAGE SECTION.
 01 LS-I                   BINARY-LONG.
 01 LS-X                   FLOAT-LONG.
 01 LS-Y                   FLOAT-LONG.
 01 LS-Z                   FLOAT-LONG.
 01 LS-HALF                FLOAT-LONG.
 01 LS-HEIGHT              FLOAT-LONG.
 01 LS-COUNTED             BINARY-LONG.
 01 LS-LIVING              BINARY-LONG.
 01 LS-V                   FLOAT-LONG.
 01 LS-X0                  BINARY-LONG.
 01 LS-X1                  BINARY-LONG.
 01 LS-Z0                  BINARY-LONG.
 01 LS-Z1                  BINARY-LONG.
 01 LS-CY                  BINARY-LONG.
 01 LS-CX                  BINARY-LONG.
 01 LS-CZ                  BINARY-LONG.
 01 LS-STATE               BINARY-LONG.
 01 LS-CLASS               BINARY-LONG.
 01 LS-OLD                 BINARY-LONG.
 01 LS-RUN                 BINARY-LONG.
 01 LS-ALL                 BINARY-LONG.
 01 LS-LIVE                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "REDSTONE-IDS-ENSURE"
     PERFORM VARYING LS-I FROM 1 BY 1 UNTIL LS-I > EN-COUNT
         IF EN-USED(LS-I) = 1
             CALL "RL-ENTITY-FACTS" USING LS-I LS-X LS-Y LS-Z LS-HALF LS-HEIGHT LS-COUNTED LS-LIVING
*>           the cells the box covers in x and z, and the cell of its feet
             COMPUTE LS-V = LS-X - LS-HALF
             COMPUTE LS-X0 = FUNCTION INTEGER(LS-V)
             COMPUTE LS-V = LS-X + LS-HALF
             COMPUTE LS-X1 = FUNCTION INTEGER(LS-V)
             COMPUTE LS-V = LS-Z - LS-HALF
             COMPUTE LS-Z0 = FUNCTION INTEGER(LS-V)
             COMPUTE LS-V = LS-Z + LS-HALF
             COMPUTE LS-Z1 = FUNCTION INTEGER(LS-V)
             COMPUTE LS-CY = FUNCTION INTEGER(LS-Y)
             PERFORM VARYING LS-CX FROM LS-X0 BY 1 UNTIL LS-CX > LS-X1
                 PERFORM VARYING LS-CZ FROM LS-Z0 BY 1 UNTIL LS-CZ > LS-Z1
                     CALL "WORLD-GET-BLOCK" USING EN-DIM(LS-I) LS-CX LS-CY LS-CZ LS-STATE
                     MOVE RL-CLASS(CB-S-BLOCK(LS-STATE + 1) + 1) TO LS-CLASS
                     IF LS-CLASS = 25 AND RL-S-ON(LS-STATE + 1) = 0
                         CALL "RL-TRIP-ENTITY" USING EN-DIM(LS-I) LS-CX LS-CY LS-CZ LS-STATE
                     END-IF
                     IF LS-CLASS = 18 OR LS-CLASS = 19
                         MOVE RL-S-POWER(LS-STATE + 1) TO LS-OLD
                         IF LS-CLASS = 18 AND RL-S-ON(LS-STATE + 1) = 1
                             MOVE 15 TO LS-OLD
                         END-IF
*>                       entityInside (4.1): an unpressed plate checks, a pressed one ignores it
                         CALL "RS2-PLATE-INSIDE" USING WS-SERVER LS-OLD LS-RUN
                         IF LS-RUN = 1
                             CALL "RL-PLATE-CHECK" USING EN-DIM(LS-I) LS-CX LS-CY LS-CZ LS-STATE LS-RUN
                         END-IF
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM REDSTONE-ENTITY-TICK.
