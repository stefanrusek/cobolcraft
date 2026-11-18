*> Aquatic mobs of document 21 section 4 (lane 002-lane-mobsfull-h10; with doc 44 part 7): the water animals cod, salmon, pufferfish, tropical fish (4.1 to 4.4), squid
*> and glow squid (4.5) and dolphin (4.6). Their rows are core/copy/MOB21ROWS.cpy.
*> Entry points:
*>   MS6-ROW-CAT USING row, category out: the spawn category of a table row (18 section 1.2): kind 0 creature 2, 1 monster 1, 2 water creature 6, 3 water ambient 7, 4 underground 5, 5 axolotls 4, 6 aquatic monster 1.
*>   STDMOB-AQUATIC-STEP USING tracker row, table row: one tick of a water animal that is alive and in a ready chunk (STDMOB-STEP calls it for SM-KIND 2 to 4).
*>   STDMOB-AQUATIC-FINALIZE USING xoro state, tracker row, table row: the spawn variant of a salmon (4.2: small 30, medium 50, large 15) and of a tropical fish (4.4).
*>   AQUA-STATE-SEND USING tracker row, value: Set Entity Data index 17 VarInt value to the viewers (the pufferfish's puff state).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-ROW-CAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STDMOBS.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-CAT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-CAT.
     EVALUATE SM-KIND(L-ROW)
         WHEN 0
             MOVE 2 TO L-CAT
         WHEN 1
             MOVE 1 TO L-CAT
         WHEN 2
             MOVE 6 TO L-CAT
         WHEN 3
             MOVE 7 TO L-CAT
         WHEN 5
             MOVE 4 TO L-CAT
         WHEN 6
             MOVE 1 TO L-CAT
         WHEN OTHER
             MOVE 5 TO L-CAT
     END-EVALUATE
     GOBACK.
 END PROGRAM MS6-ROW-CAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MS6-WATER-RULE.
*> USING dim row, species row, x, y, z (BINARY-LONG feet cell), ok out (BINARY-LONG): the spawn predicates of the water animals (21 section 3.2). SM-SPAWN 7 and 8 (surface water
*> animal; the tropical fish's any-height biome tag is open): y in [sea - 13, sea], water below and a water block above. SM-SPAWN 9 (glow squid): y at most sea - 33, raw
*> brightness (sky or block light) 0 and water at the position. The sea level is that of the dimension (DM-SEA-LEVEL).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DIMENSIONS.
 COPY STDMOBS.
 01 WS-Y                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BAND-LOW            BINARY-LONG.
 01 WS-BAND-HIGH           BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-ROW L-X L-Y L-Z L-OK.
     MOVE 0 TO L-OK
     CALL "MS6-BLOCK-KIND" USING L-DIM L-X L-Y L-Z WS-KIND
     IF SM-SPAWN(L-ROW) = 9
         CALL "STDMOB-LIGHTS" USING L-DIM L-X L-Y L-Z WS-SKY WS-BLOCK
         IF L-Y <= DM-SEA-LEVEL(L-DIM) - 33 AND WS-SKY = 0 AND WS-BLOCK = 0 AND WS-KIND = 2
             MOVE 1 TO L-OK
         END-IF
         GOBACK
     END-IF
     COMPUTE WS-Y = L-Y - 1
     CALL "MS6-BLOCK-KIND" USING L-DIM L-X WS-Y L-Z WS-BELOW
     COMPUTE WS-Y = L-Y + 1
     CALL "MS6-BLOCK-KIND" USING L-DIM L-X WS-Y L-Z WS-ABOVE
     MOVE 13 TO WS-BAND-LOW
     MOVE 0 TO WS-BAND-HIGH
     IF SM-SPAWN(L-ROW) = 15
*>       The nautilus: y from sea level - 25 to sea level - 5 (21 section 3.2).
         MOVE 25 TO WS-BAND-LOW
         MOVE 5 TO WS-BAND-HIGH
     END-IF
     IF L-Y >= DM-SEA-LEVEL(L-DIM) - WS-BAND-LOW AND L-Y <= DM-SEA-LEVEL(L-DIM) - WS-BAND-HIGH AND WS-BELOW = 2 AND WS-ABOVE = 2
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM MS6-WATER-RULE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQUA-RAND.
*> USING tracker row, salt (BINARY-LONG), r out (FLOAT-LONG): a draw in [0, 1) from the hash of the entity id, the time and the salt (core/src/rng.cob).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-H                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SALT                 BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-SALT L-R.
     MOVE EN-ID(L-ROW) TO WS-ARG(1)
     MOVE CW-TIME TO WS-ARG(2)
     MOVE L-SALT TO WS-ARG(3)
     CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-H
     COMPUTE L-R = FUNCTION MOD(WS-H, 1000000) / 1000000
     GOBACK.
 END PROGRAM AQUA-RAND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQUA-MOVE.
*> USING tracker row, yaw (FLOAT-SHORT): moves the mob by its velocity (EN-VX, EN-VY, EN-VZ) one axis at a time; an axis whose move would put the box into a block loses its
*> velocity. A downward move that is blocked puts the mob on the ground (y on top of the block). The viewers are sent the movement when the position or the yaw changed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-NEW                 FLOAT-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-GROUND              BINARY-LONG.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-YAW                  FLOAT-SHORT.
 PROCEDURE DIVISION USING L-ROW L-YAW.
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     MOVE 0 TO WS-GROUND
     COMPUTE WS-NEW = WS-X + EN-VX(L-ROW)
     CALL "ENTITY-BOX-HITS" USING EN-DIM(L-ROW) EN-TYPE(L-ROW) WS-NEW WS-Y WS-Z WS-HIT WS-TOP
     IF WS-HIT = 0
         MOVE WS-NEW TO WS-X
     ELSE
         MOVE 0 TO EN-VX(L-ROW)
     END-IF
     COMPUTE WS-NEW = WS-Z + EN-VZ(L-ROW)
     CALL "ENTITY-BOX-HITS" USING EN-DIM(L-ROW) EN-TYPE(L-ROW) WS-X WS-Y WS-NEW WS-HIT WS-TOP
     IF WS-HIT = 0
         MOVE WS-NEW TO WS-Z
     ELSE
         MOVE 0 TO EN-VZ(L-ROW)
     END-IF
     COMPUTE WS-NEW = WS-Y + EN-VY(L-ROW)
     CALL "ENTITY-BOX-HITS" USING EN-DIM(L-ROW) EN-TYPE(L-ROW) WS-X WS-NEW WS-Z WS-HIT WS-TOP
     EVALUATE TRUE
         WHEN WS-HIT = 0
             MOVE WS-NEW TO WS-Y
         WHEN EN-VY(L-ROW) <= 0
             COMPUTE WS-Y = WS-TOP + 1
             MOVE 1 TO WS-GROUND
             MOVE 0 TO EN-VY(L-ROW)
         WHEN OTHER
             MOVE 0 TO EN-VY(L-ROW)
     END-EVALUATE
     IF WS-X NOT = EN-X(L-ROW) OR WS-Y NOT = EN-Y(L-ROW) OR WS-Z NOT = EN-Z(L-ROW) OR L-YAW NOT = EN-YAW(L-ROW)
         CALL "ENTITY-MOVE" USING L-ROW WS-X WS-Y WS-Z L-YAW WS-PITCH WS-GROUND
     END-IF
     MOVE WS-GROUND TO EN-ON-GROUND(L-ROW)
     GOBACK.
 END PROGRAM AQUA-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQUA-STATE-SEND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-VALUE.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(L-ROW)
     INITIALIZE MD-METADATA-ENTRY
     MOVE 17 TO MD-MD-INDEX
     MOVE MD-MDS-INT TO MD-MD-SERIALIZER
     MOVE L-VALUE TO MD-MD-INT
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     MOVE MD-MD-END TO MD-MD-INDEX
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM AQUA-STATE-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQUA-SWIM.
*> USING tracker row, table row: the swimming of a fish or a dolphin that is in water (4.1: RandomSwimmingGoal interval 40 and FishMoveControl; PanicGoal). A panicking mob (EN-FLEE)
*> swims away from its attacker at the panic speed. Otherwise a mob without a destination (EN-COOLDOWN 0) picks one with probability 1/40 a tick: a cell up to 10 blocks away
*> horizontally and 7 vertically, which must be water; it swims there for at most 200 ticks (EN-COOLDOWN) or until it is within a block. The move speed lerps by 0.125 toward the
*> row's speed (SM-WALK-MILLI or SM-PANIC-MILLI / 1000: attribute x modifier); each tick the velocity gains speed x 0.01 (dolphin 0.02) along the heading and speed x dy / distance x
*> 0.1 vertically; with nowhere to go the speed is 0. The drag of 0.9 is applied by the caller.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-SALT                BINARY-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-GO                  BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-TARGET              FLOAT-LONG.
 01 WS-FACTOR              FLOAT-LONG.
 01 WS-RADIANS             FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-P                   BINARY-LONG.
 01 WS-CELL-X              BINARY-LONG.
 01 WS-CELL-Y              BINARY-LONG.
 01 WS-CELL-Z              BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-ODDS                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M.
     MOVE 0 TO WS-GO WS-DX WS-DY WS-DZ
     MOVE 0.025 TO WS-ODDS
     IF SM-KIND(L-M) = 6
*>       RandomStrollGoal(1, 80) of the guardians (21 section 4.8): 1 / 80 a tick.
         MOVE 0.0125 TO WS-ODDS
     END-IF
     MOVE EN-YAW(L-ROW) TO WS-YAW
     COMPUTE WS-TARGET = SM-WALK-MILLI(L-M) / 1000
     IF EN-FLEE(L-ROW) > 0
         SUBTRACT 1 FROM EN-FLEE(L-ROW)
         MOVE EN-FLEE-PLAYER(L-ROW) TO WS-P
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ID(WS-P) = EN-FLEE-ID(L-ROW) AND PL-DIM(WS-P) = EN-DIM(L-ROW)
             MOVE PL-X(WS-P) TO EN-FLEE-X(L-ROW)
             MOVE PL-Z(WS-P) TO EN-FLEE-Z(L-ROW)
         END-IF
         COMPUTE WS-DX = EN-X(L-ROW) - EN-FLEE-X(L-ROW)
         COMPUTE WS-DZ = EN-Z(L-ROW) - EN-FLEE-Z(L-ROW)
         COMPUTE WS-TARGET = SM-PANIC-MILLI(L-M) / 1000
         MOVE 0 TO EN-COOLDOWN(L-ROW)
         MOVE 1 TO WS-GO
     ELSE
         IF EN-COOLDOWN(L-ROW) = 0
             MOVE 1 TO WS-SALT
             CALL "AQUA-RAND" USING L-ROW WS-SALT WS-R
             IF WS-R < WS-ODDS
                 COMPUTE WS-Q = WS-R * 1000000
                 COMPUTE EN-DEST-X(L-ROW) = FUNCTION INTEGER(EN-X(L-ROW)) + FUNCTION MOD(WS-Q, 21) - 10
                 COMPUTE WS-Q = WS-Q / 21
                 COMPUTE EN-DEST-Z(L-ROW) = FUNCTION INTEGER(EN-Z(L-ROW)) + FUNCTION MOD(WS-Q, 21) - 10
                 COMPUTE WS-Q = WS-Q / 21
                 COMPUTE EN-DEST-Y(L-ROW) = FUNCTION INTEGER(EN-Y(L-ROW)) + FUNCTION MOD(WS-Q, 15) - 7
                 CALL "MS6-BLOCK-KIND" USING EN-DIM(L-ROW) EN-DEST-X(L-ROW) EN-DEST-Y(L-ROW) EN-DEST-Z(L-ROW) WS-KIND
                 IF WS-KIND = 2
                     MOVE SM-STROLL-TICKS TO EN-COOLDOWN(L-ROW)
                 END-IF
             END-IF
         END-IF
         IF EN-COOLDOWN(L-ROW) > 0
             SUBTRACT 1 FROM EN-COOLDOWN(L-ROW)
             COMPUTE WS-DX = EN-DEST-X(L-ROW) + 0.5 - EN-X(L-ROW)
             COMPUTE WS-DY = EN-DEST-Y(L-ROW) + 0.5 - EN-Y(L-ROW)
             COMPUTE WS-DZ = EN-DEST-Z(L-ROW) + 0.5 - EN-Z(L-ROW)
             COMPUTE WS-DIST = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
             IF WS-DIST < 1
                 MOVE 0 TO EN-COOLDOWN(L-ROW)
             ELSE
                 MOVE 1 TO WS-GO
             END-IF
         END-IF
     END-IF
     IF WS-GO = 0
         MOVE 0 TO EN-SWIM-SPEED(L-ROW)
         GOBACK
     END-IF
     COMPUTE EN-SWIM-SPEED(L-ROW) = EN-SWIM-SPEED(L-ROW) + (WS-TARGET - EN-SWIM-SPEED(L-ROW)) * 0.125
     CALL "MOB-YAW-TOWARD" USING WS-DX WS-DZ WS-YAW
     COMPUTE WS-DIST = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
     MOVE 0.01 TO WS-FACTOR
     IF SM-KEY(L-M) = "dolphin"
         MOVE 0.02 TO WS-FACTOR
     END-IF
     IF SM-KIND(L-M) = 6
         MOVE 0.1 TO WS-FACTOR
     END-IF
     COMPUTE WS-RADIANS = WS-YAW * FUNCTION PI / 180
     COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) - FUNCTION SIN(WS-RADIANS) * EN-SWIM-SPEED(L-ROW) * WS-FACTOR
     COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + FUNCTION COS(WS-RADIANS) * EN-SWIM-SPEED(L-ROW) * WS-FACTOR
     COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + EN-SWIM-SPEED(L-ROW) * (WS-DY / WS-DIST) * 0.1
     MOVE WS-YAW TO EN-YAW(L-ROW)
     GOBACK.
 END PROGRAM AQUA-SWIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQUA-SQUID.
*> USING tracker row, wet (1 when the squid is in water): 4.5. The movement vector m (EN-SQ-MX, -MY, -MZ): with no player within 32 blocks for over 100 ticks (noActionTime) it is 0;
*> otherwise with probability 1/50 a tick, out of water, or when it has none, a random heading gives (cos a x 0.2, -0.1 + nextFloat x 0.2, sin a x 0.2). A squid with an attacker
*> (EN-FLEE) within 10 blocks, in water, flees: the push is self - attacker; the cell at self + push must be water or air; the vector is scaled to 3 (less (d - 5) / 10 beyond 5 blocks,
*> never below 0), loses its Y part when that cell is air, and m is that / 20. The tentacle phase advances by its speed and wraps at 2 pi (then 1/10 a new speed 0.2 / (nextFloat + 1));
*> in the first half, past 0.75 of it the velocity is m, in the second half it is multiplied by 0.9. Out of water the horizontal velocity is 0 and gravity 0.08 pulls (drag 0.98).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                BINARY-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-MAG                 FLOAT-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-SCALE               FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-TWO-PI              FLOAT-LONG VALUE 6.283185307179586.
 01 WS-PI                  FLOAT-LONG VALUE 3.141592653589793.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-WET                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-WET.
     MOVE EN-YAW(L-ROW) TO WS-YAW
     CALL "MS6-NEAREST" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-D2
     IF WS-D2 < 1024
         MOVE 0 TO EN-IDLE(L-ROW)
     ELSE
         ADD 1 TO EN-IDLE(L-ROW)
     END-IF
     IF EN-SQ-TSPEED(L-ROW) = 0
         MOVE 2 TO WS-SALT
         CALL "AQUA-RAND" USING L-ROW WS-SALT WS-R
         COMPUTE EN-SQ-TSPEED(L-ROW) = 0.2 / (WS-R + 1)
     END-IF
     COMPUTE WS-MAG = EN-SQ-MX(L-ROW) * EN-SQ-MX(L-ROW) + EN-SQ-MY(L-ROW) * EN-SQ-MY(L-ROW) + EN-SQ-MZ(L-ROW) * EN-SQ-MZ(L-ROW)
     IF EN-IDLE(L-ROW) > 100
         MOVE 0 TO EN-SQ-MX(L-ROW) EN-SQ-MY(L-ROW) EN-SQ-MZ(L-ROW)
     ELSE
         MOVE 3 TO WS-SALT
         CALL "AQUA-RAND" USING L-ROW WS-SALT WS-R
         IF WS-R < 0.02 OR L-WET = 0 OR WS-MAG <= 0.00001
             MOVE 4 TO WS-SALT
             CALL "AQUA-RAND" USING L-ROW WS-SALT WS-R
             COMPUTE WS-ANGLE = WS-R * WS-TWO-PI
             COMPUTE EN-SQ-MX(L-ROW) = FUNCTION COS(WS-ANGLE) * 0.2
             COMPUTE EN-SQ-MZ(L-ROW) = FUNCTION SIN(WS-ANGLE) * 0.2
             MOVE 5 TO WS-SALT
             CALL "AQUA-RAND" USING L-ROW WS-SALT WS-R
             COMPUTE EN-SQ-MY(L-ROW) = -0.1 + WS-R * 0.2
         END-IF
     END-IF
     IF L-WET = 1 AND EN-FLEE(L-ROW) > 0
         SUBTRACT 1 FROM EN-FLEE(L-ROW)
         MOVE EN-FLEE-PLAYER(L-ROW) TO WS-P
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ID(WS-P) = EN-FLEE-ID(L-ROW) AND PL-DIM(WS-P) = EN-DIM(L-ROW)
             COMPUTE WS-DX = EN-X(L-ROW) - PL-X(WS-P)
             COMPUTE WS-DY = EN-Y(L-ROW) - PL-Y(WS-P)
             COMPUTE WS-DZ = EN-Z(L-ROW) - PL-Z(WS-P)
             COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
             IF WS-LEN > 0 AND WS-LEN < 10
                 COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW) + WS-DX)
                 COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW) + WS-DY)
                 COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW) + WS-DZ)
                 CALL "MS6-BLOCK-KIND" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-KIND
                 IF WS-KIND = 0 OR WS-KIND = 2
                     MOVE 3 TO WS-SCALE
                     IF WS-LEN > 5
                         COMPUTE WS-SCALE = FUNCTION MAX(0, 3 - (WS-LEN - 5) / 10)
                     END-IF
                     COMPUTE EN-SQ-MX(L-ROW) = WS-DX / WS-LEN * WS-SCALE / 20
                     COMPUTE EN-SQ-MY(L-ROW) = WS-DY / WS-LEN * WS-SCALE / 20
                     COMPUTE EN-SQ-MZ(L-ROW) = WS-DZ / WS-LEN * WS-SCALE / 20
                     IF WS-KIND = 0
                         MOVE 0 TO EN-SQ-MY(L-ROW)
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-IF
     COMPUTE EN-SQ-PHASE(L-ROW) = EN-SQ-PHASE(L-ROW) + EN-SQ-TSPEED(L-ROW)
     IF EN-SQ-PHASE(L-ROW) > WS-TWO-PI
         COMPUTE EN-SQ-PHASE(L-ROW) = EN-SQ-PHASE(L-ROW) - WS-TWO-PI
         MOVE 6 TO WS-SALT
         CALL "AQUA-RAND" USING L-ROW WS-SALT WS-R
         IF WS-R < 0.1
             MOVE 7 TO WS-SALT
             CALL "AQUA-RAND" USING L-ROW WS-SALT WS-R
             COMPUTE EN-SQ-TSPEED(L-ROW) = 0.2 / (WS-R + 1)
         END-IF
     END-IF
     IF L-WET = 1
         IF EN-SQ-PHASE(L-ROW) < WS-PI
             IF EN-SQ-PHASE(L-ROW) / WS-PI > 0.75
                 MOVE EN-SQ-MX(L-ROW) TO EN-VX(L-ROW)
                 MOVE EN-SQ-MY(L-ROW) TO EN-VY(L-ROW)
                 MOVE EN-SQ-MZ(L-ROW) TO EN-VZ(L-ROW)
             END-IF
         ELSE
             COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * 0.9
             COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * 0.9
             COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * 0.9
         END-IF
     ELSE
         MOVE 0 TO EN-VX(L-ROW) EN-VZ(L-ROW)
         COMPUTE EN-VY(L-ROW) = (EN-VY(L-ROW) - 0.08) * 0.98
     END-IF
     IF EN-VX(L-ROW) NOT = 0 OR EN-VZ(L-ROW) NOT = 0
         CALL "MOB-YAW-TOWARD" USING EN-VX(L-ROW) EN-VZ(L-ROW) WS-YAW
         MOVE WS-YAW TO EN-YAW(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM AQUA-SQUID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQUA-PUFFER.
*> USING tracker row: 4.3 for a player (the scary-mob test of the mobs is open). A survival or adventure player within 2 blocks of its box starts the puff goal (inflateCounter 1, deflateTimer 0);
*> with none the counter returns to 0. While the counter is above 0: state 0 becomes 1, a counter above 40 makes state 1 into 2, and the counter rises; otherwise a state above 0
*> deflates: deflateTimer above 60 turns 2 into 1, above 100 turns 1 into 0, and the timer rises. The state is EN-VARIANT; a change goes to the viewers (AQUA-STATE-SEND). With a
*> state above 0 a player within 0.3 blocks of its box is stung: 1 + state damage (a mob hit) and, when that took health, Poison for 60 x state ticks.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-SCARY               BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-HEALTH              FLOAT-SHORT.
 01 WS-POISON              BINARY-LONG VALUE 18.
 01 WS-AMPLIFIER           BINARY-LONG VALUE 0.
 01 WS-DURATION            BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 6.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 0 TO WS-SCARY
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = EN-DIM(L-ROW)
                 AND (PL-MODE(WS-P) = 0 OR PL-MODE(WS-P) = 2)
             COMPUTE WS-DX = FUNCTION ABS(PL-X(WS-P) - EN-X(L-ROW))
             COMPUTE WS-DZ = FUNCTION ABS(PL-Z(WS-P) - EN-Z(L-ROW))
             COMPUTE WS-DY = PL-Y(WS-P) - EN-Y(L-ROW)
             IF WS-DX < 2.65 AND WS-DZ < 2.65 AND WS-DY > -3.8 AND WS-DY < 2.7
                 MOVE 1 TO WS-SCARY
             END-IF
         END-IF
     END-PERFORM
     IF WS-SCARY = 1 AND EN-INFLATE(L-ROW) = 0
         MOVE 1 TO EN-INFLATE(L-ROW)
         MOVE 0 TO EN-DEFLATE(L-ROW)
     END-IF
     IF WS-SCARY = 0 AND EN-INFLATE(L-ROW) > 0
         MOVE 0 TO EN-INFLATE(L-ROW)
     END-IF
     MOVE EN-VARIANT(L-ROW) TO WS-STATE WS-OLD
     IF EN-INFLATE(L-ROW) > 0
         IF WS-STATE = 0
             MOVE 1 TO WS-STATE
         ELSE
             IF EN-INFLATE(L-ROW) > 40 AND WS-STATE = 1
                 MOVE 2 TO WS-STATE
             END-IF
         END-IF
         ADD 1 TO EN-INFLATE(L-ROW)
     ELSE
         IF WS-STATE NOT = 0
             IF EN-DEFLATE(L-ROW) > 60 AND WS-STATE = 2
                 MOVE 1 TO WS-STATE
             ELSE
                 IF EN-DEFLATE(L-ROW) > 100 AND WS-STATE = 1
                     MOVE 0 TO WS-STATE
                 END-IF
             END-IF
             ADD 1 TO EN-DEFLATE(L-ROW)
         END-IF
     END-IF
     IF WS-STATE NOT = WS-OLD
         MOVE WS-STATE TO EN-VARIANT(L-ROW)
         CALL "AQUA-STATE-SEND" USING L-ROW WS-STATE
     END-IF
     IF WS-STATE > 0
         COMPUTE WS-DAMAGE = 1 + WS-STATE
         PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
             IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = EN-DIM(L-ROW)
                     AND (PL-MODE(WS-P) = 0 OR PL-MODE(WS-P) = 2)
                 COMPUTE WS-DX = FUNCTION ABS(PL-X(WS-P) - EN-X(L-ROW))
                 COMPUTE WS-DZ = FUNCTION ABS(PL-Z(WS-P) - EN-Z(L-ROW))
                 COMPUTE WS-DY = PL-Y(WS-P) - EN-Y(L-ROW)
                 IF WS-DX < 0.95 AND WS-DZ < 0.95 AND WS-DY > -2.1 AND WS-DY < 1.0
                     MOVE PL-HEALTH(WS-P) TO WS-HEALTH
                     CALL "HEALTH-MOB-HIT" USING WS-P WS-DAMAGE L-ROW
                     IF PL-HEALTH(WS-P) < WS-HEALTH
                         COMPUTE WS-DURATION = 60 * WS-STATE
                         CALL "EFFECT-ADD" USING WS-P WS-POISON WS-AMPLIFIER WS-DURATION WS-FLAGS
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM AQUA-PUFFER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-AQUATIC-STEP.
*> USING tracker row, table row: one tick of a water animal (a row of SM-KIND 2 to 4) that is alive in a ready chunk. Air (44 part 7 section 2.6): a fish or squid out of water counts
*> EN-DRY; at 320 (air 300, then -20) the air is reset to 0 (EN-DRY 300) and it takes 2 drown damage; in water EN-DRY is 0. A dolphin dries out instead (moistness 2400): at 2400
*> dry ticks it takes 1 damage a tick, and on the ground and dry it hops (velocity + (nextFloat x 2 - 1) x 0.2, 0.5, ...; 4.2). A fish on the ground out of water flops on every tick
*> (velocity + ((nextFloat x 2 - 1) x 0.05, 0.4, ...); 44-7 section 4.1). Then the behaviour (AQUA-SQUID, AQUA-SWIM, AQUA-PUFFER), gravity out of water (0.08), the move (AQUA-MOVE)
*> and the drag (0.9 in water; out of water 0.98 vertical, 0.546 on the ground and 0.91 in the air horizontal). A glow squid hit goes dark for 100 ticks (EN-DARK counts down).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY RULES.
 01 WS-WET                 BINARY-LONG.
 01 WS-SALT                BINARY-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG VALUE 8.
 01 WS-NO-ATTACKER         BINARY-LONG VALUE 0.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-DRAG                FLOAT-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-RESET               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M.
     CALL "FLUID-TOUCHES-WATER" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-WET
     MOVE EN-YAW(L-ROW) TO WS-YAW
*>   Air: a fish or squid 300 and 20 more (drown), the axolotl 6000 and 20 (dry out, 44 part 7 section 8.4), the guardian none (it breathes under water and flops on land, 21 section 4.8).
     MOVE 320 TO WS-LIMIT
     MOVE 300 TO WS-RESET
     IF SM-KIND(L-M) = 5
         MOVE 6020 TO WS-LIMIT
         MOVE 6000 TO WS-RESET
     END-IF
     IF SM-KIND(L-M) = 6
         MOVE 0 TO WS-LIMIT
     END-IF
     IF WS-WET = 1
         MOVE 0 TO EN-DRY(L-ROW)
     ELSE
         ADD 1 TO EN-DRY(L-ROW)
         IF SM-KEY(L-M) = "dolphin"
             IF EN-DRY(L-ROW) >= 2400
                 MOVE 1 TO WS-AMOUNT
                 CALL "HEALTH-MOB-DAMAGE" USING L-ROW WS-AMOUNT WS-CAUSE WS-NO-ATTACKER
             END-IF
             IF EN-ON-GROUND(L-ROW) = 1
                 MOVE 8 TO WS-SALT
                 CALL "AQUA-RAND" USING L-ROW WS-SALT WS-R
                 COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) + (WS-R * 2 - 1) * 0.2
                 MOVE 9 TO WS-SALT
                 CALL "AQUA-RAND" USING L-ROW WS-SALT WS-R
                 COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + (WS-R * 2 - 1) * 0.2
                 MOVE 10 TO WS-SALT
                 CALL "AQUA-RAND" USING L-ROW WS-SALT WS-R
                 COMPUTE WS-YAW = WS-R * 360
                 COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + 0.5
                 MOVE 0 TO EN-ON-GROUND(L-ROW)
             END-IF
         ELSE
             IF WS-LIMIT > 0 AND EN-DRY(L-ROW) >= WS-LIMIT
                 MOVE WS-RESET TO EN-DRY(L-ROW)
                 MOVE 2 TO WS-AMOUNT
                 CALL "HEALTH-MOB-DAMAGE" USING L-ROW WS-AMOUNT WS-CAUSE WS-NO-ATTACKER
             END-IF
         END-IF
         IF EN-HEALTH(L-ROW) = 0
             GOBACK
         END-IF
         IF SM-KIND(L-M) = 6 AND EN-ON-GROUND(L-ROW) = 1
