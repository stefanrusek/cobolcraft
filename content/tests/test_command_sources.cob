*> Test of the registry sources the commands name (T0280; docs/protocol/16-commands-catalog.md section 13 and the argument
*> types of 15-commands-framework.md 6.7: item, block, entity_type, mob_effect, enchantment, attribute, biome, structure,
*> particle_type, game_rule, point_of_interest_type, world_clock, timeline, dialog, feature, template_pool, sound_event).
*> CONTENT-REGISTRY-COUNT USING registry (PIC X(64)), count out, status; CONTENT-REGISTRY-ENTRY USING registry, id,
*> key out (PIC X(64)), key length out, payload area, capacity, payload length out, status: every one of these registries
*> enumerates in id order, for the standard set (opened over content/tests/fixtures/std, copied to
*> build/content-test/cmdsrc) and for the cobolcraft set. Counts and keys are those of 46 (static registries), 24/25/21
*> (block, item, entity type), 16 section 13 (game rules) and cobolcraft-standard-core.md sections 2 and 3 (the
*> synchronized registries of the cobolcraft set); an id outside 0 to count - 1 and an unknown registry are
*> CT-NOT-FOUND; static entries have no payload (length 0).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COMMAND-SOURCES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 01 WS-DIR                 PIC X(1100).
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-REGISTRY            PIC X(64).
 01 WS-STATIC-REGISTRY     PIC X(48).
 01 WS-COUNT               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-BACK-ID             BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-PAYLOAD             PIC X(2000).
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-WANT-COUNT          BINARY-LONG.
 01 WS-FIRST               PIC X(64).
 01 WS-LAST                PIC X(64).
 01 WS-BAD                 BINARY-LONG.
 01 WS-PAYLOADS            BINARY-LONG VALUE 0.
 01 WS-LABEL               PIC X(60).
 01 WS-NAMES.
    05 FILLER              PIC X(40) VALUE "mob_effect".
    05 FILLER              PIC X(40) VALUE "attribute".
    05 FILLER              PIC X(40) VALUE "potion".
    05 FILLER              PIC X(40) VALUE "particle_type".
    05 FILLER              PIC X(40) VALUE "game_event".
    05 FILLER              PIC X(40) VALUE "fluid".
    05 FILLER              PIC X(40) VALUE "block_entity_type".
    05 FILLER              PIC X(40) VALUE "menu".
    05 FILLER              PIC X(40) VALUE "map_decoration_type".
    05 FILLER              PIC X(40) VALUE "villager_type".
    05 FILLER              PIC X(40) VALUE "villager_profession".
    05 FILLER              PIC X(40) VALUE "point_of_interest_type".
    05 FILLER              PIC X(40) VALUE "custom_stat".
    05 FILLER              PIC X(40) VALUE "data_component_type".
    05 FILLER              PIC X(40) VALUE "consume_effect_type".
    05 FILLER              PIC X(40) VALUE "number_format_type".
    05 FILLER              PIC X(40) VALUE "data_component_predicate_type".
    05 FILLER              PIC X(40) VALUE "recipe_display".
    05 FILLER              PIC X(40) VALUE "slot_display".
    05 FILLER              PIC X(40) VALUE "recipe_book_category".
    05 FILLER              PIC X(40) VALUE "recipe_type".
    05 FILLER              PIC X(40) VALUE "recipe_serializer".
    05 FILLER              PIC X(40) VALUE "command_argument_type".
    05 FILLER              PIC X(40) VALUE "enchantment_effect_component_type".
    05 FILLER              PIC X(40) VALUE "debug_subscription".
    05 FILLER              PIC X(40) VALUE "position_source_type".
    05 FILLER              PIC X(40) VALUE "sound_event".
    05 FILLER              PIC X(40) VALUE "stat_type".
    05 FILLER              PIC X(40) VALUE "block".
    05 FILLER              PIC X(40) VALUE "item".
    05 FILLER              PIC X(40) VALUE "entity_type".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(40) OCCURS 31 TIMES.
 01 WS-N                   BINARY-LONG.
 PROCEDURE DIVISION.
