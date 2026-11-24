*> Particles part 6 (docs/protocol/42-particles-6-emitters-blocks.md) section 10: the per-block summary, as a lookup.
*>
*> Entry point for the integrator (inputs):
*>   P6-EMITTERS-OF name(PIC X(40): a particle name of the first column of the table) text(PIC X(256) out: the blocks and sources that emit it, as the
*>     document words them) found(out: 1 when the name is a row of the table, else 0 and spaces). The table is a reading aid (section 3 to 9 are authoritative).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. P6-EMITTERS-OF.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-TEXT                 PIC X(256).
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-TEXT L-FOUND.
     MOVE 1 TO L-FOUND
     MOVE SPACES TO L-TEXT
     EVALUATE L-NAME
         WHEN "smoke"
             MOVE "torches, wall torches, furnace, smoker, blast furnace, brewing stand, "
                 & "end portal, wither rose, campfire food, candle (30%), trial spawner st"
                 & "ates, spawner, vault, redstone torch burnout, end-portal frame" TO L-TEXT
         WHEN "flame"
             MOVE "furnace, spawner, trial spawner active (normal)" TO L-TEXT
         WHEN "soul_fire_flame"
             MOVE "soul torch, ominous trial spawner and vault" TO L-TEXT
         WHEN "copper_fire_flame"
             MOVE "copper torch" TO L-TEXT
         WHEN "small_flame"
             MOVE "candle, trial spawner, vault" TO L-TEXT
         WHEN "large_smoke"
             MOVE "fire, soul fire, lava extinguish" TO L-TEXT
         WHEN "lava"
             MOVE "lava fluid pop, campfire ember" TO L-TEXT
         WHEN "dust"
             MOVE "redstone wire, redstone torches, repeater, redstone ore, lever" TO L-TEXT
         WHEN "dripping_water"
             MOVE "wet sponge, leaves while raining, water drips from fluid cells" TO L-TEXT
         WHEN "dripping_lava"
             MOVE "lava fluid drips" TO L-TEXT
         WHEN "dripping_honey"
             MOVE "beehive with `honey_level >= 5`" TO L-TEXT
         WHEN "dripping_obsidian_tear"
             MOVE "crying obsidian" TO L-TEXT
         WHEN "dripping_dripstone_water"
         WHEN "dripping_dripstone_lava"
             MOVE "pointed dripstone" TO L-TEXT
         WHEN "falling_dust"
             MOVE "sand and gravel family, brushable blocks" TO L-TEXT
         WHEN "portal"
             MOVE "nether portal, end gateway, ender chest" TO L-TEXT
         WHEN "reverse_portal"
             MOVE "respawn anchor" TO L-TEXT
         WHEN "enchant"
             MOVE "enchanting table" TO L-TEXT
         WHEN "mycelium"
             MOVE "mycelium" TO L-TEXT
         WHEN "falling_spore_blossom"
         WHEN "spore_blossom_air"
             MOVE "spore blossom" TO L-TEXT
         WHEN "firefly"
             MOVE "firefly bush" TO L-TEXT
         WHEN "end_rod"
             MOVE "end rod" TO L-TEXT
         WHEN "electric_spark"
             MOVE "lightning rod, copper events" TO L-TEXT
         WHEN "current_down"
         WHEN "bubble_column_up"
             MOVE "bubble column" TO L-TEXT
         WHEN "sculk_charge"
         WHEN "sculk_charge_pop"
         WHEN "shriek"
             MOVE "sculk events" TO L-TEXT
         WHEN "dust_color_transition"
             MOVE "sculk sensor (active)" TO L-TEXT
         WHEN "white_smoke"
         WHEN "happy_villager"
             MOVE "dried ghast" TO L-TEXT
         WHEN "sulfur_bubbles"
         WHEN "noxious_gas_cloud"
         WHEN "geyser"
             MOVE "sulfur, geyser" TO L-TEXT
         WHEN "campfire_cosy_smoke"
         WHEN "campfire_signal_smoke"
             MOVE "campfire" TO L-TEXT
         WHEN "underwater"
             MOVE "water" TO L-TEXT
         WHEN "composter"
         WHEN "cloud"
         WHEN "poof"
         WHEN "egg_crack"
         WHEN "wax_on"
         WHEN "wax_off"
         WHEN "scrape"
             MOVE "block-driven level events (section 6): composter fill (1500 family), e"
                 & "vent 2009 (`cloud`), 3018 (`poof`), egg crack, wax and scrape events" TO L-TEXT
         WHEN "trial_omen"
         WHEN "trial_spawner_detected_player"
         WHEN "trial_spawner_detected_player_ominous"
         WHEN "vault_connection"
             MOVE "trial spawner and vault emitters (4.2, 4.4)" TO L-TEXT
         WHEN "explosion"
         WHEN "explosion_emitter"
             MOVE "events 2008 and 3000 (section 6)" TO L-TEXT
         WHEN "sculk_soul"
         WHEN "snowflake"
         WHEN "dust_plume"
         WHEN "trail"
             MOVE "sculk (4.5, 6), powder snow (8.4), decorated pot (8.5), creaking heart"
                 & " and eyeblossom (9)" TO L-TEXT
         WHEN "note"
             MOVE "note block (3.4)" TO L-TEXT
         WHEN "block"
             MOVE "sprint, landing, honey; `block_marker`: barrier and light; `dust_pilla"
                 & "r`: smash (42-7)" TO L-TEXT
         WHEN OTHER
             MOVE 0 TO L-FOUND
     END-EVALUATE
     GOBACK.
 END PROGRAM P6-EMITTERS-OF.
