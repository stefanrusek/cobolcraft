*> English texts of the built-in pack (docs/protocol/08-resource-packs.md §10.8, every key of its
*> tables 10.8.1 to 10.8.6, in table order), transcribed for assets/cobolcraft/lang/en_us.json of
*> client/src/packs/builtin.cob. Never edit a text here without changing 08 §10.8 first. The last rows are
*> the cobolcraft.packs.* messages of 22 §9.2 and the cobolcraft.world_type.* and type texts of
*> docs/design/builtin-ui-art.md §7.2 (the title banner, the create-world and world-list type), then the 20 menu keys of docs/protocol/40-menus-3 and 40-menus-5 (anvil, smithing, merchant, lectern, beacon texts; standard key names and English read there).
 78 BI-LANG-COUNT           VALUE 356.
 01 BI-LANG-DATA.
    05 FILLER PIC X(80) VALUE "block.cobolcraft.baseplate".
    05 FILLER PIC X(128) VALUE "Baseplate".
    05 FILLER PIC X(80) VALUE "block.cobolcraft.greystone".
    05 FILLER PIC X(128) VALUE "Greystone".
    05 FILLER PIC X(80) VALUE "block.cobolcraft.loam".
    05 FILLER PIC X(128) VALUE "Loam".
    05 FILLER PIC X(80) VALUE "block.cobolcraft.turf".
    05 FILLER PIC X(128) VALUE "Turf".
    05 FILLER PIC X(80) VALUE "block.cobolcraft.grit".
    05 FILLER PIC X(128) VALUE "Grit".
    05 FILLER PIC X(80) VALUE "block.cobolcraft.cardstack".
    05 FILLER PIC X(128) VALUE "Cardstack".
    05 FILLER PIC X(80) VALUE "block.cobolcraft.lucite".
    05 FILLER PIC X(128) VALUE "Lucite".
    05 FILLER PIC X(80) VALUE "block.cobolcraft.glowtube".
    05 FILLER PIC X(128) VALUE "Glowtube".
    05 FILLER PIC X(80) VALUE "block.cobolcraft.ledger_tile".
    05 FILLER PIC X(128) VALUE "Ledger Tile".
    05 FILLER PIC X(80) VALUE "block.cobolcraft.goto_pad".
    05 FILLER PIC X(128) VALUE "GOTO Pad".
    05 FILLER PIC X(80) VALUE "block.cobolcraft.slag".
    05 FILLER PIC X(128) VALUE "Slag".
    05 FILLER PIC X(80) VALUE "item.cobolcraft.pry_bar".
    05 FILLER PIC X(128) VALUE "Pry Bar".
    05 FILLER PIC X(80) VALUE "item.cobolcraft.trowel".
    05 FILLER PIC X(128) VALUE "Trowel".
    05 FILLER PIC X(80) VALUE "item.cobolcraft.grazer_flank".
    05 FILLER PIC X(128) VALUE "Grazer Flank".
    05 FILLER PIC X(80) VALUE "item.cobolcraft.seared_flank".
    05 FILLER PIC X(128) VALUE "Seared Flank".
    05 FILLER PIC X(80) VALUE "item.cobolcraft.sod_cake".
    05 FILLER PIC X(128) VALUE "Sod Cake".
    05 FILLER PIC X(80) VALUE "item.cobolcraft.dump_shard".
    05 FILLER PIC X(128) VALUE "Dump Shard".
    05 FILLER PIC X(80) VALUE "entity.cobolcraft.operator".
    05 FILLER PIC X(128) VALUE "Operator".
    05 FILLER PIC X(80) VALUE "entity.cobolcraft.sodgrazer".
    05 FILLER PIC X(128) VALUE "Sodgrazer".
    05 FILLER PIC X(80) VALUE "entity.cobolcraft.abend".
    05 FILLER PIC X(128) VALUE "Abend".
    05 FILLER PIC X(80) VALUE "weather.cobolcraft.clear".
    05 FILLER PIC X(128) VALUE "Clear".
    05 FILLER PIC X(80) VALUE "weather.cobolcraft.drizzle".
    05 FILLER PIC X(128) VALUE "Drizzle".
    05 FILLER PIC X(80) VALUE "weather.cobolcraft.hailstorm".
    05 FILLER PIC X(128) VALUE "Hailstorm".
    05 FILLER PIC X(80) VALUE "dimension.cobolcraft.main".
    05 FILLER PIC X(128) VALUE "Main".
    05 FILLER PIC X(80) VALUE "dimension.cobolcraft.subroutine".
    05 FILLER PIC X(128) VALUE "Subroutine".
    05 FILLER PIC X(80) VALUE "cobolcraft.gamemode.survival".
    05 FILLER PIC X(128) VALUE "Survival".
    05 FILLER PIC X(80) VALUE "cobolcraft.gamemode.creative".
    05 FILLER PIC X(128) VALUE "Creative".
    05 FILLER PIC X(80) VALUE "cobolcraft.death.fall".
    05 FILLER PIC X(128) VALUE "%s misjudged the drop".
    05 FILLER PIC X(80) VALUE "cobolcraft.death.mob.abend".
    05 FILLER PIC X(128) VALUE "%s was halted by an Abend".
    05 FILLER PIC X(80) VALUE "cobolcraft.death.player".
    05 FILLER PIC X(128) VALUE "%s lost a duel with %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.death.starvation".
    05 FILLER PIC X(128) VALUE "%s ran out of rations".
    05 FILLER PIC X(80) VALUE "cobolcraft.death.hail".
    05 FILLER PIC X(128) VALUE "%s was battered by hail".
    05 FILLER PIC X(80) VALUE "cobolcraft.death.command".
    05 FILLER PIC X(128) VALUE "%s had their vitality set to zero".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.death.title".
    05 FILLER PIC X(128) VALUE "Run Terminated".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.death.respawn".
    05 FILLER PIC X(128) VALUE "Return to Spawn".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.unknown".
    05 FILLER PIC X(128) VALUE "Unknown command %s (howto lists the commands)".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.not_permitted".
    05 FILLER PIC X(128) VALUE "You may not use %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.missing_argument".
    05 FILLER PIC X(128) VALUE "Missing argument. Usage: %s (see howto)".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.invalid_argument".
    05 FILLER PIC X(128) VALUE "Invalid argument %s. Usage: %s (see howto)".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.invalid_name".
    05 FILLER PIC X(128) VALUE "%s is not a valid player name".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.player_not_found".
    05 FILLER PIC X(128) VALUE "No player named %s is online".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.dimension_not_found".
    05 FILLER PIC X(128) VALUE "No dimension is named %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.item_not_found".
    05 FILLER PIC X(128) VALUE "No item is named %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.mob_not_found".
    05 FILLER PIC X(128) VALUE "No mob is named %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.not_survival".
    05 FILLER PIC X(128) VALUE "%s is not in survival mode".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.not_alive".
    05 FILLER PIC X(128) VALUE "%s is dead and has not respawned yet".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.is_host".
    05 FILLER PIC X(128) VALUE "%s is the host of this world".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.promote.notice".
    05 FILLER PIC X(128) VALUE "You now hold operator status".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.demote.notice".
    05 FILLER PIC X(128) VALUE "You no longer hold operator status".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.howto.header".
    05 FILLER PIC X(128) VALUE "Commands you may use (%s):".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.howto.entry".
    05 FILLER PIC X(128) VALUE "- %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.roster".
    05 FILLER PIC X(128) VALUE "Online (%s): %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.murmur.incoming".
    05 FILLER PIC X(128) VALUE "%s murmurs to you: %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.murmur.incoming_console".
    05 FILLER PIC X(128) VALUE "The server murmurs to you: %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.murmur.sent".
    05 FILLER PIC X(128) VALUE "You murmur to %s: %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.promote.done".
    05 FILLER PIC X(128) VALUE "%s now holds operator status".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.promote.already".
    05 FILLER PIC X(128) VALUE "%s already holds operator status".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.demote.done".
    05 FILLER PIC X(128) VALUE "%s no longer holds operator status".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.demote.not_operator".
    05 FILLER PIC X(128) VALUE "%s does not hold operator status".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.eject.done".
    05 FILLER PIC X(128) VALUE "Ejected %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.bar.done".
    05 FILLER PIC X(128) VALUE "Barred %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.bar.already".
    05 FILLER PIC X(128) VALUE "%s is already barred".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.unbar.done".
    05 FILLER PIC X(128) VALUE "Lifted the bar on %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.unbar.not_barred".
    05 FILLER PIC X(128) VALUE "%s is not barred".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.barlist".
    05 FILLER PIC X(128) VALUE "Barred (%s): %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.guestlist.on".
    05 FILLER PIC X(128) VALUE "The guest list is now enforced".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.guestlist.off".
    05 FILLER PIC X(128) VALUE "The guest list is no longer enforced".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.guestlist.added".
    05 FILLER PIC X(128) VALUE "Added %s to the guest list".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.guestlist.already".
    05 FILLER PIC X(128) VALUE "%s is already on the guest list".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.guestlist.removed".
    05 FILLER PIC X(128) VALUE "Removed %s from the guest list".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.guestlist.not_listed".
    05 FILLER PIC X(128) VALUE "%s is not on the guest list".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.guestlist.show".
    05 FILLER PIC X(128) VALUE "Guest list enforcement %s; guests (%s): %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.mode.done".
    05 FILLER PIC X(128) VALUE "%s now plays in %s mode".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.relocate.position".
    05 FILLER PIC X(128) VALUE "Relocated %s to %s, %s, %s in %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.relocate.player".
    05 FILLER PIC X(128) VALUE "Relocated %s to %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.supply.done".
    05 FILLER PIC X(128) VALUE "Supplied %s %s to %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.supply.no_room".
    05 FILLER PIC X(128) VALUE "%s has no room for that".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.empty.done".
    05 FILLER PIC X(128) VALUE "Emptied the inventory of %s (%s items removed)".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.vitality.done".
    05 FILLER PIC X(128) VALUE "Set the health of %s to %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.ration.done".
    05 FILLER PIC X(128) VALUE "Set the food level of %s to %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.conjure.done".
    05 FILLER PIC X(128) VALUE "Conjured a %s at %s, %s, %s in %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.conjure.hostile_disabled".
    05 FILLER PIC X(128) VALUE "Hostile mobs are switched off, so no %s can be conjured".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.sweep.done".
    05 FILLER PIC X(128) VALUE "Swept away %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.sweep.unknown_target".
    05 FILLER PIC X(128) VALUE "Nothing to sweep is named %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.clock.done".
    05 FILLER PIC X(128) VALUE "The clock now reads %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.skies.timed".
    05 FILLER PIC X(128) VALUE "The skies over %s turn to %s for %s seconds".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.skies.held".
    05 FILLER PIC X(128) VALUE "The skies over %s turn to %s until changed".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.skies.no_weather".
    05 FILLER PIC X(128) VALUE "%s has no skies to change".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.homestead.done".
    05 FILLER PIC X(128) VALUE "The world spawn point is now %s, %s, %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.announce.message".
    05 FILLER PIC X(128) VALUE "[Server] %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.announce.done".
    05 FILLER PIC X(128) VALUE "Announcement sent".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.persist.done".
    05 FILLER PIC X(128) VALUE "The world has been saved".
    05 FILLER PIC X(80) VALUE "cobolcraft.command.shutdown.done".
    05 FILLER PIC X(128) VALUE "Shutting down".
    05 FILLER PIC X(80) VALUE "cobolcraft.disconnect.barred".
    05 FILLER PIC X(128) VALUE "You are barred from this world".
    05 FILLER PIC X(80) VALUE "cobolcraft.disconnect.not_on_guestlist".
    05 FILLER PIC X(128) VALUE "You are not on this world's guest list".
    05 FILLER PIC X(80) VALUE "cobolcraft.disconnect.name_is_host".
    05 FILLER PIC X(128) VALUE "The name %s belongs to the host of this world".
    05 FILLER PIC X(80) VALUE "cobolcraft.disconnect.replaced".
    05 FILLER PIC X(128) VALUE "Someone joined elsewhere under your name".
    05 FILLER PIC X(80) VALUE "cobolcraft.disconnect.shutdown".
    05 FILLER PIC X(128) VALUE "The server is shutting down".
    05 FILLER PIC X(80) VALUE "cobolcraft.disconnect.host_closed".
    05 FILLER PIC X(128) VALUE "The host closed the world".
    05 FILLER PIC X(80) VALUE "cobolcraft.disconnect.pack_required".
    05 FILLER PIC X(128) VALUE "This server requires its resource pack".
    05 FILLER PIC X(80) VALUE "cobolcraft.disconnect.ejected".
    05 FILLER PIC X(128) VALUE "You were ejected: %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.disconnect.ejected_plain".
    05 FILLER PIC X(128) VALUE "You were ejected by an operator".
    05 FILLER PIC X(80) VALUE "multiplayer.disconnect.incompatible".
    05 FILLER PIC X(128) VALUE "This server runs %s and cannot talk to your game version".
    05 FILLER PIC X(80) VALUE "multiplayer.disconnect.outdated_client".
    05 FILLER PIC X(128) VALUE "Your game version is too old for this server (%s)".
    05 FILLER PIC X(80) VALUE "multiplayer.disconnect.transfers_disabled".
    05 FILLER PIC X(128) VALUE "This server does not take transferred players".
    05 FILLER PIC X(80) VALUE "multiplayer.disconnect.slow_login".
    05 FILLER PIC X(128) VALUE "Logging in took too long".
    05 FILLER PIC X(80) VALUE "multiplayer.disconnect.unexpected_query_response".
    05 FILLER PIC X(128) VALUE "The server got a reply it never asked for".
    05 FILLER PIC X(80) VALUE "multiplayer.disconnect.invalid_player_movement".
    05 FILLER PIC X(128) VALUE "The server refused an impossible position".
    05 FILLER PIC X(80) VALUE "disconnect.timeout".
    05 FILLER PIC X(128) VALUE "No reply arrived in time".
    05 FILLER PIC X(80) VALUE "cobolcraft.chat.say".
    05 FILLER PIC X(128) VALUE "<%s> %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.chat.say.narrate".
    05 FILLER PIC X(128) VALUE "%s says %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.common.done".
    05 FILLER PIC X(128) VALUE "Done".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.common.cancel".
    05 FILLER PIC X(128) VALUE "Cancel".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.common.back".
    05 FILLER PIC X(128) VALUE "Back".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.common.yes".
    05 FILLER PIC X(128) VALUE "Yes".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.common.no".
    05 FILLER PIC X(128) VALUE "No".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.title.name".
    05 FILLER PIC X(128) VALUE "CobolCraft".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.title.single_player".
    05 FILLER PIC X(128) VALUE "Single-player".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.title.multiplayer".
    05 FILLER PIC X(128) VALUE "Multiplayer".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.title.packs".
    05 FILLER PIC X(128) VALUE "Resource Packs".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.title.quit".
    05 FILLER PIC X(128) VALUE "Quit Game".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.server_list.title".
    05 FILLER PIC X(128) VALUE "Servers".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.server_list.join".
    05 FILLER PIC X(128) VALUE "Join".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.server_list.add".
    05 FILLER PIC X(128) VALUE "Add Server".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.server_list.edit".
    05 FILLER PIC X(128) VALUE "Edit".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.server_list.remove".
    05 FILLER PIC X(128) VALUE "Remove".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.server_list.empty".
    05 FILLER PIC X(128) VALUE "No servers yet".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.server_list.pinging".
    05 FILLER PIC X(128) VALUE "Asking the server...".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.server_list.online".
    05 FILLER PIC X(128) VALUE "%s of %s online".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.server_list.unreachable".
    05 FILLER PIC X(128) VALUE "No answer from the server".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.server_list.incompatible".
    05 FILLER PIC X(128) VALUE "Incompatible version: %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.server_list.disconnected".
    05 FILLER PIC X(128) VALUE "Disconnected: %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.edit_server.title_add".
    05 FILLER PIC X(128) VALUE "Add Server".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.edit_server.title_edit".
    05 FILLER PIC X(128) VALUE "Edit Server".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.edit_server.name".
    05 FILLER PIC X(128) VALUE "Server name".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.edit_server.address".
    05 FILLER PIC X(128) VALUE "Address".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.edit_server.pack_policy".
    05 FILLER PIC X(128) VALUE "Server packs: %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.pack_policy.prompt".
    05 FILLER PIC X(128) VALUE "Ask each time".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.pack_policy.enabled".
    05 FILLER PIC X(128) VALUE "Always accept".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.pack_policy.disabled".
    05 FILLER PIC X(128) VALUE "Never accept".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.connecting.title".
    05 FILLER PIC X(128) VALUE "Connecting to %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.connecting.joining".
    05 FILLER PIC X(128) VALUE "Joining the world".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.connecting.loading".
    05 FILLER PIC X(128) VALUE "Loading terrain...".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.connecting.failed".
    05 FILLER PIC X(128) VALUE "Could not connect to %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.connecting.lost".
    05 FILLER PIC X(128) VALUE "The connection was lost".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.connecting.timed_out".
    05 FILLER PIC X(128) VALUE "The server stopped answering".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.inventory.title".
    05 FILLER PIC X(128) VALUE "Inventory".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.crafting.title".
    05 FILLER PIC X(128) VALUE "Crafting".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.crafting.craftable".
    05 FILLER PIC X(128) VALUE "Ready to craft".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.crafting.not_craftable".
    05 FILLER PIC X(128) VALUE "Missing ingredients".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.crafting.ingredient".
    05 FILLER PIC X(128) VALUE "%s x %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.crafting.result".
    05 FILLER PIC X(128) VALUE "Makes %s x %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.crafting.craft".
    05 FILLER PIC X(128) VALUE "Craft".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.chat.hint".
    05 FILLER PIC X(128) VALUE "Type a message, or / for a command".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.pause.title".
    05 FILLER PIC X(128) VALUE "Game Menu".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.pause.paused".
    05 FILLER PIC X(128) VALUE "Paused".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.pause.resume".
    05 FILLER PIC X(128) VALUE "Back to the World".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.pause.open_to_others".
    05 FILLER PIC X(128) VALUE "Open to Others".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.pause.disconnect".
    05 FILLER PIC X(128) VALUE "Disconnect".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.pause.quit_world".
    05 FILLER PIC X(128) VALUE "Save and Leave the World".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.packs.title".
    05 FILLER PIC X(128) VALUE "Resource Packs".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.packs.available".
    05 FILLER PIC X(128) VALUE "Available".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.packs.selected".
    05 FILLER PIC X(128) VALUE "Selected".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.packs.enable".
    05 FILLER PIC X(128) VALUE "Enable".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.packs.disable".
    05 FILLER PIC X(128) VALUE "Disable".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.packs.move_up".
    05 FILLER PIC X(128) VALUE "Move Up".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.packs.move_down".
    05 FILLER PIC X(128) VALUE "Move Down".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.packs.builtin".
    05 FILLER PIC X(128) VALUE "Built-in pack".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.packs.compatible".
    05 FILLER PIC X(128) VALUE "Compatible".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.packs.too_old".
    05 FILLER PIC X(128) VALUE "Made for an older version".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.packs.too_new".
    05 FILLER PIC X(128) VALUE "Made for a newer version".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.packs.unknown".
    05 FILLER PIC X(128) VALUE "Version unknown".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.packs.error".
    05 FILLER PIC X(128) VALUE "%s cannot be used: %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.packs.problem.unreadable".
    05 FILLER PIC X(128) VALUE "the pack cannot be read".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.packs.problem.no_metadata".
    05 FILLER PIC X(128) VALUE "pack.mcmeta is missing".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.packs.problem.bad_metadata".
    05 FILLER PIC X(128) VALUE "pack.mcmeta has no usable pack section".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.packs.problem.bad_file".
    05 FILLER PIC X(128) VALUE "%s cannot be read".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.packs.problem.missing".
    05 FILLER PIC X(128) VALUE "the pack is missing".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.pack_confirm.title".
    05 FILLER PIC X(128) VALUE "Enable This Pack?".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.pack_confirm.too_old".
    05 FILLER PIC X(128) VALUE "%s was made for an older version and may look wrong".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.pack_confirm.too_new".
    05 FILLER PIC X(128) VALUE "%s was made for a newer version and may look wrong".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.pack_confirm.unknown".
    05 FILLER PIC X(128) VALUE "The version of %s is unknown and it may look wrong".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.pack_confirm.enable".
    05 FILLER PIC X(128) VALUE "Enable Anyway".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.pack_prompt.title".
    05 FILLER PIC X(128) VALUE "Server Resource Pack".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.pack_prompt.optional".
    05 FILLER PIC X(128) VALUE "This server offers a resource pack".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.pack_prompt.required".
    05 FILLER PIC X(128) VALUE "This server requires a resource pack; declining disconnects you".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.pack_prompt.message".
    05 FILLER PIC X(128) VALUE "The server says: %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.pack_prompt.accept".
    05 FILLER PIC X(128) VALUE "Accept".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.pack_prompt.decline".
    05 FILLER PIC X(128) VALUE "Decline".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.pack_prompt.remembered".
    05 FILLER PIC X(128) VALUE "Your answer is kept for this server".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.pack_prompt.downloading".
    05 FILLER PIC X(128) VALUE "Fetching the server pack...".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.world_list.title".
    05 FILLER PIC X(128) VALUE "Single-player Worlds".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.world_list.entry".
    05 FILLER PIC X(128) VALUE "%s (%s)".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.world_list.play".
    05 FILLER PIC X(128) VALUE "Play".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.world_list.create".
    05 FILLER PIC X(128) VALUE "Create New World".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.world_list.delete".
    05 FILLER PIC X(128) VALUE "Delete".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.world_list.empty".
    05 FILLER PIC X(128) VALUE "No worlds yet".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.create_world.title".
    05 FILLER PIC X(128) VALUE "Create New World".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.create_world.name".
    05 FILLER PIC X(128) VALUE "World name".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.create_world.default_name".
    05 FILLER PIC X(128) VALUE "New World".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.create_world.mode".
    05 FILLER PIC X(128) VALUE "Game mode: %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.create_world.create".
    05 FILLER PIC X(128) VALUE "Create".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.confirm_delete.title".
    05 FILLER PIC X(128) VALUE "Delete This World?".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.confirm_delete.text".
    05 FILLER PIC X(128) VALUE "%s will be deleted for good".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.confirm_delete.delete".
    05 FILLER PIC X(128) VALUE "Delete".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.open_to_others.title".
    05 FILLER PIC X(128) VALUE "Open to Others".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.open_to_others.mode".
    05 FILLER PIC X(128) VALUE "Guest game mode: %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.open_to_others.operators".
    05 FILLER PIC X(128) VALUE "Guests may use operator commands: %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.open_to_others.start".
    05 FILLER PIC X(128) VALUE "Open the World".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.open_to_others.address".
    05 FILLER PIC X(128) VALUE "Others can join at %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.hud.health".
    05 FILLER PIC X(128) VALUE "Health %s/%s".
    05 FILLER PIC X(80) VALUE "cobolcraft.hud.food".
    05 FILLER PIC X(128) VALUE "Food %s/%s".
    05 FILLER PIC X(80) VALUE "cobolcraft.hud.crosshair".
    05 FILLER PIC X(128) VALUE "+".
    05 FILLER PIC X(80) VALUE "cobolcraft.packs.absent".
    05 FILLER PIC X(128) VALUE "Minecraft content is not set up. Run the extraction tool with your "
        & "Minecraft 26.3 client jar to play standard worlds.".
    05 FILLER PIC X(80) VALUE "cobolcraft.packs.incomplete".
    05 FILLER PIC X(128) VALUE "The Minecraft content is incomplete. Run the extraction tool again.".
    05 FILLER PIC X(80) VALUE "cobolcraft.packs.stale".
    05 FILLER PIC X(128) VALUE "The Minecraft content was made for another version. Run the "
        & "extraction tool again.".
    05 FILLER PIC X(80) VALUE "cobolcraft.packs.damaged".
    05 FILLER PIC X(128) VALUE "The Minecraft content is damaged. Run the extraction tool with --force.".
    05 FILLER PIC X(80) VALUE "cobolcraft.world_type.standard".
    05 FILLER PIC X(128) VALUE "Standard".
    05 FILLER PIC X(80) VALUE "cobolcraft.world_type.cobolcraft".
    05 FILLER PIC X(128) VALUE "CobolCraft".
    05 FILLER PIC X(80) VALUE "cobolcraft.world_type.standard.unavailable".
    05 FILLER PIC X(128) VALUE "Standard worlds need the Minecraft content. See the title screen message.".
    05 FILLER PIC X(80) VALUE "cobolcraft.world_type.refused".
    05 FILLER PIC X(128) VALUE "This world cannot be opened: it has no world type, or its files are incomplete.".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.create_world.type".
    05 FILLER PIC X(128) VALUE "World type: %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.world_list.type".
    05 FILLER PIC X(128) VALUE "Type: %s".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.packs.open_folder".
    05 FILLER PIC X(128) VALUE "Open Pack Folder".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.packs.open_failed".
    05 FILLER PIC X(128) VALUE "Cannot start %s to open the pack folder".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.title.options".
    05 FILLER PIC X(128) VALUE "Options".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.pause.options".
    05 FILLER PIC X(128) VALUE "Options".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.options.title".
    05 FILLER PIC X(128) VALUE "Options".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.options.previous".
    05 FILLER PIC X(128) VALUE "Previous Page".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.options.next".
    05 FILLER PIC X(128) VALUE "Next Page".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.options.page".
    05 FILLER PIC X(128) VALUE "Options (page %s of %s)".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.options.press_key".
    05 FILLER PIC X(128) VALUE "> Press a key <".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.common.search_hint".
    05 FILLER PIC X(128) VALUE "Search...".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.recipe_book.filter_on".
    05 FILLER PIC X(128) VALUE "Showing Craftable".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.recipe_book.filter_off".
    05 FILLER PIC X(128) VALUE "Showing All".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.recipe_book.more".
    05 FILLER PIC X(128) VALUE "Right Click for More".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.recipe_book.page".
    05 FILLER PIC X(128) VALUE "%s/%s".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.recipe_book.tab.search".
    05 FILLER PIC X(128) VALUE "Search".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.recipe_book.tab.equipment".
    05 FILLER PIC X(128) VALUE "Equipment".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.recipe_book.tab.building".
    05 FILLER PIC X(128) VALUE "Building Blocks".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.recipe_book.tab.misc".
    05 FILLER PIC X(128) VALUE "Misc".
    05 FILLER PIC X(80) VALUE "cobolcraft.screen.recipe_book.tab.redstone".
    05 FILLER PIC X(128) VALUE "Redstone".
    05 FILLER PIC X(80) VALUE "recipe.toast.title".
    05 FILLER PIC X(128) VALUE "New Recipe(s) Unlocked!".
    05 FILLER PIC X(80) VALUE "recipe.toast.description".
    05 FILLER PIC X(128) VALUE "Check your recipe book".
    05 FILLER PIC X(80) VALUE "container.repair.cost".
    05 FILLER PIC X(128) VALUE "Enchantment Cost: %1$s".
    05 FILLER PIC X(80) VALUE "container.repair.expensive".
    05 FILLER PIC X(128) VALUE "Too Expensive!".
    05 FILLER PIC X(80) VALUE "container.upgrade".
    05 FILLER PIC X(128) VALUE "Upgrade Gear".
    05 FILLER PIC X(80) VALUE "container.upgrade.error_tooltip".
    05 FILLER PIC X(128) VALUE "Item can't be upgraded this way".
    05 FILLER PIC X(80) VALUE "container.upgrade.missing_template_tooltip".
    05 FILLER PIC X(128) VALUE "Add Smithing Template".
    05 FILLER PIC X(80) VALUE "container.inventory".
    05 FILLER PIC X(128) VALUE "Inventory".
    05 FILLER PIC X(80) VALUE "gui.done".
    05 FILLER PIC X(128) VALUE "Done".
    05 FILLER PIC X(80) VALUE "gui.cancel".
    05 FILLER PIC X(128) VALUE "Cancel".
    05 FILLER PIC X(80) VALUE "merchant.trades".
    05 FILLER PIC X(128) VALUE "Trades".
    05 FILLER PIC X(80) VALUE "merchant.title".
    05 FILLER PIC X(128) VALUE "%s - %s".
    05 FILLER PIC X(80) VALUE "merchant.level.1".
    05 FILLER PIC X(128) VALUE "Novice".
    05 FILLER PIC X(80) VALUE "merchant.level.2".
    05 FILLER PIC X(128) VALUE "Apprentice".
    05 FILLER PIC X(80) VALUE "merchant.level.3".
    05 FILLER PIC X(128) VALUE "Journeyman".
    05 FILLER PIC X(80) VALUE "merchant.level.4".
    05 FILLER PIC X(128) VALUE "Expert".
    05 FILLER PIC X(80) VALUE "merchant.level.5".
    05 FILLER PIC X(128) VALUE "Master".
    05 FILLER PIC X(80) VALUE "merchant.deprecated".
    05 FILLER PIC X(128) VALUE "Villagers restock up to two times per day.".
    05 FILLER PIC X(80) VALUE "lectern.take_book".
    05 FILLER PIC X(128) VALUE "Take Book".
    05 FILLER PIC X(80) VALUE "book.pageIndicator".
    05 FILLER PIC X(128) VALUE "Page %1$s of %2$s".
    05 FILLER PIC X(80) VALUE "block.minecraft.beacon.primary".
    05 FILLER PIC X(128) VALUE "Primary Power".
    05 FILLER PIC X(80) VALUE "block.minecraft.beacon.secondary".
    05 FILLER PIC X(128) VALUE "Secondary Power".
