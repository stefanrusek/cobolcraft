*> Standard (minecraft:) mobs (002-lane-mobs; docs/protocol/18 sections 2 to 7, 19 sections 2.1 and 2.2). A standard mob is a
*> tracker row of a vanilla entity type id that has a row in core/copy/STDMOBS.cpy (pig, cow, sheep, chicken); the stand-in table
*> (MOBS.cpy, core/src/mobs.cob) describes the cobolcraft types only. The type ids are found by key in the open standard set, once.
*> Viewers see the row like any tracked entity (core/src/entities.cob); the client draws the vanilla model of the type.
*>
*> Entry points:
*>   STDMOB-INDEX USING entity type id, index out           the STDMOBS.cpy row (1 to SM-COUNT) in a standard world, else 0
*>   STDMOB-HEALTH USING entity type id, health out         max_health of the row, 0 for no row
*>   STDMOB-PANIC USING entity type id, panic milli out     the panic speed (blocks per tick x 1000), 0 for no row
*>   STDMOB-DROPS USING dim, x, y, z, entity id, type       the loot pools of the type on the ground (18 section 7.5, 7.6)
*>   STDMOB-STEP USING tracker row                          one tick of one mob: stroll or panic, then the physics
*>   STDMOB-SPAWN-RULE USING dim, x, z, top, r              one natural pack on the block at (x, top)
*>   STDMOB-SPAWN-TRY USING dim, player row                 one attempt around the player
*>   STDMOB-SPAWN-TICK                                      the friendly spawn cycle (18 section 6.1)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-INDEX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY STDMOBS.
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 4 TIMES.
 01 WS-LOADED              BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW                 PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-INDEX.
     MOVE 0 TO L-INDEX
     IF CT-OPEN = 0 OR CT-SET-TYPE = CT-TYPE-COBOLCRAFT OR CT-SET-TYPE = CT-TYPE-DEBUG
         GOBACK
     END-IF
     IF WS-LOADED = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-COUNT
             MOVE SPACES TO WS-KEY
             STRING "minecraft:" DELIMITED BY SIZE SM-KEY(WS-I) DELIMITED BY SPACE INTO WS-KEY
             CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ID(WS-I) WS-ROW WS-STATUS
         END-PERFORM
         MOVE 1 TO WS-LOADED
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-COUNT
         IF WS-ID(WS-I) = L-TYPE
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STDMOB-INDEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-HEALTH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-HEALTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-HEALTH.
     MOVE 0 TO L-HEALTH
     CALL "STDMOB-INDEX" USING L-TYPE WS-M
     IF WS-M > 0
         MOVE SM-HEALTH(WS-M) TO L-HEALTH
     END-IF
     GOBACK.
 END PROGRAM STDMOB-HEALTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-PANIC.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-MILLI                BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-MILLI.
     MOVE 0 TO L-MILLI
     CALL "STDMOB-INDEX" USING L-TYPE WS-M
     IF WS-M > 0
         MOVE SM-PANIC-MILLI(WS-M) TO L-MILLI
     END-IF
     GOBACK.
 END PROGRAM STDMOB-PANIC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-DROPS.
