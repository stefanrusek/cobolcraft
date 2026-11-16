*> Structure spawn overrides (docs/protocol/44-residual-mob-questions-2-spawning-structures.md section 8; core/src/struct-override.cob). EXTERNAL, memory of the game process.
*> SO-REG is the registry of the boxes a generated chunk was told about (GENT-APPLY): per record the dimension, the chunk, the kind of structure and one box that intersects the chunk (a
*> `piece` structure registers each piece box, a `full` one its start's overall box). A full registry overwrites the oldest record (SO-NEXT). Kinds: 1 fortress (piece), 2 monument (full),
*> 3 pillager outpost (full), 4 swamp hut (piece), 5 ancient city (full), 6 trial chambers (piece), 7 the whole box of a fortress (the hardcoded rule of 8.1 step 1, on nether bricks).
*> SO-LIST is the table of override lists: a kind, a category (1 monster, 2 creature, 3 ambient, 4 axolotls, 5 underground water creature, 6 water creature, 7 water ambient; 0 every
*> category) and the entries SO-L-FIRST + 1 to SO-L-FIRST + SO-L-COUNT of SO-ENTRY (species key without namespace, weight, count minimum and maximum); a list of no entries removes
*> every natural spawn of its category inside the box.
 78 SO-MAX                VALUE 2048.
 78 SO-LISTS              VALUE 10.
 78 SO-ENTRIES            VALUE 9.
 01 STRUCT-OVERRIDE EXTERNAL.
    05 SO-COUNT            BINARY-LONG.
    05 SO-NEXT             BINARY-LONG.
    05 SO-REG OCCURS 2048 TIMES.
       10 SO-DIM           BINARY-LONG.
       10 SO-CX            BINARY-LONG.
       10 SO-CZ            BINARY-LONG.
       10 SO-KIND          BINARY-LONG.
       10 SO-BOX           BINARY-LONG OCCURS 6 TIMES.
 01 SO-LIST-DATA.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 5.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 5.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 3.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 8.
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
 01 SO-LIST-TABLE REDEFINES SO-LIST-DATA.
    05 SO-LIST OCCURS 10 TIMES.
       10 SO-L-KIND        BINARY-LONG.
       10 SO-L-CAT         BINARY-LONG.
       10 SO-L-FIRST       BINARY-LONG.
       10 SO-L-COUNT       BINARY-LONG.
 01 SO-ENTRY-DATA.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "blaze".
       10 FILLER BINARY-LONG VALUE 10.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 3.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "zombified_piglin".
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE 4.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "wither_skeleton".
       10 FILLER BINARY-LONG VALUE 8.
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER BINARY-LONG VALUE 5.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "skeleton".
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER BINARY-LONG VALUE 5.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "magma_cube".
       10 FILLER BINARY-LONG VALUE 3.
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE 4.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "guardian".
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 4.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "pillager".
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "witch".
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.
       10 FILLER PIC X(24) VALUE "cat".
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
 01 SO-ENTRY-TABLE REDEFINES SO-ENTRY-DATA.
    05 SO-ENTRY OCCURS 9 TIMES.
       10 SO-E-KEY         PIC X(24).
       10 SO-E-WEIGHT      BINARY-LONG.
       10 SO-E-MIN         BINARY-LONG.
       10 SO-E-MAX         BINARY-LONG.
