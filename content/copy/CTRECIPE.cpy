*> The recipe store of the content library (docs/protocol/27-recipes-and-unlocks.md sections 1, 2, 3, 5.9 and 6.1;
*> docs/design/cobolcraft-standard-core.md section 5.7). EXTERNAL: every program that copies this book shares
*> the one record. RECIPES-LOAD (recipes.cob) fills it from a data tree and BUILTIN-RECIPES-LOAD
*> (builtin-recipes.cob) with the cobolcraft recipes; both fill the same row shape. Rows are in listing order
*> (23 section 3.4: path first, then namespace), the order that decides display ids and the first match
*> (27 section 6.1); a built-in row is in the order of core 5.7. Package-private.
*> Serializer ids are those of 27 section 1.1: 0 crafting_shaped, 1 crafting_shapeless, 2 crafting_dye,
*> 3 crafting_imbue, 4 crafting_transmute, 5 crafting_decorated_pot, 6 bookcloning, 7 mapextending,
*> 8 firework_rocket, 9 firework_star, 10 firework_star_fade, 11 bannerduplicate, 12 shielddecoration,
*> 13 repairitem, 14 smelting, 15 blasting, 16 smoking, 17 campfire_cooking, 18 stonecutting,
*> 19 smithing_transform, 20 brewing, 21 smithing_trim.
*> RR-ING holds the ingredient slots in the order of the serializer's fields (27 section 2.1): a shaped
*> recipe holds the cells of its trimmed pattern row by row (RR-WIDTH x RR-HEIGHT, an empty cell is spaces), a
*> shapeless recipe its ingredients in order, any other recipe its ingredient fields in the order of
*> RECIPE-TYPE-AT. An ingredient is the text of its item ids or "#tag" references separated by single spaces
*> (27 1.3). RR-UNLOCK-FIRST and RR-UNLOCK-N select the entries of RC-UNLOCK that belong to the recipe: the
*> criteria of its recipe advancement other than recipe_unlocked (27 5.9), each a trigger and, for
*> inventory_changed, the item predicates (ids of one predicate separated by spaces, predicates by " & ").
 78 RC-MAX-RECIPES         VALUE 4096.
 78 RC-MAX-UNLOCKS         VALUE 4096.
 01 RC-STORE EXTERNAL.
    05 RC-COUNT              BINARY-LONG.
    05 RC-UNLOCK-COUNT       BINARY-LONG.
    05 RC-ROW OCCURS 4096 TIMES.
       10 RR-KEY             PIC X(64).
       10 RR-SERIALIZER      BINARY-LONG.
       10 RR-SPECIAL         BINARY-LONG.
       10 RR-GROUP           PIC X(48).
       10 RR-CATEGORY        PIC X(24).
       10 RR-NOTIFY          BINARY-LONG.
       10 RR-RESULT-ID       PIC X(64).
       10 RR-RESULT-COUNT    BINARY-LONG.
       10 RR-WIDTH           BINARY-LONG.
       10 RR-HEIGHT          BINARY-LONG.
       10 RR-ING-COUNT       BINARY-LONG.
       10 RR-ING             PIC X(160) OCCURS 9 TIMES.
       10 RR-MATERIAL-MIN    BINARY-LONG.
       10 RR-MATERIAL-MAX    BINARY-LONG.
       10 RR-ADD-COUNT       BINARY-LONG.
       10 RR-COOK-TIME       BINARY-LONG.
       10 RR-EXPERIENCE      FLOAT-LONG.
       10 RR-EXTRA           PIC X(64).
       10 RR-UNLOCK-FIRST    BINARY-LONG.
       10 RR-UNLOCK-N        BINARY-LONG.
    05 RC-UNLOCK OCCURS 4096 TIMES.
       10 RU-TRIGGER         PIC X(40).
       10 RU-ITEMS           PIC X(200).
