*> Leashing (docs/protocol/18-mob-framework.md section 8.3, 05b 0x66 Set Entity Link, 17 section 3.7). EN-LEASH is the player row that holds the lead of a mob (0 none).
*> A fence knot (24 section 6.3, 21 section 8.15): a leash_knot entity at the block + (0.5, 0.375, 0.5); a mob held by it has EN-LEASH-KNOT = the knot's entity row (EN-LEASH 0).
*>   MOB-KNOT-TYPE USING type out                                  entity type id of leash_knot (looked up once)
*>   MOB-KNOT-FIND USING dim, x, y, z, row out                      the knot at that block (0 none)
*>   MOB-KNOT-GET USING dim, x, y, z, row out, created out          the knot at that block, made when absent
*>   MOB-KNOT-FREE USING knot row                                   the knot discards itself when no mob is held by it (notifyLeasheeRemoved)
*>   MOB-KNOT-USE USING player row, x, y, z, ok out                 LeadItem.bindPlayerMobs: the player's mobs within 16 of the block go to the knot
*>   MOB-KNOT-INTERACT USING player row, knot row, sneaking, ok out the interact of the knot: to the knot, else (not sneaking) back to the player
*> Open items: the lead on a boat or a mob that is not a passive creature other than the list below, the closeRange walk toward
*> the holder (PathfinderMob.closeRangeLeashBehaviour), the home set by whenLeashedTo, the angular momentum and the holder-motion term of the spring, the entity_drops game rule, the
*> exact list of leashable species (doc 18 gives only the rule and fish/squid/dolphin in 21 section 4), the creative-mode lead refund, and the Set Entity Link detach value:
*> 05b says "presumably 0 or -1", this server sends 0.
*>   MOB-LEASHABLE USING row, ok            1 for a passive creature or a squid, glow squid or dolphin (canBeLeashed)
*>   MOB-LEASH-DIST USING row, holder row, distance out   between the centres of the two bounding boxes (leashDistanceTo)
*>   MOB-LEASH-LINK USING row, destination id             Set Entity Link to the viewers of the mob
*>   MOB-LEASH-ATTACH USING player row, mob row, ok       canHaveALeashAttachedTo then setLeashedTo
*>   MOB-LEASH-DROP USING mob row                         dropLeash: the lead item at the mob, the link cleared
*>   MOB-LEASH-PAIR USING player row, mob row             Set Entity Link to one player that starts tracking the mob
*>   MOB-LEASH-USE USING player row, mob row, held key, handled out   the lead item and the holder's interact
*>   MOB-LEASH-TICK USING mob row                         Leashable.tickLeash: break, elastic pull

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-LEASHABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-OK.
     MOVE 0 TO L-OK
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M > 0
         IF SM-KIND(WS-M) = 0 OR SM-KEY(WS-M) = "squid" OR "glow_squid" OR "dolphin"
             MOVE 1 TO L-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOB-LEASHABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-LEASH-DIST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HOLDER               BINARY-LONG.
 01 L-DISTANCE             FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-HOLDER L-DISTANCE.
     MOVE PL-X(L-HOLDER) TO WS-PX
     COMPUTE WS-PY = PL-Y(L-HOLDER) + 0.9
     MOVE PL-Z(L-HOLDER) TO WS-PZ
     CALL "MOB-LEASH-DIST-PT" USING L-ROW WS-PX WS-PY WS-PZ L-DISTANCE
     GOBACK.
 END PROGRAM MOB-LEASH-DIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-LEASH-DIST-PT.
