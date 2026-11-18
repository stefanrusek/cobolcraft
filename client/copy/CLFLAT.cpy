*> The nine flat world presets of docs/protocol/56-superflat-world.md §3.2 (the `visible` tag order of §3.1), for the
*> superflat customization screens (client/src/screens/flat-world.cob): the preset id (the key suffix of
*> flat_world_preset.minecraft.<id>), the layer count and the layers bottom first as stored (block name without the
*> minecraft: namespace, height). The biome, features, lakes and structure overrides of §3.2 are the world generator's,
*> not the client's, so only the layers are kept here (the core takes the preset id).
 78 FP-COUNT              VALUE 9.
 78 FP-MAX-LAYERS         VALUE 6.
 01 FP-DATA.
    05 FILLER PIC X(20) VALUE "classic_flat".
    05 FILLER PIC 9 VALUE 3.
    05 FILLER PIC X(16) VALUE "bedrock".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(16) VALUE "dirt".
    05 FILLER PIC 9(4) VALUE 2.
    05 FILLER PIC X(16) VALUE "grass_block".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(20) VALUE "tunnelers_dream".
    05 FILLER PIC 9 VALUE 4.
    05 FILLER PIC X(16) VALUE "bedrock".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(16) VALUE "stone".
    05 FILLER PIC 9(4) VALUE 230.
    05 FILLER PIC X(16) VALUE "dirt".
    05 FILLER PIC 9(4) VALUE 5.
    05 FILLER PIC X(16) VALUE "grass_block".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(20) VALUE "water_world".
    05 FILLER PIC 9 VALUE 6.
    05 FILLER PIC X(16) VALUE "bedrock".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(16) VALUE "deepslate".
    05 FILLER PIC 9(4) VALUE 64.
    05 FILLER PIC X(16) VALUE "stone".
    05 FILLER PIC 9(4) VALUE 5.
    05 FILLER PIC X(16) VALUE "dirt".
    05 FILLER PIC 9(4) VALUE 5.
    05 FILLER PIC X(16) VALUE "gravel".
    05 FILLER PIC 9(4) VALUE 5.
    05 FILLER PIC X(16) VALUE "water".
    05 FILLER PIC 9(4) VALUE 90.
    05 FILLER PIC X(20) VALUE "overworld".
    05 FILLER PIC 9 VALUE 4.
    05 FILLER PIC X(16) VALUE "bedrock".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(16) VALUE "stone".
    05 FILLER PIC 9(4) VALUE 59.
    05 FILLER PIC X(16) VALUE "dirt".
    05 FILLER PIC 9(4) VALUE 3.
    05 FILLER PIC X(16) VALUE "grass_block".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(20) VALUE "snowy_kingdom".
    05 FILLER PIC 9 VALUE 5.
    05 FILLER PIC X(16) VALUE "bedrock".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(16) VALUE "stone".
    05 FILLER PIC 9(4) VALUE 59.
    05 FILLER PIC X(16) VALUE "dirt".
    05 FILLER PIC 9(4) VALUE 3.
    05 FILLER PIC X(16) VALUE "grass_block".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(16) VALUE "snow".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(20) VALUE "bottomless_pit".
    05 FILLER PIC 9 VALUE 3.
    05 FILLER PIC X(16) VALUE "cobblestone".
    05 FILLER PIC 9(4) VALUE 2.
    05 FILLER PIC X(16) VALUE "dirt".
    05 FILLER PIC 9(4) VALUE 3.
    05 FILLER PIC X(16) VALUE "grass_block".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(20) VALUE "desert".
    05 FILLER PIC 9 VALUE 4.
    05 FILLER PIC X(16) VALUE "bedrock".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(16) VALUE "stone".
    05 FILLER PIC 9(4) VALUE 3.
    05 FILLER PIC X(16) VALUE "sandstone".
    05 FILLER PIC 9(4) VALUE 52.
    05 FILLER PIC X(16) VALUE "sand".
    05 FILLER PIC 9(4) VALUE 8.
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(20) VALUE "redstone_ready".
    05 FILLER PIC 9 VALUE 3.
    05 FILLER PIC X(16) VALUE "bedrock".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(16) VALUE "stone".
    05 FILLER PIC 9(4) VALUE 3.
    05 FILLER PIC X(16) VALUE "sandstone".
    05 FILLER PIC 9(4) VALUE 116.
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(20) VALUE "the_void".
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC X(16) VALUE "air".
    05 FILLER PIC 9(4) VALUE 1.
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
    05 FILLER PIC X(16) VALUE SPACES.
    05 FILLER PIC 9(4) VALUE 0.
 01 FP-TABLE REDEFINES FP-DATA.
    05 FP-PRESET OCCURS 9 TIMES.
       10 FP-ID              PIC X(20).
       10 FP-LAYER-COUNT     PIC 9.
       10 FP-LAYER OCCURS 6 TIMES.
          15 FP-BLOCK        PIC X(16).
          15 FP-HEIGHT       PIC 9(4).
