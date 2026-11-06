*> Block and block-state tables (standin-content §1.1, §1.2), transcribed; never edit values here
*> without changing docs/design/standin-content.md first. Tested by core/tests/test_content_tables.cob.
*> Index both tables by (id + 1): BL-ENTRY (block id + 1), SB-ENTRY (state id + 1).

*> Block ids (§1.1, registration order).
 78 BLK-VOID                  VALUE 0.
 78 BLK-BASEPLATE             VALUE 1.
 78 BLK-GREYSTONE             VALUE 2.
 78 BLK-LOAM                  VALUE 3.
 78 BLK-TURF                  VALUE 4.
 78 BLK-GRIT                  VALUE 5.
 78 BLK-CARDSTACK             VALUE 6.
 78 BLK-LUCITE                VALUE 7.
 78 BLK-GLOWTUBE              VALUE 8.
 78 BLK-LEDGER-TILE           VALUE 9.
 78 BLK-GOTO-PAD              VALUE 10.
 78 BLK-SLAG                  VALUE 11.
 78 BLOCK-COUNT               VALUE 12.

*> Block state ids (§1.2).
 78 ST-VOID                   VALUE 0.
 78 ST-BASEPLATE              VALUE 1.
 78 ST-GREYSTONE              VALUE 2.
 78 ST-LOAM                   VALUE 3.
 78 ST-TURF                   VALUE 4.
 78 ST-GRIT                   VALUE 5.
 78 ST-CARDSTACK-X-PUNCHED    VALUE 6.
 78 ST-CARDSTACK-X            VALUE 7.
 78 ST-CARDSTACK-Y-PUNCHED    VALUE 8.
 78 ST-CARDSTACK-Y            VALUE 9.
 78 ST-CARDSTACK-Z-PUNCHED    VALUE 10.
 78 ST-CARDSTACK-Z            VALUE 11.
 78 ST-LUCITE                 VALUE 12.
 78 ST-GLOWTUBE-LIT           VALUE 13.
 78 ST-GLOWTUBE-UNLIT         VALUE 14.
 78 ST-LEDGER-TILE            VALUE 15.
 78 ST-GOTO-PAD               VALUE 16.
 78 ST-SLAG                   VALUE 17.
 78 BLOCK-STATE-COUNT         VALUE 18.
*> Global (direct) palette widths: ceillog2(18) block states (§1.2), ceillog2(3) biomes (§4.3).
 78 BLOCK-PALETTE-BITS        VALUE 5.
 78 BIOME-PALETTE-BITS        VALUE 2.

*> Biome ids (§4.3): plains is our "lowland".
 78 BIOME-PLAINS              VALUE 0.
 78 BIOME-UPLAND              VALUE 1.
 78 BIOME-ASH-FLATS           VALUE 2.

*> Tool classes of a block (§1.1 "Hard"/"Soft"; §2: pry_bar serves hard, trowel serves soft).
 78 BLOCK-CLASS-NONE          VALUE 0.
 78 BLOCK-CLASS-HARD          VALUE 1.
 78 BLOCK-CLASS-SOFT          VALUE 2.
*> Hand break time in milliseconds: -1 unbreakable, 0 not applicable (void).
 78 BREAK-UNBREAKABLE         VALUE -1.

