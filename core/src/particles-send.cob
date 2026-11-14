*> Particles sent by the server (docs/protocol/42-particles-7 section 1, 42-particles-6 section 8.2; 05a
*> 0x30 Level Particles): the client draws the particles of these emissions from the packet only (the base
*> Level methods do nothing on a server). PARTICLE-BUILD writes the packet, PARTICLE-SEND offers it to every
*> player of the dimension whose block position is closer than 32 blocks to the point (512 with the
*> override limiter; the always-show flag only travels), and the three emitters below are the sites whose
*> events the core has: a player's hit that damages a player or a mob by more than 2 (damage_indicator,
*> 42-7 section 1.4 Player.damageStatsAndHearts) and a survival player's landing after a fall (block
*> particles of the landed-on state, 42-6 section 8.2). Particle type ids are the registry order of
*> 46 section 5.1: block 1, damage_indicator 14.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PARTICLE-BUILD.
*> USING PB-BUFFER, particle type id, option (-1 none, else the VarInt state of a block particle), override
*> limiter (0/1), always show (0/1), x, y, z (FLOAT-LONG), the six floats (distances x y z then max speeds
*> x y z; a table of FLOAT-SHORT), count, randomisation (0 default): the packet id 0x30 and its body.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 48.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TYPE                 BINARY-LONG.
 01 L-OPTION               BINARY-LONG.
 01 L-OVERRIDE             BINARY-LONG.
 01 L-ALWAYS               BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-SPREAD-TABLE.
    05 L-SPREAD            FLOAT-SHORT OCCURS 6 TIMES.
 01 L-COUNT                BINARY-LONG.
 01 L-RANDOM               BINARY-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-TYPE L-OPTION L-OVERRIDE L-ALWAYS L-X L-Y L-Z L-SPREAD-TABLE
         L-COUNT L-RANDOM.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TYPE
     IF L-OPTION >= 0
         CALL "PB-PUT-VARINT" USING PB-BUFFER L-OPTION
     END-IF
     CALL "PB-PUT-BOOL" USING PB-BUFFER L-OVERRIDE
     CALL "PB-PUT-BOOL" USING PB-BUFFER L-ALWAYS
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Z
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         CALL "PB-PUT-FLOAT" USING PB-BUFFER L-SPREAD(WS-I)
     END-PERFORM
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-COUNT
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-RANDOM
     GOBACK.
 END PROGRAM PARTICLE-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PARTICLE-SEND.
