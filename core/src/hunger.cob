*> Hunger, saturation and eating (17 section 4.9, the shared rules of both world types; docs/protocol/09
*> section 3.3 Hunger rows; 05a 0x22, 05c 0x29, 0x43).
*>
*> Hunger applies only to alive survival players: a creative player's food, saturation and exhaustion
*> do not change, it does not starve and Use Item does not start eating.
*>
*> Exhaustion (HUNGER-EXHAUST): an activity adds its amount (capped at 40). The activities call it:
*> sprinting and jumping (MOVE-PLAYER, core/src/movement.cob), hits (HEALTH-ATTACK), damage taken
*> (HEALTH-DAMAGE, the damage type's exhaustion), regeneration (below), survival breaks
*> (BLOCK-ACTION, core/src/blocks.cob).
*>
*> FoodData tick (HUNGER-TICK, from HEALTH-TICK, after the hurt window): when exhaustion is at least
*> 4.0, 4.0 is taken off and saturation falls by 1 (to at least 0) or, with none left, food by 1.
*> Natural regeneration: while saturation is above 0, food is 20 and health is below 20, every 10th
*> tick heals min(saturation, 6) / 6 and adds min(saturation, 6) exhaustion; else while food is at
*> least 18 and health below 20, every 80th tick heals 1 and adds 6.0 exhaustion; else at food 0
*> every 80th tick the player takes 1 starvation damage (HEALTH-DAMAGE) while its health is above 1
*> (Normal difficulty); otherwise the timer (PL-RECOVER-TICKS) is 0. The player is sent Set Health
*> (with the saturation) in a tick in which health, food or saturation changed.
*>
*> Eating (17 section 4.9; the foods' saturation is 0.0, standard core CORE-21): Use Item from an
*> alive survival player whose held hotbar slot holds a food item (CITEMS.cpy IT-FOOD > 0) and whose
*> food is below 20 starts eating that item (HUNGER-USE-ITEM); food at 20, creative mode or no food
*> item held does nothing. When 30 ticks have passed since the start (HUNGER-TICK) and the held slot
*> still holds that item, one item leaves the slot, food rises by the item's value up to 20,
*> saturation stays within the food level, and the player is sent Set Health and Container Set Slot
*> of the slot, then Entity Event 9 (eating finished), which every player that has the player's
*> entity is sent too. Player Action 6 RELEASE_USE_ITEM, a change of held slot (INV-HELD), a change
*> of the slot's item, death (HEALTH-DIE) or creative mode before then cancel it (HUNGER-CANCEL).
*>
*> Entry points:
*>   HUNGER-EXHAUST USING player row (BINARY-LONG), amount (FLOAT-LONG)
*>   HUNGER-USE-ITEM USING connection id, PLAY-SERVERBOUND   Use Item
*>   HUNGER-CANCEL USING player row                           stop eating, nothing is eaten
*>   HUNGER-TICK USING player row                             the per-tick rules of an alive player
*> Builder (appends id + body to the caller's PB-BUFFER):
*>   ENTITY-EVENT-BUILD USING entity id, event id (BINARY-LONG), PB-BUFFER

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-EVENT-BUILD.
*> USING entity id, event id (BINARY-LONG), PB-BUFFER: Entity Event 0x22 (05a; 09 §3.3): Int entity
*> id, Byte event id.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PACKET-ID           BINARY-LONG VALUE 34.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ENTITY-ID            BINARY-LONG.
 01 L-EVENT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY-ID L-EVENT PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-INT" USING PB-BUFFER L-ENTITY-ID
     CALL "PB-PUT-BYTE" USING PB-BUFFER L-EVENT
     GOBACK.
 END PROGRAM ENTITY-EVENT-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HUNGER-EXHAUST.
*> USING player row (BINARY-LONG), amount (FLOAT-LONG): adds the exhaustion of an activity to an
*> alive survival player (see above).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-AMOUNT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-AMOUNT.
     MOVE L-ROW TO WS-ROW
     IF PL-MODE(WS-ROW) NOT = 0 OR PL-STATE(WS-ROW) NOT = PS-ALIVE
         GOBACK
     END-IF
     COMPUTE WS-LIMIT = RULE-EXHAUST-CAP-MILLI / 1000
     COMPUTE PL-EXHAUSTION(WS-ROW) = FUNCTION MIN(WS-LIMIT, PL-EXHAUSTION(WS-ROW) + L-AMOUNT)
     GOBACK.
 END PROGRAM HUNGER-EXHAUST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HUNGER-USE-ITEM.
*> USING connection id, PLAY-SERVERBOUND (a decoded Use Item 0x43): starts eating (see above).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY CITEMS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     COMPUTE WS-SLOT = PL-HELD(WS-ROW) + 1
     IF PL-MODE(WS-ROW) NOT = 0 OR PL-STATE(WS-ROW) NOT = PS-ALIVE
             OR PL-FOOD(WS-ROW) >= RULE-MAX-FOOD
             OR PL-SLOT-COUNT(WS-ROW, WS-SLOT) = 0
         GOBACK
     END-IF
     IF IT-FOOD(PL-SLOT-ITEM(WS-ROW, WS-SLOT) + 1) = 0
         GOBACK
     END-IF
     MOVE PL-SLOT-ITEM(WS-ROW, WS-SLOT) TO PL-EATING-ITEM(WS-ROW)
     MOVE PL-HELD(WS-ROW) TO PL-EATING-SLOT(WS-ROW)
     MOVE CW-TICKS TO PL-EATING-START(WS-ROW)
     GOBACK.
 END PROGRAM HUNGER-USE-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HUNGER-CANCEL.
*> USING player row (BINARY-LONG): the player stops eating; nothing is eaten.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 0 TO PL-EATING-ITEM(L-ROW)
     GOBACK.
 END PROGRAM HUNGER-CANCEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HUNGER-TICK.
*> USING player row (BINARY-LONG) of an alive player: eating completion and the FoodData tick (see
*> above).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY CITEMS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 16.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ITEM                BINARY-LONG.
 01 WS-FOOD                BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-AMOUNT              FLOAT-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-HEAL                FLOAT-LONG.
 01 WS-ENOUGH              FLOAT-LONG.
 01 WS-NO-ENTITY           BINARY-LONG VALUE 0.
 01 WS-NO-ATTACKER         BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE L-ROW TO WS-ROW
     IF PL-MODE(WS-ROW) NOT = 0
         MOVE 0 TO PL-EATING-ITEM(WS-ROW)
         GOBACK
     END-IF
*>   Eating completion (§11.6).
     IF PL-EATING-ITEM(WS-ROW) > 0
             AND CW-TICKS - PL-EATING-START(WS-ROW) >= RULE-EAT-TICKS
         MOVE PL-EATING-SLOT(WS-ROW) TO WS-SLOT
         IF PL-HELD(WS-ROW) = WS-SLOT
                 AND PL-SLOT-ITEM(WS-ROW, WS-SLOT + 1) = PL-EATING-ITEM(WS-ROW)
                 AND PL-SLOT-COUNT(WS-ROW, WS-SLOT + 1) > 0
             CALL "INV-REMOVE" USING WS-ROW WS-SLOT WS-ONE
             COMPUTE WS-ITEM = PL-EATING-ITEM(WS-ROW) + 1
             COMPUTE WS-FOOD = PL-FOOD(WS-ROW) + IT-FOOD(WS-ITEM)
             COMPUTE PL-FOOD(WS-ROW) = FUNCTION MIN(RULE-MAX-FOOD, WS-FOOD)
             COMPUTE PL-SATURATION(WS-ROW) = FUNCTION MIN(PL-SATURATION(WS-ROW), PL-FOOD(WS-ROW))
             CALL "HEALTH-SEND" USING WS-ROW
             COMPUTE PL-STATE-ID(WS-ROW) = FUNCTION MOD(PL-STATE-ID(WS-ROW) + 1, 32768)
             CALL "INV-SLOT-SEND" USING PL-CONN(WS-ROW) WS-SLOT
             MOVE RULE-EAT-EVENT TO WS-EVENT
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             CALL "ENTITY-EVENT-BUILD" USING PL-ENTITY-ID(WS-ROW) WS-EVENT PB-BUFFER
             CALL "CORE-SEND" USING PL-CONN(WS-ROW) PB-BUFFER
             CALL "HEALTH-VIEWERS-SEND" USING PL-ENTITY-ROW(WS-ROW) PB-BUFFER
             CALL "PB-FREE" USING PB-BUFFER
         END-IF
         MOVE 0 TO PL-EATING-ITEM(WS-ROW)
     END-IF
*>   Exhaustion spent (17 section 4.9).
     MOVE 0 TO WS-CHANGED
     COMPUTE WS-LIMIT = RULE-EXHAUST-DROP-MILLI / 1000
     IF PL-EXHAUSTION(WS-ROW) >= WS-LIMIT - 0.000000001
         COMPUTE PL-EXHAUSTION(WS-ROW) = FUNCTION MAX(0, PL-EXHAUSTION(WS-ROW) - WS-LIMIT)
         IF PL-SATURATION(WS-ROW) > 0
             COMPUTE PL-SATURATION(WS-ROW) = FUNCTION MAX(PL-SATURATION(WS-ROW) - 1, 0)
             MOVE 1 TO WS-CHANGED
         ELSE
             IF PL-FOOD(WS-ROW) > 0
                 SUBTRACT 1 FROM PL-FOOD(WS-ROW)
                 MOVE 1 TO WS-CHANGED
             END-IF
         END-IF
     END-IF
*>   Natural regeneration and starvation.
     COMPUTE WS-ENOUGH = RULE-REGEN-SATURATION-CAP
     EVALUATE TRUE
         WHEN PL-SATURATION(WS-ROW) > 0 AND PL-HEALTH(WS-ROW) < RULE-MAX-HEALTH
                 AND PL-FOOD(WS-ROW) >= RULE-MAX-FOOD
             ADD 1 TO PL-RECOVER-TICKS(WS-ROW)
             IF PL-RECOVER-TICKS(WS-ROW) >= RULE-REGEN-FAST-TICKS
                 COMPUTE WS-AMOUNT = FUNCTION MIN(PL-SATURATION(WS-ROW), WS-ENOUGH)
                 COMPUTE WS-HEAL = WS-AMOUNT / RULE-REGEN-SATURATION-CAP
                 COMPUTE PL-HEALTH(WS-ROW) = FUNCTION MIN(RULE-MAX-HEALTH,
                     PL-HEALTH(WS-ROW) + WS-HEAL)
                 CALL "HUNGER-EXHAUST" USING WS-ROW WS-AMOUNT
                 MOVE 0 TO PL-RECOVER-TICKS(WS-ROW)
                 MOVE 1 TO WS-CHANGED
             END-IF
         WHEN PL-FOOD(WS-ROW) >= RULE-HEAL-FOOD AND PL-HEALTH(WS-ROW) < RULE-MAX-HEALTH
             ADD 1 TO PL-RECOVER-TICKS(WS-ROW)
             IF PL-RECOVER-TICKS(WS-ROW) >= RULE-REGEN-TICKS
                 COMPUTE PL-HEALTH(WS-ROW) = FUNCTION MIN(RULE-MAX-HEALTH,
                     PL-HEALTH(WS-ROW) + 1)
                 MOVE RULE-REGEN-SLOW-EXHAUST TO WS-AMOUNT
                 CALL "HUNGER-EXHAUST" USING WS-ROW WS-AMOUNT
                 MOVE 0 TO PL-RECOVER-TICKS(WS-ROW)
                 MOVE 1 TO WS-CHANGED
             END-IF
         WHEN PL-FOOD(WS-ROW) <= 0
             ADD 1 TO PL-RECOVER-TICKS(WS-ROW)
             IF PL-RECOVER-TICKS(WS-ROW) >= RULE-REGEN-TICKS
                 MOVE 0 TO PL-RECOVER-TICKS(WS-ROW)
                 IF PL-HEALTH(WS-ROW) > 1
                     MOVE CAUSE-STARVATION TO WS-CAUSE
                     CALL "HEALTH-DAMAGE" USING WS-ROW RULE-CAUSE-AMOUNT(WS-CAUSE) WS-CAUSE
                         WS-NO-ENTITY WS-NO-ATTACKER
                 END-IF
             END-IF
         WHEN OTHER
             MOVE 0 TO PL-RECOVER-TICKS(WS-ROW)
     END-EVALUATE
     IF WS-CHANGED = 1
         CALL "HEALTH-SEND" USING WS-ROW
     END-IF
     GOBACK.
 END PROGRAM HUNGER-TICK.
