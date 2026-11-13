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
*>   STDMOB-DROPS USING dim, x, y, z, type, killer row    the loot table of the type on the ground (18 section 7.5, 7.6)
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
    05 WS-ID               BINARY-LONG OCCURS 9 TIMES.
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
 PROGRAM-ID. STDMOB-HOSTILE.
*> USING entity type id, hostile out (BINARY-LONG): 1 when the type is a standard mob of the monster kind (SM-KIND 1), else 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-HOSTILE              BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-HOSTILE.
     MOVE 0 TO L-HOSTILE
     CALL "STDMOB-INDEX" USING L-TYPE WS-M
     IF WS-M > 0
         MOVE SM-KIND(WS-M) TO L-HOSTILE
     END-IF
     GOBACK.
 END PROGRAM STDMOB-HOSTILE.

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
*> USING dim, x, y, z (FLOAT-LONG), entity type (BINARY-LONG), the player row that killed it (BINARY-LONG, 0 none): the loot table of the type,
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
 01 L-KILLER               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-TYPE L-KILLER.
     CALL "STDMOB-INDEX" USING L-TYPE WS-M
     MOVE SPACES TO WS-KEY
     STRING "minecraft:entities/" DELIMITED BY SIZE SM-KEY(WS-M) DELIMITED BY SPACE INTO WS-KEY
     INITIALIZE LOOT-CONTEXT
     MOVE 1 TO LC-ORIGIN-SET LC-THIS-SET
     MOVE L-X TO LC-X
     MOVE L-Y TO LC-Y
     MOVE L-Z TO LC-Z
     STRING "minecraft:" DELIMITED BY SIZE SM-KEY(WS-M) DELIMITED BY SPACE INTO LC-THIS-TYPE
     MOVE 0 TO LC-KILLER
     IF L-KILLER > 0
         MOVE 1 TO LC-KILLER
         CALL "STDMOB-LOOTING" USING L-KILLER LC-ATTACKER-SET LC-ATTACKER-ENCH-COUNT LC-AE-ID(1) LC-AE-LEVEL(1)
     END-IF
     MOVE CW-SEED TO LC-WORLD-SEED
     CALL "LOOT-ROLL" USING WS-KEY LOOT-CONTEXT LOOT-RESULT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > LR-COUNT
         CALL "IP-AT-LOCATION" USING L-DIM L-X L-Y L-Z WS-OFFSET LR-ITEM(WS-I) LR-AMOUNT(WS-I) LR-HANDLE(WS-I)
             WS-ITEM-ENTITY
     END-PERFORM
     GOBACK.
 END PROGRAM STDMOB-DROPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-LOOTING.
