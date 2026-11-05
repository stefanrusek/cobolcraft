*> Implementation test of the US2 content copybooks (core/copy/BLOCKS.cpy, ITEMS.cpy, ENTITYTYPES.cpy,
*> RULES.cpy, DIMENSIONS.cpy, REGISTRY.cpy) against docs/design/standin-content.md: blocks §1.1, block
*> states §1.2, items §2 with food values §11.5 and attack damage §10.4, entity types §3 and §12.1, the
*> dimensions and spawn point §5.1, §5.2, §15, maximum health §10.1 and maximum food §11.1,
*> the health and death rules of §10.2 to §10.6 and the hunger rules of §11.2, §11.3 and §11.6
*> (RULES.cpy), the death messages of §10.7 (MESSAGES.cpy), the mob rules of §12 (MOBS.cpy), the
*> recipes of §13 (RECIPES.cpy), the weather of §14 (WEATHER.cpy), the console's en_us texts of
*> docs/protocol/08-resource-packs.md §10.8.2 to §10.8.4 (CONSOLELANG.cpy),
*> every synchronized registry entry of §4 (§4.2 to §4.8) and the starting inventory of §2 (US4-8).
*> Each table row is rendered as one line of text, fields separated by single spaces, and compared
*> with the row transcribed from the document.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CONTENT-TABLES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY BLOCKS.
 COPY ITEMS.
 COPY ENTITYTYPES.
 COPY RULES.
 COPY MESSAGES.
 COPY DIMENSIONS.
 COPY REGISTRY.
 COPY MOBS.
 COPY RECIPES.
 COPY WEATHER.
 COPY CONSOLELANG.
 01 WS-CONSOLE-ROWS.
    05 FILLER PIC X(128) VALUE
        "cobolcraft.death.fall => %s misjudged the drop".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.death.mob.abend => %s was halted by an Abend".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.death.player => %s lost a duel with %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.death.starvation => %s ran out of rations".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.death.hail => %s was battered by hail".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.death.command => %s had their vitality set to zero".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.unknown => Unknown command %s (howto lists the commands)".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.not_permitted => You may not use %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.missing_argument => Missing argument. Usage: %s (see howto)".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.invalid_argument => Invalid argument %s. Usage: %s (see howto)".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.invalid_name => %s is not a valid player name".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.player_not_found => No player named %s is online".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.dimension_not_found => No dimension is named %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.item_not_found => No item is named %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.mob_not_found => No mob is named %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.not_survival => %s is not in survival mode".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.not_alive => %s is dead and has not respawned yet".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.is_host => %s is the host of this world".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.promote.notice => You now hold operator status".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.demote.notice => You no longer hold operator status".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.howto.header => Commands you may use (%s):".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.howto.entry => - %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.roster => Online (%s): %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.murmur.incoming => %s murmurs to you: %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.murmur.incoming_console => The server murmurs to you: %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.murmur.sent => You murmur to %s: %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.promote.done => %s now holds operator status".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.promote.already => %s already holds operator status".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.demote.done => %s no longer holds operator status".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.demote.not_operator => %s does not hold operator status".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.eject.done => Ejected %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.bar.done => Barred %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.bar.already => %s is already barred".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.unbar.done => Lifted the bar on %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.unbar.not_barred => %s is not barred".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.barlist => Barred (%s): %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.guestlist.on => The guest list is now enforced".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.guestlist.off => The guest list is no longer enforced".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.guestlist.added => Added %s to the guest list".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.guestlist.already => %s is already on the guest list".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.guestlist.removed => Removed %s from the guest list".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.guestlist.not_listed => %s is not on the guest list".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.guestlist.show => Guest list enforcement %s; guests (%s): %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.mode.done => %s now plays in %s mode".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.relocate.position => Relocated %s to %s, %s, %s in %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.relocate.player => Relocated %s to %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.supply.done => Supplied %s %s to %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.supply.no_room => %s has no room for that".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.empty.done => Emptied the inventory of %s (%s items removed)".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.vitality.done => Set the health of %s to %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.ration.done => Set the food level of %s to %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.conjure.done => Conjured a %s at %s, %s, %s in %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.conjure.hostile_disabled => Hostile mobs are switched off, so no %s can be conjured".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.sweep.done => Swept away %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.sweep.unknown_target => Nothing to sweep is named %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.clock.done => The clock now reads %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.skies.timed => The skies over %s turn to %s for %s seconds".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.skies.held => The skies over %s turn to %s until changed".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.skies.no_weather => %s has no skies to change".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.homestead.done => The world spawn point is now %s, %s, %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.announce.message => [Server] %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.announce.done => Announcement sent".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.persist.done => The world has been saved".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.command.shutdown.done => Shutting down".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.disconnect.barred => You are barred from this world".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.disconnect.not_on_guestlist => You are not on this world's guest list".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.disconnect.name_is_host => The name %s belongs to the host of this world".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.disconnect.replaced => Someone joined elsewhere under your name".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.disconnect.shutdown => The server is shutting down".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.disconnect.host_closed => The host closed the world".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.disconnect.pack_required => This server requires its resource pack".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.disconnect.ejected => You were ejected: %s".
    05 FILLER PIC X(128) VALUE
        "cobolcraft.disconnect.ejected_plain => You were ejected by an operator".
    05 FILLER PIC X(128) VALUE
        "multiplayer.disconnect.incompatible => This server runs %s and cannot talk to your game version".
    05 FILLER PIC X(128) VALUE
        "multiplayer.disconnect.outdated_client => Your game version is too old for this server (%s)".
    05 FILLER PIC X(128) VALUE
        "multiplayer.disconnect.transfers_disabled => This server does not take transferred players".
    05 FILLER PIC X(128) VALUE
        "multiplayer.disconnect.slow_login => Logging in took too long".
    05 FILLER PIC X(128) VALUE
        "multiplayer.disconnect.unexpected_query_response => The server got a reply it never asked for".
    05 FILLER PIC X(128) VALUE
        "multiplayer.disconnect.invalid_player_movement => The server refused an impossible position".
    05 FILLER PIC X(128) VALUE
        "disconnect.timeout => No reply arrived in time".
 01 WS-CONSOLE-TABLE REDEFINES WS-CONSOLE-ROWS.
    05 WS-CONSOLE-ROW      PIC X(128) OCCURS 80 TIMES.
 01 WS-ROW                 PIC X(400).
 01 WS-J                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-NUM                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
*> Expected rows, transcribed from standin-content. Block row: id key solid opaque light
*> hand-break-ms class(0 none, 1 hard, 2 soft) first-state state-count default-state.
 01 WS-BLOCK-ROWS.
    05 FILLER PIC X(60) VALUE "0 cobolcraft:void 0 0 0 0 0 0 1 0".
    05 FILLER PIC X(60) VALUE "1 cobolcraft:baseplate 1 1 0 -1 0 1 1 1".
    05 FILLER PIC X(60) VALUE "2 cobolcraft:greystone 1 1 0 1500 1 2 1 2".
    05 FILLER PIC X(60) VALUE "3 cobolcraft:loam 1 1 0 600 2 3 1 3".
    05 FILLER PIC X(60) VALUE "4 cobolcraft:turf 1 1 0 700 2 4 1 4".
    05 FILLER PIC X(60) VALUE "5 cobolcraft:grit 1 1 0 500 2 5 1 5".
    05 FILLER PIC X(60) VALUE "6 cobolcraft:cardstack 1 1 0 1000 1 6 6 9".
    05 FILLER PIC X(60) VALUE "7 cobolcraft:lucite 1 0 0 400 0 12 1 12".
    05 FILLER PIC X(60) VALUE "8 cobolcraft:glowtube 1 1 15 300 0 13 2 13".
    05 FILLER PIC X(60) VALUE "9 cobolcraft:ledger_tile 1 1 0 1200 1 15 1 15".
    05 FILLER PIC X(60) VALUE "10 cobolcraft:goto_pad 1 1 6 2000 0 16 1 16".
    05 FILLER PIC X(60) VALUE "11 cobolcraft:slag 1 1 0 1200 1 17 1 17".
 01 WS-BLOCK-EXPECT REDEFINES WS-BLOCK-ROWS.
    05 WS-BLOCK-ROW        PIC X(60) OCCURS 12 TIMES.
