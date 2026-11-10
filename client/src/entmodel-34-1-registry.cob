*> Entity models part 1 section 4 (docs/protocol/34-entity-models-1-shared-model-and-framework.md): the model layer registry (Appendix A: 292 fields,
*> 269 single layers and 23 armor sets, 361 layers) and the animation definition ids (4.4).
*> Entry points for the integrator (inputs):
*>   EM4-LAYER-COUNTS fields single-layers armor-sets layers (out): 292 269 23 361.
*>   EM4-LAYER-ID index(1..361) id(X(60), out): "minecraft:<model>#<layer>" in the order of Appendix A (an armor set field expands to the layers helmet,
*>     chestplate, leggings, boots); spaces past the end. EM4-LAYER-FIND id(X(60)) index(out, 0 = unknown location: bakeLayer would throw).
*>   EM4-FIELD-LAYERS field(X(28), the ModelLayers field name) first-index count (out; 0 for an unknown field). EM4-LAYER-DUPLICATES n (out).
*>   EM4-ANIM-ID class(X(28)) field(X(28)) id(X(60), out "Class.FIELD") known(out 1 for one of the 16 definition classes of 5.6);
*>     EM4-ANIM-CLASS-COUNT n.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM4-FIELD-ROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TABLE.
    05 FILLER PIC X(80) VALUE "ACACIA_BOAT                 boat/acacia                 main                    ".
    05 FILLER PIC X(80) VALUE "ACACIA_CHEST_BOAT           chest_boat/acacia           main                    ".
    05 FILLER PIC X(80) VALUE "ALLAY                       allay                       main                    ".
    05 FILLER PIC X(80) VALUE "ARMADILLO                   armadillo                   main                    ".
    05 FILLER PIC X(80) VALUE "ARMADILLO_BABY              armadillo_baby              main                    ".
    05 FILLER PIC X(80) VALUE "ARMOR_STAND                 armor_stand                 main                    ".
    05 FILLER PIC X(80) VALUE "ARMOR_STAND_ARMOR           armor_stand                 #armor-set              ".
    05 FILLER PIC X(80) VALUE "ARMOR_STAND_SMALL           armor_stand_small           main                    ".
    05 FILLER PIC X(80) VALUE "ARMOR_STAND_SMALL_ARMOR     armor_stand_small           #armor-set              ".
    05 FILLER PIC X(80) VALUE "ARROW                       arrow                       main                    ".
    05 FILLER PIC X(80) VALUE "AXOLOTL                     axolotl                     main                    ".
    05 FILLER PIC X(80) VALUE "AXOLOTL_BABY                axolotl_baby                main                    ".
    05 FILLER PIC X(80) VALUE "BAMBOO_CHEST_RAFT           chest_boat/bamboo           main                    ".
    05 FILLER PIC X(80) VALUE "BAMBOO_RAFT                 boat/bamboo                 main                    ".
    05 FILLER PIC X(80) VALUE "STANDING_BANNER             standing_banner             main                    ".
    05 FILLER PIC X(80) VALUE "STANDING_BANNER_FLAG        standing_banner             flag                    ".
    05 FILLER PIC X(80) VALUE "WALL_BANNER                 wall_banner                 main                    ".
    05 FILLER PIC X(80) VALUE "WALL_BANNER_FLAG            wall_banner                 flag                    ".
    05 FILLER PIC X(80) VALUE "BAT                         bat                         main                    ".
    05 FILLER PIC X(80) VALUE "BEE                         bee                         main                    ".
    05 FILLER PIC X(80) VALUE "BEE_BABY                    bee_baby                    main                    ".
    05 FILLER PIC X(80) VALUE "BEE_STINGER                 bee_stinger                 main                    ".
    05 FILLER PIC X(80) VALUE "BELL                        bell                        main                    ".
    05 FILLER PIC X(80) VALUE "BIRCH_BOAT                  boat/birch                  main                    ".
    05 FILLER PIC X(80) VALUE "BIRCH_CHEST_BOAT            chest_boat/birch            main                    ".
    05 FILLER PIC X(80) VALUE "BLAZE                       blaze                       main                    ".
    05 FILLER PIC X(80) VALUE "BOAT_WATER_PATCH            boat                        water_patch             ".
    05 FILLER PIC X(80) VALUE "BOGGED                      bogged                      main                    ".
    05 FILLER PIC X(80) VALUE "BOGGED_ARMOR                bogged                      #armor-set              ".
    05 FILLER PIC X(80) VALUE "BOGGED_OUTER_LAYER          bogged                      outer                   ".
    05 FILLER PIC X(80) VALUE "BOOK                        book                        main                    ".
    05 FILLER PIC X(80) VALUE "BREEZE                      breeze                      main                    ".
    05 FILLER PIC X(80) VALUE "BREEZE_WIND                 breeze                      wind                    ".
    05 FILLER PIC X(80) VALUE "BREEZE_EYES                 breeze                      eyes                    ".
    05 FILLER PIC X(80) VALUE "CAMEL                       camel                       main                    ".
    05 FILLER PIC X(80) VALUE "CAMEL_BABY                  camel_baby                  main                    ".
    05 FILLER PIC X(80) VALUE "CAMEL_SADDLE                camel                       saddle                  ".
    05 FILLER PIC X(80) VALUE "CAMEL_HUSK_SADDLE           camel_husk                  saddle                  ".
    05 FILLER PIC X(80) VALUE "CAT                         cat                         main                    ".
    05 FILLER PIC X(80) VALUE "CAT_BABY                    cat_baby                    main                    ".
    05 FILLER PIC X(80) VALUE "CAT_BABY_COLLAR             cat_baby                    collar                  ".
    05 FILLER PIC X(80) VALUE "CAT_COLLAR                  cat                         collar                  ".
    05 FILLER PIC X(80) VALUE "CAVE_SPIDER                 cave_spider                 main                    ".
    05 FILLER PIC X(80) VALUE "CHERRY_BOAT                 boat/cherry                 main                    ".
    05 FILLER PIC X(80) VALUE "CHERRY_CHEST_BOAT           chest_boat/cherry           main                    ".
    05 FILLER PIC X(80) VALUE "CHEST                       chest                       main                    ".
    05 FILLER PIC X(80) VALUE "CHEST_MINECART              chest_minecart              main                    ".
    05 FILLER PIC X(80) VALUE "CHICKEN                     chicken                     main                    ".
    05 FILLER PIC X(80) VALUE "CHICKEN_BABY                chicken_baby                main                    ".
    05 FILLER PIC X(80) VALUE "COD                         cod                         main                    ".
    05 FILLER PIC X(80) VALUE "COLD_CHICKEN                cold_chicken                main                    ".
    05 FILLER PIC X(80) VALUE "COLD_COW                    cold_cow                    main                    ".
    05 FILLER PIC X(80) VALUE "COLD_COW_BABY               cold_cow_baby               main                    ".
    05 FILLER PIC X(80) VALUE "COLD_PIG                    cold_pig                    main                    ".
    05 FILLER PIC X(80) VALUE "COMMAND_BLOCK_MINECART      command_block_minecart      main                    ".
    05 FILLER PIC X(80) VALUE "CONDUIT_CAGE                conduit                     cage                    ".
    05 FILLER PIC X(80) VALUE "CONDUIT_EYE                 conduit                     eye                     ".
    05 FILLER PIC X(80) VALUE "CONDUIT_SHELL               conduit                     shell                   ".
    05 FILLER PIC X(80) VALUE "CONDUIT_WIND                conduit                     wind                    ".
    05 FILLER PIC X(80) VALUE "COPPER_GOLEM                copper_golem                main                    ".
    05 FILLER PIC X(80) VALUE "COPPER_GOLEM_EYES           copper_golem                eyes                    ".
    05 FILLER PIC X(80) VALUE "COPPER_GOLEM_RUNNING        copper_golem_running        main                    ".
    05 FILLER PIC X(80) VALUE "COPPER_GOLEM_SITTING        copper_golem_sitting        main                    ".
    05 FILLER PIC X(80) VALUE "COPPER_GOLEM_STAR           copper_golem_star           main                    ".
    05 FILLER PIC X(80) VALUE "ZOMBIE_NAUTILUS_CORAL       zombie_nautilus_coral       main                    ".
    05 FILLER PIC X(80) VALUE "COW                         cow                         main                    ".
    05 FILLER PIC X(80) VALUE "COW_BABY                    cow_baby                    main                    ".
    05 FILLER PIC X(80) VALUE "CREAKING                    creaking                    main                    ".
    05 FILLER PIC X(80) VALUE "CREAKING_EYES               creaking                    eyes                    ".
    05 FILLER PIC X(80) VALUE "CREEPER                     creeper                     main                    ".
    05 FILLER PIC X(80) VALUE "CREEPER_ARMOR               creeper                     armor                   ".
    05 FILLER PIC X(80) VALUE "CREEPER_HEAD                creeper_head                main                    ".
    05 FILLER PIC X(80) VALUE "CUSHION                     cushion                     main                    ".
    05 FILLER PIC X(80) VALUE "DARK_OAK_BOAT               boat/dark_oak               main                    ".
    05 FILLER PIC X(80) VALUE "DARK_OAK_CHEST_BOAT         chest_boat/dark_oak         main                    ".
    05 FILLER PIC X(80) VALUE "DECORATED_POT_BASE          decorated_pot_base          main                    ".
    05 FILLER PIC X(80) VALUE "DECORATED_POT_SIDES         decorated_pot_sides         main                    ".
    05 FILLER PIC X(80) VALUE "DOLPHIN                     dolphin                     main                    ".
    05 FILLER PIC X(80) VALUE "DOLPHIN_BABY                dolphin_baby                main                    ".
    05 FILLER PIC X(80) VALUE "DONKEY                      donkey                      main                    ".
    05 FILLER PIC X(80) VALUE "DONKEY_BABY                 donkey_baby                 main                    ".
    05 FILLER PIC X(80) VALUE "DONKEY_SADDLE               donkey                      saddle                  ".
    05 FILLER PIC X(80) VALUE "DOUBLE_CHEST_LEFT           double_chest_left           main                    ".
    05 FILLER PIC X(80) VALUE "DOUBLE_CHEST_RIGHT          double_chest_right          main                    ".
    05 FILLER PIC X(80) VALUE "DRAGON_SKULL                dragon_skull                main                    ".
    05 FILLER PIC X(80) VALUE "DROWNED                     drowned                     main                    ".
    05 FILLER PIC X(80) VALUE "DROWNED_BABY                drowned_baby                main                    ".
    05 FILLER PIC X(80) VALUE "DROWNED_BABY_ARMOR          drowned_baby                #armor-set              ".
    05 FILLER PIC X(80) VALUE "DROWNED_BABY_OUTER_LAYER    drowned_baby                outer                   ".
    05 FILLER PIC X(80) VALUE "DROWNED_ARMOR               drowned                     #armor-set              ".
    05 FILLER PIC X(80) VALUE "DROWNED_OUTER_LAYER         drowned                     outer                   ".
    05 FILLER PIC X(80) VALUE "ELDER_GUARDIAN              elder_guardian              main                    ".
    05 FILLER PIC X(80) VALUE "ELYTRA                      elytra                      main                    ".
    05 FILLER PIC X(80) VALUE "ELYTRA_BABY                 elytra_baby                 main                    ".
    05 FILLER PIC X(80) VALUE "ENDERMAN                    enderman                    main                    ".
    05 FILLER PIC X(80) VALUE "ENDERMITE                   endermite                   main                    ".
    05 FILLER PIC X(80) VALUE "ENDER_DRAGON                ender_dragon                main                    ".
    05 FILLER PIC X(80) VALUE "END_CRYSTAL                 end_crystal                 main                    ".
    05 FILLER PIC X(80) VALUE "EVOKER                      evoker                      main                    ".
    05 FILLER PIC X(80) VALUE "EVOKER_FANGS                evoker_fangs                main                    ".
    05 FILLER PIC X(80) VALUE "FOX                         fox                         main                    ".
    05 FILLER PIC X(80) VALUE "FOX_BABY                    fox_baby                    main                    ".
    05 FILLER PIC X(80) VALUE "FROG                        frog                        main                    ".
    05 FILLER PIC X(80) VALUE "FURNACE_MINECART            furnace_minecart            main                    ".
    05 FILLER PIC X(80) VALUE "GHAST                       ghast                       main                    ".
    05 FILLER PIC X(80) VALUE "GIANT                       giant                       main                    ".
    05 FILLER PIC X(80) VALUE "GIANT_ARMOR                 giant                       #armor-set              ".
    05 FILLER PIC X(80) VALUE "GLOW_SQUID                  glow_squid                  main                    ".
    05 FILLER PIC X(80) VALUE "GLOW_SQUID_BABY             glow_squid_baby             main                    ".
    05 FILLER PIC X(80) VALUE "GOAT                        goat                        main                    ".
    05 FILLER PIC X(80) VALUE "GOAT_BABY                   goat_baby                   main                    ".
    05 FILLER PIC X(80) VALUE "GUARDIAN                    guardian                    main                    ".
    05 FILLER PIC X(80) VALUE "HAPPY_GHAST                 happy_ghast                 main                    ".
    05 FILLER PIC X(80) VALUE "HAPPY_GHAST_BABY            happy_ghast_baby            main                    ".
    05 FILLER PIC X(80) VALUE "HAPPY_GHAST_HARNESS         happy_ghast_harness         main                    ".
    05 FILLER PIC X(80) VALUE "HAPPY_GHAST_BABY_HARNESS    happy_ghast_baby_harness    main                    ".
    05 FILLER PIC X(80) VALUE "HAPPY_GHAST_ROPES           happy_ghast_ropes           main                    ".
    05 FILLER PIC X(80) VALUE "HAPPY_GHAST_BABY_ROPES      happy_ghast_baby_ropes      main                    ".
    05 FILLER PIC X(80) VALUE "HOGLIN                      hoglin                      main                    ".
    05 FILLER PIC X(80) VALUE "HOGLIN_BABY                 hoglin_baby                 main                    ".
    05 FILLER PIC X(80) VALUE "HOPPER_MINECART             hopper_minecart             main                    ".
    05 FILLER PIC X(80) VALUE "HORSE                       horse                       main                    ".
    05 FILLER PIC X(80) VALUE "HORSE_ARMOR                 horse_armor                 main                    ".
    05 FILLER PIC X(80) VALUE "HORSE_SADDLE                horse                       saddle                  ".
    05 FILLER PIC X(80) VALUE "HORSE_BABY                  horse_baby                  main                    ".
    05 FILLER PIC X(80) VALUE "HUSK                        husk                        main                    ".
    05 FILLER PIC X(80) VALUE "HUSK_BABY                   husk_baby                   main                    ".
    05 FILLER PIC X(80) VALUE "HUSK_BABY_ARMOR             husk_baby                   #armor-set              ".
    05 FILLER PIC X(80) VALUE "HUSK_ARMOR                  husk                        #armor-set              ".
    05 FILLER PIC X(80) VALUE "ILLUSIONER                  illusioner                  main                    ".
    05 FILLER PIC X(80) VALUE "IRON_GOLEM                  iron_golem                  main                    ".
    05 FILLER PIC X(80) VALUE "JUNGLE_BOAT                 boat/jungle                 main                    ".
    05 FILLER PIC X(80) VALUE "JUNGLE_CHEST_BOAT           chest_boat/jungle           main                    ".
    05 FILLER PIC X(80) VALUE "LEASH_KNOT                  leash_knot                  main                    ".
    05 FILLER PIC X(80) VALUE "LLAMA                       llama                       main                    ".
    05 FILLER PIC X(80) VALUE "LLAMA_BABY                  llama_baby                  main                    ".
    05 FILLER PIC X(80) VALUE "LLAMA_BABY_DECOR            llama_baby                  decor                   ".
    05 FILLER PIC X(80) VALUE "LLAMA_DECOR                 llama                       decor                   ".
    05 FILLER PIC X(80) VALUE "LLAMA_SPIT                  llama_spit                  main                    ".
    05 FILLER PIC X(80) VALUE "MAGMA_CUBE                  magma_cube                  main                    ".
    05 FILLER PIC X(80) VALUE "MANGROVE_BOAT               boat/mangrove               main                    ".
    05 FILLER PIC X(80) VALUE "MANGROVE_CHEST_BOAT         chest_boat/mangrove         main                    ".
    05 FILLER PIC X(80) VALUE "MINECART                    minecart                    main                    ".
    05 FILLER PIC X(80) VALUE "MOOSHROOM                   mooshroom                   main                    ".
    05 FILLER PIC X(80) VALUE "MOOSHROOM_BABY              mooshroom_baby              main                    ".
    05 FILLER PIC X(80) VALUE "MULE                        mule                        main                    ".
    05 FILLER PIC X(80) VALUE "MULE_BABY                   mule_baby                   main                    ".
    05 FILLER PIC X(80) VALUE "MULE_SADDLE                 mule                        saddle                  ".
    05 FILLER PIC X(80) VALUE "NAUTILUS                    nautilus                    main                    ".
    05 FILLER PIC X(80) VALUE "NAUTILUS_BABY               nautilus_baby               main                    ".
    05 FILLER PIC X(80) VALUE "NAUTILUS_SADDLE             nautilus                    saddle                  ".
    05 FILLER PIC X(80) VALUE "NAUTILUS_ARMOR              nautilus_armor              main                    ".
    05 FILLER PIC X(80) VALUE "OAK_BOAT                    boat/oak                    main                    ".
    05 FILLER PIC X(80) VALUE "OAK_CHEST_BOAT              chest_boat/oak              main                    ".
    05 FILLER PIC X(80) VALUE "OCELOT                      ocelot                      main                    ".
    05 FILLER PIC X(80) VALUE "OCELOT_BABY                 ocelot_baby                 main                    ".
    05 FILLER PIC X(80) VALUE "PALE_OAK_BOAT               boat/pale_oak               main                    ".
    05 FILLER PIC X(80) VALUE "PALE_OAK_CHEST_BOAT         chest_boat/pale_oak         main                    ".
    05 FILLER PIC X(80) VALUE "PANDA                       panda                       main                    ".
    05 FILLER PIC X(80) VALUE "PANDA_BABY                  panda_baby                  main                    ".
    05 FILLER PIC X(80) VALUE "PARCHED                     parched                     main                    ".
    05 FILLER PIC X(80) VALUE "PARCHED_ARMOR               parched                     #armor-set              ".
    05 FILLER PIC X(80) VALUE "PARCHED_OUTER_LAYER         parched                     outer                   ".
    05 FILLER PIC X(80) VALUE "PARROT                      parrot                      main                    ".
    05 FILLER PIC X(80) VALUE "PHANTOM                     phantom                     main                    ".
    05 FILLER PIC X(80) VALUE "PIG                         pig                         main                    ".
    05 FILLER PIC X(80) VALUE "PIGLIN                      piglin                      main                    ".
    05 FILLER PIC X(80) VALUE "PIGLIN_BABY                 piglin_baby                 main                    ".
    05 FILLER PIC X(80) VALUE "PIGLIN_BABY_ARMOR           piglin_baby                 #armor-set              ".
    05 FILLER PIC X(80) VALUE "PIGLIN_BRUTE                piglin_brute                main                    ".
    05 FILLER PIC X(80) VALUE "PIGLIN_BRUTE_ARMOR          piglin_brute                #armor-set              ".
    05 FILLER PIC X(80) VALUE "PIGLIN_HEAD                 piglin_head                 main                    ".
    05 FILLER PIC X(80) VALUE "PIGLIN_ARMOR                piglin                      #armor-set              ".
    05 FILLER PIC X(80) VALUE "PIG_BABY                    pig_baby                    main                    ".
    05 FILLER PIC X(80) VALUE "PIG_SADDLE                  pig                         saddle                  ".
    05 FILLER PIC X(80) VALUE "PILLAGER                    pillager                    main                    ".
    05 FILLER PIC X(80) VALUE "PLAYER                      player                      main                    ".
    05 FILLER PIC X(80) VALUE "PLAYER_CAPE                 player                      cape                    ".
    05 FILLER PIC X(80) VALUE "PLAYER_EARS                 player                      ears                    ".
    05 FILLER PIC X(80) VALUE "PLAYER_HEAD                 player_head                 main                    ".
    05 FILLER PIC X(80) VALUE "PLAYER_ARMOR                player                      #armor-set              ".
    05 FILLER PIC X(80) VALUE "PLAYER_SLIM                 player_slim                 main                    ".
    05 FILLER PIC X(80) VALUE "PLAYER_SLIM_ARMOR           player_slim                 #armor-set              ".
    05 FILLER PIC X(80) VALUE "PLAYER_SPIN_ATTACK          spin_attack                 main                    ".
    05 FILLER PIC X(80) VALUE "POLAR_BEAR                  polar_bear                  main                    ".
    05 FILLER PIC X(80) VALUE "POLAR_BEAR_BABY             polar_bear_baby             main                    ".
    05 FILLER PIC X(80) VALUE "POPLAR_BOAT                 boat/poplar                 main                    ".
    05 FILLER PIC X(80) VALUE "POPLAR_CHEST_BOAT           chest_boat/poplar           main                    ".
    05 FILLER PIC X(80) VALUE "PUFFERFISH_BIG              pufferfish_big              main                    ".
    05 FILLER PIC X(80) VALUE "PUFFERFISH_MEDIUM           pufferfish_medium           main                    ".
    05 FILLER PIC X(80) VALUE "PUFFERFISH_SMALL            pufferfish_small            main                    ".
    05 FILLER PIC X(80) VALUE "RABBIT                      rabbit                      main                    ".
    05 FILLER PIC X(80) VALUE "RABBIT_BABY                 rabbit_baby                 main                    ".
    05 FILLER PIC X(80) VALUE "RAVAGER                     ravager                     main                    ".
    05 FILLER PIC X(80) VALUE "SALMON                      salmon                      main                    ".
    05 FILLER PIC X(80) VALUE "SALMON_LARGE                salmon_large                main                    ".
    05 FILLER PIC X(80) VALUE "SALMON_SMALL                salmon_small                main                    ".
    05 FILLER PIC X(80) VALUE "SHEEP                       sheep                       main                    ".
    05 FILLER PIC X(80) VALUE "SHEEP_BABY                  sheep_baby                  main                    ".
    05 FILLER PIC X(80) VALUE "SHEEP_BABY_WOOL             sheep_baby                  wool                    ".
    05 FILLER PIC X(80) VALUE "SHEEP_WOOL                  sheep                       wool                    ".
    05 FILLER PIC X(80) VALUE "SHEEP_WOOL_UNDERCOAT        sheep                       wool_undercoat          ".
    05 FILLER PIC X(80) VALUE "SHIELD                      shield                      main                    ".
    05 FILLER PIC X(80) VALUE "SHULKER                     shulker                     main                    ".
    05 FILLER PIC X(80) VALUE "SHULKER_BOX                 shulker_box                 main                    ".
    05 FILLER PIC X(80) VALUE "SHULKER_BULLET              shulker_bullet              main                    ".
    05 FILLER PIC X(80) VALUE "SILVERFISH                  silverfish                  main                    ".
    05 FILLER PIC X(80) VALUE "SKELETON                    skeleton                    main                    ".
    05 FILLER PIC X(80) VALUE "SKELETON_HORSE              skeleton_horse              main                    ".
    05 FILLER PIC X(80) VALUE "SKELETON_HORSE_BABY         skeleton_horse_baby         main                    ".
    05 FILLER PIC X(80) VALUE "SKELETON_HORSE_SADDLE       skeleton_horse              saddle                  ".
    05 FILLER PIC X(80) VALUE "SKELETON_ARMOR              skeleton                    #armor-set              ".
    05 FILLER PIC X(80) VALUE "SKELETON_SKULL              skeleton_skull              main                    ".
    05 FILLER PIC X(80) VALUE "SLIME                       slime                       main                    ".
    05 FILLER PIC X(80) VALUE "SLIME_OUTER                 slime                       outer                   ".
    05 FILLER PIC X(80) VALUE "SNIFFER                     sniffer                     main                    ".
    05 FILLER PIC X(80) VALUE "SNIFFER_BABY                sniffer_baby                main                    ".
    05 FILLER PIC X(80) VALUE "SNOW_GOLEM                  snow_golem                  main                    ".
    05 FILLER PIC X(80) VALUE "SPAWNER_MINECART            spawner_minecart            main                    ".
    05 FILLER PIC X(80) VALUE "SPIDER                      spider                      main                    ".
    05 FILLER PIC X(80) VALUE "SPRUCE_BOAT                 boat/spruce                 main                    ".
    05 FILLER PIC X(80) VALUE "SPRUCE_CHEST_BOAT           chest_boat/spruce           main                    ".
    05 FILLER PIC X(80) VALUE "SQUID                       squid                       main                    ".
    05 FILLER PIC X(80) VALUE "SQUID_BABY                  squid_baby                  main                    ".
    05 FILLER PIC X(80) VALUE "STRAY                       stray                       main                    ".
    05 FILLER PIC X(80) VALUE "STRAY_ARMOR                 stray                       #armor-set              ".
    05 FILLER PIC X(80) VALUE "STRAY_OUTER_LAYER           stray                       outer                   ".
    05 FILLER PIC X(80) VALUE "STRIDER                     strider                     main                    ".
    05 FILLER PIC X(80) VALUE "STRIDER_SADDLE              strider                     saddle                  ".
    05 FILLER PIC X(80) VALUE "STRIDER_BABY                strider_baby                main                    ".
    05 FILLER PIC X(80) VALUE "SULFUR_CUBE                 sulfur_cube                 main                    ".
    05 FILLER PIC X(80) VALUE "SULFUR_CUBE_INNER           sulfur_cube                 inner                   ".
    05 FILLER PIC X(80) VALUE "SULFUR_CUBE_SMALL           sulfur_cube_small           main                    ".
    05 FILLER PIC X(80) VALUE "SULFUR_CUBE_SMALL_INNER     sulfur_cube_small           inner                   ".
    05 FILLER PIC X(80) VALUE "TADPOLE                     tadpole                     main                    ".
    05 FILLER PIC X(80) VALUE "TNT_MINECART                tnt_minecart                main                    ".
    05 FILLER PIC X(80) VALUE "TRADER_LLAMA                trader_llama                main                    ".
    05 FILLER PIC X(80) VALUE "TRADER_LLAMA_BABY           trader_llama_baby           main                    ".
    05 FILLER PIC X(80) VALUE "TRIDENT                     trident                     main                    ".
    05 FILLER PIC X(80) VALUE "TROPICAL_FISH_LARGE         tropical_fish_large         main                    ".
    05 FILLER PIC X(80) VALUE "TROPICAL_FISH_LARGE_PATTERN tropical_fish_large         pattern                 ".
    05 FILLER PIC X(80) VALUE "TROPICAL_FISH_SMALL         tropical_fish_small         main                    ".
    05 FILLER PIC X(80) VALUE "TROPICAL_FISH_SMALL_PATTERN tropical_fish_small         pattern                 ".
    05 FILLER PIC X(80) VALUE "TURTLE                      turtle                      main                    ".
    05 FILLER PIC X(80) VALUE "TURTLE_BABY                 turtle_baby                 main                    ".
    05 FILLER PIC X(80) VALUE "UNDEAD_HORSE_ARMOR          undead_horse_armor          main                    ".
    05 FILLER PIC X(80) VALUE "VEX                         vex                         main                    ".
    05 FILLER PIC X(80) VALUE "VILLAGER                    villager                    main                    ".
    05 FILLER PIC X(80) VALUE "VILLAGER_NO_HAT             villager_no_hat             main                    ".
    05 FILLER PIC X(80) VALUE "VILLAGER_BABY               villager_baby               main                    ".
    05 FILLER PIC X(80) VALUE "VILLAGER_BABY_NO_HAT        villager_baby_no_hat        main                    ".
    05 FILLER PIC X(80) VALUE "VINDICATOR                  vindicator                  main                    ".
    05 FILLER PIC X(80) VALUE "WANDERING_TRADER            wandering_trader            main                    ".
    05 FILLER PIC X(80) VALUE "WARDEN                      warden                      main                    ".
    05 FILLER PIC X(80) VALUE "WARDEN_BIOLUMINESCENT       warden                      bioluminescent          ".
    05 FILLER PIC X(80) VALUE "WARDEN_PULSATING_SPOTS      warden                      pulsating_spots         ".
    05 FILLER PIC X(80) VALUE "WARDEN_TENDRILS             warden                      tendrils                ".
    05 FILLER PIC X(80) VALUE "WARDEN_HEART                warden                      heart                   ".
    05 FILLER PIC X(80) VALUE "WARM_COW                    warm_cow                    main                    ".
    05 FILLER PIC X(80) VALUE "WARM_COW_BABY               warm_cow_baby               main                    ".
    05 FILLER PIC X(80) VALUE "WIND_CHARGE                 wind_charge                 main                    ".
    05 FILLER PIC X(80) VALUE "WITCH                       witch                       main                    ".
    05 FILLER PIC X(80) VALUE "WITHER                      wither                      main                    ".
    05 FILLER PIC X(80) VALUE "WITHER_ARMOR                wither                      armor                   ".
    05 FILLER PIC X(80) VALUE "WITHER_SKELETON             wither_skeleton             main                    ".
    05 FILLER PIC X(80) VALUE "WITHER_SKELETON_ARMOR       wither_skeleton             #armor-set              ".
    05 FILLER PIC X(80) VALUE "WITHER_SKELETON_SKULL       wither_skeleton_skull       main                    ".
    05 FILLER PIC X(80) VALUE "WITHER_SKULL                wither_skull                main                    ".
    05 FILLER PIC X(80) VALUE "WOLF                        wolf                        main                    ".
    05 FILLER PIC X(80) VALUE "WOLF_ARMOR                  wolf_armor                  main                    ".
    05 FILLER PIC X(80) VALUE "WOLF_BABY                   wolf_baby                   main                    ".
    05 FILLER PIC X(80) VALUE "ZOGLIN                      zoglin                      main                    ".
    05 FILLER PIC X(80) VALUE "ZOGLIN_BABY                 zoglin_baby                 main                    ".
    05 FILLER PIC X(80) VALUE "ZOMBIE                      zombie                      main                    ".
    05 FILLER PIC X(80) VALUE "ZOMBIE_BABY                 zombie_baby                 main                    ".
    05 FILLER PIC X(80) VALUE "ZOMBIE_BABY_ARMOR           zombie_baby                 #armor-set              ".
    05 FILLER PIC X(80) VALUE "ZOMBIE_HEAD                 zombie_head                 main                    ".
    05 FILLER PIC X(80) VALUE "ZOMBIE_HORSE                zombie_horse                main                    ".
    05 FILLER PIC X(80) VALUE "ZOMBIE_HORSE_BABY           zombie_horse_baby           main                    ".
    05 FILLER PIC X(80) VALUE "ZOMBIE_HORSE_SADDLE         zombie_horse                saddle                  ".
    05 FILLER PIC X(80) VALUE "ZOMBIE_ARMOR                zombie                      #armor-set              ".
    05 FILLER PIC X(80) VALUE "ZOMBIE_VILLAGER             zombie_villager             main                    ".
    05 FILLER PIC X(80) VALUE "ZOMBIE_VILLAGER_NO_HAT      zombie_villager_no_hat      main                    ".
    05 FILLER PIC X(80) VALUE "ZOMBIE_VILLAGER_BABY        zombie_villager_baby        main                    ".
    05 FILLER PIC X(80) VALUE "ZOMBIE_VILLAGER_BABY_NO_HAT zombie_villager_baby_no_hat main                    ".
    05 FILLER PIC X(80) VALUE "ZOMBIE_VILLAGER_BABY_ARMOR  zombie_villager_baby        #armor-set              ".
    05 FILLER PIC X(80) VALUE "ZOMBIE_VILLAGER_ARMOR       zombie_villager             #armor-set              ".
    05 FILLER PIC X(80) VALUE "ZOMBIFIED_PIGLIN            zombified_piglin            main                    ".
    05 FILLER PIC X(80) VALUE "ZOMBIFIED_PIGLIN_BABY       zombified_piglin_baby       main                    ".
    05 FILLER PIC X(80) VALUE "ZOMBIFIED_PIGLIN_BABY_ARMOR zombified_piglin_baby       #armor-set              ".
    05 FILLER PIC X(80) VALUE "ZOMBIFIED_PIGLIN_ARMOR      zombified_piglin            #armor-set              ".
    05 FILLER PIC X(80) VALUE "ZOMBIE_NAUTILUS             zombie_nautilus             main                    ".
 01 WS-TABLE-R REDEFINES WS-TABLE.
    05 WS-ROW OCCURS 292 TIMES.
       10 WS-FIELD         PIC X(28).
       10 WS-MODEL         PIC X(28).
       10 WS-LAYER         PIC X(24).
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-FIELD                PIC X(28).
 01 L-MODEL                PIC X(28).
 01 L-LAYER                PIC X(24).