*> USING dimension row, the arguments of PARTICLE-BUILD after the buffer: the packet to every player of
*> the dimension within the radius (42-7 section 1.2: the distance from the centre of the player's block
*> to the point is below 32, or below 512 with the override limiter).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 128.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-RADIUS-SQUARED      BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-OPTION               BINARY-LONG.
 01 L-OVERRIDE             BINARY-LONG.
 01 L-ALWAYS               BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-SPREAD-TABLE.
    05 L-SPREAD            FLOAT-SHORT OCCURS 6 TIMES.
 01 L-COUNT                BINARY-LONG.
 01 L-RANDOM               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-TYPE L-OPTION L-OVERRIDE L-ALWAYS L-X L-Y L-Z L-SPREAD-TABLE
         L-COUNT L-RANDOM.
     MOVE 1024 TO WS-RADIUS-SQUARED
     IF L-OVERRIDE = 1
         MOVE 262144 TO WS-RADIUS-SQUARED
     END-IF
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PARTICLE-BUILD" USING PB-BUFFER L-TYPE L-OPTION L-OVERRIDE L-ALWAYS L-X L-Y L-Z
         L-SPREAD-TABLE L-COUNT L-RANDOM
     PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS
         IF PL-USED(WS-PLAYER) = 1 AND PL-DIM(WS-PLAYER) = L-DIM
             COMPUTE WS-DX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 0.5 - L-X
             COMPUTE WS-DY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 0.5 - L-Y
             COMPUTE WS-DZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 0.5 - L-Z
             IF WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ < WS-RADIUS-SQUARED
                 CALL "CORE-SEND" USING PL-CONN(WS-PLAYER) PB-BUFFER
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM PARTICLE-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PARTICLE-DAMAGE-INDICATOR.
*> USING dimension row, health lost, x, y, z (the target's x, y at half its height, z): when more than 2 was
*> lost, damage_indicator (14), count (int)(lost * 0.5), spread 0.1, 0, 0.1, speed 0.2 on all axes, default
*> randomisation, no flags (42-7 section 1.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG VALUE 14.
 01 WS-NO-OPTION           BINARY-LONG VALUE -1.
 01 WS-OVERRIDE            BINARY-LONG VALUE 0.
 01 WS-ALWAYS              BINARY-LONG VALUE 0.
 01 WS-RANDOM              BINARY-LONG VALUE 0.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SPREAD-TABLE.
    05 WS-SPREAD           FLOAT-SHORT OCCURS 6 TIMES.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-LOST                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-DIM L-LOST L-X L-Y L-Z.
     IF L-LOST > 2
         COMPUTE WS-COUNT = L-LOST / 2
         MOVE 0.1 TO WS-SPREAD(1) WS-SPREAD(3)
         MOVE 0 TO WS-SPREAD(2)
         MOVE 0.2 TO WS-SPREAD(4) WS-SPREAD(5) WS-SPREAD(6)
         CALL "PARTICLE-SEND" USING L-DIM WS-TYPE WS-NO-OPTION WS-OVERRIDE WS-ALWAYS L-X L-Y L-Z
             WS-SPREAD-TABLE WS-COUNT WS-RANDOM
     END-IF
     GOBACK.
 END PROGRAM PARTICLE-DAMAGE-INDICATOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PARTICLE-HIT-PLAYER.
*> USING player row, health lost: the damage indicator of a player damaged by a player, at the player's x,
*> y + half the operator's height, z in its dimension.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-Y                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-LOST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-LOST.
     COMPUTE WS-Y = PL-Y(L-ROW) + ET-HEIGHT-MILLI(CR-OPERATOR + 1) / 2000
     CALL "PARTICLE-DAMAGE-INDICATOR" USING PL-DIM(L-ROW) L-LOST PL-X(L-ROW) WS-Y PL-Z(L-ROW)
     GOBACK.
 END PROGRAM PARTICLE-HIT-PLAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PARTICLE-HIT-MOB.
*> USING mob tracker row, health lost: the damage indicator of a mob damaged by a player, at its x,
*> y + half its height, z in its dimension.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-Y                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-LOST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-LOST.
     COMPUTE WS-Y = EN-Y(L-ROW) + ET-HEIGHT-MILLI(EN-TYPE(L-ROW) + 1) / 2000
     CALL "PARTICLE-DAMAGE-INDICATOR" USING EN-DIM(L-ROW) L-LOST EN-X(L-ROW) WS-Y EN-Z(L-ROW)
     GOBACK.
 END PROGRAM PARTICLE-HIT-MOB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PARTICLE-LANDING.
*> USING dimension row, x, y, z (the player's feet), fall power (floor(D + 1e-6 - 3), above 0): block
*> particles of the block state under the feet (none over air), count (int)(150 * min(0.2f + power / 15,
*> 2.5)) (0.2f widened is 0.20000000298023224), no spread, speed 0.15 (42-6 section 8.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG VALUE 1.
 01 WS-OVERRIDE            BINARY-LONG VALUE 0.
 01 WS-ALWAYS              BINARY-LONG VALUE 0.
 01 WS-RANDOM              BINARY-LONG VALUE 0.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-AMOUNT              FLOAT-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SPREAD-TABLE.
    05 WS-SPREAD           FLOAT-SHORT OCCURS 6 TIMES.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-POWER                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-POWER.
     COMPUTE WS-BX = FUNCTION INTEGER(L-X)
     COMPUTE WS-BY = FUNCTION INTEGER(L-Y - 0.001)
     COMPUTE WS-BZ = FUNCTION INTEGER(L-Z)
     CALL "WORLD-GET-BLOCK" USING L-DIM WS-BX WS-BY WS-BZ WS-STATE
     IF WS-STATE NOT = 0
         COMPUTE WS-AMOUNT = FUNCTION MIN(0.20000000298023224 + L-POWER / 15, 2.5)
         COMPUTE WS-COUNT = FUNCTION INTEGER-PART(150 * WS-AMOUNT)
         MOVE 0 TO WS-SPREAD(1) WS-SPREAD(2) WS-SPREAD(3)
         MOVE 0.15 TO WS-SPREAD(4) WS-SPREAD(5) WS-SPREAD(6)
         CALL "PARTICLE-SEND" USING L-DIM WS-TYPE WS-STATE WS-OVERRIDE WS-ALWAYS L-X L-Y L-Z
             WS-SPREAD-TABLE WS-COUNT WS-RANDOM
     END-IF
     GOBACK.
 END PROGRAM PARTICLE-LANDING.
