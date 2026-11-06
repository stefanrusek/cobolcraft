*> Synchronized registries (standin-content §4, as extended), transcribed: the entry data of every
*> Registry Data packet (docs/protocol/03 0x07, 04 §3, §4, §6) in id order. Tested by
*> core/tests/test_content_tables.cob; packets built by core/src/registries.cob.
*>
*> RG-REGISTRY: the 32 rows of the §4.2 summary, row n + 1 = registry number n. RG-KIND selects the
*>   entry table: RGK-EMPTY (OE, §4.9: no packet), RGK-BIOME (RB-, §4.3), RGK-CHAT (RC-, §4.4), RGK-MV
*>   (RM-, §4.5; RG-MV-ROW = the RM- row), RGK-DIMENSION-TYPE (RD-, §4.6), RGK-DAMAGE (RX-, §4.7),
*>   RGK-CLOCK (RW-, §4.8). RG-ENTRY-COUNT = entries sent (§4.2 "Entries sent").
*> Real numbers are integer THOUSANDTHS (0.6 -> 600). Absent fields: Byte -1, string length 0.
*> NBT field names are protocol vocabulary (04 §6); the field order of 09 §3.4 rule 9 is the order
*> in which registries.cob writes them.
 78 REG-COUNT                 VALUE 32.
 78 RGK-EMPTY                 VALUE 0.
 78 RGK-BIOME                 VALUE 1.
 78 RGK-CHAT                  VALUE 2.
 78 RGK-MV                    VALUE 3.
 78 RGK-DIMENSION-TYPE        VALUE 4.
 78 RGK-DAMAGE                VALUE 5.
 78 RGK-CLOCK                 VALUE 6.
 78 REG-PACKETS               VALUE 18.   *> registries with entries (§4.2: 18 packets)
 78 REG-ENTRIES               VALUE 52.   *> entries over all registries (§4.2)
 01 REGISTRY-DATA.
    05 FILLER.                                      *> #0
       10 FILLER PIC X(48) VALUE "minecraft:worldgen/biome".
       10 FILLER BINARY-LONG VALUE 24.              *> key length
       10 FILLER BINARY-LONG VALUE 1.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 3.               *> entries sent
       10 FILLER BINARY-LONG VALUE 0.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #1
       10 FILLER PIC X(48) VALUE "minecraft:chat_type".
       10 FILLER BINARY-LONG VALUE 19.              *> key length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 1.               *> entries sent
       10 FILLER BINARY-LONG VALUE 0.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #2
       10 FILLER PIC X(48) VALUE "minecraft:trim_pattern".
       10 FILLER BINARY-LONG VALUE 22.              *> key length
       10 FILLER BINARY-LONG VALUE 0.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 0.               *> entries sent
       10 FILLER BINARY-LONG VALUE 0.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #3
       10 FILLER PIC X(48) VALUE "minecraft:trim_material".
       10 FILLER BINARY-LONG VALUE 23.              *> key length
       10 FILLER BINARY-LONG VALUE 0.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 0.               *> entries sent
       10 FILLER BINARY-LONG VALUE 0.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #4
       10 FILLER PIC X(48) VALUE "minecraft:wolf_variant".
       10 FILLER BINARY-LONG VALUE 22.              *> key length
       10 FILLER BINARY-LONG VALUE 3.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 1.               *> entries sent
       10 FILLER BINARY-LONG VALUE 1.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #5
       10 FILLER PIC X(48) VALUE "minecraft:wolf_sound_variant".
       10 FILLER BINARY-LONG VALUE 28.              *> key length
       10 FILLER BINARY-LONG VALUE 3.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 1.               *> entries sent
       10 FILLER BINARY-LONG VALUE 2.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #6
       10 FILLER PIC X(48) VALUE "minecraft:pig_variant".
       10 FILLER BINARY-LONG VALUE 21.              *> key length
       10 FILLER BINARY-LONG VALUE 3.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 1.               *> entries sent
       10 FILLER BINARY-LONG VALUE 3.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #7
       10 FILLER PIC X(48) VALUE "minecraft:pig_sound_variant".
       10 FILLER BINARY-LONG VALUE 27.              *> key length
       10 FILLER BINARY-LONG VALUE 3.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 1.               *> entries sent
       10 FILLER BINARY-LONG VALUE 4.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #8
       10 FILLER PIC X(48) VALUE "minecraft:frog_variant".
       10 FILLER BINARY-LONG VALUE 22.              *> key length
       10 FILLER BINARY-LONG VALUE 3.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 1.               *> entries sent
       10 FILLER BINARY-LONG VALUE 5.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #9
       10 FILLER PIC X(48) VALUE "minecraft:cat_variant".
       10 FILLER BINARY-LONG VALUE 21.              *> key length
       10 FILLER BINARY-LONG VALUE 3.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 1.               *> entries sent
       10 FILLER BINARY-LONG VALUE 6.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #10
       10 FILLER PIC X(48) VALUE "minecraft:cat_sound_variant".
       10 FILLER BINARY-LONG VALUE 27.              *> key length
       10 FILLER BINARY-LONG VALUE 3.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 1.               *> entries sent
       10 FILLER BINARY-LONG VALUE 7.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #11
       10 FILLER PIC X(48) VALUE "minecraft:cow_sound_variant".
       10 FILLER BINARY-LONG VALUE 27.              *> key length
       10 FILLER BINARY-LONG VALUE 3.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 1.               *> entries sent
       10 FILLER BINARY-LONG VALUE 8.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #12
       10 FILLER PIC X(48) VALUE "minecraft:cow_variant".
       10 FILLER BINARY-LONG VALUE 21.              *> key length
       10 FILLER BINARY-LONG VALUE 3.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 1.               *> entries sent
       10 FILLER BINARY-LONG VALUE 9.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #13
       10 FILLER PIC X(48) VALUE "minecraft:chicken_sound_variant".
       10 FILLER BINARY-LONG VALUE 31.              *> key length
       10 FILLER BINARY-LONG VALUE 3.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 1.               *> entries sent
       10 FILLER BINARY-LONG VALUE 10.              *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #14
       10 FILLER PIC X(48) VALUE "minecraft:chicken_variant".
       10 FILLER BINARY-LONG VALUE 25.              *> key length
       10 FILLER BINARY-LONG VALUE 3.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 1.               *> entries sent
       10 FILLER BINARY-LONG VALUE 11.              *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #15
       10 FILLER PIC X(48) VALUE "minecraft:zombie_nautilus_variant".
       10 FILLER BINARY-LONG VALUE 33.              *> key length
       10 FILLER BINARY-LONG VALUE 3.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 1.               *> entries sent
       10 FILLER BINARY-LONG VALUE 12.              *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #16
       10 FILLER PIC X(48) VALUE "minecraft:painting_variant".
       10 FILLER BINARY-LONG VALUE 26.              *> key length
       10 FILLER BINARY-LONG VALUE 3.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 1.               *> entries sent
       10 FILLER BINARY-LONG VALUE 13.              *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #17
       10 FILLER PIC X(48) VALUE "minecraft:sulfur_cube_archetype".
       10 FILLER BINARY-LONG VALUE 31.              *> key length
       10 FILLER BINARY-LONG VALUE 0.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 0.               *> entries sent
       10 FILLER BINARY-LONG VALUE 0.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #18
       10 FILLER PIC X(48) VALUE "minecraft:dimension_type".
       10 FILLER BINARY-LONG VALUE 24.              *> key length
       10 FILLER BINARY-LONG VALUE 4.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 2.               *> entries sent
       10 FILLER BINARY-LONG VALUE 0.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #19
       10 FILLER PIC X(48) VALUE "minecraft:damage_type".
       10 FILLER BINARY-LONG VALUE 21.              *> key length
       10 FILLER BINARY-LONG VALUE 5.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 32.              *> entries sent
       10 FILLER BINARY-LONG VALUE 0.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #20
       10 FILLER PIC X(48) VALUE "minecraft:banner_pattern".
       10 FILLER BINARY-LONG VALUE 24.              *> key length
       10 FILLER BINARY-LONG VALUE 0.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 0.               *> entries sent
       10 FILLER BINARY-LONG VALUE 0.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #21
       10 FILLER PIC X(48) VALUE "minecraft:enchantment".
       10 FILLER BINARY-LONG VALUE 21.              *> key length
       10 FILLER BINARY-LONG VALUE 0.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 0.               *> entries sent
       10 FILLER BINARY-LONG VALUE 0.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #22
       10 FILLER PIC X(48) VALUE "minecraft:jukebox_song".
       10 FILLER BINARY-LONG VALUE 22.              *> key length
       10 FILLER BINARY-LONG VALUE 0.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 0.               *> entries sent
       10 FILLER BINARY-LONG VALUE 0.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #23
       10 FILLER PIC X(48) VALUE "minecraft:instrument".
       10 FILLER BINARY-LONG VALUE 20.              *> key length
       10 FILLER BINARY-LONG VALUE 0.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 0.               *> entries sent
       10 FILLER BINARY-LONG VALUE 0.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #24
       10 FILLER PIC X(48) VALUE "minecraft:test_environment".
       10 FILLER BINARY-LONG VALUE 26.              *> key length
       10 FILLER BINARY-LONG VALUE 0.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 0.               *> entries sent
       10 FILLER BINARY-LONG VALUE 0.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #25
       10 FILLER PIC X(48) VALUE "minecraft:test_instance".
       10 FILLER BINARY-LONG VALUE 23.              *> key length
       10 FILLER BINARY-LONG VALUE 0.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 0.               *> entries sent
       10 FILLER BINARY-LONG VALUE 0.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #26
       10 FILLER PIC X(48) VALUE "minecraft:dialog".
       10 FILLER BINARY-LONG VALUE 16.              *> key length
       10 FILLER BINARY-LONG VALUE 0.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 0.               *> entries sent
       10 FILLER BINARY-LONG VALUE 0.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #27
       10 FILLER PIC X(48) VALUE "minecraft:world_clock".
       10 FILLER BINARY-LONG VALUE 21.              *> key length
       10 FILLER BINARY-LONG VALUE 6.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 1.               *> entries sent
       10 FILLER BINARY-LONG VALUE 0.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #28
       10 FILLER PIC X(48) VALUE "minecraft:timeline".
       10 FILLER BINARY-LONG VALUE 18.              *> key length
       10 FILLER BINARY-LONG VALUE 0.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 0.               *> entries sent
       10 FILLER BINARY-LONG VALUE 0.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #29
       10 FILLER PIC X(48) VALUE "minecraft:decorated_pot_pattern".
       10 FILLER BINARY-LONG VALUE 31.              *> key length
       10 FILLER BINARY-LONG VALUE 0.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 0.               *> entries sent
       10 FILLER BINARY-LONG VALUE 0.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #30
       10 FILLER PIC X(48) VALUE "minecraft:block_transformer".
       10 FILLER BINARY-LONG VALUE 27.              *> key length
       10 FILLER BINARY-LONG VALUE 0.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 0.               *> entries sent
       10 FILLER BINARY-LONG VALUE 0.               *> RM- row (MV registries), else 0
    05 FILLER.                                      *> #31
       10 FILLER PIC X(48) VALUE "minecraft:worldgen/block_state_provider".
       10 FILLER BINARY-LONG VALUE 39.              *> key length
       10 FILLER BINARY-LONG VALUE 0.               *> kind (RGK-*)
       10 FILLER BINARY-LONG VALUE 0.               *> entries sent
       10 FILLER BINARY-LONG VALUE 0.               *> RM- row (MV registries), else 0
 01 REGISTRY-TABLE REDEFINES REGISTRY-DATA.
    05 RG-REGISTRY OCCURS 32 TIMES.
       10 RG-KEY                PIC X(48).
       10 RG-KEY-LENGTH         BINARY-LONG.
       10 RG-KIND               BINARY-LONG.
       10 RG-ENTRY-COUNT        BINARY-LONG.
       10 RG-MV-ROW             BINARY-LONG.

