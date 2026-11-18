*> Per-row state of standard mobs added by 002-lane-p49n (core/src/mob-20-hcoll.cob and the files named in the lane's task list), EXTERNAL, one entry per tracker row.
*> PN-ID is the entity id the entry belongs to (an entry whose PN-ID is not the row's EN-ID is a stale one of a mob that left the row: it reads as all zero).
*> PN-HCOLL: 1 when the last MOB-PHYSICS move was blocked horizontally (horizontalCollision, 18 section 3.3). PN-CLIMB: the spider flags byte sent as metadata 16, bit 0 = climbing
*> (20 section 7.1: set to PN-HCOLL every tick by SPIDER-CLIMB-TICK, read by MOB-PHYSICS as onClimbable).
 78 PN-MAX                VALUE 1024.
 01 PN-STATE EXTERNAL.
    05 PN-ROW                OCCURS 1024 TIMES.
       10 PN-ID              BINARY-LONG.
       10 PN-HCOLL           BINARY-LONG.
       10 PN-CLIMB           BINARY-LONG.
