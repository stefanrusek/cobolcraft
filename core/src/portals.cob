*> Portals and dimension travel wiring (docs/protocol/39-portals.md sections 2, 4, 6 and 8; tasks T1763, T1764): the entity-side process of each
*> player (PORTAL-PLAYER-TICK, called for every player in play by PORTAL-TICK after the player tick of CORE-TICK) and the nether portal
*> transfer (PORTAL-TRAVEL: destination, origin with the x8 scaling and the border clamp, find or create the exit portal, relative position,
*> yaw change, then DIM-SWITCH of dimensions.cob for the Respawn and the join sequence of the new dimension, and the portal sound).
*> The rules themselves are in portal-39.cob. Not done (open items): mobs, items and vehicles do not use portals (players only), the
*> collision-free placement of 6.8, velocity rotation (the core keeps no player velocity), the End portal and gateway (7), Change Difficulty and
*> Initialize Border after the Respawn, the chunk ticket of 6.4.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-AXIS-OF.
*> USING dimension row, x, y, z, axis out (BINARY-LONG): 0 or 1 for the axis of the nether_portal block there, 0 when it is none (39 section 4.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PORTAL.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-AXIS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-AXIS.
     CALL "PORTAL-IDS-ENSURE"
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     MOVE 0 TO L-AXIS
     IF WS-STATE = PI-PORTAL-Z
         MOVE 1 TO L-AXIS
     END-IF
     GOBACK.
 END PROGRAM PORTAL-AXIS-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-SOUND.
*> USING connection id: Level Event 1032 (portal travel; the post action PLAY_PORTAL_SOUND of 39 section 6.4) to that player only.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-PACKET-ID           BINARY-LONG VALUE 47.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-EVENT               BINARY-LONG VALUE 1032.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO-Y              BINARY-LONG VALUE 0.
 01 WS-ZERO-Z              BINARY-LONG VALUE 0.
 01 WS-ZERO-DATA           BINARY-LONG VALUE 0.
 01 WS-NOT-GLOBAL          BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-CONN                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CONN.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-LEVEL-EVENT" USING PB-BUFFER WS-EVENT WS-ZERO WS-ZERO-Y WS-ZERO-Z WS-ZERO-DATA WS-NOT-GLOBAL
     CALL "CORE-SEND" USING L-CONN PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM PORTAL-SOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-DESTINATION.
*> USING source dimension row, destination row out (0 when the world has none): 39 section 4.1 step 1: the overworld when the player is in
*> the nether, otherwise the nether (so the End leads to the nether), if that dimension is enabled in this world.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 01 WS-WANT                PIC X(32).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-SRC                  BINARY-LONG.
 01 L-DEST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SRC L-DEST.
     MOVE 0 TO L-DEST
     MOVE "minecraft:the_nether" TO WS-WANT
     IF DM-KEY(L-SRC) = "minecraft:the_nether"
         MOVE "minecraft:overworld" TO WS-WANT
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CW-DIM-COUNT
         IF DM-KEY(CW-DIM(WS-I)) = WS-WANT
             MOVE CW-DIM(WS-I) TO L-DEST
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PORTAL-DESTINATION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-TRAVEL.
*> USING player row, entry x, y, z (BINARY-LONG, the portal block the player stood in), done out (1 when the player changed dimension): the
*> nether portal transfer of 39 sections 4 and 5. No destination (dimension not enabled), the rule allow_entering_nether_using_portals false
*> for a nether destination, or a portal that cannot be made, leaves the player where she is (done 0; the last one logs the vanilla error).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY PORTAL.
 COPY PORTALRECT.
 COPY PORTALRECT REPLACING ==PORTAL-RECT== BY ==ENTRY-RECT== LEADING ==PR-== BY ==ER-==.
 01 WS-SRC                 BINARY-LONG.
 01 WS-DEST                BINARY-LONG.
 01 WS-NETHER              BINARY-LONG.
 01 WS-RULE-NAME           PIC X(40).
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-RADIUS              BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-ENTRY-AXIS          BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-EW                  FLOAT-LONG VALUE 0.6.
 01 WS-EH                  FLOAT-LONG VALUE 1.8.
 01 WS-RX                  FLOAT-LONG.
 01 WS-RY                  FLOAT-LONG.
 01 WS-RZ                  FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-LINE                PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-EX                   BINARY-LONG.
 01 L-EY                   BINARY-LONG.
 01 L-EZ                   BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-EX L-EY L-EZ L-DONE.
     MOVE 0 TO L-DONE
     MOVE L-ROW TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-SRC
     CALL "PORTAL-DESTINATION" USING WS-SRC WS-DEST
     IF WS-DEST = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-NETHER
     IF DM-KEY(WS-DEST) = "minecraft:the_nether"
         MOVE 1 TO WS-NETHER
     END-IF
     MOVE "allow_entering_nether_using_portals" TO WS-RULE-NAME
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     IF WS-NETHER = 1 AND WS-RULE = 0
         GOBACK
     END-IF
     CALL "PORTAL-ORIGIN" USING WS-SRC WS-DEST PL-X(WS-ROW) PL-Y(WS-ROW) PL-Z(WS-ROW) WS-OX WS-OY WS-OZ
     MOVE PQ-RADIUS-OVERWORLD TO WS-RADIUS
     IF WS-NETHER = 1
         MOVE PQ-RADIUS-NETHER TO WS-RADIUS
     END-IF
     CALL "PORTAL-LOAD-SAVED" USING WS-DEST WS-OX WS-OZ WS-RADIUS
     CALL "PORTAL-FIND-EXISTING" USING WS-DEST WS-OX WS-OY WS-OZ WS-NETHER WS-FOUND WS-FX WS-FY WS-FZ
     CALL "PORTAL-AXIS-OF" USING WS-SRC L-EX L-EY L-EZ WS-ENTRY-AXIS
     IF WS-FOUND = 1
         CALL "PORTAL-AXIS-OF" USING WS-DEST WS-FX WS-FY WS-FZ WS-AXIS
         CALL "PORTAL-LARGEST-RECT" USING WS-DEST WS-FX WS-FY WS-FZ WS-AXIS PORTAL-RECT
     ELSE
         CALL "PORTAL-CREATE" USING WS-DEST WS-OX WS-OY WS-OZ WS-ENTRY-AXIS PORTAL-RECT WS-OK
         IF WS-OK = 0
             MOVE "Unable to create a portal, likely target out of worldborder" TO WS-LINE
             MOVE 59 TO WS-LENGTH
             CALL "CORE-LOG" USING WS-LINE WS-LENGTH
             GOBACK
         END-IF
         MOVE WS-ENTRY-AXIS TO WS-AXIS
     END-IF
*>   The entry rectangle in the player's current level: the portal block she stands in (axis X and (0.5, 0, 0) when there is none).
     CALL "PORTAL-CELL-KIND" USING WS-SRC L-EX L-EY L-EZ WS-KIND
     MOVE 0.5 TO WS-RX
     MOVE 0 TO WS-RY WS-RZ
     IF WS-KIND = 2
         CALL "PORTAL-LARGEST-RECT" USING WS-SRC L-EX L-EY L-EZ WS-ENTRY-AXIS ENTRY-RECT
         CALL "PORTAL-RELATIVE" USING ENTRY-RECT PL-X(WS-ROW) PL-Y(WS-ROW) PL-Z(WS-ROW) WS-EW WS-EH WS-RX WS-RY WS-RZ
     END-IF
     CALL "PORTAL-EXIT-POS" USING PORTAL-RECT WS-RX WS-RY WS-RZ WS-EW WS-EH WS-X WS-Y WS-Z
     IF WS-ENTRY-AXIS NOT = WS-AXIS
         COMPUTE PL-YAW(WS-ROW) = PL-YAW(WS-ROW) + 90
     END-IF
     CALL "DIM-SWITCH" USING WS-ROW WS-DEST WS-X WS-Y WS-Z
     CALL "PORTAL-SOUND" USING PL-CONN(WS-ROW)
     MOVE 1 TO L-DONE
     GOBACK.
 END PROGRAM PORTAL-TRAVEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-PLAYER-TICK.
*> USING player row: one tick of the entity-side portal process of a player in play (39 section 2.2 and 2.3), in the order of Entity.baseTick
*> and the end of aiStep: handlePortal first (the cooldown counts down unless the player is changing dimension; a present process advances:
*> inside this tick adds one to portalTime and the player travels when the old portalTime reached the transit time, not inside subtracts
*> 4 and the process ends at 0; a transfer starts the cooldown of 10 ticks), then the inside-block sweep: a portal block touched by the
*> player's box (0.6 x 1.8, shrunk by 1e-5; the current position only) sets the process (setAsInsidePortal: a running cooldown is
*> refilled instead). Transit time: the rules players_nether_portal_default_delay (80) and _creative_delay (0, creative players).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PORTAL.
 01 WS-NAME-DEFAULT        PIC X(40) VALUE "players_nether_portal_default_delay".
 01 WS-NAME-CREATIVE       PIC X(40) VALUE "players_nether_portal_creative_delay".
 01 WS-NAME-ALLOW          PIC X(40) VALUE "allow_entering_nether_using_portals".
 01 WS-DEFAULT-RULE        BINARY-DOUBLE.
 01 WS-CREATIVE-RULE       BINARY-DOUBLE.
 01 WS-ALLOW-RULE          BINARY-DOUBLE.
 01 WS-R-DEFAULT           BINARY-LONG.
 01 WS-R-CREATIVE          BINARY-LONG.
 01 WS-R-ALLOW             BINARY-LONG.
 01 WS-CREATIVE            BINARY-LONG.
 01 WS-NETHER              BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG.
 01 WS-ALLOWED             BINARY-LONG.
 01 WS-DEST                BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-EPS                 FLOAT-LONG VALUE 0.00001.
 01 WS-MIN-X               BINARY-LONG.
 01 WS-MAX-X               BINARY-LONG.
 01 WS-MIN-Y               BINARY-LONG.
 01 WS-MAX-Y               BINARY-LONG.
 01 WS-MIN-Z               BINARY-LONG.
 01 WS-MAX-Z               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-CONN                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF PQ-PL-OWNER(L-ROW) NOT = PL-ENTITY-ID(L-ROW)
         INITIALIZE PQ-PL(L-ROW)
         MOVE PL-ENTITY-ID(L-ROW) TO PQ-PL-OWNER(L-ROW)
     END-IF
     MOVE PL-CONN(L-ROW) TO WS-CONN
     IF PQ-PL-CHANGING(L-ROW) = 1 AND CN-TELEPORT-ACKED(WS-CONN) = 1
         MOVE 0 TO PQ-PL-CHANGING(L-ROW)
     END-IF