*> USING dim, x, y, z (FLOAT-LONG), entity id, entity type (BINARY-LONG): each pool of the row is one item roll, uniform(min, max)
*> (19 sections 2.1 and 2.2; no looting, and no smelting without fire), the stack spawned at the position as Entity.spawnAtLocation
*> does (IP-AT-LOCATION). The random numbers are RNG-HASH of the entity id, the pool and the time.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-POOL                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-OFFSET              FLOAT-LONG VALUE 0.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-ITEM-ENTITY         BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ID L-TYPE.
     CALL "STDMOB-INDEX" USING L-TYPE WS-M
     IF WS-M = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-POOL FROM 1 BY 1 UNTIL WS-POOL > 2
         MOVE SPACES TO WS-KEY
         IF WS-POOL = 1
             MOVE SM-DROP-MIN-1(WS-M) TO WS-MIN
             MOVE SM-DROP-MAX-1(WS-M) TO WS-MAX
             IF SM-DROP-KEY-1(WS-M) NOT = SPACES
                 STRING "minecraft:" DELIMITED BY SIZE SM-DROP-KEY-1(WS-M) DELIMITED BY SPACE INTO WS-KEY
             END-IF
         ELSE
             MOVE SM-DROP-MIN-2(WS-M) TO WS-MIN
             MOVE SM-DROP-MAX-2(WS-M) TO WS-MAX
             IF SM-DROP-KEY-2(WS-M) NOT = SPACES
                 STRING "minecraft:" DELIMITED BY SIZE SM-DROP-KEY-2(WS-M) DELIMITED BY SPACE INTO WS-KEY
             END-IF
         END-IF
         IF WS-KEY NOT = SPACES
             MOVE L-ID TO WS-ARG(1)
             MOVE WS-POOL TO WS-ARG(2)
             MOVE CW-TIME TO WS-ARG(3)
             CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
             COMPUTE WS-AMOUNT = WS-MIN + FUNCTION MOD(WS-R, WS-MAX - WS-MIN + 1)
             CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
             IF WS-AMOUNT > 0 AND WS-ITEM > 0
                 CALL "IP-AT-LOCATION" USING L-DIM L-X L-Y L-Z WS-OFFSET WS-ITEM WS-AMOUNT WS-NONE
                     WS-ITEM-ENTITY
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STDMOB-DROPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-STEP.
*> USING tracker row: nothing for a row that is no standard mob or whose chunk is not loaded. Otherwise the hurt window counts down,
*> then the mob panics (EN-FLEE ticks left, away from the attacker at the panic speed) or strolls: a standing mob (EN-COOLDOWN 0)
*> starts a stroll with probability 1 / SM-STROLL-ODDS on a tick (hash of the entity id and the time), along a random heading for
*> 3 to 10 blocks at the walk speed (EN-COOLDOWN = the ticks left, EN-WANDER-X/-Z the velocity); then MOB-PHYSICS moves it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CHUNK               BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-Q                   BINARY-DOUBLE.
 01 WS-P                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-RADIANS             FLOAT-LONG.
 01 WS-BLOCKS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE L-ROW TO WS-ROW
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-ROW) WS-M
     IF WS-M = 0
         GOBACK
     END-IF
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-ROW) / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-ROW) / 16)
     CALL "WORLD-FIND" USING EN-DIM(WS-ROW) WS-CX WS-CZ WS-CHUNK
     IF WS-CHUNK = 0
         GOBACK
     END-IF
     IF EN-HURT(WS-ROW) > 0
         SUBTRACT 1 FROM EN-HURT(WS-ROW)
     END-IF
     MOVE EN-YAW(WS-ROW) TO WS-YAW
     MOVE 0 TO WS-HX WS-HZ
     IF EN-FLEE(WS-ROW) > 0
         SUBTRACT 1 FROM EN-FLEE(WS-ROW)
         MOVE EN-FLEE-PLAYER(WS-ROW) TO WS-P
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ID(WS-P) = EN-FLEE-ID(WS-ROW)
                 AND PL-DIM(WS-P) = EN-DIM(WS-ROW)
             MOVE PL-X(WS-P) TO EN-FLEE-X(WS-ROW)
             MOVE PL-Z(WS-P) TO EN-FLEE-Z(WS-ROW)
         END-IF
         COMPUTE WS-DX = EN-X(WS-ROW) - EN-FLEE-X(WS-ROW)
         COMPUTE WS-DZ = EN-Z(WS-ROW) - EN-FLEE-Z(WS-ROW)
         CALL "MOB-YAW-TOWARD" USING WS-DX WS-DZ WS-YAW
         COMPUTE WS-SPEED = SM-PANIC-MILLI(WS-M) / 1000
         COMPUTE WS-RADIANS = WS-YAW * FUNCTION PI / 180
         COMPUTE WS-HX = - FUNCTION SIN(WS-RADIANS) * WS-SPEED
         COMPUTE WS-HZ = FUNCTION COS(WS-RADIANS) * WS-SPEED
         MOVE 0 TO EN-COOLDOWN(WS-ROW)
     ELSE
         IF EN-COOLDOWN(WS-ROW) = 0
             MOVE EN-ID(WS-ROW) TO WS-ARG(1)
             MOVE CW-TIME TO WS-ARG(2)
             MOVE 7 TO WS-ARG(3)
             CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
             IF FUNCTION MOD(WS-R, SM-STROLL-ODDS) = 0
                 COMPUTE WS-Q = WS-R / SM-STROLL-ODDS
                 COMPUTE WS-YAW = FUNCTION MOD(WS-Q, 360)
                 COMPUTE WS-Q = WS-Q / 360
                 COMPUTE WS-BLOCKS = 3 + FUNCTION MOD(WS-Q, SM-STROLL-BLOCKS - 2)
                 COMPUTE WS-SPEED = SM-WALK-MILLI(WS-M) / 1000
                 COMPUTE EN-COOLDOWN(WS-ROW) = WS-BLOCKS / WS-SPEED + 1
                 COMPUTE WS-RADIANS = WS-YAW * FUNCTION PI / 180
                 COMPUTE EN-WANDER-X(WS-ROW) = - FUNCTION SIN(WS-RADIANS) * WS-SPEED
                 COMPUTE EN-WANDER-Z(WS-ROW) = FUNCTION COS(WS-RADIANS) * WS-SPEED
             END-IF
         END-IF
         IF EN-COOLDOWN(WS-ROW) > 0
             SUBTRACT 1 FROM EN-COOLDOWN(WS-ROW)
             MOVE EN-WANDER-X(WS-ROW) TO WS-HX
             MOVE EN-WANDER-Z(WS-ROW) TO WS-HZ
         END-IF
     END-IF
     CALL "MOB-PHYSICS" USING WS-ROW WS-HX WS-HZ WS-YAW
     GOBACK.
 END PROGRAM STDMOB-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-BRIGHT.