*> Block table (§1.1). Light is the light emitted by the default state.
 01 BLOCK-DATA.
    05 FILLER.                                  *> block 0
       10 FILLER PIC X(32) VALUE "cobolcraft:void".
       10 FILLER BINARY-LONG VALUE 15.          *> key length
       10 FILLER BINARY-LONG VALUE 0.           *> solid
       10 FILLER BINARY-LONG VALUE 0.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER BINARY-LONG VALUE 0.           *> hand break ms
       10 FILLER BINARY-LONG VALUE 0.           *> class
       10 FILLER BINARY-LONG VALUE 0.           *> first state
       10 FILLER BINARY-LONG VALUE 1.           *> state count
       10 FILLER BINARY-LONG VALUE 0.           *> default state
    05 FILLER.                                  *> block 1
       10 FILLER PIC X(32) VALUE "cobolcraft:baseplate".
       10 FILLER BINARY-LONG VALUE 20.          *> key length
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER BINARY-LONG VALUE -1.          *> hand break ms
       10 FILLER BINARY-LONG VALUE 0.           *> class
       10 FILLER BINARY-LONG VALUE 1.           *> first state
       10 FILLER BINARY-LONG VALUE 1.           *> state count
       10 FILLER BINARY-LONG VALUE 1.           *> default state
    05 FILLER.                                  *> block 2
       10 FILLER PIC X(32) VALUE "cobolcraft:greystone".
       10 FILLER BINARY-LONG VALUE 20.          *> key length
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER BINARY-LONG VALUE 1500.        *> hand break ms
       10 FILLER BINARY-LONG VALUE 1.           *> class
       10 FILLER BINARY-LONG VALUE 2.           *> first state
       10 FILLER BINARY-LONG VALUE 1.           *> state count
       10 FILLER BINARY-LONG VALUE 2.           *> default state
    05 FILLER.                                  *> block 3
       10 FILLER PIC X(32) VALUE "cobolcraft:loam".
       10 FILLER BINARY-LONG VALUE 15.          *> key length
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER BINARY-LONG VALUE 600.         *> hand break ms
       10 FILLER BINARY-LONG VALUE 2.           *> class
       10 FILLER BINARY-LONG VALUE 3.           *> first state
       10 FILLER BINARY-LONG VALUE 1.           *> state count
       10 FILLER BINARY-LONG VALUE 3.           *> default state
    05 FILLER.                                  *> block 4
       10 FILLER PIC X(32) VALUE "cobolcraft:turf".
       10 FILLER BINARY-LONG VALUE 15.          *> key length
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER BINARY-LONG VALUE 700.         *> hand break ms
       10 FILLER BINARY-LONG VALUE 2.           *> class
       10 FILLER BINARY-LONG VALUE 4.           *> first state
       10 FILLER BINARY-LONG VALUE 1.           *> state count
       10 FILLER BINARY-LONG VALUE 4.           *> default state
    05 FILLER.                                  *> block 5
       10 FILLER PIC X(32) VALUE "cobolcraft:grit".
       10 FILLER BINARY-LONG VALUE 15.          *> key length
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER BINARY-LONG VALUE 500.         *> hand break ms
       10 FILLER BINARY-LONG VALUE 2.           *> class
       10 FILLER BINARY-LONG VALUE 5.           *> first state
       10 FILLER BINARY-LONG VALUE 1.           *> state count
       10 FILLER BINARY-LONG VALUE 5.           *> default state
    05 FILLER.                                  *> block 6
       10 FILLER PIC X(32) VALUE "cobolcraft:cardstack".
       10 FILLER BINARY-LONG VALUE 20.          *> key length
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER BINARY-LONG VALUE 1000.        *> hand break ms
       10 FILLER BINARY-LONG VALUE 1.           *> class
       10 FILLER BINARY-LONG VALUE 6.           *> first state
       10 FILLER BINARY-LONG VALUE 6.           *> state count
       10 FILLER BINARY-LONG VALUE 9.           *> default state
    05 FILLER.                                  *> block 7
       10 FILLER PIC X(32) VALUE "cobolcraft:lucite".
       10 FILLER BINARY-LONG VALUE 17.          *> key length
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 0.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER BINARY-LONG VALUE 400.         *> hand break ms
       10 FILLER BINARY-LONG VALUE 0.           *> class
       10 FILLER BINARY-LONG VALUE 12.          *> first state
       10 FILLER BINARY-LONG VALUE 1.           *> state count
       10 FILLER BINARY-LONG VALUE 12.          *> default state
    05 FILLER.                                  *> block 8
       10 FILLER PIC X(32) VALUE "cobolcraft:glowtube".
       10 FILLER BINARY-LONG VALUE 19.          *> key length
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 15.          *> light
       10 FILLER BINARY-LONG VALUE 300.         *> hand break ms
       10 FILLER BINARY-LONG VALUE 0.           *> class
       10 FILLER BINARY-LONG VALUE 13.          *> first state
       10 FILLER BINARY-LONG VALUE 2.           *> state count
       10 FILLER BINARY-LONG VALUE 13.          *> default state
    05 FILLER.                                  *> block 9
       10 FILLER PIC X(32) VALUE "cobolcraft:ledger_tile".
       10 FILLER BINARY-LONG VALUE 22.          *> key length
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER BINARY-LONG VALUE 1200.        *> hand break ms
       10 FILLER BINARY-LONG VALUE 1.           *> class
       10 FILLER BINARY-LONG VALUE 15.          *> first state
       10 FILLER BINARY-LONG VALUE 1.           *> state count
       10 FILLER BINARY-LONG VALUE 15.          *> default state
    05 FILLER.                                  *> block 10
       10 FILLER PIC X(32) VALUE "cobolcraft:goto_pad".
       10 FILLER BINARY-LONG VALUE 19.          *> key length
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 6.           *> light
       10 FILLER BINARY-LONG VALUE 2000.        *> hand break ms
       10 FILLER BINARY-LONG VALUE 0.           *> class
       10 FILLER BINARY-LONG VALUE 16.          *> first state
       10 FILLER BINARY-LONG VALUE 1.           *> state count
       10 FILLER BINARY-LONG VALUE 16.          *> default state
    05 FILLER.                                  *> block 11
       10 FILLER PIC X(32) VALUE "cobolcraft:slag".
       10 FILLER BINARY-LONG VALUE 15.          *> key length
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER BINARY-LONG VALUE 1200.        *> hand break ms
       10 FILLER BINARY-LONG VALUE 1.           *> class
       10 FILLER BINARY-LONG VALUE 17.          *> first state
       10 FILLER BINARY-LONG VALUE 1.           *> state count
       10 FILLER BINARY-LONG VALUE 17.          *> default state
 01 BLOCK-TABLE REDEFINES BLOCK-DATA.
    05 BL-ENTRY OCCURS 12 TIMES.
       10 BL-KEY                PIC X(32).
       10 BL-KEY-LENGTH         BINARY-LONG.
       10 BL-SOLID              BINARY-LONG.
       10 BL-OPAQUE             BINARY-LONG.
       10 BL-LIGHT              BINARY-LONG.
       10 BL-BREAK-MS           BINARY-LONG.
       10 BL-CLASS              BINARY-LONG.
       10 BL-FIRST-STATE        BINARY-LONG.
       10 BL-STATE-COUNT        BINARY-LONG.
       10 BL-DEFAULT-STATE      BINARY-LONG.

