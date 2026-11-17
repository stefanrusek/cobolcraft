*> The support rules of the blocks that need something to stand on or hang from (core/src/support-29.cob SUP-OPEN builds them from the block table, its keys and tags once per table epoch;
*> lane bugsw T10305; docs/protocol/29 sections 3.2 and 9.5, 24 part 2). EXTERNAL, indexed by the 1-based block number of CORE-BLOCKS. SP-RULE 0 none (the block stands anywhere),
*> 1 vegetation (the block below is in supports_vegetation), 2 dry vegetation, 3 mushroom, 4 lily pad, 5 seagrass, 6 sea pickle, 7 tall seagrass, 8 snow layer, 9 sugar cane, 10 cactus,
*> 11 kelp and kelp plant, 12 bamboo, 13 double plant (SP-ARG the rule of its lower half), 14 stands on a solid block, 15 hangs on the solid block behind its facing, 16 button or lever (face and facing),
*> 17 door. SP-SUP are the bits of the tags the block holds as a support (as a block below): 1 supports_vegetation, 2 supports_dry_vegetation, 4 overrides_mushroom_light_requirement,
*> 8 supports_lily_pad, 16 cannot_support_seagrass, 32 cannot_support_snow_layer, 64 support_override_snow_layer, 128 supports_sugar_cane, 256 supports_sugar_cane_adjacently,
*> 512 supports_cactus, 1024 cannot_support_kelp, 2048 supports_bamboo, 4096 fences and walls (stand-on blocks that are not full).
 01 SUP-STATE EXTERNAL.
    05 SP-EPOCH             BINARY-LONG.
    05 SP-WATER             BINARY-LONG.
    05 SP-BLOCK OCCURS 1400 TIMES.
       10 SP-RULE           BINARY-LONG.
       10 SP-ARG            BINARY-LONG.
       10 SP-SUP            BINARY-LONG.
