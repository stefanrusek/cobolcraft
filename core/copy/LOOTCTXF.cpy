*> The fields of a loot context (docs/protocol/26-loot-and-predicates.md section 3), shared by LOOTCTX.cpy (the caller's record,
*> prefix LC-) and LOOTSTATE.cpy (the engine's working copy, prefix LW-C-). A key of section 3.1 that a caller does not supply has its
*> -SET flag 0 (the key is absent from the parameter map); every flag is 0 or 1. Positions are doubles, luck and radius floats.
*> The entity keys of section 3.1 are reduced to what the engine reads: LC-KILLER (last_damage_player present), the enchantment levels
*> of the attacking entity's equipped items (LC-ATTACKER-ENCH: enchantment registry id and level, as many as the caller lists), the
*> type keys of this_entity and the attacking entity, the weather of the level (LC-RAINING, LC-THUNDERING: 0 = clear when not
*> set) and the world clock's total ticks (LC-CLOCK-SET). LC-SEED is the explicit seed (0: none, the table's random sequence is used, section 4).
*> LC-DYNAMIC holds the dynamic drops by name (LootParams.addDynamicDrops: one stack each) for the dynamic entry.
 10 LC-ORIGIN-SET        BINARY-LONG.
 10 LC-X                 FLOAT-LONG.
 10 LC-Y                 FLOAT-LONG.
 10 LC-Z                 FLOAT-LONG.
 10 LC-STATE-SET         BINARY-LONG.
 10 LC-STATE             BINARY-LONG.
 10 LC-TOOL-SET          BINARY-LONG.
 10 LC-TOOL-ITEM         BINARY-LONG.
 10 LC-TOOL-COUNT        BINARY-LONG.
 10 LC-TOOL-HANDLE       BINARY-LONG.
 10 LC-RADIUS-SET        BINARY-LONG.
 10 LC-RADIUS            FLOAT-LONG.
 10 LC-LUCK              FLOAT-LONG.
 10 LC-SEED              BINARY-DOUBLE.
 10 LC-WORLD-SEED        BINARY-DOUBLE.
 10 LC-KILLER            BINARY-LONG.
 10 LC-ATTACKER-SET      BINARY-LONG.
 10 LC-ATTACKER-TYPE      PIC X(48).
 10 LC-ATTACKER-ENCH-COUNT BINARY-LONG.
 10 LC-ATTACKER-ENCH     OCCURS 4 TIMES.
    15 LC-AE-ID          BINARY-LONG.
    15 LC-AE-LEVEL       BINARY-LONG.
 10 LC-THIS-SET          BINARY-LONG.
 10 LC-THIS-TYPE         PIC X(48).
 10 LC-ENCH-SET          BINARY-LONG.
 10 LC-ENCH-LEVEL        BINARY-LONG.
 10 LC-ACTIVE-SET        BINARY-LONG.
 10 LC-ACTIVE            BINARY-LONG.
 10 LC-RAINING           BINARY-LONG.
 10 LC-THUNDERING        BINARY-LONG.
 10 LC-CLOCK-SET         BINARY-LONG.
 10 LC-CLOCK-TICKS       BINARY-DOUBLE.
 10 LC-DYNAMIC-COUNT     BINARY-LONG.
 10 LC-DYNAMIC           OCCURS 4 TIMES.
    15 LC-DY-NAME        PIC X(48).
    15 LC-DY-ITEM        BINARY-LONG.
    15 LC-DY-COUNT       BINARY-LONG.
    15 LC-DY-HANDLE      BINARY-LONG.
