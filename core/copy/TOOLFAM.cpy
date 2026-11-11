*> The wood and copper families of the block transformers (17 section 3.1): the ten woods that have logs and woods, and the 15 copper
*> families of axe.json and honeycomb (family 1 is the copper block, named copper_block plain and "copper" with an oxidation prefix;
*> families 14 and 15 are the chest and the door, which do not update from neighbours).
 78 TF-WOODS               VALUE 10.
 78 TF-FAMILIES            VALUE 15.
 01 TF-WOOD-TABLE.
    05 FILLER              PIC X(12) VALUE "oak".
    05 FILLER              PIC X(12) VALUE "dark_oak".
    05 FILLER              PIC X(12) VALUE "pale_oak".
    05 FILLER              PIC X(12) VALUE "poplar".
    05 FILLER              PIC X(12) VALUE "acacia".
    05 FILLER              PIC X(12) VALUE "cherry".
    05 FILLER              PIC X(12) VALUE "birch".
    05 FILLER              PIC X(12) VALUE "jungle".
    05 FILLER              PIC X(12) VALUE "spruce".
    05 FILLER              PIC X(12) VALUE "mangrove".
 01 TF-WOODS-R REDEFINES TF-WOOD-TABLE.
    05 TF-WOOD             PIC X(12) OCCURS 10 TIMES.
 01 TF-FAMILY-TABLE.
    05 FILLER              PIC X(24) VALUE "copper".
    05 FILLER              PIC X(24) VALUE "cut_copper".
    05 FILLER              PIC X(24) VALUE "cut_copper_slab".
    05 FILLER              PIC X(24) VALUE "cut_copper_stairs".
    05 FILLER              PIC X(24) VALUE "chiseled_copper".
    05 FILLER              PIC X(24) VALUE "copper_trapdoor".
    05 FILLER              PIC X(24) VALUE "copper_bars".
    05 FILLER              PIC X(24) VALUE "copper_grate".
    05 FILLER              PIC X(24) VALUE "copper_bulb".
    05 FILLER              PIC X(24) VALUE "copper_chain".
    05 FILLER              PIC X(24) VALUE "copper_lantern".
    05 FILLER              PIC X(24) VALUE "copper_golem_statue".
    05 FILLER              PIC X(24) VALUE "lightning_rod".
    05 FILLER              PIC X(24) VALUE "copper_chest".
    05 FILLER              PIC X(24) VALUE "copper_door".
 01 TF-FAMILIES-R REDEFINES TF-FAMILY-TABLE.
    05 TF-FAMILY           PIC X(24) OCCURS 15 TIMES.