*> USING player row, attacker set out, enchantment count out, id out, level out (BINARY-LONG): the looting level of the item in the player's
*> main hand (18 section 7.6: the loot functions read it from the killer's weapon). The four outputs are the loot context's attacker fields:
*> set to 1 with one enchantment (looting) when the level is above 0, else all 0 (and the registry lacking looting counts as level 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:looting".
 01 WS-ID                  BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-SET                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-LEVEL                BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-SET L-COUNT L-ID L-LEVEL.
     MOVE 0 TO L-SET L-COUNT L-ID L-LEVEL WS-LEVEL
     CALL "LOOT-ENCH-ID" USING WS-KEY WS-ID
     COMPUTE WS-SLOT = PL-HELD(L-PLAYER) + 1
     IF WS-ID >= 0 AND PL-SLOT-COUNT(L-PLAYER, WS-SLOT) > 0 AND PL-SLOT-VAR(L-PLAYER, WS-SLOT) > 0
         CALL "SP-ENCHANT-LEVEL" USING PL-SLOT-VAR(L-PLAYER, WS-SLOT) WS-ID WS-LEVEL
     END-IF
     IF WS-LEVEL > 0
         MOVE 1 TO L-SET L-COUNT
         MOVE WS-ID TO L-ID
         MOVE WS-LEVEL TO L-LEVEL
     END-IF
     GOBACK.
 END PROGRAM STDMOB-LOOTING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-XP.
*> USING dim, x, y, z (FLOAT-LONG), type, killer player row (BINARY-LONG): the experience of a defeated standard mob (18 section 7.5 dropExperience):
*> only when a player killed it, SM-XP points (an animal, SM-XP 0: 1 + nextInt(3)) as orbs at its position (XP-AWARD). Equipment bonuses and
*> the mob_drops game rule are not modelled yet.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-POINTS              BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 4.
 01 WS-BOUND               BINARY-LONG VALUE 3.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-KILLER               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-TYPE L-KILLER.
     IF L-KILLER > 0
         CALL "STDMOB-INDEX" USING L-TYPE WS-M
         MOVE SM-XP(WS-M) TO WS-POINTS
         IF WS-POINTS = 0
             CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-POINTS
             ADD 1 TO WS-POINTS
         END-IF
         CALL "XP-AWARD" USING L-DIM L-X L-Y L-Z WS-POINTS
     END-IF
     GOBACK.
 END PROGRAM STDMOB-XP.

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
     MOVE EN-KILLER(L-ROW) TO WS-KILLED
     CALL "STDMOB-DROPS" USING WS-DIM WS-X WS-Y WS-Z WS-TYPE WS-KILLED
     CALL "STDMOB-XP" USING WS-DIM WS-X WS-Y WS-Z WS-TYPE WS-KILLED
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
 PROGRAM-ID. STDMOB-AGGRO.
*> USING tracker row, table row of a hostile standard mob: its target for this tick. A neutral-by-day mob (SM-NEUTRAL, the spider, 20 section 7.1) whose cell
*> has light 13 or more (the sky light after the night's darkening or the block light) takes no new target and gives up the one it has with probability
*> 1 / 100 a tick; anywhere darker, and for every other hostile mob, STDMOB-TARGET decides.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-DARK                BINARY-LONG.
 01 WS-LIGHT               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M.
     MOVE 0 TO WS-LIGHT
     IF SM-NEUTRAL(L-M) = 1
         COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
         COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW)) + 1
         COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
         CALL "STDMOB-LIGHTS" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-SKY WS-BLOCK
         CALL "STDMOB-DARKEN" USING CW-TIME WS-DARK
         COMPUTE WS-LIGHT = FUNCTION MAX(WS-BLOCK, WS-SKY - WS-DARK)
     END-IF
     IF WS-LIGHT >= 13
         MOVE EN-ID(L-ROW) TO WS-ARG(1)
         MOVE CW-TIME TO WS-ARG(2)
         MOVE 17 TO WS-ARG(3)
         CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
         IF FUNCTION MOD(WS-R, 100) = 0
             MOVE 0 TO EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW)
         END-IF
     ELSE
         CALL "STDMOB-TARGET" USING L-ROW L-M
     END-IF
     GOBACK.
 END PROGRAM STDMOB-AGGRO.

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
 PROGRAM-ID. STDMOB-HEAD.