*>   The keys of the screens of docs/protocol/40-menus-7 (the tab titles) and 40-menus-8 (the sign and book editors).
    05 FILLER PIC X(80) VALUE "sign.edit".
    05 FILLER PIC X(128) VALUE "Edit Sign Message".
    05 FILLER PIC X(80) VALUE "book.signButton".
    05 FILLER PIC X(128) VALUE "Sign".
    05 FILLER PIC X(80) VALUE "book.finalizeButton".
    05 FILLER PIC X(128) VALUE "Sign and Close".
    05 FILLER PIC X(80) VALUE "book.editTitle".
    05 FILLER PIC X(128) VALUE "Enter Book Title:".
    05 FILLER PIC X(80) VALUE "book.byAuthor".
    05 FILLER PIC X(128) VALUE "by %1$s".
    05 FILLER PIC X(80) VALUE "book.finalizeWarning".
    05 FILLER PIC X(128) VALUE "Note! When you sign the book, it will no longer be editable.".
    05 FILLER PIC X(80) VALUE "itemGroup.buildingBlocks".
    05 FILLER PIC X(128) VALUE "Building Blocks".
    05 FILLER PIC X(80) VALUE "itemGroup.coloredBlocks".
    05 FILLER PIC X(128) VALUE "Colored Blocks".
    05 FILLER PIC X(80) VALUE "itemGroup.natural".
    05 FILLER PIC X(128) VALUE "Natural Blocks".
    05 FILLER PIC X(80) VALUE "itemGroup.functional".
    05 FILLER PIC X(128) VALUE "Functional Blocks".
    05 FILLER PIC X(80) VALUE "itemGroup.redstone".
    05 FILLER PIC X(128) VALUE "Redstone Blocks".
    05 FILLER PIC X(80) VALUE "itemGroup.hotbar".
    05 FILLER PIC X(128) VALUE "Saved Hotbars".
    05 FILLER PIC X(80) VALUE "itemGroup.search".
    05 FILLER PIC X(128) VALUE "Search Items".
    05 FILLER PIC X(80) VALUE "itemGroup.tools".
    05 FILLER PIC X(128) VALUE "Tools & Utilities".
    05 FILLER PIC X(80) VALUE "itemGroup.combat".
    05 FILLER PIC X(128) VALUE "Combat".
    05 FILLER PIC X(80) VALUE "itemGroup.foodAndDrink".
    05 FILLER PIC X(128) VALUE "Food & Drinks".
    05 FILLER PIC X(80) VALUE "itemGroup.ingredients".
    05 FILLER PIC X(128) VALUE "Ingredients".
    05 FILLER PIC X(80) VALUE "itemGroup.spawnEggs".
    05 FILLER PIC X(128) VALUE "Spawn Eggs".
    05 FILLER PIC X(80) VALUE "itemGroup.op".
    05 FILLER PIC X(128) VALUE "Operator Utilities".
    05 FILLER PIC X(80) VALUE "itemGroup.inventory".
    05 FILLER PIC X(128) VALUE "Survival Inventory".