*> USING mob row, holder point x, y, z (the centre of the holder's box), distance out: leashDistanceTo.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-TYPE                BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-DISTANCE             FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-DISTANCE.
     COMPUTE WS-TYPE = EN-TYPE(L-ROW) + 1
     COMPUTE WS-DX = L-X - EN-X(L-ROW)
     COMPUTE WS-DY = L-Y - (EN-Y(L-ROW) + ET-HEIGHT-MILLI(WS-TYPE) / 2000)
     COMPUTE WS-DZ = L-Z - EN-Z(L-ROW)
     COMPUTE L-DISTANCE = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
     GOBACK.
 END PROGRAM MOB-LEASH-DIST-PT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-LEASH-LINK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-PACKET-ID           BINARY-LONG VALUE 102.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DEST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DEST.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-INT" USING PB-BUFFER EN-ID(L-ROW)
     CALL "PB-PUT-INT" USING PB-BUFFER L-DEST
     CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM MOB-LEASH-LINK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-LEASH-ATTACH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-LEASHABLE           BINARY-LONG.
 01 WS-DISTANCE            FLOAT-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ROW L-OK.
     MOVE 0 TO L-OK
     CALL "MOB-LEASHABLE" USING L-ROW WS-LEASHABLE
     IF WS-LEASHABLE = 1 AND EN-LEASH(L-ROW) = 0 AND EN-LEASH-KNOT(L-ROW) = 0 AND EN-DIM(L-ROW) = PL-DIM(L-PLAYER)
         CALL "MOB-LEASH-DIST" USING L-ROW L-PLAYER WS-DISTANCE
         IF WS-DISTANCE <= 12
             MOVE L-PLAYER TO EN-LEASH(L-ROW)
             MOVE 1 TO L-OK
             CALL "MOB-LEASH-LINK" USING L-ROW PL-ENTITY-ID(L-PLAYER)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOB-LEASH-ATTACH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-LEASH-DROP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-ITEM-KEY            PIC X(112) VALUE "minecraft:lead".
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-OFFSET              FLOAT-LONG VALUE 0.
 01 WS-DROPPED             BINARY-LONG.
 01 WS-KNOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE EN-LEASH-KNOT(L-ROW) TO WS-KNOT
     MOVE 0 TO EN-LEASH(L-ROW) EN-LEASH-KNOT(L-ROW)
     CALL "MOB-LEASH-LINK" USING L-ROW WS-NONE
     IF WS-KNOT > 0
         CALL "MOB-KNOT-FREE" USING WS-KNOT
     END-IF
     CALL "CONTENT-ITEM-BY-KEY" USING WS-ITEM-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     CALL "IP-AT-LOCATION" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-OFFSET WS-ITEM WS-ONE
         WS-NONE WS-DROPPED
     GOBACK.
 END PROGRAM MOB-LEASH-DROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-LEASH-PAIR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-PACKET-ID           BINARY-LONG VALUE 102.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ROW.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-INT" USING PB-BUFFER EN-ID(L-ROW)
     IF EN-LEASH-KNOT(L-ROW) > 0
         CALL "PB-PUT-INT" USING PB-BUFFER EN-ID(EN-LEASH-KNOT(L-ROW))
     ELSE
         CALL "PB-PUT-INT" USING PB-BUFFER PL-ENTITY-ID(EN-LEASH(L-ROW))
     END-IF
     CALL "CORE-SEND" USING PL-CONN(L-PLAYER) PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM MOB-LEASH-PAIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-LEASH-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-HELD                 PIC X(24).
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ROW L-HELD L-HANDLED.
     MOVE 0 TO L-HANDLED
     EVALUATE TRUE
         WHEN EN-LEASH(L-ROW) = L-PLAYER
             CALL "MOB-LEASH-DROP" USING L-ROW
             MOVE 1 TO L-HANDLED
         WHEN L-HELD = "lead" AND EN-LEASH(L-ROW) = 0 AND EN-LEASH-KNOT(L-ROW) = 0
             CALL "MOB-LEASH-ATTACH" USING L-PLAYER L-ROW WS-OK
             IF WS-OK = 1
                 CALL "MOB-TAKE" USING L-PLAYER
                 MOVE 1 TO L-HANDLED
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM MOB-LEASH-USE.


 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-KNOT-TYPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:leash_knot".
 01 WS-ROW                 PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG VALUE -1.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE.
     IF WS-TYPE < 0
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW WS-STATUS
     END-IF
     MOVE WS-TYPE TO L-TYPE
     GOBACK.
 END PROGRAM MOB-KNOT-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-KNOT-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-TYPE                BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ROW.
     MOVE 0 TO L-ROW
     CALL "MOB-KNOT-TYPE" USING WS-TYPE
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR L-ROW > 0
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-TYPE AND EN-DIM(WS-E) = L-DIM
             COMPUTE WS-BX = FUNCTION INTEGER(EN-X(WS-E))
             COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(WS-E))
             COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(WS-E))
             IF WS-BX = L-X AND WS-BY = L-Y AND WS-BZ = L-Z
                 MOVE WS-E TO L-ROW
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MOB-KNOT-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-KNOT-GET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-CREATED              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-BX L-BY L-BZ L-ROW L-CREATED.
     MOVE 0 TO L-CREATED
     CALL "MOB-KNOT-FIND" USING L-DIM L-BX L-BY L-BZ L-ROW
     IF L-ROW = 0
         CALL "MOB-KNOT-TYPE" USING WS-TYPE
         COMPUTE WS-X = L-BX + 0.5
         COMPUTE WS-Y = L-BY + 0.375
         COMPUTE WS-Z = L-BZ + 0.5
         CALL "MOB-SPAWN" USING L-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW L-ROW
         MOVE 1 TO L-CREATED
     END-IF
     GOBACK.
 END PROGRAM MOB-KNOT-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-KNOT-FREE.
