*> The loot loaders (T0289; docs/protocol/26-loot-and-predicates.md sections 1, 2, 3.2, 6 to 9 and 13.1).
*> LOOT-LOAD USING root (PIC X(1100): the folder that holds data/), status out (CT-OK, CT-BAD-DATA; every error is on standard
*> error as "ERROR registry: ..." and nothing of the load stays). The files of data/<namespace>/loot_table (the table, section 2.1;
*> pool 2.2; entry 2.3), predicate (a condition), item_modifier (a function), slot_source, context_int_provider and
*> context_float_provider (section 1) are read by the shape engine (shapes.cob, CTSHAPE.cpy) and kept as elements of its store;
*> each is checked against the member list of its document. The shape groups (group names are global to the engine):
*>   loot_table, loot_pool, loot_entry (9 types, section 6), loot_slot (6 slot sources, 6.2), loot_fn (42 functions, section 7),
*>   loot_cond (20 conditions, section 8), loot_level (the 6 level based values, 8.1), loot_int (23 int providers, 9.2),
*>   loot_float (28 float providers, 9.3), loot_score (9.4), loot_nbt (9.5), and the plain objects loot_limit (IntLimit),
*>   loot_op (copy_custom_data op), loot_attr (set_attributes modifier), loot_stew (set_stew_effect effect), loot_wint and
*>   loot_wflt (weighted list entry {data, weight}, 23 section 7.5), loot_cint and loot_cflt (number_dispatcher case).
*> Every group that section 6 to 9 enumerates is closed (type row "!"): an unknown type is an error also when nested. The forms
*> P (number, identifier or object), F (object, identifier or array of those) and M (array of P) of CTSHAPE.cpy carry the
*> provider fields (a bare number, an id of the data registry, or an object: 9.1) and the condition and function lists (a list
*> is a sequence, a string names an entry of the registry: section 1). The type of a loot table is one of the 31 parameter sets
*> of 3.2 (LOOT-TABLE-TYPES-CHECK).
*> Documented assumptions: L1 (replaced by 48 2.7) a provider file of context_int_provider and context_float_provider is an object with a type or
*> a bare number (a row "~" of the group: an integer file, a decimal file); L2 members that a section names without saying whether they are optional
*> are optional, except those whose absence leaves the type without meaning (count of set_count, name of an item entry, rolls of
*> a pool, and so on: the capital letters of the rows); L3 the members whose value the sections leave to other documents are
*> accepted as any value or any object (item, entity, block, location and damage source predicates 10, text components,
*> component patches, NBT, list operation members, slot ranges, structure and block entity target names), the list operation
*> mode of 7.5 is a string; L4 the validation problems of 6.1 and 13.1 (Empty children list, Unreachable entry!, parameters
*> not provided, recursive references, unresolved holders) are not load errors here, because 23 section 10 V18 and 26 Open
*> question 5 do not say which are fatal; L5 (replaced: a shape member name may be 64 bytes) the member include_additional_cost_component
*> (33 bytes) is checked; L6 enum members over 40 bytes (list operation mode, container
*> component) are strings; L7 a slot source field, a function field and a condition list also accept an identifier (a registry
*> entry) as sections 1 and 6.2 say for the fields of that kind.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-TABLE-TYPES-CHECK.
*> No parameters: checks the type member of the elements of the registry loot_table stored since SHAPE-BEGIN (the shapes have
*> already vouched for their form): one of the 31 parameter sets of 26 section 3.2, with or without "minecraft:". A table with
*> no type is the generic set (2.1). Errors are counted for SHAPE-END.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTSHAPE.
 COPY CTWORLDGEN.
 COPY JSONDOC.
 01 WS-SETS.
    05 FILLER PIC X(24) VALUE "empty".
    05 FILLER PIC X(24) VALUE "generic".
    05 FILLER PIC X(24) VALUE "chest".
    05 FILLER PIC X(24) VALUE "command".
    05 FILLER PIC X(24) VALUE "command_slot_source".
    05 FILLER PIC X(24) VALUE "command_compute_default".
    05 FILLER PIC X(24) VALUE "command_compute_position".
    05 FILLER PIC X(24) VALUE "command_compute_entity".
    05 FILLER PIC X(24) VALUE "selector".
    05 FILLER PIC X(24) VALUE "villager_trade".
    05 FILLER PIC X(24) VALUE "fishing".
    05 FILLER PIC X(24) VALUE "entity".
    05 FILLER PIC X(24) VALUE "equipment".
    05 FILLER PIC X(24) VALUE "archaeology".
    05 FILLER PIC X(24) VALUE "gift".
    05 FILLER PIC X(24) VALUE "barter".
    05 FILLER PIC X(24) VALUE "vault".
    05 FILLER PIC X(24) VALUE "advancement_reward".
    05 FILLER PIC X(24) VALUE "advancement_entity".
    05 FILLER PIC X(24) VALUE "advancement_location".
    05 FILLER PIC X(24) VALUE "block_use".
    05 FILLER PIC X(24) VALUE "block".
    05 FILLER PIC X(24) VALUE "shearing".
    05 FILLER PIC X(24) VALUE "entity_interact".
    05 FILLER PIC X(24) VALUE "block_interact".
    05 FILLER PIC X(24) VALUE "container_process".
    05 FILLER PIC X(24) VALUE "enchanted_damage".
    05 FILLER PIC X(24) VALUE "enchanted_item".
    05 FILLER PIC X(24) VALUE "enchanted_location".
    05 FILLER PIC X(24) VALUE "enchanted_entity".
    05 FILLER PIC X(24) VALUE "hit_block".
 01 WS-SET-TABLE REDEFINES WS-SETS.
    05 WS-SET              PIC X(24) OCCURS 31 TIMES.
 01 WS-TYPE-NAME           PIC X(32) VALUE "type".
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(200).
 01 WS-SHORT               PIC X(200).
 01 WS-KEY                 PIC X(112).
 01 WS-DETAIL              PIC X(120).
 01 B-TEXT                 PIC X(268435456) BASED.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > SH-ELEMENT-COUNT
         IF WS-E > SH-MARK AND SH-E-REGISTRY(WS-E) = "loot_table"
             SET ADDRESS OF B-TEXT TO SH-E-ADDR(WS-E)
             MOVE SH-E-LENGTH(WS-E) TO WS-LENGTH
             MOVE SH-E-KEY(WS-E) TO WS-KEY
             MOVE SPACES TO WG-LABEL
             MOVE "loot_table" TO WG-LABEL
             CALL "JSON-PARSE" USING JSON-DOC B-TEXT WS-LENGTH
             CALL "RECIPE-GET-TEXT" USING JSON-DOC WS-ROOT WS-TYPE-NAME WS-TEXT WS-FOUND
             IF WS-FOUND = 1
                 MOVE WS-TEXT TO WS-SHORT
                 IF WS-TEXT(1:10) = "minecraft:"
                     MOVE SPACES TO WS-SHORT
                     MOVE WS-TEXT(11:) TO WS-SHORT
                 END-IF
                 MOVE 0 TO WS-OK
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 31
                     IF WS-SHORT = WS-SET(WS-I)
                         MOVE 1 TO WS-OK
                     END-IF
                 END-PERFORM
                 IF WS-OK = 0
                     MOVE SPACES TO WS-DETAIL
                     STRING "type " FUNCTION TRIM(WS-SHORT) " is not a loot parameter set" DELIMITED BY SIZE INTO WS-DETAIL
                     CALL "WG-FAIL" USING WS-KEY WS-DETAIL
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM LOOT-TABLE-TYPES-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOOT-LOAD.
*> USING root (PIC X(1100)), status out (CT-OK, CT-BAD-DATA): the header of this file.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-ROWS.
    05 FILLER PIC X(24) VALUE "loot_table".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "d type;d random_sequence;l pools=loot_pool;f modifier=loot_fn".
    05 FILLER PIC X(24) VALUE "loot_pool".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "L entries=loot_entry;r condition=loot_cond;f modifier=loot_fn;P rolls=loot_int" &
        ";p bonus_rolls=loot_float".
    05 FILLER PIC X(24) VALUE "loot_entry".
    05 FILLER PIC X(48) VALUE "item".
    05 FILLER PIC X(600) VALUE "D name;i weight;i quality;r condition=loot_cond;f modifier=loot_fn".
    05 FILLER PIC X(24) VALUE "loot_entry".
    05 FILLER PIC X(48) VALUE "empty".
    05 FILLER PIC X(600) VALUE "x type;i weight;i quality;r condition=loot_cond;f modifier=loot_fn".
    05 FILLER PIC X(24) VALUE "loot_entry".
    05 FILLER PIC X(48) VALUE "tag".
    05 FILLER PIC X(600) VALUE "H items=item;B expand;i weight;i quality;r condition=loot_cond;f modifier=loot" &
        "_fn".
    05 FILLER PIC X(24) VALUE "loot_entry".
    05 FILLER PIC X(48) VALUE "loot_table".
    05 FILLER PIC X(600) VALUE "H value=loot_table;b expand;i weight;i quality;r condition=loot_cond;f modifie" &
        "r=loot_fn".
    05 FILLER PIC X(24) VALUE "loot_entry".
    05 FILLER PIC X(48) VALUE "dynamic".
    05 FILLER PIC X(600) VALUE "D name;i weight;i quality;r condition=loot_cond;f modifier=loot_fn".
    05 FILLER PIC X(24) VALUE "loot_entry".
    05 FILLER PIC X(48) VALUE "slots".
    05 FILLER PIC X(600) VALUE "F slot_source=loot_slot;i weight;i quality;r condition=loot_cond;f modifier=lo" &
        "ot_fn".
    05 FILLER PIC X(24) VALUE "loot_entry".
    05 FILLER PIC X(48) VALUE "alternatives".
    05 FILLER PIC X(600) VALUE "L children=loot_entry;r condition=loot_cond;f modifier=loot_fn".
    05 FILLER PIC X(24) VALUE "loot_entry".
    05 FILLER PIC X(48) VALUE "sequence".
    05 FILLER PIC X(600) VALUE "l children=loot_entry;r condition=loot_cond;f modifier=loot_fn".
    05 FILLER PIC X(24) VALUE "loot_entry".
    05 FILLER PIC X(48) VALUE "group".
    05 FILLER PIC X(600) VALUE "l children=loot_entry;r condition=loot_cond;f modifier=loot_fn".
    05 FILLER PIC X(24) VALUE "loot_entry".
    05 FILLER PIC X(48) VALUE "!".
    05 FILLER PIC X(600) VALUE "x type".
    05 FILLER PIC X(24) VALUE "loot_slot".
    05 FILLER PIC X(48) VALUE "group".
    05 FILLER PIC X(600) VALUE "F terms=loot_slot".
    05 FILLER PIC X(24) VALUE "loot_slot".
    05 FILLER PIC X(48) VALUE "filtered".
    05 FILLER PIC X(600) VALUE "F slot_source=loot_slot;O item_filter".
    05 FILLER PIC X(24) VALUE "loot_slot".
    05 FILLER PIC X(48) VALUE "limit_slots".
    05 FILLER PIC X(600) VALUE "F slot_source=loot_slot;I limit".
    05 FILLER PIC X(24) VALUE "loot_slot".
    05 FILLER PIC X(48) VALUE "slot_range".
    05 FILLER PIC X(600) VALUE "s source;S slots".
    05 FILLER PIC X(24) VALUE "loot_slot".
    05 FILLER PIC X(48) VALUE "contents".
    05 FILLER PIC X(600) VALUE "F slot_source=loot_slot;S component".
    05 FILLER PIC X(24) VALUE "loot_slot".
    05 FILLER PIC X(48) VALUE "empty".
    05 FILLER PIC X(600) VALUE "x type".
    05 FILLER PIC X(24) VALUE "loot_slot".
    05 FILLER PIC X(48) VALUE "!".
    05 FILLER PIC X(600) VALUE "x type".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "set_count".
    05 FILLER PIC X(600) VALUE "P count=loot_int;b add;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "set_item".
    05 FILLER PIC X(600) VALUE "D item;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "limit_count".
    05 FILLER PIC X(600) VALUE "T limit=loot_limit;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "explosion_decay".
    05 FILLER PIC X(600) VALUE "x type".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "enchanted_count_increase".
    05 FILLER PIC X(600) VALUE "P count=loot_float;D enchantment;i limit;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "apply_bonus".
    05 FILLER PIC X(600) VALUE "D enchantment;S formula;o parameters;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "furnace_smelt".
    05 FILLER PIC X(600) VALUE "b use_input_count;R condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "discard".
    05 FILLER PIC X(600) VALUE "x type".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "sequence".
    05 FILLER PIC X(600) VALUE "F functions=loot_fn;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "filtered".
    05 FILLER PIC X(600) VALUE "O item_filter;f on_pass=loot_fn;F on_fail=loot_fn".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "enchant_with_levels".
    05 FILLER PIC X(600) VALUE "P levels=loot_int;H options=enchantment;b include_additional_cost_component;r " &
        "condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "enchant_randomly".
    05 FILLER PIC X(600) VALUE "H options=enchantment;b only_compatible;b include_additional_cost_component;r " &
        "condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "set_enchantments".
    05 FILLER PIC X(600) VALUE "O enchantments;b add;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "set_damage".
    05 FILLER PIC X(600) VALUE "P damage=loot_float;b add;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "set_name".
    05 FILLER PIC X(600) VALUE "O name;s entity;E target=custom_name|item_name;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "set_lore".
    05 FILLER PIC X(600) VALUE "A lore;s mode;i offset;i size;s entity;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "copy_name".
    05 FILLER PIC X(600) VALUE "S source;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "copy_state".
    05 FILLER PIC X(600) VALUE "D block;K properties;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "copy_components".
    05 FILLER PIC X(600) VALUE "S source;K include;k exclude;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "set_components".
    05 FILLER PIC X(600) VALUE "O components;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "set_custom_data".
    05 FILLER PIC X(600) VALUE "X tag;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "copy_custom_data".
    05 FILLER PIC X(600) VALUE "T source=loot_nbt;L ops=loot_op;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "set_attributes".
    05 FILLER PIC X(600) VALUE "L modifiers=loot_attr;b replace;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "set_potion".
    05 FILLER PIC X(600) VALUE "D id;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "set_random_potion".
    05 FILLER PIC X(600) VALUE "H options=potion;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "set_stew_effect".
    05 FILLER PIC X(600) VALUE "L effects=loot_stew;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "set_instrument".
    05 FILLER PIC X(600) VALUE "H options=instrument;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "set_ominous_bottle_amplifier".
    05 FILLER PIC X(600) VALUE "P amplifier=loot_int;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "set_random_dyes".
    05 FILLER PIC X(600) VALUE "P number_of_dyes=loot_int;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "set_banner_pattern".
    05 FILLER PIC X(600) VALUE "A patterns;b append;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "set_book_cover".
    05 FILLER PIC X(600) VALUE "x title;x author;i generation;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "set_written_book_pages".
    05 FILLER PIC X(600) VALUE "A pages;s mode;i offset;i size;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "set_writable_book_pages".
    05 FILLER PIC X(600) VALUE "A pages;s mode;i offset;i size;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "set_fireworks".
    05 FILLER PIC X(600) VALUE "x explosions;i flight_duration;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "set_firework_explosion".
    05 FILLER PIC X(600) VALUE "s shape;a colors;a fade_colors;b trail;b twinkle;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "set_custom_model_data".
    05 FILLER PIC X(600) VALUE "x floats;x flags;x strings;x colors;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "toggle_tooltips".
    05 FILLER PIC X(600) VALUE "O toggles;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "fill_player_head".
    05 FILLER PIC X(600) VALUE "S entity;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "exploration_map".
    05 FILLER PIC X(600) VALUE "H destination=structure;s decoration;i zoom;i search_radius;b skip_existing_ch" &
        "unks;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "set_contents".
    05 FILLER PIC X(600) VALUE "S component;L entries=loot_entry;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "modify_contents".
    05 FILLER PIC X(600) VALUE "S component;F modifier=loot_fn;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "set_loot_table".
    05 FILLER PIC X(600) VALUE "D loot_table_id;i seed;r condition=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_fn".
    05 FILLER PIC X(48) VALUE "!".
    05 FILLER PIC X(600) VALUE "x type".
    05 FILLER PIC X(24) VALUE "loot_limit".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "p min=loot_int;p max=loot_int".
    05 FILLER PIC X(24) VALUE "loot_nbt".
    05 FILLER PIC X(48) VALUE "context".
    05 FILLER PIC X(600) VALUE "S target".
    05 FILLER PIC X(24) VALUE "loot_nbt".
    05 FILLER PIC X(48) VALUE "storage".
    05 FILLER PIC X(600) VALUE "D source".
    05 FILLER PIC X(24) VALUE "loot_nbt".
    05 FILLER PIC X(48) VALUE "!".
    05 FILLER PIC X(600) VALUE "x type".
    05 FILLER PIC X(24) VALUE "loot_op".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "S source;S target;E op=replace|append|merge".
    05 FILLER PIC X(24) VALUE "loot_attr".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "D id;D attribute;S operation;P amount=loot_float;X slot".
    05 FILLER PIC X(24) VALUE "loot_stew".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "D type;P duration=loot_int".
    05 FILLER PIC X(24) VALUE "loot_cond".
    05 FILLER PIC X(48) VALUE "inverted".
    05 FILLER PIC X(600) VALUE "R term=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_cond".
    05 FILLER PIC X(48) VALUE "all_of".
    05 FILLER PIC X(600) VALUE "F terms=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_cond".
    05 FILLER PIC X(48) VALUE "any_of".
    05 FILLER PIC X(600) VALUE "F terms=loot_cond".
    05 FILLER PIC X(24) VALUE "loot_cond".
    05 FILLER PIC X(48) VALUE "random_chance".
    05 FILLER PIC X(600) VALUE "P chance=loot_float".
    05 FILLER PIC X(24) VALUE "loot_cond".
    05 FILLER PIC X(48) VALUE "random_chance_with_enchanted_bonus".
    05 FILLER PIC X(600) VALUE "P unenchanted_chance=loot_float;V enchanted_chance=loot_level;D enchantment".
    05 FILLER PIC X(24) VALUE "loot_cond".
    05 FILLER PIC X(48) VALUE "killed_by_player".
    05 FILLER PIC X(600) VALUE "x type".
    05 FILLER PIC X(24) VALUE "loot_cond".
    05 FILLER PIC X(48) VALUE "survives_explosion".
    05 FILLER PIC X(600) VALUE "x type".
    05 FILLER PIC X(24) VALUE "loot_cond".
    05 FILLER PIC X(48) VALUE "table_bonus".
    05 FILLER PIC X(600) VALUE "D enchantment;A chances".
    05 FILLER PIC X(24) VALUE "loot_cond".
    05 FILLER PIC X(48) VALUE "match_tool".
    05 FILLER PIC X(600) VALUE "O predicate".
    05 FILLER PIC X(24) VALUE "loot_cond".
    05 FILLER PIC X(48) VALUE "match_block".
    05 FILLER PIC X(600) VALUE "x blocks;o state;x nbt;x components".
    05 FILLER PIC X(24) VALUE "loot_cond".
    05 FILLER PIC X(48) VALUE "damage_source_properties".
    05 FILLER PIC X(600) VALUE "O predicate".
    05 FILLER PIC X(24) VALUE "loot_cond".
    05 FILLER PIC X(48) VALUE "entity_properties".
    05 FILLER PIC X(600) VALUE "S entity;O predicate".
    05 FILLER PIC X(24) VALUE "loot_cond".
    05 FILLER PIC X(48) VALUE "entity_scores".
    05 FILLER PIC X(600) VALUE "S entity;O scores".
    05 FILLER PIC X(24) VALUE "loot_cond".
    05 FILLER PIC X(48) VALUE "location_check".
    05 FILLER PIC X(600) VALUE "O predicate;i offsetX;i offsetY;i offsetZ".
    05 FILLER PIC X(24) VALUE "loot_cond".
    05 FILLER PIC X(48) VALUE "weather_check".
    05 FILLER PIC X(600) VALUE "b raining;b thundering".
    05 FILLER PIC X(24) VALUE "loot_cond".
    05 FILLER PIC X(48) VALUE "time_check".
    05 FILLER PIC X(600) VALUE "X value;x clock;i period".
    05 FILLER PIC X(24) VALUE "loot_cond".
    05 FILLER PIC X(48) VALUE "int_value_check".
    05 FILLER PIC X(600) VALUE "P value=loot_int;X range".
    05 FILLER PIC X(24) VALUE "loot_cond".
    05 FILLER PIC X(48) VALUE "float_value_check".
    05 FILLER PIC X(600) VALUE "P value=loot_float;X range".
    05 FILLER PIC X(24) VALUE "loot_cond".
    05 FILLER PIC X(48) VALUE "enchantment_active_check".
    05 FILLER PIC X(600) VALUE "B active".
    05 FILLER PIC X(24) VALUE "loot_cond".
    05 FILLER PIC X(48) VALUE "environment_attribute_check".
    05 FILLER PIC X(600) VALUE "D attribute;X value".
    05 FILLER PIC X(24) VALUE "loot_cond".
    05 FILLER PIC X(48) VALUE "!".
    05 FILLER PIC X(600) VALUE "x type".
    05 FILLER PIC X(24) VALUE "loot_level".
    05 FILLER PIC X(48) VALUE "linear".
    05 FILLER PIC X(600) VALUE "N base;N per_level_above_first".
    05 FILLER PIC X(24) VALUE "loot_level".
    05 FILLER PIC X(48) VALUE "lookup".
    05 FILLER PIC X(600) VALUE "A values;V fallback=loot_level".
    05 FILLER PIC X(24) VALUE "loot_level".
    05 FILLER PIC X(48) VALUE "exponent".
    05 FILLER PIC X(600) VALUE "V base=loot_level;V power=loot_level".
    05 FILLER PIC X(24) VALUE "loot_level".
    05 FILLER PIC X(48) VALUE "clamped".
    05 FILLER PIC X(600) VALUE "V value=loot_level;N min;N max".
    05 FILLER PIC X(24) VALUE "loot_level".
    05 FILLER PIC X(48) VALUE "fraction".
    05 FILLER PIC X(600) VALUE "V numerator=loot_level;V denominator=loot_level".
    05 FILLER PIC X(24) VALUE "loot_level".
    05 FILLER PIC X(48) VALUE "levels_squared".
    05 FILLER PIC X(600) VALUE "N added".
    05 FILLER PIC X(24) VALUE "loot_level".
    05 FILLER PIC X(48) VALUE "!".
    05 FILLER PIC X(600) VALUE "x type".
    05 FILLER PIC X(24) VALUE "loot_score".
    05 FILLER PIC X(48) VALUE "fixed".
    05 FILLER PIC X(600) VALUE "S name".
    05 FILLER PIC X(24) VALUE "loot_score".
    05 FILLER PIC X(48) VALUE "context".
    05 FILLER PIC X(600) VALUE "S target".
    05 FILLER PIC X(24) VALUE "loot_score".
    05 FILLER PIC X(48) VALUE "!".
    05 FILLER PIC X(600) VALUE "x type".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "constant".
    05 FILLER PIC X(600) VALUE "I value".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "uniform".
    05 FILLER PIC X(600) VALUE "P min=loot_int;P max=loot_int".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "weighted_list".
    05 FILLER PIC X(600) VALUE "L distribution=loot_wint".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "conditional".
    05 FILLER PIC X(600) VALUE "R condition=loot_cond;P on_true=loot_int;p on_false=loot_int".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "number_dispatcher".
    05 FILLER PIC X(600) VALUE "L cases=loot_cint;P default=loot_int".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "abs".
    05 FILLER PIC X(600) VALUE "P input=loot_int".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "negate".
    05 FILLER PIC X(600) VALUE "P input=loot_int".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "avg".
    05 FILLER PIC X(600) VALUE "M inputs=loot_int".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "add".
    05 FILLER PIC X(600) VALUE "M inputs=loot_int".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "mul".
    05 FILLER PIC X(600) VALUE "M inputs=loot_int".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "min".
    05 FILLER PIC X(600) VALUE "M inputs=loot_int".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "max".
    05 FILLER PIC X(600) VALUE "M inputs=loot_int".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "sub".
    05 FILLER PIC X(600) VALUE "P left=loot_int;P right=loot_int".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "div".
    05 FILLER PIC X(600) VALUE "P left=loot_int;P right=loot_int".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "floor_div".
    05 FILLER PIC X(600) VALUE "P left=loot_int;P right=loot_int".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "mod".
    05 FILLER PIC X(600) VALUE "P left=loot_int;P right=loot_int".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "floor_mod".
    05 FILLER PIC X(600) VALUE "P left=loot_int;P right=loot_int".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "pow".
    05 FILLER PIC X(600) VALUE "P base=loot_int;P exponent=loot_int".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "environment_attribute".
    05 FILLER PIC X(600) VALUE "D attribute".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "storage".
    05 FILLER PIC X(600) VALUE "D storage;S path;p fallback=loot_int".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "binomial".
    05 FILLER PIC X(600) VALUE "P n=loot_int;P p=loot_float".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "from_float".
    05 FILLER PIC X(600) VALUE "P input=loot_float".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "score".
    05 FILLER PIC X(600) VALUE "T target=loot_score;S score;p fallback=loot_int".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "constant".
    05 FILLER PIC X(600) VALUE "N value".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "uniform".
    05 FILLER PIC X(600) VALUE "P min=loot_float;P max=loot_float".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "weighted_list".
    05 FILLER PIC X(600) VALUE "L distribution=loot_wflt".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "conditional".
    05 FILLER PIC X(600) VALUE "R condition=loot_cond;P on_true=loot_float;p on_false=loot_float".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "number_dispatcher".
    05 FILLER PIC X(600) VALUE "L cases=loot_cflt;P default=loot_float".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "abs".
    05 FILLER PIC X(600) VALUE "P input=loot_float".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "negate".
    05 FILLER PIC X(600) VALUE "P input=loot_float".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "avg".
    05 FILLER PIC X(600) VALUE "M inputs=loot_float".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "add".
    05 FILLER PIC X(600) VALUE "M inputs=loot_float".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "mul".
    05 FILLER PIC X(600) VALUE "M inputs=loot_float".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "min".
    05 FILLER PIC X(600) VALUE "M inputs=loot_float".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "max".
    05 FILLER PIC X(600) VALUE "M inputs=loot_float".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "sub".
    05 FILLER PIC X(600) VALUE "P left=loot_float;P right=loot_float".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "div".
    05 FILLER PIC X(600) VALUE "P left=loot_float;P right=loot_float".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "mod".
    05 FILLER PIC X(600) VALUE "P left=loot_float;P right=loot_float".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "pow".
    05 FILLER PIC X(600) VALUE "P base=loot_float;P exponent=loot_float".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "environment_attribute".
    05 FILLER PIC X(600) VALUE "D attribute".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "storage".
    05 FILLER PIC X(600) VALUE "D storage;S path;p fallback=loot_float".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "ceil".
    05 FILLER PIC X(600) VALUE "P input=loot_float".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "floor".
    05 FILLER PIC X(600) VALUE "P input=loot_float".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "round".
    05 FILLER PIC X(600) VALUE "P input=loot_float".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "truncate".
    05 FILLER PIC X(600) VALUE "P input=loot_float".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "sqrt".
    05 FILLER PIC X(600) VALUE "P input=loot_float".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "sin".
    05 FILLER PIC X(600) VALUE "P input=loot_float".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "cos".
    05 FILLER PIC X(600) VALUE "P input=loot_float".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "length".
    05 FILLER PIC X(600) VALUE "M inputs=loot_float".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "from_int".
    05 FILLER PIC X(600) VALUE "P input=loot_int".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "enchantment_level".
    05 FILLER PIC X(600) VALUE "V amount=loot_level".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "~".
    05 FILLER PIC X(600) VALUE "I".
    05 FILLER PIC X(24) VALUE "loot_int".
    05 FILLER PIC X(48) VALUE "!".
    05 FILLER PIC X(600) VALUE "x type".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "~".
    05 FILLER PIC X(600) VALUE "N".
    05 FILLER PIC X(24) VALUE "loot_float".
    05 FILLER PIC X(48) VALUE "!".
    05 FILLER PIC X(600) VALUE "x type".
    05 FILLER PIC X(24) VALUE "loot_wint".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "P data=loot_int;I weight=0..".
    05 FILLER PIC X(24) VALUE "loot_cint".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "R condition=loot_cond;P value=loot_int".
    05 FILLER PIC X(24) VALUE "loot_wflt".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "P data=loot_float;I weight=0..".
    05 FILLER PIC X(24) VALUE "loot_cflt".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(600) VALUE "R condition=loot_cond;P value=loot_float".
 01 WS-ROW-COUNT           BINARY-LONG VALUE 159.
 01 WS-TABLE               PIC X(48) VALUE "loot_table".
 01 WS-TABLE-GROUP         PIC X(24) VALUE "loot_table".
 01 WS-PREDICATE           PIC X(48) VALUE "predicate".
 01 WS-PREDICATE-GROUP     PIC X(24) VALUE "loot_cond".
 01 WS-MODIFIER            PIC X(48) VALUE "item_modifier".
 01 WS-MODIFIER-GROUP      PIC X(24) VALUE "loot_fn".
 01 WS-SLOT                PIC X(48) VALUE "slot_source".
 01 WS-SLOT-GROUP          PIC X(24) VALUE "loot_slot".
 01 WS-INT                 PIC X(48) VALUE "context_int_provider".
 01 WS-INT-GROUP           PIC X(24) VALUE "loot_int".
 01 WS-FLOAT               PIC X(48) VALUE "context_float_provider".
 01 WS-FLOAT-GROUP         PIC X(24) VALUE "loot_float".
 01 WS-LENIENT             BINARY-LONG VALUE 0.
 01 WS-STRICT              BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "SHAPE-BEGIN"
     CALL "SHAPE-REGISTER" USING WS-ROWS WS-ROW-COUNT
     CALL "SHAPE-LOAD" USING L-DIR WS-TABLE WS-TABLE-GROUP WS-LENIENT
     CALL "SHAPE-LOAD" USING L-DIR WS-PREDICATE WS-PREDICATE-GROUP WS-STRICT
     CALL "SHAPE-LOAD" USING L-DIR WS-MODIFIER WS-MODIFIER-GROUP WS-STRICT
     CALL "SHAPE-LOAD" USING L-DIR WS-SLOT WS-SLOT-GROUP WS-STRICT
     CALL "SHAPE-LOAD" USING L-DIR WS-INT WS-INT-GROUP WS-STRICT
     CALL "SHAPE-LOAD" USING L-DIR WS-FLOAT WS-FLOAT-GROUP WS-STRICT
     CALL "LOOT-TABLE-TYPES-CHECK"
     CALL "SHAPE-END" USING L-STATUS
     GOBACK.
 END PROGRAM LOOT-LOAD.