*>   The keys of the command block screen of docs/protocol/40-menus-9.
    05 FILLER PIC X(80) VALUE "advMode.setCommand".
    05 FILLER PIC X(128) VALUE "Set Console Command for Block".
    05 FILLER PIC X(80) VALUE "advMode.command".
    05 FILLER PIC X(128) VALUE "Console Command".
    05 FILLER PIC X(80) VALUE "advMode.previousOutput".
    05 FILLER PIC X(128) VALUE "Previous Output".
    05 FILLER PIC X(80) VALUE "advMode.mode.sequence".
    05 FILLER PIC X(128) VALUE "Chain".
    05 FILLER PIC X(80) VALUE "advMode.mode.auto".
    05 FILLER PIC X(128) VALUE "Repeat".
    05 FILLER PIC X(80) VALUE "advMode.mode.redstone".
    05 FILLER PIC X(128) VALUE "Impulse".
    05 FILLER PIC X(80) VALUE "advMode.mode.conditional".
    05 FILLER PIC X(128) VALUE "Conditional".
    05 FILLER PIC X(80) VALUE "advMode.mode.unconditional".
    05 FILLER PIC X(128) VALUE "Unconditional".
    05 FILLER PIC X(80) VALUE "advMode.mode.autoexec.bat".
    05 FILLER PIC X(128) VALUE "Always Active".
    05 FILLER PIC X(80) VALUE "advMode.mode.redstoneTriggered".
    05 FILLER PIC X(128) VALUE "Needs Redstone".
