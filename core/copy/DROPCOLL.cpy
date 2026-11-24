*> The drop collector of one explosion (docs/protocol/26 section 11.2, ServerExplosion.interactWithBlocks): the stacks the exploded blocks drop are not spawned at once; each goes through
*> addOrAppendStack (DROP-COLLECT-ADD) and every entry is spawned after the last block (DROP-COLLECT-FLUSH). DC-COUNT entries are in use; DC-IMMEDIATE 1 spawns each stack as it comes
*> (a single block's drops, BLOCK-DROPS-SPAWN). An entry holds the block cell that produced its first stack (DC-X, DC-Y, DC-Z), the item and the count; a stack's component patch is
*> not kept (the ground item cannot carry one yet, block-drops.cob).
 78 DC-MAX                VALUE 4096.
 01 DROP-COLLECTOR.
    05 DC-COUNT            BINARY-LONG.
    05 DC-IMMEDIATE        BINARY-LONG.
    05 DC-ENTRY            OCCURS 4096 TIMES.
       10 DC-X             BINARY-LONG.
       10 DC-Y             BINARY-LONG.
       10 DC-Z             BINARY-LONG.
       10 DC-ITEM          BINARY-LONG.
       10 DC-AMOUNT        BINARY-LONG.
