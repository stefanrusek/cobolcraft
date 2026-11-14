*> Test of the recipe loader (T0212; docs/protocol/27-recipes-and-unlocks.md sections 1 to 3, 5.9 and 6.1, 13 section 3.1
*> and 3.2). RECIPES-LOAD USING root (PIC X(1100): the folder that holds data/), status out (CT-OK, or CT-BAD-DATA
*> with every error printed on standard error as "ERROR registry: recipe ..."; nothing stays loaded then):
*> reads data/<namespace>/recipe/**/*.json through the registry loader (strict JSON, identifiers, listing order:
*> path first, then namespace) and parses each file into a row of RC-STORE (CTRECIPE.cpy); the recipe advancements
*> data/<namespace>/advancement/recipes/**/*.json give each recipe its unlock conditions (27 5.9). RECIPE-FIND USING
*> key (PIC X(112)), row out (BINARY-LONG, 0 when not found). RECIPES-FREE empties the store. The fixture tree is
*> content/tests/fixtures/recipes (31 recipes of every serializer family, three namespaces' worth of ordering, four
*> recipe advancements); the failing trees are copies of it under build/content-test/recipes altered per case.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-RECIPES-LOAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTRECIPE.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW                 BINARY-LONG.
 01 WS-LABEL               PIC X(60).
 01 WS-GOT-N               BINARY-LONG.
 01 WS-WANT-N              BINARY-LONG.
 01 WS-GOT-T               PIC X(200).
 01 WS-WANT-T              PIC X(200).
 01 WS-T                   PIC X(80).
 01 WS-N                   BINARY-LONG.
 01 WS-N-TEXT              PIC Z9.
 01 WS-MILLI               BINARY-LONG.
 01 WS-U                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "content/tests/fixtures/recipes" TO WS-DIR

*>   Before any load the store is empty and nothing is found.
     MOVE "minecraft:stick" TO WS-KEY
     CALL "RECIPE-FIND" USING WS-KEY WS-ROW
     MOVE "recipes: nothing is found before a load" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     PERFORM ASSERT-NUM

     CALL "RECIPES-LOAD" USING WS-DIR WS-STATUS
     MOVE "recipes: the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "recipes: 31 recipes, folders below recipe/ included" TO TL-CASE
     MOVE 31 TO TL-EXPECTED-N
     MOVE RC-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM

*>   Listing order (27 6.1, 23 3.4): path first, then namespace; zeta:own sorts between oak_planks and repair_item.
     MOVE 1 TO WS-N
     MOVE "minecraft:banner_duplicate_red" TO WS-WANT-T
     PERFORM ASSERT-ORDER
     MOVE 5 TO WS-N
     MOVE "minecraft:brewing/awkward" TO WS-WANT-T
     PERFORM ASSERT-ORDER
     MOVE 22 TO WS-N
     MOVE "minecraft:oak_planks" TO WS-WANT-T
     PERFORM ASSERT-ORDER
     MOVE 23 TO WS-N
     MOVE "zeta:own" TO WS-WANT-T
     PERFORM ASSERT-ORDER
     MOVE 24 TO WS-N
     MOVE "minecraft:repair_item" TO WS-WANT-T
     PERFORM ASSERT-ORDER
     MOVE 31 TO WS-N
     MOVE "minecraft:wooden_pickaxe" TO WS-WANT-T
     PERFORM ASSERT-ORDER