*> USING knot row: the knot is discarded when no mob is held by it any longer.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-TYPE                BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "MOB-KNOT-TYPE" USING WS-TYPE
     IF L-ROW > 0 AND EN-USED(L-ROW) = 1 AND EN-TYPE(L-ROW) = WS-TYPE
         MOVE 0 TO WS-HELD
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF EN-USED(WS-E) = 1 AND EN-LEASH-KNOT(WS-E) = L-ROW
                 ADD 1 TO WS-HELD
             END-IF
         END-PERFORM
         IF WS-HELD = 0
             CALL "ENTITY-REMOVE" USING L-ROW
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOB-KNOT-FREE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-KNOT-VALID.
*> USING knot row, mob row, ok out: the knot is a used leash_knot row in the mob's dimension and the block at its position is in the block tag fences.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:fences".
 01 WS-TYPE                BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TAGGED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KNOT                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KNOT L-ROW L-OK.
     MOVE 0 TO L-OK
     CALL "MOB-KNOT-TYPE" USING WS-TYPE
     IF L-KNOT > 0 AND EN-USED(L-KNOT) = 1 AND EN-TYPE(L-KNOT) = WS-TYPE AND EN-DIM(L-KNOT) = EN-DIM(L-ROW)
         COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-KNOT))
         COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-KNOT))
         COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-KNOT))
         CALL "WORLD-GET-BLOCK" USING EN-DIM(L-KNOT) WS-BX WS-BY WS-BZ WS-STATE
         MOVE 0 TO WS-TAGGED
         IF WS-STATE > 0
             MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
             CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-BLOCK WS-TAGGED
         END-IF
         MOVE WS-TAGGED TO L-OK
     END-IF
     GOBACK.
 END PROGRAM MOB-KNOT-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-KNOT-USE.
*> USING player row, block x, y, z, ok out: LeadItem.bindPlayerMobs. Every mob held by this player whose box is within the cube of side 32 round the block centre and
*> that can have the knot as its holder (within 12 blocks of it) is held by the knot (made when absent); ok is 1 when one was bound.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-E                   BINARY-LONG.
 01 WS-KNOT                BINARY-LONG VALUE 0.
 01 WS-CREATED             BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-DISTANCE            FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-X L-Y L-Z L-OK.
     MOVE 0 TO L-OK WS-KNOT
     COMPUTE WS-PX = L-X + 0.5
     COMPUTE WS-PY = L-Y + 0.375
     COMPUTE WS-PZ = L-Z + 0.5
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-LEASH(WS-E) = L-PLAYER AND EN-DIM(WS-E) = PL-DIM(L-PLAYER)
             COMPUTE WS-DX = EN-X(WS-E) - (L-X + 0.5)
             COMPUTE WS-DY = EN-Y(WS-E) - (L-Y + 0.5)
             COMPUTE WS-DZ = EN-Z(WS-E) - (L-Z + 0.5)
             CALL "MOB-LEASH-DIST-PT" USING WS-E WS-PX WS-PY WS-PZ WS-DISTANCE
             IF FUNCTION ABS(WS-DX) <= 16 AND FUNCTION ABS(WS-DY) <= 16 AND FUNCTION ABS(WS-DZ) <= 16 AND WS-DISTANCE <= 12
                 IF WS-KNOT = 0
                     CALL "MOB-KNOT-GET" USING PL-DIM(L-PLAYER) L-X L-Y L-Z WS-KNOT WS-CREATED
                 END-IF
                 MOVE 0 TO EN-LEASH(WS-E)
                 MOVE WS-KNOT TO EN-LEASH-KNOT(WS-E)
                 CALL "MOB-LEASH-LINK" USING WS-E EN-ID(WS-KNOT)
                 MOVE 1 TO L-OK
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MOB-KNOT-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-KNOT-INTERACT.
*> USING player row, knot row, sneaking, ok out (21 section 8.15): the mobs the player holds go to the knot; when none did and the player is not sneaking, the mobs the
*> knot holds go back to the player (those within 12 blocks of it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-E                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-DISTANCE            FLOAT-LONG.
 01 WS-EV-ACTION           PIC X(32) VALUE "entity_action".
 01 WS-NO-STATE            BINARY-LONG VALUE -1.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-KNOT                 BINARY-LONG.
 01 L-SNEAK                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-KNOT L-SNEAK L-OK.
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-KNOT))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-KNOT))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-KNOT))
     CALL "MOB-KNOT-USE" USING L-PLAYER WS-BX WS-BY WS-BZ L-OK