*>   No set open: both entry points answer CT-NOT-OPEN for a source registry.
     MOVE 0 TO CT-OPEN
     MOVE "item" TO WS-REGISTRY
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
     MOVE "sources: no set open, item count" TO TL-CASE
     MOVE CT-NOT-OPEN TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE 0 TO WS-ID
     MOVE 0 TO WS-CAPACITY
     CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY WS-ID WS-KEY WS-KEY-LENGTH WS-PAYLOAD WS-CAPACITY
         WS-LENGTH WS-STATUS
     MOVE "sources: no set open, item entry" TO TL-CASE
     PERFORM ASSERT-STATUS

*>   The standard set.
     CALL "SYSTEM" USING "chmod -R u+rwx build/content-test/cmdsrc 2>/dev/null; rm -rf build/content-test/cmdsrc; mkdir -p build/content-test/cmdsrc && cp -R content/tests/fixtures/std build/content-test/cmdsrc/std"
     MOVE SPACES TO WS-DIR
     MOVE "build/content-test/cmdsrc/std" TO WS-DIR
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "sources: the standard set opens" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS

     MOVE "block" TO WS-REGISTRY
     MOVE 1286 TO WS-WANT-COUNT
     MOVE "minecraft:air" TO WS-FIRST
     MOVE "minecraft:firefly_bush" TO WS-LAST
     PERFORM CHECK-REGISTRY
     MOVE "item" TO WS-REGISTRY
     MOVE 1658 TO WS-WANT-COUNT
     MOVE "minecraft:air" TO WS-FIRST
     MOVE SPACES TO WS-LAST
     PERFORM CHECK-REGISTRY
     MOVE "entity_type" TO WS-REGISTRY
     MOVE 161 TO WS-WANT-COUNT
     MOVE "minecraft:acacia_boat" TO WS-FIRST
     MOVE SPACES TO WS-LAST
     PERFORM CHECK-REGISTRY
     MOVE "mob_effect" TO WS-REGISTRY
     MOVE 40 TO WS-WANT-COUNT
     MOVE "minecraft:speed" TO WS-FIRST
     MOVE "minecraft:breath_of_the_nautilus" TO WS-LAST
     PERFORM CHECK-REGISTRY
     MOVE "minecraft:mob_effect" TO WS-REGISTRY
     PERFORM CHECK-REGISTRY
     MOVE "attribute" TO WS-REGISTRY
     MOVE 40 TO WS-WANT-COUNT
     MOVE "minecraft:air_drag_modifier" TO WS-FIRST
     MOVE "minecraft:waypoint_receive_range" TO WS-LAST
     PERFORM CHECK-REGISTRY
     MOVE "particle_type" TO WS-REGISTRY
     MOVE 128 TO WS-WANT-COUNT
     MOVE "minecraft:angry_villager" TO WS-FIRST
     MOVE "minecraft:sulfur_cube_goo" TO WS-LAST
     PERFORM CHECK-REGISTRY
     MOVE "sound_event" TO WS-REGISTRY
     MOVE 1991 TO WS-WANT-COUNT
     MOVE "minecraft:entity.allay.ambient_with_item" TO WS-FIRST
     MOVE "minecraft:block.red_shrub.place" TO WS-LAST
     PERFORM CHECK-REGISTRY
     MOVE "point_of_interest_type" TO WS-REGISTRY
     MOVE 21 TO WS-WANT-COUNT
     MOVE "minecraft:armorer" TO WS-FIRST
     MOVE "minecraft:lightning_rod" TO WS-LAST
     PERFORM CHECK-REGISTRY
     MOVE "command_argument_type" TO WS-REGISTRY
     MOVE 62 TO WS-WANT-COUNT
     MOVE "brigadier:bool" TO WS-FIRST
     MOVE "minecraft:uuid" TO WS-LAST
     PERFORM CHECK-REGISTRY
*>   Game rules: 16 section 13, 59 rules in the order of the table.
     MOVE "game_rule" TO WS-REGISTRY
     MOVE 59 TO WS-WANT-COUNT
     MOVE "minecraft:advance_time" TO WS-FIRST
     MOVE "minecraft:water_source_conversion" TO WS-LAST
     PERFORM CHECK-REGISTRY
     MOVE 4 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "sources: game rule 4 is block_explosion_drop_decay" TO TL-CASE
     MOVE "minecraft:block_explosion_drop_decay" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
