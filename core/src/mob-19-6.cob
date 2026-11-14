*> Wolf behaviour beyond taming (lane 002-lane-mobsfull-h23; docs/protocol/19 section 6.1).
*>
*> Entry points:
*>   WOLF-HURT USING row                      any damage makes a tame sitting wolf stand (entity data to the viewers)
*>   WOLF-ARMOR-USE USING player row, entity row, used out
*>                                            the owner's wolf armour equips on an adult wolf without armour; an armadillo scute repairs 8 points
*>                                            (floor(durability x 0.125)) of damaged armour on a sitting wolf; used 1 when the item was used
*>   WOLF-ARMOR-ABSORB USING row, damage, absorbed out
*>                                            armour takes the hit (the damage in whole points) instead of the wolf; at the durability it breaks
*>   WOLF-ARMOR-DROP USING row                the armour worn drops as an item when the wolf dies
*> Open: the crack-stage sound and scute particles, the damage tag bypasses_wolf_armor (the cause is not passed), the body slot in Set Equipment,
*> the durability damage of the dropped item (no patch handle for it).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WOLF-HURT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(24).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = "wolf" AND EN-TAMED(L-ROW) = 1 AND EN-SIT(L-ROW) = 1
         MOVE 0 TO EN-SIT(L-ROW)
         CALL "MOB-DATA-SEND" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM WOLF-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WOLF-ARMOR-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-HELD                PIC X(48).
 01 WS-ARMOR-KEY           PIC X(48) VALUE "wolf_armor".
 01 WS-FOUND               BINARY-LONG.
 01 WS-DURABILITY          BINARY-LONG.
 01 WS-DEFENSE             BINARY-LONG.
 01 WS-TOUGHNESS           BINARY-LONG.
 01 WS-KNOCKBACK           BINARY-LONG.
 01 WS-ENCHANT             BINARY-LONG.
 01 WS-REPAIR              PIC X(40).
 01 WS-UNIT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-USED                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ENTITY L-USED.
     MOVE 0 TO L-USED
     MOVE SPACES TO WS-HELD
     IF PL-SLOT-COUNT(L-ROW, PL-HELD(L-ROW) + 1) > 0
         CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(L-ROW, PL-HELD(L-ROW) + 1) WS-HELD
     END-IF
     IF EN-OWNER-UUID(L-ENTITY) NOT = PL-UUID(L-ROW)
         GOBACK
     END-IF
     EVALUATE TRUE
         WHEN WS-HELD = "wolf_armor" AND EN-WOLF-ARM(L-ENTITY) = 0 AND EN-MOBAGE(L-ENTITY) >= 0
             MOVE PL-SLOT-ITEM(L-ROW, PL-HELD(L-ROW) + 1) TO EN-WOLF-ARM(L-ENTITY)
             MOVE 0 TO EN-WOLF-ARM-DMG(L-ENTITY)
             CALL "MOB-TAKE" USING L-ROW
             MOVE 1 TO L-USED
         WHEN WS-HELD = "armadillo_scute" AND EN-WOLF-ARM(L-ENTITY) > 0 AND EN-WOLF-ARM-DMG(L-ENTITY) > 0 AND EN-SIT(L-ENTITY) = 1
             CALL "TOOL-ARMOR-ITEM" USING WS-ARMOR-KEY WS-FOUND WS-DURABILITY WS-DEFENSE WS-TOUGHNESS WS-KNOCKBACK
                 WS-ENCHANT WS-REPAIR
             COMPUTE WS-UNIT = WS-DURABILITY / 8
             COMPUTE EN-WOLF-ARM-DMG(L-ENTITY) = FUNCTION MAX(0, EN-WOLF-ARM-DMG(L-ENTITY) - WS-UNIT)
             CALL "MOB-TAKE" USING L-ROW
             MOVE 1 TO L-USED
     END-EVALUATE
     GOBACK.
 END PROGRAM WOLF-ARMOR-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WOLF-ARMOR-ABSORB.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ARMOR-KEY           PIC X(48) VALUE "wolf_armor".
 01 WS-FOUND               BINARY-LONG.
 01 WS-DURABILITY          BINARY-LONG.
 01 WS-DEFENSE             BINARY-LONG.
 01 WS-TOUGHNESS           BINARY-LONG.
 01 WS-KNOCKBACK           BINARY-LONG.
 01 WS-ENCHANT             BINARY-LONG.
 01 WS-REPAIR              PIC X(40).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 01 L-ABSORBED             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DAMAGE L-ABSORBED.
     MOVE 0 TO L-ABSORBED
     IF EN-WOLF-ARM(L-ROW) = 0
         GOBACK
     END-IF
     MOVE 1 TO L-ABSORBED
     CALL "TOOL-ARMOR-ITEM" USING WS-ARMOR-KEY WS-FOUND WS-DURABILITY WS-DEFENSE WS-TOUGHNESS WS-KNOCKBACK
         WS-ENCHANT WS-REPAIR
     ADD L-DAMAGE TO EN-WOLF-ARM-DMG(L-ROW)
     IF EN-WOLF-ARM-DMG(L-ROW) >= WS-DURABILITY
         MOVE 0 TO EN-WOLF-ARM(L-ROW) EN-WOLF-ARM-DMG(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM WOLF-ARMOR-ABSORB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WOLF-ARMOR-DROP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-OFFSET              FLOAT-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-PATCH               BINARY-LONG VALUE 0.
 01 WS-ITEM-ENTITY         BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF EN-WOLF-ARM(L-ROW) > 0
         CALL "IP-AT-LOCATION" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-OFFSET EN-WOLF-ARM(L-ROW) WS-ONE
             WS-PATCH WS-ITEM-ENTITY
         MOVE 0 TO EN-WOLF-ARM(L-ROW) EN-WOLF-ARM-DMG(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM WOLF-ARMOR-DROP.
