*> The plant rules simple_block asks (core/src/feat-veg.cob FR-SURV-OPEN builds them from the block table and the tags once per table epoch; docs/protocol/24 part 2 table 7.2, 24 part 4
*> 5.4 and 6.14). EXTERNAL, indexed by the 1-based block number of CORE-BLOCKS. FS-RULE 0 no rule (the block stands on any block), 1 the block below is in supports_vegetation, 2 in
*> supports_dry_vegetation, 3 mushroom, 4 lily pad, 5 seagrass. FS-UPPER the state of the upper half of a double plant (0 for a single block). FS-SUP bit values 1 supports_vegetation,
*> 2 supports_dry_vegetation, 4 overrides_mushroom_light_requirement, 8 supports_lily_pad, 16 cannot_support_seagrass: the tags of the block below.
 01 FEAT-SURV EXTERNAL.
    05 FS-EPOCH             BINARY-LONG.
    05 FS-BLOCK OCCURS 1400 TIMES.
       10 FS-RULE           BINARY-LONG.
       10 FS-UPPER          BINARY-LONG.
       10 FS-SUP            BINARY-LONG.