*> USING dim, x, y, z (BINARY-LONG), brightness out: the raw brightness of the cell, max(sky light, block light) (18 section 6.8;
*> getRawBrightness(pos, 0) subtracts no darkening). Light is held per section of 4096 cells, 2048 bytes, the first light section
*> being the one below the dimension; a column that is not loaded reads 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CELLS.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CHUNK               BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-LIGHT                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-LIGHT.
     MOVE 0 TO L-LIGHT
     COMPUTE WS-CX = (L-X - FUNCTION MOD(L-X, 16)) / 16
     COMPUTE WS-CZ = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
     CALL "WORLD-FIND" USING L-DIM WS-CX WS-CZ WS-CHUNK
     IF WS-CHUNK = 0
         GOBACK
     END-IF
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-CHUNK)
     COMPUTE WS-CELL = (L-Y - DM-MIN-Y(L-DIM)) * 256 + (L-Z - WS-CZ * 16) * 16 + L-X - WS-CX * 16 + 1
     COMPUTE WS-BYTE = 2048 + (WS-CELL - 1) / 2 + 1
     MOVE CE-BLOCK-LIGHT(WS-BYTE) TO WS-BLOCK
     MOVE CE-SKY(WS-BYTE) TO WS-SKY
     IF FUNCTION MOD(WS-CELL, 2) = 1
         COMPUTE WS-BLOCK = FUNCTION MOD(WS-BLOCK, 16)
         COMPUTE WS-SKY = FUNCTION MOD(WS-SKY, 16)
     ELSE
         COMPUTE WS-BLOCK = WS-BLOCK / 16
         COMPUTE WS-SKY = WS-SKY / 16
     END-IF
     COMPUTE L-LIGHT = FUNCTION MAX(WS-BLOCK, WS-SKY)
     GOBACK.
 END PROGRAM STDMOB-BRIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SPAWN-RULE.
