*> Acceptance test of docs/protocol/18-mob-framework.md section 7.2 (Which items a mob wants) and 44-1 RQ-1.3 with its worked case E3 (lane wrap I3, T2272/T2273): the pure rules
*> canReplaceCurrentItem, compareArmor, compareWeapons, getApproximateAttributeWith and canReplaceEqualItem on stack facts, the stack facts of real items (armor and toughness of the
*> item tables, enchantments, damage, custom name, the binding curse), the drop test of equipItemIfPossible, then the per-slot stack model of a mob row: equipItemIfPossible
*> (the main-hand fallback of a refused armour piece, the replaced stack and its drop chance, the guaranteed drop and persistence flags), the armour points and Set Equipment
*> of a picked-up piece, and the loot pickup of a row that canPickUpLoot (mob_griefing, reach, pickup delay), with the flag rolled at spawn.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-7-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY WCSTATE.
 COPY CITEMS.
 COPY BRWORLD.
 COPY XORO.
 COPY M187MODS.
 COPY M187FACTS REPLACING LEADING ==MF-== BY ==CA-==.
 COPY M187FACTS REPLACING LEADING ==MF-== BY ==CU-==.
 COPY PROTO.
 01 WS-CASE                PIC X(200).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-YES                 BINARY-LONG.
 01 WS-GROUP               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ATTR                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BASE                FLOAT-LONG.
 01 WS-RESULT              FLOAT-LONG.
 01 WS-DRAW                FLOAT-LONG.
 01 WS-CHANCE              FLOAT-LONG.
 01 WS-SCALED              BINARY-LONG.
 01 WS-KEY32               PIC X(32).
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM2               BINARY-LONG.
 01 WS-HELM-IRON           BINARY-LONG.
 01 WS-HELM-CHAIN          BINARY-LONG.
 01 WS-HELM-DIAMOND        BINARY-LONG.
 01 WS-HELM-LEATHER        BINARY-LONG.
 01 WS-HELM-GOLD           BINARY-LONG.
 01 WS-CHEST-DIAMOND       BINARY-LONG.
 01 WS-SWORD-IRON          BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-HANDLE2             BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG VALUE 1.
 01 WS-ENCH-ID             BINARY-LONG.
 01 WS-ENCH-KEY            PIC X(112).
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 4.
 01 WS-WEAR                BINARY-LONG.
 01 WS-BASE-ARMOR          FLOAT-LONG.
 01 WS-BASE-TOUGH          FLOAT-LONG.
 01 WS-BASE-DAMAGE         FLOAT-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-LOOSE               BINARY-LONG.
 01 WS-KEY112              PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG VALUE 9.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-DELAY               BINARY-LONG.
 01 WS-TAKEN               BINARY-LONG.
 01 WS-ARMOR               BINARY-LONG.
 01 WS-TOUGHNESS           BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DROPS               BINARY-LONG.
 01 WS-TAKEN-SUM           BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-FLAGGED             BINARY-LONG.
 01 WS-RULE-NAME           PIC X(40) VALUE "mob_griefing".
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-REGISTRY-DIR        PIC X(1100) VALUE "core/tests/fixtures/mount-registry".
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OFF                 BINARY-LONG.
 01 WS-VIEW BASED.
    05 WS-BYTE             PIC X OCCURS 4096 TIMES.
 PROCEDURE DIVISION.
*>   ---- groups: the slot group list of 04 (any, mainhand, offhand, hand, feet, legs, chest, head, armor, body, saddle)
     MOVE "acceptance US15 18§7.2 slot group any holds the chest slot" TO WS-CASE
     MOVE 1 TO WS-GROUP
     MOVE 7 TO WS-SLOT
     MOVE 1 TO WS-EXP
     PERFORM GROUP-CASE
     MOVE "acceptance US15 18§7.2 slot group hand holds the main hand" TO WS-CASE
     MOVE 4 TO WS-GROUP
     MOVE 2 TO WS-SLOT
     PERFORM GROUP-CASE
     MOVE "acceptance US15 18§7.2 slot group hand holds the off hand" TO WS-CASE
     MOVE 3 TO WS-SLOT
     PERFORM GROUP-CASE
     MOVE "acceptance US15 18§7.2 slot group hand does not hold the head" TO WS-CASE
     MOVE 8 TO WS-SLOT
     MOVE 0 TO WS-EXP
     PERFORM GROUP-CASE
     MOVE "acceptance US15 18§7.2 slot group armor holds the feet" TO WS-CASE
     MOVE 9 TO WS-GROUP
     MOVE 5 TO WS-SLOT
     MOVE 1 TO WS-EXP
     PERFORM GROUP-CASE
     MOVE "acceptance US15 18§7.2 slot group armor does not hold the main hand" TO WS-CASE
     MOVE 2 TO WS-SLOT
     MOVE 0 TO WS-EXP
     PERFORM GROUP-CASE
     MOVE "acceptance US15 18§7.2 slot group chest holds the chest only" TO WS-CASE
     MOVE 7 TO WS-GROUP
     MOVE 7 TO WS-SLOT
     MOVE 1 TO WS-EXP
     PERFORM GROUP-CASE
     MOVE "acceptance US15 18§7.2 slot group chest does not hold the legs" TO WS-CASE
     MOVE 6 TO WS-SLOT
     MOVE 0 TO WS-EXP
     PERFORM GROUP-CASE
     MOVE "acceptance US15 18§7.2 slot group body holds the body slot" TO WS-CASE
     MOVE 10 TO WS-GROUP
     MOVE 10 TO WS-SLOT
     MOVE 1 TO WS-EXP
     PERFORM GROUP-CASE
*>   ---- getApproximateAttributeWith: one modifier of 2 armor in the armor group, asked for the head
     INITIALIZE MM-MODS
     MOVE 1 TO MM-ATTR(1)
     MOVE 9 TO MM-GROUP(1)
     MOVE 0 TO MM-OP(1)
     MOVE 2 TO MM-AMOUNT(1)
     MOVE 0 TO WS-BASE
     MOVE 1 TO WS-ATTR
     MOVE 8 TO WS-SLOT
     MOVE 1 TO WS-COUNT
     MOVE "acceptance US15 18§7.2 approx attribute: base 0 plus add_value 2 is 2" TO WS-CASE
     MOVE 2000 TO WS-EXP
     PERFORM APPROX-CASE
     MOVE "acceptance US15 18§7.2 approx attribute: a modifier of another attribute is ignored" TO WS-CASE
     MOVE 2 TO WS-ATTR
     MOVE 0 TO WS-EXP
     PERFORM APPROX-CASE
     MOVE "acceptance US15 18§7.2 approx attribute: a modifier whose group lacks the slot is ignored" TO WS-CASE
     MOVE 1 TO WS-ATTR
     MOVE 2 TO WS-SLOT
     MOVE 0 TO WS-EXP
     PERFORM APPROX-CASE
