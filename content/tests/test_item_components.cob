*> Test of the item component defaults (T0283; content-api section 2, CONTENT-ITEM-COMPONENT; 17 section 1.2 to 1.4 and 2.1
*> to 2.5 for the standard set, standard-core 5.3 for the cobolcraft items). Each case is an item key, a component
*> name and the value read from the document ("-": the item has no such component, status CT-NOT-FOUND). The expected
*> values are transcribed from the tables of 17 section 2 (attack damage 1 + modifier + bonus, so the component
*> "attack_damage" is the attribute modifier amount: the table's registered damage plus the material bonus) and not
*> computed. The component names beyond max_stack_size, max_damage are documented assumptions listed in the header of
*> content/src/item-components.cob. The set is made by setting CT-SET.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ITEM-COMPONENTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 01 WS-STANDARD-CASES.
    05 FILLER PIC X(100) VALUE "iron_sword|max_damage|250".
    05 FILLER PIC X(100) VALUE "iron_sword|max_stack_size|1".
    05 FILLER PIC X(100) VALUE "iron_sword|tool|minecraft:cobweb 15.0".
    05 FILLER PIC X(100) VALUE "iron_sword|tool_rule_1|mine minecraft:cobweb 15.0".
    05 FILLER PIC X(100) VALUE "iron_sword|tool_rule_2|speed #minecraft:sword_instantly_mines 3.4028235E38".
    05 FILLER PIC X(100) VALUE "iron_sword|tool_rule_3|speed #minecraft:sword_efficient 1.5".
    05 FILLER PIC X(100) VALUE "iron_sword|tool_default_speed|1.0".
    05 FILLER PIC X(100) VALUE "iron_sword|tool_damage_per_block|2".
    05 FILLER PIC X(100) VALUE "iron_sword|tool_creative_break|0".
    05 FILLER PIC X(100) VALUE "iron_sword|attack_damage|5.0".
    05 FILLER PIC X(100) VALUE "iron_sword|attack_speed|-2.4".
    05 FILLER PIC X(100) VALUE "iron_sword|weapon|1".
    05 FILLER PIC X(100) VALUE "iron_sword|weapon_disable_blocking|0.0".
    05 FILLER PIC X(100) VALUE "iron_sword|enchantable|14".
    05 FILLER PIC X(100) VALUE "iron_sword|repairable|minecraft:iron_ingot".
    05 FILLER PIC X(100) VALUE "iron_sword|armor|-".
    05 FILLER PIC X(100) VALUE "iron_sword|damage_resistant|-".
    05 FILLER PIC X(100) VALUE "wooden_sword|attack_damage|3.0".
    05 FILLER PIC X(100) VALUE "wooden_sword|enchantable|15".
    05 FILLER PIC X(100) VALUE "wooden_sword|repairable|#minecraft:wooden_tool_materials".
    05 FILLER PIC X(100) VALUE "stone_sword|repairable|#minecraft:stone_tool_materials".
    05 FILLER PIC X(100) VALUE "stone_sword|enchantable|5".
    05 FILLER PIC X(100) VALUE "stone_sword|attack_damage|4.0".
    05 FILLER PIC X(100) VALUE "diamond_sword|attack_damage|6.0".
    05 FILLER PIC X(100) VALUE "netherite_sword|attack_damage|7.0".
    05 FILLER PIC X(100) VALUE "netherite_sword|max_damage|2031".
    05 FILLER PIC X(100) VALUE "copper_sword|attack_damage|4.0".
    05 FILLER PIC X(100) VALUE "copper_sword|repairable|minecraft:copper_ingot".
    05 FILLER PIC X(100) VALUE "copper_sword|enchantable|13".
    05 FILLER PIC X(100) VALUE "golden_sword|attack_damage|3.0".
    05 FILLER PIC X(100) VALUE "golden_sword|repairable|minecraft:gold_ingot".
    05 FILLER PIC X(100) VALUE "golden_sword|enchantable|22".
    05 FILLER PIC X(100) VALUE "iron_pickaxe|tool|#minecraft:mineable/pickaxe 6.0".
    05 FILLER PIC X(100) VALUE "iron_pickaxe|tool_rule_1|deny #minecraft:incorrect_for_iron_tool".
    05 FILLER PIC X(100) VALUE "iron_pickaxe|tool_rule_2|mine #minecraft:mineable/pickaxe 6.0".
    05 FILLER PIC X(100) VALUE "iron_pickaxe|tool_rule_3|-".
    05 FILLER PIC X(100) VALUE "iron_pickaxe|tool_default_speed|1.0".
    05 FILLER PIC X(100) VALUE "iron_pickaxe|tool_damage_per_block|1".
    05 FILLER PIC X(100) VALUE "iron_pickaxe|tool_creative_break|1".
    05 FILLER PIC X(100) VALUE "iron_pickaxe|attack_damage|3.0".
    05 FILLER PIC X(100) VALUE "iron_pickaxe|attack_speed|-2.8".
    05 FILLER PIC X(100) VALUE "iron_pickaxe|weapon|2".
    05 FILLER PIC X(100) VALUE "iron_pickaxe|weapon_disable_blocking|0.0".
    05 FILLER PIC X(100) VALUE "iron_pickaxe|enchantable|14".
    05 FILLER PIC X(100) VALUE "iron_pickaxe|max_damage|250".
    05 FILLER PIC X(100) VALUE "wooden_pickaxe|tool_rule_1|deny #minecraft:incorrect_for_wooden_tool".
    05 FILLER PIC X(100) VALUE "wooden_pickaxe|tool|#minecraft:mineable/pickaxe 2.0".
    05 FILLER PIC X(100) VALUE "stone_pickaxe|tool_rule_1|deny #minecraft:incorrect_for_stone_tool".
    05 FILLER PIC X(100) VALUE "copper_pickaxe|tool_rule_1|deny #minecraft:incorrect_for_copper_tool".
    05 FILLER PIC X(100) VALUE "copper_pickaxe|tool|#minecraft:mineable/pickaxe 5.0".
    05 FILLER PIC X(100) VALUE "diamond_pickaxe|tool_rule_1|deny #minecraft:incorrect_for_diamond_tool".
    05 FILLER PIC X(100) VALUE "diamond_pickaxe|attack_damage|4.0".
    05 FILLER PIC X(100) VALUE "netherite_pickaxe|tool_rule_1|deny #minecraft:incorrect_for_netherite_tool".
    05 FILLER PIC X(100) VALUE "netherite_pickaxe|attack_damage|5.0".
    05 FILLER PIC X(100) VALUE "golden_pickaxe|tool|#minecraft:mineable/pickaxe 12.0".
    05 FILLER PIC X(100) VALUE "golden_pickaxe|tool_rule_1|deny #minecraft:incorrect_for_gold_tool".
    05 FILLER PIC X(100) VALUE "golden_axe|tool_rule_2|mine #minecraft:mineable/axe 12.0".
    05 FILLER PIC X(100) VALUE "golden_axe|attack_damage|6.0".
    05 FILLER PIC X(100) VALUE "golden_axe|attack_speed|-3.0".
    05 FILLER PIC X(100) VALUE "golden_axe|weapon_disable_blocking|5.0".
    05 FILLER PIC X(100) VALUE "golden_axe|enchantable|22".
    05 FILLER PIC X(100) VALUE "wooden_axe|attack_damage|6.0".
    05 FILLER PIC X(100) VALUE "wooden_axe|attack_speed|-3.2".
    05 FILLER PIC X(100) VALUE "stone_axe|attack_damage|8.0".
    05 FILLER PIC X(100) VALUE "iron_axe|attack_damage|8.0".
    05 FILLER PIC X(100) VALUE "iron_axe|attack_speed|-3.1".
    05 FILLER PIC X(100) VALUE "diamond_axe|attack_damage|8.0".
    05 FILLER PIC X(100) VALUE "netherite_axe|attack_damage|9.0".
    05 FILLER PIC X(100) VALUE "netherite_axe|attack_speed|-3.0".
    05 FILLER PIC X(100) VALUE "netherite_axe|tool|#minecraft:mineable/axe 9.0".
    05 FILLER PIC X(100) VALUE "diamond_shovel|attack_damage|4.5".
    05 FILLER PIC X(100) VALUE "diamond_shovel|attack_speed|-3.0".
    05 FILLER PIC X(100) VALUE "diamond_shovel|tool|#minecraft:mineable/shovel 8.0".
    05 FILLER PIC X(100) VALUE "diamond_shovel|weapon_disable_blocking|0.0".
    05 FILLER PIC X(100) VALUE "copper_shovel|attack_damage|2.5".
    05 FILLER PIC X(100) VALUE "copper_shovel|enchantable|13".
    05 FILLER PIC X(100) VALUE "copper_shovel|repairable|minecraft:copper_ingot".
    05 FILLER PIC X(100) VALUE "iron_hoe|attack_damage|0.0".
    05 FILLER PIC X(100) VALUE "iron_hoe|attack_speed|-1.0".
    05 FILLER PIC X(100) VALUE "iron_hoe|tool|#minecraft:mineable/hoe 6.0".
    05 FILLER PIC X(100) VALUE "diamond_hoe|attack_damage|0.0".
    05 FILLER PIC X(100) VALUE "diamond_hoe|attack_speed|0.0".
    05 FILLER PIC X(100) VALUE "stone_hoe|attack_damage|0.0".
    05 FILLER PIC X(100) VALUE "stone_hoe|attack_speed|-2.0".
    05 FILLER PIC X(100) VALUE "wooden_hoe|attack_damage|0.0".
    05 FILLER PIC X(100) VALUE "wooden_hoe|attack_speed|-3.0".
    05 FILLER PIC X(100) VALUE "netherite_hoe|attack_damage|0.0".
    05 FILLER PIC X(100) VALUE "netherite_hoe|attack_speed|0.0".
    05 FILLER PIC X(100) VALUE "netherite_hoe|enchantable|15".
    05 FILLER PIC X(100) VALUE "netherite_hoe|repairable|minecraft:netherite_ingot".
    05 FILLER PIC X(100) VALUE "iron_chestplate|max_damage|240".
    05 FILLER PIC X(100) VALUE "iron_chestplate|armor|6".
    05 FILLER PIC X(100) VALUE "iron_chestplate|armor_toughness|0.0".
    05 FILLER PIC X(100) VALUE "iron_chestplate|armor_knockback_resistance|-".
    05 FILLER PIC X(100) VALUE "iron_chestplate|equippable|chest".
    05 FILLER PIC X(100) VALUE "iron_chestplate|equippable_damage_on_hurt|1".
    05 FILLER PIC X(100) VALUE "iron_chestplate|enchantable|9".
    05 FILLER PIC X(100) VALUE "iron_chestplate|repairable|minecraft:iron_ingot".
    05 FILLER PIC X(100) VALUE "iron_chestplate|tool|-".
    05 FILLER PIC X(100) VALUE "iron_chestplate|attack_damage|-".
    05 FILLER PIC X(100) VALUE "iron_chestplate|damage_resistant|-".
    05 FILLER PIC X(100) VALUE "diamond_helmet|armor|3".
    05 FILLER PIC X(100) VALUE "diamond_helmet|armor_toughness|2.0".
    05 FILLER PIC X(100) VALUE "diamond_helmet|equippable|head".
    05 FILLER PIC X(100) VALUE "diamond_helmet|enchantable|10".
    05 FILLER PIC X(100) VALUE "diamond_helmet|repairable|minecraft:diamond".
    05 FILLER PIC X(100) VALUE "diamond_helmet|max_damage|363".
    05 FILLER PIC X(100) VALUE "netherite_boots|armor|3".
    05 FILLER PIC X(100) VALUE "netherite_boots|armor_toughness|3.0".
    05 FILLER PIC X(100) VALUE "netherite_boots|armor_knockback_resistance|0.1".
    05 FILLER PIC X(100) VALUE "netherite_boots|equippable|feet".
    05 FILLER PIC X(100) VALUE "netherite_boots|enchantable|15".
    05 FILLER PIC X(100) VALUE "netherite_leggings|armor|6".
    05 FILLER PIC X(100) VALUE "netherite_leggings|equippable|legs".
    05 FILLER PIC X(100) VALUE "leather_leggings|armor|2".
    05 FILLER PIC X(100) VALUE "leather_leggings|enchantable|15".
    05 FILLER PIC X(100) VALUE "leather_leggings|repairable|minecraft:leather".
    05 FILLER PIC X(100) VALUE "leather_leggings|equippable|legs".
    05 FILLER PIC X(100) VALUE "leather_chestplate|armor|3".
    05 FILLER PIC X(100) VALUE "leather_helmet|armor|1".
    05 FILLER PIC X(100) VALUE "leather_boots|armor|1".
    05 FILLER PIC X(100) VALUE "leather_boots|max_damage|65".
    05 FILLER PIC X(100) VALUE "chainmail_boots|armor|1".
    05 FILLER PIC X(100) VALUE "chainmail_boots|enchantable|12".
    05 FILLER PIC X(100) VALUE "chainmail_boots|repairable|#minecraft:repairs_chain_armor".
    05 FILLER PIC X(100) VALUE "chainmail_chestplate|armor|5".
    05 FILLER PIC X(100) VALUE "chainmail_leggings|armor|4".
    05 FILLER PIC X(100) VALUE "chainmail_helmet|armor|2".
    05 FILLER PIC X(100) VALUE "golden_chestplate|armor|5".
    05 FILLER PIC X(100) VALUE "golden_chestplate|enchantable|25".
    05 FILLER PIC X(100) VALUE "golden_chestplate|repairable|minecraft:gold_ingot".
    05 FILLER PIC X(100) VALUE "golden_helmet|armor|2".
    05 FILLER PIC X(100) VALUE "golden_leggings|armor|3".
    05 FILLER PIC X(100) VALUE "golden_boots|armor|1".
    05 FILLER PIC X(100) VALUE "copper_helmet|armor|2".
    05 FILLER PIC X(100) VALUE "copper_helmet|enchantable|8".
    05 FILLER PIC X(100) VALUE "copper_helmet|repairable|minecraft:copper_ingot".
    05 FILLER PIC X(100) VALUE "copper_chestplate|armor|4".
    05 FILLER PIC X(100) VALUE "copper_leggings|armor|3".
    05 FILLER PIC X(100) VALUE "copper_boots|armor|1".
    05 FILLER PIC X(100) VALUE "iron_helmet|armor|2".
    05 FILLER PIC X(100) VALUE "iron_leggings|armor|5".
    05 FILLER PIC X(100) VALUE "iron_boots|armor|2".
    05 FILLER PIC X(100) VALUE "diamond_chestplate|armor|8".
    05 FILLER PIC X(100) VALUE "diamond_leggings|armor|6".
    05 FILLER PIC X(100) VALUE "diamond_boots|armor|3".
    05 FILLER PIC X(100) VALUE "netherite_chestplate|armor|8".
    05 FILLER PIC X(100) VALUE "netherite_helmet|armor|3".
    05 FILLER PIC X(100) VALUE "turtle_helmet|armor|2".
    05 FILLER PIC X(100) VALUE "turtle_helmet|armor_toughness|0.0".
    05 FILLER PIC X(100) VALUE "turtle_helmet|enchantable|9".
    05 FILLER PIC X(100) VALUE "turtle_helmet|repairable|item tag repairs_turtle_helmet".
    05 FILLER PIC X(100) VALUE "turtle_helmet|equippable|head slot".
    05 FILLER PIC X(100) VALUE "turtle_helmet|max_damage|275".
    05 FILLER PIC X(100) VALUE "stone|tool|-".
    05 FILLER PIC X(100) VALUE "stone|armor|-".
    05 FILLER PIC X(100) VALUE "iron_ingot|tool|-".
    05 FILLER PIC X(100) VALUE "iron_ingot|armor|-".
    05 FILLER PIC X(100) VALUE "iron_ingot|enchantable|-".
    05 FILLER PIC X(100) VALUE "iron_horse_armor|armor|5".
    05 FILLER PIC X(100) VALUE "bow|tool|-".
 01 WS-STANDARD-TABLE REDEFINES WS-STANDARD-CASES.
    05 WS-STANDARD-CASE    PIC X(100) OCCURS 161 TIMES.
 01 WS-COBOLCRAFT-CASES.
    05 FILLER PIC X(100) VALUE "cobolcraft:pry_bar|max_stack_size|1".
    05 FILLER PIC X(100) VALUE "cobolcraft:pry_bar|max_damage|-".
    05 FILLER PIC X(100) VALUE "cobolcraft:pry_bar|tool|#minecraft:mineable/pickaxe 4.0".
    05 FILLER PIC X(100) VALUE "cobolcraft:pry_bar|tool_rule_1|mine #minecraft:mineable/pickaxe 4.0".
    05 FILLER PIC X(100) VALUE "cobolcraft:pry_bar|tool_rule_2|-".
    05 FILLER PIC X(100) VALUE "cobolcraft:pry_bar|tool_default_speed|1.0".
    05 FILLER PIC X(100) VALUE "cobolcraft:pry_bar|tool_damage_per_block|1".
    05 FILLER PIC X(100) VALUE "cobolcraft:pry_bar|tool_creative_break|1".
    05 FILLER PIC X(100) VALUE "cobolcraft:pry_bar|attack_damage|3.0".
    05 FILLER PIC X(100) VALUE "cobolcraft:pry_bar|attack_speed|-2.8".
    05 FILLER PIC X(100) VALUE "cobolcraft:pry_bar|weapon|2".
    05 FILLER PIC X(100) VALUE "cobolcraft:pry_bar|weapon_disable_blocking|0.0".
    05 FILLER PIC X(100) VALUE "cobolcraft:pry_bar|enchantable|-".
    05 FILLER PIC X(100) VALUE "cobolcraft:pry_bar|repairable|-".
    05 FILLER PIC X(100) VALUE "cobolcraft:pry_bar|armor|-".
    05 FILLER PIC X(100) VALUE "cobolcraft:trowel|tool|#minecraft:mineable/shovel 4.0".
    05 FILLER PIC X(100) VALUE "cobolcraft:trowel|tool_rule_1|mine #minecraft:mineable/shovel 4.0".
    05 FILLER PIC X(100) VALUE "cobolcraft:trowel|attack_damage|1.0".
    05 FILLER PIC X(100) VALUE "cobolcraft:trowel|attack_speed|-3.0".
    05 FILLER PIC X(100) VALUE "cobolcraft:trowel|weapon|2".
    05 FILLER PIC X(100) VALUE "cobolcraft:trowel|enchantable|-".
    05 FILLER PIC X(100) VALUE "cobolcraft:baseplate|tool|-".
    05 FILLER PIC X(100) VALUE "cobolcraft:baseplate|tool_default_speed|-".
    05 FILLER PIC X(100) VALUE "cobolcraft:baseplate|weapon_disable_blocking|-".
    05 FILLER PIC X(100) VALUE "cobolcraft:baseplate|attack_damage|-".
    05 FILLER PIC X(100) VALUE "cobolcraft:grazer_flank|food|3".
    05 FILLER PIC X(100) VALUE "cobolcraft:grazer_flank|tool_rule_1|-".
 01 WS-COBOLCRAFT-TABLE REDEFINES WS-COBOLCRAFT-CASES.
    05 WS-COBOLCRAFT-CASE  PIC X(100) OCCURS 27 TIMES.
 01 WS-CASE                PIC X(100).
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-VALUE               PIC X(100).
 01 WS-WANT                PIC X(100).
 01 WS-ITEM                PIC X(112).
 PROCEDURE DIVISION.
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 161
         MOVE WS-STANDARD-CASE(WS-I) TO WS-CASE
         PERFORM CHECK-CASE
     END-PERFORM
     MOVE CT-TYPE-COBOLCRAFT TO CT-SET-TYPE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 27
         MOVE WS-COBOLCRAFT-CASE(WS-I) TO WS-CASE
         PERFORM CHECK-CASE
     END-PERFORM
     STOP RUN.

 CHECK-CASE.
     MOVE SPACES TO WS-KEY WS-NAME WS-WANT
     UNSTRING WS-CASE DELIMITED BY "|" INTO WS-ITEM WS-NAME WS-WANT
     MOVE WS-ITEM TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
     CALL "CONTENT-ITEM-COMPONENT" USING WS-ID WS-NAME WS-VALUE WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "item components: " FUNCTION TRIM(WS-ITEM) " " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     IF WS-WANT = "-"
         MOVE "not found" TO TL-EXPECTED
         IF WS-STATUS = CT-NOT-FOUND AND WS-VALUE = SPACES
             MOVE "not found" TO TL-OBSERVED
         ELSE
             MOVE WS-VALUE TO TL-OBSERVED
         END-IF
     ELSE
         MOVE WS-WANT TO TL-EXPECTED
         IF WS-STATUS = CT-OK
             MOVE WS-VALUE TO TL-OBSERVED
         ELSE
             MOVE "not found" TO TL-OBSERVED
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