*>   World registries of the fixture tree: ids in the sorted order of the element id (path first, then namespace).
     MOVE 1 TO WS-PAYLOADS
     MOVE "worldgen/biome" TO WS-REGISTRY
     MOVE 5 TO WS-WANT-COUNT
     MOVE "minecraft:a/b" TO WS-FIRST
     MOVE "minecraft:plains" TO WS-LAST
     PERFORM CHECK-REGISTRY
     MOVE 2 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "sources: biome 2 is mymod:beach" TO TL-CASE
     MOVE "mymod:beach" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "damage_type" TO WS-REGISTRY
     MOVE 1 TO WS-WANT-COUNT
     MOVE "minecraft:generic" TO WS-FIRST
     MOVE "minecraft:generic" TO WS-LAST
     PERFORM CHECK-REGISTRY
     MOVE 0 TO WS-PAYLOADS
     MOVE 0 TO WS-WANT-COUNT
     PERFORM CHECK-EMPTY-REGISTRIES
*>   The walk: every static key answers its own id (CONTENT-STATIC-ID).
     PERFORM CHECK-ROUND-TRIPS
*>   An unknown registry, another namespace and an id outside.
     PERFORM CHECK-UNKNOWN
     CALL "CONTENT-CLOSE"

*>   The cobolcraft set.
     MOVE SPACES TO WS-DIR
     MOVE CT-TYPE-COBOLCRAFT TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE "sources: the cobolcraft set opens" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "block" TO WS-REGISTRY
     MOVE 13 TO WS-WANT-COUNT
     MOVE "cobolcraft:void" TO WS-FIRST
     MOVE "cobolcraft:crafting_bench" TO WS-LAST
     PERFORM CHECK-REGISTRY
     MOVE "item" TO WS-REGISTRY
     MOVE 19 TO WS-WANT-COUNT
     MOVE "cobolcraft:nothing" TO WS-FIRST
     MOVE "cobolcraft:crafting_bench" TO WS-LAST
     PERFORM CHECK-REGISTRY
     MOVE "entity_type" TO WS-REGISTRY
     MOVE 4 TO WS-WANT-COUNT
     MOVE "cobolcraft:operator" TO WS-FIRST
     MOVE "cobolcraft:abend" TO WS-LAST
     PERFORM CHECK-REGISTRY
*>   The other static registries keep the vanilla numbering (world-types WT-9).
     MOVE "mob_effect" TO WS-REGISTRY
     MOVE 40 TO WS-WANT-COUNT
     MOVE "minecraft:speed" TO WS-FIRST
     MOVE "minecraft:breath_of_the_nautilus" TO WS-LAST
     PERFORM CHECK-REGISTRY
     MOVE "particle_type" TO WS-REGISTRY
     MOVE 128 TO WS-WANT-COUNT
     MOVE "minecraft:angry_villager" TO WS-FIRST
     MOVE "minecraft:sulfur_cube_goo" TO WS-LAST
     PERFORM CHECK-REGISTRY
     MOVE "game_rule" TO WS-REGISTRY
     MOVE 59 TO WS-WANT-COUNT
     MOVE "minecraft:advance_time" TO WS-FIRST
     MOVE "minecraft:water_source_conversion" TO WS-LAST
     PERFORM CHECK-REGISTRY
