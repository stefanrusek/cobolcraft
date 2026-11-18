*> The fields of one entity's saved state of lane 002-lane-p49m (docs/protocol/45-entity-nbt-1 to 45-9), at level 10: ENKEEP.cpy holds one per tracker row
*> (EK-), ENKSTAGE.cpy the copy ENTITY-NBT-ONE collects while it reads a compound (KD-, the same bytes, so one group MOVE applies it). A field the
*> compound does not hold stays 0 or spaces, so every default that is not 0 is a "set" flag here.
*>   Entity base (45-1 section 5): CustomName (EK-NAME-*, the tag payload as the compound has it: String, Compound or List; kept when it fits), Tags
*>   (a set of strings: the u16 length and the bytes of each distinct tag one after the other, what fits 1024 bytes), data (the custom data compound payload,
*>   End tag included; an empty compound is none).
       10 EK-NAME-LEN        BINARY-LONG.
       10 EK-NAME-TYPE       BINARY-LONG.
       10 EK-NAME-RAW        PIC X(256).
       10 EK-TAG-COUNT       BINARY-LONG.
       10 EK-TAG-LEN         BINARY-LONG.
       10 EK-TAG-RAW         PIC X(1024).
       10 EK-DATA-LEN        BINARY-LONG.
       10 EK-DATA-RAW        PIC X(1024).
*>   LivingEntity (45-2 section 2): attributes (the list payload as the compound has it, type byte and count included; none or an empty list is not kept),
*>   active_effects (per effect of the six the core holds, in the order speed, strength, regeneration, invisibility, fire_resistance, water_breathing:
*>   the amplifier, ambient, the show_particles and show_icon flags as 1 = false, and the hidden_effect compound payload; the elements of any other effect
*>   as compound payloads one after the other), the impulse and explosion keys, FallFlying, sleeping_pos, the Brain memories compound, last_hurt_by_mob,
*>   locator_bar_icon.
       10 EK-ATTR-LEN        BINARY-LONG.
       10 EK-ATTR-RAW        PIC X(1024).
       10 EK-FX OCCURS 6 TIMES.
          15 EK-FX-AMP       BINARY-LONG.
          15 EK-FX-AMBIENT   BINARY-LONG.
          15 EK-FX-NOPART    BINARY-LONG.
          15 EK-FX-NOICON    BINARY-LONG.
          15 EK-FX-HID-LEN   BINARY-LONG.
          15 EK-FX-HID-RAW   PIC X(160).
       10 EK-FXO-COUNT       BINARY-LONG.
       10 EK-FXO-LEN         BINARY-LONG.
       10 EK-FXO-RAW         PIC X(1024).
       10 EK-GRACE           BINARY-LONG.
       10 EK-IMPACT-ON       BINARY-LONG.
       10 EK-IMPACT-X        FLOAT-LONG.
       10 EK-IMPACT-Y        FLOAT-LONG.
       10 EK-IMPACT-Z        FLOAT-LONG.
       10 EK-ABSORB          FLOAT-SHORT.
       10 EK-FALLFLY         BINARY-LONG.
       10 EK-SLEEP-ON        BINARY-LONG.
       10 EK-SLEEP-X         BINARY-LONG.
       10 EK-SLEEP-Y         BINARY-LONG.
       10 EK-SLEEP-Z         BINARY-LONG.
       10 EK-BRAIN-LEN       BINARY-LONG.
       10 EK-BRAIN-RAW       PIC X(1024).
       10 EK-HURTMOB         PIC X(16).
       10 EK-HURTMOB-TICKS   BINARY-LONG.
       10 EK-LOCATOR-LEN     BINARY-LONG.
       10 EK-LOCATOR-RAW     PIC X(128).
*>   Mob (45-2 section 3): drop_chances (per slot in the order mainhand, offhand, feet, legs, chest, head, body, saddle: the Float and whether the
*>   compound had it), home_radius and home_pos, DeathLootTable and its seed, LoveCause (the UUID of the feeder, kept while that player is not in the world).
       10 EK-DROPS OCCURS 8 TIMES.
          15 EK-DROP-SET     BINARY-LONG.
          15 EK-DROP         FLOAT-SHORT.
       10 EK-HOME-ON         BINARY-LONG.
       10 EK-HOME-RADIUS     BINARY-LONG.
       10 EK-HOME-X          BINARY-LONG.
       10 EK-HOME-Y          BINARY-LONG.
       10 EK-HOME-Z          BINARY-LONG.
       10 EK-LOOT-LEN        BINARY-LONG.
       10 EK-LOOT            PIC X(64).
       10 EK-LOOT-SEED       BINARY-DOUBLE.
       10 EK-LOVE-UUID       PIC X(16).
