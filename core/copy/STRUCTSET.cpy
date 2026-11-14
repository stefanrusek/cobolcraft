*> The placement settings of a template (docs/protocol/36-structures-2 section 4.1, StructurePlaceSettings), passed to STRUCT-PLACE and STRUCT-FILTER-BLOCKS.
*> Mirror codes 0 NONE, 1 LEFT_RIGHT, 2 FRONT_BACK; rotation codes 0 NONE, 1 CLOCKWISE_90, 2 CLOCKWISE_180, 3 COUNTERCLOCKWISE_90 (the codes of struct-36-2.cob).
*> ST-LIQUID 0 APPLY_WATERLOGGING (the default), 1 IGNORE_WATERLOGGING. ST-BOX is the bounding box (min x, y, z, max x, y, z) when ST-BOX-SET is 1: in a chunk it is
*> the window the piece may write. ST-RANDOM-SET 1 gives the settings a shared random: ST-RANDOM is its java.util.Random state (rng-java.cob), consumed by every
*> getRandom(pos) call; with 0 each call is a new source seeded with Mth.getSeed(pos) (4.2). ST-PROCESSORS is the index of a compiled processor list (STRUCT-PROC-LOAD),
*> 0 for none. ST-SEED is the level seed (the `capped` processor seeds a source from it, 9.4). The palette field of the settings is never read (4.1) and is not kept.
 01 STRUCT-SETTINGS.
    05 ST-MIRROR            BINARY-LONG.
    05 ST-ROTATION          BINARY-LONG.
    05 ST-PIVOT-X           BINARY-LONG.
    05 ST-PIVOT-Z           BINARY-LONG.
    05 ST-IGNORE-ENTITIES   BINARY-LONG.
    05 ST-BOX-SET           BINARY-LONG.
    05 ST-BOX               BINARY-LONG OCCURS 6 TIMES.
    05 ST-LIQUID            BINARY-LONG.
    05 ST-KNOWN-SHAPE       BINARY-LONG.
    05 ST-FINALIZE          BINARY-LONG.
    05 ST-RANDOM-SET        BINARY-LONG.
    05 ST-RANDOM            BINARY-DOUBLE UNSIGNED.
    05 ST-PROCESSORS        BINARY-LONG.
    05 ST-SEED              BINARY-DOUBLE.