*>   Synchronized registries of the cobolcraft set (core section 2 and 3): keys in id order.
     MOVE "worldgen/biome" TO WS-REGISTRY
     MOVE 3 TO WS-WANT-COUNT
     MOVE "minecraft:plains" TO WS-FIRST
     MOVE "cobolcraft:ash_flats" TO WS-LAST
     PERFORM CHECK-REGISTRY
     MOVE 1 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "sources: cobolcraft biome 1 is upland" TO TL-CASE
     MOVE "cobolcraft:upland" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "enchantment" TO WS-REGISTRY
     MOVE 1 TO WS-WANT-COUNT
     MOVE "minecraft:efficiency" TO WS-FIRST
     MOVE "minecraft:efficiency" TO WS-LAST
     PERFORM CHECK-REGISTRY
     MOVE "damage_type" TO WS-REGISTRY
     MOVE 52 TO WS-WANT-COUNT
     MOVE "minecraft:arrow" TO WS-FIRST
     MOVE "minecraft:wither_skull" TO WS-LAST
     PERFORM CHECK-REGISTRY
     MOVE 20 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "sources: cobolcraft damage type 20 is hail" TO TL-CASE
     MOVE "cobolcraft:hail" TO TL-EXPECTED
     MOVE WS-KEY TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "world_clock" TO WS-REGISTRY
     MOVE 1 TO WS-WANT-COUNT
     MOVE "minecraft:overworld" TO WS-FIRST
     MOVE "minecraft:overworld" TO WS-LAST
     PERFORM CHECK-REGISTRY
     MOVE "timeline" TO WS-REGISTRY
     MOVE 2 TO WS-WANT-COUNT
     MOVE "minecraft:day" TO WS-FIRST
     MOVE "minecraft:moon" TO WS-LAST
     PERFORM CHECK-REGISTRY
     MOVE "dimension_type" TO WS-REGISTRY
     MOVE 2 TO WS-WANT-COUNT
     MOVE "cobolcraft:surface" TO WS-FIRST
     MOVE "cobolcraft:sunless" TO WS-LAST
     PERFORM CHECK-REGISTRY
     MOVE "chat_type" TO WS-REGISTRY
     MOVE 8 TO WS-WANT-COUNT
     MOVE "minecraft:chat" TO WS-FIRST
     MOVE "minecraft:team_msg_command_outgoing" TO WS-LAST
     PERFORM CHECK-REGISTRY
     MOVE "wolf_variant" TO WS-REGISTRY
     MOVE 1 TO WS-WANT-COUNT
     MOVE "cobolcraft:placeholder" TO WS-FIRST
     MOVE "cobolcraft:placeholder" TO WS-LAST
     PERFORM CHECK-REGISTRY
     MOVE 0 TO WS-WANT-COUNT
     PERFORM CHECK-EMPTY-REGISTRIES
     PERFORM CHECK-ROUND-TRIPS
     PERFORM CHECK-UNKNOWN
     CALL "CONTENT-CLOSE"
     STOP RUN.

*> CHECK-REGISTRY: WS-REGISTRY, WS-WANT-COUNT, WS-FIRST, WS-LAST (spaces: not checked). The count, every id from 0
*> to count - 1 with a key (namespace, length, no payload), the first and last key, and the ids count and -1 as
*> CT-NOT-FOUND.
 CHECK-REGISTRY.
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
     MOVE SPACES TO WS-LABEL
     STRING "sources: " FUNCTION TRIM(WS-REGISTRY) " status" DELIMITED BY SIZE INTO WS-LABEL
     MOVE WS-LABEL TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE SPACES TO WS-LABEL
     STRING "sources: " FUNCTION TRIM(WS-REGISTRY) " count" DELIMITED BY SIZE INTO WS-LABEL
     MOVE WS-LABEL TO TL-CASE
     MOVE WS-WANT-COUNT TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-ID FROM 0 BY 1 UNTIL WS-ID >= WS-COUNT
         PERFORM ENTRY-OF
         IF WS-STATUS NOT = CT-OK OR WS-KEY = SPACES OR (WS-LENGTH NOT = 0 AND WS-PAYLOADS = 0)
             ADD 1 TO WS-BAD
         END-IF
         MOVE 0 TO WS-N
         INSPECT WS-KEY TALLYING WS-N FOR CHARACTERS BEFORE INITIAL SPACE
         IF WS-N NOT = WS-KEY-LENGTH
             ADD 1 TO WS-BAD
         END-IF
         IF WS-ID = 0 AND WS-FIRST NOT = SPACES AND WS-KEY NOT = WS-FIRST
             ADD 1 TO WS-BAD
         END-IF
         IF WS-ID = WS-COUNT - 1 AND WS-LAST NOT = SPACES AND WS-KEY NOT = WS-LAST
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE SPACES TO WS-LABEL
     STRING "sources: " FUNCTION TRIM(WS-REGISTRY) " entries in id order" DELIMITED BY SIZE INTO WS-LABEL
     MOVE WS-LABEL TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-COUNT TO WS-ID
     PERFORM ENTRY-OF
     MOVE SPACES TO WS-LABEL
     STRING "sources: " FUNCTION TRIM(WS-REGISTRY) " id count outside" DELIMITED BY SIZE INTO WS-LABEL
     MOVE WS-LABEL TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE -1 TO WS-ID
     PERFORM ENTRY-OF
     MOVE SPACES TO WS-LABEL
     STRING "sources: " FUNCTION TRIM(WS-REGISTRY) " id -1 outside" DELIMITED BY SIZE INTO WS-LABEL
     MOVE WS-LABEL TO TL-CASE
     PERFORM ASSERT-STATUS.

 ENTRY-OF.
     MOVE 2000 TO WS-CAPACITY
     MOVE SPACES TO WS-KEY
     CALL "CONTENT-REGISTRY-ENTRY" USING WS-REGISTRY WS-ID WS-KEY WS-KEY-LENGTH WS-PAYLOAD WS-CAPACITY
         WS-LENGTH WS-STATUS.

