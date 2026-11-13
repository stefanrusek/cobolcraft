*> Standard (minecraft:) mobs (002-lane-mobs; docs/protocol/18 sections 2 to 7, 19 sections 2.1 and 2.2). A standard mob is a
*> tracker row of a vanilla entity type id that has a row in core/copy/STDMOBS.cpy (pig, cow, sheep, chicken); the stand-in table
*> (MOBS.cpy, core/src/mobs.cob) describes the cobolcraft types only. The type ids are found by key in the open standard set, once.
*> Viewers see the row like any tracked entity (core/src/entities.cob); the client draws the vanilla model of the type.
*>
*> Entry points:
*>   STDMOB-INDEX USING entity type id, index out           the STDMOBS.cpy row (1 to SM-COUNT) in a standard world, else 0
*>   STDMOB-HEALTH USING entity type id, health out         max_health of the row, 0 for no row
*>   STDMOB-PANIC USING entity type id, panic milli out     the panic speed (blocks per tick x 1000), 0 for no row
*>   STDMOB-DIE USING tracker row                           death: loot, Entity Event 3, dying for 20 ticks
*>   STDMOB-VANISH USING tracker row                        Entity Event 60 and removal
*>   STDMOB-DROPS USING dim, x, y, z, type, killed        the loot table of the type on the ground (18 section 7.5, 7.6)
*>   STDMOB-STEP USING tracker row                          one tick of one mob: stroll or panic, then the physics
*>   STDMOB-NAME USING entity type id, name out (PIC X(16)), length out   the display name of the type ("Zombie")
*>   STDMOB-SPAWN-RULE USING dim, x, z, top, r              one natural pack of animals on the block at (x, top)
*>   STDMOB-SPAWN-HOSTILE USING dim, x, z, top, r           one pack of monsters on the block at (x, top), in the dark
*>   STDMOB-SPAWN-TRY USING dim, player row, mode           one attempt around the player (1 animals, 2 monsters)
*>   STDMOB-SPAWN-TICK                                      the spawn cycles (18 section 6.1)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-INDEX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY STDMOBS.
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 6 TIMES.
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
*> USING dim, x, y, z (FLOAT-LONG), entity type (BINARY-LONG), killed by a player (BINARY-LONG, 0 or 1): the loot table of the type,
*> minecraft:entities/<key> (18 sections 7.5 and 7.6, rolled by LOOT-ROLL of docs 26), with this_entity the mob's type key and
*> last_damage_player set when a player killed it; every stack it yields lands on the ground at the mob's position as
*> Entity.spawnAtLocation does (IP-AT-LOCATION). A set without the table drops nothing. The type must be a table mob (the caller, STDMOB-DIE, has checked).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY LOOTCTX.
 01 WS-M                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-I                   BINARY-LONG.
 01 WS-OFFSET              FLOAT-LONG VALUE 0.
 01 WS-ITEM-ENTITY         BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-KILLED               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-TYPE L-KILLED.
     CALL "STDMOB-INDEX" USING L-TYPE WS-M
     MOVE SPACES TO WS-KEY
     STRING "minecraft:entities/" DELIMITED BY SIZE SM-KEY(WS-M) DELIMITED BY SPACE INTO WS-KEY
     INITIALIZE LOOT-CONTEXT
     MOVE 1 TO LC-ORIGIN-SET LC-THIS-SET
     MOVE L-X TO LC-X
     MOVE L-Y TO LC-Y
     MOVE L-Z TO LC-Z
     STRING "minecraft:" DELIMITED BY SIZE SM-KEY(WS-M) DELIMITED BY SPACE INTO LC-THIS-TYPE
     MOVE L-KILLED TO LC-KILLER
     MOVE CW-SEED TO LC-WORLD-SEED
     CALL "LOOT-ROLL" USING WS-KEY LOOT-CONTEXT LOOT-RESULT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > LR-COUNT
         CALL "IP-AT-LOCATION" USING L-DIM L-X L-Y L-Z WS-OFFSET LR-ITEM(WS-I) LR-AMOUNT(WS-I) LR-HANDLE(WS-I)
             WS-ITEM-ENTITY
     END-PERFORM
     GOBACK.
 END PROGRAM STDMOB-DROPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-DIE.
