*> Picking up a stuck arrow (docs/protocol/17 section 3.9: AbstractArrow.playerTouch -> tryPickup, the three AbstractArrow$Pickup modes; lane 002-lane-p46e, T27011).
*> ARROW-PICKUP runs for an arrow that has stuck in a block, every tick. The arrow can be picked up once it has been stuck 7 ticks (shakeTime) by a player whose box,
*> inflated by 1.0 horizontally and 0.5 vertically, meets it (GI-IN-REACH, the reach rule of loose items; an arrow's own box is a little larger than an item's: open). The mode
*> in EN-ARR-PICKUP: 0 never, 1 any player (the arrow item, EN-ARR-ITEM or a plain arrow, goes into the inventory; what does not fit stays), 2 only a player with infinite
*> materials. The viewers get Take Item Entity (collected id, collector id, 1), the entity goes and the taker's changed slots are sent. Which mode a shot arrow gets is the
*> weapon's (ranged-use.cob: 1 when the shot used an arrow up, 2 for a shot that cost nothing).
*>
*>   ARROW-PICKUP USING tracker row

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ARROW-PICKUP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-LEFT                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-SENT                BINARY-LONG.
 01 WS-ARROW-KEY           PIC X(112) VALUE "minecraft:arrow".
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-BEFORE.
    05 WS-B-ITEM           BINARY-LONG OCCURS 36 TIMES.
    05 WS-B-COUNT          BINARY-LONG OCCURS 36 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF EN-ARR-PICKUP(L-ROW) = 0 OR EN-AGE(L-ROW) < 7
         GOBACK
     END-IF
     MOVE EN-ARR-ITEM(L-ROW) TO WS-ITEM
     IF WS-ITEM = 0
         CALL "CONTENT-ITEM-BY-KEY" USING WS-ARROW-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     END-IF
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS OR WS-DONE = 1
         CALL "GI-IN-REACH" USING WS-PLAYER L-ROW WS-IN
         MOVE WS-IN TO WS-OK
         IF EN-ARR-PICKUP(L-ROW) = 2 AND PL-MODE(WS-PLAYER) NOT = 1
             MOVE 0 TO WS-OK
         END-IF
         IF WS-OK = 1
             PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 36
                 MOVE PL-SLOT-ITEM(WS-PLAYER, WS-SLOT) TO WS-B-ITEM(WS-SLOT)
                 MOVE PL-SLOT-COUNT(WS-PLAYER, WS-SLOT) TO WS-B-COUNT(WS-SLOT)
             END-PERFORM
             CALL "INV-ADD" USING WS-PLAYER WS-ITEM WS-ONE WS-LEFT
             IF WS-LEFT = 0
                 CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
                 CALL "TAKE-ITEM-ENTITY-BUILD" USING EN-ID(L-ROW) PL-ENTITY-ID(WS-PLAYER) WS-ONE PB-BUFFER
                 CALL "GI-VIEWERS-SEND" USING L-ROW PB-BUFFER
                 CALL "PB-FREE" USING PB-BUFFER
                 PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 36
                     IF PL-SLOT-ITEM(WS-PLAYER, WS-SLOT) NOT = WS-B-ITEM(WS-SLOT)
                             OR PL-SLOT-COUNT(WS-PLAYER, WS-SLOT) NOT = WS-B-COUNT(WS-SLOT)
                         COMPUTE WS-SENT = WS-SLOT - 1
                         CALL "INV-SLOT-SEND" USING PL-CONN(WS-PLAYER) WS-SENT
                     END-IF
                 END-PERFORM
                 CALL "ENTITY-REMOVE" USING L-ROW
                 MOVE 1 TO WS-DONE
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ARROW-PICKUP.