*> USING tracker row, table row, dest x, y, z (BINARY-LONG: the cell the mob wants to stand in), hx, hz out (FLOAT-LONG: the horizontal velocity of this tick,
*> blocks per tick), arrived out (BINARY-LONG): how a walking mob moves toward a cell (18 sections 5.2 and 5.5). Every EN-PATH-TICKS ticks (4 + a draw
*> of 0 to 6, +5 when the destination is more than 16 blocks away, +10 when more than 32: the recalculation delay of MeleeAttackGoal in 4.2) and
*> whenever the waypoint is reached, STDMOB-PATH searches a new path from the mob's feet cell (a budget of 100 nodes), and the waypoint EN-WAY-X/-Z
*> becomes the centre of the path's second cell; a path of one cell (the mob is at its closest) or none (no floor, nothing found) sends it straight at the
*> destination. The velocity is the walk speed toward the waypoint. The mob has arrived when it is in the destination cell column.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY STDMOBS.
 01 WS-MX                  BINARY-LONG.
 01 WS-MY                  BINARY-LONG.
 01 WS-MZ                  BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-BUDGET              BINARY-LONG VALUE 100.
 01 WS-COUNT               BINARY-LONG.
 01 WS-REACHED             BINARY-LONG.
 01 WS-PATH-TABLE.
    05 WS-PATH OCCURS 128 TIMES.
       10 WS-PX            BINARY-LONG.
       10 WS-PY            BINARY-LONG.
       10 WS-PZ            BINARY-LONG.
 01 WS-ARGS-COUNT          BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-TYPE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DY                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-ARRIVED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M L-DX L-DY L-DZ L-HX L-HZ L-ARRIVED.
     MOVE 0 TO L-HX L-HZ L-ARRIVED
     COMPUTE WS-MX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-MY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-MZ = FUNCTION INTEGER(EN-Z(L-ROW))
     IF WS-MX = L-DX AND WS-MZ = L-DZ
         MOVE 1 TO L-ARRIVED
         GOBACK
     END-IF
     IF EN-PATH-TICKS(L-ROW) > 0
         SUBTRACT 1 FROM EN-PATH-TICKS(L-ROW)
     END-IF
     COMPUTE WS-DX = EN-WAY-X(L-ROW) - EN-X(L-ROW)
     COMPUTE WS-DZ = EN-WAY-Z(L-ROW) - EN-Z(L-ROW)
     IF EN-WAY-X(L-ROW) = 0 AND EN-WAY-Z(L-ROW) = 0
         MOVE 0 TO EN-PATH-TICKS(L-ROW)
     END-IF
     IF WS-DX * WS-DX + WS-DZ * WS-DZ < 0.2
         MOVE 0 TO EN-PATH-TICKS(L-ROW)
     END-IF
     IF EN-PATH-TICKS(L-ROW) = 0
         MOVE 1 TO WS-HEIGHT
         COMPUTE WS-TYPE = EN-TYPE(L-ROW) + 1
         IF ET-HEIGHT-MILLI(WS-TYPE) > 1000
             MOVE 2 TO WS-HEIGHT
         END-IF
         CALL "STDMOB-PATH" USING EN-DIM(L-ROW) WS-MX WS-MY WS-MZ L-DX L-DY L-DZ WS-HEIGHT WS-BUDGET
             WS-PATH-TABLE WS-COUNT WS-REACHED
         IF WS-COUNT >= 2
             COMPUTE EN-WAY-X(L-ROW) = WS-PX(2) + 0.5
             COMPUTE EN-WAY-Z(L-ROW) = WS-PZ(2) + 0.5
         ELSE
             COMPUTE EN-WAY-X(L-ROW) = L-DX + 0.5
             COMPUTE EN-WAY-Z(L-ROW) = L-DZ + 0.5
         END-IF
         MOVE EN-ID(L-ROW) TO WS-ARG(1)
         MOVE CW-TIME TO WS-ARG(2)
         MOVE 13 TO WS-ARG(3)
         CALL "RNG-HASH" USING WS-ARGS-COUNT WS-ARGS WS-R
         COMPUTE EN-PATH-TICKS(L-ROW) = 4 + FUNCTION MOD(WS-R, 7)
         COMPUTE WS-D2 = (L-DX - WS-MX) ** 2 + (L-DZ - WS-MZ) ** 2
         IF WS-D2 > 1024
             ADD 10 TO EN-PATH-TICKS(L-ROW)
         ELSE
             IF WS-D2 > 256
                 ADD 5 TO EN-PATH-TICKS(L-ROW)
             END-IF
         END-IF
     END-IF
     COMPUTE WS-DX = EN-WAY-X(L-ROW) - EN-X(L-ROW)
     COMPUTE WS-DZ = EN-WAY-Z(L-ROW) - EN-Z(L-ROW)
     COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     IF WS-H > 0.05
         COMPUTE WS-SPEED = SM-WALK-MILLI(L-M) / 1000
         COMPUTE L-HX = WS-SPEED * WS-DX / WS-H
         COMPUTE L-HZ = WS-SPEED * WS-DZ / WS-H
     END-IF
     GOBACK.
 END PROGRAM STDMOB-HEAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SET-ENTITY-DATA-INT-BUILD.
