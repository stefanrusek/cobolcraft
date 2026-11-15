*> The setups of the ruined portal structures (docs/protocol/36-structures-4 section 8.1; core/src/struct-portal.cob STRUCT-PORTAL-READ). EXTERNAL, core-private. A structure's setups are the
*> RP-REC rows SDT-RP-FIRST on, SDT-RP-N of them (STRUCTDATA.cpy). RP-PLACEMENT 0 on_land_surface, 1 partly_buried, 2 on_ocean_floor, 3 in_mountain, 4 underground, 5 in_nether (the enum's
*> order); RP-AIR air_pocket_probability and RP-WEIGHT (float32 values); RP-MOSS the mossiness in tenths (the data has one decimal); RP-OVERGROWN, RP-VINES, RP-COLD (can_be_cold) and
*> RP-BLACK (replace_with_blackstone) 0 or 1.
 78 RP-MAX                VALUE 64.
 01 STRUCT-PORTAL-DATA EXTERNAL.
    05 RP-COUNT             BINARY-LONG.
    05 RP-REC OCCURS 64 TIMES.
       10 RP-PLACEMENT      BINARY-LONG.
       10 RP-AIR            FLOAT-LONG.
       10 RP-WEIGHT         FLOAT-LONG.
       10 RP-MOSS           BINARY-LONG.
       10 RP-OVERGROWN      BINARY-LONG.
       10 RP-VINES          BINARY-LONG.
       10 RP-COLD           BINARY-LONG.
       10 RP-BLACK          BINARY-LONG.
