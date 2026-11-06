*> Recipes (standin-content §13; data-model §8), transcribed in display-id order. Index by (display
*> id + 1). Tested by core/tests/test_content_tables.cob. Each recipe has RP-LINE-COUNT ingredient
*> lines (item id, count) in the §13 display order (unused lines are 0 0) and one result (item id,
*> count). Item ids are those of ITEMS.cpy (§2).
 78 RECIPE-COUNT              VALUE 9.
 78 RECIPE-MAX-LINES          VALUE 3.
 01 RECIPE-DATA.
    05 FILLER.                                  *> 0: 4 greystone -> 2 ledger_tile
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 9.
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.                                  *> 1: 4 grit -> 2 lucite
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.                                  *> 2: 3 greystone + 1 cardstack -> 1 pry_bar
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 3.
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 10.
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> 3: 2 greystone + 1 cardstack -> 1 trowel
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 11.
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> 4: 1 lucite + 1 dump_shard -> 2 glowtube
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 15.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 8.
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.                                  *> 5: 4 turf + 1 loam -> 1 sod_cake
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE 3.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 14.
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> 6: 2 grazer_flank + 1 glowtube -> 2 seared_flank
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 12.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 8.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 13.
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.                                  *> 7: 4 ledger_tile + 2 dump_shard + 1 glowtube -> 1 goto_pad
       10 FILLER BINARY-LONG VALUE 3.
       10 FILLER BINARY-LONG VALUE 9.
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE 15.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 8.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 16.
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.                                  *> 8: 2 cardstack + 2 lucite -> 1 dump_shard
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 15.
       10 FILLER BINARY-LONG VALUE 1.
 01 RECIPE-TABLE REDEFINES RECIPE-DATA.
    05 RP-ENTRY OCCURS 9 TIMES.
       10 RP-LINE-COUNT         BINARY-LONG.
       10 RP-LINE OCCURS 3 TIMES.
          15 RP-IN-ITEM         BINARY-LONG.
          15 RP-IN-COUNT        BINARY-LONG.
       10 RP-RESULT-ITEM        BINARY-LONG.
       10 RP-RESULT-COUNT       BINARY-LONG.