*> USING dimension row, x, z, top (BINARY-LONG: the block column and the y of its ground block), r (BINARY-DOUBLE, a hash): one pack
*> of the creature category at that column (18 section 6.5, the position rules of 6.8 and the animal rule): the type is table row
*> 1 + (r div 4) mod SM-COUNT, the pack size 1 + r mod 4. A member needs grass_block below its cell, two air cells above and a raw
*> brightness above 8, and fewer than SM-LOCAL-CAP creatures within SM-CAP-CHUNKS chunks of its chunk (6.3 local cap). The first member
*> stands at the column, each next one at a cursor that moves by nextInt(6) - nextInt(6) blocks per axis (6.5 step 1) at the same y.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY STDMOBS.
 01 WS-GRASS               BINARY-LONG.
 01 WS-EPOCH               BINARY-LONG VALUE -1.
 01 WS-KEY                 PIC X(112).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-SIZE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-LIGHT               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG VALUE 5.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-H                   BINARY-DOUBLE.
 01 WS-Q                   BINARY-DOUBLE.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ECX                 BINARY-LONG.
 01 WS-ECZ                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-R                    BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-DIM L-X L-Z L-TOP L-R.
     IF WS-EPOCH NOT = CB-EPOCH
         MOVE SPACES TO WS-KEY
         MOVE "minecraft:grass_block" TO WS-KEY
         CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-GRASS WS-BLOCK-ROW WS-STATUS
         MOVE CB-EPOCH TO WS-EPOCH
     END-IF
     COMPUTE WS-Q = L-R / 4
     COMPUTE WS-M = FUNCTION MOD(WS-Q, SM-COUNT) + 1
     COMPUTE WS-SIZE = FUNCTION MOD(L-R, SM-PACK-MAX) + 1
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE SM-KEY(WS-M) DELIMITED BY SPACE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE L-X TO WS-X
     MOVE L-Z TO WS-Z
     COMPUTE WS-Y = L-TOP + 1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-SIZE
         IF WS-I > 1
             COMPUTE WS-ARG(1) = L-DIM
             MOVE L-R TO WS-ARG(2)
             MOVE WS-I TO WS-ARG(3)
             MOVE WS-X TO WS-ARG(4)
             MOVE WS-Z TO WS-ARG(5)
             CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-H
             COMPUTE WS-Q = WS-H / SM-CURSOR-STEP
             COMPUTE WS-X = WS-X + FUNCTION MOD(WS-H, SM-CURSOR-STEP) - FUNCTION MOD(WS-Q, SM-CURSOR-STEP)
             COMPUTE WS-Q = WS-Q / SM-CURSOR-STEP
             COMPUTE WS-Z = WS-Z + FUNCTION MOD(WS-Q, SM-CURSOR-STEP)
                 - FUNCTION MOD(WS-Q / SM-CURSOR-STEP, SM-CURSOR-STEP)
         END-IF
         MOVE 1 TO WS-OK
         COMPUTE WS-CX = (WS-X - FUNCTION MOD(WS-X, 16)) / 16
         COMPUTE WS-CZ = (WS-Z - FUNCTION MOD(WS-Z, 16)) / 16
         CALL "WORLD-FIND" USING L-DIM WS-CX WS-CZ WS-ROW
         IF WS-ROW = 0
             MOVE 0 TO WS-OK
         END-IF
         IF WS-OK = 1
             CALL "WORLD-GET-BLOCK" USING L-DIM WS-X L-TOP WS-Z WS-STATE
             IF CB-S-BLOCK(WS-STATE + 1) NOT = WS-GRASS
                 MOVE 0 TO WS-OK
             END-IF
         END-IF
         IF WS-OK = 1
             CALL "WORLD-GET-BLOCK" USING L-DIM WS-X WS-Y WS-Z WS-STATE
             IF WS-STATE NOT = 0
                 MOVE 0 TO WS-OK
             END-IF
             COMPUTE WS-E = WS-Y + 1
             CALL "WORLD-GET-BLOCK" USING L-DIM WS-X WS-E WS-Z WS-STATE
             IF WS-STATE NOT = 0
                 MOVE 0 TO WS-OK
             END-IF
         END-IF
         IF WS-OK = 1
             CALL "STDMOB-BRIGHT" USING L-DIM WS-X WS-Y WS-Z WS-LIGHT
             IF WS-LIGHT < SM-LIGHT-MIN
                 MOVE 0 TO WS-OK
             END-IF
         END-IF
         IF WS-OK = 1
             MOVE 0 TO WS-N
             PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
                 IF EN-USED(WS-E) = 1 AND EN-DIM(WS-E) = L-DIM
                     CALL "STDMOB-INDEX" USING EN-TYPE(WS-E) WS-STATE
                     IF WS-STATE > 0
                         COMPUTE WS-ECX = FUNCTION INTEGER(EN-X(WS-E) / 16)
                         COMPUTE WS-ECZ = FUNCTION INTEGER(EN-Z(WS-E) / 16)
                         IF FUNCTION ABS(WS-ECX - WS-CX) <= SM-CAP-CHUNKS
                                 AND FUNCTION ABS(WS-ECZ - WS-CZ) <= SM-CAP-CHUNKS
                             ADD 1 TO WS-N
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
             IF WS-N >= SM-LOCAL-CAP
                 MOVE 0 TO WS-OK
             END-IF
         END-IF
         IF WS-OK = 1
             COMPUTE WS-FX = WS-X + 0.5
             MOVE WS-Y TO WS-FY
             COMPUTE WS-FZ = WS-Z + 0.5
             COMPUTE WS-Q = L-R / 16
             COMPUTE WS-YAW = FUNCTION MOD(WS-Q + WS-I * 97, 360)
             CALL "MOB-SPAWN" USING L-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STDMOB-SPAWN-RULE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SPAWN-TRY.
