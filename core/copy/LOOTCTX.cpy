*> The caller's loot context and result of LOOT-ROLL (core/src/loot.cob; docs/protocol/26-loot-and-predicates.md section 3 and 5).
*> LOOT-ROLL USING table key (PIC X(112), "namespace:path"), LOOT-CONTEXT, LOOT-RESULT: rolls the table with the context
*> (fields: LOOTCTXF.cpy; clear the record with INITIALIZE, then set the keys the parameter set of the table needs) and returns the
*> stacks. LR-STATUS 0 = rolled, 1 = no such table. LR-STACK(1 to LR-COUNT): item id, count (1 to the item's stack size: stacks
*> are split as in 5.1 step 5, empty ones left out) and the patch handle of core/copy/CSTACK.cpy (0: no component differs; a
*> handle must be stored in a slot or sent before the next patch is interned, see CSTACK.cpy).
 78 LR-MAX-STACKS         VALUE 128.
 01 LOOT-CONTEXT.
    05 LOOT-CONTEXT-FIELDS.
       COPY LOOTCTXF.
 01 LOOT-RESULT.
    05 LR-STATUS            BINARY-LONG.
    05 LR-COUNT             BINARY-LONG.
    05 LR-STACK             OCCURS 128 TIMES.
       10 LR-ITEM           BINARY-LONG.
       10 LR-AMOUNT         BINARY-LONG.
       10 LR-HANDLE         BINARY-LONG.
