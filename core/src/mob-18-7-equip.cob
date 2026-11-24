*> The per-slot stack model of a mob and its loot pickup (docs/protocol/18-mob-framework.md sections 2.7 step 2 and 7.2, 20 sections 3.6 and 4.1; wrap I3 round 6, T2272/T2273).
*> The slots are head, chest, legs, feet, main hand (the order of EN-EQUIP). What the older model keeps (EN-EQUIP tier and count, EN-HAND code or 1000 + item id, EN-HEAD-WEAR) is the
*> worn stack of a slot until the mob picks a piece up; a picked-up piece lives in WC-EQ of WCSTATE.cpy (the item id, the patch handle of its components and the guaranteed-drop flag).
*> Not modelled (recorded on T2272): the off hand (a shield stays on the ground), the preferred weapon tags of the skeleton, drowned and pillager families (MF-PREF is 0, so the weapon rule is
*> the attack damage then the equal rule), a patch attribute_modifiers component (the item tables give armor, toughness and attack damage), the wither skeleton's disliked tag, saving and
*> the sun protection of a picked-up helmet, and a death drop of the picked-up pieces.
*>
*>   M187-SLOT-OF-ITEM USING item, slot out                       getEquipmentSlotForItem: 1 head, 2 chest, 3 legs, 4 feet, 5 main hand (any other item), 6 off hand (a shield)
*>   M187-STACK-FACTS USING item, patch handle, slot, base armor, base toughness, base attack damage (FLOAT-LONG), facts out     the facts canReplaceCurrentItem reads (M187FACTS.cpy)
*>   M187-BASES USING row, base armor, base toughness, base attack damage out (FLOAT-LONG)       the mob's own attribute values
*>   MOB-EQ-GET USING row, slot (1 to 5), item out, patch handle out, wear out                   the stack worn or held in a slot (item 0 when empty)
*>   MOB-EQUIP-IF-POSSIBLE USING row, item, count, patch handle, taken out                       Mob.equipItemIfPossible: how many of the stack the mob took (0 or 1)
*>   MOB-LOOT-PICKUP-TICK USING row                                                               Mob.aiStep loot pickup of a row with canPickUpLoot
*>   MOB-LOOT-ROLL USING row, special multiplier (thousandths)                                    finalizeSpawn: canPickUpLoot with probability 0.55 x special for the zombie and skeleton families

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M187-SLOT-OF-ITEM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-KIND                BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-SLOT.
     MOVE 5 TO L-SLOT
     CALL "MENU-EQUIP-KIND" USING L-ITEM WS-KIND
     EVALUATE WS-KIND
         WHEN 1 MOVE 4 TO L-SLOT
         WHEN 2 MOVE 3 TO L-SLOT
         WHEN 3 MOVE 2 TO L-SLOT
         WHEN 4 MOVE 1 TO L-SLOT
         WHEN 5 MOVE 6 TO L-SLOT
     END-EVALUATE
     IF L-ITEM > 0 AND L-ITEM < IT-COUNT
         MOVE IT-KEY-LENGTH(L-ITEM + 1) TO WS-LEN
         IF IT-KEY(L-ITEM + 1)(1:WS-LEN) = "minecraft:carved_pumpkin" OR "carved_pumpkin"
             MOVE 1 TO L-SLOT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM M187-SLOT-OF-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M187-STACK-FACTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 COPY M187MODS REPLACING LEADING ==MM-== BY ==WS-M-==.
 01 WS-LEN                 BINARY-LONG.
 01 WS-KEY48               PIC X(48).
 01 WS-FOUND               BINARY-LONG.
 01 WS-DURABILITY          BINARY-LONG.
 01 WS-DEFENSE             BINARY-LONG.
 01 WS-TOUGHNESS           BINARY-LONG.
 01 WS-KNOCKBACK           BINARY-LONG.
 01 WS-ENCHANT             BINARY-LONG.
 01 WS-REPAIR              PIC X(40).
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-SPEED               BINARY-LONG.
 01 WS-COOLDOWN            BINARY-LONG.
 01 WS-MINING              BINARY-LONG.
 01 WS-ISLOT               BINARY-LONG.
 01 WS-ASLOT               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ATTR                BINARY-LONG.
 01 WS-TYPE13              BINARY-LONG VALUE 13.
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-CURSE-KEY           PIC X(112) VALUE "minecraft:binding_curse".
 01 WS-CURSE               BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-BASE-ARMOR           FLOAT-LONG.
 01 L-BASE-TOUGH           FLOAT-LONG.
 01 L-BASE-DAMAGE          FLOAT-LONG.
 COPY M187FACTS REPLACING LEADING ==MF-== BY ==L-F-==.
 PROCEDURE DIVISION USING L-ITEM L-VAR L-SLOT L-BASE-ARMOR L-BASE-TOUGH L-BASE-DAMAGE L-F-FACTS.
     INITIALIZE L-F-FACTS
     IF L-ITEM <= 0 OR L-ITEM >= IT-COUNT
         MOVE 1 TO L-F-EMPTY
         GOBACK
     END-IF
     INITIALIZE WS-M-MODS
     MOVE 0 TO WS-COUNT
     MOVE IT-KEY-LENGTH(L-ITEM + 1) TO WS-LEN
     MOVE SPACES TO WS-KEY48
     MOVE IT-KEY(L-ITEM + 1)(1:WS-LEN) TO WS-KEY48
     CALL "M187-SLOT-OF-ITEM" USING L-ITEM WS-ISLOT