*>   base 4: add_multiplied_base 0.5 adds 0.5 x base
     INITIALIZE MM-MODS
     MOVE 3 TO MM-ATTR(1) MM-ATTR(2)
     MOVE 1 TO MM-GROUP(1) MM-GROUP(2)
     MOVE 1 TO MM-OP(1)
     MOVE 0.5 TO MM-AMOUNT(1)
     MOVE 4 TO WS-BASE
     MOVE 3 TO WS-ATTR
     MOVE 2 TO WS-SLOT
     MOVE 1 TO WS-COUNT
     MOVE "acceptance US15 18§7.2 approx attribute: add_multiplied_base 0.5 on base 4 is 6" TO WS-CASE
     MOVE 6000 TO WS-EXP
     PERFORM APPROX-CASE
*>   [add_value 2, add_multiplied_base 0.5]: 4 + 2 = 6, then + 0.5 x base (4) = 8
     MOVE 0 TO MM-OP(1)
     MOVE 2 TO MM-AMOUNT(1)
     MOVE 1 TO MM-OP(2)
     MOVE 0.5 TO MM-AMOUNT(2)
     MOVE 2 TO WS-COUNT
     MOVE "acceptance US15 18§7.2 approx attribute: multiplied_base uses the base, not the running value (8)" TO WS-CASE
     MOVE 8000 TO WS-EXP
     PERFORM APPROX-CASE
*>   [add_value 2, add_multiplied_total 0.5]: 6 + 0.5 x 6 = 9
     MOVE 2 TO MM-OP(2)
     MOVE "acceptance US15 18§7.2 approx attribute: multiplied_total multiplies the running value (9)" TO WS-CASE
     MOVE 9000 TO WS-EXP
     PERFORM APPROX-CASE
*>   list order: [add_multiplied_total 0.5, add_value 2]: 4 + 0.5 x 4 = 6, then + 2 = 8
     MOVE 2 TO MM-OP(1)
     MOVE 0.5 TO MM-AMOUNT(1)
     MOVE 0 TO MM-OP(2)
     MOVE 2 TO MM-AMOUNT(2)
     MOVE "acceptance US15 18§7.2 approx attribute: a single pass in list order (8, not 9)" TO WS-CASE
     MOVE 8000 TO WS-EXP
     PERFORM APPROX-CASE
*>   count 1 reads only the first entry
     MOVE 1 TO WS-COUNT
     MOVE "acceptance US15 18§7.2 approx attribute: only count entries are read (6)" TO WS-CASE
     MOVE 6000 TO WS-EXP
     PERFORM APPROX-CASE
     MOVE 12 TO WS-COUNT
     MOVE "acceptance US15 18§7.2 approx attribute: a count above 8 reads only the 8 entries of the list (8)" TO WS-CASE
     MOVE 0 TO MM-OP(1)
     MOVE 2 TO MM-OP(1)
     MOVE 8000 TO WS-EXP
     PERFORM APPROX-CASE
*>   ---- canReplaceEqualItem
     PERFORM CLEAR-FACTS
     MOVE 2 TO CA-ENCH
     MOVE 1 TO CU-ENCH
     MOVE "acceptance US15 18§7.2 equal item: more enchantments in the candidate replaces" TO WS-CASE
     MOVE 1 TO WS-EXP
     PERFORM EQUAL-CASE
     MOVE 1 TO CA-ENCH
     MOVE 2 TO CU-ENCH
     MOVE 90 TO CA-WEAR
     MOVE "acceptance US15 18§7.2 equal item: fewer enchantments does not, whatever the wear" TO WS-CASE
     MOVE 0 TO WS-EXP
     PERFORM EQUAL-CASE
     PERFORM CLEAR-FACTS
     MOVE 10 TO CA-WEAR
     MOVE 40 TO CU-WEAR
     MOVE "acceptance US15 18§7.2 equal item: the less worn candidate replaces (10 against 40)" TO WS-CASE
     MOVE 1 TO WS-EXP
     PERFORM EQUAL-CASE
     MOVE 40 TO CA-WEAR
     MOVE 10 TO CU-WEAR
     MOVE "acceptance US15 18§7.2 equal item: the more worn candidate does not (40 against 10)" TO WS-CASE
     MOVE 0 TO WS-EXP
     PERFORM EQUAL-CASE
     PERFORM CLEAR-FACTS
     MOVE 1 TO CA-NAMED
     MOVE "acceptance US15 18§7.2 equal item: a named candidate replaces an unnamed current" TO WS-CASE
     MOVE 1 TO WS-EXP
     PERFORM EQUAL-CASE
     MOVE 1 TO CU-NAMED
     MOVE "acceptance US15 18§7.2 equal item: both named does not" TO WS-CASE
     MOVE 0 TO WS-EXP
     PERFORM EQUAL-CASE
     MOVE 0 TO CA-NAMED
     MOVE "acceptance US15 18§7.2 equal item: an unnamed candidate against a named current does not" TO WS-CASE
     PERFORM EQUAL-CASE
     PERFORM CLEAR-FACTS
     MOVE "acceptance US15 18§7.2 equal item: identical stacks do not replace" TO WS-CASE
     PERFORM EQUAL-CASE
*>   ---- compareArmor
     PERFORM CLEAR-FACTS
     MOVE 3 TO CA-ARMOR
     MOVE 2 TO CU-ARMOR
     MOVE "acceptance US15 18§7.2 compareArmor: more armor replaces" TO WS-CASE
     MOVE 1 TO WS-EXP
     PERFORM ARMOR-CASE
     MOVE 1 TO CA-ARMOR
     MOVE "acceptance US15 18§7.2 compareArmor: less armor does not, even with more toughness" TO WS-CASE
     MOVE 5 TO CA-TOUGH
     MOVE 0 TO WS-EXP
     PERFORM ARMOR-CASE
     PERFORM CLEAR-FACTS
     MOVE 3 TO CA-ARMOR CU-ARMOR
     MOVE 3 TO CA-TOUGH
     MOVE 2 TO CU-TOUGH
     MOVE "acceptance US15 18§7.2 compareArmor: equal armor, more toughness replaces" TO WS-CASE
     MOVE 1 TO WS-EXP
     PERFORM ARMOR-CASE
     MOVE 1 TO CA-TOUGH
     MOVE 1 TO CA-ENCH
     MOVE "acceptance US15 18§7.2 compareArmor: equal armor, less toughness does not (enchantments are not read)" TO WS-CASE
     MOVE 0 TO WS-EXP
     PERFORM ARMOR-CASE
*>   E3: equal armor 2 and toughness 0: the tie-break
     PERFORM CLEAR-FACTS
     MOVE 2 TO CA-ARMOR CU-ARMOR
     MOVE 1 TO CA-ENCH
     MOVE "acceptance US15 18§7.2 E3 compareArmor: equal armor and toughness, one enchantment wins" TO WS-CASE
     MOVE 1 TO WS-EXP
     PERFORM ARMOR-CASE
     MOVE 0 TO CA-ENCH
     MOVE 40 TO CA-WEAR
     MOVE 10 TO CU-WEAR
     MOVE "acceptance US15 18§7.2 E3 compareArmor: no enchantments, damage 40 against 10: the current stays" TO WS-CASE
     MOVE 0 TO WS-EXP
     PERFORM ARMOR-CASE
     MOVE 3 TO CA-ARMOR
     MOVE 1 TO CU-BINDING
     MOVE "acceptance US15 18§7.2 E3 compareArmor: the binding curse on the current refuses a better piece" TO WS-CASE
     PERFORM ARMOR-CASE
