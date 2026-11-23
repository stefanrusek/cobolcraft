*> Per-row state of standard mobs added by the wrap C closures (spec 002-client-polish, round 4), EXTERNAL, one entry per tracker row. Kept apart from CORESTATE.cpy so that
*> adding a field recompiles only the programs that COPY this book. WC-ID is the entity id the entry belongs to: an entry whose WC-ID is not the row's EN-ID is a stale one of a
*> mob that left the row (WC-ROW-OPEN clears it).
*>   rabbit (core/src/mob-19-4b.cob, 19 section 4, 44 part 4 section 3): WC-JUMP-DELAY the jumpDelayTicks, WC-MORE-CARROT the moreCarrotTicks, WC-HOPPING 1 from a hop's start until it lands,
*>   WC-HOP-TICKS the ticks of the hop so far (the 15-tick animation), WC-WAS-GROUND the on-ground flag of the last tick, WC-RAID-ON 1 while RaidGarden walks to a crop
*>   (WC-RAID-X/-Y/-Z the crop cell, WC-RAID-TRY the ticks spent, WC-RAID-WAIT the ticks to the goal's next start).
*>   donkey and mule (core/src/mob-19-3c.cob, 19 section 3.5 step 5): WC-CHEST 1 when a chest is attached (the chest flag, metadata 19; saved as ChestedHorse).
*>   nautilus and zombie nautilus (core/src/mob-21-4-nautilus.cob, 44-7 sections 10.5 and 10.6): WC-NAU-INIT 1 once the spawn memories were set, WC-NAU-ATTACK-CD ATTACK_TARGET_COOLDOWN,
*>   WC-NAU-CHARGE-CD CHARGE_COOLDOWN_TICKS, WC-NAU-CHARGING the ticks the charge has run (0 not charging), WC-NAU-VX/-VY/-VZ the chargeVelocity and WC-NAU-SX/-SY/-SZ the start position
*>   (thousandths), WC-NAU-ANGRY the entity id of the ANGRY_AT memory (EN-ANGER holds its ticks), WC-NAU-DASH 1 while the dash flag (metadata 20) is set.
 78 WC-MAX                VALUE 1024.
 01 WC-STATE EXTERNAL.
    05 WC-ROW                OCCURS 1024 TIMES.
       10 WC-ID              BINARY-LONG.
       10 WC-JUMP-DELAY      BINARY-LONG.
       10 WC-MORE-CARROT     BINARY-LONG.
       10 WC-HOPPING         BINARY-LONG.
       10 WC-HOP-TICKS       BINARY-LONG.
       10 WC-WAS-GROUND      BINARY-LONG.
       10 WC-RAID-ON         BINARY-LONG.
       10 WC-RAID-X          BINARY-LONG.
       10 WC-RAID-Y          BINARY-LONG.
       10 WC-RAID-Z          BINARY-LONG.
       10 WC-RAID-TRY        BINARY-LONG.
       10 WC-RAID-WAIT       BINARY-LONG.
       10 WC-CHEST           BINARY-LONG.
       10 WC-NAU-INIT        BINARY-LONG.
       10 WC-NAU-ATTACK-CD   BINARY-LONG.
       10 WC-NAU-CHARGE-CD   BINARY-LONG.
       10 WC-NAU-CHARGING    BINARY-LONG.
       10 WC-NAU-VX          BINARY-LONG.
       10 WC-NAU-VY          BINARY-LONG.
       10 WC-NAU-VZ          BINARY-LONG.
       10 WC-NAU-SX          BINARY-LONG.
       10 WC-NAU-SY          BINARY-LONG.
       10 WC-NAU-SZ          BINARY-LONG.
       10 WC-NAU-ANGRY       BINARY-LONG.
       10 WC-NAU-DASH        BINARY-LONG.
