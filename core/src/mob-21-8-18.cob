*> The wind charge and the breeze wind charge (docs/protocol/21 section 8.18, 44-8 section 8, 17 section 3.15, 20 section 6.2, 42-7 section 3.1), lane p49f. PJ-KIND 42: PJ-I1 1 for the breeze's charge.
*> The charge flies straight at constant speed (acceleration power 0, inertia 1.0: THROWN-FLY2 with no gravity and drag 1). A hit player or standard mob takes 1.0 (a player through HEALTH-HURT with
*> CAUSE-MOB, a mob 1 point) and the burst follows at the charge's position; a block hit bursts 0.25 outside the face that was hit (XP-BOTTLE-NORMAL gives the normal); a charge whose position is above
*> the world top 319 + 30 bursts where it is. The burst (WIND-EXPLODE): radius 1.2 and knockback multiplier 1.22 for the charge of a player, 3.0 and none for the breeze's; no entity damage, no block
*> destruction; a player or standard mob within 2 x radius is pushed by (1 - dist) x seen x multiplier (dist = distance of its feet to the centre / (2 x radius), seen = EXPLODE-SEEN) along the direction from
*> the centre to its eyes; a flying player has multiplier 0; the players within 64 blocks get the Explode packet (particle gust_emitter_small 34 below radius 2, gust_emitter_large 33 else; no blocks).
*> Redirect by attack (WIND-REDIRECT, called by PROJ-REDIRECT; wrap C round 6, T24214): a player's attack on a charge is AIM_DEFLECT (44-8 6.3): the velocity becomes the player's look direction, the player
*> the owner and the acceleration power 0.1 (PJ-ROU, 6.4 onDeflection by an attack: each tick adds 0.1 along the velocity before the flight); the charge of a player refuses any deflection for its first
*> 5 ticks (PJ-I2 the noDeflectTicks, counted down by WIND-STEP), the breeze's charge has no window; the attack never damages a charge. Not done: the pick radius 1.0 of a redirectable charge, a charge flying into another one.
*> Not done: triggering the blocks in the burst (levers, buttons, doors, trapdoors, gates, candles: the per-block rules of 24 are given but the exploded-position walk with the immune set
*> blocks_wind_charge_explosions is not built), the box 0.15 below the position (the flight uses the thrown entities' 0.25 box), pushes of
*> non-mob entities (items, arrows, boats), the burst sounds are the registered holders of 21 section 8.18 (lane p49t),
*> the dispenser launch (30-4 4.1 gives it: position, 6.6666665 uncertainty, power 1.0), the breeze that shoots it (20 section 8).
*>
*>   WIND-SPAWN USING breeze (0 or 1), dim, x, y, z, vx, vy, vz (FLOAT-LONG), owner entity id, row out
*>   WIND-STRENGTH USING dist, seen (FLOAT-LONG), multiplier (thousandths), flying (0 or 1), strength out (FLOAT-LONG)
*>   WIND-BUILD USING x, y, z, radius (FLOAT-LONG), knockback present, kx, ky, kz, PB-BUFFER   the Explode packet
*>   WIND-EXPLODE USING dim, x, y, z, radius (FLOAT-LONG), multiplier (thousandths), source tracker row (0 none)
*>   WIND-STEP USING tracker row

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIND-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-KEY-WIND            PIC X(112) VALUE "minecraft:wind_charge".
 01 WS-KEY-BREEZE          PIC X(112) VALUE "minecraft:breeze_wind_charge".
 01 WS-KIND                BINARY-LONG VALUE 42.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-BREEZE               BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-OWNER                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-BREEZE L-DIM L-X L-Y L-Z L-VX L-VY L-VZ L-OWNER L-ROW.
     IF L-BREEZE = 1
         CALL "THROWN-SPAWN" USING WS-KIND WS-KEY-BREEZE L-DIM L-X L-Y L-Z L-VX L-VY L-VZ L-OWNER L-ROW
     ELSE
         CALL "THROWN-SPAWN" USING WS-KIND WS-KEY-WIND L-DIM L-X L-Y L-Z L-VX L-VY L-VZ L-OWNER L-ROW
     END-IF
     IF L-ROW > 0
         CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
         MOVE L-BREEZE TO PJ-I1(WS-SLOT)
*>       noDeflectTicks = 5 for the charge of a player (the breeze's has none).
         IF L-BREEZE = 0
             MOVE 5 TO PJ-I2(WS-SLOT)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WIND-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIND-STRENGTH.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIST                 FLOAT-LONG.
 01 L-SEEN                 FLOAT-LONG.
 01 L-MULT                 BINARY-LONG.
 01 L-FLYING               BINARY-LONG.
 01 L-STRENGTH             FLOAT-LONG.
 PROCEDURE DIVISION USING L-DIST L-SEEN L-MULT L-FLYING L-STRENGTH.
     COMPUTE L-STRENGTH = (1 - L-DIST) * L-SEEN * L-MULT / 1000
     IF L-FLYING = 1
         MOVE 0 TO L-STRENGTH
     END-IF
     GOBACK.
 END PROGRAM WIND-STRENGTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIND-BUILD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 36.
 01 WS-RADIUS              FLOAT-SHORT.
 01 WS-PARTICLE            BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-DATA                PIC X(64).
 01 WS-HOLDER              BINARY-LONG.
 01 WS-TRUE                BINARY-LONG VALUE 1.
 01 WS-FALSE               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-RADIUS               FLOAT-LONG.
 01 L-KNOCK                BINARY-LONG.
 01 L-KX                   FLOAT-LONG.
 01 L-KY                   FLOAT-LONG.
 01 L-KZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-RADIUS L-KNOCK L-KX L-KY L-KZ PB-BUFFER.
     MOVE L-RADIUS TO WS-RADIUS
     MOVE 33 TO WS-PARTICLE
     IF L-RADIUS < 2
         MOVE 34 TO WS-PARTICLE
     END-IF
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Z
     CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-RADIUS
     CALL "PB-PUT-INT" USING PB-BUFFER WS-NONE
     IF L-KNOCK = 1
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-TRUE
         CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-KX
         CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-KY
         CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-KZ
     ELSE
         CALL "PB-PUT-BOOL" USING PB-BUFFER WS-FALSE
     END-IF
     CALL "PB-PUT-PARTICLE" USING PB-BUFFER WS-PARTICLE WS-NONE WS-DATA
*>   The explosion sound as a registered holder (id + 1): entity.wind_charge.wind_burst 1776 for the wind charge, entity.breeze.wind_burst 210 for the breeze's (21 section 8.18, 46).
     COMPUTE WS-HOLDER = 1777
     IF L-RADIUS >= 2
         COMPUTE WS-HOLDER = 211
     END-IF
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-HOLDER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-NONE
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-TRUE
     GOBACK.
 END PROGRAM WIND-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIND-EXPLODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-REACH               FLOAT-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-WIDTH               FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-SEEN                FLOAT-LONG.
 01 WS-MINX                FLOAT-LONG.
 01 WS-MINY                FLOAT-LONG.
 01 WS-MINZ                FLOAT-LONG.
 01 WS-MAXX                FLOAT-LONG.
 01 WS-MAXY                FLOAT-LONG.
 01 WS-MAXZ                FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-FLYING              BINARY-LONG.
 01 WS-KNOCK.
    05 WS-KN OCCURS 64 TIMES.
       10 WS-KN-SET        BINARY-LONG.
       10 WS-KN-X          FLOAT-LONG.
       10 WS-KN-Y          FLOAT-LONG.
       10 WS-KN-Z          FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-RADIUS               FLOAT-LONG.
 01 L-MULT                 BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-RADIUS L-MULT L-SOURCE.
     INITIALIZE WS-KNOCK
     COMPUTE WS-REACH = 2 * L-RADIUS
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = L-DIM
                 AND PL-MODE(WS-P) < 3
             COMPUTE WS-DX = PL-X(WS-P) - L-X
             COMPUTE WS-DY = PL-Y(WS-P) - L-Y
             COMPUTE WS-DZ = PL-Z(WS-P) - L-Z
             COMPUTE WS-DIST = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ) / WS-REACH
             IF WS-DIST <= 1
                 COMPUTE WS-MINX = PL-X(WS-P) - 0.3
                 COMPUTE WS-MAXX = PL-X(WS-P) + 0.3
                 MOVE PL-Y(WS-P) TO WS-MINY
                 COMPUTE WS-MAXY = PL-Y(WS-P) + 1.8
                 COMPUTE WS-MINZ = PL-Z(WS-P) - 0.3
                 COMPUTE WS-MAXZ = PL-Z(WS-P) + 0.3
                 CALL "EXPLODE-SEEN" USING L-DIM L-X L-Y L-Z WS-MINX WS-MINY WS-MINZ WS-MAXX WS-MAXY WS-MAXZ WS-SEEN
                 MOVE PL-FLYING(WS-P) TO WS-FLYING
                 CALL "WIND-STRENGTH" USING WS-DIST WS-SEEN L-MULT WS-FLYING WS-S
                 COMPUTE WS-DY = PL-Y(WS-P) + 1.62 - L-Y
                 COMPUTE WS-DX = PL-X(WS-P) - L-X
                 COMPUTE WS-DZ = PL-Z(WS-P) - L-Z
                 COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
                 IF WS-LEN > 0
                     MOVE 1 TO WS-KN-SET(WS-P)
                     COMPUTE WS-KN-X(WS-P) = WS-DX / WS-LEN * WS-S
                     COMPUTE WS-KN-Y(WS-P) = WS-DY / WS-LEN * WS-S
                     COMPUTE WS-KN-Z(WS-P) = WS-DZ / WS-LEN * WS-S
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-DIM(WS-E) = L-DIM AND EN-HEALTH(WS-E) > 0 AND WS-E NOT = L-SOURCE
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-E) WS-M
             IF WS-M > 0
                 COMPUTE WS-DX = EN-X(WS-E) - L-X
                 COMPUTE WS-DY = EN-Y(WS-E) - L-Y
                 COMPUTE WS-DZ = EN-Z(WS-E) - L-Z
                 COMPUTE WS-DIST = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ) / WS-REACH
                 IF WS-DIST <= 1
                     COMPUTE WS-WIDTH = ET-WIDTH-MILLI(EN-TYPE(WS-E) + 1) / 1000
                     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(EN-TYPE(WS-E) + 1) / 1000
                     COMPUTE WS-MINX = EN-X(WS-E) - WS-WIDTH / 2
                     COMPUTE WS-MAXX = EN-X(WS-E) + WS-WIDTH / 2
                     MOVE EN-Y(WS-E) TO WS-MINY
                     COMPUTE WS-MAXY = EN-Y(WS-E) + WS-HEIGHT
                     COMPUTE WS-MINZ = EN-Z(WS-E) - WS-WIDTH / 2
                     COMPUTE WS-MAXZ = EN-Z(WS-E) + WS-WIDTH / 2
                     CALL "EXPLODE-SEEN" USING L-DIM L-X L-Y L-Z WS-MINX WS-MINY WS-MINZ WS-MAXX WS-MAXY WS-MAXZ WS-SEEN
                     MOVE 0 TO WS-FLYING
                     CALL "WIND-STRENGTH" USING WS-DIST WS-SEEN L-MULT WS-FLYING WS-S
                     COMPUTE WS-DY = EN-Y(WS-E) + WS-HEIGHT * 0.85 - L-Y
                     COMPUTE WS-DX = EN-X(WS-E) - L-X
                     COMPUTE WS-DZ = EN-Z(WS-E) - L-Z
                     COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
                     IF WS-LEN > 0
                         COMPUTE EN-VX(WS-E) = EN-VX(WS-E) + WS-DX / WS-LEN * WS-S
                         COMPUTE EN-VY(WS-E) = EN-VY(WS-E) + WS-DY / WS-LEN * WS-S
                         COMPUTE EN-VZ(WS-E) = EN-VZ(WS-E) + WS-DZ / WS-LEN * WS-S
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0 AND PL-DIM(WS-P) = L-DIM
             COMPUTE WS-DX = PL-X(WS-P) - L-X
             COMPUTE WS-DY = PL-Y(WS-P) - L-Y
             COMPUTE WS-DZ = PL-Z(WS-P) - L-Z
             IF WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ < 4096
                 CALL "PB-RESET" USING PB-BUFFER
                 CALL "WIND-BUILD" USING L-X L-Y L-Z L-RADIUS WS-KN-SET(WS-P) WS-KN-X(WS-P) WS-KN-Y(WS-P) WS-KN-Z(WS-P) PB-BUFFER
                 CALL "CORE-SEND" USING PL-CONN(WS-P) PB-BUFFER
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM WIND-EXPLODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIND-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY RULES.
 01 WS-SLOT                BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-NO-GRAVITY          FLOAT-LONG VALUE 0.
 01 WS-NO-DRAG             FLOAT-LONG VALUE 1.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-NX                  FLOAT-LONG.
 01 WS-NY                  FLOAT-LONG.
 01 WS-NZ                  FLOAT-LONG.
 01 WS-RADIUS              FLOAT-LONG.
 01 WS-MULT                BINARY-LONG.
 01 WS-TOP                 FLOAT-LONG VALUE 349.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-MOB.
 01 WS-MILLI               BINARY-LONG VALUE 1000.
 01 WS-POINT               BINARY-LONG VALUE 1.
 01 WS-OWNER-ID            BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 01 WS-RESULT              BINARY-LONG.
 01 WS-BURST               BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE 3.0 TO WS-RADIUS
     MOVE 1000 TO WS-MULT
     IF PJ-I1(WS-SLOT) = 0
         MOVE 1.2 TO WS-RADIUS
         MOVE 1220 TO WS-MULT
     END-IF
     MOVE 0 TO WS-BURST