*>   handlePortal
     IF PQ-PL-COOLDOWN(L-ROW) > 0 AND PQ-PL-CHANGING(L-ROW) = 0
         SUBTRACT 1 FROM PQ-PL-COOLDOWN(L-ROW)
     END-IF
     IF PQ-PL-PROCESS(L-ROW) = 1
         MOVE 0 TO WS-RESULT
         IF PQ-PL-FLAG(L-ROW) = 1
             MOVE 0 TO PQ-PL-FLAG(L-ROW)
             MOVE PQ-PL-TIME(L-ROW) TO WS-OLD
             ADD 1 TO PQ-PL-TIME(L-ROW)
             CALL "BR-RULE-GET" USING WS-NAME-DEFAULT WS-DEFAULT-RULE
             CALL "BR-RULE-GET" USING WS-NAME-CREATIVE WS-CREATIVE-RULE
             CALL "BR-RULE-GET" USING WS-NAME-ALLOW WS-ALLOW-RULE
             MOVE WS-DEFAULT-RULE TO WS-R-DEFAULT
             MOVE WS-CREATIVE-RULE TO WS-R-CREATIVE
             MOVE WS-ALLOW-RULE TO WS-R-ALLOW
             MOVE 0 TO WS-CREATIVE WS-NETHER
             IF PL-MODE(L-ROW) = 1
                 MOVE 1 TO WS-CREATIVE
             END-IF
             CALL "GR-PORTAL" USING WS-CREATIVE WS-R-CREATIVE WS-R-DEFAULT WS-NETHER WS-R-ALLOW WS-PLAYER WS-DELAY WS-ALLOWED
             IF WS-OLD >= WS-DELAY
                 MOVE 1 TO WS-RESULT
             END-IF
         ELSE
             COMPUTE PQ-PL-TIME(L-ROW) = FUNCTION MAX(PQ-PL-TIME(L-ROW) - PQ-DECAY, 0)
         END-IF
         IF WS-RESULT = 1
             MOVE PQ-PLAYER-COOLDOWN TO PQ-PL-COOLDOWN(L-ROW)
             MOVE PQ-PL-EX(L-ROW) TO WS-X
             MOVE PQ-PL-EY(L-ROW) TO WS-Y
             MOVE PQ-PL-EZ(L-ROW) TO WS-Z
             CALL "PORTAL-TRAVEL" USING L-ROW WS-X WS-Y WS-Z WS-DONE
             IF WS-DONE = 1
                 MOVE 1 TO PQ-PL-CHANGING(L-ROW)
             END-IF
         ELSE
             IF PQ-PL-TIME(L-ROW) <= 0
                 MOVE 0 TO PQ-PL-PROCESS(L-ROW)
             END-IF
         END-IF
     END-IF