*>   ---- compareWeapons
     PERFORM CLEAR-FACTS
     MOVE 3 TO CA-DAMAGE
     MOVE 5 TO CU-DAMAGE
     MOVE 1 TO CU-PREF
     MOVE "acceptance US15 18§7.2 compareWeapons: a preferred current is kept for a non-preferred candidate" TO WS-CASE
     MOVE 0 TO CA-DAMAGE
     MOVE 9 TO CA-DAMAGE
     MOVE 0 TO WS-EXP
     PERFORM WEAPON-CASE
     MOVE 0 TO CU-PREF
     MOVE 1 TO CA-PREF
     MOVE 1 TO CA-DAMAGE
     MOVE 5 TO CU-DAMAGE
     MOVE "acceptance US15 18§7.2 compareWeapons: a preferred candidate replaces a non-preferred current" TO WS-CASE
     MOVE 1 TO WS-EXP
     PERFORM WEAPON-CASE
     MOVE 1 TO CU-PREF
     MOVE 6 TO CA-DAMAGE
     MOVE 4 TO CU-DAMAGE
     MOVE "acceptance US15 18§7.2 compareWeapons: both preferred, more damage replaces" TO WS-CASE
     PERFORM WEAPON-CASE
     MOVE 4 TO CA-DAMAGE
     MOVE 6 TO CU-DAMAGE
     MOVE "acceptance US15 18§7.2 compareWeapons: both preferred, less damage does not" TO WS-CASE
     MOVE 0 TO WS-EXP
     PERFORM WEAPON-CASE
     PERFORM CLEAR-FACTS
     MOVE 6 TO CA-DAMAGE
     MOVE 4 TO CU-DAMAGE
     MOVE "acceptance US15 18§7.2 compareWeapons: no preferred tag, more damage replaces" TO WS-CASE
     MOVE 1 TO WS-EXP
     PERFORM WEAPON-CASE
     MOVE 4 TO CA-DAMAGE
     MOVE 6 TO CU-DAMAGE
     MOVE "acceptance US15 18§7.2 compareWeapons: no preferred tag, less damage does not" TO WS-CASE
     MOVE 0 TO WS-EXP
     PERFORM WEAPON-CASE
     MOVE 5 TO CA-DAMAGE CU-DAMAGE
     MOVE 1 TO CA-ENCH
     MOVE "acceptance US15 18§7.2 compareWeapons: equal damage, the tie-break (an enchantment) replaces" TO WS-CASE
     MOVE 1 TO WS-EXP
     PERFORM WEAPON-CASE
*>   ---- canReplaceCurrentItem
     PERFORM CLEAR-FACTS
     MOVE 1 TO CU-EMPTY
     MOVE "acceptance US15 18§7.2 canReplace: an empty current is replaced in any slot (off hand)" TO WS-CASE
     MOVE 6 TO WS-SLOT
     MOVE 1 TO WS-EXP
     PERFORM REPLACE-CASE
     MOVE 0 TO CU-EMPTY
     MOVE 3 TO CA-ARMOR
     MOVE 2 TO CU-ARMOR
     MOVE "acceptance US15 18§7.2 canReplace: an armor slot compares armor (head)" TO WS-CASE
     MOVE 1 TO WS-SLOT
     PERFORM REPLACE-CASE
     MOVE "acceptance US15 18§7.2 canReplace: the feet slot is an armor slot too" TO WS-CASE
     MOVE 4 TO WS-SLOT
     PERFORM REPLACE-CASE
     MOVE 3 TO CA-DAMAGE
     MOVE 2 TO CU-DAMAGE
     MOVE 0 TO CA-ARMOR CU-ARMOR
     MOVE "acceptance US15 18§7.2 canReplace: the main hand compares weapons (more damage)" TO WS-CASE
     MOVE 5 TO WS-SLOT
     PERFORM REPLACE-CASE
     MOVE "acceptance US15 18§7.2 canReplace: any other slot refuses when the current is not empty" TO WS-CASE
     MOVE 6 TO WS-SLOT
     MOVE 0 TO WS-EXP
     PERFORM REPLACE-CASE
*>   ---- the drop test of equipItemIfPossible: max(nextFloat - 0.1, 0) < c
     MOVE 0.05 TO WS-DRAW
     MOVE 0.085 TO WS-CHANCE
     MOVE "acceptance US15 18§7.2 drop test: a draw under 0.1 counts as 0, below 0.085" TO WS-CASE
     MOVE 1 TO WS-EXP
     PERFORM DROP-CASE
     MOVE 0.15 TO WS-DRAW
     MOVE "acceptance US15 18§7.2 drop test: draw 0.15 gives 0.05, below 0.085" TO WS-CASE
     PERFORM DROP-CASE
     MOVE 0.25 TO WS-DRAW
     MOVE "acceptance US15 18§7.2 drop test: draw 0.25 gives 0.15, not below 0.085" TO WS-CASE
     MOVE 0 TO WS-EXP
     PERFORM DROP-CASE
     MOVE 0.99 TO WS-DRAW
     MOVE 2 TO WS-CHANCE
     MOVE "acceptance US15 18§7.2 drop test: the preserve value 2 always drops" TO WS-CASE
     MOVE 1 TO WS-EXP
     PERFORM DROP-CASE
     MOVE 0.05 TO WS-DRAW
     MOVE 0 TO WS-CHANCE
     MOVE "acceptance US15 18§7.2 drop test: a chance of 0 never drops" TO WS-CASE
     MOVE 0 TO WS-EXP
     PERFORM DROP-CASE
*>   ---- the world: items and stack facts
     CALL "MS-TEST-OPEN" USING WS-PLAYER
*>   The enchantment registry of the test: the ranged-weapon set plus the binding curse and unbreaking (fixtures of the mount tests).
     CALL "REGISTRY-LOAD-ALL" USING WS-REGISTRY-DIR WS-STATUS
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE "iron_helmet" TO WS-KEY32
     CALL "T-ITEM-ID" USING WS-KEY32 WS-HELM-IRON
     MOVE "chainmail_helmet" TO WS-KEY32
     CALL "T-ITEM-ID" USING WS-KEY32 WS-HELM-CHAIN
     MOVE "diamond_helmet" TO WS-KEY32
     CALL "T-ITEM-ID" USING WS-KEY32 WS-HELM-DIAMOND
     MOVE "leather_helmet" TO WS-KEY32
     CALL "T-ITEM-ID" USING WS-KEY32 WS-HELM-LEATHER
     MOVE "golden_helmet" TO WS-KEY32
     CALL "T-ITEM-ID" USING WS-KEY32 WS-HELM-GOLD
     MOVE "diamond_chestplate" TO WS-KEY32
     CALL "T-ITEM-ID" USING WS-KEY32 WS-CHEST-DIAMOND
     MOVE "iron_sword" TO WS-KEY32
     CALL "T-ITEM-ID" USING WS-KEY32 WS-SWORD-IRON