*>   The no-deflect window counts down; a redirected charge (power 0.1) adds the power along its velocity before it flies (applyInertia).
     IF PJ-I2(WS-SLOT) > 0
         SUBTRACT 1 FROM PJ-I2(WS-SLOT)
     END-IF
     COMPUTE WS-SPEED = FUNCTION SQRT(EN-VX(L-ROW) * EN-VX(L-ROW) + EN-VY(L-ROW) * EN-VY(L-ROW) + EN-VZ(L-ROW) * EN-VZ(L-ROW))
     IF PJ-ROU(WS-SLOT) > 0 AND WS-SPEED > 0
         COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) + EN-VX(L-ROW) / WS-SPEED * PJ-ROU(WS-SLOT)
         COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + EN-VY(L-ROW) / WS-SPEED * PJ-ROU(WS-SLOT)
         COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + EN-VZ(L-ROW) / WS-SPEED * PJ-ROU(WS-SLOT)
     END-IF
     IF EN-Y(L-ROW) > WS-TOP
         MOVE EN-X(L-ROW) TO WS-X
         MOVE EN-Y(L-ROW) TO WS-Y
         MOVE EN-Z(L-ROW) TO WS-Z
         MOVE 1 TO WS-BURST
     ELSE
         CALL "THROWN-FLY2" USING L-ROW WS-NO-GRAVITY WS-NO-DRAG WS-HIT WS-ENTITY WS-PLAYER
         MOVE EN-X(L-ROW) TO WS-X
         MOVE EN-Y(L-ROW) TO WS-Y
         MOVE EN-Z(L-ROW) TO WS-Z
         IF WS-HIT = 1
             CALL "XP-BOTTLE-NORMAL" USING L-ROW WS-NX WS-NY WS-NZ
             COMPUTE WS-X = WS-X + WS-NX * 0.25
             COMPUTE WS-Y = WS-Y + WS-NY * 0.25
             COMPUTE WS-Z = WS-Z + WS-NZ * 0.25
             MOVE 1 TO WS-BURST
         END-IF
         IF WS-HIT = 2
             MOVE EN-TARGET-ID(L-ROW) TO WS-OWNER-ID
             IF WS-PLAYER > 0
                 CALL "HEALTH-HURT" USING WS-PLAYER WS-MILLI WS-CAUSE WS-OWNER-ID WS-NONE WS-RESULT
             END-IF
             IF WS-ENTITY > 0
                 CALL "HEALTH-MOB-DAMAGE" USING WS-ENTITY WS-POINT WS-CAUSE WS-NONE2
             END-IF
             MOVE 1 TO WS-BURST
         END-IF
     END-IF
     IF WS-BURST = 1
         CALL "WIND-EXPLODE" USING WS-DIM WS-X WS-Y WS-Z WS-RADIUS WS-MULT L-ROW
         CALL "PJ-DROP" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM WIND-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIND-REDIRECT.