*>   The inside-block sweep (the cells the box touches now).
     IF PL-STATE(L-ROW) = PS-ALIVE AND PL-MODE(L-ROW) NOT = 3
         COMPUTE WS-F = PL-X(L-ROW) - 0.3 + WS-EPS
         COMPUTE WS-MIN-X = FUNCTION INTEGER(WS-F)
         COMPUTE WS-F = PL-X(L-ROW) + 0.3 - WS-EPS
         COMPUTE WS-MAX-X = FUNCTION INTEGER(WS-F)
         COMPUTE WS-F = PL-Y(L-ROW) + WS-EPS
         COMPUTE WS-MIN-Y = FUNCTION INTEGER(WS-F)
         COMPUTE WS-F = PL-Y(L-ROW) + 1.8 - WS-EPS
         COMPUTE WS-MAX-Y = FUNCTION INTEGER(WS-F)
         COMPUTE WS-F = PL-Z(L-ROW) - 0.3 + WS-EPS
         COMPUTE WS-MIN-Z = FUNCTION INTEGER(WS-F)
         COMPUTE WS-F = PL-Z(L-ROW) + 0.3 - WS-EPS
         COMPUTE WS-MAX-Z = FUNCTION INTEGER(WS-F)
         MOVE 0 TO WS-FOUND
         PERFORM VARYING WS-X FROM WS-MIN-X BY 1 UNTIL WS-X > WS-MAX-X
             PERFORM VARYING WS-Y FROM WS-MIN-Y BY 1 UNTIL WS-Y > WS-MAX-Y
                 PERFORM VARYING WS-Z FROM WS-MIN-Z BY 1 UNTIL WS-Z > WS-MAX-Z
                     CALL "PORTAL-CELL-KIND" USING PL-DIM(L-ROW) WS-X WS-Y WS-Z WS-KIND
                     IF WS-KIND = 2 AND WS-FOUND = 0
                         MOVE 1 TO WS-FOUND
                         PERFORM SET-INSIDE
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-IF
     GOBACK.