*> worldgen/biome (§4.3), row = biome id + 1 (BLOCKS.cpy BIOME-*). effects colours exactly as standin.
 78 RB-COUNT                  VALUE 3.
 01 REG-BIOME-DATA.
    05 FILLER.                                      *> biome 0
       10 FILLER PIC X(32) VALUE "minecraft:plains".
       10 FILLER BINARY-LONG VALUE 16.              *> key length
       10 FILLER BINARY-LONG VALUE 1.               *> has_precipitation
       10 FILLER BINARY-LONG VALUE 600.             *> temperature/1000
       10 FILLER BINARY-LONG VALUE 400.             *> downfall/1000
       10 FILLER PIC X(7) VALUE "#3A6EA5".
       10 FILLER PIC X(7) VALUE "#4F8F3A".
       10 FILLER PIC X(7) VALUE "#4F8F3A".
    05 FILLER.                                      *> biome 1
       10 FILLER PIC X(32) VALUE "cobolcraft:upland".
       10 FILLER BINARY-LONG VALUE 17.              *> key length
       10 FILLER BINARY-LONG VALUE 1.               *> has_precipitation
       10 FILLER BINARY-LONG VALUE 300.             *> temperature/1000
       10 FILLER BINARY-LONG VALUE 200.             *> downfall/1000
       10 FILLER PIC X(7) VALUE "#2F5C8C".
       10 FILLER PIC X(7) VALUE "#6B9A55".
       10 FILLER PIC X(7) VALUE "#6B9A55".
    05 FILLER.                                      *> biome 2
       10 FILLER PIC X(32) VALUE "cobolcraft:ash_flats".
       10 FILLER BINARY-LONG VALUE 20.              *> key length
       10 FILLER BINARY-LONG VALUE 0.               *> has_precipitation
       10 FILLER BINARY-LONG VALUE 1400.            *> temperature/1000
       10 FILLER BINARY-LONG VALUE 0.               *> downfall/1000
       10 FILLER PIC X(7) VALUE "#3A2F2A".
       10 FILLER PIC X(7) VALUE "#5A4A40".
       10 FILLER PIC X(7) VALUE "#5A4A40".
 01 REG-BIOME-TABLE REDEFINES REG-BIOME-DATA.
    05 RB-ENTRY OCCURS 3 TIMES.
       10 RB-KEY                PIC X(32).
       10 RB-KEY-LENGTH         BINARY-LONG.
       10 RB-PRECIPITATION      BINARY-LONG.
       10 RB-TEMPERATURE-MILLI  BINARY-LONG.
       10 RB-DOWNFALL-MILLI     BINARY-LONG.
       10 RB-WATER-COLOR        PIC X(7).
       10 RB-GRASS-COLOR        PIC X(7).
       10 RB-FOLIAGE-COLOR      PIC X(7).

