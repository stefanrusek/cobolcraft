*> The core's numeric block tables, built from the open content set by BLOCKS-OPEN (core/src/block-props.cob) when
*> a world opens; EXTERNAL, so every core program that COPYs this book sees the same tables. They replace the
*> stand-in tables of BLOCKS.cpy: both world types fill them from CONTENT-BLOCK-OF-STATE rows, tags and flags, so a
*> caller never tests the world type. Index CB-BLOCK by block id + 1 and CB-STATE by state id + 1.
*>
*> Derived from a content row (24 part 1 section 2; the rules are in block-props.cob):
*>   CB-SOLID    1 unless the flags hold noCollision or air.
*>   CB-OPAQUE   0 when the flags hold noOcclusion, noCollision or air, else 1 (until the light engine of 32).
*>   CB-BREAK-MS the hardness in milliseconds (hardness x 1000, rounded; -1 for a negative hardness = unbreakable; 0 none).
*>   CB-CLASS    tool class from the block tags: 1 minecraft:mineable/pickaxe, 2 minecraft:mineable/shovel, else 0.
*>   CB-LIGHT    the light the default state emits; CB-S-LIGHT is the light of each state: a plain number in the
*>               row's light text is that number for every state, "N ... if lit, else 0" is N where the state's
*>               property lit is true; any other text is 0 (the light engine of 32 will define the rest).
*> CB-EPOCH rises by one at every BLOCKS-OPEN, so a program that caches ids resolved from keys can tell.
 78 CB-MAX-BLOCKS         VALUE 1400.
 78 CB-MAX-STATES         VALUE 40000.
 01 CORE-BLOCKS EXTERNAL.
    05 CB-EPOCH              BINARY-LONG.
    05 CB-BLOCK-COUNT        BINARY-LONG.
    05 CB-STATE-COUNT        BINARY-LONG.
    05 CB-BLOCK OCCURS 1400 TIMES.
       10 CB-KEY             PIC X(48).
       10 CB-KEY-LENGTH      BINARY-LONG.
       10 CB-SOLID           BINARY-LONG.
       10 CB-OPAQUE          BINARY-LONG.
       10 CB-LIGHT           BINARY-LONG.
       10 CB-BREAK-MS        BINARY-LONG.
       10 CB-CLASS           BINARY-LONG.
       10 CB-FIRST-STATE     BINARY-LONG.
       10 CB-STATES          BINARY-LONG.
       10 CB-DEFAULT-STATE   BINARY-LONG.
    05 CB-STATE OCCURS 40000 TIMES.
       10 CB-S-BLOCK         BINARY-SHORT UNSIGNED.
       10 CB-S-LIGHT         BINARY-CHAR UNSIGNED.

*> Tool classes of CB-CLASS.
 78 CB-CLASS-NONE         VALUE 0.
 78 CB-CLASS-HARD         VALUE 1.
 78 CB-CLASS-SOFT         VALUE 2.

*> The blocks and states the rules of the cobolcraft content set name, resolved by key when BLOCKS-OPEN runs (block
*> ids -1 and states 0 when the open set has no such block, so a rule about it never fires in a standard world):
*> the cardstack (axis x, y or z, punched or not), the glowtube (lit, unlit), the goto_pad that starts travel, and the
*> terrain blocks of the cobolcraft generator.
 01 CORE-BLOCK-ROLES EXTERNAL.
    05 CR-CARDSTACK          BINARY-LONG.
    05 CR-GLOWTUBE           BINARY-LONG.
    05 CR-GOTO-PAD           BINARY-LONG.
    05 CR-CARDSTACK-X        BINARY-LONG.
    05 CR-CARDSTACK-Y        BINARY-LONG.
    05 CR-CARDSTACK-Z        BINARY-LONG.
    05 CR-CARDSTACK-Y-PUNCHED BINARY-LONG.
    05 CR-GLOWTUBE-LIT       BINARY-LONG.
    05 CR-GLOWTUBE-UNLIT     BINARY-LONG.
    05 CR-GOTO-PAD-STATE     BINARY-LONG.
    05 CR-BASEPLATE          BINARY-LONG.
    05 CR-GREYSTONE          BINARY-LONG.
    05 CR-LOAM               BINARY-LONG.
    05 CR-TURF               BINARY-LONG.
    05 CR-GRIT               BINARY-LONG.
    05 CR-LUCITE             BINARY-LONG.
    05 CR-SLAG               BINARY-LONG.

*> The biomes of the open set (registry minecraft:worldgen/biome), read by BLOCKS-OPEN from the entries' payloads: the key
*> (with namespace) and has_precipitation of each biome id (index = id + 1).
 78 CBI-MAX                VALUE 128.
 01 CORE-BIOMES EXTERNAL.
    05 CBI-COUNT             BINARY-LONG.
    05 CBI-BIOME OCCURS 128 TIMES.
       10 CBI-KEY            PIC X(48).
       10 CBI-KEY-LENGTH     BINARY-LONG.
       10 CBI-PRECIPITATION  BINARY-LONG.