*> USING tracker row of a standard mob whose health reached 0 (18 section 7.5): its loot lands on the ground now (STDMOB-DROPS), Entity Event 3
*> (death) goes to the viewers, and the row stays as a dying mob for 20 ticks: health 0, EN-COOLDOWN counts the ticks (deathTime), the
*> panic and the stroll end. STDMOB-STEP finishes it (Entity Event 60, removal).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-EVENT               BINARY-LONG VALUE 3.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-KILLED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     MOVE EN-ID(L-ROW) TO WS-ID
     MOVE EN-TYPE(L-ROW) TO WS-TYPE
     MOVE 0 TO EN-HEALTH(L-ROW) EN-COOLDOWN(L-ROW) EN-FLEE(L-ROW)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "ENTITY-EVENT-BUILD" USING WS-ID WS-EVENT PB-BUFFER
     CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     MOVE 0 TO WS-KILLED
     IF EN-KILLER(L-ROW) > 0
         MOVE 1 TO WS-KILLED
     END-IF
     CALL "STDMOB-DROPS" USING WS-DIM WS-X WS-Y WS-Z WS-TYPE WS-KILLED
     GOBACK.
 END PROGRAM STDMOB-DIE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-VANISH.
*> USING tracker row of a dying standard mob at the 20th tick (18 section 7.5): Entity Event 60 (poof) to the viewers, then the row is removed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-EVENT               BINARY-LONG VALUE 60.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ROW) WS-EVENT PB-BUFFER
     CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     CALL "ENTITY-REMOVE" USING L-ROW
     GOBACK.
 END PROGRAM STDMOB-VANISH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-READY.
*> USING dim, chunk x, chunk z (BINARY-LONG), ready out (BINARY-LONG): 1 when the chunk is generated, 0 when it is not. A chunk enters the cache only when
*> its generation is done (the generation queue and the worker pool install a finished chunk, gen-queue.cob), so a cache row means generated; a chunk that
*> was never loaded, or is still being made, has no contents to rely on, so no mob spawns or moves in it. The light of an installed chunk is computed
*> on demand here (LIGHT-CHUNK, as WORLD-CHUNK does), because the dark and daylight rules read it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-CHUNK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-READY                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-READY.
     MOVE 0 TO L-READY
     CALL "WORLD-FIND" USING L-DIM L-CX L-CZ WS-CHUNK
     IF WS-CHUNK > 0
         IF CK-LIT(WS-CHUNK) = 0
             CALL "LIGHT-CHUNK" USING WS-CHUNK
         END-IF
         MOVE 1 TO L-READY
     END-IF
     GOBACK.
 END PROGRAM STDMOB-READY.


 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-NAME.
*> USING entity type id (BINARY-LONG), name out (PIC X(16)), length out (BINARY-LONG): the display name of a table mob, its key with the first letter
*> in capitals (zombie: Zombie), for the death message of a player it killed. A type with no row gives spaces and 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-LOWER               PIC X(26) VALUE "abcdefghijklmnopqrstuvwxyz".
 01 WS-UPPER               PIC X(26) VALUE "ABCDEFGHIJKLMNOPQRSTUVWXYZ".
 01 WS-TEXT                PIC X(24).
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-NAME                 PIC X(16).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-NAME L-LENGTH.
     MOVE SPACES TO L-NAME
     MOVE 0 TO L-LENGTH
     CALL "STDMOB-INDEX" USING L-TYPE WS-M
     IF WS-M > 0
         MOVE SM-KEY(WS-M) TO WS-TEXT
         INSPECT WS-TEXT(1:1) CONVERTING WS-LOWER TO WS-UPPER
         MOVE WS-TEXT(1:16) TO L-NAME
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO L-LENGTH
     END-IF
     GOBACK.
 END PROGRAM STDMOB-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-TARGET.
