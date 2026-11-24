*> The candidates of the structure spawn override query (docs/protocol/36-structures-1-model-placement-starts.md section 10; core/src/struct-36-1-10.cob STRUCT-SPAWN-SELECT): one row per structure
*> that references the chunk of the position, in the iteration order of the caller, each with its starts that reference it. A start row carries its pieces' boxes and the box the structure reports
*> (the adjusted box of 5.6: STRUCT-ADJUST-BOX). Not EXTERNAL: the caller owns the record.
*>   SPS-COUNT structures; SPS-OVERRIDE 1 when the structure's spawn_overrides has the category; SPS-MODE the bounding_box of that override (0 piece, 1 full);
*>   SPS-STARTS starts (up to 4); per start SPS-VALID (the start has pieces), SPS-PIECES (up to 8) with SPS-PX0..SPS-PZ1 the piece boxes and SPS-BX0..SPS-BZ1 the start's bounding box.
 78 SPS-MAX-STRUCTS      VALUE 8.
 78 SPS-MAX-STARTS       VALUE 4.
 78 SPS-MAX-PIECES       VALUE 512.
 01 SPAWN-SELECT.
    05 SPS-COUNT            BINARY-LONG.
    05 SPS-STRUCT OCCURS 8 TIMES.
       10 SPS-OVERRIDE      BINARY-LONG.
       10 SPS-MODE          BINARY-LONG.
       10 SPS-STARTS        BINARY-LONG.
       10 SPS-START OCCURS 4 TIMES.
          15 SPS-VALID      BINARY-LONG.
          15 SPS-PIECES     BINARY-LONG.
          15 SPS-BX0        BINARY-LONG.
          15 SPS-BY0        BINARY-LONG.
          15 SPS-BZ0        BINARY-LONG.
          15 SPS-BX1        BINARY-LONG.
          15 SPS-BY1        BINARY-LONG.
          15 SPS-BZ1        BINARY-LONG.
          15 SPS-PIECE OCCURS 512 TIMES.
             20 SPS-PX0     BINARY-LONG.
             20 SPS-PY0     BINARY-LONG.
             20 SPS-PZ0     BINARY-LONG.
             20 SPS-PX1     BINARY-LONG.
             20 SPS-PY1     BINARY-LONG.
             20 SPS-PZ1     BINARY-LONG.