*> USING dimension row, player row: one attempt around the player (18 sections 6.4 and 6.5 step 2): the column is a hash of the
*> dimension, the player's column and the time, within 40 blocks per axis, and no nearer than 24 blocks horizontally (a spawn
*> must be above 576 squared distance from the player); it must be in a loaded chunk, with its ground the highest non-void block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY STDMOBS.
 01 WS-COUNT               BINARY-LONG VALUE 4.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-Q                   BINARY-DOUBLE.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CHUNK               BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SPREAD              BINARY-LONG VALUE 81.
 01 WS-REACH               BINARY-LONG VALUE 40.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-PLAYER.
     COMPUTE WS-ARG(1) = L-DIM - 1
     COMPUTE WS-ARG(2) = FUNCTION INTEGER(PL-X(L-PLAYER))
     COMPUTE WS-ARG(3) = FUNCTION INTEGER(PL-Z(L-PLAYER))
     MOVE CW-TIME TO WS-ARG(4)
     CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
     COMPUTE WS-DX = FUNCTION MOD(WS-R, WS-SPREAD) - WS-REACH
     COMPUTE WS-Q = WS-R / WS-SPREAD
     COMPUTE WS-DZ = FUNCTION MOD(WS-Q, WS-SPREAD) - WS-REACH
     IF WS-DX * WS-DX + WS-DZ * WS-DZ <= SM-NEAR-BLOCKS * SM-NEAR-BLOCKS
         GOBACK
     END-IF
     COMPUTE WS-X = WS-ARG(2) + WS-DX
     COMPUTE WS-Z = WS-ARG(3) + WS-DZ
     COMPUTE WS-CX = (WS-X - FUNCTION MOD(WS-X, 16)) / 16
     COMPUTE WS-CZ = (WS-Z - FUNCTION MOD(WS-Z, 16)) / 16
     CALL "WORLD-FIND" USING L-DIM WS-CX WS-CZ WS-CHUNK
     IF WS-CHUNK = 0
         GOBACK
     END-IF
     COMPUTE WS-TOP = DM-MIN-Y(L-DIM) + DM-HEIGHT(L-DIM) - 1
     MOVE 0 TO WS-STATE
     PERFORM UNTIL WS-STATE NOT = 0 OR WS-TOP < DM-MIN-Y(L-DIM)
         CALL "WORLD-GET-BLOCK" USING L-DIM WS-X WS-TOP WS-Z WS-STATE
         IF WS-STATE = 0
             SUBTRACT 1 FROM WS-TOP
         END-IF
     END-PERFORM
     IF WS-TOP + 3 >= DM-MIN-Y(L-DIM) + DM-HEIGHT(L-DIM) OR WS-TOP < DM-MIN-Y(L-DIM)
         GOBACK
     END-IF
     COMPUTE WS-Q = WS-R / (WS-SPREAD * WS-SPREAD)
     CALL "STDMOB-SPAWN-RULE" USING L-DIM WS-X WS-Z WS-TOP WS-Q
     GOBACK.
 END PROGRAM STDMOB-SPAWN-TRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SPAWN-TICK.
*> No parameters: in a standard world, on ticks with Time mod SM-SPAWN-TICKS = 0 (the friendly cycle), each alive player of each
*> enabled dimension in player-row order makes one attempt (STDMOB-SPAWN-TRY).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 01 WS-D                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 PROCEDURE DIVISION.
     IF CT-OPEN = 0 OR CT-SET-TYPE NOT = CT-TYPE-STANDARD
         GOBACK
     END-IF
     IF FUNCTION MOD(CW-TIME, SM-SPAWN-TICKS) NOT = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > CW-DIM-COUNT
         MOVE CW-DIM(WS-D) TO WS-DIM
         PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS
             IF PL-USED(WS-PLAYER) = 1 AND PL-STATE(WS-PLAYER) = PS-ALIVE AND PL-DIM(WS-PLAYER) = WS-DIM
                 CALL "STDMOB-SPAWN-TRY" USING WS-DIM WS-PLAYER
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM STDMOB-SPAWN-TICK.