*>   The smithing table tooltips of docs/protocol/40-menus-3 section 5.7.
    05 FILLER PIC X(80) VALUE "item.minecraft.smithing_template.armor_trim.base_slot_description".
    05 FILLER PIC X(128) VALUE "Add a piece of armor".
    05 FILLER PIC X(80) VALUE "item.minecraft.smithing_template.armor_trim.additions_slot_description".
    05 FILLER PIC X(128) VALUE "Add ingot or crystal".
    05 FILLER PIC X(80) VALUE "item.minecraft.smithing_template.netherite_upgrade.base_slot_description".
    05 FILLER PIC X(128) VALUE "Add diamond armor, weapon, or tool".
    05 FILLER PIC X(80) VALUE "item.minecraft.smithing_template.netherite_upgrade.additions_slot_description".
    05 FILLER PIC X(128) VALUE "Add Netherite Ingot".
*>   The keys of the test block and jigsaw screens of docs/protocol/40-menus-x1 sections 6 and 7.
    05 FILLER PIC X(80) VALUE "block.minecraft.test_block".
    05 FILLER PIC X(128) VALUE "Test Block".
    05 FILLER PIC X(80) VALUE "test_block.mode.start".
    05 FILLER PIC X(128) VALUE "Start".
    05 FILLER PIC X(80) VALUE "test_block.mode.log".
    05 FILLER PIC X(128) VALUE "Log".
    05 FILLER PIC X(80) VALUE "test_block.mode.fail".
    05 FILLER PIC X(128) VALUE "Fail".
    05 FILLER PIC X(80) VALUE "test_block.mode.accept".
    05 FILLER PIC X(128) VALUE "Accept".
    05 FILLER PIC X(80) VALUE "test_block.message".
    05 FILLER PIC X(128) VALUE "Message:".
    05 FILLER PIC X(80) VALUE "test_block.mode_info.start".
    05 FILLER PIC X(128) VALUE "Start Mode - The starting point for a test".
    05 FILLER PIC X(80) VALUE "test_block.mode_info.log".
    05 FILLER PIC X(128) VALUE "Log Mode - Log a message".
    05 FILLER PIC X(80) VALUE "test_block.mode_info.fail".
    05 FILLER PIC X(128) VALUE "Fail Mode - Fail the test".
    05 FILLER PIC X(80) VALUE "test_block.mode_info.accept".
    05 FILLER PIC X(128) VALUE "Accept Mode - Accept success for (part of) a test".
    05 FILLER PIC X(80) VALUE "jigsaw_block.pool".
    05 FILLER PIC X(128) VALUE "Target Pool:".
    05 FILLER PIC X(80) VALUE "jigsaw_block.name".
    05 FILLER PIC X(128) VALUE "Name:".
    05 FILLER PIC X(80) VALUE "jigsaw_block.target".
    05 FILLER PIC X(128) VALUE "Target Name:".
    05 FILLER PIC X(80) VALUE "jigsaw_block.final_state".
    05 FILLER PIC X(128) VALUE "Turns into:".
    05 FILLER PIC X(80) VALUE "jigsaw_block.selection_priority".
    05 FILLER PIC X(128) VALUE "Selection Priority:".
    05 FILLER PIC X(80) VALUE "jigsaw_block.placement_priority".
    05 FILLER PIC X(128) VALUE "Placement Priority:".
    05 FILLER PIC X(80) VALUE "jigsaw_block.joint_label".
    05 FILLER PIC X(128) VALUE "Joint Type:".
    05 FILLER PIC X(80) VALUE "jigsaw_block.joint.rollable".
    05 FILLER PIC X(128) VALUE "Rollable".
    05 FILLER PIC X(80) VALUE "jigsaw_block.joint.aligned".
    05 FILLER PIC X(128) VALUE "Aligned".
    05 FILLER PIC X(80) VALUE "jigsaw_block.levels".
    05 FILLER PIC X(128) VALUE "Levels: %s".
    05 FILLER PIC X(80) VALUE "jigsaw_block.keep_jigsaws".
    05 FILLER PIC X(128) VALUE "Keep Jigsaws".
    05 FILLER PIC X(80) VALUE "jigsaw_block.generate".
    05 FILLER PIC X(128) VALUE "Generate".
    05 FILLER PIC X(80) VALUE "options.on".
    05 FILLER PIC X(128) VALUE "ON".
    05 FILLER PIC X(80) VALUE "options.off".
    05 FILLER PIC X(128) VALUE "OFF".
