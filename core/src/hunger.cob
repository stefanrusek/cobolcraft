*> Hunger and eating (US8; standin-content §11, §10.3 starvation; data-model §6;
*> docs/protocol/09-cobolcraft-profile.md §3.3 Hunger rows; 05a 0x22, 05c 0x29, 0x43).
*>
*> Hunger applies only to alive survival players (US8-6): a creative player's food and exhaustion
*> do not change, it does not starve and Use Item does not start eating.
*>
*> Exhaustion (HUNGER-EXHAUST, §11.2, §11.3): an activity adds its amount; whenever exhaustion is
*> at least 5.0, 5.0 is taken off and, if food is above 0, food falls by 1 and the player is sent
*> Set Health (repeated while it is still at least 5.0). The activities call it: time (HUNGER-TICK),
*> walking, running and jumping (MOVE-PLAYER, core/src/movement.cob), hits (HEALTH-ATTACK) and
*> recovery (HEALTH-TICK, core/src/health.cob), survival breaks (BLOCK-ACTION, core/src/blocks.cob).
*> The comparison with 5.0 allows 1e-9 so that 1000 ticks of 0.005 reach it.
*>
*> Eating (§11.6): Use Item from an alive survival player whose held hotbar slot holds a food item
*> (ITEMS.cpy IT-FOOD > 0) and whose food is below 24 starts eating that item (HUNGER-USE-ITEM);
*> food at 24, creative mode or no food item held does nothing. When 30 ticks have passed since the
*> start (HUNGER-TICK) and the held slot still holds that item, one item leaves the slot, food rises
*> by the item's value up to 24, and the player is sent Set Health and Container Set Slot of the
*> slot, then Entity Event 9 (eating finished), which every player that has the player's entity is
*> sent too. Player Action 6 RELEASE_USE_ITEM, a change of held slot (INV-HELD), a change of the
*> slot's item, death (HEALTH-DIE) or creative mode before then cancel it (HUNGER-CANCEL): nothing
*> is eaten.
*>
*> Per tick (HUNGER-TICK, from HEALTH-TICK, step 4 of §9.5, after the hurt cooldown): eating
*> completion, exhaustion from time (0.005), then starvation: while food is 0 a counter counts the
*> consecutive ticks and at 60 the player takes 1 starvation damage (HEALTH-DAMAGE, which can kill)
*> and the counter returns to 0; it returns to 0 whenever food is above 0.
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
*> alive survival player and removes food points (see above).
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
     COMPUTE PL-EXHAUSTION(WS-ROW) = PL-EXHAUSTION(WS-ROW) + L-AMOUNT
     COMPUTE WS-LIMIT = RULE-EXHAUST-FOOD-MILLI / 1000
     PERFORM UNTIL PL-EXHAUSTION(WS-ROW) < WS-LIMIT - 0.000000001
         COMPUTE PL-EXHAUSTION(WS-ROW) = FUNCTION MAX(0, PL-EXHAUSTION(WS-ROW) - WS-LIMIT)
         IF PL-FOOD(WS-ROW) > 0
             SUBTRACT 1 FROM PL-FOOD(WS-ROW)
             CALL "HEALTH-SEND" USING WS-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM HUNGER-EXHAUST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HUNGER-USE-ITEM.
*> USING connection id, PLAY-SERVERBOUND (a decoded Use Item 0x43): starts eating (see above).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY ITEMS.
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
*> USING player row (BINARY-LONG) of an alive player: eating completion, exhaustion from time and
*> starvation (see above).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY ITEMS.
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
 01 WS-NO-ENTITY           BINARY-LONG VALUE 0.
 01 WS-NO-ATTACKER         BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE L-ROW TO WS-ROW
     IF PL-MODE(WS-ROW) NOT = 0
         MOVE 0 TO PL-EATING-ITEM(WS-ROW) PL-STARVE-TICKS(WS-ROW)
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
*>   Exhaustion from time (§11.2) and food point removal (§11.3).
     COMPUTE WS-AMOUNT = RULE-EXHAUST-TICK-MILLI / 1000
     CALL "HUNGER-EXHAUST" USING WS-ROW WS-AMOUNT
*>   Starvation (§10.3).
     IF PL-FOOD(WS-ROW) > 0
         MOVE 0 TO PL-STARVE-TICKS(WS-ROW)
         GOBACK
     END-IF
     ADD 1 TO PL-STARVE-TICKS(WS-ROW)
     IF PL-STARVE-TICKS(WS-ROW) >= RULE-STARVE-TICKS
         MOVE 0 TO PL-STARVE-TICKS(WS-ROW)
         MOVE CAUSE-STARVATION TO WS-CAUSE
         CALL "HEALTH-DAMAGE" USING WS-ROW RULE-CAUSE-AMOUNT(WS-CAUSE) WS-CAUSE WS-NO-ENTITY
             WS-NO-ATTACKER
     END-IF
     GOBACK.
 END PROGRAM HUNGER-TICK.