*>   the equipment slot of an item
     MOVE "acceptance US15 18§7.2 slot of an iron helmet is the head (1)" TO WS-CASE
     MOVE WS-HELM-IRON TO WS-ITEM
     MOVE 1 TO WS-EXP
     PERFORM SLOT-CASE
     MOVE "acceptance US15 18§7.2 slot of a diamond chestplate is the chest (2)" TO WS-CASE
     MOVE WS-CHEST-DIAMOND TO WS-ITEM
     MOVE 2 TO WS-EXP
     PERFORM SLOT-CASE
     MOVE "acceptance US15 18§7.2 slot of iron leggings is the legs (3)" TO WS-CASE
     MOVE "iron_leggings" TO WS-KEY32
     CALL "T-ITEM-ID" USING WS-KEY32 WS-ITEM
     MOVE 3 TO WS-EXP
     PERFORM SLOT-CASE
     MOVE "acceptance US15 18§7.2 slot of iron boots is the feet (4)" TO WS-CASE
     MOVE "iron_boots" TO WS-KEY32
     CALL "T-ITEM-ID" USING WS-KEY32 WS-ITEM
     MOVE 4 TO WS-EXP
     PERFORM SLOT-CASE
     MOVE "acceptance US15 18§7.2 slot of a sword is the main hand (5)" TO WS-CASE
     MOVE WS-SWORD-IRON TO WS-ITEM
     MOVE 5 TO WS-EXP
     PERFORM SLOT-CASE
     MOVE "acceptance US15 18§7.2 slot of an apple is the main hand (canHoldItem is true for every item)" TO WS-CASE
     MOVE "apple" TO WS-KEY32
     CALL "T-ITEM-ID" USING WS-KEY32 WS-ITEM
     MOVE 5 TO WS-EXP
     PERFORM SLOT-CASE
     MOVE "acceptance US15 18§7.2 slot of a shield is the off hand (6)" TO WS-CASE
     MOVE "shield" TO WS-KEY32
     CALL "T-ITEM-ID" USING WS-KEY32 WS-ITEM
     MOVE 6 TO WS-EXP
     PERFORM SLOT-CASE
     MOVE "acceptance US15 18§7.2 slot of a carved pumpkin is the head (1)" TO WS-CASE
     MOVE "carved_pumpkin" TO WS-KEY32
     CALL "T-ITEM-ID" USING WS-KEY32 WS-ITEM
     MOVE 1 TO WS-EXP
     PERFORM SLOT-CASE
*>   facts of a diamond helmet (armor 3, toughness 2) on a mob whose armor base is 0, in the head slot
     MOVE 0 TO WS-BASE-ARMOR WS-BASE-TOUGH WS-BASE-DAMAGE
     MOVE 0 TO WS-HANDLE
     MOVE 1 TO WS-SLOT
     CALL "M187-STACK-FACTS" USING WS-HELM-DIAMOND WS-HANDLE WS-SLOT WS-BASE-ARMOR WS-BASE-TOUGH WS-BASE-DAMAGE CA-FACTS
     MOVE "acceptance US15 18§7.2 facts: a diamond helmet approximates armor 3" TO WS-CASE
     MOVE 3000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = CA-ARMOR * 1000
     PERFORM CHK
     MOVE "acceptance US15 18§7.2 facts: a diamond helmet approximates toughness 2" TO WS-CASE
     MOVE 2000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = CA-TOUGH * 1000
     PERFORM CHK
     MOVE "acceptance US15 18§7.2 facts: a plain stack has no enchantments, wear, name or curse" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS = CA-ENCH + CA-WEAR + CA-NAMED + CA-BINDING + CA-EMPTY
     PERFORM CHK
*>   the armor base counts: a zombie (base 2) wearing nothing approximates 2 + 3
     MOVE 2 TO WS-BASE-ARMOR
     CALL "M187-STACK-FACTS" USING WS-HELM-DIAMOND WS-HANDLE WS-SLOT WS-BASE-ARMOR WS-BASE-TOUGH WS-BASE-DAMAGE CA-FACTS
     MOVE "acceptance US15 18§7.2 facts: the mob's base armor 2 is the start of the fold (5)" TO WS-CASE
     MOVE 5000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = CA-ARMOR * 1000
     PERFORM CHK
*>   the same helmet in the feet slot: the modifiers are of the head group, so only the base is left
     MOVE 4 TO WS-SLOT
     CALL "M187-STACK-FACTS" USING WS-HELM-DIAMOND WS-HANDLE WS-SLOT WS-BASE-ARMOR WS-BASE-TOUGH WS-BASE-DAMAGE CA-FACTS
     MOVE "acceptance US15 18§7.2 facts: a helmet asked in the feet slot contributes nothing (2)" TO WS-CASE
     MOVE 2000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = CA-ARMOR * 1000
     PERFORM CHK
     MOVE 0 TO WS-BASE-ARMOR
*>   stack components: an enchantment, a wear of 40, a custom name and the binding curse
     MOVE "minecraft:unbreaking" TO WS-ENCH-KEY
     CALL "TOOL-ENCHANT-ID" USING WS-ENCH-KEY WS-ENCH-ID
     MOVE 0 TO WS-HANDLE
     CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-ENCH-ID WS-LEVEL
     MOVE "minecraft:binding_curse" TO WS-ENCH-KEY
     CALL "TOOL-ENCHANT-ID" USING WS-ENCH-KEY WS-ENCH-ID
     MOVE 1 TO WS-SLOT
     CALL "M187-STACK-FACTS" USING WS-HELM-DIAMOND WS-HANDLE WS-SLOT WS-BASE-ARMOR WS-BASE-TOUGH WS-BASE-DAMAGE CA-FACTS
     MOVE "acceptance US15 18§7.2 facts: one enchantment counts 1 and is not the binding curse" TO WS-CASE
     COMPUTE WS-EXP = 1
     COMPUTE WS-OBS = CA-ENCH * 10 + CA-BINDING
     MOVE 10 TO WS-EXP
     PERFORM CHK
     CALL "SP-ADD-ENCHANT" USING WS-HANDLE WS-ENCH-ID WS-LEVEL
     CALL "M187-STACK-FACTS" USING WS-HELM-DIAMOND WS-HANDLE WS-SLOT WS-BASE-ARMOR WS-BASE-TOUGH WS-BASE-DAMAGE CA-FACTS
     MOVE "acceptance US15 18§7.2 facts: two enchantments, one of them the binding curse (21)" TO WS-CASE
     COMPUTE WS-OBS = CA-ENCH * 10 + CA-BINDING
     MOVE 21 TO WS-EXP
     PERFORM CHK
     MOVE 40 TO WS-WEAR
     CALL "SP-SET-DAMAGE" USING WS-HANDLE WS-WEAR
     MOVE "Bob!" TO WS-NAME
     CALL "SP-SET-NAME" USING WS-HANDLE WS-NAME WS-NAME-LENGTH
     CALL "M187-STACK-FACTS" USING WS-HELM-DIAMOND WS-HANDLE WS-SLOT WS-BASE-ARMOR WS-BASE-TOUGH WS-BASE-DAMAGE CA-FACTS
     MOVE "acceptance US15 18§7.2 facts: wear 40 and a custom name are read from the stack" TO WS-CASE
     COMPUTE WS-OBS = CA-WEAR * 10 + CA-NAMED
     MOVE 401 TO WS-EXP
     PERFORM CHK
