*> The POI index of villagers (docs/protocol/54 section 4 and 19 sections 22.3, 22.7; core/src/mob-vil-index.cob; lane 002-lane-mobsb3, T8105), EXTERNAL.
*> PX-BKIND is the kind of every block index (0 none, 1 bed, 2 bell, 3 job site), built once per CB-EPOCH. PX-ENTRY is one found point of interest (PX-KIND 0 = free); an
*> entry is validated against the world when it is used and dropped when the block is gone (ValidateNearbyPoi). PX-DONE lists the chunks whose 24 sections were scanned
*> and PX-SC-* is the scan in progress (one 16-high section per call).
 78 PX-MAX                VALUE 1024.
 78 PX-DONE-MAX           VALUE 512.
 01 PX-STATE EXTERNAL.
    05 PX-EPOCH              BINARY-LONG.
    05 PX-BKIND              BINARY-CHAR UNSIGNED OCCURS 1400 TIMES.
    05 PX-ENTRY              OCCURS 1024 TIMES.
       10 PX-KIND            BINARY-LONG.
       10 PX-DIM             BINARY-LONG.
       10 PX-X               BINARY-LONG.
       10 PX-Y               BINARY-LONG.
       10 PX-Z               BINARY-LONG.
    05 PX-DONE-N             BINARY-LONG.
    05 PX-DONE OCCURS 512 TIMES.
       10 PX-D-DIM           BINARY-LONG.
       10 PX-D-CX            BINARY-LONG.
       10 PX-D-CZ            BINARY-LONG.
    05 PX-SC-ON              BINARY-LONG.
    05 PX-SC-DIM             BINARY-LONG.
    05 PX-SC-CX              BINARY-LONG.
    05 PX-SC-CZ              BINARY-LONG.
    05 PX-SC-SEC             BINARY-LONG.