*>   The keys of the structure block screen of docs/protocol/40-menus-x1 section 5.
    05 FILLER PIC X(80) VALUE "block.minecraft.structure_block".
    05 FILLER PIC X(128) VALUE "Structure Block".
    05 FILLER PIC X(80) VALUE "structure_block.mode.save".
    05 FILLER PIC X(128) VALUE "Save".
    05 FILLER PIC X(80) VALUE "structure_block.mode.load".
    05 FILLER PIC X(128) VALUE "Load".
    05 FILLER PIC X(80) VALUE "structure_block.mode.corner".
    05 FILLER PIC X(128) VALUE "Corner".
    05 FILLER PIC X(80) VALUE "structure_block.mode.data".
    05 FILLER PIC X(128) VALUE "Data".
    05 FILLER PIC X(80) VALUE "structure_block.button.save".
    05 FILLER PIC X(128) VALUE "SAVE".
    05 FILLER PIC X(80) VALUE "structure_block.button.load".
    05 FILLER PIC X(128) VALUE "LOAD".
    05 FILLER PIC X(80) VALUE "structure_block.button.detect_size".
    05 FILLER PIC X(128) VALUE "DETECT".
    05 FILLER PIC X(80) VALUE "structure_block.structure_name".
    05 FILLER PIC X(128) VALUE "Structure Name".
    05 FILLER PIC X(80) VALUE "structure_block.position".
    05 FILLER PIC X(128) VALUE "Relative Position".
    05 FILLER PIC X(80) VALUE "structure_block.include_entities".
    05 FILLER PIC X(128) VALUE "Include Entities:".
    05 FILLER PIC X(80) VALUE "structure_block.size".
    05 FILLER PIC X(128) VALUE "Structure Size".
    05 FILLER PIC X(80) VALUE "structure_block.detect_size".
    05 FILLER PIC X(128) VALUE "Detect Structure Size and Position:".
    05 FILLER PIC X(80) VALUE "structure_block.show_air".
    05 FILLER PIC X(128) VALUE "Show Invisible Blocks:".
    05 FILLER PIC X(80) VALUE "structure_block.integrity".
    05 FILLER PIC X(128) VALUE "Structure Integrity and Seed".
    05 FILLER PIC X(80) VALUE "structure_block.strict".
    05 FILLER PIC X(128) VALUE "Strict Placement:".
    05 FILLER PIC X(80) VALUE "structure_block.show_boundingbox".
    05 FILLER PIC X(128) VALUE "Show Bounding Box:".
    05 FILLER PIC X(80) VALUE "structure_block.custom_data".
    05 FILLER PIC X(128) VALUE "Custom Data Tag Name".
    05 FILLER PIC X(80) VALUE "structure_block.mode_info.save".
    05 FILLER PIC X(128) VALUE "Save Mode - Write to file".
    05 FILLER PIC X(80) VALUE "structure_block.mode_info.load".
    05 FILLER PIC X(128) VALUE "Load Mode - Load from file".
    05 FILLER PIC X(80) VALUE "structure_block.mode_info.corner".
    05 FILLER PIC X(128) VALUE "Corner Mode - Placement and size marker".
    05 FILLER PIC X(80) VALUE "structure_block.mode_info.data".
    05 FILLER PIC X(128) VALUE "Data Mode - Game logic marker".
    05 FILLER PIC X(80) VALUE "mirror.none".
    05 FILLER PIC X(128) VALUE "|".
    05 FILLER PIC X(80) VALUE "mirror.left_right".
    05 FILLER PIC X(128) VALUE "← →".
    05 FILLER PIC X(80) VALUE "mirror.front_back".
    05 FILLER PIC X(128) VALUE "↑ ↓".
