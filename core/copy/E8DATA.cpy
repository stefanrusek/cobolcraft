*> What a saved entity compound said about the falling block and the primed TNT of docs/protocol/45-entity-nbt-8 sections 3.3 and 3.4, collected by ENTITY8-NBT-KEY and applied by
*> ENTITY8-NBT-APPLY. E8-STATE is -1 when the compound holds no BlockState; E8-FUSE is -1 without a fuse (80 is the TNT default, set by ENTITY-NBT-ONE).
 01 E8-DATA.
    05 E8-STATE            BINARY-LONG.
    05 E8-TIME             BINARY-LONG.
    05 E8-CANCEL           BINARY-LONG.
    05 E8-FUSE             BINARY-LONG.