*> chat_type (§4.4): one entry with two decorations, chat then narration (cell order), each a
*> translation_key and a List of String parameters; style absent.
 78 RC-COUNT                  VALUE 1.
 01 REG-CHAT-DATA.
    05 FILLER.                                      *> chat type 0
       10 FILLER PIC X(32) VALUE "cobolcraft:say".
       10 FILLER BINARY-LONG VALUE 14.              *> key length
       10 FILLER.                                   *> decoration chat
          15 FILLER PIC X(16) VALUE "chat".
          15 FILLER BINARY-LONG VALUE 4.               *> name length
          15 FILLER PIC X(40) VALUE "cobolcraft.chat.say".
          15 FILLER BINARY-LONG VALUE 19.              *> translation_key length
          15 FILLER BINARY-LONG VALUE 2.               *> parameter count
          15 FILLER PIC X(16) VALUE "sender".
          15 FILLER BINARY-LONG VALUE 6.               *> parameter length
          15 FILLER PIC X(16) VALUE "content".
          15 FILLER BINARY-LONG VALUE 7.               *> parameter length
       10 FILLER.                                   *> decoration narration
          15 FILLER PIC X(16) VALUE "narration".
          15 FILLER BINARY-LONG VALUE 9.               *> name length
          15 FILLER PIC X(40) VALUE "cobolcraft.chat.say.narrate".
          15 FILLER BINARY-LONG VALUE 27.              *> translation_key length
          15 FILLER BINARY-LONG VALUE 2.               *> parameter count
          15 FILLER PIC X(16) VALUE "sender".
          15 FILLER BINARY-LONG VALUE 6.               *> parameter length
          15 FILLER PIC X(16) VALUE "content".
          15 FILLER BINARY-LONG VALUE 7.               *> parameter length
 01 REG-CHAT-TABLE REDEFINES REG-CHAT-DATA.
    05 RC-ENTRY OCCURS 1 TIMES.
       10 RC-KEY                PIC X(32).
       10 RC-KEY-LENGTH         BINARY-LONG.
       10 RC-DECORATION OCCURS 2 TIMES.
          15 RC-DEC-NAME        PIC X(16).
          15 RC-DEC-NAME-LENGTH BINARY-LONG.
          15 RC-DEC-KEY         PIC X(40).
          15 RC-DEC-KEY-LENGTH  BINARY-LONG.
          15 RC-PARAM-COUNT     BINARY-LONG.
          15 RC-PARAM OCCURS 2 TIMES.
             20 RC-PARAM-NAME   PIC X(16).
             20 RC-PARAM-LENGTH BINARY-LONG.

