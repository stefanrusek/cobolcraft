*> The job site claims of villagers (docs/protocol/44 section 1.3 and 2.1; core/src/mob-vil-poi.cob), EXTERNAL, one entry per claimed workstation (PO-OWNER 0 = free), one
*> ticket each. The core keeps no POI index of the world: a claim exists only while a villager holds the job site.
 78 PO-MAX                VALUE 256.
 01 PO-STATE EXTERNAL.
    05 PO-ENTRY              OCCURS 256 TIMES.
       10 PO-OWNER           BINARY-LONG.
       10 PO-DIM             BINARY-LONG.
       10 PO-X               BINARY-LONG.
       10 PO-Y               BINARY-LONG.
       10 PO-Z               BINARY-LONG.