*>   an iron sword in the main hand of a zombie (attack base 3) approximates 3 + 5
     MOVE 5 TO WS-SLOT
     MOVE 3 TO WS-BASE-DAMAGE
     MOVE 0 TO WS-HANDLE
     CALL "M187-STACK-FACTS" USING WS-SWORD-IRON WS-HANDLE WS-SLOT WS-BASE-ARMOR WS-BASE-TOUGH WS-BASE-DAMAGE CA-FACTS
     MOVE "acceptance US15 18§7.2 facts: an iron sword gives attack damage 3 + 5 on a base of 3" TO WS-CASE
     MOVE 8000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = CA-DAMAGE * 1000
     PERFORM CHK
     MOVE 6 TO WS-SLOT
     CALL "M187-STACK-FACTS" USING WS-SWORD-IRON WS-HANDLE WS-SLOT WS-BASE-ARMOR WS-BASE-TOUGH WS-BASE-DAMAGE CA-FACTS
     MOVE "acceptance US15 18§7.2 facts: a sword asked in the off hand slot adds nothing (the modifier is of the main hand): 3" TO WS-CASE
     MOVE 3000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = CA-DAMAGE * 1000
     PERFORM CHK
     MOVE 0 TO WS-ITEM
     CALL "M187-STACK-FACTS" USING WS-ITEM WS-HANDLE WS-SLOT WS-BASE-ARMOR WS-BASE-TOUGH WS-BASE-DAMAGE CA-FACTS
     MOVE "acceptance US15 18§7.2 facts: item 0 is an empty stack" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE CA-EMPTY TO WS-OBS
     PERFORM CHK
*>   ---- a zombie row: equipItemIfPossible
     MOVE "minecraft:zombie" TO WS-KEY112
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY112 WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-PLAYER))
     COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FX = WS-BX - 4
     COMPUTE WS-FZ = WS-BZ - 4
     COMPUTE WS-FY = WS-BY - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-SIZE WS-FY WS-KIND
     COMPUTE WS-X = WS-BX + 0.5
     COMPUTE WS-Y = WS-BY
     COMPUTE WS-Z = WS-BZ + 0.5
     MOVE 6000 TO CW-TIME
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 0 TO EN-EQUIP(WS-ROW) EN-HAND(WS-ROW) EN-HEAD-WEAR(WS-ROW) EN-PERSISTENT(WS-ROW)
     CALL "WC-ROW-OPEN" USING WS-ROW
     MOVE 0 TO WS-HANDLE
     MOVE WS-HELM-IRON TO WS-ITEM
     CALL "MOB-EQUIP-IF-POSSIBLE" USING WS-ROW WS-ITEM WS-ONE WS-HANDLE WS-TAKEN
     MOVE "acceptance US15 18§7.2 equip: an iron helmet goes on an empty head, one taken" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-TAKEN TO WS-OBS
     PERFORM CHK
     MOVE 1 TO WS-SLOT
     CALL "MOB-EQ-GET" USING WS-ROW WS-SLOT WS-ITEM2 WS-HANDLE2 WS-WEAR
     MOVE "acceptance US15 18§7.2 equip: the head slot holds the iron helmet" TO WS-CASE
     MOVE WS-HELM-IRON TO WS-EXP
     MOVE WS-ITEM2 TO WS-OBS
     PERFORM CHK
     MOVE "acceptance US15 18§7.2 equip: the stored item has a guaranteed drop (preserve value 2)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WC-EQ-KEEP(WS-ROW, 1) TO WS-OBS
     PERFORM CHK
     MOVE "acceptance US15 18§7.2 equip: persistenceRequired becomes true" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE EN-PERSISTENT(WS-ROW) TO WS-OBS
     PERFORM CHK
     CALL "MOB-ARMOR-POINTS" USING WS-ROW WS-ARMOR WS-TOUGHNESS
     MOVE "acceptance US15 18§7.2 equip: the zombie's armor is its base 2 plus the helmet's 2" TO WS-CASE
     MOVE 4 TO WS-EXP
     MOVE WS-ARMOR TO WS-OBS
     PERFORM CHK
*>   Set Equipment of a row that wears only a picked-up chestplate is not empty any more
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-EQUIP-BUILD" USING WS-ROW PB-BUFFER
     SET ADDRESS OF WS-VIEW TO PB-ADDR
     MOVE 3 TO WS-OFF
     IF EN-ID(WS-ROW) >= 128
         MOVE 4 TO WS-OFF
     END-IF
     MOVE "acceptance US15 18§7.2 equip: Set Equipment (0x68) carries the picked-up helmet: head ordinal 5, last pair" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF PB-LENGTH > 4 AND WS-BYTE(1) = X"68" AND WS-BYTE(WS-OFF) = X"05"
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM CHK
     CALL "PB-FREE" USING PB-BUFFER
*>   a worse helmet is refused by the head, so the empty main hand takes it (the fallback)
     MOVE WS-HELM-LEATHER TO WS-ITEM
     CALL "MOB-EQUIP-IF-POSSIBLE" USING WS-ROW WS-ITEM WS-ONE WS-HANDLE WS-TAKEN
     MOVE "acceptance US15 18§7.2 equip: a worse helmet is carried in the empty main hand instead" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-TAKEN TO WS-OBS
     PERFORM CHK
     MOVE "acceptance US15 18§7.2 equip: the main hand holds the leather helmet (EN-HAND 1000 + id)" TO WS-CASE
     COMPUTE WS-EXP = 1000 + WS-HELM-LEATHER
     MOVE EN-HAND(WS-ROW) TO WS-OBS
     PERFORM CHK
     MOVE 1 TO WS-SLOT
     CALL "MOB-EQ-GET" USING WS-ROW WS-SLOT WS-ITEM2 WS-HANDLE2 WS-WEAR
     MOVE "acceptance US15 18§7.2 equip: the head still holds the iron helmet" TO WS-CASE
     MOVE WS-HELM-IRON TO WS-EXP
     MOVE WS-ITEM2 TO WS-OBS
     PERFORM CHK
