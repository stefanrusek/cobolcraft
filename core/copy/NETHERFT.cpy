*> The Nether's global feature order (docs/protocol/37-nether-5 section 3): one row per placed feature in (step, index) order: step (1 digit), index within the step
*> (2 digits), placed feature id without namespace (26), the biomes that list it (W nether_wastes, S soul_sand_valley, C crimson_forest, P warped_forest, D basalt_deltas; . for none).
 01 NF-ROWS.
    05 FILLER PIC X(34) VALUE "200basalt_pillar             .S...".
    05 FILLER PIC X(34) VALUE "400delta                     ....D".
    05 FILLER PIC X(34) VALUE "401small_basalt_columns      ....D".
    05 FILLER PIC X(34) VALUE "402large_basalt_columns      ....D".
    05 FILLER PIC X(34) VALUE "700basalt_blobs              ....D".
    05 FILLER PIC X(34) VALUE "701blackstone_blobs          ....D".
    05 FILLER PIC X(34) VALUE "702spring_delta              ....D".
    05 FILLER PIC X(34) VALUE "703spring_open               WSCP.".
    05 FILLER PIC X(34) VALUE "704patch_fire                WSCPD".
    05 FILLER PIC X(34) VALUE "705patch_soul_fire           WS.PD".
    05 FILLER PIC X(34) VALUE "706glowstone_extra           WSCPD".
    05 FILLER PIC X(34) VALUE "707glowstone                 WSCPD".
    05 FILLER PIC X(34) VALUE "708patch_crimson_roots       .S...".
    05 FILLER PIC X(34) VALUE "709brown_mushroom_nether     W...D".
    05 FILLER PIC X(34) VALUE "710red_mushroom_nether       W...D".
    05 FILLER PIC X(34) VALUE "711ore_magma                 WSCPD".
    05 FILLER PIC X(34) VALUE "712spring_closed_double      ....D".
    05 FILLER PIC X(34) VALUE "713ore_gold_deltas           ....D".
    05 FILLER PIC X(34) VALUE "714ore_quartz_deltas         ....D".
    05 FILLER PIC X(34) VALUE "715spring_closed             WSCP.".
    05 FILLER PIC X(34) VALUE "716ore_soul_sand             .S...".
    05 FILLER PIC X(34) VALUE "717ore_gravel_nether         WSCP.".
    05 FILLER PIC X(34) VALUE "718ore_blackstone            WSCP.".
    05 FILLER PIC X(34) VALUE "719ore_gold_nether           WSCP.".
    05 FILLER PIC X(34) VALUE "720ore_quartz_nether         WSCP.".
    05 FILLER PIC X(34) VALUE "721ore_ancient_debris_large  WSCPD".
    05 FILLER PIC X(34) VALUE "722ore_debris_small          WSCPD".
    05 FILLER PIC X(34) VALUE "900spring_lava               WSCP.".
    05 FILLER PIC X(34) VALUE "901brown_mushroom_normal     W.CP.".
    05 FILLER PIC X(34) VALUE "902red_mushroom_normal       W.CP.".
    05 FILLER PIC X(34) VALUE "903warped_fungi              ...P.".
    05 FILLER PIC X(34) VALUE "904warped_forest_vegetation  ...P.".
    05 FILLER PIC X(34) VALUE "905nether_sprouts            ...P.".
    05 FILLER PIC X(34) VALUE "906twisting_vines            ...P.".
    05 FILLER PIC X(34) VALUE "907weeping_vines             ..C..".
    05 FILLER PIC X(34) VALUE "908crimson_fungi             ..C..".
    05 FILLER PIC X(34) VALUE "909crimson_forest_vegetation ..C..".
 01 NF-TABLE REDEFINES NF-ROWS.
    05 NF-ROW OCCURS 37 TIMES.
       10 NF-STEP PIC 9.
       10 NF-INDEX PIC 99.
       10 NF-KEY PIC X(26).
       10 NF-MASK PIC X(5).