*>   Entity.interact: the player tied the mobs it held to the knot: entity_action at the knot's block centre, the player as the source (30-8 14.3.7)
     IF L-OK = 1
         CALL "GAME-EVENT-CELL" USING EN-DIM(L-KNOT) WS-BX WS-BY WS-BZ WS-EV-ACTION PL-ENTITY-ROW(L-PLAYER) WS-NO-STATE
     END-IF
     IF L-OK = 0 AND L-SNEAK = 0
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF EN-USED(WS-E) = 1 AND EN-LEASH-KNOT(WS-E) = L-KNOT
                 CALL "MOB-LEASH-DIST" USING WS-E L-PLAYER WS-DISTANCE
                 IF WS-DISTANCE <= 12
                     MOVE L-PLAYER TO EN-LEASH(WS-E)
                     MOVE 0 TO EN-LEASH-KNOT(WS-E)
                     CALL "MOB-LEASH-LINK" USING WS-E PL-ENTITY-ID(L-PLAYER)
                     MOVE 1 TO L-OK
                 END-IF
             END-IF
         END-PERFORM
         CALL "MOB-KNOT-FREE" USING L-KNOT
     END-IF
     GOBACK.
 END PROGRAM MOB-KNOT-INTERACT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-LEASH-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-HOLDER              BINARY-LONG.
 01 WS-KNOT                BINARY-LONG.
 01 WS-HOK                 BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HY                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-DISTANCE            FLOAT-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-SCALE               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE EN-LEASH(L-ROW) TO WS-HOLDER
     MOVE EN-LEASH-KNOT(L-ROW) TO WS-KNOT
*>   The holder point: the knot's position, or the player's eyes-to-feet midpoint (feet + 0.9).
     MOVE 0 TO WS-HOK
     EVALUATE TRUE
         WHEN WS-KNOT > 0
             CALL "MOB-KNOT-VALID" USING WS-KNOT L-ROW WS-HOK
             MOVE EN-X(WS-KNOT) TO WS-HX
             MOVE EN-Y(WS-KNOT) TO WS-HY
             MOVE EN-Z(WS-KNOT) TO WS-HZ
         WHEN PL-USED(WS-HOLDER) = 1 AND PL-DIM(WS-HOLDER) = EN-DIM(L-ROW)
             MOVE 1 TO WS-HOK
             MOVE PL-X(WS-HOLDER) TO WS-HX
             COMPUTE WS-HY = PL-Y(WS-HOLDER) + 0.9
             MOVE PL-Z(WS-HOLDER) TO WS-HZ
     END-EVALUATE
     EVALUATE TRUE
         WHEN EN-HEALTH(L-ROW) = 0
             CALL "MOB-LEASH-DROP" USING L-ROW
         WHEN WS-HOK = 0
             CALL "MOB-LEASH-DROP" USING L-ROW
         WHEN OTHER
             CALL "MOB-LEASH-DIST-PT" USING L-ROW WS-HX WS-HY WS-HZ WS-DISTANCE
             COMPUTE WS-TYPE = EN-TYPE(L-ROW) + 1
             IF WS-DISTANCE > 12
                 CALL "MOB-LEASH-DROP" USING L-ROW
             END-IF
             IF WS-DISTANCE <= 12 AND WS-DISTANCE >= 6
*>               The dampened spring (8.3): force (d - 6) toward the holder, x 0.3 unless it opposes the mob's motion, x (0.8, 0.2, 0.8) added to the velocity.
                 COMPUTE WS-SCALE = (WS-DISTANCE - 6) / WS-DISTANCE
                 COMPUTE WS-FX = (WS-HX - EN-X(L-ROW)) * WS-SCALE
                 COMPUTE WS-FY = (WS-HY - (EN-Y(L-ROW) + ET-HEIGHT-MILLI(WS-TYPE) / 2000)) * WS-SCALE
                 COMPUTE WS-FZ = (WS-HZ - EN-Z(L-ROW)) * WS-SCALE
                 IF WS-FX * EN-VX(L-ROW) + WS-FZ * EN-VZ(L-ROW) >= 0
                     COMPUTE WS-FX = WS-FX * 0.3
                     COMPUTE WS-FY = WS-FY * 0.3
                     COMPUTE WS-FZ = WS-FZ * 0.3
                 END-IF
                 COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) + WS-FX * 0.8
                 COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + WS-FZ * 0.8
                 COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + WS-FY * 0.2
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM MOB-LEASH-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-FENCE-USE.
*> USING player row, clicked state, x, y, z, used out: Use Item On a block in the block tag fences (FenceBlock.useWithoutItem, LeadItem.useOn): the player's mobs go to the knot.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:fences".
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TAGGED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-USED                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-STATE L-X L-Y L-Z L-USED.
     MOVE 0 TO L-USED WS-TAGGED
     IF L-STATE > 0
         MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
         CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-BLOCK WS-TAGGED
     END-IF
     IF WS-TAGGED = 1
         CALL "MOB-KNOT-USE" USING L-PLAYER L-X L-Y L-Z L-USED
     END-IF
     GOBACK.
 END PROGRAM MOB-FENCE-USE.