*>   Shaped (13 3.1, 3.2, 27 2.3): crafting_table, a 2 x 2 tag recipe that shows no notification.
     MOVE "minecraft:crafting_table" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "serializer" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE RR-SERIALIZER(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "category" TO WS-LABEL
     MOVE "building" TO WS-WANT-T
     MOVE RR-CATEGORY(WS-ROW) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "show_notification false" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE RR-NOTIFY(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "not special" TO WS-LABEL
     MOVE RR-SPECIAL(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "result" TO WS-LABEL
     MOVE "minecraft:crafting_table" TO WS-WANT-T
     MOVE RR-RESULT-ID(WS-ROW) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "result count" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE RR-RESULT-COUNT(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "width" TO WS-LABEL
     MOVE 2 TO WS-WANT-N
     MOVE RR-WIDTH(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "height" TO WS-LABEL
     MOVE RR-HEIGHT(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "slots" TO WS-LABEL
     MOVE 4 TO WS-WANT-N
     MOVE RR-ING-COUNT(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "slot 4 is the tag" TO WS-LABEL
     MOVE "#minecraft:planks" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 4) TO WS-GOT-T
     PERFORM EXPECT-T

*>   stick: 1 x 2, group, default category misc and notification true, count 4.
     MOVE "minecraft:stick" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "group" TO WS-LABEL
     MOVE "sticks" TO WS-WANT-T
     MOVE RR-GROUP(WS-ROW) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "default category" TO WS-LABEL
     MOVE "misc" TO WS-WANT-T
     MOVE RR-CATEGORY(WS-ROW) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "default notification" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE RR-NOTIFY(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "result count 4" TO WS-LABEL
     MOVE 4 TO WS-WANT-N
     MOVE RR-RESULT-COUNT(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "width 1" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE RR-WIDTH(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "height 2" TO WS-LABEL
     MOVE 2 TO WS-WANT-N
     MOVE RR-HEIGHT(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "slot 2" TO WS-LABEL
     MOVE "#minecraft:planks" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 2) TO WS-GOT-T
     PERFORM EXPECT-T

*>   wooden_pickaxe: 3 x 3 with empty cells, an item list as an ingredient, count defaults to 1.
     MOVE "minecraft:wooden_pickaxe" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "category equipment" TO WS-LABEL
     MOVE "equipment" TO WS-WANT-T
     MOVE RR-CATEGORY(WS-ROW) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "result count defaults to 1" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE RR-RESULT-COUNT(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "slots 9" TO WS-LABEL
     MOVE 9 TO WS-WANT-N
     MOVE RR-ING-COUNT(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "slot 1 is the list" TO WS-LABEL
     MOVE "minecraft:oak_planks minecraft:birch_planks" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 1) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "slot 4 is empty" TO WS-LABEL
     MOVE SPACES TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 4) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "slot 5 is the stick" TO WS-LABEL
     MOVE "minecraft:stick" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 5) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "slot 8 is the stick" TO WS-LABEL
     MOVE RR-ING(WS-ROW, 8) TO WS-GOT-T
     PERFORM EXPECT-T

*>   boxed: trailing empty columns and the empty middle row (13 3.2: only the outer rows and columns are trimmed).
     MOVE "minecraft:boxed" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "trimmed width" TO WS-LABEL
     MOVE 2 TO WS-WANT-N
     MOVE RR-WIDTH(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "trimmed height" TO WS-LABEL
     MOVE 3 TO WS-WANT-N
     MOVE RR-HEIGHT(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "cell 1" TO WS-LABEL
     MOVE "minecraft:iron_ingot" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 1) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "cell 3 (empty middle row)" TO WS-LABEL
     MOVE SPACES TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 3) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "cell 6" TO WS-LABEL
     MOVE "minecraft:iron_ingot" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 6) TO WS-GOT-T
     PERFORM EXPECT-T

*>   lead_trim: a leading empty row and column are removed as well.
     MOVE "minecraft:lead_trim" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "trimmed width" TO WS-LABEL
     MOVE 2 TO WS-WANT-N
     MOVE RR-WIDTH(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "trimmed height" TO WS-LABEL
     MOVE RR-HEIGHT(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "cell 1 is empty" TO WS-LABEL
     MOVE SPACES TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 1) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "cell 2" TO WS-LABEL
     MOVE "minecraft:iron_ingot" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 2) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "cell 3" TO WS-LABEL
     MOVE RR-ING(WS-ROW, 3) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "cell 4 is empty" TO WS-LABEL
     MOVE SPACES TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 4) TO WS-GOT-T
     PERFORM EXPECT-T

*>   Shapeless (27 2.2).
     MOVE "minecraft:oak_planks" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "serializer 1" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE RR-SERIALIZER(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "group planks" TO WS-LABEL
     MOVE "planks" TO WS-WANT-T
     MOVE RR-GROUP(WS-ROW) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "result count 4" TO WS-LABEL
     MOVE 4 TO WS-WANT-N
     MOVE RR-RESULT-COUNT(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "one ingredient" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE RR-ING-COUNT(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "ingredient 1" TO WS-LABEL
     MOVE "#minecraft:oak_logs" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 1) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "minecraft:two_kinds" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "two ingredients" TO WS-LABEL
     MOVE 2 TO WS-WANT-N
     MOVE RR-ING-COUNT(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "ingredient 1 is a list" TO WS-LABEL
     MOVE "minecraft:a minecraft:b" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 1) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "ingredient 2" TO WS-LABEL
     MOVE "minecraft:c" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 2) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "zeta:own" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "other namespace result" TO WS-LABEL
     MOVE "zeta:other" TO WS-WANT-T
     MOVE RR-RESULT-ID(WS-ROW) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "other namespace count" TO WS-LABEL
     MOVE 2 TO WS-WANT-N
     MOVE RR-RESULT-COUNT(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N

*>   The cooking family (27 3.1).
     MOVE "minecraft:iron_ingot_from_smelting" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "smelting serializer" TO WS-LABEL
     MOVE 14 TO WS-WANT-N
     MOVE RR-SERIALIZER(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "smelting ingredient" TO WS-LABEL
     MOVE "minecraft:raw_iron" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 1) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "smelting group" TO WS-LABEL
     MOVE "iron_ingot" TO WS-WANT-T
     MOVE RR-GROUP(WS-ROW) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "smelting cookingtime" TO WS-LABEL
     MOVE 200 TO WS-WANT-N
     MOVE RR-COOK-TIME(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "smelting experience 0.7" TO WS-LABEL
     MOVE 700 TO WS-WANT-N
     COMPUTE WS-MILLI ROUNDED = RR-EXPERIENCE(WS-ROW) * 1000
     MOVE WS-MILLI TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "smelting result" TO WS-LABEL
     MOVE "minecraft:iron_ingot" TO WS-WANT-T
     MOVE RR-RESULT-ID(WS-ROW) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "minecraft:iron_ingot_from_blasting" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "blasting serializer" TO WS-LABEL
     MOVE 15 TO WS-WANT-N
     MOVE RR-SERIALIZER(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "blasting cookingtime" TO WS-LABEL
     MOVE 100 TO WS-WANT-N
     MOVE RR-COOK-TIME(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "minecraft:cooked_beef_smoking" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "smoking serializer" TO WS-LABEL
     MOVE 16 TO WS-WANT-N
     MOVE RR-SERIALIZER(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "smoking category food" TO WS-LABEL
     MOVE "food" TO WS-WANT-T
     MOVE RR-CATEGORY(WS-ROW) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "smoking experience 0.35" TO WS-LABEL
     MOVE 350 TO WS-WANT-N
     COMPUTE WS-MILLI ROUNDED = RR-EXPERIENCE(WS-ROW) * 1000
     MOVE WS-MILLI TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "minecraft:cooked_beef_campfire" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "campfire serializer" TO WS-LABEL
     MOVE 17 TO WS-WANT-N
     MOVE RR-SERIALIZER(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "campfire cookingtime 600" TO WS-LABEL
     MOVE 600 TO WS-WANT-N
     MOVE RR-COOK-TIME(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "campfire experience defaults to 0" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     COMPUTE WS-MILLI ROUNDED = RR-EXPERIENCE(WS-ROW) * 1000
     MOVE WS-MILLI TO WS-GOT-N
     PERFORM EXPECT-N

*>   Stonecutting (27 3.2): no group, no category.
     MOVE "minecraft:stone_stairs_stonecutting" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "stonecutting serializer" TO WS-LABEL
     MOVE 18 TO WS-WANT-N
     MOVE RR-SERIALIZER(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "stonecutting ingredient" TO WS-LABEL
     MOVE "minecraft:stone" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 1) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "stonecutting result" TO WS-LABEL
     MOVE "minecraft:stone_stairs" TO WS-WANT-T
     MOVE RR-RESULT-ID(WS-ROW) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "stonecutting has no category" TO WS-LABEL
     MOVE SPACES TO WS-WANT-T
     MOVE RR-CATEGORY(WS-ROW) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "stonecutting has no group" TO WS-LABEL
     MOVE RR-GROUP(WS-ROW) TO WS-GOT-T
     PERFORM EXPECT-T

*>   Smithing (27 3.3): the template and the addition are optional for the transform.
     MOVE "minecraft:netherite_sword_smithing" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "transform serializer" TO WS-LABEL
     MOVE 19 TO WS-WANT-N
     MOVE RR-SERIALIZER(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "transform slots" TO WS-LABEL
     MOVE 3 TO WS-WANT-N
     MOVE RR-ING-COUNT(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "transform template" TO WS-LABEL
     MOVE "minecraft:netherite_upgrade_smithing_template" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 1) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "transform base" TO WS-LABEL
     MOVE "minecraft:diamond_sword" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 2) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "transform addition" TO WS-LABEL
     MOVE "#minecraft:netherite_tool_materials" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 3) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "minecraft:no_template_smithing" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "absent template is empty" TO WS-LABEL
     MOVE SPACES TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 1) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "base without template" TO WS-LABEL
     MOVE "minecraft:diamond_axe" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 2) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "absent addition is empty" TO WS-LABEL
     MOVE SPACES TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 3) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "minecraft:trim_smithing" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "trim serializer" TO WS-LABEL
     MOVE 21 TO WS-WANT-N
     MOVE RR-SERIALIZER(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "trim pattern" TO WS-LABEL
     MOVE "minecraft:coast" TO WS-WANT-T
     MOVE RR-EXTRA(WS-ROW) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "trim addition" TO WS-LABEL
     MOVE "#minecraft:trim_materials" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 3) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "trim has no result" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE RR-RESULT-COUNT(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N

*>   Transmute (27 2.4): default material count 1, a range, an exact count.
     MOVE "minecraft:black_shulker_box" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "transmute serializer" TO WS-LABEL
     MOVE 4 TO WS-WANT-N
     MOVE RR-SERIALIZER(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "transmute input" TO WS-LABEL
     MOVE "#minecraft:shulker_boxes" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 1) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "transmute material" TO WS-LABEL
     MOVE "minecraft:black_dye" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 2) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "default material count min" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE RR-MATERIAL-MIN(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "default material count max" TO WS-LABEL
     MOVE RR-MATERIAL-MAX(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "default add_material_count_to_result" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE RR-ADD-COUNT(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "minecraft:map_cloning" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "range min" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE RR-MATERIAL-MIN(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "range max" TO WS-LABEL
     MOVE 8 TO WS-WANT-N
     MOVE RR-MATERIAL-MAX(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "add_material_count_to_result" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE RR-ADD-COUNT(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "result {} keeps the input item (no id)" TO WS-LABEL
     MOVE SPACES TO WS-WANT-T
     MOVE RR-RESULT-ID(WS-ROW) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "result {} count 1" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE RR-RESULT-COUNT(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "minecraft:exact_count" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "exact count min" TO WS-LABEL
     MOVE 3 TO WS-WANT-N
     MOVE RR-MATERIAL-MIN(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "exact count max" TO WS-LABEL
     MOVE RR-MATERIAL-MAX(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "exact count result 2" TO WS-LABEL
     MOVE 2 TO WS-WANT-N
     MOVE RR-RESULT-COUNT(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N

*>   Dye and imbue are normal recipes (27 1.2); the special recipes carry no notification (27 1.2).
     MOVE "minecraft:leather_dye" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "dye serializer" TO WS-LABEL
     MOVE 2 TO WS-WANT-N
     MOVE RR-SERIALIZER(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "dye is not special" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE RR-SPECIAL(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "dye notifies" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE RR-NOTIFY(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "dye group" TO WS-LABEL
     MOVE "dyed_armor" TO WS-WANT-T
     MOVE RR-GROUP(WS-ROW) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "dye target" TO WS-LABEL
     MOVE "#minecraft:dyeable" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 1) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "dye dye" TO WS-LABEL
     MOVE "#minecraft:dyes" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 2) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "minecraft:tipped_arrow" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "imbue serializer" TO WS-LABEL
     MOVE 3 TO WS-WANT-N
     MOVE RR-SERIALIZER(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "imbue source" TO WS-LABEL
     MOVE "minecraft:lingering_potion" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 1) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "imbue result 8" TO WS-LABEL
     MOVE 8 TO WS-WANT-N
     MOVE RR-RESULT-COUNT(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "minecraft:decorated_pot" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "pot serializer" TO WS-LABEL
     MOVE 5 TO WS-WANT-N
     MOVE RR-SERIALIZER(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "pot is special" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE RR-SPECIAL(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "pot sends no notification" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE RR-NOTIFY(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "pot category misc" TO WS-LABEL
     MOVE "misc" TO WS-WANT-T
     MOVE RR-CATEGORY(WS-ROW) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "pot has four ingredients" TO WS-LABEL
     MOVE 4 TO WS-WANT-N
     MOVE RR-ING-COUNT(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "pot front" TO WS-LABEL
     MOVE "#minecraft:decorated_pot_ingredients" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 4) TO WS-GOT-T
     PERFORM EXPECT-T

*>   The other special recipes: their ingredient fields in the order of 27 2.1.
     MOVE "minecraft:book_cloning" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "book cloning serializer" TO WS-LABEL
     MOVE 6 TO WS-WANT-N
     MOVE RR-SERIALIZER(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "book cloning material" TO WS-LABEL
     MOVE "#minecraft:book_cloning_target" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 2) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "minecraft:map_extending" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "map extending serializer" TO WS-LABEL
     MOVE 7 TO WS-WANT-N
     MOVE RR-SERIALIZER(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "map extending map" TO WS-LABEL
     MOVE "#minecraft:extendable_maps" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 1) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "map extending material" TO WS-LABEL
     MOVE "minecraft:paper" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 2) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "minecraft:firework_rocket" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "rocket serializer" TO WS-LABEL
     MOVE 8 TO WS-WANT-N
     MOVE RR-SERIALIZER(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "rocket star" TO WS-LABEL
     MOVE "minecraft:firework_star" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 3) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "rocket result 3" TO WS-LABEL
     MOVE 3 TO WS-WANT-N
     MOVE RR-RESULT-COUNT(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "minecraft:firework_star" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "star serializer" TO WS-LABEL
     MOVE 9 TO WS-WANT-N
     MOVE RR-SERIALIZER(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "star trail" TO WS-LABEL
     MOVE "minecraft:diamond" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 1) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "star dye" TO WS-LABEL
     MOVE "#minecraft:dyes" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 4) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "minecraft:firework_star_fade" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "fade serializer" TO WS-LABEL
     MOVE 10 TO WS-WANT-N
     MOVE RR-SERIALIZER(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "minecraft:banner_duplicate_red" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "banner serializer" TO WS-LABEL
     MOVE 11 TO WS-WANT-N
     MOVE RR-SERIALIZER(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "banner ingredient" TO WS-LABEL
     MOVE "minecraft:red_banner" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 1) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "minecraft:shield_decoration" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "shield serializer" TO WS-LABEL
     MOVE 12 TO WS-WANT-N
     MOVE RR-SERIALIZER(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "shield target" TO WS-LABEL
     MOVE "minecraft:shield" TO WS-WANT-T
     MOVE RR-ING(WS-ROW, 2) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "minecraft:repair_item" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "repair serializer" TO WS-LABEL
     MOVE 13 TO WS-WANT-N
     MOVE RR-SERIALIZER(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "repair has no ingredient fields" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE RR-ING-COUNT(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "repair has no result" TO WS-LABEL
     MOVE RR-RESULT-COUNT(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "repair is special" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE RR-SPECIAL(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N

*>   Brewing (27 3.4) is special and has an output template; its ingredients are not read by this loader.
     MOVE "minecraft:brewing/awkward" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "brewing serializer" TO WS-LABEL
     MOVE 20 TO WS-WANT-N
     MOVE RR-SERIALIZER(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "brewing is special" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE RR-SPECIAL(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "brewing output" TO WS-LABEL
     MOVE "minecraft:potion" TO WS-WANT-T
     MOVE RR-RESULT-ID(WS-ROW) TO WS-GOT-T
     PERFORM EXPECT-T

*>   Unlock conditions (27 5.9): the criteria of the recipe advancement other than recipe_unlocked.
     MOVE "minecraft:oak_planks" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "unlock: one condition" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE RR-UNLOCK-N(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE RR-UNLOCK-FIRST(WS-ROW) TO WS-U
     MOVE "unlock: trigger" TO WS-LABEL
     MOVE "minecraft:inventory_changed" TO WS-WANT-T
     MOVE RU-TRIGGER(WS-U) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "unlock: items" TO WS-LABEL
     MOVE "#minecraft:oak_logs" TO WS-WANT-T
     MOVE RU-ITEMS(WS-U) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "minecraft:crafting_table" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "unlock: crafting_table has one" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE RR-UNLOCK-N(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE RR-UNLOCK-FIRST(WS-ROW) TO WS-U
     MOVE "unlock: crafting_table unlocks on the tick" TO WS-LABEL
     MOVE "minecraft:tick" TO WS-WANT-T
     MOVE RU-TRIGGER(WS-U) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "unlock: a tick condition has no items" TO WS-LABEL
     MOVE SPACES TO WS-WANT-T
     MOVE RU-ITEMS(WS-U) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "minecraft:iron_ingot_from_smelting" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "unlock: iron has two" TO WS-LABEL
     MOVE 2 TO WS-WANT-N
     MOVE RR-UNLOCK-N(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE RR-UNLOCK-FIRST(WS-ROW) TO WS-U
     MOVE "unlock: first trigger" TO WS-LABEL
     MOVE "minecraft:inventory_changed" TO WS-WANT-T
     MOVE RU-TRIGGER(WS-U) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "unlock: two predicates joined, ids of one predicate listed" TO WS-LABEL
     MOVE "minecraft:raw_iron minecraft:iron_ore & minecraft:coal" TO WS-WANT-T
     MOVE RU-ITEMS(WS-U) TO WS-GOT-T
     PERFORM EXPECT-T
     ADD 1 TO WS-U
     MOVE "unlock: second trigger" TO WS-LABEL
     MOVE "minecraft:enter_block" TO WS-WANT-T
     MOVE RU-TRIGGER(WS-U) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "minecraft:stick" TO WS-KEY
     PERFORM FIND-ROW
     MOVE "unlock: a recipe with no advancement has none" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE RR-UNLOCK-N(WS-ROW) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "unlock: entries stored (the orphan and the root add none)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE RC-UNLOCK-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM

*>   An unknown key is not found; RECIPES-FREE empties the store; a second load replaces the first.
     MOVE "minecraft:nothing" TO WS-KEY
     CALL "RECIPE-FIND" USING WS-KEY WS-ROW
     MOVE "recipes: an unknown key is not found" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "RECIPES-LOAD" USING WS-DIR WS-STATUS
     MOVE "recipes: loading again replaces the rows" TO TL-CASE
     MOVE 31 TO TL-EXPECTED-N
     MOVE RC-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "RECIPES-FREE"
     MOVE "recipes: RECIPES-FREE empties the store" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RC-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "recipes: ... and the unlock entries" TO TL-CASE
     MOVE RC-UNLOCK-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM

*>   A tree without recipes loads nothing and is not an error.
     MOVE "build/content-test/recipes/nothing" TO WS-DIR
     CALL "RECIPES-LOAD" USING WS-DIR WS-STATUS
     MOVE "recipes: a folder without data loads zero recipes" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "recipes: ... zero rows" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RC-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM

*>   An inventory_changed criterion without item predicates, or whose items are not a list, keeps no items.
     MOVE "build/content-test/recipes/t" TO WS-DIR
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""rewards"":{""recipes"":[""minecraft:stick""]},""criteria"":{""a"":{""trigger"":""minecraft:inventory_changed"",""conditions"":{}}}}' > build/content-test/recipes/t/data/minecraft/advancement/recipes/stick.json && printf '{""rewards"":{""recipes"":[""minecraft:two_kinds""]},""criteria"":{""a"":{""trigger"":""minecraft:inventory_changed"",""conditions"":{""items"":""x""}}}}' > build/content-test/recipes/t/data/minecraft/advancement/recipes/two_kinds.json"
     CALL "RECIPES-LOAD" USING WS-DIR WS-STATUS
     MOVE "recipes: criteria without item predicates load" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "recipes: ... two more unlock entries" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE RC-UNLOCK-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "minecraft:stick" TO WS-KEY
     PERFORM FIND-ROW
     MOVE RR-UNLOCK-FIRST(WS-ROW) TO WS-U
     MOVE "unlock: no conditions.items keeps no items" TO WS-LABEL
     MOVE SPACES TO WS-WANT-T
     MOVE RU-ITEMS(WS-U) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "minecraft:two_kinds" TO WS-KEY
     PERFORM FIND-ROW
     MOVE RR-UNLOCK-FIRST(WS-ROW) TO WS-U
     MOVE "unlock: items that are not a list keep no items" TO WS-LABEL
     MOVE RU-ITEMS(WS-U) TO WS-GOT-T
     PERFORM EXPECT-T
     CALL "RECIPES-FREE"

*>   Failures: each is CT-BAD-DATA with an ERROR line naming the recipe, and nothing stays loaded.
     MOVE "not strict JSON" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:stonecutting"",}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "a recipe that is not an object" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '[]' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "a recipe of more than 4096 nodes" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "(printf '{""type"":""minecraft:crafting_shapeless"",""ingredients"":['; for i in $(seq 1 4100); do printf '""minecraft:a"",'; done; printf '""minecraft:a""]}') > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "a missing type" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""ingredient"":""minecraft:a""}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "an unknown type" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:crafting_nothing""}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "a shaped pattern of four rows" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:crafting_shaped"",""key"":{""A"":""minecraft:a""},""pattern"":[""A"",""A"",""A"",""A""],""result"":{""id"":""minecraft:b""}}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "a shaped pattern that is missing" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:crafting_shaped"",""key"":{""A"":""minecraft:a""},""result"":{""id"":""minecraft:b""}}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "a shaped pattern row that is not text" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:crafting_shaped"",""key"":{""A"":""minecraft:a""},""pattern"":[1],""result"":{""id"":""minecraft:b""}}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "a shaped pattern row of four columns" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:crafting_shaped"",""key"":{""A"":""minecraft:a""},""pattern"":[""AAAA""],""result"":{""id"":""minecraft:b""}}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "shaped rows of different lengths" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:crafting_shaped"",""key"":{""A"":""minecraft:a""},""pattern"":[""AA"",""A""],""result"":{""id"":""minecraft:b""}}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "a shaped key that is missing" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:crafting_shaped"",""pattern"":[""A""],""result"":{""id"":""minecraft:b""}}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "a shaped key of two characters" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:crafting_shaped"",""key"":{""AB"":""minecraft:a""},""pattern"":[""A""],""result"":{""id"":""minecraft:b""}}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "ten shaped keys" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:crafting_shaped"",""key"":{""A"":""a"",""B"":""a"",""C"":""a"",""D"":""a"",""E"":""a"",""F"":""a"",""G"":""a"",""H"":""a"",""I"":""a"",""J"":""a""},""pattern"":[""ABC"",""DEF"",""GHI""],""result"":{""id"":""minecraft:b""}}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "a pattern character with no key" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:crafting_shaped"",""key"":{""A"":""minecraft:a""},""pattern"":[""AB""],""result"":{""id"":""minecraft:b""}}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "a key that the pattern does not use" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:crafting_shaped"",""key"":{""A"":""minecraft:a"",""B"":""minecraft:a""},""pattern"":[""A""],""result"":{""id"":""minecraft:b""}}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "an all-empty pattern" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:crafting_shaped"",""key"":{},""pattern"":["" ""],""result"":{""id"":""minecraft:b""}}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "a shaped ingredient that is an empty list" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:crafting_shaped"",""key"":{""A"":[]},""pattern"":[""A""],""result"":{""id"":""minecraft:b""}}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "a shapeless recipe with no ingredients" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:crafting_shapeless"",""ingredients"":[],""result"":{""id"":""minecraft:b""}}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "a shapeless recipe without the ingredients field" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:crafting_shapeless"",""result"":{""id"":""minecraft:b""}}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "a shapeless recipe with ten ingredients" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:crafting_shapeless"",""ingredients"":[""a"",""a"",""a"",""a"",""a"",""a"",""a"",""a"",""a"",""a""],""result"":{""id"":""minecraft:b""}}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "an ingredient that is a number" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:crafting_shapeless"",""ingredients"":[5],""result"":{""id"":""minecraft:b""}}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "an ingredient list holding a number" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:crafting_shapeless"",""ingredients"":[[""a"",5]],""result"":{""id"":""minecraft:b""}}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "an empty ingredient string" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:crafting_shapeless"",""ingredients"":[""""],""result"":{""id"":""minecraft:b""}}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "an ingredient list over 800 bytes" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "(printf '{""type"":""minecraft:crafting_shapeless"",""ingredients"":[['; for i in $(seq 1 40); do printf '""minecraft:long_item_name_%s"",' $i; done; printf '""x""]],""result"":{""id"":""minecraft:b""}}') > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
*>   48 section 4.7: an ingredient may be a list of 16 ids (a choice, 783 bytes at most) and a recipe id may be 88 bytes long.
     MOVE "a choice ingredient of 16 ids and a recipe key of 88 bytes" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "f=$(printf 'r%.0s' $(seq 1 88)); (printf '{""type"":""minecraft:crafting_shapeless"",""ingredients"":[['; for i in $(seq 1 15); do printf '""minecraft:iron_pickaxe_%s"",' $i; done; printf '""x""]],""result"":{""id"":""minecraft:b""}}') > build/content-test/recipes/t/data/minecraft/recipe/$f.json"
     CALL "RECIPES-LOAD" USING WS-DIR WS-STATUS
     MOVE "recipes: a choice ingredient of 16 ids and a key of 88 bytes loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "RECIPES-FREE"
     MOVE "a smelting recipe without cookingtime" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:smelting"",""ingredient"":""minecraft:a"",""result"":{""id"":""minecraft:b""}}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "a smelting recipe without an ingredient" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:smelting"",""cookingtime"":5,""result"":{""id"":""minecraft:b""}}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "a recipe without a result" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:stonecutting"",""ingredient"":""minecraft:a""}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "a result without an id" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:stonecutting"",""ingredient"":""minecraft:a"",""result"":{""count"":2}}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "a material count of 9" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:crafting_transmute"",""input"":""a"",""material"":""b"",""material_count"":9,""result"":{}}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "a material count range with max 0" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:crafting_transmute"",""input"":""a"",""material"":""b"",""material_count"":{""min"":1,""max"":0},""result"":{}}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "a material count that is text" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""type"":""minecraft:crafting_transmute"",""input"":""a"",""material"":""b"",""material_count"":""x"",""result"":{}}' > build/content-test/recipes/t/data/minecraft/recipe/bad.json"
     PERFORM LOAD-FAILS
     MOVE "a bad namespace folder" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "mkdir -p build/content-test/recipes/t/data/Bad/recipe && printf '{}' > build/content-test/recipes/t/data/Bad/recipe/x.json"
     PERFORM LOAD-FAILS
     MOVE "an advancement that is not strict JSON" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""a"":1,}' > build/content-test/recipes/t/data/minecraft/advancement/recipes/bad.json"
     PERFORM LOAD-FAILS
     MOVE "an advancement of more than 4096 nodes" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "(printf '{""rewards"":{""recipes"":[""minecraft:stick""]},""criteria"":{""a"":{""trigger"":""minecraft:inventory_changed"",""conditions"":{""items"":['; for i in $(seq 1 2100); do printf '{""items"":""a""},'; done; printf '{""items"":""a""}]}}}}') > build/content-test/recipes/t/data/minecraft/advancement/recipes/bad.json"
     PERFORM LOAD-FAILS
     MOVE "two advancements for one recipe" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "cp build/content-test/recipes/t/data/minecraft/advancement/recipes/misc/oak_planks.json build/content-test/recipes/t/data/minecraft/advancement/recipes/again.json"
     PERFORM LOAD-FAILS
     MOVE "an inventory_changed predicate list over 200 bytes" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "(printf '{""rewards"":{""recipes"":[""minecraft:stick""]},""criteria"":{""a"":{""trigger"":""minecraft:inventory_changed"",""conditions"":{""items"":['; for i in $(seq 1 12); do printf '{""items"":""minecraft:long_item_name_%s""},' $i; done; printf '{""items"":""a""}]}}}}') > build/content-test/recipes/t/data/minecraft/advancement/recipes/bad.json"
     PERFORM LOAD-FAILS
     MOVE "a predicate item list that is empty" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '{""rewards"":{""recipes"":[""minecraft:stick""]},""criteria"":{""a"":{""trigger"":""minecraft:inventory_changed"",""conditions"":{""items"":[{""items"":[]}]}}}}' > build/content-test/recipes/t/data/minecraft/advancement/recipes/bad.json"
     PERFORM LOAD-FAILS
     MOVE "more than 4096 recipes" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "for i in $(seq 1 4097); do printf '{""type"":""minecraft:stonecutting"",""ingredient"":""minecraft:a"",""result"":{""id"":""minecraft:b""}}' > build/content-test/recipes/t/data/minecraft/recipe/r$i.json; done"
     PERFORM LOAD-FAILS
     MOVE "more than 4096 unlock conditions" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "d=build/content-test/recipes/t/data/minecraft; for i in $(seq 1 300); do printf '{""type"":""minecraft:stonecutting"",""ingredient"":""minecraft:a"",""result"":{""id"":""minecraft:b""}}' > $d/recipe/r$i.json; (printf '{""rewards"":{""recipes"":[""minecraft:r%s""]},""criteria"":{' $i; for c in $(seq 1 14); do printf '""c%s"":{""trigger"":""minecraft:tick""},' $c; done; printf '""c15"":{""trigger"":""minecraft:tick""}}}') > $d/advancement/recipes/r$i.json; done"
     PERFORM LOAD-FAILS
     MOVE "a directory path of 1100 characters" TO WS-T
     MOVE ALL "a" TO WS-DIR
     CALL "RECIPES-LOAD" USING WS-DIR WS-STATUS
     MOVE "recipes: a directory path of 1100 characters is CT-BAD-DATA" TO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     STOP RUN.

 FRESH-TREE.
     CALL "SYSTEM" USING "chmod -R u+rwx build/content-test/recipes 2>/dev/null; rm -rf build/content-test/recipes; mkdir -p build/content-test/recipes && cp -R content/tests/fixtures/recipes build/content-test/recipes/t".

 LOAD-FAILS.
     CALL "RECIPES-LOAD" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "recipes: " FUNCTION TRIM(WS-T) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "recipes: after " FUNCTION TRIM(WS-T) " nothing stays loaded" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RC-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "RECIPES-FREE".

 FIND-ROW.
     CALL "RECIPE-FIND" USING WS-KEY WS-ROW
     IF WS-ROW = 0
         MOVE 1 TO WS-ROW
     END-IF.

 ASSERT-ORDER.
     MOVE RR-KEY(WS-N) TO WS-GOT-T
     MOVE WS-N TO WS-N-TEXT
     MOVE SPACES TO TL-CASE
     STRING "recipes: listing position " WS-N-TEXT DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-WANT-T TO TL-EXPECTED
     MOVE WS-GOT-T TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 EXPECT-N.
     MOVE SPACES TO TL-CASE
     STRING "recipes: " FUNCTION TRIM(WS-KEY) " " FUNCTION TRIM(WS-LABEL) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-WANT-N TO TL-EXPECTED-N
     MOVE WS-GOT-N TO TL-OBSERVED-N
     PERFORM ASSERT-NUM.

 EXPECT-T.
     MOVE SPACES TO TL-CASE
     STRING "recipes: " FUNCTION TRIM(WS-KEY) " " FUNCTION TRIM(WS-LABEL) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-WANT-T TO TL-EXPECTED
     MOVE WS-GOT-T TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
