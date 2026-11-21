*> The flat generator settings of the open superflat world (docs/protocol/56-superflat-world.md section 2; core/src/flat-settings.cob).
*> EXTERNAL, so every program that COPYs this book sees the same record. They are filled when a superflat world opens (FLAT-SETTINGS-OPEN: the
*> preset a host chose with FLAT-PRESET-SET, else data/minecraft/world_gen_settings.dat of the folder, else the world preset `flat`), saved
*> with the world (FLAT-SETTINGS-SAVE) and used by the flat chunk generator (worldgen-flat.cob).
*>
*>   FS-LOADED       1 once the record holds settings (0 = none yet; the first user fills the default)
*>   FS-PENDING      1 while FLAT-PRESET-SET has chosen the settings for the world about to be created (consumed by FLAT-SETTINGS-OPEN)
*>   FS-GEN-STRUCT   the world option generate_structures of the file (56 section 4.7), 1 unless the file says 0
*>   FS-LAYER        the layers, bottom first (56 section 2.2): the block key (with minecraft:) and its height; at most 64 layers
*>   FS-BIOME        the biome id string (with minecraft:)
*>   FS-LAKES, FS-FEATURES the two flags (1 on)
*>   FS-OVR-MODE     0 = structure_overrides absent (every structure set), 1 = the listed sets (a list of none is mode 1, count 0)
*>   FS-OVR          the listed structure sets (with minecraft:)
*>   FS-TOTAL        the sum of the layer heights (at most 4064)
*>   FS-STAMP        CB-EPOCH of the block table the expanded layers below were built from; -1 = not built (FLAT-SETTINGS-PREPARE)
*>   FS-VOID         1 when every layer is air (56 section 2.4 voidGen)
*>   FS-KIND         per layer index i (index 1 = the lowest block, min y): 0 = null (the block does not satisfy MOTION_BLOCKING: air, a snow layer,
*>                   flowers; the terrain fill skips it and a fill_layer feature writes it, 56 section 4.4), 1 = a fluid, 2 = a block of the tag
*>                   blocks_motion_in_heightmap. Only the lowest 384 layers exist in the overworld (56 section 4.3)
*>   FS-STATE        the default state of the layer's block per layer index (0 for an unknown block)
 78 FS-MAX-LAYERS         VALUE 64.
 78 FS-MAX-OVERRIDES      VALUE 24.
 78 FS-MAX-STACK          VALUE 384.
 01 FLAT-SETTINGS EXTERNAL.
    05 FS-LOADED             BINARY-LONG.
    05 FS-PENDING            BINARY-LONG.
    05 FS-GEN-STRUCT         BINARY-LONG.
    05 FS-LAYER-COUNT        BINARY-LONG.
    05 FS-LAYER OCCURS 64 TIMES.
       10 FS-L-KEY           PIC X(48).
       10 FS-L-HEIGHT        BINARY-LONG.
    05 FS-BIOME              PIC X(48).
    05 FS-LAKES              BINARY-LONG.
    05 FS-FEATURES           BINARY-LONG.
    05 FS-OVR-MODE           BINARY-LONG.
    05 FS-OVR-COUNT          BINARY-LONG.
    05 FS-OVR                PIC X(48) OCCURS 24 TIMES.
    05 FS-TOTAL              BINARY-LONG.
    05 FS-STAMP              BINARY-LONG.
    05 FS-VOID               BINARY-LONG.
    05 FS-KIND               BINARY-LONG OCCURS 384 TIMES.
    05 FS-STATE              BINARY-LONG OCCURS 384 TIMES.
