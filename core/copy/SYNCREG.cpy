*> The 32 synchronized registries of docs/protocol/04 section 3, in the order of their Registry Data packets (09 section 3.1).
*> Protocol vocabulary only (standin-content section 0): which registries exist and in which order. Their entries, counts
*> and payloads come from the content set (CONTENT-REGISTRY-COUNT, CONTENT-REGISTRY-ENTRY); an empty registry sends no packet.
 78 REG-COUNT                 VALUE 32.
 01 REG-NAME-DATA.
    05 FILLER PIC X(48) VALUE "minecraft:worldgen/biome".
    05 FILLER PIC X(48) VALUE "minecraft:chat_type".
    05 FILLER PIC X(48) VALUE "minecraft:trim_pattern".
    05 FILLER PIC X(48) VALUE "minecraft:trim_material".
    05 FILLER PIC X(48) VALUE "minecraft:wolf_variant".
    05 FILLER PIC X(48) VALUE "minecraft:wolf_sound_variant".
    05 FILLER PIC X(48) VALUE "minecraft:pig_variant".
    05 FILLER PIC X(48) VALUE "minecraft:pig_sound_variant".
    05 FILLER PIC X(48) VALUE "minecraft:frog_variant".
    05 FILLER PIC X(48) VALUE "minecraft:cat_variant".
    05 FILLER PIC X(48) VALUE "minecraft:cat_sound_variant".
    05 FILLER PIC X(48) VALUE "minecraft:cow_sound_variant".
    05 FILLER PIC X(48) VALUE "minecraft:cow_variant".
    05 FILLER PIC X(48) VALUE "minecraft:chicken_sound_variant".
    05 FILLER PIC X(48) VALUE "minecraft:chicken_variant".
    05 FILLER PIC X(48) VALUE "minecraft:zombie_nautilus_variant".
    05 FILLER PIC X(48) VALUE "minecraft:painting_variant".
    05 FILLER PIC X(48) VALUE "minecraft:sulfur_cube_archetype".
    05 FILLER PIC X(48) VALUE "minecraft:dimension_type".
    05 FILLER PIC X(48) VALUE "minecraft:damage_type".
    05 FILLER PIC X(48) VALUE "minecraft:banner_pattern".
    05 FILLER PIC X(48) VALUE "minecraft:enchantment".
    05 FILLER PIC X(48) VALUE "minecraft:jukebox_song".
    05 FILLER PIC X(48) VALUE "minecraft:instrument".
    05 FILLER PIC X(48) VALUE "minecraft:test_environment".
    05 FILLER PIC X(48) VALUE "minecraft:test_instance".
    05 FILLER PIC X(48) VALUE "minecraft:dialog".
    05 FILLER PIC X(48) VALUE "minecraft:world_clock".
    05 FILLER PIC X(48) VALUE "minecraft:timeline".
    05 FILLER PIC X(48) VALUE "minecraft:decorated_pot_pattern".
    05 FILLER PIC X(48) VALUE "minecraft:block_transformer".
    05 FILLER PIC X(48) VALUE "minecraft:worldgen/block_state_provider".
 01 REG-NAME-TABLE REDEFINES REG-NAME-DATA.
    05 REG-NAME             PIC X(48) OCCURS 32 TIMES.