*> USING tracker row of a hostile standard mob, table row: its target (20 section 4.1: the nearest attackable player). A target is dropped when that
*> player is gone, not alive, not in survival, in another dimension or beyond the follow range (SM-FOLLOW, 3D distance between positions). Without a
*> target the mob takes the nearest alive survival player of its dimension within the follow range (ties: the earliest-entering player). Line of sight
*> is not tested.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-P                   BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-BEST-D2             FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M.
     COMPUTE WS-LIMIT = SM-FOLLOW(L-M) * SM-FOLLOW(L-M)
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-P > 0
         COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2
             + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
         IF PL-USED(WS-P) NOT = 1 OR PL-ENTITY-ID(WS-P) NOT = EN-TARGET-ID(L-ROW)
                 OR PL-STATE(WS-P) NOT = PS-ALIVE OR PL-MODE(WS-P) NOT = 0
                 OR PL-DIM(WS-P) NOT = EN-DIM(L-ROW) OR WS-D2 > WS-LIMIT
             MOVE 0 TO EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW)
         END-IF
     END-IF
     IF EN-TARGET(L-ROW) > 0
         GOBACK
     END-IF
     MOVE 0 TO WS-BEST
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-MODE(WS-P) = 0
                 AND PL-DIM(WS-P) = EN-DIM(L-ROW)
             COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2
                 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
             IF WS-D2 <= WS-LIMIT AND (WS-BEST = 0 OR WS-D2 < WS-BEST-D2
                     OR (WS-D2 = WS-BEST-D2 AND PL-ENTERED(WS-P) < PL-ENTERED(WS-BEST)))
                 MOVE WS-P TO WS-BEST
                 MOVE WS-D2 TO WS-BEST-D2
             END-IF
         END-IF
     END-PERFORM
     IF WS-BEST > 0
         MOVE WS-BEST TO EN-TARGET(L-ROW)
         MOVE PL-ENTITY-ID(WS-BEST) TO EN-TARGET-ID(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM STDMOB-TARGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-LIGHTS.
*> USING dim, x, y, z (BINARY-LONG), sky out, block out: the raw sky light and block light of the cell (no sky darkening). Light is held per section of
*> 4096 cells, 2048 bytes, the first light section being the one below the dimension; a column that is not loaded reads 0 and 0.
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
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SKY                  BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-SKY L-BLOCK.
     MOVE 0 TO L-SKY L-BLOCK
     IF L-Y < DM-MIN-Y(L-DIM) OR L-Y >= DM-MIN-Y(L-DIM) + DM-HEIGHT(L-DIM)
         GOBACK
     END-IF
     COMPUTE WS-CX = (L-X - FUNCTION MOD(L-X, 16)) / 16
     COMPUTE WS-CZ = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
     CALL "WORLD-FIND" USING L-DIM WS-CX WS-CZ WS-CHUNK
     IF WS-CHUNK = 0
         GOBACK
     END-IF
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-CHUNK)
     COMPUTE WS-CELL = (L-Y - DM-MIN-Y(L-DIM)) * 256 + (L-Z - WS-CZ * 16) * 16 + L-X - WS-CX * 16 + 1
     COMPUTE WS-BYTE = 2048 + (WS-CELL - 1) / 2 + 1
     MOVE CE-BLOCK-LIGHT(WS-BYTE) TO L-BLOCK
     MOVE CE-SKY(WS-BYTE) TO L-SKY
     IF FUNCTION MOD(WS-CELL, 2) = 1
         COMPUTE L-BLOCK = FUNCTION MOD(L-BLOCK, 16)
         COMPUTE L-SKY = FUNCTION MOD(L-SKY, 16)
     ELSE
         COMPUTE L-BLOCK = L-BLOCK / 16
         COMPUTE L-SKY = L-SKY / 16
     END-IF
     GOBACK.
 END PROGRAM STDMOB-LIGHTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-BRIGHT.
