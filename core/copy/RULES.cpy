*> Player rules (standin-content §10.1, §11.1), transcribed. Tested by core/tests/test_content_tables.cob.
*> Maximum health (§10.1): health is a whole number 0..30; new and respawned players have 30.
 78 RULE-MAX-HEALTH           VALUE 30.
*> Maximum food level (§11.1): food is a whole number 0..24; new and respawned players have 24.
 78 RULE-MAX-FOOD             VALUE 24.
*> Day length (§4.8): the time of day runs 0..29999, advancing 1 per tick and wrapping to 0.
 78 RULE-DAY-LENGTH           VALUE 30000.
*> Ground items (§9; §1.3 block yields; data-model §5). Lengths, speeds and factors are integer
*> THOUSANDTHS (0.035 -> 35), as in ENTITYTYPES.cpy; times are ticks.
*> Pickup delay of a new ground item (§9.1): a survival block break or a mob defeat 6, a throw 30.
 78 RULE-GI-BREAK-DELAY       VALUE 6.
 78 RULE-GI-THROW-DELAY       VALUE 30.
*> Block yield position (§1.3, §9.1): (x + 0.5, y + 0.25, z + 0.5) of the broken block at (x, y, z).
 78 RULE-GI-BREAK-DXZ-MILLI   VALUE 500.
 78 RULE-GI-BREAK-DY-MILLI    VALUE 250.
*> Throw (§9.1): from the thrower's feet + (0, 1.3, 0); motion mx = -sin(yaw) cos(pitch) x 0.25,
*> my = -sin(pitch) x 0.25 + 0.12, mz = cos(yaw) cos(pitch) x 0.25 blocks per tick; no spread.
 78 RULE-GI-THROW-DY-MILLI    VALUE 1300.
 78 RULE-GI-THROW-SPEED-MILLI VALUE 250.
 78 RULE-GI-THROW-LIFT-MILLI  VALUE 120.
*> Age (§9.2 step 2): it advances only while a player of the dimension is within 32.0 blocks (3D
*> Euclidean distance between positions); at 4800 the item despawns.
 78 RULE-GI-NEAR-MILLI        VALUE 32000.
 78 RULE-GI-DESPAWN-AGE       VALUE 4800.
*> Movement (§9.2 step 3): gravity 0.035 per tick, drag factor 0.97 per tick.
 78 RULE-GI-GRAVITY-MILLI     VALUE 35.
 78 RULE-GI-DRAG-MILLI        VALUE 970.
*> Pickup range (§9.3): the player's box expanded by 0.75 in x and z and by 0.25 in y.
 78 RULE-GI-REACH-XZ-MILLI    VALUE 750.
 78 RULE-GI-REACH-Y-MILLI     VALUE 250.
*> Merging (§9.2): ground items never merge (0 = never).
 78 RULE-GI-MERGES            VALUE 0.
*> Block yields (§1.3): the item of a block broken in survival, by block id (index block id + 1);
*> 0 = no yield (void; the baseplate is never broken). Block 2-9 -> item 2-9, goto_pad (10) -> 16,
*> slag (11) -> 17.
 01 RULE-YIELD-DATA.
    05 FILLER BINARY-LONG VALUE 0.              *> void
    05 FILLER BINARY-LONG VALUE 0.              *> baseplate
    05 FILLER BINARY-LONG VALUE 2.              *> greystone
    05 FILLER BINARY-LONG VALUE 3.              *> loam
    05 FILLER BINARY-LONG VALUE 4.              *> turf
    05 FILLER BINARY-LONG VALUE 5.              *> grit
    05 FILLER BINARY-LONG VALUE 6.              *> cardstack
    05 FILLER BINARY-LONG VALUE 7.              *> lucite
    05 FILLER BINARY-LONG VALUE 8.              *> glowtube
    05 FILLER BINARY-LONG VALUE 9.              *> ledger_tile
    05 FILLER BINARY-LONG VALUE 16.             *> goto_pad
    05 FILLER BINARY-LONG VALUE 17.             *> slag
 01 RULE-YIELD-TABLE REDEFINES RULE-YIELD-DATA.
    05 RULE-YIELD-ITEM BINARY-LONG OCCURS 12 TIMES.