*> Mandatory variant registries (§4.5): one entry each, key RG-PLACEHOLDER-KEY. RM- row: the
*> registry number, the group compounds (0 = the fields sit on the entry itself; 2 = the fields are
*> repeated inside each named group, e.g. adult_sounds then baby_sounds) and the entry's fields, rows
*> RM-FIRST-FIELD to RM-FIRST-FIELD + RM-FIELD-COUNT - 1 of RF-. Field kinds: RMF-TEXTURE (String,
*> RG-PLACEHOLDER-TEXTURE), RMF-SOUND (the inline Compound {sound_id: RG-PLACEHOLDER-SOUND}),
*> RMF-STRING (String RF-STRING), RMF-INT (Int RF-INT).
 78 RM-COUNT                  VALUE 13.
 78 RMF-TEXTURE               VALUE 1.
 78 RMF-SOUND                 VALUE 2.
 78 RMF-STRING                VALUE 3.
 78 RMF-INT                   VALUE 4.
 01 RG-PLACEHOLDER-KEY        PIC X(22) VALUE "cobolcraft:placeholder".
 01 RG-PLACEHOLDER-TEXTURE    PIC X(29) VALUE "cobolcraft:entity/placeholder".
 01 RG-PLACEHOLDER-SOUND      PIC X(17) VALUE "cobolcraft:silent".
 01 RG-PLACEHOLDER-KEY-LENGTH     BINARY-LONG VALUE 22.
 01 RG-PLACEHOLDER-TEXTURE-LENGTH BINARY-LONG VALUE 29.
 01 RG-PLACEHOLDER-SOUND-LENGTH   BINARY-LONG VALUE 17.
 01 REG-MV-DATA.
    05 FILLER.                                      *> minecraft:wolf_variant
       10 FILLER BINARY-LONG VALUE 4.               *> registry number
       10 FILLER BINARY-LONG VALUE 2.               *> group count
       10 FILLER PIC X(16) VALUE "assets".
       10 FILLER BINARY-LONG VALUE 6.               *> group name length
       10 FILLER PIC X(16) VALUE "baby_assets".
       10 FILLER BINARY-LONG VALUE 11.              *> group name length
       10 FILLER BINARY-LONG VALUE 1.               *> first RF- row
       10 FILLER BINARY-LONG VALUE 3.               *> field count
    05 FILLER.                                      *> minecraft:wolf_sound_variant
       10 FILLER BINARY-LONG VALUE 5.               *> registry number
       10 FILLER BINARY-LONG VALUE 2.               *> group count
       10 FILLER PIC X(16) VALUE "adult_sounds".
       10 FILLER BINARY-LONG VALUE 12.              *> group name length
       10 FILLER PIC X(16) VALUE "baby_sounds".
       10 FILLER BINARY-LONG VALUE 11.              *> group name length
       10 FILLER BINARY-LONG VALUE 4.               *> first RF- row
       10 FILLER BINARY-LONG VALUE 7.               *> field count
    05 FILLER.                                      *> minecraft:pig_variant
       10 FILLER BINARY-LONG VALUE 6.               *> registry number
       10 FILLER BINARY-LONG VALUE 0.               *> group count
       10 FILLER PIC X(16) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> group name length
       10 FILLER PIC X(16) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> group name length
       10 FILLER BINARY-LONG VALUE 11.              *> first RF- row
       10 FILLER BINARY-LONG VALUE 3.               *> field count
    05 FILLER.                                      *> minecraft:pig_sound_variant
       10 FILLER BINARY-LONG VALUE 7.               *> registry number
       10 FILLER BINARY-LONG VALUE 2.               *> group count
       10 FILLER PIC X(16) VALUE "adult_sounds".
       10 FILLER BINARY-LONG VALUE 12.              *> group name length
       10 FILLER PIC X(16) VALUE "baby_sounds".
       10 FILLER BINARY-LONG VALUE 11.              *> group name length
       10 FILLER BINARY-LONG VALUE 14.              *> first RF- row
       10 FILLER BINARY-LONG VALUE 5.               *> field count
    05 FILLER.                                      *> minecraft:frog_variant
       10 FILLER BINARY-LONG VALUE 8.               *> registry number
       10 FILLER BINARY-LONG VALUE 0.               *> group count
       10 FILLER PIC X(16) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> group name length
       10 FILLER PIC X(16) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> group name length
       10 FILLER BINARY-LONG VALUE 19.              *> first RF- row
       10 FILLER BINARY-LONG VALUE 1.               *> field count
    05 FILLER.                                      *> minecraft:cat_variant
       10 FILLER BINARY-LONG VALUE 9.               *> registry number
       10 FILLER BINARY-LONG VALUE 0.               *> group count
       10 FILLER PIC X(16) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> group name length
       10 FILLER PIC X(16) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> group name length
       10 FILLER BINARY-LONG VALUE 20.              *> first RF- row
       10 FILLER BINARY-LONG VALUE 2.               *> field count
    05 FILLER.                                      *> minecraft:cat_sound_variant
       10 FILLER BINARY-LONG VALUE 10.              *> registry number
       10 FILLER BINARY-LONG VALUE 2.               *> group count
       10 FILLER PIC X(16) VALUE "adult_sounds".
       10 FILLER BINARY-LONG VALUE 12.              *> group name length
       10 FILLER PIC X(16) VALUE "baby_sounds".
       10 FILLER BINARY-LONG VALUE 11.              *> group name length
       10 FILLER BINARY-LONG VALUE 22.              *> first RF- row
       10 FILLER BINARY-LONG VALUE 9.               *> field count
    05 FILLER.                                      *> minecraft:cow_sound_variant
       10 FILLER BINARY-LONG VALUE 11.              *> registry number
       10 FILLER BINARY-LONG VALUE 0.               *> group count
       10 FILLER PIC X(16) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> group name length
       10 FILLER PIC X(16) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> group name length
       10 FILLER BINARY-LONG VALUE 31.              *> first RF- row
       10 FILLER BINARY-LONG VALUE 4.               *> field count
    05 FILLER.                                      *> minecraft:cow_variant
       10 FILLER BINARY-LONG VALUE 12.              *> registry number
       10 FILLER BINARY-LONG VALUE 0.               *> group count
       10 FILLER PIC X(16) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> group name length
       10 FILLER PIC X(16) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> group name length
       10 FILLER BINARY-LONG VALUE 35.              *> first RF- row
       10 FILLER BINARY-LONG VALUE 3.               *> field count
    05 FILLER.                                      *> minecraft:chicken_sound_variant
       10 FILLER BINARY-LONG VALUE 13.              *> registry number
       10 FILLER BINARY-LONG VALUE 2.               *> group count
       10 FILLER PIC X(16) VALUE "adult_sounds".
       10 FILLER BINARY-LONG VALUE 12.              *> group name length
       10 FILLER PIC X(16) VALUE "baby_sounds".
       10 FILLER BINARY-LONG VALUE 11.              *> group name length
       10 FILLER BINARY-LONG VALUE 38.              *> first RF- row
       10 FILLER BINARY-LONG VALUE 4.               *> field count
    05 FILLER.                                      *> minecraft:chicken_variant
       10 FILLER BINARY-LONG VALUE 14.              *> registry number
       10 FILLER BINARY-LONG VALUE 0.               *> group count
       10 FILLER PIC X(16) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> group name length
       10 FILLER PIC X(16) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> group name length
       10 FILLER BINARY-LONG VALUE 42.              *> first RF- row
       10 FILLER BINARY-LONG VALUE 3.               *> field count
    05 FILLER.                                      *> minecraft:zombie_nautilus_variant
       10 FILLER BINARY-LONG VALUE 15.              *> registry number
       10 FILLER BINARY-LONG VALUE 0.               *> group count
       10 FILLER PIC X(16) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> group name length
       10 FILLER PIC X(16) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> group name length
       10 FILLER BINARY-LONG VALUE 45.              *> first RF- row
       10 FILLER BINARY-LONG VALUE 2.               *> field count
    05 FILLER.                                      *> minecraft:painting_variant
       10 FILLER BINARY-LONG VALUE 16.              *> registry number
       10 FILLER BINARY-LONG VALUE 0.               *> group count
       10 FILLER PIC X(16) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> group name length
       10 FILLER PIC X(16) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> group name length
       10 FILLER BINARY-LONG VALUE 47.              *> first RF- row
       10 FILLER BINARY-LONG VALUE 4.               *> field count
 01 REG-MV-TABLE REDEFINES REG-MV-DATA.
    05 RM-ENTRY OCCURS 13 TIMES.
       10 RM-REGISTRY           BINARY-LONG.
       10 RM-GROUP-COUNT        BINARY-LONG.
       10 RM-GROUP OCCURS 2 TIMES.
          15 RM-GROUP-NAME      PIC X(16).
          15 RM-GROUP-LENGTH    BINARY-LONG.
       10 RM-FIRST-FIELD        BINARY-LONG.
       10 RM-FIELD-COUNT        BINARY-LONG.
 78 RF-COUNT                  VALUE 50.
 01 REG-MV-FIELD-DATA.
    05 FILLER.                                      *> field 1
       10 FILLER PIC X(24) VALUE "wild".
       10 FILLER BINARY-LONG VALUE 4.               *> name length
       10 FILLER BINARY-LONG VALUE 1.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 2
       10 FILLER PIC X(24) VALUE "tame".
       10 FILLER BINARY-LONG VALUE 4.               *> name length
       10 FILLER BINARY-LONG VALUE 1.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 3
       10 FILLER PIC X(24) VALUE "angry".
       10 FILLER BINARY-LONG VALUE 5.               *> name length
       10 FILLER BINARY-LONG VALUE 1.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 4
       10 FILLER PIC X(24) VALUE "ambient_sound".
       10 FILLER BINARY-LONG VALUE 13.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 5
       10 FILLER PIC X(24) VALUE "death_sound".
       10 FILLER BINARY-LONG VALUE 11.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 6
       10 FILLER PIC X(24) VALUE "growl_sound".
       10 FILLER BINARY-LONG VALUE 11.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 7
       10 FILLER PIC X(24) VALUE "hurt_sound".
       10 FILLER BINARY-LONG VALUE 10.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 8
       10 FILLER PIC X(24) VALUE "pant_sound".
       10 FILLER BINARY-LONG VALUE 10.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 9
       10 FILLER PIC X(24) VALUE "whine_sound".
       10 FILLER BINARY-LONG VALUE 11.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 10
       10 FILLER PIC X(24) VALUE "step_sound".
       10 FILLER BINARY-LONG VALUE 10.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 11
       10 FILLER PIC X(24) VALUE "model".
       10 FILLER BINARY-LONG VALUE 5.               *> name length
       10 FILLER BINARY-LONG VALUE 3.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE "normal".
       10 FILLER BINARY-LONG VALUE 6.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 12
       10 FILLER PIC X(24) VALUE "asset_id".
       10 FILLER BINARY-LONG VALUE 8.               *> name length
       10 FILLER BINARY-LONG VALUE 1.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 13
       10 FILLER PIC X(24) VALUE "baby_asset_id".
       10 FILLER BINARY-LONG VALUE 13.              *> name length
       10 FILLER BINARY-LONG VALUE 1.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 14
       10 FILLER PIC X(24) VALUE "ambient_sound".
       10 FILLER BINARY-LONG VALUE 13.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 15
       10 FILLER PIC X(24) VALUE "hurt_sound".
       10 FILLER BINARY-LONG VALUE 10.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 16
       10 FILLER PIC X(24) VALUE "death_sound".
       10 FILLER BINARY-LONG VALUE 11.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 17
       10 FILLER PIC X(24) VALUE "step_sound".
       10 FILLER BINARY-LONG VALUE 10.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 18
       10 FILLER PIC X(24) VALUE "eat_sound".
       10 FILLER BINARY-LONG VALUE 9.               *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 19
       10 FILLER PIC X(24) VALUE "asset_id".
       10 FILLER BINARY-LONG VALUE 8.               *> name length
       10 FILLER BINARY-LONG VALUE 1.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 20
       10 FILLER PIC X(24) VALUE "asset_id".
       10 FILLER BINARY-LONG VALUE 8.               *> name length
       10 FILLER BINARY-LONG VALUE 1.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 21
       10 FILLER PIC X(24) VALUE "baby_asset_id".
       10 FILLER BINARY-LONG VALUE 13.              *> name length
       10 FILLER BINARY-LONG VALUE 1.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 22
       10 FILLER PIC X(24) VALUE "ambient_sound".
       10 FILLER BINARY-LONG VALUE 13.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 23
       10 FILLER PIC X(24) VALUE "stray_ambient_sound".
       10 FILLER BINARY-LONG VALUE 19.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 24
       10 FILLER PIC X(24) VALUE "hiss_sound".
       10 FILLER BINARY-LONG VALUE 10.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 25
       10 FILLER PIC X(24) VALUE "hurt_sound".
       10 FILLER BINARY-LONG VALUE 10.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 26
       10 FILLER PIC X(24) VALUE "death_sound".
       10 FILLER BINARY-LONG VALUE 11.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 27
       10 FILLER PIC X(24) VALUE "eat_sound".
       10 FILLER BINARY-LONG VALUE 9.               *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 28
       10 FILLER PIC X(24) VALUE "beg_for_food_sound".
       10 FILLER BINARY-LONG VALUE 18.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 29
       10 FILLER PIC X(24) VALUE "purr_sound".
       10 FILLER BINARY-LONG VALUE 10.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 30
       10 FILLER PIC X(24) VALUE "purreow_sound".
       10 FILLER BINARY-LONG VALUE 13.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 31
       10 FILLER PIC X(24) VALUE "ambient_sound".
       10 FILLER BINARY-LONG VALUE 13.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 32
       10 FILLER PIC X(24) VALUE "hurt_sound".
       10 FILLER BINARY-LONG VALUE 10.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 33
       10 FILLER PIC X(24) VALUE "death_sound".
       10 FILLER BINARY-LONG VALUE 11.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 34
       10 FILLER PIC X(24) VALUE "step_sound".
       10 FILLER BINARY-LONG VALUE 10.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 35
       10 FILLER PIC X(24) VALUE "model".
       10 FILLER BINARY-LONG VALUE 5.               *> name length
       10 FILLER BINARY-LONG VALUE 3.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE "normal".
       10 FILLER BINARY-LONG VALUE 6.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 36
       10 FILLER PIC X(24) VALUE "asset_id".
       10 FILLER BINARY-LONG VALUE 8.               *> name length
       10 FILLER BINARY-LONG VALUE 1.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 37
       10 FILLER PIC X(24) VALUE "baby_asset_id".
       10 FILLER BINARY-LONG VALUE 13.              *> name length
       10 FILLER BINARY-LONG VALUE 1.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 38
       10 FILLER PIC X(24) VALUE "ambient_sound".
       10 FILLER BINARY-LONG VALUE 13.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 39
       10 FILLER PIC X(24) VALUE "hurt_sound".
       10 FILLER BINARY-LONG VALUE 10.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 40
       10 FILLER PIC X(24) VALUE "death_sound".
       10 FILLER BINARY-LONG VALUE 11.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 41
       10 FILLER PIC X(24) VALUE "step_sound".
       10 FILLER BINARY-LONG VALUE 10.              *> name length
       10 FILLER BINARY-LONG VALUE 2.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 42
       10 FILLER PIC X(24) VALUE "model".
       10 FILLER BINARY-LONG VALUE 5.               *> name length
       10 FILLER BINARY-LONG VALUE 3.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE "normal".
       10 FILLER BINARY-LONG VALUE 6.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 43
       10 FILLER PIC X(24) VALUE "asset_id".
       10 FILLER BINARY-LONG VALUE 8.               *> name length
       10 FILLER BINARY-LONG VALUE 1.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 44
       10 FILLER PIC X(24) VALUE "baby_asset_id".
       10 FILLER BINARY-LONG VALUE 13.              *> name length
       10 FILLER BINARY-LONG VALUE 1.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 45
       10 FILLER PIC X(24) VALUE "model".
       10 FILLER BINARY-LONG VALUE 5.               *> name length
       10 FILLER BINARY-LONG VALUE 3.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE "normal".
       10 FILLER BINARY-LONG VALUE 6.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 46
       10 FILLER PIC X(24) VALUE "asset_id".
       10 FILLER BINARY-LONG VALUE 8.               *> name length
       10 FILLER BINARY-LONG VALUE 1.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 47
       10 FILLER PIC X(24) VALUE "width".
       10 FILLER BINARY-LONG VALUE 5.               *> name length
       10 FILLER BINARY-LONG VALUE 4.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 1.               *> int value
    05 FILLER.                                      *> field 48
       10 FILLER PIC X(24) VALUE "height".
       10 FILLER BINARY-LONG VALUE 6.               *> name length
       10 FILLER BINARY-LONG VALUE 4.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> string length
       10 FILLER BINARY-LONG VALUE 1.               *> int value
    05 FILLER.                                      *> field 49
       10 FILLER PIC X(24) VALUE "asset_id".
       10 FILLER BINARY-LONG VALUE 8.               *> name length
       10 FILLER BINARY-LONG VALUE 3.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE "cobolcraft:placeholder".
       10 FILLER BINARY-LONG VALUE 22.              *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
    05 FILLER.                                      *> field 50
       10 FILLER PIC X(24) VALUE "title".
       10 FILLER BINARY-LONG VALUE 5.               *> name length
       10 FILLER BINARY-LONG VALUE 3.               *> kind (RMF-*)
       10 FILLER PIC X(24) VALUE "Placeholder".
       10 FILLER BINARY-LONG VALUE 11.              *> string length
       10 FILLER BINARY-LONG VALUE 0.               *> int value
 01 REG-MV-FIELD-TABLE REDEFINES REG-MV-FIELD-DATA.
    05 RF-ENTRY OCCURS 50 TIMES.
       10 RF-NAME               PIC X(24).
       10 RF-NAME-LENGTH        BINARY-LONG.
       10 RF-KIND               BINARY-LONG.
       10 RF-STRING             PIC X(24).
       10 RF-STRING-LENGTH      BINARY-LONG.
       10 RF-INT                BINARY-LONG.

