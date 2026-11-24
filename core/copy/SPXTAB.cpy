*> The species keys of lane 002-lane-p49m that have a value but no behaviour of their own in the core (docs/protocol/45-entity-nbt-4 to 45-6; one row per species and key),
*> read and written by core/src/entity-spx.cob into the EK-SPX slots (1 to 20: a number or a text, a tag payload kept up to 256 bytes) and EK-BIG slots (21 to 23: a tag payload kept up to 1024).
*> A row is SPX-SPECIES (the standard mob key), SPX-KEY, SPX-TAG (the NBT tag type: 1 Byte, 2 Short, 3 Int, 4 Long, 5 Float, 8 String, 9 List, 10 Compound, 11 Int Array), SPX-DEF (the number written
*> when the key was not read), SPX-TEXT (the text written then), SPX-MODE (A written always, C only when read, Y always the payload read or an empty list, Z the same but only when ENTITY-SPX-WRITE-Z is asked for the key (the writer of the species puts it where the document has it)),
*> SPX-SLOT. Keys that other core programs already write are not here (ChestedHorse and Items of the donkey, mule and llamas: MOB-NBT-WRITE and MNT-INV-READ, core/src/mob-mount-screen.cob; SkeletonTrap and SkeletonTrapTime: MOB-NBT-WRITE, WC-TRAP and WC-TRAP-TICKS).
 78 SPX-ROWS             VALUE 121.
 01 SPX-TABLE-VALUES.
    05 FILLER              PIC X(24) VALUE "rabbit".
    05 FILLER              PIC X(24) VALUE "RabbitType".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "rabbit".
    05 FILLER              PIC X(24) VALUE "MoreCarrotTicks".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 2.
    05 FILLER              PIC X(24) VALUE "horse".
    05 FILLER              PIC X(24) VALUE "Variant".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "trader_llama".
    05 FILLER              PIC X(24) VALUE "DespawnDelay".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 47999.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 2.
    05 FILLER              PIC X(24) VALUE "cow".
    05 FILLER              PIC X(24) VALUE "sound_variant".
    05 FILLER              PIC 99 VALUE 8.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "pig".
    05 FILLER              PIC X(24) VALUE "sound_variant".
    05 FILLER              PIC 99 VALUE 8.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "chicken".
    05 FILLER              PIC X(24) VALUE "sound_variant".
    05 FILLER              PIC 99 VALUE 8.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "cat".
    05 FILLER              PIC X(24) VALUE "sound_variant".
    05 FILLER              PIC 99 VALUE 8.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "wolf".
    05 FILLER              PIC X(24) VALUE "sound_variant".
    05 FILLER              PIC 99 VALUE 8.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "frog".
    05 FILLER              PIC X(24) VALUE "variant".
    05 FILLER              PIC 99 VALUE 8.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "minecraft:temperate".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "mooshroom".
    05 FILLER              PIC X(24) VALUE "stew_effects".
    05 FILLER              PIC 99 VALUE 9.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 21.
    05 FILLER              PIC X(24) VALUE "allay".
    05 FILLER              PIC X(24) VALUE "listener".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "happy_ghast".
    05 FILLER              PIC X(24) VALUE "still_timeout".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "copper_golem".
    05 FILLER              PIC X(24) VALUE "next_weather_age".
    05 FILLER              PIC 99 VALUE 4.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE -1.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "copper_golem".
    05 FILLER              PIC X(24) VALUE "weather_state".
    05 FILLER              PIC 99 VALUE 8.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "unaffected".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 2.
    05 FILLER              PIC X(24) VALUE "bat".
    05 FILLER              PIC X(24) VALUE "BatFlags".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "enderman".
    05 FILLER              PIC X(24) VALUE "carriedBlockState".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "endermite".
    05 FILLER              PIC X(24) VALUE "Lifetime".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "vex".
    05 FILLER              PIC X(24) VALUE "bound_pos".
    05 FILLER              PIC 99 VALUE 11.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "vex".
    05 FILLER              PIC X(24) VALUE "life_ticks".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 2.
    05 FILLER              PIC X(24) VALUE "vex".
    05 FILLER              PIC X(24) VALUE "owner".
    05 FILLER              PIC 99 VALUE 11.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC X(24) VALUE "warden".
    05 FILLER              PIC X(24) VALUE "anger".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "warden".
    05 FILLER              PIC X(24) VALUE "listener".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 2.
    05 FILLER              PIC X(24) VALUE "creaking".
    05 FILLER              PIC X(24) VALUE "home_pos".
    05 FILLER              PIC 99 VALUE 11.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "bogged".
    05 FILLER              PIC X(24) VALUE "sheared".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "sulfur_cube".
    05 FILLER              PIC X(24) VALUE "pickup_timer".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "sulfur_cube".
    05 FILLER              PIC X(24) VALUE "from_bucket".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 2.
    05 FILLER              PIC X(24) VALUE "sulfur_cube".
    05 FILLER              PIC X(24) VALUE "fuse".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE -1.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC X(24) VALUE "zombie_villager".
    05 FILLER              PIC X(24) VALUE "Offers".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 21.
    05 FILLER              PIC X(24) VALUE "zombie_villager".
    05 FILLER              PIC X(24) VALUE "Gossips".
    05 FILLER              PIC 99 VALUE 9.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 22.
    05 FILLER              PIC X(24) VALUE "villager".
    05 FILLER              PIC X(24) VALUE "Offers".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 21.
    05 FILLER              PIC X(24) VALUE "wandering_trader".
    05 FILLER              PIC X(24) VALUE "Offers".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 21.
    05 FILLER              PIC X(24) VALUE "villager".
    05 FILLER              PIC X(24) VALUE "Gossips".
    05 FILLER              PIC 99 VALUE 9.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "Z".
    05 FILLER              PIC 99 VALUE 22.
    05 FILLER              PIC X(24) VALUE "villager".
    05 FILLER              PIC X(24) VALUE "Inventory".
    05 FILLER              PIC 99 VALUE 9.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "Z".
    05 FILLER              PIC 99 VALUE 23.
    05 FILLER              PIC X(24) VALUE "pillager".
    05 FILLER              PIC X(24) VALUE "Inventory".
    05 FILLER              PIC 99 VALUE 9.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "Z".
    05 FILLER              PIC 99 VALUE 23.
    05 FILLER              PIC X(24) VALUE "piglin".
    05 FILLER              PIC X(24) VALUE "Inventory".
    05 FILLER              PIC 99 VALUE 9.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "Z".
    05 FILLER              PIC 99 VALUE 23.
    05 FILLER              PIC X(24) VALUE "wandering_trader".
    05 FILLER              PIC X(24) VALUE "Inventory".
    05 FILLER              PIC 99 VALUE 9.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "Y".
    05 FILLER              PIC 99 VALUE 23.
    05 FILLER              PIC X(24) VALUE "wandering_trader".
    05 FILLER              PIC X(24) VALUE "DespawnDelay".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "wandering_trader".
    05 FILLER              PIC X(24) VALUE "wander_target".
    05 FILLER              PIC 99 VALUE 11.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 2.
    05 FILLER              PIC X(24) VALUE "pillager".
    05 FILLER              PIC X(24) VALUE "RaidId".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "vindicator".
    05 FILLER              PIC X(24) VALUE "RaidId".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "evoker".
    05 FILLER              PIC X(24) VALUE "RaidId".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "illusioner".
    05 FILLER              PIC X(24) VALUE "RaidId".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "ravager".
    05 FILLER              PIC X(24) VALUE "RaidId".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "witch".
    05 FILLER              PIC X(24) VALUE "RaidId".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "item".
    05 FILLER              PIC X(24) VALUE "Thrower".
    05 FILLER              PIC 99 VALUE 11.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "item".
    05 FILLER              PIC X(24) VALUE "Owner".
    05 FILLER              PIC 99 VALUE 11.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 2.
    05 FILLER              PIC X(24) VALUE "experience_orb".
    05 FILLER              PIC X(24) VALUE "Health".
    05 FILLER              PIC 99 VALUE 2.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 5.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "experience_orb".
    05 FILLER              PIC X(24) VALUE "Age".
    05 FILLER              PIC 99 VALUE 2.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 2.
    05 FILLER              PIC X(24) VALUE "experience_orb".
    05 FILLER              PIC X(24) VALUE "Value".
    05 FILLER              PIC 99 VALUE 2.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC X(24) VALUE "experience_orb".
    05 FILLER              PIC X(24) VALUE "Count".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 1.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 4.
    05 FILLER              PIC X(24) VALUE "falling_block".
    05 FILLER              PIC X(24) VALUE "TileEntityData".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "tnt".
    05 FILLER              PIC X(24) VALUE "explosion_power".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "tnt".
    05 FILLER              PIC X(24) VALUE "owner".
    05 FILLER              PIC 99 VALUE 11.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 2.
    05 FILLER              PIC X(24) VALUE "ominous_item_spawner".
    05 FILLER              PIC X(24) VALUE "item".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "ominous_item_spawner".
    05 FILLER              PIC X(24) VALUE "spawn_item_after_ticks".
    05 FILLER              PIC 99 VALUE 4.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 2.
    05 FILLER              PIC X(24) VALUE "area_effect_cloud".
    05 FILLER              PIC X(24) VALUE "Age".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "area_effect_cloud".
    05 FILLER              PIC X(24) VALUE "Duration".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE -1.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 2.
    05 FILLER              PIC X(24) VALUE "area_effect_cloud".
    05 FILLER              PIC X(24) VALUE "WaitTime".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 20.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC X(24) VALUE "area_effect_cloud".
    05 FILLER              PIC X(24) VALUE "ReapplicationDelay".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 20.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 4.
    05 FILLER              PIC X(24) VALUE "area_effect_cloud".
    05 FILLER              PIC X(24) VALUE "DurationOnUse".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC X(24) VALUE "area_effect_cloud".
    05 FILLER              PIC X(24) VALUE "RadiusOnUse".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 6.
    05 FILLER              PIC X(24) VALUE "area_effect_cloud".
    05 FILLER              PIC X(24) VALUE "RadiusPerTick".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 7.
    05 FILLER              PIC X(24) VALUE "area_effect_cloud".
    05 FILLER              PIC X(24) VALUE "Radius".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 3.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 8.
    05 FILLER              PIC X(24) VALUE "area_effect_cloud".
    05 FILLER              PIC X(24) VALUE "custom_particle".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 9.
    05 FILLER              PIC X(24) VALUE "area_effect_cloud".
    05 FILLER              PIC X(24) VALUE "Owner".
    05 FILLER              PIC 99 VALUE 11.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC X(24) VALUE "area_effect_cloud".
    05 FILLER              PIC X(24) VALUE "potion_contents".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 11.
    05 FILLER              PIC X(24) VALUE "area_effect_cloud".
    05 FILLER              PIC X(24) VALUE "potion_duration_scale".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 1.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 12.
    05 FILLER              PIC X(24) VALUE "interaction".
    05 FILLER              PIC X(24) VALUE "width".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 1.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "interaction".
    05 FILLER              PIC X(24) VALUE "height".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 1.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 2.
    05 FILLER              PIC X(24) VALUE "interaction".
    05 FILLER              PIC X(24) VALUE "attack".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC X(24) VALUE "interaction".
    05 FILLER              PIC X(24) VALUE "interaction".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 4.
    05 FILLER              PIC X(24) VALUE "interaction".
    05 FILLER              PIC X(24) VALUE "response".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC X(24) VALUE "block_display".
    05 FILLER              PIC X(24) VALUE "billboard".
    05 FILLER              PIC 99 VALUE 8.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "fixed".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "block_display".
    05 FILLER              PIC X(24) VALUE "interpolation_duration".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 2.
    05 FILLER              PIC X(24) VALUE "block_display".
    05 FILLER              PIC X(24) VALUE "teleport_duration".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC X(24) VALUE "block_display".
    05 FILLER              PIC X(24) VALUE "view_range".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 1.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 4.
    05 FILLER              PIC X(24) VALUE "block_display".
    05 FILLER              PIC X(24) VALUE "shadow_radius".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC X(24) VALUE "block_display".
    05 FILLER              PIC X(24) VALUE "shadow_strength".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 1.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 6.
    05 FILLER              PIC X(24) VALUE "block_display".
    05 FILLER              PIC X(24) VALUE "width".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 7.
    05 FILLER              PIC X(24) VALUE "block_display".
    05 FILLER              PIC X(24) VALUE "height".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 8.
    05 FILLER              PIC X(24) VALUE "block_display".
    05 FILLER              PIC X(24) VALUE "glow_color_override".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE -1.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 9.
    05 FILLER              PIC X(24) VALUE "block_display".
    05 FILLER              PIC X(24) VALUE "transformation".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC X(24) VALUE "block_display".
    05 FILLER              PIC X(24) VALUE "brightness".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 11.
    05 FILLER              PIC X(24) VALUE "item_display".
    05 FILLER              PIC X(24) VALUE "billboard".
    05 FILLER              PIC 99 VALUE 8.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "fixed".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "item_display".
    05 FILLER              PIC X(24) VALUE "interpolation_duration".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 2.
    05 FILLER              PIC X(24) VALUE "item_display".
    05 FILLER              PIC X(24) VALUE "teleport_duration".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC X(24) VALUE "item_display".
    05 FILLER              PIC X(24) VALUE "view_range".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 1.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 4.
    05 FILLER              PIC X(24) VALUE "item_display".
    05 FILLER              PIC X(24) VALUE "shadow_radius".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC X(24) VALUE "item_display".
    05 FILLER              PIC X(24) VALUE "shadow_strength".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 1.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 6.
    05 FILLER              PIC X(24) VALUE "item_display".
    05 FILLER              PIC X(24) VALUE "width".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 7.
    05 FILLER              PIC X(24) VALUE "item_display".
    05 FILLER              PIC X(24) VALUE "height".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 8.
    05 FILLER              PIC X(24) VALUE "item_display".
    05 FILLER              PIC X(24) VALUE "glow_color_override".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE -1.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 9.
    05 FILLER              PIC X(24) VALUE "item_display".
    05 FILLER              PIC X(24) VALUE "transformation".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC X(24) VALUE "item_display".
    05 FILLER              PIC X(24) VALUE "brightness".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 11.
    05 FILLER              PIC X(24) VALUE "text_display".
    05 FILLER              PIC X(24) VALUE "billboard".
    05 FILLER              PIC 99 VALUE 8.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "fixed".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "text_display".
    05 FILLER              PIC X(24) VALUE "interpolation_duration".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 2.
    05 FILLER              PIC X(24) VALUE "text_display".
    05 FILLER              PIC X(24) VALUE "teleport_duration".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC X(24) VALUE "text_display".
    05 FILLER              PIC X(24) VALUE "view_range".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 1.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 4.
    05 FILLER              PIC X(24) VALUE "text_display".
    05 FILLER              PIC X(24) VALUE "shadow_radius".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC X(24) VALUE "text_display".
    05 FILLER              PIC X(24) VALUE "shadow_strength".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 1.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 6.
    05 FILLER              PIC X(24) VALUE "text_display".
    05 FILLER              PIC X(24) VALUE "width".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 7.
    05 FILLER              PIC X(24) VALUE "text_display".
    05 FILLER              PIC X(24) VALUE "height".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 8.
    05 FILLER              PIC X(24) VALUE "text_display".
    05 FILLER              PIC X(24) VALUE "glow_color_override".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE -1.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 9.
    05 FILLER              PIC X(24) VALUE "text_display".
    05 FILLER              PIC X(24) VALUE "transformation".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC X(24) VALUE "text_display".
    05 FILLER              PIC X(24) VALUE "brightness".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 11.
    05 FILLER              PIC X(24) VALUE "block_display".
    05 FILLER              PIC X(24) VALUE "block_state".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 12.
    05 FILLER              PIC X(24) VALUE "item_display".
    05 FILLER              PIC X(24) VALUE "item".
    05 FILLER              PIC 99 VALUE 10.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 12.
    05 FILLER              PIC X(24) VALUE "item_display".
    05 FILLER              PIC X(24) VALUE "item_display".
    05 FILLER              PIC 99 VALUE 8.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "none".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 13.
    05 FILLER              PIC X(24) VALUE "text_display".
    05 FILLER              PIC X(24) VALUE "line_width".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 200.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 12.
    05 FILLER              PIC X(24) VALUE "text_display".
    05 FILLER              PIC X(24) VALUE "background".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 1073741824.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 13.
    05 FILLER              PIC X(24) VALUE "text_display".
    05 FILLER              PIC X(24) VALUE "text_opacity".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE -1.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 14.
    05 FILLER              PIC X(24) VALUE "text_display".
    05 FILLER              PIC X(24) VALUE "shadow".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 15.
    05 FILLER              PIC X(24) VALUE "text_display".
    05 FILLER              PIC X(24) VALUE "see_through".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 16.
    05 FILLER              PIC X(24) VALUE "text_display".
    05 FILLER              PIC X(24) VALUE "default_background".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 17.
    05 FILLER              PIC X(24) VALUE "text_display".
    05 FILLER              PIC X(24) VALUE "alignment".
    05 FILLER              PIC 99 VALUE 8.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE "center".
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 18.
    05 FILLER              PIC X(24) VALUE "wither".
    05 FILLER              PIC X(24) VALUE "Invul".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "ender_dragon".
    05 FILLER              PIC X(24) VALUE "DragonPhase".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC X(24) VALUE "ender_dragon".
    05 FILLER              PIC X(24) VALUE "DragonDeathTime".
    05 FILLER              PIC 99 VALUE 3.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 2.
    05 FILLER              PIC X(24) VALUE "ender_dragon".
    05 FILLER              PIC X(24) VALUE "sitting_damage_received".
    05 FILLER              PIC 99 VALUE 5.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "A".
    05 FILLER              PIC 99 VALUE 3.
*>   The Johnny flag of a vindicator (45-6 section 2: a Byte written when set, read default 0; 20 section 13.1; JOHNNY-IS, core/src/mob-20-johnny.cob). Slot 2 (slot 1 is its RaidId).
    05 FILLER              PIC X(24) VALUE "vindicator".
    05 FILLER              PIC X(24) VALUE "Johnny".
    05 FILLER              PIC 99 VALUE 1.
    05 FILLER              PIC S9(10) SIGN LEADING SEPARATE VALUE 0.
    05 FILLER              PIC X(24) VALUE SPACES.
    05 FILLER              PIC X VALUE "C".
    05 FILLER              PIC 99 VALUE 2.
 01 SPX-TABLE REDEFINES SPX-TABLE-VALUES.
    05 SPX-ROW OCCURS SPX-ROWS TIMES.
       10 SPX-SPECIES   PIC X(24).
       10 SPX-KEY       PIC X(24).
       10 SPX-TAG       PIC 99.
       10 SPX-DEF       PIC S9(10) SIGN LEADING SEPARATE.
       10 SPX-TEXT      PIC X(24).
       10 SPX-MODE      PIC X.
       10 SPX-SLOT      PIC 99.
