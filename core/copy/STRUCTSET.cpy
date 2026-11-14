*> The placement settings of a template (docs/protocol/36-structures-2 section 4.1, StructurePlaceSettings), passed to STRUCT-PLACE and STRUCT-FILTER-BLOCKS.
*> Mirror codes 0 NONE, 1 LEFT_RIGHT, 2 FRONT_BACK; rotation codes 0 NONE, 1 CLOCKWISE_90, 2 CLOCKWISE_180, 3 COUNTERCLOCKWISE_90 (the codes of struct-36-2.cob).
*> PS-LIQUID 0 APPLY_WATERLOGGING (the default), 1 IGNORE_WATERLOGGING. PS-BOX is the bounding box (min x, y, z, max x, y, z) when PS-BOX-SET is 1: in a chunk it is
*> the window the piece may write. PS-RANDOM-SET 1 gives the settings a shared random: PS-RANDOM is its java.util.Random state (rng-java.cob), consumed by every
*> getRandom(pos) call; with 0 each call is a new source seeded with Mth.getSeed(pos) (4.2). PS-PROCESSORS is the index of a compiled processor list (STRUCT-PROC-LOAD),
*> 0 for none. PS-SEED is the level seed (the `capped` processor seeds a source from it, 9.4). The palette field of the settings is never read (4.1) and is not kept.
 01 STRUCT-SETTINGS.
    05 PS-MIRROR            BINARY-LONG.
    05 PS-ROTATION          BINARY-LONG.
    05 PS-PIVOT-X           BINARY-LONG.
    05 PS-PIVOT-Z           BINARY-LONG.
    05 PS-IGNORE-ENTITIES   BINARY-LONG.
    05 PS-BOX-SET           BINARY-LONG.
    05 PS-BOX               BINARY-LONG OCCURS 6 TIMES.
    05 PS-LIQUID            BINARY-LONG.
    05 PS-KNOWN-SHAPE       BINARY-LONG.
    05 PS-FINALIZE          BINARY-LONG.
    05 PS-RANDOM-SET        BINARY-LONG.
    05 PS-RANDOM            BINARY-DOUBLE UNSIGNED.
    05 PS-PROCESSORS        BINARY-LONG.
    05 PS-SEED              BINARY-DOUBLE.