*>   a second worse helmet finds the main hand taken: refused
     MOVE WS-HELM-GOLD TO WS-ITEM
     CALL "MOB-EQUIP-IF-POSSIBLE" USING WS-ROW WS-ITEM WS-ONE WS-HANDLE WS-TAKEN
     MOVE "acceptance US15 18§7.2 equip: with the main hand taken a worse helmet is refused" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-TAKEN TO WS-OBS
     PERFORM CHK
*>   a better helmet replaces a leather one worn from the spawn roll (drop chance 0.085): forty rounds count the stacks dropped (max(f - 0.1, 0) < 0.085 is about 18.5 per cent)
     MOVE 0 TO WS-DROPS WS-TAKEN-SUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         MOVE 11 TO EN-EQUIP(WS-ROW)
         MOVE 0 TO WC-EQ-ITEM(WS-ROW, 1) WC-EQ-VAR(WS-ROW, 1) WC-EQ-KEEP(WS-ROW, 1)
         MOVE WS-HELM-IRON TO WS-ITEM
         CALL "MOB-EQUIP-IF-POSSIBLE" USING WS-ROW WS-ITEM WS-ONE WS-HANDLE WS-TAKEN
         ADD WS-TAKEN TO WS-TAKEN-SUM
     END-PERFORM
     MOVE "acceptance US15 18§7.2 equip: an iron helmet replaces the worn leather one every time (40 of 40)" TO WS-CASE
     MOVE 40 TO WS-EXP
     MOVE WS-TAKEN-SUM TO WS-OBS
     PERFORM CHK
     MOVE 1 TO WS-SLOT
     CALL "MOB-EQ-GET" USING WS-ROW WS-SLOT WS-ITEM2 WS-HANDLE2 WS-WEAR
     MOVE "acceptance US15 18§7.2 equip: the head holds the iron helmet" TO WS-CASE
     MOVE WS-HELM-IRON TO WS-EXP
     MOVE WS-ITEM2 TO WS-OBS
     PERFORM CHK
     MOVE 0 TO WS-DROPS
     PERFORM VARYING WS-LOOSE FROM 1 BY 1 UNTIL WS-LOOSE > 1024
         IF EN-USED(WS-LOOSE) = 1 AND EN-TYPE(WS-LOOSE) = CR-LOOSE-ITEM AND EN-ITEM(WS-LOOSE) = WS-HELM-LEATHER
             ADD 1 TO WS-DROPS
         END-IF
     END-PERFORM
     MOVE "acceptance US15 18§7.2 equip: some of the 40 replaced leather helmets were dropped, not all (1 to 39)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-DROPS >= 1 AND WS-DROPS <= 39
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM CHK
*>   a stack picked up earlier has the preserve value 2: replacing it always drops it (exactly one iron helmet on the ground)
     MOVE WS-HELM-DIAMOND TO WS-ITEM
     CALL "MOB-EQUIP-IF-POSSIBLE" USING WS-ROW WS-ITEM WS-ONE WS-HANDLE WS-TAKEN
     MOVE 0 TO WS-DROPS
     PERFORM VARYING WS-LOOSE FROM 1 BY 1 UNTIL WS-LOOSE > 1024
         IF EN-USED(WS-LOOSE) = 1 AND EN-TYPE(WS-LOOSE) = CR-LOOSE-ITEM AND EN-ITEM(WS-LOOSE) = WS-HELM-IRON
             ADD 1 TO WS-DROPS
         END-IF
     END-PERFORM
     MOVE "acceptance US15 18§7.2 equip: replacing a picked-up (guaranteed drop) stack always drops it" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE WS-DROPS TO WS-OBS
     PERFORM CHK
     MOVE 1 TO WS-SLOT
     CALL "MOB-EQ-GET" USING WS-ROW WS-SLOT WS-ITEM2 WS-HANDLE2 WS-WEAR
     MOVE "acceptance US15 18§7.2 equip: the head holds the diamond helmet" TO WS-CASE
     MOVE WS-HELM-DIAMOND TO WS-EXP
     MOVE WS-ITEM2 TO WS-OBS
     PERFORM CHK
     CALL "MOB-ARMOR-POINTS" USING WS-ROW WS-ARMOR WS-TOUGHNESS
     MOVE "acceptance US15 18§7.2 equip: the armor is 2 + 3 and the toughness 2 (tenths: 20), as 5020" TO WS-CASE
     MOVE 5020 TO WS-EXP
     COMPUTE WS-OBS = WS-ARMOR * 1000 + WS-TOUGHNESS
     PERFORM CHK
*>   an empty stack and a count of 0 are never taken
     MOVE 0 TO WS-ITEM
     CALL "MOB-EQUIP-IF-POSSIBLE" USING WS-ROW WS-ITEM WS-ONE WS-HANDLE WS-TAKEN
     MOVE "acceptance US15 18§7.2 equip: item 0 is not taken" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-TAKEN TO WS-OBS
     PERFORM CHK
     MOVE WS-HELM-GOLD TO WS-ITEM
     CALL "MOB-EQUIP-IF-POSSIBLE" USING WS-ROW WS-ITEM WS-ZERO WS-HANDLE WS-TAKEN
     MOVE "acceptance US15 18§7.2 equip: a count of 0 is not taken" TO WS-CASE
     MOVE WS-TAKEN TO WS-OBS
     PERFORM CHK
*>   the wear of a helmet worn from the spawn roll is EN-HEAD-WEAR; of a picked-up stack its damage component
     MOVE 11 TO EN-EQUIP(WS-ROW)
     MOVE 5 TO EN-HEAD-WEAR(WS-ROW)
     MOVE 0 TO WC-EQ-ITEM(WS-ROW, 1)
     MOVE 1 TO WS-SLOT
     CALL "MOB-EQ-GET" USING WS-ROW WS-SLOT WS-ITEM2 WS-HANDLE2 WS-WEAR
     MOVE "acceptance US15 18§7.2 stack model: the worn leather helmet has the wear EN-HEAD-WEAR (5)" TO WS-CASE
     MOVE 5 TO WS-EXP
     MOVE WS-WEAR TO WS-OBS
     PERFORM CHK
     MOVE 0 TO EN-EQUIP(WS-ROW) EN-HEAD-WEAR(WS-ROW)
     MOVE 0 TO WS-HANDLE
     MOVE 12 TO WS-WEAR
     CALL "SP-SET-DAMAGE" USING WS-HANDLE WS-WEAR
     MOVE "iron_boots" TO WS-KEY32
     CALL "T-ITEM-ID" USING WS-KEY32 WS-ITEM
     CALL "MOB-EQUIP-IF-POSSIBLE" USING WS-ROW WS-ITEM WS-ONE WS-HANDLE WS-TAKEN
     MOVE 4 TO WS-SLOT
     CALL "MOB-EQ-GET" USING WS-ROW WS-SLOT WS-ITEM2 WS-HANDLE2 WS-WEAR
     MOVE "acceptance US15 18§7.2 stack model: boots picked up with damage 12 keep it (the patch handle)" TO WS-CASE
     MOVE 12 TO WS-EXP
     MOVE WS-WEAR TO WS-OBS
     PERFORM CHK
     MOVE "acceptance US15 18§7.2 stack model: the stored handle is the one given" TO WS-CASE
     MOVE WS-HANDLE TO WS-EXP
     MOVE WS-HANDLE2 TO WS-OBS
     PERFORM CHK
     MOVE WS-SWORD-IRON TO WS-ITEM
     CALL "MOB-EQUIP-IF-POSSIBLE" USING WS-ROW WS-ITEM WS-ONE WS-HANDLE WS-TAKEN
     MOVE 5 TO WS-SLOT
     CALL "MOB-EQ-GET" USING WS-ROW WS-SLOT WS-ITEM2 WS-HANDLE2 WS-WEAR
     MOVE "acceptance US15 18§7.2 stack model: a sword with damage 12 replaces the carried helmet in the main hand and keeps it" TO WS-CASE
     MOVE 12 TO WS-EXP
     MOVE WS-WEAR TO WS-OBS
     PERFORM CHK