*>   The keys of the test instance screen of docs/protocol/40-menus-x1 section 8.
    05 FILLER PIC X(80) VALUE "block.minecraft.test_instance_block".
    05 FILLER PIC X(128) VALUE "Test Instance Block".
    05 FILLER PIC X(80) VALUE "test_instance.action.reset".
    05 FILLER PIC X(128) VALUE "Reset and Load".
    05 FILLER PIC X(80) VALUE "test_instance.action.save".
    05 FILLER PIC X(128) VALUE "Save Structure".
    05 FILLER PIC X(80) VALUE "test_instance.action.run".
    05 FILLER PIC X(128) VALUE "Load and Run".
    05 FILLER PIC X(80) VALUE "test_instance_block.test_id".
    05 FILLER PIC X(128) VALUE "Test Instance ID".
    05 FILLER PIC X(80) VALUE "test_instance_block.size".
    05 FILLER PIC X(128) VALUE "Test Structure Size".
    05 FILLER PIC X(80) VALUE "test_instance_block.rotation".
    05 FILLER PIC X(128) VALUE "Rotation:".
    05 FILLER PIC X(80) VALUE "test_instance_block.entities".
    05 FILLER PIC X(128) VALUE "Entities:".
    05 FILLER PIC X(80) VALUE "test_instance.description.invalid_id".
    05 FILLER PIC X(128) VALUE "Invalid test ID".
    05 FILLER PIC X(80) VALUE "test_instance.description.failed".
    05 FILLER PIC X(128) VALUE "Failed: %s".
 01 BI-LANG-TABLE REDEFINES BI-LANG-DATA.
    05 BI-LANG OCCURS 356 TIMES.
       10 BI-LANG-KEY        PIC X(80).
       10 BI-LANG-TEXT       PIC X(128).