*> USING player row, tracker row, done out: a player's attack on a wind charge (44-8 section 8 Redirection, 6.3 AIM_DEFLECT, 6.4 onDeflection). done is 1 for a wind charge (the attack never damages it).
*> Outside the no-deflect window the velocity becomes the player's look direction (speed 1), the player is the owner and the acceleration power is 0.1 (PJ-ROU); inside it nothing changes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ROW L-DONE.
     MOVE 0 TO L-DONE
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT > 0 AND PJ-KIND(WS-SLOT) = 42
         MOVE 1 TO L-DONE
         IF PJ-I2(WS-SLOT) = 0
             COMPUTE WS-YAW = PL-YAW(L-PLAYER) * FUNCTION PI / 180
             COMPUTE WS-PITCH = PL-PITCH(L-PLAYER) * FUNCTION PI / 180
             COMPUTE EN-VX(L-ROW) = 0 - FUNCTION SIN(WS-YAW) * FUNCTION COS(WS-PITCH)
             COMPUTE EN-VY(L-ROW) = 0 - FUNCTION SIN(WS-PITCH)
             COMPUTE EN-VZ(L-ROW) = FUNCTION COS(WS-YAW) * FUNCTION COS(WS-PITCH)
             MOVE PL-ENTITY-ID(L-PLAYER) TO EN-TARGET-ID(L-ROW) PJ-OWNER(WS-SLOT)
             MOVE 0.1 TO PJ-ROU(WS-SLOT)
             CALL "PROJ-ROTATE" USING L-ROW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WIND-REDIRECT.