*>   ---- loot pickup of a row that canPickUpLoot
     MOVE 0 TO EN-EQUIP(WS-ROW) EN-HAND(WS-ROW)
     INITIALIZE WC-ROW(WS-ROW)
     MOVE EN-ID(WS-ROW) TO WC-ID(WS-ROW)
     MOVE 1 TO WC-LOOT(WS-ROW)
     MOVE 0 TO WS-DELAY
     MOVE 0 TO WS-HANDLE
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X WS-Y WS-Z WS-CHEST-DIAMOND WS-ONE WS-HANDLE WS-DELAY WS-LOOSE
     CALL "MOB-LOOT-PICKUP-TICK" USING WS-ROW
     MOVE "acceptance US15 18§7.2 pickup: a diamond chestplate at the feet is picked up and worn (chest, slot 2)" TO WS-CASE
     MOVE 2 TO WS-SLOT
     CALL "MOB-EQ-GET" USING WS-ROW WS-SLOT WS-ITEM2 WS-HANDLE2 WS-WEAR
     MOVE WS-CHEST-DIAMOND TO WS-EXP
     MOVE WS-ITEM2 TO WS-OBS
     PERFORM CHK
     MOVE "acceptance US15 18§7.2 pickup: the item entity is discarded when the stack is used up" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-USED(WS-LOOSE) TO WS-OBS
     PERFORM CHK
*>   a row without canPickUpLoot leaves the item
     INITIALIZE WC-ROW(WS-ROW)
     MOVE EN-ID(WS-ROW) TO WC-ID(WS-ROW)
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X WS-Y WS-Z WS-CHEST-DIAMOND WS-ONE WS-HANDLE WS-DELAY WS-LOOSE
     CALL "MOB-LOOT-PICKUP-TICK" USING WS-ROW
     MOVE "acceptance US15 18§7.2 pickup: a row that cannot pick up loot leaves the item" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE EN-USED(WS-LOOSE) TO WS-OBS
     PERFORM CHK
*>   mob_griefing off: nothing is picked up
     MOVE 1 TO WC-LOOT(WS-ROW)
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     CALL "MOB-LOOT-PICKUP-TICK" USING WS-ROW
     MOVE "acceptance US15 18§7.2 pickup: with mob_griefing off the item stays" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE EN-USED(WS-LOOSE) TO WS-OBS
     PERFORM CHK
     MOVE 1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
*>   a pickup delay: the item stays
     MOVE 10 TO EN-DELAY(WS-LOOSE)
     CALL "MOB-LOOT-PICKUP-TICK" USING WS-ROW
     MOVE "acceptance US15 18§7.2 pickup: an item with a pickup delay is not taken" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE EN-USED(WS-LOOSE) TO WS-OBS
     PERFORM CHK
*>   out of reach: three blocks away
     MOVE 0 TO EN-DELAY(WS-LOOSE)
     COMPUTE EN-X(WS-LOOSE) = EN-X(WS-ROW) + 3
     CALL "MOB-LOOT-PICKUP-TICK" USING WS-ROW
     MOVE "acceptance US15 18§7.2 pickup: an item three blocks away is out of reach" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE EN-USED(WS-LOOSE) TO WS-OBS
     PERFORM CHK
*>   within the reach: a zombie's box is 0.6 wide, so 1.3 blocks away (under 0.3 + 1 + 0.125 + the item's 0.125 is 1.55) is picked up
     COMPUTE EN-X(WS-LOOSE) = EN-X(WS-ROW) + 1.3
     CALL "MOB-LOOT-PICKUP-TICK" USING WS-ROW
     MOVE "acceptance US15 18§7.2 pickup: an item 1.3 blocks away is inside the box inflated by 1" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE EN-USED(WS-LOOSE) TO WS-OBS
     PERFORM CHK
*>   an off-hand item (a shield) is not equipped: no slot model for it, so the item stays
     MOVE "shield" TO WS-KEY32
     CALL "T-ITEM-ID" USING WS-KEY32 WS-ITEM
     INITIALIZE WC-ROW(WS-ROW)
     MOVE EN-ID(WS-ROW) TO WC-ID(WS-ROW)
     MOVE 1 TO WC-LOOT(WS-ROW)
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X WS-Y WS-Z WS-ITEM WS-ONE WS-HANDLE WS-DELAY WS-LOOSE
     CALL "MOB-LOOT-PICKUP-TICK" USING WS-ROW
     MOVE "acceptance US15 18§7.2 pickup: a shield (off-hand slot, not modelled) stays on the ground" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE EN-USED(WS-LOOSE) TO WS-OBS
     PERFORM CHK
*>   a zombie never picks up a glow ink sac; an apple goes into the empty main hand
     MOVE 0 TO EN-EQUIP(WS-ROW) EN-HAND(WS-ROW)
     INITIALIZE WC-ROW(WS-ROW)
     MOVE EN-ID(WS-ROW) TO WC-ID(WS-ROW)
     MOVE 1 TO WC-LOOT(WS-ROW)
     MOVE "glow_ink_sac" TO WS-KEY32
     CALL "T-ITEM-ID" USING WS-KEY32 WS-ITEM
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X WS-Y WS-Z WS-ITEM WS-ONE WS-HANDLE WS-DELAY WS-LOOSE
     CALL "MOB-LOOT-PICKUP-TICK" USING WS-ROW
     MOVE "acceptance US15 20§4.1 pickup: a zombie never picks up a glow ink sac" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE EN-USED(WS-LOOSE) TO WS-OBS
     PERFORM CHK
     MOVE "apple" TO WS-KEY32
     CALL "T-ITEM-ID" USING WS-KEY32 WS-ITEM
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X WS-Y WS-Z WS-ITEM WS-ONE WS-HANDLE WS-DELAY WS-LOOSE
     CALL "MOB-LOOT-PICKUP-TICK" USING WS-ROW
     MOVE "acceptance US15 18§7.2 pickup: an apple goes into the empty main hand (EN-HAND 1000 + id)" TO WS-CASE
     COMPUTE WS-EXP = 1000 + WS-ITEM
     MOVE EN-HAND(WS-ROW) TO WS-OBS
     PERFORM CHK
