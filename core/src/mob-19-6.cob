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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WOLF-FEED-LOVE.
*> USING player row, entity row (a tame wolf), consumed out: wolf food that heals nothing is the base Animal feeding (love, or the age-up of a pup): consumed 1 when the love or the age changed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-LOVE                BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-CONSUMED             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ENTITY L-CONSUMED.
     MOVE EN-LOVE(L-ENTITY) TO WS-LOVE
     MOVE EN-MOBAGE(L-ENTITY) TO WS-AGE
     CALL "MOB-FEED-USE" USING L-ROW L-ENTITY
     MOVE 0 TO L-CONSUMED
     IF EN-LOVE(L-ENTITY) NOT = WS-LOVE OR EN-MOBAGE(L-ENTITY) NOT = WS-AGE
         MOVE 1 TO L-CONSUMED
     END-IF
     GOBACK.
 END PROGRAM WOLF-FEED-LOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WOLF-BRED.
*> USING parent a, parent b, baby, coin: the pup has the variant of the parent the coin names (EN-WOOL); when the first parent is tame the pup is tame with the same owner, 40 health and
*> the collar mixed from the parents' collars (M19-SHEEP-MIX, the dye ids; the default collar is red, 14).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-COLOR-A             BINARY-LONG.
 01 WS-COLOR-B             BINARY-LONG.
 01 WS-MIXED               BINARY-LONG.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-COIN                 BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-BABY L-COIN.
     MOVE EN-WOOL(L-A) TO EN-WOOL(L-BABY)
     IF L-COIN = 1
         MOVE EN-WOOL(L-B) TO EN-WOOL(L-BABY)
     END-IF
     IF EN-TAMED(L-A) = 1
         MOVE 14 TO WS-COLOR-A WS-COLOR-B
         IF EN-COLLAR(L-A) > 0
             COMPUTE WS-COLOR-A = EN-COLLAR(L-A) - 1
         END-IF
         IF EN-COLLAR(L-B) > 0
             COMPUTE WS-COLOR-B = EN-COLLAR(L-B) - 1
         END-IF
         CALL "M19-SHEEP-MIX" USING WS-COLOR-A WS-COLOR-B L-COIN WS-MIXED
         COMPUTE EN-COLLAR(L-BABY) = WS-MIXED + 1
         MOVE 1 TO EN-TAMED(L-BABY)
         MOVE 0 TO EN-SIT(L-BABY)
         MOVE EN-OWNER-UUID(L-A) TO EN-OWNER-UUID(L-BABY)
         MOVE 40 TO EN-HEALTH(L-BABY)
     END-IF
     GOBACK.
 END PROGRAM WOLF-BRED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WOLF-WET-STEP.
*> USING row, in water (0 or 1: in water or rain), walking (1 when it follows a path): the wet shake of 19 section 6.1. Being in water latches EN-WOLF-WET and cancels a running
*> shake (Entity Event 56); out of water a wet wolf that is not shaking, not walking and on the ground starts to shake (Entity Event 8); a shake grows 0.05 a tick
*> and ends at 2.0 (40 ticks after its start), clearing the wet state.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-EVENT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-WALKING              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-WATER L-WALKING.
     MOVE 0 TO WS-EVENT
     EVALUATE TRUE
         WHEN L-WATER = 1
             MOVE 1 TO EN-WOLF-WET(L-ROW)
             IF EN-WOLF-SHAKE(L-ROW) > 0
                 MOVE 0 TO EN-WOLF-SHAKE(L-ROW)
                 MOVE 56 TO WS-EVENT
             END-IF
         WHEN EN-WOLF-SHAKE(L-ROW) > 0
             ADD 1 TO EN-WOLF-SHAKE(L-ROW)
             IF EN-WOLF-SHAKE(L-ROW) > 40
                 MOVE 0 TO EN-WOLF-SHAKE(L-ROW) EN-WOLF-WET(L-ROW)
             END-IF
         WHEN EN-WOLF-WET(L-ROW) = 1 AND L-WALKING = 0 AND EN-ON-GROUND(L-ROW) = 1
             MOVE 1 TO EN-WOLF-SHAKE(L-ROW)
             MOVE 8 TO WS-EVENT
     END-EVALUATE
     IF WS-EVENT > 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ROW) WS-EVENT PB-BUFFER
         CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
         CALL "PB-FREE" USING PB-BUFFER
     END-IF
     GOBACK.
 END PROGRAM WOLF-WET-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WOLF-WET-TICK.
*> USING row, walking: WOLF-WET-STEP with the water test of the cell the wolf stands in (rain is an open item).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-HEIGHT              FLOAT-LONG VALUE 0.85.
 01 WS-KIND-WATER          BINARY-LONG VALUE 1.
 01 WS-WATER               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-WALKING              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-WALKING.
     CALL "M182-FLUID" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-HEIGHT WS-KIND-WATER WS-WATER
     CALL "WOLF-WET-STEP" USING L-ROW WS-WATER L-WALKING
     GOBACK.
 END PROGRAM WOLF-WET-TICK.