*> State row: id block solid opaque light axis punched lit [properties].
 01 WS-STATE-ROWS.
    05 FILLER PIC X(60) VALUE "0 0 0 0 0 -1 -1 -1".
    05 FILLER PIC X(60) VALUE "1 1 1 1 0 -1 -1 -1".
    05 FILLER PIC X(60) VALUE "2 2 1 1 0 -1 -1 -1".
    05 FILLER PIC X(60) VALUE "3 3 1 1 0 -1 -1 -1".
    05 FILLER PIC X(60) VALUE "4 4 1 1 0 -1 -1 -1".
    05 FILLER PIC X(60) VALUE "5 5 1 1 0 -1 -1 -1".
    05 FILLER PIC X(60) VALUE "6 6 1 1 0 0 1 -1 axis=x,punched=true".
    05 FILLER PIC X(60) VALUE "7 6 1 1 0 0 0 -1 axis=x,punched=false".
    05 FILLER PIC X(60) VALUE "8 6 1 1 0 1 1 -1 axis=y,punched=true".
    05 FILLER PIC X(60) VALUE "9 6 1 1 0 1 0 -1 axis=y,punched=false".
    05 FILLER PIC X(60) VALUE "10 6 1 1 0 2 1 -1 axis=z,punched=true".
    05 FILLER PIC X(60) VALUE "11 6 1 1 0 2 0 -1 axis=z,punched=false".
    05 FILLER PIC X(60) VALUE "12 7 1 0 0 -1 -1 -1".
    05 FILLER PIC X(60) VALUE "13 8 1 1 15 -1 -1 1 lit=true".
    05 FILLER PIC X(60) VALUE "14 8 1 1 0 -1 -1 0 lit=false".
    05 FILLER PIC X(60) VALUE "15 9 1 1 0 -1 -1 -1".
    05 FILLER PIC X(60) VALUE "16 10 1 1 6 -1 -1 -1".
    05 FILLER PIC X(60) VALUE "17 11 1 1 0 -1 -1 -1".
 01 WS-STATE-EXPECT REDEFINES WS-STATE-ROWS.
    05 WS-STATE-ROW        PIC X(60) OCCURS 18 TIMES.
*> Item row: id key placed-state max-stack tool-class food-value attack-damage.
 01 WS-ITEM-ROWS.
    05 FILLER PIC X(60) VALUE "0 cobolcraft:nothing -1 0 0 0 1".
    05 FILLER PIC X(60) VALUE "1 cobolcraft:baseplate 1 64 0 0 1".
    05 FILLER PIC X(60) VALUE "2 cobolcraft:greystone 2 64 0 0 1".
    05 FILLER PIC X(60) VALUE "3 cobolcraft:loam 3 64 0 0 1".
    05 FILLER PIC X(60) VALUE "4 cobolcraft:turf 4 64 0 0 1".
    05 FILLER PIC X(60) VALUE "5 cobolcraft:grit 5 64 0 0 1".
    05 FILLER PIC X(60) VALUE "6 cobolcraft:cardstack 9 64 0 0 1".
    05 FILLER PIC X(60) VALUE "7 cobolcraft:lucite 12 64 0 0 1".
    05 FILLER PIC X(60) VALUE "8 cobolcraft:glowtube 13 64 0 0 1".
    05 FILLER PIC X(60) VALUE "9 cobolcraft:ledger_tile 15 64 0 0 1".
    05 FILLER PIC X(60) VALUE "10 cobolcraft:pry_bar -1 1 1 0 4".
    05 FILLER PIC X(60) VALUE "11 cobolcraft:trowel -1 1 2 0 2".
    05 FILLER PIC X(60) VALUE "12 cobolcraft:grazer_flank -1 32 0 3 1".
    05 FILLER PIC X(60) VALUE "13 cobolcraft:seared_flank -1 32 0 8 1".
    05 FILLER PIC X(60) VALUE "14 cobolcraft:sod_cake -1 16 0 2 1".
    05 FILLER PIC X(60) VALUE "15 cobolcraft:dump_shard -1 64 0 0 1".
    05 FILLER PIC X(60) VALUE "16 cobolcraft:goto_pad 16 16 0 0 1".
    05 FILLER PIC X(60) VALUE "17 cobolcraft:slag 17 64 0 0 1".
 01 WS-ITEM-EXPECT REDEFINES WS-ITEM-ROWS.
    05 WS-ITEM-ROW         PIC X(60) OCCURS 18 TIMES.
*> Entity type row: id key width height eye-height, in thousandths of a block.
 01 WS-ENTITY-ROWS.
    05 FILLER PIC X(60) VALUE "0 cobolcraft:operator 700 1750 1600".
    05 FILLER PIC X(60) VALUE "1 cobolcraft:loose_item 300 300 150".
    05 FILLER PIC X(60) VALUE "2 cobolcraft:sodgrazer 900 900 700".
    05 FILLER PIC X(60) VALUE "3 cobolcraft:abend 750 750 500".
 01 WS-ENTITY-EXPECT REDEFINES WS-ENTITY-ROWS.
    05 WS-ENTITY-ROW       PIC X(60) OCCURS 4 TIMES.
*> Mob type rows (§12.1; see the mob cases).
 01 WS-MOB-ROWS.
    05 FILLER PIC X(80) VALUE "2 cobolcraft:sodgrazer 0 8 50 100 0 0 0 0 0 0 12 2 12".
    05 FILLER PIC X(80) VALUE "3 cobolcraft:abend 1 12 40 0 120 12000 20000 1750 2 30 15 1 8".
 01 WS-MOB-EXPECT REDEFINES WS-MOB-ROWS.
    05 WS-MOB-ROW          PIC X(80) OCCURS 2 TIMES.
*> Recipe rows (§13, display-id order): display id, then each ingredient line as count x item key,
*> "->", the result count x item key.
 01 WS-RECIPE-ROWS.
    05 FILLER PIC X(120) VALUE "0 4xcobolcraft:greystone -> 2xcobolcraft:ledger_tile".
    05 FILLER PIC X(120) VALUE "1 4xcobolcraft:grit -> 2xcobolcraft:lucite".
    05 FILLER PIC X(120) VALUE
        "2 3xcobolcraft:greystone 1xcobolcraft:cardstack -> 1xcobolcraft:pry_bar".
    05 FILLER PIC X(120) VALUE
        "3 2xcobolcraft:greystone 1xcobolcraft:cardstack -> 1xcobolcraft:trowel".
    05 FILLER PIC X(120) VALUE
        "4 1xcobolcraft:lucite 1xcobolcraft:dump_shard -> 2xcobolcraft:glowtube".
    05 FILLER PIC X(120) VALUE "5 4xcobolcraft:turf 1xcobolcraft:loam -> 1xcobolcraft:sod_cake".
    05 FILLER PIC X(120) VALUE
        "6 2xcobolcraft:grazer_flank 1xcobolcraft:glowtube -> 2xcobolcraft:seared_flank".
    05 FILLER PIC X(120) VALUE "7 4xcobolcraft:ledger_tile 2xcobolcraft:dump_shard "
        & "1xcobolcraft:glowtube -> 1xcobolcraft:goto_pad".
    05 FILLER PIC X(120) VALUE
        "8 2xcobolcraft:cardstack 2xcobolcraft:lucite -> 1xcobolcraft:dump_shard".
 01 WS-RECIPE-EXPECT REDEFINES WS-RECIPE-ROWS.
    05 WS-RECIPE-ROW       PIC X(120) OCCURS 9 TIMES.
*> Weather kind rows (§14.1, §14.3, §14.6): kind number, key, English name, rain level and thunder
*> level in thousandths, gameplay effect (0 none, 1 hail), duration base and span in ticks (the
*> remaining time after a change is base + ((r div 100) mod span)).
 01 WS-WEATHER-ROWS.
    05 FILLER PIC X(80) VALUE "1 cobolcraft:clear Clear 0 0 0 6000 6001".
    05 FILLER PIC X(80) VALUE "2 cobolcraft:drizzle Drizzle 1000 0 0 2400 2401".
    05 FILLER PIC X(80) VALUE "3 cobolcraft:hailstorm Hailstorm 1000 1000 1 1200 1201".
 01 WS-WEATHER-EXPECT REDEFINES WS-WEATHER-ROWS.
    05 WS-WEATHER-ROW      PIC X(80) OCCURS 3 TIMES.