*>           The guardian out of water hops: velocity + ((nextFloat x 2 - 1) x 0.4, 0.5, (nextFloat x 2 - 1) x 0.4), a random yaw (21 section 4.8).
             MOVE 13 TO WS-SALT
             CALL "AQUA-RAND" USING L-ROW WS-SALT WS-R
             COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) + (WS-R * 2 - 1) * 0.4
             MOVE 14 TO WS-SALT
             CALL "AQUA-RAND" USING L-ROW WS-SALT WS-R
             COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + (WS-R * 2 - 1) * 0.4
             MOVE 15 TO WS-SALT
             CALL "AQUA-RAND" USING L-ROW WS-SALT WS-R
             COMPUTE WS-YAW = WS-R * 360
             COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + 0.5
             MOVE 0 TO EN-ON-GROUND(L-ROW)
         END-IF
         IF SM-KIND(L-M) = 3 AND EN-ON-GROUND(L-ROW) = 1
             MOVE 11 TO WS-SALT
             CALL "AQUA-RAND" USING L-ROW WS-SALT WS-R
             COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) + (WS-R * 2 - 1) * 0.05
             MOVE 12 TO WS-SALT
             CALL "AQUA-RAND" USING L-ROW WS-SALT WS-R
             COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + (WS-R * 2 - 1) * 0.05
             COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + 0.4
             MOVE 0 TO EN-ON-GROUND(L-ROW)
         END-IF
     END-IF
     IF SM-KEY(L-M) = "squid" OR "glow_squid"
         CALL "AQUA-SQUID" USING L-ROW WS-WET
     ELSE
         EVALUATE TRUE
             WHEN SM-KIND(L-M) = 5
                 CALL "AXOLOTL-TICK" USING L-ROW L-M WS-WET
             WHEN SM-KIND(L-M) = 6
                 CALL "GUARDIAN-TICK" USING L-ROW L-M WS-WET
             WHEN WS-WET = 1
                 CALL "AQUA-SWIM" USING L-ROW L-M
         END-EVALUATE
     END-IF
     IF SM-KEY(L-M) = "pufferfish"
         CALL "AQUA-PUFFER" USING L-ROW
     END-IF
     IF SM-KEY(L-M) = "glow_squid"
         IF EN-DARK(L-ROW) > 0
             SUBTRACT 1 FROM EN-DARK(L-ROW)
         END-IF
         IF EN-HURT(L-ROW) >= RULE-HURT-WINDOW - 1 AND EN-DARK(L-ROW) = 0
             MOVE 100 TO EN-DARK(L-ROW)
         END-IF
     END-IF
     IF WS-WET = 0 AND SM-KEY(L-M) NOT = "squid" AND SM-KEY(L-M) NOT = "glow_squid"
         COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) - 0.08
     END-IF
     CALL "AQUA-MOVE" USING L-ROW WS-YAW
     IF SM-KEY(L-M) NOT = "squid" AND SM-KEY(L-M) NOT = "glow_squid"
         IF WS-WET = 1
             MOVE 0.9 TO WS-DRAG
             COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * 0.9
         ELSE
             COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * 0.98
             MOVE 0.91 TO WS-DRAG
             IF EN-ON-GROUND(L-ROW) = 1
                 MOVE 0.546 TO WS-DRAG
             END-IF
         END-IF
         COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * WS-DRAG
         COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * WS-DRAG
     END-IF
     GOBACK.
 END PROGRAM STDMOB-AQUATIC-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-AQUATIC-FINALIZE.
