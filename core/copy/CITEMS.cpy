*> The core's numeric item, entity-type and recipe tables, built from the open content set by CORE-TABLES-OPEN
*> (core/src/content-tables.cob) when a world opens; EXTERNAL. They replace ITEMS.cpy, ENTITYTYPES.cpy and
*> RECIPES.cpy. Index IT-ENTRY by item id + 1, ET-ENTRY by entity type id + 1, RP-ENTRY by display id + 1.
*>
*> Items (content-api: CONTENT-ITEM-BY-ID rows): IT-PLACES-STATE the default state of the block a block item places
*> (-1 for none), IT-MAX-STACK the stack size column, IT-TOOL-CLASS 1 for a tool rule over #minecraft:mineable/pickaxe
*> and 2 over #minecraft:mineable/shovel (0 none), IT-FOOD the "food" nutrition of the default components, IT-ATTACK
*> 1 + the "attack_damage" modifier (1 for an item without one).
*> IT-TOOL-SPEED the speed in thousandths that follows the class tag in the tool rule (4.0 gives 4000; 0 for no tool rule),
*> IT-TOOL-TIER the tier of 13 section 2.1: 0 wooden, golden or none, 1 stone or copper, 2 iron, 3 diamond, netherite and every other tool.
*> Entity types: the width and height of the row's size text in thousandths. CR-OPERATOR and CR-LOOSE-ITEM are the
*> player and item entity roles (world-types WT-22), CR-SODGRAZER and CR-ABEND the cobolcraft mobs; -1 when the open
*> set has no such type.
*> Recipes (the recipe store of the content set): each shapeless recipe as ingredient lines (item id, count) in order
*> of first use, at most RP-MAX-LINES lines; a recipe with more lines, and a shaped recipe (the crafting bench's, which
*> needs the 3 x 3 grid), is not held here.
 78 TOOL-BREAK-DIVISOR      VALUE 4.
 78 CI-MAX-ITEMS            VALUE 1500.
 78 CI-MAX-ENTITIES         VALUE 200.
 78 RP-MAX                  VALUE 64.
 78 RP-MAX-LINES            VALUE 3.
 01 CORE-ITEMS EXTERNAL.
    05 IT-COUNT               BINARY-LONG.
    05 IT-ENTRY OCCURS 1500 TIMES.
       10 IT-KEY             PIC X(48).
       10 IT-KEY-LENGTH      BINARY-LONG.
       10 IT-PLACES-STATE    BINARY-LONG.
       10 IT-MAX-STACK       BINARY-LONG.
       10 IT-TOOL-CLASS      BINARY-LONG.
       10 IT-FOOD            BINARY-LONG.
       10 IT-ATTACK          BINARY-LONG.
       10 IT-TOOL-SPEED      BINARY-LONG.
       10 IT-TOOL-TIER       BINARY-LONG.
 01 CORE-ENTITY-TYPES EXTERNAL.
    05 ET-COUNT               BINARY-LONG.
    05 ET-ENTRY OCCURS 200 TIMES.
       10 ET-KEY             PIC X(48).
       10 ET-KEY-LENGTH      BINARY-LONG.
       10 ET-WIDTH-MILLI     BINARY-LONG.
       10 ET-HEIGHT-MILLI    BINARY-LONG.
 01 CORE-ENTITY-ROLES EXTERNAL.
    05 CR-OPERATOR            BINARY-LONG.
    05 CR-LOOSE-ITEM          BINARY-LONG.
    05 CR-SODGRAZER           BINARY-LONG.
    05 CR-ABEND               BINARY-LONG.
 01 CORE-RECIPES EXTERNAL.
    05 RP-COUNT               BINARY-LONG.
    05 RP-ENTRY OCCURS 64 TIMES.
       10 RP-LINE-COUNT      BINARY-LONG.
       10 RP-LINE OCCURS 3 TIMES.
          15 RP-IN-ITEM      BINARY-LONG.
          15 RP-IN-COUNT     BINARY-LONG.
       10 RP-RESULT-ITEM     BINARY-LONG.
       10 RP-RESULT-COUNT    BINARY-LONG.