*> USING field-row index (1..292), the field name, model name and layer string ("#armor-set" = the four armor layers).
 PROCEDURE DIVISION USING L-INDEX L-FIELD L-MODEL L-LAYER.
     MOVE WS-FIELD(L-INDEX) TO L-FIELD
     MOVE WS-MODEL(L-INDEX) TO L-MODEL
     MOVE WS-LAYER(L-INDEX) TO L-LAYER
     GOBACK.
 END PROGRAM EM4-FIELD-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM4-LAYER-COUNTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-F                   PIC X(28).
 01 WS-M                   PIC X(28).
 01 WS-L                   PIC X(24).
 LINKAGE SECTION.
 01 L-FIELDS               BINARY-LONG.
 01 L-SINGLE               BINARY-LONG.
 01 L-SETS                 BINARY-LONG.
 01 L-LAYERS               BINARY-LONG.
 PROCEDURE DIVISION USING L-FIELDS L-SINGLE L-SETS L-LAYERS.
     MOVE 292 TO L-FIELDS
     MOVE 0 TO L-SINGLE L-SETS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 292
         CALL "EM4-FIELD-ROW" USING WS-I WS-F WS-M WS-L
         IF WS-L = "#armor-set"
             ADD 1 TO L-SETS
         ELSE
             ADD 1 TO L-SINGLE
         END-IF
     END-PERFORM
     COMPUTE L-LAYERS = L-SINGLE + L-SETS * 4
     GOBACK.
 END PROGRAM EM4-LAYER-COUNTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM4-LAYER-ID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-F                   PIC X(28).
 01 WS-M                   PIC X(28).
 01 WS-L                   PIC X(24).
 01 WS-SETS.
    05 FILLER PIC X(12) VALUE "helmet".
    05 FILLER PIC X(12) VALUE "chestplate".
    05 FILLER PIC X(12) VALUE "leggings".
    05 FILLER PIC X(12) VALUE "boots".
 01 WS-SETS-R REDEFINES WS-SETS.
    05 WS-SET-LAYER        PIC X(12) OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-ID                   PIC X(60).
 PROCEDURE DIVISION USING L-INDEX L-ID.
     MOVE SPACES TO L-ID
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 292
         CALL "EM4-FIELD-ROW" USING WS-I WS-F WS-M WS-L
         IF WS-L = "#armor-set"
             IF L-INDEX > WS-N AND L-INDEX <= WS-N + 4
                 STRING "minecraft:" FUNCTION TRIM(WS-M) "#" FUNCTION TRIM(WS-SET-LAYER(L-INDEX - WS-N)) DELIMITED BY SIZE
                     INTO L-ID
             END-IF
             ADD 4 TO WS-N
         ELSE
             ADD 1 TO WS-N
             IF L-INDEX = WS-N
                 STRING "minecraft:" FUNCTION TRIM(WS-M) "#" FUNCTION TRIM(WS-L) DELIMITED BY SIZE INTO L-ID
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EM4-LAYER-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM4-LAYER-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-ID                  PIC X(60).
 LINKAGE SECTION.
 01 L-ID                   PIC X(60).
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-INDEX.
     MOVE 0 TO L-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 361
         CALL "EM4-LAYER-ID" USING WS-I WS-ID
         IF WS-ID = L-ID
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EM4-LAYER-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM4-FIELD-LAYERS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-F                   PIC X(28).
 01 WS-M                   PIC X(28).
 01 WS-L                   PIC X(24).
 LINKAGE SECTION.
 01 L-FIELD                PIC X(28).
 01 L-FIRST                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-FIELD L-FIRST L-COUNT.
     MOVE 0 TO L-FIRST L-COUNT WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 292
         CALL "EM4-FIELD-ROW" USING WS-I WS-F WS-M WS-L
         IF WS-F = L-FIELD
             COMPUTE L-FIRST = WS-N + 1
             MOVE 1 TO L-COUNT
             IF WS-L = "#armor-set"
                 MOVE 4 TO L-COUNT
             END-IF
         END-IF
         IF WS-L = "#armor-set"
             ADD 4 TO WS-N
         ELSE
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EM4-FIELD-LAYERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM4-LAYER-DUPLICATES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-A                   PIC X(60).
 01 WS-B                   PIC X(60).
 LINKAGE SECTION.
 01 L-DUPS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DUPS.
     MOVE 0 TO L-DUPS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 360
         CALL "EM4-LAYER-ID" USING WS-I WS-A
         COMPUTE WS-J = WS-I + 1
         PERFORM VARYING WS-J FROM WS-J BY 1 UNTIL WS-J > 361
             CALL "EM4-LAYER-ID" USING WS-J WS-B
             IF WS-A = WS-B
                 ADD 1 TO L-DUPS
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM EM4-LAYER-DUPLICATES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM4-ANIM-ID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CLASSES.
    05 FILLER PIC X(28) VALUE "ArmadilloAnimation".
    05 FILLER PIC X(28) VALUE "BabyArmadilloAnimation".
    05 FILLER PIC X(28) VALUE "BabyAxolotlAnimation".
    05 FILLER PIC X(28) VALUE "BabyRabbitAnimation".
    05 FILLER PIC X(28) VALUE "BatAnimation".
    05 FILLER PIC X(28) VALUE "BreezeAnimation".
    05 FILLER PIC X(28) VALUE "CamelAnimation".
    05 FILLER PIC X(28) VALUE "CamelBabyAnimation".
    05 FILLER PIC X(28) VALUE "CopperGolemAnimation".
    05 FILLER PIC X(28) VALUE "CreakingAnimation".
    05 FILLER PIC X(28) VALUE "FoxBabyAnimation".
    05 FILLER PIC X(28) VALUE "FrogAnimation".
    05 FILLER PIC X(28) VALUE "NautilusAnimation".
    05 FILLER PIC X(28) VALUE "RabbitAnimation".
    05 FILLER PIC X(28) VALUE "SnifferAnimation".
    05 FILLER PIC X(28) VALUE "WardenAnimation".
 01 WS-CLASSES-R REDEFINES WS-CLASSES.
    05 WS-CLASS            PIC X(28) OCCURS 16 TIMES.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CLASS                PIC X(28).
 01 L-FIELD                PIC X(28).
 01 L-ID                   PIC X(60).
 01 L-KNOWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-CLASS L-FIELD L-ID L-KNOWN.
     MOVE 0 TO L-KNOWN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         IF WS-CLASS(WS-I) = L-CLASS
             MOVE 1 TO L-KNOWN
         END-IF
     END-PERFORM
     MOVE SPACES TO L-ID
     STRING FUNCTION TRIM(L-CLASS) "." FUNCTION TRIM(L-FIELD) DELIMITED BY SIZE INTO L-ID
     GOBACK.
 END PROGRAM EM4-ANIM-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EM4-ANIM-CLASS-COUNT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT.
     MOVE 16 TO L-COUNT
     GOBACK.
 END PROGRAM EM4-ANIM-CLASS-COUNT.