*> dimension_type (§4.6), row = dimension type id + 1, fields in the field-table row order.
*> has_fixed_time -1 = absent; skybox / default_clock length 0 = absent. infiniburn is the empty List
*> in both entries (§4.6) and has no column; cardinal_light, attributes and timelines are absent.
 78 RD-COUNT                  VALUE 2.
 01 REG-DIMTYPE-DATA.
    05 FILLER.                                      *> dimension type 0
       10 FILLER PIC X(32) VALUE "cobolcraft:surface".
       10 FILLER BINARY-LONG VALUE 18.              *> key length
       10 FILLER BINARY-LONG VALUE -1.              *> has_fixed_time (-1 absent)
       10 FILLER BINARY-LONG VALUE 1.               *> has_skylight
       10 FILLER BINARY-LONG VALUE 0.               *> has_ceiling
       10 FILLER BINARY-LONG VALUE 0.               *> has_ender_dragon_fight
       10 FILLER BINARY-LONG VALUE 1000.            *> coordinate_scale/1000
       10 FILLER BINARY-LONG VALUE 0.               *> min_y
       10 FILLER BINARY-LONG VALUE 256.             *> height
       10 FILLER BINARY-LONG VALUE 256.             *> logical_height
       10 FILLER BINARY-LONG VALUE 0.               *> ambient_light/1000
       10 FILLER BINARY-LONG VALUE 0.               *> monster_spawn_light_level
       10 FILLER BINARY-LONG VALUE 0.               *> monster_spawn_block_light_limit
       10 FILLER PIC X(16) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> skybox length (0 absent)
       10 FILLER PIC X(32) VALUE "cobolcraft:daylight".
       10 FILLER BINARY-LONG VALUE 19.              *> default_clock length (0 absent)
    05 FILLER.                                      *> dimension type 1
       10 FILLER PIC X(32) VALUE "cobolcraft:sunless".
       10 FILLER BINARY-LONG VALUE 18.              *> key length
       10 FILLER BINARY-LONG VALUE 1.               *> has_fixed_time (-1 absent)
       10 FILLER BINARY-LONG VALUE 0.               *> has_skylight
       10 FILLER BINARY-LONG VALUE 0.               *> has_ceiling
       10 FILLER BINARY-LONG VALUE 0.               *> has_ender_dragon_fight
       10 FILLER BINARY-LONG VALUE 1000.            *> coordinate_scale/1000
       10 FILLER BINARY-LONG VALUE 0.               *> min_y
       10 FILLER BINARY-LONG VALUE 128.             *> height
       10 FILLER BINARY-LONG VALUE 128.             *> logical_height
       10 FILLER BINARY-LONG VALUE 0.               *> ambient_light/1000
       10 FILLER BINARY-LONG VALUE 0.               *> monster_spawn_light_level
       10 FILLER BINARY-LONG VALUE 0.               *> monster_spawn_block_light_limit
       10 FILLER PIC X(16) VALUE "none".
       10 FILLER BINARY-LONG VALUE 4.               *> skybox length (0 absent)
       10 FILLER PIC X(32) VALUE SPACES.
       10 FILLER BINARY-LONG VALUE 0.               *> default_clock length (0 absent)
 01 REG-DIMTYPE-TABLE REDEFINES REG-DIMTYPE-DATA.
    05 RD-ENTRY OCCURS 2 TIMES.
       10 RD-KEY                PIC X(32).
       10 RD-KEY-LENGTH         BINARY-LONG.
       10 RD-FIXED-TIME         BINARY-LONG.
       10 RD-SKYLIGHT           BINARY-LONG.
       10 RD-CEILING            BINARY-LONG.
       10 RD-DRAGON-FIGHT       BINARY-LONG.
       10 RD-COORD-SCALE-MILLI  BINARY-LONG.
       10 RD-MIN-Y              BINARY-LONG.
       10 RD-HEIGHT             BINARY-LONG.
       10 RD-LOGICAL-HEIGHT     BINARY-LONG.
       10 RD-AMBIENT-MILLI      BINARY-LONG.
       10 RD-SPAWN-LIGHT        BINARY-LONG.
       10 RD-SPAWN-BLOCK-LIMIT  BINARY-LONG.
       10 RD-SKYBOX             PIC X(16).
       10 RD-SKYBOX-LENGTH      BINARY-LONG.
       10 RD-CLOCK              PIC X(32).
       10 RD-CLOCK-LENGTH       BINARY-LONG.