*> USING dim, x, y, z (BINARY-LONG), brightness out: the raw brightness of the cell, max(sky light, block light) (18 section 6.8;
*> getRawBrightness(pos, 0) subtracts no darkening). A column that is not loaded reads 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-LIGHT                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-LIGHT.
     CALL "STDMOB-LIGHTS" USING L-DIM L-X L-Y L-Z WS-SKY WS-BLOCK
     COMPUTE L-LIGHT = FUNCTION MAX(WS-BLOCK, WS-SKY)
     GOBACK.
 END PROGRAM STDMOB-BRIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-DARKEN.
*> USING time (BINARY-DOUBLE, the day clock), darkening out (BINARY-LONG): how many points the night takes off the sky light in the Overworld: 0 by
*> day, SM-DARK-MAX from SM-DARK-FULL-START to SM-DARK-FULL-END, a linear ramp over the dusk and dawn (12 section 3.2 D4, whose ticks are the
*> reference tracks of the client's sky).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STDMOBS.
 01 WS-T                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TIME                 BINARY-DOUBLE.
 01 L-DARK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TIME L-DARK.
     COMPUTE WS-T = FUNCTION MOD(L-TIME, 24000)
     IF WS-T < SM-DARK-RAMP-END - 24000
         ADD 24000 TO WS-T
     END-IF
     EVALUATE TRUE
         WHEN WS-T < SM-DARK-RAMP-UP
             MOVE 0 TO L-DARK
         WHEN WS-T < SM-DARK-FULL-START
             COMPUTE L-DARK = SM-DARK-MAX * (WS-T - SM-DARK-RAMP-UP) / (SM-DARK-FULL-START - SM-DARK-RAMP-UP)
         WHEN WS-T <= SM-DARK-FULL-END
             MOVE SM-DARK-MAX TO L-DARK
         WHEN OTHER
             COMPUTE L-DARK = SM-DARK-MAX * (SM-DARK-RAMP-END - WS-T) / (SM-DARK-RAMP-END - SM-DARK-FULL-END)
     END-EVALUATE
     GOBACK.
 END PROGRAM STDMOB-DARKEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-BURN.
*> USING tracker row, table row of a mob that burns in daylight (SM-BURNS 1, 20 section 3.5; STDMOB-STEP calls it for those rows only). While not burning, in the monsters_burn window of the day
*> (SM-BURN-DAY-START to SM-BURN-DAY-END) and with raw light 13 or more at its eye cell (the sky is open there), a hash of the entity id and the time
*> sets it on fire for SM-BURN-TICKS with the chance of the light (SM-BURN-CHANCE, per ten thousand). While burning EN-BURN counts down and every
*> SM-BURN-STEP ticks the mob takes 1 point (HEALTH-MOB-DAMAGE, the generic cause). Water, rain and head items are not modelled.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY STDMOBS.
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-T                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-LIGHT               BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG VALUE 1.
 01 WS-CAUSE               BINARY-LONG VALUE 6.
 01 WS-NO-ATTACKER         BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M.
     IF EN-BURN(L-ROW) > 0
         SUBTRACT 1 FROM EN-BURN(L-ROW)
         IF FUNCTION MOD(EN-BURN(L-ROW), SM-BURN-STEP) = 0
             CALL "HEALTH-MOB-DAMAGE" USING L-ROW WS-AMOUNT WS-CAUSE WS-NO-ATTACKER
         END-IF
         GOBACK
     END-IF
     COMPUTE WS-T = FUNCTION MOD(CW-TIME, 24000)
     IF WS-T >= SM-BURN-DAY-END AND WS-T < SM-BURN-DAY-START
         GOBACK
     END-IF
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW)) + 1
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "STDMOB-BRIGHT" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-LIGHT
     IF WS-LIGHT < 13
         GOBACK
     END-IF
     MOVE EN-ID(L-ROW) TO WS-ARG(1)
     MOVE CW-TIME TO WS-ARG(2)
     MOVE 11 TO WS-ARG(3)
     CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
     IF FUNCTION MOD(WS-R, 10000) < SM-BURN-CHANCE(WS-LIGHT - 12)
         MOVE SM-BURN-TICKS TO EN-BURN(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM STDMOB-BURN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-STEP.
*> USING tracker row: nothing for a row that is no standard mob. A hostile mob is removed while the difficulty is Peaceful or the hostile-mobs
*> setting is off. A dying mob (health 0) counts its death ticks (EN-COOLDOWN) and vanishes at the 20th (STDMOB-VANISH). Nothing else happens in a
*> chunk that is not generated and lit (STDMOB-READY). Otherwise the hurt window counts down and:
*> - a hostile mob burns in daylight (STDMOB-BURN), keeps a target (STDMOB-TARGET), counts its attack timer down (EN-COOLDOWN), walks toward the
*>   target at the walk speed until its box is within the melee reach, and with the timer at 0 and the target in reach hits it (HEALTH-MOB-HIT, the
*>   attack damage of the row), the timer becoming SM-ATTACK-TICKS; with no target it strolls like the animals;
*> - a mob that was hit panics (EN-FLEE ticks left, away from the attacker at the panic speed);
*> - otherwise a standing mob (EN-COOLDOWN 0) starts a stroll with probability 1 / SM-STROLL-ODDS on a tick (hash of the entity id and the time),
*>   along a random heading for 3 to 10 blocks at the walk speed (EN-COOLDOWN = the ticks left, EN-WANDER-X/-Z the velocity);
*> then MOB-PHYSICS moves it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY BRWORLD.
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
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-REACH               FLOAT-LONG.
 01 WS-RADIANS             FLOAT-LONG.
 01 WS-BLOCKS              BINARY-LONG.
 01 WS-CHASE               BINARY-LONG.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     MOVE L-ROW TO WS-ROW
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-ROW) WS-M
     IF WS-M = 0
         GOBACK
     END-IF
     CALL "BR-WORLD-READY"
     IF SM-KIND(WS-M) = 1 AND (BW-DIFFICULTY = 0 OR CS-HOSTILE-MOBS NOT = 1)
         CALL "ENTITY-REMOVE" USING WS-ROW
         GOBACK
     END-IF
     IF EN-HEALTH(WS-ROW) = 0
         ADD 1 TO EN-COOLDOWN(WS-ROW)
         IF EN-COOLDOWN(WS-ROW) >= SM-DEATH-TICKS
             CALL "STDMOB-VANISH" USING WS-ROW
         END-IF
         GOBACK
     END-IF
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-ROW) / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-ROW) / 16)
     CALL "STDMOB-READY" USING EN-DIM(WS-ROW) WS-CX WS-CZ WS-CHUNK
     IF WS-CHUNK = 0
         GOBACK
     END-IF
     IF EN-HURT(WS-ROW) > 0
         SUBTRACT 1 FROM EN-HURT(WS-ROW)
     END-IF
     MOVE EN-YAW(WS-ROW) TO WS-YAW
     MOVE 0 TO WS-HX WS-HZ WS-CHASE
     IF SM-KIND(WS-M) = 1
         IF SM-BURNS(WS-M) = 1
             CALL "STDMOB-BURN" USING WS-ROW WS-M
         END-IF
         IF EN-HEALTH(WS-ROW) = 0
             GOBACK
         END-IF
         CALL "STDMOB-TARGET" USING WS-ROW WS-M
         IF EN-COOLDOWN(WS-ROW) > 0
             SUBTRACT 1 FROM EN-COOLDOWN(WS-ROW)
         END-IF
         IF EN-TARGET(WS-ROW) > 0
             MOVE 1 TO WS-CHASE
         END-IF
     END-IF
     EVALUATE TRUE
         WHEN WS-CHASE = 1
             MOVE EN-TARGET(WS-ROW) TO WS-P
             COMPUTE WS-DX = PL-X(WS-P) - EN-X(WS-ROW)
             COMPUTE WS-DY = PL-Y(WS-P) - EN-Y(WS-ROW)
             COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(WS-ROW)
             CALL "MOB-YAW-TOWARD" USING WS-DX WS-DZ WS-YAW
             COMPUTE WS-REACH = SM-REACH-MILLI / 1000
             IF FUNCTION ABS(WS-DX) > WS-REACH OR FUNCTION ABS(WS-DZ) > WS-REACH
                 COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
                 COMPUTE WS-SPEED = SM-WALK-MILLI(WS-M) / 1000
                 COMPUTE WS-HX = WS-SPEED * WS-DX / WS-H
                 COMPUTE WS-HZ = WS-SPEED * WS-DZ / WS-H
             END-IF
             IF EN-COOLDOWN(WS-ROW) = 0 AND FUNCTION ABS(WS-DX) <= WS-REACH
                     AND FUNCTION ABS(WS-DZ) <= WS-REACH
                     AND WS-DY > - SM-REACH-BELOW-MILLI / 1000 AND WS-DY < SM-REACH-ABOVE-MILLI / 1000
                 MOVE SM-ATTACK-TICKS TO EN-COOLDOWN(WS-ROW)
                 CALL "HEALTH-MOB-HIT" USING WS-P SM-ATTACK(WS-M) WS-ROW
             END-IF
         WHEN EN-FLEE(WS-ROW) > 0
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
         WHEN OTHER
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
     END-EVALUATE
     CALL "MOB-PHYSICS" USING WS-ROW WS-HX WS-HZ WS-YAW
     GOBACK.
 END PROGRAM STDMOB-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SPOT-OK.