*> Registry rows (§4.2 summary): registry number, key, entries sent.
 01 WS-REG-ROWS.
    05 FILLER PIC X(60) VALUE "0 minecraft:worldgen/biome 3".
    05 FILLER PIC X(60) VALUE "1 minecraft:chat_type 1".
    05 FILLER PIC X(60) VALUE "2 minecraft:trim_pattern 0".
    05 FILLER PIC X(60) VALUE "3 minecraft:trim_material 0".
    05 FILLER PIC X(60) VALUE "4 minecraft:wolf_variant 1".
    05 FILLER PIC X(60) VALUE "5 minecraft:wolf_sound_variant 1".
    05 FILLER PIC X(60) VALUE "6 minecraft:pig_variant 1".
    05 FILLER PIC X(60) VALUE "7 minecraft:pig_sound_variant 1".
    05 FILLER PIC X(60) VALUE "8 minecraft:frog_variant 1".
    05 FILLER PIC X(60) VALUE "9 minecraft:cat_variant 1".
    05 FILLER PIC X(60) VALUE "10 minecraft:cat_sound_variant 1".
    05 FILLER PIC X(60) VALUE "11 minecraft:cow_sound_variant 1".
    05 FILLER PIC X(60) VALUE "12 minecraft:cow_variant 1".
    05 FILLER PIC X(60) VALUE "13 minecraft:chicken_sound_variant 1".
    05 FILLER PIC X(60) VALUE "14 minecraft:chicken_variant 1".
    05 FILLER PIC X(60) VALUE "15 minecraft:zombie_nautilus_variant 1".
    05 FILLER PIC X(60) VALUE "16 minecraft:painting_variant 1".
    05 FILLER PIC X(60) VALUE "17 minecraft:sulfur_cube_archetype 0".
    05 FILLER PIC X(60) VALUE "18 minecraft:dimension_type 2".
    05 FILLER PIC X(60) VALUE "19 minecraft:damage_type 32".
    05 FILLER PIC X(60) VALUE "20 minecraft:banner_pattern 0".
    05 FILLER PIC X(60) VALUE "21 minecraft:enchantment 0".
    05 FILLER PIC X(60) VALUE "22 minecraft:jukebox_song 0".
    05 FILLER PIC X(60) VALUE "23 minecraft:instrument 0".
    05 FILLER PIC X(60) VALUE "24 minecraft:test_environment 0".
    05 FILLER PIC X(60) VALUE "25 minecraft:test_instance 0".
    05 FILLER PIC X(60) VALUE "26 minecraft:dialog 0".
    05 FILLER PIC X(60) VALUE "27 minecraft:world_clock 1".
    05 FILLER PIC X(60) VALUE "28 minecraft:timeline 0".
    05 FILLER PIC X(60) VALUE "29 minecraft:decorated_pot_pattern 0".
    05 FILLER PIC X(60) VALUE "30 minecraft:block_transformer 0".
    05 FILLER PIC X(60) VALUE "31 minecraft:worldgen/block_state_provider 0".
 01 WS-REG-EXPECT REDEFINES WS-REG-ROWS.
    05 WS-REG-ROW PIC X(60) OCCURS 32 TIMES.
*> MV rows (§4.5): registry key, group compounds, then name=value per field; T = the placeholder
*> texture, S = the inline placeholder sound {sound_id}, other values literal (Int or String).
 01 WS-MV-ROWS.
    05 FILLER PIC X(240) VALUE "minecraft:wolf_variant assets baby_assets wild=T tame=T angry=T".
    05 FILLER PIC X(240) VALUE
        "minecraft:wolf_sound_variant adult_sounds baby_sounds ambient_sound=S " &
        "death_sound=S growl_sound=S hurt_sound=S pant_sound=S whine_sound=S st" &
        "ep_sound=S".
    05 FILLER PIC X(240) VALUE "minecraft:pig_variant model=normal asset_id=T baby_asset_id=T".
    05 FILLER PIC X(240) VALUE
        "minecraft:pig_sound_variant adult_sounds baby_sounds ambient_sound=S h" &
        "urt_sound=S death_sound=S step_sound=S eat_sound=S".
    05 FILLER PIC X(240) VALUE "minecraft:frog_variant asset_id=T".
    05 FILLER PIC X(240) VALUE "minecraft:cat_variant asset_id=T baby_asset_id=T".
    05 FILLER PIC X(240) VALUE
        "minecraft:cat_sound_variant adult_sounds baby_sounds ambient_sound=S s" &
        "tray_ambient_sound=S hiss_sound=S hurt_sound=S death_sound=S eat_sound" &
        "=S beg_for_food_sound=S purr_sound=S purreow_sound=S".
    05 FILLER PIC X(240) VALUE "minecraft:cow_sound_variant ambient_sound=S hurt_sound=S death_sound=S step_sound=S".
    05 FILLER PIC X(240) VALUE "minecraft:cow_variant model=normal asset_id=T baby_asset_id=T".
    05 FILLER PIC X(240) VALUE
        "minecraft:chicken_sound_variant adult_sounds baby_sounds ambient_sound" &
        "=S hurt_sound=S death_sound=S step_sound=S".
    05 FILLER PIC X(240) VALUE "minecraft:chicken_variant model=normal asset_id=T baby_asset_id=T".
    05 FILLER PIC X(240) VALUE "minecraft:zombie_nautilus_variant model=normal asset_id=T".
    05 FILLER PIC X(240) VALUE
        "minecraft:painting_variant width=1 height=1 asset_id=cobolcraft:placeh" &
        "older title=Placeholder".
 01 WS-MV-EXPECT REDEFINES WS-MV-ROWS.
    05 WS-MV-ROW PIC X(240) OCCURS 13 TIMES.
*> damage_type rows (§4.7): id key message_id scaling exhaustion-in-thousandths.
 01 WS-DAMAGE-ROWS.
    05 FILLER PIC X(80) VALUE "0 cobolcraft:generic cobolcraft.generic never 0".
    05 FILLER PIC X(80) VALUE "1 cobolcraft:impact cobolcraft.impact never 0".
    05 FILLER PIC X(80) VALUE "2 cobolcraft:below_world cobolcraft.below_world never 0".
    05 FILLER PIC X(80) VALUE "3 minecraft:in_fire cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "4 minecraft:campfire cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "5 minecraft:lightning_bolt cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "6 minecraft:on_fire cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "7 minecraft:lava cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "8 minecraft:hot_floor cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "9 minecraft:in_wall cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "10 minecraft:cramming cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "11 minecraft:drown cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "12 minecraft:starve cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "13 minecraft:cactus cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "14 minecraft:fall cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "15 minecraft:ender_pearl cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "16 minecraft:fly_into_wall cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "17 minecraft:fell_out_of_world cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "18 minecraft:generic cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "19 minecraft:magic cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "20 minecraft:wither cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "21 minecraft:dragon_breath cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "22 minecraft:dry_out cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "23 minecraft:sweet_berry_bush cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "24 minecraft:freeze cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "25 minecraft:stalagmite cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "26 minecraft:outside_border cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "27 minecraft:generic_kill cobolcraft.compat never 0".
    05 FILLER PIC X(80) VALUE "28 cobolcraft:mob_attack cobolcraft.mob_attack never 0".
    05 FILLER PIC X(80) VALUE "29 cobolcraft:player_attack cobolcraft.player_attack never 0".
    05 FILLER PIC X(80) VALUE "30 cobolcraft:starvation cobolcraft.starvation never 0".
    05 FILLER PIC X(80) VALUE "31 cobolcraft:hail cobolcraft.hail never 0".
 01 WS-DAMAGE-EXPECT REDEFINES WS-DAMAGE-ROWS.
    05 WS-DAMAGE-ROW PIC X(80) OCCURS 32 TIMES.
*> Dimension rows (§5.1, §15.1, §15.5; see the dimension cases).
 01 WS-DIMENSION-ROWS.
    05 FILLER PIC X(100) VALUE
       "cobolcraft:main 0 cobolcraft:surface 0 256 48 1 1 1 1 -1 0 2".
    05 FILLER PIC X(100) VALUE
       "cobolcraft:subroutine 1 cobolcraft:sunless 0 128 32 2 2 0 0 2 1 1".
 01 WS-DIMENSION-TABLE REDEFINES WS-DIMENSION-ROWS.
    05 WS-DIMENSION-ROW    PIC X(100) OCCURS 2 TIMES.
 PROCEDURE DIVISION.
*>   Block ids, block-state ids and palette widths (§1.1, §1.2, §4.3).
     MOVE "test content tables block id constants" TO TL-CASE
     PERFORM START-ROW
     MOVE BLK-VOID TO WS-NUM PERFORM ADD-NUM
     MOVE BLK-BASEPLATE TO WS-NUM PERFORM ADD-NUM
     MOVE BLK-GREYSTONE TO WS-NUM PERFORM ADD-NUM
     MOVE BLK-LOAM TO WS-NUM PERFORM ADD-NUM
     MOVE BLK-TURF TO WS-NUM PERFORM ADD-NUM
     MOVE BLK-GRIT TO WS-NUM PERFORM ADD-NUM
     MOVE BLK-CARDSTACK TO WS-NUM PERFORM ADD-NUM
     MOVE BLK-LUCITE TO WS-NUM PERFORM ADD-NUM
     MOVE BLK-GLOWTUBE TO WS-NUM PERFORM ADD-NUM
     MOVE BLK-LEDGER-TILE TO WS-NUM PERFORM ADD-NUM
     MOVE BLK-GOTO-PAD TO WS-NUM PERFORM ADD-NUM
     MOVE BLK-SLAG TO WS-NUM PERFORM ADD-NUM
     MOVE BLOCK-COUNT TO WS-NUM PERFORM ADD-NUM
     MOVE "0 1 2 3 4 5 6 7 8 9 10 11 12" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test content tables block state id constants" TO TL-CASE
     PERFORM START-ROW
     MOVE ST-VOID TO WS-NUM PERFORM ADD-NUM
     MOVE ST-BASEPLATE TO WS-NUM PERFORM ADD-NUM
     MOVE ST-GREYSTONE TO WS-NUM PERFORM ADD-NUM
     MOVE ST-LOAM TO WS-NUM PERFORM ADD-NUM
     MOVE ST-TURF TO WS-NUM PERFORM ADD-NUM
     MOVE ST-GRIT TO WS-NUM PERFORM ADD-NUM
     MOVE ST-CARDSTACK-X-PUNCHED TO WS-NUM PERFORM ADD-NUM
     MOVE ST-CARDSTACK-X TO WS-NUM PERFORM ADD-NUM
     MOVE ST-CARDSTACK-Y-PUNCHED TO WS-NUM PERFORM ADD-NUM
     MOVE ST-CARDSTACK-Y TO WS-NUM PERFORM ADD-NUM
     MOVE ST-CARDSTACK-Z-PUNCHED TO WS-NUM PERFORM ADD-NUM
     MOVE ST-CARDSTACK-Z TO WS-NUM PERFORM ADD-NUM
     MOVE ST-LUCITE TO WS-NUM PERFORM ADD-NUM
     MOVE ST-GLOWTUBE-LIT TO WS-NUM PERFORM ADD-NUM
     MOVE ST-GLOWTUBE-UNLIT TO WS-NUM PERFORM ADD-NUM
     MOVE ST-LEDGER-TILE TO WS-NUM PERFORM ADD-NUM
     MOVE ST-GOTO-PAD TO WS-NUM PERFORM ADD-NUM
     MOVE ST-SLAG TO WS-NUM PERFORM ADD-NUM
     MOVE BLOCK-STATE-COUNT TO WS-NUM PERFORM ADD-NUM
     MOVE "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test content tables palette widths and biome ids" TO TL-CASE
     PERFORM START-ROW
     MOVE BLOCK-PALETTE-BITS TO WS-NUM PERFORM ADD-NUM
     MOVE BIOME-PALETTE-BITS TO WS-NUM PERFORM ADD-NUM
     MOVE BIOME-PLAINS TO WS-NUM PERFORM ADD-NUM
     MOVE BIOME-UPLAND TO WS-NUM PERFORM ADD-NUM
     MOVE BIOME-ASH-FLATS TO WS-NUM PERFORM ADD-NUM
     MOVE "5 2 0 1 2" TO TL-EXPECTED
     PERFORM ASSERT-ROW

