*> Allay (002-lane-mobsfull-h21; docs/protocol/19-mobs-land-friendly-and-neutral.md section 15).
*> - Item: a right click with an item on an allay that holds none: it takes one (the stack of a survival player shrinks, MOB-TAKE) and likes the player (EN-ALLAY-LIKED). A right click with an empty hand on an
*>   allay that holds an item gives the item back (the empty held slot always has room for it) and the allay forgets the liked player. An item in both hands does nothing.
*> - Duplication: an amethyst shard (duplicates_allays) on a dancing allay whose cooldown is 0 (canDuplicate): a second allay appears at the same place, both get the cooldown 6000 ticks (EN-ALLAY-DUP, counted
*>   down by 1 a tick), Entity Event 18 (hearts) goes to the viewers and the shard is used up. Metadata 16 is dancing, 17 canDuplicate (sent when false).
*> - Regeneration: 1 HP every 10 ticks up to the max health of the row. The liked player's hits do nothing (ALLAY-LIKES, called by HEALTH-MOB-DAMAGE).
*> Item pickup and delivery are in core/src/mob-44-j.cob (M44-ALLAY-BRAIN, called at the end of ALLAY-TICK; 002-lane-mobsa4).
*> Open items: staying close to the liked player, dancing (the jukebox and note block triggers; EN-ALLAY-DANCE is set by
*>   nothing yet), the small inventory (the held item is the only one), the held item in Set Equipment, the liked noteblock, panic.
*>
*> Entry points:
*>   MOB-ALLAY-USE USING player row, allay row       ALLAY-TICK USING row       ALLAY-LIKES USING row, attacker player row, liked out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ALLAY-LIKES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 01 L-LIKED                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ATTACKER L-LIKED.
     MOVE 0 TO L-LIKED
     IF L-ATTACKER > 0 AND EN-ALLAY-LIKED(L-ROW) NOT = SPACES
         IF EN-ALLAY-LIKED(L-ROW) = PL-UUID(L-ATTACKER)
             MOVE 1 TO L-LIKED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ALLAY-LIKES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ALLAY-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF EN-ALLAY-DUP(L-ROW) > 0
         SUBTRACT 1 FROM EN-ALLAY-DUP(L-ROW)
         IF EN-ALLAY-DUP(L-ROW) = 0
             CALL "MOB-DATA-SEND" USING L-ROW
         END-IF
     END-IF
     ADD 1 TO EN-ALLAY-T(L-ROW)
     IF EN-ALLAY-T(L-ROW) >= 10
         MOVE 0 TO EN-ALLAY-T(L-ROW)
         IF EN-HEALTH(L-ROW) < SM-HEALTH(WS-M)
             ADD 1 TO EN-HEALTH(L-ROW)
         END-IF
     END-IF
     CALL "M44-ALLAY-BRAIN" USING L-ROW
     GOBACK.
 END PROGRAM ALLAY-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-ALLAY-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-EVENT               BINARY-LONG VALUE 18.
 01 WS-KEY48               PIC X(48).
 01 WS-COUNT               BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-LEFT                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-COPY                BINARY-LONG.
 01 WS-HALF                FLOAT-LONG VALUE 0.5.
 01 WS-NOPATCH             BINARY-LONG VALUE 0.
 01 WS-DROPPED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ENTITY.
     MOVE SPACES TO WS-KEY48
     MOVE PL-SLOT-COUNT(L-ROW, PL-HELD(L-ROW) + 1) TO WS-COUNT
     MOVE PL-SLOT-ITEM(L-ROW, PL-HELD(L-ROW) + 1) TO WS-ITEM
     IF WS-COUNT > 0
         CALL "TOOLUSE-KEY" USING WS-ITEM WS-KEY48
     END-IF
     EVALUATE TRUE
         WHEN WS-COUNT > 0 AND WS-KEY48 = "amethyst_shard" AND EN-ALLAY-DANCE(L-ENTITY) = 1 AND EN-ALLAY-DUP(L-ENTITY) = 0
             MOVE EN-X(L-ENTITY) TO WS-X
             MOVE EN-Y(L-ENTITY) TO WS-Y
             MOVE EN-Z(L-ENTITY) TO WS-Z
             CALL "MOB-SPAWN" USING EN-DIM(L-ENTITY) EN-TYPE(L-ENTITY) WS-X WS-Y WS-Z WS-YAW WS-COPY
             MOVE 6000 TO EN-ALLAY-DUP(L-ENTITY) EN-ALLAY-DUP(WS-COPY)
             CALL "MOB-DATA-SEND" USING L-ENTITY
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ENTITY) WS-EVENT PB-BUFFER
             CALL "HEALTH-VIEWERS-SEND" USING L-ENTITY PB-BUFFER
             CALL "PB-FREE" USING PB-BUFFER
             CALL "MOB-TAKE" USING L-ROW
         WHEN WS-COUNT = 0 AND EN-ALLAY-ITEM(L-ENTITY) > 0
             CALL "INV-ADD" USING L-ROW EN-ALLAY-ITEM(L-ENTITY) WS-ONE WS-LEFT
             PERFORM VARYING WS-SLOT FROM 0 BY 1 UNTIL WS-SLOT > 35
                 CALL "INV-SLOT-SEND" USING PL-CONN(L-ROW) WS-SLOT
             END-PERFORM
             IF EN-ALLAY-COUNT(L-ENTITY) > 0
                 CALL "IP-AT-LOCATION" USING EN-DIM(L-ENTITY) EN-X(L-ENTITY) EN-Y(L-ENTITY) EN-Z(L-ENTITY) WS-HALF
                     EN-ALLAY-ITEM(L-ENTITY) EN-ALLAY-COUNT(L-ENTITY) WS-NOPATCH WS-DROPPED
                 MOVE 0 TO EN-ALLAY-COUNT(L-ENTITY)
             END-IF
             MOVE 0 TO EN-ALLAY-ITEM(L-ENTITY)
             MOVE SPACES TO EN-ALLAY-LIKED(L-ENTITY)
         WHEN WS-COUNT > 0 AND EN-ALLAY-ITEM(L-ENTITY) = 0
             MOVE WS-ITEM TO EN-ALLAY-ITEM(L-ENTITY)
             MOVE PL-UUID(L-ROW) TO EN-ALLAY-LIKED(L-ENTITY)
             CALL "MOB-TAKE" USING L-ROW
     END-EVALUATE
     GOBACK.
 END PROGRAM MOB-ALLAY-USE.