*> setAsInsidePortal for the portal block at (WS-X, WS-Y, WS-Z).
 SET-INSIDE.
     IF PQ-PL-COOLDOWN(L-ROW) > 0
         MOVE PQ-PLAYER-COOLDOWN TO PQ-PL-COOLDOWN(L-ROW)
     ELSE
         IF PQ-PL-PROCESS(L-ROW) = 0
             MOVE 1 TO PQ-PL-PROCESS(L-ROW) PQ-PL-FLAG(L-ROW)
             MOVE 0 TO PQ-PL-TIME(L-ROW)
             MOVE WS-X TO PQ-PL-EX(L-ROW)
             MOVE WS-Y TO PQ-PL-EY(L-ROW)
             MOVE WS-Z TO PQ-PL-EZ(L-ROW)
         ELSE
             IF PQ-PL-FLAG(L-ROW) NOT = 1
                 MOVE WS-X TO PQ-PL-EX(L-ROW)
                 MOVE WS-Y TO PQ-PL-EY(L-ROW)
                 MOVE WS-Z TO PQ-PL-EZ(L-ROW)
                 MOVE 1 TO PQ-PL-FLAG(L-ROW)
             END-IF
         END-IF
     END-IF.
 END PROGRAM PORTAL-PLAYER-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-TICK.
*> No parameters: PORTAL-PLAYER-TICK for every player in play; a world without a nether portal block in its content set (a cobolcraft world)
*> has nothing to do.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PORTAL.
 01 WS-ROW                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "PORTAL-IDS-ENSURE"
     IF PI-PORTAL < 0
         GOBACK
     END-IF
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1 AND PL-STATE(WS-ROW) = PS-ALIVE
             CALL "PORTAL-PLAYER-TICK" USING WS-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PORTAL-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-POI-SCAN.