*>   Block table (§1.1), one case per block.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BLOCK-COUNT
         MOVE SPACES TO TL-CASE
         COMPUTE WS-EDIT = WS-I - 1
         STRING "test content tables block " DELIMITED BY SIZE
             FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-CASE
         PERFORM START-ROW
         COMPUTE WS-NUM = WS-I - 1 PERFORM ADD-NUM
         PERFORM ADD-SPACE
         STRING BL-KEY(WS-I)(1:BL-KEY-LENGTH(WS-I)) DELIMITED BY SIZE
             INTO WS-ROW WITH POINTER WS-PTR
         MOVE BL-SOLID(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE BL-OPAQUE(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE BL-LIGHT(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE BL-BREAK-MS(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE BL-CLASS(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE BL-FIRST-STATE(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE BL-STATE-COUNT(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE BL-DEFAULT-STATE(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE WS-BLOCK-ROW(WS-I) TO TL-EXPECTED
         PERFORM ASSERT-ROW
     END-PERFORM

     MOVE "test content tables block class constants" TO TL-CASE
     PERFORM START-ROW
     MOVE BLOCK-CLASS-NONE TO WS-NUM PERFORM ADD-NUM
     MOVE BLOCK-CLASS-HARD TO WS-NUM PERFORM ADD-NUM
     MOVE BLOCK-CLASS-SOFT TO WS-NUM PERFORM ADD-NUM
     MOVE BREAK-UNBREAKABLE TO WS-NUM PERFORM ADD-NUM
     MOVE "0 1 2 -1" TO TL-EXPECTED
     PERFORM ASSERT-ROW

*>   Block-state table (§1.2), one case per state.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BLOCK-STATE-COUNT
         MOVE SPACES TO TL-CASE
         COMPUTE WS-EDIT = WS-I - 1
         STRING "test content tables block state " DELIMITED BY SIZE
             FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-CASE
         PERFORM START-ROW
         COMPUTE WS-NUM = WS-I - 1 PERFORM ADD-NUM
         MOVE SB-BLOCK(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE SB-SOLID(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE SB-OPAQUE(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE SB-LIGHT(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE SB-AXIS(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE SB-PUNCHED(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE SB-LIT(WS-I) TO WS-NUM PERFORM ADD-NUM
         IF SB-PROPS(WS-I) NOT = SPACES
             PERFORM ADD-SPACE
             STRING FUNCTION TRIM(SB-PROPS(WS-I)) DELIMITED BY SIZE
                 INTO WS-ROW WITH POINTER WS-PTR
         END-IF
         MOVE WS-STATE-ROW(WS-I) TO TL-EXPECTED
         PERFORM ASSERT-ROW
     END-PERFORM

*>   Every state of a block lies in the block's range, and states of a block share its solid and
*>   opaque flags (§1.2: first state = number of states before the block).
     MOVE "test content tables state ranges match blocks" TO TL-CASE
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-S
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BLOCK-COUNT
         IF BL-FIRST-STATE(WS-I) NOT = WS-S
             ADD 1 TO WS-BAD
         END-IF
         IF BL-DEFAULT-STATE(WS-I) < BL-FIRST-STATE(WS-I)
            OR BL-DEFAULT-STATE(WS-I) >= BL-FIRST-STATE(WS-I) + BL-STATE-COUNT(WS-I)
             ADD 1 TO WS-BAD
         END-IF
         PERFORM BL-STATE-COUNT(WS-I) TIMES
             ADD 1 TO WS-S
             IF SB-BLOCK(WS-S) NOT = WS-I - 1
                OR SB-SOLID(WS-S) NOT = BL-SOLID(WS-I)
                OR SB-OPAQUE(WS-S) NOT = BL-OPAQUE(WS-I)
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
         IF SB-LIGHT(BL-DEFAULT-STATE(WS-I) + 1) NOT = BL-LIGHT(WS-I)
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test content tables cardstack and glowtube default states" TO TL-CASE
     PERFORM START-ROW
     MOVE BL-DEFAULT-STATE(BLK-CARDSTACK + 1) TO WS-NUM PERFORM ADD-NUM
     MOVE BL-DEFAULT-STATE(BLK-GLOWTUBE + 1) TO WS-NUM PERFORM ADD-NUM
     MOVE "9 13" TO TL-EXPECTED
     PERFORM ASSERT-ROW

*>   Item table (§2, §10.4, §11.5), one case per item.
     MOVE "test content tables item count" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 18 TO TL-EXPECTED-N
     MOVE ITEM-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > ITEM-COUNT
         MOVE SPACES TO TL-CASE
         COMPUTE WS-EDIT = WS-I - 1
         STRING "test content tables item " DELIMITED BY SIZE
             FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-CASE
         PERFORM START-ROW
         COMPUTE WS-NUM = WS-I - 1 PERFORM ADD-NUM
         PERFORM ADD-SPACE
         STRING IT-KEY(WS-I)(1:IT-KEY-LENGTH(WS-I)) DELIMITED BY SIZE
             INTO WS-ROW WITH POINTER WS-PTR
         MOVE IT-PLACES-STATE(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE IT-MAX-STACK(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE IT-TOOL-CLASS(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE IT-FOOD(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE IT-ATTACK(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE WS-ITEM-ROW(WS-I) TO TL-EXPECTED
         PERFORM ASSERT-ROW
     END-PERFORM

*>   Starting inventory (§2 "Starting inventory", US4-8): slot item count per row.
     MOVE "test content tables starting inventory (slots 0 to 7 items 2 to 9 x 64, slot 8 "
         & "pry_bar, slot 9 trowel)" TO TL-CASE
     PERFORM START-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > START-ITEM-COUNT
         MOVE SI-SLOT(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE SI-ITEM(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE SI-COUNT(WS-I) TO WS-NUM PERFORM ADD-NUM
     END-PERFORM
     MOVE "0 2 64 1 3 64 2 4 64 3 5 64 4 6 64 5 7 64 6 8 64 7 9 64 8 10 1 9 11 1"
         TO TL-EXPECTED
     PERFORM ASSERT-ROW

*>   Entity type table (§3, §12.1).
     MOVE "test content tables entity type id constants" TO TL-CASE
     PERFORM START-ROW
     MOVE ET-OPERATOR TO WS-NUM PERFORM ADD-NUM
     MOVE ET-LOOSE-ITEM TO WS-NUM PERFORM ADD-NUM
     MOVE ET-SODGRAZER TO WS-NUM PERFORM ADD-NUM
     MOVE ET-ABEND TO WS-NUM PERFORM ADD-NUM
     MOVE ENTITY-TYPE-COUNT TO WS-NUM PERFORM ADD-NUM
     MOVE "0 1 2 3 4" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > ENTITY-TYPE-COUNT
         MOVE SPACES TO TL-CASE
         COMPUTE WS-EDIT = WS-I - 1
         STRING "test content tables entity type " DELIMITED BY SIZE
             FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-CASE
         PERFORM START-ROW
         COMPUTE WS-NUM = WS-I - 1 PERFORM ADD-NUM
         PERFORM ADD-SPACE
         STRING ET-KEY(WS-I)(1:ET-KEY-LENGTH(WS-I)) DELIMITED BY SIZE
             INTO WS-ROW WITH POINTER WS-PTR
         MOVE ET-WIDTH-MILLI(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE ET-HEIGHT-MILLI(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE ET-EYE-MILLI(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE WS-ENTITY-ROW(WS-I) TO TL-EXPECTED
         PERFORM ASSERT-ROW
     END-PERFORM

*>   Mob types (§12.1). Row: entity type, key, kind (0 passive, 1 hostile), maximum health, wander,
*>   flee and pursue speeds, notice, give-up and attack reach (thousandths of a block), attack
*>   cause (RULES.cpy CAUSE-*, 0 none), attack cooldown, yield item and count, dimension cap (§12.4).
     MOVE "test content tables mob type constants" TO TL-CASE
     PERFORM START-ROW
     MOVE MOB-TYPE-COUNT TO WS-NUM PERFORM ADD-NUM
     MOVE MOB-FIRST-TYPE TO WS-NUM PERFORM ADD-NUM
     MOVE MOB-PASSIVE TO WS-NUM PERFORM ADD-NUM
     MOVE MOB-HOSTILE TO WS-NUM PERFORM ADD-NUM
     MOVE "2 2 0 1" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MOB-TYPE-COUNT
         MOVE SPACES TO TL-CASE
         STRING "test content tables mob type " DELIMITED BY SIZE
             ET-KEY(MB-ENTITY-TYPE(WS-I) + 1)(1:ET-KEY-LENGTH(MB-ENTITY-TYPE(WS-I) + 1))
             DELIMITED BY SIZE INTO TL-CASE
         PERFORM START-ROW
         MOVE MB-ENTITY-TYPE(WS-I) TO WS-NUM PERFORM ADD-NUM
         PERFORM ADD-SPACE
         STRING ET-KEY(MB-ENTITY-TYPE(WS-I) + 1)(1:ET-KEY-LENGTH(MB-ENTITY-TYPE(WS-I) + 1))
             DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
         MOVE MB-KIND(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE MB-HEALTH(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE MB-WANDER-MILLI(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE MB-FLEE-MILLI(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE MB-PURSUE-MILLI(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE MB-NOTICE-MILLI(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE MB-GIVE-UP-MILLI(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE MB-REACH-MILLI(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE MB-CAUSE(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE MB-COOLDOWN(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE MB-YIELD-ITEM(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE MB-YIELD-COUNT(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE MB-CAP(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE WS-MOB-ROW(WS-I) TO TL-EXPECTED
         PERFORM ASSERT-ROW
     END-PERFORM

     MOVE "test content tables mob attack amount (§12.3, §10.3: an abend hit does 3)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 3 TO TL-EXPECTED-N
     MOVE RULE-CAUSE-AMOUNT(MB-CAUSE(2)) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test content tables mob physics (§12.2: gravity 0.05, vertical drag 0.96, step-up 1)"
         TO TL-CASE
     PERFORM START-ROW
     MOVE MOB-GRAVITY-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE MOB-DRAG-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE MOB-STEP-UP TO WS-NUM PERFORM ADD-NUM
     MOVE "50 960 1" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test content tables mob behaviour (§12.3: decide every 80 ticks, stand when r mod 3 = "
         & "0, 8 yaws of 45 degrees, flee 40 ticks, pursuit stops within 1.0)" TO TL-CASE
     PERFORM START-ROW
     MOVE MOB-DECIDE-TICKS TO WS-NUM PERFORM ADD-NUM
     MOVE MOB-STAND-MOD TO WS-NUM PERFORM ADD-NUM
     MOVE MOB-YAW-DIRECTIONS TO WS-NUM PERFORM ADD-NUM
     MOVE MOB-YAW-STEP TO WS-NUM PERFORM ADD-NUM
     MOVE MOB-FLEE-TICKS TO WS-NUM PERFORM ADD-NUM
     MOVE MOB-PURSUE-STOP-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE "80 3 8 45 40 1000" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test content tables mob spawning (§12.4: every 100 ticks, offsets (r mod 41) - 20, "
         & "none nearer than 8, no player within 8.0; §4.8 night 16000 to 29000)" TO TL-CASE
     PERFORM START-ROW
     MOVE MOB-SPAWN-TICKS TO WS-NUM PERFORM ADD-NUM
     MOVE MOB-SPAWN-SPREAD TO WS-NUM PERFORM ADD-NUM
     MOVE MOB-SPAWN-OFFSET TO WS-NUM PERFORM ADD-NUM
     MOVE MOB-SPAWN-MIN TO WS-NUM PERFORM ADD-NUM
     MOVE MOB-SPAWN-NEAR-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE MOB-NIGHT-START TO WS-NUM PERFORM ADD-NUM
     MOVE MOB-NIGHT-END TO WS-NUM PERFORM ADD-NUM
     MOVE "100 41 20 8 8000 16000 29000" TO TL-EXPECTED
     PERFORM ASSERT-ROW

*>   Spawn rules (§12.4 step 4, §15.4), in order. Row: dimension row, time (0 any, 1 day, 2
*>   night), ground block (-1 any), maximum block light (-1 any), entity type.
     MOVE "test content tables mob spawn rules (§12.4 step 4)" TO TL-CASE
     PERFORM START-ROW
     MOVE MOB-SPAWN-RULE-COUNT TO WS-NUM PERFORM ADD-NUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MOB-SPAWN-RULE-COUNT
         MOVE MS-DIM(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE MS-TIME(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE MS-GROUND(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE MS-LIGHT(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE MS-TYPE(WS-I) TO WS-NUM PERFORM ADD-NUM
     END-PERFORM
     MOVE "3 1 2 -1 5 3 1 1 4 -1 2 2 0 11 5 3" TO TL-EXPECTED
     PERFORM ASSERT-ROW

*>   Recipes (§13): the count, then one case per recipe in display-id order.
     MOVE "test content tables recipe count (§13: nine recipes, at most three ingredient lines)"
         TO TL-CASE
     PERFORM START-ROW
     MOVE RECIPE-COUNT TO WS-NUM PERFORM ADD-NUM
     MOVE RECIPE-MAX-LINES TO WS-NUM PERFORM ADD-NUM
     MOVE "9 3" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RECIPE-COUNT
         MOVE SPACES TO TL-CASE
         COMPUTE WS-EDIT = WS-I - 1
         STRING "test content tables recipe " DELIMITED BY SIZE
             FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-CASE
         PERFORM START-ROW
         COMPUTE WS-NUM = WS-I - 1 PERFORM ADD-NUM
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > RP-LINE-COUNT(WS-I)
             MOVE RP-IN-COUNT(WS-I, WS-J) TO WS-NUM PERFORM ADD-NUM
             MOVE RP-IN-ITEM(WS-I, WS-J) TO WS-F
             STRING "x" IT-KEY(WS-F + 1)(1:IT-KEY-LENGTH(WS-F + 1)) DELIMITED BY SIZE
                 INTO WS-ROW WITH POINTER WS-PTR
         END-PERFORM
         STRING " ->" DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
         MOVE RP-RESULT-COUNT(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE RP-RESULT-ITEM(WS-I) TO WS-F
         STRING "x" IT-KEY(WS-F + 1)(1:IT-KEY-LENGTH(WS-F + 1)) DELIMITED BY SIZE
             INTO WS-ROW WITH POINTER WS-PTR
         MOVE WS-RECIPE-ROW(WS-I) TO TL-EXPECTED
         PERFORM ASSERT-ROW
     END-PERFORM

*>   Weather (§14): the constants, then one case per kind.
     MOVE "test content tables weather constants (§14.1 kinds, §14.3 start kind and time, until "
         & "changed, drizzle chance of 100, §14.4 Game Event numbers, §14.6 hail interval)"
         TO TL-CASE
     PERFORM START-ROW
     MOVE WEATHER-KIND-COUNT TO WS-NUM PERFORM ADD-NUM
     MOVE WK-CLEAR TO WS-NUM PERFORM ADD-NUM
     MOVE WK-DRIZZLE TO WS-NUM PERFORM ADD-NUM
     MOVE WK-HAILSTORM TO WS-NUM PERFORM ADD-NUM
     MOVE WEATHER-START-KIND TO WS-NUM PERFORM ADD-NUM
     MOVE WEATHER-START-TICKS TO WS-NUM PERFORM ADD-NUM
     MOVE WEATHER-UNTIL-CHANGED TO WS-NUM PERFORM ADD-NUM
     MOVE WEATHER-DRIZZLE-CHANCE TO WS-NUM PERFORM ADD-NUM
     MOVE WEATHER-CHANCE-RANGE TO WS-NUM PERFORM ADD-NUM
     MOVE WEATHER-EVENT-START TO WS-NUM PERFORM ADD-NUM
     MOVE WEATHER-EVENT-STOP TO WS-NUM PERFORM ADD-NUM
     MOVE WEATHER-EVENT-RAIN TO WS-NUM PERFORM ADD-NUM
     MOVE WEATHER-EVENT-THUNDER TO WS-NUM PERFORM ADD-NUM
     MOVE WEATHER-HAIL-INTERVAL TO WS-NUM PERFORM ADD-NUM
     MOVE "3 1 2 3 1 6000 -1 70 100 1 2 7 8 80" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WEATHER-KIND-COUNT
         MOVE SPACES TO TL-CASE
         STRING "test content tables weather kind " DELIMITED BY SIZE
             WK-KEY(WS-I)(1:WK-KEY-LENGTH(WS-I)) DELIMITED BY SIZE INTO TL-CASE
         PERFORM START-ROW
         MOVE WS-I TO WS-NUM PERFORM ADD-NUM
         PERFORM ADD-SPACE
         STRING WK-KEY(WS-I)(1:WK-KEY-LENGTH(WS-I)) " "
             FUNCTION TRIM(WK-NAME(WS-I)) DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
         MOVE WK-RAIN-MILLI(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE WK-THUNDER-MILLI(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE WK-EFFECT(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE WK-DURATION-BASE(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE WK-DURATION-SPAN(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE WS-WEATHER-ROW(WS-I) TO TL-EXPECTED
         PERFORM ASSERT-ROW
     END-PERFORM

*>   The dimension table (§5.1, §5.2, §4.6, §14.2, §15.1 to §15.5). Row: key type-id type-key min-y
*>   height sea-level generator light-policy skylight weather biome (-1 = from the generator)
*>   extra (1 = enabled by the extra-dimensions setting) travel-destination-row.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > DIM-TABLE-ROWS
         MOVE SPACES TO TL-CASE
         STRING "test content tables dimension " DELIMITED BY SIZE
             DM-KEY(WS-I)(1:DM-KEY-LENGTH(WS-I)) DELIMITED BY SIZE INTO TL-CASE
         PERFORM START-ROW
         STRING DM-KEY(WS-I)(1:DM-KEY-LENGTH(WS-I)) DELIMITED BY SIZE
             INTO WS-ROW WITH POINTER WS-PTR
         MOVE DM-TYPE-ID(WS-I) TO WS-NUM PERFORM ADD-NUM
         PERFORM ADD-SPACE
         STRING DM-TYPE-KEY(WS-I)(1:DM-TYPE-KEY-LENGTH(WS-I)) DELIMITED BY SIZE
             INTO WS-ROW WITH POINTER WS-PTR
         MOVE DM-MIN-Y(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE DM-HEIGHT(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE DM-SEA-LEVEL(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE DM-GENERATOR(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE DM-LIGHT-POLICY(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE DM-SKYLIGHT(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE DM-WEATHER(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE DM-BIOME(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE DM-EXTRA(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE DM-TRAVEL-TO(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE WS-DIMENSION-ROW(WS-I) TO TL-EXPECTED
         PERFORM ASSERT-ROW
     END-PERFORM

*>   Row numbers, generator and light policy ids, the §15.2 generator constants (base, amplitude,
*>   x and z divisors, marker chunk modulus) and the §15.5 travel constants (travel block id, the
*>   arrival goto_pad state, cooldown ticks, Respawn data to keep).
     MOVE "test content tables dimension constants" TO TL-CASE
     PERFORM START-ROW
     MOVE DIM-MAIN TO WS-NUM PERFORM ADD-NUM
     MOVE DIM-SUBROUTINE TO WS-NUM PERFORM ADD-NUM
     MOVE DIM-TABLE-ROWS TO WS-NUM PERFORM ADD-NUM
     MOVE DIM-GEN-MAIN TO WS-NUM PERFORM ADD-NUM
     MOVE DIM-GEN-SUBROUTINE TO WS-NUM PERFORM ADD-NUM
     MOVE DIM-LIGHT-STANDIN TO WS-NUM PERFORM ADD-NUM
     MOVE DIM-LIGHT-BLOCK-ONLY TO WS-NUM PERFORM ADD-NUM
     MOVE "1 2 2 1 2 1 2" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test content tables subroutine generator constants" TO TL-CASE
     PERFORM START-ROW
     MOVE GEN-SUB-BASE TO WS-NUM PERFORM ADD-NUM
     MOVE GEN-SUB-AMPLITUDE TO WS-NUM PERFORM ADD-NUM
     MOVE GEN-SUB-X-DIVISOR TO WS-NUM PERFORM ADD-NUM
     MOVE GEN-SUB-Z-DIVISOR TO WS-NUM PERFORM ADD-NUM
     MOVE GEN-SUB-MARKER-MOD TO WS-NUM PERFORM ADD-NUM
     MOVE "32 5 11 13 3" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test content tables travel constants" TO TL-CASE
     PERFORM START-ROW
     MOVE TRAVEL-BLOCK TO WS-NUM PERFORM ADD-NUM
     MOVE TRAVEL-PAD-STATE TO WS-NUM PERFORM ADD-NUM
     MOVE TRAVEL-COOLDOWN TO WS-NUM PERFORM ADD-NUM
     MOVE TRAVEL-KEEP TO WS-NUM PERFORM ADD-NUM
     MOVE "10 16 20 3" TO TL-EXPECTED
     PERFORM ASSERT-ROW

*>   Spawn point (§5.2): feet (4.5, 54.0, 8.5) in tenths, yaw -90, pitch 0.
     MOVE "test content tables spawn point" TO TL-CASE
     PERFORM START-ROW
     MOVE SPAWN-X10 TO WS-NUM PERFORM ADD-NUM
     MOVE SPAWN-Y10 TO WS-NUM PERFORM ADD-NUM
     MOVE SPAWN-Z10 TO WS-NUM PERFORM ADD-NUM
     MOVE SPAWN-YAW TO WS-NUM PERFORM ADD-NUM
     MOVE SPAWN-PITCH TO WS-NUM PERFORM ADD-NUM
     MOVE "45 540 85 -90 0" TO TL-EXPECTED
     PERFORM ASSERT-ROW

*>   Player rules (§10.1, §11.1).
     MOVE "test content tables maximum health" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 30 TO TL-EXPECTED-N
     MOVE RULE-MAX-HEALTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test content tables maximum food" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 24 TO TL-EXPECTED-N
     MOVE RULE-MAX-FOOD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test content tables day length (standin-content §4.8: Time 0 to 29999)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 30000 TO TL-EXPECTED-N
     MOVE RULE-DAY-LENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Health and death (§10.2 to §10.7; US7), lengths and amounts in thousandths.
     MOVE "test content tables hurt cooldown and fall damage (§10.2: 12 ticks; §10.3: safe fall "
         & "height 4, 2 x (floor(D) - 4))" TO TL-CASE
     PERFORM START-ROW
     MOVE RULE-HURT-COOLDOWN TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-SAFE-FALL TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-FALL-FACTOR TO WS-NUM PERFORM ADD-NUM
     MOVE "12 4 2" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test content tables causes of damage (§10.3: per cause fall, abend, player, "
         & "starvation, hail, command the damage type id and fixed amount)" TO TL-CASE
     PERFORM START-ROW
     MOVE CAUSE-FALL TO WS-NUM PERFORM ADD-NUM
     MOVE CAUSE-ABEND TO WS-NUM PERFORM ADD-NUM
     MOVE CAUSE-PLAYER TO WS-NUM PERFORM ADD-NUM
     MOVE CAUSE-STARVATION TO WS-NUM PERFORM ADD-NUM
     MOVE CAUSE-HAIL TO WS-NUM PERFORM ADD-NUM
     MOVE CAUSE-COMMAND TO WS-NUM PERFORM ADD-NUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CAUSE-COUNT
         MOVE RULE-CAUSE-TYPE(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE RULE-CAUSE-AMOUNT(WS-I) TO WS-NUM PERFORM ADD-NUM
     END-PERFORM
     MOVE "1 2 3 4 5 6 1 0 28 3 29 0 30 1 31 1 0 0" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test content tables starvation and attacks (§10.3: every 60th tick; §10.4: reach 4.0 "
         & "from the eye point feet + 1.6)" TO TL-CASE
     PERFORM START-ROW
     MOVE RULE-STARVE-TICKS TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-ATTACK-REACH-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-ATTACK-EYE-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE "60 4000 1600" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test content tables recovery (§10.5: food at least 20, every 50 ticks 1 health and "
         & "2.5 exhaustion)" TO TL-CASE
     PERFORM START-ROW
     MOVE RULE-RECOVER-FOOD TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-RECOVER-TICKS TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-RECOVER-AMOUNT TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-RECOVER-EXHAUST-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE "20 50 1 2500" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test content tables death drops (§10.6: feet + 0.5, spread 0.02, lift 0.2, pickup "
         & "delay 30)" TO TL-CASE
     PERFORM START-ROW
     MOVE RULE-DEATH-DY-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-DEATH-SPREAD-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-DEATH-LIFT-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-DEATH-DELAY TO WS-NUM PERFORM ADD-NUM
     MOVE "500 20 200 30" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test content tables death messages (§10.7: per cause the translate key and its "
         & "arguments, v victim name, a attacker name)" TO TL-CASE
     PERFORM START-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CAUSE-COUNT
         PERFORM ADD-SPACE
         STRING DTH-KEY(WS-I)(1:DTH-KEY-LENGTH(WS-I)) DELIMITED BY SIZE
             INTO WS-ROW WITH POINTER WS-PTR
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > DTH-ARG-COUNT(WS-I)
             IF DTH-ARG-KIND(WS-I, WS-J) = MSG-ARG-VICTIM
                 STRING ",v" DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
             ELSE
                 STRING ",a" DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "cobolcraft.death.fall,v cobolcraft.death.mob.abend,v cobolcraft.death.player,v,a "
         & "cobolcraft.death.starvation,v cobolcraft.death.hail,v cobolcraft.death.command,v"
         TO TL-EXPECTED
     PERFORM ASSERT-ROW

*>   Hunger and eating (§11.2, §11.3, §11.6; US8), exhaustion in thousandths. The movement speeds
*>   of §11.4 are the client's (client-surface.md §3) and are not core rules.
     MOVE "test content tables exhaustion (§11.2: per tick 0.005, per block walking 0.02 and "
         & "running 0.12, per jump 0.3, per hit 0.15, per survival break 0.025)" TO TL-CASE
     PERFORM START-ROW
     MOVE RULE-EXHAUST-TICK-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-EXHAUST-WALK-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-EXHAUST-SPRINT-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-EXHAUST-JUMP-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-EXHAUST-ATTACK-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-EXHAUST-BREAK-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE "5 20 120 300 150 25" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test content tables food point removal and eating (§11.3: 5.0 exhaustion per food "
         & "point; §11.6: eating time 30 ticks, Entity Event 9 eating finished)" TO TL-CASE
     PERFORM START-ROW
     MOVE RULE-EXHAUST-FOOD-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-EAT-TICKS TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-EAT-EVENT TO WS-NUM PERFORM ADD-NUM
     MOVE "5000 30 9" TO TL-EXPECTED
     PERFORM ASSERT-ROW

*>   Ground items (§9, §1.3), lengths and factors in thousandths.
     MOVE "test content tables ground item pickup delays (§9.1: break 6, throw 30)" TO TL-CASE
     PERFORM START-ROW
     MOVE RULE-GI-BREAK-DELAY TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-GI-THROW-DELAY TO WS-NUM PERFORM ADD-NUM
     MOVE "6 30" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test content tables ground item source positions (§1.3 yield (0.5, 0.25, 0.5), §9.1 "
         & "throw feet + 1.3)" TO TL-CASE
     PERFORM START-ROW
     MOVE RULE-GI-BREAK-DXZ-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-GI-BREAK-DY-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-GI-THROW-DY-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE "500 250 1300" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test content tables ground item thrown motion (§9.1: speed 0.25, lift 0.12)"
         TO TL-CASE
     PERFORM START-ROW
     MOVE RULE-GI-THROW-SPEED-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-GI-THROW-LIFT-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE "250 120" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test content tables ground item age (§9.2: near 32.0, despawn at 4800)" TO TL-CASE
     PERFORM START-ROW
     MOVE RULE-GI-NEAR-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-GI-DESPAWN-AGE TO WS-NUM PERFORM ADD-NUM
     MOVE "32000 4800" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test content tables ground item movement (§9.2: gravity 0.035, drag 0.97)" TO TL-CASE
     PERFORM START-ROW
     MOVE RULE-GI-GRAVITY-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-GI-DRAG-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE "35 970" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test content tables ground item pickup range and merging (§9.3: 0.75 in x and z, "
         & "0.25 in y; §9.2: never merge)" TO TL-CASE
     PERFORM START-ROW
     MOVE RULE-GI-REACH-XZ-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-GI-REACH-Y-MILLI TO WS-NUM PERFORM ADD-NUM
     MOVE RULE-GI-MERGES TO WS-NUM PERFORM ADD-NUM
     MOVE "750 250 0" TO TL-EXPECTED
     PERFORM ASSERT-ROW

     MOVE "test content tables block yields (§1.3: blocks 0 to 11)" TO TL-CASE
     PERFORM START-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE RULE-YIELD-ITEM(WS-I) TO WS-NUM PERFORM ADD-NUM
     END-PERFORM
     MOVE "0 0 2 3 4 5 6 7 8 9 16 17" TO TL-EXPECTED
     PERFORM ASSERT-ROW

*>   Synchronized registries (§4). Summary (§4.2): one case per registry.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > REG-COUNT
         MOVE SPACES TO TL-CASE
         COMPUTE WS-EDIT = WS-I - 1
         STRING "test content tables registry " DELIMITED BY SIZE
             FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-CASE
         PERFORM START-ROW
         COMPUTE WS-NUM = WS-I - 1 PERFORM ADD-NUM
         PERFORM ADD-SPACE
         STRING RG-KEY(WS-I)(1:RG-KEY-LENGTH(WS-I)) DELIMITED BY SIZE
             INTO WS-ROW WITH POINTER WS-PTR
         MOVE RG-ENTRY-COUNT(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE WS-REG-ROW(WS-I) TO TL-EXPECTED
         PERFORM ASSERT-ROW
     END-PERFORM

*>   18 packets and 52 entries (§4.2); each kind's entry count equals its table's row count.
     MOVE "test content tables registry packet and entry totals" TO TL-CASE
     PERFORM START-ROW
     MOVE 0 TO WS-S WS-SUM WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > REG-COUNT
         IF RG-ENTRY-COUNT(WS-I) > 0
             ADD 1 TO WS-S
         END-IF
         ADD RG-ENTRY-COUNT(WS-I) TO WS-SUM
         EVALUATE RG-KIND(WS-I)
             WHEN RGK-EMPTY
                 MOVE 0 TO WS-NUM
             WHEN RGK-BIOME
                 MOVE RB-COUNT TO WS-NUM
             WHEN RGK-CHAT
                 MOVE RC-COUNT TO WS-NUM
             WHEN RGK-MV
                 MOVE 1 TO WS-NUM
                 IF RM-REGISTRY(RG-MV-ROW(WS-I)) NOT = WS-I - 1
                     ADD 1 TO WS-BAD
                 END-IF
             WHEN RGK-DIMENSION-TYPE
                 MOVE RD-COUNT TO WS-NUM
             WHEN RGK-DAMAGE
                 MOVE RX-COUNT TO WS-NUM
             WHEN RGK-CLOCK
                 MOVE RW-COUNT TO WS-NUM
             WHEN OTHER
                 MOVE -1 TO WS-NUM
         END-EVALUATE
         IF RG-ENTRY-COUNT(WS-I) NOT = WS-NUM
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE WS-S TO WS-NUM PERFORM ADD-NUM
     MOVE WS-SUM TO WS-NUM PERFORM ADD-NUM
     MOVE REG-PACKETS TO WS-NUM PERFORM ADD-NUM
     MOVE REG-ENTRIES TO WS-NUM PERFORM ADD-NUM
     MOVE WS-BAD TO WS-NUM PERFORM ADD-NUM
     MOVE "18 52 18 52 0" TO TL-EXPECTED
     PERFORM ASSERT-ROW

*>   worldgen/biome (§4.3): id key has_precipitation temperature downfall (thousandths) water grass
*>   foliage colours.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RB-COUNT
         MOVE SPACES TO TL-CASE
         COMPUTE WS-EDIT = WS-I - 1
         STRING "test content tables biome " DELIMITED BY SIZE
             FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-CASE
         PERFORM START-ROW
         COMPUTE WS-NUM = WS-I - 1 PERFORM ADD-NUM
         PERFORM ADD-SPACE
         STRING RB-KEY(WS-I)(1:RB-KEY-LENGTH(WS-I)) DELIMITED BY SIZE
             INTO WS-ROW WITH POINTER WS-PTR
         MOVE RB-PRECIPITATION(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE RB-TEMPERATURE-MILLI(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE RB-DOWNFALL-MILLI(WS-I) TO WS-NUM PERFORM ADD-NUM
         STRING " " RB-WATER-COLOR(WS-I) " " RB-GRASS-COLOR(WS-I) " " RB-FOLIAGE-COLOR(WS-I)
             DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
         EVALUATE WS-I
             WHEN 1
                 MOVE "0 minecraft:plains 1 600 400 #3A6EA5 #4F8F3A #4F8F3A" TO TL-EXPECTED
             WHEN 2
                 MOVE "1 cobolcraft:upland 1 300 200 #2F5C8C #6B9A55 #6B9A55" TO TL-EXPECTED
             WHEN OTHER
                 MOVE "2 cobolcraft:ash_flats 0 1400 0 #3A2F2A #5A4A40 #5A4A40" TO TL-EXPECTED
         END-EVALUATE
         PERFORM ASSERT-ROW
     END-PERFORM

*>   chat_type (§4.4): key, then per decoration its name, translation_key and parameters.
     MOVE "test content tables chat type 0" TO TL-CASE
     PERFORM START-ROW
     MOVE 0 TO WS-NUM PERFORM ADD-NUM
     PERFORM ADD-SPACE
     STRING RC-KEY(1)(1:RC-KEY-LENGTH(1)) DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 2
         STRING " " RC-DEC-NAME(1, WS-J)(1:RC-DEC-NAME-LENGTH(1, WS-J))
             " " RC-DEC-KEY(1, WS-J)(1:RC-DEC-KEY-LENGTH(1, WS-J))
             DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
         PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > RC-PARAM-COUNT(1, WS-J)
             STRING " " RC-PARAM-NAME(1, WS-J, WS-F)(1:RC-PARAM-LENGTH(1, WS-J, WS-F))
                 DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
         END-PERFORM
     END-PERFORM
     MOVE "0 cobolcraft:say chat cobolcraft.chat.say sender content narration "
         & "cobolcraft.chat.say.narrate sender content" TO TL-EXPECTED
     PERFORM ASSERT-ROW

*>   MV placeholders (§4.5): shared key, texture and sound, then one case per registry.
     MOVE "test content tables MV placeholder key, texture and sound" TO TL-CASE
     PERFORM START-ROW
     STRING RG-PLACEHOLDER-KEY(1:RG-PLACEHOLDER-KEY-LENGTH) " "
         RG-PLACEHOLDER-TEXTURE(1:RG-PLACEHOLDER-TEXTURE-LENGTH) " "
         RG-PLACEHOLDER-SOUND(1:RG-PLACEHOLDER-SOUND-LENGTH)
         DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
     MOVE "cobolcraft:placeholder cobolcraft:entity/placeholder cobolcraft:silent"
         TO TL-EXPECTED
     PERFORM ASSERT-ROW

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RM-COUNT
         MOVE SPACES TO TL-CASE
         STRING "test content tables MV registry " DELIMITED BY SIZE
             RG-KEY(RM-REGISTRY(WS-I) + 1)(1:RG-KEY-LENGTH(RM-REGISTRY(WS-I) + 1))
             DELIMITED BY SIZE INTO TL-CASE
         PERFORM START-ROW
         STRING RG-KEY(RM-REGISTRY(WS-I) + 1)(1:RG-KEY-LENGTH(RM-REGISTRY(WS-I) + 1))
             DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > RM-GROUP-COUNT(WS-I)
             STRING " " RM-GROUP-NAME(WS-I, WS-J)(1:RM-GROUP-LENGTH(WS-I, WS-J))
                 DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
         END-PERFORM
         PERFORM VARYING WS-F FROM RM-FIRST-FIELD(WS-I) BY 1
                 UNTIL WS-F >= RM-FIRST-FIELD(WS-I) + RM-FIELD-COUNT(WS-I)
             STRING " " RF-NAME(WS-F)(1:RF-NAME-LENGTH(WS-F)) "="
                 DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
             EVALUATE RF-KIND(WS-F)
                 WHEN RMF-TEXTURE
                     STRING "T" DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
                 WHEN RMF-SOUND
                     STRING "S" DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
                 WHEN RMF-STRING
                     STRING RF-STRING(WS-F)(1:RF-STRING-LENGTH(WS-F)) DELIMITED BY SIZE
                         INTO WS-ROW WITH POINTER WS-PTR
                 WHEN OTHER
                     MOVE RF-INT(WS-F) TO WS-EDIT
                     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
                         INTO WS-ROW WITH POINTER WS-PTR
             END-EVALUATE
         END-PERFORM
         MOVE WS-MV-ROW(WS-I) TO TL-EXPECTED
         PERFORM ASSERT-ROW
     END-PERFORM

*>   dimension_type (§4.6): id key has_fixed_time (-1 absent) has_skylight has_ceiling
*>   has_ender_dragon_fight coordinate_scale min_y height logical_height ambient_light (scale and
*>   light in thousandths) monster_spawn_light_level monster_spawn_block_light_limit skybox
*>   default_clock ("-" = absent).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RD-COUNT
         MOVE SPACES TO TL-CASE
         COMPUTE WS-EDIT = WS-I - 1
         STRING "test content tables dimension type " DELIMITED BY SIZE
             FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-CASE
         PERFORM START-ROW
         COMPUTE WS-NUM = WS-I - 1 PERFORM ADD-NUM
         PERFORM ADD-SPACE
         STRING RD-KEY(WS-I)(1:RD-KEY-LENGTH(WS-I)) DELIMITED BY SIZE
             INTO WS-ROW WITH POINTER WS-PTR
         MOVE RD-FIXED-TIME(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE RD-SKYLIGHT(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE RD-CEILING(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE RD-DRAGON-FIGHT(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE RD-COORD-SCALE-MILLI(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE RD-MIN-Y(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE RD-HEIGHT(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE RD-LOGICAL-HEIGHT(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE RD-AMBIENT-MILLI(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE RD-SPAWN-LIGHT(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE RD-SPAWN-BLOCK-LIMIT(WS-I) TO WS-NUM PERFORM ADD-NUM
         IF RD-SKYBOX-LENGTH(WS-I) > 0
             STRING " " RD-SKYBOX(WS-I)(1:RD-SKYBOX-LENGTH(WS-I)) DELIMITED BY SIZE
                 INTO WS-ROW WITH POINTER WS-PTR
         ELSE
             STRING " -" DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
         END-IF
         IF RD-CLOCK-LENGTH(WS-I) > 0
             STRING " " RD-CLOCK(WS-I)(1:RD-CLOCK-LENGTH(WS-I)) DELIMITED BY SIZE
                 INTO WS-ROW WITH POINTER WS-PTR
         ELSE
             STRING " -" DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
         END-IF
         IF WS-I = 1
             MOVE "0 cobolcraft:surface -1 1 0 0 1000 0 256 256 0 0 0 - cobolcraft:daylight"
                 TO TL-EXPECTED
         ELSE
             MOVE "1 cobolcraft:sunless 1 0 0 0 1000 0 128 128 0 0 0 none -" TO TL-EXPECTED
         END-IF
         PERFORM ASSERT-ROW
     END-PERFORM

*>   damage_type (§4.7), one case per entry.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RX-COUNT
         MOVE SPACES TO TL-CASE
         COMPUTE WS-EDIT = WS-I - 1
         STRING "test content tables damage type " DELIMITED BY SIZE
             FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-CASE
         PERFORM START-ROW
         COMPUTE WS-NUM = WS-I - 1 PERFORM ADD-NUM
         STRING " " RX-KEY(WS-I)(1:RX-KEY-LENGTH(WS-I))
             " " RX-MESSAGE(WS-I)(1:RX-MESSAGE-LENGTH(WS-I))
             " " RX-SCALING(WS-I)(1:RX-SCALING-LENGTH(WS-I))
             DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
         MOVE RX-EXHAUSTION-MILLI(WS-I) TO WS-NUM PERFORM ADD-NUM
         MOVE WS-DAMAGE-ROW(WS-I) TO TL-EXPECTED
         PERFORM ASSERT-ROW
     END-PERFORM

*>   world_clock (§4.8).
     MOVE "test content tables world clock 0" TO TL-CASE
     PERFORM START-ROW
     MOVE 0 TO WS-NUM PERFORM ADD-NUM
     STRING " " RW-KEY(1)(1:RW-KEY-LENGTH(1)) DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
     MOVE "0 cobolcraft:daylight" TO TL-EXPECTED
     PERFORM ASSERT-ROW

*>   The en_us texts of the console (CONSOLELANG.cpy; docs/protocol/08-resource-packs.md §10.8.2 to
*>   §10.8.4): every translation key the core sends, with its text.
     MOVE "test content tables console language: 80 keys" TO TL-CASE
     PERFORM START-ROW
     MOVE CL-COUNT TO WS-NUM PERFORM ADD-NUM
     MOVE "80" TO TL-EXPECTED
     PERFORM ASSERT-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CL-COUNT
         MOVE SPACES TO TL-CASE
         STRING "test content tables console language " CL-KEY(WS-I)(1:CL-KEY-LENGTH(WS-I))
             DELIMITED BY SIZE INTO TL-CASE
         PERFORM START-ROW
         STRING CL-KEY(WS-I)(1:CL-KEY-LENGTH(WS-I)) " => " CL-TEXT(WS-I)(1:CL-TEXT-LENGTH(WS-I))
             DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
         MOVE WS-CONSOLE-ROW(WS-I) TO TL-EXPECTED
         PERFORM ASSERT-ROW
     END-PERFORM

     STOP RUN.

*> Row rendering helpers: START-ROW clears the row; ADD-NUM appends WS-NUM, preceded by a space
*> unless the row is empty; ASSERT-ROW compares the row with TL-EXPECTED.
 START-ROW.
     MOVE SPACES TO WS-ROW
     MOVE 1 TO WS-PTR.

 ADD-SPACE.
     IF WS-PTR > 1
         STRING " " DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR
     END-IF.

 ADD-NUM.
     PERFORM ADD-SPACE
     MOVE WS-NUM TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-ROW WITH POINTER WS-PTR.

 ASSERT-ROW.
     MOVE "T" TO TL-MODE
     MOVE WS-ROW TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