*> Block-state table (§1.2). SB-PROPS is the property values as text ("name=value,..." in sorted
*> name order, spaces when none). SB-AXIS: 0 x, 1 y, 2 z; SB-PUNCHED and SB-LIT: 1 true, 0 false;
*> -1 where the block has no such property. SB-LIGHT: lit glowtube 15, unlit 0, goto_pad 6 (§1.1, §5.2).
 01 BLOCK-STATE-DATA.
    05 FILLER.                                  *> state 0
       10 FILLER BINARY-LONG VALUE 0.           *> block
       10 FILLER BINARY-LONG VALUE 0.           *> solid
       10 FILLER BINARY-LONG VALUE 0.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER PIC X(24) VALUE SPACES.        *> properties
       10 FILLER BINARY-LONG VALUE -1.          *> axis
       10 FILLER BINARY-LONG VALUE -1.          *> punched
       10 FILLER BINARY-LONG VALUE -1.          *> lit
    05 FILLER.                                  *> state 1
       10 FILLER BINARY-LONG VALUE 1.           *> block
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER PIC X(24) VALUE SPACES.        *> properties
       10 FILLER BINARY-LONG VALUE -1.          *> axis
       10 FILLER BINARY-LONG VALUE -1.          *> punched
       10 FILLER BINARY-LONG VALUE -1.          *> lit
    05 FILLER.                                  *> state 2
       10 FILLER BINARY-LONG VALUE 2.           *> block
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER PIC X(24) VALUE SPACES.        *> properties
       10 FILLER BINARY-LONG VALUE -1.          *> axis
       10 FILLER BINARY-LONG VALUE -1.          *> punched
       10 FILLER BINARY-LONG VALUE -1.          *> lit
    05 FILLER.                                  *> state 3
       10 FILLER BINARY-LONG VALUE 3.           *> block
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER PIC X(24) VALUE SPACES.        *> properties
       10 FILLER BINARY-LONG VALUE -1.          *> axis
       10 FILLER BINARY-LONG VALUE -1.          *> punched
       10 FILLER BINARY-LONG VALUE -1.          *> lit
    05 FILLER.                                  *> state 4
       10 FILLER BINARY-LONG VALUE 4.           *> block
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER PIC X(24) VALUE SPACES.        *> properties
       10 FILLER BINARY-LONG VALUE -1.          *> axis
       10 FILLER BINARY-LONG VALUE -1.          *> punched
       10 FILLER BINARY-LONG VALUE -1.          *> lit
    05 FILLER.                                  *> state 5
       10 FILLER BINARY-LONG VALUE 5.           *> block
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER PIC X(24) VALUE SPACES.        *> properties
       10 FILLER BINARY-LONG VALUE -1.          *> axis
       10 FILLER BINARY-LONG VALUE -1.          *> punched
       10 FILLER BINARY-LONG VALUE -1.          *> lit
    05 FILLER.                                  *> state 6
       10 FILLER BINARY-LONG VALUE 6.           *> block
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER PIC X(24) VALUE "axis=x,punched=true".*> properties
       10 FILLER BINARY-LONG VALUE 0.           *> axis
       10 FILLER BINARY-LONG VALUE 1.           *> punched
       10 FILLER BINARY-LONG VALUE -1.          *> lit
    05 FILLER.                                  *> state 7
       10 FILLER BINARY-LONG VALUE 6.           *> block
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER PIC X(24) VALUE "axis=x,punched=false".*> properties
       10 FILLER BINARY-LONG VALUE 0.           *> axis
       10 FILLER BINARY-LONG VALUE 0.           *> punched
       10 FILLER BINARY-LONG VALUE -1.          *> lit
    05 FILLER.                                  *> state 8
       10 FILLER BINARY-LONG VALUE 6.           *> block
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER PIC X(24) VALUE "axis=y,punched=true".*> properties
       10 FILLER BINARY-LONG VALUE 1.           *> axis
       10 FILLER BINARY-LONG VALUE 1.           *> punched
       10 FILLER BINARY-LONG VALUE -1.          *> lit
    05 FILLER.                                  *> state 9
       10 FILLER BINARY-LONG VALUE 6.           *> block
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER PIC X(24) VALUE "axis=y,punched=false".*> properties
       10 FILLER BINARY-LONG VALUE 1.           *> axis
       10 FILLER BINARY-LONG VALUE 0.           *> punched
       10 FILLER BINARY-LONG VALUE -1.          *> lit
    05 FILLER.                                  *> state 10
       10 FILLER BINARY-LONG VALUE 6.           *> block
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER PIC X(24) VALUE "axis=z,punched=true".*> properties
       10 FILLER BINARY-LONG VALUE 2.           *> axis
       10 FILLER BINARY-LONG VALUE 1.           *> punched
       10 FILLER BINARY-LONG VALUE -1.          *> lit
    05 FILLER.                                  *> state 11
       10 FILLER BINARY-LONG VALUE 6.           *> block
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER PIC X(24) VALUE "axis=z,punched=false".*> properties
       10 FILLER BINARY-LONG VALUE 2.           *> axis
       10 FILLER BINARY-LONG VALUE 0.           *> punched
       10 FILLER BINARY-LONG VALUE -1.          *> lit
    05 FILLER.                                  *> state 12
       10 FILLER BINARY-LONG VALUE 7.           *> block
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 0.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER PIC X(24) VALUE SPACES.        *> properties
       10 FILLER BINARY-LONG VALUE -1.          *> axis
       10 FILLER BINARY-LONG VALUE -1.          *> punched
       10 FILLER BINARY-LONG VALUE -1.          *> lit
    05 FILLER.                                  *> state 13
       10 FILLER BINARY-LONG VALUE 8.           *> block
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 15.          *> light
       10 FILLER PIC X(24) VALUE "lit=true".    *> properties
       10 FILLER BINARY-LONG VALUE -1.          *> axis
       10 FILLER BINARY-LONG VALUE -1.          *> punched
       10 FILLER BINARY-LONG VALUE 1.           *> lit
    05 FILLER.                                  *> state 14
       10 FILLER BINARY-LONG VALUE 8.           *> block
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER PIC X(24) VALUE "lit=false".   *> properties
       10 FILLER BINARY-LONG VALUE -1.          *> axis
       10 FILLER BINARY-LONG VALUE -1.          *> punched
       10 FILLER BINARY-LONG VALUE 0.           *> lit
    05 FILLER.                                  *> state 15
       10 FILLER BINARY-LONG VALUE 9.           *> block
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER PIC X(24) VALUE SPACES.        *> properties
       10 FILLER BINARY-LONG VALUE -1.          *> axis
       10 FILLER BINARY-LONG VALUE -1.          *> punched
       10 FILLER BINARY-LONG VALUE -1.          *> lit
    05 FILLER.                                  *> state 16
       10 FILLER BINARY-LONG VALUE 10.          *> block
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 6.           *> light
       10 FILLER PIC X(24) VALUE SPACES.        *> properties
       10 FILLER BINARY-LONG VALUE -1.          *> axis
       10 FILLER BINARY-LONG VALUE -1.          *> punched
       10 FILLER BINARY-LONG VALUE -1.          *> lit
    05 FILLER.                                  *> state 17
       10 FILLER BINARY-LONG VALUE 11.          *> block
       10 FILLER BINARY-LONG VALUE 1.           *> solid
       10 FILLER BINARY-LONG VALUE 1.           *> opaque
       10 FILLER BINARY-LONG VALUE 0.           *> light
       10 FILLER PIC X(24) VALUE SPACES.        *> properties
       10 FILLER BINARY-LONG VALUE -1.          *> axis
       10 FILLER BINARY-LONG VALUE -1.          *> punched
       10 FILLER BINARY-LONG VALUE -1.          *> lit
 01 BLOCK-STATE-TABLE REDEFINES BLOCK-STATE-DATA.
    05 SB-ENTRY OCCURS 18 TIMES.
       10 SB-BLOCK              BINARY-LONG.
       10 SB-SOLID              BINARY-LONG.
       10 SB-OPAQUE             BINARY-LONG.
       10 SB-LIGHT              BINARY-LONG.
       10 SB-PROPS              PIC X(24).
       10 SB-AXIS               BINARY-LONG.
       10 SB-PUNCHED            BINARY-LONG.
       10 SB-LIT                BINARY-LONG.
