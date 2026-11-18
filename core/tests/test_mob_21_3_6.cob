*> Acceptance test (US15, FR-036, SC-008; docs/protocol/21 sections 3.6 and 3.8): the entity type tags and block tags the mobs of this document use. GENERATED from the two doc tables by a script that
*> reads only the markdown (lane 002-lane-p49d): one case per tag compares the members the content set resolves (CONTENT-TAG-HAS over every entity type or block the doc names) with the
*> doc's literal list, nested #tags expanded. A tag the doc lists a nested tag of (dragon_transparent, bats_spawnable_on) is checked for its literal members only. Needs CC_GENERATED_DIR.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-3-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 78 CASES VALUE 49.
 01 WS-CASE-DATA.
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "accepts_iron_golem_gift".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "copper_golem ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "aquatic".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "turtle axolotl guardian elder_guardian cod pufferfish salmon" &
          " tropical_fish dolphin squid glow_squid tadpole nautilus zom" &
          "bie_nautilus ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "arrows".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "arrow spectral_arrow ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "arthropod".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "bee endermite silverfish spider cave_spider ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "axolotl_always_hostiles".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "guardian elder_guardian drowned ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "axolotl_hunt_targets".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "cod pufferfish salmon tropical_fish squid glow_squid tadpole" &
          " ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "beehive_inhabitors".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "bee ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "boat".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "oak_boat spruce_boat birch_boat jungle_boat acacia_boat cher" &
          "ry_boat dark_oak_boat pale_oak_boat mangrove_boat bamboo_raf" &
          "t poplar_boat ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "burn_in_daylight".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "zombie_nautilus drowned skeleton stray wither_skeleton bogge" &
          "d zombie zombie_horse zombie_villager phantom ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "can_breathe_under_water".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish squid glow_squid tadpole nautilu" &
          "s zombie_nautilus drowned skeleton stray wither_skeleton bog" &
          "ged zombie zombie_horse zombie_villager phantom skeleton_hor" &
          "se parched camel_husk zombified_piglin zoglin husk wither fr" &
          "og armor_stand ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "can_equip_harness".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "happy_ghast ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "can_equip_saddle".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "nautilus zombie_nautilus zombie_horse skeleton_horse camel_h" &
          "usk horse donkey mule pig strider camel ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "can_float_while_ridden".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "zombie_horse camel_husk horse donkey mule camel ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "can_turn_in_boats".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "breeze ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "can_wear_horse_armor".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "zombie_horse horse ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "can_wear_nautilus_armor".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "nautilus zombie_nautilus ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "candidate_for_iron_golem_gift".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "copper_golem villager ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "cannot_be_age_locked".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "zombie_horse skeleton_horse villager ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "cannot_be_dismounted_by_item_usage".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "interaction ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "cannot_be_pushed_onto_boats".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "elder_guardian cod pufferfish salmon tropical_fish dolphin s" &
          "quid glow_squid tadpole nautilus zombie_nautilus player crea" &
          "king sulfur_cube ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "deflects_projectiles".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "breeze ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "dismounts_underwater".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "spider zombie_horse happy_ghast horse donkey mule pig stride" &
          "r camel chicken llama ravager trader_llama ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "fall_damage_immune".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "copper_golem bee phantom wither happy_ghast breeze chicken i" &
          "ron_golem snow_golem shulker allay bat blaze cat ghast magma" &
          "_cube ocelot parrot ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "followable_friendly_mobs".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "bee skeleton_horse happy_ghast horse donkey mule pig strider" &
          " camel villager chicken llama cat ocelot parrot armadillo co" &
          "w fox goat panda polar_bear rabbit sheep sniffer wolf ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "freeze_hurts_extra_types".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "strider blaze magma_cube ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "freeze_immune_entity_types".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "stray wither snow_golem polar_bear ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "frog_food".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "magma_cube slime ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "ignores_poison_and_regen".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "zombie_nautilus drowned skeleton stray wither_skeleton bogge" &
          "d zombie zombie_horse zombie_villager phantom skeleton_horse" &
          " parched camel_husk zombified_piglin zoglin husk wither ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "illager".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "evoker illusioner pillager vindicator ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "illager_friends".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "evoker illusioner pillager vindicator ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "immune_to_infested".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "silverfish ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "immune_to_oozing".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "slime ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "impact_projectiles".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "arrow spectral_arrow firework_rocket snowball fireball small" &
          "_fireball egg trident dragon_fireball wither_skull wind_char" &
          "ge breeze_wind_charge ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "inverted_healing_and_harm".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "zombie_nautilus drowned skeleton stray wither_skeleton bogge" &
          "d zombie zombie_horse zombie_villager phantom skeleton_horse" &
          " parched camel_husk zombified_piglin zoglin husk wither ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "nautilus_hostiles".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "pufferfish ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "no_anger_from_wind_charge".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "spider cave_spider skeleton stray bogged zombie husk breeze " &
          "slime ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "non_controlling_rider".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "sulfur_cube magma_cube slime ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "not_affected_by_geysers".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "ender_dragon ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "not_scary_for_pufferfish".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "turtle guardian elder_guardian cod pufferfish salmon tropica" &
          "l_fish dolphin squid glow_squid tadpole nautilus zombie_naut" &
          "ilus sulfur_cube ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "powder_snow_walkable_mobs".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "endermite silverfish fox rabbit ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "raiders".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "ravager evoker illusioner pillager vindicator witch ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "redirectable_projectile".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "fireball wind_charge breeze_wind_charge ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "sensitive_to_bane_of_arthropods".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "bee endermite silverfish spider cave_spider ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "sensitive_to_impaling".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "turtle axolotl guardian elder_guardian cod pufferfish salmon" &
          " tropical_fish dolphin squid glow_squid tadpole nautilus zom" &
          "bie_nautilus ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "sensitive_to_smite".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "zombie_nautilus drowned skeleton stray wither_skeleton bogge" &
          "d zombie zombie_horse zombie_villager phantom skeleton_horse" &
          " parched camel_husk zombified_piglin zoglin husk wither ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "skeletons".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "skeleton stray wither_skeleton bogged skeleton_horse parched" &
          " ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "undead".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "zombie_nautilus drowned skeleton stray wither_skeleton bogge" &
          "d zombie zombie_horse zombie_villager phantom skeleton_horse" &
          " parched camel_husk zombified_piglin zoglin husk wither ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "wither_friends".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "zombie_nautilus drowned skeleton stray wither_skeleton bogge" &
          "d zombie zombie_horse zombie_villager phantom skeleton_horse" &
          " parched camel_husk zombified_piglin zoglin husk wither ".
    05 FILLER.
       10 FILLER PIC X(12) VALUE "entity_type".
       10 FILLER PIC X(48) VALUE "zombies".
       10 FILLER PIC X(2000) VALUE "copper_golem turtle axolotl guardian elder_guardian cod puff" &
          "erfish salmon tropical_fish dolphin squid glow_squid tadpole" &
          " nautilus zombie_nautilus arrow spectral_arrow bee endermite" &
          " silverfish spider cave_spider drowned oak_boat spruce_boat " &
          "birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat" &
          " pale_oak_boat mangrove_boat bamboo_raft poplar_boat skeleto" &
          "n stray wither_skeleton bogged zombie zombie_horse zombie_vi" &
          "llager phantom skeleton_horse parched camel_husk zombified_p" &
          "iglin zoglin husk wither frog armor_stand happy_ghast horse " &
          "donkey mule pig strider camel breeze villager interaction pl" &
          "ayer creaking sulfur_cube chicken llama ravager trader_llama" &
          " iron_golem snow_golem shulker allay bat blaze cat ghast mag" &
          "ma_cube ocelot parrot armadillo cow fox goat panda polar_bea" &
          "r rabbit sheep sniffer wolf slime evoker illusioner pillager" &
          " vindicator firework_rocket snowball fireball small_fireball" &
          " egg trident dragon_fireball wither_skull wind_charge breeze" &
          "_wind_charge ender_dragon witch ".
       10 FILLER PIC X(1000) VALUE "zombie_nautilus drowned zombie zombie_horse zombie_villager " &
          "camel_husk zombified_piglin zoglin husk ".
 01 WS-CASE-TABLE REDEFINES WS-CASE-DATA.
    05 WS-C OCCURS CASES TIMES.
       10 WS-C-REGISTRY      PIC X(12).
       10 WS-C-TAG           PIC X(48).
       10 WS-C-SCOPE         PIC X(2000).
       10 WS-C-EXPECTED      PIC X(1000).
 01 WS-I                   BINARY-LONG.
 01 WS-DIR                 PIC X(1100).
 01 WS-ENV                 PIC X(1100).
 01 WS-FILE                PIC X(1200).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-TYPE                BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-WORD                PIC X(48).
 01 WS-KEY                 PIC X(112).
 01 WS-TAGKEY              PIC X(112).
 01 WS-REGISTRY            PIC X(48).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-LIST                PIC X(1024).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "tags 21 3.6 no generated packs here, skipped" TO TL-CASE
         MOVE "ok" TO TL-EXPECTED
         MOVE "ok" TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CASES
         MOVE SPACES TO WS-LIST
         MOVE 1 TO WS-OUT
         MOVE 1 TO WS-PTR
         MOVE SPACES TO WS-REGISTRY WS-TAGKEY
         MOVE WS-C-REGISTRY(WS-I) TO WS-REGISTRY
         STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-C-TAG(WS-I)) DELIMITED BY SIZE INTO WS-TAGKEY
         PERFORM UNTIL WS-PTR > 2000 OR WS-C-SCOPE(WS-I)(WS-PTR:1) = SPACE
             MOVE SPACES TO WS-WORD
             UNSTRING WS-C-SCOPE(WS-I) DELIMITED BY SPACE INTO WS-WORD WITH POINTER WS-PTR
             MOVE SPACES TO WS-KEY
             STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-WORD) DELIMITED BY SIZE INTO WS-KEY
             MOVE 0 TO WS-ID
             IF WS-C-REGISTRY(WS-I) = "entity_type"
                 CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
             ELSE
                 CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
             END-IF
             MOVE 0 TO WS-HAS
             IF WS-STATUS = CT-OK
                 CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAGKEY WS-ID WS-HAS
             END-IF
             IF WS-HAS = 1
                 STRING FUNCTION TRIM(WS-WORD) DELIMITED BY SIZE " " DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-OUT
             END-IF
         END-PERFORM
         MOVE SPACES TO TL-CASE
         IF WS-C-REGISTRY(WS-I) = "entity_type"
             STRING "acceptance US15 21§3.6 entity tag " DELIMITED BY SIZE FUNCTION TRIM(WS-C-TAG(WS-I)) DELIMITED BY SIZE INTO TL-CASE
         ELSE
             STRING "acceptance US15 21§3.8 block tag " DELIMITED BY SIZE FUNCTION TRIM(WS-C-TAG(WS-I)) DELIMITED BY SIZE INTO TL-CASE
         END-IF
         MOVE WS-C-EXPECTED(WS-I) TO TL-EXPECTED
         MOVE WS-LIST TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-MOB-21-3-6.
