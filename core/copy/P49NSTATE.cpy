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
*>     enderman (core/src/mob-20-8b.cob, 20 section 8.1): PN-CARRY the carried block state id (0 none), PN-CREEPY and PN-STARED the flags last sent as metadata 17 and 18, PN-STARE-WANT the flag the stare rule wants (1 once it took a target by a stare, 0 when the target is gone).
       10 PN-CARRY           BINARY-LONG.
       10 PN-CREEPY          BINARY-LONG.
       10 PN-STARED          BINARY-LONG.
       10 PN-STARE-WANT      BINARY-LONG.
*>     sulfur cube (core/src/mob-20-sulfur.cob, 20 section 18.2): PN-BODY the item id + 1 of the BODY slot (0 empty), PN-FUSE the fuse ticks left and PN-MAXFUSE the synched max fuse
*>     (0 = not primed; the fuse 0 of a primed cube is the tick it explodes).
*>     pillager (core/src/mob-20-pillager.cob, 20 section 13.2): PN-INV-ITEM (item id + 1, 0 empty) and PN-INV-COUNT of its five inventory slots, PN-CHARGE the charging flag last sent as
*>     metadata 17.
       10 PN-INV-ITEM        BINARY-LONG OCCURS 5 TIMES.
       10 PN-INV-COUNT       BINARY-LONG OCCURS 5 TIMES.
       10 PN-CHARGE          BINARY-LONG.
       10 PN-BODY            BINARY-LONG.
       10 PN-FUSE            BINARY-LONG.
       10 PN-MAXFUSE         BINARY-LONG.
*> The warning_level of the last shriek of each sculk shrieker (44 part x2 section 2.3, core/src/mob-20-shriek.cob): PN-SH-USED 1, the block position and the level (the block entity's own
*> key; kept here by position, not in the saved block entity). At most 64 shriekers hold one at a time; an entry is freed when its level goes back to 0.
 78 PN-SH-MAX             VALUE 64.
 01 PN-SHRIEK EXTERNAL.
    05 PN-SH-ENTRY           OCCURS 64 TIMES.
       10 PN-SH-USED         BINARY-LONG.
       10 PN-SH-DIM          BINARY-LONG.
       10 PN-SH-X            BINARY-LONG.
       10 PN-SH-Y            BINARY-LONG.
       10 PN-SH-Z            BINARY-LONG.
       10 PN-SH-LEVEL        BINARY-LONG.
*> The loot context facts of a raider that dies (set by RAIDER-LOOT-SET before STDMOB-DROPS rolls its table, cleared after; 26 section on entity predicates type_specific/raider).
 01 PN-LOOT EXTERNAL.
    05 PN-LOOT-RAIDER        BINARY-LONG.
    05 PN-LOOT-HAS-RAID      BINARY-LONG.
    05 PN-LOOT-CAPTAIN       BINARY-LONG.