*> USING dim, x, top, z (BINARY-LONG: the column and the y of its ground block), mode (1 animal, 2 monster), r (BINARY-DOUBLE, the draw), ok out
*> (BINARY-LONG): whether a mob of that mode may stand on the cell above the ground (18 sections 6.5 and 6.8, 20 sections 3.3 and 3.4). The chunk must
*> be generated and lit, the two cells above the ground must be air, and:
*> - animals: the ground is grass_block and the raw brightness is above 8 (SM-LIGHT-MIN);
*> - monsters: the ground block is solid; with the sky light after the night's darkening (STDMOB-DARKEN) called s: it fails when s is above
*>   nextInt(32), when the block light is above 0 (the Overworld limit), and passes when s is at most nextInt(8) (the uniform 0 to 7 spawn light of the
*>   Overworld); the two draws are RNG-HASH values of r.
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
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-READY               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-DARK                BINARY-LONG.
 01 WS-LIGHT               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-H                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-R                    BINARY-DOUBLE.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-TOP L-Z L-MODE L-R L-OK.
     MOVE 0 TO L-OK
     IF WS-EPOCH NOT = CB-EPOCH
         MOVE SPACES TO WS-KEY
         MOVE "minecraft:grass_block" TO WS-KEY
         CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-GRASS WS-BLOCK-ROW WS-STATUS
         MOVE CB-EPOCH TO WS-EPOCH
     END-IF
     COMPUTE WS-CX = (L-X - FUNCTION MOD(L-X, 16)) / 16
     COMPUTE WS-CZ = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
     CALL "STDMOB-READY" USING L-DIM WS-CX WS-CZ WS-READY
     IF WS-READY = 0
         GOBACK
     END-IF
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-TOP L-Z WS-STATE
     IF L-MODE = 1 AND CB-S-BLOCK(WS-STATE + 1) NOT = WS-GRASS
         GOBACK
     END-IF
     IF L-MODE = 2 AND CB-SOLID(CB-S-BLOCK(WS-STATE + 1) + 1) NOT = 1
         GOBACK
     END-IF
     COMPUTE WS-Y = L-TOP + 1
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-Y L-Z WS-STATE
     IF WS-STATE NOT = 0
         GOBACK
     END-IF
     ADD 1 TO WS-Y
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-Y L-Z WS-STATE
     IF WS-STATE NOT = 0
         GOBACK
     END-IF
     COMPUTE WS-Y = L-TOP + 1
     CALL "STDMOB-LIGHTS" USING L-DIM L-X WS-Y L-Z WS-SKY WS-BLOCK
     IF L-MODE = 1
         COMPUTE WS-LIGHT = FUNCTION MAX(WS-SKY, WS-BLOCK)
         IF WS-LIGHT < SM-LIGHT-MIN
             GOBACK
         END-IF
     ELSE
         CALL "STDMOB-DARKEN" USING CW-TIME WS-DARK
         COMPUTE WS-SKY = FUNCTION MAX(0, WS-SKY - WS-DARK)
         IF WS-BLOCK > 0
             GOBACK
         END-IF
         MOVE L-R TO WS-ARG(1)
         MOVE 1 TO WS-ARG(2)
         MOVE L-X TO WS-ARG(3)
         CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-H
         IF WS-SKY > FUNCTION MOD(WS-H, 32)
             GOBACK
         END-IF
         MOVE 2 TO WS-ARG(2)
         CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-H
         IF WS-SKY > FUNCTION MOD(WS-H, 8)
             GOBACK
         END-IF
     END-IF
     MOVE 1 TO L-OK
     GOBACK.
 END PROGRAM STDMOB-SPOT-OK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SPAWN-PACK.