*> damage_type (§4.7), row = damage type id + 1: key, message_id, scaling, exhaustion (thousandths);
*> effects and death_message_type absent. Ids 3 to 27 are the 25 compat keys in the listed order.
 78 RX-COUNT                  VALUE 32.
 01 REG-DAMAGE-DATA.
    05 FILLER.                                      *> damage type 0
       10 FILLER PIC X(32) VALUE "cobolcraft:generic".
       10 FILLER BINARY-LONG VALUE 18.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.generic".
       10 FILLER BINARY-LONG VALUE 18.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 1
       10 FILLER PIC X(32) VALUE "cobolcraft:impact".
       10 FILLER BINARY-LONG VALUE 17.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.impact".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 2
       10 FILLER PIC X(32) VALUE "cobolcraft:below_world".
       10 FILLER BINARY-LONG VALUE 22.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.below_world".
       10 FILLER BINARY-LONG VALUE 22.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 3
       10 FILLER PIC X(32) VALUE "minecraft:in_fire".
       10 FILLER BINARY-LONG VALUE 17.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 4
       10 FILLER PIC X(32) VALUE "minecraft:campfire".
       10 FILLER BINARY-LONG VALUE 18.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 5
       10 FILLER PIC X(32) VALUE "minecraft:lightning_bolt".
       10 FILLER BINARY-LONG VALUE 24.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 6
       10 FILLER PIC X(32) VALUE "minecraft:on_fire".
       10 FILLER BINARY-LONG VALUE 17.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 7
       10 FILLER PIC X(32) VALUE "minecraft:lava".
       10 FILLER BINARY-LONG VALUE 14.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 8
       10 FILLER PIC X(32) VALUE "minecraft:hot_floor".
       10 FILLER BINARY-LONG VALUE 19.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 9
       10 FILLER PIC X(32) VALUE "minecraft:in_wall".
       10 FILLER BINARY-LONG VALUE 17.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 10
       10 FILLER PIC X(32) VALUE "minecraft:cramming".
       10 FILLER BINARY-LONG VALUE 18.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 11
       10 FILLER PIC X(32) VALUE "minecraft:drown".
       10 FILLER BINARY-LONG VALUE 15.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 12
       10 FILLER PIC X(32) VALUE "minecraft:starve".
       10 FILLER BINARY-LONG VALUE 16.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 13
       10 FILLER PIC X(32) VALUE "minecraft:cactus".
       10 FILLER BINARY-LONG VALUE 16.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 14
       10 FILLER PIC X(32) VALUE "minecraft:fall".
       10 FILLER BINARY-LONG VALUE 14.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 15
       10 FILLER PIC X(32) VALUE "minecraft:ender_pearl".
       10 FILLER BINARY-LONG VALUE 21.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 16
       10 FILLER PIC X(32) VALUE "minecraft:fly_into_wall".
       10 FILLER BINARY-LONG VALUE 23.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 17
       10 FILLER PIC X(32) VALUE "minecraft:fell_out_of_world".
       10 FILLER BINARY-LONG VALUE 27.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 18
       10 FILLER PIC X(32) VALUE "minecraft:generic".
       10 FILLER BINARY-LONG VALUE 17.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 19
       10 FILLER PIC X(32) VALUE "minecraft:magic".
       10 FILLER BINARY-LONG VALUE 15.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 20
       10 FILLER PIC X(32) VALUE "minecraft:wither".
       10 FILLER BINARY-LONG VALUE 16.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 21
       10 FILLER PIC X(32) VALUE "minecraft:dragon_breath".
       10 FILLER BINARY-LONG VALUE 23.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 22
       10 FILLER PIC X(32) VALUE "minecraft:dry_out".
       10 FILLER BINARY-LONG VALUE 17.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 23
       10 FILLER PIC X(32) VALUE "minecraft:sweet_berry_bush".
       10 FILLER BINARY-LONG VALUE 26.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 24
       10 FILLER PIC X(32) VALUE "minecraft:freeze".
       10 FILLER BINARY-LONG VALUE 16.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 25
       10 FILLER PIC X(32) VALUE "minecraft:stalagmite".
       10 FILLER BINARY-LONG VALUE 20.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 26
       10 FILLER PIC X(32) VALUE "minecraft:outside_border".
       10 FILLER BINARY-LONG VALUE 24.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 27
       10 FILLER PIC X(32) VALUE "minecraft:generic_kill".
       10 FILLER BINARY-LONG VALUE 22.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.compat".
       10 FILLER BINARY-LONG VALUE 17.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 28
       10 FILLER PIC X(32) VALUE "cobolcraft:mob_attack".
       10 FILLER BINARY-LONG VALUE 21.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.mob_attack".
       10 FILLER BINARY-LONG VALUE 21.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 29
       10 FILLER PIC X(32) VALUE "cobolcraft:player_attack".
       10 FILLER BINARY-LONG VALUE 24.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.player_attack".
       10 FILLER BINARY-LONG VALUE 24.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 30
       10 FILLER PIC X(32) VALUE "cobolcraft:starvation".
       10 FILLER BINARY-LONG VALUE 21.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.starvation".
       10 FILLER BINARY-LONG VALUE 21.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
    05 FILLER.                                      *> damage type 31
       10 FILLER PIC X(32) VALUE "cobolcraft:hail".
       10 FILLER BINARY-LONG VALUE 15.              *> key length
       10 FILLER PIC X(32) VALUE "cobolcraft.hail".
       10 FILLER BINARY-LONG VALUE 15.              *> message_id length
       10 FILLER PIC X(8) VALUE "never".
       10 FILLER BINARY-LONG VALUE 5.               *> scaling length
       10 FILLER BINARY-LONG VALUE 0.               *> exhaustion/1000
 01 REG-DAMAGE-TABLE REDEFINES REG-DAMAGE-DATA.
    05 RX-ENTRY OCCURS 32 TIMES.
       10 RX-KEY                PIC X(32).
       10 RX-KEY-LENGTH         BINARY-LONG.
       10 RX-MESSAGE            PIC X(32).
       10 RX-MESSAGE-LENGTH     BINARY-LONG.
       10 RX-SCALING            PIC X(8).
       10 RX-SCALING-LENGTH     BINARY-LONG.
       10 RX-EXHAUSTION-MILLI   BINARY-LONG.

*> world_clock (§4.8): one entry, data the empty Compound.
 78 RW-COUNT                  VALUE 1.
 01 REG-CLOCK-DATA.
    05 FILLER.                                      *> world clock 0
       10 FILLER PIC X(32) VALUE "cobolcraft:daylight".
       10 FILLER BINARY-LONG VALUE 19.              *> key length
 01 REG-CLOCK-TABLE REDEFINES REG-CLOCK-DATA.
    05 RW-ENTRY OCCURS 1 TIMES.
       10 RW-KEY                PIC X(32).
       10 RW-KEY-LENGTH         BINARY-LONG.
