*> The ender dragon fight controller (docs/protocol/21 section 6.4.5 and 6.4.6; lane 002-lane-mobsb8, T9704, T9705): FR-STATE (FIGHTRT.cpy) is its running state, END-FIGHT (ENDFIGHT.cpy,
*> end-fight-io.cob) the saved one. Every tick (FIGHT-TICK, called after THROWN-TICK): every 20 ticks the bar members (alive players within 192 blocks of (0, 128, 0)); with at least one member: the first
*> state scan, the respawn sequence if one runs, else the unseen counter (a dragon is made after 1200 ticks), the crystal count (every 100 ticks) and the bar progress.
*> The bar is own Boss Event packets (05a 0x09, uuid 15 zero bytes and 0xFE, translate entity.minecraft.ender_dragon, pink, progress, flags 0x06 play boss music + create world fog).
*> Gaps: a fresh End (nothing saved, no portal, never killed) does not set the killed flag when no dragon exists yet (the docs' scan would leave a new world without a dragon): the dragon is made after the 1200
*> ticks; the arena chunk ticket; crystal beam targets (entity data 8); the gateway's exit block entity; the fight's dragon UUID; the pillar box height range (height to height + 10, inferred); old pillar crystals
*> are discarded when a pillar is regenerated; the respawn explosion's random positions; the summoned-entity criterion; the 3001 and 3000 world events are sent with no extra data; a player is not pushed.
*>
*>   FIGHT-TICK                               one tick
*>   FIGHT-KILLED USING dim                   setDragonKilled: bar hidden, exit portal active, new gateway, egg on the first kill
*>   FIGHT-RESPAWN-TRY USING dim              tryRespawn (called after an end crystal was placed)
*>   FIGHT-NEW-DRAGON USING dim               createNewDragon at (0, 128, 0)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIGHT-DIM.
*> USING dim out: FR-DIM, else the End's dimension row of the open world (0 when it has none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY FIGHTRT.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     MOVE FR-DIM TO L-DIM
     IF FR-DIM = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CW-DIM-COUNT
             IF DM-KEY(CW-DIM(WS-I)) = "minecraft:the_end"
                 MOVE CW-DIM(WS-I) TO L-DIM
                 MOVE CW-DIM(WS-I) TO FR-DIM
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM FIGHT-DIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIGHT-BAR-PACKET.
*> USING operation (0 ADD, 1 REMOVE, 2 UPDATE_PROGRESS), player row (0 = every member of the bar).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY FIGHTRT.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ID                  BINARY-LONG VALUE 9.
 01 WS-UUID                PIC X(16).
 01 WS-PROGRESS            FLOAT-SHORT.
 01 WS-COLOR               BINARY-LONG VALUE 0.
 01 WS-STYLE               BINARY-LONG VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 6.
 01 WS-P                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ON                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-OP                   BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-OP L-ROW.
     MOVE LOW-VALUES TO WS-UUID
     MOVE FUNCTION CHAR(255) TO WS-UUID(16:1)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-OP
     COMPUTE WS-PROGRESS = FR-PROG / 1000
     IF L-OP = 0
         INITIALIZE PB-TEXT
         MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
         MOVE "entity.minecraft.ender_dragon" TO PB-TX-VALUE
         MOVE 29 TO PB-TX-LENGTH
         CALL "PB-PUT-TEXT" USING PB-BUFFER PB-TEXT
         CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-PROGRESS
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COLOR
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-STYLE
         CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-FLAGS
     END-IF
     IF L-OP = 2
         CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-PROGRESS
     END-IF
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0
             MOVE 0 TO WS-ON
             IF L-ROW = 0
                 PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > FR-BAR-N
                     IF FR-BAR-PLAYER(WS-J) = PL-UUID(WS-P)
                         MOVE 1 TO WS-ON
                     END-IF
                 END-PERFORM
             ELSE
                 IF WS-P = L-ROW
                     MOVE 1 TO WS-ON
                 END-IF
             END-IF
             IF WS-ON = 1
                 CALL "CORE-SEND" USING PL-CONN(WS-P) PB-BUFFER
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM FIGHT-BAR-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIGHT-BAR-SYNC.
*> USING dim: the members are the alive players of the dimension within 192 blocks of (0, 128, 0); a new member gets ADD when the bar is shown, one that left gets REMOVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY FIGHTRT.
 01 WS-P                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-OP-ADD              BINARY-LONG VALUE 0.
 01 WS-OP-REMOVE           BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0
             MOVE 0 TO WS-VALID
             IF PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = L-DIM
                 IF PL-X(WS-P) ** 2 + (PL-Y(WS-P) - 128) ** 2 + PL-Z(WS-P) ** 2 <= 36864
                     MOVE 1 TO WS-VALID
                 END-IF
             END-IF
             MOVE 0 TO WS-IN
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > FR-BAR-N
                 IF FR-BAR-PLAYER(WS-J) = PL-UUID(WS-P)
                     MOVE WS-J TO WS-IN
                 END-IF
             END-PERFORM
             IF WS-VALID = 1 AND WS-IN = 0 AND FR-BAR-N < 16
                 ADD 1 TO FR-BAR-N
                 MOVE PL-UUID(WS-P) TO FR-BAR-PLAYER(FR-BAR-N)
                 IF FR-BAR = 1
                     CALL "FIGHT-BAR-PACKET" USING WS-OP-ADD WS-P
                 END-IF
             END-IF
             IF WS-VALID = 0 AND WS-IN > 0
                 IF FR-BAR = 1
                     CALL "FIGHT-BAR-PACKET" USING WS-OP-REMOVE WS-P
                 END-IF
                 PERFORM VARYING WS-K FROM WS-IN BY 1 UNTIL WS-K >= FR-BAR-N
                     MOVE FR-BAR-PLAYER(WS-K + 1) TO FR-BAR-PLAYER(WS-K)
                 END-PERFORM
                 SUBTRACT 1 FROM FR-BAR-N
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FIGHT-BAR-SYNC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIGHT-COUNT-CRYSTALS.
*> USING dim, count out: the end crystals inside the top box of each pillar (x and z over the pillar's square, y from its height to height + 10).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY ENDSPIKE.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-COUNT.
     MOVE 0 TO L-COUNT
     CALL "END-SPIKES" USING CW-SEED SPIKE-LIST
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 10
         COMPUTE WS-X0 = SP-CX(WS-S) - SP-R(WS-S)
         COMPUTE WS-X1 = SP-CX(WS-S) + SP-R(WS-S) + 1
         COMPUTE WS-Z0 = SP-CZ(WS-S) - SP-R(WS-S)
         COMPUTE WS-Z1 = SP-CZ(WS-S) + SP-R(WS-S) + 1
         COMPUTE WS-Y1 = SP-H(WS-S) + 10
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
             IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 16
                 PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
                     IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = PJ-ENT(WS-I) AND EN-DIM(WS-E) = L-DIM
                         IF EN-X(WS-E) >= WS-X0 AND EN-X(WS-E) <= WS-X1 AND EN-Z(WS-E) >= WS-Z0 AND EN-Z(WS-E) <= WS-Z1
                                 AND EN-Y(WS-E) >= SP-H(WS-S) AND EN-Y(WS-E) <= WS-Y1
                             ADD 1 TO L-COUNT
                         END-IF
                     END-IF
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FIGHT-COUNT-CRYSTALS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIGHT-PORTAL.
*> USING dim, active (0 or 1): spawnExitPortal: the stored location, else the surface of the podium column minus 1, lowered while bedrock above Y 63 and at least Y 1 (stored); the podium feature.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY ENDFIGHT.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-SURFACE             BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-DONE                BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-DROP                BINARY-LONG VALUE 0.
 01 WS-DROPPED             BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-GET                 BINARY-LONG VALUE 3.
 01 WS-SET                 BINARY-LONG VALUE 4.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-ACTIVE               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-ACTIVE.
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     IF EF-HAS-PORTAL = 0
         CALL "DRAGON-SURFACE" USING L-DIM WS-ZERO WS-ZERO2 WS-SURFACE
         COMPUTE WS-Y = WS-SURFACE - 1
         MOVE 0 TO WS-DONE
         PERFORM UNTIL WS-DONE = 1
             MOVE 1 TO WS-DONE
             IF WS-Y > 63
                 CALL "WORLD-GET-BLOCK" USING L-DIM WS-ZERO WS-Y WS-ZERO2 WS-STATE
                 IF WS-STATE NOT = 0
                     MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-KEY
                     IF WS-KEY = "minecraft:bedrock"
                         SUBTRACT 1 FROM WS-Y
                         MOVE 0 TO WS-DONE
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
         COMPUTE WS-Y = FUNCTION MAX(WS-Y, 1)
         MOVE 0 TO EF-PORTAL(1) EF-PORTAL(3)
         MOVE WS-Y TO EF-PORTAL(2)
         MOVE 1 TO EF-HAS-PORTAL
         CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
     END-IF
     MOVE EF-PORTAL(1) TO WS-PX
     MOVE EF-PORTAL(2) TO WS-PY
     MOVE EF-PORTAL(3) TO WS-PZ
     CALL "END-PODIUM-PLACE" USING WS-MODE L-DIM WS-PX WS-PY WS-PZ L-ACTIVE WS-DROPPED
     GOBACK.
 END PROGRAM FIGHT-PORTAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIGHT-GATEWAY.
*> USING dim: spawnNewGateway: the last remaining index n gives (floor(96 cos(2 (-pi + 0.15707963 n))), 75, floor(96 sin(...))); the frame is placed and world event 3000 played.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY ENDFIGHT.
 01 WS-GET                 BINARY-LONG VALUE 3.
 01 WS-SET                 BINARY-LONG VALUE 4.
 01 WS-N                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG VALUE 75.
 01 WS-Z                   BINARY-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-EVENT               BINARY-LONG VALUE 3000.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     IF EF-GATEWAY-COUNT > 0
         MOVE EF-GATEWAY(EF-GATEWAY-COUNT) TO WS-N
         SUBTRACT 1 FROM EF-GATEWAY-COUNT
         CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
         COMPUTE WS-A = 2 * (0 - FUNCTION PI + 0.15707963 * WS-N)
         COMPUTE WS-X = FUNCTION INTEGER(96 * FUNCTION COS(WS-A))
         COMPUTE WS-Z = FUNCTION INTEGER(96 * FUNCTION SIN(WS-A))
         CALL "END-GATEWAY-PLACE" USING WS-MODE L-DIM WS-X WS-Y WS-Z
         CALL "LEVEL-EVENT" USING L-DIM WS-EVENT WS-X WS-Y WS-Z WS-NONE WS-NONE2
     END-IF
     GOBACK.
 END PROGRAM FIGHT-GATEWAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIGHT-EGG.
*> USING dim: the dragon egg on the surface of the podium column.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG.
 01 WS-KEY                 PIC X(112) VALUE "dragon_egg".
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     CALL "DRAGON-SURFACE" USING L-DIM WS-ZERO WS-ZERO2 WS-Y
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "BLOCK-CHANGE" USING L-DIM WS-ZERO WS-Y WS-ZERO2 WS-STATE
     GOBACK.
 END PROGRAM FIGHT-EGG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIGHT-NEW-DRAGON.
*> USING dim: createNewDragon at (0, 128, 0) with a random yaw, phase HOLDING_PATTERN; the fight is not killed and the bar is shown.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DRAGSTATE.
 COPY FIGHTRT.
 COPY ENDFIGHT.
 COPY CORESTATE.
 01 WS-X                   FLOAT-LONG VALUE 0.
 01 WS-Y                   FLOAT-LONG VALUE 128.
 01 WS-Z                   FLOAT-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-BOUND               BINARY-LONG VALUE 360.
 01 WS-YAW                 BINARY-LONG.
 01 WS-GET                 BINARY-LONG VALUE 3.
 01 WS-SET                 BINARY-LONG VALUE 4.
 01 WS-OP-ADD              BINARY-LONG VALUE 0.
 01 WS-ALL                 BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     CALL "DRAGON-SPAWN" USING L-DIM WS-X WS-Y WS-Z WS-ROW
     IF WS-ROW > 0
         CALL "DRAGON-ROLL" USING WS-BOUND WS-YAW
         MOVE WS-YAW TO EN-YAW(WS-ROW)
         MOVE 1 TO DG-FIGHT
         MOVE 0 TO FR-SEEN
         CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
         MOVE 0 TO EF-KILLED
         CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
         MOVE 1 TO FR-BAR
         MOVE 1000 TO FR-PROG
         CALL "FIGHT-BAR-PACKET" USING WS-OP-ADD WS-ALL
     END-IF
     GOBACK.
 END PROGRAM FIGHT-NEW-DRAGON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIGHT-KILLED.
*> USING dim: setDragonKilled: the bar's progress is 0 and it is hidden, the portal becomes active, a new gateway is made, the first kill places the egg.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FIGHTRT.
 COPY ENDFIGHT.
 01 WS-GET                 BINARY-LONG VALUE 3.
 01 WS-SET                 BINARY-LONG VALUE 4.
 01 WS-OP-REMOVE           BINARY-LONG VALUE 1.
 01 WS-ALL                 BINARY-LONG VALUE 0.
 01 WS-ACTIVE              BINARY-LONG VALUE 1.
 01 WS-FIRST               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     MOVE 0 TO FR-PROG
     IF FR-BAR = 1
         CALL "FIGHT-BAR-PACKET" USING WS-OP-REMOVE WS-ALL
     END-IF
     MOVE 0 TO FR-BAR
     CALL "FIGHT-PORTAL" USING L-DIM WS-ACTIVE
     CALL "FIGHT-GATEWAY" USING L-DIM
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE 0 TO WS-FIRST
     IF EF-PREVIOUS = 0
         MOVE 1 TO WS-FIRST
         MOVE 1 TO EF-PREVIOUS
     END-IF
     MOVE 1 TO EF-KILLED
     CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
     IF WS-FIRST = 1
         CALL "FIGHT-EGG" USING L-DIM
     END-IF
     GOBACK.
 END PROGRAM FIGHT-KILLED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIGHT-RESPAWN-TRY.
*> USING dim: tryRespawn: the dragon is killed, no sequence runs, the portal is known and each of the four directions at the portal's y + 1 and 3 blocks holds an end crystal: every bedrock or
*> end_portal block of the pattern becomes end_stone, the portal is rebuilt inactive and the sequence starts (stage START).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY CBLOCKS.
 COPY ENDFIGHT.
 COPY FIGHTRT.
 01 WS-GET                 BINARY-LONG VALUE 3.
 01 WS-SET                 BINARY-LONG VALUE 4.
 01 WS-D                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-IDS                 BINARY-LONG OCCURS 4 TIMES.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-STONE-KEY           PIC X(112) VALUE "end_stone".
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-STONE               BINARY-LONG.
 01 WS-INACTIVE            BINARY-LONG VALUE 0.
 01 WS-ALL                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     IF EF-KILLED = 0 OR EF-STAGE > 0
         GOBACK
     END-IF
     IF EF-HAS-PORTAL = 0
         CALL "FIGHT-PORTAL" USING L-DIM WS-INACTIVE
         CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     END-IF
     MOVE 0 TO WS-ALL
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 4
         MOVE 0 TO WS-IDS(WS-D)
         EVALUATE WS-D
             WHEN 1
                 MOVE 3 TO WS-DX
                 MOVE 0 TO WS-DZ
             WHEN 2
                 MOVE -3 TO WS-DX
                 MOVE 0 TO WS-DZ
             WHEN 3
                 MOVE 0 TO WS-DX
                 MOVE 3 TO WS-DZ
             WHEN OTHER
                 MOVE 0 TO WS-DX
                 MOVE -3 TO WS-DZ
         END-EVALUATE
         COMPUTE WS-CX = EF-PORTAL(1) + WS-DX
         COMPUTE WS-CY = EF-PORTAL(2) + 1
         COMPUTE WS-CZ = EF-PORTAL(3) + WS-DZ
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
             IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 16 AND WS-IDS(WS-D) = 0
                 PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
                     IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = PJ-ENT(WS-I) AND EN-DIM(WS-E) = L-DIM
                         IF FUNCTION INTEGER(EN-X(WS-E)) = WS-CX AND FUNCTION INTEGER(EN-Y(WS-E)) = WS-CY AND FUNCTION INTEGER(EN-Z(WS-E)) = WS-CZ
                             MOVE EN-ID(WS-E) TO WS-IDS(WS-D)
                         END-IF
                     END-IF
                 END-PERFORM
             END-IF
         END-PERFORM
         IF WS-IDS(WS-D) > 0
             ADD 1 TO WS-ALL
         END-IF
     END-PERFORM
     IF WS-ALL < 4
         GOBACK
     END-IF
     CALL "BLOCKS-STATE-OF" USING WS-STONE-KEY WS-PAIRS WS-STONE
     PERFORM VARYING WS-X FROM -4 BY 1 UNTIL WS-X > 4
         PERFORM VARYING WS-Y FROM -1 BY 1 UNTIL WS-Y > 4
             PERFORM VARYING WS-Z FROM -4 BY 1 UNTIL WS-Z > 4
                 COMPUTE WS-CX = EF-PORTAL(1) + WS-X
                 COMPUTE WS-CY = EF-PORTAL(2) + WS-Y
                 COMPUTE WS-CZ = EF-PORTAL(3) + WS-Z
                 CALL "WORLD-GET-BLOCK" USING L-DIM WS-CX WS-CY WS-CZ WS-STATE
                 IF WS-STATE NOT = 0
                     MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-KEY
                     IF WS-KEY = "minecraft:bedrock" OR WS-KEY = "minecraft:end_portal"
                         CALL "BLOCK-CHANGE" USING L-DIM WS-CX WS-CY WS-CZ WS-STONE
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     CALL "FIGHT-PORTAL" USING L-DIM WS-INACTIVE
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE 1 TO EF-STAGE
     MOVE 0 TO EF-TIME
     CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
     MOVE 4 TO FR-RC-N
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 4
         MOVE WS-IDS(WS-D) TO FR-RC(WS-D)
     END-PERFORM
     GOBACK.
 END PROGRAM FIGHT-RESPAWN-TRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIGHT-PILLAR.
*> USING dim, spike index (1 to 10): the pillar of the respawn: the cube of half-size 10 round (x, height, z) is cleared, an explosion of power 5.0 at (x + 0.5, height, z + 0.5) and the pillar rebuilt
*> with an invulnerable crystal (the old crystals of its box are discarded).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY ENDSPIKE.
 COPY XORO.
 01 WS-S                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-POWER               FLOAT-LONG VALUE 5.0.
 01 WS-DESTROY             BINARY-LONG VALUE 1.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YES                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-SPIKE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-SPIKE.
     CALL "END-SPIKES" USING CW-SEED SPIKE-LIST
     MOVE SP-CX(L-SPIKE) TO WS-X
     MOVE SP-H(L-SPIKE) TO WS-Y
     MOVE SP-CZ(L-SPIKE) TO WS-Z
     PERFORM VARYING WS-DX FROM -10 BY 1 UNTIL WS-DX > 10
         PERFORM VARYING WS-DY FROM -10 BY 1 UNTIL WS-DY > 10
             PERFORM VARYING WS-DZ FROM -10 BY 1 UNTIL WS-DZ > 10
                 COMPUTE WS-FX = WS-X + WS-DX
                 COMPUTE WS-FY = WS-Y + WS-DY
                 COMPUTE WS-FZ = WS-Z + WS-DZ
                 MOVE WS-FX TO WS-EX
                 MOVE WS-FY TO WS-EY
                 MOVE WS-FZ TO WS-EZ
                 CALL "FIGHT-CLEAR-CELL" USING L-DIM WS-EX WS-EY WS-EZ
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE WS-EX = WS-X + 0.5
     MOVE WS-Y TO WS-EY
     COMPUTE WS-EZ = WS-Z + 0.5
     CALL "EXPLODE-RUN" USING L-DIM WS-EX WS-EY WS-EZ WS-POWER WS-DESTROY WS-NONE
*>   The old crystals of the pillar's top box go, the pillar is rebuilt.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 16
             PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
                 IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = PJ-ENT(WS-I) AND EN-DIM(WS-E) = L-DIM
                     IF FUNCTION ABS(EN-X(WS-E) - WS-X - 0.5) <= SP-R(L-SPIKE) + 1 AND FUNCTION ABS(EN-Z(WS-E) - WS-Z - 0.5) <= SP-R(L-SPIKE) + 1
                             AND EN-Y(WS-E) >= WS-Y AND EN-Y(WS-E) <= WS-Y + 10
                         CALL "PJ-DROP" USING WS-E
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     MOVE CW-SEED TO WS-SEED
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "END-SPIKE-PLACE" USING WS-MODE L-DIM WS-X WS-Z CW-SEED XR-STATE CRYSTAL-LIST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EC-COUNT
         COMPUTE WS-EX = EC-X(WS-I) + 0.5
         MOVE EC-Y(WS-I) TO WS-EY
         COMPUTE WS-EZ = EC-Z(WS-I) + 0.5
         CALL "CRYSTAL-SPAWN" USING L-DIM WS-EX WS-EY WS-EZ WS-YES WS-ROW
         IF WS-ROW > 0
             MOVE EC-YAW(WS-I) TO EN-YAW(WS-ROW)
             CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
             MOVE 1 TO PJ-I2(WS-SLOT)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FIGHT-PILLAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIGHT-CLEAR-CELL.
*> USING dim, x, y, z (FLOAT-LONG, whole numbers): the cell becomes air when it is not.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     COMPUTE WS-X = FUNCTION INTEGER(L-X)
     COMPUTE WS-Y = FUNCTION INTEGER(L-Y)
     COMPUTE WS-Z = FUNCTION INTEGER(L-Z)
     CALL "WORLD-GET-BLOCK" USING L-DIM WS-X WS-Y WS-Z WS-STATE
     IF WS-STATE NOT = 0
         CALL "BLOCK-CHANGE" USING L-DIM WS-X WS-Y WS-Z WS-AIR
     END-IF
     GOBACK.
 END PROGRAM FIGHT-CLEAR-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIGHT-RC-GONE.
*> USING gone out: 1 when one of the respawn crystals no longer exists.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY FIGHTRT.
 01 WS-D                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-GONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-GONE.
     MOVE 0 TO L-GONE
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > FR-RC-N
         MOVE 0 TO WS-FOUND
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = FR-RC(WS-D)
                 MOVE 1 TO WS-FOUND
             END-IF
         END-PERFORM
         IF WS-FOUND = 0
             MOVE 1 TO L-GONE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FIGHT-RC-GONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIGHT-SPIKES-RESET.
*> No parameters: every end crystal is vulnerable again (resetSpikeCrystals).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROJSTATE.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
         IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 16
             MOVE 0 TO PJ-I2(WS-I)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FIGHT-SPIKES-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIGHT-RESPAWN-TICK.
*> USING dim: one tick of the respawn sequence (stages 1 to 4 of EF-STAGE); a vanished respawn crystal aborts it (portal active again, spike crystals vulnerable).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY ENDFIGHT.
 COPY FIGHTRT.
 01 WS-GET                 BINARY-LONG VALUE 3.
 01 WS-SET                 BINARY-LONG VALUE 4.
 01 WS-GONE                BINARY-LONG.
 01 WS-ACTIVE              BINARY-LONG VALUE 1.
 01 WS-EVENT               BINARY-LONG VALUE 3001.
 01 WS-X                   BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG VALUE 128.
 01 WS-Z                   BINARY-LONG VALUE 0.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 01 WS-SPIKE               BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-POWER               FLOAT-LONG VALUE 6.0.
 01 WS-DESTROY             BINARY-LONG VALUE 0.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     CALL "FIGHT-RC-GONE" USING WS-GONE
     IF WS-GONE = 1
         CALL "FIGHT-PORTAL" USING L-DIM WS-ACTIVE
         CALL "FIGHT-SPIKES-RESET"
         MOVE 0 TO EF-STAGE EF-TIME FR-RC-N
         CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
         GOBACK
     END-IF
     EVALUATE EF-STAGE
         WHEN 1
             MOVE 2 TO EF-STAGE
             MOVE 0 TO EF-TIME
         WHEN 2
             IF EF-TIME >= 100
                 MOVE 3 TO EF-STAGE
                 MOVE 0 TO EF-TIME
             ELSE
                 IF EF-TIME = 0 OR EF-TIME = 50 OR EF-TIME = 51 OR EF-TIME = 52 OR EF-TIME >= 95
                     CALL "LEVEL-EVENT" USING L-DIM WS-EVENT WS-X WS-Y WS-Z WS-NONE WS-NONE2
                 END-IF
                 ADD 1 TO EF-TIME
             END-IF
         WHEN 3
             IF FUNCTION MOD(EF-TIME, 40) = 39
                 COMPUTE WS-SPIKE = EF-TIME / 40 + 1
                 CALL "FIGHT-PILLAR" USING L-DIM WS-SPIKE
             END-IF
             IF EF-TIME >= 399
                 MOVE 4 TO EF-STAGE
                 MOVE 0 TO EF-TIME
             ELSE
                 ADD 1 TO EF-TIME
             END-IF
         WHEN 4
             IF EF-TIME < 5 OR EF-TIME >= 80
                 CALL "LEVEL-EVENT" USING L-DIM WS-EVENT WS-X WS-Y WS-Z WS-NONE WS-NONE2
             END-IF
             IF EF-TIME >= 100
                 CALL "FIGHT-SPIKES-RESET"
                 PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > FR-RC-N
                     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
                         IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = FR-RC(WS-D)
                             MOVE EN-X(WS-E) TO WS-EX
                             MOVE EN-Y(WS-E) TO WS-EY
                             MOVE EN-Z(WS-E) TO WS-EZ
                             CALL "PJ-DROP" USING WS-E
                             CALL "EXPLODE-RUN" USING L-DIM WS-EX WS-EY WS-EZ WS-POWER WS-DESTROY WS-NONE
                         END-IF
                     END-PERFORM
                 END-PERFORM
                 MOVE 0 TO EF-STAGE EF-TIME FR-RC-N
                 MOVE 0 TO EF-KILLED
                 CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
                 CALL "FIGHT-NEW-DRAGON" USING L-DIM
                 GOBACK
             END-IF
             ADD 1 TO EF-TIME
     END-EVALUATE
     CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
     GOBACK.
 END PROGRAM FIGHT-RESPAWN-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIGHT-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DRAGSTATE.
 COPY FIGHTRT.
 COPY ENDFIGHT.
 01 WS-DIM                 BINARY-LONG.
 01 WS-GET                 BINARY-LONG VALUE 3.
 01 WS-SET                 BINARY-LONG VALUE 4.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PROG                BINARY-LONG.
 01 WS-OP-PROGRESS         BINARY-LONG VALUE 2.
 01 WS-ALL                 BINARY-LONG VALUE 0.
 01 WS-NOW                 BINARY-LONG.
 LINKAGE SECTION.
 PROCEDURE DIVISION.
     CALL "FIGHT-DIM" USING WS-DIM
     IF WS-DIM = 0
         GOBACK
     END-IF
     ADD 1 TO FR-TICKS
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     IF EF-KILLED = 0
         MOVE 1 TO FR-BAR
     END-IF
     IF FUNCTION MOD(FR-TICKS, 20) = 0
         CALL "FIGHT-BAR-SYNC" USING WS-DIM
     END-IF
     IF FR-BAR-N = 0
         GOBACK
     END-IF
     IF FR-SCANNED = 0
         MOVE 1 TO FR-SCANNED
         CALL "FIGHT-SCAN" USING WS-DIM
         CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     END-IF
     IF EF-STAGE > 0
         CALL "FIGHT-RESPAWN-TICK" USING WS-DIM
         GOBACK
     END-IF
     IF EF-KILLED = 1
         GOBACK
     END-IF
     CALL "DRAGON-ROW" USING WS-ROW
     IF WS-ROW > 0
         MOVE 0 TO FR-SEEN
         COMPUTE WS-PROG = FUNCTION INTEGER(DG-HP * 1000 / 200)
         IF WS-PROG NOT = FR-PROG
             MOVE WS-PROG TO FR-PROG
             CALL "FIGHT-BAR-PACKET" USING WS-OP-PROGRESS WS-ALL
         END-IF
     ELSE
         ADD 1 TO FR-SEEN
         IF FR-SEEN >= 1200
             CALL "FIGHT-NEW-DRAGON" USING WS-DIM
         END-IF
     END-IF
     IF FUNCTION MOD(FR-TICKS, 100) = 0
         CALL "FIGHT-COUNT-CRYSTALS" USING WS-DIM FR-CRYSTALS
     END-IF
     GOBACK.
 END PROGRAM FIGHT-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FIGHT-SCAN.
*> USING dim: scanState: an active exit portal (an end_portal block at the stored location, else at the podium) means the dragon was killed before; else the inactive portal is built.
*> A dragon that exists is adopted (DG-FIGHT 1). Gap: a new End with no dragon stays unkilled (see the header).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY DRAGSTATE.
 COPY ENDFIGHT.
 01 WS-GET                 BINARY-LONG VALUE 3.
 01 WS-SET                 BINARY-LONG VALUE 4.
 01 WS-INACTIVE            BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-ACTIVE              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     CALL "END-FIGHT-IO" USING WS-GET END-FIGHT
     MOVE 0 TO WS-ACTIVE
     IF EF-HAS-PORTAL = 1
         MOVE EF-PORTAL(1) TO WS-X
         MOVE EF-PORTAL(2) TO WS-Y
         MOVE EF-PORTAL(3) TO WS-Z
         CALL "WORLD-GET-BLOCK" USING L-DIM WS-X WS-Y WS-Z WS-STATE
         IF WS-STATE NOT = 0
             MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-KEY
             IF WS-KEY = "minecraft:end_portal"
                 MOVE 1 TO WS-ACTIVE
             END-IF
         END-IF
     END-IF
     IF WS-ACTIVE = 1
         MOVE 1 TO EF-PREVIOUS
         CALL "END-FIGHT-IO" USING WS-SET END-FIGHT
     ELSE
         CALL "FIGHT-PORTAL" USING L-DIM WS-INACTIVE
     END-IF
     CALL "DRAGON-ROW" USING WS-ROW
     IF WS-ROW > 0
         MOVE 1 TO DG-FIGHT
     END-IF
     GOBACK.
 END PROGRAM FIGHT-SCAN.