*> USING entity id, entry index, value (BINARY-LONG), PB-BUFFER: Set Entity Data 0x65 with one INT entry (a creeper's swell direction is entry 16, 20 section 6.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 101.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ENTITY-ID            BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY-ID L-INDEX L-VALUE PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ENTITY-ID
     INITIALIZE MD-METADATA-ENTRY
     MOVE L-INDEX TO MD-MD-INDEX
     MOVE MD-MDS-INT TO MD-MD-SERIALIZER
     MOVE L-VALUE TO MD-MD-INT
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     MOVE MD-MD-END TO MD-MD-INDEX
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     GOBACK.
 END PROGRAM SET-ENTITY-DATA-INT-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SWELL.
*> USING tracker row, table row of a mob with a fuse (SM-FUSE above 0: the creeper, 20 section 6.1), stop out (BINARY-LONG): the swell goal. The swell
*> direction is 1 while the swell is above 0 and the target is within 7 blocks (distance squared 49), or from 0 while the target is within 3 blocks
*> (distance squared 9); otherwise -1. The swell moves by the direction (not below 0). A change of direction goes to the viewers (Set Entity Data,
*> entry 16). At the fuse the mob explodes at its position with its blast power (EXPLODE-RUN, source this mob, destroying blocks) and the row is removed
*> without loot or experience. stop out: 0 nothing, 1 the mob stands still (it is swelling), 2 it exploded and the row is gone. The line of sight is
*> not tested yet (open).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-DIR                 BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-INDEX               BINARY-LONG VALUE 16.
 01 WS-POWER               FLOAT-LONG.
 01 WS-DESTROY             BINARY-LONG VALUE 1.
 01 WS-GRIEF-RULE          PIC X(40) VALUE "mob_griefing".
 01 WS-GRIEF               BINARY-DOUBLE.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-STOP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M L-STOP.
     MOVE 0 TO L-STOP
     MOVE -1 TO WS-DIR
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-P > 0
         COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
         COMPUTE WS-DY = PL-Y(WS-P) - EN-Y(L-ROW)
         COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
         COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
         IF (EN-SWELL(L-ROW) > 0 AND WS-D2 <= 49) OR (EN-SWELL(L-ROW) = 0 AND WS-D2 < 9)
             MOVE 1 TO WS-DIR
         END-IF
     END-IF
     ADD WS-DIR TO EN-SWELL(L-ROW)
     IF EN-SWELL(L-ROW) < 0
         MOVE 0 TO EN-SWELL(L-ROW)
     END-IF
     IF WS-DIR NOT = EN-SWELL-DIR(L-ROW) AND NOT (EN-SWELL-DIR(L-ROW) = 0 AND WS-DIR = -1)
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "SET-ENTITY-DATA-INT-BUILD" USING EN-ID(L-ROW) WS-INDEX WS-DIR PB-BUFFER
         CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
         CALL "PB-FREE" USING PB-BUFFER
     END-IF
     MOVE WS-DIR TO EN-SWELL-DIR(L-ROW)
     IF EN-SWELL(L-ROW) >= SM-FUSE(L-M)
         MOVE EN-DIM(L-ROW) TO WS-DIM
         MOVE EN-X(L-ROW) TO WS-X
         MOVE EN-Y(L-ROW) TO WS-Y
         MOVE EN-Z(L-ROW) TO WS-Z
         MOVE SM-BLAST(L-M) TO WS-POWER
         MOVE L-ROW TO WS-ROW
         CALL "BR-RULE-GET" USING WS-GRIEF-RULE WS-GRIEF
         MOVE WS-GRIEF TO WS-DESTROY
         CALL "EXPLODE-RUN" USING WS-DIM WS-X WS-Y WS-Z WS-POWER WS-DESTROY WS-ROW
         CALL "ENTITY-REMOVE" USING L-ROW
         MOVE 2 TO L-STOP
         GOBACK
     END-IF
     IF EN-SWELL(L-ROW) > 0
         MOVE 1 TO L-STOP
     END-IF
     GOBACK.
 END PROGRAM STDMOB-SWELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-STEP.
*> USING tracker row: nothing for a row that is no standard mob. A hostile mob is removed while the difficulty is Peaceful or the hostile-mobs
*> setting is off. A dying mob (health 0) counts its death ticks (EN-COOLDOWN) and vanishes at the 20th (STDMOB-VANISH). Nothing else happens in a
*> chunk that is not generated and lit (STDMOB-READY). Otherwise the hurt window counts down and:
*> - a hostile mob burns in daylight (STDMOB-BURN), keeps a target (STDMOB-TARGET), counts its attack timer down (EN-COOLDOWN), walks toward the
*>   target at the walk speed until its box is within the melee reach, and with the timer at 0 and the target in reach hits it (HEALTH-MOB-HIT, the
*>   attack damage of the row), the timer becoming SM-ATTACK-TICKS; with no target it strolls like the animals;
*> - a mob that was hit panics (EN-FLEE ticks left, away from the attacker at the panic speed);
*> - otherwise a standing mob (EN-COOLDOWN 0) starts a stroll with probability 1 / SM-STROLL-ODDS on a tick (hash of the entity id and the time):
*>   it picks a cell up to 10 blocks away on each axis (RandomStrollGoal: 10 horizontally; EN-DEST-X/-Z), and walks to it by STDMOB-HEAD for at most
*>   SM-STROLL-TICKS ticks (EN-COOLDOWN = the ticks left) or until it is in the cell;
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
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-ARRIVED             BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
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
         CALL "STDMOB-AGGRO" USING WS-ROW WS-M
         IF EN-COOLDOWN(WS-ROW) > 0
             SUBTRACT 1 FROM EN-COOLDOWN(WS-ROW)
         END-IF
         IF EN-TARGET(WS-ROW) > 0
             MOVE 1 TO WS-CHASE
         END-IF
     END-IF
     MOVE 0 TO WS-STOP
     IF SM-FUSE(WS-M) > 0
         CALL "STDMOB-SWELL" USING WS-ROW WS-M WS-STOP
         IF WS-STOP = 2
             GOBACK
         END-IF
     END-IF
     IF SM-RANGED(WS-M) > 0
         CALL "STDMOB-SHOOT" USING WS-ROW WS-M WS-STOP
     END-IF
     EVALUATE TRUE
         WHEN WS-STOP = 1
*>           A swelling creeper stands still, facing its target.
             MOVE EN-TARGET(WS-ROW) TO WS-P
             COMPUTE WS-DX = PL-X(WS-P) - EN-X(WS-ROW)
             COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(WS-ROW)
             CALL "MOB-YAW-TOWARD" USING WS-DX WS-DZ WS-YAW
         WHEN WS-CHASE = 1
             MOVE EN-TARGET(WS-ROW) TO WS-P
             COMPUTE WS-DX = PL-X(WS-P) - EN-X(WS-ROW)
             COMPUTE WS-DY = PL-Y(WS-P) - EN-Y(WS-ROW)
             COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(WS-ROW)
             CALL "MOB-YAW-TOWARD" USING WS-DX WS-DZ WS-YAW
             COMPUTE WS-REACH = SM-REACH-MILLI / 1000
             IF FUNCTION ABS(WS-DX) > WS-REACH OR FUNCTION ABS(WS-DZ) > WS-REACH
                 COMPUTE WS-GX = FUNCTION INTEGER(PL-X(WS-P))
                 COMPUTE WS-GY = FUNCTION INTEGER(PL-Y(WS-P))
                 COMPUTE WS-GZ = FUNCTION INTEGER(PL-Z(WS-P))
                 CALL "STDMOB-HEAD" USING WS-ROW WS-M WS-GX WS-GY WS-GZ WS-HX WS-HZ WS-ARRIVED
             END-IF
             IF SM-FUSE(WS-M) = 0 AND SM-RANGED(WS-M) = 0 AND EN-COOLDOWN(WS-ROW) = 0 AND FUNCTION ABS(WS-DX) <= WS-REACH
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
                     COMPUTE EN-DEST-X(WS-ROW) = FUNCTION INTEGER(EN-X(WS-ROW)) + FUNCTION MOD(WS-Q, 21) - 10
                     COMPUTE WS-Q = WS-Q / 21
                     COMPUTE EN-DEST-Z(WS-ROW) = FUNCTION INTEGER(EN-Z(WS-ROW)) + FUNCTION MOD(WS-Q, 21) - 10
                     MOVE SM-STROLL-TICKS TO EN-COOLDOWN(WS-ROW)
                     MOVE 0 TO EN-PATH-TICKS(WS-ROW) EN-WAY-X(WS-ROW) EN-WAY-Z(WS-ROW)
                 END-IF
             END-IF
             IF EN-COOLDOWN(WS-ROW) > 0
                 SUBTRACT 1 FROM EN-COOLDOWN(WS-ROW)
                 COMPUTE WS-GY = FUNCTION INTEGER(EN-Y(WS-ROW))
                 CALL "STDMOB-HEAD" USING WS-ROW WS-M EN-DEST-X(WS-ROW) WS-GY EN-DEST-Z(WS-ROW) WS-HX WS-HZ
                     WS-ARRIVED
                 IF WS-ARRIVED = 1
                     MOVE 0 TO EN-COOLDOWN(WS-ROW)
                 END-IF
                 CALL "MOB-YAW-TOWARD" USING WS-HX WS-HZ WS-YAW
             END-IF
     END-EVALUATE
*>   The push of an explosion (EN-VX, EN-VZ; EN-VY is the vertical speed itself) adds to the walk and decays by 0.546 a tick on the ground, 0.91 in the air.
     COMPUTE WS-HX = WS-HX + EN-VX(WS-ROW)
     COMPUTE WS-HZ = WS-HZ + EN-VZ(WS-ROW)
     IF EN-ON-GROUND(WS-ROW) = 1
         COMPUTE EN-VX(WS-ROW) = EN-VX(WS-ROW) * 0.546
         COMPUTE EN-VZ(WS-ROW) = EN-VZ(WS-ROW) * 0.546
     ELSE
         COMPUTE EN-VX(WS-ROW) = EN-VX(WS-ROW) * 0.91
         COMPUTE EN-VZ(WS-ROW) = EN-VZ(WS-ROW) * 0.91
     END-IF
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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-CELL.
*> USING dim, x, y, z (BINARY-LONG), type out (BINARY-LONG): what a walking mob meets in a cell: 0 passable (air or a block without collision), 1 solid
*> (CB-SOLID), 2 hazard (water, lava or fire: a land mob does not path through it; 18 section 5.1 gives liquids a malus that keeps a land mob out). A cell
*> outside the dimension's height reads as passable air above and solid below.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY DIMENSIONS.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-TYPE.
     MOVE 0 TO L-TYPE
     IF L-Y < DM-MIN-Y(L-DIM)
         MOVE 1 TO L-TYPE
         GOBACK
     END-IF
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     IF WS-STATE = 0
         GOBACK
     END-IF
     COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
     IF CB-SOLID(WS-BLOCK) = 1
         MOVE 1 TO L-TYPE
         GOBACK
     END-IF
     MOVE 0 TO WS-N
     INSPECT CB-KEY(WS-BLOCK) TALLYING WS-N FOR ALL "water" ALL "lava" ALL "fire"
     IF WS-N > 0
         MOVE 2 TO L-TYPE
     END-IF
     GOBACK.
 END PROGRAM STDMOB-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-STANDABLE.
*> USING dim, x, y, z, height (cells the mob needs, 1 or 2), ok out (BINARY-LONG): 1 when a mob can stand with its feet in the cell: the cell (and, for a
*> height of 2, the one above it) is passable and the cell below is solid.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-HEIGHT L-OK.
     MOVE 0 TO L-OK
     CALL "STDMOB-CELL" USING L-DIM L-X L-Y L-Z WS-TYPE
     IF WS-TYPE NOT = 0
         GOBACK
     END-IF
     IF L-HEIGHT > 1
         COMPUTE WS-Y = L-Y + 1
         CALL "STDMOB-CELL" USING L-DIM L-X WS-Y L-Z WS-TYPE
         IF WS-TYPE NOT = 0
             GOBACK
         END-IF
     END-IF
     COMPUTE WS-Y = L-Y - 1
     CALL "STDMOB-CELL" USING L-DIM L-X WS-Y L-Z WS-TYPE
     IF WS-TYPE = 1
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM STDMOB-STANDABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-PATH.
*> USING dim, start x, y, z, target x, y, z (BINARY-LONG feet cells), height (1 or 2), budget (BINARY-LONG: nodes it may expand), path (128 x, y, z cells),
*> count out (cells in the path, start first; 0 = no path), reached out (1 when the last cell is the target).
*> The weighted A* of 18 section 5.2 over the walk neighbours of 5.3, simplified: a node is a standable feet cell (STDMOB-STANDABLE); its neighbours
*> are the four horizontal ones, the same level when standable, one up when the cell ahead is solid and standable above it with head room
*> over the current cell, and down by 1 to 3 when the cell ahead is passable with no floor; no diagonals. Step cost sqrt(1 + dy squared), heuristic 1.5 x
*> the Euclidean distance to the target, nodes never farther than 15 blocks horizontally from the start or 8 below / 15 above it. The search pops
*> the open node of the least f at most `budget` times; it ends at the target, or when the open set is empty or the budget used, with the path to
*> the node that came closest (the least heuristic). A start that is not standable moves down to a floor within 3 cells, else there is no path.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NODES.
    05 WS-NODE OCCURS 1024 TIMES.
       10 WN-X             BINARY-LONG.
       10 WN-Y             BINARY-LONG.
       10 WN-Z             BINARY-LONG.
       10 WN-G             FLOAT-LONG.
       10 WN-F             FLOAT-LONG.
       10 WN-H             FLOAT-LONG.
       10 WN-PARENT        BINARY-LONG.
       10 WN-STATE         BINARY-LONG.
 01 WS-GRID-TABLE.
    05 WS-GRID             BINARY-LONG OCCURS 24576 TIMES.
 01 WS-NODE-COUNT          BINARY-LONG.
 01 WS-POPPED              BINARY-LONG.
 01 WS-CUR                 BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-CAND                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-LEAST               FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-TENT                FLOAT-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-CHAIN.
    05 WS-LINK             BINARY-LONG OCCURS 1024 TIMES.
 01 WS-DIRX-DATA.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
 01 WS-DIRX REDEFINES WS-DIRX-DATA.
    05 WS-DX-OF            BINARY-LONG OCCURS 4 TIMES.
 01 WS-DIRZ-DATA.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE -1.
 01 WS-DIRZ REDEFINES WS-DIRZ-DATA.
    05 WS-DZ-OF            BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-TX                   BINARY-LONG.
 01 L-TY                   BINARY-LONG.
 01 L-TZ                   BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-BUDGET               BINARY-LONG.
 01 L-PATH.
    05 L-CELL OCCURS 128 TIMES.
       10 L-PX             BINARY-LONG.
       10 L-PY             BINARY-LONG.
       10 L-PZ             BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-REACHED              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-SX L-SY L-SZ L-TX L-TY L-TZ L-HEIGHT L-BUDGET L-PATH L-COUNT L-REACHED.
     MOVE 0 TO L-COUNT L-REACHED
     MOVE L-SY TO WS-NY
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 3 OR WS-FOUND = 1
         COMPUTE WS-Y = L-SY - WS-D
         CALL "STDMOB-STANDABLE" USING L-DIM L-SX WS-Y L-SZ L-HEIGHT WS-OK
         IF WS-OK = 1
             MOVE WS-Y TO WS-NY
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     IF WS-FOUND = 0
         GOBACK
     END-IF
     INITIALIZE WS-GRID-TABLE
     MOVE 1 TO WS-NODE-COUNT
     MOVE L-SX TO WN-X(1)
     MOVE WS-NY TO WN-Y(1)
     MOVE L-SZ TO WN-Z(1)
     MOVE 0 TO WN-G(1) WN-PARENT(1) WN-STATE(1)
     COMPUTE WS-DX = WN-X(1) - L-TX
     COMPUTE WS-DY = WN-Y(1) - L-TY
     COMPUTE WS-DZ = WN-Z(1) - L-TZ
     COMPUTE WN-H(1) = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
     COMPUTE WN-F(1) = 1.5 * WN-H(1)
     MOVE 1 TO WS-GRID(((16 * 32) + 16) * 24 + 8 + 1)
     MOVE 1 TO WS-BEST
     MOVE WN-H(1) TO WS-LEAST
     MOVE 0 TO WS-POPPED WS-DONE
     PERFORM UNTIL WS-DONE = 1
         MOVE 0 TO WS-CUR
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-NODE-COUNT
             IF WN-STATE(WS-I) = 0 AND (WS-CUR = 0 OR WN-F(WS-I) < WN-F(WS-CUR))
                 MOVE WS-I TO WS-CUR
             END-IF
         END-PERFORM
         IF WS-CUR = 0 OR WS-POPPED >= L-BUDGET
             MOVE 1 TO WS-DONE
         ELSE
             ADD 1 TO WS-POPPED
             MOVE 1 TO WN-STATE(WS-CUR)
             IF WN-X(WS-CUR) = L-TX AND WN-Y(WS-CUR) = L-TY AND WN-Z(WS-CUR) = L-TZ
                 MOVE WS-CUR TO WS-BEST
                 MOVE 1 TO L-REACHED
                 MOVE 1 TO WS-DONE
             ELSE
                 PERFORM VARYING WS-DIR FROM 1 BY 1 UNTIL WS-DIR > 4
                     COMPUTE WS-NX = WN-X(WS-CUR) + WS-DX-OF(WS-DIR)
                     COMPUTE WS-NZ = WN-Z(WS-CUR) + WS-DZ-OF(WS-DIR)
                     MOVE -1000 TO WS-CAND
                     MOVE WN-Y(WS-CUR) TO WS-Y
                     CALL "STDMOB-STANDABLE" USING L-DIM WS-NX WS-Y WS-NZ L-HEIGHT WS-OK
                     IF WS-OK = 1
                         MOVE WS-Y TO WS-CAND
                     ELSE
                         CALL "STDMOB-CELL" USING L-DIM WS-NX WS-Y WS-NZ WS-TYPE
                         EVALUATE WS-TYPE
                             WHEN 1
                                 COMPUTE WS-NY = WN-Y(WS-CUR) + 1
                                 COMPUTE WS-Y = WN-Y(WS-CUR) + L-HEIGHT
                                 CALL "STDMOB-CELL" USING L-DIM WN-X(WS-CUR) WS-Y WN-Z(WS-CUR) WS-TYPE
                                 IF WS-TYPE = 0
                                     CALL "STDMOB-STANDABLE" USING L-DIM WS-NX WS-NY WS-NZ L-HEIGHT WS-OK
                                     IF WS-OK = 1
                                         MOVE WS-NY TO WS-CAND
                                     END-IF
                                 END-IF
                             WHEN 0
                                 MOVE 0 TO WS-FOUND
                                 PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 3 OR WS-FOUND = 1
                                     COMPUTE WS-NY = WN-Y(WS-CUR) - WS-D
                                     CALL "STDMOB-STANDABLE" USING L-DIM WS-NX WS-NY WS-NZ L-HEIGHT WS-OK
                                     IF WS-OK = 1
                                         MOVE WS-NY TO WS-CAND
                                         MOVE 1 TO WS-FOUND
                                     ELSE
                                         CALL "STDMOB-CELL" USING L-DIM WS-NX WS-NY WS-NZ WS-TYPE
                                         IF WS-TYPE NOT = 0
                                             MOVE 1 TO WS-FOUND
                                         END-IF
                                     END-IF
                                 END-PERFORM
                         END-EVALUATE
                     END-IF
                     IF WS-CAND > -1000
                         COMPUTE WS-GX = WS-NX - L-SX + 16
                         COMPUTE WS-GZ = WS-NZ - L-SZ + 16
                         COMPUTE WS-GY = WS-CAND - WN-Y(1) + 8
                         IF WS-GX >= 0 AND WS-GX < 32 AND WS-GZ >= 0 AND WS-GZ < 32 AND WS-GY >= 0 AND WS-GY < 24
                             COMPUTE WS-KEY = (WS-GX * 32 + WS-GZ) * 24 + WS-GY + 1
                             COMPUTE WS-DY = WS-CAND - WN-Y(WS-CUR)
                             COMPUTE WS-TENT = WN-G(WS-CUR) + FUNCTION SQRT(1 + WS-DY * WS-DY)
                             IF WS-GRID(WS-KEY) = 0
                                 IF WS-NODE-COUNT < 1024
                                     ADD 1 TO WS-NODE-COUNT
                                     MOVE WS-NODE-COUNT TO WS-GRID(WS-KEY)
                                     MOVE WS-NX TO WN-X(WS-NODE-COUNT)
                                     MOVE WS-CAND TO WN-Y(WS-NODE-COUNT)
                                     MOVE WS-NZ TO WN-Z(WS-NODE-COUNT)
                                     MOVE WS-TENT TO WN-G(WS-NODE-COUNT)
                                     MOVE WS-CUR TO WN-PARENT(WS-NODE-COUNT)
                                     MOVE 0 TO WN-STATE(WS-NODE-COUNT)
                                     COMPUTE WS-DX = WS-NX - L-TX
                                     COMPUTE WS-DY = WS-CAND - L-TY
                                     COMPUTE WS-DZ = WS-NZ - L-TZ
                                     COMPUTE WN-H(WS-NODE-COUNT) = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
                                     COMPUTE WN-F(WS-NODE-COUNT) = WS-TENT + 1.5 * WN-H(WS-NODE-COUNT)
                                     IF WN-H(WS-NODE-COUNT) < WS-LEAST
                                         MOVE WN-H(WS-NODE-COUNT) TO WS-LEAST
                                         MOVE WS-NODE-COUNT TO WS-BEST
                                     END-IF
                                 END-IF
                             ELSE
                                 MOVE WS-GRID(WS-KEY) TO WS-I
                                 IF WN-STATE(WS-I) = 0 AND WS-TENT < WN-G(WS-I)
                                     MOVE WS-TENT TO WN-G(WS-I)
                                     MOVE WS-CUR TO WN-PARENT(WS-I)
                                     COMPUTE WN-F(WS-I) = WS-TENT + 1.5 * WN-H(WS-I)
                                 END-IF
                             END-IF
                         END-IF
                     END-IF
                 END-PERFORM
             END-IF
         END-IF
     END-PERFORM
*>   The path: the chain of parents from the best node to the start, reversed.
     MOVE 0 TO WS-LEN
     MOVE WS-BEST TO WS-CUR
     PERFORM UNTIL WS-CUR = 0
         ADD 1 TO WS-LEN
         MOVE WS-CUR TO WS-LINK(WS-LEN)
         MOVE WN-PARENT(WS-CUR) TO WS-CUR
     END-PERFORM
     MOVE 0 TO L-COUNT
     PERFORM VARYING WS-I FROM WS-LEN BY -1 UNTIL WS-I < 1 OR L-COUNT >= 128
         ADD 1 TO L-COUNT
         MOVE WN-X(WS-LINK(WS-I)) TO L-PX(L-COUNT)
         MOVE WN-Y(WS-LINK(WS-I)) TO L-PY(L-COUNT)
         MOVE WN-Z(WS-LINK(WS-I)) TO L-PZ(L-COUNT)
     END-PERFORM
     GOBACK.
 END PROGRAM STDMOB-PATH.
