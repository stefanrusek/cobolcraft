*> Leashing (docs/protocol/18-mob-framework.md section 8.3, 05b 0x66 Set Entity Link, 17 section 3.7). EN-LEASH is the player row that holds the lead of a mob (0 none).
*> Open items: a fence knot (the holder is always a player here), the lead on a boat or a mob that is not a passive creature other than the list below, the closeRange walk toward
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
 COPY CITEMS.
 01 WS-TYPE                BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HOLDER               BINARY-LONG.
 01 L-DISTANCE             FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-HOLDER L-DISTANCE.
     COMPUTE WS-TYPE = EN-TYPE(L-ROW) + 1
     COMPUTE WS-DX = PL-X(L-HOLDER) - EN-X(L-ROW)
     COMPUTE WS-DY = (PL-Y(L-HOLDER) + 0.9) - (EN-Y(L-ROW) + ET-HEIGHT-MILLI(WS-TYPE) / 2000)
     COMPUTE WS-DZ = PL-Z(L-HOLDER) - EN-Z(L-ROW)
     COMPUTE L-DISTANCE = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
     GOBACK.
 END PROGRAM MOB-LEASH-DIST.

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
     IF WS-LEASHABLE = 1 AND EN-LEASH(L-ROW) = 0 AND EN-DIM(L-ROW) = PL-DIM(L-PLAYER)
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
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 0 TO EN-LEASH(L-ROW)
     CALL "MOB-LEASH-LINK" USING L-ROW WS-NONE
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
     CALL "PB-PUT-INT" USING PB-BUFFER PL-ENTITY-ID(EN-LEASH(L-ROW))
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
         WHEN L-HELD = "lead" AND EN-LEASH(L-ROW) = 0
             CALL "MOB-LEASH-ATTACH" USING L-PLAYER L-ROW WS-OK
             IF WS-OK = 1
                 CALL "MOB-TAKE" USING L-PLAYER
                 MOVE 1 TO L-HANDLED
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM MOB-LEASH-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-LEASH-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-HOLDER              BINARY-LONG.
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
     EVALUATE TRUE
         WHEN EN-HEALTH(L-ROW) = 0
             CALL "MOB-LEASH-DROP" USING L-ROW
         WHEN PL-USED(WS-HOLDER) = 0 OR PL-DIM(WS-HOLDER) NOT = EN-DIM(L-ROW)
             CALL "MOB-LEASH-DROP" USING L-ROW
         WHEN OTHER
             CALL "MOB-LEASH-DIST" USING L-ROW WS-HOLDER WS-DISTANCE
             COMPUTE WS-TYPE = EN-TYPE(L-ROW) + 1
             IF WS-DISTANCE > 12
                 CALL "MOB-LEASH-DROP" USING L-ROW
             END-IF
             IF WS-DISTANCE <= 12 AND WS-DISTANCE >= 6
*>               The dampened spring (8.3): force (d - 6) toward the holder, x 0.3 unless it opposes the mob's motion, x (0.8, 0.2, 0.8) added to the velocity.
                 COMPUTE WS-SCALE = (WS-DISTANCE - 6) / WS-DISTANCE
                 COMPUTE WS-FX = (PL-X(WS-HOLDER) - EN-X(L-ROW)) * WS-SCALE
                 COMPUTE WS-FY = ((PL-Y(WS-HOLDER) + 0.9) - (EN-Y(L-ROW) + ET-HEIGHT-MILLI(WS-TYPE) / 2000)) * WS-SCALE
                 COMPUTE WS-FZ = (PL-Z(WS-HOLDER) - EN-Z(L-ROW)) * WS-SCALE
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