*> CHECK-EMPTY-REGISTRIES: the world registries the commands name that the set leaves empty (structure,
*> worldgen/feature, worldgen/template_pool, dialog) answer count WS-WANT-COUNT with CT-OK.
 CHECK-EMPTY-REGISTRIES.
     MOVE "worldgen/structure" TO WS-REGISTRY
     MOVE SPACES TO WS-FIRST WS-LAST
     PERFORM CHECK-REGISTRY
     MOVE "worldgen/feature" TO WS-REGISTRY
     PERFORM CHECK-REGISTRY
     MOVE "worldgen/template_pool" TO WS-REGISTRY
     PERFORM CHECK-REGISTRY
     MOVE "dialog" TO WS-REGISTRY
     PERFORM CHECK-REGISTRY.

*> CHECK-ROUND-TRIPS: for every source registry named in WS-NAMES, each id's key is found again with CONTENT-STATIC-ID
*> and gives the same id.
 CHECK-ROUND-TRIPS.
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 31
         MOVE WS-NAME(WS-N) TO WS-REGISTRY
         MOVE WS-NAME(WS-N) TO WS-STATIC-REGISTRY
         CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
         MOVE 0 TO WS-BAD
         IF WS-STATUS NOT = CT-OK OR WS-COUNT < 1
             ADD 1 TO WS-BAD
         END-IF
         PERFORM VARYING WS-ID FROM 0 BY 1 UNTIL WS-ID >= WS-COUNT
             PERFORM ENTRY-OF
             CALL "CONTENT-STATIC-ID" USING WS-STATIC-REGISTRY WS-KEY WS-BACK-ID WS-STATUS
             IF WS-STATUS NOT = CT-OK OR WS-BACK-ID NOT = WS-ID
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
         MOVE SPACES TO WS-LABEL
         STRING "sources: " FUNCTION TRIM(WS-REGISTRY) " ids round trip" DELIMITED BY SIZE INTO WS-LABEL
         MOVE WS-LABEL TO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         MOVE WS-BAD TO TL-OBSERVED-N
         MOVE "N" TO TL-MODE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM.

 CHECK-UNKNOWN.
     MOVE "no_such_registry" TO WS-REGISTRY
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
     MOVE "sources: an unknown registry is not found" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "sources: an unknown registry has count 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-ID
     PERFORM ENTRY-OF
     MOVE "sources: an entry of an unknown registry is not found" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS
     MOVE "othermod:item" TO WS-REGISTRY
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
     MOVE "sources: a registry of another namespace is not found" TO TL-CASE
     PERFORM ASSERT-STATUS
     MOVE "minecraft:item" TO WS-REGISTRY
     CALL "CONTENT-REGISTRY-COUNT" USING WS-REGISTRY WS-COUNT WS-STATUS
     MOVE "sources: the namespace of the registry is optional" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     PERFORM ASSERT-STATUS.

 ASSERT-STATUS.
     MOVE WS-STATUS TO TL-OBSERVED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