*> USING dimension row, x, z, top (BINARY-LONG: the column and the y of its ground block), r (BINARY-DOUBLE, a hash), mode (1 animals, 2 monsters):
*> one pack at that column (18 section 6.5). The type is the table row 1 + (r div 4) mod SM-NATURAL (animals) or SM-HOSTILE-FIRST + (r div 4) mod
*> SM-HOSTILE-COUNT (monsters), the pack size 1 + r mod 4. The first member stands at the column, each next one at a cursor that moves by
*> nextInt(6) - nextInt(6) blocks per axis (6.5 step 1) at the same y. A member needs a valid spot (STDMOB-SPOT-OK) and fewer than the local cap of
*> its kind (SM-LOCAL-CAP animals, SM-HOSTILE-CAP monsters, 6.3) standard mobs of that kind within SM-CAP-CHUNKS chunks of its chunk.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-SIZE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-CAP                 BINARY-LONG.
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
 01 L-MODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Z L-TOP L-R L-MODE.
     COMPUTE WS-Q = L-R / 4
     IF L-MODE = 1
         COMPUTE WS-M = FUNCTION MOD(WS-Q, SM-NATURAL) + 1
         MOVE SM-LOCAL-CAP TO WS-CAP
     ELSE
         COMPUTE WS-M = SM-HOSTILE-FIRST + FUNCTION MOD(WS-Q, SM-HOSTILE-COUNT)
         MOVE SM-HOSTILE-CAP TO WS-CAP
     END-IF
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
         COMPUTE WS-CX = (WS-X - FUNCTION MOD(WS-X, 16)) / 16
         COMPUTE WS-CZ = (WS-Z - FUNCTION MOD(WS-Z, 16)) / 16
         CALL "STDMOB-SPOT-OK" USING L-DIM WS-X L-TOP WS-Z L-MODE L-R WS-OK
         IF WS-OK = 1
             MOVE 0 TO WS-N
             PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
                 IF EN-USED(WS-E) = 1 AND EN-DIM(WS-E) = L-DIM
                     CALL "STDMOB-INDEX" USING EN-TYPE(WS-E) WS-S
                     IF WS-S > 0
                         COMPUTE WS-ECX = FUNCTION INTEGER(EN-X(WS-E) / 16)
                         COMPUTE WS-ECZ = FUNCTION INTEGER(EN-Z(WS-E) / 16)
                         IF SM-KIND(WS-S) = SM-KIND(WS-M) AND FUNCTION ABS(WS-ECX - WS-CX) <= SM-CAP-CHUNKS
                                 AND FUNCTION ABS(WS-ECZ - WS-CZ) <= SM-CAP-CHUNKS
                             ADD 1 TO WS-N
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
             IF WS-N >= WS-CAP
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
 END PROGRAM STDMOB-SPAWN-PACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SPAWN-RULE.
