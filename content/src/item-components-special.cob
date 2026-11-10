*> The default item components of the items the tool defaults of item-components.cob do not cover (T2016 to T2103 lane
*> prerequisite; 17 section 1.4, 2.4 spears, 2.5 and 2.6): the spears, the mace, the trident, shears, the animal armor
*> (horse, nautilus, wolf), the elytra, the block_transformer of the axes, shovels and hoes, and the single numbers of
*> the special items (use duration of the bow, brush and spyglass, the boost cost of the two sticks, the equipment
*> slot of the shield, elytra and saddle). The table is data, one line "item key|component name|value" per
*> component, generated from the tables of 17 (the spear values are the rows of 2.4; attack_speed of a spear is 1 / a
*> - 4.0 to four places, so the item's speed 4 + modifier reads back as the table's 1.5385 and so on).
*>
*> Component names (value formats, all text; assumptions in the header of item-components.cob, A7 to A9):
*>   spears: attack_damage (the material bonus, the item's damage is 1 + it), attack_speed, attack_animation "stab <ticks>",
*>     kinetic_contact_cooldown, kinetic_delay, kinetic_dismount / kinetic_knockback / kinetic_damage "<max ticks> <min
*>     speed>", kinetic_forward, kinetic_multiplier, piercing_weapon "<deals knockback> <dismounts>", attack_range (six
*>     floats), minimum_attack_charge, damage_type, use_effects "<can sprint> <vibrations> <speed multiplier>", weapon,
*>     weapon_disable_blocking, enchantable, repairable
*>   mace, trident: attack_damage, attack_speed (the amounts of the modifiers, 2.6), weapon_item_damage (their summary has a blank weapon entry), the tool defaults of a sword-like tool
*>     with no rules (tool_default_speed 1.0, tool_damage_per_block 2, tool_creative_break 0), weapon, weapon_disable_blocking
*>   shears: tool_rule_1 to tool_rule_4 (cobweb mine and drop 15.0; the three speed rules), tool_default_speed,
*>     tool_damage_per_block 1, tool_creative_break 1
*>   animal armor (leather to netherite horse armor, copper to netherite nautilus armor, wolf armor): armor (the body
*>     defense), armor_toughness, armor_knockback_resistance (netherite), equippable body, equippable_damage_on_hurt,
*>     enchantable, repairable; the wolf armor also max_damage 64 (the durability multiplier 4 x 16). Horse and nautilus
*>     armor have no max_damage default: the generated rows give them none.
*>   block_transformer: "axe", "shovel" or "hoe", the transformer data of 17 section 3.1, for the 21 tools
*>   others: use_duration, food_on_a_stick "<ride> <boost damage>", equip_slot, equippable_damage_on_hurt (elytra 0), repair_tag
*>
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ITEM-SPECIAL-COMPONENT.
*> USING item key (PIC X(38), no namespace), name (PIC X(32)), value out (PIC X(100)), status out (CT-OK, or the status as
*> it was when the table has no line for the pair).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-LINES.
    05 FILLER PIC X(120) VALUE "wooden_spear|attack_damage|0.0".
    05 FILLER PIC X(120) VALUE "wooden_spear|attack_speed|-2.4615".
    05 FILLER PIC X(120) VALUE "wooden_spear|attack_animation|stab 13".
    05 FILLER PIC X(120) VALUE "wooden_spear|kinetic_contact_cooldown|10".
    05 FILLER PIC X(120) VALUE "wooden_spear|kinetic_delay|15".
    05 FILLER PIC X(120) VALUE "wooden_spear|kinetic_dismount|100 14.0".
    05 FILLER PIC X(120) VALUE "wooden_spear|kinetic_knockback|200 5.1".
    05 FILLER PIC X(120) VALUE "wooden_spear|kinetic_damage|300 4.6".
    05 FILLER PIC X(120) VALUE "wooden_spear|kinetic_forward|0.38".
    05 FILLER PIC X(120) VALUE "wooden_spear|kinetic_multiplier|0.7".
    05 FILLER PIC X(120) VALUE "wooden_spear|piercing_weapon|true false".
    05 FILLER PIC X(120) VALUE "wooden_spear|attack_range|2.0 4.5 2.0 6.5 0.125 0.5".
    05 FILLER PIC X(120) VALUE "wooden_spear|minimum_attack_charge|1.0".
    05 FILLER PIC X(120) VALUE "wooden_spear|damage_type|minecraft:spear".
    05 FILLER PIC X(120) VALUE "wooden_spear|use_effects|true false 1.0".
    05 FILLER PIC X(120) VALUE "wooden_spear|weapon|1".
    05 FILLER PIC X(120) VALUE "wooden_spear|weapon_disable_blocking|0.0".
    05 FILLER PIC X(120) VALUE "wooden_spear|enchantable|15".
    05 FILLER PIC X(120) VALUE "wooden_spear|repairable|#minecraft:wooden_tool_materials".
    05 FILLER PIC X(120) VALUE "stone_spear|attack_damage|1.0".
    05 FILLER PIC X(120) VALUE "stone_spear|attack_speed|-2.6667".
    05 FILLER PIC X(120) VALUE "stone_spear|attack_animation|stab 15".
    05 FILLER PIC X(120) VALUE "stone_spear|kinetic_contact_cooldown|10".
    05 FILLER PIC X(120) VALUE "stone_spear|kinetic_delay|14".
    05 FILLER PIC X(120) VALUE "stone_spear|kinetic_dismount|90 13.0".
    05 FILLER PIC X(120) VALUE "stone_spear|kinetic_knockback|180 5.1".
    05 FILLER PIC X(120) VALUE "stone_spear|kinetic_damage|275 4.6".
    05 FILLER PIC X(120) VALUE "stone_spear|kinetic_forward|0.38".
    05 FILLER PIC X(120) VALUE "stone_spear|kinetic_multiplier|0.82".
    05 FILLER PIC X(120) VALUE "stone_spear|piercing_weapon|true false".
    05 FILLER PIC X(120) VALUE "stone_spear|attack_range|2.0 4.5 2.0 6.5 0.125 0.5".
    05 FILLER PIC X(120) VALUE "stone_spear|minimum_attack_charge|1.0".
    05 FILLER PIC X(120) VALUE "stone_spear|damage_type|minecraft:spear".
    05 FILLER PIC X(120) VALUE "stone_spear|use_effects|true false 1.0".
    05 FILLER PIC X(120) VALUE "stone_spear|weapon|1".
    05 FILLER PIC X(120) VALUE "stone_spear|weapon_disable_blocking|0.0".
    05 FILLER PIC X(120) VALUE "stone_spear|enchantable|5".
    05 FILLER PIC X(120) VALUE "stone_spear|repairable|#minecraft:stone_tool_materials".
    05 FILLER PIC X(120) VALUE "copper_spear|attack_damage|1.0".
    05 FILLER PIC X(120) VALUE "copper_spear|attack_speed|-2.8235".
    05 FILLER PIC X(120) VALUE "copper_spear|attack_animation|stab 17".
    05 FILLER PIC X(120) VALUE "copper_spear|kinetic_contact_cooldown|10".
    05 FILLER PIC X(120) VALUE "copper_spear|kinetic_delay|13".
    05 FILLER PIC X(120) VALUE "copper_spear|kinetic_dismount|80 12.0".
    05 FILLER PIC X(120) VALUE "copper_spear|kinetic_knockback|165 5.1".
    05 FILLER PIC X(120) VALUE "copper_spear|kinetic_damage|250 4.6".
    05 FILLER PIC X(120) VALUE "copper_spear|kinetic_forward|0.38".
    05 FILLER PIC X(120) VALUE "copper_spear|kinetic_multiplier|0.82".
    05 FILLER PIC X(120) VALUE "copper_spear|piercing_weapon|true false".
    05 FILLER PIC X(120) VALUE "copper_spear|attack_range|2.0 4.5 2.0 6.5 0.125 0.5".
    05 FILLER PIC X(120) VALUE "copper_spear|minimum_attack_charge|1.0".
    05 FILLER PIC X(120) VALUE "copper_spear|damage_type|minecraft:spear".
    05 FILLER PIC X(120) VALUE "copper_spear|use_effects|true false 1.0".
    05 FILLER PIC X(120) VALUE "copper_spear|weapon|1".
    05 FILLER PIC X(120) VALUE "copper_spear|weapon_disable_blocking|0.0".
    05 FILLER PIC X(120) VALUE "copper_spear|enchantable|13".
    05 FILLER PIC X(120) VALUE "copper_spear|repairable|minecraft:copper_ingot".
    05 FILLER PIC X(120) VALUE "iron_spear|attack_damage|2.0".
    05 FILLER PIC X(120) VALUE "iron_spear|attack_speed|-2.9474".
    05 FILLER PIC X(120) VALUE "iron_spear|attack_animation|stab 19".
    05 FILLER PIC X(120) VALUE "iron_spear|kinetic_contact_cooldown|10".
    05 FILLER PIC X(120) VALUE "iron_spear|kinetic_delay|12".
    05 FILLER PIC X(120) VALUE "iron_spear|kinetic_dismount|50 11.0".
    05 FILLER PIC X(120) VALUE "iron_spear|kinetic_knockback|135 5.1".
    05 FILLER PIC X(120) VALUE "iron_spear|kinetic_damage|225 4.6".
    05 FILLER PIC X(120) VALUE "iron_spear|kinetic_forward|0.38".
    05 FILLER PIC X(120) VALUE "iron_spear|kinetic_multiplier|0.95".
    05 FILLER PIC X(120) VALUE "iron_spear|piercing_weapon|true false".
    05 FILLER PIC X(120) VALUE "iron_spear|attack_range|2.0 4.5 2.0 6.5 0.125 0.5".
    05 FILLER PIC X(120) VALUE "iron_spear|minimum_attack_charge|1.0".
    05 FILLER PIC X(120) VALUE "iron_spear|damage_type|minecraft:spear".
    05 FILLER PIC X(120) VALUE "iron_spear|use_effects|true false 1.0".
    05 FILLER PIC X(120) VALUE "iron_spear|weapon|1".
    05 FILLER PIC X(120) VALUE "iron_spear|weapon_disable_blocking|0.0".
    05 FILLER PIC X(120) VALUE "iron_spear|enchantable|14".
    05 FILLER PIC X(120) VALUE "iron_spear|repairable|minecraft:iron_ingot".
    05 FILLER PIC X(120) VALUE "golden_spear|attack_damage|0.0".
    05 FILLER PIC X(120) VALUE "golden_spear|attack_speed|-2.9474".
    05 FILLER PIC X(120) VALUE "golden_spear|attack_animation|stab 19".
    05 FILLER PIC X(120) VALUE "golden_spear|kinetic_contact_cooldown|10".
    05 FILLER PIC X(120) VALUE "golden_spear|kinetic_delay|14".
    05 FILLER PIC X(120) VALUE "golden_spear|kinetic_dismount|70 13.0".
    05 FILLER PIC X(120) VALUE "golden_spear|kinetic_knockback|170 5.1".
    05 FILLER PIC X(120) VALUE "golden_spear|kinetic_damage|275 4.6".
    05 FILLER PIC X(120) VALUE "golden_spear|kinetic_forward|0.38".
    05 FILLER PIC X(120) VALUE "golden_spear|kinetic_multiplier|0.7".
    05 FILLER PIC X(120) VALUE "golden_spear|piercing_weapon|true false".
    05 FILLER PIC X(120) VALUE "golden_spear|attack_range|2.0 4.5 2.0 6.5 0.125 0.5".
    05 FILLER PIC X(120) VALUE "golden_spear|minimum_attack_charge|1.0".
    05 FILLER PIC X(120) VALUE "golden_spear|damage_type|minecraft:spear".
    05 FILLER PIC X(120) VALUE "golden_spear|use_effects|true false 1.0".
    05 FILLER PIC X(120) VALUE "golden_spear|weapon|1".
    05 FILLER PIC X(120) VALUE "golden_spear|weapon_disable_blocking|0.0".
    05 FILLER PIC X(120) VALUE "golden_spear|enchantable|22".
    05 FILLER PIC X(120) VALUE "golden_spear|repairable|minecraft:gold_ingot".
    05 FILLER PIC X(120) VALUE "diamond_spear|attack_damage|3.0".
    05 FILLER PIC X(120) VALUE "diamond_spear|attack_speed|-3.0476".
    05 FILLER PIC X(120) VALUE "diamond_spear|attack_animation|stab 21".
    05 FILLER PIC X(120) VALUE "diamond_spear|kinetic_contact_cooldown|10".
    05 FILLER PIC X(120) VALUE "diamond_spear|kinetic_delay|10".
    05 FILLER PIC X(120) VALUE "diamond_spear|kinetic_dismount|60 10.0".
    05 FILLER PIC X(120) VALUE "diamond_spear|kinetic_knockback|130 5.1".
    05 FILLER PIC X(120) VALUE "diamond_spear|kinetic_damage|200 4.6".
    05 FILLER PIC X(120) VALUE "diamond_spear|kinetic_forward|0.38".
    05 FILLER PIC X(120) VALUE "diamond_spear|kinetic_multiplier|1.075".
    05 FILLER PIC X(120) VALUE "diamond_spear|piercing_weapon|true false".
    05 FILLER PIC X(120) VALUE "diamond_spear|attack_range|2.0 4.5 2.0 6.5 0.125 0.5".
    05 FILLER PIC X(120) VALUE "diamond_spear|minimum_attack_charge|1.0".
    05 FILLER PIC X(120) VALUE "diamond_spear|damage_type|minecraft:spear".
    05 FILLER PIC X(120) VALUE "diamond_spear|use_effects|true false 1.0".
    05 FILLER PIC X(120) VALUE "diamond_spear|weapon|1".
    05 FILLER PIC X(120) VALUE "diamond_spear|weapon_disable_blocking|0.0".
    05 FILLER PIC X(120) VALUE "diamond_spear|enchantable|10".
    05 FILLER PIC X(120) VALUE "diamond_spear|repairable|minecraft:diamond".
    05 FILLER PIC X(120) VALUE "netherite_spear|attack_damage|4.0".
    05 FILLER PIC X(120) VALUE "netherite_spear|attack_speed|-3.1304".
    05 FILLER PIC X(120) VALUE "netherite_spear|attack_animation|stab 23".
    05 FILLER PIC X(120) VALUE "netherite_spear|kinetic_contact_cooldown|10".
    05 FILLER PIC X(120) VALUE "netherite_spear|kinetic_delay|8".
    05 FILLER PIC X(120) VALUE "netherite_spear|kinetic_dismount|50 9.0".
    05 FILLER PIC X(120) VALUE "netherite_spear|kinetic_knockback|110 5.1".
    05 FILLER PIC X(120) VALUE "netherite_spear|kinetic_damage|175 4.6".
    05 FILLER PIC X(120) VALUE "netherite_spear|kinetic_forward|0.38".
    05 FILLER PIC X(120) VALUE "netherite_spear|kinetic_multiplier|1.2".
    05 FILLER PIC X(120) VALUE "netherite_spear|piercing_weapon|true false".
    05 FILLER PIC X(120) VALUE "netherite_spear|attack_range|2.0 4.5 2.0 6.5 0.125 0.5".
    05 FILLER PIC X(120) VALUE "netherite_spear|minimum_attack_charge|1.0".
    05 FILLER PIC X(120) VALUE "netherite_spear|damage_type|minecraft:spear".
    05 FILLER PIC X(120) VALUE "netherite_spear|use_effects|true false 1.0".
    05 FILLER PIC X(120) VALUE "netherite_spear|weapon|1".
    05 FILLER PIC X(120) VALUE "netherite_spear|weapon_disable_blocking|0.0".
    05 FILLER PIC X(120) VALUE "netherite_spear|enchantable|15".
    05 FILLER PIC X(120) VALUE "netherite_spear|repairable|minecraft:netherite_ingot".
    05 FILLER PIC X(120) VALUE "mace|attack_damage|5.0".
    05 FILLER PIC X(120) VALUE "mace|attack_speed|-3.4".
    05 FILLER PIC X(120) VALUE "mace|tool_default_speed|1.0".
    05 FILLER PIC X(120) VALUE "mace|tool_damage_per_block|2".
    05 FILLER PIC X(120) VALUE "mace|tool_creative_break|0".
    05 FILLER PIC X(120) VALUE "mace|weapon_item_damage|1".
    05 FILLER PIC X(120) VALUE "mace|weapon_disable_blocking|0.0".
    05 FILLER PIC X(120) VALUE "trident|attack_damage|8.0".
    05 FILLER PIC X(120) VALUE "trident|attack_speed|-2.9".
    05 FILLER PIC X(120) VALUE "trident|tool_default_speed|1.0".
    05 FILLER PIC X(120) VALUE "trident|tool_damage_per_block|2".
    05 FILLER PIC X(120) VALUE "trident|tool_creative_break|0".
    05 FILLER PIC X(120) VALUE "trident|weapon_item_damage|1".
    05 FILLER PIC X(120) VALUE "trident|weapon_disable_blocking|0.0".
    05 FILLER PIC X(120) VALUE "shears|tool_rule_1|mine minecraft:cobweb 15.0".
    05 FILLER PIC X(120) VALUE "shears|tool_rule_2|speed #minecraft:shears_extreme_breaking_speed 15.0".
    05 FILLER PIC X(120) VALUE "shears|tool_rule_3|speed #minecraft:shears_major_breaking_speed 5.0".
    05 FILLER PIC X(120) VALUE "shears|tool_rule_4|speed #minecraft:shears_minor_breaking_speed 2.0".
    05 FILLER PIC X(120) VALUE "shears|tool_default_speed|1.0".
    05 FILLER PIC X(120) VALUE "shears|tool_damage_per_block|1".
    05 FILLER PIC X(120) VALUE "shears|tool_creative_break|1".
    05 FILLER PIC X(120) VALUE "bow|use_duration|72000".
    05 FILLER PIC X(120) VALUE "brush|use_duration|200".
    05 FILLER PIC X(120) VALUE "spyglass|use_duration|1200".
    05 FILLER PIC X(120) VALUE "carrot_on_a_stick|food_on_a_stick|pig 7".
    05 FILLER PIC X(120) VALUE "warped_fungus_on_a_stick|food_on_a_stick|strider 1".
    05 FILLER PIC X(120) VALUE "shield|equip_slot|offhand".
    05 FILLER PIC X(120) VALUE "elytra|equip_slot|chest".
    05 FILLER PIC X(120) VALUE "saddle|equip_slot|saddle".
    05 FILLER PIC X(120) VALUE "elytra|equippable_damage_on_hurt|0".
    05 FILLER PIC X(120) VALUE "shield|repair_tag|wooden_tool_materials".
    05 FILLER PIC X(120) VALUE "leather_horse_armor|armor|3".
    05 FILLER PIC X(120) VALUE "leather_horse_armor|armor_toughness|0.0".
    05 FILLER PIC X(120) VALUE "leather_horse_armor|equippable|body".
    05 FILLER PIC X(120) VALUE "leather_horse_armor|equippable_damage_on_hurt|1".
    05 FILLER PIC X(120) VALUE "leather_horse_armor|enchantable|15".
    05 FILLER PIC X(120) VALUE "leather_horse_armor|repairable|minecraft:leather".
    05 FILLER PIC X(120) VALUE "copper_horse_armor|armor|4".
    05 FILLER PIC X(120) VALUE "copper_horse_armor|armor_toughness|0.0".
    05 FILLER PIC X(120) VALUE "copper_horse_armor|equippable|body".
    05 FILLER PIC X(120) VALUE "copper_horse_armor|equippable_damage_on_hurt|1".
    05 FILLER PIC X(120) VALUE "copper_horse_armor|enchantable|8".
    05 FILLER PIC X(120) VALUE "copper_horse_armor|repairable|minecraft:copper_ingot".
    05 FILLER PIC X(120) VALUE "iron_horse_armor|armor|5".
    05 FILLER PIC X(120) VALUE "iron_horse_armor|armor_toughness|0.0".
    05 FILLER PIC X(120) VALUE "iron_horse_armor|equippable|body".
    05 FILLER PIC X(120) VALUE "iron_horse_armor|equippable_damage_on_hurt|1".
    05 FILLER PIC X(120) VALUE "iron_horse_armor|enchantable|9".
    05 FILLER PIC X(120) VALUE "iron_horse_armor|repairable|minecraft:iron_ingot".
    05 FILLER PIC X(120) VALUE "golden_horse_armor|armor|7".
    05 FILLER PIC X(120) VALUE "golden_horse_armor|armor_toughness|0.0".
    05 FILLER PIC X(120) VALUE "golden_horse_armor|equippable|body".
    05 FILLER PIC X(120) VALUE "golden_horse_armor|equippable_damage_on_hurt|1".
    05 FILLER PIC X(120) VALUE "golden_horse_armor|enchantable|25".
    05 FILLER PIC X(120) VALUE "golden_horse_armor|repairable|minecraft:gold_ingot".
    05 FILLER PIC X(120) VALUE "diamond_horse_armor|armor|11".
    05 FILLER PIC X(120) VALUE "diamond_horse_armor|armor_toughness|2.0".
    05 FILLER PIC X(120) VALUE "diamond_horse_armor|equippable|body".
    05 FILLER PIC X(120) VALUE "diamond_horse_armor|equippable_damage_on_hurt|1".
    05 FILLER PIC X(120) VALUE "diamond_horse_armor|enchantable|10".
    05 FILLER PIC X(120) VALUE "diamond_horse_armor|repairable|minecraft:diamond".
    05 FILLER PIC X(120) VALUE "netherite_horse_armor|armor|19".
    05 FILLER PIC X(120) VALUE "netherite_horse_armor|armor_toughness|3.0".
    05 FILLER PIC X(120) VALUE "netherite_horse_armor|armor_knockback_resistance|0.1".
    05 FILLER PIC X(120) VALUE "netherite_horse_armor|equippable|body".
    05 FILLER PIC X(120) VALUE "netherite_horse_armor|equippable_damage_on_hurt|1".
    05 FILLER PIC X(120) VALUE "netherite_horse_armor|enchantable|15".
    05 FILLER PIC X(120) VALUE "netherite_horse_armor|repairable|minecraft:netherite_ingot".
    05 FILLER PIC X(120) VALUE "copper_nautilus_armor|armor|4".
    05 FILLER PIC X(120) VALUE "copper_nautilus_armor|armor_toughness|0.0".
    05 FILLER PIC X(120) VALUE "copper_nautilus_armor|equippable|body".
    05 FILLER PIC X(120) VALUE "copper_nautilus_armor|equippable_damage_on_hurt|1".
    05 FILLER PIC X(120) VALUE "copper_nautilus_armor|enchantable|8".
    05 FILLER PIC X(120) VALUE "copper_nautilus_armor|repairable|minecraft:copper_ingot".
    05 FILLER PIC X(120) VALUE "iron_nautilus_armor|armor|5".
    05 FILLER PIC X(120) VALUE "iron_nautilus_armor|armor_toughness|0.0".
    05 FILLER PIC X(120) VALUE "iron_nautilus_armor|equippable|body".
    05 FILLER PIC X(120) VALUE "iron_nautilus_armor|equippable_damage_on_hurt|1".
    05 FILLER PIC X(120) VALUE "iron_nautilus_armor|enchantable|9".
    05 FILLER PIC X(120) VALUE "iron_nautilus_armor|repairable|minecraft:iron_ingot".
    05 FILLER PIC X(120) VALUE "golden_nautilus_armor|armor|7".
    05 FILLER PIC X(120) VALUE "golden_nautilus_armor|armor_toughness|0.0".
    05 FILLER PIC X(120) VALUE "golden_nautilus_armor|equippable|body".
    05 FILLER PIC X(120) VALUE "golden_nautilus_armor|equippable_damage_on_hurt|1".
    05 FILLER PIC X(120) VALUE "golden_nautilus_armor|enchantable|25".
    05 FILLER PIC X(120) VALUE "golden_nautilus_armor|repairable|minecraft:gold_ingot".
    05 FILLER PIC X(120) VALUE "diamond_nautilus_armor|armor|11".
    05 FILLER PIC X(120) VALUE "diamond_nautilus_armor|armor_toughness|2.0".
    05 FILLER PIC X(120) VALUE "diamond_nautilus_armor|equippable|body".
    05 FILLER PIC X(120) VALUE "diamond_nautilus_armor|equippable_damage_on_hurt|1".
    05 FILLER PIC X(120) VALUE "diamond_nautilus_armor|enchantable|10".
    05 FILLER PIC X(120) VALUE "diamond_nautilus_armor|repairable|minecraft:diamond".
    05 FILLER PIC X(120) VALUE "netherite_nautilus_armor|armor|19".
    05 FILLER PIC X(120) VALUE "netherite_nautilus_armor|armor_toughness|3.0".
    05 FILLER PIC X(120) VALUE "netherite_nautilus_armor|armor_knockback_resistance|0.1".
    05 FILLER PIC X(120) VALUE "netherite_nautilus_armor|equippable|body".
    05 FILLER PIC X(120) VALUE "netherite_nautilus_armor|equippable_damage_on_hurt|1".
    05 FILLER PIC X(120) VALUE "netherite_nautilus_armor|enchantable|15".
    05 FILLER PIC X(120) VALUE "netherite_nautilus_armor|repairable|minecraft:netherite_ingot".
    05 FILLER PIC X(120) VALUE "wolf_armor|armor|11".
    05 FILLER PIC X(120) VALUE "wolf_armor|armor_toughness|0.0".
    05 FILLER PIC X(120) VALUE "wolf_armor|equippable|body".
    05 FILLER PIC X(120) VALUE "wolf_armor|equippable_damage_on_hurt|1".
    05 FILLER PIC X(120) VALUE "wolf_armor|enchantable|10".
    05 FILLER PIC X(120) VALUE "wolf_armor|repairable|minecraft:armadillo_scute".
    05 FILLER PIC X(120) VALUE "wolf_armor|max_damage|64".
    05 FILLER PIC X(120) VALUE "wooden_axe|block_transformer|axe".
    05 FILLER PIC X(120) VALUE "stone_axe|block_transformer|axe".
    05 FILLER PIC X(120) VALUE "copper_axe|block_transformer|axe".
    05 FILLER PIC X(120) VALUE "iron_axe|block_transformer|axe".
    05 FILLER PIC X(120) VALUE "golden_axe|block_transformer|axe".
    05 FILLER PIC X(120) VALUE "diamond_axe|block_transformer|axe".
    05 FILLER PIC X(120) VALUE "netherite_axe|block_transformer|axe".
    05 FILLER PIC X(120) VALUE "wooden_shovel|block_transformer|shovel".
    05 FILLER PIC X(120) VALUE "stone_shovel|block_transformer|shovel".
    05 FILLER PIC X(120) VALUE "copper_shovel|block_transformer|shovel".
    05 FILLER PIC X(120) VALUE "iron_shovel|block_transformer|shovel".
    05 FILLER PIC X(120) VALUE "golden_shovel|block_transformer|shovel".
    05 FILLER PIC X(120) VALUE "diamond_shovel|block_transformer|shovel".
    05 FILLER PIC X(120) VALUE "netherite_shovel|block_transformer|shovel".
    05 FILLER PIC X(120) VALUE "wooden_hoe|block_transformer|hoe".
    05 FILLER PIC X(120) VALUE "stone_hoe|block_transformer|hoe".
    05 FILLER PIC X(120) VALUE "copper_hoe|block_transformer|hoe".
    05 FILLER PIC X(120) VALUE "iron_hoe|block_transformer|hoe".
    05 FILLER PIC X(120) VALUE "golden_hoe|block_transformer|hoe".
    05 FILLER PIC X(120) VALUE "diamond_hoe|block_transformer|hoe".
    05 FILLER PIC X(120) VALUE "netherite_hoe|block_transformer|hoe".
 01 WS-LINE-TABLE REDEFINES WS-LINES.
    05 WS-LINE             PIC X(120) OCCURS 260 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(38).
 01 WS-NAME                PIC X(32).
 01 WS-VALUE               PIC X(100).
 LINKAGE SECTION.
 01 L-KEY                  PIC X(38).
 01 L-NAME                 PIC X(32).
 01 L-VALUE                PIC X(100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-NAME L-VALUE L-STATUS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 260 OR L-STATUS = CT-OK
         MOVE SPACES TO WS-KEY WS-NAME WS-VALUE
         UNSTRING WS-LINE(WS-I) DELIMITED BY "|" INTO WS-KEY WS-NAME WS-VALUE
         IF WS-KEY = L-KEY AND WS-NAME = L-NAME
             MOVE WS-VALUE TO L-VALUE
             MOVE CT-OK TO L-STATUS
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ITEM-SPECIAL-COMPONENT.