*> USING cache row of a chunk just loaded from its region file: records a nether_portal point of interest for every portal block the chunk holds
*> (the core keeps no POI files; 39 section 5.1 needs one for every portal block), in the overworld and the nether only.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY CELLS.
 COPY DIMENSIONS.
 COPY PORTAL.
 01 WS-CELLS               BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-LAYER               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PORTAL-IDS-ENSURE"
     IF PI-PORTAL < 0
         GOBACK
     END-IF
     IF DM-KEY(CK-DIM(L-ROW)) NOT = "minecraft:overworld" AND DM-KEY(CK-DIM(L-ROW)) NOT = "minecraft:the_nether"
         GOBACK
     END-IF
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(L-ROW)
     COMPUTE WS-CELLS = DM-HEIGHT(CK-DIM(L-ROW)) * 256
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > WS-CELLS
         IF CE-STATE(WS-CELL) = PI-PORTAL-X OR CE-STATE(WS-CELL) = PI-PORTAL-Z
             COMPUTE WS-LAYER = (WS-CELL - 1) / 256
             COMPUTE WS-COL = WS-CELL - 1 - WS-LAYER * 256
             COMPUTE WS-LZ = WS-COL / 16
             COMPUTE WS-X = CK-X(L-ROW) * 16 + WS-COL - WS-LZ * 16
             COMPUTE WS-Z = CK-Z(L-ROW) * 16 + WS-LZ
             COMPUTE WS-Y = DM-MIN-Y(CK-DIM(L-ROW)) + WS-LAYER
             CALL "PORTAL-POI-ADD" USING CK-DIM(L-ROW) WS-X WS-Y WS-Z
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PORTAL-POI-SCAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PORTAL-LOAD-SAVED.
*> USING destination dimension row, origin x, z, search radius (BINARY-LONG): PortalForcer step 2 (39 section 5.1: the points of interest of the
*> chunks within the radius are made loaded and valid): every chunk of the square |dx| <= radius, |dz| <= radius round the origin that is not
*> in the cache but is in the dimension's region file is loaded (WORLD-CHUNK-LOAD records its portal blocks, PORTAL-POI-SCAN), so a portal saved
*> before a restart is found. Chunks the file lacks are not generated.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-REGION              PIC X(8) VALUE "region".
 01 WS-DIR                 PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-LOW-X               BINARY-LONG.
 01 WS-HIGH-X              BINARY-LONG.
 01 WS-LOW-Z               BINARY-LONG.
 01 WS-HIGH-Z              BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-OX L-OZ L-RADIUS.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     COMPUTE WS-T = L-OX - L-RADIUS
     COMPUTE WS-LOW-X = FUNCTION INTEGER(WS-T / 16)
     COMPUTE WS-T = L-OX + L-RADIUS
     COMPUTE WS-HIGH-X = FUNCTION INTEGER(WS-T / 16)
     COMPUTE WS-T = L-OZ - L-RADIUS
     COMPUTE WS-LOW-Z = FUNCTION INTEGER(WS-T / 16)
     COMPUTE WS-T = L-OZ + L-RADIUS
     COMPUTE WS-HIGH-Z = FUNCTION INTEGER(WS-T / 16)
     CALL "PERSIST-DIM-DIR" USING L-DIM WS-REGION WS-DIR WS-LENGTH
     PERFORM VARYING WS-CZ FROM WS-LOW-Z BY 1 UNTIL WS-CZ > WS-HIGH-Z
         PERFORM VARYING WS-CX FROM WS-LOW-X BY 1 UNTIL WS-CX > WS-HIGH-X
             CALL "WORLD-FIND" USING L-DIM WS-CX WS-CZ WS-ROW
             IF WS-ROW = 0
                 CALL "REGION-READ" USING WS-DIR WS-LENGTH WS-CX WS-CZ PB-BUFFER WS-OUTCOME
                 IF WS-OUTCOME = 0
                     CALL "WORLD-CHUNK-LOAD" USING L-DIM WS-CX WS-CZ WS-ROW
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM PORTAL-LOAD-SAVED.
