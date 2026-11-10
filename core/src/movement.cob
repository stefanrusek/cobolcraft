*> Player movement (US3-2, US3-3; data-model §6; docs/protocol/05c 0x1E to 0x21, 0x28 and "Accept
*> Teleportation"; standin-content §3, §10.3 fall distance).
*>
*> Move Player packets are ignored while the connection's last Player Position is not yet accepted
*> (05c: the server ignores movement until a matching Accept Teleportation). A move with a position
*> whose player box would intersect a solid block is refused: the player is sent Player Position at
*> the last valid position (a new teleport id, awaited again). An accepted move stores the position,
*> rotation and on-ground flag, tracks the fall start, moves the chunk view (CHUNKS-FOLLOW) and the
*> player's entity for the other players (ENTITY-MOVE).
*>
*> Player box (standin §3, cobolcraft:operator): width x height, centred on the feet position
*> horizontally, from the feet y upward. A cell [bx, bx + 1) x [by, by + 1) x [bz, bz + 1) is hit when
*> it overlaps the box with positive volume (touching faces do not overlap; edges within 1e-7 block
*> of a cell face count as touching) and its block state is solid (BLOCKS.cpy SB-SOLID).
*>
*> Fall start (standin §10.3): while the player is on the ground, flying or in creative mode it
*> follows the feet y; otherwise it is the highest feet y since the player was last on the ground.
*> An accepted move with on-ground true ends a fall: D = fall start - the new feet y, and when
*> floor(D) >= 5 the player takes 2 x (floor(D) - 4) fall damage (HEALTH-DAMAGE, cause fall; a
*> creative player takes none) after the move has been applied and sent.
*>
*> Exhaustion (standin §11.2; HUNGER-EXHAUST, core/src/hunger.cob, counts it only for an alive
*> survival player): an accepted move with a position adds 0.02 per block of horizontal distance
*> from the last accepted position (sqrt(dx^2 + dz^2)), 0.12 while the sprinting flag is set, and
*> nothing while flying; a move with on-ground false after one with on-ground true and a higher feet
*> y is a jump and adds 0.3.
*>
*> Sprinting (MOVE-SPRINT, Player Command 0x2A): action 1 START_SPRINTING sets the player's
*> sprinting flag, action 2 STOP_SPRINTING clears it, other actions leave it (data-model §6). Death
*> and respawn clear it (core/src/health.cob).
*>
*> Entry points:
*>   MOVE-PLAYER USING connection id, packet id (30 to 33), PLAY-SERVERBOUND
*>   MOVE-SPRINT USING connection id, PLAY-SERVERBOUND
*>   MOVE-ABILITIES USING connection id, flags (BINARY-LONG)
*>   MOVE-COLLIDES USING dim, x, y, z (FLOAT-LONG feet position), hit out (BINARY-LONG 1 or 0)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOVE-COLLIDES.
*> USING dimension row, feet x, y, z (FLOAT-LONG), hit out (BINARY-LONG): 1 when the player box at
*> that position overlaps a solid block, else 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 COPY CBLOCKS.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-EPSILON             FLOAT-LONG VALUE 0.0000001.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-HIT.
     MOVE 0 TO L-HIT
     COMPUTE WS-HALF = ET-WIDTH-MILLI(CR-OPERATOR + 1) / 2000
     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(CR-OPERATOR + 1) / 1000
*>   First cell: floor(low edge + e); last cell: ceil(high edge - e) - 1. The tolerance e (1e-7
*>   block) keeps a face that touches a cell face from counting as an overlap when the edge is not
*>   exactly representable (x + 0.35).
     COMPUTE WS-X0 = FUNCTION INTEGER(L-X - WS-HALF + WS-EPSILON)
     COMPUTE WS-X1 = - FUNCTION INTEGER(WS-EPSILON - (L-X + WS-HALF)) - 1
     COMPUTE WS-Y0 = FUNCTION INTEGER(L-Y + WS-EPSILON)
     COMPUTE WS-Y1 = - FUNCTION INTEGER(WS-EPSILON - (L-Y + WS-HEIGHT)) - 1
     COMPUTE WS-Z0 = FUNCTION INTEGER(L-Z - WS-HALF + WS-EPSILON)
     COMPUTE WS-Z1 = - FUNCTION INTEGER(WS-EPSILON - (L-Z + WS-HALF)) - 1
     PERFORM VARYING WS-BY FROM WS-Y0 BY 1 UNTIL WS-BY > WS-Y1 OR L-HIT = 1
         PERFORM VARYING WS-BZ FROM WS-Z0 BY 1 UNTIL WS-BZ > WS-Z1 OR L-HIT = 1
             PERFORM VARYING WS-BX FROM WS-X0 BY 1 UNTIL WS-BX > WS-X1 OR L-HIT = 1
                 CALL "WORLD-GET-BLOCK" USING L-DIM WS-BX WS-BY WS-BZ WS-STATE
                 MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLK
                 IF CB-SOLID(WS-BLK + 1) = 1
                     MOVE 1 TO L-HIT
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM MOVE-COLLIDES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOVE-PLAYER.
*> USING connection id, packet id (30 Pos, 31 Pos Rot, 32 Rot, 33 Status Only), PLAY-SERVERBOUND
*> (PSB-X to PSB-PITCH as the packet has them, PSB-FLAGS): one Move Player packet, as above.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 128.
 01 WS-ROW                 BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-MOVED               PIC 9.
 01 WS-ON-GROUND           BINARY-LONG.
 01 WS-FALL                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-NO-ENTITY           BINARY-LONG VALUE 0.
 01 WS-NO-ATTACKER         BINARY-LONG VALUE 0.
 01 WS-OLD-X               FLOAT-LONG.
 01 WS-OLD-Y               FLOAT-LONG.
 01 WS-OLD-Z               FLOAT-LONG.
 01 WS-OLD-ON-GROUND       PIC 9.
 01 WS-EXHAUST             FLOAT-LONG.
 01 WS-RATE                BINARY-LONG.
 01 WS-SUPPORTED           BINARY-LONG.
 01 WS-CLIMBING            BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 01 L-PACKET-ID            BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-PACKET-ID PLAY-SERVERBOUND.
     IF CN-TELEPORT-ACKED(L-ID) = 0
         GOBACK
     END-IF
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     MOVE 0 TO WS-MOVED
     IF L-PACKET-ID = 30 OR L-PACKET-ID = 31
         CALL "MOVE-COLLIDES" USING PL-DIM(WS-ROW) PSB-X PSB-Y PSB-Z WS-HIT
*>       A rise that claims the ground (on-ground 1) without support or a climbable block is refused
*>       like a collision (move-check.cob): the endless climb of a client that claims the ground in
*>       the air.
         IF WS-HIT = 0 AND FUNCTION MOD(PSB-FLAGS, 2) = 1 AND PL-MODE(WS-ROW) = 0
                 AND PL-FLYING(WS-ROW) = 0 AND PSB-Y > PL-Y(WS-ROW) + 0.00001
             CALL "MOVE-SUPPORTED" USING PL-DIM(WS-ROW) PSB-X PSB-Y PSB-Z WS-SUPPORTED
             IF WS-SUPPORTED = 0
                 CALL "MOVE-CLIMBING" USING PL-DIM(WS-ROW) PSB-X PSB-Y PSB-Z WS-CLIMBING
                 IF WS-CLIMBING = 0
                     MOVE 1 TO WS-HIT
                 END-IF
             END-IF
         END-IF
         IF WS-HIT = 1
             IF WS-READY = 0
                 CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
                 MOVE 1 TO WS-READY
             END-IF
             CALL "PB-RESET" USING PB-BUFFER
             ADD 1 TO CN-TELEPORT-ID(L-ID)
             MOVE 0 TO CN-TELEPORT-ACKED(L-ID)
             CALL "PLAY-POSITION-BUILD" USING CN-TELEPORT-ID(L-ID) PL-X(WS-ROW) PL-Y(WS-ROW)
                 PL-Z(WS-ROW) PL-YAW(WS-ROW) PL-PITCH(WS-ROW) PB-BUFFER
             CALL "CORE-SEND" USING L-ID PB-BUFFER
             GOBACK
         END-IF
         MOVE PL-X(WS-ROW) TO WS-OLD-X
         MOVE PL-Y(WS-ROW) TO WS-OLD-Y
         MOVE PL-Z(WS-ROW) TO WS-OLD-Z
         MOVE PSB-X TO PL-X(WS-ROW)
         MOVE PSB-Y TO PL-Y(WS-ROW)
         MOVE PSB-Z TO PL-Z(WS-ROW)
         MOVE 1 TO WS-MOVED
     END-IF
     IF L-PACKET-ID = 31 OR L-PACKET-ID = 32
         MOVE PSB-YAW TO PL-YAW(WS-ROW)
         MOVE PSB-PITCH TO PL-PITCH(WS-ROW)
     END-IF
     MOVE PL-ON-GROUND(WS-ROW) TO WS-OLD-ON-GROUND
     MOVE FUNCTION MOD(PSB-FLAGS, 2) TO PL-ON-GROUND(WS-ROW)
*>   The claim counts as ground only with support below the feet (move-check.cob).
     IF PL-ON-GROUND(WS-ROW) = 1 AND PL-MODE(WS-ROW) = 0
         CALL "MOVE-SUPPORTED" USING PL-DIM(WS-ROW) PL-X(WS-ROW) PL-Y(WS-ROW) PL-Z(WS-ROW)
             WS-SUPPORTED
         IF WS-SUPPORTED = 0
             MOVE 0 TO PL-ON-GROUND(WS-ROW)
         END-IF
     END-IF
     MOVE 0 TO WS-FALL
     IF PL-ON-GROUND(WS-ROW) = 1
         COMPUTE WS-FALL = FUNCTION INTEGER(PL-FALL-START(WS-ROW) - PL-Y(WS-ROW))
     END-IF
     IF PL-ON-GROUND(WS-ROW) = 1 OR PL-FLYING(WS-ROW) = 1 OR PL-MODE(WS-ROW) = 1
             OR PL-Y(WS-ROW) > PL-FALL-START(WS-ROW)
         MOVE PL-Y(WS-ROW) TO PL-FALL-START(WS-ROW)
     END-IF
     IF WS-MOVED = 1
         CALL "CHUNKS-FOLLOW" USING L-ID
     END-IF
     IF PL-ENTITY-ROW(WS-ROW) > 0
         MOVE PL-ON-GROUND(WS-ROW) TO WS-ON-GROUND
         CALL "ENTITY-MOVE" USING PL-ENTITY-ROW(WS-ROW) PL-X(WS-ROW) PL-Y(WS-ROW) PL-Z(WS-ROW)
             PL-YAW(WS-ROW) PL-PITCH(WS-ROW) WS-ON-GROUND
     END-IF
*>   Exhaustion of walking or running, and of a jump (§11.2).
     IF WS-MOVED = 1 AND PL-FLYING(WS-ROW) = 0
         MOVE RULE-EXHAUST-WALK-MILLI TO WS-RATE
         IF PL-SPRINTING(WS-ROW) = 1
             MOVE RULE-EXHAUST-SPRINT-MILLI TO WS-RATE
         END-IF
         COMPUTE WS-EXHAUST = FUNCTION SQRT((PL-X(WS-ROW) - WS-OLD-X) ** 2
             + (PL-Z(WS-ROW) - WS-OLD-Z) ** 2) * WS-RATE / 1000
         CALL "HUNGER-EXHAUST" USING WS-ROW WS-EXHAUST
         IF WS-OLD-ON-GROUND = 1 AND PL-ON-GROUND(WS-ROW) = 0 AND PL-Y(WS-ROW) > WS-OLD-Y
             COMPUTE WS-EXHAUST = RULE-EXHAUST-JUMP-MILLI / 1000
             CALL "HUNGER-EXHAUST" USING WS-ROW WS-EXHAUST
         END-IF
     END-IF
     IF WS-FALL > RULE-SAFE-FALL
         COMPUTE WS-AMOUNT = RULE-FALL-FACTOR * (WS-FALL - RULE-SAFE-FALL)
         MOVE CAUSE-FALL TO WS-CAUSE
         CALL "HEALTH-DAMAGE" USING WS-ROW WS-AMOUNT WS-CAUSE WS-NO-ENTITY WS-NO-ATTACKER
     END-IF
     GOBACK.
 END PROGRAM MOVE-PLAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOVE-ABILITIES.
*> USING connection id, flags (BINARY-LONG, the signed Byte of 05c 0x28): flying (0x02) is accepted
*> only from a creative player (US3-3). A survival player's request is refused: flying stays off and
*> the player is sent its Player Abilities again (09 §3.2: flags 0x00).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-FLAGS.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     IF PL-MODE(WS-ROW) = 1
         MOVE 0 TO PL-FLYING(WS-ROW)
         IF FUNCTION MOD(L-FLAGS, 4) >= 2
             MOVE 1 TO PL-FLYING(WS-ROW)
         END-IF
         GOBACK
     END-IF
     MOVE 0 TO PL-FLYING(WS-ROW)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PLAY-ABILITIES-BUILD" USING PL-MODE(WS-ROW) PL-FLYING(WS-ROW) PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM MOVE-ABILITIES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOVE-SPRINT.
*> USING connection id, PLAY-SERVERBOUND (a decoded Player Command 0x2A): action 1 sets the
*> sprinting flag, action 2 clears it, any other action is ignored.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     IF PSB-ACTION = 1
         MOVE 1 TO PL-SPRINTING(CN-PLAYER(L-ID))
     END-IF
     IF PSB-ACTION = 2
         MOVE 0 TO PL-SPRINTING(CN-PLAYER(L-ID))
     END-IF
     GOBACK.
 END PROGRAM MOVE-SPRINT.
