*> The species keys of lane 002-lane-p49m that have a value but no behaviour of their own in the core (docs/protocol/45-entity-nbt-4 to 45-6; one row per species and key),
*> read and written by core/src/entity-spx.cob into the EK-SPX slots (1 to 4: a number or a text, a tag payload kept up to 256 bytes) and EK-BIG slots (5 to 7: a tag payload kept up to 1024).
*> A row is SPX-SPECIES (the standard mob key), SPX-KEY, SPX-TAG (the NBT tag type: 1 Byte, 3 Int, 4 Long, 8 String, 9 List, 10 Compound, 11 Int Array), SPX-DEF (the number written
*> when the key was not read), SPX-TEXT (the text written then), SPX-MODE (A written always, C only when read, X only when the first number of the species is 1 and Z always: the payload read or an empty list),
*> SPX-SLOT. Keys that other core programs already write are not here.
 78 SPX-ROWS             VALUE 55.
 01 SPX-TABLE-VALUES.
    05 FILLER              PIC X(16) VALUE "rabbit".
    05 FILLER              PIC X(24) VALUE "RabbitType".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "rabbit".
    05 FILLER              PIC X(24) VALUE "MoreCarrotTicks".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 9 VALUE 2.
    05 FILLER              PIC X(16) VALUE "horse".
    05 FILLER              PIC X(24) VALUE "Variant".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "skeleton_horse".
    05 FILLER              PIC X(24) VALUE "SkeletonTrap".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "skeleton_horse".
    05 FILLER              PIC X(24) VALUE "SkeletonTrapTime".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 9 VALUE 2.
    05 FILLER              PIC X(16) VALUE "donkey".
    05 FILLER              PIC X(24) VALUE "ChestedHorse".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "mule".
    05 FILLER              PIC X(24) VALUE "ChestedHorse".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "llama".
    05 FILLER              PIC X(24) VALUE "ChestedHorse".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "trader_llama".
    05 FILLER              PIC X(24) VALUE "ChestedHorse".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "donkey".
    05 FILLER              PIC X(24) VALUE "Items".
    05 FILLER              PIC 99 VALUE 9.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "X".
    05 FILLER              PIC 9 VALUE 5.
    05 FILLER              PIC X(16) VALUE "mule".
    05 FILLER              PIC X(24) VALUE "Items".
    05 FILLER              PIC 99 VALUE 9.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "X".
    05 FILLER              PIC 9 VALUE 5.
    05 FILLER              PIC X(16) VALUE "llama".
    05 FILLER              PIC X(24) VALUE "Items".
    05 FILLER              PIC 99 VALUE 9.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "X".
    05 FILLER              PIC 9 VALUE 5.
    05 FILLER              PIC X(16) VALUE "trader_llama".
    05 FILLER              PIC X(24) VALUE "Items".
    05 FILLER              PIC 99 VALUE 9.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "X".
    05 FILLER              PIC 9 VALUE 5.
    05 FILLER              PIC X(16) VALUE "trader_llama".
    05 FILLER              PIC X(24) VALUE "DespawnDelay".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 47999.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 9 VALUE 2.
    05 FILLER              PIC X(16) VALUE "cow".
    05 FILLER              PIC X(24) VALUE "sound_variant".
    05 FILLER              PIC 99 VALUE 8.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "pig".
    05 FILLER              PIC X(24) VALUE "sound_variant".
    05 FILLER              PIC 99 VALUE 8.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "chicken".
    05 FILLER              PIC X(24) VALUE "sound_variant".
    05 FILLER              PIC 99 VALUE 8.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "cat".
    05 FILLER              PIC X(24) VALUE "sound_variant".
    05 FILLER              PIC 99 VALUE 8.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "wolf".
    05 FILLER              PIC X(24) VALUE "sound_variant".
    05 FILLER              PIC 99 VALUE 8.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "frog".
    05 FILLER              PIC X(24) VALUE "variant".
    05 FILLER              PIC 99 VALUE 8.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "minecraft:temperate".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "mooshroom".
    05 FILLER              PIC X(24) VALUE "stew_effects".
    05 FILLER              PIC 99 VALUE 9.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 5.
    05 FILLER              PIC X(16) VALUE "allay".
    05 FILLER              PIC X(24) VALUE "listener".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "happy_ghast".
    05 FILLER              PIC X(24) VALUE "still_timeout".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "copper_golem".
    05 FILLER              PIC X(24) VALUE "next_weather_age".
    05 FILLER              PIC 99 VALUE 4.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE -1.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "copper_golem".
    05 FILLER              PIC X(24) VALUE "weather_state".
    05 FILLER              PIC 99 VALUE 8.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "unaffected".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 9 VALUE 2.
    05 FILLER              PIC X(16) VALUE "bat".
    05 FILLER              PIC X(24) VALUE "BatFlags".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "enderman".
    05 FILLER              PIC X(24) VALUE "carriedBlockState".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "endermite".
    05 FILLER              PIC X(24) VALUE "Lifetime".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "vex".
    05 FILLER              PIC X(24) VALUE "bound_pos".
    05 FILLER              PIC 99 VALUE 11.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "vex".
    05 FILLER              PIC X(24) VALUE "life_ticks".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 2.
    05 FILLER              PIC X(16) VALUE "vex".
    05 FILLER              PIC X(24) VALUE "owner".
    05 FILLER              PIC 99 VALUE 11.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 3.
    05 FILLER              PIC X(16) VALUE "warden".
    05 FILLER              PIC X(24) VALUE "anger".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "warden".
    05 FILLER              PIC X(24) VALUE "listener".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 2.
    05 FILLER              PIC X(16) VALUE "creaking".
    05 FILLER              PIC X(24) VALUE "home_pos".
    05 FILLER              PIC 99 VALUE 11.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "bogged".
    05 FILLER              PIC X(24) VALUE "sheared".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "sulfur_cube".
    05 FILLER              PIC X(24) VALUE "pickup_timer".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "sulfur_cube".
    05 FILLER              PIC X(24) VALUE "from_bucket".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 9 VALUE 2.
    05 FILLER              PIC X(16) VALUE "sulfur_cube".
    05 FILLER              PIC X(24) VALUE "fuse".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE -1.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 9 VALUE 3.
    05 FILLER              PIC X(16) VALUE "zombie_villager".
    05 FILLER              PIC X(24) VALUE "Offers".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 5.
    05 FILLER              PIC X(16) VALUE "zombie_villager".
    05 FILLER              PIC X(24) VALUE "Gossips".
    05 FILLER              PIC 99 VALUE 9.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 6.
    05 FILLER              PIC X(16) VALUE "villager".
    05 FILLER              PIC X(24) VALUE "Offers".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 5.
    05 FILLER              PIC X(16) VALUE "wandering_trader".
    05 FILLER              PIC X(24) VALUE "Offers".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 5.
    05 FILLER              PIC X(16) VALUE "villager".
    05 FILLER              PIC X(24) VALUE "Gossips".
    05 FILLER              PIC 99 VALUE 9.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "Z".
    05 FILLER              PIC 9 VALUE 6.
    05 FILLER              PIC X(16) VALUE "villager".
    05 FILLER              PIC X(24) VALUE "Inventory".
    05 FILLER              PIC 99 VALUE 9.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "Z".
    05 FILLER              PIC 9 VALUE 7.
    05 FILLER              PIC X(16) VALUE "pillager".
    05 FILLER              PIC X(24) VALUE "Inventory".
    05 FILLER              PIC 99 VALUE 9.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "Z".
    05 FILLER              PIC 9 VALUE 7.
    05 FILLER              PIC X(16) VALUE "piglin".
    05 FILLER              PIC X(24) VALUE "Inventory".
    05 FILLER              PIC 99 VALUE 9.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "Z".
    05 FILLER              PIC 9 VALUE 7.
    05 FILLER              PIC X(16) VALUE "wandering_trader".
    05 FILLER              PIC X(24) VALUE "Inventory".
    05 FILLER              PIC 99 VALUE 9.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "Z".
    05 FILLER              PIC 9 VALUE 7.
    05 FILLER              PIC X(16) VALUE "wandering_trader".
    05 FILLER              PIC X(24) VALUE "DespawnDelay".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "wandering_trader".
    05 FILLER              PIC X(24) VALUE "wander_target".
    05 FILLER              PIC 99 VALUE 11.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 2.
    05 FILLER              PIC X(16) VALUE "pillager".
    05 FILLER              PIC X(24) VALUE "RaidId".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "vindicator".
    05 FILLER              PIC X(24) VALUE "RaidId".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "evoker".
    05 FILLER              PIC X(24) VALUE "RaidId".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "illusioner".
    05 FILLER              PIC X(24) VALUE "RaidId".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "ravager".
    05 FILLER              PIC X(24) VALUE "RaidId".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 1.
    05 FILLER              PIC X(16) VALUE "witch".
    05 FILLER              PIC X(24) VALUE "RaidId".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "".
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 9 VALUE 1.
 01 SPX-TABLE REDEFINES SPX-TABLE-VALUES.
    05 SPX-ROW OCCURS 55 TIMES.
       10 SPX-SPECIES   PIC X(16).
       10 SPX-KEY       PIC X(24).
       10 SPX-TAG       PIC 99.
       10 SPX-DEF       PIC S9(10) SIGN LEADING SEPARATE.
       10 SPX-TEXT      PIC X(24).
       10 SPX-MODE      PIC X.
       10 SPX-SLOT      PIC 9.