*> USING xoro state, tracker row, table row: finalizeSpawn of a salmon (4.2: a draw of 95 gives small below 30, medium below 80, else large; EN-VARIANT is 1 + the variant id) and of a
*> tropical fish (4.4: with nextFloat below 0.9 one of the 22 common variants, else a random pattern of 12 and two random colours; EN-VARIANT is 1 + the packed variant, the pattern
*> id | base colour x 65536 | pattern colour x 16777216). The school that shares a variant is not modelled (open).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-COMMON-DATA.
    05 FILLER              BINARY-LONG VALUE 257.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 11.
    05 FILLER              BINARY-LONG VALUE 1281.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 256.
    05 FILLER              BINARY-LONG VALUE 11.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1280.
    05 FILLER              BINARY-LONG VALUE 6.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE 769.
    05 FILLER              BINARY-LONG VALUE 10.
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              BINARY-LONG VALUE 1281.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 14.
    05 FILLER              BINARY-LONG VALUE 1280.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              BINARY-LONG VALUE 513.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 1281.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 768.
    05 FILLER              BINARY-LONG VALUE 9.
    05 FILLER              BINARY-LONG VALUE 6.
    05 FILLER              BINARY-LONG VALUE 1024.
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE 3.
    05 FILLER              BINARY-LONG VALUE 1025.
    05 FILLER              BINARY-LONG VALUE 14.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 512.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 14.
    05 FILLER              BINARY-LONG VALUE 769.
    05 FILLER              BINARY-LONG VALUE 14.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 14.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 256.
    05 FILLER              BINARY-LONG VALUE 7.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 768.
    05 FILLER              BINARY-LONG VALUE 9.
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              BINARY-LONG VALUE 4.
 01 WS-COMMON REDEFINES WS-COMMON-DATA.
    05 WS-C OCCURS 22 TIMES.
       10 WS-C-PATTERN        BINARY-LONG.
       10 WS-C-BASE           BINARY-LONG.
       10 WS-C-COLOUR         BINARY-LONG.
 01 WS-PATTERN-DATA.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 256.
    05 FILLER              BINARY-LONG VALUE 512.
    05 FILLER              BINARY-LONG VALUE 768.
    05 FILLER              BINARY-LONG VALUE 1024.
    05 FILLER              BINARY-LONG VALUE 1280.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 257.
    05 FILLER              BINARY-LONG VALUE 513.
    05 FILLER              BINARY-LONG VALUE 769.
    05 FILLER              BINARY-LONG VALUE 1025.
    05 FILLER              BINARY-LONG VALUE 1281.
 01 WS-PATTERNS REDEFINES WS-PATTERN-DATA.
    05 WS-PATTERN             BINARY-LONG OCCURS 12 TIMES.
 01 WS-D                   FLOAT-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-COLOUR              BINARY-LONG.
 01 WS-22                  BINARY-LONG VALUE 22.
 01 WS-12                  BINARY-LONG VALUE 12.
 01 WS-16                  BINARY-LONG VALUE 16.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-M.
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
     IF SM-KEY(L-M) = "salmon"
         COMPUTE WS-N = WS-D * 95
         EVALUATE TRUE
             WHEN WS-N < 30
                 MOVE 1 TO EN-VARIANT(L-ROW)
             WHEN WS-N < 80
                 MOVE 2 TO EN-VARIANT(L-ROW)
             WHEN OTHER
                 MOVE 3 TO EN-VARIANT(L-ROW)
         END-EVALUATE
         GOBACK
     END-IF
     IF WS-D < 0.9
         CALL "XORO-NEXT-INT" USING L-STATE WS-22 WS-N
         ADD 1 TO WS-N
         MOVE WS-C-BASE(WS-N) TO WS-BASE
         MOVE WS-C-COLOUR(WS-N) TO WS-COLOUR
         COMPUTE EN-VARIANT(L-ROW) = 1 + WS-C-PATTERN(WS-N) + WS-BASE * 65536 + WS-COLOUR * 16777216
     ELSE
         CALL "XORO-NEXT-INT" USING L-STATE WS-12 WS-N
         ADD 1 TO WS-N
         CALL "XORO-NEXT-INT" USING L-STATE WS-16 WS-BASE
         CALL "XORO-NEXT-INT" USING L-STATE WS-16 WS-COLOUR
         COMPUTE EN-VARIANT(L-ROW) = 1 + WS-PATTERN(WS-N) + WS-BASE * 65536 + WS-COLOUR * 16777216
     END-IF
     GOBACK.
 END PROGRAM STDMOB-AQUATIC-FINALIZE.
