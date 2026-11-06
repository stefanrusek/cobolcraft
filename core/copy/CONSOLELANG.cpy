*> The en_us text of every translation key the core sends (docs/protocol/08-resource-packs.md
*> §10.8.2 death messages, §10.8.3 command messages, §10.8.4 disconnect and refusal reasons),
*> transcribed; used only to render the console lines of server-sent `translate` messages
*> (contracts/operator-surface.md §3; core/src/console.cob). Each "%s" takes the next argument.
*> Tested by core/tests/test_content_tables.cob.
 78 CL-COUNT                  VALUE 80.
 01 CONSOLE-LANG-DATA.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.death.fall".
       10 FILLER BINARY-LONG VALUE 21.
       10 FILLER PIC X(64) VALUE "%s misjudged the drop".
       10 FILLER BINARY-LONG VALUE 21.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.death.mob.abend".
       10 FILLER BINARY-LONG VALUE 26.
       10 FILLER PIC X(64) VALUE "%s was halted by an Abend".
       10 FILLER BINARY-LONG VALUE 25.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.death.player".
       10 FILLER BINARY-LONG VALUE 23.
       10 FILLER PIC X(64) VALUE "%s lost a duel with %s".
       10 FILLER BINARY-LONG VALUE 22.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.death.starvation".
       10 FILLER BINARY-LONG VALUE 27.
       10 FILLER PIC X(64) VALUE "%s ran out of rations".
       10 FILLER BINARY-LONG VALUE 21.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.death.hail".
       10 FILLER BINARY-LONG VALUE 21.
       10 FILLER PIC X(64) VALUE "%s was battered by hail".
       10 FILLER BINARY-LONG VALUE 23.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.death.command".
       10 FILLER BINARY-LONG VALUE 24.
       10 FILLER PIC X(64) VALUE "%s had their vitality set to zero".
       10 FILLER BINARY-LONG VALUE 33.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.unknown".
       10 FILLER BINARY-LONG VALUE 26.
       10 FILLER PIC X(64) VALUE "Unknown command %s (howto lists the commands)".
       10 FILLER BINARY-LONG VALUE 45.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.not_permitted".
       10 FILLER BINARY-LONG VALUE 32.
       10 FILLER PIC X(64) VALUE "You may not use %s".
       10 FILLER BINARY-LONG VALUE 18.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.missing_argument".
       10 FILLER BINARY-LONG VALUE 35.
       10 FILLER PIC X(64) VALUE "Missing argument. Usage: %s (see howto)".
       10 FILLER BINARY-LONG VALUE 39.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.invalid_argument".
       10 FILLER BINARY-LONG VALUE 35.
       10 FILLER PIC X(64) VALUE "Invalid argument %s. Usage: %s (see howto)".
       10 FILLER BINARY-LONG VALUE 42.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.invalid_name".
       10 FILLER BINARY-LONG VALUE 31.
       10 FILLER PIC X(64) VALUE "%s is not a valid player name".
       10 FILLER BINARY-LONG VALUE 29.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.player_not_found".
       10 FILLER BINARY-LONG VALUE 35.
       10 FILLER PIC X(64) VALUE "No player named %s is online".
       10 FILLER BINARY-LONG VALUE 28.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.dimension_not_found".
       10 FILLER BINARY-LONG VALUE 38.
       10 FILLER PIC X(64) VALUE "No dimension is named %s".
       10 FILLER BINARY-LONG VALUE 24.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.item_not_found".
       10 FILLER BINARY-LONG VALUE 33.
       10 FILLER PIC X(64) VALUE "No item is named %s".
       10 FILLER BINARY-LONG VALUE 19.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.mob_not_found".
       10 FILLER BINARY-LONG VALUE 32.
       10 FILLER PIC X(64) VALUE "No mob is named %s".
       10 FILLER BINARY-LONG VALUE 18.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.not_survival".
       10 FILLER BINARY-LONG VALUE 31.
       10 FILLER PIC X(64) VALUE "%s is not in survival mode".
       10 FILLER BINARY-LONG VALUE 26.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.not_alive".
       10 FILLER BINARY-LONG VALUE 28.
       10 FILLER PIC X(64) VALUE "%s is dead and has not respawned yet".
       10 FILLER BINARY-LONG VALUE 36.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.is_host".
       10 FILLER BINARY-LONG VALUE 26.
       10 FILLER PIC X(64) VALUE "%s is the host of this world".
       10 FILLER BINARY-LONG VALUE 28.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.promote.notice".
       10 FILLER BINARY-LONG VALUE 33.
       10 FILLER PIC X(64) VALUE "You now hold operator status".
       10 FILLER BINARY-LONG VALUE 28.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.demote.notice".
       10 FILLER BINARY-LONG VALUE 32.
       10 FILLER PIC X(64) VALUE "You no longer hold operator status".
       10 FILLER BINARY-LONG VALUE 34.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.howto.header".
       10 FILLER BINARY-LONG VALUE 31.
       10 FILLER PIC X(64) VALUE "Commands you may use (%s):".
       10 FILLER BINARY-LONG VALUE 26.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.howto.entry".
       10 FILLER BINARY-LONG VALUE 30.
       10 FILLER PIC X(64) VALUE "- %s".
       10 FILLER BINARY-LONG VALUE 4.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.roster".
       10 FILLER BINARY-LONG VALUE 25.
       10 FILLER PIC X(64) VALUE "Online (%s): %s".
       10 FILLER BINARY-LONG VALUE 15.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.murmur.incoming".
       10 FILLER BINARY-LONG VALUE 34.
       10 FILLER PIC X(64) VALUE "%s murmurs to you: %s".
       10 FILLER BINARY-LONG VALUE 21.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.murmur.incoming_console".
       10 FILLER BINARY-LONG VALUE 42.
       10 FILLER PIC X(64) VALUE "The server murmurs to you: %s".
       10 FILLER BINARY-LONG VALUE 29.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.murmur.sent".
       10 FILLER BINARY-LONG VALUE 30.
       10 FILLER PIC X(64) VALUE "You murmur to %s: %s".
       10 FILLER BINARY-LONG VALUE 20.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.promote.done".
       10 FILLER BINARY-LONG VALUE 31.
       10 FILLER PIC X(64) VALUE "%s now holds operator status".
       10 FILLER BINARY-LONG VALUE 28.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.promote.already".
       10 FILLER BINARY-LONG VALUE 34.
       10 FILLER PIC X(64) VALUE "%s already holds operator status".
       10 FILLER BINARY-LONG VALUE 32.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.demote.done".
       10 FILLER BINARY-LONG VALUE 30.
       10 FILLER PIC X(64) VALUE "%s no longer holds operator status".
       10 FILLER BINARY-LONG VALUE 34.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.demote.not_operator".
       10 FILLER BINARY-LONG VALUE 38.
       10 FILLER PIC X(64) VALUE "%s does not hold operator status".
       10 FILLER BINARY-LONG VALUE 32.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.eject.done".
       10 FILLER BINARY-LONG VALUE 29.
       10 FILLER PIC X(64) VALUE "Ejected %s".
       10 FILLER BINARY-LONG VALUE 10.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.bar.done".
       10 FILLER BINARY-LONG VALUE 27.
       10 FILLER PIC X(64) VALUE "Barred %s".
       10 FILLER BINARY-LONG VALUE 9.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.bar.already".
       10 FILLER BINARY-LONG VALUE 30.
       10 FILLER PIC X(64) VALUE "%s is already barred".
       10 FILLER BINARY-LONG VALUE 20.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.unbar.done".
       10 FILLER BINARY-LONG VALUE 29.
       10 FILLER PIC X(64) VALUE "Lifted the bar on %s".
       10 FILLER BINARY-LONG VALUE 20.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.unbar.not_barred".
       10 FILLER BINARY-LONG VALUE 35.
       10 FILLER PIC X(64) VALUE "%s is not barred".
       10 FILLER BINARY-LONG VALUE 16.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.barlist".
       10 FILLER BINARY-LONG VALUE 26.
       10 FILLER PIC X(64) VALUE "Barred (%s): %s".
       10 FILLER BINARY-LONG VALUE 15.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.guestlist.on".
       10 FILLER BINARY-LONG VALUE 31.
       10 FILLER PIC X(64) VALUE "The guest list is now enforced".
       10 FILLER BINARY-LONG VALUE 30.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.guestlist.off".
       10 FILLER BINARY-LONG VALUE 32.
       10 FILLER PIC X(64) VALUE "The guest list is no longer enforced".
       10 FILLER BINARY-LONG VALUE 36.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.guestlist.added".
       10 FILLER BINARY-LONG VALUE 34.
       10 FILLER PIC X(64) VALUE "Added %s to the guest list".
       10 FILLER BINARY-LONG VALUE 26.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.guestlist.already".
       10 FILLER BINARY-LONG VALUE 36.
       10 FILLER PIC X(64) VALUE "%s is already on the guest list".
       10 FILLER BINARY-LONG VALUE 31.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.guestlist.removed".
       10 FILLER BINARY-LONG VALUE 36.
       10 FILLER PIC X(64) VALUE "Removed %s from the guest list".
       10 FILLER BINARY-LONG VALUE 30.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.guestlist.not_listed".
       10 FILLER BINARY-LONG VALUE 39.
       10 FILLER PIC X(64) VALUE "%s is not on the guest list".
       10 FILLER BINARY-LONG VALUE 27.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.guestlist.show".
       10 FILLER BINARY-LONG VALUE 33.
       10 FILLER PIC X(64) VALUE "Guest list enforcement %s; guests (%s): %s".
       10 FILLER BINARY-LONG VALUE 42.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.mode.done".
       10 FILLER BINARY-LONG VALUE 28.
       10 FILLER PIC X(64) VALUE "%s now plays in %s mode".
       10 FILLER BINARY-LONG VALUE 23.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.relocate.position".
       10 FILLER BINARY-LONG VALUE 36.
       10 FILLER PIC X(64) VALUE "Relocated %s to %s, %s, %s in %s".
       10 FILLER BINARY-LONG VALUE 32.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.relocate.player".
       10 FILLER BINARY-LONG VALUE 34.
       10 FILLER PIC X(64) VALUE "Relocated %s to %s".
       10 FILLER BINARY-LONG VALUE 18.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.supply.done".
       10 FILLER BINARY-LONG VALUE 30.
       10 FILLER PIC X(64) VALUE "Supplied %s %s to %s".
       10 FILLER BINARY-LONG VALUE 20.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.supply.no_room".
       10 FILLER BINARY-LONG VALUE 33.
       10 FILLER PIC X(64) VALUE "%s has no room for that".
       10 FILLER BINARY-LONG VALUE 23.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.empty.done".
       10 FILLER BINARY-LONG VALUE 29.
       10 FILLER PIC X(64) VALUE "Emptied the inventory of %s (%s items removed)".
       10 FILLER BINARY-LONG VALUE 46.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.vitality.done".
       10 FILLER BINARY-LONG VALUE 32.
       10 FILLER PIC X(64) VALUE "Set the health of %s to %s".
       10 FILLER BINARY-LONG VALUE 26.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.ration.done".
       10 FILLER BINARY-LONG VALUE 30.
       10 FILLER PIC X(64) VALUE "Set the food level of %s to %s".
       10 FILLER BINARY-LONG VALUE 30.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.conjure.done".
       10 FILLER BINARY-LONG VALUE 31.
       10 FILLER PIC X(64) VALUE "Conjured a %s at %s, %s, %s in %s".
       10 FILLER BINARY-LONG VALUE 33.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.conjure.hostile_disabled".
       10 FILLER BINARY-LONG VALUE 43.
       10 FILLER PIC X(64) VALUE "Hostile mobs are switched off, so no %s can be conjured".
       10 FILLER BINARY-LONG VALUE 55.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.sweep.done".
       10 FILLER BINARY-LONG VALUE 29.
       10 FILLER PIC X(64) VALUE "Swept away %s".
       10 FILLER BINARY-LONG VALUE 13.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.sweep.unknown_target".
       10 FILLER BINARY-LONG VALUE 39.
       10 FILLER PIC X(64) VALUE "Nothing to sweep is named %s".
       10 FILLER BINARY-LONG VALUE 28.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.clock.done".
       10 FILLER BINARY-LONG VALUE 29.
       10 FILLER PIC X(64) VALUE "The clock now reads %s".
       10 FILLER BINARY-LONG VALUE 22.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.skies.timed".
       10 FILLER BINARY-LONG VALUE 30.
       10 FILLER PIC X(64) VALUE "The skies over %s turn to %s for %s seconds".
       10 FILLER BINARY-LONG VALUE 43.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.skies.held".
       10 FILLER BINARY-LONG VALUE 29.
       10 FILLER PIC X(64) VALUE "The skies over %s turn to %s until changed".
       10 FILLER BINARY-LONG VALUE 42.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.skies.no_weather".
       10 FILLER BINARY-LONG VALUE 35.
       10 FILLER PIC X(64) VALUE "%s has no skies to change".
       10 FILLER BINARY-LONG VALUE 25.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.homestead.done".
       10 FILLER BINARY-LONG VALUE 33.
       10 FILLER PIC X(64) VALUE "The world spawn point is now %s, %s, %s".
       10 FILLER BINARY-LONG VALUE 39.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.announce.message".
       10 FILLER BINARY-LONG VALUE 35.
       10 FILLER PIC X(64) VALUE "[Server] %s".
       10 FILLER BINARY-LONG VALUE 11.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.announce.done".
       10 FILLER BINARY-LONG VALUE 32.
       10 FILLER PIC X(64) VALUE "Announcement sent".
       10 FILLER BINARY-LONG VALUE 17.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.persist.done".
       10 FILLER BINARY-LONG VALUE 31.
       10 FILLER PIC X(64) VALUE "The world has been saved".
       10 FILLER BINARY-LONG VALUE 24.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.command.shutdown.done".
       10 FILLER BINARY-LONG VALUE 32.
       10 FILLER PIC X(64) VALUE "Shutting down".
       10 FILLER BINARY-LONG VALUE 13.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.disconnect.barred".
       10 FILLER BINARY-LONG VALUE 28.
       10 FILLER PIC X(64) VALUE "You are barred from this world".
       10 FILLER BINARY-LONG VALUE 30.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.disconnect.not_on_guestlist".
       10 FILLER BINARY-LONG VALUE 38.
       10 FILLER PIC X(64) VALUE "You are not on this world's guest list".
       10 FILLER BINARY-LONG VALUE 38.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.disconnect.name_is_host".
       10 FILLER BINARY-LONG VALUE 34.
       10 FILLER PIC X(64) VALUE "The name %s belongs to the host of this world".
       10 FILLER BINARY-LONG VALUE 45.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.disconnect.replaced".
       10 FILLER BINARY-LONG VALUE 30.
       10 FILLER PIC X(64) VALUE "Someone joined elsewhere under your name".
       10 FILLER BINARY-LONG VALUE 40.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.disconnect.shutdown".
       10 FILLER BINARY-LONG VALUE 30.
       10 FILLER PIC X(64) VALUE "The server is shutting down".
       10 FILLER BINARY-LONG VALUE 27.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.disconnect.host_closed".
       10 FILLER BINARY-LONG VALUE 33.
       10 FILLER PIC X(64) VALUE "The host closed the world".
       10 FILLER BINARY-LONG VALUE 25.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.disconnect.pack_required".
       10 FILLER BINARY-LONG VALUE 35.
       10 FILLER PIC X(64) VALUE "This server requires its resource pack".
       10 FILLER BINARY-LONG VALUE 38.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.disconnect.ejected".
       10 FILLER BINARY-LONG VALUE 29.
       10 FILLER PIC X(64) VALUE "You were ejected: %s".
       10 FILLER BINARY-LONG VALUE 20.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "cobolcraft.disconnect.ejected_plain".
       10 FILLER BINARY-LONG VALUE 35.
       10 FILLER PIC X(64) VALUE "You were ejected by an operator".
       10 FILLER BINARY-LONG VALUE 31.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "multiplayer.disconnect.incompatible".
       10 FILLER BINARY-LONG VALUE 35.
       10 FILLER PIC X(64) VALUE "This server runs %s and cannot talk to your game version".
       10 FILLER BINARY-LONG VALUE 56.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "multiplayer.disconnect.outdated_client".
       10 FILLER BINARY-LONG VALUE 38.
       10 FILLER PIC X(64) VALUE "Your game version is too old for this server (%s)".
       10 FILLER BINARY-LONG VALUE 49.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "multiplayer.disconnect.transfers_disabled".
       10 FILLER BINARY-LONG VALUE 41.
       10 FILLER PIC X(64) VALUE "This server does not take transferred players".
       10 FILLER BINARY-LONG VALUE 45.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "multiplayer.disconnect.slow_login".
       10 FILLER BINARY-LONG VALUE 33.
       10 FILLER PIC X(64) VALUE "Logging in took too long".
       10 FILLER BINARY-LONG VALUE 24.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "multiplayer.disconnect.unexpected_query_response".
       10 FILLER BINARY-LONG VALUE 48.
       10 FILLER PIC X(64) VALUE "The server got a reply it never asked for".
       10 FILLER BINARY-LONG VALUE 41.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "multiplayer.disconnect.invalid_player_movement".
       10 FILLER BINARY-LONG VALUE 46.
       10 FILLER PIC X(64) VALUE "The server refused an impossible position".
       10 FILLER BINARY-LONG VALUE 41.
    05 FILLER.
       10 FILLER PIC X(48) VALUE "disconnect.timeout".
       10 FILLER BINARY-LONG VALUE 18.
       10 FILLER PIC X(64) VALUE "No reply arrived in time".
       10 FILLER BINARY-LONG VALUE 24.
 01 CONSOLE-LANG-TABLE REDEFINES CONSOLE-LANG-DATA.
    05 CL-ENTRY OCCURS 80 TIMES.
       10 CL-KEY                PIC X(48).
       10 CL-KEY-LENGTH         BINARY-LONG.
       10 CL-TEXT               PIC X(64).
       10 CL-TEXT-LENGTH        BINARY-LONG.
