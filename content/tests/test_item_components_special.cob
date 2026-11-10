*> Test of the item component defaults of the items the tool defaults do not cover (17 section 1.4, 2.4 spears, 2.5 animal
*> armor, 2.6 special weapons and tools; item-components-special.cob): each case is an item key, a component name and the
*> value read ("-": the item has no such component, status CT-NOT-FOUND). The expected values are transcribed from the
*> tables of 17 section 2.4 (the spear speed modifier is 1 / a - 4.0 to four places, so 4 + it is the table's attack
*> speed), 2.5 (body defense of the animal armor), 2.6 (mace, trident, shears) and 3.1 (the transformer of the axes,
*> shovels and hoes). The standard set is selected with CT-SET.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ITEM-COMPONENTS-SPECIAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 01 WS-CASES.
    05 FILLER PIC X(100) VALUE "wooden_spear|attack_damage|0.0".
    05 FILLER PIC X(100) VALUE "wooden_spear|attack_speed|-2.4615".
    05 FILLER PIC X(100) VALUE "wooden_spear|attack_animation|stab 13".
    05 FILLER PIC X(100) VALUE "wooden_spear|kinetic_contact_cooldown|10".
    05 FILLER PIC X(100) VALUE "wooden_spear|kinetic_delay|15".
    05 FILLER PIC X(100) VALUE "wooden_spear|kinetic_dismount|100 14.0".
    05 FILLER PIC X(100) VALUE "wooden_spear|kinetic_knockback|200 5.1".
    05 FILLER PIC X(100) VALUE "wooden_spear|kinetic_damage|300 4.6".
    05 FILLER PIC X(100) VALUE "wooden_spear|kinetic_forward|0.38".
    05 FILLER PIC X(100) VALUE "wooden_spear|kinetic_multiplier|0.7".
    05 FILLER PIC X(100) VALUE "wooden_spear|enchantable|15".
    05 FILLER PIC X(100) VALUE "stone_spear|attack_damage|1.0".
    05 FILLER PIC X(100) VALUE "stone_spear|attack_speed|-2.6667".
    05 FILLER PIC X(100) VALUE "stone_spear|attack_animation|stab 15".
    05 FILLER PIC X(100) VALUE "stone_spear|kinetic_contact_cooldown|10".
    05 FILLER PIC X(100) VALUE "stone_spear|kinetic_delay|14".
    05 FILLER PIC X(100) VALUE "stone_spear|kinetic_dismount|90 13.0".
    05 FILLER PIC X(100) VALUE "stone_spear|kinetic_knockback|180 5.1".
    05 FILLER PIC X(100) VALUE "stone_spear|kinetic_damage|275 4.6".
    05 FILLER PIC X(100) VALUE "stone_spear|kinetic_forward|0.38".
    05 FILLER PIC X(100) VALUE "stone_spear|kinetic_multiplier|0.82".
    05 FILLER PIC X(100) VALUE "stone_spear|enchantable|5".
    05 FILLER PIC X(100) VALUE "copper_spear|attack_damage|1.0".
    05 FILLER PIC X(100) VALUE "copper_spear|attack_speed|-2.8235".
    05 FILLER PIC X(100) VALUE "copper_spear|attack_animation|stab 17".
    05 FILLER PIC X(100) VALUE "copper_spear|kinetic_contact_cooldown|10".
    05 FILLER PIC X(100) VALUE "copper_spear|kinetic_delay|13".
    05 FILLER PIC X(100) VALUE "copper_spear|kinetic_dismount|80 12.0".
    05 FILLER PIC X(100) VALUE "copper_spear|kinetic_knockback|165 5.1".
    05 FILLER PIC X(100) VALUE "copper_spear|kinetic_damage|250 4.6".
    05 FILLER PIC X(100) VALUE "copper_spear|kinetic_forward|0.38".
    05 FILLER PIC X(100) VALUE "copper_spear|kinetic_multiplier|0.82".
    05 FILLER PIC X(100) VALUE "copper_spear|enchantable|13".
    05 FILLER PIC X(100) VALUE "iron_spear|attack_damage|2.0".
    05 FILLER PIC X(100) VALUE "iron_spear|attack_speed|-2.9474".
    05 FILLER PIC X(100) VALUE "iron_spear|attack_animation|stab 19".
    05 FILLER PIC X(100) VALUE "iron_spear|kinetic_contact_cooldown|10".
    05 FILLER PIC X(100) VALUE "iron_spear|kinetic_delay|12".
    05 FILLER PIC X(100) VALUE "iron_spear|kinetic_dismount|50 11.0".
    05 FILLER PIC X(100) VALUE "iron_spear|kinetic_knockback|135 5.1".
    05 FILLER PIC X(100) VALUE "iron_spear|kinetic_damage|225 4.6".
    05 FILLER PIC X(100) VALUE "iron_spear|kinetic_forward|0.38".
    05 FILLER PIC X(100) VALUE "iron_spear|kinetic_multiplier|0.95".
    05 FILLER PIC X(100) VALUE "iron_spear|enchantable|14".
    05 FILLER PIC X(100) VALUE "golden_spear|attack_damage|0.0".
    05 FILLER PIC X(100) VALUE "golden_spear|attack_speed|-2.9474".
    05 FILLER PIC X(100) VALUE "golden_spear|attack_animation|stab 19".
    05 FILLER PIC X(100) VALUE "golden_spear|kinetic_contact_cooldown|10".
    05 FILLER PIC X(100) VALUE "golden_spear|kinetic_delay|14".
    05 FILLER PIC X(100) VALUE "golden_spear|kinetic_dismount|70 13.0".
    05 FILLER PIC X(100) VALUE "golden_spear|kinetic_knockback|170 5.1".
    05 FILLER PIC X(100) VALUE "golden_spear|kinetic_damage|275 4.6".
    05 FILLER PIC X(100) VALUE "golden_spear|kinetic_forward|0.38".
    05 FILLER PIC X(100) VALUE "golden_spear|kinetic_multiplier|0.7".
    05 FILLER PIC X(100) VALUE "golden_spear|enchantable|22".
    05 FILLER PIC X(100) VALUE "diamond_spear|attack_damage|3.0".
    05 FILLER PIC X(100) VALUE "diamond_spear|attack_speed|-3.0476".
    05 FILLER PIC X(100) VALUE "diamond_spear|attack_animation|stab 21".
    05 FILLER PIC X(100) VALUE "diamond_spear|kinetic_contact_cooldown|10".
    05 FILLER PIC X(100) VALUE "diamond_spear|kinetic_delay|10".
    05 FILLER PIC X(100) VALUE "diamond_spear|kinetic_dismount|60 10.0".
    05 FILLER PIC X(100) VALUE "diamond_spear|kinetic_knockback|130 5.1".
    05 FILLER PIC X(100) VALUE "diamond_spear|kinetic_damage|200 4.6".
    05 FILLER PIC X(100) VALUE "diamond_spear|kinetic_forward|0.38".
    05 FILLER PIC X(100) VALUE "diamond_spear|kinetic_multiplier|1.075".
    05 FILLER PIC X(100) VALUE "diamond_spear|enchantable|10".
    05 FILLER PIC X(100) VALUE "netherite_spear|attack_damage|4.0".
    05 FILLER PIC X(100) VALUE "netherite_spear|attack_speed|-3.1304".
    05 FILLER PIC X(100) VALUE "netherite_spear|attack_animation|stab 23".
    05 FILLER PIC X(100) VALUE "netherite_spear|kinetic_contact_cooldown|10".
    05 FILLER PIC X(100) VALUE "netherite_spear|kinetic_delay|8".
    05 FILLER PIC X(100) VALUE "netherite_spear|kinetic_dismount|50 9.0".
    05 FILLER PIC X(100) VALUE "netherite_spear|kinetic_knockback|110 5.1".
    05 FILLER PIC X(100) VALUE "netherite_spear|kinetic_damage|175 4.6".
    05 FILLER PIC X(100) VALUE "netherite_spear|kinetic_forward|0.38".
    05 FILLER PIC X(100) VALUE "netherite_spear|kinetic_multiplier|1.2".
    05 FILLER PIC X(100) VALUE "netherite_spear|enchantable|15".
    05 FILLER PIC X(100) VALUE "wooden_spear|piercing_weapon|true false".
    05 FILLER PIC X(100) VALUE "wooden_spear|attack_range|2.0 4.5 2.0 6.5 0.125 0.5".
    05 FILLER PIC X(100) VALUE "wooden_spear|minimum_attack_charge|1.0".
    05 FILLER PIC X(100) VALUE "wooden_spear|damage_type|minecraft:spear".
    05 FILLER PIC X(100) VALUE "wooden_spear|use_effects|true false 1.0".
    05 FILLER PIC X(100) VALUE "wooden_spear|weapon|1".
    05 FILLER PIC X(100) VALUE "wooden_spear|weapon_disable_blocking|0.0".
    05 FILLER PIC X(100) VALUE "wooden_spear|repairable|#minecraft:wooden_tool_materials".
    05 FILLER PIC X(100) VALUE "stone_spear|repairable|#minecraft:stone_tool_materials".
    05 FILLER PIC X(100) VALUE "copper_spear|repairable|minecraft:copper_ingot".
    05 FILLER PIC X(100) VALUE "iron_spear|repairable|minecraft:iron_ingot".
    05 FILLER PIC X(100) VALUE "golden_spear|repairable|minecraft:gold_ingot".
    05 FILLER PIC X(100) VALUE "diamond_spear|repairable|minecraft:diamond".
    05 FILLER PIC X(100) VALUE "netherite_spear|repairable|minecraft:netherite_ingot".
    05 FILLER PIC X(100) VALUE "netherite_spear|max_damage|2031".
    05 FILLER PIC X(100) VALUE "wooden_spear|max_damage|59".
    05 FILLER PIC X(100) VALUE "netherite_spear|tool|-".
    05 FILLER PIC X(100) VALUE "wooden_spear|armor|-".
    05 FILLER PIC X(100) VALUE "mace|attack_damage|5.0".
    05 FILLER PIC X(100) VALUE "mace|attack_speed|-3.4".
    05 FILLER PIC X(100) VALUE "mace|tool_default_speed|1.0".
    05 FILLER PIC X(100) VALUE "mace|tool_damage_per_block|2".
    05 FILLER PIC X(100) VALUE "mace|tool_creative_break|0".
    05 FILLER PIC X(100) VALUE "mace|weapon_item_damage|1".
    05 FILLER PIC X(100) VALUE "mace|weapon_disable_blocking|0.0".
    05 FILLER PIC X(100) VALUE "mace|tool_rule_1|-".
    05 FILLER PIC X(100) VALUE "trident|attack_damage|8.0".
    05 FILLER PIC X(100) VALUE "trident|attack_speed|-2.9".
    05 FILLER PIC X(100) VALUE "trident|tool_default_speed|1.0".
    05 FILLER PIC X(100) VALUE "trident|tool_damage_per_block|2".
    05 FILLER PIC X(100) VALUE "trident|tool_creative_break|0".
    05 FILLER PIC X(100) VALUE "trident|weapon_item_damage|1".
    05 FILLER PIC X(100) VALUE "trident|weapon_disable_blocking|0.0".
    05 FILLER PIC X(100) VALUE "trident|tool_rule_1|-".
    05 FILLER PIC X(100) VALUE "mace|enchantable|15".
    05 FILLER PIC X(100) VALUE "mace|repairable|breeze_rod".
    05 FILLER PIC X(100) VALUE "mace|max_damage|500".
    05 FILLER PIC X(100) VALUE "trident|enchantable|1".
    05 FILLER PIC X(100) VALUE "trident|max_damage|250".
    05 FILLER PIC X(100) VALUE "shears|tool_rule_1|mine minecraft:cobweb 15.0".
    05 FILLER PIC X(100) VALUE "shears|tool_rule_2|speed #minecraft:shears_extreme_breaking_speed 15.0".
    05 FILLER PIC X(100) VALUE "shears|tool_rule_3|speed #minecraft:shears_major_breaking_speed 5.0".
    05 FILLER PIC X(100) VALUE "shears|tool_rule_4|speed #minecraft:shears_minor_breaking_speed 2.0".
    05 FILLER PIC X(100) VALUE "shears|tool_default_speed|1.0".
    05 FILLER PIC X(100) VALUE "shears|tool_damage_per_block|1".
    05 FILLER PIC X(100) VALUE "shears|tool_creative_break|1".
    05 FILLER PIC X(100) VALUE "shears|max_damage|238".
    05 FILLER PIC X(100) VALUE "shears|enchantable|-".
    05 FILLER PIC X(100) VALUE "bow|use_duration|72000".
    05 FILLER PIC X(100) VALUE "brush|use_duration|200".
    05 FILLER PIC X(100) VALUE "spyglass|use_duration|1200".
    05 FILLER PIC X(100) VALUE "carrot_on_a_stick|food_on_a_stick|pig 7".
    05 FILLER PIC X(100) VALUE "warped_fungus_on_a_stick|food_on_a_stick|strider 1".
    05 FILLER PIC X(100) VALUE "shield|equip_slot|offhand".
    05 FILLER PIC X(100) VALUE "elytra|equip_slot|chest".
    05 FILLER PIC X(100) VALUE "saddle|equip_slot|saddle".
    05 FILLER PIC X(100) VALUE "elytra|equippable_damage_on_hurt|0".
    05 FILLER PIC X(100) VALUE "elytra|max_damage|432".
    05 FILLER PIC X(100) VALUE "shield|repair_tag|wooden_tool_materials".
    05 FILLER PIC X(100) VALUE "bucket|use_duration|-".
    05 FILLER PIC X(100) VALUE "stone|food_on_a_stick|-".
    05 FILLER PIC X(100) VALUE "leather_horse_armor|armor|3".
    05 FILLER PIC X(100) VALUE "leather_horse_armor|armor_toughness|0.0".
    05 FILLER PIC X(100) VALUE "leather_horse_armor|armor_knockback_resistance|-".
    05 FILLER PIC X(100) VALUE "leather_horse_armor|enchantable|15".
    05 FILLER PIC X(100) VALUE "leather_horse_armor|repairable|minecraft:leather".
    05 FILLER PIC X(100) VALUE "leather_horse_armor|equippable|body".
    05 FILLER PIC X(100) VALUE "leather_horse_armor|equippable_damage_on_hurt|1".
    05 FILLER PIC X(100) VALUE "copper_horse_armor|armor|4".
    05 FILLER PIC X(100) VALUE "copper_horse_armor|armor_toughness|0.0".
    05 FILLER PIC X(100) VALUE "copper_horse_armor|armor_knockback_resistance|-".
    05 FILLER PIC X(100) VALUE "copper_horse_armor|enchantable|8".
    05 FILLER PIC X(100) VALUE "copper_horse_armor|repairable|minecraft:copper_ingot".
    05 FILLER PIC X(100) VALUE "copper_horse_armor|equippable|body".
    05 FILLER PIC X(100) VALUE "copper_horse_armor|equippable_damage_on_hurt|1".
    05 FILLER PIC X(100) VALUE "iron_horse_armor|armor|5".
    05 FILLER PIC X(100) VALUE "iron_horse_armor|armor_toughness|0.0".
    05 FILLER PIC X(100) VALUE "iron_horse_armor|armor_knockback_resistance|-".
    05 FILLER PIC X(100) VALUE "iron_horse_armor|enchantable|9".
    05 FILLER PIC X(100) VALUE "iron_horse_armor|repairable|minecraft:iron_ingot".
    05 FILLER PIC X(100) VALUE "iron_horse_armor|equippable|body".
    05 FILLER PIC X(100) VALUE "iron_horse_armor|equippable_damage_on_hurt|1".
    05 FILLER PIC X(100) VALUE "golden_horse_armor|armor|7".
    05 FILLER PIC X(100) VALUE "golden_horse_armor|armor_toughness|0.0".
    05 FILLER PIC X(100) VALUE "golden_horse_armor|armor_knockback_resistance|-".
    05 FILLER PIC X(100) VALUE "golden_horse_armor|enchantable|25".
    05 FILLER PIC X(100) VALUE "golden_horse_armor|repairable|minecraft:gold_ingot".
    05 FILLER PIC X(100) VALUE "golden_horse_armor|equippable|body".
    05 FILLER PIC X(100) VALUE "golden_horse_armor|equippable_damage_on_hurt|1".
    05 FILLER PIC X(100) VALUE "diamond_horse_armor|armor|11".
    05 FILLER PIC X(100) VALUE "diamond_horse_armor|armor_toughness|2.0".
    05 FILLER PIC X(100) VALUE "diamond_horse_armor|armor_knockback_resistance|-".
    05 FILLER PIC X(100) VALUE "diamond_horse_armor|enchantable|10".
    05 FILLER PIC X(100) VALUE "diamond_horse_armor|repairable|minecraft:diamond".
    05 FILLER PIC X(100) VALUE "diamond_horse_armor|equippable|body".
    05 FILLER PIC X(100) VALUE "diamond_horse_armor|equippable_damage_on_hurt|1".
    05 FILLER PIC X(100) VALUE "netherite_horse_armor|armor|19".
    05 FILLER PIC X(100) VALUE "netherite_horse_armor|armor_toughness|3.0".
    05 FILLER PIC X(100) VALUE "netherite_horse_armor|armor_knockback_resistance|0.1".
    05 FILLER PIC X(100) VALUE "netherite_horse_armor|enchantable|15".
    05 FILLER PIC X(100) VALUE "netherite_horse_armor|repairable|minecraft:netherite_ingot".
    05 FILLER PIC X(100) VALUE "netherite_horse_armor|equippable|body".
    05 FILLER PIC X(100) VALUE "netherite_horse_armor|equippable_damage_on_hurt|1".
    05 FILLER PIC X(100) VALUE "copper_nautilus_armor|armor|4".
    05 FILLER PIC X(100) VALUE "copper_nautilus_armor|armor_toughness|0.0".
    05 FILLER PIC X(100) VALUE "copper_nautilus_armor|armor_knockback_resistance|-".
    05 FILLER PIC X(100) VALUE "copper_nautilus_armor|enchantable|8".
    05 FILLER PIC X(100) VALUE "copper_nautilus_armor|repairable|minecraft:copper_ingot".
    05 FILLER PIC X(100) VALUE "copper_nautilus_armor|equippable|body".
    05 FILLER PIC X(100) VALUE "copper_nautilus_armor|equippable_damage_on_hurt|1".
    05 FILLER PIC X(100) VALUE "iron_nautilus_armor|armor|5".
    05 FILLER PIC X(100) VALUE "iron_nautilus_armor|armor_toughness|0.0".
    05 FILLER PIC X(100) VALUE "iron_nautilus_armor|armor_knockback_resistance|-".
    05 FILLER PIC X(100) VALUE "iron_nautilus_armor|enchantable|9".
    05 FILLER PIC X(100) VALUE "iron_nautilus_armor|repairable|minecraft:iron_ingot".
    05 FILLER PIC X(100) VALUE "iron_nautilus_armor|equippable|body".
    05 FILLER PIC X(100) VALUE "iron_nautilus_armor|equippable_damage_on_hurt|1".
    05 FILLER PIC X(100) VALUE "golden_nautilus_armor|armor|7".
    05 FILLER PIC X(100) VALUE "golden_nautilus_armor|armor_toughness|0.0".
    05 FILLER PIC X(100) VALUE "golden_nautilus_armor|armor_knockback_resistance|-".
    05 FILLER PIC X(100) VALUE "golden_nautilus_armor|enchantable|25".
    05 FILLER PIC X(100) VALUE "golden_nautilus_armor|repairable|minecraft:gold_ingot".
    05 FILLER PIC X(100) VALUE "golden_nautilus_armor|equippable|body".
    05 FILLER PIC X(100) VALUE "golden_nautilus_armor|equippable_damage_on_hurt|1".
    05 FILLER PIC X(100) VALUE "diamond_nautilus_armor|armor|11".
    05 FILLER PIC X(100) VALUE "diamond_nautilus_armor|armor_toughness|2.0".
    05 FILLER PIC X(100) VALUE "diamond_nautilus_armor|armor_knockback_resistance|-".
    05 FILLER PIC X(100) VALUE "diamond_nautilus_armor|enchantable|10".
    05 FILLER PIC X(100) VALUE "diamond_nautilus_armor|repairable|minecraft:diamond".
    05 FILLER PIC X(100) VALUE "diamond_nautilus_armor|equippable|body".
    05 FILLER PIC X(100) VALUE "diamond_nautilus_armor|equippable_damage_on_hurt|1".
    05 FILLER PIC X(100) VALUE "netherite_nautilus_armor|armor|19".
    05 FILLER PIC X(100) VALUE "netherite_nautilus_armor|armor_toughness|3.0".
    05 FILLER PIC X(100) VALUE "netherite_nautilus_armor|armor_knockback_resistance|0.1".
    05 FILLER PIC X(100) VALUE "netherite_nautilus_armor|enchantable|15".
    05 FILLER PIC X(100) VALUE "netherite_nautilus_armor|repairable|minecraft:netherite_ingot".
    05 FILLER PIC X(100) VALUE "netherite_nautilus_armor|equippable|body".
    05 FILLER PIC X(100) VALUE "netherite_nautilus_armor|equippable_damage_on_hurt|1".
    05 FILLER PIC X(100) VALUE "wolf_armor|armor|11".
    05 FILLER PIC X(100) VALUE "wolf_armor|armor_toughness|0.0".
    05 FILLER PIC X(100) VALUE "wolf_armor|armor_knockback_resistance|-".
    05 FILLER PIC X(100) VALUE "wolf_armor|enchantable|10".
    05 FILLER PIC X(100) VALUE "wolf_armor|repairable|minecraft:armadillo_scute".
    05 FILLER PIC X(100) VALUE "wolf_armor|equippable|body".
    05 FILLER PIC X(100) VALUE "wolf_armor|equippable_damage_on_hurt|1".
    05 FILLER PIC X(100) VALUE "wolf_armor|max_damage|64".
    05 FILLER PIC X(100) VALUE "iron_horse_armor|max_damage|-".
    05 FILLER PIC X(100) VALUE "diamond_nautilus_armor|max_damage|-".
    05 FILLER PIC X(100) VALUE "wooden_axe|block_transformer|axe".
    05 FILLER PIC X(100) VALUE "stone_axe|block_transformer|axe".
    05 FILLER PIC X(100) VALUE "copper_axe|block_transformer|axe".
    05 FILLER PIC X(100) VALUE "iron_axe|block_transformer|axe".
    05 FILLER PIC X(100) VALUE "golden_axe|block_transformer|axe".
    05 FILLER PIC X(100) VALUE "diamond_axe|block_transformer|axe".
    05 FILLER PIC X(100) VALUE "netherite_axe|block_transformer|axe".
    05 FILLER PIC X(100) VALUE "wooden_shovel|block_transformer|shovel".
    05 FILLER PIC X(100) VALUE "stone_shovel|block_transformer|shovel".
    05 FILLER PIC X(100) VALUE "copper_shovel|block_transformer|shovel".
    05 FILLER PIC X(100) VALUE "iron_shovel|block_transformer|shovel".
    05 FILLER PIC X(100) VALUE "golden_shovel|block_transformer|shovel".
    05 FILLER PIC X(100) VALUE "diamond_shovel|block_transformer|shovel".
    05 FILLER PIC X(100) VALUE "netherite_shovel|block_transformer|shovel".
    05 FILLER PIC X(100) VALUE "wooden_hoe|block_transformer|hoe".
    05 FILLER PIC X(100) VALUE "stone_hoe|block_transformer|hoe".
    05 FILLER PIC X(100) VALUE "copper_hoe|block_transformer|hoe".
    05 FILLER PIC X(100) VALUE "iron_hoe|block_transformer|hoe".
    05 FILLER PIC X(100) VALUE "golden_hoe|block_transformer|hoe".
    05 FILLER PIC X(100) VALUE "diamond_hoe|block_transformer|hoe".
    05 FILLER PIC X(100) VALUE "netherite_hoe|block_transformer|hoe".
    05 FILLER PIC X(100) VALUE "iron_pickaxe|block_transformer|-".
    05 FILLER PIC X(100) VALUE "iron_sword|block_transformer|-".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE-LINE        PIC X(100) OCCURS 248 TIMES.
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
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 248
         MOVE WS-CASE-LINE(WS-I) TO WS-CASE
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
     STRING "item components special: " FUNCTION TRIM(WS-ITEM) " " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
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