*> USING dimension row, x, z, top, r: one pack of animals at the column (STDMOB-SPAWN-PACK, mode 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MODE                BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-R                    BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-DIM L-X L-Z L-TOP L-R.
     CALL "STDMOB-SPAWN-PACK" USING L-DIM L-X L-Z L-TOP L-R WS-MODE
     GOBACK.
 END PROGRAM STDMOB-SPAWN-RULE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SPAWN-HOSTILE.
*> USING dimension row, x, z, top, r: one pack of monsters at the column (STDMOB-SPAWN-PACK, mode 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MODE                BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-R                    BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-DIM L-X L-Z L-TOP L-R.
     CALL "STDMOB-SPAWN-PACK" USING L-DIM L-X L-Z L-TOP L-R WS-MODE
     GOBACK.
 END PROGRAM STDMOB-SPAWN-HOSTILE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SPAWN-TRY.
*> USING dimension row, player row, mode (1 animals, 2 monsters): one attempt around the player (18 sections 6.4 and 6.5 step 2): the column is a hash
*> of the dimension, the player's column, the time and the mode, within 40 blocks per axis, and no nearer than 24 blocks horizontally (a spawn
*> must be above 576 squared distance from the player); it must be in a generated and lit chunk, with its ground the highest non-void block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY STDMOBS.
 01 WS-COUNT               BINARY-LONG VALUE 5.
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
 01 L-MODE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-PLAYER L-MODE.
     COMPUTE WS-ARG(1) = L-DIM - 1
     COMPUTE WS-ARG(2) = FUNCTION INTEGER(PL-X(L-PLAYER))
     COMPUTE WS-ARG(3) = FUNCTION INTEGER(PL-Z(L-PLAYER))
     MOVE CW-TIME TO WS-ARG(4)
     MOVE L-MODE TO WS-ARG(5)
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
     CALL "STDMOB-READY" USING L-DIM WS-CX WS-CZ WS-CHUNK
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
     CALL "STDMOB-SPAWN-PACK" USING L-DIM WS-X WS-Z WS-TOP WS-Q L-MODE
     GOBACK.
 END PROGRAM STDMOB-SPAWN-TRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SPAWN-TICK.
*> No parameters: in a standard world, for each enabled dimension and each alive player in it in player-row order: on ticks with Time mod SM-SPAWN-TICKS
*> = 0 one attempt at animals (the friendly cycle, mode 1), and on ticks with Time mod SM-HOSTILE-TICKS = 0 one attempt at monsters (mode 2) while the
*> difficulty is not Peaceful and the hostile-mobs setting is on (STDMOB-SPAWN-TRY).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY STDMOBS.
 COPY BRWORLD.
 01 WS-D                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 LINKAGE SECTION.
 COPY COREAPI.
 PROCEDURE DIVISION.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     IF CT-OPEN = 0 OR CT-SET-TYPE NOT = CT-TYPE-STANDARD
         GOBACK
     END-IF
     CALL "BR-WORLD-READY"
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > CW-DIM-COUNT
         MOVE CW-DIM(WS-D) TO WS-DIM
         PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS
             IF PL-USED(WS-PLAYER) = 1 AND PL-STATE(WS-PLAYER) = PS-ALIVE AND PL-DIM(WS-PLAYER) = WS-DIM
                 IF FUNCTION MOD(CW-TIME, SM-SPAWN-TICKS) = 0
                     MOVE 1 TO WS-MODE
                     CALL "STDMOB-SPAWN-TRY" USING WS-DIM WS-PLAYER WS-MODE
                 END-IF
                 IF FUNCTION MOD(CW-TIME, SM-HOSTILE-TICKS) = 0 AND BW-DIFFICULTY > 0 AND CS-HOSTILE-MOBS = 1
                     MOVE 2 TO WS-MODE
                     CALL "STDMOB-SPAWN-TRY" USING WS-DIM WS-PLAYER WS-MODE
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM STDMOB-SPAWN-TICK.
