*> A block record in flight through the processors (processBlock's `current`).
 01 STRUCT-CUR.
    05 CU-X                 BINARY-LONG.
    05 CU-Y                 BINARY-LONG.
    05 CU-Z                 BINARY-LONG.
    05 CU-STATE             BINARY-LONG.
    05 CU-NBT               BINARY-LONG.
*>  CU-LOOT the rule row of an append_loot that made the record's tag (0 none; SPR-LOOT is its table), CU-SEED the LootTableSeed it drew (the signed nextLong of the rule's source)
    05 CU-LOOT              BINARY-LONG.
    05 CU-SEED              BINARY-DOUBLE.
