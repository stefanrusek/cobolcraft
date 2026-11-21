*> Acceptance test of docs/protocol/42-particles-6-emitters-blocks.md section 10 (Per-block summary): every row of the table, by each particle name of its
*> first column, returns the document's list of emitting blocks and sources.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-6-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(40).
 01 WS-EXP                 PIC X(256).
 01 WS-TEXT                PIC X(256).
 01 WS-FOUND               BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "smoke" TO WS-NAME
     MOVE "torches, wall torches, furnace, smoker, blast furnace, brewing stand, end portal"
         & ", wither rose, campfire food, candle (30%), trial spawner states, spawner, vault"
         & ", redstone torch burnout, end-portal frame" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "flame" TO WS-NAME
     MOVE "furnace, spawner, trial spawner active (normal)" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "soul_fire_flame" TO WS-NAME
     MOVE "soul torch, ominous trial spawner and vault" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "copper_fire_flame" TO WS-NAME
     MOVE "copper torch" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "small_flame" TO WS-NAME
     MOVE "candle, trial spawner, vault" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "large_smoke" TO WS-NAME
     MOVE "fire, soul fire, lava extinguish" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "lava" TO WS-NAME
     MOVE "lava fluid pop, campfire ember" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "dust" TO WS-NAME
     MOVE "redstone wire, redstone torches, repeater, redstone ore, lever" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "dripping_water" TO WS-NAME
     MOVE "wet sponge, leaves while raining, water drips from fluid cells" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "dripping_lava" TO WS-NAME
     MOVE "lava fluid drips" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "dripping_honey" TO WS-NAME
     MOVE "beehive with `honey_level >= 5`" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "dripping_obsidian_tear" TO WS-NAME
     MOVE "crying obsidian" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "dripping_dripstone_water" TO WS-NAME
     MOVE "pointed dripstone" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "dripping_dripstone_lava" TO WS-NAME
     MOVE "pointed dripstone" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "falling_dust" TO WS-NAME
     MOVE "sand and gravel family, brushable blocks" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "portal" TO WS-NAME
     MOVE "nether portal, end gateway, ender chest" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "reverse_portal" TO WS-NAME
     MOVE "respawn anchor" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "enchant" TO WS-NAME
     MOVE "enchanting table" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "mycelium" TO WS-NAME
     MOVE "mycelium" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "falling_spore_blossom" TO WS-NAME
     MOVE "spore blossom" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "spore_blossom_air" TO WS-NAME
     MOVE "spore blossom" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "firefly" TO WS-NAME
     MOVE "firefly bush" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "end_rod" TO WS-NAME
     MOVE "end rod" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "electric_spark" TO WS-NAME
     MOVE "lightning rod, copper events" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "current_down" TO WS-NAME
     MOVE "bubble column" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "bubble_column_up" TO WS-NAME
     MOVE "bubble column" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "sculk_charge" TO WS-NAME
     MOVE "sculk events" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "sculk_charge_pop" TO WS-NAME
     MOVE "sculk events" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "shriek" TO WS-NAME
     MOVE "sculk events" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "dust_color_transition" TO WS-NAME
     MOVE "sculk sensor (active)" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "white_smoke" TO WS-NAME
     MOVE "dried ghast" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "happy_villager" TO WS-NAME
     MOVE "dried ghast" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "sulfur_bubbles" TO WS-NAME
     MOVE "sulfur, geyser" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "noxious_gas_cloud" TO WS-NAME
     MOVE "sulfur, geyser" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "geyser" TO WS-NAME
     MOVE "sulfur, geyser" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "campfire_cosy_smoke" TO WS-NAME
     MOVE "campfire" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "campfire_signal_smoke" TO WS-NAME
     MOVE "campfire" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "underwater" TO WS-NAME
     MOVE "water" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "composter" TO WS-NAME
     MOVE "block-driven level events (section 6): composter fill (1500 family), event 2009 "
         & "(`cloud`), 3018 (`poof`), egg crack, wax and scrape events" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "cloud" TO WS-NAME
     MOVE "block-driven level events (section 6): composter fill (1500 family), event 2009 "
         & "(`cloud`), 3018 (`poof`), egg crack, wax and scrape events" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "poof" TO WS-NAME
     MOVE "block-driven level events (section 6): composter fill (1500 family), event 2009 "
         & "(`cloud`), 3018 (`poof`), egg crack, wax and scrape events" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "egg_crack" TO WS-NAME
     MOVE "block-driven level events (section 6): composter fill (1500 family), event 2009 "
         & "(`cloud`), 3018 (`poof`), egg crack, wax and scrape events" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "wax_on" TO WS-NAME
     MOVE "block-driven level events (section 6): composter fill (1500 family), event 2009 "
         & "(`cloud`), 3018 (`poof`), egg crack, wax and scrape events" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "wax_off" TO WS-NAME
     MOVE "block-driven level events (section 6): composter fill (1500 family), event 2009 "
         & "(`cloud`), 3018 (`poof`), egg crack, wax and scrape events" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "scrape" TO WS-NAME
     MOVE "block-driven level events (section 6): composter fill (1500 family), event 2009 "
         & "(`cloud`), 3018 (`poof`), egg crack, wax and scrape events" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "trial_omen" TO WS-NAME
     MOVE "trial spawner and vault emitters (4.2, 4.4)" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "trial_spawner_detected_player" TO WS-NAME
     MOVE "trial spawner and vault emitters (4.2, 4.4)" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "trial_spawner_detected_player_ominous" TO WS-NAME
     MOVE "trial spawner and vault emitters (4.2, 4.4)" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "vault_connection" TO WS-NAME
     MOVE "trial spawner and vault emitters (4.2, 4.4)" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "explosion" TO WS-NAME
     MOVE "events 2008 and 3000 (section 6)" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "explosion_emitter" TO WS-NAME
     MOVE "events 2008 and 3000 (section 6)" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "sculk_soul" TO WS-NAME
     MOVE "sculk (4.5, 6), powder snow (8.4), decorated pot (8.5), creaking heart and eyebl"
         & "ossom (9)" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "snowflake" TO WS-NAME
     MOVE "sculk (4.5, 6), powder snow (8.4), decorated pot (8.5), creaking heart and eyebl"
         & "ossom (9)" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "dust_plume" TO WS-NAME
     MOVE "sculk (4.5, 6), powder snow (8.4), decorated pot (8.5), creaking heart and eyebl"
         & "ossom (9)" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "trail" TO WS-NAME
     MOVE "sculk (4.5, 6), powder snow (8.4), decorated pot (8.5), creaking heart and eyebl"
         & "ossom (9)" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "note" TO WS-NAME
     MOVE "note block (3.4)" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "block" TO WS-NAME
     MOVE "sprint, landing, honey; `block_marker`: barrier and light; `dust_pillar`: smash "
         & "(42-7)" TO WS-EXP
     PERFORM CHECK-ROW
     MOVE "no_such_particle" TO WS-NAME
     CALL "P6-EMITTERS-OF" USING WS-NAME WS-TEXT WS-FOUND
     MOVE SPACES TO TL-CASE
     MOVE "acceptance US12 42-6§10 Per-block summary: an unknown particle is not found" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "smoke" TO WS-NAME
     CALL "P6-EMITTERS-OF" USING WS-NAME WS-TEXT WS-FOUND
     MOVE "acceptance US12 42-6§10 Per-block summary: a known particle is found" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CHECK-ROW.
     CALL "P6-EMITTERS-OF" USING WS-NAME WS-TEXT WS-FOUND
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-6§10 Per-block summary: " FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-EXP TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PARTICLES-42-6-10.