*>   The item tables: an armor piece carries armor and toughness (tenths) in the slot group of its own slot, a tool or weapon its attack damage modifier (the player's total less 1) in the main hand.
     CALL "TOOL-ARMOR-ITEM" USING WS-KEY48 WS-FOUND WS-DURABILITY WS-DEFENSE WS-TOUGHNESS WS-KNOCKBACK WS-ENCHANT WS-REPAIR
     IF WS-FOUND = 1 AND WS-ISLOT >= 1 AND WS-ISLOT <= 4
         ADD 1 TO WS-COUNT
         MOVE 1 TO WS-M-ATTR(WS-COUNT)
         COMPUTE WS-M-GROUP(WS-COUNT) = 9 - WS-ISLOT
         MOVE 0 TO WS-M-OP(WS-COUNT)
         MOVE WS-DEFENSE TO WS-M-AMOUNT(WS-COUNT)
         ADD 1 TO WS-COUNT
         MOVE 2 TO WS-M-ATTR(WS-COUNT)
         COMPUTE WS-M-GROUP(WS-COUNT) = 9 - WS-ISLOT
         MOVE 0 TO WS-M-OP(WS-COUNT)
         COMPUTE WS-M-AMOUNT(WS-COUNT) = WS-TOUGHNESS / 10
     END-IF
     CALL "TOOL-ITEM-STATS" USING WS-KEY48 WS-FOUND WS-DURABILITY WS-DAMAGE WS-SPEED WS-COOLDOWN WS-MINING
     IF WS-FOUND = 1
         ADD 1 TO WS-COUNT
         MOVE 3 TO WS-M-ATTR(WS-COUNT)
         MOVE 2 TO WS-M-GROUP(WS-COUNT)
         MOVE 0 TO WS-M-OP(WS-COUNT)
         COMPUTE WS-M-AMOUNT(WS-COUNT) = (WS-DAMAGE - 10000) / 10000
     END-IF
*>   The slot of the mob (1 to 4 armor, 5 main hand, 6 off hand) as a slot of the group list: head 8, chest 7, legs 6, feet 5, mainhand 2, offhand 3.
     EVALUATE TRUE
         WHEN L-SLOT >= 1 AND L-SLOT <= 4
             COMPUTE WS-ASLOT = 9 - L-SLOT
         WHEN L-SLOT = 5
             MOVE 2 TO WS-ASLOT
         WHEN OTHER
             MOVE 3 TO WS-ASLOT
     END-EVALUATE
     MOVE 1 TO WS-ATTR
     CALL "M187-APPROX-ATTR" USING L-BASE-ARMOR WS-ATTR WS-ASLOT WS-COUNT WS-M-MODS L-F-ARMOR
     MOVE 2 TO WS-ATTR
     CALL "M187-APPROX-ATTR" USING L-BASE-TOUGH WS-ATTR WS-ASLOT WS-COUNT WS-M-MODS L-F-TOUGH
     MOVE 3 TO WS-ATTR
     CALL "M187-APPROX-ATTR" USING L-BASE-DAMAGE WS-ATTR WS-ASLOT WS-COUNT WS-M-MODS L-F-DAMAGE
     IF L-VAR > 0
         CALL "SC-ENCH-COUNT" USING L-VAR WS-TYPE13 L-F-ENCH
         CALL "SP-GET-DAMAGE" USING L-ITEM L-VAR L-F-WEAR
         CALL "SP-GET-NAME" USING L-VAR WS-NAME WS-NAME-LENGTH
         IF WS-NAME-LENGTH > 0
             MOVE 1 TO L-F-NAMED
         END-IF
         CALL "TOOL-ENCHANT-ID" USING WS-CURSE-KEY WS-CURSE
         CALL "SP-ENCHANT-LEVEL" USING L-VAR WS-CURSE WS-LEVEL
         IF WS-LEVEL > 0
             MOVE 1 TO L-F-BINDING
         END-IF
     END-IF
     GOBACK.
 END PROGRAM M187-STACK-FACTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M187-BASES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-KEY                 PIC X(24).
 01 WS-M                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-BASE-ARMOR           FLOAT-LONG.
 01 L-BASE-TOUGH           FLOAT-LONG.
 01 L-BASE-DAMAGE          FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-BASE-ARMOR L-BASE-TOUGH L-BASE-DAMAGE.
*> USING row, base armor, base toughness, base attack damage out (FLOAT-LONG): the mob's own attribute values that getApproximateAttributeWith starts from (0 when the mob lacks the attribute): armor 2.0
*> for the zombie family (as MOB-ARMOR-POINTS), no base toughness, the attack damage of the species table.
     MOVE 0 TO L-BASE-ARMOR L-BASE-TOUGH L-BASE-DAMAGE
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = "zombie" OR "zombie_villager" OR "husk"
         MOVE 2 TO L-BASE-ARMOR
     END-IF
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M > 0
         MOVE SM-ATTACK(WS-M) TO L-BASE-DAMAGE
     END-IF
     GOBACK.
 END PROGRAM M187-BASES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-EQ-GET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 COPY CONTENT.
 01 WS-TIER                BINARY-LONG.
 01 WS-SLOTS               BINARY-LONG.
 01 WS-KEY40               PIC X(40).
 01 WS-KEY                 PIC X(112).
 01 WS-ROWDATA             PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 01 L-WEAR                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ITEM L-VAR L-WEAR.
*> USING row, slot (1 head, 2 chest, 3 legs, 4 feet, 5 main hand), item out, patch handle out, wear out: (an item the table does not know is 0, as CONTENT-ITEM-BY-KEY leaves it) the stack a mob wears or holds in the slot (item 0 and handle 0 when it is empty). A piece the mob
*> picked up (WC-EQ-ITEM) wins; otherwise the armor of EN-EQUIP (tier and prefix count; a broken helmet is empty, the helmet's wear is EN-HEAD-WEAR) or the main hand EN-HAND (a code or 1000 + item id).
     CALL "WC-ROW-OPEN" USING L-ROW
     MOVE 0 TO L-ITEM L-VAR L-WEAR
     EVALUATE TRUE
         WHEN L-SLOT >= 1 AND L-SLOT <= 4 AND WC-EQ-ITEM(L-ROW, L-SLOT) > 0
             MOVE WC-EQ-ITEM(L-ROW, L-SLOT) TO L-ITEM
             MOVE WC-EQ-VAR(L-ROW, L-SLOT) TO L-VAR
             IF L-VAR > 0
                 CALL "SP-GET-DAMAGE" USING L-ITEM L-VAR L-WEAR
             END-IF
         WHEN L-SLOT >= 1 AND L-SLOT <= 4
             MOVE 0 TO WS-SLOTS WS-TIER
             IF EN-EQUIP(L-ROW) > 0
                 COMPUTE WS-TIER = EN-EQUIP(L-ROW) / 10 - 1
                 COMPUTE WS-SLOTS = FUNCTION MOD(EN-EQUIP(L-ROW), 10)
             END-IF
             IF L-SLOT <= WS-SLOTS AND NOT (L-SLOT = 1 AND EN-HEAD-WEAR(L-ROW) = -1)
                 CALL "STDMOB-EQUIP-KEY" USING WS-TIER L-SLOT WS-KEY40
                 MOVE SPACES TO WS-KEY
                 MOVE WS-KEY40 TO WS-KEY
                 CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY L-ITEM WS-ROWDATA WS-STATUS
                 IF L-SLOT = 1 AND EN-HEAD-WEAR(L-ROW) > 0
                     MOVE EN-HEAD-WEAR(L-ROW) TO L-WEAR
                 END-IF
             END-IF
         WHEN L-SLOT = 5 AND EN-HAND(L-ROW) > 0
             CALL "STDMOB-HAND-KEY" USING EN-HAND(L-ROW) WS-KEY40
             IF WS-KEY40 NOT = SPACES
                 MOVE SPACES TO WS-KEY
                 MOVE WS-KEY40 TO WS-KEY
                 CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY L-ITEM WS-ROWDATA WS-STATUS
             END-IF
             IF L-ITEM > 0
                 MOVE WC-EQ-VAR(L-ROW, 5) TO L-VAR
                 IF L-VAR > 0
                     CALL "SP-GET-DAMAGE" USING L-ITEM L-VAR L-WEAR
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM MOB-EQ-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-EQUIP-IF-POSSIBLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 COPY M187FACTS REPLACING LEADING ==MF-== BY ==WS-C-==.
 COPY M187FACTS REPLACING LEADING ==MF-== BY ==WS-U-==.
 01 WS-SLOT                BINARY-LONG.
 01 WS-YES                 BINARY-LONG.
 01 WS-BASE-ARMOR          FLOAT-LONG.
 01 WS-BASE-TOUGH          FLOAT-LONG.
 01 WS-BASE-DAMAGE         FLOAT-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-OLD-VAR             BINARY-LONG.
 01 WS-OLD-WEAR            BINARY-LONG.
 01 WS-HAND                BINARY-LONG.
 01 WS-HAND-VAR            BINARY-LONG.
 01 WS-HAND-WEAR           BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 71.
 01 WS-BOUND               BINARY-LONG VALUE 100000.
 01 WS-DRAW                BINARY-LONG.
 01 WS-DRAW-F              FLOAT-LONG.
 01 WS-CHANCE              FLOAT-LONG.
 01 WS-DROP                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 10.
 01 WS-SPAWNED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 01 L-TAKEN                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEM L-COUNT L-VAR L-TAKEN.
*> USING row, item, count, patch handle, taken out: Mob.equipItemIfPossible (7.2): the slot is the item's own (an off-hand item has no slot here and is refused); canReplaceCurrentItem against what the slot holds;
*> when an armor slot refuses, the main hand is tried instead and takes the item only when it is empty. When it replaces: an old stack that is not empty is dropped as an item entity when
*> max(nextFloat - 0.1, 0) < the slot's drop chance (0.085, or 2 for a stack picked up earlier; the draw is made only for a non-empty old stack), the new stack (one of it, the slot's limit) is stored with a
*> guaranteed drop (WC-EQ-KEEP) and the mob never despawns (EN-PERSISTENT). The viewers get Set Equipment. taken is 1 or 0.
     CALL "WC-ROW-OPEN" USING L-ROW
     MOVE 0 TO L-TAKEN
     IF L-ITEM <= 0 OR L-COUNT <= 0
         GOBACK
     END-IF
     CALL "M187-SLOT-OF-ITEM" USING L-ITEM WS-SLOT
     IF WS-SLOT = 6
         GOBACK
     END-IF
     CALL "M187-BASES" USING L-ROW WS-BASE-ARMOR WS-BASE-TOUGH WS-BASE-DAMAGE
     CALL "MOB-EQ-GET" USING L-ROW WS-SLOT WS-OLD WS-OLD-VAR WS-OLD-WEAR
     CALL "M187-STACK-FACTS" USING L-ITEM L-VAR WS-SLOT WS-BASE-ARMOR WS-BASE-TOUGH WS-BASE-DAMAGE WS-C-FACTS
     CALL "M187-STACK-FACTS" USING WS-OLD WS-OLD-VAR WS-SLOT WS-BASE-ARMOR WS-BASE-TOUGH WS-BASE-DAMAGE WS-U-FACTS
     IF WS-OLD > 0 AND WS-OLD-VAR = 0
         MOVE WS-OLD-WEAR TO WS-U-WEAR
     END-IF
     CALL "M187-CAN-REPLACE" USING WS-SLOT WS-C-FACTS WS-U-FACTS WS-YES
     IF WS-YES = 0 AND WS-SLOT <= 4
*>       An armor piece the slot refuses goes to the main hand when that is empty (replace only if the main hand is empty).
         MOVE 5 TO WS-SLOT
         CALL "MOB-EQ-GET" USING L-ROW WS-SLOT WS-HAND WS-HAND-VAR WS-HAND-WEAR
         IF WS-HAND = 0
             MOVE 1 TO WS-YES
             MOVE 0 TO WS-OLD WS-OLD-VAR WS-OLD-WEAR
         END-IF
     END-IF
     IF WS-YES = 0
         GOBACK
     END-IF
     IF WS-OLD > 0
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
         COMPUTE WS-DRAW-F = WS-DRAW / 100000
         MOVE 0.085 TO WS-CHANCE
         IF WC-EQ-KEEP(L-ROW, WS-SLOT) = 1
             MOVE 2 TO WS-CHANCE
         END-IF
         CALL "M187-DROP-TEST" USING WS-DRAW-F WS-CHANCE WS-DROP
         IF WS-DROP = 1
             MOVE EN-X(L-ROW) TO WS-X
             MOVE EN-Y(L-ROW) TO WS-Y
             MOVE EN-Z(L-ROW) TO WS-Z
             CALL "GI-SPAWN-RANDOM" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-OLD WS-ONE WS-OLD-VAR WS-DELAY WS-SPAWNED
         END-IF
     END-IF
     IF WS-SLOT = 5
         COMPUTE EN-HAND(L-ROW) = 1000 + L-ITEM
     ELSE
         MOVE L-ITEM TO WC-EQ-ITEM(L-ROW, WS-SLOT)
     END-IF
     MOVE L-VAR TO WC-EQ-VAR(L-ROW, WS-SLOT)
     MOVE 1 TO WC-EQ-KEEP(L-ROW, WS-SLOT)
     MOVE 1 TO EN-PERSISTENT(L-ROW)
     CALL "STDMOB-EQUIP-SEND" USING L-ROW
     MOVE 1 TO L-TAKEN
     GOBACK.
 END PROGRAM MOB-EQUIP-IF-POSSIBLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-LOOT-PICKUP-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY CITEMPHYS.
 COPY WCSTATE.
 01 WS-RULE-NAME           PIC X(40) VALUE "mob_griefing".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-E                   BINARY-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-LEN                 BINARY-LONG.
 01 WS-REFUSE              BINARY-LONG.
 01 WS-TAKEN               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
*> USING row: the loot pickup of Mob.aiStep (2.7 step 2) for a row with canPickUpLoot that is alive and under the game rule mob_griefing: each item entity that is not empty, has no pickup delay and lies within
*> the mob's box inflated by 1 horizontally (the item's half width 0.125 on top) is offered to MOB-EQUIP-IF-POSSIBLE; the taken count leaves the entity, which is removed when empty. A zombie never picks up
*> a glow ink sac (20 section 4.1), a skeleton refuses the items of the tag spears (20 section 5).
     CALL "WC-ROW-OPEN" USING L-ROW
     IF WC-LOOT(L-ROW) = 0 OR EN-HEALTH(L-ROW) <= 0
         GOBACK
     END-IF
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     IF WS-RULE = 0
         GOBACK
     END-IF
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     COMPUTE WS-HALF = ET-WIDTH-MILLI(EN-TYPE(L-ROW) + 1) / 2000 + 1.125
     COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(EN-TYPE(L-ROW) + 1) / 1000
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = CR-LOOSE-ITEM AND EN-DIM(WS-E) = EN-DIM(L-ROW)
                 AND EN-ITEM-COUNT(WS-E) > 0 AND EN-DELAY(WS-E) <= 0
             IF FUNCTION ABS(EN-X(WS-E) - EN-X(L-ROW)) < WS-HALF AND FUNCTION ABS(EN-Z(WS-E) - EN-Z(L-ROW)) < WS-HALF
                     AND EN-Y(WS-E) >= EN-Y(L-ROW) - 0.25 AND EN-Y(WS-E) < EN-Y(L-ROW) + WS-HEIGHT
                 MOVE 0 TO WS-REFUSE
                 MOVE IT-KEY-LENGTH(EN-ITEM(WS-E) + 1) TO WS-LEN
                 IF WS-KEY = "zombie" OR "zombie_villager" OR "husk" OR "drowned"
                     IF IT-KEY(EN-ITEM(WS-E) + 1)(1:WS-LEN) = "minecraft:glow_ink_sac" OR "glow_ink_sac"
                         MOVE 1 TO WS-REFUSE
                     END-IF
                 END-IF
                 IF WS-KEY = "skeleton" OR "stray" OR "bogged" OR "parched"
                     IF WS-LEN >= 6 AND IT-KEY(EN-ITEM(WS-E) + 1)(WS-LEN - 5:6) = "_spear"
                         MOVE 1 TO WS-REFUSE
                     END-IF
                 END-IF
                 IF WS-REFUSE = 0
                     CALL "MOB-EQUIP-IF-POSSIBLE" USING L-ROW EN-ITEM(WS-E) EN-ITEM-COUNT(WS-E) IP-I-VAR(WS-E) WS-TAKEN
                     SUBTRACT WS-TAKEN FROM EN-ITEM-COUNT(WS-E)
                     IF WS-TAKEN > 0 AND EN-ITEM-COUNT(WS-E) = 0
                         CALL "ENTITY-REMOVE" USING WS-E
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MOB-LOOT-PICKUP-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-LOOT-ROLL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 01 WS-KEY                 PIC X(24).
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-LIMIT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SPECIAL              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SPECIAL.
*> USING row, special multiplier (thousandths): finalizeSpawn sets canPickUpLoot with probability 0.55 x the special multiplier (20 sections 3.6, 4.1 step 1, 5) for the zombie family, the drowned and the
*> skeleton family. The draw is a hash of the entity id and the time (salt 41), not the spawn's xoroshiro state, so the draws of the species' own finalize do not move.
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY = "zombie" OR "zombie_villager" OR "husk" OR "drowned" OR "skeleton" OR "stray" OR "bogged" OR "parched"
         CALL "WC-ROW-OPEN" USING L-ROW
         MOVE EN-ID(L-ROW) TO WS-ARG(1)
         MOVE CW-TIME TO WS-ARG(2)
         MOVE 41 TO WS-ARG(3)
         CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
         COMPUTE WS-LIMIT = 5500 * L-SPECIAL / 1000
         IF FUNCTION MOD(WS-R, 10000) < WS-LIMIT
             MOVE 1 TO WC-LOOT(L-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOB-LOOT-ROLL.