*>   Set Equipment of a leather helmet worn by EN-EQUIP plus a picked-up chestplate: two pairs, the first with the continuation bit
     MOVE 11 TO EN-EQUIP(WS-ROW)
     MOVE 0 TO EN-HAND(WS-ROW)
     MOVE WS-CHEST-DIAMOND TO WC-EQ-ITEM(WS-ROW, 2)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-EQUIP-BUILD" USING WS-ROW PB-BUFFER
     SET ADDRESS OF WS-VIEW TO PB-ADDR
     MOVE 3 TO WS-OFF
     IF EN-ID(WS-ROW) >= 128
         MOVE 4 TO WS-OFF
     END-IF
     MOVE "acceptance US15 18§7.2 equip: Set Equipment lists the worn leather helmet (0x85) before the picked-up chestplate" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF PB-LENGTH > 8 AND WS-BYTE(1) = X"68" AND WS-BYTE(WS-OFF) = X"85"
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM CHK
     CALL "PB-FREE" USING PB-BUFFER
     MOVE "acceptance US15 18§7.2 equip: armor is 2 + the leather helmet 1 + the diamond chestplate 8 (11)" TO WS-CASE
     CALL "MOB-ARMOR-POINTS" USING WS-ROW WS-ARMOR WS-TOUGHNESS
     MOVE 11 TO WS-EXP
     MOVE WS-ARMOR TO WS-OBS
     PERFORM CHK
     MOVE 0 TO EN-EQUIP(WS-ROW) EN-HAND(WS-ROW)
*>   a skeleton (a bow in hand) refuses a spear but takes a sword (more attack damage than the bow)
     MOVE "minecraft:skeleton" TO WS-KEY112
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY112 WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW2
     CALL "WC-ROW-OPEN" USING WS-ROW2
     MOVE 1 TO WC-LOOT(WS-ROW2)
     MOVE 4 TO EN-HAND(WS-ROW2)
     MOVE "iron_spear" TO WS-KEY32
     CALL "T-ITEM-ID" USING WS-KEY32 WS-ITEM
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X WS-Y WS-Z WS-ITEM WS-ONE WS-HANDLE WS-DELAY WS-LOOSE
     CALL "MOB-LOOT-PICKUP-TICK" USING WS-ROW2
     MOVE "acceptance US15 20§5 pickup: a skeleton refuses the items of the tag spears" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE EN-USED(WS-LOOSE) TO WS-OBS
     PERFORM CHK
     CALL "ENTITY-REMOVE" USING WS-LOOSE
     MOVE "iron_sword" TO WS-KEY32
     CALL "T-ITEM-ID" USING WS-KEY32 WS-ITEM
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X WS-Y WS-Z WS-ITEM WS-ONE WS-HANDLE WS-DELAY WS-LOOSE
     CALL "MOB-LOOT-PICKUP-TICK" USING WS-ROW2
     MOVE "acceptance US15 18§7.2 pickup: a skeleton swaps its bow for an iron sword (more attack damage)" TO WS-CASE
     COMPUTE WS-EXP = 1000 + WS-ITEM
     MOVE EN-HAND(WS-ROW2) TO WS-OBS
     PERFORM CHK
     CALL "ENTITY-REMOVE" USING WS-ROW2
*>   dead mobs pick up nothing
     MOVE 1 TO WC-LOOT(WS-ROW)
     MOVE 0 TO EN-HAND(WS-ROW)
     MOVE 0 TO EN-HEALTH(WS-ROW)
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X WS-Y WS-Z WS-ITEM WS-ONE WS-HANDLE WS-DELAY WS-LOOSE
     CALL "MOB-LOOT-PICKUP-TICK" USING WS-ROW
     MOVE "acceptance US15 18§7.2 pickup: a mob with no health left picks up nothing" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE EN-USED(WS-LOOSE) TO WS-OBS
     PERFORM CHK
*>   canPickUpLoot is rolled at spawn: over thirty zombies some have it and some do not
     MOVE 0 TO WS-FLAGGED
     MOVE 3 TO BW-DIFFICULTY
     MOVE 1600000 TO CW-GAME-TIME
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         MOVE WS-I TO CW-TIME
         MULTIPLY 37 BY CW-TIME
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW2
         CALL "STDMOB-FINALIZE" USING XR-STATE WS-ROW2
         CALL "WC-ROW-OPEN" USING WS-ROW2
         ADD WC-LOOT(WS-ROW2) TO WS-FLAGGED
         CALL "ENTITY-REMOVE" USING WS-ROW2
     END-PERFORM
     MOVE "acceptance US15 18§7.2 spawn: canPickUpLoot is set on some of thirty zombies and not on all (1 to 29)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-FLAGGED >= 1 AND WS-FLAGGED <= 29
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM CHK
     STOP RUN.
 GROUP-CASE.
     CALL "M187-GROUP-HAS" USING WS-GROUP WS-SLOT WS-YES
     MOVE WS-YES TO WS-OBS
     PERFORM CHK.
 APPROX-CASE.
     CALL "M187-APPROX-ATTR" USING WS-BASE WS-ATTR WS-SLOT WS-COUNT MM-MODS WS-RESULT
     COMPUTE WS-OBS ROUNDED = WS-RESULT * 1000
     PERFORM CHK.
 CLEAR-FACTS.
     INITIALIZE CA-FACTS
     INITIALIZE CU-FACTS.
 EQUAL-CASE.
     CALL "M187-EQUAL-ITEM" USING CA-FACTS CU-FACTS WS-YES
     MOVE WS-YES TO WS-OBS
     PERFORM CHK.
 ARMOR-CASE.
     CALL "M187-COMPARE-ARMOR" USING CA-FACTS CU-FACTS WS-YES
     MOVE WS-YES TO WS-OBS
     PERFORM CHK.
 WEAPON-CASE.
     CALL "M187-COMPARE-WEAPONS" USING CA-FACTS CU-FACTS WS-YES
     MOVE WS-YES TO WS-OBS
     PERFORM CHK.
 REPLACE-CASE.
     CALL "M187-CAN-REPLACE" USING WS-SLOT CA-FACTS CU-FACTS WS-YES
     MOVE WS-YES TO WS-OBS
     PERFORM CHK.
 DROP-CASE.
     CALL "M187-DROP-TEST" USING WS-DRAW WS-CHANCE WS-YES
     MOVE WS-YES TO WS-OBS
     PERFORM CHK.
 SLOT-CASE.
     CALL "M187-SLOT-OF-ITEM" USING WS-ITEM WS-SLOT
     MOVE WS-SLOT TO WS-OBS
     PERFORM CHK.
 CHK.
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS.
 END PROGRAM TEST-MOB-18-7-2.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. T-ITEM-ID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW                 PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(32).
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ID.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE L-KEY DELIMITED BY SPACE INTO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY L-ID WS-ROW WS-STATUS
     GOBACK.
 END PROGRAM T-ITEM-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(200).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.
 COPY CORETEST.
 COPY MOBSPTEST.
